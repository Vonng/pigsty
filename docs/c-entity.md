# Entity & Identifier

Entity, and their naming are very important things, and naming style reflects the engineer's knowledge of the system architecture.
Poorly defined concepts will lead to confusing communication, and arbitrarily set names will create an unexpected extra burden.
This article introduces the concept of domain entities in Pigsty, and the naming rules used to identify them.

-------------

## Core Model

There are four types of core entities in Pigsty: [Database Cluster](c-arch.md#database-cluster) **(Cluster)**, [Database Service´](c-service.md) **(Service)**, **Database Instance**, [**Database Node**](c-arch.md#database-node) **(Node)**
Hereafter referred to as cluster, service, instance, and node.

![](_media/er-core.svg)


**Description**

* **Cluster** is the basic autonomous unit, uniquely identified by **user designation**, expressing business meaning, and serving as a top-level namespace.
* Clusters contain a series of **Nodes** at the hardware level, i.e., physical machines, virtual machines (or Pods) that can be uniquely identified by **IP**.
* The cluster contains a series of **Instance** at the software level, i.e., software servers, which can be uniquely identified by **IP:Port**.
* The cluster contains a series of **Services** at the service level, i.e., accessible domains and endpoints that can be uniquely identified by **domains**.

**Naming Pattern**

* Cluster naming can use any name that satisfies the DNS domain name specification, not with a dot ( `[a-zA-Z0-9-]+`).
* Node naming uses the cluster name as a prefix, followed by `-`, and then an integer ordinal number (recommended to be assigned starting from 0, consistent with k8s)
* Because Pigsty uses exclusive deployment, nodes correspond to instances one by one. Then the instance naming can be consistent with the node naming, i.e. `${cluster}-${seq}` way.
* Service naming also uses the cluster name as the prefix, followed by `-` to connect the service specifics, such as `primary`, ` replica`, `offline`, `delayed`, etc.

**Naming Example**

Take the test database cluster `pg-test` for a sandbox environment as an example.

* One cluster: the database cluster for testing is named `pg-test`"
* Two roles: `primary` and `replica`, which are the cluster master and slave respectively.
* Three instances: The cluster consists of three database instances: `pg-test-1`, `pg-test-2`, `pg-test-3`
* Three nodes: The cluster is deployed on three nodes: `10.10.10.11`, `10.10.10.12`, `10.10.10.13`.
* Four services: read-write service `pg-test-primary`, read-only service `pg-test-replica`, directly connected management service `pg-test-default`, offline read service `pg-test-offline



-------------

## Full Model

The four-entity model can be expanded:

![](_media/er-full.svg)

**Description**

* **Environment** , or **Deployment** is a complete Pigsty system.
* Each set of environments has a [configuration](c-config.md) (Config), with a set of [infrastructure](c-arch.md#infrastructure) (Infrastructure) that manages multiple sets of [database clusters](c-arch.md#database clusters)
* There are several [**business databases**](c-database.md) (Databases) on each database instance that serve as the top-level namespace at the logical level
* There are various **Database objects** within each database, such as tables, indexes, sequence numbers, functions, etc.

**Identifiers**

* Each set of **environments**, represented by a custom identifier, Pigsty uses the environment identifier `pgsql` by default. You can use any meaningful name: `prod`, `staging`, `uat`, `testing`, `pgsql`, `pgsql-prod`, etc.
* **Horizontal sharding** is currently not a hierarchy of entities natively supported by Pigsty, but you can emulate this hierarchy through the rules of cluster naming. The cluster to which a horizontal shard belongs can be identified as belonging to a horizontal shard by using a uniform naming rule: `xxx-shard\d+`.
* **Database** naming is at the discretion of the user, but it is recommended to use the same constraint rules as the cluster name, e.g. `test`, `meta`, `grafana`.
* **Database objects** are named at the user's discretion, but it is recommended to use the same constraint rules as the cluster name. Pigsty uses the full name with the schema name to identify the object, for example: `public.cluster`.



-------------

## Identity

The most critical **cluster identifiers (cls)** and **instance identifiers (ins)** are automatically generated through [identity parameters](c-config.md#identity parameters) in the cluster configuration, including

| name | attributes | description | example |
| :-----------------------------------------: | :----------------: | :------: | :------------------: |
| [`pg_cluster`](v-pg-provision.md#pg_cluster) | **REQUIRED**, cluster level | cluster name | `pg-test` |
| [`pg_role`](v-pg-provision.md#pg_role) | **REQUIRED**, instance level | instance role | `primary`, `replica` |
| [`pg_seq`](v-pg-provision.md#pg_seq) | **REQUIRED**, instance level | serial number | `1`, `2`, `3`,`... ` |

The identity parameters are the **minimum set of mandatory parameters** required to define the database cluster. The core identity parameters** must be explicitly specified** and cannot be ignored.

- `pg_cluster` (`cls`) identifies the name of the cluster, configured at the cluster level, and serves as the top-level namespace for cluster resources.
- `pg_instance` (`ins`) is used to uniquely identify a database instance, which is composed of `pg_cluster` and `pg_seq` spelled together by `-`.
- `pg_seq` is used to identify an instance within a cluster, usually as an integer incrementing from 0 or 1, and will not be changed once assigned.
- `pg_service` (`svc`) uniquely identifies the service in the cluster, and is formed by combining `pg_cluster` and `pg_role` via `-`.
- `pg_role` identifies the role that the instance plays in the cluster and is configured at the instance level, with optional values including
  - `primary`: the **unique primary repository** in the cluster, the cluster leader, which provides write services.
  - `replica`: the **ordinary slave library** in the cluster, which takes on regular production read-only traffic.
  - `offline`: **offline slave** in the cluster, takes ETL/SAGA/personal user/interactive/analytical queries.
  - `standby`: **synchronous slave** in the cluster, with synchronous replication and no replication latency.
  - `delayed`: **delayed slave** in the cluster, explicitly specifying replication delay, used to perform backtracking queries and data salvage.

