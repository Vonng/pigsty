# Redis Exporter (ansible role)

This role will install redis_exporter on target nodes

### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Add yum repo for redis_exporter	TAGS: [monitor, redis, redis-exporter, redis-monitor, redis_exporter, redis_exporter_install]
Install redis_exporter via yum	TAGS: [monitor, redis, redis-exporter, redis-monitor, redis_exporter, redis_exporter_install]
Install redis_exporter via binary	TAGS: [monitor, redis, redis-exporter, redis-monitor, redis_exporter, redis_exporter_install]
Config /etc/default/redis_exporter	TAGS: [monitor, redis, redis-exporter, redis-monitor, redis_exporter, redis_exporter_config]
Config redis_exporter service unit	TAGS: [monitor, redis, redis-exporter, redis-monitor, redis_exporter, redis_exporter_config]
Launch redis_exporter systemd service	TAGS: [monitor, redis, redis-exporter, redis-monitor, redis_exporter, redis_exporter_launch]
Wait for redis_exporter online	TAGS: [monitor, redis, redis-exporter, redis-monitor, redis_exporter, redis_exporter_launch]
Deregister redis exporter from prometheus	TAGS: [deregister_prometheus, monitor, redis, redis-exporter, redis-monitor, redis_deregister]
Register redis exporter as prometheus target	TAGS: [monitor, redis, redis-exporter, redis-monitor, redis_exporter, redis_register, register_prometheus]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
---
#-----------------------------------------------------------------
# REDIS_EXPORTER
#-----------------------------------------------------------------
redis_exporter_enabled: true    # install redis exporter on redis nodes ?
redis_exporter_port: 9121       # default port for redis exporter
redis_exporter_options: ''      # default cli args for redis exporter

#-----------------------------------------------------------------
# EXPORTER (Reference)
#-----------------------------------------------------------------
exporter_install: none           # none|yum|binary, none by default
exporter_repo_url: ''            # if set, repo will be added to /etc/yum.repos.d/ before yum installation
exporter_metrics_path: /metrics  # default metric path for pg related exporter

#-----------------------------------------------------------------
# DCS (Reference)
#-----------------------------------------------------------------
dcs_registry: consul          # where to register services: none | consul | etcd | both
...
```