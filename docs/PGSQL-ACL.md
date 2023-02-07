# PGSQL Access Control

> Pigsty has a battery-included access control model based on [Role System](#role-system) and [Privileges](#privileges).



---------------------

## Role System

Pigsty has a default role system consist of four [default roles](#default-roles) and four [default users](#default-users)：

| Role name          | Attributes    | Member of                   | Description                          |
|--------------------|---------------|-----------------------------|--------------------------------------|
| `dbrole_readonly`  | `NOLOGIN`     |                             | role for global read-only access     |
| `dbrole_readwrite` | `NOLOGIN`     | dbrole_readonly             | role for global read-write access    |
| `dbrole_admin`     | `NOLOGIN`     | pg_monitor,dbrole_readwrite | role for object creation             |
| `dbrole_offline`   | `NOLOGIN`     |                             | role for restricted read-only access |
| `postgres`         | `SUPERUSER`   |                             | system superuser                     |
| `replicator`       | `REPLICATION` | pg_monitor,dbrole_readonly  | system replicator                    |
| `dbuser_dba`       | `SUPERUSER`   | dbrole_admin                | pgsql admin user                     |
| `dbuser_monitor`   |               | pg_monitor,dbrole_readonly  | pgsql monitor user                   |

```yaml
pg_default_roles:                 # default roles and users in postgres cluster
  - { name: dbrole_readonly  ,login: false ,comment: role for global read-only access     }
  - { name: dbrole_offline   ,login: false ,comment: role for restricted read-only access }
  - { name: dbrole_readwrite ,login: false ,roles: [dbrole_readonly]               ,comment: role for global read-write access }
  - { name: dbrole_admin     ,login: false ,roles: [pg_monitor, dbrole_readwrite]  ,comment: role for object creation }
  - { name: postgres     ,superuser: true                                          ,comment: system superuser }
  - { name: replicator ,replication: true  ,roles: [pg_monitor, dbrole_readonly]   ,comment: system replicator }
  - { name: dbuser_dba   ,superuser: true  ,roles: [dbrole_admin]  ,pgbouncer: true ,pool_mode: session, pool_connlimit: 16 , comment: pgsql admin user }
  - { name: dbuser_monitor   ,roles: [pg_monitor, dbrole_readonly] ,pgbouncer: true ,parameters: {log_min_duration_statement: 1000 } ,pool_mode: session ,pool_connlimit: 8 ,comment: pgsql monitor user }
```


---------------------

## Default Roles

There are four default roles in pigsty:

* Read Only (`dbrole_readonly`): Role for global read-only access
* Read Write (`dbrole_readwrite`): Role for global read-write access, inherits `dbrole_readonly`.
* Admin (`dbrole_admin`): Role for DDL commands, inherits `dbrole_readwrite`.
* Offline (`dbrole_offline`): Role for restricted read-only access ([offline](PGSQL-CONF#offline) instance)

Default roles are defined in [`pg_default_roles`](PARAM#pg_default_roles), change default roles is not recommended.

```yaml
- { name: dbrole_readonly  , login: false , comment: role for global read-only access  }                            # production read-only role
- { name: dbrole_offline ,   login: false , comment: role for restricted read-only access (offline instance) }      # restricted-read-only role
- { name: dbrole_readwrite , login: false , roles: [dbrole_readonly], comment: role for global read-write access }  # production read-write role
- { name: dbrole_admin , login: false , roles: [pg_monitor, dbrole_readwrite] , comment: role for object creation } # production DDL change role
```


---------------------

## Default Users

There are four default users in pigsty, too.

* Superuser (`postgres`), the owner and creator of the cluster, same as the OS dbsu.
* Replication user (`replicator`), the system user used for primary-replica.
* Monitor user (`dbuser_monitor`), a user used to monitor database and connection pool metrics.
* Admin user (`dbuser_dba`), the admin user who performs daily operations and database changes.

Default users' username/password are defined with dedicate parameters (except for dbsu password): 

- [`pg_dbsu`](PARAM#pg_dbsu)                                 : os dbsu name, postgres by default, better not change it
- [`pg_replication_username`](PARAM#pg_replication_username) : postgres replication username, `replicator` by default
- [`pg_replication_password`](PARAM#pg_replication_password) : postgres replication password, `DBUser.Replicator` by default
- [`pg_admin_username`](PARAM#pg_admin_username)             : postgres admin username, `dbuser_dba` by default
- [`pg_admin_password`](PARAM#pg_admin_password)             : postgres admin password in plain text, `DBUser.DBA` by default
- [`pg_monitor_username`](PARAM#pg_monitor_username)         : postgres monitor username, `dbuser_monitor` by default
- [`pg_monitor_password`](PARAM#pg_monitor_password)         : postgres monitor password, `DBUser.Monitor` by default

!> **Remember to change these password in production deployment !** 

```yaml
pg_dbsu: postgres                             # os user for the database
pg_replication_username: replicator           # system replication user
pg_replication_password: DBUser.Replicator    # system replication password
pg_monitor_username: dbuser_monitor           # system monitor user
pg_monitor_password: DBUser.Monitor           # system monitor password
pg_admin_username: dbuser_dba                 # system admin user
pg_admin_password: DBUser.DBA                 # system admin password
```

To define extra options, specify them in [`pg_default_roles`](PARAM#pg_default_roles):

```yaml
- { name: postgres     ,superuser: true                                          ,comment: system superuser }
- { name: replicator ,replication: true  ,roles: [pg_monitor, dbrole_readonly]   ,comment: system replicator }
- { name: dbuser_dba   ,superuser: true  ,roles: [dbrole_admin]  ,pgbouncer: true ,pool_mode: session, pool_connlimit: 16 , comment: pgsql admin user }
- { name: dbuser_monitor   ,roles: [pg_monitor, dbrole_readonly] ,pgbouncer: true ,parameters: {log_min_duration_statement: 1000 } ,pool_mode: session ,pool_connlimit: 8 ,comment: pgsql monitor user }
```





---------------------

## Privileges

Pigsty has a battery-included privilege model that works with [default roles](#default-roles).

* All users have access to all schemas.
* Read-Only user can read from all tables. (SELECT, EXECUTE)
* Read-Write user can write to all tables run DML. (INSERT, UPDATE, DELETE).
* Admin user can create object and run DDL (CREATE, USAGE, TRUNCATE, REFERENCES, TRIGGER). 
* Offline user is Read-Only user with limited access on offline instance (`pg_role = 'offline'` or `pg_offline_query = true`)
* Object created by admin users will have correct privilege.
* Default privileges are installed on all databases, including template database. 
* Database connect privilege is covered by database [definition](PGSQL-DB#define-database) 
* `CREATE` privileges of database & public schema are revoked from `PUBLIC` by default 



---------------------

## Object Privilege

Default object privileges are defined in [`pg_default_privileges`](PARAM#pg_default_privileges).

```yaml
- GRANT USAGE      ON SCHEMAS   TO dbrole_readonly
- GRANT SELECT     ON TABLES    TO dbrole_readonly
- GRANT SELECT     ON SEQUENCES TO dbrole_readonly
- GRANT EXECUTE    ON FUNCTIONS TO dbrole_readonly
- GRANT USAGE      ON SCHEMAS   TO dbrole_offline
- GRANT SELECT     ON TABLES    TO dbrole_offline
- GRANT SELECT     ON SEQUENCES TO dbrole_offline
- GRANT EXECUTE    ON FUNCTIONS TO dbrole_offline
- GRANT INSERT     ON TABLES    TO dbrole_readwrite
- GRANT UPDATE     ON TABLES    TO dbrole_readwrite
- GRANT DELETE     ON TABLES    TO dbrole_readwrite
- GRANT USAGE      ON SEQUENCES TO dbrole_readwrite
- GRANT UPDATE     ON SEQUENCES TO dbrole_readwrite
- GRANT TRUNCATE   ON TABLES    TO dbrole_admin
- GRANT REFERENCES ON TABLES    TO dbrole_admin
- GRANT TRIGGER    ON TABLES    TO dbrole_admin
- GRANT CREATE     ON SCHEMAS   TO dbrole_admin
```

Which will be rendered in [`pg-init-template.sql`](https://github.com/Vonng/pigsty/blob/master/roles/pgsql/templates/pg-init-template.sql) alone with `ALTER DEFAULT PRIVILEGES` statement for admin users.
The `\ddp+` may looks like:

| Type     | Access privileges    |
|----------|----------------------|
| function | =X                   |
|          | dbrole_readonly=X    |
|          | dbrole_offline=X     |
|          | dbrole_admin=X       |
| schema   | dbrole_readonly=U    |
|          | dbrole_offline=U     |
|          | dbrole_admin=UC      |
| sequence | dbrole_readonly=r    |
|          | dbrole_offline=r     |
|          | dbrole_readwrite=wU  |
|          | dbrole_admin=rwU     |
| table    | dbrole_readonly=r    |
|          | dbrole_offline=r     |
|          | dbrole_readwrite=awd |
|          | dbrole_admin=arwdDxt |

Newly created objects will have corresponding privileges when it is **created by admin users** 



---------------------

## Default Privilege

[`ALTER DEFAULT PRIVILEGES`](https://www.postgresql.org/docs/current/sql-alterdefaultprivileges.html) allows you to set the privileges that will be applied to objects created in the future. 
It does not affect privileges assigned to already-existing objects, and objects created by non-admin users.

That is to say, to maintain the correct object privilege, you have to run DDL with **admin users**, which could be: 

1. [`{{ pg_dbsu }}`](PARAM#pg_dbsu), `postgres` by default
2. [`{{ pg_admin_username }}`](PARAM#pg_admin_username), `dbuser_dba` by default
3. Business admin user granted with `dbrole_admin`

It's wise to use `postgres` as global object owner. If you wish to create objects with business admin user, YOU MUST USE `SET ROLE dbrole_admin` before running that DDL to maintain the correct privileges. 



---------------------

## Database Privilege

Database privilege is covered by [database definition](PGSQL-DB#define-database).

There are 3 database level privileges: `CONNECT`, `CREATE`, `TEMP`, and a special 'privilege': `OWNERSHIP`. 

```yaml
- name: meta         # required, `name` is the only mandatory field of a database definition
  owner: postgres    # optional, specify a database owner, {{ pg_dbsu }} by default
  allowconn: true    # optional, allow connection, true by default. false will disable connect at all
  revokeconn: false  # optional, revoke public connection privilege. false by default. (leave connect with grant option to owner)
```

* If `owner` exists, it will be used as database owner instead of default [`{{ pg_dbsu }}`](PARAM#pg_dbsu)
* If `revokeconn` is `false`, all users have the `CONNECT` privilege of the database, this is the default behavior.
* If `revokeconn` is set to `true` explicitly:
  * `CONNECT` privilege of the database will be revoked from `PUBLIC`
  * `CONNECT` privilege will be granted to `{{ pg_replication_username }}`, `{{ pg_monitor_username }}` and `{{ pg_admin_username }}` 
  * `CONNECT` privilege will be granted to database owner with `GRANT OPTION`

`revokeconn` flag can be used for database access isolation, you can create different business users as the owners for each database and set the `revokeconn` option for all of them. 


<details><summary>Example: Database Isolation</summary>

```yaml
pg-infra:
  hosts:
    10.10.10.40: { pg_seq: 1, pg_role: primary }
    10.10.10.41: { pg_seq: 2, pg_role: replica , pg_offline_query: true }
  vars:
    pg_cluster: pg-infra
    pg_users:
      - { name: dbuser_confluence, password: mc2iohos , pgbouncer: true, roles: [ dbrole_admin ] }
      - { name: dbuser_gitlab, password: sdf23g22sfdd , pgbouncer: true, roles: [ dbrole_readwrite ] }
      - { name: dbuser_jira, password: sdpijfsfdsfdfs , pgbouncer: true, roles: [ dbrole_admin ] }
    pg_databases:
      - { name: confluence , revokeconn: true, owner: dbuser_confluence , connlimit: 100 }
      - { name: gitlab , revokeconn: true, owner: dbuser_gitlab, connlimit: 100 }
      - { name: jira , revokeconn: true, owner: dbuser_jira , connlimit: 100 }

```

</details>




---------------------

## Create Privilege

Pigsty revokes the `CREATE` privilege on database from `PUBLIC` by default, for security consideration.

Pigsty revokes the `CREATE` privilege on `public` schema from `PUBLIC` by default. Which is the default behavior since PostgreSQL 15.

The database owner have the full capability to adjust these privileges as they see fit. 



