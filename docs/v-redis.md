# Config: REDIS

> [Config](v-config.md) [Redis](v-redis.md) cluster and manipulate [REDIS playbook](p-redis.md) behavior. Refer to [Redis Deployment](t-redis.md) for details.

- [`REDIS_IDENTITY`](#REDIS_IDENTITY): REDIS Identity Params

- [`REDIS_NODE`](#REDIS_NODE): REDIS Software, Dir & Exporter

- [`REDIS_PROVISION`](#REDIS_PROVISION): REDIS Server Provisioning




| ID | Name                                                | Section                               | Type       | Level | Comment                                                      |
| -- |-----------------------------------------------------| ------------------------------------- | ---------- | ----- | ------------------------------------------------------------ |
| 700 | [`redis_cluster`](#redis_cluster)                   | [`REDIS_IDENTITY`](#REDIS_IDENTITY)   | string     | C     | redis cluster identity                                       |
| 701 | [`redis_node`](#redis_node)                         | [`REDIS_IDENTITY`](#REDIS_IDENTITY)   | int        | I     | redis node identity                                          |
| 702 | [`redis_instances`](#redis_instances)               | [`REDIS_IDENTITY`](#REDIS_IDENTITY)   | instance[] | I     | redis instances definition on this node                      |
| 710  | [`redis_fs_main`](#redis_fs_main)                   | [`REDIS_NODE`](#REDIS_NODE) | path       | C     | main data disk for redis                                     |
| 711 | [`redis_exporter_enabled`](#redis_exporter_enabled) | [`REDIS_NODE`](#REDIS_NODE)   | bool       | C     | install redis exporter on redis nodes                        |
| 712 | [`redis_exporter_port`](#redis_exporter_port)       | [`REDIS_NODE`](#REDIS_NODE)   | int        | C     | default port for redis exporter                              |
| 713 | [`redis_exporter_options`](#redis_exporter_options) | [`REDIS_NODE`](#REDIS_NODE)   | string     | C/I   | default cli args for redis exporter                          |
| 720  | [`redis_safeguard`](#redis_safeguard)               | [`REDIS_PROVISION`](#REDIS_PROVISION) | bool     | C     | set to true to disable purge  |
| 721  | [`redis_clean`](#redis_clean)                       | [`REDIS_PROVISION`](#REDIS_PROVISION) | bool       | C     | purge existing redis during init |
| 722  | [`redis_rmdata`](#redis_clean)                       | [`REDIS_PROVISION`](#REDIS_PROVISION) | bool       | C     | remove redis data dir with it? |
| 723 | [`redis_mode`](#redis_mode)                         | [`REDIS_PROVISION`](#REDIS_PROVISION) | enum       | C     | standalone,cluster,sentinel                                  |
| 724 | [`redis_conf`](#redis_conf)                         | [`REDIS_PROVISION`](#REDIS_PROVISION) | string     | C     | which config template will be used                           |
| 725  | [`redis_bind_address`](#redis_bind_address)         | [`REDIS_PROVISION`](#REDIS_PROVISION) | ip         | C     | e.g 0.0.0.0, empty will use inventory_hostname as bind address |
| 726  | [`redis_max_memory`](#redis_max_memory)             | [`REDIS_PROVISION`](#REDIS_PROVISION) | size       | C/I   | max memory used by each redis instance                       |
| 727  | [`redis_mem_policy`](#redis_mem_policy)             | [`REDIS_PROVISION`](#REDIS_PROVISION) | enum       | C     | memory eviction policy                                       |
| 728  | [`redis_password`](#redis_password)                 | [`REDIS_PROVISION`](#REDIS_PROVISION) | string     | C     | empty password disable password auth (masterauth & requirepass) |
| 729  | [`redis_rdb_save`](#redis_rdb_save)                 | [`REDIS_PROVISION`](#REDIS_PROVISION) | string[]   | C     | RDB save cmd, disable with empty  array                      |
| 730  | [`redis_aof_enabled`](#redis_aof_enabled)           | [`REDIS_PROVISION`](#REDIS_PROVISION) | bool       | C     | enable redis AOF                                             |
| 731  | [`redis_rename_commands`](#redis_rename_commands)   | [`REDIS_PROVISION`](#REDIS_PROVISION) | object     | C     | rename dangerous commands                                    |
| 732  | [`redis_cluster_replicas`](#redis_cluster_replicas) | [`REDIS_PROVISION`](#REDIS_PROVISION) | int        | C     | how much replicas per master in redis cluster ?              |



----------------
## `REDIS_IDENTITY`

**Identity parameters** are the information that must be provided to define a Redis cluster, including:

|                  Name                  |        Level        |   Description   |         Example         |
|:-------------------------------------:| :----------------: | :------: | :------------------: |
|   [`redis_cluster`](#redis_cluster)   | **MUST**, cluster level |  Cluster name  |      `redis-test`       |
|      [`redis_node`](#redis_node)      | **MUST**, node level | Node Number | `primary`, `replica` |
| [`redis_instances`](#redis_instances) | **MUST**, node level | Ins Definition | `{ 6001 : {} ,6002 : {}}`  |


- [`redis_cluster`](#redis_cluster) identifies the Redis cluster name, configured at the cluster level, and serves as the top-level namespace for cluster resources.
- [`redis_node`](#redis_node) identifies the serial number of the node in the cluster.
- [`redis_instances`](#redis_instances) is a JSON object with the Key as the ins port and the Value as a JSON object containing the instance-specific config.



### `redis_cluster`

Redis cluster identity, type: `string`, level: C, default value:

Redis cluster identity will be used as a namespace for resources within the cluster and needs to follow specific naming patterns: `[a-z][a-z0-9-]*` to be compatible with different constraints on identity identification. It is recommended to use `redis-` as the cluster name prefix.

**Identity param is required params and cluster-level params**.




### `redis_node`

Redis node identity, type: `int`, level: I, default value:

Redis node identity, unique in the **cluster**, is used to distinguish and identify different nodes, starting with an assignment of 0 or 1.



### `redis_instances`

Redis instances definition on this node, type: `instance[]`, level: I, default value.

This database node deployed all Redis ins in JSON K-V object format. The key is the numeric type port number, and the value is the JSON config entry specific to that instance.

Sample example:

```yaml
redis_instances: { 6501 : {} ,6502 : {} ,6503 : {} ,6504 : {} ,6505 : {} ,6506 : {} }
redis_instances:
    6501: {}
    6502: { replica_of: '10.10.10.13 6501' }
    6503: { replica_of: '10.10.10.13 6501' }
```

Each Redis ins listens on a unique port on the node. You can configure separate parameter options for Redis ins (currently, only `replica_of` is supported for pre-built M-S replication).

**Identity params required params and instance-level params**.




----------------
## `REDIS_NODE`



### `redis_fs_main`

Primary data disk for Redis, type: `path`, level: C, default value: `"/data"`.

Pigsty will create the `redis` dir under that dir to store Redis data. For example, `/data/redis`.

See [FHS: Redis](r-fhs.md) for details.




### `redis_exporter_enabled`

Enable Redis exporter, type: `bool`, level: C, default: `true`.

Redis Exporter is enabled by default, one on each Redis node deployed and listens on port 9121 by default.



### `redis_exporter_port`

Redis Exporter listens port, type: `int`, tier: C, default value: `9121`.

Note: If you modify this default port, you will need to replace this port along with the relevant config rule file in Prometheus.



### `redis_exporter_options`

Redis Exporter command parameter, type: `string`, level: C/I, default value: `""`.



----------------
## `REDIS_PROVISION`


### `redis_safeguard`

Disable erasure of existing Redis, type: `string`, level: C, default value: `false`.

if true, [`redis.yml`](p-redis.md#redis) and [`redis-remove.yml`](p-redis.md#redis-remove) will not remove running redis instance


### `redis_clean`

What to do when Redis exists, type: `bool`, level: C/A, default value: `"false"`.

If true, [`redis.yml`](p-redis.md#redis) will purge existing instance during init.



### `redis_mode`

Redis cluster mode, type: `enum`, level: C, default value: `"standalone"`.

Specifies the mode of this Redis cluster, with three optional modes:

* `standalone`: Default mode, deploys a series of independent Redis ins.
* `cluster`: Redis native cluster mode
* `sentinel`: Redis HA component: sentinel

Pigsty also sets up standalone Redis based on the `replica_of` parameter when using the `standalone` mode.
Pigsty creates a native Redis cluster using all defined instances according to the [`redis_cluster_replicas`](#redis_cluster_replicas) parameter when using `cluster` mode.




### `redis_conf`

Redis config template, type: `string`, level: C, default value: `"redis.conf"`.




### `redis_bind_address`

Redis listener address, type: `ip`, level: C, default value: `"0.0.0.0"`.

Redis listener the IP, or `inventory_hostname` if left blank. The default listener has all local IPv4.


### `redis_max_memory`

Max memory used by each Redis ins, type: `size`, level: C/I, default value: `"1GB"`

Max memory used by each Redis ins, default is 1GB; it is recommended to configure this parameter at the cluster level to keep the cluster ins config consistent.



### `redis_mem_policy`

Memory eviction policy, type: `enum`, level: C, default value: `"allkeys-lru"`.

Other optional policies include:

* `volatile-lru`
* `allkeys-lru`
* `volatile-lfu`
* `allkeys-lfu`
* `volatile-random`
* `allkeys-random`
* `volatile-ttl`
* `noeviction`



### `redis_password`

Redis password, type: `string`, level: C, default value: `""`.

`masterauth` & `requirepass` password to use, leave blank to disable password, disabled by default.

!> Be careful with security, do not place Redis on the public network without password protection.



### `redis_rdb_save`

RDB SAVE directives, type: `string[]`, level: C, default value: `[ "1200 1" ]`.

Redis SAVE directives, the config will enable RDB functionality, each Save policy as a string。



### `redis_aof_enabled`

Enable AOF, type: `bool`, level: C, default value: `false`.





### `redis_rename_commands`

Rename dangerous commands, Type: `object`, Level: C, Default value: `{}`.

JSON dictionary renames the command represented by Key to the command represented by Value to avoid misuse of dangerous commands.






### `redis_cluster_replicas`

How many replicas per primary in Redis cluster, type: `int`, tier: C, default: `1`.

```bash
/bin/redis-cli --cluster create --cluster-yes \
  --cluster-replicas {{ redis_cluster_replicas|default(1) }}
```
