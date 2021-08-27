# Database

The term **Database** refers to neither the database software nor the database server process, but rather to a logical object in a database cluster.
This is the database object created by the SQL statement `CREATE DATABASE`.

Pigsty will modify and customize the default template database `template1`, create the default schema, install the default extensions, configure the default permissions, and the newly created database will inherit these settings from `template1` by default.

PostgreSQL provides schema as a namespace, so it is not recommended to create too many databases in a single database cluster.

By default, `pg_exporter` will find and monitor all business databases through the auto-discovery mechanism.


## Schema

Pigsty defines the databases in a database cluster with the `pg_databases` configuration parameter, which is an array of objects consisting of database definitions.
The databases within the array are created sequentially in **definition order**, so that databases defined later can use previously defined databases as **templates**.

The following is an example of a database definition.

```yaml
pg_databases:                       # define business databases on this cluster, array of database definition
  
  # define the default `meta` database
  - name: meta                      # required, `name` is the only mandatory field of a database definition
    baseline: cmdb.sql              # optional, database sql baseline path, (relative path among ansible search path, e.g files/)
    owner: postgres                 # optional, database owner, postgres by default
    template: template1             # optional, which template to use, template1 by default
    encoding: UTF8                  # optional, database encoding, UTF8 by default. (MUST same as template database)
    locale: C                       # optional, database locale, C by default.  (MUST same as template database)
    lc_collate: C                   # optional, database collate, C by default. (MUST same as template database)
    lc_ctype: C                     # optional, database ctype, C by default.   (MUST same as template database)
    tablespace: pg_default          # optional, default tablespace, 'pg_default' by default.
    allowconn: true                 # optional, allow connection, true by default. false will disable connect at all
    revokeconn: false               # optional, revoke public connection privilege. false by default. (leave connect with grant option to owner)
    pgbouncer: true                 # optional, add this database to pgbouncer database list? true by default
    comment: pigsty meta database   # optional, comment string for this database
    connlimit: -1                   # optional, database connection limit, default -1 disable limit
    schemas: [pigsty]               # optional, additional schemas to be created, array of schema names
    extensions:                     # optional, additional extensions to be installed: array of schema definition `{name,schema}`
      - {name: adminpack, schema: pg_catalog}    # install adminpack to pg_catalog and install postgis to public
      - {name: postgis, schema: public}          # if schema is omitted, extension will be installed according to search_path.
```


* `name`: the name of the database, **required**.
* `baseline`: SQL file path (Ansible search path, usually located in `files`), used to initialize the database contents.
* `owner`: database owner, default is `postgres`.
* `template`: the template used when creating the database, default is `template1`.
* `encoding`: the default character encoding of the database, default is `UTF8`, default is consistent with the instance. It is recommended not to configure and modify it.
* `locale`: the default localization rule for the database, default is `C`, it is recommended not to configure it and keep it consistent with the instance.
* `lc_collate`: the default localization string sorting rule for the database, default is the same as the instance setting, it is recommended not to modify it, and must be consistent with the template database. It is strongly recommended not to configure it, or configure it as `C`.
* `lc_ctype`: the default LOCALE of the database, the default is the same as the instance setting, it is recommended not to modify or set it, and it must be consistent with the template database. It is recommended to configure to C or `en_US.UTF8`.
* `allowconn`: whether to allow connection to the database, default is `true`, not recommended to modify.
* `revokeconn`: whether to reclaim the permission to connect to the database? The default is `false`. If `true`, then `PUBLIC CONNECT` permission on the database will be reclaimed. Only the default user (`dbsu|monitor|admin|replicator|owner`) can connect. In addition, `admin|owner` will have GRANT OPTION, which can give other users connection privileges.
* `tablespace`: the tablespace associated with the database, the default is `pg_default`.
* `connlimit`: database connection limit, default is `-1`, i.e. no limit.
* `extensions`: array of objects , each of which defines an **extension** in the database, and its installed **schema**.
* `parameters`: KV objects, each KV defines a parameter that needs to be modified against the database via `ALTER DATABASE`.
* `pgbouncer`: Boolean option, whether to join this database to Pgbouncer. All databases will be added to the Pgbouncer list unless `pgbouncer: false` is explicitly specified.
* `comment`: database comment information.


## Creating Databases

The databases defined by `pg_databases` are automatically created sequentially when a database cluster (or master instance) is created.

You can create a new business database on a running database cluster by using the pre-built script `pgsql-createdb.yml`.

First, you need to add the definition of the database to the `pg_databases` configuration of the corresponding database cluster. Then, use the following command to create the database on the corresponding cluster.

```bash
# <pg_cluster> is the cluster name and <dbname> is the new username.
# must be defined first, then the script is executed to create it
bin/createdb <pg_cluster> <dbname>
bin/createdb pg-meta meta # Example: Creating a meta database in a pg-meta cluster

# This script actually calls the following Ansible script to complete the corresponding task
. /pgsql-createdb.yml -l <pg_cluster> -e pg_database=<dbname>
```

When the target database already exists, Pigsty modifies the properties of the target database to make it match the configuration.

If you have configured the `owner` parameter for the database, you must ensure that the user already exists when the database is created.
So it is usually recommended to complete the creation of the business user first, and then create the database.

The script by default modifies and reloads the configuration `/etc/pgbouncer/database.txt` for all Pgbouncers in the database cluster
However, if the database being created has the `pgbouncer: false` flag, the script skips the Pgbouncer configuration phase

! > If the database will be served externally via a connection pool, **be sure to create it via a pre-built script or scripts**.


## Pgbouncer

The operating system user for Pgbouncer will be the same as the database superuser, both using `{{ pg_dbsu }}`, defaulting to `postgres`.
Pgbouncer's administrative database is named `pgbouncer` and can be managed using the `postgres` and `dbuser_dba` users. You can connect to pgbouncer as an administrator by executing the shortcut `pgb` under the OS user `postgres`

The list of databases in Pgbouncer is controlled through the `/etc/pgbouncer/database.txt` file, which by default has a format similar to the following

```bash
# database name = actual target connection information
meta = host=/var/run/postgresql
grafana = host=/var/run/postgresql
prometheus = host=/var/run/postgresql
```

In Pigsty, Pgbouncer and Postgres instances are deployed 1:1 on the same machine, using `/var/run/postgresql` Unix socket communication.

Normally, all new databases are added to Pgbouncer's database list. If you want a database to be inaccessible via Pgbouncer, you can explicitly specify `pgbouncer: false` in the database definition.

Normally, use the `pgsql-createdb.yml` script to create a new database. You can also add the database manually by executing the following command on the database instance as the ``postgres`` user, which needs to be executed on all Pgbouncers in the cluster and reload the configuration.

```bash
# This command can be used to add the database manually in special cases
/pg/bin/pgbouncer-create-db
# Usage: pgbouncer-create-user <dbname> [connstr] [dblist=/etc/pgbouncer/database.txt]

pgbouncer-create-db meta # Create a meta database, pointing to the local database of the same name
pgbouncer-create-db test host=10.10.10.13 # Create the test database and point it to the database of the same name on 10.10.10.13 
```

? > After manually modifying the Pgbouncer configuration, please reload it via `systemctl reload pgbouncer` to take effect. (Do not use `pgbouncer -R`)