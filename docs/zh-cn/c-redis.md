# Redis 概念

> 介绍 Redis 数据库集群管理所需的核心概念

[部署：Redis](d-redis.md) ｜[配置：Redis](v-redis.md)  | [剧本：Redis](p-redis.md)



### 实体概念模型

Redis的实体概念模型与[PostgreSQL](c-pgsql.md#实体模型)几乎相同，同样包括 **集群（Cluster）** 与 **实例（Instance）** 的概念。注意这里的Cluster概念指的不是 Redis原生集群方案中的集群。

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

