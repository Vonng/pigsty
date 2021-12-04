# Repo (ansible role)

This role will bootstrap a local yum repo and download rpm packages


Tasks:

```yaml
Create local repo directory	TAGS: [infra, repo, repo_dir]
Backup & remove existing repos	TAGS: [infra, repo, repo_upstream]
Add required upstream repos	TAGS: [infra, repo, repo_upstream]
Check repo pkgs cache exists	TAGS: [infra, repo, repo_prepare]
Set fact whether repo_exists	TAGS: [infra, repo, repo_prepare]
Move upstream repo to backup	TAGS: [infra, repo, repo_prepare]
Add local file system repos	TAGS: [infra, repo, repo_prepare]
Remake yum cache if not exists	TAGS: [infra, repo, repo_prepare]
Install repo bootstrap packages	TAGS: [infra, repo, repo_boot]
Render repo nginx server files	TAGS: [infra, repo, repo_nginx]
Disable selinux for repo server	TAGS: [infra, repo, repo_nginx]
Launch repo nginx server	TAGS: [infra, repo, repo_nginx]
Waits repo server online	TAGS: [infra, repo, repo_nginx]
Download web url packages	TAGS: [infra, repo, repo_download]
Download repo packages	TAGS: [infra, repo, repo_download]
Download repo pkg deps	TAGS: [infra, repo, repo_download]
Create local repo index	TAGS: [infra, repo, repo_download]
Copy bootstrap scripts	TAGS: [infra, repo, repo_download, repo_script]
Mark repo cache as valid	TAGS: [infra, repo, repo_download]
```

Related variables:

```yaml
#------------------------------------------------------------------------------
# NODE PROVISION
#------------------------------------------------------------------------------
# this section defines how to provision nodes
# nodename:                                   # if defined, node's hostname will be overwritten
# meta_node: false                            # node with meta_node will be marked as admin node

# - node dns - #
node_dns_hosts:                               # static dns records in /etc/hosts
  - 10.10.10.10 meta
  - 10.10.10.10 pigsty c.pigsty g.pigsty p.pigsty a.pigsty cli.pigsty lab.pigsty

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
  - http://pigsty/pigsty.repo

# - node packages - #
node_packages:                                # common packages for all nodes
  - wget,yum-utils,sshpass,ntp,chrony,tuned,uuid,lz4,vim-minimal,make,patch,bash,lsof,wget,unzip,git,ftp
  - numactl,grubby,sysstat,dstat,iotop,bind-utils,net-tools,tcpdump,socat,ipvsadm,telnet,tuned,pv,jq,perf
  - readline,zlib,openssl,openssl-libs
  - python3,python3-psycopg2,python36-requests,python3-etcd,python3-consul
  - python36-urllib3,python36-idna,python36-pyOpenSSL,python36-cryptography
  - node_exporter,redis_exporter,consul,consul-template,etcd,haproxy,keepalived,vip-manager
node_extra_packages:                          # extra packages for all nodes
  - patroni,patroni-consul,patroni-etcd,pgbouncer,pgbadger,pg_activity
node_meta_packages:                           # packages for meta nodes only
  - grafana,prometheus2,alertmanager,nginx_exporter,blackbox_exporter,pushgateway,redis
  - nginx,ansible,pgbadger,python-psycopg2,dnsmasq
  - gcc,gcc-c++,clang,coreutils,diffutils,rpm-build,rpm-devel,rpmlint,rpmdevtools
  - zlib-devel,openssl-libs,openssl-devel,libxml2-devel,libxslt-devel
node_meta_pip_install: 'jupyterlab'           # pip packages installed on meta


# - node features - #
node_disable_numa: false                      # disable numa, reboot required
node_disable_swap: false                      # disable swap, use with caution
node_disable_firewall: true                   # disable firewall
node_disable_selinux: true                    # disable selinux
node_static_network: true                     # keep dns resolver settings after reboot
node_disk_prefetch: false                     # setup disk prefetch on HDD to increase performance

# - node kernel modules - #
node_kernel_modules: [softdog, br_netfilter, ip_vs, ip_vs_rr, ip_vs_rr, ip_vs_wrr, ip_vs_sh]

# - node tuned - #
node_tune: tiny                               # install and activate tuned profile: none|oltp|olap|crit|tiny
node_sysctl_params: { }                       # set additional sysctl parameters, k:v format
# net.bridge.bridge-nf-call-iptables: 1       # example sysctl parameters

# - node admin - #
node_admin_setup: true                        # create a default admin user defined by `node_admin_*` ?
node_admin_uid: 88                            # uid and gid for this admin user
node_admin_username: dba                      # name of this admin user, dba by default
node_admin_ssh_exchange: true                 # exchange admin ssh key among each pgsql cluster ?
node_admin_pk_current: true                   # add current user's ~/.ssh/id_rsa.pub to admin authorized_keys ?
node_admin_pks:                               # ssh public keys to be added to admin user (REPLACE WITH YOURS!)
  - 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQC7IMAMNavYtWwzAJajKqwdn3ar5BhvcwCnBTxxEkXhGlCO2vfgosSAQMEflfgvkiI5nM1HIFQ8KINlx1XLO7SdL5KdInG5LIJjAFh0pujS4kNCT9a5IGvSq1BrzGqhbEcwWYdju1ZPYBcJm/MG+JD0dYCh8vfrYB/cYMD0SOmNkQ== vagrant@pigsty.com'

# - node tz - #
node_timezone: Asia/Hong_Kong                 # default node timezone, empty will not change

# - node ntp - #
node_ntp_config: true                         # config ntp service? false will leave it with system default
node_ntp_service: ntp                         # ntp service provider: ntp|chrony
node_ntp_servers:                             # default NTP servers
  - pool cn.pool.ntp.org iburst
  - pool pool.ntp.org iburst
  - pool time.pool.aliyun.com iburst
  - server 10.10.10.10 iburst
  - server ntp.tuna.tsinghua.edu.cn iburst
```