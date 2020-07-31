# Pigsty —— 图形化PostgreSQL环境

> PIGSTY: Postgres in Graphic STYle （图形化PostgreSQL环境）

本项目为图形化PostgreSQL的演示项目，用于初始化高可用PG集群，并带有自包含的监控系统。
本项目可以直接用于开发、测试、生产环境，针对本地开发，提供了基于[vagrant](https://vagrantup.com/)的沙箱环境（四虚机节点）



## 功能简介

* High Availability
* Monitoring/Alerting/Logging System
* Service Discovery with dcs
* Performance tuning for bare metal
* Util scripts
* Cloud native deployment (TBD)



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
> It may takes around 5m to download all packages (1GB). But with poor network condition (e.g. Mainland China), it may take around 30m or more. 
> Consider using a local [http proxy](group_vars/dev.yml), and don't forget to make a local cache via  `make cache` after bootstrap. 
>
>  [Grafana](http://grafana.pigsty) default credential: `user=admin pass=admin`, if required.



## Inventory

Default inventory file are split into two files:

* common variables and default values are define in [group_vars/all.yml](group_vars/all.yml) using group variables (for group `all`) (example for vagrant [dev](group_vars/dev.yml) env) 

* Ad hoc variables are defined in [cls/inventory.ini](cls/inventory.ini) using host/group variables (example for vagrant [dev](cls/dev.ini) env)


## Playbooks


* [`infra.yml`](infra.yml) will bootstrap entire infrastructure on given inventory

* [`initdb.yml`](initdb.yml) will bootstrap a PostgreSQL cluster according to your inventory (infrastructure should be initialized before initdb)



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

Take `init-meta.yml` for example, here are tasks executed by this playbook 

```bash
playbook: ./infra.yml

  play #1 (meta): Init local repo							TAGS: [repo]
    tasks:
      repo : Create local repo directory					TAGS: [repo_dir]
      repo : Check repo boot cache exists					TAGS: [repo_boot]
      repo : Check repo cache exists						TAGS: [repo_download]
      repo : Remove existing repos							TAGS: [repo_upstream]
      repo : Add upstream repos								TAGS: [repo_upstream]
      repo : Remake yum cache if cache not exists			TAGS: [repo_upstream]
      repo : Disable upstream yum repo if cache exists		TAGS: [repo_upstream]
      repo : Download repo boot packages					TAGS: [repo_boot]
      repo : Install bootstrap packages						TAGS: [repo_boot]
      repo : Render repo nginx files						TAGS: [repo_boot]
      repo : Disable selinux								TAGS: [repo_boot]
      repo : Start repo nginx server						TAGS: [repo_boot]
      repo : Waits repo server online						TAGS: [repo_boot]
      repo : Mark bootstrap cache valid						TAGS: [repo_boot]
      repo : Download repo packages							TAGS: [repo_download]
      repo : Download additional url packages				TAGS: [repo_download]
      repo : Create local yum repo index					TAGS: [repo_download]
      repo : Mark repo cache valid							TAGS: [repo_download]

  play #2 (all): Provision Node								TAGS: [node]
    tasks:
      node : Write static dns record to node				TAGS: [node_dns]
      node : Get old nameservers							TAGS: [node_resolv]
      node : Truncate resolv file							TAGS: [node_resolv]
      node : Write resolv options							TAGS: [node_resolv]
      node : Add nameservers								TAGS: [node_resolv]
      node : Append old nameservers if needed				TAGS: [node_resolv]
      node : Stop network manager							TAGS: [node_resolv]
      node : Find all network interface						TAGS: [node_network]
      node : Add peerdns=no to ifcfg						TAGS: [node_network]
      node : Backup existing repos							TAGS: [node_repo]
      node : Install local yum repo							TAGS: [node_repo]
      node : Install upstream repo							TAGS: [node_repo]
      node : Config using local repo						TAGS: [node_repo]
      node : Run yum config manager command					TAGS: [node_repo]
      node : Install node basic packages					TAGS: [node_pkgs]
      node : Install node extra packages					TAGS: [node_pkgs]
      node : Install node meta packages						TAGS: [node_pkgs]
      node : Node configure disable numa					TAGS: [node_feature]
      node : Node configure disable swap					TAGS: [node_feature]
      node : Node configure unmount swap					TAGS: [node_feature]
      node : Node configure disable firewall				TAGS: [node_feature]
      node : Node disable selinux by default				TAGS: [node_feature]
      node : Node configure disk prefetch					TAGS: [node_feature]
      node : Enable kernel modules							TAGS: [node_kernel]
      node : Enable kernel module on reboot					TAGS: [node_kernel]
      node : Get config parameter page count				TAGS: [node_tuned]
      node : Get config parameter page size					TAGS: [node_tuned]
      node : Tune shmmax and shmall via mem					TAGS: [node_tuned]
      node : Create tuned profile postgres					TAGS: [node_tuned]
      node : Render tuned profile postgres					TAGS: [node_tuned]
      node : Active tuned profile postgres					TAGS: [node_tuned]
      node : Change additional sysctl params				TAGS: [node_tuned]
      node : Copy default user bash profile					TAGS: [node_profile]
      node : Setup node default pam ulimits					TAGS: [node_ulimit]
      node : Create os group admin							TAGS: [node_admin]
      node : Create os user admin							TAGS: [node_admin]
      node : Grant admin group nopass sudo					TAGS: [node_admin]
      node : Add no host checking to ssh config				TAGS: [node_admin]
      node : Add ssh no host checking						TAGS: [node_admin]
      node : Fetch admin public keys						TAGS: [node_admin]
      node : Exchange admin ssh keys						TAGS: [node_admin]
      node : Setup default node timezone					TAGS: [node_ntp]
      node : Copy the chrony.conf template					TAGS: [node_ntp]
      node : Launch chronyd ntpd service					TAGS: [node_ntp]

  play #3 (all): Init dcs									TAGS: [dcs]
    tasks:
      include_tasks											TAGS: [dcs]
      include_tasks											TAGS: [dcs, dcs_etcd]

  play #4 (meta): Init meta service							TAGS: [meta]
    tasks:
      nginx : Make sure nginx package installed				TAGS: [nginx]
      nginx : Copy nginx default config						TAGS: [nginx]
      nginx : Copy nginx upstream conf						TAGS: [nginx]
      nginx : Create local html directory					TAGS: [nginx]
      nginx : Update default nginx index page				TAGS: [nginx]
      nginx : Restart meta nginx service					TAGS: [nginx]
      nginx : Wait for nginx service online					TAGS: [nginx]
      nginx : Make sure nginx exporter installed			TAGS: [nginx_exporter]
      nginx : Config nginx_exporter options					TAGS: [nginx_exporter]
      nginx : Restart nginx_exporter service				TAGS: [nginx_exporter]
      nginx : Wait for nginx exporter online				TAGS: [nginx_exporter]
      nginx : Register cosnul nginx service					TAGS: [nginx_register]
      nginx : Register consul nginx-exporter service		TAGS: [nginx_register]
      nginx : Reload consul									TAGS: [nginx_register]
      nameserver : Make sure dnsmasq package installed		TAGS: [dnsmasq]
      nameserver : Copy dnsmasq /etc/dnsmasq.d/config		TAGS: [dnsmasq]
      nameserver : Add dynamic dns records to meta			TAGS: [dnsmasq]
      nameserver : Launch meta dnsmasq service				TAGS: [dnsmasq]
      nameserver : Wait for meta dnsmasq online				TAGS: [dnsmasq]
      nameserver : Register consul dnsmasq service			TAGS: [dnsmasq]
      nameserver : Reload consul							TAGS: [dnsmasq]
      prometheus : Install prometheus and alertmanager		TAGS: [prometheus_install]
      prometheus : Wipe out prometheus config dir			TAGS: [prometheus_clean]
      prometheus : Wipe out existing prometheus data		TAGS: [prometheus_clean]
      prometheus : Recreate prometheus data dir				TAGS: [prometheus_config]
      prometheus : Copy /etc/prometheus configs				TAGS: [prometheus_config]
      prometheus : Copy /etc/prometheus opts				TAGS: [prometheus_config]
      prometheus : Overwrite prometheus scrape_interval		TAGS: [prometheus_config]
      prometheus : Overwrite prometheus evaluation_interval	TAGS: [prometheus_config]
      prometheus : Overwrite prometheus scrape_timeout		TAGS: [prometheus_config]
      prometheus : Overwrite prometheus pg metrics path		TAGS: [prometheus_config]
      prometheus : Launch prometheus service				TAGS: [prometheus_launch]
      prometheus : Launch alertmanager service				TAGS: [prometheus_launch]
      prometheus : Wait for prometheus online				TAGS: [prometheus_launch]
      prometheus : Wait for alertmanager online				TAGS: [prometheus_launch]
      prometheus : Copy prometheus service definition		TAGS: [prometheus_register]
      prometheus : Copy alertmanager service definition		TAGS: [prometheus_register]
      prometheus : Reload consul to register prometheus		TAGS: [prometheus_register]
      grafana : Make sure grafana is installed				TAGS: [grafana_install]
      grafana : Check grafana plugin cache exists			TAGS: [grafana_install]
      grafana : Provision grafana plugin via cache			TAGS: [grafana_install]
      grafana : Download grafana plugins from web			TAGS: [grafana_install]
      grafana : Create grafana plugins cache				TAGS: [grafana_install]
      grafana : Copy /etc/grafana/grafana.ini				TAGS: [grafana_install]
      grafana : Launch grafana service						TAGS: [grafana_install]
      grafana : Wait for grafana online						TAGS: [grafana_install]
      grafana : Register consul grafana service				TAGS: [grafana_install]
      grafana : Reload consul								TAGS: [grafana_install]
      grafana : Launch meta grafana service					TAGS: [grafana_provision]
      grafana : Copy grafana.db to data dir					TAGS: [grafana_provision]
      grafana : Restart meta grafana service				TAGS: [grafana_provision]
      grafana : Wait for meta grafana online				TAGS: [grafana_provision]
      grafana : Remove grafana dashboard dir				TAGS: [grafana_provision]
      grafana : Copy grafana dashboards json				TAGS: [grafana_provision]
      grafana : Preprocess grafana dashboards				TAGS: [grafana_provision]
      grafana : Provision prometheus datasource				TAGS: [grafana_provision]
      grafana : Provision grafana dashboards				TAGS: [grafana_provision]
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

