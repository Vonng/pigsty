# Pigsty -- PostgreSQL in Graphic Style

> PIGSTY: Postgres in Graphic STYle

This project provides a powerful monitoring system specially designed for PostgreSQL, along with a patroni-based high-available database cluster provision solution. It has been used and tested in real world production environment.

![](doc/logo/logo-full.svg)

[中文文档](doc/README_CN.md)



## Highlight

* High-available PostgreSQL cluster with production grade quality
* Intergreted monitoring, logging, alerting system
* Service discovery and configuration management based on DCS
* Offline installtaion without Internet access
* Infrastructure as Code. Fully customizable. 
* Optimized for different situations: OLTP, OLAP, Critical, Virtual Machine, ...
* Simple interface, declarative parameters and idempotent playbooks
* Latest version support (PostgreSQL 13 and Patroni 2.0), Fully tested under CentOS 7

![](doc/img/overview.jpg)





## Quick Start

1. Prepare nodes, pick one as meta node which have nopass ssh & sudo on other nodes ([Vagrant Provision Guide](doc/vagrant-provision.md))
2. Install ansible on meta nodes and clone this repo ([Bootstrap Guide](doc/bootstrap.md))
   
   ```bash
   git clone https://github.com/vonng/pigsty && cd pigsty 
   ```

3. **Configure** your infrastructure and defining you database clusters ([Configuration Guide](doc/configuration.md))

   ```bash
   conf/all.yml				 # default configuration path
   ```


4. Run`infra.yml` on meta node to provision infrastructure. ([Infrastructure Provision Guide](doc/infra-provision.md))

   ```bash
   ./infra.yml          # setup infrastructure properly
   ```
   
5. Run`initdb.yml` on meta node to provision database cluster ([Postgres Provision Guide](doc/postgres-provision.md))

   ```bash
   ./initdb.yml       # pull up all postgres clusters  
   ```

6. Start exploring ([Monitor System Guide](doc/monitor-system.md))

   ```bash
   # GUI access:
   sudo make dns				   # write local DNS record to your /etc/hosts, sudo required
   open http://g.pigsty   # monitor system grafana, default credential: admin:admin

   # cli access: benching pg-test cluster with pgbench
   pgbench -is10 postgres://test:test@pg-test:5433/test						                          # init
   pgbench -nv -P1 -c2 --rate=50 -T10 postgres://test:test@pg-test:5433/test	                # primary
   pgbench -nv -P1 -c4 --select-only --rate=1000 -T10 postgres://test:test@pg-test:5434/test # replica
   ```
   



## Architecture

### Cluster Overview

Take standard demo cluster as an example, this cluster consist of four nodes: `meta` , `node-1` , `node-2`, `node-3`. 

![](doc/img/arch.png)

### Service Overview

Pigsty provides multiple ways to connect to database:

* L2: via virtual IP address that are bond to primary instance
* L4: via haproxy load balancer that runs symmetrically on all nodes among cluster
* L7: via DNS (`pg-test`, `primary.pg-test`, `replica.pg-test`)

And multiple ways to route (read-only/read-write) traffic:

* Distinguish primary and replica service by DNS  (`pg-test`, `pg-test-primary`, `pg-test-replica`)
* Distinguish primary and replica service by Port (5433 for primary, 5434 for replica)
* Direct instance access
* Smart Client (`target_session_attrs=read-write`)

Lot's of configurable parameters items, refer to [Proxy Configuration Guide](doc/proxy-configuration.md) for more detail.

![](doc/img/proxy.png)

[Database Access Guide](doc/database-access.md) provides information about how to connect to database.



## Sepcification

**System Requirement**

* CentOS 7 / Red Hat 7 / Oracle Linux 7
* CentOS 7.6 is highly recommened (Fully tested under minimal installtion)

**Minimal setup**

* Self-contained single node, singleton database `pg-meta`
* Minimal requirement: 2 CPU Core & 2 GB RAM

**Standard setup ( TINY mode, vagrant demo)**

* 4 Node, including single meta node, singleton databaes cluster `pg-meta` and 3-instances database cluster `pg-test`
* Recommend Spec: 2Core/2GB for meta controller node, 1Core/1GB for database node 

**Production setup (OLTP/OLAP/CRIT mode)**

* 200+ nodes,  3 meta nodes , 100+ database clusters
* Verified Spec: Dell R740 / 64 Core / 400GB Mem / 3TB PCI-E SSD





## Support

Bug fix and issue

* No guaranteed deadline.

Business support for pigsty is available. [Contact](mailto:fengruohang@outlook.com) for more detail.

* Advance Monitoring System, 3000+ metrics, 30+ extra dashboards
* Production  deployment & operation & administration scheme
* Meta database and data dictionary
* Log collecting system and daily log summary
* Backup / Recovery plan
* Deployment assistance and trouble shooting. Intergration with existing system.

Read [more [TBD]](doc/enterprise.md) about business support of pigsty.



## Roadmap

[Roadmap](doc/roadmap.md)



## About

Author：Vonng ([fengruohang@outlook.com](mailto:fengruohang@outlook.com))

[Apache Apache License Version 2.0](LICENSE)

