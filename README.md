# Pigsty -- PostgreSQL Sandbox

> PIGSTY: Postgres in Grafana STYle

This project provisioned a PostgreSQL cluster upon [vagrant](https://vagrantup.com/) with a battery-included monitoring system and minimal HA setup.



# Quick Start

1. Install [vagrant](https://vagrantup.com/), [virtualbox](https://www.virtualbox.org/) and [ansible](https://www.ansible.com/)
   
2. Clone this repo: `git clone https://github.com/vonng/pigsty && cd pigsty`
3. Setup local dns: `sudo make dns` (one-time job)
4. Pull up vm nodes: `make` 
5. Init database cluster via `make init`
6. Explore pigsty via http://pigsty

```bash
# TL;DR
brew install virtualbox vagrant ansible # (may not work that way)
git clone https://github.com/vonng/pigsty && cd pigsty
sudo make dns		# run-once to write /etc/hosts, may require password
make            # pull up all nodes
make init       # init infrastructures and create meta node on node0
make initdb     # init postgresql cluster
```

> #### Note 
>
> It may takes 30m to download packages (1GB) . So don't forget to make a local cache via  `make cache` after bootstrap. It will copy all packages to  `your_host:pigsty/pkg`. If cache is already available in `pigsty/pkg`.  Pigsty will bootstrap from it much faster (30m to 5m). Reboot from existing cluster will only takes around 30 seconds.
>
>  [Grafana](http://grafana.pigsty) default credential: `user=admin pass=admin`, if required.



## Operations

```
make					# launch cluster
make dns			# write pigsty dns record to your /etc/hosts (sudo required)
make cache		# copy local yum repo packages to your pigsty/pkg
make init			# init infrastructure and postgres cluster

make infra		# (re)init infrastructure only
make pgsql		# (re)init postgres cluster only
make clean		# delete current cluster
make ssh			# write ssh config to your ~/.ssh/config
make st				# show vagrant cluster status
```



## Architecture



## What's Next?

* Explore the monitoring system
* How service discovery works
* Add some load to cluster
* Managing postgres cluster with ansible
* High Available Drill




## About

Author：Vonng ([fengruohang@outlook.com](mailto:fengruohang@outlook.com))

LICENSE: [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/)