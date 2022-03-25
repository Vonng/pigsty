# Redis (Ansible role)

Deploy redis on target hosts

## Tasks

```tasks
Install redis via yum	TAGS: [redis, redis-setup, redis_install]
Create user redis	TAGS: [redis, redis-setup, redis_install, redis_user]
Make sure fs main dir exists	TAGS: [redis, redis-setup, redis_dir, redis_install]
Make sure redis data dir exists	TAGS: [redis, redis-setup, redis_dir, redis_install]
Check necessary variables exists	TAGS: [redis, redis-setup, redis_ins]

include_tasks	TAGS: [redis, redis-setup, redis_ins]

Fetch redis cluster memberships	TAGS: [redis, redis-setup, redis_join]
Render redis cluster join script	TAGS: [redis, redis-setup, redis_join]
Join redis clusters	TAGS: [redis, redis-setup, redis_join]
```

## Defaults

```yaml
---
# - identity - #
# redis_cluster: redis-test         # name of this redis cluster @ cluster level
# redis_node: 1                     # redis node identifier, integer sequence @ node level
# redis_instances: {}               # redis instances definition of this redis node @ node level

# - install - #
redis_install: yum                  # none|yum|binary, yum by default (install from yum repo)

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

# - reference - #
service_registry: consul            # which service registry to be used
...
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