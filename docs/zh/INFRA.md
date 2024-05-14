# INFRA

> Pigsty 带有一个开箱即用，生产就绪的基础设施模块，为用户带来究极的可观测性体验。 [配置](#配置) | [管理](#管理) | [剧本](#剧本) | [监控](#监控) | [参数](#参数)


----------------

## 概览

每一套 Pigsty 部署都会提供一套基础架构组件，为纳管的节点与数据库集群提供服务，组件包括：

|               组件                |  端口  |     域名     | 描述                    |
|:-------------------------------:|:----:|:----------:|-----------------------|
|         [Nginx](#nginx)         |  80  | `h.pigsty` | Web服务门户（也用作yum/atp仓库） |
|   [AlertManager](#prometheus)   | 9093 | `a.pigsty` | 告警聚合分发                |
|    [Prometheus](#prometheus)    | 9090 | `p.pigsty` | 时间序列数据库（收存监控指标）       |
|       [Grafana](#grafana)       | 3000 | `g.pigsty` | 可视化平台                 |
|        [Loki](#grafana)         | 3100 |     -      | 日志收集服务器               |
|   [PushGateway](#prometheus)    | 9091 |     -      | 接受一次性的任务指标            |
| [BlackboxExporter](#prometheus) | 9115 |     -      | 黑盒监控探测                |
|       [DNSMASQ](#dnsmasq)       |  53  |     -      | DNS 服务器               |
|       [Chronyd](#chronyd)       | 123  |     -      | NTP 时间服务器             |
|    [PostgreSQL](#postgresql)    | 5432 |     -      | Pigsty CMDB 和默认数据库    |
|       [Ansible](#ansible)       |  -   |     -      | 运行剧本                  |


[![pigsty-arch.jpg](https://repo.pigsty.cc/img/pigsty-arch.jpg)](INFRA)

在 Pigsty 中，[PGSQL](PGSQL) 模块会使用到[INFRA节点](NODE#infra节点)上的一些服务，具体来说包括：

* 数据库集群/主机节点的域名，依赖INFRA节点的 DNSMASQ **解析**。
* 在数据库节点软件上**安装**，需要用到INFRA节点上的Nginx托管的本地 yum/apt 软件源。
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

有许多带有WebUI的基础设施组件通过Nginx对外暴露服务，例如Grafana，Prometheus，AlertManager，以及HAProxy流量管理页等，此外 yum/apt 仓库等静态文件资源也通过Nginx对外提供服务。

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

如果您没有可用的互联网域名或本地DNS解析，您可以在 `/etc/hosts` （MacOS/Linux）或`C:\Windows\System32\drivers\etc\hosts` （Windows）中添加本地静态解析记录。

Nginx相关配置参数位于：[配置：INFRA - NGINX](PARAM#nginx)


----------------

### 本地软件仓库

Pigsty会在安装时首先建立一个本地软件源，以加速后续软件安装。

该软件源由Nginx提供服务，默认位于为 `/www/pigsty`，可以访问 `http://h.pigsty/pigsty` 使用。

Pigsty的离线软件包即是将已经建立好的软件源目录（yum/apt）整个打成压缩包，当Pigsty尝试构建本地源时，如果发现本地源目录 `/www/pigsty` 已经存在，且带有 `/www/pigsty/repo_complete` 标记文件，则会认为本地源已经构建完成，从而跳过从原始上游下载软件的步骤，消除了对互联网访问的依赖。

Repo定义文件位于 `/www/pigsty.repo`，默认可以通过 `http://${admin_ip}/pigsty.repo` 获取

```bash
curl -L http://h.pigsty/pigsty.repo -o /etc/yum.repos.d/pigsty.repo
```

您也可以在没有Nginx的情况下直接使用文件本地源：

```ini
[pigsty-local]
name=Pigsty local $releasever - $basearch
baseurl=file:///www/pigsty/
enabled=1
gpgcheck=0
```

本地软件仓库相关配置参数位于：[配置：INFRA - REPO](PARAM#repo)


----------------

### Prometheus

Prometheus是监控时序数据库，默认监听9090端口，可以直接通过`IP:9090`或域名`http://p.pigsty`访问。

Prometheus是监控用时序数据库，提供以下功能：

* Prometheus默认通过本地静态文件服务发现获取监控对象，并为其关联身份信息。
* Prometheus从Exporter拉取监控指标数据，进行预计算加工后存入自己的TSDB中。
* Prometheus计算报警规则，将报警事件发往Alertmanager处理。

AlertManager是与Prometheus配套的告警平台，默认监听9093端口，可以直接通过`IP:9093`或域名 `http://a.pigsty` 访问。
Prometheus的告警事件会发送至AlertManager，但如果需要进一步处理，用户需要进一步对其进行配置，例如提供SMTP服务配置以发送告警邮件。

Prometheus、AlertManager，PushGateway，BlackboxExporter 的相关配置参数位于：[配置：INFRA - PROMETHEUS](INFRA#prometheus)



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

DNSMASQ 提供环境内的DNS**解析**服务，其他模块的域名将会注册到 INFRA节点上的 DNSMASQ 服务中。

DNS记录默认放置于所有INFRA节点的 `/etc/hosts.d/` 目录中。

DNSMASQ相关配置参数位于：[配置：INFRA - DNS](PARAM#dns)




----------------

### Chronyd

NTP服务用于同步环境内所有节点的时间（可选）

NTP相关配置参数位于：[配置：NODES - NTP](PARAM#node_time)






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

下面是与 INFRA 模块相关的一些管理任务：

----------------

### 安装卸载Infra模块

```bash
./infra.yml     # 在 infra 分组上安装 INFRA 模块
./infra-rm.yml  # 从 infra 分组上卸载 INFRA 模块
```

----------------

### 管理本地软件仓库

您可以使用以下剧本子任务，管理 Infra节点 上的本地yun源：

```bash
./infra.yml -t repo              #从互联网或离线包中创建本地软件源

./infra.yml -t repo_dir          # 创建本地软件源
./infra.yml -t repo_check        # 检查本地软件源是否已经存在？
./infra.yml -t repo_prepare      # 如果存在，直接使用已有的本地软件源
./infra.yml -t repo_build        # 如果不存在，从上游构建本地软件源
./infra.yml     -t repo_upstream     # 处理 /etc/yum.repos.d 中的上游仓库文件
./infra.yml     -t repo_remove       # 如果 repo_remove == true，则删除现有的仓库文件
./infra.yml     -t repo_add          # 将上游仓库文件添加到 /etc/yum.repos.d （或 /etc/apt/sources.list.d）
./infra.yml     -t repo_url_pkg      # 从由 repo_url_packages 定义的互联网下载包
./infra.yml     -t repo_cache        # 使用 yum makecache / apt update 创建上游软件源元数据缓存
./infra.yml     -t repo_boot_pkg     # 安装如 createrepo_c、yum-utils 等的引导包...（或 dpkg-）
./infra.yml     -t repo_pkg          # 从上游仓库下载包 & 依赖项
./infra.yml     -t repo_create       # 使用 createrepo_c & modifyrepo_c 创建本地软件源
./infra.yml     -t repo_use          # 将新建的仓库添加到 /etc/yum.repos.d | /etc/apt/sources.list.d 用起来
./infra.yml -t repo_nginx        # 如果没有 nginx 在服务，启动一个 nginx 作为 Web Server
```

其中最常用的命令为：

```bash
./infra.yml     -t repo_upstream     # 向 INFRA 节点添加 repo_upstream 中定义的上游软件源
./infra.yml     -t repo_pkg          # 从上游仓库下载包及其依赖项。
./infra.yml     -t repo_create       # 使用 createrepo_c & modifyrepo_c 创建/更新本地 yum 仓库
```



----------------

### 管理基础设施组件

您可以使用以下剧本子任务，管理 Infra节点 上的各个基础设施组件

```bash
./infra.yml -t infra           # 配置基础设施
./infra.yml -t infra_env       # 配置管理节点上的环境变量：env_dir, env_pg, env_var
./infra.yml -t infra_pkg       # 安装INFRA所需的软件包：infra_pkg_yum, infra_pkg_pip
./infra.yml -t infra_user      # 设置 infra 操作系统用户组
./infra.yml -t infra_cert      # 为 infra 组件颁发证书
./infra.yml -t dns             # 配置 DNSMasq：dns_config, dns_record, dns_launch
./infra.yml -t nginx           # 配置 Nginx：nginx_config, nginx_cert, nginx_static, nginx_launch, nginx_exporter
./infra.yml -t prometheus      # 配置 Prometheus：prometheus_clean, prometheus_dir, prometheus_config, prometheus_launch, prometheus_reload
./infra.yml -t alertmanager    # 配置 AlertManager：alertmanager_config, alertmanager_launch
./infra.yml -t pushgateway     # 配置 PushGateway：pushgateway_config, pushgateway_launch
./infra.yml -t blackbox        # 配置 Blackbox Exporter： blackbox_launch
./infra.yml -t grafana         # 配置 Grafana：grafana_clean, grafana_config, grafana_plugin, grafana_launch, grafana_provision
./infra.yml -t loki            # 配置 Loki：loki_clean, loki_dir, loki_config, loki_launch
./infra.yml -t infra_register  # 将 infra 组件注册到 prometheus
```

其他常用的任务包括：

```bash
./infra.yml -t nginx_index                        # 重新渲染 Nginx 首页内容
./infra.yml -t nginx_config,nginx_reload          # 重新渲染 Nginx 网站门户配置，对外暴露新的上游服务。
./infra.yml -t prometheus_conf,prometheus_reload  # 重新生成 Prometheus 主配置文件，并重载配置
./infra.yml -t prometheus_rule,prometheus_reload  # 重新拷贝 Prometheus 规则 & 告警，并重载配置
./infra.yml -t grafana_plugin                     # 从互联网上下载 Grafana 插件，通常需要科学上网
```


----------------

## 剧本

Pigsty 提供了三个与 INFRA 模块相关的剧本：

- [`infra.yml`](#infrayml) ：在 infra 节点上初始化 pigsty 基础设施
- [`infra-rm.yml`](#infra-rmyml)：从 infra 节点移除基础设施组件
- [`install.yml`](#installyml)：在当前节点上一次性完整安装 Pigsty

----------------

### `infra.yml`

INFRA模块剧本 [`infra.yml`](https://github.com/vonng/pigsty/blob/master/infra.yml) 用于在 [Infra节点](NODE#infra节点) 上初始化 pigsty 基础设施

**执行该剧本将完成以下任务**

* 配置元节点的目录与环境变量
* 下载并建立一个本地软件源，加速后续安装。（若使用离线软件包，则跳过下载阶段）
* 将当前元节点作为一个普通节点纳入 Pigsty 管理
* 部署**基础设施**组件，包括 Prometheus, Grafana, Loki, Alertmanager, PushGateway，Blackbox Exporter 等

**该剧本默认在 [INFRA节点](NODE#infra节点) 上执行**

* Pigsty默认将使用**当前执行此剧本的节点**作为Pigsty的Infra节点与Admin节点。
* Pigsty在[配置过程](INSTALL#configure)中默认会将当前节点标记为Infra/Admin节点，并使用**当前节点首要IP地址**替换配置模板中的占位IP地址`10.10.10.10`。
* 该节点除了可以发起管理，部署有基础设施，与一个部署普通托管节点并无区别。
* 单机安装时，ETCD 也会安装在此节点上，提供 DCS 服务

**本剧本的一些注意事项**

* 本剧本为幂等剧本，重复执行会抹除元节点上的基础设施组件。
* 当离线软件源 `/www/pigsty/repo_complete` 存在时，本剧本会跳过从互联网下载软件的任务。完整执行该剧本耗时约5-8分钟，视机器配置而异。
* 不使用离线软件包而直接从互联网原始上游下载软件时，可能耗时10-20分钟，根据您的网络条件而异。

[![asciicast](https://asciinema.org/a/566412.svg)](https://asciinema.org/a/566412)


----------------

### `infra-rm.yml`

INFRA模块剧本 [`infra-rm.yml`](https://github.com/vonng/pigsty/blob/master/infra-rm.yml) 用于从 [Infra节点](NODE#infra节点) 上移除 pigsty 基础设施

常用子任务包括：

```bash
./infra-rm.yml               # 移除 INFRA 模块
./infra-rm.yml -t service    # 停止 INFRA 上的基础设施服务
./infra-rm.yml -t data       # 移除 INFRA 上的存留数据
./infra-rm.yml -t package    # 卸载 INFRA 上安装的软件包
```


----------------

### `install.yml`

INFRA模块剧本 [`install.yml`](https://github.com/vonng/pigsty/blob/master/install.yml)用于在**所有节点**上一次性完整安装 Pigsty

该剧本在 [剧本：一次性安装](PLAYBOOK#一次性安装) 中有更详细的介绍。
       



----------------

## 监控


[Pigsty Home](https://demo.pigsty.cc/d/pigsty) : Pigsty 监控系统主页

<details><summary>Pigsty Home Dashboard</summary>

[![pigsty.jpg](https://repo.pigsty.cc/img/pigsty.jpg)](https://demo.pigsty.cc/d/pigsty/)

</details>


[INFRA Overview](https://demo.pigsty.cc/d/infra-overview) : Pigsty 基础设施自监控概览

<details><summary>INFRA Overview Dashboard</summary>

[![infra-overview.jpg](https://repo.pigsty.cc/img/infra-overview.jpg)](https://demo.pigsty.cc/d/infra-overview/)

</details>


[Nginx Overview](https://demo.pigsty.cc/d/nginx-overview) : Nginx 监控指标与日志

<details><summary>Nginx Overview Dashboard</summary>

[![nginx-overview.jpg](https://repo.pigsty.cc/img/nginx-overview.jpg)](https://demo.pigsty.cc/d/nginx-overview)

</details>


[Grafana Overview](https://demo.pigsty.cc/d/grafana-overview): Grafana 监控指标与日志

<details><summary>Grafana Overview Dashboard</summary>

[![grafana-overview.jpg](https://repo.pigsty.cc/img/grafana-overview.jpg)](https://demo.pigsty.cc/d/grafana-overview)

</details>


[Prometheus Overview](https://demo.pigsty.cc/d/prometheus-overview): Prometheus 监控指标与日志

<details><summary>Prometheus Overview Dashboard</summary>

[![prometheus-overview.jpg](https://repo.pigsty.cc/img/prometheus-overview.jpg)](https://demo.pigsty.cc/d/prometheus-overview)

</details>


[Loki Overview](https://demo.pigsty.cc/d/loki-overview): Loki 监控指标与日志

<details><summary>Loki Overview Dashboard</summary>

[![loki-overview.jpg](https://repo.pigsty.cc/img/loki-overview.jpg)](https://demo.pigsty.cc/d/loki-overview)

</details>


[Logs Instance](https://demo.pigsty.cc/d/logs-instance): 查阅单个节点上的日志信息

<details><summary>Logs Instance Dashboard</summary>

[![logs-instance.jpg](https://repo.pigsty.cc/img/logs-instance.jpg)](https://demo.pigsty.cc/d/logs-instance)

</details>


[Logs Overview](https://demo.pigsty.cc/d/logs-overview): 查阅全局日志信息

<details><summary>Logs Overview Dashboard</summary>

[![logs-overview.jpg](https://repo.pigsty.cc/img/logs-overview.jpg)](https://demo.pigsty.cc/d/logs-overview)

</details>


[CMDB Overview](https://demo.pigsty.cc/d/cmdb-overview): CMDB 可视化

<details><summary>CMDB Overview Dashboard</summary>

[![cmdb-overview.jpg](https://repo.pigsty.cc/img/cmdb-overview.jpg)](https://demo.pigsty.cc/d/cmdb-overview)

</details>


[ETCD Overview](https://demo.pigsty.cc/d/etcd-overview): etcd 监控指标与日志

<details><summary>ETCD Overview Dashboard</summary>

[![etcd-overview.jpg](https://repo.pigsty.cc/img/etcd-overview.jpg)](https://demo.pigsty.cc/d/etcd-overview)

</details>




----------------

## 参数

[`INFRA`](PARAM#infra) 模块有下列10个参数组。

- [`META`](PARAM#meta)：Pigsty元数据
- [`CA`](PARAM#ca)：自签名公私钥基础设施/CA
- [`INFRA_ID`](PARAM#infra_id)：基础设施门户，Nginx域名
- [`REPO`](PARAM#repo)：本地软件源
- [`INFRA_PACKAGE`](PARAM#infra_package)：基础设施软件包
- [`NGINX`](PARAM#nginx)：Nginx 网络服务器
- [`DNS`](PARAM#dns)：DNSMASQ 域名服务器
- [`PROMETHEUS`](PARAM#prometheus)：Prometheus 时序数据库全家桶
- [`GRAFANA`](PARAM#grafana)：Grafana 可观测性全家桶
- [`LOKI`](PARAM#loki)：Loki 日志服务

<details><summary>完整参数列表</summary>

| 参数                                                               | 参数组                                    |     类型     | 级别  | 说明                                      |
|------------------------------------------------------------------|----------------------------------------|:----------:|:---:|-----------------------------------------|
| [`version`](PARAM#version)                                       | [`META`](PARAM#meta)                   |   string   |  G  | pigsty 版本字符串                            |
| [`admin_ip`](PARAM#admin_ip)                                     | [`META`](PARAM#meta)                   |     ip     |  G  | 管理节点 IP 地址                              |
| [`region`](PARAM#region)                                         | [`META`](PARAM#meta)                   |    enum    |  G  | 上游镜像区域：default,china,europe             |
| [`proxy_env`](PARAM#proxy_env)                                   | [`META`](PARAM#meta)                   |    dict    |  G  | 下载包时使用的全局代理环境变量                         |
| [`ca_method`](PARAM#ca_method)                                   | [`CA`](PARAM#ca)                       |    enum    |  G  | CA处理方式：create,recreate,copy，默认为没有则创建    |
| [`ca_cn`](PARAM#ca_cn)                                           | [`CA`](PARAM#ca)                       |   string   |  G  | CA CN名称，固定为 pigsty-ca                   |
| [`cert_validity`](PARAM#cert_validity)                           | [`CA`](PARAM#ca)                       |  interval  |  G  | 证书有效期，默认为 20 年                          |
| [`infra_seq`](PARAM#infra_seq)                                   | [`INFRA_ID`](PARAM#infra_id)           |    int     |  I  | 基础设施节号，必选身份参数                           |
| [`infra_portal`](PARAM#infra_portal)                             | [`INFRA_ID`](PARAM#infra_id)           |    dict    |  G  | 通过Nginx门户暴露的基础设施服务列表                    |
| [`repo_enabled`](PARAM#repo_enabled)                             | [`REPO`](PARAM#repo)                   |    bool    | G/I | 在此基础设施节点上创建本地软件源？                       |
| [`repo_home`](PARAM#repo_home)                                   | [`REPO`](PARAM#repo)                   |    path    |  G  | 软件仓库主目录，默认为`/www``                      |
| [`repo_name`](PARAM#repo_name)                                   | [`REPO`](PARAM#repo)                   |   string   |  G  | 软件仓库名称，默认为 pigsty                       |
| [`repo_endpoint`](PARAM#repo_endpoint)                           | [`REPO`](PARAM#repo)                   |    url     |  G  | 仓库的访问点：域名或 `ip:port` 格式                 |
| [`repo_remove`](PARAM#repo_remove)                               | [`REPO`](PARAM#repo)                   |    bool    | G/A | 构建本地仓库时是否移除现有上游仓库源定义文件？                 |
| [`repo_modules`](#repo_modules)                                  | [`REPO`](PARAM#repo)                   |   string   | G/A | 启用的上游仓库模块列表，用逗号分隔                       |
| [`repo_upstream`](PARAM#repo_upstream)                           | [`REPO`](PARAM#repo)                   | upstream[] |  G  | 上游仓库源定义：从哪里下载上游包？                       |
| [`repo_packages`](PARAM#repo_packages)                           | [`REPO`](PARAM#repo)                   |  string[]  |  G  | 从上游仓库下载哪些软件包？                           |
| [`repo_url_packages`](PARAM#repo_url_packages)                   | [`REPO`](PARAM#repo)                   |  string[]  |  G  | 使用URL下载的额外软件包列表                         |
| [`infra_packages`](PARAM#infra_packages)                         | [`INFRA_PACKAGE`](PARAM#infra_package) |  string[]  |  G  | 在基础设施节点上要安装的软件包                         |
| [`infra_packages_pip`](PARAM#infra_packages_pip)                 | [`INFRA_PACKAGE`](PARAM#infra_package) |   string   |  G  | 在基础设施节点上使用 pip 安装的包                     |
| [`nginx_enabled`](PARAM#nginx_enabled)                           | [`NGINX`](PARAM#nginx)                 |    bool    | G/I | 在此基础设施节点上启用 nginx？                      |
| [`nginx_exporter_enabled`](PARAM#nginx_exporter_enabled)         | [`NGINX`](PARAM#nginx)                 |    bool    | G/I | 在此基础设施节点上启用 nginx_exporter？             |
| [`nginx_sslmode`](PARAM#nginx_sslmode)                           | [`NGINX`](PARAM#nginx)                 |    enum    |  G  | nginx SSL模式？disable,enable,enforce      |
| [`nginx_home`](PARAM#nginx_home)                                 | [`NGINX`](PARAM#nginx)                 |    path    |  G  | nginx 内容目录，默认为 `/www`，通常和仓库目录一致         |
| [`nginx_port`](PARAM#nginx_port)                                 | [`NGINX`](PARAM#nginx)                 |    port    |  G  | nginx 监听端口，默认为 80                       |
| [`nginx_ssl_port`](PARAM#nginx_ssl_port)                         | [`NGINX`](PARAM#nginx)                 |    port    |  G  | nginx SSL监听端口，默认为 443                   |
| [`nginx_navbar`](PARAM#nginx_navbar)                             | [`NGINX`](PARAM#nginx)                 |  index[]   |  G  | nginx 首页导航链接列表                          |
| [`dns_enabled`](PARAM#dns_enabled)                               | [`DNS`](PARAM#dns)                     |    bool    | G/I | 在此基础设施节点上设置dnsmasq？                     |
| [`dns_port`](PARAM#dns_port)                                     | [`DNS`](PARAM#dns)                     |    port    |  G  | DNS 服务器监听端口，默认为 53                      |
| [`dns_records`](PARAM#dns_records)                               | [`DNS`](PARAM#dns)                     |  string[]  |  G  | 由 dnsmasq 解析的动态 DNS 记录                  |
| [`prometheus_enabled`](PARAM#prometheus_enabled)                 | [`PROMETHEUS`](PARAM#prometheus)       |    bool    | G/I | 在此基础设施节点上启用 prometheus？                 |
| [`prometheus_clean`](PARAM#prometheus_clean)                     | [`PROMETHEUS`](PARAM#prometheus)       |    bool    | G/A | 初始化Prometheus的时候清除现有数据？                 |
| [`prometheus_data`](PARAM#prometheus_data)                       | [`PROMETHEUS`](PARAM#prometheus)       |    path    |  G  | Prometheus 数据目录，默认为 `/data/prometheus`` |
| [`prometheus_sd_dir`](PARAM#prometheus_sd_dir)                   | [`PROMETHEUS`](PARAM#prometheus)       |    path    |  G  | Prometheus 服务发现目标文件目录                   |
| [`prometheus_sd_interval`](PARAM#prometheus_sd_interval)         | [`PROMETHEUS`](PARAM#prometheus)       |  interval  |  G  | Prometheus 目标刷新间隔，默认为 5s                |
| [`prometheus_scrape_interval`](PARAM#prometheus_scrape_interval) | [`PROMETHEUS`](PARAM#prometheus)       |  interval  |  G  | Prometheus 抓取 & 评估间隔，默认为 10s            |
| [`prometheus_scrape_timeout`](PARAM#prometheus_scrape_timeout)   | [`PROMETHEUS`](PARAM#prometheus)       |  interval  |  G  | Prometheus 全局抓取超时，默认为 8s                |
| [`prometheus_options`](PARAM#prometheus_options)                 | [`PROMETHEUS`](PARAM#prometheus)       |    arg     |  G  | Prometheus 额外的命令行参数选项                   |
| [`pushgateway_enabled`](PARAM#pushgateway_enabled)               | [`PROMETHEUS`](PARAM#prometheus)       |    bool    | G/I | 在此基础设施节点上设置 pushgateway？                |
| [`pushgateway_options`](PARAM#pushgateway_options)               | [`PROMETHEUS`](PARAM#prometheus)       |    arg     |  G  | pushgateway 额外的命令行参数选项                  |
| [`blackbox_enabled`](PARAM#blackbox_enabled)                     | [`PROMETHEUS`](PARAM#prometheus)       |    bool    | G/I | 在此基础设施节点上设置 blackbox_exporter？          |
| [`blackbox_options`](PARAM#blackbox_options)                     | [`PROMETHEUS`](PARAM#prometheus)       |    arg     |  G  | blackbox_exporter 额外的命令行参数选项            |
| [`alertmanager_enabled`](PARAM#alertmanager_enabled)             | [`PROMETHEUS`](PARAM#prometheus)       |    bool    | G/I | 在此基础设施节点上设置 alertmanager？               |
| [`alertmanager_options`](PARAM#alertmanager_options)             | [`PROMETHEUS`](PARAM#prometheus)       |    arg     |  G  | alertmanager 额外的命令行参数选项                 |
| [`exporter_metrics_path`](PARAM#exporter_metrics_path)           | [`PROMETHEUS`](PARAM#prometheus)       |    path    |  G  | exporter 指标路径，默认为 /metrics              |
| [`exporter_install`](PARAM#exporter_install)                     | [`PROMETHEUS`](PARAM#prometheus)       |    enum    |  G  | 如何安装 exporter？none,yum,binary           |
| [`exporter_repo_url`](PARAM#exporter_repo_url)                   | [`PROMETHEUS`](PARAM#prometheus)       |    url     |  G  | 通过 yum 安装exporter时使用的yum仓库文件地址          |
| [`grafana_enabled`](PARAM#grafana_enabled)                       | [`GRAFANA`](PARAM#grafana)             |    bool    | G/I | 在此基础设施节点上启用 Grafana？                    |
| [`grafana_clean`](PARAM#grafana_clean)                           | [`GRAFANA`](PARAM#grafana)             |    bool    | G/A | 初始化Grafana期间清除数据？                       |
| [`grafana_admin_username`](PARAM#grafana_admin_username)         | [`GRAFANA`](PARAM#grafana)             |  username  |  G  | Grafana 管理员用户名，默认为 `admin``             |
| [`grafana_admin_password`](PARAM#grafana_admin_password)         | [`GRAFANA`](PARAM#grafana)             |  password  |  G  | Grafana 管理员密码，默认为 `pigsty``             |
| [`grafana_plugin_cache`](PARAM#grafana_plugin_cache)             | [`GRAFANA`](PARAM#grafana)             |    path    |  G  | Grafana 插件缓存 tarball 的路径                |
| [`grafana_plugin_list`](PARAM#grafana_plugin_list)               | [`GRAFANA`](PARAM#grafana)             |  string[]  |  G  | 使用 grafana-cli 下载的 Grafana 插件           |
| [`loki_enabled`](PARAM#loki_enabled)                             | [`LOKI`](PARAM#loki)                   |    bool    | G/I | 在此基础设施节点上启用 loki？                       |
| [`loki_clean`](PARAM#loki_clean)                                 | [`LOKI`](PARAM#loki)                   |    bool    | G/A | 是否删除现有的 loki 数据？                        |
| [`loki_data`](PARAM#loki_data)                                   | [`LOKI`](PARAM#loki)                   |    path    |  G  | loki 数据目录，默认为 `/data/loki``             |
| [`loki_retention`](PARAM#loki_retention)                         | [`LOKI`](PARAM#loki)                   |  interval  |  G  | loki 日志保留期，默认为 15d                      |


</details>
