# Pigsty Dashboards

Pigsty由提供了专业且易用的PostgreSQL监控系统，浓缩了业界监控的最佳实践。

用户可以方便地进行修改与定制；复用监控基础设施，或与其他监控系统相集成。

Pigsty监控面板由几个相对独立的板块组成。

| 应用                  | 说明              |
|---------------------|-----------------|
| [Home](http://demo.pigsty.cc/d/home) | 首页 |
| [`PGSQL`](#PGSQL监控) | PostgreSQL数据库监控 |
| [`REDIS`](#REDIS监控) | Redis数据库监控      |
| [`NODES`](#NODES监控) | 主机节点监控          |
| [`INFRA`](#INFRA监控) | 基础设施监控/日志  |
| [APP](#APP) | 额外加装的应用 |



## HOME

Pigsty的首页提供了对各个板块的导航。

* [HOME](http://demo.pigsty.cc/d/home)



## PGSQL

PostgreSQL监控面板有着自己的层次，自顶向下分别为：

* 全局：关注整个**环境**，大盘全局指标
* 集群：专注单个数据库集群的聚合指标
* 实例：专注单个实例对象：数据库实例，节点，负载均衡器，各类主题面板
* 数据库（对象）：数据库内的活动，表与查询的详细信息

大多数监控面板都可以通过表格，图元进行层级跳转，允许您快速上卷下钻。


|                         Overview                         |                              Cluster                               |                         Instance                         |                            Database                            |
|:--------------------------------------------------------:|:------------------------------------------------------------------:|:--------------------------------------------------------:|:--------------------------------------------------------------:|
| [PGSQL Overview](http://demo.pigsty.cc/d/pgsql-overview) |       [PGSQL Cluster](http://demo.pigsty.cc/d/pgsql-cluster)       | [PGSQL Instance](http://demo.pigsty.cc/d/pgsql-instance) |    [PGSQL Database](http://demo.pigsty.cc/d/pgsql-database)    |
|   [PGSQL Alert](http://demo.pigsty.cc/d/pgsql-alert/)    |       [PGSQL Service](http://demo.pigsty.cc/d/pgsql-service)       |    [PGSQL Node](http://demo.pigsty.cc/d/pgsql-node/)     |      [PGSQL Tables](http://demo.pigsty.cc/d/pgsql-tables)      |
|    [PGSQL Shard](http://demo.pigsty.cc/d/pgsql-shard)    |     [PGSQL Database](http://demo.pigsty.cc/d/pgsql-databases)      |    [PGSQL Proxy](http://demo.pigsty.cc/d/pgsql-proxy)    |       [PGSQL Table](http://demo.pigsty.cc/d/pgsql-table)       |
| [PGSQL MatrixDB](http://demo.pigsty.cc/d/gpsql-overview) |   [PGSQL Replication](http://demo.pigsty.cc/d/pgsql-replication)   |    [PGSQL Xacts](http://demo.pigsty.cc/d/pgsql-xacts)    |       [PGSQL Query](http://demo.pigsty.cc/d/pgsql-query)       |
|                                                          |      [PGSQL Activity](http://demo.pigsty.cc/d/pgsql-activity)      |  [PGSQL Queries](http://demo.pigsty.cc/d/pgsql-queries)  | [PGCAT Table](http://demo.pigsty.cc/d/pgcat-table/pgcat-table) |
|                                                          | [PGSQL Cluster Monly](http://demo.pigsty.cc/d/pgsql-cluster-monly) |  [PGSQL Session](http://demo.pigsty.cc/d/pgsql-session)  |       [PGCAT Query](http://demo.pigsty.cc/d/pgcat-query)       |
|                                                          |                                                                    | [PGCAT Instance](http://demo.pigsty.cc/d/pgcat-instance) |    [PGCAT Database](http://demo.pigsty.cc/d/pgcat-database)    |



## REDIS

REDIS监控分为三个层次：全局总览，单个集群，单个实例

* [Redis Overview](http://demo.pigsty.cc/d/redis-overview)
* [Redis Cluster](http://demo.pigsty.cc/d/redis-cluster)
* [Redis Instance](http://demo.pigsty.cc/d/redis-instance)



## NODES

NODES监控分为三个层次：全局总览，单个节点集群，单个节点

* [Nodes Overview](http://demo.pigsty.cc/d/nodes-overview)
* [Nodes Cluster](http://demo.pigsty.cc/d/nodes-cluster)
* [Nodes Instance](http://demo.pigsty.cc/d/nodes-instance)
* [Nodes Alert](http://demo.pigsty.cc/d/nodes-alert)



## INFRA

INFRA监控用于监控基础设施本身，包含以下Dashboards：

* [Infra Overview](http://demo.pigsty.cc/d/infra-overview)：基础设施概览
* [Logs Instance](http://demo.pigsty.cc/d/logs-instance) ： 查看单个节点上的日志
* [Nodes Alert](http://demo.pigsty.cc/d/nodes-alert) ： 主机告警
* [PGSQL Alert](http://demo.pigsty.cc/d/pgsql-alert/) ： PostgreSQL数据库告警



## APP

Pigsty自带了一个典型的应用 PGLOG，用于分析PG本身的CSV日志样本。

* [PGLOG Overview](http://demo.pigsty.cc/d/pglog-overview)
* [PGLOG Session](http://demo.pigsty.cc/d/pglog-session)

访问 https://github.com/vonng/pigsty-app ，获取更多样例应用。
