# Pigsty

> "**P**ostgreSQL **I**n **G**reat **STY**le": **P**ostgres, **I**nfras, **G**raphics, **S**ervice, **T**oolbox, it's all **Y**ours.
>
> —— **开箱即用、本地优先的 PostgreSQL 发行版，开源 RDS 替代**
>
> [网站](https://pigsty.io/zh/) | [仓库](https://github.com/Vonng/pigsty) | [演示](https://demo.pigsty.cc) | [博客](https://pigsty.cc/zh/blog) | [论坛](https://github.com/Vonng/pigsty/discussions) | [GPTs](https://chat.openai.com/g/g-y0USNfoXJ-pigsty-consul) | [微信公众号](https://mp.weixin.qq.com/s/-E_-HZ7LvOze5lmzy3QbQA) | [Website](https://pigsty.cc/zh/)
>
> [快速上手](INSTALL) 最新版本的 Pigsty [v2.7.0](https://github.com/Vonng/pigsty/releases/tag/v2.7.0)：`bash -c "$(curl -fsSL https://get.pigsty.cc/install)"`


----------------

## 功能特性

> Pigsty 提出以下六条 [**价值主张**](FEATURE#价值主张) ，更多详情请参阅 [**功能特性**](FEATURE) 。

[**可扩展性**](https://repo.pigsty.cc/img/pigsty-extension.jpg)： 强力[**扩展**](PGSQL-EXTENSION)开箱即用：深度整合**PostGIS**, **TimescaleDB**, **Citus**, **PGVector**, **ParadeDB**, **Hydra**, **AGE** , **PGML** 等 [**255+**](PGSQL-EXTENSION#扩展列表) PG生态插件。

[**可靠性**](https://repo.pigsty.cc/img/pigsty-arch.jpg)：快速创建[**高可用**](PGSQL-ARCH#高可用)、故障自愈的 [**PostgreSQL**](PGSQL) 集群，自动预置的[**时间点恢复**](PGSQL-ARCH#时间点恢复)、[**访问控制**](PGSQL-ACL)、自签名 [**CA**](PARAM#ca) 与 [**SSL**](SECURITY)，确保数据坚如磐石。

[**可观测性**](https://repo.pigsty.cc/img/pigsty-dashboard.jpg)： 基于 [**Prometheus**](INFRA#prometheus) & [**Grafana**](INFRA#grafana) 现代可观测性技术栈，提供惊艳的监控最佳实践。模块化设计，可独立使用：[**画廊**](https://github.com/Vonng/pigsty/wiki/Gallery) & [**Demo**](https://demo.pigsty.cc)。

[**可用性**](https://repo.pigsty.cc/img/pgsql-ha.jpg)：交付稳定可靠，自动路由，事务池化、读写分离的高性能数据库[**服务**](PGSQL-SVC#默认服务)，通过 HAProxy，Pgbouncer，VIP 提供灵活的[**接入**](PGSQL-SVC#接入服务)模式。

[**可维护性**](https://repo.pigsty.cc/img/pigsty-iac.jpg)：[**简单易用**](INSTALL)，[**基础设施即代码**](PGSQL-CONF)，[**管理SOP预案**](PGSQL-ADMIN)，自动调参，本地软件仓库，[**Vagrant**](PROVISION#vagrant) 沙箱与 [**Terraform**](PROVISION#terraform) 模板，不停机[**迁移**](PGSQL-MIGRATION)方案。

[**可组合性**](https://repo.pigsty.cc/img/pigsty-sandbox.jpg)：[**模块化**](ARCH#模块)架构设计，可复用的 [**Infra**](INFRA)，多种可选功能模块：[**Redis**](REDIS), [**MinIO**](MINIO), [**ETCD**](ETCD), [**FerretDB**](MONGO), [**DuckDB**](https://github.com/Vonng/pigsty/tree/master/app/duckdb), [**Supabase**](https://github.com/Vonng/pigsty/tree/master/app/supabase), [**Docker**](APP) 应用。

[![pigsty-banner](https://repo.pigsty.cc/img/pigsty-banner.jpg)](FEATURE#价值主张)



----------------

## 快速上手

> Pigsty可以一键安装! 详情请参阅 [**快速上手**](INSTALL)。

[准备](https://pigsty.io/docs/setup/prepare/) 一个装有[兼容](#兼容性)操作系统的 Linux x86_64 全新节点，
使用带有免密 ssh/sudo 权限的管理员用户执行 [`install`](https://github.com/Vonng/pigsty/blob/master/bin/install) 安装脚本 

```bash
bash -c "$(curl -fsSL https://get.pigsty.cc/install)"
cd ~/pigsty; ./bootstrap; ./configure; ./install.yml;
```

安装完成后，您可以通过域名或`80/443`端口通过 Nginx 访问 [WEB界面](INFRA#概览)，通过 `5432` 端口[访问](PGSQL-SVC#单机用户)默认的 PostgreSQL 数据库[服务](PGSQL-SVC#服务概述)。


<details><summary>安装脚本输出结果</summary>

```bash
$ bash -c "$(curl -fsSL https://get.pigsty.cc/install)"
[v2.7.0] ===========================================
$ curl -fsSL https://pigsty.cc/install | bash
[Site] https://pigsty.io
[Demo] https://demo.pigsty.cc
[Repo] https://github.com/Vonng/pigsty
[Docs] https://pigsty.io/docs/setup/install
[Download] ===========================================
[ OK ] version = v2.7.0 (from default)
curl -fSL https://get.pigsty.cc/v2.7.0/pigsty-v2.7.0.tgz -o /tmp/pigsty-v2.7.0.tgz
########################################################################### 100.0%
[ OK ] md5sums = some_random_md5_hash_value_here_  /tmp/pigsty-v2.7.0.tgz
[Install] ===========================================
[ OK ] install = /home/vagrant/pigsty, from /tmp/pigsty-v2.7.0.tgz
[Resource] ===========================================
[HINT] rocky 8  have [OPTIONAL] offline package available: https://pigsty.io/docs/setup/offline
curl -fSL https://github.com/Vonng/pigsty/releases/download/v2.7.0/pigsty-pkg-v2.7.0.el8.x86_64.tgz -o /tmp/pkg.tgz
curl -fSL https://get.pigsty.cc/v2.7.0/pigsty-pkg-v2.7.0.el8.x86_64.tgz -o /tmp/pkg.tgz # or use alternative CDN
[TodoList] ===========================================
cd /home/vagrant/pigsty
./bootstrap      # [OPTIONAL] install ansible & use offline package
./configure      # [OPTIONAL] preflight-check and config generation
./install.yml    # install pigsty modules according to your config.
[Complete] ===========================================
```

</details>


<details><summary>Git检出安装</summary>

你也可以使用 `git` 来下载安装 Pigsty 源代码，请务必检出特定版本使用，不要使用默认的 `master` 分支。

```bash
git clone https://github.com/Vonng/pigsty;
cd pigsty; git checkout v2.7.0
```

</details>


<details><summary>直接下载</summary>

您还可以直接从 GitHub 发布页面下载源代码包与[离线软件包](INSTALL#离线软件包)：

```bash
# 直接使用 curl 从 GitHub Release 下载
curl -L https://github.com/Vonng/pigsty/releases/download/v2.7.0/pigsty-v2.7.0.tgz -o ~/pigsty.tgz     # Pigsty 源码包
curl -L https://github.com/Vonng/pigsty/releases/download/v2.7.0/pigsty-pkg-v2.7.0.debian12.x86_64.tgz -o /tmp/pkg.tgz  # 离线软件包 Debian 12    (12.4)
curl -L https://github.com/Vonng/pigsty/releases/download/v2.7.0/pigsty-pkg-v2.7.0.el8.x86_64.tgz      -o /tmp/pkg.tgz  # 离线软件包 Rocky 8      (8.9)
curl -L https://github.com/Vonng/pigsty/releases/download/v2.7.0/pigsty-pkg-v2.7.0.ubuntu22.x86_64.tgz -o /tmp/pkg.tgz  # 离线软件包 Ubuntu 22.04 (22.04.3)

# 对于中国大陆用户来说，也可以选择从中国 CDN 下载
curl -L https://get.pigsty.cc/v2.7.0/pigsty-v2.7.0.tgz -o ~/pigsty.tgz # 源码包
curl -L https://get.pigsty.cc/v2.7.0/pigsty-pkg-v2.7.0.debian12.x86_64.tgz -o /tmp/pkg.tgz  # 离线软件包 Debian 12    (12.4)
curl -L https://get.pigsty.cc/v2.7.0/pigsty-pkg-v2.7.0.el8.x86_64.tgz      -o /tmp/pkg.tgz  # 离线软件包 Rocky 8      (8.9)
curl -L https://get.pigsty.cc/v2.7.0/pigsty-pkg-v2.7.0.ubuntu22.x86_64.tgz -o /tmp/pkg.tgz  # 离线软件包 Ubuntu 22.04 (22.04.3)
```

请注意，离线软件包是与操作系统**小版本**相关的！如果您的操作系统小版本与上述之不同，例如 7.6，8.6，9.1 等，请考虑不使用离线软件包，直接执行在线安装。

</details>

----------------

**样例：在 Ubuntu 22.04 节点上，在线单机安装流程**

[![asciicast](https://asciinema.org/a/659640.svg)](https://asciinema.org/a/659640)

<details><summary>样例：在 EL8 节点上，使用离线软件包完成安装</summary>

[![asciicast](https://asciinema.org/a/659637.svg)](https://asciinema.org/a/659637)

</details>



----------------

## 系统架构

Pigsty 采用模块化设计，有六个主要的 [模块](https://pigsty.cc/zh/docs/about/module/)：[`PGSQL`](PGSQL)、[`INFRA`](INFRA)、[`NODE`](NODE)、[`ETCD`](ETCD)、[`REDIS`](REDIS) 和 [`MINIO`](MINIO)。

* [`PGSQL`](PGSQL)：由 Patroni、Pgbouncer、HAproxy、PgBackrest 等驱动的自治高可用 Postgres 集群。
* [`INFRA`](INFRA)：本地软件仓库、Prometheus、Grafana、Loki、AlertManager、PushGateway、Blackbox Exporter...
* [`NODE`](NODE)：调整节点到所需状态、名称、时区、NTP、ssh、sudo、haproxy、docker、promtail...
* [`ETCD`](ETCD)：分布式键值存储，用作高可用 Postgres 集群的 DCS：共识选主/配置管理/服务发现。
* [`REDIS`](REDIS)：Redis 服务器，支持独立主从、哨兵、集群模式，并带有完整的监控支持。
* [`MINIO`](MINIO)：与 S3 兼容的简单对象存储服务器，可作为 PG数据库备份的可选目的地。

你可以声明式地自由组合它们。如果你想要主机监控，[`INFRA`](INFRA) 和 [`NODE`](NODE) 就足够了。
额外的 [`ETCD`](ETCD) 和 [`PGSQL`](PGSQL) 用于 HA PG 集群，在多个节点上部署它们将自动组成一个高可用集群。
您可以重复使用 pigsty 基础架构并开发您的模块，[`REDIS`](REDIS) 和 [`MINIO`](MINIO) 可以作为一个样例。
后续还会有更多的模块加入，例如对 Mongo, MySQL 的支持已经初步提上了日程。

[`install.yml`](https://github.com/Vonng/pigsty/blob/master/install.yml) 剧本将在**当前**节点上安装 [`INFRA`](INFRA)、[`ETCD`](ETCD)、[`PGSQL`](PGSQL) 和可选的 [`MINIO`](MINIO) 模块，
这将为你提供一个功能完备的可观测性技术栈全家桶 (Prometheus、Grafana、Loki、AlertManager、PushGateway、BlackboxExporter 等) ，以及一个内置的 PostgreSQL 单机实例作为 CMDB，也可以开箱即用。 (集群名 `pg-meta`，库名为 `meta`)。
这个节点现在会有完整的自我监控系统、可视化工具集，以及一个自动配置有 PITR 的 Postgres 数据库（单机安装时HA不可用，因为你只有一个节点）。你可以使用此节点作为开发箱、测试、运行演示以及进行数据可视化和分析。或者，还可以把这个节点当作管理节点，部署纳管更多的节点！

[![pigsty-arch.jpg](https://repo.pigsty.cc/img/pigsty-arch.jpg)](ARCH)




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

定义完后，可以使用[剧本](PLAYBOOK)将其创建：

```bash
bin/pgsql-add pg-test   # 初始化 pg-test 集群 
```

[![pgsql-ha.jpg](https://repo.pigsty.cc/img/pgsql-ha.jpg)](PGSQL-ARCH)

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
    pg_libs: 'citus, timescaledb, pg_stat_statements, auto_explain' # citus will be added by patroni automatically
    pg_extensions:
      - postgis34_${ pg_version }* timescaledb-2-postgresql-${ pg_version }* pgvector_${ pg_version }* citus_${ pg_version }*
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

详情请参考 [**Pigsty配置**](CONFIG) 与 [**PGSQL配置**](PGSQL-CONF)。



----------------

## 兼容性

Pigsty 不使用任何虚拟化容器化技术，直接运行于裸操作系统上。支持的操作系统包括 EL 7/8/9 (RHEL, Rocky, CentOS, Alma, Oracle, Anolis,...)，Ubuntu 20.04 / 22.04 & Debian 11/12。
其中 EL 8/9 是我们长期支持的操作系统，而 Ubuntu/Debian 系统的支持是在近期的 v2.5 版本引入，两者之间的主要差别是，软件包名有显著差异，另外默认可用的 PostgreSQL 扩展插件列表略有不同。

我们强烈建议使用 **RockyLinux 8.9**， **Debian 12**，以及 **Ubuntu 22.04 LTS** 作为安装 Pigsty 的操作系统，我们针对这三个发行版预先准备了[离线软件包](INSTALL#离线软件包)。
可以确保在没有互联网访问的情况下也能稳定可靠丝滑地完成安装。使用其他操作系统发行版首次安装时，通常需要您有互联网访问，以便下载并构建本地 YUM/APT 软件仓库。

PostgreSQL 16 是 Pigsty 当前主要支持的数据库大版本，使用 Pigsty 部署管理 12 ～ 15 也是可行的，但需对配置文件进行少许变更。
如果您有对兼容性的高级需求，例如使用特定操作系统发行版、支持特定版本的 PostgreSQL，或者需要咨询答疑与支持，我们也提供[商业支持](SUPPORT)选项。



----------------

## 关于

文档: https://pigsty.cc/zh/

网站: https://pigsty.io/ | https://pigsty.cc/zh/

微信: 搜索 `pigsty-cc` 加入 PGSQL x Pigsty 交流群

Telegram: https://t.me/joinchat/gV9zfZraNPM3YjFh

Discord: https://discord.gg/j5pG8qfKxU

作者: [Vonng](https://vonng.com/en) ([rh@vonng.com](mailto:rh@vonng.com))

协议: [AGPL-3.0](LICENSE)

版权所有 2018-2024 rh@vonng.com