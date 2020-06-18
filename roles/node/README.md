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
# node basics
#==============================================================#
# node hostname override : use {{ cluseter }}-{{ seq } if defined
node_overwrite_hostname: true

# node timezone override
node_timezone: 'Asia/Shanghai'     # default node timezone

#==============================================================#
# node features
#==============================================================#
# node feature switch
node_disable_numa: false        # [VERY IMPORTANT] disable numa, skip for vm or single CPU setup
node_disable_swap: true         # [VERY IMPORTANT] disable swap for pg and kubernetes
node_disable_thp: true          # [VERY IMPORTANT] disable transparent huge page
node_disable_firewall: true     # disable firewall to allow haproxy and kubernetes
node_disable_selinux: true      # disable selinux
node_cpupower_performance: true # set cpupower governor to performance mode if available
node_disk_prefetch: false       # setup disk prefetch on HDD to increase performance

# node kernel modeles
node_kernel_modules: [softdog, br_netfilter, ip_vs, ip_vs_rr, ip_vs_rr, ip_vs_wrr, ip_vs_sh, nf_conntrack_ipv4]


#==============================================================#
# node sysctl
#==============================================================#
node_sysctl_dynamic_tune: true  # set some param based on node fact
# additional sysctl parameters (overwrite with your own)
node_sysctl_params:

```