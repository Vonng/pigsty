# REDIS

> Redis is a widely used open-source, in-memory data store that works well with PostgreSQL.

[Configuration](#configuration) | [Administration](#administration) | [Playbook](#playbook) | [Dashboard](#dashboard) | [Parameter](#parameter)

----------------

## Concept

The entity model of Redis is almost the same as that of [PostgreSQL](PGSQL-ARCH#er-diagram), which also includes the concepts of **Cluster** and **Instance**. The Cluster here does not refer to the native Redis Cluster mode.

The core difference between the REDIS module and the [PGSQL](PGSQL) module is that Redis uses a **single-node multi-instance** deployment rather than the 1:1 deployment: multiple Redis instances are typically deployed on a physical/virtual machine node to utilize multi-core CPUs fully. Therefore, the ways to [configure](#Configuration) and [administer](#administration) Redis instances are slightly different from PGSQL.

In Redis managed by Pigsty, nodes are entirely subordinate to the cluster, which means that currently, it is not allowed to deploy Redis instances of two different clusters on one node. However, this does not affect deploying multiple independent Redis primary replica instances on one node.



----------------

## Configuration

**Redis Identity**

Redis [**identity parameters**](PARAM#redis_id) are required parameters when defining a Redis cluster.

|                    Name                    |          Attribute          |     Description      |          Example          |
| :----------------------------------------: | :-------------------------: | :------------------: | :-----------------------: |
|   [`redis_cluster`](PARAM#redis_cluster)   | **REQUIRED**, cluster level |     cluster name     |       `redis-test`        |
|      [`redis_node`](PARAM#redis_node)      |  **REQUIRED**, node level   | Node Sequence Number |          `1`,`2`          |
| [`redis_instances`](PARAM#redis_instances) |  **REQUIRED**, node level   | Instance Definition  | `{ 6001 : {} ,6002 : {}}` |


- [`redis_cluster`](PARAM#redis_cluster): Redis cluster name, top-level namespace for cluster sources.
- [`redis_node`](PARAM#redis_node): Redis node identity, integer, and node number in the cluster.
- [`redis_instances`](PARAM#redis_instances): A Dict with the Key as redis port and the value as an instance level parameter.

**Redis Mode**

There are three [`redis_mode`](PARAM#redis_mode) available in Pigsty:

* `standalone`: setup Redis in standalone (master-slave) mode
* `cluster`: setup this Redis cluster as a Redis native cluster
* `sentinel`: setup Redis as a sentinel for standalone Redis HA

**Redis Definition**

Here are three examples:

- A 1-node, one master & one slave Redis Standalone cluster: `redis-ms`
- A 1-node, 3-instance Redis Sentinel cluster: `redis-sentinel`
- A 2-node, 6-instance Redis Cluster: `redis-cluster`

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



- A Redis node can only belong to one Redis cluster, which means you cannot assign a node to two different Redis clusters simultaneously.
- On each Redis node, you need to assign a unique port number to the Redis instance to avoid port conflicts.
- Typically, the same Redis cluster will use the same password, but multiple Redis instances on a Redis node cannot set different passwords (because redis_exporter only allows one password).
- Redis Cluster has built-in HA, while standalone HA requires manually configured in Sentinel because we are unsure if you have any sentinels available. Fortunately, configuring standalone Redis HA is straightforward: [Configure HA with sentinel](#configure-ha-with-sentinel).




-------------

## Administration

Here are some common administration tasks for Redis. Check [FAQ: Redis](FAQ#REDIS) for more details.

-------------

### Init Redis

**Init Cluster/Node/Instance**

```bash
# init all redis instances on group <cluster>
./redis.yml -l <cluster>      # init redis cluster

# init redis node
./redis.yml -l 10.10.10.10    # init redis node

# init one specific redis instance 10.10.10.11:6501
./redis.yml -l 10.10.10.11 -e redis_port=6501 -t redis
```

You can also use wrapper script:

```bash
bin/redis-add redis-ms          # create redis cluster 'redis-ms'
bin/redis-add 10.10.10.10       # create redis node '10.10.10.10'
bin/redis-add 10.10.10.10 6501  # create redis instance '10.10.10.10:6501'
```

-------------

### Remove Redis

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

-------------

## Use Redis Client Tools

Access redis instance with `redis-cli`:

```bash
$ redis-cli -h 10.10.10.10 -p 6501 # <--- connect with host and port
10.10.10.10:6501> auth redis.ms    # <--- auth with password
OK
10.10.10.10:6501> set a 10         # <--- set a key
OK
10.10.10.10:6501> get a            # <--- get a key back
"10"
```

Redis also has a `redis-benchmark` which can be used for benchmark and generate load on redis server:

```bash
redis-benchmark -h 10.10.10.13 -p 6501
```

-------------

### Configure HA with Sentinel

You have to enable HA for redis standalone m-s cluster manually with your redis sentinel.

Take the 4-node sandbox as an example, a redis sentinel cluster `redis-meta` is used manage the `redis-ms` standalone cluster.  

```bash
# for each sentinel, add redis master to the sentinel with:
$ redis-cli -h 10.10.10.11 -p 6501 -a redis.meta
10.10.10.11:6501> SENTINEL MONITOR redis-ms 10.10.10.10 6501 1
10.10.10.11:6501> SENTINEL SET redis-ms auth-pass redis.ms      # if auth enabled, password has to be configured 
```




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




----------------

## Dashboard

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

## Parameter

There 20 parameters in the redis module.

| Parameter                                                |   Type   | Level | Comment                                            |
|----------------------------------------------------------|:--------:|:-----:|----------------------------------------------------|
| [`redis_cluster`](PARAM#redis_cluster)                   |  string  |   C   | redis cluster name, required identity parameter    |
| [`redis_instances`](PARAM#redis_instances)               |   dict   |   I   | redis instances definition on this redis node      |
| [`redis_node`](PARAM#redis_node)                         |   int    |   I   | redis node sequence number, node int id required   |
| [`redis_fs_main`](PARAM#redis_fs_main)                   |   path   |   C   | redis main data mountpoint, `/data` by default     |
| [`redis_exporter_enabled`](PARAM#redis_exporter_enabled) |   bool   |   C   | install redis exporter on redis nodes?             |
| [`redis_exporter_port`](PARAM#redis_exporter_port)       |   port   |   C   | redis exporter listen port, 9121 by default        |
| [`redis_exporter_options`](PARAM#redis_exporter_options) |  string  |  C/I  | cli args and extra options for redis exporter      |
| [`redis_safeguard`](PARAM#redis_safeguard)               |   bool   | G/C/A | prevent purging running redis instance?            |
| [`redis_clean`](PARAM#redis_clean)                       |   bool   | G/C/A | purging existing redis during init?                |
| [`redis_rmdata`](PARAM#redis_rmdata)                     |   bool   | G/C/A | remove redis data when purging redis server?       |
| [`redis_mode`](PARAM#redis_mode)                         |   enum   |   C   | redis mode: standalone,cluster,sentinel            |
| [`redis_conf`](PARAM#redis_conf)                         |  string  |   C   | redis config template path, except sentinel        |
| [`redis_bind_address`](PARAM#redis_bind_address)         |    ip    |   C   | redis bind address, empty string will use host ip  |
| [`redis_max_memory`](PARAM#redis_max_memory)             |   size   |  C/I  | max memory used by each redis instance             |
| [`redis_mem_policy`](PARAM#redis_mem_policy)             |   enum   |   C   | redis memory eviction policy                       |
| [`redis_password`](PARAM#redis_password)                 | password |   C   | redis password, empty string will disable password |
| [`redis_rdb_save`](PARAM#redis_rdb_save)                 | string[] |   C   | redis rdb save directives, disable with empty list |
| [`redis_aof_enabled`](PARAM#redis_aof_enabled)           |   bool   |   C   | enable redis append only file?                     |
| [`redis_rename_commands`](PARAM#redis_rename_commands)   |   dict   |   C   | rename redis dangerous commands                    |
| [`redis_cluster_replicas`](PARAM#redis_cluster_replicas) |   int    |   C   | replica number for one master in redis cluster     |


```yaml
#redis_cluster:        <CLUSTER> # redis cluster name, required identity parameter
#redis_node: 1            <NODE> # redis node sequence number, node int id required
#redis_instances: {}      <NODE> # redis instances definition on this redis node
redis_fs_main: /data              # redis main data mountpoint, `/data` by default
redis_exporter_enabled: true      # install redis exporter on redis nodes?
redis_exporter_port: 9121         # redis exporter listen port, 9121 by default
redis_exporter_options: ''        # cli args and extra options for redis exporter
redis_safeguard: false            # prevent purging running redis instance?
redis_clean: true                 # purging existing redis during init?
redis_rmdata: true                # remove redis data when purging redis server?
redis_mode: standalone            # redis mode: standalone,cluster,sentinel
redis_conf: redis.conf            # redis config template path, except sentinel
redis_bind_address: '0.0.0.0'     # redis bind address, empty string will use host ip
redis_max_memory: 1GB             # max memory used by each redis instance
redis_mem_policy: allkeys-lru     # redis memory eviction policy
redis_password: ''                # redis password, empty string will disable password
redis_rdb_save: ['1200 1']        # redis rdb save directives, disable with empty list
redis_aof_enabled: false          # enable redis append only file?
redis_rename_commands: {}         # rename redis dangerous commands
redis_cluster_replicas: 1         # replica number for one master in redis cluster
```
