# 配置：Infra

> 配置Pigsty基础设施

* [`repo`](#repo) ：本地YUM源配置


## 参数概览

部署于管理节点上的 [**基础设施**](c-arch.md#基础设施) 由下列配置项所描述。

|                           参数                            |                                    角色                                    | 层级 |              说明              |
|-----------------------------------------------------------|----------------------------------------------------------------------------|------|--------------------------------|
| [proxy_env](#proxy_env)                                   | [repo](https://github.com/Vonng/pigsty/tree/master/roles/repo)             | G    | 代理服务器配置|
| [repo_enabled](#repo_enabled)                             | [repo](https://github.com/Vonng/pigsty/tree/master/roles/repo)             | G    | 是否启用本地源|
| [repo_name](#repo_name)                                   | [repo](https://github.com/Vonng/pigsty/tree/master/roles/repo)             | G    | 本地源名称|
| [repo_address](#repo_address)                             | [repo](https://github.com/Vonng/pigsty/tree/master/roles/repo)             | G    | 本地源外部访问地址|
| [repo_port](#repo_port)                                   | [repo](https://github.com/Vonng/pigsty/tree/master/roles/repo)             | G    | 本地源端口|
| [repo_home](#repo_home)                                   | [repo](https://github.com/Vonng/pigsty/tree/master/roles/repo)             | G    | 本地源文件根目录|
| [repo_rebuild](#repo_rebuild)                             | [repo](https://github.com/Vonng/pigsty/tree/master/roles/repo)             | A    | 是否重建Yum源|
| [repo_remove](#repo_remove)                               | [repo](https://github.com/Vonng/pigsty/tree/master/roles/repo)             | A    | 是否移除已有Yum源|
| [repo_upstreams](#repo_upstreams)                         | [repo](https://github.com/Vonng/pigsty/tree/master/roles/repo)             | G    | Yum源的上游来源|
| [repo_packages](#repo_packages)                           | [repo](https://github.com/Vonng/pigsty/tree/master/roles/repo)             | G    | Yum源需下载软件列表|
| [repo_url_packages](#repo_url_packages)                   | [repo](https://github.com/Vonng/pigsty/tree/master/roles/repo)             | G    | 通过URL直接下载的软件|
| [ca_method](#ca_method)                                   | [ca](https://github.com/Vonng/pigsty/tree/master/roles/ca)                 | G    | CA的创建方式|
| [ca_subject](#ca_subject)                                 | [ca](https://github.com/Vonng/pigsty/tree/master/roles/ca)                 | G    | 自签名CA主题|
| [ca_homedir](#ca_homedir)                                 | [ca](https://github.com/Vonng/pigsty/tree/master/roles/ca)                 | G    | CA证书根目录|
| [ca_cert](#ca_cert)                                       | [ca](https://github.com/Vonng/pigsty/tree/master/roles/ca)                 | G    | CA证书|
| [ca_key](#ca_key)                                         | [ca](https://github.com/Vonng/pigsty/tree/master/roles/ca)                 | G    | CA私钥名称|
| [nginx_upstream](#nginx_upstream)                         | [nginx](https://github.com/Vonng/pigsty/tree/master/roles/nginx)           | G    | Nginx上游服务器|
| [app_list](#app_list)                                     | [nginx](https://github.com/Vonng/pigsty/tree/master/roles/nginx)           | G    | 首页导航栏显示的应用列表|
| [docs_enabled](#docs_enabled)                             | [nginx](https://github.com/Vonng/pigsty/tree/master/roles/nginx)           | G    | 是否启用本地文档|
| [pev2_enabled](#pev2_enabled)                             | [nginx](https://github.com/Vonng/pigsty/tree/master/roles/nginx)           | G    | 是否启用PEV2组件|
| [pgbadger_enabled](#pgbadger_enabled)                     | [nginx](https://github.com/Vonng/pigsty/tree/master/roles/nginx)           | G    | 是否启用Pgbadger|
| [dns_records](#dns_records)                               | [nameserver](https://github.com/Vonng/pigsty/tree/master/roles/nameserver) | G    | 动态DNS解析记录|
| [prometheus_data_dir](#prometheus_data_dir)               | [prometheus](https://github.com/Vonng/pigsty/tree/master/roles/prometheus) | G    | Prometheus数据库目录|
| [prometheus_options](#prometheus_options)                 | [prometheus](https://github.com/Vonng/pigsty/tree/master/roles/prometheus) | G    | Prometheus命令行参数|
| [prometheus_reload](#prometheus_reload)                   | [prometheus](https://github.com/Vonng/pigsty/tree/master/roles/prometheus) | A    | Reload而非Recreate|
| [prometheus_sd_method](#prometheus_sd_method)             | [prometheus](https://github.com/Vonng/pigsty/tree/master/roles/prometheus) | G    | 服务发现机制：static|consul|
| [prometheus_scrape_interval](#prometheus_scrape_interval) | [prometheus](https://github.com/Vonng/pigsty/tree/master/roles/prometheus) | G    | Prom抓取周期|
| [prometheus_scrape_timeout](#prometheus_scrape_timeout)   | [prometheus](https://github.com/Vonng/pigsty/tree/master/roles/prometheus) | G    | Prom抓取超时|
| [prometheus_sd_interval](#prometheus_sd_interval)         | [prometheus](https://github.com/Vonng/pigsty/tree/master/roles/prometheus) | G    | Prom服务发现刷新周期|
| [grafana_endpoint](#grafana_endpoint)                     | [grafana](https://github.com/Vonng/pigsty/tree/master/roles/grafana)       | G    | Grafana地址|
| [grafana_admin_username](#grafana_admin_username)         | [grafana](https://github.com/Vonng/pigsty/tree/master/roles/grafana)       | G    | Grafana管理员用户名|
| [grafana_admin_password](#grafana_admin_password)         | [grafana](https://github.com/Vonng/pigsty/tree/master/roles/grafana)       | G    | Grafana管理员密码|
| [grafana_database](#grafana_database)                     | [grafana](https://github.com/Vonng/pigsty/tree/master/roles/grafana)       | G    | Grafana后端数据库类型|
| [grafana_pgurl](#grafana_pgurl)                           | [grafana](https://github.com/Vonng/pigsty/tree/master/roles/grafana)       | G    | Grafana的PG数据库连接串|
| [grafana_plugin](#grafana_plugin)                         | [grafana](https://github.com/Vonng/pigsty/tree/master/roles/grafana)       | G    | 如何安装Grafana插件|
| [grafana_cache](#grafana_cache)                           | [grafana](https://github.com/Vonng/pigsty/tree/master/roles/grafana)       | G    | Grafana插件缓存地址|
| [grafana_plugins](#grafana_plugins)                       | [grafana](https://github.com/Vonng/pigsty/tree/master/roles/grafana)       | G    | 安装的Grafana插件列表|
| [grafana_git_plugins](#grafana_git_plugins)               | [grafana](https://github.com/Vonng/pigsty/tree/master/roles/grafana)       | G    | 从Git安装的Grafana插件|
| [loki_clean](#loki_clean)                                 | [loki](https://github.com/Vonng/pigsty/tree/master/roles/loki)             | A    | 是否在安装Loki时清理数据库目录|
| [loki_options](#loki_options)                             | [loki](https://github.com/Vonng/pigsty/tree/master/roles/loki)             | G    | Loki的命令行参数|
| [loki_data_dir](#loki_data_dir)                           | [loki](https://github.com/Vonng/pigsty/tree/master/roles/loki)             | G    | Loki的数据目录|
| [loki_retention](#loki_retention)                         | [loki](https://github.com/Vonng/pigsty/tree/master/roles/loki)             | G    | Loki日志默认保留天数|
| [jupyter_enabled](#jupyter_enabled)                       | [jupyter](https://github.com/Vonng/pigsty/tree/master/roles/jupyter)       | G    | 是否启用JupyterLab|
| [jupyter_username](#jupyter_username)                     | [jupyter](https://github.com/Vonng/pigsty/tree/master/roles/jupyter)       | G    | Jupyter使用的操作系统用户|
| [jupyter_password](#jupyter_password)                     | [jupyter](https://github.com/Vonng/pigsty/tree/master/roles/jupyter)       | G    | Jupyter Lab的密码|
| [pgweb_enabled](#pgweb_enabled)                           | [jupyter](https://github.com/Vonng/pigsty/tree/master/roles/jupyter)       | G    | 是否启用PgWeb|
| [pgweb_username](#pgweb_username)                         | [jupyter](https://github.com/Vonng/pigsty/tree/master/roles/jupyter)       | G    | PgWeb使用的操作系统用户|


------------------

## CONNECT

<details>
<summary>CONNECT参数默认值</summary>

```yaml
#------------------------------------------------------------------------------
# CONNECTION PARAMETERS
#------------------------------------------------------------------------------
# this section defines connection parameters (How to perform ssh sudo on nodes)

# ansible_user: vagrant                       # admin user with ssh access and sudo privilege
# ansible_password: <remote ssh pass>         # admin user's ssh password (sshpass required, not recommended)
# ansible_become_pass: <remote sudo password> # admin user's sudo password (security breach, not recommended)

proxy_env:                                    # global proxy env when downloading packages
  no_proxy: "localhost,127.0.0.1,10.0.0.0/8,192.168.0.0/16,*.pigsty,*.aliyun.com,mirrors.*,*.myqcloud.com"
  # http_proxy:  # set your proxy here: e.g http://user:pass@proxy.xxx.com
  # https_proxy: # set your proxy here: e.g http://user:pass@proxy.xxx.com
  # all_proxy:   # set your proxy here: e.g http://user:pass@proxy.xxx.com
```

</details>


### `proxy_env`

在某些受到“互联网封锁”的地区，有些软件的下载会受到影响。

例如，从中国大陆访问PostgreSQL的官方源，下载速度可能只有几KB每秒。但如果使用了合适的HTTP代理，则可以达到几MB每秒。因此如果用户有代理服务器，请通过`proxy_env`进行配置，样例如下：

```yaml
proxy_env: # global proxy env when downloading packages
  http_proxy: 'http://username:password@proxy.address.com'
  https_proxy: 'http://username:password@proxy.address.com'
  all_proxy: 'http://username:password@proxy.address.com'
  no_proxy: "localhost,127.0.0.1,10.0.0.0/8,192.168.0.0/16,*.pigsty,*.aliyun.com,mirrors.aliyuncs.com,mirrors.tuna.tsinghua.edu.cn,mirrors.zju.edu.cn"
```

使用Ansible在远程机器上执行剧本时，默认需要远程机器上可以直接通过ssh登陆，且登陆的用户具有免密码sudo的权限。

如果您无法使用**免密码**的方式执行SSH登陆，可以在执行剧本时添加`--ask-pass`或`-k`参数，手工输入SSH密码。

如果您无法使用**免密码**的方式执行远程sudo命令，可以在执行剧本时添加`--ask-become-pass`或`-K`参数，手工输入sudo密码。

如果管理账号在目标机器上不存在，您可以使用其他具有远程登录管理员身份的用户，使用 `pgsql.yml` 剧本中的 `node_admin` 进行创建。

例如：

```bash
./pgsql --limit <target_hosts>  --tags node_admin  -e ansible_user=<another_admin> --ask-pass --ask-become-pass 
```

详情请参考：[准备：管理用户置备](d-prepare.md#管理用户置备)

### `ansible_host`

如果用户的环境使用了跳板机，或者进行了某些定制化修改，无法通过简单的`ssh <ip>`方式访问，那么可以考虑使用Ansible的连接参数。`ansible_host`是ansiblel连接参数中最典型的一个。

> [Ansible中关于SSH连接的参数](https://docs.ansible.com/ansible/2.3/intro_inventory.html#list-of-behavioral-inventory-parameters)
>
> - ansible_host
    >
    >   The name of the host to connect to, if different from the alias you wish to give to it.
>
> - ansible_port
    >
    >   The ssh port number, if not 22
>
> - ansible_user
    >
    >   The default ssh user name to use.
>
> - ansible_ssh_pass
    >
    >   The ssh password to use (never store this variable in plain text; always use a vault. See [Variables and Vaults](https://docs.ansible.com/ansible/2.3/playbooks_best_practices.html#best-practices-for-variables-and-vaults))
>
> - ansible_ssh_private_key_file
    >
    >   Private key file used by ssh. Useful if using multiple keys and you don’t want to use SSH agent.
>
> - ansible_ssh_common_args
    >
    >   This setting is always appended to the default command line for **sftp**, **scp**, and **ssh**. Useful to configure a `ProxyCommand` for a certain host (or group).
>
> - ansible_sftp_extra_args
    >
    >   This setting is always appended to the default **sftp** command line.
>
> - ansible_scp_extra_args
    >
    >   This setting is always appended to the default **scp** command line.
>
> - ansible_ssh_extra_args
    >
    >   This setting is always appended to the default **ssh** command line.
>
> - ansible_ssh_pipelining
    >
    >   Determines whether or not to use SSH pipelining. This can override the `pipelining` setting in `ansible.cfg`.

最简单的用法是将`ssh alias`配置为`ansible_host`，只要用户可以通过 `ssh <name>`的方式访问目标机器，那么将`ansible_host`配置为`<name>`即可。

注意这些变量都是**实例级别**的变量。




------------------

## `REPO`


<details>
<summary>REPO参数默认值</summary>

```yaml

#------------------------------------------------------------------------------
# REPO PROVISION
#------------------------------------------------------------------------------
# this section describes pigsty local yum repo

# - repo basic - #
repo_enabled: true                            # build local yum repo on meta nodes?
repo_name: pigsty                             # local repo name (do not change)
repo_address: pigsty                          # repo external address (ip:port or url)
repo_port: 80                                 # listen address, must same as repo_address
repo_home: /www                               # default repo dir location
repo_rebuild: false                           # force re-download packages
repo_remove: true                             # remove existing repos

# - where to download - #
repo_upstreams:
  - name: base
    description: CentOS-$releasever - Base
    gpgcheck: no
    baseurl:
      - https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/os/$basearch/ # tuna
      - http://mirrors.aliyun.com/centos/$releasever/os/$basearch/
      - http://mirrors.aliyuncs.com/centos/$releasever/os/$basearch/
      - http://mirrors.cloud.aliyuncs.com/centos/$releasever/os/$basearch/    # aliyun
      - http://mirror.centos.org/centos/$releasever/os/$basearch/             # official

  - name: updates
    description: CentOS-$releasever - Updates
    gpgcheck: no
    baseurl:
      - https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/updates/$basearch/ # tuna
      - http://mirrors.aliyun.com/centos/$releasever/updates/$basearch/
      - http://mirrors.aliyuncs.com/centos/$releasever/updates/$basearch/
      - http://mirrors.cloud.aliyuncs.com/centos/$releasever/updates/$basearch/    # aliyun
      - http://mirror.centos.org/centos/$releasever/updates/$basearch/             # official

  - name: extras
    description: CentOS-$releasever - Extras
    baseurl:
      - https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/extras/$basearch/ # tuna
      - http://mirrors.aliyun.com/centos/$releasever/extras/$basearch/
      - http://mirrors.aliyuncs.com/centos/$releasever/extras/$basearch/
      - http://mirrors.cloud.aliyuncs.com/centos/$releasever/extras/$basearch/    # aliyun
      - http://mirror.centos.org/centos/$releasever/extras/$basearch/             # official
    gpgcheck: no

  - name: epel
    description: CentOS $releasever - epel
    gpgcheck: no
    baseurl:
      - https://mirrors.tuna.tsinghua.edu.cn/epel/$releasever/$basearch   # tuna
      - http://mirrors.aliyun.com/epel/$releasever/$basearch              # aliyun
      - http://download.fedoraproject.org/pub/epel/$releasever/$basearch  # official

  - name: grafana
    description: Grafana
    enabled: yes
    gpgcheck: no
    baseurl:
      - https://mirrors.tuna.tsinghua.edu.cn/grafana/yum/rpm    # tuna mirror
      - https://packages.grafana.com/oss/rpm                    # official

  - name: prometheus
    description: Prometheus and exporters
    gpgcheck: no
    baseurl: https://packagecloud.io/prometheus-rpm/release/el/$releasever/$basearch # no other mirrors, quite slow

  - name: pgdg-common
    description: PostgreSQL common RPMs for RHEL/CentOS $releasever - $basearch
    gpgcheck: no
    baseurl:
      - http://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/redhat/rhel-$releasever-$basearch  # tuna
      - https://download.postgresql.org/pub/repos/yum/common/redhat/rhel-$releasever-$basearch             # official

  - name: pgdg13
    description: PostgreSQL 13 for RHEL/CentOS $releasever - $basearch
    gpgcheck: no
    baseurl:
      - https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/13/redhat/rhel-$releasever-$basearch    # tuna
      - https://download.postgresql.org/pub/repos/yum/13/redhat/rhel-$releasever-$basearch                # official

  - name: pgdg14
    description: PostgreSQL 14 for RHEL/CentOS $releasever - $basearch
    gpgcheck: no
    baseurl:
      - https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/14/redhat/rhel-$releasever-$basearch    # tuna
      - https://download.postgresql.org/pub/repos/yum/14/redhat/rhel-$releasever-$basearch                # official

  - name: timescaledb
    description: TimescaleDB for RHEL/CentOS $releasever - $basearch
    gpgcheck: no
    baseurl:
      - https://packagecloud.io/timescale/timescaledb/el/7/$basearch

  - name: centos-sclo
    description: CentOS-$releasever - SCLo
    gpgcheck: no
    baseurl: # mirrorlist: http://mirrorlist.centos.org?arch=$basearch&release=$releasever&repo=sclo-sclo
      - http://mirrors.aliyun.com/centos/$releasever/sclo/$basearch/sclo/
      - http://repo.virtualhosting.hk/centos/$releasever/sclo/$basearch/sclo/

  - name: centos-sclo-rh
    description: CentOS-$releasever - SCLo rh
    gpgcheck: no
    baseurl: # mirrorlist: http://mirrorlist.centos.org?arch=$basearch&release=7&repo=sclo-rh
      - http://mirrors.aliyun.com/centos/$releasever/sclo/$basearch/rh/
      - http://repo.virtualhosting.hk/centos/$releasever/sclo/$basearch/rh/

  - name: nginx
    description: Nginx Official Yum Repo
    skip_if_unavailable: true
    gpgcheck: no
    baseurl: http://nginx.org/packages/centos/$releasever/$basearch/

  # for latest consul & kubernetes
  - name: harbottle
    description: Copr repo for main owned by harbottle
    skip_if_unavailable: true
    gpgcheck: no
    baseurl: https://download.copr.fedorainfracloud.org/results/harbottle/main/epel-$releasever-$basearch/

repo_packages:                                                                                                      #  what to download #
  - epel-release nginx wget yum-utils yum createrepo sshpass zip unzip                                              # ----  boot   ---- #
  - ntp chrony uuid lz4 bzip2 nc pv jq vim-enhanced make patch bash lsof wget git tuned perf ftp lrzsz rsync        # ----  node   ---- #
  - numactl grubby sysstat dstat iotop bind-utils net-tools tcpdump socat ipvsadm telnet ca-certificates keepalived # ----- utils ----- #
  - readline zlib openssl openssh-clients libyaml libxml2 libxslt libevent perl perl-devel perl-ExtUtils*           # ---  deps:pg  --- #
  - readline-devel zlib-devel uuid-devel libuuid-devel libxml2-devel libxslt-devel openssl-devel libicu-devel       # --- deps:devel -- #
  - ed mlocate parted krb5-devel apr apr-util audit rsyslog                                                         # --- deps:gpsql -- #
  - grafana prometheus2 pushgateway alertmanager consul consul_exporter consul-template etcd dnsmasq                # -----  meta ----- #
  - node_exporter postgres_exporter nginx_exporter blackbox_exporter redis_exporter                                 # ---- exporter --- #
  - ansible python python-pip python-psycopg2                                                                       # - ansible & py3 - #
  - python3 python3-psycopg2 python36-requests python3-etcd python3-consul python36-urllib3 python36-idna python36-pyOpenSSL python36-cryptography
  - patroni patroni-consul patroni-etcd pgbouncer pg_cli pgbadger pg_activity tail_n_mail                           # -- pgsql common - #
  - pgcenter boxinfo check_postgres emaj pgbconsole pg_bloat_check pgquarrel barman barman-cli pgloader pgFormatter pitrery pspg pgxnclient PyGreSQL pgadmin4
  - postgresql14* postgis32_14* citus_14* pglogical_14* timescaledb-2-postgresql-14 pg_repack_14 wal2json_14        # -- pg14 packages -#
  - pg_qualstats_14 pg_stat_kcache_14 pg_stat_monitor_14 pg_top_14 pg_track_settings_14 pg_wait_sampling_14
  - pg_statement_rollback_14 system_stats_14 plproxy_14 plsh_14 pldebugger_14 plpgsql_check_14 pgmemcache_14 # plr_14
  - mysql_fdw_14 ogr_fdw_14 tds_fdw_14 sqlite_fdw_14 firebird_fdw_14 hdfs_fdw_14 mongo_fdw_14 osm_fdw_14 pgbouncer_fdw_14
  - hypopg_14 geoip_14 rum_14 hll_14 ip4r_14 prefix_14 pguri_14 tdigest_14 topn_14 periods_14
  - bgw_replstatus_14 count_distinct_14 credcheck_14 ddlx_14 extra_window_functions_14 logerrors_14 mysqlcompat_14 orafce_14
  - repmgr_14 pg_auth_mon_14 pg_auto_failover_14 pg_background_14 pg_bulkload_14 pg_catcheck_14 pg_comparator_14
  - pg_cron_14 pg_fkpart_14 pg_jobmon_14 pg_partman_14 pg_permissions_14 pg_prioritize_14 pgagent_14
  - pgaudit16_14 pgauditlogtofile_14 pgcryptokey_14 pgexportdoc_14 pgfincore_14 pgimportdoc_14 powa_14 pgmp_14 pgq_14
  - pgquarrel-0.7.0-1 pgsql_tweaks_14 pgtap_14 pgtt_14 postgresql-unit_14 postgresql_anonymizer_14 postgresql_faker_14
  - safeupdate_14 semver_14 set_user_14 sslutils_14 table_version_14 # pgrouting_14 osm2pgrouting_14
  - clang coreutils diffutils rpm-build rpm-devel rpmlint rpmdevtools bison flex # gcc gcc-c++                      # - build utils - #

repo_url_packages:
  - https://github.com/cybertec-postgresql/vip-manager/releases/download/v1.0.1/vip-manager_1.0.1-1_amd64.rpm
  - https://github.com/Vonng/pg_exporter/releases/download/v0.4.1/pg_exporter-0.4.1-1.el7.x86_64.rpm
  - https://github.com/Vonng/pigsty-pkg/releases/download/haproxy/haproxy-2.5.5-1.el7.x86_64.rpm
  - https://github.com/Vonng/loki-rpm/releases/download/v2.4.2/loki-2.4.2-1.el7.x86_64.rpm
  - https://github.com/Vonng/loki-rpm/releases/download/v2.4.2/promtail-2.4.2-1.el7.x86_64.rpm
  - https://github.com/Vonng/pigsty-pkg/releases/download/postgrest/postgrest-9.0.0-1.el7.x86_64.rpm
  - https://github.com/Vonng/pigsty-pkg/releases/download/misc/polysh-0.4-1.noarch.rpm
  - https://github.com/dalibo/pev2/releases/download/v0.24.0/pev2.tar.gz
  - https://github.com/sosedoff/pgweb/releases/download/v0.11.10/pgweb_linux_amd64.zip
  - https://github.com/Vonng/pigsty-pkg/releases/download/misc/redis-6.2.6-1.el7.remi.x86_64.rpm

```

</details>


为了确保系统的稳定，Pigsty会在初始化过程中从互联网下载所有依赖的软件包，建立本地Yum源，以加速后续安装步骤。

所有依赖的软件总大小约1GB左右，下载速度取决于您的网络情况。

建立本地Yum源时，如果`{{ repo_home }}/{{ repo_name }}`目录已经存在，而且目录中存在名为`repo_complete`的标记文件，
Pigsty会认为本地Yum源已经初始化完毕，跳过软件下载阶段。

尽管Pigsty已经尽量使用镜像源以加速下载，但少量包的下载仍可能受到防火墙的阻挠。如果某些软件包的下载速度过慢，
您可以通过`proxy_env`配置项设置下载代理以完成首次下载，或直接下载预先打包好的[离线安装包](t-offline.md)。

离线安装包即是把`{{ repo_home }}/{{ repo_name }}`目录整个打成压缩包`pkg.tgz`。
在`configure`过程中，如果Pigsty发现离线软件包`/tmp/pkg.tgz`存在，则会将其解压至`{{ repo_home }}/{{ repo_name }}`目录

默认的离线安装包基于CentOS 7.8.2003 x86_64操作系统制作，如果您使用的操作系统与此不同，或并非使用全新安装的操作系统环境，则有概率出现RPM软件包冲突与依赖错误的问题。
在此情况下，您依然可以使用大部分离线软件包中的内容：只需要删除 `{{ repo_home }}/{{ repo_name }}/repo_complete` （默认为`/www/pigsty/repo_complete`）标记文件，
并移除所有冲突的软件包，从您当前操作系统可用的YUM源（默认备份于`/etc/yum.repos.d/backup`）下载兼容的软件包。


### `repo_enabled`

如果为`true`（默认情况），执行正常的本地yum源创建流程，否则跳过构建本地yum源的操作。



### `repo_name`

本地yum源的**名称**，默认为`pigsty`，您可以改为自己喜欢的名称，例如`pgsql-rhel7`等。



### `repo_address`

本地yum源对外提供服务的地址，可以是域名也可以是IP地址，默认为`yum.pigsty`。

如果使用域名，您必须确保在当前环境中该域名会解析到本地源所在的服务器，也就是元节点。

如果您的本地yum源没有使用标准的80端口，您需要在地址中加入端口，并与`repo_port`变量保持一致。

您可以通过[节点](v-nodes.md)参数中的静态DNS配置来为环境中的所有节点写入`Pigsty`本地源的域名，沙箱环境中即是采用这种方式来解析默认的`yum.pigsty`域名。



### `repo_port`

本地yum源使用的HTTP端口，默认为80端口。



### `repo_home`

本地yum源的根目录，默认为`www`。

该目录将作为HTTP服务器的根对外暴露。



### `repo_rebuild`

如果为`false`（默认情况），什么都不发生，如果为`true`，那么在任何情况下都会执行Repo重建的工作。



### `repo_remove`

在执行本地源初始化的过程中，是否移除`/etc/yum.repos.d`中所有已有的repo？默认为`true`。

原有repo文件会备份至`/etc/yum.repos.d/backup`中。

因为操作系统已有的源内容不可控，建议强制移除并通过`repo_upstreams`进行显式配置。



### `repo_upstream`

所有添加到`/etc/yum.repos.d`中的Yum源，Pigsty将从这些源中下载软件。

Pigsty默认使用阿里云的CentOS7镜像源，清华大学Grafana镜像源，PackageCloud的Prometheus源，PostgreSQL官方源，以及SCLo，Harbottle，Nginx, Haproxy等软件源。




### `repo_packages`

需要下载的rpm安装包列表，默认下载的软件包如下所示

<details>

```bash
repo_packages:                                                                                                      #  what to download #
  - epel-release nginx wget yum-utils yum createrepo sshpass zip unzip                                              # ----  boot   ---- #
  - ntp chrony uuid lz4 bzip2 nc pv jq vim-enhanced make patch bash lsof wget git tuned perf ftp lrzsz rsync        # ----  node   ---- #
  - numactl grubby sysstat dstat iotop bind-utils net-tools tcpdump socat ipvsadm telnet ca-certificates keepalived # ----- utils ----- #
  - readline zlib openssl openssh-clients libyaml libxml2 libxslt libevent perl perl-devel perl-ExtUtils*           # ---  deps:pg  --- #
  - readline-devel zlib-devel uuid-devel libuuid-devel libxml2-devel libxslt-devel openssl-devel libicu-devel       # --- deps:devel -- #
  - ed mlocate parted krb5-devel apr apr-util audit rsyslog                                                         # --- deps:gpsql -- #
  - grafana prometheus2 pushgateway alertmanager consul consul_exporter consul-template etcd dnsmasq                # -----  meta ----- #
  - node_exporter postgres_exporter nginx_exporter blackbox_exporter redis_exporter                                 # ---- exporter --- #
  - ansible python python-pip python-psycopg2                                                                       # - ansible & py3 - #
  - python3 python3-psycopg2 python36-requests python3-etcd python3-consul python36-urllib3 python36-idna python36-pyOpenSSL python36-cryptography
  - patroni patroni-consul patroni-etcd pgbouncer pg_cli pgbadger pg_activity tail_n_mail                           # -- pgsql common - #
  - pgcenter boxinfo check_postgres emaj pgbconsole pg_bloat_check pgquarrel barman barman-cli pgloader pgFormatter pitrery pspg pgxnclient PyGreSQL pgadmin4
  - postgresql14* postgis32_14* citus_14* pglogical_14* timescaledb-2-postgresql-14 pg_repack_14 wal2json_14        # -- pg14 packages -#
  - pg_qualstats_14 pg_stat_kcache_14 pg_stat_monitor_14 pg_top_14 pg_track_settings_14 pg_wait_sampling_14
  - pg_statement_rollback_14 system_stats_14 plproxy_14 plsh_14 pldebugger_14 plpgsql_check_14 pgmemcache_14 # plr_14
  - mysql_fdw_14 ogr_fdw_14 tds_fdw_14 sqlite_fdw_14 firebird_fdw_14 hdfs_fdw_14 mongo_fdw_14 osm_fdw_14 pgbouncer_fdw_14
  - hypopg_14 geoip_14 rum_14 hll_14 ip4r_14 prefix_14 pguri_14 tdigest_14 topn_14 periods_14
  - bgw_replstatus_14 count_distinct_14 credcheck_14 ddlx_14 extra_window_functions_14 logerrors_14 mysqlcompat_14 orafce_14
  - repmgr_14 pg_auth_mon_14 pg_auto_failover_14 pg_background_14 pg_bulkload_14 pg_catcheck_14 pg_comparator_14
  - pg_cron_14 pg_fkpart_14 pg_jobmon_14 pg_partman_14 pg_permissions_14 pg_prioritize_14 pgagent_14
  - pgaudit16_14 pgauditlogtofile_14 pgcryptokey_14 pgexportdoc_14 pgfincore_14 pgimportdoc_14 powa_14 pgmp_14 pgq_14
  - pgquarrel-0.7.0-1 pgsql_tweaks_14 pgtap_14 pgtt_14 postgresql-unit_14 postgresql_anonymizer_14 postgresql_faker_14
  - safeupdate_14 semver_14 set_user_14 sslutils_14 table_version_14 # pgrouting_14 osm2pgrouting_14
  - clang coreutils diffutils rpm-build rpm-devel rpmlint rpmdevtools bison flex # gcc gcc-c++                      # - build utils - #

```

</details>


### `repo_url_packages`

采用URL直接下载，而非yum下载的软件包。您可以将自定义的软件包连接添加到这里。

Pigsty默认会通过URL下载一些软件：

* `pg_exporter`： **必须项**，监控系统核心组件
* `vip-manager`：**必选项**，启用L2 VIP时所必须的软件包，用于管理VIP
* `loki`, `promtail`：**必选项**，日志收集服务端与客户端二进制。
* `postgrest`：可选，自动根据PostgreSQL数据库模式生成后端API接口
* `polysh`：可选，并行在多台节点上执行ssh命令
* `pev2`：可选，PostgreSQL执行计划可视化
* `pgweb`：可选，网页版PostgreSQL命令行工具
* `redis`：**可选**，当安装Redis时为必选

<details>

```yaml
repo_url_packages:
  - https://github.com/cybertec-postgresql/vip-manager/releases/download/v1.0.1/vip-manager_1.0.1-1_amd64.rpm
  - https://github.com/Vonng/pg_exporter/releases/download/v0.4.1/pg_exporter-0.4.1-1.el7.x86_64.rpm
  - https://github.com/Vonng/pigsty-pkg/releases/download/haproxy/haproxy-2.5.5-1.el7.x86_64.rpm
  - https://github.com/Vonng/loki-rpm/releases/download/v2.4.2/loki-2.4.2-1.el7.x86_64.rpm
  - https://github.com/Vonng/loki-rpm/releases/download/v2.4.2/promtail-2.4.2-1.el7.x86_64.rpm
  - https://github.com/Vonng/pigsty-pkg/releases/download/postgrest/postgrest-9.0.0-1.el7.x86_64.rpm
  - https://github.com/Vonng/pigsty-pkg/releases/download/misc/polysh-0.4-1.noarch.rpm
  - https://github.com/dalibo/pev2/releases/download/v0.24.0/pev2.tar.gz
  - https://github.com/sosedoff/pgweb/releases/download/v0.11.10/pgweb_linux_amd64.zip
  - https://github.com/Vonng/pigsty-pkg/releases/download/misc/redis-6.2.6-1.el7.remi.x86_64.rpm
```

</details>




------------------

## `CA`


<details>
<summary>CA参数默认值</summary>

```yaml
# - ca - #
ca_method: create                             # create|copy|recreate
ca_subject: "/CN=root-ca"                     # self-signed CA subject
ca_homedir: /ca                               # ca cert directory
ca_cert: ca.crt                               # ca public key/cert
ca_key: ca.key                                # ca private key
```

</details>


### `ca_method`

* create：创建新的公私钥用于CA
* copy：拷贝现有的CA公私钥用于构建CA

（Pigsty开源版暂未使用CA基础设施高级安全特性）




### `ca_subject`

CA自签名的主题

默认主题为：

```
"/CN=root-ca"
```


### `ca_homedir`

CA文件的根目录

默认为`/ca`



### `ca_cert`

CA公钥证书名称

默认为：`ca.crt`



### `ca_key`

CA私钥文件名称

默认为`ca.key`




------------------

## `NGINX`

<details>
<summary>NGINX参数默认值</summary>

```yaml
# - nginx - #
nginx_upstream:                               # domain names that will be used for accessing pigsty services
  - { name: home,          domain: pigsty,        endpoint: "10.10.10.10:80" }     # default -> index.html (80)
  - { name: grafana,       domain: g.pigsty,      endpoint: "10.10.10.10:3000" }   # pigsty grafana (3000)
  - { name: loki,          domain: l.pigsty,      endpoint: "10.10.10.10:3100" }   # pigsty loki (3100)
  - { name: prometheus,    domain: p.pigsty,      endpoint: "10.10.10.10:9090" }   # pigsty prometheus (9090)
  - { name: alertmanager,  domain: a.pigsty,      endpoint: "10.10.10.10:9093" }   # pigsty alertmanager (9093)
  # some service can only be accessed via domain name due to security reasons (e.g consul, pgweb, jupyter)
  - { name: consul,        domain: c.pigsty,      endpoint: "127.0.0.1:8500" }     # pigsty consul UI (8500) (domain required)
  - { name: pgweb,         domain: cli.pigsty,    endpoint: "127.0.0.1:8081" }     # pgweb console (8081)
  - { name: jupyter,       domain: lab.pigsty,    endpoint: "127.0.0.1:8888" }     # jupyter lab (8888)

# - app - #
app_list:                                      # show extra application links on home page
  - { name: Pev2    , url : '/pev2'        , comment: 'postgres explain visualizer 2' }
  - { name: Logs    , url : '/logs'        , comment: 'realtime pgbadger log sample' }
  - { name: Report  , url : '/report'      , comment: 'daily log summary report ' }
  - { name: Pkgs    , url : '/pigsty'      , comment: 'local yum repo packages' }
  - { name: Repo    , url : '/pigsty.repo' , comment: 'local yum repo file' }
  - { name: ISD     , url : '${grafana}/d/isd-overview'   , comment: 'noaa isd data visualization' }
  - { name: Covid   , url : '${grafana}/d/covid-overview' , comment: 'covid data visualization' }
  - { name: Applog  , url : '${grafana}/d/applog-overview', comment: 'apple privacy log analysis' }

docs_enabled: true                            # setup local document under default server?
pev2_enabled: true                            # setup pev2 explain visualizer under default server?
pgbadger_enabled: true                        # setup pgbadger under default server?
```

</details>


### `nginx_upstream`

Nginx上游服务的URL与域名

Nginx会通过Host进行流量转发，因此确保访问Pigsty基础设施服务时，配置有正确的域名。

部分基础设施默认只能通过Nginx代理访问（监听地址为`127.0.0.1`的服务：Consul, Pgweb, Jupyter）

不要修改`name` 部分的定义，默认基础设施的`name`是硬编码在任务中的。

```yaml
nginx_upstream:                               # domain names that will be used for accessing pigsty services
  - { name: home,          domain: pigsty,        endpoint: "10.10.10.10:80" }     # default -> index.html (80)
  - { name: grafana,       domain: g.pigsty,      endpoint: "10.10.10.10:3000" }   # pigsty grafana (3000)
  - { name: loki,          domain: l.pigsty,      endpoint: "10.10.10.10:3100" }   # pigsty loki (3100)
  - { name: prometheus,    domain: p.pigsty,      endpoint: "10.10.10.10:9090" }   # pigsty prometheus (9090)
  - { name: alertmanager,  domain: a.pigsty,      endpoint: "10.10.10.10:9093" }   # pigsty alertmanager (9093)
  # some service can only be accessed via domain name due to security reasons (e.g consul, pgweb, jupyter)
  - { name: consul,        domain: c.pigsty,      endpoint: "127.0.0.1:8500" }     # pigsty consul UI (8500) (domain required)
  - { name: pgweb,         domain: cli.pigsty,    endpoint: "127.0.0.1:8081" }     # pgweb console (8081)
  - { name: jupyter,       domain: lab.pigsty,    endpoint: "127.0.0.1:8888" }     # jupyter lab (8888)
```

### `app_list`

用于渲染Pigsty首页的应用列表，每一项都会备渲染为首页导航栏App下拉选单的按钮

其中，`url`中的`${grafana}`会被自动替换为[`nginx_upstream`](#nginx_upstream) 中定义的 Grafana域名。


```yaml
app_list:                                      # show extra application links on home page
  - { name: Pev2    , url : '/pev2'        , comment: 'postgres explain visualizer 2' }
  - { name: Logs    , url : '/logs'        , comment: 'realtime pgbadger log sample' }
  - { name: Report  , url : '/report'      , comment: 'daily log summary report ' }
  - { name: Pkgs    , url : '/pigsty'      , comment: 'local yum repo packages' }
  - { name: Repo    , url : '/pigsty.repo' , comment: 'local yum repo file' }
  - { name: ISD     , url : '${grafana}/d/isd-overview'   , comment: 'noaa isd data visualization' }
  - { name: Covid   , url : '${grafana}/d/covid-overview' , comment: 'covid data visualization' }
  - { name: Applog  , url : '${grafana}/d/applog-overview', comment: 'apple privacy log analysis' }
```

大部分应用均为可选项。



### `docs_enabled`

是否在默认首页中启用本地文档支持？默认启用

本地文档是静态页面，由默认的Nginx提供服务，挂载于`/docs`路径下。



### `pev2_enabled`

是否在默认首页中启用Pev2组件？默认启用

Pev2是一个方便的PostgreSQL执行计划可视化工具，为静态单页应用。

Pev2由默认的Nginx提供服务，挂载于`/pev2`路径下。



### `pgbadger_enabled`

是否在默认首页中启用Pgbadger组件？默认启用

Pgbadger是一个方便的PostgreSQL日志分析工具，可以从PG日志中生成全面美观的网页报告。

Pgabdger由默认的Nginx提供服务，挂载于`/logs`路径与`/report`路径下。



------------------

## `NAMESERVER`

<details>
<summary>NAMESERVER参数默认值</summary>

```yaml
dns_records:
  - 10.10.10.10 pigsty y.pigsty yum.pigsty
```

</details>

### `dns_records`

动态DNS解析记录

每一条记录都会写入元节点的`/etc/hosts`中，并由元节点上的域名服务器提供解析。




------------------

## `PROMETHEUS`


<details>
<summary>PROMETHEUS参数默认值</summary>

```yaml
#------------------------------------------------------------------------------
# Prometheus
#------------------------------------------------------------------------------
# - prometheus - #
prometheus_data_dir: /data/prometheus/data    # prometheus data dir
prometheus_options: '--storage.tsdb.retention=30d'
prometheus_reload: false                      # reload prometheus instead of recreate it
prometheus_sd_method: static                  # service discovery method: static|consul|etcd
prometheus_scrape_interval: 10s               # global scrape & evaluation interval
prometheus_scrape_timeout: 8s                 # scrape timeout
prometheus_sd_interval: 10s                   # service discovery refresh interval
```

</details>


### `prometheus_data_dir`

Prometheus数据目录

默认位于`/data/prometheus/data`



### `prometheus_options`

Prometheus命令行参数

默认参数为：`--storage.tsdb.retention=30d`，即保留30天的监控数据


### `prometheus_reload`

如果为`true`，执行Prometheus任务时不会清除已有数据目录。

默认为：`false`，即执行`prometheus`剧本时会清除已有监控数据。



### `prometheus_sd_method`

Prometheus使用的服务发现机制，默认为`static`，另外的选项 `consul` 将使用Consul进行服务发现。

Pigsty建议使用`static`服务发现，该方式提供了更高的可靠性与灵活性，Consul服务发现将逐步停止支持。

`static`服务发现依赖`/etc/prometheus/targets/{infra,nodes,pgsql,redis}/*.yml`中的配置进行服务发现。
采用这种方式的优势是不依赖Consul。当Pigsty监控系统与外部管控方案集成时，这种模式对原系统的侵入性较小。 

手动维护时，可以根据以下命令从配置文件生成Prometheus所需的监控对象配置文件。

```bash
./nodes.yml -t register_prometheus
./pgsql.yml -t register_prometheus
./redis.yml -t register_prometheus
```

详细信息请参考：[**服务发现**](m-discovery.md)


### `prometheus_scrape_interval`

Prometheus抓取周期，默认为`10s`



### `prometheus_scrape_timeout`

Prometheus抓取超时，默认为`8s`



### `prometheus_sd_interval`

Prometheus刷新服务发现列表的周期，默认为`10s`。



------------------

## `GRAFANA`

<details>
<summary>GRAFANA参数默认值</summary>

```yaml
# - grafana - #
grafana_endpoint: http://10.10.10.10:3000             # grafana endpoint url
grafana_admin_username: admin                         # default grafana admin username
grafana_admin_password: pigsty                        # default grafana admin password
grafana_database: sqlite3                             # default grafana database type: sqlite3|postgres, sqlite3 by default
# if postgres is used, url must be specified. The user is pre-defined in pg-meta.pg_users
grafana_pgurl: postgres://dbuser_grafana:DBUser.Grafana@10.10.10.10:5436/grafana
grafana_plugin: install                               # none|install|always
grafana_cache: /www/pigsty/plugins.tgz                # path to grafana plugins cache tarball
grafana_plugins: []                                   # plugins that will be downloaded via grafana-cli
grafana_git_plugins:                                  # plugins that will be downloaded via git
  - https://github.com/Vonng/grafana-echarts
```

</details>

### `grafana_endpoint`

Grafana对外提供服务的端点，需要带上用户名与密码。

Grafana初始化与安装监控面板会使用该端点调用Grafana API

默认为`http://10.10.10.10:3000`，其中`10.10.10.10`会在`configure`过程中被实际IP替换。



### `grafana_admin_username`

Grafana默认管理用户，默认为`admin`



### `grafana_admin_password`

Grafana管理用户的密码，默认为`pigsty`


### `grafana_database`

Grafana本身数据存储使用的数据库，默认为`sqlite3`文件数据库。

可选为`postgres`，使用`postgres`时，必须确保目标数据库已经存在并可以访问。
（即首次初始化基础设施前无法使用管理节点上的Postgres，因为Grafana先于该数据库而创建）

详情请参考【[教程:使用Postgres作为Grafana后端数据库](t-grafana-upgrade.md)】


### `grafana_pgurl`

当 `grafana_database` 类型为 `postgres`时，所使用的 Postgres 数据库连接串。


### `grafana_plugin`

Grafana插件的供给方式

* `none`：不安装插件
* `install`: 安装Grafana插件（默认）
* `reinstall`: 强制重新安装Grafana插件

Grafana需要访问互联网以下载若干扩展插件，如果您的元节点没有互联网访问，则应当确保使用了离线安装包。
离线安装包中默认已经包含了所有下载好的Grafana插件，位于 [`grafana_cache`](#grafana_cache) 指定的路径下。
当从互联网下载插件时，Pigsty会在下载完成后打包下载好的插件，并放置于 [`grafana_cache`](#grafana_cache) 路径下。



### `grafana_cache`

Grafana插件缓存文件地址

离线安装包中已经包含了所有下载并打包好的Grafana插件，如果插件包目录已经存在，Pigsty就不会尝试从互联网重新下载Grafana插件。

默认的离线插件缓存地址为：`/www/pigsty/plugins.tar.gz` （假设本地Yum源名为`pigsty`）



### `grafana_plugins`

需要从Grafana官方安装的插件列表

数组，每个数组元素是一个字符串，为插件的名称。

插件会通过`grafana-cli plugins install`的方式进行安装。

默认安装的插件包括：

```yaml
grafana_plugins:                              # plugins that will be downloaded via grafana-cli
  - marcusolsson-csv-datasource
  - marcusolsson-json-datasource
  - marcusolsson-treemap-panel


```



### `grafana_git_plugins`

需要通过Git的方式下载的Grafana插件列表

数组，每个数组元素是一个字符串，为插件的Git URL。

一些插件无法通过官方命令行下载，但可以通过Git Clone的方式下载。

插件会通过`cd /var/lib/grafana/plugins && git clone `的方式进行安装。

默认会下载一个可视化插件：`vonng-echarts-panel`，提供为Grafana提供Echarts绘图支持。

```yaml
grafana_git_plugins:                          # plugins that will be downloaded via git
  - https://github.com/Vonng/vonng-echarts-panel
```



------------------

## `LOKI`

<details>
<summary>LOKI参数默认值</summary>

```yaml
# - loki - #
loki_clean: false                             # whether remove existing loki data
loki_options: '-config.file=/etc/loki.yml -config.expand-env=true'
loki_data_dir: /data/loki                     # default loki data dir
loki_retention: 15d                           # log retention period
```

</details>

### `loki_clean`

bool类型，命令行参数，用于指明安装Loki时是否先清理Loki数据目录。


### `loki_options`

字符串类型，用于指定运行Loki时传入的命令行参数，默认为 `-config.file=/etc/loki.yml -config.expand-env=true`。

除非您清楚的知道自己在做什么，修改时请保留上述两个默认参数。


### `loki_data_dir`

字符串类型，文件系统路径，用于指定Loki数据目录位置。

默认位于`/export/loki/`


### `loki_retention`

时间区间类型字符串，用于指定Loki中保留日志的时长，默认为`15d`，即15天。



------------------

## `JUPYTER`

Jupyter目前为可选功能，只在Demo中默认启用。

<details>
<summary>JUPYTER参数默认值</summary>

```yaml
---
jupyter_enabled: true                         # setup jupyter lab server?
jupyter_username: jupyter                     # os user name, special names: default|root (dangerous!)
jupyter_password: pigsty                      # default password for jupyter lab (important!)

# - reference - #
nginx_upstream:                               # domain names that will be used for accessing pigsty services
  - { name: jupyter,       domain: lab.pigsty,    endpoint: "127.0.0.1:8888" }     # jupyter lab (8888)
...
```

</details>

Jupyter Lab 是非常实用的Python数据分析环境。

默认情况下，Demo环境，单机配置模板中会启用 JupyterLab，生产环境部署模版中默认不会启用JupyterLab

要启用Jupyter Lab，用户需要设置 [`jupyter_enabled`](jupyter_enabled) 参数为`true`。

那么Jupyter会使用[`jupyter_username`](jupyter_username) 参数指定的用户运行本地Notebook服务器。

此外，需要配置[`node_meta_pip_install`](v-nodes.md#node_meta_pip_install) 参数，在元数据库初始化时正确通过pip安装。（默认值为 `'jupyterlab'`，无需修改）

Jupyter Lab可以从Pigsty首页导航进入，或通过默认域名 `lab.pigsty` 访问，默认监听于8888端口。

```yaml
# - reference - #
nginx_upstream:                               # domain names that will be used for accessing pigsty services
  - { name: jupyter,       domain: lab.pigsty,    endpoint: "127.0.0.1:8888" }     # jupyter lab (8888)
```

访问需要使用密码，由参数 [`jupyter_password`](v-infra.md#jupyter_password) 指定。

!> 如果您在生产环境中启用了Jupyter，请务必修改Jupyter的密码



### `jupyter_enabled`

是否启用Jupyter Lab服务器？对于演示与个人使用默认启用，对于生产环境部署默认不启用。

对于数据分析、个人学习研究、演示环境，Jupyter Lab非常有用，可以用于完成各类数据分析、处理、演示的工作。

但是Jupyter Lab提供的网页终端与任意代码执行能力对于生产环境非常危险，您必须在充分意识到这一风险的前提下手工启用该功能。

Jupyter Lab的网页界面默认只能通过域名由 Nginx 代理访问，默认为`lab.pigsty`，默认的密码为`pigsty`，默认会使用名为`jupyter`的操作系统用户运行。

```yaml
- { name: jupyter,       domain: lab.pigsty,    endpoint: "127.0.0.1:8888" }     # jupyter lab (8888)
```



### `jupyter_username`

运行Jupyter Lab服务器的操作系统用户。默认为`jupyter`，即会创建一个低权限的默认用户`jupyter`。

其他用户名亦同理，但特殊用户名`default`会使用当前执行安装的用户（通常为管理员）运行 Jupyter Lab，这会更方便，但也更危险。



### `jupyter_password`

Jupyter Lab的密码，默认为`pigsty`。

如果启用Jupyter，强烈建议修改此密码。

加盐混淆的密码默认会写入`~jupyter/.jupyter/jupyter_server_config.json`。




------------------

## `PGWEB`


PGWEB目前为可选功能，只在Demo中默认启用。

<details>
<summary>PGWEB参数默认值</summary>

```yaml
pgweb_enabled: true                         # setup jupyter lab server?
pgweb_username: pgweb                       # os user name, special names: default|root (dangerous!)
```

</details>


### `pgweb_enabled`

是否启用PGWeb服务器？对于演示与个人使用默认启用，对于生产环境部署默认不启用。

PGWEB是一个开箱即用的网页PostgreSQL客户端，可以浏览数据库内对象，执行简单SQL。

PGWEB的网页界面默认只能通过域名由 Nginx 代理访问，默认为`cli.pigsty`，默认会使用名为`pgweb`的操作系统用户运行。

```yaml
- { name: jupyter,       domain: lab.pigsty,    endpoint: "127.0.0.1:8888" }     # jupyter lab (8888)
```


### `pgweb_username`

运行PGWEB服务器的操作系统用户。默认为`pgweb`，即会创建一个低权限的默认用户`pgweb`。

其他用户名亦同理，但特殊用户名`default`会使用当前执行安装的用户（通常为管理员）运行 PGWEB。

您需要数据库的连接串方可通过PGWEB访问环境中的数据库。例如：`postgres://dbuser_dba:DBUser.DBA@127.0.0.1:5432/meta`