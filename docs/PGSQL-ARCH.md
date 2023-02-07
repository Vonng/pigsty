# PGSQL Architecture


PGSQL for production environments is organized in **clusters**, which **clusters** are **logical entities** consisting of a set of database **instances** associated by **primary-replica**. Each **database cluster** is a **self-organizing** business service unit consisting of at least one **database instance**.



### High-Availability

> Primary Failure RTO ≈ 30s~1min, RPO < 10MB, Replica Failure RTO≈0 (reset current conn)

Pigsty creates a **HA PostgreSQL cluster** by default. Pigsty can **automatic failover,** and read-only business traffic is not affected; the impact of reading and write traffic depends on the specific configuration and load, usually in a few seconds to tens of seconds.

By default, Pigsty deploys clusters in **availability first** mode. When the primary goes down, data not replicated to the replica part may be lost (generally about a few hundred KB, no more than 10 MB); you can refer to [Sync Standby](d-pgsql.md#Sync-Standby) and use **consistency first** mode, RPO = 0 in this mode.



![pgsql-ha](https://user-images.githubusercontent.com/8587410/206971583-74293d7b-d29a-4ca2-8728-75d50421c371.gif)



Pigsty's HA is achieved using Patroni + HAProxy, with the former failing over and the latter switching over traffic.

Patroni uses DCS service for heartbeat preservation, and the primary will register a 15-second lease by default and renew it periodically. When the primary fails to renew the lease, the lease is released, and a new primary election round is triggered. Usually, the one with the lowest delay is elected as the new primary. The cluster enters a new timeline, and all other clusters, including the old primary, re-follow the new primary.

HAProxy automatically detects the state of the instances and distributes the traffic correctly. Haproxy is stateless and deployed uniformly on each node/instance. All HAProxy can act as service access for the cluster. For example, the Primary service on port 5433 will use HTTP GET `ip:8008/primary` health check to get information from all Patroni in the cluster, find out the primary, and distribute traffic to the primary.





### Interaction

On a singleton node/instance, the components work with each other through the following connections.

![](_media/ARCH.gif)



* vip-manager gets the primary information by **querying** the Consul and binds the cluster-specific L2 VIP to the primary (default sandbox access).
* Haproxy is the database **traffic** portal for exposing services, with different ports (543x) distinguishing between different services.
  * Haproxy port 9101 exposes Haproxy monitoring metrics and provides Admin interface traffic control.
  * Haproxy port 5433 defaults point to primary connection pool port 6432
  * Haproxy port 5434 defaults point to replica connection pool port 6432
  * Haproxy port 5436 defaults point to primary 5432 port.
  * Haproxy port 5438 defaults point to offline 5432 port.
* Pgbouncer is used for **pooling** database connections, buffering failures, and exposing additional metrics.
  * Production services (HF non-interactive, 5433/5434) must be accessed via Pgbouncer.
  * Directly connected services (management and ETL, 5436/5438) must be directly connected, bypassing Pgbouncer.
* Postgres provides database services that form a primary-replica cluster via streaming replication.
* Patroni **oversees** the Postgres service, primary-replica election and switchover, health checks, and config management.
  * Patroni uses Consul to reach **Consensus**, the basis for the primary election.
* The Consul Agent is used to issue configs, accept service registrations, service discovery, and provide DNS queries.
  * All services that use the port are **registered** with Consul.
* PGB Exporter, PG Exporter, and Node Exporter are used to **expose** database, connection pool, and node monitoring metrics.
* Promtail is the log collection component used to send the collected PG, PGB, Patroni, and node logs to the infrastructure Loki.









## ER Model

In Pigsty, PostgreSQL has four types of core entities.

* [**PGSQL Cluster**](#Cluster)， Hereafter referred to as clusters
* [**PGSQL Service**](#Service)， Hereafter referred to as services
* [**PGSQL Instance**](#Instance)， Hereafter referred to as instances
* [**PGSQL Node**](#Node)， Hereafter referred to as nodes


### Entities

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

Take the test database cluster `pg-test` for a sandbox as an example.

* One cluster: The database cluster for testing is named `pg-test`.
* Two roles: `primary` and `replica`.
* Three instances: The cluster consists of three database instances: `pg-test-1`, `pg-test-2`, `pg-test-3`.
* Three nodes: The cluster is deployed on three nodes: `10.10.10.11`, `10.10.10.12`, and `10.10.10.13`.
* Four services:
  *  read-write service:  [`pg-test-primary`](c-service.md#Primary-Service)
  * read-only service: [`pg-test-replica`](c-service.md#Replica-Service)
  * directly connected management service: [`pg-test-default`](c-service.md#Default-Service)
  * offline read service: [`pg-test-offline`](c-service.md#Offline-Service)



## Identity Parameter

Entities and identities are a conceptual model, and the following describes the implementation in Pigsty.

[`pg_cluster`](v-pgsql.md#pg_cluster)，[`pg_role`](v-pgsql.md#pg_role)， and [`pg_seq`](v-pgsql.md#pg_seq) are **identity parameters** used to generate entity identities.

In addition to the IP address, these three parameters are the minimum set of parameters necessary to define database clusters.

* Cluster Identity：`pg_cluster` ： `{{ pg_cluster }}`
* Instance Identity：`pg_instance` ： `{{ pg_cluster }}-{{ pg_seq }}`
* Service Identity：`pg_service` ：`{{ pg_cluster }}-{{ pg_role }}`
* Node Identity：`nodename`：
  *  `pg_hostname: true`: Use the same as `pg_instance`：`{{ pg_cluster }}-{{ pg_seq }}`
  *  `pg_hostname: false`: Explicitly specifying `{{ nodename }}` is used directly. Otherwise, the existing hostname is used.

The following is a sample definition of a `pg-test` cluster in a sandbox.


```yaml
pg-test:
  hosts:
    10.10.10.11: {pg_seq: 1, pg_role: replica}
    10.10.10.12: {pg_seq: 2, pg_role: primary}
    10.10.10.13: {pg_seq: 3, pg_role: replica}
  vars:
    pg_cluster: pg-test
    pg_hostname: true     # The identity of the PG instance as the identity of the node(1:1)
```

The three members of the cluster are identified as follows.

|     host      |  cluster  |  instance   |      service      |  nodename   |
| :-----------: | :-------: | :---------: | :---------------: | :---------: |
| `10.10.10.11` | `pg-test` | `pg-test-1` | `pg-test-primary` | `pg-test-1` |
| `10.10.10.12` | `pg-test` | `pg-test-2` | `pg-test-replica` | `pg-test-2` |
| `10.10.10.13` | `pg-test` | `pg-test-3` | `pg-test-replica` | `pg-test-3` |

In the monitoring system, the monitoring time series data is labeled as：

```json
pg_up{cls="pg-meta", ins="pg-meta-1", ip="10.10.10.10", job="pgsql"}
pg_up{cls="pg-test", ins="pg-test-1", ip="10.10.10.11", job="pgsql"}
pg_up{cls="pg-test", ins="pg-test-2", ip="10.10.10.12", job="pgsql"}
pg_up{cls="pg-test", ins="pg-test-3", ip="10.10.10.13", job="pgsql"}
```






## Cluster

**A cluster** is the basic autonomous business unit, which means that the cluster can provide services as a whole. Note that cluster here is a software-level concept, not to be confused with PG Cluster (database set cluster, i.e., a data directory containing multiple PGs of a singleton) or Node Cluster (machine cluster).

A cluster is one of the basic management units, and an organizational unit is used to unify various sources. A PG cluster may include.

* Three physical machine nodes
* One primary instance provides database read and writes services to.
* Two replica instances provide read-only copies of the database.
* Two exposed services: read-write service, and read-only copy service.

### Cluster Naming Pattern

Each cluster has a unique identity. In this case, a database cluster named `pg-test` is defined.

The cluster name is similar to the role of a namespace. All sources belonging to this cluster will use this namespace.

The **cluster identity** (`cls`) must be unique within a set of environments, and naming patterns that conform to the DNS standard [RFC1034](https://tools.ietf.org/html/rfc1034) is recommended.

A good cluster name should use only lowercase letters, numbers, and the hyphen `-`and use letter starters.

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

Pigsty names the database instances in a cluster by default, increasing order starting from 1. For example, the database cluster `pg-test` has three database instances: `pg-test-1`, `pg-test-2`, and `pg-test-3`.

Once the instance name `ins` is assigned immutable, the instance will be used for the entire lifetime of the cluster.

In addition, with a singleton deployment, the database instance and the machine node can use each other's identities.




-------------

## Node

**[A Node](c-nodes.md#Node)** is an abstraction of a hardware resource, usually referring to a working machine, whether a physical machine (bare metal), a VM or a Pod in Kubernetes.

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

* A service that points to the primary connection pool (primary) role instance is called `pg-test-primary`.
* A service that points to a replica connection pool (`replica`) role is called `pg-test-replica`.
* A service that points to an (`offline`) is called `pg-test-offline`.
* A service that points to a (`standby`) is called `pg-test-standby`.

Note that **services are not enough to divide pairs of instances**. The same service can point to multiple instances. However, the same instance can also handle requests from different services.








### Sandbox

Clusters are the basic business service units, and the following diagram shows the replication topology in a sandbox where `pg-meta-1` constitutes a database cluster `pg-meta`. In contrast, `pg-test-1`, `pg-test-2`, and `pg-test-3` form another logical cluster `pg-test`.

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


