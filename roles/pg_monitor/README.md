# Pgbouncer (ansible role)

This role will install monitor component on target hosts


### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
tasks:

```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
# default user/pass/db to monitor
pg_monitor_username: 'dbuser_monitor'
pg_monitor_password: 'dbuser_monitor'
default_database: 'postgres'

# default exporter settings
exporter_metric_path: "/metrics"
node_exporter_port: 9100
pg_exporter_port: 9630
pgbouncer_exporter_port: 9631
```