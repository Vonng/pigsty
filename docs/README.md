# Pigsty

> **PostgreSQL in Great STYle**

**A battery-included, open-source RDS alternative.**

![](icon.svg)

> Latest Version: [v2.0.0-rc3](https://github.com/Vonng/pigsty/releases/tag/v2.0.0-rc3)  |  [Github Repo](https://github.com/Vonng/pigsty) | [Demo](http://demo.pigsty.cc) | [Docs](https://vonng.github.io/pigsty/#/) | [Website](https://pigsty.cc/en/)


![pigsty-banner](https://user-images.githubusercontent.com/8587410/206971422-deb6dd88-c89e-43e4-8130-cf32a24b07b9.jpg)



## Features

Pigsty is a **Me-Better Open-Source RDS Alternative** with:

- Battery-Included [PostgreSQL](https://www.postgresql.org/) Distribution, with [PostGIS](https://postgis.net/), [TimescaleDB](https://www.timescale.com/), [Citus](https://www.citusdata.com/) ...
- Incredible observability powered by [Prometheus](https://prometheus.io/) & [Grafana](https://grafana.com/) stack.
- Self-healing HA PGSQL cluster, powered by [patroni](https://patroni.readthedocs.io/en/latest/), [haproxy](http://www.haproxy.org/), [etcd](https://etcd.io/)...
- Auto-Configured PITR, powered by [pgbackrest](https://pgbackrest.org/) and optional [MinIO](https://min.io/) cluster
- Declarative API, Database-as-Code implemented with [Ansible](https://www.ansible.com/) playbooks.
- Versatile Scenarios, run [Docker](https://www.docker.com/) apps, build demos, visualize data with [ECharts](https://echarts.apache.org/).
- Handy Toolbox, provision IaaS with [Terraform](https://www.terraform.io/), and try with local [Vagrant](https://www.vagrantup.com/) sandbox.

[![pigsty-distro](https://user-images.githubusercontent.com/8587410/206971964-0035bbca-889e-44fc-9b0d-640d34573a95.gif)](FEATURE)


Check [**Feature**](FEATURE) for detail.



## Get Started

Prepare a new node with Linux x86_64 EL compatible OS, then run as a **sudo-able** user:

```bash
bash -c "$(curl -fsSL http://download.pigsty.cc/getb)" && cd ~/pigsty   
./bootstrap  && ./configure && ./install.yml # install latest pigsty
```

Then you will have a pigsty singleton node ready, with Web Services on port `80` and Postgres on port `5432`.

>  `getb` will get the latest beta, v2.0.0-rc3, while `get` will use the last stable release, v1.5.1. 

<details><summary>Download Directly</summary>

You can also download pigsty source and packages with `git` or `curl` directly:

```bash
curl -L https://github.com/Vonng/pigsty/releases/download/v2.0.0-rc3/pigsty-v2.0.0-rc3.tgz -o ~/pigsty.tgz
curl -L https://github.com/Vonng/pigsty/releases/download/v2.0.0-rc3/pigsty-pkg-v2.0.0-rc3.el7.x86_64.tgz  -o /tmp/pkg.tgz
# or using git if curl not available
git clone https://github.com/Vonng/pigsty; cd pigsty; git checkout v2.0.0-rc3
```

</details>

Check [**Installation**](INSTALL) for details.







## Architecture

Pigsty uses a **modular** design. There are six default modules available:

* [`INFRA`](INFRA): Local yum repo, Nginx, DNS, and entire Prometheus & Grafana observability stack.
* [`NODE`](NODE):   Init node name, repo, pkg, NTP, ssh, admin, tune, expose services, collect logs & metrics.
* [`ETCD`](ETCD):   Init etcd cluster for HA Postgres DCS or Kubernetes, used as distributed config store.
* [`PGSQL`](PGSQL): Autonomous self-healing PostgreSQL cluster powered by Patroni, Pgbouncer, PgBackrest & HAProxy
* [`REDIS`](REDIS): Deploy Redis servers in standalone master-replica, sentinel, and native cluster mode, optional.
* [`MINIO`](MINIO): S3-compatible object storage service used as an optional central backup server for `PGSQL`.

You can compose them freely in a declarative manner. If you want host monitoring, `INFRA` & `NODE` will suffice.
`ETCD` and `PGSQL` are used for HA PG clusters, install them on multiple nodes will automatically form a HA cluster.
You can also reuse pigsty infra and develop your own modules, `KAFKA`, `MYSQL`, `GPSQL`, and more will come.

The default [`install.yml`](https://github.com/Vonng/pigsty/blob/master/install.yml) playbook in [Get Started](#get-started) will install `INFRA`, `NODE`, `ETCD` & `PGSQL` on the current node. 
which gives you a battery-included PostgreSQL singleton instance (`admin_ip:5432`) with everything ready.
This node can be used as an admin center & infra provider to manage, deploy & monitor more nodes & clusters.

Check [**Architecture**](ARCH) for details.





## More Clusters

To deploy a 3-node HA Postgres Cluster with streaming replication, [define](https://github.com/Vonng/pigsty/blob/master/pigsty.yml#L157) a new cluster on `all.children.pg-test` of [`pigsty.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml):

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

You can deploy different kinds of instance roles, such as primary, replica, offline, delayed, sync standby, and different kinds of clusters, such as standby clusters, Citus clusters, and even Redis/MinIO/Etcd clusters.

<details><summary>Example: Complex Postgres Customize</summary>

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

<details><summary>Example: Security Enhanced PG Cluster with Delayed Replica</summary>

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
    pg_services:
      - { name: standby ,src_ip: "*" ,port: 5435 , dest: default ,selector: "[]" , backup: "[? pg_role == `primary`]" }
    pg_vip_enabled: true
    pg_vip_address: 10.10.10.2/24
    pg_vip_interface: eth1

# OPTIONAL delayed cluster for pg-meta
pg-meta-delay:                    # delayed instance for pg-meta (1 hour ago)
  hosts: { 10.10.10.13: { pg_seq: 1, pg_role: primary, pg_upstream: 10.10.10.10, pg_delay: 1h } }
  vars: { pg_cluster: pg-meta-delay }
```

</details>

<details><summary>Example: Citus Distributed Cluster: 5 Nodes</summary>

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
    patroni_citus_db: meta            # citus distributed database name
    pg_dbsu_password: DBUser.Postgres # all dbsu password access for citus cluster
    pg_users: [ { name: dbuser_meta ,password: DBUser.Meta ,pgbouncer: true ,roles: [ dbrole_admin ] } ]
    pg_databases: [ { name: meta ,extensions: [ { name: citus }, { name: postgis }, { name: timescaledb } ] } ]
    pg_hba_rules:
      - { user: 'all' ,db: all  ,addr: 127.0.0.1/32 ,auth: ssl ,title: 'all user ssl access from localhost' }
      - { user: 'all' ,db: all  ,addr: intra        ,auth: ssl ,title: 'all user ssl access from intranet'  }
```


</details>

<details><summary>Example: Redis Cluster/Sentinel/Standalone</summary>

```yaml
redis-ms: # redis classic primary & replica
  hosts: { 10.10.10.10: { redis_node: 1 , redis_instances: { 6501: { }, 6502: { replica_of: '10.10.10.13 6501' } } } }
  vars: { redis_cluster: redis-ms ,redis_password: 'redis.ms' ,redis_max_memory: 64MB }

redis-meta: # redis sentinel x 3
  hosts: { 10.10.10.11: { redis_node: 1 , redis_instances: { 6001: { } ,6002: { } , 6003: { } } } }
  vars: { redis_cluster: redis-meta, redis_mode: sentinel ,redis_max_memory: 16MB }

redis-test: # redis native cluster: 3m x 3s
  hosts:
    10.10.10.12: { redis_node: 1 ,redis_instances: { 6501: { } ,6502: { } ,6503: { } } }
    10.10.10.13: { redis_node: 2 ,redis_instances: { 6501: { } ,6502: { } ,6503: { } } }
  vars: { redis_cluster: redis-test ,redis_mode: cluster, redis_max_memory: 32MB }

```

</details>

<details><summary>Example: ETCD 3 Node Cluster</summary>

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

<details><summary>Example: Minio 3 Node Deployment</summary>

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

Check [**Configuration**](CONFIG) for details.





## About

> Pigsty (/ˈpɪɡˌstaɪ/) is the abbreviation of "PostgreSQL In Great STYle."

Wiki: https://github.com/Vonng/pigsty/wiki

Official Site: https://pigsty.cc/en/ , https://pigsty.cc/zh/

WeChat Group: Search `pigsty-cc` to join the WeChat group.

Telegram: https://t.me/joinchat/gV9zfZraNPM3YjFh

Discord: https://discord.gg/wDzt5VyWEz

Author: [Vonng](https://vonng.com/en) ([rh@vonng.com](mailto:rh@vonng.com))

License: [AGPL-3.0](LICENSE)

Copyright 2018-2023 rh@vonng.com
