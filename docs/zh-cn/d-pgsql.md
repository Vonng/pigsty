# PostgreSQL集群部署

> 本文介绍使用Pigsty部署PostgreSQL集群的典型用例：PGSQL相关[剧本](p-pgsql.md)与[配置](v-pgsql.md)。



## 身份参数

**核心身份参数**是定义 PostgreSQL 数据库集群时必须提供的信息，包括：

|                 名称                  |        属性        |   说明   |         例子         |
| :-----------------------------------: | :----------------: | :------: | :------------------: |
| [`pg_cluster`](v-pgsql.md#pg_cluster) | **必选**，集群级别 |  集群名  |      `pg-test`       |
|    [`pg_role`](v-pgsql.md#pg_role)    | **必选**，实例级别 | 实例角色 | `primary`, `replica` |
|     [`pg_seq`](v-pgsql.md#pg_seq)     | **必选**，实例级别 | 实例序号 | `1`, `2`, `3`,`...`  |

身份参数的内容遵循 [实体命名规则](c-entity.md) 。其中 [`pg_cluster`](v-pgsql.md#pg_cluster) ，[`pg_role`](v-pgsql.md#pg_role)，[`pg_seq`](v-pgsql.md#pg_seq) 属于核心身份参数，是定义数据库集群所需的**最小必须参数集**，核心身份参数**必须显式指定**，不可忽略。

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

### 定义水平分片数据库集簇

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

使用 `bin/createpg pg-test`，即可创建出该集群来。
如果您已经在第一步 [单机部署](#单机部署)中完成了`10.10.10.11`的部署，那么也可以使用 `bin/createpg 10.10.10.12`，进行集群扩容。



## 同步从库

正常情况下，PostgreSQL的复制延迟在几十KB/10ms的量级，对于常规业务而言可以近似忽略不计。

重要的是，当主库出现故障时，尚未完成复制的数据会丢失！当您在处理非常关键与精密的业务查询时（例如和钱打交道），复制延迟可能会成为一个问题。

此外，或者在主库写入后，立刻向从库查询刚才的写入（read-your-write），也会对复制延迟非常敏感。

为了解决此类问题，需要用到同步从库。 一种简单的配置同步从库的方式是使用 [`pg_conf`](v-pgsql.md#pg_conf) = `crit` 模板，该模板会自动启用同步复制。

或者，您可以在集群创建完毕后，通过在管理节点上执行 `pg edit-config <cluster.name>` ，编辑集群配置文件，修改修改参数

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



### 法定人数提交

在默认情况下，同步复制会从所有候选从库 **挑选一个实例**，作为同步从库，任何主库事务只有当复制到从库并Flush至磁盘上时，方视作成功提交并返回。 

如果我们期望更高的数据持久化保证，例如，在一个一主三从的四实例集群中，至少有两个从库成功刷盘后才确认提交，则可以使用法定人数提交。

使用法定人数提交时，需要修改 PostgreSQL 中 `synchronous_standby_names` 参数的值，并配套修改Patroni中 [`synchronous_node_count`](https://patroni.readthedocs.io/en/latest/replication_modes.html#synchronous-replication-factor) 的值。

假设三个从库分别为 `pg-test-2, pg-test-3, pg-test-4` ，那么应当配置：

* `synchronous_standby_names = ANY 2 (pg-test-2, pg-test-3, pg-test-4)`
* `synchronous_node_count : 2`




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

使用 `bin/createpg pg-test`，即可创建出该集群来。
如果您已经完成了第一步 [单机部署](#单机部署)与第二步 [主从集群](#主从集群)，那么可以使用 `bin/createpg 10.10.10.13`，进行集群扩容，向集群中添加一台离线从库实例。




## 备份集群

您可以使用 Standby Cluster 的方式，制作现有集群的克隆。使用这种方式，您可以从现有数据库平滑迁移至Pigsty集群中。

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
    pg_cluster: pg-test
    pg_version: 14          # 制作Standby Cluster时，数据库大版本必须保持一致！
```

```bash
bin/createpg pg-test     # 创建原始集群
bin/createpg pg-test2    # 创建备份集群

```


## 延迟从库

延时从库


## 级连复制

