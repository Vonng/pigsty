# Concept: Redis

> This article introduces the core concepts required for Redis cluster management.

[Deploy: Redis](d-redis.md) ｜[Config: Redis](v-redis.md)  | [Playbook: Redis](p-redis.md)



### ER Model

The Redis entity concept model is almost identical to [PostgreSQL](c-entity.md) and includes the **Cluster** and **Instance**. Note that Cluster here does not refer to the clusters in Redis' native clusters.

The core difference is that Redis typically uses multiple singleton instances, with **multiple** Redis instances typically deployed on a single physical/VM to take advantage of multi-core CPUs.

In Pigsty-managed Redis, it is not yet possible to deploy two Redis instances from different clusters on a node, but this does not affect the deployment of multiple independent Redis instances on a node.


### Redis Identity

The [**identity parameters**](v-redis.md#identity-parameters) are the information that must be provided when defining a Redis cluster.

|                    Name                    |        Attribute        |   Description   |         Example         |
| :-----------------------------------------: | :----------------: | :------: | :------------------: |
| [`redis_cluster`](v-redis.md#redis_cluster) | **MUST**, cluster level |  cluster name  |      `redis-test`       |
|    [`redis_node`](v-redis.md#redis_node)    | **MUST**，node level | Node Number | `1`,`2` |
|     [`redis_instances`](v-redis.md#redis_instances)     | **MUST**，node level | Instance Definition | `{ 6001 : {} ,6002 : {}}`  |


- [`redis_cluster`](v-redis.md#redis_cluster): Identifies the Redis cluster name, configured at the cluster level, as the top-level namespace for cluster sources.
- [`redis_node`](v-redis.md#redis_node): Identifies the number of the node in the cluster.
- [`redis_instances`](v-redis.md#redis_instances): A JSON object with the Key as the instance port and the Value as a JSON object containing the instance-specific configuration.

