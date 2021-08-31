# Node Provision

## Overview

|                            Name                             |    Type    | Level  | Description |
| :----------------------------------------------------------: | :--------: | :---: | ---- |
|                 [nodename](#nodename)                 |  `string`  |  I  | overwrite hostname if specified |
|           [node_dns_hosts](#node_dns_hosts)           |  `string[]`  |  G  | static DNS records |
|          [node_dns_server](#node_dns_server)          |  `enum`  |  G  | how to setup dns service? |
|         [node_dns_servers](#node_dns_servers)         |  `string[]`  |  G  | dynamic DNS servers |
|         [node_dns_options](#node_dns_options)         |  `string[]`  |  G  | /etc/resolv.conf options |
|         [node_repo_method](#node_repo_method)         |  `enum`  |  G  | how to use yum repo (local) |
|         [node_repo_remove](#node_repo_remove)         |  `bool`  |  G  | remove existing repo file? |
|      [node_local_repo_url](#node_local_repo_url)      |  `string[]`  |  G  | local yum repo url |
|            [node_packages](#node_packages)            |  `string[]`  |  G  | pkgs to be installed on all node |
|      [node_extra_packages](#node_extra_packages)      |  `string[]`  |  C/I/A  | extra pkgs to be installed |
|       [node_meta_packages](#node_meta_packages)       |  `string[]`  |  G  | meta node only packages |
| [node_meta_pip_install](#node_meta_pip_install)       |  `string`  |  G  | meta node pip3 packages |
|        [node_disable_numa](#node_disable_numa)        |  `bool`  |  G  | disable numa? |
|        [node_disable_swap](#node_disable_swap)        |  `bool`  |  G  | disable swap? |
|    [node_disable_firewall](#node_disable_firewall)    |  `bool`  |  G  | disable firewall? |
|     [node_disable_selinux](#node_disable_selinux)     |  `bool`  |  G  | disable selinux? |
|      [node_static_network](#node_static_network)      |  `bool`  |  G  | use static DNS config? |
|       [node_disk_prefetch](#node_disk_prefetch)       |  `bool`  |  G  | enable disk prefetch? |
|      [node_kernel_modules](#node_kernel_modules)      |  `string[]`  |  G  | kernel modules to be installed |
|                [node_tune](#node_tune)                |  `enum`  |  G  | node tune mode |
|       [node_sysctl_params](#node_sysctl_params)       |  `dict`  |  G  | extra kernel parameters |
|         [node_admin_setup](#node_admin_setup)         |  `bool`  |  G  | create admin user? |
|           [node_admin_uid](#node_admin_uid)           |  `number`  |  G  | admin user UID |
|      [node_admin_username](#node_admin_username)      |  `string`  |  G  | admin user name |
|  [node_admin_ssh_exchange](#node_admin_ssh_exchange)  |  `bool`  |  G  | exchange admin ssh keys? |
| [node_admin_current_pk](#node_admin_current_pk) | `bool` | A | add current user's pkey? |
|           [node_admin_pks](#node_admin_pks)           |  `string[]`  |  G  | pks to be added to admin |
|         [node_ntp_service](#node_ntp_service)         |  `enum`  |  G  | ntp mode: ntp or chrony? |
|          [node_ntp_config](#node_ntp_config)          |  `bool`  |  G  | setup ntp on node? |
|            [node_timezone](#node_timezone)            |  `string`  |  G  | node timezone |
|         [node_ntp_servers](#node_ntp_servers)         |  `string[]`  |  G  | ntp server list |

## Defaults

```yaml
#------------------------------------------------------------------------------
# NODE PROVISION
#------------------------------------------------------------------------------
# this section defines how to provision nodes
# nodename:                                   # if defined, node's hostname will be overwritten
# meta_node: false                            # node with meta_node will be marked as admin node

# - node dns - #
node_dns_hosts:                               # static dns records in /etc/hosts
  - 10.10.10.10 yum.pigsty
  - 10.10.10.10 meta   pg-meta-1
  - 10.10.10.11 node-1 pg-test-1
  - 10.10.10.12 node-2 pg-test-2
  - 10.10.10.13 node-2 pg-test-3

node_dns_server: add                          # add (default) | none (skip) | overwrite (remove old settings)
node_dns_servers:                             # dynamic nameserver in /etc/resolv.conf
  - 10.10.10.10
node_dns_options:                             # dns resolv options
  - options single-request-reopen timeout:1 rotate
  - domain service.consul

# - node repo - #
node_repo_method: local                       # none|local|public (use local repo for production env)
node_repo_remove: true                        # whether remove existing repo
node_local_repo_url:                          # local repo url (if method=local, make sure firewall is configured or disabled)
  - http://yum.pigsty/pigsty.repo

# - node packages - #
node_packages:                                # common packages for all nodes
  - wget,yum-utils,sshpass,ntp,chrony,tuned,uuid,lz4,vim-minimal,make,patch,bash,lsof,wget,unzip,git,readline,zlib,openssl
  - numactl,grubby,sysstat,dstat,iotop,bind-utils,net-tools,tcpdump,socat,ipvsadm,telnet,tuned,pv,jq
  - python3,python3-psycopg2,python36-requests,python3-etcd,python3-consul
  - python36-urllib3,python36-idna,python36-pyOpenSSL,python36-cryptography
  - node_exporter,consul,consul-template,etcd,haproxy,keepalived,vip-manager
node_extra_packages:                          # extra packages for all nodes
  - patroni,patroni-consul,patroni-etcd,pgbouncer,pgbadger,pg_activity
node_meta_packages:                           # packages for meta nodes only
  - grafana,prometheus2,alertmanager,nginx_exporter,blackbox_exporter,pushgateway
  - nginx,ansible,pgbadger,python-psycopg2,dnsmasq
  - gcc,gcc-c++,clang,coreutils,diffutils,rpm-build,rpm-devel,rpmlint,rpmdevtools
  - zlib-devel,openssl-libs,openssl-devel,libxml2-devel,libxslt-devel
  # - pam-devel,openldap-devel,systemd-devel,tcl-devel,python-devel
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
node_admin_pks:                               # ssh public keys to be added to admin user (REPLACE WITH YOURS!)
  - 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQC7IMAMNavYtWwzAJajKqwdn3ar5BhvcwCnBTxxEkXhGlCO2vfgosSAQMEflfgvkiI5nM1HIFQ8KINlx1XLO7SdL5KdInG5LIJjAFh0pujS4kNCT9a5IGvSq1BrzGqhbEcwWYdju1ZPYBcJm/MG+JD0dYCh8vfrYB/cYMD0SOmNkQ== vagrant@pigsty.com'

# - node ntp - #
node_ntp_service: ntp                         # ntp service provider: ntp|chrony
node_ntp_config: true                         # config ntp service? false will leave it with system default
node_timezone: Asia/Hong_Kong                 # default node timezone
node_ntp_servers:                             # default NTP servers
  - pool cn.pool.ntp.org iburst
  - pool pool.ntp.org iburst
  - pool time.pool.aliyun.com iburst
  - server 10.10.10.10 iburst
  - server ntp.tuna.tsinghua.edu.cn iburst
```





## Details

### nodename

If this parameter is configured, then the `HOSTNAM` of the instance will be overridden by that name.

This option can be used to explicitly specify a name for the node. To use the PG instance name as the node name, you can use the `pg_hostname` option



### node_dns_hosts

The default static DNS resolution records for machine nodes, each of which is written to `/etc/hosts` when the machine node is initialized, are particularly suitable for configuring infrastructure addresses.

`node_dns_hosts` is an array, each element of which is a string shaped like `ip domain_name`, representing a DNS resolution record.

By default, Pigsty writes `10.10.10.10 yum.pigsty` to `/etc/hosts`, so that the local yum source can be accessed using the domain name before the DNS Nameserver starts.



### node_dns_server

The default configuration of the machine node's dynamic DNS server has three modes.

* `add`: Append the records in `node_dns_servers` to `/etc/resolv.conf` and keep the existing DNS servers. (default)
* `overwrite`: use to overwrite `/etc/resolv.conf` with the records in `node_dns_servers`
* `none`: skip DNS server configuration



### node_dns_servers

If `node_dns_server` is configured as `add` or `overwrite`, the records in `node_dns_servers` will be appended or overwritten to `/etc/resolv.conf`. See the Linux documentation for `/etc/resolv.conf` for the exact format.

Pigsty adds meta-nodes as DNS Server by default, and DNSMASQ on the meta-node responds to DNS requests in the environment.

```
node_dns_servers: # dynamic nameserver in /etc/resolv.conf
  - 10.10.10.10
```



### node_dns_options

If `node_dns_server` is configured as `add` or `overwrite`, the records in `node_dns_options` will be appended or overwritten to `/etc/resolv.conf`. See the Linux documentation for `/etc/resolv.conf` for the exact format

The default parsing options added by Pigsty are

```bash
- options single-request-reopen timeout:1 rotate
- domain service.consul
```



### node_repo_method

The way the machine node Yum software source is configured, there are three modes.

* ``local``: use the local Yum source on the meta node, default behavior, recommended.
* `public`: install directly using the Internet source, write the public repo in `repo_upstream` to `/etc/yum.repos.d/`
* `none`: no configuration and modification of local sources.



### node_repo_remove

How to handle the original Yum source, does it remove the original Yum source on the node?

Pigsty by default will **remove** the original configuration file in `/etc/yum.repos.d` and backup it to `/etc/yum.repos.d/backup`



### node_local_repo_url

If `node_repo_method` is configured as `local`, the Repo File URLs listed here will be downloaded to `/etc/yum.repos.d`

Here is an array of Repo File URLs that Pigsty will add to the machine's source configuration by default from the local Yum sources on the meta node.

```
node_local_repo_url:
  - http://yum.pigsty/pigsty.repo
```



### node_packages

A list of packages installed via yum.

The list of packages is an array, but each element can contain multiple packages separated by commas. The default list of packages installed by Pigsty is as follows.

```yaml
node_packages: # common packages for all nodes
  - wget,yum-utils,ntp,chrony,tuned,uuid,lz4,vim-minimal,make,patch,bash,lsof,wget,unzip,git,readline,zlib,openssl
  - numactl,grubby,sysstat,dstat,iotop,bind-utils,net-tools,tcpdump,socat,ipvsadm,telnet,tuned,pv,jq
  - python3,python3-psycopg2,python36-requests,python3-etcd,python3-consul
  - python36-urllib3,python36-idna,python36-pyOpenSSL,python36-cryptography
  - node_exporter,consul,consul-template,etcd,haproxy,keepalived,vip-manager
```



### node_extra_packages

List of extra packages to install via yum.

Similar to `node_packages`, but `node_packages` is usually configured globally and uniformly, while `node_extra_packages` makes exceptions for specific nodes. For example, you can install additional packages for nodes running PG. This variable is usually overridden and defined at cluster and instance level.

The list of additional packages that Pigsty installs by default is as follows.

```yaml
- patroni,patroni-consul,patroni-etcd,pgbouncer,pgbadger,pg_activity
```



### node_meta_packages

List of meta-node packages installed via yum.

Similar to `node_packages` and `node_extra_packages`, but the packages listed in `node_meta_packages` will only be installed on the meta node. So they are usually monitoring software, management tools, build tools, etc. The list of meta-node packages that Pigsty installs by default is as follows

```yaml
node_meta_packages: # packages for meta nodes only
  - grafana,prometheus2,alertmanager,nginx_exporter,blackbox_exporter,pushgateway
  - dnsmasq,nginx,ansible,pgbadger,polysh
```



### node_meta_pip_install

List of meta node packages installed via pip3.

Packages will be downloaded to the `{{ repo_home }}/{{ repo_name }}/python` directory and then installed uniformly.

Currently `jupyterlab` will be installed by default, providing a complete Python runtime environment.



### node_disable_numa

Whether to disable Numa, note that this option requires a reboot to take effect! The default is not to disable it, but it is highly recommended for production environments to disable NUMA.



### node_disable_swap

Whether to disable SWAP, the default is not disabled.

It is not normally recommended to disable SWAP, but if you have enough memory and the database is deployed exclusively, you can disable SWAP to improve performance.



### node_disable_firewall

Whether to turn off firewall, it recommended disabling it, default off.



### node_disable_selinux

Whether to disable SELinux, recommended, disabled by default.




### node_static_network

Whether to use static network configuration, enabled by default

Enabling static network means that your DNS Resolv configuration will not be overwritten by machine reboots and NIC changes. It is recommended to enable it.



### node_disk_prefetch

Is disk prefetching enabled?

Instances deployed for HDDs can optimize throughput, turn it off by default.



### node_kernel_modules

Kernel modules to install

Pigsty will enable the following kernel modules by default

```
node_kernel_modules: [softdog, ip_vs, ip_vs_rr, ip_vs_rr, ip_vs_wrr, ip_vs_sh]
```



### node_tune

A preproduction scheme for machine tuning, based on the `tuned` service. There are four preproduction modes.

* ``tiny``: mini-VM
* `oltp`: regular OLTP database, optimized for latency
* `olap`: regular OLAP database, optimized for throughput
* `crit`: core financial library, optimized for data consistency



### node_sysctl_params

Additional modifications to sysctl system parameters

Dictionary KV structure



### node_admin_setup

Whether to create admin user on each node (password free sudo with ssh), by default it will be created.

Pigsty by default will create admin user named `admin (uid=88)` that can access other nodes in the environment from the meta node via SSH unencrypted and perform unencrypted sudo.



### node_admin_uid

The `uid` of the admin user, default is `88`, please note UID namespace conflicts when assigning.




### node_admin_username

The name of the admin user, default is `dba`



### node_admin_ssh_exchange

Does the SSH key for the admin user get exchanged between the machines currently executing the command?

The exchange is performed by default, so that the administrator can quickly jump between machines.



### node_admin_pks

The key written to admin `~/.ssh/authorized_keys`

Users with the corresponding private key can log in as administrators.



### node_admin_current_pk

Boolean type, usually used as a command line parameter. Used to copy the current user's SSH public key (~/.ssh/id_rsa.pub) to the administrator user's `authorized_keys`. No copy by default.



### node_ntp_service

Specifies the type of NTP service used by the system.

* `ntp`: traditional NTP service
* `chrony`: the time service used by CentOS 7/8 by default



### node_ntp_config

Override existing NTP configuration or not?

Boolean option, overrides by default.




### node_timezone

The default timezone to use

Pigsty uses `Asia/Hong_Kong (HKT)` by default, please adjust it according to your actual situation.

> Please do not use `Asia/Shanghai` timezone, the abbreviation CST will cause a series of log timezone parsing problems.



### node_ntp_servers

NTP server addresses

Pigsty will use the following NTP servers by default, where `10.10.10.10` will be replaced with the IP address of the management node.

```ini
- pool cn.pool.ntp.org iburst
- pool pool.ntp.org iburst
- pool time.pool.aliyun.com iburst
- server 10.10.10.10 iburst
```

