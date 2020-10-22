# Infrastructure Provision [DRAFT]



## TL;DR

1. Configure infrastructure parameters

    ```bash
    vi config/all.yml
    ```

2. Run infra provision playbook

    ```bash
    ./infra.yml
    ```



## Parameters

```yaml
#------------------------------------------------------------------------------
# CONNECTION PARAMETERS
#------------------------------------------------------------------------------
# this section defines connection parameters

# ansible_user: vagrant             # admin user with ssh access and sudo privilege

proxy_env:                          # global proxy env when downloading packages
  no_proxy: "localhost,127.0.0.1,10.0.0.0/8,192.168.0.0/16,*.pigsty,*.aliyun.com"

#------------------------------------------------------------------------------
# REPO PROVISION
#------------------------------------------------------------------------------
# this section defines how to build a local repo

repo_enabled: true                            # build local yum repo on meta nodes?
repo_name: pigsty                             # local repo name
repo_address: yum.pigsty                      # repo external address (ip:port or url)
repo_port: 80                                 # listen address, must same as repo_address
repo_home: /www                               # default repo dir location
repo_rebuild: false                           # force re-download packages
repo_remove: true                             # remove existing repos
# repo_upstreams: []                          # use role default upstream
# repo_packages: []                           # use role default packages
# repo_url_packages: []                       # use role default web urls


#------------------------------------------------------------------------------
# NODE PROVISION
#------------------------------------------------------------------------------
# this section defines how to provision nodes

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
node_repo_method: local                       # none|local|public (use local repo for production env)
node_repo_remove: true                        # whether remove existing repo
node_local_repo_url:                          # local repo url (if method=local)
  - http://yum.pigsty/pigsty.repo

# - node packages - #
node_extra_packages:                          # extra packages for all nodes (install postgres12 to accelerate initdb)
  - postgresql12*,postgis30_12*,timescaledb_12,citus_12,pglogical_12   # postgres 12 basic
  - pg_qualstats12,pg_cron_12,pg_top12,pg_repack12,pg_squeeze12,pg_stat_kcache12,wal2json12
  - python36-requests,python3-consul,pgbouncer,patroni,pg_exporter,pg_top,pgbadger

# node_packages: []                           # common packages for all nodes (use role default)
# node_meta_packages: []                      # packages for meta nodes only (use role default)

# - node features - #
node_disable_numa: false                      # disable numa, important for production database, reboot required
node_disable_swap: true                       # disable swap, important for production database
node_disable_firewall: true                   # disable firewall (required if using kubernetes)
node_disable_selinux: true                    # disable selinux  (required if using kubernetes)
node_static_network: true                     # keep dns resolver settings after reboot
node_disk_prefetch: false                     # setup disk prefetch on HDD to increase performance

# - node kernel modules - #
node_kernel_modules: [softdog, br_netfilter, ip_vs, ip_vs_rr, ip_vs_rr, ip_vs_wrr, ip_vs_sh, nf_conntrack_ipv4]

# - node tuned - #
node_tune: tiny                               # install and activate tuned profile: none|oltp|olap|crit|tiny
node_sysctl_params:                           # set additional sysctl parameters, k:v format
  net.bridge.bridge-nf-call-iptables: 1       # for kubernetes

# - node user - #
node_admin_setup: true                        # setup an default admin user ?
node_admin_uid: 88                            # uid and gid for admin user
node_admin_username: admin                    # default admin user
node_admin_ssh_exchange: true                 # exchange ssh key among cluster ?
node_admin_pks: []                            # public key list that will be installed

# - node ntp - #
node_ntp_service: ntp                         # ntp or chrony
node_ntp_config: true                         # overwrite existing ntp config?
node_timezone: Asia/Shanghai                  # default node timezone
node_ntp_servers:                             # default NTP servers
  - pool cn.pool.ntp.org iburst
  - pool pool.ntp.org iburst
  - pool time.pool.aliyun.com iburst
  - server 10.10.10.10 iburst


#------------------------------------------------------------------------------
# META PROVISION
#------------------------------------------------------------------------------
# - ca - #
ca_method: create                             # create|copy|recreate
ca_subject: "/CN=root-ca"                     # self-signed CA subject
ca_homedir: /ca                               # ca cert directory
ca_cert: ca.crt                               # ca public key/cert
ca_key: ca.key                                # ca private key

# - nginx - #
nginx_upstream:
  - {name: consul,        host: c.pigsty, url: "127.0.0.1:8500"}
  - {name: grafana,       host: g.pigsty, url: "127.0.0.1:3000"}
  - {name: prometheus,    host: p.pigsty, url: "127.0.0.1:9090"}
  - {name: alertmanager,  host: a.pigsty, url: "127.0.0.1:9093"}

# - nameserver - #
dns_records:                                  # dynamic dns record resolved by dnsmasq
  - 10.10.10.2  pg-meta                       # sandbox vip for pg-meta
  - 10.10.10.3  pg-test                       # sandbox vip for pg-test
  - 10.10.10.10 meta-1                        # sandbox node meta-1 (node-0)
  - 10.10.10.11 node-1                        # sandbox node node-1
  - 10.10.10.12 node-2                        # sandbox node node-2
  - 10.10.10.13 node-3                        # sandbox node node-3
  - 10.10.10.10 pigsty
  - 10.10.10.10 y.pigsty yum.pigsty
  - 10.10.10.10 c.pigsty consul.pigsty
  - 10.10.10.10 g.pigsty grafana.pigsty
  - 10.10.10.10 p.pigsty prometheus.pigsty
  - 10.10.10.10 a.pigsty alertmanager.pigsty
  - 10.10.10.10 n.pigsty ntp.pigsty

# - prometheus - #
prometheus_scrape_interval: 2s                # global scrape & evaluation interval (2s for dev, 15s for prod)
prometheus_scrape_timeout: 1s                 # global scrape timeout (1s for dev, 8s for prod)
prometheus_metrics_path: /metrics             # default metrics path (only affect job 'pg')
prometheus_data_dir: /export/prometheus/data  # prometheus data dir
prometheus_retention: 30d                     # how long to keep

# - grafana - #
grafana_url: http://10.10.10.10:3000           # grafana url
grafana_admin_password: admin                  # default grafana admin user password
grafana_plugin: install                        # none|install|reinstall
grafana_cache: /www/pigsty/grafana/plugins.tar.gz # path to grafana plugins tarball
grafana_provision_mode: db                     # none|db|api
# grafana_plugins: []                          # grafana plugins list (use role default)
# grafana_git_plugins: []                      # grafana plugins from git (use role default)
# grafana_dashboards: []                       # default dashboards (use role default)


#------------------------------------------------------------------------------
# DCS PROVISION
#------------------------------------------------------------------------------
dcs_type: consul                              # consul | etcd | both
dcs_name: pigsty                              # consul dc name | etcd initial cluster token
dcs_servers:                                  # dcs server dict in name:ip format
  meta-1: 10.10.10.10                         # you could use existing dcs cluster
  # meta-2: 10.10.10.11                       # host which have their IP listed here will be init as server
  # meta-3: 10.10.10.12                       # 3 or 5 dcs nodes are recommend for production environment

dcs_exists_action: skip                       # abort|skip|clean if dcs server already exists
consul_data_dir: /var/lib/consul              # consul data dir (/var/lib/consul by default)
etcd_data_dir: /var/lib/etcd                  # etcd data dir (/var/lib/consul by default)


```





## Playbook

[`infra.yml`](../infra.yml) will bootstrap entire infrastructure on given inventory


```bash
playbook: ./infra.yml

  play #1 (meta): Init local repo	TAGS: [repo]
    tasks:
      repo : Create local repo directory	TAGS: [repo, repo_dir]
      repo : Backup & remove existing repos	TAGS: [repo, repo_upstream]
      repo : Add required upstream repos	TAGS: [repo, repo_upstream]
      repo : Check repo pkgs cache exists	TAGS: [repo, repo_prepare]
      repo : Set fact whether repo_exists	TAGS: [repo, repo_prepare]
      repo : Move upstream repo to backup	TAGS: [repo, repo_prepare]
      repo : Add local file system repos	TAGS: [repo, repo_prepare]
      repo : Remake yum cache if not exists	TAGS: [repo, repo_prepare]
      repo : Install repo bootstrap packages	TAGS: [repo, repo_boot]
      repo : Render repo nginx server files	TAGS: [repo, repo_nginx]
      repo : Disable selinux for repo server	TAGS: [repo, repo_nginx]
      repo : Launch repo nginx server	TAGS: [repo, repo_nginx]
      repo : Waits repo server online	TAGS: [repo, repo_nginx]
      repo : Download web url packages	TAGS: [repo, repo_download]
      repo : Download repo packages	TAGS: [repo, repo_download]
      repo : Download repo pkg deps	TAGS: [repo, repo_download]
      repo : Create local repo index	TAGS: [repo, repo_download]
      repo : Mark repo cache as valid	TAGS: [repo, repo_download]

  play #2 (all): Provision Node	TAGS: [node]
    tasks:
      node : Update node hostname	TAGS: [node, node_name]
      node : Add new hostname to /etc/hosts	TAGS: [node, node_name]
      node : Write static dns records	TAGS: [node, node_dns]
      node : Get old nameservers	TAGS: [node, node_resolv]
      node : Truncate resolv file	TAGS: [node, node_resolv]
      node : Write resolv options	TAGS: [node, node_resolv]
      node : Add new nameservers	TAGS: [node, node_resolv]
      node : Append old nameservers	TAGS: [node, node_resolv]
      node : Backup existing repos	TAGS: [node, node_repo]
      node : Install upstream repo	TAGS: [node, node_repo]
      node : Install local repo	TAGS: [node, node_repo]
      node : Install node basic packages	TAGS: [node, node_pkgs]
      node : Install node extra packages	TAGS: [node, node_pkgs]
      node : Install meta specific packages	TAGS: [node, node_pkgs]
      node : Install node basic packages	TAGS: [node, node_pkgs]
      node : Install node extra packages	TAGS: [node, node_pkgs]
      node : Install meta specific packages	TAGS: [node, node_pkgs]
      node : Node configure disable numa	TAGS: [node, node_feature]
      node : Node configure disable swap	TAGS: [node, node_feature]
      node : Node configure unmount swap	TAGS: [node, node_feature]
      node : Node configure disable firewall	TAGS: [node, node_feature]
      node : Node disable selinux by default	TAGS: [node, node_feature]
      node : Node setup static network	TAGS: [node, node_feature]
      node : Node configure disable firewall	TAGS: [node, node_feature]
      node : Node configure disk prefetch	TAGS: [node, node_feature]
      node : Enable linux kernel modules	TAGS: [node, node_kernel]
      node : Enable kernel module on reboot	TAGS: [node, node_kernel]
      node : Get config parameter page count	TAGS: [node, node_tuned]
      node : Get config parameter page size	TAGS: [node, node_tuned]
      node : Tune shmmax and shmall via mem	TAGS: [node, node_tuned]
      node : Create tuned profile postgres	TAGS: [node, node_tuned]
      node : Render tuned profile postgres	TAGS: [node, node_tuned]
      node : Active tuned profile postgres	TAGS: [node, node_tuned]
      node : Change additional sysctl params	TAGS: [node, node_tuned]
      node : Copy default user bash profile	TAGS: [node, node_profile]
      node : Setup node default pam ulimits	TAGS: [node, node_ulimit]
      node : Create os user group admin	TAGS: [node, node_admin]
      node : Create os user admin	TAGS: [node, node_admin]
      node : Grant admin group nopass sudo	TAGS: [node, node_admin]
      node : Add no host checking to ssh config	TAGS: [node, node_admin]
      node : Add admin ssh no host checking	TAGS: [node, node_admin]
      node : Fetch all admin public keys	TAGS: [node, node_admin]
      node : Exchange all admin ssh keys	TAGS: [node, node_admin]
      node : Install public keys	TAGS: [node, node_admin]
      node : Install ntp package	TAGS: [node, ntp_install]
      node : Install chrony package	TAGS: [node, ntp_install]
      node : Setup default node timezone	TAGS: [node, ntp_config]
      node : Copy the ntp.conf file	TAGS: [node, ntp_config]
      node : Copy the chrony.conf template	TAGS: [node, ntp_config]
      node : Launch ntpd service	TAGS: [node, ntp_launch]
      node : Launch chronyd service	TAGS: [node, ntp_launch]

  play #3 (meta): Init meta service	TAGS: [meta]
    tasks:
      ca : Create local ca directory	TAGS: [ca, ca_dir, meta]
      ca : Copy ca cert from local files	TAGS: [ca, ca_copy, meta]
      ca : Check ca key cert exists	TAGS: [ca, ca_create, meta]
      ca : Create self-signed CA key-cert	TAGS: [ca, ca_create, meta]
      nginx : Make sure nginx package installed	TAGS: [meta, nginx]
      nginx : Copy nginx default config	TAGS: [meta, nginx]
      nginx : Copy nginx upstream conf	TAGS: [meta, nginx]
      nginx : Create local html directory	TAGS: [meta, nginx]
      nginx : Update default nginx index page	TAGS: [meta, nginx]
      nginx : Restart meta nginx service	TAGS: [meta, nginx]
      nginx : Wait for nginx service online	TAGS: [meta, nginx]
      nginx : Make sure nginx exporter installed	TAGS: [meta, nginx, nginx_exporter]
      nginx : Config nginx_exporter options	TAGS: [meta, nginx, nginx_exporter]
      nginx : Restart nginx_exporter service	TAGS: [meta, nginx, nginx_exporter]
      nginx : Wait for nginx exporter online	TAGS: [meta, nginx, nginx_exporter]
      prometheus : Install prometheus and alertmanager	TAGS: [meta, prometheus, prometheus_install]
      prometheus : Wipe out prometheus config dir	TAGS: [meta, prometheus, prometheus_clean]
      prometheus : Wipe out existing prometheus data	TAGS: [meta, prometheus, prometheus_clean]
      prometheus : Recreate prometheus data dir	TAGS: [meta, prometheus, prometheus_config]
      prometheus : Copy /etc/prometheus configs	TAGS: [meta, prometheus, prometheus_config]
      prometheus : Copy /etc/prometheus opts	TAGS: [meta, prometheus, prometheus_config]
      prometheus : Overwrite prometheus scrape_interval	TAGS: [meta, prometheus, prometheus_config]
      prometheus : Overwrite prometheus evaluation_interval	TAGS: [meta, prometheus, prometheus_config]
      prometheus : Overwrite prometheus scrape_timeout	TAGS: [meta, prometheus, prometheus_config]
      prometheus : Overwrite prometheus pg metrics path	TAGS: [meta, prometheus, prometheus_config]
      prometheus : Launch prometheus service	TAGS: [meta, prometheus, prometheus_launch]
      prometheus : Launch alertmanager service	TAGS: [meta, prometheus, prometheus_launch]
      prometheus : Wait for prometheus online	TAGS: [meta, prometheus, prometheus_launch]
      prometheus : Wait for alertmanager online	TAGS: [meta, prometheus, prometheus_launch]
      grafana : Make sure grafana is installed	TAGS: [grafana, grafana_install, meta]
      grafana : Check grafana plugin cache exists	TAGS: [grafana, grafana_plugin, meta]
      grafana : Provision grafana plugins via cache	TAGS: [grafana, grafana_plugin, meta]
      grafana : Download grafana plugins from web	TAGS: [grafana, grafana_plugin, meta]
      grafana : Download grafana plugins from web	TAGS: [grafana, grafana_plugin, meta]
      grafana : Create grafana plugins cache	TAGS: [grafana, grafana_plugin, meta]
      grafana : Copy /etc/grafana/grafana.ini	TAGS: [grafana, grafana_config, meta]
      grafana : Copy grafana.db to data dir	TAGS: [grafana, grafana_config, meta]
      grafana : Launch grafana service	TAGS: [grafana, grafana_launch, meta]
      grafana : Wait for grafana online	TAGS: [grafana, grafana_launch, meta]
      grafana : Register consul grafana service	TAGS: [grafana, grafana_register, meta]
      grafana : Reload consul	TAGS: [grafana, grafana_register, meta]
      grafana : Remove grafana dashboard dir	TAGS: [grafana, grafana_provision, meta]
      grafana : Copy grafana dashboards json	TAGS: [grafana, grafana_provision, meta]
      grafana : Preprocess grafana dashboards	TAGS: [grafana, grafana_provision, meta]
      grafana : Provision prometheus datasource	TAGS: [grafana, grafana_provision, meta]
      grafana : Provision grafana dashboards	TAGS: [grafana, grafana_provision, meta]

  play #4 (all): Init dcs	TAGS: [dcs]
    tasks:
      consul : Check for existing consul	TAGS: [consul_check, dcs]
      consul : Consul exists flag fact set	TAGS: [consul_check, dcs]
      consul : Abort due to consul exists	TAGS: [consul_check, dcs]
      consul : Clean existing consul instance	TAGS: [consul_check, dcs]
      consul : Purge existing consul instance	TAGS: [consul_check, dcs]
      consul : Make sure consul is installed	TAGS: [consul_install, dcs]
      consul : Make sure consul dir exists	TAGS: [consul_config, dcs]
      consul : Get dcs server node names	TAGS: [consul_config, dcs]
      consul : Get dcs node name from var	TAGS: [consul_config, dcs]
      consul : Get dcs node name from var	TAGS: [consul_config, dcs]
      consul : Fetch hostname as dcs node name	TAGS: [consul_config, dcs]
      consul : Get dcs name from hostname	TAGS: [consul_config, dcs]
      consul : Copy /etc/consul.d/consul.json	TAGS: [consul_config, dcs]
      consul : Get dcs bootstrap expect quroum	TAGS: [consul_server, dcs]
      consul : Copy consul server service unit	TAGS: [consul_server, dcs]
      consul : Launch consul server service	TAGS: [consul_server, dcs]
      consul : Wait for consul server online	TAGS: [consul_server, dcs]
      consul : Copy consul agent service	TAGS: [consul_agent, dcs]
      consul : Launch consul agent service	TAGS: [consul_agent, dcs]
      consul : Wait for consul agent online	TAGS: [consul_agent, dcs]

  play #5 (meta): Copy ansible scripts	TAGS: [ansible]
    tasks:
      Create ansible tarball	TAGS: [ansible]
      Create ansible directory	TAGS: [ansible]
      Copy ansible tarball	TAGS: [ansible]
      Extract tarball	TAGS: [ansible]
```
