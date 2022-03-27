# Monitoring System

Pigsty's monitoring system contains two agents: **Node Exporter** , **PG Exporter**

Node Exporter is used to expose monitoring metrics for machine nodes, and PG Exporter is used to pull monitoring metrics for database and Pgbouncer connection pools; in addition, Haproxy will **directly** expose monitoring metrics to the public through the management port.

By default, all monitoring Exporter will be registered to Consul and Prometheus will manage these tasks by default through static file service discovery.
However, users can change to Consul service discovery by configuring [`prometheus_sd_method`](v-meta.md/#prometheus_sd_method) to `consul`.

Promtail is used to collect Postgres, Patroni, and Pgbouncer logs and is an optional extra component to install.

## Overview

|                            Name                             |    Type    | Level  | Description |
| :----------------------------------------------------------: | :--------: | :---: | ---- |
|       [exporter_install](v-monitor.md#exporter_install)        |  `enum`  |  G/C  | how to install exporter? |
|      [exporter_repo_url](v-monitor.md#exporter_repo_url)       |  `string`  |  G/C  | repo url for yum install |
|  [exporter_metrics_path](v-monitor.md#exporter_metrics_path)   |  `string`  |  G/C  | URL path for exporting metrics |
|  [node_exporter_enabled](v-monitor.md#node_exporter_enabled)   |  `bool`  |  G/C  | node_exporter enabled? |
|     [node_exporter_port](v-monitor.md#node_exporter_port)      |  `number`  |  G/C  | node_exporter listen port |
|  [node_exporter_options](v-monitor.md#node_exporter_options)   |  `string`  |  G/C  | node_exporter extra cli args |
|     [pg_exporter_config](v-monitor.md#pg_exporter_config)      |  `string`  |  G/C  | pg_exporter config path |
|    [pg_exporter_enabled](v-monitor.md#pg_exporter_enabled)     |  `bool`  |  G/C  | pg_exporter enabled ? |
|       [pg_exporter_port](v-monitor.md#pg_exporter_port)        |  `number`  |  G/C  | pg_exporter listen address |
|        [pg_exporter_url](v-monitor.md#pg_exporter_url)         |  `string`  |  G/C  | monitor target pgurl (overwrite) |
|[pg_exporter_auto_discovery](v-monitor.md#pg_exporter_auto_discovery)     |  `bool`    |  G/C  | enable auto-database-discovery? |
|[pg_exporter_exclude_database](v-monitor.md#pg_exporter_exclude_database) |  `string`  |  G/C  | excluded list of databases |
|[pg_exporter_include_database](v-monitor.md#pg_exporter_include_database) |  `string`  |  G/C  | included list of databases |
| [pgbouncer_exporter_enabled](v-monitor.md#pgbouncer_exporter_enabled) |  `bool`  |  G/C  | pgbouncer_exporter enabled ? |
| [pgbouncer_exporter_port](v-monitor.md#pgbouncer_exporter_port) |  `number`  |  G/C  | pgbouncer_exporter listen addr? |
| [pgbouncer_exporter_url](v-monitor.md#pgbouncer_exporter_url)  |  `string`  |  G/C  | target pgbouncer url (overwrite) |
| [promtail_enabled](v-monitor.md#promtail_enabled)  |  `bool`  |  G/C  | promtail enabled ? |
| [promtail_clean](v-monitor.md#promtail_clean)  |  `bool`  |  G/C/A  | remove promtail status file ? |
| [promtail_port](v-monitor.md#promtail_port)  |  `number`  |  G/C  | promtail listen port |
| [promtail_status_path](v-monitor.md#promtail_status_path)  |  `string`  |  G/C  | path to store promtail status file |
| [loki_endpoint](v-monitor.md#loki_endpoint)  |  `string`  |  G/C  | loki endpoint to receive log |



## Defaults

```yaml
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
node_exporter_options: '--no-collector.softnet --no-collector.nvme --collector.ntp --collector.tcpstat --collector.processes'

# - pg exporter - #
pg_exporter_config: pg_exporter.yml           # default config files for pg_exporter
pg_exporter_enabled: true                     # setup pg_exporter on instance
pg_exporter_port: 9630                        # default port for pg exporter
pg_exporter_url: ''                           # optional, if not set, generate from reference parameters
pg_exporter_auto_discovery: true              # optional, discovery available database on target instance ?
pg_exporter_exclude_database: 'template0,template1,postgres' # optional, comma separated list of database that WILL NOT be monitored when auto-discovery enabled
pg_exporter_include_database: ''             # optional, comma separated list of database that WILL BE monitored when auto-discovery enabled, empty string will disable include mode
pg_exporter_options: '--log.level=info --log.format="logger:syslog?appname=pg_exporter&local=7"'

# - pgbouncer exporter - #
pgbouncer_exporter_enabled: true              # setup pgbouncer_exporter on instance (if you don't have pgbouncer, disable it)
pgbouncer_exporter_port: 9631                 # default port for pgbouncer exporter
pgbouncer_exporter_url: ''                    # optional, if not set, generate from reference parameters
pgbouncer_exporter_options: '--log.level=info --log.format="logger:syslog?appname=pgbouncer_exporter&local=7"'

# - promtail - #                              # promtail is a beta feature which requires manual deployment
promtail_enabled: true                        # enable promtail logging collector?
promtail_clean: false                         # remove promtail status file? false by default
promtail_port: 9080                           # default listen address for promtail
promtail_status_file: /tmp/promtail-status.yml
loki_endpoint: http://10.10.10.10:3100/loki/api/v1/push  # loki url to receive logs
```





## Parameter details

### exporter_install

Specifies how to install the Exporter.

* `none`: no install, (default behavior, Exporter has been previously installed by the `node.pkgs` task)
* `yum`: install using yum (if yum installation is enabled, run yum to install `node_exporter` and `pg_exporter` before deploying Exporter)
* `binary`: install using copy binary (copy `node_exporter` and `pg_exporter` binaries directly from `files`)

When installing with `yum`, if `exporter_repo_url` is specified (not empty), the installation will first install the REPO file under that URL into `/etc/yum.repos.d`. This feature allows you to install Exporter directly without initializing the node infrastructure.

When installing with `binary`, the user needs to make sure that the Linux binaries for `node_exporter` and `pg_exporter` have been placed in the `files` directory.

```bash
<meta>:<pigsty>/files/node_exporter -> <target>:/usr/bin/node_exporter
<meta>:<pigsty>/files/pg_exporter -> <target>:/usr/bin/pg_exporter
```



### exporter_binary_install (deprecated)

**This parameter is overridden by the [`expoter_install`](#exporter_install) parameter**

Whether to install Node Exporter and PG Exporter by copying binaries, default is `false`

This option is mainly used to reduce the working assumptions on the legacy system when integrating external provisioning solutions. Enabling this option will copy the Linux binaries directly to the target machine.

```
<meta>:<pigsty>/files/node_exporter -> <target>:/usr/bin/node_exporter
<meta>:<pigsty>/files/pg_exporter -> <target>:/usr/bin/pg_exporter
```

Users need to download the Linux binary from Github via `files/download-exporter.sh` to the `files` directory to enable this option.



### exporter_metrics_path

URL PATH of all Exporter exposed metrics, default is `/metrics`.

This variable is referenced by the external actor `prometheus`, which will apply this configuration to the `job = pg` monitoring object based on the configuration here.



### node_exporter_enabled

Whether to install and configure `node_exporter`, default is `true`



### node_exporter_port

Port that `node_exporter` listens on

Default port `9100`



### node_exporter_options

Additional command line options used by `node_exporter`.

This option is mainly used to customize the metric collectors enabled by `node_exporter`. A list of collectors supported by Node Exporter can be found at: [Node Exporter Collectors](https://github.com/prometheus/node_exporter# collectors)

The default value of this option is

```yaml
node_exporter_options: '--no-collector.softnet --collector.systemd --collector.ntp --collector.tcpstat --collector.processes'
```



### pg_exporter_config

The default configuration file used by `pg_exporter` defines the metrics in Pigsty.

Pigsty provides two configuration files by default.

* `pg_exporter-demo.yaml` for the sandbox demo environment, with a lower cache TTL (1s) and better monitoring in real time, but with a bigger performance hit.

* `pg_exporter.yaml`, for production environments, has a normal caching TTL (10s) and significantly reduces the load of multiple Prometheus simultaneous crawls.

It is recommended to check and adjust the `pg_exporter` configuration file if the user has a different Prometheus architecture.

The PG Exporter configuration file used by Pigsty is supported by default since PostgreSQL 10.0 and is currently supported up to the latest PG 13 version



### pg_exporter_enabled

Whether to install and configure `pg_exporter`, default is `true`



### pg_exporter_url

PG URL used by PG Exporter to connect to the database

Optional parameter, defaults to an empty string.

Pigsty generates the target URL for monitoring by default using the following rules, and if the `pg_exporter_url` option is configured, it will be used directly as the connection string.

```bash
PG_EXPORTER_URL='postgres://{{ pg_monitor_username }}:{{ pg_monitor_password }}@:{{ pg_port }}/{{ pg_default_database }}?host={{ pg_ localhost }}&sslmode=disable'
```

This option is configured as an environment variable in `/etc/default/pg_exporter`.



### pg_exporter_auto_discovery

New feature after PG Exporter v0.4: Enable automatic database discovery, which is enabled by default.

When enabled, PG Exporter automatically detects changes to the list of databases in the target instance and creates a crawl connection for each database

When turned off, monitoring of objects in the library is not available. (You can turn this feature off if you do not want to expose business-related data in the monitoring system)

! > Note that if you have many databases (100+), or a very large number of objects in the database (several k, a dozen), please carefully evaluate the overhead incurred by object monitoring.



### pg_exporter_exclude_database

Comma-separated list of database names

When automatic database discovery is enabled, the databases in this list are not monitored.



### pg_exporter_include_database

Comma-separated list of database names

When automatic database discovery is enabled, databases not in this list are not monitored.



### pgbouncer_exporter_enabled

Whether to install and configure `pgbouncer_exporter`, default is `true`



### pg_exporter_port

The port that `pg_exporter` listens on

Default port `9630`



### pgbouncer_exporter_port

Port on which `pgbouncer_exporter` listens

Default port `9631`



### pgbouncer_exporter_url

URL used by the PGBouncer Exporter to connect to the database

Optional parameter, defaults to an empty string.

Pigsty generates the target URL for monitoring by default using the following rules, if the `pgbouncer_exporter_url` option is configured, this URL will be used directly as the connection string.

```bash
PG_EXPORTER_URL='postgres://{{ pg_monitor_username }}:{{ pg_monitor_password }}@:{{ pgbouncer_port }}/pgbouncer?host={{ pg_localhost }}& sslmode=disable'
```

This option is configured as an environment variable in `/etc/default/pgbouncer_exporter`.



### promtail_enabled

Boolean type, global｜cluster variable, is promtail log collection service enabled? Enabled by default.
But note that Loki and Promtail are currently optional modules and will not be installed in the Monitor section of `pgsql.yml`, but will only be used in the `pgsql-promtail.yml` script for now.



### promtail_clean

Boolean type, command line argument.

Does it remove existing status information when installing promtail? The status file is recorded in [`promtail_status_file`](#promtail_status_file), which records all log consumption offsets and is not cleared by default.



### promtail_port

The default port used by promtail, default is 9080



### promtail_status_file

String type, cluster｜global variable, content is the location of the file where promtail status information is stored, default is `/ptmp/promtail-status.yml`.



### loki_endpoint

HTTP URL to receive logs for the loki service endpoint

