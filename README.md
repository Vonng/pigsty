# Pigsty -- PostgreSQL in Graphic Style

> PIGSTY: Postgres in Graphic STYle

This project provisioned a PostgreSQL cluster upon [vagrant](https://vagrantup.com/) with a battery-included monitoring system and HA setup.

[中文文档](README_CN.md)



## Highlight

* High-available PostgreSQL cluster with production grade quality.
* Offline installtaion mode without Internet access
* Intergreted monitoring alerting logging system
* Service discovery and metadata storage with dcs
* Performance tuning for different situations (OLTP, OLAP, CRIT, TINY)
* Infra as Code: declarative parameters, customizable templates, idempotent playbooks.



## Quick Start

1. Prepare nodes, pick one as meta nodes which have ssh nopass access to other nodes and sudo privileges.
2. Install ansible on meta nodes and clone this repo ([Offline installation guide]())
   
   ```bash
   git clone https://github.com/vonng/pigsty && cd pigsty 
   ```

3. Configure your infrastructure and defining you database clusters ([Configuration Guide]())

   ```bash
   group_vars/all.yml   # infrastructure definition, global variables
   cls/inventory.ini    # postgres cluster definition, node/cluster specific variables
   templates/           # provision template (pre-defined or user-provided)   
   ```


4. Run`infra.yml` on meta node to provision infrastructure. ([Infrastructure Parameters]())

   ```bash
   ./infra.yml          # setup infrastructure properly
   ```
   
5. Run`postgres.yml` on meta node to provision database cluster ([Postgres Cluster Parameters]())

   ```bash
   ./postgres.yml       # pull up all postgres clusters  
   ```



## Requirement

**Minimal setup**

* 1 Node, self-contained
* Meta node, and a one-node postgres instance `pg-meta`
* Minimal requirement: 2 CPU Core & 2 GB RAM

**Standard setup**

* 4 Node, including 1 meta node and 3 database node
* Two postgres cluster `pg-meta` and `pg-test` (1 primary, 2 replica)
* Meta node requirement: 2~4 CPU Core & 4 ~ 8 GB RAM
* DB node minimal requirement: 1 CPU Core & 1 GB RAM


## Vagrant Provision

If you wish to run pigsty on your laptop, consider using vagrant and virtualbox as vm provisioner

*  [`Vagrantfile`](vagrant/Vagrantfile) will provision 4 nodes (via [virtualbox](https://www.virtualbox.org/)) for this project.
* Install  [vagrant](https://vagrantup.com/), [virtualbox](https://www.virtualbox.org/) and [ansible](https://www.ansible.com/) before next step
* Make sure you have no-pass ssh access to these nodes from this machine, then:

```bash
make up     # alternative: cd vagrant && vagrant up
```

will pull up all four nodes



### Run

2. Clone this repo: `git clone https://github.com/vonng/pigsty && cd pigsty`
4. Pull up vagrant vm nodes: `make` 
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
> It may takes around 5m to download all packages (1GB). But with poor network condition (e.g. Mainland China), it may take around 30m or more. 
> Consider using a local [http proxy](group_vars/dev.yml), and don't forget to make a local cache via  `make cache` after bootstrap. 
>
>  [Grafana](http://grafana.pigsty) default credential: `user=admin pass=admin`, if required.



1. Setup your local dns: `sudo make dns` (one-time job)

   ```bash
   # add these lines to /etc/hosts
   10.10.10.10 pigsty yum.pigsty c.pigsty p.pigsty g.pigsty a.pigsty
   ```


## Inventory

Default inventory file are split into two files:

* common variables and default values are define in [group_vars/all.yml](group_vars/all.yml) using group variables (for group `all`) (example for vagrant [dev](group_vars/dev.yml) env) 

* Ad hoc variables are defined in [cls/inventory.ini](cls/inventory.ini) using host/group variables (example for vagrant [dev](cls/dev.ini) env)


## Playbooks



#### Infrastructure Provision

* [`infra.yml`](infra.yml) will bootstrap entire infrastructure on given inventory


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


#### Postgres Provision

* [`postgres.yml`](postgres.yml) will bootstrap PostgreSQL cluster according to inventory (assume infra provisioned)

```yaml
  play #1 (all): Init database cluster	TAGS: []
    tasks:
      postgres : Create os group postgres	TAGS: [instal, pg_dbsu, postgres]
      postgres : Make sure dcs group exists	TAGS: [instal, pg_dbsu, postgres]
      postgres : Create dbsu {{ pg_dbsu }}	TAGS: [instal, pg_dbsu, postgres]
      postgres : Grant dbsu nopass sudo	TAGS: [instal, pg_dbsu, postgres]
      postgres : Grant dbsu all sudo	TAGS: [instal, pg_dbsu, postgres]
      postgres : Grant dbsu limited sudo	TAGS: [instal, pg_dbsu, postgres]
      postgres : Config patroni watchdog support	TAGS: [instal, pg_dbsu, postgres]
      postgres : Add dbsu ssh no host checking	TAGS: [instal, pg_dbsu, postgres]
      postgres : Fetch dbsu public keys	TAGS: [instal, pg_dbsu, postgres]
      postgres : Exchange dbsu ssh keys	TAGS: [instal, pg_dbsu, postgres]
      postgres : Install offical pgdg yum repo	TAGS: [instal, pg_install, postgres]
      postgres : Install pg packages	TAGS: [instal, pg_install, postgres]
      postgres : Install pg extensions	TAGS: [instal, pg_install, postgres]
      postgres : Link /usr/pgsql to current version	TAGS: [instal, pg_install, postgres]
      postgres : Add pg bin dir to profile path	TAGS: [instal, pg_install, postgres]
      postgres : Fix directory ownership	TAGS: [instal, pg_install, postgres]
      postgres : Remove default postgres service	TAGS: [instal, pg_install, postgres]
      postgres : Check necessary variables exists	TAGS: [always, pg_preflight, postgres, preflight]
      postgres : Fetch variables via pg_cluster	TAGS: [always, pg_preflight, postgres, preflight]
      postgres : Set cluster basic facts for hosts	TAGS: [always, pg_preflight, postgres, preflight]
      postgres : Assert cluster primary singleton	TAGS: [always, pg_preflight, postgres, preflight]
      postgres : Setup cluster primary ip address	TAGS: [always, pg_preflight, postgres, preflight]
      postgres : Setup repl upstream for primary	TAGS: [always, pg_preflight, postgres, preflight]
      postgres : Setup repl upstream for replicas	TAGS: [always, pg_preflight, postgres, preflight]
      postgres : Debug print instance summary	TAGS: [always, pg_preflight, postgres, preflight]
      postgres : Check for existing postgres instance	TAGS: [pg_check, postgres, prepare]
      postgres : Set fact whether pg port is open	TAGS: [pg_check, postgres, prepare]
      postgres : Abort due to existing postgres instance	TAGS: [pg_check, postgres, prepare]
      postgres : Clean existing postgres instance	TAGS: [pg_check, postgres, prepare]
      postgres : Shutdown existing postgres service	TAGS: [pg_clean, postgres, prepare]
      postgres : Remove registerd consul service	TAGS: [pg_clean, postgres, prepare]
      postgres : Remove postgres metadata in consul	TAGS: [pg_clean, postgres, prepare]
      postgres : Remove existing postgres data	TAGS: [pg_clean, postgres, prepare]
      postgres : Make sure main and backup dir exists	TAGS: [pg_dir, postgres, prepare]
      postgres : Create postgres directory structure	TAGS: [pg_dir, postgres, prepare]
      postgres : Create pgbouncer directory structure	TAGS: [pg_dir, postgres, prepare]
      postgres : Create links from pgbkup to pgroot	TAGS: [pg_dir, postgres, prepare]
      postgres : Create links from current cluster	TAGS: [pg_dir, postgres, prepare]
      postgres : Copy postgres scripts to /pg/bin/	TAGS: [pg_scripts, postgres, prepare]
      postgres : Copy alias profile to /etc/profile.d	TAGS: [pg_scripts, postgres, prepare]
      postgres : Copy psqlrc to postgres home	TAGS: [pg_scripts, postgres, prepare]
      postgres : Setup hostname to pg instance name	TAGS: [pg_hostname, postgres, prepare]
      postgres : Copy consul node-meta definition	TAGS: [postgres, prepare]
      postgres : Restart consul to load new node-meta	TAGS: [postgres, prepare]
      postgres : Config patroni watchdog support	TAGS: [pg_watchdog, postgres, prepare]
      postgres : Get config parameter page count	TAGS: [pg_config, postgres]
      postgres : Get config parameter page size	TAGS: [pg_config, postgres]
      postgres : Tune shared buffer and work mem	TAGS: [pg_config, postgres]
      postgres : Hanlde small size mem occasion	TAGS: [pg_config, postgres]
      postgres : Calculate postgres mem params	TAGS: [pg_config, postgres]
      postgres : Render default initdb scripts	TAGS: [pg_config, postgres]
      postgres : create patroni config dir	TAGS: [pg_config, postgres]
      postgres : use predefined patroni template	TAGS: [pg_config, postgres]
      postgres : Render default /pg/conf/patroni.yml	TAGS: [pg_config, postgres]
      postgres : Link /pg/conf/patroni to /pg/bin/	TAGS: [pg_config, postgres]
      postgres : Link /pg/bin/patroni.yml to /etc/patroni/	TAGS: [pg_config, postgres]
      postgres : Config patroni watchdog support	TAGS: [pg_config, postgres]
      postgres : create patroni systemd drop-in dir	TAGS: [pg_config, postgres]
      postgres : Copy postgres systemd service file	TAGS: [pg_config, postgres]
      postgres : create patroni systemd drop-in file	TAGS: [pg_config, postgres]
      postgres : Launch patroni on primary instance	TAGS: [pg_primary, postgres]
      postgres : Wait for patroni primary online	TAGS: [pg_primary, postgres]
      postgres : Wait for postgres primary online	TAGS: [pg_primary, postgres]
      postgres : Check primary postgres service ready	TAGS: [pg_primary, postgres]
      postgres : Check replication connectivity to primary	TAGS: [pg_primary, postgres]
      postgres : Check replication connectivity to primary	TAGS: [pg_replica, postgres]
      postgres : Launch patroni on replica instances	TAGS: [pg_replica, postgres]
      postgres : Wait for patroni replica online	TAGS: [pg_replica, postgres]
      postgres : Wait for postgres replica online	TAGS: [pg_replica, postgres]
      postgres : Check replica postgres service ready	TAGS: [pg_replica, postgres]
      postgres : Pause patroni	TAGS: [pg_patroni, postgres]
      postgres : Stop patroni on replica instance	TAGS: [pg_patroni, postgres]
      postgres : Stop patroni on primary instance	TAGS: [pg_patroni, postgres]
      postgres : Launch raw postgres on primary	TAGS: [pg_patroni, postgres]
      postgres : Launch raw postgres on primary	TAGS: [pg_patroni, postgres]
      postgres : Wait for postgres online	TAGS: [pg_patroni, postgres]
      postgres : Check pgbouncer is installed	TAGS: [pgbouncer, pgbouncer_check, postgres]
      postgres : Stop existing pgbouncer service	TAGS: [pgbouncer, pgbouncer_cleanup, postgres]
      postgres : Remove existing pgbouncer dirs	TAGS: [pgbouncer, pgbouncer_cleanup, postgres]
      postgres : Recreate dirs with owner postgres	TAGS: [pgbouncer, pgbouncer_cleanup, postgres]
      postgres : Copy /etc/pgbouncer/pgbouncer.ini	TAGS: [pgbouncer, pgbouncer_config, postgres]
      postgres : Copy /etc/pgbouncer/pgb_hba.conf	TAGS: [pgbouncer, pgbouncer_config, postgres]
      postgres : Add system users to pgbouncer	TAGS: [pgbouncer, pgbouncer_config, postgres]
      postgres : Add default users to pgbouncer	TAGS: [pgbouncer, pgbouncer_config, postgres]
      postgres : Add default database to pgbouncer	TAGS: [pgbouncer, pgbouncer_config, postgres]
      postgres : Copy pgbouncer systemd service	TAGS: [pgbouncer, pgbouncer_launch, postgres]
      postgres : Launch pgbouncer pool service	TAGS: [pgbouncer, pgbouncer_launch, postgres]
      postgres : Wait for pgbouncer service online	TAGS: [pgbouncer, pgbouncer_launch, postgres]
      postgres : Check pgbouncer service is ready	TAGS: [pgbouncer, pgbouncer_launch, postgres]
      postgres : Check pgbouncer connectivity	TAGS: [pgbouncer, pgbouncer_launch, postgres]
      postgres : Copy postgres service definition	TAGS: [pg_register, postgres, register]
      postgres : Reload consul service	TAGS: [pg_register, postgres, register]
      postgres : Create grafana datasource postgres	TAGS: [pg_register, postgres, register]
      monitor : Create /etc/pg_exporter conf dir	TAGS: [monitor, pg_exporter]
      monitor : Copy default pg_exporter.yaml	TAGS: [monitor, pg_exporter]
      monitor : Config /etc/default/pg_exporter	TAGS: [monitor, pg_exporter]
      monitor : Config pg_exporter service unit	TAGS: [monitor, pg_exporter]
      monitor : Launch pg_exporter systemd service	TAGS: [monitor, pg_exporter]
      monitor : Wait for pg_exporter service online	TAGS: [monitor, pg_exporter]
      monitor : Register pg-exporter consul service	TAGS: [monitor, pg_exporter]
      monitor : Reload pg-exporter consul service	TAGS: [monitor, pg_exporter]
      monitor : Config pgbouncer_exporter opts	TAGS: [monitor, pgbouncer_exporter]
      monitor : Config pgbouncer_exporter service	TAGS: [monitor, pgbouncer_exporter]
      monitor : Launch pgbouncer_exporter service	TAGS: [monitor, pgbouncer_exporter]
      monitor : Wait for pgbouncer_exporter online	TAGS: [monitor, pgbouncer_exporter]
      monitor : Register pgb-exporter consul service	TAGS: [monitor, pgbouncer_exporter]
      monitor : Reload pgb-exporter consul service	TAGS: [monitor, pgbouncer_exporter]
      monitor : Copy node_exporter systemd service	TAGS: [monitor, node_exporter]
      monitor : Config default node_exporter options	TAGS: [monitor, node_exporter]
      monitor : Launch node_exporter service unit	TAGS: [monitor, node_exporter]
      monitor : Wait for node_exporter online	TAGS: [monitor, node_exporter]
      monitor : Register node-exporter service	TAGS: [monitor, node_exporter]
      monitor : Reload node-exporter consul service	TAGS: [monitor, node_exporter]
      proxy : Templating /etc/default/vip-manager.yml	TAGS: [proxy, vip]
      proxy : create vip-manager. systemd drop-in dir	TAGS: [proxy, vip]
      proxy : create vip-manager systemd drop-in file	TAGS: [proxy, vip]
      proxy : Launch vip-manager	TAGS: [proxy, vip]
      proxy : Set pg_instance in case of absence	TAGS: [haproxy, proxy]
      proxy : Fetch postgres cluster memberships	TAGS: [haproxy, proxy]
      proxy : Templating /etc/haproxyhaproxy.cfg	TAGS: [haproxy, proxy]
      proxy : Copy haproxy systemd service file	TAGS: [haproxy, proxy]
      proxy : Launch haproxy load balancer service	TAGS: [haproxy, proxy]
      proxy : Wait for haproxy load balancer online	TAGS: [haproxy, proxy]
      proxy : Copy haproxy service definition	TAGS: [haproxy_register, proxy]
      proxy : Reload haproxy consul service	TAGS: [haproxy_register, proxy]
```


### **Database Administration (TBD)**

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


## Operations

```
make		# launch cluster
make new    # create a new pigsty cluster
make dns	# write pigsty dns record to your /etc/hosts (sudo required)
make ssh	# write ssh config to your ~/.ssh/config
make init	# init infrastructure and postgres cluster
make cache	# copy local yum repo packages to your pigsty/pkg
make clean	# delete current cluster
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

License: (Apache Apache License Version 2.0)[LICENSE] 

