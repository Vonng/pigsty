# 配置：REDIS

> [配置](v-config.md) Redis数据库集群，控制[REDIS剧本](p-redis.md)行为，详情参考[Redis部署与监控教程](t-redis.md)

- [`REDIS_IDENTITY`](#REDIS_IDENTITY) : REDIS身份参数
- [`REDIS_NODE`](#REDIS_NODE) : REDIS节点准备
- [`REDIS_PROVISION`](#REDIS_PROVISION) : REDIS集群/实例置备


| ID  |                        Name                         |                Section                |    Type    | Level | Comment            |
|-----|-----------------------------------------------------|---------------------------------------|------------|-------|--------------------|
| 700 | [`redis_cluster`](#redis_cluster)                   | [`REDIS_IDENTITY`](#REDIS_IDENTITY)   | string     | C     | Redis数据库集群名称       |
| 701 | [`redis_node`](#redis_node)                         | [`REDIS_IDENTITY`](#REDIS_IDENTITY)   | int        | I     | Redis节点序列号         |
| 702 | [`redis_instances`](#redis_instances)               | [`REDIS_IDENTITY`](#REDIS_IDENTITY)   | instance[] | I     | Redis实例定义          |
| 723 | [`redis_fs_main`](#redis_fs_main)                   | [`REDIS_NODE`](#REDIS_NODE) | path       | C     | Redis主数据盘挂载点    |
| 741 | [`redis_exporter_enabled`](#redis_exporter_enabled) | [`REDIS_NODE`](#REDIS_NODE) | bool       | C     | 是否启用Redis Exporter |
| 742 | [`redis_exporter_port`](#redis_exporter_port)       | [`REDIS_NODE`](#REDIS_NODE) | int        | C     | Redis Exporter监听端口 |
| 743 | [`redis_exporter_options`](#redis_exporter_options) | [`REDIS_NODE`](#REDIS_NODE) | string     | C/I   | Redis Exporter命令参数 |
| 726 | [`redis_safeguard`](#redis_safeguard)       | [`REDIS_PROVISION`](#REDIS_PROVISION) | bool  | C     | 禁止抹除现存的Redis       |
| 725 | [`redis_clean`](#redis_clean)       | [`REDIS_PROVISION`](#REDIS_PROVISION) | bool    | C     | 初始化Redis是否抹除现存实例 |
| 726 | [`redis_rmdata`](#redis_rmdata)       | [`REDIS_PROVISION`](#REDIS_PROVISION) | bool  | C     | 清除Redis时是否抹除数据 |
| 721 | [`redis_mode`](#redis_mode)                         | [`REDIS_PROVISION`](#REDIS_PROVISION) | enum       | C     | Redis集群模式          |
| 722 | [`redis_conf`](#redis_conf)                         | [`REDIS_PROVISION`](#REDIS_PROVISION) | string     | C     | Redis配置文件模板        |
| 724 | [`redis_bind_address`](#redis_bind_address)         | [`REDIS_PROVISION`](#REDIS_PROVISION) | ip         | C     | Redis监听地址       |
| 727 | [`redis_max_memory`](#redis_max_memory)             | [`REDIS_PROVISION`](#REDIS_PROVISION) | size       | C/I   | Redis可用的最大内存       |
| 728 | [`redis_mem_policy`](#redis_mem_policy)             | [`REDIS_PROVISION`](#REDIS_PROVISION) | enum       | C     | 内存逐出策略             |
| 729 | [`redis_password`](#redis_password)                 | [`REDIS_PROVISION`](#REDIS_PROVISION) | string     | C     | Redis密码            |
| 730 | [`redis_rdb_save`](#redis_rdb_save)                 | [`REDIS_PROVISION`](#REDIS_PROVISION) | string[]   | C     | RDB保存指令            |
| 731 | [`redis_aof_enabled`](#redis_aof_enabled)           | [`REDIS_PROVISION`](#REDIS_PROVISION) | bool       | C     | 是否启用AOF            |
| 732 | [`redis_rename_commands`](#redis_rename_commands)   | [`REDIS_PROVISION`](#REDIS_PROVISION) | object     | C     | 重命名危险命令列表          |
| 740 | [`redis_cluster_replicas`](#redis_cluster_replicas) | [`REDIS_PROVISION`](#REDIS_PROVISION) | int        | C     | 集群每个主库带几个从库        |


----------------
## `REDIS_IDENTITY`

**身份参数**是定义Redis集群时必须提供的信息，包括：

|                  名称                   |        属性        |   说明   |         例子         |
|:-------------------------------------:| :----------------: | :------: | :------------------: |
|   [`redis_cluster`](#redis_cluster)   | **必选**，集群级别 |  集群名  |      `redis-test`       |
|      [`redis_node`](#redis_node)      | **必选**，节点级别 | 节点编号 | `primary`, `replica` |
| [`redis_instances`](#redis_instances) | **必选**，节点级别 | 实例定义 | `{ 6001 : {} ,6002 : {}}`  |


- [`redis_cluster`](#redis_cluster) 标识了Redis集群的名称，在集群层面进行配置，作为集群资源的顶层命名空间。
- [`redis_node`](#redis_node) 标识了节点在集群中的序号
- [`redis_instances`](#redis_instances) 是一个JSON对象，Key为实例端口号，Value为一个JSON对象，包含实例特殊的配置



### `redis_cluster`

Redis数据库集群名称, 类型：`string`，层级：C，默认值为：

REDIS数据库集群名称将用作集群内资源的命名空间，需要遵循特定命名规则：`[a-z][a-z0-9-]*`，以兼容不同约束对身份标识的要求。建议使用`redis-`作为集群名前缀。

**身份参数，必填参数，集群级参数**




### `redis_node`

Redis节点序列号, 类型：`int`，层级：I，默认值为：

数据库节点的序号，在**集群内部唯一**，用于区别与标识集群内的不同节点，从0或1开始分配。



### `redis_instances`

Redis实例定义, 类型：`instance[]`，层级：I，默认值为：

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









----------------

## `REDIS_NODE`



### `redis_fs_main`

Redis使用的主数据盘挂载点, 类型：`path`，层级：C，默认值为：`"/data"`

Redis使用的主数据盘挂载点，默认为`/data`。

Pigsty会在该目录下创建`redis`目录，用于存放Redis数据。例如`/data/redis`。

详情请参考 [FHS：Redis](r-fhs.md)



### `redis_exporter_enabled`

是否启用Redis监控, 类型：`bool`，层级：C，默认值为：`true`

Redis Exporter默认启用，在每个Redis节点上部署一个，默认监听9121端口。



### `redis_exporter_port`

Redis Exporter监听端口, 类型：`int`，层级：C，默认值为：`9121`

注：如果您修改了该默认端口，则需要在Prometheus的相关配置规则文件中一并替换此端口。



### `redis_exporter_options`

Redis Exporter命令参数, 类型：`string`，层级：C/I，默认值为：`""`







----------------
## `REDIS_PROVISION`



### `redis_safeguard`

安全保险，禁止清除存在的Redis实例, 类型：`bool`，层级：C/A，默认值为：`false`

如果为`true`，任何情况下，Pigsty剧本都不会移除运行中的PostgreSQL实例，包括 [`redis-remove.yml`](p-redis#pgsql-remove)。

详情请参考 [保护机制](p-redis.md#保护机制)。



### `redis_clean`

是否抹除运行中的Redis实例？类型：`bool`，层级：C/A，默认值为：`false`。

针对 [`redis.yml`](p-redis.md#redis) 剧本的抹除豁免，如果指定该参数为真，那么在 [`redis.yml`](p-redis.md#redis) 剧本执行时，会自动抹除已有的Redis实例

这是一个危险的操作，因此必须显式指定。

当安全保险参数 [`redis_safeguard`](#redis_safeguard) 打开时，本参数无效。



### `redis_rmdata`

移除Redis实例时是否一并移除数据目录？, 类型：`enum`，层级：A，默认值为：`true`

如果不移除， 之前实例残留的RDB/AOF文件会被自动加载使用。




### `redis_mode`

Redis集群模式, 类型：`enum`，层级：C，默认值为：`"standalone"`

指明该Redis集群的模式，有三种可选模式：

* `standalone`：默认模式，部署一系列独立的Redis实例，（可以构建普通主从）
* `cluster`： Redis原生集群模式
* `sentinel`：Redis高可用组件：哨兵

当使用`standalone`模式时，Pigsty会根据 `replica_of` 参数额外设置Redis主从。
当使用`cluster`模式时，Pigsty会根据 [`redis_cluster_replicas`](#redis_cluster_replicas) 参数使用所有定义的实例创建原生Redis集群。




### `redis_conf`

Redis配置文件模板, 类型：`string`，层级：C，默认值为：`"redis.conf"`






### `redis_bind_address`

Redis监听地址, 类型：`ip`，层级：C，默认值为：`"0.0.0.0"`

Redis监听的IP地址，如果留空则为 `inventory_hostname`。默认监听有本地所有IPv4地址



### `redis_max_memory`

Redis可用的最大内存, 类型：`size`，层级：C/I，默认值为：`"1GB"`

每个Redis实例使用的最大内存限制，默认为1GB，建议在集群层面配置此参数，保持集群实例配置一致。



### `redis_mem_policy`

内存逐出策略, 类型：`enum`，层级：C，默认值为：`"allkeys-lru"`

其他可选策略包括：

* `volatile-lru`
* `allkeys-lru`
* `volatile-lfu`
* `allkeys-lfu`
* `volatile-random`
* `allkeys-random`
* `volatile-ttl`
* `noeviction`



### `redis_password`

Redis密码, 类型：`string`，层级：C，默认值为：`""`

`masterauth` & `requirepass` 使用的密码，留空则禁用密码，默认禁用

!> 注意安全，请不要将无密码保护的Redis放置于公网上



### `redis_rdb_save`

RDB保存指令, 类型：`string[]`，层级：C，默认值为： `[ "1200 1" ]`

Redis SAVE命令，配置将启用RDB功能，每一条Save策略作为一个字符串。



### `redis_aof_enabled`

是否启用AOF, 类型：`bool`，层级：C，默认值为：`false`





### `redis_rename_commands`

重命名危险命令列表, 类型：`object`，层级：C，默认值为：`{}`

JSON字典，将Key表示的命令重命名为Value表示的命令，避免误操作危险命令。






### `redis_cluster_replicas`

集群每个主库带几个从库, 类型：`int`，层级：C，默认值为：`1`

在Redis原生集群模式中，为每一个主库配置多少个从库？默认为1个。

```bash
/bin/redis-cli --cluster create --cluster-yes \
  --cluster-replicas {{ redis_cluster_replicas|default(1) }}
```




