# Node Exporter (ansible role)

This role will install node_exporter on target nodes

### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Install exporter yum repo	TAGS: [exporter_install, exporter_yum_install, monitor, pgsql]
Install node_exporter and pg_exporter	TAGS: [exporter_install, exporter_yum_install, monitor, pgsql]
Copy exporter binaries	TAGS: [exporter_binary_install, exporter_install, monitor, pgsql]
Create /etc/pg_exporter conf dir	TAGS: [monitor, pg_exporter, pgsql]
Copy default pg_exporter.yaml	TAGS: [monitor, pg_exporter, pgsql]
Config /etc/default/pg_exporter	TAGS: [monitor, pg_exporter, pgsql]
Config pg_exporter service unit	TAGS: [monitor, pg_exporter, pgsql]
Launch pg_exporter systemd service	TAGS: [monitor, pg_exporter, pgsql]
Wait for pg_exporter service online	TAGS: [monitor, pg_exporter, pgsql]
Config pgbouncer_exporter opts	TAGS: [monitor, pgbouncer_exporter, pgsql]
Config pgbouncer_exporter service	TAGS: [monitor, pgbouncer_exporter, pgsql]
Launch pgbouncer_exporter service	TAGS: [monitor, pgbouncer_exporter, pgsql]
Wait for pgbouncer_exporter online	TAGS: [monitor, pgbouncer_exporter, pgsql]
Copy node_exporter systemd service	TAGS: [monitor, node_exporter, pgsql]
Config default node_exporter options	TAGS: [monitor, node_exporter, pgsql]
Launch node_exporter service unit	TAGS: [monitor, node_exporter, pgsql]
Wait for node_exporter online	TAGS: [monitor, node_exporter, pgsql]
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