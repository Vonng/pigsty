# Roles and Users

PostgreSQL provides a standard access control mechanism: [authentication](c-auth.md) and [privileges](c-privilege.md),
both based on the [role](c-user.md) systems. 
Pigsty provides a battery-included access control model that covers the security needs of most scenarios.

This article describes the default role system used by Pigsty.

Pigsty's default user system consists of 4 **default users** and 4 **default roles**.


## Default Roles

Pigsty comes with four default roles.

* Read-only role (`dbrole_readonly`): has read-only access to all data tables.
* Read-write role (`dbrole_readwrite`): has write access to all data tables, inherits from `dbrole_readonly`.
* Administrative role (`dbrole_admin`): can execute DDL changes, inherits `dbrole_readwrite`.
* Offline role (`dbrole_offline`): special read-only role for executing slow queries/ETL/interactive queries, only allowed to access on specific instances.

Its definition is shown below:

```yaml
- { name: dbrole_readonly  , login: false , comment: role for global read-only access  }                            # production read-only role
- { name: dbrole_offline ,   login: false , comment: role for restricted read-only access (offline instance) }      # restricted-read-only role
- { name: dbrole_readwrite , login: false , roles: [dbrole_readonly], comment: role for global read-write access }  # production read-write role
- { name: dbrole_admin , login: false , roles: [pg_monitor, dbrole_readwrite] , comment: role for object creation } # production DDL change role
```

!> It is not recommended for new users to change the name of the default role



## Default Users

Pigsty comes with 4 default users.

* Superuser (`postgres`), the owner and creator of the database, the same as the OS user
* Replication user (`replicator`), the system user used for master-slave replication
* monitor user (`dbuser_monitor`), a user used to monitor database and connection pool metrics
* Administrator (`dbuser_dba`), the administrator user who performs daily administrative operations and database changes

The definitions are shown below.


```yaml
- { name: postgres , superuser: true , comment: system superuser }                             # system dbsu, name is designated by `pg_dbsu`
- { name: dbuser_dba , superuser: true , roles: [dbrole_admin] , comment: system admin user }  # admin dbsu, name is designated by `pg_admin_username`
- { name: replicator , replication: true , bypassrls: true , roles: [pg_monitor, dbrole_readonly] , comment: system replicator }                   # replicator
- { name: dbuser_monitor , roles: [pg_monitor, dbrole_readonly] , comment: system monitor user , parameters: {log_min_duration_statement: 1000 } } # monitor user
- { name: dbuser_stats , password: DBUser.Stats , roles: [dbrole_offline] , comment: business offline user for offline queries and ETL }           # ETL user
```


## Role System

The following are the 8 default user/role definitions that come with Pigsty

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


<details>
<summary>Original Definition</summary>

```yaml
pg_dbsu: postgres                             # os user for database

# - system roles - #
pg_replication_username: replicator           # system replication user
pg_replication_password: DBUser.Replicator    # system replication password
pg_monitor_username: dbuser_monitor           # system monitor user
pg_monitor_password: DBUser.Monitor           # system monitor password
pg_admin_username: dbuser_dba                 # system admin user
pg_admin_password: DBUser.DBA                 # system admin password

# - default roles - #
pg_default_roles:                             # check https://pigsty.cc/#/zh-cn/c-user for more detail, sequence matters
  # default roles
  - { name: dbrole_readonly  , login: false , comment: role for global read-only access  }                            # production read-only role
  - { name: dbrole_readwrite , login: false , roles: [dbrole_readonly], comment: role for global read-write access }  # production read-write role
  - { name: dbrole_offline , login: false , comment: role for restricted read-only access (offline instance) }        # restricted-read-only role
  - { name: dbrole_admin , login: false , roles: [pg_monitor, dbrole_readwrite] , comment: role for object creation }  # production DDL change role

  # default users
  - { name: postgres , superuser: true , comment: system superuser }                             # system dbsu, name is designated by `pg_dbsu`
  - { name: dbuser_dba , superuser: true , roles: [dbrole_admin] , comment: system admin user }  # admin dbsu, name is designated by `pg_admin_username`
  - { name: replicator , replication: true , bypassrls: true , roles: [pg_monitor, dbrole_readonly] , comment: system replicator }                   # replicator
  - { name: dbuser_monitor , roles: [pg_monitor, dbrole_readonly] , comment: system monitor user , parameters: {log_min_duration_statement: 1000 } } # monitor user
  - { name: dbuser_stats , password: DBUser.Stats , roles: [dbrole_offline] , comment: business offline user for offline queries and ETL }           # ETL user
```

In addition, users can define cluster-specific business users in `pg_users`, in the same way as `pg_default_roles`.

</details>

!> You can avoid some potential security issue by revoke `dborle_readony` from `dbuser_monitor`.


## Password Management

When defining **user**, you can specify a password for the user via the `password` field. However, the three default user passwords are managed independently by dedicated parameters and will override the password definitions in `pg_default_roles`, which do not need to be set in them.

```bash
pg_dbsu: postgres                             # os user for database
pg_replication_username: replicator           # system replication user
pg_replication_password: DBUser.Replicator    # system replication password
pg_monitor_username: dbuser_monitor           # system monitor user
pg_monitor_password: DBUser.Monitor           # system monitor password
pg_admin_username: dbuser_dba                 # system admin user
pg_admin_password: DBUser.DBA                 # system admin password
```

For security reasons, it is not recommended setting a password or allow remote access for the default superuser `postgres`, so there is no dedicated `dbsu_password` option.
If such a need arises, set a password for the superuser in `pg_default_roles`.

!> Make sure to change the passwords for all default users when using pigsty in a production environment


## User Definition

Pigsty defines the roles and users in the database cluster with two configuration parameters.

* `pg_default_roles`
* `pg_users`

The former defines roles that are common to the entire environment, while the latter defines business roles and users that are specific to a single cluster. Both are identical in form and are arrays of user-defined objects.

The roles/users defined by `pg_default_roles` are created before `pg_users`, and the roles/users in the array are created in **definition order**, and the users defined later can belong to the roles defined earlier.

Here is an example:

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

* `name` : `name` must be specified for each user or role, the only mandatory parameter.
* `password` : is optional, if left blank then no password is set, can use MD5 cipher password.
* `login`, `superuser`, `createdb`, `createrole`, `inherit`, `replication`, `bypassrls` : are all boolean type tags used to set user attributes. If they are not set, the system defaults are used.
  The users of `pg_default_roles` do not have the `login` attribute by default, while `pg_users` have the `login` attribute by default, which can be overridden by explicit configuration.
* `expire_at` and `expire_in` are used to control when users expire. `expire_at` uses a date timestamp in the shape of `YYYY-mm-DD`. `expire_in` uses the number of days to expire from now, and overrides the `expire_at` option if `expire_in` exists.
* `pgbouncer: true` is used to control whether new users are added to the Pgbouncer user list. This parameter must be explicitly defined as `true` for the corresponding user to be added to the Pgbouncer user list.
* `roles` is the group to which the role/user belongs, multiple groups can be specified, e.g. add [**default role**](#default role) for the user.


## Create users

The roles and users defined by [`pg_default_roles`](v-pg-template.md#pg_default_roles) and [`pg_users`](v-pg-template.md#pg_users) are automatically created sequentially when the database cluster (or master instance) is created.

New business users can be created on a running existing database via built-in playbook [`pgsql-createuser.yml`](p-pgsql-createuser.md).

First, Add the definition of the user to the [`pg_users`](v-pg-template.md#pg_users) entry of the corresponding database cluster. 
Then, use the following command to create the user/role on that cluster:

```bash
# <pg_cluster> is the cluster name and <username> is the new username.
# Must be defined first, then executed in script to create
bin/createuser <pg_cluster> <username>
bin/createuser pg-meta dbuser_meta # Example: Create the dbuser_meta user in the pg-meta cluster

# This script actually calls the following Ansible script to complete the corresponding task
. /pgsql-createuser.yml -l <pg_cluster> -e pg_user=<user.name>
```

When the target user already exists, Pigsty modifies the properties of the target user to make it match the configuration.

If the user being created has the `pgbouncer: true` flag, the script will also modify and reload the configuration `/etc/pgbouncer/userlist.txt` for all Pgbouncers in the database cluster.

!> **Be sure to add new business users and business databases via pre-built scripts or scripts**, otherwise it is difficult to keep the connection pool configuration information synchronized with the database


## Pgbouncer

Pgbouncer's OS user will be consistent with the database superuser, both using `{{ pg_dbsu }}`, defaulting to `postgres`.
Pigsty defaults to using the Postgres admin user as the Pgbouncer admin user and the Postgres monitor user as the Pgbouncer monitor user as well.

The user list of Pgbouncer is controlled through the `/etc/pgbouncer/userlist.txt` file.
Pgbouncer's user permissions are controlled via `/etc/pgbouncer/pgb_hba.conf`.

Only users who explicitly add the `pgbouncer: true` configuration entry will be added to the Pgbouncer user list and access the database through Pgbouncer.
Normally accounts used by production applications should access the database through the Pgbouncer connection pool, while personal users, administration, ETL, etc. should access the database directly.

Under normal circumstances, use the `pgsql-createuser.yml` script to manage database users. In an emergency, you can also add users manually by executing the following command on the database instance as the ``postgres`` user, which needs to be executed on all Pgbouncers in the cluster and reload the configuration.

```bash
# This command can be used to manually add users in an emergency
# Usage: pgbouncer-create-user <username> [password]
/pg/bin/pgbouncer-create-user

pgbouncer-create-user dbp_vonng Test.Password                       # plaintext password         
pgbouncer-create-user dbp_vonng md596bceae83ba2937778af09adf00ae738 # md5 password
pgbouncer-create-user dbp_vonng auto                                # Get password from database query
pgbouncer-create-user dbp_vonng null                                # Use empty password
```

