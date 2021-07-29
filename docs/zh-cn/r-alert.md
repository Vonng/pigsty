# 告警系统

Pigsty有两套并行的告警系统：

* [Prometheus](http://p.pigsty.cc/alerts) + [AlertManager](http://a.pigsty.cc/#/alerts) （主）
* [Grafana](http://demo.pigsty.cc/d/pgsql-alert)（备）

两套系统功能等效，侧重能力不同，可同时使用，互为备份补充。



## 告警

告警对于日常故障响应，提高系统可用性至关重要。

漏报会导致可用性降低，误报会导致敏感性下降，有必要对告警规则进行审慎的设计。

* 合理定义告警级别，以及相应的处理流程
* 合理定义告警指标，去除重复告警项，补充缺失告警项
* 根据历史监控数据科学配置告警阈值，减少误报率。
* 合理疏理特例规则，消除维护工作，ETL，离线查询导致的误报。



## 告警分类学

**按紧急程度分类**

* P0：CRIT：产生重大场外影响的事故，需要紧急介入处理。例如主库宕机，复制中断。（事故）
* P1：WARN：场外影响轻微，或有冗余处理的事故，需要在分钟级别内进行响应处理。（警告）
* P2：INFO：即将产生影响，放任可能在小时级别内恶化，需在小时级别进行响应。（事件）
* Pigsty使用`level`标签`{0, 1, 2}`，与`severity`标签`{CRIT,WARN,INFO}`来标识告警的紧急程度。

**按告警层次分类**

* 基础设施：操作系统，硬件资源，基础设施软件，负载均衡等告警，通常由运维人员负责处理。
* 数据库级：数据库集群本身的告警，DBA重点关注。由PG，PGB，Exporter本身的监控指标产生。
* 应用级：应用告警由业务方自己负责，但DBA会为QPS，TPS，Rollback，Seasonality等业务指标设置告警
* Pigsty使用`category`标签`{infra,pgsql}`来标识告警的层次分类：基础设施与数据库集群。

**按指标类型分类**

* 错误：PG Down, PGB Down, Exporter Down, 流复制中断，单集簇多主
* 流量：QPS，TPS，Rollback，Seasonaility
* 延迟: 平均响应时间，复制延迟
* 饱和度：连接堆积，闲事务数，CPU，磁盘，年龄（事务号），缓冲区



## 告警可视化

在各类监控面板中，Pigsty使用**时间轴状态图**呈现告警信息。横轴代表时间段，一段色条代表告警事件。只有处于 **激发（Firing）** 状态的告警才会显示在告警图表中，处于Pending状态的告警通常会隐藏或以灰色显示。



## 告警规则

告警规则按类型可粗略分为四类：错误，延迟，饱和度，流量。其中：

* 错误：主要关注各个组件的**存活性（Aliveness）**，以及网络中断，脑裂等异常情况，级别通常较高（P0|P1）。
* 延迟：主要关注查询响应时间，复制延迟，慢查询，长事务。
* 饱和度：主要关注CPU，磁盘（这两个属于系统监控但对于DB非常重要所以纳入），连接池排队，数据库后端连接数，年龄（本质是可用事物号的饱和度），SSD寿命等。
* 流量：QPS，TPS，Rollback（流量通常与业务指标有关属于业务监控范畴，但因为对于DB很重要所以纳入），QPS的季节性，TPS的突增。

## Prometheus告警规则

告警规则使用Prometheus语法定义，完整的告警规则详见：

* [基础设施告警规则](https://github.com/Vonng/pigsty/blob/master/roles/prometheus/files/rules/infra-alert.yml)
* [数据库集群告警规则](https://github.com/Vonng/pigsty/blob/master/roles/prometheus/files/rules/pgsql-alert.yml)



## Pigsty典型告警

### **错误告警**

数据库实例宕机将立刻触发P0报警。

```yaml
# database server down
- alert: PostgresDown
  expr: pg_up < 1
  for: 1m
  labels: { level: 0, severity: CRIT, category: pgsql }
  annotations:
    summary: "CRIT PostgresDown {{ $labels.ins }}@{{ $labels.instance }}"
    description: |
      pg_up[ins={{ $labels.ins }}, instance={{ $labels.instance }}] = {{ $value }} < 1
      http://g.pigsty/d/pgsql-instance?var-ins={{ $labels.ins }}
```

在生产环境使用PostgreSQL时，Pgbouncer实例与Postgres是一一对应的命运共同体，Pgbouncer故障效果基本与Postgres故障等同，其存活性告警规则级别与Postgres统一。

```yaml
# database connection pool down
- alert: PgbouncerDown
  expr: pgbouncer_up < 1
  for: 1m
  labels: { level: 0, severity: CRIT, category: pgsql }
  annotations:
    summary: "CRIT PostgresDown {{ $labels.ins }}@{{ $labels.instance }}"
    description: |
      pgbouncer_up[ins={{ $labels.ins }}, instance={{ $labels.instance }}] = {{ $value }} < 1
      http://g.pigsty/d/pgsql-instance?var-ins={{ $labels.ins }}
```

监控代理Exporter宕机通常预示着严重故障：HAProxy 与Node Exporter宕机通常意味着负载均衡器与数据库节点本身宕机，需要重点关注

```yaml
#==============================================================#
#                       Agent Aliveness                        #
#==============================================================#
# node & haproxy aliveness are determined directly by exporter aliveness
# including: node_exporter, pg_exporter, pgbouncer_exporter, haproxy_exporter
- alert: AgentDown
  expr: agent_up < 1
  for: 1m
  labels: { level: 0, severity: CRIT, category: infra }
  annotations:
    summary: 'CRIT AgentDown {{ $labels.ins }}@{{ $labels.instance }}'
    description: |
      agent_up[ins={{ $labels.ins }}, instance={{ $labels.instance }}] = {{ $value  | printf "%.2f" }} < 1
      http://g.pigsty/d/pgsql-alert?viewPanel=22
```

所有存活性检测的持续时间阈值设定为1分钟，对15s的采集周期通常意味着连续4次探活失败。常规的快速重启操作通常不会触发存活性告警。



**集群脑裂分区**

一个数据库集群，应当有且仅有一个主库领导者实例。即集群正常情况下应当只有一个**分区**。如果集群的分区数量不为1（为0代表群龙无首，大于1代表群雄逐鹿）则代表集群进入了异常状态：不可写入或脑裂，会立即触发P0报警。因为检测阈值为1分钟，所以常规的Failover与Switchover通常不容易触发此告警。

```yaml
# cluster partition: split brain
- alert: PostgresPartition
  expr: pg:cls:partition != 1
  for: 1m
  labels: { level: 0, severity: CRIT, category: pgsql }
  annotations:
    summary: "CRIT PostgresPartition {{ $labels.cls }}@{{ $labels.job }} {{ $value }}"
    description: |
      pg:cls:partition[cls={{ $labels.cls }}, job={{ $labels.job }}] = {{ $value }} != 1
```





### **延迟告警**

与复制延迟有关的告警有二个：复制中断，复制延迟高，定级为P1警告。

* 其中**复制中断**是一种错误，使用指标：`pg_downstream_count{state="streaming"}`进行判断，当前`streaming`状态的从库如果数量发生负向变动，则触发break告警。`walsender`会决定复制的状态，从库直接断开会产生此现象，缓冲区出现积压时会从`streaming`进入`catchup`状态也会触发此告警。此外，采用`-Xs`手工制作备份结束时也会产生此告警，此告警会在5分钟后自动Resolve。复制中断会导致客户端读到陈旧的数据，具有一定的场外影响，定级为P1。

* 复制延迟可以使用延迟时间或者延迟字节数判定。以延迟字节数为权威指标。常规状态下，复制延迟时间在百毫秒量级，复制延迟字节在百KB量级均属于正常。根据历史经验数据，目前采用的是1MB与1s的时间告警阈值。


```yaml
#==============================================================#
#                         Replication                          #
#==============================================================#
# replication break for 1m triggers a P1 alert (WARN: heal in 5m)
- alert: PostgresReplicationBreak
  expr: changes(pg_downstream_count{state="streaming"}[5m]) > 0
  # for: 1m
  labels: { level: 1, severity: WARN, category: pgsql }
  annotations:
    summary: "WARN PostgresReplicationBreak: {{ $labels.ins }}@{{ $labels.instance }}"
    description: |
      changes(pg_downstream_count{ins={{ $labels.ins }}, instance={{ $labels.instance }}, state="streaming"}[5m]) > 0


# replication lag bytes > 1MiB or lag seconds > 1s
- alert: PostgresReplicationLag
  expr: pg:ins:lag_bytes > 1048576 or pg:ins:lag_seconds > 1
  for: 1m
  labels: { level: 1, severity: WARN, category: pgsql }
  annotations:
    summary: "WARN PostgresReplicationLag: {{ $labels.ins }}@{{ $labels.instance }}"
    description: |
      pg:ins:lag_bytes[ins={{ $labels.ins }}, instance={{ $labels.instance }}] = {{ $value | printf "%.0f" }} > 1048576 or
      pg:ins:lag_seconds[ins={{ $labels.ins }}, instance={{ $labels.instance }}] = {{ $value | printf "%.2f" }} > 1


```

此外，查询延迟与磁盘延迟也有相应的报警规则：

例如，磁盘读写平均响应时间持续一分钟超过32ms，或Pgbouncer中平均查询RT超过16ms均会触发P1告警。

```yaml

# read latency > 32ms (typical on pci-e ssd: 100µs)
- alert: NodeDiskSlow
  expr: node:dev:disk_read_rt_1m > 0.032 or node:dev:disk_write_rt_1m > 0.032
  for: 1m
  labels: { level: 1, severity: WARN, category: node }
  annotations:
    summary: 'WARN NodeReadSlow {{ $labels.ins }}@{{ $labels.instance }} {{ $value  | printf "%.6f" }}'
    description: |
      node:dev:disk_read_rt_1m[ins={{ $labels.ins }}] = {{ $value  | printf "%.6f" }} > 32ms


# pgbouncer avg response time > 16ms (database level)
- alert: PgbouncerQuerySlow
  expr: pgbouncer:db:query_rt_1m > 0.016
  for: 3m
  labels: { level: 1, severity: WARN, category: pgsql }
  annotations:
    summary: "WARN PgbouncerQuerySlow: {{ $labels.ins }}@{{ $labels.instance }} [{{ $labels.datname }}]"
    description: |
      pgbouncer:db:query_rt_1m[ins={{ $labels.ins }}, instance={{ $labels.instance }}, datname={{ $labels.datname }}] = {{ $value | printf "%.3f" }} > 0.016

```







### 饱和度告警

饱和度指标主要资源，包含很多系统级监控的指标。主要包括：CPU，磁盘（这两个属于系统监控但对于DB非常重要所以纳入），连接池排队，数据库后端连接数，年龄（本质是可用事物号的饱和度），SSD寿命等。

**数据库压力**

数据库压力是：机器CPU使用率，Pgbouncer时间利用率，Postgres时间利用率（14引入）的综合最大值（百分比，但过载时可以超过100%）。压力是Pigsty中最重要的指标，集中体现了数据库实例与集群的负载水位。

```yaml
#==============================================================#
#                        Saturation                            #
#==============================================================#
# instance pressure higher than 70% for 1m triggers a P1 alert
- alert: PostgresPressureHigh
  expr: ins:pressure1 > 0.70
  for: 1m
  labels: { level: 1, severity: WARN, category: pgsql }
  annotations:
    summary: "WARN PostgresPressureHigh: {{ $labels.ins }}@{{ $labels.instance }}"
    description: |
      ins:pressure1[ins={{ $labels.ins }}, instance={{ $labels.instance }}] = {{ $value | printf "%.3f" }} > 0.70

```





**堆积检测**

堆积主要包含两类指标，一方面是PG本身的后端连接数与活跃连接数，另一方面是连接池的排队情况。

PGB排队是决定性的指标，它代表用户端可感知的阻塞已经出现，因此出现排队持续1分钟触发P0告警。

当使用**Session Pooling**模式时，可适当放宽此报警指标。

```yaml
# pgbouncer client queue exists
- alert: PgbouncerClientQueue
  expr: pgbouncer:db:waiting_clients > 1
  for: 1m
  labels: { level: 0, severity: CRIT, category: pgsql }
  annotations:
    summary: "CRIT PgbouncerClientQueue: {{ $labels.ins }}@{{ $labels.instance }} [{{ $labels.datname }}]"
    description: |
      pgbouncer:db:waiting_clients[ins={{ $labels.ins }}, instance={{ $labels.instance }}, datname={{ $labels.datname }}] = {{ $value | printf "%.0f" }} > 1

```

后端连接数是一个重要的告警指标，如果后端连接持续达到最大连接数，往往也意味着雪崩。连接池的排队连接数也能反映这种情况，但不能覆盖应用直连数据库的情况。

目前，Pigsty使用**连接使用率**作为告警指标，即数据库可用连接数量已经使用的百分比，超过70%持续3分钟即出发P1告警。

```yaml
# database connection usage > 70%
- alert: PostgresConnUsageHigh
  expr: pg:db:conn_usage > 0.70
  for: 3m
  labels: { level: 1, severity: WARN, category: pgsql }
  annotations:
    summary: "WARN PostgresConnUsageHigh: {{ $labels.ins }}@{{ $labels.instance }} [{{ $labels.datname }}]"
    description: |
      pg:db:conn_usage[ins={{ $labels.ins }}, instance={{ $labels.instance }}, datname={{ $labels.datname }}] = {{ $value | printf "%.3f" }} > 0.70

```



**空闲事务**

即数据库出现`Idle in Transaction`状态的连接数量，超过2条持续3分钟即出发P1告警。

```yaml
# database connection usage > 70%
- alert: PostgresIdleInXact
  expr: pg:db:ixact_backends > 1
  for: 3m
  labels: { level: 2, severity: INFO, category: pgsql }
  annotations:
    summary: "Info PostgresIdleInXact: {{ $labels.ins }}@{{ $labels.instance }} [{{ $labels.datname }}]"
    description: |
      pg:db:ixact_backends[ins={{ $labels.ins }}, instance={{ $labels.instance }}, datname={{ $labels.datname }}] = {{ $value | printf "%.0f" }} > 1

```

**资源告警**

年龄（XID）使用量超过80%出发P0告警，这意味着系统快要消耗完事务号资源，进入XID Wraparound状态

```yaml
# database age saturation > 80%
- alert: PostgresXidWarpAround
  expr: pg:db:age > 0.80
  for: 1m
  labels: { level: 0, severity: CRIT, category: pgsql }
  annotations:
    summary: "CRIT PostgresXidWarpAround: {{ $labels.ins }}@{{ $labels.instance }} [{{ $labels.datname }}]"
    description: |
      pg:db:age[ins={{ $labels.ins }}, instance={{ $labels.instance }}, datname={{ $labels.datname }}] = {{ $value | printf "%.0f" }} > 80%

```


