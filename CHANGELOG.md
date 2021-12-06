# v1.3.1 

* [FEATURE] `demo.yml` playbook for one-pass initialization
* [FEATURE] `pg` alias on meta nodes to initiate control on pg clusters
* [BUG FIX] fix `pg_instance` & `pg_service` in `register` role when start from middle of playbook
* [CHANGE] Change default parameters for all patroni templates
  * reduce `max_locks_per_transactions` to proper value 
  * add `citus.node_conninfo: 'sslmode=prefer'` for all citus nodes
* [UPGRADE] Software upgrade:
  * add all extensions from pgdg14 repo
  * node_exporter: 1.3.0 
  * grafana: 8.3.0



# 1.3.0

* [ENHANCEMENT] Redis Deployment (cluster,sentinel,standalone)
* [ENHANCEMENT] Redis Monitor
  * Redis Overview Dashboard
  * Redis Cluster Dashboard
  * Redis Instance Dashboard

* [ENHANCEMENT] monitor: PGCAT Overhaul 
  * New Dashboard: PGCAT Instance 
  * New Dashboard: PGCAT Database Dashboard
  * Remake Dashboard: PGCAT Table

* [ENHANCEMENT] monitor: PGSQL Enhancement
  * New Panels: PGSQL Cluster, add 10 key metrics panel (toggled by default) 
  * New Panels: PGSQL Instance, add 10 key metrics panel (toggled by default)
  * Simplify & Redesign: PGSQL Service
  * Add cross-references between PGCAT & PGSL dashboards

* [ENHANCEMENT] monitor deploy 
  * Now grafana datasource is automatically registered during monly deployment

* [ENHANCEMENT] software upgrade
  * add PostgreSQL 13 to default package list
  * upgrade to PostgreSQL 14.1 by default
  * add greenplum rpm and dependencies
  * add redis rpm & source packages
  * add perf as default packages


# v1.2.0
 
* [ENHANCEMENT] Use PostgreSQL 14 as default version
* [ENHANCEMENT] Use TimescaleDB 2.5 as default extension
  * now timescaledb & postgis are enabled in cmdb by default
* [ENHANCEMENT] new monitor-only mode: 
  * you can use pigsty to monitor existing pg instances with a connectable url only
  * pg_exporter will be deployed on meta node locally
  * new dashboard PGSQL Cluster Monly for remote clusters
* [ENHANCEMENT] Software upgrade
  * grafana to 8.2.2
  * pev2 to v0.11.9
  * promscale to 0.6.2
  * pgweb to 0.11.9
  * Add new extensions: pglogical pg_stat_monitor orafce 
* [ENHANCEMENT] Automatic detect machine spec and use proper `node_tune` and `pg_conf` templates 
* [ENHANCEMENT] Rework on bloat related views, now more information are exposed
* [ENHANCEMENT] Remove timescale & citus internal monitoring
* [ENHANCEMENT] New playbook `pgsql-audit.yml` to create audit report.
* [BUG FIX] now pgbouncer_exporter resource owner are {{ pg_dbsu }} instead of postgres
* [BUG FIX] fix pg_exporter duplicate metrics on pg_table pg_index while executing `REINDEX TABLE CONCURRENTLY`
* [CHANGE] now all config templates are minimize into two: auto & demo. (removed: `pub4, pg14, demo4, tiny, oltp` ) 
  * `pigsty-demo` is configured if `vagrant` is the default user, otherwise `pigsty-auto` is used.


**How to upgrade from v1.1.1**

There's no API change in 1.2.0 You can still use old `pigsty.yml` configuration files (PG13).

For the infrastructure part. Re-execution of `repo` will do most of the parts

As for the database. You can still use the existing PG13 instances. In-place upgrade is quite
tricky especially when involving extensions such as PostGIS & Timescale. I would highly recommend
performing a database migration with logical replication. 

The new playbook `pgsql-migration.yml` will make this a lot easier. It will create a series of
scripts which will help you to migrate your cluster with near-zero downtime. 




# v1.1.1
* [ENHANCEMENT] replace timescaledb `apache` version with `timescale` version
* [ENHANCEMENT] upgrade prometheus to 2.30
* [BUG FIX] now pg_exporter config dir's owner are {{ pg_dbsu }} instead of prometheus

**How to upgrade from v1.1.0**
  The major change in this release is timescaledb. Which replace old `apache` license version with `timescale` license version

```bash
stop/pause postgres instance with timescaledb
yum remove -y timescaledb_13

[timescale_timescaledb]
name=timescale_timescaledb
baseurl=https://packagecloud.io/timescale/timescaledb/el/7/$basearch
repo_gpgcheck=0
gpgcheck=0
enabled=1

yum install timescaledb-2-postgresql13 
```

# v1.1.0

* [ENHANCEMENT] add `pg_dummy_filesize` to create fs space placeholder 
* [ENHANCEMENT] home page overhaul
* [ENHANCEMENT] add jupyter lab integration
* [ENHANCEMENT] add pgweb console integration
* [ENHANCEMENT] add pgbadger support
* [ENHANCEMENT] add pev2 support, explain visualizer
* [ENHANCEMENT] add pglog utils
* [ENHANCEMENT] update default pkg.tgz software version:
  * upgrade postgres to v13.4  (with official pg14 support)
  * upgrade pgbouncer to v1.16 (metrics definition updates)
  * upgrade grafana to v8.1.4
  * upgrade prometheus to v2.2.29
  * upgrade node_exporter to v1.2.2
  * upgrade haproxy to v2.1.1
  * upgrade consul to v1.10.2
  * upgrade vip-manager to v1.0.1

**API Changes**

* `nginx_upstream` now holds different structures. (incompatible)
* new config entries: `app_list`, render into home page's nav entries
* new config entries: `docs_enabled`, setup local docs on default server.
* new config entries: `pev2_enabled`, setup local pev2 utils.
* new config entries: `pgbadger_enabled`, create log summary/report dir
* new config entries: `jupyter_enabled`, enable jupyter lab server on meta node 
* new config entries: `jupyter_username`, specify which user to run jupyter lab
* new config entries: `jupyter_password`, specify jupyter lab default password
* new config entries: `pgweb_enabled`, enable pgweb server on meta node
* new config entries: `pgweb_username`, specify which user to run pgweb

* rename internal flag `repo_exist` into `repo_exists`
* now default value for `repo_address` is `pigsty` instead of `yum.pigsty`
* now haproxy access point is `http://pigsty` instead of `http://h.pigsty`


# v1.0.1

2021-09-14

* Documentation Update
  * Chinese document now viable
  * Machine-Translated English document now viable
* Bug Fix: `pgsql-remove` does not remove primary instance.
* Bug Fix: replace pg_instance with pg_cluster + pg_seq
  * Start-At-Task may fail due to pg_instance undefined
* Bug Fix: remove citus from default shared preload library
  * citus will force max_prepared_transaction to non-zero value
* Bug Fix: ssh sudo checking in `configure`:
  * now `ssh -t sudo -n ls` is used for privilege checking
* Typo Fix: `pg-backup` script typo   
* Alert Adjust: Remove ntp sanity check alert (dupe with ClockSkew)
* Exporter Adjust: remove collector.systemd to reduce overhead

# v1.0.0

## Highlights

* Monitoring System Overhaul
  * New Dashboards on Grafana 8.0
  * New metrics definition, with extra PG14 support
  * Simplified labeling system: static label set: (job, cls, ins)
  * New Alerting Rules & Derived Metrics
  * Monitoring multiple database at one time
  * Realtime log search & csvlog analysis
  * Link-Rich Dashboards, click graphic elements to drill-down|roll-up

* Architecture Changes
  * Add citus & timescaledb as part of default installation
  * Add PostgreSQL 14beta2 support
  * Simply haproxy admin page index 
  * Decouple infra & pgsql by adding a new role `register`
  * Add new role `loki` and `promtail` for logging 
  * Add new role `environ` for setting up environment for admin user on admin node
  * Using `static` service-discovery for prometheus by default (instead of `consul`)
  * Add new role `remove` to gracefully remove cluster & instance
  * Upgrade prometheus & grafana provisioning logics.
  * Upgrade to vip-manager 1.0 , node_exporter 1.2 , pg_exporter 0.4, grafana 8.0  
  * Now every database on every instance can be auto-registered as grafana datasource  
  * Move consul register tasks to role `register`, change consul service tags
  * Add cmdb.sql as pg-meta baseline definition (CMDB & PGLOG) 

* Application Framework
  * Extensible framework for new functionalities
  * core app: PostgreSQL Monitor System: `pgsql`
  * core app: PostgreSQL Catalog explorer: `pgcat`
  * core app: PostgreSQL Csvlog Analyzer: `pglog`
  * add example app `covid` for visualizing covid-19 data.
  * add example app `isd` for visualizing isd data.
    
* Misc
  * Add jupyterlab which brings entire python environment for data science
  * Add `vonng-echarts-panel` to bring Echarts support back.
  * Add wrap script `createpg` , `createdb`, `createuser`
  * Add cmdb dynamic inventory scripts: `load_conf.py`, `inventory_cmdb`, `inventory_conf`   
  * Remove obsolete playbooks: `pgsql-monitor`, `pgsql-service`, `node-remove`, etc....


## API Change

* new var :  [`node_meta_pip_install`](http://doc.pigsty.cc/#/zh-cn/v-node?id=node_meta_pip_install)
* rename var: `grafana_url` to [`grafana_endpoint`](http://doc.pigsty.cc/#/zh-cn/v-meta?id=grafana_endpoint)
* new var: [`grafana_admin_username`](http://doc.pigsty.cc/#/zh-cn/v-meta?id=grafana_admin_username)
* new var: [`grafana_database`](http://doc.pigsty.cc/#/zh-cn/v-meta?id=grafana_database)
* new var: [`grafana_pgurl`](http://doc.pigsty.cc/#/zh-cn/v-meta?id=grafana_pgurl)
* new var: [`pg_shared_libraries`](http://doc.pigsty.cc/#/zh-cn/v-pg-provision?id=pg_shared_libraries)
* new var: [`pg_exporter_auto_discovery`](http://doc.pigsty.cc/#/zh-cn/v-monitor?id=pg_exporter_auto_discovery)
* new var: [`pg_exporter_exclude_database`](http://doc.pigsty.cc/#/zh-cn/v-monitor?id=pg_exporter_exclude_database)
* new var: [`pg_exporter_include_database`](http://doc.pigsty.cc/#/zh-cn/v-monitor?id=pg_exporter_include_database)


## Bug Fix

* Fix default timezone Asia/Shanghai (CST) issue
* Fix nofile limit for pgbouncer & patroni
* Pgbouncer userlist & database list will be generated when executing tag `pgbouncer`



# v0.9.0

## Features

* One-Line Installation

  Run this on meta node `/bin/bash -c "$(curl -fsSL https://pigsty.cc/install)"`

* MetaDB provisioning

  Now you can use pgsql database on meta node as inventory instead of static yaml file affter bootstrap. 

* Add Loki & Prometail as optinal logging collector

  Now you can view, query, search postgres|pgbouncer|patroni logs with Grafana UI (PG Instance Log)

* Pigsty CLI/GUI (beta)

  Mange you pigsty deployment with much more human-friendly command line interface. 

## Bug Fix

* Log related issues
  * fix `connection reset by peer` entries in postgres log caused by Haproxy health check.
  * fix `Connect Reset Exception` in patroni logs caused by haproxy health check
  * fix patroni log time format (remove mill seconds, add timezone) 
  * set `log_min_duration_statement=1s` for `dbuser_monitor` to get ride of monitor logs. 
* Fix `pgbouncer-create-user` does not handle md5 password properly
* Fix obsolete `Makefile` entries
* Fix node dns nameserver lost when abort during resolv.conf rewrite
* Fix db/user template and entry not null check

## API Change

* Set default value of `node_disable_swap` to `false`
* Remove example enties of `node_sysctl_params`.
* `grafana_plugin` default `install` will now download from CDN if plugins not exists
* `repo_url_packages` now download rpm via pigsty CDN to accelerate.
* `proxy_env.no_proxy` now add pigsty CDN to `noproxy` sites。
* `grafana_customize`  set to `false` by default，enable it means install pigsty pro UI.
* `node_admin_pk_current` add current user's `~/.ssh/id_rsa.pub` to admin pks
* `loki_clean` whether to cleanup existing loki data during init
* `loki_data_dir` set default data dir for loki logging service
* `promtail_enabled` enabling promtail logging agent service?
* `promtail_clean` remove existing promtail status during init?
* `promtail_port` default port used by promtail, 9080 by default
* `promtail_status_file` location of promtail status file
* `promtail_send_url` endpoint of loki service which receives log data

------------------------

# v0.8.0

Pigsty now is in **RC** status with guaranteed provisoning API stability.

## New Features

* Service provision.
* full locale support.


## API Changes

Role `vip` and `haproxy` are merged into `service`.

```yaml
#------------------------------------------------------------------------------
# SERVICE PROVISION
#------------------------------------------------------------------------------
pg_weight: 100              # default load balance weight (instance level)

# - service - #
pg_services:                                  # how to expose postgres service in cluster?
  # primary service will route {ip|name}:5433 to primary pgbouncer (5433->6432 rw)
  - name: primary           # service name {{ pg_cluster }}_primary
    src_ip: "*"
    src_port: 5433
    dst_port: pgbouncer     # 5433 route to pgbouncer
    check_url: /primary     # primary health check, success when instance is primary
    selector: "[]"          # select all instance as primary service candidate

  # replica service will route {ip|name}:5434 to replica pgbouncer (5434->6432 ro)
  - name: replica           # service name {{ pg_cluster }}_replica
    src_ip: "*"
    src_port: 5434
    dst_port: pgbouncer
    check_url: /read-only   # read-only health check. (including primary)
    selector: "[]"          # select all instance as replica service candidate
    selector_backup: "[? pg_role == `primary`]"   # primary are used as backup server in replica service

  # default service will route {ip|name}:5436 to primary postgres (5436->5432 primary)
  - name: default           # service's actual name is {{ pg_cluster }}-{{ service.name }}
    src_ip: "*"             # service bind ip address, * for all, vip for cluster virtual ip address
    src_port: 5436          # bind port, mandatory
    dst_port: postgres      # target port: postgres|pgbouncer|port_number , pgbouncer(6432) by default
    check_method: http      # health check method: only http is available for now
    check_port: patroni     # health check port:  patroni|pg_exporter|port_number , patroni by default
    check_url: /primary     # health check url path, / as default
    check_code: 200         # health check http code, 200 as default
    selector: "[]"          # instance selector
    haproxy:                # haproxy specific fields
      maxconn: 3000         # default front-end connection
      balance: roundrobin   # load balance algorithm (roundrobin by default)
      default_server_options: 'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'

  # offline service will route {ip|name}:5438 to offline postgres (5438->5432 offline)
  - name: offline           # service name {{ pg_cluster }}_replica
    src_ip: "*"
    src_port: 5438
    dst_port: postgres
    check_url: /replica     # offline MUST be a replica
    selector: "[? pg_role == `offline` || pg_offline_query ]"         # instances with pg_role == 'offline' or instance marked with 'pg_offline_query == true'
    selector_backup: "[? pg_role == `replica` && !pg_offline_query]"  # replica are used as backup server in offline service

pg_services_extra: []        # extra services to be added

# - haproxy - #
haproxy_enabled: true                         # enable haproxy among every cluster members
haproxy_reload: true                          # reload haproxy after config
haproxy_policy: roundrobin                    # roundrobin, leastconn
haproxy_admin_auth_enabled: false             # enable authentication for haproxy admin?
haproxy_admin_username: admin                 # default haproxy admin username
haproxy_admin_password: admin                 # default haproxy admin password
haproxy_exporter_port: 9101                   # default admin/exporter port
haproxy_client_timeout: 3h                    # client side connection timeout
haproxy_server_timeout: 3h                    # server side connection timeout

# - vip - #
vip_mode: none                                # none | l2 | l4
vip_reload: true                              # whether reload service after config
# vip_address: 127.0.0.1                      # virtual ip address ip (l2 or l4)
# vip_cidrmask: 24                            # virtual ip address cidr mask (l2 only)
# vip_interface: eth0                         # virtual ip network interface (l2 only)
```

**New Options**

```yml
# - localization - #
pg_encoding: UTF8                             # default to UTF8
pg_locale: C                                  # default to C
pg_lc_collate: C                              # default to C
pg_lc_ctype: en_US.UTF8                       # default to en_US.UTF8

pg_reload: true                               # reload postgres after hba changes
vip_mode: none                                # none | l2 | l4
vip_reload: true                              # whether reload service after config
```

**Remove Options**

```
haproxy_check_port                            # covered by service options
haproxy_primary_port
haproxy_replica_port
haproxy_backend_port
haproxy_weight
haproxy_weight_fallback
vip_enabled                                   # replace by vip_mode
```

## Service

`pg_services` and `pg_services_extra` Defines the services in cluster:

A service has some mandatory fields:

* `name`: service's name
* `src_port`: which port to listen and expose service?
* `selector`: which instances belonging to this service?

```yaml
  # default service will route {ip|name}:5436 to primary postgres (5436->5432 primary)
  - name: default           # service's actual name is {{ pg_cluster }}-{{ service.name }}
    src_ip: "*"             # service bind ip address, * for all, vip for cluster virtual ip address
    src_port: 5436          # bind port, mandatory
    dst_port: postgres      # target port: postgres|pgbouncer|port_number , pgbouncer(6432) by default
    check_method: http      # health check method: only http is available for now
    check_port: patroni     # health check port:  patroni|pg_exporter|port_number , patroni by default
    check_url: /primary     # health check url path, / as default
    check_code: 200         # health check http code, 200 as default
    selector: "[]"          # instance selector
    haproxy:                # haproxy specific fields
      maxconn: 3000         # default front-end connection
      balance: roundrobin   # load balance algorithm (roundrobin by default)
      default_server_options: 'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'
```

## Database

Add additional locale support: `lc_ctype` and `lc_collate`. 

It's mainly because of `pg_trgm` 's weird behavior on i18n characters. 

```yaml
pg_databases:
  - name: meta                      # name is the only required field for a database
    # owner: postgres                 # optional, database owner
    # template: template1             # optional, template1 by default
    # encoding: UTF8                # optional, UTF8 by default , must same as template database, leave blank to set to db default
    # locale: C                     # optional, C by default , must same as template database, leave blank to set to db default
    # lc_collate: C                 # optional, C by default , must same as template database, leave blank to set to db default
    # lc_ctype: C                   # optional, C by default , must same as template database, leave blank to set to db default
    allowconn: true                 # optional, true by default, false disable connect at all
    revokeconn: false               # optional, false by default, true revoke connect from public # (only default user and owner have connect privilege on database)
    # tablespace: pg_default          # optional, 'pg_default' is the default tablespace
    connlimit: -1                   # optional, connection limit, -1 or none disable limit (default)
    extensions:                     # optional, extension name and where to create
      - {name: postgis, schema: public}
    parameters:                     # optional, extra parameters with ALTER DATABASE
      enable_partitionwise_join: true
    pgbouncer: true                 # optional, add this database to pgbouncer list? true by default
    comment: pigsty meta database   # optional, comment string for database
```


------------------------

# v0.7.0

## Overview

* Monitor Only Deployment
      * Now you can monitoring existing postgres clusters without Pigsty provisioning solution.
      * Intergration with other provisioning solution is available and under further test.

* Database/User Management
      * Update user/database definition schema to cover more usecases.
      * Add `pgsql-createdb.yml` and `pgsql-createuser.yml` to mange user/db on running clusters.

## Features

* [Monitor Only Deployment Support #25](https://github.com/Vonng/pigsty/issues/25)
* [Split monolith static monitor target file into per-cluster conf #36](https://github.com/Vonng/pigsty/issues/36)
* [Add create user playbook #29](https://github.com/Vonng/pigsty/issues/29)
* [Add create database playbook #28](https://github.com/Vonng/pigsty/issues/28)
* [Database provisioning interface enhancement #33](https://github.com/Vonng/pigsty/issues/33)
* [User provisioning interface enhancement #34](https://github.com/Vonng/pigsty/issues/34)



## Bug Fix

* [Create extension with schema typo #32](https://github.com/Vonng/pigsty/issues/32)
* [pgbouncer reload with systemctl not work #35](https://github.com/Vonng/pigsty/issues/35)



## API Changes

**New Options**

```yml
prometheus_sd_target: batch                   # batch|single
exporter_install: none                        # none|yum|binary
exporter_repo_url: ''                         # add to yum repo if set
node_exporter_options: '--no-collector.softnet --collector.systemd --collector.ntp --collector.tcpstat --collector.processes'                          # default opts for node_exporter
pg_exporter_url: ''                           # optional, overwrite default pg_exporter target
pgbouncer_exporter_url: ''                    # optional, overwrite default pgbouncer_expoter target
```

**Remove Options**

```yml
exporter_binary_install: false                 # covered by exporter_install
```

**Structure Changes**

```yaml
pg_default_roles                               # refer to pg_users
pg_users                                       # refer to pg_users
pg_databases                                   # refer to pg_databases
```

**Rename Options**

```yml
pg_default_privilegs -> pg_default_privileges  # fix typo
```


## Enhancement

**Monitoring Provisioning Enhancement**

* [Decouple consul #13](https://github.com/Vonng/pigsty/issues/13)
* [Binary install mode for node_exporter and pg_exporter #14](https://github.com/Vonng/pigsty/issues/14)
* [Prometheus static targets mode support #11](https://github.com/Vonng/pigsty/issues/11)

**Haproxy Enhancement**

* [Adjust relative traffic weight with configuration #10](https://github.com/Vonng/pigsty/issues/10)
* [HAProxy admin page access via nginx #12](https://github.com/Vonng/pigsty/issues/12)
* [Readonly traffic fallback on primary if all replicas down #8](https://github.com/Vonng/pigsty/issues/8)

**Security Enhancement**

* [Offline access control #7](https://github.com/Vonng/pigsty/issues/7)
* [Safeguard for purge functionality #9](https://github.com/Vonng/pigsty/issues/9)

**Software Update**

* [Upgrade to PG 13.2 #6](https://github.com/Vonng/pigsty/issues/6)

* Prometheus 2.25 / Grafana 7.4 / Consul 1.9.3 / Node Exporter 1.1 / PG Exporter 0.3.2



## API Change

**New Config Entries**

```yaml
service_registry: consul                      # none | consul | etcd | both
prometheus_options: '--storage.tsdb.retention=30d'  # prometheus cli opts
prometheus_sd_method: consul                  # Prometheus service discovery method：static|consul
prometheus_sd_interval: 2s                    # Prometheus service discovery refresh interval
pg_offline_query: false                       # set to true to allow offline queries on this instance
node_exporter_enabled: true                   # enabling Node Exporter
pg_exporter_enabled: true                     # enabling PG Exporter
pgbouncer_exporter_enabled: true              # enabling Pgbouncer Exporter
export_binary_install: false                  # install Node/PG Exporter via copy binary
dcs_disable_purge: false                      # force dcs_exists_action = abort to avoid dcs purge
pg_disable_purge: false                       # force pg_exists_action = abort to avoid pg purge
haproxy_weight: 100                           # relative lb weight for backend instance
haproxy_weight_fallback: 1                    # primary server weight in replica service group
```

**Obsolete Config Entries**

```yaml
prometheus_metrics_path                       # duplicate with exporter_metrics_path 
prometheus_retention                          # covered by `prometheus_options`
```


## Database Definition

[Database provisioning interface enhancement #33](https://github.com/Vonng/pigsty/issues/33)

### Old Schema

```yaml
pg_databases:                       # create a business database 'meta'
  - name: meta
    schemas: [meta]                 # create extra schema named 'meta'
    extensions: [{name: postgis}]   # create extra extension postgis
    parameters:                     # overwrite database meta's default search_path
      search_path: public, monitor
```

### New Schema

```yaml
pg_databases:
  - name: meta                      # name is the only required field for a database
    owner: postgres                 # optional, database owner
    template: template1             # optional, template1 by default
    encoding: UTF8                  # optional, UTF8 by default
    locale: C                       # optional, C by default
    allowconn: true                 # optional, true by default, false disable connect at all
    revokeconn: false               # optional, false by default, true revoke connect from public # (only default user and owner have connect privilege on database)
    tablespace: pg_default          # optional, 'pg_default' is the default tablespace
    connlimit: -1                   # optional, connection limit, -1 or none disable limit (default)
    extensions:                     # optional, extension name and where to create
      - {name: postgis, schema: public}
    parameters:                     # optional, extra parameters with ALTER DATABASE
      enable_partitionwise_join: true
    pgbouncer: true                 # optional, add this database to pgbouncer list? true by default
    comment: pigsty meta database   # optional, comment string for database
```

### Changes

* Add new options: `template` , `encoding`, `locale`, `allowconn`, `tablespace`, `connlimit`
* Add new option `revokeconn`, which revoke connect privileges from public for this database
* Add `comment` field for database

### Apply Changes

You can create new database on running postgres clusters with `pgsql-createdb.yml` playbook.
1. Define your new database in config files
2. Pass new database.name with option `pg_database` to playbook.

```bash
./pgsql-createdb.yml -e pg_database=<your_new_database_name>
```


## User Definition

[User provisioning interface enhancement #34](https://github.com/Vonng/pigsty/issues/34)

### Old Schema

```yaml
pg_users:
  - username: test                  # example production user have read-write access
    password: test                  # example user's password
    options: LOGIN                  # extra options
    groups: [ dbrole_readwrite ]    # dborole_admin|dbrole_readwrite|dbrole_readonly
    comment: default test user for production usage
    pgbouncer: true                 # add to pgbouncer
```

### New Schema

```yaml
pg_users:
  # complete example of user/role definition for production user
  - name: dbuser_meta               # example production user have read-write access
    password: DBUser.Meta           # example user's password, can be encrypted
    login: true                     # can login, true by default (should be false for role)
    superuser: false                # is superuser? false by default
    createdb: false                 # can create database? false by default
    createrole: false               # can create role? false by default
    inherit: true                   # can this role use inherited privileges?
    replication: false              # can this role do replication? false by default
    bypassrls: false                # can this role bypass row level security? false by default
    connlimit: -1                   # connection limit, -1 disable limit
    expire_at: '2030-12-31'         # 'timestamp' when this role is expired
    expire_in: 365                  # now + n days when this role is expired (OVERWRITE expire_at)
    roles: [dbrole_readwrite]       # dborole_admin|dbrole_readwrite|dbrole_readonly
    pgbouncer: true                 # add this user to pgbouncer? false by default (true for production user)
    parameters:                     # user's default search path
      search_path: public
    comment: test user
```

## Changes

* `username` field rename to `name`
* `groups` field rename to `roles`
* `options` now split into separated configration entries:
  `login`, `superuser`, `createdb`, `createrole`, `inherit`, `replication`,`bypassrls`,`connlimit`
* `expire_at` and `expire_in` options
* `pgbouncer` option for user is now `false` by default

### Apply Changes

You can create new users on running postgres clusters with `pgsql-createuser.yml` playbook.
1. Define your new users in config files (`pg_users`)
2. Pass new user.name with option `pg_user` to playbook.

```bash
./pgsql-createuser.yml -e pg_user=<your_new_user_name>
```


------------------------


# v0.6.0


## Bug Fix

* [pg_hba reset on patroni restart (patroni 2.0) #5](https://github.com/Vonng/pigsty/issues/5)

* Merge [Fix name of dashboard #1](https://github.com/Vonng/pigsty/pull/1), Fix PG Overview Dashboard typo
* Fix default primary instance to `pg-test-1` of cluster `pg-test` in sandbox environment
* Fix obsolete comments



## Enhancement

**Monitoring Provisioning Enhancement**

* [Decouple consul #13](https://github.com/Vonng/pigsty/issues/13)
* [Binary install mode for node_exporter and pg_exporter #14](https://github.com/Vonng/pigsty/issues/14)
* [Prometheus static targets mode support #11](https://github.com/Vonng/pigsty/issues/11)

**Haproxy Enhancement**

* [Adjust relative traffic weight with configuration #10](https://github.com/Vonng/pigsty/issues/10)
* [HAProxy admin page access via nginx #12](https://github.com/Vonng/pigsty/issues/12)
* [Readonly traffic fallback on primary if all replicas down #8](https://github.com/Vonng/pigsty/issues/8)

**Security Enhancement**

* [Offline access control #7](https://github.com/Vonng/pigsty/issues/7)
* [Safeguard for purge functionality #9](https://github.com/Vonng/pigsty/issues/9)

**Software Update**

* [Upgrade to PG 13.2 #6](https://github.com/Vonng/pigsty/issues/6)

* Prometheus 2.25 / Grafana 7.4 / Consul 1.9.3 / Node Exporter 1.1 / PG Exporter 0.3.2



## API Change

**New Config Entries**

```yaml
service_registry: consul                      # none | consul | etcd | both
prometheus_options: '--storage.tsdb.retention=30d'  # prometheus cli opts
prometheus_sd_method: consul                  # Prometheus service discovery method：static|consul
prometheus_sd_interval: 2s                    # Prometheus service discovery refresh interval
pg_offline_query: false                       # set to true to allow offline queries on this instance
node_exporter_enabled: true                   # enabling Node Exporter
pg_exporter_enabled: true                     # enabling PG Exporter
pgbouncer_exporter_enabled: true              # enabling Pgbouncer Exporter
export_binary_install: false                  # install Node/PG Exporter via copy binary
dcs_disable_purge: false                      # force dcs_exists_action = abort to avoid dcs purge
pg_disable_purge: false                       # force pg_exists_action = abort to avoid pg purge
haproxy_weight: 100                           # relative lb weight for backend instance
haproxy_weight_fallback: 1                    # primary server weight in replica service group
```

**Obsolete Config Entries**

```yaml
prometheus_metrics_path                       # duplicate with exporter_metrics_path 
prometheus_retention                          # covered by `prometheus_options`
```



------------------------


# v0.5.0


Pigsty now have an [Official Site](http://pigsty.cc/) 🎉 !

## New Features

* Add Database Provision Template
* Add Init Template
* Add Business Init Template
* Refactor HBA Rules variables
* Fix dashboards bugs.
* Move `pg-cluster-replication` to default dashboards
* Use ZJU PostgreSQL mirror as default to accelerate repo build phase.
* Move documentation to official site:  https://pigsty.cc
* Download newly created offline installation packages:  [pkg.tgz](https://github.com/Vonng/pigsty/releases/download/v0.5.0/pkg.tgz) (v0.5)

## Database Provision Template

Now you can customize your database content with pigsty !

```yaml
pg_users:
  - username: test
    password: test
    comment: default test user
    groups: [ dbrole_readwrite ]    # dborole_admin|dbrole_readwrite|dbrole_readonly
pg_databases:                       # create a business database 'test'
  - name: test
    extensions: [{name: postgis}]   # create extra extension postgis
    parameters:                     # overwrite database meta's default search_path
      search_path: public,monitor
```
[pg-init-template.sql](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/pg-init-template.sql) wil be used as default template1 database init script
[pg-init-business.sql
](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/pg-init-business.sql) will be used as default business database init script


you can customize default role system, schemas, extensions, privileges with variables now:

<details>
<summary>Template Configuration</summary>

```yaml
# - system roles - #
pg_replication_username: replicator           # system replication user
pg_replication_password: DBUser.Replicator    # system replication password
pg_monitor_username: dbuser_monitor           # system monitor user
pg_monitor_password: DBUser.Monitor           # system monitor password
pg_admin_username: dbuser_admin               # system admin user
pg_admin_password: DBUser.Admin               # system admin password

# - default roles - #
pg_default_roles:
  - username: dbrole_readonly                 # sample user:
    options: NOLOGIN                          # role can not login
    comment: role for readonly access         # comment string

  - username: dbrole_readwrite                # sample user: one object for each user
    options: NOLOGIN
    comment: role for read-write access
    groups: [ dbrole_readonly ]               # read-write includes read-only access

  - username: dbrole_admin                    # sample user: one object for each user
    options: NOLOGIN BYPASSRLS                # admin can bypass row level security
    comment: role for object creation
    groups: [dbrole_readwrite,pg_monitor,pg_signal_backend]

  # NOTE: replicator, monitor, admin password are overwritten by separated config entry
  - username: postgres                        # reset dbsu password to NULL (if dbsu is not postgres)
    options: SUPERUSER LOGIN
    comment: system superuser

  - username: replicator
    options: REPLICATION LOGIN
    groups: [pg_monitor, dbrole_readonly]
    comment: system replicator

  - username: dbuser_monitor
    options: LOGIN CONNECTION LIMIT 10
    comment: system monitor user
    groups: [pg_monitor, dbrole_readonly]

  - username: dbuser_admin
    options: LOGIN BYPASSRLS
    comment: system admin user
    groups: [dbrole_admin]

  - username: dbuser_stats
    password: DBUser.Stats
    options: LOGIN
    comment: business read-only user for statistics
    groups: [dbrole_readonly]


# object created by dbsu and admin will have their privileges properly set
pg_default_privilegs:
  - GRANT USAGE                         ON SCHEMAS   TO dbrole_readonly
  - GRANT SELECT                        ON TABLES    TO dbrole_readonly
  - GRANT SELECT                        ON SEQUENCES TO dbrole_readonly
  - GRANT EXECUTE                       ON FUNCTIONS TO dbrole_readonly
  - GRANT INSERT, UPDATE, DELETE        ON TABLES    TO dbrole_readwrite
  - GRANT USAGE,  UPDATE                ON SEQUENCES TO dbrole_readwrite
  - GRANT TRUNCATE, REFERENCES, TRIGGER ON TABLES    TO dbrole_admin
  - GRANT CREATE                        ON SCHEMAS   TO dbrole_admin
  - GRANT USAGE                         ON TYPES     TO dbrole_admin

# schemas
pg_default_schemas: [monitor]

# extension
pg_default_extensions:
  - { name: 'pg_stat_statements',  schema: 'monitor' }
  - { name: 'pgstattuple',         schema: 'monitor' }
  - { name: 'pg_qualstats',        schema: 'monitor' }
  - { name: 'pg_buffercache',      schema: 'monitor' }
  - { name: 'pageinspect',         schema: 'monitor' }
  - { name: 'pg_prewarm',          schema: 'monitor' }
  - { name: 'pg_visibility',       schema: 'monitor' }
  - { name: 'pg_freespacemap',     schema: 'monitor' }
  - { name: 'pg_repack',           schema: 'monitor' }
  - name: postgres_fdw
  - name: file_fdw
  - name: btree_gist
  - name: btree_gin
  - name: pg_trgm
  - name: intagg
  - name: intarray

# postgres host-based authentication rules
pg_hba_rules:
  - title: allow meta node password access
    role: common
    rules:
      - host    all     all                         10.10.10.10/32      md5

  - title: allow intranet admin password access
    role: common
    rules:
      - host    all     +dbrole_admin               10.0.0.0/8          md5
      - host    all     +dbrole_admin               172.16.0.0/12       md5
      - host    all     +dbrole_admin               192.168.0.0/16      md5

  - title: allow intranet password access
    role: common
    rules:
      - host    all             all                 10.0.0.0/8          md5
      - host    all             all                 172.16.0.0/12       md5
      - host    all             all                 192.168.0.0/16      md5

  - title: allow local read-write access (local production user via pgbouncer)
    role: common
    rules:
      - local   all     +dbrole_readwrite                               md5
      - host    all     +dbrole_readwrite           127.0.0.1/32        md5

  - title: allow read-only user (stats, personal) password directly access
    role: replica
    rules:
      - local   all     +dbrole_readonly                               md5
      - host    all     +dbrole_readonly           127.0.0.1/32        md5
pg_hba_rules_extra: []

# pgbouncer host-based authentication rules
pgbouncer_hba_rules:
  - title: local password access
    role: common
    rules:
      - local  all          all                                     md5
      - host   all          all                     127.0.0.1/32    md5

  - title: intranet password access
    role: common
    rules:
      - host   all          all                     10.0.0.0/8      md5
      - host   all          all                     172.16.0.0/12   md5
      - host   all          all                     192.168.0.0/16  md5
pgbouncer_hba_rules_extra: []


```

</details>



------------------------

# v0.4.0

The second public beta (v0.4.0) of pigsty is available now ! 🎉

## Monitoring System

**Skim version of monitoring system** consist of 10 essential dashboards:

* PG Overview
* PG Cluster
* PG Service
* PG Instance
* PG Database
* PG Query
* PG Table
* PG Table Catalog
* PG Table Detail
* Node

## Software upgrade

* Upgrade to PostgreSQL 13.1, Patroni 2.0.1-4, add citus to repo.
* Upgrade to [`pg_exporter 0.3.1`](https://github.com/Vonng/pg_exporter/releases/tag/v0.3.1)
* Upgrade to Grafana 7.3, Ton's of compatibility work
* Upgrade to prometheus 2.23, with new UI as default
* Upgrade to consul 1.9

## Misc

* Update prometheus alert rules
* Fix alertmanager info links
* Fix bugs and typos.
* add a simple backup script

### **Offline Installation**

* [pkg.tgz](https://github.com/Vonng/pigsty/releases/download/v0.4.0/pkg.tgz) is the latest offline install package (1GB rpm packages, made under CentOS 7.8)


------------------------

# v0.3.0

The first public beta (v0.3.0) of pigsty is available now ! 🎉

## Monitoring System

**Skim version of monitoring system** consist of 8 essential dashboards:

* PG Overview
* PG Cluster
* PG Service
* PG Instance
* PG Database
* PG Table Overview
* PG Table Catalog
* Node

## **Database Cluster Provision**

* All config files are merged into one file: `conf/all.yml` by default
* Use `infra.yml` to provision meta node(s) and infrastructure
* Use `initdb.yml` to provision database clusters
* Use `ins-add.yml` to add new instance to database cluster
* Use `ins-del.yml` to remove instance from database cluster


## **Offline Installation**

* [pkg.tgz](https://github.com/Vonng/pigsty/releases/download/v0.3.0/pkg.tgz) is the latest offline install package (1GB rpm packages, made under CentOS 7.8)

