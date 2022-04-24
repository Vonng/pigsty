# PostgreSQL集群部署

> 本文介绍使用Pigsty部署PostgreSQL集群的几种不同方式：PGSQL相关[剧本](p-pgsql.md)与[配置](v-pgsql.md)请参考相关文档。



* [身份参数](#身份参数)：介绍定义标准PostgreSQL高可用集群所需的身份参数。
* [单机部署](#单机部署)：定义一个单实例的PostgreSQL集群
* [主从集群](#主从集群)：定义一个一主一从的标准可用性集群。
* [同步从库](#同步从库)：定义一个同步复制，RPO = 0 的高一致性集群。
* [法定人数同步提交](#法定人数同步提交)：定义数据一致性更高的集群：多数从库成功方返回提交。
* [离线从库](#离线从库)：用于单独承载OLAP分析，ETL，交互式个人查询的专用实例
* [备份集群](#备份集群)：制作现有集群的实时在线克隆，用于异地灾备或延迟从库。
* [延迟从库](#延迟从库)：用于应对误删表删库等软件/人为故障，比PITR更快。
* [级联复制](#级联复制)：用于搭建一个集群内的级联复制，针对大量从库场景（20+），降低主库复制压力。
* [Citus集群部署](#Citus集群部署)：部署Citus分布式数据库集群
* [MatrixDB集群部署](#MatrixDB集群部署)：部署Greenplum7/PostgreSQL12兼容的时序数据仓库。



## 身份参数

**核心身份参数**是定义 PostgreSQL 数据库集群时必须提供的信息，包括：

|                 名称                  |        属性        |   说明   |         例子         |
| :-----------------------------------: | :----------------: | :------: | :------------------: |
| [`pg_cluster`](v-pgsql.md#pg_cluster) | **必选**，集群级别 |  集群名  |      `pg-test`       |
|    [`pg_role`](v-pgsql.md#pg_role)    | **必选**，实例级别 | 实例角色 | `primary`, `replica` |
|     [`pg_seq`](v-pgsql.md#pg_seq)     | **必选**，实例级别 | 实例序号 | `1`, `2`, `3`,`...`  |

身份参数的内容遵循 [实体命名规则](c-pgsql.md#实体模型) 。其中 [`pg_cluster`](v-pgsql.md#pg_cluster) ，[`pg_role`](v-pgsql.md#pg_role)，[`pg_seq`](v-pgsql.md#pg_seq) 属于核心身份参数，是定义数据库集群所需的**最小必须参数集**，核心身份参数**必须显式指定**，不可忽略。

- `pg_cluster` 标识了集群的名称，在集群层面进行配置，作为集群资源的顶层命名空间。

- `pg_role`标识了实例在集群中扮演的角色，在实例层面进行配置，可选值包括：

  - `primary`：集群中的**唯一主库**，集群领导者，提供写入服务。
  - `replica`：集群中的**普通从库**，承接常规生产只读流量。
  - `offline`：集群中的**离线从库**，承接ETL/SAGA/个人用户/交互式/分析型查询。
  - `standby`：集群中的**同步从库**，采用同步复制，没有复制延迟（保留）。
  - `delayed`：集群中的**延迟从库**，显式指定复制延迟，用于执行回溯查询与数据抢救（保留）。

- `pg_seq` 用于在集群内标识实例，通常采用从0或1开始递增的整数，一旦分配不再更改。

- `pg_shard` 用于标识集群所属的上层 **分片集簇**，只有当集群是水平分片集簇的一员时需要设置。

- `pg_sindex` 用于标识集群的**分片集簇**编号，只有当集群是水平分片集簇的一员时需要设置。

- `pg_instance` 是**衍生身份参数**，用于唯一标识一个数据库实例，其构成规则为

  `{{ pg_cluster }}-{{ pg_seq }}`。 因为`pg_seq`是集群内唯一的，因此该标识符全局唯一。



### 水平分片集簇

`pg_shard` 与`pg_sindex` 用于定义特殊的分片数据库集簇，是可选的身份参数，目前为Citus与Greenplum保留。

假设用户有一个水平分片的 **分片数据库集簇（Shard）** ，名称为`test`。这个集簇由四个独立的集群组成：`pg-test1`, `pg-test2`，`pg-test3`，`pg-test-4`。则用户可以将 `pg_shard: test` 的身份绑定至每一个数据库集群，将`pg_sindex: 1|2|3|4` 分别绑定至每一个数据库集群上。如下所示：

```yaml
pg-test1:
  vars: {pg_cluster: pg-test1, pg_shard: test, pg_sindex: 1}
  hosts: {10.10.10.10: {pg_seq: 1, pg_role: primary}}
pg-test2:
  vars: {pg_cluster: pg-test1, pg_shard: test, pg_sindex: 2}
  hosts: {10.10.10.11: {pg_seq: 1, pg_role: primary}}
pg-test3:
  vars: {pg_cluster: pg-test1, pg_shard: test, pg_sindex: 3}
  hosts: {10.10.10.12: {pg_seq: 1, pg_role: primary}}
pg-test4:
  vars: {pg_cluster: pg-test1, pg_shard: test, pg_sindex: 4}
  hosts: {10.10.10.13: {pg_seq: 1, pg_role: primary}}
```

通过这样的定义，您可以方便地从 PGSQL Shard 监控面板中，观察到这四个水平分片集群的横向指标对比。同样的功能对于 [Citus](#Citus集群) 与 MatrixDB集群同样有效。





## 单机部署

让我们从最简单的案例开始：

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
  vars:
    pg_cluster: pg-test
```

使用以下命令，在 `10.10.10.11` 节点上创建一个单主的数据库实例。

```bash
bin/createpg pg-test
```





## 主从集群

复制可以极大高数据库系统可靠性，是应对硬件故障的最佳手段。

Pigsty原生支持设置主从复制，例如，声明一个典型的一主一从高可用数据库集群，可以使用：

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
  vars:
    pg_cluster: pg-test
```

使用 `bin/createpg pg-test`，即可创建出该集群来。如果您已经在第一步 [单机部署](#单机部署)中完成了`10.10.10.11`的部署，那么也可以使用 `bin/createpg 10.10.10.12`，进行集群扩容。





## 同步从库

正常情况下，PostgreSQL的复制延迟在几十KB/10ms的量级，对于常规业务而言可以近似忽略不计。

重要的是，当主库出现故障时，尚未完成复制的数据会丢失！当您在处理非常关键与精密的业务查询时（例如和钱打交道），复制延迟可能会成为一个问题。此外，或者在主库写入后，立刻向从库查询刚才的写入（read-your-write），也会对复制延迟非常敏感。

为了解决此类问题，需要用到同步从库。 一种简单的配置同步从库的方式是使用 [`pg_conf`](v-pgsql.md#pg_conf) = `crit` 模板，该模板会自动启用同步复制。

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
    10.10.10.13: { pg_seq: 3, pg_role: replica }
  vars:
    pg_cluster: pg-test
    pg_conf: crit.yml
```

或者，您可以在集群创建完毕后，通过在元节点上执行 `pg edit-config <cluster.name>` ，编辑集群配置文件，修改参数`synchronous_mode`的值为`true`并应用即可。

```bash
$ pg edit-config pg-test
---
+++
-synchronous_mode: false
+synchronous_mode: true
 synchronous_mode_strict: false

Apply these changes? [y/N]: y
```





## 法定人数同步提交

在默认情况下，同步复制会从所有候选从库 **挑选一个实例**，作为同步从库，任何主库事务只有当复制到从库并Flush至磁盘上时，方视作成功提交并返回。 如果我们期望更高的数据持久化保证，例如，在一个一主三从的四实例集群中，至少有两个从库成功刷盘后才确认提交，则可以使用法定人数提交。

使用法定人数提交时，需要修改 PostgreSQL 中 `synchronous_standby_names` 参数的值，并配套修改Patroni中 [`synchronous_node_count`](https://patroni.readthedocs.io/en/latest/replication_modes.html#synchronous-replication-factor) 的值。假设三个从库分别为 `pg-test-2, pg-test-3, pg-test-4` ，那么应当配置：

* `synchronous_standby_names = ANY 2 (pg-test-2, pg-test-3, pg-test-4)`
* `synchronous_node_count : 2`

```bash
pg-test:
  hosts:
    10.10.10.10: { pg_seq: 1, pg_role: primary } # pg-test-1
    10.10.10.11: { pg_seq: 2, pg_role: replica } # pg-test-2
    10.10.10.12: { pg_seq: 3, pg_role: replica } # pg-test-3
    10.10.10.13: { pg_seq: 4, pg_role: replica } # pg-test-4
  vars:
    pg_cluster: pg-test
```

执行`pg edit-config pg-test`，并修改配置如下：

```bash
$ pg edit-config pg-test
---
+++
@@ -82,10 +82,12 @@
     work_mem: 4MB
+    synchronous_standby_names: 'ANY 2 (pg-test-2, pg-test-3, pg-test-4)'
 
-synchronous_mode: false
+synchronous_mode: true
+synchronous_node_count: 2
 synchronous_mode_strict: false

Apply these changes? [y/N]: y
```

应用后，即可看到配置生效，出现两个Sync Standby，当集群出现Failover或扩缩容时，请相应调整这些参数以免服务不可用。

```bash
+ Cluster: pg-test (7080814403632534854) +---------+----+-----------+-----------------+
| Member    | Host        | Role         | State   | TL | Lag in MB | Tags            |
+-----------+-------------+--------------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.10 | Leader       | running |  1 |           | clonefrom: true |
| pg-test-2 | 10.10.10.11 | Sync Standby | running |  1 |         0 | clonefrom: true |
| pg-test-3 | 10.10.10.12 | Sync Standby | running |  1 |         0 | clonefrom: true |
| pg-test-4 | 10.10.10.13 | Replica      | running |  1 |         0 | clonefrom: true |
+-----------+-------------+--------------+---------+----+-----------+-----------------+
```






## 离线从库

当您的在线业务请求负载水位很大时，将数据分析/ETL/个人交互式查询放置在专用的离线只读从库上是一个更为合适的选择。

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
    10.10.10.13: { pg_seq: 2, pg_role: offline } # 定义一个新的Offline实例
  vars:
    pg_cluster: pg-test
```

使用 `bin/createpg pg-test`，即可创建出该集群来。如果您已经完成了第一步 [单机部署](#单机部署)与第二步 [主从集群](#主从集群)，那么可以使用 `bin/createpg 10.10.10.13`，进行集群扩容，向集群中添加一台离线从库实例。

离线从库默认不承载  [`replica`](c-service.md#replica服务)  服务，只有当所有   [`replica`](c-service.md#replica服务)  服务中的实例均不可用时，离线实例才会用于紧急承载只读流量。如果您只有一主一从，或者干脆只有一个主库，没有专用的离线实例，可以通过为该实例设置 [`pg_offline_query`](v-pgsql.md#pg_offline_query) 标记，该实例仍然扮演原来的角色，但同时也承载  [`offline`](c-service.md#offline服务)  服务，用作 **准离线实例**。








## 备份集群

您可以使用 Standby Cluster 的方式，制作现有集群的克隆，使用这种方式，您可以从现有数据库平滑迁移至Pigsty集群中。

创建 Standby Cluster 的方式无比简单，您只需要确保备份集群的主库上配置有合适的 [`pg_upstream`](v-pgsql.md#pg_upstream) 参数，即可自动从原始上游拉取备份。

```yaml
# pg-test是原始数据库
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
  vars:
    pg_cluster: pg-test
    pg_version: 14


# pg-test2将作为pg-test1的Standby Cluster
pg-test2:
  hosts:
    10.10.10.12: { pg_seq: 1, pg_role: primary , pg_upstream: 10.10.10.11 } # 实际角色为 Standby Leader
    10.10.10.13: { pg_seq: 2, pg_role: replica }
  vars:
    pg_cluster: pg-test2
    pg_version: 14          # 制作Standby Cluster时，数据库大版本必须保持一致！
```

```bash
bin/createpg pg-test     # 创建原始集群
bin/createpg pg-test2    # 创建备份集群
```

### 提升备份集群

当您想要将整个备份集群提升为一个独立运作的集群时，编辑新集群的Patroni配置文件，移除所有`standby_cluster`配置，备份集群中的Standby Leader会被提升为独立的主库。

```bash
pg edit-config pg-test2  # 移除 standby_cluster 配置定义并应用
```

移除下列配置：整个`standby_cluster`定义部分。

```bash
-standby_cluster:
-  create_replica_methods:
-  - basebackup
-  host: 10.10.10.11
-  port: 5432
```

### 修改备份集群上游复制源

当源集群发生Failover主库发生变化时，您需要调整备份集群的复制源。执行`pg edit-config <cluster>`，并修改`standby_cluster`中的源地址为新主库，应用即可生效。这里需要注意，从源集群的从库进行复制是**可行的**，源集群发生Failover并不会影响备份集群的复制。但新集群在只读从库上无法创建复制槽，可能出现相关报错，并存在潜在的复制中断风险，建议及时调整备份集群的上游复制源。

```yaml
 standby_cluster:
   create_replica_methods:
   - basebackup
-  host: 10.10.10.13
+  host: 10.10.10.12
   port: 5432
```

修改 `standby_cluster.host` 中复制上游的IP地址，应用即可生效（无需重启，Reload即可）。





## 延迟从库

高可用与主从复制可以解决机器硬件故障带来的问题，但无法解决软件Bug与人为操作导致的故障，例如：误删库删表。误删数据通常需要用到[冷备份](t-backup.md)，但另一种更优雅高效快速的方式是事先准备一个延迟从库。

您可以使用 [备份集群](#备份集群) 的功能创建延时从库，例如，现在您希望为`pg-test` 集群指定一个延时从库：`pg-testdelay`，该集群是`pg-test`1小时前的状态。因此如果出现了误删数据，您可以立即从延时从库中获取并回灌入原始集群中。


```yaml
# pg-test是原始数据库
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
  vars:
    pg_cluster: pg-test
    pg_version: 14

# pg-testdelay 将作为 pg-test 库的延时从库
pg-testdelay:
  hosts:
    10.10.10.12: { pg_seq: 1, pg_role: primary , pg_upstream: 10.10.10.11 } # 实际角色为 Standby Leader
  vars:
    pg_cluster: pg-testdelay
    pg_version: 14          
```

创建完毕后，在元节点使用 `pg edit-config pg-testdelay`编辑延时集群的Patroni配置文件，修改 `standby_cluster.recovery_min_apply_delay` 为你期待的值，例如`1h`，应用即可。

```bash
 standby_cluster:
   create_replica_methods:
   - basebackup
   host: 10.10.10.11
   port: 5432
+  recovery_min_apply_delay: 1h
```




## 级连复制

在创建集群时，如果为集群中的某个**从库**指定 [`pg_upstream`](v-pgsql.md#pg_upstream) 参数（指定为集群中**另一个从库**），那么该实例将尝试从该指定从库构建逻辑复制。

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica } # 尝试从2号从库而非主库复制
    10.10.10.13: { pg_seq: 2, pg_role: replica, pg_upstream: 10.10.10.12 }
  vars:
    pg_cluster: pg-test
```









## Citus集群部署

[Citus](https://www.citusdata.com/)是一个PostgreSQL生态的分布式扩展插件，默认情况下Pigsty安装Citus，但不启用。 [`pigsty-citus.yml`](https://github.com/Vonng/pigsty/blob/master/files/conf/pigsty-citus.yml) 提供了一个部署Citus集群的配置文件案例。为了启用Citus，您需要修改以下参数：

* `max_prepared_transaction`： 修改为一个大于`max_connections`的值，例如800。
* [`pg_shared_libraries`](v-pgsql.md#pg_shared_libraries)：必须包含`citus`，并放置在最前的位置。
* 您需要在[业务数据库](c-pgdbuser.md#数据库)中包含 `citus` 扩展插件（但您也可以事后手工通过`CREATE EXTENSION`自行安装）

<details><summary>Citus集群样例配置</summary>

```yaml
#----------------------------------#
# cluster: citus coordinator
#----------------------------------#
pg-meta:
  hosts:
    10.10.10.10: { pg_seq: 1, pg_role: primary , pg_offline_query: true }
  vars:
    pg_cluster: pg-meta
    vip_address: 10.10.10.2
    pg_users: [ { name: citus , password: citus , pgbouncer: true , roles: [ dbrole_admin ] } ]
    pg_databases: [ { name: meta , owner: citus , extensions: [ { name: citus } ] } ]

#----------------------------------#
# cluster: citus data nodes
#----------------------------------#
pg-node1:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
  vars:
    pg_cluster: pg-node1
    vip_address: 10.10.10.3
    pg_users: [ { name: citus , password: citus , pgbouncer: true , roles: [ dbrole_admin ] } ]
    pg_databases: [ { name: meta , owner: citus , extensions: [ { name: citus } ] } ]

pg-node2:
  hosts:
    10.10.10.12: { pg_seq: 1, pg_role: primary  , pg_offline_query: true }
  vars:
    pg_cluster: pg-node2
    vip_address: 10.10.10.4
    pg_users: [ { name: citus , password: citus , pgbouncer: true , roles: [ dbrole_admin ] } ]
    pg_databases: [ { name: meta , owner: citus , extensions: [ { name: citus } ] } ]

pg-node3:
  hosts:
    10.10.10.13: { pg_seq: 1, pg_role: primary  , pg_offline_query: true }
  vars:
    pg_cluster: pg-node3
    vip_address: 10.10.10.5
    pg_users: [ { name: citus , password: citus , pgbouncer: true , roles: [ dbrole_admin ] } ]
    pg_databases: [ { name: meta , owner: citus , extensions: [ { name: citus } ] } ]

```

</details>

接下来，您需要参照[Citus多节点部署指南](https://docs.citusdata.com/en/latest/installation/multi_node_rhel.html)，在 Coordinator 节点上，执行以下命令以添加数据节点：

```bash
sudo su - postgres; psql meta 
SELECT * from citus_add_node('10.10.10.11', 5432);
SELECT * from citus_add_node('10.10.10.12', 5432);
SELECT * from citus_add_node('10.10.10.13', 5432);
```

```bash
SELECT * FROM citus_get_active_worker_nodes();
  node_name  | node_port
-------------+-----------
 10.10.10.11 |      5432
 10.10.10.13 |      5432
 10.10.10.12 |      5432
(3 rows)
```

成功添加数据节点后，您可以使用以下命令，在协调者上创建样例数据表，并将其分布到每个数据节点上。

```sql
-- 声明一个分布式表
CREATE TABLE github_events
(
    event_id     bigint,
    event_type   text,
    event_public boolean,
    repo_id      bigint,
    payload      jsonb,
    repo         jsonb,
    actor        jsonb,
    org          jsonb,
    created_at   timestamp
) PARTITION BY RANGE (created_at);
-- 创建分布式表
SELECT create_distributed_table('github_events', 'repo_id');
```

更多Citus相关功能介绍，请参考[Citus官方文档](https://docs.citusdata.com/en/v11.0-beta/)。





## MatrixDB集群部署

Greenplum是基于PostgreSQL生态构建的分布式数据仓库，广受广大用户喜爱。MatrixDB是Greenplum的一个分支，基于Greenplum 7 ，使用PostgreSQL 12内核。因为Greenplum 7尚未正式发布，因此Pigsty目前使用MatrixDB作为Greenplum的替代实现。

因为MatrixDB基于PostgreSQL生态，因此大多数PostgreSQL剧本与任务可以复用在 MatrixDB 上。MatrixDB 专用的额外参数只有两个：

* [`gp_role`](v-pgsql.md#gp_role)：定义Greenplum集群的身份，`master`或 `segment`。
* [`pg_instances`](v-pgsql.md#pg_instances)：定义Segment实例，用于部署Segment实例监控。

详情请参考 [MatrixDB部署](d-matrixdb.md)

<details><summary>MatrixDB集群样例配置 4节点</summary>

```yaml
#----------------------------------#
# cluster: mx-mdw (gp master)
#----------------------------------#
mx-mdw:
  hosts:
    10.10.10.10: { pg_seq: 1, pg_role: primary , nodename: mx-mdw-1 }
  vars:
    gp_role: master          # this cluster is used as greenplum master
    pg_shard: mx             # pgsql sharding name & gpsql deployment name
    pg_cluster: mx-mdw       # this master cluster name is mx-mdw
    pg_databases:
      - { name: matrixmgr , extensions: [ { name: matrixdbts } ] }
      - { name: meta }
    pg_users:
      - { name: meta , password: DBUser.Meta , pgbouncer: true }
      - { name: dbuser_monitor , password: DBUser.Monitor , roles: [ dbrole_readonly ], superuser: true }

    pgbouncer_enabled: true                # enable pgbouncer for greenplum master
    pgbouncer_exporter_enabled: false      # enable pgbouncer_exporter for greenplum master
    pg_exporter_params: 'host=127.0.0.1&sslmode=disable'  # use 127.0.0.1 as local monitor host

#----------------------------------#
# cluster: mx-sdw (gp master)
#----------------------------------#
mx-sdw:
  hosts:
    10.10.10.11:
      nodename: mx-sdw-1        # greenplum segment node
      pg_instances:             # greenplum segment instances
        6000: { pg_cluster: mx-seg1, pg_seq: 1, pg_role: primary , pg_exporter_port: 9633 }
        6001: { pg_cluster: mx-seg2, pg_seq: 2, pg_role: replica , pg_exporter_port: 9634 }
    10.10.10.12:
      nodename: mx-sdw-2
      pg_instances:
        6000: { pg_cluster: mx-seg2, pg_seq: 1, pg_role: primary , pg_exporter_port: 9633  }
        6001: { pg_cluster: mx-seg3, pg_seq: 2, pg_role: replica , pg_exporter_port: 9634  }
    10.10.10.13:
      nodename: mx-sdw-3
      pg_instances:
        6000: { pg_cluster: mx-seg3, pg_seq: 1, pg_role: primary , pg_exporter_port: 9633 }
        6001: { pg_cluster: mx-seg1, pg_seq: 2, pg_role: replica , pg_exporter_port: 9634 }
  vars:
    gp_role: segment               # these are nodes for gp segments
    pg_shard: mx                   # pgsql sharding name & gpsql deployment name
    pg_cluster: mx-sdw             # these segment clusters name is mx-sdw
    pg_preflight_skip: true        # skip preflight check (since pg_seq & pg_role & pg_cluster not exists)
    pg_exporter_config: pg_exporter_basic.yml   # use basic config to avoid segment server crash
    pg_exporter_params: 'options=-c%20gp_role%3Dutility&sslmode=disable'  # use gp_role = utility to connect to segments

```

</details>