# 概念：节点

> Pigsty使用**节点**（Node）进行安装与部署，节点可以是物理机，虚拟机，甚至Pod。



在Pigsty中有两种节点：[元节点 ](#元节点) 与（普通）[节点](#节点)。

元节点用于发起管理，普通节点是纳入Pigsty管理的节点。

* [元节点](#元节点)（Meta）：执行 [`infra.yml`](p-infra.md) 剧本安装Pigsty，安装 **INFRA**，**NODES**，**PGSQL** 三个模块。
* [节点](#节点)（Node）：通过 [`nodes.yml`](p-nodes.md#nodes) 剧本纳入管理的普通节点，默认安装 **NODES** 模块。



## 元节点

元节点即完整安装Pigty，带有管理功能的节点，部署有完整的[基础设施](c-infra.md)组件。

当您在某节点上执行 `./configure` 时，当前节点会被默认作为元节点，填入[配置文件](v-config.md) `meta` 分组中。

在每套环境中，**Pigsty最少需要一个元节点，该节点将作为整个环境的控制中心**。元节点负责各种管理工作：保存状态，管理配置，发起任务，收集指标，等等。整个环境的基础设施组件，Nginx，Grafana，Prometheus，Alertmanager，NTP，DNS Nameserver，DCS都将部署在元节点上。

### 复用元节点


**元节点亦可复用为普通数据库节点**，在元节点上默认运行有名为 `pg-meta` 的PostgreSQL数据库集群。提供额外的扩展功能：CMDB，巡检报告，扩展应用，日志分析，数据分析与处理等

以Pigsty附带的四节点沙箱环境为例，组件在节点上的分布如下图所示：

![](../_media/SANDBOX.gif)

沙箱由一个[元节点](#元节点)与四个[普通节点](#节点)组成，这里元节点也被复用为一个普通节点。沙箱内部署有一套[基础设施](c-infra.md#基础设施)与两套[数据库集群](c-pgsql.md#集群概览)。 `meta` 为元节点，部署有**基础设施**组件，同时被复用为普通数据库节点，部署有单主数据库集群`pg-meta`。 `node-1`，`node-2`，`node-3` 为普通数据库节点，部署有数据库集群`pg-test`。

### 元节点上的服务

元节点上默认运行的服务如下所示：

|             组件              | 端口 | 说明                          |   默认域名   |
| :---------------------------: | :--: | ----------------------------- | :----------: |
| Nginx        |  80  | 所有Web服务的入口，文件服务器 |   `pigsty`   |
| Yum      |  80  | 本地YUM软件源                 | `yum.pigsty` |
| Grafana      | 3000 | 监控系统/可视化平台           |  `g.pigsty`  |
| AlertManager | 9093 | 报警聚合管理组件              |  `a.pigsty`  |
| Prometheus   | 9090 | 监控时序数据库                |  `p.pigsty`  |
| Loki         | 3100 | 实时日志收集基础设施          |  `l.pigsty`  |
| Consul (Server) | 8500 | 分布式配置管理与服务发现      |  `c.pigsty`  |
| Docker       | 2375 | 运行无状态服务的容器平台      |      -       |
| PostgreSQL   | 5432 | Pigsty CMDB                   |      -       |
| Ansible      |  -   | 用于发起管理命令的组件        |      -       |
| Consul DNS | 8600 | Consul提供的DNS服务（可选）   |      -       |
| Dnsmasq      |  53  | DNS域名解析服务器（可选）     |      -       |
| NTP          | 123  | NTP时间服务器（可选）         |      -       |
|           Pgbouncer           | 6432 | Pgbouncer连接池服务 | - |
| Patroni | 8008 | Patroni高可用组件 | - |
| Haproxy Primary | 5433 | 集群读写服务（主库连接池）代理 | - |
| Haproxy Replica | 5434 | 集群只读服务（从库连接池）代理 | - |
| Haproxy Default | 5436 | 集群主库直连服务（用于管理，DDL/DML变更） | - |
| Haproxy Offline | 5438 | 集群离线读取服务（直连离线实例，用于ETL，交互式查询） | - |
| Haproxy Admin | 9101 | Haproxy监控指标与流量管理页面 | - |
| PG Exporter | 9630 | Postgres监控指标导出器 | - |
| PGBouncer Exporter | 9631 | Pgbouncer监控指标导出器 | - |
| Node Exporter | 9100 | 机器节点监控指标导出器 | - |
| Promtail | 9080 | 实时收集节点与数据库日志 | - |
| vip-manager | - | 将VIP绑定至集群主库上 |  |

![](../_media/ARCH.gif)



### 元节点与DCS

默认情况下，元节点上将部署元数据库 （Consul 或 Etcd），用户也可以使用已有的**外部DCS集群**。如果将DCS部署至元节点上，建议在**生产环境**使用3个元节点，以充分保证DCS服务的可用性。DCS外的基础设施组件都将以对等副本的方式部署在所有元节点上。元节点的数量要求最少1个，推荐3个，建议不超过5个。

!> DCS用于支持数据库高可用的故障检测与选主，**在默认模式停止DCS服务会导致所有数据库集群拒绝写入**，因此请务必确保DCS服务的可靠性（增加元节点数量，或使用外部独立维护的高可用DCS集群）。

### 使用多个元节点

复数个元节点是可能的，通常一个元节点足矣，两个元节点可以互为备份，三个元节点自身便足以部署生产级DCS Server集群。超过三个的元节点意义不大，如果只是为了追求DCS Server集群的高可用，您可以使用外部的专用DCS Server集群。DCS（Consul/Etcd）对于生产环境PostgreSQL数据库高可用至关重要，Pigsty建议使用3-5个外部的专用DCS Server集群以确保元数据库本身的高可用。但本着开箱即用的原则，Pigsty默认在所有元节点上部署DCS Server。

元节点的特征是节点地址配置于配置文件的 `all.children.meta.host` 分组中，带有`meta_node: true` 标记。在 [`configure`](v-config.md#配置过程) 过程中，执行安装的当前节点会被配置为元节点，复数个元节点则需要手工配置，可参考三管理节点样例配置文件： [`pigsty-dcs3.yml`](https://github.com/Vonng/pigsty/blob/master/files/conf/pigsty-dcs3.yml)。







## 节点

您可以使用Pigsty管理更多的节点，并使用这些节点部署数据库。

纳入Pigsty管理的节点会被 [`nodes.yml`](p-nodes.md#nodes) 调整至 [配置：NODES](v-nodes.md) 所描述的状态，加装节点监控与日志收集组件，您可以从监控系统中查阅节点状态与日志。被Pigsty管理的节点可以进一步用于部署各种**数据库**，或您自己的应用。



### 节点身份

在Pigsty中，主网卡IPv4地址用于唯一标识一个节点。如果节点有多块



实体与标识符是一种概念模型，下面介绍Pigsty中的具体实现。

[`pg_cluster`](#pg_cluster)，[`pg_role`](#pg_role)，[`pg_seq`](#pg_seq) 属于 **身份参数** ，用于生成实体标识。

除IP地址外，这三个参数是定义一套新的数据库集群的最小必须参数集

* 集群标识：`pg_cluster` ： `{{ pg_cluster }}`
* 实例标识：`pg_instance` ： `{{ pg_cluster }}-{{ pg_seq }}`
* 服务标识：`pg_service` ：`{{ pg_cluster }}-{{ pg_role }}`
* 节点标识：`nodename`：
  * 若 `pg_hostname: true`: 使用与 `pg_instance`相同的：`{{ pg_cluster }}-{{ pg_seq }}`
  * 若 `pg_hostname: false`: 显式指定`{{ nodename }}`则直接使用，否则使用现有主机名。

下面是沙箱环境中 `pg-test` 集群的定义样例：


```yaml
pg-test:
  hosts:
    10.10.10.11: {pg_seq: 1, pg_role: replica}
    10.10.10.12: {pg_seq: 2, pg_role: primary}
    10.10.10.13: {pg_seq: 3, pg_role: replica}
  vars:
    pg_cluster: pg-test
    pg_hostname: true     # 使用1:1 PG实例的身份作为节点的身份
```

因此，该集群三个成员的身份标识如下：

|     host      |  cluster  |  instance   |      service      |  nodename   |
| :-----------: | :-------: | :---------: | :---------------: | :---------: |
| `10.10.10.11` | `pg-test` | `pg-test-1` | `pg-test-primary` | `pg-test-1` |
| `10.10.10.12` | `pg-test` | `pg-test-2` | `pg-test-replica` | `pg-test-2` |
| `10.10.10.13` | `pg-test` | `pg-test-3` | `pg-test-replica` | `pg-test-3` |

在监控系统中，相关的时序监控数据标签为：

```json
pg_up{cls="pg-meta", ins="pg-meta-1", ip="10.10.10.10", job="pgsql"}
pg_up{cls="pg-test", ins="pg-test-1", ip="10.10.10.11", job="pgsql"}
pg_up{cls="pg-test", ins="pg-test-2", ip="10.10.10.12", job="pgsql"}
pg_up{cls="pg-test", ins="pg-test-3", ip="10.10.10.13", job="pgsql"}
```





### 节点默认服务

|     组件      | 端口 | 说明                                              |
| :-----------: | :--: | ------------------------------------------------- |
| Consul Agent  | 8500 | 分布式配置管理，服务发现组件Consul的本地Agent     |
| Node Exporter | 9100 | 机器节点监控指标导出器                            |
|   Promtail    | 9080 | 实时收集Postgres，Pgbouncer，Patroni日志 （选装） |
|  Consul DNS   | 8600 | Consul Agent提供的DNS服务                         |





**数据库节点**负责运行**数据库实例**， 在Pigsty中数据库实例固定采用**独占式部署**，一个节点上有且仅有一个数据库实例，因此节点与数据库实例可以互用唯一标识（IP地址与实例名）。

一个典型的数据库节点上运行的服务如下所示：

|        组件        | 端口 | 说明                                                  |
| :----------------: | :--: | ----------------------------------------------------- |
|      Postgres      | 5432 | Postgres数据库服务                                    |
|     Pgbouncer      | 6432 | Pgbouncer连接池服务                                   |
|      Patroni       | 8008 | Patroni高可用组件                                     |
|       Consul       | 8500 | 分布式配置管理，服务发现组件Consul的本地Agent         |
|  Haproxy Primary   | 5433 | 集群读写服务（主库连接池）代理                        |
|  Haproxy Replica   | 5434 | 集群只读服务（从库连接池）代理                        |
|  Haproxy Default   | 5436 | 集群主库直连服务（用于管理，DDL/DML变更）             |
|  Haproxy Offline   | 5438 | 集群离线读取服务（直连离线实例，用于ETL，交互式查询） |
| Haproxy `service`  | 543x | *集群提供的额外自定义服务将依次分配端口*              |
|   Haproxy Admin    | 9101 | Haproxy监控指标与流量管理页面                         |
|    PG Exporter     | 9630 | Postgres监控指标导出器                                |
| PGBouncer Exporter | 9631 | Pgbouncer监控指标导出器                               |
|   Node Exporter    | 9100 | 机器节点监控指标导出器                                |
|      Promtail      | 9080 | 实时收集Postgres，Pgbouncer，Patroni日志 （选装）     |
|     Consul DNS     | 8600 | Consul提供的DNS服务                                   |
|    vip-manager     |  x   | 将VIP绑定至集群主库上                                 |




![](../_media/node.svg)



## 交互

以单个 [元节点](#元节点) 和 单个 [节点](#数据库节点) 构成的环境为例，架构如下图所示：

![](../_media/ARCH.gif)

元节点与数据库节点之间的交互主要包括：

* 数据库集群/节点的域名依赖元节点的Nameserver进行**解析** （可选）。
* 数据库节点软件**安装**需要用到元节点上的Yum Repo。
* 数据库集群/节点的监控**指标**会被元节点的Prometheus收集。
* 数据库的日志会被Promtail收集并发往Loki。
* Pigsty会从元节点上发起对数据库节点的**管理**:

  * 执行集群创建，扩缩容，实例/集群回收
  * 创建业务用户、业务数据库、修改服务、HBA修改；
  * 执行日志采集、垃圾清理，备份，巡检等

* 数据库节点的Consul会向元节点的DCS同步本地注册的服务，并代理状态读写操作。
* 数据库节点会从元节点（或其他NTP服务器）同步时间l
