# Infrastructure Provision [DRAFT]



## TL;DR

1. Configure infrastructure parameters

    ```bash
    vi conf/dev.yml
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

    proxy_env: # global proxy env when downloading packages
      # http_proxy: 'http://xxxxxx'
      # https_proxy: 'http://xxxxxx'
      # all_proxy: 'http://xxxxxx'
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

    # - where to download - #
    repo_upstreams:
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

      - name: pgdg13
        description: PostgreSQL 13 for RHEL/CentOS $releasever - $basearch - Updates testing
        gpgcheck: no
        baseurl: https://download.postgresql.org/pub/repos/yum/13/redhat/rhel-$releasever-$basearch

      - name: centos-sclo
        description: CentOS-$releasever - SCLo
        gpgcheck: no
        mirrorlist: http://mirrorlist.centos.org?arch=$basearch&release=7&repo=sclo-sclo

      - name: centos-sclo-rh
        description: CentOS-$releasever - SCLo rh
        gpgcheck: no
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

      # for latest consul & kubernetes
      - name: harbottle
        description: Copr repo for main owned by harbottle
        skip_if_unavailable: true
        gpgcheck: no
        baseurl: https://download.copr.fedorainfracloud.org/results/harbottle/main/epel-$releasever-$basearch/


    # - what to download - #
    repo_packages:
      # repo bootstrap packages
      - epel-release nginx wget yum-utils yum createrepo                                      # bootstrap packages

      # node basic packages
      - ntp chrony uuid lz4 nc pv jq vim-enhanced make patch bash lsof wget unzip git tuned   # basic system util
      - readline zlib openssl libyaml libxml2 libxslt perl-ExtUtils-Embed ca-certificates     # basic pg dependency
      - numactl grubby sysstat dstat iotop bind-utils net-tools tcpdump socat ipvsadm telnet  # system utils

      # dcs & monitor packages
      - grafana prometheus2 pushgateway alertmanager                                          # monitor and ui
      - node_exporter postgres_exporter nginx_exporter blackbox_exporter                      # exporter
      - consul consul_exporter consul-template etcd                                           # dcs

      # python3 dependencies
      - ansible python python-pip python-psycopg2                                             # ansible & python
      - python3 python3-psycopg2 python36-requests python3-etcd python3-consul                # python3
      - python36-urllib3 python36-idna python36-pyOpenSSL python36-cryptography               # python3 patroni extra deps

      # proxy and load balancer
      - haproxy keepalived dnsmasq                                                            # proxy and dns

      # postgres common Packages
      - patroni patroni-consul patroni-etcd pgbouncer pg_cli pgbadger pg_activity               # major components
      - pgcenter boxinfo check_postgres emaj pgbconsole pg_bloat_check pgquarrel                # other common utils
      - barman barman-cli pgloader pgFormatter pitrery pspg pgxnclient PyGreSQL pgadmin4 tail_n_mail

      # postgres 13 packages
      - postgresql13* postgis31* citus_13 pgrouting_13                                          # postgres 13 and postgis 31
      - pg_repack13 pg_squeeze13                                                                # maintenance extensions
      - pg_qualstats13 pg_stat_kcache13 system_stats_13 bgw_replstatus13                        # stats extensions
      - plr13 plsh13 plpgsql_check_13 plproxy13 plr13 plsh13 plpgsql_check_13 pldebugger13      # PL extensions                                      # pl extensions
      - hdfs_fdw_13 mongo_fdw13 mysql_fdw_13 ogr_fdw13 redis_fdw_13 pgbouncer_fdw13             # FDW extensions
      - wal2json13 count_distinct13 ddlx_13 geoip13 orafce13                                    # MISC extensions
      - rum_13 hypopg_13 ip4r13 jsquery_13 logerrors_13 periods_13 pg_auto_failover_13 pg_catcheck13
      - pg_fkpart13 pg_jobmon13 pg_partman13 pg_prioritize_13 pg_track_settings13 pgaudit15_13
      - pgcryptokey13 pgexportdoc13 pgimportdoc13 pgmemcache-13 pgmp13 pgq-13
      - pguint13 pguri13 prefix13  safeupdate_13 semver13  table_version13 tdigest13


    repo_url_packages:
      - https://github.com/Vonng/pg_exporter/releases/download/v0.3.1/pg_exporter-0.3.1-1.el7.x86_64.rpm
      - https://github.com/cybertec-postgresql/vip-manager/releases/download/v0.6/vip-manager_0.6-1_amd64.rpm
      - http://guichaz.free.fr/polysh/files/polysh-0.4-1.noarch.rpm





    #------------------------------------------------------------------------------
    # NODE PROVISION
    #------------------------------------------------------------------------------
    # this section defines how to provision nodes

    # - node dns - #
    node_dns_hosts: # static dns records in /etc/hosts
      - 10.10.10.10 yum.pigsty
    node_dns_server: add                          # add (default) | none (skip) | overwrite (remove old settings)
    node_dns_servers: # dynamic nameserver in /etc/resolv.conf
      - 10.10.10.10
    node_dns_options: # dns resolv options
      - options single-request-reopen timeout:1 rotate
      - domain service.consul

    # - node repo - #
    node_repo_method: local                       # none|local|public (use local repo for production env)
    node_repo_remove: true                        # whether remove existing repo
    # local repo url (if method=local, make sure firewall is configured or disabled)
    node_local_repo_url:
      - http://yum.pigsty/pigsty.repo

    # - node packages - #
    node_packages: # common packages for all nodes
      - wget,yum-utils,ntp,chrony,tuned,uuid,lz4,vim-minimal,make,patch,bash,lsof,wget,unzip,git,readline,zlib,openssl
      - numactl,grubby,sysstat,dstat,iotop,bind-utils,net-tools,tcpdump,socat,ipvsadm,telnet,tuned,pv,jq
      - python3,python3-psycopg2,python36-requests,python3-etcd,python3-consul
      - python36-urllib3,python36-idna,python36-pyOpenSSL,python36-cryptography
      - node_exporter,consul,consul-template,etcd,haproxy,keepalived,vip-manager
    node_extra_packages: # extra packages for all nodes
      - patroni,patroni-consul,patroni-etcd,pgbouncer,pgbadger,pg_activity
    node_meta_packages: # packages for meta nodes only
      - grafana,prometheus2,alertmanager,nginx_exporter,blackbox_exporter,pushgateway
      - dnsmasq,nginx,ansible,pgbadger,polysh

    # - node features - #
    node_disable_numa: false                      # disable numa, important for production database, reboot required
    node_disable_swap: false                      # disable swap, important for production database
    node_disable_firewall: true                   # disable firewall (required if using kubernetes)
    node_disable_selinux: true                    # disable selinux  (required if using kubernetes)
    node_static_network: true                     # keep dns resolver settings after reboot
    node_disk_prefetch: false                     # setup disk prefetch on HDD to increase performance

    # - node kernel modules - #
    node_kernel_modules:
      - softdog
      - br_netfilter
      - ip_vs
      - ip_vs_rr
      - ip_vs_rr
      - ip_vs_wrr
      - ip_vs_sh
      - nf_conntrack_ipv4

    # - node tuned - #
    node_tune: tiny                               # install and activate tuned profile: none|oltp|olap|crit|tiny
    node_sysctl_params: # set additional sysctl parameters, k:v format
      net.bridge.bridge-nf-call-iptables: 1       # for kubernetes

    # - node user - #
    node_admin_setup: true                        # setup an default admin user ?
    node_admin_uid: 88                            # uid and gid for admin user
    node_admin_username: admin                    # default admin user
    node_admin_ssh_exchange: true                 # exchange ssh key among cluster ?
    node_admin_pks: # public key list that will be installed
      - 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQC7IMAMNavYtWwzAJajKqwdn3ar5BhvcwCnBTxxEkXhGlCO2vfgosSAQMEflfgvkiI5nM1HIFQ8KINlx1XLO7SdL5KdInG5LIJjAFh0pujS4kNCT9a5IGvSq1BrzGqhbEcwWYdju1ZPYBcJm/MG+JD0dYCh8vfrYB/cYMD0SOmNkQ== vagrant@pigsty.com'

    # - node ntp - #
    node_ntp_service: ntp                         # ntp or chrony
    node_ntp_config: true                         # overwrite existing ntp config?
    node_timezone: Asia/Shanghai                  # default node timezone
    node_ntp_servers: # default NTP servers
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
      - {name: home,           host: pigsty,   url: "127.0.0.1:3000"}
      - { name: consul,        host: c.pigsty, url: "127.0.0.1:8500" }
      - { name: grafana,       host: g.pigsty, url: "127.0.0.1:3000" }
      - { name: prometheus,    host: p.pigsty, url: "127.0.0.1:9090" }
      - { name: alertmanager,  host: a.pigsty, url: "127.0.0.1:9093" }

    # - nameserver - #
    dns_records: # dynamic dns record resolved by dnsmasq
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
    prometheus_scrape_timeout: 1s                 # global scrape timeout (1s for dev, 1s for prod)
    prometheus_metrics_path: /metrics             # default metrics path (only affect job 'pg')
    prometheus_data_dir: /export/prometheus/data  # prometheus data dir
    prometheus_retention: 30d                     # how long to keep

    # - grafana - #
    grafana_url: http://admin:admin@10.10.10.10:3000 # grafana url
    grafana_admin_password: admin                  # default grafana admin user password
    grafana_plugin: install                        # none|install|reinstall
    grafana_cache: /www/pigsty/grafana/plugins.tar.gz # path to grafana plugins tarball
    grafana_customize: true                        # customize grafana resources
    grafana_plugins: # default grafana plugins list
      - redis-datasource
      - simpod-json-datasource
      - fifemon-graphql-datasource
      - sbueringer-consul-datasource
      - camptocamp-prometheus-alertmanager-datasource
      - ryantxu-ajax-panel
      - marcusolsson-hourly-heatmap-panel
      - michaeldmoore-multistat-panel
      - marcusolsson-treemap-panel
      - pr0ps-trackmap-panel
      - dalvany-image-panel
      - magnesium-wordcloud-panel
      - cloudspout-button-panel
      - speakyourcode-button-panel
      - jdbranham-diagram-panel
      - grafana-piechart-panel
      - snuids-radar-panel
      - digrich-bubblechart-panel
    grafana_git_plugins:
      - https://github.com/Vonng/grafana-echarts



    #------------------------------------------------------------------------------
    # DCS PROVISION
    #------------------------------------------------------------------------------
    dcs_type: consul                              # consul | etcd | both
    dcs_name: pigsty                              # consul dc name | etcd initial cluster token
    # dcs server dict in name:ip format
    dcs_servers:
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

play #1 (meta): Init local repo						TAGS: [repo]
tasks:
  Create local repo directory						TAGS: [repo, repo_dir]
  Backup & remove existing repos					TAGS: [repo, repo_upstream]
  Add required upstream repos						TAGS: [repo, repo_upstream]
  Check repo pkgs cache exists						TAGS: [repo, repo_prepare]
  Set fact whether repo_exists						TAGS: [repo, repo_prepare]
  Move upstream repo to backup						TAGS: [repo, repo_prepare]
  Add local file system repos						TAGS: [repo, repo_prepare]
  repo : Remake yum cache if not exists				TAGS: [repo, repo_prepare]
  Install repo bootstrap packages					TAGS: [repo, repo_boot]
  Render repo nginx server files					TAGS: [repo, repo_nginx]
  Disable selinux for repo server					TAGS: [repo, repo_nginx]
  Launch repo nginx server							TAGS: [repo, repo_nginx]
  Waits repo server online							TAGS: [repo, repo_nginx]
  repo : Download web url packages					TAGS: [repo, repo_download]
  Download repo packages							TAGS: [repo, repo_download]
  Download repo pkg deps							TAGS: [repo, repo_download]
  Create local repo index							TAGS: [repo, repo_download]
  repo : Copy bootstrap scripts						TAGS: [repo, repo_download, repo_script]
  Mark repo cache as valid							TAGS: [repo, repo_download]

play #2 (all): Provision Node						TAGS: [node]
tasks:
  Update node hostname								TAGS: [node, node_name]
  node : Add new hostname to /etc/hosts				TAGS: [node, node_name]
  node : Write static dns records					TAGS: [node, node_dns]
  node : Get old nameservers						TAGS: [node, node_resolv]
  node : Truncate resolv file						TAGS: [node, node_resolv]
  node : Write resolv options						TAGS: [node, node_resolv]
  node : Add new nameservers						TAGS: [node, node_resolv]
  node : Append old nameservers						TAGS: [node, node_resolv]
  node : Node configure disable firewall			TAGS: [node, node_firewall]
  node : Node disable selinux by default			TAGS: [node, node_firewall]
  node : Backup existing repos						TAGS: [node, node_repo]
  node : Install upstream repo						TAGS: [node, node_repo]
  node : Install local repo							TAGS: [node, node_repo]
  Install node basic packages						TAGS: [node, node_pkgs]
  Install node extra packages						TAGS: [node, node_pkgs]
  node : Install meta specific packages				TAGS: [node, node_pkgs]
  Install node basic packages						TAGS: [node, node_pkgs]
  Install node extra packages						TAGS: [node, node_pkgs]
  node : Install meta specific packages				TAGS: [node, node_pkgs]
  node : Node configure disable numa				TAGS: [node, node_feature]
  node : Node configure disable swap				TAGS: [node, node_feature]
  node : Node configure unmount swap				TAGS: [node, node_feature]
  node : Node setup static network					TAGS: [node, node_feature]
  node : Node configure disable firewall			TAGS: [node, node_feature]
  node : Node configure disk prefetch				TAGS: [node, node_feature]
  node : Enable linux kernel modules				TAGS: [node, node_kernel]
  node : Enable kernel module on reboot				TAGS: [node, node_kernel]
  node : Get config parameter page count			TAGS: [node, node_tuned]
  node : Get config parameter page size				TAGS: [node, node_tuned]
  node : Tune shmmax and shmall via mem				TAGS: [node, node_tuned]
  node : Create tuned profiles						TAGS: [node, node_tuned]
  node : Render tuned profiles						TAGS: [node, node_tuned]
  node : Active tuned profile						TAGS: [node, node_tuned]
  node : Change additional sysctl params			TAGS: [node, node_tuned]
  node : Copy default user bash profile				TAGS: [node, node_profile]
  Setup node default pam ulimits					TAGS: [node, node_ulimit]
  node : Create os user group admin					TAGS: [node, node_admin]
  node : Create os user admin						TAGS: [node, node_admin]
  node : Grant admin group nopass sudo				TAGS: [node, node_admin]
  node : Add no host checking to ssh config			TAGS: [node, node_admin]
  node : Add admin ssh no host checking				TAGS: [node, node_admin]
  node : Fetch all admin public keys				TAGS: [node, node_admin]
  node : Exchange all admin ssh keys				TAGS: [node, node_admin]
  node : Install public keys						TAGS: [node, node_admin]
  node : Install ntp package						TAGS: [node, ntp_install]
  node : Install chrony package						TAGS: [node, ntp_install]
  Setup default node timezone						TAGS: [node, ntp_config]
  node : Copy the ntp.conf file						TAGS: [node, ntp_config]
  node : Copy the chrony.conf template				TAGS: [node, ntp_config]
  node : Launch ntpd service						TAGS: [node, ntp_launch]
  node : Launch chronyd service						TAGS: [node, ntp_launch]

play #3 (meta): Init meta service					TAGS: [meta]
tasks:
  Create local ca directory							TAGS: [ca, ca_dir, meta]
  Copy ca cert from local files						TAGS: [ca, ca_copy, meta]
  Check ca key cert exists							TAGS: [ca, ca_create, meta]
  ca : Create self-signed CA key-cert				TAGS: [ca, ca_create, meta]
  Make sure nginx package installed					TAGS: [meta, nginx]
  Copy nginx default config							TAGS: [meta, nginx]
  Copy nginx upstream conf							TAGS: [meta, nginx]
  nginx : Create local html directory				TAGS: [meta, nginx]
  Update default nginx index page					TAGS: [meta, nginx]
  Restart meta nginx service						TAGS: [meta, nginx]
  Wait for nginx service online						TAGS: [meta, nginx]
  Make sure nginx exporter installed				TAGS: [meta, nginx, nginx_exporter]
  Config nginx_exporter options						TAGS: [meta, nginx, nginx_exporter]
  Restart nginx_exporter service					TAGS: [meta, nginx, nginx_exporter]
  Wait for nginx exporter online					TAGS: [meta, nginx, nginx_exporter]
  Install prometheus and alertmanager				TAGS: [meta, prometheus, prometheus_install]
  Wipe out prometheus config dir					TAGS: [meta, prometheus, prometheus_clean]
  Wipe out existing prometheus data					TAGS: [meta, prometheus, prometheus_clean]
  Recreate prometheus data dir						TAGS: [meta, prometheus, prometheus_config]
  Copy /etc/prometheus configs						TAGS: [meta, prometheus, prometheus_config]
  Copy /etc/prometheus opts							TAGS: [meta, prometheus, prometheus_config]
  Overwrite prometheus scrape_interval				TAGS: [meta, prometheus, prometheus_config]
  Overwrite prometheus evaluation_interval			TAGS: [meta, prometheus, prometheus_config]
  Overwrite prometheus scrape_timeout				TAGS: [meta, prometheus, prometheus_config]
  Overwrite prometheus pg metrics path				TAGS: [meta, prometheus, prometheus_config]
  Launch prometheus service							TAGS: [meta, prometheus, prometheus_launch]
  prometheus : Launch alertmanager service			TAGS: [meta, prometheus, prometheus_launch]
  Wait for prometheus online						TAGS: [meta, prometheus, prometheus_launch]
  prometheus : Wait for alertmanager online			TAGS: [meta, prometheus, prometheus_launch]
  Make sure grafana is installed					TAGS: [grafana, grafana_install, meta]
  Check grafana plugin cache exists					TAGS: [grafana, grafana_plugin, meta]
  Provision grafana plugins via cache				TAGS: [grafana, grafana_plugin, meta]
  Download grafana plugins from web					TAGS: [grafana, grafana_plugin, meta]
  Download grafana plugins from web					TAGS: [grafana, grafana_plugin, meta]
  Create grafana plugins cache						TAGS: [grafana, grafana_plugin, meta]
  Copy /etc/grafana/grafana.ini						TAGS: [grafana, grafana_config, meta]
  Remove grafana provision dir						TAGS: [grafana, grafana_config, meta]
  grafana : Copy provisioning content				TAGS: [grafana, grafana_config, meta]
  grafana : Copy pigsty dashboards					TAGS: [grafana, grafana_config, meta]
  grafana : Copy pigsty icon image					TAGS: [grafana, grafana_config, meta]
  Replace grafana icon with pigsty					TAGS: [grafana, grafana_config, grafana_customize, meta]
  Launch grafana service							TAGS: [grafana, grafana_launch, meta]
  Wait for grafana online							TAGS: [grafana, grafana_launch, meta]
  Update grafana default preferences				TAGS: [grafana, grafana_provision, meta]
  Register consul grafana service					TAGS: [grafana, grafana_register, meta]
  grafana : Reload consul							TAGS: [grafana, grafana_register, meta]

play #4 (all): Init dcs								TAGS: []
tasks:
  Check for existing consul							TAGS: [consul_check, dcs]
  consul : Consul exists flag fact set				TAGS: [consul_check, dcs]
  Abort due to consul exists						TAGS: [consul_check, dcs]
  Clean existing consul instance					TAGS: [consul_check, dcs]
  Stop any running consul instance					TAGS: [consul_check, dcs]
  Remove existing consul dir						TAGS: [consul_check, dcs]
  Recreate consul dir								TAGS: [consul_check, dcs]
  Make sure consul is installed						TAGS: [consul_install, dcs]
  Make sure consul dir exists						TAGS: [consul_config, dcs]
  consul : Get dcs server node names				TAGS: [consul_config, dcs]
  consul : Get dcs node name from var				TAGS: [consul_config, dcs]
  consul : Get dcs node name from var				TAGS: [consul_config, dcs]
  consul : Fetch hostname as dcs node name			TAGS: [consul_config, dcs]
  consul : Get dcs name from hostname				TAGS: [consul_config, dcs]
  Copy /etc/consul.d/consul.json					TAGS: [consul_config, dcs]
  Copy consul agent service							TAGS: [consul_config, dcs]
  consul : Get dcs bootstrap expect quroum			TAGS: [consul_server, dcs]
  Copy consul server service unit					TAGS: [consul_server, dcs]
  Launch consul server service						TAGS: [consul_server, dcs]
  Wait for consul server online						TAGS: [consul_server, dcs]
  Launch consul agent service						TAGS: [consul_agent, dcs]
  Wait for consul agent online						TAGS: [consul_agent, dcs]

play #5 (meta): Copy ansible scripts				TAGS: [ansible]
tasks:
  Create ansible tarball							TAGS: [ansible]
  Create ansible directory							TAGS: [ansible]
  Copy ansible tarball								TAGS: [ansible]
  Extract tarball									TAGS: [ansible]

```
