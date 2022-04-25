# PGSQL Authentication and Privilege

PostgreSQL provides a standard access control mechanism: [Authentication](#Authentication) and [Privileges](#Privilege), both of which are based on the [Role](#Role) system.


---------------------



## Role

Pigsty's default role system contains four [default roles](#default-roles) and four [default users](#default-users)：

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

Pigsty has four default roles：

* Read-only role (`dbrole_readonly`): Has read-only access to all data tables.
* Read-write role (`dbrole_readwrite`): Has to write access to all data tables, inherits `dbrole_readonly`.
* Admin role (`dbrole_admin`): Can execute DDL changes, inherits `dbrole_readwrite`.
* Offline role (`dbrole_offline`): A special read-only role for executing slow queries/ETL/interactive queries, only allowed access to specific instances.

The definition is shown below.

```yaml
- { name: dbrole_readonly  , login: false , comment: role for global read-only access  }                            # production read-only role
- { name: dbrole_offline ,   login: false , comment: role for restricted read-only access (offline instance) }      # restricted-read-only role
- { name: dbrole_readwrite , login: false , roles: [dbrole_readonly], comment: role for global read-write access }  # production read-write role
- { name: dbrole_admin , login: false , roles: [pg_monitor, dbrole_readwrite] , comment: role for object creation } # production DDL change role
```

!> Common users should not change the name of the default role.


### Default Users

Pigsty has four default users.

* superuser (`postgres`), the owner and creator of the database, the same as the OS user.
* Replication user (`replicator`), the system user used for primary-replica.
* Monitor user (`dbuser_monitor`), a user used to monitor database and connection pool metrics.
* Admin user (`dbuser_dba`), the admin user who performs daily operations and database changes.

The definitions are shown below:

```yaml
- { name: postgres , superuser: true , comment: system superuser }                             # system dbsu, name is designated by `pg_dbsu`
- { name: dbuser_dba , superuser: true , roles: [dbrole_admin] , comment: system admin user }  # admin dbsu, name is designated by `pg_admin_username`
- { name: replicator , replication: true , bypassrls: true , roles: [pg_monitor, dbrole_readonly] , comment: system replicator }                   # replicator
- { name: dbuser_monitor , roles: [pg_monitor, dbrole_readonly] , comment: system monitor user , parameters: {log_min_duration_statement: 1000 } } # monitor user
```

In Pigsty, four important default usernames and passwords are controlled and managed by separate parameters.

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

It is not recommended to set a password or allow remote access for the default superuser `postgres`, so there is no dedicated `dbsu_password` option.
If there is such a need, you can set a password for the dbsu in [`pg_default_roles`](v-pgsql.md#pg_default_roles).

!> **Be sure to change the passwords of all default users**.

In addition, users can define cluster-specific [business users](c-pgdbuser.md#users) in [`pg_users`](p-pgsql.md#pg_users) in the same way as [`pg_default_roles`](v-pgsql.md#pg_default_roles).


!> It is recommended to remove the `dborle_readony` role from `dbuser_monitor` if there is a higher data security requirement. Some of the monitoring system features will not be available.








---------------------

## Authentication

Pigsty uses `md5` password authentication by default and provides access control based on the PostgreSQL HBA mechanism.

> HBA(Host Based Authentication)can be treated as an IP blocklist and allowlist.

### Config: HBA

In Pigsty, the HBA of all instances is generated from the config file, and HBA rules vary depending on the instance's role (`pg_role`).
The following variables control pigsty's HBAs.

* [`pg_hba_rules`](v-pgsql.md#pg_hba_rules): Environmentally uniform HBA rules
* [`pg_hba_rules_extra`](v-pgsql.md#pg_hba_rules_extra): HBA rules for a specific instance or cluster
* [`pgbouncer_hba_rules`](v-pgsql.md#pgbouncer_hba_rules): HBA rules used for connection pooling
* [`pgbouncer_hba_rules_extra`](v-pgsql.md#pgbouncer_hba_rules_extra): HBA rules for a specific instance or cluster connection pooling 

Each variable is an array consisting of the following rules.

```yaml
- title: allow intranet admin password access
  role: common
  rules:
    - host    all     +dbrole_admin               10.0.0.0/8          md5
    - host    all     +dbrole_admin               172.16.0.0/12       md5
    - host    all     +dbrole_admin               192.168.0.0/16      md5
```

### Role-Based HBA

The HBA rule set with `role = common` is installed to all instances,(`role: primary`) are only installed to instances with `pg_role = primary`. 

As a **special case**, the HBA rule for the `role: offline` will be installed to instances with `pg_role == 'offline'` as well as to instances with `pg_offline_query == true`.

The rendering priority rules for HBA are:

* `hard_coded_rules` Global hard-coded rules
* `pg_hba_rules_extra.common` Cluster common rules
* `pg_hba_rules_extra.pg_role` Cluster role rules
* `pg_hba_rules.pg_role` Global role rules
* `pg_hba_rules.offline` Cluster offline rules
* `pg_hba_rules_extra.offline` Global offline rules
* `pg_hba_rules.common` Global common rules


### Default HBA Rules

Under the default config, the primary and replica will use the following HBA rules:

* Superuser access with local OS auth.
* Other users can access it with a password from local.
* Replica users can access via password from the LAN segment.
* Monitor users can access it locally.
* Everyone can access it with a password on the meta node.
* Admin users can access via password from the LAN.
* Everyone can access the intranet with a password.
* Read and write users (production business users) can be accessed locally (Connection Pool).
* On the replica: read-only users (individuals) can access from the local (Connection Pool).
* On instances with `pg_role == 'offline'` or with `pg_offline_query == true`, HBA rules that allow access to `dbrole_offline` grouped users are added.

<details><summary>Default HBA rule information</summary>

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

</details>



### Change HBA Rules

Users can modify and apply the new HBA rules through a playbook after the cluster/instance is created and running.

```bash
./pgsql.yml -t pg_hba    # Specify the target cluster with -l
bin/reloadhba <cluster>  # Reload the HBA rules
```
When the database cluster directory is destroyed and rebuilt, the new copy will have the same HBA rules as the cluster primary. You can use the above command to perform HBA repair for a specific instance.




### Pgbouncer HBA

In Pigsty, Pgbouncer also uses HBA for access control. The usage is the same as Postgres HBA:

* [`pgbouncer_hba_rules`](v-pgsql.md#pgbouncer_hba_rules): HBA rules used by the connection pool
* [`pgbouncer_hba_rules_extra`](v-pgsql.md#pgbouncer_hba_rules_extra): Instance- or cluster-specific connection pooling HBA rules

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

Pigsty's default privilege model is related to the [default role](#default-roles). When using the Pigsty access control, all newly created business users should belong to one of the four default roles, which have the privileges shown below:


* All users have access to all schemas.
* Read-only users can read all tables.
* Read-write users can perform DML operations (INSERT, UPDATE, DELETE).
* Admin users can perform DDL change operations (CREATE, USAGE, TRUNCATE, REFERENCES, TRIGGER).
* Offline and read-only users are only allowed to access instances of `pg_role == 'offline'` or `pg_offline_query = true`.

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

PostgreSQL's `ALTER DEFAULT PRIVILEGES` ensures default access to database objects.

All objects created by `{{ dbsu }}`, `{{ pg_admin_username }}`, `{{ dbrole_admin }}` will have the default privileges.

PostgreSQL's `ALTER DEFAULT PRIVILEGE` only takes effect for "objects created by specific users" objects created by superuser `postgres,` and `dbuser_dba` have default privileges. Suppose you want to give business users privileges to execute DDL besides giving the dbrole_admin role to business users. You should also remember that you should first run the following command when executing DDL changes.

```sql
SET ROLE dbrole_admin; -- dbrole_admin creates objects with the correct default permissions
```




### Database Privileges

The database has three privileges: `CONNECT`, `CREATE`, `TEMP`, and a special genus `OWNERSHIP`. The parameter `pg_database` controls the definition of the database. A complete database definition is shown below:

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

If the database is not configured with an owner, `dbsu` will be the default `OWNER` of the database. Otherwise, it will be the specified user.

All users have the `CONNECT` privilege to the newly created database; set `revokeconn == true` if you wish to reclaim this privilege. Only the default user (dbsu|admin|monitor|replicator) with the database's owner is explicitly given the `CONNECT` privilege. Also, `admin|owner` will have `GRANT OPTION` for the `CONNECT` privilege and can transfer the `CONNECT` privilege to others.

If you implement **access isolation** between different databases, you can create a business user as the `owner` for each database and set the `revokeconn` option for all of them.

<details><summary>A sample database for privilege isolation</summary>

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

</details>



### Create Privilege

Pigsty revokes the `PUBLIC` user's privilege to `CREATE` a new schema under the database for security reasons.
It also revokes the `PUBLIC` user's privilege to create new relationships in the `PUBLIC` schema.
The database superuser and admin user are not subject to this restriction.

**Privileges to create objects in the database are independent of whether the user is the database owner or not. It only depends on whether the user was given admin privileges when it was created**.

```yaml
pg_users:
  - {name: test1, password: xxx , groups: [dbrole_readwrite]}  # Schema with objects cannot be created 
  - {name: test2, password: xxx , groups: [dbrole_admin]}      # Schema and objects can be created
```
