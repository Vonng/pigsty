# Config: Infra

> Use the [INFRA Playbook](p-pgsql.md), and [deploy the PGSQL](d-pgsql.md) cluster to adjust the cluster state to the state described in [PGSQL Config](v-pgsql.md).
>
> Use the [INFRA](p-infra.md) series playbooks to configure the Pigsty infra.

Infra config deals with such issues: localYum repos, machine node base services: DNS, NTP, kernel modules, parameter tuning, admin users, installing packages, DCS Server setup, monitor infra installation, and initialization (Grafana, Prometheus, Alertmanager), global traffic portal Nginx config, etc.

Usually, the infra requires very few modifications, and the main modification is just a text replacement of the meta node IPs, which is done in [`./configure`](v-config.md#configure) automatically. The other occasional change is to the access domain defined in [`nginx_upstream`](#nginx_upstream). Other parameters are adjusted as needed.


- [`CONNECT`](#CONNECT): Connection parameters
- [`CA`](#CA): CA PKI Infra
- [`NGINX`](#NGINX): Nginx Web Server
- [`REPO`](#REPO): Local repo infra
- [`NAMESERVER`](#NAMESERVER): DNS Server
- [`PROMETHEUS`](#PROMETHEUS): Monitor Time Series Database
- [`EXPORTER`](#EXPORTER): Universal Exporter Config
- [`GRAFANA`](#GRAFANA) : Grafana Visualization Platform
- [`LOKI`](#LOKI): Loki log collection platform
- [`DCS`](#DCS): Distributed Configure Storage Meta DB
- [`CONSUL`](#CONSUL): DCS Implementation: Consul
- [`ETCD`](#ETCD): DCS Implementation: ETCD


## Parameter Overview

The following config entries describe the [**infra**](c-infra.md#infrastructure) deployed on the meta node.

| ID |                            Name                             | Section                     |    Type    | Level | Comment                         |
|--|-------------------------------------------------------------|-----------------------------|------------|-------|---------------------------------|
| 100 | [`proxy_env`](#proxy_env)                 | [`CONNECT`](#CONNECT)       | dict       | G     | proxy env variables             |
| 110 | [`ca_method`](#ca_method)                 | [`CA`](#CA)                 | enum       | G     | ca mode, create,copy,recreate   |
| 111 | [`ca_subject`](#ca_subject)               | [`CA`](#CA)                 | string     | G     | ca subject                      |
| 112 | [`ca_homedir`](#ca_homedir)               | [`CA`](#CA)                 | path       | G     | ca cert home dir                |
| 113 | [`ca_cert`](#ca_cert)                      | [`CA`](#CA)                 | string     | G     | ca cert file name               |
| 114 | [`ca_key`](#ca_key)                       | [`CA`](#CA)                 | string     | G     | ca private key name             |
| 120 | [`nginx_enabled`](#nginx_enabled)         | [`NGINX`](#NGINX)           | bool       | C/I     | enable nginx web server         |
| 121 | [`nginx_home`](#nginx_home)               | [`NGINX`](#NGINX)           | path       | G     | nginx home dir (/www)           |
| 122 | [`nginx_port`](#nginx_port)               | [`NGINX`](#NGINX)           | int        | G     | nginx listen address (80)       |
| 123 | [`nginx_upstream`](#nginx_upstream)       | [`NGINX`](#NGINX)           | upstream[] | G     | nginx upstream definition       |
| 124 | [`nginx_indexes`](#nginx_indexes)         | [`NGINX`](#NGINX)           | app[]      | G     | nginx index page nav entries    |
| 130 | [`repo_name`](#repo_name)                 | [`REPO`](#REPO)             | string     | G     | local yum repo name             |
| 131 | [`repo_address`](#repo_address)           | [`REPO`](#REPO)             | string     | G     | external access port of repo    |
| 132 | [`repo_rebuild`](#repo_rebuild)           | [`REPO`](#REPO)             | bool       | A     | rebuild local yum repo          |
| 133 | [`repo_remove`](#repo_remove)             | [`REPO`](#REPO)             | bool       | A     | remove existing repo file       |
| 134 | [`repo_upstreams`](#repo_upstreams)       | [`REPO`](#REPO)             | repo[]     | G     | upstream repo definition        |
| 135 | [`repo_packages`](#repo_packages)         | [`REPO`](#REPO)             | string[]   | G     | packages to be downloaded       |
| 136 | [`repo_url_packages`](#repo_url_packages) | [`REPO`](#REPO)             | url[]      | G     | pkgs to be downloaded via url   |
| 140 | [`nameserver_enabled`](#nameserver_enabled) | [`NAMESERVER`](#NAMESERVER) | bool       | C/I | enable dnsmasq on meta node |
| 141 | [`dns_records`](#dns_records)                               | [`NAMESERVER`](#NAMESERVER) | string[]   | G     | dynamic DNS records             |
| 150 | [`prometheus_enabled`](#prometheus_enabled)                 | [`PROMETHEUS`](#PROMETHEUS) | bool       | C/I | enable Prometheus on meta |
| 151 | [`prometheus_data_dir`](#prometheus_data_dir)               | [`PROMETHEUS`](#PROMETHEUS) | path       | G     | prometheus data dir             |
| 152 | [`prometheus_options`](#prometheus_options)                 | [`PROMETHEUS`](#PROMETHEUS) | string     | G     | prometheus cli args             |
| 153 | [`prometheus_reload`](#prometheus_reload)                   | [`PROMETHEUS`](#PROMETHEUS) | bool       | A     | prom reload instead of init     |
| 154 | [`prometheus_sd_method`](#prometheus_sd_method)             | [`PROMETHEUS`](#PROMETHEUS) | enum       | G     | consul                          |
| 155 | [`prometheus_scrape_interval`](#prometheus_scrape_interval) | [`PROMETHEUS`](#PROMETHEUS) | interval   | G     | prom scrape interval (10s)      |
| 156 | [`prometheus_scrape_timeout`](#prometheus_scrape_timeout)   | [`PROMETHEUS`](#PROMETHEUS) | interval   | G     | prom scrape timeout (8s)        |
| 157 | [`prometheus_sd_interval`](#prometheus_sd_interval)         | [`PROMETHEUS`](#PROMETHEUS) | interval   | G     | prom discovery refresh interval |
| 160 | [`exporter_install`](#exporter_install)              | [`EXPORTER`](#EXPORTER)   | enum       | G     | Installation of exporter        |
| 161 | [`exporter_repo_url`](#exporter_repo_url)            | [`EXPORTER`](#EXPORTER)   | string     | G     | repo url for yum install        |
| 162 | [`exporter_metrics_path`](#exporter_metrics_path)    | [`EXPORTER`](#EXPORTER)   | string     | G     | URL path for exporting metrics  |
| 170 | [`grafana_enabled`](#grafana_enabled)                | [`GRAFANA`](#GRAFANA)       | bool       | C/I | enable grafana on meta node    |
| 171 | [`grafana_endpoint`](#grafana_endpoint)              | [`GRAFANA`](#GRAFANA)     | url        | G     | grafana API endpoint            |
| 172 | [`grafana_admin_username`](#grafana_admin_username)  | [`GRAFANA`](#GRAFANA)     | string     | G     | grafana admin username          |
| 173 | [`grafana_admin_password`](#grafana_admin_password)  | [`GRAFANA`](#GRAFANA)     | string     | G     | grafana admin password          |
| 174 | [`grafana_database`](#grafana_database)           | [`GRAFANA`](#GRAFANA)        | enum       | G     | grafana backend database type   |
| 175 | [`grafana_pgurl`](#grafana_pgurl)                 | [`GRAFANA`](#GRAFANA)        | url        | G     | grafana backend postgres url    |
| 176 | [`grafana_plugin_method`](#grafana_plugin_method) | [`GRAFANA`](#GRAFANA)        | enum       | G     | Install grafana plugin method   |
| 177 | [`grafana_plugin_cache`](#grafana_plugin_cache)   | [`GRAFANA`](#GRAFANA)        | path       | G     | grafana plugins cache path      |
| 178 | [`grafana_plugin_list`](#grafana_plugin_list)     | [`GRAFANA`](#GRAFANA)        | string[]   | G     | grafana plugins to be installed |
| 179 | [`grafana_plugin_git`](#grafana_plugin_git)       | [`GRAFANA`](#GRAFANA)        | url[]      | G     | grafana plugins via git         |
| 180 | [`loki_enabled`](#loki_enabled)       | [`LOKI`](#LOKI)             | bool       | C/I  | enable loki on meta node      |
| 180 | [`loki_endpoint`](#loki_endpoint)     | [`LOKI`](#LOKI)             | url        | G     | loki endpoint to receive log    |
| 181 | [`loki_clean`](#loki_clean)           | [`LOKI`](#LOKI)             | bool       | A     | remove existing loki data       |
| 182 | [`loki_options`](#loki_options)       | [`LOKI`](#LOKI)             | string     | G     | loki cli args                   |
| 183 | [`loki_data_dir`](#loki_data_dir)     | [`LOKI`](#LOKI)             | string     | G     | loki data path                  |
| 184 | [`loki_retention`](#loki_retention)   | [`LOKI`](#LOKI)             | interval   | G     | loki log keeping period         |
| 190 | [`dcs_name`](#dcs_name)               | [`DCS`](#DCS)               | string     | G     | dcs cluster name (dc)           |
| 191 | [`dcs_servers`](#dcs_servers)         | [`DCS`](#DCS)               | dict       | G     | dcs server dict                 |
| 192 | [`dcs_registry`](#dcs_registry)       | [`DCS`](#DCS)               | enum       | G     | Registration Services           |
| 193 | [`dcs_safeguard`](#dcs_safeguard)     | [`DCS`](#DCS)               | bool       | C/A   | avoid dcs remove at all         |
| 194 | [`dcs_clean`](#dcs_clean)             | [`DCS`](#DCS)               | bool       | C/A   | purge dcs during init?          |
| 195 | [`consul_enabled`](#consul_enabled)   | [`CONSUL`](#CONSUL)         | bool       | G     | enable consul servers/agents  |
| 196 | [`consul_data_dir`](#consul_data_dir) | [`CONSUL`](#CONSUL)         | string     | G     | consul data dir path |
| 197 | [`etcd_enabled`](#etcd_enabled)       | [`ETCD`](#ETCD)             | bool       | G     | enable etcd servers/clients   |
| 198 | [`etcd_data_dir`](#etcd_data_dir)     | [`ETCD`](#ETCD)             | string     | G     | etcd data dir path       |



----------------

## `CONNECT`


### `proxy_env`

Using a proper HTTP proxy, download speeds of several MB per second can be achieved. If you have a proxy server, please configure it via `proxy_env`. The sample example is as follows.

```yaml
proxy_env: # global proxy env when downloading packages
  http_proxy: 'http://username:password@proxy.address.com'
  https_proxy: 'http://username:password@proxy.address.com'
  all_proxy: 'http://username:password@proxy.address.com'
  no_proxy: "localhost,127.0.0.1,10.0.0.0/8,192.168.0.0/16,*.pigsty,*.aliyun.com,mirrors.aliyuncs.com,mirrors.tuna.tsinghua.edu.cn,mirrors.zju.edu.cn"
```



### `ansible_host`

If considering using the **Ansible connection parameter**, your target machine is hidden behind an SSH springboard machine or is not accessible via `ssh ip`.

For example, in the example below, [`ansible_host`](v-infra.md#ansible_host) tells Pigsty to access the target database node using an SSH alias using the `ssh node-1` method instead of the `ssh 10.10.10.11` method. This allows you to freely specify the connection method of the database node and save the connection configuration in the `~/.ssh/config` of the admin user for independent management.

```yaml
  pg-test:
    vars: { pg_cluster: pg-test }
    hosts:
      10.10.10.11: {pg_seq: 1, pg_role: primary, ansible_host: node-1}
      10.10.10.12: {pg_seq: 2, pg_role: replica, ansible_host: node-2}
      10.10.10.13: {pg_seq: 3, pg_role: offline, ansible_host: node-3}
```

`ansible_host` is the most typical of the ansible connection parameters. Usually, as long as the user can access the target machine via `ssh <name>`, configuring the `ansible_host` variable, for instance, with a value of `<name>` and other common Ansible SSH connection parameters are shown below:

> - ansible_host: Specify the target machine's IP, hostname, or SSH alias.
>
> - ansible_port: Specify a different SSH port than 22
>
> - ansible_user: Specify the username to use for SSH
>
> - ansible_ssh_pass: SSH password (Do not store plaintext, and input from the keyboard can be specified by the -k)
>
> - ansible_ssh_private_key_file: SSH private key path
>
> - ansible_ssh_common_args: SSH General Parameters









----------------
## `CA`

Self-Signed CA PKI.


### `ca_method`

CA creation method, type: `enum`, level: G, default value: `"create"`.

* `create`： Create a new CA public-private key pair.
* `copy`： Copy the existing CA public and private keys for building CA.


### `ca_subject`

Self-signed CA theme, type: `string`, level: G, default value: `"/CN=root-ca"`.



### `ca_homedir`

CA certificate root dir, type: `path`, level: G, default value: `"/ca"`.



### `ca_cert`

CA certificate, type: `string`, level: G, default value: `"ca.crt"`.



### `ca_key`

CA private key name, type: `string`, level: G, default value: `"ca.key"`.








----------------
## `NGINX`

Pigsty exposes all Web services through Nginx: Home Page, Grafana, Prometheus, AlertManager, Consul, and other optional tools such as PGWe, Jupyter Lab, Pgadmin, Bytebase ,and other static resource & report such as pgweb schemaspy & pgbadger

Some services on the meta node can be accessed directly through the port, bypassing Nginx, but some services can only be accessed through the Nginx proxy for security reasons. Nginx distinguishes between different services by the domain name.
If the domain name configured for each service does not resolve in the current environment, you will need to configure it in `/etc/hosts`.


### `nginx_enabled`

Enable nginx (and yum repo), type: `bool`, level: C/I, default value: `true`.

Setup nginx server on current meta node?

Set to `false` will skip it.

You can set this parameter to `false` on standby meta nodes when using multiple meta nodes


### `nginx_port`

Local repo port, type: `int`, level: G, default value: `80`.

Pigsty accesses all web services through this port on the meta node. Make sure you can access this port on the meta node.



### `nginx_home`

Local repo root, type: `path`, level: G, default value: `"/www"`.

Nginx root directory which contains static resource and repo resource.



### `nginx_upstream`

Nginx upstream server, Type: `upstream[]`, Level: G, default value:

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

Each record contains three subsections: `name`, `domain`, and `endpoint`, representing the component name, the external access domain, and the internal TCP port, respectively.

The `name` definition of the default record is fixed and referenced by hard-coding, do not modify it. Upstream server records with other names can be added at will.

The `domain` is the domain name that should be used for external access to this upstream server. When accessing the Pigsty Web service, the domain name should be used to access it through the Nginx proxy.

The `endpoint` is an internally reachable TCP port. During the Configure, the placeholder IP `10.10.10.10` will be replaced with the meta node IP. 




### `nginx_indexes`

List of applications displayed in the home navigation bar, type: `app[]`, level: G, default value:

```yaml
nginx_indexes:                            # application nav links on home page
  - { name: Pev2    , url : '/pev2'        , comment: 'postgres explain visualizer 2' }
  - { name: Logs    , url : '/logs'        , comment: 'realtime pgbadger log sample' }
  - { name: Report  , url : '/report'      , comment: 'daily log summary report ' }
  - { name: Pkgs    , url : '/pigsty'      , comment: 'local yum repo packages' }
  - { name: Repo    , url : '/pigsty.repo' , comment: 'local yum repo file' }
  - { name: ISD     , url : '${grafana}/d/isd-overview'   , comment: 'noaa isd data visualization' }
  - { name: Covid   , url : '${grafana}/d/covid-overview' , comment: 'covid data visualization' }
```

Each record is rendered as a navigation link to the Pigsty home page App drop-down menu, and the apps are all optional, mounted by default on the Pigsty default server under `http://pigsty/`.
The `url` parameter specifies the URL PATH for the app, with the exception that if the `${grafana}` string is present in the URL, it will be automatically replaced with the Grafana domain name defined in [`nginx_upstream`](#nginx_upstream).







----------------
## `REPO`

Pigsty is installed on a meta node. Pigsty pulls up a localYum repo for the current environment to install RPM packages.

During initialization, Pigsty downloads all packages and their dependencies (specified by [`repo_packages`](#repo_packages)) from the Internet upstream repo (specified by [`repo_upstreams`](#repo_upstreams)) to [`{{ nginx_home }}`](#nginx_home) / [`{{ repo_name }}`](#repo_name)  (default is `/www/pigsty`). The total size of all dependent software is about 1GB or so.

When creating a localYum repo, Pigsty will skip the software download phase if the directory already exists and if there is a marker file named `repo_complete` in the dir.

If the download speed of some packages is too slow, you can set the download proxy to complete the first download by using the [`proxy_env`](#proxy_env) config entry or directly download the pre-packaged [offline package](t-offline.md).

The offline package is a zip archive of the `{{ nginx_home }}/{{ repo_name }}` dir `pkg.tgz`. During `configure`, if Pigsty finds the offline package `/tmp/pkg.tgz`, it will extract it to `{{ nginx_home }}/{{ repo_name }}`, skipping the software download step during installation.

The default offline package is based on CentOS 7.9.2009 x86_64; if you use a different OS, there may be RPM package conflict and dependency error problems; please refer to the FAQ to solve.




### `repo_name`

Local repo name, type: `string`, level: G, default value: `"pigsty"`. It is not recommended to modify this parameter.




### `repo_address`

Local repo external access address, type: `string`, level: G, default value: `"pigsty"`.

The address of the local yum repo for external services, either a domain name or an IP, the default is `yum. pigsty`.

If you use a domain name, you must ensure that the domain name will resolve correctly to the server where the local repo is located, i.e., the meta node.

If the local yum repo does not use the standard port 80, you need to add the port to the address and keep it consistent with the [`nginx_port`](#nginx_port) variable.

The static DNS config [`node_etc_hosts_default`](v-nodes.md#node_etc_hosts_default) in the [nodes](v-nodes.md) parameter can be used to write the `pigsty` local repo domain name by default for all nodes in the current env.





### `repo_rebuild`

Rebuild Yum repo, type: `bool`, level: A, default value: `false`.

If `true`, then the Repo rebuild will be performed in all cases, i.e., regardless of whether the offline package exists.



### `repo_remove`

Remove existing REPO files, type: `bool`, level: A, default value: `true`.

If `true`, the existing repo in `/etc/yum.repos.d` on the meta node will be removed and backed up to the `/etc/yum.repos.d/backup` dir during the local repo initialization process.

Since the content of existing reports in the OS is not controllable, it is recommended to force the removal of existing repos and configure them explicitly via [`repo_upstreams`](#repo_upstreams).

When the node has other self-configured repos or needs to download some particular version of RPM packages from a specific repo, it can be set to `false` to keep the existing repos.



### `repo_upstreams`

Upstream source of Yum repo, type: `repo[]`, level: G.

We use AliCloud's CentOS7 mirror repo, Tsinghua University's Grafana mirror repo, PackageCloud's Prometheus repo, PostgreSQL official repo, and software repos such as SCLo, Harbottle, and Nginx.




### `repo_packages`

List of software to download for Yum repo, type: `string[]`, level: G, default value.

```yaml
epel-release nginx wget yum-utils yum createrepo_c sshpass zip unzip                                            # ----  boot   ---- #
ntp chrony uuid lz4 bzip2 nc pv jq vim-enhanced make patch bash lsof wget git tuned perf ftp lrzsz rsync        # ----  node   ---- #
numactl grubby sysstat dstat iotop bind-utils net-tools tcpdump socat ipvsadm telnet ca-certificates keepalived # ----- utils ----- #
readline zlib openssl openssh-clients libyaml libxml2 libxslt libevent perl perl-devel perl-ExtUtils*           # ---  deps:pg  --- #
readline-devel zlib-devel uuid-devel libuuid-devel libxml2-devel libxslt-devel openssl-devel libicu-devel       # --- deps:devel -- #
grafana prometheus2 pushgateway alertmanager mtail consul consul_exporter consul-template etcd dnsmasq          # -----  meta ----- #
node_exporter nginx_exporter blackbox_exporter redis_exporter                                                   # ---- exporter --- #
ansible python python-pip python-psycopg2                                                                       # - ansible & py3 - #
python3 python3-psycopg2 python36-requests python3-etcd python3-consul python36-urllib3 python36-idna python36-pyOpenSSL python36-cryptography
patroni patroni-consul patroni-etcd pgbouncer pg_cli pgbadger pg_activity tail_n_mail                           # -- pgsql common - #
pgcenter boxinfo check_postgres emaj pgbconsole pg_bloat_check pgquarrel barman barman-cli pgloader pgFormatter pitrery pspg pgxnclient PyGreSQL
postgresql14* postgis32_14* citus_14* pglogical_14* timescaledb-2-postgresql-14 pg_repack_14 wal2json_14        # -- pg14 packages -#
pg_qualstats_14 pg_stat_kcache_14 pg_stat_monitor_14 pg_top_14 pg_track_settings_14 pg_wait_sampling_14 pg_probackup-std-14
pg_statement_rollback_14 system_stats_14 plproxy_14 plsh_14 pldebugger_14 plpgsql_check_14 pgmemcache_14 # plr_14
mysql_fdw_14 ogr_fdw_14 tds_fdw_14 sqlite_fdw_14 firebird_fdw_14 hdfs_fdw_14 mongo_fdw_14 osm_fdw_14 pgbouncer_fdw_14
hypopg_14 geoip_14 rum_14 hll_14 ip4r_14 prefix_14 pguri_14 tdigest_14 topn_14 periods_14
bgw_replstatus_14 count_distinct_14 credcheck_14 ddlx_14 extra_window_functions_14 logerrors_14 mysqlcompat_14 orafce_14
repmgr_14 pg_auth_mon_14 pg_auto_failover_14 pg_background_14 pg_bulkload_14 pg_catcheck_14 pg_comparator_14
pg_cron_14 pg_fkpart_14 pg_jobmon_14 pg_partman_14 pg_permissions_14 pg_prioritize_14 pgagent_14
pgaudit16_14 pgauditlogtofile_14 pgcryptokey_14 pgexportdoc_14 pgfincore_14 pgimportdoc_14 powa_14 pgmp_14 pgq_14
pgquarrel-0.7.0-1 pgsql_tweaks_14 pgtap_14 pgtt_14 postgresql-unit_14 postgresql_anonymizer_14 postgresql_faker_14
safeupdate_14 semver_14 set_user_14 sslutils_14 table_version_14 # pgrouting_14 osm2pgrouting_14
clang coreutils diffutils rpm-build rpm-devel rpmlint rpmdevtools bison flex # gcc gcc-c++                      # - build utils - #
docker-ce docker-compose kubelet kubectl kubeadm kubernetes-cni helm                                            # - cloud native- #
```

Each line is a set of package names separated by spaces, where the specified software will be downloaded via `repotrack`.




### `repo_url_packages`

Software for direct download via URL, type: `url[]`, level: G

Download some software via URL, not YUM:

* `pg_exporter`: **Must**, core components of the monitor system.
* `vip-manager`: **Must**, package required to enable L2 VIP for managing VIP.
* `loki`, `promtail`: **Must**, log collection server-side and client-side binary.
* `postgrest`: Optional, automatically generate backend API interface based on PostgreSQL mode.
* `polysh`: Optional, execute ssh commands on multiple nodes in parallel.
* `pev2`: Optional, PostgreSQL execution plan visualization
* `pgweb`: Optional, web-based PostgreSQL CLI tool
* `redis`: **Optional**, mandatory when Redis is installed

```yaml
https://github.com/Vonng/loki-rpm/releases/download/v2.5.0/loki-2.5.0.x86_64.rpm
https://github.com/Vonng/loki-rpm/releases/download/v2.5.0/promtail-2.5.0.x86_64.rpm
https://github.com/Vonng/pg_exporter/releases/download/v0.5.0/pg_exporter-0.5.0.x86_64.rpm
https://github.com/cybertec-postgresql/vip-manager/releases/download/v1.0.2/vip-manager-1.0.2-1.x86_64.rpm
https://github.com/Vonng/haproxy-rpm/releases/download/v2.6.1/haproxy-2.6.1-1.el7.x86_64.rpm
https://github.com/Vonng/pigsty-pkg/releases/download/misc/redis-6.2.7-1.el7.remi.x86_64.rpm
https://github.com/dalibo/pev2/releases/download/v0.24.0/pev2.tar.gz
https://github.com/Vonng/pigsty-pkg/releases/download/misc/polysh-0.4-1.noarch.rpm
```






----------------
## `NAMESERVER`

Pigsty will default use DNSMASQ to build an optional battery-included name server on the meta node.



### `nameserver_enabled`

Enable DNSMASQ on the meta node, type: `bool`, level: C/I, default value: `false`.



### `dns_records`

Dynamic DNS resolution record, type: `string[]`, level: G, default value is `[]` empty list, the following resolution records are available by default in the sandbox.

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

Prometheus is the core component of the Pigsty monitor system, used to pull timing data, perform metrics precomputation, and evaluate alarm rules.



### `prometheus_enabled`

Enable Prometheus on the meta node, type: `bool`, level: C/I, default value: `true`.



### `prometheus_data_dir`

Prometheus dir, type: `path`, level: G, default value: `"/data/prometheus/data"`.





### `prometheus_options`

Prometheus CLI parameter, type: `string`, level: G, default value: `"--storage.tsdb.retention=15d --enable-feature=promql-negative-offset"`.

The default parameters will allow Prometheus to enable the negative time offset feature and retain the monitoring data for 15 days by default. If you have a large enough disk, you can increase the length of time that monitoring data is kept.



### `prometheus_reload`

Reload the configuration instead of rebuilding the whole thing when performing Prometheus tasks. Type: `bool`, Level: A, Default: `false`.

By default, executing the `prometheus` task will clear existing monitoring data, but if set to `true`, it will not.




### `prometheus_sd_method`

Service discovery mechanism: static|consul, type: `enum`, level: G, default value: `"static"`.

Prometheus's service discovery mechanism, default `static`, option `consul` Use Consul for service discovery (will be phased out).
Pigsty recommends using `static` for service discovery, which provides more excellent reliability and flexibility.

`static` service discovery relies on the config in `/etc/prometheus/targets/{infra,nodes,pgsql,redis}/*.yml` for service discovery.

The advantage of this method is that the monitoring system does not rely on consult. The monitoring target will give an error prompt when the node goes down instead of disappearing directly. In addition, when the pigsty monitor system is integrated with the external control mode, this mode is less invasive to the original system.

The following command can be used to generate the required monitoring object profile for Prometheus from the config file.

```bash
./nodes.yml -t register_prometheus  # Generate a list of host monitoring targets
./pgsql.yml -t register_prometheus  # Generate a list of PostgreSQL/Pgbouncer/Patroni/Haproxy monitoring targets
./redis.yml -t register_prometheus  # Generate a list of Redis monitoring targets
```




### `prometheus_scrape_interval`

Prometheus crawl period, type: `interval`, level: G, default value: `"10s"`.

Ten seconds - 30 seconds is a suitable crawl period. If a finer granularity of monitoring data is required, this parameter can be adjusted.



### `prometheus_scrape_timeout`

Prometheus grab timeout, type: `interval`, level: G, default value: `"8s"`.

Setting the crawl timeout can effectively avoid avalanches caused by monitoring system queries. This parameter must be less than and close to [`prometheus_scrape_interval`](#prometheus_scrape_interval) to ensure that the length of each crawl does not exceed the crawling period.

### `prometheus_sd_interval`

Prometheus service discovery refresh period, type: `interval`, level: G, default value: `"10s"`.

Prometheus re-examines the local file dir every time specified by this parameter and refreshes the monitoring target object.





----------------
## `EXPORTER`

Define generic metrics exporter options, such as how the Exporter is installed, the URL path to listen to, etc.



### `exporter_install`

To install the monitoring component, type: `enum`, level: G, default value: `"none"`.

Specify how to install Exporter:

* `none`： No installation, (by default, the Exporter has been previously installed by the [`node.pkgs`](v-nodes.md#node_packages_default) task)
* `yum`： Install using yum (if yum installation is enabled, run yum to install [`node_exporter`](v-nodes.md#node_exporter) and [`pg_exporter`](v-pgsql.md#pg_exporter) before deploying Exporter)
* `binary`： Install using a copy binary (copy [`node_exporter`](v-nodes.md#node_exporter) and [`pg_exporter`](v-pgsql.md#pg_exporter) binary directly from the meta node, not recommended)

When installing with `yum`, if `exporter_repo_url` is specified (not empty), the installation will first install the REPO file under that URL into `/etc/yum.repos.d`. This feature allows you to install Exporter directly without initializing the node infrastructure.
It is not recommended for regular users to use `binary` installation. This mode is usually used for emergency troubleshooting and temporary problem fixes.

```bash
<meta>:<pigsty>/files/node_exporter ->  <target>:/usr/bin/node_exporter
<meta>:<pigsty>/files/pg_exporter   ->  <target>:/usr/bin/pg_exporter
```





### `exporter_repo_url`

Yum Repo URL of the monitor component, type: `string`, level: G, default value: `""`.

Default is empty; when [`exporter_install`](#exporter_install) is `yum`, the repo specified by this parameter will be added to the node source list.





### `exporter_metrics_path`

Monitor the exposed URL Path, type: `string`, level: G, default value: `"/metrics"`.

The URL PATH for all Exporter externally exposed metrics, which defaults to `/metrics`, is referenced by the external role [`prometheus`](#prometheus), and Prometheus will apply this config to the monitoring object based on the config here.

Indicator exponents affected by this parameter include:

* [`node_exporter`](v-nodes.md#node_exporter)
* [`pg_exporter`](v-pgsql.md#pg_exporter)
* [`pgbouncer_port`](v-pgsql.md#pgbouncer_port)
* [`haproxy`](v-pgsql.md#haproxy_exporter_port)
* Patroni's Metrics endpoint is currently fixed to `/metrics` and cannot be configured, so it is not affected by this parameter.
* The Metrics endpoint of the Infra component is fixed to `/metrics` and is not affected by this parameter.






----------------
## `GRAFANA`

Grafana is the visualization platform for Pigsty's monitoring system.



### `grafana_enabled`

Enable Grafana on the meta node, type: `bool`, level: C/I, default value: `true`.



### `grafana_endpoint`

Grafana address, type: `url`, level: G, default value: `"http://10.10.10.10:3000"`.

Grafana provides a service endpoint to the public, which is used by the Grafana initialization and installation monitoring panel to call the Grafana API.

The placeholder IP `10.10.10.10` will be replaced by the actual IP during the `configure`.



### `grafana_admin_username`

Grafana administrator username, type: `string`, level: G, default value: `"admin"`.





### `grafana_admin_password`

Grafana administrator password, type: `string`, level: G, default value: `"pigsty"`.





### `grafana_database`

Grafana backend database type, type: `enum`, tier: G, default value: `"sqlite3"`.

The alternative is `postgres`. When using `postgres`, you must ensure that the target database already exists and is accessible. That is, Postgres on the meta node cannot be used before the initialization of the infrastructure for the first time because Grafana was created before that database.

To avoid creating circular dependencies (Grafana depends on Postgres, PostgreSQL depends on the infra, including Grafana), you need to modify this parameter and re-execute [`grafana`](#grafana)-related tasks after the first time you complete the installation.
For details, please see [Tutorial: Using Postgres as a Grafana database](t-grafana-upgrade.md).




### `grafana_pgurl`

PostgreSQL connection string for Grafana, type: `url`, level: G, default value: `"postgres://dbuser_grafana:DBUser.Grafana@meta:5436/grafana"`.

Only valid if the parameter [`grafana_database`](#grafana_database) is `postgres`.





### `grafana_plugin_method`

Install the Grafana plugin, type: `enum`, level: G, default value: `"install"`.

How Grafana plug-ins are provisioned:

* `none`： No plug-in installation.
* `install`: Install the Grafana plugin (default), or skip it if it already exists.
* `reinstall`: Re-download and install the Grafana plugin anyway.

Grafana requires Internet access to download several extension plug-ins, and if your meta-node does not have Internet access, you should ensure that you are using an offline installer.
The offline installation package already contains all downloaded Grafana plugins by default, located under the path specified by [`grafana_plugin_cache`](#grafana_plugin_cache). Pigsty will package the downloaded plugins and place them under that path after the download is complete when downloading plugins from the Internet.




### `grafana_plugin_cache`

Grafana plugin cache address, type: `path`, level: G, default value: `"/www/pigsty/plugins.tgz"`.





### `grafana_plugin_list`

List of installed Grafana plugins, type: `string[]`, level: G, default value:

```yaml
grafana_plugin_list:
  - marcusolsson-csv-datasource
  - marcusolsson-json-datasource
  - marcusolsson-treemap-panel
```

Each array element is a string that represents the name of the plugin. Plugins are installed using `grafana-cli plugins install`.






### `grafana_plugin_git`

Grafana plugin installed from Git, type: `url[]`, level: G, default value:

```yaml
grafana_plugin_git:                          # plugins that will be downloaded via git
  - https://github.com/Vonng/vonng-echarts-panel
```

Some plugins cannot be downloaded via the official command line but can be downloaded via Git Clone. Plugins will be installed via `cd /var/lib/grafana/plugins && git clone `.

A visualization plugin will be downloaded by default: `vonng-echarts-panel`, which provides Echarts drawing support for Grafana.







----------------
## `LOKI`


LOKI is the default log collection server used by Pigsty.



### `loki_enabled`

Enable Loki on the meta node, type: `bool`, level: C/I, default value: `false`.




### `loki_endpoint`

Loki service endpoint for receiving logs, type: `url`, level: G, default value: `"http://10.10.10.10:3100/loki/api/v1/push"`.





### `loki_clean`

Clean up the database directory when installing Loki, type: `bool`, level: A, default value: `false`.




### `loki_options`

Command line arguments for Loki, type: `string`, level: G, default value: `"-config.file=/etc/loki.yml -config.expand-env=true"`.

The default config parameters are used to specify the Loki config file location and to enable the ability to expand environment variables in the config file; it is not recommended to remove these two options.




### `loki_data_dir`

Loki's data directory, type: `string`, level: G, default value: `"/data/loki"`.





### `loki_retention`

Loki log default retention days, type: `interval`, level: G, default value: `"15d"`.





----------------
## `DCS`

Distributed Configuration Store (DCS) is a distributed, highly available meta-database that provides HA consensus and service discovery.

Pigsty supports Consul & ETCD as DCS. Use [`dcs_registry`](#dcs_registry) to specify where to register service,  

Availability of Consul/ETCD is critical for postgres HA. Special care needs to be taken when using the DCS service in a production env.
Availability of DCS itself is achieved through multiple peers. For example, a 3-node DCS cluster allows up to one node to fail, while a 5-node DCS cluster allows 2 nodes to fail. 
In a large-scale production env, it is recommended to use at least 3~5 DCS Servers.
The DCS servers used by Pigsty are specified by the parameter [`dcs_servers`](#dcs_servers), either by using an existing external DCS server cluster or by deploying DCS Servers using nodes managed by Pigsty itself.

By default, Pigsty deploys setup DCS services when nodes are included in management ([`nodes.yml`](p-nodes.md#nodes)), and if the current node is defined in [`dcs_servers`](#dcs_servers), the node will be initialized as a DCS Server.
Pigsty deploys a single node DCS Server on the meta node itself by default. You can use any node as DCS Servers.  Before deploying any HA Postgres Cluster, you should ensure that all DCS Servers have been initialized. (Which is done during `nodes.yml`)


the type of DCS used by [`pg_dcs_type`](#pg_dcs_type) and the location of the service registration by


### `dcs_name`

DCS cluster name, type: `string`, level: G, default value: `"pigsty"`.

Represents the data center name in Consul, and used as initial cluster token in Etcd.



### `dcs_servers`

DCS Server, type: `dict`, level: G, default value:

```yaml
dcs_servers:
  meta-1: 10.10.10.10      # Deploy a single DCS Server on the meta node by default
  # meta-2: 10.10.10.11
  # meta-3: 10.10.10.12 
```

Key is the DCS server instance name, and Value is the server IP address. By default, Pigsty will configure the DCS service for the node in the [node initialization](p-nodes.md#nodes) playbook, which defaults to Consul.

You can use an external DCS server and fill in the addresses of all external DCS Servers. Otherwise, Pigsty will deploy a single instance DCS Server on the meta node (`10.10.10.10` placeholder) by default.
If the current node is defined in [`dcs_servers`](#dcs_servers), i.e., the IP address matches any Value, the node will be initialized as a DCS Server, and its Key will be used as a Consul Server.



### `dcs_registry`

Where to register service, type: `enum`, level: G, default value: `"consul"`.

* `none`： No service registration is performed (`none` will disable [`prometheus_sd_method`](#prometheus_sd_method) = consul ).
* `consul`： Registering services to Consul.
* `etcd`： Registering services into Etcd (not supported yet).



### `dcs_safeguard`

Assure that any running consul instance will not be purged by any [`nodes`](p-nodes.md) playbook., level: C/A, default: `false`

Check [SafeGuard](p-nodes.md#SafeGuard) for details.



### `dcs_clean`

Remove existing consul during node init? level: C/A, default: `false`

This allows the removal of any running consul instance during [`nodes.yml`](p-nodes.yml#nodes), which makes it a true idempotent playbook.

It's a dangerous option so you'd better disable it by default and use it with `-e` CLI args.

!> This parameter not working when [`dcs_safeguard`](#dcs_safeguard) is set to `true`





----------------

## `Consul`

Consul is used for service mesh, traffic control, health check, service registry, service discovery & consensus.


### `consul_enabled`

Enable consul: `bool`, level: G, default value: `true`.

Setup consul servers & agents on all nodes. 


### `consul_data_dir`

Consul data directory, type: `string`, level: G, default value: `"/data/consul"`.





----------------

## `ETCD`

ETCD is used for HA PostgreSQL Leader election, alternative to Consul.

### `etcd_enabled`

Enable etcd: `bool`, level: G, default value: `true`.

Setup etcd servers on nodes in [`dcs_servers`](#dcs_servers), and write credential to all client nodes.


### `etcd_data_dir`

ETCD data directory, type: `string`, level: G, default value: `"/etcd/consul"`.

