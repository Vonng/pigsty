# 配置参数

> Pigsty 提供了 280+ 参数，用于描述数据库集群与整个环境的方方面面。

| 序号  | 参数                                                              |        模块         |                参数组                | 类型          | 层次    | 中文说明                                                                            |
|-----|-----------------------------------------------------------------|:-----------------:|:---------------------------------:|-------------|-------|---------------------------------------------------------------------------------|
| 101 | [`version`](#version)                                           | [`INFRA`](#infra) |          [`META`](#meta)          | string      | G     | pigsty 版本字符串                                                                    |
| 102 | [`admin_ip`](#admin_ip)                                         | [`INFRA`](#infra) |          [`META`](#meta)          | ip          | G     | 管理节点 IP 地址                                                                      |
| 103 | [`region`](#region)                                             | [`INFRA`](#infra) |          [`META`](#meta)          | enum        | G     | 上游镜像区域：default,china,europe                                                     |
| 104 | [`proxy_env`](#proxy_env)                                       | [`INFRA`](#infra) |          [`META`](#meta)          | dict        | G     | 下载包时使用的全局代理环境变量                                                                 |
| 105 | [`ca_method`](#ca_method)                                       | [`INFRA`](#infra) |            [`CA`](#ca)            | enum        | G     | CA处理方式：create,recreate,copy，默认为没有则创建                                            |
| 106 | [`ca_cn`](#ca_cn)                                               | [`INFRA`](#infra) |            [`CA`](#ca)            | string      | G     | CA CN名称，固定为 pigsty-ca                                                           |
| 107 | [`cert_validity`](#cert_validity)                               | [`INFRA`](#infra) |            [`CA`](#ca)            | interval    | G     | 证书有效期，默认为 20 年                                                                  |
| 108 | [`infra_seq`](#infra_seq)                                       | [`INFRA`](#infra) |      [`INFRA_ID`](#infra_id)      | int         | I     | 基础设施节号，必选身份参数                                                                   |
| 109 | [`infra_portal`](#infra_portal)                                 | [`INFRA`](#infra) |      [`INFRA_ID`](#infra_id)      | dict        | G     | 通过Nginx门户暴露的基础设施服务列表                                                            |
| 110 | [`repo_enabled`](#repo_enabled)                                 | [`INFRA`](#infra) |          [`REPO`](#repo)          | bool        | G/I   | 在此基础设施节点上创建软件仓库？                                                                |
| 111 | [`repo_home`](#repo_home)                                       | [`INFRA`](#infra) |          [`REPO`](#repo)          | path        | G     | 软件仓库主目录，默认为`/www`                                                               |
| 112 | [`repo_name`](#repo_name)                                       | [`INFRA`](#infra) |          [`REPO`](#repo)          | string      | G     | 软件仓库名称，默认为 pigsty                                                               |
| 113 | [`repo_endpoint`](#repo_endpoint)                               | [`INFRA`](#infra) |          [`REPO`](#repo)          | url         | G     | 仓库的访问点：域名或 `ip:port` 格式                                                         |
| 114 | [`repo_remove`](#repo_remove)                                   | [`INFRA`](#infra) |          [`REPO`](#repo)          | bool        | G/A   | 构建本地仓库时是否移除现有上游仓库源定义文件？                                                         |
| 115 | [`repo_modules`](#repo_modules)                                 | [`INFRA`](#infra) |          [`REPO`](#repo)          | string      | G/A   | 启用的上游仓库模块列表，用逗号分隔                                                               |
| 116 | [`repo_upstream`](#repo_upstream)                               | [`INFRA`](#infra) |          [`REPO`](#repo)          | upstream[]  | G     | 上游仓库源定义：从哪里下载上游包？                                                               |
| 117 | [`repo_packages`](#repo_packages)                               | [`INFRA`](#infra) |          [`REPO`](#repo)          | string[]    | G     | 从上游仓库下载哪些软件包？                                                                   |
| 118 | [`repo_url_packages`](#repo_url_packages)                       | [`INFRA`](#infra) |          [`REPO`](#repo)          | string[]    | G     | 使用URL下载的额外软件包列表                                                                 |
| 120 | [`infra_packages`](#infra_packages)                             | [`INFRA`](#infra) | [`INFRA_PACKAGE`](#infra_package) | string[]    | G     | 在基础设施节点上要安装的软件包                                                                 |
| 121 | [`infra_packages_pip`](#infra_packages_pip)                     | [`INFRA`](#infra) | [`INFRA_PACKAGE`](#infra_package) | string      | G     | 在基础设施节点上使用 pip 安装的包                                                             |
| 130 | [`nginx_enabled`](#nginx_enabled)                               | [`INFRA`](#infra) |         [`NGINX`](#nginx)         | bool        | G/I   | 在此基础设施节点上启用 nginx？                                                              |
| 131 | [`nginx_exporter_enabled`](#nginx_enabled)                      | [`INFRA`](#infra) |         [`NGINX`](#nginx)         | bool        | G/I   | 在此基础设施节点上启用 nginx_exporter？                                                     |
| 132 | [`nginx_sslmode`](#nginx_sslmode)                               | [`INFRA`](#infra) |         [`NGINX`](#nginx)         | enum        | G     | nginx SSL模式？disable,enable,enforce                                              |
| 133 | [`nginx_home`](#nginx_home)                                     | [`INFRA`](#infra) |         [`NGINX`](#nginx)         | path        | G     | nginx 内容目录，默认为 `/www`，通常和仓库目录一致                                                 |
| 134 | [`nginx_port`](#nginx_port)                                     | [`INFRA`](#infra) |         [`NGINX`](#nginx)         | port        | G     | nginx 监听端口，默认为 80                                                               |
| 135 | [`nginx_ssl_port`](#nginx_ssl_port)                             | [`INFRA`](#infra) |         [`NGINX`](#nginx)         | port        | G     | nginx SSL监听端口，默认为 443                                                           |
| 136 | [`nginx_navbar`](#nginx_navbar)                                 | [`INFRA`](#infra) |         [`NGINX`](#nginx)         | index[]     | G     | nginx 首页导航链接列表                                                                  |
| 140 | [`dns_enabled`](#dns_enabled)                                   | [`INFRA`](#infra) |           [`DNS`](#dns)           | bool        | G/I   | 在此基础设施节点上设置dnsmasq？                                                             |
| 141 | [`dns_port`](#dns_port)                                         | [`INFRA`](#infra) |           [`DNS`](#dns)           | port        | G     | DNS 服务器监听端口，默认为 53                                                              |
| 142 | [`dns_records`](#dns_records)                                   | [`INFRA`](#infra) |           [`DNS`](#dns)           | string[]    | G     | 由 dnsmasq 解析的动态 DNS 记录                                                          |
| 150 | [`prometheus_enabled`](#prometheus_enabled)                     | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | bool        | G/I   | 在此基础设施节点上启用 prometheus？                                                         |
| 151 | [`prometheus_clean`](#prometheus_clean)                         | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | bool        | G/A   | 初始化Prometheus的时候清除现有数据？                                                         |
| 152 | [`prometheus_data`](#prometheus_data)                           | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | path        | G     | Prometheus 数据目录，默认为 `/target/prometheus`                                        |
| 153 | [`prometheus_sd_dir`](#prometheus_sd_dir)                       | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | path        | G     | Prometheus 服务发现目标文件目录                                                           |
| 154 | [`prometheus_sd_interval`](#prometheus_sd_interval)             | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | interval    | G     | Prometheus 目标刷新间隔，默认为 5s                                                        |
| 155 | [`prometheus_scrape_interval`](#prometheus_scrape_interval)     | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | interval    | G     | Prometheus 抓取 & 评估间隔，默认为 10s                                                    |
| 156 | [`prometheus_scrape_timeout`](#prometheus_scrape_timeout)       | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | interval    | G     | Prometheus 全局抓取超时，默认为 8s                                                        |
| 157 | [`prometheus_options`](#prometheus_options)                     | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | arg         | G     | Prometheus 额外的命令行参数选项                                                           |
| 158 | [`pushgateway_enabled`](#pushgateway_enabled)                   | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | bool        | G/I   | 在此基础设施节点上设置 pushgateway？                                                        |
| 159 | [`pushgateway_options`](#pushgateway_options)                   | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | arg         | G     | pushgateway 额外的命令行参数选项                                                          |
| 160 | [`blackbox_enabled`](#blackbox_enabled)                         | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | bool        | G/I   | 在此基础设施节点上设置 blackbox_exporter？                                                  |
| 161 | [`blackbox_options`](#blackbox_options)                         | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | arg         | G     | blackbox_exporter 额外的命令行参数选项                                                    |
| 162 | [`alertmanager_enabled`](#alertmanager_enabled)                 | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | bool        | G/I   | 在此基础设施节点上设置 alertmanager？                                                       |
| 163 | [`alertmanager_options`](#alertmanager_options)                 | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | arg         | G     | alertmanager 额外的命令行参数选项                                                         |
| 164 | [`exporter_metrics_path`](#exporter_metrics_path)               | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | path        | G     | exporter 指标路径，默认为 /metrics                                                      |
| 165 | [`exporter_install`](#exporter_install)                         | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | enum        | G     | 如何安装 exporter？none,yum,binary                                                   |
| 166 | [`exporter_repo_url`](#exporter_repo_url)                       | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | url         | G     | 通过 yum 安装exporter时使用的yum仓库文件地址                                                  |
| 170 | [`grafana_enabled`](#grafana_enabled)                           | [`INFRA`](#infra) |       [`GRAFANA`](#grafana)       | bool        | G/I   | 在此基础设施节点上启用 Grafana？                                                            |
| 171 | [`grafana_clean`](#grafana_clean)                               | [`INFRA`](#infra) |       [`GRAFANA`](#grafana)       | bool        | G/A   | 初始化Grafana期间清除数据？                                                               |
| 172 | [`grafana_admin_username`](#grafana_admin_username)             | [`INFRA`](#infra) |       [`GRAFANA`](#grafana)       | username    | G     | Grafana 管理员用户名，默认为 `admin`                                                      |
| 173 | [`grafana_admin_password`](#grafana_admin_password)             | [`INFRA`](#infra) |       [`GRAFANA`](#grafana)       | password    | G     | Grafana 管理员密码，默认为 `pigsty`                                                      |
| 174 | [`grafana_plugin_cache`](#grafana_plugin_cache)                 | [`INFRA`](#infra) |       [`GRAFANA`](#grafana)       | path        | G     | Grafana 插件缓存 tarball 的路径                                                        |
| 175 | [`grafana_plugin_list`](#grafana_plugin_list)                   | [`INFRA`](#infra) |       [`GRAFANA`](#grafana)       | string[]    | G     | 使用 grafana-cli 下载的 Grafana 插件                                                   |
| 176 | [`loki_enabled`](#loki_enabled)                                 | [`INFRA`](#infra) |          [`LOKI`](#loki)          | bool        | G/I   | 在此基础设施节点上启用 loki？                                                               |
| 177 | [`loki_clean`](#loki_clean)                                     | [`INFRA`](#infra) |          [`LOKI`](#loki)          | bool        | G/A   | 是否删除现有的 loki 数据？                                                                |
| 178 | [`loki_data`](#loki_data)                                       | [`INFRA`](#infra) |          [`LOKI`](#loki)          | path        | G     | loki 数据目录，默认为 `/data/loki`                                                      |
| 179 | [`loki_retention`](#loki_retention)                             | [`INFRA`](#infra) |          [`LOKI`](#loki)          | interval    | G     | loki 日志保留期，默认为 15d                                                              |
| 201 | [`nodename`](#nodename)                                         |  [`NODE`](#node)  |       [`NODE_ID`](#node_id)       | string      | I     | node 实例标识，如缺失则使用主机名，可选                                                          |
| 202 | [`node_cluster`](#node_cluster)                                 |  [`NODE`](#node)  |       [`NODE_ID`](#node_id)       | string      | C     | node 集群标识，如缺失则使用默认值'nodes'，可选                                                   |
| 203 | [`nodename_overwrite`](#nodename_overwrite)                     |  [`NODE`](#node)  |       [`NODE_ID`](#node_id)       | bool        | C     | 用 nodename 覆盖节点的主机名吗？                                                           |
| 204 | [`nodename_exchange`](#nodename_exchange)                       |  [`NODE`](#node)  |       [`NODE_ID`](#node_id)       | bool        | C     | 在剧本主机之间交换 nodename 吗？                                                           |
| 205 | [`node_id_from_pg`](#node_id_from_pg)                           |  [`NODE`](#node)  |       [`NODE_ID`](#node_id)       | bool        | C     | 如果可行，是否借用 postgres 身份作为节点身份？                                                    |
| 210 | [`node_write_etc_hosts`](#node_write_etc_hosts)                 |  [`NODE`](#node)  |      [`NODE_DNS`](#node_dns)      | bool        | G/C/I | 是否修改目标节点上的 `/etc/hosts`？                                                        |
| 211 | [`node_default_etc_hosts`](#node_default_etc_hosts)             |  [`NODE`](#node)  |      [`NODE_DNS`](#node_dns)      | string[]    | G     | /etc/hosts 中的静态 DNS 记录                                                          |
| 212 | [`node_etc_hosts`](#node_etc_hosts)                             |  [`NODE`](#node)  |      [`NODE_DNS`](#node_dns)      | string[]    | C     | /etc/hosts 中的额外静态 DNS 记录                                                        |
| 213 | [`node_dns_method`](#node_dns_method)                           |  [`NODE`](#node)  |      [`NODE_DNS`](#node_dns)      | enum        | C     | 如何处理现有DNS服务器：add,none,overwrite                                                 |
| 214 | [`node_dns_servers`](#node_dns_servers)                         |  [`NODE`](#node)  |      [`NODE_DNS`](#node_dns)      | string[]    | C     | /etc/resolv.conf 中的动态域名服务器列表                                                    |
| 215 | [`node_dns_options`](#node_dns_options)                         |  [`NODE`](#node)  |      [`NODE_DNS`](#node_dns)      | string[]    | C     | /etc/resolv.conf 中的DNS解析选项                                                      |
| 220 | [`node_repo_modules`](#node_repo_modules)                       |  [`NODE`](#node)  |  [`NODE_PACKAGE`](#node_package)  | enum        | C     | 在节点上启用哪些软件源模块？默认为 local 使用本地源                                                   |
| 221 | [`node_repo_remove`](#node_repo_remove)                         |  [`NODE`](#node)  |  [`NODE_PACKAGE`](#node_package)  | bool        | C     | 配置节点软件仓库时，删除节点上现有的仓库吗？                                                          |
| 223 | [`node_packages`](#node_packages)                               |  [`NODE`](#node)  |  [`NODE_PACKAGE`](#node_package)  | string[]    | C     | 要在当前节点上安装的软件包列表                                                                 |
| 224 | [`node_default_packages`](#node_default_packages)               |  [`NODE`](#node)  |  [`NODE_PACKAGE`](#node_package)  | string[]    | G     | 默认在所有节点上安装的软件包列表                                                                |
| 230 | [`node_disable_firewall`](#node_disable_firewall)               |  [`NODE`](#node)  |     [`NODE_TUNE`](#node_tune)     | bool        | C     | 禁用节点防火墙？默认为 `true`                                                              |
| 231 | [`node_disable_selinux`](#node_disable_selinux)                 |  [`NODE`](#node)  |     [`NODE_TUNE`](#node_tune)     | bool        | C     | 禁用节点 selinux？默认为  `true`                                                        |
| 232 | [`node_disable_numa`](#node_disable_numa)                       |  [`NODE`](#node)  |     [`NODE_TUNE`](#node_tune)     | bool        | C     | 禁用节点 numa，禁用需要重启                                                                |
| 233 | [`node_disable_swap`](#node_disable_swap)                       |  [`NODE`](#node)  |     [`NODE_TUNE`](#node_tune)     | bool        | C     | 禁用节点 Swap，谨慎使用                                                                  |
| 234 | [`node_static_network`](#node_static_network)                   |  [`NODE`](#node)  |     [`NODE_TUNE`](#node_tune)     | bool        | C     | 重启后保留 DNS 解析器设置，即静态网络，默认启用                                                      |
| 235 | [`node_disk_prefetch`](#node_disk_prefetch)                     |  [`NODE`](#node)  |     [`NODE_TUNE`](#node_tune)     | bool        | C     | 在 HDD 上配置磁盘预取以提高性能                                                              |
| 236 | [`node_kernel_modules`](#node_kernel_modules)                   |  [`NODE`](#node)  |     [`NODE_TUNE`](#node_tune)     | string[]    | C     | 在此节点上启用的内核模块列表                                                                  |
| 237 | [`node_hugepage_count`](#node_hugepage_count)                   |  [`NODE`](#node)  |     [`NODE_TUNE`](#node_tune)     | int         | C     | 主机节点分配的 2MB 大页数量，优先级比比例更高                                                       |
| 238 | [`node_hugepage_ratio`](#node_hugepage_ratio)                   |  [`NODE`](#node)  |     [`NODE_TUNE`](#node_tune)     | float       | C     | 主机节点分配的内存大页占总内存比例，0 默认禁用                                                        |
| 239 | [`node_overcommit_ratio`](#node_overcommit_ratio)               |  [`NODE`](#node)  |     [`NODE_TUNE`](#node_tune)     | float       | C     | 节点内存允许的 OverCommit 超额比率 (50-100)，0 默认禁用                                         |
| 240 | [`node_tune`](#node_tune)                                       |  [`NODE`](#node)  |     [`NODE_TUNE`](#node_tune)     | enum        | C     | 节点调优配置文件：无，oltp,olap,crit,tiny                                                  |
| 241 | [`node_sysctl_params`](#node_sysctl_params)                     |  [`NODE`](#node)  |     [`NODE_TUNE`](#node_tune)     | dict        | C     | 额外的 sysctl 配置参数，k:v 格式                                                          |
| 250 | [`node_data`](#node_data)                                       |  [`NODE`](#node)  |    [`NODE_ADMIN`](#node_admin)    | path        | C     | 节点主数据目录，默认为 `/data`                                                             |
| 251 | [`node_admin_enabled`](#node_admin_enabled)                     |  [`NODE`](#node)  |    [`NODE_ADMIN`](#node_admin)    | bool        | C     | 在目标节点上创建管理员用户吗？                                                                 |
| 252 | [`node_admin_uid`](#node_admin_uid)                             |  [`NODE`](#node)  |    [`NODE_ADMIN`](#node_admin)    | int         | C     | 节点管理员用户的 uid 和 gid                                                              |
| 253 | [`node_admin_username`](#node_admin_username)                   |  [`NODE`](#node)  |    [`NODE_ADMIN`](#node_admin)    | username    | C     | 节点管理员用户的名称，默认为 `dba`                                                            |
| 254 | [`node_admin_ssh_exchange`](#node_admin_ssh_exchange)           |  [`NODE`](#node)  |    [`NODE_ADMIN`](#node_admin)    | bool        | C     | 是否在节点集群之间交换管理员 ssh 密钥                                                           |
| 255 | [`node_admin_pk_current`](#node_admin_pk_current)               |  [`NODE`](#node)  |    [`NODE_ADMIN`](#node_admin)    | bool        | C     | 将当前用户的 ssh 公钥添加到管理员的 authorized_keys 中吗？                                        |
| 256 | [`node_admin_pk_list`](#node_admin_pk_list)                     |  [`NODE`](#node)  |    [`NODE_ADMIN`](#node_admin)    | string[]    | C     | 要添加到管理员用户的 ssh 公钥                                                               |
| 260 | [`node_timezone`](#node_timezone)                               |  [`NODE`](#node)  |     [`NODE_TIME`](#node_time)     | string      | C     | 设置主机节点时区，空字符串跳过                                                                 |
| 261 | [`node_ntp_enabled`](#node_ntp_enabled)                         |  [`NODE`](#node)  |     [`NODE_TIME`](#node_time)     | bool        | C     | 启用 chronyd 时间同步服务吗？                                                             |
| 262 | [`node_ntp_servers`](#node_ntp_servers)                         |  [`NODE`](#node)  |     [`NODE_TIME`](#node_time)     | string[]    | C     | /etc/chrony.conf 中的 ntp 服务器列表                                                   |
| 263 | [`node_crontab_overwrite`](#node_crontab_overwrite)             |  [`NODE`](#node)  |     [`NODE_TIME`](#node_time)     | bool        | C     | 写入 /etc/crontab 时，追加写入还是全部覆盖？                                                   |
| 264 | [`node_crontab`](#node_crontab)                                 |  [`NODE`](#node)  |     [`NODE_TIME`](#node_time)     | string[]    | C     | 在 /etc/crontab 中的 crontab 条目                                                    |
| 270 | [`vip_enabled`](#vip_enabled)                                   |  [`NODE`](#node)  |      [`NODE_VIP`](#node_vip)      | bool        | C     | 在此节点集群上启用 L2 vip 吗？                                                             |
| 271 | [`vip_address`](#vip_address)                                   |  [`NODE`](#node)  |      [`NODE_VIP`](#node_vip)      | ip          | C     | 节点 vip 地址的 ipv4 格式，启用 vip 时为必要参数                                                |
| 272 | [`vip_vrid`](#vip_vrid)                                         |  [`NODE`](#node)  |      [`NODE_VIP`](#node_vip)      | int         | C     | 所需的整数，1-254，在同一 VLAN 中应唯一                                                       |
| 273 | [`vip_role`](#vip_role)                                         |  [`NODE`](#node)  |      [`NODE_VIP`](#node_vip)      | enum        | I     | 可选，master/backup，默认为 backup，用作初始角色                                              |
| 274 | [`vip_preempt`](#vip_preempt)                                   |  [`NODE`](#node)  |      [`NODE_VIP`](#node_vip)      | bool        | C/I   | 可选，true/false，默认为 false，启用 vip 抢占                                               |
| 275 | [`vip_interface`](#vip_interface)                               |  [`NODE`](#node)  |      [`NODE_VIP`](#node_vip)      | string      | C/I   | 节点 vip 网络接口监听，默认为 eth0                                                          |
| 276 | [`vip_dns_suffix`](#vip_dns_suffix)                             |  [`NODE`](#node)  |      [`NODE_VIP`](#node_vip)      | string      | C     | 节点 vip DNS 名称后缀，默认为空字符串                                                         |
| 277 | [`vip_exporter_port`](#vip_exporter_port)                       |  [`NODE`](#node)  |      [`NODE_VIP`](#node_vip)      | port        | C     | keepalived exporter 监听端口，默认为 9650                                               |
| 280 | [`haproxy_enabled`](#haproxy_enabled)                           |  [`NODE`](#node)  |       [`HAPROXY`](#haproxy)       | bool        | C     | 在此节点上启用 haproxy 吗？                                                              |
| 281 | [`haproxy_clean`](#haproxy_clean)                               |  [`NODE`](#node)  |       [`HAPROXY`](#haproxy)       | bool        | G/C/A | 清除所有现有的 haproxy 配置吗？                                                            |
| 282 | [`haproxy_reload`](#haproxy_reload)                             |  [`NODE`](#node)  |       [`HAPROXY`](#haproxy)       | bool        | A     | 配置后重新加载 haproxy 吗？                                                              |
| 283 | [`haproxy_auth_enabled`](#haproxy_auth_enabled)                 |  [`NODE`](#node)  |       [`HAPROXY`](#haproxy)       | bool        | G     | 启用 haproxy 管理页面的身份验证？                                                           |
| 284 | [`haproxy_admin_username`](#haproxy_admin_username)             |  [`NODE`](#node)  |       [`HAPROXY`](#haproxy)       | username    | G     | haproxy 管理用户名，默认为 `admin`                                                       |
| 285 | [`haproxy_admin_password`](#haproxy_admin_password)             |  [`NODE`](#node)  |       [`HAPROXY`](#haproxy)       | password    | G     | haproxy 管理密码，默认为 `pigsty`                                                       |
| 286 | [`haproxy_exporter_port`](#haproxy_exporter_port)               |  [`NODE`](#node)  |       [`HAPROXY`](#haproxy)       | port        | C     | haproxy exporter 的端口，默认为 9101                                                   |
| 287 | [`haproxy_client_timeout`](#haproxy_client_timeout)             |  [`NODE`](#node)  |       [`HAPROXY`](#haproxy)       | interval    | C     | haproxy 客户端连接超时，默认为 24h                                                         |
| 288 | [`haproxy_server_timeout`](#haproxy_server_timeout)             |  [`NODE`](#node)  |       [`HAPROXY`](#haproxy)       | interval    | C     | haproxy 服务器端连接超时，默认为 24h                                                        |
| 289 | [`haproxy_services`](#haproxy_services)                         |  [`NODE`](#node)  |       [`HAPROXY`](#haproxy)       | service[]   | C     | 要在节点上对外暴露的 haproxy 服务列表                                                         |
| 290 | [`node_exporter_enabled`](#node_exporter_enabled)               |  [`NODE`](#node)  | [`NODE_EXPORTER`](#node_exporter) | bool        | C     | 在此节点上配置 node_exporter 吗？                                                        |
| 291 | [`node_exporter_port`](#node_exporter_port)                     |  [`NODE`](#node)  | [`NODE_EXPORTER`](#node_exporter) | port        | C     | node exporter 监听端口，默认为 9100                                                     |
| 292 | [`node_exporter_options`](#node_exporter_options)               |  [`NODE`](#node)  | [`NODE_EXPORTER`](#node_exporter) | arg         | C     | node_exporter 的额外服务器选项                                                          |
| 293 | [`promtail_enabled`](#promtail_enabled)                         |  [`NODE`](#node)  |      [`PROMTAIL`](#promtail)      | bool        | C     | 启用 promtail 日志收集器吗？                                                             |
| 294 | [`promtail_clean`](#promtail_clean)                             |  [`NODE`](#node)  |      [`PROMTAIL`](#promtail)      | bool        | G/A   | 初始化期间清除现有的 promtail 状态文件吗？                                                      |
| 295 | [`promtail_port`](#promtail_port)                               |  [`NODE`](#node)  |      [`PROMTAIL`](#promtail)      | port        | C     | promtail 监听端口，默认为 9080                                                          |
| 296 | [`promtail_positions`](#promtail_positions)                     |  [`NODE`](#node)  |      [`PROMTAIL`](#promtail)      | path        | C     | promtail 位置状态文件路径                                                               |
| 401 | [`docker_enabled`](#docker_enabled)                             |  [`NODE`](#node)  |        [`DOCKER`](#docker)        | bool        | C     | 在当前节点上启用 Docker？默认不启用                                                           |
| 402 | [`docker_cgroups_driver`](#docker_cgroups_driver)               |  [`NODE`](#node)  |        [`DOCKER`](#docker)        | enum        | C     | Docker CGroup 文件系统驱动：cgroupfs,systemd                                           |
| 403 | [`docker_registry_mirrors`](#docker_registry_mirrors)           |  [`NODE`](#node)  |        [`DOCKER`](#docker)        | string[]    | C     | Docker 仓库镜像列表                                                                   |
| 404 | [`docker_image_cache`](#docker_image_cache)                     |  [`NODE`](#node)  |        [`DOCKER`](#docker)        | path        | C     | Docker 镜像缓存目录：默认为`/tmp/docker`                                                  |
| 501 | [`etcd_seq`](#etcd_seq)                                         |  [`ETCD`](#etcd)  |          [`ETCD`](#etcd)          | int         | I     | etcd 实例标识符，必填                                                                   |
| 502 | [`etcd_cluster`](#etcd_cluster)                                 |  [`ETCD`](#etcd)  |          [`ETCD`](#etcd)          | string      | C     | etcd 集群名，默认固定为 etcd                                                             |
| 503 | [`etcd_safeguard`](#etcd_safeguard)                             |  [`ETCD`](#etcd)  |          [`ETCD`](#etcd)          | bool        | G/C/A | etcd 防误删保险，阻止清除正在运行的 etcd 实例？                                                   |
| 504 | [`etcd_clean`](#etcd_clean)                                     |  [`ETCD`](#etcd)  |          [`ETCD`](#etcd)          | bool        | G/C/A | etcd 清除指令：在初始化时清除现有的 etcd 实例？                                                   |
| 505 | [`etcd_data`](#etcd_data)                                       |  [`ETCD`](#etcd)  |          [`ETCD`](#etcd)          | path        | C     | etcd 数据目录，默认为 /data/etcd                                                        |
| 506 | [`etcd_port`](#etcd_port)                                       |  [`ETCD`](#etcd)  |          [`ETCD`](#etcd)          | port        | C     | etcd 客户端端口，默认为 2379                                                             |
| 507 | [`etcd_peer_port`](#etcd_peer_port)                             |  [`ETCD`](#etcd)  |          [`ETCD`](#etcd)          | port        | C     | etcd 同伴端口，默认为 2380                                                              |
| 508 | [`etcd_init`](#etcd_init)                                       |  [`ETCD`](#etcd)  |          [`ETCD`](#etcd)          | enum        | C     | etcd 初始集群状态，新建或已存在                                                              |
| 509 | [`etcd_election_timeout`](#etcd_election_timeout)               |  [`ETCD`](#etcd)  |          [`ETCD`](#etcd)          | int         | C     | etcd 选举超时，默认为 1000ms                                                            |
| 510 | [`etcd_heartbeat_interval`](#etcd_heartbeat_interval)           |  [`ETCD`](#etcd)  |          [`ETCD`](#etcd)          | int         | C     | etcd 心跳间隔，默认为 100ms                                                             |
| 601 | [`minio_seq`](#minio_seq)                                       | [`MINIO`](#minio) |         [`MINIO`](#minio)         | int         | I     | minio 实例标识符，必填                                                                  |
| 602 | [`minio_cluster`](#minio_cluster)                               | [`MINIO`](#minio) |         [`MINIO`](#minio)         | string      | C     | minio 集群名称，默认为 minio                                                            |
| 603 | [`minio_clean`](#minio_clean)                                   | [`MINIO`](#minio) |         [`MINIO`](#minio)         | bool        | G/C/A | 初始化时清除 minio？默认为 false                                                          |
| 604 | [`minio_user`](#minio_user)                                     | [`MINIO`](#minio) |         [`MINIO`](#minio)         | username    | C     | minio 操作系统用户，默认为 `minio`                                                        |
| 605 | [`minio_node`](#minio_node)                                     | [`MINIO`](#minio) |         [`MINIO`](#minio)         | string      | C     | minio 节点名模式                                                                     |
| 606 | [`minio_data`](#minio_data)                                     | [`MINIO`](#minio) |         [`MINIO`](#minio)         | path        | C     | minio 数据目录，使用 `{x...y}` 指定多个磁盘                                                  |
| 607 | [`minio_domain`](#minio_domain)                                 | [`MINIO`](#minio) |         [`MINIO`](#minio)         | string      | G     | minio 外部域名，默认为 `sss.pigsty`                                                     |
| 608 | [`minio_port`](#minio_port)                                     | [`MINIO`](#minio) |         [`MINIO`](#minio)         | port        | C     | minio 服务端口，默认为 9000                                                             |
| 609 | [`minio_admin_port`](#minio_admin_port)                         | [`MINIO`](#minio) |         [`MINIO`](#minio)         | port        | C     | minio 控制台端口，默认为 9001                                                            |
| 610 | [`minio_access_key`](#minio_access_key)                         | [`MINIO`](#minio) |         [`MINIO`](#minio)         | username    | C     | 根访问密钥，默认为 `minioadmin`                                                          |
| 611 | [`minio_secret_key`](#minio_secret_key)                         | [`MINIO`](#minio) |         [`MINIO`](#minio)         | password    | C     | 根密钥，默认为 `minioadmin`                                                            |
| 612 | [`minio_extra_vars`](#minio_extra_vars)                         | [`MINIO`](#minio) |         [`MINIO`](#minio)         | string      | C     | minio 服务器的额外环境变量                                                                |
| 613 | [`minio_alias`](#minio_alias)                                   | [`MINIO`](#minio) |         [`MINIO`](#minio)         | string      | G     | minio 部署的客户端别名                                                                  |
| 614 | [`minio_buckets`](#minio_buckets)                               | [`MINIO`](#minio) |         [`MINIO`](#minio)         | bucket[]    | C     | 待创建的 minio 存储桶列表                                                                |
| 615 | [`minio_users`](#minio_users)                                   | [`MINIO`](#minio) |         [`MINIO`](#minio)         | user[]      | C     | 待创建的 minio 用户列表                                                                 |
| 701 | [`redis_cluster`](#redis_cluster)                               | [`REDIS`](#redis) |         [`REDIS`](#redis)         | string      | C     | Redis数据库集群名称，必选身份参数                                                             |
| 702 | [`redis_instances`](#redis_instances)                           | [`REDIS`](#redis) |         [`REDIS`](#redis)         | dict        | I     | Redis节点上的实例定义                                                                   |
| 703 | [`redis_node`](#redis_node)                                     | [`REDIS`](#redis) |         [`REDIS`](#redis)         | int         | I     | Redis节点编号，正整数，集群内唯一，必选身份参数                                                      |
| 710 | [`redis_fs_main`](#redis_fs_main)                               | [`REDIS`](#redis) |         [`REDIS`](#redis)         | path        | C     | Redis主数据目录，默认为 `/data`                                                          |
| 711 | [`redis_exporter_enabled`](#redis_exporter_enabled)             | [`REDIS`](#redis) |         [`REDIS`](#redis)         | bool        | C     | Redis Exporter 是否启用？                                                            |
| 712 | [`redis_exporter_port`](#redis_exporter_port)                   | [`REDIS`](#redis) |         [`REDIS`](#redis)         | port        | C     | Redis Exporter监听端口                                                              |
| 713 | [`redis_exporter_options`](#redis_exporter_options)             | [`REDIS`](#redis) |         [`REDIS`](#redis)         | string      | C/I   | Redis Exporter命令参数                                                              |
| 720 | [`redis_safeguard`](#redis_safeguard)                           | [`REDIS`](#redis) |         [`REDIS`](#redis)         | bool        | G/C/A | 禁止抹除现存的Redis                                                                    |
| 721 | [`redis_clean`](#redis_clean)                                   | [`REDIS`](#redis) |         [`REDIS`](#redis)         | bool        | G/C/A | 初始化Redis是否抹除现存实例                                                                |
| 722 | [`redis_rmdata`](#redis_rmdata)                                 | [`REDIS`](#redis) |         [`REDIS`](#redis)         | bool        | G/C/A | 移除Redis实例时是否一并移除数据？                                                             |
| 723 | [`redis_mode`](#redis_mode)                                     | [`REDIS`](#redis) |         [`REDIS`](#redis)         | enum        | C     | Redis集群模式：sentinel，cluster，standalone                                           |
| 724 | [`redis_conf`](#redis_conf)                                     | [`REDIS`](#redis) |         [`REDIS`](#redis)         | string      | C     | Redis配置文件模板，sentinel 除外                                                         |
| 725 | [`redis_bind_address`](#redis_bind_address)                     | [`REDIS`](#redis) |         [`REDIS`](#redis)         | ip          | C     | Redis监听地址，默认留空则会绑定主机IP                                                          |
| 726 | [`redis_max_memory`](#redis_max_memory)                         | [`REDIS`](#redis) |         [`REDIS`](#redis)         | size        | C/I   | Redis可用的最大内存                                                                    |
| 727 | [`redis_mem_policy`](#redis_mem_policy)                         | [`REDIS`](#redis) |         [`REDIS`](#redis)         | enum        | C     | Redis内存逐出策略                                                                     |
| 728 | [`redis_password`](#redis_password)                             | [`REDIS`](#redis) |         [`REDIS`](#redis)         | password    | C     | Redis密码，默认留空则禁用密码                                                               |
| 729 | [`redis_rdb_save`](#redis_rdb_save)                             | [`REDIS`](#redis) |         [`REDIS`](#redis)         | string[]    | C     | Redis RDB 保存指令，字符串列表，空数组则禁用RDB                                                  |
| 730 | [`redis_aof_enabled`](#redis_aof_enabled)                       | [`REDIS`](#redis) |         [`REDIS`](#redis)         | bool        | C     | Redis AOF 是否启用？                                                                 |
| 731 | [`redis_rename_commands`](#redis_rename_commands)               | [`REDIS`](#redis) |         [`REDIS`](#redis)         | dict        | C     | Redis危险命令重命名列表                                                                  |
| 732 | [`redis_cluster_replicas`](#redis_cluster_replicas)             | [`REDIS`](#redis) |         [`REDIS`](#redis)         | int         | C     | Redis原生集群中每个主库配几个从库？                                                            |
| 733 | [`redis_sentinel_monitor`](#redis_sentinel_monitor)             | [`REDIS`](#redis) |         [`REDIS`](#redis)         | master[]    | C     | Redis哨兵监控的主库列表，只在哨兵集群上使用                                                        |
| 801 | [`pg_mode`](#pg_mode)                                           | [`PGSQL`](#pgsql) |         [`PG_ID`](#pg_id)         | enum        | C     | pgsql 集群模式: pgsql,citus,gpsql                                                   |
| 802 | [`pg_cluster`](#pg_cluster)                                     | [`PGSQL`](#pgsql) |         [`PG_ID`](#pg_id)         | string      | C     | pgsql 集群名称, 必选身份参数                                                              |
| 803 | [`pg_seq`](#pg_seq)                                             | [`PGSQL`](#pgsql) |         [`PG_ID`](#pg_id)         | int         | I     | pgsql 实例号, 必选身份参数                                                               |
| 804 | [`pg_role`](#pg_role)                                           | [`PGSQL`](#pgsql) |         [`PG_ID`](#pg_id)         | enum        | I     | pgsql 实例角色, 必选身份参数, 可为 primary，replica，offline                                  |
| 805 | [`pg_instances`](#pg_instances)                                 | [`PGSQL`](#pgsql) |         [`PG_ID`](#pg_id)         | dict        | I     | 在一个节点上定义多个 pg 实例，使用 `{port:ins_vars}` 格式                                        |
| 806 | [`pg_upstream`](#pg_upstream)                                   | [`PGSQL`](#pgsql) |         [`PG_ID`](#pg_id)         | ip          | I     | 级联从库或备份集群或的复制上游节点IP地址                                                           |
| 807 | [`pg_shard`](#pg_shard)                                         | [`PGSQL`](#pgsql) |         [`PG_ID`](#pg_id)         | string      | C     | pgsql 分片名，对 citus 与 gpsql 等水平分片集群为必选身份参数                                        |
| 808 | [`pg_group`](#pg_group)                                         | [`PGSQL`](#pgsql) |         [`PG_ID`](#pg_id)         | int         | C     | pgsql 分片号，正整数，对 citus 与 gpsql 等水平分片集群为必选身份参数                                    |
| 809 | [`gp_role`](#gp_role)                                           | [`PGSQL`](#pgsql) |         [`PG_ID`](#pg_id)         | enum        | C     | 这个集群的 greenplum 角色，可以是 master 或 segment                                         |
| 810 | [`pg_exporters`](#pg_exporters)                                 | [`PGSQL`](#pgsql) |         [`PG_ID`](#pg_id)         | dict        | C     | 在该节点上设置额外的 pg_exporters 用于监控远程 postgres 实例                                      |
| 811 | [`pg_offline_query`](#pg_offline_query)                         | [`PGSQL`](#pgsql) |         [`PG_ID`](#pg_id)         | bool        | I     | 设置为 true 将此只读实例标记为特殊的离线从库，承载 Offline 服务，允许离线查询                                  |
| 820 | [`pg_users`](#pg_users)                                         | [`PGSQL`](#pgsql) |   [`PG_BUSINESS`](#pg_business)   | user[]      | C     | postgres 业务用户                                                                   |
| 821 | [`pg_databases`](#pg_databases)                                 | [`PGSQL`](#pgsql) |   [`PG_BUSINESS`](#pg_business)   | database[]  | C     | postgres 业务数据库                                                                  |
| 822 | [`pg_services`](#pg_services)                                   | [`PGSQL`](#pgsql) |   [`PG_BUSINESS`](#pg_business)   | service[]   | C     | postgres 业务服务                                                                   |
| 823 | [`pg_hba_rules`](#pg_hba_rules)                                 | [`PGSQL`](#pgsql) |   [`PG_BUSINESS`](#pg_business)   | hba[]       | C     | postgres 的业务 hba 规则                                                             |
| 824 | [`pgb_hba_rules`](#pgb_hba_rules)                               | [`PGSQL`](#pgsql) |   [`PG_BUSINESS`](#pg_business)   | hba[]       | C     | pgbouncer 的业务 hba 规则                                                            |
| 831 | [`pg_replication_username`](#pg_replication_username)           | [`PGSQL`](#pgsql) |   [`PG_BUSINESS`](#pg_business)   | username    | G     | postgres 复制用户名，默认为 `replicator`                                                 |
| 832 | [`pg_replication_password`](#pg_replication_password)           | [`PGSQL`](#pgsql) |   [`PG_BUSINESS`](#pg_business)   | password    | G     | postgres 复制密码，默认为 `DBUser.Replicator`                                           |
| 833 | [`pg_admin_username`](#pg_admin_username)                       | [`PGSQL`](#pgsql) |   [`PG_BUSINESS`](#pg_business)   | username    | G     | postgres 管理员用户名，默认为 `dbuser_dba`                                                |
| 834 | [`pg_admin_password`](#pg_admin_password)                       | [`PGSQL`](#pgsql) |   [`PG_BUSINESS`](#pg_business)   | password    | G     | postgres 管理员明文密码，默认为 `DBUser.DBA`                                               |
| 835 | [`pg_monitor_username`](#pg_monitor_username)                   | [`PGSQL`](#pgsql) |   [`PG_BUSINESS`](#pg_business)   | username    | G     | postgres 监控用户名，默认为 `dbuser_monitor`                                             |
| 836 | [`pg_monitor_password`](#pg_monitor_password)                   | [`PGSQL`](#pgsql) |   [`PG_BUSINESS`](#pg_business)   | password    | G     | postgres 监控密码，默认为 `DBUser.Monitor`                                              |
| 837 | [`pg_dbsu_password`](#pg_dbsu_password)                         | [`PGSQL`](#pgsql) |   [`PG_BUSINESS`](#pg_business)   | password    | G/C   | dbsu 密码，默认为空字符串意味着不设置 dbsu 密码，最好不要设置。                                           |
| 840 | [`pg_dbsu`](#pg_dbsu)                                           | [`PGSQL`](#pgsql) |    [`PG_INSTALL`](#pg_install)    | username    | C     | 操作系统 dbsu 名称，默认为 postgres，最好不要更改                                                |
| 841 | [`pg_dbsu_uid`](#pg_dbsu_uid)                                   | [`PGSQL`](#pgsql) |    [`PG_INSTALL`](#pg_install)    | int         | C     | 操作系统 dbsu uid 和 gid，对于默认的 postgres 用户和组为 26                                     |
| 842 | [`pg_dbsu_sudo`](#pg_dbsu_sudo)                                 | [`PGSQL`](#pgsql) |    [`PG_INSTALL`](#pg_install)    | enum        | C     | dbsu sudo 权限, none,limit,all,nopass，默认为 limit，有限sudo权限                          |
| 843 | [`pg_dbsu_home`](#pg_dbsu_home)                                 | [`PGSQL`](#pgsql) |    [`PG_INSTALL`](#pg_install)    | path        | C     | postgresql 主目录，默认为 `/var/lib/pgsql`                                             |
| 844 | [`pg_dbsu_ssh_exchange`](#pg_dbsu_ssh_exchange)                 | [`PGSQL`](#pgsql) |    [`PG_INSTALL`](#pg_install)    | bool        | C     | 在 pgsql 集群之间交换 postgres dbsu ssh 密钥                                             |
| 845 | [`pg_version`](#pg_version)                                     | [`PGSQL`](#pgsql) |    [`PG_INSTALL`](#pg_install)    | enum        | C     | 要安装的 postgres 主版本，默认为 16                                                        |
| 846 | [`pg_bin_dir`](#pg_bin_dir)                                     | [`PGSQL`](#pgsql) |    [`PG_INSTALL`](#pg_install)    | path        | C     | postgres 二进制目录，默认为 `/usr/pgsql/bin`                                             |
| 847 | [`pg_log_dir`](#pg_log_dir)                                     | [`PGSQL`](#pgsql) |    [`PG_INSTALL`](#pg_install)    | path        | C     | postgres 日志目录，默认为 `/pg/log/postgres`                                            |
| 848 | [`pg_packages`](#pg_packages)                                   | [`PGSQL`](#pgsql) |    [`PG_INSTALL`](#pg_install)    | string[]    | C     | 要安装的 pg 包，`${pg_version}` 将被替换为实际主版本号                                           |
| 849 | [`pg_extensions`](#pg_extensions)                               | [`PGSQL`](#pgsql) |    [`PG_INSTALL`](#pg_install)    | string[]    | C     | 要安装的 pg 扩展，`${pg_version}` 将被替换为实际主版本号                                          |
| 850 | [`pg_safeguard`](#pg_safeguard)                                 | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | bool        | G/C/A | 防误删保险，禁止清除正在运行的 postgres 实例？默认为 false                                           |
| 851 | [`pg_clean`](#pg_clean)                                         | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | bool        | G/C/A | 在 pgsql 初始化期间清除现有的 postgres？默认为 true                                            |
| 852 | [`pg_data`](#pg_data)                                           | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | path        | C     | postgres 数据目录，默认为 `/pg/data`                                                    |
| 853 | [`pg_fs_main`](#pg_fs_main)                                     | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | path        | C     | postgres 主数据的挂载点/路径，默认为 `/data`                                                 |
| 854 | [`pg_fs_bkup`](#pg_fs_bkup)                                     | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | path        | C     | pg 备份数据的挂载点/路径，默认为 `/data/backup`                                               |
| 855 | [`pg_storage_type`](#pg_storage_type)                           | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | enum        | C     | pg 主数据的存储类型，SSD、HDD，默认为 SSD，影响自动优化的参数。                                          |
| 856 | [`pg_dummy_filesize`](#pg_dummy_filesize)                       | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | size        | C     | `/pg/dummy` 的大小，默认保留 64MB 磁盘空间用于紧急抢修                                            |
| 857 | [`pg_listen`](#pg_listen)                                       | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | ip(s)       | C/I   | postgres/pgbouncer 的监听地址，用逗号分隔的IP列表，默认为 `0.0.0.0`                               |
| 858 | [`pg_port`](#pg_port)                                           | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | port        | C     | postgres 监听端口，默认为 5432                                                          |
| 859 | [`pg_localhost`](#pg_localhost)                                 | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | path        | C     | postgres 的 Unix 套接字目录，用于本地连接                                                    |
| 860 | [`pg_namespace`](#pg_namespace)                                 | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | path        | C     | 在 etcd 中的顶级键命名空间，被 patroni & vip 用于高可用管理                                        |
| 861 | [`patroni_enabled`](#patroni_enabled)                           | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | bool        | C     | 如果禁用，初始化期间不会创建 postgres 集群                                                      |
| 862 | [`patroni_mode`](#patroni_mode)                                 | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | enum        | C     | patroni 工作模式：default,pause,remove                                               |
| 863 | [`patroni_port`](#patroni_port)                                 | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | port        | C     | patroni 监听端口，默认为 8008                                                           |
| 864 | [`patroni_log_dir`](#patroni_log_dir)                           | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | path        | C     | patroni 日志目录，默认为 `/pg/log/patroni`                                              |
| 865 | [`patroni_ssl_enabled`](#patroni_ssl_enabled)                   | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | bool        | G     | 使用 SSL 保护 patroni RestAPI 通信？                                                   |
| 866 | [`patroni_watchdog_mode`](#patroni_watchdog_mode)               | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | enum        | C     | patroni 看门狗模式：automatic,required,off，默认为 off                                    |
| 867 | [`patroni_username`](#patroni_username)                         | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | username    | C     | patroni restapi 用户名，默认为 `postgres`                                              |
| 868 | [`patroni_password`](#patroni_password)                         | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | password    | C     | patroni restapi 密码，默认为 `Patroni.API`                                            |
| 869 | [`patroni_citus_db`](#patroni_citus_db)                         | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | string      | C     | 由 Patroni 所管理的 Citus 数据库名称，默认为 `postgres`                                       |
| 870 | [`pg_conf`](#pg_conf)                                           | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | enum        | C     | 配置模板：oltp,olap,crit,tiny，默认为 `oltp.yml`                                         |
| 871 | [`pg_max_conn`](#pg_max_conn)                                   | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | int         | C     | postgres 最大连接数，`auto` 将使用推荐值                                                    |
| 872 | [`pg_shared_buffer_ratio`](#pg_shared_buffer_ratio)             | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | float       | C     | postgres 共享缓冲区内存比率，默认为 0.25，范围 0.1~0.4                                          |
| 873 | [`pg_rto`](#pg_rto)                                             | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | int         | C     | 恢复时间目标（秒），默认为 `30s`                                                             |
| 874 | [`pg_rpo`](#pg_rpo)                                             | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | int         | C     | 恢复点目标（字节），默认为 `1MiB`                                                            |
| 875 | [`pg_libs`](#pg_libs)                                           | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | string      | C     | 预加载的库，默认为 `timescaledb,pg_stat_statements,auto_explain`                         |
| 876 | [`pg_delay`](#pg_delay)                                         | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | interval    | I     | 备份集群主库的WAL重放应用延迟，用于制备延迟从库                                                       |
| 877 | [`pg_checksum`](#pg_checksum)                                   | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | bool        | C     | 为 postgres 集群启用数据校验和？                                                           |
| 878 | [`pg_pwd_enc`](#pg_pwd_enc)                                     | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | enum        | C     | 密码加密算法：md5,scram-sha-256                                                        |
| 879 | [`pg_encoding`](#pg_encoding)                                   | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | enum        | C     | 数据库集群编码，默认为 `UTF8`                                                              |
| 880 | [`pg_locale`](#pg_locale)                                       | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | enum        | C     | 数据库集群本地化设置，默认为 `C`                                                              |
| 881 | [`pg_lc_collate`](#pg_lc_collate)                               | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | enum        | C     | 数据库集群排序，默认为 `C`                                                                 |
| 882 | [`pg_lc_ctype`](#pg_lc_ctype)                                   | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | enum        | C     | 数据库字符类型，默认为 `en_US.UTF8`                                                        |
| 890 | [`pgbouncer_enabled`](#pgbouncer_enabled)                       | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | bool        | C     | 如果禁用，则不会配置 pgbouncer 连接池                                                        |
| 891 | [`pgbouncer_port`](#pgbouncer_port)                             | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | port        | C     | pgbouncer 监听端口，默认为 6432                                                         |
| 892 | [`pgbouncer_log_dir`](#pgbouncer_log_dir)                       | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | path        | C     | pgbouncer 日志目录，默认为 `/pg/log/pgbouncer`                                          |
| 893 | [`pgbouncer_auth_query`](#pgbouncer_auth_query)                 | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | bool        | C     | 使用 AuthQuery 来从 postgres 获取未列出的业务用户？                                            |
| 894 | [`pgbouncer_poolmode`](#pgbouncer_poolmode)                     | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | enum        | C     | 池化模式：transaction,session,statement，默认为 transaction                              |
| 895 | [`pgbouncer_sslmode`](#pgbouncer_sslmode)                       | [`PGSQL`](#pgsql) |  [`PG_BOOTSTRAP`](#pg_bootstrap)  | enum        | C     | pgbouncer 客户端 SSL 模式，默认为禁用                                                      |
| 900 | [`pg_provision`](#pg_provision)                                 | [`PGSQL`](#pgsql) |  [`PG_PROVISION`](#pg_provision)  | bool        | C     | 在引导后置备 postgres 集群内部的业务对象？                                                      |
| 901 | [`pg_init`](#pg_init)                                           | [`PGSQL`](#pgsql) |  [`PG_PROVISION`](#pg_provision)  | string      | G/C   | 为集群模板提供初始化脚本，默认为 `pg-init`                                                      |
| 902 | [`pg_default_roles`](#pg_default_roles)                         | [`PGSQL`](#pgsql) |  [`PG_PROVISION`](#pg_provision)  | role[]      | G/C   | postgres 集群中的默认预定义角色和系统用户                                                       |
| 903 | [`pg_default_privileges`](#pg_default_privileges)               | [`PGSQL`](#pgsql) |  [`PG_PROVISION`](#pg_provision)  | string[]    | G/C   | 由管理员用户创建数据库内对象时的默认权限                                                            |
| 904 | [`pg_default_schemas`](#pg_default_schemas)                     | [`PGSQL`](#pgsql) |  [`PG_PROVISION`](#pg_provision)  | string[]    | G/C   | 要创建的默认模式列表                                                                      |
| 905 | [`pg_default_extensions`](#pg_default_extensions)               | [`PGSQL`](#pgsql) |  [`PG_PROVISION`](#pg_provision)  | extension[] | G/C   | 要创建的默认扩展列表                                                                      |
| 906 | [`pg_reload`](#pg_reload)                                       | [`PGSQL`](#pgsql) |  [`PG_PROVISION`](#pg_provision)  | bool        | A     | 更改HBA后，是否立即重载 postgres 配置                                                       |
| 907 | [`pg_default_hba_rules`](#pg_default_hba_rules)                 | [`PGSQL`](#pgsql) |  [`PG_PROVISION`](#pg_provision)  | hba[]       | G/C   | postgres 基于主机的认证规则，全局PG默认HBA                                                    |
| 908 | [`pgb_default_hba_rules`](#pgb_default_hba_rules)               | [`PGSQL`](#pgsql) |  [`PG_PROVISION`](#pg_provision)  | hba[]       | G/C   | pgbouncer 默认的基于主机的认证规则，全局PGB默认HBA                                               |
| 910 | [`pgbackrest_enabled`](#pgbackrest_enabled)                     | [`PGSQL`](#pgsql) |     [`PG_BACKUP`](#pg_backup)     | bool        | C     | 在 pgsql 主机上启用 pgbackrest？                                                       |
| 911 | [`pgbackrest_clean`](#pgbackrest_clean)                         | [`PGSQL`](#pgsql) |     [`PG_BACKUP`](#pg_backup)     | bool        | C     | 在初始化时删除以前的 pg 备份数据？                                                             |
| 912 | [`pgbackrest_log_dir`](#pgbackrest_log_dir)                     | [`PGSQL`](#pgsql) |     [`PG_BACKUP`](#pg_backup)     | path        | C     | pgbackrest 日志目录，默认为 `/pg/log/pgbackrest`                                        |
| 913 | [`pgbackrest_method`](#pgbackrest_method)                       | [`PGSQL`](#pgsql) |     [`PG_BACKUP`](#pg_backup)     | enum        | C     | pgbackrest 使用的仓库：local,minio,等...                                               |
| 914 | [`pgbackrest_repo`](#pgbackrest_repo)                           | [`PGSQL`](#pgsql) |     [`PG_BACKUP`](#pg_backup)     | dict        | G/C   | pgbackrest 仓库[定义](https://pgbackrest.org/configuration.html#section-repository) |
| 921 | [`pg_weight`](#pg_weight)                                       | [`PGSQL`](#pgsql) |    [`PG_SERVICE`](#pg_service)    | int         | I     | 在服务中的相对负载均衡权重，默认为 100，范围 0-255                                                  |
| 922 | [`pg_service_provider`](#pg_service_provider)                   | [`PGSQL`](#pgsql) |    [`PG_SERVICE`](#pg_service)    | string      | G/C   | 专用的 haproxy 节点组名称，或默认空字符，使用本地节点上的 haproxy                                       |
| 923 | [`pg_default_service_dest`](#pg_default_service_dest)           | [`PGSQL`](#pgsql) |    [`PG_SERVICE`](#pg_service)    | enum        | G/C   | 如果 svc.dest='default'，默认服务指向哪里？postgres 或 pgbouncer，默认指向 pgbouncer              |
| 924 | [`pg_default_services`](#pg_default_services)                   | [`PGSQL`](#pgsql) |    [`PG_SERVICE`](#pg_service)    | service[]   | G/C   | postgres 默认服务定义列表，全局共用。                                                         |
| 931 | [`pg_vip_enabled`](#pg_vip_enabled)                             | [`PGSQL`](#pgsql) |    [`PG_SERVICE`](#pg_service)    | bool        | C     | 是否为 pgsql 主节点启用 L2 VIP？默认不启用                                                    |
| 932 | [`pg_vip_address`](#pg_vip_address)                             | [`PGSQL`](#pgsql) |    [`PG_SERVICE`](#pg_service)    | cidr4       | C     | vip 地址的格式为 <ipv4>/<mask>，启用 vip 时为必选参数                                          |
| 933 | [`pg_vip_interface`](#pg_vip_interface)                         | [`PGSQL`](#pgsql) |    [`PG_SERVICE`](#pg_service)    | string      | C/I   | 监听的 vip 网络接口，默认为 eth0                                                           |
| 934 | [`pg_dns_suffix`](#pg_dns_suffix)                               | [`PGSQL`](#pgsql) |    [`PG_SERVICE`](#pg_service)    | string      | C     | pgsql dns 后缀，默认为空                                                               |
| 935 | [`pg_dns_target`](#pg_dns_target)                               | [`PGSQL`](#pgsql) |    [`PG_SERVICE`](#pg_service)    | enum        | C     | PG DNS 解析到哪里？auto、primary、vip、none 或者特定的 IP 地址                                  |
| 940 | [`pg_exporter_enabled`](#pg_exporter_enabled)                   | [`PGSQL`](#pgsql) |   [`PG_EXPORTER`](#pg_exporter)   | bool        | C     | 在 pgsql 主机上启用 pg_exporter 吗？                                                    |
| 941 | [`pg_exporter_config`](#pg_exporter_config)                     | [`PGSQL`](#pgsql) |   [`PG_EXPORTER`](#pg_exporter)   | string      | C     | pg_exporter 配置文件/模板名称                                                           |
| 942 | [`pg_exporter_cache_ttls`](#pg_exporter_cache_ttls)             | [`PGSQL`](#pgsql) |   [`PG_EXPORTER`](#pg_exporter)   | string      | C     | pg_exporter 收集器阶梯TTL配置，默认为4个由逗号分隔的秒数：'1,10,60,300'                              |
| 943 | [`pg_exporter_port`](#pg_exporter_port)                         | [`PGSQL`](#pgsql) |   [`PG_EXPORTER`](#pg_exporter)   | port        | C     | pg_exporter 监听端口，默认为 9630                                                       |
| 944 | [`pg_exporter_params`](#pg_exporter_params)                     | [`PGSQL`](#pgsql) |   [`PG_EXPORTER`](#pg_exporter)   | string      | C     | pg_exporter dsn 中传入的额外 URL 参数                                                   |
| 945 | [`pg_exporter_url`](#pg_exporter_url)                           | [`PGSQL`](#pgsql) |   [`PG_EXPORTER`](#pg_exporter)   | pgurl       | C     | 如果指定，则覆盖自动生成的 postgres DSN 连接串                                                  |
| 946 | [`pg_exporter_auto_discovery`](#pg_exporter_auto_discovery)     | [`PGSQL`](#pgsql) |   [`PG_EXPORTER`](#pg_exporter)   | bool        | C     | 监控是否启用自动数据库发现？默认启用                                                              |
| 947 | [`pg_exporter_exclude_database`](#pg_exporter_exclude_database) | [`PGSQL`](#pgsql) |   [`PG_EXPORTER`](#pg_exporter)   | string      | C     | 启用自动发现时，排除在外的数据库名称列表，用逗号分隔                                                      |
| 948 | [`pg_exporter_include_database`](#pg_exporter_include_database) | [`PGSQL`](#pgsql) |   [`PG_EXPORTER`](#pg_exporter)   | string      | C     | 启用自动发现时，只监控这个列表中的数据库，名称用逗号分隔                                                    |
| 949 | [`pg_exporter_connect_timeout`](#pg_exporter_connect_timeout)   | [`PGSQL`](#pgsql) |   [`PG_EXPORTER`](#pg_exporter)   | int         | C     | pg_exporter 连接超时，单位毫秒，默认为 200                                                   |
| 950 | [`pg_exporter_options`](#pg_exporter_options)                   | [`PGSQL`](#pgsql) |   [`PG_EXPORTER`](#pg_exporter)   | arg         | C     | pg_exporter 的额外命令行参数选项                                                          |
| 951 | [`pgbouncer_exporter_enabled`](#pgbouncer_exporter_enabled)     | [`PGSQL`](#pgsql) |   [`PG_EXPORTER`](#pg_exporter)   | bool        | C     | 在 pgsql 主机上启用 pgbouncer_exporter 吗？                                             |
| 952 | [`pgbouncer_exporter_port`](#pgbouncer_exporter_port)           | [`PGSQL`](#pgsql) |   [`PG_EXPORTER`](#pg_exporter)   | port        | C     | pgbouncer_exporter 监听端口，默认为 9631                                                |
| 953 | [`pgbouncer_exporter_url`](#pgbouncer_exporter_url)             | [`PGSQL`](#pgsql) |   [`PG_EXPORTER`](#pg_exporter)   | pgurl       | C     | 如果指定，则覆盖自动生成的 pgbouncer dsn 连接串                                                 |
| 954 | [`pgbouncer_exporter_options`](#pgbouncer_exporter_options)     | [`PGSQL`](#pgsql) |   [`PG_EXPORTER`](#pg_exporter)   | arg         | C     | pgbouncer_exporter 的额外命令行参数选项                                                   |



------------------------------------------------------------

# `INFRA`


关于基础设施组件的配置参数：本地软件源，Nginx，DNSMasq，Prometheus，Grafana，Loki，Alertmanager，Pushgateway，Blackbox_exporter 等...



------------------------------

## `META`

这一小节指定了一套 Pigsty 部署的元数据：包括版本号，管理员节点 IP 地址，软件源镜像上游[`区域`](#region) 和下载软件包时使用的 http(s) 代理。

```yaml
version: v2.7.0                   # pigsty 版本号
admin_ip: 10.10.10.10             # 管理节点IP地址
region: default                   # 上游镜像区域：default,china,europe
proxy_env:                        # 全局HTTPS代理，用于下载、安装软件包。
  no_proxy: "localhost,127.0.0.1,10.0.0.0/8,192.168.0.0/16,*.pigsty,*.aliyun.com,mirrors.*,*.myqcloud.com,*.tsinghua.edu.cn"
  # http_proxy:  # set your proxy here: e.g http://user:pass@proxy.xxx.com
  # https_proxy: # set your proxy here: e.g http://user:pass@proxy.xxx.com
  # all_proxy:   # set your proxy here: e.g http://user:pass@proxy.xxx.com
```


### `version`

参数名称： `version`， 类型： `string`， 层次：`G`

Pigsty 版本号字符串，默认值为当前版本：`v2.7.0`。

Pigsty 内部会使用版本号进行功能控制与内容渲染。

Pigsty使用语义化版本号，版本号字符串通常以字符 `v` 开头。







### `admin_ip`

参数名称： `admin_ip`， 类型： `ip`， 层次：`G`

管理节点的 IP 地址，默认为占位符 IP 地址：`10.10.10.10`

由该参数指定的节点将被视为管理节点，通常指向安装 Pigsty 时的第一个节点，即中控节点。

默认值 `10.10.10.10` 是一个占位符，会在 [configure](INSTALL#配置) 过程中被替换为实际的管理节点 IP 地址。

许多参数都会引用此参数，例如：

- [`infra_portal`](#infra_portal)
- [`repo_endpoint`](#repo_endpoint)
- [`repo_upstream`](#repo_upstream)
- [`dns_records`](#dns_records)
- [`node_default_etc_hosts`](#node_default_etc_hosts)
- [`node_etc_hosts`](#node_etc_hosts)

在这些参数中，字符串 `${admin_ip}` 会被替换为 `admin_ip` 的真实取值。使用这种机制，您可以为不同的节点指定不同的中控管理节点。








### `region`

参数名称： `region`， 类型： `enum`， 层次：`G`

上游镜像的区域，默认可选值为：upstream mirror region: default,china,europe，默认为： `default`

如果一个不同于 `default` 的区域被设置，且在 [`repo_upstream`](#repo_upstream) 中有对应的条目，将会使用该条目对应 `baseurl` 代替 `default` 中的 `baseurl`。

例如，如果您的区域被设置为 `china`，那么 Pigsty 会尝试使用中国地区的上游软件镜像站点以加速下载，如果某个上游软件仓库没有对应的中国地区镜像，那么会使用默认的上游镜像站点替代。






### `proxy_env`

参数名称： `proxy_env`， 类型： `dict`， 层次：`G`

下载包时使用的全局代理环境变量，默认值指定了 `no_proxy`，即不使用代理的地址列表：

```yaml
proxy_env:
  no_proxy: "localhost,127.0.0.1,10.0.0.0/8,192.168.0.0/16,*.pigsty,*.aliyun.com,mirrors.aliyuncs.com,mirrors.tuna.tsinghua.edu.cn,mirrors.zju.edu.cn"
  #http_proxy: 'http://username:password@proxy.address.com'
  #https_proxy: 'http://username:password@proxy.address.com'
  #all_proxy: 'http://username:password@proxy.address.com'
```

当您在中国大陆地区从互联网上游安装时，特定的软件包可能会被墙，您可以使用代理来解决这个问题。






------------------------------

## `CA`

Pigsty 使用的自签名 CA 证书，用于支持高级安全特性。

```yaml
ca_method: create                 # CA处理方式：create,recreate,copy，默认为没有则创建
ca_cn: pigsty-ca                  # CA CN名称，固定为 pigsty-ca
cert_validity: 7300d              # 证书有效期，默认为 20 年
```


### `ca_method`

参数名称： `ca_method`， 类型： `enum`， 层次：`G`

CA处理方式：`create` , `recreate` ,`copy`，默认为没有则创建

默认值为： `create`，即如果不存在则创建一个新的 CA 证书。

* `create`：如果 `files/pki/ca` 中不存在现有的CA，则创建一个全新的 CA 公私钥对，否则就直接使用现有的 CA 公私钥对。
* `recreate`：总是创建一个新的 CA 公私钥对，覆盖现有的 CA 公私钥对。注意，这是一个危险的操作。
* `copy`：假设`files/pki/ca` 目录下已经有了一对CA公私钥对，并将 `ca_method` 设置为 `copy`，Pigsty 将会使用现有的 CA 公私钥对。如果不存在则会报错

如果您已经有了一对 CA 公私钥对，可以将其复制到 `files/pki/ca` 目录下，并将 `ca_method` 设置为 `copy`，Pigsty 将会使用现有的 CA 公私钥对，而不是新建一个。






### `ca_cn`

参数名称： `ca_cn`， 类型： `string`， 层次：`G`

CA CN名称，固定为 `pigsty-ca`，不建议修改。

你可以使用以下命令来查看节点上的 Pigsty CA 证书： `openssl x509 -text -in /etc/pki/ca.crt`





### `cert_validity`

参数名称： `cert_validity`， 类型： `interval`， 层次：`G`

签发证书的有效期，默认为 20 年，对绝大多数场景都足够了。默认值为： `7300d`








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

参数名称： `infra_seq`， 类型： `int`， 层次：`I`

基础设施节号，必选身份参数，所以不提供默认值，必须在基础设施节点上显式指定。





### `infra_portal`

参数名称： `infra_portal`， 类型： `dict`， 层次：`G`

通过Nginx门户暴露的基础设施服务列表，默认情况下，Pigsty 会通过 Nginx 对外暴露以下服务：

```yaml
infra_portal:
  home         : { domain: h.pigsty }
  grafana      : { domain: g.pigsty ,endpoint: "${admin_ip}:3000" ,websocket: true }
  prometheus   : { domain: p.pigsty ,endpoint: "${admin_ip}:9090" }
  alertmanager : { domain: a.pigsty ,endpoint: "${admin_ip}:9093" }
  blackbox     : { endpoint: "${admin_ip}:9115" }
  loki         : { endpoint: "${admin_ip}:3100" }
```

每个记录包含三个子部分：`name` 作为键，代表组件名称，外部访问域名和内部TCP端口。 值包含 `domain` 和 `endpoint`，以及其他可选字段：

- 默认记录的 `name` 定义是固定的，其他模块会引用它，所以不要修改默认条目名称。
- `domain` 是用于外部访问此上游服务器的域名。域名将被添加到Nginx SSL证书的 `SAN` 字段中。
- `endpoint` 是一个可以内部访问的TCP端口。如果包含 `${admin_ip}` ，则将在运行时被实际的 [`admin_ip`](#admin_ip) 替换。
- 如果 `websocket` 设置为 `true`，http协议将自动为 Websocket 连接升级。
- 如果给定了 `scheme`（`http` 或 `https`），它将被用作 proxy_pass URL的一部分。





------------------------------

## `REPO`


本节配置是关于本地软件仓库的。 Pigsty 默认会在基础设施节点上启用一个本地软件仓库（APT / YUM）。

在初始化过程中，Pigsty 会从互联网上游仓库（由 [`repo_upstream`](#repo_upstream) 指定）下载所有软件包及其依赖项（由 [`repo_packages`](#repo_packages) 指定）到 [`{{ nginx_home }}`](#nginx_home) / [`{{ repo_name }}`](#repo_name) （默认为 `/www/pigsty`），所有软件及其依赖的总大小约为1GB左右。

创建本地软件仓库时，如果仓库已存在（判断方式：仓库目录目录中有一个名为 `repo_complete` 的标记文件）Pigsty 将认为仓库已经创建完成，跳过软件下载阶段，直接使用构建好的仓库。

如果某些软件包的下载速度太慢，您可以通过使用 [`proxy_env`](#proxy_env) 配置项来设置下载代理来完成首次下载，或直接下载预打包的[离线包](INSTALL#离线软件包)，离线软件包本质上就是在同样操作系统上构建好的本地软件源。


```yaml
repo_enabled: true                # create a yum repo on this infra node?
repo_home: /www                   # repo home dir, `/www` by default
repo_name: pigsty                 # repo name, pigsty by default
repo_endpoint: http://${admin_ip}:80 # access point to this repo by domain or ip:port
repo_remove: true                 # remove existing upstream repo
repo_modules: infra,node,pgsql    # install upstream repo during repo bootstrap
repo_upstream:                    # where to download
  - { name: pigsty-local   ,description: 'Pigsty Local'      ,module: local ,releases: [7,8,9] ,baseurl: { default: 'http://${admin_ip}/pigsty'  }} # used by intranet nodes
  - { name: pigsty-infra   ,description: 'Pigsty INFRA'      ,module: infra ,releases: [7,8,9] ,baseurl: { default: 'https://repo.pigsty.io/rpm/infra/$basearch' ,china: 'https://repo.pigsty.cc/rpm/infra/$basearch' }}
  - { name: pigsty-pgsql   ,description: 'Pigsty PGSQL'      ,module: pgsql ,releases: [7,8,9] ,baseurl: { default: 'https://repo.pigsty.io/rpm/pgsql/el$releasever.$basearch' ,china: 'https://repo.pigsty.cc/rpm/pgsql/el$releasever.$basearch' }}
  - { name: nginx          ,description: 'Nginx Repo'        ,module: infra ,releases: [7,8,9] ,baseurl: { default: 'https://nginx.org/packages/centos/$releasever/$basearch/' }}
  - { name: docker-ce      ,description: 'Docker CE'         ,module: infra ,releases: [7,8,9] ,baseurl: { default: 'https://download.docker.com/linux/centos/$releasever/$basearch/stable'        ,china: 'https://mirrors.aliyun.com/docker-ce/linux/centos/$releasever/$basearch/stable'  ,europe: 'https://mirrors.xtom.de/docker-ce/linux/centos/$releasever/$basearch/stable' }}
  - { name: baseos         ,description: 'EL 8+ BaseOS'      ,module: node  ,releases: [  8,9] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/BaseOS/$basearch/os/'         ,china: 'https://mirrors.aliyun.com/rockylinux/$releasever/BaseOS/$basearch/os/'          ,europe: 'https://mirrors.xtom.de/rocky/$releasever/BaseOS/$basearch/os/'     }}
  - { name: appstream      ,description: 'EL 8+ AppStream'   ,module: node  ,releases: [  8,9] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/AppStream/$basearch/os/'      ,china: 'https://mirrors.aliyun.com/rockylinux/$releasever/AppStream/$basearch/os/'       ,europe: 'https://mirrors.xtom.de/rocky/$releasever/AppStream/$basearch/os/'  }}
  - { name: extras         ,description: 'EL 8+ Extras'      ,module: node  ,releases: [  8,9] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/extras/$basearch/os/'         ,china: 'https://mirrors.aliyun.com/rockylinux/$releasever/extras/$basearch/os/'          ,europe: 'https://mirrors.xtom.de/rocky/$releasever/extras/$basearch/os/'     }}
  - { name: powertools     ,description: 'EL 8 PowerTools'   ,module: node  ,releases: [  8  ] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/PowerTools/$basearch/os/'     ,china: 'https://mirrors.aliyun.com/rockylinux/$releasever/PowerTools/$basearch/os/'      ,europe: 'https://mirrors.xtom.de/rocky/$releasever/PowerTools/$basearch/os/' }}
  - { name: crb            ,description: 'EL 9 CRB'          ,module: node  ,releases: [    9] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/CRB/$basearch/os/'            ,china: 'https://mirrors.aliyun.com/rockylinux/$releasever/CRB/$basearch/os/'             ,europe: 'https://mirrors.xtom.de/rocky/$releasever/CRB/$basearch/os/'        }}
  - { name: epel           ,description: 'EL 8+ EPEL'        ,module: node  ,releases: [  8,9] ,baseurl: { default: 'http://download.fedoraproject.org/pub/epel/$releasever/Everything/$basearch/' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/epel/$releasever/Everything/$basearch/'     ,europe: 'https://mirrors.xtom.de/epel/$releasever/Everything/$basearch/'     }}
  - { name: pgdg-common    ,description: 'PostgreSQL Common' ,module: pgsql ,releases: [7,8,9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/common/redhat/rhel-$releasever-$basearch' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/redhat/rhel-$releasever-$basearch' , europe: 'https://mirrors.xtom.de/postgresql/repos/yum/common/redhat/rhel-$releasever-$basearch' }}
  - { name: pgdg-extras    ,description: 'PostgreSQL Extra'  ,module: pgsql ,releases: [7,8,9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/common/pgdg-rhel$releasever-extras/redhat/rhel-$releasever-$basearch' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/pgdg-rhel$releasever-extras/redhat/rhel-$releasever-$basearch' , europe: 'https://mirrors.xtom.de/postgresql/repos/yum/common/pgdg-rhel$releasever-extras/redhat/rhel-$releasever-$basearch' }}
  - { name: pgdg-el8fix    ,description: 'PostgreSQL EL8FIX' ,module: pgsql ,releases: [  8  ] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/common/pgdg-centos8-sysupdates/redhat/rhel-8-x86_64/' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/pgdg-centos8-sysupdates/redhat/rhel-8-x86_64/' , europe: 'https://mirrors.xtom.de/postgresql/repos/yum/common/pgdg-centos8-sysupdates/redhat/rhel-8-x86_64/' } }
  - { name: pgdg-el9fix    ,description: 'PostgreSQL EL9FIX' ,module: pgsql ,releases: [    9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/common/pgdg-rocky9-sysupdates/redhat/rhel-9-x86_64/'  ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/pgdg-rocky9-sysupdates/redhat/rhel-9-x86_64/' , europe: 'https://mirrors.xtom.de/postgresql/repos/yum/common/pgdg-rocky9-sysupdates/redhat/rhel-9-x86_64/' }}
  - { name: pgdg16         ,description: 'PostgreSQL 16'     ,module: pgsql ,releases: [  8,9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/16/redhat/rhel-$releasever-$basearch' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/16/redhat/rhel-$releasever-$basearch' ,europe: 'https://mirrors.xtom.de/postgresql/repos/yum/16/redhat/rhel-$releasever-$basearch' }}
  - { name: timescaledb    ,description: 'TimescaleDB'       ,module: pgsql ,releases: [7,8,9] ,baseurl: { default: 'https://packagecloud.io/timescale/timescaledb/el/$releasever/$basearch'  }}
  #- { name: pgdg16-nonfree ,description: 'PostgreSQL 16+'    ,module: pgsql ,releases: [  8,9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/non-free/16/redhat/rhel-$releasever-$basearch' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/non-free/16/redhat/rhel-$releasever-$basearch' ,europe: 'https://mirrors.xtom.de/postgresql/repos/yum/non-free/16/redhat/rhel-$releasever-$basearch' }}
repo_packages:
  - ansible python3 python3-pip python3-virtualenv python3-requests python3.11-jmespath python3.11-pip dnf-utils modulemd-tools createrepo_c sshpass                  # Distro & Boot
  - nginx dnsmasq etcd haproxy vip-manager pg_exporter pgbackrest_exporter python3-jmespath python3-cryptography                                                      # Pigsty Addons
  - grafana loki logcli promtail prometheus2 alertmanager pushgateway node_exporter blackbox_exporter nginx_exporter keepalived_exporter                              # Infra Packages
  - lz4 unzip bzip2 zlib yum pv jq git ncdu make patch bash lsof wget uuid tuned nvme-cli numactl grubby sysstat iotop htop rsync tcpdump perf flamegraph             # Node Tools 1
  - netcat socat ftp lrzsz net-tools ipvsadm bind-utils telnet audit ca-certificates openssl openssh-clients readline vim-minimal keepalived chrony                   # Node Tools 2
  - patroni patroni-etcd pgbouncer pgbadger pgbackrest pgloader pg_activity pg_filedump timescaledb-tools scws libduckdb libarrow-s3 pgFormatter # pgxnclient el9     # PGSQL Common Tools
  - postgresql16* pg_repack_16* wal2json_16* passwordcheck_cracklib_16* pglogical_16* pg_cron_16* postgis34_16* timescaledb-2-postgresql-16* pgvector_16* citus_16*   # PGDG 16 Packages
  - pg_net_16* pgsql-http_16* pgsql-gzip_16* vault_16 pgjwt_16 pg_tle_16* pg_roaringbitmap_16* pointcloud_16* zhparser_16* hydra_16* apache-age_16* duckdb_fdw_16* pg_tde_16* md5hash_16* pg_dirtyread_16* plv8_16*
  - pgml_16* pg_graphql_16 wrappers_16 pg_jsonschema_16 pg_search_16* pg_lakehouse_16* pg_analytics_16* pgmq_16 pg_tier_16 pg_later_16 pg_vectorize_16 pg_tiktoken_16 pgdd_16 plprql_16 pgsmcrypto_16 pg_idkit_16 parquet_s3_fdw_16*
  - orafce_16* mongo_fdw_16* tds_fdw_16* mysql_fdw_16 hdfs_fdw_16 sqlite_fdw_16 pgbouncer_fdw_16 powa_16* pg_stat_kcache_16* pg_stat_monitor_16* pg_qualstats_16 pg_track_settings_16 pg_wait_sampling_16 hll_16 pgaudit_16
  - plprofiler_16* plsh_16* pldebugger_16 plpgsql_check_16* pgtt_16 pgq_16* pgsql_tweaks_16 count_distinct_16 hypopg_16 timestamp9_16* semver_16* prefix_16* periods_16 ip4r_16 tdigest_16 pgmp_16 extra_window_functions_16 topn_16
  - pg_background_16 e-maj_16 pg_prioritize_16 pgcryptokey_16 logerrors_16 pg_top_16 pg_comparator_16 pg_ivm_16* pgsodium_16* pgfincore_16* ddlx_16 credcheck_16 safeupdate_16 pg_squeeze_16* pg_fkpart_16 pg_jobmon_16
  - pg_partman_16 pg_permissions_16 pgexportdoc_16 pgimportdoc_16 pg_statement_rollback_16* pg_hint_plan_16* pg_auth_mon_16 pg_checksums_16 pg_failover_slots_16 pg_readonly_16* pg_uuidv7_16* set_user_16* rum_16
  - system_stats_16* pg_store_plans_16* pg_catcheck_16 pgcopydb pg_profile_16 # mysqlcompat_16 multicorn2_16* plproxy_16 geoip_16 postgresql-unit_16 # not available for PG 16 yet
  - redis_exporter mysqld_exporter mongodb_exporter docker-ce docker-compose-plugin redis minio mcli ferretdb duckdb sealos  # Miscellaneous Packages
repo_url_packages:
  - https://repo.pigsty.cc/etc/pev.html
  - https://repo.pigsty.cc/etc/chart.tgz
  - https://repo.pigsty.cc/etc/plugins.tgz
```




### `repo_enabled`

参数名称： `repo_enabled`， 类型： `bool`， 层次：`G/I`

是否在当前的基础设施节点上启用本地软件源？默认为： `true`，即所有 Infra 节点都会设置一个本地软件仓库。

如果您有多个基础设施节点，可以只保留 1 ～ 2 个节点作为软件仓库，其他节点可以通过设置此参数为 `false` 来避免重复软件下载构建。





### `repo_home`

参数名称： `repo_home`， 类型： `path`， 层次：`G`

本地软件仓库的家目录，默认为 Nginx 的根目录，也就是： `/www`，我们不建议您修改此目录。如果修改，需要和 [`nginx_home`](#nginx_home)






### `repo_name`

参数名称： `repo_name`， 类型： `string`， 层次：`G`

本地仓库名称，默认为 `pigsty`，更改此仓库的名称是不明智的行为。






### `repo_endpoint`

参数名称： `repo_endpoint`， 类型： `url`， 层次：`G`

其他节点访问此仓库时使用的端点，默认值为：`http://${admin_ip}:80`。

Pigsty 默认会在基础设施节点 80/443 端口启动 Nginx，对外提供本地软件源（静态文件）服务。

如果您修改了 [`nginx_port`](#nginx_port) 与 [`nginx_ssl_port`](#nginx_ssl_port)，或者使用了不同于中控节点的基础设施节点，请相应调整此参数。

如果您使用了域名，可以在 [`node_default_etc_hosts`](#node_default_etc_hosts)、[`node_etc_hosts`](#node_etc_hosts)、或者 [`dns_records`](#dns_records) 中添加解析。





### `repo_remove`

参数名称： `repo_remove`， 类型： `bool`， 层次：`G/A`

在构建本地软件源时，是否移除现有的上游仓库定义？默认值： `true`。

当启用此参数时，`/etc/yum.repos.d` 中所有已有仓库文件会被移动备份至`/etc/yum.repos.d/backup`，在 Debian 系上是移除 `/etc/apt/sources.list` 和 `/etc/apt/sources.list.d`，将文件备份至 `/etc/apt/backup` 中。

因为操作系统已有的源内容不可控，使用 Pigsty 验证过的上游软件源可以提高从互联网下载软件包的成功率与速度。

但在一些特定情况下（例如您的操作系统是某种 EL/Deb 兼容版，许多软件包使用了自己的私有源），您可能需要保留现有的上游仓库定义，此时可以将此参数设置为 `false`。







### `repo_modules`

参数名称： `repo_modules`， 类型： `string`， 层次：`G/A`

哪些上游仓库模块会被添加到本地软件源中，默认值： `infra,node,pgsql`

当 Pigsty 尝试添加上游仓库时，会根据此参数的值来过滤 [`repo_upstream`](#repo_upstream) 中的条目，只有 `module` 字段与此参数值匹配的条目才会被添加到本地软件源中。

对于 Ubuntu/Debian 用户来说，如果希望使用 Rediscover 相关功能，此参数应当显式配置为 `infra,node,pgsql,redis` 以启用 Redis 上游源。






### `repo_upstream`

参数名称： `repo_upstream`， 类型： `upstream[]`， 层次：`G`

从哪里下载上游软件包？默认值是针对 EL 7/8/9 及其兼容操作系统发行版所准备的：

```yaml
repo_upstream:                    # where to download
  - { name: pigsty-local   ,description: 'Pigsty Local'      ,module: local ,releases: [7,8,9] ,baseurl: { default: 'http://${admin_ip}/pigsty'  }} # used by intranet nodes
  - { name: pigsty-infra   ,description: 'Pigsty INFRA'      ,module: infra ,releases: [7,8,9] ,baseurl: { default: 'https://repo.pigsty.io/rpm/infra/$basearch' ,china: 'https://repo.pigsty.cc/rpm/infra/$basearch' }}
  - { name: pigsty-pgsql   ,description: 'Pigsty PGSQL'      ,module: pgsql ,releases: [7,8,9] ,baseurl: { default: 'https://repo.pigsty.io/rpm/pgsql/el$releasever.$basearch' ,china: 'https://repo.pigsty.cc/rpm/pgsql/el$releasever.$basearch' }}
  - { name: nginx          ,description: 'Nginx Repo'        ,module: infra ,releases: [7,8,9] ,baseurl: { default: 'https://nginx.org/packages/centos/$releasever/$basearch/' }}
  - { name: docker-ce      ,description: 'Docker CE'         ,module: infra ,releases: [7,8,9] ,baseurl: { default: 'https://download.docker.com/linux/centos/$releasever/$basearch/stable'        ,china: 'https://mirrors.aliyun.com/docker-ce/linux/centos/$releasever/$basearch/stable'  ,europe: 'https://mirrors.xtom.de/docker-ce/linux/centos/$releasever/$basearch/stable' }}
  - { name: baseos         ,description: 'EL 8+ BaseOS'      ,module: node  ,releases: [  8,9] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/BaseOS/$basearch/os/'         ,china: 'https://mirrors.aliyun.com/rockylinux/$releasever/BaseOS/$basearch/os/'          ,europe: 'https://mirrors.xtom.de/rocky/$releasever/BaseOS/$basearch/os/'     }}
  - { name: appstream      ,description: 'EL 8+ AppStream'   ,module: node  ,releases: [  8,9] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/AppStream/$basearch/os/'      ,china: 'https://mirrors.aliyun.com/rockylinux/$releasever/AppStream/$basearch/os/'       ,europe: 'https://mirrors.xtom.de/rocky/$releasever/AppStream/$basearch/os/'  }}
  - { name: extras         ,description: 'EL 8+ Extras'      ,module: node  ,releases: [  8,9] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/extras/$basearch/os/'         ,china: 'https://mirrors.aliyun.com/rockylinux/$releasever/extras/$basearch/os/'          ,europe: 'https://mirrors.xtom.de/rocky/$releasever/extras/$basearch/os/'     }}
  - { name: powertools     ,description: 'EL 8 PowerTools'   ,module: node  ,releases: [  8  ] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/PowerTools/$basearch/os/'     ,china: 'https://mirrors.aliyun.com/rockylinux/$releasever/PowerTools/$basearch/os/'      ,europe: 'https://mirrors.xtom.de/rocky/$releasever/PowerTools/$basearch/os/' }}
  - { name: crb            ,description: 'EL 9 CRB'          ,module: node  ,releases: [    9] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/CRB/$basearch/os/'            ,china: 'https://mirrors.aliyun.com/rockylinux/$releasever/CRB/$basearch/os/'             ,europe: 'https://mirrors.xtom.de/rocky/$releasever/CRB/$basearch/os/'        }}
  - { name: epel           ,description: 'EL 8+ EPEL'        ,module: node  ,releases: [  8,9] ,baseurl: { default: 'http://download.fedoraproject.org/pub/epel/$releasever/Everything/$basearch/' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/epel/$releasever/Everything/$basearch/'     ,europe: 'https://mirrors.xtom.de/epel/$releasever/Everything/$basearch/'     }}
  - { name: pgdg-common    ,description: 'PostgreSQL Common' ,module: pgsql ,releases: [7,8,9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/common/redhat/rhel-$releasever-$basearch' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/redhat/rhel-$releasever-$basearch' , europe: 'https://mirrors.xtom.de/postgresql/repos/yum/common/redhat/rhel-$releasever-$basearch' }}
  - { name: pgdg-extras    ,description: 'PostgreSQL Extra'  ,module: pgsql ,releases: [7,8,9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/common/pgdg-rhel$releasever-extras/redhat/rhel-$releasever-$basearch' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/pgdg-rhel$releasever-extras/redhat/rhel-$releasever-$basearch' , europe: 'https://mirrors.xtom.de/postgresql/repos/yum/common/pgdg-rhel$releasever-extras/redhat/rhel-$releasever-$basearch' }}
  - { name: pgdg-el8fix    ,description: 'PostgreSQL EL8FIX' ,module: pgsql ,releases: [  8  ] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/common/pgdg-centos8-sysupdates/redhat/rhel-8-x86_64/' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/pgdg-centos8-sysupdates/redhat/rhel-8-x86_64/' , europe: 'https://mirrors.xtom.de/postgresql/repos/yum/common/pgdg-centos8-sysupdates/redhat/rhel-8-x86_64/' } }
  - { name: pgdg-el9fix    ,description: 'PostgreSQL EL9FIX' ,module: pgsql ,releases: [    9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/common/pgdg-rocky9-sysupdates/redhat/rhel-9-x86_64/'  ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/pgdg-rocky9-sysupdates/redhat/rhel-9-x86_64/' , europe: 'https://mirrors.xtom.de/postgresql/repos/yum/common/pgdg-rocky9-sysupdates/redhat/rhel-9-x86_64/' }}
  - { name: pgdg16         ,description: 'PostgreSQL 16'     ,module: pgsql ,releases: [  8,9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/16/redhat/rhel-$releasever-$basearch' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/16/redhat/rhel-$releasever-$basearch' ,europe: 'https://mirrors.xtom.de/postgresql/repos/yum/16/redhat/rhel-$releasever-$basearch' }}
  - { name: timescaledb    ,description: 'TimescaleDB'       ,module: pgsql ,releases: [7,8,9] ,baseurl: { default: 'https://packagecloud.io/timescale/timescaledb/el/$releasever/$basearch'  }}
  #- { name: pgdg16-nonfree ,description: 'PostgreSQL 16+'    ,module: pgsql ,releases: [  8,9] ,baseurl: { default: 'https://download.postgresql.org/pub/repos/yum/non-free/16/redhat/rhel-$releasever-$basearch' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/non-free/16/redhat/rhel-$releasever-$basearch' ,europe: 'https://mirrors.xtom.de/postgresql/repos/yum/non-free/16/redhat/rhel-$releasever-$basearch' }}
```

对于 Debian (11,12) 或 Ubuntu (20.04,22.04)，您需要在配置文件的合适位置（全局/集群/实例）中 **显式** 指定此参数：

```yaml
repo_upstream:                    # where to download #
  - { name: pigsty-local  ,description: 'Pigsty Local'     ,module: local ,releases: [11,12,20,22] ,baseurl: { default: 'http://${admin_ip}/pigsty ./' }}
  - { name: pigsty-pgsql  ,description: 'Pigsty PgSQL'     ,module: pgsql ,releases: [11,12,20,22] ,baseurl: { default: 'https://repo.pigsty.io/deb/pgsql/${distro_codename}.amd64/ ./', china: 'https://repo.pigsty.cc/deb/pgsql/${distro_codename}.amd64/ ./' }}
  - { name: pigsty-infra  ,description: 'Pigsty Infra'     ,module: infra ,releases: [11,12,20,22] ,baseurl: { default: 'https://repo.pigsty.io/deb/infra/amd64/ ./', china: 'https://repo.pigsty.cc/deb/infra/amd64/ ./' }}
  - { name: nginx         ,description: 'Nginx'            ,module: infra ,releases: [11,12,20,22] ,baseurl: { default: 'http://nginx.org/packages/mainline/${distro_name} ${distro_codename} nginx' }}
  - { name: base          ,description: 'Debian Basic'     ,module: node  ,releases: [11,12      ] ,baseurl: { default: 'http://deb.debian.org/debian/ ${distro_codename} main non-free-firmware'         ,china: 'https://mirrors.aliyun.com/debian/ ${distro_codename} main restricted universe multiverse' }}
  - { name: updates       ,description: 'Debian Updates'   ,module: node  ,releases: [11,12      ] ,baseurl: { default: 'http://deb.debian.org/debian/ ${distro_codename}-updates main non-free-firmware' ,china: 'https://mirrors.aliyun.com/debian/ ${distro_codename}-updates main restricted universe multiverse' }}
  - { name: security      ,description: 'Debian Security'  ,module: node  ,releases: [11,12      ] ,baseurl: { default: 'http://security.debian.org/debian-security ${distro_codename}-security main non-free-firmware' }}
  - { name: base          ,description: 'Ubuntu Basic'     ,module: node  ,releases: [      20,22] ,baseurl: { default: 'https://mirrors.edge.kernel.org/${distro_name}/ ${distro_codename}   main universe multiverse restricted' ,china: 'https://mirrors.aliyun.com/${distro_name}/ ${distro_codename}   main restricted universe multiverse' }}
  - { name: updates       ,description: 'Ubuntu Updates'   ,module: node  ,releases: [      20,22] ,baseurl: { default: 'https://mirrors.edge.kernel.org/ubuntu/ ${distro_codename}-backports main restricted universe multiverse' ,china: 'https://mirrors.aliyun.com/ubuntu/ ${distro_codename}-updates   main restricted universe multiverse' }}
  - { name: backports     ,description: 'Ubuntu Backports' ,module: node  ,releases: [      20,22] ,baseurl: { default: 'https://mirrors.edge.kernel.org/ubuntu/ ${distro_codename}-security  main restricted universe multiverse' ,china: 'https://mirrors.aliyun.com/ubuntu/ ${distro_codename}-backports main restricted universe multiverse' }}
  - { name: security      ,description: 'Ubuntu Security'  ,module: node  ,releases: [      20,22] ,baseurl: { default: 'https://mirrors.edge.kernel.org/ubuntu/ ${distro_codename}-updates   main restricted universe multiverse' ,china: 'https://mirrors.aliyun.com/ubuntu/ ${distro_codename}-security  main restricted universe multiverse' }}
  - { name: pgdg          ,description: 'PGDG'             ,module: pgsql ,releases: [11,12,20,22] ,baseurl: { default: 'http://apt.postgresql.org/pub/repos/apt/ ${distro_codename}-pgdg main' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/apt/ ${distro_codename}-pgdg main' }}
  - { name: citus         ,description: 'Citus'            ,module: pgsql ,releases: [11,12,20,22] ,baseurl: { default: 'https://packagecloud.io/citusdata/community/${distro_name}/ ${distro_codename} main'   }}
  - { name: timescaledb   ,description: 'Timescaledb'      ,module: pgsql ,releases: [11,12,20,22] ,baseurl: { default: 'https://packagecloud.io/timescale/timescaledb/${distro_name}/ ${distro_codename} main' }}
  - { name: redis         ,description: 'Redis'            ,module: redis ,releases: [11,12,20,22] ,baseurl: { default: 'https://packages.redis.io/deb ${distro_codename} main' }}
  - { name: docker-ce     ,description: 'Docker'           ,module: infra ,releases: [11,12,20,22] ,baseurl: { default: 'https://download.docker.com/linux/${distro_name} ${distro_codename} stable' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux//${distro_name} ${distro_codename} stable' }}
```

Pigsty 构建配置模板 [`build.yml`](https://github.com/Vonng/pigsty/blob/master/files/pigsty/build.yml) 提供了不同操作系统下的权威默认值。






### `repo_packages`

参数名称： `repo_packages`， 类型： `string[]`， 层次：`G`

构建本地软件源时，从上游下载哪些离线软件包？默认值是针对 EL 7/8/9 及其兼容操作系统发行版所准备的：

```yaml
repo_packages:
  - ansible python3 python3-pip python3-virtualenv python3-requests python3.11-jmespath python3.11-pip dnf-utils modulemd-tools createrepo_c sshpass                  # Distro & Boot
  - nginx dnsmasq etcd haproxy vip-manager pg_exporter pgbackrest_exporter python3-jmespath python3-cryptography                                                      # Pigsty Addons
  - grafana loki logcli promtail prometheus2 alertmanager pushgateway node_exporter blackbox_exporter nginx_exporter keepalived_exporter                              # Infra Packages
  - redis_exporter docker-ce docker-compose-plugin redis minio mcli ferretdb duckdb                                                                                   # Miscellaneous
  - lz4 unzip bzip2 zlib yum pv jq git ncdu make patch bash lsof wget uuid tuned nvme-cli numactl grubby sysstat iotop htop rsync tcpdump perf flamegraph             # Node Packages 1
  - netcat socat ftp lrzsz net-tools ipvsadm bind-utils telnet audit ca-certificates openssl openssh-clients readline vim-minimal keepalived chrony                   # Node Packages 2
  - patroni patroni-etcd pgbouncer pgbadger pgbackrest pgloader pg_activity pg_filedump timescaledb-tools scws libduckdb libarrow-s3 pgFormatter luapgsql pgcopydb    # PGDG Common
  - postgresql16* pg_repack_16* wal2json_16* passwordcheck_cracklib_16* pglogical_16* pg_cron_16* postgis34_16* timescaledb-2-postgresql-16* pgvector_16* citus_16*   # PGDG 16 Packages
  - vault_16* pgjwt_16* pg_roaringbitmap_16* zhparser_16* hydra_16* apache-age_16* duckdb_fdw_16* pg_tde_16* md5hash_16* pg_dirtyread_16* plv8_16* parquet_s3_fdw_16* # Pigsty Extension (C)
  - pgml_16 pg_graphql_16 wrappers_16 pg_jsonschema_16 pg_search_16 pg_lakehouse_16 pg_analytics_16 pgmq_16 pg_tier_16 pg_later_16 pg_vectorize_16 pg_tiktoken_16 pgdd_16 plprql_16 pgsmcrypto_16 pg_idkit_16
  - bgw_replstatus_16* count_distinct_16* credcheck_16* ddlx_16* e-maj_16* extra_window_functions_16* h3-pg_16* hdfs_fdw_16* hll_16* hypopg_16* ip4r_16* jsquery_16*  # PGDG Extensions
  - logerrors_16* login_hook_16* mongo_fdw_16* mysql_fdw_16* ogr_fdw_16* orafce_16* passwordcheck_cracklib_16* periods_16* pg_auth_mon_16* pg_auto_failover_16* pg_background_16* pgfincore_16* pgimportdoc_16* pgl_ddl_deploy_16* pgmemcache_16* pgmeminfo_16* pgmp_16* pgq_16* pgrouting_16* pgsodium_16* pgsql_gzip_16* pgsql_http_16* pgsql_tweaks_16*
  - pgtt_16* pguint_16* pg_bigm_16* pg_bulkload_16* pg_catcheck_16* pg_checksums_16* pg_comparator_16* pg_dbms_lock_16* pg_dbms_metadata_16* pg_extra_time_16* pg_fact_loader_16* pg_failover_slots_16* pg_filedump_16* pg_fkpart_16* pg_hint_plan_16* pg_ivm_16* pg_jobmon_16* pg_net_16* pg_partman_16* pg_permissions_16* pg_prioritize_16* pg_profile_16*
  - pg_qualstats_16* pg_readonly_16* pg_show_plans_16* pg_squeeze_16* pg_stat_kcache_16* pg_stat_monitor_16* pg_statement_rollback_16* pg_statviz_extension_16 pg_store_plans_16* pg_tle_16* pg_top_16* pg_track_settings_16* pg_uuidv7_16* pg_wait_sampling_16* pgagent_16* pgaudit_16* pgauditlogtofile_16* pgbouncer_fdw_16* pgcryptokey_16* pgexportdoc_16*
  - pldebugger_16* pllua_16* plpgsql_check_16* plprofiler_16* plsh_16* pointcloud_16* postgres-decoderbufs_16* postgresql_anonymizer_16* postgresql_faker_16* powa-archivist_16* powa_16* prefix_16* rum_16 safeupdate_16* semver_16* set_user_16* sqlite_fdw_16* system_stats_16* tdigest_16* tds_fdw_16* temporal_tables_16* timestamp9_16* topn_16*
```

不同的 EL 大版本所包含的软件包会有微量差别，在当前版本中：

* EL7:  `python36-requests python36-idna yum-utils yum-utils`，以及 `postgis33*`
* EL8:  `python3-jmespath python3.11-jmespath dnf-utils modulemd-tools`，以及 `postgis34*`
* EL9:  与 EL8 相同，唯独缺少 `pgxnclient` 软件包

对于 Debian 系操作系统，合理默认值有所不同：

```yaml
repo_packages:                    # which packages to be included
  - ansible python3 python3-pip python3-venv python3-jmespath dpkg-dev sshpass                                                                        # Distro & Boot
  - nginx dnsmasq etcd haproxy vip-manager pg-exporter pgbackrest-exporter                                                                            # Pigsty Addon
  - grafana loki logcli promtail prometheus2 alertmanager pushgateway node-exporter blackbox-exporter nginx-exporter keepalived-exporter              # Infra Packages
  - redis-exporter docker-ce docker-compose-plugin redis minio mcli ferretdb duckdb                                                                   # Miscellaneous
  - lz4 unzip bzip2 zlib1g pv jq git ncdu make patch bash lsof wget uuid tuned nvme-cli numactl sysstat iotop htop rsync tcpdump linux-tools-generic  # Node Tools 1
  - netcat socat ftp lrzsz net-tools ipvsadm dnsutils telnet ca-certificates openssl openssh-client libreadline-dev vim-tiny keepalived acl chrony    # Node Tools 2
  - patroni pgbouncer pgbackrest pgbadger pgloader pg-activity pgloader pg-activity postgresql-filedump pgxnclient pgformatter                        # PGSQL Packages
  - postgresql-client-16 postgresql-16 postgresql-server-dev-16 postgresql-plpython3-16 postgresql-plperl-16 postgresql-pltcl-16 postgresql-16-wal2json postgresql-16-repack
  - postgresql-16-postgis-3 postgresql-16-postgis-3-scripts postgresql-16-citus-12.1 postgresql-16-pgvector timescaledb-2-postgresql-16               # PGDG 16 Extensions
  - postgresql-16-age postgresql-16-asn1oid postgresql-16-auto-failover postgresql-16-bgw-replstatus postgresql-16-pg-catcheck postgresql-16-pg-checksums postgresql-16-credcheck postgresql-16-cron postgresql-16-debversion postgresql-16-decoderbufs postgresql-16-dirtyread postgresql-16-extra-window-functions postgresql-16-first-last-agg postgresql-16-hll postgresql-16-hypopg postgresql-16-icu-ext postgresql-16-ip4r postgresql-16-jsquery postgresql-16-londiste-sql
  - postgresql-16-mimeo postgresql-16-mysql-fdw postgresql-16-numeral postgresql-16-ogr-fdw postgresql-16-omnidb postgresql-16-oracle-fdw postgresql-16-orafce postgresql-16-partman postgresql-16-periods postgresql-16-pgaudit postgresql-16-pgauditlogtofile postgresql-16-pgextwlist postgresql-16-pg-fact-loader postgresql-16-pg-failover-slots postgresql-16-pgfincore postgresql-16-pgl-ddl-deploy postgresql-16-pglogical postgresql-16-pglogical-ticker
  - postgresql-16-pgmemcache postgresql-16-pgmp postgresql-16-pgpcre postgresql-16-pgq3 postgresql-16-pgq-node postgresql-16-pg-qualstats postgresql-16-pgsphere postgresql-16-pg-stat-kcache postgresql-16-pgtap postgresql-16-pg-track-settings postgresql-16-pg-wait-sampling postgresql-16-pldebugger postgresql-16-pllua postgresql-16-plpgsql-check postgresql-16-plprofiler postgresql-16-plproxy postgresql-16-plsh postgresql-16-pointcloud
  - postgresql-16-powa postgresql-16-prefix postgresql-16-preprepare postgresql-16-prioritize postgresql-16-q3c postgresql-16-rational postgresql-16-rum postgresql-16-semver postgresql-16-set-user postgresql-16-show-plans postgresql-16-similarity postgresql-16-snakeoil postgresql-16-squeeze postgresql-16-tablelog postgresql-16-tdigest postgresql-16-tds-fdw postgresql-16-toastinfo postgresql-16-topn postgresql-16-unit
  - postgresql-16-pg-hint-plan postgresql-16-mobilitydb postgresql-16-roaringbitmap postgresql-16-pg-rrule postgresql-16-http postgresql-16-pgfaceting postgresql-16-pgrouting postgresql-16-pgrouting-scripts postgresql-16-h3 postgresql-16-rdkit
  - pg-graphql pg-net pg-jsonschema wrappers pg-analytics pg-search pg-lakehouse pgdd-jammy-pg16
```

其中也有少量区别：

- Ubuntu 22.04：`postgresql-pgml-15`, `postgresql-15-rdkit`, `linux-tools-generic`(perf), `netcat`, `ftp`
- Ubuntu 20.04：`postgresql-15-rdkit` 不可用， `postgresql-15-postgis-3` 必须在线安装（不能使用本地源）
- Debian 12：`netcat` -> `netcat-openbsd`，`ftp` -> `tnftp`，`linux-tools-generic`（perf） 的包名是 `linux-perf`，其余与 Ubuntu 一致
- Debian 11：与 Debian 12 一样，除了 `postgresql-15-rdkit` 不可用。

每一行都是 **由空格分隔** 的软件包列表字符串，这些软件包会使用 `repotrack` 或 `apt download` 下载本地以及所有依赖。

Pigsty 构建配置模板 [`build.yml`](https://github.com/Vonng/pigsty/blob/master/files/pigsty/build.yml) 提供了不同操作系统下的权威默认值。






### `repo_url_packages`

参数名称： `repo_url_packages`， 类型： `string[]`， 层次：`G`

直接使用 URL 从互联网上下载的软件包，默认为：

```yaml
repo_url_packages:
  - https://repo.pigsty.cc/etc/pev.html     # postgres 执行计划可视化
  - https://repo.pigsty.cc/etc/chart.tgz    # grafana 额外地图数据 GeoJson
  - https://repo.pigsty.cc/etc/plugins.tgz  # grafana 插件，可选
```

这几个都是可选的加装项：例如，如果不下载 `plugins.tgz`，Grafana 初始化的时候就会直接从互联网上下载插件，这样会导致初始化时间变长（而且有可能被墙），但是不会影响最终结果。





------------------------------

## `INFRA_PACKAGE`

这些软件包只会在 INFRA 节点上安装，包括普通的 RPM/DEB 软件包，以及 PIP 软件包。


### `infra_packages`

参数名称： `infra_packages`， 类型： `string[]`， 层次：`G`

将要在 Infra 节点上安装的软件包列表，默认值（EL系操作系统）为：

```yaml
infra_packages:                   # packages to be installed on infra nodes
  - grafana,loki,logcli,promtail,prometheus2,alertmanager,pushgateway
  - node_exporter,blackbox_exporter,nginx_exporter,pg_exporter
  - nginx,dnsmasq,ansible,etcd,python3-requests,redis,mcli
```

对于 Debian/Ubuntu 来说，默认的 Infra 软件包列表为：

```yaml
infra_packages:                   # packages to be installed on infra nodes
  - grafana,loki,logcli,promtail,prometheus2,alertmanager,pushgateway,blackbox-exporter
  - node-exporter,blackbox-exporter,nginx-exporter,redis-exporter,pg-exporter
  - nginx,dnsmasq,ansible,etcd,python3-requests,redis,mcli
```




### `infra_packages_pip`

参数名称： `infra_packages_pip`， 类型： `string`， 层次：`G`

Infra 节点上要使用 `pip` 额外安装的软件包，包名使用逗号分隔，默认值是空字符串，即不安装任何额外的 python 包。








------------------------------

## `NGINX`

Pigsty 会通过 Nginx 代理所有的 Web 服务访问：Home Page、Grafana、Prometheus、AlertManager 等等。
以及其他可选的工具，如 PGWe、Jupyter Lab、Pgadmin、Bytebase 等等，还有一些静态资源和报告，如 `pev`、`schemaspy` 和 `pgbadger`。

最重要的是，Nginx 还作为本地软件仓库（Yum/Apt）的 Web 服务器，用于存储和分发 Pigsty 的软件包。

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

参数名称： `nginx_enabled`， 类型： `bool`， 层次：`G/I`

是否在当前的 Infra 节点上启用 Nginx？默认值为： `true`。





### `nginx_exporter_enabled`

参数名称： `nginx_exporter_enabled`， 类型： `bool`， 层次：`G/I`

在此基础设施节点上启用 nginx_exporter ？默认值为： `true`。

如果禁用此选项，还会一并禁用 `/nginx` 健康检查 stub，当您安装使用的 Nginx 版本不支持此功能是可以考虑关闭此开关






### `nginx_sslmode`

参数名称： `nginx_sslmode`， 类型： `enum`， 层次：`G`

Nginx 的 SSL工作模式？有三种选择：`disable` , `enable` , `enforce`， 默认值为 `enable`，即启用 SSL，但不强制使用。

* `disable`：只监听 [`nginx_port`](#nginx_port) 指定的端口服务 HTTP 请求。
* `enable`：同时会监听 [`nginx_ssl_port`](#nginx_ssl_port) 指定的端口服务 HTTPS 请求。
* `enforce`：所有链接都会被渲染为默认使用 `https://`





### `nginx_home`

参数名称： `nginx_home`， 类型： `path`， 层次：`G`

Nginx服务器静态文件目录，默认为： `/www`

Nginx服务器的根目录，包含静态资源和软件仓库文件。最好不要随意修改此参数，修改时需要与 [`repo_home`](#repo_home) 参数保持一致。





### `nginx_port`

参数名称： `nginx_port`， 类型： `port`， 层次：`G`

Nginx 默认监听的端口（提供HTTP服务），默认为 `80` 端口，最好不要修改这个参数。

当您的服务器 80 端口被占用时，可以考虑修改此参数，但是需要同时修改 [`repo_endpoint`](#repo_endpoint) ，以及 [`node_repo_local_urls`](#node_repo_local_urls) 所使用的端口并与这里保持一致。






### `nginx_ssl_port`

参数名称： `nginx_ssl_port`， 类型： `port`， 层次：`G`

Nginx SSL 默认监听的端口，默认为 `443`，最好不要修改这个参数。





### `nginx_navbar`

参数名称： `nginx_navbar`， 类型： `index[]`， 层次：`G`

Nginx 首页上的导航栏内容，默认值：

```yaml
nginx_navbar:                     # nginx index page navigation links
  - { name: CA Cert ,url: '/ca.crt'   ,desc: 'pigsty self-signed ca.crt'   }
  - { name: Package ,url: '/pigsty'   ,desc: 'local yum repo packages'     }
  - { name: PG Logs ,url: '/logs'     ,desc: 'postgres raw csv logs'       }
  - { name: Reports ,url: '/report'   ,desc: 'pgbadger summary report'     }
  - { name: Explain ,url: '/pigsty/pev.html' ,desc: 'postgres explain visualizer' }
```

每一条记录都会被渲染为一个导航链接，链接到 Pigsty 首页的 App 下拉菜单，所有的 App 都是可选的，默认挂载在 Pigsty 默认服务器下的 `http://pigsty/` 。

`url` 参数指定了 App 的 URL PATH，但是如果 URL 中包含 `${grafana}` 字符串，它会被自动替换为 [`infra_portal`](#infra_portal) 中定义的 Grafana 域名。

所以您可以将一些使用 Grafana 的数据应用挂载到 Pigsty 的首页导航栏中。







------------------------------

## `DNS`

Pigsty 默认会在 Infra 节点上启用 DNSMASQ 服务，用于解析一些辅助域名，例如 `h.pigsty` `a.pigsty` `p.pigsty` `g.pigsty` 等等，以及可选 MinIO 的 `sss.pigsty`。

解析记录会记录在 Infra 节点的 `/etc/hosts.d/default` 文件中。 要使用这个 DNS 服务器，您必须将 `nameserver <ip>` 添加到 `/etc/resolv` 中，[`node_dns_servers`](#node_dns_servers) 参数可以解决这个问题。


```yaml
dns_enabled: true                 # setup dnsmasq on this infra node?
dns_port: 53                      # dns server listen port, 53 by default
dns_records:                      # dynamic dns records resolved by dnsmasq
  - "${admin_ip} h.pigsty a.pigsty p.pigsty g.pigsty"
  - "${admin_ip} api.pigsty adm.pigsty cli.pigsty ddl.pigsty lab.pigsty git.pigsty sss.pigsty wiki.pigsty"
```



### `dns_enabled`

参数名称： `dns_enabled`， 类型： `bool`， 层次：`G/I`

是否在这个 Infra 节点上启用 DNSMASQ 服务？默认值为： `true`。

如果你不想使用默认的 DNS 服务器，（比如你已经有了外部的DNS服务器，或者您的供应商不允许您使用 DNS 服务器）可以将此值设置为 `false` 来禁用它。
并使用 [`node_default_etc_hosts`](#node_default_etc_hosts) 和 [`node_etc_hosts`](#node_etc_hosts) 静态解析记录代替。




### `dns_port`

参数名称： `dns_port`， 类型： `port`， 层次：`G`

DNSMASQ 的默认监听端口，默认是 `53`，不建议修改 DNS 服务默认端口。





### `dns_records`

参数名称： `dns_records`， 类型： `string[]`， 层次：`G`

由 dnsmasq 负责解析的动态 DNS 记录，一般用于将一些辅助域名解析到本地，例如 `h.pigsty` `a.pigsty` `p.pigsty` `g.pigsty` 等等。这些记录会被写入到基础设置节点的 `/etc/hosts.d/default` 文件中。


```yaml
dns_records:                      # dynamic dns records resolved by dnsmasq
  - "${admin_ip} h.pigsty a.pigsty p.pigsty g.pigsty"
  - "${admin_ip} api.pigsty adm.pigsty cli.pigsty ddl.pigsty lab.pigsty git.pigsty sss.pigsty wiki.pigsty"
```






------------------------------

## `PROMETHEUS`

Prometheus 被用作时序数据库，用于存储和分析监控指标数据，进行指标预计算，评估告警规则。

```yaml
prometheus_enabled: true          # enable prometheus on this infra node?
prometheus_clean: true            # clean prometheus data during init?
prometheus_data: /data/prometheus # prometheus data dir, `/data/prometheus` by default
prometheus_sd_dir: /etc/prometheus/targets # prometheus file service discovery directory
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

参数名称： `prometheus_enabled`， 类型： `bool`， 层次：`G/I`

是否在当前 Infra 节点上启用 Prometheus？ 默认值为 `true`，即所有基础设施节点默认都会安装启用 Prometheus。

例如，如果您有多个元节点，默认情况下，Pigsty会在所有元节点上部署Prometheus。如果您想一台用于Prometheus监控指标收集，一台用于Loki日志收集，则可以在其他元节点的实例层次上将此参数设置为`false`。





### `prometheus_clean`

参数名称： `prometheus_clean`， 类型： `bool`， 层次：`G/A`

是否在执行 Prometheus 初始化的时候清除现有 Prometheus 数据？默认值为 `true`。







### `prometheus_data`

参数名称： `prometheus_data`， 类型： `path`， 层次：`G`

Prometheus数据库目录, 默认位置为 `/data/prometheus`。





### `prometheus_sd_dir`

参数名称： `prometheus_sd_dir`， 类型： `path`， 层次：`G`

Prometheus 静态文件服务发现的对象存储目录，默认值为 `/etc/prometheus/targets`。







### `prometheus_sd_interval`

参数名称： `prometheus_sd_interval`， 类型： `interval`， 层次：`G`

Prometheus 静态文件服务发现的刷新周期，默认值为 `5s`。

这意味着 Prometheus 每隔这样长的时间就会重新扫描一次 [`prometheus_sd_dir`](#prometheus_sd_dir) （默认为：`/etc/prometheus/targets` 目录），以发现新的监控对象。





### `prometheus_scrape_interval`

参数名称： `prometheus_scrape_interval`， 类型： `interval`， 层次：`G`

Prometheus 全局指标抓取周期, 默认值为 `10s`。在生产环境，10秒 - 30秒是一个较为合适的抓取周期。如果您需要更精细的的监控数据粒度，则可以调整此参数。







### `prometheus_scrape_timeout`

参数名称： `prometheus_scrape_timeout`， 类型： `interval`， 层次：`G`

Prometheus 全局抓取超时，默认为 `8s`。

设置抓取超时可以有效避免监控系统查询导致的雪崩，设置原则是，本参数必须小于并接近 [`prometheus_scrape_interval`](#prometheus_scrape_interval) ，确保每次抓取时长不超过抓取周期。





### `prometheus_options`

参数名称： `prometheus_options`， 类型： `arg`， 层次：`G`

Prometheus 的额外的命令行参数，默认值：`--storage.tsdb.retention.time=15d`

默认的参数会为 Prometheus 配置一个 15 天的保留期限来限制磁盘使用量。







### `pushgateway_enabled`

参数名称： `pushgateway_enabled`， 类型： `bool`， 层次：`G/I`

是否在当前 Infra 节点上启用 PushGateway？ 默认值为 `true`，即所有基础设施节点默认都会安装启用 PushGateway。







### `pushgateway_options`

参数名称： `pushgateway_options`， 类型： `arg`， 层次：`G`

PushGateway 的额外的命令行参数，默认值：`--persistence.interval=1m`，即每分钟进行一次持久化操作。





### `blackbox_enabled`

参数名称： `blackbox_enabled`， 类型： `bool`， 层次：`G/I`

是否在当前 Infra 节点上启用 BlackboxExporter ？ 默认值为 `true`，即所有基础设施节点默认都会安装启用 BlackboxExporter 。

BlackboxExporter 会向节点 IP 地址， VIP 地址，PostgreSQL VIP 地址发送 ICMP 报文测试网络连通性。





### `blackbox_options`

参数名称： `blackbox_options`， 类型： `arg`， 层次：`G`

BlackboxExporter 的额外的命令行参数，默认值：空字符串。






### `alertmanager_enabled`

参数名称： `alertmanager_enabled`， 类型： `bool`， 层次：`G/I`

是否在当前 Infra 节点上启用 AlertManager ？ 默认值为 `true`，即所有基础设施节点默认都会安装启用 AlertManager 。





### `alertmanager_options`

参数名称： `alertmanager_options`， 类型： `arg`， 层次：`G`

AlertManager 的额外的命令行参数，默认值：空字符串。





### `exporter_metrics_path`

参数名称： `exporter_metrics_path`， 类型： `path`， 层次：`G`

监控 exporter 暴露指标的 HTTP 端点路径，默认为： `/metrics` ，不建议修改此参数。






### `exporter_install`

参数名称： `exporter_install`， 类型： `enum`， 层次：`G`

（弃用参数）安装监控组件的方式，有三种可行选项：`none`, `yum`, `binary`

指明安装Exporter的方式：

* `none`：不安装，（默认行为，Exporter已经在先前由 [`node_pkg`](NODE#nodeyml) 任务完成安装）
* `yum`：使用yum（apt）安装（如果启用yum安装，在部署Exporter前执行yum安装 [`node_exporter`](#node_exporter) 与 [`pg_exporter`](#pg_exporter) ）
* `binary`：使用拷贝二进制的方式安装（从元节点中直接拷贝[`node_exporter`](#node_exporter) 与 [`pg_exporter`](#pg_exporter) 二进制，不推荐）

使用`yum`安装时，如果指定了`exporter_repo_url`（不为空），在执行安装时会首先将该URL下的REPO文件安装至`/etc/yum.repos.d`中。这一功能可以在不执行节点基础设施初始化的环境下直接进行Exporter的安装。
不推荐普通用户使用`binary`安装，这种模式通常用于紧急故障抢修与临时问题修复。






### `exporter_repo_url`

参数名称： `exporter_repo_url`， 类型： `url`， 层次：`G`

（弃用参数）监控组件的 Yum Repo URL

默认为空，当 [`exporter_install`](#exporter_install) 为 `yum` 时，该参数指定的Repo会被添加至节点源列表中。






------------------------------

## `GRAFANA`

Pigsty 使用 Grafana 作为监控系统前端。它也可以做为数据分析与可视化平台，或者用于低代码数据应用开发，制作数据应用原型等目的。


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

参数名称： `grafana_enabled`， 类型： `bool`， 层次：`G/I`

是否在Infra节点上启用Grafana？默认值为： `true`，即所有基础设施节点默认都会安装启用 Grafana。





### `grafana_clean`

参数名称： `grafana_clean`， 类型： `bool`， 层次：`G/A`

是否在初始化 Grafana 时一并清理其数据文件？默认为：`true`。

该操作会移除 `/var/lib/grafana/grafana.db`，确保 Grafana 全新安装。





### `grafana_admin_username`

参数名称： `grafana_admin_username`， 类型： `username`， 层次：`G`

Grafana管理员用户名，`admin` by default







### `grafana_admin_password`

参数名称： `grafana_admin_password`， 类型： `password`， 层次：`G`

Grafana管理员密码，`pigsty` by default

> 提示：请务必在生产部署中修改此密码参数！ 





### `grafana_plugin_cache`

参数名称： `grafana_plugin_cache`， 类型： `path`， 层次：`G`

Grafana 插件缓存地址，一个指向 Tarball 的路径，默认值为：`/www/pigsty/plugins.tgz`

如果该文件存在，Pigsty会直接将其解压至：`/var/lib/grafana/plugins` 中并跳过从互联网下载 Grafana 插件的步骤。






### `grafana_plugin_list`

参数名称： `grafana_plugin_list`， 类型： `string[]`， 层次：`G`

列表中的 Grafana 插件将会被下载，默认包含了来自 volkovlabs 与 marusolsson 的几个实用扩展。 

```yaml
grafana_plugin_list:              # grafana plugins to be downloaded with grafana-cli
  - volkovlabs-echarts-panel
  - volkovlabs-image-panel
  - volkovlabs-form-panel
  - volkovlabs-variable-panel
  - volkovlabs-grapi-datasource
  - marcusolsson-static-datasource
  - marcusolsson-json-datasource
  - marcusolsson-dynamictext-panel
  - marcusolsson-treemap-panel
  - marcusolsson-calendar-panel
  - marcusolsson-hourly-heatmap-panel
  - knightss27-weathermap-panel
```

每个数组元素是一个字符串，表示插件的名称。插件会通过`grafana-cli plugins install`的方式进行安装。





------------------------------

## `LOKI`

Loki 是Grafana提供的轻量级日志收集/检索平台，它可以提供一个集中查询服务器/数据库日志的地方。


### `loki_enabled`

参数名称： `loki_enabled`， 类型： `bool`， 层次：`G/I`

是否在当前 Infra 节点上启用 Loki ？ 默认值为 `true`，即所有基础设施节点默认都会安装启用 Loki 。






### `loki_clean`

参数名称： `loki_clean`， 类型： `bool`， 层次：`G/A`

是否在安装Loki时清理数据库目录？默认值： `false`，现有日志数据在初始化时会保留。





### `loki_data`

参数名称： `loki_data`， 类型： `path`， 层次：`G`

Loki的数据目录，默认值为： `/data/loki`






### `loki_retention`

参数名称： `loki_retention`， 类型： `interval`， 层次：`G`

Loki日志默认保留天数，默认保留 `15d` 。










------------------------------------------------------------

# `NODE`

[NODE](NODE) 模块负责将主机节点调整到期待的目标状态，并将其纳入 Pigsty 的监控系统中。



------------------------------

## `NODE_ID`

每个节点都有**身份参数**，通过在`<cluster>.hosts`与`<cluster>.vars`中的相关参数进行配置。

Pigsty使用**IP地址**作为**数据库节点**的唯一标识，**该IP地址必须是数据库实例监听并对外提供服务的IP地址**，但不宜使用公网IP地址。 
尽管如此，用户并不一定非要通过该IP地址连接至该数据库。例如，通过SSH隧道或跳板机中转的方式间接操作管理目标节点也是可行的。
但在标识数据库节点时，首要IPv4地址依然是节点的核心标识符。**这一点非常重要，用户应当在配置时保证这一点**。
IP地址即配置清单中主机的`inventory_hostname` ，体现为`<cluster>.hosts`对象中的`key`。

```yaml
node-test:
  hosts:
    10.10.10.11: { nodename: node-test-1 }
    10.10.10.12: { nodename: node-test-2 }
    10.10.10.13: { nodename: node-test-3 }
  vars:
    node_cluster: node-test
```

除此之外，在Pigsty监控系统中，节点还有两个重要的身份参数：[`nodename`](#nodename) 与 [`node_cluster`](#node_cluster)，这两者将在监控系统中被用作节点的 **实例标识**（`ins`） 与 **集群标识** （`cls`）。

```yaml
node_load1{cls="pg-meta", ins="pg-meta-1", ip="10.10.10.10", job="nodes"}
node_load1{cls="pg-test", ins="pg-test-1", ip="10.10.10.11", job="nodes"}
node_load1{cls="pg-test", ins="pg-test-2", ip="10.10.10.12", job="nodes"}
node_load1{cls="pg-test", ins="pg-test-3", ip="10.10.10.13", job="nodes"}
```

在执行默认的PostgreSQL部署时，因为Pigsty默认采用节点独占1:1部署，因此可以通过 [`node_id_from_pg`](#node_id_from_pg) 参数，将数据库实例的身份参数（ [`pg_cluster`](#pg_cluster) 借用至节点的`ins`与`cls`标签上。

|               名称                |    类型    |  层级   | 必要性    | 说明         |
|:-------------------------------:|:--------:|:-----:|--------|------------|
|      `inventory_hostname`       |   `ip`   | **-** | **必选** | **节点IP地址** |
|     [`nodename`](#nodename)     | `string` | **I** | 可选     | **节点名称**   |
| [`node_cluster`](#node_cluster) | `string` | **C** | 可选     | **节点集群名称** |


```yaml
#nodename:                # [实例] # 节点实例标识，如缺失则使用现有主机名，可选，无默认值
node_cluster: nodes       # [集群] # 节点集群标识，如缺失则使用默认值'nodes'，可选
nodename_overwrite: true          # 用 nodename 覆盖节点的主机名吗？
nodename_exchange: false          # 在剧本主机之间交换 nodename 吗？
node_id_from_pg: true             # 如果可行，是否借用 postgres 身份作为节点身份？
```




### `nodename`

参数名称： `nodename`， 类型： `string`， 层次：`I`

主机节点的身份参数，如果没有显式设置，则会使用现有的主机 Hostname 作为节点名。本参数虽然是身份参数，但因为有合理默认值，所以是可选项。

如果启用了 [`node_id_from_pg`](#node_id_from_pg) 选项（默认启用），且 `nodename` 没有被显式指定，
那么 [`nodename`](#nodename) 会尝试使用 `${pg_cluster}-${pg_seq}` 作为实例身份参数，如果集群没有定义 PGSQL 模块，那么会回归到默认值，也就是主机节点的 HOSTNAME。




### `node_cluster`

参数名称： `node_cluster`， 类型： `string`， 层次：`C`

该选项可为节点显式指定一个集群名称，通常在节点集群层次定义才有意义。使用默认空值将直接使用固定值`nodes`作为节点集群标识。

如果启用了 [`node_id_from_pg`](#node_id_from_pg) 选项（默认启用），且 `node_cluster` 没有被显式指定，那么 [`node_cluster`](#node_cluster) 会尝试使用 `${pg_cluster}-${pg_seq}` 作为集群身份参数，如果集群没有定义 PGSQL 模块，那么会回归到默认值 `nodes`。







### `nodename_overwrite`

参数名称： `nodename_overwrite`， 类型： `bool`， 层次：`C`

是否使用 [`nodename`](#nodename) 覆盖主机名？默认值为 `true`，在这种情况下，如果你设置了一个非空的 [`nodename`](#nodename) ，那么它会被用作当前主机的 HOSTNAME 。

当 `nodename` 配置为空时，如果  [`node_id_from_pg`](#node_id_from_pg) 参数被配置为 `true` （默认为真），那么 Pigsty 会尝试借用1:1定义在节点上的 PostgreSQL 实例的身份参数作为主机的节点名。
也就是 `{{ pg_cluster }}-{{ pg_seq }}`，如果该节点没有安装 PGSQL 模块，则会回归到默认什么都不做的状态。

因此，如果您将 [`nodename`](#nodename) 留空，并且没有启用 [`node_id_from_pg`](#node_id_from_pg) 参数时，Pigsty不会对现有主机名进行任何修改。






### `nodename_exchange`

参数名称： `nodename_exchange`， 类型： `bool`， 层次：`C`

是否在剧本节点间交换主机名？默认值为：`false`

启用此参数时，同一批组执行 [`node.yml`](NODE#nodeyml) 剧本的节点之间会相互交换节点名称，写入`/etc/hosts`中。





### `node_id_from_pg`

参数名称： `node_id_from_pg`， 类型： `bool`， 层次：`C`

从节点上 1:1 部署的 PostgreSQL 实例/集群上借用身份参数？ 默认值为 `true`。

Pigsty 中的 PostgreSQL 实例与节点默认使用 1:1 部署，因此，您可以从数据库实例上“借用” 身份参数。
此参数默认启用，这意味着一套 PostgreSQL 集群如果没有特殊配置，主机节点集群和实例的身份参数默认值是与数据库身份参数保持一致的。对于问题分析，监控数据处理都提供了额外便利。





------------------------------

## `NODE_DNS`

Pigsty会为节点配置静态DNS解析记录与动态DNS服务器。

如果您的节点供应商已经为您配置了DNS服务器，您可以将 [`node_dns_method`](#node_dns_method) 设置为 `none` 跳过DNS设置。

```yaml
node_write_etc_hosts: true        # modify `/etc/hosts` on target node?
node_default_etc_hosts:           # static dns records in `/etc/hosts`
  - "${admin_ip} h.pigsty a.pigsty p.pigsty g.pigsty"
node_etc_hosts: []                # extra static dns records in `/etc/hosts`
node_dns_method: add              # how to handle dns servers: add,none,overwrite
node_dns_servers: ['${admin_ip}'] # dynamic nameserver in `/etc/resolv.conf`
node_dns_options:                 # dns resolv options in `/etc/resolv.conf`
  - options single-request-reopen timeout:1
```



### node_write_etc_hosts

参数名称： `node_write_etc_hosts`， 类型： `bool`， 层次：`G|C|I`

是否修改目标节点上的 `/etc/hosts`？例如，在容器环境中通常不允许修改此配置文件。




### `node_default_etc_hosts`

参数名称： `node_default_etc_hosts`， 类型： `string[]`， 层次：`G`

默认写入所有节点 `/etc/hosts` 的静态DNS记录，默认值为：

```yaml
["${admin_ip} h.pigsty a.pigsty p.pigsty g.pigsty"]
```

[`node_default_etc_hosts`](#node_default_etc_hosts) 是一个数组，每个元素都是一条 DNS 记录，格式为 `<ip> <name>`，您可以指定多个用空格分隔的域名。

这个参数是用于配置全局静态DNS解析记录的，如果您希望为单个集群与实例配置特定的静态DNS解析，则可以使用 [`node_etc_hosts`](#node_etc_hosts) 参数。






### `node_etc_hosts`

参数名称： `node_etc_hosts`， 类型： `string[]`， 层次：`C`

写入节点 `/etc/hosts` 的额外的静态DNS记录，默认值为：`[]` 空数组。

本参数与 [`node_default_etc_hosts`](#node_default_etc_hosts)，形式一样，但用途不同：适合在集群/实例层面进行配置。




### `node_dns_method`

参数名称： `node_dns_method`， 类型： `enum`， 层次：`C`

如何配置DNS服务器？有三种选项：`add`、`none`、`overwrite`，默认值为 `add`。

* `add`：将 [`node_dns_servers`](#node_dns_servers) 中的记录**追加**至`/etc/resolv.conf`，并保留已有DNS服务器。（默认）
* `overwrite`：使用将 [`node_dns_servers`](#node_dns_servers) 中的记录覆盖`/etc/resolv.conf`
* `none`：跳过DNS服务器配置，如果您的环境中已经配置有DNS服务器，则可以直接跳过DNS配置。




### `node_dns_servers`

参数名称： `node_dns_servers`， 类型： `string[]`， 层次：`C`

配置 `/etc/resolv.conf` 中的动态DNS服务器列表：默认值为： `["${admin_ip}"]`，即将管理节点作为首要DNS服务器。





### `node_dns_options`

参数名称： `node_dns_options`， 类型： `string[]`， 层次：`C`

`/etc/resolv.conf` 中的DNS解析选项，默认值为：

```yaml
- "options single-request-reopen timeout:1"
```

如果 [`node_dns_method`](#node_dns_method) 配置为`add`或`overwrite`，则本配置项中的记录会被首先写入`/etc/resolv.conf` 中。具体格式请参考Linux文档关于`/etc/resolv.conf`的说明











------------------------------

## `NODE_PACKAGE`

Pigsty会为纳入管理的节点配置Yum源，并安装软件包。

```yaml
node_repo_modules: local          # upstream repo to be added on node, local by default.
node_repo_remove: true            # remove existing repo on node?
node_packages: [ ]                # packages to be installed current nodes
node_default_packages:            # default packages to be installed on all nodes
  - lz4,unzip,bzip2,zlib,yum,pv,jq,git,ncdu,make,patch,bash,lsof,wget,uuid,tuned,nvme-cli,numactl,grubby,sysstat,iotop,htop,rsync,tcpdump,chrony,python3
  - netcat,socat,ftp,lrzsz,net-tools,ipvsadm,bind-utils,telnet,audit,ca-certificates,openssl,readline,vim-minimal,node_exporter,etcd,haproxy,python3-pip
```  




### `node_repo_modules`

参数名称： `node_repo_modules`， 类型： `string`， 层次：`C/A`

需要在节点上添加的的软件源模块列表，形式同 [`repo_modules`](#repo_modules)。默认值为 `local`，即使用 [`repo_upstream`](#repo_upstream) 中 `local` 所指定的本地软件源。

当 Pigsty 纳管节点时，会根据此参数的值来过滤 [`repo_upstream`](#repo_upstream) 中的条目，只有 `module` 字段与此参数值匹配的条目才会被添加到节点的软件源中。





### `node_repo_remove`

参数名称： `node_repo_remove`， 类型： `bool`， 层次：`C/A`

是否移除节点已有的软件仓库定义？默认值为：`true`。

如果启用，则Pigsty会 **移除** 节点上`/etc/yum.repos.d`中原有的配置文件，并备份至`/etc/yum.repos.d/backup`。
在 Debian/Ubuntu 系统上，则是 `/etc/apt/sources.list(.d)` 备份至 `/etc/apt/backup`。






### `node_packages`

参数名称： `node_packages`， 类型： `string[]`， 层次：`C`

在当前节点上要安装的软件包列表，默认值为：`[]` 空数组。

每一个数组元素都是字符串：由逗号分隔的软件包名称。形式上与 [`node_packages_default`](#node_default_packages) 相同。本参数通常用于在节点/集群层面指定需要额外安装的软件包。





### `node_default_packages`

参数名称： `node_default_packages`， 类型： `string[]`， 层次：`G`

默认在所有节点上安装的软件包，默认值是 EL 7/8/9 通用的 RPM 软件包列表，数组，每个元素为逗号分隔的包名：

```yaml
node_default_packages:            # default packages to be installed on all nodes
  - lz4,unzip,bzip2,zlib,yum,pv,jq,git,ncdu,make,patch,bash,lsof,wget,uuid,tuned,nvme-cli,numactl,grubby,sysstat,iotop,htop,rsync,tcpdump,chrony,python3
  - netcat,socat,ftp,lrzsz,net-tools,ipvsadm,bind-utils,telnet,audit,ca-certificates,openssl,readline,vim-minimal,node_exporter,etcd,haproxy,python3-pip
```

对于 Ubuntu 22.04 / 20.04 ，默认值应当被显式替换为：

```yaml
- lz4,unzip,bzip2,zlib1g,pv,jq,git,ncdu,make,patch,bash,lsof,wget,uuid,tuned,nvme-cli,numactl,sysstat,iotop,htop,rsync,tcpdump,chrony,acl,python3,python3-pip
- netcat,ftp,socat,lrzsz,net-tools,ipvsadm,dnsutils,telnet,ca-certificates,openssl,openssh-client,libreadline-dev,vim-tiny,keepalived,node-exporter,etcd,haproxy
```

对于 Debian 12 / 11 ，默认值应当被显式替换为：

```yaml
- lz4,unzip,bzip2,zlib1g,pv,jq,git,ncdu,make,patch,bash,lsof,wget,uuid,tuned,linux-perf,nvme-cli,numactl,sysstat,iotop,htop,rsync,tcpdump,chrony,acl,python3,python3-pip
- netcat-openbsd,socat,tnftp,lrzsz,net-tools,ipvsadm,dnsutils,telnet,ca-certificates,openssl,openssh-client,libreadline-dev,vim-tiny,keepalived,node-exporter,etcd,haproxy
```

形式上与 [`node_packages`](#node_packages) 相同，但本参数通常用于全局层面指定所有节点都必须安装的默认软件包。




------------------------------

## `NODE_TUNE`

主机节点特性、内核模块与参数调优模板。


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

参数名称： `node_disable_firewall`， 类型： `bool`， 层次：`C`

关闭节点防火墙？默认关闭防火墙：`true`。

如果您在受信任的内网部署，可以关闭防火墙。在 EL 下是 `firewalld` 服务，在 Ubuntu下是 `ufw` 服务。




### `node_disable_selinux`

参数名称： `node_disable_selinux`， 类型： `bool`， 层次：`C`

关闭节点SELINUX？默认关闭SELinux：`true`。

如果您没有操作系统/安全专家，请关闭 SELinux。




### `node_disable_numa`

参数名称： `node_disable_numa`， 类型： `bool`， 层次：`C`

是否关闭NUMA？默认不关闭NUMA：`false`。

注意，关闭NUMA需要重启机器后方可生效！如果您不清楚如何绑核，在生产环境使用数据库时建议关闭NUMA。







### `node_disable_swap`

参数名称： `node_disable_swap`， 类型： `bool`， 层次：`C`

是否关闭 SWAP ？ 默认不关闭SWAP：`false`。

通常情况下不建议关闭SWAP，如果您有足够的内存，且数据库采用独占式部署，则可以关闭SWAP提高性能。

例外：当您的节点用于部署Kubernetes时，应当禁用SWAP。






### `node_static_network`

参数名称： `node_static_network`， 类型： `bool`， 层次：`C`

是否使用静态DNS服务器, 类型：`bool`，层级：C，默认值为：`true`，默认启用。

启用静态网络，意味着您的DNS Resolv配置不会因为机器重启与网卡变动被覆盖（EL 7/8 操作系统）。建议启用。





### `node_disk_prefetch`

参数名称： `node_disk_prefetch`， 类型： `bool`， 层次：`C`

是否启用磁盘预读？默认不启用：`false`。

针对HDD部署的实例可以优化性能，使用机械硬盘时建议启用。





### `node_kernel_modules`

参数名称： `node_kernel_modules`， 类型： `string[]`， 层次：`C`

启用哪些内核模块？默认启用以下内核模块：

```yaml
node_kernel_modules: [ softdog, br_netfilter, ip_vs, ip_vs_rr, ip_vs_wrr, ip_vs_sh ]
```

形式上是由内核模块名称组成的数组，声明了需要在节点上安装的内核模块。

 




### `node_hugepage_count`

参数名称： `node_hugepage_count`， 类型： `int`， 层次：`C`

在节点上分配 2MB 大页的数量，默认为 `0`，另一个相关的参数是 [`node_hugepage_ratio`](#node_hugepage_ratio)。

如果这两个参数 `node_hugepage_count` 和 `node_hugepage_ratio` 都为 `0`（默认），则大页将完全被禁用，本参数的优先级相比 [`node_hugepage_ratio`](#node_hugepage_ratio) 更高，因为它更加精确。

如果设定了一个非零值，它将被写入 `/etc/sysctl.d/hugepage.conf` 中应用生效；负值将不起作用，高于90%节点内存的数字将被限制为节点内存的90%

如果不为零，它应该略大于[`pg_shared_buffer_ratio`](#pg_shared_buffer_ratio) 的对应值，这样才能让 PostgreSQL 用上大页。





### `node_hugepage_ratio`

参数名称： `node_hugepage_ratio`， 类型： `float`， 层次：`C`

节点内存大页占内存的比例，默认为 `0`，有效范围：`0` ~ `0.40`

此内存比例将以大页的形式分配，并为PostgreSQL预留。 [`node_hugepage_count`](#node_hugepage_count) 是具有更高优先级和精度的参数版本。

默认值：`0`，这将设置 `vm.nr_hugepages=0` 并完全不使用大页。 

本参数应该等于或略大于[`pg_shared_buffer_ratio`](#pg_shared_buffer_ratio)，如果不为零。

例如，如果您为Postgres共享缓冲区默认分配了25%的内存，您可以将此值设置为 0.27 ~ 0.30，并在初始化后使用 `/pg/bin/pg-tune-hugepage` 精准回收浪费的大页。





### `node_overcommit_ratio`

参数名称： `node_overcommit_ratio`， 类型： `int`， 层次：`C`

节点内存超额分配比率，默认为：`0`。这是一个从 `0` 到 `100+` 的整数。

默认值：`0`，这将设置 `vm.overcommit_memory=0`，否则将使用 `vm.overcommit_memory=2`， 并使用此值作为 `vm.overcommit_ratio`。

建议在 pgsql 独占节点上设置 `vm.overcommit_ratio`，避免内存过度提交。





### `node_tune`

参数名称： `node_tune`， 类型： `enum`， 层次：`C`

针对机器进行调优的预制方案，基于`tuned` 提供服务。有四种预制模式：

* `tiny`：微型虚拟机
* `oltp`：常规OLTP模板，优化延迟（默认值）
* `olap`：常规OLAP模板，优化吞吐量
* `crit`：核心金融业务模板，优化脏页数量

通常，数据库的调优模板 [`pg_conf`](PARAM#pg_conf)应当与机器调优模板配套。







### `node_sysctl_params`

参数名称： `node_sysctl_params`， 类型： `dict`， 层次：`C`

使用 K:V 形式的 sysctl 内核参数，会添加到 `tuned` profile 中，默认值为： `{}` 空对象。

这是一个 KV 结构的字典参数，Key 是内核 `sysctl` 参数名，Value 是参数值。你也可以考虑直接在 `roles/node/templates` 中的 tuned 模板中直接定义额外的 sysctl 参数。







------------------------------

## `NODE_ADMIN`

这一节关于主机节点上的管理员，谁能登陆，怎么登陆。

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

参数名称： `node_data`， 类型： `path`， 层次：`C`

节点的主数据目录，默认为 `/data`。

如果该目录不存在，则该目录会被创建。该目录应当由 `root` 拥有，并拥有 `777` 权限。






### `node_admin_enabled`

参数名称： `node_admin_enabled`， 类型： `bool`， 层次：`C`

是否在本节点上创建一个专用管理员用户？默认值为：`true`。

Pigsty默认会在每个节点上创建一个管理员用户（拥有免密sudo与ssh权限），默认的管理员名为`dba (uid=88)`的管理用户，可以从元节点上通过SSH免密访问环境中的其他节点并执行免密sudo。




### `node_admin_uid`

参数名称： `node_admin_uid`， 类型： `int`， 层次：`C`

管理员用户UID，默认值为：`88`。

请尽可能确保 UID 在所有节点上都相同，可以避免一些无谓的权限问题。

如果默认 UID 88 已经被占用，您可以选择一个其他 UID ，手工分配时请注意UID命名空间冲突。







### `node_admin_username`

参数名称： `node_admin_username`， 类型： `username`， 层次：`C`

管理员用户名，默认为 `dba` 。





### `node_admin_ssh_exchange`

参数名称： `node_admin_ssh_exchange`， 类型： `bool`， 层次：`C`

在节点集群间交换节点管理员SSH密钥, 类型：`bool`，层级：C，默认值为：`true`

启用时，Pigsty会在执行剧本时，在成员间交换SSH公钥，允许管理员 [`node_admin_username`](#node_admin_username) 从不同节点上相互访问。





### `node_admin_pk_current`

参数名称： `node_admin_pk_current`， 类型： `bool`， 层次：`C`

是否将当前节点 & 用户的公钥加入管理员账户，默认值是： `true`

启用时，将会把当前节点上执行此剧本的管理用户的SSH公钥（`~/.ssh/id_rsa.pub`）拷贝至目标节点管理员用户的 `authorized_keys` 中。

生产环境部署时，请务必注意此参数，此参数会将当前执行命令用户的默认公钥安装至所有机器的管理用户上。








### `node_admin_pk_list`

参数名称： `node_admin_pk_list`， 类型： `string[]`， 层次：`C`

可登陆管理员的公钥列表，默认值为：`[]` 空数组。 

数组的每一个元素为字符串，内容为写入到管理员用户`~/.ssh/authorized_keys`中的公钥，持有对应私钥的用户可以以管理员身份登录。

生产环境部署时，请务必注意此参数，仅将信任的密钥加入此列表中。





------------------------------

## `NODE_TIME`

关于主机时间/时区/NTP/定时任务的相关配置。

时间同步对于数据库服务来说非常重要，请确保系统 `chronyd` 授时服务正常运行。

```yaml
node_timezone: ''                 # 设置节点时区，空字符串表示跳过
node_ntp_enabled: true            # 启用chronyd时间同步服务？
node_ntp_servers:                 # `/etc/chrony.conf`中的ntp服务器
  - pool pool.ntp.org iburst
node_crontab_overwrite: true      # 覆盖还是追加到`/etc/crontab`？
node_crontab: [ ]                 # `/etc/crontab`中的crontab条目
```


### `node_timezone`

参数名称： `node_timezone`， 类型： `string`， 层次：`C`

设置节点时区，空字符串表示跳过。默认值是空字符串，默认不会修改默认的时区（即使用通常的默认值UTC）

在中国地区使用时，建议设置为 `Asia/Hong_Kong`。




### `node_ntp_enabled`

参数名称： `node_ntp_enabled`， 类型： `bool`， 层次：`C`

启用chronyd时间同步服务？默认值为：`true`

此时 Pigsty 将使用 [`node_ntp_servers`](#node_ntp_servers) 中指定的 NTP服务器列表覆盖节点的 `/etc/chrony.conf`。

如果您的节点已经配置好了 NTP 服务器，那么可以将此参数设置为 `false` 跳过时间同步配置。




### `node_ntp_servers`

参数名称： `node_ntp_servers`， 类型： `string[]`， 层次：`C`

在 `/etc/chrony.conf` 中使用的 NTP 服务器列表。默认值为：`["pool pool.ntp.org iburst"]`

本参数是一个数组，每一个数组元素是一个字符串，代表一行 NTP 服务器配置。仅当 [`node_ntp_enabled`](#node_ntp_enabled) 启用时生效。

Pigsty 默认使用全球 NTP 服务器 `pool.ntp.org`，您可以根据自己的网络环境修改此参数，例如 `cn.pool.ntp.org iburst`，或内网的时钟服务。

您也可以在配置中使用 `${admin_ip}` 占位符，使用管理节点上的时间服务器。

```yaml
node_ntp_servers: [ 'pool ${admin_ip} iburst' ]
```





### `node_crontab_overwrite`

参数名称： `node_crontab_overwrite`， 类型： `bool`， 层次：`C`

处理 [`node_crontab`](#node_crontab) 中的定时任务时，是追加还是覆盖？默认值为：`true`，即覆盖。

如果您希望在节点上追加定时任务，可以将此参数设置为 `false`，Pigsty 将会在节点的 crontab 上 **追加**，而非 **覆盖所有** 定时任务。






### `node_crontab`

参数名称： `node_crontab`， 类型： `string[]`， 层次：`C`

定义在节点 `/etc/crontab` 中的定时任务：默认值为：`[]` 空数组。

每一个数组数组元素都是一个字符串，代表一行定时任务。使用标准的 cron 格式定义。

例如，以下配置会以  postgres 用户在每天凌晨1点执行全量备份任务。

```yaml
node_crontab: 
  - '00 01 * * * postgres /pg/bin/pg-backup full' ] # make a full backup every 1am
```




------------------------------

## `NODE_VIP`

您可以为节点集群绑定一个可选的 L2 VIP，默认不启用此特性。L2 VIP 只对一组节点集群有意义，该 VIP 会根据配置的优先级在集群中的节点之间进行切换，确保节点服务的高可用。

请注意，L2 VIP  **只能** 在同一 L2 网段中使用，这可能会对您的网络拓扑产生额外的限制，如果不想受此限制，您可以考虑使用 DNS LB 或者 Haproxy 实现类似的功能。

当启用此功能时，您需要为这个 L2 VIP 显式分配可用的 [`vip_address`](#vip_address) 与 [`vip_vrid`](#vip_vrid)，用户应当确保这两者在同一网段内唯一。 


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

参数名称： `vip_enabled`， 类型： `bool`， 层次：`C`

是否在当前这个节点集群中配置一个由 Keepalived 管理的 L2 VIP ？ 默认值为： `false`。







### `vip_address`

参数名称： `vip_address`， 类型： `ip`， 层次：`C`

节点 VIP 地址，IPv4 格式（不带 CIDR 网段后缀），当节点启用 [`vip_enabled`](#vip_enabled) 时，这是一个必选参数。

本参数没有默认值，这意味着您必须显式地为节点集群分配一个唯一的 VIP 地址。




### `vip_vrid`

参数名称： `vip_address`， 类型： `ip`， 层次：`C`

VRID 是一个范围从 `1` 到 `254` 的正整数，用于标识一个网络中的 VIP，当节点启用 [`vip_enabled`](#vip_enabled) 时，这是一个必选参数。

本参数没有默认值，这意味着您必须显式地为节点集群分配一个网段内唯一的 ID。







### `vip_role`

参数名称： `vip_role`， 类型： `enum`， 层次：`I`

节点 VIP 角色，可选值为： `master` 或 `backup`，默认值为 `backup`

该参数的值会被设置为 keepalived 的初始状态。




### `vip_preempt`

参数名称： `vip_preempt`， 类型： `bool`， 层次：`C/I`

是否启用 VIP 抢占？可选参数，默认值为 `false`，即不抢占 VIP。

所谓抢占，是指一个 `backup` 角色的节点，当其优先级高于当前存活且正常工作的 `master` 角色的节点时，是否取抢占其 VIP？






### `vip_interface`

参数名称： `vip_interface`， 类型： `string`， 层次：`C/I`

节点 VIP 监听使用的网卡，默认为 `eth0`。

您应当使用与节点主IP地址（即：你填入清单中IP地址）所使用网卡相同的名称。

如果你的节点有着不同的网卡名称，你可以在实例/节点层次对其进行覆盖。




### `vip_dns_suffix`

参数名称： `vip_dns_suffix`， 类型： `string`， 层次：`C/I`

节点集群 L2 VIP 使用的DNS名称，默认是空字符串，即直接使用集群名本身作为DNS名。





### `vip_exporter_port`

参数名称： `vip_exporter_port`， 类型： `port`， 层次：`C/I`

keepalived exporter 监听端口号，默认为：`9650`。






------------------------------

## `HAPROXY`

HAProxy 默认在所有节点上安装启用，并以类似于 Kubernetes NodePort 的方式对外暴露服务。

[`PGSQL`](PGSQL) 模块对外[服务](PGSQL-SERVICE)使用到了 Haproxy。


```yaml
haproxy_enabled: true             # 在此节点上启用haproxy？
haproxy_clean: false              # 清理所有现有的haproxy配置？
haproxy_reload: true              # 配置后重新加载haproxy？
haproxy_auth_enabled: true        # 为haproxy管理页面启用身份验证
haproxy_admin_username: admin     # haproxy管理用户名，默认为`admin`
haproxy_admin_password: pigsty    # haproxy管理密码，默认为`pigsty`
haproxy_exporter_port: 9101       # haproxy管理/导出端口，默认为9101
haproxy_client_timeout: 24h       # 客户端连接超时，默认为24小时
haproxy_server_timeout: 24h       # 服务器端连接超时，默认为24小时
haproxy_services: []              # 需要在节点上暴露的haproxy服务列表
```



### `haproxy_enabled`

参数名称： `haproxy_enabled`， 类型： `bool`， 层次：`C`

在此节点上启用haproxy？默认值为： `true`。





### `haproxy_clean`

参数名称： `haproxy_clean`， 类型： `bool`， 层次：`G/C/A`

清理所有现有的haproxy配置？默认值为 `false`。




### `haproxy_reload`

参数名称： `haproxy_reload`， 类型： `bool`， 层次：`A`

配置后重新加载 haproxy？默认值为 `true`，配置更改后会重新加载haproxy。

如果您希望在应用配置前进行手工检查，您可以使用命令参数关闭此选项，并进行检查后再应用。




### `haproxy_auth_enabled`

参数名称： `haproxy_auth_enabled`， 类型： `bool`， 层次：`G`

为haproxy管理页面启用身份验证，默认值为 `true`，它将要求管理页面进行http基本身份验证。

建议不要禁用认证，因为您的流量控制页面将对外暴露，这是比较危险的。




### `haproxy_admin_username`

参数名称： `haproxy_admin_username`， 类型： `username`， 层次：`G`

haproxy 管理员用户名，默认为：`admin`。






### `haproxy_admin_password`

参数名称： `haproxy_admin_password`， 类型： `password`， 层次：`G`

haproxy管理密码，默认为 `pigsty`

> 在生产环境中请务必修改此密码！




### `haproxy_exporter_port`

参数名称： `haproxy_exporter_port`， 类型： `port`， 层次：`C`

haproxy 流量管理/指标对外暴露的端口，默认为：`9101`







### `haproxy_client_timeout`

参数名称： `haproxy_client_timeout`， 类型： `interval`， 层次：`C`

客户端连接超时，默认为 `24h`。 

设置一个超时可以避免难以清理的超长的连接，但如果您真的需要一个长连接，您可以将其设置为更长的时间。







### `haproxy_server_timeout`

参数名称： `haproxy_server_timeout`， 类型： `interval`， 层次：`C`

服务端连接超时，默认为 `24h`。

设置一个超时可以避免难以清理的超长的连接，但如果您真的需要一个长连接，您可以将其设置为更长的时间。





### `haproxy_services`

参数名称： `haproxy_services`， 类型： `service[]`， 层次：`C`

需要在此节点上通过 Haproxy 对外暴露的服务列表，默认值为： `[]` 空数组。

每一个数组元素都是一个服务定义，下面是一个服务定义的例子：

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

每个服务定义会被渲染为 `/etc/haproxy/<service.name>.cfg` 配置文件，并在 Haproxy 重载后生效。









------------------------------

## `NODE_EXPORTER`

```yaml
node_exporter_enabled: true       # setup node_exporter on this node?
node_exporter_port: 9100          # node exporter listen port, 9100 by default
node_exporter_options: '--no-collector.softnet --no-collector.nvme --collector.tcpstat --collector.processes'
```



### `node_exporter_enabled`

参数名称： `node_exporter_enabled`， 类型： `bool`， 层次：`C`

在当前节点上启用节点指标收集器？默认启用：`true`




### `node_exporter_port`

参数名称： `node_exporter_port`， 类型： `port`， 层次：`C`

对外暴露节点指标使用的端口，默认为 `9100`。





### `node_exporter_options`

参数名称： `node_exporter_options`， 类型： `arg`， 层次：`C`

节点指标采集器的命令行参数，默认值为：

`--no-collector.softnet --no-collector.nvme --collector.tcpstat --collector.processes`

该选项会启用/禁用一些指标收集器，请根据您的需要进行调整。






------------------------------

## `PROMTAIL`

Promtail 是与 Loki 配套的日志收集组件，会收集各个模块产生的日志并发送至基础设施节点上的 [`LOKI`](#loki) 服务。

* `INFRA`： 基础设施组件的日志只会在 Infra 节点上收集。
    * `nginx-access`: `/var/log/nginx/access.log`
    * `nginx-error`: `/var/log/nginx/error.log`
    * `grafana`: `/var/log/grafana/grafana.log`

* `NODES`：主机相关的日志，所有节点上都会启用收集。
    * `syslog`: `/var/log/messages` （Debian上为 `/var/log/syslog`）
    * `dmesg`: `/var/log/dmesg`
    * `cron`: `/var/log/cron`

* `PGSQL`：PostgreSQL 相关的日志，只有节点配置了 [PGSQL](PGSQL) 模块才会启用收集。
    * `postgres`: `/pg/log/postgres/*.csv`
    * `patroni`: `/pg/log/patroni.log`
    * `pgbouncer`: `/pg/log/pgbouncer/pgbouncer.log`
    * `pgbackrest`: `/pg/log/pgbackrest/*.log`

* `REDIS`：Redis 相关日志，只有节点配置了 [REDIS](REDIS) 模块才会启用收集。
    * `redis`: `/var/log/redis/*.log`

> 日志目录会根据这些参数的配置自动调整：[`pg_log_dir`](#pg_log_dir), [`patroni_log_dir`](#patroni_log_dir), [`pgbouncer_log_dir`](#pgbouncer_log_dir), [`pgbackrest_log_dir`](#pgbackrest_log_dir)


```yaml
promtail_enabled: true            # enable promtail logging collector?
promtail_clean: false             # purge existing promtail status file during init?
promtail_port: 9080               # promtail listen port, 9080 by default
promtail_positions: /var/log/positions.yaml # promtail position status file path
```



### `promtail_enabled`

参数名称： `promtail_enabled`， 类型： `bool`， 层次：`C`

是否启用Promtail日志收集服务？默认值为： `true`




### `promtail_clean`

参数名称： `promtail_clean`， 类型： `bool`， 层次：`G/A`

是否在安装 Promtail 时移除已有状态信息？默认值为： `false`。

默认不会清理，当您选择清理时，Pigsty会在部署Promtail时移除现有状态文件 [`promtail_positions`](#promtail_positions)，这意味着Promtail会重新收集当前节点上的所有日志并发送至Loki。





### `promtail_port`

参数名称： `promtail_port`， 类型： `port`， 层次：`C`

Promtail 监听使用的默认端口号， 默认为：`9080`






### `promtail_positions`

参数名称： `promtail_positions`， 类型： `path`， 层次：`C`

Promtail 状态文件路径，默认值为：`/var/log/positions.yaml`。

Promtail记录了所有日志的消费偏移量，定期写入由本参数指定的文件中。






------------------------------------------------------------

# `DOCKER`

您可以使用 [`docker.yml`](https://github.com/Vonng/pigsty/blob/master/docker.yml) 剧本，在节点上安装并启用 Docker。


```yaml
docker_enabled: false             # enable docker on this node?
docker_cgroups_driver: systemd    # docker cgroup fs driver: cgroupfs,systemd
docker_registry_mirrors: []       # docker registry mirror list
docker_image_cache: /tmp/docker   # docker image cache dir, `/tmp/docker` by default
```



### `docker_enabled`

参数名称： `docker_enabled`， 类型： `bool`， 层次：`C`

是否在当前节点启用Docker？默认为： `false`，即不启用。




### `docker_cgroups_driver`

参数名称： `docker_cgroups_driver`， 类型： `enum`， 层次：`C`

Docker使用的 CGroup FS 驱动，可以是 `cgroupfs` 或 `systemd`，默认值为： `systemd`





### `docker_registry_mirrors`

参数名称： `docker_registry_mirrors`， 类型： `string[]`， 层次：`C`

Docker使用的镜像仓库地址，默认值为：`[]` 空数组。

您可以使用Docker镜像站点加速镜像拉取，下面是一些例子：

```yaml
[ "https://mirror.ccs.tencentyun.com" ]         # 腾讯云内网的镜像站点
["https://registry.cn-hangzhou.aliyuncs.com"]   # 阿里云镜像站点，需要登陆
```

如果拉取速度太慢，您也可以考虑：`docker login quay.io` 使用其他的 Registry。





### `docker_image_cache`

参数名称： `docker_image_cache`， 类型： `path`， 层次：`C`

本地的Docker镜像离线缓存包路径， 默认为 `/tmp/docker`。

在该路径下以 `tgz` 结尾的文件会被逐个 `load` 到 Docker 中：

```bash
cat {{ docker_image_cache }}/*.tgz | gzip -d -c - | docker load
```





------------------------------------------------------------

# `ETCD`

[ETCD](ETCD) 是一个分布式、可靠的键值存储，用于分布式系统的最关键数据。Pigsty使用etcd作为DCS，这对PostgreSQL的高可用性至关重要。

Pigsty为etcd集群使用一个硬编码的集群组名 `etcd`，它可以是一套现有的外部etcd集群，或者默认由 Pigsty 使用 [etcd.yml](ETCD#etcdyml) 剧本部署创建的新etcd集群。


```yaml
#etcd_seq: 1                      # etcd实例标识符，需要显式指定
#etcd_cluster: etcd               # etcd集群和组名称，默认为etcd
etcd_safeguard: false             # 组织清除正在运行的etcd实例？
etcd_clean: true                  # 在初始化过程中清除现有的etcd？
etcd_data: /data/etcd             # etcd数据目录，默认为/data/etcd
etcd_port: 2379                   # etcd客户端端口，默认为2379
etcd_peer_port: 2380              # etcd对等端口，默认为2380
etcd_init: new                    # etcd初始集群状态，新建或现有
etcd_election_timeout: 1000       # etcd选举超时，默认为1000ms
etcd_heartbeat_interval: 100      # etcd心跳间隔，默认为100ms
```



### `etcd_seq`

参数名称： `etcd_seq`， 类型： `int`， 层次：`I`

etcd 实例标号， 这是必选参数，必须为每一个 etcd 实例指定一个唯一的标号。

以下是一个3节点etcd集群的示例，分配了 1 ～ 3 三个标号。

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

参数名称： `etcd_cluster`， 类型： `string`， 层次：`C`

etcd 集群 & 分组名称，默认值为硬编码值 `etcd`。

当您想要部署另外的 etcd 集群备用时，可以修改此参数并使用其他集群名。







### `etcd_safeguard`

参数名称： `etcd_safeguard`， 类型： `bool`， 层次：`G/C/A`

安全保险参数，防止清除正在运行的etcd实例？默认值为 `false`。

如果启用安全保险，[etcd.yml](ETCD#etcdyml) 剧本不会清除正在运行的etcd实例。




### `etcd_clean`

参数名称： `etcd_clean`， 类型： `bool`， 层次：`G/C/A`

在初始化时清除现有的 etcd ？默认值为`true`。

如果启用，[etcd.yml](ETCD#etcdyml) 剧本将清除正在运行的 etcd 实例，这将使其成为一个真正幂等的剧本（总是抹除现有集群）。

但是如果启用了[`etcd_safeguard`](#etcd_safeguard)，即使设置了此参数，剧本依然会在遇到运行中的 etcd 实例时中止，避免误删。





### `etcd_data`

参数名称： `etcd_data`， 类型： `path`， 层次：`C`

etcd 数据目录，默认为`/data/etcd` 。






### `etcd_port`

参数名称： `etcd_port`， 类型： `port`， 层次：`C`

etcd 客户端端口号，默认为`2379`。





### `etcd_peer_port`

参数名称： `etcd_peer_port`， 类型： `port`， 层次：`C`

etcd peer 端口，默认为 `2380` 。





### `etcd_init`

参数名称： `etcd_init`， 类型： `enum`， 层次：`C`

etcd初始集群状态，可以是`new`或`existing`，默认值：`new`。

默认将创建一个独立的新etcd集群，当尝试向现有etcd集群[添加新成员](ETCD#添加成员)时，应当使用 `existing`。





### `etcd_election_timeout`

参数名称： `etcd_election_timeout`， 类型： `int`， 层次：`C`

etcd 选举超时，默认为 `1000` (毫秒)，也就是 1 秒。





### `etcd_heartbeat_interval`

参数名称： `etcd_heartbeat_interval`， 类型： `int`， 层次：`C`

etcd心跳间隔，默认为 `100` (毫秒)。



------------------------------------------------------------

# `MINIO`

MinIO 是一个与S3兼容的对象存储服务，它被用作PostgreSQL的可选的集中式备份存储库。

但你也可以将其用于其他目的，如存储大文件、文档、图片和视频。


```yaml
#minio_seq: 1                     # minio instance identifier, REQUIRED
#minio_cluster: minio             # minio cluster identifier, REQUIRED
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

参数名称： `minio_seq`， 类型： `int`， 层次：`I`

MinIO 实例标识符，必需的身份参数。没有默认值，您必须手动分配。





### `minio_cluster`

参数名称： `minio_cluster`， 类型： `string`， 层次：`C`

MinIO 集群名称，默认为 `minio`。当部署多个MinIO集群时，可以使用此参数进行区分。







### `minio_clean`

参数名称： `minio_clean`， 类型： `bool`， 层次：`G/C/A`

是否在初始化时清理 MinIO ？默认为 `false`，即不清理现有数据。






### `minio_user`

参数名称： `minio_user`， 类型： `username`， 层次：`C`

MinIO 操作系统用户名，默认为 `minio`。






### `minio_node`

参数名称： `minio_node`， 类型： `string`， 层次：`C`

MinIO 节点名称模式，用于[多节点](MINIO#多机多盘)部署。

默认值为：`${minio_cluster}-${minio_seq}.pigsty`，即以实例名 + `.pigsty` 后缀作为默认的节点名。





### `minio_data`

参数名称： `minio_data`， 类型： `path`， 层次：`C`

MinIO 数据目录（们），默认值：`/data/minio`，这是[单节点](MINIO#单机单盘)部署的常见目录。

对于[多个磁盘](MINIO#单机多盘)部署，您可以使用 `{x...y}` 的记法来指定多个驱动器。





### `minio_domain`

参数名称： `minio_domain`， 类型： `string`， 层次：`G`

MinIO 服务域名，默认为`sss.pigsty`。

客户端可以通过此域名访问 MinIO S3服务。此名称将注册到本地DNSMASQ，并包含在SSL证书字段中。






### `minio_port`

参数名称： `minio_port`， 类型： `port`， 层次：`C`

MinIO 服务端口，默认为`9000`。





### `minio_admin_port`

参数名称： `minio_admin_port`， 类型： `port`， 层次：`C`

MinIO 控制台端口，默认为`9001`。





### `minio_access_key`

参数名称： `minio_access_key`， 类型： `username`， 层次：`C`

根访问用户名（access key），默认为`minioadmin`。






### `minio_secret_key`

参数名称： `minio_secret_key`， 类型： `password`， 层次：`C`

根访问密钥（secret key），默认为`minioadmin`。

> **请务必在生产部署中更改此参数！**





### `minio_extra_vars`

参数名称： `minio_extra_vars`， 类型： `string`， 层次：`C`

MinIO 服务器的额外环境变量。查看[Minio Server](https://min.io/docs/minio/linux/reference/minio-server/minio-server.html) 文档以获取完整列表。

默认值为空字符串，您可以使用多行字符串来传递多个环境变量。




### `minio_alias`

参数名称： `minio_alias`， 类型： `string`， 层次：`G`


本地MinIO集群的MinIO别名，默认值：`sss`，它将被写入基础设施节点/管理员用户的客户端别名配置文件中。





### `minio_buckets`

参数名称： `minio_buckets`， 类型： `bucket[]`， 层次：`C`

默认创建的minio存储桶列表：

```yaml
minio_buckets: [ { name: pgsql }, { name: infra },  { name: redis } ]
```

为模块[`PGSQL`](PGSQL)、[`INFRA`](INFRA)和[`REDIS`](REDIS)创建了三个默认的存储桶。




### `minio_users`

参数名称： `minio_users`， 类型： `user[]`， 层次：`C`

要创建的minio用户列表，默认值：

```yaml
minio_users:
  - { access_key: dba , secret_key: S3User.DBA, policy: consoleAdmin }
  - { access_key: pgbackrest , secret_key: S3User.Backup, policy: readwrite }
```

默认配置会为 PostgreSQL DBA 和 pgBackREST 创建两个默认用户。

> **请务必在您的部署中调整这些凭证！**






------------------------------------------------------------

# `REDIS`

[Redis](REDIS) 模块包含了20个配置参数。

```yaml
#redis_cluster:             <集群> # Redis数据库集群名称，必选身份参数
#redis_node: 1              <节点> # Redis节点上的实例定义
#redis_instances: {}        <节点> # Redis节点编号，正整数，集群内唯一，必选身份参数
redis_fs_main: /data              # Redis主数据目录，默认为 `/data`
redis_exporter_enabled: true      # Redis Exporter 是否启用？
redis_exporter_port: 9121         # Redis Exporter监听端口
redis_exporter_options: ''        # Redis Exporter命令参数
redis_safeguard: false            # 禁止抹除现存的Redis
redis_clean: true                 # 初始化Redis是否抹除现存实例
redis_rmdata: true                # 移除Redis实例时是否一并移除数据？
redis_mode: standalone            # Redis集群模式：sentinel，cluster，standalone
redis_conf: redis.conf            # Redis配置文件模板，sentinel 除外
redis_bind_address: '0.0.0.0'     # Redis监听地址，默认留空则会绑定主机IP
redis_max_memory: 1GB             # Redis可用的最大内存
redis_mem_policy: allkeys-lru     # Redis内存逐出策略
redis_password: ''                # Redis密码，默认留空则禁用密码
redis_rdb_save: ['1200 1']        # Redis RDB 保存指令，字符串列表，空数组则禁用RDB
redis_aof_enabled: false          # Redis AOF 是否启用？
redis_rename_commands: {}         # Redis危险命令重命名列表
redis_cluster_replicas: 1         # Redis原生集群中每个主库配几个从库？
```



### `redis_cluster`

参数名称： `redis_cluster`， 类型： `string`， 层次：`C`

身份参数，必选参数，必须显式在集群层面配置，将用作集群内资源的命名空间。

需要遵循特定命名规则：`[a-z][a-z0-9-]*`，以兼容不同约束对身份标识的要求，建议使用`redis-`作为集群名前缀。





### `redis_node`

参数名称： `redis_node`， 类型： `int`， 层次：`I`

Redis节点序列号，身份参数，必选参数，必须显式在节点（Host）层面配置。

自然数，在集群中应当是唯一的，用于区别与标识集群内的不同节点，从0或1开始分配。





### `redis_instances`

参数名称： `redis_instances`， 类型： `dict`， 层次：`I`

当前 Redis 节点上的 Redis 实例定义，必选参数，必须显式在节点（Host）层面配置。

内容为JSON KV对象格式。Key为数值类型端口号，Value为该实例特定的JSON配置项。

```yaml
redis-test: # redis native cluster: 3m x 3s
  hosts:
    10.10.10.12: { redis_node: 1 ,redis_instances: { 6379: { } ,6380: { } ,6381: { } } }
    10.10.10.13: { redis_node: 2 ,redis_instances: { 6379: { } ,6380: { } ,6381: { } } }
  vars: { redis_cluster: redis-test ,redis_password: 'redis.test' ,redis_mode: cluster, redis_max_memory: 32MB }
```

每一个Redis实例在对应节点上监听一个唯一端口，实例配置项中`replica_of` 用于设置一个实例的上游主库地址，构建主从复制关系。

```yaml
redis_instances:
    6379: {}
    6380: { replica_of: '10.10.10.13 6379' }
    6381: { replica_of: '10.10.10.13 6379' }
```






### `redis_fs_main`

参数名称： `redis_fs_main`， 类型： `path`， 层次：`C`

Redis使用的主数据盘挂载点，默认为`/data`，Pigsty会在该目录下创建`redis`目录，用于存放Redis数据。

所以实际存储数据的目录为 `/data/redis`，该目录的属主为操作系统用户 `redis`，内部结构详情请参考 [FHS：Redis](FHS#redis-fhs)





### `redis_exporter_enabled`

参数名称： `redis_exporter_enabled`， 类型： `bool`， 层次：`C`

是否启用Redis监控组件 Redis Exporter？

默认启用，在每个Redis节点上部署一个，默认监听 [`redis_exporter_port`](#redis_exporter_port) `9121` 端口。所有本节点上 Redis 实例的监控指标都由它负责抓取。





### `redis_exporter_port`

参数名称： `redis_exporter_port`， 类型： `port`， 层次：`C`

Redis Exporter监听端口，默认值为：`9121`





### `redis_exporter_options`

参数名称： `redis_exporter_options`， 类型： `string`， 层次：`C/I`

传给 Redis Exporter 的额外命令行参数，会被渲染到 `/etc/defaut/redis_exporter` 中，默认为空字符串。






### `redis_safeguard`

参数名称： `redis_safeguard`， 类型： `bool`， 层次：`G/C/A`

Redis的防误删安全保险开关：打开后无法使用剧本抹除正在运行的 Redis 实例。

默认值为 `false`，如果设置为 `true`，那么当剧本遇到正在运行的 Redis 实例时，会中止初始化/抹除的操作，避免误删。





### `redis_clean`

参数名称： `redis_clean`， 类型： `bool`， 层次：`G/C/A`

Redis清理开关：是否在初始化的过程中抹除运行中的Redis实例？默认值为：`true`。

剧本 `redis.yml` 会在执行时抹除具有相同定义的现有 Redis 实例，这样可以保证剧本的幂等性。

如果您不希望 `redis.yml` 这样做，可以将此参数设置为 `false`，那么当剧本遇到正在运行的 Redis 实例时，会中止初始化/抹除的操作，避免误删。 

如果安全保险参数 [`redis_safeguard`](#redis_safeguard) 已经打开，那么本参数的优先级低于该参数。





### `redis_rmdata`

参数名称： `redis_rmdata`， 类型： `bool`， 层次：`G/C/A`

移除 Redis 实例的时候，是否一并移除 Redis 数据目录？默认为 `true`。

数据目录包含了 Redis 的 RDB与AOF文件，如果不抹除它们，那么新拉起的 Redis 实例将会从这些备份文件中加载数据。





### `redis_mode`

参数名称： `redis_mode`， 类型： `enum`， 层次：`C`

Redis集群的工作模式，有三种选项：`standalone`, `cluster`, `sentinel`，默认值为 `standalone`

* `standalone`：默认，独立的Redis主从模式
* `cluster`： Redis原生集群模式
* `sentinel`：Redis高可用组件：哨兵

当使用`standalone`模式时，Pigsty会根据 `replica_of` 参数设置Redis主从复制关系。

当使用`cluster`模式时，Pigsty会根据 [`redis_cluster_replicas`](#redis_cluster_replicas) 参数使用所有定义的实例创建原生Redis集群。





### `redis_conf`

参数名称： `redis_conf`， 类型： `string`， 层次：`C`

Redis 配置模板路径，Sentinel除外。

默认值：`redis.conf`，这是一个模板文件，位于 [`roles/redis/templates/redis.conf`](https://github.com/Vonng/pigsty/blob/master/roles/redis/templates/redis.conf)。

如果你想使用自己的 Redis 配置模板，你可以将它放在 `templates/` 目录中，并设置此参数为模板文件名。

注意： Redis Sentinel 使用的是另一个不同的模板文件，即 [`roles/redis/templates/redis-sentinel.conf`](https://github.com/Vonng/pigsty/blob/master/roles/redis/templates/redis-sentinel.conf)。





### `redis_bind_address`

参数名称： `redis_bind_address`， 类型： `ip`， 层次：`C`

Redis服务器绑定的IP地址，空字符串将使用配置清单中定义的主机名。

默认值：`0.0.0.0`，这将绑定到此主机上的所有可用 IPv4 地址。

在生产环境中出于安全性考虑，建议仅绑定内网 IP，即将此值设置为空字符串 `''`






### `redis_max_memory`

参数名称： `redis_max_memory`， 类型： `size`， 层次：`C/I`

每个 Redis 实例使用的最大内存配置，默认值：`1GB`。





### `redis_mem_policy`

参数名称： `redis_mem_policy`， 类型： `enum`， 层次：`C`

Redis 内存回收策略，默认值：`allkeys-lru`，

- `noeviction`：内存达限时不保存新值：当使用主从复制时仅适用于主库
- `allkeys-lru`：保持最近使用的键；删除最近最少使用的键（LRU）
- `allkeys-lfu`：保持频繁使用的键；删除最少频繁使用的键（LFU）
- `volatile-lru`：删除带有真实过期字段的最近最少使用的键
- `volatile-lfu`：删除带有真实过期字段的最少频繁使用的键
- `allkeys-random`：随机删除键以为新添加的数据腾出空间
- `volatile-random`：随机删除带有过期字段的键
- `volatile-ttl`：删除带有真实过期字段和最短剩余生存时间（TTL）值的键。

详情请参阅[Redis内存回收策略](https://redis.io/docs/reference/eviction/)。





### `redis_password`

参数名称： `redis_password`， 类型： `password`， 层次：`C/N`

Redis 密码，空字符串将禁用密码，这是默认行为。

注意，由于 redis_exporter 的实现限制，您每个节点只能设置一个 `redis_password`。这通常不是问题，因为 pigsty 不允许在同一节点上部署两个不同的 Redis 集群。

> 请在生产环境中使用强密码




### `redis_rdb_save`

参数名称： `redis_rdb_save`， 类型： `string[]`， 层次：`C`

Redis RDB 保存指令，使用空列表则禁用 RDB。

默认值是 `["1200 1"]`：如果最近20分钟至少有1个键更改，则将数据集转储到磁盘。

详情请参考 [Redis持久化](https://redis.io/docs/management/persistence/)。




### `redis_aof_enabled`

参数名称： `redis_aof_enabled`， 类型： `bool`， 层次：`C`

启用 Redis AOF 吗？默认值是 `false`，即不使用 AOF。





### `redis_rename_commands`

参数名称： `redis_rename_commands`， 类型： `dict`， 层次：`C`

重命名 Redis 危险命令，这是一个 k:v 字典：`old: new`，old是待重命名的命令名称，new是重命名后的名字。

默认值：`{}`，你可以通过设置此值来隐藏像 `FLUSHDB` 和 `FLUSHALL` 这样的危险命令，下面是一个例子：

```yaml
{
  "keys": "op_keys",
  "flushdb": "op_flushdb",
  "flushall": "op_flushall",
  "config": "op_config"  
}
```




### `redis_cluster_replicas`

参数名称： `redis_cluster_replicas`， 类型： `int`， 层次：`C`

在 Redis 原生集群中，应当为一个 Master/Primary 实例配置多少个从库？默认值为： `1`，即每个主库配一个从库。



### `redis_sentinel_monitor`

参数名称： `redis_sentinel_monitor`， 类型： `master[]`， 层次：`C`

Redis哨兵监控的主库列表，只在哨兵集群上使用。每个待纳管的主库定义方式如下所示：

```yaml
redis_sentinel_monitor:  # primary list for redis sentinel, use cls as name, primary ip:port
  - { name: redis-src, host: 10.10.10.45, port: 6379 ,password: redis.src, quorum: 1 }
  - { name: redis-dst, host: 10.10.10.48, port: 6379 ,password: redis.dst, quorum: 1 }
```

其中，`name`，`host` 是必选参数，`port`，`password`，`quorum` 是可选参数，`quorum` 用于设置判定主库失效所需的法定人数数，通常大于哨兵实例数的一半（默认为1）。




------------------------------------------------------------

# `PGSQL`

[`PGSQL`](PGSQL) 模块需要在 Pigsty 管理的节点上安装（即节点已经配置了 [`NODE`](NODE) 模块），同时还要求您的部署中有一套可用的 [`ETCD`](ETCD) 集群来存储集群元数据。

在单个节点上安装 `PGSQL` 模块将创建一个独立的 PGSQL 服务器/实例，即[主实例](PGSQL-CONF#读写主库)。
在额外节点上安装将创建[只读副本](PGSQL-CONF#只读从库)，可以作为备用实例，并用于承载分担只读请求。
您还可以创建用于 ETL/OLAP/交互式查询的[离线](PGSQL-CONF#离线从库)实例， 使用[同步备库](PGSQL-CONF#同步备库) 和 [法定人数提交](PGSQL-CONF#法定人数提交) 来提高数据一致性， 
甚至搭建[备份集群](PGSQL-CONF#备份集群) 和 [延迟集群](PGSQL-CONF#延迟集群) 以快速应对人为失误与软件缺陷导致的数据损失。

您可以定义多个 PGSQL 集群并进一步组建一个水平分片集群： Pigsty 支持原生的 [citus 集群组](PGSQL-CONF#citus集群)，可以将您的标准 PGSQL 集群原地升级为一个分布式的数据库集群。



------------------------------

## `PG_ID`

以下是一些常用的参数，用于标识 PGSQL 模块中的[实体](PGSQL-ARCH#实体概念图)：集群、实例、服务等...


```yaml
# pg_cluster:           #CLUSTER  # pgsql 集群名称，必需的标识参数
# pg_seq: 0             #INSTANCE # pgsql 实例序列号，必需的标识参数
# pg_role: replica      #INSTANCE # pgsql 角色，必需的，可以是 primary,replica,offline
# pg_instances: {}      #INSTANCE # 在节点上定义多个 pg 实例，使用 `{port:ins_vars}` 格式
# pg_upstream:          #INSTANCE # 备用集群或级联副本的 repl 上游 ip 地址
# pg_shard:             #CLUSTER  # pgsql 分片名称，分片集群的可选标识
# pg_group: 0           #CLUSTER  # pgsql 分片索引号，分片集群的可选标识
# gp_role: master       #CLUSTER  # 此集群的 greenplum 角色，可以是 master 或 segment
pg_offline_query: false #INSTANCE # 设置为 true 以在此实例上启用离线查询
```

您必须显式指定这些**身份参数**，它们没有默认值：

|             名称              |    类型    |  级别   | 扩展说明            |
|:---------------------------:|:--------:|:-----:|-----------------|
| [`pg_cluster`](#pg_cluster) | `string` | **C** | **PG 数据库集群名称**  |
|     [`pg_seq`](#pg_seq)     | `number` | **I** | **PG 数据库实例 ID** |
|    [`pg_role`](#pg_role)    |  `enum`  | **I** | **PG 数据库实例角色**  |
|   [`pg_shard`](#pg_shard)   | `string` | **C** | **数据库分片名称**     |
|   [`pg_group`](#pg_group)   | `number` | **C** | **数据库分片序号**     |

- [`pg_cluster`](#pg_cluster): 它标识集群的名称，该名称在集群级别配置。
- [`pg_role`](#pg_role): 在实例级别配置，标识 ins 的角色。只有 `primary` 角色会特别处理。如果不填写，默认为 `replica` 角色和特殊的 `delayed` 和 `offline` 角色。
- [`pg_seq`](#pg_seq): 用于在集群内标识 ins，通常是从 0 或 1 递增的整数，一旦分配就不会更改。
- `{{ pg_cluster }}-{{ pg_seq }}` 用于唯一标识 ins，即 `pg_instance`。
- `{{ pg_cluster }}-{{ pg_role }}` 用于标识集群内的服务，即 `pg_service`。
- [`pg_shard`](#pg_shard) 和 [`pg_group`](#pg_group) 用于水平分片集群，仅用于 citus、greenplum 和 matrixdb。

[`pg_cluster`](#pg_cluster)、[`pg_role`](#pg_role)、[`pg_seq`](#pg_seq) 是核心**标识参数**，对于任何 Postgres 集群都是**必选**的，并且必须显式指定。以下是一个示例：

```yaml
pg-test:
  hosts:
    10.10.10.11: {pg_seq: 1, pg_role: replica}
    10.10.10.12: {pg_seq: 2, pg_role: primary}
    10.10.10.13: {pg_seq: 3, pg_role: replica}
  vars:
    pg_cluster: pg-test
```

所有其他参数都可以从全局配置或默认配置继承，但标识参数必须**明确指定**和**手动分配**。



### `pg_mode`

参数名称： `pg_mode`， 类型： `enum`， 层次：`C`

PostgreSQL 集群模式，可选值为：`pgsql`，`citus`，或 `gpsql`，默认值为 `pgsql`，即标准的 PostgreSQL 集群。

如果 `pg_mode` 设置为 `citus` 或 `gpsql`，则需要两个额外的必选身份参数 [`pg_shard`](#pg_shard) 和 [`pg_group`](#pg_group) 来定义水平分片集群的身份。

在这两种情况下，每一个 PostgreSQL 集群都是一组更大的业务单元的一部分。




### `pg_cluster`

参数名称： `pg_cluster`， 类型： `string`， 层次：`C`

PostgreSQL 集群名称，必选的身份标识参数,没有默认值

集群名将用作资源的命名空间。

集群命名需要遵循特定的命名模式：`[a-z][a-z0-9-]*`，即，只使用数字与小写字母，且不以数字开头，以符合标识上的不同约束的要求。




### `pg_seq`

参数名称： `pg_seq`， 类型： `int`， 层次：`I`

PostgreSQL 实例序列号，必选的身份标识参数，无默认值。

此实例的序号，在其**集群**内是唯一分配的，通常使用自然数，从0或1开始分配，通常不会回收重用。




### `pg_role`

参数名称： `pg_role`， 类型： `enum`， 层次：`I`

PostgreSQL 实例角色，必选的身份标识参数，无默认值。取值可以是：`primary`, `replica`, `offline`

PGSQL 实例的角色，可以是：`primary`、`replica`、`standby` 或 `offline`。

- `primary`: 主实例，在集群中有且仅有一个。
- `replica`: 用于承载在线只读流量的副本，高负载下可能会有轻微复制延迟（10ms~100ms, 100KB）。
- `offline`: 用于处理离线只读流量的离线副本，如统计分析/ETL/个人查询等。





### `pg_instances`

参数名称： `pg_instances`， 类型： `dict`， 层次：`I`

使用 `{port:ins_vars}` 的形式在一台主机上定义多个 PostgreSQL 实例。

此参数是为在单个节点上的多实例部署保留的参数，Pigsty 尚未实现此功能，并强烈建议独占节点部署。





### `pg_upstream`

参数名称： `pg_upstream`， 类型： `ip`， 层次：`I`

[备份集群](PGSQL-CONF#备份集群)或级联从库的上游实例 IP 地址。

在集群的 `primary` 实例上设置 `pg_upstream` ，表示此集群是一个[备份集群](PGSQL-CONF#备份集群)，该实例将作为 `standby leader`，从上游集群接收并应用更改。

对非 `primary` 实例设置 `pg_upstream` 参数将指定一个具体实例作为物理复制的上游，如果与主实例 ip 地址不同，此实例将成为 **级联副本** 。确保上游 IP 地址是同一集群中的另一个实例是用户的责任。





### `pg_shard`

参数名称： `pg_shard`， 类型： `string`， 层次：`C`

PostgreSQL 水平分片名称，对于分片集群来说（例如 citus 集群），这是的必选标识参数。

当多个标准的 PostgreSQL 集群一起以水平分片方式为同一业务提供服务时，Pigsty 将此组集群标记为 **水平分片集群**。

[`pg_shard`](#pg_shard) 是分片组名称。它通常是 [`pg_cluster`](#pg_cluster) 的前缀。

例如，如果我们有一个分片组 `pg-citus`，并且其中有4个集群，它们的标识参数将是：

```
cls pg_shard: pg-citus
cls pg_group = 0:   pg-citus0
cls pg_group = 1:   pg-citus1
cls pg_group = 2:   pg-citus2
cls pg_group = 3:   pg-citus3
```





### `pg_group`

参数名称： `pg_group`， 类型： `int`， 层次：`C`

PostgreSQL 水平分片集群的分片索引号，对于分片集群来说（例如 citus 集群），这是的必选标识参数。

此参数与 [pg_shard](#pg_shard) 配对使用，通常可以使用非负整数作为索引号。







### `gp_role`

参数名称： `gp_role`， 类型： `enum`， 层次：`C`

PostgreSQL 集群的 Greenplum/Matrixdb 角色，可以是 `master` 或 `segment`。

- `master`: 标记 postgres 集群为 greenplum 主实例（协调节点），这是默认值。
- `segment` 标记 postgres 集群为 greenplum 段集群（数据节点）。

此参数仅用于 Greenplum/MatrixDB 数据库 （[`pg_mode`](#pg_mode) 为 `gpsql`），对于普通的 PostgreSQL 集群没有意义。






### `pg_exporters`

参数名称： `pg_exporters`， 类型： `dict`， 层次：`C`

额外用于[监控](PGSQL-MONITOR)远程 PostgreSQL 实例的 Exporter 定义，默认值：`{}`

如果您希望监控远程 PostgreSQL 实例，请在监控系统所在节点（Infra节点）集群上的 `pg_exporters` 参数中定义它们，并使用 [`pgsql-monitor.yml`](PGSQL-PLAYBOOK#pgsql-monitoryml) 剧本来完成部署。

```yaml
pg_exporters: # list all remote instances here, alloc a unique unused local port as k
    20001: { pg_cluster: pg-foo, pg_seq: 1, pg_host: 10.10.10.10 }
    20004: { pg_cluster: pg-foo, pg_seq: 2, pg_host: 10.10.10.11 }
    20002: { pg_cluster: pg-bar, pg_seq: 1, pg_host: 10.10.10.12 }
    20003: { pg_cluster: pg-bar, pg_seq: 1, pg_host: 10.10.10.13 }
```






### `pg_offline_query`

参数名称： `pg_offline_query`， 类型： `bool`， 层次：`I`

设置为 `true` 以在此实例上启用离线查询，默认为 `false`。

当某个 PostgreSQL 实例启用此参数时， 属于 `dbrole_offline` 分组的用户可以直接连接到该 PostgreSQL 实例上执行离线查询（慢查询，交互式查询，ETL/分析类查询）。

带有此标记的实例在效果上类似于为实例设置 `pg_role` = `offline` ，唯一的区别在于 `offline` 实例默认不会承载 `replica` 服务的请求，是作为专用的离线/分析从库实例而存在的。

如果您没有富余的实例可以专门用于此目的，则可以挑选一台普通的从库，在实例层次启用此参数，以便在需要时承载离线查询。









------------------------------

## `PG_BUSINESS`

定制集群模板：用户，数据库，服务，权限规则。

用户需**重点关注**此部分参数，因为这里是业务声明自己所需数据库对象的地方。

* 业务用户定义： [`pg_users`](#pg_users)
* 业务数据库定义： [`pg_databases`](#pg_databases)
* 集群专有服务定义： [`pg_services`](#pg_services) （全局定义：[`pg_default_services`](#pg_default_services)）
* PostgreSQL集群/实例特定的HBA规则： [`pg_default_services`](#pg_default_services)
* Pgbouncer连接池特定HBA规则： [`pgb_hba_rules`](#pgb_hba_rules)

[默认](PGSQL-ACL#默认用户)的数据库用户及其凭据，强烈建议在生产环境中修改这些用户的密码。

* PG管理员用户：[`pg_admin_username`](#pg_admin_username) / [`pg_admin_password`](#pg_admin_password)
* PG复制用户： [`pg_replication_username`](#pg_replication_username) / [`pg_replication_password`](#pg_replication_password)
* PG监控用户：[`pg_monitor_username`](#pg_monitor_username) / [`pg_monitor_password`](#pg_monitor_password)

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

参数名称： `pg_users`， 类型： `user[]`， 层次：`C`

PostgreSQL 业务用户列表，需要在 PG 集群层面进行定义。默认值为：`[]` 空列表。

每一个数组元素都是一个 [用户/角色](PGSQL-USER) 定义，例如：

```yaml
- name: dbuser_meta               # 必需，`name` 是用户定义的唯一必选字段
  password: DBUser.Meta           # 可选，密码，可以是 scram-sha-256 哈希字符串或明文
  login: true                     # 可选，默认情况下可以登录
  superuser: false                # 可选，默认为 false，是超级用户吗？
  createdb: false                 # 可选，默认为 false，可以创建数据库吗？
  createrole: false               # 可选，默认为 false，可以创建角色吗？
  inherit: true                   # 可选，默认情况下，此角色可以使用继承的权限吗？
  replication: false              # 可选，默认为 false，此角色可以进行复制吗？
  bypassrls: false                # 可选，默认为 false，此角色可以绕过行级安全吗？
  pgbouncer: true                 # 可选，默认为 false，将此用户添加到 pgbouncer 用户列表吗？（使用连接池的生产用户应该显式定义为 true）
  connlimit: -1                   # 可选，用户连接限制，默认 -1 禁用限制
  expire_in: 3650                 # 可选，此角色过期时间：从创建时 + n天计算（优先级比 expire_at 更高）
  expire_at: '2030-12-31'         # 可选，此角色过期的时间点，使用 YYYY-MM-DD 格式的字符串指定一个特定日期（优先级没 expire_in 高）
  comment: pigsty admin user      # 可选，此用户/角色的说明与备注字符串
  roles: [dbrole_admin]           # 可选，默认角色为：dbrole_{admin,readonly,readwrite,offline}
  parameters: {}                  # 可选，使用 `ALTER ROLE SET` 针对这个角色，配置角色级的数据库参数
  pool_mode: transaction          # 可选，默认为 transaction 的 pgbouncer 池模式，用户级别
  pool_connlimit: -1              # 可选，用户级别的最大数据库连接数，默认 -1 禁用限制
  search_path: public             # 可选，根据 postgresql 文档的键值配置参数（例如：使用 pigsty 作为默认 search_path）
```





### `pg_databases`

参数名称： `pg_databases`， 类型： `database[]`， 层次：`C`

PostgreSQL 业务数据库列表，需要在 PG 集群层面进行定义。默认值为：`[]` 空列表。

每一个数组元素都是一个 [业务数据库](PGSQL-DB) 定义，例如：

```yaml
- name: meta                      # 必选，`name` 是数据库定义的唯一必选字段
  baseline: cmdb.sql              # 可选，数据库 sql 的基线定义文件路径（ansible 搜索路径中的相对路径，如 files/）
  pgbouncer: true                 # 可选，是否将此数据库添加到 pgbouncer 数据库列表？默认为 true
  schemas: [pigsty]               # 可选，要创建的附加模式，由模式名称字符串组成的数组
  extensions:                     # 可选，要安装的附加扩展： 扩展对象的数组
    - { name: postgis , schema: public }  # 可以指定将扩展安装到某个模式中，也可以不指定（不指定则安装到 search_path 首位模式中）
    - { name: timescaledb }               # 例如有的扩展会创建并使用固定的模式，就不需要指定模式。
  comment: pigsty meta database   # 可选，数据库的说明与备注信息
  owner: postgres                 # 可选，数据库所有者，默认为 postgres
  template: template1             # 可选，要使用的模板，默认为 template1，目标必须是一个模板数据库
  encoding: UTF8                  # 可选，数据库编码，默认为 UTF8（必须与模板数据库相同）
  locale: C                       # 可选，数据库地区设置，默认为 C（必须与模板数据库相同）
  lc_collate: C                   # 可选，数据库 collate 排序规则，默认为 C（必须与模板数据库相同），没有理由不建议更改。
  lc_ctype: C                     # 可选，数据库 ctype 字符集，默认为 C（必须与模板数据库相同）
  tablespace: pg_default          # 可选，默认表空间，默认为 'pg_default'
  allowconn: true                 # 可选，是否允许连接，默认为 true。显式设置 false 将完全禁止连接到此数据库
  revokeconn: false               # 可选，撤销公共连接权限。默认为 false，设置为 true 时，属主和管理员之外用户的 CONNECT 权限会被回收
  register_datasource: true       # 可选，是否将此数据库注册到 grafana 数据源？默认为 true，显式设置为 false 会跳过注册
  connlimit: -1                   # 可选，数据库连接限制，默认为 -1 ，不限制，设置为正整数则会限制连接数。
  pool_auth_user: dbuser_meta     # 可选，连接到此 pgbouncer 数据库的所有连接都将使用此用户进行验证（启用 pgbouncer_auth_query 才有用）
  pool_mode: transaction          # 可选，数据库级别的 pgbouncer 池化模式，默认为 transaction
  pool_size: 64                   # 可选，数据库级别的 pgbouncer 默认池子大小，默认为 64
  pool_size_reserve: 32           # 可选，数据库级别的 pgbouncer 池子保留空间，默认为 32，当默认池子不够用时，最多再申请这么多条突发连接。
  pool_size_min: 0                # 可选，数据库级别的 pgbouncer 池的最小大小，默认为 0
  pool_max_db_conn: 100           # 可选，数据库级别的最大数据库连接数，默认为 100
```

在每个数据库定义对象中，只有 `name` 是必选字段，其他的字段都是可选项。







### `pg_services`

参数名称： `pg_services`， 类型： `service[]`， 层次：`C`

PostgreSQL 服务列表，需要在 PG 集群层面进行定义。默认值为：`[]` ，空列表。

用于在数据库集群层面定义额外的服务，数组中的每一个对象定义了一个[服务](PGSQL-SVC#定义服务)，一个完整的服务定义样例如下：


```yaml
- name: standby                   # 必选，服务名称，最终的 svc 名称会使用 `pg_cluster` 作为前缀，例如：pg-meta-standby
  port: 5435                      # 必选，暴露的服务端口（作为 kubernetes 服务节点端口模式）
  ip: "*"                         # 可选，服务绑定的 IP 地址，默认情况下为所有 IP 地址
  selector: "[]"                  # 必选，服务成员选择器，使用 JMESPath 来筛选配置清单
  backup: "[? pg_role == `primary`]"  # 可选，服务成员选择器（备份），也就是当默认选择器选中的实例都宕机后，服务才会由这里选中的实例成员来承载
  dest: default                   # 可选，目标端口，default|postgres|pgbouncer|<port_number>，默认为 'default'，Default的意思就是使用 pg_default_service_dest 的取值来最终决定
  check: /sync                    # 可选，健康检查 URL 路径，默认为 /，这里使用 Patroni API：/sync ，只有同步备库和主库才会返回 200 健康状态码 
  maxconn: 5000                   # 可选，允许的前端连接最大数，默认为5000
  balance: roundrobin             # 可选，haproxy 负载均衡算法（默认为 roundrobin，其他选项：leastconn）
  options: 'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'
```

请注意，本参数用于在集群层面添加额外的服务。如果您想在全局定义所有 PostgreSQL 数据库都要提供的服务，可以使用 [`pg_default_services`](#pg_default_services) 参数。 





### `pg_hba_rules`

参数名称： `pg_hba_rules`， 类型： `hba[]`， 层次：`C`

数据库集群/实例的客户端IP黑白名单规则。默认为：`[]` 空列表。

对象数组，每一个对象都代表一条规则， [hba](PGSQL-HBA#定义hba) 规则对象的定义形式如下：

```yaml
- title: allow intranet password access
  role: common
  rules:
    - host   all  all  10.0.0.0/8      md5
    - host   all  all  172.16.0.0/12   md5
    - host   all  all  192.168.0.0/16  md5
```

* `title`： 规则的标题名称，会被渲染为 HBA 文件中的注释。
* `rules`：规则数组，每个元素是一条标准的 HBA 规则字符串。
* `role`：规则的应用范围，哪些实例角色会启用这条规则？
  * `common`：对于所有实例生效
  * `primary`, `replica`,`offline`： 只针对特定的角色 [`pg_role`](#pg_role) 实例生效。
  * 特例：`role: 'offline'` 的规则除了会应用在 `pg_role : offline` 的实例上，对于带有 [`pg_offline_query`](#pg_offline_query) 标记的实例也生效。

除了上面这种原生 HBA 规则定义形式，Pigsty 还提供了另外一种更为简便的别名形式：

```yaml
- addr: 'intra'    # world|intra|infra|admin|local|localhost|cluster|<cidr>
  auth: 'pwd'      # trust|pwd|ssl|cert|deny|<official auth method>
  user: 'all'      # all|${dbsu}|${repl}|${admin}|${monitor}|<user>|<group>
  db: 'all'        # all|replication|....
  rules: []        # raw hba string precedence over above all
  title: allow intranet password access
```

[`pg_default_hba_rules`](#pg_default_hba_rules) 与本参数基本类似，但它是用于定义全局的 HBA 规则，而本参数通常用于定制某个集群/实例的 HBA 规则。







### `pgb_hba_rules`

参数名称： `pgb_hba_rules`， 类型： `hba[]`， 层次：`C`

Pgbouncer 业务HBA规则，默认值为： `[]`， 空数组。

此参数与 [`pg_hba_rules`](#pg_hba_rules) 基本类似，都是 [hba](PGSQL-HBA#define-hba) 规则对象的数组，区别在于本参数是为 Pgbouncer 准备的。

[`pgb_default_hba_rules`](#pgb_default_hba_rules) 与本参数基本类似，但它是用于定义全局连接池 HBA 规则，而本参数通常用于定制某个连接池集群/实例的 HBA 规则。






### `pg_replication_username`

参数名称： `pg_replication_username`， 类型： `username`， 层次：`G`

PostgreSQL 物理复制用户名，默认使用 `replicator`，不建议修改此参数。






### `pg_replication_password`

参数名称： `pg_replication_password`， 类型： `password`， 层次：`G`

PostgreSQL 物理复制用户密码，默认值为：`DBUser.Replicator`。

> 警告：请在生产环境中修改此密码！





### `pg_admin_username`

参数名称： `pg_admin_username`， 类型： `username`， 层次：`G`

PostgreSQL / Pgbouncer 管理员名称，默认为：`dbuser_dba`。

这是全局使用的数据库管理员，具有数据库的 Superuser 权限与连接池的流量管理权限，请务必控制使用范围。





### `pg_admin_password`

参数名称： `pg_admin_password`， 类型： `password`， 层次：`G`

PostgreSQL / Pgbouncer 管理员密码，默认为： `DBUser.DBA`。

> 警告：请在生产环境中修改此密码！





### `pg_monitor_username`

参数名称： `pg_monitor_username`， 类型： `username`， 层次：`G`

PostgreSQL/Pgbouncer 监控用户名，默认为：`dbuser_monitor`。

这是一个用于监控的数据库/连接池用户，不建议修改此用户名。

但如果您的现有数据库使用了不同的监控用户，可以在指定监控目标时使用此参数传入使用的监控用户名。






### `pg_monitor_password`

参数名称： `pg_monitor_password`， 类型： `password`， 层次：`G`

PostgreSQL/Pgbouncer 监控用户使用的密码，默认为：`DBUser.Monitor`。

请尽可能不要在密码中使用 `@:/` 这些容易与 URL 分隔符混淆的字符，减少不必要的麻烦。

> 警告：请在生产环境中修改此密码！




### `pg_dbsu_password`

参数名称： `pg_dbsu_password`， 类型： `password`， 层次：`G/C`

PostgreSQL [`pg_dbsu`](#pg_dbsu) 超级用户密码，默认是空字符串，即不为其设置密码。

我们不建议为 dbsu 配置密码登陆，这会增大攻击面。例外情况是：[`pg_mode`](#pg_mode) = `citus`，这时候需要为每个分片集群的 dbsu 配置密码，以便在分片集群内部进行连接。







------------------------------

## `PG_INSTALL`

本节负责安装 PostgreSQL 及其扩展。如果您希望安装不同大版本与扩展插件，修改 [`pg_version`](#pg_version) 与 [`pg_extensions`](#pg_extensions) 即可，不过请注意，并不是所有扩展都在所有大版本可用。


```yaml
pg_dbsu: postgres                 # os 数据库超级用户名称，默认为 postgres，最好不要更改
pg_dbsu_uid: 26                   # os 数据库超级用户 uid 和 gid，默认为 26，适用于默认的 postgres 用户和组
pg_dbsu_sudo: limit               # 数据库超级用户 sudo 权限，可选 none,limit,all,nopass。默认为 limit
pg_dbsu_home: /var/lib/pgsql      # postgresql 主目录，默认为 `/var/lib/pgsql`
pg_dbsu_ssh_exchange: true        # 是否在相同的 pgsql 集群中交换 postgres 数据库超级用户的 ssh 密钥
pg_version: 15                    # 要安装的 postgres 主版本，默认为 15
pg_bin_dir: /usr/pgsql/bin        # postgres 二进制目录，默认为 `/usr/pgsql/bin`
pg_log_dir: /pg/log/postgres      # postgres 日志目录，默认为 `/pg/log/postgres`
pg_packages:                      # 要安装的 pg 包，`${pg_version}` 将被替换
  - postgresql-*-${pg_version}
  - patroni pgbouncer pgbackrest pg-exporter pgbadger vip-manager
  - postgresql-${pg_version}-repack postgresql-${pg_version}-wal2json
pg_extensions:                    # 要安装的 pg 扩展，`${pg_version}` 将被替换
  - postgresql-${pg_version}-postgis* timescaledb-2-postgresql-${pg_version} postgresql-${pg_version}-pgvector postgresql-${pg_version}-citus-12.1
```



### `pg_dbsu`

参数名称： `pg_dbsu`， 类型： `username`， 层次：`C`

PostgreSQL 使用的操作系统 dbsu 用户名， 默认为 `postgres`，改这个用户名是不太明智的。

不过在特定情况下，您可能会使用到不同于 `postgres` 的用户名，例如在安装配置 Greenplum / MatrixDB 时，需要使用 `gpadmin` / `mxadmin` 作为相应的操作系统超级用户。





### `pg_dbsu_uid`

参数名称： `pg_dbsu_uid`， 类型： `int`， 层次：`C`

操作系统数据库超级用户的 uid 和 gid，`26` 是 PGDG RPM 默认的 postgres 用户 UID/GID。

对于 Debian/Ubuntu 系统来说，没有默认值，所以您最好指定一个合适的值，比如 `543`







### `pg_dbsu_sudo`

参数名称： `pg_dbsu_sudo`， 类型： `enum`， 层次：`C`

数据库超级用户的 sudo 权限，可以是 `none`、`limit`、`all` 或 `nopass`。默认为 `limit`

- `none`: 无 Sudo 权限
- `limit`: 有限的 sudo 权限，用于执行与数据库相关的组件的 `systemctl` 命令（默认选项）。
- `all`: 完全的 `sudo` 权限，需要密码。
- `nopass`: 不需要密码的完全 `sudo` 权限（不推荐）。

- 默认值为 `limit`，只允许执行 `sudo systemctl <start|stop|reload> <postgres|patroni|pgbouncer|...> `。




### `pg_dbsu_home`

参数名称： `pg_dbsu_home`， 类型： `path`， 层次：`C`

postgresql 主目录，默认为 `/var/lib/pgsql`，与官方的 pgdg RPM 保持一致。






### `pg_dbsu_ssh_exchange`

参数名称： `pg_dbsu_ssh_exchange`， 类型： `bool`， 层次：`C`

是否在同一 PostgreSQL 集群中交换操作系统 dbsu 的 ssh 密钥？

默认值为 `true`，意味着同一集群中的数据库超级用户可以互相 ssh 访问。






### `pg_version`

参数名称： `pg_version`， 类型： `enum`， 层次：`C`

要安装的 postgres 主版本，默认为 `15`。

请注意，PostgreSQL 的物理流复制不能跨主要版本，因此最好不要在实例级别上配置此项。

您可以使用 [`pg_packages`](#pg_packages) 和 [`pg_extensions`](#pg_extensions) 中的参数来为特定的 PG 大版本安装不同的软件包与扩展。





### `pg_bin_dir`

参数名称： `pg_bin_dir`， 类型： `path`， 层次：`C`

PostgreSQL 二进制程序目录，默认为 `/usr/pgsql/bin`。

默认值是在安装过程中手动创建的软链接，指向安装的特定的 Postgres 版本目录。

例如 `/usr/pgsql -> /usr/pgsql-15`。在 Ubuntu/Debian 上则指向 `/usr/lib/postgresql/15/bin`。

更多详细信息，请查看 [PGSQL 文件结构](FHS#postgres-fhs)。





### `pg_log_dir`

参数名称： `pg_log_dir`， 类型： `path`， 层次：`C`

PostgreSQL 日志目录，默认为：`/pg/log/postgres`，[Promtail](#promtail) 会使用此变量收集 PostgreSQL 日志。

请注意，如果日志目录 [`pg_log_dir`](#pg_log_dir) 以数据库目录 [`pg_data`](#pg_data) 作为前缀，则不会显式创建（数据库目录初始化时自动创建）。






### `pg_packages`

参数名称： `pg_packages`， 类型： `string[]`， 层次：`C`

要安装的 PostgreSQL 软件包（rpm/deb），包名中的 `${pg_version}` 将被替换为具体的大版本号： [`pg_version`](#pg_version) 的取值。

默认情况下安装的软件包为：

```yaml
pg_packages:                      # pg packages to be installed, `${pg_version}` will be replaced
  - postgresql${pg_version}*
  - patroni pgbouncer pgbackrest pg_exporter pgbadger vip-manager patroni-etcd             # pgdg common tools
  - pg_repack_${pg_version}* wal2json_${pg_version}* passwordcheck_cracklib_${pg_version}* # important extensions
```

对于 Ubuntu/Debian 来说，合适的取值需要显式地在配置文件中指定：

```yaml
pg_packages:                      # pg packages to be installed, `${pg_version}` will be replaced
  - postgresql-*-${pg_version}
  - patroni pgbouncer pgbackrest pg-exporter pgbadger vip-manager
  - postgresql-${pg_version}-repack postgresql-${pg_version}-wal2json
```






### `pg_extensions`

参数名称： `pg_extensions`， 类型： `string[]`， 层次：`C`

要安装的 PostgreSQL 扩展，`${pg_version}` 将被替换为具体的PG大版本号： [`pg_version`](#pg_version)。

Pigsty 默认会为所有数据库实例安装以下扩展：`postgis`、`timescaledb`、`pgvector`、`pg_repack`、`wal2json` 和 `passwordcheck_cracklib`。

```yaml
pg_extensions: # citus & hydra are exclusive
  - postgis34_${pg_version}* timescaledb-2-postgresql-${pg_version}* pgvector_${pg_version}*
```

对于 Ubuntu/Debian 来说，合适的取值需要显式地在配置文件中指定：

```yaml
pg_extensions:                    # pg extensions to be installed, `${pg_version}` will be replaced
  - postgresql-${pg_version}-postgis* timescaledb-2-postgresql-${pg_version} postgresql-${pg_version}-pgvector postgresql-${pg_version}-citus-12.1
```

请注意，并不是所有扩展都在所有大版本可用，但 Pigsty 确保重要的扩展 `wal2json`，`pg_repack` 和 `passwordcheck_cracklib`（仅限EL） 在所有PG大版本上都可用。




------------------------------

## `PG_BOOTSTRAP`


使用 Patroni 引导拉起 PostgreSQL 集群，并设置 1:1 对应的 Pgbouncer 连接池。

它还会使用 [`PG_PROVISION`](#pg_provision) 中定义的默认角色、用户、权限、模式、扩展来初始化数据库集群


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

参数名称： `pg_safeguard`， 类型： `bool`， 层次：`G/C/A`

是否防止清除正在运行的Postgres实例？默认为：`false`。

如果启用，[`pgsql.yml`](PGSQL-PLAYBOOK#pgsqlyml) 和 [`pgsql-rm.yml`](PGSQL-PLAYBOOK#pgsql-rmyml) 在检测到任何正在运行的postgres实例时将立即中止。




### `pg_clean`

参数名称： `pg_clean`， 类型： `bool`， 层次：`G/C/A`

在 PostgreSQL 初始化期间清除现有的 PG 实例吗？默认为：`true`。

默认值为`true`，在 [`pgsql.yml`](PGSQL-PLAYBOOK#pgsqlyml) 初始化期间它将清除现有的postgres实例，这使得playbook具有幂等性。

如果设置为 `false`，[`pgsql.yml`](PGSQL-PLAYBOOK#pgsqlyml) 会在遇到正在运行的 PostgreSQL 实例时中止。而 [`pgsql-rm.yml`](PGSQL-PLAYBOOK#pgsql-rmyml) 将不会删除 PostgreSQL 的数据目录（只会停止服务器）。





### `pg_data`

参数名称： `pg_data`， 类型： `path`， 层次：`C`

Postgres 数据目录，默认为 `/pg/data`。

这是一个指向底层实际数据目录的符号链接，在多处被使用，请不要修改它。参阅 [PGSQL文件结构](FHS) 获取详细信息。 





### `pg_fs_main`

参数名称： `pg_fs_main`， 类型： `path`， 层次：`C`

PostgreSQL 主数据盘的挂载点/文件系统路径，默认为`/data`。

默认值：`/data`，它将被用作 PostgreSQL 主数据目录（`/data/postgres`）的父目录。

建议使用 NVME SSD 作为 PostgreSQL 主数据存储，Pigsty默认为SSD存储进行了优化，但是也支持HDD。

您可以更改[`pg_storage_type`](#pg_storage_type)为`HDD`以针对HDD存储进行优化。





### `pg_fs_bkup`

参数名称： `pg_fs_bkup`， 类型： `path`， 层次：`C`

PostgreSQL 备份数据盘的挂载点/文件系统路径，默认为`/data/backup`。

如果您使用的是默认的 [`pgbackrest_method`](#pgbackrest_method) = `local`，建议为备份存储使用一个单独的磁盘。

备份磁盘应足够大，以容纳所有的备份，至少足以容纳3个基础备份+2天的WAL归档。 通常容量不是什么大问题，因为您可以使用便宜且大的机械硬盘作为备份盘。

建议为备份存储使用一个单独的磁盘，否则 Pigsty 将回退到主数据磁盘，并占用主数据盘的容量与IO。





### `pg_storage_type`

参数名称： `pg_storage_type`， 类型： `enum`， 层次：`C`

PostgreSQL 数据存储介质的类型：`SSD`或`HDD`，默认为`SSD`。

默认值：`SSD`，它会影响一些调优参数，如 `random_page_cost` 和 `effective_io_concurrency` 。




### `pg_dummy_filesize`

参数名称： `pg_dummy_filesize`， 类型： `size`， 层次：`C`

`/pg/dummy`的大小，默认值为`64MiB`，用于紧急使用的64MB磁盘空间。

当磁盘已满时，删除占位符文件可以为紧急使用释放一些空间，建议生产使用至少`8GiB`。





### `pg_listen`

参数名称： `pg_listen`， 类型： `ip`， 层次：`C`

PostgreSQL / Pgbouncer 的监听地址，默认为`0.0.0.0`（所有ipv4地址）。

您可以在此变量中使用占位符，例如：`'${ip},${lo}'`或`'${ip},${vip},${lo}'`：

- `${ip}`：转换为 `inventory_hostname`，它是配置清单中定义的首要内网IP地址。
- `${vip}`：如果启用了[`pg_vip_enabled`](#pg_vip_enabled)，将使用[`pg_vip_address`](#pg_vip_address)的主机部分。
- `${lo}`：将替换为`127.0.0.1`

对于高安全性要求的生产环境，建议限制监听的IP地址。




### `pg_port`

参数名称： `pg_port`， 类型： `port`， 层次：`C`

PostgreSQL 服务器监听的端口，默认为 `5432`。





### `pg_localhost`

参数名称： `pg_localhost`， 类型： `path`， 层次：`C`

本地主机连接 PostgreSQL 使用的 Unix套接字目录，默认值为`/var/run/postgresql`。

PostgreSQL 和 Pgbouncer 本地连接的Unix套接字目录，[`pg_exporter`](#pg_exporter) 和 patroni 都会优先使用 Unix 套接字访问 PostgreSQL。




### `pg_namespace`

参数名称： `pg_namespace`， 类型： `path`， 层次：`C`

在 [etcd](#etcd) 中使用的顶级命名空间，由 patroni 和 vip-manager 使用，默认值是：`/pg`，不建议更改。





### `patroni_enabled`

参数名称： `patroni_enabled`， 类型： `bool`， 层次：`C`

是否启用 Patroni ？默认值为：`true`。

如果禁用，则在初始化期间不会创建Postgres集群。Pigsty将跳过拉起 patroni的任务，当试图向现有的postgres实例添加一些组件时，可以使用此参数。




### `patroni_mode`

参数名称： `patroni_mode`， 类型： `enum`， 层次：`C`

Patroni 工作模式：`default`，`pause`，`remove`。默认值：`default`。

- `default`：正常使用 Patroni 引导 PostgreSQL 集群
- `pause`：与`default`相似，但在引导后进入维护模式
- `remove`：使用Patroni初始化集群，然后删除Patroni并使用原始 PostgreSQL。




### `patroni_port`

参数名称： `patroni_port`， 类型： `port`， 层次：`C`

patroni监听端口，默认为`8008`，不建议更改。

Patroni API服务器在此端口上监听健康检查和API请求。




### `patroni_log_dir`

参数名称： `patroni_log_dir`， 类型： `path`， 层次：`C`

patroni日志目录，默认为`/pg/log/patroni`，由[`promtail`](#promtail)收集。







### `patroni_ssl_enabled`

参数名称： `patroni_ssl_enabled`， 类型： `bool`， 层次：`G`

使用SSL保护patroni RestAPI通信吗？默认值为`false`。

此参数是一个全局标志，只能在部署之前预先设置。因为如果为 patroni 启用了SSL，您将必须使用 HTTPS 而不是 HTTP 执行健康检查、获取指标，调用API。





### `patroni_watchdog_mode`

参数名称： `patroni_watchdog_mode`， 类型： `string`， 层次：`C`

patroni看门狗模式：`automatic`，`required`，`off`，默认值为 `off`。

在主库故障的情况下，Patroni 可以使用[看门狗](https://patroni.readthedocs.io/en/latest/watchdog.html) 来强制关机旧主库节点以避免脑裂。

- `off`：不使用`看门狗`。完全不进行 Fencing （默认行为）
- `automatic`：如果内核启用了`softdog`模块并且看门狗属于dbsu，则启用 `watchdog`。
- `required`：强制启用 `watchdog`，如果`softdog`不可用则拒绝启动 Patroni/PostgreSQL。

默认值为`off`，您不应该在 Infra节点 启用看门狗，数据一致性优先于可用性的关键系统，特别是与钱有关的业务集群可以考虑打开此选项。

请注意，如果您的所有访问流量都使用 HAproxy 健康检查[服务接入](PGSQL-SVC#接入服务)，正常是不存在脑裂风险的。





### `patroni_username`

参数名称： `patroni_username`， 类型： `username`， 层次：`C`

Patroni REST API 用户名，默认为`postgres`，与[`patroni_password`](#patroni_password) 配对使用。

Patroni的危险 REST API （比如重启集群）由额外的用户名/密码保护，查看[配置集群](PGSQL-ADMIN#配置集群)和[Patroni RESTAPI](https://patroni.readthedocs.io/en/latest/rest_api.html)以获取详细信息。





### `patroni_password`

参数名称： `patroni_password`， 类型： `password`， 层次：`C`

Patroni REST API 密码，默认为`Patroni.API`。

> 警告：务必生产环境中修改此参数！





### `patroni_citus_db`

参数名称： `patroni_citus_db`， 类型： `string`， 层次：`C`

由 Patroni 管理的 citus 业务数据库，默认为 `postgres`。

Patroni 3.0的原生citus支持，将为citus指定一个由patroni自身创建并管理的数据库。



### `pg_conf`

参数名称： `pg_conf`， 类型： `enum`， 层次：`C`

配置模板：`{oltp,olap,crit,tiny}.yml`，默认为`oltp.yml`。

- `tiny.yml`：为小节点、虚拟机、小型演示优化（1-8核，1-16GB）
- `oltp.yml`：为OLTP工作负载和延迟敏感应用优化（4C8GB+）（默认模板）
- `olap.yml`：为OLAP工作负载和吞吐量优化（4C8G+）
- `crit.yml`：为数据一致性和关键应用优化（4C8G+）

默认值：`oltp.yml`，但是[配置](INSTALL#配置)程序将在当前节点为小节点时将此值设置为 `tiny.yml`。

您可以拥有自己的模板，只需将其放在`templates/<mode>.yml`下，并将此值设置为模板名称即可使用。




### `pg_max_conn`

参数名称： `pg_max_conn`， 类型： `int`， 层次：`C`

PostgreSQL 服务器最大连接数。你可以选择一个介于 50 到 5000 之间的值，或使用 `auto` 选择推荐值。

默认值为 `auto`，会根据 [`pg_conf`](#pg_conf) 和 [`pg_default_service_dest`](#pg_default_service_dest) 来设定最大连接数。

- tiny: 100
- olap: 200
- oltp: 200 (pgbouncer) / 1000 (postgres)
    - pg_default_service_dest = pgbouncer : 200
    - pg_default_service_dest = postgres : 1000
- crit: 200 (pgbouncer) / 1000 (postgres)
    - pg_default_service_dest = pgbouncer : 200
    - pg_default_service_dest = postgres : 1000

不建议将此值设定为超过 5000，否则你还需要手动增加 haproxy 服务的连接限制。

Pgbouncer 的事务池可以缓解过多的 OLTP 连接问题，因此默认情况下不建议设置很大的连接数。

对于 OLAP 场景， [`pg_default_service_dest`](#pg_default_service_dest) 修改为 `postgres` 可以绕过连接池。





### `pg_shared_buffer_ratio`

参数名称： `pg_shared_buffer_ratio`， 类型： `float`， 层次：`C`

Postgres 共享缓冲区内存比例，默认为 `0.25`，正常范围在 `0.1`~`0.4` 之间。

默认值：`0.25`，意味着节点内存的 25% 将被用作 PostgreSQL 的分片缓冲区。如果您想为 PostgreSQL 启用大页，那么此参数值应当适当小于 [`node_hugepage_ratio`](#node_hugepage_ratio)。 

将此值设定为大于 0.4（40%）通常不是好主意，但在极端情况下可能有用。

注意，共享缓冲区只是 PostgreSQL 中共享内存的一部分，要计算总共享内存，使用 `show shared_memory_size_in_huge_pages;`。





### `pg_rto`

参数名称： `pg_rto`， 类型： `int`， 层次：`C`

以秒为单位的恢复时间目标（RTO）。这将用于计算 Patroni 的 TTL 值，默认为 `30` 秒。

如果主实例在这么长时间内失踪，将触发新的领导者选举，此值并非越低越好，它涉及到利弊权衡：

减小这个值可以减少集群故障转移期间的不可用时间（无法写入）， 但会使集群对短期网络抖动更加敏感，从而增加误报触发故障转移的几率。

您需要根据网络状况和业务约束来配置这个值，在故障几率和故障影响之间做出**权衡**， 默认值是 `30s`，它将影响以下的 Patroni 参数：

```yaml
# 获取领导者租约的 TTL（以秒为单位）。将其视为启动自动故障转移过程之前的时间长度。默认值：30
ttl: {{ pg_rto }}

# 循环将休眠的秒数。默认值：10，这是 patroni 检查循环间隔
loop_wait: {{ (pg_rto / 3)|round(0, 'ceil')|int }}

# DCS 和 PostgreSQL 操作重试的超时时间（以秒为单位）。比这短的 DCS 或网络问题不会导致 Patroni 降级领导。默认值：10
retry_timeout: {{ (pg_rto / 3)|round(0, 'ceil')|int }}

# 主实例在触发故障转移之前允许从故障中恢复的时间（以秒为单位），最大 RTO：2 倍循环等待 + primary_start_timeout
primary_start_timeout: {{ (pg_rto / 3)|round(0, 'ceil')|int }}
```




### `pg_rpo`

参数名称： `pg_rpo`， 类型： `int`， 层次：`C`

以字节为单位的恢复点目标（RPO），默认值：`1048576`。

默认为 1MiB，这意味着在故障转移期间最多可以容忍 1MiB 的数据丢失。

当主节点宕机并且所有副本都滞后时，你必须做出一个艰难的选择，**在可用性和一致性之间进行权衡**：

- 提升一个从库成为新的主库，并尽快将系统恢复服务，但要付出可接受的数据丢失代价（例如，少于 1MB）。
- 等待主库重新上线（可能永远不会），或人工干预以避免任何数据丢失。

你可以使用 `crit.yml` [conf](#pg_conf) 模板来确保在故障转移期间没有数据丢失，但这会牺牲一些性能。





### `pg_libs`

参数名称： `pg_libs`， 类型： `string`， 层次：`C`

预加载的动态共享库，默认为 `pg_stat_statements,auto_explain`，这是两个 PostgreSQL 自带的扩展，强烈建议启用。

对于现有集群，您可以直接[配置集群](PGSQL-ADMIN#配置集群)的 `shared_preload_libraries` 参数并应用生效。

如果您想使用 TimescaleDB 或 Citus 扩展，您需要将 `timescaledb` 或 `citus` 添加到此列表中。`timescaledb` 和 `citus` 应当放在这个列表的最前面，例如：

```
citus,timescaledb,pg_stat_statements,auto_explain
```

其他需要动态加载的扩展也可以添加到这个列表中，例如 `pg_cron`， `pgml` 等，通常 `citus` 和 `timescaledb` 有着最高的优先级，应该添加到列表的最前面。






### `pg_delay`

参数名称： `pg_delay`， 类型： `interval`， 层次：`I`

延迟备库复制延迟，默认值：`0`。

如果此值被设置为一个正值，备用集群主库在应用 WAL 变更之前将被延迟这个时间。设置为 `1h` 意味着该集群中的数据将始终滞后原集群一个小时。

查看 [延迟备用集群](PGSQL-CONF#延迟集群) 以获取详细信息。





### `pg_checksum`

参数名称： `pg_checksum`， 类型： `bool`， 层次：`C`

为 PostgreSQL 集群启用数据校验和吗？默认值是 `false`，不启用。

这个参数只能在 PGSQL 部署之前设置（但你可以稍后手动启用它）。

如果使用 [`pg_conf`](#pg_conf) `crit.yml` 模板，无论此参数如何，都会始终启用数据校验和，以确保数据完整性。





### `pg_pwd_enc`

参数名称： `pg_pwd_enc`， 类型： `enum`， 层次：`C`

密码加密算法：`md5` 或 `scram-sha-256`，默认值：`scram-sha-256`。

前者已经不再安全，如果你与旧客户端有兼容性问题，你可以将其设置为 `md5`。




### `pg_encoding`

参数名称： `pg_encoding`， 类型： `enum`， 层次：`C`

数据库集群编码，默认为 `UTF8`。

不建议使用其他非 `UTF8` 系编码。




### `pg_locale`

参数名称： `pg_locale`， 类型： `enum`， 层次：`C`

数据库集群编码，默认为 `UTF8`。

数据库集群本地化规则集，默认为 `UTF8`。




### `pg_lc_collate`

参数名称： `pg_lc_collate`， 类型： `enum`， 层次：`C`

数据库集群本地化排序规则，默认为 `C`。

除非您知道自己在做什么，否则不建议修改集群级别的本地排序规则设置。





### `pg_lc_ctype`

参数名称： `pg_lc_ctype`， 类型： `enum`， 层次：`C`

数据库字符集 CTYPE，默认为 `en_US.UTF8`。






### `pgbouncer_enabled`

参数名称： `pgbouncer_enabled`， 类型： `bool`， 层次：`C`

默认值为 `true`，如果禁用，将不会在 PGSQL节点上配置连接池 Pgbouncer。






### `pgbouncer_port`

参数名称： `pgbouncer_port`， 类型： `port`， 层次：`C`

Pgbouncer 监听端口，默认为 `6432`。






### `pgbouncer_log_dir`

参数名称： `pgbouncer_log_dir`， 类型： `path`， 层次：`C`

Pgbouncer 日志目录，默认为 `/pg/log/pgbouncer`，日志代理 [promtail](#promtail) 会根据此参数收集 Pgbouncer 日志。






### `pgbouncer_auth_query`

参数名称： `pgbouncer_auth_query`， 类型： `bool`， 层次：`C`

是否允许 Pgbouncer 查询 PostgreSQL，以允许未显式列出的用户通过连接池访问 PostgreSQL？默认值是 `false`。

如果启用，pgbouncer 用户将使用 `SELECT username, password FROM monitor.pgbouncer_auth($1)` 对 postgres 数据库进行身份验证，否则，只有带有 `pgbouncer: true` 的业务用户才被允许连接到 Pgbouncer 连接池。






### `pgbouncer_poolmode`

参数名称： `pgbouncer_poolmode`， 类型： `enum`， 层次：`C`

Pgbouncer 连接池池化模式：`transaction`,`session`,`statement`，默认为 `transaction`。

- `session`：会话级池化，具有最佳的功能兼容性。
- `transaction`：事务级池化，具有更好的性能（许多小连接），可能会破坏某些会话级特性，如`NOTIFY/LISTEN` 等...
- `statements`：语句级池化，用于简单的只读查询。

如果您的应用出现功能兼容性问题，可以考虑修改此参数为 `session`。




### `pgbouncer_sslmode`

参数名称： `pgbouncer_sslmode`， 类型： `enum`， 层次：`C`

Pgbouncer 客户端 ssl 模式，默认为 `disable`。

注意，启用 SSL 可能会对你的 pgbouncer 产生巨大的性能影响。

- `disable`：如果客户端请求 TLS 则忽略（默认）
- `allow`：如果客户端请求 TLS 则使用。如果没有则使用纯TCP。不验证客户端证书。
- `prefer`：与 allow 相同。
- `require`：客户端必须使用 TLS。如果没有则拒绝客户端连接。不验证客户端证书。
- `verify-ca`：客户端必须使用有效的客户端证书的TLS。
- `verify-full`：与 verify-ca 相同。







------------------------------

## `PG_PROVISION`


如果说 [`PG_BOOTSTRAP`](#pg_bootstrap) 是创建一个新的集群，那么 PG_PROVISION 就是在集群中创建默认的对象，包括：

* [默认角色](PGSQL-ACL#默认角色)
* [默认用户](PGSQL-ACL#默认用户)
* [默认权限](PGSQL-ACL#默认权限)
* [默认HBA规则](PGSQL-HBA#默认hba)
* 默认模式
* 默认扩展



```yaml
pg_provision: true                # 在引导后提供postgres集群
pg_init: pg-init                  # 集群模板的初始化脚本，默认为`pg-init`
pg_default_roles:                 # postgres集群中的默认角色和用户
  - { name: dbrole_readonly  ,login: false ,comment: role for global read-only access     }
  - { name: dbrole_offline   ,login: false ,comment: role for restricted read-only access }
  - { name: dbrole_readwrite ,login: false ,roles: [dbrole_readonly] ,comment: role for global read-write access }
  - { name: dbrole_admin     ,login: false ,roles: [pg_monitor, dbrole_readwrite] ,comment: role for object creation }
  - { name: postgres     ,superuser: true  ,comment: system superuser }
  - { name: replicator ,replication: true  ,roles: [pg_monitor, dbrole_readonly] ,comment: system replicator }
  - { name: dbuser_dba   ,superuser: true  ,roles: [dbrole_admin]  ,pgbouncer: true ,pool_mode: session, pool_connlimit: 16 ,comment: pgsql admin user }
  - { name: dbuser_monitor ,roles: [pg_monitor] ,pgbouncer: true ,parameters: {log_min_duration_statement: 1000 } ,pool_mode: session ,pool_connlimit: 8 ,comment: pgsql monitor user }
pg_default_privileges:            # 管理员用户创建时的默认权限
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
pg_default_schemas: [ monitor ]   # 默认模式
pg_default_extensions:            # 默认扩展
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
pg_reload: true                   # HBA变化后是否重载配置？
pg_default_hba_rules:             # postgres 默认 HBA 规则集
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
pgb_default_hba_rules:            # pgbouncer 默认 HBA 规则集
  - {user: '${dbsu}'    ,db: pgbouncer   ,addr: local     ,auth: peer  ,title: 'dbsu local admin access with os ident'}
  - {user: 'all'        ,db: all         ,addr: localhost ,auth: pwd   ,title: 'allow all user local access with pwd' }
  - {user: '${monitor}' ,db: pgbouncer   ,addr: intra     ,auth: pwd   ,title: 'monitor access via intranet with pwd' }
  - {user: '${monitor}' ,db: all         ,addr: world     ,auth: deny  ,title: 'reject all other monitor access addr' }
  - {user: '${admin}'   ,db: all         ,addr: intra     ,auth: pwd   ,title: 'admin access via intranet with pwd'   }
  - {user: '${admin}'   ,db: all         ,addr: world     ,auth: deny  ,title: 'reject all other admin access addr'   }
  - {user: 'all'        ,db: all         ,addr: intra     ,auth: pwd   ,title: 'allow all user intra access with pwd' }
```


### `pg_provision`

参数名称： `pg_provision`， 类型： `bool`， 层次：`C`

在集群拉起后，完整本节定义的 PostgreSQL 集群置备工作。默认值为`true`。

如果禁用，不会置备 PostgreSQL 集群。对于一些特殊的 "PostgreSQL" 集群，比如 Greenplum，可以关闭此选项跳过置备阶段。




### `pg_init`

参数名称： `pg_init`， 类型： `string`， 层次：`G/C`

用于初始化数据库模板的Shell脚本位置，默认为 `pg-init`，该脚本会被拷贝至`/pg/bin/pg-init`后执行。

该脚本位于 [`roles/pgsql/templates/pg-init`](https://github.com/Vonng/pigsty/blob/master/roles/pgsql/templates/pg-init)

你可以在该脚本中添加自己的逻辑，或者提供一个新的脚本放置在 `templates/` 目录下，并将 `pg_init` 设置为新的脚本名称。使用自定义脚本时请保留现有的初始化逻辑。








### `pg_default_roles`

参数名称： `pg_default_roles`， 类型： `role[]`， 层次：`G/C`

Postgres 集群中的默认角色和用户。

Pigsty有一个内置的角色系统，请查看[PGSQL访问控制：角色系统](PGSQL-ACL#角色系统)了解详情。

```yaml
pg_default_roles:                 # postgres集群中的默认角色和用户
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

参数名称： `pg_default_privileges`， 类型： `string[]`， 层次：`G/C`

每个数据库中的默认权限（`DEFAULT PRIVILEGE`）设置：

```yaml
pg_default_privileges:            # 管理员用户创建时的默认权限
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

Pigsty 基于默认角色系统提供了相应的默认权限设置，请查看[PGSQL访问控制：权限](PGSQL-ACL#默认权限)了解详情。






### `pg_default_schemas`

参数名称： `pg_default_schemas`， 类型： `string[]`， 层次：`G/C`

要创建的默认模式，默认值为：`[ monitor ]`，这将在所有数据库上创建一个`monitor`模式，用于放置各种监控扩展、表、视图、函数。






### `pg_default_extensions`

参数名称： `pg_default_extensions`， 类型： `extension[]`， 层次：`G/C`

要在所有数据库中默认创建启用的扩展列表，默认值：

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

唯一的三方扩展是 `pg_repack`，这对于数据库维护很重要，所有其他扩展都是内置的 PostgreSQL Contrib 扩展插件。

监控相关的扩展默认安装在 `monitor` 模式中，该模式由[`pg_default_schemas`](#pg_default_schemas)创建。





### `pg_reload`

参数名称： `pg_reload`， 类型： `bool`， 层次：`A`

在hba更改后重新加载 PostgreSQL，默认值为`true`

当您想在应用HBA更改之前进行检查时，将其设置为`false`以禁用自动重新加载配置。





### `pg_default_hba_rules`

参数名称： `pg_default_hba_rules`， 类型： `hba[]`， 层次：`G/C`

PostgreSQL 基于主机的认证规则，全局默认规则定义。默认值为：


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

默认值为常见场景提供了足够的安全级别，请查看[PGSQL身份验证](PGSQL-HBA)了解详情。

本参数为 [HBA](PGSQL-HBA#define-hba)规则对象组成的数组，在形式上与 [`pg_hba_rules`](#pg_hba_rules) 完全一致。
建议在全局配置统一的 [`pg_default_hba_rules`](#pg_default_hba_rules)，针对特定集群使用 [`pg_hba_rules`](#pg_hba_rules) 进行额外定制。两个参数中的规则都会依次应用，后者优先级更高。




### `pgb_default_hba_rules`

参数名称： `pgb_default_hba_rules`， 类型： `hba[]`， 层次：`G/C`

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

默认的Pgbouncer HBA规则很简单：

1. 允许从**本地**使用密码登陆
2. 允许从内网网断使用密码登陆

用户可以按照自己的需求进行定制。

本参数在形式上与 [`pgb_hba_rules`](#pgb_hba_rules) 完全一致，建议在全局配置统一的 [`pgb_default_hba_rules`](#pgb_default_hba_rules)，针对特定集群使用 [`pgb_hba_rules`](#pgb_hba_rules) 进行额外定制。两个参数中的规则都会依次应用，后者优先级更高。






------------------------------

## `PG_BACKUP`

本节定义了用于 [pgBackRest](https://pgbackrest.org/) 的变量，它被用于 PGSQL 时间点恢复 PITR 。

查看 [PGSQL 备份 & PITR](PGSQL-PITR) 以获取详细信息。


```yaml
pgbackrest_enabled: true          # 在 pgsql 主机上启用 pgBackRest 吗？
pgbackrest_clean: true            # 初始化时删除 pg 备份数据？
pgbackrest_log_dir: /pg/log/pgbackrest # pgbackrest 日志目录，默认为 `/pg/log/pgbackrest`
pgbackrest_method: local          # pgbackrest 仓库方法：local, minio, [用户定义...]
pgbackrest_repo:                  # pgbackrest 仓库：https://pgbackrest.org/configuration.html#section-repository
  local:                          # 默认使用本地 posix 文件系统的 pgbackrest 仓库
    path: /pg/backup              # 本地备份目录，默认为 `/pg/backup`
    retention_full_type: count    # 按计数保留完整备份
    retention_full: 2             # 使用本地文件系统仓库时，最多保留 3 个完整备份，至少保留 2 个
  minio:                          # pgbackrest 的可选 minio 仓库
    type: s3                      # minio 是与 s3 兼容的，所以使用 s3
    s3_endpoint: sss.pigsty       # minio 端点域名，默认为 `sss.pigsty`
    s3_region: us-east-1          # minio 区域，默认为 us-east-1，对 minio 无效
    s3_bucket: pgsql              # minio 桶名称，默认为 `pgsql`
    s3_key: pgbackrest            # pgbackrest 的 minio 用户访问密钥
    s3_key_secret: S3User.Backup  # pgbackrest 的 minio 用户秘密密钥
    s3_uri_style: path            # 对 minio 使用路径风格的 uri，而不是主机风格
    path: /pgbackrest             # minio 备份路径，默认为 `/pgbackrest`
    storage_port: 9000            # minio 端口，默认为 9000
    storage_ca_file: /etc/pki/ca.crt  # minio ca 文件路径，默认为 `/etc/pki/ca.crt`
    bundle: y                     # 将小文件打包成一个文件
    cipher_type: aes-256-cbc      # 为远程备份仓库启用 AES 加密
    cipher_pass: pgBackRest       # AES 加密密码，默认为 'pgBackRest'
    retention_full_type: time     # 在 minio 仓库上按时间保留完整备份
    retention_full: 14            # 保留过去 14 天的完整备份
```



### `pgbackrest_enabled`

参数名称： `pgbackrest_enabled`， 类型： `bool`， 层次：`C`

是否在 PGSQL 节点上启用 pgBackRest？默认值为： `true`

在使用本地文件系统备份仓库（`local`）时，只有集群主库才会真正启用 `pgbackrest`。其他实例只会初始化一个空仓库。





### `pgbackrest_clean`

参数名称： `pgbackrest_clean`， 类型： `bool`， 层次：`C`

初始化时删除 PostgreSQL 备份数据吗？默认值为 `true`。




### `pgbackrest_log_dir`

参数名称： `pgbackrest_log_dir`， 类型： `path`， 层次：`C`

pgBackRest 日志目录，默认为 `/pg/log/pgbackrest`，[`promtail`](#promtail) 日志代理会引用此参数收集日志。





### `pgbackrest_method`

参数名称： `pgbackrest_method`， 类型： `enum`， 层次：`C`

pgBackRest 仓库方法：默认可选项为：`local`、`minio` 或其他用户定义的方法，默认为 `local`。

此参数用于确定用于 pgBackRest 的仓库，所有可用的仓库方法都在 [`pgbackrest_repo`](#pgbackrest_repo) 中定义。

Pigsty 默认使用 `local` 备份仓库，这将在主实例的 `/pg/backup` 目录上创建一个备份仓库。底层存储路径由 [`pg_fs_bkup`](#pg_fs_bkup) 指定。






### `pgbackrest_repo`

参数名称： `pgbackrest_repo`， 类型： `dict`， 层次：`G/C`

pgBackRest 仓库文档：https://pgbackrest.org/configuration.html#section-repository

默认值包括两种仓库方法：`local` 和 `minio`，定义如下：

```yaml
pgbackrest_repo:                  # pgbackrest 仓库：https://pgbackrest.org/configuration.html#section-repository
  local:                          # 默认使用本地 posix 文件系统的 pgbackrest 仓库
    path: /pg/backup              # 本地备份目录，默认为 `/pg/backup`
    retention_full_type: count    # 按计数保留完整备份
    retention_full: 2             # 使用本地文件系统仓库时，最多保留 3 个完整备份，至少保留 2 个
  minio:                          # pgbackrest 的可选 minio 仓库
    type: s3                      # minio 是与 s3 兼容的，所以使用 s3
    s3_endpoint: sss.pigsty       # minio 端点域名，默认为 `sss.pigsty`
    s3_region: us-east-1          # minio 区域，默认为 us-east-1，对 minio 无效
    s3_bucket: pgsql              # minio 桶名称，默认为 `pgsql`
    s3_key: pgbackrest            # pgbackrest 的 minio 用户访问密钥
    s3_key_secret: S3User.Backup  # pgbackrest 的 minio 用户秘密密钥
    s3_uri_style: path            # 对 minio 使用路径风格的 uri，而不是主机风格
    path: /pgbackrest             # minio 备份路径，默认为 `/pgbackrest`
    storage_port: 9000            # minio 端口，默认为 9000
    storage_ca_file: /etc/pki/ca.crt  # minio ca 文件路径，默认为 `/etc/pki/ca.crt`
    bundle: y                     # 将小文件打包成一个文件
    cipher_type: aes-256-cbc      # 为远程备份仓库启用 AES 加密
    cipher_pass: pgBackRest       # AES 加密密码，默认为 'pgBackRest'
    retention_full_type: time     # 在 minio 仓库上按时间保留完整备份
    retention_full: 14            # 保留过去 14 天的完整备份
```

您可以定义新的备份仓库，例如使用 AWS S3，GCP 或其他云供应商的 S3 兼容存储服务。





------------------------------

## `PG_SERVICE`

本节介绍如何将PostgreSQL服务暴露给外部世界，包括：

- 使用`haproxy`在不同的端口上暴露不同的PostgreSQL服务
- 使用`vip-manager`将可选的L2 VIP绑定到主实例
- 在基础设施节点上使用`dnsmasq`注册集群/实例DNS记录

```yaml
pg_weight: 100          #实例 # 服务中的相对负载均衡权重，默认为100，范围0-255
pg_default_service_dest: pgbouncer # 如果svc.dest='default'，则此为默认服务目的地
pg_default_services:              # postgres默认服务定义
  - { name: primary ,port: 5433 ,dest: default  ,check: /primary   ,selector: "[]" }
  - { name: replica ,port: 5434 ,dest: default  ,check: /read-only ,selector: "[]" , backup: "[? pg_role == `primary` || pg_role == `offline` ]" }
  - { name: default ,port: 5436 ,dest: postgres ,check: /primary   ,selector: "[]" }
  - { name: offline ,port: 5438 ,dest: postgres ,check: /replica   ,selector: "[? pg_role == `offline` || pg_offline_query ]" , backup: "[? pg_role == `replica` && !pg_offline_query]"}
pg_vip_enabled: false             # 为pgsql主要实例启用l2 vip吗? 默认为false
pg_vip_address: 127.0.0.1/24      # `<ipv4>/<mask>`格式的vip地址，如果启用vip则需要
pg_vip_interface: eth0            # vip网络接口监听，默认为eth0
pg_dns_suffix: ''                 # pgsql dns后缀，默认为空
pg_dns_target: auto               # auto、primary、vip、none或特定的ip
```



### `pg_weight`

参数名称： `pg_weight`， 类型： `int`， 层次：`G`

服务中的相对负载均衡权重，默认为100，范围0-255。

默认值： `100`。您必须在实例变量中定义它，并[重载服务](PGSQL-ADMIN#重载服务)以生效。





### `pg_service_provider`

参数名称： `pg_service_provider`， 类型： `string`， 层次：`G/C`

专用的haproxy节点组名，或默认为本地节点的空字符串。

如果指定，PostgreSQL服务将注册到专用的haproxy节点组，而不是当下的 PGSQL 集群节点。

请记住为每个服务在专用的 haproxy 节点上分配**唯一**的端口！

例如，如果我们在3节点的 `pg-test` 集群上定义以下参数：

```yaml
pg_service_provider: infra       # use load balancer on group `infra`
pg_default_services:             # alloc port 10001 and 10002 for pg-test primary/replica service  
  - { name: primary ,port: 10001 ,dest: postgres  ,check: /primary   ,selector: "[]" }
  - { name: replica ,port: 10002 ,dest: postgres  ,check: /read-only ,selector: "[]" , backup: "[? pg_role == `primary` || pg_role == `offline` ]" }
```




### `pg_default_service_dest`

参数名称： `pg_default_service_dest`， 类型： `enum`， 层次：`G/C`

当定义一个[服务](PGSQL-SVC#define-service)时，如果 `svc.dest='default'`，此参数将用作默认值。

默认值： `pgbouncer`，意味着5433主服务和5434副本服务将默认将流量路由到 pgbouncer。

如果您不想使用pgbouncer，将其设置为`postgres`。流量将直接路由到 postgres。






### `pg_default_services`

参数名称： `pg_default_services`， 类型： `service[]`， 层次：`G/C`

postgres默认服务定义

默认值是四个默认服务定义，如[PGSQL Service](PGSQL-SVC#服务概述)所述

```yaml
pg_default_services:               # postgres default service definitions
  - { name: primary ,port: 5433 ,dest: default  ,check: /primary   ,selector: "[]" }
  - { name: replica ,port: 5434 ,dest: default  ,check: /read-only ,selector: "[]" , backup: "[? pg_role == `primary` || pg_role == `offline` ]" }
  - { name: default ,port: 5436 ,dest: postgres ,check: /primary   ,selector: "[]" }
  - { name: offline ,port: 5438 ,dest: postgres ,check: /replica   ,selector: "[? pg_role == `offline` || pg_offline_query ]" , backup: "[? pg_role == `replica` && !pg_offline_query]"}
```






### `pg_vip_enabled`

参数名称： `pg_vip_enabled`， 类型： `bool`， 层次：`C`

为 PGSQL 集群启用 L2 VIP吗？默认值是`false`，表示不创建 L2 VIP。

启用 L2 VIP 后，会有一个 VIP 绑定在集群主实例节点上，由 `vip-manager` 管理，根据 `etcd` 中的数据进行判断。

L2 VIP只能在相同的L2网络中使用，这可能会对您的网络拓扑产生额外的限制。





### `pg_vip_address`

参数名称： `pg_vip_address`， 类型： `cidr4`， 层次：`C`

如果启用vip，则需要`<ipv4>/<mask>`格式的vip地址。

默认值： `127.0.0.1/24`。这个值由两部分组成：`ipv4`和`mask`，用`/`分隔。





### `pg_vip_interface`

参数名称： `pg_vip_interface`， 类型： `string`， 层次：`C/I`

vip network interface to listen, `eth0` by default.

L2 VIP 监听的网卡接口，默认为 `eth0`。

它应该是您节点的首要网卡名，即您在配置清单中使用的IP地址。

如果您的节点有多块名称不同的网卡，您可以在实例变量上进行覆盖：

```yaml
pg-test:
    hosts:
        10.10.10.11: {pg_seq: 1, pg_role: replica ,pg_vip_interface: eth0 }
        10.10.10.12: {pg_seq: 2, pg_role: primary ,pg_vip_interface: eth1 }
        10.10.10.13: {pg_seq: 3, pg_role: replica ,pg_vip_interface: eth2 }
    vars:
      pg_vip_enabled: true          # 为这个集群启用L2 VIP，默认绑定到主实例
      pg_vip_address: 10.10.10.3/24 # L2网络CIDR: 10.10.10.0/24, vip地址: 10.10.10.3
      # pg_vip_interface: eth1      # 如果您的节点有统一的接口，您可以在这里定义它
```




### `pg_dns_suffix`

参数名称： `pg_dns_suffix`， 类型： `string`， 层次：`C`

PostgreSQL DNS 名称后缀，默认为空字符串。

在默认情况下，PostgreQL 集群名会作为 DNS 域名注册到 Infra 节点的 `dnsmasq` 中对外提供解析。

您可以通过本参数指定一个域名后缀，这样会使用 `{{ pg_cluster }}{{ pg_dns_suffix }}` 作为集群 DNS 名称。

例如，如果您将 `pg_dns_suffix` 设置为 `.db.vip.company.tld`，那么 `pg-test` 的集群 DNS 名称将是 `pg-test.db.vip.company.tld`





### `pg_dns_target`

参数名称： `pg_dns_target`， 类型： `enum`， 层次：`C`

Could be: `auto`, `primary`, `vip`, `none`, or an ad hoc ip address, which will be the target IP address of cluster DNS record. 

default values: `auto` , which will bind to `pg_vip_address` if `pg_vip_enabled`, or fallback to cluster primary instance ip address.

* `vip`: bind to `pg_vip_address`
* `primary`: resolve to cluster primary instance ip address
* `auto`: resolve to `pg_vip_address` if `pg_vip_enabled`, or fallback to cluster primary instance ip address.
* `none`: do not bind to any ip address
* `<ipv4>`: bind to the given IP address


可以是：`auto`、`primary`、`vip`、`none`或一个特定的IP地址，它将是集群DNS记录的解析目标IP地址。

默认值： `auto`，如果`pg_vip_enabled`，将绑定到`pg_vip_address`，否则会回退到集群主实例的 IP 地址。

- `vip`：绑定到`pg_vip_address`
- `primary`：解析为集群主实例IP地址
- `auto`：如果 [`pg_vip_enabled`](#pg_vip_enabled)，解析为 [`pg_vip_address`](#pg_vip_address)，或回退到集群主实例ip地址。
- `none`：不绑定到任何ip地址
- `<ipv4>`：绑定到指定的IP地址






------------------------------

## `PG_EXPORTER`

PG Exporter 用于监控 PostgreSQL 数据库与 Pgbouncer 连接池的状态。

```yaml
pg_exporter_enabled: true              # 在 pgsql 主机上启用 pg_exporter 吗？
pg_exporter_config: pg_exporter.yml    # pg_exporter 配置文件名
pg_exporter_cache_ttls: '1,10,60,300'  # pg_exporter 收集器 ttl 阶段（秒），默认为 '1,10,60,300'
pg_exporter_port: 9630                 # pg_exporter 监听端口，默认为 9630
pg_exporter_params: 'sslmode=disable'  # pg_exporter dsn 的额外 url 参数
pg_exporter_url: ''                    # 如果指定，将覆盖自动生成的 pg dsn
pg_exporter_auto_discovery: true       # 启用自动数据库发现？默认启用
pg_exporter_exclude_database: 'template0,template1,postgres' # 在自动发现过程中不会被监控的数据库的 csv 列表
pg_exporter_include_database: ''       # 在自动发现过程中将被监控的数据库的 csv 列表
pg_exporter_connect_timeout: 200       # pg_exporter 连接超时（毫秒），默认为 200
pg_exporter_options: ''                # 覆盖 pg_exporter 的额外选项
pgbouncer_exporter_enabled: true       # 在 pgsql 主机上启用 pgbouncer_exporter 吗？
pgbouncer_exporter_port: 9631          # pgbouncer_exporter 监听端口，默认为 9631
pgbouncer_exporter_url: ''             # 如果指定，将覆盖自动生成的 pgbouncer dsn
pgbouncer_exporter_options: ''         # 覆盖 pgbouncer_exporter 的额外选项
```



### `pg_exporter_enabled`

参数名称： `pg_exporter_enabled`， 类型： `bool`， 层次：`C`

是否在 PGSQL 节点上启用 pg_exporter？默认值为：`true`。

PG Exporter 用于监控 PostgreSQL 数据库实例，如果不想安装 pg_exporter 可以设置为 `false`。






### `pg_exporter_config`

参数名称： `pg_exporter_config`， 类型： `string`， 层次：`C`

pg_exporter 配置文件名，PG Exporter 和 PGBouncer Exporter 都会使用这个配置文件。默认值：`pg_exporter.yml`。

如果你想使用自定义配置文件，你可以在这里定义它。你的自定义配置文件应当放置于 `files/<name>.yml`。

例如，当您希望监控一个远程的 PolarDB 数据库实例时，可以使用样例配置：`files/polar_exporter.yml`。





### `pg_exporter_cache_ttls`

参数名称： `pg_exporter_cache_ttls`， 类型： `string`， 层次：`C`

pg_exporter 收集器 TTL 阶梯（秒），默认为 '1,10,60,300'

默认值：`1,10,60,300`，它将为不同的度量收集器使用不同的TTL值： 1s, 10s, 60s, 300s。

PG Exporter 内置了缓存机制，避免多个 Prometheus 重复抓取对数据库产生不当影响，所有指标收集器按 TTL 分为四类：

```yaml
ttl_fast: "{{ pg_exporter_cache_ttls.split(',')[0]|int }}"         # critical queries
ttl_norm: "{{ pg_exporter_cache_ttls.split(',')[1]|int }}"         # common queries
ttl_slow: "{{ pg_exporter_cache_ttls.split(',')[2]|int }}"         # slow queries (e.g table size)
ttl_slowest: "{{ pg_exporter_cache_ttls.split(',')[3]|int }}"      # ver slow queries (e.g bloat)
```

例如，在默认配置下，存活类指标默认最多缓存 `1s`，大部分普通指标会缓存 `10s`（应当与 [`prometheus_scrape_interval`](#prometheus_scrape_interval) 相同）。
少量变化缓慢的查询会有 `60s` 的TTL，极个别大开销监控查询会有 `300s` 的TTL。






### `pg_exporter_port`

参数名称： `pg_exporter_port`， 类型： `port`， 层次：`C`

pg_exporter 监听端口号，默认值为：`9631`





### `pg_exporter_params`

参数名称： `pg_exporter_params`， 类型： `string`， 层次：`C`

pg_exporter 所使用 DSN 中额外的 URL PATH 参数。

默认值：`sslmode=disable`，它将禁用用于监控连接的 SSL（因为默认使用本地 unix 套接字）。





### `pg_exporter_url`

参数名称： `pg_exporter_url`， 类型： `pgurl`， 层次：`C`

如果指定了本参数，将会覆盖自动生成的 PostgreSQL DSN，使用指定的 DSN 连接 PostgreSQL 。默认值为空字符串。

如果没有指定此参数，PG Exporter 默认会使用以下的连接串访问 PostgreSQL ：

```
postgres://{{ pg_monitor_username }}:{{ pg_monitor_password }}@{{ pg_host }}:{{ pg_port }}/postgres{% if pg_exporter_params != '' %}?{{ pg_exporter_params }}{% endif %}
```

当您想监控一个远程的 PostgreSQL 实例时，或者需要使用不同的监控用户/密码，配置选项时，可以使用这个参数。




### `pg_exporter_auto_discovery`

参数名称： `pg_exporter_auto_discovery`， 类型： `bool`， 层次：`C`

启用自动数据库发现吗？ 默认启用：`true`。

PG Exporter 默认会连接到 DSN 中指定的数据库 （默认为管理数据库 `postgres`） 收集全局指标，如果您希望收集所有业务数据库的指标，可以开启此选项。
PG Exporter 会自动发现目标 PostgreSQL 实例中的所有数据库，并在这些数据库中收集 **库级监控指标**。




### `pg_exporter_exclude_database`

参数名称： `pg_exporter_exclude_database`， 类型： `string`， 层次：`C`

如果启用了数据库自动发现（默认启用），在这个参数指定的列表中的数据库将不会被监控。
默认值为： `template0,template1,postgres`，即管理数据库 `postgres` 与模板数据库会被排除在自动监控的数据库之外。

作为例外，DSN 中指定的数据库不受此参数影响，例如，PG Exporter 如果连接的是 `postgres` 数据库，那么即使 `postgres` 在此列表中，也会被监控。





### `pg_exporter_include_database`

参数名称： `pg_exporter_include_database`， 类型： `string`， 层次：`C`

如果启用了数据库自动发现（默认启用），在这个参数指定的列表中的数据库才会被监控。默认值为空字符串，即不启用此功能。

参数的形式是由逗号分隔的数据库名称列表，例如：`db1,db2,db3`。

此参数相对于 [`pg_exporter_exclude_database`] 有更高的优先级，相当于白名单模式。如果您只希望监控特定的数据库，可以使用此参数。





### `pg_exporter_connect_timeout`

参数名称： `pg_exporter_connect_timeout`， 类型： `int`， 层次：`C`

pg_exporter 连接超时（毫秒），默认为 `200` （单位毫秒）

当 PG Exporter 尝试连接到 PostgreSQL 数据库时，最多会等待多长时间？超过这个时间，PG Exporter 将会放弃连接并报错。

默认值 200毫秒 对于绝大多数场景（例如：同可用区监控）都是足够的，但是如果您监控的远程 PostgreSQL 位于另一个大洲，您可能需要增加此值以避免连接超时。






### `pg_exporter_options`

参数名称： `pg_exporter_options`， 类型： `arg`， 层次：`C`

传给 PG Exporter 的命令行参数，默认值为：`""` 空字符串。

当使用空字符串时，会使用默认的命令参数：

```bash
{% if pg_exporter_port != '' %}
PG_EXPORTER_OPTS='--web.listen-address=:{{ pg_exporter_port }} {{ pg_exporter_options }}'
{% else %}
PG_EXPORTER_OPTS='--web.listen-address=:{{ pg_exporter_port }} --log.level=info'
{% endif %}
```

注意，请不要在本参数中覆盖 [`pg_exporter_port`](#pg_exporter_port) 的端口配置。





### `pgbouncer_exporter_enabled`

参数名称： `pgbouncer_exporter_enabled`， 类型： `bool`， 层次：`C`

在 PGSQL 节点上，是否启用 pgbouncer_exporter ？默认值为：`true`。





### `pgbouncer_exporter_port`

参数名称： `pgbouncer_exporter_port`， 类型： `port`， 层次：`C`

pgbouncer_exporter 监听端口号，默认值为：`9631`





### `pgbouncer_exporter_url`

参数名称： `pgbouncer_exporter_url`， 类型： `pgurl`， 层次：`C`

如果指定了本参数，将会覆盖自动生成的 pgbouncer DSN，使用指定的 DSN 连接 pgbouncer。默认值为空字符串。

如果没有指定此参数，Pgbouncer Exporter 默认会使用以下的连接串访问 Pgbouncer：

```
postgres://{{ pg_monitor_username }}:{{ pg_monitor_password }}@:{{ pgbouncer_port }}/pgbouncer?host={{ pg_localhost }}&sslmode=disable
```

当您想监控一个远程的 Pgbouncer 实例时，或者需要使用不同的监控用户/密码，配置选项时，可以使用这个参数。






### `pgbouncer_exporter_options`

参数名称： `pgbouncer_exporter_options`， 类型： `arg`， 层次：`C`

传给 Pgbouncer Exporter 的命令行参数，默认值为：`""` 空字符串。

当使用空字符串时，会使用默认的命令参数：

```bash
{% if pgbouncer_exporter_options != '' %}
PG_EXPORTER_OPTS='--web.listen-address=:{{ pgbouncer_exporter_port }} {{ pgbouncer_exporter_options }}'
{% else %}
PG_EXPORTER_OPTS='--web.listen-address=:{{ pgbouncer_exporter_port }} --log.level=info'
{% endif %}
```

注意，请不要在本参数中覆盖 [`pgbouncer_exporter_port`](#pgbouncer_exporter_port) 的端口配置。

