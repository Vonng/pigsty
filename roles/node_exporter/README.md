# Node Exporter (ansible role)

This role will install node_exporter on target nodes


### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Add yum repo for node_exporter	TAGS: [node-exporter, node-monitor, node_exporter, node_exporter_install]
Install node_exporter via yum	TAGS: [node-exporter, node-monitor, node_exporter, node_exporter_install]
Install node_exporter via binary	TAGS: [node-exporter, node-monitor, node_exporter, node_exporter_install]
Config node_exporter systemd unit	TAGS: [node-exporter, node-monitor, node_exporter, node_exporter_config]
Config default node_exporter options	TAGS: [node-exporter, node-monitor, node_exporter, node_exporter_config]
Launch node_exporter systemd unit	TAGS: [node-exporter, node-monitor, node_exporter, node_exporter_launch]
Wait for node_exporter online	TAGS: [node-exporter, node-monitor, node_exporter, node_exporter_launch]
Fetch hostname from server if no node name is given	TAGS: [node-exporter, node-monitor, node_exporter, node_register, register_prometheus]
Setup nodename according to hostname	TAGS: [node-exporter, node-monitor, node_exporter, node_register, register_prometheus]
Register node exporter as prometheus target	TAGS: [node-exporter, node-monitor, node_exporter, node_register, register_prometheus]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
#------------------------------------------------------------------------------
# NODE EXPORTER
#------------------------------------------------------------------------------
node_exporter_enabled: true      # setup node_exporter on instance
node_exporter_port: 9100         # default port for node exporter
node_exporter_options: '--no-collector.softnet --no-collector.nvme --collector.ntp --collector.tcpstat --collector.processes'

#------------------------------------------------------------------------------
# EXPORTER (REFERENCE)
#------------------------------------------------------------------------------
exporter_install: none           # none|yum|binary, none by default
exporter_repo_url: ''            # if set, repo will be added to /etc/yum.repos.d/ before yum installation
exporter_metrics_path: /metrics  # default metric path for pg related exporter
```