# [Pigsty](http://pigsty.cc) -- PostgreSQL in Graphic Style

> [PIGSTY](http://pigsty.cc): Postgres in Graphic STYle

[Pigsty](http://pigsty.cc) is a monitoring system that is specially designed for large scale PostgreSQL clusters. Along with a  postgres cluster provisioning solution. It also shipped with a four-node VM sandbox environment based on [vagrant](https://vagrantup.com/) for demonstration purpose.

![](doc/logo/logo-full.svg)

[Offical Site](http://pigsty.cc): http://pigsty.cc

[中文文档](doc/README_CN.md)



## Highlights

* [Monitoring System](doc/monitoring-system.md) based on prometheus & grafana &  [`pg_exporter`](https://github.com/Vonng/pg_exporter)
* [Provisioning Solution](doc/provision.md) based on ansible. Kubernetes style, scale at ease.
* [HA Deployment](doc/ha.md) based on patroni. Self-healing and failover in seconds
* [Service Discovery](doc/service-discovery.md) based on DCS (consul / etcd), maintainence made easy.
* [Offline Installataion](doc/offline-installation.md) without Internet access. fast and secure.
* [Infrastructure as Code](doc/architecture.md). Fully [configurable](doc/configuration.md) and [customizable](doc/templates.md). 
* Based on PostgreSQL 13 and Patroni 2. Tested under CentOS 7



## Quick Start

If you already have vagrant and virtualbox installed. These commands will just setup everything for you.

```bash
# run under pigsty home dir
make up          # pull up all vagrant nodes
make ssh         # setup vagrant ssh access
make init        # init infrastructure and databaes clusters
sudo make dns    # write static DNS record to your host (sudo required)
make mon-view    # monitoring system home page (default: admin:admin) 
```

> Verified version: MacOS 10.15, Vagrant 2.2.10, Virtualbox 6.1.14

Check [Quick Start](doc/quick-start.md) for more inforamtion



## Features

### Monitoring System

Pigsty provides a battery-included [Monitoring System](doc/monitoring-system.md). Which is specially designed for managing large-scale PostgreSQL clusters, and consist of thousands of metrics and 30+ dashboards.

![](doc/img/pg-overview.jpg)



### Provisioning Solution

PostgreSQL cluster comes before monitoring system. That's why pigsty is shipping with a  [Provisioning Solution](doc/provision.md). It allows you to create, update, scale your postgres cluster in kubernetes style.

```bash
# most common database cluster management operations:
vi conf/all.yml           # declare cluster status (check configuration guide for detail)
./ins-add.yml  -l <host>  # setup new instance / adjust instance according to config
./ins-del.yml  -l <host>  # remove instance on host
```

Here is an example base on vagrant 4-node demo. [Vagrantfile](vagrant/Vagrantfile) define four nodes: `meta` , `node-1` , `node-2`, `node-3`. Check [Architecture Overview](doc/architecture.md) for more information.

![](doc/img/arch.png)



### High Availability

Pigsty has [HA Deployment](doc/ha.md) support powered by [Patroni 2.0](https://github.com/zalando/patroni). 

Failover and switchover are extremely simple and fast. It can be completed in seconds without affecting any standby traffics (PG13). 

![](doc/img/proxy.png)

One-line failover, and complete in seconds

```bash
# run as postgres @ any member of cluster `pg-test`
$ pt failover
Candidate ['pg-test-2', 'pg-test-3'] []: pg-test-3
Current cluster topology
+ Cluster: pg-test (6886641621295638555) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Leader  | running |  1 |           | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  1 |         0 | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Replica | running |  1 |         0 | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+
Are you sure you want to failover cluster pg-test, demoting current master pg-test-1? [y/N]: y
+ Cluster: pg-test (6886641621295638555) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Replica | running |  2 |         0 | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  2 |         0 | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Leader  | running |  2 |           | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+
```

### Service Discovery

Pigsty is intergreted with [Service Discovery](doc/service-discovery.md) based on DCS (consul/etcd). All service are automatically registed to DCS. Which eliminate lots of manual maintenance work. And you can check health status about all nodes and service in an intuitive way.

Consul is the only DCS that is supported (etcd will be added further). You can use consul as DNS service provider to achieve DNS based traffic routing.

![](doc/img/service-discovery.jpg)

###  Offline Installation

Pigsty supports offline installation. It is especially useful for environment that has poor network condition.

Pigsty comes with a local Yum repo that includes all required packages and its dependencies. You can download pre-packed offline packages or make it on your own in another node that have internet or proxy access. Check [Offline Installation](doc/offline-installation.md) for detail.





## Sepcification

**System Requirement**

* CentOS 7 / Red Hat 7 / Oracle Linux 7
* CentOS 7.6/7.8 is highly recommened (Fully tested under minimal installtion)

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

Business support for pigsty is available. [Contact](mailto:fengruohang@outlook.com) for more detail.

* Complete version of monitoring system.

  > Community version  includes 10 core dashboards. Which is already very powerful.
  >
  > Unlock 30+ dashboards with enterprise version 😊)

* Security enhancement (DCS with ACL, SSL, CA, etc....)

* Production  deployment & operation & administration scheme

* Meta database and data dictionary

* Log collecting system and daily log summary

* Backup / Recovery plan

* Deployment assistance and trouble shooting.

* Intergration with existing system.

Read more about [Business Support](doc/support.md)



## Roadmap

[Roadmap](doc/roadmap.md)



## About

Author：Vonng ([fengruohang@outlook.com](mailto:fengruohang@outlook.com))

[Apache Apache License Version 2.0](LICENSE)