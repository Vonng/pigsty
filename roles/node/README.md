# Node (ansible role)

This role will provision a node with following tasks:
* hostname
* features
  * disable numa
  * disable swap
  * disable transparent huge page
  * disable firewall
  * disable selinux
  * cpupower performance
* load kernel module
* load sysctl params
* setup users
  * root ssh exchange
  * admin user group
  * postgres prometheus etcd consul
  * pam limit
  * user profile
* setup static dns
* timezone
* ntp service


### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Set hostname from nodename	TAGS: [node, node-init, node_name]
Fetch hostname from server	TAGS: [node, node-init, node_name]
Exchange hostname among servers	TAGS: [node, node-init, node_name]
Write static dns records to /etc/hosts	TAGS: [node, node-init, node_dns]
Write extra static dns records to /etc/hosts	TAGS: [node, node-init, node_dns]
Get old nameservers	TAGS: [node, node-init, node_resolv]
Write tmp resolv file	TAGS: [node, node-init, node_resolv]
Write resolv options	TAGS: [node, node-init, node_resolv]
Write additional nameservers	TAGS: [node, node-init, node_resolv]
Append existing nameservers	TAGS: [node, node-init, node_resolv]
Swap resolv.conf	TAGS: [node, node-init, node_resolv]
Node configure disable firewall	TAGS: [node, node-init, node_firewall]
Node disable selinux by default	TAGS: [node, node-init, node_firewall]
Backup existing repos	TAGS: [node, node-init, node_repo]
Install upstream repo	TAGS: [node, node-init, node_repo]
Install local repo	TAGS: [node, node-init, node_repo]
Install node basic packages	TAGS: [node, node-init, node_pkgs]
Install node extra packages	TAGS: [node, node-init, node_pkgs]
Install meta specific packages	TAGS: [node, node-init, node_pkgs]
Install node basic packages	TAGS: [node, node-init, node_pkgs]
Install node extra packages	TAGS: [node, node-init, node_pkgs]
Install meta specific packages	TAGS: [node, node-init, node_pkgs]
Install pip3 packages on meta node	TAGS: [node, node-init, node_pip, node_pkgs]
Node configure disable numa	TAGS: [node, node-init, node_feature]
Node configure disable swap	TAGS: [node, node-init, node_feature]
Node configure unmount swap	TAGS: [node, node-init, node_feature]
Node setup static network	TAGS: [node, node-init, node_feature]
Node configure disable firewall	TAGS: [node, node-init, node_feature]
Node configure disk prefetch	TAGS: [node, node-init, node_feature]
Enable linux kernel modules	TAGS: [node, node-init, node_kernel]
Enable kernel module on reboot	TAGS: [node, node-init, node_kernel]
Get config parameter page count	TAGS: [node, node-init, node_tuned]
Get config parameter page size	TAGS: [node, node-init, node_tuned]
Tune shmmax and shmall via mem	TAGS: [node, node-init, node_tuned]
Create tuned profiles	TAGS: [node, node-init, node_tuned]
Render tuned profiles	TAGS: [node, node-init, node_tuned]
Active tuned profile	TAGS: [node, node-init, node_tuned]
Change additional sysctl params	TAGS: [node, node-init, node_tuned]
Copy default user bash profile	TAGS: [node, node-init, node_profile]
Setup node default pam ulimits	TAGS: [node, node-init, node_ulimit]
Create os user group admin	TAGS: [node, node-init, node_admin]
Create os user admin	TAGS: [node, node-init, node_admin]
Grant admin group nopass sudo	TAGS: [node, node-init, node_admin]
Add no host checking to ssh config	TAGS: [node, node-init, node_admin]
Add admin ssh no host checking	TAGS: [node, node-init, node_admin]
Fetch all admin public keys	TAGS: [node, node-init, node_admin]
Exchange all admin ssh keys	TAGS: [node, node-init, node_admin]
Install public keys	TAGS: [node, node-init, node_admin, node_admin_pk_list]
Install current public key	TAGS: [node, node-init, node_admin, node_admin_pk_current]
Setup default node timezone	TAGS: [node, node-init, node_timezone]
Install ntp package	TAGS: [node, node-init, node_ntp, ntp_config]
Install chrony package	TAGS: [node, node-init, node_ntp, ntp_config]
Copy the ntp.conf file	TAGS: [node, node-init, node_ntp, ntp_config]
Copy the chrony.conf template	TAGS: [node, node-init, node_ntp, ntp_config]
Launch ntpd service	TAGS: [node, node-init, node_ntp, ntp_launch]
Launch chronyd service	TAGS: [node, node-init, node_ntp, ntp_launch]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
---
#-----------------------------------------------------------------
# NODE IDENTITY
#-----------------------------------------------------------------
meta_node: false                # node with meta_node flag will be marked as admin node
# nodename:                     # [OPTIONAL] node instance's identity, used as `ins`
node_cluster: nodes             # [OPTIONAL] node cluster identity, 'nodes' by default, used as `cls`
nodename_overwrite: true        # use node's nodename as hostname?
nodename_exchange: false        # exchange hostname among play hosts?

#-----------------------------------------------------------------
# NODE DNS
#-----------------------------------------------------------------
node_etc_hosts_default:                 # static dns records in /etc/hosts
  - 10.10.10.10 meta pigsty c.pigsty g.pigsty l.pigsty p.pigsty a.pigsty cli.pigsty lab.pigsty api.pigsty
node_etc_hosts: []        # extra static dns records in /etc/hosts
node_dns_method: add            # add (default) | none (skip) | overwrite (remove old settings)
node_dns_servers: []            # dynamic nameserver in /etc/resolv.conf
node_dns_options:               # dns resolv options
  - options single-request-reopen timeout:1 rotate
  - domain service.consul

#-----------------------------------------------------------------
# NODE REPO
#-----------------------------------------------------------------
node_repo_method: local         # none|local|public
node_repo_remove: true          # remove existing repo on nodes?
node_local_repo_url:            # list local repo url, if node_repo_method = local
  - http://pigsty/pigsty.repo

#-----------------------------------------------------------------
# NODE PACKAGES
#-----------------------------------------------------------------
node_packages_default:                  # common packages for all nodes
  - wget,sshpass,ntp,chrony,tuned,uuid,lz4,make,patch,bash,lsof,wget,unzip,git,ftp,vim-minimal
  - numactl,grubby,sysstat,dstat,iotop,bind-utils,net-tools,tcpdump,socat,ipvsadm,telnet,tuned,pv,jq,perf,ca-certificates
  - readline,zlib,openssl,openssl-libs,openssh-clients,python3,python36-requests,node_exporter,redis_exporter,consul,etcd,promtail
node_packages: [ ]        # extra packages for all nodes
node_packages_meta:             # extra packages for meta nodes
  - grafana,prometheus2,alertmanager,loki,nginx_exporter,blackbox_exporter,pushgateway,redis,postgresql14
  - nginx,ansible,pgbadger,python-psycopg2,dnsmasq,coreutils,diffutils,polysh
node_packages_meta_pip: jupyterlab  # extra pip packages to be installed on meta nodes

#-----------------------------------------------------------------
# NODE FEATURES
#-----------------------------------------------------------------
node_disable_numa: false        # disable numa, reboot required
node_disable_swap: false        # disable swap, use with caution
node_disable_firewall: true     # disable firewall
node_disable_selinux: true      # disable selinux
node_static_network: true       # keep dns resolver settings after reboot
node_disk_prefetch: false       # setup disk prefetch on HDD to increase performance

#-----------------------------------------------------------------
# NODE MODULES
#-----------------------------------------------------------------
node_kernel_modules: [softdog, br_netfilter, ip_vs, ip_vs_rr, ip_vs_rr, ip_vs_wrr, ip_vs_sh]

#-----------------------------------------------------------------
# NODE TUNE
#-----------------------------------------------------------------
node_tune: tiny                 # install and activate tuned profile: none|oltp|olap|crit|tiny
node_sysctl_params: { }         # set additional sysctl parameters, k:v format

#-----------------------------------------------------------------
# NODE ADMIN
#-----------------------------------------------------------------
node_admin_enabled: true           # create a default admin user defined by `node_admin_*` ?
node_admin_uid: 88               # uid and gid for this admin user
node_admin_username: dba         # name of this admin user, dba by default
node_admin_ssh_exchange: true    # exchange admin ssh key among each pgsql cluster ?
node_admin_pk_current: true      # add current user's ~/.ssh/id_rsa.pub to admin authorized_keys ?
node_admin_pk_list: []               # ssh public keys to be added to admin user (REPLACE WITH YOURS!)

#-----------------------------------------------------------------
# NODE_TIME
#-----------------------------------------------------------------
node_timezone: Asia/Hong_Kong    # default node timezone, empty will not change
node_ntp_enabled: true            # config ntp service? false will leave it with system default
node_ntp_service: ntp            # ntp service provider: ntp|chrony
node_ntp_servers:                # default NTP servers
  - pool cn.pool.ntp.org iburst
  - pool pool.ntp.org iburst
  - pool time.pool.aliyun.com iburst

#-----------------------------------------------------------------
# REPO (Reference)
#-----------------------------------------------------------------
repo_upstreams: [...]
...

```