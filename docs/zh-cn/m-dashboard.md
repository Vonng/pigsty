## 监控面板

Pigsty由提供了专业且易用的PostgreSQL监控系统，浓缩了业界监控的最佳实践。

用户可以方便地进行修改与定制；复用监控基础设施，或与其他监控系统相集成。



## 监控应用

Pigsty监控面板由几个板块组成

| 应用                  | 说明              |
|---------------------|-----------------|
| [`PGSQL`](#PGSQL监控) | PostgreSQL数据库监控 |
| [`REDIS`](#REDIS监控) | Redis数据库监控      |
| [`NODES`](#NODES监控) | 主机节点监控          |
| [`INFRA`](#INFRA监控) | 基础设施监控/日志  |


## PGSQL监控

PostgreSQL监控面板有着自己的层次，自顶向下分别为：

* 全局：关注整个**环境**，大盘全局指标
* 集群：专注单个数据库集群的聚合指标
* 实例：专注单个实例对象：数据库实例，节点，负载均衡器，各类主题面板
* 数据库（对象）：数据库内的活动，表与查询的详细信息

大多数监控面板都可以通过表格，图元进行跳转。
|            全局             |             集群             |            实例             |           数据库            |
| :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
|        [PGSQL Overview](http://demo.pigsty.cc/d/pgsql-overview)        |  [PGSQL Cluster](http://demo.pigsty.cc/d/pgsql-cluster)  | [PGSQL Instance](http://demo.pigsty.cc/d/pgsql-instance) | [PGSQL Database](http://demo.pigsty.cc/d/pgsql-database) |
| [PGSQL Alert](http://demo.pigsty.cc/d/pgsql-alert/) | [PGSQL Service](http://demo.pigsty.cc/d/pgsql-service) | [PGSQL Node](http://demo.pigsty.cc/d/pgsql-node/) | [PGSQL Tables](http://demo.pigsty.cc/d/pgsql-tables) |
|  | [PGSQL Activity](http://demo.pigsty.cc/d/pgsql-activity) | [PGSQL Proxy](http://demo.pigsty.cc/d/pgsql-proxy) | [PGSQL Table](http://demo.pigsty.cc/d/pgsql-table) |
|  | [PGSQL Replication](http://demo.pigsty.cc/d/pgsql-replication) | [PGSQL Xacts](http://demo.pigsty.cc/d/pgsql-xacts) | [PGSQL Query](http://demo.pigsty.cc/d/pgsql-query) |
|  |  | [PGSQL Queries](http://demo.pigsty.cc/d/pgsql-queries) |  |
|  |  |        [PGSQL Session](http://demo.pigsty.cc/d/pgsql-session)        |        |
| [Home](http://demo.pigsty.cc/d/home) |  | **PGLOG** | **PGCAT** |
|            |  |  [PGLOG Instance](http://demo.pigsty.cc/d/pglog-instance)  | [PGCAT Table](http://demo.pigsty.cc/d/pgcat-table/pgcat-table) |
|  |  | [PGLOG Analysis](http://demo.pigsty.cc/d/pglog-analysis) | [PGCAT Query](http://demo.pigsty.cc/d/pgcat-query) |
|  |  | [PGLOG Session](http://demo.pigsty.cc/d/pglog-session) | [PGCAT Bloat](http://demo.pigsty.cc/d/pgcat-bloat) |


## REDIS

REDIS监控分为三个层次：全局总览，单个集群，单个实例

* Redis Overview
* Redis Cluster
* Redis Instance



## NODES

NODES监控分为三个层次：全局总览，单个节点集群，单个节点

* Nodes Overview
* Nodes Cluster
* Nodes Instance



## NODES

INFRA监控用于监控基础设施本身，包含以下Dashboards：

* Infra Overview：基础设施概览
* Logs Instance ： 查看单个节点上的日志
* Nodes Alert ： 主机告警
* PgSQL Alert ： PostgreSQL数据库告警

