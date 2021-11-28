# Pigsty

## v1.2.0 中文文档

**开箱即用**的**开源**PostgreSQL**发行版**

[![logo](../_media/icon.svg)](/)

> 最新版本: [v1.2.0](https://github.com/Vonng/pigsty/releases/tag/v1.2.0)  |  [Github项目](https://github.com/Vonng/pigsty) | [公开演示](http://home.pigsty.cc)
>
> 文档地址: [英文文档](https://pigsty.cc/) | [中文文档](https://pigsty.cc/#/zh-cn/) | [Github Pages文档](https://vonng.github.io/pigsty/#/)
>
> 执行`make doc`可以在本地浏览器中阅览文档


## Pigsty是什么？

* Pigsty是**开箱即用的PostgreSQL[发行版](#发行版)**

* Pigsty是**全面专业的PostgreSQL[监控系统](#监控系统)**

* Pigsty是**简单易用的PostgreSQL高可用[部署方案](#部署方案)**

* Pigsty是**便捷全能的[本地沙箱](#沙箱环境)与[数据分析可视化环境](#数据分析与可视化)**

* Pigsty是**自由免费的开源软件，基于Apache 2.0协议开源**


![](../_media/what-zh.svg)

## 太长；不看

准备新机器一台：Linux x86_64 CentOS 7.8，配置免密码`sudo`与`ssh`登陆权限，执行以下命令在本机完成Pigsty安装。

```bash
git clone https://github.com/Vonng/pigsty && cd pigsty
./configure
make install
```

安装Pigsty的细节请参考[快速上手](#快速上手)


## 亮点特性

* **开箱即用**的软件系统，一键拉起生产环境所需的功能套件，**开源免费**。
* 全面专业的[监控系统](#监控系统)，基于 [Grafana](https://grafana.com/)、[Prometheus](https://prometheus.io/)与[pg_exporter](https://github.com/Vonng/pg_exporter) 等开源组件。
* 简单易用的[部署方案](#部署方案)，基于[Ansible](https://docs.ansible.com/ansible/latest/index.html)的裸机部署，却提供类似Kubernetes的使用体验。
* [高可用](#高可用集群)数据库集群[架构](c-arch.md)，基于Patroni实现，具有秒级故障自愈能力，久经生产环境考验。集成负载均衡，成员对外表现等价，提供类似分布式数据库的体验。
* 基于DCS的[服务发现](m-discovery.md)与配置管理，维护管理自动化，智能化，无需人工维护元数据。
* 无需互联网访问与代理的[离线安装](t-offline.md)模式，快速、安全、可靠。
* [代码定义](v-config.md)的基础设施，可配置，可定制，可扩展。
* 基于PostgreSQL 14（支持13/12），打包PostGIS，Timescale，Citus等强力扩展。 
* 集成Echarts，Jupyterlab等工具，可作为数据分析与可视化的集成开发环境。
* 架构方案经过长时间大规模的生产环境验证（200余节点 x 64C|400GB|3TB x 2年）
* Pigsty提供基于裸机的**应用运行时**，可用于部署与监控其他数据库与应用，目前还对Redis提供原生部署监控支持

### 发行版

**发行版（Distribution）** 指的是由内核及其一组软件包组成的整体解决方案。例如Linux是一个操作系统内核，而RedHat，Debian，SUSE则是基于此内核的操作系统发行版。

Pigsty将集群部署，扩容缩容，主从复制，故障切换，流量代理，连接池，服务发现，访问控制，监控系统，告警系统，日志采集等生产级成熟**解决方案**封装为发行版，一次性解决在生产环境与各类场景下使用 **世界上最先进的开源关系型数据库 —— [PostgreSQL](https://www.postgresql.org/)** 时会遇到的问题，真正做到开箱即用。

![](../_media/infra.svg)



### 监控系统

监控系统提供了对系统状态的度量，是运维管理工作的基石。

Pigsty带有一个针对大规模数据库集群管理而设计的专业级PostgreSQL监控系统。包括约1200类指标，20+监控面板，上千个监控仪表盘，覆盖了从全局大盘到单个对象的详细信息。与同类产品相比在指标的覆盖率与监控面板丰富程度上一骑绝尘，为专业用户提供无可替代的价值。

![](../_media/overview-monitor.jpg)

一个典型的Pigsty部署可以管理几百套数据库集群，采集上千类指标，管理百万级时间序列，并将其精心组织为上千个监控仪表盘，交织于几十个监控面板中实时呈现。从全局大盘概览，到单个对象（表，查询，索引，函数）的细节指标，如同实时的核磁共振/CT机一般，将整个数据库剖析的清清楚楚，明明白白。

Pigsty监控系统由目前由三个紧密联系的应用共同组成：
  * 收集并呈现监控 **指标（Metrics）** 数据的 `pgsql`
  * 直接浏览数据库系统 **目录（Catalog）** 的 `pgcat`
  * 实时查询搜索分析数据库 **日志（log）** 的 `pglog`

Pigsty监控系统基于业内最佳实践，采用Prometheus、Grafana作为监控基础设施。开源开放，定制便利，可复用，可移植，没有厂商锁定。
Pigsty监控系统可独立使用，监控已有PostgreSQL数据库实例，详情参考[监控系统部署](t-monly.md)。
Pigsty提供的监控管理基础设施可亦可用于其他数据库与应用的监控与管理，例如，Pigsty v1.3 引入了对[Redis部署与监控](t-redis.md)的支持。


### 部署方案

数据库是管理数据的软件，管控系统是管理数据库的软件。

Pigsty内置了一套以Ansible为核心的数据库管控方案，并基于此封装了命令行工具与图形界面。它集成了数据库管理中的核心功能：包括数据库集群的创建，销毁，扩缩容；用户、数据库、服务的创建等。

Pigsty采纳 *Infra as Code* 的设计哲学，使用类似 Kubernetes 的声明式配置，通过大量可选的配置选项对数据库与运行环境进行描述，并通过幂等的预置剧本自动创建所需的数据库集群，提供私有云般的使用体验。

用户只需要通过配置文件或图形界面描述“自己想要什么样的数据库”，而无需关心Pigsty如何去创建或修改它。Pigsty会根据用户的配置文件清单，在几分钟内从裸机节点上创造出所需的数据库集群。

例如，在三台机器上创建一主两从的数据库集群`pg-test`，只需要几行配置与一行命令`pgsql.yml -l pg-test`，即可创建出如下一节所介绍的高可用数据库集群。

![](../_media/provision.jpg)


<details>
<summary>使用更多参数对数据库集群进行定制</summary>

![](../_media/interface.jpg)

```yaml
#----------------------------------#
# cluster: pg-meta (on meta node)  #
#----------------------------------#
# pg-meta is the default SINGLE-NODE pgsql cluster deployed on meta node (10.10.10.10)
# if you have multiple n meta nodes, consider deploying pg-meta as n-node cluster too

pg-meta:                                # required, ansible group name , pgsql cluster name. should be unique among environment
  hosts:                                # `<cluster>.hosts` holds instances definition of this cluster
    10.10.10.10:                        # INSTANCE-LEVEL CONFIG: ip address is the key. values are instance level config entries (dict)
      pg_seq: 1                         # required, unique identity parameter (+integer) among pg_cluster
      pg_role: primary                  # required, pg_role is mandatory identity parameter, primary|replica|offline|delayed
      pg_offline_query: true            # instance with `pg_offline_query: true` will take offline traffic (saga, etl,...)
      # some variables can be overwritten on instance level. e.g: pg_upstream, pg_weight, etc...
    #---------------
    # mandatory                         # all configuration above (`ip`, `pg_seq`, `pg_role`) and `pg_cluster` are mandatory
    #---------------
  vars:                                 # `<cluster>.vars` holds CLUSTER LEVEL CONFIG of this pgsql cluster
    pg_cluster: pg-meta                 # required, pgsql cluster name, unique among cluster, used as namespace of cluster resources

    #---------------
    # optional                          # all configuration below are OPTIONAL for a pgsql cluster (Overwrite global default)
    #---------------
    pg_version: 14                      # pgsql version to be installed (use global version if missing)
    node_tune: tiny                     # node optimization profile: {oltp|olap|crit|tiny}, use tiny for vm sandbox
    pg_conf: tiny.yml                   # pgsql template:  {oltp|olap|crit|tiny}, use tiny for sandbox
    patroni_mode: default               # entering patroni pause mode after bootstrap  {default|pause|remove}
    patroni_watchdog_mode: off          # disable patroni watchdog on meta node        {off|require|automatic}
    pg_lc_ctype: en_US.UTF8             # use en_US.UTF8 locale for i18n char support  (required by `pg_trgm`)

    #---------------
    # biz databases                     # Defining Business Databases (Optional)
    #---------------
    pg_databases:                       # define business databases on this cluster, array of database definition
      # define the default `meta` database
      - name: meta                      # required, `name` is the only mandatory field of a database definition
        baseline: cmdb.sql              # optional, database sql baseline path, (relative path among ansible search path, e.g files/)
        # owner: postgres               # optional, database owner, postgres by default
        # template: template1           # optional, which template to use, template1 by default
        # encoding: UTF8                # optional, database encoding, UTF8 by default. (MUST same as template database)
        # locale: C                     # optional, database locale, C by default.  (MUST same as template database)
        # lc_collate: C                 # optional, database collate, C by default. (MUST same as template database)
        # lc_ctype: C                   # optional, database ctype, C by default.   (MUST same as template database)
        # tablespace: pg_default        # optional, default tablespace, 'pg_default' by default.
        # allowconn: true               # optional, allow connection, true by default. false will disable connect at all
        # revokeconn: false             # optional, revoke public connection privilege. false by default. (leave connect with grant option to owner)
        # pgbouncer: true               # optional, add this database to pgbouncer database list? true by default
        comment: pigsty meta database   # optional, comment string for this database
        connlimit: -1                   # optional, database connection limit, default -1 disable limit
        schemas: [pigsty]               # optional, additional schemas to be created, array of schema names
        extensions:                     # optional, additional extensions to be installed: array of schema definition `{name,schema}`
          - { name: adminpack, schema: pg_catalog }    # install adminpack to pg_catalog
          - { name: postgis, schema: public }          # if schema is omitted, extension will be installed according to search_path.
          - { name: timescaledb }                      # some extensions are not relocatable, you can just omit the schema part

      # define an additional database named grafana & prometheus (optional)
      # - { name: grafana,    owner: dbuser_grafana    , revokeconn: true , comment: grafana    primary database }
      # - { name: prometheus, owner: dbuser_prometheus , revokeconn: true , comment: prometheus primary database , extensions: [{ name: timescaledb }]}

    #---------------
    # biz users                         # Defining Business Users (Optional)
    #---------------
    pg_users:                           # define business users/roles on this cluster, array of user definition
      # define admin user for meta database (This user are used for pigsty app deployment by default)
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
      - {name: dbuser_view , password: DBUser.Viewer  ,pgbouncer: true ,roles: [dbrole_readonly], comment: read-only viewer for meta database}

      # define additional business users for prometheus & grafana (optional)
      - {name: dbuser_grafana    , password: DBUser.Grafana    ,pgbouncer: true ,roles: [dbrole_admin], comment: admin user for grafana database }
      - {name: dbuser_prometheus , password: DBUser.Prometheus ,pgbouncer: true ,roles: [dbrole_admin], comment: admin user for prometheus database , createrole: true }

    #---------------
    # hba rules                                         # Defining extra HBA rules on this cluster (Optional)
    #---------------
    pg_hba_rules_extra:                                 # Extra HBA rules to be installed on this cluster
      - title: reject grafana non-local access          # required, rule title (used as hba description & comment string)
        role: common                                    # required, which roles will be applied? ('common' applies to all roles)
        rules:                                          # required, rule content: array of hba string
          - local   grafana         dbuser_grafana                          md5
          - host    grafana         dbuser_grafana      127.0.0.1/32        md5
          - host    grafana         dbuser_grafana      10.10.10.10/32      md5

    vip_mode: l2                        # setup a level-2 vip for cluster pg-meta
    vip_address: 10.10.10.2             # virtual ip address that binds to primary instance of cluster pg-meta
    vip_cidrmask: 8                     # cidr network mask length
    vip_interface: eth1                 # interface to add virtual ip

```

</details>


此外，除了PostgreSQL外，从Pigsty v1.3开始，还提供了对Redis部署与监控的支持，更多的数据库类型将在后续逐渐加入。
<details>
<summary>样例：定制不同类型的Redis集群</summary>

```bash
#----------------------------------#
# sentinel example                 #
#----------------------------------#
redis-sentinel:
  hosts:
    10.10.10.10:
      redis_node: 1
      redis_instances:  { 6001 : {} ,6002 : {} , 6003 : {} }
  vars:
    redis_cluster: redis-sentinel
    redis_mode: sentinel
    redis_max_memory: 128MB

#----------------------------------#
# cluster example                  #
#----------------------------------#
redis-cluster:
  hosts:
    10.10.10.11:
      redis_node: 1
      redis_instances: { 6501 : {} ,6502 : {} ,6503 : {} ,6504 : {} ,6505 : {} ,6506 : {} }
    10.10.10.12:
      redis_node: 2
      redis_instances: { 6501 : {} ,6502 : {} ,6503 : {} ,6504 : {} ,6505 : {} ,6506 : {} }
  vars:
    redis_cluster: redis-cluster        # name of this redis 'cluster'
    redis_mode: cluster                 # standalone,cluster,sentinel
    redis_max_memory: 64MB              # max memory used by each redis instance
    redis_mem_policy: allkeys-lru       # memory eviction policy

#----------------------------------#
# standalone example               #
#----------------------------------#
redis-standalone:
  hosts:
    10.10.10.13:
      redis_node: 1
      redis_instances:
        6501: {}
        6502: { replica_of: '10.10.10.13 6501' }
        6503: { replica_of: '10.10.10.13 6501' }
  vars:
    redis_cluster: redis-standalone     # name of this redis 'cluster'
    redis_mode: standalone              # standalone,cluster,sentinel
    redis_max_memory: 64MB              # max memory used by each redis instance
```

</details>


### 高可用集群

Pigsty创建的数据库集群是**分布式、高可用**的[数据库集群](c-arch.md#数据库集群)。只要集群中有任意实例存活，集群就可以对外提供完整的[读写服务](c-service.md#primary服务)与[只读服务](c-service.md#replica服务)。

数据库集群中的每个数据库实例在使用上都是幂等的，任意实例都可以通过内建负载均衡组件提供完整的读写服务。数据库集群可以自动进行故障检测与主从切换，普通故障能在几秒到几十秒内自愈，且期间只读流量不受影响。

Pigsty的高可用架构久经生产环境考验，Pigsty使用Patroni + Consul（`etcd`为可选）进行故障检测、Fencing、以及自动切换，通过HAProxy、VIP或DNS实现流量的自动切换，以极小的复杂度实现了完整的高可用方案，让主从架构的数据库用出了分布式数据库的体验。

![](../_media/access.svg)


Pigsty允许用户通过配置灵活定义[服务](c-service.md)，并提供了多种可选的[数据库接入](c-access.md)模式。
例如Pigsty沙箱默认使用DNS+二层VIP+Haproxy的接入层方案（如上图所示）：Haproxy**幂等**地部署在集群的每个实例上，任何一个或多个Haproxy实例都可以作为集群的负载均衡器，并通过健康检查进行流量分发，对外屏蔽集群成员的区别。
而同样的功能亦可通过四层VIP实现，用户可根据自身基础设施情况灵活选择。



### 沙箱环境

使用PostgreSQL不仅仅是企业，还有许许多多多个人用户：用于软件的开发、测试、实验，演示；或者是数据的清洗，分析，可视化，存储。然而如何搭建环境往往成为用户面前的第一道拦路虎。

尽管Pigsty是针对大规模生产环境PostgreSQL数据库管理的解决方案，但它也可以完整运行于1核1GB的微型虚拟机中。
Pigsty可以在您的笔记本或PC机上一键拉起完整的生产级PostgreSQL[沙箱](s-sandbox.md)，这是通过Vagrant调用Virtualbox自动创建虚拟机来实现的。

默认沙箱配置为2核4GB的单节点，带有各类实用工具，可服务于各种用途。此外还有四节点版本的完整版沙箱，可用于充分展现Pigsty高可用架构与监控系统的能力，或用于生产仿真环境搭建。

![](../_media/sandbox.svg)

<details>
<summary>沙箱所需机器规格</summary>

**系统要求**

* Linux内核，x86_64处理器架构
* 使用 CentOS 7 / RedHat 7 / Oracle Linux 7 或其他等效操作系统发行版
* 强烈推荐使用 CentOS 7.8.2003 x86_64 ，这是经过长时间生产环境的测试的操作系统环境

**单节点基本规格**

* 最低规格：1核，1GB （容易OOM，建议内存至少2GB）
* 推荐规格：2核，4GB （沙箱默认配置）
* 将部署一个单机PostgreSQL实例`pg-meta-1`
* 在沙箱中，该节点的IP固定为`10.10.10.10`

**四节点基本规格**

* 管理节点要求同**单节点**
* 将部署一个额外的三节点PostgreSQL数据库集群`pg-test`
* 普通数据库节点，最低规格：1核，1GB，建议至少使用2GB内存。

</details>



### 数据分析与可视化

Pigsty带有完善的数据分析工具集，如Jupyterlab，IPython，PostgreSQL，Grafana，Echarts。用户可以将Pigsty单机沙箱用作数据分析与可视化的集成开发环境：使用SQL与Python进行数据处理，并通过Grafana与Echarts快速制作交互式数据应用。

Pigsty自带有两个样例：新冠疫情数据可视化 [`covid`](http://demo.pigsty.cc/d/covid-overview)，全球地表气象站数据查询 [`isd`](http://demo.pigsty.cc/d/isd-overview) 。 

![](../_media/overview-covid.jpg)

![](../_media/overview-isd.jpg)



## 快速上手

拉起Pigsty最少只需要三条命令：**下载**，**配置**与**安装**，详见[快速开始](s-install.md)。

![](../_media/how-zh.svg)

准备新机器一台：Linux x86_64 CentOS 7.8，配置免密码`sudo`与`ssh`登陆权限。

```bash
# 离线下载
# curl -SL https://github.com/Vonng/pigsty/releases/download/v1.2.0/pigsty.tgz -o ~/pigsty.tgz  
# curl -SL https://github.com/Vonng/pigsty/releases/download/v1.2.0/pkg.tgz    -o /tmp/pkg.tgz

# 常规安装
git clone https://github.com/Vonng/pigsty && cd pigsty
./configure
make install
```

如需运行[本地沙箱](s-sandbox.md)，可运行以下命令（MacOS）

```bash
make deps   # 安装homebrew，并通过homebrew安装vagrant与virtualbox（需重启）
make dns    # 向本机/etc/hosts写入静态域名 (需sudo输入密码)
make start  # 使用Vagrant拉起单个meta节点 (start4则为4个节点)
make demo   # 使用单节点Demo配置并安装    (demo4则为4节点demo)
```

接下来，您可以参考 [快速上手-简介](s-intro.md) 探索更多关于Pigsty的内容。 


## Demo

[http://demo.pigsty.cc](http://demo.pigsty.cc) 提供了公开的演示。您可以在这里浏览**Pigsty监控系统**提供的功能。Pigsty自带有两个有趣的数据应用：WHO新冠疫情数据大盘：[`covid`](http://demo.pigsty.cc/d/covid-overview)，与全球地表气象站历史数据查询：[`isd`](http://demo.pigsty.cc/d/isd-overview)。


Pigsty部署方案与其他功能则可以通过[**沙箱环境**](s-sandbox.md)在本机体验，教程 [【使用Postgres作为Grafana后端数据库】](t-grafana-upgrade.md)将会以一个具体的例子介绍Pigsty提供的管控功能。


## 协议

Pigsty基于Apache 2.0协议开源，可以免费用于商业目的。如需额外支持，请联系[作者](https://vonng.com/en/))

改装与衍生需遵守[Apache License 2.0 ](https://raw.githubusercontent.com/Vonng/pigsty/master/LICENSE)的显著声明条款。


## 关于

> Pigsty (/ˈpɪɡˌstaɪ/)是"PostgreSQL In Graphic STYle"的缩写

作者: [冯若航](https://vonng.com/en/) ([rh@vonng.com](mailto:rh@vonng.com))

协议: [Apache 2.0 License](https://github.com/Vonng/Capslock/blob/master/LICENSE)

备案: [浙ICP备15016890-2号](https://beian.miit.gov.cn/)
