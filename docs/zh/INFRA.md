# INFRA

> Pigsty 带有一个开箱即用，生产就绪的基础设施模块，为用户带来究极的可观测性体验。 [配置](#配置) | [管理](#管理) | [剧本](#剧本) | [监控](#监控) | [参数](#参数)


----------------

## 概览

每一套 Pigsty 部署都会提供一套基础架构组件，为纳管的节点与数据库集群提供服务，组件包括：

|        组件        |  端口  |     域名     | 描述                 |
|:----------------:|:----:|:----------:|--------------------|
|      Nginx       |  80  | `h.pigsty` | 网络服务门户（也用作 Yum 仓库） |
|   AlertManager   | 9093 | `a.pigsty` | 告警聚合与分发            |
|    Prometheus    | 9090 | `p.pigsty` | 时间序列数据库（收存监控指标）    |
|     Grafana      | 3000 | `g.pigsty` | 可视化平台              |
|       Loki       | 3100 |     -      | 日志收集服务器            |
|   PushGateway    | 9091 |     -      | 接受一次性的任务指标         |
| BlackboxExporter | 9115 |     -      | 黑盒监控探测             |
|     Dnsmasq      |  53  |     -      | DNS 服务器            |
|     Chronyd      | 123  |     -      | NTP 时间服务器          |
|    PostgreSQL    | 5432 |     -      | Pigsty CMDB 和默认数据库 |
|     Ansible      |  -   |     -      | 运行剧本               |

Pigsty 将在 infra 节点上为您配置好这些组件。您可以通过配置 [`infra_portal`](PARAM#infra_portal) 参数，将它们通过 Nginx 暴露给外部世界。

```yaml
infra_portal:  # domain names and upstream servers
  home         : { domain: h.pigsty }
  grafana      : { domain: g.pigsty ,endpoint: "${admin_ip}:3000" , websocket: true }
  prometheus   : { domain: p.pigsty ,endpoint: "${admin_ip}:9090" }
  alertmanager : { domain: a.pigsty ,endpoint: "${admin_ip}:9093" }
  blackbox     : { endpoint: "${admin_ip}:9115" }
  loki         : { endpoint: "${admin_ip}:3100" }
  #minio        : { domain: sss.pigsty  ,endpoint: "${admin_ip}:9001" ,scheme: https ,websocket: true }
```

![pigsty-infra](https://user-images.githubusercontent.com/8587410/206972543-664ae71b-7ed1-4e82-90bd-5aa44c73bca4.gif)


----------------

## 配置





----------------

## 剧本

Pigsty 提供了三个与 INFRA 模块相关的剧本：

- [`install.yml`](https://github.com/vonng/pigsty/blob/master/install.yml)   ：在当前节点上一次性完整安装 Pigsty
- [`infra.yml`](https://github.com/vonng/pigsty/blob/master/infra.yml)       ：在 infra 节点上初始化 pigsty 基础设施
- [`infra-rm.yml`](https://github.com/vonng/pigsty/blob/master/infra-rm.yml) ：从 infra 节点移除基础设施组件

[![asciicast](https://asciinema.org/a/566412.svg)](https://asciinema.org/a/566412)
       



----------------

## 监控


[Pigsty Home](https://demo.pigsty.cc/d/pigsty) : Pigsty 监控系统主页

<details><summary>Pigsty Home Dashboard</summary>

[![pigsty-home](https://github.com/Vonng/pigsty/assets/8587410/b9679741-5baf-4a89-b6d0-e9eb4a13814d)](https://demo.pigsty.cc/d/pigsty/)

</details>


[INFRA Overview](https://demo.pigsty.cc/d/infra-overview) : Pigsty 基础设施自监控概览

<details><summary>INFRA Overview Dashboard</summary>

[![infra-overview](https://github.com/Vonng/pigsty/assets/8587410/d262ceaa-2d73-4817-88e7-1790c77a5498)](https://demo.pigsty.cc/d/infra-overview/)

</details>


[Nginx Overview](https://demo.pigsty.cc/d/nginx-overview) : Nginx 监控指标与日志

<details><summary>Nginx Overview Dashboard</summary>

[![nginx-overview](https://github.com/Vonng/pigsty/assets/8587410/08bff428-5f2a-4adb-9c96-479da59ccd2a)](https://demo.pigsty.cc/d/nginx-overview)

</details>


[Grafana Overview](https://demo.pigsty.cc/d/grafana-overview): Grafana 监控指标与日志

<details><summary>Grafana Overview Dashboard</summary>

[![grafana-overview](https://github.com/Vonng/pigsty/assets/8587410/6801fe16-1b47-4c1b-99aa-6af8b07aee4a)](https://demo.pigsty.cc/d/grafana-overview)

</details>


[Prometheus Overview](https://demo.pigsty.cc/d/prometheus-overview): Prometheus 监控指标与日志

<details><summary>Prometheus Overview Dashboard</summary>

[![prometheus-overview](https://github.com/Vonng/pigsty/assets/8587410/553f2f60-67a8-401d-abef-a58dd52a5bee)](https://demo.pigsty.cc/d/prometheus-overview)

</details>


[Loki Overview](https://demo.pigsty.cc/d/loki-overview): Loki 监控指标与日志

<details><summary>Loki Overview Dashboard</summary>

[![loki-overview](https://github.com/Vonng/pigsty/assets/8587410/a70a5d3a-bc8d-4fef-9708-4eabdd0436ff)](https://demo.pigsty.cc/d/loki-overview)

</details>


[Logs Instance](https://demo.pigsty.cc/d/logs-instance): 查阅单个节点上的日志信息

<details><summary>Logs Instance Dashboard</summary>

[![logs-instance](https://github.com/Vonng/pigsty/assets/8587410/246eff0e-d47d-4740-99db-20aca4b8ec55)](https://demo.pigsty.cc/d/logs-instance)

</details>


[Logs Overview](https://demo.pigsty.cc/d/logs-overview): 查阅全局日志信息

<details><summary>Logs Overview Dashboard</summary>

[![logs-overview](https://github.com/Vonng/pigsty/assets/8587410/e0a6c0f5-8cb1-4d70-a327-d9fa815e3f27)](https://demo.pigsty.cc/d/logs-overview)

</details>


[CMDB Overview](https://demo.pigsty.cc/d/cmdb-overview): CMDB 可视化

<details><summary>CMDB Overview Dashboard</summary>

[![cmdb-overview](https://github.com/Vonng/pigsty/assets/8587410/9e187204-9d8d-4c31-8885-313f00bbc73f)](https://demo.pigsty.cc/d/cmdb-overview)

</details>


[ETCD Overview](https://demo.pigsty.cc/d/etcd-overview): etcd 监控指标与日志

<details><summary>ETCD Overview Dashboard</summary>

[![etcd-overview](https://github.com/Vonng/pigsty/assets/8587410/3f268146-9242-42e7-b78f-b5b676155f3f)](https://demo.pigsty.cc/d/etcd-overview)

</details>




----------------

## 参数

[`INFRA`](PARAM#INFRA) 模块有下列10个参数组。

- [`META`](PARAM#meta)：Pigsty元数据
- [`CA`](PARAM#ca)：自签名公私钥基础设施/CA
- [`INFRA_ID`](PARAM#infra_id)：基础设施门户，Nginx域名
- [`REPO`](PARAM#repo)：本地 Yum 仓库
- [`INFRA_PACKAGE`](PARAM#infra_package)：基础设施软件包
- [`NGINX`](PARAM#nginx)：Nginx 网络服务器
- [`DNS`](PARAM#dns)：DNSMASQ 域名服务器
- [`PROMETHEUS`](PARAM#prometheus)：Prometheus 时序数据库全家桶
- [`GRAFANA`](PARAM#grafana)：Grafana 可观测性全家桶
- [`LOKI`](PARAM#loki)：Loki 日志服务

<details><summary>完整参数列表</summary>

| 参数                                                               | 参数组                                    |     类型     | 级别  | 说明                                                 | 中文说明                                    |
|------------------------------------------------------------------|----------------------------------------|:----------:|:---:|----------------------------------------------------|-----------------------------------------|
| [`version`](PARAM#version)                                       | [`META`](PARAM#meta)                   |   string   |  G  | pigsty version string                              | pigsty 版本字符串                            |
| [`admin_ip`](PARAM#admin_ip)                                     | [`META`](PARAM#meta)                   |     ip     |  G  | admin node ip address                              | 管理节点 IP 地址                              |
| [`region`](PARAM#region)                                         | [`META`](PARAM#meta)                   |    enum    |  G  | upstream mirror region: default,china,europe       | 上游镜像区域：default,china,europe             |
| [`proxy_env`](PARAM#proxy_env)                                   | [`META`](PARAM#meta)                   |    dict    |  G  | global proxy env when downloading packages         | 下载包时使用的全局代理环境变量                         |
| [`ca_method`](PARAM#ca_method)                                   | [`CA`](PARAM#ca)                       |    enum    |  G  | create,recreate,copy, create by default            | CA处理方式：create,recreate,copy，默认为没有则创建    |
| [`ca_cn`](PARAM#ca_cn)                                           | [`CA`](PARAM#ca)                       |   string   |  G  | ca common name, fixed as pigsty-ca                 | CA CN名称，固定为 pigsty-ca                   |
| [`cert_validity`](PARAM#cert_validity)                           | [`CA`](PARAM#ca)                       |  interval  |  G  | cert validity, 20 years by default                 | 证书有效期，默认为 20 年                          |
| [`infra_seq`](PARAM#infra_seq)                                   | [`INFRA_ID`](PARAM#infra_id)           |    int     |  I  | infra node identity, REQUIRED                      | 基础设施节号，必选身份参数                           |
| [`infra_portal`](PARAM#infra_portal)                             | [`INFRA_ID`](PARAM#infra_id)           |    dict    |  G  | infra services exposed via portal                  | 通过Nginx门户暴露的基础设施服务列表                    |
| [`repo_enabled`](PARAM#repo_enabled)                             | [`REPO`](PARAM#repo)                   |    bool    | G/I | create a yum repo on this infra node?              | 在此基础设施节点上创建Yum仓库？                       |
| [`repo_home`](PARAM#repo_home)                                   | [`REPO`](PARAM#repo)                   |    path    |  G  | repo home dir, `/www` by default                   | Yum仓库主目录，默认为`/www``                     |
| [`repo_name`](PARAM#repo_name)                                   | [`REPO`](PARAM#repo)                   |   string   |  G  | repo name, pigsty by default                       | Yum仓库名称，默认为 pigsty                      |
| [`repo_endpoint`](PARAM#repo_endpoint)                           | [`REPO`](PARAM#repo)                   |    url     |  G  | access point to this repo by domain or ip:port     | 仓库的访问点：域名或 `ip:port` 格式                 |
| [`repo_remove`](PARAM#repo_remove)                               | [`REPO`](PARAM#repo)                   |    bool    | G/A | remove existing upstream repo                      | 构建本地仓库时是否移除现有上游仓库源定义文件？                 |
| [`repo_modules`](#repo_modules)                                  | [`REPO`](PARAM#repo)                   |   string   | G/A | which repo modules are installed in repo_upstream  | 启用的上游仓库模块列表，用逗号分隔                       |
| [`repo_upstream`](PARAM#repo_upstream)                           | [`REPO`](PARAM#repo)                   | upstream[] |  G  | where to download upstream packages                | 上游仓库源定义：从哪里下载上游包？                       |
| [`repo_packages`](PARAM#repo_packages)                           | [`REPO`](PARAM#repo)                   |  string[]  |  G  | which packages to be included                      | 从上游仓库下载哪些软件包？                           |
| [`repo_url_packages`](PARAM#repo_url_packages)                   | [`REPO`](PARAM#repo)                   |  string[]  |  G  | extra packages from url                            | 使用URL下载的额外软件包列表                         |
| [`infra_packages`](PARAM#infra_packages)                         | [`INFRA_PACKAGE`](PARAM#infra_package) |  string[]  |  G  | packages to be installed on infra nodes            | 在基础设施节点上要安装的软件包                         |
| [`infra_packages_pip`](PARAM#infra_packages_pip)                 | [`INFRA_PACKAGE`](PARAM#infra_package) |   string   |  G  | pip installed packages for infra nodes             | 在基础设施节点上使用 pip 安装的包                     |
| [`nginx_enabled`](PARAM#nginx_enabled)                           | [`NGINX`](PARAM#nginx)                 |    bool    | G/I | enable nginx on this infra node?                   | 在此基础设施节点上启用 nginx？                      |
| [`nginx_exporter_enabled`](PARAM#nginx_exporter_enabled)         | [`NGINX`](PARAM#nginx)                 |    bool    | G/I | enable nginx_exporter on this infra node?          | 在此基础设施节点上启用 nginx_exporter？             |
| [`nginx_sslmode`](PARAM#nginx_sslmode)                           | [`NGINX`](PARAM#nginx)                 |    enum    |  G  | nginx ssl mode? disable,enable,enforce             | nginx SSL模式？disable,enable,enforce      |
| [`nginx_home`](PARAM#nginx_home)                                 | [`NGINX`](PARAM#nginx)                 |    path    |  G  | nginx content dir, `/www` by default               | nginx 内容目录，默认为 `/www`，通常和仓库目录一致         |
| [`nginx_port`](PARAM#nginx_port)                                 | [`NGINX`](PARAM#nginx)                 |    port    |  G  | nginx listen port, 80 by default                   | nginx 监听端口，默认为 80                       |
| [`nginx_ssl_port`](PARAM#nginx_ssl_port)                         | [`NGINX`](PARAM#nginx)                 |    port    |  G  | nginx ssl listen port, 443 by default              | nginx SSL监听端口，默认为 443                   |
| [`nginx_navbar`](PARAM#nginx_navbar)                             | [`NGINX`](PARAM#nginx)                 |  index[]   |  G  | nginx index page navigation links                  | nginx 首页导航链接列表                          |
| [`dns_enabled`](PARAM#dns_enabled)                               | [`DNS`](PARAM#dns)                     |    bool    | G/I | setup dnsmasq on this infra node?                  | 在此基础设施节点上设置dnsmasq？                     |
| [`dns_port`](PARAM#dns_port)                                     | [`DNS`](PARAM#dns)                     |    port    |  G  | dns server listen port, 53 by default              | DNS 服务器监听端口，默认为 53                      |
| [`dns_records`](PARAM#dns_records)                               | [`DNS`](PARAM#dns)                     |  string[]  |  G  | dynamic dns records resolved by dnsmasq            | 由 dnsmasq 解析的动态 DNS 记录                  |
| [`prometheus_enabled`](PARAM#prometheus_enabled)                 | [`PROMETHEUS`](PARAM#prometheus)       |    bool    | G/I | enable prometheus on this infra node?              | 在此基础设施节点上启用 prometheus？                 |
| [`prometheus_clean`](PARAM#prometheus_clean)                     | [`PROMETHEUS`](PARAM#prometheus)       |    bool    | G/A | clean prometheus data during init?                 | 初始化Prometheus的时候清除现有数据？                 |
| [`prometheus_data`](PARAM#prometheus_data)                       | [`PROMETHEUS`](PARAM#prometheus)       |    path    |  G  | prometheus data dir, `/data/prometheus` by default | Prometheus 数据目录，默认为 `/data/prometheus`` |
| [`prometheus_sd_interval`](PARAM#prometheus_sd_interval)         | [`PROMETHEUS`](PARAM#prometheus)       |  interval  |  G  | prometheus target refresh interval, 5s by default  | Prometheus 目标刷新间隔，默认为 5s                |
| [`prometheus_scrape_interval`](PARAM#prometheus_scrape_interval) | [`PROMETHEUS`](PARAM#prometheus)       |  interval  |  G  | prometheus scrape & eval interval, 10s by default  | Prometheus 抓取 & 评估间隔，默认为 10s            |
| [`prometheus_scrape_timeout`](PARAM#prometheus_scrape_timeout)   | [`PROMETHEUS`](PARAM#prometheus)       |  interval  |  G  | prometheus global scrape timeout, 8s by default    | Prometheus 全局抓取超时，默认为 8s                |
| [`prometheus_options`](PARAM#prometheus_options)                 | [`PROMETHEUS`](PARAM#prometheus)       |    arg     |  G  | prometheus extra server options                    | Prometheus 额外的命令行参数选项                   |
| [`pushgateway_enabled`](PARAM#pushgateway_enabled)               | [`PROMETHEUS`](PARAM#prometheus)       |    bool    | G/I | setup pushgateway on this infra node?              | 在此基础设施节点上设置 pushgateway？                |
| [`pushgateway_options`](PARAM#pushgateway_options)               | [`PROMETHEUS`](PARAM#prometheus)       |    arg     |  G  | pushgateway extra server options                   | pushgateway 额外的命令行参数选项                  |
| [`blackbox_enabled`](PARAM#blackbox_enabled)                     | [`PROMETHEUS`](PARAM#prometheus)       |    bool    | G/I | setup blackbox_exporter on this infra node?        | 在此基础设施节点上设置 blackbox_exporter？          |
| [`blackbox_options`](PARAM#blackbox_options)                     | [`PROMETHEUS`](PARAM#prometheus)       |    arg     |  G  | blackbox_exporter extra server options             | blackbox_exporter 额外的命令行参数选项            |
| [`alertmanager_enabled`](PARAM#alertmanager_enabled)             | [`PROMETHEUS`](PARAM#prometheus)       |    bool    | G/I | setup alertmanager on this infra node?             | 在此基础设施节点上设置 alertmanager？               |
| [`alertmanager_options`](PARAM#alertmanager_options)             | [`PROMETHEUS`](PARAM#prometheus)       |    arg     |  G  | alertmanager extra server options                  | alertmanager 额外的命令行参数选项                 |
| [`exporter_metrics_path`](PARAM#exporter_metrics_path)           | [`PROMETHEUS`](PARAM#prometheus)       |    path    |  G  | exporter metric path, `/metrics` by default        | exporter 指标路径，默认为 /metrics              |
| [`exporter_install`](PARAM#exporter_install)                     | [`PROMETHEUS`](PARAM#prometheus)       |    enum    |  G  | how to install exporter? none,yum,binary           | 如何安装 exporter？none,yum,binary           |
| [`exporter_repo_url`](PARAM#exporter_repo_url)                   | [`PROMETHEUS`](PARAM#prometheus)       |    url     |  G  | exporter repo file url if install exporter via yum | 通过 yum 安装exporter时使用的yum仓库文件地址          |
| [`grafana_enabled`](PARAM#grafana_enabled)                       | [`GRAFANA`](PARAM#grafana)             |    bool    | G/I | enable grafana on this infra node?                 | 在此基础设施节点上启用 Grafana？                    |
| [`grafana_clean`](PARAM#grafana_clean)                           | [`GRAFANA`](PARAM#grafana)             |    bool    | G/A | clean grafana data during init?                    | 初始化Grafana期间清除数据？                       |
| [`grafana_admin_username`](PARAM#grafana_admin_username)         | [`GRAFANA`](PARAM#grafana)             |  username  |  G  | grafana admin username, `admin` by default         | Grafana 管理员用户名，默认为 `admin``             |
| [`grafana_admin_password`](PARAM#grafana_admin_password)         | [`GRAFANA`](PARAM#grafana)             |  password  |  G  | grafana admin password, `pigsty` by default        | Grafana 管理员密码，默认为 `pigsty``             |
| [`grafana_plugin_cache`](PARAM#grafana_plugin_cache)             | [`GRAFANA`](PARAM#grafana)             |    path    |  G  | path to grafana plugins cache tarball              | Grafana 插件缓存 tarball 的路径                |
| [`grafana_plugin_list`](PARAM#grafana_plugin_list)               | [`GRAFANA`](PARAM#grafana)             |  string[]  |  G  | grafana plugins to be downloaded with grafana-cli  | 使用 grafana-cli 下载的 Grafana 插件           |
| [`loki_enabled`](PARAM#loki_enabled)                             | [`LOKI`](PARAM#loki)                   |    bool    | G/I | enable loki on this infra node?                    | 在此基础设施节点上启用 loki？                       |
| [`loki_clean`](PARAM#loki_clean)                                 | [`LOKI`](PARAM#loki)                   |    bool    | G/A | whether remove existing loki data?                 | 是否删除现有的 loki 数据？                        |
| [`loki_data`](PARAM#loki_data)                                   | [`LOKI`](PARAM#loki)                   |    path    |  G  | loki data dir, `/data/loki` by default             | loki 数据目录，默认为 `/data/loki``             |
| [`loki_retention`](PARAM#loki_retention)                         | [`LOKI`](PARAM#loki)                   |  interval  |  G  | loki log retention period, 15d by default          | loki 日志保留期，默认为 15d                      |


</details>
