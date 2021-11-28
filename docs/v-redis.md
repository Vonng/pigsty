# Redis Config


## Overview

|                            Name                             |    Type    | Level  | Description |
| :----------------------------------------------------------: | :--------: | :---: | ---- |
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
redis_cluster: redis-test           # name of this redis 'cluster' , cluster level
redis_node: 1                       # id of this redis node, integer sequence @ instance level
redis_instances: {}                 # redis instance list on this redis node @ instance level

# - mode - #
redis_mode: standalone              # standalone,cluster,sentinel
redis_conf: redis.conf              # which config template will be used
redis_fs_main: /data                # main data disk for redis
redis_bind_address: '0.0.0.0'       # e.g 0.0.0.0, empty will use inventory_hostname as bind address

# - cleanup - #
redis_exists: false                 # internal flag
redis_exists_action: clean          # abort|skip|clean if dcs server already exists
redis_disable_purge: false          # set to true to disable purge functionality for good (force redis_exists_action = abort)

# - conf - #
redis_max_memory: 1GB               # max memory used by each redis instance
redis_mem_policy: allkeys-lru       # memory eviction policy
redis_password: ''                  # empty password disable password auth (masterauth & requirepass)
redis_rdb_save: ['1200 1']          # redis RDB save directives, empty list disable it
redis_aof_enabled: false            # enable redis AOF
redis_rename_commands: {}           # rename dangerous commands
# redis_rename_commands:              # rename dangerous commands
#   flushall: opflushall
#   flushdb: opflushdb
#   keys: opkeys
redis_cluster_replicas: 1           # how much replicas per master in redis cluster ?

# - redis exporter - #
redis_exporter_enabled: true        # install redis exporter on redis nodes
redis_exporter_port: 9121           # default port for redis exporter
redis_exporter_options: ''          # default cli args for redis exporter

# - node exporter - #
node_exporter_enabled: true                   # setup node_exporter on instance
node_exporter_port: 9100                      # default port for node exporter
node_exporter_options: '--no-collector.softnet --collector.systemd --collector.ntp --collector.tcpstat --collector.processes'

# - reference - #
redis_install: yum                  # none|yum|binary, yum by default (install from yum repo)
exporter_install: none              # none|yum|binary, none by default (usually installed during node init)
exporter_repo_url: ''               # if set, repo will be added to /etc/yum.repos.d/ before yum installation
exporter_metrics_path: /metrics     # default metric path for pg related exporter
service_registry: consul
...
```



## Identity Parameters

|           Name            |   Type   | Level  | Description                            |
| :-----------------------: | :------: | :---: | ------------------------------- |
| [pg_cluster](#pg_cluster) | `string` | **C** | **PG Cluster Name**            |
|     [pg_seq](#pg_seq)     | `number` | **I** | **PG Instance Serial**            |
|    [pg_role](#pg_role)    |  `enum`  | **I** | **PG Instance Role**            |
|   [pg_shard](#pg_shard)   | `string` | **C** | **PG Sharding Name** (TODO) |
|  [pg_sindex](#pg_sindex)  | `number` | **C** | **PG Sharding Index** (TODO) |

`pg_cluster`， `pg_role`， `pg_seq` are **identity parameters** .

They are a minimal set of parameters for defining a new postgres cluster. They MUST be explicitly set.

* `pg_cluster` identifies the name of the cluster and is configured at the cluster level.
* `pg_role` identifies the role of the instance, configured at the instance level. Only the `primary` role will be handled specially, if left unfilled, the default is the `replica` role, in addition to the special `delayed` and `offline` roles.
* `pg_seq` is used to identify the instance within the cluster, usually as an integer incrementing from 0 or 1, and will not be changed once assigned.
* `{{ pg_cluster }}-{{ pg_seq }}` is used to uniquely identify the instance, i.e. `pg_instance`
* `{{ pg_cluster }}-{{ pg_role }}` is used to identify the services within the cluster, i.e. `pg_service`

```yaml
pg-test:
  hosts:
    10.10.10.11: {pg_seq: 1, pg_role: replica}
    10.10.10.12: {pg_seq: 2, pg_role: primary}
    10.10.10.13: {pg_seq: 3, pg_role: replica}
  vars:
    pg_cluster: pg-test
```

`pg_shard` 与 `pg_sindex` is reserved for horizontal sharding clusters. for future support for citus.



## Details

### redis_cluster

The name of the Redis database cluster will be used as the namespace for the resources within the cluster.

Cluster naming needs to follow specific naming rules: `[a-z][a-z0-9-]*` to be compatible with different constraints on identity identification.

**identity, required, cluster-level**


### redis_node

Unique sequence number of redis nodes among cluster. allocate from 0 or 1. 

**identity, required, node-level**



### redis_instances

Describe all redis instances deployed on this node. Key as port number, value as instance override conf (such as `replica_of`)

Examples:

```yaml
redis_instances: { 6501 : {} ,6502 : {} ,6503 : {} ,6504 : {} ,6505 : {} ,6506 : {} }
redis_instances:
    6501: {}
    6502: { replica_of: '10.10.10.13 6501' }
    6503: { replica_of: '10.10.10.13 6501' }
```

**identity, required, node-level**


### redis_mode

string, cluster level, enum:

* `standalone` : default mode (can be used for primary-replica replication)
* `cluster`： Redis native cluster
* `sentinel`：Redis ha components: sentinel

Pigsty will setup primary-replica replication according to `replica_of` only if `redis_mode = standalone`.
Pigsty will create native cluster according to [`redis_cluster_replicas`](#redis_cluster_replicas) if `redis_mode = cluster`.


### redis_conf



### redis_fs_main



### redis_bind_address



### redis_exists



### redis_exists_action



### redis_disable_purge



### redis_max_memory



### redis_mem_policy



### redis_password



### redis_rdb_save



### redis_aof_enabled



### redis_rename_commands



### redis_cluster_replicas



### redis_exporter_enabled



### redis_exporter_port



### redis_exporter_options

