# PostgreSQL Databases

In this context, Database refer to object create by SQL `CREATE DATABASE`.

A database server may serve several business databases. These databases are forks of `template1` database by default.
And pigsty will customize that `template1` database during bootstrap.


## Define Database

Business databases are defined by [`pg_databases`](PARAM#pg_databases) in Pigsty.

Here is an database definition example for `pg-meta` cluster in demo config:

```yaml
pg_databases:                       # define business databases on this cluster, array of database definition
  - name: meta                      # REQUIRED, `name` is the only mandatory field of a database definition
    baseline: cmdb.sql              # optional, database sql baseline path, (relative path among ansible search path, e.g files/)
    pgbouncer: true                 # optional, add this database to pgbouncer database list? true by default
    schemas: [pigsty]               # optional, additional schemas to be created, array of schema names
    extensions:                     # optional, additional extensions to be installed: array of `{name[,schema]}`
      - { name: postgis , schema: public }
      - { name: timescaledb }
    comment: pigsty meta database   # optional, comment string for this database
    owner: postgres                # optional, database owner, postgres by default
    template: template1            # optional, which template to use, template1 by default
    encoding: UTF8                 # optional, database encoding, UTF8 by default. (MUST same as template database)
    locale: C                      # optional, database locale, C by default.  (MUST same as template database)
    lc_collate: C                  # optional, database collate, C by default. (MUST same as template database)
    lc_ctype: C                    # optional, database ctype, C by default.   (MUST same as template database)
    tablespace: pg_default         # optional, default tablespace, 'pg_default' by default.
    allowconn: true                # optional, allow connection, true by default. false will disable connect at all
    revokeconn: false              # optional, revoke public connection privilege. false by default. (leave connect with grant option to owner)
    register_datasource: true      # optional, register this database to grafana datasources? true by default
    connlimit: -1                  # optional, database connection limit, default -1 disable limit
    pool_auth_user: dbuser_meta    # optional, all connection to this pgbouncer database will be authenticated by this user
    pool_mode: transaction         # optional, pgbouncer pool mode at database level, default transaction
    pool_size: 64                  # optional, pgbouncer pool size at database level, default 64
    pool_size_reserve: 32          # optional, pgbouncer pool size reserve at database level, default 32
    pool_size_min: 0               # optional, pgbouncer pool size min at database level, default 0
    pool_max_db_conn: 100          # optional, max database connections at database level, default 100
  - { name: grafana  ,owner: dbuser_grafana  ,revokeconn: true ,comment: grafana primary database }
  - { name: bytebase ,owner: dbuser_bytebase ,revokeconn: true ,comment: bytebase primary database }
  - { name: kong     ,owner: dbuser_kong     ,revokeconn: true ,comment: kong the api gateway database }
  - { name: gitea    ,owner: dbuser_gitea    ,revokeconn: true ,comment: gitea meta database }
  - { name: wiki     ,owner: dbuser_wiki     ,revokeconn: true ,comment: wiki meta database }
```



## Create Database

Databases listed in [`pg_databases`](PARAM#pg_databases) will be automatically created during cluster bootstrap.

If you wish to add new database to existing cluster, you can use the `pgsql-db.yml` playbook or `bin/pgsql-db` script.

Add database definition to `all.children.<cls>.pg_databases`, and create that database with:

```bash
bin/pgsql-db <cls> <dbname>    # translate to ./pgsql-db.yml -l <cls> -e dbname=<dbname>
```

It's usually not a good idea to execute this on existing database, But it's ok if there's no user provided baseline script used.  



## Pgbouncer Database

If pgbouncer is enabled (by default). It will add all business databases listed in [`pg_databases`](PARAM#pg_databases) to it.

The database is listed in `/etc/pgbouncer/database.txt`, which contains pgbouncer database list, and database-level parameters.

```bash
meta = host=/var/run/postgresql
grafana = host=/var/run/postgresql
prometheus = host=/var/run/postgresql
```

There's an util function defined in `/etc/profile.d/pg-alias.sh`, that can allows you to reroute pgbouncer database traffic to a new host quickly.

```bash
# route pgbouncer traffic to another cluster member
function pgb-route(){
  local ip=${1-'\/var\/run\/postgresql'}
  sed -ie "s/host=[^[:space:]]\+/host=${ip}/g" /etc/pgbouncer/pgbouncer.ini
  cat /etc/pgbouncer/pgbouncer.ini
}
```


**Special Database**

Pgbouncer has a special admin database named as `pgbouncer`, which can be accessed by [`pg_dbsu`](PARAM#pg_dbsu) and [`pg_admin_username`](#pg_admin_username).
In Pigsty, you can connect to it with shortcut alias `pgb` with dbsu (`postgres` by default).

```bash
$ pgb

```
