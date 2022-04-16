# 部署与监控Redis

Pigsty是一个PostgreSQL发行版，也是一个通用应用运行时。您可以用它管理、部署、监控其他应用与数据库，例如Redis。

与PostgreSQL类似，部署Redis同样需要两个步骤：

1. 声明/定义Redis集群
2. 执行Playbook创建Redis集群



## 定义Redis集群

[redis配置参数](v-redis.md)


### Redis实体概念模型

Redis的实体概念模型与[PostgreSQL](c-entity.md)几乎相同，同样包括 **集群（Cluster）** 与 **实例（Instance）** 的概念。注意这里的Cluster概念指的不是 Redis原生集群方案中的集群。

核心的区别在于，Redis通常采用单机多实例部署，一个物理/虚拟机节点上通常会部署**多个** Redis实例，以充分利用多核CPU。因此，定义Redis实例的方式与PGSQL稍有不同。

在Pigsty管理的Redis中，节点完全隶属于集群，即目前尚不允许在一个节点上部署两个不同集群的Redis实例，但这并不影响您在在一个节点上部署多个独立Redis实例。


### Redis身份参数

[**身份参数**](v-redis.md#身份参数)是定义Redis集群时必须提供的信息，包括：

|                    名称                     |        属性        |   说明   |         例子         |
| :-----------------------------------------: | :----------------: | :------: | :------------------: |
| [`redis_cluster`](v-redis.md#redis_cluster) | **必选**，集群级别 |  集群名  |      `redis-test`       |
|    [`redis_node`](v-redis.md#redis_node)    | **必选**，节点级别 | 节点编号 | `1`,`2` |
|     [`redis_instances`](v-redis.md#redis_instances)     | **必选**，节点级别 | 实例定义 | `{ 6001 : {} ,6002 : {}}`  |


- [`redis_cluster`](v-redis.md#redis_cluster) 标识了Redis集群的名称，在集群层面进行配置，作为集群资源的顶层命名空间。
- [`redis_node`](v-redis.md#redis_node) 标识了节点在集群中的序号
- [`redis_instances`](v-redis.md#redis_instances) 是一个JSON对象，Key为实例端口号，Value为一个JSON对象，包含实例特殊的配置



### Redis集群定义

下面给出了三个Redis集群的精简定义，包括：
* 一个1节点，3实例的Redis Sentinel集群 `redis-sentinel`
* 一个2节点，12实例的的Redis Cluster集群 `redis-cluster`
* 一个1节点，一主两从的Redis Standalone集群 `redis-standalone`

您需要在节点上为Redis实例分配唯一的端口号。

### Redis Sentinel集群定义

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

### Redis原生集群定义

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

### Redis普通主从实例定义

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


## 创建Redis集群


### 部署剧本

使用剧本`redis.yml`创建Redis实例/集群

```bash
./redis.yml -l redis-sentinel
./redis.yml -l redis-cluster
./redis.yml -l redis-standalone
```


### 其他注意事项

尽管这样做并不是推荐的行为，您可以将PostgreSQL与Redis进行混合部署，以充分利用机器资源。

`redis.yml` 剧本会在机器上同时部署Redis监控Exporter，包括`redis_exporter`与`node_exporter`（可选）

在此过程中，如果机器的`node_exporter`存在，将会被重新部署。

Prometheus默认会使用"多目标抓取"模式，使用节点上9121端口的Redis Exporter抓取该节点上**所有**的Redis实例。



## 查阅Redis监控

目前Pigsty提供了3个Redis监控面板，作为一个独立监控应用 `REDIS`的组成部分，分别为：

* Redis Overview：提供整个环境中Redis的全局概览
* Redis Cluster： 关注单个Redis业务集群的监控信息
* Redis Instance：关注单个Redis实例的详细监控信息

您可以使用自带的 redis-benchmark 测试





## 其他功能

Pigsty v1.4 只提供Redis集群整体性部署与监控功能。扩容、缩容，单实例管理等功能将在后续版本中逐步提供。

