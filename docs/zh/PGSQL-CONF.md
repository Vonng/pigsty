# PostgreSQL 集群配置

> 根据需求场景选择合适的实例与集群类型，配置出满足需求的 PostgreSQL 数据库集群。

您可以定义不同类型的实例和集群，下面是 Pigsty 中常见的几种 PostgreSQL 实例/集群类型：

- [读写主库](#读写主库)：定义单一实例集群。
- [只读从库](#只读从库)：定义具有一个主库和一个副本的基本HA集群。
- [离线从库](#离线从库)：定义专用于OLAP/ETL/交互式查询的实例
- [同步备库](#同步备库)：启用同步提交以确保没有数据丢失。
- [法定人数提交](#法定人数提交)：使用多数同步提交获得更高的一致性级别。
- [备份集群](#备份集群)：克隆现有集群并跟随它
- [延迟集群](#延迟集群)：克隆现有集群用于紧急数据恢复
- [Citus集群](#citus集群)：定义一个Citus分布式数据库集群
- [大版本切换](#大版本切换)：使用不同的PostgreSQL大版本


----------------

## 读写主库

我们从最简单的情况开始：由一个主库（Primary）组成的单实例集群：

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
  vars:
    pg_cluster: pg-test
```

这段配置言简意赅，仅由[身份参数](PGSQL-ARCH#身份参数)构成。

使用以下命令在节点 `10.10.10.11` 上创建一个主库实例：

```bash
bin/pgsql-add pg-test
```

Demo展示，开发测试，承载临时需求，进行无关紧要的计算分析任务时，使用单一数据库实例可能并没有太大问题。但这样的单机集群没有[高可用](PGSQL-ARCH#高可用)，当出现硬件故障时，您需要使用 [PITR](PGSQL-PITR) 或其他恢复手段来确保集群的 RTO / RPO。为此，您可以考虑为集群添加若干个[只读从库](#只读从库)


----------------

## 只读从库

要添加一台只读从库（Replica）实例，您可以在 `pg-test` 中添加一个新节点，并将其 [`pg_role`](PARAM#pg_role) 设置为`replica`。

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }  # <--- 新添加的从库
  vars:
    pg_cluster: pg-test
```

如果整个集群不存在，您可以直接[创建](PGSQL-ADMIN#创建集群)这个完整的集群。 如果集群主库已经初始化好了，那么您可以向现有集群[添加](PGSQL-ADMIN#添加实例)一个从库：

```bash
bin/pgsql-add pg-test               # 一次性初始化整个集群
bin/pgsql-add pg-test 10.10.10.12   # 添加从库到现有的集群
```

当集群主库出现故障时，只读实例（Replica）可以在高可用系统的帮助下接管主库的工作。除此之外，只读实例还可以用于执行只读查询：许多业务的读请求要比写请求多很多，而大部分只读查询负载都可以由从库实例承担。



----------------

## 离线从库

离线实例（Offline）是专门用于服务慢查询、ETL、OLAP流量和交互式查询等的专用只读从库。慢查询/长事务对在线业务的性能与稳定性有不利影响，因此最好将它们与在线业务隔离开来。

要添加离线实例，请为其分配一个新实例，并将[`pg_role`](PARAM#pg_role)设置为`offline`。

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
    10.10.10.13: { pg_seq: 2, pg_role: offline }  # <--- 新添加的离线从库
  vars:
    pg_cluster: pg-test
```

专用离线实例的工作方式与常见的从库实例类似，但它在 `pg-test-replica` 服务中用作备份服务器。 也就是说，只有当所有`replica`实例都宕机时，离线和主实例才会提供此项只读服务。

许多情况下，数据库资源有限，单独使用一台服务器作为离线实例是不经济的做法。作为折中，您可以选择一台现有的从库实例，打上 [`pg_offline_query`](PARAM#pg_offline_query) 标记，将其标记为一台可以承载“离线查询”的实例。在这种情况下，这台只读从库会同时承担在线只读请求与离线类查询。您可以使用 [`pg_default_hba_rules`](PARAM#pg_default_hba_rules)和[`pg_hba_rules`](PARAM#pg_hba_rules) 对离线实例进行额外的访问控制。




----------------

## 同步备库

当启用同步备库（Sync Standby）时，PostgreSQL 将选择一个从库作为**同步备库**，其他所有从库作为**候选者**。 主数据库会等待备库实例刷新到磁盘，然后才确认提交，备库实例始终拥有最新的数据，没有复制延迟，主从切换至同步备库不会有数据丢失。

PostgreSQL 默认使用异步流复制，这可能会有小的复制延迟（10KB / 10ms 数量级）。当主库失败时，可能会有一个小的数据丢失窗口（可以使用[`pg_rpo`](PARAM#pg_rpo)来控制），但对于大多数场景来说，这是可以接受的。

但在某些关键场景中（例如，金融交易），数据丢失是完全不可接受的，或者，读取复制延迟是不可接受的。在这种情况下，您可以使用同步提交来解决这个问题。 要启用同步备库模式，您可以简单地使用[`pg_conf`](PARAM#pg_conf)中的`crit.yml`模板。

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
    10.10.10.13: { pg_seq: 3, pg_role: replica }
  vars:
    pg_cluster: pg-test
    pg_conf: crit.yml   # <--- 使用 crit 模板
```

要在现有集群上启用同步备库，请[配置集群](PGSQL-ADMIN#配置集群)并启用 `synchronous_mode`：

```bash
$ pg edit-config pg-test    # 在管理员节点以管理员用户身份运行
+++
-synchronous_mode: false    # <--- 旧值
+synchronous_mode: true     # <--- 新值
 synchronous_mode_strict: false

应用这些更改？[y/N]: y
```

在这种情况下，PostgreSQL 配置项 [`synchronous_standby_names`](https://www.postgresql.org/docs/current/runtime-config-replication.html#synchronous_standby_names) 由 Patroni 自动管理。
一台从库将被选拔为同步从库，它的 `application_name` 将被写入 PostgreSQL 主库配置文件中并应用生效。



----------------

## 法定人数提交

法定人数提交（Quorum Commit）提供了比同步备库更强大的控制能力：特别是当您有多个从库时，您可以设定提交成功的标准，实现更高/更低的一致性级别（以及可用性之间的权衡）。

如果想要**最少两个从**库来确认提交，可以通过 Patroni [配置集群](PGSQL-ADMIN#配置集群)，调整参数 [`synchronous_node_count`](https://patroni.readthedocs.io/en/latest/replication_modes.html#synchronous-replication-factor) 并应用生效

```yaml
synchronous_mode: true          # 确保同步提交已经启用
synchronous_node_count: 2       # 指定“至少”有多少个从库提交成功，才算提交成功
```

如果你想要使用更多的同步从库，修改 `synchronous_node_count` 的取值即可。当集群的规模发生变化时，您应当确保这里的配置仍然是有效的，以避免服务不可用。

在这种情况下，PostgreSQL 配置项 [`synchronous_standby_names`](https://www.postgresql.org/docs/current/runtime-config-replication.html#synchronous_standby_names) 由 Patroni 自动管理。

```yaml
synchronous_standby_names = '2 ("pg-test-3","pg-test-2")'
```

<details><summary>示例：使用多个同步从库</summary>

```bash
$ pg edit-config pg-test
---
+synchronous_node_count: 2

Apply these changes? [y/N]: y
```

应用配置后，出现两个同步备库。

```bash
+ Cluster: pg-test (7080814403632534854) +---------+----+-----------+-----------------+
| Member    | Host        | Role         | State   | TL | Lag in MB | Tags            |
+-----------+-------------+--------------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.10 | Leader       | running |  1 |           | clonefrom: true |
| pg-test-2 | 10.10.10.11 | Sync Standby | running |  1 |         0 | clonefrom: true |
| pg-test-3 | 10.10.10.12 | Sync Standby | running |  1 |         0 | clonefrom: true |
+-----------+-------------+--------------+---------+----+-----------+-----------------+
```

</details>

另一种情景是，使用 **任意n个** 从库来确认提交。在这种情况下，配置的方式略有不同，例如，假设我们只需要任意一个从库确认提交：

```yaml
synchronous_mode: quorum        # 使用法定人数提交
postgresql:
  parameters:                   # 修改 PostgreSQL 的配置参数 synchronous_standby_names ，使用 `ANY n ()` 语法
    synchronous_standby_names: 'ANY 1 (*)'  # 你可以指定具体的从库列表，或直接使用 * 通配所有从库。
```

<details><summary>示例：启用ANY法定人数提交</summary>

```bash
$ pg edit-config pg-test

+    synchronous_standby_names: 'ANY 1 (*)' # 在 ANY 模式下，需要使用此参数
- synchronous_node_count: 2  # 在 ANY 模式下， 不需要使用此参数

Apply these changes? [y/N]: y
```

应用后，配置生效，所有备库在 Patroni 中变为普通的 replica。但是在 `pg_stat_replication` 中可以看到 `sync_state` 会变为 `quorum`。

</details>




----------------

## 备份集群

您可以克隆现有的集群，并创建一个备份集群（Standby Cluster），用于数据迁移、水平拆分、多区域部署，或灾难恢复。

在正常情况下，备份集群将追随上游集群并保持内容同步，您可以将备份集群提升，作为真正地独立集群。

备份集群的定义方式与正常集群的定义基本相同，除了在主库上额外定义了 [`pg_upstream`](PARAM#pg_upstream) 参数，备份集群的主库被称为 **备份集群领导者** （Standby Leader）。

例如，下面定义了一个`pg-test`集群，以及其备份集群`pg-test2`，其配置清单可能如下所示：

```yaml
# pg-test 是原始集群
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
  vars: { pg_cluster: pg-test }

# pg-test2 是 pg-test 的备份集群
pg-test2:
  hosts:
    10.10.10.12: { pg_seq: 1, pg_role: primary , pg_upstream: 10.10.10.11 } # <--- pg_upstream 在这里定义
    10.10.10.13: { pg_seq: 2, pg_role: replica }
  vars: { pg_cluster: pg-test2 }
```

而 `pg-test2` 集群的主节点 `pg-test2-1` 将是 `pg-test` 的下游从库，并在`pg-test2`集群中充当备份集群领导者（**Standby Leader**）。

只需确保备份集群的主节点上配置了[`pg_upstream`](PARAM#pg_upstream)参数，以便自动从原始上游拉取备份。

```bash
bin/pgsql-add pg-test     # 创建原始集群
bin/pgsql-add pg-test2    # 创建备份集群
```

<details><summary>示例：更改复制上游</summary>

如有必要（例如，上游发生主从切换/故障转移），您可以通过[配置集群](PGSQL-ADMIN#配置集群)更改备份集群的复制上游。

要这样做，只需将`standby_cluster.host`更改为新的上游IP地址并应用。

```bash
$ pg edit-config pg-test2

 standby_cluster:
   create_replica_methods:
   - basebackup
-  host: 10.10.10.13     # <--- 旧的上游
+  host: 10.10.10.12     # <--- 新的上游
   port: 5432

 Apply these changes? [y/N]: y
```

</details>



<details><summary>示例：提升备份集群</summary>

你可以随时将备份集群提升为独立集群，这样该集群就可以独立承载写入请求，并与原集群分叉。

为此，你必须[配置](PGSQL-ADMIN#配置集群)该集群并完全擦除`standby_cluster`部分，然后应用。

```bash
$ pg edit-config pg-test2
-standby_cluster:
-  create_replica_methods:
-  - basebackup
-  host: 10.10.10.11
-  port: 5432

Apply these changes? [y/N]: y
```

</details>



 <details><summary>示例：级联复制</summary>

如果您在一台从库上指定了 [`pg_upstream`](PARAM#pg_upstream)，而不是主库。那么可以配置集群的 **级联复制**（Cascade Replication）

在配置级联复制时，您必须使用集群中某一个实例的IP地址作为参数的值，否则初始化会报错。该从库从特定的实例进行流复制，而不是主库。

这台充当 WAL 中继器的实例被称为 **桥接实例**（Bridge Instance）。使用桥接实例可以分担主库发送 WAL 的负担，当您有几十台从库时，使用桥接实例级联复制是一个不错的注意。

```yaml
pg-test:
  hosts: # pg-test-1 ---> pg-test-2 ---> pg-test-3
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica } # <--- 桥接实例
    10.10.10.13: { pg_seq: 2, pg_role: replica, pg_upstream: 10.10.10.12 }
    # ^--- 从 pg-test-2 (桥接)复制，而不是从 pg-test-1 (主节点) 
  vars: { pg_cluster: pg-test }
```

</details>





----------------

## 延迟集群

延迟集群（Delayed Cluster）是一种特殊类型的[备份集群](备份集群)，用于尽快恢复“意外删除”的数据。

例如，如果你希望有一个名为 `pg-testdelay` 的集群，其数据内容与一小时前的 `pg-test` 集群相同：

```yaml
# pg-test 是原始集群
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
  vars: { pg_cluster: pg-test }

# pg-testdelay 是 pg-test 的延迟集群
pg-testdelay:
  hosts:
    10.10.10.12: { pg_seq: 1, pg_role: primary , pg_upstream: 10.10.10.11, pg_delay: 1d }
    10.10.10.13: { pg_seq: 2, pg_role: replica }
  vars: { pg_cluster: pg-test2 }
```

你还可以在现有的[备份集群](#备份集群)上[配置](PGSQL-ADMIN#配置集群)一个“复制延迟”。

```bash
$ pg edit-config pg-testdelay
 standby_cluster:
   create_replica_methods:
   - basebackup
   host: 10.10.10.11
   port: 5432
+  recovery_min_apply_delay: 1h    # <--- 在此处添加延迟时长，例如1小时

Apply these changes? [y/N]: y
```

当某些元组和表格被意外删除时，你可以通过修改此参数的方式，将此延迟集群推进到适当的时间点，并从中读取数据，快速修复原始集群。

延迟集群需要额外的资源，但比起 [PITR](PGSQL-PITR#恢复) 要快得多，并且对系统的影响也小得多，对于非常关键的集群，可以考虑搭建延迟集群。




----------------

## Citus集群

Pigsty 原生支持 Citus。可以参考 [`files/pigsty/citus.yml`](https://github.com/Vonng/pigsty/blob/master/files/pigsty/citus.yml) 与 [`prod.yml`](https://github.com/Vonng/pigsty/blob/master/files/pigsty/prod.yml#L298) 作为样例。

要定义一个 citus 集群，您需要指定以下参数：

- [`pg_mode`](PARAM#pg_mode) 必须设置为 `citus`，而不是默认的 `pgsql`
- 在每个分片集群上都必须定义分片名 [`pg_shard`](PARAM#pg_shard) 和分片号 [`pg_group`](PARAM#pg_group)
- 必须定义 [`patroni_citus_db`](PARAM#patroni_citus_db) 来指定由 Patroni 管理的数据库。
- 如果您想使用 [`pg_dbsu`](PARAM#pg_dbsu) 的 `postgres` 而不是默认的 [`pg_admin_username`](PARAM#pg_admin_username) 来执行管理命令，那么 [`pg_dbsu_password`](PARAM#pg_dbsu_password) 必须设置为非空的纯文本密码

此外，还需要额外的 hba 规则，允许从本地和其他数据节点进行 SSL 访问。如下所示：

```yaml
all:
  children:
    pg-citus0: # citus 0号分片
      hosts: { 10.10.10.10: { pg_seq: 1, pg_role: primary } }
      vars: { pg_cluster: pg-citus0 , pg_group: 0 }
    pg-citus1: # citus 1号分片
      hosts: { 10.10.10.11: { pg_seq: 1, pg_role: primary } }
      vars: { pg_cluster: pg-citus1 , pg_group: 1 }
    pg-citus2: # citus 2号分片
      hosts: { 10.10.10.12: { pg_seq: 1, pg_role: primary } }
      vars: { pg_cluster: pg-citus2 , pg_group: 2 }
    pg-citus3: # citus 3号分片
      hosts:
        10.10.10.13: { pg_seq: 1, pg_role: primary }
        10.10.10.14: { pg_seq: 2, pg_role: replica }
      vars: { pg_cluster: pg-citus3 , pg_group: 3 }
  vars:                               # 所有 Citus 集群的全局参数
    pg_mode: citus                    # pgsql 集群模式需要设置为： citus
    pg_shard: pg-citus                # citus 水平分片名称： pg-citus
    patroni_citus_db: meta            # citus 数据库名称：meta
    pg_dbsu_password: DBUser.Postgres # 如果使用 dbsu ，那么需要为其配置一个密码
    pg_users: [ { name: dbuser_meta ,password: DBUser.Meta ,pgbouncer: true ,roles: [ dbrole_admin ] } ]
    pg_databases: [ { name: meta ,extensions: [ { name: citus }, { name: postgis }, { name: timescaledb } ] } ]
    pg_hba_rules:
      - { user: 'all' ,db: all  ,addr: 127.0.0.1/32 ,auth: ssl ,title: 'all user ssl access from localhost' }
      - { user: 'all' ,db: all  ,addr: intra        ,auth: ssl ,title: 'all user ssl access from intranet'  }
```

在协调者节点上，您可以创建分布式表和引用表，并从任何数据节点查询它们。从 11.2 开始，任何 Citus 数据库节点都可以扮演协调者的角色了。

```bash
SELECT create_distributed_table('pgbench_accounts', 'aid'); SELECT truncate_local_data_after_distributing_table($$public.pgbench_accounts$$);
SELECT create_reference_table('pgbench_branches')         ; SELECT truncate_local_data_after_distributing_table($$public.pgbench_branches$$);
SELECT create_reference_table('pgbench_history')          ; SELECT truncate_local_data_after_distributing_table($$public.pgbench_history$$);
SELECT create_reference_table('pgbench_tellers')          ; SELECT truncate_local_data_after_distributing_table($$public.pgbench_tellers$$);
```






----------------

## 大版本切换

Pigsty 从 PostgreSQL 10 开始提供支持，不过目前预打包的离线软件包中仅包含 12 - 16 版本。

Pigsty 对不同大版本的支持力度不同，如下表所示：

| 版本 | 说明                  | 软件包支持程度          |
|----|---------------------|------------------|
| 16 | 刚发布的新版本，支持重要扩展      | Core, L1, L2     |
| 15 | 稳定的主版本，支持全部扩展（默认）   | Core, L1, L2, L3 |
| 14 | 旧的稳定主版本，支持 L1、L2 扩展 | Core, L1         |
| 13 | 更旧的主版本，仅支持 L1 扩展    | Core, L1         |
| 12 | 更旧的主版本，仅支持 L1 扩展    | Core, L1         |

- 内核: `postgresql*`，提供 12 - 16 支持
- 1类扩展: `wal2json`，`pg_repack`，`passwordcheck_cracklib` (在 PG 12 - 16 中提供) 
- 2类扩展: `postgis`， `citus`， `timescaledb`， `pgvector` (在 PG 15,16 中提供)
- 3类扩展: 其他扩展 (目前只在 PG 15 提供)

除了 PG15 之外，其他大版本上可能会有一些扩展不可用，您可能需要更改 [`pg_extensions`](PARAM#pg_extensions) 和 [`pg_libs`](PARAM#pg_libs) 以满足您的需求。

如果您确实希望在较老的大版本上使用这些扩展，可以参考[添加软件](PGSQL-ADMIN#添加软件)和[安装扩展](PGSQL-ADMIN#安装扩展)的说明，手工从PGDG源下载并安装。

这里有一些不同大版本集群的配置样例：

```yaml
pg-v12:
  hosts: { 10.10.10.12: { pg_seq: 1 ,pg_role: primary } }
  vars:
    pg_cluster: pg-v12
    pg_version: 12
    pg_libs: 'pg_stat_statements, auto_explain'
    pg_extensions: [ 'wal2json_12* pg_repack_12* passwordcheck_cracklib_12*' ]

pg-v13:
  hosts: { 10.10.10.13: { pg_seq: 1 ,pg_role: primary } }
  vars:
    pg_cluster: pg-v13
    pg_version: 13
    pg_libs: 'pg_stat_statements, auto_explain'
    pg_extensions: [ 'wal2json_13* pg_repack_13* passwordcheck_cracklib_13*' ]

pg-v14:
  hosts: { 10.10.10.14: { pg_seq: 1 ,pg_role: primary } }
  vars:
    pg_cluster: pg-v14
    pg_version: 14

pg-v15:
  hosts: { 10.10.10.15: { pg_seq: 1 ,pg_role: primary } }
  vars:
    pg_cluster: pg-v15
    pg_version: 15

pg-v16:
  hosts: { 10.10.10.16: { pg_seq: 1 ,pg_role: primary } }
  vars:
    pg_cluster: pg-v16
    pg_version: 16
```
