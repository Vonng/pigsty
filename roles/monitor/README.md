# Monitor (ansible role)

This role will install monitor component on target hosts
* Install exporters
* node_exporter
* pg_exporter
* pgbouncer_exporter

### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
tasks:
  postgres : Check necessary variables exists	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
  postgres : Fetch variables via pg_cluster	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
  postgres : Set cluster basic facts for hosts	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
  postgres : Assert cluster primary singleton	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
  postgres : Setup cluster primary ip address	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
  postgres : Setup repl upstream for primary	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
  postgres : Setup repl upstream for replicas	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
  postgres : Debug print instance summary	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
  monitor : Install exporter yum repo	TAGS: [exporter_install, exporter_yum_install, monitor, pgsql]
  monitor : Install node_exporter and pg_exporter	TAGS: [exporter_install, exporter_yum_install, monitor, pgsql]
  monitor : Copy node_exporter binary	TAGS: [exporter_binary_install, exporter_install, monitor, pgsql]
  monitor : Copy pg_exporter binary	TAGS: [exporter_binary_install, exporter_install, monitor, pgsql]
  monitor : Create /etc/pg_exporter conf dir	TAGS: [monitor, pg_exporter, pgsql]
  monitor : Copy default pg_exporter.yaml	TAGS: [monitor, pg_exporter, pgsql]
  monitor : Config /etc/default/pg_exporter	TAGS: [monitor, pg_exporter, pgsql]
  monitor : Config pg_exporter service unit	TAGS: [monitor, pg_exporter, pgsql]
  monitor : Launch pg_exporter systemd service	TAGS: [monitor, pg_exporter, pgsql]
  monitor : Wait for pg_exporter service online	TAGS: [monitor, pg_exporter, pgsql]
  monitor : Register pg-exporter consul service	TAGS: [monitor, pg_exporter_register, pgsql]
  monitor : Reload pg-exporter consul service	TAGS: [monitor, pg_exporter_register, pgsql]
  monitor : Config pgbouncer_exporter opts	TAGS: [monitor, pgbouncer_exporter, pgsql]
  monitor : Config pgbouncer_exporter service	TAGS: [monitor, pgbouncer_exporter, pgsql]
  monitor : Launch pgbouncer_exporter service	TAGS: [monitor, pgbouncer_exporter, pgsql]
  monitor : Wait for pgbouncer_exporter online	TAGS: [monitor, pgbouncer_exporter, pgsql]
  monitor : Register pgb-exporter consul service	TAGS: [monitor, node_exporter_register, pgsql]
  monitor : Reload pgb-exporter consul service	TAGS: [monitor, node_exporter_register, pgsql]
  monitor : Copy node_exporter systemd service	TAGS: [monitor, node_exporter, pgsql]
  monitor : Config default node_exporter options	TAGS: [monitor, node_exporter, pgsql]
  monitor : Launch node_exporter service unit	TAGS: [monitor, node_exporter, pgsql]
  monitor : Wait for node_exporter online	TAGS: [monitor, node_exporter, pgsql]
  monitor : Register node-exporter service to consul	TAGS: [monitor, node_exporter_register, pgsql]
  monitor : Reload node-exporter consul service	TAGS: [monitor, node_exporter_register, pgsql]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
---
#------------------------------------------------------------------------------
# MONITOR PROVISION
#------------------------------------------------------------------------------
# - install - #
exporter_install: none                        # none|yum|binary, none by default
exporter_repo_url: ''                         # if set, repo will be added to /etc/yum.repos.d/ before yum installation

# - collect - #
exporter_metrics_path: /metrics               # default metric path for pg related exporter

# - node exporter - #
node_exporter_enabled: true                   # setup node_exporter on instance
node_exporter_port: 9100                      # default port for node exporter
node_exporter_options: '--no-collector.softnet --collector.systemd --collector.ntp --collector.tcpstat --collector.processes'

# - pg exporter - #
pg_exporter_config: pg_exporter-demo.yaml     # default config files for pg_exporter
pg_exporter_enabled: true                     # setup pg_exporter on instance
pg_exporter_port: 9630                        # default port for pg exporter
pg_exporter_url: ''                           # optional, if not set, generate from reference parameters

# - pgbouncer exporter - #
pgbouncer_exporter_enabled: true              # setup pgbouncer_exporter on instance (if you don't have pgbouncer, disable it)
pgbouncer_exporter_port: 9631                 # default port for pgbouncer exporter
pgbouncer_exporter_url: ''                    # optional, if not set, generate from reference parameters

# - postgres variables reference - #
pg_dbsu: postgres
pg_port: 5432                                 # postgres port (5432 by default)
pgbouncer_port: 6432                          # pgbouncer port (6432 by default)
pg_localhost: /var/run/postgresql             # localhost unix socket dir for connection
pg_default_database: postgres                 # default database will be used as primary monitor target
pg_monitor_username: dbuser_monitor           # system monitor username, for postgres and pgbouncer
pg_monitor_password: DBUser.Monitor           # system monitor user's password
service_registry: consul                      # none | consul | etcd | both
...
```