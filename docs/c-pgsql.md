# Concept: PGSQL

> This article introduces the core concepts required for PostgreSQL cluster management.


* [PGSQL Cluster](#PGSQL-Cluster) / [ER Model](#ER-Model) / [Identity Parameter](#Identity-Parameter)
* [Cluster](#Cluster) /  [Instance](#Instance) / [Node](#Node) / [Service](#Service) 
* [PostgreSQL HA](#High-Availability)




* [Deploy: PGSQL](d-pgsql.md) ｜[Config: PGSQL](v-pgsql.md)  | [Playbook: PGSQL](p-pgsql.md) ｜ [Custom: PGSQL](v-pgsql-customize.md)
* [PGSQL Service](c-service.md#Service) and [PGSQL Access](c-service.md#Access)
* [PGSQL Privilege](c-privilege.md#Privilege) and [PGSQL Authentication](c-privilege.md#Authentication)
* [PGSQL Users](c-pgdbuser.md#Users) and [PGSQL Database](c-pgdbuser.md#Database)



## PGSQL Cluster

生产环境的PGSQL数据库以**集群**为单位进行组织，**集群**是一个由**主从复制**所关联的一组数据库**实例**所构成的**逻辑实体**。每个**数据库集群**是一个**自组织**的业务服务单元，由至少一个**数据库实例**组成。

### Sandbox

集群是基本的业务服务单元，下图展示了沙箱环境中的复制拓扑。其中`pg-meta-1`单独构成一个数据库集群`pg-meta`，而`pg-test-1`，`pg-test-2`，`pg-test-3`共同构成另一个逻辑集群`pg-test`。

```
pg-meta-1
(primary)

pg-test-1 -------------> pg-test-2
(primary)      |         (replica)
               |
               ^-------> pg-test-3
                         (replica)
```

![](_media/SANDBOX.gif)



### High-Availability

> Primary Failure RTO ≈ 30s~1min, RPO < 10MB, Replica Failure RTO≈0 (reset current conn)

Pigsty默认创建创建**高可用PostgreSQL数据库集群**。只要集群中有任意实例存活，集群就可以对外提供完整的读写服务与只读服务。Pigsty可以**自动进行故障切换**，业务方只读流量不受影响；读写流量的影响视具体配置与负载，通常在几秒到几十秒的范围。

默认情况下， Pigsty部署的集群采用 **可用性优先** 模式，主库宕机时，未及时复制至从库部分的数据可能会丢失（正常约几百KB，不超过10MB），您可以参考 [同步从库](d-pgsql.md#同步从库) 的说明，使用 **一致性优先** 模式，此模式下 RPO = 0 。



![](_media/HA-PGSQL.svg)



Pigsty的高可用使用 Patroni + HAProxy实现，前者负责故障切换，后者负责流量切换。Patroni会利用DCS服务进行心跳保活，集群主库默认会注册一个时长为15秒的租约并定期续租。当主库故障无法续租时，租约释放，触发新一轮集群选举。通常，复制延迟最小者（数据损失最小化）会被选举为新的集群领导者。集群进入新的时间线，包括旧主库在内的其他成员都会重新追随新的领导者。

Pigsty提供了多种流量接入方式，如果您使用默认的HAProxy接入，则无需担心集群故障切换对业务流量产生影响。HAProxy会自动检测集群中的实例状态，并正确分发流量。例如，5433端口上的 Primary服务，会使用HTTP GET `ip:8008/primary` 健康检查，从集群中所有的Patroni处获取信息，找出集群主库，并将流量分发至主库上。HAProxy本身是无状态的，均匀部署在每个节点/实例上。任意或所有HAProxy都可以作为集群的服务接入点。



### Interaction

在单个数据库节点/实例上，各组件通过以下联系相互配合：

![](_media/ARCH.gif)



* vip-manager通过**查询**Consul获取集群主库信息，将集群专用L2 VIP绑定至主库节点（默认沙箱接入方案）。
* Haproxy是数据库**流量**入口，用于对外暴露服务，使用不同端口（543x）区分不同的服务。
  * Haproxy的9101端口暴露Haproxy的内部监控指标，同时提供Admin界面控制流量。
  * Haproxy 5433端口默认指向集群主库连接池6432端口
  * Haproxy 5434端口默认指向集群从库连接池6432端口
  * Haproxy 5436端口默认直接指向集群主库5432端口
  * Haproxy 5438端口默认直接指向集群离线实例5432端口
* Pgbouncer用于**池化**数据库连接，缓冲故障冲击，暴露额外指标。
  * 生产服务（高频非交互，5433/5434）必须通过Pgbouncer访问。
  * 直连服务（管理与ETL，5436/5438）必须绕开Pgbouncer直连。
* Postgres提供实际数据库服务，通过流复制构成主从数据库集群。
* Patroni用于**监管**Postgres服务，负责主从选举与切换，健康检查，配置管理。
  * Patroni使用Consul达成**共识**，作为集群领导者选举的依据。
* Consul Agent用于下发配置，接受服务注册，服务发现，提供DNS查询。
  * 所有使用端口的进程服务都会**注册**至Consul中
* PGB Exporter，PG Exporter， Node Exporter分别用于**暴露**数据库，连接池，节点的监控指标
* Promtail是日志收集组件，用于向基础设施Loki发送采集到的PG，PGB，Patroni与节点日志









## ER Model

在Pigsty中，PostgreSQL有四类核心实体：

* [**PGSQL集群**](#集群) **（Cluster）**，以下简称为集群
* [**PGSQL服务**](#服务) **（Service）**，以下简称为服务
* [**PGSQL实例**](#实例) **（Instance）** ，以下简称为实例
* [**PGSQL节点**](#节点) **（Node）** ，以下简称为节点


### Entities

* **集群（Cluster）** 是基本自治单元，由**用户指定**唯一标识，表达业务含义，作为顶层命名空间。
* 集群在硬件层面上包含一系列的**节点（Node）**，即物理机，虚机（或Pod），可以通过**IP**唯一标识。
* 集群在软件层面上包含一系列的**实例（Instance）**，即软件服务器，可以通过**IP:Port**唯一标识。
* 集群在服务层面上包含一系列的**服务（Service）**，即可访问的域名与端点，可以通过**域名**唯一标识。

![](_media/ER-PGSQL.gif)

### Naming Pattern


* 集群的命名可以使用任意满足DNS域名规范的名称，不能带点（`[a-zA-Z0-9-]+`）。
* 节点命名采用集群名称作为前缀，后接`-`，再接一个整数序号（建议从0开始分配，与k8s保持一致）
* PGSQL采用独占式部署，节点与实例一一对应，因此实例命名可与节点命名一致，即`${cluster}-${seq}`的方式。
* 服务命名亦采用集群名称作为前缀，后接`-`连接服务具体内容，如`primary`,` replica`,`offline`,`standby`等。

以沙箱环境的测试数据库集群 `pg-test` 为例：

* 一个集群：用于测试的数据库集群名为“`pg-test`”
* 两种角色：`primary` 与 `replica`，分别是集群主库与从库。
* 三个实例：集群由三个数据库实例：`pg-test-1`, `pg-test-2`, `pg-test-3`组成
* 三个节点：集群部署在三个节点上：`10.10.10.11`, `10.10.10.12`, `10.10.10.13`上。
* 四个服务：
  * 读写服务： [`pg-test-primary`](c-service.md#Primary服务)
  * 只读服务： [`pg-test-replica`](c-service.md#Replica服务)
  * 直连管理服务： [`pg-test-default`](c-service.md#Default服务)
  * 离线查询服务： [`pg-test-offline`](c-service.md#Offline服务)



## Identity Parameter

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






## Cluster

**集群**是基本的自治业务单元，这意味着集群能够作为一个整体组织对外提供服务。类似于k8s中Deployment的概念。注意这里的集群是软件层面的概念，不要与PG Cluster（数据库集簇，即包含多个PG Database的单个PG实例的数据目录）或Node Cluster（机器集群）混淆。

集群是管理的基本单位之一，是用于统合各类资源的组织单位。例如一个PG集群可能包括：

* 三个物理机器节点
* 一个主库实例，对外提供数据库读写服务。
* 两个从库实例，对外提供数据库只读副本服务。
* 两个对外暴露的服务：读写服务，只读副本服务。

### Cluster Naming Pattern

每个集群都有用户根据业务需求定义的唯一标识符，本例中定义了一个名为`pg-test`的数据库集群。

集群名称，其实类似于命名空间的作用。所有隶属本集群的资源，都会使用该命名空间。

**集群标识符**（`cls`）必须在一套环境中唯一，建议采用符合DNS标准 [RFC1034](https://tools.ietf.org/html/rfc1034) 命名规则的标识符。

良好的集群名称应当仅使用小写字母，数字，以及 减号连字符（hyphen）`-`，且只使用字母启头。这样集群中所有对象都可以该标识符作为自己标识符的前缀，严格约束的标识符可以应用于更广泛地场景。

```c
cluster_name := [a-z][a-z0-9-]*
```

集群命名中不应该包括**点（dot）`.`**，之所以强调不要在集群名称中用**点**，是因为有一种流行的命名方式便是采用点号分隔的层次标识符，例如`com.foo.bar`。这种命名方式虽然简洁名快，但用户给出的名字中域名层次数目不可控。如果集群需要与外部系统交互，而外部系统对于命名有约束，这样的名字就会带来麻烦。最直观的例子是Kubernetes中的Pod，Pod的命名规则中不允许出现`.`。

**集群命名的内涵**，建议采用`-`分隔的两段式，三段式名称，例如：

```bashba s
<集群类型>-<业务>-<业务线>
```

典型的集群名称包括：`pg-meta`, `pg-test-fin`, `pg-infrastructure-biz`



-------------

## Instance

实例指带**一个具体的数据库服务器**，它可以是单个进程，也可能是共享命运的一组进程，也可以是一个Pod中几个紧密关联的容器。实例的关键要素在于：

* 可以通过**实例标识**（`ins`）符唯一标识
* 具有处理请求的能力（而不管接收请求的究竟是数据库，还是连接池或负载均衡器）

例如，我们可以把一个Postgres进程，为之服务的独占Pgbouncer连接池，PgExporter监控组件，高可用组件，管理Agent看作一个提供服务的整体，视为一个数据库实例，使用同样的标识符指称。

### Instance Naming Pattern

实例隶属于集群，每个实例在集群范围内都有着自己的唯一标识用于区分。实例标识符`ins`建议采用与Kubernetes Pod一致的命名规则：即集群名称连以从0/1开始递增分配的整数序号`<cls>-<seq>`。

Pigsty默认使用从1开始的自增序列号依次为集群中的新数据库实例命名，例如，数据库集群`pg-test`有三个数据库实例，那么这三个实例就可以依次命名为：`pg-test-1`, `pg-test-2`和`pg-test-3`。

实例名`ins`一旦分配即不可变，该实例将在整个集群的生命周期中使用此标识符。

此外，采用独占节点部署模式时，数据库实例与机器节点可以互相使用对方的标识符。即我们也可用数据库实例标识`ins`来唯一指称一个机器节点。




-------------

## Node

[节点](c-nodes.md#节点)是对硬件资源的一种抽象，通常指代一台工作机器，无论是物理机（bare metal）还是虚拟机（vm），或者是Kubernetes 中的Pod。

?> 注意 Kubernetes 中Node是硬件资源的抽象，但在实际管理使用上，这里Node概念类似于Kubernetes中Pod的概念。

节点的关键特征是：

* 节点是硬件资源的抽象，可以运行软件服务，部署数据库实例
* **节点可以使用IP地址作为唯一标识符**

### Node Naming Pattern

Pigsty使用 `ip` 地址作为节点唯一标识符，如果机器有多个IP地址，则以配置清单中指定的，实际访问使用的IP地址为准。为便于管理，节点应当拥有一个人类可读的充满意义的名称作为节点的主机名。主机名`nodename`，数据库实例标识`ins`，节点标识`ip` 三者在Pigsty中彼此一一对应，可交叉混用做数据库实例、机器节点、HAProxy负载均衡器的标识符。

节点的命名与数据库实例一致，在整个集群的生命周期中保持不变，便于监控与管理。



-------------

## Service

[服务](c-service.md) 是对软件服务（例如Postgres，Redis）的一种**命名抽象（named abstraction）**。服务可以有各种各样的实现，但其的关键要素在于：

* **可以寻址访问的服务名称**，用于对外提供接入，例如：
  * 一个DNS域名（`pg-test-primary`）
  * 一个Nginx/Haproxy Endpoint
* **服务流量路由解析与负载均衡机制**，用于决定哪个实例负责处理请求，例如：
  * DNS L7：DNS解析记录
  * HTTP Proxy：Nginx/Ingress L7：Nginx Upstream配置 
  * TCP Proxy：Haproxy L4：Haproxy Backend配置
  * Kubernetes：Ingress：**Pod Selector 选择器**。
  * 服务也需要决定由哪个组件来处理请求：连接池，或是数据库本身。
  

更多关于服务的介绍，请参考[Service](c-service.md#service)一章。

### Service Naming Pattern

**服务标识** (`svc`) 由两部分组成：作为命名空间的 `cls`， 与服务承载的**角色**（`role`）

在PostgreSQL数据库集群中，实例可能有不同的身份：集群领导者（主库），普通从库，同步从库，离线从库，延迟从库，不同的实例可能会提供不同的服务；同时直连数据库与通过连接池中间件访问数据库也属于性质不同的服务。通常我们会使用服务目标实例的身份角色来标识服务，例如在数据库集群`pg-test`中：

* 指向 主库连接池（`primary`）角色实例的服务，叫做`pg-test-primary`
* 指向 从库连接池（`replica`）角色实例的服务，叫做`pg-test-replica`
* 指向 离线从库数据库（`offline`）的服务，叫做`pg-test-offline`
* 指向 同步复制从库（`standby`）的服务，叫做`pg-test-standby`

请注意，**服务并不够成对实例的划分**，同一个服务可以指向集群内多个不同的实例，然而同一个实例也可以承接来自不同服务的请求。例如，角色为 `standby`的同步从库既可以承接来自 `pg-test-standby` 的同步读取请求，也可以承接来自 `pg-test-replica` 的普通读取请求。





