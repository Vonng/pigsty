# PostgreSQL 系统架构

> PGSQL 模块总览：PostgreSQL 高可用集群的关键概念与架构细节 

PGSQL模块在生产环境中以**集群**的形式组织，这些**集群**是由一组由**主-备**关联的数据库**实例**组成的**逻辑实体**。
每个**数据库集群**都是由至少一个**数据库实例**组成的**自治**业务服务单元。

----------------

## 实体概念图

让我们从ER图开始。在Pigsty的PGSQL模块中，有四种核心实体：

- [**PGSQL 集群**](#集群)：一个自主的PostgreSQL业务单元，用作其他实体的顶级命名空间。
- [**PGSQL 服务**](#服务)：集群能力的命名抽象，路由流量，并使用节点端口暴露postgres服务。
- [**PGSQL 实例**](#实例)：一个在单个节点上的运行进程和数据库文件组成的单一postgres服务器。
- [**PGSQL 节点**](#节点)：硬件资源的抽象，可以是裸金属、虚拟机或甚至是k8s pods。

![PGSQL-ER](https://user-images.githubusercontent.com/8587410/217492920-47613743-88b8-4c21-a8b9-cf7420cdd50f.png)

**命名约定**

- 集群名称应为有效的域名，不包含任何点：`[a-zA-Z0-9-]+`
- 服务名称应以集群名称为前缀，并以单词后缀，如`primary`、`replica`、`offline`、`delayed`，用`-`连接。
- 实例名称以集群名称为前缀，以整数为后缀，用`-`连接，例如`${cluster}-${seq}`。
- 节点由其IP地址识别，其主机名通常与实例名称相同，因为它们是1:1部署的。


----------------

## 身份参数

Pigsty使用**身份参数**来识别实体：[`PG_ID`](PARAM#PG_ID)。

除了节点IP地址，[`pg_cluster`](PARAM#pg_cluster)、[`pg_role`](PARAM#pg_role)和[`pg_seq`](PARAM#pg_seq)三个参数是定义postgres集群所必需的最小参数集。以[sandbox](PROVISION#sandbox)测试集群`pg-test`为例：

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
    10.10.10.13: { pg_seq: 3, pg_role: replica }
  vars:
    pg_cluster: pg-test
```

集群的三个成员如下所示。

| 集群 | 序号 | 角色 | 主机 / IP | 实例 | 服务 | 节点名 |
|:---------:|:---:|:---------:|:-------------:|:-----------:|:-----------------:|:-----------:|
| `pg-test` | `1` | `primary` | `10.10.10.11` | `pg-test-1` | `pg-test-primary` | `pg-test-1` |
| `pg-test` | `2` | `replica` | `10.10.10.12` | `pg-test-2` | `pg-test-replica` | `pg-test-2` |
| `pg-test` | `3` | `replica` | `10.10.10.13` | `pg-test-3` | `pg-test-replica` | `pg-test-3` |

这里包含了：

- 一个集群：该集群命名为`pg-test`。
- 两种角色：`primary`和`replica`。
- 三个实例：集群由三个实例组成：`pg-test-1`、`pg-test-2`、`pg-test-3`。
- 三个节点：集群部署在三个节点上：`10.10.10.11`、`10.10.10.12`和`10.10.10.13`。
- 四个服务：
  - 读写服务：[`pg-test-primary`](PGSQL-SVC#primary-service)
  - 只读服务：[`pg-test-replica`](PGSQL-SVC#replica-service)
  - 直接连接的管理服务：[`pg-test-default`](PGSQL-SVC#default-service)
  - 离线读服务：[`pg-test-offline`](PGSQL-SVC#offline-service)

在监控系统（Prometheus/Grafana/Loki）中，相应的指标将用这些身份进行标记：

```yaml
pg_up{cls="pg-meta", ins="pg-meta-1", ip="10.10.10.10", job="pgsql"}
pg_up{cls="pg-test", ins="pg-test-1", ip="10.10.10.11", job="pgsql"}
pg_up{cls="pg-test", ins="pg-test-2", ip="10.10.10.12", job="pgsql"}
pg_up{cls="pg-test", ins="pg-test-3", ip="10.10.10.13", job="pgsql"}
```




----------------

## 组件概览

以下是 PostgreSQL 模块组件及其相互作用的详细描述，从上至下分别为：

- 集群 DNS 由 infra 节点上的 DNSMASQ 负责解析
- 集群 VIP 由 `vip-manager` 组件管理，它负责将 [`pg_vip_address`](PARAM#pg_vip_address) 绑定到集群主节点上。
  - `vip-manager` 从 `etcd` 集群获取由 `patroni` 写入的集群领导者信息
- 集群服务由节点上的 Haproxy 对外暴露，不同服务通过节点的不同端口（543x）区分。
  - Haproxy 端口 9101：监控指标 & 统计 & 管理页面
  - Haproxy 端口 5433：默认路由至主 pgbouncer：[读写服务](PGSQL-SVC#primary-service)
  - Haproxy 端口 5434：默认路由至副本 pgbouncer：[只读服务](PGSQL-SVC#replica-service)
  - Haproxy 端口 5436：默认路由至主 postgres：[默认服务](PGSQL-SVC#default-service)
  - Haproxy 端口 5438：默认路由至离线 postgres：[离线服务](PGSQL-SVC#offline-service)
  - HAProxy 将根据 `patroni` 提供的健康检查信息路由流量。
- Pgbouncer 是一个连接池中间件，可以缓冲连接、暴露额外的指标，并增加额外的灵活性 @ 端口 6432
  - Pgbouncer 是无状态的，并通过本地 unix 套接字以 1:1 的方式与 Postgres 服务器部署。
  - 生产流量（主/副本）将默认通过 pgbouncer（可以通过[`pg_default_service_dest`](PARAM#pg_default_service_dest)跳过）
  - 默认/离线服务将始终绕过 pgbouncer 并直接连接到目标 Postgres。
- Postgres 在端口 5432 提供关系数据库服务
  - 在多个节点上安装 PGSQL 模块将基于流式复制自动形成 HA 集群
  - PostgreSQL 默认由 `patroni` 监控。
- Patroni 默认监听端口 8008，监管着 PostgreSQL 服务器进程
  - Patroni 将 Postgres 服务器作为子进程启动
  - Patroni 使用 `etcd` 作为 DCS：存储配置、故障检测和领导者选举。
  - Patroni 通过健康检查提供 Postgres 信息（比如主/从），HAProxy 通过健康检查使用该信息分发服务流量
  - Patroni 指标将被 infra 节点上的 Prometheus 抓取
- PG Exporter 在 9630 端口对外暴露 postgres 架空指标
  - PostgreSQL 指标将被 infra 节点上的 Prometheus 抓取
- Pgbouncer Exporter 在端口 9631 暴露 pgbouncer 指标
  - Pgbouncer 指标将被 infra 节点上的 Prometheus 抓取
- pgBackRest 默认在使用本地备份仓库 （`pgbackrest_method` = `local`）
  - 如果使用 `local`（默认）作为备份仓库，pgBackRest 将在主节点的[`pg_fs_bkup`](PARAM#pg_fs_bkup) 下创建本地仓库
  - 如果使用 `minio` 作为备份仓库，pgBackRest 将在专用的 MinIO 集群上创建备份仓库：[`pgbackrest_repo`.`minio`](PARAM#pgbackrest_repo)
- Postgres 相关日志（postgres, pgbouncer, patroni, pgbackrest）由 promtail 负责收集
  - Promtail 监听 9080 端口，也对 infra 节点上的 Prometheus 暴露自身的监控指标 
  - Promtail 将日志发送至 infra 节点上的 Loki

![pigsty-infra](https://user-images.githubusercontent.com/8587410/206972543-664ae71b-7ed1-4e82-90bd-5aa44c73bca4.gif)



----------------

## 高可用

> 主库故障恢复时间目标 (RTO) ≈ 30s，数据恢复点目标 (RPO) < 1MB，从库故障 RTO ≈ 0 (重置当前连接)

Pigsty 的 PostgreSQL 集群带有开箱即用的高可用方案，由 [patroni](https://patroni.readthedocs.io/en/latest/)、[etcd](https://etcd.io/) 和 [haproxy](http://www.haproxy.org/) 强力驱动。

![pgsql-ha](https://user-images.githubusercontent.com/8587410/206971583-74293d7b-d29a-4ca2-8728-75d50421c371.gif)

当主节点故障时，其中一个副本将自动升级为主节点，并且读写流量将立即路由至新的主节点。影响是：写入查询将被阻塞 15 ~ 40s，直到选出新的领导者。

当副本故障时，只读流量将路由至其他副本，如果所有副本都故障，只读流量将回落到主节点。影响非常小：该副本上的几个运行查询将由于连接重置而中止。

故障检测由 `patroni` 和 `etcd` 完成，领导者将持有一个租约，如果它故障，由于超时，租约将被释放，另一个实例将选举新的领导者来接管。

ttl 可以使用 [`pg_rto`](PARAM#pg_rto) 进行调整，默认为 30s，增加它将导致更长的故障转移等待时间，而减少它将增加误报故障转移率（例如，网络抖动）。

Pigsty 默认使用**可用性优先**模式，这意味着当主节点故障时，它将尽快进行故障转移，尚未复制到副本的数据可能会丢失（常规万兆网络下，复制延迟在通常在几KB到100KB），最大潜在数据丢失由 [`pg_rpo`](PARAM#pg_rpo) 控制，默认为 1MB。

