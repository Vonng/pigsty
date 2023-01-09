# Parameter

There are 260+ parameters in Pigsty.

|    ID   |  Name                                                        | Module                | Section                               | Type        | Level | Comment                                                      |
|:-------:| ------------------------------------------------------------ | --------------------- | ------------------------------------- |:-----------:|:-----:| ------------------------------------------------------------ |
| **101** | [`version`](#version)                                        | [`INFRA`](#INFRA)     | [`META`](#META)                       | string      | G     | pigsty version string                                        |
| **102** | [`admin_ip`](#admin_ip)                                      | [`INFRA`](#INFRA)     | [`META`](#META)                       | ip          | G     | admin node ip address                                        |
| **103** | [`region`](#region)                                          | [`INFRA`](#INFRA)     | [`META`](#META)                       | enum        | G     | upstream mirror region: default,china,europe                 |
| **104** | [`proxy_env`](#proxy_env)                                    | [`INFRA`](#INFRA)     | [`META`](#META)                       | dict        | G     | global proxy env when downloading packages                   |
| **105** | [`ca_method`](#ca_method)                                    | [`INFRA`](#INFRA)     | [`CA`](#CA)                           | enum        | G     | create,recreate,copy, create by default                      |
| **106** | [`ca_cn`](#ca_cn)                                            | [`INFRA`](#INFRA)     | [`CA`](#CA)                           | string      | G     | ca common name, fixed as pigsty-ca                           |
| **107** | [`cert_validity`](#cert_validity)                            | [`INFRA`](#INFRA)     | [`CA`](#CA)                           | interval    | G     | cert validity, 20 years by default                           |
| **108** | [`infra_seq`](#infra_seq)                                    | [`INFRA`](#INFRA)     | [`INFRA_ID`](#INFRA_ID)               | int         | I     | infra node identity, REQUIRED                                |
| **109** | [`infra_portal`](#infra_portal)                              | [`INFRA`](#INFRA)     | [`INFRA_ID`](#INFRA_ID)               | dict        | G     | infra services exposed via portal                            |
| **110** | [`repo_enabled`](#repo_enabled)                              | [`INFRA`](#INFRA)     | [`REPO`](#REPO)                       | bool        | G/I   | create a yum repo on this infra node?                        |
| **111** | [`repo_home`](#repo_home)                                    | [`INFRA`](#INFRA)     | [`REPO`](#REPO)                       | path        | G     | repo home dir, `/www` by default                             |
| **112** | [`repo_name`](#repo_name)                                    | [`INFRA`](#INFRA)     | [`REPO`](#REPO)                       | string      | G     | repo name, pigsty by default                                 |
| **113** | [`repo_endpoint`](#repo_endpoint)                            | [`INFRA`](#INFRA)     | [`REPO`](#REPO)                       | url         | G     | access point to this repo by domain or ip:port               |
| **114** | [`repo_remove`](#repo_remove)                                | [`INFRA`](#INFRA)     | [`REPO`](#REPO)                       | bool        | G/A   | remove existing upstream repo                                |
| **115** | [`repo_upstream`](#repo_upstream)                            | [`INFRA`](#INFRA)     | [`REPO`](#REPO)                       | upstream[]  | G     | where to download upstream packages                          |
| **116** | [`repo_packages`](#repo_packages)                            | [`INFRA`](#INFRA)     | [`REPO`](#REPO)                       | string[]    | G     | which packages to be included                                |
| **117** | [`repo_url_packages`](#repo_url_packages)                    | [`INFRA`](#INFRA)     | [`REPO`](#REPO)                       | string[]    | G     | extra packages from url                                      |
| **118** | [`infra_packages`](#infra_packages)                          | [`INFRA`](#INFRA)     | [`INFRA_PACKAGE`](#INFRA_PACKAGE)     | string[]    | G     | packages to be installed on infra nodes                      |
| **119** | [`infra_packages_pip`](#infra_packages_pip)                  | [`INFRA`](#INFRA)     | [`INFRA_PACKAGE`](#INFRA_PACKAGE)     | string      | G     | pip installed packages for infra nodes                       |
| **120** | [`nginx_enabled`](#nginx_enabled)                            | [`INFRA`](#INFRA)     | [`NGINX`](#NGINX)                     | bool        | G/I   | enable nginx on this infra node?                             |
| **121** | [`nginx_sslmode`](#nginx_sslmode)                            | [`INFRA`](#INFRA)     | [`NGINX`](#NGINX)                     | enum        | G     | nginx ssl mode? disable,enable,enforce                       |
| **122** | [`nginx_home`](#nginx_home)                                  | [`INFRA`](#INFRA)     | [`NGINX`](#NGINX)                     | path        | G     | nginx content dir, `/www` by default                         |
| **123** | [`nginx_port`](#nginx_port)                                  | [`INFRA`](#INFRA)     | [`NGINX`](#NGINX)                     | port        | G     | nginx listen port, 80 by default                             |
| **124** | [`nginx_ssl_port`](#nginx_ssl_port)                          | [`INFRA`](#INFRA)     | [`NGINX`](#NGINX)                     | port        | G     | nginx ssl listen port, 443 by default                        |
| **222** | [`node_kernel_modules`](#node_kernel_modules)                | [`NODE`](#NODE)       | [`NODE_TUNE`](#NODE_TUNE)             | string[]    | C     | kernel modules to be enabled on this node                    |
| **223** | [`node_hugepage_ratio`](#node_hugepage_ratio)                | [`NODE`](#NODE)       | [`NODE_TUNE`](#NODE_TUNE)             | float       | C     | node mem hugepage ratio, 0 disable it by default             |
| **125** | [`nginx_navbar`](#nginx_navbar)                              | [`INFRA`](#INFRA)     | [`NGINX`](#NGINX)                     | index[]     | G     | nginx index page navigation links                            |
| **126** | [`dns_enabled`](#dns_enabled)                                | [`INFRA`](#INFRA)     | [`DNS`](#DNS)                         | bool        | G/I   | setup dnsmasq on this infra node?                            |
| **127** | [`dns_port`](#dns_port)                                      | [`INFRA`](#INFRA)     | [`DNS`](#DNS)                         | port        | G     | dns server listen port, 53 by default                        |
| **128** | [`dns_records`](#dns_records)                                | [`INFRA`](#INFRA)     | [`DNS`](#DNS)                         | string[]    | G     | dynamic dns records resolved by dnsmasq                      |
| **129** | [`prometheus_enabled`](#prometheus_enabled)                  | [`INFRA`](#INFRA)     | [`PROMETHEUS`](#PROMETHEUS)           | bool        | G/I   | enable prometheus on this infra node?                        |
| **130** | [`prometheus_clean`](#prometheus_clean)                      | [`INFRA`](#INFRA)     | [`PROMETHEUS`](#PROMETHEUS)           | bool        | G/A   | clean prometheus data during init?                           |
| **131** | [`prometheus_data`](#prometheus_data)                        | [`INFRA`](#INFRA)     | [`PROMETHEUS`](#PROMETHEUS)           | path        | G     | prometheus data dir, `/data/prometheus` by default           |
| **132** | [`prometheus_sd_interval`](#prometheus_sd_interval)          | [`INFRA`](#INFRA)     | [`PROMETHEUS`](#PROMETHEUS)           | interval    | G     | prometheus target refresh interval, 5s by default            |
| **133** | [`prometheus_scrape_interval`](#prometheus_scrape_interval)  | [`INFRA`](#INFRA)     | [`PROMETHEUS`](#PROMETHEUS)           | interval    | G     | prometheus scrape & eval interval, 10s by default            |
| **134** | [`prometheus_scrape_timeout`](#prometheus_scrape_timeout)    | [`INFRA`](#INFRA)     | [`PROMETHEUS`](#PROMETHEUS)           | interval    | G     | prometheus global scrape timeout, 8s by default              |
| **135** | [`prometheus_options`](#prometheus_options)                  | [`INFRA`](#INFRA)     | [`PROMETHEUS`](#PROMETHEUS)           | arg         | G     | prometheus extra server options                              |
| **136** | [`pushgateway_enabled`](#pushgateway_enabled)                | [`INFRA`](#INFRA)     | [`PROMETHEUS`](#PROMETHEUS)           | bool        | G/I   | setup pushgateway on this infra node?                        |
| **137** | [`pushgateway_options`](#pushgateway_options)                | [`INFRA`](#INFRA)     | [`PROMETHEUS`](#PROMETHEUS)           | arg         | G     | pushgateway extra server options                             |
| **138** | [`blackbox_enabled`](#blackbox_enabled)                      | [`INFRA`](#INFRA)     | [`PROMETHEUS`](#PROMETHEUS)           | bool        | G/I   | setup blackbox_exporter on this infra node?                  |
| **139** | [`blackbox_options`](#blackbox_options)                      | [`INFRA`](#INFRA)     | [`PROMETHEUS`](#PROMETHEUS)           | arg         | G     | blackbox_exporter extra server options                       |
| **140** | [`alertmanager_enabled`](#alertmanager_enabled)              | [`INFRA`](#INFRA)     | [`PROMETHEUS`](#PROMETHEUS)           | bool        | G/I   | setup alertmanager on this infra node?                       |
| **141** | [`alertmanager_options`](#alertmanager_options)              | [`INFRA`](#INFRA)     | [`PROMETHEUS`](#PROMETHEUS)           | arg         | G     | alertmanager extra server options                            |
| **142** | [`exporter_metrics_path`](#exporter_metrics_path)            | [`INFRA`](#INFRA)     | [`PROMETHEUS`](#PROMETHEUS)           | path        | G     | exporter metric path, `/metrics` by default                  |
| **143** | [`exporter_install`](#exporter_install)                      | [`INFRA`](#INFRA)     | [`PROMETHEUS`](#PROMETHEUS)           | enum        | G     | how to install exporter? none,yum,binary                     |
| **144** | [`exporter_repo_url`](#exporter_repo_url)                    | [`INFRA`](#INFRA)     | [`PROMETHEUS`](#PROMETHEUS)           | url         | G     | exporter repo file url if install exporter via yum           |
| **145** | [`grafana_enabled`](#grafana_enabled)                        | [`INFRA`](#INFRA)     | [`GRAFANA`](#GRAFANA)                 | bool        | G/I   | enable grafana on this infra node?                           |
| **146** | [`grafana_clean`](#grafana_clean)                            | [`INFRA`](#INFRA)     | [`GRAFANA`](#GRAFANA)                 | bool        | G/A   | clean grafana data during init?                              |
| **147** | [`grafana_admin_username`](#grafana_admin_username)          | [`INFRA`](#INFRA)     | [`GRAFANA`](#GRAFANA)                 | username    | G     | grafana admin username, `admin` by default                   |
| **148** | [`grafana_admin_password`](#grafana_admin_password)          | [`INFRA`](#INFRA)     | [`GRAFANA`](#GRAFANA)                 | password    | G     | grafana admin password, `pigsty` by default                  |
| **149** | [`grafana_plugin_cache`](#grafana_plugin_cache)              | [`INFRA`](#INFRA)     | [`GRAFANA`](#GRAFANA)                 | path        | G     | path to grafana plugins cache tarball                        |
| **150** | [`grafana_plugin_list`](#grafana_plugin_list)                | [`INFRA`](#INFRA)     | [`GRAFANA`](#GRAFANA)                 | string[]    | G     | grafana plugins to be downloaded with grafana-cli            |
| **151** | [`loki_enabled`](#loki_enabled)                              | [`INFRA`](#INFRA)     | [`LOKI`](#LOKI)                       | bool        | G/I   | enable loki on this infra node?                              |
| **152** | [`loki_clean`](#loki_clean)                                  | [`INFRA`](#INFRA)     | [`LOKI`](#LOKI)                       | bool        | G/A   | whether remove existing loki data?                           |
| **153** | [`loki_data`](#loki_data)                                    | [`INFRA`](#INFRA)     | [`LOKI`](#LOKI)                       | path        | G     | loki data dir, `/data/loki` by default                       |
| **154** | [`loki_retention`](#loki_retention)                          | [`INFRA`](#INFRA)     | [`LOKI`](#LOKI)                       | interval    | G     | loki log retention period, 15d by default                    |
| **201** | [`nodename`](#nodename)                                      | [`NODE`](#NODE)       | [`NODE_ID`](#NODE_ID)                 | string      | I     | node instance identity, use hostname if missing, optional    |
| **202** | [`node_cluster`](#node_cluster)                              | [`NODE`](#NODE)       | [`NODE_ID`](#NODE_ID)                 | string      | C     | node cluster identity, use 'nodes' if missing, optional      |
| **203** | [`nodename_overwrite`](#nodename_overwrite)                  | [`NODE`](#NODE)       | [`NODE_ID`](#NODE_ID)                 | bool        | C     | overwrite node's hostname with nodename?                     |
| **204** | [`nodename_exchange`](#nodename_exchange)                    | [`NODE`](#NODE)       | [`NODE_ID`](#NODE_ID)                 | bool        | C     | exchange nodename among play hosts?                          |
| **205** | [`node_id_from_pg`](#node_id_from_pg)                        | [`NODE`](#NODE)       | [`NODE_ID`](#NODE_ID)                 | bool        | C     | use postgres identity as node identity if applicable?        |
| **206** | [`node_default_etc_hosts`](#node_default_etc_hosts)          | [`NODE`](#NODE)       | [`NODE_DNS`](#NODE_DNS)               | string[]    | G     | static dns records in `/etc/hosts`                           |
| **207** | [`node_etc_hosts`](#node_etc_hosts)                          | [`NODE`](#NODE)       | [`NODE_DNS`](#NODE_DNS)               | string[]    | C     | extra static dns records in `/etc/hosts`                     |
| **208** | [`node_dns_method`](#node_dns_method)                        | [`NODE`](#NODE)       | [`NODE_DNS`](#NODE_DNS)               | enum        | C     | how to handle dns servers: add,none,overwrite                |
| **209** | [`node_dns_servers`](#node_dns_servers)                      | [`NODE`](#NODE)       | [`NODE_DNS`](#NODE_DNS)               | string[]    | C     | dynamic nameserver in `/etc/resolv.conf`                     |
| **210** | [`node_dns_options`](#node_dns_options)                      | [`NODE`](#NODE)       | [`NODE_DNS`](#NODE_DNS)               | string[]    | C     | dns resolv options in `/etc/resolv.conf`                     |
| **211** | [`node_repo_method`](#node_repo_method)                      | [`NODE`](#NODE)       | [`NODE_PACKAGE`](#NODE_PACKAGE)       | enum        | C     | how to setup node repo: none,local,public                    |
| **212** | [`node_repo_remove`](#node_repo_remove)                      | [`NODE`](#NODE)       | [`NODE_PACKAGE`](#NODE_PACKAGE)       | bool        | C     | remove existing repo on node?                                |
| **213** | [`node_repo_local_urls`](#node_repo_local_urls)              | [`NODE`](#NODE)       | [`NODE_PACKAGE`](#NODE_PACKAGE)       | string[]    | C     | local repo url, if node_repo_method = local                  |
| **214** | [`node_packages`](#node_packages)                            | [`NODE`](#NODE)       | [`NODE_PACKAGE`](#NODE_PACKAGE)       | string[]    | C     | packages to be installed current nodes                       |
| **215** | [`node_default_packages`](#node_default_packages)            | [`NODE`](#NODE)       | [`NODE_PACKAGE`](#NODE_PACKAGE)       | string[]    | G     | default packages to be installed on all nodes                |
| **216** | [`node_disable_firewall`](#node_disable_firewall)            | [`NODE`](#NODE)       | [`NODE_TUNE`](#NODE_TUNE)             | bool        | C     | disable node firewall? true by default                       |
| **217** | [`node_disable_selinux`](#node_disable_selinux)              | [`NODE`](#NODE)       | [`NODE_TUNE`](#NODE_TUNE)             | bool        | C     | disable node selinux? true by default                        |
| **218** | [`node_disable_numa`](#node_disable_numa)                    | [`NODE`](#NODE)       | [`NODE_TUNE`](#NODE_TUNE)             | bool        | C     | disable node numa, reboot required                           |
| **219** | [`node_disable_swap`](#node_disable_swap)                    | [`NODE`](#NODE)       | [`NODE_TUNE`](#NODE_TUNE)             | bool        | C     | disable node swap, use with caution                          |
| **220** | [`node_static_network`](#node_static_network)                | [`NODE`](#NODE)       | [`NODE_TUNE`](#NODE_TUNE)             | bool        | C     | preserve dns resolver settings after reboot                  |
| **221** | [`node_disk_prefetch`](#node_disk_prefetch)                  | [`NODE`](#NODE)       | [`NODE_TUNE`](#NODE_TUNE)             | bool        | C     | setup disk prefetch on HDD to increase performance           |
| **224** | [`node_tune`](#node_tune)                                    | [`NODE`](#NODE)       | [`NODE_TUNE`](#NODE_TUNE)             | enum        | C     | node tuned profile: none,oltp,olap,crit,tiny                 |
| **225** | [`node_sysctl_params`](#node_sysctl_params)                  | [`NODE`](#NODE)       | [`NODE_TUNE`](#NODE_TUNE)             | dict        | C     | sysctl parameters in k:v format in addition to tuned         |
| **226** | [`node_data`](#node_data)                                    | [`NODE`](#NODE)       | [`NODE_ADMIN`](#NODE_ADMIN)           | path        | C     | node main data directory, `/data` by default                 |
| **227** | [`node_admin_enabled`](#node_admin_enabled)                  | [`NODE`](#NODE)       | [`NODE_ADMIN`](#NODE_ADMIN)           | bool        | C     | create a admin user on target node?                          |
| **228** | [`node_admin_uid`](#node_admin_uid)                          | [`NODE`](#NODE)       | [`NODE_ADMIN`](#NODE_ADMIN)           | int         | C     | uid and gid for node admin user                              |
| **229** | [`node_admin_username`](#node_admin_username)                | [`NODE`](#NODE)       | [`NODE_ADMIN`](#NODE_ADMIN)           | username    | C     | name of node admin user, `dba` by default                    |
| **230** | [`node_admin_ssh_exchange`](#node_admin_ssh_exchange)        | [`NODE`](#NODE)       | [`NODE_ADMIN`](#NODE_ADMIN)           | bool        | C     | exchange admin ssh key among node cluster                    |
| **231** | [`node_admin_pk_current`](#node_admin_pk_current)            | [`NODE`](#NODE)       | [`NODE_ADMIN`](#NODE_ADMIN)           | bool        | C     | add current user's ssh pk to admin authorized_keys           |
| **232** | [`node_admin_pk_list`](#node_admin_pk_list)                  | [`NODE`](#NODE)       | [`NODE_ADMIN`](#NODE_ADMIN)           | string[]    | C     | ssh public keys to be added to admin user                    |
| **233** | [`node_timezone`](#node_timezone)                            | [`NODE`](#NODE)       | [`NODE_TIME`](#NODE_TIME)             | string      | C     | setup node timezone, empty string to skip                    |
| **234** | [`node_ntp_enabled`](#node_ntp_enabled)                      | [`NODE`](#NODE)       | [`NODE_TIME`](#NODE_TIME)             | bool        | C     | enable chronyd time sync service?                            |
| **235** | [`node_ntp_servers`](#node_ntp_servers)                      | [`NODE`](#NODE)       | [`NODE_TIME`](#NODE_TIME)             | string[]    | C     | ntp servers in `/etc/chrony.conf`                            |
| **236** | [`node_crontab_overwrite`](#node_crontab_overwrite)          | [`NODE`](#NODE)       | [`NODE_TIME`](#NODE_TIME)             | bool        | C     | overwrite or append to `/etc/crontab`?                       |
| **237** | [`node_crontab`](#node_crontab)                              | [`NODE`](#NODE)       | [`NODE_TIME`](#NODE_TIME)             | string[]    | C     | crontab entries in `/etc/crontab`                            |
| **238** | [`haproxy_enabled`](#haproxy_enabled)                        | [`NODE`](#NODE)       | [`HAPROXY`](#HAPROXY)                 | bool        | C     | enable haproxy on this node?                                 |
| **239** | [`haproxy_clean`](#haproxy_clean)                            | [`NODE`](#NODE)       | [`HAPROXY`](#HAPROXY)                 | bool        | G/C/A | cleanup all existing haproxy config?                         |
| **240** | [`haproxy_reload`](#haproxy_reload)                          | [`NODE`](#NODE)       | [`HAPROXY`](#HAPROXY)                 | bool        | A     | reload haproxy after config?                                 |
| **241** | [`haproxy_auth_enabled`](#haproxy_auth_enabled)              | [`NODE`](#NODE)       | [`HAPROXY`](#HAPROXY)                 | bool        | G     | enable authentication for haproxy admin page                 |
| **242** | [`haproxy_admin_username`](#haproxy_admin_username)          | [`NODE`](#NODE)       | [`HAPROXY`](#HAPROXY)                 | username    | G     | haproxy admin username, `admin` by default                   |
| **243** | [`haproxy_admin_password`](#haproxy_admin_password)          | [`NODE`](#NODE)       | [`HAPROXY`](#HAPROXY)                 | password    | G     | haproxy admin password, `pigsty` by default                  |
| **244** | [`haproxy_exporter_port`](#haproxy_exporter_port)            | [`NODE`](#NODE)       | [`HAPROXY`](#HAPROXY)                 | port        | C     | haproxy admin/exporter port, 9101 by default                 |
| **245** | [`haproxy_client_timeout`](#haproxy_client_timeout)          | [`NODE`](#NODE)       | [`HAPROXY`](#HAPROXY)                 | interval    | C     | client side connection timeout, 24h by default               |
| **246** | [`haproxy_server_timeout`](#haproxy_server_timeout)          | [`NODE`](#NODE)       | [`HAPROXY`](#HAPROXY)                 | interval    | C     | server side connection timeout, 24h by default               |
| **247** | [`haproxy_services`](#haproxy_services)                      | [`NODE`](#NODE)       | [`HAPROXY`](#HAPROXY)                 | service[]   | C     | list of haproxy service to be exposed on node                |
| **248** | [`docker_enabled`](#docker_enabled)                          | [`NODE`](#NODE)       | [`DOCKER`](#DOCKER)                   | bool        | C     | enable docker on this node?                                  |
| **249** | [`docker_cgroups_driver`](#docker_cgroups_driver)            | [`NODE`](#NODE)       | [`DOCKER`](#DOCKER)                   | enum        | C     | docker cgroup fs driver: cgroupfs,systemd                    |
| **250** | [`docker_registry_mirrors`](#docker_registry_mirrors)        | [`NODE`](#NODE)       | [`DOCKER`](#DOCKER)                   | string[]    | C     | docker registry mirror list                                  |
| **251** | [`docker_image_cache`](#docker_image_cache)                  | [`NODE`](#NODE)       | [`DOCKER`](#DOCKER)                   | path        | C     | docker image cache dir, `/tmp/docker` by default             |
| **252** | [`node_exporter_enabled`](#node_exporter_enabled)            | [`NODE`](#NODE)       | [`NODE_EXPORTER`](#NODE_EXPORTER)     | bool        | C     | setup node_exporter on this node?                            |
| **253** | [`node_exporter_port`](#node_exporter_port)                  | [`NODE`](#NODE)       | [`NODE_EXPORTER`](#NODE_EXPORTER)     | port        | C     | node exporter listen port, 9100 by default                   |
| **254** | [`node_exporter_options`](#node_exporter_options)            | [`NODE`](#NODE)       | [`NODE_EXPORTER`](#NODE_EXPORTER)     | arg         | C     | extra server options for node_exporter                       |
| **255** | [`promtail_enabled`](#promtail_enabled)                      | [`NODE`](#NODE)       | [`PROMTAIL`](#PROMTAIL)               | bool        | C     | enable promtail logging collector?                           |
| **256** | [`promtail_clean`](#promtail_clean)                          | [`NODE`](#NODE)       | [`PROMTAIL`](#PROMTAIL)               | bool        | G/A   | purge existing promtail status file during init?             |
| **257** | [`promtail_port`](#promtail_port)                            | [`NODE`](#NODE)       | [`PROMTAIL`](#PROMTAIL)               | port        | C     | promtail listen port, 9080 by default                        |
| **258** | [`promtail_positions`](#promtail_positions)                  | [`NODE`](#NODE)       | [`PROMTAIL`](#PROMTAIL)               | path        | C     | promtail position status file path                           |
| **301** | [`etcd_seq`](#etcd_seq)                                      | [`ETCD`](#ETCD)       | [`ETCD`](#ETCD)                       | int         | I     | etcd instance identifier, REQUIRED                           |
| **302** | [`etcd_cluster`](#etcd_cluster)                              | [`ETCD`](#ETCD)       | [`ETCD`](#ETCD)                       | string      | C     | etcd cluster & group name, etcd by default                   |
| **303** | [`etcd_safeguard`](#etcd_safeguard)                          | [`ETCD`](#ETCD)       | [`ETCD`](#ETCD)                       | bool        | G/C/A | prevent purging running etcd instance?                       |
| **304** | [`etcd_clean`](#etcd_clean)                                  | [`ETCD`](#ETCD)       | [`ETCD`](#ETCD)                       | bool        | G/C/A | purging existing etcd during initialization?                 |
| **305** | [`etcd_data`](#etcd_data)                                    | [`ETCD`](#ETCD)       | [`ETCD`](#ETCD)                       | path        | C     | etcd data directory, /data/etcd by default                   |
| **306** | [`etcd_port`](#etcd_port)                                    | [`ETCD`](#ETCD)       | [`ETCD`](#ETCD)                       | port        | C     | etcd client port, 2379 by default                            |
| **307** | [`etcd_peer_port`](#etcd_peer_port)                          | [`ETCD`](#ETCD)       | [`ETCD`](#ETCD)                       | port        | C     | etcd peer port, 2380 by default                              |
| **308** | [`etcd_init`](#etcd_init)                                    | [`ETCD`](#ETCD)       | [`ETCD`](#ETCD)                       | enum        | C     | etcd initial cluster state, new or existing                  |
| **309** | [`etcd_election_timeout`](#etcd_election_timeout)            | [`ETCD`](#ETCD)       | [`ETCD`](#ETCD)                       | int         | C     | etcd election timeout, 1000ms by default                     |
| **310** | [`etcd_heartbeat_interval`](#etcd_heartbeat_interval)        | [`ETCD`](#ETCD)       | [`ETCD`](#ETCD)                       | int         | C     | etcd heartbeat interval, 100ms by default                    |
| **401** | [`minio_seq`](#minio_seq)                                    | [`MINIO`](#MINIO)     | [`MINIO`](#MINIO)                     | int         | I     | minio instance identifier, REQUIRED                          |
| **402** | [`minio_cluster`](#minio_cluster)                            | [`MINIO`](#MINIO)     | [`MINIO`](#MINIO)                     | string      | C     | minio cluster name, minio by default                         |
| **403** | [`minio_clean`](#minio_clean)                                | [`MINIO`](#MINIO)     | [`MINIO`](#MINIO)                     | bool        | G/C/A | cleanup minio during init?, false by default                 |
| **404** | [`minio_user`](#minio_user)                                  | [`MINIO`](#MINIO)     | [`MINIO`](#MINIO)                     | username    | C     | minio os user, `minio` by default                            |
| **405** | [`minio_node`](#minio_node)                                  | [`MINIO`](#MINIO)     | [`MINIO`](#MINIO)                     | string      | C     | minio node name pattern                                      |
| **406** | [`minio_data`](#minio_data)                                  | [`MINIO`](#MINIO)     | [`MINIO`](#MINIO)                     | path        | C     | minio data dir(s), use {x...y} to specify multi drivers      |
| **407** | [`minio_domain`](#minio_domain)                              | [`MINIO`](#MINIO)     | [`MINIO`](#MINIO)                     | string      | G     | minio external domain name, `sss.pigsty` by default          |
| **408** | [`minio_port`](#minio_port)                                  | [`MINIO`](#MINIO)     | [`MINIO`](#MINIO)                     | port        | C     | minio service port, 9000 by default                          |
| **409** | [`minio_admin_port`](#minio_admin_port)                      | [`MINIO`](#MINIO)     | [`MINIO`](#MINIO)                     | port        | C     | minio console port, 9001 by default                          |
| **410** | [`minio_access_key`](#minio_access_key)                      | [`MINIO`](#MINIO)     | [`MINIO`](#MINIO)                     | username    | C     | root access key, `minioadmin` by default                     |
| **411** | [`minio_secret_key`](#minio_secret_key)                      | [`MINIO`](#MINIO)     | [`MINIO`](#MINIO)                     | password    | C     | root secret key, `minioadmin` by default                     |
| **412** | [`minio_extra_vars`](#minio_extra_vars)                      | [`MINIO`](#MINIO)     | [`MINIO`](#MINIO)                     | string      | C     | extra environment variables for minio server                 |
| **413** | [`minio_alias`](#minio_alias)                                | [`MINIO`](#MINIO)     | [`MINIO`](#MINIO)                     | string      | G     | alias name for local minio deployment                        |
| **414** | [`minio_buckets`](#minio_buckets)                            | [`MINIO`](#MINIO)     | [`MINIO`](#MINIO)                     | bucket[]    | C     | list of minio bucket to be created                           |
| **415** | [`minio_users`](#minio_users)                                | [`MINIO`](#MINIO)     | [`MINIO`](#MINIO)                     | user[]      | C     | list of minio user to be created                             |
| **501** | [`pg_cluster`](#pg_cluster)                                  | [`PGSQL`](#PGSQL)     | [`PG_ID`](#PG_ID)                     | string      | C     | pgsql cluster name, REQUIRED identity parameter              |
| **502** | [`pg_seq`](#pg_seq)                                          | [`PGSQL`](#PGSQL)     | [`PG_ID`](#PG_ID)                     | int         | I     | pgsql instance seq number, REQUIRED identity parameter       |
| **503** | [`pg_role`](#pg_role)                                        | [`PGSQL`](#PGSQL)     | [`PG_ID`](#PG_ID)                     | enum        | I     | pgsql role, REQUIRED, could be primary,replica,offline       |
| **504** | [`pg_instances`](#pg_instances)                              | [`PGSQL`](#PGSQL)     | [`PG_ID`](#PG_ID)                     | dict        | I     | define multiple pg instances on node in `{port:ins_vars}` format |
| **505** | [`pg_upstream`](#pg_upstream)                                | [`PGSQL`](#PGSQL)     | [`PG_ID`](#PG_ID)                     | ip          | I     | repl upstream ip addr for standby cluster or cascade replica |
| **506** | [`pg_shard`](#pg_shard)                                      | [`PGSQL`](#PGSQL)     | [`PG_ID`](#PG_ID)                     | string      | C     | pgsql shard name, optional identity for sharding clusters    |
| **507** | [`pg_sindex`](#pg_sindex)                                    | [`PGSQL`](#PGSQL)     | [`PG_ID`](#PG_ID)                     | int         | C     | pgsql shard index, optional identity for sharding clusters   |
| **508** | [`gp_role`](#gp_role)                                        | [`PGSQL`](#PGSQL)     | [`PG_ID`](#PG_ID)                     | enum        | C     | greenplum role of this cluster, could be master or segment   |
| **509** | [`pg_exporters`](#pg_exporters)                              | [`PGSQL`](#PGSQL)     | [`PG_ID`](#PG_ID)                     | dict        | C     | additional pg_exporters to monitor remote postgres instances |
| **510** | [`pg_offline_query`](#pg_offline_query)                      | [`PGSQL`](#PGSQL)     | [`PG_ID`](#PG_ID)                     | bool        | G     | set to true to enable offline query on this instance         |
| **511** | [`pg_weight`](#pg_weight)                                    | [`PGSQL`](#PGSQL)     | [`PG_ID`](#PG_ID)                     | int         | G     | relative load balance weight in service, 100 by default, 0-255 |
| **512** | [`pg_users`](#pg_users)                                      | [`PGSQL`](#PGSQL)     | [`PG_BUSINESS`](#PG_BUSINESS)         | user[]      | C     | postgres business users                                      |
| **513** | [`pg_databases`](#pg_databases)                              | [`PGSQL`](#PGSQL)     | [`PG_BUSINESS`](#PG_BUSINESS)         | database[]  | C     | postgres business databases                                  |
| **514** | [`pg_services`](#pg_services)                                | [`PGSQL`](#PGSQL)     | [`PG_BUSINESS`](#PG_BUSINESS)         | service[]   | C     | postgres business services                                   |
| **515** | [`pg_hba_rules`](#pg_hba_rules)                              | [`PGSQL`](#PGSQL)     | [`PG_BUSINESS`](#PG_BUSINESS)         | hba[]       | C     | business hba rules for postgres                              |
| **516** | [`pgb_hba_rules`](#pgb_hba_rules)                            | [`PGSQL`](#PGSQL)     | [`PG_BUSINESS`](#PG_BUSINESS)         | hba[]       | C     | business hba rules for pgbouncer                             |
| **517** | [`pg_replication_username`](#pg_replication_username)        | [`PGSQL`](#PGSQL)     | [`PG_BUSINESS`](#PG_BUSINESS)         | username    | G     | postgres replication username, `replicator` by default       |
| **518** | [`pg_replication_password`](#pg_replication_password)        | [`PGSQL`](#PGSQL)     | [`PG_BUSINESS`](#PG_BUSINESS)         | password    | G     | postgres replication password, `DBUser.Replicator` by default |
| **519** | [`pg_admin_username`](#pg_admin_username)                    | [`PGSQL`](#PGSQL)     | [`PG_BUSINESS`](#PG_BUSINESS)         | username    | G     | postgres admin username, `dbuser_dba` by default             |
| **520** | [`pg_admin_password`](#pg_admin_password)                    | [`PGSQL`](#PGSQL)     | [`PG_BUSINESS`](#PG_BUSINESS)         | password    | G     | postgres admin password in plain text, `DBUser.DBA` by default |
| **521** | [`pg_monitor_username`](#pg_monitor_username)                | [`PGSQL`](#PGSQL)     | [`PG_BUSINESS`](#PG_BUSINESS)         | username    | G     | postgres monitor username, `dbuser_monitor` by default       |
| **522** | [`pg_monitor_password`](#pg_monitor_password)                | [`PGSQL`](#PGSQL)     | [`PG_BUSINESS`](#PG_BUSINESS)         | password    | G     | postgres monitor password, `DBUser.Monitor` by default       |
| **523** | [`pg_dbsu`](#pg_dbsu)                                        | [`PGSQL`](#PGSQL)     | [`PG_INSTALL`](#PG_INSTALL)           | username    | C     | os dbsu name, postgres by default, better not change it      |
| **524** | [`pg_dbsu_uid`](#pg_dbsu_uid)                                | [`PGSQL`](#PGSQL)     | [`PG_INSTALL`](#PG_INSTALL)           | int         | C     | os dbsu uid and gid, 26 for default postgres users and groups |
| **525** | [`pg_dbsu_sudo`](#pg_dbsu_sudo)                              | [`PGSQL`](#PGSQL)     | [`PG_INSTALL`](#PG_INSTALL)           | enum        | C     | dbsu sudo privilege, none,limit,all,nopass. limit by default |
| **526** | [`pg_dbsu_home`](#pg_dbsu_home)                              | [`PGSQL`](#PGSQL)     | [`PG_INSTALL`](#PG_INSTALL)           | path        | C     | postgresql home directory, `/var/lib/pgsql` by default       |
| **527** | [`pg_dbsu_ssh_exchange`](#pg_dbsu_ssh_exchange)              | [`PGSQL`](#PGSQL)     | [`PG_INSTALL`](#PG_INSTALL)           | bool        | C     | exchange postgres dbsu ssh key among same pgsql cluster      |
| **528** | [`pg_version`](#pg_version)                                  | [`PGSQL`](#PGSQL)     | [`PG_INSTALL`](#PG_INSTALL)           | enum        | C     | postgres major version to be installed, 15 by default        |
| **529** | [`pg_bin_dir`](#pg_bin_dir)                                  | [`PGSQL`](#PGSQL)     | [`PG_INSTALL`](#PG_INSTALL)           | path        | C     | postgres binary dir, `/usr/pgsql/bin` by default             |
| **530** | [`pg_log_dir`](#pg_log_dir)                                  | [`PGSQL`](#PGSQL)     | [`PG_INSTALL`](#PG_INSTALL)           | path        | C     | postgres log dir, `/pg/log/postgres` by default              |
| **531** | [`pg_packages`](#pg_packages)                                | [`PGSQL`](#PGSQL)     | [`PG_INSTALL`](#PG_INSTALL)           | string[]    | C     | pg packages to be installed, `${pg_version}` will be replaced |
| **532** | [`pg_extensions`](#pg_extensions)                            | [`PGSQL`](#PGSQL)     | [`PG_INSTALL`](#PG_INSTALL)           | string[]    | C     | pg extensions to be installed, `${pg_version}` will be replaced |
| **533** | [`pg_safeguard`](#pg_safeguard)                              | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | bool        | G/C/A | prevent purging running postgres instance? false by default  |
| **534** | [`pg_clean`](#pg_clean)                                      | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | bool        | G/C/A | purging existing postgres during pgsql init? true by default |
| **535** | [`pg_data`](#pg_data)                                        | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | path        | C     | postgres data directory, `/pg/data` by default               |
| **536** | [`pg_fs_main`](#pg_fs_main)                                  | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | path        | C     | mountpoint/path for postgres main data, `/data` by default   |
| **537** | [`pg_fs_bkup`](#pg_fs_bkup)                                  | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | path        | C     | mountpoint/path for pg backup data, `/data/backup` by default |
| **538** | [`pg_storage_type`](#pg_storage_type)                        | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | enum        | C     | storage type for pg main data, SSD,HDD, SSD by default       |
| **539** | [`pg_dummy_filesize`](#pg_dummy_filesize)                    | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | size        | C     | size of `/pg/dummy`, hold 64MB disk space for emergency use  |
| **540** | [`pg_listen`](#pg_listen)                                    | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | ip          | C     | postgres listen address, `0.0.0.0` (all ipv4 addr) by defaul |
| **541** | [`pg_port`](#pg_port)                                        | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | port        | C     | postgres listen port, 5432 by default                        |
| **542** | [`pg_localhost`](#pg_localhost)                              | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | path        | C     | postgres unix socket dir for localhost connection            |
| **543** | [`pg_namespace`](#pg_namespace)                              | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | path        | C     | top level key namespace in etcd, used by patroni & vip       |
| **544** | [`patroni_enabled`](#patroni_enabled)                        | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | bool        | C     | if disabled, no postgres cluster will be created during init |
| **545** | [`patroni_mode`](#patroni_mode)                              | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | enum        | C     | patroni working mode: default,pause,remove                   |
| **546** | [`patroni_port`](#patroni_port)                              | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | port        | C     | patroni listen port, 8008 by default                         |
| **547** | [`patroni_log_dir`](#patroni_log_dir)                        | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | path        | C     | patroni log dir, `/pg/log/patroni` by default                |
| **548** | [`patroni_ssl_enabled`](#patroni_ssl_enabled)                | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | bool        | G     | secure patroni RestAPI communications with SSL?              |
| **549** | [`patroni_watchdog_mode`](#patroni_watchdog_mode)            | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | bool        | C     | patroni watchdog mode: automatic,required,off. off by default |
| **550** | [`patroni_username`](#patroni_username)                      | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | username    | C     | patroni restapi username, `postgres` by default              |
| **551** | [`patroni_password`](#patroni_password)                      | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | password    | C     | patroni restapi password, `Patroni.API` by default           |
| **552** | [`pg_conf`](#pg_conf)                                        | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | enum        | C     | config template: oltp,olap,crit,tiny. `oltp.yml` by default  |
| **553** | [`pg_max_conn`](#pg_max_conn)                                | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | int         | C     | postgres max connections, `auto` will use recommended value  |
| **554** | [`pg_shmem_ratio`](#pg_shmem_ratio)                          | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | float       | C     | postgres shared memory ratio, 0.25 by default, 0.1~0.4       |
| **555** | [`pg_rto`](#pg_rto)                                          | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | int         | C     | recovery time objective in seconds, `30s` by default         |
| **556** | [`pg_rpo`](#pg_rpo)                                          | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | int         | C     | recovery point objective in bytes, `1MiB` at most by default |
| **557** | [`pg_libs`](#pg_libs)                                        | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | string      | C     | preloaded libraries, `pg_stat_statements,auto_explain` by default |
| **558** | [`pg_delay`](#pg_delay)                                      | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | interval    | I     | replication apply delay for standby cluster leader           |
| **559** | [`pg_checksum`](#pg_checksum)                                | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | bool        | C     | enable data checksum for postgres cluster?                   |
| **560** | [`pg_pwd_enc`](#pg_pwd_enc)                                  | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | enum        | C     | passwords encryption algorithm: md5,scram-sha-256            |
| **561** | [`pg_encoding`](#pg_encoding)                                | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | enum        | C     | database cluster encoding, `UTF8` by default                 |
| **562** | [`pg_locale`](#pg_locale)                                    | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | enum        | C     | database cluster local, `C` by default                       |
| **563** | [`pg_lc_collate`](#pg_lc_collate)                            | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | enum        | C     | database cluster collate, `C` by default                     |
| **564** | [`pg_lc_ctype`](#pg_lc_ctype)                                | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | enum        | C     | database character type, `en_US.UTF8` by default             |
| **565** | [`pgbouncer_enabled`](#pgbouncer_enabled)                    | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | bool        | C     | if disabled, pgbouncer will not be launched on pgsql host    |
| **566** | [`pgbouncer_port`](#pgbouncer_port)                          | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | port        | C     | pgbouncer listen port, 6432 by default                       |
| **567** | [`pgbouncer_log_dir`](#pgbouncer_log_dir)                    | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | path        | C     | pgbouncer log dir, `/pg/log/pgbouncer` by default            |
| **568** | [`pgbouncer_auth_query`](#pgbouncer_auth_query)              | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | bool        | C     | query postgres to retrieve unlisted business users?          |
| **569** | [`pgbouncer_poolmode`](#pgbouncer_poolmode)                  | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | enum        | C     | pooling mode: transaction,session,statement, transaction by default |
| **570** | [`pgbouncer_sslmode`](#pgbouncer_sslmode)                    | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | enum        | C     | pgbouncer client ssl mode, disable by default                |
| **571** | [`pg_provision`](#pg_provision)                              | [`PGSQL`](#PGSQL)     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)       | bool        | C     | provision postgres cluster after bootstrap                   |
| **572** | [`pg_init`](#pg_init)                                        | [`PGSQL`](#PGSQL)     | [`PG_PROVISION`](#PG_PROVISION)       | string      | G/C   | provision init script for cluster template, `pg-init` by default |
| **573** | [`pg_default_roles`](#pg_default_roles)                      | [`PGSQL`](#PGSQL)     | [`PG_PROVISION`](#PG_PROVISION)       | role[]      | G/C   | default roles and users in postgres cluster                  |
| **574** | [`pg_default_privileges`](#pg_default_privileges)            | [`PGSQL`](#PGSQL)     | [`PG_PROVISION`](#PG_PROVISION)       | string[]    | G/C   | default privileges when created by admin user                |
| **575** | [`pg_default_schemas`](#pg_default_schemas)                  | [`PGSQL`](#PGSQL)     | [`PG_PROVISION`](#PG_PROVISION)       | string[]    | G/C   | default schemas to be created                                |
| **576** | [`pg_default_extensions`](#pg_default_extensions)            | [`PGSQL`](#PGSQL)     | [`PG_PROVISION`](#PG_PROVISION)       | extension[] | G/C   | default extensions to be created                             |
| **577** | [`pg_reload`](#pg_reload)                                    | [`PGSQL`](#PGSQL)     | [`PG_PROVISION`](#PG_PROVISION)       | bool        | A     | reload postgres after hba changes                            |
| **702** | [`redis_instances`](#redis_instances)                        | [`REDIS`](#REDIS)     | [`REDIS_ID`](#REDIS_ID)               | dict        | I     | redis instances definition on this redis node                |
| **703** | [`redis_node`](#redis_node)                                  | [`REDIS`](#REDIS)     | [`REDIS_ID`](#REDIS_ID)               | int         | I     | redis node sequence number, node int id required             |
| **704** | [`redis_fs_main`](#redis_fs_main)                            | [`REDIS`](#REDIS)     | [`REDIS_NODE`](#REDIS_NODE)           | path        | C     | redis main data mountpoint, `/data` by default               |
| **705** | [`redis_exporter_enabled`](#redis_exporter_enabled)          | [`REDIS`](#REDIS)     | [`REDIS_NODE`](#REDIS_NODE)           | bool        | C     | install redis exporter on redis nodes?                       |
| **706** | [`redis_exporter_port`](#redis_exporter_port)                | [`REDIS`](#REDIS)     | [`REDIS_NODE`](#REDIS_NODE)           | port        | C     | redis exporter listen port, 9121 by default                  |
| **707** | [`redis_exporter_options`](#redis_exporter_options)          | [`REDIS`](#REDIS)     | [`REDIS_NODE`](#REDIS_NODE)           | string      | C/I   | cli args and extra options for redis exporter                |
| **708** | [`redis_safeguard`](#redis_safeguard)                        | [`REDIS`](#REDIS)     | [`REDIS_PROVISION`](#REDIS_PROVISION) | bool        | C     | prevent purging running redis instance?                      |
| **709** | [`redis_clean`](#redis_clean)                                | [`REDIS`](#REDIS)     | [`REDIS_PROVISION`](#REDIS_PROVISION) | bool        | C     | purging existing redis during init?                          |
| **710** | [`redis_rmdata`](#redis_rmdata)                              | [`REDIS`](#REDIS)     | [`REDIS_PROVISION`](#REDIS_PROVISION) | bool        | A     | remove redis data when purging redis server?                 |
| **711** | [`redis_mode`](#redis_mode)                                  | [`REDIS`](#REDIS)     | [`REDIS_PROVISION`](#REDIS_PROVISION) | enum        | C     | redis mode: standalone,cluster,sentinel                      |
| **578** | [`pg_default_hba_rules`](#pg_default_hba_rules)              | [`PGSQL`](#PGSQL)     | [`PG_PROVISION`](#PG_PROVISION)       | hba[]       | G/C   | postgres default host-based authentication rules             |
| **579** | [`pgb_default_hba_rules`](#pgb_default_hba_rules)            | [`PGSQL`](#PGSQL)     | [`PG_PROVISION`](#PG_PROVISION)       | hba[]       | G/C   | pgbouncer default host-based authentication rules            |
| **580** | [`pg_default_service_dest`](#pg_default_service_dest)        | [`PGSQL`](#PGSQL)     | [`PG_PROVISION`](#PG_PROVISION)       | enum        | G/C   | default service destination if svc.dest='default'            |
| **581** | [`pg_default_services`](#pg_default_services)                | [`PGSQL`](#PGSQL)     | [`PG_PROVISION`](#PG_PROVISION)       | service[]   | G/C   | postgres default service definitions                         |
| **582** | [`pgbackrest_enabled`](#pgbackrest_enabled)                  | [`PGSQL`](#PGSQL)     | [`PG_BACKUP`](#PG_BACKUP)             | bool        | C     | enable pgbackrest on pgsql host?                             |
| **583** | [`pgbackrest_clean`](#pgbackrest_clean)                      | [`PGSQL`](#PGSQL)     | [`PG_BACKUP`](#PG_BACKUP)             | bool        | C     | remove pg backup data during init?                           |
| **584** | [`pgbackrest_log_dir`](#pgbackrest_log_dir)                  | [`PGSQL`](#PGSQL)     | [`PG_BACKUP`](#PG_BACKUP)             | path        | C     | pgbackrest log dir, `/pg/log/pgbackrest` by default          |
| **585** | [`pgbackrest_method`](#pgbackrest_method)                    | [`PGSQL`](#PGSQL)     | [`PG_BACKUP`](#PG_BACKUP)             | enum        | C     | pgbackrest repo method: local,minio,[user-defined...]        |
| **586** | [`pgbackrest_repo`](#pgbackrest_repo)                        | [`PGSQL`](#PGSQL)     | [`PG_BACKUP`](#PG_BACKUP)             | dict        | G/C   | pgbackrest repo: https://pgbackrest.org/configuration.html#section-repository |
| **587** | [`pg_vip_enabled`](#pg_vip_enabled)                          | [`PGSQL`](#PGSQL)     | [`PG_VIP`](#PG_VIP)                   | bool        | C     | enable a l2 vip for pgsql primary? false by default          |
| **588** | [`pg_vip_address`](#pg_vip_address)                          | [`PGSQL`](#PGSQL)     | [`PG_VIP`](#PG_VIP)                   | cidr4       | C     | vip address in `<ipv4>/<mask>` format, require if vip is enabled |
| **589** | [`pg_vip_interface`](#pg_vip_interface)                      | [`PGSQL`](#PGSQL)     | [`PG_VIP`](#PG_VIP)                   | string      | C/I   | vip network interface to listen, eth0 by default             |
| **590** | [`pg_dns_suffix`](#pg_dns_suffix)                            | [`PGSQL`](#PGSQL)     | [`PG_DNS`](#PG_DNS)                   | string      | C     | pgsql dns suffix, '' by default                              |
| **591** | [`pg_dns_target`](#pg_dns_target)                            | [`PGSQL`](#PGSQL)     | [`PG_DNS`](#PG_DNS)                   | enum        | C     | auto, primary, vip, none, or ad hoc ip                       |
| **592** | [`pg_exporter_enabled`](#pg_exporter_enabled)                | [`PGSQL`](#PGSQL)     | [`PG_EXPORTER`](#PG_EXPORTER)         | bool        | C     | enable pg_exporter on pgsql hosts?                           |
| **593** | [`pg_exporter_config`](#pg_exporter_config)                  | [`PGSQL`](#PGSQL)     | [`PG_EXPORTER`](#PG_EXPORTER)         | string      | C     | pg_exporter configuration file name                          |
| **594** | [`pg_exporter_cache_ttls`](#pg_exporter_cache_ttls)          | [`PGSQL`](#PGSQL)     | [`PG_EXPORTER`](#PG_EXPORTER)         | string      | C     | pg_exporter collector ttl stage in seconds, '1,10,60,300' by default |
| **595** | [`pg_exporter_port`](#pg_exporter_port)                      | [`PGSQL`](#PGSQL)     | [`PG_EXPORTER`](#PG_EXPORTER)         | port        | C     | pg_exporter listen port, 9630 by default                     |
| **596** | [`pg_exporter_params`](#pg_exporter_params)                  | [`PGSQL`](#PGSQL)     | [`PG_EXPORTER`](#PG_EXPORTER)         | string      | C     | extra url parameters for pg_exporter dsn                     |
| **597** | [`pg_exporter_url`](#pg_exporter_url)                        | [`PGSQL`](#PGSQL)     | [`PG_EXPORTER`](#PG_EXPORTER)         | pgurl       | C     | overwrite auto-generate pg dsn if specified                  |
| **598** | [`pg_exporter_auto_discovery`](#pg_exporter_auto_discovery)  | [`PGSQL`](#PGSQL)     | [`PG_EXPORTER`](#PG_EXPORTER)         | bool        | C     | enable auto database discovery? enabled by default           |
| **599** | [`pg_exporter_exclude_database`](#pg_exporter_exclude_database) | [`PGSQL`](#PGSQL)     | [`PG_EXPORTER`](#PG_EXPORTER)         | string      | C     | csv of database that WILL NOT be monitored during auto-discovery |
| **600** | [`pg_exporter_include_database`](#pg_exporter_include_database) | [`PGSQL`](#PGSQL)     | [`PG_EXPORTER`](#PG_EXPORTER)         | string      | C     | csv of database that WILL BE monitored during auto-discovery |
| **601** | [`pg_exporter_connect_timeout`](#pg_exporter_connect_timeout) | [`PGSQL`](#PGSQL)     | [`PG_EXPORTER`](#PG_EXPORTER)         | int         | C     | pg_exporter connect timeout in ms, 200 by default            |
| **602** | [`pg_exporter_options`](#pg_exporter_options)                | [`PGSQL`](#PGSQL)     | [`PG_EXPORTER`](#PG_EXPORTER)         | arg         | C     | overwrite extra options for pg_exporter                      |
| **603** | [`pgbouncer_exporter_enabled`](#pgbouncer_exporter_enabled)  | [`PGSQL`](#PGSQL)     | [`PG_EXPORTER`](#PG_EXPORTER)         | bool        | C     | enable pgbouncer_exporter on pgsql hosts?                    |
| **604** | [`pgbouncer_exporter_port`](#pgbouncer_exporter_port)        | [`PGSQL`](#PGSQL)     | [`PG_EXPORTER`](#PG_EXPORTER)         | port        | C     | pgbouncer_exporter listen port, 9631 by default              |
| **605** | [`pgbouncer_exporter_url`](#pgbouncer_exporter_url)          | [`PGSQL`](#PGSQL)     | [`PG_EXPORTER`](#PG_EXPORTER)         | pgurl       | C     | overwrite auto-generate pgbouncer dsn if specified           |
| **606** | [`pgbouncer_exporter_options`](#pgbouncer_exporter_options)  | [`PGSQL`](#PGSQL)     | [`PG_EXPORTER`](#PG_EXPORTER)         | arg         | C     | overwrite extra options for pgbouncer_exporter               |
| **701** | [`redis_cluster`](#redis_cluster)                            | [`REDIS`](#REDIS)     | [`REDIS_ID`](#REDIS_ID)               | string      | C     | redis cluster name, required identity parameter              |
| **712** | [`redis_conf`](#redis_conf)                                  | [`REDIS`](#REDIS)     | [`REDIS_PROVISION`](#REDIS_PROVISION) | string      | C     | redis config template path, except sentinel                  |
| **713** | [`redis_bind_address`](#redis_bind_address)                  | [`REDIS`](#REDIS)     | [`REDIS_PROVISION`](#REDIS_PROVISION) | ip          | C     | redis bind address, empty string will use host ip            |
| **714** | [`redis_max_memory`](#redis_max_memory)                      | [`REDIS`](#REDIS)     | [`REDIS_PROVISION`](#REDIS_PROVISION) | size        | C/I   | max memory used by each redis instance                       |
| **715** | [`redis_mem_policy`](#redis_mem_policy)                      | [`REDIS`](#REDIS)     | [`REDIS_PROVISION`](#REDIS_PROVISION) | enum        | C     | redis memory eviction policy                                 |
| **716** | [`redis_password`](#redis_password)                          | [`REDIS`](#REDIS)     | [`REDIS_PROVISION`](#REDIS_PROVISION) | password    | C     | redis password, empty string will disable password           |
| **717** | [`redis_rdb_save`](#redis_rdb_save)                          | [`REDIS`](#REDIS)     | [`REDIS_PROVISION`](#REDIS_PROVISION) | string[]    | C     | redis rdb save directives, disable with empty list           |
| **718** | [`redis_aof_enabled`](#redis_aof_enabled)                    | [`REDIS`](#REDIS)     | [`REDIS_PROVISION`](#REDIS_PROVISION) | bool        | C     | enable redis append only file?                               |
| **719** | [`redis_rename_commands`](#redis_rename_commands)            | [`REDIS`](#REDIS)     | [`REDIS_PROVISION`](#REDIS_PROVISION) | dict        | C     | rename redis dangerous commands                              |
| **720** | [`redis_cluster_replicas`](#redis_cluster_replicas)          | [`REDIS`](#REDIS)     | [`REDIS_PROVISION`](#REDIS_PROVISION) | int         | C     | replica number for one master in redis cluster               |










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
- postgresql15* postgis33_15* citus_15* sqlite_fdw_15 wal2json_15 # timescaledb-2-postgresql-15*
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
  - postgresql15* postgis33_15* citus_15* sqlite_fdw_15 wal2json_15 # timescaledb-2-postgresql-15*
```

</details>


<details><summary>RHEL9 repo packages</summary>

```yaml
repo_packages:
  - grafana loki logcli promtail prometheus2 alertmanager pushgateway blackbox_exporter node_exporter redis_exporter
  - nginx wget createrepo_c sshpass ansible python3 python3-pip python3-requests mtail dnsmasq docker-ce etcd
  - lz4 unzip bzip2 zlib yum pv jq git ncdu make patch bash lsof wget uuid tuned chrony perf nvme-cli numactl grubby sysstat iotop htop
  - netcat socat rsync ftp lrzsz s3cmd net-tools tcpdump ipvsadm bind-utils telnet audit ca-certificates openssl openssh-clients readline vim-minimal
  - postgresql15* postgis33_15* citus_15* pglogical_15* pg_repack_15* pg_squeeze_15* wal2json_15* timescaledb-tools #timescaledb-2-postgresql-15
  - patroni patroni-etcd pgbouncer pgbadger pgbackrest tail_n_mail pgloader pg_activity
  - orafce_15* mysqlcompat_15 mongo_fdw_15* tds_fdw_15* mysql_fdw_15 hdfs_fdw_15 sqlite_fdw_15 pgbouncer_fdw_15 pg_dbms_job_15
  - pg_stat_kcache_15* pg_stat_monitor_15* pg_qualstats_15 pg_track_settings_15 pg_wait_sampling_15 system_stats_15 logerrors_15 pg_top_15
  - plprofiler_15* plproxy_15 plsh_15* pldebugger_15 plpgsql_check_15*  pgtt_15 pgq_15* pgsql_tweaks_15 count_distinct_15 hypopg_15
  - timestamp9_15* semver_15* prefix_15* rum_15 geoip_15 periods_15 ip4r_15 tdigest_15 hll_15 pgmp_15 extra_window_functions_15 topn_15
  - pg_comparator_15 pg_ivm_15* pgsodium_15*  pgfincore_15* ddlx_15 credcheck_15 postgresql_anonymizer_15* postgresql_faker_15 safeupdate_15
  - pg_fkpart_15 pg_jobmon_15 pg_partman_15 pg_permissions_15 pgaudit17_15 pgexportdoc_15 pgimportdoc_15 pg_statement_rollback_15*
  - pg_cron_15 pg_background_15 e-maj_15 pg_catcheck_15 pg_prioritize_15 pgcopydb_15 pg_filedump_15 pgcryptokey_15
  - docker-compose #timescaledb-2-postgresql-15  # el7
  #- modulemd-tools python38-jmespath haproxy redis docker-compose-plugin # el8
  #- modulemd-tools python3-jmespath haproxy redis docker-compose-plugin citus_15* # el9
```

</details>




### `repo_url_packages`

Software for direct download via URL, type: `url[]`, level: G

Download some software via URL, not YUM:

* `pg_exporter`: **Required**, core components of the monitor system.
* `vip-manager`: **Required**, package required to enable L2 VIP for managing VIP.
* `pev2`: Optional, PostgreSQL execution plan visualization
* `minio/mcli`: Optional, Setup minio clusters for PostgreSQL backup center.

<details><summary>RHEL7 repo packages</summary>

```yaml
- https://github.com/Vonng/pg_exporter/releases/download/v0.5.0/pg_exporter-0.5.0.x86_64.rpm
- https://github.com/cybertec-postgresql/vip-manager/releases/download/v2.0.0/vip-manager_2.0.0_Linux_x86_64.rpm
- https://github.com/dalibo/pev2/releases/download/v1.6.0/index.html
- https://github.com/Vonng/pigsty-pkg/releases/download/misc/redis-6.2.7-1.el7.remi.x86_64.rpm # redis.el7
- https://github.com/Vonng/haproxy-rpm/releases/download/v2.6.6/haproxy-2.6.6-1.el7.x86_64.rpm # haproxy.el7
- https://dl.min.io/server/minio/release/linux-amd64/archive/minio-20230102094009.0.0.x86_64.rpm
- https://dl.min.io/client/mc/release/linux-amd64/archive/mcli-20221224152138.0.0.x86_64.rpm
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
  - 10.10.10.10 meta h.pigsty a.pigsty p.pigsty g.pigsty
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
node_dns_servers: ['${admin_ip}'] # dynamic nameserver in `/etc/resolv.conf`
```





### `node_dns_options`

If [`node_dns_method`](#node_dns_method) is configured as `add` or `overwrite`, the records in this config entry will be appended or overwritten to `/etc/resolv.conf`. Please see the Linux doc for `/etc/resolv.conf` for the exact format.

The default parsing options added by Pigsty:

```bash
- options single-request-reopen timeout:1
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

## `HAPROXY`



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










----------------

# `ETCD`

Distributed Configuration Store (DCS) is a distributed, highly available meta-database that provides HA consensus and service discovery.

Pigsty supports Consul & ETCD as DCS. Use [`dcs_registry`](#dcs_registry) to specify where to register service,

Availability of Consul/ETCD is critical for postgres HA. Special care needs to be taken when using the DCS service in a production env.
Availability of DCS itself is achieved through multiple peers. For example, a 3-node DCS cluster allows up to one node to fail, while a 5-node DCS cluster allows 2 nodes to fail.
In a large-scale production env, it is recommended to use at least 3~5 DCS Servers.
The DCS servers used by Pigsty are specified by the parameter [`dcs_servers`](#dcs_servers), either by using an existing external DCS server cluster or by deploying DCS Servers using nodes managed by Pigsty itself.

By default, Pigsty deploys setup DCS services when nodes are included in management ([`nodes.yml`](playbook.md#nodes#nodes)), and if the current node is defined in [`dcs_servers`](#dcs_servers), the node will be initialized as a DCS Server.
Pigsty deploys a single node DCS Server on the meta node itself by default. You can use any node as DCS Servers.  Before deploying any HA Postgres Cluster, you should ensure that all DCS Servers have been initialized. (Which is done during `nodes.yml`)


the type of DCS used by [`pg_dcs_type`](#pg_dcs_type) and the location of the service registration by








----------------

# `MINIO`







----------------

# `PGSQL`

----------------

## `PG_IDENTITY`


[`pg_cluster`](#pg_cluster), [`pg_role`](#pg_role), [`pg_seq`](#pg_seq) are core **identity params**, which are **required** for any Postgres cluster, and must be explicitly specified. Here's an example:

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

pgsql cluster name, type: `string`, level: C, no default values. **required** identity parameter.

The cluster name will be used as the namespace for postgres related resources within that cluster. The naming needs to follow a specific naming pattern: `[a-z][a-z0-9-]*` to be compatible with the requirements of different constraints on the identity.



### `pg_seq`

PG ins serial number, type: `int`, level: I, no default value,  **mandatory parameter, must be provided by the user.**

A serial number of the database ins, unique within the **cluster**, is used to distinguish and identify different instances within the cluster, assigned starting from 0 or 1.




### `pg_role`

PG instance role, type: `enum`, level: I, no default,  **mandatory parameter, must be provided by the user.**

Roles for PG ins, default roles include   `primary`, `replica`, and `offline`.

* `primary`: Primary, there must be one and only one member of the cluster as `primary`.
* `replica`: Replica for carrying online read-only traffic.
* `offline`: Offline replica for taking on offline read-only traffic, such as statistical analysis/ETL/personal queries, etc.

**Identity params, required params, and instance-level params.**




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



### `pg_offline_query`

Allow offline queries, type: `bool`, level: I, default value: `false`.

When set to `true`, the user group `dbrole_offline` can connect to the ins and perform offline queries, regardless of the role of the current ins.

More practical for cases with a small number of ins (one primary & one replica), the user can mark the only replica as `pg_offline_query = true`, thus accepting ETL, slow queries with interactive access.




### `pg_weight`

The relative weight of the ins in load balancing, type: `int`, level: I, default value: `100`.

When adjusting the relative weight of an instance in service, this parameter can be modified at the instance level and applied to take effect as described in [SOP: Cluster Traffic Adjustment](/en/docs/pgsql/reference/sop).






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
  - name: dbuser_meta               # REQUIRED, `name` is the only mandatory field of a user definition
    password: DBUser.Meta           # optional, password, can be a scram-sha-256 hash string or plain text
    login: true                     # optional, can log in, true by default  (new biz ROLE should be false)
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
    parameters: {}                  # optional, role level parameters with `ALTER ROLE SET`
    pool_mode: transaction          # optional, pgbouncer pool mode at user level, transaction by default
    pool_connlimit: -1              # optional, max database connections at user level, default -1 disable limit
    search_path: public             # key value config parameters according to postgresql documentation (e.g: use pigsty as default search_path)
  - {name: dbuser_view     ,password: DBUser.Viewer   ,pgbouncer: true ,roles: [dbrole_readonly], comment: read-only viewer for meta database}
  - {name: dbuser_grafana  ,password: DBUser.Grafana  ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for grafana database   }
  - {name: dbuser_bytebase ,password: DBUser.Bytebase ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for bytebase database  }
  - {name: dbuser_kong     ,password: DBUser.Kong     ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for kong api gateway   }
  - {name: dbuser_gitea    ,password: DBUser.Gitea    ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for gitea service      }
  - {name: dbuser_wiki     ,password: DBUser.Wiki     ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for wiki.js service    }
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
  - name: meta                      # REQUIRED, `name` is the only mandatory field of a database definition
    baseline: cmdb.sql              # optional, database sql baseline path, (relative path among ansible search path, e.g files/)
    pgbouncer: true                 # optional, add this database to pgbouncer database list? true by default
    schemas: [pigsty]               # optional, additional schemas to be created, array of schema names
    extensions: [{name: postgis}]   # optional, additional extensions to be installed: array of `{name[,schema]}`
    comment: pigsty meta database   # optional, comment string for this database
    owner: postgres                 # optional, database owner, postgres by default
    template: template1             # optional, which template to use, template1 by default
    encoding: UTF8                  # optional, database encoding, UTF8 by default. (MUST same as template database)
    locale: C                       # optional, database locale, C by default.  (MUST same as template database)
    lc_collate: C                   # optional, database collate, C by default. (MUST same as template database)
    lc_ctype: C                     # optional, database ctype, C by default.   (MUST same as template database)
    tablespace: pg_default          # optional, default tablespace, 'pg_default' by default.
    allowconn: true                 # optional, allow connection, true by default. false will disable connect at all
    revokeconn: false               # optional, revoke public connection privilege. false by default. (leave connect with grant option to owner)
    register_datasource: true       # optional, register this database to grafana datasources? true by default
    connlimit: -1                   # optional, database connection limit, default -1 disable limit
    pool_auth_user: dbuser_meta     # optional, all connection to this pgbouncer database will be authenticated by this user
    pool_mode: transaction          # optional, pgbouncer pool mode at database level, default transaction
    pool_size: 64                   # optional, pgbouncer pool size at database level, default 64
    pool_size_reserve: 32           # optional, pgbouncer pool size reserve at database level, default 32
    pool_size_min: 0                # optional, pgbouncer pool size min at database level, default 0
    pool_max_db_conn: 100           # optional, max database connections at database level, default 100
  - { name: grafana  ,owner: dbuser_grafana  ,revokeconn: true ,comment: grafana primary database }
  - { name: bytebase ,owner: dbuser_bytebase ,revokeconn: true ,comment: bytebase primary database }
  - { name: kong     ,owner: dbuser_kong     ,revokeconn: true ,comment: kong the api gateway database }
  - { name: gitea    ,owner: dbuser_gitea    ,revokeconn: true ,comment: gitea meta database }
  - { name: wiki     ,owner: dbuser_wiki     ,revokeconn: true ,comment: wiki meta database }
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






### `pg_services`

Cluster Proprietary Service Definition, Type: `service[]`, Level: C, Default:

Used to define additional services at the cluster level, each object in the array defines a [service](c-service#service), a complete service definition is as follows:

```yaml
pg_services:                        # extra services in addition to pg_default_services, array of service definition
  
  - name: standby                   # required, service name, the actual svc name will be prefixed with `pg_cluster`, e.g: pg-meta-standby
    port: 5435                      # required, service exposed port (work as kubernetes service node port mode)
    ip: "*"                         # optional, service bind ip address, `*` for all ip by default
    selector: "[]"                  # required, service member selector, use JMESPath to filter inventory
    dest: pgbouncer                 # optional, destination port, postgres|pgbouncer|<port_number> , pgbouncer(6432) by default
    check: /sync                    # optional, health check url path, / by default
    backup: "[? pg_role == `primary`]"  # backup server selector
    maxconn: 3000                   # optional, max allowed front-end connection
    balance: roundrobin             # optional, haproxy load balance algorithm (roundrobin by default, other: leastconn)
    options: 'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'

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




### `pg_hba_rules`

Cluster/ins specific HBA rule, Type: `rule[]`, Level: C, Default:

Set the client IP black and white list rules for the database. An array of objects, each of which represents a rule, each of which consists of three parts:

* `title`: Rule headings, which are converted to comments in the HBA file
* `role`: Apply for roles, `common` means apply to all instances, other values (e.g. `replica`, `offline`) will only be installed to matching roles. For example, `role='replica'` means that this rule will only be applied to instances with `pg_role == 'replica'`.
* `rules`: Array of strings, each record represents a rule that will eventually be written to `pg_hba.conf`.

As a special case, the HBA rule for `role == 'offline'` is additionally installed on instance of `pg_offline_query == true`.

[`pg_hba_rules`](#pg_hba_rules) is similar, but is typically used for global uniform HBA rule settings, and [`pg_hba_rules_extra`](#pg_hba_rules_extra) will **append** to `pg_hba.conf` in the same way.

If you need to completely **overwrite** the cluster's HBA rules and do not want to inherit the global HBA config, you should configure [`pg_hba_rules`](#pg_hba_rules) at the cluster level and override the global config.





### `pgb_hba_rules`

Pgbounce HBA rule, type: `rule[]`, level: C, default value is an empty array.

Similar to [`pg_hba_rules_extra`](#pg_hba_rules_extra) for extra config of Pgbouncer's HBA rules at the cluster level.




### `pg_replication_username`

PG replication user's name, type: `string`, level: G, default value: `"replicator"`.

For performing PostgreSQL stream replication, it is recommended to keep global consistency.




### `pg_replication_password`

PG's Replication User Password, type: `string`, level: G, default value: `"DBUser.Replicator"`.

The password of the database user used to perform PostgreSQL stream replication must be in plaintext. The default is `DBUser.Replicator`.

It is highly recommended to change this parameter when deploying in production envs!




### `pg_admin_username`

PG admin user, type: `string`, level: G, default value: `"dbuser_dba"`.

The DB username is used to perform PG management tasks (DDL changes), with superuser privileges by default.



### `pg_admin_password`

PG admin user password, type: `string`, level: G, default value: `"DBUser.DBA"`.

The database user password used to perform PG management tasks (DDL changes) must be in plaintext. The default is `DBUser.DBA` and highly recommended changes!

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


```yaml
- postgresql${pg_version}*
- pgbouncer pg_exporter pgbadger vip-manager patroni patroni-etcd pgbackrest
```





### `pg_extensions`

pg extensions to be installed, type: `string[]`, level: C, default value:

```yaml
postgis33_${pg_version}* pg_repack_${pg_version} wal2json_${pg_version} timescaledb-2-postgresql-${pg_version}
```

Append  `citus_${pg_version}` if you want citus on el7, use `citus_${pg_version}` on el8, el9 instead.






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




### `pg_namespace`

top level key namespace in etcd, used by patroni & vip, type: `path`, level: C, default value: `"/pg"`.




### `patroni_enabled`

Enabled Patroni, type: `bool`, level: C, default value: `true`.

If disabled, Pigsty will skip pulling up patroni. This option is used when setting up extra staff for an existing ins.




### `patroni_mode`

Patroni work mode, type: `enum`, level: C, default value: `"default"`.

* `default`: Enable Patroni to enter HA auto-switching mode.
* `pause`: Enable Patroni to automatically enter maintenance mode after completing initialization (no automatic M-S S switching).
* `remove`: Initialize the cluster with Patroni and remove Patroni after initialization.





### `patroni_port`

Patroni listens to port, type: `int`, level: C, default value: `8008`.

The Patroni API server listens to the port for service and health checks to the public by default.




### `patroni_log_dir`

Patroni log directory, type: `path`, level: C, default value: `/pg/log/patroni`.

The default patroni log lies in `/pg/log/patroni.log`




### `patroni_ssl_enabled`

secure patroni RestAPI communications with SSL? type: `bool`, level: C, default value: `false`.

It's not recommended to enable this option, since haproxy health check & prometheus metrics scrape would fail.

You can secure patroni RestAPI with [`patroni_username`](#patroni_username) and [`patroni_password`](#patroni_password),
Basic authentication restricted from meta nodes is sufficent for most cases.




### `patroni_watchdog_mode`

Patroni Watchdog mode, type: `enum`, level: C, default value: `"off"`.

When an M-S switchover occurs, Patroni will try to shut down the primary before elevating the replica. If the primary is still not shut down within the specified time, Patroni will use the Linux kernel module `softdog` to fence shutdown according to the config.

* `off`: not using `watchdog`. avoid fencing node.
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




### `pgbouncer_sslmode`

pgbouncer client ssl mode, type: `enum`, level: C, default value: `disable`.








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

Struct same as [`pg_users`](#pg_users)

```yaml
- { name: dbrole_readonly  ,login: false ,comment: role for global read-only access     }
- { name: dbrole_offline   ,login: false ,comment: role for restricted read-only access }
- { name: dbrole_readwrite ,login: false ,roles: [dbrole_readonly]               ,comment: role for global read-write access }
- { name: dbrole_admin     ,login: false ,roles: [pg_monitor, dbrole_readwrite]  ,comment: role for object creation }
- { name: postgres     ,superuser: true                                          ,comment: system superuser }
- { name: replicator ,replication: true  ,roles: [pg_monitor, dbrole_readonly]   ,comment: system replicator }
- { name: dbuser_dba   ,superuser: true  ,roles: [dbrole_admin]  ,pgbouncer: true ,pool_mode: session, pool_connlimit: 16 , comment: pgsql admin user }
- { name: dbuser_monitor   ,roles: [pg_monitor, dbrole_readonly] ,pgbouncer: true ,parameters: {log_min_duration_statement: 1000 } ,pool_mode: session ,pool_connlimit: 8 ,comment: pgsql monitor user }
```





### `pg_default_privileges`

default privileges when created by admin user, type: `string[]`, level: G/C, default value:

```yaml
pg_default_privileges:            # default privileges when created by admin user
  - GRANT USAGE      ON SCHEMAS   TO dbrole_readonly
  - GRANT SELECT     ON TABLES    TO dbrole_readonly
  - GRANT SELECT     ON SEQUENCES TO dbrole_readonly
  - GRANT EXECUTE    ON FUNCTIONS TO dbrole_readonly
  - GRANT USAGE      ON SCHEMAS   TO dbrole_offline
  - GRANT SELECT     ON TABLES    TO dbrole_offline
  - GRANT SELECT     ON SEQUENCES TO dbrole_offline
  - GRANT EXECUTE    ON FUNCTIONS TO dbrole_offline
  - GRANT INSERT     ON TABLES    TO dbrole_readwrite
  - GRANT UPDATE     ON TABLES    TO dbrole_readwrite
  - GRANT DELETE     ON TABLES    TO dbrole_readwrite
  - GRANT USAGE      ON SEQUENCES TO dbrole_readwrite
  - GRANT UPDATE     ON SEQUENCES TO dbrole_readwrite
  - GRANT TRUNCATE   ON TABLES    TO dbrole_admin
  - GRANT REFERENCES ON TABLES    TO dbrole_admin
  - GRANT TRIGGER    ON TABLES    TO dbrole_admin
  - GRANT CREATE     ON SCHEMAS   TO dbrole_admin
```




### `pg_default_schemas`

List of default schemas, type: `string[]`, hierarchy: G/C, default value: `[monitor]`.

Pigsty creates a schema named `monitor` for installing monitoring extensions by default.




### `pg_default_extensions`

List of defalut extensions, array of objects, type `extension[]`, hierarchy: G/C, default value:

```yaml
pg_default_extensions:            # default extensions to be created
  - { name: adminpack          ,schema: pg_catalog }
  - { name: pg_stat_statements ,schema: monitor }
  - { name: pgstattuple        ,schema: monitor }
  - { name: pg_buffercache     ,schema: monitor }
  - { name: pageinspect        ,schema: monitor }
  - { name: pg_prewarm         ,schema: monitor }
  - { name: pg_visibility      ,schema: monitor }
  - { name: pg_freespacemap    ,schema: monitor }
  - { name: postgres_fdw       ,schema: public  }
  - { name: file_fdw           ,schema: public  }
  - { name: btree_gist         ,schema: public  }
  - { name: btree_gin          ,schema: public  }
  - { name: pg_trgm            ,schema: public  }
  - { name: intagg             ,schema: public  }
  - { name: intarray           ,schema: public  }
  - { name: pg_repack }
```

If the extension does not specify a `schema` field, the extension will install to the corresponding schema based on the current `search_path`, e.g., `public`.




### `pg_reload`

Reload Database Config (HBA), type: `bool`, level: A, default value: `true`.

When set to `true`, Pigsty will execute the `pg_ctl reload` application immediately after generating HBA rules.

When generating the `pg_hba.conf` file and manually comparing it before applying it to take effect, you can specify `-e pg_reload=false` to disable it.




### `pg_default_hba_rules`

postgres default host-based authentication rules, type: `rule[]`, hierarchy: G/C, default value:

```yaml
pg_default_hba_rules:             # postgres default host-based authentication rules
  - {user: '${dbsu}'    ,db: all         ,addr: local     ,auth: ident ,title: 'dbsu access via local os user ident'  }
  - {user: '${dbsu}'    ,db: replication ,addr: local     ,auth: ident ,title: 'dbsu replication from local os ident' }
  - {user: '${repl}'    ,db: replication ,addr: localhost ,auth: pwd   ,title: 'replicator replication from localhost'}
  - {user: '${repl}'    ,db: replication ,addr: intra     ,auth: pwd   ,title: 'replicator replication from intranet' }
  - {user: '${repl}'    ,db: postgres    ,addr: intra     ,auth: pwd   ,title: 'replicator postgres db from intranet' }
  - {user: '${monitor}' ,db: all         ,addr: localhost ,auth: pwd   ,title: 'monitor from localhost with password' }
  - {user: '${monitor}' ,db: all         ,addr: infra     ,auth: pwd   ,title: 'monitor from infra host with password'}
  - {user: '${admin}'   ,db: all         ,addr: infra     ,auth: ssl   ,title: 'admin @ infra nodes with pwd & ssl'   }
  - {user: '${admin}'   ,db: all         ,addr: world     ,auth: cert  ,title: 'admin @ everywhere with ssl & cert'   }
  - {user: '+dbrole_readonly',db: all    ,addr: localhost ,auth: pwd   ,title: 'pgbouncer read/write via local socket'}
  - {user: '+dbrole_readonly',db: all    ,addr: intra     ,auth: pwd   ,title: 'read/write biz user via password'     }
  - {user: '+dbrole_offline' ,db: all    ,addr: intra     ,auth: pwd   ,title: 'allow etl offline tasks from intranet'}
```

This parameter is formally identical to [`pg_hba_rules_extra`](#pg_hba_rules_extra), and it is recommended to configure a uniform [`pg_hba_rules`](#pg_hba_rules) globally and use [`pg_hba_rules_extra`](#pg_hba_rules_extra) for extra customization. The rules in both parameters are applied sequentially, with the latter taking higher priority.

Beware, if you are using `scram-sha-256` on [`pg_pwd_enc`](#pg_pwd_enc), please replace `md5` with `scram-sha-256` in the above rules.






### `pgb_default_hba_rules`

pgbouncer default host-based authentication rules, type: `rule[]`, level: G/C, default value:

```yaml
pgb_default_hba_rules:            # pgbouncer default host-based authentication rules
  - {user: '${dbsu}'    ,db: pgbouncer   ,addr: local     ,auth: peer  ,title: 'dbsu local admin access with os ident'}
  - {user: 'all'        ,db: all         ,addr: localhost ,auth: pwd   ,title: 'allow all user local access with pwd' }
  - {user: '${monitor}' ,db: pgbouncer   ,addr: intra     ,auth: pwd   ,title: 'monitor access via intranet with pwd' }
  - {user: '${monitor}' ,db: all         ,addr: world     ,auth: deny  ,title: 'reject all other monitor access addr' }
  - {user: '${admin}'   ,db: all         ,addr: intra     ,auth: pwd   ,title: 'admin access via intranet with pwd'   }
  - {user: '${admin}'   ,db: all         ,addr: world     ,auth: deny  ,title: 'reject all other admin access addr'   }
  - {user: 'all'        ,db: all         ,addr: intra     ,auth: pwd   ,title: 'allow all user intra access with pwd' }
```

The default Pgbouncer HBA rules are simple:

1. Allow login from **local** with password
2. Allow password login from the intranet network break

Users can customize it.





### `pg_default_services`

postgres default service definitions, type: `service[]`, level: G/C, default value:

```yaml
pg_default_services:              # postgres default service definitions
  - { name: primary ,port: 5433 ,dest: pgbouncer ,check: /primary   ,selector: "[]" }
  - { name: replica ,port: 5434 ,dest: pgbouncer ,check: /read-only ,selector: "[]" , backup: "[? pg_role == `primary` || pg_role == `offline` ]" }
  - { name: default ,port: 5436 ,dest: postgres  ,check: /primary   ,selector: "[]" }
  - { name: offline ,port: 5438 ,dest: postgres  ,check: /replica   ,selector: "[? pg_role == `offline` || pg_offline_query ]" , backup: "[? pg_role == `replica` && !pg_offline_query]"}
```




----------------

## `PG_BACKUP`

PG Backup will setup WAL archive and local backup repo using [pgbackrest](https://pgbackrest.org/).



### `pgbackrest_enabled`

Enable PgBackrest, type: `bool`, level: C, default value: `true`.

Pigsty will setup pgbackrest on all postgres instance, if disabled, wal archive will be managed with shell scripts.




### `pgbackrest_clean`

Whether removing existing local pgbackrest data during init? type: `bool`, level: C, default value: `true`.




### `pgbackrest_log_dir`

pgbackrest log dir, type: `path`, level: C, default value: `/pg/log`.

RPM default values are `/var/log/pgbackrest`, use `/pg/log` instead.

Promtail will collect these logs.




### `pgbackrest_repo`

pgbackrest repo definition, type: `string`, level: C, default value:

```yaml
  repo1-path=/pg/backup/
  repo1-retention-full-type=time
  repo1-retention-full=14
  repo1-retention-diff=3
```

Pigsty will create a default local repo on all pgsql instances among cluster.

But only the one on primary is used. Other repo are prepared after failover/switchover.




----------------

## `PG_VIP`

Bind a layer 2 virtual ip address to primary instance with [vip-manager](https://github.com/cybertec-postgresql/vip-manager)



### `pg_vip_enabled`

enable a l2 vip for pgsql primary? type: `enum`, level: C, default value: `false`.




### `pg_vip_address`

vip address in `<ipv4>/<mask>` format, type: `string`, level: C, no default value.

example: `10.10.10.2/24`, `192.168.10.1/16`, etc...



### `pg_vip_interface`

vip network interface to listen, type: `string`, level: C, default value: `eth0`




----------------

## `PG_EXPORTER`

PG Exporter for monitoring Postgres with Pgbouncer connection pools.




### `pg_exporter_enabled`

Enable PG-exporter, type: `bool`, level: C, default value: `true`.

Whether to install and configure `pg_exporter`, when `false`, the config of `pg_exporter` on the current node will be skipped, and this Exporter will be skipped when registering monitoring targets.




### `pg_exporter_config`

PG-exporter config file, type: `string`, level: C, default value: `"pg_exporter.yml"`.

The default config file used by `pg_exporter` defines the database and connection pool monitor metrics in Pigsty. The default is [`pg_exporter.yml`](https://github.com/Vonng/pigsty/blob/master/roles/pg_exporter/files/pg_exporter.yml).

The PG-exporter config file used by Pigsty is supported by default from PostgreSQL 10.0 and is currently supported up to the latest PG 14 release. There are several of optional templates.

* [`pg_exporter_basic.yml`](https://github.com/Vonng/pigsty/blob/master/roles/pg_exporter/files/pg_exporter_basic.yml): contains only basic metrics, not Object monitor metrics within the database.
* [`pg_exporter_fast.yml`](https://github.com/Vonng/pigsty/blob/master/roles/pg_exporter/files/pg_exporter_fast.yml): metrics with shorter cache time definitions.




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

# `REDIS`



----------------
## `REDIS_IDENTITY`

**Identity parameters** are the information that must be provided to define a Redis cluster, including:

|                  Name                  |        Level        |   Description   |         Example         |
|:-------------------------------------:| :----------------: | :------: | :------------------: |
|   [`redis_cluster`](#redis_cluster)   | **MUST**, cluster level |  Cluster name  |      `redis-test`       |
|      [`redis_node`](#redis_node)      | **MUST**, node level | Node Number | `primary`, `replica` |
| [`redis_instances`](#redis_instances) | **MUST**, node level | Ins Definition | `{ 6001 : {} ,6002 : {}}`  |


- [`redis_cluster`](#redis_cluster) identifies the Redis cluster name, configured at the cluster level, and serves as the top-level namespace for cluster resources.
- [`redis_node`](#redis_node) identifies the serial number of the node in the cluster.
- [`redis_instances`](#redis_instances) is a JSON object with the Key as the ins port and the Value as a JSON object containing the instance-specific config.



### `redis_cluster`

Redis cluster identity, type: `string`, level: C, default value:

Redis cluster identity will be used as a namespace for resources within the cluster and needs to follow specific naming patterns: `[a-z][a-z0-9-]*` to be compatible with different constraints on identity identification. It is recommended to use `redis-` as the cluster name prefix.

**Identity param is required params and cluster-level params**.




### `redis_node`

Redis node identity, type: `int`, level: I, default value:

Redis node identity, unique in the **cluster**, is used to distinguish and identify different nodes, starting with an assignment of 0 or 1.



### `redis_instances`

Redis instances definition on this node, type: `instance[]`, level: I, default value.

This database node deployed all Redis ins in JSON K-V object format. The key is the numeric type port number, and the value is the JSON config entry specific to that instance.

Sample example:

```yaml
redis_instances: { 6501 : {} ,6502 : {} ,6503 : {} ,6504 : {} ,6505 : {} ,6506 : {} }
redis_instances:
    6501: {}
    6502: { replica_of: '10.10.10.13 6501' }
    6503: { replica_of: '10.10.10.13 6501' }
```

Each Redis ins listens on a unique port on the node. You can configure separate parameter options for Redis ins (currently, only `replica_of` is supported for pre-built M-S replication).

**Identity params required params and instance-level params**.




----------------
## `REDIS_NODE`



### `redis_fs_main`

Primary data disk for Redis, type: `path`, level: C, default value: `"/data"`.

Pigsty will create the `redis` dir under that dir to store Redis data. For example, `/data/redis`.

See [FHS: Redis](/en/docs/pgsql/concept/fhs) for details.




### `redis_exporter_enabled`

Enable Redis exporter, type: `bool`, level: C, default: `true`.

Redis Exporter is enabled by default, one on each Redis node deployed and listens on port 9121 by default.



### `redis_exporter_port`

Redis Exporter listens port, type: `int`, tier: C, default value: `9121`.

Note: If you modify this default port, you will need to replace this port along with the relevant config rule file in Prometheus.



### `redis_exporter_options`

Redis Exporter command parameter, type: `string`, level: C/I, default value: `""`.



----------------
## `REDIS_PROVISION`


### `redis_safeguard`

Disable erasure of existing Redis, type: `string`, level: C, default value: `false`.

if true, [`redis.yml`](/en/docs/redis/playbook#redis) and [`redis-remove.yml`](/en/docs/redis/playbook#redis-remove) will not remove running redis instance


### `redis_clean`

What to do when Redis exists, type: `bool`, level: C/A, default value: `"false"`.

If true, [`redis.yml`](/en/docs/redis/playbook#redis) will purge existing instance during init.



### `redis_mode`

Redis cluster mode, type: `enum`, level: C, default value: `"standalone"`.

Specifies the mode of this Redis cluster, with three optional modes:

* `standalone`: Default mode, deploys a series of independent Redis ins.
* `cluster`: Redis native cluster mode
* `sentinel`: Redis HA component: sentinel

Pigsty also sets up standalone Redis based on the `replica_of` parameter when using the `standalone` mode.
Pigsty creates a native Redis cluster using all defined instances according to the [`redis_cluster_replicas`](#redis_cluster_replicas) parameter when using `cluster` mode.




### `redis_conf`

Redis config template, type: `string`, level: C, default value: `"redis.conf"`.




### `redis_bind_address`

Redis listener address, type: `ip`, level: C, default value: `"0.0.0.0"`.

Redis listener the IP, or `inventory_hostname` if left blank. The default listener has all local IPv4.


### `redis_max_memory`

Max memory used by each Redis ins, type: `size`, level: C/I, default value: `"1GB"`

Max memory used by each Redis ins, default is 1GB; it is recommended to configure this parameter at the cluster level to keep the cluster ins config consistent.



### `redis_mem_policy`

Memory eviction policy, type: `enum`, level: C, default value: `"allkeys-lru"`.

Other optional policies include:

* `volatile-lru`
* `allkeys-lru`
* `volatile-lfu`
* `allkeys-lfu`
* `volatile-random`
* `allkeys-random`
* `volatile-ttl`
* `noeviction`



### `redis_password`

Redis password, type: `string`, level: C, default value: `""`.

`masterauth` & `requirepass` password to use, leave blank to disable password, disabled by default.

> Be careful with security, do not place Redis on the public network without password protection.



### `redis_rdb_save`

RDB SAVE directives, type: `string[]`, level: C, default value: `[ "1200 1" ]`.

Redis SAVE directives, the config will enable RDB functionality, each Save policy as a string。



### `redis_aof_enabled`

Enable AOF, type: `bool`, level: C, default value: `false`.





### `redis_rename_commands`

Rename dangerous commands, Type: `object`, Level: C, Default value: `{}`.

JSON dictionary renames the command represented by Key to the command represented by Value to avoid misuse of dangerous commands.






### `redis_cluster_replicas`

How many replicas per primary in Redis cluster, type: `int`, tier: C, default: `1`.

```bash
/bin/redis-cli --cluster create --cluster-yes \
  --cluster-replicas {{ redis_cluster_replicas|default(1) }}
```
