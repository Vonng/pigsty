# Configuring Pigsty

Pigsty uses declarative [configuration] (c-config.md) to describe desired state.
And the idempotent provisioning playbooks are responsible for adjusting system into that state.

Pigsty config is consist of 185 [config entry](#config-entries), 
divided into 10 [groups](#config-groups) and 5 levels. 
Most of them does not need your attention. Only identity parameters are required for defining new database clusters.


## Config Groups

| No | Group | Category | Count | Functionality |
| :--: | :----------------------------: | :------: | :--: | -------------------------------------- |
| 1 | [connect](v-connect.md) | Infra | 1 | Proxy server configuration, connection information for managed objects |
| 2 | [repo](v-repo.md) | Infra | 10 | Customize local Yum sources, install packages offline |
| 3 | [node](v-node.md) | Infra | 31 | Configure the infrastructure on a normal node |
| 4 | [meta](v-meta.md) | Infra | 34 | Installing and enabling infrastructure services on a meta node |
| 5 | [dcs](v-dcs.md) | Infra | 8 | Configure DCS services (consul/etcd) on all nodes |
| 6 | [pg-install](v-pg-install.md) | PgSQL | 11 | Install PostgreSQL database |
| 7 | [pg-provision](v-pg-provision.md) | PgSQL | 33 | Pulling up a PostgreSQL database cluster |
| 8 | [pg-template](v-pg-template.md) | PgSQL | 19 | Customizing PostgreSQL database content |
| 9 | [monitor](v-monitor.md) | PgSQL | 21 | Installing Pigsty database monitoring system |
| 10 | [service](v-service.md) | PgSQL | 17 | Expose database services to the public via Haproxy or VIP |



## Config Entries

|                                   Var                                   |      Category       |                                        Role                                        | Level |                                         Comment                                         |
|-------------------------------------------------------------------------|---------------------|------------------------------------------------------------------------------------|-------|-----------------------------------------------------------------------------------------|
| [proxy_env](v-infra.md#proxy_env)                                       | [INFRA](v-infra.md) | [repo](https://github.com/Vonng/pigsty/tree/master/roles/repo)                     | G     | proxy environment variables|
| [repo_enabled](v-infra.md#repo_enabled)                                 | [INFRA](v-infra.md) | [repo](https://github.com/Vonng/pigsty/tree/master/roles/repo)                     | G     | enable local yum repo|
| [repo_name](v-infra.md#repo_name)                                       | [INFRA](v-infra.md) | [repo](https://github.com/Vonng/pigsty/tree/master/roles/repo)                     | G     | local yum repo name|
| [repo_address](v-infra.md#repo_address)                                 | [INFRA](v-infra.md) | [repo](https://github.com/Vonng/pigsty/tree/master/roles/repo)                     | G     | external access point of repo|
| [repo_port](v-infra.md#repo_port)                                       | [INFRA](v-infra.md) | [repo](https://github.com/Vonng/pigsty/tree/master/roles/repo)                     | G     | repo listen address (80)|
| [repo_home](v-infra.md#repo_home)                                       | [INFRA](v-infra.md) | [repo](https://github.com/Vonng/pigsty/tree/master/roles/repo)                     | G     | repo home dir (www)|
| [repo_rebuild](v-infra.md#repo_rebuild)                                 | [INFRA](v-infra.md) | [repo](https://github.com/Vonng/pigsty/tree/master/roles/repo)                     | A     | rebuild local yum repo?|
| [repo_remove](v-infra.md#repo_remove)                                   | [INFRA](v-infra.md) | [repo](https://github.com/Vonng/pigsty/tree/master/roles/repo)                     | A     | remove existing repo file?|
| [repo_upstreams](v-infra.md#repo_upstreams)                             | [INFRA](v-infra.md) | [repo](https://github.com/Vonng/pigsty/tree/master/roles/repo)                     | G     | upstream repo definition|
| [repo_packages](v-infra.md#repo_packages)                               | [INFRA](v-infra.md) | [repo](https://github.com/Vonng/pigsty/tree/master/roles/repo)                     | G     | packages to be downloaded|
| [repo_url_packages](v-infra.md#repo_url_packages)                       | [INFRA](v-infra.md) | [repo](https://github.com/Vonng/pigsty/tree/master/roles/repo)                     | G     | pkgs to be downloaded via url|
| [ca_method](v-infra.md#ca_method)                                       | [INFRA](v-infra.md) | [ca](https://github.com/Vonng/pigsty/tree/master/roles/ca)                         | G     | ca mode|
| [ca_subject](v-infra.md#ca_subject)                                     | [INFRA](v-infra.md) | [ca](https://github.com/Vonng/pigsty/tree/master/roles/ca)                         | G     | ca subject|
| [ca_homedir](v-infra.md#ca_homedir)                                     | [INFRA](v-infra.md) | [ca](https://github.com/Vonng/pigsty/tree/master/roles/ca)                         | G     | ca cert home dir|
| [ca_cert](v-infra.md#ca_cert)                                           | [INFRA](v-infra.md) | [ca](https://github.com/Vonng/pigsty/tree/master/roles/ca)                         | G     | ca cert file name|
| [ca_key](v-infra.md#ca_key)                                             | [INFRA](v-infra.md) | [ca](https://github.com/Vonng/pigsty/tree/master/roles/ca)                         | G     | ca private key name|
| [nginx_upstream](v-infra.md#nginx_upstream)                             | [INFRA](v-infra.md) | [nginx](https://github.com/Vonng/pigsty/tree/master/roles/nginx)                   | G     | nginx upstream definition|
| [app_list](v-infra.md#app_list)                                         | [INFRA](v-infra.md) | [nginx](https://github.com/Vonng/pigsty/tree/master/roles/nginx)                   | G     | app list on home page navbar|
| [docs_enabled](v-infra.md#docs_enabled)                                 | [INFRA](v-infra.md) | [nginx](https://github.com/Vonng/pigsty/tree/master/roles/nginx)                   | G     | enable local docs|
| [pev2_enabled](v-infra.md#pev2_enabled)                                 | [INFRA](v-infra.md) | [nginx](https://github.com/Vonng/pigsty/tree/master/roles/nginx)                   | G     | enable pev2|
| [pgbadger_enabled](v-infra.md#pgbadger_enabled)                         | [INFRA](v-infra.md) | [nginx](https://github.com/Vonng/pigsty/tree/master/roles/nginx)                   | G     | enable pgbadger|
| [dns_records](v-infra.md#dns_records)                                   | [INFRA](v-infra.md) | [nameserver](https://github.com/Vonng/pigsty/tree/master/roles/nameserver)         | G     | dynamic DNS records|
| [prometheus_data_dir](v-infra.md#prometheus_data_dir)                   | [INFRA](v-infra.md) | [prometheus](https://github.com/Vonng/pigsty/tree/master/roles/prometheus)         | G     | prometheus data dir|
| [prometheus_options](v-infra.md#prometheus_options)                     | [INFRA](v-infra.md) | [prometheus](https://github.com/Vonng/pigsty/tree/master/roles/prometheus)         | G     | prometheus cli args|
| [prometheus_reload](v-infra.md#prometheus_reload)                       | [INFRA](v-infra.md) | [prometheus](https://github.com/Vonng/pigsty/tree/master/roles/prometheus)         | A     | prom reload instead of init|
| [prometheus_sd_method](v-infra.md#prometheus_sd_method)                 | [INFRA](v-infra.md) | [prometheus](https://github.com/Vonng/pigsty/tree/master/roles/prometheus)         | G     | service discovery method: static|consul|
| [prometheus_scrape_interval](v-infra.md#prometheus_scrape_interval)     | [INFRA](v-infra.md) | [prometheus](https://github.com/Vonng/pigsty/tree/master/roles/prometheus)         | G     | prom scrape interval (10s)|
| [prometheus_scrape_timeout](v-infra.md#prometheus_scrape_timeout)       | [INFRA](v-infra.md) | [prometheus](https://github.com/Vonng/pigsty/tree/master/roles/prometheus)         | G     | prom scrape timeout (8s)|
| [prometheus_sd_interval](v-infra.md#prometheus_sd_interval)             | [INFRA](v-infra.md) | [prometheus](https://github.com/Vonng/pigsty/tree/master/roles/prometheus)         | G     | prom discovery refresh interval|
| [grafana_endpoint](v-infra.md#grafana_endpoint)                         | [INFRA](v-infra.md) | [grafana](https://github.com/Vonng/pigsty/tree/master/roles/grafana)               | G     | grafana API endpoint|
| [grafana_admin_username](v-infra.md#grafana_admin_username)             | [INFRA](v-infra.md) | [grafana](https://github.com/Vonng/pigsty/tree/master/roles/grafana)               | G     | grafana admin username|
| [grafana_admin_password](v-infra.md#grafana_admin_password)             | [INFRA](v-infra.md) | [grafana](https://github.com/Vonng/pigsty/tree/master/roles/grafana)               | G     | grafana admin password|
| [grafana_database](v-infra.md#grafana_database)                         | [INFRA](v-infra.md) | [grafana](https://github.com/Vonng/pigsty/tree/master/roles/grafana)               | G     | grafana backend database type|
| [grafana_pgurl](v-infra.md#grafana_pgurl)                               | [INFRA](v-infra.md) | [grafana](https://github.com/Vonng/pigsty/tree/master/roles/grafana)               | G     | grafana backend postgres url|
| [grafana_plugin](v-infra.md#grafana_plugin)                             | [INFRA](v-infra.md) | [grafana](https://github.com/Vonng/pigsty/tree/master/roles/grafana)               | G     | how to install grafana plugins|
| [grafana_cache](v-infra.md#grafana_cache)                               | [INFRA](v-infra.md) | [grafana](https://github.com/Vonng/pigsty/tree/master/roles/grafana)               | G     | grafana plugins cache path|
| [grafana_plugins](v-infra.md#grafana_plugins)                           | [INFRA](v-infra.md) | [grafana](https://github.com/Vonng/pigsty/tree/master/roles/grafana)               | G     | grafana plugins to be installed|
| [grafana_git_plugins](v-infra.md#grafana_git_plugins)                   | [INFRA](v-infra.md) | [grafana](https://github.com/Vonng/pigsty/tree/master/roles/grafana)               | G     | grafana plugins via git|
| [loki_clean](v-infra.md#loki_clean)                                     | [INFRA](v-infra.md) | [loki](https://github.com/Vonng/pigsty/tree/master/roles/loki)                     | A     | remove existing loki data?|
| [loki_options](v-infra.md#loki_options)                                 | [INFRA](v-infra.md) | [loki](https://github.com/Vonng/pigsty/tree/master/roles/loki)                     | G     | loki cli args|
| [loki_data_dir](v-infra.md#loki_data_dir)                               | [INFRA](v-infra.md) | [loki](https://github.com/Vonng/pigsty/tree/master/roles/loki)                     | G     | loki data path|
| [loki_retention](v-infra.md#loki_retention)                             | [INFRA](v-infra.md) | [loki](https://github.com/Vonng/pigsty/tree/master/roles/loki)                     | G     | loki log keeping period|
| [jupyter_enabled](v-infra.md#jupyter_enabled)                           | [INFRA](v-infra.md) | [jupyter](https://github.com/Vonng/pigsty/tree/master/roles/jupyter)               | G     | enable jupyter lab|
| [jupyter_username](v-infra.md#jupyter_username)                         | [INFRA](v-infra.md) | [jupyter](https://github.com/Vonng/pigsty/tree/master/roles/jupyter)               | G     | os user for jupyter lab|
| [jupyter_password](v-infra.md#jupyter_password)                         | [INFRA](v-infra.md) | [jupyter](https://github.com/Vonng/pigsty/tree/master/roles/jupyter)               | G     | password for jupyter lab|
| [pgweb_enabled](v-infra.md#pgweb_enabled)                               | [INFRA](v-infra.md) | [jupyter](https://github.com/Vonng/pigsty/tree/master/roles/jupyter)               | G     | enable pgweb|
| [pgweb_username](v-infra.md#pgweb_username)                             | [INFRA](v-infra.md) | [jupyter](https://github.com/Vonng/pigsty/tree/master/roles/jupyter)               | G     | os user for pgweb|
| [meta_node](v-nodes.md#meta_node)                                       | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | I/C   | mark this node as meta|
| [nodename](v-nodes.md#nodename)                                         | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | I     | overwrite hostname if specified|
| [nodename_overwrite](v-nodes.md#nodename_overwrite)                     | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | I/C/G | overwrite hostname with nodename|
| [node_cluster](v-nodes.md#node_cluster)                                 | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | C     | node cluster name|
| [node_name_exchange](v-nodes.md#node_name_exchange)                     | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | I/C/G | exchange static hostname|
| [node_dns_hosts](v-nodes.md#node_dns_hosts)                             | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | static DNS records|
| [node_dns_hosts_extra](v-nodes.md#node_dns_hosts_extra)                 | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | I/C   | extra static DNS records|
| [node_dns_server](v-nodes.md#node_dns_server)                           | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | how to setup dns service?|
| [node_dns_servers](v-nodes.md#node_dns_servers)                         | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | dynamic DNS servers|
| [node_dns_options](v-nodes.md#node_dns_options)                         | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | /etc/resolv.conf options|
| [node_repo_method](v-nodes.md#node_repo_method)                         | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | how to use yum repo (local)|
| [node_repo_remove](v-nodes.md#node_repo_remove)                         | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | remove existing repo file?|
| [node_local_repo_url](v-nodes.md#node_local_repo_url)                   | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | local yum repo url|
| [node_packages](v-nodes.md#node_packages)                               | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | pkgs to be installed on all node|
| [node_extra_packages](v-nodes.md#node_extra_packages)                   | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | C/I/A | extra pkgs to be installed|
| [node_meta_packages](v-nodes.md#node_meta_packages)                     | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | meta node only packages|
| [node_meta_pip_install](v-nodes.md#node_meta_pip_install)               | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | meta node pip3 packages|
| [node_disable_numa](v-nodes.md#node_disable_numa)                       | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | disable numa?|
| [node_disable_swap](v-nodes.md#node_disable_swap)                       | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | disable swap?|
| [node_disable_firewall](v-nodes.md#node_disable_firewall)               | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | disable firewall?|
| [node_disable_selinux](v-nodes.md#node_disable_selinux)                 | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | disable selinux?|
| [node_static_network](v-nodes.md#node_static_network)                   | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | use static DNS config?|
| [node_disk_prefetch](v-nodes.md#node_disk_prefetch)                     | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | enable disk prefetch?|
| [node_kernel_modules](v-nodes.md#node_kernel_modules)                   | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | kernel modules to be installed|
| [node_tune](v-nodes.md#node_tune)                                       | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | node tune mode|
| [node_sysctl_params](v-nodes.md#node_sysctl_params)                     | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | extra kernel parameters|
| [node_admin_setup](v-nodes.md#node_admin_setup)                         | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | create admin user?|
| [node_admin_uid](v-nodes.md#node_admin_uid)                             | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | admin user UID|
| [node_admin_username](v-nodes.md#node_admin_username)                   | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | admin user name|
| [node_admin_ssh_exchange](v-nodes.md#node_admin_ssh_exchange)           | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | exchange admin ssh keys?|
| [node_admin_pks](v-nodes.md#node_admin_pks)                             | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | add current user's pkey?|
| [node_admin_pk_current](v-nodes.md#node_admin_pk_current)               | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | A     | pks to be added to admin|
| [node_ntp_service](v-nodes.md#node_ntp_service)                         | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | ntp mode: ntp or chrony?|
| [node_ntp_config](v-nodes.md#node_ntp_config)                           | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | setup ntp on node?|
| [node_timezone](v-nodes.md#node_timezone)                               | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | node timezone|
| [node_ntp_servers](v-nodes.md#node_ntp_servers)                         | [NODES](v-nodes.md) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                     | G     | ntp server list|
| [service_registry](v-nodes.md#service_registry)                         | [NODES](v-nodes.md) | [consul](https://github.com/Vonng/pigsty/tree/master/roles/consul)                 | G/C/I | where to register service?|
| [dcs_type](v-nodes.md#dcs_type)                                         | [NODES](v-nodes.md) | [consul](https://github.com/Vonng/pigsty/tree/master/roles/consul)                 | G     | which dcs to use (consul/etcd)|
| [dcs_name](v-nodes.md#dcs_name)                                         | [NODES](v-nodes.md) | [consul](https://github.com/Vonng/pigsty/tree/master/roles/consul)                 | G     | dcs cluster name (dc)|
| [dcs_servers](v-nodes.md#dcs_servers)                                   | [NODES](v-nodes.md) | [consul](https://github.com/Vonng/pigsty/tree/master/roles/consul)                 | G     | dcs server dict|
| [dcs_exists_action](v-nodes.md#dcs_exists_action)                       | [NODES](v-nodes.md) | [consul](https://github.com/Vonng/pigsty/tree/master/roles/consul)                 | G/A   | how to deal with existing dcs|
| [dcs_disable_purge](v-nodes.md#dcs_disable_purge)                       | [NODES](v-nodes.md) | [consul](https://github.com/Vonng/pigsty/tree/master/roles/consul)                 | G/C/I | disable dcs purge|
| [consul_data_dir](v-nodes.md#consul_data_dir)                           | [NODES](v-nodes.md) | [consul](https://github.com/Vonng/pigsty/tree/master/roles/consul)                 | G     | consul data dir path|
| [etcd_data_dir](v-nodes.md#etcd_data_dir)                               | [NODES](v-nodes.md) | [consul](https://github.com/Vonng/pigsty/tree/master/roles/consul)                 | G     | etcd data dir path|
| [exporter_install](v-nodes.md#exporter_install)                         | [NODES](v-nodes.md) | [node_exporter](https://github.com/Vonng/pigsty/tree/master/roles/node_exporter)   | G/C   | how to install exporter?|
| [exporter_repo_url](v-nodes.md#exporter_repo_url)                       | [NODES](v-nodes.md) | [node_exporter](https://github.com/Vonng/pigsty/tree/master/roles/node_exporter)   | G/C   | repo url for yum install|
| [exporter_metrics_path](v-nodes.md#exporter_metrics_path)               | [NODES](v-nodes.md) | [node_exporter](https://github.com/Vonng/pigsty/tree/master/roles/node_exporter)   | G/C   | URL path for exporting metrics|
| [node_exporter_enabled](v-nodes.md#node_exporter_enabled)               | [NODES](v-nodes.md) | [node_exporter](https://github.com/Vonng/pigsty/tree/master/roles/node_exporter)   | G/C   | node_exporter enabled?|
| [node_exporter_port](v-nodes.md#node_exporter_port)                     | [NODES](v-nodes.md) | [node_exporter](https://github.com/Vonng/pigsty/tree/master/roles/node_exporter)   | G/C   | node_exporter listen port|
| [node_exporter_options](v-nodes.md#node_exporter_options)               | [NODES](v-nodes.md) | [node_exporter](https://github.com/Vonng/pigsty/tree/master/roles/node_exporter)   | G/C   | node_exporter extra cli args|
| [promtail_enabled](v-nodes.md#promtail_enabled)                         | [NODES](v-nodes.md) | [promtail](https://github.com/Vonng/pigsty/tree/master/roles/promtail)             | G/C   | promtail enabled ?|
| [promtail_clean](v-nodes.md#promtail_clean)                             | [NODES](v-nodes.md) | [promtail](https://github.com/Vonng/pigsty/tree/master/roles/promtail)             | G/C/A | remove promtail status file ?|
| [promtail_port](v-nodes.md#promtail_port)                               | [NODES](v-nodes.md) | [promtail](https://github.com/Vonng/pigsty/tree/master/roles/promtail)             | G/C   | promtail listen port|
| [promtail_options](v-nodes.md#promtail_options)                         | [NODES](v-nodes.md) | [promtail](https://github.com/Vonng/pigsty/tree/master/roles/promtail)             | G/C   | promtail cli args|
| [promtail_positions](v-nodes.md#promtail_positions)                     | [NODES](v-nodes.md) | [promtail](https://github.com/Vonng/pigsty/tree/master/roles/promtail)             | G/C   | path to store promtail status file|
| [promtail_send_url](v-nodes.md#promtail_send_url)                       | [NODES](v-nodes.md) | [promtail](https://github.com/Vonng/pigsty/tree/master/roles/promtail)             | G/C   | loki endpoint to receive log|
| [pg_dbsu](v-pgsql.md#pg_dbsu)                                           | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | os dbsu for postgres|
| [pg_dbsu_uid](v-pgsql.md#pg_dbsu_uid)                                   | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | dbsu UID|
| [pg_dbsu_sudo](v-pgsql.md#pg_dbsu_sudo)                                 | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | sudo priv mode for dbsu|
| [pg_dbsu_home](v-pgsql.md#pg_dbsu_home)                                 | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | home dir for dbsu|
| [pg_dbsu_ssh_exchange](v-pgsql.md#pg_dbsu_ssh_exchange)                 | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | exchange dbsu ssh keys?|
| [pg_version](v-pgsql.md#pg_version)                                     | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | major PG version to be installed|
| [pgdg_repo](v-pgsql.md#pgdg_repo)                                       | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | add official PGDG repo?|
| [pg_add_repo](v-pgsql.md#pg_add_repo)                                   | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | add extra upstream PG repo?|
| [pg_bin_dir](v-pgsql.md#pg_bin_dir)                                     | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | PG binary dir|
| [pg_packages](v-pgsql.md#pg_packages)                                   | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | PG packages to be installed|
| [pg_extensions](v-pgsql.md#pg_extensions)                               | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | PG extension pkgs to be installed|
| [pg_cluster](v-pgsql.md#pg_cluster)                                     | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | C     | PG Cluster Name|
| [pg_seq](v-pgsql.md#pg_seq)                                             | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | I     | PG Instance Sequence|
| [pg_role](v-pgsql.md#pg_role)                                           | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | I     | PG Instance Role|
| [pg_shard](v-pgsql.md#pg_shard)                                         | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | C     | PG Shard Name (Reserve)|
| [pg_sindex](v-pgsql.md#pg_sindex)                                       | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | C     | PG Shard Index (Reserve)|
| [pg_preflight_skip](v-pgsql.md#pg_preflight_skip)                       | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | A/C   | skip preflight param validation|
| [pg_hostname](v-pgsql.md#pg_hostname)                                   | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | set PG ins name as hostname|
| [pg_exists](v-pgsql.md#pg_exists)                                       | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | A     | flag indicate pg exists|
| [pg_exists_action](v-pgsql.md#pg_exists_action)                         | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/A   | how to deal with existing pg ins|
| [pg_disable_purge](v-pgsql.md#pg_disable_purge)                         | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C/I | disable pg instance purge|
| [pg_data](v-pgsql.md#pg_data)                                           | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G     | pg data dir|
| [pg_fs_main](v-pgsql.md#pg_fs_main)                                     | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G     | pg main data disk mountpoint|
| [pg_fs_bkup](v-pgsql.md#pg_fs_bkup)                                     | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G     | pg backup disk mountpoint|
| [pg_dummy_filesize](v-pgsql.md#pg_dummy_filesize)                       | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C/I | /pg/dummy file size|
| [pg_listen](v-pgsql.md#pg_listen)                                       | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G     | pg listen IP address|
| [pg_port](v-pgsql.md#pg_port)                                           | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G     | pg listen port|
| [pg_localhost](v-pgsql.md#pg_localhost)                                 | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | pg unix socket path|
| [pg_upstream](v-pgsql.md#pg_upstream)                                   | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | I     | pg upstream IP address|
| [pg_backup](v-pgsql.md#pg_backup)                                       | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | I     | make base backup on this ins?|
| [pg_delay](v-pgsql.md#pg_delay)                                         | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | I     | apply lag for delayed instance|
| [patroni_enabled](v-pgsql.md#patroni_enabled)                           | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | C     | Is patroni & postgres enabled?|
| [patroni_mode](v-pgsql.md#patroni_mode)                                 | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | patroni working mode|
| [pg_namespace](v-pgsql.md#pg_namespace)                                 | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | namespace for patroni|
| [patroni_port](v-pgsql.md#patroni_port)                                 | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | patroni listen port (8080)|
| [patroni_watchdog_mode](v-pgsql.md#patroni_watchdog_mode)               | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | patroni watchdog policy|
| [pg_conf](v-pgsql.md#pg_conf)                                           | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | patroni template|
| [pg_shared_libraries](v-pgsql.md#pg_shared_libraries)                   | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | default preload shared libraries|
| [pg_encoding](v-pgsql.md#pg_encoding)                                   | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | character encoding|
| [pg_locale](v-pgsql.md#pg_locale)                                       | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | locale|
| [pg_lc_collate](v-pgsql.md#pg_lc_collate)                               | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | collate rule of locale|
| [pg_lc_ctype](v-pgsql.md#pg_lc_ctype)                                   | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | ctype of locale|
| [pgbouncer_enabled](v-pgsql.md#pgbouncer_enabled)                       | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | is pgbouncer enabled|
| [pgbouncer_port](v-pgsql.md#pgbouncer_port)                             | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | pgbouncer listen port|
| [pgbouncer_poolmode](v-pgsql.md#pgbouncer_poolmode)                     | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | pgbouncer pooling mode|
| [pgbouncer_max_db_conn](v-pgsql.md#pgbouncer_max_db_conn)               | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | max connection per database|
| [pg_init](v-pgsql.md#pg_init)                                           | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | path to postgres init script|
| [pg_replication_username](v-pgsql.md#pg_replication_username)           | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G     | replication user's name|
| [pg_replication_password](v-pgsql.md#pg_replication_password)           | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G     | replication user's password|
| [pg_monitor_username](v-pgsql.md#pg_monitor_username)                   | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G     | monitor user's name|
| [pg_monitor_password](v-pgsql.md#pg_monitor_password)                   | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G     | monitor user's password|
| [pg_admin_username](v-pgsql.md#pg_admin_username)                       | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G     | admin user's name|
| [pg_admin_password](v-pgsql.md#pg_admin_password)                       | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G     | admin user's password|
| [pg_default_roles](v-pgsql.md#pg_default_roles)                         | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G     | list or global default roles/users|
| [pg_default_privilegs](v-pgsql.md#pg_default_privilegs)                 | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G     | list of default privileges|
| [pg_default_schemas](v-pgsql.md#pg_default_schemas)                     | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G     | list of default schemas|
| [pg_default_extensions](v-pgsql.md#pg_default_extensions)               | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G     | list of default extensions|
| [pg_offline_query](v-pgsql.md#pg_offline_query)                         | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | I     | allow offline query?|
| [pg_reload](v-pgsql.md#pg_reload)                                       | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | A     | reload configuration?|
| [pg_hba_rules](v-pgsql.md#pg_hba_rules)                                 | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G     | global HBA rules|
| [pg_hba_rules_extra](v-pgsql.md#pg_hba_rules_extra)                     | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | C/I   | ad hoc HBA rules|
| [pgbouncer_hba_rules](v-pgsql.md#pgbouncer_hba_rules)                   | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | global pgbouncer HBA rules|
| [pgbouncer_hba_rules_extra](v-pgsql.md#pgbouncer_hba_rules_extra)       | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | ad hoc pgbouncer HBA rules|
| [pg_databases](v-pgsql.md#pg_databases)                                 | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | business databases definition|
| [pg_users](v-pgsql.md#pg_users)                                         | [PGSQL](v-pgsql.md) | [postgres](https://github.com/Vonng/pigsty/tree/master/roles/postgres)             | G/C   | business users definition|
| [pg_exporter_config](v-pgsql.md#pg_exporter_config)                     | [PGSQL](v-pgsql.md) | [pg_exporter](https://github.com/Vonng/pigsty/tree/master/roles/pg_exporter)       | G/C   | pg_exporter config path|
| [pg_exporter_enabled](v-pgsql.md#pg_exporter_enabled)                   | [PGSQL](v-pgsql.md) | [pg_exporter](https://github.com/Vonng/pigsty/tree/master/roles/pg_exporter)       | G/C   | pg_exporter enabled ?|
| [pg_exporter_port](v-pgsql.md#pg_exporter_port)                         | [PGSQL](v-pgsql.md) | [pg_exporter](https://github.com/Vonng/pigsty/tree/master/roles/pg_exporter)       | G/C   | pg_exporter listen address|
| [pg_exporter_params](v-pgsql.md#pg_exporter_params)                     | [PGSQL](v-pgsql.md) | [pg_exporter](https://github.com/Vonng/pigsty/tree/master/roles/pg_exporter)       | G/C/I | extra params for pg_exporter url|
| [pg_exporter_url](v-pgsql.md#pg_exporter_url)                           | [PGSQL](v-pgsql.md) | [pg_exporter](https://github.com/Vonng/pigsty/tree/master/roles/pg_exporter)       | C/I   | monitor target pgurl (overwrite)|
| [pg_exporter_auto_discovery](v-pgsql.md#pg_exporter_auto_discovery)     | [PGSQL](v-pgsql.md) | [pg_exporter](https://github.com/Vonng/pigsty/tree/master/roles/pg_exporter)       | G/C/I | enable auto-database-discovery?|
| [pg_exporter_exclude_database](v-pgsql.md#pg_exporter_exclude_database) | [PGSQL](v-pgsql.md) | [pg_exporter](https://github.com/Vonng/pigsty/tree/master/roles/pg_exporter)       | G/C/I | excluded list of databases|
| [pg_exporter_include_database](v-pgsql.md#pg_exporter_include_database) | [PGSQL](v-pgsql.md) | [pg_exporter](https://github.com/Vonng/pigsty/tree/master/roles/pg_exporter)       | G/C/I | included list of databases|
| [pg_exporter_options](v-pgsql.md#pg_exporter_options)                   | [PGSQL](v-pgsql.md) | [pg_exporter](https://github.com/Vonng/pigsty/tree/master/roles/pg_exporter)       | G/C/I | cli args for pg_exporter|
| [pgbouncer_exporter_enabled](v-pgsql.md#pgbouncer_exporter_enabled)     | [PGSQL](v-pgsql.md) | [pg_exporter](https://github.com/Vonng/pigsty/tree/master/roles/pg_exporter)       | G/C   | pgbouncer_exporter enabled ?|
| [pgbouncer_exporter_port](v-pgsql.md#pgbouncer_exporter_port)           | [PGSQL](v-pgsql.md) | [pg_exporter](https://github.com/Vonng/pigsty/tree/master/roles/pg_exporter)       | G/C   | pgbouncer_exporter listen addr?|
| [pgbouncer_exporter_url](v-pgsql.md#pgbouncer_exporter_url)             | [PGSQL](v-pgsql.md) | [pg_exporter](https://github.com/Vonng/pigsty/tree/master/roles/pg_exporter)       | G/C   | target pgbouncer url (overwrite)|
| [pgbouncer_exporter_options](v-pgsql.md#pgbouncer_exporter_options)     | [PGSQL](v-pgsql.md) | [pg_exporter](https://github.com/Vonng/pigsty/tree/master/roles/pg_exporter)       | G/C/I | cli args for pgbouncer exporter|
| [pg_weight](v-pgsql.md#pg_weight)                                       | [PGSQL](v-pgsql.md) | [service](https://github.com/Vonng/pigsty/tree/master/roles/service)               | I     | relative weight in load balancer|
| [pg_services](v-pgsql.md#pg_services)                                   | [PGSQL](v-pgsql.md) | [service](https://github.com/Vonng/pigsty/tree/master/roles/service)               | G     | global service definition|
| [pg_services_extra](v-pgsql.md#pg_services_extra)                       | [PGSQL](v-pgsql.md) | [service](https://github.com/Vonng/pigsty/tree/master/roles/service)               | C     | ad hoc service definition|
| [haproxy_enabled](v-pgsql.md#haproxy_enabled)                           | [PGSQL](v-pgsql.md) | [service](https://github.com/Vonng/pigsty/tree/master/roles/service)               | G/C/I | haproxy enabled ?|
| [haproxy_reload](v-pgsql.md#haproxy_reload)                             | [PGSQL](v-pgsql.md) | [service](https://github.com/Vonng/pigsty/tree/master/roles/service)               | A     | haproxy reload instead of reset|
| [haproxy_admin_auth_enabled](v-pgsql.md#haproxy_admin_auth_enabled)     | [PGSQL](v-pgsql.md) | [service](https://github.com/Vonng/pigsty/tree/master/roles/service)               | G/C   | enable auth for haproxy admin ?|
| [haproxy_admin_username](v-pgsql.md#haproxy_admin_username)             | [PGSQL](v-pgsql.md) | [service](https://github.com/Vonng/pigsty/tree/master/roles/service)               | G/C   | haproxy admin user name|
| [haproxy_admin_password](v-pgsql.md#haproxy_admin_password)             | [PGSQL](v-pgsql.md) | [service](https://github.com/Vonng/pigsty/tree/master/roles/service)               | G/C   | haproxy admin password|
| [haproxy_exporter_port](v-pgsql.md#haproxy_exporter_port)               | [PGSQL](v-pgsql.md) | [service](https://github.com/Vonng/pigsty/tree/master/roles/service)               | G/C   | haproxy exporter listen port|
| [haproxy_client_timeout](v-pgsql.md#haproxy_client_timeout)             | [PGSQL](v-pgsql.md) | [service](https://github.com/Vonng/pigsty/tree/master/roles/service)               | G/C   | haproxy client timeout|
| [haproxy_server_timeout](v-pgsql.md#haproxy_server_timeout)             | [PGSQL](v-pgsql.md) | [service](https://github.com/Vonng/pigsty/tree/master/roles/service)               | G/C   | haproxy server timeout|
| [vip_mode](v-pgsql.md#vip_mode)                                         | [PGSQL](v-pgsql.md) | [service](https://github.com/Vonng/pigsty/tree/master/roles/service)               | G/C   | vip working mode|
| [vip_reload](v-pgsql.md#vip_reload)                                     | [PGSQL](v-pgsql.md) | [service](https://github.com/Vonng/pigsty/tree/master/roles/service)               | G/C   | reload vip configuration|
| [vip_address](v-pgsql.md#vip_address)                                   | [PGSQL](v-pgsql.md) | [service](https://github.com/Vonng/pigsty/tree/master/roles/service)               | G/C   | vip address used by cluster|
| [vip_cidrmask](v-pgsql.md#vip_cidrmask)                                 | [PGSQL](v-pgsql.md) | [service](https://github.com/Vonng/pigsty/tree/master/roles/service)               | G/C   | vip network CIDR|
| [vip_interface](v-pgsql.md#vip_interface)                               | [PGSQL](v-pgsql.md) | [service](https://github.com/Vonng/pigsty/tree/master/roles/service)               | G/C   | vip network interface name|
| [dns_mode](v-pgsql.md#dns_mode)                                         | [PGSQL](v-pgsql.md) | [service](https://github.com/Vonng/pigsty/tree/master/roles/service)               | G/C   | cluster DNS mode|
| [dns_selector](v-pgsql.md#dns_selector)                                 | [PGSQL](v-pgsql.md) | [service](https://github.com/Vonng/pigsty/tree/master/roles/service)               | G/C   | cluster DNS ins selector|
| [rm_pgdata](v-pgsql.md#rm_pgdata)                                       | [PGSQL](v-pgsql.md) | [pg_remove](https://github.com/Vonng/pigsty/tree/master/roles/pg_remove)           | A     | rm pgdata when remove pg|
| [rm_pgpkgs](v-pgsql.md#rm_pgpkgs)                                       | [PGSQL](v-pgsql.md) | [pg_remove](https://github.com/Vonng/pigsty/tree/master/roles/pg_remove)           | A     | rm pg pkgs when remove pg|
| [pg_user](v-pgsql.md#pg_user)                                           | [PGSQL](v-pgsql.md) | [createuser](https://github.com/Vonng/pigsty/tree/master/roles/createuser)         | A     | name of pg_users to be created|
| [pg_database](v-pgsql.md#pg_database)                                   | [PGSQL](v-pgsql.md) | [createdb](https://github.com/Vonng/pigsty/tree/master/roles/createdb)             | A     | name of pg_databases to be created|
| [gp_cluster](v-gpsql.md#gp_cluster)                                     | [GPSQL](v-gpsql.md) | [pg_exporters](https://github.com/Vonng/pigsty/tree/master/roles/pg_exporters)     | C     | gp cluster name of this pg cluster|
| [gp_role](v-gpsql.md#gp_role)                                           | [GPSQL](v-gpsql.md) | [pg_exporters](https://github.com/Vonng/pigsty/tree/master/roles/pg_exporters)     | C     | gp role of this pg cluster|
| [pg_instances](v-gpsql.md#pg_instances)                                 | [GPSQL](v-gpsql.md) | [pg_exporters](https://github.com/Vonng/pigsty/tree/master/roles/pg_exporters)     | I     | pg instance on this node|
| [redis_cluster](v-redis.md#redis_cluster)                               | [REDIS](v-redis.md) | [redis](https://github.com/Vonng/pigsty/tree/master/roles/redis)                   | )     | name of this redis 'cluster' , cluster level|
| [redis_node](v-redis.md#redis_node)                                     | [REDIS](v-redis.md) | [redis](https://github.com/Vonng/pigsty/tree/master/roles/redis)                   | I     | id of this redis node, integer sequence @ instance level|
| [redis_instances](v-redis.md#redis_instances)                           | [REDIS](v-redis.md) | [redis](https://github.com/Vonng/pigsty/tree/master/roles/redis)                   | I     | redis instance list on this redis node @ instance level|
| [redis_mode](v-redis.md#redis_mode)                                     | [REDIS](v-redis.md) | [redis](https://github.com/Vonng/pigsty/tree/master/roles/redis)                   | C     | standalone,cluster,sentinel|
| [redis_conf](v-redis.md#redis_conf)                                     | [REDIS](v-redis.md) | [redis](https://github.com/Vonng/pigsty/tree/master/roles/redis)                   | G     | which config template will be used|
| [redis_fs_main](v-redis.md#redis_fs_main)                               | [REDIS](v-redis.md) | [redis](https://github.com/Vonng/pigsty/tree/master/roles/redis)                   | G/C/I | main data disk for redis|
| [redis_bind_address](v-redis.md#redis_bind_address)                     | [REDIS](v-redis.md) | [redis](https://github.com/Vonng/pigsty/tree/master/roles/redis)                   | G/C/I | e.g 0.0.0.0, empty will use inventory_hostname as bind address|
| [redis_exists](v-redis.md#redis_exists)                                 | [REDIS](v-redis.md) | [redis](https://github.com/Vonng/pigsty/tree/master/roles/redis)                   | A     | internal flag|
| [redis_exists_action](v-redis.md#redis_exists_action)                   | [REDIS](v-redis.md) | [redis](https://github.com/Vonng/pigsty/tree/master/roles/redis)                   | G/C   | what to do when redis exists|
| [redis_disable_purge](v-redis.md#redis_disable_purge)                   | [REDIS](v-redis.md) | [redis](https://github.com/Vonng/pigsty/tree/master/roles/redis)                   | G/C   | set to true to disable purge functionality for good (force redis_exists_action = abort)|
| [redis_max_memory](v-redis.md#redis_max_memory)                         | [REDIS](v-redis.md) | [redis](https://github.com/Vonng/pigsty/tree/master/roles/redis)                   | G/C   | max memory used by each redis instance|
| [redis_mem_policy](v-redis.md#redis_mem_policy)                         | [REDIS](v-redis.md) | [redis](https://github.com/Vonng/pigsty/tree/master/roles/redis)                   | G/C   | memory eviction policy|
| [redis_password](v-redis.md#redis_password)                             | [REDIS](v-redis.md) | [redis](https://github.com/Vonng/pigsty/tree/master/roles/redis)                   | G/C   | empty password disable password auth (masterauth & requirepass)|
| [redis_rdb_save](v-redis.md#redis_rdb_save)                             | [REDIS](v-redis.md) | [redis](https://github.com/Vonng/pigsty/tree/master/roles/redis)                   | G/C   | redis RDB save directives, empty list disable it|
| [redis_aof_enabled](v-redis.md#redis_aof_enabled)                       | [REDIS](v-redis.md) | [redis](https://github.com/Vonng/pigsty/tree/master/roles/redis)                   | G/C   | enable redis AOF|
| [redis_rename_commands](v-redis.md#redis_rename_commands)               | [REDIS](v-redis.md) | [redis](https://github.com/Vonng/pigsty/tree/master/roles/redis)                   | G/C   | rename dangerous commands|
| [redis_cluster_replicas](v-redis.md#redis_cluster_replicas)             | [REDIS](v-redis.md) | [redis](https://github.com/Vonng/pigsty/tree/master/roles/redis)                   | G/C   | how much replicas per master in redis cluster ?|
| [redis_exporter_enabled](v-redis.md#redis_exporter_enabled)             | [REDIS](v-redis.md) | [redis_exporter](https://github.com/Vonng/pigsty/tree/master/roles/redis_exporter) | G/C   | install redis exporter on redis nodes|
| [redis_exporter_port](v-redis.md#redis_exporter_port)                   | [REDIS](v-redis.md) | [redis_exporter](https://github.com/Vonng/pigsty/tree/master/roles/redis_exporter) | G/C   | default port for redis exporter|
| [redis_exporter_options](v-redis.md#redis_exporter_options)             | [REDIS](v-redis.md) | [redis_exporter](https://github.com/Vonng/pigsty/tree/master/roles/redis_exporter) | G/C   | default cli args for redis exporter|
