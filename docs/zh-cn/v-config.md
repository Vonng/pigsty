# 配置Pigsty

Pigsty采用声明式[配置](c-config.md)：用户配置描述状态，而Pigsty负责将真实组件调整至所期待的状态。

Pigsty包含了约200个[配置项](#配置项清单)，大体分为四个部分：[INFRA](v-infra.md), [NODES](v-nodes.md), [PGSQL](v-pgsql.md), [REDIS](v-redis.md)。
通常只有数据库/节点集群的身份参数是必选参数，绝大多数配置参数无需修改，可直接使用默认值，


## 配置项清单

|            类目             |                                    名称                                     |    类型    | 层级  | 说明 |
|:-------------------------:|:-------------------------------------------------------------------------:| :--------: | :---: | ---- |
|    [INFRA](v-infra.md)    |                    [proxy_env](v-connect.md#proxy_env)                    |  `dict`  |   G   | 代理服务器配置 |
|    [INFRA](v-infra.md)    |                  [repo_enabled](v-repo.md#repo_enabled)                   |  `bool`  |   G   | 是否启用本地源 |
|    [INFRA](v-infra.md)    |                     [repo_name](v-repo.md#repo_name)                      |  `string`  |   G   | 本地源名称 |
|    [INFRA](v-infra.md)    |                  [repo_address](v-repo.md#repo_address)                   |  `string`  |   G   | 本地源外部访问地址 |
|    [INFRA](v-infra.md)    |                     [repo_port](v-repo.md#repo_port)                      |  `number`  |   G   | 本地源端口 |
|    [INFRA](v-infra.md)    |                     [repo_home](v-repo.md#repo_home)                      |  `string`  |   G   | 本地源文件根目录 |
|    [INFRA](v-infra.md)    |                  [repo_rebuild](v-repo.md#repo_rebuild)                   |  `bool`  |   A   | 是否重建Yum源 |
|    [INFRA](v-infra.md)    |                   [repo_remove](v-repo.md#repo_remove)                    |  `bool`  |   A   | 是否移除已有Yum源 |
|    [INFRA](v-infra.md)    |                [repo_upstreams](v-repo.md#repo_upstreams)                 |  `object[]`  |   G   | Yum源的上游来源 |
|    [INFRA](v-infra.md)    |                 [repo_packages](v-repo.md#repo_packages)                  | `string[]` | G | Yum源需下载软件列表 |
|    [INFRA](v-infra.md)    |             [repo_url_packages](v-repo.md#repo_url_packages)              | `string[]` | G | 通过URL直接下载的软件 |
|    [NODES](v-nodes.md)  |                     [meta_node](v-node.md#meta_node)                      |   `bool`   |  I/C  | 表示此节点为元节点          |
|    [NODES](v-nodes.md)  |                      [nodename](v-node.md#nodename)                       |  `string`  |   I   | 若指定，覆盖机器HOSTNAME   |
|    [NODES](v-nodes.md)  |                  [node_cluster](v-node.md#node_cluster)                   |  `string`  |   C   | 节点集群名，默认名为`nodes`  |
|    [NODES](v-nodes.md)  |            [node_name_exchange](v-node.md#node_name_exchange)             |   `bool`   | I/C/G | 是否在剧本节点间交换主机名      |
|    [NODES](v-nodes.md)  |                [node_dns_hosts](v-node.md#node_dns_hosts)                 | `string[]` |   G   | 写入机器的静态DNS解析       |
|    [NODES](v-nodes.md)  |          [node_dns_hosts_extra](v-node.md#node_dns_hosts_extra)           | `string[]` |  I/C  | 同上，用于集群实例层级        |
|    [NODES](v-nodes.md)  |               [node_dns_server](v-node.md#node_dns_server)                |   `enum`   |   G   | 如何配置DNS服务器？        |
|    [NODES](v-nodes.md)  |              [node_dns_servers](v-node.md#node_dns_servers)               | `string[]` |   G   | 配置动态DNS服务器         |
|    [NODES](v-nodes.md)  |              [node_dns_options](v-node.md#node_dns_options)               | `string[]` |   G   | 配置/etc/resolv.conf |
|    [NODES](v-nodes.md)  |              [node_repo_method](v-node.md#node_repo_method)               |   `enum`   |   G   | 节点使用Yum源的方式        |
|    [NODES](v-nodes.md)  |              [node_repo_remove](v-node.md#node_repo_remove)               |   `bool`   |   G   | 是否移除节点已有Yum源       |
|    [NODES](v-nodes.md)  |           [node_local_repo_url](v-node.md#node_local_repo_url)            | `string[]` |   G   | 本地源的URL地址          |
|    [NODES](v-nodes.md)  |                 [node_packages](v-node.md#node_packages)                  | `string[]` |   G   | 节点安装软件列表           |
|    [NODES](v-nodes.md)  |           [node_extra_packages](v-node.md#node_extra_packages)            | `string[]` | C/I/A | 节点额外安装的软件列表        |
|    [NODES](v-nodes.md)  |            [node_meta_packages](v-node.md#node_meta_packages)             | `string[]` |   G   | 元节点所需的软件列表         |
|    [NODES](v-nodes.md)  |         [node_meta_pip_install](v-node.md#node_meta_pip_install)          |  `string`  |   G   | 元节点上通过pip3安装的软件包   |
|    [NODES](v-nodes.md)  |             [node_disable_numa](v-node.md#node_disable_numa)              |   `bool`   |   G   | 关闭节点NUMA           |
|    [NODES](v-nodes.md)  |             [node_disable_swap](v-node.md#node_disable_swap)              |   `bool`   |   G   | 关闭节点SWAP           |
|    [NODES](v-nodes.md)  |         [node_disable_firewall](v-node.md#node_disable_firewall)          |   `bool`   |   G   | 关闭节点防火墙            |
|    [NODES](v-nodes.md)  |          [node_disable_selinux](v-node.md#node_disable_selinux)           |   `bool`   |   G   | 关闭节点SELINUX        |
|    [NODES](v-nodes.md)  |           [node_static_network](v-node.md#node_static_network)            |   `bool`   |   G   | 是否使用静态DNS服务器       |
|    [NODES](v-nodes.md)  |            [node_disk_prefetch](v-node.md#node_disk_prefetch)             |   `bool`   |   G   | 是否启用磁盘预读           |
|    [NODES](v-nodes.md)  |           [node_kernel_modules](v-node.md#node_kernel_modules)            | `string[]` |   G   | 启用的内核模块            |
|    [NODES](v-nodes.md)  |                     [node_tune](v-node.md#node_tune)                      |   `enum`   |   G   | 节点调优模式            |
|    [NODES](v-nodes.md)  |            [node_sysctl_params](v-node.md#node_sysctl_params)             |   `dict`   |   G   | 操作系统内核参数           |
|    [NODES](v-nodes.md)  |              [node_admin_setup](v-node.md#node_admin_setup)               |   `bool`   |   G   | 是否创建管理员用户          |
|    [NODES](v-nodes.md)  |                [node_admin_uid](v-node.md#node_admin_uid)                 |  `number`  |   G   | 管理员用户UID           |
|    [NODES](v-nodes.md)  |           [node_admin_username](v-node.md#node_admin_username)            |  `string`  |   G   | 管理员用户名             |
|    [NODES](v-nodes.md)  |       [node_admin_ssh_exchange](v-node.md#node_admin_ssh_exchange)        |   `bool`   |   G   | 在实例间交换管理员SSH密钥     |
|    [NODES](v-nodes.md)  |                [node_admin_pks](v-node.md#node_admin_pks)                 | `string[]` |   G   | 可登陆管理员的公钥列表        |
|    [NODES](v-nodes.md)  |         [node_admin_pk_current](v-node.md#node_admin_pk_current)          |   `bool`   |   A   | 是否将当前用户的公钥加入管理员账户  |
|    [NODES](v-nodes.md)  |              [node_ntp_service](v-node.md#node_ntp_service)               |   `enum`   |   G   | NTP服务类型：ntp或chrony |
|    [NODES](v-nodes.md)  |               [node_ntp_config](v-node.md#node_ntp_config)                |   `bool`   |   G   | 是否配置NTP服务？         |
|    [NODES](v-nodes.md)  |                 [node_timezone](v-node.md#node_timezone)                  |  `string`  |   G   | NTP时区设置            |
|    [NODES](v-nodes.md)  |              [node_ntp_servers](v-node.md#node_ntp_servers)               | `string[]` |   G   | NTP服务器列表           |
|    [NODES](v-nodes.md)  |              [service_registry](v-node.md#service_registry)               |   `enum`    | G/C/I | 服务注册的位置           |
|    [NODES](v-nodes.md)  |                           [dcs_type](#dcs_type)                           |   `enum`    |   G   | 使用的DCS类型          |
|    [NODES](v-nodes.md)  |                           [dcs_name](#dcs_name)                           |  `string`   |   G   | DCS集群名称           |
|    [NODES](v-nodes.md)  |                        [dcs_servers](#dcs_servers)                        |   `dict`    |   G   | DCS服务器名称:IP列表     |
|    [NODES](v-nodes.md)  |                  [dcs_exists_action](#dcs_exists_action)                  |   `enum`    |  G/A  | 若DCS实例存在如何处理      |
|    [NODES](v-nodes.md)  |                  [dcs_disable_purge](#dcs_disable_purge)                  |   `bool`    | G/C/I | 完全禁止清理DCS实例       |
|    [NODES](v-nodes.md)  |                    [consul_data_dir](#consul_data_dir)                    |  `string`   |   G   | Consul数据目录        |
|    [NODES](v-nodes.md)  |                      [etcd_data_dir](#etcd_data_dir)                      |  `string`   |   G   | Etcd数据目录          |
|    [NODES](v-nodes.md)  |                   [exporter_install](#exporter_install)                   |  `enum`  | G/C  | 安装监控组件的方式             |
|    [NODES](v-nodes.md)  |                  [exporter_repo_url](#exporter_repo_url)                  | `string` | G/C  | 监控组件的YumRepo              |
|    [NODES](v-nodes.md)  |              [exporter_metrics_path](#exporter_metrics_path)              | `string` | G/C  | 监控暴露的URL Path             |
|    [NODES](v-nodes.md)  |              [node_exporter_enabled](#node_exporter_enabled)              |  `bool`  | G/C  | 启用节点指标收集器             |
|    [NODES](v-nodes.md)  |                 [node_exporter_port](#node_exporter_port)                 | `number` | G/C  | 节点指标暴露端口               |
|    [NODES](v-nodes.md)  |              [node_exporter_options](#node_exporter_options)              | `string` | G/C  | 节点指标采集选项               |
|    [INFRA](v-meta.md)     |                     [ca_method](v-meta.md#ca_method)                      |  `enum`  |  G  | CA的创建方式 |
|    [INFRA](v-meta.md)     |                    [ca_subject](v-meta.md#ca_subject)                     |  `string`  |  G  | 自签名CA主题 |
|    [INFRA](v-meta.md)     |                    [ca_homedir](v-meta.md#ca_homedir)                     |  `string`  |  G  | CA证书根目录 |
|    [INFRA](v-meta.md)     |                       [ca_cert](v-meta.md#ca_cert)                        |  `string`  |  G  | CA证书 |
|    [INFRA](v-meta.md)     |                        [ca_key](v-meta.md#ca_key)                         |  `string`  |  G  | CA私钥名称 |
|    [INFRA](v-meta.md)     |                [nginx_upstream](v-meta.md#nginx_upstream)                 |  `object[]`  |  G  | Nginx上游服务器 |
|    [INFRA](v-meta.md)     |                      [app_list](v-meta.md##app_list)                      |  `object[]`  |  G  | 首页导航栏显示的应用列表 |
|    [INFRA](v-meta.md)     |                  [docs_enabled](v-meta.md#docs_enabled)                   |  `bool`      |  G  | 是否启用本地文档 |
|    [INFRA](v-meta.md)     |                  [pev2_enabled](v-meta.md#pev2_enabled)                   |  `bool`      |  G  | 是否启用PEV2组件 |
|    [INFRA](v-meta.md)     |              [pgbadger_enabled](v-meta.md#pgbadger_enabled)               |  `bool`      |  G  | 是否启用Pgbadger |
|    [INFRA](v-meta.md)     |                   [dns_records](v-meta.md#dns_records)                    |  `string[]`  |  G  | 动态DNS解析记录 |
|    [INFRA](v-meta.md)     |           [prometheus_data_dir](v-meta.md#prometheus_data_dir)            |  `string`  |  G  | Prometheus数据库目录 |
|    [INFRA](v-meta.md)     |            [prometheus_options](v-meta.md#prometheus_options)             |  `string`  |  G  | Prometheus命令行参数 |
|    [INFRA](v-meta.md)     |             [prometheus_reload](v-meta.md#prometheus_reload)              |  `bool`  |  A  | Reload而非Recreate |
|    [INFRA](v-meta.md)     |          [prometheus_sd_method](v-meta.md#prometheus_sd_method)           |  `enum`  |  G  | 服务发现机制：static\|consul |
|    [INFRA](v-meta.md)     |    [prometheus_scrape_interval](v-meta.md#prometheus_scrape_interval)     |  `interval`  |  G  | Prom抓取周期 |
|    [INFRA](v-meta.md)     |     [prometheus_scrape_timeout](v-meta.md#prometheus_scrape_timeout)      |  `interval`  |  G  | Prom抓取超时 |
|    [INFRA](v-meta.md)     |        [prometheus_sd_interval](v-meta.md#prometheus_sd_interval)         |  `interval`  |  G  | Prom服务发现刷新周期 |
|    [INFRA](v-meta.md)     |              [grafana_endpoint](v-meta.md#grafana_endpoint)               |  `string`  |  G  | Grafana地址 |
|    [INFRA](v-meta.md)     |        [grafana_admin_username](v-meta.md#grafana_admin_username)         |  `string`  |  G  | Grafana管理员用户名 |
|    [INFRA](v-meta.md)     |        [grafana_admin_password](v-meta.md#grafana_admin_password)         |  `string`  |  G  | Grafana管理员密码 |
|    [INFRA](v-meta.md)     |              [grafana_database](v-meta.md#grafana_database)               |  `string`  |  G  | Grafana后端数据库类型 |
|    [INFRA](v-meta.md)     |                 [grafana_pgurl](v-meta.md#grafana_pgurl)                  |  `string`  |  G  | Grafana的PG数据库连接串 |
|    [INFRA](v-meta.md)     |                [grafana_plugin](v-meta.md#grafana_plugin)                 |  `enum`  |  G  | 如何安装Grafana插件 |
|    [INFRA](v-meta.md)     |                 [grafana_cache](v-meta.md#grafana_cache)                  |  `string`  |  G  | Grafana插件缓存地址 |
|    [INFRA](v-meta.md)     |               [grafana_plugins](v-meta.md#grafana_plugins)                |  `string[]`  |  G  | 安装的Grafana插件列表 |
|    [INFRA](v-meta.md)     |           [grafana_git_plugins](v-meta.md#grafana_git_plugins)            |  `string[]`  |  G  | 从Git安装的Grafana插件 |
|    [INFRA](v-meta.md)     |                    [loki_clean](v-meta.md#loki_clean)                     |  `bool`  |  A  | 是否在安装Loki时清理数据库目录 |
|    [INFRA](v-meta.md)     |                 [loki_data_dir](v-meta.md#loki_data_dir)                  |  `string`  |  G  | Loki的数据目录 |
|    [INFRA](v-meta.md)     |               [jupyter_enabled](v-meta.md#jupyter_enabled)                |  `bool`      |  G  | 是否启用JupyterLab |
|    [INFRA](v-meta.md)     |              [jupyter_username](v-meta.md#jupyter_username)               |  `bool`      |  G  | Jupyter使用的操作系统用户 |
|    [INFRA](v-meta.md)     |              [jupyter_password](v-meta.md#jupyter_password)               |  `bool`      |  G  | Jupyter Lab的密码 |
|    [INFRA](v-meta.md)     |                 [pgweb_enabled](v-meta.md#pgweb_enabled)                  |  `bool`      |  G  | 是否启用PgWeb |
|    [INFRA](v-meta.md)     |                [pgweb_username](v-meta.md#pgweb_username)                 |  `bool`      |  G  | PgWeb使用的操作系统用户 |
|      [NO](v-dcs.md)       |               [service_registry](v-dcs.md#service_registry)               |  `enum`  |  G/C/I  | 服务注册的位置 |
|      [NO](v-dcs.md)       |                       [dcs_type](v-dcs.md#dcs_type)                       |  `enum`  |  G  | 使用的DCS类型 |
|      [NO](v-dcs.md)       |                       [dcs_name](v-dcs.md#dcs_name)                       |  `string`  |  G  | DCS集群名称 |
|      [NO](v-dcs.md)       |                    [dcs_servers](v-dcs.md#dcs_servers)                    |  `dict`  |  G  | DCS服务器名称:IP列表 |
|      [NO](v-dcs.md)       |              [dcs_exists_action](v-dcs.md#dcs_exists_action)              |  `enum`  |  G/A  | 若DCS实例存在如何处理 |
|      [NO](v-dcs.md)       |              [dcs_disable_purge](v-dcs.md#dcs_disable_purge)              |  `bool`  |  G/C/I  | 完全禁止清理DCS实例 |
|      [NO](v-dcs.md)       |                [consul_data_dir](v-dcs.md#consul_data_dir)                |  `string`  |  G  | Consul数据目录 |
|      [NO](v-dcs.md)       |                  [etcd_data_dir](v-dcs.md#etcd_data_dir)                  |  `string`  |  G  | Etcd数据目录 |
|  [PG安装](v-pg-install.md)  |                    [pg_dbsu](v-pg-install.md#pg_dbsu)                     |  `string`  |  G/C  | PG操作系统超级用户 |
|  [PG安装](v-pg-install.md)  |                [pg_dbsu_uid](v-pg-install.md#pg_dbsu_uid)                 |  `number`  |  G/C  | 超级用户UID |
|  [PG安装](v-pg-install.md)  |               [pg_dbsu_sudo](v-pg-install.md#pg_dbsu_sudo)                |  `enum`  |  G/C  | 超级用户的Sudo权限 |
|  [PG安装](v-pg-install.md)  |               [pg_dbsu_home](v-pg-install.md#pg_dbsu_home)                |  `string`  |  G/C  | 超级用户的家目录 |
|  [PG安装](v-pg-install.md)  |       [pg_dbsu_ssh_exchange](v-pg-install.md#pg_dbsu_ssh_exchange)        |  `bool`  |  G/C  | 是否交换超级用户密钥 |
|  [PG安装](v-pg-install.md)  |                 [pg_version](v-pg-install.md#pg_version)                  |  `string`  |  G/C  | 安装的数据库大版本 |
|  [PG安装](v-pg-install.md)  |                  [pgdg_repo](v-pg-install.md#pgdg_repo)                   |  `bool`  |  G/C  | 是否添加PG官方源？ |
|  [PG安装](v-pg-install.md)  |                [pg_add_repo](v-pg-install.md#pg_add_repo)                 |  `bool`  |  G/C  | 是否添加PG相关源？ |
|  [PG安装](v-pg-install.md)  |                 [pg_bin_dir](v-pg-install.md#pg_bin_dir)                  |  `string`  |  G/C  | PG二进制目录 |
|  [PG安装](v-pg-install.md)  |                [pg_packages](v-pg-install.md#pg_packages)                 |  `string[]`  |  G/C  | 安装的PG软件包列表 |
|  [PG安装](v-pg-install.md)  |              [pg_extensions](v-pg-install.md#pg_extensions)               |  `string[]`  |  G/C  | 安装的PG插件列表 |
| [PG供给](v-pg-provision.md) |                [pg_cluster](v-pg-provision.md#pg_cluster)                 |  `string`  |  **C**  | **PG数据库集群名称** |
| [PG供给](v-pg-provision.md) |                    [pg_seq](v-pg-provision.md#pg_seq)                     |  `number`  |  **I**  | **PG数据库实例序号** |
| [PG供给](v-pg-provision.md) |                   [pg_role](v-pg-provision.md#pg_role)                    |  `enum`  |  **I**  | **PG数据库实例角色** |
| [PG供给](v-pg-provision.md) |               [pg_hostname](v-pg-provision.md#pg_hostname)                |  `bool`  |  G/C  | 将PG实例名称设为HOSTNAME |
| [PG供给](v-pg-provision.md) |               [pg_nodename](v-pg-provision.md#pg_nodename)                |  `bool`  |  G/C  | 将PG实例名称设为Consul节点名 |
| [PG供给](v-pg-provision.md) |                 [pg_exists](v-pg-provision.md#pg_exists)                  |  `bool`  |  A  | 标记位，PG是否已存在 |
| [PG供给](v-pg-provision.md) |          [pg_exists_action](v-pg-provision.md#pg_exists_action)           |  `enum`  |  G/A  | PG存在时如何处理 |
| [PG供给](v-pg-provision.md) |          [pg_disable_purge](v-pg-provision.md#pg_disable_purge)           | `bool`  | G/C/I | 禁止清除存在的PG实例 |
| [PG供给](v-pg-provision.md) |                   [pg_data](v-pg-provision.md#pg_data)                    |  `string`  |  G  | PG数据目录 |
| [PG供给](v-pg-provision.md) |                [pg_fs_main](v-pg-provision.md#pg_fs_main)                 |  `string`  |  G  | PG主数据盘挂载点 |
| [PG供给](v-pg-provision.md) |                [pg_fs_bkup](v-pg-provision.md#pg_fs_bkup)                 |  `path`  |  G  | PG备份盘挂载点 |
| [PG供给](v-pg-provision.md) |         [pg_dummy_filesize](v-pg-provision.md#pg_dummy_filesize)          |  `size`  | G/C/I | 占位文件`/pg/dummy`的大小  |
| [PG供给](v-pg-provision.md) |                 [pg_listen](v-pg-provision.md#pg_listen)                  |  `ip`  |  G  | PG监听的IP地址 |
| [PG供给](v-pg-provision.md) |                   [pg_port](v-pg-provision.md#pg_port)                    |  `number`  |  G  | PG监听的端口 |
| [PG供给](v-pg-provision.md) |              [pg_localhost](v-pg-provision.md#pg_localhost)               |  `string`  |  G/C  | PG使用的UnixSocket地址 |
| [PG供给](v-pg-provision.md) |               [pg_upstream](v-pg-provision.md#pg_upstream)                | `string` | I | 实例的复制上游节点 |
| [PG供给](v-pg-provision.md) |                 [pg_backup](v-pg-provision.md#pg_backup)                  | `bool`    | I | 是否在实例上存储备份 |
| [PG供给](v-pg-provision.md) |                  [pg_delay](v-pg-provision.md#pg_delay)                   | `interval` | I | 若实例为延迟从库，采用的延迟时长 |
| [PG供给](v-pg-provision.md) |              [patroni_mode](v-pg-provision.md#patroni_mode)               |  `enum`  |  G/C  | Patroni配置模式 |
| [PG供给](v-pg-provision.md) |              [pg_namespace](v-pg-provision.md#pg_namespace)               |  `string`  |  G/C  | Patroni使用的DCS命名空间 |
| [PG供给](v-pg-provision.md) |              [patroni_port](v-pg-provision.md#patroni_port)               |  `string`  |  G/C  | Patroni服务端口 |
| [PG供给](v-pg-provision.md) |     [patroni_watchdog_mode](v-pg-provision.md#patroni_watchdog_mode)      |  `enum`  |  G/C  | Patroni Watchdog模式 |
| [PG供给](v-pg-provision.md) |                   [pg_conf](v-pg-provision.md#pg_conf)                    |  `enum`  |  G/C  | Patroni使用的配置模板 |
| [PG供给](v-pg-provision.md) |       [pg_shared_libraries](v-pg-provision.md#pg_shared_libraries)        |  `string`  |  G/C  | PG默认加载的共享库 |
| [PG供给](v-pg-provision.md) |               [pg_encoding](v-pg-provision.md#pg_encoding)                |  `string`  |  G/C  | PG字符集编码 |
| [PG供给](v-pg-provision.md) |                 [pg_locale](v-pg-provision.md#pg_locale)                  |  `enum`  |  G/C  | PG使用的本地化规则 |
| [PG供给](v-pg-provision.md) |             [pg_lc_collate](v-pg-provision.md#pg_lc_collate)              |  `enum`  |  G/C  | PG使用的本地化排序规则 |
| [PG供给](v-pg-provision.md) |               [pg_lc_ctype](v-pg-provision.md#pg_lc_ctype)                |  `enum`  |  G/C  | PG使用的本地化字符集定义 |
| [PG供给](v-pg-provision.md) |            [pgbouncer_port](v-pg-provision.md#pgbouncer_port)             |  `number`  |  G/C  | Pgbouncer端口 |
| [PG供给](v-pg-provision.md) |        [pgbouncer_poolmode](v-pg-provision.md#pgbouncer_poolmode)         |  `enum`  |  G/C  | Pgbouncer池化模式 |
| [PG供给](v-pg-provision.md) |     [pgbouncer_max_db_conn](v-pg-provision.md#pgbouncer_max_db_conn)      |  `number`  |  G/C  | Pgbouncer最大单DB连接数 |
| [PG模板](v-pg-template.md)  |                    [pg_init](v-pg-template.md#pg_init)                    |  `string`  |  G/C  | 自定义PG初始化脚本 |
| [PG模板](v-pg-template.md)  |    [pg_replication_username](v-pg-template.md#pg_replication_username)    |  `string`  |  G  | PG复制用户 |
| [PG模板](v-pg-template.md)  |    [pg_replication_password](v-pg-template.md#pg_replication_password)    |  `string`  |  G  | PG复制用户的密码 |
| [PG模板](v-pg-template.md)  |        [pg_monitor_username](v-pg-template.md#pg_monitor_username)        |  `string`  |  G  | PG监控用户 |
| [PG模板](v-pg-template.md)  |        [pg_monitor_password](v-pg-template.md#pg_monitor_password)        |  `string`  |  G  | PG监控用户密码 |
| [PG模板](v-pg-template.md)  |          [pg_admin_username](v-pg-template.md#pg_admin_username)          |  `string`  |  G  | PG管理用户 |
| [PG模板](v-pg-template.md)  |          [pg_admin_password](v-pg-template.md#pg_admin_password)          |  `string`  |  G  | PG管理用户密码 |
| [PG模板](v-pg-template.md)  |           [pg_default_roles](v-pg-template.md#pg_default_roles)           |  `role[]`  |  G  | 默认创建的角色与用户 |
| [PG模板](v-pg-template.md)  |       [pg_default_privilegs](v-pg-template.md#pg_default_privilegs)       |  `string[]`  |  G  | 数据库默认权限配置 |
| [PG模板](v-pg-template.md)  |         [pg_default_schemas](v-pg-template.md#pg_default_schemas)         |  `string[]`  |  G  | 默认创建的模式 |
| [PG模板](v-pg-template.md)  |      [pg_default_extensions](v-pg-template.md#pg_default_extensions)      |  `extension[]`  |  G  | 默认安装的扩展 |
| [PG模板](v-pg-template.md)  |           [pg_offline_query](v-pg-template.md#pg_offline_query)           |  `bool`  |  **I**  | 是否允许**离线**查询 |
| [PG模板](v-pg-template.md)  |                  [pg_reload](v-pg-template.md#pg_reload)                  |  `bool`  |  **A**  | 是否重载数据库配置（HBA） |
| [PG模板](v-pg-template.md)  |               [pg_hba_rules](v-pg-template.md#pg_hba_rules)               |  `rule[]`  |  G  | 全局HBA规则 |
| [PG模板](v-pg-template.md)  |         [pg_hba_rules_extra](v-pg-template.md#pg_hba_rules_extra)         |  `rule[]`  |  C/I  | 集群/实例特定的HBA规则 |
| [PG模板](v-pg-template.md)  |        [pgbouncer_hba_rules](v-pg-template.md#pgbouncer_hba_rules)        |  `rule[]`  |  G/C  | Pgbouncer全局HBA规则 |
| [PG模板](v-pg-template.md)  |  [pgbouncer_hba_rules_extra](v-pg-template.md#pgbouncer_hba_rules_extra)  |  `rule[]`  |  G/C  | Pgbounce特定HBA规则 |
| [PG模板](v-pg-template.md)  |               [pg_databases](v-pg-template.md#pg_databases)               | `database[]`   | G/C | **业务数据库定义** |
| [PG模板](v-pg-template.md)  |                   [pg_users](v-pg-template.md#pg_users)                   | `user[]`               | G/C | **业务用户定义** |
|   [监控系统](v-monitor.md)    |             [exporter_install](v-monitor.md#exporter_install)             |  `enum`  |  G/C  | 安装监控组件的方式 |
|   [监控系统](v-monitor.md)    |            [exporter_repo_url](v-monitor.md#exporter_repo_url)            |  `string`  |  G/C  | 监控组件的YumRepo |
|   [监控系统](v-monitor.md)    |        [exporter_metrics_path](v-monitor.md#exporter_metrics_path)        |  `string`  |  G/C  | 监控暴露的URL Path |
|   [监控系统](v-monitor.md)    |        [node_exporter_enabled](v-monitor.md#node_exporter_enabled)        |  `bool`  |  G/C  | 启用节点指标收集器 |
|   [监控系统](v-monitor.md)    |           [node_exporter_port](v-monitor.md#node_exporter_port)           |  `number`  |  G/C  | 节点指标暴露端口 |
|   [监控系统](v-monitor.md)    |        [node_exporter_options](v-monitor.md#node_exporter_options)        |  `string`  |  G/C  | 节点指标采集选项 |
|   [监控系统](v-monitor.md)    |           [pg_exporter_config](v-monitor.md#pg_exporter_config)           |  `string`  |  G/C  | PG指标定义文件 |
|   [监控系统](v-monitor.md)    |          [pg_exporter_enabled](v-monitor.md#pg_exporter_enabled)          |  `bool`  |  G/C  | 启用PG指标收集器 |
|   [监控系统](v-monitor.md)    |             [pg_exporter_port](v-monitor.md#pg_exporter_port)             |  `number`  |  G/C  | PG指标暴露端口 |
|   [监控系统](v-monitor.md)    |              [pg_exporter_url](v-monitor.md#pg_exporter_url)              |  `string`  |  G/C  | 采集对象数据库的连接串（覆盖） |
|   [监控系统](v-monitor.md)    |   [pg_exporter_auto_discovery](v-monitor.md#pg_exporter_auto_discovery)   |  `bool`    |  G/C  | 是否自动发现实例中的数据库 |
|   [监控系统](v-monitor.md)    | [pg_exporter_exclude_database](v-monitor.md#pg_exporter_exclude_database) |  `string`  |  G/C  | 数据库自动发现排除列表 |
|   [监控系统](v-monitor.md)    | [pg_exporter_include_database](v-monitor.md#pg_exporter_include_database) |  `string`  |  G/C  | 数据库自动发现囊括列表 |
|   [监控系统](v-monitor.md)    |   [pgbouncer_exporter_enabled](v-monitor.md#pgbouncer_exporter_enabled)   |  `bool`  |  G/C  | 启用PGB指标收集器 |
|   [监控系统](v-monitor.md)    |      [pgbouncer_exporter_port](v-monitor.md#pgbouncer_exporter_port)      |  `number`  |  G/C  | PGB指标暴露端口 |
|   [监控系统](v-monitor.md)    |       [pgbouncer_exporter_url](v-monitor.md#pgbouncer_exporter_url)       |  `string`  |  G/C  | 采集对象连接池的连接串 |
|   [监控系统](v-monitor.md)    |             [promtail_enabled](v-monitor.md#promtail_enabled)             |  `bool`  |  G/C  | 是否启用Promtail日志收集服务 |
|   [监控系统](v-monitor.md)    |               [promtail_clean](v-monitor.md#promtail_clean)               |  `bool`  |  G/C/A  | 是否在安装promtail时移除已有状态信息 |
|   [监控系统](v-monitor.md)    |                [promtail_port](v-monitor.md#promtail_port)                |  `number`  |  G/C  | promtail使用的默认端口 |
|   [监控系统](v-monitor.md)    |         [promtail_status_path](v-monitor.md#promtail_status_path)         |  `string`  |  G/C  | 保存Promtail状态信息的文件位置 |
|   [监控系统](v-monitor.md)    |            [promtail_send_url](v-monitor.md#promtail_send_url)            |  `string`  |  G/C  | 用于接收日志的loki服务endpoint |
|   [服务供给](v-service.md)    |                    [pg_weight](v-service.md#pg_weight)                    |  `number`  |  **I**  | 实例在负载均衡中的相对权重 |
|   [服务供给](v-service.md)    |                  [pg_services](v-service.md#pg_services)                  |  `service[]`  |  G  | 全局通用**服务定义** |
|   [服务供给](v-service.md)    |            [pg_services_extra](v-service.md#pg_services_extra)            |  `service[]`  |  C  | 集群专有服务定义 |
|   [服务供给](v-service.md)    |              [haproxy_enabled](v-service.md#haproxy_enabled)              |  `bool`  |  G/C/I  | 是否启用Haproxy |
|   [服务供给](v-service.md)    |               [haproxy_reload](v-service.md#haproxy_reload)               |  `bool`  |  A  | 是否重载Haproxy配置 |
|   [服务供给](v-service.md)    |   [haproxy_admin_auth_enabled](v-service.md#haproxy_admin_auth_enabled)   |  `bool`  |  G/C  | 是否对Haproxy管理界面启用认证 |
|   [服务供给](v-service.md)    |       [haproxy_admin_username](v-service.md#haproxy_admin_username)       |  `string`  |  G/C  | HAproxy管理员名称 |
|   [服务供给](v-service.md)    |       [haproxy_admin_password](v-service.md#haproxy_admin_password)       |  `string`  |  G/C  | HAproxy管理员密码 |
|   [服务供给](v-service.md)    |        [haproxy_exporter_port](v-service.md#haproxy_exporter_port)        |  `number`  |  G/C  | HAproxy指标暴露器端口 |
|   [服务供给](v-service.md)    |       [haproxy_client_timeout](v-service.md#haproxy_client_timeout)       |  `interval`  |  G/C  | HAproxy客户端超时 |
|   [服务供给](v-service.md)    |       [haproxy_server_timeout](v-service.md#haproxy_server_timeout)       |  `interval`  |  G/C  | HAproxy服务端超时 |
|   [服务供给](v-service.md)    |                     [vip_mode](v-service.md#vip_mode)                     |  `enum`  |  G/C  | VIP模式：`none`|
|   [服务供给](v-service.md)    |                   [vip_reload](v-service.md#vip_reload)                   |  `bool`  |  G/C  | 是否重载VIP配置 |
|   [服务供给](v-service.md)    |                  [vip_address](v-service.md#vip_address)                  |  `string`  |  G/C  | 集群使用的VIP地址 |
|   [服务供给](v-service.md)    |                 [vip_cidrmask](v-service.md#vip_cidrmask)                 |  `number`  |  G/C  | VIP地址的网络CIDR掩码 |
|   [服务供给](v-service.md)    |                [vip_interface](v-service.md#vip_interface)                |  `string`  |  G/C  | VIP使用的网卡 |
|   [服务供给](v-service.md)    |                     [dns_mode](v-service.md#dns_mode)                     |  `enum`  |  G/C  | DNS配置模式 |
|   [服务供给](v-service.md)    |                 [dns_selector](v-service.md#dns_selector)                 |  `string`  |  G/C  | DNS解析对象选择器 |



## Redis支持

Pigsty v1.3提供了Redis部署与监控的支持，但仍作为Beta功能。Redis的相关配置项请参考 [Redis配置](v-redis.md)

