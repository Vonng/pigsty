# Redis (Ansible role)

Deploy redis on target hosts

## Tasks

```tasks
redis : Check node has redis_cluster defined	TAGS: [redis]
redis : Copy redis binaries	TAGS: [redis, redis_install, redis_node]
redis : Create user redis	TAGS: [redis, redis_node, redis_user]
redis : Make sure fs main dir exists	TAGS: [redis, redis_dir, redis_node]
redis : Make sure redis data dir exists	TAGS: [redis, redis_dir, redis_node]
redis : Render redis systemd service template	TAGS: [redis, redis_node, redis_systemd, renew]
redis : Reload systemd daemon	TAGS: [redis, redis_node, redis_systemd, renew]
redis : Install node_exporter & redis_exporter	TAGS: [exporter_install, redis, redis_monitor]
redis : Copy node_exporter systemd service	TAGS: [node_exporter, redis, redis_monitor]
redis : Config default node_exporter options	TAGS: [node_exporter, redis, redis_monitor]
redis : Launch node_exporter service unit	TAGS: [node_exporter, redis, redis_monitor]
redis : Wait for node_exporter online	TAGS: [node_exporter, redis, redis_monitor]
redis : Config /etc/default/redis_exporter	TAGS: [redis, redis_exporter, redis_monitor]
redis : Config redis_exporter service unit	TAGS: [redis, redis_exporter, redis_monitor]
redis : Launch redis_exporter systemd service	TAGS: [redis, redis_exporter, redis_monitor]
redis : Wait for redis_exporter service online	TAGS: [redis, redis_exporter, redis_monitor]
redis : Check necessary variables exists	TAGS: [redis]
redis : Render redis instance config	TAGS: [redis, redis_config]
redis : Create redis instance data dir	TAGS: [redis, redis_config]
include_tasks	TAGS: [redis, redis_launch, redis_launch_primary]
include_tasks	TAGS: [redis, redis_launch, redis_launch_replica, reload]
redis : Register redis instance as prometheus target	TAGS: [redis, redis_register, register_prometheus]
```

## Defaults

```yaml
---
# - identity - #
# redis_cluster:                    # name of this redis 'cluster' , cluster level
# redis_node:                       # id of this redis node, integer sequence
# redis_instances:                  # redis instance list on this redis node

# - config - #
redis_mode: standalone              # standalone,cluster,sentinel
redis_conf: redis.conf              # which config template will be used
redis_fs_main: /data                # main data disk for redis
redis_bind_address: '0.0.0.0'       # e.g 0.0.0.0, empty will use inventory_hostname as bind address
redis_max_memory: 1GB               # max memory used by each redis instance
redis_mem_policy: allkeys-lru       # memory eviction policy
redis_password: ''                  # empty password disable password auth (masterauth & requirepass)
redis_rdb_save: ['1200 1']          # redis RDB save directives, empty list disable it
redis_aof_enabled: false            # enable redis AOF
redis_rename_commands: {}           # rename dangerous commands
  # flushall: opflushall
  # flushdb: opflushdb
  # keys: opkeys

# - redis exporter - #
redis_exporter_enabled: true        # install redis exporter on redis nodes
redis_exporter_port: 9121           # default port for redis exporter
redis_exporter_options: ''          # default cli args for redis exporter

# - node exporter - #
node_exporter_enabled: true                   # setup node_exporter on instance
node_exporter_port: 9100                      # default port for node exporter
node_exporter_options: '--no-collector.softnet --collector.systemd --collector.ntp --collector.tcpstat --collector.processes'

# - reference - #
exporter_install: none              # none|yum|binary, none by default
exporter_repo_url: ''               # if set, repo will be added to /etc/yum.repos.d/ before yum installation
exporter_metrics_path: /metrics     # default metric path for pg related exporter
service_registry: consul
...
```

## Examples

```yaml

#----------------------------------#
# cluster: redis-meta              #
#----------------------------------#
redis-meta:
  hosts:
    10.10.10.10: {redis_node: 1 , redis_instances: {16379: { port: 6379 } }}
  vars:
    redis_cluster: redis-meta           # name of this redis cluster


#----------------------------------#
# cluster: redis-test              #
#----------------------------------#
redis-test:
  hosts:
    10.10.10.11:
      redis_node: 1
      redis_instances:
        16501: { port: 6501 }
        16502: { port: 6502 , replica_of: '10.10.10.11 6501'}
        16503: { port: 6503 , replica_of: '10.10.10.11 6501'}
    10.10.10.12:
      redis_node: 2
      redis_instances:
        26501: { port: 6501 }
        26502: { port: 6502 , replica_of: '10.10.10.12 6501' }
        26503: { port: 6503 , replica_of: '10.10.10.12 6501' }
    10.10.10.13:
      redis_node: 3
      redis_instances:
        36501: { port: 6501 }
        36502: { port: 6502 , replica_of: '10.10.10.13 6501'}
        36503: { port: 6503 , replica_of: '10.10.10.13 6501' }
  vars:
    redis_cluster: redis-test           # name of this redis 'cluster'
    redis_mode: standalone              # standalone,cluster,sentinel
    redis_conf_template: redis.conf     # which config template will be used
    redis_fs_main: /data                # main data disk for redis
    redis_bind_address: '0.0.0.0'       # e.g 0.0.0.0, empty will use inventory_hostname as bind address
    redis_max_memory: 1GB               # max memory used by each redis instance
    redis_mem_policy: allkeys-lru       # memory eviction policy
    redis_password: ''                  # empty password disable password auth (masterauth & requirepass)
    redis_rdb_save: ['1200 1']          # redis RDB save directives, empty list disable it
    redis_aof_enabled: false            # enable redis AOF
    redis_rename_commands:              # rename dangerous commands
      flushall: opflushall
      flushdb: opflushdb
      keys: opkeys
```