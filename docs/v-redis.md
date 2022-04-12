# Config: REDIS

> [config](v-config.md) Redis cluster, control [REDIS playbook](p-redis.md) behavior, refer to [Redis Deploy and Monitoring Tutorial](t-redis.md) for details.

- [`REDIS_IDENTITY`](#REDIS_IDENTITY): REDIS Identity Params

- [`REDIS_PROVISION`](#REDIS_PROVISION): REDIS Cluster Provisioning

  [`REDIS_EXPORTER`](#REDIS_EXPORTER): REDIS  Exporter


| ID   | Name                                                | Section                               | Type       | Level | Comment                                                      |
| ---- | --------------------------------------------------- | ------------------------------------- | ---------- | ----- | ------------------------------------------------------------ |
| 700  | [`redis_cluster`](#redis_cluster)                   | [`REDIS_IDENTITY`](#REDIS_IDENTITY)   | string     | C     | redis cluster identity                                       |
| 701  | [`redis_node`](#redis_node)                         | [`REDIS_IDENTITY`](#REDIS_IDENTITY)   | int        | I     | redis node identity                                          |
| 702  | [`redis_instances`](#redis_instances)               | [`REDIS_IDENTITY`](#REDIS_IDENTITY)   | instance[] | I     | redis instances definition on this node                      |
| 720  | [`redis_install`](#redis_install)                   | [`REDIS_PROVISION`](#REDIS_PROVISION) | enum       | C     | Way of install redis binaries                                |
| 721  | [`redis_mode`](#redis_mode)                         | [`REDIS_PROVISION`](#REDIS_PROVISION) | enum       | C     | standalone,cluster,sentinel                                  |
| 722  | [`redis_conf`](#redis_conf)                         | [`REDIS_PROVISION`](#REDIS_PROVISION) | string     | C     | which config template will be used                           |
| 723  | [`redis_fs_main`](#redis_fs_main)                   | [`REDIS_PROVISION`](#REDIS_PROVISION) | path       | C     | main data disk for redis                                     |
| 724  | [`redis_bind_address`](#redis_bind_address)         | [`REDIS_PROVISION`](#REDIS_PROVISION) | ip         | C     | e.g 0.0.0.0, empty will use inventory_hostname as bind address |
| 725  | [`redis_exists_action`](#redis_exists_action)       | [`REDIS_PROVISION`](#REDIS_PROVISION) | enum       | C     | what to do when redis exists                                 |
| 726  | [`redis_disable_purge`](#redis_disable_purge)       | [`REDIS_PROVISION`](#REDIS_PROVISION) | string     | C     | set to true to disable purge functionality for good (force redis_exists_action = abort) |
| 727  | [`redis_max_memory`](#redis_max_memory)             | [`REDIS_PROVISION`](#REDIS_PROVISION) | size       | C/I   | max memory used by each redis instance                       |
| 728  | [`redis_mem_policy`](#redis_mem_policy)             | [`REDIS_PROVISION`](#REDIS_PROVISION) | enum       | C     | memory eviction policy                                       |
| 729  | [`redis_password`](#redis_password)                 | [`REDIS_PROVISION`](#REDIS_PROVISION) | string     | C     | empty password disable password auth (masterauth & requirepass) |
| 730  | [`redis_rdb_save`](#redis_rdb_save)                 | [`REDIS_PROVISION`](#REDIS_PROVISION) | string[]   | C     | redis RDB save directives, empty list disable it             |
| 731  | [`redis_aof_enabled`](#redis_aof_enabled)           | [`REDIS_PROVISION`](#REDIS_PROVISION) | bool       | C     | enable redis AOF                                             |
| 732  | [`redis_rename_commands`](#redis_rename_commands)   | [`REDIS_PROVISION`](#REDIS_PROVISION) | object     | C     | rename dangerous commands                                    |
| 740  | [`redis_cluster_replicas`](#redis_cluster_replicas) | [`REDIS_PROVISION`](#REDIS_PROVISION) | int        | C     | how much replicas per master in redis cluster ?              |
| 741  | [`redis_exporter_enabled`](#redis_exporter_enabled) | [`REDIS_EXPORTER`](#REDIS_EXPORTER)   | bool       | C     | install redis exporter on redis nodes                        |
| 742  | [`redis_exporter_port`](#redis_exporter_port)       | [`REDIS_EXPORTER`](#REDIS_EXPORTER)   | int        | C     | default port for redis exporter                              |
| 743  | [`redis_exporter_options`](#redis_exporter_options) | [`REDIS_EXPORTER`](#REDIS_EXPORTER)   | string     | C/I   | default cli args for redis exporter                          |


----------------
## `REDIS_IDENTITY`

**Identity parameters** are the information that must be provided to define a Redis cluster, including:

|                  Name                  |        Level        |   Description   |         Example         |
|:-------------------------------------:| :----------------: | :------: | :------------------: |
|   [`redis_cluster`](#redis_cluster)   | **MUST**, cluster level |  Cluster name  |      `redis-test`       |
|      [`redis_node`](#redis_node)      | **MUST**, node level | Node Number | `primary`, `replica` |
| [`redis_instances`](#redis_instances) | **MUST**, node level | Ins Definition | `{ 6001 : {} ,6002 : {}}`  |


- [`redis_cluster`](#redis_cluster) identifies the name of the Redis cluster, which is configured at the cluster level and serves as the top-level namespace for cluster resources.
- [`redis_node`](#redis_node) identifies the serial number of the node in the cluster.
- [`redis_instances`](#redis_instances) is a JSON object with the Key as the ins port and the Value as a JSON object containing the instance-specific config.



### `redis_cluster`

Redis cluster identity, type: `string`, level: C, default value:

Redis cluster identity will be used as a namespace for resources within the cluster and needs to follow specific naming rules: `[a-z][a-z0-9-]*` to be compatible with different constraints on identity identification. It is recommended to use `redis-` as the cluster name prefix.

**Identity params required params and cluster-level params**.




### `redis_node`

Redis node identity, type: `int`, level: I, default value:

Redis node identity, unique within the **cluster**, is used to distinguish and identify different nodes within the cluster, starting with an assignment of 0 or 1.



### `redis_instances`

Redis instances definition on this node, type: `instance[]`, level: I, default value:

All Redis ins are deployed on this database node, in JSON K-V object format. the key is the numeric type port number, and the value is the JSON config entry specific to that instance.

Sample example:

```yaml
redis_instances: { 6501 : {} ,6502 : {} ,6503 : {} ,6504 : {} ,6505 : {} ,6506 : {} }
redis_instances:
    6501: {}
    6502: { replica_of: '10.10.10.13 6501' }
    6503: { replica_of: '10.10.10.13 6501' }
```

Each Redis ins listens on a unique port on the node, and you can configure separate parameter options for Redis ins (currently only `replica_of` is supported for pre-built master-slave replication).

**Identity params required params and instance-level params**.





----------------
## `REDIS_PROVISION`





### `redis_install`

Way of installing Redis binaries, type: `enum`, level: C, default value: `"yum"`.

When `none` is specified, you will need to complete the Redis installation yourself, for example through the NODES-related params.




### `redis_mode`

Redis cluster mode, type: `enum`, level: C, default value: `"standalone"`.

Specifies the mode of this Redis cluster, with three optional modes:

* `standalone`: default mode, deploys a series of independent Redis ins, (a common master-slave can be built)
* `cluster`: Redis native cluster mode
* `sentinel`: Redis high availability component: sentinel

When using the `standalone` mode, Pigsty additionally sets up Redis masters and slaves based on the `replica_of` parameter.
When using `cluster` mode, Pigsty creates a native Redis cluster using all defined instances according to the [`redis_cluster_replicas`](#redis_cluster_replicas) parameter.




### `redis_conf`

Redis config template, type: `string`, level: C, default value: `"redis.conf"`.



### `redis_fs_main`

Main data disk for Redis, type: `path`, level: C, default value: `"/data"`.

The main data disk for Redis, default is `/data`.

Pigsty will create the `redis` dir under that dir to store Redis data. For example, `/data/redis`.

See [FHS: Redis](r-fhs.md) for details.


### `redis_bind_address`

Redis listener address, type: `ip`, level: C, default value: `"0.0.0.0"`.

Redis listener the IP address, or `inventory_hostname` if left blank. The default listener has all local IPv4 addresses.



### `redis_exists_action`

What to do when Redis exists, type: `enum`, level: C, default value: `"clean"`.

* `abort`: abort the execution of the entire playbook
* `skip`: Continue execution, so the Redis ins may be started using an RDB file from an existing database.
* `clean`: wipes the data and starts clean.



### `redis_disable_purge`

Disable erasure of existing Redis, type: `string`, level: C, default value: `false`.

If enabled, force set [`redis_exists_action`](#redis_exists_action) = `abort`.

### `redis_max_memory`

Max memory used by each Redis ins, type: `size`, level: C/I, default value: `"1GB"`

Max memory used by each Redis ins, default is 1GB, it is recommended to configure this parameter at the cluster level to keep the cluster ins config consistent.



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

Be careful with security, do not place Redis on the public network without password protection.



### `redis_rdb_save`

RDB SAVE directives, type: `string[]`, level: C, default value: `[ "1200 1" ]`.

Redis SAVE directives, the config will enable RDB functionality, each Save policy as a string。



### `redis_aof_enabled`

Enable AOF, type: `bool`, level: C, default value: `false`.





### `redis_rename_commands`

Rename dangerous commands, Type: `object`, Level: C, Default value: `{}`.

JSON dictionary, rename the command represented by Key to the command represented by Value to avoid misuse of dangerous commands.






### `redis_cluster_replicas`

How many replicas per master in Redis cluster, type: `int`, tier: C, default: `1`.

How many replicas per master in the Redis cluster? The default is 1.

```bash
/bin/redis-cli --cluster create --cluster-yes \
  --cluster-replicas {{ redis_cluster_replicas|default(1) }}
```





----------------
## `REDIS_EXPORTER`

REDIS Exporter Related Config.


### `redis_exporter_enabled`

Enable Redis exporter, type: `bool`, level: C, default: `true`.

Redis Exporter is enabled by default, one on each Redis node deployed and listens on port 9121 by default.



### `redis_exporter_port`

Redis Exporter listens port, type: `int`, tier: C, default value: `9121`.

Note: If you modify this default port, you will need to replace this port along with the relevant config rule file in Prometheus.



### `redis_exporter_options`

Redis Exporter command parameter, type: `string`, level: C/I, default value: `""`.