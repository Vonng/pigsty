# 配置：Infra

> 使用 [INFRA剧本](p-pgsql.md)，[部署PGSQL](d-pgsql.md)集群，将集群状态调整至 [PGSQL配置](v-pgsql.md)所描述的状态。
>
> 配置Pigsty基础设施，由[INFRA](p-infra.md)系列剧本使用。

基础设施配置主要处理此类问题：本地Yum源，机器节点基础服务：DNS，NTP，内核模块，参数调优，管理用户，安装软件包，DCS Server的架设，监控基础设施的安装与初始化（Grafana，Prometheus，Alertmanager），全局流量入口Nginx的配置等等。

通常来说，基础设施部分需要修改的内容很少，通常涉及到的主要修改只是对元节点的IP地址进行文本替换，这一步会在[`./configure`](v-config.md#配置过程)过程中自动完成，另一处偶尔需要改动的地方是 [`nginx_upstream`](nginx_upstream)中定义的访问域名。其他参数很少需要调整，按需即可。



- [`CONNECT`](#CONNECT) : 连接参数
- [`REPO`](#REPO) : 本地源基础设施
- [`CA`](#CA) : 公私钥基础设施
- [`NGINX`](#NGINX) : NginxWeb服务器
- [`NAMESERVER`](#NAMESERVER) : DNS服务器
- [`PROMETHEUS`](#PROMETHEUS) : 监控时序数据库
- [`EXPORTER`](#EXPORTER) : 通用Exporter配置
- [`GRAFANA`](#GRAFANA) : Grafana可视化平台
- [`LOKI`](#LOKI) : Loki日志收集平台
- [`DCS`](#DCS) : 分布式配置存储元数据库
- [`JUPYTER`](#JUPYTER) : JupyterLab数据分析环境
- [`PGWEB`](#PGWEB) : PGWeb网页客户端工具


## 参数概览

部署于元节点上的 [**基础设施**](c-arch.md#基础设施) 由下列配置项所描述。

| ID  |                            Name                             |           Section           |    Type    | Level |            Comment             |
|-----|-------------------------------------------------------------|-----------------------------|------------|-------|--------------------------------|
| 100 | [`proxy_env`](#proxy_env)                                   | [`CONNECT`](#CONNECT)       | dict       | G     | 代理服务器配置                 |
| 110 | [`repo_enabled`](#repo_enabled)                             | [`REPO`](#REPO)             | bool       | G     | 是否启用本地源                 |
| 111 | [`repo_name`](#repo_name)                                   | [`REPO`](#REPO)             | string     | G     | 本地源名称                     |
| 112 | [`repo_address`](#repo_address)                             | [`REPO`](#REPO)             | string     | G     | 本地源外部访问地址             |
| 113 | [`repo_port`](#repo_port)                                   | [`REPO`](#REPO)             | int        | G     | 本地源端口                     |
| 114 | [`repo_home`](#repo_home)                                   | [`REPO`](#REPO)             | path       | G     | 本地源文件根目录               |
| 115 | [`repo_rebuild`](#repo_rebuild)                             | [`REPO`](#REPO)             | bool       | A     | 是否重建Yum源                  |
| 116 | [`repo_remove`](#repo_remove)                               | [`REPO`](#REPO)             | bool       | A     | 是否移除已有REPO文件           |
| 117 | [`repo_upstreams`](#repo_upstreams)                         | [`REPO`](#REPO)             | repo[]     | G     | Yum源的上游来源                |
| 118 | [`repo_packages`](#repo_packages)                           | [`REPO`](#REPO)             | string[]   | G     | Yum源需下载软件列表            |
| 119 | [`repo_url_packages`](#repo_url_packages)                   | [`REPO`](#REPO)             | url[]      | G     | 通过URL直接下载的软件          |
| 120 | [`ca_method`](#ca_method)                                   | [`CA`](#CA)                 | enum       | G     | CA的创建方式                   |
| 121 | [`ca_subject`](#ca_subject)                                 | [`CA`](#CA)                 | string     | G     | 自签名CA主题                   |
| 122 | [`ca_homedir`](#ca_homedir)                                 | [`CA`](#CA)                 | path       | G     | CA证书根目录                   |
| 123 | [`ca_cert`](#ca_cert)                                       | [`CA`](#CA)                 | string     | G     | CA证书                         |
| 124 | [`ca_key`](#ca_key)                                         | [`CA`](#CA)                 | string     | G     | CA私钥名称                     |
| 130 | [`nginx_upstream`](#nginx_upstream)                         | [`NGINX`](#NGINX)           | upstream[] | G     | Nginx上游服务器                |
| 131 | [`app_list`](#app_list)                                     | [`NGINX`](#NGINX)           | app[]      | G     | 首页导航栏显示的应用列表       |
| 132 | [`docs_enabled`](#docs_enabled)                             | [`NGINX`](#NGINX)           | bool       | G     | 是否启用本地文档               |
| 133 | [`pev2_enabled`](#pev2_enabled)                             | [`NGINX`](#NGINX)           | bool       | G     | 是否启用PEV2组件               |
| 134 | [`pgbadger_enabled`](#pgbadger_enabled)                     | [`NGINX`](#NGINX)           | bool       | G     | 是否启用Pgbadger               |
| 140 | [`dns_records`](#dns_records)                               | [`NAMESERVER`](#NAMESERVER) | string[]   | G     | 动态DNS解析记录                |
| 150 | [`prometheus_data_dir`](#prometheus_data_dir)               | [`PROMETHEUS`](#PROMETHEUS) | path       | G     | Prometheus数据库目录           |
| 151 | [`prometheus_options`](#prometheus_options)                 | [`PROMETHEUS`](#PROMETHEUS) | string     | G     | Prometheus命令行参数           |
| 152 | [`prometheus_reload`](#prometheus_reload)                   | [`PROMETHEUS`](#PROMETHEUS) | bool       | A     | Reload而非Recreate             |
| 153 | [`prometheus_sd_method`](#prometheus_sd_method)             | [`PROMETHEUS`](#PROMETHEUS) | enum       | G     | 服务发现机制：static|
| 154 | [`prometheus_scrape_interval`](#prometheus_scrape_interval) | [`PROMETHEUS`](#PROMETHEUS) | interval   | G     | Prom抓取周期                   |
| 155 | [`prometheus_scrape_timeout`](#prometheus_scrape_timeout)   | [`PROMETHEUS`](#PROMETHEUS) | interval   | G     | Prom抓取超时                   |
| 156 | [`prometheus_sd_interval`](#prometheus_sd_interval)         | [`PROMETHEUS`](#PROMETHEUS) | interval   | G     | Prom服务发现刷新周期           |
| 160 | [`exporter_install`](#exporter_install)                     | [`EXPORTER`](#EXPORTER)     | enum       | G     | 安装监控组件的方式             |
| 161 | [`exporter_repo_url`](#exporter_repo_url)                   | [`EXPORTER`](#EXPORTER)     | string     | G     | 监控组件的YumRepo              |
| 162 | [`exporter_metrics_path`](#exporter_metrics_path)           | [`EXPORTER`](#EXPORTER)     | string     | G     | 监控暴露的URL Path             |
| 170 | [`grafana_endpoint`](#grafana_endpoint)                     | [`GRAFANA`](#GRAFANA)       | url        | G     | Grafana地址                    |
| 171 | [`grafana_admin_username`](#grafana_admin_username)         | [`GRAFANA`](#GRAFANA)       | string     | G     | Grafana管理员用户名            |
| 172 | [`grafana_admin_password`](#grafana_admin_password)         | [`GRAFANA`](#GRAFANA)       | string     | G     | Grafana管理员密码              |
| 173 | [`grafana_database`](#grafana_database)                     | [`GRAFANA`](#GRAFANA)       | enum       | G     | Grafana后端数据库类型          |
| 174 | [`grafana_pgurl`](#grafana_pgurl)                           | [`GRAFANA`](#GRAFANA)       | url        | G     | Grafana的PG数据库连接串        |
| 175 | [`grafana_plugin`](#grafana_plugin)                         | [`GRAFANA`](#GRAFANA)       | enum       | G     | 如何安装Grafana插件            |
| 176 | [`grafana_cache`](#grafana_cache)                           | [`GRAFANA`](#GRAFANA)       | path       | G     | Grafana插件缓存地址            |
| 177 | [`grafana_plugins`](#grafana_plugins)                       | [`GRAFANA`](#GRAFANA)       | string[]   | G     | 安装的Grafana插件列表          |
| 178 | [`grafana_git_plugins`](#grafana_git_plugins)               | [`GRAFANA`](#GRAFANA)       | url[]      | G     | 从Git安装的Grafana插件         |
| 180 | [`loki_endpoint`](#loki_endpoint)                           | [`LOKI`](#LOKI)             | url        | G     | 用于接收日志的loki服务endpoint |
| 181 | [`loki_clean`](#loki_clean)                                 | [`LOKI`](#LOKI)             | bool       | A     | 是否在安装Loki时清理数据库目录 |
| 182 | [`loki_options`](#loki_options)                             | [`LOKI`](#LOKI)             | string     | G     | Loki的命令行参数               |
| 183 | [`loki_data_dir`](#loki_data_dir)                           | [`LOKI`](#LOKI)             | string     | G     | Loki的数据目录                 |
| 184 | [`loki_retention`](#loki_retention)                         | [`LOKI`](#LOKI)             | interval   | G     | Loki日志默认保留天数           |
| 200 | [`dcs_servers`](#dcs_servers)                               | [`DCS`](#DCS)               | dict       | G     | DCS服务器名称:IP列表           |
| 201 | [`service_registry`](#service_registry)                     | [`DCS`](#DCS)               | enum       | G     | 服务注册的位置                 |
| 202 | [`dcs_type`](#dcs_type)                                     | [`DCS`](#DCS)               | enum       | G     | 使用的DCS类型                  |
| 203 | [`dcs_name`](#dcs_name)                                     | [`DCS`](#DCS)               | string     | G     | DCS集群名称                    |
| 204 | [`dcs_exists_action`](#dcs_exists_action)                   | [`DCS`](#DCS)               | enum       | C/A   | 若DCS实例存在如何处理          |
| 205 | [`dcs_disable_purge`](#dcs_disable_purge)                   | [`DCS`](#DCS)               | bool       | C/A   | 完全禁止清理DCS实例            |
| 206 | [`consul_data_dir`](#consul_data_dir)                       | [`DCS`](#DCS)               | string     | G     | Consul数据目录                 |
| 207 | [`etcd_data_dir`](#etcd_data_dir)                           | [`DCS`](#DCS)               | string     | G     | Etcd数据目录                   |
| 220 | [`jupyter_enabled`](#jupyter_enabled)                       | [`JUPYTER`](#JUPYTER)       | bool       | G     | 是否启用JupyterLab             |
| 221 | [`jupyter_username`](#jupyter_username)                     | [`JUPYTER`](#JUPYTER)       | bool       | G     | Jupyter使用的操作系统用户      |
| 222 | [`jupyter_password`](#jupyter_password)                     | [`JUPYTER`](#JUPYTER)       | bool       | G     | Jupyter Lab的密码              |
| 230 | [`pgweb_enabled`](#pgweb_enabled)                           | [`PGWEB`](#PGWEB)           | bool       | G     | 是否启用PgWeb                  |
| 231 | [`pgweb_username`](#pgweb_username)                         | [`PGWEB`](#PGWEB)           | bool       | G     | PgWeb使用的操作系统用户        |




----------------

## `CONNECT`


### `proxy_env`

在某些受到“互联网封锁”的地区，有些软件的下载会受到影响。例如从中国大陆访问PostgreSQL的官方源，下载速度可能只有几KB每秒。

但如果使用了合适的HTTP代理，则可以达到几MB每秒。因此如果用户有代理服务器，请通过`proxy_env`进行配置，样例如下：

```yaml
proxy_env: # global proxy env when downloading packages
  http_proxy: 'http://username:password@proxy.address.com'
  https_proxy: 'http://username:password@proxy.address.com'
  all_proxy: 'http://username:password@proxy.address.com'
  no_proxy: "localhost,127.0.0.1,10.0.0.0/8,192.168.0.0/16,*.pigsty,*.aliyun.com,mirrors.aliyuncs.com,mirrors.tuna.tsinghua.edu.cn,mirrors.zju.edu.cn"
```



### `ansible_host`

如果您的目标机器藏在SSH跳板机之后，或者进行了某些定制化修改无法通过`ssh ip`的方式直接访问，则可以考虑使用 **Ansible连接参数**。

例如下面的例子中，[`ansible_host`](v-infra.md#ansible_host) 通过SSH别名的方式告知Pigsty通过`ssh node-1` 的方式而不是`ssh 10.10.10.11`的方式访问目标数据库节点。通过这种方式，用户可以自由指定数据库节点的连接方式，并将连接配置保存在管理用户的`~/.ssh/config`中独立管理。

```yaml
  pg-test:
    vars: { pg_cluster: pg-test }
    hosts:
      10.10.10.11: {pg_seq: 1, pg_role: primary, ansible_host: node-1}
      10.10.10.12: {pg_seq: 2, pg_role: replica, ansible_host: node-2}
      10.10.10.13: {pg_seq: 3, pg_role: offline, ansible_host: node-3}
```

`ansible_host`是ansible连接参数中最典型的一个。通常只要用户可以通过 `ssh <name>`的方式访问目标机器，为实例配置`ansible_host`变量，值为`<name>`即可，其他常用的Ansible SSH连接参数如下所示：

> - ansible_host :   在此指定目标机器的IP、主机名或SSH别名
>
> - ansible_port :   指定一个不同于22的SSH端口
>
> - ansible_user :   指定SSH使用的用户名
>
> - ansible_ssh_pass :   SSH密码（请不要存储明文，可通过-k参数指定从键盘输入）
>
> - ansible_ssh_private_key_file :    SSH私钥路径
>
> - ansible_ssh_common_args :   SSH通用参数
>





----------------
## `REPO`

当在元节点上安装Pigsty时，Pigsty会在本地拉起一个YUM软件源，供当前环境安装RPM软件包使用。

Pigsty在初始化过程中，会从互联网上游源（由 [`repo_upstreams`](#repo_upstreams)指定）， 下载所有软件包及其依赖（由 [`repo_packages`](#repo_packages)指定）至 [`{{ repo_home }}`](#repo_home) / [`{{ repo_name }}`](#repo_name)  （默认为`/www/pigsty`）。所有依赖的软件总大小约1GB左右，下载速度取决于您的网络情况。

建立本地Yum源时，如果该目录已经存在，而且目录中存在名为`repo_complete`的标记文件，Pigsty会认为本地Yum源已经初始化完毕，跳过软件下载阶段。

尽管Pigsty已经尽量使用镜像源以加速下载，但少量包的下载仍可能受到防火墙的阻挠。如果某些软件包的下载速度过慢，您可以通过[`proxy_env`](#proxy_env)配置项设置下载代理以完成首次下载，或直接下载预先打包好的[离线安装包](t-offline.md)。

离线安装包即是把`{{ repo_home }}/{{ repo_name }}`目录整个打成压缩包`pkg.tgz`。在`configure`过程中，如果Pigsty发现离线软件包`/tmp/pkg.tgz`存在，则会将其解压至`{{ repo_home }}/{{ repo_name }}`目录，进而在安装时跳过软件下载的步骤。

默认的离线安装包基于CentOS 7.8.2003 x86_64操作系统制作，如果您使用的操作系统与此不同，或并非使用全新安装的操作系统环境，则有概率出现RPM软件包冲突与依赖错误的问题，请参照FAQ解决。


### `repo_enabled`

是否启用本地源, 类型：`bool`，层级：G，默认值为：`true`

执行正常的本地YUM源创建流程，设置为`false`则会在当前节点跳过构建本地源的操作。当您有多个元节点时，可以在备用元节点上设置此参数为`false`。



### `repo_name`

本地源名称, 类型：`string`，层级：G，默认值为：`"pigsty"`，不建议修改此参数。




### `repo_address`

本地源外部访问地址, 类型：`string`，层级：G，默认值为：`"pigsty"`

本地yum源对外提供服务的地址，可以是域名也可以是IP地址，默认为`yum.pigsty`。

如果使用域名，您必须确保在当前环境中，该域名会正确解析到本地源所在的服务器，也就是元节点。

如果您的本地yum源没有使用标准的80端口，您需要在地址中加入端口，并与 [`repo_port`](#repo_port) 变量保持一致。

您可以通过[节点](v-nodes.md)参数中的静态DNS配置 [`node_dns_hosts`](v-nodes.md#node_dns_hosts)) 来为当前环境中的所有节点默认写入`pigsty`本地源域名。




### `repo_port`

本地源端口, 类型：`int`，层级：G，默认值为：`80`

Pigsty通过元节点上的该端口访问所有Web服务，请确保您可以访问元节点上的该端口。



### `repo_home`

本地源文件根目录, 类型：`path`，层级：G，默认值为：`"/www"`

该目录将作为HTTP服务器的根对外暴露，包含本地源，以及其他静态文件内容。



### `repo_rebuild`

是否重建Yum源, 类型：`bool`，层级：A，默认值为：`false`

如果为`true`，那么在任何情况下都会执行Repo重建的工作，即无视离线软件包存在与否。



### `repo_remove`

是否移除已有REPO文件, 类型：`bool`，层级：A，默认值为：`true`

如果为真，在执行本地源初始化的过程中，元节点上`/etc/yum.repos.d`中所有已有的repo会被全部移除，备份至`/etc/yum.repos.d/backup` 目录中。

因为操作系统已有的源内容不可控，建议强制移除已有源并通过 [`repo_upstreams`](#repo_upstreams) 进行显式配置。

当您的节点有其他自行配置的源，或需要从特定源下载一些特殊版本的RPM包时，可以设置为`false`，保留已有源。



### `repo_upstreams`

Yum源的上游来源, 类型：`repo[]`，层级：

默认使用阿里云的CentOS7镜像源，清华大学Grafana镜像源，PackageCloud的Prometheus源，PostgreSQL官方源，以及SCLo，Harbottle，Nginx等软件源。




### `repo_packages`

Yum源需下载软件列表, 类型：`string[]`，层级：G，默认值为：

```yaml
  - epel-release nginx wget yum-utils yum createrepo sshpass zip unzip
  - ntp chrony uuid lz4 bzip2 nc pv jq vim-enhanced make patch bash lsof wget git tuned perf ftp lrzsz rsync
  - numactl grubby sysstat dstat iotop bind-utils net-tools tcpdump socat ipvsadm telnet ca-certificates keepalived
  - readline zlib openssl openssh-clients libyaml libxml2 libxslt libevent perl perl-devel perl-ExtUtils*
  - readline-devel zlib-devel uuid-devel libuuid-devel libxml2-devel libxslt-devel openssl-devel libicu-devel
  - ed mlocate parted krb5-devel apr apr-util audit
  - grafana prometheus2 pushgateway alertmanager consul consul_exporter consul-template etcd dnsmasq
  - node_exporter postgres_exporter nginx_exporter blackbox_exporter redis_exporter
  - ansible python python-pip python-psycopg2
  - python3 python3-psycopg2 python36-requests python3-etcd python3-consul python36-urllib3 python36-idna python36-pyOpenSSL python36-cryptography
  - patroni patroni-consul patroni-etcd pgbouncer pg_cli pgbadger pg_activity tail_n_mail
  - pgcenter boxinfo check_postgres emaj pgbconsole pg_bloat_check pgquarrel barman barman-cli pgloader pgFormatter pitrery pspg pgxnclient PyGreSQL pgadmin4
  - postgresql14* postgis32_14* citus_14* pglogical_14* timescaledb-2-postgresql-14 pg_repack_14 wal2json_14
  - pg_qualstats_14 pg_stat_kcache_14 pg_stat_monitor_14 pg_top_14 pg_track_settings_14 pg_wait_sampling_14
  - pg_statement_rollback_14 system_stats_14 plproxy_14 plsh_14 pldebugger_14 plpgsql_check_14 pgmemcache_14
  - mysql_fdw_14 ogr_fdw_14 tds_fdw_14 sqlite_fdw_14 firebird_fdw_14 hdfs_fdw_14 mongo_fdw_14 osm_fdw_14 pgbouncer_fdw_14
  - hypopg_14 geoip_14 rum_14 hll_14 ip4r_14 prefix_14 pguri_14 tdigest_14 topn_14 periods_14
  - bgw_replstatus_14 count_distinct_14 credcheck_14 ddlx_14 extra_window_functions_14 logerrors_14 mysqlcompat_14 orafce_14
  - repmgr_14 pg_auth_mon_14 pg_auto_failover_14 pg_background_14 pg_bulkload_14 pg_catcheck_14 pg_comparator_14
  - pg_cron_14 pg_fkpart_14 pg_jobmon_14 pg_partman_14 pg_permissions_14 pg_prioritize_14 pgagent_14
  - pgaudit16_14 pgauditlogtofile_14 pgcryptokey_14 pgexportdoc_14 pgfincore_14 pgimportdoc_14 powa_14 pgmp_14 pgq_14
  - pgquarrel-0.7.0-1 pgsql_tweaks_14 pgtap_14 pgtt_14 postgresql-unit_14 postgresql_anonymizer_14 postgresql_faker_14
  - safeupdate_14 semver_14 set_user_14 sslutils_14 table_version_14
  - clang coreutils diffutils rpm-build rpm-devel rpmlint rpmdevtools bison flex
```

每一行都是一组由空格分割的软件包名称，在这里指定的软件会通过`repotrack`进行下载。







### `repo_url_packages`

通过URL直接下载的软件, 类型：`url[]`，层级：G

通过URL，而非YUM下载一些软件：

* `pg_exporter`： **必须项**，监控系统核心组件
* `vip-manager`：**必选项**，启用L2 VIP时所必须的软件包，用于管理VIP
* `loki`, `promtail`：**必选项**，日志收集服务端与客户端二进制。
* `postgrest`：可选，自动根据PostgreSQL数据库模式生成后端API接口
* `polysh`：可选，并行在多台节点上执行ssh命令
* `pev2`：可选，PostgreSQL执行计划可视化
* `pgweb`：可选，网页版PostgreSQL命令行工具
* `redis`：**可选**，当安装Redis时为必选

```yaml
  - https://github.com/cybertec-postgresql/vip-manager/releases/download/v1.0.1/vip-manager_1.0.1-1_amd64.rpm
  - https://github.com/Vonng/pg_exporter/releases/download/v0.4.1/pg_exporter-0.4.1-1.el7.x86_64.rpm
  - https://github.com/Vonng/pigsty-pkg/releases/download/haproxy/haproxy-2.5.5-1.el7.x86_64.rpm
  - https://github.com/Vonng/loki-rpm/releases/download/v2.4.2/loki-2.4.2-1.el7.x86_64.rpm
  - https://github.com/Vonng/loki-rpm/releases/download/v2.4.2/promtail-2.4.2-1.el7.x86_64.rpm
  - https://github.com/Vonng/pigsty-pkg/releases/download/postgrest/postgrest-9.0.0-1.el7.x86_64.rpm
  - https://github.com/Vonng/pigsty-pkg/releases/download/misc/polysh-0.4-1.noarch.rpm
  - https://github.com/dalibo/pev2/releases/download/v0.24.0/pev2.tar.gz
  - https://github.com/sosedoff/pgweb/releases/download/v0.11.10/pgweb_linux_amd64.zip
  - https://github.com/Vonng/pigsty-pkg/releases/download/misc/redis-6.2.6-1.el7.remi.x86_64.rp
```










----------------
## `CA`

用于搭建本地公私钥基础设施，当您需要SSL证书等高级安全特性时，可以使用此任务。




### `ca_method`

CA的创建方式, 类型：`enum`，层级：G，默认值为：`"create"`

* `create`：创建新的公私钥用于CA
* `copy`：拷贝现有的CA公私钥用于构建CA



### `ca_subject`

自签名CA主题, 类型：`string`，层级：G，默认值为：`"/CN=root-ca"`





### `ca_homedir`

CA证书根目录, 类型：`path`，层级：G，默认值为：`"/ca"`





### `ca_cert`

CA证书, 类型：`string`，层级：G，默认值为：`"ca.crt"`





### `ca_key`

CA私钥名称, 类型：`string`，层级：G，默认值为：`"ca.key"`







----------------
## `NGINX`

Pigsty通过元节点上的Nginx对外暴露所有Web类服务，如首页，Grafana，Prometheus，AlertManager，Consul，以及可选的PGWeb与Jupyter Lab。此外，本地软件源，本地文档，与其他本地WEB工具如Pev2，Pgbouncer也由Nginx对外提供服务。

您可以绕过Nginx直接通过端口访问元节点上的部分服务，但部分服务出于安全性原因不宜对外暴露，只能通过Nginx代理访问。Nginx通过域名区分不同的服务，因此，如果您为各个服务配置的域名在当前环境中无法解析，则需要您自行在`/etc/hosts`中配置后使用。



### `nginx_upstream`

Nginx上游服务器, 类型：`upstream[]`，层级：G，默认值为：

```yaml
nginx_upstream:                  # domain names and upstream servers
  - { name: home,         domain: pigsty,     endpoint: "10.10.10.10:80" }
  - { name: grafana,      domain: g.pigsty,   endpoint: "10.10.10.10:3000" }
  - { name: loki,         domain: l.pigsty,   endpoint: "10.10.10.10:3100" }
  - { name: prometheus,   domain: p.pigsty,   endpoint: "10.10.10.10:9090" }
  - { name: alertmanager, domain: a.pigsty,   endpoint: "10.10.10.10:9093" }
  - { name: consul,       domain: c.pigsty,   endpoint: "127.0.0.1:8500" }
  - { name: pgweb,        domain: cli.pigsty, endpoint: "127.0.0.1:8081" }
  - { name: jupyter,      domain: lab.pigsty, endpoint: "127.0.0.1:8888" }
```

每一条记录包含三个子段：`name`, `domain`, `endpoint`，分别代表组件名称，外部访问域名，以及内部的TCP端点。

默认记录的`name` 定义是固定的，通过硬编码引用，请勿修改。您可以任意新增其他名称的上游服务器记录。

`domain`是外部访问此上游服务器时应当使用的域名，当您访问Pigsty Web服务时，应当使用域名通过Nginx代理访问。

`endpoint`是内部可达的TCP端点，占位IP地址`10.10.10.10`会在Configure过程中被替换为元节点IP。




### `app_list`

首页导航栏显示的应用列表, 类型：`app[]`，层级：G，默认值为：

```yaml
app_list:                            # application nav links on home page
  - { name: Pev2    , url : '/pev2'        , comment: 'postgres explain visualizer 2' }
  - { name: Logs    , url : '/logs'        , comment: 'realtime pgbadger log sample' }
  - { name: Report  , url : '/report'      , comment: 'daily log summary report ' }
  - { name: Pkgs    , url : '/pigsty'      , comment: 'local yum repo packages' }
  - { name: Repo    , url : '/pigsty.repo' , comment: 'local yum repo file' }
  - { name: ISD     , url : '${grafana}/d/isd-overview'   , comment: 'noaa isd data visualization' }
  - { name: Covid   , url : '${grafana}/d/covid-overview' , comment: 'covid data visualization' }
```

每一条记录都会渲染为Pigsty首页App下拉菜单的导航连接，应用均为可选项目，默认挂载于Pigsty默认服务器下`http://pigsty/`
其中，`url` 参数指定了应用的URL PATH，特例是如果URL中存在`${grafana}`字符串，会被自动替换为[`nginx_upstream`](#nginx_upstream) 中定义的Grafana域名。







### `docs_enabled`

是否启用本地文档, 类型：`bool`，层级：G，默认值为：`true`。

本地文档会被自动拷贝至元节点的 `{{ repo_home }}` / docs 路径下，通过Nginx从默认Server提供服务。

默认访问地址为：`http://pigsty/docs`。



### `pev2_enabled`

是否启用PEV2组件, 类型：`bool`，层级：G，默认值为：`true`

Pev2是一个方便的PostgreSQL执行计划可视化工具，静态单页应用。

如果启用，Pev2资源会被拷贝至元节点的 `{{ repo_home }}` / pev2 路径下，并通过Nginx从默认Server提供服务。默认访问地址为：`http://pigsty/pev2`。





### `pgbadger_enabled`

是否启用Pgbadger, 类型：`bool`，层级：G，默认值为：`true`

Pgbadger是一个方便的PostgreSQL日志分析工具，可以从PG日志中生成全面美观的网页报告。

如果启用，Pigsty会在元节点上创建 `{{ repo_home }}` / logs 占位目录，后续Pgbouncer生成的报告会自动放置于此。默认访问地址为：`http://pigsty/logs`。






----------------
## `NAMESERVER`

Pigsty默认会使用DNSMASQ在元节点上搭建一个可选的开箱即用的域名服务器。



### `dns_records`

动态DNS解析记录, 类型：`string[]`，层级：G，默认值为`[]`空列表，在沙箱环境中默认有以下解析记录。

```yaml
dns_records:                    # dynamic dns record resolved by dnsmasq
  - 10.10.10.2  pg-meta         # sandbox vip for pg-meta
  - 10.10.10.3  pg-test         # sandbox vip for pg-test
  - 10.10.10.10 meta-1          # sandbox node meta-1
  - 10.10.10.11 node-1          # sandbox node node-1
  - 10.10.10.12 node-2          # sandbox node node-2
  - 10.10.10.13 node-3          # sandbox node node-3
  - 10.10.10.10 pg-meta-1       # sandbox instance pg-meta-1
  - 10.10.10.11 pg-test-1       # sandbox instance node-1
  - 10.10.10.12 pg-test-2       # sandbox instance node-2
  - 10.10.10.13 pg-test-3       # sandbox instance node-3
```






----------------
## `PROMETHEUS`

Prometheus是Pigsty监控系统核心组件，用于拉取时序数据，进行指标预计算，评估告警规则。



### `prometheus_data_dir`

Prometheus数据库目录, 类型：`path`，层级：G，默认值为：`"/data/prometheus/data"`





### `prometheus_options`

Prometheus命令行参数, 类型：`string`，层级：G，默认值为：`"--storage.tsdb.retention=15d --enable-feature=promql-negative-offset"`

默认参数会允许Prometheus启用负时间偏移量功能，并默认保留15天监控数据。如果您的磁盘有余裕，可以增大监控数据的保留时长。



### `prometheus_reload`

在执行Prometheus任务时，是否仅仅只是重载配置，而不是整个重建。类型：`bool`，层级：A，默认值为：`false`。

默认情况下，执行执行`prometheus`任务时会清除已有监控数据，如果设置为`true`，执行Prometheus任务时不会清除已有数据目录。




### `prometheus_sd_method`

服务发现机制：static|consul, 类型：`enum`，层级：G，默认值为：`"static"`

Prometheus使用的服务发现机制，默认为`static`，另外的选项 `consul` 将使用Consul进行服务发现（将逐步弃用）。
Pigsty建议使用`static`服务发现，该方式提供了更高的可靠性与灵活性，Consul服务发现将逐步停止支持。

`static`服务发现依赖`/etc/prometheus/targets/{infra,nodes,pgsql,redis}/*.yml`中的配置进行服务发现。
采用这种方式的优势是，监控系统不依赖Consul，当节点宕机时，监控目标会报错提示，而不是直接消失。此外，当Pigsty监控系统与外部管控方案集成时，这种模式对原系统的侵入性较小。

可以使用以下命令，从配置文件生成Prometheus所需的监控对象配置文件。

```bash
./nodes.yml -t register_prometheus  # 生成主机监控目标列表
./pgsql.yml -t register_prometheus  # 生成PostgreSQL/Pgbouncer/Patroni/Haproxy监控目标列表
./redis.yml -t register_prometheus  # 生成Redis监控目标列表
```




### `prometheus_scrape_interval`

Prometheus抓取周期, 类型：`interval`，层级：G，默认值为：`"10s"`

在生产环境，10秒 - 30秒是一个较为合适的抓取周期。如果您需要更精细的的监控数据粒度，则可以调整此参数。



### `prometheus_scrape_timeout`

Prometheus抓取超时, 类型：`interval`，层级：G，默认值为：`"8s"`

设置抓取超时可以有效避免监控系统查询导致的雪崩，原则是本参数必须小于并接近 [`prometheus_scrape_interval`](#prometheus_scrape_interval) ，确保每次抓取时长不超过抓取周期。



### `prometheus_sd_interval`

Prometheus服务发现刷新周期, 类型：`interval`，层级：G，默认值为：`"10s"`

每隔本参数指定的时长，Prometheus就会重新检查本地文件目录，刷新监控目标对象。





----------------
## `EXPORTER`

定义通用的指标暴露器选项，例如Exporter的安装方式，监听的URL路径等。



### `exporter_install`

安装监控组件的方式, 类型：`enum`，层级：G，默认值为：`"none"`

指明安装Exporter的方式：

* `none`：不安装，（默认行为，Exporter已经在先前由 [`node.pkgs`](v-nodes.md#node_packages) 任务完成安装）
* `yum`：使用yum安装（如果启用yum安装，在部署Exporter前执行yum安装 [`node_exporter`](#node_exporter) 与 [`pg_exporter`](v-pgsql.md#pg_exporter) ）
* `binary`：使用拷贝二进制的方式安装（从元节点中直接拷贝[`node_exporter`](#node_exporter) 与 [`pg_exporter`](v-pgsql.md#pg_exporter) 二进制，不推荐）

使用`yum`安装时，如果指定了`exporter_repo_url`（不为空），在执行安装时会首先将该URL下的REPO文件安装至`/etc/yum.repos.d`中。这一功能可以在不执行节点基础设施初始化的环境下直接进行Exporter的安装。
不推荐普通用户使用`binary`安装，这种模式通常用于紧急故障抢修与临时问题修复。

```bash
<meta>:<pigsty>/files/node_exporter ->  <target>:/usr/bin/node_exporter
<meta>:<pigsty>/files/pg_exporter   ->  <target>:/usr/bin/pg_exporter
```





### `exporter_repo_url`

监控组件的Yum Repo URL, 类型：`string`，层级：G，默认值为：`""`。

默认为空，当 [`exporter_install`](#exporter_install) 为 `yum` 时，该参数指定的Repo会被添加至节点源列表中。





### `exporter_metrics_path`

监控暴露的URL Path, 类型：`string`，层级：G，默认值为：`"/metrics"`

所有Exporter对外暴露指标的URL PATH，默认为`/metrics`，该变量被外部角色[`prometheus`](#prometheus)引用，Prometheus会根据这里的配置，对监控对象应用此配置。

受此参数影响的指标暴露器包括：

* [`node_exporter`](#node_exporter)
* [`pg_exporter`](v-pgsql.md#pg_exporter)
* [`pgbouncer_exporter`](v-pgsql.md#pgbouncer_exporter)
* [`haproxy`](v-pgsql.md#haproxy_exporter_port)
* Patroni的Metrics端点目前固定为`/metrics`，无法配置，故不受此参数影响
* Infra组件的Metrics端点固定为`/metrics`，不受此参数影响。






----------------
## `GRAFANA`

Grafana是Pigsty监控系统的可视化平台。



### `grafana_endpoint`

Grafana地址, 类型：`url`，层级：G，默认值为：`"http://10.10.10.10:3000"`

Grafana对外提供服务的端点，Grafana初始化与安装监控面板会使用该端点调用Grafana API

在Configure过程中，占位IP`10.10.10.10`会在`configure`过程中被实际IP替换。



### `grafana_admin_username`

Grafana管理员用户名, 类型：`string`，层级：G，默认值为：`"admin"`





### `grafana_admin_password`

Grafana管理员密码, 类型：`string`，层级：G，默认值为：`"pigsty"`





### `grafana_database`

Grafana后端数据库类型, 类型：`enum`，层级：G，默认值为：`"sqlite3"`

备选为`postgres`，使用`postgres`时，必须确保目标数据库已经存在并可以访问。即首次初始化基础设施前，无法使用元节点上的Postgres，因为Grafana先于该数据库而创建。

为了避免产生循环依赖（Grafana依赖Postgres，PostgreSQL依赖包括Grafana在内的基础设施），您需要在首次完成安装后，修改此参数并重新执行 [`grafana`](#grafana)相关任务。
详情请参考【[教程:使用Postgres作为Grafana后端数据库](t-grafana-upgrade.md)】




### `grafana_pgurl`

Grafana的PostgreSQL数据库连接串, 类型：`url`，层级：G，默认值为：`"postgres://dbuser_grafana:DBUser.Grafana@meta:5436/grafana"`

仅当参数 [`grafana_database`](#grafana_database) 为 `postgres` 时有效。





### `grafana_plugin`

如何安装Grafana插件, 类型：`enum`，层级：G，默认值为：`"install"`

Grafana插件的供给方式

* `none`：不安装插件
* `install`: 安装Grafana插件（默认），若已存在则跳过。
* `reinstall`: 无论如何都重新下载安装Grafana插件

Grafana需要访问互联网以下载若干扩展插件，如果您的元节点没有互联网访问，则应当确保使用了离线安装包。
离线安装包中默认已经包含了所有下载好的Grafana插件，位于 [`grafana_cache`](#grafana_cache) 指定的路径下。当从互联网下载插件时，Pigsty会在下载完成后打包下载好的插件，并放置于该路径下。




### `grafana_cache`

Grafana插件缓存地址, 类型：`path`，层级：G，默认值为：`"/www/pigsty/plugins.tgz"`





### `grafana_plugins`

安装的Grafana插件列表, 类型：`string[]`，层级：G，默认值为：

```yaml
grafana_plugins:
  - marcusolsson-csv-datasource
  - marcusolsson-json-datasource
  - marcusolsson-treemap-panel
```

每个数组元素是一个字符串，表示插件的名称。插件会通过`grafana-cli plugins install`的方式进行安装。






### `grafana_git_plugins`

从Git安装的Grafana插件, 类型：`url[]`，层级：G，默认值为：

```yaml
grafana_git_plugins:                          # plugins that will be downloaded via git
  - https://github.com/Vonng/vonng-echarts-panel
```

一些插件无法通过官方命令行下载，但可以通过Git Clone的方式下载。插件会通过`cd /var/lib/grafana/plugins && git clone `的方式进行安装。

默认会下载一个可视化插件：`vonng-echarts-panel`，提供为Grafana提供Echarts绘图支持。







----------------
## `LOKI`


LOKI是Pigsty使用的默认日志收集服务器。



### `loki_endpoint`

用于接收日志的loki服务端点, 类型：`url`，层级：G，默认值为：`"http://10.10.10.10:3100/loki/api/v1/push"`





### `loki_clean`

是否在安装Loki时清理数据库目录, 类型：`bool`，层级：A，默认值为：`false`





### `loki_options`

Loki的命令行参数, 类型：`string`，层级：G，默认值为：`"-config.file=/etc/loki.yml -config.expand-env=true"`

默认的配置参数用于指定Loki配置文件位置，并启用在配置文件中展开环境变量的功能，不建议移除这两个选项。




### `loki_data_dir`

Loki的数据目录, 类型：`string`，层级：G，默认值为：`"/data/loki"`





### `loki_retention`

Loki日志默认保留天数, 类型：`interval`，层级：G，默认值为：`"15d"`







----------------
## `DCS`

Distributed Configuration Store (DCS) 是一种分布式，高可用的元数据库。Pigsty使用DCS来实现数据库高可用，服务发现等功能也通过DCS实现。

Pigsty目前仅支持使用Consul作为DCS，后续会添加ETCD作为DCS的选项。通过 [`dcs_type`](#dcs_type) 指明使用的DCS种类，通过 [`service_registry`](#service_registry) 指明服务注册的位置。

Consul服务的可用性对于数据库高可用至关重要，因此在生产环境摆弄DCS服务时，需要特别小心。DCS本身的可用性，通过多副本实现。例如，3节点的Consul集群最多允许1个节点故障，5节点的Consul集群则可以允许两个节点故障，在大规模生产环境中，建议使用至少3个DCS Server。
Pigsty使用的DCS服务器通过参数 [`dcs_servers`](#dcs_servers) 指定，您可以使用外部的现有DCS服务器集群。也可以使用Pigsty本身管理的节点部署DCS Servers。

在默认情况下，Pigsty会在节点纳入管理时（[`nodes.yml`](p-nodes.md#nodes)）部署设置DCS服务，如果当前节点定义于 [`dcs_servers`](#dcs_servers) 中，则该节点会被初始化为 DCS Server。
Pigsty会在元节点本身部署一个单节点的DCS Server，使用多个元节点时，您也可以将其复用为DCS Server。尽管如此，元节点与DCS Server并不绑定。您可以使用任意节点作为DCS Servers。
但大的原则是，在部署任意高可用数据库集群前，您应当确保所有DCS Servers已经完成初始化。



### `dcs_servers`

DCS服务器, 类型：`dict`，层级：G，默认值为：

```yaml
dcs_servers:
  meta-1: 10.10.10.10      # 默认在元节点上部署单个DCS Server
  # meta-2: 10.10.10.11
  # meta-3: 10.10.10.12 
```

字典格式，Key为DCS服务器实例名称，Value为服务器IP地址。 默认情况下，Pigsty将在[节点初始化](p-nodes.md#nodes)剧本中为节点配置DCS服务，默认为Consul。

您可以使用外部的DCS服务器，依次填入所有外部DCS Servers的地址即可，否则Pigsty默认将在元节点（`10.10.10.10`占位）上部署一个单实例DCS Server。
如果当前节点定义于 [`dcs_servers`](#dcs_servers) 中，即IP地址与任意Value匹配，则该节点会被初始化为 DCS Server，其Key将被用作Consul Server




### `service_registry`

服务注册的位置, 类型：`enum`，层级：G，默认值为：`"consul"`

* `none`：不执行服务注册（当执行[**仅监控部署**](d-monly.md)时，必须指定`none`模式）
* `consul`：将服务注册至Consul中
* `etcd`：将服务注册至Etcd中（尚未支持）




### `dcs_type`

使用的DCS类型, 类型：`enum`，层级：G，默认值为：`"consul"`

有两种选项：`consul` 与 `etcd` ，但ETCD尚未正式支持。



### `dcs_name`

DCS集群名称, 类型：`string`，层级：G，默认值为：`"pigsty"`

在Consul中代表数据中心名称，在Etcd中没有意义。



### `dcs_exists_action`

DCS安全保险，若DCS实例以及存在如何处理, 类型：`enum`，层级：C/A，默认值为：`"abort"`，

在部署Consul时，如果Pigsty发现目标实例上Consul已经存在，则会根据本参数采取对应的行为：

* `abort`: 中止整个剧本的执行（默认行为）
* `clean`: 抹除现有DCS实例并继续（极端危险，仅Demo中使用此方式）
* `skip`: 忽略存在DCS实例的目标（中止），在其他目标机器上继续执行。

Consul服务的可用性对于数据库高可用至关重要，因此在生产环境摆弄DCS服务时，需要特别小心。
如果您真的需要强制清除已经存在的DCS实例，建议先使用[`nodes-remove.yml`](p-pgsql.md#pgsql-remove)完成集群与实例的下线与销毁，再重新执行初始化。
否则需要通过命令行参数`./nodes.yml -e dcs_exists_action=clean`完成覆写，强制在初始化过程中抹除已有实例。






### `dcs_disable_purge`

DCS双重安全保险，完全禁止清理DCS实例, 类型：`bool`，层级：C/A，默认值为：`false`

双重安全保险，如果启用为`true`，则强制设置 [`dcs_exists_action`](#dcs_exists_action) 变量为`abort`。

等效于关闭 [`dcs_exists_action`](#dcs_exists_action) 的清理功能，确保**任何情况**下DCS实例都不会被抹除。



### `consul_data_dir`

Consul数据目录, 类型：`string`，层级：G，默认值为：`"/data/consul"`





### `etcd_data_dir`

Etcd数据目录, 类型：`string`，层级：G，默认值为：`"/data/etcd"`







----------------
## `JUPYTER`

Jupyter Lab 是基于 IPython Notebook 的完整数据科学研发环境，可用于数据分析与可视化。目前为可选Beta功能，默认只在Demo中启用

因为JupyterLab提供了Web Terminal功能，因此不建议在生产环境中开启，可以使用 [`infra-jupyter`](p-infra.md#infra-jupyter) 在元节点上手动部署。



### `jupyter_enabled`

是否启用JupyterLab, 类型：`bool`，层级：G，默认值为：`false`，不启用。



启用JupyterLab时，Pigsty会使用[`jupyter_username`](jupyter_username) 参数指定的用户运行本地Notebook服务器。
此外，需要确保配置[`node_meta_pip_install`](v-nodes.md#node_meta_pip_install) 参数包含默认值 `'jupyterlab'`。
Jupyter Lab可以从Pigsty首页导航进入，或通过默认域名 `lab.pigsty` 访问，默认监听于8888端口。


### `jupyter_username`

Jupyter使用的操作系统用户, 类型：`bool`，层级：G，默认值为：`"jupyter"`

其他用户名亦同理，但特殊用户名`default`会使用当前执行安装的用户（通常为管理员）运行 Jupyter Lab，这会更方便，但也更危险。



### `jupyter_password`

Jupyter Lab的密码, 类型：`bool`，层级：G，默认值为：`"pigsty"`

如果启用Jupyter，强烈建议修改此密码。加盐混淆的密码默认会写入`~jupyter/.jupyter/jupyter_server_config.json`。







----------------
## `PGWEB`

PGWeb 是基于浏览器的PostgreSQL客户端工具，可用于小批量个人数据查询等场景。目前为可选Beta功能，默认只在Demo中启用

在Demo中该功能默认启用，其他情况下默认关闭，可以使用 [`infra-pgweb`](p-infra.md#infra-pgweb) 在元节点上手动部署。


### `pgweb_enabled`

是否启用PgWeb, 类型：`bool`，层级：G，默认值为：`false`，对于演示与个人使用默认启用，对于生产环境部署默认不启用。

PGWEB的网页界面默认只能通过域名由 Nginx 代理访问，默认为`cli.pigsty`，默认会使用名为`pgweb`的操作系统用户运行。

```yaml
- { name: pgweb,        domain: cli.pigsty, endpoint: "127.0.0.1:8081" }
```


### `pgweb_username`

PgWeb使用的操作系统用户, 类型：`bool`，层级：G，默认值为：`"pgweb"`

运行PGWEB服务器的操作系统用户。默认为`pgweb`，即会创建一个低权限的默认用户`pgweb`。

特殊用户名`default`会使用当前执行安装的用户（通常为管理员）运行 PGWEB。

您需要数据库的连接串方可通过PgWeb访问环境中的数据库。例如：`postgres://dbuser_dba:DBUser.DBA@127.0.0.1:5432/meta`