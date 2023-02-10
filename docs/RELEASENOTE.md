# RELEASENOTE

| Version               |    Time    | Description                                             | Release                                                                                   |
|:----------------------|:----------:|---------------------------------------------------------|-------------------------------------------------------------------------------------------|
| [v2.0.0-b6](#v200-b6) | 2023-02-09 | Compatibility Security Maintainability Enhancement      | [v2.0.0-b6](https://github.com/Vonng/pigsty/releases/tag/v2.0.0-b6)                       |
| [v1.5.1](#v151)       | 2022-06-18 | Grafana Security Hotfix                                 | [v1.5.1](https://github.com/Vonng/pigsty/releases/tag/v1.5.1)                             |
| [v1.5.0](#v150)       | 2022-05-31 | Docker Applications                                     | [v1.5.0](https://github.com/Vonng/pigsty/releases/tag/v1.5.0)                             |
| [v1.4.1](#v141)       | 2022-04-20 | Bug fix & Full translation of English documents.        | [v1.4.1](https://github.com/Vonng/pigsty/releases/tag/v1.4.1)                             |
| [v1.4.0](#v140)       | 2022-03-31 | MatrixDB Support, Separated INFRA, NODES, PGSQL, REDIS  | [v1.4.0](https://github.com/Vonng/pigsty/releases/tag/v1.4.0)                             |
| [v1.3.0](#v130)       | 2021-11-30 | PGCAT Overhaul & PGSQL Enhancement & Redis Support Beta | [v1.3.0](https://github.com/Vonng/pigsty/releases/tag/v1.3.0)                             |
| [v1.2.0](#v120)       | 2021-11-03 | Upgrade default Postgres to 14, monitoring existing pg  | [v1.2.0](https://github.com/Vonng/pigsty/releases/tag/v1.2.0)                             |
| [v1.1.0](#v110)       | 2021-10-12 | HomePage, JupyterLab, Pgweb, Pev2 & Pgbadger            | [v1.1.0](https://github.com/Vonng/pigsty/releases/tag/v1.1.0)                             |
| [v1.0.0](#v100)       | 2021-07-26 | v1 GA, Monitoring System Overhaul                       | [v1.0.0](https://github.com/Vonng/pigsty/releases/tag/v1.0.0)                             |
| [v0.9.0](#v090)       | 2021-04-04 | Pigsty GUI, CLI, Logging Integration                    | [v0.9.0](https://github.com/Vonng/pigsty/releases/tag/v0.9.0)                             |
| [v0.8.0](#v080)       | 2021-03-28 | Service Provision                                       | [v0.8.0](https://github.com/Vonng/pigsty/releases/tag/v0.8.0)                             |
| [v0.7.0](#v070)       | 2021-03-01 | Monitor only deployment                                 | [v0.7.0](https://github.com/Vonng/pigsty/releases/tag/v0.7.0)                             |
| [v0.6.0](#v060)       | 2021-02-19 | Architecture Enhancement                                | [v0.6.0](https://github.com/Vonng/pigsty/releases/tag/v0.6.0)                             |
| [v0.5.0](#v050)       | 2021-01-07 | Database Customize Template                             | [v0.5.0](https://github.com/Vonng/pigsty/releases/tag/v0.5.0)                             |
| [v0.4.0](#v040)       | 2020-12-14 | PostgreSQL 13 Support, Official Documentation           | [v0.4.0](https://github.com/Vonng/pigsty/releases/tag/v0.4.0)                             |
| [v0.3.0](#v030)       | 2020-10-22 | Provisioning Solution GA                                | [v0.3.0](https://github.com/Vonng/pigsty/releases/tag/v0.3.0)                             |
| [v0.2.0](#)           | 2020-07-10 | PGSQL Monitoring v6 GA                                  | [v0.2.0](https://github.com/Vonng/pigsty/commit/385e33a62a19817e8ba19997260e6b77d99fe2ba) |
| [v0.1.0](#)           | 2020-06-20 | Validation on Testing Environment                       | [v0.1.0](https://github.com/Vonng/pigsty/commit/1cf2ea5ee91db071de00ec805032928ff582453b) |
| [v0.0.5](#)           | 2020-08-19 | Offline Installation Mode                               | [v0.0.5](https://github.com/Vonng/pigsty/commit/0fe9e829b298fe5e56307de3f78c95071de28245) |
| [v0.0.4](#)           | 2020-07-27 | Refactor playbooks into ansible roles                   | [v0.0.4](https://github.com/Vonng/pigsty/commit/90b44259818d2c71e37df5250fe8ed1078a883d0) |
| [v0.0.3](#)           | 2020-06-22 | Interface enhancement                                   | [v0.0.3](https://github.com/Vonng/pigsty/commit/4c5c68ccd57bc32a9e9c98aa3f264aa19f45c7ee) |
| [v0.0.2](#)           | 2020-04-30 | First Commit                                            | [v0.0.2](https://github.com/Vonng/pigsty/commit/dd646775624ddb33aef7884f4f030682bdc371f8) |
| [v0.0.1](#)           | 2019-05-15 | POC                                                     | [v0.0.1](https://github.com/Vonng/pg/commit/fa2ade31f8e81093eeba9d966c20120054f0646b)     |


------------------------------

## v2.0.0-b6

v2.0.0 Beta6 Release

```bash
bash -c "$(curl -fsSL http://download.pigsty.cc/getb)" && cd ~/pigsty   
./bootstrap  && ./configure && ./install.yml    # install latest beta
```

**Highlights**

* PostgreSQL 15.1, PostGIS 3.3, Citus 11.1, TimescaleDB 2.9
* Compatibility: EL 7,8,9, PG 15 for RHEL, CentOS, Rocky, OracleLinux, AlmaLinux
* Security Enhancement: CA, SSL for nginx/etcd/postgres/patroni, scram-sha-256 auth by default
* New module: `ETCD`,  Use `etcd` instead of `consul`
* New module: `MINIO`, S3-Compatible Object Storage, optional backup center for pgbackrest
* Battery-Included PITR with `pgbackrest`
* Adaptive tuning template for PostgreSQL and Node Tuned
* Simplified configuration templates
* Replace consul with etcd completely
* New HBA/Service API
* Change license to AGPL v3.0 (infect by grafana & minio)

**Compatibility**

* More compatible Linux distributions: RHEL, CentOS, RockyLinux, AlmaLinux.
* RHEL 7, 8, 9 Support (build on 7.9, 8.6, 9.0 ), use versioning in pigsty & pkg name
* Add support for PostgreSQL 15 & PostGIS 3.3
* Add version & arch as part of the `pkg.tgz` name

**Security**

* A full-featured self-signed CA enabled by default
* Pgbouncer Auth Query  by @alemacci
* SSL for etcd/consul by @alemacci
* SSL for postgres/pgbouncer/patroni by @alemacci
* scram-sha-256 auth for postgres by @alemacci
* redact password in postgres logs

**Maintainability**

* Adaptive tuning template for PostgreSQL & Patroni by @Vonng, @alemacci
* configurable log dir for Patroni & Postgres & Pgbouncer & Pgbackrest by @alemacci
* Use `${admin_ip}` in infra vars to switch the admin node.
* Adaptive upstream repo definition, compatible with EL7/EL8/EL9
* Vagrant templates examples for el8, el9, building environment.
* Terraform Templates for AWS EC2
* Use chrony instead of ntpd as NTP services
* New signed apache ECharts 5.0 plugin for Grafana panels
* Simplify roles implementation. merge into `pgsql`, `infra`, `node`, `node_monitor`
* Refactor `pgsql-monitor.yml` & `pgsql-migration.yml` for new architecture.

**Enhancement**

* enable dns on infra nodes by default
* add the nameserver on admin node to all node's resolver by default 
* register pg dns name to infra nodes nameservers
* HAProxy are part of `node` rather than `pgsql`, which can be used for other services
* Support all pgbouncer db/user level parameters 
* Upgrade vip-manager to v2 to enforce etcd v3 API
* Use official loki, promtail rpm packages


**Software Upgrade**

* PostgreSQL 15.1
* Patroni 2.1.7
* Pgbouncer 1.18
* pgBackRest 2.44
* HAProxy 2.7.0
* vip-manager 2.1.0
* PostGIS 3.3.2
* Citus 11.2.0
* TimescaleDB 2.9.3
* Prometheus 2.42
* Loki & Promtail 2.7.1
* Grafana 9.3.6
* Node Exporter 1.5.0
* ETCD 3.5.6
* Minio 20230131022419 / MCLI 20230128202938
* PEV v1.7
* Use grafana official rpm for `loki`, `promtail`, `logcli`
* Add `minio` & `mcli` to URL packages


**API Changes**

add 24 parameters, remove 8 parameters, rename 12 parameters

- `INFRA`.`META`.`admin_ip`                     : primary meta node ip address
- `INFRA`.`META`.`region`                       : upstream mirror region: default|china|europe
- `INFRA`.`META`.`os_version`                   : enterprise linux release version: 7,8,9
- `INFRA`.`CA`.`ca_cn`                          : ca common name, pigsty-ca by default
- `INFRA`.`CA`.`cert_validity`                  : cert validity, 20 years by default
- `INFRA`.`REPO`.`repo_enabled`                 : build a local yum repo on infra node?
- `INFRA`.`REPO`.`repo_upstream`                : list of upstream yum repo definition
- `INFRA`.`REPO`.`repo_home`                    : home dir of local yum repo, usually same as nginx_home '/www'
- `INFRA`.`NGINX`.`nginx_ssl_port`              : https listen port
- `INFRA`.`NGINX`.`nginx_ssl_enabled`           : nginx https enabled?
- `INFRA`.`PROMTETHEUS`.`alertmanager_endpoint` : altermanager endpoint in (ip|domain):port format
- `NODE`.`NODE_TUNE`.`node_hugepage_ratio`      : mem hugepage ratio, 0 disable it by default
- `NODE`.`HAPROXY`.`haproxy_service`            : list of haproxy service to be exposed
- `PGSQL`.`PG_INSTALL`.`pg_log_dir`             : postgres log dir, `/pg/data/log` by default
- `PGSQL`.`PG_BOOTSTRAP`.`pg_storage_type`      : SSD|HDD, SSD by default
- `PGSQL`.`PG_BOOTSTRAP`.`patroni_log_dir`      : patroni log dir, `/pg/log` by default
- `PGSQL`.`PG_BOOTSTRAP`.`patroni_ssl_enabled`  : secure patroni RestAPI communications with SSL?
- `PGSQL`.`PG_BOOTSTRAP`.`patroni_username`     : patroni rest api username
- `PGSQL`.`PG_BOOTSTRAP`.`patroni_password`     : patroni rest api password (IMPORTANT: CHANGE THIS)
- `PGSQL`.`PG_BOOTSTRAP`.`pg_max_conn`          : postgres max connections, `auto` will use recommended value
- `PGSQL`.`PG_BOOTSTRAP`.`pg_shmem_ratio`       : postgres shared memory ratio, 0.25 by default, 0.1~0.4
- `PGSQL`.`PG_BOOTSTRAP`.`pg_rto`               : recovery time objective, ttl to failover, 30s by default
- `PGSQL`.`PG_BOOTSTRAP`.`pg_rpo`               : recovery point objective, 1MB data loss at most by default
- `PGSQL`.`PG_BOOTSTRAP`.`pg_pwd_enc`           : algorithm for encrypting passwords: md5|scram-sha-256
- `PGSQL`.`PG_BOOTSTRAP`.`pgbouncer_log_dir`    : pgbouncer log dir, `/var/log/pgbouncer` by default
- `PGSQL`.`PG_BOOTSTRAP`.`pgbouncer_auth_query` : if enabled, query pg_authid table to retrieve biz users instead of populating userlist
- `PGSQL`.`PG_BOOTSTRAP`.`pgbouncer_sslmode`    : SSL for pgbouncer client: disable|allow|prefer|require|verify-ca|verify-full
- `PGSQL`.`PG_BOOTSTRAP`.`pg_default_service_dest` : default service destination if svc.dest='default'
- `PGSQL`.`PG_BACKUP`.`pgbackrest_enabled`      : pgbackrest enabled ?
- `PGSQL`.`PG_BACKUP`.`pgbackrest_clean`        : remove pgbackrest data during init ?
- `PGSQL`.`PG_BACKUP`.`pgbackrest_log_dir`      : pgbackrest log dir, `/pg/log` by default
- `PGSQL`.`PG_BACKUP`.`pgbackrest_method`       : pgbackrest backup repo method, local or minio
- `PGSQL`.`PG_BACKUP`.`pgbackrest_repo`         : pgbackrest backup repo config
- `PGSQL`.`PG_DNS`.`pg_dns_suffix`              : pgsql dns suffix, '' by default
- `PGSQL`.`PG_DNS`.`pg_dns_target`              : auto, primary, vip, none, or ad hoc ip
- `ETCD`: 10 parameters
- `MINIO`: 15 parameters

**Removed Parameters**

- `INFRA`.`DCS`: removed, replaced by `ETCD`
- `INFRA`.`CA`.`ca_homedir`: ca home dir, now fixed as `/etc/pki/`
- `INFRA`.`CA`.`ca_cert`: ca cert filename, now fixed as `ca.key`
- `INFRA`.`CA`.`ca_key`: ca key filename, now fixed as `ca.key`
- `INFRA`.`REPO`.`repo_upstreams`: replaced by `repo_upstream`
- `PGSQL`.`PG_INSTALL`.`pgdg_repo`: now taken care by node playbooks
- `PGSQL`.`PG_INSTALL`.`pg_add_repo`: now taken care by node playbooks
- `PGSQL`.`PG_IDENTITY`.`pg_backup`: not used and conflict with section name
- `PGSQL`.`PG_IDENTITY`.`pg_preflight_skip`: not used anymore, replace by `pg_id`

**Renamed Parameters**

- `nginx_upstream`            -> `infra_portal`
- `repo_address`              -> `repo_endpoint`
- `pg_hostname`               -> `node_id_from_pg`
- `pg_sindex`                 -> `pg_group`
- `pg_services`               -> `pg_default_services`
- `pg_services_extra`         -> `pg_services`
- `pg_hba_rules_extra`        -> `pg_hba_rules`
- `pg_hba_rules`              -> `pg_default_hba_rules`
- `pgbouncer_hba_rules_extra` -> `pgb_hba_rules`
- `pgbouncer_hba_rules`       -> `pgb_default_hba_rules`
- `vip_mode`                  -> `pg_vip_enabled`
- `vip_address`               -> `pg_vip_address`
- `vip_interface`             -> `pg_vip_interface`
- `node_packages_default`     -> `node_default_packages`
- `node_packages_meta`        -> `infra_packages`
- `node_packages_meta_pip`    -> `infra_packages_pip`
- `node_data_dir`             -> `node_data`

**Checksums**

```
MD5 (pigsty-pkg-v2.0.0-b6.el7.x86_64.tgz) = af4b5db9dc38c860de609956a8f1f0d3
MD5 (pigsty-pkg-v2.0.0-b6.el8.x86_64.tgz) = 5b7152e142df3e3cbc06de30bd70e433
MD5 (pigsty-pkg-v2.0.0-b6.el9.x86_64.tgz) = 1362e2a5680fc1a3a014cc4f304100bd
```


------------------------

## v1.5.1

WARNING: `CREATE INDEX|REINDEX CONCURRENTLY` PostgreSQL 14.0 - 14.3 may lead to index data corruption!

Please upgrade postgres to 14.4 ASAP.

**Software Upgrade**

* upgrade postgres to 14.4 (important bug fix)
* upgrade citus to 11.0-2 (with enterprise features)
* upgrade timescaledb to 2.7 (more continuous aggregates)
* Upgrade patroni to 2.1.4 (new sync health-check)
* Upgrade haproxy to 2.6.0 (cli, reload, ssl,...)
* Upgrade grafana to 9.0.0 (new ui)
* Upgrade prometheus 2.36.0

**Bug fix**

* Fix typo in `pgsql-migration.yml`
* remove pid file in haproxy config
* remove i686 packages when using repotrack under el7
* Fix redis service systemctl enabled issue
* Fix patroni systemctl service enabled=no by default issue
* stop vip-manager when purging existing postgres

**API Changes**

* Mark `grafana_database` and `grafana_pgurl` as obsolete
* Add some new etcd & pgsql alias (optional)

**New Apps**

* wiki.js : Local wiki with Postgres
* FerretDB : MongoDB API over Postgres



------------------------

## v1.5.0

**Highlights**

* Complete Docker Support, enable on meta nodes by default with lot's of software templates.
  * bytebase pgadmin4 pgweb postgrest kong minio,...
* Infra Self Monitoring: Nginx, ETCD, Consul, Grafana, Prometheus, Loki, etc...
* New CMDB design compatible with redis & greenplum, visualize with CMDB Overview
* Service Discovery : Consul SD now works again for prometheus targets management
* Redis playbook now works on single instance with `redis_port` option.
* Better cold backup support: crontab for backup, delayed standby with `pg_delay`
* Use ETCD as DCS, alternative to Consul
* Nginx Log Enhancement

**Monitoring**

***Dashboards***

* CMDB Overview: Visualize CMDB Inventory
* DCS Overview: Show consul & etcd metrics
* Nginx Overview: Visualize nginx metrics & access/error logs
* Grafana Overview: Grafana self Monitoring
* Prometheus Overview：Prometheus self Monitoring
* INFRA Dashboard & Home Dashboard Reforge

***Architecture***

* Infra monitoring targets now have a separated target dir `targets/infra`
* Consul SD is available for prometheus
* etcd , consul , patroni, docker metrics
* Now infra targets are managed by role `infra_register`
* Upgrade pg_exporter to v0.5.0 with `scale` and `default` support
  * `pg_bgwriter`, `pg_wal`, `pg_query`, `pg_db`, `pgbouncer_stat` now use seconds instead of ms and µs
  * `pg_table` counters now have default value 0 instead of NaN
  * `pg_class` is replaced by `pg_table` and `pg_index`
  * `pg_table_size` is now enabled with 300s ttl 

***Provisioning***

* New optional package `docker.tgz` contains: Pgadmin, Pgweb, Postgrest, ByteBase, Kong, Minio, etc.
* New Role `etcd` to deploy & monitor etcd dcs service
* Specify which type of DCS to use with `pg_dcs_type` (`etcd` now available)
* Add `pg_checksum` option to enable data checksum
* Add `pg_delay` option to setup delayed standby leaders 
* Add `node_crontab` and `node_crontab_overwrite` to create routine jobs such as cold backup
* Add a series of `*_enable` options to control  components
* Loki and Promtail are now installed using the RPM package made by `frpm`.
* Allow customize monitoring logo

***Software Updates***

* Upgrade PostgreSQL to 14.3
* Upgrade Redis to 6.2.7
* Upgrade PG Exporter to 0.5.0
* Upgrade Consul to 1.12.0
* Upgrade vip-manager to v1.0.2
* Upgrade Grafana to v8.5.2
* Upgrade HAproxy to 2.5.7 without rsyslog dependency
* Upgrade Loki & Promtail to v2.5.0 with RPM packages
* New packages: `pg_probackup`

New software / application based on docker:
* bytebase : DDL Schema Migrator
* pgadmin4 : Web Admin UI for PostgreSQL
* pgweb : Web Console for PostgreSQL
* postgrest : Auto generated REST API for PostgreSQL
* kong : API Gateway which use PostgreSQL as backend storage
* swagger openapi : API Specification Generator
* Minio : S3-compatible object storage
* Gitea : Private local git service

**Bug Fix**

* Fix loki & promtail `/etc/default` config file name issue
* Now `node_data_dir (/data)` is created before consul init if not exists
* Fix haproxy silence `/var/log/messages` with inappropriate rsyslog dependency


**API Change**

***New Variable***

* `node_data_dir` : major data mount path, will be created if not exist. 
* `node_crontab_overwrite` : overwrite `/etc/crontab` instead of append
* `node_crontab`: node crontab to be appended or overwritten
* `nameserver_enabled`: enable nameserver on this meta node?
* `prometheus_enabled`: enable prometheus on this meta node?
* `grafana_enabled`: enable grafana on this meta node?
* `loki_enabled`: enable loki on this meta node?
* `docker_enable`: enable docker on this node?
* `consul_enable`: enable consul server/agent?
* `etcd_enable`: enable etcd server/clients?
* `pg_checksum`: enable pg cluster data-checksum?
* `pg_delay`: recovery min apply delay for standby leader
* `grafana_customize_logo`: customize grafana icon

***Reforge***

Now `*_clean` are boolean flags to clean up existing instance during init.

And `*_safeguard` are boolean flags to avoid purging running instance when executing any playbook.

- `pg_exists_action` -> `pg_clean`
- `pg_disable_purge` -> `pg_safeguard`
- `dcs_exists_action` -> `dcs_clean`
- `dcs_disable_purge` -> `dcs_safeguard`

***Rename***

- `node_ntp_config` -> `node_ntp_enabled`
- `node_admin_setup` -> `node_admin_enabled`
- `node_admin_pks` -> `node_admin_pk_list`
- `node_dns_hosts` -> `node_etc_hosts_default`
- `node_dns_hosts_extra` -> `node_etc_hosts`
- `node_dns_server` -> `node_dns_method`
- `node_local_repo_url` -> `node_repo_local_urls`
- `node_packages` -> `node_packages_default`
- `node_extra_packages` -> `node_packages`
- `node_meta_pip_install` -> `node_packages_meta_pip`
- `node_sysctl_params` -> `node_tune_params`
- `app_list` -> `nginx_indexes`
- `grafana_plugin` -> `grafana_plugin_method`
- `grafana_cache` -> `grafana_plugin_cache`
- `grafana_plugins` -> `grafana_plugin_list`
- `grafana_git_plugin_git` -> `grafana_plugin_git`
- `haproxy_admin_auth_enabled` -> `haproxy_auth_enabled`
- `pg_shared_libraries` -> `pg_libs`
- `dcs_type` -> `pg_dcs_type`




------------------------


## v1.4.1

Routine bug fix / Docker Support / English Docs

Now docker is enabled on meta node by default. You can launch ton's of SaaS with it

English document is available now.

* [add docker to default packages](https://github.com/Vonng/pigsty/commit/68f8c8da0576e043686137aca47bad01dd4e82c0)
* [add docker-compose to default pacakge list](https://github.com/Vonng/pigsty/commit/765077744836d8600a8703dce8623182784d65a7)
* [disable nameserver by default & enable docker role by default](https://github.com/Vonng/pigsty/commit/9b8b7c5209d09049716318b624001de3b567452a)


**Bug Fix**

* [fix promtail & loki config var issue](https://github.com/Vonng/pigsty/commit/100f31842d473001f946200d9b8e2e3e89add35a)
* Fix grafana legacy alerts.
* Disable nameserver by default
* Rename pg-alias.sh for patroni shortcuts
* [disable exemplars queries for all dashboards](https://github.com/Vonng/pigsty/commit/62d74f15f8c164e5971d9d1d1215869359267b53)
* [fix loki data dir issue](https://github.com/Vonng/pigsty/commit/b277f488b7ed0fd0a7eeeb995e2efd75a048e0ef) https://github.com/Vonng/pigsty/issues/100
* [change autovacuum_freeze_max_age from 100000000 to 1000000000](https://github.com/Vonng/pigsty/commit/1690b490205af24d5f0394aba99007c0d9ebc49d)



------------------------


## v1.4.0

**Architecture**

* Decouple system into 4 major categories:  `INFRA`, `NODES`, `PGSQL`, `REDIS`, which makes pigsty far more clear and more extensible.
* Single Node Deployment = `INFRA` + `NODES` + `PGSQL`
* Deploy pgsql clusters = `NODES` + `PGSQL`
* Deploy redis clusters = `NODES` + `REDIS`
* Deploy other databases = `NODES` + xxx (e.g `MONGO`, `KAFKA`, ... TBD)


**Accessibility**

* CDN for mainland China.
* Get the latest source with `bash -c "$(curl -fsSL http://download.pigsty.cc/get)"`
* Download & Extract packages with new `download` script.


**Monitor Enhancement**

* Split monitoring system into 5 major categories:  `INFRA`, `NODES`, `REDIS`, `PGSQL`, `APP`
* Logging enabled by default
  * now `loki` and `promtail` are enabled by default. with prebuilt [loki-rpm](https://github.com/Vonng/loki-rpm)
* Models & Labels
  * A hidden `ds` prometheus datasource variable is added for all dashboards, so you can easily switch different datasource simply by select a new one rather than modifying Grafana Datasources & Dashboards
  * An `ip` label is added for all metrics, and will be used as join key between database metrics & nodes metrics
* INFRA Monitoring
  * Home dashboard for infra: INFRA Overview
  * Add logging Dashboards : Logs Instance
  * PGLOG Analysis & PGLOG Session now treated as an example Pigsty APP.
* NODES Monitoring Application
  * If you don't care database at all, Pigsty now can be used as host monitoring software alone!
  * Consist of 4 core dashboards: Nodes Overview & Nodes Cluster & Nodes Instance & Nodes Alert
  * Introduce new identity variables for nodes: `node_cluster` and `nodename`
  * Variable `pg_hostname` now means set hostname same as postgres instance name to keep backward-compatible
  * Variable `nodename_overwrite` control whether overwrite node's hostname with nodename
  * Variable `nodename_exchange` will write nodename to each other's `/etc/hosts`
  * All nodes metrics reference are overhauled, join by `ip`
  * Nodes monitoring targets are managed alone under `/etc/prometheus/targets/nodes`
* PGSQL Monitoring Enhancement
  * Complete new PGSQL Cluster which simplify and focus on important stuff among cluster.
  * New Dashboard PGSQL Databases which is cluster level object monitoring. Such as tables & queries among the entire cluster rather than single instance.
  * PGSQL Alert dashboard now only focus on pgsql alerts.
  * PGSQL Shard are added to PGSQL
* Redis Monitoring Enhancement
  * Add nodes monitoring for all redis dashboards.


**MatrixDB Support**

* MatrixDB (Greenplum 7) can be deployed via `pigsty-matrix.yml` playbook
* MatrixDB Monitor Dashboards : PGSQL MatrixDB
* Example configuration added: `pigsty-mxdb.yml`


**Provisioning Enhancement**

Now pigsty work flow works as this:

```bash
 infra.yml ---> install pigsty on single meta node
      |          then add more nodes under pigsty's management
      |
 nodes.yml ---> prepare nodes for pigsty (node setup, dcs, node_exporter, promtail)
      |          then choose one playbook to deploy database clusters on those nodes
      |
      ^--> pgsql.yml   install postgres on prepared nodes
      ^--> redis.yml   install redis on prepared nodes

infra-demo.yml = 
           infra.yml -l meta     +
           nodes.yml -l pg-test  +
           pgsql.yml -l pg-test +
           infra-loki.yml + infra-jupyter.yml + infra-pgweb.yml
 
```

* `nodes.yml` to setup & prepare nodes for pigsty
  *  setup node, node_exporter, consul agent on nodes
  * `node-remove.yml` are used for node de-register
* `pgsql.yml` now only works on prepared nodes
  * `pgsql-remove` now  only responsible for postgres itself. (dcs and node monitor are taken by `node.yml`)
  * Add a series of new options to reuse `postgres` role in greenplum/matrixdb
* `redis.yml` now works on prepared nodes
  * and `redis-remove.yml` now remove redis from nodes.
* `pgsql-matrix.yml` now install matrixdb (Greenplum 7) on prepared nodes.

**Software Upgrade**

* PostgreSQL  14.2
* PostGIS 3.2
* TimescaleDB 2.6
* Patroni 2.1.3 (Prometheus Metrics + Failover Slots)
* HAProxy 2.5.5  (Fix stats error, more metrics)
* PG Exporter 0.4.1 (Timeout Parameters, and)
* Grafana 8.4.4
* Prometheus 2.33.4
* Greenplum 6.19.4 / MatrixDB 4.4.0
* Loki are now shipped as rpm packages instead of zip archives


**Bug Fix**

* Remove consul dependency for patroni , which makes it much more easier to migrate to a new consul cluster
* Fix prometheus bin/new scripts default data dir path : `/export/prometheus` to `/data/prometheus`
* Fix typos and tasks
* Add restart seconds to vip-manager systemd service


**API Changes**

New Variable

* `node_cluster`: Identity variable for node cluster
* `nodename_overwrite`: If set, nodename will be set to node's hostname
* `nodename_exchange` : exchange node hostname (in `/etc/hosts`) among play hosts
* `node_dns_hosts_extra` : extra static dns records which can be easily overwritten by single instance/cluster
* `patroni_enabled`: if disabled, postgres & patroni bootstrap will not be performed during role `postgres`
* `pgbouncer_enabled` : if disabled, pgbouncer will not be launched during role `postgres`
* `pg_exporter_params`: extra url parameters for pg_exporter when generating monitor target url.
* `pg_provision`: bool var to indicate whether perform provision part of role `postgres` (template, db,user)
* `no_cmdb`: cli args for `infra.yml` and `infra-demo.yml` playbook which will not create cmdb on meta node.

```
MD5 (app.tgz) = f887313767982b31a2b094e5589a75ea
MD5 (matrix.tgz) = 3d063437c482d94bd7e35df1a08bbc84
MD5 (pigsty.tgz) = e143b88ebea1474f9ebaffddc6072c49
MD5 (pkg.tgz) = 73e8f5ce995b1f1760cb63c1904fb91b
```



------------------------


## v1.3.1

[Monitor]
* PGSQL & PGCAT Dashboard polish
* optimize layout for pgcat instance & pgcat database
* add key metrics panels to pgsql instance dashboard, keep consist with pgsql cluster
* add table/index bloat panels to pgcat database, remove pgcat bloat dashboard.
* add index information in pgcat database dashboard
* fix broken panels in grafana 8.3
* add redis index in nginx homepage

[Deploy]
* New `infra-demo.yml` playbook for one-pass bootstrap
* Use `infra-jupyter.yml` playbook to deploy optional jupyter lab server
* Use `infra-pgweb.yml` playbook to deploy optional pgweb server
* New `pg` alias on meta node, can initiate postgres cluster from admin user (in addition to postgres)
* Adjust all patroni conf templates's `max_locks_per_transactions` according to `timescaledb-tune` 's advise
* Add `citus.node_conninfo: 'sslmode=prefer'` to conf templates in order to use citus without SSL
* Add all extensions (except for pgrouting) in pgdg14 in package list
* Upgrade node_exporter to v1.3.1
* Add PostgREST v9.0.0 to package list. Generate API from postgres schema.


[BugFix]
* Grafana's security breach (upgrade to v8.3.1 [issue](https://grafana.com/blog/2021/12/07/grafana-8.3.1-8.2.7-8.1.8-and-8.0.7-released-with-high-severity-security-fix/))
* fix `pg_instance` & `pg_service` in `register` role when start from middle of playbook
* Fix nginx homepage render issue when host without `pg_cluster` variable exists
* Fix style issue when upgrading to grafana 8.3.1



## v1.3.0

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


------------------------

## v1.2.0

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


------------------------

## v1.1.1

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


------------------------



## v1.1.0


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


------------------------



## v1.0.1

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



------------------------



## v1.0.0

v1 GA, Monitoring System Overhaul

**Highlights**

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


**API Change**

* new var :  [`node_meta_pip_install`](http://doc.pigsty.cc/#/zh-cn/v-node?id=node_meta_pip_install)
* rename var: `grafana_url` to [`grafana_endpoint`](http://doc.pigsty.cc/#/zh-cn/v-meta?id=grafana_endpoint)
* new var: [`grafana_admin_username`](http://doc.pigsty.cc/#/zh-cn/v-meta?id=grafana_admin_username)
* new var: [`grafana_database`](http://doc.pigsty.cc/#/zh-cn/v-meta?id=grafana_database)
* new var: [`grafana_pgurl`](http://doc.pigsty.cc/#/zh-cn/v-meta?id=grafana_pgurl)
* new var: [`pg_shared_libraries`](http://doc.pigsty.cc/#/zh-cn/v-pg-provision?id=pg_shared_libraries)
* new var: [`pg_exporter_auto_discovery`](http://doc.pigsty.cc/#/zh-cn/v-monitor?id=pg_exporter_auto_discovery)
* new var: [`pg_exporter_exclude_database`](http://doc.pigsty.cc/#/zh-cn/v-monitor?id=pg_exporter_exclude_database)
* new var: [`pg_exporter_include_database`](http://doc.pigsty.cc/#/zh-cn/v-monitor?id=pg_exporter_include_database)


**Bug Fix**

* Fix default timezone Asia/Shanghai (CST) issue
* Fix nofile limit for pgbouncer & patroni
* Pgbouncer userlist & database list will be generated when executing tag `pgbouncer`




------------------------


## v0.9.0

Pigsty GUI, CLI, Logging Intergration

<details>

**Features**

* One-Line Installation

  Run this on meta node `/bin/bash -c "$(curl -fsSL https://pigsty.cc/install)"`

* MetaDB provisioning

  Now you can use pgsql database on meta node as inventory instead of static yaml file affter bootstrap.

* Add Loki & Prometail as optinal logging collector

  Now you can view, query, search postgres|pgbouncer|patroni logs with Grafana UI (PG Instance Log)

* Pigsty CLI/GUI (beta)

  Mange you pigsty deployment with much more human-friendly command line interface.

**Bug Fix**

* Log related issues
  * fix `connection reset by peer` entries in postgres log caused by Haproxy health check.
  * fix `Connect Reset Exception` in patroni logs caused by haproxy health check
  * fix patroni log time format (remove mill seconds, add timezone)
  * set `log_min_duration_statement=1s` for `dbuser_monitor` to get ride of monitor logs.
* Fix `pgbouncer-create-user` does not handle md5 password properly
* Fix obsolete `Makefile` entries
* Fix node dns nameserver lost when abort during resolv.conf rewrite
* Fix db/user template and entry not null check

**API Change**

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

</details>






------------------------



## v0.8.0

Service Provisioning support is added in this release

<details>

**New Features**

* Service provision.
* full locale support.

**API Changes**

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

**Service**

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

**Database**

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

</details>





------------------------



## v0.7.0

Monitor only deployment support

<details>

**Overview**

* Monitor Only Deployment
  * Now you can monitoring existing postgres clusters without Pigsty provisioning solution.
  * Intergration with other provisioning solution is available and under further test.

* Database/User Management
  * Update user/database definition schema to cover more usecases.
  * Add `pgsql-createdb.yml` and `pgsql-user.yml` to mange user/db on running clusters.

**Features**

* [Monitor Only Deployment Support #25](https://github.com/Vonng/pigsty/issues/25)
* [Split monolith static monitor target file into per-cluster conf #36](https://github.com/Vonng/pigsty/issues/36)
* [Add create user playbook #29](https://github.com/Vonng/pigsty/issues/29)
* [Add create database playbook #28](https://github.com/Vonng/pigsty/issues/28)
* [Database provisioning interface enhancement #33](https://github.com/Vonng/pigsty/issues/33)
* [User provisioning interface enhancement #34](https://github.com/Vonng/pigsty/issues/34)


**Bug Fix**

* [Create extension with schema typo #32](https://github.com/Vonng/pigsty/issues/32)
* [pgbouncer reload with systemctl not work #35](https://github.com/Vonng/pigsty/issues/35)



**API Changes**

***New Options***

```yml
prometheus_sd_target: batch                   # batch|single
exporter_install: none                        # none|yum|binary
exporter_repo_url: ''                         # add to yum repo if set
node_exporter_options: '--no-collector.softnet --collector.systemd --collector.ntp --collector.tcpstat --collector.processes'                          # default opts for node_exporter
pg_exporter_url: ''                           # optional, overwrite default pg_exporter target
pgbouncer_exporter_url: ''                    # optional, overwrite default pgbouncer_expoter target
```

***Remove Options***

```yml
exporter_binary_install: false                 # covered by exporter_install
```

***Structure Changes***

```yaml
pg_default_roles                               # refer to pg_users
pg_users                                       # refer to pg_users
pg_databases                                   # refer to pg_databases
```

***Rename Options***

```yml
pg_default_privilegs -> pg_default_privileges  # fix typo
```


**Enhancement**

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



**API Change**

***New Config Entries***

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

***Obsolete Config Entries***

```yaml
prometheus_metrics_path                       # duplicate with exporter_metrics_path 
prometheus_retention                          # covered by `prometheus_options`
```


**Database Definition**

[Database provisioning interface enhancement #33](https://github.com/Vonng/pigsty/issues/33)

***Old Schema***

```yaml
pg_databases:                       # create a business database 'meta'
  - name: meta
    schemas: [meta]                 # create extra schema named 'meta'
    extensions: [{name: postgis}]   # create extra extension postgis
    parameters:                     # overwrite database meta's default search_path
      search_path: public, monitor
```

***New Schema***

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

**Changes**

* Add new options: `template` , `encoding`, `locale`, `allowconn`, `tablespace`, `connlimit`
* Add new option `revokeconn`, which revoke connect privileges from public for this database
* Add `comment` field for database

***Apply Changes***

You can create new database on running postgres clusters with `pgsql-createdb.yml` playbook.
1. Define your new database in config files
2. Pass new database.name with option `pg_database` to playbook.

```bash
./pgsql-createdb.yml -e pg_database=<your_new_database_name>
```


**User Definition**

[User provisioning interface enhancement #34](https://github.com/Vonng/pigsty/issues/34)

***Old Schema***

```yaml
pg_users:
  - username: test                  # example production user have read-write access
    password: test                  # example user's password
    options: LOGIN                  # extra options
    groups: [ dbrole_readwrite ]    # dborole_admin|dbrole_readwrite|dbrole_readonly
    comment: default test user for production usage
    pgbouncer: true                 # add to pgbouncer
```

***New Schema***

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

**Changes**

* `username` field rename to `name`
* `groups` field rename to `roles`
* `options` now split into separated configration entries:
  `login`, `superuser`, `createdb`, `createrole`, `inherit`, `replication`,`bypassrls`,`connlimit`
* `expire_at` and `expire_in` options
* `pgbouncer` option for user is now `false` by default

**Apply Changes**

You can create new users on running postgres clusters with `pgsql-createuser.yml` playbook.
1. Define your new users in config files (`pg_users`)
2. Pass new user.name with option `pg_user` to playbook.

```bash
./pgsql-createuser.yml -e pg_user=<your_new_user_name>
```

</details>




------------------------




## v0.6.0

Architecture Enhancement

<details>

**Bug Fix**

* [pg_hba reset on patroni restart (patroni 2.0) #5](https://github.com/Vonng/pigsty/issues/5)
* Merge [Fix name of dashboard #1](https://github.com/Vonng/pigsty/pull/1), Fix PG Overview Dashboard typo
* Fix default primary instance to `pg-test-1` of cluster `pg-test` in sandbox environment
* Fix obsolete comments


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


**API Change**

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

</details>


------------------------


## v0.5.0

Pigsty now have an [Official Site](http://pigsty.cc/) 🎉 !

<details>

**New Features**

* Add Database Provision Template
* Add Init Template
* Add Business Init Template
* Refactor HBA Rules variables
* Fix dashboards bugs.
* Move `pg-cluster-replication` to default dashboards
* Use ZJU PostgreSQL mirror as default to accelerate repo build phase.
* Move documentation to official site:  https://pigsty.cc
* Download newly created offline installation packages:  [pkg.tgz](https://github.com/Vonng/pigsty/releases/download/v0.5.0/pkg.tgz) (v0.5)

**Database Provision Template**

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
[pg-init-business.sql](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/pg-init-business.sql) will be used as default business database init script


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
</details>


------------------------

## v0.4.0

The second public beta (v0.4.0) of pigsty is available now ! 🎉

<details>

**Monitoring System**

Skim version of monitoring system consist of 10 essential dashboards:

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

**Software upgrade**

* Upgrade to PostgreSQL 13.1, Patroni 2.0.1-4, add citus to repo.
* Upgrade to [`pg_exporter 0.3.1`](https://github.com/Vonng/pg_exporter/releases/tag/v0.3.1)
* Upgrade to Grafana 7.3, Ton's of compatibility work
* Upgrade to prometheus 2.23, with new UI as default
* Upgrade to consul 1.9

**Misc**

* Update prometheus alert rules
* Fix alertmanager info links
* Fix bugs and typos.
* add a simple backup script

**Offline Installation**

* [pkg.tgz](https://github.com/Vonng/pigsty/releases/download/v0.4.0/pkg.tgz) is the latest offline install package (1GB rpm packages, made under CentOS 7.8)

</details>

------------------------


## v0.3.0

The first public beta (v0.3.0) of pigsty is available now ! 🎉

<details>

**Monitoring System**

**Skim version of monitoring system** consist of 8 essential dashboards:

* PG Overview
* PG Cluster
* PG Service
* PG Instance
* PG Database
* PG Table Overview
* PG Table Catalog
* Node

**Database Cluster Provision**

* All config files are merged into one file: `conf/all.yml` by default
* Use `infra.yml` to provision meta node(s) and infrastructure
* Use `initdb.yml` to provision database clusters
* Use `ins-add.yml` to add new instance to database cluster
* Use `ins-del.yml` to remove instance from database cluster


**Offline Installation**

* [pkg.tgz](https://github.com/Vonng/pigsty/releases/download/v0.3.0/pkg.tgz) is the latest offline install package (1GB rpm packages, made under CentOS 7.8)

</details>