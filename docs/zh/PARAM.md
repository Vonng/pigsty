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
| 110 | [`repo_enabled`](#repo_enabled)                                 | [`INFRA`](#infra) |          [`REPO`](#repo)          | bool        | G/I   | 在此基础设施节点上创建Yum仓库？                                                               |
| 111 | [`repo_home`](#repo_home)                                       | [`INFRA`](#infra) |          [`REPO`](#repo)          | path        | G     | Yum仓库主目录，默认为`/www`                                                              |
| 112 | [`repo_name`](#repo_name)                                       | [`INFRA`](#infra) |          [`REPO`](#repo)          | string      | G     | Yum仓库名称，默认为 pigsty                                                              |
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
| 152 | [`prometheus_data`](#prometheus_data)                           | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | path        | G     | Prometheus 数据目录，默认为 `/data/prometheus`                                          |
| 153 | [`prometheus_sd_interval`](#prometheus_sd_interval)             | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | interval    | G     | Prometheus 目标刷新间隔，默认为 5s                                                        |
| 154 | [`prometheus_scrape_interval`](#prometheus_scrape_interval)     | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | interval    | G     | Prometheus 抓取 & 评估间隔，默认为 10s                                                    |
| 155 | [`prometheus_scrape_timeout`](#prometheus_scrape_timeout)       | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | interval    | G     | Prometheus 全局抓取超时，默认为 8s                                                        |
| 156 | [`prometheus_options`](#prometheus_options)                     | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | arg         | G     | Prometheus 额外的命令行参数选项                                                           |
| 157 | [`pushgateway_enabled`](#pushgateway_enabled)                   | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | bool        | G/I   | 在此基础设施节点上设置 pushgateway？                                                        |
| 158 | [`pushgateway_options`](#pushgateway_options)                   | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | arg         | G     | pushgateway 额外的命令行参数选项                                                          |
| 159 | [`blackbox_enabled`](#blackbox_enabled)                         | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | bool        | G/I   | 在此基础设施节点上设置 blackbox_exporter？                                                  |
| 160 | [`blackbox_options`](#blackbox_options)                         | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | arg         | G     | blackbox_exporter 额外的命令行参数选项                                                    |
| 161 | [`alertmanager_enabled`](#alertmanager_enabled)                 | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | bool        | G/I   | 在此基础设施节点上设置 alertmanager？                                                       |
| 162 | [`alertmanager_options`](#alertmanager_options)                 | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | arg         | G     | alertmanager 额外的命令行参数选项                                                         |
| 163 | [`exporter_metrics_path`](#exporter_metrics_path)               | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | path        | G     | exporter 指标路径，默认为 /metrics                                                      |
| 164 | [`exporter_install`](#exporter_install)                         | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | enum        | G     | 如何安装 exporter？none,yum,binary                                                   |
| 165 | [`exporter_repo_url`](#exporter_repo_url)                       | [`INFRA`](#infra) |    [`PROMETHEUS`](#prometheus)    | url         | G     | 通过 yum 安装exporter时使用的yum仓库文件地址                                                  |
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
| 210 | [`node_default_etc_hosts`](#node_default_etc_hosts)             |  [`NODE`](#node)  |      [`NODE_DNS`](#node_dns)      | string[]    | G     | /etc/hosts 中的静态 DNS 记录                                                          |
| 211 | [`node_etc_hosts`](#node_etc_hosts)                             |  [`NODE`](#node)  |      [`NODE_DNS`](#node_dns)      | string[]    | C     | /etc/hosts 中的额外静态 DNS 记录                                                        |
| 212 | [`node_dns_method`](#node_dns_method)                           |  [`NODE`](#node)  |      [`NODE_DNS`](#node_dns)      | enum        | C     | 如何处理现有DNS服务器：add,none,overwrite                                                 |
| 213 | [`node_dns_servers`](#node_dns_servers)                         |  [`NODE`](#node)  |      [`NODE_DNS`](#node_dns)      | string[]    | C     | /etc/resolv.conf 中的动态域名服务器列表                                                    |
| 214 | [`node_dns_options`](#node_dns_options)                         |  [`NODE`](#node)  |      [`NODE_DNS`](#node_dns)      | string[]    | C     | /etc/resolv.conf 中的DNS解析选项                                                      |
| 220 | [`node_repo_method`](#node_repo_method)                         |  [`NODE`](#node)  |  [`NODE_PACKAGE`](#node_package)  | enum        | C     | 如何设置节点仓库：none,local,public,both                                                 |
| 221 | [`node_repo_remove`](#node_repo_remove)                         |  [`NODE`](#node)  |  [`NODE_PACKAGE`](#node_package)  | bool        | C     | 配置节点软件仓库时，删除节点上现有的仓库吗？                                                          |
| 222 | [`node_repo_local_urls`](#node_repo_local_urls)                 |  [`NODE`](#node)  |  [`NODE_PACKAGE`](#node_package)  | string[]    | C     | 如果 node_repo_method = local,both，使用的本地仓库URL列表                                   |
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
| 845 | [`pg_version`](#pg_version)                                     | [`PGSQL`](#pgsql) |    [`PG_INSTALL`](#pg_install)    | enum        | C     | 要安装的 postgres 主版本，默认为 15                                                        |
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

参数名称： `version`， 类型： `string`， 层次：`G`

pigsty version string

default value:`v2.5.0`

It will be used for pigsty introspection & content rendering.





### `admin_ip`

参数名称： `admin_ip`， 类型： `ip`， 层次：`G`

admin node ip address

default value:`10.10.10.10`

Node with this ip address will be treated as admin node, usually point to the first node that install Pigsty.

The default value `10.10.10.10` is a placeholder which will be replaced during [configure](INSTALL#Configure)

This parameter is referenced by many other parameters, such as:

* [`infra_portal`](#infra_portal)
* [`repo_endpoint`](#repo_endpoint)
* [`dns_records`](#dns_records)
* [`node_default_etc_hosts`](#node_default_etc_hosts)
* [`node_etc_hosts`](#node_etc_hosts)
* [`node_repo_local_urls`](#node_repo_local_urls)

The exact string `${admin_ip}` will be replaced with the actual `admin_ip` for above parameters.








### `region`

参数名称： `region`， 类型： `enum`， 层次：`G`

upstream mirror region: default,china,europe

default value: `default`

If a region other than `default` is set, and there's a corresponding entry in `repo_upstream.[repo].baseurl`, it will be used instead of `default`.

For example, if `china` is used,  pigsty will use China mirrors designated in [`repo_upstream`](#repo_upstream) if applicable.




### `proxy_env`

参数名称： `proxy_env`， 类型： `dict`， 层次：`G`

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

参数名称： `ca_method`， 类型： `enum`， 层次：`G`

available options: create,recreate,copy

default value: `create`

* `create`: Create a new CA public-private key pair if not exists, use if exists
* `recreate`: Always re-create a new CA public-private key pair
* `copy`: Copy the existing CA public and private keys from local `files/pki/ca`, abort if missing

If you already have a pair of `ca.crt` and `ca.key`, put them under `files/pki/ca` and set `ca_method` to `copy`.





### `ca_cn`

参数名称： `ca_cn`， 类型： `string`， 层次：`G`

ca common name, not recommending to change it.

default value: `pigsty-ca`

you can check that with  `openssl x509 -text -in /etc/pki/ca.crt`





### `cert_validity`

参数名称： `cert_validity`， 类型： `interval`， 层次：`G`

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

参数名称： `infra_seq`， 类型： `int`， 层次：`I`

infra node identity, REQUIRED, no default value, you have to assign it explicitly.




### `infra_portal`

参数名称： `infra_portal`， 类型： `dict`， 层次：`G`

infra services exposed via portal

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
and the value contains `domain`, and `endpoint`,

* The `name` definition of the default record is fixed and referenced by other modules, so do not modify the default entry names.
* The `domain` is the domain name that should be used for external access to this upstream server. domain names will be added to Nginx SSL cert SAN.
* The `endpoint` is an internally reachable TCP port. and `${admin_ip}` will be replaced with actual [`admin_ip`](#admin_ip) in runtime.
* If `websocket` is set to `true`, http protocol will be auto upgraded for ws connections.
* If `scheme` is given (`http` or `https`), it will be used as part of proxy_pass URL.




------------------------------

## `REPO`

This section is about local yum repo, which is used by all other modules.

Pigsty is installed on a meta node. Pigsty pulls up a localYum repo for the current environment to install RPM packages.

During initialization, Pigsty downloads all packages and their dependencies (specified by [`repo_packages`](#repo_packages)) from the Internet upstream repo (specified by [`repo_upstream`](#repo_upstream)) to [`{{ nginx_home }}`](#nginx_home) / [`{{ repo_name }}`](#repo_name)  (default is `/www/pigsty`). The total size of all dependent software is about 1GB or so.

When creating a localYum repo, Pigsty will skip the software download phase if the directory already exists and if there is a marker file named `repo_complete` in the dir.

If the download speed of some packages is too slow, you can set the download proxy to complete the first download by using the [`proxy_env`](#proxy_env) config entry or directly download the pre-packaged [offline package](INSTALL#offline-packages).

The offline package is a zip archive of the `{{ nginx_home }}/{{ repo_name }}` dir `pkg.tgz`. During `configure`, if Pigsty finds the offline package `/tmp/pkg.tgz`, it will extract it to `{{ nginx_home }}/{{ repo_name }}`, skipping the software download step during installation.

The default offline package is based on CentOS 7.9.2011 x86_64; if you use a different OS, there may be RPM package conflict and dependency error problems; please refer to the FAQ to solve.



```yaml
repo_enabled: true                # create a yum repo on this infra node?
repo_home: /www                   # repo home dir, `/www` by default
repo_name: pigsty                 # repo name, pigsty by default
repo_endpoint: http://${admin_ip}:80 # access point to this repo by domain or ip:port
repo_remove: true                 # remove existing upstream repo
repo_modules: infra,node,pgsql,redis,minio  # which repo modules are installed in repo_upstream
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
repo_packages:                    # which packages to be included
  - ansible python3 python3-pip python3-requests python3.11-jmespath python3.11-pip dnf-utils modulemd-tools
  - grafana loki logcli promtail prometheus2 alertmanager pushgateway
  - node_exporter blackbox_exporter nginx_exporter redis_exporter mysqld_exporter mongodb_exporter kafka_exporter keepalived_exporter
  - redis etcd minio mcli haproxy vip-manager pg_exporter ferretdb sealos nginx createrepo_c sshpass chrony dnsmasq docker-ce docker-compose-plugin
  - lz4 unzip bzip2 zlib yum pv jq git ncdu make patch bash lsof wget uuid tuned nvme-cli numactl grubby sysstat iotop htop rsync tcpdump perf flamegraph
  - netcat socat ftp lrzsz net-tools ipvsadm bind-utils telnet audit ca-certificates openssl openssh-clients readline vim-minimal keepalived
  - patroni patroni-etcd pgbouncer pgbadger pgbackrest pgloader pg_activity pg_filedump timescaledb-tools scws
  - postgresql14* wal2json_14* pg_repack_14* passwordcheck_cracklib_14* postgresql13* wal2json_13* pg_repack_13* passwordcheck_cracklib_13* postgresql12* wal2json_12* pg_repack_12* passwordcheck_cracklib_12*
  - postgresql15* citus_15* pglogical_15* wal2json_15* pgvector_15* postgis34_15* passwordcheck_cracklib_15* pg_cron_15* pointcloud_15* pg_tle_15* pgsql-http_15* zhparser_15* pg_roaringbitmap_15* pg_net_15* vault_15 pg_graphql_15 timescaledb-2-postgresql-15* pg_repack_15*
  - postgresql16* citus_16* pglogical_16* wal2json_16* pgvector_16* postgis34_16* passwordcheck_cracklib_16* pg_cron_16* pointcloud_16* pg_tle_16* pgsql-http_16* zhparser_16* pg_roaringbitmap_16* pg_net_16* vault_16 pg_graphql_16 hydra_15* pgml_15* apache-age_15
  - orafce_15* mysqlcompat_15 mongo_fdw_15* tds_fdw_15* mysql_fdw_15 hdfs_fdw_15 sqlite_fdw_15 pgbouncer_fdw_15 multicorn2_15* powa_15* pg_stat_kcache_15* pg_stat_monitor_15* pg_qualstats_15 pg_track_settings_15 pg_wait_sampling_15 system_stats_15
  - plprofiler_15* plproxy_15 plsh_15* pldebugger_15 plpgsql_check_15*  pgtt_15 pgq_15* pgsql_tweaks_15 count_distinct_15 hypopg_15 timestamp9_15* semver_15* prefix_15* geoip_15 periods_15 ip4r_15 tdigest_15 hll_15 pgmp_15 extra_window_functions_15 topn_15
  - pg_background_15 e-maj_15 pg_catcheck_15 pg_prioritize_15 pgcopydb_15 pgcryptokey_15 logerrors_15 pg_top_15 pg_comparator_15 pg_ivm_15* pgsodium_15* pgfincore_15* ddlx_15 credcheck_15 safeupdate_15 pg_squeeze_15* pg_fkpart_15 pg_jobmon_15
  - pg_partman_15 pg_permissions_15 pgexportdoc_15 pgimportdoc_15 pg_statement_rollback_15* pg_hint_plan_15* pg_auth_mon_15 pg_checksums_15 pg_failover_slots_15 pg_readonly_15* postgresql-unit_15* pg_store_plans_15* pg_uuidv7_15* set_user_15* pgaudit17_15 rum_15
repo_url_packages:
  - https://repo.pigsty.cc/etc/pev.html
  - https://repo.pigsty.cc/etc/chart.tgz
  - https://repo.pigsty.cc/etc/plugins.tgz
```


### `repo_enabled`

参数名称： `repo_enabled`， 类型： `bool`， 层次：`G/I`

create a yum repo on this infra node? default value: `true`

If you have multiple infra nodes, you can disable yum repo on other standby nodes to reduce Internet traffic.




### `repo_home`

参数名称： `repo_home`， 类型： `path`， 层次：`G`

repo home dir, `/www` by default






### `repo_name`

参数名称： `repo_name`， 类型： `string`， 层次：`G`

repo name, `pigsty` by default, it is not wise to change this value






### `repo_endpoint`

参数名称： `repo_endpoint`， 类型： `url`， 层次：`G`

access point to this repo by domain or ip:port

default value: `http://${admin_ip}:80`




### `repo_remove`

参数名称： `repo_remove`， 类型： `bool`， 层次：`G/A`

remove existing upstream repo, default value: `true`

If you want to keep existing upstream repo, set this value to `false`.




### `repo_modules`

参数名称： `repo_modules`， 类型： `string`， 层次：`G/A`

which repo modules are installed in repo_upstream, default value: `node,pgsql,pgsql`

This is a comma separated value string, it is used to filter entries in [`repo_upstream`](#repo_upstream) with corresponding `module` field. 






### `repo_upstream`

参数名称： `repo_upstream`， 类型： `upstream[]`， 层次：`G`

where to download upstream packages

default values: 

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




### `repo_packages`

参数名称： `repo_packages`， 类型： `string[]`， 层次：`G`

which packages to be included, default values: 

```yaml
repo_packages:                    # which packages to be included
- ansible python3 python3-pip python3-requests python3.11-jmespath python3.11-pip dnf-utils modulemd-tools
- grafana loki logcli promtail prometheus2 alertmanager pushgateway
- node_exporter blackbox_exporter nginx_exporter redis_exporter mysqld_exporter mongodb_exporter kafka_exporter keepalived_exporter
- redis etcd minio mcli haproxy vip-manager pg_exporter ferretdb sealos nginx createrepo_c sshpass chrony dnsmasq docker-ce docker-compose-plugin
- lz4 unzip bzip2 zlib yum pv jq git ncdu make patch bash lsof wget uuid tuned nvme-cli numactl grubby sysstat iotop htop rsync tcpdump perf flamegraph
- netcat socat ftp lrzsz net-tools ipvsadm bind-utils telnet audit ca-certificates openssl openssh-clients readline vim-minimal keepalived
- patroni patroni-etcd pgbouncer pgbadger pgbackrest pgloader pg_activity pg_filedump timescaledb-tools scws
- postgresql14* wal2json_14* pg_repack_14* passwordcheck_cracklib_14* postgresql13* wal2json_13* pg_repack_13* passwordcheck_cracklib_13* postgresql12* wal2json_12* pg_repack_12* passwordcheck_cracklib_12*
- postgresql15* citus_15* pglogical_15* wal2json_15* pgvector_15* postgis34_15* passwordcheck_cracklib_15* pg_cron_15* pointcloud_15* pg_tle_15* pgsql-http_15* zhparser_15* pg_roaringbitmap_15* pg_net_15* vault_15 pg_graphql_15 timescaledb-2-postgresql-15* pg_repack_15*
- postgresql16* citus_16* pglogical_16* wal2json_16* pgvector_16* postgis34_16* passwordcheck_cracklib_16* pg_cron_16* pointcloud_16* pg_tle_16* pgsql-http_16* zhparser_16* pg_roaringbitmap_16* pg_net_16* vault_16 pg_graphql_16 hydra_15* pgml_15* apache-age_15
- orafce_15* mysqlcompat_15 mongo_fdw_15* tds_fdw_15* mysql_fdw_15 hdfs_fdw_15 sqlite_fdw_15 pgbouncer_fdw_15 multicorn2_15* powa_15* pg_stat_kcache_15* pg_stat_monitor_15* pg_qualstats_15 pg_track_settings_15 pg_wait_sampling_15 system_stats_15
- plprofiler_15* plproxy_15 plsh_15* pldebugger_15 plpgsql_check_15*  pgtt_15 pgq_15* pgsql_tweaks_15 count_distinct_15 hypopg_15 timestamp9_15* semver_15* prefix_15* geoip_15 periods_15 ip4r_15 tdigest_15 hll_15 pgmp_15 extra_window_functions_15 topn_15
- pg_background_15 e-maj_15 pg_catcheck_15 pg_prioritize_15 pgcopydb_15 pgcryptokey_15 logerrors_15 pg_top_15 pg_comparator_15 pg_ivm_15* pgsodium_15* pgfincore_15* ddlx_15 credcheck_15 safeupdate_15 pg_squeeze_15* pg_fkpart_15 pg_jobmon_15
- pg_partman_15 pg_permissions_15 pgexportdoc_15 pgimportdoc_15 pg_statement_rollback_15* pg_hint_plan_15* pg_auth_mon_15 pg_checksums_15 pg_failover_slots_15 pg_readonly_15* postgresql-unit_15* pg_store_plans_15* pg_uuidv7_15* set_user_15* pgaudit17_15 rum_15
```

Each line is a set of package names separated by spaces, where the specified software will be downloaded via `repotrack`.

EL7 packages is slightly different, here are some ad hoc packages:

* EL7:  `python36-requests python36-idna yum-utils yum-utils`
* EL8 / EL9:  `python3.11-jmespath dnf-utils modulemd-tools`




### `repo_url_packages`

参数名称： `repo_url_packages`， 类型： `string[]`， 层次：`G`

extra packages from url, default values:

```yaml
repo_url_packages:
  - https://repo.pigsty.cc/etc/pev.html
  - https://repo.pigsty.cc/etc/chart.tgz
```





------------------------------

## `INFRA_PACKAGE`

These packages are installed on infra nodes only, including common rpm pacakges, and pip packages.


```yaml
infra_packages:                   # packages to be installed on infra nodes
  - grafana,loki,logcli,promtail,prometheus2,alertmanager,karma,pushgateway
  - node_exporter,blackbox_exporter,nginx_exporter,redis_exporter,pg_exporter
  - nginx,dnsmasq,ansible,postgresql15,redis,mcli,python3-requests
infra_packages_pip: ''            # pip installed packages for infra nodes
```


### `infra_packages`

参数名称： `infra_packages`， 类型： `string[]`， 层次：`G`

packages to be installed on infra nodes, default value:

```yaml
infra_packages:                   # packages to be installed on infra nodes
  - grafana,loki,logcli,promtail,prometheus2,alertmanager,karma,pushgateway
  - node_exporter,blackbox_exporter,nginx_exporter,redis_exporter,pg_exporter
  - nginx,dnsmasq,ansible,postgresql15,redis,mcli,python3-requests
```




### `infra_packages_pip`

参数名称： `infra_packages_pip`， 类型： `string`， 层次：`G`

pip installed packages for infra nodes, default value is empty string








------------------------------

## `NGINX`

Pigsty exposes all Web services through Nginx: Home Page, Grafana, Prometheus, AlertManager, etc...,
and other optional tools such as PGWe, Jupyter Lab, Pgadmin, Bytebase ,and other static resource & report such as `pev`, `schemaspy` & `pgbadger`

This nginx also serves as a local yum repo.


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

enable nginx on this infra node? default value: `true`





### `nginx_exporter_enabled`

参数名称： `nginx_exporter_enabled`， 类型： `bool`， 层次：`G/I`

enable nginx_exporter on this infra node? default value: `true`.

set to false will disable `/nginx` health check stub too 





### `nginx_sslmode`

参数名称： `nginx_sslmode`， 类型： `enum`， 层次：`G`

nginx ssl mode? disable,enable,enforce

default value: `enable`

* `disable`: listen on default port only
* `enable`: serve both http / https requests
* `enforce`: all links are rendered as `https://`





### `nginx_home`

参数名称： `nginx_home`， 类型： `path`， 层次：`G`

nginx content dir, `/www` by default

Nginx root directory which contains static resource and repo resource. It's wise to set this value same as [`repo_home`](#repo_home) so that local repo content is automatically served.




### `nginx_port`

参数名称： `nginx_port`， 类型： `port`， 层次：`G`

nginx listen port, `80` by default






### `nginx_ssl_port`

参数名称： `nginx_ssl_port`， 类型： `port`， 层次：`G`

nginx ssl listen port, `443` by default





### `nginx_navbar`

参数名称： `nginx_navbar`， 类型： `index[]`， 层次：`G`

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


You can set a default DNSMASQ server on infra nodes to serve DNS inquiry.

All records on infra node's  `/etc/hosts.d/*` will be resolved.

You have to add `nameserver {{ admin_ip }}` to your `/etc/resolv` to use this dns server

For pigsty managed node, the default `"${admin_ip}"` in [`node_dns_servers`](#node_dns_servers) will do the trick.




```yaml
dns_enabled: true                 # setup dnsmasq on this infra node?
dns_port: 53                      # dns server listen port, 53 by default
dns_records:                      # dynamic dns records resolved by dnsmasq
  - "${admin_ip} h.pigsty a.pigsty p.pigsty g.pigsty"
  - "${admin_ip} api.pigsty adm.pigsty cli.pigsty ddl.pigsty lab.pigsty git.pigsty sss.pigsty wiki.pigsty"
```


### `dns_enabled`

参数名称： `dns_enabled`， 类型： `bool`， 层次：`G/I`

setup dnsmasq on this infra node? default value: `true`




### `dns_port`

参数名称： `dns_port`， 类型： `port`， 层次：`G`

dns server listen port, `53` by default





### `dns_records`

参数名称： `dns_records`， 类型： `string[]`， 层次：`G`

dynamic dns records resolved by dnsmasq, Some auxiliary domain names will be written to `/etc/hosts.d/default` by default

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

参数名称： `prometheus_enabled`， 类型： `bool`， 层次：`G/I`

enable prometheus on this infra node?

default value: `true`





### `prometheus_clean`

参数名称： `prometheus_clean`， 类型： `bool`， 层次：`G/A`

clean prometheus data during init? default value: `true`






### `prometheus_data`

参数名称： `prometheus_data`， 类型： `path`， 层次：`G`

prometheus data dir, `/data/prometheus` by default





### `prometheus_sd_interval`

参数名称： `prometheus_sd_interval`， 类型： `interval`， 层次：`G`

prometheus target refresh interval, `5s` by default







### `prometheus_scrape_interval`

参数名称： `prometheus_scrape_interval`， 类型： `interval`， 层次：`G`

prometheus scrape & eval interval, `10s` by default







### `prometheus_scrape_timeout`

参数名称： `prometheus_scrape_timeout`， 类型： `interval`， 层次：`G`

prometheus global scrape timeout, `8s` by default

DO NOT set this larger than [`prometheus_scrape_interval`](#prometheus_scrape_interval)





### `prometheus_options`

参数名称： `prometheus_options`， 类型： `arg`， 层次：`G`

prometheus extra server options

default value: `--storage.tsdb.retention.time=15d`

Extra cli args for prometheus server, the default value will set up a 15-day data retention to limit disk usage.





### `pushgateway_enabled`

参数名称： `pushgateway_enabled`， 类型： `bool`， 层次：`G/I`

setup pushgateway on this infra node? default value: `true`





### `pushgateway_options`

参数名称： `pushgateway_options`， 类型： `arg`， 层次：`G`

pushgateway extra server options, default value: `--persistence.interval=1m`





### `blackbox_enabled`

参数名称： `blackbox_enabled`， 类型： `bool`， 层次：`G/I`

setup blackbox_exporter on this infra node? default value: `true`





### `blackbox_options`

参数名称： `blackbox_options`， 类型： `arg`， 层次：`G`

blackbox_exporter extra server options, default value is empty string






### `alertmanager_enabled`

参数名称： `alertmanager_enabled`， 类型： `bool`， 层次：`G/I`

setup alertmanager on this infra node? default value: `true`





### `alertmanager_options`

参数名称： `alertmanager_options`， 类型： `arg`， 层次：`G`

alertmanager extra server options, default value is empty string





### `exporter_metrics_path`

参数名称： `exporter_metrics_path`， 类型： `path`， 层次：`G`

exporter metric path, `/metrics` by default






### `exporter_install`

参数名称： `exporter_install`， 类型： `enum`， 层次：`G`

how to install exporter? none,yum,binary

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

参数名称： `exporter_repo_url`， 类型： `url`， 层次：`G`

exporter repo file url if install exporter via yum

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
  - volkovlabs-grapi-datasource
  - marcusolsson-dynamictext-panel
  - marcusolsson-treemap-panel
  - marcusolsson-calendar-panel
  - marcusolsson-static-datasource
loki_enabled: true                # enable loki on this infra node?
loki_clean: false                 # whether remove existing loki data?
loki_data: /data/loki             # loki data dir, `/data/loki` by default
loki_retention: 15d               # loki log retention period, 15d by default
```



### `grafana_enabled`

参数名称： `grafana_enabled`， 类型： `bool`， 层次：`G/I`

enable grafana on this infra node? default value: `true`





### `grafana_clean`

参数名称： `grafana_clean`， 类型： `bool`， 层次：`G/A`

clean grafana data during init? default value: `true`





### `grafana_admin_username`

参数名称： `grafana_admin_username`， 类型： `username`， 层次：`G`

grafana admin username, `admin` by default







### `grafana_admin_password`

参数名称： `grafana_admin_password`， 类型： `password`， 层次：`G`

grafana admin password, `pigsty` by default

default value: `pigsty`

!> WARNING: Change this to a strong password before deploying to production environment 





### `grafana_plugin_cache`

参数名称： `grafana_plugin_cache`， 类型： `path`， 层次：`G`

path to grafana plugins cache tarball

default value: `/www/pigsty/plugins.tgz`

If that cache exists, pigsty use that instead of downloading plugins from the Internet





### `grafana_plugin_list`

参数名称： `grafana_plugin_list`， 类型： `string[]`， 层次：`G`

grafana plugins to be downloaded with grafana-cli

default value:

```yaml
grafana_plugin_list:              # grafana plugins to be downloaded with grafana-cli
  - volkovlabs-echarts-panel
  - volkovlabs-image-panel
  - volkovlabs-form-panel
  - volkovlabs-grapi-datasource
  - marcusolsson-dynamictext-panel
  - marcusolsson-treemap-panel
  - marcusolsson-calendar-panel
  - marcusolsson-static-datasource
```






------------------------------

## `LOKI`


### `loki_enabled`

参数名称： `loki_enabled`， 类型： `bool`， 层次：`G/I`

enable loki on this infra node? default value: `true`





### `loki_clean`

参数名称： `loki_clean`， 类型： `bool`， 层次：`G/A`

whether remove existing loki data? default value: `false`





### `loki_data`

参数名称： `loki_data`， 类型： `path`， 层次：`G`

loki data dir, default value: `/data/loki`






### `loki_retention`

参数名称： `loki_retention`， 类型： `interval`， 层次：`G`

loki log retention period, `15d` by default










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

node instance identity, use hostname if missing, optional

no default value, Null or empty string means `nodename` will be set to node's current hostname.

If [`node_id_from_pg`](#node_id_from_pg) is `true`, [`nodename`](#nodename) will try to use `${pg_cluster}-${pg_seq}` first, if PGSQL is not defined on this node, it will fall back to default `HOSTNAME`.

If [`nodename_overwrite`](#nodename_overwrite) is `true`, the node name will also be used as the HOSTNAME.





### `node_cluster`

参数名称： `node_cluster`， 类型： `string`， 层次：`C`

node cluster identity, use 'nodes' if missing, optional

default values: `nodes`

If [`node_id_from_pg`](#node_id_from_pg) is `true`, [`node_cluster`](#nodename) will try to use `${pg_cluster}-${pg_seq}` first, if PGSQL is not defined on this node, it will fall back to default `HOSTNAME`.

If [`nodename_overwrite`](#nodename_overwrite) is `true`, the node name will also be used as the HOSTNAME.





### `nodename_overwrite`

参数名称： `nodename_overwrite`， 类型： `bool`， 层次：`C`

是否使用 nodename 覆盖主机名？默认值为 `true`，在这种情况下，如果你设置了一个非空的 [`nodename`](#nodename) ，那么它会被用作当前主机的 HOSTNAME 。

当 `nodename` 配置为空时，如果  [`node_id_from_pg`](#node_id_from_pg) 参数被配置为 `true` （默认为真），那么 Pigsty 会尝试借用1:1定义在节点上的 PostgreSQL 实例的身份参数作为主机的节点名。
也就是 `{{ pg_cluster }}-{{ pg_seq }}`，如果该节点没有安装 PGSQL 模块，则会回归到默认什么都不做的状态。

因此，如果您将 [`nodename`](#nodename) 留空，并且没有启用 [`node_id_from_pg`](#node_id_from_pg) 参数时，Pigsty不会对现有主机名进行任何修改。




### `nodename_exchange`

参数名称： `nodename_exchange`， 类型： `bool`， 层次：`C`

exchange nodename among play hosts?

default value is `false`

When this parameter is enabled, node names are exchanged between the same group of nodes executing the `node.yml` playbook, written to `/etc/hosts`.




### `node_id_from_pg`

参数名称： `node_id_from_pg`， 类型： `bool`， 层次：`C`

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

参数名称： `node_default_etc_hosts`， 类型： `string[]`， 层次：`G`

static dns records in `/etc/hosts`

default value: 

```yaml
["${admin_ip} h.pigsty a.pigsty p.pigsty g.pigsty"]
```

[`node_default_etc_hosts`](#node_default_etc_hosts) is an array. Each element is a DNS record with format `<ip> <name>`.

It is used for global static DNS records. You can use [`node_etc_hosts`](#node_etc_hosts) for ad hoc records for each cluster.

Make sure to write a DNS record like `10.10.10.10 h.pigsty a.pigsty p.pigsty g.pigsty` to `/etc/hosts` to ensure that the local yum repo can be accessed using the domain name before the DNS Nameserver starts.




### `node_etc_hosts`

参数名称： `node_etc_hosts`， 类型： `string[]`， 层次：`C`

extra static dns records in `/etc/hosts`

default values: `[]`

Same as [`node_default_etc_hosts`](#node_default_etc_hosts), but in addition to it.




### `node_dns_method`

参数名称： `node_dns_method`， 类型： `enum`， 层次：`C`

how to handle dns servers: add,none,overwrite

default values: `add`

* `add`: Append the records in [`node_dns_servers`](#node_dns_servers) to `/etc/resolv.conf` and keep the existing DNS servers. (default)
* `overwrite`: Overwrite `/etc/resolv.conf` with the record in [`node_dns_servers`](#node_dns_servers)
* `none`: If a DNS server is provided in the production env, the DNS server config can be skipped.




### `node_dns_servers`

参数名称： `node_dns_servers`， 类型： `string[]`， 层次：`C`

dynamic nameserver in `/etc/resolv.conf`

default values: `["${admin_ip}"]` , the default nameserver on admin node will be added to `/etc/resolv.conf` as the first nameserver.





### `node_dns_options`

参数名称： `node_dns_options`， 类型： `string[]`， 层次：`C`

dns resolv options in `/etc/resolv.conf`

default value: 

```yaml
["options single-request-reopen timeout:1"]
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
  - lz4,unzip,bzip2,zlib,yum,pv,jq,git,ncdu,make,patch,bash,lsof,wget,uuid,tuned,chrony,nvme-cli,numactl,grubby,sysstat,iotop,htop,yum,yum-utils
  - wget,netcat,socat,rsync,ftp,lrzsz,s3cmd,net-tools,tcpdump,ipvsadm,bind-utils,telnet,dnsmasq,audit,ca-certificates,openssl,openssh-clients,readline,vim-minimal
  - node_exporter,etcd,mtail,python3,python3-pip,python3-idna,python3-requests,haproxy
```  




### `node_repo_method`

参数名称： `node_repo_method`， 类型： `enum`， 层次：`C/A`

how to setup node repo: `none`, `local`, `public`, `both`, default values: `local`

Which repos are added to `/etc/yum.repos.d` on target nodes ?

* `local`: Use the local yum repo on the admin node, default behavior.
* `public`: Add public upstream repo directly to the target nodes, use this if you have Internet access. 
* `both`: Add both local repo and public repo. Useful when some rpm are missing 
* `none`: do not add any repo to target nodes.



### `node_repo_remove`

参数名称： `node_repo_remove`， 类型： `bool`， 层次：`C/A`

remove existing repo on node?

default value is `true`, and thus Pigsty will move existing repo file in `/etc/yum.repos.d` to a backup dir: `/etc/yum.repos.d/backup` before adding upstream repos




### `node_repo_local_urls`

参数名称： `node_repo_local_urls`， 类型： `string[]`， 层次：`C`

local repo url, if node_repo_method = local

default values: `["http://${admin_ip}/pigsty.repo"]`

When [`node_repo_method`](#node_repo_method) = `local`, the Repo file URLs listed here will be downloaded to `/etc/yum.repos.d`.






### `node_packages`

参数名称： `node_packages`， 类型： `string[]`， 层次：`C`

packages to be installed current nodes

default values: `[]`

Like [`node_packages_default`](#node_default_packages), but in addition to it. designed for overwriting in cluster/instance level.




### `node_default_packages`

参数名称： `node_default_packages`， 类型： `string[]`， 层次：`G`

default packages to be installed on all nodes

default value: 

```yaml
node_default_packages:            # default packages to be installed on all nodes
  - lz4,unzip,bzip2,zlib,yum,pv,jq,git,ncdu,make,patch,bash,lsof,wget,uuid,tuned,nvme-cli,numactl,grubby,sysstat,iotop,htop,rsync,tcpdump
  - netcat,socat,ftp,lrzsz,net-tools,ipvsadm,bind-utils,telnet,audit,ca-certificates,openssl,readline,vim-minimal,node_exporter,etcd,haproxy,python3,python3-pip
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

参数名称： `node_disable_firewall`， 类型： `bool`， 层次：`C`

disable node firewall? true by default

default value is `true`




### `node_disable_selinux`

参数名称： `node_disable_selinux`， 类型： `bool`， 层次：`C`

disable node selinux? true by default

default value is `true`




### `node_disable_numa`

参数名称： `node_disable_numa`， 类型： `bool`， 层次：`C`

disable node numa, reboot required

default value is `false`

Boolean flag, default is not off. Note that turning off NUMA requires a reboot of the machine before it can take effect!

If you don't know how to set the CPU affinity, it is recommended to turn off NUMA.





### `node_disable_swap`

参数名称： `node_disable_swap`， 类型： `bool`， 层次：`C`

disable node swap, use with caution

default value is `false`

But turning off SWAP is not recommended. But SWAP should be disabled when your node is used for a Kubernetes deployment. 

If there is enough memory and the database is deployed exclusively. it may slightly improve performance 






### `node_static_network`

参数名称： `node_static_network`， 类型： `bool`， 层次：`C`

preserve dns resolver settings after reboot, default value is `true`

Enabling static networking means that machine reboots will not overwrite your DNS Resolv config with NIC changes. It is recommended to enable it in production environment.




### `node_disk_prefetch`

参数名称： `node_disk_prefetch`， 类型： `bool`， 层次：`C`

setup disk prefetch on HDD to increase performance

default value is `false`, Consider enable this when using HDD.





### `node_kernel_modules`

参数名称： `node_kernel_modules`， 类型： `string[]`， 层次：`C`

kernel modules to be enabled on this node

default value: 

```yaml
node_kernel_modules: [ softdog, br_netfilter, ip_vs, ip_vs_rr, ip_vs_wrr, ip_vs_sh ]
```

An array consisting of kernel module names declaring the kernel modules that need to be installed on the node. 




### `node_hugepage_count`

参数名称： `node_hugepage_count`， 类型： `int`， 层次：`C`

number of 2MB hugepage, take precedence over ratio, 0 by default

Take precedence over [`node_hugepage_ratio`](#node_hugepage_ratio). If a non-zero value is given, it will be written to `/etc/sysctl.d/hugepage.conf`

If `node_hugepage_count` and `node_hugepage_ratio` are both `0` (default), hugepage will be disabled at all.

Negative value will not work, and number higher than 90% node mem will be ceil to 90% of node mem. 

It should slightly larger than [`pg_shared_buffer_ratio`](#pg_shared_buffer_ratio), if not zero.




### `node_hugepage_ratio`

参数名称： `node_hugepage_ratio`， 类型： `float`， 层次：`C`

node mem hugepage ratio, 0 disable it by default, valid range: 0 ~ 0.40

default values: `0`, which will set `vm.nr_hugepages=0` and not use HugePage at all.

Percent of this memory will be allocated as HugePage, and reserved for PostgreSQL.

It should be equal or slightly larger than [`pg_shared_buffer_ratio`](#pg_shared_buffer_ratio), if not zero.

For example, if you have default 25% mem for postgres shard buffers, you can set this value to 27 ~ 30.  Wasted hugepage can be reclaimed later with `/pg/bin/pg-tune-hugepage`





### `node_overcommit_ratio`

参数名称： `node_overcommit_ratio`， 类型： `int`， 层次：`C`

node mem overcommit ratio, 0 disable it by default. this is an integer from 0 to 100+ .

default values: `0`, which will set `vm.overcommit_memory=0`, otherwise `vm.overcommit_memory=2` will be used,
and this value will be used as `vm.overcommit_ratio`.

It is recommended to set use a `vm.overcommit_ratio` on dedicated pgsql nodes. e.g. 50 ~ 100. 




### `node_tune`

参数名称： `node_tune`， 类型： `enum`， 层次：`C`

node tuned profile: none,oltp,olap,crit,tiny

default values: `oltp`

* `tiny`: Micro Virtual Machine (1 ~ 3 Core, 1 ~ 8 GB Mem)
* `oltp`: Regular OLTP templates with optimized latency
* `olap `: Regular OLAP templates to optimize throughput
* `crit`: Core financial business templates, optimizing the number of dirty pages

Usually, the database tuning template [`pg_conf`](#pg_conf) should be paired with the node tuning template: [`node_tune`](#node_tune)






### `node_sysctl_params`

参数名称： `node_sysctl_params`， 类型： `dict`， 层次：`C`

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

参数名称： `node_data`， 类型： `path`， 层次：`C`

node main data directory, `/data` by default

default values: `/data`

If specified, this path will be used as major data disk mountpoint. And a dir will be created and throwing a warning if path not exists.

The data dir is owned by root with mode `0777`.





### `node_admin_enabled`

参数名称： `node_admin_enabled`， 类型： `bool`， 层次：`C`

create a admin user on target node?

default value is `true`

Create an admin user on each node (password-free sudo and ssh), an admin user named `dba (uid=88)` will be created by default,
 which can access other nodes in the env and perform sudo from the meta node via SSH password-free.




### `node_admin_uid`

参数名称： `node_admin_uid`， 类型： `int`， 层次：`C`

uid and gid for node admin user

default values: `88`





### `node_admin_username`

参数名称： `node_admin_username`， 类型： `username`， 层次：`C`

name of node admin user, `dba` by default

default values: `dba`





### `node_admin_ssh_exchange`

参数名称： `node_admin_ssh_exchange`， 类型： `bool`， 层次：`C`

exchange admin ssh key among node cluster

default value is `true`

When enabled, Pigsty will exchange SSH public keys between members during playbook execution, allowing admins [`node_admin_username`](#node_admin_username) to access each other from different nodes.




### `node_admin_pk_current`

参数名称： `node_admin_pk_current`， 类型： `bool`， 层次：`C`

add current user's ssh pk to admin authorized_keys

default value is `true`

When enabled, on the current node, the SSH public key (`~/.ssh/id_rsa.pub`) of the current user is copied to the `authorized_keys` of the target node admin user.

When deploying in a production env, be sure to pay attention to this parameter, which installs the default public key of the user currently executing the command to the admin user of all machines.





### `node_admin_pk_list`

参数名称： `node_admin_pk_list`， 类型： `string[]`， 层次：`C`

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

参数名称： `node_timezone`， 类型： `string`， 层次：`C`

setup node timezone, empty string to skip

default value is empty string, which will not change the default timezone (usually UTC)





### `node_ntp_enabled`

参数名称： `node_ntp_enabled`， 类型： `bool`， 层次：`C`

enable chronyd time sync service?

default value is `true`, and thus Pigsty will override the node's `/etc/chrony.conf` by with [`node_ntp_servers`](#node_ntp_servers).

If you already a NTP server configured, just set to `false` to leave it be.




### `node_ntp_servers`

参数名称： `node_ntp_servers`， 类型： `string[]`， 层次：`C`

ntp servers in `/etc/chrony.conf`

default value:  `["pool pool.ntp.org iburst"]`

It only takes effect if [`node_ntp_enabled`](#node_ntp_enabled) is true.

You can use `${admin_ip}` to sync time with ntp server on admin node rather than public ntp server.

```yaml
node_ntp_servers: [ 'pool ${admin_ip} iburst' ]
```





### `node_crontab_overwrite`

参数名称： `node_crontab_overwrite`， 类型： `bool`， 层次：`C`

overwrite or append to `/etc/crontab`?

default value is `true`, and pigsty will render records in [`node_crontab`](#node_crontab) in overwrite mode rather than appending to it.





### `node_crontab`

参数名称： `node_crontab`， 类型： `string[]`， 层次：`C`

crontab entries in `/etc/crontab`

default values: `[]`





------------------------------

## `NODE_VIP`

You can bind an optional L2 VIP among one node cluster, which is disabled by default.

You have to manually assign the `vip_address` and `vip_vrid` for each node cluster.

It is user's responsibility to ensure that the address / vrid is **unique** among your LAN.


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

enable vip on this node cluster?

default value is `false`, means no L2 VIP is created for this node cluster.

L2 VIP can only be used in same L2 LAN, which may incurs extra restrictions on your network topology.



### `vip_address`

参数名称： `vip_address`， 类型： `ip`， 层次：`C`

node vip address in IPv4 format, **required** if node [`vip_enabled`](#vip_enabled).

no default value. This parameter must be explicitly assigned and unique in your LAN.



### `vip_vrid`

参数名称： `vip_address`， 类型： `ip`， 层次：`C`

integer, 1-254, should be unique in same VLAN, **required** if node [`vip_enabled`](#vip_enabled).

no default value. This parameter must be explicitly assigned and unique in your LAN.





### `vip_role`

参数名称： `vip_role`， 类型： `enum`， 层次：`I`

node vip role, could be `master` or `backup`, will be used as initial keepalived state.




### `vip_preempt`

参数名称： `vip_preempt`， 类型： `bool`， 层次：`C/I`

optional, `true/false`, false by default, enable vip preemption

default value is `false`, means no preempt is happening when a backup have higher priority than living master.




### `vip_interface`

参数名称： `vip_interface`， 类型： `string`， 层次：`C/I`

node vip network interface to listen, `eth0` by default.

It should be the same primary intranet interface of your node, which is the IP address you used in the inventory file.

If your node have different interface, you can override it on instance vars




### `vip_dns_suffix`

参数名称： `vip_dns_suffix`， 类型： `string`， 层次：`C/I`

节点集群 L2 VIP 使用的DNS名称，默认是空字符串，即直接使用集群名本身作为DNS名称。





### `vip_exporter_port`

参数名称： `vip_exporter_port`， 类型： `port`， 层次：`C/I`

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

参数名称： `haproxy_enabled`， 类型： `bool`， 层次：`C`

enable haproxy on this node?

default value is `true`




### `haproxy_clean`

参数名称： `haproxy_clean`， 类型： `bool`， 层次：`G/C/A`

cleanup all existing haproxy config?

default value is `false`




### `haproxy_reload`

参数名称： `haproxy_reload`， 类型： `bool`， 层次：`A`

reload haproxy after config?

default value is `true`, it will reload haproxy after config change.

If you wish to check before apply, you can turn off this with cli args and check it.




### `haproxy_auth_enabled`

参数名称： `haproxy_auth_enabled`， 类型： `bool`， 层次：`G`

enable authentication for haproxy admin page

default value is `true`, which will require a http basic auth for admin page.

disable it is not recommended, since your traffic control will be exposed




### `haproxy_admin_username`

参数名称： `haproxy_admin_username`， 类型： `username`， 层次：`G`

haproxy admin username, `admin` by default

default values: `admin`





### `haproxy_admin_password`

参数名称： `haproxy_admin_password`， 类型： `password`， 层次：`G`

haproxy admin password, `pigsty` by default

default values: `pigsty`





### `haproxy_exporter_port`

参数名称： `haproxy_exporter_port`， 类型： `port`， 层次：`C`

haproxy admin/exporter port, 9101 by default

default values: `9101`





### `haproxy_client_timeout`

参数名称： `haproxy_client_timeout`， 类型： `interval`， 层次：`C`

client side connection timeout, 24h by default

default values: `24h`





### `haproxy_server_timeout`

参数名称： `haproxy_server_timeout`， 类型： `interval`， 层次：`C`

server side connection timeout, 24h by default

default values: `24h`





### `haproxy_services`

参数名称： `haproxy_services`， 类型： `service[]`， 层次：`C`

list of haproxy service to be exposed on node

default values: `[]`, each element is a service definition, here is an ad hoc haproxy service example:


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
node_exporter_options: '--no-collector.softnet --no-collector.nvme --collector.ntp --collector.tcpstat --collector.processes'
```



### `node_exporter_enabled`

参数名称： `node_exporter_enabled`， 类型： `bool`， 层次：`C`

setup node_exporter on this node?

default value is `true`




### `node_exporter_port`

参数名称： `node_exporter_port`， 类型： `port`， 层次：`C`

node exporter listen port, 9100 by default

default values: `9100`





### `node_exporter_options`

参数名称： `node_exporter_options`， 类型： `arg`， 层次：`C`

extra server options for node_exporter

default value: `--no-collector.softnet --no-collector.nvme --collector.ntp --collector.tcpstat --collector.processes`

Pigsty enables `ntp`, `tcpstat`, `processes` three extra metrics, collectors, by default, and disables `softnet`, `nvme` metrics collectors by default.





------------------------------

## `PROMTAIL`

Promtail will collect logs from other modules, and send them to [`LOKI`](#loki)

* `INFRA`: Infra logs, collected only on meta nodes.
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

!> Log directory are customizable according to [`pg_log_dir`](#pg_log_dir), [`patroni_log_dir`](#patroni_log_dir), [`pgbouncer_log_dir`](#pgbouncer_log_dir), [`pgbackrest_log_dir`](#pgbackrest_log_dir)



```yaml
promtail_enabled: true            # enable promtail logging collector?
promtail_clean: false             # purge existing promtail status file during init?
promtail_port: 9080               # promtail listen port, 9080 by default
promtail_positions: /var/log/positions.yaml # promtail position status file path
```



### `promtail_enabled`

参数名称： `promtail_enabled`， 类型： `bool`， 层次：`C`

enable promtail logging collector?

default value is `true`




### `promtail_clean`

参数名称： `promtail_clean`， 类型： `bool`， 层次：`G/A`

purge existing promtail status file during init?

default value is `false`, if you choose to clean, Pigsty will remove the existing state file defined by [`promtail_positions`](#promtail_positions)
which means that Promtail will recollect all logs on the current node and send them to Loki again.




### `promtail_port`

参数名称： `promtail_port`， 类型： `port`， 层次：`C`

promtail listen port, 9080 by default

default values: `9080`





### `promtail_positions`

参数名称： `promtail_positions`， 类型： `path`， 层次：`C`

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

参数名称： `docker_enabled`， 类型： `bool`， 层次：`C`

enable docker on this node? default value is `false`




### `docker_cgroups_driver`

参数名称： `docker_cgroups_driver`， 类型： `enum`， 层次：`C`

docker cgroup fs driver, could be `cgroupfs` or `systemd`, default values: `systemd`





### `docker_registry_mirrors`

参数名称： `docker_registry_mirrors`， 类型： `string[]`， 层次：`C`

docker registry mirror list, default values: `[]`, Example: 

```yaml
[ "https://mirror.ccs.tencentyun.com" ]         # tencent cloud mirror, intranet only
["https://registry.cn-hangzhou.aliyuncs.com"]   # aliyun cloud mirror, login required
```



### `docker_image_cache`

参数名称： `docker_image_cache`， 类型： `path`， 层次：`C`

docker image cache dir, `/tmp/docker` by default.

The local docker image cache with `.tgz` suffix under this directory will be loaded into docker one by one:

```bash
cat {{ docker_image_cache }}/*.tgz | gzip -d -c - | docker load
```





------------------------------------------------------------

# `ETCD`

[ETCD](ETCD) is a distributed, reliable key-value store for the most critical data of a distributed system,
and pigsty use **etcd** as **DCS**, Which is critical to PostgreSQL High-Availability.

Pigsty has a hard coded group name `etcd` for etcd cluster, it can be an existing & external etcd cluster, or a new etcd cluster created by pigsty with `etcd.yml`.


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

参数名称： `etcd_seq`， 类型： `int`， 层次：`I`

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

参数名称： `etcd_cluster`， 类型： `string`， 层次：`C`

etcd cluster & group name, etcd by default

default values: `etcd`, which is a fixed group name, can be useful when you want to use deployed some extra etcd clusters





### `etcd_safeguard`

参数名称： `etcd_safeguard`， 类型： `bool`， 层次：`G/C/A`

prevent purging running etcd instance? default value is `false`

If enabled, running etcd instance will not be purged by `etcd.yml` playbook.




### `etcd_clean`

参数名称： `etcd_clean`， 类型： `bool`， 层次：`G/C/A`

purging existing etcd during initialization? default value is `true`

If enabled, running etcd instance will be purged by `etcd.yml` playbook, which makes `etcd.yml` a truly idempotent playbook.

But if [`etcd_safeguard`](#etcd_safeguard) is enabled, it will still abort on any running etcd instance.





### `etcd_data`

参数名称： `etcd_data`， 类型： `path`， 层次：`C`

etcd data directory, `/data/etcd` by default






### `etcd_port`

参数名称： `etcd_port`， 类型： `port`， 层次：`C`

etcd client port, `2379` by default





### `etcd_peer_port`

参数名称： `etcd_peer_port`， 类型： `port`， 层次：`C`

etcd peer port, `2380` by default





### `etcd_init`

参数名称： `etcd_init`， 类型： `enum`， 层次：`C`

etcd initial cluster state, `new` or `existing`

default values: `new`, which will create a standalone new etcd cluster.

The value `existing` is used when trying to [add new member](ETCD#添加成员) to existing etcd cluster.





### `etcd_election_timeout`

参数名称： `etcd_election_timeout`， 类型： `int`， 层次：`C`

etcd election timeout, `1000` (ms) by default





### `etcd_heartbeat_interval`

参数名称： `etcd_heartbeat_interval`， 类型： `int`， 层次：`C`

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

参数名称： `minio_seq`， 类型： `int`， 层次：`I`

minio instance identifier, REQUIRED identity parameters. no default value, you have to assign it manually





### `minio_cluster`

参数名称： `minio_cluster`， 类型： `string`， 层次：`C`

minio cluster name, `minio` by default. This is useful when deploying multiple MinIO clusters







### `minio_clean`

参数名称： `minio_clean`， 类型： `bool`， 层次：`G/C/A`

cleanup minio during init?, `false` by default






### `minio_user`

参数名称： `minio_user`， 类型： `username`， 层次：`C`

minio os user name, `minio` by default






### `minio_node`

参数名称： `minio_node`， 类型： `string`， 层次：`C`

minio node name pattern, this is used for [multi-node](MINIO#multi-node-multi-drive) deployment

default values: `${minio_cluster}-${minio_seq}.pigsty`





### `minio_data`

参数名称： `minio_data`， 类型： `path`， 层次：`C`

minio data dir(s)

default values: `/data/minio`, which is a common dir for [single-node](MINIO#single-node-single-drive) deployment.

For a [multi-drive](MINIO#single-node-multi-drive) deployment, you can use `{x...y}` notion to specify multi drivers.





### `minio_domain`

参数名称： `minio_domain`， 类型： `string`， 层次：`G`

minio service domain name, `sss.pigsty` by default.

The client can access minio S3 service via this domain name. This name will be registered to local DNSMASQ and included in SSL certs.






### `minio_port`

参数名称： `minio_port`， 类型： `port`， 层次：`C`

minio service port, `9000` by default





### `minio_admin_port`

参数名称： `minio_admin_port`， 类型： `port`， 层次：`C`

minio console port, `9001` by default





### `minio_access_key`

参数名称： `minio_access_key`， 类型： `username`， 层次：`C`

root access key, `minioadmin` by default

!> PLEASE CHANGE THIS IN YOUR DEPLOYMENT






### `minio_secret_key`

参数名称： `minio_secret_key`， 类型： `password`， 层次：`C`

root secret key, `minioadmin` by default

default values: `minioadmin`

!> PLEASE CHANGE THIS IN YOUR DEPLOYMENT




### `minio_extra_vars`

参数名称： `minio_extra_vars`， 类型： `string`， 层次：`C`

extra environment variables for minio server. Check [Minio Server](https://min.io/docs/minio/linux/reference/minio-server/minio-server.html) for the complete list.

default value is empty string, you can use multiline string to passing multiple environment variables.





### `minio_alias`

参数名称： `minio_alias`， 类型： `string`， 层次：`G`

MinIO alias name for the local MinIO cluster

default values: `sss`, which will be written to infra nodes' / admin users' client alias profile.





### `minio_buckets`

参数名称： `minio_buckets`， 类型： `bucket[]`， 层次：`C`

list of minio bucket to be created by default:

```yaml
minio_buckets: [ { name: pgsql }, { name: infra },  { name: redis } ]
```

Three default buckets are created for module [`PGSQL`](PGSQL), [`INFRA`](INFRA), and [`REDIS`](REDIS)




### `minio_users`

参数名称： `minio_users`， 类型： `user[]`， 层次：`C`

list of minio user to be created, default value:

```yaml
minio_users:
  - { access_key: dba , secret_key: S3User.DBA, policy: consoleAdmin }
  - { access_key: pgbackrest , secret_key: S3User.Backup, policy: readwrite }
```

Two default users are created for PostgreSQL DBA and pgBackREST.

!> PLEASE ADJUST THESE USERS & CREDENTIALS IN YOUR DEPLOYMENT!






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

All other params can be inherited from the global config or the default config, but the identity params must be **explicitly specified** and **manually assigned**. The current PGSQL identity params are as follows:




### `pg_mode`

参数名称： `pg_mode`， 类型： `enum`， 层次：`C`

pgsql cluster mode, cloud be `pgsql`, `citus`, or `gpsql`, `pgsql` by default.

If `pg_mode` is set to `citus` or `gpsql`, [`pg_shard`](#pg_shard) and [`pg_group`](#pg_group) will be required for horizontal sharding clusters.





### `pg_cluster`

参数名称： `pg_cluster`， 类型： `string`， 层次：`C`

pgsql cluster name, REQUIRED identity parameter

The cluster name will be used as the namespace for PGSQL related resources within that cluster.

The naming needs to follow the specific naming pattern: `[a-z][a-z0-9-]*` to be compatible with the requirements of different constraints on the identity.




### `pg_seq`

参数名称： `pg_seq`， 类型： `int`， 层次：`I`

pgsql instance seq number, REQUIRED identity parameter

A serial number of this instance, unique within its **cluster**, starting from 0 or 1.




### `pg_role`

参数名称： `pg_role`， 类型： `enum`， 层次：`I`

pgsql role, REQUIRED, could be primary,replica,offline

Roles for PGSQL instance, can be: `primary`, `replica`, `standby` or `offline`.

* `primary`: Primary, there is one and only one primary in a cluster.
* `replica`: Replica for carrying online read-only traffic, there may be a slight replication delay through (10ms~100ms, 100KB).
* `standby`: Special replica that is always synced with primary, there's no replication delay & data loss on this replica. (currently same as `replica`)
* `offline`: Offline replica for taking on offline read-only traffic, such as statistical analysis/ETL/personal queries, etc.

**Identity params, required params, and instance-level params.**





### `pg_instances`

参数名称： `pg_instances`， 类型： `dict`， 层次：`I`

define multiple pg instances on node in `{port:ins_vars}` format.

This parameter is reserved for multi-instance deployment on a single node which is not implemented in Pigsty yet. 





### `pg_upstream`

参数名称： `pg_upstream`， 类型： `ip`， 层次：`I`

Upstream ip address for standby cluster or cascade replica

Setting `pg_upstream` is set on `primary` instance indicate that this cluster is a [**Standby Cluster**](PGSQL-CONF#standby-cluster), and will receiving changes from upstream instance, thus the `primary` is actually a `standby leader`.

Setting `pg_upstream` for a non-primary instance will explicitly set a replication upstream instance, if it is different from the primary ip addr, this instance will become a **cascade replica**. And it's user's responsibility to ensure that the upstream IP addr is another instance in the same cluster.





### `pg_shard`

参数名称： `pg_shard`， 类型： `string`， 层次：`C`

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

参数名称： `pg_group`， 类型： `int`， 层次：`C`

pgsql shard index number, required identity for sharding clusters, optional for common pgsql clusters.

Sharding cluster index of sharding group, used in pair with [pg_shard](#pg_shard). You can use any non-negative integer as the index number.





### `gp_role`

参数名称： `gp_role`， 类型： `enum`， 层次：`C`

greenplum/matrixdb role of this cluster, could be `master` or `segment`

- `master`:  mark the postgres cluster as greenplum master, which is the default value
- `segment`  mark the postgres cluster as greenplum segment

This parameter is only used for greenplum/matrixdb database, and is ignored for common pgsql cluster.





### `pg_exporters`

参数名称： `pg_exporters`， 类型： `dict`， 层次：`C`

additional pg_exporters to monitor remote postgres instances, default values: `{}`

If you wish to monitoring remote postgres instances, define them in `pg_exporters` and load them with `pgsql-monitor.yml` playbook.

```
pg_exporters: # list all remote instances here, alloc a unique unused local port as k
    20001: { pg_cluster: pg-foo, pg_seq: 1, pg_host: 10.10.10.10 }
    20004: { pg_cluster: pg-foo, pg_seq: 2, pg_host: 10.10.10.11 }
    20002: { pg_cluster: pg-bar, pg_seq: 1, pg_host: 10.10.10.12 }
    20003: { pg_cluster: pg-bar, pg_seq: 1, pg_host: 10.10.10.13 }
```

Check [PGSQL Monitoring](PGSQL-MONITOR) for details.




### `pg_offline_query`

参数名称： `pg_offline_query`， 类型： `bool`， 层次：`I`

set to true to enable offline query on this instance

default value is `false`

When set to `true`, the user group `dbrole_offline` can connect to the ins and perform offline queries, regardless of the role of the current instance, just like a `offline` instance.

If you just have one replica or even one primary in your postgres cluster, adding this could mark it for accepting ETL, slow queries with interactive access.







------------------------------

## `PG_BUSINESS`

Database credentials, In-Database Objects that need to be taken care of by Users.

!> WARNING: YOU HAVE TO CHANGE THESE DEFAULT **PASSWORD**s in production environment.


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

postgres business users, has to be defined at cluster level.

default values: `[]`, each object in the array defines a [User/Role](PGSQL-USER). Examples:

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
* `pool_mode`, `pool_connlimit` are user-level pgbouncer parameters that will override default settings.
* Users can use pre-defined [pg_default_roles](#pg_default_roles) with `roles` field:
    * `dbrole_readonly`: Default production read-only user with global read-only privileges. (Read-only production access)
    * `dbrole_offline`: Default offline read-only user with read-only access on a specific ins. (offline query, personal account, ETL)
    * `dbrole_readwrite`: Default production read/write user with global CRUD privileges. (Regular production use)
    * `dbrole_admin`: Default production management user with the privilege to execute DDL changes. (Admin User)

Configure `pgbouncer: true` for the production account to add the user to pgbouncer; It's important to use a connection pool if you got thousands of clients.





### `pg_databases`

参数名称： `pg_databases`， 类型： `database[]`， 层次：`C`

postgres business databases, has to be defined at cluster level.

default values: `[]`, each object in the array defines a **Database**. Examples:


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

In each database definition, the DB  `name` is mandatory and the rest are optional.






### `pg_services`

参数名称： `pg_services`， 类型： `service[]`， 层次：`C`

postgres business services exposed via haproxy, has to be defined at cluster level.

You can define ad hoc services with [`pg_services`](#pg_services) in additional to default [`pg_default_services`](#pg_default_services)

default values: `[]`, each object in the array defines a **Service**. Examples:


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






### `pg_hba_rules`

参数名称： `pg_hba_rules`， 类型： `hba[]`， 层次：`C`

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

参数名称： `pgb_hba_rules`， 类型： `hba[]`， 层次：`C`

business hba rules for pgbouncer, default values: `[]`

Similar to [`pg_hba_rules`](#pg_hba_rules), array of [hba](PGSQL-HBA#define-hba) rule object, except this is for pgbouncer.






### `pg_replication_username`

参数名称： `pg_replication_username`， 类型： `username`， 层次：`G`

postgres replication username, `replicator` by default

This parameter is globally used, it not wise to change it.





### `pg_replication_password`

参数名称： `pg_replication_password`， 类型： `password`， 层次：`G`

postgres replication password, `DBUser.Replicator` by default

!> WARNING: CHANGE THIS IN PRODUCTION ENVIRONMENT!!!!





### `pg_admin_username`

参数名称： `pg_admin_username`， 类型： `username`， 层次：`G`

postgres admin username, `dbuser_dba` by default, which is a global postgres superuser.

default values: `dbuser_dba`





### `pg_admin_password`

参数名称： `pg_admin_password`， 类型： `password`， 层次：`G`

postgres admin password in plain text, `DBUser.DBA` by default

!> WARNING: CHANGE THIS IN PRODUCTION ENVIRONMENT!!!!





### `pg_monitor_username`

参数名称： `pg_monitor_username`， 类型： `username`， 层次：`G`

postgres monitor username, `dbuser_monitor` by default, which is a global monitoring user.





### `pg_monitor_password`

参数名称： `pg_monitor_password`， 类型： `password`， 层次：`G`

postgres monitor password, `DBUser.Monitor` by default.

!> WARNING: CHANGE THIS IN PRODUCTION ENVIRONMENT!!!!




### `pg_dbsu_password`

参数名称： `pg_dbsu_password`， 类型： `password`， 层次：`G/C`

PostgreSQL dbsu password for [`pg_dbsu`](#pg_dbsu), empty string means no dbsu password, which is the default behavior.

!> WARNING: It's not recommend to set a dbsu password for common PGSQL clusters, except for [`pg_mode`](#pg_mode) = `citus`.








------------------------------

## `PG_INSTALL`

This section is responsible for installing PostgreSQL & Extensions.

If you wish to install a different major version, just make sure repo packages exists and overwrite [`pg_version`](#pg_version) on cluster level.


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

参数名称： `pg_dbsu`， 类型： `username`， 层次：`C`

os dbsu name, `postgres` by default, it's not wise to change it.

When installing Greenplum / MatrixDB, set this parameter to the corresponding default value: `gpadmin|mxadmin`.




### `pg_dbsu_uid`

参数名称： `pg_dbsu_uid`， 类型： `int`， 层次：`C`

os dbsu uid and gid, `26` for default postgres users and groups, which is consistent with the official pgdg RPM.






### `pg_dbsu_sudo`

参数名称： `pg_dbsu_sudo`， 类型： `enum`， 层次：`C`

dbsu sudo privilege, coud be `none`, `limit` ,`all` ,`nopass`. `limit` by default

* `none`: No Sudo privilege
* `limit`: Limited sudo privilege to execute systemctl commands for database-related components, default.
* `all`: Full `sudo` privilege, password required.
* `nopass`: Full `sudo` privileges without a password (not recommended).

default values: `limit`, which only allow `sudo systemctl <start|stop|reload> <postgres|patroni|pgbouncer|...> `





### `pg_dbsu_home`

参数名称： `pg_dbsu_home`， 类型： `path`， 层次：`C`

postgresql home directory, `/var/lib/pgsql` by default, which is consistent with the official pgdg RPM.






### `pg_dbsu_ssh_exchange`

参数名称： `pg_dbsu_ssh_exchange`， 类型： `bool`， 层次：`C`

exchange postgres dbsu ssh key among same pgsql cluster?

default value is `true`, means the dbsu can ssh to each other among the same cluster.





### `pg_version`

参数名称： `pg_version`， 类型： `enum`， 层次：`C`

postgres major version to be installed, `15` by default

Note that PostgreSQL physical stream replication cannot cross major versions, so do not configure this on instance level.

You can use the parameters in [`pg_packages`](#pg_packages) and [`pg_extensions`](#pg_extensions) to install rpms for the specific pg major version.





### `pg_bin_dir`

参数名称： `pg_bin_dir`， 类型： `path`， 层次：`C`

postgres binary dir, `/usr/pgsql/bin` by default

The default value is a soft link created manually during the installation process, pointing to the specific Postgres version dir installed.

For example `/usr/pgsql -> /usr/pgsql-15`. For more details, check [PGSQL File Structure](FHS#postgres-fhs) for details.




### `pg_log_dir`

参数名称： `pg_log_dir`， 类型： `path`， 层次：`C`

postgres log dir, `/pg/log/postgres` by default.

!> caveat: if `pg_log_dir` is prefixed with `pg_data` it will not be created explicit (it will be created by postgres itself then).




### `pg_packages`

参数名称： `pg_packages`， 类型： `string[]`， 层次：`C`

pg packages to be installed, `${pg_version}` will be replaced to the actual value of [`pg_version`](#pg_version)

PostgreSQL, pgbouncer, pg_exporter, pgbadger, vip-manager, patroni, pgbackrest are install by default.

```yaml
pg_packages:                      # pg packages to be installed, `${pg_version}` will be replaced
  - postgresql${pg_version}*
  - pgbouncer pg_exporter pgbadger vip-manager patroni patroni-etcd pgbackrest
```

对于 Ubuntu 来说，合适的取值为：

```yaml
pg_packages:                      # pg packages to be installed, `${pg_version}` will be replaced (ubuntu version)
  - postgresql-*-${pg_version}
  - patroni pgbouncer pgbackrest pg-exporter pgbadger vip-manager2
```




### `pg_extensions`

参数名称： `pg_extensions`， 类型： `string[]`， 层次：`C`

pg extensions to be installed, `${pg_version}` will be replaced to [`pg_version`](#pg_version)

PostGIS, TimescaleDB, PGVector, `pg_repack`， `wal2json`，以及 `passwordcheck_cracklib` 会被默认安装。

```yaml
pg_extensions:                    # pg extensions to be installed, `${pg_version}` will be replaced
  - pg_repack_${pg_version}* wal2json_${pg_version}* passwordcheck_cracklib_${pg_version}*
  - postgis34_${pg_version}* timescaledb-2-postgresql-${pg_version}* pgvector_${pg_version}*
```





------------------------------

## `PG_BOOTSTRAP`

Bootstrap a postgres cluster with patroni, and setup pgbouncer connection pool along with it.

It also init cluster template databases with default roles, schemas & extensions & default privileges.

Then it will create business databases & users and add them to pgbouncer & monitoring system

On a machine with Postgres, create a set of databases.


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

prevent purging running postgres instance? false by default

default value is `false`, If enabled, `pgsql.yml` & `pgsql-rm.yml` will abort immediately if any postgres instance is running.




### `pg_clean`

参数名称： `pg_clean`， 类型： `bool`， 层次：`G/C/A`

purging existing postgres during pgsql init? true by default

default value is `true`, it will purge existing postgres instance during `pgsql.yml` init. which makes the playbook idempotent.

if set to `false`, `pgsql.yml` will abort if there's already a running postgres instance. and `pgsql-rm.yml` will NOT remove postgres data (only stop the server).




### `pg_data`

参数名称： `pg_data`， 类型： `path`， 层次：`C`

postgres data directory, `/pg/data` by default

default values: `/pg/data`, DO NOT CHANGE IT.

It's a soft link that point to underlying data directory. 

Check [PGSQL File Structure](FHS) for details. 





### `pg_fs_main`

参数名称： `pg_fs_main`， 类型： `path`， 层次：`C`

mountpoint/path for postgres main data, `/data` by default

default values: `/data`, which will be used as parent dir of postgres main data directory: `/data/postgres`.

It's recommended to use NVME SSD for postgres main data storage, Pigsty is optimized for SSD storage by default.
But HDD is also supported, you can change [`pg_storage_type`](#pg_storage_type) to `HDD` to optimize for HDD storage.






### `pg_fs_bkup`

参数名称： `pg_fs_bkup`， 类型： `path`， 层次：`C`

mountpoint/path for pg backup data, `/data/backup` by default

If you are using the default [`pgbackrest_method`](#pgbackrest_method) = `local`, it is recommended to have a separate disk for backup storage.

The backup disk should be large enough to hold all your backups, at least enough for 3 basebackups + 2 days WAL archive.
This is usually not a problem since you can use cheap & large HDD for that.

It's recommended to use a separate disk for backup storage, otherwise pigsty will fall back to the main data disk.





### `pg_storage_type`

参数名称： `pg_storage_type`， 类型： `enum`， 层次：`C`

storage type for pg main data, `SSD`,`HDD`, `SSD` by default

default values: `SSD`, it will affect some tuning parameters, such as `random_page_cost` & `effective_io_concurrency`





### `pg_dummy_filesize`

参数名称： `pg_dummy_filesize`， 类型： `size`， 层次：`C`

size of `/pg/dummy`, default values: `64MiB`, which hold 64MB disk space for emergency use

When the disk is full, removing the placeholder file can free up some space for emergency use, it is recommended to use at least `8GiB` for production use.





### `pg_listen`

参数名称： `pg_listen`， 类型： `ip`， 层次：`C`

postgres/pgbouncer listen address, `0.0.0.0` (all ipv4 addr) by default

You can use placeholder in this variable:

* `${ip}`: translate to inventory_hostname, which is primary private IP address in the inventory
* `${vip}`: if [`pg_vip_enabled`](#pg_vip_enabled), this will translate to host part of [`pg_vip_address`](#pg_vip_address)
* `${lo}`: will translate to `127.0.0.1`

For example: `'${ip},${lo}'` or `'${ip},${vip},${lo}'`.





### `pg_port`

参数名称： `pg_port`， 类型： `port`， 层次：`C`

postgres listen port, `5432` by default.





### `pg_localhost`

参数名称： `pg_localhost`， 类型： `path`， 层次：`C`

postgres unix socket dir for localhost connection, default values: `/var/run/postgresql`

The Unix socket dir for PostgreSQL and Pgbouncer local connection, which is used by [`pg_exporter`](#pg_exporter) and patroni.





### `pg_namespace`

参数名称： `pg_namespace`， 类型： `path`， 层次：`C`

top level key namespace in etcd, used by patroni & vip, default values is: `/pg` , and it's not recommended to change it.





### `patroni_enabled`

参数名称： `patroni_enabled`， 类型： `bool`， 层次：`C`

if disabled, no postgres cluster will be created during init

default value is `true`, If disabled, Pigsty will skip pulling up patroni (thus postgres).

This option is useful when trying to add some components to an existing postgres instance.




### `patroni_mode`

参数名称： `patroni_mode`， 类型： `enum`， 层次：`C`

patroni working mode: `default`, `pause`, `remove`

default values: `default`

* `default`: Bootstrap PostgreSQL cluster with Patroni
* `pause`: Just like `default`, but entering maintenance mode after bootstrap
* `remove`: Init the cluster with Patroni, them remove Patroni and use raw PostgreSQL instead.




### `patroni_port`

参数名称： `patroni_port`， 类型： `port`， 层次：`C`

patroni listen port, `8008` by default, changing it is not recommended.

The Patroni API server listens on this port for health checking & API requests.




### `patroni_log_dir`

参数名称： `patroni_log_dir`， 类型： `path`， 层次：`C`

patroni log dir, `/pg/log/patroni` by default, which will be collected by [`promtail`](#promtail).







### `patroni_ssl_enabled`

参数名称： `patroni_ssl_enabled`， 类型： `bool`， 层次：`G`

Secure patroni RestAPI communications with SSL? default value is `false`

This parameter is a global flag that can only be set before deployment.

Since if SSL is enabled for patroni, you'll have to perform healthcheck, metrics scrape and API call with HTTPS instead of HTTP. 







### `patroni_watchdog_mode`

参数名称： `patroni_watchdog_mode`， 类型： `string`， 层次：`C`

In case of primary failure, patroni can use [watchdog](https://patroni.readthedocs.io/en/latest/watchdog.html) to shutdown the old primary node to avoid split-brain.

patroni watchdog mode: `automatic`, `required`, `off`:

* `off`: not using `watchdog`. avoid fencing at all. This is the default value.
* `automatic`: Enable `watchdog` if the kernel has `softdog` module enabled and watchdog is owned by dbsu 
* `required`: Force `watchdog`, refuse to start if `softdog` is not available

default value is `off`, you should not enable watchdog on infra nodes to avoid fencing.

For those critical systems where data consistency prevails over availability, it is recommended to enable watchdog.






### `patroni_username`

参数名称： `patroni_username`， 类型： `username`， 层次：`C`

patroni restapi username, `postgres` by default, used in pair with [`patroni_password`](#patroni_password)

Patroni unsafe RESTAPI is protected by username/password by default, check [Config Cluster](PGSQL-ADMIN#配置集群) and [Patroni RESTAPI](https://patroni.readthedocs.io/en/latest/rest_api.html) for details. 




### `patroni_password`

参数名称： `patroni_password`， 类型： `password`， 层次：`C`

patroni restapi password, `Patroni.API` by default

!> WARNING: CHANGE THIS IN PRODUCTION ENVIRONMENT!!!!





### `patroni_citus_db`

参数名称： `patroni_citus_db`， 类型： `string`， 层次：`C`

citus database managed by patroni, `postgres` by default.

Patroni 3.0's native citus will specify a managed database for citus. which is created by patroni itself.




### `pg_conf`

参数名称： `pg_conf`， 类型： `enum`， 层次：`C`

config template: `{oltp,olap,crit,tiny}.yml`, `oltp.yml` by default

- `tiny.yml`: optimize for tiny nodes, virtual machines, small demo, (1~8Core, 1~16GB)
- `oltp.yml`: optimize for OLTP workloads and latency sensitive applications, (4C8GB+), which is the default template
- `olap.yml`: optimize for OLAP workloads and throughput (4C8G+)
- `crit.yml`: optimize for data consistency and critical applications (4C8G+) 

default values: `oltp.yml`, but [configure](INSTALL#configure) procedure will set this value to `tiny.yml` if current node is a tiny node.

You can have your own template, just put it under `templates/<mode>.yml` and set this value to the template name.





### `pg_max_conn`

参数名称： `pg_max_conn`， 类型： `int`， 层次：`C`

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

参数名称： `pg_shared_buffer_ratio`， 类型： `float`， 层次：`C`

postgres shared buffer memory ratio, 0.25 by default, 0.1~0.4

default values: `0.25`, means 25% of node memory will be used as PostgreSQL shard buffers.

Setting this value greater than 0.4 (40%) is usually not a good idea. 

Note that shared buffer is only part of shared memory in PostgreSQL, to calculate the total shared memory, use `show shared_memory_size_in_huge_pages;`.




### `pg_rto`

参数名称： `pg_rto`， 类型： `int`， 层次：`C`

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

参数名称： `pg_rpo`， 类型： `int`， 层次：`C`

recovery point objective in bytes, `1MiB` at most by default

default values: `1048576`, which will tolerate at most 1MiB data loss during failover.

when the primary is down and all replicas are lagged, you have to make a tough choice to **trade off between Availability and Consistency**:

* Promote a replica to be the new primary and bring system back online ASAP, with the price of an acceptable data loss (e.g. less than 1MB).
* Wait for the primary to come back (which may never be) or human intervention to avoid any data loss.

You can use `crit.yml` [conf](#pg_conf) template to ensure no data loss during failover, but it will sacrifice some performance.
 






### `pg_libs`

参数名称： `pg_libs`， 类型： `string`， 层次：`C`

preloaded libraries, `timescaledb,pg_stat_statements,auto_explain` by default

default value: `timescaledb, pg_stat_statements, auto_explain`.

If you want to manage citus cluster by your own, add `citus` to the head of this list.
If you are using patroni native citus cluster, patroni will add it automatically for you.





### `pg_delay`

参数名称： `pg_delay`， 类型： `interval`， 层次：`I`

replication apply delay for standby cluster leader , default values: `0`.

if this value is set to a positive value, the standby cluster leader will be delayed for this time before apply WAL changes.

Check [delayed standby cluster](PGSQL-CONF#delayed-cluster) for details.





### `pg_checksum`

参数名称： `pg_checksum`， 类型： `bool`， 层次：`C`

enable data checksum for postgres cluster?, default value is `false`.

This parameter can only be set before PGSQL deployment. (but you can enable it manually later)

If [`pg_conf`](#pg_conf) `crit.yml` template is used, data checksum is always enabled regardless of this parameter to ensure data integrity.




### `pg_pwd_enc`

参数名称： `pg_pwd_enc`， 类型： `enum`， 层次：`C`

passwords encryption algorithm: md5,scram-sha-256

default values: `scram-sha-256`, if you have compatibility issues with old clients, you can set it to `md5` instead. 





### `pg_encoding`

参数名称： `pg_encoding`， 类型： `enum`， 层次：`C`

database cluster encoding, `UTF8` by default





### `pg_locale`

参数名称： `pg_locale`， 类型： `enum`， 层次：`C`

database cluster local, `C` by default






### `pg_lc_collate`

参数名称： `pg_lc_collate`， 类型： `enum`， 层次：`C`

database cluster collate, `C` by default, It's not recommended to change this value unless you know what you are doing.





### `pg_lc_ctype`

参数名称： `pg_lc_ctype`， 类型： `enum`， 层次：`C`

database character type, `en_US.UTF8` by default






### `pgbouncer_enabled`

参数名称： `pgbouncer_enabled`， 类型： `bool`， 层次：`C`

default value is `true`, if disabled, pgbouncer will not be launched on pgsql host






### `pgbouncer_port`

参数名称： `pgbouncer_port`， 类型： `port`， 层次：`C`

pgbouncer listen port, `6432` by default






### `pgbouncer_log_dir`

参数名称： `pgbouncer_log_dir`， 类型： `path`， 层次：`C`

pgbouncer log dir, `/pg/log/pgbouncer` by default, referenced by promtail the logging agent.






### `pgbouncer_auth_query`

参数名称： `pgbouncer_auth_query`， 类型： `bool`， 层次：`C`

query postgres to retrieve unlisted business users? default value is `false`

If enabled, pgbouncer user will be authenticated against postgres database with `SELECT username, password FROM monitor.pgbouncer_auth($1)`, otherwise, only the users in `pgbouncer_users` will be allowed to connect to pgbouncer.





### `pgbouncer_poolmode`

参数名称： `pgbouncer_poolmode`， 类型： `enum`， 层次：`C`

pooling mode: transaction,session,statement, `transaction` by default

* `session`, Session-level pooling with the best compatibility.
* `transaction`, Transaction-level pooling with better performance (lots of small conns), could break some session level features such as PreparedStatements, notify, etc... 
* `statements`, Statement-level pooling which is used for simple read-only queries.





### `pgbouncer_sslmode`

参数名称： `pgbouncer_sslmode`， 类型： `enum`， 层次：`C`

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

Init database roles, templates, default privileges, create schemas, extensions, and generate hba rules

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

参数名称： `pg_provision`， 类型： `bool`， 层次：`C`

provision postgres cluster after bootstrap, default value is `true`.

If disabled, postgres cluster will not be provisioned after bootstrap.





### `pg_init`

参数名称： `pg_init`， 类型： `string`， 层次：`G/C`

Provision init script for cluster template, `pg-init` by default, which is located in [`roles/pgsql/templates/pg-init`](https://github.com/Vonng/pigsty/blob/master/roles/pgsql/templates/pg-init)

You can add your own logic in the init script, or provide a new one in `templates/` and set `pg_init` to the new script name.






### `pg_default_roles`

参数名称： `pg_default_roles`， 类型： `role[]`， 层次：`G/C`

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

参数名称： `pg_default_privileges`， 类型： `string[]`， 层次：`G/C`

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

参数名称： `pg_default_schemas`， 类型： `string[]`， 层次：`G/C`

default schemas to be created, default values is: `[ monitor ]`, which will create a `monitor` schema on all databases.





### `pg_default_extensions`

参数名称： `pg_default_extensions`， 类型： `extension[]`， 层次：`G/C`

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

参数名称： `pg_reload`， 类型： `bool`， 层次：`A`

reload postgres after hba changes, default value is `true`

This is useful when you want to check before applying HBA changes, set it to `false` to disable reload.





### `pg_default_hba_rules`

参数名称： `pg_default_hba_rules`， 类型： `hba[]`， 层次：`G/C`

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

参数名称： `pgbackrest_enabled`， 类型： `bool`， 层次：`C`

enable pgBackRest on pgsql host? default value is `true`





### `pgbackrest_clean`

参数名称： `pgbackrest_clean`， 类型： `bool`， 层次：`C`

remove pg backup data during init?  default value is `true`




### `pgbackrest_log_dir`

参数名称： `pgbackrest_log_dir`， 类型： `path`， 层次：`C`

pgBackRest log dir, `/pg/log/pgbackrest` by default, which is referenced by [`promtail`](#promtail) the logging agent.





### `pgbackrest_method`

参数名称： `pgbackrest_method`， 类型： `enum`， 层次：`C`

pgBackRest repo method: `local`, `minio`, or other user-defined methods, `local` by default

This parameter is used to determine which repo to use for pgBackRest, all available repo methods are defined in [`pgbackrest_repo`](#pgbackrest_repo).

Pigsty will use `local` backup repo by default, which will create a backup repo on primary instance's `/pg/backup` directory. The underlying storage is specified by [`pg_fs_bkup`](#pg_fs_bkup).





### `pgbackrest_repo`

参数名称： `pgbackrest_repo`， 类型： `dict`， 层次：`G/C`

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

参数名称： `pg_weight`， 类型： `int`， 层次：`G`

relative load balance weight in service, 100 by default, 0-255

default values: `100`. you have to define it at instance vars, and [reload-service](PGSQL-ADMIN#重载服务) to take effect.




### `pg_service_provider`

参数名称： `pg_service_provider`， 类型： `string`， 层次：`G/C`

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

参数名称： `pg_default_service_dest`， 类型： `enum`， 层次：`G/C`

When defining a [service](PGSQL-SVC#define-service), if svc.dest='default', this parameter will be used as the default value.

default values: `pgbouncer`, means 5433 primary service and 5434 replica service will route traffic to pgbouncer by default.

If you don't want to use pgbouncer, set it to `postgres` instead. traffic will be route to postgres directly.






### `pg_default_services`

参数名称： `pg_default_services`， 类型： `service[]`， 层次：`G/C`

postgres default service definitions

default value is four default services definition, which is explained in [PGSQL Service](PGSQL-SVC#服务概述)

```yaml
pg_default_services:               # postgres default service definitions
  - { name: primary ,port: 5433 ,dest: default  ,check: /primary   ,selector: "[]" }
  - { name: replica ,port: 5434 ,dest: default  ,check: /read-only ,selector: "[]" , backup: "[? pg_role == `primary` || pg_role == `offline` ]" }
  - { name: default ,port: 5436 ,dest: postgres ,check: /primary   ,selector: "[]" }
  - { name: offline ,port: 5438 ,dest: postgres ,check: /replica   ,selector: "[? pg_role == `offline` || pg_offline_query ]" , backup: "[? pg_role == `replica` && !pg_offline_query]"}
```






### `pg_vip_enabled`

参数名称： `pg_vip_enabled`， 类型： `bool`， 层次：`C`

enable a l2 vip for pgsql primary?

default value is `false`, means no L2 VIP is created for this cluster.

L2 VIP can only be used in same L2 network, which may incurs extra restrictions on your network topology.





### `pg_vip_address`

参数名称： `pg_vip_address`， 类型： `cidr4`， 层次：`C`

vip address in `<ipv4>/<mask>` format, if vip is enabled, this parameter is required.

default values: `127.0.0.1/24`. This value is consist of two parts: `ipv4` and `mask`, separated by `/`.





### `pg_vip_interface`

参数名称： `pg_vip_interface`， 类型： `string`， 层次：`C/I`

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
        # pg_vip_interface: eth1      # if your node have uniform interface, you can define it here
```




### `pg_dns_suffix`

参数名称： `pg_dns_suffix`， 类型： `string`， 层次：`C`

pgsql dns suffix, '' by default, cluster DNS name is defined as `{{ pg_cluster }}{{ pg_dns_suffix }}`

For example, if you set `pg_dns_suffix` to `.db.vip.company.tld` for cluster `pg-test`, then the cluster DNS name will be `pg-test.db.vip.company.tld`




### `pg_dns_target`

参数名称： `pg_dns_target`， 类型： `enum`， 层次：`C`

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

参数名称： `pg_exporter_enabled`， 类型： `bool`， 层次：`C`

enable pg_exporter on pgsql hosts?

default value is `true`, if you don't want to install pg_exporter, set it to `false`.




### `pg_exporter_config`

参数名称： `pg_exporter_config`， 类型： `string`， 层次：`C`

pg_exporter configuration file name

default values: `pg_exporter.yml`, if you want to use a custom configuration file, you can define it here.

Your config file should be placed in `roles/files/<filename>`.




### `pg_exporter_cache_ttls`

参数名称： `pg_exporter_cache_ttls`， 类型： `string`， 层次：`C`

pg_exporter collector ttl stage in seconds, '1,10,60,300' by default

default values: `1,10,60,300`, which will use 1s, 10s, 60s, 300s for different metric collectors.

```yaml
ttl_fast: "{{ pg_exporter_cache_ttls.split(',')[0]|int }}"         # critical queries
ttl_norm: "{{ pg_exporter_cache_ttls.split(',')[1]|int }}"         # common queries
ttl_slow: "{{ pg_exporter_cache_ttls.split(',')[2]|int }}"         # slow queries (e.g table size)
ttl_slowest: "{{ pg_exporter_cache_ttls.split(',')[3]|int }}"      # ver slow queries (e.g bloat)
```



### `pg_exporter_port`

参数名称： `pg_exporter_port`， 类型： `port`， 层次：`C`

pg_exporter listen port, 9630 by default





### `pg_exporter_params`

参数名称： `pg_exporter_params`， 类型： `string`， 层次：`C`

extra url parameters for pg_exporter dsn

default values: `sslmode=disable`, which will disable SSL for monitoring connection (since it's local unix socket by default)





### `pg_exporter_url`

参数名称： `pg_exporter_url`， 类型： `pgurl`， 层次：`C`

overwrite auto-generate pg dsn if specified

default value is empty string, If specified, it will be used as the pg_exporter dsn instead of constructing from other parameters:

This could be useful if you want to monitor a remote pgsql instance, or you want to use a different user/password for monitoring.

```
'postgres://{{ pg_monitor_username }}:{{ pg_monitor_password }}@{{ pg_host }}:{{ pg_port }}/postgres{% if pg_exporter_params != '' %}?{{ pg_exporter_params }}{% endif %}'
```





### `pg_exporter_auto_discovery`

参数名称： `pg_exporter_auto_discovery`， 类型： `bool`， 层次：`C`

enable auto database discovery? enabled by default

default value is `true`, which will auto-discover all databases on the postgres server and spawn a new pg_exporter connection for each database.




### `pg_exporter_exclude_database`

参数名称： `pg_exporter_exclude_database`， 类型： `string`， 层次：`C`

csv of database that WILL NOT be monitored during auto-discovery

default values: `template0,template1,postgres`, which will be excluded for database auto discovery.





### `pg_exporter_include_database`

参数名称： `pg_exporter_include_database`， 类型： `string`， 层次：`C`

csv of database that WILL BE monitored during auto-discovery

default value is empty string. If this value is set, only the databases in this list will be monitored during auto discovery.




### `pg_exporter_connect_timeout`

参数名称： `pg_exporter_connect_timeout`， 类型： `int`， 层次：`C`

pg_exporter connect timeout in ms, 200 by default

default values: `200`ms , which is enough for most cases.

If your remote pgsql server is in another continent, you may want to increase this value to avoid connection timeout.





### `pg_exporter_options`

参数名称： `pg_exporter_options`， 类型： `arg`， 层次：`C`

overwrite extra options for pg_exporter

default value is empty string, which will fall back the following default options: 

```bash
PG_EXPORTER_OPTS='--log.level=info --log.format="logger:syslog?appname=pg_exporter&local=7"'
```

If you want to customize logging options or other pg_exporter options, you can set it here.





### `pgbouncer_exporter_enabled`

参数名称： `pgbouncer_exporter_enabled`， 类型： `bool`， 层次：`C`

enable pgbouncer_exporter on pgsql hosts?

default value is `true`, which will enable pg_exporter for pgbouncer connection pooler.




### `pgbouncer_exporter_port`

参数名称： `pgbouncer_exporter_port`， 类型： `port`， 层次：`C`

pgbouncer_exporter listen port, 9631 by default

default values: `9631`





### `pgbouncer_exporter_url`

参数名称： `pgbouncer_exporter_url`， 类型： `pgurl`， 层次：`C`

overwrite auto-generate pgbouncer dsn if specified

default value is empty string,  If specified, it will be used as the pgbouncer_exporter dsn instead of constructing from other parameters:

```
'postgres://{{ pg_monitor_username }}:{{ pg_monitor_password }}@:{{ pgbouncer_port }}/pgbouncer?host={{ pg_localhost }}&sslmode=disable'
```

This could be useful if you want to monitor a remote pgbouncer instance, or you want to use a different user/password for monitoring.




### `pgbouncer_exporter_options`

参数名称： `pgbouncer_exporter_options`， 类型： `arg`， 层次：`C`

overwrite extra options for pgbouncer_exporter

default value is empty string, which will fall back the following default options:

```
'--log.level=info --log.format="logger:syslog?appname=pgbouncer_exporter&local=7"'
```

If you want to customize logging options or other pgbouncer_exporter options, you can set it here.

