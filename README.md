# Pigsty -- PostgreSQL in Graphic Style

> PIGSTY: Postgres in Graphic STYle

This project provisioned a PostgreSQL cluster upon [vagrant](https://vagrantup.com/) with a battery-included monitoring system and minimal HA setup.



## Features

* High Availability
* Monitoring System
* Service Discovery
* Fine scripts
* Bare metal deployment
* Cloud native deployment (Progressing)



## Quick Start

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



## Inventory

Default inventory file are:

* [hosts](hosts): define a meta node and a 3-node cluster pg-test

* [group_vars/all.yml](group_vars/all.yml) defines common variables for all nodes

* [group_vars/meta.yml](group_vars/meta.yml) defines variables for meta node

* [group_vars/test.yml](group_vars/test.yml) defines variables for pg-test nodes



## Playbooks

[`init.yml`](init.yml) will just pull everything up.

### **Infrastructure Initialization** 

* [provision.yml](provision.yml) will setup repo and noes in vagrant environment

* [init-meta.yml](init-meta.yml) will init a meta control node with a cmdb pg-meta

* [init-test.yml](init-test.yml) will init a sample database cluster pg-test

* [init-kube.yml](init-kube.yml) (optional) will create a 3-node kubernetes cluster

* [stop-psql.yml](stop-psql.yml) will stop existing postgres related service


### **Database Administration**

* admin-report.yml
* admin-backup.yml
* admin-repack.yml
* admin-vacuum.yml
* admin-deploy.yml
* admin-restart.yml
* admin-reload.yml
* admin-createdb.yml
* admin-createuser.yml
* admin-edit-hba.yml
* admin-edit-config.yml
* admin-dump-schema.yml
* admin-dump-table.yml
* admin-copy-data.yml
* admin-pg-exporter-reload.yml

### **Database HA**

* ha-switchover.yml
* ha-failover.yml
* ha-election.yml
* ha-rewind.yml
* ha-restore.yml
* ha-pitr.yml
* ha-drain.yml
* ha-proxy-add.yml
* ha-proxy-remove.yml
* ha-proxy-switch.yml
* ha-repl-report.yml
* ha-repl-sync.yml
* ha-repl-retarget.yml
* ha-pool-retarget.yml
* ha-pool-pause.yml
* ha-pool-resume.yml

Take `init-meta.yml` for example, here are tasks executed by this playbook 

```bash
play #1 (meta): Init meta node	TAGS: [init-meta]
tasks:
  repo : Create local repo directory	TAGS: [init-meta, repo_precheck]
  repo : Check pigsty repo cache exists	TAGS: [init-meta, repo_precheck]
  repo : Check pigsty boot cache exists	TAGS: [init-meta, repo_precheck]
  repo : Enable default centos yum repos	TAGS: [init-meta, repo_bootstrap]
  repo : Install official centos yum repos	TAGS: [init-meta, repo_bootstrap]
  repo : Install additional nginx yum repo	TAGS: [init-meta, repo_bootstrap]
  repo : Download bootstrap packages	TAGS: [init-meta, repo_bootstrap]
  repo : Bootstrap packages downloaded	TAGS: [init-meta, repo_bootstrap]
  repo : Install bootstrap packages (nginx)	TAGS: [init-meta, repo_nginx]
  repo : Copy default nginx server config	TAGS: [init-meta, repo_nginx]
  repo : Copy default nginx index page	TAGS: [init-meta, repo_nginx]
  repo : Copy nginx pigsty repo files	TAGS: [init-meta, repo_nginx]
  repo : Start nginx service to serve repo	TAGS: [init-meta, repo_nginx]
  repo : Waits yum repo nginx online	TAGS: [init-meta, repo_nginx]
  repo : Install default centos yum repos	TAGS: [init-meta, repo_download]
  repo : Enable default centos yum repos	TAGS: [init-meta, repo_download]
  repo : Install additional yum repos	TAGS: [init-meta, repo_download]
  repo : Download build essential packages	TAGS: [init-meta, repo_download]
  repo : Download build essential packages	TAGS: [init-meta, repo_download]
  repo : Print packages to be downloaded	TAGS: [init-meta, repo_download]
  repo : Download packages to /www/pigsty	TAGS: [init-meta, repo_download]
  repo : Download cloud native packages	TAGS: [init-meta, repo_download]
  repo : Download additional url packages	TAGS: [init-meta, repo_download]
  repo : Create local yum repo index	TAGS: [init-meta, repo_download]
  repo : Mark local yum repo complete	TAGS: [init-meta, repo_download]
  node : Overwrite /etc/hosts config	TAGS: [init-meta, node_dns]
  node : Add resovler to /etc/resolv.conf	TAGS: [init-meta, node_dns]
  node : Set SELinux to permissive mode	TAGS: [init-meta, node_selinux]
  node : Disable selinux by setenforce 0	TAGS: [init-meta, node_selinux]
  node : Disable linux firewalld service	TAGS: [init-meta, node_selinux]
  node : Node configure disable swap	TAGS: [init-meta, node_tune]
  node : Node configure unmount swap	TAGS: [init-meta, node_tune]
  node : Disable transparent hugepage	TAGS: [init-meta, node_tune]
  node : Node configure disable firewall	TAGS: [init-meta, node_tune]
  node : Node configure disk prefetch	TAGS: [init-meta, node_tune]
  node : Node configure enable watchdog	TAGS: [init-meta, node_tune]
  node : Node configure disable numa	TAGS: [init-meta, node_tune]
  node : Install additional kernel modules	TAGS: [init-meta, node_kernel]
  node : Load kernel module on node start	TAGS: [init-meta, node_kernel]
  node : Change sysctl.conf parameters	TAGS: [init-meta, node_sysctl]
  node : Create os user group postgres	TAGS: [init-meta, node_user]
  node : Create os user postgres:postgres	TAGS: [init-meta, node_user]
  node : Create os user prometheus:postgres	TAGS: [init-meta, node_user]
  node : Create os user consul:postgres	TAGS: [init-meta, node_user]
  node : Create os user etcd:postgres	TAGS: [init-meta, node_user]
  node : Copy default user bash profile	TAGS: [init-meta, node_profile]
  node : Install local yum repo for node	TAGS: [init-meta, node_repo]
  node : Configure node using local repo	TAGS: [init-meta, node_repo]
  node : Install cloud repo if enabled	TAGS: [init-meta, node_repo]
  node : Install cloud native packages	TAGS: [init-meta, node_install]
  node : Install build essential packages	TAGS: [init-meta, node_install]
  node : Install additional node packages	TAGS: [init-meta, node_install]
  node : Install node packages from yum	TAGS: [init-meta, node_install]
  node : Install chronyd package on node	TAGS: [init-meta, node_ntp]
  node : Copy the chrony.conf template	TAGS: [init-meta, node_ntp]
  node : Launch chronyd ntpd service	TAGS: [init-meta, node_ntp]
  node : Set local timezone and synctime	TAGS: [init-meta, node_ntp]
  consul : Set default consul node name	TAGS: [consul, init-meta]
  consul : Get hostname as consul node name	TAGS: [consul, init-meta]
  consul : Set consul node name to hostname	TAGS: [consul, init-meta]
  consul : Stop existing consul service	TAGS: [consul, init-meta]
  consul : Copy consul server service unit	TAGS: [consul, init-meta]
  consul : Copy consul agent service unit	TAGS: [consul, init-meta]
  consul : Remove existing consul data	TAGS: [consul, init-meta]
  consul : Recreate /etc/consul.d dir	TAGS: [consul, init-meta]
  consul : Recreate /var/lib/consul dir	TAGS: [consul, init-meta]
  consul : Copy /etc/consul.d/consul.json	TAGS: [consul, init-meta]
  consul : Launch consul service unit	TAGS: [consul, init-meta]
  consul : Wait for consul service online	TAGS: [consul, init-meta]
  meta : Install build essential packages	TAGS: [init-meta, meta_install]
  meta : Install meta packages from yum	TAGS: [init-meta, meta_install]
  meta : Copy additional nginx proxy conf	TAGS: [init-meta, meta_nginx]
  meta : Update default nginx index page	TAGS: [init-meta, meta_nginx]
  meta : Restart pigsty nginx service	TAGS: [init-meta, meta_nginx]
  meta : Config nginx_exporter options	TAGS: [init-meta, meta_nginx]
  meta : Restart nginx_exporter service	TAGS: [init-meta, meta_nginx]
  meta : Copy dnsmasq /etc/dnsmasq.d/config	TAGS: [init-meta, meta_dnsmasq]
  meta : Copy dnsmasq hosts /etc/hosts	TAGS: [init-meta, meta_dnsmasq]
  meta : Launch meta dnsmasq service	TAGS: [init-meta, meta_dnsmasq]
  meta : Wait for meta dnsmasq online	TAGS: [init-meta, meta_dnsmasq]
  meta : Wipe out prometheus config dir	TAGS: [init-meta, meta_prometheus]
  meta : Wipe out existing prometheus data	TAGS: [init-meta, meta_prometheus]
  meta : Recreate prometheus data dir	TAGS: [init-meta, meta_prometheus]
  meta : Copy /etc/prometheus configs	TAGS: [init-meta, meta_prometheus]
  meta : Launch meta prometheus service	TAGS: [init-meta, meta_prometheus]
  meta : Launch meta alertmanager service	TAGS: [init-meta, meta_prometheus]
  meta : Wait for meta prometheus online	TAGS: [init-meta, meta_prometheus]
  meta : Wait for meta alertmanager online	TAGS: [init-meta, meta_prometheus]
  meta : Copy /etc/grafana/grafana.ini	TAGS: [init-meta, meta_grafana]
  meta : Provision grafana via grafana.db	TAGS: [init-meta, meta_grafana]
  meta : Provision grafana datasources	TAGS: [init-meta, meta_grafana]
  meta : Provision grafana dashboards	TAGS: [init-meta, meta_grafana]
  meta : Launch meta grafana service	TAGS: [init-meta, meta_grafana]
  meta : Wait for meta grafana online	TAGS: [init-meta, meta_grafana]
  meta : Check grafana plugin cache exists	TAGS: [init-meta, meta_plugins]
  meta : Provision grafana plugin via cache	TAGS: [init-meta, meta_plugins]
  meta : Download plugins if not exists	TAGS: [init-meta, meta_plugins]
  meta : Restart meta grafana service	TAGS: [init-meta, meta_plugins]
  meta : Copy consul services definition	TAGS: [init-meta, meta_register]
  meta : Reload consul meta services	TAGS: [init-meta, meta_register]

play #2 (meta): Init pg-meta database cluster on meta node(s)	TAGS: [init-meta]
tasks:
  pg_preflight : Check cluster role seq exists	TAGS: [always, init-meta, pg_precheck]
  pg_preflight : Set instance name and host facts	TAGS: [always, init-meta, pg_precheck]
  pg_preflight : Set addional facts from inventory	TAGS: [always, init-meta, pg_precheck]
  pg_preflight : Check all hosts in same cluster	TAGS: [always, init-meta, pg_precheck]
  pg_preflight : Check cluster primary singleton	TAGS: [always, init-meta, pg_precheck]
  pg_preflight : Set replica replication source	TAGS: [always, init-meta, pg_precheck]
  pg_preflight : Build group based on role fact	TAGS: [always, init-meta, pg_precheck]
  pg_install : Create group postgres if not exists	TAGS: [init-meta, pg_dbsu]
  pg_install : Create user postgres  if not exists	TAGS: [init-meta, pg_dbsu]
  pg_install : Allow dbus postgres nopass sudo	TAGS: [init-meta, pg_dbsu]
  pg_install : Setup dbsu postgres pam limit	TAGS: [init-meta, pg_dbsu]
  pg_install : Add no host checking to ssh config	TAGS: [init-meta, pg_dbsu]
  pg_install : Fetch all public key amoung cluster	TAGS: [init-meta, pg_dbsu]
  pg_install : Copy ssh key to authorized hosts	TAGS: [init-meta, pg_dbsu]
  pg_install : Create postgres directory structure	TAGS: [init-meta, pg_directory]
  pg_install : Create links from pgbkup to pgroot	TAGS: [init-meta, pg_directory]
  pg_install : Install offical pgdg yum repo	TAGS: [init-meta, pg_install]
  pg_install : Listing packages to be installed	TAGS: [init-meta, pg_install]
  pg_install : Add postgis packages to checklist	TAGS: [init-meta, pg_install]
  pg_install : Add extension packages to checklist	TAGS: [init-meta, pg_install]
  pg_install : Print packages to be installed	TAGS: [init-meta, pg_install]
  pg_install : Install postgres major version	TAGS: [init-meta, pg_install]
  pg_install : Install postgres according to list	TAGS: [init-meta, pg_install]
  pg_install : Link /usr/pgsql to current version	TAGS: [init-meta, pg_install]
  pg_install : Add /usr/ppgsql to profile path	TAGS: [init-meta, pg_install]
  pg_install : Check installed pgsql version	TAGS: [init-meta, pg_install]
  pg_install : Copy postgres systemd service file	TAGS: [init-meta, pg_install]
  pg_install : Daemon reload postgres service	TAGS: [init-meta, pg_install]
  pg_primary : Check primary postgres version	TAGS: [init-meta, pg_primary_check]
  pg_primary : Check primary instance not running	TAGS: [init-meta, pg_primary_check]
  pg_primary : Set default postgres conf path	TAGS: [init-meta, pg_primary_check]
  pg_primary : Stop patroni service if exists	TAGS: [init-meta, pg_primary_clean]
  pg_primary : Stop postgres primary service	TAGS: [init-meta, pg_primary_clean]
  pg_primary : Stop running postgres double check	TAGS: [init-meta, pg_primary_clean]
  pg_primary : Remove existing /pg/data directory	TAGS: [init-meta, pg_primary_clean]
  pg_primary : Recreate default /pg/data directory	TAGS: [init-meta, pg_primary_clean]
  pg_primary : Init primary database cluster	TAGS: [init-meta, pg_primary_init]
  pg_primary : Copy primary default postgresql.conf	TAGS: [init-meta, pg_primary_config]
  pg_primary : Copy primary default pg_hba.conf	TAGS: [init-meta, pg_primary_config]
  pg_primary : Start primary postgres service	TAGS: [init-meta, pg_primary_launch]
  pg_primary : Waits for primary postgres online	TAGS: [init-meta, pg_primary_launch]
  pg_primary : Check primary postgres is ready	TAGS: [init-meta, pg_primary_launch]
  pg_primary : Create cluster replication user	TAGS: [init-meta, pg_primary_bootstrap]
  pg_primary : Grant function usage to replicator	TAGS: [init-meta, pg_primary_bootstrap]
  pg_primary : Create cluster default monitor user	TAGS: [init-meta, pg_primary_bootstrap]
  pg_primary : Grant pg_monitor to dbuser_monitor	TAGS: [init-meta, pg_primary_bootstrap]
  pg_primary : Create pgpass with replication user	TAGS: [init-meta, pg_primary_bootstrap]
  pg_primary : Check replication user connectivity	TAGS: [init-meta, pg_primary_bootstrap]
  pg_primary : Create default read/write role	TAGS: [init-meta, pg_primary_bootstrap]
  pg_primary : Create cluster default admin role	TAGS: [init-meta, pg_primary_bootstrap]
  pg_primary : Grant readonly role to rw & monitor	TAGS: [init-meta, pg_primary_bootstrap]
  pg_primary : Grant readwrite role to admin	TAGS: [init-meta, pg_primary_bootstrap]
  pg_primary : Grant admin role to sa postgres	TAGS: [init-meta, pg_primary_bootstrap]
  pg_primary : Alter default privileges for admin	TAGS: [init-meta, pg_primary_bootstrap]
  pg_primary : Create default business dbuser	TAGS: [init-meta, pg_primary_createdb]
  pg_primary : Grant admin role to default user	TAGS: [init-meta, pg_primary_createdb]
  pg_primary : Create default business database	TAGS: [init-meta, pg_primary_createdb]
  pg_primary : Create pgpass with business userinfo	TAGS: [init-meta, pg_primary_createdb]
  pg_primary : Check business database connectivity	TAGS: [init-meta, pg_primary_createdb]
  pg_replica : Check replica postgres version	TAGS: [init-meta, pg_replica_check]
  pg_replica : Check replica instance not running	TAGS: [init-meta, pg_replica_check]
  pg_replica : Set replica upstream and hba path	TAGS: [init-meta, pg_replica_check]
  pg_replica : Stop patroni service if exists	TAGS: [init-meta, pg_replica_clean]
  pg_replica : Stop postgres replica service	TAGS: [init-meta, pg_replica_clean]
  pg_replica : Stop running postgres double check	TAGS: [init-meta, pg_replica_clean]
  pg_replica : Remove existing /pg/data directory	TAGS: [init-meta, pg_replica_clean]
  pg_replica : Recreate default /pg/data directory	TAGS: [init-meta, pg_replica_clean]
  pg_replica : Write pgpass with default userinfo	TAGS: [init-meta, pg_replica_init]
  pg_replica : Add replication user to pgpass	TAGS: [init-meta, pg_replica_init]
  pg_replica : Check connectivity to primary	TAGS: [init-meta, pg_replica_init]
  pg_replica : Create basebackup from primary	TAGS: [init-meta, pg_replica_init]
  pg_replica : Copy replica default postgresql.conf	TAGS: [init-meta, pg_replica_config]
  pg_replica : Copy replica default pg_hba.conf	TAGS: [init-meta, pg_replica_config]
  pg_replica : Setup replica replication source	TAGS: [init-meta, pg_replica_config]
  pg_replica : Start replica postgres service	TAGS: [init-meta, pg_replica_launch]
  pg_replica : Waits for replica postgres online	TAGS: [init-meta, pg_replica_launch]
  pg_replica : Check replica postgres is ready	TAGS: [init-meta, pg_replica_launch]
  pg_pgbouncer : Check pgbouncer is installed	TAGS: [init-meta, pgbouncer_check]
  pg_pgbouncer : Stop running pgbouncer service	TAGS: [init-meta, pgbouncer_cleanup]
  pg_pgbouncer : Remove existing pgbouncer dirs	TAGS: [init-meta, pgbouncer_cleanup]
  pg_pgbouncer : Recreate dirs with owner postgres	TAGS: [init-meta, pgbouncer_cleanup]
  pg_pgbouncer : Copy /etc/pgbouncer/pgbouncer.ini	TAGS: [init-meta, pgbouncer_config]
  pg_pgbouncer : Copy /etc/pgbouncer/pgb_hba.conf	TAGS: [init-meta, pgbouncer_config]
  pg_pgbouncer : Generate pgbouncer userlist.txt	TAGS: [init-meta, pgbouncer_config]
  pg_pgbouncer : Copy pgbouncer systemd service	TAGS: [init-meta, pgbouncer_config]
  pg_pgbouncer : Launch pgbouncer pool service	TAGS: [init-meta, pgbouncer_launch]
  pg_pgbouncer : Wait for pgbouncer service online	TAGS: [init-meta, pgbouncer_launch]
  pg_pgbouncer : Check pgbouncer service is ready	TAGS: [init-meta, pgbouncer_launch]
  pg_pgbouncer : Check pgbouncer connectivity	TAGS: [init-meta, pgbouncer_launch]
  pg_patroni : Install patroni from local yum	TAGS: [init-meta, patroni_install]
  pg_patroni : Disable existing patroni services	TAGS: [init-meta, patroni_cleanup]
  pg_patroni : Remove patroni consul metadata	TAGS: [init-meta, patroni_cleanup]
  pg_patroni : Copy patroni callback scripts	TAGS: [init-meta, patroni_setup]
  pg_patroni : Copy default /pg/conf/patroni.yml	TAGS: [init-meta, patroni_setup]
  pg_patroni : Link /pg/conf/patroni to /pg/bin/	TAGS: [init-meta, patroni_setup]
  pg_patroni : Copy patroni systemd service unit	TAGS: [init-meta, patroni_setup]
  pg_patroni : Launch patroni on primary instance	TAGS: [init-meta, patroni_setup]
  pg_patroni : Launch patroni on replica instances	TAGS: [init-meta, patroni_setup]
  pg_patroni : Wait for patroni service online	TAGS: [init-meta, patroni_setup]
  pg_proxy : Render /etc/haproxy/haproxy.cfg	TAGS: [init-meta, pg_haproxy]
  pg_proxy : Copy haproxy systemd service file	TAGS: [init-meta, pg_haproxy]
  pg_proxy : Increase pam ulimit for user haproxy	TAGS: [init-meta, pg_haproxy]
  pg_proxy : Launch haproxy on all instances	TAGS: [init-meta, pg_haproxy]
  pg_proxy : Wait for haproxy service online	TAGS: [init-meta, pg_haproxy]
  pg_monitor : Create /etc/pg_exporter conf dir	TAGS: [init-meta, pg_exporter]
  pg_monitor : Copy default pg_exporter.yaml	TAGS: [init-meta, pg_exporter]
  pg_monitor : Config /etc/default/pg_exporter	TAGS: [init-meta, pg_exporter]
  pg_monitor : Config pg_exporter service unit	TAGS: [init-meta, pg_exporter]
  pg_monitor : Launch pg_exporter systemd service	TAGS: [init-meta, pg_exporter]
  pg_monitor : Wait for pg_exporter service online	TAGS: [init-meta, pg_exporter]
  pg_monitor : Config pgbouncer_exporter opts	TAGS: [init-meta, pgbouncer_exporter]
  pg_monitor : Config pgbouncer_exporter service	TAGS: [init-meta, pgbouncer_exporter]
  pg_monitor : Launch pgbouncer_exporter service	TAGS: [init-meta, pgbouncer_exporter]
  pg_monitor : Wait for pgbouncer_exporter online	TAGS: [init-meta, pgbouncer_exporter]
  pg_monitor : Copy node_exporter systemd service	TAGS: [init-meta, node_exporter]
  pg_monitor : Config default node_exporter options	TAGS: [init-meta, node_exporter]
  pg_monitor : Launch node_exporter service unit	TAGS: [init-meta, node_exporter]
  pg_monitor : Wait for node_exporter online	TAGS: [init-meta, node_exporter]
  pg_monitor : Register postgres monitoring service	TAGS: [init-meta, pg_register]
  pg_monitor : Register patroni service if enabled	TAGS: [init-meta, pg_register]
  pg_monitor : Register load balancer service	TAGS: [init-meta, pg_register]
  pg_monitor : Restart consul to reload node-meta	TAGS: [init-meta, pg_register]
```


## Operations

```
make				# launch cluster
make new    # create a new pigsty cluster
make dns		# write pigsty dns record to your /etc/hosts (sudo required)
make ssh		# write ssh config to your ~/.ssh/config
make init		# init infrastructure and postgres cluster
make cache	# copy local yum repo packages to your pigsty/pkg
make clean	# delete current cluster
```



## Architecture

TBD


## Todo List

* haproxy improvement
* keepalived imporvement (haproxy health chekc / pg health check)
* metadb , remote catalog
* pg_exporter enhancement
* consul template or vip-manager 
* cloud native support 

## What's Next?

* Explore the monitoring system
* How service discovery works
* Add some load to cluster
* Managing postgres cluster with ansible
* High Available Drill




## About

Author：Vonng ([fengruohang@outlook.com](mailto:fengruohang@outlook.com))

](https://creativecommons.org/licenses/by-nc/4.0/)

