# 节点参数

Pigsty提供了完整的主机置备与监控功能，执行 [`nodes.yml`](p-node.md) 剧本即可将对应节点配置为对应状态，并纳入Pigsty监控系统。

默认情况下，Pigsty将在节点上配置身份，DNS记录与解析，设置Yum源，安装RPM软件包，启用内核模块，应用参数配置与调优模板，创建管理员，配置时间与时区同步服务。
Pigsty还会在节点上安装DCS（Consul Agent）与监控组件。对于元节点而言，还会安装额外的RPM与PIP软件包。


|                        参数                         |                                       角色                                       | 层级  |                 说明                 |
|-----------------------------------------------------|----------------------------------------------------------------------------------|-------|--------------------------------------|
| [meta_node](#meta_node)                             | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | I/C   | 表示此节点为元节点|
| [nodename](#nodename)                               | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | I     | 指定节点实例标识|
| [nodename_overwrite](#nodename_overwrite)           | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | I/C/G | 用Nodename覆盖机器HOSTNAME|
| [node_cluster](#node_cluster)                       | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | C     | 节点集群名，默认名为nodes|
| [node_name_exchange](#node_name_exchange)           | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | I/C/G | 是否在剧本节点间交换主机名|
| [node_dns_hosts](#node_dns_hosts)                   | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | 写入机器的静态DNS解析|
| [node_dns_hosts_extra](#node_dns_hosts_extra)       | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | I/C   | 同上，用于集群实例层级|
| [node_dns_server](#node_dns_server)                 | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | 如何配置DNS服务器？|
| [node_dns_servers](#node_dns_servers)               | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | 配置动态DNS服务器|
| [node_dns_options](#node_dns_options)               | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | 配置/etc/resolv.conf|
| [node_repo_method](#node_repo_method)               | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | 节点使用Yum源的方式|
| [node_repo_remove](#node_repo_remove)               | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | 是否移除节点已有Yum源|
| [node_local_repo_url](#node_local_repo_url)         | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | 本地源的URL地址|
| [node_packages](#node_packages)                     | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | 节点安装软件列表|
| [node_extra_packages](#node_extra_packages)         | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | C/I/A | 节点额外安装的软件列表|
| [node_meta_packages](#node_meta_packages)           | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | 元节点所需的软件列表|
| [node_meta_pip_install](#node_meta_pip_install)     | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | 元节点上通过pip3安装的软件包|
| [node_disable_numa](#node_disable_numa)             | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | 关闭节点NUMA|
| [node_disable_swap](#node_disable_swap)             | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | 关闭节点SWAP|
| [node_disable_firewall](#node_disable_firewall)     | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | 关闭节点防火墙|
| [node_disable_selinux](#node_disable_selinux)       | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | 关闭节点SELINUX|
| [node_static_network](#node_static_network)         | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | 是否使用静态DNS服务器|
| [node_disk_prefetch](#node_disk_prefetch)           | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | 是否启用磁盘预读|
| [node_kernel_modules](#node_kernel_modules)         | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | 启用的内核模块|
| [node_tune](#node_tune)                             | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | 节点调优模式|
| [node_sysctl_params](#node_sysctl_params)           | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | 操作系统内核参数|
| [node_admin_setup](#node_admin_setup)               | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | 是否创建管理员用户|
| [node_admin_uid](#node_admin_uid)                   | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | 管理员用户UID|
| [node_admin_username](#node_admin_username)         | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | 管理员用户名|
| [node_admin_ssh_exchange](#node_admin_ssh_exchange) | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | 在实例间交换管理员SSH密钥|
| [node_admin_pks](#node_admin_pks)                   | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | 可登陆管理员的公钥列表|
| [node_admin_pk_current](#node_admin_pk_current)     | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | A     | 是否将当前用户的公钥加入管理员账户|
| [node_ntp_service](#node_ntp_service)               | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | NTP服务类型：ntp或chrony|
| [node_ntp_config](#node_ntp_config)                 | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | 是否配置NTP服务？|
| [node_timezone](#node_timezone)                     | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | NTP时区设置|
| [node_ntp_servers](#node_ntp_servers)               | [node](https://github.com/Vonng/pigsty/tree/master/roles/node)                   | G     | NTP服务器列表|
| [service_registry](#service_registry)               | [consul](https://github.com/Vonng/pigsty/tree/master/roles/consul)               | G/C/I | 服务注册的位置|
| [dcs_type](#dcs_type)                               | [consul](https://github.com/Vonng/pigsty/tree/master/roles/consul)               | G     | 使用的DCS类型|
| [dcs_name](#dcs_name)                               | [consul](https://github.com/Vonng/pigsty/tree/master/roles/consul)               | G     | DCS集群名称|
| [dcs_servers](#dcs_servers)                         | [consul](https://github.com/Vonng/pigsty/tree/master/roles/consul)               | G     | DCS服务器名称:IP列表|
| [dcs_exists_action](#dcs_exists_action)             | [consul](https://github.com/Vonng/pigsty/tree/master/roles/consul)               | G/A   | 若DCS实例存在如何处理|
| [dcs_disable_purge](#dcs_disable_purge)             | [consul](https://github.com/Vonng/pigsty/tree/master/roles/consul)               | G/C/I | 完全禁止清理DCS实例|
| [consul_data_dir](#consul_data_dir)                 | [consul](https://github.com/Vonng/pigsty/tree/master/roles/consul)               | G     | Consul数据目录|
| [etcd_data_dir](#etcd_data_dir)                     | [consul](https://github.com/Vonng/pigsty/tree/master/roles/consul)               | G     | Etcd数据目录|
| [exporter_install](#exporter_install)               | [node_exporter](https://github.com/Vonng/pigsty/tree/master/roles/node_exporter) | G/C   | 安装监控组件的方式|
| [exporter_repo_url](#exporter_repo_url)             | [node_exporter](https://github.com/Vonng/pigsty/tree/master/roles/node_exporter) | G/C   | 监控组件的YumRepo|
| [exporter_metrics_path](#exporter_metrics_path)     | [node_exporter](https://github.com/Vonng/pigsty/tree/master/roles/node_exporter) | G/C   | 监控暴露的URL Path|
| [node_exporter_enabled](#node_exporter_enabled)     | [node_exporter](https://github.com/Vonng/pigsty/tree/master/roles/node_exporter) | G/C   | 启用节点指标收集器|
| [node_exporter_port](#node_exporter_port)           | [node_exporter](https://github.com/Vonng/pigsty/tree/master/roles/node_exporter) | G/C   | 节点指标暴露端口|
| [node_exporter_options](#node_exporter_options)     | [node_exporter](https://github.com/Vonng/pigsty/tree/master/roles/node_exporter) | G/C   | 节点指标采集选项|
| [promtail_enabled](#promtail_enabled)               | [promtail](https://github.com/Vonng/pigsty/tree/master/roles/promtail)           | G/C   | 是否启用Promtail日志收集服务|
| [promtail_clean](#promtail_clean)                   | [promtail](https://github.com/Vonng/pigsty/tree/master/roles/promtail)           | G/C/A | 是否在安装promtail时移除已有状态信息|
| [promtail_port](#promtail_port)                     | [promtail](https://github.com/Vonng/pigsty/tree/master/roles/promtail)           | G/C   | promtail使用的默认端口|
| [promtail_options](#promtail_options)               | [promtail](https://github.com/Vonng/pigsty/tree/master/roles/promtail)           | G/C   | promtail命令行参数|
| [promtail_positions](#promtail_positions)           | [promtail](https://github.com/Vonng/pigsty/tree/master/roles/promtail)           | G/C   | 保存Promtail状态信息的文件位置|
| [promtail_send_url](#promtail_send_url)             | [promtail](https://github.com/Vonng/pigsty/tree/master/roles/promtail)           | G/C   | 用于接收日志的loki服务endpoint|



## 节点身份参数

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








------------------

## `NODE`

<details>
<summary>NODE参数默认值</summary>

```yaml
meta_node: false                              # node with meta_node will be marked as admin nod

# - node identity - #
# nodename:                                   # if not provided, node's hostname will be use as nodename
nodename_overwrite: true                      # if set, node's hostname will be set to nodename
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
  - wget,sshpass,ntp,chrony,tuned,uuid,lz4,make,patch,bash,lsof,wget,unzip,git,ftp,vim-minimal
  - numactl,grubby,sysstat,dstat,iotop,bind-utils,net-tools,tcpdump,socat,ipvsadm,telnet,tuned,pv,jq,perf,ca-certificates
  - readline,zlib,openssl,openssl-libs,openssh-clients,python3,python36-requests,node_exporter,redis_exporter,consul,etcd,promtail
node_extra_packages: [ ]                      # extra packages for all nodes
node_meta_packages:                           # packages for meta nodes only
  - grafana,prometheus2,alertmanager,loki,nginx_exporter,blackbox_exporter,pushgateway,redis,postgresql14
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

</details>



### `meta_node`

Bool类型标记，元节点为真，其他节点为假。

在配置清单中，`meta`分组下的节点默认带有此标记。

带有此标记的节点会在节点置备时进行额外的配置：安装[`node_meta_packages`](#node_meta_packages)指定的RPM软件包，并安装[`node_meta_pip_install`](#node_meta_pip_install)指定的Python软件包。


### `nodename`

该选项可为节点显式指定名称，只可在节点实例层次定义。

在Pigsty中，主机名将被用作为节点身份标识的一部分，例如监控数据的`ins`标签。

备注：如果要使用PostgreSQL的实例名称作为节点名称，可以指定使用[`pg_hostname`](v-pgsql.md#pg_hostname)选项，则初始化节点时，PG实例名会被设置为 `nodename`。




### `nodename_overwrite`

布尔类型，默认为真，为真时，非空的节点名 [`nodename`](#nodename) 将覆盖节点的当前主机名称。

如果 [`nodename`](#nodename) 参数未定义，为空或为空字符串，则不会对主机名进行修改。



### `node_cluster`

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


### `node_dns_hosts`

机器节点的默认静态DNS解析记录，每一条记录都会在机器节点初始化时写入`/etc/hosts`中，特别适合在全局配置基础设施地址。

`node_dns_hosts`是一个数组，每一个元素都是形如`ip domain_name`的字符串，代表一条DNS解析记录。

默认情况下，Pigsty会向`/etc/hosts`中写入`10.10.10.10 yum.pigsty`，这样可以在DNS Nameserver启动之前，采用域名的方式访问本地yum源。


### `node_dns_hosts_extra`

形式与 [`node_dns_hosts`](#node_dns_hosts) 完全相同，但用于集群/实例层次。将会与[`node_dns_hosts`](#node_dns_hosts) 追加写入至`/etc/hosts`



### `node_dns_server`

机器节点默认的动态DNS服务器的配置方式，有三种模式：

* `add`：将`node_dns_servers`中的记录追加至`/etc/resolv.conf`，并保留已有DNS服务器。（默认）
* `overwrite`：使用将`node_dns_servers`中的记录覆盖`/etc/resolv.conf`
* `none`：跳过DNS服务器配置



### `node_dns_servers`

如果`node_dns_server`配置为`add`或`overwrite`，则`node_dns_servers`中的记录会被追加或覆盖至`/etc/resolv.conf`中。具体格式请参考Linux文档关于`/etc/resolv.conf`的说明。

Pigsty默认会添加元节点作为DNS Server，元节点上的DNSMASQ会响应环境中的DNS请求。

```
node_dns_servers: # dynamic nameserver in /etc/resolv.conf
  - 10.10.10.10
```



### `node_dns_options`

如果`node_dns_server`配置为`add`或`overwrite`，则`node_dns_options`中的记录会被追加或覆盖至`/etc/resolv.conf`中。具体格式请参考Linux文档关于`/etc/resolv.conf`的说明

Pigsty默认添加的解析选项为：

```bash
- options single-request-reopen timeout:1 rotate
- domain service.consul
```



### `node_repo_method`

机器节点Yum软件源的配置方式，有三种模式：

* `local`：使用元节点上的本地Yum源，默认行为，推荐。
* `public`：直接使用互联网源安装，将`repo_upstream`中的公共repo写入`/etc/yum.repos.d/`
* `none`：不对本地源进行配置与修改。



### `node_repo_remove`

原有Yum源的处理方式，是否移除节点上原有的Yum源？

Pigsty默认会**移除**`/etc/yum.repos.d`中原有的配置文件，并备份至`/etc/yum.repos.d/backup`



### `node_local_repo_url`

如果`node_repo_method`配置为`local`，则这里列出的Repo文件URL会被下载至`/etc/yum.repos.d`中

这里是一个Repo File URL 构成的数组，Pigsty默认会将元节点上的本地Yum源加入机器的源配置中。

```
node_local_repo_url:
  - http://yum.pigsty/pigsty.repo
```



### `node_packages`

通过yum安装的软件包列表。

软件包列表为数组，但每个元素可以包含由**逗号分隔**的多个软件包，Pigsty默认安装的软件包列表如下：

```yaml
node_packages:                                # common packages for all nodes
  - wget,sshpass,ntp,chrony,tuned,uuid,lz4,make,patch,bash,lsof,wget,unzip,git,ftp,vim-minimal
  - numactl,grubby,sysstat,dstat,iotop,bind-utils,net-tools,tcpdump,socat,ipvsadm,telnet,tuned,pv,jq,perf,ca-certificates
  - readline,zlib,openssl,openssl-libs,openssh-clients,python3,python36-requests,node_exporter,redis_exporter,consul,etcd,promtail
```



### `node_extra_packages`

通过yum安装的额外软件包列表，默认为空列表。

与[`node_packages`](#node_packages)类似，但`node_packages`通常是全局统一配置，而`node_extra_packages`则是针对具体节点进行例外处理。例如，您可以为运行PG的节点安装额外的工具包。该变量通常在集群和实例级别进行覆盖定义。



### `node_meta_packages`

通过yum安装的元节点软件包列表。

与[`node_packages`](#node_packages)和[`node_extra_packages`](#node_extra_packages)类似，但[`node_meta_packages`](#node_meta_packages)中列出的软件包只会在元节点上安装。
因此通常都是监控软件，管理工具，构建工具等。Pigsty默认安装的元节点软件包列表如下：

```yaml
node_meta_packages:                           # packages for meta nodes only
  - grafana,prometheus2,alertmanager,loki,nginx_exporter,blackbox_exporter,pushgateway,redis,postgresql14
  - nginx,ansible,pgbadger,python-psycopg2,dnsmasq,polysh,coreutils,diffutils
  # - clang,rpm-build,rpm-devel,rpmlint,rpmdevtools,bison,flex # gcc,gcc-c++
  # - readline-devel,zlib-devel,uuid-devel,libuuid-devel,libxml2-devel,libxslt-devel,openssl-devel,libicu-devel
```

### `node_meta_pip_install`

通过pip3安装的元节点软件包列表。

软件包会下载至`{{ repo_home }}/{{ repo_name }}/python`目录后统一安装。

目前默认会安装`jupyterlab`，提供完整的Python运行时环境。



### `node_disable_numa`

是否关闭Numa，注意，该选项需要重启机器后方可生效！

默认不禁用，如果您不清楚如何绑核，在生产环境使用数据库时建议关闭NUMA。



### `node_disable_swap`

是否禁用SWAP，默认不禁用。

通常情况下不建议关闭SWAP，如果您有足够的内存，且数据库采用独占式部署，则可以关闭SWAP提高性能。

当您的节点用于部署Kubernetes时，应当禁用SWAP。


### `node_disable_firewall`

是否关闭防火墙，建议关闭，默认关闭。



### `node_disable_selinux`

是否关闭SELinux，建议关闭，默认关闭。




### `node_static_network`

是否采用静态网络配置，默认启用

启用静态网络，意味着您的DNS Resolv配置不会因为机器重启与网卡变动被覆盖。建议启用。



### `node_disk_prefetch`

是否启用磁盘预读？

针对HDD部署的实例可以优化吞吐量，默认关闭。



### `node_kernel_modules`

需要安装的内核模块

Pigsty默认会启用以下内核模块

```
node_kernel_modules: [softdog, ip_vs, ip_vs_rr, ip_vs_rr, ip_vs_wrr, ip_vs_sh]
```



### `node_tune`

针对机器进行调优的预制方案，基于`tuned`服务。有四种预制模式：

* `tiny`：微型虚拟机
* `oltp`：常规OLTP模板，优化延迟
* `olap`：常规OLAP模板，优化吞吐量
* `crit`：核心金融业务模板，优化脏页数量

通常机器节点的调优需要与[数据库模版](t-patroni-template.md)相对应。



### `node_sysctl_params`

需要额外修改的操作系统内核参数

字典KV结构，Key为内核`sysctl`参数名，Value为参数值。



### `node_admin_setup`

是否在每个节点上创建管理员用户（免密sudo与ssh），默认会创建。

Pigsty默认会创建名为`admin (uid=88)`的管理用户，可以从元节点上通过SSH免密访问环境中的其他节点并执行免密sudo。



### `node_admin_uid`

管理员用户的`uid`，默认为`88`，分配时请注意UID命名空间冲突。




### `node_admin_username`

管理员用户的名称，默认为`dba`



### `node_admin_ssh_exchange`

是否在当前执行命令的机器之间相互交换管理员用户的SSH密钥？

默认会执行交换，这样管理员可以在机器间快速跳转。



### `node_admin_pks`

写入到管理员`~/.ssh/authorized_keys`中的密钥

持有对应私钥的用户可以以管理员身份登陆。



### `node_admin_pk_current`

布尔类型，通常用作命令行参数。用于将当前用户的SSH公钥（~/.ssh/id_rsa.pub）拷贝至管理员用户的`authorized_keys`中。默认不拷贝。



### `node_ntp_service`

指明系统使用的NTP服务类型：

* `ntp`：传统NTP服务
* `chrony`：CentOS 7/8默认使用的时间服务

默认使用 `ntp` 作为时间服务



### `node_ntp_config`

是否覆盖现有NTP配置？

布尔选项，默认覆盖（`true`）。



### `node_timezone`

默认使用的时区

Pigsty默认使用`Asia/Hong_Kong`，请根据您的实际情况调整。

> 请不要使用`Asia/Shanghai`时区，该时区缩写 CST 会导致一系列日志时区解析问题。

如果选择 `false`，则Pigsty不会修改该节点的时区配置。



### `node_ntp_servers`

NTP服务器地址

Pigsty默认会使用以下NTP服务器，其中`10.10.10.10`会被替换为管理节点的IP地址。

```ini
- pool cn.pool.ntp.org iburst
- pool pool.ntp.org iburst
- pool time.pool.aliyun.com iburst
- server 10.10.10.10 iburst
```







------------------

## `DCS`

<details>
<summary>DCS参数默认值</summary>

```yaml
#------------------------------------------------------------------------------
# DCS PROVISION
#------------------------------------------------------------------------------
service_registry: consul                      # where to register services: none | consul | etcd | both
dcs_type: consul                              # consul | etcd | both
dcs_name: pigsty                              # consul dc name | etcd initial cluster token
dcs_servers:                                  # dcs server dict in name:ip format
  meta-1: 10.10.10.10                         # you could use existing dcs cluster
  # meta-2: 10.10.10.11                       # host which have their IP listed here will be init as server
  # meta-3: 10.10.10.12                       # 3 or 5 dcs nodes are recommend for production environment
dcs_exists_action: clean                      # abort|skip|clean if dcs server already exists
dcs_disable_purge: false                      # set to true to disable purge functionality for good (force dcs_exists_action = abort)
consul_data_dir: /var/lib/consul              # consul data dir (/var/lib/consul by default)
etcd_data_dir: /var/lib/etcd                  # etcd data dir (/var/lib/consul by default)
```

</details>

Pigsty使用DCS（Distributive Configuration Storage）作为元数据库。DCS有三个重要作用：

* 主库选举：Patroni基于DCS进行选举与切换
* 配置管理：Patroni使用DCS管理Postgres的配置
* 身份管理：监控系统基于DCS管理并维护数据库实例的身份信息。

DCS对于数据库的稳定至关重要，Pigsty提供了基本的Consul与Etcd支持，默认在管理节点部署DCS服务。**在生产环境中建议使用专用机器部署多节点专用DCS集群**。


### `service_registry`

服务注册的地址，被多个组件引用。

* `none`：不执行服务注册（当执行**仅监控部署**时，必须指定`none`模式）
* `consul`：将服务注册至Consul中
* `etcd`：将服务注册至Etcd中（尚未支持）


### `dcs_type`

DCS类型，有两种选项：

* Consul

* Etcd （尚未正式支持）



### `dcs_name`

DCS集群名称，默认为`pigsty`，在Consul中代表 DataCenter名称



### `dcs_servers`

DCS服务器名称与地址，采用字典格式，Key为DCS服务器实例名称，Value为服务器IP地址。 默认情况下，Pigsty将在[节点初始化](p-nodes.md#nodes)剧本中为节点配置DCS服务，默认为Consul。

Pigsty默认在当前管理节点上部署**一个**DCS Server。当执行当 [`DCS`](#DCS) 角色时，如果当前节点定义于 [`dcs_servers`](#dcs_servers) 中，则该节点会被初始化为 DCS Server。

DCS Servers并不于管理节点绑定，您可以使用外部的已有DCS服务器（推荐），在这种情况下，直接填入外部DCS Server的地址即可。

如果您希望在管理节点，甚至普通节点上部署**复数个**DCS Servers，则进行任何新节点/数据库部署时，都应当确保



1. DCS Server已经全部完成初始化（超过法定人数的DCS Server Member在线，DCS服务才整体可用）
2. 当前

如果采用初始化新DCS实例的方式，建议先在所有DCS Server（通常也是元节点）上完成DCS初始化（[`infra.yml`](p-infra.md)）。

尽管您也可以一次性初始化所有的DCS Server与DCS Agent，但必须在完整初始化时将所有Server囊括在内。
此时所有IP地址匹配`dcs_servers`项的目标机器将会在DCS初始化过程中被初始化为DCS Server。

强烈建议使用奇数个DCS Server，演示环境可使用单个DCS Server，生产环境建议使用3～5个确保DCS可用性。

您必须根据实际情况显式配置DCS Server，例如在沙箱环境中，您可以选择启用1个或3个DCS节点。

```yaml
dcs_servers:
  meta-1: 10.10.10.10
  meta-2: 10.10.10.11 
  meta-3: 10.10.10.12 
```



### `dcs_exists_action`

安全保险，当Consul实例已经存在时，系统应当执行的动作

* `abort`: 中止整个剧本的执行（默认行为）
* `clean`: 抹除现有DCS实例并继续（极端危险）
* `skip`: 忽略存在DCS实例的目标（中止），在其他目标机器上继续执行。

如果您真的需要强制清除已经存在的DCS实例，建议先使用[`pgsql-remove.yml`](p-pgsql-remove.md)完成集群与实例的下线与销毁，再重新执行初始化。
否则需要通过命令行参数`-e dcs_exists_action=clean`完成覆写，强制在初始化过程中抹除已有实例。



### `dcs_disable_purge`

双重安全保险，默认为`false`。如果为`true`，强制设置`dcs_exists_action`变量为`abort`。

等效于关闭`dcs_exists_action`的清理功能，确保**任何情况**下DCS实例都不会被抹除。



### `consul_data_dir`

Consul数据目录地址，默认为`/var/lib/consul`。



### `etcd_data_dir`

Etcd数据目录地址，默认为`/var/lib/etcd`。




------------------

## `EXPORTER`

<details>
<summary>EXPORTER参数默认值</summary>

```yaml
# - exporter - #
exporter_install: none                        # none|yum|binary, none by default
exporter_repo_url: ''                         # if set, repo will be added to /etc/yum.repos.d/ before yum installation
exporter_metrics_path: /metrics               # default metric path for exporter
```

</details>

Exporter共享配置，[`exporter_metrics_path`](#exporter_metrics_path) 会控制包括 [`node_exporter`](#node-exporter), [pg_exporter](v-pgsql.md#pg-exporter), [pgbouncer_exporter](v-pgsql.md#pgbouncer-exporter), [haproxy](v-pgsql.md#haproxy) 等组件的指标URL PATH。
而 [`exporter_install`](#exporter_install) 与 [`exporter_repo_url`](#exporter_repo_url) 则用于控制大多数外置Exporter的安装方式。


### `exporter_install`

指明安装Exporter的方式：

* `none`：不安装，（默认行为，Exporter已经在先前由 `node.pkgs` 任务完成安装）
* `yum`：使用yum安装（如果启用yum安装，在部署Exporter前执行yum安装 `node_exporter` 与 `pg_exporter` ）
* `binary`：使用拷贝二进制的方式安装（从`files`中直接拷贝`node_exporter`与 `pg_exporter` 二进制）

使用`yum`安装时，如果指定了`exporter_repo_url`（不为空），在执行安装时会首先将该URL下的REPO文件安装至`/etc/yum.repos.d`中。这一功能可以在不执行节点基础设施初始化的环境下直接进行Exporter的安装。

使用`binary`安装时，用户需要确保已经将 `node_exporter` 与 `pg_exporter` 的Linux二进制程序放置在`files`目录中，正常情况不建议使用此种方式。

```bash
<meta>:<pigsty>/files/node_exporter ->  <target>:/usr/bin/node_exporter
<meta>:<pigsty>/files/pg_exporter   ->  <target>:/usr/bin/pg_exporter
```

### `exporter_repo_url`

包含有Node|PG Exporter监控组件的YUM源 Repo 文件的URL。

默认为空，当 [`exporter_install`](#exporter_install) 为 `yum` 时，该参数指定的Repo会被添加至操作系统中。



### `exporter_metrics_path`

所有Exporter对外暴露指标的URL PATH，默认为`/metrics`

该变量被外部角色[`prometheus`](v-infra.md#prometheus)引用，Prometheus会根据这里的配置，对监控对象应用此配置。




------------------

## `NODE` EXPORTER

<details>
<summary>NODE EXPORTER参数默认值</summary>

```yaml
# - node exporter - #
node_exporter_enabled: true                   # setup node_exporter on instance
node_exporter_port: 9100                      # default port for node exporter
node_exporter_options: '--no-collector.softnet --no-collector.nvme --collector.ntp --collector.tcpstat --collector.processes'
```

</details>

Exporter共享配置


### `node_exporter_enabled`

布尔类型，是否在当前节点上安装并配置 [`node_exporter`](#node-exporter)，默认为`true`


### `node_exporter_port`

在当前节点上，[`node_exporter`](#node-exporter) 监听的端口，默认使用`9100`端口。


### `node_exporter_options`

[`node_exporter`](#node-exporter) 二进制执行时，额外传入的命令行参数。

该选项主要用于定制 `node_exporter` 启用的指标收集器，Node Exporter支持的收集器列表可以参考：[Node Exporter Collectors](https://github.com/prometheus/node_exporter#collectors)

该选项的默认值将启用额外的`ntp`, `tcpstat`, `processes`三个收集器，并禁用 `nvme` 与 `softnet`两个收集器。 






------------------

## `PROMTAIL`

<details>
<summary>PROMTAIL参数默认值</summary>

```yaml
# - promtail - #                              # promtail is a beta feature which requires manual deployment
promtail_enabled: true                        # enable promtail logging collector?
promtail_clean: false                         # remove promtail status file? false by default
promtail_port: 9080                           # default listen address for promtail
promtail_options: '-config.file=/etc/promtail.yml -config.expand-env=true'
promtail_positions: /var/log/positions.yaml   # position status for promtail
promtail_send_url: http://10.10.10.10:3100/loki/api/v1/push  # loki url to receive logs
```

</details>


### `promtail_enabled`

布尔类型，是否在当前节点启用Promtail日志收集服务？默认启用。

启用 [`promtail`](#promtail) 后，Pigsty会根据配置清单中的定义，生成Promtail的配置文件，抓取下列日志并发送至由[`promtail_send_url`](#promtail_send_url)指定的Loki实例。

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

布尔类型，命令行参数。是否在安装promtail时移除已有状态信息？状态文件记录在[`promtail_positions`](#promtail_positions) 中，记录了所有日志的消费偏移量，默认不会清理。

当您选择清理时，Promtail会重新收集当前节点上的所有日志并发送至Loki。


### `promtail_port`

promtail使用的默认端口，默认为9080。



### `promtail_options`

运行promtail二进制程序时传入的额外命令行参数，默认值为`'-config.file=/etc/promtail.yml -config.expand-env=true'`。

已有参数用于指定配置文件路径，并在配置文件中展开环境变量，不建议修改已有参数。


### `promtail_positions`

字符串类型，集群｜全局变量，用于配置Promtail保存日志消费偏移量的状态文件，不建议修改。默认值为 `/var/log/positions.yaml`。



### `promtail_send_url`

用于接收Promtail发送日志的Loki端点

默认值为：`http://10.10.10.10:3100/loki/api/v1/push`，即管理节点上部署的Loki实例，其中IP地址`10.10.10.10`会在`configure`过程中被替换。



