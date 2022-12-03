# Pigsty

**PostgreSQL in Great STYle, Battery-Included Free RDS Alternative!**

> Best Practices for using PostgreSQL in real-world production environment! 

![icon](https://user-images.githubusercontent.com/8587410/198861991-cd169e71-9d62-42ca-a3e0-db945d5751d9.svg)

**Current master branch is under development (v2.0.0-b1), check [v1.5.1](https://github.com/Vonng/pigsty/tree/v1.5.1) for stable release.**

> Latest Beta: [v2.0.0-b1](https://github.com/Vonng/pigsty/releases/tag/v2.0.0-b1) | Stable Version: [v1.5.1](https://github.com/Vonng/pigsty/releases/tag/v1.5.1)  |  [Demo](http://demo.pigsty.cc)
>
> Documentation:  [Wiki](https://github.com/Vonng/pigsty/wiki), [Website](https://pigsty.cc/en/) | [中文站点](https://pigsty.cc/zh/)


[![pigsty](https://user-images.githubusercontent.com/8587410/198840611-744709cb-cf25-4dff-a91d-c593347076a8.jpg)](https://pigsty.cc/en/)



--------

## What is Pigsty?


* [**Open Source RDS**](#): Open-Source alternative to public cloud RDS.
  <details><summary>Full-Featured Open-Source Alternative to RDS PostgreSQL</summary>

  ![RDS](https://user-images.githubusercontent.com/8587410/198838843-3b9c4c42-849b-48d3-9a13-25da10c33a86.gif)

  > If you can have a better RDS service with the price of EC2, Why use RDS at all?
  </details>
* [**Postgres Distribution**](#): PostgreSQL, PostGIS, TimescaleDB, Citus, Redis/GP, United in One!
  <details><summary>PostgreSQL Kernel, Extensions, Peripherals, and Companion</summary>

  ![DISTRO](https://user-images.githubusercontent.com/8587410/198838835-f9df4737-f109-4e5b-b5a0-f54aa1b33c5a.gif)

  > PostGIS, TimescaleDB, Citus, and tons of extensions!
  </details>

* [**Infra Best Practice**](#): Full observability stack of Prometheus & Grafana, Battery-Included!
  <details><summary>Open Source Infrastructure Best Practice, Ultimate observability for free!</summary>

  ![ARCH](https://user-images.githubusercontent.com/8587410/198838831-d0f263cb-da99-46db-a33e-01e7a9c6e061.gif)

  > If you can have a better RDS service with the price of EC2, Why use RDS at all?
  </details>

* [**Developer Toolbox**](#): Manage production-ready HA database clusters in one command!
  <details><summary>GUI & CLI, Handling 70% of database administration work in minutes!</summary>

  ![INTERFACE](https://user-images.githubusercontent.com/8587410/198838840-898dbe75-8af7-4b87-9d18-02abc33f36eb.gif)

  > Define clusters in a declarative manner and materialize them with idempotent playbooks
  </details>

Check [**Architecture**](https://github.com/Vonng/pigsty/wiki/Architecture) & [**Demo**](http://demo.pigsty.cc) for details.




--------

## Why Pigsty?


* [**High-Availability**](#): Auto-Pilot Postgres with idempotent instances & services, self-healing from failures!
  <details><summary>High-Availability PostgreSQL Powered by Patroni & HAProxy</summary>

  ![HA](https://user-images.githubusercontent.com/8587410/198838836-433331a4-0df1-4588-944c-625c34430f2f.svg)

  > Self-healing on hardware failures: Failover impact on primary < 30s, Switchover impact < 1s
  </details>

* [**Ultimate Observability**](#): Unparalleled monitoring system based on modern open-source best-practice!!
  <details><summary>Observability powered by Grafana, Prometheus & Loki</summary>

  ![DASHBOARD](https://user-images.githubusercontent.com/8587410/198838834-1bd30b7e-47c9-4e35-90cb-5a75a2e6f6c6.jpg)

  > 3K+ metrics on 30+ dashboards, Check [http://demo.pigsty.cc](http://demo.pigsty.cc) for a live demo!

  </details>

* [**Database as Code**](#): Declarative config with idempotent playbooks. WYSIWYG and GitOps made easy!
  <details><summary>Define & Create a HA PostgreSQL Cluster in 10 lines of Code</summary>

  ![IAC](https://user-images.githubusercontent.com/8587410/198838838-91c3d193-f600-422c-b504-b9bbec076802.gif)

  > Create a 3-node HA PostgreSQL with 10 lines of config and one command! Check [conf](https://github.com/Vonng/pigsty/tree/master/files/conf) for examples.

  </details>

* [**IaaS Provisioning**](#): Bare metal or VM, Cloud or On-Perm, One-Click provisioning with Vagrant/Terraform

  <details><summary>Pigsty 4-nodes sandbox on Local Vagrant VM or AWS EC2</summary>

  ![SANDBOX](https://user-images.githubusercontent.com/8587410/198838845-09aee295-31d2-495b-b206-40ffc5f25133.gif)

  > Full-featured 4 nodes demo sandbox can be created using pre-configured vagrant & terraform templates.

  </details>

* [**Versatile Scenario**](f#):  Monitor existing RDS, Run docker template apps, Toolset for data apps & vis/analysis.
  <details><summary>Docker Applications, Data Toolkits, Visualization Data Apps</summary>

  ![APP](https://user-images.githubusercontent.com/8587410/198838829-f0ea4af2-d33f-4978-a31a-ed81897aa8d1.gif)

  > If your software requires a PostgreSQL, Pigsty may be the easiest way to get one.
  </details>


* [**Production Ready**](#): Ready for large-scale production environment and proven in real-world scenarios.

  <details><summary>Overview Dashboards for a Huge Production Deployment</summary>

  ![OVERVIEW](https://user-images.githubusercontent.com/8587410/198838841-b0796703-03c3-483b-bf52-dbef9ea10913.gif)

  > A real-world Pigsty production deployment with 240 nodes, 13kC / 100T, 500K TPS , 3+ years.

    </details>

* [**Cost Saving**](#): Save 50% - 90% compare to Public Cloud RDS. Create as many clusters as you want for free!

  <details><summary>Price Reference for EC2 / RDS Unit  ($ per  core · per month)</summary>

  | Resource                                               | **Node Price** |
  |--------------------------------------------------------|:--------------:|
  | AWS EC2 C5D.METAL 96C 200G                             | 11 ~ 14        |
  | Aliyun ECS 2xMem Series Exclusive                      | 28 ~ 38        |
  | IDC Self-Hosting: Dell R730 64C 384G x PCI-E SSD 3.2TB | 2.6            |
  | IDC Self-Hosting: Dell R730 40C 64G (China Mobile)     | 3.6            |
  | UCloud VPC 8C / 16G Exclusive                          | 3.3            |
  | **EC2**  /  **RDS**                                    | **RDS Price**  |
  | Aliyun RDS PG 2x Mem                                   | 36 ~ 56        |
  | AWS RDS PostgreSQL db.T2 (4x) / EBS                    | 60             |
  | AWS RDS PostgreSQL db.M5 (4x) / EBS                    | 84             |
  | AWS RDS PostgreSQL db.R6G (8x) / EBS                   | 108            |
  | AWS RDS PostgreSQL db.M5 24xlarge (96C 384G)           | 182            |
  | Oracle Licenses                                        | 1300           |

  > AWS Price [Calculator](https://calculator.amazonaws.cn/#/): You can run RDS service with a dramatic cost reduction with EC2 or IDC.

  </details>

* [**Security**](#): On-Perm Deployment, Self-signed CA, Full SSL Support, PITR with one command.

  <details><summary>PITR with Pgbackrest</summary>
  
  ```bash
  pg-backup                      # make a full/incr backup
  pg-pitr "2022-11-08 10:58:48"  # pitr to specific timepoint
  pg-restore 20221108-105325F_20221108-105938I # restore to specific backup
  ```

  > Check [Backup & PITR](https://github.com/Vonng/pigsty/wiki/Backup-and-PITR) for details 

  </details>


Check [**FEATURES**](https://github.com/Vonng/pigsty/wiki/Overview) for detail.



--------

## Getting Started

Get a fresh Linux x86_64 EL7/8/9 node with nopass `sudo` & `ssh` access, then run:

```bash
bash -c "$(curl -fsSL http://download.pigsty.cc/get)" && cd ~/pigsty   
./bootstrap  && ./configure && ./install.yml # install latest pigsty
```

<details><summary>Compatible OS Platform</summary>

| Vendor \ Version | EL7  | EL8  | EL9  |
| :--------------: | :--: | :--: | :--: |
|      RedHat      |  7   |  8   |  9   |
|      CentOS      |  7*  |  8   |  x   |
|   Rocky Linux    |      |  8*  |  9*  |
|    AlmaLinux     |  7   |  8   |  8   |
|   OracleLinux    |  7   |  8   |  9   |

> Pigsty offline packages are built on CentOS 7.9, Rocky 8.6, and Rocky 9.0. Which are fully tested. 

</details>

Then you will have full-featured Postgres on port `5432` and Infra Stack on port `80` by default.

Check [Installation](https://github.com/Vonng/pigsty/wiki/Installation) & [Configure](https://github.com/Vonng/pigsty/wiki/Configuration) for detail.





## Modular Design

Pigsty uses a **modular** design. There are several default modules available:

* [`INFRA`](https://github.com/Vonng/pigsty/wiki/INFRA): Local yum repo, Nginx, DNS, and entire Prometheus & Grafana observability stack.
* [`NODE`](https://github.com/Vonng/pigsty/wiki/NODE):   Init node name, repo, pkg, NTP, ssh, admin, tune, expose services, collect logs & metrics.
* [`ETCD`](https://github.com/Vonng/pigsty/wiki/ETCD):   Init etcd cluster for HA PostgreSQL DCS or Kubernetes, used as distributed config store.
* [`PGSQL`](https://github.com/Vonng/pigsty/wiki/PGSQL): Autonomous self-healing PostgreSQL cluster powered by Patroni, Pgbouncer, PgBackrest & HAProxy
* [`REDIS`](https://github.com/Vonng/pigsty/wiki/REDIS): Deploy Redis servers in standalone master-replica, sentinel, and native cluster mode, optional.
* [`MINIO`](https://github.com/Vonng/pigsty/wiki/MINIO): S3-compatible object storage service used as an optional central backup server for `PGSQL`.

You can compose them freely in a declarative manner. If you want host monitoring, `INFRA` & `NODE` will suffice.
`ETCD` and `PGSQL` are used for HA PG clusters, install them on multiple nodes will automatically form a HA cluster.
You can also reuse pigsty infra and develop your own modules, `KAFKA`, `MYSQL`, `GPSQL`, and more will come.

The default [`install.yml`](install.yml) playbook in [Getting Started](#getting-started) will install `INFRA`, `NODE`, `ETCD` & `PGSQL` on the current node. 
which gives you a battery-included PostgreSQL singleton instance (`admin_ip:5432`) with everything ready.
This node can be used as an admin center & infra provider to manage, deploy & monitor more nodes & clusters.




## More Clusters

To deploy a 3-node HA Postgres Cluster with streaming replication,
[define](https://github.com/Vonng/pigsty/blob/master/pigsty.yml#L157) a new cluster on `all.children.pg-test` of [`pigsty.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml):

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
bin/createpg pg-test   # init pg-test cluster 
```

You can deploy different kinds of instance roles such as primary, replica, offline, delayed, sync standby,
and different kinds of clusters such as standby clusters, Citus clusters, and even Redis clusters & YMatrix clusters.
Check [playbook](https://github.com/Vonng/pigsty/wiki/Playbook) & [admin](https://github.com/Vonng/pigsty/wiki/Administration) for details.

<details><summary>Example: Complex Postgres Customize</summary>

```bash
pg-meta:
  hosts: { 10.10.10.10: { pg_seq: 1, pg_role: primary , pg_offline_query: true } }
  vars:
    pg_cluster: pg-meta
    patroni_watchdog_mode: off
    pg_databases:                       # define business databases on this cluster, array of database definition
      - name: meta                      # REQUIRED, `name` is the only mandatory field of a database definition
        baseline: cmdb.sql              # optional, database sql baseline path, (relative path among ansible search path, e.g files/)
        pgbouncer: true                 # optional, add this database to pgbouncer database list? true by default
        schemas: [pigsty]               # optional, additional schemas to be created, array of schema names
        extensions: [{name: postgis}]   # optional, additional extensions to be installed: array of `{name[,schema]}`
        comment: pigsty meta database   # optional, comment string for this database
        #owner: postgres                # optional, database owner, postgres by default
        #template: template1            # optional, which template to use, template1 by default
        #encoding: UTF8                 # optional, database encoding, UTF8 by default. (MUST same as template database)
        #locale: C                      # optional, database locale, C by default.  (MUST same as template database)
        #lc_collate: C                  # optional, database collate, C by default. (MUST same as template database)
        #lc_ctype: C                    # optional, database ctype, C by default.   (MUST same as template database)
        #tablespace: pg_default         # optional, default tablespace, 'pg_default' by default.
        #allowconn: true                # optional, allow connection, true by default. false will disable connect at all
        #revokeconn: false              # optional, revoke public connection privilege. false by default. (leave connect with grant option to owner)
        #register_datasource: true      # optional, register this database to grafana datasources? true by default
        #connlimit: -1                  # optional, database connection limit, default -1 disable limit
        #pool_auth_user: dbuser_meta    # optional, all connection to this pgbouncer database will be authenticated by this user
        #pool_mode: transaction         # optional, pgbouncer pool mode at database level, default transaction
        #pool_size: 64                  # optional, pgbouncer pool size at database level, default 64
        #pool_size_reserve: 32          # optional, pgbouncer pool size reserve at database level, default 32
        #pool_size_min: 0               # optional, pgbouncer pool size min at database level, default 0
        #pool_max_db_conn: 100          # optional, max database connections at database level, default 100
      #- { name: grafana  ,owner: dbuser_grafana  ,revokeconn: true ,comment: grafana primary database }
      #- { name: bytebase ,owner: dbuser_bytebase ,revokeconn: true ,comment: bytebase primary database }
      #- { name: kong     ,owner: dbuser_kong     ,revokeconn: true ,comment: kong the api gateway database }
      #- { name: gitea    ,owner: dbuser_gitea    ,revokeconn: true ,comment: gitea meta database }
      #- { name: wiki     ,owner: dbuser_wiki     ,revokeconn: true ,comment: wiki meta database }
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
        search_path: public             # key value config parameters according to postgresql documentation (e.g: use pigsty as default search_path)
      - {name: dbuser_view     ,password: DBUser.Viewer   ,pgbouncer: true ,roles: [dbrole_readonly], comment: read-only viewer for meta database}
      #- {name: dbuser_grafana  ,password: DBUser.Grafana  ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for grafana database   }
      #- {name: dbuser_bytebase ,password: DBUser.Bytebase ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for bytebase database  }
      #- {name: dbuser_kong     ,password: DBUser.Kong     ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for kong api gateway   }
      #- {name: dbuser_gitea    ,password: DBUser.Gitea    ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for gitea service      }
      #- {name: dbuser_wiki     ,password: DBUser.Wiki     ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for wiki.js service    }
    pg_services:                        # extra services in addition to pg_default_services, array of service definition
      # standby service will route {ip|name}:5435 to sync replica's pgbouncer (5435->6432 standby)
      - name: standby                   # required, service name, the actual svc name will be prefixed with `pg_cluster`, e.g: pg-meta-standby
        port: 5435                      # required, service exposed port (work as kubernetes service node port mode)
        ip: "*"                         # optional, service bind ip address, `*` for all ip by default
        selector: "[]"                  # required, service member selector, use JMESPath to filter inventory
        dest: pgbouncer                 # optional, destination port, postgres|pgbouncer|<port_number> , pgbouncer(6432) by default
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
    node_crontab:
      - '00 01 * * * postgres pgbackrest --stanza=pg-meta backup >> /pg/log/pgbackrest/backup.log 2>&1'

```

</details>

<details><summary>Example: Security Enhanced PG Cluster with Delayed Replica</summary>

```bash
pg-meta:                          # 3 instance postgres cluster `pg-meta`
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
      - { name: meta , baseline: cmdb.sql ,comment: pigsty meta database , schemas: [ pigsty ] , extensions: [{ name: postgis, schema: public }] }
    pg_services:
      - { name: standby ,src_ip: "*" ,src_port: 5435 , dst_port: postgres ,selector: "[]" , selector_backup: "[? pg_role == `primary`]" }
    vip_mode: l2
    vip_address: 10.10.10.2
    vip_cidrmask: 8
    vip_interface: eth1

# OPTIONAL delayed cluster for pg-meta
pg-meta-delay:                    # delayed instance for pg-meta (1 hour ago)
  hosts:
    10.10.10.13: { pg_seq: 1, pg_role: primary, pg_upstream: 10.10.10.10, pg_delay: 1h }
  vars:
    pg_cluster: pg-meta-delay
```

</details>

<details><summary>Example: Citus Cluster: 1 Coordinator x 3 Data Nodes</summary>

```bash
# citus coordinator node
pg-meta:
  hosts:
    10.10.10.10: { pg_seq: 1, pg_role: primary , pg_offline_query: true }
  vars:
    pg_cluster: pg-meta
    pg_users: [{ name: citus ,password: citus ,pgbouncer: true ,roles: [dbrole_admin]}]
    pg_databases:
      - { name: meta ,schemas: [pigsty] ,extensions: [{name: postgis, schema: public},{ name: citus}] ,baseline: cmdb.sql ,comment: pigsty meta database}

# citus data node 1,2,3
pg-node1:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
  vars:
    pg_cluster: pg-node1
    vip_address: 10.10.10.3
    pg_users: [{ name: citus ,password: citus ,pgbouncer: true ,roles: [dbrole_admin]}]
    pg_databases: [{ name: meta ,owner: citus , extensions: [{name: citus},{name: postgis, schema: public}]}]

pg-node2:
  hosts:
    10.10.10.12: { pg_seq: 1, pg_role: primary  , pg_offline_query: true }
  vars:
    pg_cluster: pg-node2
    vip_address: 10.10.10.4
    pg_users: [ { name: citus , password: citus , pgbouncer: true , roles: [ dbrole_admin ] } ]
    pg_databases: [ { name: meta , owner: citus , extensions: [ { name: citus }, { name: postgis, schema: public } ] } ]

pg-node3:
  hosts:
    10.10.10.13: { pg_seq: 1, pg_role: primary  , pg_offline_query: true }
  vars:
    pg_cluster: pg-node3
    vip_address: 10.10.10.5
    pg_users: [ { name: citus , password: citus , pgbouncer: true , roles: [ dbrole_admin ] } ]
    pg_databases: [ { name: meta , owner: citus , extensions: [ { name: citus }, { name: postgis, schema: public } ] } ]

```

</details>

<details><summary>Redis Cluster Example</summary>

```bash
# redis sentinel
redis-meta:
  hosts:
    10.10.10.10:
      redis_node: 1
      redis_instances:  { 6001 : {} ,6002 : {} , 6003 : {} }
  vars:
    redis_cluster: redis-meta
    redis_mode: sentinel
    redis_max_memory: 64MB

# redis native cluster
redis-test:
  hosts:
    10.10.10.11:
      redis_node: 1
      redis_instances: { 6501 : {} ,6502 : {} ,6503 : {} }
    10.10.10.12:
      redis_node: 2
      redis_instances: { 6501 : {} ,6502 : {} ,6503 : {} }
  vars:
    redis_cluster: redis-test           # name of this redis 'cluster'
    redis_mode: cluster                 # standalone,cluster,sentinel
    redis_max_memory: 32MB              # max memory used by each redis instance
    redis_mem_policy: allkeys-lru       # memory eviction policy

# redis standalone
redis-common:
  hosts:
    10.10.10.13:
      redis_node: 1
      redis_instances:
        6501: {}
        6502: { replica_of: '10.10.10.13 6501' }
        6503: { replica_of: '10.10.10.13 6501' }
  vars:
    redis_cluster: redis-common         # name of this redis 'cluster'
    redis_mode: standalone              # standalone,cluster,sentinel
    redis_max_memory: 64MB              # max memory used by each redis instance
```

</details>




## About

> Pigsty (/ˈpɪɡˌstaɪ/) is the abbreviation of "PostgreSQL In Great STYle."

Wiki: https://github.com/Vonng/pigsty/wiki

Official Site: https://pigsty.cc/en/ , https://pigsty.cc/zh/

WeChat Group: Search `pigsty-cc` to join the WeChat group.

Telegram: https://t.me/joinchat/gV9zfZraNPM3YjFh

Discord: https://discord.gg/wDzt5VyWEz

Author: [Vonng](https://vonng.com/en) ([rh@vonng.com](mailto:rh@vonng.com))

License: [AGPL-3.0](LICENSE)

Copyright 2018-2022 rh@vonng.com
