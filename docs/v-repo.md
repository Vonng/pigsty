# Repo

Pigsty will build a local yum repo during installation.

The repo can be build:

* via pre-downloaded [/tmp/pkg.tgz](t-prepare.md#pigsty-offline-package)
* via upstream repo directly from internet

The total size of all dependent software is around 1GB and the download speed depends on your network. Although Pigsty has tried to use mirror sources to speed up the download, a small number of packages may still be blocked by firewalls and may appear very slow. You can set the download proxy to complete the first download with the `proxy_env` configuration item, or download the pre-packaged **offline installer** directly.

When creating a local Yum source, if the `{{ repo_home }}/{{ repo_name }}` directory already exists and contains the `repo_complete` marker file, Pigsty assumes that the local Yum source has been initialized and therefore skips the software download phase, speeding it up significantly. An offline installer is a zip archive of the entire `{{ repo_home }}/{{ repo_name }}` directory.


## Overview

|                            Name                             |    Type    | Level  | Description |
| :----------------------------------------------------------: | :--------: | :---: | ---- |
|             [repo_enabled](#repo_enabled)             |  `bool`  |   G   | enable local yum repo |
|                [repo_name](#repo_name)                |  `string`  |   G   | local yum repo name |
|             [repo_address](#repo_address)             |  `string`  |   G   | external access point of repo |
|                [repo_port](#repo_port)                |  `number`  |   G   | repo listen address (80) |
|                [repo_home](#repo_home)                |  `string`  |   G   | repo home dir (www) |
|             [repo_rebuild](#repo_rebuild)             |  `bool`  |   A   | rebuild local yum repo? |
|              [repo_remove](#repo_remove)              |  `bool`  |   A   | remove existing repo file? |
|           [repo_upstreams](#repo_upstreams)           |  `object[]`  |   G   | upstream repo definition |
|            [repo_packages](#repo_packages)            | `string[]` | G | packages to be downloaded |
|        [repo_url_packages](#repo_url_packages)        | `string[]` | G | pkgs to be downloaded via url |

## Defaults

```yaml
# - repo basic - #
repo_enabled: true                            # build local yum repo on meta nodes?
repo_name: pigsty                             # local repo name
repo_address: yum.pigsty                      # repo external address (ip:port or url)
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
  - ...

# - what to download - #
repo_packages:
  # repo bootstrap packages
  - epel-release nginx wget yum-utils yum createrepo sshpass unzip                        # bootstrap packages
  - ...

repo_url_packages:
  - https://github.com/Vonng/pg_exporter/releases/download/v0.4.0/pg_exporter-0.4.0-1.el7.x86_64.rpm            # pg_exporter rpm
  - ...

```



## Parameter details

### repo_enabled

If `true` (the default), perform the normal local yum source creation process, otherwise skip the build of local yum sources.



### repo_name

The **name** of the local yum source, the default is `pigsty`, you can change it to something you like, e.g. `pgsql-rhel7` etc.



### repo_address

The address of the local yum source for external services, either a domain name or an IP address, the default is `yum.pigsty`.

If you use a domain name, you must ensure that in the current environment the domain name resolves to the server where the local source is located, i.e. the meta-node.

If your local yum source does not use the standard port 80, you need to add the port to the address and keep it consistent with the `repo_port` variable.

You can write the domain name of the `Pigsty` local source for all nodes in your environment via the static DNS configuration in the [node](/zh/docs/deploy/config/3-node/) parameter, which is used in the sandbox environment to resolve the default `yum.pigsty` domain name.



### repo_port

The HTTP port used by the local yum source, the default is port 80.



### repo_home

The root directory of the local yum source, default is `/www`.

This directory will be exposed to the public as the root of the HTTP server.



### repo_rebuild

If `false` (the default), nothing happens, if `true`, then the repo rebuild will be performed in any case.



### repo_remove

Whether to remove all existing repo from `/etc/yum.repos.d` during the execution of local source initialization; default is `true`.

The existing repo files will be backed up to `/etc/yum.repos.d/backup`.

Since the OS has no control over the content of existing sources, it is recommended to force their removal and configure them explicitly via `repo_upstreams`.



### repo_upstream

All Yum sources added to `/etc/yum.repos.d`, from which Pigsty will download software.

By default, Pigsty uses AliCloud's CentOS7 mirror source, Tsinghua University's Grafana mirror source, PackageCloud's Prometheus source, PostgreSQL official source, and software sources such as SCLo, Harbottle, Nginx, Haproxy, etc.

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

packages that will be downloaded and build as local yum repo

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

packages that will be downloaded directly via curl instead of yum.

you can add extra packages url here.

Pigsty will download following packages via URL by default:

* `pg_exporter` (REQUIRED, monitoring agent for postgres & pgbouncer )
* `vip-manager` (OPTIONAL, required when using l2 vip)
* `loki`, `promtail`, `logcli`, `loki-canary` (OPTIONAL, additional logging support)

```yaml
repo_url_packages:
  - https://github.com/Vonng/pg_exporter/releases/download/v0.4.0/pg_exporter-0.4.0-1.el7.x86_64.rpm            # pg_exporter rpm
  - https://github.com/cybertec-postgresql/vip-manager/releases/download/v1.0/vip-manager_1.0-1_amd64.rpm       # vip manger
  - https://github.com/prometheus/node_exporter/releases/download/v1.2.2/node_exporter-1.1.2.linux-amd64.tar.gz # monitor binaries
  - https://github.com/Vonng/pg_exporter/releases/download/v0.4.0/pg_exporter_v0.4.0_linux-amd64.tar.gz
  - https://github.com/grafana/loki/releases/download/v2.2.1/loki-linux-amd64.zip
  - https://github.com/grafana/loki/releases/download/v2.2.1/promtail-linux-amd64.zip
  - https://github.com/grafana/loki/releases/download/v2.2.1/logcli-linux-amd64.zip
  - https://github.com/grafana/loki/releases/download/v2.2.1/loki-canary-linux-amd64.zip
```



