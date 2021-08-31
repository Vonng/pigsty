# PostgreSQL Template

[PG Provision](v-pg-provision.md) is responsible for pulling together a brand new set of Postgres clusters, while PG
Template is responsible for creating default objects in this new set of database clusters based on PG Provision,
including:

* Basic roles: read-only roles, read-write roles, administrative roles
* Basic users: replication user, super user, monitoring user, administration user
* Default permissions in the template database
* Default schemas
* Default extensions
* HBA black and white list rules

## Overview

|                            Name                             |    Type    | Level  | Description |
| :----------------------------------------------------------: | :--------: | :---: | ---- |
|              [pg_init](v-pg-template.md#pg_init)               |  `string`  |  G/C  | path to postgres init script |
| [pg_replication_username](v-pg-template.md#pg_replication_username) |  `string`  |  G  | replication user's name |
| [pg_replication_password](v-pg-template.md#pg_replication_password) |  `string`  |  G  | replication user's password |
|  [pg_monitor_username](v-pg-template.md#pg_monitor_username)   |  `string`  |  G  | monitor user's name |
|  [pg_monitor_password](v-pg-template.md#pg_monitor_password)   |  `string`  |  G  | monitor user's password |
|    [pg_admin_username](v-pg-template.md#pg_admin_username)     |  `string`  |  G  | admin user's name |
|    [pg_admin_password](v-pg-template.md#pg_admin_password)     |  `string`  |  G  | admin user's password |
|     [pg_default_roles](v-pg-template.md#pg_default_roles)      |  `role[]`  |  G  | list or global default roles/users |
| [pg_default_privilegs](v-pg-template.md#pg_default_privilegs)  |  `string[]`  |  G  | list of default privileges |
|   [pg_default_schemas](v-pg-template.md#pg_default_schemas)    |  `string[]`  |  G  | list of default schemas |
| [pg_default_extensions](v-pg-template.md#pg_default_extensions) |  `extension[]`  |  G  | list of default extensions |
|     [pg_offline_query](v-pg-template.md#pg_offline_query)      |  `bool`  |  **I**  | allow offline query? |
|            [pg_reload](v-pg-template.md#pg_reload)             |  `bool`  |  **A**  | reload configuration? |
|         [pg_hba_rules](v-pg-template.md#pg_hba_rules)          |  `rule[]`  |  G  | global HBA rules |
|   [pg_hba_rules_extra](v-pg-template.md#pg_hba_rules_extra)    |  `rule[]`  |  C/I  | ad hoc HBA rules |
|  [pgbouncer_hba_rules](v-pg-template.md#pgbouncer_hba_rules)   |  `rule[]`  |  G/C  | global pgbouncer HBA rules |
| [pgbouncer_hba_rules_extra](v-pg-template.md#pgbouncer_hba_rules_extra) |  `rule[]`  |  G/C  | ad hoc pgbouncer HBA rules |
| [pg_databases](v-pg-template.md#pg_databases) | `database[]`   | G/C | [business databases definition](c-database.md) |
| [pg_users](v-pg-template.md#pg_users) | `user[]`               | G/C | [business users definition](c-user.md) |



## Defaults

```yaml
#------------------------------------------------------------------------------
# POSTGRES TEMPLATE
#------------------------------------------------------------------------------
# - template - #
pg_init: pg-init                              # init script for cluster template

# - system roles - #
pg_replication_username: replicator           # system replication user
pg_replication_password: DBUser.Replicator    # system replication password
pg_monitor_username: dbuser_monitor           # system monitor user
pg_monitor_password: DBUser.Monitor           # system monitor password
pg_admin_username: dbuser_dba                 # system admin user
pg_admin_password: DBUser.DBA                 # system admin password

# - default roles - #
pg_default_roles: # check https://pigsty.cc/#/zh-cn/c-user for more detail, sequence matters
  # default roles
  - { name: dbrole_readonly  , login: false , comment: role for global read-only access }                            # production read-only role
  - { name: dbrole_readwrite , login: false , roles: [ dbrole_readonly ], comment: role for global read-write access }  # production read-write role
  - { name: dbrole_offline , login: false , comment: role for restricted read-only access (offline instance) }        # restricted-read-only role
  - { name: dbrole_admin , login: false , roles: [ pg_monitor, dbrole_readwrite ] , comment: role for object creation }  # production DDL change role

  # default users
  - { name: postgres , superuser: true , comment: system superuser }                             # system dbsu, name is designated by `pg_dbsu`
  - { name: dbuser_dba , superuser: true , roles: [ dbrole_admin ] , comment: system admin user }  # admin dbsu, name is designated by `pg_admin_username`
  - { name: replicator , replication: true , bypassrls: true , roles: [ pg_monitor, dbrole_readonly ] , comment: system replicator }                   # replicator
  - { name: dbuser_monitor , roles: [ pg_monitor, dbrole_readonly ] , comment: system monitor user , parameters: { log_min_duration_statement: 1000 } } # monitor user
  - { name: dbuser_stats , password: DBUser.Stats , roles: [ dbrole_offline ] , comment: business offline user for offline queries and ETL }           # ETL user

# - privileges - #
# object created by dbsu and admin will have their privileges properly set
pg_default_privileges:
  - GRANT USAGE                         ON SCHEMAS   TO dbrole_readonly
  - GRANT SELECT                        ON TABLES    TO dbrole_readonly
  - GRANT SELECT                        ON SEQUENCES TO dbrole_readonly
  - GRANT EXECUTE                       ON FUNCTIONS TO dbrole_readonly
  - GRANT USAGE                         ON SCHEMAS   TO dbrole_offline
  - GRANT SELECT                        ON TABLES    TO dbrole_offline
  - GRANT SELECT                        ON SEQUENCES TO dbrole_offline
  - GRANT EXECUTE                       ON FUNCTIONS TO dbrole_offline
  - GRANT INSERT, UPDATE, DELETE        ON TABLES    TO dbrole_readwrite
  - GRANT USAGE, UPDATE                 ON SEQUENCES TO dbrole_readwrite
  - GRANT TRUNCATE, REFERENCES, TRIGGER ON TABLES    TO dbrole_admin
  - GRANT CREATE                        ON SCHEMAS   TO dbrole_admin

# - schemas - #
pg_default_schemas: [ monitor ]                 # default schemas to be created

# - extension - #
pg_default_extensions: # default extensions to be created
  - { name: 'pg_stat_statements', schema: 'monitor' }
  - { name: 'pgstattuple',        schema: 'monitor' }
  - { name: 'pg_qualstats',       schema: 'monitor' }
  - { name: 'pg_buffercache',     schema: 'monitor' }
  - { name: 'pageinspect',        schema: 'monitor' }
  - { name: 'pg_prewarm',         schema: 'monitor' }
  - { name: 'pg_visibility',      schema: 'monitor' }
  - { name: 'pg_freespacemap',    schema: 'monitor' }
  - { name: 'pg_repack',          schema: 'monitor' }
  - name: postgres_fdw
  - name: file_fdw
  - name: btree_gist
  - name: btree_gin
  - name: pg_trgm
  - name: intagg
  - name: intarray

# - hba - #
pg_offline_query: false                       # set to true to enable offline query on this instance (instance level)
pg_reload: true                               # reload postgres after hba changes
pg_hba_rules: # postgres host-based authentication rules
  - title: allow meta node password access
    role: common
    rules:
      - host    all     all                         10.10.10.10/32      md5

  - title: allow intranet admin password access
    role: common
    rules:
      - host    all     +dbrole_admin               10.0.0.0/8          md5
      - host    all     +dbrole_admin               172.16.0.0/12       md5
      - host    all     +dbrole_admin               192.168.0.0/16      md5

  - title: allow intranet password access
    role: common
    rules:
      - host    all             all                 10.0.0.0/8          md5
      - host    all             all                 172.16.0.0/12       md5
      - host    all             all                 192.168.0.0/16      md5

  - title: allow local read/write (local production user via pgbouncer)
    role: common
    rules:
      - local   all     +dbrole_readonly                                md5
      - host    all     +dbrole_readonly           127.0.0.1/32         md5

  - title: allow offline query (ETL,SAGA,Interactive) on offline instance
    role: offline
    rules:
      - host    all     +dbrole_offline               10.0.0.0/8        md5
      - host    all     +dbrole_offline               172.16.0.0/12     md5
      - host    all     +dbrole_offline               192.168.0.0/16    md5

pg_hba_rules_extra: [ ]                        # extra hba rules (overwrite by cluster/instance level config)

pgbouncer_hba_rules: # pgbouncer host-based authentication rules
  - title: local password access
    role: common
    rules:
      - local  all          all                                     md5
      - host   all          all                     127.0.0.1/32    md5

  - title: intranet password access
    role: common
    rules:
      - host   all          all                     10.0.0.0/8      md5
      - host   all          all                     172.16.0.0/12   md5
      - host   all          all                     192.168.0.0/16  md5

pgbouncer_hba_rules_extra: [ ]                 # extra pgbouncer hba rules (overwrite by cluster/instance level config)
# pg_users: []                                # business users
# pg_databases: []                            # business databases
```




## Details

### pg_init

Path of cluster init script. `pg-init` by default. (which links
to [roles/postgres/templates/pg-init](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/pg-init) by
default)

It will be rendered to `/pg/bin/pg-init` and execute after cluster is bootstrapped.

The default `pg-init` is merely a wrapper of pre-rendered SQL commands:

* `/pg/tmp/pg-init-roles.sql`: create roles according to [`pg_default_roles`](#pg_default_roles)
* `/pg/tmp/pg-init-template.sql`: SQL generated according to [`pg_default_privileges`](#pg_default_privileges)
  , [`pg_default_schemas`](#pg_default_schemas), [`pg_default_extensions`](#pg_default_extensions) . Will apply
  to `template1` and `postgres`.

```bash
# system default roles
psql postgres -qAXwtf /pg/tmp/pg-init-roles.sql

# system default template
psql template1 -qAXwtf /pg/tmp/pg-init-template.sql

# make postgres same as templated database (optional)
psql postgres  -qAXwtf /pg/tmp/pg-init-template.sql
```

You can add arbitrary logic here , but changing it is strongly not recommended, unless you really know what you are
doing.

### pg_replication_username

The username of the database used to perform PostgreSQL stream replication

The default is `replicator`.

### pg_replication_password

The password of the database user to perform PostgreSQL replication, must be in plaintext

Default is `DBUser.Replicator`, strongly recommended to change it!

### pg_monitor_username

The database user name used to perform PostgreSQL and Pgbouncer monitoring tasks

The default is `dbuser_monitor`.

### pg_monitor_password

The password of the database user used to perform PostgreSQL and Pgbouncer monitoring tasks, must be in plaintext

Default is `DBUser.Monitor`, strongly recommended to change it!

### pg_admin_username

Database username used to perform PostgreSQL database administration tasks (DDL changes), default with superuser
privileges.

Default is `dbuser_dba`.

### pg_admin_password

The database user password used to perform PostgreSQL database administration tasks (DDL changes), must be in plaintext

Default is `DBUser.DBA`

!> It's strongly recommended changing it!

### pg_default_roles

Defines the default [roles and users](c-user.md) in PostgreSQL, in the form of an array of objects, each of which
defines a user or role.

Each user or role must specify `name` and the rest of the fields are optional.

* `password` is optional, if left blank then no password is set, you can use MD5 cipher password.
* `login`, `superuser`, `createdb`, `createrole`, `inherit`, `replication`, `bypassrls` are all boolean types used to
  set user attributes. If not set, the system defaults are used.
* Users are created by `CREATE USER`, so they have the `login` attribute by default. If you are creating a role, you
  need to specify `login: false`.
* `expire_at` and `expire_in` are used to control when users expire. `expire_at` uses a date and time stamp
  like `YYYY-mm-DD`. `expire_in` uses the number of days to expire from now, and overrides the `expire_at` option
  if `expire_in` exists.
* New users are **not** added to the Pgbouncer user list by default, `pgbouncer: true` must be explicitly defined for
  the user to be added to the Pgbouncer user list.

* Users/roles will be created in order, users defined later can belong to the roles defined earlier.

```yaml
pg_users: # define business users/roles on this cluster, array of user definition
  # define admin user for meta database (This user are used for pigsty app deployment by default)
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
    roles: [ dbrole_admin ]           # optional, belonged roles. default roles are: dbrole_{admin,readonly,readwrite,offline}
    parameters: # optional, role level parameters with `ALTER ROLE SET`
      log_min_duration_statements: 1000
    search_path: public         # key value config parameters according to postgresql documentation (e.g: use pigsty as default search_path)
  - { name: dbuser_view , password: DBUser.Viewer  ,pgbouncer: true ,roles: [ dbrole_readonly ], comment: read-only viewer for meta database }

  # define additional business users for prometheus & grafana (optional)
  - { name: dbuser_grafana    , password: DBUser.Grafana    ,pgbouncer: true ,roles: [ dbrole_admin ], comment: admin user for grafana database }
  - { name: dbuser_prometheus , password: DBUser.Prometheus ,pgbouncer: true ,roles: [ dbrole_admin ], comment: admin user for prometheus database }

```

Pigsty have a default [user/role](c-user.md) system with basic [auth](c-auth.md) and [privilege](c-privilege.md)
support. Which is sufficient for most common cases.

### pg_default_privileges

Define `DEFAULT PRIVILEGE` of this cluster

Object that created by `{{ dbsu」}}` and `{{ pg_admin_username }}` will have their privileges properly set.

```yaml
pg_default_privileges:
  - GRANT USAGE                         ON SCHEMAS   TO dbrole_readonly
  - GRANT SELECT                        ON TABLES    TO dbrole_readonly
  - GRANT SELECT                        ON SEQUENCES TO dbrole_readonly
  - GRANT EXECUTE                       ON FUNCTIONS TO dbrole_readonly
  - GRANT USAGE                         ON SCHEMAS   TO dbrole_offline
  - GRANT SELECT                        ON TABLES    TO dbrole_offline
  - GRANT SELECT                        ON SEQUENCES TO dbrole_offline
  - GRANT EXECUTE                       ON FUNCTIONS TO dbrole_offline
  - GRANT INSERT, UPDATE, DELETE        ON TABLES    TO dbrole_readwrite
  - GRANT USAGE,  UPDATE                ON SEQUENCES TO dbrole_readwrite
  - GRANT TRUNCATE, REFERENCES, TRIGGER ON TABLES    TO dbrole_admin
  - GRANT CREATE                        ON SCHEMAS   TO dbrole_admin
```

Check [Privileges](c-privilege.md) for more information.

### pg_default_schemas

List of default schema that will be created on all databases.

```yml
pg_default_schemas: [ monitor ]                 # default schemas to be created
```

Pigsty will create a `monitor` schema on all databases by default.

### pg_default_extensions

Array of extension definition. Each extension is represented as :

```json
{
  "name": "xxx",
  "schema": "xxx"
}
```

Extensions defined here are installed to the template database by default, so newly created database will have them all. 

If the `schema` field is not specified, the extension will be installed to the corresponding schema based on the
current `search_path`.

```yaml
pg_default_extensions:
  - { name: 'pg_stat_statements',  schema: 'monitor' }
  - { name: 'pgstattuple',         schema: 'monitor' }
  - { name: 'pg_qualstats',        schema: 'monitor' }
  - { name: 'pg_buffercache',      schema: 'monitor' }
  - { name: 'pageinspect',         schema: 'monitor' }
  - { name: 'pg_prewarm',          schema: 'monitor' }
  - { name: 'pg_visibility',       schema: 'monitor' }
  - { name: 'pg_freespacemap',     schema: 'monitor' }
  - { name: 'pg_repack',           schema: 'monitor' }
  - name: postgres_fdw
  - name: file_fdw
  - name: btree_gist
  - name: btree_gin
  - name: pg_trgm
  - name: intagg
  - name: intarray
```

### pg_offline_query

Instance-level variable, boolean type, defaults to `false`.

When set to `true`, the user group `dbrole_offline` can connect to the instance and perform offline queries, regardless of the role of the current instance.

It is more practical for cases where the number of instances is small (e.g. one master and one slave), and the user can mark the only slave as `pg_offline_query = true`
and thus accept ETL, slow queries and interactive access. See [Access Control - Offline Users](c-privileges) for details.



### pg_reload

Command line parameter, boolean type, defaults to `true`.

When set to `true`, Pigsty will execute the `pg_ctl reload` application immediately after the HBA rule is generated.

You can disable it by specifying `-e pg_reload=false` when you want to generate the `pg_hba.conf` file and manually compare it before applying it to take effect.



### pg_hba_rules

Set the client IP black and white list rules for the database. An array of objects, each of which represents a rule.

Each rule consists of three parts.

* `title`, the title of the rule, which is converted to a comment in the HBA file
* `role`, the application role, `common` means apply to all instances, other values (e.g. `replica`, `offline`) will be installed only to matching roles. For example, `role='replica'`
  means that this rule will only be applied to instances with `pg_role == 'replica'`.
* `rules`, an array of strings, each record representing a rule that will eventually be written to `pg_hba.conf`.

As a special case, HBA rules with `role == 'offline'` are additionally installed on instances with `pg_offline_query == true`.


```yaml
pg_hba_rules:
  - title: allow meta node password access
    role: common
    rules:
      - host    all     all                         10.10.10.10/32      md5

  - title: allow intranet admin password access
    role: common
    rules:
      - host    all     +dbrole_admin               10.0.0.0/8          md5
      - host    all     +dbrole_admin               172.16.0.0/12       md5
      - host    all     +dbrole_admin               192.168.0.0/16      md5

  - title: allow intranet password access
    role: common
    rules:
      - host    all             all                 10.0.0.0/8          md5
      - host    all             all                 172.16.0.0/12       md5
      - host    all             all                 192.168.0.0/16      md5

  - title: allow local read-write access (local production user via pgbouncer)
    role: common
    rules:
      - local   all     +dbrole_readwrite                               md5
      - host    all     +dbrole_readwrite           127.0.0.1/32        md5

  - title: allow read-only user (stats, personal) password directly access
    role: replica
    rules:
      - local   all     +dbrole_readonly                               md5
      - host    all     +dbrole_readonly           127.0.0.1/32        md5
```

It is recommended to configure uniform `pg_hba_rules` globally and use `pg_hba_rules_extra` for additional customization for specific clusters.

### pg_hba_rules_extra

Similar to `pg_hba_rules`, but typically used for cluster-level HBA rule settings.

`pg_hba_rules_extra` will be **appended** to `pg_hba.conf` in the same way.

If the user needs to completely **override** the cluster's HBA rules, i.e. does not want to inherit the global HBA configuration, then `pg_hba_rules` should be configured at the cluster level and override the global configuration.

### pgbouncer_hba_rules

Similar to `pg_hba_rules` for Pgbouncer's HBA rule settings.

The default Pgbouncer HBA rules are simple and can be customized by the user according to their needs.

The default Pgbouncer HBA rules are more lenient.

1. allow login from **local** with password
2. allow password login from intranet network disconnect

```yaml
pgbouncer_hba_rules:
  - title: local password access
    role: common
    rules:
      - local  all          all                                     md5
      - host   all          all                     127.0.0.1/32    md5

  - title: intranet password access
    role: common
    rules:
      - host   all          all                     10.0.0.0/8      md5
      - host   all          all                     172.16.0.0/12   md5
      - host   all          all                     192.168.0.0/16  md5
```

### pgbouncer_hba_rules_extra

Similar to `pg_hba_rules_extras` for additional configuration of Pgbouncer's HBA rules at the cluster level.



### pg_users

Typically used to define business users at the database cluster level, using the same form as [`pg_default_roles`](#pg_default_roles).

An array of objects, each of which defines a business user. The username `name` field is mandatory, and the password can be an MD5 cipher password

Users can add default permission groups for business users via the `roles` field.

* `dbrole_readonly`: default production read-only user with global read-only permissions. (Read-only production access)
* `dbrole_offline`: default offline read-only user with read-only permissions on specific instances. (offline query, personal account, ETL)
* `dbrole_readwrite`: default production read-write user with global CRUD privileges. (Regular production use)
* `dbrole_admin`: default production admin user with permission to execute DDL changes. (Administrator)

`pgbouncer: true` should be configured for the production account to allow it to access through the connection pool; regular users should not access the database through the connection pool.

The following is an example of creating a business account.

```yaml
pg_users: # define business users/roles on this cluster, array of user definition
  # define admin user for meta database (This user are used for pigsty app deployment by default)
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
    roles: [ dbrole_admin ]           # optional, belonged roles. default roles are: dbrole_{admin,readonly,readwrite,offline}
    parameters: # optional, role level parameters with `ALTER ROLE SET`
      log_min_duration_statements: 1000
    search_path: public         # key value config parameters according to postgresql documentation (e.g: use pigsty as default search_path)
  - { name: dbuser_view , password: DBUser.Viewer  ,pgbouncer: true ,roles: [ dbrole_readonly ], comment: read-only viewer for meta database }

  # define additional business users for prometheus & grafana (optional)
  - { name: dbuser_grafana    , password: DBUser.Grafana    ,pgbouncer: true ,roles: [ dbrole_admin ], comment: admin user for grafana database }
  - { name: dbuser_prometheus , password: DBUser.Prometheus ,pgbouncer: true ,roles: [ dbrole_admin ], comment: admin user for prometheus database }
```

### pg_databases


An array of objects, each of which defines a **business database**. In each database definition, the database name `name` is mandatory, the rest are optional.

* `name`: database name, **mandatory**.
* `owner`: database owner, default is `postgres`.
* `template`: the template used when creating the database, default is `template1`.
* `encoding`: the default character encoding of the database, default is `UTF8`, default is consistent with the instance. It is recommended not to configure and modify it.
* `locale`: the default localization rule for the database, default is `C`, it is recommended not to configure it and keep it consistent with the instance.
* `lc_collate`: the default localization string sorting rule for the database, default is the same as the instance setting, it is recommended not to modify it, and must be consistent with the template database. It is strongly recommended not to configure it, or configure it as `C`.
* `lc_ctype`: the default LOCALE of the database, the default is the same as the instance setting, it is recommended not to modify or set it, and it must be consistent with the template database. It is recommended to configure to C or `en_US.UTF8`.
* `allowconn`: whether to allow connection to the database, default is `true`, not recommended to modify.
* `revokeconn`: whether to reclaim the permission to connect to the database? The default is `false`. If it is `true`, then the `PUBLIC CONNECT`
  permissions on the database will be reclaimed. Only the default user (`dbsu|monitor|admin|replicator|owner`) can connect. In addition, `admin|owner` will have GRANT OPTION, which gives other users permission to connect.
* `tablespace`: the tablespace associated with the database, the default is `pg_default`.
* `connlimit`: database connection limit, default is `-1`, i.e. no limit.
* `extensions`: array of objects , each of which defines an **extension** in the database, and its installed **schema**.
* `parameters`: KV objects, each KV defines a parameter that needs to be modified against the database via `ALTER DATABASE`.
* `pgbouncer`: Boolean option, whether to join this database to Pgbouncer. All databases will be added to Pgbouncer unless `pgbouncer: false` is explicitly specified.
* `comment`: database comment information.

```yaml
pg_databases: # define business databases on this cluster, array of database definition
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
    schemas: [ pigsty ]               # optional, additional schemas to be created, array of schema names
    extensions: # optional, additional extensions to be installed: array of schema definition `{name,schema}`
      - { name: adminpack, schema: pg_catalog }    # install adminpack to pg_catalog and install postgis to public
      - { name: postgis, schema: public }          # if schema is omitted, extension will be installed according to search_path.

```

