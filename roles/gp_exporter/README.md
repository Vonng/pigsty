# PG Exporter Extra (ansible role)

This role will setup extra pg_exporter on target hosts


### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Add yum repo for pg_exporter	TAGS: [pg_exporter, pg_exporter_install, pgsql]
Install pg_exporter via yum	TAGS: [pg_exporter, pg_exporter_install, pgsql]
Install pg_exporter via binary	TAGS: [pg_exporter, pg_exporter_install, pgsql]
Create /etc/pg_exporter conf dir	TAGS: [pg_exporter, pg_exporter_config, pgsql]
Copy default pg_exporter.yml config	TAGS: [pg_exporter, pg_exporter_config, pgsql]
Config pg_exporter parameters	TAGS: [pg_exporter, pg_exporter_config, pgsql]
Config pg_exporter systemd unit	TAGS: [pg_exporter, pg_exporter_config, pgsql]
Config pgbouncer_exporter parameters	TAGS: [pg_exporter, pg_exporter_config, pgsql]
Config pgbouncer_exporter systemd unit	TAGS: [pg_exporter, pg_exporter_config, pgsql]
Launch pg_exporter systemd unit	TAGS: [pg_exporter, pg_exporter_launch, pgsql]
Wait for pg_exporter online	TAGS: [pg_exporter, pg_exporter_launch, pgsql]
Launch pgbouncer_exporter systemd unit	TAGS: [pg_exporter, pgbouncer_exporter_launch, pgsql]
Wait for pgbouncer_exporter online	TAGS: [pg_exporter, pgbouncer_exporter_launch, pgsql]
Deregister pgssql exporter from prometheus	TAGS: [pg_deregister, pg_exporter, pgsql]
Register pgsql exporter as prometheus target	TAGS: [pg_exporter, pg_register, pgsql]
```


### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
---
#------------------------------------------------------------------------------
# PG Exporter
#------------------------------------------------------------------------------
# - install - #
exporter_install: none                        # none|yum|binary, none by default
exporter_repo_url: ''                         # if set, repo will be added to /etc/yum.repos.d/ before yum installation

# - collect - #
exporter_metrics_path: /metrics               # default metric path for pg related exporter

# - pg exporter - #
pg_exporter_config: pg_exporter.yml           # default config files for pg_exporter
pg_exporter_enabled: true                     # setup pg_exporter on instance
pg_exporter_port: 9630                        # default port for pg exporter
pg_exporter_params: 'sslmode=disable'         # url query parameters for pg_exporter
pg_exporter_url: ''                           # optional, if not set, generate from reference parameters
pg_exporter_auto_discovery: true              # optional, discovery available database on target instance ?
pg_exporter_exclude_database: 'template0,template1,postgres' # optional, comma separated list of database that WILL NOT be monitored when auto-discovery enabled
pg_exporter_include_database: ''                             # optional, comma separated list of database that WILL BE monitored when auto-discovery enabled, empty string will disable include mode
pg_exporter_options: '--log.level=info --log.format="logger:syslog?appname=pg_exporter&local=7"'

# - pgbouncer exporter - #
pgbouncer_exporter_enabled: true              # setup pgbouncer_exporter on instance (if you don't have pgbouncer, disable it)
pgbouncer_exporter_port: 9631                 # default port for pgbouncer exporter
pgbouncer_exporter_url: ''                    # optional, if not set, generate from reference parameters
pgbouncer_exporter_options: '--log.level=info --log.format="logger:syslog?appname=pgbouncer_exporter&local=7"'

# - postgres variables reference - #
pg_dbsu: postgres                             # who will run these exporters ?
pg_port: 5432                                 # pg_exporter target port
pgbouncer_port: 6432                          # pgbouncer_exporter target port
pg_localhost: /var/run/postgresql             # access via unix socket
pg_monitor_username: dbuser_monitor           # default monitor username
pg_monitor_password: DBUser.Monitor           # default monitor password
...
```