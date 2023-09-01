# PGSQL User

> In this context, the **User** refers to objects created by SQL `CREATE USER/ROLE`.



----------------

## Define User

There are two parameters related to users:

* [`pg_users`](PARAM#pg_users) : Define business users & roles at cluster level
* [`pg_default_roles`](PARAM#pg_default_roles) : Define system-wide roles & global users at global level

They are both arrays of user/role definition. You can define multiple users/roles in one cluster.

```yaml
pg-meta:
  hosts: { 10.10.10.10: { pg_seq: 1, pg_role: primary } }
  vars:
    pg_cluster: pg-meta
    pg_databases:
      - {name: dbuser_meta     ,password: DBUser.Meta     ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: pigsty admin user }
      - {name: dbuser_view     ,password: DBUser.Viewer   ,pgbouncer: true ,roles: [dbrole_readonly] ,comment: read-only viewer for meta database }
      - {name: dbuser_grafana  ,password: DBUser.Grafana  ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for grafana database    }
      - {name: dbuser_bytebase ,password: DBUser.Bytebase ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for bytebase database   }
      - {name: dbuser_kong     ,password: DBUser.Kong     ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for kong api gateway    }
      - {name: dbuser_gitea    ,password: DBUser.Gitea    ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for gitea service       }
      - {name: dbuser_wiki     ,password: DBUser.Wiki     ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for wiki.js service     }
      - {name: dbuser_noco     ,password: DBUser.Noco     ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for nocodb service      }
```

And each user definition may look like:

```yaml
- name: dbuser_meta               # REQUIRED, `name` is the only mandatory field of a user definition
  password: DBUser.Meta           # optional, password, can be a scram-sha-256 hash string or plain text
  login: true                     # optional, can log in, true by default  (new biz ROLE should be false)
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
  pool_mode: transaction          # optional, pgbouncer pool mode at user level, transaction by default
  pool_connlimit: -1              # optional, max database connections at user level, default -1 disable limit
  search_path: public             # key value config parameters according to postgresql documentation (e.g: use pigsty as default search_path)
```

* The only required field is `name`, which should be a valid & unique username in PostgreSQL.
* Roles don't need a `password`, while it could be necessary for a login-able user. 
* The `password` can be plain text or a scram-sha-256 / md5 hash string.
* User/Role are created one by one in array order. So make sure role/group definition is ahead of its members
* `login`, `superuser`, `createdb`, `createrole`, `inherit`, `replication`, `bypassrls` are boolean flags
* `pgbouncer` is disabled by default. To add a business user to the pgbouncer user-list, you should set it to `true` explicitly. 

**ACL System**

Pigsty has a battery-included [ACL](PGSQL-ACL) system, which can be easily used by assigning roles to users:

* `dbrole_readonly` : The role for global read-only access
* `dbrole_readwrite` : The role for global read-write access
* `dbrole_admin` : The role for object creation
* `dbrole_offline` : The role for restricted read-only access ([offline](PGSQL-CONF#offline) instance)

If you wish to re-design your ACL system, check the following parameters & templates.

* [`pg_default_roles`](PARAM#pg_default_roles) : System-wide roles & global users
* [`pg_default_privileges`](PARAM#pg_default_privileges) : Default privileges for newly created objects
* [`roles/pgsql/templates/pg-init-role.sql`](https://github.com/Vonng/pigsty/blob/master/roles/pgsql/templates/pg-init-role.sql): Role creation SQL template
* [`roles/pgsql/templates/pg-init-template.sql`](https://github.com/Vonng/pigsty/blob/master/roles/pgsql/templates/pg-init-template.sql): Privilege SQL template




----------------

## Create User

Users & Roles [defined](#define-user) in [`pg_default_roles`](PARAM#pg_default_roles) and [`pg_users`](PARAM#pg_users) will be automatically created one by one during cluster bootstrap.

If you wish to [create user](PGSQL-ADMIN#create-user) on an existing cluster, the `bin/pgsql-user` util can be used.

Add new user definition to `all.children.<cls>.pg_users`, and create that database with:

```bash
bin/pgsql-user <cls> <username>    # pgsql-user.yml -l <cls> -e username=<username>
```

The playbook is idempotent, so it's ok to run this multiple times on the existing cluster. 

If you are using the default pgbouncer as proxy middleware, YOU MUST create a new user with `pgsql-user` util, or `pgsql-user.yml` playbook,
Otherwise, the new user will not be added to the [pgbouncer userlist](#pgbouncer-user).





----------------

## Pgbouncer User

Pgbouncer is enabled by default and serves as a connection pool middleware, and its user is managed by default.

Pigsty will add all users in [`pg_users`](PARAM#pg_users) with `pgbouncer: true` flag to the pgbouncer userlist by default.

The user is listed in `/etc/pgbouncer/userlist.txt`:

```ini
"postgres" ""
"dbuser_wiki" "SCRAM-SHA-256$4096:+77dyhrPeFDT/TptHs7/7Q==$KeatuohpKIYzHPCt/tqBu85vI11o9mar/by0hHYM2W8=:X9gig4JtjoS8Y/o1vQsIX/gY1Fns8ynTXkbWOjUfbRQ="
"dbuser_view" "SCRAM-SHA-256$4096:DFoZHU/DXsHL8MJ8regdEw==$gx9sUGgpVpdSM4o6A2R9PKAUkAsRPLhLoBDLBUYtKS0=:MujSgKe6rxcIUMv4GnyXJmV0YNbf39uFRZv724+X1FE="
"dbuser_monitor" "SCRAM-SHA-256$4096:fwU97ZMO/KR0ScHO5+UuBg==$CrNsmGrx1DkIGrtrD1Wjexb/aygzqQdirTO1oBZROPY=:L8+dJ+fqlMQh7y4PmVR/gbAOvYWOr+KINjeMZ8LlFww="
"dbuser_meta" "SCRAM-SHA-256$4096:leB2RQPcw1OIiRnPnOMUEg==$eyC+NIMKeoTxshJu314+BmbMFpCcspzI3UFZ1RYfNyU=:fJgXcykVPvOfro2MWNkl5q38oz21nSl1dTtM65uYR1Q="
"dbuser_kong" "SCRAM-SHA-256$4096:bK8sLXIieMwFDz67/0dqXQ==$P/tCRgyKx9MC9LH3ErnKsnlOqgNd/nn2RyvThyiK6e4=:CDM8QZNHBdPf97ztusgnE7olaKDNHBN0WeAbP/nzu5A="
"dbuser_grafana" "SCRAM-SHA-256$4096:HjLdGaGmeIAGdWyn2gDt/Q==$jgoyOB8ugoce+Wqjr0EwFf8NaIEMtiTuQTg1iEJs9BM=:ed4HUFqLyB4YpRr+y25FBT7KnlFDnan6JPVT9imxzA4="
"dbuser_gitea" "SCRAM-SHA-256$4096:l1DBGCc4dtircZ8O8Fbzkw==$tpmGwgLuWPDog8IEKdsaDGtiPAxD16z09slvu+rHE74=:pYuFOSDuWSofpD9OZhG7oWvyAR0PQjJBffgHZLpLHds="
"dbuser_dba" "SCRAM-SHA-256$4096:zH8niABU7xmtblVUo2QFew==$Zj7/pq+ICZx7fDcXikiN7GLqkKFA+X5NsvAX6CMshF0=:pqevR2WpizjRecPIQjMZOm+Ap+x0kgPL2Iv5zHZs0+g="
"dbuser_bytebase" "SCRAM-SHA-256$4096:OMoTM9Zf8QcCCMD0svK5gg==$kMchqbf4iLK1U67pVOfGrERa/fY818AwqfBPhsTShNQ=:6HqWteN+AadrUnrgC0byr5A72noqnPugItQjOLFw0Wk="
```

And user level parameters are listed in `/etc/pgbouncer/useropts.txt`:

```ini
dbuser_dba                  = pool_mode=session max_user_connections=16
dbuser_monitor              = pool_mode=session max_user_connections=8
```

The userlist & useropts file will be updated automatically when you add a new user with `pgsql-user` util, or `pgsql-user.yml` playbook.

You can use [`pgbouncer_auth_query`](PARAM#pgbouncer_auth_query) to simplify pgbouncer user management (with the cost of reliability & security).



