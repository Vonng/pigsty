# PostgreSQL 监控仪表盘

> Pigsty 为 PostgreSQL 提供了诸多开箱即用的 Grafana 监控仪表盘： [Demo](https://demo.pigsty.cc/d/pgsql-overview) & [Gallery](https://github.com/Vonng/pigsty/wiki/Gallery)。

在 Pigsty 中共有 26 个与 PostgreSQL 相关的监控面板，按照层次分为 总览，集群，实例，数据库四大类，按照数据来源又分为 [PGSQL](#总览)，[PGCAT](#pgcat)，[PGLOG](#pglog) 三大类。

![pigsty-dashboard.jpg](https://repo.pigsty.cc/img/pigsty-dashboard.jpg)

----------------

## 总览

|                            总览                             |                               集群                                |                             实例                              |                            数据库                            |
|:---------------------------------------------------------:|:---------------------------------------------------------------:|:-----------------------------------------------------------:|:---------------------------------------------------------:|
| [PGSQL Overview](https://demo.pigsty.cc/d/pgsql-overview) |     [PGSQL Cluster](https://demo.pigsty.cc/d/pgsql-cluster)     |  [PGSQL Instance](https://demo.pigsty.cc/d/pgsql-instance)  | [PGSQL Database](https://demo.pigsty.cc/d/pgsql-database) |
|    [PGSQL Alert](https://demo.pigsty.cc/d/pgsql-alert)    |     [PGRDS Cluster](https://demo.pigsty.cc/d/pgrds-cluster)     |  [PGRDS Instance](https://demo.pigsty.cc/d/pgrds-instance)  | [PGCAT Database](https://demo.pigsty.cc/d/pgcat-database) |
|    [PGSQL Shard](https://demo.pigsty.cc/d/pgsql-shard)    |    [PGSQL Activity](https://demo.pigsty.cc/d/pgsql-activity)    |  [PGCAT Instance](https://demo.pigsty.cc/d/pgcat-instance)  |   [PGSQL Tables](https://demo.pigsty.cc/d/pgsql-tables)   |
|                                                           | [PGSQL Replication](https://demo.pigsty.cc/d/pgsql-replication) |   [PGSQL Persist](https://demo.pigsty.cc/d/pgsql-persist)   |    [PGSQL Table](https://demo.pigsty.cc/d/pgsql-table)    |
|                                                           |     [PGSQL Service](https://demo.pigsty.cc/d/pgsql-service)     |     [PGSQL Proxy](https://demo.pigsty.cc/d/pgsql-proxy)     |    [PGCAT Table](https://demo.pigsty.cc/d/pgcat-table)    |
|                                                           |   [PGSQL Databases](https://demo.pigsty.cc/d/pgsql-databases)   | [PGSQL Pgbouncer](https://demo.pigsty.cc/d/pgsql-pgbouncer) |    [PGSQL Query](https://demo.pigsty.cc/d/pgsql-query)    |
|                                                           |     [PGSQL Patroni](https://demo.pigsty.cc/d/pgsql-patroni)     |   [PGSQL Session](https://demo.pigsty.cc/d/pgsql-session)   |    [PGCAT Query](https://demo.pigsty.cc/d/pgcat-query)    |
|                                                           |                                                                 |     [PGSQL Xacts](https://demo.pigsty.cc/d/pgsql-xacts)     |    [PGCAT Locks](https://demo.pigsty.cc/d/pgcat-locks)    |
|                                                           |                                                                 |  [PGSQL Exporter](https://demo.pigsty.cc/d/pgsql-exporter)  |   [PGCAT Schema](https://demo.pigsty.cc/d/pgcat-schema)   |


**概览**

- [pgsql-overview](https://demo.pigsty.cc/d/pgsql-overview) : PGSQL模块的主仪表板
- [pgsql-alert](https://demo.pigsty.cc/d/pgsql-alert) : PGSQL的全局关键指标和警报事件
- [pgsql-shard](https://demo.pigsty.cc/d/pgsql-shard) : 关于水平分片的PGSQL集群的概览，例如 citus / gpsql 集群

**集群**

- [pgsql-cluster](https://demo.pigsty.cc/d/pgsql-cluster): 一个PGSQL集群的主仪表板
- [pgrds-cluster](https://demo.pigsty.cc/d/pgrds-cluster): PGSQL Cluster 的RDS版本，专注于所有 PostgreSQL 本身的指标
- [pgsql-activity](https://demo.pigsty.cc/d/pgsql-activity): 关注PGSQL集群的会话/负载/QPS/TPS/锁定情况
- [pgsql-replication](https://demo.pigsty.cc/d/pgsql-replication): 关注PGSQL集群复制、插槽和发布/订阅。
- [pgsql-service](https://demo.pigsty.cc/d/pgsql-service): 关注PGSQL集群服务、代理、路由和负载均衡。
- [pgsql-databases](https://demo.pigsty.cc/d/pgsql-databases): 关注所有实例的数据库CRUD、慢查询和表统计信息。
- [pgsql-patroni](https://demo.pigsty.cc/d/pgsql-databases): 关注集群高可用状态，Patroni组件状态

**实例**

- [pgsql-instance](https://demo.pigsty.cc/d/pgsql-instance): 单个PGSQL实例的主仪表板
- [pgrds-instance](https://demo.pigsty.cc/d/pgrds-instance): PGSQL Instance 的RDS版本，专注于所有 PostgreSQL 本身的指标
- [pgcat-instance](https://demo.pigsty.cc/d/pgcat-instance): 直接从数据库目录获取的实例信息
- [pgsql-proxy](https://demo.pigsty.cc/d/pgsql-proxy): 单个haproxy负载均衡器的详细指标
- [pgsql-pgbouncer](https://demo.pigsty.cc/d/pgsql-pgbouncer): 单个Pgbouncer连接池实例中的指标总览
- [pgsql-persist](https://demo.pigsty.cc/d/pgsql-persist): 持久性指标：WAL、XID、检查点、存档、IO
- [pgsql-session](https://demo.pigsty.cc/d/pgsql-session): 单个实例中的会话和活动/空闲时间的指标
- [pgsql-xacts](https://demo.pigsty.cc/d/pgsql-xacts): 关于事务、锁、TPS/QPS相关的指标
- [pgsql-exporter](https://demo.pigsty.cc/d/pgsql-exporter): Postgres 与 Pgbouncer 监控组件自我监控指标



**数据库**

- [pgsql-database](https://demo.pigsty.cc/d/pgsql-database): 单个PGSQL数据库的主仪表板
- [pgcat-database](https://demo.pigsty.cc/d/pgcat-database): 直接从数据库目录获取的数据库信息
- [pgsql-tables](https://demo.pigsty.cc/d/pgsql-tables) : 单个数据库内的表/索引访问指标
- [pgsql-table](https://demo.pigsty.cc/d/pgsql-table): 单个表的详细信息（QPS/RT/索引/序列...）
- [pgcat-table](https://demo.pigsty.cc/d/pgcat-table): 直接从数据库目录获取的单个表的详细信息（统计/膨胀...）
- [pgsql-query](https://demo.pigsty.cc/d/pgsql-query): 单个查询的详细信息（QPS/RT）
- [pgcat-query](https://demo.pigsty.cc/d/pgcat-query): 直接从数据库目录获取的单个查询的详细信息（SQL/统计）
- [pgcat-schema](https://demo.pigsty.cc/d/pgcat-schema): 直接从数据库目录获取关于模式的信息（表/索引/序列...）
- [pgcat-locks](https://demo.pigsty.cc/d/pgcat-locks): 直接从数据库目录获取的关于活动与锁等待的信息


-------------------

## 总览

[PGSQL Overview](https://demo.pigsty.cc/d/pgsql-overview)：PGSQL模块的主仪表板

<details><summary>PGSQL Overview</summary>

[![pgsql-overview.jpg](https://repo.pigsty.cc/img/pgsql-overview.jpg)](https://demo.pigsty.cc/d/pgsql-overview)

</details>


[PGSQL Alert](https://demo.pigsty.cc/d/pgsql-alert)：PGSQL 全局核心指标总览与告警事件一览

<details><summary>PGSQL Alert</summary>

[![pgsql-alert.jpg](https://repo.pigsty.cc/img/pgsql-alert.jpg)](https://demo.pigsty.cc/d/pgsql-alert)

</details>


[PGSQL Shard](https://demo.pigsty.cc/d/pgsql-shard)：展示一个PGSQL 水平分片集群内的横向指标对比：例如 CITUS / GPSQL 集群。

<details><summary>PGSQL Shard</summary>

[![pgsql-shard.jpg](https://repo.pigsty.cc/img/pgsql-shard.jpg)](https://demo.pigsty.cc/d/pgsql-shard)

</details>



-------------------

## 集群

[PGSQL Cluster](https://demo.pigsty.cc/d/pgsql-cluster)：一个PGSQL集群的主仪表板

<details><summary>PGSQL Cluster</summary>

[![pgsql-cluster.jpg](https://repo.pigsty.cc/img/pgsql-cluster.jpg)](https://demo.pigsty.cc/d/pgsql-cluster)

</details>


[PGRDS Cluster](https://demo.pigsty.cc/d/pgrds-cluster)：PGSQL Cluster 的RDS版本，专注于所有 PostgreSQL 本身的指标

<details><summary>PGRDS Cluster</summary>

[![pgrds-cluster.jpg](https://repo.pigsty.cc/img/pgrds-cluster.jpg)](https://demo.pigsty.cc/d/pgrds-cluster)

</details>


[PGSQL Service](https://demo.pigsty.cc/d/pgsql-service)：关注PGSQL集群服务、代理、路由和负载均衡。

<details><summary>PGSQL Service</summary>

[![pgsql-service.jpg](https://repo.pigsty.cc/img/pgsql-service.jpg)](https://demo.pigsty.cc/d/pgsql-service)

</details>

[PGSQL Activity](https://demo.pigsty.cc/d/pgsql-activity)：关注PGSQL集群的会话/负载/QPS/TPS/锁定情况

<details><summary>PGSQL Activity</summary>

[![pgsql-activity.jpg](https://repo.pigsty.cc/img/pgsql-activity.jpg)](https://demo.pigsty.cc/d/pgsql-activity)

</details>

[PGSQL Replication](https://demo.pigsty.cc/d/pgsql-replication)：关注PGSQL集群复制、插槽和发布/订阅。

<details><summary>PGSQL Replication</summary>

[![pgsql-replication.jpg](https://repo.pigsty.cc/img/pgsql-replication.jpg)](https://demo.pigsty.cc/d/pgsql-replication)

</details>


[PGSQL Databases](https://demo.pigsty.cc/d/pgsql-databases)：关注所有实例的数据库CRUD、慢查询和表统计信息。

<details><summary>PGSQL Databases</summary>

[![pgsql-databases.jpg](https://repo.pigsty.cc/img/pgsql-databases.jpg)](https://demo.pigsty.cc/d/pgsql-databases)

</details>


[PGSQL Patroni](https://demo.pigsty.cc/d/pgsql-patroni)：关注集群高可用状态，Patroni组件状态

<details><summary>PGSQL Patroni</summary>

[![pgsql-patroni.jpg](https://repo.pigsty.cc/img/pgsql-patroni.jpg)](https://demo.pigsty.cc/d/pgsql-patroni)

</details>




-------------------

## 实例

[PGSQL Instance](https://demo.pigsty.cc/d/pgsql-instance)：单个PGSQL实例的主仪表板

<details><summary>PGSQL Instance</summary>

[![pgsql-instance.jpg](https://repo.pigsty.cc/img/pgsql-instance.jpg)](https://demo.pigsty.cc/d/pgsql-instance)

</details>


[PGRDS Instance](https://demo.pigsty.cc/d/pgrds-instance)：PGSQL Instance 的RDS版本，专注于所有 PostgreSQL 本身的指标

<details><summary>PGRDS Instance</summary>

[![pgrds-instance.jpg](https://repo.pigsty.cc/img/pgrds-instance.jpg)](https://demo.pigsty.cc/d/pgrds-instance)

</details>


[PGSQL Proxy](https://demo.pigsty.cc/d/pgsql-proxy)：单个haproxy负载均衡器的详细指标

<details><summary>PGSQL Proxy</summary>

[![pgsql-proxy.jpg](https://repo.pigsty.cc/img/pgsql-proxy.jpg)](https://demo.pigsty.cc/d/pgsql-proxy)

</details>


[PGSQL Pgbouncer](https://demo.pigsty.cc/d/pgsql-pgbouncer)：单个Pgbouncer连接池实例中的指标总览

<details><summary>PGSQL Pgbouncer</summary>

[![pgsql-pgbouncer.jpg](https://repo.pigsty.cc/img/pgsql-pgbouncer.jpg)](https://demo.pigsty.cc/d/pgsql-pgbouncer)

</details>


[PGSQL Persist](https://demo.pigsty.cc/d/pgsql-persist)：持久性指标：WAL、XID、检查点、存档、IO

<details><summary>PGSQL Persist</summary>

[![pgsql-persist.jpg](https://repo.pigsty.cc/img/pgsql-persist.jpg)](https://demo.pigsty.cc/d/pgsql-persist)

</details>


[PGSQL Xacts](https://demo.pigsty.cc/d/pgsql-xacts)：关于事务、锁、TPS/QPS相关的指标

<details><summary>PGSQL Xacts</summary>

[![pgsql-xacts.jpg](https://repo.pigsty.cc/img/pgsql-xacts.jpg)](https://demo.pigsty.cc/d/pgsql-xacts)

</details>


[PGSQL Session](https://demo.pigsty.cc/d/pgsql-session)：单个实例中的会话和活动/空闲时间的指标

<details><summary>PGSQL Session</summary>

[![pgsql-session.jpg](https://repo.pigsty.cc/img/pgsql-session.jpg)](https://demo.pigsty.cc/d/pgsql-session)

</details>


[PGSQL Exporter](https://demo.pigsty.cc/d/pgsql-exporter)：Postgres/Pgbouncer 监控组件自我监控指标

<details><summary>PGSQL Exporter</summary>

[![pgsql-exporter.jpg](https://repo.pigsty.cc/img/pgsql-exporter.jpg)](https://demo.pigsty.cc/d/pgsql-exporter)

</details>




-------------------

## 数据库


[PGSQL Database](https://demo.pigsty.cc/d/pgsql-database)：单个PGSQL数据库的主仪表板

<details><summary>PGSQL Database</summary>

[![pgsql-database.jpg](https://repo.pigsty.cc/img/pgsql-database.jpg)](https://demo.pigsty.cc/d/pgsql-database)

</details>


[PGSQL Tables](https://demo.pigsty.cc/d/pgsql-tables)：单个数据库内的表/索引访问指标

<details><summary>PGSQL Tables</summary>

[![pgsql-tables.jpg](https://repo.pigsty.cc/img/pgsql-tables.jpg)](https://demo.pigsty.cc/d/pgsql-tables)

</details>


[PGSQL Table](https://demo.pigsty.cc/d/pgsql-table)：单个表的详细信息（QPS/RT/索引/序列...）

<details><summary>PGSQL Table</summary>

[![pgsql-table.jpg](https://repo.pigsty.cc/img/pgsql-table.jpg)](https://demo.pigsty.cc/d/pgsql-table)

</details>


[PGSQL Query](https://demo.pigsty.cc/d/pgsql-query)：单类查询的详细信息（QPS/RT）

<details><summary>PGSQL Query</summary>

[![pgsql-query.jpg](https://repo.pigsty.cc/img/pgsql-query.jpg)](https://demo.pigsty.cc/d/pgsql-query)

</details>




-------------------

## PGCAT

[PGCAT Instance](https://demo.pigsty.cc/d/pgcat-instance)：直接从数据库目录获取的实例信息

<details><summary>PGCAT Instance</summary>

[![pgcat-instance.jpg](https://repo.pigsty.cc/img/pgcat-instance.jpg)](https://demo.pigsty.cc/d/pgcat-instance)

</details>


[PGCAT Database](https://demo.pigsty.cc/d/pgcat-database)：直接从数据库目录获取的数据库信息

<details><summary>PGCAT Database</summary>

[![pgcat-database.jpg](https://repo.pigsty.cc/img/pgcat-database.jpg)](https://demo.pigsty.cc/d/pgcat-database)

</details>



[PGCAT Schema](https://demo.pigsty.cc/d/pgcat-schema)：直接从数据库目录获取关于模式的信息（表/索引/序列...）

<details><summary>PGCAT Schema</summary>

[![pgcat-schema.jpg](https://repo.pigsty.cc/img/pgcat-schema.jpg)](https://demo.pigsty.cc/d/pgcat-schema)

</details>




[PGCAT Table](https://demo.pigsty.cc/d/pgcat-table)：直接从数据库目录获取的单个表的详细信息（统计/膨胀...）

<details><summary>PGCAT Table</summary>

[![pgcat-table.jpg](https://repo.pigsty.cc/img/pgcat-table.jpg)](https://demo.pigsty.cc/d/pgcat-table)

</details>



[PGCAT Query](https://demo.pigsty.cc/d/pgcat-query)：直接从数据库目录获取的单类查询的详细信息（SQL/统计）

<details><summary>PGCAT Query</summary>

[![pgcat-query.jpg](https://repo.pigsty.cc/img/pgcat-query.jpg)](https://demo.pigsty.cc/d/pgcat-query)

</details>



[PGCAT Locks](https://demo.pigsty.cc/d/pgcat-locks)：直接从数据库目录获取的关于活动与锁等待的信息

<details><summary>PGCAT Locks</summary>

[![pgcat-locks.jpg](https://repo.pigsty.cc/img/pgcat-locks.jpg)](https://demo.pigsty.cc/d/pgcat-locks)

</details>



-------------------

## PGLOG

[PGLOG Overview](https://demo.pigsty.cc/d/pglog-overview)：总览 Pigsty CMDB 中的CSV日志样本

<details><summary>PGLOG Overview</summary>

[![pglog-overview.jpg](https://repo.pigsty.cc/img/pglog-overview.jpg)](https://demo.pigsty.cc/d/pglog-overview)

</details>



[PGLOG Overview](https://demo.pigsty.cc/d/pglog-overview)：Pigsty CMDB 中的CSV日志样本中某一条会话的日志详情

<details><summary>PGLOG Session</summary>

[![pglog-session.jpg](https://repo.pigsty.cc/img/pglog-session.jpg)](https://demo.pigsty.cc/d/pglog-session)

</details>





----------------

## 画廊

详情请参考 [pigsty/wiki/gallery](https://github.com/Vonng/pigsty/wiki/Gallery)。

<details><summary>PGSQL Overview</summary>

[![pgsql-overview.jpg](https://repo.pigsty.cc/img/pgsql-overview.jpg)](https://demo.pigsty.cc/d/pgsql-overview)

</details>


<details><summary>PGSQL Shard</summary>

[![pgsql-shard.jpg](https://repo.pigsty.cc/img/pgsql-shard.jpg)](https://demo.pigsty.cc/d/pgsql-shard)

</details>


<details><summary>PGSQL Cluster</summary>

[![pgsql-cluster.jpg](https://repo.pigsty.cc/img/pgsql-cluster.jpg)](https://demo.pigsty.cc/d/pgsql-cluster)

</details>


<details><summary>PGSQL Service</summary>

[![pgsql-service.jpg](https://repo.pigsty.cc/img/pgsql-service.jpg)](https://demo.pigsty.cc/d/pgsql-service)

</details>


<details><summary>PGSQL Activity</summary>

[![pgsql-activity.jpg](https://repo.pigsty.cc/img/pgsql-activity.jpg)](https://demo.pigsty.cc/d/pgsql-activity)

</details>


<details><summary>PGSQL Replication</summary>

[![pgsql-replication.jpg](https://repo.pigsty.cc/img/pgsql-replication.jpg)](https://demo.pigsty.cc/d/pgsql-replication)

</details>


<details><summary>PGSQL Databases</summary>

[![pgsql-databases.jpg](https://repo.pigsty.cc/img/pgsql-databases.jpg)](https://demo.pigsty.cc/d/pgsql-databases)

</details>


<details><summary>PGSQL Instance</summary>

[![pgsql-instance.jpg](https://repo.pigsty.cc/img/pgsql-instance.jpg)](https://demo.pigsty.cc/d/pgsql-instance)

</details>


<details><summary>PGSQL Proxy</summary>

[![pgsql-proxy.jpg](https://repo.pigsty.cc/img/pgsql-proxy.jpg)](https://demo.pigsty.cc/d/pgsql-proxy)

</details>


<details><summary>PGSQL Pgbouncer</summary>

[![pgsql-pgbouncer.jpg](https://repo.pigsty.cc/img/pgsql-pgbouncer.jpg)](https://demo.pigsty.cc/d/pgsql-pgbouncer)

</details>


<details><summary>PGSQL Session</summary>

[![pgsql-session.jpg](https://repo.pigsty.cc/img/pgsql-session.jpg)](https://demo.pigsty.cc/d/pgsql-session)

</details>


<details><summary>PGSQL Xacts</summary>

[![pgsql-xacts.jpg](https://repo.pigsty.cc/img/pgsql-xacts.jpg)](https://demo.pigsty.cc/d/pgsql-xacts)

</details>


<details><summary>PGSQL Persist</summary>

[![pgsql-persist.jpg](https://repo.pigsty.cc/img/pgsql-persist.jpg)](https://demo.pigsty.cc/d/pgsql-persist)

</details>


<details><summary>PGSQL Database</summary>

[![pgsql-database.jpg](https://repo.pigsty.cc/img/pgsql-database.jpg)](https://demo.pigsty.cc/d/pgsql-database)

</details>


<details><summary>PGSQL Tables</summary>

[![pgsql-tables.jpg](https://repo.pigsty.cc/img/pgsql-tables.jpg)](https://demo.pigsty.cc/d/pgsql-tables)

</details>


<details><summary>PGSQL Table</summary>

[![pgsql-table.jpg](https://repo.pigsty.cc/img/pgsql-table.jpg)](https://demo.pigsty.cc/d/pgsql-table)


</details>


<details><summary>PGSQL Query</summary>

[![pgsql-query.jpg](https://repo.pigsty.cc/img/pgsql-query.jpg)](https://demo.pigsty.cc/d/pgsql-query)

</details>


<details><summary>PGCAT Instance</summary>

[![pgcat-instance.jpg](https://repo.pigsty.cc/img/pgcat-instance.jpg)](https://demo.pigsty.cc/d/pgcat-instance)

</details>


<details><summary>PGCAT Database</summary>

[![pgcat-database.jpg](https://repo.pigsty.cc/img/pgcat-database.jpg)](https://demo.pigsty.cc/d/pgcat-database)

</details>


<details><summary>PGCAT Schema</summary>

[![pgcat-schema.jpg](https://repo.pigsty.cc/img/pgcat-schema.jpg)](https://demo.pigsty.cc/d/pgcat-schema)

</details>


<details><summary>PGCAT Table</summary>

[![pgcat-table.jpg](https://repo.pigsty.cc/img/pgcat-table.jpg)](https://demo.pigsty.cc/d/pgcat-table)

</details>


<details><summary>PGCAT Lock</summary>

[![pgcat-locks.jpg](https://repo.pigsty.cc/img/pgcat-locks.jpg)](https://demo.pigsty.cc/d/pgcat-locks)

</details>


<details><summary>PGCAT Query</summary>

[![pgcat-query.jpg](https://repo.pigsty.cc/img/pgcat-query.jpg)](https://demo.pigsty.cc/d/pgcat-query)

</details>



<details><summary>PGLOG Overview</summary>

[![pglog-overview.jpg](https://repo.pigsty.cc/img/pglog-overview.jpg)](https://demo.pigsty.cc/d/pglog-overview)


</details>


<details><summary>PGLOG Session</summary>

[![pglog-session.jpg](https://repo.pigsty.cc/img/pglog-session.jpg)](https://demo.pigsty.cc/d/pglog-session)

</details>


