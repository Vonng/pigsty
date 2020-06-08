# Pigsty -- PostgreSQL in Graph

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



## Playbook

[ansible/init.yml](ansible/init.yml) contains init scripts for pigsty cluster, which execute following tasks:

[`playbook: ./infra.yml`](ansible/infra.yml) contains infrastructure init tasks, list as below:

```bash
  play #1 (meta): Init Repo	TAGS: [repo]
    tasks:
      repo : Create local repo directory	TAGS: [repo, repo_precheck]
      repo : Check pigsty repo cache exists	TAGS: [repo, repo_precheck]
      repo : Check pigsty boot cache exists	TAGS: [repo, repo_precheck]
      repo : Enable default centos yum repos	TAGS: [repo, repo_bootstrap]
      repo : Install official centos yum repos	TAGS: [repo, repo_bootstrap]
      repo : Install additional nginx yum repo	TAGS: [repo, repo_bootstrap]
      repo : Download bootstrap packages	TAGS: [repo, repo_bootstrap]
      repo : Bootstrap packages downloaded	TAGS: [repo, repo_bootstrap]
      repo : Install bootstrap packages (nginx)	TAGS: [repo, repo_nginx]
      repo : Copy default nginx server config	TAGS: [repo, repo_nginx]
      repo : Copy default nginx index page	TAGS: [repo, repo_nginx]
      repo : Copy nginx pigsty repo files	TAGS: [repo, repo_nginx]
      repo : Start nginx service to serve repo	TAGS: [repo, repo_nginx]
      repo : Waits yum repo nginx online	TAGS: [repo, repo_nginx]
      repo : Install default centos yum repos	TAGS: [repo, repo_download]
      repo : Enable default centos yum repos	TAGS: [repo, repo_download]
      repo : Install additional yum repos	TAGS: [repo, repo_download]
      repo : Download build essential packages	TAGS: [repo, repo_download]
      repo : Download build essential packages	TAGS: [repo, repo_download]
      repo : Print packages to be downloaded	TAGS: [repo, repo_download]
      repo : Download packages to /www/pigsty	TAGS: [repo, repo_download]
      repo : Download cloud native packages	TAGS: [repo, repo_download]
      repo : Download additional url packages	TAGS: [repo, repo_download]
      repo : Create local yum repo index	TAGS: [repo, repo_download]
      repo : Mark local yum repo complete	TAGS: [repo, repo_download]

  play #2 (all): Init Node	TAGS: [node]
    tasks:
      node : Overwrite /etc/hosts config	TAGS: [node, node_dns]
      node : Add resovler to /etc/resolv.conf	TAGS: [node, node_dns]
      node : Set SELinux to permissive mode	TAGS: [node, node_selinux]
      node : Disable transparent hugepage	TAGS: [node, node_tune]
      node : Node configure disk prefetch	TAGS: [node, node_tune]
      node : Node configure enable watchdog	TAGS: [node, node_tune]
      node : Node configure disable numa	TAGS: [node, node_tune]
      node : Change sysctl.conf parameters	TAGS: [node, node_sysctl]
      node : Create os user group postgres	TAGS: [node, node_user]
      node : Create os user postgres:postgres	TAGS: [node, node_user]
      node : Create os user prometheus:postgres	TAGS: [node, node_user]
      node : Create os user consul:postgres	TAGS: [node, node_user]
      node : Create os user etcd:postgres	TAGS: [node, node_user]
      node : Copy default user bash profile	TAGS: [node, node_user]
      node : Install local yum repo for node	TAGS: [node, node_repo]
      node : Configure node using local repo	TAGS: [node, node_repo]
      node : Install cloud native packages	TAGS: [node, node_install]
      node : Install build essential packages	TAGS: [node, node_install]
      node : Install build essential packages	TAGS: [node, node_install]
      node : Install node packages from yum	TAGS: [node, node_install]
      node : Install chronyd package on node	TAGS: [node, node_ntp]
      node : Copy the chrony.conf template	TAGS: [node, node_ntp]
      node : Launch chronyd ntpd service	TAGS: [node, node_ntp]
      node : Set local timezone and synctime	TAGS: [node, node_ntp]
      node_consul : Stop existing consul	TAGS: [consul, node]
      node_consul : Copy consul server service	TAGS: [consul, node]
      node_consul : Copy consul agent service	TAGS: [consul, node]
      node_consul : Remove existing consul data	TAGS: [consul, node]
      node_consul : Recreate consul conf dir	TAGS: [consul, node]
      node_consul : Recreate consul data dir	TAGS: [consul, node]
      node_consul : Copy consul main config	TAGS: [consul, node]
      node_consul : Launch consul service	TAGS: [consul, node]
      node_exporter : Copy node_exporter svc	TAGS: [node, node_exporter]
      node_exporter : Config node_exporter svc	TAGS: [node, node_exporter]
      node_exporter : Launch node_exporter svc	TAGS: [node, node_exporter]
      node_exporter : Waits node_exporter ready	TAGS: [node, node_exporter]

  play #3 (all): Init Meta	TAGS: [meta]
    tasks:
      meta : Install build essential packages	TAGS: [meta, meta_install]
      meta : Install meta packages from yum	TAGS: [meta, meta_install]
      meta : Copy additional nginx proxy conf	TAGS: [meta, meta_nginx]
      meta : Restart pigsty nginx service	TAGS: [meta, meta_nginx]
      meta : Config nginx_exporter options	TAGS: [meta, meta_nginx]
      meta : Restart nginx_exporter service	TAGS: [meta, meta_nginx]
      meta : Copy dnsmasq /etc/dnsmasq.d/config	TAGS: [meta, meta_dnsmasq]
      meta : Copy dnsmasq hosts /etc/hosts	TAGS: [meta, meta_dnsmasq]
      meta : Launch meta dnsmasq service	TAGS: [meta, meta_dnsmasq]
      meta : Wait for meta dnsmasq online	TAGS: [meta, meta_dnsmasq]
      meta : Wipe out prometheus config dir	TAGS: [meta, meta_prometheus]
      meta : Wipe out existing prometheus data	TAGS: [meta, meta_prometheus]
      meta : Recreate prometheus data dir	TAGS: [meta, meta_prometheus]
      meta : Copy /etc/prometheus configs	TAGS: [meta, meta_prometheus]
      meta : Launch meta prometheus service	TAGS: [meta, meta_prometheus]
      meta : Launch meta alertmanager service	TAGS: [meta, meta_prometheus]
      meta : Wait for meta prometheus online	TAGS: [meta, meta_prometheus]
      meta : Wait for meta alertmanager online	TAGS: [meta, meta_prometheus]
      meta : Copy /etc/grafana/grafana.ini	TAGS: [meta, meta_grafana]
      meta : Provision grafana via grafana.db	TAGS: [meta, meta_grafana]
      meta : Provision grafana datasources	TAGS: [meta, meta_grafana]
      meta : Provision grafana dashboards	TAGS: [meta, meta_grafana]
      meta : Launch meta grafana service	TAGS: [meta, meta_grafana]
      meta : Wait for meta grafana online	TAGS: [meta, meta_grafana]
      meta : Check grafana plugin cache exists	TAGS: [meta, meta_plugins]
      meta : Provision grafana plugin via cache	TAGS: [meta, meta_plugins]
      meta : Download plugins if not exists	TAGS: [meta, meta_plugins]
      meta : Restart meta grafana service	TAGS: [meta, meta_plugins]
      meta : Copy consul services definition	TAGS: [meta, meta_register]
      meta : Reload consul meta services	TAGS: [meta, meta_register]
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