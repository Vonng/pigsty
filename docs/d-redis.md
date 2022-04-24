# Redis Deployment

Pigsty is a PostgreSQL distribution and a general-purpose application runtime. You can use it to manage, deploy, and monitor other applications and databases, such as Redis.

Similar to PostgreSQL, deploying Redis requires the same two steps.

1. declare/define the Redis cluster
2. Execute Playbook to create the Redis cluster



## Define Redis Cluster


### ER Model

The Redis ER model is almost identical to [PostgreSQL](c-pgsql.md#ER-Model), and also includes the concepts of **Cluster** and **Instance**. Note that the concept of Cluster here does not refer to the clusters in Redis' native clustering scheme.

The core difference is that Redis is typically deployed in a single multi-instance deployment, with **many** Redis instances typically deployed on a single physical/virtual machine node to take advantage of multi-core CPUs. Therefore, how Redis instances are defined is slightly different from PGSQL.

In Pigsty-managed Redis, the nodes are fully subordinate to the cluster, i.e. it is not currently allowed to deploy two Redis instances from different clusters on a single node, but this does not prevent you from deploying multiple independent Redis instances on a single node.


### Identity Parameters

The [**identity parameters**](d-redis.md#identity-parameters) are the information that must be provided when defining a Redis cluster and include.

|                    Name                    |        Properties        |   Description   |         Example         |
| :-----------------------------------------: | :----------------: | :------: | :------------------: |
| [`redis_cluster`](v-redis.md#redis_cluster) | **MUST**, cluster level |  Cluster name  |      `redis-test`       |
|    [`redis_node`](v-redis.md#redis_node)    | **MUST**, node level | Node Number | `1`,`2` |
|     [`redis_instances`](v-redis.md#redis_instances)     | **MUST**, node level | Instance Definition | `{ 6001 : {} ,6002 : {}}`  |


- [`redis_cluster`](v-redis.md#redis_cluster) identifies the name of the Redis cluster, which is configured at the cluster level and serves as the top-level namespace for cluster resources.

- [`redis_node`](v-redis.md#redis_node) identifies the serial number of the node in the cluster.

- [`redis_instances`](v-redis.md#redis_instances) is a JSON object with the Key as the instance port number and the Value as a JSON object containing the instance-specific config.

  

### Cluster Definition

A condensed definition of three Redis clusters is given below, including.

* A 1-node, 3-instance Redis Sentinel cluster `redis-sentinel`
* A 2-node, 12-instance Redis Cluster `redis-cluster`.
* A 1-node, one-master-two-slave Redis Standalone cluster `redis-standalone`


You need to assign a unique port number to the Redis instance on the node.

### Redis Sentinel Cluster Example



### Redis Sentinel Example


```yaml
#----------------------------------#
# redis sentinel example           #
#----------------------------------#
redis-meta:
  hosts:
    10.10.10.10:
      redis_node: 1
      redis_instances:  { 6001 : {} ,6002 : {} , 6003 : {} }
  vars:
    redis_cluster: redis-meta
    redis_mode: sentinel
    redis_max_memory: 128MB
```



### Redis Native Cluster Example

```yaml
#----------------------------------#
# redis cluster example            #
#----------------------------------#
redis-test:
  hosts:
    10.10.10.11:
      redis_node: 1
      redis_instances: { 6501 : {} ,6502 : {} ,6503 : {} ,6504 : {} ,6505 : {} ,6506 : {} }
    10.10.10.12:
      redis_node: 2
      redis_instances: { 6501 : {} ,6502 : {} ,6503 : {} ,6504 : {} ,6505 : {} ,6506 : {} }
  vars:
    redis_cluster: redis-test           # name of this redis 'cluster'
    redis_mode: cluster                 # standalone,cluster,sentinel
    redis_max_memory: 64MB              # max memory used by each redis instance
    redis_mem_policy: allkeys-lru       # memory eviction policy
```



### Redis Standalone Example

```yaml
#----------------------------------#
# redis standalone example         #
#----------------------------------#
redis-common:
  hosts:
    10.10.10.13:
      redis_node: 1
      redis_instances:
        6501: {}
        6502: { replica_of: '10.10.10.13 6501' }
        6503: { replica_of: '10.10.10.13 6501' }
  vars:
    redis_cluster: redis-common         # name of this redis 'cluster'
    redis_mode: standalone              # standalone,cluster,sentinel
    redis_max_memory: 64MB              # max memory used by each redis instance
```



## Create Cluster


### Playbook

Create a Redis instance/cluster using the playbook `redis.yml`.

```bash
./redis.yml -l redis-sentinel
./redis.yml -l redis-cluster
./redis.yml -l redis-standalone
```



### Caveat

Although this is not the recommended behavior, you can deploy PostgreSQL with Redis in a mixed deployment to make the best use of machine resources.

The `redis.yml` playbook will deploy the Redis Monitor Exporter on the machine at the same time, including `redis_exporter` and `node_exporter` (optional).

During this process, if the machine's `node_exporter` exists, it will be redeployed.

By default, Prometheus will use the "multi-target crawl" mode, using the Redis Exporter on port 9121 on the node to crawl **all** Redis instances on that node.



## Checking Redis Monitor

Pigsty currently provides three Redis monitor panels as part of a standalone monitoring application `REDIS`, namely:

* Redis Overview: Provides a global overview of Redis in the entire environment.
* Redis Cluster: focuses on monitoring information for a single Redis business cluster.
* Redis Instance: provides detailed monitoring information about a single Redis instance.


You can use the included redis-benchmark test.


## Other Functions

Pigsty v1.4 only provides Redis cluster deployment and monitoring capabilities in a holistic manner. Features such as capacity expansion, capacity reduction, and single-instance management will be provided in subsequent versions.

