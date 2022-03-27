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


| ID  |                         Name                          |              Section              |   Type   | Level |               Comment                |              Comment2              |
|-----|-------------------------------------------------------|-----------------------------------|----------|-------|--------------------------------------|------------------------------------|
| 300 | [`meta_node`](#meta_node)                             | [`NODE_IDENTITY`](#NODE_IDENTITY) | bool     | C     | 表示此节点为元节点                   | mark this node as meta|
| 301 | [`nodename`](#nodename)                               | [`NODE_IDENTITY`](#NODE_IDENTITY) | string   | I     | 指定节点实例标识                     | node instance identity|
| 302 | [`node_cluster`](#node_cluster)                       | [`NODE_IDENTITY`](#NODE_IDENTITY) | string   | C     | 节点集群名，默认名为nodes            | node cluster identity|
| 303 | [`nodename_overwrite`](#nodename_overwrite)           | [`NODE_IDENTITY`](#NODE_IDENTITY) | bool     | C     | 用Nodename覆盖机器HOSTNAME           | overwrite hostname with nodename|
| 304 | [`nodename_exchange`](#nodename_exchange)             | [`NODE_IDENTITY`](#NODE_IDENTITY) | bool     | C     | 是否在剧本节点间交换主机名           | exchange static hostname|
| 310 | [`node_dns_hosts`](#node_dns_hosts)                   | [`NODE_DNS`](#NODE_DNS)           | string[] | C     | 写入机器的静态DNS解析                | static DNS records|
| 311 | [`node_dns_hosts_extra`](#node_dns_hosts_extra)       | [`NODE_DNS`](#NODE_DNS)           | string[] | C/I   | 同上，用于集群实例层级               | extra static DNS records|
| 312 | [`node_dns_server`](#node_dns_server)                 | [`NODE_DNS`](#NODE_DNS)           | enum     | C     | 如何配置DNS服务器？                  | how to setup dns service?|
| 313 | [`node_dns_servers`](#node_dns_servers)               | [`NODE_DNS`](#NODE_DNS)           | string[] | C     | 配置动态DNS服务器列表                | dynamic DNS servers|
| 314 | [`node_dns_options`](#node_dns_options)               | [`NODE_DNS`](#NODE_DNS)           | string[] | C     | 配置/etc/resolv.conf                 | /etc/resolv.conf options|
| 320 | [`node_repo_method`](#node_repo_method)               | [`NODE_REPO`](#NODE_REPO)         | enum     | C     | 节点使用Yum源的方式                  | how to use yum repo (local)|
| 321 | [`node_repo_remove`](#node_repo_remove)               | [`NODE_REPO`](#NODE_REPO)         | bool     | C     | 是否移除节点已有Yum源                | remove existing repo file?|
| 322 | [`node_local_repo_url`](#node_local_repo_url)         | [`NODE_REPO`](#NODE_REPO)         | url[]    | C     | 本地源的URL地址                      | local yum repo url|
| 330 | [`node_packages`](#node_packages)                     | [`NODE_PACKAGES`](#NODE_PACKAGES) | string[] | C     | 节点安装软件列表                     | pkgs to be installed on all node|
| 331 | [`node_extra_packages`](#node_extra_packages)         | [`NODE_PACKAGES`](#NODE_PACKAGES) | string[] | C     | 节点额外安装的软件列表               | extra pkgs to be installed|
| 332 | [`node_meta_packages`](#node_meta_packages)           | [`NODE_PACKAGES`](#NODE_PACKAGES) | string[] | G     | 元节点所需的软件列表                 | meta node only packages|
| 333 | [`node_meta_pip_install`](#node_meta_pip_install)     | [`NODE_PACKAGES`](#NODE_PACKAGES) | string   | G     | 元节点上通过pip3安装的软件包         | meta node pip3 packages|
| 340 | [`node_disable_numa`](#node_disable_numa)             | [`NODE_FEATURES`](#NODE_FEATURES) | bool     | C     | 关闭节点NUMA                         | disable numa?|
| 341 | [`node_disable_swap`](#node_disable_swap)             | [`NODE_FEATURES`](#NODE_FEATURES) | bool     | C     | 关闭节点SWAP                         | disable swap?|
| 342 | [`node_disable_firewall`](#node_disable_firewall)     | [`NODE_FEATURES`](#NODE_FEATURES) | bool     | C     | 关闭节点防火墙                       | disable firewall?|
| 343 | [`node_disable_selinux`](#node_disable_selinux)       | [`NODE_FEATURES`](#NODE_FEATURES) | bool     | C     | 关闭节点SELINUX                      | disable selinux?|
| 344 | [`node_static_network`](#node_static_network)         | [`NODE_FEATURES`](#NODE_FEATURES) | bool     | C     | 是否使用静态DNS服务器                | use static DNS config?|
| 345 | [`node_disk_prefetch`](#node_disk_prefetch)           | [`NODE_FEATURES`](#NODE_FEATURES) | bool     | C     | 是否启用磁盘预读                     | enable disk prefetch?|
| 346 | [`node_kernel_modules`](#node_kernel_modules)         | [`NODE_MODULES`](#NODE_MODULES)   | string[] | C     | 启用的内核模块                       | kernel modules to be installed|
| 350 | [`node_tune`](#node_tune)                             | [`NODE_TUNE`](#NODE_TUNE)         | enum     | C     | 节点调优模式                         | node tune mode|
| 351 | [`node_sysctl_params`](#node_sysctl_params)           | [`NODE_TUNE`](#NODE_TUNE)         | dict     | C     | 操作系统内核参数                     | extra kernel parameters|
| 360 | [`node_admin_setup`](#node_admin_setup)               | [`NODE_ADMIN`](#NODE_ADMIN)       | bool     | G     | 是否创建管理员用户                   | create admin user?|
| 361 | [`node_admin_uid`](#node_admin_uid)                   | [`NODE_ADMIN`](#NODE_ADMIN)       | int      | G     | 管理员用户UID                        | admin user UID|
| 362 | [`node_admin_username`](#node_admin_username)         | [`NODE_ADMIN`](#NODE_ADMIN)       | string   | G     | 管理员用户名                         | admin user name|
| 363 | [`node_admin_ssh_exchange`](#node_admin_ssh_exchange) | [`NODE_ADMIN`](#NODE_ADMIN)       | bool     | C     | 在实例间交换管理员SSH密钥            | exchange admin ssh keys?|
| 364 | [`node_admin_pk_current`](#node_admin_pk_current)     | [`NODE_ADMIN`](#NODE_ADMIN)       | bool     | A     | 是否将当前用户的公钥加入管理员账户   | pks to be added to admin|
| 365 | [`node_admin_pks`](#node_admin_pks)                   | [`NODE_ADMIN`](#NODE_ADMIN)       | key[]    | C     | 可登陆管理员的公钥列表               | add current user's pkey?|
| 370 | [`node_timezone`](#node_timezone)                     | [`NODE_TIME`](#NODE_TIME)         | string   | C     | NTP时区设置                          | node timezone|
| 371 | [`node_ntp_config`](#node_ntp_config)                 | [`NODE_TIME`](#NODE_TIME)         | bool     | C     | 是否配置NTP服务？                    | setup ntp on node?|
| 372 | [`node_ntp_service`](#node_ntp_service)               | [`NODE_TIME`](#NODE_TIME)         | enum     | C     | NTP服务类型：ntp或chrony             | ntp mode: ntp or chrony?|
| 373 | [`node_ntp_servers`](#node_ntp_servers)               | [`NODE_TIME`](#NODE_TIME)         | string[] | C     | NTP服务器列表                        | ntp server list|
| 380 | [`node_exporter_enabled`](#node_exporter_enabled)     | [`NODE_EXPORTER`](#NODE_EXPORTER) | bool     | C     | 启用节点指标收集器                   | node_exporter enabled?|
| 381 | [`node_exporter_port`](#node_exporter_port)           | [`NODE_EXPORTER`](#NODE_EXPORTER) | int      | C     | 节点指标暴露端口                     | node_exporter listen port|
| 382 | [`node_exporter_options`](#node_exporter_options)     | [`NODE_EXPORTER`](#NODE_EXPORTER) | string   | C/I   | 节点指标采集选项                     | node_exporter extra cli args|
| 390 | [`promtail_enabled`](#promtail_enabled)               | [`PROMTAIL`](#PROMTAIL)           | bool     | C     | 是否启用Promtail日志收集服务         | promtail enabled ?|
| 391 | [`promtail_clean`](#promtail_clean)                   | [`PROMTAIL`](#PROMTAIL)           | bool     | C/A   | 是否在安装promtail时移除已有状态信息 | remove promtail status file ?|
| 392 | [`promtail_port`](#promtail_port)                     | [`PROMTAIL`](#PROMTAIL)           | int      | G     | promtail使用的默认端口               | promtail listen port|
| 393 | [`promtail_options`](#promtail_options)               | [`PROMTAIL`](#PROMTAIL)           | string   | C/I   | promtail命令行参数                   | promtail cli args|
| 394 | [`promtail_positions`](#promtail_positions)           | [`PROMTAIL`](#PROMTAIL)           | string   | C     | promtail状态文件位置                 | path to store promtail status file|


----------------
## `NODE_IDENTITY`


每个节点都有**身份参数**，通过在`<cluster>.hosts`与`<cluster>.vars`中的相关参数进行配置

|                    名称                    |    类型    | 层级  | 必要性   | 说明             |
|:----------------------------------------:|:--------:| :---: | -------- | ---------------- |
|            inventory_hostname            |   `ip`   | **-** | **必选** | **节点IP地址**   |
|          [nodename](#nodename)           | `string` | **I** | 可选     | **节点名称**     |
|      [node_cluster](#node_cluster)       | `string` | **C** | 可选     | **节点集群名称** |

* `inventory_hostname` 是节点的IP地址，是必选项，体现为`<cluster>.hosts`对象中的`key`。
* [`nodename`](#nodename)与[`node_cluster`](#node_cluster)为可选项，分别在实例级别与集群级别进行配置，如果不指定将使用合理的默认值。
* 当特殊参数 `pg_hostname: true` 启用时，节点将在初始化时挪用1:1对应的PGSQL实例名与集群名用作节点的实例名与集群名。

* 以下集群配置声明了一个三节点节点集群：

```yaml
node-test:
  hosts:
    10.10.10.11: { nodename: node-test-1 }
    10.10.10.12: { nodename: node-test-2 }
    10.10.10.13: { nodename: node-test-3 }
  vars:
    node_cluster: node-test
```

节点的主机名将用作监控系统中的`ins`标签，集群名将用作`cls`标签。




### `meta_node`

表示此节点为元节点, 类型：`bool`，层级：C，默认值为：`false`

在配置清单中，`meta`分组下的节点默认带有此标记。

带有此标记的节点会在节点置备时进行额外的配置：安装[`node_meta_packages`](#node_meta_packages)指定的RPM软件包，并安装[`node_meta_pip_install`](#node_meta_pip_install)指定的Python软件包。




### `nodename`

指定节点实例标识, 类型：`string`，层级：I，默认值为：

该选项可为节点显式指定名称，只可在节点实例层次定义。

在Pigsty中，主机名将被用作为节点身份标识的一部分，例如监控数据的`ins`标签。

备注：如果要使用PostgreSQL的实例名称作为节点名称，可以指定使用[`pg_hostname`](v-pgsql.md#pg_hostname)选项，则初始化节点时，PG实例名会被设置为 `nodename`。




### `node_cluster`

节点集群名，默认名为nodes, 类型：`string`，层级：C，默认值为：`"nodes"`

该选项可为节点指定一个集群名，如果不指定，将使用默认的节点集群名`nodes`。

节点集群是一个Pigsty中的虚拟概念，在Pigsty监控系统中，将对归属于同一集群的节点计算额外的监控指标，例如整个集群的CPU使用率等。

备注：如果要使用PostgreSQL的集群名称作为节点集群名称，可以指定使用`pg_hostname`选项，则初始化节点时，当前节点上定义的唯一PG实例的集群名，会被设置为节点的集群名。

例如，以下配置项声明了一个名为`app-payment

```yaml
app-payment:
  hosts:
    10.10.10.10: { nodename: app-payment-1 }
    10.10.10.11: { nodename: app-payment-1 }
  vars:
    node_cluster: app-payment
```





### `nodename_overwrite`

用Nodename覆盖机器HOSTNAME, 类型：`bool`，层级：C，默认值为：`true`

布尔类型，默认为真，为真时，非空的节点名 [`nodename`](#nodename) 将覆盖节点的当前主机名称。

如果 [`nodename`](#nodename) 参数未定义，为空或为空字符串，则不会对主机名进行修改。




### `nodename_exchange`

是否在剧本节点间交换主机名, 类型：`bool`，层级：C，默认值为：`false`





----------------
## `NODE_DNS`





### `node_dns_hosts`

写入机器的静态DNS解析, 类型：`string[]`，层级：C，默认值为：

```yaml
node_dns_hosts:                 # static dns records in /etc/hosts
  - 10.10.10.10 meta pigsty c.pigsty g.pigsty l.pigsty p.pigsty a.pigsty cli.pigsty lab.pigsty api.pigsty
```

机器节点的默认静态DNS解析记录，每一条记录都会在机器节点初始化时写入`/etc/hosts`中，特别适合在全局配置基础设施地址。

[`node_dns_hosts`](#node_dns_hosts) 是一个数组，每一个元素都是形如`ip domain_name`的字符串，代表一条DNS解析记录。

默认情况下，Pigsty会向`/etc/hosts`中写入`10.10.10.10 yum.pigsty`，这样可以在DNS Nameserver启动之前，采用域名的方式访问本地yum源。





### `node_dns_hosts_extra`

同上，用于集群实例层级, 类型：`string[]`，层级：C/I，默认值为空数组 `[]`






### `node_dns_server`

如何配置DNS服务器？, 类型：`enum`，层级：C，默认值为：`"add"`

机器节点默认的动态DNS服务器的配置方式，有三种模式：

* `add`：将 [`node_dns_servers`](#node_dns_servers) 中的记录追加至`/etc/resolv.conf`，并保留已有DNS服务器。（默认）
* `overwrite`：使用将 [`node_dns_servers`](#node_dns_servers) 中的记录覆盖`/etc/resolv.conf`
* `none`：跳过DNS服务器配置




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





### `node_repo_method`

节点使用Yum源的方式, 类型：`enum`，层级：C，默认值为：`"local"`

机器节点Yum软件源的配置方式，有三种模式：

* `local`：使用元节点上的本地Yum源，默认行为，推荐。
* `public`：直接使用互联网源安装，将`repo_upstream`中的公共repo写入`/etc/yum.repos.d/`
* `none`：不对本地源进行配置与修改。




### `node_repo_remove`

是否移除节点已有Yum源, 类型：`bool`，层级：C，默认值为：`true`

原有Yum源的处理方式，是否移除节点上原有的Yum源？

Pigsty默认会**移除**`/etc/yum.repos.d`中原有的配置文件，并备份至`/etc/yum.repos.d/backup`




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

与[`node_packages`](#node_packages)类似，但[`node_packages`](#node_packages)通常是全局统一配置，而 [`node_extra_packages`](#node_extra_packages) 则是针对具体节点进行例外处理。例如，您可以为运行PG的节点安装额外的工具包。该变量通常在集群和实例级别进行覆盖定义。









### `node_meta_packages`

元节点所需的软件列表, 类型：`string[]`，层级：G，默认值为：

与[`node_packages`](#node_packages)和[`node_extra_packages`](#node_extra_packages)类似，但[`node_meta_packages`](#node_meta_packages)中列出的软件包只会在元节点上安装。
因此通常都是监控软件，管理工具，构建工具等。Pigsty默认安装的元节点软件包列表如下：

```yaml
node_meta_packages:                           # packages for meta nodes only
  - grafana,prometheus2,alertmanager,loki,nginx_exporter,blackbox_exporter,pushgateway,redis,postgresql14
  - nginx,ansible,pgbadger,python-psycopg2,dnsmasq,polysh,coreutils,diffutils
```






### `node_meta_pip_install`

元节点上通过pip3安装的软件包, 类型：`string`，层级：G，默认值为：`"jupyterlab"`

软件包会下载至[`{{ repo_home }}`](v-infra.md#repo_home)/[`{{ repo_name }}`](v-infra.md#repo_name)/`python`目录后统一安装。

目前默认会安装`jupyterlab`，提供完整的Python运行时环境。






----------------
## `NODE_FEATURES`





### `node_disable_numa`

关闭节点NUMA, 类型：`bool`，层级：C，默认值为：`false`

布尔标记，是否关闭NUMA，默认不关闭。注意，关闭NUMA需要重启机器后方可生效！

如果您不清楚如何绑核，在生产环境使用数据库时建议关闭NUMA。





### `node_disable_swap`

关闭节点SWAP, 类型：`bool`，层级：C，默认值为：`false`

通常情况下不建议关闭SWAP，如果您有足够的内存，且数据库采用独占式部署，则可以关闭SWAP提高性能。

当您的节点用于部署Kubernetes时，应当禁用SWAP。



### `node_disable_firewall`

关闭节点防火墙, 类型：`bool`，层级：C，默认值为：`true`，建议保持关闭。





### `node_disable_selinux`

关闭节点SELINUX, 类型：`bool`，层级：C，默认值为：`true`，建议保持关闭。





### `node_static_network`

是否使用静态DNS服务器, 类型：`bool`，层级：C，默认值为：`true`，默认启用。

启用静态网络，意味着您的DNS Resolv配置不会因为机器重启与网卡变动被覆盖。建议启用。





### `node_disk_prefetch`

是否启用磁盘预读, 类型：`bool`，层级：C，默认值为：`false`，默认不启用。

针对HDD部署的实例可以优化吞吐量，使用HDD时建议启用。







----------------
## `NODE_MODULES`





### `node_kernel_modules`

启用的内核模块, 类型：`string[]`，层级：C，默认值为：

由内核模块名称组成的数组，声明了需要在节点上安装的内核模块，Pigsty默认会启用以下内核模块：

```
node_kernel_modules: [softdog, ip_vs, ip_vs_rr, ip_vs_rr, ip_vs_wrr, ip_vs_sh]
```








----------------
## `NODE_TUNE`





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





### `node_admin_setup`

是否创建管理员用户, 类型：`bool`，层级：G，默认值为：`true`

是否在每个节点上创建管理员用户（免密sudo与ssh），默认会创建。

Pigsty默认会创建名为`admin (uid=88)`的管理用户，可以从元节点上通过SSH免密访问环境中的其他节点并执行免密sudo。



### `node_admin_uid`

管理员用户UID, 类型：`int`，层级：G，默认值为：`88`

分配时请注意UID命名空间冲突。



### `node_admin_username`

管理员用户名, 类型：`string`，层级：G，默认值为：`"dba"`





### `node_admin_ssh_exchange`

在实例间交换管理员SSH密钥, 类型：`bool`，层级：C，默认值为：`true`

是否在当前执行命令的机器之间相互交换管理员用户的SSH密钥？

默认会执行交换，这样管理员 [`node_admin_username`](#node_admin_username) 可以在机器间快速跳转。



### `node_admin_pk_current`

是否将当前用户的公钥加入管理员账户, 类型：`bool`，层级：A，默认值为：`true`

布尔类型，通常用作命令行参数，启用时，用于将当前用户的SSH公钥（~/.ssh/id_rsa.pub）拷贝至管理员用户的`authorized_keys`中。默认拷贝。

```bash
./nodes.yml -t node_admin_pk_current 
```

!> 生产环境部署时，请务必注意此参数，此参数会将当前执行命令用户的默认公钥安装至所有机器的管理用户上。



### `node_admin_pks`

可登陆管理员的公钥列表, 类型：`key[]`，层级：C，默认值为空数组，Demo中有`vagrant`用户默认的公钥。

数组，每一个元素为字符串，内容为写入到管理员用户`~/.ssh/authorized_keys`中的密钥，持有对应私钥的用户可以以管理员身份登陆。

!> 生产环境部署时，请务必注意此参数，仅将信任的密钥加入此列表中。







----------------
## `NODE_TIME`





### `node_timezone`

NTP时区设置, 类型：`string`，层级：C，默认值为：`"Asia/Hong_Kong"`

默认使用的时区

Pigsty默认使用`Asia/Hong_Kong`，请根据您的实际情况调整。

> 请不要使用`Asia/Shanghai`时区，该时区缩写 CST 会导致一系列日志时区解析问题。

如果选择 `false`，则Pigsty不会修改该节点的时区配置。



### `node_ntp_config`

是否配置NTP服务？, 类型：`bool`，层级：C，默认值为：`true`

布尔标记，是否覆盖现有NTP配置？默认覆盖。

如果您的服务器节点已经配置好有NTP服务器，则建议关闭，使用原有NTP服务器。




### `node_ntp_service`

NTP服务类型：ntp或chrony, 类型：`enum`，层级：C，默认值为：`"ntp"`

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







----------------
## `PROMTAIL`





### `promtail_enabled`

是否启用Promtail日志收集服务, 类型：`bool`，层级：C，默认值为：`true`

布尔类型，是否在当前节点启用Promtail日志收集服务？默认启用。

启用 [`promtail`](#promtail) 后，Pigsty会根据配置清单中的定义，生成Promtail的配置文件，抓取下列日志并发送至由[`loki_endpoint`](#loki_endpoint)指定的Loki实例。

* `INFRA`：基础设施日志，只在管理节点上收集
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

布尔类型，命令行参数。是否在安装promtail时移除已有状态信息？状态文件记录在[`promtail_positions`](#promtail_positions) 中，记录了所有日志的消费偏移量，默认不会清理。

当您选择清理时，Promtail会重新收集当前节点上的所有日志并发送至Loki。



### `promtail_port`

promtail使用的默认端口, 类型：`int`，层级：G，默认值为：`9080`





### `promtail_options`

promtail命令行参数, 类型：`string`，层级：C/I，默认值为：`"-config.file=/etc/promtail.yml -config.expand-env=true"`

运行promtail二进制程序时传入的额外命令行参数，默认值为`'-config.file=/etc/promtail.yml -config.expand-env=true'`。

已有参数用于指定配置文件路径，并在配置文件中展开环境变量，不建议修改已有参数。



### `promtail_positions`

promtail状态文件位置, 类型：`string`，层级：C，默认值为：`"/var/log/positions.yaml"`