# 基础设施初始化

> 如何使用剧本初始化基础设施



## 概览

基础设施初始化通过 [`infra.yml`](https://github.com/Vonng/pigsty/blob/master/infra.yml) 完成。该剧本会在**管理节点** 上完成**基础设施**的安装与部署。

`infra.yml` 将管理节点（默认分组名为`meta`）作为部署目标。

完整执行一遍初始化流程可能花费2～8分钟，视机器配置而异。

```bash
./infra.yml
```

!> 必须完成管理节点的初始化后，才能正常执行数据库节点的初始化❗️



![](../_media/playbook/infra.svg)

**管理节点**可以当作**普通节点复用**，即在管理节点上也可以定义并创建PostgreSQL数据库。Infra剧本默认会在在管理节点上创建一个[`pg-meta`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml#L43)元数据库，用于承载Pigsty高级特性。

`infra.yml`覆盖了[`pgsql.yml`](p-pgsql.md)的所有内容，因此`infra.yml`如果可以在管理节点上成功执行完毕，那么则在相同状态的普通节点上一定可以成功完成数据库部署。







## 选择性执行

用户可以通过ansible的标签机制，**选择性执行**剧本的一个子集。

例如，如果只想执行本地源初始化的部分，则可以通过以下命令：

```bash
./infra.yml --tags=repo
```

具体的标签请参考 [**任务详情**](#任务详情)

一些常用的任务子集包括：

```bash
./infra.yml --tags=environ                       # 重新在管理节点上配置环境
./infra.yml --tags=repo -e repo_rebuild=true     # 强制重新创建本地源
./infra.yml --tags=repo_upstream                 # 加入上游YumRepo
./infra.yml --tags=prometheus                    # 重新创建Prometheus
./infra.yml --tags=nginx_config,nginx_restart    # 重新生成Nginx配置文件
……
```





## 剧本说明

[`infra.yml`](https://github.com/Vonng/pigsty/blob/master/infra.yml) 主要完成以下工作

* 配置管理节点环境：目录，变量，凭证等
* 部署并启用本地源
* 完成管理节点的初始化
* 完成管理节点基础设施初始化
  * CA基础设施
  * DNS Nameserver
  * Nginx
  * Prometheus & Alertmanger
  * Grafana
* 在管理节点上完整执行`./pgsql.yml`以部署元数据库`pg-meta`



## 原始内容

<details>

```yaml
#!/usr/bin/env ansible-playbook
---
#==============================================================#
# File      :   infra.yml
# Ctime     :   2020-04-13
# Mtime     :   2021-07-07
# Desc      :   init infrastructure on meta nodes
# Path      :   infra.yml
# Copyright (C) 2018-2021 Ruohang Feng (rh@vonng.com)
#==============================================================#

#==============================================================#
# Playbook : Init Meta Node
#==============================================================#
#  Init infra on meta nodes (special group 'meta')
#     infra.yml
#
#  Setup environment on meta node (dir, ssh, pgpass, env)
#     infra.yml -t environ
#
#  Setup local yum repo
#     infra.yml -t repo
#
#  Setup prometheus
#     infra.yml -t prometheus
#
#  Setup grafana
#     infra.yml -t grafana
#
#  Setup nginx
#     infra.yml -t nginx
#
#  Setup cmdb on meta nodes
#     infra.yml -t pgsql
#
#  Sync dashboards baseline to grafana
#     infra.yml -t dashboard
#
#  Upgrade grafana with postgres as primary database
#     infra.yml -t grafana -e grafana_database=postgres
#     ssh meta rm -rf /etc/grafana/provisioning/dashboards/pigsty.yml
#
#==============================================================#

#---------------------------------------------------------------
- name: Infra Init      # init infra on meta node
  become: yes
  hosts: meta
  gather_facts: no
  tags: infra
  roles:

    - role: environ     # init postgres pgbouncer patroni
      tags: environ

    - role: repo        # init local yum repo on meta node
      tags: repo

    - role: node        # init meta node
      tags: node

    - role: consul      # init dcs:consul (servers)
      tags: [ dcs , consul ]

    - role: ca          # init certification infrastructure
      tags: ca

    - role: nameserver  # init dns nameserver
      tags: nameserver

    - role: nginx       # init nginx
      tags: nginx

    - role: prometheus  # init prometheus
      tags: prometheus

    - role: grafana     # init grafana
      tags: grafana

#---------------------------------------------------------------
- name: Pgsql Init      # init pgsql-cmdb on meta nodes
  become: yes
  hosts: meta
  gather_facts: no
  tags: pgsql
  roles:

    - role: postgres   # init postgres pgbouncer patroni
      tags: postgres

    - role: monitor    # init monitor exporters
      tags: monitor

    - role: service    # init service , lb , vip
      tags: service

    - role: register   # register cluster/instance to infra
      tags: register

#---------------------------------------------------------------
...

```

</details>



## 任务详情

使用以下命令可以列出所有基础设施初始化会执行的任务，以及可以使用的标签：

```bash
./infra.yml --list-tasks
```

默认任务如下：

<details>

```yaml
playbook: ./infra.yml

  play #1 (meta): Infra Init	TAGS: [infra]
    tasks:
      environ : Create pigsty resource dirs on /etc/pigsty	TAGS: [environ, environ_dirs, infra]
      environ : Get current username	TAGS: [environ, environ_ssh, infra]
      environ : Create admin user ssh key pair if not exists	TAGS: [environ, environ_ssh, infra]
      environ : Write default user credential to pgpass	TAGS: [environ, environ_pgpass, infra]
      environ : Write default meta service to pg_service	TAGS: [environ, environ_pgpass, infra]
      environ : Set environment for admin user	TAGS: [environ, environ_vars, infra]
      environ : Enable environment for admin user	TAGS: [environ, environ_vars, infra]
      repo : Create local repo directory	TAGS: [infra, repo, repo_dir]
      repo : Backup & remove existing repos	TAGS: [infra, repo, repo_upstream]
      repo : Add required upstream repos	TAGS: [infra, repo, repo_upstream]
      repo : Check repo pkgs cache exists	TAGS: [infra, repo, repo_prepare]
      repo : Set fact whether repo_exists	TAGS: [infra, repo, repo_prepare]
      repo : Move upstream repo to backup	TAGS: [infra, repo, repo_prepare]
      repo : Add local file system repos	TAGS: [infra, repo, repo_prepare]
      repo : Remake yum cache if not exists	TAGS: [infra, repo, repo_prepare]
      repo : Install repo bootstrap packages	TAGS: [infra, repo, repo_boot]
      repo : Render repo nginx server files	TAGS: [infra, repo, repo_nginx]
      repo : Disable selinux for repo server	TAGS: [infra, repo, repo_nginx]
      repo : Launch repo nginx server	TAGS: [infra, repo, repo_nginx]
      repo : Waits repo server online	TAGS: [infra, repo, repo_nginx]
      repo : Download web url packages	TAGS: [infra, repo, repo_download]
      repo : Download repo packages	TAGS: [infra, repo, repo_download]
      repo : Download repo pkg deps	TAGS: [infra, repo, repo_download]
      repo : Create local repo index	TAGS: [infra, repo, repo_download]
      repo : Copy bootstrap scripts	TAGS: [infra, repo, repo_download, repo_script]
      repo : Mark repo cache as valid	TAGS: [infra, repo, repo_download]
      node : Update node hostname	TAGS: [infra, node, node_name]
      node : Add new hostname to /etc/hosts	TAGS: [infra, node, node_name]
      node : Write static dns records	TAGS: [infra, node, node_dns]
      node : Get old nameservers	TAGS: [infra, node, node_resolv]
      node : Write tmp resolv file	TAGS: [infra, node, node_resolv]
      node : Write resolv options	TAGS: [infra, node, node_resolv]
      node : Write additional nameservers	TAGS: [infra, node, node_resolv]
      node : Append existing nameservers	TAGS: [infra, node, node_resolv]
      node : Swap resolv.conf	TAGS: [infra, node, node_resolv]
      node : Node configure disable firewall	TAGS: [infra, node, node_firewall]
      node : Node disable selinux by default	TAGS: [infra, node, node_firewall]
      node : Backup existing repos	TAGS: [infra, node, node_repo]
      node : Install upstream repo	TAGS: [infra, node, node_repo]
      node : Install local repo	TAGS: [infra, node, node_repo]
      node : Install node basic packages	TAGS: [infra, node, node_pkgs]
      node : Install node extra packages	TAGS: [infra, node, node_pkgs]
      node : Install meta specific packages	TAGS: [infra, node, node_pkgs]
      node : Install node basic packages	TAGS: [infra, node, node_pkgs]
      node : Install node extra packages	TAGS: [infra, node, node_pkgs]
      node : Install meta specific packages	TAGS: [infra, node, node_pkgs]
      node : Install pip3 packages on meta node	TAGS: [infra, node, node_pip, node_pkgs]
      node : Node configure disable numa	TAGS: [infra, node, node_feature]
      node : Node configure disable swap	TAGS: [infra, node, node_feature]
      node : Node configure unmount swap	TAGS: [infra, node, node_feature]
      node : Node setup static network	TAGS: [infra, node, node_feature]
      node : Node configure disable firewall	TAGS: [infra, node, node_feature]
      node : Node configure disk prefetch	TAGS: [infra, node, node_feature]
      node : Enable linux kernel modules	TAGS: [infra, node, node_kernel]
      node : Enable kernel module on reboot	TAGS: [infra, node, node_kernel]
      node : Get config parameter page count	TAGS: [infra, node, node_tuned]
      node : Get config parameter page size	TAGS: [infra, node, node_tuned]
      node : Tune shmmax and shmall via mem	TAGS: [infra, node, node_tuned]
      node : Create tuned profiles	TAGS: [infra, node, node_tuned]
      node : Render tuned profiles	TAGS: [infra, node, node_tuned]
      node : Active tuned profile	TAGS: [infra, node, node_tuned]
      node : Change additional sysctl params	TAGS: [infra, node, node_tuned]
      node : Copy default user bash profile	TAGS: [infra, node, node_profile]
      node : Setup node default pam ulimits	TAGS: [infra, node, node_ulimit]
      node : Create os user group admin	TAGS: [infra, node, node_admin]
      node : Create os user admin	TAGS: [infra, node, node_admin]
      node : Grant admin group nopass sudo	TAGS: [infra, node, node_admin]
      node : Add no host checking to ssh config	TAGS: [infra, node, node_admin]
      node : Add admin ssh no host checking	TAGS: [infra, node, node_admin]
      node : Fetch all admin public keys	TAGS: [infra, node, node_admin]
      node : Exchange all admin ssh keys	TAGS: [infra, node, node_admin]
      node : Install public keys	TAGS: [infra, node, node_admin, node_admin_pks]
      node : Install current public key	TAGS: [infra, node, node_admin, node_admin_pk_current]
      node : Install ntp package	TAGS: [infra, node, ntp_install]
      node : Install chrony package	TAGS: [infra, node, ntp_install]
      node : Setup default node timezone	TAGS: [infra, node, ntp_config]
      node : Copy the ntp.conf file	TAGS: [infra, node, ntp_config]
      node : Copy the chrony.conf template	TAGS: [infra, node, ntp_config]
      node : Launch ntpd service	TAGS: [infra, node, ntp_launch]
      node : Launch chronyd service	TAGS: [infra, node, ntp_launch]
      consul : Check for existing consul	TAGS: [consul, consul_check, dcs, infra]
      consul : Consul exists flag fact set	TAGS: [consul, consul_check, dcs, infra]
      consul : Abort due to consul exists	TAGS: [consul, consul_check, dcs, infra]
      consul : Clean existing consul instance	TAGS: [consul, consul_clean, dcs, infra]
      consul : Stop any running consul instance	TAGS: [consul, consul_clean, dcs, infra]
      consul : Remove existing consul dir	TAGS: [consul, consul_clean, dcs, infra]
      consul : Recreate consul dir	TAGS: [consul, consul_clean, dcs, infra]
      consul : Make sure consul is installed	TAGS: [consul, consul_install, dcs, infra]
      consul : Make sure consul dir exists	TAGS: [consul, consul_config, dcs, infra]
      consul : Get dcs server node names	TAGS: [consul, consul_config, dcs, infra]
      consul : Get dcs node name from var nodename	TAGS: [consul, consul_config, dcs, infra]
      consul : Get dcs node name from pgsql ins name	TAGS: [consul, consul_config, dcs, infra]
      consul : Fetch hostname as dcs node name	TAGS: [consul, consul_config, dcs, infra]
      consul : Get dcs name from hostname	TAGS: [consul, consul_config, dcs, infra]
      consul : Copy /etc/consul.d/consul.json	TAGS: [consul, consul_config, dcs, infra]
      consul : Copy consul agent service	TAGS: [consul, consul_config, dcs, infra]
      consul : Get dcs bootstrap expect quroum	TAGS: [consul, consul_server, dcs, infra]
      consul : Copy consul server service unit	TAGS: [consul, consul_server, dcs, infra]
      consul : Launch consul server service	TAGS: [consul, consul_server, dcs, infra]
      consul : Wait for consul server online	TAGS: [consul, consul_server, dcs, infra]
      consul : Launch consul agent service	TAGS: [consul, consul_agent, dcs, infra]
      consul : Wait for consul agent online	TAGS: [consul, consul_agent, dcs, infra]
      ca : Create local ca directory	TAGS: [ca, ca_dir, infra]
      ca : Copy ca cert from local files	TAGS: [ca, ca_copy, infra]
      ca : Check ca key cert exists	TAGS: [ca, ca_create, infra]
      ca : Create self-signed CA key-cert	TAGS: [ca, ca_create, infra]
      nameserver : Make sure dnsmasq package installed	TAGS: [infra, nameserver]
      nameserver : Copy dnsmasq /etc/dnsmasq.d/config	TAGS: [infra, nameserver]
      nameserver : Add dynamic dns records to meta	TAGS: [infra, nameserver]
      nameserver : Launch meta dnsmasq service	TAGS: [infra, nameserver]
      nameserver : Wait for meta dnsmasq online	TAGS: [infra, nameserver]
      nameserver : Register consul dnsmasq service	TAGS: [infra, nameserver]
      nameserver : Reload consul	TAGS: [infra, nameserver]
      nginx : Make sure nginx installed	TAGS: [infra, nginx, nginx_install]
      nginx : Create nginx config directory	TAGS: [infra, nginx, nginx_content]
      nginx : Create local html directory	TAGS: [infra, nginx, nginx_content]
      nginx : Update default nginx index page	TAGS: [infra, nginx, nginx_content]
      nginx : Copy nginx default config	TAGS: [infra, nginx, nginx_config]
      nginx : Copy nginx upstream conf	TAGS: [infra, nginx, nginx_config]
      nginx : Create nginx haproxy config dir	TAGS: [infra, nginx, nginx_haproxy]
      nginx : Create haproxy proxy server config	TAGS: [infra, nginx, nginx_haproxy, nginx_haproxy_config]
      nginx : Restart meta nginx service	TAGS: [infra, nginx, nginx_restart]
      nginx : Wait for nginx service online	TAGS: [infra, nginx, nginx_restart]
      nginx : Make sure nginx exporter installed	TAGS: [infra, nginx, nginx_exporter]
      nginx : Config nginx_exporter options	TAGS: [infra, nginx, nginx_exporter]
      nginx : Restart nginx_exporter service	TAGS: [infra, nginx, nginx_exporter]
      nginx : Wait for nginx exporter online	TAGS: [infra, nginx, nginx_exporter]
      nginx : Register cosnul nginx service	TAGS: [infra, nginx, nginx_register]
      nginx : Register consul nginx-exporter service	TAGS: [infra, nginx, nginx_register]
      nginx : Reload consul	TAGS: [infra, nginx, nginx_register]
      prometheus : Install prometheus and alertmanager	TAGS: [infra, prometheus]
      prometheus : Wipe out prometheus config dir	TAGS: [infra, prometheus, prometheus_clean]
      prometheus : Wipe out existing prometheus data	TAGS: [infra, prometheus, prometheus_clean]
      prometheus : Create prometheus directories	TAGS: [infra, prometheus, prometheus_config]
      prometheus : Copy prometheus bin scripts	TAGS: [infra, prometheus, prometheus_config]
      prometheus : Copy prometheus rules	TAGS: [infra, prometheus, prometheus_config, prometheus_rules]
      prometheus : Render prometheus config	TAGS: [infra, prometheus, prometheus_config]
      prometheus : Render altermanager config	TAGS: [infra, prometheus, prometheus_config]
      prometheus : Config /etc/prometheus opts	TAGS: [infra, prometheus, prometheus_config]
      prometheus : Launch prometheus service	TAGS: [infra, prometheus, prometheus_launch]
      prometheus : Wait for prometheus online	TAGS: [infra, prometheus, prometheus_launch]
      prometheus : Launch alertmanager service	TAGS: [infra, prometheus, prometheus_launch]
      prometheus : Wait for alertmanager online	TAGS: [infra, prometheus, prometheus_launch]
      prometheus : Render infra file-sd targets targets for prometheus	TAGS: [infra, prometheus, prometheus_infra_targets]
      prometheus : Reload prometheus service	TAGS: [infra, prometheus, prometheus_reload]
      prometheus : Copy prometheus service definition	TAGS: [infra, prometheus, prometheus_register]
      prometheus : Copy alertmanager service definition	TAGS: [infra, prometheus, prometheus_register]
      prometheus : Reload consul to register prometheus	TAGS: [infra, prometheus, prometheus_register]
      grafana : Make sure grafana installed	TAGS: [grafana, grafana_install, infra]
      grafana : Stop grafana service	TAGS: [grafana, grafana_stop, infra]
      grafana : Check grafana plugin cache exists	TAGS: [grafana, grafana_plugins, infra]
      grafana : Provision grafana plugins via cache if exists	TAGS: [grafana, grafana_plugins, grafana_plugins_unzip, infra]
      grafana : Download grafana plugins via internet	TAGS: [grafana, grafana_plugins, infra]
      grafana : Download grafana plugins via git	TAGS: [grafana, grafana_plugins, infra]
      grafana : Remove grafana provisioning config	TAGS: [grafana, grafana_config, infra]
      grafana : Remake grafana resource dir	TAGS: [grafana, grafana_config, infra]
      grafana : Templating /etc/grafana/grafana.ini	TAGS: [grafana, grafana_config, infra]
      grafana : Templating datasources provisioning config	TAGS: [grafana, grafana_config, infra]
      grafana : Templating dashboards provisioning config	TAGS: [grafana, grafana_config, infra]
      grafana : Launch grafana service	TAGS: [grafana, grafana_launch, infra]
      grafana : Wait for grafana online	TAGS: [grafana, grafana_launch, infra]
      grafana : Sync grafana home and core dashboards	TAGS: [dashboard, dashboard_sync, grafana, grafana_provision, infra]
      grafana : Provisioning grafana with grafana.py	TAGS: [dashboard, dashboard_init, grafana, grafana_provision, infra]
      grafana : Register consul grafana service	TAGS: [grafana, grafana_register, infra]
      grafana : Reload consul	TAGS: [grafana, grafana_register, infra]

  play #2 (meta): Pgsql Init	TAGS: [pgsql]
    tasks:
      postgres : Create os group postgres	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Make sure dcs group exists	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Create dbsu {{ pg_dbsu }}	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Grant dbsu nopass sudo	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Grant dbsu all sudo	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Grant dbsu limited sudo	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Config watchdog onwer to dbsu	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Add dbsu ssh no host checking	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Fetch dbsu public keys	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Exchange dbsu ssh keys	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Install offical pgdg yum repo	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Install pg packages	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Install pg extensions	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Link /usr/pgsql to current version	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Add pg bin dir to profile path	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Fix directory ownership	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Remove default postgres service	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Check necessary variables exists	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Fetch variables via pg_cluster	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Set cluster basic facts for hosts	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Assert cluster primary singleton	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Setup cluster primary ip address	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Setup repl upstream for primary	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Setup repl upstream for replicas	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Debug print instance summary	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Check for existing postgres instance	TAGS: [pg_check, pgsql, postgres, prepare]
      postgres : Set fact whether pg port is open	TAGS: [pg_check, pgsql, postgres, prepare]
      postgres : Abort due to existing postgres instance	TAGS: [pg_check, pgsql, postgres, prepare]
      postgres : Clean existing postgres instance	TAGS: [pg_check, pgsql, postgres, prepare]
      postgres : Shutdown existing postgres service	TAGS: [pg_clean, pgsql, postgres, prepare]
      postgres : Remove registerd consul service	TAGS: [pg_clean, pgsql, postgres, prepare]
      postgres : Remove postgres metadata in consul	TAGS: [pg_clean, pgsql, postgres, prepare]
      postgres : Remove existing postgres data	TAGS: [pg_clean, pgsql, postgres, prepare]
      postgres : Make sure main and backup dir exists	TAGS: [pg_dir, pgsql, postgres, prepare]
      postgres : Create postgres directory structure	TAGS: [pg_dir, pgsql, postgres, prepare]
      postgres : Create pgbouncer directory structure	TAGS: [pg_dir, pgsql, postgres, prepare]
      postgres : Create links from pgbkup to pgroot	TAGS: [pg_dir, pgsql, postgres, prepare]
      postgres : Create links from current cluster	TAGS: [pg_dir, pgsql, postgres, prepare]
      postgres : Copy pg_cluster to /pg/meta/cluster	TAGS: [pg_meta, pgsql, postgres, prepare]
      postgres : Copy pg_version to /pg/meta/version	TAGS: [pg_meta, pgsql, postgres, prepare]
      postgres : Copy pg_instance to /pg/meta/instance	TAGS: [pg_meta, pgsql, postgres, prepare]
      postgres : Copy pg_seq to /pg/meta/sequence	TAGS: [pg_meta, pgsql, postgres, prepare]
      postgres : Copy pg_role to /pg/meta/role	TAGS: [pg_meta, pgsql, postgres, prepare]
      postgres : Copy postgres scripts to /pg/bin/	TAGS: [pg_scripts, pgsql, postgres, prepare]
      postgres : Copy alias profile to /etc/profile.d	TAGS: [pg_scripts, pgsql, postgres, prepare]
      postgres : Copy psqlrc to postgres home	TAGS: [pg_scripts, pgsql, postgres, prepare]
      postgres : Setup hostname to pg instance name	TAGS: [pg_hostname, pgsql, postgres, prepare]
      postgres : Copy consul node-meta definition	TAGS: [pg_nodemeta, pgsql, postgres, prepare]
      postgres : Restart consul to load new node-meta	TAGS: [pg_nodemeta, pgsql, postgres, prepare]
      postgres : Get config parameter page count	TAGS: [pg_config, pgsql, postgres]
      postgres : Get config parameter page size	TAGS: [pg_config, pgsql, postgres]
      postgres : Tune shared buffer and work mem	TAGS: [pg_config, pgsql, postgres]
      postgres : Hanlde small size mem occasion	TAGS: [pg_config, pgsql, postgres]
      postgres : Calculate postgres mem params	TAGS: [pg_config, pgsql, postgres]
      postgres : create patroni config dir	TAGS: [pg_config, pgsql, postgres]
      postgres : use predefined patroni template	TAGS: [pg_config, pgsql, postgres]
      postgres : Render default /pg/conf/patroni.yml	TAGS: [pg_config, pgsql, postgres]
      postgres : Link /pg/conf/patroni to /pg/bin/	TAGS: [pg_config, pgsql, postgres]
      postgres : Link /pg/bin/patroni.yml to /etc/patroni/	TAGS: [pg_config, pgsql, postgres]
      postgres : Config patroni watchdog support	TAGS: [pg_config, pgsql, postgres]
      postgres : Copy patroni systemd service file	TAGS: [pg_config, pgsql, postgres]
      postgres : create patroni systemd drop-in dir	TAGS: [pg_config, pgsql, postgres]
      postgres : Copy postgres systemd service file	TAGS: [pg_config, pgsql, postgres]
      postgres : Drop-In systemd config for patroni	TAGS: [pg_config, pgsql, postgres]
      postgres : Launch patroni on primary instance	TAGS: [pg_primary, pgsql, postgres]
      postgres : Wait for patroni primary online	TAGS: [pg_primary, pgsql, postgres]
      postgres : Wait for postgres primary online	TAGS: [pg_primary, pgsql, postgres]
      postgres : Check primary postgres service ready	TAGS: [pg_primary, pgsql, postgres]
      postgres : Check replication connectivity on primary	TAGS: [pg_primary, pgsql, postgres]
      postgres : Render init roles sql	TAGS: [pg_init, pg_init_role, pgsql, postgres]
      postgres : Render init template sql	TAGS: [pg_init, pg_init_tmpl, pgsql, postgres]
      postgres : Render default pg-init scripts	TAGS: [pg_init, pg_init_main, pgsql, postgres]
      postgres : Execute initialization scripts	TAGS: [pg_init, pg_init_exec, pgsql, postgres]
      postgres : Check primary instance ready	TAGS: [pg_init, pg_init_exec, pgsql, postgres]
      postgres : Add dbsu password to pgpass if exists	TAGS: [pg_pass, pgsql, postgres]
      postgres : Add system user to pgpass	TAGS: [pg_pass, pgsql, postgres]
      postgres : Check replication connectivity to primary	TAGS: [pg_replica, pgsql, postgres]
      postgres : Launch patroni on replica instances	TAGS: [pg_replica, pgsql, postgres]
      postgres : Wait for patroni replica online	TAGS: [pg_replica, pgsql, postgres]
      postgres : Wait for postgres replica online	TAGS: [pg_replica, pgsql, postgres]
      postgres : Check replica postgres service ready	TAGS: [pg_replica, pgsql, postgres]
      postgres : Render hba rules	TAGS: [pg_hba, pgsql, postgres]
      postgres : Reload hba rules	TAGS: [pg_hba, pgsql, postgres]
      postgres : Pause patroni	TAGS: [pg_patroni, pgsql, postgres]
      postgres : Stop patroni on replica instance	TAGS: [pg_patroni, pgsql, postgres]
      postgres : Stop patroni on primary instance	TAGS: [pg_patroni, pgsql, postgres]
      postgres : Launch raw postgres on primary	TAGS: [pg_patroni, pgsql, postgres]
      postgres : Launch raw postgres on replicas	TAGS: [pg_patroni, pgsql, postgres]
      postgres : Wait for postgres online	TAGS: [pg_patroni, pgsql, postgres]
      postgres : Check pgbouncer is installed	TAGS: [pgbouncer, pgbouncer_check, pgsql, postgres]
      postgres : Stop existing pgbouncer service	TAGS: [pgbouncer, pgbouncer_clean, pgsql, postgres]
      postgres : Remove existing pgbouncer dirs	TAGS: [pgbouncer, pgbouncer_clean, pgsql, postgres]
      postgres : Recreate dirs with owner postgres	TAGS: [pgbouncer, pgbouncer_clean, pgsql, postgres]
      postgres : Copy /etc/pgbouncer/pgbouncer.ini	TAGS: [pgbouncer, pgbouncer_config, pgbouncer_ini, pgsql, postgres]
      postgres : Copy /etc/pgbouncer/pgb_hba.conf	TAGS: [pgbouncer, pgbouncer_config, pgbouncer_hba, pgsql, postgres]
      postgres : Touch userlist and database list	TAGS: [pgbouncer, pgbouncer_config, pgsql, postgres]
      postgres : Add default users to pgbouncer	TAGS: [pgbouncer, pgbouncer_config, pgsql, postgres]
      postgres : Init pgbouncer business database list	TAGS: [pgbouncer, pgbouncer_config, pgbouncer_db, pgsql, postgres]
      postgres : Init pgbouncer business user list	TAGS: [pgbouncer, pgbouncer_config, pgbouncer_user, pgsql, postgres]
      postgres : Copy pgbouncer systemd service	TAGS: [pgbouncer, pgbouncer_launch, pgsql, postgres]
      postgres : Launch pgbouncer pool service	TAGS: [pgbouncer, pgbouncer_launch, pgsql, postgres]
      postgres : Wait for pgbouncer service online	TAGS: [pgbouncer, pgbouncer_launch, pgsql, postgres]
      postgres : Check pgbouncer service is ready	TAGS: [pgbouncer, pgbouncer_launch, pgsql, postgres]
      include_tasks	TAGS: [pg_user, pgsql, postgres]
      include_tasks	TAGS: [pg_db, pgsql, postgres]
      postgres : Reload pgbouncer to add db and users	TAGS: [pgbouncer_reload, pgsql, postgres]
      monitor : Install exporter yum repo	TAGS: [exporter_install, exporter_yum_install, monitor, pgsql]
      monitor : Install node_exporter and pg_exporter	TAGS: [exporter_install, exporter_yum_install, monitor, pgsql]
      monitor : Copy exporter binaries	TAGS: [exporter_binary_install, exporter_install, monitor, pgsql]
      monitor : Create /etc/pg_exporter conf dir	TAGS: [monitor, pg_exporter, pgsql]
      monitor : Copy default pg_exporter.yaml	TAGS: [monitor, pg_exporter, pgsql]
      monitor : Config /etc/default/pg_exporter	TAGS: [monitor, pg_exporter, pgsql]
      monitor : Config pg_exporter service unit	TAGS: [monitor, pg_exporter, pgsql]
      monitor : Launch pg_exporter systemd service	TAGS: [monitor, pg_exporter, pgsql]
      monitor : Wait for pg_exporter service online	TAGS: [monitor, pg_exporter, pgsql]
      monitor : Config pgbouncer_exporter opts	TAGS: [monitor, pgbouncer_exporter, pgsql]
      monitor : Config pgbouncer_exporter service	TAGS: [monitor, pgbouncer_exporter, pgsql]
      monitor : Launch pgbouncer_exporter service	TAGS: [monitor, pgbouncer_exporter, pgsql]
      monitor : Wait for pgbouncer_exporter online	TAGS: [monitor, pgbouncer_exporter, pgsql]
      monitor : Copy node_exporter systemd service	TAGS: [monitor, node_exporter, pgsql]
      monitor : Config default node_exporter options	TAGS: [monitor, node_exporter, pgsql]
      monitor : Launch node_exporter service unit	TAGS: [monitor, node_exporter, pgsql]
      monitor : Wait for node_exporter online	TAGS: [monitor, node_exporter, pgsql]
      service : Make sure haproxy is installed	TAGS: [haproxy, haproxy_install, pgsql, service]
      service : Create haproxy directory	TAGS: [haproxy, haproxy_install, pgsql, service]
      service : Copy haproxy systemd service file	TAGS: [haproxy, haproxy_install, haproxy_unit, pgsql, service]
      service : Fetch postgres cluster memberships	TAGS: [haproxy, haproxy_config, pgsql, service]
      service : Templating /etc/haproxy/haproxy.cfg	TAGS: [haproxy, haproxy_config, pgsql, service]
      service : Launch haproxy load balancer service	TAGS: [haproxy, haproxy_launch, haproxy_restart, pgsql, service]
      service : Wait for haproxy load balancer online	TAGS: [haproxy, haproxy_launch, pgsql, service]
      service : Reload haproxy load balancer service	TAGS: [haproxy, haproxy_reload, pgsql, service]
      service : Make sure vip-manager is installed	TAGS: [pgsql, service, vip, vip_l2_install]
      service : Copy vip-manager systemd service file	TAGS: [pgsql, service, vip, vip_l2_install]
      service : create vip-manager systemd drop-in dir	TAGS: [pgsql, service, vip, vip_l2_install]
      service : create vip-manager systemd drop-in file	TAGS: [pgsql, service, vip, vip_l2_install]
      service : Templating /etc/default/vip-manager.yml	TAGS: [pgsql, service, vip, vip_l2_config, vip_manager_config]
      service : Launch vip-manager	TAGS: [pgsql, service, vip, vip_l2_reload]
      service : Fetch postgres cluster memberships	TAGS: [pgsql, service, vip, vip_l4_config]
      service : Render L4 VIP configs	TAGS: [pgsql, service, vip, vip_l4_config]
      include_tasks	TAGS: [pgsql, service, vip, vip_l4_reload]
      register : Register postgres service to consul	TAGS: [pgsql, postgres, register, register_consul, register_consul_postgres]
      register : Register patroni service to consul	TAGS: [pgsql, postgres, register, register_consul, register_consul_patroni]
      register : Register pgbouncer service to consul	TAGS: [pgbouncer, pgsql, register, register_consul, register_consul_pgbouncer]
      register : Register node-exporter service to consul	TAGS: [node_exporter, pgsql, register, register_consul, register_consul_node_exporter]
      register : Register pg_exporter service to consul	TAGS: [pg_exporter, pgsql, register, register_consul, register_consul_pg_exporter]
      register : Register pgbouncer_exporter service to consul	TAGS: [pgbouncer_exporter, pgsql, register, register_consul, register_consul_pgbouncer_exporter]
      register : Register haproxy (exporter) service to consul	TAGS: [haproxy, pgsql, register, register_consul, register_consul_haproxy_exporter]
      register : Register cluster service to consul	TAGS: [haproxy, pgsql, register, register_consul, register_consul_cluster_service]
      register : Reload consul to finish register	TAGS: [pgsql, register, register_consul, register_consul_reload]
      register : Register pgsql instance as prometheus target	TAGS: [pgsql, register, register_prometheus]
      register : Render datasource definition on meta node	TAGS: [pgsql, register, register_grafana]
      register : Load grafana datasource on meta node	TAGS: [pgsql, register, register_grafana]
      register : Create haproxy config dir resource dirs on /etc/pigsty	TAGS: [pgsql, register, register_nginx]
      register : Register haproxy upstream to nginx	TAGS: [pgsql, register, register_nginx]
      register : Register haproxy url location to nginx	TAGS: [pgsql, register, register_nginx]
      register : Reload nginx to finish haproxy register	TAGS: [pgsql, register, register_nginx]
```

</details>





