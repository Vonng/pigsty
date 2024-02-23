# PGSQL Database

> In this context, Database refers to the object created by SQL `CREATE DATABASE`.

A PostgreSQL server can serve multiple databases simultaneously. And you can customize each database with Pigsty API. 



----------------

## Define Database

Business databases are defined by [`pg_databases`](PARAM#pg_databases), which is a cluster-level parameter. 

For example, the default `meta` database is defined in the `pg-meta` cluster:

```yaml
pg-meta:
  hosts: { 10.10.10.10: { pg_seq: 1, pg_role: primary } }
  vars:
    pg_cluster: pg-meta
    pg_databases:
      - { name: meta ,baseline: cmdb.sql ,comment: pigsty meta database ,schemas: [pigsty] ,extensions: [{name: postgis, schema: public}, {name: timescaledb}]}
      - { name: grafana  ,owner: dbuser_grafana  ,revokeconn: true ,comment: grafana primary database }
      - { name: bytebase ,owner: dbuser_bytebase ,revokeconn: true ,comment: bytebase primary database }
      - { name: kong     ,owner: dbuser_kong     ,revokeconn: true ,comment: kong the api gateway database }
      - { name: gitea    ,owner: dbuser_gitea    ,revokeconn: true ,comment: gitea meta database }
      - { name: wiki     ,owner: dbuser_wiki     ,revokeconn: true ,comment: wiki meta database }
      - { name: noco     ,owner: dbuser_noco     ,revokeconn: true ,comment: nocodb database }
```

Each database definition is a dict with the following fields:

```yaml
- name: meta                      # REQUIRED, `name` is the only mandatory field of a database definition
  baseline: cmdb.sql              # optional, database sql baseline path, (relative path among ansible search path, e.g files/)
  pgbouncer: true                 # optional, add this database to pgbouncer database list? true by default
  schemas: [pigsty]               # optional, additional schemas to be created, array of schema names
  extensions:                     # optional, additional extensions to be installed: array of `{name[,schema]}`
    - { name: postgis , schema: public }
    - { name: timescaledb }
  comment: pigsty meta database   # optional, comment string for this database
  owner: postgres                 # optional, database owner, postgres by default
  template: template1             # optional, which template to use, template1 by default
  encoding: UTF8                  # optional, database encoding, UTF8 by default. (MUST same as template database)
  locale: C                       # optional, database locale, C by default.  (MUST same as template database)
  lc_collate: C                   # optional, database collate, C by default. (MUST same as template database)
  lc_ctype: C                     # optional, database ctype, C by default.   (MUST same as template database)
  tablespace: pg_default          # optional, default tablespace, 'pg_default' by default.
  allowconn: true                 # optional, allow connection, true by default. false will disable connect at all
  revokeconn: false               # optional, revoke public connection privilege. false by default. (leave connect with grant option to owner)
  register_datasource: true       # optional, register this database to grafana datasources? true by default
  connlimit: -1                   # optional, database connection limit, default -1 disable limit
  pool_auth_user: dbuser_meta     # optional, all connection to this pgbouncer database will be authenticated by this user
  pool_mode: transaction          # optional, pgbouncer pool mode at database level, default transaction
  pool_size: 64                   # optional, pgbouncer pool size at database level, default 64
  pool_size_reserve: 32           # optional, pgbouncer pool size reserve at database level, default 32
  pool_size_min: 0                # optional, pgbouncer pool size min at database level, default 0
  pool_max_db_conn: 100           # optional, max database connections at database level, default 100
```

The only required field is `name`, which should be a valid and unique database name in PostgreSQL.

Newly created databases are forked from `template1` database by default. which is customized by [`PG_PROVISION`](PARAM#pg_provision) during cluster bootstrap.

Check [ACL: Database Privilege](PGSQL-ACL#database-privilege) for details about database-level privilege.


----------------

## Create Database

Databases [defined](#define-database) in [`pg_databases`](PARAM#pg_databases) will be automatically created during cluster bootstrap.

If you wish to [create database](PGSQL-ADMIN#create-database) on an existing cluster, the `bin/pgsql-db` util can be used.

Add new database definition to `all.children.<cls>.pg_databases`, and create that database with:

```bash
bin/pgsql-db <cls> <dbname>    # pgsql-db.yml -l <cls> -e dbname=<dbname>
```

It's usually not a good idea to execute this on the existing database again when a `baseline` script is used.  

If you are using the default pgbouncer as the proxy middleware, YOU MUST create the new database with `pgsql-db` util or `pgsql-db.yml` playbook. Otherwise, the new database will not be added to the [pgbouncer database](#pgbouncer-database) list.

Remember, if your database definition has a non-trivial `owner` (dbsu `postgres` by default ), make sure the owner user exists. 
That is to say, always [create](PGSQL-ADMIN#create-user) the [user](PGSQL-USER) before the database.




----------------

## Pgbouncer Database

Pgbouncer is enabled by default and serves as a connection pool middleware.

Pigsty will add all databases in [`pg_databases`](PARAM#pg_databases) to the pgbouncer database list by default.
You can disable the pgbouncer proxy for a specific database by setting `pgbouncer: false` in the database [definition](#define-database).

The database is listed in `/etc/pgbouncer/database.txt`, with extra database-level parameters such as:

```ini
meta                        = host=/var/run/postgresql mode=session
grafana                     = host=/var/run/postgresql mode=transaction
bytebase                    = host=/var/run/postgresql auth_user=dbuser_meta
kong                        = host=/var/run/postgresql pool_size=32 reserve_pool=64
gitea                       = host=/var/run/postgresql min_pool_size=10
wiki                        = host=/var/run/postgresql
noco                        = host=/var/run/postgresql
mongo                       = host=/var/run/postgresql
```

The Pgbouncer database list will be updated when [create database](#create-database) with Pigsty util & playbook. 

To access pgbouncer administration functionality, you can use the `pgb` alias as dbsu.

There's a util function defined in `/etc/profile.d/pg-alias.sh`, allowing you to reroute pgbouncer database traffic to a new host quickly, which can be used during zero-downtime migration.

```bash
# route pgbouncer traffic to another cluster member
function pgb-route(){
  local ip=${1-'\/var\/run\/postgresql'}
  sed -ie "s/host=[^[:space:]]\+/host=${ip}/g" /etc/pgbouncer/pgbouncer.ini
  cat /etc/pgbouncer/pgbouncer.ini
}
```
