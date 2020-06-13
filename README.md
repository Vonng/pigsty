# Pigsty -- PostgreSQL in Graphic Style

> PIGSTY: Postgres in Graphic STYle

This project provisioned a PostgreSQL cluster upon [vagrant](https://vagrantup.com/) with a battery-included monitoring system and minimal HA setup.



# Quick Start

1. Install [vagrant](https://vagrantup.com/), [virtualbox](https://www.virtualbox.org/) and [ansible](https://www.ansible.com/)
2. Clone this repo: `git clone https://github.com/vonng/pigsty && cd pigsty`
3. Setup local dns: `sudo make dns` (one-time job)
4. Pull up vm nodes: `make` 
5. Init cluster via `make init`
6. Explore pigsty via http://pigsty

```bash
# TL;DR
brew install virtualbox vagrant ansible # (may not work that way)
git clone https://github.com/vonng/pigsty && cd pigsty
sudo make dns	# run-once to write /etc/hosts, may require password
make new        # pull up all nodes and create a new cluster

# delivered service url:
PG_TEST_PRIMARY_URL=""

```

> #### Note 
>
> It may takes 30m to download packages (1GB) . So don't forget to make a local cache via  `make cache` after bootstrap. It will copy all packages to  `your_host:pigsty/pkg`. If cache is already available in `pigsty/pkg`.  Pigsty will bootstrap from it much faster (30m to 5m). Reboot from existing cluster will only takes around 30 seconds.
>
>  [Grafana](http://grafana.pigsty) default credential: `user=admin pass=admin`, if required.



## Inventory & Playbook

Default inventory file are:
* [hosts](hosts): define a meta node and a 3-node cluster pg-test

* [group_vars/all.yml](group_vars/all.yml) defines common variables for all nodes

* [group_vars/meta.yml](group_vars/meta.yml) defines variables for meta node

* [group_vars/test.yml](group_vars/test.yml) defines variables for pg-test nodes


Two major playbooks:

* [pg-meta.yml](pg-meta.yml) will init a meta control node with a cmdb pg-meta

* [pg-test.yml](pg-test.yml) will init a sample database cluster pg-test

Take `pg-meta.yml` for example, here are tasks executed by this playbook 
 
```bash
  play #1 (meta): Init meta node	TAGS: [node-meta]
    tasks:
      repo : Create local repo directory	TAGS: [node-meta, repo_precheck]
      repo : Check pigsty repo cache exists	TAGS: [node-meta, repo_precheck]
      repo : Check pigsty boot cache exists	TAGS: [node-meta, repo_precheck]
      repo : Enable default centos yum repos	TAGS: [node-meta, repo_bootstrap]
      repo : Install official centos yum repos	TAGS: [node-meta, repo_bootstrap]
      repo : Install additional nginx yum repo	TAGS: [node-meta, repo_bootstrap]
      repo : Download bootstrap packages	TAGS: [node-meta, repo_bootstrap]
      repo : Bootstrap packages downloaded	TAGS: [node-meta, repo_bootstrap]
      repo : Install bootstrap packages (nginx)	TAGS: [node-meta, repo_nginx]
      repo : Copy default nginx server config	TAGS: [node-meta, repo_nginx]
      repo : Copy default nginx index page	TAGS: [node-meta, repo_nginx]
      repo : Copy nginx pigsty repo files	TAGS: [node-meta, repo_nginx]
      repo : Start nginx service to serve repo	TAGS: [node-meta, repo_nginx]
      repo : Waits yum repo nginx online	TAGS: [node-meta, repo_nginx]
      repo : Install default centos yum repos	TAGS: [node-meta, repo_download]
      repo : Enable default centos yum repos	TAGS: [node-meta, repo_download]
      repo : Install additional yum repos	TAGS: [node-meta, repo_download]
      repo : Download build essential packages	TAGS: [node-meta, repo_download]
      repo : Download build essential packages	TAGS: [node-meta, repo_download]
      repo : Print packages to be downloaded	TAGS: [node-meta, repo_download]
      repo : Download packages to /www/pigsty	TAGS: [node-meta, repo_download]
      repo : Download cloud native packages	TAGS: [node-meta, repo_download]
      repo : Download additional url packages	TAGS: [node-meta, repo_download]
      repo : Create local yum repo index	TAGS: [node-meta, repo_download]
      repo : Mark local yum repo complete	TAGS: [node-meta, repo_download]
      node : Overwrite /etc/hosts config	TAGS: [node-meta, node_dns]
      node : Add resovler to /etc/resolv.conf	TAGS: [node-meta, node_dns]
      node : Set SELinux to permissive mode	TAGS: [node-meta, node_selinux]
      node : Disable selinux by setenforce 0	TAGS: [node-meta, node_selinux]
      node : Node configure disable swap	TAGS: [node-meta, node_tune]
      node : Node configure unmount swap	TAGS: [node-meta, node_tune]
      node : Disable transparent hugepage	TAGS: [node-meta, node_tune]
      node : Node configure disable firewall	TAGS: [node-meta, node_tune]
      node : Node configure disk prefetch	TAGS: [node-meta, node_tune]
      node : Node configure enable watchdog	TAGS: [node-meta, node_tune]
      node : Node configure disable numa	TAGS: [node-meta, node_tune]
      node : Install additional kernel modules	TAGS: [node-meta, node_kernel]
      node : Load kernel module on node start	TAGS: [node-meta, node_kernel]
      node : Change sysctl.conf parameters	TAGS: [node-meta, node_sysctl]
      node : Create os user group postgres	TAGS: [node-meta, node_user]
      node : Create os user postgres:postgres	TAGS: [node-meta, node_user]
      node : Create os user prometheus:postgres	TAGS: [node-meta, node_user]
      node : Create os user consul:postgres	TAGS: [node-meta, node_user]
      node : Create os user etcd:postgres	TAGS: [node-meta, node_user]
      node : Copy default user bash profile	TAGS: [node-meta, node_profile]
      node : Install local yum repo for node	TAGS: [node-meta, node_repo]
      node : Configure node using local repo	TAGS: [node-meta, node_repo]
      node : Install cloud repo if enabled	TAGS: [node-meta, node_repo]
      node : Install cloud native packages	TAGS: [node-meta, node_install]
      node : Install build essential packages	TAGS: [node-meta, node_install]
      node : Install additional node packages	TAGS: [node-meta, node_install]
      node : Install node packages from yum	TAGS: [node-meta, node_install]
      node : Install chronyd package on node	TAGS: [node-meta, node_ntp]
      node : Copy the chrony.conf template	TAGS: [node-meta, node_ntp]
      node : Launch chronyd ntpd service	TAGS: [node-meta, node_ntp]
      node : Set local timezone and synctime	TAGS: [node-meta, node_ntp]
      consul : Set default consul node name	TAGS: [consul, node-meta]
      consul : Get hostname as consul node name	TAGS: [consul, node-meta]
      consul : Set consul node name to hostname	TAGS: [consul, node-meta]
      consul : Stop existing consul service	TAGS: [consul, node-meta]
      consul : Copy consul server service unit	TAGS: [consul, node-meta]
      consul : Copy consul agent service unit	TAGS: [consul, node-meta]
      consul : Remove existing consul data	TAGS: [consul, node-meta]
      consul : Recreate /etc/consul.d dir	TAGS: [consul, node-meta]
      consul : Recreate /var/lib/consul dir	TAGS: [consul, node-meta]
      consul : Copy /etc/consul.d/consul.json	TAGS: [consul, node-meta]
      consul : Launch consul service unit	TAGS: [consul, node-meta]
      consul : Wait for consul service online	TAGS: [consul, node-meta]
      meta : Install build essential packages	TAGS: [meta_install, node-meta]
      meta : Install meta packages from yum	TAGS: [meta_install, node-meta]
      meta : Copy additional nginx proxy conf	TAGS: [meta_nginx, node-meta]
      meta : Update default nginx index page	TAGS: [meta_nginx, node-meta]
      meta : Restart pigsty nginx service	TAGS: [meta_nginx, node-meta]
      meta : Config nginx_exporter options	TAGS: [meta_nginx, node-meta]
      meta : Restart nginx_exporter service	TAGS: [meta_nginx, node-meta]
      meta : Copy dnsmasq /etc/dnsmasq.d/config	TAGS: [meta_dnsmasq, node-meta]
      meta : Copy dnsmasq hosts /etc/hosts	TAGS: [meta_dnsmasq, node-meta]
      meta : Launch meta dnsmasq service	TAGS: [meta_dnsmasq, node-meta]
      meta : Wait for meta dnsmasq online	TAGS: [meta_dnsmasq, node-meta]
      meta : Wipe out prometheus config dir	TAGS: [meta_prometheus, node-meta]
      meta : Wipe out existing prometheus data	TAGS: [meta_prometheus, node-meta]
      meta : Recreate prometheus data dir	TAGS: [meta_prometheus, node-meta]
      meta : Copy /etc/prometheus configs	TAGS: [meta_prometheus, node-meta]
      meta : Launch meta prometheus service	TAGS: [meta_prometheus, node-meta]
      meta : Launch meta alertmanager service	TAGS: [meta_prometheus, node-meta]
      meta : Wait for meta prometheus online	TAGS: [meta_prometheus, node-meta]
      meta : Wait for meta alertmanager online	TAGS: [meta_prometheus, node-meta]
      meta : Copy /etc/grafana/grafana.ini	TAGS: [meta_grafana, node-meta]
      meta : Provision grafana via grafana.db	TAGS: [meta_grafana, node-meta]
      meta : Provision grafana datasources	TAGS: [meta_grafana, node-meta]
      meta : Provision grafana dashboards	TAGS: [meta_grafana, node-meta]
      meta : Launch meta grafana service	TAGS: [meta_grafana, node-meta]
      meta : Wait for meta grafana online	TAGS: [meta_grafana, node-meta]
      meta : Check grafana plugin cache exists	TAGS: [meta_plugins, node-meta]
      meta : Provision grafana plugin via cache	TAGS: [meta_plugins, node-meta]
      meta : Download plugins if not exists	TAGS: [meta_plugins, node-meta]
      meta : Restart meta grafana service	TAGS: [meta_plugins, node-meta]
      meta : Copy consul services definition	TAGS: [meta_register, node-meta]
      meta : Reload consul meta services	TAGS: [meta_register, node-meta]

  play #2 (meta): Init pg-meta database cluster on meta node(s)	TAGS: [pg-meta]
    tasks:
      pg_preflight : Check cluster role seq exists	TAGS: [always, pg-meta, pg_precheck]
      pg_preflight : Set instance name and host facts	TAGS: [always, pg-meta, pg_precheck]
      pg_preflight : Set addional facts from inventory	TAGS: [always, pg-meta, pg_precheck]
      pg_preflight : Check all hosts in same cluster	TAGS: [always, pg-meta, pg_precheck]
      pg_preflight : Check cluster primary singleton	TAGS: [always, pg-meta, pg_precheck]
      pg_preflight : Set replica replication source	TAGS: [always, pg-meta, pg_precheck]
      pg_preflight : Build group based on role fact	TAGS: [always, pg-meta, pg_precheck]
      pg_install : Create group postgres if not exists	TAGS: [pg-meta, pg_dbsu]
      pg_install : Create user postgres  if not exists	TAGS: [pg-meta, pg_dbsu]
      pg_install : Allow dbus postgres nopass sudo	TAGS: [pg-meta, pg_dbsu]
      pg_install : Setup dbsu postgres pam limit	TAGS: [pg-meta, pg_dbsu]
      pg_install : Add no host checking to ssh config	TAGS: [pg-meta, pg_dbsu]
      pg_install : Fetch all public key amoung cluster	TAGS: [pg-meta, pg_dbsu]
      pg_install : Copy ssh key to authorized hosts	TAGS: [pg-meta, pg_dbsu]
      pg_install : Create postgres directory structure	TAGS: [pg-meta, pg_directory]
      pg_install : Create links from pgbkup to pgroot	TAGS: [pg-meta, pg_directory]
      pg_install : Install offical pgdg yum repo	TAGS: [pg-meta, pg_install]
      pg_install : Listing packages to be installed	TAGS: [pg-meta, pg_install]
      pg_install : Add postgis packages to checklist	TAGS: [pg-meta, pg_install]
      pg_install : Add extension packages to checklist	TAGS: [pg-meta, pg_install]
      pg_install : Print packages to be installed	TAGS: [pg-meta, pg_install]
      pg_install : Install postgres major version	TAGS: [pg-meta, pg_install]
      pg_install : Install postgres according to list	TAGS: [pg-meta, pg_install]
      pg_install : Link /usr/pgsql to current version	TAGS: [pg-meta, pg_install]
      pg_install : Add /usr/ppgsql to profile path	TAGS: [pg-meta, pg_install]
      pg_install : Check installed pgsql version	TAGS: [pg-meta, pg_install]
      pg_install : Copy postgres systemd service file	TAGS: [pg-meta, pg_install]
      pg_install : Daemon reload postgres service	TAGS: [pg-meta, pg_install]
      pg_primary : Check primary postgres version	TAGS: [pg-meta, pg_primary_check]
      pg_primary : Check primary instance not running	TAGS: [pg-meta, pg_primary_check]
      pg_primary : Set default postgres conf path	TAGS: [pg-meta, pg_primary_check]
      pg_primary : Stop patroni service if exists	TAGS: [pg-meta, pg_primary_clean]
      pg_primary : Stop postgres primary service	TAGS: [pg-meta, pg_primary_clean]
      pg_primary : Stop running postgres double check	TAGS: [pg-meta, pg_primary_clean]
      pg_primary : Remove existing /pg/data directory	TAGS: [pg-meta, pg_primary_clean]
      pg_primary : Recreate default /pg/data directory	TAGS: [pg-meta, pg_primary_clean]
      pg_primary : Init primary database cluster	TAGS: [pg-meta, pg_primary_init]
      pg_primary : Copy primary default postgresql.conf	TAGS: [pg-meta, pg_primary_config]
      pg_primary : Copy primary default pg_hba.conf	TAGS: [pg-meta, pg_primary_config]
      pg_primary : Start primary postgres service	TAGS: [pg-meta, pg_primary_launch]
      pg_primary : Waits for primary postgres online	TAGS: [pg-meta, pg_primary_launch]
      pg_primary : Check primary postgres is ready	TAGS: [pg-meta, pg_primary_launch]
      pg_primary : Create cluster replication user	TAGS: [pg-meta, pg_primary_bootstrap]
      pg_primary : Grant function usage to replicator	TAGS: [pg-meta, pg_primary_bootstrap]
      pg_primary : Create cluster default monitor user	TAGS: [pg-meta, pg_primary_bootstrap]
      pg_primary : Grant pg_monitor to dbuser_monitor	TAGS: [pg-meta, pg_primary_bootstrap]
      pg_primary : Create pgpass with replication user	TAGS: [pg-meta, pg_primary_bootstrap]
      pg_primary : Check replication user connectivity	TAGS: [pg-meta, pg_primary_bootstrap]
      pg_primary : Create default read/write role	TAGS: [pg-meta, pg_primary_bootstrap]
      pg_primary : Create cluster default admin role	TAGS: [pg-meta, pg_primary_bootstrap]
      pg_primary : Grant readonly role to rw & monitor	TAGS: [pg-meta, pg_primary_bootstrap]
      pg_primary : Grant readwrite role to admin	TAGS: [pg-meta, pg_primary_bootstrap]
      pg_primary : Grant admin role to sa postgres	TAGS: [pg-meta, pg_primary_bootstrap]
      pg_primary : Alter default privileges for admin	TAGS: [pg-meta, pg_primary_bootstrap]
      pg_primary : Create default business dbuser	TAGS: [pg-meta, pg_primary_createdb]
      pg_primary : Grant admin role to default user	TAGS: [pg-meta, pg_primary_createdb]
      pg_primary : Create default business database	TAGS: [pg-meta, pg_primary_createdb]
      pg_primary : Create pgpass with business userinfo	TAGS: [pg-meta, pg_primary_createdb]
      pg_primary : Check business database connectivity	TAGS: [pg-meta, pg_primary_createdb]
      pg_replica : Check replica postgres version	TAGS: [pg-meta, pg_replica_check]
      pg_replica : Check replica instance not running	TAGS: [pg-meta, pg_replica_check]
      pg_replica : Set replica upstream and hba path	TAGS: [pg-meta, pg_replica_check]
      pg_replica : Stop patroni service if exists	TAGS: [pg-meta, pg_replica_clean]
      pg_replica : Stop postgres replica service	TAGS: [pg-meta, pg_replica_clean]
      pg_replica : Stop running postgres double check	TAGS: [pg-meta, pg_replica_clean]
      pg_replica : Remove existing /pg/data directory	TAGS: [pg-meta, pg_replica_clean]
      pg_replica : Recreate default /pg/data directory	TAGS: [pg-meta, pg_replica_clean]
      pg_replica : Write pgpass with default userinfo	TAGS: [pg-meta, pg_replica_init]
      pg_replica : Add replication user to pgpass	TAGS: [pg-meta, pg_replica_init]
      pg_replica : Check connectivity to primary	TAGS: [pg-meta, pg_replica_init]
      pg_replica : Create basebackup from primary	TAGS: [pg-meta, pg_replica_init]
      pg_replica : Copy replica default postgresql.conf	TAGS: [pg-meta, pg_replica_config]
      pg_replica : Copy replica default pg_hba.conf	TAGS: [pg-meta, pg_replica_config]
      pg_replica : Setup replica replication source	TAGS: [pg-meta, pg_replica_config]
      pg_replica : Start replica postgres service	TAGS: [pg-meta, pg_replica_launch]
      pg_replica : Waits for replica postgres online	TAGS: [pg-meta, pg_replica_launch]
      pg_replica : Check replica postgres is ready	TAGS: [pg-meta, pg_replica_launch]
      pg_pgbouncer : Check pgbouncer is installed	TAGS: [pg-meta, pgbouncer_check]
      pg_pgbouncer : Stop running pgbouncer service	TAGS: [pg-meta, pgbouncer_cleanup]
      pg_pgbouncer : Remove existing pgbouncer dirs	TAGS: [pg-meta, pgbouncer_cleanup]
      pg_pgbouncer : Recreate dirs with owner postgres	TAGS: [pg-meta, pgbouncer_cleanup]
      pg_pgbouncer : Copy /etc/pgbouncer/pgbouncer.ini	TAGS: [pg-meta, pgbouncer_config]
      pg_pgbouncer : Copy /etc/pgbouncer/pgb_hba.conf	TAGS: [pg-meta, pgbouncer_config]
      pg_pgbouncer : Generate pgbouncer userlist.txt	TAGS: [pg-meta, pgbouncer_config]
      pg_pgbouncer : Copy pgbouncer systemd service	TAGS: [pg-meta, pgbouncer_config]
      pg_pgbouncer : Launch pgbouncer pool service	TAGS: [pg-meta, pgbouncer_launch]
      pg_pgbouncer : Wait for pgbouncer service online	TAGS: [pg-meta, pgbouncer_launch]
      pg_pgbouncer : Check pgbouncer service is ready	TAGS: [pg-meta, pgbouncer_launch]
      pg_pgbouncer : Check pgbouncer connectivity	TAGS: [pg-meta, pgbouncer_launch]
      pg_patroni : Install patroni from local yum	TAGS: [patroni_install, pg-meta]
      pg_patroni : Disable existing patroni services	TAGS: [patroni_cleanup, pg-meta]
      pg_patroni : Remove patroni consul metadata	TAGS: [patroni_cleanup, pg-meta]
      pg_patroni : Copy patroni callback scripts	TAGS: [patroni_setup, pg-meta]
      pg_patroni : Copy default /pg/conf/patroni.yml	TAGS: [patroni_setup, pg-meta]
      pg_patroni : Link /pg/conf/patroni to /pg/bin/	TAGS: [patroni_setup, pg-meta]
      pg_patroni : Copy patroni systemd service unit	TAGS: [patroni_setup, pg-meta]
      pg_patroni : Launch patroni on primary instance	TAGS: [patroni_setup, pg-meta]
      pg_patroni : Launch patroni on replica instances	TAGS: [patroni_setup, pg-meta]
      pg_patroni : Wait for patroni service online	TAGS: [patroni_setup, pg-meta]
      pg_proxy : Render /etc/haproxy/haproxy.cfg	TAGS: [pg-meta, pg_haproxy]
      pg_proxy : Copy haproxy systemd service file	TAGS: [pg-meta, pg_haproxy]
      pg_proxy : Increase pam ulimit for user haproxy	TAGS: [pg-meta, pg_haproxy]
      pg_proxy : Launch haproxy on all instances	TAGS: [pg-meta, pg_haproxy]
      pg_proxy : Wait for haproxy service online	TAGS: [pg-meta, pg_haproxy]
      pg_monitor : Create /etc/pg_exporter conf dir	TAGS: [pg-meta, pg_exporter]
      pg_monitor : Copy default pg_exporter.yaml	TAGS: [pg-meta, pg_exporter]
      pg_monitor : Config /etc/default/pg_exporter	TAGS: [pg-meta, pg_exporter]
      pg_monitor : Config pg_exporter service unit	TAGS: [pg-meta, pg_exporter]
      pg_monitor : Launch pg_exporter systemd service	TAGS: [pg-meta, pg_exporter]
      pg_monitor : Wait for pg_exporter service online	TAGS: [pg-meta, pg_exporter]
      pg_monitor : Config pgbouncer_exporter opts	TAGS: [pg-meta, pgbouncer_exporter]
      pg_monitor : Config pgbouncer_exporter service	TAGS: [pg-meta, pgbouncer_exporter]
      pg_monitor : Launch pgbouncer_exporter service	TAGS: [pg-meta, pgbouncer_exporter]
      pg_monitor : Wait for pgbouncer_exporter online	TAGS: [pg-meta, pgbouncer_exporter]
      pg_monitor : Copy node_exporter systemd service	TAGS: [node_exporter, pg-meta]
      pg_monitor : Config default node_exporter options	TAGS: [node_exporter, pg-meta]
      pg_monitor : Launch node_exporter service unit	TAGS: [node_exporter, pg-meta]
      pg_monitor : Wait for node_exporter online	TAGS: [node_exporter, pg-meta]
      pg_monitor : Register postgres monitoring service	TAGS: [pg-meta, pg_register]
      pg_monitor : Register patroni service if enabled	TAGS: [pg-meta, pg_register]
      pg_monitor : Register load balancer service	TAGS: [pg-meta, pg_register]
      pg_monitor : Restart consul to reload node-meta	TAGS: [pg-meta, pg_register]
```


## Operations

```
make			# launch cluster
make new        # create a new pigsty cluster
make dns		# write pigsty dns record to your /etc/hosts (sudo required)
make ssh		# write ssh config to your ~/.ssh/config
make init		# init infrastructure and postgres cluster
make cache		# copy local yum repo packages to your pigsty/pkg
make clean		# delete current cluster
```



## Architecture

TBD


## Todo List

* cloud native support 
* lvs based load balancer
* haproxy admin scripts
* consul template or vip-manager 


## What's Next?

* Explore the monitoring system
* How service discovery works
* Add some load to cluster
* Managing postgres cluster with ansible
* High Available Drill




## About

Author：Vonng ([fengruohang@outlook.com](mailto:fengruohang@outlook.com))

LICENSE: [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/)