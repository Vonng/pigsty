# Node Register (ansible role)

This role will register node_exporter & docker


### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Deregister node exporter from prometheus	TAGS: [deregister_prometheus, node-monitor, node-register, node_deregister]
Fetch hostname from server if no node name is given	TAGS: [node-monitor, node-register, node_register, register_prometheus]
Setup nodename according to hostname	TAGS: [node-monitor, node-register, node_register, register_prometheus]
Register node exporter as prometheus target	TAGS: [node-monitor, node-register, node_exporter, node_register, register_prometheus]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
```