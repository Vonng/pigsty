# PGSQL Authentication and Privilege

Pigsty provides a battery-included access control model that is simple and practical to meet basic security needs.

PostgreSQL provides a standard access control mechanism: [Authentication](#Authentication) and [Privileges](#Privileges), both of which are based on the [Role](#Role) system.


---------------------



## Role

Pigsty's default role system contains four [default roles](#default roles) and four [default users](#default users)：

| name             | attr                                                         | roles                                                   | desc                                                    |
| ---------------- | ------------------------------------------------------------ | ------------------------------------------------------- | ------------------------------------------------------- |
| dbrole_readonly  | Cannot login                                                 |                                                         | role for global readonly access                         |
| dbrole_readwrite | Cannot login                                                 | dbrole_readonly                                         | role for global read-write access                       |
| dbrole_offline   | Cannot login                                                 |                                                         | role for restricted read-only access (offline instance) |
| dbrole_admin     | Cannot login<br /> Bypass RLS                                | pg_monitor<br />pg_signal_backend<br />dbrole_readwrite | role for object creation                                |
| postgres         | Superuser<br />Create role<br />Create DB<br />Replication<br />Bypass RLS |                                                         | system superuser                                        |
| replicator       | Replication<br />Bypass RLS                                  | pg_monitor<br />dbrole_readonly                         | system replicator                                       |
| dbuser_monitor   | 16 connections                                               | pg_monitor<br />dbrole_readonly                         | system monitor user                                     |
| dbuser_dba     | Bypass RLS<br />Superuser                                    | dbrole_admin                                            | system admin user                                       |


### Default Roles

Pigsty comes with four default roles：

* Read-only role (`dbrole_readonly`): Has read-only access to all data tables.
* Read-write role (`dbrole_readwrite`): has to write access to all data tables, inherits `dbrole_readonly`.
* Administrative role (`dbrole_admin`): can execute DDL changes, inherits `dbrole_readwrite`.
* Offline role (`dbrole_offline`): a special read-only role for executing slow queries/ETL/interactive queries, only allowed to access on specific instances.

Its definition is shown below:

```yaml
- { name: dbrole_readonly  , login: false , comment: role for global read-only access  }                            # production read-only role
- { name: dbrole_offline ,   login: false , comment: role for restricted read-only access (offline instance) }      # restricted-read-only role
- { name: dbrole_readwrite , login: false , roles: [dbrole_readonly], comment: role for global read-write access }  # production read-write role
- { name: dbrole_admin , login: false , roles: [pg_monitor, dbrole_readwrite] , comment: role for object creation } # production DDL change role
```

It is not recommended for normal users to change the default role name.


### Default Users

Pigsty comes with four default users.

* superuser (`postgres`), the owner and creator of the database, the same as the operating system user.
* Replication user (`replicator`), the system user used for master-slave replication.
* monitor user (`dbuser_monitor`), a user used to monitor database and connection pool metrics.
* Administrator (`dbuser_dba`), the administrator user who performs daily administrative operations and database changes.

The definitions are shown below:

```yaml
- { name: postgres , superuser: true , comment: system superuser }                             # system dbsu, name is designated by `pg_dbsu`
- { name: dbuser_dba , superuser: true , roles: [dbrole_admin] , comment: system admin user }  # admin dbsu, name is designated by `pg_admin_username`
- { name: replicator , replication: true , bypassrls: true , roles: [pg_monitor, dbrole_readonly] , comment: system replicator }                   # replicator
- { name: dbuser_monitor , roles: [pg_monitor, dbrole_readonly] , comment: system monitor user , parameters: {log_min_duration_statement: 1000 } } # monitor user
```

In Pigsty, the user names and passwords of the four default important users are controlled and managed by independent parameters:

```yaml
pg_dbsu: postgres                             # os user for the database

# - system roles - #
pg_replication_username: replicator           # system replication user
pg_replication_password: DBUser.Replicator    # system replication password
pg_monitor_username: dbuser_monitor           # system monitor user
pg_monitor_password: DBUser.Monitor           # system monitor password
pg_admin_username: dbuser_dba                 # system admin user
pg_admin_password: DBUser.DBA                 # system admin password
```

For security reasons, it is not recommended to set a password or allow remote access for the default superuser `postgres`, so there is no dedicated `dbsu_password` option.
If there is such a need, you can set a password for the dbsu in [`pg_default_roles`](v-pgsql.md#pg_default_roles).

**Be sure to change the passwords of all default users when using in a production env**.

In addition, users can define cluster-specific [business users](c-pgdbuser.md#users) in [`pg_users`](p-pgsql.md#pg_users) in the same way as [`pg_default_roles`](v-pgsql.md#pg_default_roles).


It is recommended to remove the `dborle_readony` role from `dbuser_monitor` if there is a higher data security requirement, some of the monitoring system features will not be available.








---------------------

## Authentication

Pigsty uses `md5` password auth by default and provides access control based on the PostgreSQL HBA mechanism.

> HBA stands for Host-Based Auth, which can be thought of as an IP black and white list.

### Config: HBA

In Pigsty, the HBA of all instances is generated from the config file, and the final generated HBA rules vary depending on the role of the instance (`pg_role`).
Pigsty's HBAs are controlled by the following variables.

* [`pg_hba_rules`](v-pgsql.md#pg_hba_rules): Environmentally uniform HBA rules
* [`pg_hba_rules_extra`](v-pgsql.md#pg_hba_rules_extra): instance- or cluster-specific HBA rules
* [`pgbouncer_hba_rules`](v-pgsql.md#pgbouncer_hba_rules): HBA rules used by linked pools
* [`pgbouncer_hba_rules_extra`](v-pgsql.md#pgbouncer_hba_rules_extra): HBA rules for the linked pool specific to the instance or cluster.

Each variable is an array of rules in the following style.

```yaml
- title: allow intranet admin password access
  role: common
  rules:
    - host    all     +dbrole_admin               10.0.0.0/8          md5
    - host    all     +dbrole_admin               172.16.0.0/12       md5
    - host    all     +dbrole_admin               192.168.0.0/16      md5
```

### Role-Based HBA

The HBA rule set with `role = common` is installed to all instances, while other fetch values, for example (`role: primary`) are only installed to instances with `pg_role = primary`. Thus users can define flexible HBA rules through the role system.

As a **special case**, the HBA rule for the `role: offline` will be installed to instances with `pg_role == 'offline'` as well as to instances with `pg_offline_query == true`.

The rendering priority rules for HBA are:

* `hard_coded_rules` global hard-coded rules
* `pg_hba_rules_extra.common` Cluster common rules
* `pg_hba_rules_extra.pg_role` Cluster role rules
* `pg_hba_rules.pg_role` global role rules
* `pg_hba_rules.offline` Cluster offline rules
* `pg_hba_rules_extra.offline` Global offline rules
* `pg_hba_rules.common` Global common rules


### Default HBA Rules

Under the default config, the master and slave libraries will use the following HBA rules:

* Superuser access with local OS auth
* Other users can access it with a password from local
* Replicated users can access from the LAN segment with a password
* Monitoring users can access locally
* Everyone can access it with a password on the meta-node
* Administrators can access via password from the LAN
* Everyone can access from the intranet with a password
* Read and write users (production business accounts) can be accessed locally (link pool)
  (some access control is transferred to the link pool for processing)
* On the slave: read-only users (individuals) can access from the local (link pool).
  (implies that read-only user connections are denied on the master)
* On instances with `pg_role == 'offline'` or with `pg_offline_query == true`, HBA rules that allow access to `dbrole_offline` grouped users are added.

<details><summary>Default HBA rule details</summary>


```ini
#==============================================================#
# Default HBA
#==============================================================#
# allow local su with ident"
local   all             postgres                               ident
local   replication     postgres                               ident

# allow local user password access
local   all             all                                    md5

# allow local/intranet replication with password
local   replication     replicator                              md5
host    replication     replicator         127.0.0.1/32         md5
host    all             replicator         10.0.0.0/8           md5
host    all             replicator         172.16.0.0/12        md5
host    all             replicator         192.168.0.0/16       md5
host    replication     replicator         10.0.0.0/8           md5
host    replication     replicator         172.16.0.0/12        md5
host    replication     replicator         192.168.0.0/16       md5

# allow local role monitor with password
local   all             dbuser_monitor                          md5
host    all             dbuser_monitor      127.0.0.1/32        md5

#==============================================================#
# Extra HBA
#==============================================================#
# add extra hba rules here

#==============================================================#
# primary HBA
#==============================================================#

#==============================================================#
# special HBA for instance marked with 'pg_offline_query = true'
#==============================================================#

#==============================================================#
# Common HBA
#==============================================================#
#  allow meta node password access
host    all     all                         10.10.10.10/32      md5

#  allow intranet admin password access
host    all     +dbrole_admin               10.0.0.0/8          md5
host    all     +dbrole_admin               172.16.0.0/12       md5
host    all     +dbrole_admin               192.168.0.0/16      md5

#  allow intranet password access
host    all             all                 10.0.0.0/8          md5
host    all             all                 172.16.0.0/12       md5
host    all             all                 192.168.0.0/16      md5

#  allow local read/write (local production user via pgbouncer)
local   all     +dbrole_readonly                                md5
host    all     +dbrole_readonly           127.0.0.1/32         md5

#==============================================================#
# Ad Hoc HBA
#===========================================================
```





### Change HBA

HBA rules are automatically generated when the cluster/instance is initialized.

Users can modify and apply the new HBA rules through a playbook after the database cluster/instance is created and running.

```bash
./pgsql.yml -t pg_hba    # Specify the target cluster with -l
bin/reloadhba <cluster>  # Reload the HBA rules for the target cluster
```
When the cluster dir is destroyed and rebuilt, the new copy will have the same HBA rules as the cluster master (because the slave's dataset cluster dir is a binary copy of the master, and the HBA rules are also in the dataset cluster dir).
This is not usually the behavior expected by users. You can use the above command to perform HBA repair for a specific instance.




### Pgbouncer HBA

In Pigsty, Pgbouncer also uses HBA for access control, the usage is basically the same as Postgres HBA:

* [`pgbouncer_hba_rules`](v-pgsql.md#pgbouncer_hba_rules): HBA rules used by the link pool
* [`pgbouncer_hba_rules_extra`](v-pgsql.md#pgbouncer_hba_rules_extra): instance or cluster-specific HBA rules for the linked pool

The default Pgbouncer HBA rules allow password access from local and intranet.

```bash
pgbouncer_hba_rules:                          # pgbouncer host-based authentication rules
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






---------------------

## Privilege

Pigsty's default privilege model is closely related to the [default role](#default role). When using the Pigsty access control, all newly created business users should belong to one of the four default roles, which have the permissions shown below:


* All users have access to all schemas
* Read-only users can read all tables
* Read-write users can perform DML operations (INSERT, UPDATE, DELETE) on all tables
* Administrators can perform DDL change operations (CREATE, USAGE, TRUNCATE, REFERENCES, TRIGGER)
* Offline users are similar to read-only users, but are only allowed to access instances of `pg_role == 'offline'` or `pg_offline_query = true`

```sql
GRANT USAGE                         ON SCHEMAS   TO dbrole_readonly;
GRANT SELECT                        ON TABLES    TO dbrole_readonly;
GRANT SELECT                        ON SEQUENCES TO dbrole_readonly;
GRANT EXECUTE                       ON FUNCTIONS TO dbrole_readonly;
GRANT USAGE                         ON SCHEMAS   TO dbrole_offline;
GRANT SELECT                        ON TABLES    TO dbrole_offline;
GRANT SELECT                        ON SEQUENCES TO dbrole_offline;
GRANT EXECUTE                       ON FUNCTIONS TO dbrole_readonly;
GRANT INSERT, UPDATE, DELETE        ON TABLES    TO dbrole_readwrite;
GRANT USAGE,  UPDATE                ON SEQUENCES TO dbrole_readwrite;
GRANT TRUNCATE, REFERENCES, TRIGGER ON TABLES    TO dbrole_admin;
GRANT CREATE                        ON SCHEMAS   TO dbrole_admin;
GRANT USAGE                         ON TYPES     TO dbrole_admin;
```

| Owner    | Schema | Type     | Access privileges             |
| -------- | ------ | -------- | ----------------------------- |
| username |        | schema   | postgres=UC/postgres          |
|          |        |          | dbrole_readonly=U/postgres    |
|          |        |          | dbrole_offline=U/postgres     |
|          |        |          | dbrole_admin=C/postgres       |
| username |        | sequence | postgres=rwU/postgres         |
|          |        |          | dbrole_readonly=r/postgres    |
|          |        |          | dbrole_readwrite=wU/postgres  |
|          |        |          | dbrole_offline=r/postgres     |
| username |        | table    | postgres=arwdDxt/postgres     |
|          |        |          | dbrole_readonly=r/postgres    |
|          |        |          | dbrole_readwrite=awd/postgres |
|          |        |          | dbrole_offline=r/postgres     |
|          |        |          | dbrole_admin=Dxt/postgres     |
| username |        | function | =X/postgres                   |
|          |        |          | postgres=X/postgres           |
|          |        |          | dbrole_readonly=X/postgres    |
|          |        |          | dbrole_offline=X/postgres     |


### Privilege Maintenance

Default access to database objects is ensured by PostgreSQL's `ALTER DEFAULT PRIVILEGES`.

All objects created by `{{ dbsu }}`, `{{ pg_admin_username }}`, `{{ dbrole_admin }}` will have the above default permissions.
Conversely, objects created by other roles will not be configured with the correct default access permissions.

Pigsty strongly discourages the use of **business users** to execute DDL changes, because PostgreSQL's `ALTER DEFAULT PRIVILEGE` only takes effect for `objects created by specific users'. dbuser_dba` has the default privilege config. If you want to grant business users the privilege to execute DDL, then in addition to giving the `dbrole_admin` role to business users, users should also keep in mind that when executing DDL changes, you should first execute:

```sql
SET ROLE dbrole_admin; -- dbrole_admin creates objects with the correct default permissions
```

The objects created in this way will only have default access rights.


### Database Privileges

The database has three privileges: `CONNECT`, `CREATE`, `TEMP`, and a special genus `OWNERSHIP`. The definition of the database is controlled by the parameter `pg_database`. A complete database definition is shown below:

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

By default, the `dbsu` will be the default `OWNER` of the database if the database is not configured with an owner, otherwise, it will be the specified user.

By default, all users have the `CONNECT` permission for newly created databases, which will be reclaimed by setting `revokeconn == true` if you wish to reclaim the permission. Only the default user (dbsu|admin|monitor|replicator) with the database's owner is explicitly given the `CONNECT` permission. Also, the `admin|owner` will have `GRANT OPTION` for the `CONNECT` permission and can delegate the `CONNECT` permission to others.

If you want to achieve **access isolation** between different databases, you can create a corresponding business user as the `owner` for each database and set the `revokeconn` option for all of them, this config is especially useful for multi-tenant instances.

<details>
<summary>A sample database for privilege isolation</summary>


```yaml
#--------------------------------------------------------------#
# pg-infra (example database for cluster loading)
#--------------------------------------------------------------#
pg-infra:
  hosts:
    10.10.10.40: { pg_seq: 1, pg_role: primary }
    10.10.10.41: { pg_seq: 2, pg_role: replica , pg_offline_query: true }
  vars:
    pg_cluster: pg-infrastructure
    pg_version: 14
    vip_address: 10.10.10.4
    pgbouncer_poolmode: session
    pg_hba_rules_extra:
      - title: allow confluence jira gitlab eazybi direct access
        role: common
        rules:
          - host    confluence dbuser_confluence   10.0.0.0/8        md5
          - host    jira       dbuser_jira         10.0.0.0/8        md5
          - host    gitlab     dbuser_gitlab       10.0.0.0/8        md5

    pg_users:
      # infra prod user
      - { name: dbuser_hybridcloud, password: ssag-2xd, pgbouncer: true, roles: [ dbrole_readwrite ] }
      - { name: dbuser_confluence, password: mc2iohos , pgbouncer: true, roles: [ dbrole_admin ] }
      - { name: dbuser_gitlab, password: sdf23g22sfdd , pgbouncer: true, roles: [ dbrole_readwrite ] }
      - { name: dbuser_jira, password: sdpijfsfdsfdfs , pgbouncer: true, roles: [ dbrole_admin ] }
    pg_databases:
      # infra database
      - { name: hybridcloud , revokeconn: true, owner: dbuser_hybridcloud , parameters: { search_path: yay,public } , connlimit: 100 }
      - { name: confluence , revokeconn: true, owner: dbuser_confluence , connlimit: 100 }
      - { name: gitlab , revokeconn: true, owner: dbuser_gitlab, connlimit: 100 }
      - { name: jira , revokeconn: true, owner: dbuser_jira , connlimit: 100 }

```





### CREATE Privilege

By default, Pigsty revokes the `PUBLIC` user's permission to `CREATE` a new schema under the database.
It also revokes the `PUBLIC` user's permission to create new relationships in the `PUBLIC` schema.
Database superusers and administrators are not subject to this restriction and can always perform DDL changes anywhere.

**Permissions to create objects in the database are independent of whether the user is the database owner or not, it only depends on whether the user was given administrator privileges when it was created**.

```yaml
pg_users:
  - {name: test1, password: xxx , groups: [dbrole_readwrite]}  # Cannot create Schema with objects
  - {name: test2, password: xxx , groups: [dbrole_admin]}      # Schema and objects can be created
```
