# Pigsty -- PostgreSQL Sandbox

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
```

> #### Note 
>
> It may takes 30m to download packages (1GB) . So don't forget to make a local cache via  `make cache` after bootstrap. It will copy all packages to  `your_host:pigsty/pkg`. If cache is already available in `pigsty/pkg`.  Pigsty will bootstrap from it much faster (30m to 5m). Reboot from existing cluster will only takes around 30 seconds.
>
>  [Grafana](http://grafana.pigsty) default credential: `user=admin pass=admin`, if required.


## Play

[ansible/init.yml](ansible/init.yml) contains init scripts for pigsty cluster, which execute following tasks:

```bash
playbook: ./init.yml

  play #1 (meta): Init Local Yum Repo	TAGS: [repo]
    tasks:
      repo_bootstrap : Create pigsty repo directory	TAGS: [pigsty_repo_precheck, repo]
      repo_bootstrap : Check pigsty repo cache exists	TAGS: [pigsty_repo_precheck, repo]
      repo_bootstrap : Check pigsty boot cache exists	TAGS: [pigsty_repo_precheck, repo]
      repo_bootstrap : Install centos yum repos	TAGS: [pigsty_repo_download, repo]
      repo_bootstrap : Install nginx yum repo	TAGS: [pigsty_repo_download, repo]
      repo_bootstrap : Download bootstrap packages	TAGS: [pigsty_repo_download, repo]
      repo_bootstrap : Download packages complete	TAGS: [pigsty_repo_download, repo]
      repo_bootstrap : Install bootstrap packages	TAGS: [pigsty_repo_install, repo]
      repo_bootstrap : Copy nginx conf	TAGS: [pigsty_nginx_setup, repo]
      repo_bootstrap : Copy nginx content	TAGS: [pigsty_nginx_setup, repo]
      repo_bootstrap : Launch nginx service	TAGS: [pigsty_nginx_setup, repo]
      repo_bootstrap : Waits nginx online	TAGS: [pigsty_nginx_setup, repo]
      repo_download : Create pigsty repo directory	TAGS: [pigsty_repo_precheck, repo]
      repo_download : Check pigsty repo cache exists	TAGS: [pigsty_repo_precheck, repo]
      repo_download : Install centos yum repos	TAGS: [pigsty_package_download, repo]
      repo_download : Install additional yum repos	TAGS: [pigsty_package_download, repo]
      repo_download : Download packages from yum repo	TAGS: [pigsty_package_download, repo]
      repo_download : Download packages from web	TAGS: [pigsty_package_download, repo]
      repo_download : Download cloud native packages	TAGS: [pigsty_package_download, repo]
      repo_download : Download build essential packages	TAGS: [pigsty_package_download, repo]
      repo_download : Create yum repo index	TAGS: [pigsty_package_download, repo]
      repo_download : Build local yum repo complete	TAGS: [pigsty_package_download, repo]

  play #2 (all): Init Infrastructure	TAGS: [node]
    tasks:
      repo_install : Download pigsty yum repo	TAGS: [node, pigsty_repo_install]
      repo_install : Configure using local yum if exists	TAGS: [node, pigsty_repo_install]
      node_user : Create os group postgres	TAGS: [node, node_user_create]
      node_user : Create os user postgres	TAGS: [node, node_user_create]
      node_user : Create os user prometheus	TAGS: [node, node_user_create]
      node_user : Create os user consul	TAGS: [node, node_user_create]
      node_user : Create os user etcd	TAGS: [node, node_user_create]
      node_user : Copy os user profile	TAGS: [node, node_user_create]
      node_pkgs : Install node packages	TAGS: [node, node_pkgs_install]
      node_pkgs : Install node build packages	TAGS: [node, node_build_pkgs_install]
      node_pkgs : Install node cloud native packages	TAGS: [node, node_cloud_pkgs_install]
      node_dns : Add dns hosts	TAGS: [node, node_dns_etc_hosts]
      node_dns : Add dns resolver	TAGS: [node, node_dns_etc_hosts]
      node_ntp : Install chrony package	TAGS: [node, ntp_centos]
      node_ntp : Copy the chrony.conf template file	TAGS: [node, ntp_centos]
      node_ntp : Restart chronyd service	TAGS: [node, ntp_centos]
      node_ntp : Set timezone and synctime	TAGS: [node, ntp_centos]
      node_ntp : Install ntp package	TAGS: [node, ntp_debian, ntp_install]
      node_ntp : Copy the ntp.conf file	TAGS: [node, ntp_config, ntp_debian]
      node_ntp : Restart ntp service	TAGS: [node, ntp_debian]
      node_tune : Disable transparent hugepage	TAGS: [disable_thp, node, node_tune]
      node_tune : Setup disk prefetch	TAGS: [disk_prefetch, node, node_tune]
      node_tune : Disable Numa	TAGS: [disable_numa, node, node_tune]
      node_tune : Setup RAID	TAGS: [node, node_tune, setup_raid]
      node_sysctl : Get cpu core count	TAGS: [node]
      node_sysctl : Get memory size	TAGS: [node]
      node_sysctl : Get swap size	TAGS: [node]
      node_sysctl : Calculate parameters	TAGS: [node]
      node_sysctl : Set sysctl parameters	TAGS: [node]
      node_consul : Stop existing consul	TAGS: [consul, node]
      node_consul : Copy consul server service unit	TAGS: [consul, node]
      node_consul : Copy consul service unit	TAGS: [consul, node]
      node_consul : Remove existing consul directory	TAGS: [consul, node]
      node_consul : Recreate consul conf dir	TAGS: [consul, node]
      node_consul : Recreate consul data dir	TAGS: [consul, node]
      node_consul : Copy consul main config	TAGS: [consul, node]
      node_consul : Launch consul service	TAGS: [consul, node]
      node_exporter : Copy node_exporter service unit	TAGS: [node, node_exporter]
      node_exporter : Config node_exporter	TAGS: [node, node_exporter]
      node_exporter : Launch node_exporter service	TAGS: [node, node_exporter]
      node_exporter : Waits node_exporter online	TAGS: [node, node_exporter]

  play #3 (meta): Init Meta Node	TAGS: [meta]
    tasks:
      meta_pkgs : Install meta node packages	TAGS: [meta, meta_node_pkgs_install]
      meta_pkgs : Install meta node build packages	TAGS: [meta, meta_node_build_pkgs_install]
      meta_nginx : Copy nginx conf	TAGS: [meta, nginx_setup]
      meta_nginx : Restart nginx service	TAGS: [meta, nginx_setup]
      meta_nginx : Config nginx_exporter opts	TAGS: [meta, nginx_setup]
      meta_nginx : Restart nginx service	TAGS: [meta, nginx_setup]
      meta_nginx : Copy consul services definition	TAGS: [meta, nginx_setup]
      meta_nginx : Reload consul service	TAGS: [meta, nginx_setup]
      meta_dnsmasq : Copy dnsmasq config	TAGS: [dnsmasq_setup, meta]
      meta_dnsmasq : Copy dnsmasq hosts	TAGS: [dnsmasq_setup, meta]
      meta_dnsmasq : Launch dnsmasq service	TAGS: [dnsmasq_setup, meta]
      meta_dnsmasq : Wait dnsmasq online	TAGS: [dnsmasq_setup, meta]
      meta_dnsmasq : Copy consul services definition	TAGS: [dnsmasq_setup, meta, meta_register_nginx_service]
      meta_dnsmasq : Reload consul	TAGS: [dnsmasq_setup, meta]
      meta_prometheus : Wipe out prometheus config	TAGS: [meta, prometheus_setup]
      meta_prometheus : Wipe out prometheus data	TAGS: [meta, prometheus_setup]
      meta_prometheus : Recreate prometheus data dir	TAGS: [meta, prometheus_setup]
      meta_prometheus : Copy prometheus configs	TAGS: [meta, prometheus_setup]
      meta_prometheus : Launch prometheus service	TAGS: [meta, prometheus_setup]
      meta_prometheus : Launch alertmanager service	TAGS: [meta, prometheus_setup]
      meta_prometheus : Wait prometheus online	TAGS: [meta, prometheus_setup]
      meta_prometheus : Wait alertmanager online	TAGS: [meta, prometheus_setup]
      meta_prometheus : Copy prometheus consul services definition	TAGS: [meta, prometheus_setup]
      meta_prometheus : Reload consul service	TAGS: [meta, prometheus_setup]
      meta_grafana : Copy grafana configs	TAGS: [grafana_setup, meta]
      meta_grafana : Provision grafana via grafana.db	TAGS: [grafana_setup, meta]
      meta_grafana : Provision grafana datasources	TAGS: [grafana_setup, meta]
      meta_grafana : Provision grafana dashboards	TAGS: [grafana_setup, meta]
      meta_grafana : Launch grafana service	TAGS: [grafana_setup, meta]
      meta_grafana : Wait grafana online	TAGS: [grafana_setup, meta]
      meta_grafana : Copy grafana consul services definition	TAGS: [grafana_setup, meta]
      meta_grafana : Reload consul service	TAGS: [grafana_setup, meta]
      meta_grafana : Check grafana cache exists	TAGS: [meta, meta_grafana_plugin_setup]
      meta_grafana : Provision grafana plugins	TAGS: [meta, meta_grafana_plugin_setup]
      meta_grafana : Download grafana plugins if not exists	TAGS: [meta, meta_grafana_plugin_setup]
      meta_grafana : Restart grafana service	TAGS: [meta, meta_grafana_plugin_setup]

  play #4 (test): Init PostgreSQL Cluster	TAGS: [pg-test]
    tasks:
      pg_dbsu : Create os group postgres	TAGS: [dbsu_create, pg-test]
      pg_dbsu : Create os user postgres	TAGS: [dbsu_create, pg-test]
      pg_dbsu : Add ssh config	TAGS: [dbsu_key_exchange, pg-test]
      pg_dbsu : Fetch all public key	TAGS: [dbsu_key_exchange, pg-test]
      pg_dbsu : Check all public key	TAGS: [dbsu_key_exchange, pg-test]
      pg_dbsu : Copy ssh key to authorized hosts	TAGS: [dbsu_key_exchange, pg-test]
      pg_dbsu : Fetch all public key	TAGS: [dbsu_key_exchange, pg-test]
      pg_dbsu : Allow postgres systemctl nopass sudo	TAGS: [dbsu_sudo_setup, pg-test]
      pg_dbsu : Setup dbsu pam limit	TAGS: [dbsu_limit_setup, pg-test]
      pg_dir : Create postgres directories	TAGS: [pg-test, pg_dir_create]
      pg_dir : Create links between pgroot and pgbkup	TAGS: [pg-test, pg_dir_create]
      pg_install : Install pgdg	TAGS: [pg-test, pg_install, setup_pgdg]
      pg_install : Enlisting postgres packages	TAGS: [pg-test, pg_install]
      pg_install : Enlisting postgis packages	TAGS: [pg-test, pg_install]
      pg_install : Enlisting extension packages	TAGS: [pg-test, pg_install]
      pg_install : Print postgres packages	TAGS: [pg-test, pg_install]
      pg_install : Install postgres {{ version }} package list	TAGS: [pg-test, pg_install]
      pg_install : Make /usr/pgsql link	TAGS: [pg-test, pg_install]
      pg_install : Add /usr/ppgsql to path	TAGS: [pg-test, pg_install]
      pg_install : Check pgsql version	TAGS: [pg-test, pg_install]
      pg_install : Copy postgres systemd service file	TAGS: [pg-test, pg_install]
      pg_install : Prepare postgres service	TAGS: [pg-test, pg_install]
      pg_precheck : Check cluster role seq defined in inventory	TAGS: [pg-test, pg_inventory_check]
      pg_precheck : Set instance name	TAGS: [pg-test, pg_inventory_check]
      pg_precheck : Calculate fact according to inventory	TAGS: [pg-test, pg_inventory_check]
      pg_precheck : Check hosts all belong to same cluster	TAGS: [pg-test, pg_inventory_check]
      pg_precheck : Check cluster only have one primary	TAGS: [pg-test, pg_inventory_check]
      pg_precheck : Set replication source for standby	TAGS: [pg-test, pg_inventory_check]
      pg_precheck : Group by	TAGS: [pg-test]
      pg_primary : Check primary pg version {{ version }}	TAGS: [pg-test, pg_primary_check]
      pg_primary : Check primary not running (set force=on to skip)	TAGS: [pg-test, pg_primary_check]
      pg_primary : Set default postgres conf path	TAGS: [pg-test, pg_primary_check]
      pg_primary : Stop running postgres service	TAGS: [pg-test, pg_primary_clean]
      pg_primary : Stop running postgres manully if still exist	TAGS: [pg-test, pg_primary_clean]
      pg_primary : Remove existing /pg/data directory	TAGS: [pg-test, pg_primary_clean]
      pg_primary : Recreate /pg/data directory	TAGS: [pg-test, pg_primary_clean]
      pg_primary : Init database cluster {{ cluster }} with version={{ version }}	TAGS: [pg-test, pg_primary_init]
      pg_primary : Copy primary postgresql.conf of version {{ version }}	TAGS: [pg-test, pg_primary_config]
      pg_primary : Copy primary pg_hba.conf	TAGS: [pg-test, pg_primary_config]
      pg_primary : Start postgres service	TAGS: [pg-test, pg_primary_launch]
      pg_primary : Waits postgres listen on port	TAGS: [pg-test, pg_primary_launch]
      pg_primary : Check postgres is ready	TAGS: [pg-test, pg_primary_launch]
      pg_primary : Create replicator user	TAGS: [pg-test, primary_bootstrap]
      pg_primary : Grant function usage to replicator	TAGS: [pg-test, primary_bootstrap]
      pg_primary : Create monitor user	TAGS: [pg-test, primary_bootstrap]
      pg_primary : Grant pg_monitor to dbuser_monitor	TAGS: [pg-test, primary_bootstrap]
      pg_primary : Create pgpass contains replicator info	TAGS: [pg-test, primary_bootstrap]
      pg_primary : Check replicator connectivity	TAGS: [pg-test, primary_bootstrap]
      pg_primary : Create default role readonly/readwrite	TAGS: [pg-test, primary_bootstrap]
      pg_primary : Create admin role	TAGS: [pg-test, primary_bootstrap]
      pg_primary : Grant readonly to readwrite and monitor	TAGS: [pg-test, primary_bootstrap]
      pg_primary : Grant readwrite to admin	TAGS: [pg-test, primary_bootstrap]
      pg_primary : Grant admin to postgres	TAGS: [pg-test, primary_bootstrap]
      pg_primary : Alter default privileges	TAGS: [pg-test, primary_bootstrap]
      pg_primary : Create default user	TAGS: [pg-test, primary_default_creation]
      pg_primary : Grant admin role to default user	TAGS: [pg-test, primary_default_creation]
      pg_primary : Create default database	TAGS: [pg-test, primary_default_creation]
      pg_primary : Create pgpass contains replicator info	TAGS: [pg-test, primary_default_creation]
      pg_primary : Check business user / db connectivity	TAGS: [pg-test, primary_default_creation]
      pg_standby : Check replica pg version {{ version }}	TAGS: [always, pg-test, pg_replica_check]
      pg_standby : Check replica not running (set force=on to skip)	TAGS: [always, pg-test, pg_replica_check]
      pg_standby : Set replica facts	TAGS: [always, pg-test, pg_replica_check]
      pg_standby : Stop running postgres replica	TAGS: [pg-test, pg_replica_clean]
      pg_standby : Stop running postgres replica manull	TAGS: [pg-test, pg_replica_clean]
      pg_standby : Remove existing /pg/data directory	TAGS: [pg-test, pg_replica_clean]
      pg_standby : Recreate /pg/data directory	TAGS: [pg-test, pg_replica_clean]
      pg_standby : Write pgpass according to default setting	TAGS: [pg-test, pg_replica_init]
      pg_standby : Create pgpass contains replicator info	TAGS: [pg-test, pg_replica_init]
      pg_standby : Check replica connectivity to upstream	TAGS: [pg-test, pg_replica_init]
      pg_standby : Create basebackup from primary	TAGS: [pg-test, pg_replica_init]
      pg_standby : Copy replica postgresql.conf of version {{ version }}	TAGS: [pg-test, pg_replica_config]
      pg_standby : Copy replica pg_hba.conf if provided	TAGS: [pg-test, pg_replica_config]
      pg_standby : Setup replica replication source	TAGS: [config_replica, pg-test, pg_replica_config]
      pg_standby : Start postgres service	TAGS: [pg-test, pg_primary_launch]
      pg_standby : Waits postgres listen on port	TAGS: [pg-test, pg_primary_launch]
      pg_standby : Check postgres is ready	TAGS: [pg-test, pg_primary_launch]
      pg_pgbouncer : Check pgbouncer installed	TAGS: [pg-test, pgbouncer_check]
      pg_pgbouncer : Stop running pgbouncer service	TAGS: [pg-test, pgbouncer_cleanup]
      pg_pgbouncer : Remove existing pgbouncer directories	TAGS: [pg-test, pgbouncer_cleanup]
      pg_pgbouncer : Recreate pgbouncer directories with user postgres	TAGS: [pg-test, pgbouncer_cleanup]
      pg_pgbouncer : Copy pgbouncer.ini	TAGS: [config_pgbouncer, pg-test]
      pg_pgbouncer : Copy pgb_hba.conf	TAGS: [config_pgbouncer, pg-test]
      pg_pgbouncer : Generate userlist.txt	TAGS: [config_pgbouncer, pg-test]
      pg_pgbouncer : Generate pgbouncer systemd definition	TAGS: [config_pgbouncer, pg-test]
      pg_pgbouncer : Launch pgbouncer service	TAGS: [launch_pgbouncer, pg-test]
      pg_pgbouncer : Waits pgbouncer listen on port	TAGS: [launch_pgbouncer, pg-test]
      pg_pgbouncer : Check pgbouncer is ready	TAGS: [launch_pgbouncer, pg-test]
      pg_pgbouncer : Check pgbouncer bizdb accessibility	TAGS: [launch_pgbouncer, pg-test]
      pg_monitor : Create /etc/pg_exporter conf dir	TAGS: [pg-test, pg_exporter_setup]
      pg_monitor : Config pg_exporter with /etc/pg_exporter/pg_exporter.yaml	TAGS: [pg-test, pg_exporter_setup]
      pg_monitor : Config pg_exporter opts	TAGS: [pg-test, pg_exporter_setup]
      pg_monitor : Config pg_exporter service unit	TAGS: [pg-test, pg_exporter_setup]
      pg_monitor : Launch pg_exporter service	TAGS: [pg-test, pg_exporter_setup]
      pg_monitor : Wait pg_exporter online	TAGS: [pg-test, pg_exporter_setup]
      pg_monitor : Config pgbouncer_exporter opts	TAGS: [pg-test, pgbouncer_exporter_setup]
      pg_monitor : Config pgbouncer_exporter service unit	TAGS: [pg-test, pgbouncer_exporter_setup]
      pg_monitor : Launch pgbouncer_exporter service	TAGS: [pg-test, pgbouncer_exporter_setup]
      pg_monitor : Wait pgbouncer_exporter online	TAGS: [pg-test, pgbouncer_exporter_setup]
      pg_monitor : Register monitoring service	TAGS: [pg-test, pg_monitor_service_register]
      pg_monitor : Restart consul	TAGS: [pg-test, restart_consul]
```


## Operations

```
make			# launch cluster
make dns		# write pigsty dns record to your /etc/hosts (sudo required)
make cache		# copy local yum repo packages to your pigsty/pkg
make init		# init infrastructure and postgres cluster
make clean		# delete current cluster
make start		# launch cluster
make ssh		# write ssh config to your ~/.ssh/config
make st			# show vagrant cluster status
```



## Architecture

TBD



## What's Next?

* Explore the monitoring system
* How service discovery works
* Add some load to cluster
* Managing postgres cluster with ansible
* High Available Drill




## About

Author：Vonng ([fengruohang@outlook.com](mailto:fengruohang@outlook.com))

LICENSE: [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/)