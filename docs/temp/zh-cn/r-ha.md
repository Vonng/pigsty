# 数据库高可用场景演练

您可以通过高可用场景演练，来加强对集群高可用能力的信心。

以下列出了24种典型的高可用故障场景，分为主库故障，从库故障，DCS故障三类，每类8个具体场景。

所有演练均假设**高可用自动切换模式**已启用，其中，Patroni应当正确处理主库故障与从库故障。

|                编号                | 案例名称                                                     |       自动模式       | 手动切换 |
| :--------------------------------: | :----------------------------------------------------------- |:----------------:| :------: |
|         [A](#主库故障演练)         | **主库故障**                                                 |                  |          |
|      [1A](#_1a-主库节点宕机)       | 主库节点宕机                                                 |  **自动Failover**  | 人工切换 |
|  [2A](#_2a-主库postgres进程关停)   | 主库Postgres进程关停（`pg_ctl or kill -9`）                  |  **自动Failover**  | 人工重启 |
| [3A](#_3a-主库patroni进程正常关停) | 主库Patroni进程正常关停（`systemctl stop patroni`）          |  **自动Failover**  | 人工重启 |
| [4A](#_4a-主库patroni进程异常关停) | 主库Patroni进程异常关停（`kill -9`）                         |     **需要确认**     |  无影响  |
|                 5A                 | 主库负载打满，假死（watchdog）                               |     **需要确认**     |  无影响  |
|                 6A                 | 主库DCS Agent不可用（`systemctl stop consul`）               |    **集群主库降级**    |  无影响  |
|                 7A                 | 主库网络抖动                                                 | **超时自动Failover** |  需观察  |
|                 8A                 | 误删主库数据目录                                             |  **自动Failover**  | 手工切换 |
|         [B](#从库故障演练)         | **从库故障（1/n , n>1）**                                    |                  |          |
|                 1B                 | 从库节点宕机                                                 |       无影响        |  无影响  |
|                 2B                 | 从库Postgres进程关停（`pg_ctl or kill -9`）                  |       无影响        |  无影响  |
|                 3B                 | 从库Postgres进程手工关停 （`pg_ctl`）                        |       无影响        |  无影响  |
|                 4B                 | 从库Patroni进程异常Kill（`kill -9`）                         |       无影响        |  无影响  |
|                 5B                 | 从库DCS Agent不可用（`systemctl stop consul`）               |       无影响        |  无影响  |
|                 6B                 | 从库负载打满，假死                                           |     Depends      | Depends  |
|                 7B                 | 从库网络抖动                                                 |       无影响        |  无影响  |
|                 8B                 | 误提升一个从库（`pg_ctl promte`）                            |     **自动恢复**     | **脑裂** |
|         [C](#dcs故障演练)          | **DCS故障**                                                  |                  |          |
|                 1C                 | DCS Server完全不可用（多数节点不可用）                       |   **所有集群主库降级**   |  无影响  |
|                 2C                 | DCS通主库，不通从库（1主1从）                                |       无影响        |  无影响  |
|                 3C                 | DCS通主库，不通从库（1主n从，n>1）                           |       无影响        |  无影响  |
|                 4C                 | DCS通从库，不通主库（1主1从）                                |       无影响        |  无影响  |
|                 5C                 | DCS通从库，不通主库（1主n从，n>1）                           |  **自动Failover**  |  无影响  |
|                 6C                 | DCS网络抖动：同时中断，<br />主库从库同时恢复，或主库先恢复  |       无影响        |  无影响  |
|                 7C                 | DCS网络抖动：同时中断，<br />从库先恢复，主库后恢复（1主1从） |       无影响*       |  无影响  |
|                 8C                 | DCS网络抖动：同时中断，<br />从库先恢复，主库后恢复（1主n从，n>1） | 超过TTL自动Failover  |  无影响  |

-----------------------



## 演练环境说明

以下以本地Pigsty 四节点沙箱作为演练对象。

**准备负载**

在演练中，您可以使用`pgbench`生成虚拟负载，观察负载流量在各种故障下的状态。

```bash
make test-ri     # 在 pg-test集群初始化 pgbench 表
make test-rw     # 生成 pgbench 写入流量
make test-ro     # 生成 pgbench 只读流量
```

如果您希望仿真其他样式的流量，可以直接调整负载生成的命令并执行。

```bash
# 4条连接，总计64读写TPS
while true; do pgbench -nv -P1 -c4 --rate=64 -T10 postgres://test:test@pg-test:5433/test; done

# 8条连接，总计512只读TPS
while true; do pgbench -nv -P1 -c8 --select-only --rate=512 -T10 postgres://test:test@pg-test:5434/test; done
```

**观察状态**

[PGSQL Cluster](http://demo.pigsty.cc/d/pgsql-cluster/pgsql-cluster?orgId=1&var-cls=pg-test&var-primary=pg-test-1) 面板提供了关于`pg-test`集群的重要监控信息，您可以查阅最近5-15分钟的指标，并设置为每5秒自动刷新。

Pigsty的监控指标采集周期默认为10秒，而Patroni主从切换的典型耗时通常在几秒到十几秒之间。您可以使用`patronictl`来获取亚秒级别的观测精度：

```bash
pg list pg-test          # 查看 pg-test 集群状态（在单独的窗口中）
pg list pg-test -w 0.1   # 查看 pg-test 集群状态，每0.1s刷新一次
```

您可以开启四个Terminal窗口，分别用于：

* 在元节点上执行管理命令（用来触发模拟故障的命令）
* 发起并观察读写请求负载（`pgbench`）
* 发起并观察只读请求负载（`pgbench --select-only`）
* 实时查阅集群主从状态（`pg list`）





## 主库故障演练

### 1A-主库节点宕机

**操作说明**

```bash
ssh 10.10.10.3 sudo reboot    # 直接将 pg-test-1 主节点重启（VIP指向实际主节点）
```

**操作结果**

Patroni可以正常处理主库宕机，执行自动Failover。

当集群处于维护模式时，则需要人工介入处理（人工执行`pg failover <cluster>`）

<details><summary>patronictl list 结果</summary>

```bash
# 正常情况：pg-test-3 是当前集群主库，时间线为3（此集群已经经历过两次Failover）
+ Cluster: pg-test (7037005266924312648) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Replica | running |  3 |         0 | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  3 |         0 | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Leader  | running |  3 |           | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+

# ssh 10.10.10.13 sudo reboot 将 pg-test-3 主实例所在节点重启，pg-test-3 实例的Patroni从集群中消失
# 下线超过TTL后，pg-test-1实例抢到Leader Key，成为新的集群领导者。
+ Cluster: pg-test (7037005266924312648) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Leader  | running |  3 |           | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  3 |         0 | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+

# pg-test-1实例完成Promote，成为集群的新领导者，时间线变为4
+ Cluster: pg-test (7037005266924312648) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Leader  | running |  4 |           | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  3 |         0 | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+

# pg-test-2 实例将自己的上游修改为新领导者 pg-test-1 ，时间线由3变为4，进入新时代，看齐新核心。
+ Cluster: pg-test (7037005266924312648) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Leader  | running |  4 |           | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  4 |         0 | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+

# pg-test-3 完成重启，Postgres处于停止状态，Patroni重新加入集群中
+ Cluster: pg-test (7037005266924312648) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Leader  | running |  4 |           | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  4 |         1 | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Replica | stopped |    |   unknown | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+

# pg-test-3 上的Postgres以从库身份被拉起，从新主库 pg-test-1 同步数据。
+ Cluster: pg-test (7037005266924312648) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Leader  | running |  4 |           | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  4 |         1 | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Replica | running |  3 |        10 | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+

# pg-test-3 追赶上新领导者，时间线进入4，与新领导保持同步。
+ Cluster: pg-test (7037005266924312648) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Leader  | running |  4 |           | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  4 |         1 | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Replica | running |  4 |         0 | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+
```

</details>





### 2A-主库Postgres进程关停

**操作说明**

采用两种不同的方式关停主库 Postgres 实例：常规的 `pg_ctl` 与暴力的 `kill -9`

```bash
# 关停主库上的Postgres主进程
ssh 10.10.10.3 'sudo -iu postgres /usr/pgsql/bin/pg_ctl -D /pg/data stop'

# 查询主库PID并强行Kill
ssh 10.10.10.3 'sudo kill -9 $(sudo cat /pg/data/postmaster.pid | head -n1)'
```

**操作结果**

关停 Postgres 后，Patroni 会尝试重新拉起 Postgres 进程。如果成功，则集群恢复正常。

如果无法正常拉起 PostgreSQL 进程，则集群会自动进行Failover。

<details><summary>patronictl list 结果</summary>

```bash
# 主库实例被强制Kill后，状态显示为crashed，而后立刻被重新拉起，恢复为Running
+ Cluster: pg-test (7037005266924312648) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Leader  | crashed |    |           | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  7 |         0 | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Replica | running |  7 |         0 | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+

# 如果持续Kill主库，导致主库拉起失败（状态变为start failed），那么就会触发Failover
+ Cluster: pg-test (7037005266924312648) ----------+----+-----------+-----------------+
| Member    | Host        | Role    | State        | TL | Lag in MB | Tags            |
+-----------+-------------+---------+--------------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Replica | running      | 11 |         0 | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Leader  | running      | 12 |           | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Replica | start failed |    |   unknown | clonefrom: true |
+-----------+-------------+---------+--------------+----+-----------+-----------------+
```

</details>



### 3A-主库Patroni进程正常关停

**操作说明**

```bash
# 关停主库上的Postgres主进程
ssh 10.10.10.3 'sudo systemctl stop patroni'
```

**操作结果**

通过常规方式关停主库Patroni，**会导致Patroni所管理PostgreSQL实例一并关闭**，并**立即**触发集群Failover。

在维护模式下通过正常方式关停Patroni，关闭Patroni不会影响所托管的PostgreSQL实例，这可以用于重启Patroni以重载配置（例如更换使用的DCS）。

<details><summary>patronictl list 结果</summary>

```bash
# 主库Patroni (pg-test-3) 关停后
+ Cluster: pg-test (7037370797549923387) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Replica | running |  2 |         0 | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  2 |         0 | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Leader  | running |  2 |           | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+

# pg-test-3 进入 stopped 状态
+ Cluster: pg-test (7037370797549923387) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Replica | running |  2 |         0 | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  2 |         0 | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Replica | stopped |    |   unknown | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+

# 新主库 pg-test-2 当选，时间线从2进入3
+ Cluster: pg-test (7037370797549923387) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Replica | running |  2 |         0 | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Leader  | running |  3 |           | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Replica | stopped |    |   unknown | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+

# 另一个健康从库 pg-test-1 重新追随新主库 pg-test-2 进入时间线3，老主库 pg-test-3 在一段时间后，从集群中消失
+ Cluster: pg-test (7037370797549923387) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Replica | running |  3 |         0 | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Leader  | running |  3 |           | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+

# 使用 systemctl start patroni 重新拉起老主库 pg-test-3，该实例自动进入复制模式，追随新领导者。
+ Cluster: pg-test (7037370797549923387) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Replica | running |  3 |         0 | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Leader  | running |  3 |           | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Replica | running |  3 |         0 | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+
```

</details>





### 4A-主库Patroni进程异常关停

!> 这种情况需要特别关注！

如果使用Kill -9 强行杀死主库Patroni，则主库Patroni有大概率无法关停所管理的PostgreSQL主库实例。这会导致原主库PostgreSQL 实例在Patroni死亡后继续存活，而剩余的集群从库则会进行领导选举选出新的主库来，**从而导致脑裂**。

**操作说明**

```bash
# 关停主库上的Patroni主进程
ssh 10.10.10.3 "ps aux | grep /usr/bin/patroni | grep -v grep | awk '{print $2}'"
ssh 10.10.10.3 'sudo kill -9 723'
```

**操作结果**

该操作可能导致集群脑裂：因为Patroni暴死，无暇杀死自己管理的PostgreSQL进程。而其他集群成员则会在TTL超时后进行新一轮选举，选出新的主库。

如果您采用标准的基于负载均衡健康检查的服务[接入](c-service#接入)机制，**不会有问题**，因为原主库 Patroni已死，健康检查为假。即使该主库存活，负载均衡器也不会将流量分发至此实例。但如果您通过其他方式继续写入该主库，**则可能会出现脑裂**！

Patroni使用Watchdog机制对这种情况进行兜底，您需要视情况使用（参数 [`patroni_watchdog_mode`](v-pgsql.md#patroni_watchdog_mode) ）。启用watchdog时，如果原主库因为各种原因（Patroni暴死，机器负载假死，虚拟机调度，PG关机太慢）等原因，无法在Failover中及时关停PG主库以避免脑裂，则会使用Linux内核模块`softdog`强制关机以免脑裂。

<details><summary>patronictl list 结果</summary>

```bash
# 使用Kill -9 强杀 主库Patroni (pg-test-2) 
+ Cluster: pg-test (7037370797549923387) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Replica | running |  3 |         0 | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Leader  | running |  3 |           | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Replica | running |  3 |         0 | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+
# 因为Patroni暴死，PostgreSQL进程通常仍然会存活并且为主库状态
# 因为Patroni暴死，原主库的健康检查会立刻失败，导致主库流量没有实例承载，集群不可写入。

# 因为Patroni暴死，无暇释放 DCS中的Leader Key，因此上面的状态会保持TTL的时间。
# 直到 DCS 中的 Leader Lease 因为超时被释放（约15s），集群才意识到主库已死，发起Failover
+ Cluster: pg-test (7037370797549923387) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Replica | running |  3 |         0 | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Replica | running |  3 |         0 | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+

# 集群触发Failover，pg-test-1 成为新的集群领导者，开始承载只读流量，集群写入服务恢复
+ Cluster: pg-test (7037370797549923387) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Leader  | running |  4 |           | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Replica | running |  3 |         0 | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+

# 此时必须注意！原集群主库仍然存活并允许写入！！！
# 如果您采用标准的基于负载均衡健康检查的流量分发机制则不会有问题，因为Patroni已死，健康检查为假。
# 该主库存活，但负载均衡器不会将流量分发至此实例。但如果您通过其他方式直接写入该主库，则会出现脑裂！
$ psql -AXtwh 10.10.10.12 -d postgres -c 'select pg_is_in_recovery();'
t
```

</details>



**从这种情况中恢复**

当Patroni暴死时，您应当首先手工关闭由其管理的，仍在运行的原PostgreSQL主库实例。然后再重新启动Patroni，并由Patroni拉起PostgreSQL实例，如下所示：

```bash
/usr/pgsql/bin/pg_ctl -D /pg/data stop
systemctl restart patroni
```

如若不然，则可能出现Patroni无法正常启动的错误：

```bash
2021-12-03 14:16:18 +0800 INFO:  stderr=2021-12-03 14:16:18.752 HKT [7852] FATAL:  lock file "postmaster.pid" already exists
2021-12-03 14:16:18.752 HKT [7852] HINT:  Is another postmaster (PID 887) running in data directory "/pg/data"?
```



> 参数 [`patroni_watchdog_mode`](v-pgsql.md#patroni_watchdog_mode)  的说明：
>
> * 如果模式为 `required`，但`/dev/watchdog`不可用，不会影响Patroni启动，只会影响当前实例的领导候选人资格。
> * 如果模式为 `required`，但`/dev/watchdog`不可用，那么该实例无法作为合格的主库候选人，即无法参与Failover，即使手工强制指定也不行：会出现`Switchover failed, details: 412, switchover is not possible: no good candidates have been found` 的错误。若想解决此问题，修改`/pg/bin/patroni.yml`文件的`patroni_watchdog`选项为`automatic|off`即可。
> * 如果模式为`automatic`，则没有限制，无论`/dev/watchdog`可不可用，该实例都可以正常参选主库选举。
> * `/dev/watchdog` 可用需要两个条件，加载`softdog`内核模块，`/dev/watchdog`的属主为`postgres`（dbsu）
>





### 5A-主库DCS Agent不可用

在这种情况下，主库上的Patroni会因为无法连接至DCS服务，将自身降级为普通从库，但如果从库Patroni仍然意识到主库存活（例如，流复制仍然正常进行），并不会触发Failover！

在这种情况下，Pigsty的接入机制会因为原主库健康检查为假，**而导致整个集群进入无主状态，无法写入，需要特别关注**！


在维护模式下，不会有变化发生。



### 6A-主库负载打满，假死

TBD

### 7A-主库网络抖动


### 8A-误删主库数据目录



-----------------------





## 从库故障演练

### 1B-从库节点宕机

**操作说明**

```bash
ssh 10.10.10.3 sudo reboot    # 直接将 pg-test-1 主节点重启（VIP指向实际主节点）
```

**操作结果**

从库宕机会导致该节点上的 `HAPorxy` `Patroni`，`Postgres` 等服务不可用。通常业务侧会察觉到极少量的瞬时报错（与故障实例的连接会中断），而后集群中的其他负载均衡器会将此故障节点从后端列表中摘除。

请注意，如果集群为一主一从结构，且唯一一台从库宕机，那么离线查询服务可能会受到影响（没有可用承载实例）。

节点重启完成后，Patroni服务会自动拉起，实例会自动重新加入集群中。



### 2B-从库Postgres进程关停

**操作说明**

采用两种不同的方式关停从库 Postgres 实例：常规的 `pg_ctl` 与暴力的 `kill -9`

```bash
# 关停从库上的Postgres主进程
ssh 10.10.10.3 'sudo -iu postgres /usr/pgsql/bin/pg_ctl -D /pg/data stop'

# 查询从库PID并强行Kill
ssh 10.10.10.3 'sudo kill -9 $(sudo cat /pg/data/postmaster.pid | head -n1)'
```

**操作结果**

关停 Postgres 后，Patroni 会尝试重新拉起 Postgres 进程。如果成功，则集群恢复正常。如果

从库 宕机会导致该实例健康检查为Down，集群的负载均衡器不会将流量再分发至该实例，应用只读请求会有少量瞬时报错。






### 3B-从库Postgres进程手工关停


### 4B-从库Patroni进程异常Kill


### 5B-从库DCS Agent不可用


### 6B-从库负载打满，假死


### 7B-从库网络抖动


### 8B-误提升一个从库


-----------------------





## DCS故障演练

### 1C-DCS Server完全不可用

**DCS完全不可用是一个极其严重的故障，默认情况下将导致所有数据库集群不可写入**。 如果您使用L2 VIP接入，则默认绑定于主库节点的L2 VIP亦不可用，这意味着整集群可能都无法读写！您应当尽全力避免此种故障！

好在DCS本身便是为了解决此问题而生：本身采用分布式架构，并有可靠的容灾机制，能容忍各种常见的硬件故障。例如，3节点的DCS集群允许一台服务器出现故障，而5节点的DCS集群则最多允许两个服务器节点同时出现故障。

有一些方式可以缓解此问题。



关停 Consul 后，**所有** 启用高可用自动切换模式的数据库集群主库会触发降级逻辑（因为主库的Patroni意识不到其他集群成员的存在，须假定其他从库已经构成一个法定多数的分区并进行选举，因而要将自身降级为从库避免脑裂）

**操作说明**

关停元节点上的DCS Server，如果有3台，至少应当关停2台，如果有5台，至少应当关停3台。

```bash
systemctl stop consul
```

### 解决方案

1. 在维护模式下，用户失去了自动Failover的能力，但DCS故障不会导致主库不可写入。（仍可以手工快速切换）
2. 使用更多的DCS实例确保DCS的可用性（DCS本身便是为了解决此问题而生）
3. 为Patroni配置足够长的超时重试时间，并为DCS故障设置最高的响应优先级




### 2C-DCS通主库，不通从库（1主1从）


### 3C-DCS通主库，不通从库（1主n从，n>1）


### 4C-DCS通从库，不通主库（1主1从）


### 5C-DCS通从库，不通主库（1主n从，n>1）


### 6C-DCS网络抖动：同时中断，主库从库同时恢复，或主库先恢复


### 7C-DCS网络抖动：同时中断，从库先恢复，主库后恢复（1主1从）


### 8C-DCS网络抖动：同时中断，从库先恢复，主库后恢复（1主n从，n>1）




