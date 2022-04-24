# Conecpt: PGSQL

> 介绍 PostgreSQL 数据库集群管理所需的核心概念


* [PGSQL集群](#PGSQL集群) / [实体模型](#实体模型) / [身份参数](#身份参数)
* [集群](#集群（cluster）) /  [实例](#实例（instance）) / [节点](#节点（node） ) / [服务](#服务（service）) 
* [PostgreSQL高可用](#高可用)




* [部署：PGSQL](d-pgsql.md) ｜[配置：PGSQL](v-pgsql.md)  | [剧本：PGSQL](p-pgsql.md) ｜ [定制：PGSQL](v-pgsql-customize.md)
* [PGSQL服务](c-service.md#服务) 与 [PGSQL接入](c-service.md#接入)
* [PGSQL权限](c-privilege.md#权限) 与 [PGSQL认证](c-privilege.md#认证)
* [PGSQL业务用户](c-pgdbuser.md#用户) 与 [PGSQL业务数据库](c-pgdbuser.md#数据库)



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

![](/Volumes/Data/pigsty/docs/_media/ER-PGSQL.gif)

* **Cluster** is the basic autonomous unit, uniquely identified by **user designation**, expressing business meaning, and serving as a top-level namespace.
* The clusters contain a series of **Nodes** at the hardware level, i.e., physical machines and VMs (or Pods) that IP can uniquely identify.
* The cluster contains a series of **Instances** at the software level, i.e., software servers, which can be uniquely identified by **IP: Port**.
* The cluster contains a series of **Services** at the service level, i.e., accessible domains and ports that can be uniquely identified by **domains**.

![](_media/ER-PGSQL.gif)

### Naming Pattern

* Cluster naming can use any name that satisfies the DNS domain name specification, not with a dot ( `[a-zA-Z0-9-]+`).
* Node naming uses the cluster name as a prefix, followed by `-`and an ordinal integer number.
* Instance naming can be consistent with the node naming, i.e., `${cluster}-${seq}`.
* Service naming also uses the cluster name as the prefix, followed by `-` to connect the service specifics, such as `primary`, ` replica`, `offline`, `delayed`, etc.

**Naming Example**

Take the test database cluster `pg-test` for a sandbox as an example.

* One cluster: The database cluster for testing is named `pg-test`".
* Two roles: `primary` and `replica`.
* Three instances: The cluster consists of three database instances: `pg-test-1`, `pg-test-2`, `pg-test-3`.
* Three nodes: The cluster is deployed on three nodes: `10.10.10.11`, `10.10.10.12`, and `10.10.10.13`.
* Four services: read-write service `pg-test-primary`, read-only service `pg-test-replica`, directly connected management service `pg-test-default`, offline read service `pg-test-offline`.



## Identity Parameter

实体与标识符是一种概念模型，下面介绍Pigsty中的具体实现。

[`pg_cluster`](#pg_cluster)，[`pg_role`](#pg_role)，[`pg_seq`](#pg_seq) 属于 **身份参数** ，用于生成实体标识。

除IP地址外，这三个参数是定义一套新的数据库集群的最小必须参数集

* Cluster Identity：`pg_cluster` ： `{{ pg_cluster }}`
* Instance Identity：`pg_instance` ： `{{ pg_cluster }}-{{ pg_seq }}`
* Service Identity：`pg_service` ：`{{ pg_cluster }}-{{ pg_role }}`
* Node Identity：`nodename`：
  * if `pg_hostname: true`: 使用与 `pg_instance`相同的：`{{ pg_cluster }}-{{ pg_seq }}`
  * if `pg_hostname: false`: 显式指定`{{ nodename }}`则直接使用，否则使用现有主机名。

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



## **Cluster**

**A cluster** is the basic autonomous business unit, which means that the cluster can provide services as a whole. Note that cluster here is a software-level concept, not to be confused with PG Cluster (database set cluster, i.e., a data directory containing multiple PGs of a singleton) or Node Cluster (machine cluster).

A cluster is one of the basic management units, and an organizational unit is used to unify various sources. A PG cluster may include.

* Three physical machine nodes
* One primary instance provides database read and writes services.
* Two replica instances provide read-only copies of the database.
* Two exposed services: read-write service, and read-only copy service.

### Cluster **Naming Pattern**

Each cluster has a unique identity. In this case, a database cluster named `pg-test` is defined.

The cluster name is similar to the role of a namespace. All sources belonging to this cluster will use this namespace.

The **cluster identity** (`cls`) must be unique within a set of environments, and naming patterns that conform to the DNS standard [RFC1034](https://tools.ietf.org/html/rfc1034) is recommended.

A good cluster name should use only lowercase letters, numbers, and the hyphen `-`, and use letter starters. 

```c
cluster_name := [a-z][a-z0-9-]*
```

Cluster naming should not include the **dot`. `** A popular naming pattern uses dot-separated hierarchical identities, such as `com.foo.bar`. This naming is simple, but the number of domain hierarchies is not controllable. The most intuitive example is Pods in Kubernetes, where Pod naming patterns do not allow`. `

**Connotation of cluster naming** is recommended by-separated two-paragraph and three-paragraph names.

```bashba s
<cluster type>-<business>-<business line>
```

Typical cluster names include: `pg-meta`, `pg-test-fin`, `pg-infrastructure-biz`.



-------------

## Instance

An instance refers to **a specific database server**, which can be a single process, a group of processes, or several associated containers within a Pod. The critical elements of an instance are.

* Can be uniquely identified by the **instance identity** (`ins`).
* Can handle requests (regardless of whether the request is received from a database, a connection pool, or a load balancer).

### Instance Naming Pattern

Instances belong to clusters, and each instance has its unique identity within the cluster. The instance identity `ins` is recommended to use a naming pattern consistent with Kubernetes Pods: i.e., cluster name linked to an ordinal integer number in increments from 0/1 `<cls>-<seq>`.

By default, Pigsty names the database instances in a cluster, increasing order starting from 1. For example, the database cluster `pg-test` has three database instances: `pg-test-1`, `pg-test-2`, and `pg-test-3`.

Once the instance name `ins` is assigned immutable, the instance will be used for the entire lifetime of the cluster.

In addition, with a singleton deployment, the database instance and the machine node can use each other's identities.




-------------

## Node

**A Node** is an abstraction of a hardware resource, usually referring to a working machine, whether a physical machine (bare metal), a VM, or a Pod in Kubernetes.

?> Note that Node in Kubernetes is an abstraction of hardware sources, but in reality, the concept of Node is similar to the concept of Pod in Kubernetes.

The key features of a Node are.

* Nodes are abstractions of hardware sources that can run software services and deploy database instances.
* **Nodes can use IP as unique identities**.

### Node Naming Pattern

Pigsty uses `ip` as the node's unique identity. If the machine has more than one IP, the actual access IP specified in the inventory will prevail. The hostname `nodename`, database instance identity `ins`, and node identity `ip` correspond to each other in Pigsty and can be cross-used as identities for database instances, machine nodes, and HAProxy load balancers.

The node naming is consistent with the database instance and remains the same throughout the cluster's life.



-------------

## Service

A [service](c-service.md) is a **named abstraction** of a software service (e.g., Postgres, Redis). Services have various implementations, but the key elements are:

* **An addressable and accessible service name** for providing access:
  * A DNS domain name (`pg-test-primary`)
  * An Nginx/Haproxy Port
* **Service traffic routing and load balancing mechanism** for deciding which instance handles requests:
  * DNS L7: DNS resolution records
  * HTTP Proxy: Nginx/Ingress L7: Nginx Upstream Config 
  * TCP Proxy: Haproxy L4: Haproxy Backend Config
  * Kubernetes: Ingress: **Pod Selector**.
  * The service also needs to decide which component will handle the request: the connection pool, or the database itself.

For more information about services, see the chapter [Services](c-service.md).

### Service Naming Pattern

**The service identity** (`svc`) consists of `cls` as a namespace and (`role`) as the service bearer.

In a PostgreSQL cluster, instances have different identities: primary, replica, standby, offline, and delayed. Different instances will provide different services; direct connection to the database and access to the database through connection pools are services of varying nature. It is common to use the role of the service target to identify the service, e.g., in the database cluster `pg-test`.

* A service that points to an instance of the primary connection pool (`primary`) role is called `pg-test-primary`.
* A service that points to a replica connection pool (`replica`) role is called `pg-test-replica`.
* A service that points to an (`offline`) is called `pg-test-offline`.
* A service that points to a (`standby`) is called `pg-test-standby`.

Note that **services are not enough to divide pairs of instances**. The same service can point to multiple instances. However, the same instance can also handle requests from different services.

