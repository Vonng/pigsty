# Permissions

PostgreSQL provides a standard access control mechanism: [authentication](c-auth.md) (Authentication) and [privileges](c-privilege.md) (Privileges), both based on the [role](c-user.md) (Role) and [user](c-user. md) (User) systems. Pigsty provides an out-of-the-box access control model that covers the security needs of most scenarios.

This article describes the default permission system used by Pigsty.

Pigsty's default user system consists of **four default users** with **four types of default roles**.

## Object permissions

The permission model is closely related to the [default role](c-user.md).

When using the Pigsty access control model, newly created business users should all belong to one of the four default roles, and the permissions held by the default roles are shown below.

```sql
GRANT USAGE                         ON SCHEMAS   TO dbrole_readonly
GRANT SELECT                        ON TABLES    TO dbrole_readonly
GRANT SELECT                        ON SEQUENCES TO dbrole_readonly
GRANT EXECUTE                       ON FUNCTIONS TO dbrole_readonly
GRANT USAGE                         ON SCHEMAS   TO dbrole_offline
GRANT SELECT                        ON TABLES    TO dbrole_offline
GRANT SELECT                        ON SEQUENCES TO dbrole_offline
GRANT EXECUTE                       ON FUNCTIONS TO dbrole_readonly
GRANT INSERT, UPDATE, DELETE        ON TABLES    TO dbrole_readwrite
GRANT USAGE,  UPDATE                ON SEQUENCES TO dbrole_readwrite
GRANT TRUNCATE, REFERENCES, TRIGGER ON TABLES    TO dbrole_admin
GRANT CREATE                        ON SCHEMAS   TO dbrole_admin
GRANT USAGE                         ON TYPES     TO dbrole_admin
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


* All users have access to all schemas
* Read-only users can read all tables
* Read-write users can perform DML operations (INSERT, UPDATE, DELETE) on all tables
* Administrators can perform DDL change operations (CREATE, USAGE, TRUNCATE, REFERENCES, TRIGGER)
* Offline users are similar to read-only users, but are only allowed to access instances of `pg_role == 'offline'` or `pg_offline_query = true`


## Maintenance of object permissions

Default access to database objects is ensured by PostgreSQL's `ALTER DEFAULT PRIVILEGES`.

All objects created by `{{ dbsu }}`, `{{ pg_admin_username }}`, `{{ dbrole_admin }}` will have the above default permissions.
Conversely, objects created by other roles will not be configured with the correct default access permissions.

Pigsty strongly discourages the use of **business users** to perform DDL changes, because PostgreSQL's `ALTER DEFAULT PRIVILEGE` only works for `objects created by specific users', and by default superuser `postgres` and ` dbuser_dba` have the default privilege configuration, if you want to grant business users the privilege to execute DDL, then besides giving the `dbrole_admin` role to business users, users should also keep in mind that when executing DDL changes, you should first execute.

```sql
SET ROLE dbrole_admin; -- The object created by dbrole_admin has the correct default privileges
```

This way the created object will have the default access permissions


## Database permissions

Databases have three kinds of permissions: `CONNECT`, `CREATE`, `TEMP`, and the special attribute `OWNERSHIP`. The definition of a database is controlled by the parameter `pg_database`. A complete database definition is shown below.

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

By default, the database superuser `dbsu` will be the default `OWNER` of the database if the database is not configured with an owner, otherwise it will be the specified user.

By default, all users have the `CONNECT` permission for newly created databases, which will be reclaimed by setting `revokeconn == true` if you wish to reclaim the permission. Only the default user (dbsu|admin|monitor|replicator) with the database's owner is explicitly given the `CONNECT` permission. Also, `admin|owner` will have `GRANT OPTION` for the `CONNECT` permission and can delegate the `CONNECT` permission to others.

If you want to achieve **access isolation** between different databases, you can create a corresponding business user as `owner` for each database and set the `revokeconn` option for all of them, this configuration is especially useful for multi-tenant instances.

<details>
<summary>A sample database with privilege isolation</summary>

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
    pg_version: 13
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



## Permission on create objects

By default, Pigsty revokes the `PUBLIC` user's permission to `CREATE` a new schema under the database for security reasons.
It also revokes the `PUBLIC` user's permission to create new relationships in the `PUBLIC` schema.
Database super users and administrators are not subject to this restriction and can always perform DDL changes anywhere.

**Permissions to create objects in the database are independent of whether the user is the database owner or not, it only depends on whether the user was given administrator privileges when it was created**.

```yaml
pg_users:
  - {name: test1, password: xxx , groups: [dbrole_readwrite]}  # unable to execute DDL
  - {name: test2, password: xxx , groups: [dbrole_admin]}      # able to execute DDL
```
