# Pigsty -- PostgreSQL in Graphic Style

> PIGSTY: Postgres in Graphic STYle

This project provisioned a PostgreSQL cluster upon [vagrant](https://vagrantup.com/) with a battery-included monitoring system and minimal HA setup.



## Features

* High Availability
* Offline installtaion without network
* Monitoring/Alerting/Logging System
* Service Discovery with dcs
* Performance tuning for bare metal
* Util scripts
* Cloud native deployment (TBD)



## Quick Start

### Requirement

**Minimal setup**

  * 1 Node only, self-contained
* Meta node, and a one-node postgres instance `pg-meta`
* Minimal requirement: 2 CPU Core & 2 GB RAM

**Standard setup**

* 4 Node, including 1 meta node and 3 database node
* Two postgres cluster `pg-meta` and `pg-test` (1 primary, 2 replica)

* Meta node requirement: 2~4 CPU Core & 4 ~ 8 GB RAM
* DB node minimal requirement: 1 CPU Core & 1 GB RAM

**VM Provision**

*  [`Vagrantfile`](vagrant/Vagrantfile) will provision 4 nodes (via [virtualbox](https://www.virtualbox.org/)) for this project.
* Install  [vagrant](https://vagrantup.com/), [virtualbox](https://www.virtualbox.org/) and [ansible](https://www.ansible.com/) before next step
* Make sure you have no-pass ssh access to these nodes from this machine



### Run

2. Clone this repo: `git clone https://github.com/vonng/pigsty && cd pigsty`

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


* [`infra.yml`](infra.yml) will bootstrap entire infrastructure on given inventory

* [`initdb.yml`](initdb.yml) will bootstrap PostgreSQL cluster according to inventory (assume infra provisioned)


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
    node : Stop network manager	TAGS: [node, node_resolv]
    node : Find all network interface	TAGS: [node, node_network]
    node : Add peerdns=no to ifcfg	TAGS: [node, node_network]
    node : Backup existing repos	TAGS: [node, node_repo]
    node : Install local yum repo	TAGS: [node, node_repo]
    node : Install upstream repo	TAGS: [node, node_repo]
    node : Config using local repo	TAGS: [node, node_repo]
    node : Run yum config manager command	TAGS: [node, node_repo]
    node : Install node basic packages	TAGS: [node, node_pkgs]
    node : Install node extra packages	TAGS: [node, node_pkgs]
    node : Install meta specific packages	TAGS: [node, node_pkgs]
    node : Node configure disable numa	TAGS: [node, node_feature]
    node : Node configure disable swap	TAGS: [node, node_feature]
    node : Node configure unmount swap	TAGS: [node, node_feature]
    node : Node configure disable firewall	TAGS: [node, node_feature]
    node : Node disable selinux by default	TAGS: [node, node_feature]
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
    node : Setup default node timezone	TAGS: [node, node_ntp]
    node : Copy the chrony.conf template	TAGS: [node, node_ntp]
    node : Launch chronyd ntpd service	TAGS: [node, node_ntp]

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

