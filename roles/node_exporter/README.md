# Node Exporter (ansible role)

This role will install node_exporter on target nodes

### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Add yum repo for node_exporter	TAGS: [infra, node_exporter, node_exporter_install]
Install node_exporter via yum	TAGS: [infra, node_exporter, node_exporter_install]
Install node_exporter via binary	TAGS: [infra, node_exporter, node_exporter_install]
Config node_exporter systemd unit	TAGS: [infra, node_exporter, node_exporter_config]
Config default node_exporter options	TAGS: [infra, node_exporter, node_exporter_config]
Launch node_exporter systemd unit	TAGS: [infra, node_exporter, node_exporter_launch]
Wait for node_exporter online	TAGS: [infra, node_exporter, node_exporter_launch]
Deregister node exporter from prometheus	TAGS: [infra, node_deregister, node_exporter]
Register node exporter as prometheus target	TAGS: [infra, node_exporter, node_register]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
#------------------------------------------------------------------------------
# Node Exporter
#------------------------------------------------------------------------------
# - install - #
exporter_install: none                        # none|yum|binary, none by default

# - collect - #
exporter_metrics_path: /metrics               # default metric path for exporter

# - node exporter - #
node_exporter_enabled: true                   # setup node_exporter on instance
node_exporter_port: 9100                      # default port for node exporter
node_exporter_options: '--no-collector.softnet --collector.systemd --collector.ntp --collector.tcpstat --collector.processes'
```