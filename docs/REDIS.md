# Concept: Redis

> This article introduces the core concepts required for Redis cluster management.

[Deploy: Redis](d-redis.md) ｜[Config: Redis](v-redis.md)  | [Playbook: Redis](p-redis.md)



### ER Model

The Redis entity concept model is almost identical to [PostgreSQL](c-pgsql.md) and includes the **Cluster** and **Instance**. Note that Cluster here does not refer to the clusters in Redis' native clusters.

The core difference is that Redis typically uses multiple singleton instances, with **multiple** Redis instances typically deployed on a single physical/VM to take advantage of multi-core CPUs.

In Pigsty-managed Redis, it is not yet possible to deploy two Redis instances from different clusters on a node, but this does not affect the deployment of multiple independent Redis instances on a node.


### Redis Identity

The [**identity parameters**](v-redis.md#redis_identity) are the information that must be provided when defining a Redis cluster.

|                    Name                    |        Attribute        |   Description   |         Example         |
| :-----------------------------------------: | :----------------: | :------: | :------------------: |
| [`redis_cluster`](v-redis.md#redis_cluster) | **MUST**, cluster level |  cluster name  |      `redis-test`       |
|    [`redis_node`](v-redis.md#redis_node)    | **MUST**，node level | Node Number | `1`,`2` |
|     [`redis_instances`](v-redis.md#redis_instances)     | **MUST**，node level | Instance Definition | `{ 6001 : {} ,6002 : {}}`  |


- [`redis_cluster`](v-redis.md#redis_cluster): Identifies the Redis cluster name, configured at the cluster level, as the top-level namespace for cluster sources.
- [`redis_node`](v-redis.md#redis_node): Identifies the number of the node in the cluster.
- [`redis_instances`](v-redis.md#redis_instances): A JSON object with the Key as the instance port and the Value as a JSON object containing the instance-specific configuration.




## Parameters


There are 3 sections, 20 parameters about [`REDIS`](PARAM#REDIS) module.

- [`REDIS_ID`](PARAM#redis_id) : REDIS Identity Parameters
- [`REDIS_NODE`](PARAM#redis_node) : REDIS Node & Exporter
- [`REDIS_PROVISION`](PARAM#redis_provision) : Config & Launch Redis Instances


| Parameter                                                    |    Type     | Level | Comment                                                      |
| ------------------------------------------------------------ | :---------: | :---: | ------------------------------------------------------------ |
| [`redis_cluster`](PARAM#redis_cluster)                       |   string    |   C   | redis cluster name, required identity parameter              |
| [`redis_instances`](PARAM#redis_instances)                   |    dict     |   I   | redis instances definition on this redis node                |
| [`redis_node`](PARAM#redis_node)                             |     int     |   I   | redis node sequence number, node int id required             |
| [`redis_fs_main`](PARAM#redis_fs_main)                       |    path     |   C   | redis main data mountpoint, `/data` by default               |
| [`redis_exporter_enabled`](PARAM#redis_exporter_enabled)     |    bool     |   C   | install redis exporter on redis nodes?                       |
| [`redis_exporter_port`](PARAM#redis_exporter_port)           |    port     |   C   | redis exporter listen port, 9121 by default                  |
| [`redis_exporter_options`](PARAM#redis_exporter_options)     |   string    |  C/I  | cli args and extra options for redis exporter                |
| [`redis_safeguard`](PARAM#redis_safeguard)                   |    bool     |   C   | prevent purging running redis instance?                      |
| [`redis_clean`](PARAM#redis_clean)                           |    bool     |   C   | purging existing redis during init?                          |
| [`redis_rmdata`](PARAM#redis_rmdata)                         |    bool     |   A   | remove redis data when purging redis server?                 |
| [`redis_mode`](PARAM#redis_mode)                             |    enum     |   C   | redis mode: standalone,cluster,sentinel                      |
| [`redis_conf`](PARAM#redis_conf)                             |   string    |   C   | redis config template path, except sentinel                  |
| [`redis_bind_address`](PARAM#redis_bind_address)             |     ip      |   C   | redis bind address, empty string will use host ip            |
| [`redis_max_memory`](PARAM#redis_max_memory)                 |    size     |  C/I  | max memory used by each redis instance                       |
| [`redis_mem_policy`](PARAM#redis_mem_policy)                 |    enum     |   C   | redis memory eviction policy                                 |
| [`redis_password`](PARAM#redis_password)                     |  password   |   C   | redis password, empty string will disable password           |
| [`redis_rdb_save`](PARAM#redis_rdb_save)                     |  string[]   |   C   | redis rdb save directives, disable with empty list           |
| [`redis_aof_enabled`](PARAM#redis_aof_enabled)               |    bool     |   C   | enable redis append only file?                               |
| [`redis_rename_commands`](PARAM#redis_rename_commands)       |    dict     |   C   | rename redis dangerous commands                              |
| [`redis_cluster_replicas`](PARAM#redis_cluster_replicas)     |     int     |   C   | replica number for one master in redis cluster               |