# Pigsty -- PostgreSQL in Graphic Style

> PIGSTY: Postgres in Graphic STYle

This project is a demonstration of `pigsty` — PostgreSQL in Graphic STYle. Which consist of a high-availability database solution and a battery-included monitoring system. This project has been tested in real world production environment. It can be used freely.

[中文文档](doc/README_CN.md)



## Highlight

* High-available PostgreSQL cluster with production grade quality.
* Offline installtaion mode without Internet access
* Intergreted monitoring alerting logging system
* Service discovery and metadata storage with dcs
* Performance tuning for different situations (OLTP, OLAP, CRIT, TINY)
* Infra as Code: declarative parameters, customizable templates, idempotent playbooks.



## Quick Start

1. Prepare nodes, pick one as meta node which have nopass ssh & sudo on other nodes ([Vagrant Provision Guide](doc/vagrant-provision.md))
2. Install ansible on meta nodes and clone this repo ([Bootstrap Guide](doc/bootstrap.md))
   
   ```bash
   git clone https://github.com/vonng/pigsty && cd pigsty 
   ```

3. Configure your infrastructure and defining you database clusters ([Configuration Guide](doc/configuration.md))

   ```bash
   group_vars/all.yml   # infrastructure definition, global variables
   cls/inventory.ini    # postgres cluster definition, node/cluster specific variables
   templates/           # provision template (pre-defined or user-provided)   
   ```


4. Run`infra.yml` on meta node to provision infrastructure. ([Infrastructure Provision Guide](doc/infra-provision.md))

   ```bash
   ./infra.yml          # setup infrastructure properly
   ```
   
5. Run`postgres.yml` on meta node to provision database cluster ([Postgres Provision Guide](doc/postgres-provision.md))

   ```bash
   ./postgres.yml       # pull up all postgres clusters  
   ```

6. Start exploring ([Monitor System Guide](doc/monitor-system.md))

   ```bash
   # GUI access:
   sudo make dns				   # write local DNS record to your /etc/hosts, sudo required
   open http://g.pigsty   # monitoring system grafana, credential: admin:admin

   # cli access: benching pg-test cluster with pgbench
   pgbench -is10 postgres://test:test@pg-test:5433/test						                          # init
   pgbench -nv -P1 -c2 --rate=50 -T10 postgres://test:test@pg-test:5433/test	                # primary
   pgbench -nv -P1 -c4 --select-only --rate=1000 -T10 postgres://test:test@pg-test:5434/test # replica
   ```
   



## Architecture

Take standard demo cluster as an example

![](doc/img/arch.png)

[Database Access Guide](doc/database-access.md) provides information about how to connect to database.



## Requirement

**Minimal setup**

* 1 Node, self-contained, CentOS 7 (Tested on 7.6)
* Meta node, and a one-node postgres instance `pg-meta`
* Minimal requirement: 2 CPU Core & 2 GB RAM

**Standard setup (vagrant demo)**

* 4 Node, including 1 meta node and 3 database node, CentOS 7.6
* Two postgres cluster `pg-meta` and `pg-test` (1 primary, 2 replica)
* Meta node requirement: 2~4 CPU Core & 4 ~ 8 GB RAM
* DB node minimal requirement: 1 CPU Core & 1 GB RAM



## Support

Business support is available. contact [me](mailto:fengruohang@outlook.com) for more detail.

* Advance Monitoring System
* MetaDB and Catalog Explorer
* Logging Summary System based on pgbadger
* Customizable backup & recovery plan
* Deployment assistance and trouble shooting

Read more about enterprise (maybe later) version of pigsty.



## Roadmap

[Roadmap](doc/roadmap.md)



## About

Author：Vonng ([fengruohang@outlook.com](mailto:fengruohang@outlook.com))

[Apache Apache License Version 2.0](LICENSE)

