# Redis (Ansible role)

Deploy redis on target hosts

## Tasks

```tasks
redis : Install extra yum repo for redis	TAGS: [redis, redis_install, redis_node]
redis : Install redis via yum	TAGS: [redis, redis_install, redis_node]
redis : Install redis via binaries	TAGS: [redis, redis_install, redis_node]
redis : Install redis monitor via yum	TAGS: [redis, redis_monitor_install, redis_node]
redis : Install redis monitor via binaries	TAGS: [redis, redis_monitor_install, redis_node]
redis : Create user redis	TAGS: [redis, redis_node, redis_user]
redis : Make sure fs main dir exists	TAGS: [redis, redis_dir, redis_node]
redis : Make sure redis data dir exists	TAGS: [redis, redis_dir, redis_node]
redis : Render redis systemd service template	TAGS: [redis, redis_node, redis_systemd]
redis : Render redis-sentinel systemd service template	TAGS: [redis, redis_node, redis_systemd]
redis : Reload systemd daemon	TAGS: [redis, redis_node, redis_systemd]
redis : Install node_exporter & redis_exporter	TAGS: [exporter_install, redis, redis_monitor, redis_node]
redis : Copy node_exporter systemd service	TAGS: [node_exporter, redis, redis_monitor, redis_node]
redis : Config default node_exporter options	TAGS: [node_exporter, redis, redis_monitor, redis_node]
redis : Launch node_exporter service unit	TAGS: [node_exporter, redis, redis_monitor, redis_node]
redis : Wait for node_exporter online	TAGS: [node_exporter, redis, redis_monitor, redis_node]
redis : Config /etc/default/redis_exporter	TAGS: [redis, redis_exporter, redis_monitor, redis_node]
redis : Config redis_exporter service unit	TAGS: [redis, redis_exporter, redis_monitor, redis_node]
redis : Launch redis_exporter systemd service	TAGS: [redis, redis_exporter, redis_monitor, redis_node]
redis : Wait for redis_exporter service online	TAGS: [redis, redis_exporter, redis_monitor, redis_node]
redis : Check necessary variables exists	TAGS: [redis, redis_ins]
include_tasks	TAGS: [redis, redis_ins]
redis : Fetch redis cluster memberships	TAGS: [redis, redis_ins, redis_join]
redis : Render redis cluster join script	TAGS: [redis, redis_ins, redis_join]
redis : Join redis clusters	TAGS: [redis, redis_ins, redis_join]
redis : Register redis instance as prometheus target	TAGS: [redis, redis_ins, redis_register, register_prometheus]
```

## Defaults

```yaml
# - identity - #
# redis_cluster: redis-test         # name of this redis 'cluster' , cluster level
# redis_node: 1                     # id of this redis node, integer sequence @ instance level
# redis_instances: {}               # redis instance list on this redis node @ instance level

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
```

## Examples

```yaml
#----------------------------------#
# sentinel example                 #
#----------------------------------#
redis-sentinel:
  hosts:
    10.10.10.10:
      redis_node: 1
      redis_instances:  { 6001 : {} ,6002 : {} , 6003 : {} }
  vars:
    redis_cluster: redis-sentinel
    redis_mode: sentinel
    redis_max_memory: 128MB

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

#----------------------------------#
# standalone example               #
#----------------------------------#
redis-standalone:
  hosts:
    10.10.10.13:
      redis_node: 1
      redis_instances:
        6501: {}
        6502: { replica_of: '10.10.10.13 6501' }
        6503: { replica_of: '10.10.10.13 6501' }
  vars:
    redis_cluster: redis-standalone     # name of this redis 'cluster'
    redis_mode: standalone              # standalone,cluster,sentinel
    redis_max_memory: 64MB              # max memory used by each redis instance
```