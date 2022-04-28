# 配置：Nodes

Pigsty提供了完整的主机置备与监控功能，执行 [`nodes.yml`](p-nodes.md) 剧本即可将对应节点配置为对应状态，并纳入Pigsty监控系统。

- [`NODE_IDENTITY`](#NODE_IDENTITY) : 节点身份参数
- [`NODE_DNS`](#NODE_DNS) : 节点域名解析，配置[静态DNS记录](#node_dns_hosts)与[动态解析](#node_dns_server)
- [`NODE_REPO`](#NODE_REPO) : 节点软件源
- [`NODE_PACKAGES`](#NODE_PACKAGES) : 节点软件包
- [`NODE_FEATURES`](#NODE_FEATURES) : 节点功能特性
- [`NODE_MODULES`](#NODE_MODULES) : 节点内核模块
- [`NODE_TUNE`](#NODE_TUNE) : 节点参数调优
- [`NODE_ADMIN`](#NODE_ADMIN) : 节点管理员
- [`NODE_TIME`](#NODE_TIME) : 节点时区与时间同步
- [`NODE_EXPORTER`](#NODE_EXPORTER) : 节点指标暴露器
- [`PROMTAIL`](#PROMTAIL) : 日志收集组件


| ID |                         Name                          |              Section              |   Type   | Level |               Comment                |
|--|-------------------------------------------------------|-----------------------------------|----------|-------|--------------------------------------|
| 300 | [`meta_node`](#meta_node)                             | [`NODE_IDENTITY`](#NODE_IDENTITY) | bool     | C     | 表示此节点为元节点                   |
| 301 | [`nodename`](#nodename)                               | [`NODE_IDENTITY`](#NODE_IDENTITY) | string   | I     | 指定节点实例标识                     |
| 302 | [`node_cluster`](#node_cluster)                       | [`NODE_IDENTITY`](#NODE_IDENTITY) | string   | C     | 节点集群名，默认名为nodes            |
| 303 | [`nodename_overwrite`](#nodename_overwrite)           | [`NODE_IDENTITY`](#NODE_IDENTITY) | bool     | C     | 用Nodename覆盖机器HOSTNAME           |
| 304 | [`nodename_exchange`](#nodename_exchange)             | [`NODE_IDENTITY`](#NODE_IDENTITY) | bool     | C     | 是否在剧本节点间交换主机名           |
| 310 | [`node_dns_hosts`](#node_dns_hosts)                   | [`NODE_DNS`](#NODE_DNS)           | string[] | C     | 写入机器的静态DNS解析                |
| 311 | [`node_dns_hosts_extra`](#node_dns_hosts_extra)       | [`NODE_DNS`](#NODE_DNS)           | string[] | C/I   | 同上，用于集群实例层级               |
| 312 | [`node_dns_server`](#node_dns_server)                 | [`NODE_DNS`](#NODE_DNS)           | enum     | C     | 如何配置DNS服务器？                  |
| 313 | [`node_dns_servers`](#node_dns_servers)               | [`NODE_DNS`](#NODE_DNS)           | string[] | C     | 配置动态DNS服务器列表                |
| 314 | [`node_dns_options`](#node_dns_options)               | [`NODE_DNS`](#NODE_DNS)           | string[] | C     | 配置/etc/resolv.conf                 |
| 320 | [`node_repo_method`](#node_repo_method)               | [`NODE_REPO`](#NODE_REPO)         | enum     | C     | 节点使用Yum源的方式                  |
| 321 | [`node_repo_remove`](#node_repo_remove)               | [`NODE_REPO`](#NODE_REPO)         | bool     | C     | 是否移除节点已有Yum源                |
| 322 | [`node_local_repo_url`](#node_local_repo_url)         | [`NODE_REPO`](#NODE_REPO)         | url[]    | C     | 本地源的URL地址                      |
| 330 | [`node_packages`](#node_packages)                     | [`NODE_PACKAGES`](#NODE_PACKAGES) | string[] | C     | 节点安装软件列表                     |
| 331 | [`node_extra_packages`](#node_extra_packages)         | [`NODE_PACKAGES`](#NODE_PACKAGES) | string[] | C     | 节点额外安装的软件列表               |
| 332 | [`node_meta_packages`](#node_meta_packages)           | [`NODE_PACKAGES`](#NODE_PACKAGES) | string[] | G     | 元节点所需的软件列表                 |
| 333 | [`node_meta_pip_install`](#node_meta_pip_install)     | [`NODE_PACKAGES`](#NODE_PACKAGES) | string   | G     | 元节点上通过pip3安装的软件包         |
| 340 | [`node_disable_numa`](#node_disable_numa)             | [`NODE_FEATURES`](#NODE_FEATURES) | bool     | C     | 关闭节点NUMA                         |
| 341 | [`node_disable_swap`](#node_disable_swap)             | [`NODE_FEATURES`](#NODE_FEATURES) | bool     | C     | 关闭节点SWAP                         |
| 342 | [`node_disable_firewall`](#node_disable_firewall)     | [`NODE_FEATURES`](#NODE_FEATURES) | bool     | C     | 关闭节点防火墙                       |
| 343 | [`node_disable_selinux`](#node_disable_selinux)       | [`NODE_FEATURES`](#NODE_FEATURES) | bool     | C     | 关闭节点SELINUX                      |
| 344 | [`node_static_network`](#node_static_network)         | [`NODE_FEATURES`](#NODE_FEATURES) | bool     | C     | 是否使用静态DNS服务器                |
| 345 | [`node_disk_prefetch`](#node_disk_prefetch)           | [`NODE_FEATURES`](#NODE_FEATURES) | bool     | C     | 是否启用磁盘预读                     |
| 346 | [`node_kernel_modules`](#node_kernel_modules)         | [`NODE_MODULES`](#NODE_MODULES)   | string[] | C     | 启用的内核模块                       |
| 350 | [`node_tune`](#node_tune)                             | [`NODE_TUNE`](#NODE_TUNE)         | enum     | C     | 节点调优模式                         |
| 351 | [`node_sysctl_params`](#node_sysctl_params)           | [`NODE_TUNE`](#NODE_TUNE)         | dict     | C     | 操作系统内核参数                     |
| 360 | [`node_admin_setup`](#node_admin_setup)               | [`NODE_ADMIN`](#NODE_ADMIN)       | bool     | G     | 是否创建管理员用户                   |
| 361 | [`node_admin_uid`](#node_admin_uid)                   | [`NODE_ADMIN`](#NODE_ADMIN)       | int      | G     | 管理员用户UID                        |
| 362 | [`node_admin_username`](#node_admin_username)         | [`NODE_ADMIN`](#NODE_ADMIN)       | string   | G     | 管理员用户名                         |
| 363 | [`node_admin_ssh_exchange`](#node_admin_ssh_exchange) | [`NODE_ADMIN`](#NODE_ADMIN)       | bool     | C     | 在实例间交换管理员SSH密钥            |
| 364 | [`node_admin_pk_current`](#node_admin_pk_current)     | [`NODE_ADMIN`](#NODE_ADMIN)       | bool     | A     | 是否将当前用户的公钥加入管理员账户   |
| 365 | [`node_admin_pks`](#node_admin_pks)                   | [`NODE_ADMIN`](#NODE_ADMIN)       | key[]    | C     | 可登陆管理员的公钥列表               |
| 370 | [`node_timezone`](#node_timezone)                     | [`NODE_TIME`](#NODE_TIME)         | string   | C     | NTP时区设置                          |
| 371 | [`node_ntp_config`](#node_ntp_config)                 | [`NODE_TIME`](#NODE_TIME)         | bool     | C     | 是否配置NTP服务？                    |
| 372 | [`node_ntp_service`](#node_ntp_service)               | [`NODE_TIME`](#NODE_TIME)         | enum     | C     | NTP服务类型：ntp或chrony             |
| 373 | [`node_ntp_servers`](#node_ntp_servers)               | [`NODE_TIME`](#NODE_TIME)         | string[] | C     | NTP服务器列表                        |
| 380 | [`node_exporter_enabled`](#node_exporter_enabled)     | [`NODE_EXPORTER`](#NODE_EXPORTER) | bool     | C     | 启用节点指标收集器                   |
| 381 | [`node_exporter_port`](#node_exporter_port)           | [`NODE_EXPORTER`](#NODE_EXPORTER) | int      | C     | 节点指标暴露端口                     |
| 382 | [`node_exporter_options`](#node_exporter_options)     | [`NODE_EXPORTER`](#NODE_EXPORTER) | string   | C/I   | 节点指标采集选项                     |
| 390 | [`promtail_enabled`](#promtail_enabled)               | [`PROMTAIL`](#PROMTAIL)           | bool     | C     | 是否启用Promtail日志收集服务         |
| 391 | [`promtail_clean`](#promtail_clean)                   | [`PROMTAIL`](#PROMTAIL)           | bool     | C/A   | 是否在安装promtail时移除已有状态信息 |
| 392 | [`promtail_port`](#promtail_port)                     | [`PROMTAIL`](#PROMTAIL)           | int      | G     | promtail使用的默认端口               |
| 393 | [`promtail_options`](#promtail_options)               | [`PROMTAIL`](#PROMTAIL)           | string   | C/I   | promtail命令行参数                   |
| 394 | [`promtail_positions`](#promtail_positions)           | [`PROMTAIL`](#PROMTAIL)           | string   | C     | promtail状态文件位置                 |
| 400 | [`docker_enabled`](#docker_enabled)            | [`DOCKER`](#DOCKER)        | bool     | C   | dockerd是否启用?                    |
| 401 | [`docker_cgroups_driver`](#docker_cgroups_driver)           | [`DOCKER`](#DOCKER) | int      | C   | docker cgroup驱动               |
| 402 | [`docker_registry_mirrors`](#docker_registry_mirrors)     | [`DOCKER`](#DOCKER) | string   | C   | docker镜像仓库地址    |
| 403 | [`docker_image_cache`](#docker_image_cache)     | [`DOCKER`](#DOCKER) | string   | C | docker镜像缓存包地址       |


----------------
## `NODE_IDENTITY`

每个节点都有**身份参数**，通过在`<cluster>.hosts`与`<cluster>.vars`中的相关参数进行配置。

Pigsty使用**IP地址**作为**数据库节点**的唯一标识，**该IP地址必须是数据库实例监听并对外提供服务的IP地址**，但不宜使用公网IP地址。尽管如此，用户并不一定非要通过该IP地址连接至该数据库。例如，通过SSH隧道或跳板机中转的方式间接操作管理目标节点也是可行的。但在标识数据库节点时，首要IPv4地址依然是节点的核心标识符，**这一点非常重要，用户应当在配置时保证这一点。** IP地址即配置清单中主机的`inventory_hostname` ，体现为`<cluster>.hosts`对象中的`key`。

除此之外，在Pigsty监控系统中，节点还有两个重要的身份参数：[`nodename`](#nodename) 与 [`node_cluster`](#node_cluster)，这两者将在监控系统中用作节点的 **实例标识**（`ins`） 与 **集群标识** （`cls`）。在执行默认的PostgreSQL部署时，因为Pigsty默认采用节点独占1:1部署，因此可以通过 [`pg_hostname`](v-pgsql.md#pg_hostname) 参数，将数据库实例的身份参数（`pg_cluster` 与 `pg_instance`）借用至节点的`ins`与`cls`标签上。 

[`nodename`](#nodename) 与 [`node_cluster`](#node_cluster)并不是必选的，当留白或置空时，[`nodename`](#nodename) 会使用节点当前的主机名，而 [`node_cluster`](#node_cluster) 则会使用固定的默认值：`nodes`。

|              名称               |    类型    | 层级  | 必要性   | 说明             |
|:-----------------------------:|:--------:| :---: | -------- | ---------------- |
|      `inventory_hostname`       |   `ip`   | **-** | **必选** | **节点IP地址**   |
|     [`nodename`](#nodename)     | `string` | **I** | 可选     | **节点名称**     |
| [`node_cluster`](#node_cluster) | `string` | **C** | 可选     | **节点集群名称** |

以下集群配置声明了一个三节点节点集群：

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

表示此节点为元节点, 类型：`bool`，层级：C，默认值为：`false`

在配置清单中，`meta`分组下的节点默认带有此标记。带有此标记的节点会在节点[软件包安装](#node_packages)时进行额外的配置：
安装[`node_meta_packages`](#node_meta_packages)指定的RPM软件包，并安装[`node_meta_pip_install`](#node_meta_pip_install)指定的Python软件包。




### `nodename`

指定节点名, 类型：`string`，层级：I，默认值为空。

该选项可为节点显式指定名称，只在节点实例层次定义才有意义。使用默认空值或空字符串意味着不为节点指定名称，直接使用现有的 Hostname 作为节点名。

节点名`nodename`将在Pigsty监控系统中，用作节点实例的名称（`ins`标签）。此外，如果 [`nodename_overwrite`](#nodename_overwrite) 为真，节点名还会用作HOSTNAME。

备注：若启用[`pg_hostname`](v-pgsql.md#pg_hostname) 选项，则Pigsty会在初始化节点时，借用当前节点上一一对应PG实例的身份参数，如`pg-test-1`，作为节点名。



### `node_cluster`

节点集群名，类型：`string`，层级：C，默认值为：`"nodes"`。

该选项可为节点显式指定一个集群名称，通常在节点集群层次定义才有意义。使用默认空值将直接使用固定值`nodes`作为节点集群标识。

节点集群名`node_cluster`将在Pigsty监控系统中，用作节点集群的标签（`cls`）。

备注：若启用[`pg_hostname`](v-pgsql.md#pg_hostname) 选项，则Pigsty会在初始化节点时，借用当前节点上一一对应PG集群的身份参数，如`pg-test`，作为节点集群名。





### `nodename_overwrite`

是否用节点名覆盖机器HOSTNAME, 类型：`bool`，层级：C，默认值为：`true`

布尔类型，默认为真，为真时，非空的节点名 [`nodename`](#nodename) 将覆盖节点的当前主机名称。

如果 [`nodename`](#nodename) 参数未定义，为空或为空字符串，则不会对主机名进行修改。




### `nodename_exchange`

是否在剧本节点间交换主机名, 类型：`bool`，层级：C，默认值为：`false`

启用此参数时，同一组执行 [`nodes.yml`](p-nodes.md#nodes) 剧本的节点之间，会相互交换节点名称，写入`/etc/hosts`中。




----------------
## `NODE_DNS`

Pigsty会为节点配置静态DNS解析记录与动态DNS服务器。

如果您的节点供应商已经为您配置了DNS服务器，您可以将 [`node_dns_server`](v-nodes.md#node_dns_server) 设置为 `none` 跳过DNS设置。 



### `node_dns_hosts`

写入机器的静态DNS解析, 类型：`string[]`，层级：C，默认值为：

```yaml
node_dns_hosts:                 # static dns records in /etc/hosts
  - 10.10.10.10 meta pigsty c.pigsty g.pigsty l.pigsty p.pigsty a.pigsty cli.pigsty lab.pigsty api.pigsty
```

[`node_dns_hosts`](#node_dns_hosts) 是一个数组，每一个元素都是形如`ip domain_name`的字符串，代表一条DNS解析记录，每一条记录都会在机器节点初始化时写入`/etc/hosts`中，特别适合在全局配置基础设施地址。

您应当确保向`/etc/hosts`中写入`10.10.10.10 pigsty yum.pigsty`这样的DNS记录，确保在DNS Nameserver启动之前便可以采用域名的方式访问本地yum源。





### `node_dns_hosts_extra`

同上，用于集群实例层级特定的DNS记录, 类型：`string[]`，层级：C/I，默认值为空数组 `[]`






### `node_dns_server`

如何配置DNS服务器？, 类型：`enum`，层级：C，默认值为：`"add"`

机器节点默认的动态DNS服务器的配置方式，有三种模式：

* `add`：将 [`node_dns_servers`](#node_dns_servers) 中的记录追加至`/etc/resolv.conf`，并保留已有DNS服务器。（默认）
* `overwrite`：使用将 [`node_dns_servers`](#node_dns_servers) 中的记录覆盖`/etc/resolv.conf`
* `none`：跳过DNS服务器配置，如果您的环境中已经配置有DNS服务器，则可以跳过。




### `node_dns_servers`

配置动态DNS服务器列表, 类型：`string[]`，层级：C，默认值为 `10.10.10.10`

Pigsty默认会添加元节点作为DNS Server，元节点上的DNSMASQ会响应环境中的DNS请求。

```
node_dns_servers: # dynamic nameserver in /etc/resolv.conf
  - 10.10.10.10
```





### `node_dns_options`

如果 [`node_dns_server`](#node_dns_server) 配置为`add`或`overwrite`，则本配置项中的记录会被追加或覆盖至`/etc/resolv.conf`中。具体格式请参考Linux文档关于`/etc/resolv.conf`的说明

Pigsty默认添加的解析选项为：

```bash
- options single-request-reopen timeout:1 rotate
- domain service.consul
```








----------------
## `NODE_REPO`


Pigsty会为纳入管理的节点配置Yum源，并安装软件包。


### `node_repo_method`

节点使用Yum源的方式, 类型：`enum`，层级：C，默认值为：`"local"`

机器节点Yum软件源的配置方式，有三种模式：

* `local`：使用元节点上的本地Yum源，默认行为，推荐使用此方式。
* `public`：直接使用互联网源安装，将`repo_upstream`中的公共repo写入`/etc/yum.repos.d/`
* `none`：不对本地源进行配置与修改。




### `node_repo_remove`

是否移除节点已有Yum源, 类型：`bool`，层级：C，默认值为：`true`

如何处理节点上原有YUM源？如果启用，则Pigsty会**移除** 节点上`/etc/yum.repos.d`中原有的配置文件，并备份至`/etc/yum.repos.d/backup`




### `node_local_repo_url`

本地源的URL地址, 类型：`url[]`，层级：C，默认值为：

如果 [`node_repo_method`](#node_repo_method) 配置为`local`，则这里列出的Repo文件URL会被下载至`/etc/yum.repos.d`中

这里是一个Repo File URL 构成的数组，Pigsty默认会将元节点上的本地Yum源加入机器的源配置中。

```
node_local_repo_url:
  - http://yum.pigsty/pigsty.repo
```





----------------
## `NODE_PACKAGES`



### `node_packages`

节点安装软件列表, 类型：`string[]`，层级：C，默认值为：

软件包列表为数组，但每个元素可以包含由**逗号分隔**的多个软件包，Pigsty默认安装的软件包列表如下：

```yaml
node_meta_packages:                           # packages for meta nodes only
  - grafana,prometheus2,alertmanager,loki,nginx_exporter,blackbox_exporter,pushgateway,redis,postgresql14
  - nginx,ansible,pgbadger,python-psycopg2,dnsmasq,polysh,coreutils,diffutils
```




### `node_extra_packages`

节点额外安装的软件列表, 类型：`string[]`，层级：C，默认值为：

通过yum安装的额外软件包列表，默认为空列表。

与[`node_packages`](#node_packages)类似，前者通常是全局统一配置，而 [`node_extra_packages`](#node_extra_packages) 则是针对具体节点进行例外处理。
例如，您可以为运行PG的节点安装额外的工具包。该变量通常在集群级别进行覆盖定义。




### `node_meta_packages`

元节点所需的软件列表, 类型：`string[]`，层级：G，默认值为：

```yaml
node_meta_packages:                           # packages for meta nodes only
  - grafana,prometheus2,alertmanager,loki,nginx_exporter,blackbox_exporter,pushgateway,redis,postgresql14
  - nginx,ansible,pgbadger,python-psycopg2,dnsmasq,polysh,coreutils,diffutils
```

与[`node_packages`](#node_packages)类似，但[`node_meta_packages`](#node_meta_packages)中列出的软件包只会在元节点上安装，通常在元节点上使用的基础设施软件需要在此指定




### `node_meta_pip_install`

元节点上通过pip3安装的软件包, 类型：`string`，层级：G，默认值为：`"jupyterlab"`

软件包会下载至[`{{ repo_home }}`](v-infra.md#repo_home)/[`{{ repo_name }}`](v-infra.md#repo_name)/`python`目录后统一安装。

目前默认会安装`jupyterlab`，提供完整的Python运行时环境。






----------------
## `NODE_FEATURES`


配置主机节点上的一些特定功能。


### `node_disable_numa`

关闭节点NUMA, 类型：`bool`，层级：C，默认值为：`false`

布尔标记，是否关闭NUMA，默认不关闭。注意，关闭NUMA需要重启机器后方可生效！

如果您不清楚如何绑核，在生产环境使用数据库时建议关闭NUMA。





### `node_disable_swap`

关闭节点SWAP, 类型：`bool`，层级：C，默认值为：`false`

通常情况下不建议关闭SWAP，如果您有足够的内存，且数据库采用独占式部署，则可以关闭SWAP提高性能。

当您的节点用于部署Kubernetes时，应当禁用SWAP。



### `node_disable_firewall`

关闭节点防火墙, 类型：`bool`，层级：C，默认值为：`true`，请保持关闭。





### `node_disable_selinux`

关闭节点SELINUX, 类型：`bool`，层级：C，默认值为：`true`，请保持关闭。





### `node_static_network`

是否使用静态DNS服务器, 类型：`bool`，层级：C，默认值为：`true`，默认启用。

启用静态网络，意味着您的DNS Resolv配置不会因为机器重启与网卡变动被覆盖。建议启用。





### `node_disk_prefetch`

是否启用磁盘预读, 类型：`bool`，层级：C，默认值为：`false`，默认不启用。

针对HDD部署的实例可以优化吞吐量，使用HDD时建议启用。







----------------
## `NODE_MODULES`


内核功能模块


### `node_kernel_modules`

启用的内核模块, 类型：`string[]`，层级：C，默认值为：

由内核模块名称组成的数组，声明了需要在节点上安装的内核模块，Pigsty默认会启用以下内核模块：

```
node_kernel_modules: [softdog, ip_vs, ip_vs_rr, ip_vs_rr, ip_vs_wrr, ip_vs_sh]
```








----------------
## `NODE_TUNE`

主机节点调优



### `node_tune`

节点调优模式, 类型：`enum`，层级：C，默认值为：`"tiny"`


针对机器进行调优的预制方案，基于`tuned`服务。有四种预制模式：

* `tiny`：微型虚拟机
* `oltp`：常规OLTP模板，优化延迟
* `olap`：常规OLAP模板，优化吞吐量
* `crit`：核心金融业务模板，优化脏页数量

通常，数据库的调优模板 [`pg_conf`](v-pgsql.md#pg_conf)应当与机器调优模板配套，详情请参考[定制PGSQL模版](v-pgsql-customize.md)。





### `node_sysctl_params`

操作系统内核参数, 类型：`dict`，层级：C，默认值为空字典。字典KV结构，Key为内核`sysctl`参数名，Value为参数值。








----------------
## `NODE_ADMIN`


主机节点管理用户


### `node_admin_setup`

是否创建管理员用户, 类型：`bool`，层级：G，默认值为：`true`

是否在每个节点上创建管理员用户（免密sudo与ssh），默认会创建名为`dba (uid=88)`的管理用户，可以从元节点上通过SSH免密访问环境中的其他节点并执行免密sudo。



### `node_admin_uid`

管理员用户UID, 类型：`int`，层级：G，默认值为：`88`，手工分配时请注意UID命名空间冲突。



### `node_admin_username`

管理员用户名, 类型：`string`，层级：G，默认值为：`"dba"`





### `node_admin_ssh_exchange`

在实例间交换节点管理员SSH密钥, 类型：`bool`，层级：C，默认值为：`true`

启用时，Pigsty会在执行剧本时，在成员间交换SSH公钥，允许管理员 [`node_admin_username`](#node_admin_username) 从不同节点上相互访问。




### `node_admin_pk_current`

是否将当前节点&用户的公钥加入管理员账户, 类型：`bool`，层级：A，默认值为：`true`

启用时，将当前节点上，当前用户的SSH公钥（`~/.ssh/id_rsa.pub`）会被拷贝至目标节点管理员用户的`authorized_keys`中。

生产环境部署时，请务必注意此参数，此参数会将当前执行命令用户的默认公钥安装至所有机器的管理用户上。



### `node_admin_pks`

可登陆管理员的公钥列表, 类型：`key[]`，层级：C，默认值为空数组，Demo中有`vagrant`用户默认的公钥。

数组，每一个元素为字符串，内容为写入到管理员用户`~/.ssh/authorized_keys`中的密钥，持有对应私钥的用户可以以管理员身份登录。

 生产环境部署时，请务必注意此参数，仅将信任的密钥加入此列表中。







----------------
## `NODE_TIME`

节点时区与时间同步。

如果您的节点已经配置有NTP服务器，则可以配置 [`node_ntp_config`](v-nodes.md#node_dns_server) 为 `false`，跳过NTP服务的设置。


### `node_timezone`

NTP时区设置, 类型：`string`，层级：C，默认值为空。

在Demo中，默认使用的时区为`"Asia/Hong_Kong"`，请根据您的实际情况调整。（请不要使用`Asia/Shanghai`时区，该时区缩写 CST 会导致一系列日志时区解析问题）

如果选择 `false`，或者留空，则Pigsty不会修改该节点的时区配置。



### `node_ntp_config`

是否配置NTP服务？, 类型：`bool`，层级：C，默认值为：`true`

为真时，Pigsty会覆盖节点的`/etc/ntp.conf` 或 `/etc/chrony.conf`，填入 [`node_ntp_servers`](#node_ntp_servers) 指定的NTP服务器。

如果您的服务器节点已经配置好有NTP服务器，则建议关闭，使用原有NTP服务器。




### `node_ntp_service`

NTP服务类型：`ntp` 或 `chrony`, 类型：`enum`，层级：C，默认值为：`"ntp"`

指明系统使用的NTP服务类型，默认使用 `ntp` 作为时间服务：

* `ntp`：传统NTP服务
* `chrony`：CentOS 7/8默认使用的时间服务

只有当 [`node_ntp_config`](#node_ntp_config) 为真时生效。



### `node_ntp_servers`

NTP服务器列表, 类型：`string[]`，层级：C，默认值为：

```yaml
- pool cn.pool.ntp.org iburst
- pool pool.ntp.org iburst
- pool time.pool.aliyun.com iburst
- server 10.10.10.10 iburst
```

只有当 [`node_ntp_config`](#node_ntp_config) 为真时生效。









----------------
## `NODE_EXPORTER`


NodeExporter用于从主机上收集监控指标数据。


### `node_exporter_enabled`

启用节点指标收集器, 类型：`bool`，层级：C，默认值为：`true`



### `node_exporter_port`

节点指标暴露端口, 类型：`int`，层级：C，默认值为：`9100`



### `node_exporter_options`

节点指标采集选项, 类型：`string`，层级：C/I，默认值为：`"--no-collector.softnet --no-collector.nvme --collector.ntp --collector.tcpstat --collector.processes"`

Pigsty默认会启用`ntp`, `tcpstat`, `processes` 三个额外的指标收集器，禁用 `softnet`, `nvme` 两个默认的指标收集器。




----------------
## `PROMTAIL`

主机日志收集组件，与[Loki](v-infra.md#LOKI)基础设施配置配套使用。



### `promtail_enabled`

是否启用Promtail日志收集服务, 类型：`bool`，层级：C，默认值为：`true`

布尔类型，是否在当前节点启用Promtail日志收集服务？默认启用。

启用 [`promtail`](#promtail) 后，Pigsty会根据配置清单中的定义，生成Promtail的配置文件，抓取下列日志并发送至由[`loki_endpoint`](#loki_endpoint)指定的Loki实例。

* `INFRA`：基础设施日志，只在元节点上收集
  * `nginx-access`: `/var/log/nginx/access.log`
  * `nginx-error`: `/var/log/nginx/error.log`
  * `grafana`: `/var/log/grafana/grafana.log`

* `NODES`： 主机节点日志，在所有节点上收集。
  * `syslog`: `/var/log/messages`
  * `dmesg`: `/var/log/dmesg`
  * `cron`: `/var/log/cron`

* `PGSQL`： PostgreSQL日志，当节点定义有`pg_cluster`时收集。
  * `postgres`: `/pg/data/log/*.csv`
  * `patroni`: `/pg/log/patroni.log`
  * `pgbouncer`: `/var/log/pgbouncer/pgbouncer.log`

* `REDIS`： Redis日志，当节点定义有`redis_cluster`时收集。
  * `redis`: `/var/log/redis/*.log`




### `promtail_clean`

是否在安装promtail时移除已有状态信息, 类型：`bool`，层级：C/A，默认值为：`false`

默认不会清理，当您选择清理时，Pigsty会在部署Promtail时移除现有状态文件 [`promtail_positions`](#promtail_positions)，这意味着Promtail会重新收集当前节点上的所有日志并发送至Loki。



### `promtail_port`

promtail使用的默认端口, 类型：`int`，层级：G，默认值为：`9080`




### `promtail_options`

promtail命令行参数, 类型：`string`，层级：C/I，默认值为：`"-config.file=/etc/promtail.yml -config.expand-env=true"`

运行promtail二进制程序时传入的额外命令行参数，默认值为`'-config.file=/etc/promtail.yml -config.expand-env=true'`。

已有参数用于指定配置文件路径，并在配置文件中展开环境变量，不建议修改。



### `promtail_positions`

promtail状态文件路径, 类型：`string`，层级：C，默认值为：`"/var/log/positions.yaml"`

Promtail记录了所有日志的消费偏移量，定期写入[`promtail_positions`](#promtail_positions) 指定的文件中。



----------------

## `DOCKER`

Pigsty默认在所有元节点上启用Docker，而普通节点不启用。


### `docker_enabled`

是否在当前节点启用Docker？类型：`bool`，层级：`C`，默认值为`false`，但元节点默认为`true`。



### `docker_cgroups_driver`

Docker使用的CGroup驱动，类型：`string`，层级：`C`，默认为`systemd`。



### `docker_registry_mirrors`

Docker使用的镜像仓库地址，类型：`string[]`，层级：`C`，默认为空，即直接使用 DockerHub。


### `docker_image_cache`

本地的Docker镜像离线缓存包，类型：`path`，层级：`C`，默认为：`/www/pigsty/docker.tar.lz4`

如果存在时，配置Docker时会自动加载至本地Docker中。
