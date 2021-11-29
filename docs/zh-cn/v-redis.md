# Redis

Redis的配置参数并为列入 pigsty.yml 主配置文件中，但您可以按需加入，或直接在Redis集群层面配置。

详情请参考：[Redis部署与监控教程](t-redis.md)






## 参数概览

|                      名称                       |    类型    | 层级  | 说明                                             |
| :---------------------------------------------: | :--------: | :---: | ------------------------------------------------ |
| [redis_cluster](#redis_cluster)                         |  `string`    | **C** |    name of this redis 'cluster' , cluster level                                                |
| [redis_node](#redis_node)                               |  `number`    | **I** |    id of this redis node, integer sequence @ instance level                                    |
| [redis_instances](#redis_instances)                     |  `object`    | **I** |    redis instance list on this redis node @ instance level                                     |
| [redis_mode](#redis_mode)                               |  `string`    |  C    |    standalone,cluster,sentinel                                                                 |
| [redis_conf](#redis_conf)                               |  `string`    |  G    |    which config template will be used                                                          |
| [redis_fs_main](#redis_fs_main)                         |  `string`    | G/C/I |    main data disk for redis                                                                    |
| [redis_bind_address](#redis_bind_address)               |  `string`    | G/C/I |    e.g 0.0.0.0, empty will use inventory_hostname as bind address                              |
| [redis_exists](#redis_exists)                           |  `string`    |  C    |    internal flag                                                                               |
| [redis_exists_action](#redis_exists_action)             |  `string`    | G/C   |    abort|skip|clean if dcs server already exists                                               |
| [redis_disable_purge](#redis_disable_purge)             |  `string`    | G/C   |    set to true to disable purge functionality for good (force redis_exists_action = abort)     |
| [redis_max_memory](#redis_max_memory)                   |  `string`    | G/C    |    max memory used by each redis instance                                                      |
| [redis_mem_policy](#redis_mem_policy)                   |  `string`    | G/C    |    memory eviction policy                                                                      |
| [redis_password](#redis_password)                       |  `string`    | G/C    |    empty password disable password auth (masterauth & requirepass)                             |
| [redis_rdb_save](#redis_rdb_save)                       |  `string`    | G/C    |    redis RDB save directives, empty list disable it                                            |
| [redis_aof_enabled](#redis_aof_enabled)                 |  `string`    | G/C    |    enable redis AOF                                                                            |
| [redis_rename_commands](#redis_rename_commands)         |  `string`    | G/C    |    rename dangerous commands                                                                   |
| [redis_cluster_replicas](#redis_cluster_replicas)       |  `string`    | G/C    |    how much replicas per master in redis cluster ?                                             |
| [redis_exporter_enabled](#redis_exporter_enabled)       |  `string`    | G/C    |    install redis exporter on redis nodes                                                       |
| [redis_exporter_port](#redis_exporter_port)             |  `string`    | G/C    |    default port for redis exporter                                                             |
| [redis_exporter_options](#redis_exporter_options)       |  `string`    | G/C    |    default cli args for redis exporter                                                         |


## 默认参数

```yaml
---
# - identity - #
# redis_cluster: redis-test         # name of this redis cluster @ cluster level
# redis_node: 1                     # redis node identifier, integer sequence @ node level
# redis_instances: {}               # redis instances definition of this redis node @ node level

# - mode - #
redis_mode: standalone              # standalone,cluster,sentinel
redis_conf: redis.conf              # config template path (except sentinel)
redis_fs_main: /data                # main fs mountpoint for redis data
redis_bind_address: '0.0.0.0'       # bind address, empty string turns to inventory_hostname

# - cleanup - #
redis_exists: false                 # internal flag to indicate redis exists
redis_exists_action: clean          # abort|skip|clean if redis server already exists
redis_disable_purge: false          # force redis_exists_action = abort if true

# - conf - #
redis_max_memory: 1GB               # max memory used by each redis instance
redis_mem_policy: allkeys-lru       # memory eviction policy
redis_password: ''                  # masterauth & requirepass password, disable by empty string
redis_rdb_save: ['1200 1']          # redis rdb save directives, disable with empty list
redis_aof_enabled: false            # redis aof enabled
redis_rename_commands: {}           # rename dangerous commands
#   flushall: opflushall
#   flushdb: opflushdb
#   keys: opkeys
redis_cluster_replicas: 1           # how many replicas for a master in redis cluster ?

# - redis exporter - #
redis_exporter_enabled: true        # install redis exporter on redis nodes ?
redis_exporter_port: 9121           # default port for redis exporter
redis_exporter_options: ''          # default cli args for redis exporter

# - node exporter - #
node_exporter_enabled: true         # setup node_exporter on instance
node_exporter_port: 9100            # default port for node exporter
node_exporter_options: '--no-collector.softnet --collector.systemd --collector.ntp --collector.tcpstat --collector.processes'

# - reference - #
redis_install: yum                  # none|yum|binary, yum by default (install from yum repo)
exporter_install: none              # none|yum|binary, none by default (usually installed during node init)
exporter_repo_url: ''               # if set, repo will be added to /etc/yum.repos.d/ before yum installation
exporter_metrics_path: /metrics     # default metric path for pg related exporter
service_registry: consul
...
```



## 身份参数


**身份参数**是定义Redis集群时必须提供的信息，包括：

|                    名称                     |        属性        |   说明   |         例子         |
| :-----------------------------------------: | :----------------: | :------: | :------------------: |
| [`redis_cluster`](redis_cluster) | **必选**，集群级别 |  集群名  |      `redis-test`       |
|    [`redis_node`](redis_node)    | **必选**，节点级别 | 节点编号 | `primary`, `replica` |
|     [`redis_instances`](redis_instances)     | **必选**，节点级别 | 实例定义 | `{ 6001 : {} ,6002 : {}}`  |


- `redis_cluster` 标识了Redis集群的名称，在集群层面进行配置，作为集群资源的顶层命名空间。
- `redis_node` 标识了节点在集群中的序号
- `redis_instances` 是一个JSON对象，Key为实例端口号，Value为一个JSON对象，包含实例特殊的配置

```yaml
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
```





## 参数详解

### redis_cluster

REDIS数据库集群的名称，将用作集群内资源的命名空间。

集群命名需要遵循特定命名规则：`[a-z][a-z0-9-]*`，以兼容不同约束对身份标识的要求。建议使用`redis-`作为集群名前缀。

**身份参数，必填参数，集群级参数**



### redis_node

数据库节点的序号，在**集群内部唯一**，用于区别与标识集群内的不同节点，从0或1开始分配。

**身份参数，必填参数，节点级参数**



### redis_instances

部署在该数据库节点上的所有Redis实例，JSON KV对象格式。Key为数值类型端口号，Value为该实例特定的JSON配置项。

样例：

```yaml
redis_instances: { 6501 : {} ,6502 : {} ,6503 : {} ,6504 : {} ,6505 : {} ,6506 : {} }
redis_instances:
    6501: {}
    6502: { replica_of: '10.10.10.13 6501' }
    6503: { replica_of: '10.10.10.13 6501' }
```

每一个Redis实例在对应节点上监听一个唯一端口，您可以为Redis实例配置独立的参数选项（目前只支持 `replica_of`，用于预构建主从复制）



**身份参数，必填参数，实例级参数**




### redis_mode

指明该Redis集群的模式，有三种可选模式：

* `standalone`：默认模式，部署一系列独立的Redis实例，（可以构建普通主从）
* `cluster`： Redis原生集群模式
* `sentinel`：Redis高可用组件：哨兵

当使用`standalone`模式时，Pigsty会根据`replica_of`参数额外设置Redis主从。
当使用`cluster`模式时，Pigsty会根据 [`redis_cluster_replicas`](#redis_cluster_replicas) 参数使用所有定义的实例创建原生Redis集群。



### redis_conf

Redis配置文件模板，`redis.conf`是默认使用的配置模板。

当创建`sentinel`模式的实例时，Pigsty会使用专用的`redis-sentinel.conf` 配置模板，此参数无效。



### redis_fs_main

Redis使用的主数据盘挂载点，默认为`/data`。

Pigsty会在该目录下创建`redis`目录，用于存放Redis数据。例如`/data/redis`。

详情请参考 [FHS：Redis](r-fhs.md)



### redis_bind_address

Redis监听的IP地址，如果留空则为 inventory_hostname。

默认配置为`0.0.0.0`，即所有本地IPv4地址



### redis_exists

内部使用的标记位，判断Redis实例是否存在，请勿修改。



### redis_exists_action

如果Redis实例已经存在，如何处理：



* `abort`:  中止整个剧本的执行
* `skip`:  继续执行，因此Redis实例可能会使用现有数据库中的RDB文件启动。
* `clean`: 抹除数据，清洁启动。




### redis_disable_purge

如果启用，强制设置 `redis_exists_action = abort` 



### redis_max_memory

每个Redis实例使用的最大内存限制，默认为64MB，建议在集群层面配置此参数。




### redis_mem_policy

内存淘汰策略，默认为 `allkeys-lru` ，其他可选策略包括：

* volatile-lru
* allkeys-lru
* volatile-lfu
* allkeys-lfu
* volatile-random
* allkeys-random
* volatile-ttl
* noeviction



### redis_password

masterauth & requirepass 使用的密码，留空则禁用密码，默认禁用

!> 注意安全，请不要将无密码保护的Redis放置于公网上



### redis_rdb_save

Redis SAVE命令，配置将启用RDB功能。

每一条Save策略作为一个字符串。




### redis_aof_enabled

是否启用redis AOF？



### redis_rename_commands

JSON字典，将Key表示的命令重命名为Value表示的命令。

避免误操作危险命令。



### redis_cluster_replicas

在Redis原生集群模式中，为每一个主库配置多少个从库？默认为1个。

```bash
/bin/redis-cli --cluster create --cluster-yes \
  --cluster-replicas {{ redis_cluster_replicas|default(1) }}
```






### redis_exporter_enabled

是否启用Redis Exporter？

Redis Exporter默认启用，在每个Redis节点上部署一个，默认监听9121端口。




### redis_exporter_port

Redis Exporter 使用的默认端口，9121 为默认端口。

注：如果您修改了该默认端口，则需要在Prometheus的相关配置规则文件中一并替换此端口。




### redis_exporter_options

Redis Exporter默认使用的命令行参数选项。





