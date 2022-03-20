# 节点参数

Pigsty提供了完整的主机置备与监控功能，执行 [`nodes.yml`](p-node.md) 剧本即可将对应节点配置为对应状态，并纳入Pigsty监控系统。

默认情况下，Pigsty将在节点上配置身份，DNS记录与解析，设置Yum源，安装RPM软件包，启用内核模块，应用参数配置与调优模板，创建管理员，配置时间与时区同步服务。
Pigsty还会在节点上安装DCS（Consul Agent）与监控组件。对于元节点而言，还会安装额外的RPM与PIP软件包。

## 参数概览

|                         名称                          |     类型     |  层级   | 说明                 |
|:---------------------------------------------------:|:----------:|:-----:|--------------------|
|               [meta_node](#meta_node)               |   `bool`   |  I/C  | 表示此节点为元节点          |
|                [nodename](#nodename)                |  `string`  |   I   | 若指定，覆盖机器HOSTNAME   |
|            [node_cluster](#node_cluster)            |  `string`  |   C   | 节点集群名，默认名为`nodes`  |
|      [node_name_exchange](#node_name_exchange)      |   `bool`   | I/C/G | 是否在剧本节点间交换主机名      |
|          [node_dns_hosts](#node_dns_hosts)          | `string[]` |   G   | 写入机器的静态DNS解析       |
|    [node_dns_hosts_extra](#node_dns_hosts_extra)    | `string[]` |  I/C  | 同上，用于集群实例层级        |
|         [node_dns_server](#node_dns_server)         |   `enum`   |   G   | 如何配置DNS服务器？        |
|        [node_dns_servers](#node_dns_servers)        | `string[]` |   G   | 配置动态DNS服务器         |
|        [node_dns_options](#node_dns_options)        | `string[]` |   G   | 配置/etc/resolv.conf |
|        [node_repo_method](#node_repo_method)        |   `enum`   |   G   | 节点使用Yum源的方式        |
|        [node_repo_remove](#node_repo_remove)        |   `bool`   |   G   | 是否移除节点已有Yum源       |
|     [node_local_repo_url](#node_local_repo_url)     | `string[]` |   G   | 本地源的URL地址          |
|           [node_packages](#node_packages)           | `string[]` |   G   | 节点安装软件列表           |
|     [node_extra_packages](#node_extra_packages)     | `string[]` | C/I/A | 节点额外安装的软件列表        |
|      [node_meta_packages](#node_meta_packages)      | `string[]` |   G   | 元节点所需的软件列表         |
|   [node_meta_pip_install](#node_meta_pip_install)   |  `string`  |   G   | 元节点上通过pip3安装的软件包   |
|       [node_disable_numa](#node_disable_numa)       |   `bool`   |   G   | 关闭节点NUMA           |
|       [node_disable_swap](#node_disable_swap)       |   `bool`   |   G   | 关闭节点SWAP           |
|   [node_disable_firewall](#node_disable_firewall)   |   `bool`   |   G   | 关闭节点防火墙            |
|    [node_disable_selinux](#node_disable_selinux)    |   `bool`   |   G   | 关闭节点SELINUX        |
|     [node_static_network](#node_static_network)     |   `bool`   |   G   | 是否使用静态DNS服务器       |
|      [node_disk_prefetch](#node_disk_prefetch)      |   `bool`   |   G   | 是否启用磁盘预读           |
|     [node_kernel_modules](#node_kernel_modules)     | `string[]` |   G   | 启用的内核模块            |
|               [node_tune](#node_tune)               |   `enum`   |   G   | 节点调优模式            |
|      [node_sysctl_params](#node_sysctl_params)      |   `dict`   |   G   | 操作系统内核参数           |
|        [node_admin_setup](#node_admin_setup)        |   `bool`   |   G   | 是否创建管理员用户          |
|          [node_admin_uid](#node_admin_uid)          |  `number`  |   G   | 管理员用户UID           |
|     [node_admin_username](#node_admin_username)     |  `string`  |   G   | 管理员用户名             |
| [node_admin_ssh_exchange](#node_admin_ssh_exchange) |   `bool`   |   G   | 在实例间交换管理员SSH密钥     |
|          [node_admin_pks](#node_admin_pks)          | `string[]` |   G   | 可登陆管理员的公钥列表        |
|   [node_admin_pk_current](#node_admin_pk_current)   |   `bool`   |   A   | 是否将当前用户的公钥加入管理员账户  |
|        [node_ntp_service](#node_ntp_service)        |   `enum`   |   G   | NTP服务类型：ntp或chrony |
|         [node_ntp_config](#node_ntp_config)         |   `bool`   |   G   | 是否配置NTP服务？         |
|           [node_timezone](#node_timezone)           |  `string`  |   G   | NTP时区设置            |
|        [node_ntp_servers](#node_ntp_servers)        | `string[]` |   G   | NTP服务器列表           |
|        [service_registry](#service_registry)        |   `enum`    | G/C/I | 服务注册的位置           |
|                [dcs_type](#dcs_type)                |   `enum`    |   G   | 使用的DCS类型          |
|                [dcs_name](#dcs_name)                |  `string`   |   G   | DCS集群名称           |
|             [dcs_servers](#dcs_servers)             |   `dict`    |   G   | DCS服务器名称:IP列表     |
|       [dcs_exists_action](#dcs_exists_action)       |   `enum`    |  G/A  | 若DCS实例存在如何处理      |
|       [dcs_disable_purge](#dcs_disable_purge)       |   `bool`    | G/C/I | 完全禁止清理DCS实例       |
|         [consul_data_dir](#consul_data_dir)         |  `string`   |   G   | Consul数据目录        |
|           [etcd_data_dir](#etcd_data_dir)           |  `string`   |   G   | Etcd数据目录          |
|           [exporter_install](#exporter_install)           |  `enum`  | G/C  | 安装监控组件的方式             |
|          [exporter_repo_url](#exporter_repo_url)          | `string` | G/C  | 监控组件的YumRepo              |
|      [exporter_metrics_path](#exporter_metrics_path)      | `string` | G/C  | 监控暴露的URL Path             |
|      [node_exporter_enabled](#node_exporter_enabled)      |  `bool`  | G/C  | 启用节点指标收集器             |
|         [node_exporter_port](#node_exporter_port)         | `number` | G/C  | 节点指标暴露端口               |
|      [node_exporter_options](#node_exporter_options)      | `string` | G/C  | 节点指标采集选项               |



## 身份参数

每个节点都有**身份参数**，通过在`<cluster>.hosts`与`<cluster>.vars`中的相关参数进行配置

|                   名称                    |   类型   | 层级  | 必要性   | 说明             |
| :---------------------------------------: | :------: | :---: | -------- | ---------------- |
| [inventory_hostname](#inventory_hostname) | `string` | **-** | **必选** | **节点IP地址**   |
|           [nodename](#nodename)           | `string` | **I** | 可选     | **节点名称**     |
|       [node_cluster](#node_cluster)       | `string` | **C** | 可选     | **节点集群名称** |

`inventory_hostname` 是节点的IP地址，是必选项，体现为`<cluster>.hosts`对象中的`key`。
`nodename`与`node_cluster`为可选项，分别在实例级别与集群级别进行配置，如果不指定将使用合理的默认值。
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

节点的主机名将用作监控系统中的`ins`标签，集群名将用作`cls`标签，一些典型的监控指标数据将如下所示：

```bash
node:ins:cpu_usage{ins=}

```



## 默认配置

节点相关配置

```yaml
#------------------------------------------------------------------------------
# NODE PROVISION
#------------------------------------------------------------------------------
# this section defines how to provision nodes

# - node flag - #
meta_node: false                              # node with meta_node will be marked as admin nod

# - node identity - #
# nodename:                                   # if provided, node's hostname will be overwritten
node_cluster: nodes                           # node's cluster label will be set to this (nodes by default)
node_name_exchange: false                     # exchange hostname among play hosts ?

# - node dns - #
node_dns_hosts: [ ]                           # static dns records in /etc/hosts
node_dns_hosts_extra: []                      # extra static dns records in /etc/hosts

node_dns_server: none                         # add (default) | none (skip) | overwrite (remove old settings)
node_dns_servers: [ ]                         # dynamic nameserver in /etc/resolv.conf
node_dns_options:                             # dns resolv options
  - options single-request-reopen timeout:1 rotate
  - domain service.consul

# - node repo - #
node_repo_method: local                       # none|local|public (use local repo for production env)
node_repo_remove: true                        # whether remove existing repo
node_local_repo_url:                          # local repo url (if method=local, make sure firewall is configured or disabled)
  - http://pigsty/pigsty.repo

# - node packages - #
node_packages:                                # common packages for all nodes
  - wget,yum-utils,sshpass,ntp,chrony,tuned,uuid,lz4,vim-minimal,make,patch,bash,lsof,wget,unzip,git,ftp
  - numactl,grubby,sysstat,dstat,iotop,bind-utils,net-tools,tcpdump,socat,ipvsadm,telnet,tuned,pv,jq,perf
  - readline,zlib,openssl,openssl-libs,python3,python36-requests,node_exporter,redis_exporter,consul,etcd
node_extra_packages: [ ]                      # extra packages for all nodes
node_meta_packages:                           # packages for meta nodes only
  - grafana,prometheus2,alertmanager,nginx_exporter,blackbox_exporter,pushgateway,redis,postgresql14
  - nginx,ansible,pgbadger,python-psycopg2,dnsmasq,polysh
  - clang,coreutils,diffutils,rpm-build,rpm-devel,rpmlint,rpmdevtools,bison,flex # gcc,gcc-c++
  - readline-devel,zlib-devel,uuid-devel,libuuid-devel,libxml2-devel,libxslt-devel,openssl-devel,libicu-devel
node_meta_pip_install: 'jupyterlab'           # pip packages installed on meta

# - node features - #
node_disable_numa: false                      # disable numa, important for production database, reboot required
node_disable_swap: false                      # disable swap, important for production database
node_disable_firewall: true                   # disable firewall (required if using kubernetes)
node_disable_selinux: true                    # disable selinux  (required if using kubernetes)
node_static_network: true                     # keep dns resolver settings after reboot
node_disk_prefetch: false                     # setup disk prefetch on HDD to increase performance

# - node kernel modules - #
node_kernel_modules: [softdog, br_netfilter, ip_vs, ip_vs_rr, ip_vs_rr, ip_vs_wrr, ip_vs_sh]

# - node tuned - #
node_tune: tiny                               # install and activate tuned profile: none|oltp|olap|crit|tiny
node_sysctl_params: {}                        # set additional sysctl parameters, k:v format
# net.bridge.bridge-nf-call-iptables: 1       # example sysctl parameters

# - node admin - #
node_admin_setup: true                        # create a default admin user defined by `node_admin_*` ?
node_admin_uid: 88                            # uid and gid for this admin user
node_admin_username: dba                      # name of this admin user, dba by default
node_admin_ssh_exchange: true                 # exchange admin ssh key among each pgsql cluster ?
node_admin_pk_current: true                   # add current user's ~/.ssh/id_rsa.pub to admin authorized_keys ?
node_admin_pks: []                            # ssh public keys to be added to admin user (REPLACE WITH YOURS!)

# - node tz - #
node_timezone: ''                             # default node timezone, empty will not change it

# - node ntp - #
node_ntp_service: ntp                         # ntp service provider: ntp|chrony
node_ntp_config: true                         # config ntp service? false will leave it with system default
node_ntp_servers:                             # default NTP servers
  - pool pool.ntp.org iburst
```





## 参数详解

### meta_node

Bool类型标记，元节点为真，其他节点为假。

在配置清单中，`meta`分组下的节点默认带有此标记。

带有此标记的节点会在节点置备时进行额外的配置：安装[`node_meta_packages`](#node_meta_packages)指定的RPM软件包，并安装[`node_meta_pip_install`](#node_meta_pip_install)指定的Python软件包。


### nodename

该选项可为节点显式指定名称。如果配置了该参数，那么实例的主机名（`HOSTNAME`）将会被该名称覆盖。 如果该参数未定义，为空或为空字符串，则不会对主机名进行修改。

在Pigsty监控系统中，主机名将被用作为监控数据的`ins`标签。

备注：如果要使用PostgreSQL的实例名称作为节点名称，可以指定使用`pg_hostname`选项，则初始化节点时，PG实例名会被设置为主机节点名。


### node_cluster

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


### node_dns_hosts

机器节点的默认静态DNS解析记录，每一条记录都会在机器节点初始化时写入`/etc/hosts`中，特别适合用于配置基础设施地址。

`node_dns_hosts`是一个数组，每一个元素都是形如`ip domain_name`的字符串，代表一条DNS解析记录。

默认情况下，Pigsty会向`/etc/hosts`中写入`10.10.10.10 yum.pigsty`，这样可以在DNS Nameserver启动之前，采用域名的方式访问本地yum源。



### node_dns_server

机器节点默认的动态DNS服务器的配置方式，有三种模式：

* `add`：将`node_dns_servers`中的记录追加至`/etc/resolv.conf`，并保留已有DNS服务器。（默认）
* `overwrite`：使用将`node_dns_servers`中的记录覆盖`/etc/resolv.conf`
* `none`：跳过DNS服务器配置



### node_dns_servers

如果`node_dns_server`配置为`add`或`overwrite`，则`node_dns_servers`中的记录会被追加或覆盖至`/etc/resolv.conf`中。具体格式请参考Linux文档关于`/etc/resolv.conf`的说明。

Pigsty默认会添加元节点作为DNS Server，元节点上的DNSMASQ会响应环境中的DNS请求。 

```
node_dns_servers: # dynamic nameserver in /etc/resolv.conf
  - 10.10.10.10
```



### node_dns_options

如果`node_dns_server`配置为`add`或`overwrite`，则`node_dns_options`中的记录会被追加或覆盖至`/etc/resolv.conf`中。具体格式请参考Linux文档关于`/etc/resolv.conf`的说明

Pigsty默认添加的解析选项为：

```bash
- options single-request-reopen timeout:1 rotate
- domain service.consul
```



### node_repo_method

机器节点Yum软件源的配置方式，有三种模式：

* `local`：使用元节点上的本地Yum源，默认行为，推荐。
* `public`：直接使用互联网源安装，将`repo_upstream`中的公共repo写入`/etc/yum.repos.d/`
* `none`：不对本地源进行配置与修改。



### node_repo_remove

原有Yum源的处理方式，是否移除节点上原有的Yum源？

Pigsty默认会**移除**`/etc/yum.repos.d`中原有的配置文件，并备份至`/etc/yum.repos.d/backup`



### node_local_repo_url

如果`node_repo_method`配置为`local`，则这里列出的Repo文件URL会被下载至`/etc/yum.repos.d`中

这里是一个Repo File URL 构成的数组，Pigsty默认会将元节点上的本地Yum源加入机器的源配置中。

```
node_local_repo_url:
  - http://yum.pigsty/pigsty.repo
```



### node_packages

通过yum安装的软件包列表。

软件包列表为数组，但每个元素可以包含由**逗号分隔**的多个软件包，Pigsty默认安装的软件包列表如下：

```yaml
node_packages:                                # common packages for all nodes
  - wget,yum-utils,sshpass,ntp,chrony,tuned,uuid,lz4,vim-minimal,make,patch,bash,lsof,wget,unzip,git,readline,zlib,openssl
  - numactl,grubby,sysstat,dstat,iotop,bind-utils,net-tools,tcpdump,socat,ipvsadm,telnet,tuned,pv,jq
  - python3,python3-psycopg2,python36-requests,python3-etcd,python3-consul
  - python36-urllib3,python36-idna,python36-pyOpenSSL,python36-cryptography
  - node_exporter,consul,consul-template,etcd,haproxy,keepalived,vip-manager
```



### node_extra_packages

通过yum安装的额外软件包列表。

与`node_packages`类似，但`node_packages`通常是全局统一配置，而`node_extra_packages`则是针对具体节点进行例外处理。例如，您可以为运行PG的节点安装额外的工具包。该变量通常在集群和实例级别进行覆盖定义。

Pigsty默认安装的额外软件包列表如下：

```yaml
- patroni,patroni-consul,patroni-etcd,pgbouncer,pgbadger,pg_activity
```



### node_meta_packages

通过yum安装的元节点软件包列表。

与`node_packages`和`node_extra_packages`类似，但`node_meta_packages`中列出的软件包只会在元节点上安装。因此通常都是监控软件，管理工具，构建工具等。Pigsty默认安装的元节点软件包列表如下：

```yaml
node_meta_packages:                           # packages for meta nodes only
  - grafana,prometheus2,alertmanager,nginx_exporter,blackbox_exporter,pushgateway
  - dnsmasq,nginx,ansible,pgbadger,polysh
```



### node_meta_pip_install

通过pip3安装的元节点软件包列表。

软件包会下载至`{{ repo_home }}/{{ repo_name }}/python`目录后统一安装。

目前默认会安装`jupyterlab`，提供完整的Python运行时环境。



### node_disable_numa

是否关闭Numa，注意，该选项需要重启机器后方可生效！

默认不关闭，但生产环境建议关闭NUMA。



### node_disable_swap

是否禁用SWAP，默认不禁用。

通常情况下不建议关闭SWAP，如果您有足够的内存，且数据库采用独占式部署，则可以关闭SWAP提高性能。



### node_disable_firewall

是否关闭防火墙，建议关闭，默认关闭。



### node_disable_selinux

是否关闭SELinux，建议关闭，默认关闭。




### node_static_network

是否采用静态网络配置，默认启用

启用静态网络，意味着您的DNS Resolv配置不会因为机器重启与网卡变动被覆盖。建议启用。



### node_disk_prefetch

是否启用磁盘预读？

针对HDD部署的实例可以优化吞吐量，默认关闭。



### node_kernel_modules

需要安装的内核模块

Pigsty默认会启用以下内核模块

```
node_kernel_modules: [softdog, ip_vs, ip_vs_rr, ip_vs_rr, ip_vs_wrr, ip_vs_sh]
```



### node_tune

针对机器进行调优的预制方案，基于`tuned`服务。有四种预制模式：

* `tiny`：微型虚拟机
* `oltp`：常规OLTP数据库，优化延迟
* `olap`：常规OLAP数据库，优化吞吐量
* `crit`：核心金融库，优化数据一致性

通常机器节点的调优需要与[数据库模版](t-patroni-template.md)相对应。


### node_sysctl_params

需要额外修改的操作系统内核参数

字典KV结构，Key为参数名，Value为参数值。



### node_admin_setup

是否在每个节点上创建管理员用户（免密sudo与ssh），默认会创建。

Pigsty默认会创建名为`admin (uid=88)`的管理用户，可以从元节点上通过SSH免密访问环境中的其他节点并执行免密sudo。



### node_admin_uid

管理员用户的`uid`，默认为`88`，分配时请注意UID命名空间冲突。




### node_admin_username

管理员用户的名称，默认为`dba`



### node_admin_ssh_exchange

是否在当前执行命令的机器之间相互交换管理员用户的SSH密钥？

默认会执行交换，这样管理员可以在机器间快速跳转。



### node_admin_pks

写入到管理员`~/.ssh/authorized_keys`中的密钥

持有对应私钥的用户可以以管理员身份登陆。



### node_admin_current_pk

布尔类型，通常用作命令行参数。用于将当前用户的SSH公钥（~/.ssh/id_rsa.pub）拷贝至管理员用户的`authorized_keys`中。默认不拷贝。



### node_ntp_service

指明系统使用的NTP服务类型：

* `ntp`：传统NTP服务
* `chrony`：CentOS 7/8默认使用的时间服务



### node_ntp_config

是否覆盖现有NTP配置？

布尔选项，默认覆盖（`true`）。


### node_timezone

默认使用的时区

Pigsty默认使用`Asia/Hong_Kong`，请根据您的实际情况调整。

> 请不要使用`Asia/Shanghai`时区，该时区缩写 CST 会导致一系列日志时区解析问题。

如果选择 `false`，则Pigsty不会修改该节点的时区配置。


### node_ntp_servers

NTP服务器地址

Pigsty默认会使用以下NTP服务器，其中`10.10.10.10`会被替换为管理节点的IP地址。

```ini
- pool cn.pool.ntp.org iburst
- pool pool.ntp.org iburst
- pool time.pool.aliyun.com iburst
- server 10.10.10.10 iburst
```

