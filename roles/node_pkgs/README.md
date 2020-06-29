# Infra (ansible role)

This role will provision infrastructure
* install given repo
* install given packages
* configure dns resolver
* configure ntp server


### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
tasks:
  infra : Enlisting cloud native repo		TAGS: [infra, infra_repo]
  infra : Install local yum repo for node	TAGS: [infra, infra_repo]
  infra : Disable all default yum repo		TAGS: [infra, infra_repo]
  infra : Enable local repo to accelerate	TAGS: [infra, infra_repo]
  infra : Enlist cloud native packages		TAGS: [infra, infra_install]
  infra : Enlist build essential packages	TAGS: [infra, infra_install]
  infra : Enlist additional infra packages	TAGS: [infra, infra_install]
  infra : Install infra packages from yum	TAGS: [infra, infra_install]
  infra : Add resovler to /etc/resolv.conf	TAGS: [infra, infra_dns]
  infra : Copy the chrony.conf template		TAGS: [infra, infra_ntp]
  infra : Launch chronyd ntpd service		TAGS: [infra, infra_ntp]
  infra : Create keepalive config dir		TAGS: [infra, infra_vip]
  infra : Copy top level keepalived.conf	TAGS: [infra, infra_vip]
  infra : Copy default keepalived.conf		TAGS: [infra, infra_vip]
  infra : Launch keepalived service unit	TAGS: [infra, infra_vip]
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