# PostgreSQL 集群配置

> 根据需求场景选择合适的实例与集群类型，配置出满足需求的 PostgreSQL 数据库集群。

您可以定义不同类型的实例和集群：

- [读写主库](#读写主库)：定义单一实例集群。
- [只读从库](#只读从库)：定义具有一个主库和一个副本的基本HA集群。
- [离线从库](#离线从库)：定义专用于OLAP/ETL/交互式查询的实例
- [同步备库](#同步备库)：启用同步提交以确保没有数据丢失。
- [法定人数提交](#法定人数提交)：使用多数同步提交获得更高的一致性级别。
- [备用集群](#备用集群)：克隆现有集群并跟随它
- [延迟集群](#延迟集群)：克隆现有集群用于紧急数据恢复
- [Citus集群](#citus集群)：定义一个Citus分布式数据库集群
- [大版本切换](#大版本切换)：使用不同的PostgreSQL大版本


----------------

## 读写主库

我们从最简单的情况开始，单一主库示例：

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
  vars:
    pg_cluster: pg-test
```

使用以下命令在10.10.10.11节点上创建一个主库实例：

```bash
bin/pgsql-add pg-test
```



----------------

## 只读从库

要添加物理副本，您可以将一个新实例分配给`pg-test`，并将[`pg_role`](PARAM#pg_role)设置为`replica`。

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }  # <--- 新添加的从库
  vars:
    pg_cluster: pg-test
```


您可以[创建](PGSQL-ADMIN#创建集群)一个完整的集群，或者向现有集群[添加](PGSQL-ADMIN#添加实例)一个从库：


```bash
bin/pgsql-add pg-test               # 一次性初始化整个集群
bin/pgsql-add pg-test 10.10.10.12   # 添加副本到现有的集群
```


----------------

## 离线从库

离线实例是专门用于服务缓慢查询、ETL、OLAP流量和交互式查询等的副本。

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

离线实例的工作方式与常见的从库实例类似，但它在`pg-test-replica`服务中用作备份服务器。 也就是说，只有当所有`replica`实例都宕机时，离线和主实例才会服务。

您可以使用[`pg_default_hba_rules`](PARAM#pg_default_hba_rules)和[`pg_hba_rules`](PARAM#pg_hba_rules)进行临时访问控制离线。 它将应用于离线实例和带有[`pg_offline_query`](PARAM#pg_offline_query)标志的任何实例。



----------------

## 同步备库

PostgreSQL 默认在流复制中使用异步提交，这可能会有小的复制延迟（10KB / 10ms）。 当主数据库失败时，可能会有一个小的数据丢失窗口（可以使用[`pg_rpo`](PARAM#pg_rpo)来控制），但对于大多数场景来说，这是可以接受的。

但在某些关键场景中（例如，金融交易），数据丢失是完全不可接受的，或者需要读写一致性。 在这种情况下，您可以启用同步提交来确保这一点。

要启用同步备库模式，您可以简单地使用[`pg_conf`](PARAM#pg_conf)中的`crit.yml`模板。

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

要在现有集群上启用同步备库，请[配置集群](PGSQL-ADMIN#配置集群)并启用`synchronous_mode`：

```bash
$ pg edit-config pg-test    # 在管理员节点以管理员用户身份运行
+++
-synchronous_mode: false    # <--- 旧值
+synchronous_mode: true     # <--- 新值
 synchronous_mode_strict: false

应用这些更改？[y/N]: y
```



----------------

## 法定人数提交

当启用[同步备库](#同步备库)时，PostgreSQL 将选择一个从库作为备库实例，其他所有从库作为候选者。 主数据库会等待备库实例刷新到磁盘，然后才确认提交，备库实例始终拥有最新的数据，没有任何延迟。

然而，您可以通过法定人数提交实现更高/更低的一致性级别（与可用性之间的权衡）。例如，要有任何2个从库来确认提交：

```bash
pg-test:
  hosts:
    10.10.10.10: { pg_seq: 1, pg_role: primary } # <--- pg-test-1
    10.10.10.11: { pg_seq: 2, pg_role: replica } # <--- pg-test-2
    10.10.10.12: { pg_seq: 3, pg_role: replica } # <--- pg-test-3
    10.10.10.13: { pg_seq: 4, pg_role: replica } # <--- pg-test-4
  vars:
    pg_cluster: pg-test
    pg_conf: crit.yml   # <--- use crit template
```

相应地调整[`synchronous_standby_names`](https://www.postgresql.org/docs/current/runtime-config-replication.html#synchronous_standby_names)和`synchronous_node_count`：
- `synchronous_standby_names = ANY 2 (pg-test-2, pg-test-3, pg-test-4)`
- `synchronous_node_count : 2`

<details><summary>示例：启用法定人数提交</summary>

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

应用后，配置生效，出现两个同步备库。当集群有故障转移或扩展和收缩时，请调整这些参数，以避免服务不可用。

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

</details>





----------------

## 备份集群

你可以克隆现有的集群并创建一个备份集群，该集群可以用于迁移、水平拆分、多区域部署或灾难恢复。

备用集群的定义与其他正常集群的定义相同，除了在主实例上定义了[`pg_upstream`](PARAM#pg_upstream)。

例如，你有一个`pg-test`集群，要创建一个备用集群`pg-test2`，其配置清单可能如下所示：

```yaml
# pg-test 是原始集群
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
  vars: { pg_cluster: pg-test }

# pg-test2 是 pg-test 的备用集群
pg-test2:
  hosts:
    10.10.10.12: { pg_seq: 1, pg_role: primary , pg_upstream: 10.10.10.11 } # <--- pg_upstream is defined here
    10.10.10.13: { pg_seq: 2, pg_role: replica }
  vars: { pg_cluster: pg-test2 }
```

而`pg-test2-1`，`pg-test2`的主节点将是`pg-test`的从库，并在`pg-test2`中充当备份集群的领导者（**Standby Leader**）。

只需确保备份集群的主节点上配置了[`pg_upstream`](PARAM#pg_upstream)参数，以便自动从原始上游拉取备份。

```bash
bin/pgsql-add pg-test     # 创建原始集群
bin/pgsql-add pg-test2    # 创建备份集群
```

<details><summary>示例：更改复制上游</summary>

如有必要（例如，上游故障转移），你可以更改备用集群的复制上游。

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




<details><summary>示例：提升备用集群</summary>

你可以随时将备用集群提升为独立集群。

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

如果[`pg_upstream`](PARAM#pg_upstream)是为 **从库** 指定的，而不是**主节点**，则该从库将与给定的上游ip一起配置为级联从库，而不是集群主节点。

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

延迟集群是一种特殊类型的备用集群，用于尽快恢复“意外删除”的数据。

例如，如果你希望有一个名为 `pg-testdelay` 的集群，其数据与1天前的 `pg-test` 集群相同：

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

你还可以在现有的[备份集群](#备份集群)上[配置](PGSQL-ADMIN#配置集群)复制延迟。

```bash
$ pg edit-config pg-testdelay
 standby_cluster:
   create_replica_methods:
   - basebackup
   host: 10.10.10.11
   port: 5432
+  recovery_min_apply_delay: 1h    # <--- 在此处添加延迟时长

Apply these changes? [y/N]: y
```

当某些元组和表格被意外删除时，你可以将此延迟集群推进到适当的时间点，并从中选择数据。

这需要更多的资源，但比[PITR](PGSQL-PITR)快得多，并且对系统的影响也小得多。




----------------

## Citus集群

Pigsty 原生支持 citus。可以参考 [`files/pigsty/citus.yml`](https://github.com/Vonng/pigsty/blob/master/files/pigsty/citus.yml) 与 [`prod.yml`](https://github.com/Vonng/pigsty/blob/master/files/pigsty/prod.yml#L298) 作为样例。

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

Pigsty 从 PostgreSQL 10 开始提供支持，不过目前预打包的离线软件包中仅包含 12 - 16(beta) 版本。

Pigsty 对不同大版本的支持力度是不同，如下表所示：

| 版本     | 说明                        | 软件包支持程度          |
|--------|---------------------------|------------------|
| 16beta | 仅带有 postgres 核心的最新 beta 版 | Core             |
| 15     | 稳定的主版本，支持全部扩展（默认）         | Core, L1, L2, L3 |
| 14     | 旧的稳定主版本，支持 L1、L2 扩展       | Core, L1, L2     |
| 13     | 更旧的主版本，仅支持 L1 扩展          | Core, L1         |
| 12     | 更旧的主版本，仅支持 L1 扩展          | Core, L1         |

- 内核: `postgresql*`，提供 12 - 16beta。
- 1类扩展: `wal2json`, `pg_repack`, `passwordcheck_cracklib` (在 PG 12, 13, 14, 15 中提供)
- 2类扩展: `postgis`, `citus`, `timescaledb`, `pgvector`, `pg_logical`, `pg_cron` (在 PG 14,15 中提供)
- 3类扩展: 其他杂项扩展 (只有 PG 15 提供)

一些扩展在 PG 12,13,16 上不可用，您可能需要更改 [`pg_extensions`](PARAM#pg_extensions) 和 [`pg_libs`](PARAM#pg_libs) 以满足您的需求。

如果您确实希望在较老的大版本上使用这些扩展，可以参考[添加软件](#添加软件)和[安装扩展(#安装扩展)]的说明，手工从PGDG源下载并安装。

这里有一些不同大版本集群的配置样例：

```yaml
pg-v12:
  hosts: { 10.10.10.12: { pg_seq: 1 ,pg_role: primary } }
  vars:
    pg_cluster: pg-v12
    pg_version: 12
    pg_libs: 'pg_stat_statements, auto_explain'
    pg_extensions: [ 'wal2json_13* pg_repack_13* passwordcheck_cracklib_13*' ]

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
    pg_libs: 'pg_stat_statements, auto_explain'
    pg_extensions: [ ]
```
 