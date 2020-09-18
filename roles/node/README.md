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
  - Update node hostname					TAGS: [node, node_name]
  - Add new hostname to /etc/hosts			TAGS: [node, node_name]
  - Write static dns records				TAGS: [node, node_dns]
  - Get old nameservers						TAGS: [node, node_resolv]
  - Truncate resolv file					TAGS: [node, node_resolv]
  - Write resolv options					TAGS: [node, node_resolv]
  - Add new nameservers						TAGS: [node, node_resolv]
  - Append old nameservers					TAGS: [node, node_resolv]
  - Stop network manager					TAGS: [node, node_resolv]
  - Find all network interface				TAGS: [node, node_network]
  - Add peerdns=no to ifcfg					TAGS: [node, node_network]
  - Backup existing repos					TAGS: [node, node_repo]
  - Install local yum repo					TAGS: [node, node_repo]
  - Install upstream repo					TAGS: [node, node_repo]
  - Config using local repo					TAGS: [node, node_repo]
  - Run yum config manager command			TAGS: [node, node_repo]
  - Install node basic packages				TAGS: [node, node_pkgs]
  - Install node extra packages				TAGS: [node, node_pkgs]
  - Install meta specific packages			TAGS: [node, node_pkgs]
  - Node configure disable numa				TAGS: [node, node_feature]
  - Node configure disable swap				TAGS: [node, node_feature]
  - Node configure unmount swap				TAGS: [node, node_feature]
  - Node configure disable firewall			TAGS: [node, node_feature]
  - Node disable selinux by default			TAGS: [node, node_feature]
  - Node configure disk prefetch			TAGS: [node, node_feature]
  - Enable linux kernel modules				TAGS: [node, node_kernel]
  - Enable kernel module on reboot			TAGS: [node, node_kernel]
  - Get config parameter page count			TAGS: [node, node_tuned]
  - Get config parameter page size			TAGS: [node, node_tuned]
  - Tune shmmax and shmall via mem			TAGS: [node, node_tuned]
  - Create tuned profile postgres			TAGS: [node, node_tuned]
  - Render tuned profile postgres			TAGS: [node, node_tuned]
  - Active tuned profile postgres			TAGS: [node, node_tuned]
  - Change additional sysctl params			TAGS: [node, node_tuned]
  - Copy default user bash profile			TAGS: [node, node_profile]
  - Setup node default pam ulimits			TAGS: [node, node_ulimit]
  - Create os user group admin				TAGS: [node, node_admin]
  - Create os user admin					TAGS: [node, node_admin]
  - Grant admin group nopass sudo			TAGS: [node, node_admin]
  - Add no host checking to ssh config		TAGS: [node, node_admin]
  - Add admin ssh no host checking			TAGS: [node, node_admin]
  - Fetch all admin public keys				TAGS: [node, node_admin]
  - Exchange all admin ssh keys				TAGS: [node, node_admin]
  - Setup default node timezone				TAGS: [node, node_ntp]
  - Copy the chrony.conf template			TAGS: [node, node_ntp]
  - Launch chronyd ntpd service				TAGS: [node, node_ntp]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
#------------------------------------------------------------------------------
# NODE PROVISION
#------------------------------------------------------------------------------
# this section are usually managed by operators, do not enabled these unless
# you are fully aware what you are doing.

# - node type -#
meta_node: false                              # if set, meta packages will be installed

# - node dns - #
node_dns_hosts: []                            # static dns records in /etc/hosts
node_dns_server: add                          # add (default) | none (skip) | overwrite (remove old settings)
node_dns_servers: []                          # dynamic nameserver in /etc/resolv.conf
node_dns_options:                             # dns resolv options
  - options single-request-reopen timeout:1 rotate

# - node repo - #
node_repo_method: public                      # none|local|public (public by default)
node_repo_remove: true                        # whether remove existing repo
node_local_repo_url: []                       # local repo url (if method=local)

#node_repo_add_upstream: false                 # whether add upstream to node
#node_repo_url: []                             # additional repo to be installed via url
#node_local_repo: pigsty                       # if provide, all default repo will be disabled except this
#node_repo_config: []                          # commands to config yum repos

# - node pkgs - #
node_packages:                                # common packages for all nodes
  - wget,yum-utils,ntp,chrony,tuned,uuid,lz4,vim-minimal,make,patch,bash,lsof,wget,unzip,git,readline,zlib,openssl
  - numactl,grubby,sysstat,dstat,iotop,bind-utils,net-tools,tcpdump,socat,ipvsadm,telnet,tuned,pv,jq
  - python-pip,python-psycopg2,node_exporter
  - python3,python3-psycopg2,python36-requests,python3-etcd,python3-consul # python3
  - consul,consul-template,etcd,haproxy,keepalived,vip-manager

  # - postgresql12*
node_extra_packages: []                       # extra packages for nodes
node_meta_packages:                           # packages for meta nodes only
  - grafana,prometheus2,alertmanager,nginx_exporter,blackbox_exporter,pushgateway
  - dnsmasq,nginx,ansible,pgbadger,polysh


# - node features - #
node_disable_numa: false                      # disable numa, important for production database, reboot required
node_disable_swap: true                       # disable swap, important for production database
node_disable_firewall: true                   # disable firewall (required if using kubernetes)
node_disable_selinux: true                    # disable selinux  (required if using kubernetes)
node_static_network: true                     # keep dns resolver settings after reboot
node_disk_prefetch: false                     # setup disk prefetch on HDD to increase performance

# - node kernel modules - #
node_kernel_modules: [softdog, ip_vs, ip_vs_rr, ip_vs_rr, ip_vs_wrr, ip_vs_sh]

# - node tuned - #
node_tune: oltp                               # install and activate tuned profile: oltp|olap|crit|tiny
node_sysctl_params: {}                        # set additional sysctl parameters, k:v format

# - node user - #
node_admin_setup: true                        # setup an default admin user ?
node_admin_uid: 88                            # uid and gid for admin user
node_admin_username: admin                    # default admin user
node_admin_ssh_exchange: true                 # exchange ssh key amoung cluster ?
node_admin_servers: []                        # ssh pub key of these host will to be installed on targets

# - node ntp - #
node_ntp_service: ntp                         # ntp or chrony
node_ntp_config: true                         # overwrite existing ntp config?
node_timezone: Asia/Shanghai                  # default node timezone
node_ntp_servers:                             # default NTP servers
  - pool cn.pool.ntp.org iburst
  - pool pool.ntp.org iburst
  - pool time.pool.aliyun.com iburst
  - server 10.10.10.10 iburst

# - foreign reference - #
# this will be override by user provided repo list
repo_upstreams:                               # additional repos to be installed before downloading
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

  - name: docker
    description: Docker - Aliyun Mirror
    gpgcheck: no
    baseurl: https://mirrors.aliyun.com/docker-ce/linux/centos/7/$basearch/stable

  - name: kubernetes
    description: Kubernetes - Aliyun Mirror
    gpgcheck: no
    baseurl: https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/

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

  - name: pgdg12
    description: PostgreSQL 12 for RHEL/CentOS $releasever - $basearch
    gpgcheck: no
    baseurl: https://download.postgresql.org/pub/repos/yum/12/redhat/rhel-$releasever-$basearch

  - name: pgdg13-updates-testing
    description: PostgreSQL 13 for RHEL/CentOS $releasever - $basearch - Updates testing
    gpgcheck: no
    baseurl: https://download.postgresql.org/pub/repos/yum/testing/13/redhat/rhel-$releasever-$basearch

  - name: centos-sclo
    description: CentOS-$releasever - SCLo
    gpgcheck: no
    # baseurl: http://mirror.centos.org/centos/7/sclo/$basearch/sclo/
    mirrorlist: http://mirrorlist.centos.org?arch=$basearch&release=7&repo=sclo-sclo

  - name: centos-sclo-rh
    description: CentOS-$releasever - SCLo rh
    gpgcheck: no
    # baseurl: http://mirror.centos.org/centos/7/sclo/$basearch/rh/
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

  - name: harbottle
    description: Copr repo for harbottle
    skip_if_unavailable: true
    gpgcheck: no
    baseurl: https://copr-be.cloud.fedoraproject.org/results/harbottle/main/epel-$releasever-$basearch/

```