# Redis Deploy & Monitor

Pigsty is also a universal application runtime that could be used for deploying & monitoring other databases and applications, such as Redis.

It takes two steps to deploy a Redis cluster:


1. Declare it
2. Execute playbook



## Define Redis

* [Redis Config Entries](v-redis.md)



### E-R Model

The Redis entity conceptual model is almost identical to [PostgreSQL](c-entity.md), and also includes the concepts of **Cluster** and **Instance**. Note that the concept of Cluster here does not refer to the clusters in Redis' native clustering scheme.

The core difference is that Redis is typically deployed in a single multi-instance deployment, with **many** Redis instances typically deployed on a single physical/virtual machine node to take advantage of multi-core CPUs. therefore, how Redis instances are defined is slightly different from PGSQL.

In Pigsty-managed Redis, the nodes are fully subordinate to the cluster, i.e. it is not currently allowed to deploy two Redis instances from different clusters on a single node, but this does not prevent you from deploying multiple independent Redis instances on a single node.



### Redis Identity


The [**identity parameters**](v-redis.md#identity parameters) are the information that must be provided when defining a Redis cluster and include.

| name | attributes | description | example |
| :-----------------------------------------: | :----------------: | :------: | :------------------: |
| [`redis_cluster`](v-redis.md#redis_cluster) | **must**, cluster level | cluster-name | `redis-test` |
| [`redis_node`](v-redis.md#redis_node) | **must**, node level | node number | `1`,`2` |
| [`redis_instances`](v-redis.md#redis_instances) | **MUST**, node level | instance definition | `{ 6001 : {} ,6002 : {}}` |


- `redis_cluster` identifies the name of the Redis cluster, configured at the cluster level, and serves as the top-level namespace for cluster resources.
- `redis_node` identifies the serial number of the node in the cluster
- `redis_instances` is a JSON object with the Key as the instance port number and the Value as a JSON object containing the instance-specific configuration



### Redis Cluster Definition

Given below are three condensed definitions of Redis clusters, including.
* A 1-node, 3-instance Redis Sentinel cluster `redis-sentinel`
* A 2-node, 12-instance Redis Cluster `redis-cluster`
* A 1-node, one-master-two-slave Redis Standalone cluster `redis-standalone`

You need to assign a unique port number to the Redis instance on the node.

```yaml
#----------------------------------#
# sentinel example                 #
#----------------------------------#
redis-sentinel:
  hosts:
    10.10.10.10:
      redis_node: 1
      redis_instances:  { 6001 : {} ,6002 : {} , 6003 : {} }
  vars:
    redis_cluster: redis-sentinel
    redis_mode: sentinel
    redis_max_memory: 128MB

#----------------------------------#
# cluster example                  #
#----------------------------------#
redis-cluster:
  hosts:
    10.10.10.11:
      redis_node: 1
      redis_instances: { 6501 : {} ,6502 : {} ,6503 : {} ,6504 : {} ,6505 : {} ,6506 : {} }
    10.10.10.12:
      redis_node: 2
      redis_instances: { 6501 : {} ,6502 : {} ,6503 : {} ,6504 : {} ,6505 : {} ,6506 : {} }
  vars:
    redis_cluster: redis-cluster        # name of this redis 'cluster'
    redis_mode: cluster                 # standalone,cluster,sentinel
    redis_max_memory: 64MB              # max memory used by each redis instance
    redis_mem_policy: allkeys-lru       # memory eviction policy

#----------------------------------#
# standalone example               #
#----------------------------------#
redis-standalone:
  hosts:
    10.10.10.13:
      redis_node: 1
      redis_instances:
        6501: {}
        6502: { replica_of: '10.10.10.13 6501' }
        6503: { replica_of: '10.10.10.13 6501' }
  vars:
    redis_cluster: redis-standalone     # name of this redis 'cluster'
    redis_mode: standalone              # standalone,cluster,sentinel
    redis_max_memory: 64MB              # max memory used by each redis instance
```




## Create Cluster


### Deployment script

Create a Redis instance/cluster using the script `redis.yml`

```bash
. /redis.yml -l redis-sentinel
. /redis.yml -l redis-cluster
. /redis.yml -l redis-standalone
```


### Notes

Although this is not the recommended behavior, you can deploy PostgreSQL with Redis in a mixed deployment to make the most of machine resources.

The `redis.yml` script will deploy the Redis Monitor Exporter on the machine at the same time, including `redis_exporter` and `node_exporter` (optional)

During this process, the machine's `node_exporter` will be redeployed if it exists.

By default, Prometheus will use the "multi-target crawl" mode, using the Redis Exporter on port 9121 on the node to crawl **all** Redis instances on that node.



## Redis Monitoring

Pigsty currently provides 3 Redis monitoring panels as part of a standalone monitoring application `REDIS`, which are.

* Redis Overview: provides a global overview of Redis across the entire environment
* Redis Cluster: focuses on monitoring information for a single Redis business cluster
* Redis Instance: provides detailed monitoring information about a single Redis instance

You can use the included redis-benchmark test





## CAVEAT

Pigsty v1.3 only provides Redis cluster deployment and monitoring capabilities in a holistic manner.

Offline, scale-up, scale-down, and single-instance management features will be provided in subsequent versions gradually.