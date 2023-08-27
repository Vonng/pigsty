# NODE

> 纳管节点，将其调整至所需状态，并进行监控。


----------------

## 概念

节点是硬件资源的抽象，它可以是裸机、虚拟机、容器或者是 k8s pods：只要装着操作系统，可以使用 CPU/内存/磁盘/网络 资源就行。

在 Pigsty 中存在不同类型的节点：

- 普通节点，被 Pigsty 所管理的节点
- 管理节点，使用 Ansible 发出管理指令的节点
- 基础设施节点，安装 [`INFRA`](INFRA) 模块的节点
- PGSQL 节点，安装 [`PGSQL`](PGSQL) 模块的节点
- 安装了其他模块的节点…… 


----------------

**通用节点**

你可以使用 Pigsty 管理节点，并在其上安装模块。`node.yml` 剧本将调整节点至所需状态。

以下服务默认会被添加到所有节点：

|      组件       |  端口  | 描述           |
|:-------------:|:----:|--------------|
| Node Exporter | 9100 | 节点监控指标导出器    |
| HAProxy Admin | 9101 | HAProxy 管理页面 |
|   Promtail    | 9080 | 日志收集代理       |

此外，您可以为节点选装 Docker 与 Keepalived，这两个组件默认不启用。

|         组件          |  端口  | 描述                 |
|:-------------------:|:----:|--------------------|
|    Docker Daemon    | 9323 | 启用容器支持             |
|     Keepliaved      |  -   | 负责管理主机集群 L2 VIP    |
| Keepliaved Exporter | 9650 | 负责监控 Keepalived 状态 |



----------------

**管理节点**

在一套 pigsty 部署中会有且只有一个管理节点，由 [`admin_ip`](PARAM#admin_ip) 指定。
在单机安装的[配置](INSTALL#configure)过程中，它会被被设置为该机器的首要IP地址。

该节点将具有对所有其他节点的 ssh/sudo 访问权限：管理节点的安全至关重要，请确保它的访问受到严格控制。

通常管理节点与基础设施节点（infra节点）重合。如果有多个基础设施节点，管理节点通常是所有 infra 节点中的第一个，其他的作为管理节点的备份。


----------------

**INFRA 节点**

一套 Pigsty 部署可能有一个或多个 infra 节点，在大型生产环境中可能会有 2 ~ 3 个。

配置清单中的 `infra` 分组列出并指定了哪些节点是 infra 节点，这些节点会安装 [INFRA](INFRA) 模块（DNS、Nginx、Prometheus、Grafana 等...）。

管理节点也是默认的并且是第一个 infra 节点，infra 节点可以被用作"备用"的管理节点。


----------------

**PGSQL 节点**

安装了 [PGSQL](PGSQL) 模块的节点被称为 PGSQL 节点。节点和 PostgreSQL 实例是1:1部署的。
在这种情况下，节点默认可以从相应的 pg 实例借用身份：[`node_id_from_pg`](PARAM#node_id_from_pg)。

|         组件          |  端口  | 描述                                |
|:-------------------:|:----:|-----------------------------------|
|      Postgres       | 5432 | Pigsty CMDB                       |
|      Pgbouncer      | 6432 | Pgbouncer 连接池服务                   |
|       Patroni       | 8008 | Patroni 高可用组件                     |
|   Haproxy Primary   | 5433 | 主连接池：读/写服务                        |
|   Haproxy Replica   | 5434 | 副本连接池：只读服务                        |
|   Haproxy Default   | 5436 | 主直连服务                             |
|   Haproxy Offline   | 5438 | 离线直连：离线读服务                        |
|  Haproxy `service`  | 543x | PostgreSQL 定制服务                   |
|    Haproxy Admin    | 9101 | 监控指标和流量管理                         |
|     PG Exporter     | 9630 | PG 监控指标导出器                        |
| PGBouncer Exporter  | 9631 | PGBouncer 监控指标导出器                 |
|    Node Exporter    | 9100 | 节点监控指标导出器                         |
|      Promtail       | 9080 | 收集 Postgres、Pgbouncer、Patroni 的日志 |
|     vip-manager     |  -   | 将 VIP 绑定到主节点                      |
|     keepalived      |  -   | 为整个集群绑定 L2 VIP（默认不启用）             |
| Keepalived Exporter | 9650 | Keepalived 指标导出器（默认不启用）           |
|    Docker Daemon    | 9323 | Docker 守护进程（默认不启用）                |



----------------

## 管理


**添加节点**

要将节点添加到 Pigsty，您需要对该节点具有无密码的 ssh/sudo 访问权限。

```bash
bin/node-add [ip...]      # 将节点添加到 pigsty: ./node.yml -l <cls|ip|group>
```

----------------

**移除节点**

要从 Pigsty 中移除一个节点，您可以使用以下命令：

```bash
bin/node-rm [ip...]       # 从 pigsty 中移除节点: ./node-rm.yml -l <cls|ip|group>
```

----------------

**创建管理员**

如果当前用户没有对节点的无密码 ssh/sudo 访问权限，您可以使用另一个管理员用户来初始化该节点：

```bash
node.yml -t node_admin -k -K -e ansible_user=<另一个管理员>   # 为另一个管理员输入 ssh/sudo 密码以完成此任务
```

----------------

**绑定 VIP**

您可以在节点集群上绑定一个可选的 L2 VIP，使用 [`vip_enabled`](https://chat.openai.com/PARAM#vip_enabled) 参数。

```bash
proxy:
  hosts:
    10.10.10.29: { nodename: proxy-1 } 
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

## 剧本

Pigsty 提供了两个与 NODE 模块相关的剧本，分别用于纳管与移除节点。

* [`node.yml`](https://github.com/vonng/pigsty/blob/master/node.yml)：纳管节点，并调整节点到期望的状态
* [`node-rm.yml`](https://github.com/vonng/pigsty/blob/master/node-rm.yml)：从 pigsty 中移除纳管节点

[![asciicast](https://asciinema.org/a/568807.svg)](https://asciinema.org/a/568807)



----------------

## 监控

Pigsty 中的 NODE 模块提供了 6 个内容丰富的监控面板。


[NODE Overview](https://demo.pigsty.cc/d/node-overview)：当前环境中所有主机节点的大盘总览

<details><summary>Node Overview Dashboard</summary>

[![node-overview](https://github.com/Vonng/pigsty/assets/8587410/e41b6025-bce4-4442-bc28-f3caa49cf64f)](https://demo.pigsty.cc/d/node-overview)

</details>



[NODE Cluster](https://demo.pigsty.cc/d/node-cluster)：某一个主机集群的详细监控信息

<details><summary>Node Cluster Dashboard</summary>

[![node-cluster](https://github.com/Vonng/pigsty/assets/8587410/aa8cd43d-6c8a-47cb-b556-8da5ebb68c66)](https://demo.pigsty.cc/d/node-cluster)

</details>



[Node Instance](https://demo.pigsty.cc/d/node-instance)：某一个主机节点的详细监控信息

<details><summary>Node Instance Dashboard</summary>

[![node-instance](https://github.com/Vonng/pigsty/assets/8587410/90c0ba35-93f0-4dde-92fa-eb188adf9eb2)](https://demo.pigsty.cc/d/node-instance)

</details>



[NODE Alert](https://demo.pigsty.cc/d/node-alert)：当前环境中所有主机节点的告警信息

<details><summary>Node Alert Dashboard</summary>

[![node-alert](https://github.com/Vonng/pigsty/assets/8587410/63605aa8-909f-44b8-b7c7-e6caea1d1ed0)](https://demo.pigsty.cc/d/node-alert)

</details>



[NODE VIP](https://demo.pigsty.cc/d/node-vip)：某一个主机L2 VIP的详细监控信息

<details><summary>Node VIP Dashboard</summary>

[![node-vip](https://github.com/Vonng/pigsty/assets/8587410/9cc0ed01-49f0-4321-814f-98d1e3b0a74f)](https://demo.pigsty.cc/d/node-vip)

</details>



[Node Haproxy](https://demo.pigsty.cc/d/node-haproxy)：某一个 HAProxy 负载均衡器的详细监控

<details><summary>Node Haproxy Dashboard</summary>

[![node-haproxy](https://github.com/Vonng/pigsty/assets/8587410/75267451-06cc-4d8a-ab30-aa347a1cad0e)](https://demo.pigsty.cc/d/node-haproxy)

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

| 参数                                                         | 参数组                                    |    类型     |  级别   | 说明                                                              | 中文说明                                          |
|------------------------------------------------------------|----------------------------------------|:---------:|:-----:|-----------------------------------------------------------------|-----------------------------------------------|
| [`nodename`](PARAM#nodename)                               | [`NODE_ID`](PARAM#node_id)             |  string   |   I   | node instance identity, use hostname if missing, optional       | node 实例标识，如缺失则使用主机名，可选                        |
| [`node_cluster`](PARAM#node_cluster)                       | [`NODE_ID`](PARAM#node_id)             |  string   |   C   | node cluster identity, use 'nodes' if missing, optional         | node 集群标识，如缺失则使用默认值'nodes'，可选                 |
| [`nodename_overwrite`](PARAM#nodename_overwrite)           | [`NODE_ID`](PARAM#node_id)             |   bool    |   C   | overwrite node's hostname with nodename?                        | 用 nodename 覆盖节点的主机名吗？                         |
| [`nodename_exchange`](PARAM#nodename_exchange)             | [`NODE_ID`](PARAM#node_id)             |   bool    |   C   | exchange nodename among play hosts?                             | 在剧本主机之间交换 nodename 吗？                         |
| [`node_id_from_pg`](PARAM#node_id_from_pg)                 | [`NODE_ID`](PARAM#node_id)             |   bool    |   C   | use postgres identity as node identity if applicable?           | 如果可行，是否借用 postgres 身份作为节点身份？                  |
| [`node_default_etc_hosts`](PARAM#node_default_etc_hosts)   | [`NODE_DNS`](PARAM#node_dns)           | string[]  |   G   | static dns records in `/etc/hosts`                              | /etc/hosts 中的静态 DNS 记录                        |
| [`node_etc_hosts`](PARAM#node_etc_hosts)                   | [`NODE_DNS`](PARAM#node_dns)           | string[]  |   C   | extra static dns records in `/etc/hosts`                        | /etc/hosts 中的额外静态 DNS 记录                      |
| [`node_dns_method`](PARAM#node_dns_method)                 | [`NODE_DNS`](PARAM#node_dns)           |   enum    |   C   | how to handle dns servers: add,none,overwrite                   | 如何处理现有DNS服务器：add,none,overwrite               |
| [`node_dns_servers`](PARAM#node_dns_servers)               | [`NODE_DNS`](PARAM#node_dns)           | string[]  |   C   | dynamic nameserver in `/etc/resolv.conf`                        | /etc/resolv.conf 中的动态域名服务器列表                  |
| [`node_dns_options`](PARAM#node_dns_options)               | [`NODE_DNS`](PARAM#node_dns)           | string[]  |   C   | dns resolv options in `/etc/resolv.conf`                        | /etc/resolv.conf 中的DNS解析选项                    |
| [`node_repo_method`](PARAM#node_repo_method)               | [`NODE_PACKAGE`](PARAM#node_package)   |   enum    |  C/A  | how to setup node repo: none,local,public,both                  | 如何设置节点仓库：none,local,public,both               |
| [`node_repo_remove`](PARAM#node_repo_remove)               | [`NODE_PACKAGE`](PARAM#node_package)   |   bool    |  C/A  | remove existing repo on node?                                   | 配置节点软件仓库时，删除节点上现有的仓库吗？                        |
| [`node_repo_local_urls`](PARAM#node_repo_local_urls)       | [`NODE_PACKAGE`](PARAM#node_package)   | string[]  |   C   | local repo url, if node_repo_method = local,both                | 如果 node_repo_method = local,both，使用的本地仓库URL列表 |
| [`node_packages`](PARAM#node_packages)                     | [`NODE_PACKAGE`](PARAM#node_package)   | string[]  |   C   | packages to be installed current nodes                          | 要在当前节点上安装的软件包列表                               |
| [`node_default_packages`](PARAM#node_default_packages)     | [`NODE_PACKAGE`](PARAM#node_package)   | string[]  |   G   | default packages to be installed on all nodes                   | 默认在所有节点上安装的软件包列表                              |
| [`node_disable_firewall`](PARAM#node_disable_firewall)     | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | disable node firewall? true by default                          | 禁用节点防火墙？默认为 `true`                            |
| [`node_disable_selinux`](PARAM#node_disable_selinux)       | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | disable node selinux? true by default                           | 禁用节点 selinux？默认为  `true`                      |
| [`node_disable_numa`](PARAM#node_disable_numa)             | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | disable node numa, reboot required                              | 禁用节点 numa，禁用需要重启                              |
| [`node_disable_swap`](PARAM#node_disable_swap)             | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | disable node swap, use with caution                             | 禁用节点 Swap，谨慎使用                                |
| [`node_static_network`](PARAM#node_static_network)         | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | preserve dns resolver settings after reboot                     | 重启后保留 DNS 解析器设置，即静态网络，默认启用                    |
| [`node_disk_prefetch`](PARAM#node_disk_prefetch)           | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | setup disk prefetch on HDD to increase performance              | 在 HDD 上配置磁盘预取以提高性能                            |
| [`node_kernel_modules`](PARAM#node_kernel_modules)         | [`NODE_TUNE`](PARAM#node_tune)         | string[]  |   C   | kernel modules to be enabled on this node                       | 在此节点上启用的内核模块列表                                |
| [`node_hugepage_count`](PARAM#node_hugepage_count)         | [`NODE_TUNE`](PARAM#node_tune)         |    int    |   C   | number of 2MB hugepage, take precedence over ratio              | 主机节点分配的 2MB 大页数量，优先级比比例更高                     |
| [`node_hugepage_ratio`](PARAM#node_hugepage_ratio)         | [`NODE_TUNE`](PARAM#node_tune)         |   float   |   C   | node mem hugepage ratio, 0 disable it by default                | 主机节点分配的内存大页占总内存比例，0 默认禁用                      |
| [`node_overcommit_ratio`](PARAM#node_overcommit_ratio)     | [`NODE_TUNE`](PARAM#node_tune)         |    int    |   C   | node mem overcommit ratio (50-100), 0 disable it by default     | 节点内存允许的 OverCommit 超额比率 (50-100)，0 默认禁用       |
| [`node_tune`](PARAM#node_tune)                             | [`NODE_TUNE`](PARAM#node_tune)         |   enum    |   C   | node tuned profile: none,oltp,olap,crit,tiny                    | 节点调优配置文件：无，oltp,olap,crit,tiny                |
| [`node_sysctl_params`](PARAM#node_sysctl_params)           | [`NODE_TUNE`](PARAM#node_tune)         |   dict    |   C   | sysctl parameters in k:v format in addition to tuned            | 额外的 sysctl 配置参数，k:v 格式                        |
| [`node_data`](PARAM#node_data)                             | [`NODE_ADMIN`](PARAM#node_admin)       |   path    |   C   | node main data directory, `/data` by default                    | 节点主数据目录，默认为 `/data``                          |
| [`node_admin_enabled`](PARAM#node_admin_enabled)           | [`NODE_ADMIN`](PARAM#node_admin)       |   bool    |   C   | create a admin user on target node?                             | 在目标节点上创建管理员用户吗？                               |
| [`node_admin_uid`](PARAM#node_admin_uid)                   | [`NODE_ADMIN`](PARAM#node_admin)       |    int    |   C   | uid and gid for node admin user                                 | 节点管理员用户的 uid 和 gid                            |
| [`node_admin_username`](PARAM#node_admin_username)         | [`NODE_ADMIN`](PARAM#node_admin)       | username  |   C   | name of node admin user, `dba` by default                       | 节点管理员用户的名称，默认为 `dba``                         |
| [`node_admin_ssh_exchange`](PARAM#node_admin_ssh_exchange) | [`NODE_ADMIN`](PARAM#node_admin)       |   bool    |   C   | exchange admin ssh key among node cluster                       | 是否在节点集群之间交换管理员 ssh 密钥                         |
| [`node_admin_pk_current`](PARAM#node_admin_pk_current)     | [`NODE_ADMIN`](PARAM#node_admin)       |   bool    |   C   | add current user's ssh pk to admin authorized_keys              | 将当前用户的 ssh 公钥添加到管理员的 authorized_keys 中吗？      |
| [`node_admin_pk_list`](PARAM#node_admin_pk_list)           | [`NODE_ADMIN`](PARAM#node_admin)       | string[]  |   C   | ssh public keys to be added to admin user                       | 要添加到管理员用户的 ssh 公钥                             |
| [`node_timezone`](PARAM#node_timezone)                     | [`NODE_TIME`](PARAM#node_time)         |  string   |   C   | setup node timezone, empty string to skip                       | 设置主机节点时区，空字符串跳过                               |
| [`node_ntp_enabled`](PARAM#node_ntp_enabled)               | [`NODE_TIME`](PARAM#node_time)         |   bool    |   C   | enable chronyd time sync service?                               | 启用 chronyd 时间同步服务吗？                           |
| [`node_ntp_servers`](PARAM#node_ntp_servers)               | [`NODE_TIME`](PARAM#node_time)         | string[]  |   C   | ntp servers in `/etc/chrony.conf`                               | /etc/chrony.conf 中的 ntp 服务器列表                 |
| [`node_crontab_overwrite`](PARAM#node_crontab_overwrite)   | [`NODE_TIME`](PARAM#node_time)         |   bool    |   C   | overwrite or append to `/etc/crontab`?                          | 写入 /etc/crontab 时，追加写入还是全部覆盖？                 |
| [`node_crontab`](PARAM#node_crontab)                       | [`NODE_TIME`](PARAM#node_time)         | string[]  |   C   | crontab entries in `/etc/crontab`                               | 在 /etc/crontab 中的 crontab 条目                  |
| [`vip_enabled`](PARAM#vip_enabled)                         | [`NODE_VIP`](PARAM#node_vip)           |   bool    |   C   | enable vip on this node cluster?                                | 在此节点集群上启用 L2 vip 吗？                           |
| [`vip_address`](PARAM#vip_address)                         | [`NODE_VIP`](PARAM#node_vip)           |    ip     |   C   | node vip address in ipv4 format, required if vip is enabled     | 节点 vip 地址的 ipv4 格式，启用 vip 时为必要参数              |
| [`vip_vrid`](PARAM#vip_vrid)                               | [`NODE_VIP`](PARAM#node_vip)           |    int    |   C   | required, integer, 1-254, should be unique among same VLAN      | 所需的整数，1-254，在同一 VLAN 中应唯一                     |
| [`vip_role`](PARAM#vip_role)                               | [`NODE_VIP`](PARAM#node_vip)           |   enum    |   I   | optional, `master/backup`, backup by default, use as init role  | 可选，master/backup，默认为 backup，用作初始角色            |
| [`vip_preempt`](PARAM#vip_preempt)                         | [`NODE_VIP`](PARAM#node_vip)           |   bool    |  C/I  | optional, `true/false`, false by default, enable vip preemption | 可选，true/false，默认为 false，启用 vip 抢占             |
| [`vip_interface`](PARAM#vip_interface)                     | [`NODE_VIP`](PARAM#node_vip)           |  string   |  C/I  | node vip network interface to listen, `eth0` by default         | 节点 vip 网络接口监听，默认为 eth0                        |
| [`vip_dns_suffix`](PARAM#vip_dns_suffix)                   | [`NODE_VIP`](PARAM#node_vip)           |  string   |   C   | node vip dns name suffix, `.vip` by default                     | 节点 vip DNS 名称后缀，默认为 .vip                      |
| [`vip_exporter_port`](PARAM#vip_exporter_port)             | [`NODE_VIP`](PARAM#node_vip)           |   port    |   C   | keepalived exporter listen port, 9650 by default                | keepalived exporter 监听端口，默认为 9650             |
| [`haproxy_enabled`](PARAM#haproxy_enabled)                 | [`HAPROXY`](PARAM#haproxy)             |   bool    |   C   | enable haproxy on this node?                                    | 在此节点上启用 haproxy 吗？                            |
| [`haproxy_clean`](PARAM#haproxy_clean)                     | [`HAPROXY`](PARAM#haproxy)             |   bool    | G/C/A | cleanup all existing haproxy config?                            | 清除所有现有的 haproxy 配置吗？                          |
| [`haproxy_reload`](PARAM#haproxy_reload)                   | [`HAPROXY`](PARAM#haproxy)             |   bool    |   A   | reload haproxy after config?                                    | 配置后重新加载 haproxy 吗？                            |
| [`haproxy_auth_enabled`](PARAM#haproxy_auth_enabled)       | [`HAPROXY`](PARAM#haproxy)             |   bool    |   G   | enable authentication for haproxy admin page                    | 启用 haproxy 管理页面的身份验证？                         |
| [`haproxy_admin_username`](PARAM#haproxy_admin_username)   | [`HAPROXY`](PARAM#haproxy)             | username  |   G   | haproxy admin username, `admin` by default                      | haproxy 管理用户名，默认为 `admin``                    |
| [`haproxy_admin_password`](PARAM#haproxy_admin_password)   | [`HAPROXY`](PARAM#haproxy)             | password  |   G   | haproxy admin password, `pigsty` by default                     | haproxy 管理密码，默认为 `pigsty``                    |
| [`haproxy_exporter_port`](PARAM#haproxy_exporter_port)     | [`HAPROXY`](PARAM#haproxy)             |   port    |   C   | haproxy admin/exporter port, 9101 by default                    | haproxy exporter 的端口，默认为 9101                 |
| [`haproxy_client_timeout`](PARAM#haproxy_client_timeout)   | [`HAPROXY`](PARAM#haproxy)             | interval  |   C   | client side connection timeout, 24h by default                  | haproxy 客户端连接超时，默认为 24h                       |
| [`haproxy_server_timeout`](PARAM#haproxy_server_timeout)   | [`HAPROXY`](PARAM#haproxy)             | interval  |   C   | server side connection timeout, 24h by default                  | haproxy 服务器端连接超时，默认为 24h                      |
| [`haproxy_services`](PARAM#haproxy_services)               | [`HAPROXY`](PARAM#haproxy)             | service[] |   C   | list of haproxy service to be exposed on node                   | 要在节点上对外暴露的 haproxy 服务列表                       |
| [`node_exporter_enabled`](PARAM#node_exporter_enabled)     | [`NODE_EXPORTER`](PARAM#node_exporter) |   bool    |   C   | setup node_exporter on this node?                               | 在此节点上配置 node_exporter 吗？                      |
| [`node_exporter_port`](PARAM#node_exporter_port)           | [`NODE_EXPORTER`](PARAM#node_exporter) |   port    |   C   | node exporter listen port, 9100 by default                      | node exporter 监听端口，默认为 9100                   |
| [`node_exporter_options`](PARAM#node_exporter_options)     | [`NODE_EXPORTER`](PARAM#node_exporter) |    arg    |   C   | extra server options for node_exporter                          | node_exporter 的额外服务器选项                        |
| [`promtail_enabled`](PARAM#promtail_enabled)               | [`PROMTAIL`](PARAM#promtail)           |   bool    |   C   | enable promtail logging collector?                              | 启用 promtail 日志收集器吗？                           |
| [`promtail_clean`](PARAM#promtail_clean)                   | [`PROMTAIL`](PARAM#promtail)           |   bool    |  G/A  | purge existing promtail status file during init?                | 初始化期间清除现有的 promtail 状态文件吗？                    |
| [`promtail_port`](PARAM#promtail_port)                     | [`PROMTAIL`](PARAM#promtail)           |   port    |   C   | promtail listen port, 9080 by default                           | promtail 监听端口，默认为 9080                        |
| [`promtail_positions`](PARAM#promtail_positions)           | [`PROMTAIL`](PARAM#promtail)           |   path    |   C   | promtail position status file path                              | promtail 位置状态文件路径                             |

</details>