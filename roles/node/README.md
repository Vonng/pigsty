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
---
#------------------------------------------------------------------------------
# NODE PROVISION
#------------------------------------------------------------------------------
# this section defines how to provision nodes
# nodename:                                   # if defined, node's hostname will be overwritten
# meta_node: false                            # node with meta_node will be marked as admin node

# - node dns - #
node_dns_hosts:                               # static dns records in /etc/hosts
  - 10.10.10.10 yum.pigsty
node_dns_server: add                          # add (default) | none (skip) | overwrite (remove old settings)
node_dns_servers:                             # dynamic nameserver in /etc/resolv.conf
  - 10.10.10.10
node_dns_options:                             # dns resolv options
  - options single-request-reopen timeout:1 rotate
  - domain service.consul

# - node repo - #
node_repo_method: public                      # none|local|public (use local repo for production env)
node_repo_remove: true                        # whether remove existing repo
node_local_repo_url: [ ]                      # local repo url (if method=local, make sure firewall is configured or disabled)

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
  - dnsmasq,nginx,ansible,pgbadger,python-psycopg2
  - gcc,gcc-c++,clang,coreutils,diffutils,rpm-build,rpm-devel,rpmlint,rpmdevtools
  - zlib-devel,openssl-libs,openssl-devel,pam-devel,libxml2-devel,libxslt-devel,openldap-devel,systemd-devel,tcl-devel,python-devel

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
node_admin_pks: []                            # ssh public keys to be added to admin user (REPLACE WITH YOURS!)

# - node ntp - #
node_ntp_service: ntp                         # ntp service provider: ntp|chrony
node_ntp_config: true                         # config ntp service? false will leave it with system default
node_timezone: Asia/Hong_Kong                 # default node timezone
node_ntp_servers:                             # default NTP servers
  - pool cn.pool.ntp.org iburst
  - pool pool.ntp.org iburst

# - foreign reference - #
# this will be override by user provided repo list
repo_upstreams:                               # additional repos to be installed before downloading
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

  - name: pgdg14-beta
    description: PostgreSQL 14 beta for RHEL/CentOS $releasever - $basearch
    enabled: yes
    gpgcheck: no
    baseurl:
      - https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/testing/14/redhat/rhel-$releasever-$basearch # tuna
      - https://download.postgresql.org/pub/repos/yum/testing/14/redhat/rhel-$releasever-$basearch             # official

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
...

```