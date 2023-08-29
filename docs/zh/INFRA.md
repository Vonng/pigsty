# INFRA

> Pigsty 带有一个开箱即用，生产就绪的基础设施模块，为用户带来究极的可观测性体验。 [配置](#配置) | [管理](#管理) | [剧本](#剧本) | [监控](#监控) | [参数](#参数)


----------------

## 概览

每一套 Pigsty 部署都会提供一套基础架构组件，为纳管的节点与数据库集群提供服务，组件包括：

|               组件                |  端口  |     域名     | 描述                  |
|:-------------------------------:|:----:|:----------:|---------------------|
|         [Nginx](#nginx)         |  80  | `h.pigsty` | Web服务门户（也用作 Yum 仓库） |
|   [AlertManager](#prometheus)   | 9093 | `a.pigsty` | 告警聚合分发              |
|    [Prometheus](#prometheus)    | 9090 | `p.pigsty` | 时间序列数据库（收存监控指标）     |
|       [Grafana](#grafana)       | 3000 | `g.pigsty` | 可视化平台               |
|        [Loki](#grafana)         | 3100 |     -      | 日志收集服务器             |
|   [PushGateway](#prometheus)    | 9091 |     -      | 接受一次性的任务指标          |
| [BlackboxExporter](#prometheus) | 9115 |     -      | 黑盒监控探测              |
|       [DNSMASQ](#dnsmasq)       |  53  |     -      | DNS 服务器             |
|       [Chronyd](#chronyd)       | 123  |     -      | NTP 时间服务器           |
|    [PostgreSQL](#postgresql)    | 5432 |     -      | Pigsty CMDB 和默认数据库  |
|       [Ansible](#ansible)       |  -   |     -      | 运行剧本                |


![pigsty-infra](https://user-images.githubusercontent.com/8587410/206972543-664ae71b-7ed1-4e82-90bd-5aa44c73bca4.gif)

在 Pigsty 中，[PGSQL](PGSQL) 模块会使用到[INFRA节点](#infra节点)上的一些服务，具体来说包括：

* 数据库集群/主机节点的域名，依赖INFRA节点的 DNSMASQ **解析**。
* 在数据库节点软件上**安装**，需要用到INFRA节点上的Nginx托管的本地Yum软件源。
* 数据库集群/节点的监控**指标**，会被INFRA节点的 Prometheus 收集抓取。
* 数据库节点的日志会被 Promtail 收集，并发往 INFRA节点上的 Loki。
* 用户会从 Infra/Admin 节点上使用 Ansible 或其他工具发起对数据库节点的**管理**：
    * 执行集群创建，扩缩容，实例/集群回收
    * 创建业务用户、业务数据库、修改服务、HBA修改；
    * 执行日志采集、垃圾清理，备份，巡检等
* 数据库节点默认会从INFRA/ADMIN节点上的 NTP 服务器同步时间
* 如果没有专用集群，高可用组件 Patroni 会使用 INFRA 节点上的 etcd 作为高可用DCS。
* 如果没有专用集群，备份组件 pgbackrest 会使用 INFRA 节点上的 minio 作为可选的集中备份仓库。


----------------

### Nginx

Nginx是Pigsty所有WebUI类服务的访问入口，默认使用管理节点80端口。

有许多带有WebUI的基础设施组件通过Nginx对外暴露服务，例如Grafana，Prometheus，AlertManager，以及HAProxy流量管理页等，此外YumRepo等静态文件资源也通过Nginx对外提供服务。

Nginx会根据 [`infra_portal`](PARAM#infra_portal) 的内容，通过**域名**进行区分，将访问请求转发至对应的上游组件处理。如果您使用了其他的域名，或者公网域名，可以在这里进行相应修改：

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

Pigsty强烈建议使用域名访问Pigsty UI系统，而不是直接通过IP+端口的方式访问，基于以下几个理由：
* 使用域名便于启用 HTTPS 流量加密，可以将访问收拢至Nginx，审计一切请求，并方便地集成认证机制。
* 一些组件默认只监听 127.0.0.1 ，因此只能通过Nginx代理访问。
* 域名更容易记忆，并提供了额外的配置灵活性。

如果您没有可用的互联网域名或本地DNS解析，您可以在 `/etc/hosts`或`C:\Windows\System32\drivers\etc\hosts`中添加本地静态解析记录。

Nginx相关配置参数位于：[配置：INFRA - NGINX](PARAM#nginx)


----------------

### Yum仓库

Pigsty会在安装时首先建立一个本地Yum软件源，以加速后续软件安装。

该Yum源由Nginx提供服务，默认位于为 `/www/pigsty`，可以访问 `http://h.pigsty/pigsty` 使用。

Pigsty的离线软件包即是将已经建立好的Yum Repo目录整个打成压缩包，当Pigsty尝试构建本地源时，如果发现本地源目录 `/www/pigsty` 已经存在，且带有 `/www/pigsty/repo_complete` 标记文件，则会认为本地源已经构建完成，从而跳过从原始上游下载软件的步骤，消除了对互联网访问的依赖。

Repo定义文件位于 `/www/pigsty.repo`，默认可以通过`http://yum.pigsty/pigsty.repo` 获取

```bash
curl http://h.pigsty/pigsty.repo -o /etc/yum.repos.d/pigsty.repo
```

您也可以在没有Nginx的情况下直接使用文件本地源：

```ini
[pigsty-local]
name=Pigsty local $releasever - $basearch
baseurl=file:///www/pigsty/
enabled=1
gpgcheck=0
```

Yum Repo相关配置参数位于：[配置：INFRA - REPO](PARAM#repo)


----------------

### Prometheus

Prometheus是监控时序数据库，默认监听9090端口，可以直接通过`IP:9090`或域名`http://p.pigsty`访问。

Prometheus是监控用时序数据库，提供以下功能：

* Prometheus默认通过本地静态文件服务发现获取监控对象，并为其关联身份信息。
* Prometheus可以选择使用Consul服务发现，自动获取监控对象。
* Prometheus从Exporter拉取监控指标数据，进行预计算加工后存入自己的TSDB中。
* Prometheus计算报警规则，将报警事件发往Alertmanager处理。

AlertManager是与Prometheus配套的告警平台，默认监听9093端口，可以直接通过`IP:9093`或域名 `http://a.pigsty` 访问。
Prometheus的告警事件会发送至AlertManager，但如果需要进一步处理，用户需要进一步对其进行配置，例如提供SMTP服务配置以发送告警邮件。

Prometheus、AlertManager，PushGateway，BlackboxExporter 的相关配置参数位于：[配置：INFRA - PROMETHEUS](/zh/docs/infra/config#prometheus)



----------------

### Grafana

Grafana是开源的可视化/监控平台，是Pigsty WebUI的核心，默认监听3000端口，可以直接通过`IP:3000`或域名`http://g.pigsty`访问。

Pigsty的监控系统基于Dashboard构建，通过URL进行连接与跳转。您可以快速地在监控中下钻上卷，快速定位故障与问题。

此外，Grafana还可以用作通用的低代码前后端平台，制作交互式可视化数据应用。因此，Pigsty使用的Grafana带有一些额外的可视化插件，例如ECharts面板。


Loki是用于日志收集的日志数据库，默认监听3100端口，节点上的Promtail向元节点上的Loki推送日志。

Grafana与Loki相关配置参数位于：[配置：INFRA - GRAFANA](PARAM#grafana)，[配置：INFRA - Loki](PARAM#loki)



----------------

### Ansible

Pigsty默认会在元节点上安装Ansible，Ansible是一个流行的运维工具，采用声明式的配置风格与幂等的剧本设计，可以极大降低系统维护的复杂度。


----------------

### DNSMASQ

DNSMASQ 提供环境内的DNS**解析**服务，其他模块的域名将会注册到 INFRA节点上的 DNSMASQ 服务中，放置于 `/etc/hosts.d/` 里。

DNSMASQ相关配置参数位于：[配置：INFRA - DNS](param#dns)




----------------

### Chronyd

NTP服务用于同步环境内所有节点的时间（可选）

NTP相关配置参数位于：[配置：NODES - NTP](param#node_time)






----------------

## 配置

要在节点上安装 INFRA 模块，首先需要在配置清单中的 `infra` 分组中将其加入，并分配实例号 [`infra_seq`](PARAM#infra_seq)

```yaml
# 配置单个 INFRA 节点
infra: { hosts: { 10.10.10.10: { infra_seq: 1 } }}

# 配置两个 INFRA 节点
infra:
  hosts:
    10.10.10.10: { infra_seq: 1 }
    10.10.10.11: { infra_seq: 2 }
```

然后，使用 [`infra.yml`](#infrayml) 剧本在节点上初始化 INFRA 模块即可。



----------------

## 管理

```bash
# repo          : bootstrap a local yum repo from internet or offline packages
#   - repo_dir      : create CA directory
#   - repo_check    : generate ca private key: files/pki/ca/ca.key
#   - repo_prepare  : signing ca cert: files/pki/ca/ca.crt
#   - repo_build    : install postgres extensions only
#     - repo_upstream    : handle upstream repo files in /etc/yum.repos.d
#       - repo_remove        : remove existing repo file if repo_remove == true
#       - repo_add           : add upstream repo files to /etc/yum.repos.d
#     - repo_url_pkg     : download packages from internet defined by repo_url_packages
#     - repo_cache       : make upstream yum cache with yum makecache
#     - repo_boot_pkg    : install bootstrap pkg such as createrepo_c,yum-utils,...
#     - repo_pkg         : download packages & dependencies from upstream repo
#     - repo_create      : create a local yum repo with createrepo_c & modifyrepo_c
#     - repo_use         : add newly built repo into /etc/yum.repos.d
#   - repo_nginx    : launch a nginx for repo if no nginx is serving
#
# node/haproxy/docker/monitor : setup infra node as a common node (check node.yml)
#   - node_name, node_hosts, node_resolv, node_firewall, node_ca, node_repo, node_pkg
#   - node_feature, node_kernel, node_tune, node_sysctl, node_profile, node_ulimit
#   - node_data, node_admin, node_timezone, node_ntp, node_crontab
#   - haproxy_install, haproxy_config, haproxy_launch, haproxy_reload
#   - docker_install, docker_admin, docker_config, docker_launch, docker_image
#   - haproxy_register, node_exporter, node_register, promtail
#
# infra         : setup infra components
#   - infra_env      : env_dir, env_pg, env_var
#   - infra_pkg      : infra_pkg_yum, infra_pkg_pip
#   - infra_user     : setup infra os user group
#   - infra_cert     : issue cert for infra components
#   - dns            : dns_config, dns_record, dns_launch
#   - nginx          : nginx_config, nginx_cert, nginx_static, nginx_launch, nginx_exporter
#   - prometheus     : prometheus_clean, prometheus_dir, prometheus_config, prometheus_launch, prometheus_reload
#   - alertmanager   : alertmanager_config, alertmanager_launch
#   - pushgateway    : pushgateway_config, pushgateway_launch
#   - blackbox       : blackbox_config, blackbox_launch
#   - grafana        : grafana_clean, grafana_config, grafana_plugin, grafana_launch, grafana_provision
#   - loki           : loki clean, loki_dir, loki_config, loki_launch
#   - infra_register : register infra components to prometheus
```



----------------

## 剧本

Pigsty 提供了三个与 INFRA 模块相关的剧本：

- [`install.yml`](#installyml)：在当前节点上一次性完整安装 Pigsty
- [`infra.yml`](#infrayml) ：在 infra 节点上初始化 pigsty 基础设施
- [`infra-rm.yml`](#infra-rmyml)：从 infra 节点移除基础设施组件

----------------

### `install.yml`

INFRA模块剧本 [`install.yml`](https://github.com/vonng/pigsty/blob/master/install.yml)用于在**所有节点**上一次性完整安装 Pigsty

----------------

### `infra.yml`

INFRA模块剧本 [`infra.yml`](https://github.com/vonng/pigsty/blob/master/infra.yml) 用于在 [Infra节点](NODE#infra节点) 上初始化 pigsty 基础设施

[![asciicast](https://asciinema.org/a/566412.svg)](https://asciinema.org/a/566412)

----------------

### `infra-rm.yml`

INFRA模块剧本 [`infra-rm.yml`](https://github.com/vonng/pigsty/blob/master/infra-rm.yml) 用于从 [Infra节点](NODE#infra节点) 上移除 pigsty 基础设施



       



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
