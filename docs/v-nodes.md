# Config: Nodes

Pigsty provides complete host provisioning and monitoring functions. The [`nodes.yml`](p-nodes.md) playbook can be executed to configure the corresponding nodes to the corresponding state and incorporate them into the Pigsty monitoring system.

- [`NODE_IDENTITY`](#NODE_IDENTITY) : Node identity parameters
- [`NODE_DNS`](#NODE_DNS): Node domain name resolution, configure [static DNS records](#node_dns_hosts) and [dynamic resolution](#node_dns_server)
- [`NODE_REPO`](#NODE_REPO): Node Software Source
- [`NODE_PACKAGES`](#NODE_PACKAGES): Node Packages
- [`NODE_FEATURES`](#NODE_FEATURES): Node Functionality Features
- [`NODE_MODULES`](#NODE_MODULES): Node Kernel Module
- [`NODE_TUNE`](#NODE_TUNE): Node parameter tuning
- [`NODE_ADMIN`](#NODE_ADMIN): Node Administrator
- [`NODE_TIME`](#NODE_TIME): Node time zone and time synchronization
- [`NODE_EXPORTER`](#NODE_EXPORTER): Node Indicator Exposer
- [`PROMTAIL`](#PROMTAIL): Log collection component


| ID  |                         Name                          |              Section              |   Type   | Level |              Comment              |
|-----|-------------------------------------------------------|-----------------------------------|----------|-------|------------------------------------|
| 300 | [`meta_node`](#meta_node)                             | [`NODE_IDENTITY`](#NODE_IDENTITY) | bool     | C     | mark this node as meta|
| 301 | [`nodename`](#nodename)                               | [`NODE_IDENTITY`](#NODE_IDENTITY) | string   | I     | node instance identity|
| 302 | [`node_cluster`](#node_cluster)                       | [`NODE_IDENTITY`](#NODE_IDENTITY) | string   | C     | node cluster identity|
| 303 | [`nodename_overwrite`](#nodename_overwrite)           | [`NODE_IDENTITY`](#NODE_IDENTITY) | bool     | C     | overwrite hostname with nodename|
| 304 | [`nodename_exchange`](#nodename_exchange)             | [`NODE_IDENTITY`](#NODE_IDENTITY) | bool     | C     | exchange static hostname|
| 310 | [`node_dns_hosts`](#node_dns_hosts)                   | [`NODE_DNS`](#NODE_DNS)           | string[] | C     | static DNS records|
| 311 | [`node_dns_hosts_extra`](#node_dns_hosts_extra)       | [`NODE_DNS`](#NODE_DNS)           | string[] | C/I   | extra static DNS records|
| 312 | [`node_dns_server`](#node_dns_server)                 | [`NODE_DNS`](#NODE_DNS)           | enum     | C     | how to setup dns service?|
| 313 | [`node_dns_servers`](#node_dns_servers)               | [`NODE_DNS`](#NODE_DNS)           | string[] | C     | dynamic DNS servers|
| 314 | [`node_dns_options`](#node_dns_options)               | [`NODE_DNS`](#NODE_DNS)           | string[] | C     | /etc/resolv.conf options|
| 320 | [`node_repo_method`](#node_repo_method)               | [`NODE_REPO`](#NODE_REPO)         | enum     | C     | how to use yum repo (local)|
| 321 | [`node_repo_remove`](#node_repo_remove)               | [`NODE_REPO`](#NODE_REPO)         | bool     | C     | remove existing repo file?|
| 322 | [`node_local_repo_url`](#node_local_repo_url)         | [`NODE_REPO`](#NODE_REPO)         | url[]    | C     | local yum repo url|
| 330 | [`node_packages`](#node_packages)                     | [`NODE_PACKAGES`](#NODE_PACKAGES) | string[] | C     | pkgs to be installed on all node|
| 331 | [`node_extra_packages`](#node_extra_packages)         | [`NODE_PACKAGES`](#NODE_PACKAGES) | string[] | C     | extra pkgs to be installed|
| 332 | [`node_meta_packages`](#node_meta_packages)           | [`NODE_PACKAGES`](#NODE_PACKAGES) | string[] | G     | meta node only packages|
| 333 | [`node_meta_pip_install`](#node_meta_pip_install)     | [`NODE_PACKAGES`](#NODE_PACKAGES) | string   | G     | meta node pip3 packages|
| 340 | [`node_disable_numa`](#node_disable_numa)             | [`NODE_FEATURES`](#NODE_FEATURES) | bool     | C     | disable numa?|
| 341 | [`node_disable_swap`](#node_disable_swap)             | [`NODE_FEATURES`](#NODE_FEATURES) | bool     | C     | disable swap?|
| 342 | [`node_disable_firewall`](#node_disable_firewall)     | [`NODE_FEATURES`](#NODE_FEATURES) | bool     | C     | disable firewall?|
| 343 | [`node_disable_selinux`](#node_disable_selinux)       | [`NODE_FEATURES`](#NODE_FEATURES) | bool     | C     | disable selinux?|
| 344 | [`node_static_network`](#node_static_network)         | [`NODE_FEATURES`](#NODE_FEATURES) | bool     | C     | use static DNS config?|
| 345 | [`node_disk_prefetch`](#node_disk_prefetch)           | [`NODE_FEATURES`](#NODE_FEATURES) | bool     | C     | enable disk prefetch?|
| 346 | [`node_kernel_modules`](#node_kernel_modules)         | [`NODE_MODULES`](#NODE_MODULES)   | string[] | C     | kernel modules to be installed|
| 350 | [`node_tune`](#node_tune)                             | [`NODE_TUNE`](#NODE_TUNE)         | enum     | C     | node tune mode|
| 351 | [`node_sysctl_params`](#node_sysctl_params)           | [`NODE_TUNE`](#NODE_TUNE)         | dict     | C     | extra kernel parameters|
| 360 | [`node_admin_setup`](#node_admin_setup)               | [`NODE_ADMIN`](#NODE_ADMIN)       | bool     | G     | create admin user?|
| 361 | [`node_admin_uid`](#node_admin_uid)                   | [`NODE_ADMIN`](#NODE_ADMIN)       | int      | G     | admin user UID|
| 362 | [`node_admin_username`](#node_admin_username)         | [`NODE_ADMIN`](#NODE_ADMIN)       | string   | G     | admin user name|
| 363 | [`node_admin_ssh_exchange`](#node_admin_ssh_exchange) | [`NODE_ADMIN`](#NODE_ADMIN)       | bool     | C     | exchange admin ssh keys?|
| 364 | [`node_admin_pk_current`](#node_admin_pk_current)     | [`NODE_ADMIN`](#NODE_ADMIN)       | bool     | A     | pks to be added to admin|
| 365 | [`node_admin_pks`](#node_admin_pks)                   | [`NODE_ADMIN`](#NODE_ADMIN)       | key[]    | C     | add current user's pkey?|
| 370 | [`node_timezone`](#node_timezone)                     | [`NODE_TIME`](#NODE_TIME)         | string   | C     | node timezone|
| 371 | [`node_ntp_config`](#node_ntp_config)                 | [`NODE_TIME`](#NODE_TIME)         | bool     | C     | setup ntp on node?|
| 372 | [`node_ntp_service`](#node_ntp_service)               | [`NODE_TIME`](#NODE_TIME)         | enum     | C     | ntp mode: ntp or chrony?|
| 373 | [`node_ntp_servers`](#node_ntp_servers)               | [`NODE_TIME`](#NODE_TIME)         | string[] | C     | ntp server list|
| 380 | [`node_exporter_enabled`](#node_exporter_enabled)     | [`NODE_EXPORTER`](#NODE_EXPORTER) | bool     | C     | node_exporter enabled?|
| 381 | [`node_exporter_port`](#node_exporter_port)           | [`NODE_EXPORTER`](#NODE_EXPORTER) | int      | C     | node_exporter listen port|
| 382 | [`node_exporter_options`](#node_exporter_options)     | [`NODE_EXPORTER`](#NODE_EXPORTER) | string   | C/I   | node_exporter extra cli args|
| 390 | [`promtail_enabled`](#promtail_enabled)               | [`PROMTAIL`](#PROMTAIL)           | bool     | C     | promtail enabled ?|
| 391 | [`promtail_clean`](#promtail_clean)                   | [`PROMTAIL`](#PROMTAIL)           | bool     | C/A   | remove promtail status file ?|
| 392 | [`promtail_port`](#promtail_port)                     | [`PROMTAIL`](#PROMTAIL)           | int      | G     | promtail listen port|
| 393 | [`promtail_options`](#promtail_options)               | [`PROMTAIL`](#PROMTAIL)           | string   | C/I   | promtail cli args|
| 394 | [`promtail_positions`](#promtail_positions)           | [`PROMTAIL`](#PROMTAIL)           | string   | C     | path to store promtail status file|


----------------
## `NODE_IDENTITY`

Each node has **identity parameters** that are configured through the relevant parameters in `<cluster>.hosts` and `<cluster>.vars`.

Pigsty uses an **IP address** as a unique identifier for **database nodes**, **this IP address must be the IP address that the database instance listens to and serves externally**, but it is not appropriate to use a public IP address. Nevertheless, users do not necessarily have to connect to that database via that IP address. For example, the management target node is also operated indirectly through SSH tunnels or springboard machine transit. However, the primary IPv4 address is still the core identifier of the node when identifying the database node. **This is very important and users should ensure this when configuring.** The IP address is the `inventory_hostname` of the host in the configuration manifest and is reflected as the `key` in the `<cluster>.hosts` object.

In addition, nodes have two important identity parameters in the Pigsty monitoring system: [`nodename`](#nodename) and [`node_cluster`](#node_cluster), which will be used in the monitoring system as the node's **instance identifier** (`ins`) and **cluster identifier** (` cls`). When performing the default PostgreSQL deploy, since Pigsty uses node-exclusive 1:1 deploy by default, the identity parameters of the database instance (`pg_cluster` and `pg_instance`) can be [`pg_hostname`](v-pgsql.md#pg_hostname) parameter borrowed to the `ins` and `cls` tags of the node. 

[`nodename`](#nodename) and [`node_cluster`](#node_cluster) are not mandatory; when left blank or empty, [`nodename`](#nodename) will use the node's current hostname, while [`node_cluster`](#node_cluster) will use the fixed default value: `nodes`.

|              Name               |   Type   | Level | Necessity    | Comment               |
| :-----------------------------: | :------: | :---: | ------------ | --------------------- |
|      `inventory_hostname`       |   `ip`   | **-** | **Required** | **Node IP address**   |
|     [`nodename`](#nodename)     | `string` | **I** | Optional     | **Node Name**         |
| [`node_cluster`](#node_cluster) | `string` | **C** | Optional     | **Node cluster name** |

The following cluster config declares a three-node node cluster:

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

This node is a meta node, type: `bool`, level: C, default value: `false`.

In the inventory, nodes under the `meta` grouping carry this flag by default. Nodes with this flag will be additionally configured at node [package installation](#node_packages) with:
Install the RPM pkgs specified by [`node_meta_packages`](#node_meta_packages) and install the Python pkgs specified by [`node_meta_pip_install`](#node_meta_pip_install).




### `nodename`

Specifies the node name, type: `string`, level: I, the default value is null.

This option allows explicitly specifying a name for the node, which is only meaningful when defined at the node instance level. Using the default null value or empty string means that no name is specified for the node and the existing Hostname is used directly as the node name.

The node name `nodename` will be used as the name of the node instance (`ins` tag) in the Pigsty monitoring system. In addition, if [`nodename_overwrite`](#nodename_overwrite) is true, the node name will also be used as the HOSTNAME.

Note: If the [`pg_hostname`](v-pgsql.md#pg_hostname) option is enabled, Pigsty will borrow the identity parameter of the one-by-one corresponding PG instance on the current node, such as `pg-test-1`, as the node name when initializing the node.



### `node_cluster`

Node cluster name, type: `string`, level: C, default value: `"nodes"`.

This option explicitly specifies a cluster name for the node, which is usually meaningful only when defined at the node cluster level. Using the default null value will directly use the fixed value `nodes` as the node cluster identifier.

The node cluster name `node_cluster` will be used as the label of the node cluster (`cls`) in the Pigsty monitoring system.

Note: If the [`pg_hostname`](v-pgsql.md#pg_hostname) option is enabled, Pigsty will borrow the identity parameter of the one-by-one corresponding PG cluster on the current node, such as `pg-test`, as the node cluster name when initializing the node.





### `nodename_overwrite`

Override machine HOSTNAME with node name, type: `bool`, level: C, default value: `true`.

Defaults to `true`, i.e. a non-empty node name [`nodename`](#nodename) will override the current hostname of the node.

If the [`nodename`](#nodename) parameter is undefined, empty, or an empty string, no changes are made to the hostname.




### `nodename_exchange`

Exchange hostnames between playbook nodes, type: `bool`, level: C, default value: `false`.

When this parameter is enabled, node names are exchanged between the same group of nodes executing the [`nodes.yml`](p-nodes.md#nodes) playbook, written to `/etc/hosts`.




----------------
## `NODE_DNS`

Pigsty configs static DNS resolution records and dynamic DNS servers for the nodes.

If your node provider has configured a DNS server for you, you can skip the DNS settings by setting [`node_dns_server`](v-nodes.md#node_dns_server) to `none`. 



### `node_dns_hosts`

Write to static DNS resolution of the machine, type: `string[]`, level: C, default value:

```yaml
node_dns_hosts:                 # static dns records in /etc/hosts
  - 10.10.10.10 meta pigsty c.pigsty g.pigsty l.pigsty p.pigsty a.pigsty cli.pigsty lab.pigsty api.pigsty
```

[`node_dns_hosts`](#node_dns_hosts) is an array, each element is a string shaped like an `ip domain_name`, representing a DNS resolution record, each of which is written to `/etc/hosts` when the machine node is initialized, suitable for global config of infrastructure addresses.

Make sure to write a DNS record like `10.10.10.10 pigsty yum.pigsty` to `/etc/hosts` to ensure that the local yum repo can be accessed using the domain name before the DNS Nameserver starts.





### `node_dns_hosts_extra`

DNS records specific to the cluster instance level, type: `string[]`, level: C/I, default value is an empty array `[]`.






### `node_dns_server`

Config DNS server, type: `enum`, level: C, default value: `"add"`.

The default config of dynamic DNS servers for machine nodes has three modes:

* `add`： Append the records in [`node_dns_servers`](#node_dns_servers) to `/etc/resolv.conf` and keep the existing DNS servers. (default)
* `overwrite`：Overwrite `/etc/resolv.conf` with the record in [`node_dns_servers`](#node_dns_servers)
* `none`： If a DNS server is provided in the production env, the DNS server config can be skipped.




### `node_dns_servers`

Config dynamic DNS server list, type: `string[]`, level: C, default value is `10.10.10.10`.

Pigsty adds meta-nodes as DNS Server by default, and DNSMASQ on the meta-node responds to DNS requests in the env.

```
node_dns_servers: # dynamic nameserver in /etc/resolv.conf
  - 10.10.10.10
```





### `node_dns_options`

If [`node_dns_server`](#node_dns_server) is configured as `add` or `overwrite`, the records in this config entry will be appended or overwritten to `/etc/resolv.conf`. Please see the Linux doc for `/etc/resolv.conf` for the exact format.

The default parsing options added by Pigsty:

```bash
- options single-request-reopen timeout:1 rotate
- domain service.consul
```








----------------
## `NODE_REPO`


Pigsty configs the Yum repos for the nodes to be included in the management and installs the packages.


### `node_repo_method`

A node using Yum repo, type: `enum`, level: C, default value: `"local"`.

The machine node Yum software repo is configured in three modes:

* `local`： Use the local Yum repo on the meta node, the default behavior (recommended).
* `public`： To install using internet sources, write the public repo in `repo_upstream` to `/etc/yum.repos.d/`.
* `none`： No config and modification of local repos.




### `node_repo_remove`

Remove nodes with existing Yum repos, type: `bool`, level: C, default value: `true`.

If enabled, Pigsty will **removal** the original config file in `/etc/yum.repos.d` on the node and backup it to `/etc/yum.repos.d/backup`


### `node_local_repo_url`

URL address of the local repo, type: `url[]`, level: C, default value is `local`.

[`node_repo_method`](#node_repo_method) configured as `local`, the Repo file URLs listed here will be downloaded to `/etc/yum.repos.d`.

Here is an array of Repo File URLs that Pigsty will add by default to the machine's source config for the local Yum repos on the meta node.

```
node_local_repo_url:
  - http://yum.pigsty/pigsty.repo
```





----------------
## `NODE_PACKAGES`



### `node_packages`

List of node installation software, type: `string[]`, level: C, default value:

The package list is an array, but each element can contain multiple pkgs separated by **commas**. The list of pkgs installed by Pigsty by default is as follows:

```yaml
node_meta_packages:                           # packages for meta nodes only
  - grafana,prometheus2,alertmanager,loki,nginx_exporter,blackbox_exporter,pushgateway,redis,postgresql14
  - nginx,ansible,pgbadger,python-psycopg2,dnsmasq,polysh,coreutils,diffutils
```




### `node_extra_packages`

List of additional installed software for the node, type: `string[]`, level: C, default value:

A list of additional pkgs to install via yum, with an empty list by default.

Similar to [`node_packages`](#node_packages), the former is usually configured globally, while [`node_extra_packages`](#node_extra_packages) makes exceptions for specific nodes.
For example, you can install additional toolkits for the nodes running PG. This variable is usually overridden and defined at the cluster level.




### `node_meta_packages`

List of software required by the meta-node, type: `string[]`, level: G, default value:

```yaml
node_meta_packages:                           # packages for meta nodes only
  - grafana,prometheus2,alertmanager,loki,nginx_exporter,blackbox_exporter,pushgateway,redis,postgresql14
  - nginx,ansible,pgbadger,python-psycopg2,dnsmasq,polysh,coreutils,diffutils
```

Similar to [`node_packages`](#node_packages), the pkgs listed in [`node_meta_packages`](#node_meta_packages) will only be installed on the meta-node, and infrastructure software normally used on the meta node needs to be specified here.




### `node_meta_pip_install`

Package installed on the meta-node via pip3, type: `string`, level: G, default value: `"jupyterlab"`.

The package will be downloaded to [`{{ repo_home }}`](v-infra.md#repo_home)/[`{{ repo_name }}`](v-infra.md#repo_name)/`python` directory and then installed uniformly.

Currently, `jupyterlab` will be installed by default, providing a complete Python runtime env.






----------------
## `NODE_FEATURES`


Configure some specific features on the host node.


### `node_disable_numa`

Close the node NUMA, type: `bool`, level: C, default value: `false`.

Boolean flag, default is not off. Note that turning off NUMA requires a reboot of the machine before it can take effect!

If you don't know how to set the affinity with a certain CPU core, it is recommended to turn off NUMA when using the database in a production env.





### `node_disable_swap`

Turn off node SWAP, type: `bool`, level: C, default value: `false`.

Turning off SWAP is not recommended and can be done to improve performance if there is enough memory and the database is deployed exclusively.

SWAP should be disabled when your node is used for a Kubernetes deployment.



### `node_disable_firewall`

Turn off node firewall, type: `bool`, level: C, default value: `true`, please keep it off.





### `node_disable_selinux`

Close node SELINUX, type: `bool`, level: C, default value: `true`, please keep it off.





### `node_static_network`

Use static DNS servers, Type: `bool`, Level: C, Default: `true`, Enabled by default.

Enabling static networking means that your DNS Resolv config will not be overwritten by machine reboots with NIC changes. It is recommended to enable it.





### `node_disk_prefetch`

Enable disk pre-reading, type: `bool`, level: C, default value: `false`, not enabled by default.

Instances deployed against HDDs optimize throughput and are recommended to be enabled when using HDDs.







----------------
## `NODE_MODULES`


Kernel Function Module


### `node_kernel_modules`

Enabled kernel module, type: `string[]`, level: C, default value:

An array consisting of kernel module names declaring the kernel modules that need to be installed on the node. Pigsty will enable the following kernel modules by default:

```
node_kernel_modules: [softdog, ip_vs, ip_vs_rr, ip_vs_rr, ip_vs_wrr, ip_vs_sh]
```








----------------
## `NODE_TUNE`

Host Node Tuning



### `node_tune`

Node tuning mode, type: `enum`, level: C, default value: `"tiny"`.


Prefabricated solutions for machine tuning, based on the `tuned` service. There are four pre-production models:

* `tiny`： Micro Virtual Machine
* `oltp`： Regular OLTP templates with optimized latency
* `olap `： Regular OLAP templates to optimize throughput
* `crit`： Core financial business templates, optimizing the number of dirty pages

Normally, the database tuning template [`pg_conf`](v-pgsql.md#pg_conf) should be paired with the machine tuning template, see [Customize PGSQL Template](v-pgsql-customize.md) for details.



### `node_sysctl_params`

OS kernel parameter, type: `dict`, level: C, default value is an empty dictionary. Dictionary K-V structure, Key is kernel `sysctl` parameter name, Value is the parameter value.








----------------
## `NODE_ADMIN`


Host Node Management Users.


### `node_admin_setup`

Create admin user, type: `bool`, level: G, default value: `true`.

Whether to create an admin user on each node (password-free sudo and ssh), by default an admin user named `dba (uid=88)` will be created, which can access other nodes in the env and perform password-free sudo from the meta-node via SSH password-free.



### `node_admin_uid`

Administrator user UID, type: `int`, level: G, default value: `88`, note UID namespace conflict.



### `node_admin_username`

Administrator username, type: `string`, level: G, default value: `"dba"`.





### `node_admin_ssh_exchange`

Exchange node administrator SSH keys between instances, type: `bool`, level: C, default value: `true`.

When enabled, Pigsty will exchange SSH public keys between members during playbook execution, allowing admins [`node_admin_username`](#node_admin_username) to access each other from different nodes.




### `node_admin_pk_current`

Whether to add the public key of the current node & user to the administrator account, type: `bool`, level: A, default value: `true`.

When enabled, on the current node, the SSH public key (`~/.ssh/id_rsa.pub`) of the current user is copied to the `authorized_keys` of the target node administrator user.

When deploying in a production env, be sure to pay attention to this parameter, which installs the default public key of the user currently executing the command to the administrative user of all machines



### `node_admin_pks`

The list of public keys for login able administrators, type: `key[]`, level: C, default value is an empty array, the demo has the default public key for `vagrant` users.

Each element of the array is a string containing the key written to the administrator user `~/.ssh/authorized_keys`, and the user with the corresponding private key can log in as an administrator.

When deploying in production envs, be sure to note this parameter and add only trusted keys to this list.







----------------
## `NODE_TIME`

The node time zone is synchronized with time.

If the node is already configured with an NTP server, you can configure [`node_ntp_config`](v-nodes.md#node_dns_server) to `false` to skip the setting of the NTP service.


### `node_timezone`

NTP time zone setting, type: `string`, level: C, default value is null.

In the demo, the default time zone used is `"Asia/Hong_Kong"`, please adjust it according to your actual situation. (Please don't use `Asia/Shanghai` time zone, the abbreviation CST will cause a series of log time zone parsing problems)

Select `false`, or leave it blank and Pigsty will not modify the time zone config of this node.



### `node_ntp_config`

Is the NTP service configured? , type: `bool`, level: C, default value: `true`.

Value is  `true`: Pigsty will override the node's `/etc/ntp.conf` or `/etc/chrony.conf` by filling in the NTP server specified by [`node_ntp_servers`](#node_ntp_servers).

If the server node is already configured with an NTP server, it is recommended to turn it off and use the original NTP server.




### `node_ntp_service`

NTP service type: `ntp` or `chrony`, type: `enum`, level: C, default value: `"ntp"`.

Specify the type of NTP service used by the system, by default `ntp` is used as the time service:

* `ntp`： Traditional NTP Service
* `chrony`： Time services used by CentOS 7/8 by default

Only takes effect if [`node_ntp_config`](#node_ntp_config) is true.



### `node_ntp_servers`

List of NTP servers, type: `string[]`, level: C, default value:

```yaml
- pool cn.pool.ntp.org iburst
- pool pool.ntp.org iburst
- pool time.pool.aliyun.com iburst
- server 10.10.10.10 iburst
```

Only takes effect if [`node_ntp_config`](#node_ntp_config) is true.









----------------
## `NODE_EXPORTER`


NodeExporter is used to collect monitoring metrics data from the host.


### `node_exporter_enabled`

Enable node indicator collector, type: `bool`, level: C, default value: `true`.



### `node_exporter_port`

Node Indicator Exposure Port, type: `int`, level: C, default value: `9100`.



### `node_exporter_options`

Node metrics collection option, type: `string`, level: C/I, default value: `"--no-collector.softnet --no-collector.nvme --collector.ntp --collector.tcpstat --collector.processes"`

Pigsty enables `ntp`, `tcpstat`, `processes` three additional metrics, collectors, by default, and disables `softnet`, `nvme` two default metrics collectors.




----------------
## `PROMTAIL`

Host log collection component, used with [Loki](v-infra.md#LOKI) infrastructure config.



### `promtail_enabled`

Enable Protail log collection service at the current node, type: `bool`, level: C, default value: `true`.

When [`promtail`](#promtail) is enabled, Pigsty will generate a configuration file for Promtail, as defined in the inventory, to grab the following logs and send them to the Loki instance specified by [`loki_endpoint`](#loki_endpoint).

* `INFRA`： Infrastructure logs, collected only on meta nodes.
  * `nginx-access`: `/var/log/nginx/access.log`
  * `nginx-error`: `/var/log/nginx/error.log`
  * `grafana`: `/var/log/grafana/grafana.log`

* `NODES`： Host node logs, collected on all nodes.
  * `syslog`: `/var/log/messages`
  * `dmesg`: `/var/log/dmesg`
  * `cron`: `/var/log/cron`

* `PGSQL`： PostgreSQL logs, collected when a node is defined with `pg_cluster`.
  * `postgres`: `/pg/data/log/*.csv`
  * `patroni`: `/pg/log/patroni.log`
  * `pgbouncer`: `/var/log/pgbouncer/pgbouncer.log`

* `REDIS`： Redis logs, collected when a node is defined with `redis_cluster`.
  * `redis`: `/var/log/redis/*.log`




### `promtail_clean`

Remove existing state information when installing protail, type: `bool`, level: C/A, default value: `false`.

The default is not to clean up, when you choose to clean up, Pigsty will remove the existing state file [`promtail_positions`](#promtail_positions) when deploying Promtail, which means that Promtail will recollect all logs on the current node and send them to Loki.

### `promtail_port`

The default port used by promtail, type: `int`, level: G, default value: `9080`.




### `promtail_options`

Promtail command line parameter, type: `string`, level: C/I, default value: `"-config.file=/etc/promtail.yml -config.expand-env=true"`.

Additional command line arguments passed in when running the protail binary, default value: `'-config.file=/etc/promtail.yml -config.expand-env=true'`.

There are already parameters for specifying the config file path and expanding the environment variables in the config file, which are not recommended to be modified.



### `promtail_positions`

Path to promtail status file, type: `string`, level: C, default value：`"/var/log/positions.yaml"`

Promtail records the consumption offsets of all logs, which are periodically written to the file specified by [`promtail_positions`](#promtail_positions).