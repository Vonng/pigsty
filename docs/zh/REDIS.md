# REDIS

> Redis is an open source, in-memory data store that is widely used and works well with PostgreSQL


----------------

## Configuration

**Redis Identity**

Redis [**identity parameters**](PARAM#redis_id) are required parameters when defining a Redis cluster.

|                    Name                    |          Attribute          |     Description      |          Example          |
|:------------------------------------------:|:---------------------------:|:--------------------:|:-------------------------:|
|   [`redis_cluster`](PARAM#redis_cluster)   | **REQUIRED**, cluster level |     cluster name     |       `redis-test`        |
|      [`redis_node`](PARAM#redis_node)      |   **REQUIRED**，node level   | Node Sequence Number |          `1`,`2`          |
| [`redis_instances`](PARAM#redis_instances) |   **REQUIRED**，node level   | Instance Definition  | `{ 6001 : {} ,6002 : {}}` |


- [`redis_cluster`](PARAM#redis_cluster): Redis cluster name, top-level namespace for cluster sources.
- [`redis_node`](PARAM#redis_node): Redis node identity, integer the number of the node in the cluster.
- [`redis_instances`](PARAM#redis_instances): A Dict with the Key as redis port and the value as a instance level parameters.


**Redis Mode**

There are three [`redis_mode`](PARAM#redis_mode) available in Pigsty:

* `standalone`: setup redis as standalone (master-slave) mode
* `cluster`: setup this redis cluster as a redis native cluster
* `sentinel`: setup redis as sentinel for standalone redis HA

**Redis Definition**

Here are three examples:

```yaml
redis-ms: # redis classic primary & replica
  hosts: { 10.10.10.10: { redis_node: 1 , redis_instances: { 6501: { }, 6502: { replica_of: '10.10.10.10 6501' } } } }
  vars: { redis_cluster: redis-ms ,redis_max_memory: 64MB }

redis-meta: # redis sentinel x 3
  hosts: { 10.10.10.11: { redis_node: 1 , redis_instances: { 6001: { } ,6002: { } , 6003: { } } } }
  vars: { redis_cluster: redis-meta, redis_mode: sentinel ,redis_max_memory: 16MB }

redis-test: # redis native cluster: 3m x 3s
  hosts:
    10.10.10.12: { redis_node: 1 ,redis_instances: { 6501: { } ,6502: { } ,6503: { } } }
    10.10.10.13: { redis_node: 2 ,redis_instances: { 6501: { } ,6502: { } ,6503: { } } }
  vars: { redis_cluster: redis-test ,redis_mode: cluster, redis_max_memory: 32MB }
```

**Limitation**

* A redis node can only belong to one redis cluster
* You can not set different password for redis instances on same redis node (since redis_exporter only allows one password)



----------------

## Playbook

There are two playbooks for redis:

- [`redis.yml`](https://github.com/Vonng/pigsty/blob/master/redis.yml): create redis cluster / node / instance
- [`redis-rm.yml`](https://github.com/Vonng/pigsty/blob/master/redis-rm.yml): remove redis cluster /node /instance

You can also create & destroy redis cluster/node/instance with util scripts:

```bash
bin/redis-add redis-ms          # create redis cluster 'redis-ms'
bin/redis-add 10.10.10.10       # create redis node '10.10.10.10'
bin/redis-add 10.10.10.10 6501  # create redis instance '10.10.10.10:6501'

bin/redis-rm redis-ms           # remove redis cluster 'redis-ms'
bin/redis-rm 10.10.10.10        # remove redis node '10.10.10.10'
bin/redis-rm 10.10.10.10 6501   # remove redis instance '10.10.10.10:6501'
```


[![asciicast](https://asciinema.org/a/568808.svg)](https://asciinema.org/a/568808)



-------------

## Administration

**Init Cluster/Node/Instance**

```bash
# init all redis instances on group <cluster>
./redis.yml -l <cluster>      # create redis cluster

# init redis node (package,dir,exporter)
./redis.yml -l 10.10.10.10    # create redis cluster

# init all redis instances specific node
./redis.yml -l 10.10.10.10    # create redis cluster

# init one specific instance 10.10.10.11:6501
./redis.yml -l 10.10.10.11 -e redis_port=6501 -t redis
```

You can also use wrapper script:

```bash
bin/redis-add redis-ms          # create redis cluster 'redis-ms'
bin/redis-add 10.10.10.10       # create redis node '10.10.10.10'
bin/redis-add 10.10.10.10 6501  # create redis instance '10.10.10.10:6501'
```

**Remove Cluster/Node/Instance**

```bash
# Remove cluster `redis-test`
redis-rm.yml -l redis-test

# Remove cluster `redis-test`, and uninstall packages
redis-rm.yml -l redis-test -e redis_uninstall=true

# Remove all instance on redis node 10.10.10.13
redis-rm.yml -l 10.10.10.13

# Remove one specific instance 10.10.10.13:6501
redis-rm.yml -l 10.10.10.13 -e redis_port=6501
```

You can also use wrapper script:

```bash
bin/redis-rm redis-ms          # remove redis cluster 'redis-ms'
bin/redis-rm 10.10.10.10       # remove redis node '10.10.10.10'
bin/redis-rm 10.10.10.10 6501  # remove redis instance '10.10.10.10:6501'
```


**Setup standalone HA with sentinel**

You have to enable HA for redis standalone m-s cluster manually with your redis sentinel.

Take the 4-node sandbox as an example, a redis sentinel cluster `redis-meta` is used manage the `redis-ms` standalone cluster.  

```bash
# for each sentinel, add redis master to the sentinel with:
$ redis-cli -h 10.10.10.11 -p 6501 -a redis.meta
10.10.10.11:6501> SENTINEL MONITOR redis-ms 10.10.10.10 6501 1
10.10.10.11:6501> SENTINEL SET redis-ms auth-pass redis.ms      # if auth enabled, password has to be configured 
```



----------------

## Dashboards

There are three dashboards for [`REDIS`](REDIS) module.


[Redis Overview](https://demo.pigsty.cc/d/redis-overview): Overview of all Redis Instances

<details><summary>Redis Overview Dashboard</summary>

[![redis-overview](https://github.com/Vonng/pigsty/assets/8587410/cceabc05-7d9a-467e-9cb6-cf3f7da60ad3)](https://demo.pigsty.cc/d/redis-overview)

</details><br>



[Redis Cluster](https://demo.pigsty.cc/d/redis-cluster) : Overview of one single redis cluster

<details><summary>Redis Cluster Dashboard</summary>

[![redis-cluster](https://github.com/Vonng/pigsty/assets/8587410/840df751-07b7-4abc-83e1-108472e5b928)](https://demo.pigsty.cc/d/redis-cluster)

</details><br>



[Redis Instance](https://demo.pigsty.cc/d/redis-instance) : Overview of one single redis cluster

<details><summary>Redis Instance Dashboard</summary>

[![redis-instance](https://github.com/Vonng/pigsty/assets/8587410/caccbec5-8cf2-44a2-adc1-78b4cae5e9fb)](https://demo.pigsty.cc/d/redis-instance)

</details><br>



----------------

## 参数


There are 3 sections, 20 parameters about [`REDIS`](PARAM#REDIS) module.

- [`REDIS_ID`](PARAM#redis_id) : REDIS Identity Parameters
- [`REDIS_NODE`](PARAM#redis_node) : REDIS Node & Exporter
- [`REDIS_PROVISION`](PARAM#redis_provision) : Config & Launch Redis Instances

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
