# Pigsty

> "**P**ostgreSQL **I**n **G**reat **STY**le."
>
> —— **开箱即用，本地优先的 RDS PostgreSQL 开源替代**
>
> 最新版本：[v2.3.1](https://github.com/Vonng/pigsty/releases/tag/v2.3.1) | [仓库](https://github.com/Vonng/pigsty) | [演示](https://demo.pigsty.cc) | [文档](https://doc.pigsty.cc/) | [网站](https://pigsty.cc/zh/) | [博客](https://pigsty.cc/zh/blog) | [服务订阅](https://pigsty.cc/zh/docs/support/) | [微信公众号](https://mp.weixin.qq.com/s/-E_-HZ7LvOze5lmzy3QbQA)  | [英文文档](/)
>
> [快速上手](INSTALL.md)： `curl -fsSL https://get.pigsty.cc/latest | bash`


----------------

## 功能特性

Pigsty 是一个更好的本地开源 RDS for PostgreSQL 替代，具有以下特点：

- 开箱即用的 [PostgreSQL](https://www.postgresql.org/) 发行版，深度整合地理时序分布式向量等核心扩展： [PostGIS](https://postgis.net/), [TimescaleDB](https://www.timescale.com/), [Citus](https://www.citusdata.com/)，[PGVector](https://github.com/pgvector/pgvector)…
- 基于现代的 [Prometheus](https://prometheus.io/) 与 [Grafana](https://grafana.com/) 技术栈，提供令人惊艳，无可比拟的数据库观测能力：[画廊](https://github.com/Vonng/pigsty/wiki/Gallery) & [演示站点](https://demo.pigsty.cc)
- 基于 [patroni](https://patroni.readthedocs.io/en/latest/), [haproxy](http://www.haproxy.org/), 与[etcd](https://etcd.io/)，打造故障自愈的高可用架构：硬件故障自动切换，流量无缝衔接。
- 基于 [pgBackRest](https://pgbackrest.org/) 与可选的 [MinIO](https://min.io/) 集群提供开箱即用的 PITR 时间点恢复，为软件缺陷与人为删库兜底。
- 基于 [Ansible](https://www.ansible.com/) 提供声明式的 API 对复杂度进行抽象，以 **Database-as-Code** 的方式极大简化了日常运维管理操作。
- Pigsty用途广泛，可用作完整应用运行时，开发演示数据/可视化应用，大量使用 PG 的软件可用 [Docker](https://www.docker.com/) 模板一键拉起。
- 提供基于 [Vagrant](https://www.vagrantup.com/) 的本地开发测试沙箱环境，与基于 [Terraform](https://www.terraform.io/) 的云端自动部署方案，开发测试生产保持环境一致。
- 部署并监控专用的 [Redis](https://redis.io/)（主从，哨兵，集群），MinIO，Etcd，Haproxy，MongoDB([FerretDB](https://www.ferretdb.io/)) 集群

[![pigsty-distro](https://user-images.githubusercontent.com/8587410/226076217-77e76e0c-94ac-4faa-9014-877b4a180e09.jpg)](FEATURE.md)

[![Dashboards](https://github-production-user-asset-6210df.s3.amazonaws.com/8587410/258681605-cf6b99e5-9c8f-4db2-9bce-9ded95407c0c.jpg)](https://demo.pigsty.cc)



----------------

## 快速上手

Pigsty可以一键安装! 详情请参阅[**快速上手**](install)。

准备一个使用 Linux x86_64 EL 7，8，9 兼容系统的全新节点，使用带有免密 `sudo` 权限的用户执行：

```bash
bash -c "$(curl -fsSL https://get.pigsty.cc/latest)" && cd ~/pigsty   
./bootstrap  && ./configure && ./install.yml # 安装最新的 Pigsty 源码
```

安装完成后，您可以通过域名或`80/443`端口通过 Nginx 访问 [WEB界面](INFRA#概览)，通过 `5432` 端口[访问](PGSQL-SVC#单机用户)默认的 PostgreSQL 数据库[服务](PGSQL-SVC#服务概述)。


<details><summary>一键安装脚本</summary>

```bash
$ curl https://get.pigsty.cc/latest | bash
...
[Checking] ===========================================
[ OK ] SOURCE from CDN due to GFW
FROM CDN    : bash -c "$(curl -fsSL https://get.pigsty.cc/latest)"
FROM GITHUB : bash -c "$(curl -fsSL https://raw.githubusercontent.com/Vonng/pigsty/master/bin/latest)"
[Downloading] ===========================================
[ OK ] download pigsty source code from CDN
[ OK ] $ curl -SL https://get.pigsty.cc/v2.3.1/pigsty-v2.3.1.tgz
...
MD5: d5dc4a51efc81932a03d7c010d0d5d64  /tmp/pigsty-v2.3.1.tgz
[Extracting] ===========================================
[ OK ] extract '/tmp/pigsty-v2.3.1.tgz' to '/home/vagrant/pigsty'
[ OK ] $ tar -xf /tmp/pigsty-v2.3.1.tgz -C ~;
[Reference] ===========================================
Official Site:   https://pigsty.cc
Get Started:     https://doc.pigsty.cc/#/INSTALL
Documentation:   https://doc.pigsty.cc
Github Repo:     https://github.com/Vonng/pigsty
Public Demo:     https://demo.pigsty.cc
[Proceeding] ===========================================
cd ~/pigsty      # entering pigsty home directory before proceeding
./bootstrap      # install ansible & download the optional offline packages
./configure      # preflight-check and generate config according to your env
./install.yml    # install pigsty on this node and init it as the admin node
[ OK ] ~/pigsty is ready to go now!
```

</details>


<details><summary>Git检出安装</summary>

你也可以使用 `git` 来下载安装 Pigsty 源代码，不要忘了检出特定的版本。

```bash
git clone https://github.com/Vonng/pigsty;
cd pigsty; git checkout v2.3.1
```

</details>


<details><summary>直接下载</summary>

您还可以直接从 GitHub 发布页面下载源代码包与离线软件包：

```bash
# 执行 Github 上的下载脚本
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Vonng/pigsty/master/bin/latest)"

# 或者直接使用 curl 从 GitHub 上下载
curl -L https://github.com/Vonng/pigsty/releases/download/v2.3.1/pigsty-v2.3.1.tgz -o ~/pigsty.tgz                 # 源码包
curl -L https://github.com/Vonng/pigsty/releases/download/v2.3.1/pigsty-pkg-v2.3.1.el9.x86_64.tgz -o /tmp/pkg.tgz  # EL9 离线软件包
curl -L https://github.com/Vonng/pigsty/releases/download/v2.3.1/pigsty-pkg-v2.3.1.el8.x86_64.tgz -o /tmp/pkg.tgz  # EL8 离线软件包
curl -L https://github.com/Vonng/pigsty/releases/download/v2.3.1/pigsty-pkg-v2.3.1.el7.x86_64.tgz -o /tmp/pkg.tgz  # EL7 离线软件包

# 对于中国大陆用户来说，也可以选择从中国 CDN 下载
curl -L https://get.pigsty.cc/v2.3.1/pigsty-v2.3.1.tgz -o ~/pigsty.tgz                 # 源码包
curl -L https://get.pigsty.cc/v2.3.1/pigsty-pkg-v2.3.1.el9.x86_64.tgz -o /tmp/pkg.tgz  # EL9 离线软件包
curl -L https://get.pigsty.cc/v2.3.1/pigsty-pkg-v2.3.1.el8.x86_64.tgz -o /tmp/pkg.tgz  # EL8 离线软件包
curl -L https://get.pigsty.cc/v2.3.1/pigsty-pkg-v2.3.1.el7.x86_64.tgz -o /tmp/pkg.tgz  # EL7 离线软件包
```

</details>

[![asciicast](https://asciinema.org/a/603609.svg)](https://asciinema.org/a/603609)



----------------

## 系统架构

Pigsty 采用模块化设计，有六个主要的默认模块：[`PGSQL`](pgsql)、[`INFRA`](infra)、[`NODE`](node)、[`ETCD`](etcd)、[`REDIS`](redis) 和 [`MINIO`](minio)。

* [`PGSQL`](pgsql)：由 Patroni、Pgbouncer、HAproxy、PgBackrest 等驱动的自治高可用 Postgres 集群。
* [`INFRA`](infra)：本地软件仓库、Prometheus、Grafana、Loki、AlertManager、PushGateway、Blackbox Exporter...
* [`NODE`](node)：调整节点到所需状态、名称、时区、NTP、ssh、sudo、haproxy、docker、promtail...
* [`ETCD`](etcd)：分布式键值存储，用作高可用 Postgres 集群的 DCS：共识选主/配置管理/服务发现。
* [`REDIS`](redis)：Redis 服务器，支持独立主从、哨兵、集群模式，并带有完整的监控支持。
* [`MINIO`](minio)：与 S3 兼容的简单对象存储服务器，可作为 PG数据库备份的可选目的地。

你可以声明式地自由组合它们。如果你想要主机监控，[`INFRA`](infra) 和 [`NODE`](node) 就足够了。
额外的 [`ETCD`](etcd) 和 [`PGSQL`](pgsql) 用于 HA PG 集群，在多个节点上部署它们将自动组成一个高可用集群。
您可以重复使用 pigsty 基础架构并开发您的模块，[`REDIS`](redis) 和 [`MINIO`](minio) 可以作为一个样例。
后续还会有更多的模块加入，例如对 Mongo, MySQL 的支持已经初步提上了日程。

[`install.yml`](https://github.com/Vonng/pigsty/blob/master/install.yml) 剧本将在**当前**节点上安装 [`INFRA`](infra)、[`ETCD`](etcd)、[`PGSQL`](pgsql) 和可选的 [`MINIO`](minio) 模块，
这将为你提供一个功能完备的可观测性技术栈全家桶 (Prometheus、Grafana、Loki、AlertManager、PushGateway、BlackboxExporter 等) ，以及一个内置的 PostgreSQL 单机实例作为 CMDB，也可以开箱即用。 (集群名 `pg-meta`，库名为 `meta`)。
这个节点现在会有完整的自我监控系统、可视化工具集，以及一个自动配置有 PITR 的 Postgres 数据库（单机安装时HA不可用，因为你只有一个节点）。你可以使用此节点作为开发箱、测试、运行演示以及进行数据可视化和分析。或者，还可以把这个节点当作管理节点，部署纳管更多的节点！

详情请参阅 [**系统架构**](arch) 一节.




----------------

## 更多集群

要部署一个使用流复制组建的三节点高可用 PostgreSQL 集群，首先要在配置文件 [`pigsty.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml) 的 `all.children.pg-test` 中进行[定义](https://github.com/Vonng/pigsty/blob/master/pigsty.yml#L54)

```yaml 
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
    10.10.10.13: { pg_seq: 3, pg_role: offline }
  vars:  { pg_cluster: pg-test }
```

定义完后，可以使用[剧本](playbook)将其创建：

```bash
bin/pgsql-add pg-test   # 初始化 pg-test 集群 
```

你可以使用不同的的实例角色，例如 [主库](PGSQL-CONF#读写主库)（primary），[从库](PGSQL-CONF#只读从库)（replica），[离线从库](PGSQL-CONF#读写主库)（offline），[延迟从库](PGSQL-CONF#延迟集群)（delayed），[同步备库](PGSQL-CONF#同步备库)（sync standby）；
以及不同的集群：例如[备份集群](PGSQL-CONF#备份集群)（Standby Cluster），[Citus集群](PGSQL-CONF#citus集群)，甚至是 [Redis](REDIS) / [MinIO](MINIO) / [Etcd](ETCD) 集群，如下所示：


<details><summary>示例：复杂的 PostgreSQL 集群定制</summary>

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

<details><summary>示例：带有延迟从库的安全加固PG集群</summary>

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

<details><summary>示例：Citus 5节点分布式集群</summary>

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

<details><summary>示例：Redis 集群/哨兵/主从</summary>

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

<details><summary>示例：3节点ETCD集群</summary>

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

<details><summary>示例：3节点MinIO部署</summary>

```yaml
minio:
  hosts:
    10.10.10.10: { minio_seq: 1 }
    10.10.10.11: { minio_seq: 2 }
    10.10.10.12: { minio_seq: 3 }
  vars:
    minio_cluster: minio
    minio_data: '/data{1...2}'          # 每个节点使用两块磁盘
    minio_node: '${minio_cluster}-${minio_seq}.pigsty' # 节点名称的模式
    haproxy_services:
      - name: minio                     # [必选] 服务名称，需要唯一
        port: 9002                      # [必选] 服务端口，需要唯一
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

<details><summary>示例：安装Pigsty四节点沙箱</summary>

[![asciicast](https://asciinema.org/a/566220.svg)](https://asciinema.org/a/566220)

</details><br>

详情请参考 [**Pigsty配置**](config) 与 [**PGSQL配置**](pgsql-conf)。




----------------

## 关于

> Pigsty (/ˈpɪɡˌstaɪ/) 是 "**P**ostgreSQL **I**n **G**reat **STY**le" 的缩写，即“全盛状态的PostgreSQL”

文档: https://doc.pigsty.cc/

百科: https://github.com/Vonng/pigsty/wiki

网站: https://pigsty.cc/en/ | https://pigsty.cc/zh/

微信: 搜索 `pigsty-cc` 加入 PGSQL x Pigsty 交流群

Telegram: https://t.me/joinchat/gV9zfZraNPM3YjFh

Discord: https://discord.gg/6nA2fDXt

作者: [Vonng](https://vonng.com/en) ([rh@vonng.com](mailto:rh@vonng.com))

协议: [AGPL-3.0](LICENSE)

版权所有 2018-2023 rh@vonng.com