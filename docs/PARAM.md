# Parameter

> There are 280+ parameters in Pigsty describing all aspect of the deployment.

| ID  | Name                                                            | Module            | Section                           | Type        | Level | Comment                                                                       |
|-----|-----------------------------------------------------------------|-------------------|-----------------------------------|-------------|-------|-------------------------------------------------------------------------------|
| 101 | [`version`](#version)                                           | [`INFRA`](#infra) | [`META`](#meta)                   | string      | G     | pigsty version string                                                         |
| 102 | [`admin_ip`](#admin_ip)                                         | [`INFRA`](#infra) | [`META`](#meta)                   | ip          | G     | admin node ip address                                                         |
| 103 | [`region`](#region)                                             | [`INFRA`](#infra) | [`META`](#meta)                   | enum        | G     | upstream mirror region: default,china,europe                                  |
| 104 | [`proxy_env`](#proxy_env)                                       | [`INFRA`](#infra) | [`META`](#meta)                   | dict        | G     | global proxy env when downloading packages                                    |
| 105 | [`ca_method`](#ca_method)                                       | [`INFRA`](#infra) | [`CA`](#ca)                       | enum        | G     | create,recreate,copy, create by default                                       |
| 106 | [`ca_cn`](#ca_cn)                                               | [`INFRA`](#infra) | [`CA`](#ca)                       | string      | G     | ca common name, fixed as pigsty-ca                                            |
| 107 | [`cert_validity`](#cert_validity)                               | [`INFRA`](#infra) | [`CA`](#ca)                       | interval    | G     | cert validity, 20 years by default                                            |
| 108 | [`infra_seq`](#infra_seq)                                       | [`INFRA`](#infra) | [`INFRA_ID`](#infra_id)           | int         | I     | infra node identity, REQUIRED                                                 |
| 109 | [`infra_portal`](#infra_portal)                                 | [`INFRA`](#infra) | [`INFRA_ID`](#infra_id)           | dict        | G     | infra services exposed via portal                                             |
| 110 | [`repo_enabled`](#repo_enabled)                                 | [`INFRA`](#infra) | [`REPO`](#repo)                   | bool        | G/I   | create a yum repo on this infra node?                                         |
| 111 | [`repo_home`](#repo_home)                                       | [`INFRA`](#infra) | [`REPO`](#repo)                   | path        | G     | repo home dir, `/www` by default                                              |
| 112 | [`repo_name`](#repo_name)                                       | [`INFRA`](#infra) | [`REPO`](#repo)                   | string      | G     | repo name, pigsty by default                                                  |
| 113 | [`repo_endpoint`](#repo_endpoint)                               | [`INFRA`](#infra) | [`REPO`](#repo)                   | url         | G     | access point to this repo by domain or ip:port                                |
| 114 | [`repo_remove`](#repo_remove)                                   | [`INFRA`](#infra) | [`REPO`](#repo)                   | bool        | G/A   | remove existing upstream repo                                                 |
| 115 | [`repo_modules`](#repo_modules)                                 | [`INFRA`](#infra) | [`REPO`](#repo)                   | string      | G/A   | which repo modules are installed in repo_upstream                             |
| 116 | [`repo_upstream`](#repo_upstream)                               | [`INFRA`](#infra) | [`REPO`](#repo)                   | upstream[]  | G     | where to download upstream packages                                           |
| 117 | [`repo_packages`](#repo_packages)                               | [`INFRA`](#infra) | [`REPO`](#repo)                   | string[]    | G     | which packages to be included                                                 |
| 118 | [`repo_url_packages`](#repo_url_packages)                       | [`INFRA`](#infra) | [`REPO`](#repo)                   | string[]    | G     | extra packages from url                                                       |
| 120 | [`infra_packages`](#infra_packages)                             | [`INFRA`](#infra) | [`INFRA_PACKAGE`](#infra_package) | string[]    | G     | packages to be installed on infra nodes                                       |
| 121 | [`infra_packages_pip`](#infra_packages_pip)                     | [`INFRA`](#infra) | [`INFRA_PACKAGE`](#infra_package) | string      | G     | pip installed packages for infra nodes                                        |
| 130 | [`nginx_enabled`](#nginx_enabled)                               | [`INFRA`](#infra) | [`NGINX`](#nginx)                 | bool        | G/I   | enable nginx on this infra node?                                              |
| 131 | [`nginx_exporter_enabled`](#nginx_enabled)                      | [`INFRA`](#infra) | [`NGINX`](#nginx)                 | bool        | G/I   | enable nginx_exporter on this infra node?                                     |
| 132 | [`nginx_sslmode`](#nginx_sslmode)                               | [`INFRA`](#infra) | [`NGINX`](#nginx)                 | enum        | G     | nginx ssl mode? disable,enable,enforce                                        |
| 133 | [`nginx_home`](#nginx_home)                                     | [`INFRA`](#infra) | [`NGINX`](#nginx)                 | path        | G     | nginx content dir, `/www` by default                                          |
| 134 | [`nginx_port`](#nginx_port)                                     | [`INFRA`](#infra) | [`NGINX`](#nginx)                 | port        | G     | nginx listen port, 80 by default                                              |
| 135 | [`nginx_ssl_port`](#nginx_ssl_port)                             | [`INFRA`](#infra) | [`NGINX`](#nginx)                 | port        | G     | nginx ssl listen port, 443 by default                                         |
| 136 | [`nginx_navbar`](#nginx_navbar)                                 | [`INFRA`](#infra) | [`NGINX`](#nginx)                 | index[]     | G     | nginx index page navigation links                                             |
| 140 | [`dns_enabled`](#dns_enabled)                                   | [`INFRA`](#infra) | [`DNS`](#dns)                     | bool        | G/I   | setup dnsmasq on this infra node?                                             |
| 141 | [`dns_port`](#dns_port)                                         | [`INFRA`](#infra) | [`DNS`](#dns)                     | port        | G     | dns server listen port, 53 by default                                         |
| 142 | [`dns_records`](#dns_records)                                   | [`INFRA`](#infra) | [`DNS`](#dns)                     | string[]    | G     | dynamic dns records resolved by dnsmasq                                       |
| 150 | [`prometheus_enabled`](#prometheus_enabled)                     | [`INFRA`](#infra) | [`PROMETHEUS`](#prometheus)       | bool        | G/I   | enable prometheus on this infra node?                                         |
| 151 | [`prometheus_clean`](#prometheus_clean)                         | [`INFRA`](#infra) | [`PROMETHEUS`](#prometheus)       | bool        | G/A   | clean prometheus data during init?                                            |
| 152 | [`prometheus_data`](#prometheus_data)                           | [`INFRA`](#infra) | [`PROMETHEUS`](#prometheus)       | path        | G     | prometheus data dir, `/data/prometheus` by default                            |
| 153 | [`prometheus_sd_interval`](#prometheus_sd_interval)             | [`INFRA`](#infra) | [`PROMETHEUS`](#prometheus)       | interval    | G     | prometheus target refresh interval, 5s by default                             |
| 154 | [`prometheus_scrape_interval`](#prometheus_scrape_interval)     | [`INFRA`](#infra) | [`PROMETHEUS`](#prometheus)       | interval    | G     | prometheus scrape & eval interval, 10s by default                             |
| 155 | [`prometheus_scrape_timeout`](#prometheus_scrape_timeout)       | [`INFRA`](#infra) | [`PROMETHEUS`](#prometheus)       | interval    | G     | prometheus global scrape timeout, 8s by default                               |
| 156 | [`prometheus_options`](#prometheus_options)                     | [`INFRA`](#infra) | [`PROMETHEUS`](#prometheus)       | arg         | G     | prometheus extra server options                                               |
| 157 | [`pushgateway_enabled`](#pushgateway_enabled)                   | [`INFRA`](#infra) | [`PROMETHEUS`](#prometheus)       | bool        | G/I   | setup pushgateway on this infra node?                                         |
| 158 | [`pushgateway_options`](#pushgateway_options)                   | [`INFRA`](#infra) | [`PROMETHEUS`](#prometheus)       | arg         | G     | pushgateway extra server options                                              |
| 159 | [`blackbox_enabled`](#blackbox_enabled)                         | [`INFRA`](#infra) | [`PROMETHEUS`](#prometheus)       | bool        | G/I   | setup blackbox_exporter on this infra node?                                   |
| 160 | [`blackbox_options`](#blackbox_options)                         | [`INFRA`](#infra) | [`PROMETHEUS`](#prometheus)       | arg         | G     | blackbox_exporter extra server options                                        |
| 161 | [`alertmanager_enabled`](#alertmanager_enabled)                 | [`INFRA`](#infra) | [`PROMETHEUS`](#prometheus)       | bool        | G/I   | setup alertmanager on this infra node?                                        |
| 162 | [`alertmanager_options`](#alertmanager_options)                 | [`INFRA`](#infra) | [`PROMETHEUS`](#prometheus)       | arg         | G     | alertmanager extra server options                                             |
| 163 | [`exporter_metrics_path`](#exporter_metrics_path)               | [`INFRA`](#infra) | [`PROMETHEUS`](#prometheus)       | path        | G     | exporter metric path, `/metrics` by default                                   |
| 164 | [`exporter_install`](#exporter_install)                         | [`INFRA`](#infra) | [`PROMETHEUS`](#prometheus)       | enum        | G     | how to install exporter? none,yum,binary                                      |
| 165 | [`exporter_repo_url`](#exporter_repo_url)                       | [`INFRA`](#infra) | [`PROMETHEUS`](#prometheus)       | url         | G     | exporter repo file url if install exporter via yum                            |
| 170 | [`grafana_enabled`](#grafana_enabled)                           | [`INFRA`](#infra) | [`GRAFANA`](#grafana)             | bool        | G/I   | enable grafana on this infra node?                                            |
| 171 | [`grafana_clean`](#grafana_clean)                               | [`INFRA`](#infra) | [`GRAFANA`](#grafana)             | bool        | G/A   | clean grafana data during init?                                               |
| 172 | [`grafana_admin_username`](#grafana_admin_username)             | [`INFRA`](#infra) | [`GRAFANA`](#grafana)             | username    | G     | grafana admin username, `admin` by default                                    |
| 173 | [`grafana_admin_password`](#grafana_admin_password)             | [`INFRA`](#infra) | [`GRAFANA`](#grafana)             | password    | G     | grafana admin password, `pigsty` by default                                   |
| 174 | [`grafana_plugin_cache`](#grafana_plugin_cache)                 | [`INFRA`](#infra) | [`GRAFANA`](#grafana)             | path        | G     | path to grafana plugins cache tarball                                         |
| 175 | [`grafana_plugin_list`](#grafana_plugin_list)                   | [`INFRA`](#infra) | [`GRAFANA`](#grafana)             | string[]    | G     | grafana plugins to be downloaded with grafana-cli                             |
| 176 | [`loki_enabled`](#loki_enabled)                                 | [`INFRA`](#infra) | [`LOKI`](#loki)                   | bool        | G/I   | enable loki on this infra node?                                               |
| 177 | [`loki_clean`](#loki_clean)                                     | [`INFRA`](#infra) | [`LOKI`](#loki)                   | bool        | G/A   | whether remove existing loki data?                                            |
| 178 | [`loki_data`](#loki_data)                                       | [`INFRA`](#infra) | [`LOKI`](#loki)                   | path        | G     | loki data dir, `/data/loki` by default                                        |
| 179 | [`loki_retention`](#loki_retention)                             | [`INFRA`](#infra) | [`LOKI`](#loki)                   | interval    | G     | loki log retention period, 15d by default                                     |
| 201 | [`nodename`](#nodename)                                         | [`NODE`](#node)   | [`NODE_ID`](#node_id)             | string      | I     | node instance identity, use hostname if missing, optional                     |
| 202 | [`node_cluster`](#node_cluster)                                 | [`NODE`](#node)   | [`NODE_ID`](#node_id)             | string      | C     | node cluster identity, use 'nodes' if missing, optional                       |
| 203 | [`nodename_overwrite`](#nodename_overwrite)                     | [`NODE`](#node)   | [`NODE_ID`](#node_id)             | bool        | C     | overwrite node's hostname with nodename?                                      |
| 204 | [`nodename_exchange`](#nodename_exchange)                       | [`NODE`](#node)   | [`NODE_ID`](#node_id)             | bool        | C     | exchange nodename among play hosts?                                           |
| 205 | [`node_id_from_pg`](#node_id_from_pg)                           | [`NODE`](#node)   | [`NODE_ID`](#node_id)             | bool        | C     | use postgres identity as node identity if applicable?                         |
| 210 | [`node_default_etc_hosts`](#node_default_etc_hosts)             | [`NODE`](#node)   | [`NODE_DNS`](#node_dns)           | string[]    | G     | static dns records in `/etc/hosts`                                            |
| 211 | [`node_etc_hosts`](#node_etc_hosts)                             | [`NODE`](#node)   | [`NODE_DNS`](#node_dns)           | string[]    | C     | extra static dns records in `/etc/hosts`                                      |
| 212 | [`node_dns_method`](#node_dns_method)                           | [`NODE`](#node)   | [`NODE_DNS`](#node_dns)           | enum        | C     | how to handle dns servers: add,none,overwrite                                 |
| 213 | [`node_dns_servers`](#node_dns_servers)                         | [`NODE`](#node)   | [`NODE_DNS`](#node_dns)           | string[]    | C     | dynamic nameserver in `/etc/resolv.conf`                                      |
| 214 | [`node_dns_options`](#node_dns_options)                         | [`NODE`](#node)   | [`NODE_DNS`](#node_dns)           | string[]    | C     | dns resolv options in `/etc/resolv.conf`                                      |
| 220 | [`node_repo_method`](#node_repo_method)                         | [`NODE`](#node)   | [`NODE_PACKAGE`](#node_package)   | enum        | C     | how to setup node repo: none,local,public,both                                |
| 221 | [`node_repo_remove`](#node_repo_remove)                         | [`NODE`](#node)   | [`NODE_PACKAGE`](#node_package)   | bool        | C     | remove existing repo on node?                                                 |
| 222 | [`node_repo_local_urls`](#node_repo_local_urls)                 | [`NODE`](#node)   | [`NODE_PACKAGE`](#node_package)   | string[]    | C     | local repo url, if node_repo_method = local,both                              |
| 223 | [`node_packages`](#node_packages)                               | [`NODE`](#node)   | [`NODE_PACKAGE`](#node_package)   | string[]    | C     | packages to be installed current nodes                                        |
| 224 | [`node_default_packages`](#node_default_packages)               | [`NODE`](#node)   | [`NODE_PACKAGE`](#node_package)   | string[]    | G     | default packages to be installed on all nodes                                 |
| 230 | [`node_disable_firewall`](#node_disable_firewall)               | [`NODE`](#node)   | [`NODE_TUNE`](#node_tune)         | bool        | C     | disable node firewall? true by default                                        |
| 231 | [`node_disable_selinux`](#node_disable_selinux)                 | [`NODE`](#node)   | [`NODE_TUNE`](#node_tune)         | bool        | C     | disable node selinux? true by default                                         |
| 232 | [`node_disable_numa`](#node_disable_numa)                       | [`NODE`](#node)   | [`NODE_TUNE`](#node_tune)         | bool        | C     | disable node numa, reboot required                                            |
| 233 | [`node_disable_swap`](#node_disable_swap)                       | [`NODE`](#node)   | [`NODE_TUNE`](#node_tune)         | bool        | C     | disable node swap, use with caution                                           |
| 234 | [`node_static_network`](#node_static_network)                   | [`NODE`](#node)   | [`NODE_TUNE`](#node_tune)         | bool        | C     | preserve dns resolver settings after reboot                                   |
| 235 | [`node_disk_prefetch`](#node_disk_prefetch)                     | [`NODE`](#node)   | [`NODE_TUNE`](#node_tune)         | bool        | C     | setup disk prefetch on HDD to increase performance                            |
| 236 | [`node_kernel_modules`](#node_kernel_modules)                   | [`NODE`](#node)   | [`NODE_TUNE`](#node_tune)         | string[]    | C     | kernel modules to be enabled on this node                                     |
| 237 | [`node_hugepage_count`](#node_hugepage_count)                   | [`NODE`](#node)   | [`NODE_TUNE`](#node_tune)         | int         | C     | number of 2MB hugepage, take precedence over ratio                            |
| 238 | [`node_hugepage_ratio`](#node_hugepage_ratio)                   | [`NODE`](#node)   | [`NODE_TUNE`](#node_tune)         | float       | C     | node mem hugepage ratio, 0 disable it by default                              |
| 239 | [`node_overcommit_ratio`](#node_overcommit_ratio)               | [`NODE`](#node)   | [`NODE_TUNE`](#node_tune)         | float       | C     | node mem overcommit ratio, 0 disable it by default                            |
| 240 | [`node_tune`](#node_tune)                                       | [`NODE`](#node)   | [`NODE_TUNE`](#node_tune)         | enum        | C     | node tuned profile: none,oltp,olap,crit,tiny                                  |
| 241 | [`node_sysctl_params`](#node_sysctl_params)                     | [`NODE`](#node)   | [`NODE_TUNE`](#node_tune)         | dict        | C     | sysctl parameters in k:v format in addition to tuned                          |
| 250 | [`node_data`](#node_data)                                       | [`NODE`](#node)   | [`NODE_ADMIN`](#node_admin)       | path        | C     | node main data directory, `/data` by default                                  |
| 251 | [`node_admin_enabled`](#node_admin_enabled)                     | [`NODE`](#node)   | [`NODE_ADMIN`](#node_admin)       | bool        | C     | create a admin user on target node?                                           |
| 252 | [`node_admin_uid`](#node_admin_uid)                             | [`NODE`](#node)   | [`NODE_ADMIN`](#node_admin)       | int         | C     | uid and gid for node admin user                                               |
| 253 | [`node_admin_username`](#node_admin_username)                   | [`NODE`](#node)   | [`NODE_ADMIN`](#node_admin)       | username    | C     | name of node admin user, `dba` by default                                     |
| 254 | [`node_admin_ssh_exchange`](#node_admin_ssh_exchange)           | [`NODE`](#node)   | [`NODE_ADMIN`](#node_admin)       | bool        | C     | exchange admin ssh key among node cluster                                     |
| 255 | [`node_admin_pk_current`](#node_admin_pk_current)               | [`NODE`](#node)   | [`NODE_ADMIN`](#node_admin)       | bool        | C     | add current user's ssh pk to admin authorized_keys                            |
| 256 | [`node_admin_pk_list`](#node_admin_pk_list)                     | [`NODE`](#node)   | [`NODE_ADMIN`](#node_admin)       | string[]    | C     | ssh public keys to be added to admin user                                     |
| 260 | [`node_timezone`](#node_timezone)                               | [`NODE`](#node)   | [`NODE_TIME`](#node_time)         | string      | C     | setup node timezone, empty string to skip                                     |
| 261 | [`node_ntp_enabled`](#node_ntp_enabled)                         | [`NODE`](#node)   | [`NODE_TIME`](#node_time)         | bool        | C     | enable chronyd time sync service?                                             |
| 262 | [`node_ntp_servers`](#node_ntp_servers)                         | [`NODE`](#node)   | [`NODE_TIME`](#node_time)         | string[]    | C     | ntp servers in `/etc/chrony.conf`                                             |
| 263 | [`node_crontab_overwrite`](#node_crontab_overwrite)             | [`NODE`](#node)   | [`NODE_TIME`](#node_time)         | bool        | C     | overwrite or append to `/etc/crontab`?                                        |
| 264 | [`node_crontab`](#node_crontab)                                 | [`NODE`](#node)   | [`NODE_TIME`](#node_time)         | string[]    | C     | crontab entries in `/etc/crontab`                                             |
| 270 | [`vip_enabled`](#vip_enabled)                                   | [`NODE`](#node)   | [`NODE_VIP`](#node_vip)           | bool        | C     | enable vip on this node cluster?                                              |
| 271 | [`vip_address`](#vip_address)                                   | [`NODE`](#node)   | [`NODE_VIP`](#node_vip)           | ip          | C     | node vip address in ipv4 format, required if vip is enabled                   |
| 272 | [`vip_vrid`](#vip_vrid)                                         | [`NODE`](#node)   | [`NODE_VIP`](#node_vip)           | int         | C     | required, integer, 1-254, should be unique among same VLAN                    |
| 273 | [`vip_role`](#vip_role)                                         | [`NODE`](#node)   | [`NODE_VIP`](#node_vip)           | enum        | I     | optional, `master/backup`, backup by default, use as init role                |
| 274 | [`vip_preempt`](#vip_preempt)                                   | [`NODE`](#node)   | [`NODE_VIP`](#node_vip)           | bool        | C/I   | optional, `true/false`, false by default, enable vip preemption               |
| 275 | [`vip_interface`](#vip_interface)                               | [`NODE`](#node)   | [`NODE_VIP`](#node_vip)           | string      | C/I   | node vip network interface to listen, `eth0` by default                       |
| 276 | [`vip_dns_suffix`](#vip_dns_suffix)                             | [`NODE`](#node)   | [`NODE_VIP`](#node_vip)           | string      | C     | node vip dns name suffix, empty string by default                             |
| 277 | [`vip_exporter_port`](#vip_exporter_port)                       | [`NODE`](#node)   | [`NODE_VIP`](#node_vip)           | port        | C     | keepalived exporter listen port, 9650 by default                              |
| 280 | [`haproxy_enabled`](#haproxy_enabled)                           | [`NODE`](#node)   | [`HAPROXY`](#haproxy)             | bool        | C     | enable haproxy on this node?                                                  |
| 281 | [`haproxy_clean`](#haproxy_clean)                               | [`NODE`](#node)   | [`HAPROXY`](#haproxy)             | bool        | G/C/A | cleanup all existing haproxy config?                                          |
| 282 | [`haproxy_reload`](#haproxy_reload)                             | [`NODE`](#node)   | [`HAPROXY`](#haproxy)             | bool        | A     | reload haproxy after config?                                                  |
| 283 | [`haproxy_auth_enabled`](#haproxy_auth_enabled)                 | [`NODE`](#node)   | [`HAPROXY`](#haproxy)             | bool        | G     | enable authentication for haproxy admin page                                  |
| 284 | [`haproxy_admin_username`](#haproxy_admin_username)             | [`NODE`](#node)   | [`HAPROXY`](#haproxy)             | username    | G     | haproxy admin username, `admin` by default                                    |
| 285 | [`haproxy_admin_password`](#haproxy_admin_password)             | [`NODE`](#node)   | [`HAPROXY`](#haproxy)             | password    | G     | haproxy admin password, `pigsty` by default                                   |
| 286 | [`haproxy_exporter_port`](#haproxy_exporter_port)               | [`NODE`](#node)   | [`HAPROXY`](#haproxy)             | port        | C     | haproxy admin/exporter port, 9101 by default                                  |
| 287 | [`haproxy_client_timeout`](#haproxy_client_timeout)             | [`NODE`](#node)   | [`HAPROXY`](#haproxy)             | interval    | C     | client side connection timeout, 24h by default                                |
| 288 | [`haproxy_server_timeout`](#haproxy_server_timeout)             | [`NODE`](#node)   | [`HAPROXY`](#haproxy)             | interval    | C     | server side connection timeout, 24h by default                                |
| 289 | [`haproxy_services`](#haproxy_services)                         | [`NODE`](#node)   | [`HAPROXY`](#haproxy)             | service[]   | C     | list of haproxy service to be exposed on node                                 |
| 290 | [`node_exporter_enabled`](#node_exporter_enabled)               | [`NODE`](#node)   | [`NODE_EXPORTER`](#node_exporter) | bool        | C     | setup node_exporter on this node?                                             |
| 291 | [`node_exporter_port`](#node_exporter_port)                     | [`NODE`](#node)   | [`NODE_EXPORTER`](#node_exporter) | port        | C     | node exporter listen port, 9100 by default                                    |
| 292 | [`node_exporter_options`](#node_exporter_options)               | [`NODE`](#node)   | [`NODE_EXPORTER`](#node_exporter) | arg         | C     | extra server options for node_exporter                                        |
| 293 | [`promtail_enabled`](#promtail_enabled)                         | [`NODE`](#node)   | [`PROMTAIL`](#promtail)           | bool        | C     | enable promtail logging collector?                                            |
| 294 | [`promtail_clean`](#promtail_clean)                             | [`NODE`](#node)   | [`PROMTAIL`](#promtail)           | bool        | G/A   | purge existing promtail status file during init?                              |
| 295 | [`promtail_port`](#promtail_port)                               | [`NODE`](#node)   | [`PROMTAIL`](#promtail)           | port        | C     | promtail listen port, 9080 by default                                         |
| 296 | [`promtail_positions`](#promtail_positions)                     | [`NODE`](#node)   | [`PROMTAIL`](#promtail)           | path        | C     | promtail position status file path                                            |
| 401 | [`docker_enabled`](#docker_enabled)                             | [`NODE`](#node)   | [`DOCKER`](#docker)               | bool        | C     | enable docker on this node?                                                   |
| 402 | [`docker_cgroups_driver`](#docker_cgroups_driver)               | [`NODE`](#node)   | [`DOCKER`](#docker)               | enum        | C     | docker cgroup fs driver: cgroupfs,systemd                                     |
| 403 | [`docker_registry_mirrors`](#docker_registry_mirrors)           | [`NODE`](#node)   | [`DOCKER`](#docker)               | string[]    | C     | docker registry mirror list                                                   |
| 404 | [`docker_image_cache`](#docker_image_cache)                     | [`NODE`](#node)   | [`DOCKER`](#docker)               | path        | C     | docker image cache dir, `/tmp/docker` by default                              |
| 501 | [`etcd_seq`](#etcd_seq)                                         | [`ETCD`](#etcd)   | [`ETCD`](#etcd)                   | int         | I     | etcd instance identifier, REQUIRED                                            |
| 502 | [`etcd_cluster`](#etcd_cluster)                                 | [`ETCD`](#etcd)   | [`ETCD`](#etcd)                   | string      | C     | etcd cluster & group name, etcd by default                                    |
| 503 | [`etcd_safeguard`](#etcd_safeguard)                             | [`ETCD`](#etcd)   | [`ETCD`](#etcd)                   | bool        | G/C/A | prevent purging running etcd instance?                                        |
| 504 | [`etcd_clean`](#etcd_clean)                                     | [`ETCD`](#etcd)   | [`ETCD`](#etcd)                   | bool        | G/C/A | purging existing etcd during initialization?                                  |
| 505 | [`etcd_data`](#etcd_data)                                       | [`ETCD`](#etcd)   | [`ETCD`](#etcd)                   | path        | C     | etcd data directory, /data/etcd by default                                    |
| 506 | [`etcd_port`](#etcd_port)                                       | [`ETCD`](#etcd)   | [`ETCD`](#etcd)                   | port        | C     | etcd client port, 2379 by default                                             |
| 507 | [`etcd_peer_port`](#etcd_peer_port)                             | [`ETCD`](#etcd)   | [`ETCD`](#etcd)                   | port        | C     | etcd peer port, 2380 by default                                               |
| 508 | [`etcd_init`](#etcd_init)                                       | [`ETCD`](#etcd)   | [`ETCD`](#etcd)                   | enum        | C     | etcd initial cluster state, new or existing                                   |
| 509 | [`etcd_election_timeout`](#etcd_election_timeout)               | [`ETCD`](#etcd)   | [`ETCD`](#etcd)                   | int         | C     | etcd election timeout, 1000ms by default                                      |
| 510 | [`etcd_heartbeat_interval`](#etcd_heartbeat_interval)           | [`ETCD`](#etcd)   | [`ETCD`](#etcd)                   | int         | C     | etcd heartbeat interval, 100ms by default                                     |
| 601 | [`minio_seq`](#minio_seq)                                       | [`MINIO`](#minio) | [`MINIO`](#minio)                 | int         | I     | minio instance identifier, REQUIRED                                           |
| 602 | [`minio_cluster`](#minio_cluster)                               | [`MINIO`](#minio) | [`MINIO`](#minio)                 | string      | C     | minio cluster name, minio by default                                          |
| 603 | [`minio_clean`](#minio_clean)                                   | [`MINIO`](#minio) | [`MINIO`](#minio)                 | bool        | G/C/A | cleanup minio during init?, false by default                                  |
| 604 | [`minio_user`](#minio_user)                                     | [`MINIO`](#minio) | [`MINIO`](#minio)                 | username    | C     | minio os user, `minio` by default                                             |
| 605 | [`minio_node`](#minio_node)                                     | [`MINIO`](#minio) | [`MINIO`](#minio)                 | string      | C     | minio node name pattern                                                       |
| 606 | [`minio_data`](#minio_data)                                     | [`MINIO`](#minio) | [`MINIO`](#minio)                 | path        | C     | minio data dir(s), use {x...y} to specify multi drivers                       |
| 607 | [`minio_domain`](#minio_domain)                                 | [`MINIO`](#minio) | [`MINIO`](#minio)                 | string      | G     | minio service domain name, `sss.pigsty` by default                            |
| 608 | [`minio_port`](#minio_port)                                     | [`MINIO`](#minio) | [`MINIO`](#minio)                 | port        | C     | minio service port, 9000 by default                                           |
| 609 | [`minio_admin_port`](#minio_admin_port)                         | [`MINIO`](#minio) | [`MINIO`](#minio)                 | port        | C     | minio console port, 9001 by default                                           |
| 610 | [`minio_access_key`](#minio_access_key)                         | [`MINIO`](#minio) | [`MINIO`](#minio)                 | username    | C     | root access key, `minioadmin` by default                                      |
| 611 | [`minio_secret_key`](#minio_secret_key)                         | [`MINIO`](#minio) | [`MINIO`](#minio)                 | password    | C     | root secret key, `minioadmin` by default                                      |
| 612 | [`minio_extra_vars`](#minio_extra_vars)                         | [`MINIO`](#minio) | [`MINIO`](#minio)                 | string      | C     | extra environment variables for minio server                                  |
| 613 | [`minio_alias`](#minio_alias)                                   | [`MINIO`](#minio) | [`MINIO`](#minio)                 | string      | G     | alias name for local minio deployment                                         |
| 614 | [`minio_buckets`](#minio_buckets)                               | [`MINIO`](#minio) | [`MINIO`](#minio)                 | bucket[]    | C     | list of minio bucket to be created                                            |
| 615 | [`minio_users`](#minio_users)                                   | [`MINIO`](#minio) | [`MINIO`](#minio)                 | user[]      | C     | list of minio user to be created                                              |
| 701 | [`redis_cluster`](#redis_cluster)                               | [`REDIS`](#redis) | [`REDIS`](#redis)                 | string      | C     | redis cluster name, required identity parameter                               |
| 702 | [`redis_instances`](#redis_instances)                           | [`REDIS`](#redis) | [`REDIS`](#redis)                 | dict        | I     | redis instances definition on this redis node                                 |
| 703 | [`redis_node`](#redis_node)                                     | [`REDIS`](#redis) | [`REDIS`](#redis)                 | int         | I     | redis node sequence number, node int id required                              |
| 710 | [`redis_fs_main`](#redis_fs_main)                               | [`REDIS`](#redis) | [`REDIS`](#redis)                 | path        | C     | redis main data mountpoint, `/data` by default                                |
| 711 | [`redis_exporter_enabled`](#redis_exporter_enabled)             | [`REDIS`](#redis) | [`REDIS`](#redis)                 | bool        | C     | install redis exporter on redis nodes?                                        |
| 712 | [`redis_exporter_port`](#redis_exporter_port)                   | [`REDIS`](#redis) | [`REDIS`](#redis)                 | port        | C     | redis exporter listen port, 9121 by default                                   |
| 713 | [`redis_exporter_options`](#redis_exporter_options)             | [`REDIS`](#redis) | [`REDIS`](#redis)                 | string      | C/I   | cli args and extra options for redis exporter                                 |
| 720 | [`redis_safeguard`](#redis_safeguard)                           | [`REDIS`](#redis) | [`REDIS`](#redis)                 | bool        | G/C/A | prevent purging running redis instance?                                       |
| 721 | [`redis_clean`](#redis_clean)                                   | [`REDIS`](#redis) | [`REDIS`](#redis)                 | bool        | G/C/A | purging existing redis during init?                                           |
| 722 | [`redis_rmdata`](#redis_rmdata)                                 | [`REDIS`](#redis) | [`REDIS`](#redis)                 | bool        | G/C/A | remove redis data when purging redis server?                                  |
| 723 | [`redis_mode`](#redis_mode)                                     | [`REDIS`](#redis) | [`REDIS`](#redis)                 | enum        | C     | redis mode: standalone,cluster,sentinel                                       |
| 724 | [`redis_conf`](#redis_conf)                                     | [`REDIS`](#redis) | [`REDIS`](#redis)                 | string      | C     | redis config template path, except sentinel                                   |
| 725 | [`redis_bind_address`](#redis_bind_address)                     | [`REDIS`](#redis) | [`REDIS`](#redis)                 | ip          | C     | redis bind address, empty string will use host ip                             |
| 726 | [`redis_max_memory`](#redis_max_memory)                         | [`REDIS`](#redis) | [`REDIS`](#redis)                 | size        | C/I   | max memory used by each redis instance                                        |
| 727 | [`redis_mem_policy`](#redis_mem_policy)                         | [`REDIS`](#redis) | [`REDIS`](#redis)                 | enum        | C     | redis memory eviction policy                                                  |
| 728 | [`redis_password`](#redis_password)                             | [`REDIS`](#redis) | [`REDIS`](#redis)                 | password    | C     | redis password, empty string will disable password                            |
| 729 | [`redis_rdb_save`](#redis_rdb_save)                             | [`REDIS`](#redis) | [`REDIS`](#redis)                 | string[]    | C     | redis rdb save directives, disable with empty list                            |
| 730 | [`redis_aof_enabled`](#redis_aof_enabled)                       | [`REDIS`](#redis) | [`REDIS`](#redis)                 | bool        | C     | enable redis append only file?                                                |
| 731 | [`redis_rename_commands`](#redis_rename_commands)               | [`REDIS`](#redis) | [`REDIS`](#redis)                 | dict        | C     | rename redis dangerous commands                                               |
| 732 | [`redis_cluster_replicas`](#redis_cluster_replicas)             | [`REDIS`](#redis) | [`REDIS`](#redis)                 | int         | C     | replica number for one master in redis cluster                                |
| 733 | [`redis_sentinel_monitor`](#redis_sentinel_monitor)             | [`REDIS`](#redis) | [`REDIS`](#redis)                 | master[]    |   C   | sentinel master list, works on sentinel cluster only                          |
| 801 | [`pg_mode`](#pg_mode)                                           | [`PGSQL`](#pgsql) | [`PG_ID`](#pg_id)                 | enum        | C     | pgsql cluster mode: pgsql,citus,gpsql                                         |
| 802 | [`pg_cluster`](#pg_cluster)                                     | [`PGSQL`](#pgsql) | [`PG_ID`](#pg_id)                 | string      | C     | pgsql cluster name, REQUIRED identity parameter                               |
| 803 | [`pg_seq`](#pg_seq)                                             | [`PGSQL`](#pgsql) | [`PG_ID`](#pg_id)                 | int         | I     | pgsql instance seq number, REQUIRED identity parameter                        |
| 804 | [`pg_role`](#pg_role)                                           | [`PGSQL`](#pgsql) | [`PG_ID`](#pg_id)                 | enum        | I     | pgsql role, REQUIRED, could be primary,replica,offline                        |
| 805 | [`pg_instances`](#pg_instances)                                 | [`PGSQL`](#pgsql) | [`PG_ID`](#pg_id)                 | dict        | I     | define multiple pg instances on node in `{port:ins_vars}` format              |
| 806 | [`pg_upstream`](#pg_upstream)                                   | [`PGSQL`](#pgsql) | [`PG_ID`](#pg_id)                 | ip          | I     | repl upstream ip addr for standby cluster or cascade replica                  |
| 807 | [`pg_shard`](#pg_shard)                                         | [`PGSQL`](#pgsql) | [`PG_ID`](#pg_id)                 | string      | C     | pgsql shard name, optional identity for sharding clusters                     |
| 808 | [`pg_group`](#pg_group)                                         | [`PGSQL`](#pgsql) | [`PG_ID`](#pg_id)                 | int         | C     | pgsql shard index number, optional identity for sharding clusters             |
| 809 | [`gp_role`](#gp_role)                                           | [`PGSQL`](#pgsql) | [`PG_ID`](#pg_id)                 | enum        | C     | greenplum role of this cluster, could be master or segment                    |
| 810 | [`pg_exporters`](#pg_exporters)                                 | [`PGSQL`](#pgsql) | [`PG_ID`](#pg_id)                 | dict        | C     | additional pg_exporters to monitor remote postgres instances                  |
| 811 | [`pg_offline_query`](#pg_offline_query)                         | [`PGSQL`](#pgsql) | [`PG_ID`](#pg_id)                 | bool        | I     | set to true to enable offline query on this instance                          |
| 820 | [`pg_users`](#pg_users)                                         | [`PGSQL`](#pgsql) | [`PG_BUSINESS`](#pg_business)     | user[]      | C     | postgres business users                                                       |
| 821 | [`pg_databases`](#pg_databases)                                 | [`PGSQL`](#pgsql) | [`PG_BUSINESS`](#pg_business)     | database[]  | C     | postgres business databases                                                   |
| 822 | [`pg_services`](#pg_services)                                   | [`PGSQL`](#pgsql) | [`PG_BUSINESS`](#pg_business)     | service[]   | C     | postgres business services                                                    |
| 823 | [`pg_hba_rules`](#pg_hba_rules)                                 | [`PGSQL`](#pgsql) | [`PG_BUSINESS`](#pg_business)     | hba[]       | C     | business hba rules for postgres                                               |
| 824 | [`pgb_hba_rules`](#pgb_hba_rules)                               | [`PGSQL`](#pgsql) | [`PG_BUSINESS`](#pg_business)     | hba[]       | C     | business hba rules for pgbouncer                                              |
| 831 | [`pg_replication_username`](#pg_replication_username)           | [`PGSQL`](#pgsql) | [`PG_BUSINESS`](#pg_business)     | username    | G     | postgres replication username, `replicator` by default                        |
| 832 | [`pg_replication_password`](#pg_replication_password)           | [`PGSQL`](#pgsql) | [`PG_BUSINESS`](#pg_business)     | password    | G     | postgres replication password, `DBUser.Replicator` by default                 |
| 833 | [`pg_admin_username`](#pg_admin_username)                       | [`PGSQL`](#pgsql) | [`PG_BUSINESS`](#pg_business)     | username    | G     | postgres admin username, `dbuser_dba` by default                              |
| 834 | [`pg_admin_password`](#pg_admin_password)                       | [`PGSQL`](#pgsql) | [`PG_BUSINESS`](#pg_business)     | password    | G     | postgres admin password in plain text, `DBUser.DBA` by default                |
| 835 | [`pg_monitor_username`](#pg_monitor_username)                   | [`PGSQL`](#pgsql) | [`PG_BUSINESS`](#pg_business)     | username    | G     | postgres monitor username, `dbuser_monitor` by default                        |
| 836 | [`pg_monitor_password`](#pg_monitor_password)                   | [`PGSQL`](#pgsql) | [`PG_BUSINESS`](#pg_business)     | password    | G     | postgres monitor password, `DBUser.Monitor` by default                        |
| 837 | [`pg_dbsu_password`](#pg_dbsu_password)                         | [`PGSQL`](#pgsql) | [`PG_BUSINESS`](#pg_business)     | password    | G/C   | postgres dbsu password, empty string disable it by default                    |
| 840 | [`pg_dbsu`](#pg_dbsu)                                           | [`PGSQL`](#pgsql) | [`PG_INSTALL`](#pg_install)       | username    | C     | os dbsu name, postgres by default, better not change it                       |
| 841 | [`pg_dbsu_uid`](#pg_dbsu_uid)                                   | [`PGSQL`](#pgsql) | [`PG_INSTALL`](#pg_install)       | int         | C     | os dbsu uid and gid, 26 for default postgres users and groups                 |
| 842 | [`pg_dbsu_sudo`](#pg_dbsu_sudo)                                 | [`PGSQL`](#pgsql) | [`PG_INSTALL`](#pg_install)       | enum        | C     | dbsu sudo privilege, none,limit,all,nopass. limit by default                  |
| 843 | [`pg_dbsu_home`](#pg_dbsu_home)                                 | [`PGSQL`](#pgsql) | [`PG_INSTALL`](#pg_install)       | path        | C     | postgresql home directory, `/var/lib/pgsql` by default                        |
| 844 | [`pg_dbsu_ssh_exchange`](#pg_dbsu_ssh_exchange)                 | [`PGSQL`](#pgsql) | [`PG_INSTALL`](#pg_install)       | bool        | C     | exchange postgres dbsu ssh key among same pgsql cluster                       |
| 845 | [`pg_version`](#pg_version)                                     | [`PGSQL`](#pgsql) | [`PG_INSTALL`](#pg_install)       | enum        | C     | postgres major version to be installed, 15 by default                         |
| 846 | [`pg_bin_dir`](#pg_bin_dir)                                     | [`PGSQL`](#pgsql) | [`PG_INSTALL`](#pg_install)       | path        | C     | postgres binary dir, `/usr/pgsql/bin` by default                              |
| 847 | [`pg_log_dir`](#pg_log_dir)                                     | [`PGSQL`](#pgsql) | [`PG_INSTALL`](#pg_install)       | path        | C     | postgres log dir, `/pg/log/postgres` by default                               |
| 848 | [`pg_packages`](#pg_packages)                                   | [`PGSQL`](#pgsql) | [`PG_INSTALL`](#pg_install)       | string[]    | C     | pg packages to be installed, `${pg_version}` will be replaced                 |
| 849 | [`pg_extensions`](#pg_extensions)                               | [`PGSQL`](#pgsql) | [`PG_INSTALL`](#pg_install)       | string[]    | C     | pg extensions to be installed, `${pg_version}` will be replaced               |
| 850 | [`pg_safeguard`](#pg_safeguard)                                 | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | bool        | G/C/A | prevent purging running postgres instance? false by default                   |
| 851 | [`pg_clean`](#pg_clean)                                         | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | bool        | G/C/A | purging existing postgres during pgsql init? true by default                  |
| 852 | [`pg_data`](#pg_data)                                           | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | path        | C     | postgres data directory, `/pg/data` by default                                |
| 853 | [`pg_fs_main`](#pg_fs_main)                                     | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | path        | C     | mountpoint/path for postgres main data, `/data` by default                    |
| 854 | [`pg_fs_bkup`](#pg_fs_bkup)                                     | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | path        | C     | mountpoint/path for pg backup data, `/data/backup` by default                 |
| 855 | [`pg_storage_type`](#pg_storage_type)                           | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | enum        | C     | storage type for pg main data, SSD,HDD, SSD by default                        |
| 856 | [`pg_dummy_filesize`](#pg_dummy_filesize)                       | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | size        | C     | size of `/pg/dummy`, hold 64MB disk space for emergency use                   |
| 857 | [`pg_listen`](#pg_listen)                                       | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | ip(s)       | C/I   | postgres/pgbouncer listen addresses, comma separated list                     |
| 858 | [`pg_port`](#pg_port)                                           | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | port        | C     | postgres listen port, 5432 by default                                         |
| 859 | [`pg_localhost`](#pg_localhost)                                 | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | path        | C     | postgres unix socket dir for localhost connection                             |
| 860 | [`pg_namespace`](#pg_namespace)                                 | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | path        | C     | top level key namespace in etcd, used by patroni & vip                        |
| 861 | [`patroni_enabled`](#patroni_enabled)                           | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | bool        | C     | if disabled, no postgres cluster will be created during init                  |
| 862 | [`patroni_mode`](#patroni_mode)                                 | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | enum        | C     | patroni working mode: default,pause,remove                                    |
| 863 | [`patroni_port`](#patroni_port)                                 | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | port        | C     | patroni listen port, 8008 by default                                          |
| 864 | [`patroni_log_dir`](#patroni_log_dir)                           | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | path        | C     | patroni log dir, `/pg/log/patroni` by default                                 |
| 865 | [`patroni_ssl_enabled`](#patroni_ssl_enabled)                   | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | bool        | G     | secure patroni RestAPI communications with SSL?                               |
| 866 | [`patroni_watchdog_mode`](#patroni_watchdog_mode)               | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | enum        | C     | patroni watchdog mode: automatic,required,off. off by default                 |
| 867 | [`patroni_username`](#patroni_username)                         | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | username    | C     | patroni restapi username, `postgres` by default                               |
| 868 | [`patroni_password`](#patroni_password)                         | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | password    | C     | patroni restapi password, `Patroni.API` by default                            |
| 869 | [`patroni_citus_db`](#patroni_citus_db)                         | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | string      | C     | citus database managed by patroni, postgres by default                        |
| 870 | [`pg_conf`](#pg_conf)                                           | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | enum        | C     | config template: oltp,olap,crit,tiny. `oltp.yml` by default                   |
| 871 | [`pg_max_conn`](#pg_max_conn)                                   | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | int         | C     | postgres max connections, `auto` will use recommended value                   |
| 872 | [`pg_shared_buffer_ratio`](#pg_shared_buffer_ratio)             | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | float       | C     | postgres shared buffer memory ratio, 0.25 by default, 0.1~0.4                 |
| 873 | [`pg_rto`](#pg_rto)                                             | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | int         | C     | recovery time objective in seconds,  `30s` by default                         |
| 874 | [`pg_rpo`](#pg_rpo)                                             | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | int         | C     | recovery point objective in bytes, `1MiB` at most by default                  |
| 875 | [`pg_libs`](#pg_libs)                                           | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | string      | C     | preloaded libraries, `timescaledb,pg_stat_statements,auto_explain` by default |
| 876 | [`pg_delay`](#pg_delay)                                         | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | interval    | I     | replication apply delay for standby cluster leader                            |
| 877 | [`pg_checksum`](#pg_checksum)                                   | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | bool        | C     | enable data checksum for postgres cluster?                                    |
| 878 | [`pg_pwd_enc`](#pg_pwd_enc)                                     | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | enum        | C     | passwords encryption algorithm: md5,scram-sha-256                             |
| 879 | [`pg_encoding`](#pg_encoding)                                   | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | enum        | C     | database cluster encoding, `UTF8` by default                                  |
| 880 | [`pg_locale`](#pg_locale)                                       | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | enum        | C     | database cluster local, `C` by default                                        |
| 881 | [`pg_lc_collate`](#pg_lc_collate)                               | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | enum        | C     | database cluster collate, `C` by default                                      |
| 882 | [`pg_lc_ctype`](#pg_lc_ctype)                                   | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | enum        | C     | database character type, `en_US.UTF8` by default                              |
| 890 | [`pgbouncer_enabled`](#pgbouncer_enabled)                       | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | bool        | C     | if disabled, pgbouncer will not be launched on pgsql host                     |
| 891 | [`pgbouncer_port`](#pgbouncer_port)                             | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | port        | C     | pgbouncer listen port, 6432 by default                                        |
| 892 | [`pgbouncer_log_dir`](#pgbouncer_log_dir)                       | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | path        | C     | pgbouncer log dir, `/pg/log/pgbouncer` by default                             |
| 893 | [`pgbouncer_auth_query`](#pgbouncer_auth_query)                 | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | bool        | C     | query postgres to retrieve unlisted business users?                           |
| 894 | [`pgbouncer_poolmode`](#pgbouncer_poolmode)                     | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | enum        | C     | pooling mode: transaction,session,statement, transaction by default           |
| 895 | [`pgbouncer_sslmode`](#pgbouncer_sslmode)                       | [`PGSQL`](#pgsql) | [`PG_BOOTSTRAP`](#pg_bootstrap)   | enum        | C     | pgbouncer client ssl mode, disable by default                                 |
| 900 | [`pg_provision`](#pg_provision)                                 | [`PGSQL`](#pgsql) | [`PG_PROVISION`](#pg_provision)   | bool        | C     | provision postgres cluster after bootstrap                                    |
| 901 | [`pg_init`](#pg_init)                                           | [`PGSQL`](#pgsql) | [`PG_PROVISION`](#pg_provision)   | string      | G/C   | provision init script for cluster template, `pg-init` by default              |
| 902 | [`pg_default_roles`](#pg_default_roles)                         | [`PGSQL`](#pgsql) | [`PG_PROVISION`](#pg_provision)   | role[]      | G/C   | default roles and users in postgres cluster                                   |
| 903 | [`pg_default_privileges`](#pg_default_privileges)               | [`PGSQL`](#pgsql) | [`PG_PROVISION`](#pg_provision)   | string[]    | G/C   | default privileges when created by admin user                                 |
| 904 | [`pg_default_schemas`](#pg_default_schemas)                     | [`PGSQL`](#pgsql) | [`PG_PROVISION`](#pg_provision)   | string[]    | G/C   | default schemas to be created                                                 |
| 905 | [`pg_default_extensions`](#pg_default_extensions)               | [`PGSQL`](#pgsql) | [`PG_PROVISION`](#pg_provision)   | extension[] | G/C   | default extensions to be created                                              |
| 906 | [`pg_reload`](#pg_reload)                                       | [`PGSQL`](#pgsql) | [`PG_PROVISION`](#pg_provision)   | bool        | A     | reload postgres after hba changes                                             |
| 907 | [`pg_default_hba_rules`](#pg_default_hba_rules)                 | [`PGSQL`](#pgsql) | [`PG_PROVISION`](#pg_provision)   | hba[]       | G/C   | postgres default host-based authentication rules                              |
| 908 | [`pgb_default_hba_rules`](#pgb_default_hba_rules)               | [`PGSQL`](#pgsql) | [`PG_PROVISION`](#pg_provision)   | hba[]       | G/C   | pgbouncer default host-based authentication rules                             |
| 910 | [`pgbackrest_enabled`](#pgbackrest_enabled)                     | [`PGSQL`](#pgsql) | [`PG_BACKUP`](#pg_backup)         | bool        | C     | enable pgbackrest on pgsql host?                                              |
| 911 | [`pgbackrest_clean`](#pgbackrest_clean)                         | [`PGSQL`](#pgsql) | [`PG_BACKUP`](#pg_backup)         | bool        | C     | remove pg backup data during init?                                            |
| 912 | [`pgbackrest_log_dir`](#pgbackrest_log_dir)                     | [`PGSQL`](#pgsql) | [`PG_BACKUP`](#pg_backup)         | path        | C     | pgbackrest log dir, `/pg/log/pgbackrest` by default                           |
| 913 | [`pgbackrest_method`](#pgbackrest_method)                       | [`PGSQL`](#pgsql) | [`PG_BACKUP`](#pg_backup)         | enum        | C     | pgbackrest repo method: local,minio,etc...                                    |
| 914 | [`pgbackrest_repo`](#pgbackrest_repo)                           | [`PGSQL`](#pgsql) | [`PG_BACKUP`](#pg_backup)         | dict        | G/C   | pgbackrest repo: https://pgbackrest.org/configuration.html#section-repository |
| 921 | [`pg_weight`](#pg_weight)                                       | [`PGSQL`](#pgsql) | [`PG_SERVICE`](#pg_service)       | int         | I     | relative load balance weight in service, 100 by default, 0-255                |
| 922 | [`pg_service_provider`](#pg_service_provider)                   | [`PGSQL`](#pgsql) | [`PG_SERVICE`](#pg_service)       | string      | G/C   | dedicate haproxy node group name, or empty string for local nodes by default  |
| 923 | [`pg_default_service_dest`](#pg_default_service_dest)           | [`PGSQL`](#pgsql) | [`PG_SERVICE`](#pg_service)       | enum        | G/C   | default service destination if svc.dest='default'                             |
| 924 | [`pg_default_services`](#pg_default_services)                   | [`PGSQL`](#pgsql) | [`PG_SERVICE`](#pg_service)       | service[]   | G/C   | postgres default service definitions                                          |
| 931 | [`pg_vip_enabled`](#pg_vip_enabled)                             | [`PGSQL`](#pgsql) | [`PG_SERVICE`](#pg_service)       | bool        | C     | enable a l2 vip for pgsql primary? false by default                           |
| 932 | [`pg_vip_address`](#pg_vip_address)                             | [`PGSQL`](#pgsql) | [`PG_SERVICE`](#pg_service)       | cidr4       | C     | vip address in `<ipv4>/<mask>` format, require if vip is enabled              |
| 933 | [`pg_vip_interface`](#pg_vip_interface)                         | [`PGSQL`](#pgsql) | [`PG_SERVICE`](#pg_service)       | string      | C/I   | vip network interface to listen, eth0 by default                              |
| 934 | [`pg_dns_suffix`](#pg_dns_suffix)                               | [`PGSQL`](#pgsql) | [`PG_SERVICE`](#pg_service)       | string      | C     | pgsql dns suffix, '' by default                                               |
| 935 | [`pg_dns_target`](#pg_dns_target)                               | [`PGSQL`](#pgsql) | [`PG_SERVICE`](#pg_service)       | enum        | C     | auto, primary, vip, none, or ad hoc ip                                        |
| 940 | [`pg_exporter_enabled`](#pg_exporter_enabled)                   | [`PGSQL`](#pgsql) | [`PG_EXPORTER`](#pg_exporter)     | bool        | C     | enable pg_exporter on pgsql hosts?                                            |
| 941 | [`pg_exporter_config`](#pg_exporter_config)                     | [`PGSQL`](#pgsql) | [`PG_EXPORTER`](#pg_exporter)     | string      | C     | pg_exporter configuration file name                                           |
| 942 | [`pg_exporter_cache_ttls`](#pg_exporter_cache_ttls)             | [`PGSQL`](#pgsql) | [`PG_EXPORTER`](#pg_exporter)     | string      | C     | pg_exporter collector ttl stage in seconds, '1,10,60,300' by default          |
| 943 | [`pg_exporter_port`](#pg_exporter_port)                         | [`PGSQL`](#pgsql) | [`PG_EXPORTER`](#pg_exporter)     | port        | C     | pg_exporter listen port, 9630 by default                                      |
| 944 | [`pg_exporter_params`](#pg_exporter_params)                     | [`PGSQL`](#pgsql) | [`PG_EXPORTER`](#pg_exporter)     | string      | C     | extra url parameters for pg_exporter dsn                                      |
| 945 | [`pg_exporter_url`](#pg_exporter_url)                           | [`PGSQL`](#pgsql) | [`PG_EXPORTER`](#pg_exporter)     | pgurl       | C     | overwrite auto-generate pg dsn if specified                                   |
| 946 | [`pg_exporter_auto_discovery`](#pg_exporter_auto_discovery)     | [`PGSQL`](#pgsql) | [`PG_EXPORTER`](#pg_exporter)     | bool        | C     | enable auto database discovery? enabled by default                            |
| 947 | [`pg_exporter_exclude_database`](#pg_exporter_exclude_database) | [`PGSQL`](#pgsql) | [`PG_EXPORTER`](#pg_exporter)     | string      | C     | csv of database that WILL NOT be monitored during auto-discovery              |
| 948 | [`pg_exporter_include_database`](#pg_exporter_include_database) | [`PGSQL`](#pgsql) | [`PG_EXPORTER`](#pg_exporter)     | string      | C     | csv of database that WILL BE monitored during auto-discovery                  |
| 949 | [`pg_exporter_connect_timeout`](#pg_exporter_connect_timeout)   | [`PGSQL`](#pgsql) | [`PG_EXPORTER`](#pg_exporter)     | int         | C     | pg_exporter connect timeout in ms, 200 by default                             |
| 950 | [`pg_exporter_options`](#pg_exporter_options)                   | [`PGSQL`](#pgsql) | [`PG_EXPORTER`](#pg_exporter)     | arg         | C     | overwrite extra options for pg_exporter                                       |
| 951 | [`pgbouncer_exporter_enabled`](#pgbouncer_exporter_enabled)     | [`PGSQL`](#pgsql) | [`PG_EXPORTER`](#pg_exporter)     | bool        | C     | enable pgbouncer_exporter on pgsql hosts?                                     |
| 952 | [`pgbouncer_exporter_port`](#pgbouncer_exporter_port)           | [`PGSQL`](#pgsql) | [`PG_EXPORTER`](#pg_exporter)     | port        | C     | pgbouncer_exporter listen port, 9631 by default                               |
| 953 | [`pgbouncer_exporter_url`](#pgbouncer_exporter_url)             | [`PGSQL`](#pgsql) | [`PG_EXPORTER`](#pg_exporter)     | pgurl       | C     | overwrite auto-generate pgbouncer dsn if specified                            |
| 954 | [`pgbouncer_exporter_options`](#pgbouncer_exporter_options)     | [`PGSQL`](#pgsql) | [`PG_EXPORTER`](#pg_exporter)     | arg         | C     | overwrite extra options for pgbouncer_exporter                                |



------------------------------------------------------------

# `INFRA`

Parameters about pigsty infrastructure components: local yum repo, nginx, dnsmasq, prometheus, grafana, loki, alertmanager, pushgateway, blackbox_exporter, etc...


------------------------------

## `META`

This section contains some metadata of current pigsty deployments, such as version string, admin node IP address, repo mirror [`region`](#region) and http(s) proxy when downloading pacakges.

```yaml
version: v2.5.0                   # pigsty version string
admin_ip: 10.10.10.10             # admin node ip address
region: default                   # upstream mirror region: default,china,europe
proxy_env:                        # global proxy env when downloading packages
  no_proxy: "localhost,127.0.0.1,10.0.0.0/8,192.168.0.0/16,*.pigsty,*.aliyun.com,mirrors.*,*.myqcloud.com,*.tsinghua.edu.cn"
  # http_proxy:  # set your proxy here: e.g http://user:pass@proxy.xxx.com
  # https_proxy: # set your proxy here: e.g http://user:pass@proxy.xxx.com
  # all_proxy:   # set your proxy here: e.g http://user:pass@proxy.xxx.com
```

### `version`

name: `version`, type: `string`, level: `G`

pigsty version string

default value:`v2.5.0`

It will be used for pigsty introspection & content rendering.





### `admin_ip`

name: `admin_ip`, type: `ip`, level: `G`

admin node ip address

default value:`10.10.10.10`

Node with this ip address will be treated as admin node, usually point to the first node that install Pigsty.

The default value `10.10.10.10` is a placeholder which will be replaced during [configure](INSTALL#configure)

This parameter is referenced by many other parameters, such as:

* [`infra_portal`](#infra_portal)
* [`repo_endpoint`](#repo_endpoint)
* [`dns_records`](#dns_records)
* [`node_default_etc_hosts`](#node_default_etc_hosts)
* [`node_etc_hosts`](#node_etc_hosts)
* [`node_repo_local_urls`](#node_repo_local_urls)

The exact string `${admin_ip}` will be replaced with the actual `admin_ip` for above parameters.








### `region`

name: `region`, type: `enum`, level: `G`

upstream mirror region: default,china,europe

default value: `default`

If a region other than `default` is set, and there's a corresponding entry in `repo_upstream.[repo].baseurl`, it will be used instead of `default`.

For example, if `china` is used,  pigsty will use China mirrors designated in [`repo_upstream`](#repo_upstream) if applicable.




### `proxy_env`

name: `proxy_env`, type: `dict`, level: `G`

global proxy env when downloading packages

default value: 

```yaml
proxy_env: # global proxy env when downloading packages
  http_proxy: 'http://username:password@proxy.address.com'
  https_proxy: 'http://username:password@proxy.address.com'
  all_proxy: 'http://username:password@proxy.address.com'
  no_proxy: "localhost,127.0.0.1,10.0.0.0/8,192.168.0.0/16,*.pigsty,*.aliyun.com,mirrors.aliyuncs.com,mirrors.tuna.tsinghua.edu.cn,mirrors.zju.edu.cn"
```

It's quite important to use http proxy in restricted production environment, or your Internet access is blocked (e.g. Mainland China)






------------------------------

## `CA`

Self-Signed CA used by pigsty. It is required to support advanced security features.

```yaml
ca_method: create                 # create,recreate,copy, create by default
ca_cn: pigsty-ca                  # ca common name, fixed as pigsty-ca
cert_validity: 7300d              # cert validity, 20 years by default
```


### `ca_method`

name: `ca_method`, type: `enum`, level: `G`

available options: create,recreate,copy

default value: `create`

* `create`: Create a new CA public-private key pair if not exists, use if exists
* `recreate`: Always re-create a new CA public-private key pair
* `copy`: Copy the existing CA public and private keys from local `files/pki/ca`, abort if missing

If you already have a pair of `ca.crt` and `ca.key`, put them under `files/pki/ca` and set `ca_method` to `copy`.





### `ca_cn`

name: `ca_cn`, type: `string`, level: `G`

ca common name, not recommending to change it.

default value: `pigsty-ca`

you can check that with  `openssl x509 -text -in /etc/pki/ca.crt`





### `cert_validity`

name: `cert_validity`, type: `interval`, level: `G`

cert validity, 20 years by default, which is enough for most scenarios

default value: `7300d`








------------------------------

## `INFRA_ID`

Infrastructure identity and portal definition.

```yaml
#infra_seq: 1                     # infra node identity, explicitly required
infra_portal:                     # infra services exposed via portal
  home         : { domain: h.pigsty }
  grafana      : { domain: g.pigsty ,endpoint: "${admin_ip}:3000" ,websocket: true }
  prometheus   : { domain: p.pigsty ,endpoint: "${admin_ip}:9090" }
  alertmanager : { domain: a.pigsty ,endpoint: "${admin_ip}:9093" }
  blackbox     : { endpoint: "${admin_ip}:9115" }
  loki         : { endpoint: "${admin_ip}:3100" }
```



### `infra_seq`

name: `infra_seq`, type: `int`, level: `I`

infra node identity, REQUIRED, no default value, you have to assign it explicitly.




### `infra_portal`

name: `infra_portal`, type: `dict`, level: `G`

infra services exposed via portal.

default value will expose home, grafana, prometheus, alertmanager via nginx with corresponding domain names.

```yaml
infra_portal:                     # infra services exposed via portal
  home         : { domain: h.pigsty }
  grafana      : { domain: g.pigsty ,endpoint: "${admin_ip}:3000" ,websocket: true }
  prometheus   : { domain: p.pigsty ,endpoint: "${admin_ip}:9090" }
  alertmanager : { domain: a.pigsty ,endpoint: "${admin_ip}:9093" }
  blackbox     : { endpoint: "${admin_ip}:9115" }
  loki         : { endpoint: "${admin_ip}:3100" }
```

Each record contains three subsections: key as `name`, representing the component name, the external access domain, and the internal TCP port, respectively.
and the value contains `domain`, and `endpoint`, and other options.

* The `name` definition of the default record is fixed and referenced by other modules, so do not modify the default entry names.
* The `domain` is the domain name that should be used for external access to this upstream server. domain names will be added to Nginx SSL cert SAN.
* The `endpoint` is an internally reachable TCP port. and `${admin_ip}` will be replaced with actual [`admin_ip`](#admin_ip) in runtime.
* If `websocket` is set to `true`, http protocol will be auto upgraded for ws connections.
* If `scheme` is given (`http` or `https`), it will be used as part of proxy_pass URL.




------------------------------

## `REPO`

This section is about local software repo. Pigsty will create a local software repo (APT/YUM) when init an infra node.

In the initialization process, Pigsty will download all packages and their dependencies (specified by [`repo_packages`](#repo_packages)) from the Internet upstream repo (specified by [`repo_upstream`](#repo_upstream)) to [`{{ nginx_home }}`](#nginx_home) / [`{{ repo_name }}`](#repo_name)  (default is `/www/pigsty`), and the total size of all dependent software is about 1GB or so.

When creating a local repo, Pigsty will skip the software download phase if the directory already exists and if there is a marker file named `repo_complete` in the dir.

If the download speed of some packages is too slow, you can set the download proxy to complete the first download by using the [`proxy_env`](#proxy_env) config entry or directly download the pre-packaged [offline package](INSTALL#offline-packages), which is essentially a local software source built on the same operating system.



```yaml
repo_enabled: true                # create a yum repo on this infra node?
repo_home: /www                   # repo home dir, `/www` by default
repo_name: pigsty                 # repo name, pigsty by default
repo_endpoint: http://${admin_ip}:80 # access point to this repo by domain or ip:port
repo_remove: true                 # remove existing upstream repo
repo_modules: infra,node,pgsql,redis,minio # which repo modules are installed in repo_upstream
repo_upstream:                    # where to download #
- { name: base           ,description: 'EL 7 Base'         ,module: node  ,releases: [7    ] ,baseurl: { default: 'http://mirror.centos.org/centos/$releasever/os/$basearch/'                    ,china: 'https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/os/$basearch/'       ,europe: 'https://mirrors.xtom.de/centos/$releasever/os/$basearch/'           }}
- { name: updates        ,description: 'EL 7 Updates'      ,module: node  ,releases: [7    ] ,baseurl: { default: 'http://mirror.centos.org/centos/$releasever/updates/$basearch/'               ,china: 'https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/updates/$basearch/'  ,europe: 'https://mirrors.xtom.de/centos/$releasever/updates/$basearch/'      }}
- { name: extras         ,description: 'EL 7 Extras'       ,module: node  ,releases: [7    ] ,baseurl: { default: 'http://mirror.centos.org/centos/$releasever/extras/$basearch/'                ,china: 'https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/extras/$basearch/'   ,europe: 'https://mirrors.xtom.de/centos/$releasever/extras/$basearch/'       }}
- { name: epel           ,description: 'EL 7 EPEL'         ,module: node  ,releases: [7    ] ,baseurl: { default: 'http://download.fedoraproject.org/pub/epel/$releasever/$basearch/'            ,china: 'https://mirrors.tuna.tsinghua.edu.cn/epel/$releasever/$basearch/'            ,europe: 'https://mirrors.xtom.de/epel/$releasever/$basearch/'                }}
- { name: centos-sclo    ,description: 'EL 7 SCLo'         ,module: node  ,releases: [7    ] ,baseurl: { default: 'http://mirror.centos.org/centos/$releasever/sclo/$basearch/sclo/'             ,china: 'https://mirrors.aliyun.com/centos/$releasever/sclo/$basearch/sclo/'          ,europe: 'https://mirrors.xtom.de/centos/$releasever/sclo/$basearch/sclo/'    }}
- { name: centos-sclo-rh ,description: 'EL 7 SCLo rh'      ,module: node  ,releases: [7    ] ,baseurl: { default: 'http://mirror.centos.org/centos/$releasever/sclo/$basearch/rh/'               ,china: 'https://mirrors.aliyun.com/centos/$releasever/sclo/$basearch/rh/'            ,europe: 'https://mirrors.xtom.de/centos/$releasever/sclo/$basearch/rh/'      }}
- { name: baseos         ,description: 'EL 8+ BaseOS'      ,module: node  ,releases: [  8,9] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/BaseOS/$basearch/os/'         ,china: 'https://mirrors.aliyun.com/rockylinux/$releasever/BaseOS/$basearch/os/'      ,europe: 'https://mirrors.xtom.de/rocky/$releasever/BaseOS/$basearch/os/'     }}
- { name: appstream      ,description: 'EL 8+ AppStream'   ,module: node  ,releases: [  8,9] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/AppStream/$basearch/os/'      ,china: 'https://mirrors.aliyun.com/rockylinux/$releasever/AppStream/$basearch/os/'   ,europe: 'https://mirrors.xtom.de/rocky/$releasever/AppStream/$basearch/os/'  }}
- { name: extras         ,description: 'EL 8+ Extras'      ,module: node  ,releases: [  8,9] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/extras/$basearch/os/'         ,china: 'https://mirrors.aliyun.com/rockylinux/$releasever/extras/$basearch/os/'      ,europe: 'https://mirrors.xtom.de/rocky/$releasever/extras/$basearch/os/'     }}
- { name: epel           ,description: 'EL 8+ EPEL'        ,module: node  ,releases: [  8,9] ,baseurl: { default: 'http://download.fedoraproject.org/pub/epel/$releasever/Everything/$basearch/' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/epel/$releasever/Everything/$basearch/' ,europe: 'https://mirrors.xtom.de/epel/$releasever/Everything/$basearch/'     }}
- { name: powertools     ,description: 'EL 8 PowerTools'   ,module: node  ,releases: [  8  ] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/PowerTools/$basearch/os/'     ,china: 'https://mirrors.aliyun.com/rockylinux/$releasever/PowerTools/$basearch/os/'  ,europe: 'https://mirrors.xtom.de/rocky/$releasever/PowerTools/$basearch/os/' }}
- { name: crb            ,description: 'EL 9 CRB'          ,module: node  ,releases: [    9] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/CRB/$basearch/os/'            ,china: 'https://mirrors.aliyun.com/rockylinux/$releasever/CRB/$basearch/os/'         ,europe: 'https://mirrors.xtom.de/rocky/$releasever/CRB/$basearch/os/'        }}
- { name: pgdg-common    ,description: 'PostgreSQL Common' ,module: pgsql ,releases: [7,8,9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/common/redhat/rhel-$releasever-$basearch' , china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/redhat/rhel-$releasever-$basearch' , europe: 'https://mirrors.xtom.de/postgresql/repos/yum/common/redhat/rhel-$releasever-$basearch' }}
- { name: pgdg-extras    ,description: 'PostgreSQL Extra'  ,module: pgsql ,releases: [7,8,9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/common/pgdg-rhel$releasever-extras/redhat/rhel-$releasever-$basearch' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/pgdg-rhel$releasever-extras/redhat/rhel-$releasever-$basearch' , europe: 'https://mirrors.xtom.de/postgresql/repos/yum/common/pgdg-rhel$releasever-extras/redhat/rhel-$releasever-$basearch' }}
- { name: pgdg-el8fix    ,description: 'PostgreSQL EL8FIX' ,module: pgsql ,releases: [  8  ] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/common/pgdg-centos8-sysupdates/redhat/rhel-8-x86_64/' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/pgdg-centos8-sysupdates/redhat/rhel-8-x86_64/' , europe: 'https://mirrors.xtom.de/postgresql/repos/yum/common/pgdg-centos8-sysupdates/redhat/rhel-8-x86_64/' }}
- { name: pgdg-el9fix    ,description: 'PostgreSQL EL9FIX' ,module: pgsql ,releases: [    9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/common/pgdg-rocky9-sysupdates/redhat/rhel-9-x86_64/'  ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/pgdg-rocky9-sysupdates/redhat/rhel-9-x86_64/' , europe: 'https://mirrors.xtom.de/postgresql/repos/yum/common/pgdg-rocky9-sysupdates/redhat/rhel-9-x86_64/' }}
- { name: pgdg12         ,description: 'PostgreSQL 12'     ,module: pgsql ,releases: [7,8,9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/12/redhat/rhel-$releasever-$basearch' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/12/redhat/rhel-$releasever-$basearch' ,europe: 'https://mirrors.xtom.de/postgresql/repos/yum/12/redhat/rhel-$releasever-$basearch' }}
- { name: pgdg13         ,description: 'PostgreSQL 13'     ,module: pgsql ,releases: [7,8,9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/13/redhat/rhel-$releasever-$basearch' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/13/redhat/rhel-$releasever-$basearch' ,europe: 'https://mirrors.xtom.de/postgresql/repos/yum/13/redhat/rhel-$releasever-$basearch' }}
- { name: pgdg14         ,description: 'PostgreSQL 14'     ,module: pgsql ,releases: [7,8,9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/14/redhat/rhel-$releasever-$basearch' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/14/redhat/rhel-$releasever-$basearch' ,europe: 'https://mirrors.xtom.de/postgresql/repos/yum/14/redhat/rhel-$releasever-$basearch' }}
- { name: pgdg15         ,description: 'PostgreSQL 15'     ,module: pgsql ,releases: [7,8,9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/15/redhat/rhel-$releasever-$basearch' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/15/redhat/rhel-$releasever-$basearch' ,europe: 'https://mirrors.xtom.de/postgresql/repos/yum/15/redhat/rhel-$releasever-$basearch' }}
- { name: pgdg16         ,description: 'PostgreSQL 16'     ,module: pgsql ,releases: [  8,9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/16/redhat/rhel-$releasever-$basearch' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/16/redhat/rhel-$releasever-$basearch' ,europe: 'https://mirrors.xtom.de/postgresql/repos/yum/16/redhat/rhel-$releasever-$basearch' }}
- { name: timescaledb    ,description: 'TimescaleDB'       ,module: pgsql ,releases: [7,8,9] ,baseurl: { default: 'https://packagecloud.io/timescale/timescaledb/el/$releasever/$basearch'  }}
- { name: nginx          ,description: 'Nginx Repo'        ,module: infra ,releases: [7,8,9] ,baseurl: { default: 'https://nginx.org/packages/centos/$releasever/$basearch/'                }}
- { name: docker-ce      ,description: 'Docker CE'         ,module: infra ,releases: [7,8,9] ,baseurl: { default: 'https://download.docker.com/linux/centos/$releasever/$basearch/stable' ,china: 'https://mirrors.aliyun.com/docker-ce/linux/centos/$releasever/$basearch/stable' ,europe: 'https://mirrors.xtom.de/docker-ce/linux/centos/$releasever/$basearch/stable' }}
- { name: pigsty-misc    ,description: 'Pigsty Misc'       ,module: infra ,releases: [7,8,9] ,baseurl: { default: 'https://get.pigsty.cc/yum/el$releasever.$basearch' }}
- { name: prometheus     ,description: 'Prometheus'        ,module: infra ,releases: [7,8,9] ,baseurl: { default: 'https://packagecloud.io/prometheus-rpm/release/el/$releasever/$basearch' ,china: 'https://get.pigsty.cc/yum/prometheus/el$releasever.$basearch' }}
- { name: grafana        ,description: 'Grafana'           ,module: infra ,releases: [7,8,9] ,baseurl: { default: 'https://rpm.grafana.com' ,china: 'https://get.pigsty.cc/yum/grafana/$basearch' }}
repo_packages:                    # which packages to be included
  - ansible python3 python3-pip python3-virtualenv python3-requests python3.11-jmespath python3.11-pip dnf-utils modulemd-tools
  - grafana loki logcli promtail prometheus2 alertmanager pushgateway victoria-logs vector
  - node_exporter blackbox_exporter nginx_exporter redis_exporter mysqld_exporter mongodb_exporter kafka_exporter keepalived_exporter
  - redis etcd minio mcli haproxy vip-manager pg_exporter ferretdb sealos nginx createrepo_c sshpass chrony dnsmasq docker-ce docker-compose-plugin
  - lz4 unzip bzip2 zlib yum pv jq git ncdu make patch bash lsof wget uuid tuned nvme-cli numactl grubby sysstat iotop htop rsync tcpdump perf flamegraph
  - netcat socat ftp lrzsz net-tools ipvsadm bind-utils telnet audit ca-certificates openssl openssh-clients readline vim-minimal keepalived
  - patroni patroni-etcd pgbouncer pgbadger pgbackrest pgloader pg_activity pg_filedump timescaledb-tools scws pgFormatter # pgxnclient
  - postgresql14* wal2json_14* pg_repack_14* passwordcheck_cracklib_14* postgresql13* wal2json_13* pg_repack_13* passwordcheck_cracklib_13* postgresql12* wal2json_12* pg_repack_12* passwordcheck_cracklib_12* imgsmlr_15* pg_bigm_15* pg_similarity_15*
  - postgresql15* citus_15* pglogical_15* wal2json_15* pgvector_15* postgis34_15* passwordcheck_cracklib_15* pg_cron_15* pointcloud_15* pg_tle_15* pgsql-http_15* zhparser_15* pg_roaringbitmap_15* pg_net_15* vault_15 pgjwt_15 pg_graphql_15 timescaledb-2-postgresql-15* pg_repack_15*
  - postgresql16* citus_16* pglogical_16* wal2json_16* pgvector_16* postgis34_16* passwordcheck_cracklib_16* pg_cron_16* pointcloud_16* pg_tle_16* pgsql-http_16* zhparser_16* pg_roaringbitmap_16* pg_net_16* vault_16 pgjwt_16 pg_graphql_16 apache-age_15* hydra_15* pgml_15*
  - orafce_15* mysqlcompat_15 mongo_fdw_15* tds_fdw_15* mysql_fdw_15 hdfs_fdw_15 sqlite_fdw_15 pgbouncer_fdw_15 multicorn2_15* powa_15* pg_stat_kcache_15* pg_stat_monitor_15* pg_qualstats_15 pg_track_settings_15 pg_wait_sampling_15 system_stats_15
  - plprofiler_15* plproxy_15 plsh_15* pldebugger_15 plpgsql_check_15* pgtt_15 pgq_15* hypopg_15* timestamp9_15* semver_15* prefix_15* periods_15* ip4r_15* tdigest_15* hll_15* pgmp_15 topn_15* geoip_15 extra_window_functions_15 pgsql_tweaks_15 count_distinct_15
  - pg_background_15 e-maj_15 pg_catcheck_15 pg_prioritize_15 pgcopydb_15 pgcryptokey_15 logerrors_15 pg_top_15 pg_comparator_15 pg_ivm_15* pgsodium_15* pgfincore_15* ddlx_15 credcheck_15 safeupdate_15 pg_squeeze_15* pg_fkpart_15 pg_jobmon_15
  - pg_partman_15 pg_permissions_15 pgexportdoc_15 pgimportdoc_15 pg_statement_rollback_15* pg_hint_plan_15* pg_auth_mon_15 pg_checksums_15 pg_failover_slots_15 pg_readonly_15* postgresql-unit_15* pg_store_plans_15* pg_uuidv7_15* set_user_15* pgaudit17_15 rum_15
repo_url_packages:
  - https://repo.pigsty.cc/etc/pev.html
  - https://repo.pigsty.cc/etc/chart.tgz
  - https://repo.pigsty.cc/etc/plugins.tgz
```


### `repo_enabled`

name: `repo_enabled`, type: `bool`, level: `G/I`

create a yum repo on this infra node? default value: `true`

If you have multiple infra nodes, you can disable yum repo on other standby nodes to reduce Internet traffic.




### `repo_home`

name: `repo_home`, type: `path`, level: `G`

repo home dir, `/www` by default






### `repo_name`

name: `repo_name`, type: `string`, level: `G`

repo name, `pigsty` by default, it is not wise to change this value






### `repo_endpoint`

name: `repo_endpoint`, type: `url`, level: `G`

access point to this repo by domain or ip:port, default value: `http://${admin_ip}:80`

If you have changed the [`nginx_port`](#nginx_port) or [`nginx_ssl_port`](#nginx_ssl_port), or use a different infra node from admin node, please adjust this parameter accordingly.

The `${admin_ip}` will be replaced with actual [`admin_ip`](#admin_ip) during runtime.






### `repo_remove`

name: `repo_remove`, type: `bool`, level: `G/A`

remove existing upstream repo, default value: `true`

If you want to keep existing upstream repo, set this value to `false`.




### `repo_modules`

name: `repo_modules`, type: `string`, level: `G/A`

which repo modules are installed in repo_upstream, default value: `infra,node,pgsql,redis,minio`

This is a comma separated value string, it is used to filter entries in [`repo_upstream`](#repo_upstream) with corresponding `module` field. 






### `repo_upstream`

name: `repo_upstream`, type: `upstream[]`, level: `G`

where to download upstream packages, default values are for EL 7/8/9:

```yaml
repo_upstream:                    # where to download #
  - { name: pigsty-infra   ,description: 'Pigsty Infra'      ,module: infra ,releases: [7,8,9] ,baseurl: { default: 'https://repo.pigsty.cc/rpm/infra/$basearch' }}
  - { name: nginx          ,description: 'Nginx Repo'        ,module: infra ,releases: [7,8,9] ,baseurl: { default: 'https://nginx.org/packages/centos/$releasever/$basearch/' }}
  - { name: docker-ce      ,description: 'Docker CE'         ,module: infra ,releases: [7,8,9] ,baseurl: { default: 'https://download.docker.com/linux/centos/$releasever/$basearch/stable'   ,china: 'https://mirrors.aliyun.com/docker-ce/linux/centos/$releasever/$basearch/stable'   ,europe: 'https://mirrors.xtom.de/docker-ce/linux/centos/$releasever/$basearch/stable' }}
  - { name: prometheus     ,description: 'Prometheus'        ,module: infra ,releases: [7,8,9] ,baseurl: { default: 'https://packagecloud.io/prometheus-rpm/release/el/$releasever/$basearch' ,china: 'https://repo.pigsty.cc/rpm/prometheus/el$releasever.$basearch' }}
  - { name: grafana        ,description: 'Grafana'           ,module: infra ,releases: [7,8,9] ,baseurl: { default: 'https://rpm.grafana.com' ,china: 'https://repo.pigsty.cc/rpm/grafana/$basearch' }}
  - { name: base           ,description: 'EL 7 Base'         ,module: node  ,releases: [7    ] ,baseurl: { default: 'http://mirror.centos.org/centos/$releasever/os/$basearch/'                    ,china: 'https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/os/$basearch/'       ,europe: 'https://mirrors.xtom.de/centos/$releasever/os/$basearch/'           }}
  - { name: updates        ,description: 'EL 7 Updates'      ,module: node  ,releases: [7    ] ,baseurl: { default: 'http://mirror.centos.org/centos/$releasever/updates/$basearch/'               ,china: 'https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/updates/$basearch/'  ,europe: 'https://mirrors.xtom.de/centos/$releasever/updates/$basearch/'      }}
  - { name: extras         ,description: 'EL 7 Extras'       ,module: node  ,releases: [7    ] ,baseurl: { default: 'http://mirror.centos.org/centos/$releasever/extras/$basearch/'                ,china: 'https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/extras/$basearch/'   ,europe: 'https://mirrors.xtom.de/centos/$releasever/extras/$basearch/'       }}
  - { name: epel           ,description: 'EL 7 EPEL'         ,module: node  ,releases: [7    ] ,baseurl: { default: 'http://download.fedoraproject.org/pub/epel/$releasever/$basearch/'            ,china: 'https://mirrors.tuna.tsinghua.edu.cn/epel/$releasever/$basearch/'            ,europe: 'https://mirrors.xtom.de/epel/$releasever/$basearch/'                }}
  - { name: centos-sclo    ,description: 'EL 7 SCLo'         ,module: node  ,releases: [7    ] ,baseurl: { default: 'http://mirror.centos.org/centos/$releasever/sclo/$basearch/sclo/'             ,china: 'https://mirrors.aliyun.com/centos/$releasever/sclo/$basearch/sclo/'          ,europe: 'https://mirrors.xtom.de/centos/$releasever/sclo/$basearch/sclo/'    }}
  - { name: centos-sclo-rh ,description: 'EL 7 SCLo rh'      ,module: node  ,releases: [7    ] ,baseurl: { default: 'http://mirror.centos.org/centos/$releasever/sclo/$basearch/rh/'               ,china: 'https://mirrors.aliyun.com/centos/$releasever/sclo/$basearch/rh/'            ,europe: 'https://mirrors.xtom.de/centos/$releasever/sclo/$basearch/rh/'      }}
  - { name: baseos         ,description: 'EL 8+ BaseOS'      ,module: node  ,releases: [  8,9] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/BaseOS/$basearch/os/'         ,china: 'https://mirrors.aliyun.com/rockylinux/$releasever/BaseOS/$basearch/os/'      ,europe: 'https://mirrors.xtom.de/rocky/$releasever/BaseOS/$basearch/os/'     }}
  - { name: appstream      ,description: 'EL 8+ AppStream'   ,module: node  ,releases: [  8,9] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/AppStream/$basearch/os/'      ,china: 'https://mirrors.aliyun.com/rockylinux/$releasever/AppStream/$basearch/os/'   ,europe: 'https://mirrors.xtom.de/rocky/$releasever/AppStream/$basearch/os/'  }}
  - { name: extras         ,description: 'EL 8+ Extras'      ,module: node  ,releases: [  8,9] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/extras/$basearch/os/'         ,china: 'https://mirrors.aliyun.com/rockylinux/$releasever/extras/$basearch/os/'      ,europe: 'https://mirrors.xtom.de/rocky/$releasever/extras/$basearch/os/'     }}
  - { name: epel           ,description: 'EL 8+ EPEL'        ,module: node  ,releases: [  8,9] ,baseurl: { default: 'http://download.fedoraproject.org/pub/epel/$releasever/Everything/$basearch/' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/epel/$releasever/Everything/$basearch/' ,europe: 'https://mirrors.xtom.de/epel/$releasever/Everything/$basearch/'     }}
  - { name: powertools     ,description: 'EL 8 PowerTools'   ,module: node  ,releases: [  8  ] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/PowerTools/$basearch/os/'     ,china: 'https://mirrors.aliyun.com/rockylinux/$releasever/PowerTools/$basearch/os/'  ,europe: 'https://mirrors.xtom.de/rocky/$releasever/PowerTools/$basearch/os/' }}
  - { name: crb            ,description: 'EL 9 CRB'          ,module: node  ,releases: [    9] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/CRB/$basearch/os/'            ,china: 'https://mirrors.aliyun.com/rockylinux/$releasever/CRB/$basearch/os/'         ,europe: 'https://mirrors.xtom.de/rocky/$releasever/CRB/$basearch/os/'        }}
  - { name: pigsty-pgsql   ,description: 'Pigsty PgSQL'      ,module: pgsql ,releases: [7,8,9] ,baseurl: { default: 'https://repo.pigsty.cc/rpm/pgsql/el$releasever.$basearch'  }}
  - { name: pgdg-common    ,description: 'PostgreSQL Common' ,module: pgsql ,releases: [7,8,9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/common/redhat/rhel-$releasever-$basearch' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/redhat/rhel-$releasever-$basearch' , europe: 'https://mirrors.xtom.de/postgresql/repos/yum/common/redhat/rhel-$releasever-$basearch' }}
  - { name: pgdg-extras    ,description: 'PostgreSQL Extra'  ,module: pgsql ,releases: [7,8,9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/common/pgdg-rhel$releasever-extras/redhat/rhel-$releasever-$basearch' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/pgdg-rhel$releasever-extras/redhat/rhel-$releasever-$basearch' , europe: 'https://mirrors.xtom.de/postgresql/repos/yum/common/pgdg-rhel$releasever-extras/redhat/rhel-$releasever-$basearch' }}
  - { name: pgdg-el8fix    ,description: 'PostgreSQL EL8FIX' ,module: pgsql ,releases: [  8  ] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/common/pgdg-centos8-sysupdates/redhat/rhel-8-x86_64/' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/pgdg-centos8-sysupdates/redhat/rhel-8-x86_64/' , europe: 'https://mirrors.xtom.de/postgresql/repos/yum/common/pgdg-centos8-sysupdates/redhat/rhel-8-x86_64/' }}
  - { name: pgdg-el9fix    ,description: 'PostgreSQL EL9FIX' ,module: pgsql ,releases: [    9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/common/pgdg-rocky9-sysupdates/redhat/rhel-9-x86_64/'  ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/pgdg-rocky9-sysupdates/redhat/rhel-9-x86_64/' , europe: 'https://mirrors.xtom.de/postgresql/repos/yum/common/pgdg-rocky9-sysupdates/redhat/rhel-9-x86_64/' }}
  - { name: pgdg12         ,description: 'PostgreSQL 12'     ,module: pgsql ,releases: [7,8,9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/12/redhat/rhel-$releasever-$basearch' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/12/redhat/rhel-$releasever-$basearch' ,europe: 'https://mirrors.xtom.de/postgresql/repos/yum/12/redhat/rhel-$releasever-$basearch' }}
  - { name: pgdg13         ,description: 'PostgreSQL 13'     ,module: pgsql ,releases: [7,8,9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/13/redhat/rhel-$releasever-$basearch' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/13/redhat/rhel-$releasever-$basearch' ,europe: 'https://mirrors.xtom.de/postgresql/repos/yum/13/redhat/rhel-$releasever-$basearch' }}
  - { name: pgdg14         ,description: 'PostgreSQL 14'     ,module: pgsql ,releases: [7,8,9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/14/redhat/rhel-$releasever-$basearch' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/14/redhat/rhel-$releasever-$basearch' ,europe: 'https://mirrors.xtom.de/postgresql/repos/yum/14/redhat/rhel-$releasever-$basearch' }}
  - { name: pgdg15         ,description: 'PostgreSQL 15'     ,module: pgsql ,releases: [7,8,9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/15/redhat/rhel-$releasever-$basearch' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/15/redhat/rhel-$releasever-$basearch' ,europe: 'https://mirrors.xtom.de/postgresql/repos/yum/15/redhat/rhel-$releasever-$basearch' }}
  - { name: pgdg16         ,description: 'PostgreSQL 16'     ,module: pgsql ,releases: [  8,9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/16/redhat/rhel-$releasever-$basearch' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/16/redhat/rhel-$releasever-$basearch' ,europe: 'https://mirrors.xtom.de/postgresql/repos/yum/16/redhat/rhel-$releasever-$basearch' }}
  - { name: timescaledb    ,description: 'TimescaleDB'       ,module: pgsql ,releases: [7,8,9] ,baseurl: { default: 'https://packagecloud.io/timescale/timescaledb/el/$releasever/$basearch'  }}
  - { name: pigsty-redis   ,description: 'Pigsty Redis'      ,module: redis ,releases: [7,8,9] ,baseurl: { default: 'https://repo.pigsty.cc/rpm/redis/el$releasever.$basearch'  }}
  - { name: pigsty-minio   ,description: 'Pigsty MinIO'      ,module: minio ,releases: [7,8,9] ,baseurl: { default: 'https://repo.pigsty.cc/rpm/minio/$basearch'  }}
```

For Ubuntu 20.04 & 22.04, the proper value needs to be explicitly specified in global/cluster/host vars:

```yaml
repo_upstream:
  - { name: base        ,description: 'Ubuntu Basic'     ,module: node  ,releases: [20,22] ,baseurl: { default: 'https://mirrors.edge.kernel.org/${distro_name}/ ${distro_codename}           main universe multiverse restricted' ,china: 'https://mirrors.aliyun.com/${distro_name}/ ${distro_codename}           main restricted universe multiverse' }}
  - { name: updates     ,description: 'Ubuntu Updates'   ,module: node  ,releases: [20,22] ,baseurl: { default: 'https://mirrors.edge.kernel.org/${distro_name}/ ${distro_codename}-backports main restricted universe multiverse' ,china: 'https://mirrors.aliyun.com/${distro_name}/ ${distro_codename}-updates   main restricted universe multiverse' }}
  - { name: backports   ,description: 'Ubuntu Backports' ,module: node  ,releases: [20,22] ,baseurl: { default: 'https://mirrors.edge.kernel.org/${distro_name}/ ${distro_codename}-security  main restricted universe multiverse' ,china: 'https://mirrors.aliyun.com/${distro_name}/ ${distro_codename}-backports main restricted universe multiverse' }}
  - { name: security    ,description: 'Ubuntu Security'  ,module: node  ,releases: [20,22] ,baseurl: { default: 'https://mirrors.edge.kernel.org/${distro_name}/ ${distro_codename}-updates   main restricted universe multiverse' ,china: 'https://mirrors.aliyun.com/${distro_name}/ ${distro_codename}-security  main restricted universe multiverse' }}
  - { name: haproxy     ,description: 'HAProxy'          ,module: node  ,releases: [20,22] ,baseurl: { default: 'https://ppa.launchpadcontent.net/vbernat/haproxy-2.8/${distro_name}/ ${distro_codename} main'  }}
  - { name: nginx       ,description: 'Nginx'            ,module: infra ,releases: [20,22] ,baseurl: { default: 'http://nginx.org/packages/${distro_name}/  ${distro_codename} nginx' }}
  - { name: docker-ce   ,description: 'Docker'           ,module: infra ,releases: [20,22] ,baseurl: { default: 'https://download.docker.com/linux/${distro_name}/ ${distro_codename} stable' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/${distro_name}/ ${distro_codename} stable' }}
  - { name: grafana     ,description: 'Grafana'          ,module: infra ,releases: [20,22] ,baseurl: { default: 'https://apt.grafana.com stable main' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/grafana/apt/ stable main' }}
  - { name: infra       ,description: 'Pigsty Infra'     ,module: infra ,releases: [20,22] ,baseurl: { default: 'https://repo.pigsty.cc/deb/infra/amd64/ ./' }} # prometheus-deb packages
  - { name: pgdg        ,description: 'PGDG'             ,module: pgsql ,releases: [20,22] ,baseurl: { default: 'http://apt.postgresql.org/pub/repos/apt/ ${distro_codename}-pgdg main' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/apt/ ${distro_codename}-pgdg main' }}
  - { name: citus       ,description: 'Citus'            ,module: pgsql ,releases: [20,22] ,baseurl: { default: 'https://packagecloud.io/citusdata/community/${distro_name}/ ${distro_codename} main'   }}
  - { name: timescaledb ,description: 'Timescaledb'      ,module: pgsql ,releases: [20,22] ,baseurl: { default: 'https://packagecloud.io/timescale/timescaledb/${distro_name}/ ${distro_codename} main' }}
  - { name: pgsql       ,description: 'Pigsty PgSQL'     ,module: pgsql ,releases: [20,22] ,baseurl: { default: 'https://repo.pigsty.cc/deb/pgsql/${distro_codename}.amd64/ ./' }}
  - { name: redis       ,description: 'Pigsty Redis'     ,module: redis ,releases: [20,22] ,baseurl: { default: 'https://packages.redis.io/deb ${distro_codename} main' }}
  - { name: minio       ,description: 'Pigsty MinIO'     ,module: minio ,releases: [20,22] ,baseurl: { default: 'https://repo.pigsty.cc/deb/minio/amd64/ ./' ,europe: 'https://packagecloud.io/pigsty/minio/ubuntu/ jammy main' }}
```

For Debian 11 & 12, the proper value needs to be explicitly specified in global/cluster/host vars:

```yaml
repo_upstream:
  - { name: base        ,description: 'Debian Basic'    ,module: node  ,releases: [11,12] ,baseurl: { default: 'http://deb.debian.org/debian/ ${distro_codename} main non-free-firmware'                       ,china: 'https://mirrors.aliyun.com/debian/ ${distro_codename} main restricted universe multiverse' }}
  - { name: updates     ,description: 'Debian Updates'  ,module: node  ,releases: [11,12] ,baseurl: { default: 'http://deb.debian.org/debian/ ${distro_codename}-updates main non-free-firmware'               ,china: 'https://mirrors.aliyun.com/debian/ ${distro_codename}-updates main restricted universe multiverse' }}
  - { name: security    ,description: 'Debian Security' ,module: node  ,releases: [11,12] ,baseurl: { default: 'http://security.debian.org/debian-security ${distro_codename}-security main non-free-firmware' }}
  - { name: haproxy     ,description: 'HAProxy'         ,module: node  ,releases: [11,12] ,baseurl: { default: 'http://haproxy.debian.net ${distro_codename}-backports-2.8 main'    }}
  - { name: nginx       ,description: 'Nginx'           ,module: infra ,releases: [11,12] ,baseurl: { default: 'http://nginx.org/packages/mainline/debian ${distro_codename} nginx' }}
  - { name: docker-ce   ,description: 'Docker'          ,module: infra ,releases: [11,12] ,baseurl: { default: 'https://download.docker.com/linux/debian ${distro_codename} stable' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/debian/ ${distro_codename} stable' }}
  - { name: grafana     ,description: 'Grafana'         ,module: infra ,releases: [11,12] ,baseurl: { default: 'https://apt.grafana.com stable main' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/grafana/apt/ stable main' }}
  - { name: infra       ,description: 'Pigsty Infra'    ,module: infra ,releases: [11,12] ,baseurl: { default: 'https://repo.pigsty.cc/deb/infra/amd64/ ./' }} # prometheus-deb packages
  - { name: pgdg        ,description: 'PGDG'            ,module: pgsql ,releases: [11,12] ,baseurl: { default: 'http://apt.postgresql.org/pub/repos/apt/ ${distro_codename}-pgdg main' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/apt/ ${distro_codename}-pgdg main' }}
  - { name: citus       ,description: 'Citus'           ,module: pgsql ,releases: [11,12] ,baseurl: { default: 'https://packagecloud.io/citusdata/community/debian/ ${distro_codename} main'   }}
  - { name: timescaledb ,description: 'Timescaledb'     ,module: pgsql ,releases: [11,12] ,baseurl: { default: 'https://packagecloud.io/timescale/timescaledb/debian/ ${distro_codename} main' }}
  - { name: pgsql       ,description: 'Pigsty PGSQL'    ,module: pgsql ,releases: [11,12] ,baseurl: { default: 'https://repo.pigsty.cc/deb/pgsql/${distro_codename}.amd64/ ./' }}
  - { name: redis       ,description: 'Pigsty Redis'    ,module: redis ,releases: [11,12] ,baseurl: { default: 'https://packages.redis.io/deb ${distro_codename} main' }}
  - { name: minio       ,description: 'Pigsty MinIO'    ,module: minio ,releases: [11,12] ,baseurl: { default: 'https://repo.pigsty.cc/deb/minio/amd64/ ./' ,europe: 'https://packagecloud.io/pigsty/minio/ubuntu/ jammy main' }}
```

Pigsty [`build.yml`](https://github.com/Vonng/pigsty/blob/master/files/pigsty/build.yml) will have the default value for each OS.




### `repo_packages`

name: `repo_packages`, type: `string[]`, level: `G`

which packages to be included, default values: 

```yaml
repo_packages:                    # which packages to be included
- ansible python3 python3-pip python3-virtualenv python3-requests python3.11-jmespath python3.11-pip dnf-utils modulemd-tools
- grafana loki logcli promtail prometheus2 alertmanager pushgateway victoria-logs vector
- node_exporter blackbox_exporter nginx_exporter redis_exporter mysqld_exporter mongodb_exporter kafka_exporter keepalived_exporter
- redis etcd minio mcli haproxy vip-manager pg_exporter ferretdb sealos nginx createrepo_c sshpass chrony dnsmasq docker-ce docker-compose-plugin
- lz4 unzip bzip2 zlib yum pv jq git ncdu make patch bash lsof wget uuid tuned nvme-cli numactl grubby sysstat iotop htop rsync tcpdump perf flamegraph
- netcat socat ftp lrzsz net-tools ipvsadm bind-utils telnet audit ca-certificates openssl openssh-clients readline vim-minimal keepalived
- patroni patroni-etcd pgbouncer pgbadger pgbackrest pgloader pg_activity pg_filedump timescaledb-tools scws pgFormatter # pgxnclient
- postgresql14* wal2json_14* pg_repack_14* passwordcheck_cracklib_14* postgresql13* wal2json_13* pg_repack_13* passwordcheck_cracklib_13* postgresql12* wal2json_12* pg_repack_12* passwordcheck_cracklib_12* imgsmlr_15* pg_bigm_15* pg_similarity_15*
- postgresql15* citus_15* pglogical_15* wal2json_15* pgvector_15* postgis34_15* passwordcheck_cracklib_15* pg_cron_15* pointcloud_15* pg_tle_15* pgsql-http_15* zhparser_15* pg_roaringbitmap_15* pg_net_15* vault_15 pgjwt_15 pg_graphql_15 timescaledb-2-postgresql-15* pg_repack_15*
- postgresql16* citus_16* pglogical_16* wal2json_16* pgvector_16* postgis34_16* passwordcheck_cracklib_16* pg_cron_16* pointcloud_16* pg_tle_16* pgsql-http_16* zhparser_16* pg_roaringbitmap_16* pg_net_16* vault_16 pgjwt_16 pg_graphql_16 apache-age_15* hydra_15* pgml_15*
- orafce_15* mysqlcompat_15 mongo_fdw_15* tds_fdw_15* mysql_fdw_15 hdfs_fdw_15 sqlite_fdw_15 pgbouncer_fdw_15 multicorn2_15* powa_15* pg_stat_kcache_15* pg_stat_monitor_15* pg_qualstats_15 pg_track_settings_15 pg_wait_sampling_15 system_stats_15
- plprofiler_15* plproxy_15 plsh_15* pldebugger_15 plpgsql_check_15* pgtt_15 pgq_15* hypopg_15* timestamp9_15* semver_15* prefix_15* periods_15* ip4r_15* tdigest_15* hll_15* pgmp_15 topn_15* geoip_15 extra_window_functions_15 pgsql_tweaks_15 count_distinct_15
- pg_background_15 e-maj_15 pg_catcheck_15 pg_prioritize_15 pgcopydb_15 pgcryptokey_15 logerrors_15 pg_top_15 pg_comparator_15 pg_ivm_15* pgsodium_15* pgfincore_15* ddlx_15 credcheck_15 safeupdate_15 pg_squeeze_15* pg_fkpart_15 pg_jobmon_15
- pg_partman_15 pg_permissions_15 pgexportdoc_15 pgimportdoc_15 pg_statement_rollback_15* pg_hint_plan_15* pg_auth_mon_15 pg_checksums_15 pg_failover_slots_15 pg_readonly_15* postgresql-unit_15* pg_store_plans_15* pg_uuidv7_15* set_user_15* pgaudit17_15 rum_15
```

Each line is a set of package names separated by spaces, where the specified software will be downloaded via `repotrack`.

EL7 packages is slightly different, here are some ad hoc packages:

* EL7:  `python36-requests python36-idna yum-utils yum-utils`, and `postgis33`
* EL8:  `python3.11-jmespath dnf-utils modulemd-tools`, and `postgis34`
* EL9:  Same as EL8, Missing `pgxnclient` yet

For debian/ubuntu, the proper value needs to be explicitly specified in global/cluster/host vars:

```yaml
repo_packages:                    # which packages to be included
  - ansible python3 python3-pip python3-venv python3-jmespath dpkg-dev
  - grafana loki logcli promtail prometheus2 alertmanager pushgateway blackbox-exporter
  - node-exporter pg-exporter nginx-exporter redis-exporter mysqld-exporter mongodb-exporter kafka-exporter keepalived-exporter
  - lz4 unzip bzip2 zlib1g pv jq git ncdu make patch bash lsof wget uuid tuned nvme-cli numactl sysstat iotop htop rsync tcpdump linux-tools-generic
  - netcat socat ftp lrzsz net-tools ipvsadm dnsutils telnet ca-certificates openssl openssh-client libreadline-dev vim-tiny keepalived acl
  - redis minio mcli etcd haproxy vip-manager nginx sshpass chrony dnsmasq docker-ce docker-compose-plugin ferretdb sealos
  - patroni pgbouncer pgbackrest pgbadger pgloader pg-activity pgloader pg-activity postgresql-filedump pgxnclient pgformatter
  - postgresql-client-16 postgresql-16 postgresql-server-dev-16 postgresql-plpython3-16 postgresql-plperl-16 postgresql-pltcl-16 postgresql-16-wal2json postgresql-16-repack
  - postgresql-client-15 postgresql-15 postgresql-server-dev-15 postgresql-plpython3-15 postgresql-plperl-15 postgresql-pltcl-15 postgresql-15-wal2json postgresql-15-repack
  - postgresql-client-14 postgresql-14 postgresql-server-dev-14 postgresql-plpython3-14 postgresql-plperl-14 postgresql-pltcl-14 postgresql-14-wal2json postgresql-14-repack
  - postgresql-client-13 postgresql-13 postgresql-server-dev-13 postgresql-plpython3-13 postgresql-plperl-13 postgresql-pltcl-13 postgresql-13-wal2json postgresql-13-repack
  - postgresql-client-12 postgresql-12 postgresql-server-dev-12 postgresql-plpython3-12 postgresql-plperl-12 postgresql-pltcl-12 postgresql-12-wal2json postgresql-12-repack
  - postgresql-15-postgis-3 postgresql-15-postgis-3-scripts postgresql-15-citus-12.1 postgresql-15-pgvector timescaledb-2-postgresql-15 postgresql-pgml-15  # pgml-15 not available in ubuntu20
  - postgresql-16-postgis-3 postgresql-16-postgis-3-scripts postgresql-16-citus-12.1 postgresql-16-pgvector postgresql-pgml-15 pg-graphql pg-net
  - postgresql-15-credcheck postgresql-15-cron postgresql-15-debversion postgresql-15-decoderbufs postgresql-15-dirtyread postgresql-15-extra-window-functions postgresql-15-first-last-agg
  - postgresql-15-hll postgresql-15-hypopg postgresql-15-icu-ext postgresql-15-ip4r postgresql-15-jsquery postgresql-15-londiste-sql postgresql-15-mimeo postgresql-15-mysql-fdw postgresql-15-numeral
  - postgresql-15-ogr-fdw postgresql-15-omnidb postgresql-15-oracle-fdw postgresql-15-orafce postgresql-15-partman postgresql-15-periods postgresql-15-pg-catcheck postgresql-15-pg-checksums
  - postgresql-15-pg-fact-loader postgresql-15-pg-qualstats postgresql-15-pg-stat-kcache postgresql-15-pg-track-settings postgresql-15-pg-wait-sampling postgresql-15-pgaudit postgresql-15-pgauditlogtofile
  - postgresql-15-pgextwlist postgresql-15-pgfincore postgresql-15-pgl-ddl-deploy postgresql-15-pglogical postgresql-15-pglogical-ticker postgresql-15-pgmemcache postgresql-15-pgmp
  - postgresql-15-pgpcre postgresql-15-pgq-node postgresql-15-pgq3 postgresql-15-pgsphere postgresql-15-pgtap postgresql-15-pldebugger postgresql-15-pllua postgresql-15-plpgsql-check
  - postgresql-15-plprofiler postgresql-15-plproxy postgresql-15-plsh postgresql-15-pointcloud postgresql-15-powa postgresql-15-prefix postgresql-15-preprepare postgresql-15-prioritize
  - postgresql-15-q3c postgresql-15-rational postgresql-15-rum postgresql-15-semver postgresql-15-set-user postgresql-15-show-plans postgresql-15-similarity postgresql-15-squeeze
  - postgresql-15-tablelog postgresql-15-tdigest postgresql-15-tds-fdw postgresql-15-toastinfo postgresql-15-topn postgresql-15-unit postgresql-15-rdkit # 15-rdkit not available in ubuntu20
```

There are some differences between Ubuntu / Debian too:

- Ubuntu 22.04: `postgresql-pgml-15`, `postgresql-15-rdkit`, `linux-tools-generic`(perf), `netcat`, `ftp`
- Ubuntu 20.04: `postgresql-15-rdkit` not available. `postgresql-15-postgis-3` must be installed online (without local repo)
- Debian 12: `netcat` -> `netcat-openbsd`，`ftp` -> `tnftp`，`linux-tools-generic`(perf) -> `linux-perf`, the rest is same as Ubuntu
- Debian 11: Same as Debian 12, except for `postgresql-15-rdkit` not available

Each line is a set of package names separated by spaces, where the specified software and their dependencies will be downloaded via `repotrack` or `apt download` accordingly.

Pigsty [`build.yml`](https://github.com/Vonng/pigsty/blob/master/files/pigsty/build.yml) will have the default value for each OS.






### `repo_url_packages`

name: `repo_url_packages`, type: `string[]`, level: `G`

extra packages from url, default values:

```yaml
repo_url_packages:
  - https://repo.pigsty.cc/etc/pev.html     # postgres explain visualizer
  - https://repo.pigsty.cc/etc/chart.tgz    # grafana extra map geojson data
  - https://repo.pigsty.cc/etc/plugins.tgz  # grafana plugins
```

These are optional add-ons, which will be downloaded via URL from the Internet directly.

For example, if you don't download the `plugins.tgz`, Pigsty will download it later during grafana setup.





------------------------------

## `INFRA_PACKAGE`

These packages are installed on infra nodes only, including common rpm/deb/pip packages.



### `infra_packages`

name: `infra_packages`, type: `string[]`, level: `G`

packages to be installed on infra nodes, default value:

```yaml
infra_packages:                   # packages to be installed on infra nodes
  - grafana,loki,logcli,promtail,prometheus2,alertmanager,karma,pushgateway
  - node_exporter,blackbox_exporter,nginx_exporter,redis_exporter,pg_exporter
  - nginx,dnsmasq,ansible,postgresql15,redis,mcli,etcd,python3-requests
```

Default value for Debian/Ubuntu should be explicitly overwrite: 

```yaml
- grafana,loki,logcli,promtail,prometheus2,alertmanager,pushgateway,blackbox-exporter
- node-exporter,blackbox-exporter,nginx-exporter,redis-exporter,pg-exporter
- nginx,dnsmasq,ansible,postgresql-client-16,redis,mcli,etcd,python3-requests
```



### `infra_packages_pip`

name: `infra_packages_pip`, type: `string`, level: `G`

pip installed packages for infra nodes, default value is empty string








------------------------------

## `NGINX`

Pigsty exposes all Web services through Nginx: Home Page, Grafana, Prometheus, AlertManager, etc...,
and other optional tools such as PGWe, Jupyter Lab, Pgadmin, Bytebase ,and other static resource & report such as `pev`, `schemaspy` & `pgbadger`

This nginx also serves as a local yum/apt repo.


```yaml
nginx_enabled: true               # enable nginx on this infra node?
nginx_exporter_enabled: true      # enable nginx_exporter on this infra node?
nginx_sslmode: enable             # nginx ssl mode? disable,enable,enforce
nginx_home: /www                  # nginx content dir, `/www` by default
nginx_port: 80                    # nginx listen port, 80 by default
nginx_ssl_port: 443               # nginx ssl listen port, 443 by default
nginx_navbar:                     # nginx index page navigation links
  - { name: CA Cert ,url: '/ca.crt'   ,desc: 'pigsty self-signed ca.crt'   }
  - { name: Package ,url: '/pigsty'   ,desc: 'local yum repo packages'     }
  - { name: PG Logs ,url: '/logs'     ,desc: 'postgres raw csv logs'       }
  - { name: Reports ,url: '/report'   ,desc: 'pgbadger summary report'     }
  - { name: Explain ,url: '/pigsty/pev.html' ,desc: 'postgres explain visualizer' }
  ```


### `nginx_enabled`

name: `nginx_enabled`, type: `bool`, level: `G/I`

enable nginx on this infra node? default value: `true`





### `nginx_exporter_enabled`

name: `nginx_exporter_enabled`, type: `bool`, level: `G/I`

enable nginx_exporter on this infra node? default value: `true`.

set to false will disable `/nginx` health check stub too: If your nginx does not support `/nginx` stub, you can set this value to `false` to disable it.





### `nginx_sslmode`

name: `nginx_sslmode`, type: `enum`, level: `G`

nginx ssl mode? which could be: `disable`, `enable`, `enforce`, the default value: `enable`

* `disable`: listen on [`nginx_port`](#nginx_port) and serve plain HTTP only
* `enable`: also listen on [`nginx_ssl_port`](#nginx_ssl_port) and serve HTTPS
* `enforce`: all links will be rendered as `https://` by default





### `nginx_home`

name: `nginx_home`, type: `path`, level: `G`

nginx web server static content dir, `/www` by default

Nginx root directory which contains static resource and repo resource. It's wise to set this value same as [`repo_home`](#repo_home) so that local repo content is automatically served.




### `nginx_port`

name: `nginx_port`, type: `port`, level: `G`

nginx listen port which serves the HTTP requests, `80` by default.

If your default 80 port is occupied or unavailable, you can consider using another port, and change [`repo_endpoint`](#repo_endpoint) and [`node_repo_local_urls`](#node_repo_local_urls) accordingly.






### `nginx_ssl_port`

name: `nginx_ssl_port`, type: `port`, level: `G`

nginx ssl listen port, `443` by default





### `nginx_navbar`

name: `nginx_navbar`, type: `index[]`, level: `G`

nginx index page navigation links

default value:

```yaml
nginx_navbar:                     # nginx index page navigation links
  - { name: CA Cert ,url: '/ca.crt'   ,desc: 'pigsty self-signed ca.crt'   }
  - { name: Package ,url: '/pigsty'   ,desc: 'local yum repo packages'     }
  - { name: PG Logs ,url: '/logs'     ,desc: 'postgres raw csv logs'       }
  - { name: Reports ,url: '/report'   ,desc: 'pgbadger summary report'     }
  - { name: Explain ,url: '/pigsty/pev.html' ,desc: 'postgres explain visualizer' }
```

Each record is rendered as a navigation link to the Pigsty home page App drop-down menu, and the apps are all optional, mounted by default on the Pigsty default server under `http://pigsty/`.

The `url` parameter specifies the URL PATH for the app, with the exception that if the `${grafana}` string is present in the URL, it will be automatically replaced with the Grafana domain name defined in [`infra_portal`](#infra_portal).





------------------------------

## `DNS`


Pigsty will launch a default DNSMASQ server on infra nodes to serve DNS inquiry. such as  `h.pigsty` `a.pigsty` `p.pigsty` `g.pigsty` and `sss.pigsty` for optional MinIO service.

All records will be added to infra node's `/etc/hosts.d/*`.

You have to add `nameserver {{ admin_ip }}` to your `/etc/resolv` to use this dns server, and [`node_dns_servers`](#node_dns_servers) will do the trick.


```yaml
dns_enabled: true                 # setup dnsmasq on this infra node?
dns_port: 53                      # dns server listen port, 53 by default
dns_records:                      # dynamic dns records resolved by dnsmasq
  - "${admin_ip} h.pigsty a.pigsty p.pigsty g.pigsty"
  - "${admin_ip} api.pigsty adm.pigsty cli.pigsty ddl.pigsty lab.pigsty git.pigsty sss.pigsty wiki.pigsty"
```


### `dns_enabled`

name: `dns_enabled`, type: `bool`, level: `G/I`

setup dnsmasq on this infra node? default value: `true`

If you don't want to use the default DNS server, you can set this value to `false` to disable it.
And use [`node_default_etc_hosts`](#node_default_etc_hosts) and [`node_etc_hosts`](#node_etc_hosts) instead.




### `dns_port`

name: `dns_port`, type: `port`, level: `G`

dns server listen port, `53` by default





### `dns_records`

name: `dns_records`, type: `string[]`, level: `G`

dynamic dns records resolved by dnsmasq, Some auxiliary domain names will be written to `/etc/hosts.d/default` on infra nodes by default

```yaml
dns_records:                      # dynamic dns records resolved by dnsmasq
  - "${admin_ip} h.pigsty a.pigsty p.pigsty g.pigsty"
  - "${admin_ip} api.pigsty adm.pigsty cli.pigsty ddl.pigsty lab.pigsty git.pigsty sss.pigsty wiki.pigsty"
```







------------------------------

## `PROMETHEUS`

Prometheus is used as time-series database for metrics scrape, storage & analysis.


```yaml
prometheus_enabled: true          # enable prometheus on this infra node?
prometheus_clean: true            # clean prometheus data during init?
prometheus_data: /data/prometheus # prometheus data dir, `/data/prometheus` by default
prometheus_sd_interval: 5s        # prometheus target refresh interval, 5s by default
prometheus_scrape_interval: 10s   # prometheus scrape & eval interval, 10s by default
prometheus_scrape_timeout: 8s     # prometheus global scrape timeout, 8s by default
prometheus_options: '--storage.tsdb.retention.time=15d' # prometheus extra server options
pushgateway_enabled: true         # setup pushgateway on this infra node?
pushgateway_options: '--persistence.interval=1m' # pushgateway extra server options
blackbox_enabled: true            # setup blackbox_exporter on this infra node?
blackbox_options: ''              # blackbox_exporter extra server options
alertmanager_enabled: true        # setup alertmanager on this infra node?
alertmanager_options: ''          # alertmanager extra server options
exporter_metrics_path: /metrics   # exporter metric path, `/metrics` by default
exporter_install: none            # how to install exporter? none,yum,binary
exporter_repo_url: ''             # exporter repo file url if install exporter via yum
```


### `prometheus_enabled`

name: `prometheus_enabled`, type: `bool`, level: `G/I`

enable prometheus on this infra node?

default value: `true`





### `prometheus_clean`

name: `prometheus_clean`, type: `bool`, level: `G/A`

clean prometheus data during init? default value: `true`






### `prometheus_data`

name: `prometheus_data`, type: `path`, level: `G`

prometheus data dir, `/data/prometheus` by default





### `prometheus_sd_interval`

name: `prometheus_sd_interval`, type: `interval`, level: `G`

prometheus target refresh interval, `5s` by default







### `prometheus_scrape_interval`

name: `prometheus_scrape_interval`, type: `interval`, level: `G`

prometheus scrape & eval interval, `10s` by default







### `prometheus_scrape_timeout`

name: `prometheus_scrape_timeout`, type: `interval`, level: `G`

prometheus global scrape timeout, `8s` by default

DO NOT set this larger than [`prometheus_scrape_interval`](#prometheus_scrape_interval)





### `prometheus_options`

name: `prometheus_options`, type: `arg`, level: `G`

prometheus extra server options

default value: `--storage.tsdb.retention.time=15d`

Extra cli args for prometheus server, the default value will set up a 15-day data retention to limit disk usage.





### `pushgateway_enabled`

name: `pushgateway_enabled`, type: `bool`, level: `G/I`

setup pushgateway on this infra node? default value: `true`





### `pushgateway_options`

name: `pushgateway_options`, type: `arg`, level: `G`

pushgateway extra server options, default value: `--persistence.interval=1m`





### `blackbox_enabled`

name: `blackbox_enabled`, type: `bool`, level: `G/I`

setup blackbox_exporter on this infra node? default value: `true`





### `blackbox_options`

name: `blackbox_options`, type: `arg`, level: `G`

blackbox_exporter extra server options, default value is empty string






### `alertmanager_enabled`

name: `alertmanager_enabled`, type: `bool`, level: `G/I`

setup alertmanager on this infra node? default value: `true`





### `alertmanager_options`

name: `alertmanager_options`, type: `arg`, level: `G`

alertmanager extra server options, default value is empty string





### `exporter_metrics_path`

name: `exporter_metrics_path`, type: `path`, level: `G`

exporter metric path, `/metrics` by default






### `exporter_install`

name: `exporter_install`, type: `enum`, level: `G`

(**OBSOLETE**) how to install exporter? none,yum,binary

default value: `none`

Specify how to install Exporter:

* `none`: No installation, (by default, the Exporter has been previously installed by the [`node.pkgs`](#node_default_packages) task)
* `yum`: Install using yum (if yum installation is enabled, run yum to install [`node_exporter`](#node_exporter) and [`pg_exporter`](#pg_exporter) before deploying Exporter)
* `binary`: Install using a copy binary (copy [`node_exporter`](#node_exporter) and [`pg_exporter`](#pg_exporter) binary directly from the meta node, not recommended)

When installing with `yum`, if `exporter_repo_url` is specified (not empty), the installation will first install the REPO file under that URL into `/etc/yum.repos.d`. This feature allows you to install Exporter directly without initializing the node infrastructure.
It is not recommended for regular users to use `binary` installation. This mode is usually used for emergency troubleshooting and temporary problem fixes.

```bash
<meta>:<pigsty>/files/node_exporter ->  <target>:/usr/bin/node_exporter
<meta>:<pigsty>/files/pg_exporter   ->  <target>:/usr/bin/pg_exporter
```





### `exporter_repo_url`

name: `exporter_repo_url`, type: `url`, level: `G`

(**OBSOLETE**) exporter repo file url if install exporter via yum

default value is empty string

Default is empty; when [`exporter_install`](#exporter_install) is `yum`, the repo specified by this parameter will be added to the node source list.







------------------------------

## `GRAFANA`

Grafana is the visualization platform for Pigsty's monitoring system. 

It can also be used as a low code data visualization environment


```yaml
grafana_enabled: true             # enable grafana on this infra node?
grafana_clean: true               # clean grafana data during init?
grafana_admin_username: admin     # grafana admin username, `admin` by default
grafana_admin_password: pigsty    # grafana admin password, `pigsty` by default
grafana_plugin_cache: /www/pigsty/plugins.tgz # path to grafana plugins cache tarball
grafana_plugin_list:              # grafana plugins to be downloaded with grafana-cli
  - volkovlabs-echarts-panel
  - volkovlabs-image-panel
  - volkovlabs-form-panel
  - volkovlabs-variable-panel
  - volkovlabs-grapi-datasource
  - marcusolsson-static-datasource
  - marcusolsson-json-datasource
  - marcusolsson-csv-datasource
  - marcusolsson-dynamictext-panel
  - marcusolsson-treemap-panel
  - marcusolsson-calendar-panel
  - marcusolsson-hourly-heatmap-panel
  - knightss27-weathermap-panel
loki_enabled: true                # enable loki on this infra node?
loki_clean: false                 # whether remove existing loki data?
loki_data: /data/loki             # loki data dir, `/data/loki` by default
loki_retention: 15d               # loki log retention period, 15d by default
```



### `grafana_enabled`

name: `grafana_enabled`, type: `bool`, level: `G/I`

enable grafana on this infra node? default value: `true`





### `grafana_clean`

name: `grafana_clean`, type: `bool`, level: `G/A`

clean grafana data during init? default value: `true`





### `grafana_admin_username`

name: `grafana_admin_username`, type: `username`, level: `G`

grafana admin username, `admin` by default







### `grafana_admin_password`

name: `grafana_admin_password`, type: `password`, level: `G`

grafana admin password, `pigsty` by default

default value: `pigsty`

> WARNING: Change this to a strong password before deploying to production environment 





### `grafana_plugin_cache`

name: `grafana_plugin_cache`, type: `path`, level: `G`

path to grafana plugins cache tarball

default value: `/www/pigsty/plugins.tgz`

If that cache exists, pigsty use that instead of downloading plugins from the Internet





### `grafana_plugin_list`

name: `grafana_plugin_list`, type: `string[]`, level: `G`

grafana plugins to be downloaded with grafana-cli

default value:

```yaml
grafana_plugin_list:              # grafana plugins to be downloaded with grafana-cli
  - volkovlabs-echarts-panel
  - volkovlabs-image-panel
  - volkovlabs-form-panel
  - volkovlabs-variable-panel
  - volkovlabs-grapi-datasource
  - marcusolsson-static-datasource
  - marcusolsson-json-datasource
  - marcusolsson-csv-datasource
  - marcusolsson-dynamictext-panel
  - marcusolsson-treemap-panel
  - marcusolsson-calendar-panel
  - marcusolsson-hourly-heatmap-panel
  - knightss27-weathermap-panel
```






------------------------------

## `LOKI`


### `loki_enabled`

name: `loki_enabled`, type: `bool`, level: `G/I`

enable loki on this infra node? default value: `true`





### `loki_clean`

name: `loki_clean`, type: `bool`, level: `G/A`

whether remove existing loki data? default value: `false`





### `loki_data`

name: `loki_data`, type: `path`, level: `G`

loki data dir, default value: `/data/loki`






### `loki_retention`

name: `loki_retention`, type: `interval`, level: `G`

loki log retention period, `15d` by default










------------------------------------------------------------

# `NODE`

Node module are tuning target nodes into desired state and take it into the Pigsty monitor system.



------------------------------

## `NODE_ID`

Each node has **identity parameters** that are configured through the parameters in `<cluster>.hosts` and `<cluster>.vars`. Check [NODE Identity](NODE#configuration) for details.


### `nodename`

name: `nodename`, type: `string`, level: `I`

node instance identity, use hostname if missing, optional

no default value, Null or empty string means `nodename` will be set to node's current hostname.

If [`node_id_from_pg`](#node_id_from_pg) is `true` (by default) and `nodename` is not explicitly defined, [`nodename`](#nodename) will try to use `${pg_cluster}-${pg_seq}` first, if PGSQL is not defined on this node, it will fall back to default `HOSTNAME`.

If [`nodename_overwrite`](#nodename_overwrite) is `true`, the node name will also be used as the HOSTNAME.





### `node_cluster`

name: `node_cluster`, type: `string`, level: `C`

node cluster identity, use 'nodes' if missing, optional

default values: `nodes`

If [`node_id_from_pg`](#node_id_from_pg) is `true` (by default) and `node_cluster` is not explicitly defined, [`node_cluster`](#node_cluster) will try to use `${pg_cluster}` first, if PGSQL is not defined on this node, it will fall back to default `HOSTNAME`.





### `nodename_overwrite`

name: `nodename_overwrite`, type: `bool`, level: `C`

overwrite node's hostname with nodename?

default value is `true`, a non-empty node name [`nodename`](#nodename) will override the hostname of the current node.

When the [`nodename`](#nodename) parameter is undefined or an empty string, but [`node_id_from_pg`](#node_id_from_pg) is `true`,
the node name will try to use `{{ pg_cluster }}-{{ pg_seq }}`, borrow identity from the 1:1 PostgreSQL Instance's ins name.

No changes are made to the hostname if the `nodename` is undefined, empty, or an empty string and `node_id_from_pg` is `false`.





### `nodename_exchange`

name: `nodename_exchange`, type: `bool`, level: `C`

exchange nodename among play hosts?

default value is `false`

When this parameter is enabled, node names are exchanged between the same group of nodes executing the [`node.yml`](NODE#nodeyml) playbook, written to `/etc/hosts`.




### `node_id_from_pg`

name: `node_id_from_pg`, type: `bool`, level: `C`

use postgres identity as node identity if applicable?

default value is `true`

Boworrow PostgreSQL cluster & instance identity if application.

It's useful to use same identity for postgres & node if there's a 1:1 relationship





------------------------------

## `NODE_DNS`

Pigsty configs static DNS records and dynamic DNS resolver for nodes.

If you already have a DNS server, set [`node_dns_method`](#node_dns_method) to `none` to disable dynamic DNS setup.

```yaml
node_default_etc_hosts:           # static dns records in `/etc/hosts`
  - "${admin_ip} h.pigsty a.pigsty p.pigsty g.pigsty"
node_etc_hosts: []                # extra static dns records in `/etc/hosts`
node_dns_method: add              # how to handle dns servers: add,none,overwrite
node_dns_servers: ['${admin_ip}'] # dynamic nameserver in `/etc/resolv.conf`
node_dns_options:                 # dns resolv options in `/etc/resolv.conf`
  - options single-request-reopen timeout:1
```


### `node_default_etc_hosts`

name: `node_default_etc_hosts`, type: `string[]`, level: `G`

static dns records in `/etc/hosts`

default value: 

```yaml
["${admin_ip} h.pigsty a.pigsty p.pigsty g.pigsty"]
```

[`node_default_etc_hosts`](#node_default_etc_hosts) is an array. Each element is a DNS record with format `<ip> <name>`.

It is used for global static DNS records. You can use [`node_etc_hosts`](#node_etc_hosts) for ad hoc records for each cluster.

Make sure to write a DNS record like `10.10.10.10 h.pigsty a.pigsty p.pigsty g.pigsty` to `/etc/hosts` to ensure that the local yum repo can be accessed using the domain name before the DNS Nameserver starts.




### `node_etc_hosts`

name: `node_etc_hosts`, type: `string[]`, level: `C`

extra static dns records in `/etc/hosts`

default values: `[]`

Same as [`node_default_etc_hosts`](#node_default_etc_hosts), but in addition to it.




### `node_dns_method`

name: `node_dns_method`, type: `enum`, level: `C`

how to handle dns servers: add,none,overwrite

default values: `add`

* `add`: Append the records in [`node_dns_servers`](#node_dns_servers) to `/etc/resolv.conf` and keep the existing DNS servers. (default)
* `overwrite`: Overwrite `/etc/resolv.conf` with the record in [`node_dns_servers`](#node_dns_servers)
* `none`: If a DNS server is provided in the production env, the DNS server config can be skipped.




### `node_dns_servers`

name: `node_dns_servers`, type: `string[]`, level: `C`

dynamic nameserver in `/etc/resolv.conf`

default values: `["${admin_ip}"]` , the default nameserver on admin node will be added to `/etc/resolv.conf` as the first nameserver.





### `node_dns_options`

name: `node_dns_options`, type: `string[]`, level: `C`

dns resolv options in `/etc/resolv.conf`, default value: 

```yaml
- options single-request-reopen timeout:1
```







------------------------------

## `NODE_PACKAGE`

This section is about upstream yum repos & packages to be installed.

```yaml
node_repo_method: local           # how to setup node repo: none,local,public,both
node_repo_remove: true            # remove existing repo on node?
node_repo_local_urls:             # local repo url, if node_repo_method = local,both
  - http://${admin_ip}/pigsty.repo
node_packages: [ ]                # packages to be installed current nodes
node_default_packages:            # default packages to be installed on all nodes
  - lz4,unzip,bzip2,zlib,yum,pv,jq,git,ncdu,make,patch,bash,lsof,wget,uuid,tuned,nvme-cli,numactl,grubby,sysstat,iotop,htop,rsync,tcpdump,python3,python3-pip
  - netcat,socat,ftp,lrzsz,net-tools,ipvsadm,bind-utils,telnet,audit,ca-certificates,openssl,readline,vim-minimal,node_exporter,etcd,haproxy
```  




### `node_repo_method`

name: `node_repo_method`, type: `enum`, level: `C/A`

how to setup node repo: `none`, `local`, `public`, `both`, default values: `local`

Which repos are added to `/etc/yum.repos.d` on target nodes ?

* `local`: Use the local repo specified by [`node_repo_local_urls`](#node_repo_local_urls), default behavior.
* `public`: Add public upstream repo specified by [`repo_upstream`] & [`repo_modules`](#repo_modules), if you have Internet access. 
* `both`: Add both local repo and public repo. Useful when some rpm are missing 
* `none`: do not add any repo to target nodes. Managed by yourself.

You can use 'both' or 'public' when you have Internet access, and trying to install the latest version of softwares.




### `node_repo_remove`

name: `node_repo_remove`, type: `bool`, level: `C/A`

remove existing repo on node?

default value is `true`, and thus Pigsty will move existing repo file in `/etc/yum.repos.d` to a backup dir: `/etc/yum.repos.d/backup` before adding upstream repos
On Debian/Ubuntu, Pigsty will backup & move `/etc/apt/sources.list(.d)` to `/etc/apt/backup`.




### `node_repo_local_urls`

name: `node_repo_local_urls`, type: `string[]`, level: `C`

local repo url list, default values: `["http://${admin_ip}/pigsty.repo"]`

for debian/ubuntu, the proper default value is `['deb [trusted=yes] http://${admin_ip}/pigsty ./']`

It is used when [`node_repo_method`](#node_repo_method) is `local` or `both`.





### `node_packages`

name: `node_packages`, type: `string[]`, level: `C`

packages to be installed current nodes, default values: `[]`

Each element is a comma-separated list of package names, which will be installed on the current node in addition to [`node_default_packages`](#node_default_packages)

Like [`node_packages_default`](#node_default_packages), but in addition to it. designed for overwriting in cluster/instance level.




### `node_default_packages`

name: `node_default_packages`, type: `string[]`, level: `G`

default packages to be installed on all nodes, the default value is for EL 7/8/9: 

```yaml
node_default_packages:            # default packages to be installed on all nodes
  - lz4,unzip,bzip2,zlib,yum,pv,jq,git,ncdu,make,patch,bash,lsof,wget,uuid,tuned,nvme-cli,numactl,grubby,sysstat,iotop,htop,rsync,tcpdump,python3,python3-pip
  - netcat,socat,ftp,lrzsz,net-tools,ipvsadm,bind-utils,telnet,audit,ca-certificates,openssl,readline,vim-minimal,node_exporter,etcd,haproxy
```

For Ubuntu, the appropriate default value would be:

```yaml
- lz4,unzip,bzip2,zlib1g,pv,jq,git,ncdu,make,patch,bash,lsof,wget,uuid,tuned,linux-tools-generic,nvme-cli,numactl,sysstat,iotop,htop,rsync,tcpdump,acl,python3,python3-pip
- netcat,socat,ftp,lrzsz,net-tools,ipvsadm,dnsutils,telnet,ca-certificates,openssl,openssh-client,libreadline-dev,vim-tiny,keepalived,node-exporter,etcd,haproxy
```

For Debian, the appropriate default value would be:

```yaml
- lz4,unzip,bzip2,zlib1g,pv,jq,git,ncdu,make,patch,bash,lsof,wget,uuid,tuned,linux-perf,nvme-cli,numactl,sysstat,iotop,htop,rsync,tcpdump,acl,python3,python3-pip
- netcat-openbsd,socat,tnftp,lrzsz,net-tools,ipvsadm,dnsutils,telnet,ca-certificates,openssl,openssh-client,libreadline-dev,vim-tiny,keepalived,node-exporter,etcd,haproxy
```



------------------------------

## `NODE_TUNE`

Configure tuned templates, features, kernel modules, sysctl params on node.

```yaml
node_disable_firewall: true       # disable node firewall? true by default
node_disable_selinux: true        # disable node selinux? true by default
node_disable_numa: false          # disable node numa, reboot required
node_disable_swap: false          # disable node swap, use with caution
node_static_network: true         # preserve dns resolver settings after reboot
node_disk_prefetch: false         # setup disk prefetch on HDD to increase performance
node_kernel_modules: [ softdog, br_netfilter, ip_vs, ip_vs_rr, ip_vs_wrr, ip_vs_sh ]
node_hugepage_count: 0            # number of 2MB hugepage, take precedence over ratio
node_hugepage_ratio: 0            # node mem hugepage ratio, 0 disable it by default
node_overcommit_ratio: 0          # node mem overcommit ratio, 0 disable it by default
node_tune: oltp                   # node tuned profile: none,oltp,olap,crit,tiny
node_sysctl_params: { }           # sysctl parameters in k:v format in addition to tuned
```




### `node_disable_firewall`

name: `node_disable_firewall`, type: `bool`, level: `C`

disable node firewall? true by default

default value is `true`




### `node_disable_selinux`

name: `node_disable_selinux`, type: `bool`, level: `C`

disable node selinux? true by default

default value is `true`




### `node_disable_numa`

name: `node_disable_numa`, type: `bool`, level: `C`

disable node numa, reboot required

default value is `false`

Boolean flag, default is not off. Note that turning off NUMA requires a reboot of the machine before it can take effect!

If you don't know how to set the CPU affinity, it is recommended to turn off NUMA.





### `node_disable_swap`

name: `node_disable_swap`, type: `bool`, level: `C`

disable node swap, use with caution

default value is `false`

But turning off SWAP is not recommended. But SWAP should be disabled when your node is used for a Kubernetes deployment. 

If there is enough memory and the database is deployed exclusively. it may slightly improve performance 






### `node_static_network`

name: `node_static_network`, type: `bool`, level: `C`

preserve dns resolver settings after reboot, default value is `true`

Enabling static networking means that machine reboots will not overwrite your DNS Resolv config with NIC changes. It is recommended to enable it in production environment.




### `node_disk_prefetch`

name: `node_disk_prefetch`, type: `bool`, level: `C`

setup disk prefetch on HDD to increase performance

default value is `false`, Consider enable this when using HDD.





### `node_kernel_modules`

name: `node_kernel_modules`, type: `string[]`, level: `C`

kernel modules to be enabled on this node

default value: 

```yaml
node_kernel_modules: [ softdog, br_netfilter, ip_vs, ip_vs_rr, ip_vs_wrr, ip_vs_sh ]
```

An array consisting of kernel module names declaring the kernel modules that need to be installed on the node. 




### `node_hugepage_count`

name: `node_hugepage_count`, type: `int`, level: `C`

number of 2MB hugepage, take precedence over ratio, 0 by default

Take precedence over [`node_hugepage_ratio`](#node_hugepage_ratio). If a non-zero value is given, it will be written to `/etc/sysctl.d/hugepage.conf`

If `node_hugepage_count` and `node_hugepage_ratio` are both `0` (default), hugepage will be disabled at all.

Negative value will not work, and number higher than 90% node mem will be ceil to 90% of node mem. 

It should slightly larger than [`pg_shared_buffer_ratio`](#pg_shared_buffer_ratio), if not zero.




### `node_hugepage_ratio`

name: `node_hugepage_ratio`, type: `float`, level: `C`

node mem hugepage ratio, 0 disable it by default, valid range: 0 ~ 0.40

default values: `0`, which will set `vm.nr_hugepages=0` and not use HugePage at all.

Percent of this memory will be allocated as HugePage, and reserved for PostgreSQL.

It should be equal or slightly larger than [`pg_shared_buffer_ratio`](#pg_shared_buffer_ratio), if not zero.

For example, if you have default 25% mem for postgres shard buffers, you can set this value to 27 ~ 30.  Wasted hugepage can be reclaimed later with `/pg/bin/pg-tune-hugepage`





### `node_overcommit_ratio`

name: `node_overcommit_ratio`, type: `int`, level: `C`

node mem overcommit ratio, 0 disable it by default. this is an integer from 0 to 100+ .

default values: `0`, which will set `vm.overcommit_memory=0`, otherwise `vm.overcommit_memory=2` will be used,
and this value will be used as `vm.overcommit_ratio`.

It is recommended to set use a `vm.overcommit_ratio` on dedicated pgsql nodes. e.g. 50 ~ 100. 




### `node_tune`

name: `node_tune`, type: `enum`, level: `C`

node tuned profile: none,oltp,olap,crit,tiny

default values: `oltp`

* `tiny`: Micro Virtual Machine (1 ~ 3 Core, 1 ~ 8 GB Mem)
* `oltp`: Regular OLTP templates with optimized latency
* `olap `: Regular OLAP templates to optimize throughput
* `crit`: Core financial business templates, optimizing the number of dirty pages

Usually, the database tuning template [`pg_conf`](#pg_conf) should be paired with the node tuning template: [`node_tune`](#node_tune)






### `node_sysctl_params`

name: `node_sysctl_params`, type: `dict`, level: `C`

sysctl parameters in k:v format in addition to tuned

default values: `{}`

Dictionary K-V structure, Key is kernel `sysctl` parameter name, Value is the parameter value.

You can also define sysctl parameters with tuned profile






------------------------------

## `NODE_ADMIN`

This section is about admin users and it's credentials.

```yaml
node_data: /data                  # node main data directory, `/data` by default
node_admin_enabled: true          # create a admin user on target node?
node_admin_uid: 88                # uid and gid for node admin user
node_admin_username: dba          # name of node admin user, `dba` by default
node_admin_ssh_exchange: true     # exchange admin ssh key among node cluster
node_admin_pk_current: true       # add current user's ssh pk to admin authorized_keys
node_admin_pk_list: []            # ssh public keys to be added to admin user
```





### `node_data`

name: `node_data`, type: `path`, level: `C`

node main data directory, `/data` by default

default values: `/data`

If specified, this path will be used as major data disk mountpoint. And a dir will be created and throwing a warning if path not exists.

The data dir is owned by root with mode `0777`.





### `node_admin_enabled`

name: `node_admin_enabled`, type: `bool`, level: `C`

create a admin user on target node?

default value is `true`

Create an admin user on each node (password-free sudo and ssh), an admin user named `dba (uid=88)` will be created by default,
 which can access other nodes in the env and perform sudo from the meta node via SSH password-free.




### `node_admin_uid`

name: `node_admin_uid`, type: `int`, level: `C`

uid and gid for node admin user

default values: `88`





### `node_admin_username`

name: `node_admin_username`, type: `username`, level: `C`

name of node admin user, `dba` by default

default values: `dba`





### `node_admin_ssh_exchange`

name: `node_admin_ssh_exchange`, type: `bool`, level: `C`

exchange admin ssh key among node cluster

default value is `true`

When enabled, Pigsty will exchange SSH public keys between members during playbook execution, allowing admins [`node_admin_username`](#node_admin_username) to access each other from different nodes.




### `node_admin_pk_current`

name: `node_admin_pk_current`, type: `bool`, level: `C`

add current user's ssh pk to admin authorized_keys

default value is `true`

When enabled, on the current node, the SSH public key (`~/.ssh/id_rsa.pub`) of the current user is copied to the `authorized_keys` of the target node admin user.

When deploying in a production env, be sure to pay attention to this parameter, which installs the default public key of the user currently executing the command to the admin user of all machines.





### `node_admin_pk_list`

name: `node_admin_pk_list`, type: `string[]`, level: `C`

ssh public keys to be added to admin user

default values: `[]`

Each element of the array is a string containing the key written to the admin user `~/.ssh/authorized_keys`, and the user with the corresponding private key can log in as an admin user.

When deploying in production envs, be sure to note this parameter and add only trusted keys to this list.






------------------------------

## `NODE_TIME`

```yaml
node_timezone: ''                 # setup node timezone, empty string to skip
node_ntp_enabled: true            # enable chronyd time sync service?
node_ntp_servers:                 # ntp servers in `/etc/chrony.conf`
  - pool pool.ntp.org iburst
node_crontab_overwrite: true      # overwrite or append to `/etc/crontab`?
node_crontab: [ ]                 # crontab entries in `/etc/crontab`
```


### `node_timezone`

name: `node_timezone`, type: `string`, level: `C`

setup node timezone, empty string to skip

default value is empty string, which will not change the default timezone (usually UTC)





### `node_ntp_enabled`

name: `node_ntp_enabled`, type: `bool`, level: `C`

enable chronyd time sync service?

default value is `true`, and thus Pigsty will override the node's `/etc/chrony.conf` by with [`node_ntp_servers`](#node_ntp_servers).

If you already a NTP server configured, just set to `false` to leave it be.




### `node_ntp_servers`

name: `node_ntp_servers`, type: `string[]`, level: `C`

ntp servers in `/etc/chrony.conf`, default value:  `["pool pool.ntp.org iburst"]`

It only takes effect if [`node_ntp_enabled`](#node_ntp_enabled) is true.

You can use `${admin_ip}` to sync time with ntp server on admin node rather than public ntp server.

```yaml
node_ntp_servers: [ 'pool ${admin_ip} iburst' ]
```





### `node_crontab_overwrite`

name: `node_crontab_overwrite`, type: `bool`, level: `C`

overwrite or append to `/etc/crontab`?

default value is `true`, and pigsty will render records in [`node_crontab`](#node_crontab) in overwrite mode rather than appending to it.





### `node_crontab`

name: `node_crontab`, type: `string[]`, level: `C`

crontab entries in `/etc/crontab`

default values: `[]`





------------------------------

## `NODE_VIP`

You can bind an optional L2 VIP among one node cluster, which is disabled by default.

L2 VIP can only be used in same L2 LAN, which may incurs extra restrictions on your network topology.

If enabled, You have to manually assign the [`vip_address`](#vip_address) and [`vip_vrid`](#vip_vrid) for each node cluster.

It is user's responsibility to ensure that the address / vrid is **unique** among the same LAN.


```yaml
vip_enabled: false                # enable vip on this node cluster?
# vip_address:         [IDENTITY] # node vip address in ipv4 format, required if vip is enabled
# vip_vrid:            [IDENTITY] # required, integer, 1-254, should be unique among same VLAN
vip_role: backup                  # optional, `master/backup`, backup by default, use as init role
vip_preempt: false                # optional, `true/false`, false by default, enable vip preemption
vip_interface: eth0               # node vip network interface to listen, `eth0` by default
vip_dns_suffix: ''                # node vip dns name suffix, empty string by default
vip_exporter_port: 9650           # keepalived exporter listen port, 9650 by default
```




### `vip_enabled`

name: `vip_enabled`, type: `bool`, level: `C`

enable vip on this node cluster? default value is `false`, means no L2 VIP is created for this node cluster.

L2 VIP can only be used in same L2 LAN, which may incurs extra restrictions on your network topology.



### `vip_address`

name: `vip_address`, type: `ip`, level: `C`

node vip address in IPv4 format, **required** if node [`vip_enabled`](#vip_enabled).

no default value. This parameter must be explicitly assigned and unique in your LAN.



### `vip_vrid`

name: `vip_address`, type: `ip`, level: `C`

integer, 1-254, should be unique in same VLAN, **required** if node [`vip_enabled`](#vip_enabled).

no default value. This parameter must be explicitly assigned and unique in your LAN.





### `vip_role`

name: `vip_role`, type: `enum`, level: `I`

node vip role, could be `master` or `backup`, will be used as initial keepalived state.




### `vip_preempt`

name: `vip_preempt`, type: `bool`, level: `C/I`

optional, `true/false`, false by default, enable vip preemption

default value is `false`, means no preempt is happening when a backup have higher priority than living master.




### `vip_interface`

name: `vip_interface`, type: `string`, level: `C/I`

node vip network interface to listen, `eth0` by default.

It should be the same primary intranet interface of your node, which is the IP address you used in the inventory file.

If your node have different interface, you can override it on instance vars




### `vip_dns_suffix`

name: `vip_dns_suffix`, type: `string`, level: `C/I`

node vip dns name suffix, empty string by default. It will be used as the DNS name of the node VIP.





### `vip_exporter_port`

name: `vip_exporter_port`, type: `port`, level: `C/I`

keepalived exporter listen port, 9650 by default.






------------------------------

## `HAPROXY`

HAProxy is installed on every node by default, exposing services in a NodePort manner.

It is used by [`PGSQL`](PGSQL) [Service](PGSQL-SERVICE).


```yaml
haproxy_enabled: true             # enable haproxy on this node?
haproxy_clean: false              # cleanup all existing haproxy config?
haproxy_reload: true              # reload haproxy after config?
haproxy_auth_enabled: true        # enable authentication for haproxy admin page
haproxy_admin_username: admin     # haproxy admin username, `admin` by default
haproxy_admin_password: pigsty    # haproxy admin password, `pigsty` by default
haproxy_exporter_port: 9101       # haproxy admin/exporter port, 9101 by default
haproxy_client_timeout: 24h       # client side connection timeout, 24h by default
haproxy_server_timeout: 24h       # server side connection timeout, 24h by default
haproxy_services: []              # list of haproxy service to be exposed on node
```



### `haproxy_enabled`

name: `haproxy_enabled`, type: `bool`, level: `C`

enable haproxy on this node?

default value is `true`




### `haproxy_clean`

name: `haproxy_clean`, type: `bool`, level: `G/C/A`

cleanup all existing haproxy config?

default value is `false`




### `haproxy_reload`

name: `haproxy_reload`, type: `bool`, level: `A`

reload haproxy after config?

default value is `true`, it will reload haproxy after config change.

If you wish to check before apply, you can turn off this with cli args and check it.




### `haproxy_auth_enabled`

name: `haproxy_auth_enabled`, type: `bool`, level: `G`

enable authentication for haproxy admin page

default value is `true`, which will require a http basic auth for admin page.

disable it is not recommended, since your traffic control will be exposed




### `haproxy_admin_username`

name: `haproxy_admin_username`, type: `username`, level: `G`

haproxy admin username, `admin` by default





### `haproxy_admin_password`

name: `haproxy_admin_password`, type: `password`, level: `G`

haproxy admin password, `pigsty` by default

> PLEASE CHANGE IT IN YOUR PRODUCTION ENVIRONMENT!




### `haproxy_exporter_port`

name: `haproxy_exporter_port`, type: `port`, level: `C`

haproxy admin/exporter port, `9101` by default





### `haproxy_client_timeout`

name: `haproxy_client_timeout`, type: `interval`, level: `C`

client side connection timeout, `24h` by default






### `haproxy_server_timeout`

name: `haproxy_server_timeout`, type: `interval`, level: `C`

server side connection timeout, `24h` by default






### `haproxy_services`

name: `haproxy_services`, type: `service[]`, level: `C`

list of haproxy service to be exposed on node, default values: `[]`

Each element is a service definition, here is an ad hoc haproxy service example:


```yaml
haproxy_services:                   # list of haproxy service

  # expose pg-test read only replicas
  - name: pg-test-ro                # [REQUIRED] service name, unique
    port: 5440                      # [REQUIRED] service port, unique
    ip: "*"                         # [OPTIONAL] service listen addr, "*" by default
    protocol: tcp                   # [OPTIONAL] service protocol, 'tcp' by default
    balance: leastconn              # [OPTIONAL] load balance algorithm, roundrobin by default (or leastconn)
    maxconn: 20000                  # [OPTIONAL] max allowed front-end connection, 20000 by default
    default: 'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'
    options:
      - option httpchk
      - option http-keep-alive
      - http-check send meth OPTIONS uri /read-only
      - http-check expect status 200
    servers:
      - { name: pg-test-1 ,ip: 10.10.10.11 , port: 5432 , options: check port 8008 , backup: true }
      - { name: pg-test-2 ,ip: 10.10.10.12 , port: 5432 , options: check port 8008 }
      - { name: pg-test-3 ,ip: 10.10.10.13 , port: 5432 , options: check port 8008 }

```

It will be rendered to `/etc/haproxy/<service.name>.cfg` and take effect after reload.









------------------------------

## `NODE_EXPORTER`

```yaml
node_exporter_enabled: true       # setup node_exporter on this node?
node_exporter_port: 9100          # node exporter listen port, 9100 by default
node_exporter_options: '--no-collector.softnet --no-collector.nvme --collector.tcpstat --collector.processes'
```



### `node_exporter_enabled`

name: `node_exporter_enabled`, type: `bool`, level: `C`

setup node_exporter on this node? default value is `true`





### `node_exporter_port`

name: `node_exporter_port`, type: `port`, level: `C`

node exporter listen port, `9100` by default






### `node_exporter_options`

name: `node_exporter_options`, type: `arg`, level: `C`

extra server options for node_exporter, default value: `--no-collector.softnet --no-collector.nvme --collector.tcpstat --collector.processes`

Pigsty enables `tcpstat`, `processes` collectors and and disable  `nvme`, `softnet` metrics collectors by default.





------------------------------

## `PROMTAIL`

Promtail will collect logs from other modules, and send them to [`LOKI`](#loki)

* `INFRA`: Infra logs, collected only on infra nodes.
    * `nginx-access`: `/var/log/nginx/access.log`
    * `nginx-error`: `/var/log/nginx/error.log`
    * `grafana`: `/var/log/grafana/grafana.log`

* `NODES`: Host node logs, collected on all nodes.
    * `syslog`: `/var/log/messages`
    * `dmesg`: `/var/log/dmesg`
    * `cron`: `/var/log/cron`

* `PGSQL`: PostgreSQL logs, collected when a node is defined with `pg_cluster`.
    * `postgres`: `/pg/log/postgres/*.csv`
    * `patroni`: `/pg/log/patroni.log`
    * `pgbouncer`: `/pg/log/pgbouncer/pgbouncer.log`
    * `pgbackrest`: `/pg/log/pgbackrest/*.log`

* `REDIS`: Redis logs, collected when a node is defined with `redis_cluster`.
    * `redis`: `/var/log/redis/*.log`

> Log directory are customizable according to [`pg_log_dir`](#pg_log_dir), [`patroni_log_dir`](#patroni_log_dir), [`pgbouncer_log_dir`](#pgbouncer_log_dir), [`pgbackrest_log_dir`](#pgbackrest_log_dir)



```yaml
promtail_enabled: true            # enable promtail logging collector?
promtail_clean: false             # purge existing promtail status file during init?
promtail_port: 9080               # promtail listen port, 9080 by default
promtail_positions: /var/log/positions.yaml # promtail position status file path
```



### `promtail_enabled`

name: `promtail_enabled`, type: `bool`, level: `C`

enable promtail logging collector?

default value is `true`




### `promtail_clean`

name: `promtail_clean`, type: `bool`, level: `G/A`

purge existing promtail status file during init?

default value is `false`, if you choose to clean, Pigsty will remove the existing state file defined by [`promtail_positions`](#promtail_positions)
which means that Promtail will recollect all logs on the current node and send them to Loki again.




### `promtail_port`

name: `promtail_port`, type: `port`, level: `C`

promtail listen port, 9080 by default

default values: `9080`





### `promtail_positions`

name: `promtail_positions`, type: `path`, level: `C`

promtail position status file path

default values: `/var/log/positions.yaml`

Promtail records the consumption offsets of all logs, which are periodically written to the file specified by [`promtail_positions`](#promtail_positions).







------------------------------------------------------------

# `DOCKER`

You can install docker on nodes with [`docker.yml`](https://github.com/Vonng/pigsty/blob/master/docker.yml)


```yaml
docker_enabled: false             # enable docker on this node?
docker_cgroups_driver: systemd    # docker cgroup fs driver: cgroupfs,systemd
docker_registry_mirrors: []       # docker registry mirror list
docker_image_cache: /tmp/docker   # docker image cache dir, `/tmp/docker` by default
```



### `docker_enabled`

name: `docker_enabled`, type: `bool`, level: `C`

enable docker on this node? default value is `false`




### `docker_cgroups_driver`

name: `docker_cgroups_driver`, type: `enum`, level: `C`

docker cgroup fs driver, could be `cgroupfs` or `systemd`, default values: `systemd`





### `docker_registry_mirrors`

name: `docker_registry_mirrors`, type: `string[]`, level: `C`

docker registry mirror list, default values: `[]`, Example: 

```yaml
[ "https://mirror.ccs.tencentyun.com" ]         # tencent cloud mirror, intranet only
["https://registry.cn-hangzhou.aliyuncs.com"]   # aliyun cloud mirror, login required
```



### `docker_image_cache`

name: `docker_image_cache`, type: `path`, level: `C`

docker image cache dir, `/tmp/docker` by default.

The local docker image cache with `.tgz` suffix under this directory will be loaded into docker one by one:

```bash
cat {{ docker_image_cache }}/*.tgz | gzip -d -c - | docker load
```





------------------------------------------------------------

# `ETCD`

[ETCD](ETCD) is a distributed, reliable key-value store for the most critical data of a distributed system,
and pigsty use **etcd** as **DCS**, Which is critical to PostgreSQL High-Availability.

Pigsty has a hard coded group name `etcd` for etcd cluster, it can be an existing & external etcd cluster, or a new etcd cluster created by Pigsty with  [etcd.yml](ETCD#etcdyml).


```yaml
#etcd_seq: 1                      # etcd instance identifier, explicitly required
#etcd_cluster: etcd               # etcd cluster & group name, etcd by default
etcd_safeguard: false             # prevent purging running etcd instance?
etcd_clean: true                  # purging existing etcd during initialization?
etcd_data: /data/etcd             # etcd data directory, /data/etcd by default
etcd_port: 2379                   # etcd client port, 2379 by default
etcd_peer_port: 2380              # etcd peer port, 2380 by default
etcd_init: new                    # etcd initial cluster state, new or existing
etcd_election_timeout: 1000       # etcd election timeout, 1000ms by default
etcd_heartbeat_interval: 100      # etcd heartbeat interval, 100ms by default
```


### `etcd_seq`

name: `etcd_seq`, type: `int`, level: `I`

etcd instance identifier, REQUIRED

no default value, you have to specify it explicitly. Here is a 3-node etcd cluster example:

```yaml
etcd: # dcs service for postgres/patroni ha consensus
  hosts:  # 1 node for testing, 3 or 5 for production
    10.10.10.10: { etcd_seq: 1 }  # etcd_seq required
    10.10.10.11: { etcd_seq: 2 }  # assign from 1 ~ n
    10.10.10.12: { etcd_seq: 3 }  # odd number please
  vars: # cluster level parameter override roles/etcd
    etcd_cluster: etcd  # mark etcd cluster name etcd
    etcd_safeguard: false # safeguard against purging
    etcd_clean: true # purge etcd during init process
```



### `etcd_cluster`

name: `etcd_cluster`, type: `string`, level: `C`

etcd cluster & group name, etcd by default

default values: `etcd`, which is a fixed group name, can be useful when you want to use deployed some extra etcd clusters





### `etcd_safeguard`

name: `etcd_safeguard`, type: `bool`, level: `G/C/A`

prevent purging running etcd instance? default value is `false`

If enabled, running etcd instance will not be purged by [etcd.yml](ETCD#etcdyml) playbook.




### `etcd_clean`

name: `etcd_clean`, type: `bool`, level: `G/C/A`

purging existing etcd during initialization? default value is `true`

If enabled, running etcd instance will be purged by [etcd.yml](ETCD#etcdyml) playbook, which makes the playbook fully idempotent.

But if [`etcd_safeguard`](#etcd_safeguard) is enabled, it will still abort on any running etcd instance.





### `etcd_data`

name: `etcd_data`, type: `path`, level: `C`

etcd data directory, `/data/etcd` by default






### `etcd_port`

name: `etcd_port`, type: `port`, level: `C`

etcd client port, `2379` by default





### `etcd_peer_port`

name: `etcd_peer_port`, type: `port`, level: `C`

etcd peer port, `2380` by default





### `etcd_init`

name: `etcd_init`, type: `enum`, level: `C`

etcd initial cluster state, `new` or `existing`

default values: `new`, which will create a standalone new etcd cluster.

The value `existing` is used when trying to [add new member](ETCD#add-member) to existing etcd cluster.





### `etcd_election_timeout`

name: `etcd_election_timeout`, type: `int`, level: `C`

etcd election timeout, `1000` (ms) by default





### `etcd_heartbeat_interval`

name: `etcd_heartbeat_interval`, type: `int`, level: `C`

etcd heartbeat interval, `100` (ms) by default



------------------------------------------------------------

# `MINIO`

Minio is a S3 compatible object storage service. Which is used as an optional central backup storage repo for PostgreSQL.

But you can use it for other purpose, such as storing large files, document, pictures & videos.


```yaml
#minio_seq: 1                     # minio instance identifier, REQUIRED
minio_cluster: minio              # minio cluster name, minio by default
minio_clean: false                # cleanup minio during init?, false by default
minio_user: minio                 # minio os user, `minio` by default
minio_node: '${minio_cluster}-${minio_seq}.pigsty' # minio node name pattern
minio_data: '/data/minio'         # minio data dir(s), use {x...y} to specify multi drivers
minio_domain: sss.pigsty          # minio external domain name, `sss.pigsty` by default
minio_port: 9000                  # minio service port, 9000 by default
minio_admin_port: 9001            # minio console port, 9001 by default
minio_access_key: minioadmin      # root access key, `minioadmin` by default
minio_secret_key: minioadmin      # root secret key, `minioadmin` by default
minio_extra_vars: ''              # extra environment variables
minio_alias: sss                  # alias name for local minio deployment
minio_buckets: [ { name: pgsql }, { name: infra },  { name: redis } ]
minio_users:
  - { access_key: dba , secret_key: S3User.DBA, policy: consoleAdmin }
  - { access_key: pgbackrest , secret_key: S3User.Backup, policy: readwrite }
```


### `minio_seq`

name: `minio_seq`, type: `int`, level: `I`

minio instance identifier, REQUIRED identity parameters. no default value, you have to assign it manually





### `minio_cluster`

name: `minio_cluster`, type: `string`, level: `C`

minio cluster name, `minio` by default. This is useful when deploying multiple MinIO clusters







### `minio_clean`

name: `minio_clean`, type: `bool`, level: `G/C/A`

cleanup minio during init?, `false` by default






### `minio_user`

name: `minio_user`, type: `username`, level: `C`

minio os user name, `minio` by default






### `minio_node`

name: `minio_node`, type: `string`, level: `C`

minio node name pattern, this is used for [multi-node](MINIO#multi-node-multi-drive) deployment

default values: `${minio_cluster}-${minio_seq}.pigsty`





### `minio_data`

name: `minio_data`, type: `path`, level: `C`

minio data dir(s)

default values: `/data/minio`, which is a common dir for [single-node](MINIO#single-node-single-drive) deployment.

For a [multi-drive](MINIO#single-node-multi-drive) deployment, you can use `{x...y}` notion to specify multi drivers.





### `minio_domain`

name: `minio_domain`, type: `string`, level: `G`

minio service domain name, `sss.pigsty` by default.

The client can access minio S3 service via this domain name. This name will be registered to local DNSMASQ and included in SSL certs.






### `minio_port`

name: `minio_port`, type: `port`, level: `C`

minio service port, `9000` by default





### `minio_admin_port`

name: `minio_admin_port`, type: `port`, level: `C`

minio console port, `9001` by default





### `minio_access_key`

name: `minio_access_key`, type: `username`, level: `C`

root access key, `minioadmin` by default






### `minio_secret_key`

name: `minio_secret_key`, type: `password`, level: `C`

root secret key, `minioadmin` by default

default values: `minioadmin`

> **PLEASE CHANGE THIS IN YOUR DEPLOYMENT**




### `minio_extra_vars`

name: `minio_extra_vars`, type: `string`, level: `C`

extra environment variables for minio server. Check [Minio Server](https://min.io/docs/minio/linux/reference/minio-server/minio-server.html) for the complete list.

default value is empty string, you can use multiline string to passing multiple environment variables.





### `minio_alias`

name: `minio_alias`, type: `string`, level: `G`

MinIO alias name for the local MinIO cluster

default values: `sss`, which will be written to infra nodes' / admin users' client alias profile.





### `minio_buckets`

name: `minio_buckets`, type: `bucket[]`, level: `C`

list of minio bucket to be created by default:

```yaml
minio_buckets: [ { name: pgsql }, { name: infra },  { name: redis } ]
```

Three default buckets are created for module [`PGSQL`](PGSQL), [`INFRA`](INFRA), and [`REDIS`](REDIS)




### `minio_users`

name: `minio_users`, type: `user[]`, level: `C`

list of minio user to be created, default value:

```yaml
minio_users:
  - { access_key: dba , secret_key: S3User.DBA, policy: consoleAdmin }
  - { access_key: pgbackrest , secret_key: S3User.Backup, policy: readwrite }
```

Two default users are created for PostgreSQL DBA and pgBackREST.

> PLEASE ADJUST THESE USERS & CREDENTIALS IN YOUR DEPLOYMENT!






------------------------------------------------------------

# `REDIS`


```yaml
#redis_cluster:        <CLUSTER> # redis cluster name, required identity parameter
#redis_node: 1            <NODE> # redis node sequence number, node int id required
#redis_instances: {}      <NODE> # redis instances definition on this redis node
redis_fs_main: /data              # redis main data mountpoint, `/data` by default
redis_exporter_enabled: true      # install redis exporter on redis nodes?
redis_exporter_port: 9121         # redis exporter listen port, 9121 by default
redis_exporter_options: ''        # cli args and extra options for redis exporter
redis_safeguard: false            # prevent purging running redis instance?
redis_clean: true                 # purging existing redis during init?
redis_rmdata: true                # remove redis data when purging redis server?
redis_mode: standalone            # redis mode: standalone,cluster,sentinel
redis_conf: redis.conf            # redis config template path, except sentinel
redis_bind_address: '0.0.0.0'     # redis bind address, empty string will use host ip
redis_max_memory: 1GB             # max memory used by each redis instance
redis_mem_policy: allkeys-lru     # redis memory eviction policy
redis_password: ''                # redis password, empty string will disable password
redis_rdb_save: ['1200 1']        # redis rdb save directives, disable with empty list
redis_aof_enabled: false          # enable redis append only file?
redis_rename_commands: {}         # rename redis dangerous commands
redis_cluster_replicas: 1         # replica number for one master in redis cluster
redis_sentinel_monitor: []        # sentinel master list, works on sentinel cluster only
```



### `redis_cluster`

name: `redis_cluster`, type: `string`, level: `C`

redis cluster name, required identity parameter.

no default value, you have to define it explicitly.

Comply with regexp `[a-z][a-z0-9-]*`, it is recommended to use the same name as the group name and start with `redis-`




### `redis_node`

name: `redis_node`, type: `int`, level: `I`

redis node sequence number,  unique integer among redis cluster is required

You have to explicitly define the node id for each redis node. integer start from 0 or 1.




### `redis_instances`

name: `redis_instances`, type: `dict`, level: `I`

redis instances definition on this redis node

no default value, you have to define redis instances on each redis node using this parameter explicitly.

Here is an example for a native redis cluster definition

```yaml
redis-test: # redis native cluster: 3m x 3s
  hosts:
    10.10.10.12: { redis_node: 1 ,redis_instances: { 6379: { } ,6380: { } ,6381: { } } }
    10.10.10.13: { redis_node: 2 ,redis_instances: { 6379: { } ,6380: { } ,6381: { } } }
  vars: { redis_cluster: redis-test ,redis_password: 'redis.test' ,redis_mode: cluster, redis_max_memory: 32MB }
```

The port number should be unique among the **node**, and the `replica_of` in `value` should be instance member of the same redis **cluster**. 

```yaml
redis_instances:
    6379: {}
    6380: { replica_of: '10.10.10.13 6379' }
    6381: { replica_of: '10.10.10.13 6379' }
```





### `redis_fs_main`

name: `redis_fs_main`, type: `path`, level: `C`

redis main data mountpoint, `/data` by default

default values: `/data`, and `/data/redis` will be used as the redis data directory.





### `redis_exporter_enabled`

name: `redis_exporter_enabled`, type: `bool`, level: `C`

install redis exporter on redis nodes?

default value is `true`, which will launch a redis_exporter on this redis_node




### `redis_exporter_port`

name: `redis_exporter_port`, type: `port`, level: `C`

redis exporter listen port, 9121 by default

default values: `9121`





### `redis_exporter_options`

name: `redis_exporter_options`, type: `string`, level: `C/I`

cli args and extra options for redis exporter, will be added to `/etc/defaut/redis_exporter`.

default value is empty string






### `redis_safeguard`

name: `redis_safeguard`, type: `bool`, level: `G/C/A`

prevent purging running redis instance?

default value is `false`, if set to `true`, and redis instance is running, init / remove playbook will abort immediately.




### `redis_clean`

name: `redis_clean`, type: `bool`, level: `G/C/A`

purging existing redis during init?

default value is `true`, which will remove redis server during redis init or remove.




### `redis_rmdata`

name: `redis_rmdata`, type: `bool`, level: `G/C/A`

remove redis data when purging redis server? 

default value is `true`, which will remove redis rdb / aof along with redis instance.




### `redis_mode`

name: `redis_mode`, type: `enum`, level: `C`

redis mode: standalone,cluster,sentinel

default values: `standalone`

* `standalone`: setup redis as standalone (master-slave) mode
* `cluster`: setup this redis cluster as a redis native cluster
* `sentinel`: setup redis as sentinel for standalone redis HA





### `redis_conf`

name: `redis_conf`, type: `string`, level: `C`

redis config template path, except sentinel

default values: `redis.conf`, which is a template file in [`roles/redis/templates/redis.conf`](https://github.com/Vonng/pigsty/blob/master/roles/redis/templates/redis.conf). 

If you want to use your own redis config template, you can put it in `templates/` directory and set this parameter to the template file name.

Note that redis sentinel are using a different template file, which is [`roles/redis/templates/redis-sentinel.conf`](https://github.com/Vonng/pigsty/blob/master/roles/redis/templates/redis-sentinel.conf)





### `redis_bind_address`

name: `redis_bind_address`, type: `ip`, level: `C`

redis bind address, empty string will use inventory hostname

default values: `0.0.0.0`, which will bind to all available IPv4 address on this host

> PLEASE bind to intranet IP only in production environment, i.e. set this value to `''`




### `redis_max_memory`

name: `redis_max_memory`, type: `size`, level: `C/I`

max memory used by each redis instance, default values: `1GB`





### `redis_mem_policy`

name: `redis_mem_policy`, type: `enum`, level: `C`

redis memory eviction policy

default values: `allkeys-lru`, check redis [eviction policy](https://redis.io/docs/reference/eviction/) for more details

- `noeviction`: New values aren’t saved when memory limit is reached. When a database uses replication, this applies to the primary database
- `allkeys-lru`: Keeps most recently used keys; removes least recently used (LRU) keys
- `allkeys-lfu`: Keeps frequently used keys; removes least frequently used (LFU) keys
- `volatile-lru`: Removes least recently used keys with the expire field set to true.
- `volatile-lfu`: Removes least frequently used keys with the expire field set to true.
- `allkeys-random`: Randomly removes keys to make space for the new data added.
- `volatile-random`: Randomly removes keys with expire field set to true.
- `volatile-ttl`: Removes keys with expire field set to true and the shortest remaining time-to-live (TTL) value.




### `redis_password`

name: `redis_password`, type: `password`, level: `C/N`

redis password, empty string will disable password, which is the default behavior

Note that due to the implementation limitation of redis_exporter, you can only set one `redis_password` per node. 
This is usually not a problem, because pigsty does not allow deploying two different redis cluster on the same node. 

> PLEASE use a strong password in production environment 




### `redis_rdb_save`

name: `redis_rdb_save`, type: `string[]`, level: `C`

redis rdb save directives, disable with empty list, check redis [persist](https://redis.io/docs/management/persistence/) for details.

the default value is  `["1200 1"]`: dump the dataset to disk every 20 minutes if at least 1 key changed: 





### `redis_aof_enabled`

name: `redis_aof_enabled`, type: `bool`, level: `C`

enable redis append only file? default value is `false`.





### `redis_rename_commands`

name: `redis_rename_commands`, type: `dict`, level: `C`

rename redis dangerous commands, which is a dict of k:v `old: new`

default values: `{}`, you can hide dangerous commands like `FLUSHDB` and `FLUSHALL` by setting this value, here's an example:

```yaml
{
  "keys": "op_keys",
  "flushdb": "op_flushdb",
  "flushall": "op_flushall",
  "config": "op_config"  
}
```




### `redis_cluster_replicas`

name: `redis_cluster_replicas`, type: `int`, level: `C`

replica number for one master/primary in redis cluster, default values: `1`




### `redis_sentinel_monitor`

name: `redis_sentinel_monitor`, type: `master[]`, level: `C`

This can only be used when [`redis_mode`](#redis_mode) is set to `sentinel`.

List of redis master to be monitored by this sentinel cluster. each master is defined as a dict with `name`, `host`, `port`, `password`, `quorum` keys.

```yaml
redis_sentinel_monitor:  # primary list for redis sentinel, use cls as name, primary ip:port
  - { name: redis-src, host: 10.10.10.45, port: 6379 ,password: redis.src, quorum: 1 }
  - { name: redis-dst, host: 10.10.10.48, port: 6379 ,password: redis.dst, quorum: 1 }
```

The `name` and `host` are mandatory, `port`, `password`, `quorum` are optional, `quorum` is used to set the quorum for this master, usually large than half of the sentinel instances.




------------------------------------------------------------

# `PGSQL`

[`PGSQL`](PGSQL) module requires [`NODE`](NODE) module to be installed, and you also need a viable [`ETCD`](ETCD) cluster to store cluster meta data.

Install `PGSQL` module on a single node will create a [primary](PGSQL-CONF#primary) instance which a standalone PGSQL server/instance.
Install it on additional nodes will create [replicas](PGSQL-CONF#replica), which can be used for serving read-only traffics, or use as standby backup.
You can also create [offline](PGSQL-CONF#offline) instance of ETL/OLAP/Interactive queries,
use [Sync Standby](PGSQL-CONF#sync-standby) and [Quorum Commit](PGSQL-CONF#quorum-commit) to increase data consistency,
or even form a [standby cluster](PGSQL-CONF#standby-cluster) and [delayed standby cluster](PGSQL-CONF#delayed-cluster) for disaster recovery.

You can define multiple PGSQL clusters and form a horizontal sharding cluster, which is a group of PGSQL clusters running on different nodes.
Pigsty has native [citus cluster group](PGSQL-CONF#citus-cluster) support, which can extend your PGSQL cluster to a distributed database sharding cluster.



------------------------------

## `PG_ID`

Here are some common parameters used to identify PGSQL [entities](PGSQL-ARCH#er-diagram): instance, service, etc...

```yaml
# pg_cluster:           #CLUSTER  # pgsql cluster name, required identity parameter
# pg_seq: 0             #INSTANCE # pgsql instance seq number, required identity parameter
# pg_role: replica      #INSTANCE # pgsql role, required, could be primary,replica,offline
# pg_instances: {}      #INSTANCE # define multiple pg instances on node in `{port:ins_vars}` format
# pg_upstream:          #INSTANCE # repl upstream ip addr for standby cluster or cascade replica
# pg_shard:             #CLUSTER  # pgsql shard name, optional identity for sharding clusters
# pg_group: 0           #CLUSTER  # pgsql shard index number, optional identity for sharding clusters
# gp_role: master       #CLUSTER  # greenplum role of this cluster, could be master or segment
pg_offline_query: false #INSTANCE # set to true to enable offline query on this instance
```

You have to assign these **identity parameters** explicitly, there's no default value for them.

|            Name             |   Type   | Level | Description                            |
|:---------------------------:|:--------:|:-----:|----------------------------------------|
| [`pg_cluster`](#pg_cluster) | `string` | **C** | **PG database cluster name**           |
|     [`pg_seq`](#pg_seq)     | `number` | **I** | **PG database instance id**            |
|    [`pg_role`](#pg_role)    |  `enum`  | **I** | **PG database instance role**          |
|   [`pg_shard`](#pg_shard)   | `string` | **C** | **PG database shard name of cluster**  |
|   [`pg_group`](#pg_group)   | `number` | **C** | **PG database shard index of cluster** |

* [`pg_cluster`](#pg_cluster): It identifies the name of the cluster, which is configured at the cluster level.
* [`pg_role`](#pg_role): Configured at the instance level, identifies the role of the ins. Only the `primary` role will be handled specially. If not filled in, the default is the `replica` role and the special `delayed` and `offline` roles.
* [`pg_seq`](#pg_seq): Used to identify the ins within the cluster, usually with an integer number incremented from 0 or 1, which is not changed once it is assigned.
* `{{ pg_cluster }}-{{ pg_seq }}` is used to uniquely identify the ins, i.e. `pg_instance`.
* `{{ pg_cluster }}-{{ pg_role }}` is used to identify the services within the cluster, i.e. `pg_service`.
* [`pg_shard`](#pg_shard) and [`pg_group`](#pg_group) are used for horizontally sharding clusters, for citus, greenplum, and matrixdb only.

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

All other params can be inherited from the global config or the default config, but the identity params must be **explicitly specified** and **manually assigned**.




### `pg_mode`

name: `pg_mode`, type: `enum`, level: `C`

pgsql cluster mode, cloud be `pgsql`, `citus`, or `gpsql`, `pgsql` by default.

If `pg_mode` is set to `citus` or `gpsql`, [`pg_shard`](#pg_shard) and [`pg_group`](#pg_group) will be required for horizontal sharding clusters.





### `pg_cluster`

name: `pg_cluster`, type: `string`, level: `C`

pgsql cluster name, REQUIRED identity parameter

The cluster name will be used as the namespace for PGSQL related resources within that cluster.

The naming needs to follow the specific naming pattern: `[a-z][a-z0-9-]*` to be compatible with the requirements of different constraints on the identity.




### `pg_seq`

name: `pg_seq`, type: `int`, level: `I`

pgsql instance seq number, REQUIRED identity parameter

A serial number of this instance, unique within its **cluster**, starting from 0 or 1.




### `pg_role`

name: `pg_role`, type: `enum`, level: `I`

pgsql role, REQUIRED, could be primary,replica,offline

Roles for PGSQL instance, can be: `primary`, `replica`, `standby` or `offline`.

* `primary`: Primary, there is one and only one primary in a cluster.
* `replica`: Replica for carrying online read-only traffic, there may be a slight replication delay through (10ms~100ms, 100KB).
* `standby`: Special replica that is always synced with primary, there's no replication delay & data loss on this replica. (currently same as `replica`)
* `offline`: Offline replica for taking on offline read-only traffic, such as statistical analysis/ETL/personal queries, etc.

**Identity params, required params, and instance-level params.**





### `pg_instances`

name: `pg_instances`, type: `dict`, level: `I`

define multiple pg instances on node in `{port:ins_vars}` format.

This parameter is reserved for multi-instance deployment on a single node which is not implemented in Pigsty yet. 





### `pg_upstream`

name: `pg_upstream`, type: `ip`, level: `I`

Upstream ip address for standby cluster or cascade replica

Setting `pg_upstream` is set on `primary` instance indicate that this cluster is a [**Standby Cluster**](PGSQL-CONF#standby-cluster), and will receiving changes from upstream instance, thus the `primary` is actually a `standby leader`.

Setting `pg_upstream` for a non-primary instance will explicitly set a replication upstream instance, if it is different from the primary ip addr, this instance will become a **cascade replica**. And it's user's responsibility to ensure that the upstream IP addr is another instance in the same cluster.





### `pg_shard`

name: `pg_shard`, type: `string`, level: `C`

pgsql shard name, required identity parameter for sharding clusters (e.g. citus cluster), optional for common pgsql clusters.

When multiple pgsql clusters serve the same business together in a horizontally sharding style, Pigsty will mark this group of clusters as a **Sharding Group**.

[`pg_shard`](#pg_shard) is the name of the shard group name. It's usually the prefix of [`pg_cluster`](#pg_cluster).

For example, if we have a sharding group `pg-citus`, and 4 clusters in it, there identity params will be: 

```
cls pg_shard: pg-citus
cls pg_group = 0:   pg-citus0
cls pg_group = 1:   pg-citus1
cls pg_group = 2:   pg-citus2
cls pg_group = 3:   pg-citus3
```





### `pg_group`

name: `pg_group`, type: `int`, level: `C`

pgsql shard index number, required identity for sharding clusters, optional for common pgsql clusters.

Sharding cluster index of sharding group, used in pair with [pg_shard](#pg_shard). You can use any non-negative integer as the index number.





### `gp_role`

name: `gp_role`, type: `enum`, level: `C`

greenplum/matrixdb role of this cluster, could be `master` or `segment`

- `master`:  mark the postgres cluster as greenplum master, which is the default value
- `segment`  mark the postgres cluster as greenplum segment

This parameter is only used for greenplum/matrixdb database, and is ignored for common pgsql cluster.





### `pg_exporters`

name: `pg_exporters`, type: `dict`, level: `C`

additional pg_exporters to monitor remote postgres instances, default values: `{}`

If you wish to monitoring remote postgres instances, define them in `pg_exporters` and load them with [`pgsql-monitor.yml`](PGSQL-PLAYBOOK#pgsql-monitoryml) playbook.

```yaml
pg_exporters: # list all remote instances here, alloc a unique unused local port as k
    20001: { pg_cluster: pg-foo, pg_seq: 1, pg_host: 10.10.10.10 }
    20004: { pg_cluster: pg-foo, pg_seq: 2, pg_host: 10.10.10.11 }
    20002: { pg_cluster: pg-bar, pg_seq: 1, pg_host: 10.10.10.12 }
    20003: { pg_cluster: pg-bar, pg_seq: 1, pg_host: 10.10.10.13 }
```

Check [PGSQL Monitoring](PGSQL-MONITOR) for details.




### `pg_offline_query`

name: `pg_offline_query`, type: `bool`, level: `I`

set to true to enable offline query on this instance

default value is `false`

When set to `true`, the user group `dbrole_offline` can connect to the ins and perform offline queries, regardless of the role of the current instance, just like a `offline` instance.

If you just have one replica or even one primary in your postgres cluster, adding this could mark it for accepting ETL, slow queries with interactive access.







------------------------------

## `PG_BUSINESS`

Database credentials, In-Database Objects that need to be taken care of by Users.

* Define Business Users: [`pg_users`](#pg_users)
* Define Business Databases: [`pg_databases`](#pg_databases)
* Define Cluster Services:  [`pg_services`](#pg_services) （全局定义：[`pg_default_services`](#pg_default_services)）
* Ad-Hoc PostgreSQL HBA Rules: [`pg_default_services`](#pg_default_services)
* Ad-Hoc Pgbouncer HBA Rules: [`pgb_hba_rules`](#pgb_hba_rules)

[Default Database Users](PGSQL-ACL#default-users):

* Administrator: [`pg_admin_username`](#pg_admin_username) / [`pg_admin_password`](#pg_admin_password)
* Replication User: [`pg_replication_username`](#pg_replication_username) / [`pg_replication_password`](#pg_replication_password)
* Monitor User: [`pg_monitor_username`](#pg_monitor_username) / [`pg_monitor_password`](#pg_monitor_password)

> WARNING: YOU HAVE TO CHANGE THESE DEFAULT **PASSWORD**s in production environment.


```yaml
# postgres business object definition, overwrite in group vars
pg_users: []                      # postgres business users
pg_databases: []                  # postgres business databases
pg_services: []                   # postgres business services
pg_hba_rules: []                  # business hba rules for postgres
pgb_hba_rules: []                 # business hba rules for pgbouncer
# global credentials, overwrite in global vars
pg_dbsu_password: ''              # dbsu password, empty string means no dbsu password by default
pg_replication_username: replicator
pg_replication_password: DBUser.Replicator
pg_admin_username: dbuser_dba
pg_admin_password: DBUser.DBA
pg_monitor_username: dbuser_monitor
pg_monitor_password: DBUser.Monitor
```




### `pg_users`

name: `pg_users`, type: `user[]`, level: `C`

postgres business users, has to be defined at cluster level.

default values: `[]`, each object in the array defines a [User/Role](PGSQL-USER). Examples:

```yaml
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
```

The only mandatory field of a user definition is `name`, and the rest are optional.





### `pg_databases`

name: `pg_databases`, type: `database[]`, level: `C`

postgres business databases, has to be defined at cluster level.

default values: `[]`, each object in the array defines a [Database](PGSQL-DB). Examples:


```yaml
- name: meta                      # REQUIRED, `name` is the only mandatory field of a database definition
  baseline: cmdb.sql              # optional, database sql baseline path, (relative path among ansible search path, e.g files/)
  pgbouncer: true                 # optional, add this database to pgbouncer database list? true by default
  schemas: [pigsty]               # optional, additional schemas to be created, array of schema names
  extensions:                     # optional, additional extensions to be installed: array of `{name[,schema]}`
    - { name: postgis , schema: public }
    - { name: timescaledb }
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
```

In each database definition, the DB  `name` is mandatory and the rest are optional.






### `pg_services`

name: `pg_services`, type: `service[]`, level: `C`

postgres business services exposed via haproxy, has to be defined at cluster level.

You can define ad hoc services with [`pg_services`](#pg_services) in additional to default [`pg_default_services`](#pg_default_services)

default values: `[]`, each object in the array defines a [**Service**](PGSQL-SVC#define-service). Examples:


```yaml
- name: standby                   # required, service name, the actual svc name will be prefixed with `pg_cluster`, e.g: pg-meta-standby
  port: 5435                      # required, service exposed port (work as kubernetes service node port mode)
  ip: "*"                         # optional, service bind ip address, `*` for all ip by default
  selector: "[]"                  # required, service member selector, use JMESPath to filter inventory
  dest: default                   # optional, destination port, default|postgres|pgbouncer|<port_number>, 'default' by default
  check: /sync                    # optional, health check url path, / by default
  backup: "[? pg_role == `primary`]"  # backup server selector
  maxconn: 3000                   # optional, max allowed front-end connection
  balance: roundrobin             # optional, haproxy load balance algorithm (roundrobin by default, other: leastconn)
  options: 'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'
```






### `pg_hba_rules`

name: `pg_hba_rules`, type: `hba[]`, level: `C`

business hba rules for postgres

default values: `[]`, each object in array is an **HBA Rule** definition:

Which are array of [hba](PGSQL-HBA#define-hba) object, each hba object may look like


```yaml
# RAW HBA RULES
- title: allow intranet password access
  role: common
  rules:
    - host   all  all  10.0.0.0/8      md5
    - host   all  all  172.16.0.0/12   md5
    - host   all  all  192.168.0.0/16  md5
```

* `title`: Rule Title, transform into comment in hba file
* `rules`: Array of strings, each string is a raw hba rule record
* `role`:  Applied roles, where to install these hba rules
  * `common`: apply for all instances
  * `primary`, `replica`,`standby`, `offline`: apply on corresponding instances with that [`pg_role`](#pg_role).
  * special case: HBA rule with `role == 'offline'` will be installed on instance with [`pg_offline_query`](#pg_offline_query) flag

or you can use another alias form

```yaml
- addr: 'intra'    # world|intra|infra|admin|local|localhost|cluster|<cidr>
  auth: 'pwd'      # trust|pwd|ssl|cert|deny|<official auth method>
  user: 'all'      # all|${dbsu}|${repl}|${admin}|${monitor}|<user>|<group>
  db: 'all'        # all|replication|....
  rules: []        # raw hba string precedence over above all
  title: allow intranet password access
```

[`pg_default_hba_rules`](#pg_default_hba_rules) is similar to this, but is used for global HBA rule settings







### `pgb_hba_rules`

name: `pgb_hba_rules`, type: `hba[]`, level: `C`

business hba rules for pgbouncer, default values: `[]`

Similar to [`pg_hba_rules`](#pg_hba_rules), array of [hba](PGSQL-HBA#define-hba) rule object, except this is for pgbouncer.






### `pg_replication_username`

name: `pg_replication_username`, type: `username`, level: `G`

postgres replication username, `replicator` by default

This parameter is globally used, it not wise to change it.





### `pg_replication_password`

name: `pg_replication_password`, type: `password`, level: `G`

postgres replication password, `DBUser.Replicator` by default

> WARNING: CHANGE THIS IN PRODUCTION ENVIRONMENT!!!!





### `pg_admin_username`

name: `pg_admin_username`, type: `username`, level: `G`

postgres admin username, `dbuser_dba` by default, which is a global postgres superuser.

default values: `dbuser_dba`





### `pg_admin_password`

name: `pg_admin_password`, type: `password`, level: `G`

postgres admin password in plain text, `DBUser.DBA` by default

> WARNING: CHANGE THIS IN PRODUCTION ENVIRONMENT!!!!





### `pg_monitor_username`

name: `pg_monitor_username`, type: `username`, level: `G`

postgres monitor username, `dbuser_monitor` by default, which is a global monitoring user.





### `pg_monitor_password`

name: `pg_monitor_password`, type: `password`, level: `G`

postgres monitor password, `DBUser.Monitor` by default.

> WARNING: CHANGE THIS IN PRODUCTION ENVIRONMENT!!!!




### `pg_dbsu_password`

name: `pg_dbsu_password`, type: `password`, level: `G/C`

PostgreSQL dbsu password for [`pg_dbsu`](#pg_dbsu), empty string means no dbsu password, which is the default behavior.

> WARNING: It's not recommend to set a dbsu password for common PGSQL clusters, except for [`pg_mode`](#pg_mode) = `citus`.








------------------------------

## `PG_INSTALL`

This section is responsible for installing PostgreSQL & Extensions.

If you wish to install a different major version, just make sure repo packages exists and overwrite [`pg_version`](#pg_version) on cluster level.

To install extra extensions, overwrite [`pg_extensions`](#pg_extensions) on cluster level. Beware that not all extensions are available with other major versions.


```yaml
pg_dbsu: postgres                 # os dbsu name, postgres by default, better not change it
pg_dbsu_uid: 26                   # os dbsu uid and gid, 26 for default postgres users and groups
pg_dbsu_sudo: limit               # dbsu sudo privilege, none,limit,all,nopass. limit by default
pg_dbsu_home: /var/lib/pgsql      # postgresql home directory, `/var/lib/pgsql` by default
pg_dbsu_ssh_exchange: true        # exchange postgres dbsu ssh key among same pgsql cluster
pg_version: 15                    # postgres major version to be installed, 15 by default
pg_bin_dir: /usr/pgsql/bin        # postgres binary dir, `/usr/pgsql/bin` by default
pg_log_dir: /pg/log/postgres      # postgres log dir, `/pg/log/postgres` by default
pg_packages:                      # pg packages to be installed, `${pg_version}` will be replaced
  - postgresql${pg_version}*
  - pgbouncer pg_exporter pgbadger vip-manager patroni patroni-etcd pgbackrest
pg_extensions:                    # pg extensions to be installed, `${pg_version}` will be replaced
  - pg_repack_${pg_version}* wal2json_${pg_version}* passwordcheck_cracklib_${pg_version}*
  - postgis34_${pg_version}* timescaledb-2-postgresql-${pg_version}* pgvector_${pg_version}*
```



### `pg_dbsu`

name: `pg_dbsu`, type: `username`, level: `C`

os dbsu name, `postgres` by default, it's not wise to change it.

When installing Greenplum / MatrixDB, set this parameter to the corresponding default value: `gpadmin|mxadmin`.




### `pg_dbsu_uid`

name: `pg_dbsu_uid`, type: `int`, level: `C`

os dbsu uid and gid, `26` for default postgres users and groups, which is consistent with the official pgdg RPM.

For Ubuntu/Debian, there's no default postgres UID/GID, consider using another ad hoc value, such as `543` instead.




### `pg_dbsu_sudo`

name: `pg_dbsu_sudo`, type: `enum`, level: `C`

dbsu sudo privilege, coud be `none`, `limit` ,`all` ,`nopass`. `limit` by default

* `none`: No Sudo privilege
* `limit`: Limited sudo privilege to execute systemctl commands for database-related components, default.
* `all`: Full `sudo` privilege, password required.
* `nopass`: Full `sudo` privileges without a password (not recommended).

default values: `limit`, which only allow `sudo systemctl <start|stop|reload> <postgres|patroni|pgbouncer|...> `





### `pg_dbsu_home`

name: `pg_dbsu_home`, type: `path`, level: `C`

postgresql home directory, `/var/lib/pgsql` by default, which is consistent with the official pgdg RPM.






### `pg_dbsu_ssh_exchange`

name: `pg_dbsu_ssh_exchange`, type: `bool`, level: `C`

exchange postgres dbsu ssh key among same pgsql cluster?

default value is `true`, means the dbsu can ssh to each other among the same cluster.





### `pg_version`

name: `pg_version`, type: `enum`, level: `C`

postgres major version to be installed, `15` by default

Note that PostgreSQL physical stream replication cannot cross major versions, so do not configure this on instance level.

You can use the parameters in [`pg_packages`](#pg_packages) and [`pg_extensions`](#pg_extensions) to install rpms for the specific pg major version.





### `pg_bin_dir`

name: `pg_bin_dir`, type: `path`, level: `C`

postgres binary dir, `/usr/pgsql/bin` by default

The default value is a soft link created manually during the installation process, pointing to the specific Postgres version dir installed.

For example `/usr/pgsql -> /usr/pgsql-15`. For more details, check [PGSQL File Structure](FHS#postgres-fhs) for details.




### `pg_log_dir`

name: `pg_log_dir`, type: `path`, level: `C`

postgres log dir, `/pg/log/postgres` by default.

> caveat: if `pg_log_dir` is prefixed with `pg_data` it will not be created explicit (it will be created by postgres itself then).




### `pg_packages`

name: `pg_packages`, type: `string[]`, level: `C`

pg packages to be installed, `${pg_version}` will be replaced to the actual value of [`pg_version`](#pg_version)

PostgreSQL, pgbouncer, pg_exporter, pgbadger, vip-manager, patroni, pgbackrest are install by default.

```yaml
pg_packages:                      # pg packages to be installed, `${pg_version}` will be replaced
  - postgresql${pg_version}*
  - pgbouncer pg_exporter pgbadger vip-manager patroni patroni-etcd pgbackrest
```

For Ubuntu/Debian, the proper value has to be replaced explicitly:

```yaml
pg_packages:                      # pg packages to be installed, `${pg_version}` will be replaced (ubuntu version)
  - postgresql-*-${pg_version}
  - patroni pgbouncer pgbackrest pg-exporter pgbadger vip-manager2
```




### `pg_extensions`

name: `pg_extensions`, type: `string[]`, level: `C`

pg extensions to be installed, `${pg_version}` will be replaced with actual [`pg_version`](#pg_version)

Pigsty will install the following extensions for all database instances by default: `postgis`, `timescaledb`, `pgvector`, `pg_repack`, `wal2json` and `passwordcheck_cracklib`.

```yaml
pg_extensions:                    # pg extensions to be installed, `${pg_version}` will be replaced
  - pg_repack_${pg_version}* wal2json_${pg_version}* passwordcheck_cracklib_${pg_version}*
  - postgis34_${pg_version}* timescaledb-2-postgresql-${pg_version}* pgvector_${pg_version}*
```

For Ubuntu/Debian, the proper value has to be replaced explicitly:

```yaml
pg_extensions:                    # pg extensions to be installed, `${pg_version}` will be replaced
  - postgresql-${pg_version}-wal2json postgresql-${pg_version}-repack
  - timescaledb-2-postgresql-${pg_version} postgresql-${pg_version}-pgvector
  - postgresql-${pg_version}-postgis-3 # postgis-3 broken in ubuntu20
```

Beware that not all extensions are available with other PG major versions, but Pigsty guarantees that important extensions `wal2json`, `pg_repack` and `passwordcheck_cracklib` (EL only) are available on all PG major versions.








------------------------------

## `PG_BOOTSTRAP`

Bootstrap a postgres cluster with patroni, and setup pgbouncer connection pool along with it.

It also init cluster template databases with default roles, schemas & extensions & default privileges specified in [`PG_PROVISION`](#pg_provision)


```yaml
pg_safeguard: false               # prevent purging running postgres instance? false by default
pg_clean: true                    # purging existing postgres during pgsql init? true by default
pg_data: /pg/data                 # postgres data directory, `/pg/data` by default
pg_fs_main: /data                 # mountpoint/path for postgres main data, `/data` by default
pg_fs_bkup: /data/backups         # mountpoint/path for pg backup data, `/data/backup` by default
pg_storage_type: SSD              # storage type for pg main data, SSD,HDD, SSD by default
pg_dummy_filesize: 64MiB          # size of `/pg/dummy`, hold 64MB disk space for emergency use
pg_listen: '0.0.0.0'              # postgres listen address, `0.0.0.0` (all ipv4 addr) by default
pg_port: 5432                     # postgres listen port, 5432 by default
pg_localhost: /var/run/postgresql # postgres unix socket dir for localhost connection
pg_namespace: /pg                 # top level key namespace in etcd, used by patroni & vip
patroni_enabled: true             # if disabled, no postgres cluster will be created during init
patroni_mode: default             # patroni working mode: default,pause,remove
patroni_port: 8008                # patroni listen port, 8008 by default
patroni_log_dir: /pg/log/patroni  # patroni log dir, `/pg/log/patroni` by default
patroni_ssl_enabled: false        # secure patroni RestAPI communications with SSL?
patroni_watchdog_mode: off        # patroni watchdog mode: automatic,required,off. off by default
patroni_username: postgres        # patroni restapi username, `postgres` by default
patroni_password: Patroni.API     # patroni restapi password, `Patroni.API` by default
patroni_citus_db: postgres        # citus database managed by patroni, postgres by default
pg_conf: oltp.yml                 # config template: oltp,olap,crit,tiny. `oltp.yml` by default
pg_max_conn: auto                 # postgres max connections, `auto` will use recommended value
pg_shared_buffer_ratio: 0.25      # postgres shared buffer ratio, 0.25 by default, 0.1~0.4
pg_rto: 30                        # recovery time objective in seconds,  `30s` by default
pg_rpo: 1048576                   # recovery point objective in bytes, `1MiB` at most by default
pg_libs: 'timescaledb, pg_stat_statements, auto_explain'  # extensions to be loaded
pg_delay: 0                       # replication apply delay for standby cluster leader
pg_checksum: false                # enable data checksum for postgres cluster?
pg_pwd_enc: scram-sha-256         # passwords encryption algorithm: md5,scram-sha-256
pg_encoding: UTF8                 # database cluster encoding, `UTF8` by default
pg_locale: C                      # database cluster local, `C` by default
pg_lc_collate: C                  # database cluster collate, `C` by default
pg_lc_ctype: en_US.UTF8           # database character type, `en_US.UTF8` by default
pgbouncer_enabled: true           # if disabled, pgbouncer will not be launched on pgsql host
pgbouncer_port: 6432              # pgbouncer listen port, 6432 by default
pgbouncer_log_dir: /pg/log/pgbouncer  # pgbouncer log dir, `/pg/log/pgbouncer` by default
pgbouncer_auth_query: false       # query postgres to retrieve unlisted business users?
pgbouncer_poolmode: transaction   # pooling mode: transaction,session,statement, transaction by default
pgbouncer_sslmode: disable        # pgbouncer client ssl mode, disable by default
```



### `pg_safeguard`

name: `pg_safeguard`, type: `bool`, level: `G/C/A`

prevent purging running postgres instance? false by default

If enabled, [`pgsql.yml`](PGSQL-PLAYBOOk#pgsqlyml) & [`pgsql-rm.yml`](PGSQL-PLAYBOOk#pgsql-rmyml) will abort immediately if any postgres instance is running.




### `pg_clean`

name: `pg_clean`, type: `bool`, level: `G/C/A`

purging existing postgres during pgsql init? true by default

default value is `true`, it will purge existing postgres instance during [`pgsql.yml`](PGSQL-PLAYBOOK#pgsqlyml) init. which makes the playbook idempotent.

if set to `false`, [`pgsql.yml`](PGSQL-PLAYBOOK#pgsqlyml) will abort if there's already a running postgres instance. and [`pgsql-rm.yml`](PGSQL-PLAYBOOk#pgsql-rmyml) will NOT remove postgres data (only stop the server).




### `pg_data`

name: `pg_data`, type: `path`, level: `C`

postgres data directory, `/pg/data` by default

default values: `/pg/data`, DO NOT CHANGE IT.

It's a soft link that point to underlying data directory. 

Check [PGSQL File Structure](FHS) for details. 





### `pg_fs_main`

name: `pg_fs_main`, type: `path`, level: `C`

mountpoint/path for postgres main data, `/data` by default

default values: `/data`, which will be used as parent dir of postgres main data directory: `/data/postgres`.

It's recommended to use NVME SSD for postgres main data storage, Pigsty is optimized for SSD storage by default.
But HDD is also supported, you can change [`pg_storage_type`](#pg_storage_type) to `HDD` to optimize for HDD storage.






### `pg_fs_bkup`

name: `pg_fs_bkup`, type: `path`, level: `C`

mountpoint/path for pg backup data, `/data/backup` by default

If you are using the default [`pgbackrest_method`](#pgbackrest_method) = `local`, it is recommended to have a separate disk for backup storage.

The backup disk should be large enough to hold all your backups, at least enough for 3 basebackups + 2 days WAL archive.
This is usually not a problem since you can use cheap & large HDD for that.

It's recommended to use a separate disk for backup storage, otherwise pigsty will fall back to the main data disk.





### `pg_storage_type`

name: `pg_storage_type`, type: `enum`, level: `C`

storage type for pg main data, `SSD`,`HDD`, `SSD` by default

default values: `SSD`, it will affect some tuning parameters, such as `random_page_cost` & `effective_io_concurrency`





### `pg_dummy_filesize`

name: `pg_dummy_filesize`, type: `size`, level: `C`

size of `/pg/dummy`, default values: `64MiB`, which hold 64MB disk space for emergency use

When the disk is full, removing the placeholder file can free up some space for emergency use, it is recommended to use at least `8GiB` for production use.





### `pg_listen`

name: `pg_listen`, type: `ip`, level: `C`

postgres/pgbouncer listen address, `0.0.0.0` (all ipv4 addr) by default

You can use placeholder in this variable:

* `${ip}`: translate to inventory_hostname, which is primary private IP address in the inventory
* `${vip}`: if [`pg_vip_enabled`](#pg_vip_enabled), this will translate to host part of [`pg_vip_address`](#pg_vip_address)
* `${lo}`: will translate to `127.0.0.1`

For example: `'${ip},${lo}'` or `'${ip},${vip},${lo}'`.





### `pg_port`

name: `pg_port`, type: `port`, level: `C`

postgres listen port, `5432` by default.





### `pg_localhost`

name: `pg_localhost`, type: `path`, level: `C`

postgres unix socket dir for localhost connection, default values: `/var/run/postgresql`

The Unix socket dir for PostgreSQL and Pgbouncer local connection, which is used by [`pg_exporter`](#pg_exporter) and patroni.





### `pg_namespace`

name: `pg_namespace`, type: `path`, level: `C`

top level key namespace in etcd, used by patroni & vip, default values is: `/pg` , and it's not recommended to change it.





### `patroni_enabled`

name: `patroni_enabled`, type: `bool`, level: `C`

if disabled, no postgres cluster will be created during init

default value is `true`, If disabled, Pigsty will skip pulling up patroni (thus postgres).

This option is useful when trying to add some components to an existing postgres instance.




### `patroni_mode`

name: `patroni_mode`, type: `enum`, level: `C`

patroni working mode: `default`, `pause`, `remove`

default values: `default`

* `default`: Bootstrap PostgreSQL cluster with Patroni
* `pause`: Just like `default`, but entering maintenance mode after bootstrap
* `remove`: Init the cluster with Patroni, them remove Patroni and use raw PostgreSQL instead.




### `patroni_port`

name: `patroni_port`, type: `port`, level: `C`

patroni listen port, `8008` by default, changing it is not recommended.

The Patroni API server listens on this port for health checking & API requests.




### `patroni_log_dir`

name: `patroni_log_dir`, type: `path`, level: `C`

patroni log dir, `/pg/log/patroni` by default, which will be collected by [`promtail`](#promtail).







### `patroni_ssl_enabled`

name: `patroni_ssl_enabled`, type: `bool`, level: `G`

Secure patroni RestAPI communications with SSL? default value is `false`

This parameter is a global flag that can only be set before deployment.

Since if SSL is enabled for patroni, you'll have to perform healthcheck, metrics scrape and API call with HTTPS instead of HTTP. 







### `patroni_watchdog_mode`

name: `patroni_watchdog_mode`, type: `string`, level: `C`

In case of primary failure, patroni can use [watchdog](https://patroni.readthedocs.io/en/latest/watchdog.html) to fencing the old primary node to avoid split-brain.

patroni watchdog mode: `automatic`, `required`, `off`:

* `off`: not using `watchdog`. avoid fencing at all. This is the default value.
* `automatic`: Enable `watchdog` if the kernel has `softdog` module enabled and watchdog is owned by dbsu 
* `required`: Force `watchdog`, refuse to start if `softdog` is not available

default value is `off`, you should not enable watchdog on infra nodes to avoid fencing.

For those critical systems where data consistency prevails over availability, it is recommended to enable watchdog.

Beware that if all your traffic is [accessed](PGSQL-SVC#access-service) via haproxy, there is no risk of brain split at all.






### `patroni_username`

name: `patroni_username`, type: `username`, level: `C`

patroni restapi username, `postgres` by default, used in pair with [`patroni_password`](#patroni_password)

Patroni unsafe RESTAPI is protected by username/password by default, check [Config Cluster](PGSQL-ADMIN#config-cluster) and [Patroni RESTAPI](https://patroni.readthedocs.io/en/latest/rest_api.html) for details. 




### `patroni_password`

name: `patroni_password`, type: `password`, level: `C`

patroni restapi password, `Patroni.API` by default

> WARNING: CHANGE THIS IN PRODUCTION ENVIRONMENT!!!!





### `patroni_citus_db`

name: `patroni_citus_db`, type: `string`, level: `C`

citus database managed by patroni, `postgres` by default.

Patroni 3.0's native citus will specify a managed database for citus. which is created by patroni itself.




### `pg_conf`

name: `pg_conf`, type: `enum`, level: `C`

config template: `{oltp,olap,crit,tiny}.yml`, `oltp.yml` by default

- `tiny.yml`: optimize for tiny nodes, virtual machines, small demo, (1~8Core, 1~16GB)
- `oltp.yml`: optimize for OLTP workloads and latency sensitive applications, (4C8GB+), which is the default template
- `olap.yml`: optimize for OLAP workloads and throughput (4C8G+)
- `crit.yml`: optimize for data consistency and critical applications (4C8G+) 

default values: `oltp.yml`, but [configure](INSTALL#configure) procedure will set this value to `tiny.yml` if current node is a tiny node.

You can have your own template, just put it under `templates/<mode>.yml` and set this value to the template name.





### `pg_max_conn`

name: `pg_max_conn`, type: `int`, level: `C`

postgres max connections, You can specify a value between 50 and 5000, or use `auto` to use recommended value.

default value is `auto`, which will set max connections according to the [`pg_conf`](#pg_conf) and [`pg_default_service_dest`](#pg_default_service_dest).

- tiny: 100
- olap: 200
- oltp: 200 (pgbouncer) / 1000 (postgres)
  - pg_default_service_dest = pgbouncer : 200
  - pg_default_service_dest = postgres : 1000
- crit: 200 (pgbouncer) / 1000 (postgres)
  - pg_default_service_dest = pgbouncer : 200
  - pg_default_service_dest = postgres : 1000

It's not recommended to set this value greater than 5000, otherwise you have to increase the haproxy service connection limit manually as well.

Pgbouncer's transaction pooling can alleviate the problem of too many OLTP connections, but it's not recommended to use it in OLAP scenarios.





### `pg_shared_buffer_ratio`

name: `pg_shared_buffer_ratio`, type: `float`, level: `C`

postgres shared buffer memory ratio, 0.25 by default, 0.1~0.4

default values: `0.25`, means 25% of node memory will be used as PostgreSQL shard buffers.

Setting this value greater than 0.4 (40%) is usually not a good idea. 

Note that shared buffer is only part of shared memory in PostgreSQL, to calculate the total shared memory, use `show shared_memory_size_in_huge_pages;`.




### `pg_rto`

name: `pg_rto`, type: `int`, level: `C`

recovery time objective in seconds, This will be used as Patroni TTL value, `30`s by default.

If a primary instance is missing for such a long time, a new leader election will be triggered.

Decrease the value can reduce the unavailable time (unable to write) of the cluster during failover, 
but it will make the cluster more sensitive to network jitter, thus increase the chance of false-positive failover.

Config this according to your network condition and expectation to **trade-off between chance and impact**,
the default value is 30s, and it will be populated to the following patroni parameters:

```yaml
# the TTL to acquire the leader lock (in seconds). Think of it as the length of time before initiation of the automatic failover process. Default value: 30
ttl: {{ pg_rto }}

# the number of seconds the loop will sleep. Default value: 10 , this is patroni check loop interval
loop_wait: {{ (pg_rto / 3)|round(0, 'ceil')|int }}

# timeout for DCS and PostgreSQL operation retries (in seconds). DCS or network issues shorter than this will not cause Patroni to demote the leader. Default value: 10
retry_timeout: {{ (pg_rto / 3)|round(0, 'ceil')|int }}

# the amount of time a primary is allowed to recover from failures before failover is triggered (in seconds), Max RTO: 2 loop wait + primary_start_timeout
primary_start_timeout: {{ (pg_rto / 3)|round(0, 'ceil')|int }}
```




### `pg_rpo`

name: `pg_rpo`, type: `int`, level: `C`

recovery point objective in bytes, `1MiB` at most by default

default values: `1048576`, which will tolerate at most 1MiB data loss during failover.

when the primary is down and all replicas are lagged, you have to make a tough choice to **trade off between Availability and Consistency**:

* Promote a replica to be the new primary and bring system back online ASAP, with the price of an acceptable data loss (e.g. less than 1MB).
* Wait for the primary to come back (which may never be) or human intervention to avoid any data loss.

You can use `crit.yml` [conf](#pg_conf) template to ensure no data loss during failover, but it will sacrifice some performance.
 






### `pg_libs`

name: `pg_libs`, type: `string`, level: `C`

shared preloaded libraries, `pg_stat_statements,auto_explain` by default. 

They are two extensions that come with PostgreSQL, and it is strongly recommended to enable them.

For existing clusters, you can [configure](PGSQL-ADMIN#config-cluster) the `shared_preload_libraries` parameter of the cluster and apply it.

If you want to use TimescaleDB or Citus extensions, you need to add `timescaledb` or `citus` to this list. `timescaledb` and `citus` should be placed at the top of this list, for example:

```
citus,timescaledb,pg_stat_statements,auto_explain
```

Other extensions that need to be loaded can also be added to this list, such as `pg_cron`, `pgml`, etc. 

Generally, `citus` and `timescaledb` have the highest priority and should be added to the top of the list.






### `pg_delay`

name: `pg_delay`, type: `interval`, level: `I`

replication apply delay for standby cluster leader , default values: `0`.

if this value is set to a positive value, the standby cluster leader will be delayed for this time before apply WAL changes.

Check [delayed standby cluster](PGSQL-CONF#delayed-cluster) for details.





### `pg_checksum`

name: `pg_checksum`, type: `bool`, level: `C`

enable data checksum for postgres cluster?, default value is `false`.

This parameter can only be set before PGSQL deployment. (but you can enable it manually later)

If [`pg_conf`](#pg_conf) `crit.yml` template is used, data checksum is always enabled regardless of this parameter to ensure data integrity.




### `pg_pwd_enc`

name: `pg_pwd_enc`, type: `enum`, level: `C`

passwords encryption algorithm: md5,scram-sha-256

default values: `scram-sha-256`, if you have compatibility issues with old clients, you can set it to `md5` instead. 





### `pg_encoding`

name: `pg_encoding`, type: `enum`, level: `C`

database cluster encoding, `UTF8` by default





### `pg_locale`

name: `pg_locale`, type: `enum`, level: `C`

database cluster local, `C` by default






### `pg_lc_collate`

name: `pg_lc_collate`, type: `enum`, level: `C`

database cluster collate, `C` by default, It's not recommended to change this value unless you know what you are doing.





### `pg_lc_ctype`

name: `pg_lc_ctype`, type: `enum`, level: `C`

database character type, `en_US.UTF8` by default






### `pgbouncer_enabled`

name: `pgbouncer_enabled`, type: `bool`, level: `C`

default value is `true`, if disabled, pgbouncer will not be launched on pgsql host






### `pgbouncer_port`

name: `pgbouncer_port`, type: `port`, level: `C`

pgbouncer listen port, `6432` by default






### `pgbouncer_log_dir`

name: `pgbouncer_log_dir`, type: `path`, level: `C`

pgbouncer log dir, `/pg/log/pgbouncer` by default, referenced by promtail the logging agent.






### `pgbouncer_auth_query`

name: `pgbouncer_auth_query`, type: `bool`, level: `C`

query postgres to retrieve unlisted business users? default value is `false`

If enabled, pgbouncer user will be authenticated against postgres database with `SELECT username, password FROM monitor.pgbouncer_auth($1)`, otherwise, only the users with `pgbouncer: true` will be allowed to connect to pgbouncer.





### `pgbouncer_poolmode`

name: `pgbouncer_poolmode`, type: `enum`, level: `C`

Pgbouncer pooling mode: `transaction`, `session`, `statement`, `transaction` by default

* `session`: Session-level pooling with the best compatibility.
* `transaction`: Transaction-level pooling with better performance (lots of small conns), could break some session level features such as notify/listen, etc... 
* `statements`: Statement-level pooling which is used for simple read-only queries.

If you application has some compatibility issues with pgbouncer, you can try to change this value to `session` instead.





### `pgbouncer_sslmode`

name: `pgbouncer_sslmode`, type: `enum`, level: `C`

pgbouncer client ssl mode, `disable` by default

default values: `disable`, beware that this may have a huge performance impact on your pgbouncer.

- `disable`: Plain TCP. If client requests TLS, it’s ignored. Default.
- `allow`: If client requests TLS, it is used. If not, plain TCP is used. If the client presents a client certificate, it is not validated.
- `prefer`: Same as allow.
- `require`: Client must use TLS. If not, the client connection is rejected. If the client presents a client certificate, it is not validated.
- `verify-ca`: Client must use TLS with valid client certificate.
- `verify-full`: Same as verify-ca.








------------------------------

## `PG_PROVISION`

PG_BOOTSTRAP will bootstrap a new postgres cluster with patroni, while PG_PROVISION will create default objects in the cluster, including:

* [Default Roles](PGSQL-ACL#default-roles)
* [Default Users](PGSQL-ACL#default-users)
* [Default Privileges](PGSQL-ACL#privileges)
* [Default HBA Rules](PGSQL-HBA#default-hba)
* Default Schemas
* Default Extensions


```yaml
pg_provision: true                # provision postgres cluster after bootstrap
pg_init: pg-init                  # provision init script for cluster template, `pg-init` by default
pg_default_roles:                 # default roles and users in postgres cluster
  - { name: dbrole_readonly  ,login: false ,comment: role for global read-only access     }
  - { name: dbrole_offline   ,login: false ,comment: role for restricted read-only access }
  - { name: dbrole_readwrite ,login: false ,roles: [dbrole_readonly] ,comment: role for global read-write access }
  - { name: dbrole_admin     ,login: false ,roles: [pg_monitor, dbrole_readwrite] ,comment: role for object creation }
  - { name: postgres     ,superuser: true  ,comment: system superuser }
  - { name: replicator ,replication: true  ,roles: [pg_monitor, dbrole_readonly] ,comment: system replicator }
  - { name: dbuser_dba   ,superuser: true  ,roles: [dbrole_admin]  ,pgbouncer: true ,pool_mode: session, pool_connlimit: 16 ,comment: pgsql admin user }
  - { name: dbuser_monitor ,roles: [pg_monitor] ,pgbouncer: true ,parameters: {log_min_duration_statement: 1000 } ,pool_mode: session ,pool_connlimit: 8 ,comment: pgsql monitor user }
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
pg_default_schemas: [ monitor ]   # default schemas to be created
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
pg_reload: true                   # reload postgres after hba changes
pg_default_hba_rules:             # postgres default host-based authentication rules
  - {user: '${dbsu}'    ,db: all         ,addr: local     ,auth: ident ,title: 'dbsu access via local os user ident'  }
  - {user: '${dbsu}'    ,db: replication ,addr: local     ,auth: ident ,title: 'dbsu replication from local os ident' }
  - {user: '${repl}'    ,db: replication ,addr: localhost ,auth: pwd   ,title: 'replicator replication from localhost'}
  - {user: '${repl}'    ,db: replication ,addr: intra     ,auth: pwd   ,title: 'replicator replication from intranet' }
  - {user: '${repl}'    ,db: postgres    ,addr: intra     ,auth: pwd   ,title: 'replicator postgres db from intranet' }
  - {user: '${monitor}' ,db: all         ,addr: localhost ,auth: pwd   ,title: 'monitor from localhost with password' }
  - {user: '${monitor}' ,db: all         ,addr: infra     ,auth: pwd   ,title: 'monitor from infra host with password'}
  - {user: '${admin}'   ,db: all         ,addr: infra     ,auth: ssl   ,title: 'admin @ infra nodes with pwd & ssl'   }
  - {user: '${admin}'   ,db: all         ,addr: world     ,auth: ssl   ,title: 'admin @ everywhere with ssl & pwd'    }
  - {user: '+dbrole_readonly',db: all    ,addr: localhost ,auth: pwd   ,title: 'pgbouncer read/write via local socket'}
  - {user: '+dbrole_readonly',db: all    ,addr: intra     ,auth: pwd   ,title: 'read/write biz user via password'     }
  - {user: '+dbrole_offline' ,db: all    ,addr: intra     ,auth: pwd   ,title: 'allow etl offline tasks from intranet'}
pgb_default_hba_rules:            # pgbouncer default host-based authentication rules
  - {user: '${dbsu}'    ,db: pgbouncer   ,addr: local     ,auth: peer  ,title: 'dbsu local admin access with os ident'}
  - {user: 'all'        ,db: all         ,addr: localhost ,auth: pwd   ,title: 'allow all user local access with pwd' }
  - {user: '${monitor}' ,db: pgbouncer   ,addr: intra     ,auth: pwd   ,title: 'monitor access via intranet with pwd' }
  - {user: '${monitor}' ,db: all         ,addr: world     ,auth: deny  ,title: 'reject all other monitor access addr' }
  - {user: '${admin}'   ,db: all         ,addr: intra     ,auth: pwd   ,title: 'admin access via intranet with pwd'   }
  - {user: '${admin}'   ,db: all         ,addr: world     ,auth: deny  ,title: 'reject all other admin access addr'   }
  - {user: 'all'        ,db: all         ,addr: intra     ,auth: pwd   ,title: 'allow all user intra access with pwd' }
```


### `pg_provision`

name: `pg_provision`, type: `bool`, level: `C`

provision postgres cluster after bootstrap, default value is `true`.

If disabled, postgres cluster will not be provisioned after bootstrap.





### `pg_init`

name: `pg_init`, type: `string`, level: `G/C`

Provision init script for cluster template, `pg-init` by default, which is located in [`roles/pgsql/templates/pg-init`](https://github.com/Vonng/pigsty/blob/master/roles/pgsql/templates/pg-init)

You can add your own logic in the init script, or provide a new one in `templates/` and set `pg_init` to the new script name.






### `pg_default_roles`

name: `pg_default_roles`, type: `role[]`, level: `G/C`

default roles and users in postgres cluster.  

Pigsty has a built-in role system, check [PGSQL Access Control](PGSQL-ACL#role-system) for details.

```yaml
pg_default_roles:                 # default roles and users in postgres cluster
  - { name: dbrole_readonly  ,login: false ,comment: role for global read-only access     }
  - { name: dbrole_offline   ,login: false ,comment: role for restricted read-only access }
  - { name: dbrole_readwrite ,login: false ,roles: [dbrole_readonly] ,comment: role for global read-write access }
  - { name: dbrole_admin     ,login: false ,roles: [pg_monitor, dbrole_readwrite] ,comment: role for object creation }
  - { name: postgres     ,superuser: true  ,comment: system superuser }
  - { name: replicator ,replication: true  ,roles: [pg_monitor, dbrole_readonly] ,comment: system replicator }
  - { name: dbuser_dba   ,superuser: true  ,roles: [dbrole_admin]  ,pgbouncer: true ,pool_mode: session, pool_connlimit: 16 ,comment: pgsql admin user }
  - { name: dbuser_monitor ,roles: [pg_monitor] ,pgbouncer: true ,parameters: {log_min_duration_statement: 1000 } ,pool_mode: session ,pool_connlimit: 8 ,comment: pgsql monitor user }
```




### `pg_default_privileges`

name: `pg_default_privileges`, type: `string[]`, level: `G/C`

default privileges for each databases:

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

Pigsty has a built-in privileges base on default role system, check [PGSQL Privileges](PGSQL-ACL#privileges) for details.




### `pg_default_schemas`

name: `pg_default_schemas`, type: `string[]`, level: `G/C`

default schemas to be created, default values is: `[ monitor ]`, which will create a `monitor` schema on all databases.





### `pg_default_extensions`

name: `pg_default_extensions`, type: `extension[]`, level: `G/C`

default extensions to be created, default value: 

```yaml
pg_default_extensions: # default extensions to be created
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

The only 3rd party extension is `pg_repack`, which is important for database maintenance, all other extensions are built-in postgres contrib extensions. 

Monitor related extensions are installed in `monitor` schema, which is created by [`pg_default_schemas`](#pg_default_schemas).




### `pg_reload`

name: `pg_reload`, type: `bool`, level: `A`

reload postgres after hba changes, default value is `true`

This is useful when you want to check before applying HBA changes, set it to `false` to disable reload.





### `pg_default_hba_rules`

name: `pg_default_hba_rules`, type: `hba[]`, level: `G/C`

postgres default host-based authentication rules, array of [hba](PGSQL-HBA#define-hba) rule object.

default value provides a fair enough security level for common scenarios, check [PGSQL Authentication](PGSQL-HBA) for details.

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
  - {user: '${admin}'   ,db: all         ,addr: world     ,auth: ssl   ,title: 'admin @ everywhere with ssl & pwd'    }
  - {user: '+dbrole_readonly',db: all    ,addr: localhost ,auth: pwd   ,title: 'pgbouncer read/write via local socket'}
  - {user: '+dbrole_readonly',db: all    ,addr: intra     ,auth: pwd   ,title: 'read/write biz user via password'     }
  - {user: '+dbrole_offline' ,db: all    ,addr: intra     ,auth: pwd   ,title: 'allow etl offline tasks from intranet'}
```




### `pgb_default_hba_rules`

name: `pgb_default_hba_rules`, type: `hba[]`, level: `G/C`

pgbouncer default host-based authentication rules, array or [hba](PGSQL-HBA#define-hba) rule object.

default value provides a fair enough security level for common scenarios, check [PGSQL Authentication](PGSQL-HBA) for details.

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








------------------------------

## `PG_BACKUP`

This section defines variables for [pgBackRest](https://pgbackrest.org/), which is used for PGSQL PITR (Point-In-Time-Recovery). 

Check [PGSQL Backup & PITR](PGSQL-PITR) for details.


```yaml
pgbackrest_enabled: true          # enable pgbackrest on pgsql host?
pgbackrest_clean: true            # remove pg backup data during init?
pgbackrest_log_dir: /pg/log/pgbackrest # pgbackrest log dir, `/pg/log/pgbackrest` by default
pgbackrest_method: local          # pgbackrest repo method: local,minio,[user-defined...]
pgbackrest_repo:                  # pgbackrest repo: https://pgbackrest.org/configuration.html#section-repository
  local:                          # default pgbackrest repo with local posix fs
    path: /pg/backup              # local backup directory, `/pg/backup` by default
    retention_full_type: count    # retention full backups by count
    retention_full: 2             # keep 2, at most 3 full backup when using local fs repo
  minio:                          # optional minio repo for pgbackrest
    type: s3                      # minio is s3-compatible, so s3 is used
    s3_endpoint: sss.pigsty       # minio endpoint domain name, `sss.pigsty` by default
    s3_region: us-east-1          # minio region, us-east-1 by default, useless for minio
    s3_bucket: pgsql              # minio bucket name, `pgsql` by default
    s3_key: pgbackrest            # minio user access key for pgbackrest
    s3_key_secret: S3User.Backup  # minio user secret key for pgbackrest
    s3_uri_style: path            # use path style uri for minio rather than host style
    path: /pgbackrest             # minio backup path, default is `/pgbackrest`
    storage_port: 9000            # minio port, 9000 by default
    storage_ca_file: /etc/pki/ca.crt  # minio ca file path, `/etc/pki/ca.crt` by default
    bundle: y                     # bundle small files into a single file
    cipher_type: aes-256-cbc      # enable AES encryption for remote backup repo
    cipher_pass: pgBackRest       # AES encryption password, default is 'pgBackRest'
    retention_full_type: time     # retention full backup by time on minio repo
    retention_full: 14            # keep full backup for last 14 days
```



### `pgbackrest_enabled`

name: `pgbackrest_enabled`, type: `bool`, level: `C`

enable pgBackRest on pgsql host? default value is `true`





### `pgbackrest_clean`

name: `pgbackrest_clean`, type: `bool`, level: `C`

remove pg backup data during init?  default value is `true`




### `pgbackrest_log_dir`

name: `pgbackrest_log_dir`, type: `path`, level: `C`

pgBackRest log dir, `/pg/log/pgbackrest` by default, which is referenced by [`promtail`](#promtail) the logging agent.





### `pgbackrest_method`

name: `pgbackrest_method`, type: `enum`, level: `C`

pgBackRest repo method: `local`, `minio`, or other user-defined methods, `local` by default

This parameter is used to determine which repo to use for pgBackRest, all available repo methods are defined in [`pgbackrest_repo`](#pgbackrest_repo).

Pigsty will use `local` backup repo by default, which will create a backup repo on primary instance's `/pg/backup` directory. The underlying storage is specified by [`pg_fs_bkup`](#pg_fs_bkup).





### `pgbackrest_repo`

name: `pgbackrest_repo`, type: `dict`, level: `G/C`

pgBackRest repo document: https://pgbackrest.org/configuration.html#section-repository

default value includes two repo methods: `local` and `minio`, which are defined as follows: 

```yaml
pgbackrest_repo:                  # pgbackrest repo: https://pgbackrest.org/configuration.html#section-repository
  local:                          # default pgbackrest repo with local posix fs
    path: /pg/backup              # local backup directory, `/pg/backup` by default
    retention_full_type: count    # retention full backups by count
    retention_full: 2             # keep 2, at most 3 full backup when using local fs repo
  minio:                          # optional minio repo for pgbackrest
    type: s3                      # minio is s3-compatible, so s3 is used
    s3_endpoint: sss.pigsty       # minio endpoint domain name, `sss.pigsty` by default
    s3_region: us-east-1          # minio region, us-east-1 by default, useless for minio
    s3_bucket: pgsql              # minio bucket name, `pgsql` by default
    s3_key: pgbackrest            # minio user access key for pgbackrest
    s3_key_secret: S3User.Backup  # minio user secret key for pgbackrest
    s3_uri_style: path            # use path style uri for minio rather than host style
    path: /pgbackrest             # minio backup path, default is `/pgbackrest`
    storage_port: 9000            # minio port, 9000 by default
    storage_ca_file: /etc/pki/ca.crt  # minio ca file path, `/etc/pki/ca.crt` by default
    bundle: y                     # bundle small files into a single file
    cipher_type: aes-256-cbc      # enable AES encryption for remote backup repo
    cipher_pass: pgBackRest       # AES encryption password, default is 'pgBackRest'
    retention_full_type: time     # retention full backup by time on minio repo
    retention_full: 14            # keep full backup for last 14 days
```







------------------------------

## `PG_SERVICE`

This section is about exposing PostgreSQL service to outside world: including:

* Exposing different PostgreSQL services on different ports with `haproxy`
* Bind an optional L2 VIP to the primary instance with `vip-manager`
* Register cluster/instance DNS records with to `dnsmasq` on infra nodes

```yaml
pg_weight: 100          #INSTANCE # relative load balance weight in service, 100 by default, 0-255
pg_default_service_dest: pgbouncer # default service destination if svc.dest='default'
pg_default_services:              # postgres default service definitions
  - { name: primary ,port: 5433 ,dest: default  ,check: /primary   ,selector: "[]" }
  - { name: replica ,port: 5434 ,dest: default  ,check: /read-only ,selector: "[]" , backup: "[? pg_role == `primary` || pg_role == `offline` ]" }
  - { name: default ,port: 5436 ,dest: postgres ,check: /primary   ,selector: "[]" }
  - { name: offline ,port: 5438 ,dest: postgres ,check: /replica   ,selector: "[? pg_role == `offline` || pg_offline_query ]" , backup: "[? pg_role == `replica` && !pg_offline_query]"}
pg_vip_enabled: false             # enable a l2 vip for pgsql primary? false by default
pg_vip_address: 127.0.0.1/24      # vip address in `<ipv4>/<mask>` format, require if vip is enabled
pg_vip_interface: eth0            # vip network interface to listen, eth0 by default
pg_dns_suffix: ''                 # pgsql dns suffix, '' by default
pg_dns_target: auto               # auto, primary, vip, none, or ad hoc ip
```



### `pg_weight`

name: `pg_weight`, type: `int`, level: `G`

relative load balance weight in service, 100 by default, 0-255

default values: `100`. you have to define it at instance vars, and [reload-service](PGSQL-ADMIN#reload-service) to take effect.




### `pg_service_provider`

name: `pg_service_provider`, type: `string`, level: `G/C`

dedicate haproxy node group name, or empty string for local nodes by default.

If specified, PostgreSQL Services will be registered to the dedicated haproxy node group instead of this pgsql cluster nodes.

Do remember to allocate **unique** ports on dedicate haproxy nodes for each service!

For example, if we define following parameters on 3-node `pg-test` cluster:

```yaml
pg_service_provider: infra       # use load balancer on group `infra`
pg_default_services:             # alloc port 10001 and 10002 for pg-test primary/replica service  
  - { name: primary ,port: 10001 ,dest: postgres  ,check: /primary   ,selector: "[]" }
  - { name: replica ,port: 10002 ,dest: postgres  ,check: /read-only ,selector: "[]" , backup: "[? pg_role == `primary` || pg_role == `offline` ]" }
```




### `pg_default_service_dest`

name: `pg_default_service_dest`, type: `enum`, level: `G/C`

When defining a [service](PGSQL-SVC#define-service), if svc.dest='default', this parameter will be used as the default value.

default values: `pgbouncer`, means 5433 primary service and 5434 replica service will route traffic to pgbouncer by default.

If you don't want to use pgbouncer, set it to `postgres` instead. traffic will be route to postgres directly.






### `pg_default_services`

name: `pg_default_services`, type: `service[]`, level: `G/C`

postgres default service definitions

default value is four default services definition, which is explained in [PGSQL Service](PGSQL-SVC#service)

```yaml
pg_default_services:               # postgres default service definitions
  - { name: primary ,port: 5433 ,dest: default  ,check: /primary   ,selector: "[]" }
  - { name: replica ,port: 5434 ,dest: default  ,check: /read-only ,selector: "[]" , backup: "[? pg_role == `primary` || pg_role == `offline` ]" }
  - { name: default ,port: 5436 ,dest: postgres ,check: /primary   ,selector: "[]" }
  - { name: offline ,port: 5438 ,dest: postgres ,check: /replica   ,selector: "[? pg_role == `offline` || pg_offline_query ]" , backup: "[? pg_role == `replica` && !pg_offline_query]"}
```






### `pg_vip_enabled`

name: `pg_vip_enabled`, type: `bool`, level: `C`

enable a l2 vip for pgsql primary?

default value is `false`, means no L2 VIP is created for this cluster.

L2 VIP can only be used in same L2 network, which may incurs extra restrictions on your network topology.





### `pg_vip_address`

name: `pg_vip_address`, type: `cidr4`, level: `C`

vip address in `<ipv4>/<mask>` format, if vip is enabled, this parameter is required.

default values: `127.0.0.1/24`. This value is consist of two parts: `ipv4` and `mask`, separated by `/`.





### `pg_vip_interface`

name: `pg_vip_interface`, type: `string`, level: `C/I`

vip network interface to listen, `eth0` by default.

It should be the same primary intranet interface of your node, which is the IP address you used in the inventory file.

If your node have different interface, you can override it on instance vars:

```yaml
pg-test:
    hosts:
        10.10.10.11: {pg_seq: 1, pg_role: replica ,pg_vip_interface: eth0 }
        10.10.10.12: {pg_seq: 2, pg_role: primary ,pg_vip_interface: eth1 }
        10.10.10.13: {pg_seq: 3, pg_role: replica ,pg_vip_interface: eth2 }
    vars:
        pg_vip_enabled: true          # enable L2 VIP for this cluster, bind to primary instance by default
        pg_vip_address: 10.10.10.3/24 # the L2 network CIDR: 10.10.10.0/24, the vip address: 10.10.10.3
        # pg_vip_interface: eth1      # if your node have non-uniform interface, you can define it here
```




### `pg_dns_suffix`

name: `pg_dns_suffix`, type: `string`, level: `C`

pgsql dns suffix, '' by default, cluster DNS name is defined as `{{ pg_cluster }}{{ pg_dns_suffix }}`

For example, if you set `pg_dns_suffix` to `.db.vip.company.tld` for cluster `pg-test`, then the cluster DNS name will be `pg-test.db.vip.company.tld`




### `pg_dns_target`

name: `pg_dns_target`, type: `enum`, level: `C`

Could be: `auto`, `primary`, `vip`, `none`, or an ad hoc ip address, which will be the target IP address of cluster DNS record. 

default values: `auto` , which will bind to `pg_vip_address` if `pg_vip_enabled`, or fallback to cluster primary instance ip address.

* `vip`: bind to `pg_vip_address`
* `primary`: resolve to cluster primary instance ip address
* `auto`: resolve to `pg_vip_address` if `pg_vip_enabled`, or fallback to cluster primary instance ip address.
* `none`: do not bind to any ip address
* `<ipv4>`: bind to the given IP address





------------------------------

## `PG_EXPORTER`

```yaml
pg_exporter_enabled: true              # enable pg_exporter on pgsql hosts?
pg_exporter_config: pg_exporter.yml    # pg_exporter configuration file name
pg_exporter_cache_ttls: '1,10,60,300'  # pg_exporter collector ttl stage in seconds, '1,10,60,300' by default
pg_exporter_port: 9630                 # pg_exporter listen port, 9630 by default
pg_exporter_params: 'sslmode=disable'  # extra url parameters for pg_exporter dsn
pg_exporter_url: ''                    # overwrite auto-generate pg dsn if specified
pg_exporter_auto_discovery: true       # enable auto database discovery? enabled by default
pg_exporter_exclude_database: 'template0,template1,postgres' # csv of database that WILL NOT be monitored during auto-discovery
pg_exporter_include_database: ''       # csv of database that WILL BE monitored during auto-discovery
pg_exporter_connect_timeout: 200       # pg_exporter connect timeout in ms, 200 by default
pg_exporter_options: ''                # overwrite extra options for pg_exporter
pgbouncer_exporter_enabled: true       # enable pgbouncer_exporter on pgsql hosts?
pgbouncer_exporter_port: 9631          # pgbouncer_exporter listen port, 9631 by default
pgbouncer_exporter_url: ''             # overwrite auto-generate pgbouncer dsn if specified
pgbouncer_exporter_options: ''         # overwrite extra options for pgbouncer_exporter
```



### `pg_exporter_enabled`

name: `pg_exporter_enabled`, type: `bool`, level: `C`

enable pg_exporter on pgsql hosts?

default value is `true`, if you don't want to install pg_exporter, set it to `false`.




### `pg_exporter_config`

name: `pg_exporter_config`, type: `string`, level: `C`

pg_exporter configuration file name, used by `pg_exporter` & `pgbouncer_exporter`

default values: `pg_exporter.yml`, if you want to use a custom configuration file, you can specify its relative path here.

Your config file should be placed in `files/<filename>.yml`. For example, if you want to monitor a remote PolarDB instance, you can use the sample config: `files/polar_exporter.yml`.





### `pg_exporter_cache_ttls`

name: `pg_exporter_cache_ttls`, type: `string`, level: `C`

pg_exporter collector ttl stage in seconds, '1,10,60,300' by default

default values: `1,10,60,300`, which will use 1s, 10s, 60s, 300s for different metric collectors.

```yaml
ttl_fast: "{{ pg_exporter_cache_ttls.split(',')[0]|int }}"         # critical queries
ttl_norm: "{{ pg_exporter_cache_ttls.split(',')[1]|int }}"         # common queries
ttl_slow: "{{ pg_exporter_cache_ttls.split(',')[2]|int }}"         # slow queries (e.g table size)
ttl_slowest: "{{ pg_exporter_cache_ttls.split(',')[3]|int }}"      # ver slow queries (e.g bloat)
```



### `pg_exporter_port`

name: `pg_exporter_port`, type: `port`, level: `C`

pg_exporter listen port, 9630 by default





### `pg_exporter_params`

name: `pg_exporter_params`, type: `string`, level: `C`

extra url parameters for pg_exporter dsn

default values: `sslmode=disable`, which will disable SSL for monitoring connection (since it's local unix socket by default)





### `pg_exporter_url`

name: `pg_exporter_url`, type: `pgurl`, level: `C`

overwrite auto-generate pg dsn if specified

default value is empty string, If specified, it will be used as the pg_exporter dsn instead of constructing from other parameters:

This could be useful if you want to monitor a remote pgsql instance, or you want to use a different user/password for monitoring.

```
'postgres://{{ pg_monitor_username }}:{{ pg_monitor_password }}@{{ pg_host }}:{{ pg_port }}/postgres{% if pg_exporter_params != '' %}?{{ pg_exporter_params }}{% endif %}'
```





### `pg_exporter_auto_discovery`

name: `pg_exporter_auto_discovery`, type: `bool`, level: `C`

enable auto database discovery? enabled by default

default value is `true`, which will auto-discover all databases on the postgres server and spawn a new pg_exporter connection for each database.




### `pg_exporter_exclude_database`

name: `pg_exporter_exclude_database`, type: `string`, level: `C`

csv of database that WILL NOT be monitored during auto-discovery

default values: `template0,template1,postgres`, which will be excluded for database auto discovery.





### `pg_exporter_include_database`

name: `pg_exporter_include_database`, type: `string`, level: `C`

csv of database that WILL BE monitored during auto-discovery

default value is empty string. If this value is set, only the databases in this list will be monitored during auto discovery.




### `pg_exporter_connect_timeout`

name: `pg_exporter_connect_timeout`, type: `int`, level: `C`

pg_exporter connect timeout in ms, 200 by default

default values: `200`ms , which is enough for most cases.

If your remote pgsql server is in another continent, you may want to increase this value to avoid connection timeout.





### `pg_exporter_options`

name: `pg_exporter_options`, type: `arg`, level: `C`

overwrite extra options for pg_exporter

default value is empty string, which will fall back the following default options: 

```
--log.level=info --log.format=logfmt
```

If you want to customize logging options or other pg_exporter options, you can set it here.





### `pgbouncer_exporter_enabled`

name: `pgbouncer_exporter_enabled`, type: `bool`, level: `C`

enable pgbouncer_exporter on pgsql hosts?

default value is `true`, which will enable pg_exporter for pgbouncer connection pooler.




### `pgbouncer_exporter_port`

name: `pgbouncer_exporter_port`, type: `port`, level: `C`

pgbouncer_exporter listen port, 9631 by default

default values: `9631`





### `pgbouncer_exporter_url`

name: `pgbouncer_exporter_url`, type: `pgurl`, level: `C`

overwrite auto-generate pgbouncer dsn if specified

default value is empty string,  If specified, it will be used as the pgbouncer_exporter dsn instead of constructing from other parameters:

```
'postgres://{{ pg_monitor_username }}:{{ pg_monitor_password }}@:{{ pgbouncer_port }}/pgbouncer?host={{ pg_localhost }}&sslmode=disable'
```

This could be useful if you want to monitor a remote pgbouncer instance, or you want to use a different user/password for monitoring.




### `pgbouncer_exporter_options`

name: `pgbouncer_exporter_options`, type: `arg`, level: `C`

overwrite extra options for pgbouncer_exporter, default value is empty string.


`--log.level=info --log.format=logfmt`

default value is empty string, which will fall back the following default options:

If you want to customize logging options or other pgbouncer_exporter options, you can set it here.

