# PGSQL Business Databases & Users

> How to define & create PostgreSQL business [users](#user) & [databases](#database).



--------------------

## Users

In PostgreSQL, **User** refers to an object in a database cluster, created by the SQL statement `CREATE USER/ROLE`.

In PostgreSQL, **users** are attached to a database cluster rather than a specific **database**. Therefore, when creating business databases and users, the principle of "user first, database second" should be followed.

## Define User

Pigsty defines the roles and users in the database cluster with two config parameters:

* [`pg_default_roles`](v-pgsql.md#pg_default_roles)
* [`pg_users`](v-pgsql.md#pg_users)

The former defines roles that are common to the entire env, while the latter defines business roles and users that are specific to a single cluster. Both are identical in form and are arrays of user-defined objects. The following is an example of a user definition:

```yaml
- name: dbuser_meta               # required, `name` is the only mandatory field of a user definition
  password: md5d3d10d8cad606308bdb180148bf663e1  # md5 salted password of 'DBUser.Meta'
  # optional, plain text and md5 password are both acceptable (prefixed with `md5`)
  login: true                     # optional, can login, true by default  (new biz ROLE should be false)
  superuser: false                # optional, is superuser? false by default
  createdb: false                 # optional, can create database? false by default
  createrole: false               # optional, can create role? false by default
  inherit: true                   # optional, can this role use inherited privileges? true by default
  replication: false              # optional, can this role do replication? false by default
  bypassrls: false                # optional, can this role bypass row level security? false by default
  pgbouncer: true                 # optional, add this user to pgbouncer user-list? false by default (production user should be true explicitly)
  connlimit: -1                   # optional, user connection limit, default -1 disable limit
  expire_in: 3650                 # optional, now + n days when this role is expired (OVERWRITE expire_at)
  expire_at: '2030-12-31'         # optional, YYYY-MM-DD 'timestamp' when this role is expired  (OVERWRITTEN by expire_in)
  comment: pigsty admin user      # optional, comment string for this user/role
  roles: [dbrole_admin]           # optional, belonged roles. default roles are: dbrole_{admin,readonly,readwrite,offline}
  parameters: {}                  # optional, role level parameters with `ALTER ROLE SET`
  # search_path: public         # key value config parameters according to postgresql documentation (e.g: use pigsty as default search_path)
```

* `name`: Each user or role must specify the `name`, the only mandatory parameter.
* `password`: Optional, if left blank then no password is set, you can use the MD5 cipher password.
* `login`, `superuser`, `createdb`, `createrole`, `inherit`, `replication`, `bypassrls`: All are boolean type tags used to set user attributes. If not set, the system default value is used.
  Where `pg_default_roles` users do not have the `login` attribute by default, and `pg_users` have the `login` attribute by default, which can be overridden by explicit config.
* `expire_at` and `expire_in` are used to control the user expiration time. `expire_at` uses a date timestamp in the shape of `YYYY-mm-DD`. `expire_in` uses the number of days to expire from now and overrides the `expire_at` option if `expire_in` exists.
* `pgbouncer: true` is used to control whether new users are added to the Pgbouncer user list. This parameter must be explicitly defined as `true` for the corresponding user to be added to the Pgbouncer user list.
* `roles` are the group to which the role/user belongs, multiple groups can be specified, e.g. add a [**default role**](#default role) for the user.



## Create User

The roles and users defined by [`pg_default_roles`](v-pgsql.md#pg_default_roles) and [`pg_users`](v-pgsql.md#pg_users) are automatically created sequentially when a database cluster (or master instance) is created.

On an existing database cluster, use the prebuilt playbook [`pgsql-createuser.yml`](p-pgsql.md#pgsql-createuser) to create a new business database.

First, you need to add the definition of this user to the [`pg_users`](v-pgsql.md#pg_users) config entry of the corresponding cluster config. Then, use the following command to create the user or role on the corresponding cluster.

```bash
bin/createuser <pg_cluster> <username>    # <pg_cluster> is the cluster name, <user.name> is the new username. It must be defined first, and then the script must be executed to create.
bin/createuser pg-meta dbuser_meta        # Example: Create dbuser_meta user in pg-meta cluster
./pgsql-createuser.yml -l <pg_cluster> -e pg_user=<user.name>  # The script actually calls the following Ansible playbook to complete the corresponding task.
```

When the target user already exists, Pigsty modifies the properties of the target user to make it match the config.

If a user is created with the `pgbouncer: true` flag, the playbook will also modify and reload the config `/etc/pgbouncer/userlist.txt` for all Pgbouncers in the database cluster.

**Be sure to add new business users and databases via pre-built playbooks or scripts**, otherwise, it is difficult to keep the connection pool config info synchronized with the database.


### Pgbouncer User

The operating system user for Pgbouncer will be consistent with the dbsu, both using `{{ pg_dbsu }}`, which defaults to `postgres`.
Pigsty defaults to using the Postgres admin user as the Pgbouncer admin user and the Postgres monitor user as the Pgbouncer monitor user as well.

The user list of Pgbouncer is controlled through the `/etc/pgbouncer/userlist.txt` file.
Pgbouncer's user permissions are controlled via `/etc/pgbouncer/pgb_hba.conf`.

Only users who explicitly add the `pgbouncer: true` inventory will be added to the Pgbouncer user list and access the database through Pgbouncer.
Normally accounts used by production apps should access the database through the Pgbouncer connection pool, while personal users, administration, ETL, etc. should access the database directly.

Under normal circumstances please use the [`pgsql-createuser.yml`](p-pgsql.md#pgsql-createuser) playbook to manage database users. You can also manually add users in an emergency by executing the following command on the database instance as the `postgres` user, which needs to be executed on all Pgbouncers in the cluster and reload the config.

```bash
# This command can be used to add users manually in case of emergency, usage:pgbouncer-create-user <username> [password]
/pg/bin/pgbouncer-create-user

pgbouncer-create-user dbp_vonng Test.Password # Plaintext Password         
pgbouncer-create-user dbp_vonng md596bceae83ba2937778af09adf00ae738 # md5 password
pgbouncer-create-user dbp_vonng auto          # Get password from database query
pgbouncer-create-user dbp_vonng null          # Use empty password
```










--------------------------


## Database

Here **DATABASE** refers to neither database software nor database server process, but a logical object in a database cluster, created by the SQL statement `CREATE DATABASE`.

Pigsty will modify and customize the default database `template1`, create the default schema, install the default extensions, configure the default permissions, and the newly created database will inherit these settings from `template1` by default.

PostgreSQL provides schema as a namespace, so it is not recommended to create too many databases in a single database cluster.

`pg_exporter` will find and monitor all business databases by default through the **autodiscovery** mechanism.


## Define Database

Pigsty defines the databases in a cluster via the [`pg_databases`](v-pgsql.md#pg_databases) config parameter, which is an array of objects consisting of database definitions.
The databases within the array are created sequentially in **definition order** so that databases defined later can use previously defined databases as **templates**.

The following is an example of a database definition:

```yaml
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
* `template`: the template used when the database is created, the default is `template1`.
* `encoding`: the default character encoding of the database, the default is `UTF8`, the default is consistent with the instance. It is recommended not to configure and modify it.
* `locale`: the default localization rule for the database, default is `C`, it is recommended not to configure it and keep it consistent with the instance.
* `lc_collate`: the default localization string sorting rule for the database, default is the same as the instance setting, it is recommended not to modify it, and must be consistent with the template. It is strongly recommended not to configure, or configure to `C`.
* `lc_ctype`: the default LOCALE of the database, the default is the same as the instance setting, it is recommended not to modify or set it, it must be consistent with the template. It is recommended to configure to C or `en_US.UTF8`.
* `allowconn`: whether to allow connection to the database, default is `true`, not recommended to modify.
* `revokeconn`: whether to reclaim the permission to connect to the database? The default is `false`. If `true`, then `PUBLIC CONNECT` permission on the database will be reclaimed. Only the default user (`dbsu|monitor|admin|replicator|owner`) can connect. In addition, the `admin|owner` will have GRANT OPTION, which can give other users connection privileges.
* `tablespace`: the tablespace associated with the database, the default is `pg_default`.
* `connlimit`: database connection limit, default is `-1`, i.e. no limit.
* `extensions`: array of objects, each of which defines an **extension** in the database, and its installed **schema**.
* `parameters`: K-V objects, each K-V defines a parameter that needs to be modified against the database via `ALTER DATABASE`.
* `pgbouncer`: Boolean option, whether to join this database to Pgbouncer. All databases will be added to the Pgbouncer list unless `pgbouncer: false` is explicitly specified.
* `comment`: database comment info.


## Create Database

The databases defined by [`pg_databases`](v-pgsql.md#pg_databases) are automatically created sequentially when a cluster (or master instance) is created.

On a running existing cluster, use the prebuilt playbook [`pgsql-createdb.yml`](p-pgsql.md#pgsql-createdb) to create a new business database.

First, add the definition of this database to the [`pg_databases`](v-pgsql.md#pg_databases) config of the corresponding database cluster config. Then, the database can be created on the corresponding cluster using the following command:

```bash
bin/createdb <pg_cluster>  <database.name> # <pg_cluster> is the cluster name and <database.name> is the name of the new database.
bin/createdb pg-meta meta                  # Example: Creating a meta database in a pg-meta cluster.
./pgsql-createdb.yml -l <pg_cluster> -e pg_database=<dbname>  # The script actually calls the following Ansible playbook to complete the corresponding task.
```

When the target database already exists, Pigsty modifies the properties of the target database to make it match the config.

If you have configured the `owner` parameter for the database, you must ensure that the user already exists when the database is created. So it is usually recommended to complain inherited the creation of the [business user](#user) first, before creating the database.

The playbook by default modifies and reloads the config `/etc/pgbouncer/database.txt` for all Pgbouncers in the database cluster. However, if the database being created has the `pgbouncer: false` flag, the playbook skips the Pgbouncer config phase.

If the database will be served externally via a connection pool, **be sure to create it via a pre-built playbook or scripts**.


### Pgbouncer Database

The operating system user of Pgbouncer will be the same as the dbsu, both using `{{ pg_dbsu }}`, defaulting to `postgres`.
Pgbouncer's administrative database is named `pgbouncer` and can be managed using the `postgres` and `dbuser_dba` users, and you can connect to pgbouncer as an administrator by executing the shortcut `pgb` under the operating system user `postgres`.

The list of databases in Pgbouncer is controlled through the `/etc/pgbouncer/database.txt` file, and the default content is similar to the following format:

```bash
# Database name = actual target connection info
meta = host=/var/run/postgresql
grafana = host=/var/run/postgresql
prometheus = host=/var/run/postgresql
```

In Pigsty, Pgbouncer and Postgres instances are deployed in a 1:1 co-location, using `/var/run/postgresql` Unix socket communication.

Normally, all new databases are added to Pgbouncer's database list. If you want a database to be inaccessible viasa Pgbouncer, you can explicitly specify `pgbouncer: false` in the database definition.

Normally please use the [`pgsql-createdb.yml`](p-pgsql.md#pgsql-createdb) playbook to create a new database. The database can also be added manually by executing the following command on the database instance as the `postgres` user, which needs to be executed on all Pgbouncers in the cluster and the configuration reloaded.

```bash
# This command can be used to add the database manually in special cases.
# pgbouncer-create-user <dbname> [connstr] [dblist=/etc/pgbouncer/database.txt]
/pg/bin/pgbouncer-create-db
pgbouncer-create-db meta                     # Create a meta database, pointing to the local database of the same name
pgbouncer-create-db test host=10.10.10.13    # Create the test database and point it to the database of the same name on 10.10.10.13 
```

After manually modifying the Pgboinherita createduncer config, please reload it via `systemctl reload pgbouncer` to take effect. (Do not use `pgbouncer -R`).

