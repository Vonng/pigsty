# Entity & Identifier

Entity and their naming are very important.

The naming pattern reflects the engineer's knowledge of the system architecture. Poorly defined concepts will lead to confusing communication, and arbitrarily set names will create an unexpected extra burden.

This article introduces the concept of domain entities in Pigsty, and the naming pattern used to identify them.



-------------

## Core Model

There are four types of core entities in Pigsty: [Database Cluster](c-arch.md#PGSQL-cluster) **(Cluster)**, [Database Service](c-service.md) **(Service)**, **Database Instance**, [Database Node](c-arch.md#database-node) **(Node)**.
Hereafter referred to as cluster, service, instance, and node:

![](_media/er-core.svg)


**Description**

* **Cluster** is the basic autonomous unit, uniquely identified by **user designation**, expressing business meaning, and serving as a top-level namespace.
* Clusters contain a series of **Nodes** at the hardware level, i.e., physical machines, and virtual machines (or Pods) that can be uniquely identified by **IP**.
* The cluster contains a series of **Instances** at the software level, i.e., software servers, which can be uniquely identified by **IP: Port**.
* The cluster contains a series of **Services** at the service level, i.e., accessible domains and endpoints that can be uniquely identified by **domains**.

**Naming Pattern**

* Cluster naming can use any name that satisfies the DNS domain name specification, not with a dot ( `[a-zA-Z0-9-]+`).
* Node naming uses the cluster name as a prefix, followed by `-`, and then an integer ordinal number (recommended to be assigned starting from 0, consistent with k8s).
* Because Pigsty uses exclusive deployment, nodes correspond to instances one by one. Then the instance naming can be consistent with the node naming, i.e. `${cluster}-${seq}` way.
* Service naming also uses the cluster name as the prefix, followed by `-` to connect the service specifics, such as `primary`, ` replica`, `offline`, `delayed`, etc.

**Naming Example**

Take the test database cluster `pg-test` for a sandbox env as an example:

* One cluster: the database cluster for testing is named `pg-test`".
* Two roles: `primary` and `replica`, which are the cluster master and slave respectively.
* Three instances: The cluster consists of three database ins: `pg-test-1`, `pg-test-2`, `pg-test-3`
* Three nodes: The cluster is deployed on three nodes: `10.10.10.11`, `10.10.10.12`, and `10.10.10.13`.
* Four services: read-write service `pg-test-primary`, read-only service `pg-test-replica`, directly connected management service `pg-test-default`, offline read service `pg-test-offline`.



-------------

## Full Model

The four-entity model can be expanded:

![](_media/er-full.svg)

**Description**

* **Environment** or **Deployment** is a complete Pigsty system.
* Each set of envs has a [config](v-config.md) (Config), with a set of [infrastructure](c-arch.md#infrastructure) (Infrastructure) that manages multiple sets of [database clusters](c-arch.md#PGSQL-clusters).
* There are several [**business databases**](c-pgdbuser.md) (Databases) on each database instance that serve as the top-level namespace at the logical level.
* There are various **Database objects** within each database, such as tables, indexes, sequence numbers, functions, etc.

**Identifiers**

* For each set of **environments**, represented by a custom identifier, Pigsty uses the environment identifier `pgsql` by default. You can use any meaningful name: `prod`, `staging`, `uat`, `testing`, `pgsql`, `pgsql-prod`, etc.
* **Horizontal sharding** is currently not a hierarchy of entities natively supported by Pigsty, but you can emulate this hierarchy through the rules of cluster naming. The cluster to which a horizontal shard belongs can be identified as belonging to a horizontal shard by using a uniform naming rule: `xxx-shard\d+`.
* **Database** naming is at the discretion of the user, but it is recommended to use the same constraint rules as the cluster name, e.g. `test`, `meta`, `grafana`.
* **Database objects** are named at the user's discretion, but it is recommended to use the same constraint rules as the cluster name. Pigsty uses the full name with the schema name to identify the object, for example `public.cluster`.



-------------

## Identity

Entities and identifiers are a conceptual model, and the following describes the specific implementation in Pigsty.

The most representative implementation of Pigsty identifiers is the **Label** for temporal data in Prometheus. This is shown in the following table：

| Entity       | Identifier | Identifier Example                   | Label                      |
| ------------ | ---------- | ------------------------------------ | -------------------------- |
| Environment  | **`job`**  | `pgsql`, `redis`, `staging`          | `{job}`                    |
| Shard        |            | `pg-test-shard\d+`                   | `{job, cls*}`              |
| **Cluster**  | **`cls`**  | `pg-meta`, `pg-test`                 | `{job, cls}`               |
| Service      |            | `pg-meta-primary`, `pg-test-replica` | `{job, cls}`               |
| **Instance** | **`ins`**  | `pg-meta-1`, `pg-test-1`             | `{job, cls, ins}`          |
| Database     |            | `test`                               | `{..., datname}`           |
| Object       |            | `public.pgbench_accounts`            | `{..., datname, <object>}` |

The most critical **cluster identifiers (cls)** and **instance identifiers (ins)** are automatically generated through [identity parameters](#Identity) in the cluster config, including：

| name | attributes | description | example |
| :-----------------------------------------: | :----------------: | :------: | :------------------: |
| [`pg_cluster`](v-pgsql.md#pg_cluster) | **REQUIRED**, cluster level | cluster name | `pg-test` |
| [`pg_role`](v-pgsql.md#pg_role) | **REQUIRED**, instance level | instance role | `primary`, `replica` |
| [`pg_seq`](v-pgsql.md#pg_seq) | **REQUIRED**, instance level | serial number | `1`, `2`, `3`,`... ` |

The identity parameters are the **minimum set of mandatory parameters** required to define the database cluster. The core identity parameters **must be explicitly specified** and cannot be ignored.

- `pg_cluster` (`cls`) identifies the name of the cluster, configured at the cluster level, and serves as the top-level namespace for cluster resources.
- `pg_instance` (`ins`) is used to uniquely identify a database instance, which is composed of `pg_cluster` and `pg_seq` spelled together by `-`.
- `pg_seq` is used to identify an instance within a cluster, usually as an integer incrementing from 0 or 1, and will not be changed once assigned.
- `pg_service` (`svc`) uniquely identifies the service in the cluster, and is formed by combining `pg_cluster` and `pg_role` via `-`.
- `pg_role` identifies the role that the instance plays in the cluster and is configured at the instance level, with optional values including
  - `primary`: the **unique primary repository** in the cluster, the cluster leader, which provides writing services.
  - `replica`: the **ordinary slave library** in the cluster, which takes on regular production read-only traffic.
  - `offline`: **offline slave** in the cluster, takes ETL/SAGA/personal user/interactive/analytical queries.
  - `standby`: **synchronous slave** in the cluster, with synchronous replication and no replication latency.
  - `delayed`: **delayed slave** in the cluster, explicitly specifying replication delay, used to perform backtracking queries and data salvage.




-------------




## **Cluster**

A **cluster** is a basic autonomous business unit, which means that the cluster can be organized as a whole to provide services to the outside. Similar to the concept of Deployment in k8s. Note that cluster here is a software-level concept, not to be confused with PG Cluster (Database Set Cluster, i.e., a data dir containing multiple PG with a single PG ins) or Node Cluster (Machine Cluster).

A cluster is one of the basic units of management, an organizational unit used to unify various types of resources. For example, a PG cluster may include：

* Three physical machine nodes.
* A master ins that provides database read and write services to the outside.
* Two slave instances, which provide read-only copies of the database to the public.
* Two externally exposed services: read-write service, and read-only copy service.

### **Naming Pattern**

Each cluster has a unique identifier defined by the user based on business requirements, in this case, a cluster named `pg-test` is defined.

The cluster name, in fact, is similar to the role of a namespace. All resources belonging to this cluster will use this namespace.

The **cluster identifier** (`cls`) must be unique within a set of envs, and it is recommended to use an identifier that conforms to the DNS standard [RFC1034](https://tools.ietf.org/html/rfc1034) naming rules.

A good cluster name should use only lowercase letters, numbers, and the hyphen `-`, and use only letter starters. This way all objects in the cluster can use the identifier as a prefix to their own identifier and the tightly constrained identifier can be applied to a wider range of scenarios.

```c
cluster_name := [a-z][a-z0-9-]*
```

Cluster naming should not include the **dot`. `** The reason for the emphasis on not using **dots** in cluster names is that there is a popular naming style that uses dot-separated level identifiers, such as `com.foo.bar`. This naming style is simple and fast, but the number of domain levels in the name given by the user is not controllable. Such names can cause problems if the cluster needs to interact with external systems that have constraints on naming. The most intuitive example is Pods in Kubernetes, where Pod naming rules do not allow `. `.

**Connotation of cluster naming**, `-`-separated two-paragraph, three-paragraph names are recommended, e.g:

```bashba s
<cluster type>-<business>-<business line>
```

Typical cluster names include: `pg-meta`, `pg-test-fin`, `pg-infrastructure-biz`.



-------------

## Instance

An instance refers to **a specific database server**, which can be a single process, a group of processes sharing a common fate, or several closely related containers in a Pod. The key elements of an instance are:

* can be uniquely identified by the **instance identifier** (`ins`) character.
* the ability to process requests (regardless of whether the request is received from a database, a connection pool, or a load balancer).

For example, we can consider a Postgres process, the exclusive Pgbouncer connection pool that serves it, the PgExporter monitoring component, the high availability component, and the Management Agent as a whole that provides a service as a database instance, using the same identifier designation.

### Naming Pattern

Instances are part of a cluster, and each ins has its own unique identifier to distinguish it within the cluster. The ins identifier `ins` is recommended to use the same naming rules as Kubernetes Pods: i.e., cluster names are concatenated with integer sequences `<cls>-<seq>` assigned incrementally from 0/1.

By default, Pigsty names the new database ins in the cluster sequentially using increasing sequential numbers starting from 1. For example, if the cluster `pg-test` has three database ins, then the three ins can be named sequentially: `pg-test-1`, `pg-test-2`, and `pg-test-3`.

The instance name `ins` is immutable once it is assigned and the instance will use this identifier for the entire lifetime of the cluster.

In addition, with the exclusive node deployment model, the database instance and the machine node can use each other's identifiers. That is, we can also use the database instance identifier `ins` to uniquely refer to a machine node.








-------------

## Node

**A Node** is an abstraction of a hardware resource, usually referring to a working machine, whether it is a physical machine (bare metal) or a virtual machine (vm), or a Pod in Kubernetes.

Note that Node in Kubernetes is an abstraction of a hardware resource, but in terms of actual management usage, the concept of Node here is similar to the concept of Pod in Kubernetes.

The key features of a Node are:

* Nodes are abstractions of hardware resources that can run software services and deploy database instances.
* **Nodes can use IP addresses as unique identifiers**.

### Naming Pattern

Pigsty uses the `ip` address as a unique identifier for the node, and if the machine has multiple IP addresses, the IP address specified in the inventory that is actually used for access is used. For administrative purposes, the node should have a human-readable and meaningful name as the hostname of the node. The hostname `nodename`,  instance identifier `ins`, and node identifier `ip` correspond to each other one by one in Pigsty and can be cross-mixed as identifiers for database instances, machine nodes, and HAProxy load balancers.

The node naming is consistent with the database instance and remains the same throughout the cluster lifecycle for easy monitoring and management.





-------------

## Service

A [service](c-service.md) is a **named abstraction** of a software service (e.g. Postgres, Redis). Services can be implemented in a variety of ways, but the key elements are:

* **an addressable and accessible service name** for providing access to the outside world:
  * A DNS domain name (`pg-test-primary`)
  * An Nginx/Haproxy Endpoint
* **Service traffic routing resolution and load balancing mechanism** for deciding which instance is responsible for handling requests, e.g:
  * DNS L7: DNS resolution records
  * HTTP Proxy: Nginx/Ingress L7: Nginx Upstream config 
  * TCP Proxy: Haproxy L4: Haproxy Backend config
  * Kubernetes: Ingress: **Pod Selector Selector**.
  * The service also needs to decide which component will handle the request: the connection pool, or the database itself.

For more info about services, see the chapter [Services](c-service.md).

### Naming Pattern

**The service identity** (`svc`) consists of two parts: `cls` as a namespace, and **role** (`role`) as the service bearer.

In a PostgreSQL cluster, instances may have different identities: cluster leader (master), normal slave, synchronous slave, offline slave, deferred slave, and different instances may provide different services; also a connection to the database and access to the database through connection pool middleware are services of different nature. Usually, we use the identity role of the service target instance to identify the service, e.g. in the database cluster `pg-test`.

* A service that points to an instance of the master connection pool (`primary`) role is called `pg-test-primary`
* A service that points to a slave connection pool (`replica`) role instance, called `pg-test-replica`
* A service that points to an offline slave database (`offline`), called `pg-test-offline`
* A service that points to a synchronous replication slave (`standby`) called `pg-test-standby`

Note that **services are not enough to divide pairs of instances**, the same service can point to multiple different instances within the cluster, however, the same instance can also take requests from different services. For example, a synchronous slave with the role `standby` can take both synchronous read requests from `pg-test-standby` and normal read requests from `pg-test-replica`.
