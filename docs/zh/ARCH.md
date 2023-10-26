# 系统架构

Pigsty 使用 **模块化架构** 与 **声明式接口**。

* Pigsty 使用[配置清单](config)描述整套部署环境，并通过 ansible [剧本](playbook)实现。
* Pigsty 在可以在任意节点上运行，无论是物理裸机还是虚拟机，只要操作系统[兼容](INSTALL#要求)即可。
* Pigsty 的行为由配置参数控制，具有幂等性的剧本 会将节点调整到配置所描述的状态。
* Pigsty 采用模块化设计，可自由组合以适应不同场景。使用剧本将模块安装到配置指定的节点上。


----------------

## 模块

Pigsty 采用模块化设计，有六个主要的默认模块：[`PGSQL`](pgsql)、[`INFRA`](infra)、[`NODE`](node)、[`ETCD`](etcd)、[`REDIS`](redis) 和 [`MINIO`](minio)。

* [`PGSQL`](pgsql)：由 Patroni、Pgbouncer、HAproxy、PgBackrest 等驱动的自治高可用 Postgres 集群。
* [`INFRA`](infra)：本地软件仓库、Prometheus、Grafana、Loki、AlertManager、PushGateway、Blackbox Exporter...
* [`NODE`](node)：调整节点到所需状态、名称、时区、NTP、ssh、sudo、haproxy、docker、promtail、keepalived
* [`ETCD`](etcd)：分布式键值存储，用作高可用 Postgres 集群的 DCS：共识选主/配置管理/服务发现。
* [`REDIS`](redis)：Redis 服务器，支持独立主从、哨兵、集群模式，并带有完整的监控支持。
* [`MINIO`](minio)：与 S3 兼容的简单对象存储服务器，可作为 PG数据库备份的可选目的地。

你可以声明式地自由组合它们。如果你想要主机监控，在基础设施节点上安装[`INFRA`](infra)模块，并在纳管节点上安装 [`NODE`](node) 模块就足够了。
 [`ETCD`](etcd) 和 [`PGSQL`](pgsql) 模块用于搭建高可用 PG 集群，将模块安装在多个节点上，可以自动形成一个高可用的数据库集群。
您可以复用 Pigsty 基础架构并开发您自己的模块，[`REDIS`](redis) 和 [`MINIO`](minio) 可以作为一个样例。后续还会有更多的模块加入，例如对 Mongo 与 MySQL 的初步支持已经提上了日程。

[![pigsty-sandbox.jpg](https://repo.pigsty.cc/img/pigsty-sandbox.jpg)](PROVISION)



----------------

## 单机安装

默认情况下，Pigsty 将在单个 **节点** (物理机/虚拟机) 上安装。[`install.yml`](https://github.com/Vonng/pigsty/blob/master/install.yml) 剧本将在**当前**节点上安装 [`INFRA`](infra)、[`ETCD`](etcd)、[`PGSQL`](pgsql) 和可选的 [`MINIO`](minio) 模块，
这将为你提供一个功能完备的可观测性技术栈全家桶 (Prometheus、Grafana、Loki、AlertManager、PushGateway、BlackboxExporter 等) ，以及一个内置的 PostgreSQL 单机实例作为 CMDB，也可以开箱即用。 (集群名 `pg-meta`，库名为 `meta`)。

这个节点现在会有完整的自我监控系统、可视化工具集，以及一个自动配置有 PITR 的 Postgres 数据库（HA不可用，因为你只有一个节点）。你可以使用此节点作为开发箱、测试、运行演示以及进行数据可视化和分析。或者，还可以把这个节点当作管理节点，部署纳管更多的节点！

[![pigsty-arch.jpg](https://repo.pigsty.cc/img/pigsty-arch.jpg)](INFRA)



----------------

## 监控

安装的 [单机元节点](#单机安装) 可用作**管理节点**和**监控中心**，以将更多节点和数据库服务器置于其监视和控制之下。

Pigsty 的监控系统可以独立使用，如果你想安装 Prometheus / Grafana 可观测性全家桶，Pigsty 为你提供了最佳实践！
它为 [主机节点](https://demo.pigsty.cc/d/node-overview) 和 [PostgreSQL数据库](https://demo.pigsty.cc/d/pgsql-overview) 提供了丰富的仪表盘。
无论这些节点或 PostgreSQL 服务器是否由 Pigsty 管理，只需简单的配置，你就可以立即拥有生产级的监控和告警系统，并将现有的主机与PostgreSQL纳入监管。

[![pigsty-dashboard.jpg](https://repo.pigsty.cc/img/pigsty-dashboard.jpg)](PGSQL-DASHBOARD)



----------------

## 高可用PG集群

Pigsty 帮助您在任何地方 **拥有** 您自己的生产级高可用 PostgreSQL RDS 服务。

要创建这样一个高可用 PostgreSQL 集群/RDS服务，你只需用简短的配置来描述它，并运行剧本来创建即可：

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
    10.10.10.13: { pg_seq: 3, pg_role: replica }
  vars: { pg_cluster: pg-test }
```

```bash
$ bin/pgsql-add pg-test  # 初始化集群 'pg-test'
```

不到10分钟，您将拥有一个服务接入，监控，备份PITR，高可用配置齐全的 PostgreSQL 数据库集群。

[![pgsql-ha.jpg](https://repo.pigsty.cc/img/pgsql-ha.jpg)](PGSQL-ARCH)

硬件故障由 patroni、etcd 和 haproxy 提供的自愈高可用架构来兜底，在主库故障的情况下，默认会在 30 秒内执行自动故障转移（Failover）。
客户端无需修改配置重启应用：Haproxy 利用 patroni 健康检查进行流量分发，读写请求会自动分发到新的集群主库中，并避免脑裂的问题。
这一过程十分丝滑，例如在从库故障，或主动切换（switchover）的情况下，客户端只有一瞬间的当前查询闪断，

软件故障、人为错误和 数据中心级灾难由 pgbackrest 和可选的 [MinIO](MINIO) 集群来兜底。这为您提供了本地/云端的 PITR 能力，并在数据中心失效的情况下提供了跨地理区域复制，与异地容灾功能。


----------------

## 数据库即代码

Pigsty 遵循 IaC（基础设施即代码）与 GitOPS 理念：Pigsty 的部署由声明式的[配置清单](config#配置清单)描述，并通过幂等[剧本](PLAYBOOK)来实现。

用户用声明的方式通过[参数](param)来描述自己期望的状态，而剧本则以幂等的方式调整目标节点以达到这个状态。这就像 Kubernetes 的 CRD & Operator，但 Pigsty 在裸机和虚拟机上实现了这一点。

[![pigsty-iac.jpg](https://repo.pigsty.cc/img/pigsty-iac.jpg)](CONFIG)

以下面的默认配置片段为例，这段配置描述了一个节点 `10.10.10.10`，其上安装了 [`INFRA`](infra)、[`NODE`](node)、[`ETCD`](etcd) 和 [`PGSQL`](pgsql) 模块。

```yaml
# 监控、告警、DNS、NTP 等基础设施集群...
infra: { hosts: { 10.10.10.10: { infra_seq: 1 } } }

# minio 集群，兼容 s3 的对象存储
minio: { hosts: { 10.10.10.10: { minio_seq: 1 } }, vars: { minio_cluster: minio } }

# etcd 集群，用作 PostgreSQL 高可用所需的 DCS
etcd: { hosts: { 10.10.10.10: { etcd_seq: 1 } }, vars: { etcd_cluster: etcd } }

# PGSQL 示例集群: pg-meta
pg-meta: { hosts: { 10.10.10.10: { pg_seq: 1, pg_role: primary }, vars: { pg_cluster: pg-meta } }
```

要真正创建这些集群，执行以下剧本：

```bash
./infra.yml -l infra    # 在 'infra' 分组上初始化 infra 模块
./etcd.yml  -l etcd     # 在 'etcd'  分组上初始化 etcd 模块
./minio.yml -l minio    # 在 'minio' 分组上初始化 minio 模块
./pgsql.yml -l pg-meta  # 在 'pgsql' 分组上初始化 pgsql 模块
```

执行常规的管理任务常简单。例如，如果你希望向现有的高可用 PostgreSQL 集群中添加一个新的从库/数据库/用户，你只需要在配置中添加一条主机记录，并在其上运行该剧本即可，例如：

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
    10.10.10.13: { pg_seq: 3, pg_role: replica } # <-- add new instance
  vars: { pg_cluster: pg-test }
```

```bash
# 向 pg-test 集群中添加 10.10.10.13 作为新从库
$ bin/pgsql-add  pg-test  10.10.10.13
```

您还可以使用这种方法来管理许多 PostgreSQL 中的实体对象：用户/角色、数据库、服务、HBA 规则、扩展、模式等...

更多信息，请参阅 [PGSQL配置](pgsql-conf)。

