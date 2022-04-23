# Conecpt: Nodes

> Pigsty使用**节点**（Node）进行安装与部署，节点可以是物理机，虚拟机，甚至Pod。



在Pigsty中有两种节点：[元节点 ](#元节点) 与（普通）[节点](#节点)。

元节点用于发起管理，普通节点是纳入Pigsty管理的节点。

* [元节点](#元节点)（Meta）：执行 [`infra.yml`](p-infra.md) 剧本安装Pigsty，安装 **INFRA**，**NODES**，**PGSQL** 三个模块。
* [节点](#节点)（Node）：通过 [`nodes.yml`](p-nodes.md#nodes) 剧本纳入管理的普通节点，默认安装 **NODES** 模块。



## Meta Node

元节点即完整安装Pigty，带有管理功能的节点，部署有完整的[基础设施](c-infra.md)组件。

当您在某节点上执行 `./configure` 时，当前节点会被默认作为元节点，填入[配置文件](v-config.md) `meta` 分组中。

在每套环境中，**Pigsty最少需要一个元节点，该节点将作为整个环境的控制中心**。元节点负责各种管理工作：保存状态，管理配置，发起任务，收集指标，等等。整个环境的基础设施组件，Nginx，Grafana，Prometheus，Alertmanager，NTP，DNS Nameserver，DCS都将部署在元节点上。



### Meta Node Reuse

**元节点亦可复用为普通数据库节点**，在元节点上默认运行有名为 `pg-meta` 的PostgreSQL数据库集群。提供额外的扩展功能：CMDB，巡检报告，扩展应用，日志分析，数据分析与处理等

以Pigsty附带的四节点沙箱环境为例，组件在节点上的分布如下图所示：

![](_media/SANDBOX.gif)

沙箱由一个[元节点](#元节点)与四个[普通节点](#节点)组成，这里元节点也被复用为一个普通节点。沙箱内部署有一套[基础设施](c-infra.md#基础设施)与两套[数据库集群](c-pgsql.md#集群概览)。 `meta` 为元节点，部署有**基础设施**组件，同时被复用为普通数据库节点，部署有单主数据库集群`pg-meta`。 `node-1`，`node-2`，`node-3` 为普通数据库节点，部署有数据库集群`pg-test`。


### Meta Node Service

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

![](_media/ARCH.gif)



### Meta Node & DCS

默认情况下，元节点上将部署元数据库 （Consul 或 Etcd），用户也可以使用已有的**外部DCS集群**。如果将DCS部署至元节点上，建议在**生产环境**使用3个元节点，以充分保证DCS服务的可用性。DCS外的基础设施组件都将以对等副本的方式部署在所有元节点上。元节点的数量要求最少1个，推荐3个，建议不超过5个。

!> DCS用于支持数据库高可用的故障检测与选主，**在默认模式停止DCS服务会导致所有数据库集群拒绝写入**，因此请务必确保DCS服务的可靠性（增加元节点数量，或使用外部独立维护的高可用DCS集群）。



### Multiple Meta Nodes

复数个元节点是可能的，通常一个元节点足矣，两个元节点可以互为备份，三个元节点自身便足以部署生产级DCS Server集群。超过三个的元节点意义不大，如果只是为了追求DCS Server集群的高可用，您可以使用外部的专用DCS Server集群。DCS（Consul/Etcd）对于生产环境PostgreSQL数据库高可用至关重要，Pigsty建议使用3-5个外部的专用DCS Server集群以确保元数据库本身的高可用。但本着开箱即用的原则，Pigsty默认在所有元节点上部署DCS Server。

元节点的特征是节点地址配置于配置文件的 `all.children.meta.host` 分组中，带有`meta_node: true` 标记。在 [`configure`](v-config.md#配置过程) 过程中，执行安装的当前节点会被配置为元节点，复数个元节点则需要手工配置，可参考三管理节点样例配置文件： [`pigsty-dcs3.yml`](https://github.com/Vonng/pigsty/blob/master/files/conf/pigsty-dcs3.yml)。







## Node

您可以使用Pigsty管理更多的节点，并使用这些节点部署数据库。

纳入Pigsty管理的节点会被 [`nodes.yml`](p-nodes.md#nodes) 调整至 [配置：NODES](v-nodes.md) 所描述的状态，加装节点监控与日志收集组件，您可以从监控系统中查阅节点状态与日志。被Pigsty管理的节点可以进一步用于部署各种**数据库**，或您自己的应用。



### Node Identity

每个节点都有**身份参数**，通过在`<cluster>.hosts`与`<cluster>.vars`中的相关参数进行配置。

Pigsty使用**IP地址**作为**数据库节点**的唯一标识，**该IP地址必须是数据库实例监听并对外提供服务的IP地址**，但不宜使用公网IP地址。尽管如此，用户并不一定非要通过该IP地址连接至该数据库。例如，通过SSH隧道或跳板机中转的方式间接操作管理目标节点也是可行的。但在标识数据库节点时，首要IPv4地址依然是节点的核心标识符，**这一点非常重要，用户应当在配置时保证这一点。** IP地址即配置清单中主机的`inventory_hostname` ，体现为`<cluster>.hosts`对象中的`key`。

除此之外，在Pigsty监控系统中，节点还有两个重要的身份参数： [`nodename`](v-nodes.md#nodename) 与 [`node_cluster`](v-nodes.md#node_cluster)，这两者将在监控系统中用作节点的 **实例标识**（`ins`） 与 **集群标识** （`cls`）。在执行默认的PostgreSQL部署时，因为Pigsty默认采用节点独占1:1部署，因此可以通过 [`pg_hostname`](v-pgsql.md#pg_hostname) 参数，将数据库实例的身份参数（[`pg_cluster`](v-pgsql.md#pg_cluster) 与 `pg_instance`）借用至节点的`ins`与`cls`标签上。 

 [`nodename`](v-nodes.md#nodename) 与 [`node_cluster`](v-nodes.md#node_cluster) #node_cluster)并不是必选的，当留白或置空时，[`nodename`](#nodename) 会使用节点当前的主机名，而 [`node_cluster`](#node_cluster) 则会使用固定的默认值：`nodes`。

|              名称               |   类型   | 层级  | 必要性   | 说明             |
| :-----------------------------: | :------: | :---: | -------- | ---------------- |
|      `inventory_hostname`       |   `ip`   | **-** | **必选** | **节点IP地址**   |
|     [`nodename`](#nodename)     | `string` | **I** | 可选     | **节点名称**     |
| [`node_cluster`](#node_cluster) | `string` | **C** | 可选     | **节点集群名称** |

以下集群配置声明了一个三节点节点集群：

```yaml
node-test:
  hosts:
    10.10.10.11: { nodename: node-test-1 }
    10.10.10.12: { pg_hostname: true } # 从PG借用身份 pg-test-2
    10.10.10.13: {  } # 不显式指定nodename，则使用原有hostname: node-3
  vars:
    node_cluster: node-test
```

|     host      | node_cluster |   nodename    |  instance   |
| :-----------: | :----------: | :-----------: | :---------: |
| `10.10.10.11` | `node-test`  | `node-test-1` | `pg-test-1` |
| `10.10.10.12` | `node-test`  |  `pg-test-2`  | `pg-test-2` |
| `10.10.10.13` | `node-test`  |   `node-3`    | `pg-test-3` |

在监控系统中，相关的时序监控数据标签为：

```json
node_load1{cls="pg-meta", ins="pg-meta-1", ip="10.10.10.10", job="nodes"}
node_load1{cls="pg-test", ins="pg-test-1", ip="10.10.10.11", job="nodes"}
node_load1{cls="pg-test", ins="pg-test-2", ip="10.10.10.12", job="nodes"}
node_load1{cls="pg-test", ins="pg-test-3", ip="10.10.10.13", job="nodes"}
```

### Node Services

|     组件      | 端口 | 说明                                              |
| :-----------: | :--: | ------------------------------------------------- |
| Consul Agent  | 8500 | 分布式配置管理，服务发现组件Consul的本地Agent     |
| Node Exporter | 9100 | 机器节点监控指标导出器                            |
|   Promtail    | 9080 | 实时收集Postgres，Pgbouncer，Patroni日志 （选装） |
|  Consul DNS   | 8600 | Consul Agent提供的DNS服务                         |

### PGSQL Node Services

**PGSQL节点**是用于部署PostgreSQL集群的节点， 在Pigsty中，PGSQL实例固定采用**独占式部署**，一个节点上有且仅有一个数据库实例，因此节点与数据库实例可以互用唯一标识（IP地址与实例名）。在这种情况下，您可以使用 [`pg_hostname`](v-pgsql.md#pg_hostname) 参数，将节点上数据库的身份参数借调赋予节点。

除了 [节点默认服务]((c-nodes.md#节点默认服务)) 外，PGSQL节点上运行有下列服务：

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
| Haproxy `service`  | 543x | 集群提供的额外自定义服务将依次分配端口                |
|   Haproxy Admin    | 9101 | Haproxy监控指标与流量管理页面                         |
|    PG Exporter     | 9630 | Postgres监控指标导出器                                |
| PGBouncer Exporter | 9631 | Pgbouncer监控指标导出器                               |
|   Node Exporter    | 9100 | 机器节点监控指标导出器                                |
|      Promtail      | 9080 | 实时收集Postgres，Pgbouncer，Patroni日志 （选装）     |
|     Consul DNS     | 8600 | Consul提供的DNS服务                                   |
|    vip-manager     |  -   | 将VIP绑定至集群主库上                                 |



## Node Interaction

以单个 [元节点](#元节点) 和 单个 [节点](#数据库节点) 构成的环境为例，架构如下图所示：

![](_media/ARCH.gif)

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
