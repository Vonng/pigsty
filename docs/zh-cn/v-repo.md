# 本地仓库

Pigsty是一个复杂的软件系统，为了确保系统的稳定，Pigsty会在初始化过程中从互联网下载所有依赖的软件包并建立本地Yum源。

所有依赖的软件总大小约1GB左右，下载速度取决于您的网络情况。尽管Pigsty已经尽量使用镜像源以加速下载，但少量包的下载仍可能受到防火墙的阻挠，可能出现非常慢的情况。您可以通过`proxy_env`配置项设置下载代理以完成首次下载，或直接下载预先打包好的**离线安装包**。

建立本地Yum源时，如果`{{ repo_home }}/{{ repo_name }}`目录已经存在，而且里面有`repo_complete`的标记文件，Pigsty会认为本地Yum源已经初始化完毕，因此跳过软件下载阶段，显著加快速度。离线安装包即是把`{{ repo_home }}/{{ repo_name }}`目录整个打成压缩包。

## 参数概览

|                  名称                   |    类型    | 层级 | 说明                  |
| :-------------------------------------: | :--------: | :--: | --------------------- |
|      [repo_enabled](#repo_enabled)      |   `bool`   |  G   | 是否启用本地源        |
|         [repo_name](#repo_name)         |  `string`  |  G   | 本地源名称            |
|      [repo_address](#repo_address)      |  `string`  |  G   | 本地源外部访问地址    |
|         [repo_port](#repo_port)         |  `number`  |  G   | 本地源端口            |
|         [repo_home](#repo_home)         |  `string`  |  G   | 本地源文件根目录      |
|      [repo_rebuild](#repo_rebuild)      |   `bool`   |  A   | 是否重建Yum源         |
|       [repo_remove](#repo_remove)       |   `bool`   |  A   | 是否移除已有Yum源     |
|    [repo_upstreams](#repo_upstreams)    | `object[]` |  G   | Yum源的上游来源       |
|     [repo_packages](#repo_packages)     | `string[]` |  G   | Yum源需下载软件列表   |
| [repo_url_packages](#repo_url_packages) | `string[]` |  G   | 通过URL直接下载的软件 |

## 默认参数

```yaml
repo_enabled: true                            # 是否启用本地源功能
repo_name: pigsty                             # 本地源名称
repo_address: yum.pigsty                      # 外部可访问的源地址 (ip:port 或 url)
repo_port: 80                                 # 源HTTP服务器监听地址
repo_home: /www                               # 默认根目录
repo_rebuild: false                           # 强制重新下载软件包
repo_remove: true                             # 移除已有的yum源
repo_upstreams: [...]                         # 上游Yum源
repo_packages: [...]                          # 需要下载的软件包
repo_url_packages: [...]                      # 通过URL下载的软件
```



## 参数详解

### repo_enabled

如果为`true`（默认情况），执行正常的本地yum源创建流程，否则跳过构建本地yum源的操作。



### repo_name

本地yum源的**名称**，默认为`pigsty`，您可以改为自己喜欢的名称，例如`pgsql-rhel7`等。



### repo_address

本地yum源对外提供服务的地址，可以是域名也可以是IP地址，默认为`yum.pigsty`。

如果使用域名，您必须确保在当前环境中该域名会解析到本地源所在的服务器，也就是元节点。

如果您的本地yum源没有使用标准的80端口，您需要在地址中加入端口，并与`repo_port`变量保持一致。

您可以通过[节点](/zh/docs/deploy/config/3-node/)参数中的静态DNS配置来为环境中的所有节点写入`Pigsty`本地源的域名，沙箱环境中即是采用这种方式来解析默认的`yum.pigsty`域名。



### repo_port

本地yum源使用的HTTP端口，默认为80端口。



### repo_home

本地yum源的根目录，默认为`www`。

该目录将作为HTTP服务器的根对外暴露。



### repo_rebuild

如果为`false`（默认情况），什么都不发生，如果为`true`，那么在任何情况下都会执行Repo重建的工作。



### repo_remove

在执行本地源初始化的过程中，是否移除`/etc/yum.repos.d`中所有已有的repo？默认为`true`。

原有repo文件会备份至`/etc/yum.repos.d/backup`中。

因为操作系统已有的源内容不可控，建议强制移除并通过`repo_upstreams`进行显式配置。



### repo_upstream

所有添加到`/etc/yum.repos.d`中的Yum源，Pigsty将从这些源中下载软件。

Pigsty默认使用阿里云的CentOS7镜像源，清华大学Grafana镜像源，PackageCloud的Prometheus源，PostgreSQL官方源，以及SCLo，Harbottle，Nginx, Haproxy等软件源。

```yaml
- name: base
  description: CentOS-$releasever - Base - Aliyun Mirror
  baseurl:
    - http://mirrors.aliyun.com/centos/$releasever/os/$basearch/
    - http://mirrors.aliyuncs.com/centos/$releasever/os/$basearch/
    - http://mirrors.cloud.aliyuncs.com/centos/$releasever/os/$basearch/
  gpgcheck: no
  failovermethod: priority

- name: updates
  description: CentOS-$releasever - Updates - Aliyun Mirror
  baseurl:
    - http://mirrors.aliyun.com/centos/$releasever/updates/$basearch/
    - http://mirrors.aliyuncs.com/centos/$releasever/updates/$basearch/
    - http://mirrors.cloud.aliyuncs.com/centos/$releasever/updates/$basearch/
  gpgcheck: no
  failovermethod: priority

- name: extras
  description: CentOS-$releasever - Extras - Aliyun Mirror
  baseurl:
    - http://mirrors.aliyun.com/centos/$releasever/extras/$basearch/
    - http://mirrors.aliyuncs.com/centos/$releasever/extras/$basearch/
    - http://mirrors.cloud.aliyuncs.com/centos/$releasever/extras/$basearch/
  gpgcheck: no
  failovermethod: priority

- name: epel
  description: CentOS $releasever - EPEL - Aliyun Mirror
  baseurl: http://mirrors.aliyun.com/epel/$releasever/$basearch
  gpgcheck: no
  failovermethod: priority

- name: grafana
  description: Grafana - TsingHua Mirror
  gpgcheck: no
  baseurl: https://mirrors.tuna.tsinghua.edu.cn/grafana/yum/rpm

- name: prometheus
  description: Prometheus and exporters
  gpgcheck: no
  baseurl: https://packagecloud.io/prometheus-rpm/release/el/$releasever/$basearch

- name: pgdg-common
  description: PostgreSQL common RPMs for RHEL/CentOS $releasever - $basearch
  gpgcheck: no
  baseurl: https://download.postgresql.org/pub/repos/yum/common/redhat/rhel-$releasever-$basearch

- name: pgdg13
  description: PostgreSQL 13 for RHEL/CentOS $releasever - $basearch - Updates testing
  gpgcheck: no
  baseurl: https://download.postgresql.org/pub/repos/yum/13/redhat/rhel-$releasever-$basearch

- name: centos-sclo
  description: CentOS-$releasever - SCLo
  gpgcheck: no
  mirrorlist: http://mirrorlist.centos.org?arch=$basearch&release=7&repo=sclo-sclo

- name: centos-sclo-rh
  description: CentOS-$releasever - SCLo rh
  gpgcheck: no
  mirrorlist: http://mirrorlist.centos.org?arch=$basearch&release=7&repo=sclo-rh

- name: nginx
  description: Nginx Official Yum Repo
  skip_if_unavailable: true
  gpgcheck: no
  baseurl: http://nginx.org/packages/centos/$releasever/$basearch/

- name: haproxy
  description: Copr repo for haproxy
  skip_if_unavailable: true
  gpgcheck: no
  baseurl: https://download.copr.fedorainfracloud.org/results/roidelapluie/haproxy/epel-$releasever-$basearch/

# for latest consul & kubernetes
- name: harbottle
  description: Copr repo for main owned by harbottle
  skip_if_unavailable: true
  gpgcheck: no
  baseurl: https://download.copr.fedorainfracloud.org/results/harbottle/main/epel-$releasever-$basearch/

```



### repo_packages

需要下载的rpm安装包列表，默认下载的软件包如下所示：

```yaml
# - what to download - #
repo_packages:
  # repo bootstrap packages
  - epel-release nginx wget yum-utils yum createrepo                                      # bootstrap packages

  # node basic packages
  - ntp chrony uuid lz4 nc pv jq vim-enhanced make patch bash lsof wget unzip git tuned   # basic system util
  - readline zlib openssl libyaml libxml2 libxslt perl-ExtUtils-Embed ca-certificates     # basic pg dependency
  - numactl grubby sysstat dstat iotop bind-utils net-tools tcpdump socat ipvsadm telnet  # system utils

  # dcs & monitor packages
  - grafana prometheus2 pushgateway alertmanager                                          # monitor and ui
  - node_exporter postgres_exporter nginx_exporter blackbox_exporter                      # exporter
  - consul consul_exporter consul-template etcd                                           # dcs

  # python3 dependencies
  - ansible python python-pip python-psycopg2                                             # ansible & python
  - python3 python3-psycopg2 python36-requests python3-etcd python3-consul                # python3
  - python36-urllib3 python36-idna python36-pyOpenSSL python36-cryptography               # python3 patroni extra deps

  # proxy and load balancer
  - haproxy keepalived dnsmasq                                                            # proxy and dns

  # postgres common Packages
  - patroni patroni-consul patroni-etcd pgbouncer pg_cli pgbadger pg_activity               # major components
  - pgcenter boxinfo check_postgres emaj pgbconsole pg_bloat_check pgquarrel                # other common utils
  - barman barman-cli pgloader pgFormatter pitrery pspg pgxnclient PyGreSQL pgadmin4 tail_n_mail

  # postgres 13 packages
  - postgresql13* postgis31* citus_13 pgrouting_13                                          # postgres 13 and postgis 31
  - pg_repack13 pg_squeeze13                                                                # maintenance extensions
  - pg_qualstats13 pg_stat_kcache13 system_stats_13 bgw_replstatus13                        # stats extensions
  - plr13 plsh13 plpgsql_check_13 plproxy13 plr13 plsh13 plpgsql_check_13 pldebugger13      # PL extensions                                      # pl extensions
  - hdfs_fdw_13 mongo_fdw13 mysql_fdw_13 ogr_fdw13 redis_fdw_13 pgbouncer_fdw13             # FDW extensions
  - wal2json13 count_distinct13 ddlx_13 geoip13 orafce13                                    # MISC extensions
  - rum_13 hypopg_13 ip4r13 jsquery_13 logerrors_13 periods_13 pg_auto_failover_13 pg_catcheck13
  - pg_fkpart13 pg_jobmon13 pg_partman13 pg_prioritize_13 pg_track_settings13 pgaudit15_13
  - pgcryptokey13 pgexportdoc13 pgimportdoc13 pgmemcache-13 pgmp13 pgq-13
  - pguint13 pguri13 prefix13  safeupdate_13 semver13  table_version13 tdigest13
```



### repo_url_packages

采用URL直接下载，而非yum下载的软件包。您可以将自定义的软件包连接添加到这里。

Pigsty默认会通过URL下载三款软件：

* `pg_exporter`（必须，监控系统核心组件）
* `vip-manager`（可选，启用VIP时必须）
* `polysh`（可选，多机管理便捷工具）

```yaml
repo_url_packages:
  - https://github.com/Vonng/pg_exporter/releases/download/v0.3.1/pg_exporter-0.3.1-1.el7.x86_64.rpm
  - https://github.com/cybertec-postgresql/vip-manager/releases/download/v0.6/vip-manager_0.6-1_amd64.rpm
  - http://guichaz.free.fr/polysh/files/polysh-0.4-1.noarch.rpm
```



