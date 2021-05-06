# Pigsty -- PostgreSQL in Graphic Style

> [PIGSTY](http://pigsty.cc): Postgres in Graphic STYle

[Pigsty](https://pigsty.cc/zh/) delivers the **BEST** open source **monitoring** solution for PostgreSQL. Along with the **easiest provisioning** solution for large scale proudction-grade database clusters. 

It can be used both for large-scale pg clusters management in real-world prod-env, and for launching battery-included single pg instance for dev & demo purpose in a simple and fast way.

![](img/logo.svg)

Check [**OFFICIAL SITE**](https://pigsty.cc/en/  ) for more information：[**https://pigsty.cc/en/**](https://pigsty.cc/en/)   | 中文站点：[**https://pigsty.cc/zh/**](](https://pigsty.cc/zh/))

> The latest version of pigsty is [v0.9](https://github.com/Vonng/pigsty/releases/tag/v0.9.0).
>
> The final 1.0 GA version will be released near June~July 2021



## Highlights

* [Monitoring]() System based on prometheus & grafana &  [`pg_exporter`](https://github.com/Vonng/pg_exporter)
* [Provisioning](#provisioning) Solution based on ansible. Kubernetes style, scale at ease.
* [HA Deployment](#ha-deployment) based on patroni. Self-healing and failover in seconds
* [Service Discovery](#service-discovery) based on DCS (consul / etcd), maintenance made easy.
* [Offline Installation](#offline-installation) without Internet access. Fast and reliable.
* Infrastructure as Code. Fully configurable and customizable. 
* Based on PostgreSQL 13 and Patroni 2. Verified in proudction environment (CentOS 7, 200+nodes)



## Quick Start

Prepare a CentOS 7.x meta node with **ssh** & **root** access.  

```bash
curl -fsSL https://pigsty.cc/pigsty.tgz | gzip -d | tar -xC ~ && cd ~/pigsty # src code
bin/ipconfig <node_local_ipv4_address>                                       # ipconfig
make pkg                                                                     # download
make meta                                                                    # launch
```

Check documentation for more information.



> ## Get Node
>
> The easiest way to get a node is using cloud-services. But if you wish to run pigsty on your laptop. You can either create CentOS 7.8 vm nodes with software such as vmware, parallel desktop, virtualbox manually. Or just leave it to [vagrant](https://github.com/Vonng/pigsty/blob/master/vagrant/Vagrantfile).  For MacOS users, these makefile shortcuts will setup a vm node (ip: 10.10.10.10) on your Mac host using [virtualbox](https://www.virtualbox.org/wiki/Downloads). After that everything is same as [Quick Start](#quick-start).
>
> ```bash
> cd /tmp && git clone git@github.com:Vonng/pigsty.git && cd pigsty
> make deps        # Install MacOS deps with homebrew: vagrant virtualbox ansible
> make download    # Download packages to files/release/v*.*/{pkg,pigsty}.tgz
> make start       # launch vagrant vm nodes based on vagrant/Vagrantfile
> make dns         # write static DNS record to your host (sudo required)
> make copy        # copy pigsty resource to vagrant meta vm  node
> ```
>
> Verified Environment:: MacOS 11, Vagrant 2.2.14, Virtualbox 6.1.16



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
```
Here is an example base on vagrant 4-node demo. The default configuration file is [`pigsty.yml`](pigsty.yml)

This [Vagrantfile](vagrant/Vagrantfile) defines four nodes: `meta` , `node-1` , `node-2`, `node-3`. Check [Architecture Overview](https://pigsty.cc/en/docs/concepts/architecture/) for more information.

![](img/infra.jpg)

And you can also mange cluster with pigsty [CLI](https://github.com/Vonng/pigsty-cli) & GUI (beta)

<details>
<summary>Pigsty GUI (beta)</summary>

![](img/gui.jpg)

</details>



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
    10.10.10.11: {pg_seq: 1, pg_role: primary}
    10.10.10.12: {pg_seq: 2, pg_role: replica}
    10.10.10.13: {pg_seq: 3, pg_role: offline}

  # - cluster config - #
  vars: { pg_cluster: pg-test }  # cluster name
```

<details>
<summary>Complex One</summary>

```yaml
#-----------------------------
# cluster: pg-meta
#-----------------------------
# pg-meta is a single-node pgsql cluster deployed on meta node (10.10.10.10)
pg-meta:
  # - cluster members - #
  hosts:
    10.10.10.10: {pg_seq: 1, pg_role: primary, pg_offline_query: true}

  # - cluster configs - #
  vars:
    pg_cluster: pg-meta                 # define actual cluster name
    pg_version: 13                      # define installed pgsql version
    node_tune: tiny                     # tune node into oltp|olap|crit|tiny mode
    pg_conf: tiny.yml                   # tune pgsql into oltp|olap|crit|tiny mode
    patroni_mode: pause                 # enter maintenance mode, {default|pause|remove}
    patroni_watchdog_mode: off          # disable watchdog (require|automatic|off)
    pg_lc_ctype: en_US.UTF8             # enabled pg_trgm i18n char support

    # - defining business users - #
    pg_users:
      # default production read-write user dbuser_meta
      - name: dbuser_meta                              # user's name is required
        password: md5d3d10d8cad606308bdb180148bf663e1  # md5 password is acceptable
        pgbouncer: true                                # add user to pgbouncer userlist
        roles: [dbrole_readwrite]                      # grant roles to user
        comment: default production read-write user for meta database

      # default production read-only user for grafana direct access
      - name: dbuser_grafana
        password: DBUser.Grafana
        pgbouncer: true
        roles: [dbrole_readonly]
        comment: default readonly access for grafana datasource

      # complete example of user/role definition
      - name: dbuser_pigsty             # pigsty user have admin access (DDL|DML)
        password: DBUser.Pigsty         # example user's password, can be md5 encrypted
        login: true                     # can login, true by default (should be false for role)
        superuser: false                # is superuser? false by default
        createdb: false                 # can create database? false by default
        createrole: false               # can create role? false by default
        inherit: true                   # can this role use inherited privileges?
        replication: false              # can this role do replication? false by default
        bypassrls: false                # can this role bypass row level security? false by default
        pgbouncer: true                 # add this user to pgbouncer? false by default (true for production user)
        connlimit: -1                   # connection limit, -1 disable limit
        expire_in: 3650                 # now + n days when this role is expired (OVERWRITE expire_at)
        expire_at: '2030-12-31'         # 'timestamp' when this role is expired (OVERWRITTEN by expire_in)
        comment: pigsty admin user      # comment on user/role
        roles: [dbrole_admin]           # dbrole_{admin,readonly,readwrite,offline}
        parameters:                     # additional role level parameters with ALTER ROLE SET
          search_path: pigsty,public    # add pigsty schema into search_path

    # - defining business databases - #
    pg_databases:
      - name: meta                      # name is the only required field for a database
        baseline: metadb/schema.sql     # pigsty meta database baseline
        owner: postgres                 # optional, database owner
        template: template1             # optional, template1 by default
        encoding: UTF8                  # optional, UTF8 by default , must same as template database, leave blank to set to db default
        locale: C                       # optional, C by default , must same as template database, leave blank to set to db default
        lc_collate: C                   # optional, C by default , must same as template database, leave blank to set to db default
        lc_ctype: C                     # optional, C by default , must same as template database, leave blank to set to db default
        tablespace: pg_default          # optional, 'pg_default' is the default tablespace
        allowconn: true                 # optional, true by default, false disable connect at all
        revokeconn: false               # optional, false by default, true revoke connect from public # (only default user and owner have connect privilege on database)
        pgbouncer: true                 # optional, add this database to pgbouncer list? true by default
        comment: pigsty meta database   # optional, comment string for database
        connlimit: -1                   # optional, connection limit, -1 or none disable limit (default)
        schemas: [pigsty]               # optional, create additional schema
        extensions:                     # optional, extension name and which schema to create
          - {name: adminpack, schema: pg_catalog}
        parameters:                       # optional, extra parameters with ALTER DATABASE
          search_path: 'pigsty,public'    # add pigsty to search_path
          log_min_duration_statement: 10  # log all action on meta database

    pg_default_database: meta           # default database will be used as primary monitor target
    vip_mode: l2                        # none|l2|l4, l2 vip are used in sandbox demo
    vip_address: 10.10.10.2             # virtual ip address
    vip_cidrmask: 8                     # cidr network mask length
    vip_interface: eth1                 # interface to add virtual ip

```


And run [playbooks](https://pigsty.cc/en/docs/deploy/playbook/) to *instanlize* that cluster:

```bash
./pgsql.yml -l pg-test
```

</details>



There are 160+ [parameters](http://pigsty.cc/en/docs/config/entry/) that controls every aspect of Pigsty. Check [configuration guide](https://pigsty.cc/en/docs/config/)  for more information.


<details>
<summary>Configuration Entries</summary>

|  No  |                           Category                           | Function                                                     |
| :--: | :----------------------------------------------------------: | ------------------------------------------------------------ |
|  1   |     [connect](http://pigsty.cc/en/docs/config/1-connect)     | Connection parameters and proxy setting                      |
|  2   |        [repo](http://pigsty.cc/en/docs/config/2-repo)        | local yum and offline installation                           |
|  3   |        [node](http://pigsty.cc/en/docs/config/3-node)        | common setup for all nodes                                   |
|  4   |        [meta](http://pigsty.cc/en/docs/config/4-meta)        | infrastructure on meta nodes                                 |
|  5   |         [dcs](http://pigsty.cc/en/docs/config/5-dcs)         | dcs service (consul/etcd)                                    |
|  6   |  [pg-install](http://pigsty.cc/en/docs/config/6-pg-install)  | install postgres, extensions, users, directories, scripts, utils |
|  7   | [pg-provision](http://pigsty.cc/en/docs/config/7-pg-provision) | bootstrap postgres cluster and identity assignment           |
|  8   | [pg-template](http://pigsty.cc/en/docs/config/8-pg-template) | customize postgres cluster template                          |
|  9   |     [monitor](http://pigsty.cc/en/docs/config/9-monitor)     | install monitoring components                                |
|  10  |    [service](http://pigsty.cc/en/docs/config/10-service)     | expose database service                                      |


</details>



### Service Discovery

Pigsty is integrated with [Service Discovery](https://pigsty.cc/en/docs/concept/monitor/identity/) based on DCS (consul/etcd). All service are automatically register to DCS. Which eliminate lots of manual maintenance work. And you can check health status about all nodes and service in an intuitive way. 

<details>
<summary>Consul SD Implementation</summary>

Consul is the only DCS that is currently supported. You can use consul as DNS service provider to achieve DNS based traffic routing. 

![](img/service-discovery.jpg)

Pigsty can also use static file discovery for prometheus, which would eliminate the need of consul for monitoring.

</details>



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

* Self-contained, single meta node, singleton pgsql cluster `pg-meta`
* Minimal requirement: 1 CPU Core & 2 GB RAM

**Demo setup ( TINY mode, vagrant demo)**

* 4 Node, including single meta node, singleton database cluster `pg-meta` and 3-instances pgsql cluster `pg-test`
* Spec:  2Core/4GB for meta controller node, 1Core/1GB for database node (x3)

**Production setup (OLTP/OLAP/CRIT mode)**

* 200+ nodes,  3 meta nodes , 100+ database clusters
* Verified Spec: Dell R740 / 64 Core / 400GB Mem / 3TB PCI-E SSD

</details>



## Support

[Business Support](https://pigsty.cc/en/docs/business/) for pigsty is available.

## About

Author：[Vonng](https://vonng.com) (rh@vonng.com)

[Apache Apache License Version 2.0](LICENSE)