# Pigsty -- PostgreSQL in Graphic Style

> [PIGSTY](http://pigsty.cc): Postgres in Graphic STYle

[Pigsty](https://pigsty.cc/en/) is a **monitoring** system that is specially designed for large scale PostgreSQL clusters. Along with a production-grade HA PostgreSQL cluster **provisioning** solution.

![](img/logo.svg)

Check [official site](https://pigsty.cc/en/  ) for more information：https://pigsty.cc/en/   | 中文站点：[https://pigsty.cc/zh/](](https://pigsty.cc/zh/))

> The latest version of pigsty is [v0.8](https://github.com/Vonng/pigsty/releases/tag/v0.8.0). Under RC status with guaranteed API stability. 
>
> The final 1.0 GA version will be released on 2021-06-01.

## Highlights

* [Monitoring](#monitoring) System based on prometheus & grafana &  [`pg_exporter`](https://github.com/Vonng/pg_exporter)
* [Provisioning](#provisioning) Solution based on ansible. Kubernetes style, scale at ease.
* [HA Deployment](#ha-deployment) based on patroni. Self-healing and failover in seconds
* [Service Discovery](#service-discovery) based on DCS (consul / etcd), maintenance made easy.
* [Offline Installation](#offline-installation) without Internet access. Fast and reliable.
* Infrastructure as Code. Fully configurable and customizable. 
* Based on PostgreSQL 13 and Patroni 2. Tested under CentOS 7



## Quick Start

If you already have [vagrant](https://www.vagrantup.com/), [virtualbox](https://www.virtualbox.org/) and [ansible](https://docs.ansible.com/) installed. Try local sandbox with one command.
Clone this repo. And run following commands under project directory, pigsty will setup everything for you.

```bash
cd /tmp && git clone git@github.com:Vonng/pigsty.git && cd pigsty
make up          # pull up all vagrant nodes
make ssh         # setup vagrant ssh access
make init        # init infrastructure and databaes clusters
sudo make dns    # write static DNS record to your host (sudo required)
make mon-view    # monitoring system home page (default: admin:admin) 
```
> Verified Environment:: MacOS 11, Vagrant 2.2.14, Virtualbox 6.1.16

Check [Quick Start](http://pigsty.cc/en/docs/sandbox/) for detailed steps and more information.



## Features

### Monitoring

Pigsty provides a battery-included [Monitoring System](https://pigsty.cc/en/docs/monitor/). Which is specially designed for managing large-scale PostgreSQL clusters, and consist of thousands of metrics and 30+ dashboards.

![](img/overview1.jpg)

![](img/overview2.jpg)

### Provisioning

PostgreSQL cluster comes before monitoring system. That's why pigsty is shipping with a  [Provisioning Solution](https://pigsty.cc/en/docs/concept/provision/).

It allows you to create, update, scale, and manage your postgres cluster in kubernetes style.

```bash
vi pigsty.yml                     # edit configuration to define new clusters
./infra.yml                       # provision infrastructure on meta node 
./pgsql.yml -l <cluster>          # provision new clusters/instasnces
./pgsql-remove.yml -l <cluster>   # remove clusters/instances
```
Here is an example base on vagrant 4-node demo. The default configuration file is [`pigsty.yml`](pigsty.yml)

This [Vagrantfile](vagrant/Vagrantfile) defines four nodes: `meta` , `node-1` , `node-2`, `node-3`. 

Check [Architecture Overview](https://pigsty.cc/en/docs/concepts/architecture/) for more information.

![](img/infra.jpg)

### High Availability

Pigsty has HA Deployment powered by [Patroni 2.0](https://github.com/zalando/patroni). 

Pigsty is a database **[provisioning](https://pigsty.cc/en/docs/concept/provision/) solution** that can create [**HA**](https://pigsty.cc/en/docs/concept/provision/ha/) pgsql clusters on demand. Pigsty can automatically perform failover, with read-only traffic intact; the impact of read-write traffic is usually limited in seconds.

![](img/haproxy_l2vip.jpg)

Each instance is **idempotent**, Pigsty uses a 'NodePort' approach to expose different kind of [**services**](https://pigsty.cc/en/docs/concept/provision/service/). 

| service | port | usage                      | comment                          |
| ------- | ---- | -------------------------- | -------------------------------- |
| primary | 5433 | read-write/non-interactive | route to primary pgbouncer 6432  |
| replica | 5434 | read-only/non-interactive  | route to replicas pgbouncer 6432 |
| default | 5436 | read-write/interactive     | direct to primary 5432           |
| offline | 5438 | read-only/interactive      | direct to offline 5432           |

### Infrastructure as Code

Define infrastructure and new database clusters with declarative configurations. 

Creating a new database cluster `pg-test` with three nodes only require 6 lines config and 1 line command.

```yaml
pg-test:
  # - cluster members - #
  hosts:
    10.10.10.11: {pg_seq: 1, pg_role: primary, ansible_host: node-1}
    10.10.10.12: {pg_seq: 2, pg_role: replica, ansible_host: node-2}
    10.10.10.13: {pg_seq: 3, pg_role: offline, ansible_host: node-3}

  # - cluster config - #
  vars: { pg_cluster: pg-test }  # cluster name
```

And run [playbooks](https://pigsty.cc/en/docs/deploy/playbook/) to *instanlize* that cluster:

```bash
./pgsql.yml -l pg-test
```

<details>
<summary>Complex One</summary>

```yaml
#-----------------------------
# cluster: pg-meta
#-----------------------------
pg-meta:
  # - cluster members - #
  hosts:
    10.10.10.10: {pg_seq: 1, pg_role: primary, ansible_host: meta}

  # - cluster configs - #
  vars:
    pg_cluster: pg-meta                 # define actual cluster name
    pg_version: 13                      # define installed pgsql version
    node_tune: tiny                     # tune node into oltp|olap|crit|tiny mode
    pg_conf: tiny.yml                   # tune pgsql into oltp/olap/crit/tiny mode
    patroni_mode: pause                 # enter maintenance mode, {default|pause|remove}
    patroni_watchdog_mode: off          # disable watchdog (require|automatic|off)
    pg_lc_ctype: en_US.UTF8             # enabled pg_trgm i18n char support

    pg_users:
      # complete example of user/role definition for production user
      - name: dbuser_meta               # example production user have read-write access
        password: DBUser.Meta           # example user's password, can be encrypted
        login: true                     # can login, true by default (should be false for role)
        superuser: false                # is superuser? false by default
        createdb: false                 # can create database? false by default
        createrole: false               # can create role? false by default
        inherit: true                   # can this role use inherited privileges?
        replication: false              # can this role do replication? false by default
        bypassrls: false                # can this role bypass row level security? false by default
        connlimit: -1                   # connection limit, -1 disable limit
        expire_at: '2030-12-31'         # 'timestamp' when this role is expired
        expire_in: 365                  # now + n days when this role is expired (OVERWRITE expire_at)
        roles: [dbrole_readwrite]       # dborole_admin|dbrole_readwrite|dbrole_readonly
        pgbouncer: true                 # add this user to pgbouncer? false by default (true for production user)
        parameters:                     # user's default search path
          search_path: public
        comment: test user

      # simple example for personal user definition
      - name: dbuser_vonng              # personal user example which only have limited access to offline instance
        password: DBUser.Vonng          # or instance with explict mark `pg_offline_query = true`
        roles: [dbrole_offline]         # personal/stats/ETL user should be grant with dbrole_offline
        expire_in: 365                  # expire in 365 days since creation
        pgbouncer: false                # personal user should NOT be allowed to login with pgbouncer
        comment: example personal user for interactive queries

    pg_databases:
      - name: meta                      # name is the only required field for a database
        owner: postgres                 # optional, database owner
        template: template1             # optional, template1 by default
        encoding: UTF8                # optional, UTF8 by default , must same as template database, leave blank to set to db default
        locale: C                     # optional, C by default , must same as template database, leave blank to set to db default
        lc_collate: C                 # optional, C by default , must same as template database, leave blank to set to db default
        lc_ctype: C                   # optional, C by default , must same as template database, leave blank to set to db default
        allowconn: true                 # optional, true by default, false disable connect at all
        revokeconn: false               # optional, false by default, true revoke connect from public # (only default user and owner have connect privilege on database)
        # tablespace: pg_default          # optional, 'pg_default' is the default tablespace
        connlimit: -1                   # optional, connection limit, -1 or none disable limit (default)
        extensions:                     # optional, extension name and where to create
          - {name: postgis, schema: public}
        parameters:                     # optional, extra parameters with ALTER DATABASE
          enable_partitionwise_join: true
        pgbouncer: true                 # optional, add this database to pgbouncer list? true by default
        comment: pigsty meta database   # optional, comment string for database

    pg_default_database: meta           # default database will be used as primary monitor target

    # proxy settings
    vip_mode: l2                      # enable/disable vip (require members in same LAN)
    vip_address: 10.10.10.2             # virtual ip address
    vip_cidrmask: 8                     # cidr network mask length
    vip_interface: eth1                 # interface to add virtual ip

```

</details>

There are 156 [parameters](http://pigsty.cc/en/docs/config/entry/) that controls every aspect of Pigsty. Check [configuration guide](https://pigsty.cc/en/docs/config/)  for more detail.

|  No  |                           Category                           | Args | Function                                                     |
| :--: | :----------------------------------------------------------: | :--: | ------------------------------------------------------------ |
|  1   |     [connect](http://pigsty.cc/en/docs/config/1-connect)     |  1   | Connection parameters and proxy setting                      |
|  2   |        [repo](http://pigsty.cc/en/docs/config/2-repo)        |  10  | local yum and offline installation                           |
|  3   |        [node](http://pigsty.cc/en/docs/config/3-node)        |  29  | common setup for all nodes                                   |
|  4   |        [meta](http://pigsty.cc/en/docs/config/4-meta)        |  21  | infrastructure on meta nodes                                 |
|  5   |         [dcs](http://pigsty.cc/en/docs/config/5-dcs)         |  8   | dcs service (consul/etcd)                                    |
|  6   |  [pg-install](http://pigsty.cc/en/docs/config/6-pg-install)  |  11  | install postgres, extensions, users, directories, scripts, utils |
|  7   | [pg-provision](http://pigsty.cc/en/docs/config/7-pg-provision) |  25  | bootstrap postgres cluster and identity assignment           |
|  8   | [pg-template](http://pigsty.cc/en/docs/config/8-pg-template) |  19  | customize postgres cluster template                          |
|  9   |     [monitor](http://pigsty.cc/en/docs/config/9-monitor)     |  13  | install monitoring components                                |
|  10  |    [service](http://pigsty.cc/en/docs/config/10-service)     |  17  | expose database service                                      |



### Service Discovery

Pigsty is integrated with [Service Discovery](https://pigsty.cc/en/docs/concept/monitor/identity/) based on DCS (consul/etcd). All service are automatically register to DCS. Which eliminate lots of manual maintenance work. And you can check health status about all nodes and service in an intuitive way.

Consul is the only DCS that is supported (etcd will be added further). You can use consul as DNS service provider to achieve DNS based traffic routing.

![](img/service-discovery.jpg)


###  Offline Installation

Pigsty supports offline installation. It is especially useful for environment that has no Internet access.

Pigsty comes with a local Yum repo that includes all required packages and its dependencies. You can download [pre-packed offline packages](https://github.com/Vonng/pigsty/releases) or make it on your own in another node that have internet or proxy access. Check [Offline Installation](https://pigsty.cc/en/docs/deploy/prepare/offline/) for detail.



## Specification

<details>
<summary>specification</summary>

**System Requirement**

* CentOS 7 / Red Hat 7 / Oracle Linux 7
* CentOS 7.6/7.8 is highly recommend (Fully tested under minimal installation)

**Minimal setup**

* Self-contained single node, singleton database `pg-meta`
* Minimal requirement: 1 CPU Core & 2 GB RAM

**Standard setup ( TINY mode, vagrant demo)**

* 4 Node, including single meta node, singleton database cluster `pg-meta` and 3-instances database cluster `pg-test`
* Recommend Spec: 2Core/4GB for meta controller node, 1Core/1GB for database node 

**Production setup (OLTP/OLAP/CRIT mode)**

* 200+ nodes,  3 meta nodes , 100+ database clusters
* Verified Spec: Dell R740 / 64 Core / 400GB Mem / 3TB PCI-E SSD

</details>


## Support

[Business Support](https://pigsty.cc/en/docs/business/) for pigsty is available.

## About

Author：[Vonng](https://vonng.com) (rh@vonng.com)

[Apache Apache License Version 2.0](LICENSE)