# Node (ansible role)

This role will provision a node with following tasks:
* hostname
* timezone
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

### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
tasks:
  node : Setup node default hostname		TAGS: [node, node_hostname]
  node : Setup node default timezone		TAGS: [node, node_timezone]
  node : Node configure disable numa		TAGS: [disable_numa, node, node_feature]
  node : Node configure disable swap		TAGS: [disable_swap, node, node_feature]
  node : Node configure unmount swap		TAGS: [disable_swap, node, node_feature]
  node : Disable transparent hugepage		TAGS: [disable_thp, node, node_feature]
  node : Node configure disable firewall	TAGS: [disable_firewall, node, node_feature]
  node : Node configure disable selinux		TAGS: [disable_selinux, node, node_feature]
  node : Node configure disable selinux now	TAGS: [disable_selinux, node, node_feature]
  node : Node configure cpupower perf		TAGS: [cpupower_performance, node, node_feature]
  node : Node configure disk prefetch		TAGS: [disk_prefetch, node, node_feature]
  node : Install additional kernel modules	TAGS: [node, node_kernel]
  node : Load kernel module on node start	TAGS: [node, node_kernel]
  node : Overwrite default sysctl params	TAGS: [node, node_sysctl]
  node : Change additional sysctl params	TAGS: [node, node_sysctl]
  node : Reload sysctl params from files	TAGS: [node, node_sysctl]
  node : Gather fact cpu total cores		TAGS: [node, node_sysctl_dynamic]
  node : Gather fact memory total size		TAGS: [node, node_sysctl_dynamic]
  node : Gather fact swap total size		TAGS: [node, node_sysctl_dynamic]
  node : Calculate sysctl parameters		TAGS: [node, node_sysctl_dynamic]
  node : Dynamic tuning sysctl parameters	TAGS: [node, node_sysctl_dynamic]
  node : Generate os root user ssh key		TAGS: [node, node_root]
  node : Add no host checking to ssh config	TAGS: [node, node_root]
  node : Fetch root user's public keys		TAGS: [node, node_root]
  node : Exchange root ssh keys in cluster	TAGS: [node, node_root]
  node : Create os admin user group admin	TAGS: [node, node_user]
  node : Create os user postgres:admin		TAGS: [node, node_user]
  node : Create os user prometheus:admin	TAGS: [node, node_user]
  node : Create os dcs user consul:admin	TAGS: [node, node_user]
  node : Create os dcs user etcd:admin		TAGS: [node, node_user]
  node : Allow dbsu postgres nopass sudo	TAGS: [node, node_user]
  node : Add no host checking to ssh config	TAGS: [node, node_user]
  node : Fetch all postgres public keys		TAGS: [node, node_user]
  node : Exchange postgres user's ssh keys	TAGS: [node, node_user]
  node : Let postgres own /dev/watchdog		TAGS: [node, node_user]
  node : Copy default user bash profile		TAGS: [node, node_profile]
  node : Setup node default pam ulimits		TAGS: [node, node_ulimit]
  node : Add static dns records to node		TAGS: [node, node_dns]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
#==============================================================#
# infra provision
#==============================================================#
infra_local_repos: []                 # local yum repo file path
infra_disable_external_repo: false    # disable all other repos except local
infra_proxy_env: {}                   # add proxy environment variable here

# common infra packages
infra_packages:
  - etcd,consul,haproxy,keepalived,node_exporter,chrony,ntp                             # must have
  - uuid,readline,zlib,openssl,libxml2,libxslt,pgbouncer                                # pg util
  - lz4,nc,pv,jq,make,patch,bash,lsof,wget,unzip,git,numactl,grubby,perl-ExtUtils-Embed # basic utils
  - bind-utils,net-tools,sysstat,tcpdump,socat,ipvsadm,python-ipython,python-psycopg2   # net utils

# cloud native support
infra_cloud_native_support: false
infra_cloud_native_packages:
  - docker-ce,docker-ce-cli,rkt,kubelet,kubectl,kubeadm,kubernetes-cni,helm

# build toolchain support
infra_build_essential_support: false
infra_build_essential_packages:
  - gcc,gcc-c++,clang,coreutils,diffutils,rpm-build,rpm-devel,rpmlint,rpmdevtools
  - zlib-devel,openssl-libs,openssl-devel,pam-devel,libxml2-devel,libxslt-devel,openldap-devel,systemd-devel,tcl-devel,python-devel

# add additional packages here
infra_additional_packages: []   # additional rpm packages to be downloaded/installed

# infrastructure metadata
infra_dns_servers: []           # default DNS server
infra_ntp_servers: []           # default NTP server
```