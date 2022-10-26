# Parameters

There are 241 available parameters divide into 4 categories and 32 sections. 

## Category

| Category          | Section                                       | Description                        | Count |
|-------------------|-----------------------------------------------|------------------------------------|:-----:|
| [`INFRA`](#infra) | [`META`](#META)                               | Metadata of deployment             |   4   |
| [`INFRA`](#infra) | [`CONNECT`](#CONNECT)                         | Connection parameters              |   1   |
| [`INFRA`](#infra) | [`REPO`](#REPO)                               | Local source infra                 |   7   |
| [`INFRA`](#infra) | [`CA`](#CA)                                   | Public-Private Key Infra           |   5   |
| [`INFRA`](#infra) | [`NGINX`](#NGINX)                             | Nginx Web Server                   |   5   |
| [`INFRA`](#infra) | [`NAMESERVER`](#NAMESERVER)                   | DNS Server                         |   2   |
| [`INFRA`](#infra) | [`PROMETHEUS`](#PROMETHEUS)                   | Monitoring Time Series Database    |   8   |
| [`INFRA`](#infra) | [`EXPORTER`](#EXPORTER)                       | Universal Exporter Config          |   3   |
| [`INFRA`](#infra) | [`GRAFANA`](#GRAFANA)                         | Grafana Visualization Platform     |   9   |
| [`INFRA`](#infra) | [`LOKI`](#LOKI)                               | Loki log collection platform       |   6   |
| [`INFRA`](#infra) | [`DCS`](#DCS)                                 | Distributed Config Storage Meta DB |   7   |
| [`NODES`](#nodes) | [`NODE_IDENTITY`](#NODE_IDENTITY)             | Node identity parameters           |   5   |
| [`NODES`](#nodes) | [`NODE_DNS`](#NODE_DNS)                       | Node Domain Name Resolution        |   5   |
| [`NODES`](#nodes) | [`NODE_REPO`](#NODE_REPO)                     | Node Upstream Repo                 |   3   |
| [`NODES`](#nodes) | [`NODE_PACKAGE`](#NODE_PACKAGE)               | Node Packages                      |   4   |
| [`NODES`](#nodes) | [`NODE_KERNEL_MODULES`](#NODE_KERNEL_MODULES) | Node Kernel Module                 |   1   |
| [`NODES`](#nodes) | [`NODE_TUNE`](#NODE_TUNE)                     | Node parameter tuning              |   9   |
| [`NODES`](#nodes) | [`NODE_ADMIN`](#NODE_ADMIN)                   | Node Admin User                    |   7   |
| [`NODES`](#nodes) | [`NODE_TIME`](#NODE_TIME)                     | Node time zone and time sync       |   6   |
| [`NODES`](#nodes) | [`DOCKER`](#DOCKER)                           | Docker daemon on node              |   4   |
| [`NODES`](#nodes) | [`NODE_EXPORTER`](#NODE_EXPORTER)             | Node Indicator Exposer             |   3   |
| [`NODES`](#nodes) | [`PROMTAIL`](#PROMTAIL)                       | Log collection component           |   5   |
| [`PGSQL`](#pgsql) | [`PG_IDENTITY`](#PG_IDENTITY)                 | PGSQL Identity Parameters          |  13   |
| [`PGSQL`](#pgsql) | [`PG_BUSINESS`](#PG_BUSINESS)                 | PGSQL Business Object Definition   |  11   |
| [`PGSQL`](#pgsql) | [`PG_INSTALL`](#PG_INSTALL)                   | PGSQL Installation                 |  12   |
| [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)               | PGSQL Cluster Initialization       |  38   |
| [`PGSQL`](#pgsql) | [`PG_PROVISION`](#PG_PROVISION)               | PGSQL Cluster Provisioning         |   9   |
| [`PGSQL`](#pgsql) | [`PG_EXPORTER`](#PG_EXPORTER)                 | PGSQL Indicator Exposer            |  13   |
| [`PGSQL`](#pgsql) | [`PG_SERVICE`](#PG_SERVICE)                   | PGSQL Service Access               |  16   |
| [`REDIS`](#redis) | [`REDIS_IDENTITY`](#REDIS_IDENTITY)           | REDIS Identity Parameters          |   3   |
| [`REDIS`](#redis) | [`REDIS_PROVISION`](#REDIS_PROVISION)         | REDIS Cluster Provisioning         |  14   |
| [`REDIS`](#redis) | [`REDIS_EXPORTER`](#REDIS_EXPORTER)           | REDIS Indicator Exposer            |   3   |



## Index

| ID  | Name                                                            | Section                               | Type        | Level | Comment                                                        |
|-----|-----------------------------------------------------------------|---------------------------------------|-------------|-------|----------------------------------------------------------------|
| 100 | [`version`](#)                                                  | [`META`](#meta)                       | string      | G     | pigsty version string                                          |
| 101 | [`meta_ip`](#)                                                  | [`META`](#meta)                       | ip          | G     | primary meta node ip address                                   |
| 102 | [`region`](#)                                                   | [`META`](#meta)                       | string      | G     | upstream mirror region: default|china|europe                    |
| 103 | [`os_version`](#)                                               | [`META`](#meta)                       | int         | G/C/I | enterprise linux release version: 7,8,9                        |
| 104 | [`proxy_env`](#proxy_env)                                       | [`CONNECT`](#CONNECT)                 | dict        | G     | proxy environment variables                                    |
| 110 | [`ca_method`](#ca_method)                                       | [`CA`](#ca)                           | enum        | G     | ca mode: none,create,copy,recreate                             |
| 111 | [`ca_cn`](#ca_cn)                                               | [`CA`](#ca)                           | string      | G     | ca common name, pigsty-ca by default                           |
| 112 | [`cert_validity`](#cert_validity)                               | [`CA`](#ca)                           | interval    | G     | cert validity, 20 years by default                             |
| 120 | [`nginx_enabled`](#nginx_enabled)                               | [`NGINX`](#nginx)                     | bool        | C/I   | enable nginx web server                                        |
| 121 | [`nginx_home`](#nginx_home)                                     | [`NGINX`](#nginx)                     | path        | G     | nginx home dir (/www)                                          |
| 122 | [`nginx_port`](#nginx_port)                                     | [`NGINX`](#nginx)                     | int         | G     | nginx listen address (80)                                      |
| 123 | [`nginx_upstream`](#nginx_upstream)                             | [`NGINX`](#nginx)                     | upstream[]  | G     | nginx upstream definition                                      |
| 124 | [`nginx_indexes`](#nginx_indexes)                               | [`NGINX`](#nginx)                     | app[]       | G     | nginx index page nav entries                                   |
| 130 | [`repo_name`](#repo_name)                                       | [`REPO`](#repo)                       | string      | G     | local yum repo name                                            |
| 131 | [`repo_address`](#repo_address)                                 | [`REPO`](#repo)                       | string      | G     | external access port of repo                                   |
| 132 | [`repo_rebuild`](#repo_rebuild)                                 | [`REPO`](#repo)                       | bool        | A     | rebuild local yum repo                                         |
| 133 | [`repo_remove`](#repo_remove)                                   | [`REPO`](#repo)                       | bool        | A     | remove existing repo file                                      |
| 134 | [`repo_upstream`](#repo_upstream)                               | [`REPO`](#repo)                       | repo[]      | G     | list of upstream yum repo definition                           |
| 135 | [`repo_packages`](#repo_packages)                               | [`REPO`](#repo)                       | string[]    | G     | packages to be downloaded                                      |
| 136 | [`repo_url_packages`](#repo_url_packages)                       | [`REPO`](#repo)                       | url[]       | G     | pkgs to be downloaded via url                                  |
| 140 | [`nameserver_enabled`](#nameserver_enabled)                     | [`NAMESERVER`](#nameserver)           | bool        | C/I   | enable dnsmasq on meta node                                    |
| 141 | [`dns_records`](#dns_records)                                   | [`NAMESERVER`](#nameserver)           | string[]    | G     | dynamic DNS records                                            |
| 150 | [`prometheus_enabled`](#prometheus_enabled)                     | [`PROMETHEUS`](#prometheus)           | bool        | C/I   | enable Prometheus on meta                                      |
| 151 | [`prometheus_data_dir`](#prometheus_data_dir)                   | [`PROMETHEUS`](#prometheus)           | path        | G     | prometheus data dir                                            |
| 152 | [`prometheus_options`](#prometheus_options)                     | [`PROMETHEUS`](#prometheus)           | string      | G     | prometheus cli args                                            |
| 153 | [`prometheus_reload`](#prometheus_reload)                       | [`PROMETHEUS`](#prometheus)           | bool        | A     | prom reload instead of init                                    |
| 154 | [`prometheus_sd_method`](#prometheus_sd_method)                 | [`PROMETHEUS`](#prometheus)           | enum        | G     | consul                                                         |
| 155 | [`prometheus_scrape_interval`](#prometheus_scrape_interval)     | [`PROMETHEUS`](#prometheus)           | interval    | G     | prom scrape interval (10s)                                     |
| 156 | [`prometheus_scrape_timeout`](#prometheus_scrape_timeout)       | [`PROMETHEUS`](#prometheus)           | interval    | G     | prom scrape timeout (8s)                                       |
| 157 | [`prometheus_sd_interval`](#prometheus_sd_interval)             | [`PROMETHEUS`](#prometheus)           | interval    | G     | prom discovery refresh interval                                |
| 160 | [`exporter_install`](#exporter_install)                         | [`EXPORTER`](#exporter)               | enum        | G     | Installation of exporter                                       |
| 161 | [`exporter_repo_url`](#exporter_repo_url)                       | [`EXPORTER`](#exporter)               | string      | G     | repo url for yum install                                       |
| 162 | [`exporter_metrics_path`](#exporter_metrics_path)               | [`EXPORTER`](#exporter)               | string      | G     | URL path for exporting metrics                                 |
| 170 | [`grafana_enabled`](#grafana_enabled)                           | [`GRAFANA`](#grafana)                 | bool        | C/I   | enable grafana on meta node                                    |
| 171 | [`grafana_endpoint`](#grafana_endpoint)                         | [`GRAFANA`](#grafana)                 | url         | G     | grafana API endpoint                                           |
| 172 | [`grafana_admin_username`](#grafana_admin_username)             | [`GRAFANA`](#grafana)                 | string      | G     | grafana admin username                                         |
| 173 | [`grafana_admin_password`](#grafana_admin_password)             | [`GRAFANA`](#grafana)                 | string      | G     | grafana admin password                                         |
| 174 | [`grafana_database`](#grafana_database)                         | [`GRAFANA`](#grafana)                 | enum        | G     | grafana backend database type                                  |
| 175 | [`grafana_pgurl`](#grafana_pgurl)                               | [`GRAFANA`](#grafana)                 | url         | G     | grafana backend postgres url                                   |
| 176 | [`grafana_plugin_method`](#grafana_plugin_method)               | [`GRAFANA`](#grafana)                 | enum        | G     | Install grafana plugin method                                  |
| 177 | [`grafana_plugin_cache`](#grafana_plugin_cache)                 | [`GRAFANA`](#grafana)                 | path        | G     | grafana plugins cache path                                     |
| 178 | [`grafana_plugin_list`](#grafana_plugin_list)                   | [`GRAFANA`](#grafana)                 | string[]    | G     | grafana plugins to be installed                                |
| 180 | [`loki_enabled`](#loki_enabled)                                 | [`LOKI`](#loki)                       | bool        | C/I   | enable loki on meta node                                       |
| 180 | [`loki_endpoint`](#loki_endpoint)                               | [`LOKI`](#loki)                       | url         | G     | loki endpoint to receive log                                   |
| 181 | [`loki_clean`](#loki_clean)                                     | [`LOKI`](#loki)                       | bool        | A     | remove existing loki data                                      |
| 182 | [`loki_options`](#loki_options)                                 | [`LOKI`](#loki)                       | string      | G     | loki cli args                                                  |
| 183 | [`loki_data_dir`](#loki_data_dir)                               | [`LOKI`](#loki)                       | string      | G     | loki data path                                                 |
| 184 | [`loki_retention`](#loki_retention)                             | [`LOKI`](#loki)                       | interval    | G     | loki log keeping period                                        |
| 190 | [`dcs_name`](#dcs_name)                                         | [`DCS`](#dcs)                         | string      | G     | dcs cluster name                                               |
| 191 | [`dcs_servers`](#dcs_servers)                                   | [`DCS`](#dcs)                         | dict        | G     | dcs server dict                                                |
| 192 | [`dcs_registry`](#dcs_registry)                                 | [`DCS`](#dcs)                         | enum        | G     | Registration Services                                          |
| 193 | [`dcs_gid`](#dcs_gid)                                           | [`DCS`](#dcs)                         | int         | G     | gid for consul/etcd users                                      |
| 194 | [`dcs_ssl_enabled`](#dcs_ssl_enabled)                           | [`DCS`](#dcs)                         | bool        | G     | secure dcs communications with ssl?                            |
| 195 | [`dcs_safeguard`](#dcs_safeguard)                               | [`DCS`](#dcs)                         | bool        | C/A   | avoid dcs remove at all                                        |
| 196 | [`dcs_clean`](#dcs_clean)                                       | [`DCS`](#dcs)                         | bool        | C/A   | purge dcs during init?                                         |
| 201 | [`consul_enabled`](#consul_enabled)                             | [`CONSUL`](#consul)                   | bool        | G     | enable consul servers/agents                                   |
| 202 | [`consul_data_dir`](#consul_data_dir)                           | [`CONSUL`](#consul)                   | string      | G     | consul data dir path                                           |
| 210 | [`etcd_enabled`](#etcd_enabled)                                 | [`ETCD`](#etcd)                       | bool        | G     | enable etcd servers/clients                                    |
| 211 | [`etcd_data_dir`](#etcd_data_dir)                               | [`ETCD`](#etcd)                       | string      | G     | etcd data dir path                                             |
| 300 | [`meta_node`](#meta_node)                                       | [`NODE_IDENTITY`](#node_identity)     | bool        | C     | mark this node as meta                                         |
| 301 | [`nodename`](#nodename)                                         | [`NODE_IDENTITY`](#node_identity)     | string      | I     | node instance identity                                         |
| 302 | [`node_cluster`](#node_cluster)                                 | [`NODE_IDENTITY`](#node_identity)     | string      | C     | node cluster identity                                          |
| 303 | [`nodename_overwrite`](#nodename_overwrite)                     | [`NODE_IDENTITY`](#node_identity)     | bool        | C     | overwrite hostname with nodename                               |
| 304 | [`nodename_exchange`](#nodename_exchange)                       | [`NODE_IDENTITY`](#node_identity)     | bool        | C     | exchange static hostname                                       |
| 310 | [`node_etc_hosts_default`](#node_etc_hosts_default)             | [`NODE_DNS`](#node_dns)               | string[]    | C     | static DNS records                                             |
| 311 | [`node_etc_hosts`](#node_etc_hosts)                             | [`NODE_DNS`](#node_dns)               | string[]    | C/I   | extra static DNS records                                       |
| 312 | [`node_dns_method`](#node_dns_method)                           | [`NODE_DNS`](#node_dns)               | enum        | C     | how to setup dns service?                                      |
| 313 | [`node_dns_servers`](#node_dns_servers)                         | [`NODE_DNS`](#node_dns)               | string[]    | C     | dynamic DNS servers                                            |
| 314 | [`node_dns_options`](#node_dns_options)                         | [`NODE_DNS`](#node_dns)               | string[]    | C     | /etc/resolv.conf options                                       |
| 320 | [`node_repo_method`](#node_repo_method)                         | [`NODE_REPO`](#node_repo)             | enum        | C     | how to use yum repo (local)                                    |
| 321 | [`node_repo_remove`](#node_repo_remove)                         | [`NODE_REPO`](#node_repo)             | bool        | C     | remove existing repo file?                                     |
| 322 | [`node_repo_local_urls`](#node_repo_local_urls)                 | [`NODE_REPO`](#node_repo)             | url[]       | C     | local yum repo url list                                        |
| 330 | [`node_packages_default`](#node_packages_default)               | [`NODE_PACKAGES`](#node_package)      | string[]    | C     | pkgs to be installed on all node                               |
| 331 | [`node_packages`](#node_packages)                               | [`NODE_PACKAGES`](#node_package)      | string[]    | C     | extra pkgs to be installed                                     |
| 332 | [`node_packages_meta`](#node_packages_meta)                     | [`NODE_PACKAGES`](#node_package)      | string[]    | G     | meta node only packages                                        |
| 333 | [`node_packages_meta_pip`](#node_packages_meta_pip)             | [`NODE_PACKAGES`](#node_package)      | string      | G     | meta node pip3 packages                                        |
| 340 | [`node_disable_firewall`](#node_disable_firewall)               | [`NODE_TUNE`](#node_tune)             | bool        | C     | disable firewall?                                              |
| 341 | [`node_disable_selinux`](#node_disable_selinux)                 | [`NODE_TUNE`](#node_tune)             | bool        | C     | disable selinux?                                               |
| 342 | [`node_disable_numa`](#node_disable_numa)                       | [`NODE_TUNE`](#node_tune)             | bool        | C     | disable numa?                                                  |
| 343 | [`node_disable_swap`](#node_disable_swap)                       | [`NODE_TUNE`](#node_tune)             | bool        | C     | disable swap?                                                  |
| 344 | [`node_static_network`](#node_static_network)                   | [`NODE_TUNE`](#node_tune)             | bool        | C     | use static DNS config?                                         |
| 345 | [`node_disk_prefetch`](#node_disk_prefetch)                     | [`NODE_TUNE`](#node_tune)             | bool        | C     | enable disk prefetch?                                          |
| 346 | [`node_kernel_modules`](#node_kernel_modules)                   | [`NODE_TUNE`](#node_tune)             | string[]    | C     | kernel modules to be installed                                 |
| 347 | [`node_tune`](#node_tune)                                       | [`NODE_TUNE`](#node_tune)             | enum        | C     | node tune mode                                                 |
| 348 | [`node_sysctl_params`](#node_sysctl_params)                     | [`NODE_TUNE`](#node_tune)             | dict        | C     | extra kernel parameters                                        |
| 350 | [`node_data_dir`](#node_data_dir)                               | [`NODE_ADMIN`](#node_admin)           | path        | C     | default data disk mountpoint                                   |
| 351 | [`node_admin_enabled`](#node_admin_enabled)                     | [`NODE_ADMIN`](#node_admin)           | bool        | G     | create admin user?                                             |
| 352 | [`node_admin_uid`](#node_admin_uid)                             | [`NODE_ADMIN`](#node_admin)           | int         | G     | admin user UID                                                 |
| 353 | [`node_admin_username`](#node_admin_username)                   | [`NODE_ADMIN`](#node_admin)           | string      | G     | admin user name                                                |
| 354 | [`node_admin_ssh_exchange`](#node_admin_ssh_exchange)           | [`NODE_ADMIN`](#node_admin)           | bool        | C     | exchange admin ssh keys?                                       |
| 355 | [`node_admin_pk_current`](#node_admin_pk_current)               | [`NODE_ADMIN`](#node_admin)           | bool        | A     | pks to be added to admin                                       |
| 356 | [`node_admin_pk_list`](#node_admin_pk_list)                     | [`NODE_ADMIN`](#node_admin)           | key[]       | C     | add current user's pkey?                                       |
| 360 | [`node_timezone`](#node_timezone)                               | [`NODE_TIME`](#node_time)             | string      | C     | node timezone                                                  |
| 361 | [`node_ntp_enabled`](#node_ntp_enabled)                         | [`NODE_TIME`](#node_time)             | bool        | C     | setup ntp on node?                                             |
| 362 | [`node_ntp_service`](#node_ntp_service)                         | [`NODE_TIME`](#node_time)             | enum        | C     | ntp mode: ntp or chrony?                                       |
| 363 | [`node_ntp_servers`](#node_ntp_servers)                         | [`NODE_TIME`](#node_time)             | string[]    | C     | ntp server list                                                |
| 364 | [`node_crontab_overwrite`](#node_crontab_overwrite)             | [`NODE_TIME`](#node_time)             | string[]    | C/I   | overwrite instead of append /etc/crontab                       |
| 365 | [`node_crontab`](#node_crontab)                                 | [`NODE_TIME`](#node_time)             | string[]    | C/I   | crontab list of node                                           |
| 370 | [`docker_enabled`](#docker_enabled)                             | [`DOCKER`](#docker)                   | bool        | C     | docker enabled?                                                |
| 371 | [`docker_cgroups_driver`](#docker_cgroups_driver)               | [`DOCKER`](#docker)                   | int         | C     | docker cgroup driver                                           |
| 372 | [`docker_registry_mirrors`](#docker_registry_mirrors)           | [`DOCKER`](#docker)                   | string      | C     | docker registry mirror location                                |
| 373 | [`docker_image_cache`](#docker_image_cache)                     | [`DOCKER`](#docker)                   | string      | C     | docker image cache tarball                                     |
| 380 | [`node_exporter_enabled`](#node_exporter_enabled)               | [`NODE_EXPORTER`](#node_exporter)     | bool        | C     | node_exporter enabled?                                         |
| 381 | [`node_exporter_port`](#node_exporter_port)                     | [`NODE_EXPORTER`](#node_exporter)     | int         | C     | node_exporter listen port                                      |
| 382 | [`node_exporter_options`](#node_exporter_options)               | [`NODE_EXPORTER`](#node_exporter)     | string      | C/I   | node_exporter extra cli args                                   |
| 390 | [`promtail_enabled`](#promtail_enabled)                         | [`PROMTAIL`](#promtail)               | bool        | C     | promtail enabled ?                                             |
| 391 | [`promtail_clean`](#promtail_clean)                             | [`PROMTAIL`](#promtail)               | bool        | C/A   | remove promtail status file ?                                  |
| 392 | [`promtail_port`](#promtail_port)                               | [`PROMTAIL`](#promtail)               | int         | G     | promtail listen port                                           |
| 393 | [`promtail_options`](#promtail_options)                         | [`PROMTAIL`](#promtail)               | string      | C/I   | promtail cli args                                              |
| 394 | [`promtail_positions`](#promtail_positions)                     | [`PROMTAIL`](#promtail)               | string      | C     | path to store promtail status file                             |
| 500 | [`pg_cluster`](#pg_cluster)                                     | [`PG_IDENTITY`](#pg_identity)         | string      | C     | PG Cluster Name                                                |
| 501 | [`pg_shard`](#pg_shard)                                         | [`PG_IDENTITY`](#pg_identity)         | string      | C     | PG Shard Name (Reserve)                                        |
| 502 | [`pg_sindex`](#pg_sindex)                                       | [`PG_IDENTITY`](#pg_identity)         | int         | C     | PG Shard Index (Reserve)                                       |
| 503 | [`gp_role`](#gp_role)                                           | [`PG_IDENTITY`](#pg_identity)         | enum        | C     | gp role of this PG cluster                                     |
| 504 | [`pg_role`](#pg_role)                                           | [`PG_IDENTITY`](#pg_identity)         | enum        | I     | PG Instance Role                                               |
| 505 | [`pg_seq`](#pg_seq)                                             | [`PG_IDENTITY`](#pg_identity)         | int         | I     | PG Instance Sequence                                           |
| 506 | [`pg_instances`](#pg_instances)                                 | [`PG_IDENTITY`](#pg_identity)         | {port:ins}  | I     | PG instance on this node                                       |
| 507 | [`pg_upstream`](#pg_upstream)                                   | [`PG_IDENTITY`](#pg_identity)         | string      | I     | PG upstream IP                                                 |
| 508 | [`pg_offline_query`](#pg_offline_query)                         | [`PG_IDENTITY`](#pg_identity)         | bool        | I     | allow offline query?                                           |
| 509 | [`pg_backup`](#pg_backup)                                       | [`PG_IDENTITY`](#pg_identity)         | bool        | I     | make base backup on this ins?                                  |
| 510 | [`pg_weight`](#pg_weight)                                       | [`PG_IDENTITY`](#pg_identity)         | int         | I     | relative weight in LB                                          |
| 511 | [`pg_hostname`](#pg_hostname)                                   | [`PG_IDENTITY`](#pg_identity)         | bool        | C/I   | set PG ins name as hostname                                    |
| 512 | [`pg_preflight_skip`](#pg_preflight_skip)                       | [`PG_IDENTITY`](#pg_identity)         | bool        | C/A   | skip preflight param validation                                |
| 520 | [`pg_users`](#pg_users)                                         | [`PG_BUSINESS`](#pg_business)         | user[]      | C     | business users definition                                      |
| 521 | [`pg_databases`](#pg_databases)                                 | [`PG_BUSINESS`](#pg_business)         | database[]  | C     | business databases definition                                  |
| 522 | [`pg_services_extra`](#pg_services_extra)                       | [`PG_BUSINESS`](#pg_business)         | service[]   | C     | ad hoc service definition                                      |
| 523 | [`pg_hba_rules_extra`](#pg_hba_rules_extra)                     | [`PG_BUSINESS`](#pg_business)         | rule[]      | C     | ad hoc HBA rules                                               |
| 524 | [`pgbouncer_hba_rules_extra`](#pgbouncer_hba_rules_extra)       | [`PG_BUSINESS`](#pg_business)         | rule[]      | C     | ad hoc pgbouncer HBA rules                                     |
| 525 | [`pg_admin_username`](#pg_admin_username)                       | [`PG_BUSINESS`](#pg_business)         | string      | G     | admin user's name                                              |
| 526 | [`pg_admin_password`](#pg_admin_password)                       | [`PG_BUSINESS`](#pg_business)         | string      | G     | admin user's password                                          |
| 527 | [`pg_replication_username`](#pg_replication_username)           | [`PG_BUSINESS`](#pg_business)         | string      | G     | replication user's name                                        |
| 528 | [`pg_replication_password`](#pg_replication_password)           | [`PG_BUSINESS`](#pg_business)         | string      | G     | replication user's password                                    |
| 529 | [`pg_monitor_username`](#pg_monitor_username)                   | [`PG_BUSINESS`](#pg_business)         | string      | G     | monitor user's name                                            |
| 530 | [`pg_monitor_password`](#pg_monitor_password)                   | [`PG_BUSINESS`](#pg_business)         | string      | G     | monitor user's password                                        |
| 540 | [`pg_dbsu`](#pg_dbsu)                                           | [`PG_INSTALL`](#pg_install)           | string      | C     | os dbsu for postgres                                           |
| 541 | [`pg_dbsu_uid`](#pg_dbsu_uid)                                   | [`PG_INSTALL`](#pg_install)           | int         | C     | dbsu UID                                                       |
| 542 | [`pg_dbsu_sudo`](#pg_dbsu_sudo)                                 | [`PG_INSTALL`](#pg_install)           | enum        | C     | sudo priv mode for dbsu                                        |
| 543 | [`pg_dbsu_home`](#pg_dbsu_home)                                 | [`PG_INSTALL`](#pg_install)           | path        | C     | home dir for dbsu                                              |
| 544 | [`pg_dbsu_ssh_exchange`](#pg_dbsu_ssh_exchange)                 | [`PG_INSTALL`](#pg_install)           | bool        | C     | exchange dbsu ssh keys?                                        |
| 545 | [`pg_version`](#pg_version)                                     | [`PG_INSTALL`](#pg_install)           | int         | C     | major PG version to be installed                               |
| 546 | [`pgdg_repo`](#pgdg_repo)                                       | [`PG_INSTALL`](#pg_install)           | bool        | C     | add official PGDG repo?                                        |
| 547 | [`pg_add_repo`](#pg_add_repo)                                   | [`PG_INSTALL`](#pg_install)           | bool        | C     | add extra upstream PG repo?                                    |
| 548 | [`pg_bin_dir`](#pg_bin_dir)                                     | [`PG_INSTALL`](#pg_install)           | path        | C     | PG binary dir  `/usr/pgsql/bin` by default                     |
| 549 | [`pg_log_dir`](#pg_log_dir)                                     | [`PG_INSTALL`](#pg_install)           | path        | C     | postgres log dir, `/pg/data/log` by default                    |
| 550 | [`pg_packages`](#pg_packages)                                   | [`PG_INSTALL`](#pg_install)           | string[]    | C     | PG packages to be installed                                    |
| 551 | [`pg_extensions`](#pg_extensions)                               | [`PG_INSTALL`](#pg_install)           | string[]    | C     | PG extension pkgs to be installed                              |
| 560 | [`pg_safeguard`](#pg_safeguard)                                 | [`PG_BOOTSTRAP`](#pg_bootstrap)       | bool        | C/A   | disable pg instance purge                                      |
| 561 | [`pg_clean`](#pg_clean)                                         | [`PG_BOOTSTRAP`](#pg_bootstrap)       | bool        | C/A   | purge existing pgsql during init                               |
| 562 | [`pg_data`](#pg_data)                                           | [`PG_BOOTSTRAP`](#pg_bootstrap)       | path        | C     | pg data dir                                                    |
| 563 | [`pg_fs_main`](#pg_fs_main)                                     | [`PG_BOOTSTRAP`](#pg_bootstrap)       | path        | C     | pg main data disk mountpoint                                   |
| 564 | [`pg_fs_bkup`](#pg_fs_bkup)                                     | [`PG_BOOTSTRAP`](#pg_bootstrap)       | path        | C     | pg backup disk mountpoint                                      |
| 565 | [`pg_storage_type`](#pg_storage_type)                           | [`PG_BOOTSTRAP`](#pg_bootstrap)       | enum        | C     | SSD or HDD, SSD by default                                     |
| 566 | [`pg_dummy_filesize`](#pg_dummy_filesize)                       | [`PG_BOOTSTRAP`](#pg_bootstrap)       | size        | C     | /pg/dummy file size                                            |
| 567 | [`pg_listen`](#pg_listen)                                       | [`PG_BOOTSTRAP`](#pg_bootstrap)       | ip          | C     | pg listen IP                                                   |
| 568 | [`pg_port`](#pg_port)                                           | [`PG_BOOTSTRAP`](#pg_bootstrap)       | int         | C     | pg listen port                                                 |
| 569 | [`pg_localhost`](#pg_localhost)                                 | [`PG_BOOTSTRAP`](#pg_bootstrap)       | ip          | C     | pg's UnixSocket address                                        |
| 580 | [`patroni_enabled`](#patroni_enabled)                           | [`PG_BOOTSTRAP`](#pg_bootstrap)       | bool        | C     | Is patroni & postgres enabled?                                 |
| 581 | [`patroni_mode`](#patroni_mode)                                 | [`PG_BOOTSTRAP`](#pg_bootstrap)       | enum        | C     | patroni working mode                                           |
| 582 | [`pg_dcs_type`](#pg_dcs_type)                                   | [`PG_BOOTSTRAP`](#pg_bootstrap)       | enum        | G     | dcs to be used consul/etcd                                     |
| 583 | [`pg_namespace`](#pg_namespace)                                 | [`PG_BOOTSTRAP`](#pg_bootstrap)       | path        | C     | namespace for patroni                                          |
| 584 | [`patroni_port`](#patroni_port)                                 | [`PG_BOOTSTRAP`](#pg_bootstrap)       | int         | C     | patroni listen port (8080)                                     |
| 585 | [`patroni_log_dir`](#patroni_log_dir)                           | [`PG_BOOTSTRAP`](#pg_bootstrap)       | path        | C     | patroni log dir, `/pg/log` by default                          |
| 586 | [`patroni_ssl_enabled`](#patroni_ssl_enabled)                   | [`PG_BOOTSTRAP`](#pg_bootstrap)       | bool        | C     | secure patroni RestAPI communications with SSL?                |
| 587 | [`patroni_watchdog_mode`](#patroni_watchdog_mode)               | [`PG_BOOTSTRAP`](#pg_bootstrap)       | enum        | C     | patroni watchdog policy                                        |
| 588 | [`patroni_username`](#patroni_username)                         | [`PG_BOOTSTRAP`](#pg_bootstrap)       | string      | C     | patroni rest api username                                      |
| 589 | [`patroni_password`](#patroni_password)                         | [`PG_BOOTSTRAP`](#pg_bootstrap)       | string      | C     | patroni rest api password                                      |
| 600 | [`pg_conf`](#pg_conf)                                           | [`PG_BOOTSTRAP`](#pg_bootstrap)       | string      | C     | patroni template                                               |
| 601 | [`pg_rto`](#pg_rto)                                             | [`PG_BOOTSTRAP`](#pg_bootstrap)       | int         | C     | recovery time objective in secs, failover ttl, 30s             |
| 602 | [`pg_rpo`](#pg_rpo)                                             | [`PG_BOOTSTRAP`](#pg_bootstrap)       | int         | C     | recovery point objective in bytes, max data loss, 1MB          |
| 603 | [`pg_libs`](#pg_libs)                                           | [`PG_BOOTSTRAP`](#pg_bootstrap)       | string      | C     | default preload shared database                                |
| 604 | [`pg_delay`](#pg_delay)                                         | [`PG_BOOTSTRAP`](#pg_bootstrap)       | interval    | I     | apply delay for standby leader                                 |
| 605 | [`pg_checksum`](#pg_checksum)                                   | [`PG_BOOTSTRAP`](#pg_bootstrap)       | bool        | C     | enable data checksum                                           |
| 606 | [`pg_pwd_enc`](#pg_pwd_enc)                                     | [`PG_BOOTSTRAP`](#pg_bootstrap)       | enum        | C     | algorithm for encrypting passwords: md5,scram-sha-256          |
| 607 | [`pg_sslmode`](#pg_sslmode)                                     | [`PG_BOOTSTRAP`](#pg_bootstrap)       | bool        | C     | disable,allow,prefer,require,verify-ca,verify-full             |
| 608 | [`pg_encoding`](#pg_encoding)                                   | [`PG_BOOTSTRAP`](#pg_bootstrap)       | enum        | C     | character encoding                                             |
| 609 | [`pg_locale`](#pg_locale)                                       | [`PG_BOOTSTRAP`](#pg_bootstrap)       | enum        | C     | locale                                                         |
| 610 | [`pg_lc_collate`](#pg_lc_collate)                               | [`PG_BOOTSTRAP`](#pg_bootstrap)       | enum        | C     | collate rule of locale                                         |
| 611 | [`pg_lc_ctype`](#pg_lc_ctype)                                   | [`PG_BOOTSTRAP`](#pg_bootstrap)       | enum        | C     | ctype of locale                                                |
| 620 | [`pgbouncer_enabled`](#pgbouncer_enabled)                       | [`PG_BOOTSTRAP`](#pg_bootstrap)       | bool        | C     | is pgbouncer enabled                                           |
| 621 | [`pgbouncer_port`](#pgbouncer_port)                             | [`PG_BOOTSTRAP`](#pg_bootstrap)       | int         | C     | pgbouncer listen port                                          |
| 622 | [`pgbouncer_log_dir`](#pgbouncer_log_dir)                       | [`PG_BOOTSTRAP`](#pg_bootstrap)       | path        | C     | pgbouncer log dir, `/var/log/pgbouncer` by default             |
| 623 | [`pgbouncer_auth_query`](#pgbouncer_auth_query)                 | [`PG_BOOTSTRAP`](#pg_bootstrap)       | bool        | C     | use pg_authid query instead of static userlist                 |
| 624 | [`pgbouncer_poolmode`](#pgbouncer_poolmode)                     | [`PG_BOOTSTRAP`](#pg_bootstrap)       | enum        | C     | pgbouncer pooling mode                                         |
| 625 | [`pgbouncer_max_db_conn`](#pgbouncer_max_db_conn)               | [`PG_BOOTSTRAP`](#pg_bootstrap)       | int         | C     | max connection per database                                    |
| 640 | [`pg_provision`](#pg_provision)                                 | [`PG_PROVISION`](#pg_provision)       | bool        | C     | provision template to pgsql?                                   |
| 641 | [`pg_init`](#pg_init)                                           | [`PG_PROVISION`](#pg_provision)       | string      | C     | path to postgres init script                                   |
| 642 | [`pg_default_roles`](#pg_default_roles)                         | [`PG_PROVISION`](#pg_provision)       | role[]      | G/C   | list or global default roles/users                             |
| 643 | [`pg_default_privilegs`](#pg_default_privilegs)                 | [`PG_PROVISION`](#pg_provision)       | string[]    | G/C   | list of default privileges                                     |
| 644 | [`pg_default_schemas`](#pg_default_schemas)                     | [`PG_PROVISION`](#pg_provision)       | string[]    | G/C   | list of default modes                                          |
| 645 | [`pg_default_extensions`](#pg_default_extensions)               | [`PG_PROVISION`](#pg_provision)       | extension[] | G/C   | list of default extensions                                     |
| 646 | [`pg_reload`](#pg_reload)                                       | [`PG_PROVISION`](#pg_provision)       | bool        | A     | reload config?                                                 |
| 647 | [`pg_hba_rules`](#pg_hba_rules)                                 | [`PG_PROVISION`](#pg_provision)       | rule[]      | G/C   | global HBA rules                                               |
| 648 | [`pgbouncer_hba_rules`](#pgbouncer_hba_rules)                   | [`PG_PROVISION`](#pg_provision)       | rule[]      | G/C   | global pgbouncer HBA rules                                     |
| 650 | [`pg_exporter_config`](#pg_exporter_config)                     | [`PG_EXPORTER`](#pg_exporter)         | string      | C     | pg_exporter config path                                        |
| 651 | [`pg_exporter_enabled`](#pg_exporter_enabled)                   | [`PG_EXPORTER`](#pg_exporter)         | bool        | C     | pg_exporter enabled ?                                          |
| 652 | [`pg_exporter_port`](#pg_exporter_port)                         | [`PG_EXPORTER`](#pg_exporter)         | int         | C     | pg_exporter listen address                                     |
| 653 | [`pg_exporter_params`](#pg_exporter_params)                     | [`PG_EXPORTER`](#pg_exporter)         | string      | C/I   | extra params for pg_exporter url                               |
| 654 | [`pg_exporter_url`](#pg_exporter_url)                           | [`PG_EXPORTER`](#pg_exporter)         | string      | C/I   | monitor target pgurl (overwrite)                               |
| 655 | [`pg_exporter_auto_discovery`](#pg_exporter_auto_discovery)     | [`PG_EXPORTER`](#pg_exporter)         | bool        | C/I   | enable auto-database-discovery?                                |
| 656 | [`pg_exporter_exclude_database`](#pg_exporter_exclude_database) | [`PG_EXPORTER`](#pg_exporter)         | string      | C/I   | excluded list of databases                                     |
| 657 | [`pg_exporter_include_database`](#pg_exporter_include_database) | [`PG_EXPORTER`](#pg_exporter)         | string      | C/I   | included list of databases                                     |
| 658 | [`pg_exporter_options`](#pg_exporter_options)                   | [`PG_EXPORTER`](#pg_exporter)         | string      | C/I   | cli args for pg_exporter                                       |
| 659 | [`pgbouncer_exporter_enabled`](#pgbouncer_exporter_enabled)     | [`PG_EXPORTER`](#pg_exporter)         | bool        | C     | pgbouncer_exporter enabled ?                                   |
| 660 | [`pgbouncer_exporter_port`](#pgbouncer_exporter_port)           | [`PG_EXPORTER`](#pg_exporter)         | int         | C     | pgbouncer_exporter listen addr?                                |
| 661 | [`pgbouncer_exporter_url`](#pgbouncer_exporter_url)             | [`PG_EXPORTER`](#pg_exporter)         | string      | C/I   | target pgbouncer url (overwrite)                               |
| 662 | [`pgbouncer_exporter_options`](#pgbouncer_exporter_options)     | [`PG_EXPORTER`](#pg_exporter)         | string      | C/I   | cli args for pgbouncer exporter                                |
| 670 | [`pg_services`](#pg_services)                                   | [`PG_SERVICE`](#pg_service)           | service[]   | G/C   | global service definition                                      |
| 671 | [`haproxy_enabled`](#haproxy_enabled)                           | [`PG_SERVICE`](#pg_service)           | bool        | C/I   | haproxy enabled ?                                              |
| 672 | [`haproxy_reload`](#haproxy_reload)                             | [`PG_SERVICE`](#pg_service)           | bool        | A     | haproxy reload instead of reset                                |
| 673 | [`haproxy_auth_enabled`](#haproxy_auth_enabled)                 | [`PG_SERVICE`](#pg_service)           | bool        | G/C   | enable auth for haproxy admin ?                                |
| 674 | [`haproxy_admin_username`](#haproxy_admin_username)             | [`PG_SERVICE`](#pg_service)           | string      | G     | haproxy admin user name                                        |
| 675 | [`haproxy_admin_password`](#haproxy_admin_password)             | [`PG_SERVICE`](#pg_service)           | string      | G     | haproxy admin password                                         |
| 676 | [`haproxy_exporter_port`](#haproxy_exporter_port)               | [`PG_SERVICE`](#pg_service)           | int         | C     | haproxy exporter listen port                                   |
| 677 | [`haproxy_client_timeout`](#haproxy_client_timeout)             | [`PG_SERVICE`](#pg_service)           | interval    | C     | haproxy client timeout                                         |
| 678 | [`haproxy_server_timeout`](#haproxy_server_timeout)             | [`PG_SERVICE`](#pg_service)           | interval    | C     | haproxy server timeout                                         |
| 680 | [`vip_mode`](#vip_mode)                                         | [`PG_SERVICE`](#pg_service)           | enum        | C     | vip working mode                                               |
| 681 | [`vip_reload`](#vip_reload)                                     | [`PG_SERVICE`](#pg_service)           | bool        | A     | reload vip configuration                                       |
| 682 | [`vip_address`](#vip_address)                                   | [`PG_SERVICE`](#pg_service)           | string      | C     | vip address used by cluster                                    |
| 683 | [`vip_cidrmask`](#vip_cidrmask)                                 | [`PG_SERVICE`](#pg_service)           | int         | C     | vip network CIDR length                                        |
| 684 | [`vip_interface`](#vip_interface)                               | [`PG_SERVICE`](#pg_service)           | string      | C     | vip network interface name                                     |
| 685 | [`dns_mode`](#dns_mode)                                         | [`PG_SERVICE`](#pg_service)           | enum        | C     | cluster DNS mode                                               |
| 686 | [`dns_selector`](#dns_selector)                                 | [`PG_SERVICE`](#pg_service)           | string      | C     | cluster DNS ins selector                                       |
| 700 | [`redis_cluster`](#redis_cluster)                               | [`REDIS_IDENTITY`](#redis_identity)   | string      | C     | redis cluster identity                                         |
| 701 | [`redis_node`](#redis_node)                                     | [`REDIS_IDENTITY`](#redis_identity)   | int         | I     | redis node identity                                            |
| 702 | [`redis_instances`](#redis_instances)                           | [`REDIS_IDENTITY`](#redis_identity)   | instance[]  | I     | redis instances definition on this node                        |
| 710 | [`redis_fs_main`](#redis_fs_main)                               | [`REDIS_NODE`](#redis_node)           | path        | C     | main data disk for redis                                       |
| 711 | [`redis_exporter_enabled`](#redis_exporter_enabled)             | [`REDIS_NODE`](#redis_node)           | bool        | C     | install redis exporter on redis nodes                          |
| 712 | [`redis_exporter_port`](#redis_exporter_port)                   | [`REDIS_NODE`](#redis_node)           | int         | C     | default port for redis exporter                                |
| 713 | [`redis_exporter_options`](#redis_exporter_options)             | [`REDIS_NODE`](#redis_node)           | string      | C/I   | default cli args for redis exporter                            |
| 720 | [`redis_safeguard`](#redis_safeguard)                           | [`REDIS_PROVISION`](#redis_provision) | bool        | C     | set to true to disable purge                                   |
| 721 | [`redis_clean`](#redis_clean)                                   | [`REDIS_PROVISION`](#redis_provision) | bool        | C     | purge existing redis during init                               |
| 722 | [`redis_rmdata`](#redis_clean)                                  | [`REDIS_PROVISION`](#redis_provision) | bool        | C     | remove redis data dir with it?                                 |
| 723 | [`redis_mode`](#redis_mode)                                     | [`REDIS_PROVISION`](#redis_provision) | enum        | C     | standalone,cluster,sentinel                                    |
| 724 | [`redis_conf`](#redis_conf)                                     | [`REDIS_PROVISION`](#redis_provision) | string      | C     | which config template will be used                             |
| 725 | [`redis_bind_address`](#redis_bind_address)                     | [`REDIS_PROVISION`](#redis_provision) | ip          | C     | e.g 0.0.0.0, empty will use inventory_hostname as bind address |
| 726 | [`redis_max_memory`](#redis_max_memory)                         | [`REDIS_PROVISION`](#redis_provision) | size        | C/I   | max memory used by each redis instance                         |
| 727 | [`redis_mem_policy`](#redis_mem_policy)                         | [`REDIS_PROVISION`](#redis_provision) | enum        | C     | memory eviction policy                                         |
| 728 | [`redis_password`](#redis_password)                             | [`REDIS_PROVISION`](#redis_provision) | string      | C     | empty password disable password auth (masterauth & requirepass) |
| 729 | [`redis_rdb_save`](#redis_rdb_save)                             | [`REDIS_PROVISION`](#redis_provision) | string[]    | C     | RDB save cmd, disable with empty  array                        |
| 730 | [`redis_aof_enabled`](#redis_aof_enabled)                       | [`REDIS_PROVISION`](#redis_provision) | bool        | C     | enable redis AOF                                               |
| 731 | [`redis_rename_commands`](#redis_rename_commands)               | [`REDIS_PROVISION`](#redis_provision) | object      | C     | rename dangerous commands                                      |
| 732 | [`redis_cluster_replicas`](#redis_cluster_replicas)             | [`REDIS_PROVISION`](#redis_provision) | int         | C     | how much replicas per master in redis cluster ?                |




--------------------------------

# INFRA

Infra config deals with such issues: localYum repos, machine node base services: DNS, NTP, kernel modules, parameter tuning, admin users, installing packages, DCS Server setup, monitor infra installation, and initialization (Grafana, Prometheus, Alertmanager), global traffic portal Nginx config, etc.

Usually, the infra requirements very few modifications, and the main modification is just a text replacement of the meta node IPs, which is done in [`./configure`](/en/docs/concept/config#configure) automatically. The other occasional change is to the access domain defined in [`nginx_upstream`](#nginx_upstream). Other parameters are adjusted as needed.



----------------

## `META`

This section contains metadata of current pigsty deployments, such as pigsty version, primary meta IP address, repo mirror region, and RHEL releasever.




### `version`

Pigsty version string. type: `string`, level: G, default value: "v1.6.0-b2"

It will be used for pigsty introspection & content rendering.




### `meta_ip`

Primary meta node IP address. type: `ip`, level G, default value: `"10.10.10.10"`

The value of `meta_ip` is `10.10.10.10` by default, which is an IP placeholder and will be replaced with the current meta node primary IP address during configure procedure.

If you are using multiple meta nodes simultaneously, this parameter is used to designate a primary meta node among them.

` can be used and referenced by some other parameters:

* [`grafana_endpoint`](#grafana_endpoint)
* [`loki_endpoint`](#loki_endpoint)
* [`node_etc_hosts_default`](#node_etc_hosts_default)
* [`node_etc_hosts`](#node_etc_hosts)
* [`node_dns_servers`](#node_dns_servers)
* [`node_ntp_servers`](#node_ntp_servers)

The exact string `${meta_ip}` will be replaced with the actual value for the above parameters.




### `region`

Upstream mirror region. type: `string`, default value: `"default"`

If a region other than `default` is set, and there's a corresponding entry in `repo_upstream.[repo].baseurl`, it will be used instead of `default`.

For example, if `china` is used,  pigsty will use China mirrors designated in [`repo_upstream`](#repo_upstream) if applicable.




### `os_release`

RHEL release version. type: `int`, default value "7"

Pigsty will detect and overwrite RHEL releasever during runtime.

Supported values are: 7,8,9









----------------

## `CONNECT`


### `proxy_env`

Using a proper HTTP proxy, download speeds of several MB per second can be achieved. If you have a proxy server, please configure it via `proxy_env`. The sample example is as follows.

```yaml
proxy_env: # global proxy env when downloading packages
  http_proxy: 'http://username:password@proxy.address.com'
  https_proxy: 'http://username:password@proxy.address.com'
  all_proxy: 'http://username:password@proxy.address.com'
  no_proxy: "localhost,127.0.0.1,10.0.0.0/8,192.168.0.0/16,*.pigsty,*.aliyun.com,mirrors.aliyuncs.com,mirrors.tuna.tsinghua.edu.cn,mirrors.zju.edu.cn"
```



### `ansible_host`

If you can not access your nodes directly via ssh (e.g. behind a bastion proxy), Consider using **Ansible connection parameter**

Considering using **Ansible connection parameter** if your target machine is hidden behind an SSH springboard or is not accessible via `ssh ip`.

For example, in the example below, [`ansible_host`](#ansible_host) tells Pigsty to access the target database node using an SSH alias using the `ssh node-1` method instead of the `ssh 10.10.10.11` method.
This allows you to freely specify the connection method of the database node and save the connection configuration in the `~/.ssh/config` of the admin user for independent management.

```yaml
  pg-test:
    vars: { pg_cluster: pg-test }
    hosts:
      10.10.10.11: {pg_seq: 1, pg_role: primary, ansible_host: node-1}
      10.10.10.12: {pg_seq: 2, pg_role: replica, ansible_host: node-2}
      10.10.10.13: {pg_seq: 3, pg_role: offline, ansible_host: node-3}
```

`ansible_host` is the most typical of the ansible connection parameters. Usually, as long as the user can access the target machine via `ssh <name>`, configuring the `ansible_host` variable, for instance, with a value of `<name>` and other common Ansible SSH connection parameters are shown below:

> - `ansible_host`: Specify the target machine's IP, hostname, or SSH alias.
>
> - `ansible_port`: Specify a different SSH port than 22
>
> - `ansible_user`: Specify the username to use for SSH
>
> - `ansible_ssh_pass`: SSH password (Do not store plaintext, and input from the keyboard can be specified by the -k)
>
> - `ansible_ssh_private_key_file`: SSH private key path
>
> - `ansible_ssh_common_args`: SSH General Parameters









----------------

## `CA`

Self-Signed CA used by pigsty. It is required to support advanced security features.

```bash
/etc/pki         # CA home dir
/etc/pki/ca.crt  # CA cert, all nodes
/etc/pki/ca.key  # CA key, meta nodes only (KEEP IT SAFE!)
```



### `ca_method`

CA creation method, type: `enum`, level: G, default value: `"create"`.

* `create`: Create a new CA public-private key pair, skip if exists, default.
* `recreate`: Always create a new CA public-private key pair, skip if exists
* `copy`: Copy the existing CA public and private keys from local `files/pki`
* `none`: Do nothing about CA

If you already have a pair of `ca.crt` and `ca.key`, put them under `files/pki` and set `ca_method` to `copy`.




### `ca_cn`

CA cert common name, type: `string`, level: G, default value: `"pigsty-ca"`.

Check `ca.crt` content with the following command:

```bash
openssl x509 -text -in /etc/pki/ca.crt
```




### `cert_validity`

CA cert validity time, type: `interval`, level: G, default value: `"7300d"`.

Cert validity time is 20 years by default, which is enough for most scenarios.












----------------

## `NGINX`

Pigsty exposes all Web services through Nginx: Home Page, Grafana, Prometheus, AlertManager, Consul,
and other optional tools such as PGWe, Jupyter Lab, Pgadmin, Bytebase ,and other static resource & report such as pgweb schemaspy & pgbadger

Some services on the meta node can be accessed directly through the port, bypassing Nginx, but some services can only be accessed through the Nginx proxy for security reasons. Nginx distinguishes between different services by the domain name.
If the domain name configured for each service does not resolve in the current environment, you will need to configure it in `/etc/hosts`.


### `nginx_enabled`

Enable nginx (and yum repo), type: `bool`, level: C/I, default value: `true`.

Setup nginx server on current meta node?

Set to `false` will skip it.

You can set this parameter to `false` on standby meta nodes when using multiple meta nodes


### `nginx_port`

Local repo port, type: `int`, level: G, default value: `80`.

Pigsty accesses all web services through this port on the meta node. Make sure you can access this port on the meta node.



### `nginx_home`

Local repo root, type: `path`, level: G, default value: `"/www"`.

Nginx root directory which contains static resource and repo resource.



### `nginx_upstream`

Nginx upstream server, Type: `upstream[]`, Level: G, default value:

```yaml
nginx_upstream:                  # domain names and upstream servers
  - { name: home         , domain: pigsty      , endpoint: "10.10.10.10:80"   }
  - { name: grafana      , domain: g.pigsty    , endpoint: "10.10.10.10:3000" }
  - { name: loki         , domain: l.pigsty    , endpoint: "10.10.10.10:3100" }
  - { name: prometheus   , domain: p.pigsty    , endpoint: "10.10.10.10:9090" }
  - { name: alertmanager , domain: a.pigsty    , endpoint: "10.10.10.10:9093" }
  - { name: consul       , domain: c.pigsty    , endpoint: "127.0.0.1:8500"   } #== ^ required ==#
```

Each record contains three subsections: `name`, `domain`, and `endpoint`, representing the component name, the external access domain, and the internal TCP port, respectively.

The `name` definition of the default record is fixed and referenced by hard-coding, do not modify it. Upstream server records with other names can be added at will.

The `domain` is the domain name that should be used for external access to this upstream server. When accessing the Pigsty Web service, the domain name should be used to access it through the Nginx proxy.

The `endpoint` is an internally reachable TCP port. During the Configure, the placeholder IP `10.10.10.10` will be replaced with the meta node IP.




### `nginx_indexes`

List of applications displayed in the home navigation bar, type: `app[]`, level: G, default value:

```yaml
nginx_indexes:                            # application nav links on home page
  - { name: Explain    , url : '/pev.html'                      , comment: 'postgres explain visualizer' }
  - { name: Package    , url : '/pigsty'                        , comment: 'local yum repo packages'     }
  - { name: PG Logs    , url : '/logs'                          , comment: 'postgres raw csv logs'       }
  - { name: Schemas    , url : '/schema'                        , comment: 'schemaspy summary report'    }
  - { name: Reports    , url : '/report'                        , comment: 'pgbadger summary report'     }
  - { name: ISD        , url : '${grafana}/d/isd-overview'      , comment: 'noaa isd data visualization' }
  - { name: Covid      , url : '${grafana}/d/covid-overview'    , comment: 'covid data visualization'    }
```

Each record is rendered as a navigation link to the Pigsty home page App drop-down menu, and the apps are all optional, mounted by default on the Pigsty default server under `http://pigsty/`.
The `url` parameter specifies the URL PATH for the app, with the exception that if the `${grafana}` string is present in the URL, it will be automatically replaced with the Grafana domain name defined in [`nginx_upstream`](#nginx_upstream).







----------------
## `REPO`

Pigsty is installed on a meta node. Pigsty pulls up a localYum repo for the current environment to install RPM packages.

During initialization, Pigsty downloads all packages and their dependencies (specified by [`repo_packages`](#repo_packages)) from the Internet upstream repo (specified by [`repo_upstream`](#repo_upstream)) to [`{{ nginx_home }}`](#nginx_home) / [`{{ repo_name }}`](#repo_name)  (default is `/www/pigsty`). The total size of all dependent software is about 1GB or so.

When creating a localYum repo, Pigsty will skip the software download phase if the directory already exists and if there is a marker file named `repo_complete` in the dir.

If the download speed of some packages is too slow, you can set the download proxy to complete the first download by using the [`proxy_env`](#proxy_env) config entry or directly download the pre-packaged [offline package](/en/docs/deploy/software/offline).

The offline package is a zip archive of the `{{ nginx_home }}/{{ repo_name }}` dir `pkg.tgz`. During `configure`, if Pigsty finds the offline package `/tmp/pkg.tgz`, it will extract it to `{{ nginx_home }}/{{ repo_name }}`, skipping the software download step during installation.

The default offline package is based on CentOS 7.9.2011 x86_64; if you use a different OS, there may be RPM package conflict and dependency error problems; please refer to the FAQ to solve.




### `repo_name`

Local repo name, type: `string`, level: G, default value: `"pigsty"`. It is not recommended to modify this parameter.




### `repo_address`

Local repo external access address, type: `string`, level: G, default value: `"pigsty"`.

The address of the local yum repo for external services, either a domain name or an IP, the default is `yum. pigsty`.

If you use a domain name, you must ensure that the domain name will resolve correctly to the server where the local repo is located, i.e., the meta node.

If the local yum repo does not use the standard port 80, you need to add the port to the address and keep it consistent with the [`nginx_port`](#nginx_port) variable.

The static DNS config [`node_etc_hosts_default`](#node_etc_hosts_default) in the [nodes](/en/docs/nodes/config) parameter can be used to write the `pigsty` local repo domain name by default for all nodes in the current env.





### `repo_rebuild`

Rebuild Yum repo, type: `bool`, level: A, default value: `false`.

If `true`, then the Repo rebuild will be performed in all cases, i.e., regardless of whether the offline package exists.



### `repo_remove`

Remove existing REPO files, type: `bool`, level: A, default value: `true`.

If `true`, the existing repo in `/etc/yum.repos.d` on the meta node will be removed and backed up to the `/etc/yum.repos.d/backup` dir during the local repo initialization process.

Since the content of existing reports in the OS is not controllable, it is recommended to force the removal of existing repos and configure them explicitly via [`repo_upstream`](#repo_upstream).

When the node has other self-configured repos or needs to download some particular version of RPM packages from a specific repo, it can be set to `false` to keep the existing repos.




### `repo_upstream`

Upstream source of Yum repo, type: `repo[]`, level: G.

It can be used for el7, el8, el9. repo file are added only if server's relesever match `.releases` field.

And the `baseurl` can be altered by parameter [`region`](#region) if applicable.

```yaml
repo_upstream:                    # where to download #
  - { name: base           ,description: 'EL 7 Base'         ,category: nodes, releases: [7    ] ,baseurl: { default: 'http://mirror.centos.org/centos/$releasever/os/$basearch/'                    , china: 'https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/os/$basearch/'       , europe: 'https://mirrors.xtom.de/centos/$releasever/os/$basearch/'           }}
  - { name: updates        ,description: 'EL 7 Updates'      ,category: nodes, releases: [7    ] ,baseurl: { default: 'http://mirror.centos.org/centos/$releasever/updates/$basearch/'               , china: 'https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/updates/$basearch/'  , europe: 'https://mirrors.xtom.de/centos/$releasever/updates/$basearch/'      }}
  - { name: extras         ,description: 'EL 7 Extras'       ,category: nodes, releases: [7    ] ,baseurl: { default: 'http://mirror.centos.org/centos/$releasever/extras/$basearch/'                , china: 'https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/extras/$basearch/'   , europe: 'https://mirrors.xtom.de/centos/$releasever/extras/$basearch/'       }}
  - { name: epel           ,description: 'EL 7 EPEL'         ,category: nodes, releases: [7    ] ,baseurl: { default: 'http://download.fedoraproject.org/pub/epel/$releasever/$basearch/'            , china: 'https://mirrors.tuna.tsinghua.edu.cn/epel/$releasever/$basearch/'            , europe: 'https://mirrors.xtom.de/epel/$releasever/$basearch/'                }}
  - { name: centos-sclo    ,description: 'EL 7 SCLo'         ,category: nodes, releases: [7    ] ,baseurl: { default: 'http://mirror.centos.org/centos/$releasever/sclo/$basearch/sclo/'             , china: 'https://mirrors.aliyun.com/centos/$releasever/sclo/$basearch/sclo/'          , europe: 'https://mirrors.xtom.de/centos/$releasever/sclo/$basearch/sclo/'    }}
  - { name: centos-sclo-rh ,description: 'EL 7 SCLo rh'      ,category: nodes, releases: [7    ] ,baseurl: { default: 'http://mirror.centos.org/centos/$releasever/sclo/$basearch/rh/'               , china: 'https://mirrors.aliyun.com/centos/$releasever/sclo/$basearch/rh/'            , europe: 'https://mirrors.xtom.de/centos/$releasever/sclo/$basearch/rh/'      }}
  - { name: baseos         ,description: 'EL 8+ BaseOS'      ,category: nodes, releases: [  8,9] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/BaseOS/$basearch/os/'         , china: 'https://mirrors.aliyun.com/rockylinux/$releasever/BaseOS/$basearch/os/'      , europe: 'https://mirrors.xtom.de/rocky/$releasever/BaseOS/$basearch/os/'     }}
  - { name: appstream      ,description: 'EL 8+ AppStream'   ,category: nodes, releases: [  8,9] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/AppStream/$basearch/os/'      , china: 'https://mirrors.aliyun.com/rockylinux/$releasever/AppStream/$basearch/os/'   , europe: 'https://mirrors.xtom.de/rocky/$releasever/AppStream/$basearch/os/'  }}
  - { name: extras         ,description: 'EL 8+ Extras'      ,category: nodes, releases: [  8,9] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/extras/$basearch/os/'         , china: 'https://mirrors.aliyun.com/rockylinux/$releasever/extras/$basearch/os/'      , europe: 'https://mirrors.xtom.de/rocky/$releasever/extras/$basearch/os/'     }}
  - { name: epel           ,description: 'EL 8+ EPEL'        ,category: nodes, releases: [  8,9] ,baseurl: { default: 'http://download.fedoraproject.org/pub/epel/$releasever/Everything/$basearch/' , china: 'https://mirrors.tuna.tsinghua.edu.cn/epel/$releasever/Everything/$basearch/' , europe: 'https://mirrors.xtom.de/epel/$releasever/Everything/$basearch/'     }}
  - { name: powertools     ,description: 'EL 8 PowerTools'   ,category: nodes, releases: [  8  ] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/PowerTools/$basearch/os/'     , china: 'https://mirrors.aliyun.com/rockylinux/$releasever/PowerTools/$basearch/os/'  , europe: 'https://mirrors.xtom.de/rocky/$releasever/PowerTools/$basearch/os/' }}
  - { name: crb            ,description: 'EL 9 CRB'          ,category: nodes, releases: [    9] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/CRB/$basearch/os/'            , china: 'https://mirrors.aliyun.com/rockylinux/$releasever/CRB/$basearch/os/'         , europe: 'https://mirrors.xtom.de/rocky/$releasever/CRB/$basearch/os/'        }}
  - { name: grafana        ,description: 'Grafana'           ,category: infra, releases: [7,8,9] ,baseurl: { default: 'https://packages.grafana.com/oss/rpm'                                         , china: 'https://mirrors.tuna.tsinghua.edu.cn/grafana/yum/rpm' }}
  - { name: prometheus     ,description: 'Prometheus'        ,category: infra, releases: [7,8,9] ,baseurl: { default: 'https://packagecloud.io/prometheus-rpm/release/el/$releasever/$basearch' }}
  - { name: nginx          ,description: 'Nginx Repo'        ,category: infra, releases: [7,8,9] ,baseurl: { default: 'https://nginx.org/packages/centos/$releasever/$basearch/'                }}
  - { name: docker-ce      ,description: 'Docker CE'         ,category: infra, releases: [7,8,9] ,baseurl: { default: 'https://download.docker.com/linux/centos/$releasever/$basearch/stable'                  , china: 'https://mirrors.aliyun.com/docker-ce/linux/centos/$releasever/$basearch/stable'                     , europe: 'https://mirrors.xtom.de/docker-ce/linux/centos/$releasever/$basearch/stable'       }}
  - { name: pgdg14         ,description: 'PostgreSQL 14'     ,category: pgsql, releases: [7,8,9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/14/redhat/rhel-$releasever-$basearch'     , china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/14/redhat/rhel-$releasever-$basearch'     , europe: 'https://mirrors.xtom.de/postgresql/repos/yum/14/redhat/rhel-$releasever-$basearch' }}
  - { name: pgdg15         ,description: 'PostgreSQL 15'     ,category: pgsql, releases: [7,8,9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/15/redhat/rhel-$releasever-$basearch'     , china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/15/redhat/rhel-$releasever-$basearch'     , europe: 'https://mirrors.xtom.de/postgresql/repos/yum/15/redhat/rhel-$releasever-$basearch' }}
  - { name: pgdg-common    ,description: 'PostgreSQL Common' ,category: pgsql, releases: [7,8,9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/common/redhat/rhel-$releasever-$basearch' , china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/redhat/rhel-$releasever-$basearch' , europe: 'https://mirrors.xtom.de/postgresql/repos/yum/common/redhat/rhel-$releasever-$basearch'                             }}
  - { name: pgdg-extras    ,description: 'PostgreSQL Extra'  ,category: pgsql, releases: [7,8,9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/common/pgdg-rhel$releasever-extras/redhat/rhel-$releasever-$basearch' , china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/pgdg-rhel$releasever-extras/redhat/rhel-$releasever-$basearch' , europe: 'https://mirrors.xtom.de/postgresql/repos/yum/common/pgdg-rhel$releasever-extras/redhat/rhel-$releasever-$basearch' }}
  - { name: timescaledb    ,description: 'TimescaleDB'       ,category: pgsql, releases: [7,8  ] ,baseurl: { default: 'https://packagecloud.io/timescale/timescaledb/el/$releasever/$basearch'  }}
  - { name: citus          ,description: 'Citus Community'   ,category: pgsql, releases: [7,8  ] ,baseurl: { default: 'https://repos.citusdata.com/community/el/$releasever/$basearch'          }}
```





### `repo_packages`

List of software to download for Yum repo, type: `string[]`, level: G, default value: `[]`.

Each line is a set of package names separated by spaces, where the specified software will be downloaded via `repotrack`.

<details><summary>RHEL7 repo packages</summary>

```yaml
- epel-release nginx wget createrepo_c sshpass zip unzip chrony yum yum-utils  # modulemd-tools
- uuid lz4 bzip2 netcat pv jq vim-enhanced make patch bash lsof wget git tuned perf ftp lrzsz rsync nvme-cli numactl grubby sysstat dstat iotop bind-utils net-tools tcpdump socat ipvsadm telnet audit ca-certificates
- readline zlib openssl openssh-clients libyaml libxml2 libxslt libevent readline-devel zlib-devel uuid-devel libuuid-devel libxml2-devel libxslt-devel openssl-devel libicu-devel perl perl-devel perl-ExtUtils*
- grafana*.x86_64 prometheus2 pushgateway alertmanager mtail consul consul_exporter consul-template etcd dnsmasq node_exporter nginx_exporter blackbox_exporter redis_exporter # redis
- ansible python3 python3-pip python3-requests python3-psycopg2 python3-psycopg3 python3-etcd python3-consul python3-urllib3 python3-idna python36-pyOpenSSL # python3-pyOpenSSL python3-jmespath
- postgresql14* pglogical_14* postgis33_14* citus111_14* timescaledb-2-postgresql-14 # citus & tsdb not ready in el9, postgis33 available since el8+
- patroni patroni-consul patroni-etcd pgbouncer pgbadger tail_n_mail boxinfo check_postgres barman barman-cli pgFormatter pitrery pspg PyGreSQL
- pg_activity pgxnclient pgcenter emaj pgbconsole pg_bloat_check pgloader pg_cli pgquarrel # some not available on el8, el9
- pg_repack_14 pg_qualstats_14 pg_stat_kcache_14 pg_stat_monitor_14 pg_top_14 pg_track_settings_14 pg_wait_sampling_14 plsh_14 pldebugger_14 plpgsql_check_14 wal2json_14
- mysql_fdw_14 ogr_fdw_14 sqlite_fdw_14 firebird_fdw_14 hdfs_fdw_14 mongo_fdw_14 pgbouncer_fdw_14 hypopg_14 geoip_14 tdigest_14 multicorn2_14 pg_ivm_14 # osm_fdw_14 tds_fdw_14
- bgw_replstatus_14 ddlx_14 mysqlcompat_14 orafce_14 repmgr_14 pg_auto_failover_14 pg_catcheck_14 pg_cron_14 pg_fkpart_14 pg_jobmon_14 pg_partman_14 pg_permissions_14
- pg_readonly_14 pgagent_14 pgaudit16_14 pgauditlogtofile_14 pgfincore_14 powa_14 pgq_14 pgsql_tweaks_14 pgtt_14 postgresql-unit_14 postgresql_anonymizer_14 postgresql_faker_14
- pg_statement_rollback_14 system_stats_14 plproxy_14 pgmemcache_14  rum_14 hll_14 ip4r_14 prefix_14 pguri_14 topn_14 periods_14 # pgrouting_14 osm2pgrouting_14
- count_distinct_14 credcheck_14 extra_window_functions_14 logerrors_14 pg_auth_mon_14 pg_background_14 pg_bulkload_14 pg_comparator_14
- pg_prioritize_14 pgcryptokey_14 pgexportdoc_14 pgimportdoc_14 pgmp_14 pgtap_14 safeupdate_14 semver_14 set_user_14 sslutils_14 table_version_14
- clang coreutils diffutils rpm-build rpm-devel rpmlint rpmdevtools bison flex docker-ce docker-compose* # kubelet kubectl kubeadm kubernetes-cni helm
- postgresql15* postgis33_15* citus111_15* sqlite_fdw_15 wal2json_15 # timescaledb-2-postgresql-15*
```

</details>


<details><summary>RHEL8 repo packages</summary>

```yaml
repo_packages: # which packages to be included
  - epel-release nginx wget createrepo_c sshpass zip unzip chrony yum yum-utils modulemd-tools
  - uuid lz4 bzip2 netcat pv jq vim-enhanced make patch bash lsof wget git tuned perf ftp lrzsz rsync nvme-cli numactl grubby sysstat dstat iotop bind-utils net-tools tcpdump socat ipvsadm telnet audit ca-certificates
  - readline zlib openssl openssh-clients libyaml libxml2 libxslt libevent readline-devel zlib-devel uuid-devel libuuid-devel libxml2-devel libxslt-devel openssl-devel libicu-devel perl perl-devel perl-ExtUtils*
  - grafana*.x86_64 prometheus2 pushgateway alertmanager mtail consul consul_exporter consul-template etcd dnsmasq node_exporter nginx_exporter blackbox_exporter redis_exporter redis haproxy
  - ansible python3 python3-pip python3-requests python3-psycopg2 python3-psycopg3 python3-etcd python3-consul python3-urllib3 python3-idna python38-jmespath python3-pyOpenSSL
  - patroni patroni-consul patroni-etcd pgbouncer pgbadger tail_n_mail boxinfo check_postgres barman barman-cli pgFormatter pitrery pspg PyGreSQL
  - pg_activity pgxnclient pgcenter emaj pgbconsole pg_bloat_check # pgloader pg_cli pgquarrel not available on el8, el9
  - postgresql14* pglogical_14* postgis33_14* citus111_14* timescaledb-2-postgresql-14* # citus & tsdb not ready in el9, postgis33 available since el8+
  - pg_repack_14 pg_qualstats_14 pg_stat_kcache_14 pg_stat_monitor_14 pg_top_14 pg_track_settings_14 pg_wait_sampling_14 plsh_14 pldebugger_14 plpgsql_check_14 wal2json_14
  - mysql_fdw_14 ogr_fdw_14 sqlite_fdw_14 firebird_fdw_14 hdfs_fdw_14 mongo_fdw_14 pgbouncer_fdw_14 hypopg_14 geoip_14 tdigest_14 multicorn2_14 pg_ivm_14 # osm_fdw_14 tds_fdw_14
  - bgw_replstatus_14 ddlx_14 mysqlcompat_14 orafce_14 repmgr_14 pg_auto_failover_14 pg_catcheck_14 pg_cron_14 pg_fkpart_14 pg_jobmon_14 pg_partman_14 pg_permissions_14
  - pg_readonly_14 pgagent_14 pgaudit16_14 pgauditlogtofile_14 pgfincore_14 powa_14 pgq_14 pgsql_tweaks_14 pgtt_14 postgresql-unit_14 postgresql_anonymizer_14 postgresql_faker_14
  - pg_statement_rollback_14 system_stats_14 plproxy_14 pgmemcache_14  rum_14 hll_14 ip4r_14 prefix_14 pguri_14 topn_14 periods_14 # pgrouting_14 osm2pgrouting_14
  - count_distinct_14 credcheck_14 extra_window_functions_14 logerrors_14 pg_auth_mon_14 pg_background_14 pg_bulkload_14 pg_comparator_14
  - pg_prioritize_14 pgcryptokey_14 pgexportdoc_14 pgimportdoc_14 pgmp_14 pgtap_14 safeupdate_14 semver_14 set_user_14 sslutils_14 table_version_14
  - clang coreutils diffutils rpm-build rpm-devel rpmlint rpmdevtools bison flex docker-ce docker-compose* # kubelet kubectl kubeadm kubernetes-cni helm
  - postgresql15* postgis33_15* citus111_15* sqlite_fdw_15 wal2json_15 # timescaledb-2-postgresql-15*
```

</details>


<details><summary>RHEL9 repo packages</summary>

```yaml
repo_packages: # which packages to be included                                   #  what to download #
  - epel-release nginx wget createrepo_c sshpass zip unzip chrony yum yum-utils modulemd-tools
  - uuid lz4 bzip2 netcat pv jq vim-enhanced make patch bash lsof wget git tuned perf ftp lrzsz rsync nvme-cli numactl grubby sysstat dstat iotop bind-utils net-tools tcpdump socat ipvsadm telnet audit ca-certificates
  - readline zlib openssl openssh-clients libyaml libxml2 libxslt libevent readline-devel zlib-devel uuid-devel libuuid-devel libxml2-devel libxslt-devel openssl-devel libicu-devel perl perl-devel perl-ExtUtils*
  - grafana*.x86_64 prometheus2 pushgateway alertmanager mtail consul consul_exporter consul-template etcd dnsmasq node_exporter nginx_exporter blackbox_exporter redis_exporter redis haproxy
  - ansible python3 python3-pip python3-requests python3-psycopg2 python3-psycopg3 python3-etcd python3-consul python3-urllib3 python3-idna python3-jmespath python3-pyOpenSSL
  - patroni patroni-consul patroni-etcd pgbouncer pgbadger tail_n_mail boxinfo check_postgres barman barman-cli pgFormatter pitrery pspg PyGreSQL
  - postgresql14* pglogical_14* postgis33_14* citus_14-11* timescaledb_14 # citus111_14* timescaledb-2-postgresql-14* not ready in el9, use pgdg instead
  - pg_repack_14 pg_qualstats_14 pg_stat_kcache_14 pg_stat_monitor_14 pg_top_14 pg_track_settings_14 pg_wait_sampling_14 plsh_14 pldebugger_14 plpgsql_check_14 wal2json_14
  - mysql_fdw_14 ogr_fdw_14 sqlite_fdw_14 firebird_fdw_14 hdfs_fdw_14 mongo_fdw_14 pgbouncer_fdw_14 hypopg_14 geoip_14 tdigest_14 multicorn2_14 pg_ivm_14 # osm_fdw_14 tds_fdw_14
  - bgw_replstatus_14 ddlx_14 mysqlcompat_14 orafce_14 repmgr_14 pg_auto_failover_14 pg_catcheck_14 pg_cron_14 pg_fkpart_14 pg_jobmon_14 pg_partman_14 pg_permissions_14 rum_14
  - pg_readonly_14 pgagent_14 pgaudit16_14 pgauditlogtofile_14 pgfincore_14 powa_14 pgq_14 pgsql_tweaks_14 pgtt_14 postgresql-unit_14 postgresql_anonymizer_14 postgresql_faker_14
  #- pg_statement_rollback_14 system_stats_14 plproxy_14 pgmemcache_14  hll_14 ip4r_14 prefix_14 pguri_14 topn_14 periods_14 # pgrouting_14 osm2pgrouting_14
  #- count_distinct_14 credcheck_14 extra_window_functions_14 logerrors_14 pg_auth_mon_14 pg_background_14 pg_bulkload_14 pg_comparator_14
  #- pg_prioritize_14 pgcryptokey_14 pgexportdoc_14 pgimportdoc_14 pgmp_14 pgtap_14 safeupdate_14 semver_14 set_user_14 sslutils_14 table_version_14
  #- pg_activity pgxnclient pgcenter emaj pgbconsole pg_bloat_check pgloader pg_cli pgquarrel not available on el8, el9
  - clang coreutils diffutils rpm-build rpm-devel rpmlint rpmdevtools bison flex docker-ce docker-compose* # kubelet kubectl kubeadm kubernetes-cni helm
  - postgresql15* postgis33_15* citus_15-11* sqlite_fdw_15 wal2json_15 # timescaledb-2-postgresql-15*
```

</details>




### `repo_url_packages`

Software for direct download via URL, type: `url[]`, level: G

Download some software via URL, not YUM:

* `loki`, `promtail`: **Must**, log collection server-side and client-side binary.
* `pg_exporter`: **Must**, core components of the monitor system.
* `vip-manager`: **Must**, package required to enable L2 VIP for managing VIP.
* `polysh`: Optional, execute ssh commands on multiple nodes in parallel. el7 only
* `pev2`: Optional, PostgreSQL execution plan visualization

<details><summary>RHEL7 repo packages</summary>

```yaml
- https://github.com/Vonng/loki-rpm/releases/download/v2.6.1/loki-2.6.1.x86_64.rpm
- https://github.com/Vonng/loki-rpm/releases/download/v2.6.1/promtail-2.6.1.x86_64.rpm
- https://github.com/Vonng/pg_exporter/releases/download/v0.5.0/pg_exporter-0.5.0.x86_64.rpm
- https://github.com/cybertec-postgresql/vip-manager/releases/download/v1.0.2/vip-manager-1.0.2-1.x86_64.rpm
- https://github.com/Vonng/haproxy-rpm/releases/download/v2.6.6/haproxy-2.6.6-1.el7.x86_64.rpm
- https://github.com/Vonng/pigsty-pkg/releases/download/misc/polysh-0.4-1.noarch.rpm
- https://github.com/dalibo/pev2/releases/download/v1.5.0/index.html
- https://github.com/Vonng/pigsty-pkg/releases/download/misc/redis-6.2.7-1.el7.remi.x86_64.rpm
```

</details>


<details><summary>RHEL8 repo packages</summary>

```yaml
- https://github.com/Vonng/loki-rpm/releases/download/v2.6.1/loki-2.6.1.x86_64.rpm
- https://github.com/Vonng/loki-rpm/releases/download/v2.6.1/promtail-2.6.1.x86_64.rpm
- https://github.com/Vonng/pg_exporter/releases/download/v0.5.0/pg_exporter-0.5.0.x86_64.rpm
- https://github.com/cybertec-postgresql/vip-manager/releases/download/v1.0.2/vip-manager-1.0.2-1.x86_64.rpm
- https://github.com/Vonng/pigsty-pkg/releases/download/misc/polysh-0.4-1.noarch.rpm
- https://github.com/dalibo/pev2/releases/download/v1.5.0/index.html
```

</details>


<details><summary>RHEL9 repo packages</summary>

```yaml
- https://github.com/Vonng/loki-rpm/releases/download/v2.6.1/loki-2.6.1.x86_64.rpm
- https://github.com/Vonng/loki-rpm/releases/download/v2.6.1/promtail-2.6.1.x86_64.rpm
- https://github.com/Vonng/pg_exporter/releases/download/v0.5.0/pg_exporter-0.5.0.x86_64.rpm
- https://github.com/cybertec-postgresql/vip-manager/releases/download/v1.0.2/vip-manager-1.0.2-1.x86_64.rpm
- https://github.com/dalibo/pev2/releases/download/v1.5.0/index.html
```

</details>




```yaml

```

!> redis can be downloaded via [`repo_packages`](#repo_packages) on el8, el9 (appstream)
!> 
!> haproxy with prometheus support can be downloaded via [`repo_packages`](#repo_packages) on el8, el9 (pgdg-extras)








----------------

## `NAMESERVER`

You can set a default DNSMASQ server on meta node in case of no DNS server available. This is disabled by default.



### `nameserver_enabled`

Enable DNSMASQ on the meta node, type: `bool`, level: C/I, default value: `false`.



### `dns_records`

Dynamic DNS resolution record, type: `string[]`, level: G, default value is `[]` / empty list.

the following resolution records are available by default in the sandbox.

```yaml
dns_records:                    # dynamic dns record resolved by dnsmasq
  - 10.10.10.2  pg-meta         # sandbox vip for pg-meta
  - 10.10.10.3  pg-test         # sandbox vip for pg-test
  - 10.10.10.10 meta-1          # sandbox node meta-1
  - 10.10.10.11 node-1          # sandbox node node-1
  - 10.10.10.12 node-2          # sandbox node node-2
  - 10.10.10.13 node-3          # sandbox node node-3
  - 10.10.10.10 pg-meta-1       # sandbox instance pg-meta-1
  - 10.10.10.11 pg-test-1       # sandbox instance node-1
  - 10.10.10.12 pg-test-2       # sandbox instance node-2
  - 10.10.10.13 pg-test-3       # sandbox instance node-3
```






----------------
## `PROMETHEUS`

Prometheus is used as time-series database for monitoring, altering & metrics analysis. 




### `prometheus_enabled`

Enable Prometheus on the meta node, type: `bool`, level: C/I, default value: `true`.



### `prometheus_data_dir`

Prometheus dir, type: `path`, level: G, default value: `"/data/prometheus/data"`.





### `prometheus_options`

Prometheus CLI parameter, type: `string`, level: G, default value: `"--storage.tsdb.retention=15d --enable-feature=promql-negative-offset"`.

The default parameters will allow Prometheus to enable the negative time offset feature and retain the monitoring data for 15 days by default. If you have a large enough disk, you can increase the length of time that monitoring data is kept.




### `prometheus_reload`

Reload the configuration instead of rebuilding the whole thing when performing Prometheus tasks. Type: `bool`, Level: A, Default: `false`.

By default, executing the `prometheus` task will clear existing monitoring data, but if set to `true`, it will not.




### `prometheus_sd_method`

Service discovery mechanism: static|consul, type: `enum`, level: G, default value: `"static"`.

Prometheus's service discovery mechanism, default `static`, option `consul` Use Consul for service discovery (will be phased out).
Pigsty recommends using `static` for service discovery, which provides more excellent reliability and flexibility.

`static` service discovery relies on the config in `/etc/prometheus/targets/{infra,nodes,pgsql,redis}/*.yml` for service discovery.

The advantage of this method is that the monitoring system does not rely on consult. The monitoring target will give an error prompt when the node goes down instead of disappearing directly. In addition, when the pigsty monitor system is integrated with the external control mode, this mode is less invasive to the original system.

The following command can be used to generate the required monitoring object profile for Prometheus from the config file.

```bash
./nodes.yml -t register_prometheus  # Generate a list of host monitoring targets
./pgsql.yml -t register_prometheus  # Generate a list of PostgreSQL/Pgbouncer/Patroni/Haproxy monitoring targets
./redis.yml -t register_prometheus  # Generate a list of Redis monitoring targets
```




### `prometheus_scrape_interval`

Prometheus crawl period, type: `interval`, level: G, default value: `"10s"`.

Ten seconds - 30 seconds is a suitable crawl period. If a finer granularity of monitoring data is required, this parameter can be adjusted.




### `prometheus_scrape_timeout`

Prometheus grab timeout, type: `interval`, level: G, default value: `"8s"`.

Setting the crawl timeout can effectively avoid avalanches caused by monitoring system queries. This parameter must be less than and close to [`prometheus_scrape_interval`](#prometheus_scrape_interval) to ensure that the length of each crawl does not exceed the crawling period.




### `prometheus_sd_interval`

Prometheus service discovery refresh period, type: `interval`, level: G, default value: `"10s"`.

Interval between prometheus refresh & reload monitoring targets.





----------------
## `EXPORTER`

Define generic metrics exporter options, such as how the Exporter is installed, the URL path to listen to, etc.



### `exporter_install`

To install the monitoring component, type: `enum`, level: G, default value: `"none"`.

Specify how to install Exporter:

* `none`: No installation, (by default, the Exporter has been previously installed by the [`node.pkgs`](#node_packages_default) task)
* `yum`: Install using yum (if yum installation is enabled, run yum to install [`node_exporter`](#node_exporter) and [`pg_exporter`](#pg_exporter) before deploying Exporter)
* `binary`: Install using a copy binary (copy [`node_exporter`](#node_exporter) and [`pg_exporter`](#pg_exporter) binary directly from the meta node, not recommended)

When installing with `yum`, if `exporter_repo_url` is specified (not empty), the installation will first install the REPO file under that URL into `/etc/yum.repos.d`. This feature allows you to install Exporter directly without initializing the node infrastructure.
It is not recommended for regular users to use `binary` installation. This mode is usually used for emergency troubleshooting and temporary problem fixes.

```bash
<meta>:<pigsty>/files/node_exporter ->  <target>:/usr/bin/node_exporter
<meta>:<pigsty>/files/pg_exporter   ->  <target>:/usr/bin/pg_exporter
```





### `exporter_repo_url`

Yum Repo URL of the monitor component, type: `string`, level: G, default value: `""`.

Default is empty; when [`exporter_install`](#exporter_install) is `yum`, the repo specified by this parameter will be added to the node source list.





### `exporter_metrics_path`

Monitor the exposed URL Path, type: `string`, level: G, default value: `"/metrics"`.

The URL PATH for all Exporter externally exposed metrics, which defaults to `/metrics`, is referenced by the external role [`prometheus`](#prometheus), and Prometheus will apply this config to the monitoring object based on the config here.

Indicator exponents affected by this parameter include:

* [`node_exporter`](#node_exporter)
* [`pg_exporter`](#pg_exporter)
* [`pgbouncer_port`](#pgbouncer_port)
* [`haproxy`](#haproxy_exporter_port)
* Patroni's Metrics endpoint is currently fixed to `/metrics` and cannot be configured, so it is not affected by this parameter.
* The Metrics endpoint of the Infra component is fixed to `/metrics` and is not affected by this parameter.






----------------
## `GRAFANA`

Grafana is the visualization platform for Pigsty's monitoring system.



### `grafana_enabled`

Enable Grafana on the meta node, type: `bool`, level: C/I, default value: `true`.



### `grafana_endpoint`

Grafana address, type: `url`, level: G, default value: `"http://10.10.10.10:3000"`.

Grafana provides a service endpoint to the public, which is used by the Grafana initialization and installation monitoring panel to call the Grafana API.

The placeholder IP `10.10.10.10` will be replaced by the actual IP during the `configure`.




### `grafana_admin_username`

Grafana administrator username, type: `string`, level: G, default value: `"admin"`.





### `grafana_admin_password`

Grafana administrator password, type: `string`, level: G, default value: `"pigsty"`.





### `grafana_database`

Grafana backend database type, type: `enum`, tier: G, default value: `"sqlite3"`.

The alternative is `postgres`. When using `postgres`, you must ensure that the target database already exists and is accessible. That is, Postgres on the meta node cannot be used before the initialization of the infrastructure for the first time because Grafana was created before that database.

To avoid creating circular dependencies (Grafana depends on Postgres, PostgreSQL depends on the infra, including Grafana), you need to modify this parameter and re-execute [`grafana`](#grafana)-related tasks after the first time you complete the installation.
For details, please see [Tutorial: Using Postgres as a Grafana database](/en/docs/app/grafana).




### `grafana_pgurl`

PostgreSQL connection string for Grafana, type: `url`, level: G, default value: `"postgres://dbuser_grafana:DBUser.Grafana@meta:5436/grafana"`.

Only valid if the parameter [`grafana_database`](#grafana_database) is `postgres`.





### `grafana_plugin_method`

Install the Grafana plugin, type: `enum`, level: G, default value: `"install"`.

How Grafana plug-ins are provisioned:

* `none`: No plug-in installation.
* `install`: Install the Grafana plugin (default), or skip it if it already exists.
* `reinstall`: Re-download and install the Grafana plugin anyway.

Grafana requires Internet access to download several extension plug-ins, and if your meta-node does not have Internet access, you should ensure that you are using an offline installer.
The offline installation package already contains all downloaded Grafana plugins by default, located under the path specified by [`grafana_plugin_cache`](#grafana_plugin_cache). Pigsty will package the downloaded plugins and place them under that path after the download is complete when downloading plugins from the Internet.




### `grafana_plugin_cache`

Grafana plugin cache address, type: `path`, level: G, default value: `"/www/pigsty/plugins.tgz"`.





### `grafana_plugin_list`

List of installed Grafana plugins, type: `string[]`, level: G, default value:

```yaml
grafana_plugin_list:              # plugins that will be downloaded via grafana-cli
  - volkovlabs-echarts-panel
  - marcusolsson-csv-datasource
  - marcusolsson-json-datasource
  - marcusolsson-treemap-panel
```

Each array element is a string that represents the name of the plugin. Plugins are installed using `grafana-cli plugins install`.






### `grafana_plugin_git`

Grafana plugin installed from Git, type: `url[]`, level: G, default value:

```yaml
grafana_plugin_git:                          # plugins that will be downloaded via git
  - https://github.com/Vonng/vonng-echarts-panel
```

Some plugins cannot be downloaded via the official command line but can be downloaded via Git Clone. Plugins will be installed via `cd /var/lib/grafana/plugins && git clone `.

A visualization plugin will be downloaded by default: `vonng-echarts-panel`, which provides Echarts drawing support for Grafana.







----------------
## `LOKI`


LOKI is the default log collection server used by Pigsty.



### `loki_enabled`

Enable Loki on the meta node, type: `bool`, level: C/I, default value: `false`.




### `loki_endpoint`

Loki service endpoint for receiving logs, type: `url`, level: G, default value: `"http://10.10.10.10:3100/loki/api/v1/push"`.





### `loki_clean`

Clean up the database directory when installing Loki, type: `bool`, level: A, default value: `false`.




### `loki_options`

Command line arguments for Loki, type: `string`, level: G, default value: `"-config.file=/etc/loki.yml -config.expand-env=true"`.

The default config parameters are used to specify the Loki config file location and to enable the ability to expand environment variables in the config file; it is not recommended to remove these two options.




### `loki_data_dir`

Loki's data directory, type: `string`, level: G, default value: `"/data/loki"`.





### `loki_retention`

Loki log default retention days, type: `interval`, level: G, default value: `"15d"`.





----------------
## `DCS`

Distributed Configuration Store (DCS) is a distributed, highly available meta-database that provides HA consensus and service discovery.

Pigsty supports Consul & ETCD as DCS. Use [`dcs_registry`](#dcs_registry) to specify where to register service,

Availability of Consul/ETCD is critical for postgres HA. Special care needs to be taken when using the DCS service in a production env.
Availability of DCS itself is achieved through multiple peers. For example, a 3-node DCS cluster allows up to one node to fail, while a 5-node DCS cluster allows 2 nodes to fail.
In a large-scale production env, it is recommended to use at least 3~5 DCS Servers.
The DCS servers used by Pigsty are specified by the parameter [`dcs_servers`](#dcs_servers), either by using an existing external DCS server cluster or by deploying DCS Servers using nodes managed by Pigsty itself.

By default, Pigsty deploys setup DCS services when nodes are included in management ([`nodes.yml`](playbook.md#nodes#nodes)), and if the current node is defined in [`dcs_servers`](#dcs_servers), the node will be initialized as a DCS Server.
Pigsty deploys a single node DCS Server on the meta node itself by default. You can use any node as DCS Servers.  Before deploying any HA Postgres Cluster, you should ensure that all DCS Servers have been initialized. (Which is done during `nodes.yml`)


the type of DCS used by [`pg_dcs_type`](#pg_dcs_type) and the location of the service registration by


### `dcs_name`

DCS cluster name, type: `string`, level: G, default value: `"pigsty"`.

Represents the data center name in Consul, and used as initial cluster token in Etcd.



### `dcs_servers`

DCS Server, type: `dict`, level: G, default value:

```yaml
dcs_servers:
  meta-1: 10.10.10.10      # Deploy a single DCS Server on the meta node by default
  # meta-2: 10.10.10.11
  # meta-3: 10.10.10.12 
```

Key is the DCS server instance name, and Value is the server IP address.
By default, Pigsty will configure the DCS service for the node in the [node initialization](playbook.md#nodes#nodes) playbook, which defaults to Consul.

You can use an external DCS server and fill in the addresses of all external DCS Servers. Otherwise, Pigsty will deploy a single instance DCS Server on the meta node (`10.10.10.10` placeholder) by default.
If the current node is defined in [`dcs_servers`](#dcs_servers), i.e., the IP address matches any Value, the node will be initialized as a DCS Server, and its Key will be used as a Consul Server.



### `dcs_gid`

gid for consul/etcd users , type: `int`, level: G, default value: `910`.




### `dcs_ssl_enabled`

secure dcs communications with ssl? type: `bool`, level: G, default value: `false`.

Assure that any running consul instance will not be purged by any [`nodes`](playbook.md#nodes) playbook., level: C/A, default: `false`




### `dcs_registry`

Where to register service, type: `enum`, level: G, default value: `"consul"`.

* `none`: No service registration is performed (`none` will disable [`prometheus_sd_method`](#prometheus_sd_method) = consul ).
* `consul`: Registering services to Consul.
* `etcd`: Registering services into Etcd (not supported yet).



### `dcs_safeguard`

Assure that any running consul instance will not be purged by any [`nodes`](playbook.md#nodes) playbook., level: C/A, default: `false`

Check [SafeGuard](playbook.md#nodes#SafeGuard) for details.




### `dcs_clean`

Remove existing consul during node init? level: C/A, default: `false`

This allows the removal of any running consul instance during [`nodes.yml`](playbook.md#nodes#nodes), which makes it a true idempotent playbook.

It's a dangerous option so you'd better disable it by default and use it with `-e` CLI args.

> This parameter not working when [`dcs_safeguard`](#dcs_safeguard) is set to `true`





----------------

## `CONSUL`

Consul is used for service mesh, traffic control, health check, service registry, service discovery & consensus.


### `consul_enabled`

Enable consul: `bool`, level: G, default value: `true`.

Setup consul servers & agents on all nodes.


### `consul_data_dir`

Consul data directory, type: `string`, level: G, default value: `"/data/consul"`.





----------------

## `ETCD`

ETCD is used for HA PostgreSQL Leader election, alternative to Consul.

### `etcd_enabled`

Enable etcd: `bool`, level: G, default value: `true`.

Setup etcd servers on nodes in [`dcs_servers`](#dcs_servers), and write credential to all client nodes.


### `etcd_data_dir`

ETCD data directory, type: `string`, level: G, default value: `"/etcd/consul"`.

















--------------------------------

# NODES


Pigsty provides host provisioning and monitoring functions. 
The [`nodes.yml`](playbook.md#nodes) playbook can be executed to configure the node to the corresponding state and incorporate it into the Pigsty monitor system.


----------------

## `NODE_IDENTITY`

Each node has **identity parameters** that are configured through the parameters in `<cluster>.hosts` and `<cluster>.vars`.

Pigsty uses **IP** as a unique identifier for **database nodes**. **This IP must be the IP that the database instance listens to and serves externally**, but it is inappropriate to use a public IP. Users can also indirectly operate the management target node through an SSH tunnel or springboard machine transit. However, the primary IPv4 is still the core identity of the node when identifying the database node. **This is very important**. The IP is the `inventory_hostname` of the host in the inventory, which is reflected as the `key` in the `<cluster>.hosts` object.

In the Pigsty monitor system, nodes also have two crucial identity parameters: [`nodename`](#nodename) and [`node_cluster`](#node_cluster). These will be used in the monitor system as the node's **instance identity** (`ins`) and **cluster identity** (`cls`). Pigsty uses node-exclusive 1:1 deployment by default, so the identity params of the instances (`pg_cluster` and `pg_instance`) can be borrowed to the `ins` and `cls` tags of the nodes via the [`pg_hostname`](#pg_hostname) parameter.

[`nodename`](#nodename) and [`node_cluster`](#node_cluster) are not mandatory; when left blank or empty, [`nodename`](#nodename) will use the node's current hostname, while [`node_cluster`](#node_cluster) will use the fixed default value: `nodes`.

|              Name               |   Type   | Level | Necessity    | Comment               |
| :-----------------------------: | :------: | :---: | ------------ | --------------------- |
|      `inventory_hostname`       |   `ip`   | **-** | **Required** | **Node IP**           |
|     [`nodename`](#nodename)     | `string` | **I** | Optional     | **Node Name**         |
| [`node_cluster`](#node_cluster) | `string` | **C** | Optional     | **Node cluster name** |

The following cluster config declares a three-node node cluster:

```yaml
node-test:
  hosts:
    10.10.10.11: { nodename: node-test-1 }
    10.10.10.12: { nodename: node-test-2 }
    10.10.10.13: { nodename: node-test-3 }
  vars:
    node_cluster: node-test
```






### `meta_node`

This node is a meta node, type: `bool`, level: C, default value: `false`.

Nodes under the `meta` grouping carry this flag in the inventory by default. Nodes with this flag will be additionally configured at node [package installation](#node_packages_default) with:

Install the RPM pkgs specified by [`node_packages_meta`](#node_packages_meta) and install the Python pkgs set by [`node_packages_meta_pip`](#node_packages_meta_pip).




### `nodename`

Specifies the node name, type: `string`, level: I, the default value is `null`.

Null or empty string means `nodename` will be set to node's current hostname.

no name is specified for the node, and the existing Hostname is used directly as the node name.

The node name `nodename` will be used as the name of the node instance (`ins` tag) in the Pigsty monitor system. In addition, if [`nodename_overwrite`](#nodename_overwrite) is true, the node name will also be used as the HOSTNAME.

Note: If the [`pg_hostname`](#pg_hostname) option is enabled, Pigsty will borrow the identity parameter of the one-by-one corresponding PG instance on the current node, such as `pg-test-1`, as the node name when initializing the node.




### `node_cluster`

Node cluster name, type: `string`, level: C, default value: `"nodes"`.

The default null value will directly use the fixed value `nodes` as the node cluster identity.

The node cluster name `node_cluster` will be used as the node cluster (`cls`) label in the Pigsty monitor system.

Note: If the [`pg_hostname`](#pg_hostname) option is enabled, Pigsty will borrow the identity parameter of the one-by-one corresponding PG cluster on the current node, such as `pg-test`, as the node cluster name when initializing the node.





### `nodename_overwrite`

Override machine HOSTNAME with node name, type: `bool`, level: C, default value: `true`.

Defaults to `true`, a non-empty node name [`nodename`](#nodename) will override the current hostname of the node.

No changes are made to the hostname if the [`nodename`](#nodename) parameter is undefined, empty, or an empty string.




### `nodename_exchange`

Exchange hostnames between playbook nodes, type: `bool`, level: C, default value: `false`.

When this parameter is enabled, node names are exchanged between the same group of nodes executing the [`nodes.yml`](playbook.md#nodes#nodes) playbook, written to `/etc/hosts`.




----------------

## `NODE_DNS`

Pigsty configs static DNS records and dynamic DNS resolver for the nodes.

If you already have a DNS server, set [`node_dns_method`](#node_dns_method) to `none` to disable dynamic DNS setup.



### `node_etc_hosts`

DNS records specific to the cluster instance level, type: `string[]`, level: C/I, default value is an empty array `[]`.

[`node_etc_hosts`](#node_etc_hosts) is an array. Each element is a string shaped like an `ip domain_name`, representing a DNS resolution record. Each of which is written to `/etc/hosts` when the machine node is initialized, suitable for cluster/instance specific records.



### `node_etc_hosts_default`

Write to static DNS resolution of the machine, type: `string[]`, level: C, default value:

```yaml
node_etc_hosts_default:                 # static dns records in /etc/hosts
  - 10.10.10.10 meta pigsty c.pigsty g.pigsty l.pigsty p.pigsty a.pigsty cli.pigsty lab.pigsty api.pigsty
```

[`node_etc_hosts_default`](#node_etc_hosts_default) is an array. Each element is a string shaped like an `ip domain_name`, representing a DNS resolution record. Each of which is written to `/etc/hosts` when the machine node is initialized, suitable for global config of infra addresses.

Make sure to write a DNS record like `10.10.10.10 pigsty yum.pigsty` to `/etc/hosts` to ensure that the local yum repo can be accessed using the domain name before the DNS Nameserver starts.






### `node_dns_method`

Config DNS server, type: `enum`, level: C, default value: `"add"`.

The default config of dynamic DNS servers for machine nodes has three modes:

* `add`: Append the records in [`node_dns_servers`](#node_dns_servers) to `/etc/resolv.conf` and keep the existing DNS servers. (default)
* `overwrite`: Overwrite `/etc/resolv.conf` with the record in [`node_dns_servers`](#node_dns_servers)
* `none`: If a DNS server is provided in the production env, the DNS server config can be skipped.




### `node_dns_servers`

Config dynamic DNS server list, type: `string[]`, level: C, default value is `10.10.10.10`.

Pigsty adds meta nodes as DNS Server by default, and DNSMASQ on the meta node responds to DNS requests in the env.

```
node_dns_servers: # dynamic nameserver in /etc/resolv.conf
  - 10.10.10.10
```





### `node_dns_options`

If [`node_dns_method`](#node_dns_method) is configured as `add` or `overwrite`, the records in this config entry will be appended or overwritten to `/etc/resolv.conf`. Please see the Linux doc for `/etc/resolv.conf` for the exact format.

The default parsing options added by Pigsty:

```bash
- options single-request-reopen timeout:1 rotate
- domain service.consul
```








----------------
## `NODE_REPO`

Pigsty configure yum repos & install packages from it.




### `node_repo_method`

A node using Yum repo, type: `enum`, level: C, default value: `"local"`.

The machine node Yum software repo is configured in three modes:

* `local`: Use the local Yum repo on the meta node, the default behavior (recommended).
* `public`: To install using internet sources, write the public repo in `repo_upstream` to `/etc/yum.repos.d/`.
* `none`: No config and modification of local repos.




### `node_repo_remove`

Remove nodes with existing Yum repos, type: `bool`, level: C, default value: `true`.

If enabled, Pigsty will move repo file in `/etc/yum.repos.d` to backup dir: `/etc/yum.repos.d/backup`




### `node_repo_local_urls`

URL address of the local repo, type: `url[]`, level: C, default value is `local`.

[`node_repo_method`](#node_repo_method) configured as `local`, the Repo file URLs listed here will be downloaded to `/etc/yum.repos.d`.

Here is an array of Repo File URLs that Pigsty will add by default to the machine's source config for the local Yum repos on the meta node.

```
node_repo_local_urls:
  - http://yum.pigsty/pigsty.repo
```





----------------

## `NODE_PACKAGE`

This section describe which packages to install.


### `node_packages`

List of packages that are specific to nodes, type: `string[]`, level: C, default value: `[]`

Like [`node_packages_default`](#node_packages_default), the former is usually configured globally, while [`node_packages`](#node_packages) makes exceptions for specific nodes.



### `node_packages_default`

List of packages that all nodes are installed by default, type: `string[]`, level: C, default value:

The package list is an array, but each element can contain multiple pkgs separated by **commas**. The list of pkgs installed by Pigsty by default is as follows:

<details><summary>RHEL7 node packages</summary>

```yaml
- chrony,zip,unzip,bzip2,lz4,netcat,pv,jq,wget,sshpass,uuid,make,patch,bash,lsof,git,ftp,perf,rsync,ca-certificates
- numactl,grubby,vim-minimal,sysstat,dstat,iotop,bind-utils,net-tools,tcpdump,socat,ipvsadm,telnet,perf,nvme-cli
- python3,python3-pip,python3-requests,python3-psycopg2,python3-etcd,python3-consul,python3-urllib3,python3-idna,python36-pyOpenSSL
- readline,zlib,openssl,openssl-libs,openssh-clients,node_exporter,consul,etcd,promtail
```

</details>


<details><summary>RHEL8 node packages</summary>

```yaml
- chrony,zip,unzip,bzip2,lz4,netcat,pv,jq,wget,sshpass,uuid,make,patch,bash,lsof,git,ftp,perf,rsync,ca-certificates
- numactl,grubby,vim-minimal,sysstat,dstat,iotop,bind-utils,net-tools,tcpdump,socat,ipvsadm,telnet,perf,nvme-cli
- python3,python3-pip,python3-requests,python3-psycopg2,python3-etcd,python3-consul,python3-urllib3,python3-idna,python3-pyOpenSSL
- readline,zlib,openssl,openssl-libs,openssh-clients,node_exporter,consul,etcd,promtail
```

</details>


<details><summary>RHEL9 node packages</summary>

```yaml
- chrony,zip,unzip,bzip2,lz4,netcat,pv,jq,wget,sshpass,uuid,make,patch,bash,lsof,git,ftp,perf,rsync,ca-certificates
- numactl,grubby,vim-minimal,sysstat,dstat,iotop,bind-utils,net-tools,tcpdump,socat,ipvsadm,telnet,perf,nvme-cli
- python3,python3-pip,python3-requests,python3-psycopg2,python3-etcd,python3-consul,python3-urllib3,python3-idna,python3-pyOpenSSL
- readline,zlib,openssl,openssl-libs,openssh-clients,node_exporter,consul,etcd,promtail
```

</details>




### `node_packages_meta`

List of packages that will be installed on meta nodes, type: `string[]`, level: G, default value:

<details><summary>RHEL7 meta packages</summary>

```yaml
- grafana,prometheus2,alertmanager,loki,nginx_exporter,blackbox_exporter,pushgateway
- nginx,pgbadger,dnsmasq,coreutils,diffutils,python3-psycopg3,postgresql14,redis
- ansible,polysh
```

</details>


<details><summary>RHEL8 meta packages</summary>

```yaml
- grafana,prometheus2,alertmanager,loki,nginx_exporter,blackbox_exporter,pushgateway
- nginx,ansible,pgbadger,dnsmasq,coreutils,diffutils,python3-psycopg3,python38-jmespath
- postgresql14,redis
```

</details>


<details><summary>RHEL9 meta packages</summary>

```yaml
- grafana,prometheus2,alertmanager,loki,nginx_exporter,blackbox_exporter,pushgateway
- nginx,ansible,pgbadger,dnsmasq,coreutils,diffutils,python3-psycopg3,python3-jmespath,python3-pip
- postgresql14,redis
```

</details>




### `node_packages_meta_pip`

Package installed on the meta node via pip3, type: `string`, level: G, default value: `"jupyterlab"`.

The package will be downloaded to [`{{ nginx_home }}`](#nginx_home)/[`{{ repo_name }}`](#repo_name)/`python` dir and then installed uniformly.

Currently, `jupyterlab` will be installed by default, providing a complete Python runtime env.

!> `jupyterlab` is not installed on el8, el9 by default.






----------------

## `NODE_TUNE`

Configure some features, kernel modules, and tuning templates on the node.



### `node_disable_firewall`

Turn off node firewall, type: `bool`, level: C, default value: `true`, please keep it off.





### `node_disable_selinux`

Close node SELINUX, type: `bool`, level: C, default value: `true`, please keep it off.




### `node_disable_numa`

Close the node NUMA, type: `bool`, level: C, default value: `false`.

Boolean flag, default is not off. Note that turning off NUMA requires a reboot of the machine before it can take effect!

If you don't know how to set the affinity with a specific CPU core, it is recommended to turn off NUMA when using the database in a production env.





### `node_disable_swap`

Turn off node SWAP, type: `bool`, level: C, default value: `false`.

Turning off SWAP is not recommended and can be done to improve performance if there is enough memory and the database is deployed exclusively.

SWAP should be disabled when your node is used for a Kubernetes deployment.





### `node_static_network`

Use static DNS servers, Type: `bool`, Level: C, Default: `true`, Enabled by default.

Enabling static networking means that machine reboots will not overwrite your DNS Resolv config with NIC changes. It is recommended to allow for it.





### `node_disk_prefetch`

Enable disk pre-reading, type: `bool`, level: C, default value: `false`, not enabled by default.

Instances deployed against HDDs optimize throughput and are recommended to be enabled when using HDDs.






### `node_kernel_modules`

Enabled kernel module, type: `string[]`, level: C, default value:

An array consisting of kernel module names declaring the kernel modules that need to be installed on the node. Pigsty will enable the following kernel modules by default:

```yaml
node_kernel_modules: [ softdog, ip_vs, ip_vs_rr, ip_vs_wrr, ip_vs_sh ]
```



### `node_tune`

Node tuning mode, type: `enum`, level: C, default value: `"tiny"`.


Prefabricated solutions for machine tuning, based on the `tuned` service. There are four pre-production models:

* `tiny`: Micro Virtual Machine
* `oltp`: Regular OLTP templates with optimized latency
* `olap `: Regular OLAP templates to optimize throughput
* `crit`: Core financial business templates, optimizing the number of dirty pages

Usually, the database tuning template [`pg_conf`](#pg_conf) should be paired with the node tuning template: [`node_tune`](#node_tune)




### `node_sysctl_params`

OS kernel parameter, type: `dict`, level: C, default value is an empty dictionary.

Dictionary K-V structure, Key is kernel `sysctl` parameter name, Value is the parameter value.

You can also define sysctl parameters with tuned profile






----------------

## `NODE_ADMIN`

This section is about admin users and it's credentials.



### `node_data_dir`

Mountpoint of major data disk, level: C, default value: `/data`.

If specified, this path will be used as major data disk mountpoint.

And a dir will be created and throwing a warning if path not exists.

The data dir is owned by root with mode `0777`.




### `node_admin_enabled`

Create admin user, type: `bool`, level: G, default value: `true`.

To create an admin user on each node (password-free sudo and ssh),  an admin user named `dba (uid=88)` will be created, which can access other nodes in the env and perform sudo from the meta node via SSH password-free.




### `node_admin_uid`

Admin user UID, type: `int`, level: G, default value: `88`, note UID namespace conflict.




### `node_admin_username`

Admin username, type: `string`, level: G, default value: `"dba"`.





### `node_admin_ssh_exchange`

Exchange node admin SSH keys between instances, type: `bool`, level: C, default value: `true`.

When enabled, Pigsty will exchange SSH public keys between members during playbook execution, allowing admins [`node_admin_username`](#node_admin_username) to access each other from different nodes.




### `node_admin_pk_current`

Whether to add the public key of the current node & user to the admin account, type: `bool`, level: A, default value: `true`.

When enabled, on the current node, the SSH public key (`~/.ssh/id_rsa.pub`) of the current user is copied to the `authorized_keys` of the target node admin user.

When deploying in a production env, be sure to pay attention to this parameter, which installs the default public key of the user currently executing the command to the admin user of all machines.




### `node_admin_pk_list`

The list of public keys for login able admin, type: `key[]`, level: C, default value is an empty array; the demo has the default public key for `vagrant` users.

Each element of the array is a string containing the key written to the admin user `~/.ssh/authorized_keys`, and the user with the corresponding private key can log in as an admin user.

When deploying in production envs, be sure to note this parameter and add only trusted keys to this list.







----------------

## `NODE_TIME`

Correct time is critial for a database, so we setup `chronyd` on all nodes.

If the node is already configured with an NTP server, you can configure [`node_ntp_enabled`](#node_dns_method) to `false` to skip the setting of the NTP service.



### `node_timezone`

NTP time zone setting, type: `string`, level: C, default value is null. (leave original timezone setting)

The default time zone used in the demo is `"Asia/Hong_Kong"` please adjust it according to your actual situation.
(Please don't use `Asia/Shanghai` time zone, the abbreviation CST will cause a series of log time zone parsing problems)

Select `false`, or leave it blank, and Pigsty will not modify the time zone config of this node.




### `node_ntp_enabled`

Is the NTP service configured? , type: `bool`, level: C, default value: `true`.

Value is  `true`: Pigsty will override the node's `/etc/ntp.conf` or `/etc/chrony.conf` by filling in the NTP server specified by [`node_ntp_servers`](#node_ntp_servers).

If the server node is already configured with an NTP server, it is recommended to turn it off and use the original NTP server.




### `node_ntp_service`

NTP service type: `ntp` or `chrony`, type: `enum`, level: C, default value: `"ntp"`.

Specify the type of NTP service used by the system; by default, `ntp` is used as the time service:

* `ntp`: Traditional NTP Service
* `chrony`: Time services used by CentOS 7/8 by default

It only takes effect if [`node_ntp_enabled`](#node_ntp_enabled) is true.



### `node_ntp_servers`

List of NTP servers, type: `string[]`, level: C, default value:

```yaml
- pool cn.pool.ntp.org iburst
- pool pool.ntp.org iburst
- pool time.pool.aliyun.com iburst
- server 10.10.10.10 iburst
```

It only takes effect if [`node_ntp_enabled`](#node_ntp_enabled) is true.

You can use `${meta_ip}` to sync time with meta node ntp service, but it's not recommended.




### `node_crontab_overwrite`

Overwrite instead of append /etc/crontab, type: `bool`, level: C/I, default value: `true`

if true, records in [`node_crontab`](#node_crontab) will render to`/etc/crontab` instead of appending to it.




### `node_crontab`

Crontab of this node, type: `string[]`, level: C/I, default value: `[]`

Each element of the array is a string in `/etc/crontab`.




----------------

## `DOCKER`

Pigsty install docker on all meta nodes by default, disabled on common nodes by default.




### `docker_enabled`

Enable docker on current node? type: `bool`, level: C, default value: `false`. default `true` on meta nodes.




### `docker_cgroups_driver`

CGroup drivers for docker, type: `string`, level: C, default value: `systemd`.



### `docker_registry_mirrors`

Docker registry mirror list, type: `string[]`, level:`C`, default value: `[]`.




### `docker_image_cache`

Local image cache, type: `string`, level: C, default value: `"/var/pigsty/docker.tar.lz4"`.

The local image cache will be loaded into docker when the target path exists.




----------------
## `NODE_EXPORTER`


NodeExporter is used to collect monitor metrics data from the host.



### `node_exporter_enabled`

Enable node indicator collector, type: `bool`, level: C, default value: `true`.




### `node_exporter_port`

NodeExposure Port, type: `int`, level: C, default value: `9100`.




### `node_exporter_options`

Node metrics collection option, type: `string`, level: C/I, default value: `"--no-collector.softnet --no-collector.nvme --collector.ntp --collector.tcpstat --collector.processes"`

Pigsty enables `ntp`, `tcpstat`, `processes` three extra metrics, collectors, by default, and disables `softnet`, `nvme` two default metrics collectors.






----------------

## `PROMTAIL`

Host log collection component, used with [Loki](#loki) infrastructure config.



### `promtail_enabled`

Enable Protail log collection service at the current node, type: `bool`, level: C, default value: `true`.

When [`promtail`](#promtail) is enabled, Pigsty will generate a config file for Promtail, as defined in the inventory, to grab the following logs and send them to the Loki instance specified by [`loki_endpoint`](#loki_endpoint).

* `INFRA`: Infra logs, collected only on meta nodes.
    * `nginx-access`: `/var/log/nginx/access.log`
    * `nginx-error`: `/var/log/nginx/error.log`
    * `grafana`: `/var/log/grafana/grafana.log`

* `NODES`: Host node logs, collected on all nodes.
    * `syslog`: `/var/log/messages`
    * `dmesg`: `/var/log/dmesg`
    * `cron`: `/var/log/cron`

* `PGSQL`: PostgreSQL logs, collected when a node is defined with `pg_cluster`.
    * `postgres`: `/pg/data/log/*.csv`
    * `patroni`: `/pg/log/patroni.log`
    * `pgbouncer`: `/var/log/pgbouncer/pgbouncer.log`

* `REDIS`: Redis logs, collected when a node is defined with `redis_cluster`.
    * `redis`: `/var/log/redis/*.log`

!> Some Log directory are customizable according to [`pg_log_dir`](#pg_log_dir), [`patroni_log_dir`](#patroni_log_dir), [`pgbouncer_log_dir`](#pgbouncer_log_dir), [`redis_log_dir`](#redis_log_dir).



### `promtail_clean`

Remove existing state information when installing protail, type: `bool`, level: C/A, default value: `false`.

The default is not to clean up; when you choose to clean up, Pigsty will remove the existing state file [`promtail_positions`](#promtail_positions) when deploying Promtail, which means that Promtail will recollect all logs on the current node and send them to Loki.




### `promtail_port`

The default port used by promtail, type: `int`, level: G, default value: `9080`.




### `promtail_options`

Promtail CLI param, type: `string`, level: C/I, default value: `"-config.file=/etc/promtail.yml -config.expand-env=true"`.

Extra CLI params passed in when running the protail database, default value: `'-config.file=/etc/promtail.yml -config.expand-env=true'`.

There are already params for specifying the config file path and expanding the environment variables in the config file, which are not recommended to be modified.



### `promtail_positions`

Path to promtail status file, type: `string`, level: C, default value:`"/var/log/positions.yaml"`

Promtail records the consumption offsets of all logs, which are periodically written to the file specified by [`promtail_positions`](#promtail_positions).














--------------------------------

# PGSQL


Pigsty has 100+ config parameters for describing a PostgreSQL cluster.
However, users usually only need to care about a few parameters in [identity params](#pg_identity) and [business objects](#pg_business): 
the former expresses the database cluster "Who is it? Where is it?" and the latter represents the database "What does it look like? What's in it?".

The params on the PostgreSQL are divided into seven main sections:



----------------

## `PG_IDENTITY`

[`pg_cluster`](#pg_cluster), [`pg_role`](#pg_role), [`pg_seq`](#pg_seq) belong to **identity params** .

In addition to the IP, these three parameters are the minimum set of parameters necessary to define a new set of clusters. A typical example is shown below:

```yaml
pg-test:
  hosts:
    10.10.10.11: {pg_seq: 1, pg_role: replica}
    10.10.10.12: {pg_seq: 2, pg_role: primary}
    10.10.10.13: {pg_seq: 3, pg_role: replica}
  vars:
    pg_cluster: pg-test
```

All other params can be inherited from the global config or the default config, but the identity params must be **explicitly specified** and **manually assigned**. The current PGSQL identity params are as follows:

|            Name             |   Type   | Level | Description                                            |
| :-------------------------: | :------: | :---: | ------------------------------------------------------ |
| [`pg_cluster`](#pg_cluster) | `string` | **C** | **PG database cluster name**                           |
|     [`pg_seq`](#pg_seq)     | `number` | **I** | **PG database ins serial number**                      |
|    [`pg_role`](#pg_role)    |  `enum`  | **I** | **PG database ins role**                               |
|   [`pg_shard`](#pg_shard)   | `string` | **C** | **PG database slice set cluster name** (placeholder)   |
|  [`pg_sindex`](#pg_sindex)  | `number` | **C** | **PG database slice set cluster number** (placeholder) |

* [`pg_cluster`](#pg_cluster): It identifies the name of the cluster, which is configured at the cluster level.
* [`pg_role`](#pg_role): Configured at the instance level, identifies the role of the ins. Only the `primary` role will be handled specially. If not filled in, the default is the `replica` role and the special `delayed` and `offline` roles.
* [`pg_seq`](#pg_seq): Used to identify the ins within the cluster, usually with an integer number incremented from 0 or 1, which is not changed once it is assigned.
* `{{ pg_cluster }}-{{ pg_seq }}` is used to uniquely identify the ins, i.e. `pg_instance`.
* `{{ pg_cluster }}-{{ pg_role }}` is used to identify the services within the cluster, i.e. `pg_service`.
* [`pg_shard`](#pg_shard) and [`pg_sindex`](#pg_sindex) are used for horizontally sharding clusters, reserved for Citus and Greenplum multicluster management.





### `pg_cluster`

PG cluster name, type: `string`, level: cluster, no default. **A mandatory parameter must be provided by the user**.

The cluster name will be used as the namespace for the resources within the cluster. The naming needs to follow a specific naming pattern: `[a-z][a-z0-9-]*` to be compatible with the requirements of different constraints on the identity.




### `pg_shard`

Shard to which the PG cluster belongs (reserved), type: `string`, level: cluster, No default.

Only sharding clusters require this parameter to be set. When multiple clusters serve the same business in a horizontally sharded fashion, Pigsty refers to this group of clusters as a **Sharding Cluster**.

`pg_shard` is the name of the shard set cluster to which the cluster belongs. A shard set cluster can be specified with any name, but Pigsty recommends a meaningful naming pattern.

For example, a cluster participating in a sharded cluster can use the shard cluster name [`pg_shard`](#pg_shard) + `shard` + the cluster's shard number [`pg_sindex`](#pg_sindex) to form the cluster name:

```
shard:  test
pg-testshard1
pg-testshard2
pg-testshard3
pg-testshard4
```




### `pg_sindex`

PG cluster's slice number (reserved), type: `int`, level: C, no default.

The sharded cluster's slice number, used in conjunction with [pg_shard](#pg_shard) is usually assigned sequentially starting from 0 or 1. Only sharded clusters require this param to be set.




### `gp_role`

Current role of PG cluster in GP, type: `enum`, level: C, default value:

Greenplum/MatrixDB-specific to specify the role this PG cluster plays in a GP deployment. The optional values are :
* `master`: Facilitator Nodes
* `segment`: Data Nodes

**Identity parameter**, **cluster level parameter**, and **mandatory parameter** when deploying GPSQL.



### `pg_role`

PG instance role, type: `enum`, level: I, no default,  **mandatory parameter, must be provided by the user.**

Roles for PG ins, default roles include   `primary`, `replica`, and `offline`.

* `primary`: Primary, there must be one and only one member of the cluster as `primary`.
* `replica`: Replica for carrying online read-only traffic.
* `offline`: Offline replica for taking on offline read-only traffic, such as statistical analysis/ETL/personal queries, etc.

**Identity params, required params, and instance-level params.**




### `pg_seq`

PG ins serial number, type: `int`, level: I, no default value,  **mandatory parameter, must be provided by the user.**

A serial number of the database ins, unique within the **cluster**, is used to distinguish and identify different instances within the cluster, assigned starting from 0 or 1.



### `pg_instances`

All PG instances on the current node, type: `{port:ins}`, level: I, default value:

This parameter can be used to describe when the node is deployed by more than one PG ins, such as Greenplum's Segments, or when using [monly mode](/en/docs/pgsql/deploy/monitor.md) to supervise existing ins.
[`pg_instances`](#pg_instances) is an array of objects with keys as ins ports and values as a dictionary whose contents can be parameters of any [`PGSQL`](/en/docs/pgsql/config) board, see [MatrixDB deploy](/en/docs/pgsql/matrixdb) for details.





### `pg_upstream`

The replicated upstream node of the instance, type: `string`, level: I, the default value is null.

Ins-level config entry with IP or hostname to indicate the upstream node for stream replication.

* When configuring this parameter for a replica, the IP filled in must be another node within the cluster. Instances will be stream replicated from that node, and this option can be used to build **cascaded replication**.

* When this parameter is configured for the primary of the cluster, it means that the entire cluster will run as a **Standby Cluster**, receiving changes from upstream nodes. The `primary` in the cluster will play the role of `standby leader`.

Using this parameter flexibly, you can build a standby cluster, complete the splitting of the sharded cluster, and realize the delayed cluster.




### `pg_offline_query`

Allow offline queries, type: `bool`, level: I, default value: `false`.

When set to `true`, the user group `dbrole_offline` can connect to the ins and perform offline queries, regardless of the role of the current ins.

More practical for cases with a small number of ins (one primary & one replica), the user can mark the only replica as `pg_offline_query = true`, thus accepting ETL, slow queries with interactive access.




### `pg_backup`

Store cold standbys on the ins, type: `bool`, level: I, default value: `false`.

Not implemented, the tag bit is reserved and the ins node with this tag is used to store the base cold standby.




### `pg_weight`

The relative weight of the ins in load balancing, type: `int`, level: I, default value: `100`.

When adjusting the relative weight of an instance in service, this parameter can be modified at the instance level and applied to take effect as described in [SOP: Cluster Traffic Adjustment](/en/docs/pgsql/reference/sop).




### `pg_hostname`

Set PG ins name to HOSTNAME, type: `bool`, level: C/I, default value: `false`, which is true by default in the demo.

Use the PG ins name and cluster name as the node's name and cluster name when initializing the nodean , disabled by default.

When using the node: PG 1:1 exclusive deploy mode, you can assign the identity of the PG ins to the node, making the node consistent with the PG's monitor identity.




### `pg_preflight_skip`

Skip preflight param validation, type: `bool`, level: C/A, default value: `false`.

If not initializing a new cluster, the task of Patroni and Postgres initialization can be completely skipped with this parameter.





----------------

## `PG_BUSINESS`

Users need to **focus on** this part of the parameters to declare their required database objects on behalf of the business.

Customized cluster templates: users, databases, services, privilege patterns.

* Business User Definition: [`pg_users`](#pg_users)
* Business Database Definition: [`pg_databases`](#pg_databases)
* Cluster Proprietary Services Definition: [`pg_services_extra`](#pg_services_extra)
* Cluster/ins specific HBA rules: [`pg_hba_rules_extra`](#pg_hba_rules_extra)
* Pgbounce specific HBA rules: [`pgbouncer_hba_rules_extra`](#pgbouncer_hba_rules_extra)

Special DB users, it is recommended to change these user passwords in the production env.

* PG Admin User: [`pg_admin_username`](#pg_admin_username) / [`pg_admin_password`](#pg_admin_password)
* PG Replication User:  [`pg_replication_username`](#pg_replication_username) / [`pg_replication_password`](#pg_replication_password)
* PG Monitor Users: [`pg_monitor_username`](#pg_monitor_username) / [`pg_monitor_password`](#pg_monitor_password)




### `pg_users`

Business user definition, type: `user[]`, level: C, default value is an empty array.

Used to define business users at the cluster level, each object in the array defines a [user or role](c-pgdbuser#users), a complete user definition is as follows:

```yaml
pg_users:                           # define business users/roles on this cluster, array of user definition
  # define admin user for meta database (This user are used for pigsty app deployment by default)
  - name: dbuser_meta               # required, `name` is the only mandatory field of a user definition
    password: md5d3d10d8cad606308bdb180148bf663e1  # md5 salted password of 'DBUser.Meta'
    # optional, plain text and md5 password are both acceptable (prefixed with `md5`)
    login: true                     # optional, can login, true by default  (new biz ROLE should be false)
    superuser: false                # optional, is superuser? false by default
    createdb: false                 # optional, can create database? false by default
    createrole: false               # optional, can create role? false by default
    inherit: true                   # optional, can this role use inherited privileges? true by default
    replication: false              # optional, can this role do replication? false by default
    bypassrls: false                # optional, can this role bypass row level security? false by default
    pgbouncer: true                 # optional, add this user to pgbouncer user-list? false by default (production user should be true explicitly)
    connlimit: -1                   # optional, user connection limit, default -1 disable limit
    expire_in: 3650                 # optional, now + n days when this role is expired (OVERWRITE expire_at)
    expire_at: '2030-12-31'         # optional, YYYY-MM-DD 'timestamp' when this role is expired  (OVERWRITTEN by expire_in)
    comment: pigsty admin user      # optional, comment string for this user/role
    roles: [dbrole_admin]           # optional, belonged roles. default roles are: dbrole_{admin,readonly,readwrite,offline}
    parameters:                     # optional, role level parameters with `ALTER ROLE SET`
      log_min_duration_statements: 1000                  
    search_path: public         # key value config parameters according to postgresql documentation (e.g: use pigsty as default search_path)
  - {name: dbuser_view , password: DBUser.Viewer  ,pgbouncer: true ,roles: [dbrole_readonly], comment: read-only viewer for meta database}

  # define additional business users for prometheus & grafana (optional)
  - {name: dbuser_grafana    , password: DBUser.Grafana    ,pgbouncer: true ,roles: [dbrole_admin], comment: admin user for grafana database }
  - {name: dbuser_prometheus , password: DBUser.Prometheus ,pgbouncer: true ,roles: [dbrole_admin], comment: admin user for prometheus database }
```

* Each user or role must specify a `name` and the rest of the fields are **optional**, a `name` must be unique in this list.
* `password` is optional, if left blank then no password is set, you can use the MD5 ciphertext password.
* `login`, `superuser`, `createdb`, `createrole`, `inherit`, `replication` and ` bypassrls` are all boolean types used to set user attributes. If not set, the system defaults are used.
* Users are created by `CREATE USER`, so they have the `login` attribute by default. If the role is created, you need to specify `login: false`.
* `expire_at` and `expire_in` are used to control the user expiration time. `expire_at` uses a date timestamp in the shape of `YYYY-mm-DD`. `expire_in` uses the number of days to expire from now, and overrides the `expire_at` option if `expire_in` exists.
* New users are **not** added to the Pgbouncer user list by default, and `pgbouncer: true` must be explicitly defined for the user to be added to the Pgbouncer user list.
* Users/roles are created sequentially, and users defined later can belong to the roles defined earlier.
* Users can add [default privilegs](#pg_default_privilegs) groups for business users via the `roles` field:
    * `dbrole_readonly`: Default production read-only user with global read-only privileges. (Read-only production access)
    * `dbrole_offline`: Default offline read-only user with read-only access on a specific ins. (offline query, personal account, ETL)
    * `dbrole_readwrite`: Default production read/write user with global CRUD privileges. (Regular production use)
    * `dbrole_admin`: Default production management user with the privilege to execute DDL changes. (Admin User)

Configure `pgbouncer: true` for the production account to allow it to access through the connection pool; regular users should not access the database through the connection pool.





### `pg_databases`

Business database definition, type: `database[]`, level: C, default value is an empty array.

Used to define business users at the cluster level, each object in the array defines a [business database](c-pgdbuser#database), a complete database definition as follows:

```yaml
pg_databases:                       # define business databases on this cluster, array of database definition
  # define the default `meta` database
  - name: meta                      # required, `name` is the only mandatory field of a database definition
    baseline: cmdb.sql              # optional, database sql baseline path, (relative path among ansible search path, e.g files/)
    owner: postgres                 # optional, database owner, postgres by default
    template: template1             # optional, which template to use, template1 by default
    encoding: UTF8                  # optional, database encoding, UTF8 by default. (MUST same as template database)
    locale: C                       # optional, database locale, C by default.  (MUST same as template database)
    lc_collate: C                   # optional, database collate, C by default. (MUST same as template database)
    lc_ctype: C                     # optional, database ctype, C by default.   (MUST same as template database)
    tablespace: pg_default          # optional, default tablespace, 'pg_default' by default.
    allowconn: true                 # optional, allow connection, true by default. false will disable connect at all
    revokeconn: false               # optional, revoke public connection privilege. false by default. (leave connect with grant option to owner)
    pgbouncer: true                 # optional, add this database to pgbouncer database list? true by default
    comment: pigsty meta database   # optional, comment string for this database
    connlimit: -1                   # optional, database connection limit, default -1 disable limit
    schemas: [pigsty]               # optional, additional schemas to be created, array of schema names
    extensions:                     # optional, additional extensions to be installed: array of schema definition `{name,schema}`
      - {name: adminpack, schema: pg_catalog}    # install adminpack to pg_catalog and install postgis to public
      - {name: postgis, schema: public}          # if schema is omitted, extension will be installed according to search_path.

```

In each DB definition, the DB  `name` is mandatory and the rest are optional.

* `name`: Database name, **Must**.
* `owner`: Database owner, default is `postgres`
* `template`: The template used for database creation, default is `template1`.
* `encoding`: The default character encoding of the database, which is `UTF8` by default, is consistent with the ins by default. It is recommended not to configure and modify it.
* `locale`: The default localization rule for the database, which defaults to `C`, is recommended not to be configured to be consistent with the instance.
* `lc_collate`: The default localized string sorting rule for the database, which is set the same as the instance by default, should not be modified and must be consistent with the DB template. It is strongly recommended not to configure, or configure to `C`.
* `lc_ctype`: The default LOCALE of the database, by default, is the same as the ins setting, do not modify or set it, it must be consistent with the DB template. Configure to C or `en_US.UTF8`.
* `allowconn`: Allow database connection, default is `true`, not recommended to change.
* `revokeconn`: Reclaim privilege to connect to the database. The default is `false`. To be `true`, the `PUBLIC CONNECT` privilege on the database will be reclaimed. Only the default user (`dbsu|monitor|admin|replicator|owner`) can connect. In addition, the `admin|owner` will have GRANT OPTION, which can give other users connection privileges.
* `tablespace`: The tablespace associated with the database, the default is `pg_default`.
* `connlimit`: Database connection limit, default is `-1`, i.e. no limit.
* `extensions`: An array of objects, each of which defines an **extension** in the database, and its installed **mode**.
* `parameters`: K-V objects, each K-V defines a parameter that needs to be modified against the database via `ALTER DATABASE`.
* `pgbouncer`: Boolean option to join this database to Pgbouncer or not. All databases are joined to Pgbouncer unless `pgbouncer: false` is explicitly specified.
* `comment`: Database note information.






### `pg_services_extra`

Cluster Proprietary Service Definition, Type: `service[]`, Level: C, Default:

Used to define additional services at the cluster level, each object in the array defines a [service](c-service#service), a complete service definition is as follows:

```yaml
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

Each cluster can define multiple services, each containing any number of cluster members. Services are distinguished by **port**, `name`, and `src_port` are mandatory and must be unique within the array.

**REQUIRED**
* Name (`service.name`):
  The full name of the service is prefixed by the cluster name and suffixed by `service.name`, connected by `-`. For example, the service with `name=primary` in the `pg-test` cluster has the full-service name `pg-test-primary`.
* Port (`service.port`):
  In Pigsty, services are exposed to the public by default in the form of NodePort, so exposing the port is mandatory. However, if you use an external LB service access scheme, you can also differentiate the services in other ways.
* Selector (`service.selector`):
  The **selector** specifies the ins members of the service, in the form of JMESPath, filtering variables from all cluster ins members. The default `[]` selector will pick all cluster members.

**Optional**
* Backup Selector(`service.selector`):
  The optional **backup selector** `service.selector_backup` selects or marks the list of ins used for service backup, i.e. the backup ins take over the service only when all other members of the cluster fail. For example, the `primary` ins can be added to the `replica` service's alternative set, so that the primary can still carry the cluster's read-only traffic when all replicas fail.
* Source IP(`service.src_ip`) :
  Indicates the IP used externally by the **service**. The default is `*`, which is all IPs on the local. Using `vip` will use the `vip_address` variable to take the value, or you can fill in the specific IP supported by the NIC.
* Host port(`service.dst_port`):
  Which port on the target ins will the service's traffic be directed to? `postgres` will point to the port the database is listening on, `pgbouncer` will point to the port the connection pool is listening on, or you can fill in a fixed port.
* Health Check method(`service.check_method`):
  How does the service check the health status of the instance? Currently, only HTTP is supported.
* Health Check Port(`service.check_port`):
  Which port of the service check-ins gets the health status of the ins? `patroni` will get it from Patroni (default 8008), `pg_exporter` will get it from PG Exporter (default 9630), or you can fill in a custom port.
* Health Check Path(`service.check_url`):
  The service performs HTTP checks using the URL PATH. `/` is used as a health check by default, and PG Exporter and Patroni provide a variety of health checks that can be used to differentiate between primary & replica traffic. For example, `/primary` will only return success for the primary, and `/replica` will only return success for the replica. `/read-only` will return success for any instance that supports read-only (including the primary).
* Health Check Code(`service.check_code`):
  The code expected by the HTTP health check, default is 200.
* Haproxy Specific Placement(`service.haproxy`) :
  Proprietary config entries for service provisioning software (HAproxy).
    * `<service>.haproxy`
      These parameters are now defined in [**service**](/en/docs/pgsql/concept/service#service), using `service.haproxy` to override the parameter config of the ins.
    * `maxconn`
      HAProxy maximum number of front and back-end connections, default is 3000.
    * `balance`
      In the algorithm used by haproxy LB, the optional policy is `roundrobin`, and `leastconn`, the default is `roundrobin`.
    * `default_server_options`
      Default options for Haproxy backend server ins:
      `'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'`





### `pg_hba_rules_extra`

Cluster/ins specific HBA rule, Type: `rule[]`, Level: C, Default:

Set the client IP black and white list rules for the database. An array of objects, each of which represents a rule, each of which consists of three parts:

* `title`: Rule headings, which are converted to comments in the HBA file
* `role`: Apply for roles, `common` means apply to all instances, other values (e.g. `replica`, `offline`) will only be installed to matching roles. For example, `role='replica'` means that this rule will only be applied to instances with `pg_role == 'replica'`.
* `rules`: Array of strings, each record represents a rule that will eventually be written to `pg_hba.conf`.

As a special case, the HBA rule for `role == 'offline'` is additionally installed on instance of `pg_offline_query == true`.

[`pg_hba_rules`](#pg_hba_rules) is similar, but is typically used for global uniform HBA rule settings, and [`pg_hba_rules_extra`](#pg_hba_rules_extra) will **append** to `pg_hba.conf` in the same way.

If you need to completely **overwrite** the cluster's HBA rules and do not want to inherit the global HBA config, you should configure [`pg_hba_rules`](#pg_hba_rules) at the cluster level and override the global config.





### `pgbouncer_hba_rules_extra`

Pgbounce HBA rule, type: `rule[]`, level: C, default value is an empty array.

Similar to [`pg_hba_rules_extra`](#pg_hba_rules_extra) for extra config of Pgbouncer's HBA rules at the cluster level.







### `pg_admin_username`

PG admin user, type: `string`, level: G, default value: `"dbuser_dba"`.

The DB username is used to perform PG management tasks (DDL changes), with superuser privileges by default.

### `pg_admin_password`

PG admin user password, type: `string`, level: G, default value: `"DBUser.DBA"`.

The database user password used to perform PG management tasks (DDL changes) must be in plaintext. The default is `DBUser.DBA` and highly recommended changes!

It is highly recommended to change this parameter when deploying in production envs!



### `pg_replication_username`

PG replication user's name, type: `string`, level: G, default value: `"replicator"`.

For performing PostgreSQL stream replication, it is recommended to keep global consistency.

### `pg_replication_password`

PG's Replication User Password, type: `string`, level: G, default value: `"DBUser.Replicator"`.

The password of the database user used to perform PostgreSQL stream replication must be in plaintext. The default is `DBUser.Replicator`.

It is highly recommended to change this parameter when deploying in production envs!



### `pg_monitor_username`

PG monitor user, type: `string`, level: G, default value: `"dbuser_monitor"`.

The database user name is used to perform PostgreSQL and Pgbouncer monitoring tasks.



### `pg_monitor_password`

PG monitor user password, type: `string`, level: G, default value: `"DBUser.Monitor"`.

The password of the database user used to perform PostgreSQL and Pgbouncer monitoring tasks, must be in plaintext.

It is highly recommended to change this parameter when deploying in production envs!





----------------
## `PG_INSTALL`

PG Install is responsible for completing the installation of all PostgreSQL dependencies on a machine with the base software. The user can configure the name, ID, privileges, and access of the dbsu, configure the sources used for the installation, configure the installation address, the version to be installed, and the required pkgs and extensions plugins.

Such parameters only need to be modified when upgrading a major version of the database as a whole. Users can specify the software version to be installed via [`pg_version`](#pg_version) and override it at the cluster level to install different database versions for different clusters.





### `pg_dbsu`

PG OS dbsu, type: `string`, level: C, default value: `"postgres"`, not recommended to modify.

When installing Greenplum / MatrixDB, modify this parameter to the corresponding recommended value: `gpadmin|mxadmin`.




### `pg_dbsu_uid`

dbsu UID, type: `int`, level: C, default value: `26`.

UID of the dbsu is used by the database by default. The default value is `26`, consistent with the official RPM pkg-config of PG under CentOS, no modification is recommended.




### `pg_dbsu_sudo`

Sudo privilege for dbsu, type: `enum`, level: C, default value: `"limit"`.

* `none`: No Sudo privilege
* `limit`: Limited sudo privilege to execute systemctl commands for database-related components, default.
* `all`: Full `sudo` privilege, password required.
* `nopass`: Full `sudo` privileges without a password (not recommended).

The database superuser [`pg_dbsu`](#pg_dbsu) has restricted `sudo` privilege by default: `limit`.




### `pg_dbsu_home`

Home dir of dbsu [`pg_dbsu`](#pg_dbsu), type: `path`, level: C, default value: `"/var/lib/pgsql"`.




### `pg_dbsu_ssh_exchange`

Exchange the SSH key of dbsu [`pg_dbsu`](#pg_dbsu) between executing machines. Type: `bool`, Level: C, Default: `true`.




### `pg_version`

Installed major PG version, type: `int`, level: C, default value: `14`.

The current instance's installed a major PG version. Default is 14, supported as low as 10.

Note that PostgreSQL physical stream replication cannot span major versions, please configure this variable at the global/cluster level to ensure that all ins within the entire cluster have the same major version number.




### `pgdg_repo`

Add the official PG repo? , type: `bool`, level: C, default value: `false`.

Use this option to download and install PostgreSQL-related pkgs directly from official Internet repos without local repos.




### `pg_add_repo`

Add PG-related upstream repos? , type: `bool`, level: C, default value: `false`

If used, the official PGDG repo will be added before installing PostgreSQL.




### `pg_bin_dir`

PG binary dir, type: `path`, level: C, default value: `"/usr/pgsql/bin"`.

The default value is a softlink created manually during the installation process, pointing to the specific Postgres version dir installed.

For example `/usr/pgsql -> /usr/pgsql-14`. For more details, please see  [FHS](/en/docs/pgsql/concept/fhs).




### `pg_log_dir`

PG log directory, type: `path`, level: C, default value: `"/pg/data/log"`.

The default value is a `log` dir under [`pg_data`](#pg_data).

!> caveat: if `pg_log_dir` is prefixed with `pg_data` it will not be created explicit.  




### `pg_packages`

List of installed PG pkgs, type: `string[]`, level: C, default value: `[]`:

`${pg_version}` in the package will be replaced with the actual installed PostgreSQL version [`pg_version`](#pg_version).

When you explicitly set a [`pg_version`](#pg_version) for a cluster, you can change this parameter alone with [`pg_extensions`](#pg_extensions)
In case of there's any missing pkgs on specific PG version or EL releases.


<details><summary>RHEL7 pg packages</summary>

```yaml
- postgresql${pg_version}* citus111_${pg_version} timescaledb-2-postgresql-${pg_version} postgis33_${pg_version}* # 33 on el8+
- pgbouncer pg_exporter pgbadger consul haproxy vip-manager patroni patroni-consul patroni-etcd # pg_activity
```

</details>


<details><summary>RHEL8 pg packages</summary>

```yaml
- postgresql${pg_version}* citus111_${pg_version} timescaledb-2-postgresql-${pg_version} postgis33_${pg_version}*
- pgbouncer pg_exporter pgbadger consul haproxy vip-manager patroni patroni-consul patroni-etcd #pg_activity
```

</details>


<details><summary>RHEL9 pg packages</summary>

```yaml
- postgresql${pg_version}* postgis33_${pg_version}* citus_${pg_version}-11* timescaledb_${pg_version} #citus111_${pg_version} timescaledb-2-postgresql-${pg_version}
- pgbouncer pg_exporter pgbadger consul haproxy vip-manager patroni patroni-consul patroni-etcd #pg_activity
```

</details>


<details><summary>RHEL8,9 with PG15</summary>

```yaml
- postgresql${pg_version}* citus111_${pg_version} postgis33_${pg_version}* wal2json_${pg_version}
- pgbouncer pg_exporter pgbadger consul haproxy vip-manager patroni patroni-consul patroni-etcd
```

</details>






### `pg_extensions`

PG plugin list, type: `string[]`, level: C, default value:

```yaml
- pg_repack_${pg_version} pg_qualstats_${pg_version} pg_stat_kcache_${pg_version} pg_stat_monitor_${pg_version} wal2json_${pg_version}  
```

`${pg_version}` will be replaced with the major PG version number [`pg_version`](#pg_version).

```yaml
pg_repack_${pg_version} pg_qualstats_${pg_version} pg_stat_kcache_${pg_version} pg_stat_monitor_${pg_version} wal2json_${pg_version}
```






----------------

## `PG_BOOTSTRAP`

On a machine with Postgres, create a set of databases.

* **Cluster identity definition**, clean up existing ins, make dir, copy tools and scripts, configure environment variables.
* Render Patroni config templates, and pull up primary and replica using Patroni.
* Configure Pgbouncer, initialize the business users and database, and register the database and data source services to DCS.

With [`pg_conf`](#pg_conf) you can use the default cluster templates (OLTP / OLAP / CRIT / TINY). If you create a custom template, you can clone the default config in `roles/postgres/templates` and adapt it after modifying. Please refer to [customize pgsql cluster](/en/docs/pgsql/customize) for details.






### `pg_safeguard`

Assure that any running pg instance will not be purged by any [`pgsql`](/en/docs/pgsql/playbook) playbook., level: C/A, default: `false`

Check [SafeGuard](/en/docs/pgsql/playbook#SafeGuard) for details.



### `pg_clean`

Remove existing pg during node init? level: C/A, default: `false`

This allows the removal of any running pg instance during [`pgsql.yml`](#/en/docs/pgsql/playbook), which makes it a true idempotent playbook.

It's a dangerous option so you'd better disable it by default and use it with `-e` CLI args.

> This parameter not working when [`pg_safeguard`](#pg_safeguard) is set to `true`




### `pg_data`

PG data dir, type: `path`, level: C, default value: `"/pg/data"`, not recommended to change.





### `pg_fs_main`

PG main data disk mountpoint, type: `path`, level: C, default value: `"/data"`.

Pigsty's default [dir structure](/en/docs/pgsql/concept/fhs) assumes that there is a main data disk mountpoint on the system that holds the DB dir along with another state.



### `pg_fs_bkup`

PG backup disk mountpoint, type: `path`, level: C, default value: `"/data/backups"`.

Pigsty's default [dir structure](/en/docs/pgsql/concept/fhs) assumes that there is a backup data disk mountpoint on the system that holds backup and archive data. However, users can also specify a sub-dir on the primary data disk as the backup disk home mountpoint.



### `pg_storage_type`

Storage type of `pg_fs_main`, can be SSD or HDD, type: `enum`, level: C, default value: `"SSD"`.

This parameter is used for cost estimation. 




### `pg_dummy_filesize`

Size of the file `/pg/dummy`, type: `size`, level: C, default value: `"64MiB"`.

A placeholder file is a pre-allocated empty file that takes up disk space. When the disk is full, removing the placeholder file can free up some space, it is recommended to use `4GiB`, `and 8GiB` for production env.





### `pg_listen`

PG listen IP address, type: `ip`, level: C, default value: `"0.0.0.0"`.

PG listen to IP address, default all IPv4 `0.0.0.0`, if you want to include all IPv6, you can use `*`.




### `pg_port`

PG listen to Port, type: `int`, level: C, default value: `5432`, not recommended to change.




### `pg_localhost`

PG's UnixSocket dir, type: `ip|path`, level: C, default value: `"/var/run/postgresql"`.

The Unix socket dir holds the Unix socket files for PostgreSQL and Pgbouncer, which are accessed through the local Unix socket when the client does not specify an IP to access the database.




### `patroni_enabled`

Enabled Patroni, type: `bool`, level: C, default value: `true`.

If disabled, Pigsty will skip pulling up patroni. This option is used when setting up extra staff for an existing ins.




### `patroni_mode`

Patroni work mode, type: `enum`, level: C, default value: `"default"`.

* `default`: Enable Patroni to enter HA auto-switching mode.
* `pause`: Enable Patroni to automatically enter maintenance mode after completing initialization (no automatic M-S S switching).
* `remove`: Initialize the cluster with Patroni and remove Patroni after initialization.




### `pg_dcs_type`

Which type of DCS to be used, type: `enum`, hierarchy: G, default value: `"consul"`.

There are two available options: `consul` and `etcd`.

[`consul_enabled`](#consul_enabled) or [`etcd_enabled`](#etcd_enabled) should be true if default internal DCS are used.




### `pg_namespace`

DCS namespace used by Patroni, type: `path`, level: C, default value: `"/pg"`.





### `patroni_port`

Patroni listens to port, type: `int`, level: C, default value: `8008`.

The Patroni API server listens to the port for service and health checks to the public by default.




### `patroni_log_dir`

Patroni log directory, type: `path`, level: C, default value: `/pg/log`.

The default patroni log lies in `/pg/log/patroni.log`




### `patroni_ssl_enabled`

secure patroni RestAPI communications with SSL? type: `bool`, level: C, default value: `false`.

It's not recommended to enable this option, since haproxy health check & prometheus metrics scrape would fail.

You can secure patroni RestAPI with [`patroni_username`](#patroni_username) and [`patroni_password`](#patroni_password),
Basic authentication restricted from meta nodes is sufficent for most cases.




### `patroni_watchdog_mode`

Patroni Watchdog mode, type: `enum`, level: C, default value: `"automatic"`.

When an M-S switchover occurs, Patroni will try to shut down the primary before elevating the replica. If the primary is still not shut down within the specified time, Patroni will use the Linux kernel module `softdog` to fence shutdown according to the config.

* `off`: No using `watchdog`.
* `automatic`: Enable `watchdog` if the kernel has `softdog` enabled, not forced, default behavior.
* `required`: Force `watchdog`, or refuse to start if `softdog` is not enabled on the system.

Enabling Watchdog means that the system prioritizes ensuring data consistency and drops availability. If availability is more important to your system, it is recommended to turn off Watchdog on the meta node.




### `patroni_username`

patroni rest api username. type: `string`, level: C, default value: `"postgres"`.

Patroni RestAPI require http basic authentication by default, you can set a username and password to secure it.

Check patroni RestAPI docs for detail: https://patroni.readthedocs.io/en/latest/rest_api.html




### `patroni_password`

patroni rest api password. type: `string`, level: C, default value: `"Patroni.API"`.

use in pair with [`patroni_username`](#patroni_username).

```bash
# restart patroni from meta node with basic auth
curl -i -u "postgres:Patroni.API" -X POST http://10.10.10.10:8008/restart
```




### `pg_conf`

Patroni's template, type: `string`, level: C, default value: `"tiny.yml"`

The [Patroni template](/en/docs/pgsql/customize) was used to pull up the Postgres cluster. Pigsty has 4 pre-built templates:

* [`oltp.yml`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/oltp.yml) Regular OLTP template, default config.
* [`olap.yml`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/olap.yml) OLAP templates to improve parallelism, optimize for throughput, and optimize for long-running queries.
* [`crit.yml`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/crit.yml) Critical business templates, based on OLTP templates optimized for security, data integrity, using synchronous replication, forced to enable data checksum.
* [`tiny.yml`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/tiny.yml) Micro templates optimized for low-resource scenarios have demo clusters running in VMs.

Templates are rendered to `/pg/conf` dir and create softlinks:

```bash
/etc/patroni/patroni.yml                     # used by patroni systemd service
     ^---> /pg/bin/patroni/patroni.yml           # rename as patroni.yml
              ^---> /pg/conf/pg-meta-1.yml       # conf with instance name
                      ^---> /pg/conf/{oltp,olap,crit,tiny}.yml # available choice
```




### `pg_rto`

recovery time objective in seconds, type: `integer`, level: C, default value: `30`.

This parameter is set to patroni's failover ttl, which is the maximum time allowed for the primary to be down before the replica is promoted to primary.



### `pg_rpo`

recovery point objective in bytes, type: `integer`, level: C, default value: `1048576`.

This parameter is set to max allowed lags between primary and replica,
which is the maximum data loss that is acceptable during a failover. 1MB by default.

if `crit.yml` template is used in [`pg_conf`](#pg_conf), this parameter will be set to 0, which means no data loss is allowed during failover. 




### `pg_libs`

Shared database loaded by PG, type: `string`, level: C, default value: `"timescaledb, pg_stat_statements, auto_explain"`.

Fill in the string of the `shared_preload_libraries` parameter in the Patroni template to control the dynamic database that PG starts preloading. In the current version, the following databases are loaded by default: `timescaledb, pg_stat_statements, auand to_explain`.

If Citus support is enabled by default, you need to modify this parameter by adding `citus` to the first position: `citus, timescaledb, pg_stat_statements, auto_explain`.




### `pg_delay`

Apply delay for delayed standby cluster, type: `interval`, level: I, default: `0`

Specify a recovery min apply delay for [Delayed Replica](/en/docs/pgsql/deploy#延迟从库), can only be set on standby cluster initialization.




### `pg_checksum`

Enable data checksums? , type: `bool`, class: C , default: `"false"`

Data checksum is enforced when using `crit` template.




### `pg_pwd_enc`

algorithm for encrypting passwords, type: `enum`, class: C , default: `"md5"`

available values: `md5` (default) and `scram-sha-256` (Postgres 10+ only).

Use `md5` for best compatibility, `scram-sha-256` for better security.




### `pg_sslmode`

SSL mode for postgres client, type: `enum`, class: C , default: `"disable"`

available values: `disable`, `allow`, `prefer`, `require`, `verify-ca`, `verify-full`




### `pg_encoding`

PG character set encoding, type: `enum`, level: C, default value: `"UTF8"`. It is not recommended to modify this parameter if there is no special need.




### `pg_locale`

The locale for PG, type: `enum`, level: C, default value: `"C"`.

It is not recommended to modify this parameter if there is no special need, improper sorting rules may have a significant impact on database performance.




### `pg_lc_collate`

Collate rule of locale, type: `enum`, level: C, default value: `"C"`.

Users can implement the localization sorting function by `COLLATE` expression, wrong localization sorting rule may cause exponential performance loss for some operations, please modify this parameter when you ensure there is a localization requirement.




### `pg_lc_ctype`

C-type of locale, type: `enum`, level: C, default value: `"en_US.UTF8"`

Some PG extensions (`pg_trgm`) require extra character classification definitions to work properly for internationalized characters, so Pigsty will use the `en_US.UTF8` character set definition by default, and it is not recommended to modify this parameter.




### `pgbouncer_enabled`

Enable Pgbouncer, type: `bool`, level: C, default value: `true`.




### `pgbouncer_port`

Pgbouncer listen port, type: `int`, level: C, default value: `6432`.




### `pgbouncer_log_dir`

Pgbouncer log directory, type: `path`, level: C, default value: `/var/log/pgbouncer`.




### `pgbouncer_auth_query`

use pg_authid query instead of static userlist , type: `bool`, level: C, default value: `false`.




### `pgbouncer_poolmode`

Pgbouncer pooling mode, type: `int`, level: C, default value: `6432`.

* `transaction`, Transaction-level connection pooling, by default, has good performance but affects the use of PreparedStatements with some other session-level features.
* `session`, Session-level connection pooling for maximum compatibility.
* `statements`, Statement-level join pooling, consider using this pattern if the queries are all point-and-click.



### `pgbouncer_max_db_conn`

Max connection per database, type: `int`, level: C, default value: `100`.

When using Transaction Pooling mode, the number of active server connections is usually in single digits. If Session Pooling mode is used, this parameter can be increased appropriately.






----------------

## `PG_PROVISION`

[`PG_BOOTSTRAP`](#pg_bootstrap) is responsible for creating a completely new set of Postgres clusters,
while [`PG_PROVISION`](#pg_provision) is responsible for creating the default objects in this new set of database clusters, including:

* Basic roles: read-only role, read-write role, admin role
* Basic users: replica user, dbsu, monitor user, the admin user
* Default privileges in the template database
* Default mode
* Default Extensions
* HBA black and white list rules

Pigsty provides rich customization options, if you want to further customize the PG cluster, you can see [Customize: PGSQL Cluster](/en/docs/pgsql/customize).



### `pg_provision`

Provision template to pgsql (app template), type: `bool`, level: C, default: `true.`

Provision of the PostgreSQL cluster. Setting to false will skip the tasks defined by [`pg_provision`](#pg_provision). Note, however, that the creation of the four default dbsu, replication user, admin user, and monitor user is not affected by this.

### `pg_init`

Custom PG init script, type: `string`, level: C, default value: `"pg-init"`.

The path to pg-inits Shell script, which defaults to `pg-init`, is copied to `/pg/bin/pg-init` and then executed.

The default `pg-init` is just a wrapper for the SQL command:

* `/pg/tmp/pg-init-roles.sql`: Default role creation script generated from [`pg_default_roles`](#pg_default_roles).
* `/pg/tmp/pg-init-template.sql`: SQL commands produced according to [`pg_default_privileges`](#pg_default_privileges), [`pg_default_schemas`](#pg_default_schemas), [`pg_default_extensions`](#pg_default_extensions). Will be applied to both the default database template `template1` and the default admin `postgres`.

```bash
# system default roles
psql postgres -qAXwtf /pg/tmp/pg-init-roles.sql

# system default template
psql template1 -qAXwtf /pg/tmp/pg-init-template.sql

# make postgres same as templated database (optional)
psql postgres  -qAXwtf /pg/tmp/pg-init-template.sql
```

Users can add their cluster init logic in a custom `pg-init` script.





### `pg_default_roles`

List or global default roles/users, type: `role[]`, level: G/C, default value:

```yaml
- { name: dbrole_readonly  , login: false , comment: role for global read-only access  }                                 # production read-only role
- { name: dbrole_readwrite , login: false , roles: [dbrole_readonly], comment: role for global read-write access }       # production read-write role
- { name: dbrole_offline   , login: false , comment: role for restricted read-only access (offline instance) }           # restricted-read-only role
- { name: dbrole_admin     , login: false , roles: [pg_monitor, dbrole_readwrite] , comment: role for object creation }  # production DDL change role

- { name: dbuser_monitor   , roles: [pg_monitor, dbrole_readonly] , comment: system monitor user , parameters: {log_min_duration_statement: 1000 } }
- { name: postgres     , superuser: true  , comment: system superuser }                             # system dbsu, name is designated by `pg_dbsu`
- { name: dbuser_dba   , superuser: true  , roles: [dbrole_admin] , comment: system admin user }    # admin dbsu, name is designated by `pg_admin_username`
- { name: replicator , replication: true  , bypassrls: true , roles: [pg_monitor, dbrole_readonly] , comment: system replicator }  # replicator
- { name: dbuser_stats  , password: DBUser.Stats , roles: [dbrole_offline] , comment: business offline user for offline queries and ETL } # ETL user
```





### `pg_default_privileges`

List of default privilegs, type: `string[]`, level: G/C, default value:

```yaml
pg_default_privileges:
  - GRANT USAGE                         ON SCHEMAS   TO dbrole_readonly
  - GRANT SELECT                        ON TABLES    TO dbrole_readonly
  - GRANT SELECT                        ON SEQUENCES TO dbrole_readonly
  - GRANT EXECUTE                       ON FUNCTIONS TO dbrole_readonly
  - GRANT USAGE                         ON SCHEMAS   TO dbrole_offline
  - GRANT SELECT                        ON TABLES    TO dbrole_offline
  - GRANT SELECT                        ON SEQUENCES TO dbrole_offline
  - GRANT EXECUTE                       ON FUNCTIONS TO dbrole_offline
  - GRANT INSERT, UPDATE, DELETE        ON TABLES    TO dbrole_readwrite
  - GRANT USAGE,  UPDATE                ON SEQUENCES TO dbrole_readwrite
  - GRANT TRUNCATE, REFERENCES, TRIGGER ON TABLES    TO dbrole_admin
  - GRANT CREATE                        ON SCHEMAS   TO dbrole_admin
```

Please refer to [default privilege](/en/docs/pgsql/concept/privilege#privilege) for details.




### `pg_default_schemas`

List of default schemas, type: `string[]`, hierarchy: G/C, default value: `[monitor]`.

Pigsty creates a schema named `monitor` for installing monitoring extensions by default.




### `pg_default_extensions`

List of defalut extensions, array of objects, type `extension[]`, hierarchy: G/C, default value:

```yaml
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
```

If the extension does not specify a `schema` field, the extension will install to the corresponding schema based on the current `search_path`, e.g., `public`.




### `pg_reload`

Reload Database Config (HBA), type: `bool`, level: A, default value: `true`.

When set to `true`, Pigsty will execute the `pg_ctl reload` application immediately after generating HBA rules.

When generating the `pg_hba.conf` file and manually comparing it before applying it to take effect, you can specify `-e pg_reload=false` to disable it.



### `pg_hba_rules`

PostgreSQL global HBA rule, type: `rule[]`, hierarchy: G/C, default value:

```yaml
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
```

This parameter is formally identical to [`pg_hba_rules_extra`](#pg_hba_rules_extra), and it is recommended to configure a uniform [`pg_hba_rules`](#pg_hba_rules) globally and use [`pg_hba_rules_extra`](#pg_hba_rules_extra) for extra customization. The rules in both parameters are applied sequentially, with the latter taking higher priority.

Beware, if you are using `scram-sha-256` on [`pg_pwd_enc`](#pg_pwd_enc), please replace `md5` with `scram-sha-256` in the above rules.







### `pgbouncer_hba_rules`

PgbouncerL global HBA rule, type: `rule[]`, level: G/C, default value:

```yaml
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
```

The default Pgbouncer HBA rules are simple:

1. Allow login from **local** with password
2. Allow password login from the intranet network break

Users can customize it.






----------------

## `PG_EXPORTER`

PG Exporter for monitoring Postgres with Pgbouncer connection pools.



### `pg_exporter_config`

PG-exporter config file, type: `string`, level: C, default value: `"pg_exporter.yml"`.

The default config file used by `pg_exporter` defines the database and connection pool monitor metrics in Pigsty. The default is [`pg_exporter.yml`](https://github.com/Vonng/pigsty/blob/master/roles/pg_exporter/files/pg_exporter.yml).

The PG-exporter config file used by Pigsty is supported by default from PostgreSQL 10.0 and is currently supported up to the latest PG 14 release. There are several of optional templates.

* [`pg_exporter_basic.yml`](https://github.com/Vonng/pigsty/blob/master/roles/pg_exporter/files/pg_exporter_basic.yml): contains only basic metrics, not Object monitor metrics within the database.
* [`pg_exporter_fast.yml`](https://github.com/Vonng/pigsty/blob/master/roles/pg_exporter/files/pg_exporter_fast.yml): metrics with shorter cache time definitions.




### `pg_exporter_enabled`

Enable PG-exporter, type: `bool`, level: C, default value: `true`.

Whether to install and configure `pg_exporter`, when `false`, the config of `pg_exporter` on the current node will be skipped, and this Exporter will be skipped when registering monitoring targets.



### `pg_exporter_port`

PG-exposure listen to Port, type: `int`, level: C, default value: `9630`.




### `pg_exporter_params`

Extra params for PG-exporter URL , type: `string`, level: C/I, default value: `"sslmode=disable"`.




### `pg_exporter_url`

Monitor target pgurl(override), type: `string`, level: C/I, default value: `""`.

The PG URL used by PG-exporter to connect to the database should be the URL to access the `postgres` managed database, which is configured as an environment variable in `/etc/default/pg_exporter`.

Optional param, defaults to the empty string, if the [`pg_exporter_url`](#pg_exporter_url) option is configured, the URL will be used directly as the monitor target pgurl. Otherwise, Pigsty will generate the target URL for monitoring using the following rule:

* [`pg_monitor_username`](#pg_monitor_username): Monitor User Name
* [`pg_monitor_password`](#pg_monitor_password): Monitor User password
* [`pg_localhost`](#pg_localhost): PG listen to Local IP or Unix Socket Dir
* [`pg_port`](#pg_port): PG Listen Port
* [`pg_exorter_params`](#pg_exporter_params): Extra Params for PG-exporter

The above params will be stitched together in the following manner:

```bash
postgres://{{ pg_monitor_username }}:{{ pg_monitor_password }}@:{{ pg_port }}/postgres{% if pg_exporter_params != '' %}?{{ pg_exporter_params }}{% if pg_localhost != '' %}&host={{ pg_localhost }}{% endif %}{% endif %}
```

If the [`pg_exporter_url`](#pg_exporter_url) param is specified, Exporter will use that connection string directly.

Note: When only a specific business database needs to be monitored, you can use the PGURL of that database directly. if you need to monitor **all** business databases on a particular database ins, it is recommended to use the PGURL of the meta database `postgres`.




### `pg_exporter_auto_discovery`

Auto-database-discovery, type: `bool`, level: C/I, default value: `true`.

Enable auto-database-discovery, enabled by default. When enabled, PG Exporter automatically detects changes to the list of databases and creates a crawl connection for each database.

When off, monitoring of objects in the library is not available.

> Note that if you have many databases (100+) or a very large number of objects in the database (several k, a dozen), please carefully evaluate the overhead incurred by object monitoring.




### `pg_exporter_exclude_database`

DB auto-discovery exclusion list, type: `string`, level: C/I, default value: `"template0,template1,postgres"`.

Database name list, when auto-database-discovery is enabled, databases in this list **will not be monitored** (excluded from monitor objects).



### `pg_exporter_include_database`

Auto-database-discovery capsule list, type: `string`, level: C/I, default value: `""`.

Database name list, when auto-database-discovery is enabled, databases that are not in this column table will not be monitored.




### `pg_exporter_options`

Cli args for PG-exporter , type: `string`, level: C/I, default value:`"--log.level=info --log.format=\"logger:syslog?appname=pg_exporter&local=7\""`.




### `pgbouncer_exporter_enabled`

Pgbouncer-exporter enabled, type: `bool`, level: C, default value: `true`.




### `pgbouncer_exporter_port`

PGB-exporter listens to Port, type: `int`, level: C, default value: `9631`.





### `pgbouncer_exporter_url`

Monitor target pgurl, type: `string`, level: C/I, default value: `""`.

The DB's URL used by PGBouncer Exporter to connect, should be the URL to access the `pgbouncer` managed database. An optional parameter, default is the empty string.

Pigsty generates the target URL for monitoring by default using the following rules, if the `pgbouncer_exporter_url` option is configured, this URL will be used directly as the connection string.

```bash
PG_EXPORTER_URL='postgres://{{ pg_monitor_username }}:{{ pg_monitor_password }}@:{{ pgbouncer_port }}/pgbouncer?host={{ pg_localhost }}&sslmode=disable'
```

This option is configured as an environment variable in `/etc/default/pgbouncer_exporter`.





### `pgbouncer_exporter_options`

Cli args for PGB Exporter, type: `string`, level: C/I, default value: `"--log.level=info --log.format=\"logger:syslog?appname=pgbouncer_exporter&local=7\"`.

The INFO level log is about to be typed into syslog.





----------------
## `PG_SERVICE`

Listen to PostgreSQL service, install the load balancer HAProxy, enable VIP, and configure DNS.

### `pg_services`

Global generic PG service definition, type: `[]service`, level: G, default value:

```yaml
- name: primary                 # service name {{ pg_cluster }}-primary
  src_ip: "*"
  src_port: 5433
  dst_port: pgbouncer           # 5433 route to pgbouncer
  check_url: /primary           # primary health check, success when instance is primary
  selector: "[]"                # select all instance as primary service candidate

- name: replica                 # service name {{ pg_cluster }}-replica
  src_ip: "*"
  src_port: 5434
  dst_port: pgbouncer
  check_url: /read-only         # read-only health check. (including primary)
  selector: "[]"                # select all instance as replica service candidate
  selector_backup: "[? pg_role == `primary` || pg_role == `offline` ]"

- name: default                 # service's actual name is {{ pg_cluster }}-default
  src_ip: "*"                   # service bind ip address, * for all, vip for cluster virtual ip address
  src_port: 5436                # bind port, mandatory
  dst_port: postgres            # target port: postgres|pgbouncer|port_number , pgbouncer(6432) by default
  check_method: http            # health check method: only http is available for now
  check_port: patroni           # health check port:  patroni|pg_exporter|port_number , patroni by default
  check_url: /primary           # health check url path, / as default
  check_code: 200               # health check http code, 200 as default
  selector: "[]"                # instance selector
  haproxy:                      # haproxy specific fields
    maxconn: 3000               # default front-end connection
    balance: roundrobin         # load balance algorithm (roundrobin by default)
    default_server_options: 'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'

- name: offline                 # service name {{ pg_cluster }}-offline
  src_ip: "*"
  src_port: 5438
  dst_port: postgres
  check_url: /replica           # offline MUST be a replica
  selector: "[? pg_role == `offline` || pg_offline_query ]"         # instances with pg_role == 'offline' or instance marked with 'pg_offline_query == true'
  selector_backup: "[? pg_role == `replica` && !pg_offline_query]"  # replica are used as backup server in offline service
```

An array consisting of [service definition](#pg_service) objects that define the services listened to the public. The form is consistent with [`pg_service_extra`](#pg_services_extra).




### `haproxy_enabled`

Enable Haproxy, type: `bool`, tier: C/I, default value: `true`.

Pigsty deploys Haproxy on all database nodes by default, enabling Haproxy LB only on specific instance/nodes by overriding ins-level variables.




### `haproxy_reload`

Reload Haproxy config, type: `bool`, level: A, default value: `true`.

If turned off, Pigsty will not perform Reload operation after rendering the HAProxy config file, and users can check it by themselves.




### `haproxy_auth_enabled`

Enable auth for Haproxy, type: `bool`, level: G/C, default value: `false`.

Not enabled by default, we recommend enabling it in production envs or adding access control to Nginx or other access layers.




### `haproxy_admin_username`

HAproxy admin user name, type: `string`, level: G, default value: `"admin"`.





### `haproxy_admin_password`

HAproxy admin user password, type: `string`, level: G, default value: `"pigsty"`.





### `haproxy_exporter_port`

HAproxy-exporter listen port, type: `int`, tier: C, default value: `9101`.




### `haproxy_client_timeout`

HAproxy client timeout, type: `interval`, level: C, default value: `"24h"`.





### `haproxy_server_timeout`

HAproxy server timeout, type: `interval`, level: C, default value: `"24h"`.





### `vip_mode`

VIP mode: none, type: `enum`, level: C, default value: `"none"`.

* `none`: No VIP setting, default option.
* `l2`: Layer 2 VIP bound to the primary (requires all members to be in the same Layer 2 network broadcast domain).
* `l4`: Reserved value for traffic distribution via an external L4 load balancer. (not included in Pigsty's current implementation).

VIPs are used to ensure the HA of **reading and writing services** with **LBs**. When using L2 VIPs, Pigsty's VIPs are hosted by a `vip-manager` and will be bound to the **cluster primary**.

This means that it is always possible to access the cluster primary through a VIP, or the LB on the primary through a VIP (which may have performance pressure).

> Note that when using Layer 2 VIP, you must ensure that the VIP candidate ins are under the same Layer 2 network (VLAN, switch).




### `vip_reload`

Overloaded VIP config, type: `bool`, level: A, default value: `true`.





### `vip_address`

VIP address used by the cluster, type: `string`, level: C, default value.





### `vip_cidrmask`

Network CIDR mask length for VIP address, type: `int`, level: C, default value.





### `vip_interface`

Network CIDR mask length for VIP address, type: `int`, level: C, default value.





### `dns_mode`

DNS config mode (reserved parameter), type: `enum`, level: C, default value.




### `dns_selector`

DNS resolution object selector (reserved parameter), type: `string`, level: C, default value.