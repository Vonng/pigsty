# Redis Exporter (ansible role)

This role will install redis_exporter on target nodes

### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Add yum repo for redis_exporter	TAGS: [monitor, redis_exporter, redis_exporter_install]
Install redis_exporter via yum	TAGS: [monitor, redis_exporter, redis_exporter_install]
Install redis_exporter via binary	TAGS: [monitor, redis_exporter, redis_exporter_install]
Config /etc/default/redis_exporter	TAGS: [monitor, redis_exporter, redis_exporter_config]
Config redis_exporter service unit	TAGS: [monitor, redis_exporter, redis_exporter_config]
Launch redis_exporter systemd service	TAGS: [monitor, redis_exporter, redis_exporter_launch]
Wait for redis_exporter online	TAGS: [monitor, redis_exporter, redis_exporter_launch]
Deregister redis exporter from prometheus	TAGS: [monitor, redis_deregister, redis_exporter]
Register redis exporter as prometheus target	TAGS: [monitor, redis_exporter, redis_register]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
---
#------------------------------------------------------------------------------
# Redis Exporter
#------------------------------------------------------------------------------
# - install - #
exporter_install: none              # none|yum|binary, none by default
exporter_repo_url: ''               # if set, repo will be added to /etc/yum.repos.d/ before yum installation
exporter_metrics_path: /metrics     # default metric path for exporter
service_registry: consul            # which service registry to be used

# - redis exporter - #
redis_exporter_enabled: true        # install redis exporter on redis nodes ?
redis_exporter_port: 9121           # default port for redis exporter
redis_exporter_options: ''          # default cli args for redis exporter
...
```