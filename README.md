# Pigsty

> "**P**ostgreSQL **I**n **G**reat **STY**le": **P**ostgres, **I**nfras, **G**raphics, **S**ervice, **T**oolbox, it's all **Y**ours.
>
> —— Battery-Included, Local-First **PostgreSQL** Distribution as an Open-Source **RDS** Alternative!
>
> [Website](https://pigsty.io/) | [Docs](https://pigsty.io/docs/) | [Feature](https://pigsty.io/docs/about/feature) | [Demo](https://demo.pigsty.cc) | [Blog](https://pigsty.io/blog) | [Discuss](https://github.com/Vonng/pigsty/discussions) | [Discord](https://discord.gg/j5pG8qfKxU) | [Roadmap](https://github.com/users/Vonng/projects/2/views/3) | [中文站](https://pigsty.cc/zh/) | [专业版](https://pigsty.cc/zh/docs/price/) | [博客](https://pigsty.cc/zh/blog)
>
> [Get Started](https://pigsty.io/docs/setup/install/) with the latest [v3.0.0](https://github.com/Vonng/pigsty/releases/tag/v3.0.0) release: `curl -fsSL https://repo.pigsty.io/get | bash`


----------------

## Features

> Pigsty is your postgres, infra, grafana service toolbox, check [**Feature**](https://pigsty.io/docs/about/feature/) | [**特性**](https://pigsty.io/zh/docs/about/feature/) and [**Demo**](https://demo.pigsty.cc) for details.

[![pigsty-desc](https://pigsty.io/img/pigsty/desc.png)](https://pigsty.io/)

There are **333** unique [**extensions**](https://pigsty.io/docs/pgext/list) available for PostgreSQL in Pigsty v3, including **326** [**RPM**](https://pigsty.io/docs/pgext/list/rpm/) available in EL and **312** [**DEB**](https://pigsty.io/docs/pgext/list/deb/) available in Debian/Ubuntu.


----------------

## Get Started

> Setup everything with one command! Check [**Get Started**](https://pigsty.io/docs/setup/install/) | [**快速上手**](https://pigsty.io/zh/docs/setup/install/) for details.

[**Prepare**](https://pigsty.io/docs/setup/prepare/) a fresh Linux x86_64 node that runs [**compatible**](https://pigsty.io/docs/reference/compatibility/) OS distro.

Then run this [**`install`**](https://github.com/pgsty/pkg/blob/main/get.io) script as the admin user with nopass `ssh` & `sudo` privilege:

```bash
curl -fsSL https://repo.pigsty.io/get | bash
cd ~/pigsty; ./bootstrap; ./configure; ./install.yml;
```

Then you will have a pigsty singleton node ready, with Web Services on port `80/443` and Postgres on port `5432`.

<details><summary>Install Script Output</summary><br>
 
```
$ curl -fsSL https://repo.pigsty.io/get | bash
[v3.0.0] ===========================================
$ curl -fsSL https://repo.pigsty.io/get | bash
[Site] https://pigsty.io
[Demo] https://demo.pigsty.cc
[Repo] https://github.com/Vonng/pigsty
[Docs] https://pigsty.io/docs/setup/install
[Download] ===========================================
[ OK ] version = v3.0.0 (from default)
curl -fSL https://repo.pigsty.io/src/pigsty-v3.0.0.tgz -o /tmp/pigsty-v3.0.0.tgz
######################################################################## 100.0%
[ OK ] md5sums = 6cefb4113a3ac8eb50f408f976771eb5  /tmp/pigsty-v3.0.0.tgz
[Install] ===========================================
[WARN] os user = root , it's recommended to install as a sudo-able admin
[ OK ] install = /root/pigsty, from /tmp/pigsty-v3.0.0.tgz
[TodoList] ===========================================
cd /root/pigsty
./bootstrap      # [OPTIONAL] install ansible & use offline package
./configure      # [OPTIONAL] preflight-check and config generation
./install.yml    # install pigsty modules according to your config.
[Complete] ===========================================
```

> HINT: To install a specific version, passing the version string as the first parameter:
>
> ```bash
> curl -fsSL https://repo.pigsty.io/get | bash -s v3.0.0
> ```

</details>


<details><summary>Download with Git</summary>

You can also download pigsty source with `git`, don't forget to check out a specific version tag, the `main` branch is for development.

```bash
git clone https://github.com/Vonng/pigsty; cd pigsty; git checkout v3.0.0
```

</details>


----------------

**Example: Singleton Installation on RockyLinux 9.3:** 

[![asciicast](https://asciinema.org/a/673459.svg)](https://asciinema.org/a/673459)



----------------

## Architecture

Pigsty uses a **modular** design. There are 4 core [**modules**](https://pigsty.io/docs/about/module/) available:

* [**`INFRA`**](https://pigsty.io/docs/infra/): Local yum|apt repo, Nginx, DNS, and entire Prometheus & Grafana observability stack.
* [**`NODE`**](https://pigsty.io/docs/node/):   Init node name, repo, pkg, NTP, ssh, admin, tune, expose services, collect logs & metrics.
* [**`ETCD`**](https://pigsty.io/docs/etcd/):   Init etcd cluster for HA Postgres DCS or Kubernetes, used as distributed config store.
* [**`PGSQL`**](https://pigsty.io/docs/pgsql/): Autonomous self-healing PostgreSQL cluster powered by Patroni, Pgbouncer, PgBackrest & HAProxy

You can compose them freely in a declarative manner. If you want host monitoring, `INFRA` & `NODE` will suffice.
`ETCD` and `PGSQL` are used for HA PG clusters, install them on multiple nodes will automatically form a HA cluster.

The default [`install.yml`](https://github.com/Vonng/pigsty/blob/main/install.yml) playbook in [Get Started](#get-started) will install `INFRA`, `NODE`, `ETCD` & `PGSQL` on the current node. 
which gives you a battery-included PostgreSQL singleton instance (`admin_ip:5432`) with everything ready.
This node can be used as an admin center & infra provider to manage, deploy & monitor more nodes & clusters.

[![pigsty-arch.jpg](https://pigsty.io/img/pigsty/arch.jpg)](https://pigsty.io/docs/concept/arch/)



----------------

## More Clusters

To deploy a 3-node HA Postgres Cluster, [**define**](https://github.com/Vonng/pigsty/blob/main/pigsty.yml#L53) a new cluster on `all.children.pg-test` of [`pigsty.yml`](https://github.com/Vonng/pigsty/blob/main/pigsty.yml):

```yaml 
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
    10.10.10.13: { pg_seq: 3, pg_role: offline }
  vars:  { pg_cluster: pg-test }
```

Then create it with built-in playbooks:

```bash
bin/pgsql-add pg-test   # init pg-test cluster 
```

[![](https://pigsty.io/img/pigsty/ha.png)](https://pigsty.io/docs/concept/ha/)


--------

You can deploy different kinds of instance roles such as primary, replica, offline, delayed, sync standby, and different kinds of clusters, such as standby clusters, Citus clusters, and even Redis / MinIO / Etcd clusters.

And here some self-explanatory config examples:


<details><summary>Example: 4-node Sandbox</summary><br>

The [`full.yml`](https://github.com/Vonng/pigsty/blob/main/conf/sandbox/full.yml) utilize 4 nodes to deploy two PostgreSQL clusters `pg-meta` and `pg-test`:

```yaml
pg-meta:
  hosts: { 10.10.10.10: { pg_seq: 1, pg_role: primary } }
  vars:
    pg_cluster: pg-meta
    pg_users:
      - {name: dbuser_meta     ,password: DBUser.Meta     ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: pigsty admin user }
      - {name: dbuser_view     ,password: DBUser.Viewer   ,pgbouncer: true ,roles: [dbrole_readonly] ,comment: read-only viewer for meta database }
    pg_databases:
      - {name: meta ,baseline: cmdb.sql ,comment: pigsty meta database ,schemas: [pigsty]}
    pg_hba_rules:
      - {user: dbuser_view , db: all ,addr: infra ,auth: pwd ,title: 'allow grafana dashboard access cmdb from infra nodes'}
    pg_vip_enabled: true
    pg_vip_address: 10.10.10.2/24
    pg_vip_interface: eth1

# pgsql 3 node ha cluster: pg-test
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }   # primary instance, leader of cluster
    10.10.10.12: { pg_seq: 2, pg_role: replica }   # replica instance, follower of leader
    10.10.10.13: { pg_seq: 3, pg_role: replica, pg_offline_query: true } # replica with offline access
  vars:
    pg_cluster: pg-test           # define pgsql cluster name
    pg_users:  [{ name: test , password: test , pgbouncer: true , roles: [ dbrole_admin ] }]
    pg_databases: [{ name: test }]
    pg_vip_enabled: true
    pg_vip_address: 10.10.10.3/24
    pg_vip_interface: eth1
```

</details>



<details><summary>Example: Complex Postgres Customize</summary><br>

This config file provides a detailed example of a complex PostgreSQL cluster `pg-meta` with multiple databases, users, and services definition:

```yaml
pg-meta:
  hosts: { 10.10.10.10: { pg_seq: 1, pg_role: primary , pg_offline_query: true } }
  vars:
    pg_cluster: pg-meta
    pg_databases:                       # define business databases on this cluster, array of database definition
      - name: meta                      # REQUIRED, `name` is the only mandatory field of a database definition
        baseline: cmdb.sql              # optional, database sql baseline path, (relative path among ansible search path, e.g files/)
        pgbouncer: true                 # optional, add this database to pgbouncer database list? true by default
        schemas: [pigsty]               # optional, additional schemas to be created, array of schema names
        extensions:                     # optional, additional extensions to be installed: array of `{name[,schema]}`
          - { name: postgis , schema: public }
          - { name: timescaledb }
        comment: pigsty meta database   # optional, comment string for this database
        owner: postgres                # optional, database owner, postgres by default
        template: template1            # optional, which template to use, template1 by default
        encoding: UTF8                 # optional, database encoding, UTF8 by default. (MUST same as template database)
        locale: C                      # optional, database locale, C by default.  (MUST same as template database)
        lc_collate: C                  # optional, database collate, C by default. (MUST same as template database)
        lc_ctype: C                    # optional, database ctype, C by default.   (MUST same as template database)
        tablespace: pg_default         # optional, default tablespace, 'pg_default' by default.
        allowconn: true                # optional, allow connection, true by default. false will disable connect at all
        revokeconn: false              # optional, revoke public connection privilege. false by default. (leave connect with grant option to owner)
        register_datasource: true      # optional, register this database to grafana datasources? true by default
        connlimit: -1                  # optional, database connection limit, default -1 disable limit
        pool_auth_user: dbuser_meta    # optional, all connection to this pgbouncer database will be authenticated by this user
        pool_mode: transaction         # optional, pgbouncer pool mode at database level, default transaction
        pool_size: 64                  # optional, pgbouncer pool size at database level, default 64
        pool_size_reserve: 32          # optional, pgbouncer pool size reserve at database level, default 32
        pool_size_min: 0               # optional, pgbouncer pool size min at database level, default 0
        pool_max_db_conn: 100          # optional, max database connections at database level, default 100
      - { name: grafana  ,owner: dbuser_grafana  ,revokeconn: true ,comment: grafana primary database }
      - { name: bytebase ,owner: dbuser_bytebase ,revokeconn: true ,comment: bytebase primary database }
      - { name: kong     ,owner: dbuser_kong     ,revokeconn: true ,comment: kong the api gateway database }
      - { name: gitea    ,owner: dbuser_gitea    ,revokeconn: true ,comment: gitea meta database }
      - { name: wiki     ,owner: dbuser_wiki     ,revokeconn: true ,comment: wiki meta database }
    pg_users:                           # define business users/roles on this cluster, array of user definition
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
      - {name: dbuser_view     ,password: DBUser.Viewer   ,pgbouncer: true ,roles: [dbrole_readonly], comment: read-only viewer for meta database}
      - {name: dbuser_grafana  ,password: DBUser.Grafana  ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for grafana database   }
      - {name: dbuser_bytebase ,password: DBUser.Bytebase ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for bytebase database  }
      - {name: dbuser_kong     ,password: DBUser.Kong     ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for kong api gateway   }
      - {name: dbuser_gitea    ,password: DBUser.Gitea    ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for gitea service      }
      - {name: dbuser_wiki     ,password: DBUser.Wiki     ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for wiki.js service    }
    pg_services:                        # extra services in addition to pg_default_services, array of service definition
      # standby service will route {ip|name}:5435 to sync replica's pgbouncer (5435->6432 standby)
      - name: standby                   # required, service name, the actual svc name will be prefixed with `pg_cluster`, e.g: pg-meta-standby
        port: 5435                      # required, service exposed port (work as kubernetes service node port mode)
        ip: "*"                         # optional, service bind ip address, `*` for all ip by default
        selector: "[]"                  # required, service member selector, use JMESPath to filter inventory
        dest: default                   # optional, destination port, default|postgres|pgbouncer|<port_number>, 'default' by default
        check: /sync                    # optional, health check url path, / by default
        backup: "[? pg_role == `primary`]"  # backup server selector
        maxconn: 3000                   # optional, max allowed front-end connection
        balance: roundrobin             # optional, haproxy load balance algorithm (roundrobin by default, other: leastconn)
        options: 'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'
    pg_hba_rules:
      - {user: dbuser_view , db: all ,addr: infra ,auth: pwd ,title: 'allow grafana dashboard access cmdb from infra nodes'}
    pg_vip_enabled: true
    pg_vip_address: 10.10.10.2/24
    pg_vip_interface: eth1
    node_crontab:  # make a full backup 1 am everyday
      - '00 01 * * * postgres /pg/bin/pg-backup full'

```

</details>



<details><summary>Example: Security Enhancement & Delayed Replica</summary><br>

The following [`conf/demo/security.yml`](https://github.com/Vonng/pigsty/blob/main/conf/demo/security.yml) provision a 3-node [security](https://pigsty.io/docs/setup/security/) enhanced postgres cluster `pg-meta` with a delayed replica `pg-meta-delay`:

```yaml
pg-meta:      # 3 instance postgres cluster `pg-meta`
  hosts:
    10.10.10.10: { pg_seq: 1, pg_role: primary }
    10.10.10.11: { pg_seq: 2, pg_role: replica }
    10.10.10.12: { pg_seq: 3, pg_role: replica , pg_offline_query: true }
  vars:
    pg_cluster: pg-meta
    pg_conf: crit.yml
    pg_users:
      - { name: dbuser_meta , password: DBUser.Meta   , pgbouncer: true , roles: [ dbrole_admin ] , comment: pigsty admin user }
      - { name: dbuser_view , password: DBUser.Viewer , pgbouncer: true , roles: [ dbrole_readonly ] , comment: read-only viewer for meta database }
    pg_databases:
      - {name: meta ,baseline: cmdb.sql ,comment: pigsty meta database ,schemas: [pigsty] ,extensions: [{name: postgis, schema: public}, {name: timescaledb}]}
    pg_default_service_dest: postgres
    pg_services:
      - { name: standby ,src_ip: "*" ,port: 5435 , dest: default ,selector: "[]" , backup: "[? pg_role == `primary`]" }
    pg_vip_enabled: true
    pg_vip_address: 10.10.10.2/24
    pg_vip_interface: eth1
    pg_listen: '${ip},${vip},${lo}'
    patroni_ssl_enabled: true
    pgbouncer_sslmode: require
    pgbackrest_method: minio
    pg_libs: 'timescaledb, $libdir/passwordcheck, pg_stat_statements, auto_explain' # add passwordcheck extension to enforce strong password
    pg_default_roles:                 # default roles and users in postgres cluster
      - { name: dbrole_readonly  ,login: false ,comment: role for global read-only access     }
      - { name: dbrole_offline   ,login: false ,comment: role for restricted read-only access }
      - { name: dbrole_readwrite ,login: false ,roles: [dbrole_readonly]               ,comment: role for global read-write access }
      - { name: dbrole_admin     ,login: false ,roles: [pg_monitor, dbrole_readwrite]  ,comment: role for object creation }
      - { name: postgres     ,superuser: true  ,expire_in: 7300                        ,comment: system superuser }
      - { name: replicator ,replication: true  ,expire_in: 7300 ,roles: [pg_monitor, dbrole_readonly]   ,comment: system replicator }
      - { name: dbuser_dba   ,superuser: true  ,expire_in: 7300 ,roles: [dbrole_admin]  ,pgbouncer: true ,pool_mode: session, pool_connlimit: 16 , comment: pgsql admin user }
      - { name: dbuser_monitor ,roles: [pg_monitor] ,expire_in: 7300 ,pgbouncer: true ,parameters: {log_min_duration_statement: 1000 } ,pool_mode: session ,pool_connlimit: 8 ,comment: pgsql monitor user }
    pg_default_hba_rules:             # postgres host-based auth rules by default
      - {user: '${dbsu}'    ,db: all         ,addr: local     ,auth: ident ,title: 'dbsu access via local os user ident'  }
      - {user: '${dbsu}'    ,db: replication ,addr: local     ,auth: ident ,title: 'dbsu replication from local os ident' }
      - {user: '${repl}'    ,db: replication ,addr: localhost ,auth: ssl   ,title: 'replicator replication from localhost'}
      - {user: '${repl}'    ,db: replication ,addr: intra     ,auth: ssl   ,title: 'replicator replication from intranet' }
      - {user: '${repl}'    ,db: postgres    ,addr: intra     ,auth: ssl   ,title: 'replicator postgres db from intranet' }
      - {user: '${monitor}' ,db: all         ,addr: localhost ,auth: pwd   ,title: 'monitor from localhost with password' }
      - {user: '${monitor}' ,db: all         ,addr: infra     ,auth: ssl   ,title: 'monitor from infra host with password'}
      - {user: '${admin}'   ,db: all         ,addr: infra     ,auth: ssl   ,title: 'admin @ infra nodes with pwd & ssl'   }
      - {user: '${admin}'   ,db: all         ,addr: world     ,auth: cert  ,title: 'admin @ everywhere with ssl & cert'   }
      - {user: '+dbrole_readonly',db: all    ,addr: localhost ,auth: ssl   ,title: 'pgbouncer read/write via local socket'}
      - {user: '+dbrole_readonly',db: all    ,addr: intra     ,auth: ssl   ,title: 'read/write biz user via password'     }
      - {user: '+dbrole_offline' ,db: all    ,addr: intra     ,auth: ssl   ,title: 'allow etl offline tasks from intranet'}
    pgb_default_hba_rules:            # pgbouncer host-based authentication rules
      - {user: '${dbsu}'    ,db: pgbouncer   ,addr: local     ,auth: peer  ,title: 'dbsu local admin access with os ident'}
      - {user: 'all'        ,db: all         ,addr: localhost ,auth: pwd   ,title: 'allow all user local access with pwd' }
      - {user: '${monitor}' ,db: pgbouncer   ,addr: intra     ,auth: ssl   ,title: 'monitor access via intranet with pwd' }
      - {user: '${monitor}' ,db: all         ,addr: world     ,auth: deny  ,title: 'reject all other monitor access addr' }
      - {user: '${admin}'   ,db: all         ,addr: intra     ,auth: ssl   ,title: 'admin access via intranet with pwd'   }
      - {user: '${admin}'   ,db: all         ,addr: world     ,auth: deny  ,title: 'reject all other admin access addr'   }
      - {user: 'all'        ,db: all         ,addr: intra     ,auth: ssl   ,title: 'allow all user intra access with pwd' }

# OPTIONAL delayed cluster for pg-meta
pg-meta-delay:                    # delayed instance for pg-meta (1 hour ago)
  hosts: { 10.10.10.13: { pg_seq: 1, pg_role: primary, pg_upstream: 10.10.10.10, pg_delay: 1h } }
  vars: { pg_cluster: pg-meta-delay }
```

</details>





<details><summary>Example: Self-hosting Supabase </summary><br>

The [`conf/dbms/supabase.yml`](https://github.com/Vonng/pigsty/blob/main/conf/dbms/supabase.yml) provision a PostgreSQL cluster for self-hosting [supabase](https://pigsty.io/docs/software/supabase/) as below:

```yaml
pg-meta:
  hosts: { 10.10.10.10: { pg_seq: 1, pg_role: primary } }
  vars:
    pg_cluster: pg-meta
    pg_users:
      # supabase roles: anon, authenticated, dashboard_user
      - { name: anon           ,login: false }
      - { name: authenticated  ,login: false }
      - { name: dashboard_user ,login: false ,replication: true ,createdb: true ,createrole: true }
      - { name: service_role   ,login: false ,bypassrls: true }
      # supabase users: please use the same password
      - { name: supabase_admin             ,password: 'DBUser.Supa' ,pgbouncer: true ,inherit: true   ,superuser: true ,replication: true ,createdb: true ,createrole: true ,bypassrls: true }
      - { name: authenticator              ,password: 'DBUser.Supa' ,pgbouncer: true ,inherit: false  ,roles: [ authenticated ,anon ,service_role ] }
      - { name: supabase_auth_admin        ,password: 'DBUser.Supa' ,pgbouncer: true ,inherit: false  ,createrole: true }
      - { name: supabase_storage_admin     ,password: 'DBUser.Supa' ,pgbouncer: true ,inherit: false  ,createrole: true ,roles: [ authenticated ,anon ,service_role ] }
      - { name: supabase_functions_admin   ,password: 'DBUser.Supa' ,pgbouncer: true ,inherit: false  ,createrole: true }
      - { name: supabase_replication_admin ,password: 'DBUser.Supa' ,replication: true }
      - { name: supabase_read_only_user    ,password: 'DBUser.Supa' ,bypassrls: true ,roles: [ pg_read_all_data ] }

    pg_databases:
      - { name: meta ,baseline: cmdb.sql ,comment: pigsty meta database ,schemas: [ pigsty ]} # the optional pigsty cmdb

      # the supabase database (pg_cron should be installed in this database after bootstrap)
      - name: supa
        baseline: supa.sql    # the init-scripts: https://github.com/supabase/postgres/tree/develop/migrations/db/init-scripts
        owner: supabase_admin
        comment: supabase postgres database
        schemas: [ extensions ,auth ,realtime ,storage ,graphql_public ,supabase_functions ,_analytics ,_realtime ]
        extensions:
          - { name: pgcrypto  ,schema: extensions  } # 1.3   : cryptographic functions
          - { name: pg_net    ,schema: extensions  } # 0.9.2 : async HTTP
          - { name: pgjwt     ,schema: extensions  } # 0.2.0 : json web token API for postgres
          - { name: uuid-ossp ,schema: extensions  } # 1.1   : generate universally unique identifiers (UUIDs)
          - { name: pgsodium        }                # 3.1.9 : pgsodium is a modern cryptography library for Postgres.
          - { name: supabase_vault  }                # 0.2.8 : Supabase Vault Extension
          - { name: pg_graphql      }                # 1.5.7 : pg_graphql: GraphQL support
          - { name: pg_jsonschema   }                # 0.3.1 : pg_jsonschema: Validate json schema
          - { name: wrappers        }                # 0.4.1 : wrappers: FDW collections
          - { name: http            }                # 1.6   : http: allows web page retrieval inside the database.
          - { name: pg_cron         }
    # supabase required extensions
    pg_libs: 'pg_net, pg_cron, pg_stat_statements, auto_explain'    # add pg_net to shared_preload_libraries
    pg_extensions:
      - wal2json pg_repack
      - supa-stack # pgvector pg_cron pgsodium pg_graphql pg_jsonschema wrappers pgjwt pgsql_http pg_net supautils
    pg_parameters:
      cron.database_name: supa
      pgsodium.enable_event_trigger: off
    pg_hba_rules: # supabase hba rules, require access from docker network
      - { user: all ,db: supa ,addr: intra       ,auth: pwd ,title: 'allow supa database access from intranet'      }
      - { user: all ,db: supa ,addr: 172.0.0.0/8 ,auth: pwd ,title: 'allow supa database access from docker network'}
      - { user: all ,db: supa ,addr: all         ,auth: pwd ,title: 'allow supa database access from entire world'  }  # not safe!
```

</details>





<details><summary>Example: Citus Distributed Cluster: 5 Nodes</summary><br>

The [`conf/dbms/citus.yml`](https://github.com/Vonng/pigsty/blob/main/conf/dbms/citus.yml) provision a 5 node [citus](https://pigsty.io/docs/kernel/citus/) cluster as below:

```yaml
all:
  children:
    pg-citus0: # citus coordinator, pg_group = 0
      hosts: { 10.10.10.10: { pg_seq: 1, pg_role: primary } }
      vars: { pg_cluster: pg-citus0 , pg_group: 0 }
    pg-citus1: # citus data node 1
      hosts: { 10.10.10.11: { pg_seq: 1, pg_role: primary } }
      vars: { pg_cluster: pg-citus1 , pg_group: 1 }
    pg-citus2: # citus data node 2
      hosts: { 10.10.10.12: { pg_seq: 1, pg_role: primary } }
      vars: { pg_cluster: pg-citus2 , pg_group: 2 }
    pg-citus3: # citus data node 3, with an extra replica
      hosts:
        10.10.10.13: { pg_seq: 1, pg_role: primary }
        10.10.10.14: { pg_seq: 2, pg_role: replica }
      vars: { pg_cluster: pg-citus3 , pg_group: 3 }

  vars:                               # global parameters for all citus clusters
    pg_mode: citus                    # pgsql cluster mode: citus
    pg_shard: pg-citus                # citus shard name: pg-citus
    pg_primary_db: meta               # primary database used by citus
    pg_dbsu_password: DBUser.Postgres # all dbsu password access for citus cluster
    pg_libs: 'citus, timescaledb, pg_stat_statements, auto_explain' # citus will be added by patroni automatically
    pg_extensions:
      - postgis timescaledb pgvector_${ pg_version }* citus_${ pg_version }*
    pg_users: [ { name: dbuser_meta ,password: DBUser.Meta ,pgbouncer: true ,roles: [ dbrole_admin ] } ]
    pg_databases: [ { name: meta ,extensions: [ { name: citus }, { name: postgis }, { name: timescaledb } ] } ]
    pg_hba_rules:
      - { user: 'all' ,db: all  ,addr: 127.0.0.1/32 ,auth: ssl ,title: 'all user ssl access from localhost' }
      - { user: 'all' ,db: all  ,addr: intra        ,auth: ssl ,title: 'all user ssl access from intranet'  }
```

</details>




<details><summary>Example: Babelfish Cluster (MSSQL Compatible)</summary><br>

The [`conf/dbms/mssql.yml`](https://github.com/Vonng/pigsty/blob/main/conf/dbms/mssql.yml) Provision a Microsoft SQL Server compatible [`kernel`](https://pigsty.io/docs/kernel/babelfish/) WiltonDB & BabelfishPG extension:

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
    10.10.10.13: { pg_seq: 3, pg_role: replica, pg_offline_query: true }
  vars:
    pg_cluster: pg-test
    pg_users:                           # create MSSQL superuser
      - {name: dbuser_mssql ,password: DBUser.MSSQL ,superuser: true, pgbouncer: true ,roles: [dbrole_admin], comment: superuser & owner for babelfish  }
    pg_primary_db: mssql                # use `mssql` as the primary sql server database
    pg_databases:
      - name: mssql
        baseline: mssql.sql             # init babelfish database & user
        extensions:
          - { name: uuid-ossp          }
          - { name: babelfishpg_common }
          - { name: babelfishpg_tsql   }
          - { name: babelfishpg_tds    }
          - { name: babelfishpg_money  }
          - { name: pg_hint_plan       }
          - { name: system_stats       }
          - { name: tds_fdw            }
        owner: dbuser_mssql
        parameters: { 'babelfishpg_tsql.migration_mode' : 'single-db' }
        comment: babelfish cluster, a MSSQL compatible pg cluster

    node_repo_modules: local,node,pgsql,mssql  # add local & mssql modules to node repo (Internet Required)
    pg_version: 15                     # The current WiltonDB major version is 15
    pg_packages:                       # install forked version of postgresql with babelfishpg support
      - wiltondb patroni pgbouncer pgbackrest pg_exporter pgbadger vip-manager
    pg_extensions: [ ]                 # do not install any vanilla postgresql extensions
    pg_mode: mssql                     # Microsoft SQL Server Compatible Mode
    pg_libs: 'babelfishpg_tds, pg_stat_statements, auto_explain' # add timescaledb to shared_preload_libraries
    pg_default_services: # route primary & replica service to mssql port 1433
      - { name: primary ,port: 5433 ,dest: 1433  ,check: /primary   ,selector: "[]" }
      - { name: replica ,port: 5434 ,dest: 1433  ,check: /read-only ,selector: "[]" , backup: "[? pg_role == `primary` || pg_role == `offline` ]" }
      - { name: default ,port: 5436 ,dest: postgres ,check: /primary   ,selector: "[]" }
      - { name: offline ,port: 5438 ,dest: postgres ,check: /replica   ,selector: "[? pg_role == `offline` || pg_offline_query ]" , backup: "[? pg_role == `replica` && !pg_offline_query]" }
```

</details>




<details><summary>Example: IvorySQL Cluster (Oracle Compatible)</summary><br>

The [`conf/dbms/ivory.yml`](https://github.com/Vonng/pigsty/blob/main/conf/dbms/mssql.yml) provides an Oracle compatible PostgreSQL [kernel](https://pigsty.io/docs/kernel/ivorysql/) (EL-only)

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
    10.10.10.13: { pg_seq: 3, pg_role: replica, pg_offline_query: true }
  vars:
    pg_cluster: pg-test           # define pgsql cluster name
    pg_users:  [{ name: test , password: test , pgbouncer: true , roles: [ dbrole_admin ] }]
    pg_databases: [{ name: test }]
    pg_vip_enabled: true
    pg_vip_address: 10.10.10.3/24
    pg_vip_interface: eth1
    # IvorySQL specific settings
    node_repo_modules: local,node,pgsql,ivory  # add ivorysql upstream repo
    pg_mode: ivory                    # IvorySQL Oracle Compatible Mode
    pg_packages: [ 'ivorysql patroni pgbouncer pgbackrest pg_exporter pgbadger vip-manager' ]
    pg_libs: 'liboracle_parser, pg_stat_statements, auto_explain'
    pg_extensions: [ ]                # do not install any vanilla postgresql extensions
```

</details>



<details><summary>Example: Redis Standalone / Sentinel / Cluster</summary><br>

The [`redis.yml`](https://github.com/Vonng/pigsty/blob/main/conf/dbms/redis.yml) provision 3 [Redis](https://pigsty.io/docs/redis/) clusters in standalone, sentinel, and native cluster mode as below:

```yaml
redis-ms: # redis classic primary & replica
  hosts: { 10.10.10.10: { redis_node: 1 , redis_instances: { 6379: { }, 6380: { replica_of: '10.10.10.10 6379' } } } }
  vars: { redis_cluster: redis-ms ,redis_password: 'redis.ms' ,redis_max_memory: 64MB }

redis-meta: # redis sentinel x 3
  hosts: { 10.10.10.11: { redis_node: 1 , redis_instances: { 26379: { } ,26380: { } ,26381: { } } } }
  vars:
    redis_cluster: redis-meta
    redis_password: 'redis.meta'
    redis_mode: sentinel
    redis_max_memory: 16MB
    redis_sentinel_monitor: # primary list for redis sentinel, use cls as name, primary ip:port
      - { name: redis-ms, host: 10.10.10.10, port: 6379 ,password: redis.ms, quorum: 2 }

redis-test: # redis native cluster: 3m x 3s
  hosts:
    10.10.10.12: { redis_node: 1 ,redis_instances: { 6379: { } ,6380: { } ,6381: { } } }
    10.10.10.13: { redis_node: 2 ,redis_instances: { 6379: { } ,6380: { } ,6381: { } } }
  vars: { redis_cluster: redis-test ,redis_password: 'redis.test' ,redis_mode: cluster, redis_max_memory: 32MB }
```

</details>

<details><summary>Example: 3-Node ETCD Cluster</summary><br>

The following snippet provisions a 3-node [etcd](https://pigsty.io/docs/etcd/) cluster for HA Postgres DCS:

```yaml
etcd: # dcs service for postgres/patroni ha consensus
  hosts:  # 1 node for testing, 3 or 5 for production
    10.10.10.10: { etcd_seq: 1 }  # etcd_seq required
    10.10.10.11: { etcd_seq: 2 }  # assign from 1 ~ n
    10.10.10.12: { etcd_seq: 3 }  # odd number please
  vars: # cluster level parameter override roles/etcd
    etcd_cluster: etcd  # mark etcd cluster name etcd
    etcd_safeguard: false # safeguard against purging
    etcd_clean: true # purge etcd during init process
```

</details>

<details><summary>Example: 3-Node Minio Cluster</summary><br>

The following snippet [`minio.yml`](https://github.com/Vonng/pigsty/blob/main/conf/dbms/minio.yml) provisions an optional 3-node [Minio](https://pigsty.io/docs/minio/) cluster for S3-compatible object storage service:

```yaml
minio:
  hosts:
    10.10.10.10: { minio_seq: 1 }
    10.10.10.11: { minio_seq: 2 }
    10.10.10.12: { minio_seq: 3 }
  vars:
    minio_cluster: minio
    minio_data: '/data{1...2}'        # use two disk per node
    minio_node: '${minio_cluster}-${minio_seq}.pigsty' # minio node name pattern
    haproxy_services:
      - name: minio                     # [REQUIRED] service name, unique
        port: 9002                      # [REQUIRED] service port, unique
        options:
          - option httpchk
          - option http-keep-alive
          - http-check send meth OPTIONS uri /minio/health/live
          - http-check expect status 200
        servers:
          - { name: minio-1 ,ip: 10.10.10.10 , port: 9000 , options: 'check-ssl ca-file /etc/pki/ca.crt check port 9000' }
          - { name: minio-2 ,ip: 10.10.10.11 , port: 9000 , options: 'check-ssl ca-file /etc/pki/ca.crt check port 9000' }
          - { name: minio-3 ,ip: 10.10.10.12 , port: 9000 , options: 'check-ssl ca-file /etc/pki/ca.crt check port 9000' }
```

</details>

Check [**Configuration**](https://pigsty.io/docs/setup/config/), [**PGSQL Conf**](https://pigsty.io/docs/pgsql/config/) for details.


----------------

## Modules

There are a series of [**modules**](https://pigsty.io/docs/about/modules/) available to extend the functionalities.

Pigsty allow using different PostgreSQL [**kernel**](https://pigsty.io/docs/kernel/) forks as in-place replacement, such as:

- [**`PGSQL`**](https://pigsty.io/docs/pgsql): Vanilla PostgreSQL kernel with 333 available [**extensions**](https://pigsty.io/docs/pgext/list)!
- [**`MSSQL`**](https://pigsty.io/docs/kernel/babelfish/): Microsoft SQL Server Wire Protocol Compatible kernel powered by AWS, WiltonDB & Babelfish.
- [**`IVORY`**](https://pigsty.io/docs/kernel/ivorysql): Oracle Compatible kernel powered by the IvorySQL project.
- [**`POLAR`**](https://pigsty.io/docs/kernel/polardb/): Oracle RAC / CloudNative kernel powered by Alibaba PolarDB for PostgreSQL
- And more will come: **`PolarO`**, **`GPSQL`**, **`NEON`**,  etc...

Besides, Pigsty also have a series of **OPTIONAL** extended modules for more advanced use cases:

- [**`MINIO`**](https://pigsty.io/docs/minio/): S3-compatible object storage service used as an optional central backup server for `PGSQL`.
- [**`REDIS`**](https://pigsty.io/docs/redis/): Deploy Redis servers in standalone master-replica, sentinel, and native cluster mode.
- [**`MONGO`**](https://pigsty.io/docs/mongo/): Native support for FerretDB — adding MongoDB wire protocol compatibility to PostgreSQL!
- [**`DOCKER`**](https://pigsty.io/docs/docker/): Launch optional docker daemon to run other stateless parts in additional to Pigsty RDS.

Other pro / beta / pilot modules: [**`KAFKA`**](https://pigsty.io/docs/pro/kafka/), [**`DUCKDB`**](https://pigsty.io/docs/pro/duckdb/), [**`SUPABASE`**](https://pigsty.io/docs/kernel/supabase/), [**`TIGERBEETLE`**](https://pigsty.io/docs/pro/tigerbeetle/), [**`VICTORIA`**](https://pigsty.cc/zh/docs/pro/victoria/), [**`Jupyter`**](https://pigsty.cc/zh/docs/pro/jupyter/), [**`MYSQL`**](https://pigsty.cc/zh/docs/pro/mysql/),...




----------------

## About

Docs: https://pigsty.io/docs

Website: https://pigsty.io/ | https://pigsty.cc/zh/

WeChat: Search `pigsty-cc` to join the WeChat group.

Telegram: https://t.me/joinchat/gV9zfZraNPM3YjFh

Discord: https://discord.gg/j5pG8qfKxU

Author: [Vonng](https://vonng.com/en) ([rh@vonng.com](mailto:rh@vonng.com))

License: [AGPL-3.0](LICENSE)

Copyright: 2018-2024 rh@vonng.com