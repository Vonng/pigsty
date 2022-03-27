# Configuring Pigsty

Pigsty uses declarative [configuration] (c-config.md) to describe desired state.
And the idempotent provisioning playbooks are responsible for adjusting system into that state.

Pigsty config is consist of 185 [config entry](#config-entries), 
divided into 10 [groups](#config-groups) and 5 levels. 
Most of them does not need your attention. Only identity parameters are required for defining new database clusters.


## Config Sections

|       Category        |                     Section                     |      Description       | Count |
|-----------------------|-------------------------------------------------|------------------------|-------|
| [`INFRA`](v-infra.md) | [`CONNECT`](v-infra.md#CONNECT)                 | Connection parameters |     1|
| [`INFRA`](v-infra.md) | [`REPO`](v-infra.md#REPO)                       | Local yum repo |    10|
| [`INFRA`](v-infra.md) | [`CA`](v-infra.md#CA)                           | Certificate Infrastructure |     5|
| [`INFRA`](v-infra.md) | [`NGINX`](v-infra.md#NGINX)                     | Nginx Web Server |     5|
| [`INFRA`](v-infra.md) | [`NAMESERVER`](v-infra.md#NAMESERVER)           | DNS Nameserver |     1|
| [`INFRA`](v-infra.md) | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | Monitoring Timeseries Database |     7|
| [`INFRA`](v-infra.md) | [`EXPORTER`](v-infra.md#EXPORTER)               | Common Exporter Options |     3|
| [`INFRA`](v-infra.md) | [`GRAFANA`](v-infra.md#GRAFANA)                 | Grafana Visualization Platform |     9|
| [`INFRA`](v-infra.md) | [`LOKI`](v-infra.md#LOKI)                       | Loki Logging Collect Platform |     5|
| [`INFRA`](v-infra.md) | [`DCS`](v-infra.md#DCS)                         | Distributed Consensus Storage |     8|
| [`INFRA`](v-infra.md) | [`JUPYTER`](v-infra.md#JUPYTER)                 | JupyterLab Data Analysis Platform |     3|
| [`INFRA`](v-infra.md) | [`PGWEB`](v-infra.md#PGWEB)                     | PGWeb Client Tools |     2|
| [`NODES`](v-nodes.md) | [`NODE_IDENTITY`](v-nodes.md#NODE_IDENTITY)     | Node Identity Parameters |     5|
| [`NODES`](v-nodes.md) | [`NODE_DNS`](v-nodes.md#NODE_DNS)               | Node DNS & Resolver |     5|
| [`NODES`](v-nodes.md) | [`NODE_REPO`](v-nodes.md#NODE_REPO)             | Node Software Repo |     3|
| [`NODES`](v-nodes.md) | [`NODE_PACKAGES`](v-nodes.md#NODE_PACKAGES)     | Node Packages Installation |     4|
| [`NODES`](v-nodes.md) | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | Node Features |     6|
| [`NODES`](v-nodes.md) | [`NODE_MODULES`](v-nodes.md#NODE_MODULES)       | Node Kernel Modules |     1|
| [`NODES`](v-nodes.md) | [`NODE_TUNE`](v-nodes.md#NODE_TUNE)             | Node Optimization Template |     2|
| [`NODES`](v-nodes.md) | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | Node Admin User Setup |     6|
| [`NODES`](v-nodes.md) | [`NODE_TIME`](v-nodes.md#NODE_TIME)             | Node Timezone & NTP |     4|
| [`NODES`](v-nodes.md) | [`NODE_EXPORTER`](v-nodes.md#NODE_EXPORTER)     | Node Metrics Exporter |     3|
| [`NODES`](v-nodes.md) | [`PROMTAIL`](v-nodes.md#PROMTAIL)               | Node Logging Collector |     5|
| [`PGSQL`](v-pgsql.md) | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | PGSQL Identity Parameters |    13|
| [`PGSQL`](v-pgsql.md) | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | PGSQL Business Parameters |    11|
| [`PGSQL`](v-pgsql.md) | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | Postgres Installation |    11|
| [`PGSQL`](v-pgsql.md) | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | Patroni & Postgres Bootstrap |    24|
| [`PGSQL`](v-pgsql.md) | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | Postgres Template Provision |     9|
| [`PGSQL`](v-pgsql.md) | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | Postgres & Pgbouncer Metrics Exporter |    13|
| [`PGSQL`](v-pgsql.md) | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | Service & Access: HAProxy & VIP |    16|
| [`REDIS`](v-redis.md) | [`REDIS_IDENTITY`](v-redis.md#REDIS_IDENTITY)   | REDIS Identity Parameters |     3|
| [`REDIS`](v-redis.md) | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | REDIS Cluster Provision |    14|
| [`REDIS`](v-redis.md) | [`REDIS_EXPORTER`](v-redis.md#REDIS_EXPORTER)   | REDIS Metrics Exporter |     3|



## Config Entries


| ID  |                                   Name                                    |                     Section                     | Level |                                      Description                                       |
|-----|---------------------------------------------------------------------------|-------------------------------------------------|-------|-----------------------------------------------------------------------------------------|
| 100 | [`proxy_env`](v-infra.md#proxy_env)                                       | [`CONNECT`](v-infra.md#CONNECT)                 | G     | proxy environment variables|
| 110 | [`repo_enabled`](v-infra.md#repo_enabled)                                 | [`REPO`](v-infra.md#REPO)                       | G     | enable local yum repo|
| 111 | [`repo_name`](v-infra.md#repo_name)                                       | [`REPO`](v-infra.md#REPO)                       | G     | local yum repo name|
| 112 | [`repo_address`](v-infra.md#repo_address)                                 | [`REPO`](v-infra.md#REPO)                       | G     | external access endpoint of repo|
| 113 | [`repo_port`](v-infra.md#repo_port)                                       | [`REPO`](v-infra.md#REPO)                       | G     | repo listen address (80)|
| 114 | [`repo_home`](v-infra.md#repo_home)                                       | [`REPO`](v-infra.md#REPO)                       | G     | repo home dir (/www)|
| 115 | [`repo_rebuild`](v-infra.md#repo_rebuild)                                 | [`REPO`](v-infra.md#REPO)                       | A     | rebuild local yum repo?|
| 116 | [`repo_remove`](v-infra.md#repo_remove)                                   | [`REPO`](v-infra.md#REPO)                       | A     | remove existing repo file?|
| 117 | [`repo_upstreams`](v-infra.md#repo_upstreams)                             | [`REPO`](v-infra.md#REPO)                       | G     | upstream repo definition|
| 118 | [`repo_packages`](v-infra.md#repo_packages)                               | [`REPO`](v-infra.md#REPO)                       | G     | packages to be downloaded|
| 119 | [`repo_url_packages`](v-infra.md#repo_url_packages)                       | [`REPO`](v-infra.md#REPO)                       | G     | pkgs to be downloaded via url|
| 120 | [`ca_method`](v-infra.md#ca_method)                                       | [`CA`](v-infra.md#CA)                           | G     | ca mode, create,copy,recreate|
| 121 | [`ca_subject`](v-infra.md#ca_subject)                                     | [`CA`](v-infra.md#CA)                           | G     | ca subject|
| 122 | [`ca_homedir`](v-infra.md#ca_homedir)                                     | [`CA`](v-infra.md#CA)                           | G     | ca cert home dir|
| 123 | [`ca_cert`](v-infra.md#ca_cert)                                           | [`CA`](v-infra.md#CA)                           | G     | ca cert file name|
| 124 | [`ca_key`](v-infra.md#ca_key)                                             | [`CA`](v-infra.md#CA)                           | G     | ca private key name|
| 130 | [`nginx_upstream`](v-infra.md#nginx_upstream)                             | [`NGINX`](v-infra.md#NGINX)                     | G     | nginx upstream definition|
| 131 | [`app_list`](v-infra.md#app_list)                                         | [`NGINX`](v-infra.md#NGINX)                     | G     | app list on home page navbar|
| 132 | [`docs_enabled`](v-infra.md#docs_enabled)                                 | [`NGINX`](v-infra.md#NGINX)                     | G     | enable local docs|
| 133 | [`pev2_enabled`](v-infra.md#pev2_enabled)                                 | [`NGINX`](v-infra.md#NGINX)                     | G     | enable pev2|
| 134 | [`pgbadger_enabled`](v-infra.md#pgbadger_enabled)                         | [`NGINX`](v-infra.md#NGINX)                     | G     | enable pgbadger|
| 140 | [`dns_records`](v-infra.md#dns_records)                                   | [`NAMESERVER`](v-infra.md#NAMESERVER)           | G     | dynamic DNS records|
| 150 | [`prometheus_data_dir`](v-infra.md#prometheus_data_dir)                   | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | G     | prometheus data dir|
| 151 | [`prometheus_options`](v-infra.md#prometheus_options)                     | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | G     | prometheus cli args|
| 152 | [`prometheus_reload`](v-infra.md#prometheus_reload)                       | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | A     | prom reload instead of init|
| 153 | [`prometheus_sd_method`](v-infra.md#prometheus_sd_method)                 | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | G     |consul          |
| 154 | [`prometheus_scrape_interval`](v-infra.md#prometheus_scrape_interval)     | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | G     | prom scrape interval (10s)|
| 155 | [`prometheus_scrape_timeout`](v-infra.md#prometheus_scrape_timeout)       | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | G     | prom scrape timeout (8s)|
| 156 | [`prometheus_sd_interval`](v-infra.md#prometheus_sd_interval)             | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | G     | prom discovery refresh interval|
| 160 | [`exporter_install`](v-infra.md#exporter_install)                         | [`EXPORTER`](v-infra.md#EXPORTER)               | G     | how to install exporter?|
| 161 | [`exporter_repo_url`](v-infra.md#exporter_repo_url)                       | [`EXPORTER`](v-infra.md#EXPORTER)               | G     | repo url for yum install|
| 162 | [`exporter_metrics_path`](v-infra.md#exporter_metrics_path)               | [`EXPORTER`](v-infra.md#EXPORTER)               | G     | URL path for exporting metrics|
| 170 | [`grafana_endpoint`](v-infra.md#grafana_endpoint)                         | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | grafana API endpoint|
| 171 | [`grafana_admin_username`](v-infra.md#grafana_admin_username)             | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | grafana admin username|
| 172 | [`grafana_admin_password`](v-infra.md#grafana_admin_password)             | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | grafana admin password|
| 173 | [`grafana_database`](v-infra.md#grafana_database)                         | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | grafana backend database type|
| 174 | [`grafana_pgurl`](v-infra.md#grafana_pgurl)                               | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | grafana backend postgres url|
| 175 | [`grafana_plugin`](v-infra.md#grafana_plugin)                             | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | how to install grafana plugins|
| 176 | [`grafana_cache`](v-infra.md#grafana_cache)                               | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | grafana plugins cache path|
| 177 | [`grafana_plugins`](v-infra.md#grafana_plugins)                           | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | grafana plugins to be installed|
| 178 | [`grafana_git_plugins`](v-infra.md#grafana_git_plugins)                   | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | grafana plugins via git|
| 180 | [`loki_endpoint`](v-infra.md#loki_endpoint)                               | [`LOKI`](v-infra.md#LOKI)                       | G     | loki endpoint to receive log|
| 181 | [`loki_clean`](v-infra.md#loki_clean)                                     | [`LOKI`](v-infra.md#LOKI)                       | A     | remove existing loki data?|
| 182 | [`loki_options`](v-infra.md#loki_options)                                 | [`LOKI`](v-infra.md#LOKI)                       | G     | loki cli args|
| 183 | [`loki_data_dir`](v-infra.md#loki_data_dir)                               | [`LOKI`](v-infra.md#LOKI)                       | G     | loki data path|
| 184 | [`loki_retention`](v-infra.md#loki_retention)                             | [`LOKI`](v-infra.md#LOKI)                       | G     | loki log keeping period|
| 200 | [`dcs_servers`](v-infra.md#dcs_servers)                                   | [`DCS`](v-infra.md#DCS)                         | G     | dcs server dict|
| 201 | [`service_registry`](v-infra.md#service_registry)                         | [`DCS`](v-infra.md#DCS)                         | G     | where to register service?|
| 202 | [`dcs_type`](v-infra.md#dcs_type)                                         | [`DCS`](v-infra.md#DCS)                         | G     | which dcs to use (consul/etcd)|
| 203 | [`dcs_name`](v-infra.md#dcs_name)                                         | [`DCS`](v-infra.md#DCS)                         | G     | dcs cluster name (dc)|
| 204 | [`dcs_exists_action`](v-infra.md#dcs_exists_action)                       | [`DCS`](v-infra.md#DCS)                         | C/A   | how to deal with existing dcs|
| 205 | [`dcs_disable_purge`](v-infra.md#dcs_disable_purge)                       | [`DCS`](v-infra.md#DCS)                         | C/A   | disable dcs purge|
| 206 | [`consul_data_dir`](v-infra.md#consul_data_dir)                           | [`DCS`](v-infra.md#DCS)                         | G     | consul data dir path|
| 207 | [`etcd_data_dir`](v-infra.md#etcd_data_dir)                               | [`DCS`](v-infra.md#DCS)                         | G     | etcd data dir path|
| 220 | [`jupyter_enabled`](v-infra.md#jupyter_enabled)                           | [`JUPYTER`](v-infra.md#JUPYTER)                 | G     | enable jupyter lab|
| 221 | [`jupyter_username`](v-infra.md#jupyter_username)                         | [`JUPYTER`](v-infra.md#JUPYTER)                 | G     | os user for jupyter lab|
| 222 | [`jupyter_password`](v-infra.md#jupyter_password)                         | [`JUPYTER`](v-infra.md#JUPYTER)                 | G     | password for jupyter lab|
| 230 | [`pgweb_enabled`](v-infra.md#pgweb_enabled)                               | [`PGWEB`](v-infra.md#PGWEB)                     | G     | enable pgweb|
| 231 | [`pgweb_username`](v-infra.md#pgweb_username)                             | [`PGWEB`](v-infra.md#PGWEB)                     | G     | os user for pgweb|
| 300 | [`meta_node`](v-nodes.md#meta_node)                                       | [`NODE_IDENTITY`](v-nodes.md#NODE_IDENTITY)     | C     | mark this node as meta|
| 301 | [`nodename`](v-nodes.md#nodename)                                         | [`NODE_IDENTITY`](v-nodes.md#NODE_IDENTITY)     | I     | node instance identity|
| 302 | [`node_cluster`](v-nodes.md#node_cluster)                                 | [`NODE_IDENTITY`](v-nodes.md#NODE_IDENTITY)     | C     | node cluster identity|
| 303 | [`nodename_overwrite`](v-nodes.md#nodename_overwrite)                     | [`NODE_IDENTITY`](v-nodes.md#NODE_IDENTITY)     | C     | overwrite hostname with nodename|
| 304 | [`nodename_exchange`](v-nodes.md#nodename_exchange)                       | [`NODE_IDENTITY`](v-nodes.md#NODE_IDENTITY)     | C     | exchange static hostname|
| 310 | [`node_dns_hosts`](v-nodes.md#node_dns_hosts)                             | [`NODE_DNS`](v-nodes.md#NODE_DNS)               | C     | static DNS records|
| 311 | [`node_dns_hosts_extra`](v-nodes.md#node_dns_hosts_extra)                 | [`NODE_DNS`](v-nodes.md#NODE_DNS)               | C/I   | extra static DNS records|
| 312 | [`node_dns_server`](v-nodes.md#node_dns_server)                           | [`NODE_DNS`](v-nodes.md#NODE_DNS)               | C     | how to setup dns service?|
| 313 | [`node_dns_servers`](v-nodes.md#node_dns_servers)                         | [`NODE_DNS`](v-nodes.md#NODE_DNS)               | C     | dynamic DNS servers|
| 314 | [`node_dns_options`](v-nodes.md#node_dns_options)                         | [`NODE_DNS`](v-nodes.md#NODE_DNS)               | C     | /etc/resolv.conf options|
| 320 | [`node_repo_method`](v-nodes.md#node_repo_method)                         | [`NODE_REPO`](v-nodes.md#NODE_REPO)             | C     | how to use yum repo (local)|
| 321 | [`node_repo_remove`](v-nodes.md#node_repo_remove)                         | [`NODE_REPO`](v-nodes.md#NODE_REPO)             | C     | remove existing repo file?|
| 322 | [`node_local_repo_url`](v-nodes.md#node_local_repo_url)                   | [`NODE_REPO`](v-nodes.md#NODE_REPO)             | C     | local yum repo url|
| 330 | [`node_packages`](v-nodes.md#node_packages)                               | [`NODE_PACKAGES`](v-nodes.md#NODE_PACKAGES)     | C     | pkgs to be installed on all node|
| 331 | [`node_extra_packages`](v-nodes.md#node_extra_packages)                   | [`NODE_PACKAGES`](v-nodes.md#NODE_PACKAGES)     | C     | extra pkgs to be installed|
| 332 | [`node_meta_packages`](v-nodes.md#node_meta_packages)                     | [`NODE_PACKAGES`](v-nodes.md#NODE_PACKAGES)     | G     | meta node only packages|
| 333 | [`node_meta_pip_install`](v-nodes.md#node_meta_pip_install)               | [`NODE_PACKAGES`](v-nodes.md#NODE_PACKAGES)     | G     | meta node pip3 packages|
| 340 | [`node_disable_numa`](v-nodes.md#node_disable_numa)                       | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | C     | disable numa?|
| 341 | [`node_disable_swap`](v-nodes.md#node_disable_swap)                       | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | C     | disable swap?|
| 342 | [`node_disable_firewall`](v-nodes.md#node_disable_firewall)               | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | C     | disable firewall?|
| 343 | [`node_disable_selinux`](v-nodes.md#node_disable_selinux)                 | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | C     | disable selinux?|
| 344 | [`node_static_network`](v-nodes.md#node_static_network)                   | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | C     | use static DNS config?|
| 345 | [`node_disk_prefetch`](v-nodes.md#node_disk_prefetch)                     | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | C     | enable disk prefetch?|
| 346 | [`node_kernel_modules`](v-nodes.md#node_kernel_modules)                   | [`NODE_MODULES`](v-nodes.md#NODE_MODULES)       | C     | kernel modules to be installed|
| 350 | [`node_tune`](v-nodes.md#node_tune)                                       | [`NODE_TUNE`](v-nodes.md#NODE_TUNE)             | C     | node tune mode|
| 351 | [`node_sysctl_params`](v-nodes.md#node_sysctl_params)                     | [`NODE_TUNE`](v-nodes.md#NODE_TUNE)             | C     | extra kernel parameters|
| 360 | [`node_admin_setup`](v-nodes.md#node_admin_setup)                         | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | G     | create admin user?|
| 361 | [`node_admin_uid`](v-nodes.md#node_admin_uid)                             | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | G     | admin user UID|
| 362 | [`node_admin_username`](v-nodes.md#node_admin_username)                   | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | G     | admin user name|
| 363 | [`node_admin_ssh_exchange`](v-nodes.md#node_admin_ssh_exchange)           | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | C     | exchange admin ssh keys?|
| 364 | [`node_admin_pk_current`](v-nodes.md#node_admin_pk_current)               | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | A     | pks to be added to admin|
| 365 | [`node_admin_pks`](v-nodes.md#node_admin_pks)                             | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | C     | add current user's pkey?|
| 370 | [`node_timezone`](v-nodes.md#node_timezone)                               | [`NODE_TIME`](v-nodes.md#NODE_TIME)             | C     | node timezone|
| 371 | [`node_ntp_config`](v-nodes.md#node_ntp_config)                           | [`NODE_TIME`](v-nodes.md#NODE_TIME)             | C     | setup ntp on node?|
| 372 | [`node_ntp_service`](v-nodes.md#node_ntp_service)                         | [`NODE_TIME`](v-nodes.md#NODE_TIME)             | C     | ntp mode: ntp or chrony?|
| 373 | [`node_ntp_servers`](v-nodes.md#node_ntp_servers)                         | [`NODE_TIME`](v-nodes.md#NODE_TIME)             | C     | ntp server list|
| 380 | [`node_exporter_enabled`](v-nodes.md#node_exporter_enabled)               | [`NODE_EXPORTER`](v-nodes.md#NODE_EXPORTER)     | C     | node_exporter enabled?|
| 381 | [`node_exporter_port`](v-nodes.md#node_exporter_port)                     | [`NODE_EXPORTER`](v-nodes.md#NODE_EXPORTER)     | C     | node_exporter listen port|
| 382 | [`node_exporter_options`](v-nodes.md#node_exporter_options)               | [`NODE_EXPORTER`](v-nodes.md#NODE_EXPORTER)     | C/I   | node_exporter extra cli args|
| 390 | [`promtail_enabled`](v-nodes.md#promtail_enabled)                         | [`PROMTAIL`](v-nodes.md#PROMTAIL)               | C     | promtail enabled ?|
| 391 | [`promtail_clean`](v-nodes.md#promtail_clean)                             | [`PROMTAIL`](v-nodes.md#PROMTAIL)               | C/A   | remove promtail status file ?|
| 392 | [`promtail_port`](v-nodes.md#promtail_port)                               | [`PROMTAIL`](v-nodes.md#PROMTAIL)               | G     | promtail listen port|
| 393 | [`promtail_options`](v-nodes.md#promtail_options)                         | [`PROMTAIL`](v-nodes.md#PROMTAIL)               | C/I   | promtail cli args|
| 394 | [`promtail_positions`](v-nodes.md#promtail_positions)                     | [`PROMTAIL`](v-nodes.md#PROMTAIL)               | C     | path to store promtail status file|
| 500 | [`pg_cluster`](v-pgsql.md#pg_cluster)                                     | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | C     | PG Cluster Name|
| 501 | [`pg_shard`](v-pgsql.md#pg_shard)                                         | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | C     | PG Shard Name (Reserve)|
| 502 | [`pg_sindex`](v-pgsql.md#pg_sindex)                                       | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | C     | PG Shard Index (Reserve)|
| 503 | [`gp_role`](v-pgsql.md#gp_role)                                           | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | C     | gp role of this pg cluster|
| 504 | [`pg_role`](v-pgsql.md#pg_role)                                           | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | PG Instance Role|
| 505 | [`pg_seq`](v-pgsql.md#pg_seq)                                             | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | PG Instance Sequence|
| 506 | [`pg_instances`](v-pgsql.md#pg_instances)                                 | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | pg instance on this node|
| 507 | [`pg_upstream`](v-pgsql.md#pg_upstream)                                   | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | pg upstream IP address|
| 508 | [`pg_offline_query`](v-pgsql.md#pg_offline_query)                         | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | allow offline query?|
| 509 | [`pg_backup`](v-pgsql.md#pg_backup)                                       | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | make base backup on this ins?|
| 510 | [`pg_weight`](v-pgsql.md#pg_weight)                                       | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | relative weight in load balancer|
| 511 | [`pg_hostname`](v-pgsql.md#pg_hostname)                                   | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | C/I   | set PG ins name as hostname|
| 512 | [`pg_preflight_skip`](v-pgsql.md#pg_preflight_skip)                       | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | C/A   | skip preflight param validation|
| 520 | [`pg_users`](v-pgsql.md#pg_users)                                         | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | C     | business users definition|
| 521 | [`pg_databases`](v-pgsql.md#pg_databases)                                 | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | C     | business databases definition|
| 522 | [`pg_services_extra`](v-pgsql.md#pg_services_extra)                       | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | C     | ad hoc service definition|
| 523 | [`pg_hba_rules_extra`](v-pgsql.md#pg_hba_rules_extra)                     | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | C     | ad hoc HBA rules|
| 524 | [`pgbouncer_hba_rules_extra`](v-pgsql.md#pgbouncer_hba_rules_extra)       | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | C     | ad hoc pgbouncer HBA rules|
| 525 | [`pg_admin_username`](v-pgsql.md#pg_admin_username)                       | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | G     | admin user's name|
| 526 | [`pg_admin_password`](v-pgsql.md#pg_admin_password)                       | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | G     | admin user's password|
| 527 | [`pg_replication_username`](v-pgsql.md#pg_replication_username)           | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | G     | replication user's name|
| 528 | [`pg_replication_password`](v-pgsql.md#pg_replication_password)           | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | G     | replication user's password|
| 529 | [`pg_monitor_username`](v-pgsql.md#pg_monitor_username)                   | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | G     | monitor user's name|
| 530 | [`pg_monitor_password`](v-pgsql.md#pg_monitor_password)                   | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | G     | monitor user's password|
| 540 | [`pg_dbsu`](v-pgsql.md#pg_dbsu)                                           | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | os dbsu for postgres|
| 541 | [`pg_dbsu_uid`](v-pgsql.md#pg_dbsu_uid)                                   | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | dbsu UID|
| 542 | [`pg_dbsu_sudo`](v-pgsql.md#pg_dbsu_sudo)                                 | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | sudo priv mode for dbsu|
| 543 | [`pg_dbsu_home`](v-pgsql.md#pg_dbsu_home)                                 | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | home dir for dbsu|
| 544 | [`pg_dbsu_ssh_exchange`](v-pgsql.md#pg_dbsu_ssh_exchange)                 | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | exchange dbsu ssh keys?|
| 545 | [`pg_version`](v-pgsql.md#pg_version)                                     | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | major PG version to be installed|
| 546 | [`pgdg_repo`](v-pgsql.md#pgdg_repo)                                       | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | add official PGDG repo?|
| 547 | [`pg_add_repo`](v-pgsql.md#pg_add_repo)                                   | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | add extra upstream PG repo?|
| 548 | [`pg_bin_dir`](v-pgsql.md#pg_bin_dir)                                     | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | PG binary dir|
| 549 | [`pg_packages`](v-pgsql.md#pg_packages)                                   | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | PG packages to be installed|
| 550 | [`pg_extensions`](v-pgsql.md#pg_extensions)                               | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | PG extension pkgs to be installed|
| 560 | [`pg_exists_action`](v-pgsql.md#pg_exists_action)                         | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C/A   | how to deal with existing pg ins|
| 561 | [`pg_disable_purge`](v-pgsql.md#pg_disable_purge)                         | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C/A   | disable pg instance purge|
| 562 | [`pg_data`](v-pgsql.md#pg_data)                                           | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | pg data dir|
| 563 | [`pg_fs_main`](v-pgsql.md#pg_fs_main)                                     | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | pg main data disk mountpoint|
| 564 | [`pg_fs_bkup`](v-pgsql.md#pg_fs_bkup)                                     | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | pg backup disk mountpoint|
| 565 | [`pg_dummy_filesize`](v-pgsql.md#pg_dummy_filesize)                       | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | /pg/dummy file size|
| 566 | [`pg_listen`](v-pgsql.md#pg_listen)                                       | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | pg listen IP address|
| 567 | [`pg_port`](v-pgsql.md#pg_port)                                           | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | pg listen port|
| 568 | [`pg_localhost`](v-pgsql.md#pg_localhost)                                 | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | pg unix socket path|
| 580 | [`patroni_enabled`](v-pgsql.md#patroni_enabled)                           | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Is patroni & postgres enabled?|
| 581 | [`patroni_mode`](v-pgsql.md#patroni_mode)                                 | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | patroni working mode|
| 582 | [`pg_namespace`](v-pgsql.md#pg_namespace)                                 | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | namespace for patroni|
| 583 | [`patroni_port`](v-pgsql.md#patroni_port)                                 | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | patroni listen port (8080)|
| 584 | [`patroni_watchdog_mode`](v-pgsql.md#patroni_watchdog_mode)               | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | patroni watchdog policy|
| 585 | [`pg_conf`](v-pgsql.md#pg_conf)                                           | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | patroni template|
| 586 | [`pg_shared_libraries`](v-pgsql.md#pg_shared_libraries)                   | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | default preload shared libraries|
| 587 | [`pg_encoding`](v-pgsql.md#pg_encoding)                                   | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | character encoding|
| 588 | [`pg_locale`](v-pgsql.md#pg_locale)                                       | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | locale|
| 589 | [`pg_lc_collate`](v-pgsql.md#pg_lc_collate)                               | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | collate rule of locale|
| 590 | [`pg_lc_ctype`](v-pgsql.md#pg_lc_ctype)                                   | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | ctype of locale|
| 591 | [`pgbouncer_enabled`](v-pgsql.md#pgbouncer_enabled)                       | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | is pgbouncer enabled|
| 592 | [`pgbouncer_port`](v-pgsql.md#pgbouncer_port)                             | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | pgbouncer listen port|
| 593 | [`pgbouncer_poolmode`](v-pgsql.md#pgbouncer_poolmode)                     | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | pgbouncer pooling mode|
| 594 | [`pgbouncer_max_db_conn`](v-pgsql.md#pgbouncer_max_db_conn)               | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | max connection per database|
| 600 | [`pg_provision`](v-pgsql.md#pg_provision)                                 | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | C     | provision template to pgsql?|
| 601 | [`pg_init`](v-pgsql.md#pg_init)                                           | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | C     | path to postgres init script|
| 602 | [`pg_default_roles`](v-pgsql.md#pg_default_roles)                         | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | G/C   | list or global default roles/users|
| 603 | [`pg_default_privilegs`](v-pgsql.md#pg_default_privilegs)                 | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | G/C   | list of default privileges|
| 604 | [`pg_default_schemas`](v-pgsql.md#pg_default_schemas)                     | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | G/C   | list of default schemas|
| 605 | [`pg_default_extensions`](v-pgsql.md#pg_default_extensions)               | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | G/C   | list of default extensions|
| 606 | [`pg_reload`](v-pgsql.md#pg_reload)                                       | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | A     | reload configuration?|
| 607 | [`pg_hba_rules`](v-pgsql.md#pg_hba_rules)                                 | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | G/C   | global HBA rules|
| 608 | [`pgbouncer_hba_rules`](v-pgsql.md#pgbouncer_hba_rules)                   | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | G/C   | global pgbouncer HBA rules|
| 620 | [`pg_exporter_config`](v-pgsql.md#pg_exporter_config)                     | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C     | pg_exporter config path|
| 621 | [`pg_exporter_enabled`](v-pgsql.md#pg_exporter_enabled)                   | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C     | pg_exporter enabled ?|
| 622 | [`pg_exporter_port`](v-pgsql.md#pg_exporter_port)                         | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C     | pg_exporter listen address|
| 623 | [`pg_exporter_params`](v-pgsql.md#pg_exporter_params)                     | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | extra params for pg_exporter url|
| 624 | [`pg_exporter_url`](v-pgsql.md#pg_exporter_url)                           | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | monitor target pgurl (overwrite)|
| 625 | [`pg_exporter_auto_discovery`](v-pgsql.md#pg_exporter_auto_discovery)     | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | enable auto-database-discovery?|
| 626 | [`pg_exporter_exclude_database`](v-pgsql.md#pg_exporter_exclude_database) | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | excluded list of databases|
| 627 | [`pg_exporter_include_database`](v-pgsql.md#pg_exporter_include_database) | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | included list of databases|
| 628 | [`pg_exporter_options`](v-pgsql.md#pg_exporter_options)                   | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | cli args for pg_exporter|
| 629 | [`pgbouncer_exporter_enabled`](v-pgsql.md#pgbouncer_exporter_enabled)     | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C     | pgbouncer_exporter enabled ?|
| 630 | [`pgbouncer_exporter_port`](v-pgsql.md#pgbouncer_exporter_port)           | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C     | pgbouncer_exporter listen addr?|
| 631 | [`pgbouncer_exporter_url`](v-pgsql.md#pgbouncer_exporter_url)             | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | target pgbouncer url (overwrite)|
| 632 | [`pgbouncer_exporter_options`](v-pgsql.md#pgbouncer_exporter_options)     | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | cli args for pgbouncer exporter|
| 640 | [`pg_services`](v-pgsql.md#pg_services)                                   | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | G/C   | global service definition|
| 641 | [`haproxy_enabled`](v-pgsql.md#haproxy_enabled)                           | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C/I   | haproxy enabled ?|
| 642 | [`haproxy_reload`](v-pgsql.md#haproxy_reload)                             | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | A     | haproxy reload instead of reset|
| 643 | [`haproxy_admin_auth_enabled`](v-pgsql.md#haproxy_admin_auth_enabled)     | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | G/C   | enable auth for haproxy admin ?|
| 644 | [`haproxy_admin_username`](v-pgsql.md#haproxy_admin_username)             | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | G     | haproxy admin user name|
| 645 | [`haproxy_admin_password`](v-pgsql.md#haproxy_admin_password)             | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | G     | haproxy admin password|
| 646 | [`haproxy_exporter_port`](v-pgsql.md#haproxy_exporter_port)               | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | haproxy exporter listen port|
| 647 | [`haproxy_client_timeout`](v-pgsql.md#haproxy_client_timeout)             | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | haproxy client timeout|
| 648 | [`haproxy_server_timeout`](v-pgsql.md#haproxy_server_timeout)             | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | haproxy server timeout|
| 649 | [`vip_mode`](v-pgsql.md#vip_mode)                                         | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | vip working mode|
| 650 | [`vip_reload`](v-pgsql.md#vip_reload)                                     | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | A     | reload vip configuration|
| 651 | [`vip_address`](v-pgsql.md#vip_address)                                   | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | vip address used by cluster|
| 652 | [`vip_cidrmask`](v-pgsql.md#vip_cidrmask)                                 | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | vip network CIDR length|
| 653 | [`vip_interface`](v-pgsql.md#vip_interface)                               | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | vip network interface name|
| 654 | [`dns_mode`](v-pgsql.md#dns_mode)                                         | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | cluster DNS mode|
| 655 | [`dns_selector`](v-pgsql.md#dns_selector)                                 | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | cluster DNS ins selector|
| 700 | [`redis_cluster`](v-redis.md#redis_cluster)                               | [`REDIS_IDENTITY`](v-redis.md#REDIS_IDENTITY)   | C     | redis cluster identity|
| 701 | [`redis_node`](v-redis.md#redis_node)                                     | [`REDIS_IDENTITY`](v-redis.md#REDIS_IDENTITY)   | I     | redis node identity|
| 702 | [`redis_instances`](v-redis.md#redis_instances)                           | [`REDIS_IDENTITY`](v-redis.md#REDIS_IDENTITY)   | I     | redis instances definition on this node|
| 720 | [`redis_install`](v-redis.md#redis_install)                               | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | Way of install redis binaries|
| 721 | [`redis_mode`](v-redis.md#redis_mode)                                     | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | standalone,cluster,sentinel|
| 722 | [`redis_conf`](v-redis.md#redis_conf)                                     | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | which config template will be used|
| 723 | [`redis_fs_main`](v-redis.md#redis_fs_main)                               | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | main data disk for redis|
| 724 | [`redis_bind_address`](v-redis.md#redis_bind_address)                     | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | e.g 0.0.0.0, empty will use inventory_hostname as bind address|
| 725 | [`redis_exists_action`](v-redis.md#redis_exists_action)                   | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | what to do when redis exists|
| 726 | [`redis_disable_purge`](v-redis.md#redis_disable_purge)                   | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | set to true to disable purge functionality for good (force redis_exists_action = abort)|
| 727 | [`redis_max_memory`](v-redis.md#redis_max_memory)                         | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C/I   | max memory used by each redis instance|
| 728 | [`redis_mem_policy`](v-redis.md#redis_mem_policy)                         | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | memory eviction policy|
| 729 | [`redis_password`](v-redis.md#redis_password)                             | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | empty password disable password auth (masterauth & requirepass)|
| 730 | [`redis_rdb_save`](v-redis.md#redis_rdb_save)                             | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | redis RDB save directives, empty list disable it|
| 731 | [`redis_aof_enabled`](v-redis.md#redis_aof_enabled)                       | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | enable redis AOF|
| 732 | [`redis_rename_commands`](v-redis.md#redis_rename_commands)               | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | rename dangerous commands|
| 740 | [`redis_cluster_replicas`](v-redis.md#redis_cluster_replicas)             | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | how much replicas per master in redis cluster ?|
| 741 | [`redis_exporter_enabled`](v-redis.md#redis_exporter_enabled)             | [`REDIS_EXPORTER`](v-redis.md#REDIS_EXPORTER)   | C     | install redis exporter on redis nodes|
| 742 | [`redis_exporter_port`](v-redis.md#redis_exporter_port)                   | [`REDIS_EXPORTER`](v-redis.md#REDIS_EXPORTER)   | C     | default port for redis exporter|
| 743 | [`redis_exporter_options`](v-redis.md#redis_exporter_options)             | [`REDIS_EXPORTER`](v-redis.md#REDIS_EXPORTER)   | C/I   | default cli args for redis exporter|
