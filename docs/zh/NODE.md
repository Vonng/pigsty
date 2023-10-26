# NODE

> 纳管节点，将其调整至所需状态，并进行监控。 [配置](#配置) | [管理](#管理) | [剧本](#剧本) | [监控](#监控) | [参数](#参数)


----------------

## 概念

节点是硬件资源的抽象，它可以是裸机、虚拟机、容器或者是 k8s pods：只要装着操作系统，可以使用 CPU/内存/磁盘/网络 资源就行。

在 Pigsty 中存在不同类型的节点，它们的区别主要在于安装了不同的[模块](ARCH#模块)

- [普通节点](#普通节点)：被 Pigsty 所管理的普通节点
- [ADMIN节点](#admin节点)：使用 Ansible 发出管理指令的节点
- [INFRA节点](#infra节点)：安装 [`INFRA`](INFRA) 模块的节点
- [PGSQL节点](#pgsql节点)：安装 [`PGSQL`](PGSQL) 模块的节点
- 安装了其他[模块](ARCH#模块)的节点…… 

在[单机安装](ARCH#单机安装)时，当前节点会被同时视作为管理节点、基础设施节点、PGSQL 节点，当然，它也是一个普通的节点。


----------------

### 普通节点

你可以使用 Pigsty 管理节点，并在其上安装模块。`node.yml` 剧本将调整节点至所需状态。以下服务默认会被添加到所有节点：

|         组件          |  端口  | 描述                 | 状态     |
|:-------------------:|:----:|--------------------|--------|
|    Node Exporter    | 9100 | 节点监控指标导出器          | 默认启用   |
|    HAProxy Admin    | 9101 | HAProxy 管理页面       | 默认启用   |
|      Promtail       | 9080 | 日志收集代理             | 默认启用   |
|    Docker Daemon    | 9323 | 启用容器支持             | *按需启用* |
|     Keepalived      |  -   | 负责管理主机集群 L2 VIP    | *按需启用* |
| Keepalived Exporter | 9650 | 负责监控 Keepalived 状态 | *按需启用* |


此外，您可以为节点选装 Docker 与 Keepalived（及其监控 keepalived exporter），这两个组件默认不启用。


----------------

### ADMIN节点

在一套 Pigsty 部署中会有且只有一个管理节点，由 [`admin_ip`](PARAM#admin_ip) 指定。在单机安装的[配置](INSTALL#配置)过程中，它会被被设置为该机器的首要IP地址。

该节点将具有对所有其他节点的 `ssh/sudo` 访问权限：管理节点的安全至关重要，请确保它的访问受到严格控制。

通常管理节点与基础设施节点（infra节点）重合。如果有多个基础设施节点，管理节点通常是所有 infra 节点中的第一个，其他的作为管理节点的备份。


----------------

### INFRA节点

一套 Pigsty 部署可能有一个或多个 基础设施节点（INFRA节点），在大型生产环境中可能会有 2 ~ 3 个。

配置清单中的 `infra` 分组列出并指定了哪些节点是INFRA节点，这些节点会安装 [INFRA](INFRA) 模块（DNS、Nginx、Prometheus、Grafana 等...）。

管理节点通常是是INFRA节点分组中的第一台，其他INFRA节点可以被用作"备用"的管理节点。


----------------

### PGSQL节点

安装了 [PGSQL](PGSQL) 模块的节点被称为 PGSQL 节点。节点和 PostgreSQL 实例是1:1部署的。

在这种情况下，PGSQL节点可以从相应的 PostgreSQL 实例上借用身份：[`node_id_from_pg`](PARAM#node_id_from_pg) 参数会控制这一点。

|         组件          |  端口  | 描述                | 状态     |
|:-------------------:|:----:|-------------------|--------|
|      Postgres       | 5432 | Pigsty CMDB       | 默认启用   |
|      Pgbouncer      | 6432 | Pgbouncer 连接池服务   | 默认启用   |
|       Patroni       | 8008 | Patroni 高可用组件     | 默认启用   |
|   Haproxy Primary   | 5433 | 主连接池：读/写服务        | 默认启用   |
|   Haproxy Replica   | 5434 | 副本连接池：只读服务        | 默认启用   |
|   Haproxy Default   | 5436 | 主直连服务             | 默认启用   |
|   Haproxy Offline   | 5438 | 离线直连：离线读服务        | 默认启用   |
|  Haproxy `service`  | 543x | PostgreSQL 定制服务   | *按需定制* |
|    Haproxy Admin    | 9101 | 监控指标和流量管理         | 默认启用   |
|     PG Exporter     | 9630 | PG 监控指标导出器        | 默认启用   |
| PGBouncer Exporter  | 9631 | PGBouncer 监控指标导出器 | 默认启用   |
|    Node Exporter    | 9100 | 节点监控指标导出器         | 默认启用   |
|      Promtail       | 9080 | 收集数据库组件与主机日志      | 默认启用   |
|     vip-manager     |  -   | 将 VIP 绑定到主节点      | *按需启用* |
|    Docker Daemon    | 9323 | Docker 守护进程       | *按需启用* |
|     keepalived      |  -   | 为整个集群绑定 L2 VIP    | *按需启用* |
| Keepalived Exporter | 9650 | Keepalived 指标导出器  | *按需启用* |



----------------

## 配置

Pigsty使用**IP地址**作为**节点**的唯一身份标识，**该IP地址应当是数据库实例监听并对外提供服务的内网IP地址**。

```yaml
node-test:
  hosts:
    10.10.10.11: { nodename: node-test-1 }
    10.10.10.12: { nodename: node-test-2 }
    10.10.10.13: { nodename: node-test-3 }
  vars:
    node_cluster: node-test
```

**该IP地址必须是数据库实例监听并对外提供服务的IP地址**，但不宜使用公网IP地址。尽管如此，用户并不一定非要通过该IP地址连接至该数据库。
例如，通过SSH隧道或跳板机中转的方式间接操作管理目标节点也是可行的。
但在标识数据库节点时，首要IPv4地址依然是节点的核心标识符。**这一点非常重要，用户应当在配置时保证这一点**。
IP地址即配置清单中主机的`inventory_hostname` ，体现为`<cluster>.hosts`对象中的`key`。除此之外，每个节点还有两个额外的 [身份参数](PARAM#NODE_ID)：

|                  名称                  |    类型    |  层级   | 必要性    | 说明         |
|:------------------------------------:|:--------:|:-----:|--------|------------|
|         `inventory_hostname`         |   `ip`   | **-** | **必选** | **节点IP地址** |
|     [`nodename`](PARAM#nodename)     | `string` | **I** | 可选     | **节点名称**   |
| [`node_cluster`](PARAM#node_cluster) | `string` | **C** | 可选     | **节点集群名称** |

[`nodename`](PARAM#nodename) 与 [`node_cluster`](PARAM#node_cluster) 两个参数是可选的，如果不提供，会使用节点现有的主机名，和固定值 `nodes` 作为默认值。
在 Pigsty 的监控系统中，这两者将会被用作节点的 **集群标识** （`cls`） 与 **实例标识**（`ins`） 。

对于 [PGSQL节点](#pgsql节点) 来说，因为Pigsty默认采用PG:节点独占1:1部署，因此可以通过 [`node_id_from_pg`](PARAM#node_id_from_pg) 参数，
将 PostgreSQL 实例的身份参数（ [`pg_cluster`](PARAM#pg_cluster) 与 [`pg_seq`](PARAM#pg_seq)） 借用至节点的`ins`与`cls`标签上，从而让数据库与节点的监控指标拥有相同的标签，便于交叉分析。

```yaml
#nodename:                # [实例] # 节点实例标识，如缺失则使用现有主机名，可选，无默认值
node_cluster: nodes       # [集群] # 节点集群标识，如缺失则使用默认值'nodes'，可选
nodename_overwrite: true          # 用 nodename 覆盖节点的主机名吗？
nodename_exchange: false          # 在剧本主机之间交换 nodename 吗？
node_id_from_pg: true             # 如果可行，是否借用 postgres 身份作为节点身份？
```

您还可以为主机集群配置丰富的功能参数，例如，使用节点集群上的 HAProxy 对外提供负载均衡，暴露服务，或者为集群绑定一个 L2 VIP。  




----------------

## 管理

下面是 Node 模块中常用的管理操作：

- [添加节点](#添加节点)
- [移除节点](#移除节点)
- [创建管理员](#创建管理员)
- [绑定VIP](#绑定VIP)
- [其他常见管理任务](#其他常见管理任务)

更多问题请参考 [FAQ：NODE](FAQ#NODE)

----------------

### 添加节点

要将节点添加到 Pigsty，您需要对该节点具有无密码的 ssh/sudo 访问权限。

您也可以选择一次性添加一个集群，或使用通配符匹配配置清单中要加入 Pigsty 的节点。

```bash
# ./node.yml -l <cls|ip|group>        # 向 Pigsty 中添加节点的实际剧本
# bin/node-add <selector|ip...>       # 向 Pigsty 中添加节点
bin/node-add node-test                # 初始化节点集群 'node-test'
bin/node-add 10.10.10.10              # 初始化节点  '10.10.10.10'
```

----------------

### 移除节点

要从 Pigsty 中移除一个节点，您可以使用以下命令：

```bash
# ./node-rm.yml -l <cls|ip|group>    # 从 pigsty 中移除节点的实际剧本
# bin/node-rm <cls|ip|selector> ...  # 从 pigsty 中移除节点
bin/node-rm node-test                # 移除节点集群 'node-test'
bin/node-rm 10.10.10.10              # 移除节点 '10.10.10.10'
```

您也可以选择一次性移除一个集群，或使用通配符匹配配置清单中要从 Pigsty 移除的节点。

----------------

### 创建管理员

如果当前用户没有对节点的无密码 ssh/sudo 访问权限，您可以使用另一个管理员用户来初始化该节点：

```bash
node.yml -t node_admin -k -K -e ansible_user=<另一个管理员>   # 为另一个管理员输入 ssh/sudo 密码以完成此任务
```

----------------

### 绑定VIP

您可以在节点集群上绑定一个可选的 L2 VIP，使用 [`vip_enabled`](PARAM#vip_enabled) 参数。

```bash
proxy:
  hosts:
    10.10.10.29: { nodename: proxy-1 } # 您可以显式指定初始的 VIP 角色：MASTER / BACKUP
    10.10.10.30: { nodename: proxy-2 } # , vip_role: master }
  vars:
    node_cluster: proxy
    vip_enabled: true
    vip_vrid: 128
    vip_address: 10.10.10.99
    vip_interface: eth1
```

```bash
./node.yml -l proxy -t node_vip     # 首次启用 VIP 
./node.yml -l proxy -t vip_refresh  # 刷新 vip 配置（例如指定 master）
```

----------------

### 其他常见管理任务

```bash
# Play
./node.yml -t node                            # 完成节点主体初始化（haproxy，监控除外）
./node.yml -t haproxy                         # 在节点上设置 haproxy
./node.yml -t monitor                         # 配置节点监控：node_exporter & promtail （以及可选的 keepalived_exporter）
./node.yml -t node_vip                        # 为没启用过 VIP 的集群安装、配置、启用L2 VIP
./node.yml -t vip_config,vip_reload           # 刷新节点L2 VIP配置
./node.yml -t haproxy_config,haproxy_reload   # 刷新节点上的服务定义
./node.yml -t register_prometheus             # 重新将节点注册到 Prometheus 中
./node.yml -t register_nginx                  # 重新将节点 haproxy 管控界面注册到 Nginx 中

# Task
./node.yml -t node-id        # 生成节点身份标识
./node.yml -t node_name      # 设置主机名
./node.yml -t node_hosts     # 配置节点 /etc/hosts 记录
./node.yml -t node_resolv    # 配置节点 DNS 解析器 /etc/resolv.conf
./node.yml -t node_firewall  # 配置防火墙 & selinux
./node.yml -t node_ca        # 配置节点的CA证书
./node.yml -t node_repo      # 配置节点上游软件仓库
./node.yml -t node_pkg       # 在节点上安装 yum 软件包
./node.yml -t node_feature   # 配置 numa、grub、静态网络等特性
./node.yml -t node_kernel    # 配置操作系统内核模块
./node.yml -t node_tune      # 配置 tuned 调优模板
./node.yml -t node_sysctl    # 设置额外的 sysctl 参数
./node.yml -t node_profile   # 配置节点环境变量：/etc/profile.d/node.sh
./node.yml -t node_ulimit    # 配置节点资源限制
./node.yml -t node_data      # 配置节点首要数据目录
./node.yml -t node_admin     # 配置管理员用户和ssh密钥
./node.yml -t node_timezone  # 配置节点时区
./node.yml -t node_ntp       # 配置节点 NTP 服务器/客户端
./node.yml -t node_crontab   # 添加/覆盖 crontab 定时任务
./node.yml -t node_vip       # 为节点集群设置可选的 L2 VIP
```





----------------

## 剧本

Pigsty 提供了两个与 NODE 模块相关的剧本，分别用于纳管与移除节点。

* [`node.yml`](#nodeyml)：纳管节点，并调整节点到期望的状态
* [`node-rm.yml`](#node-rmyml)：从 pigsty 中移除纳管节点

此外， Pigsty 还提供了两个包装命令工具：`node-add` 与 `node-rm`，用于快速调用剧本。


----------------

### `node.yml`

向 Pigsty 添加节点的 [`node.yml`](https://github.com/vonng/pigsty/blob/master/node.yml) 包含以下子任务：

```bash
node-id       ：生成节点身份标识
node_name     ：设置主机名
node_hosts    ：配置 /etc/hosts 记录
node_resolv   ：配置 DNS 解析器 /etc/resolv.conf
node_firewall ：设置防火墙 & selinux
node_ca       ：添加并信任CA证书
node_repo     ：添加上游软件仓库
node_pkg      ：安装 rpm/deb 软件包
node_feature  ：配置 numa、grub、静态网络等特性
node_kernel   ：配置操作系统内核模块
node_tune     ：配置 tuned 调优模板
node_sysctl   ：设置额外的 sysctl 参数
node_profile  ：写入 /etc/profile.d/node.sh
node_ulimit   ：配置资源限制
node_data     ：配置数据目录
node_admin    ：配置管理员用户和ssh密钥
node_timezone ：配置时区
node_ntp      ：配置 NTP 服务器/客户端
node_crontab  ：添加/覆盖 crontab 定时任务
node_vip      ：为节点集群设置可选的 L2 VIP
haproxy       ：在节点上设置 haproxy 以暴露服务
monitor       ：配置节点监控：node_exporter & promtail
```

<details><summary>示例：使用 node.yml 初始化节点集群</summary>

[![asciicast](https://asciinema.org/a/568807.svg)](https://asciinema.org/a/568807)

</details>



----------------

### `node-rm.yml`

从 Pigsty 中移除节点的剧本 [`node-rm.yml`](https://github.com/vonng/pigsty/blob/master/node-rm.yml) 包含了以下子任务：

```bash
register       : 从 prometheus & nginx 中移除节点注册信息
  - prometheus : 移除已注册的 prometheus 监控目标
  - nginx      : 移除用于 haproxy 管理界面的 nginx 代理记录
vip            : 移除节点的 keepalived 与 L2 VIP（如果启用 VIP）
haproxy        : 移除 haproxy 负载均衡器
node_exporter  : 移除节点监控：Node Exporter
vip_exporter   : 移除 keepalived_exporter （如果启用 VIP）
promtail       : 移除 loki 日志代理 promtail
profile        : 移除 /etc/profile.d/node.sh 环境配置文件
```






----------------

## 监控

Pigsty 中的 NODE 模块提供了 6 个内容丰富的监控面板。


[NODE Overview](https://demo.pigsty.cc/d/node-overview)：当前环境中所有主机节点的大盘总览

<details><summary>Node Overview Dashboard</summary>

[![node-overview.jpg](https://repo.pigsty.cc/img/node-overview.jpg)](https://demo.pigsty.cc/d/node-overview.jpg)

</details>



[NODE Cluster](https://demo.pigsty.cc/d/node-cluster)：某一个主机集群的详细监控信息

<details><summary>Node Cluster Dashboard</summary>

[![node-cluster.jpg](https://repo.pigsty.cc/img/node-cluster.jpg)](https://demo.pigsty.cc/d/node-cluster.jpg)

</details>



[Node Instance](https://demo.pigsty.cc/d/node-instance)：某一个主机节点的详细监控信息

<details><summary>Node Instance Dashboard</summary>

![node-instance.jpg](https://repo.pigsty.cc/img/node-instance.jpg)

</details>



[NODE Alert](https://demo.pigsty.cc/d/node-alert)：当前环境中所有主机节点的告警信息

<details><summary>Node Alert Dashboard</summary>

[![node-alert.jpg](https://repo.pigsty.cc/img/node-alert.jpg)](https://demo.pigsty.cc/d/node-alert.jpg)

</details>



[NODE VIP](https://demo.pigsty.cc/d/node-vip)：某一个主机L2 VIP的详细监控信息

<details><summary>Node VIP Dashboard</summary>

[![node-vip.jpg](https://repo.pigsty.cc/img/node-vip.jpg)](https://demo.pigsty.cc/d/node-vip)

</details>



[Node Haproxy](https://demo.pigsty.cc/d/node-haproxy)：某一个 HAProxy 负载均衡器的详细监控

<details><summary>Node Haproxy Dashboard</summary>

[![node-haproxy.jpg](https://repo.pigsty.cc/img/node-haproxy.jpg)](https://demo.pigsty.cc/d/node-haproxy)

</details>



----------------

## 参数

[`NODE`](PARAM#NODE) 模块有11个参数组（Docker/VIP为可选项），共计 66 个相关参数：

- [`NODE_ID`](PARAM#node_id)             : 节点身份参数
- [`NODE_DNS`](PARAM#node_dns)           : 节点域名 & DNS解析
- [`NODE_PACKAGE`](PARAM#node_package)   : 节点仓库源 & 安装软件包
- [`NODE_TUNE`](PARAM#node_tune)         : 节点调优与内核特性开关
- [`NODE_ADMIN`](PARAM#node_admin)       : 管理员用户与SSH凭证管理
- [`NODE_TIME`](PARAM#node_time)         : 时区，NTP服务与定时任务
- [`NODE_VIP`](PARAM#node_vip)           : 可选的主机节点集群L2 VIP
- [`HAPROXY`](PARAM#haproxy)             : 使用HAProxy对外暴露服务
- [`NODE_EXPORTER`](PARAM#node_exporter) : 主机节点监控与注册
- [`PROMTAIL`](PARAM#promtail)           : Promtail日志收集组件
- [`DOCKER`](PARAM#docker)               : Docker容器服务（可选）

<details><summary>完整参数列表</summary>

| 参数                                                         | 参数组                                    |    类型     |  级别   | 说明                                            | 
|------------------------------------------------------------|----------------------------------------|:---------:|:-----:|-----------------------------------------------|
| [`nodename`](PARAM#nodename)                               | [`NODE_ID`](PARAM#node_id)             |  string   |   I   | node 实例标识，如缺失则使用主机名，可选                        |
| [`node_cluster`](PARAM#node_cluster)                       | [`NODE_ID`](PARAM#node_id)             |  string   |   C   | node 集群标识，如缺失则使用默认值'nodes'，可选                 |
| [`nodename_overwrite`](PARAM#nodename_overwrite)           | [`NODE_ID`](PARAM#node_id)             |   bool    |   C   | 用 nodename 覆盖节点的主机名吗？                         |
| [`nodename_exchange`](PARAM#nodename_exchange)             | [`NODE_ID`](PARAM#node_id)             |   bool    |   C   | 在剧本主机之间交换 nodename 吗？                         |
| [`node_id_from_pg`](PARAM#node_id_from_pg)                 | [`NODE_ID`](PARAM#node_id)             |   bool    |   C   | 如果可行，是否借用 postgres 身份作为节点身份？                  |
| [`node_default_etc_hosts`](PARAM#node_default_etc_hosts)   | [`NODE_DNS`](PARAM#node_dns)           | string[]  |   G   | /etc/hosts 中的静态 DNS 记录                        |
| [`node_etc_hosts`](PARAM#node_etc_hosts)                   | [`NODE_DNS`](PARAM#node_dns)           | string[]  |   C   | /etc/hosts 中的额外静态 DNS 记录                      |
| [`node_dns_method`](PARAM#node_dns_method)                 | [`NODE_DNS`](PARAM#node_dns)           |   enum    |   C   | 如何处理现有DNS服务器：add,none,overwrite               |
| [`node_dns_servers`](PARAM#node_dns_servers)               | [`NODE_DNS`](PARAM#node_dns)           | string[]  |   C   | /etc/resolv.conf 中的动态域名服务器列表                  |
| [`node_dns_options`](PARAM#node_dns_options)               | [`NODE_DNS`](PARAM#node_dns)           | string[]  |   C   | /etc/resolv.conf 中的DNS解析选项                    |
| [`node_repo_method`](PARAM#node_repo_method)               | [`NODE_PACKAGE`](PARAM#node_package)   |   enum    |  C/A  | 如何设置节点仓库：none,local,public,both               |
| [`node_repo_remove`](PARAM#node_repo_remove)               | [`NODE_PACKAGE`](PARAM#node_package)   |   bool    |  C/A  | 配置节点软件仓库时，删除节点上现有的仓库吗？                        |
| [`node_repo_local_urls`](PARAM#node_repo_local_urls)       | [`NODE_PACKAGE`](PARAM#node_package)   | string[]  |   C   | 如果 node_repo_method = local,both，使用的本地仓库URL列表 |
| [`node_packages`](PARAM#node_packages)                     | [`NODE_PACKAGE`](PARAM#node_package)   | string[]  |   C   | 要在当前节点上安装的软件包列表                               |
| [`node_default_packages`](PARAM#node_default_packages)     | [`NODE_PACKAGE`](PARAM#node_package)   | string[]  |   G   | 默认在所有节点上安装的软件包列表                              |
| [`node_disable_firewall`](PARAM#node_disable_firewall)     | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | 禁用节点防火墙？默认为 `true`                            |
| [`node_disable_selinux`](PARAM#node_disable_selinux)       | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | 禁用节点 selinux？默认为  `true`                      |
| [`node_disable_numa`](PARAM#node_disable_numa)             | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | 禁用节点 numa，禁用需要重启                              |
| [`node_disable_swap`](PARAM#node_disable_swap)             | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | 禁用节点 Swap，谨慎使用                                |
| [`node_static_network`](PARAM#node_static_network)         | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | 重启后保留 DNS 解析器设置，即静态网络，默认启用                    |
| [`node_disk_prefetch`](PARAM#node_disk_prefetch)           | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | 在 HDD 上配置磁盘预取以提高性能                            |
| [`node_kernel_modules`](PARAM#node_kernel_modules)         | [`NODE_TUNE`](PARAM#node_tune)         | string[]  |   C   | 在此节点上启用的内核模块列表                                |
| [`node_hugepage_count`](PARAM#node_hugepage_count)         | [`NODE_TUNE`](PARAM#node_tune)         |    int    |   C   | 主机节点分配的 2MB 大页数量，优先级比比例更高                     |
| [`node_hugepage_ratio`](PARAM#node_hugepage_ratio)         | [`NODE_TUNE`](PARAM#node_tune)         |   float   |   C   | 主机节点分配的内存大页占总内存比例，0 默认禁用                      |
| [`node_overcommit_ratio`](PARAM#node_overcommit_ratio)     | [`NODE_TUNE`](PARAM#node_tune)         |    int    |   C   | 节点内存允许的 OverCommit 超额比率 (50-100)，0 默认禁用       |
| [`node_tune`](PARAM#node_tune)                             | [`NODE_TUNE`](PARAM#node_tune)         |   enum    |   C   | 节点调优配置文件：无，oltp,olap,crit,tiny                |
| [`node_sysctl_params`](PARAM#node_sysctl_params)           | [`NODE_TUNE`](PARAM#node_tune)         |   dict    |   C   | 额外的 sysctl 配置参数，k:v 格式                        |
| [`node_data`](PARAM#node_data)                             | [`NODE_ADMIN`](PARAM#node_admin)       |   path    |   C   | 节点主数据目录，默认为 `/data``                          |
| [`node_admin_enabled`](PARAM#node_admin_enabled)           | [`NODE_ADMIN`](PARAM#node_admin)       |   bool    |   C   | 在目标节点上创建管理员用户吗？                               |
| [`node_admin_uid`](PARAM#node_admin_uid)                   | [`NODE_ADMIN`](PARAM#node_admin)       |    int    |   C   | 节点管理员用户的 uid 和 gid                            |
| [`node_admin_username`](PARAM#node_admin_username)         | [`NODE_ADMIN`](PARAM#node_admin)       | username  |   C   | 节点管理员用户的名称，默认为 `dba``                         |
| [`node_admin_ssh_exchange`](PARAM#node_admin_ssh_exchange) | [`NODE_ADMIN`](PARAM#node_admin)       |   bool    |   C   | 是否在节点集群之间交换管理员 ssh 密钥                         |
| [`node_admin_pk_current`](PARAM#node_admin_pk_current)     | [`NODE_ADMIN`](PARAM#node_admin)       |   bool    |   C   | 将当前用户的 ssh 公钥添加到管理员的 authorized_keys 中吗？      |
| [`node_admin_pk_list`](PARAM#node_admin_pk_list)           | [`NODE_ADMIN`](PARAM#node_admin)       | string[]  |   C   | 要添加到管理员用户的 ssh 公钥                             |
| [`node_timezone`](PARAM#node_timezone)                     | [`NODE_TIME`](PARAM#node_time)         |  string   |   C   | 设置主机节点时区，空字符串跳过                               |
| [`node_ntp_enabled`](PARAM#node_ntp_enabled)               | [`NODE_TIME`](PARAM#node_time)         |   bool    |   C   | 启用 chronyd 时间同步服务吗？                           |
| [`node_ntp_servers`](PARAM#node_ntp_servers)               | [`NODE_TIME`](PARAM#node_time)         | string[]  |   C   | /etc/chrony.conf 中的 ntp 服务器列表                 |
| [`node_crontab_overwrite`](PARAM#node_crontab_overwrite)   | [`NODE_TIME`](PARAM#node_time)         |   bool    |   C   | 写入 /etc/crontab 时，追加写入还是全部覆盖？                 |
| [`node_crontab`](PARAM#node_crontab)                       | [`NODE_TIME`](PARAM#node_time)         | string[]  |   C   | 在 /etc/crontab 中的 crontab 条目                  |
| [`vip_enabled`](PARAM#vip_enabled)                         | [`NODE_VIP`](PARAM#node_vip)           |   bool    |   C   | 在此节点集群上启用 L2 vip 吗？                           |
| [`vip_address`](PARAM#vip_address)                         | [`NODE_VIP`](PARAM#node_vip)           |    ip     |   C   | 节点 vip 地址的 ipv4 格式，启用 vip 时为必要参数              |
| [`vip_vrid`](PARAM#vip_vrid)                               | [`NODE_VIP`](PARAM#node_vip)           |    int    |   C   | 所需的整数，1-254，在同一 VLAN 中应唯一                     |
| [`vip_role`](PARAM#vip_role)                               | [`NODE_VIP`](PARAM#node_vip)           |   enum    |   I   | 可选，master/backup，默认为 backup，用作初始角色            |
| [`vip_preempt`](PARAM#vip_preempt)                         | [`NODE_VIP`](PARAM#node_vip)           |   bool    |  C/I  | 可选，true/false，默认为 false，启用 vip 抢占             |
| [`vip_interface`](PARAM#vip_interface)                     | [`NODE_VIP`](PARAM#node_vip)           |  string   |  C/I  | 节点 vip 网络接口监听，默认为 eth0                        |
| [`vip_dns_suffix`](PARAM#vip_dns_suffix)                   | [`NODE_VIP`](PARAM#node_vip)           |  string   |   C   | 节点 vip DNS 名称后缀，默认为空字符串                       |
| [`vip_exporter_port`](PARAM#vip_exporter_port)             | [`NODE_VIP`](PARAM#node_vip)           |   port    |   C   | keepalived exporter 监听端口，默认为 9650             |
| [`haproxy_enabled`](PARAM#haproxy_enabled)                 | [`HAPROXY`](PARAM#haproxy)             |   bool    |   C   | 在此节点上启用 haproxy 吗？                            |
| [`haproxy_clean`](PARAM#haproxy_clean)                     | [`HAPROXY`](PARAM#haproxy)             |   bool    | G/C/A | 清除所有现有的 haproxy 配置吗？                          |
| [`haproxy_reload`](PARAM#haproxy_reload)                   | [`HAPROXY`](PARAM#haproxy)             |   bool    |   A   | 配置后重新加载 haproxy 吗？                            |
| [`haproxy_auth_enabled`](PARAM#haproxy_auth_enabled)       | [`HAPROXY`](PARAM#haproxy)             |   bool    |   G   | 启用 haproxy 管理页面的身份验证？                         |
| [`haproxy_admin_username`](PARAM#haproxy_admin_username)   | [`HAPROXY`](PARAM#haproxy)             | username  |   G   | haproxy 管理用户名，默认为 `admin``                    |
| [`haproxy_admin_password`](PARAM#haproxy_admin_password)   | [`HAPROXY`](PARAM#haproxy)             | password  |   G   | haproxy 管理密码，默认为 `pigsty``                    |
| [`haproxy_exporter_port`](PARAM#haproxy_exporter_port)     | [`HAPROXY`](PARAM#haproxy)             |   port    |   C   | haproxy exporter 的端口，默认为 9101                 |
| [`haproxy_client_timeout`](PARAM#haproxy_client_timeout)   | [`HAPROXY`](PARAM#haproxy)             | interval  |   C   | haproxy 客户端连接超时，默认为 24h                       |
| [`haproxy_server_timeout`](PARAM#haproxy_server_timeout)   | [`HAPROXY`](PARAM#haproxy)             | interval  |   C   | haproxy 服务器端连接超时，默认为 24h                      |
| [`haproxy_services`](PARAM#haproxy_services)               | [`HAPROXY`](PARAM#haproxy)             | service[] |   C   | 要在节点上对外暴露的 haproxy 服务列表                       |
| [`node_exporter_enabled`](PARAM#node_exporter_enabled)     | [`NODE_EXPORTER`](PARAM#node_exporter) |   bool    |   C   | 在此节点上配置 node_exporter 吗？                      |
| [`node_exporter_port`](PARAM#node_exporter_port)           | [`NODE_EXPORTER`](PARAM#node_exporter) |   port    |   C   | node exporter 监听端口，默认为 9100                   |
| [`node_exporter_options`](PARAM#node_exporter_options)     | [`NODE_EXPORTER`](PARAM#node_exporter) |    arg    |   C   | node_exporter 的额外服务器选项                        |
| [`promtail_enabled`](PARAM#promtail_enabled)               | [`PROMTAIL`](PARAM#promtail)           |   bool    |   C   | 启用 promtail 日志收集器吗？                           |
| [`promtail_clean`](PARAM#promtail_clean)                   | [`PROMTAIL`](PARAM#promtail)           |   bool    |  G/A  | 初始化期间清除现有的 promtail 状态文件吗？                    |
| [`promtail_port`](PARAM#promtail_port)                     | [`PROMTAIL`](PARAM#promtail)           |   port    |   C   | promtail 监听端口，默认为 9080                        |
| [`promtail_positions`](PARAM#promtail_positions)           | [`PROMTAIL`](PARAM#promtail)           |   path    |   C   | promtail 位置状态文件路径                             |

</details>