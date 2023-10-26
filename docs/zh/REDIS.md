# REDIS

> Redis是广受喜爱的开源高性能内存数据结构服务器，PostgreSQL的好伙伴。 [配置](#配置) | [剧本](#剧本) | [管理](#管理) | [监控](#监控) | [参数](#参数)


----------------

## 概念

Redis的实体概念模型与[PostgreSQL](PGSQL-ARCH#实体概念图)几乎相同，同样包括 **集群（Cluster）** 与 **实例（Instance）** 的概念。注意这里的Cluster指的不是Redis原生集群方案中的集群。

REDIS模块与PGSQL模块核心的区别在于，Redis通常采用 **单机多实例** 部署，而不是 PostgreSQL 的 1:1 部署：一个物理/虚拟机节点上通常会部署 **多个** Redis实例，以充分利用多核CPU。因此[配置](#配置)和[管理](#管理)Redis实例的方式与PGSQL稍有不同。

在Pigsty管理的Redis中，节点完全隶属于集群，即目前尚不允许在一个节点上部署两个不同集群的Redis实例，但这并不影响您在在一个节点上部署多个独立 Redis 主从实例。当然这样也会有一些局限性，例如在这种情况下您就无法为同一个节点上的不同实例指定不同的密码了。



----------------

## 配置

**身份参数**

Redis [**身份参数**](PARAM#redis_id) 是定义Redis集群时必须提供的信息，包括：

|                     名称                     |     属性      |  说明  |            例子             |
|:------------------------------------------:|:-----------:|:----:|:-------------------------:|
|   [`redis_cluster`](PARAM#redis_cluster)   | **必选**，集群级别 | 集群名  |       `redis-test`        |
|      [`redis_node`](PARAM#redis_node)      | **必选**，节点级别 | 节点号  |          `1`,`2`          |
| [`redis_instances`](PARAM#redis_instances) | **必选**，节点级别 | 实例定义 | `{ 6001 : {} ,6002 : {}}` |

- [`redis_cluster`](PARAM#redis_cluster)：Redis集群名称，作为集群资源的顶层命名空间。
- [`redis_node`](PARAM#redis_node)：Redis节点标号，整数，在集群内唯一，用于区分不同节点。
- [`redis_instances`](PARAM#redis_instances)：JSON对象，Key为实例端口号，Value为包含实例其他配置JSON对象。

**工作模式**

Redis有三种不同的工作模式，由 [`redis_mode`](PARAM#redis_mode) 参数指定：

* `standalone`：默认的独立主从模式
* `cluster`：Redis原生分布式集群模式
* `sentinel`：哨兵模式，可以为主从模式的 Redis 提供高可用能力

下面给出了三种Redis集群的定义样例：

* 一个1节点，一主一从的 Redis Standalone 集群：`redis-ms`
* 一个1节点，3实例的Redis Sentinel集群：`redis-sentinel`
* 一个2节点，6实例的的 Redis Cluster集群： `redis-cluster`

```yaml
redis-ms: # redis 经典主从集群
  hosts: { 10.10.10.10: { redis_node: 1 , redis_instances: { 6379: { }, 6380: { replica_of: '10.10.10.10 6379' } } } }
  vars: { redis_cluster: redis-ms ,redis_password: 'redis.ms' ,redis_max_memory: 64MB }

redis-meta: # redis 哨兵 x 3
  hosts: { 10.10.10.11: { redis_node: 1 , redis_instances: { 26379: { } ,26380: { } ,26381: { } } } }
  vars:
    redis_cluster: redis-meta
    redis_password: 'redis.meta'
    redis_mode: sentinel
    redis_max_memory: 16MB
    redis_sentinel_monitor: # primary list for redis sentinel, use cls as name, primary ip:port
      - { name: redis-ms, host: 10.10.10.10, port: 6379 ,password: redis.ms, quorum: 2 }

redis-test: # redis 原生集群： 3主 x 3从
  hosts:
    10.10.10.12: { redis_node: 1 ,redis_instances: { 6379: { } ,6380: { } ,6381: { } } }
    10.10.10.13: { redis_node: 2 ,redis_instances: { 6379: { } ,6380: { } ,6381: { } } }
  vars: { redis_cluster: redis-test ,redis_password: 'redis.test' ,redis_mode: cluster, redis_max_memory: 32MB }
```

**局限性**

* 一个节点只能属于一个 Redis 集群，这意味着您不能将一个节点同时分配给两个不同的Redis集群。
* 在每个 Redis 节点上，您需要为 Redis实例 分配唯一的端口号，避免端口冲突。
* 通常同一个 Reids 集群会使用同一个密码，但一个 Redis节点上的多个 Redis 实例无法设置不同的密码（因为 redis_exporter 只允许使用一个密码0
* Redis Cluster自带高可用，而Redis主从的高可用需要在 Sentinel 中额外进行手工配置：因为我们不知道您是否会部署 Sentinel。
* 好在配置 Redis 主从实例的高可用非常简单，可以通过Sentinel进行配置，详情请参考[管理-设置Redis主从高可用](#管理)


-------------

## 管理

下面是 REDIS 模块常用的管理任务，更多问题请参考 [FAQ：REDIS](FAQ#REDIS)


-------------

### 初始化Redis

您可以使用 [`redis.yml`](#redisyml) 剧本来初始化 Redis 集群、节点、或实例：

```bash
# 初始化集群内所有 Redis 实例
./redis.yml -l <cluster>      # 初始化 redis 集群

# 初始化特定节点上的所有 Redis 实例
./redis.yml -l 10.10.10.10    # 初始化 redis 节点

# 初始化特定 Redis 实例：  10.10.10.11:6379
./redis.yml -l 10.10.10.11 -e redis_port=6379 -t redis
```

你也可以使用包装脚本命令行脚本来初始化：

```bash
bin/redis-add redis-ms          # 初始化 redis 集群 'redis-ms'
bin/redis-add 10.10.10.10       # 初始化 redis 节点 '10.10.10.10'
bin/redis-add 10.10.10.10 6379  # 初始化 redis 实例 '10.10.10.10:6379'
```

-------------

### 下线Redis

您可以使用 [`redis-rm.yml`](#redis-rmyml) 剧本来初始化 Redis 集群、节点、或实例：

```bash
# 下线 Redis 集群 `redis-test`
./redis-rm.yml -l redis-test

# 下线 Redis 集群 `redis-test` 并卸载 Redis 软件包
./redis-rm.yml -l redis-test -e redis_uninstall=true

# 下线 Redis 节点 10.10.10.13 上的所有实例
./redis-rm.yml -l 10.10.10.13

# 下线特定 Redis 实例 10.10.10.13:6379
./redis-rm.yml -l 10.10.10.13 -e redis_port=6379
```

你也可以使用包装脚本来下线 Redis 集群/节点/实例：

```bash
bin/redis-rm redis-ms          # 下线 redis 集群 'redis-ms'
bin/redis-rm 10.10.10.10       # 下线 redis 节点 '10.10.10.10'
bin/redis-rm 10.10.10.10 6379  # 下线 redis 实例 '10.10.10.10:6379'
```

-------------

### 重新配置Redis

您可以部分执行 [`redis.yml`](#redisyml) 剧本来重新配置 Redis 集群、节点、或实例：

```bash
./redis.yml -l <cluster> -t redis_config,redis_launch
```

请注意，redis 无法在线重载配置，您只能使用 launch 任务进行重启来让配置生效。


-------------

## 使用Redis客户端

使用 `redis-cli` 访问 Reids 实例：

```bash
$ redis-cli -h 10.10.10.10 -p 6379 # <--- 使用 Host 与 Port 访问对应 Redis 实例
10.10.10.10:6379> auth redis.ms    # <--- 使用密码验证
OK
10.10.10.10:6379> set a 10         # <--- 设置一个Key
OK
10.10.10.10:6379> get a            # <--- 获取 Key 的值
"10"
```

Redis提供了`redis-benchmark`工具，可以用于Redis的性能评估，或生成一些负载用于测试。

```bash
redis-benchmark -h 10.10.10.13 -p 6379
```

-------------

### 手工设置Redis从库

https://redis.io/commands/replicaof/

```bash
# 将一个 Redis 实例提升为主库
> REPLICAOF NO ONE
"OK"

# 将一个 Redis 实例设置为另一个实例的从库
> REPLICAOF 127.0.0.1 6799
"OK"
```

-------------

### 设置Redis主从高可用

Redis独立主从集群可以通过 Redis 哨兵集群配置自动高可用，详细用户请参考 [Sentinel官方文档](https://redis.io/docs/management/sentinel/)

以四节点[沙箱环境](PROVISION#沙箱环境)为例，一套 Redis Sentinel 集群 `redis-meta`，可以用来管理很多套独立 Redis 主从集群。

以一主一从的Redis普通主从集群 `redis-ms` 为例，您需要在每个 Sentinel 实例上，使用 `SENTINEL MONITOR` 添加目标，并使用 `SENTINEL SET` 提供密码，高可用就配置完毕了。

```bash
# 对于每一个 sentinel，将 redis 主服务器纳入哨兵管理：（26379,26380,26381）
$ redis-cli -h 10.10.10.11 -p 26379 -a redis.meta
10.10.10.11:26379> SENTINEL MONITOR redis-ms 10.10.10.10 6379 1
10.10.10.11:26379> SENTINEL SET redis-ms auth-pass redis.ms      # 如果启用了授权，需要配置密码
```

如果您想移除某个由 Sentinel 管理的 Redis 主从集群，使用 `SENTINEL REMOVE <name>` 移除即可。

您可以使用定义在 Sentinel 集群上的 [`redis_sentinel_monitor`](PARAM#redis_sentinel_monitor) 参数，来自动配置管理哨兵监控管理的主库列表。

```yaml
redis_sentinel_monitor:  # 需要被监控的主库列表，端口、密码、法定人数（应为1/2以上的哨兵数量）为可选参数
  - { name: redis-src, host: 10.10.10.45, port: 6379 ,password: redis.src, quorum: 1 }
  - { name: redis-dst, host: 10.10.10.48, port: 6379 ,password: redis.dst, quorum: 1 }
```

使用以下命令刷新 Redis 哨兵集群上的纳管主库列表：

```bash
./redis.yml -l redis-meta -t redis-ha   # 如果您的 Sentinel 集群名称不是 redis-meta，请在这里替换。
```




----------------

## 剧本

REDIS模块提供了两个[剧本](playbook)，用于拉起/销毁 传统主从Redis集群/节点/实例：

- [`redis.yml`](#redisyml)：初始Redis集群/节点/实例。
- [`redis-rm.yml`](#redis-rmyml)：移除Redis集群/节点/实例

### `redis.yml`

用于初始化 Redis 的 [`redis.yml`](https://github.com/Vonng/pigsty/blob/master/redis.yml) 剧本包含以下子任务：

```bash
redis_node        : 初始化redis节点
  - redis_install : 安装redis & redis_exporter
  - redis_user    : 创建操作系统用户 redis
  - redis_dir     : 配置 redis的FHS目录结构
redis_exporter    : 配置 redis_exporter 监控
  - redis_exporter_config  : 生成redis_exporter配置
  - redis_exporter_launch  : 启动redis_exporter
redis_instance    : 停止并禁用redis集群/节点/实例
  - redis_check   : 检查redis实例是否存在
  - redis_clean   : 清除现有的redis实例
  - redis_config  : 生成redis实例配置
  - redis_launch  : 启动redis实例
redis_register    : 将redis注册到基础设施中
redis_ha          : 配置redis哨兵
redis_join        : 加入redis集群
```

<details><summary>示例：使用Redis剧本初始化Redis集群</summary>

[![asciicast](https://asciinema.org/a/568808.svg)](https://asciinema.org/a/568808)

</details>

### `redis-rm.yml`

用于卸载 Redis 的 [`redis-rm.yml`](https://github.com/Vonng/pigsty/blob/master/redis.yml) 剧本包含以下子任务：

```bash
register       : 从prometheus中移除监控目标
redis_exporter : 停止并禁用redis_exporter
redis          : 停止并禁用redis集群/节点/实例
redis_data     : 移除redis数据（rdb, aof）
redis_pkg      : 卸载redis & redis_exporter软件包
```




----------------

## 监控

Pigsty 提供了三个与 [`REDIS`](REDIS) 模块有关的监控仪表盘：

----------------

### Redis Overview

[Redis Overview](https://demo.pigsty.cc/d/redis-overview)：关于所有Redis集群/实例的详细信息

[![redis-overview.jpg](https://repo.pigsty.cc/img/redis-overview.jpg)](https://demo.pigsty.cc/d/redis-overview)

----------------

### Redis Cluster

[Redis Cluster](https://demo.pigsty.cc/d/redis-cluster)：关于单个Redis集群的详细信息

<details><summary>Redis Cluster Dashboard</summary>

[![redis-cluster.jpg](https://repo.pigsty.cc/img/redis-cluster.jpg)](https://demo.pigsty.cc/d/redis-cluster)

</details><br>

----------------

### Redis Instance

[Redis Instance](https://demo.pigsty.cc/d/redis-instance)： 关于单个Redis实例的详细信息

<details><summary>Redis Instance Dashboard</summary>

[![redis-instance](https://repo.pigsty.cc/img/redis-instance.jpg)](https://demo.pigsty.cc/d/redis-instance)

</details><br>



----------------

## 参数

Pigsty中有21个关于Redis模块的配置参数：

| 参数                                                       |    类型    |  级别   | 注释                                    |
|----------------------------------------------------------|:--------:|:-----:|---------------------------------------|
| [`redis_cluster`](PARAM#redis_cluster)                   |  string  |   C   | Redis数据库集群名称，必选身份参数                   |
| [`redis_instances`](PARAM#redis_instances)               |   dict   |   I   | Redis节点上的实例定义                         |
| [`redis_node`](PARAM#redis_node)                         |   int    |   I   | Redis节点编号，正整数，集群内唯一，必选身份参数            |
| [`redis_fs_main`](PARAM#redis_fs_main)                   |   path   |   C   | Redis主数据目录，默认为 `/data`                |
| [`redis_exporter_enabled`](PARAM#redis_exporter_enabled) |   bool   |   C   | Redis Exporter 是否启用？                  |
| [`redis_exporter_port`](PARAM#redis_exporter_port)       |   port   |   C   | Redis Exporter监听端口                    |
| [`redis_exporter_options`](PARAM#redis_exporter_options) |  string  |  C/I  | Redis Exporter命令参数                    |
| [`redis_safeguard`](PARAM#redis_safeguard)               |   bool   | G/C/A | 禁止抹除现存的Redis                          |
| [`redis_clean`](PARAM#redis_clean)                       |   bool   | G/C/A | 初始化Redis是否抹除现存实例                      |
| [`redis_rmdata`](PARAM#redis_rmdata)                     |   bool   | G/C/A | 移除Redis实例时是否一并移除数据？                   |
| [`redis_mode`](PARAM#redis_mode)                         |   enum   |   C   | Redis集群模式：sentinel，cluster，standalone |
| [`redis_conf`](PARAM#redis_conf)                         |  string  |   C   | Redis配置文件模板，sentinel 除外               |
| [`redis_bind_address`](PARAM#redis_bind_address)         |    ip    |   C   | Redis监听地址，默认留空则会绑定主机IP                |
| [`redis_max_memory`](PARAM#redis_max_memory)             |   size   |  C/I  | Redis可用的最大内存                          |
| [`redis_mem_policy`](PARAM#redis_mem_policy)             |   enum   |   C   | Redis内存逐出策略                           |
| [`redis_password`](PARAM#redis_password)                 | password |   C   | Redis密码，默认留空则禁用密码                     |
| [`redis_rdb_save`](PARAM#redis_rdb_save)                 | string[] |   C   | Redis RDB 保存指令，字符串列表，空数组则禁用RDB        |
| [`redis_aof_enabled`](PARAM#redis_aof_enabled)           |   bool   |   C   | Redis AOF 是否启用？                       |
| [`redis_rename_commands`](PARAM#redis_rename_commands)   |   dict   |   C   | Redis危险命令重命名列表                        |
| [`redis_cluster_replicas`](PARAM#redis_cluster_replicas) |   int    |   C   | Redis原生集群中每个主库配几个从库？                  |
| [`redis_sentinel_monitor`](PARAM#redis_cluster_replicas) | master[] |   C   | Redis哨兵监控的主库列表，只在哨兵集群上使用？             |


```yaml
#redis_cluster:            <集群> # Redis数据库集群名称，必选身份参数
#redis_node: 1             <节点> # Redis节点上的实例定义
#redis_instances: {}       <节点> # Redis节点编号，正整数，集群内唯一，必选身份参数
redis_fs_main: /data             # Redis主数据目录，默认为 `/data`
redis_exporter_enabled: true     # Redis Exporter 是否启用？
redis_exporter_port: 9121        # Redis Exporter监听端口
redis_exporter_options: ''       # Redis Exporter命令参数
redis_safeguard: false           # 禁止抹除现存的Redis
redis_clean: true                # 初始化Redis是否抹除现存实例
redis_rmdata: true               # 移除Redis实例时是否一并移除数据？
redis_mode: standalone           # Redis集群模式：sentinel，cluster，standalone
redis_conf: redis.conf           # Redis配置文件模板，sentinel 除外
redis_bind_address: '0.0.0.0'    # Redis监听地址，默认留空则会绑定主机IP
redis_max_memory: 1GB            # Redis可用的最大内存
redis_mem_policy: allkeys-lru    # Redis内存逐出策略
redis_password: ''               # Redis密码，默认留空则禁用密码
redis_rdb_save: ['1200 1']       # Redis RDB 保存指令，字符串列表，空数组则禁用RDB
redis_aof_enabled: false         # Redis AOF 是否启用？
redis_rename_commands: {}        # Redis危险命令重命名列表
redis_cluster_replicas: 1        # Redis原生集群中每个主库配几个从库？
redis_sentinel_monitor: []       # Redis哨兵监控的主库列表，只在哨兵集群上使用
```
