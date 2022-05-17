# Pigsty

## Pigsty v1.5.0-rc Documentation

**Battery-Included Open-Source PostgreSQL Distribution**

> Latest Version: [v1.5.0-rc](https://github.com/Vonng/pigsty/releases/tag/v1.5.0-rc)  |  [Github Repo](https://github.com/Vonng/pigsty) | [Demo](http://demo.pigsty.cc)
>
> Documentation: [EN Docs](https://pigsty.cc/) | [中文文档](https://pigsty.cc/#/zh-cn/) | [Github Pages](https://vonng.github.io/pigsty/#/)



## What is Pigsty?

[![](_media/WHAT_EN.svg)](s-feature.md)

**Pigsty** is battery-included open-source database [distribution](s-feature.md#postgresql-distribution), with the latest [PostgreSQL](https://www.postgresql.org/) kernel, [TimescaleDB](https://www.timescale.com), [PostGIS](https://postgis.net/), [Citus](https://www.citusdata.com/) & 100+ extensions, along with an entire [Infra](c-infra.md): Grafana, Prometheus, Loki, Ansible, [Docker](t-docker.md) to support your databases & [applications](s-feature.md#Versatile-Scenario). It also includes common tools for [data analysis](s-feature.md#data-analysis).

Pigsty is a [monitoring](s-feature.md#ultimate-observability) & management [SRE Solution](s-feature.md#SRE-Solution). Which includes an unparalleled [monitoring](s-feature.md#Open-Source-RDS) system with ultimate observability, and [high-available](c-pgsql.md#High-Availability) PostgreSQL with self-healing architecture. You can deploy various clusters & instances: [primary, replica](d-pgsql.md#m-s-replication), [standby](d-pgsql.md#Sync-Standby), [offline](d-pgsql.md#Offline-Replica), [delayed](d-pgsql.md#Delayed-Cluster), [cascade](d-pgsql.md#Cascade-Instance), and even [Citus](d-pgsql.md#Citus-Deployment), [Redis](d-redis.md), and [Greenplum](d-matrixdb.md) clusters.

Pigsty is a handy [toolbox](s-feature.md#developer-toolbox) for developers. It treats [**Database as Code**](s-feature.md#database-as-code), Infra as Data. You just [describe](v-config.md) what database you want, and pigsty will create it for you. You can download, install, deploy, scale, backup, migration with [one command](s-install.md).  It can be deployed [everywhere](s-feature.md#Ubiquitous-Deployment): a 10k+ core prod env or local 1C/2G VM, [cloud](d-sandbox.md#cloud-sandbox), or [on-premises](d-sandbox.md#local-sandbox).

Pigsty is a [secure](s-feature.md#Safty-and-Thrifty) & [thrifty](s-feature.md#Safty-and-Thrifty) alternative to [Cloud RDS](s-feature.md#Open-Source-RDS)/PaaS. It can empower a single DEV/DBA to manage hundreds of databases clusters, with all data under your own control. It can [save](s-feature.md#Safty-and-Thrifty) 50% - 80% cost compared to cloud RDS using ECS or on-premise deployment. And the software itself is completely [open-source](https://github.com/Vonng/Capslock/blob/master/LICENSE) & free!

Check [FEATURES](s-feature.md) for more detail.


<details><summary>Distribution</summary>

[![Distribution](docs/_media/DISTRIBUTION.gif)](docs/c-infra.md#Overview)

</details>

<details><summary>Observability</summary>

[![Observability](docs/_media/overview-monitor.jpg)](http://demo.pigsty.cc)

</details>

<details><summary>High Availability</summary>

[![High Availability](docs/_media/HA-PGSQL.svg)](docs/c-pgsql.md#High-Availability)

</details>

<details><summary>Architecture</summary>

[![Architecture](docs/_media/ARCH.gif)](docs/c-arch.md)

</details>

<details><summary>Sandbox</summary>

[![Sandbox](docs/_media/SANDBOX.gif)](docs/d-sandbox.md)

</details>

<details><summary>Provisioning</summary>

[![Provisioning](docs/_media/PROVISION.gif)](docs/d-deploy.md)

</details>

<details><summary>User Interface</summary>

[![User Interface](docs/_media/interface.jpg)](docs/s-install.md)

</details>

<details><summary>Application</summary>

[![Application](docs/_media/overview-covid.jpg)](docs/t-application.md)

</details>



## TL; DR

Get a new Linux x86_64 CentOS 7.8 node. with nopass `sudo` & `ssh` access, then:

```bash
bash -c "$(curl -fsSL http://download.pigsty.cc/get)"  # get latest pigsty source
cd ~/pigsty && ./configure                             # pre-check and config templating 
./infra.yml                                            # install pigsty on current node
```

Now you have a battery-included Postgres on port **5432** and infra web services available on port **80**.

Check [Installation](s-install.md) & [Demo](http://demo.pigsty.cc) for details.

![](_media/HOW_EN.svg)



<details><summary>Download Packages Directly</summary>

Pigsty source & software packages can be downloaded directly via `curl` in case of no Internet connection:

```bash
curl -SL https://github.com/Vonng/pigsty/releases/download/v1.5.0-rc/pkg.tgz -o /tmp/pkg.tgz
curl -SL https://github.com/Vonng/pigsty/releases/download/v1.5.0-rc/pigsty.tgz | gzip -d | tar -xC ~
```

</details>


<details><summary>Mange More Nodes</summary>

You can add more nodes to Pigsty with [`nodes.yml`](p-nodes.md#nodes) after installing the meta node with [`infra.yml`](p-infra.md#infra).

```bash
./nodes.yml  -l pg-test      # init 3 nodes of cluster pg-test
```

</details>

<details><summary>Define Postgres Cluster</summary>

You can define a HA Postgres Cluster with streaming replication in a few lines of code:

```yaml
pg-test:
  hosts:
    10.10.10.11: {pg_seq: 1, pg_role: primary} 
    10.10.10.12: {pg_seq: 2, pg_role: replica}
    10.10.10.13: {pg_seq: 3, pg_role: replica}
  vars: 
    pg_cluster: pg-test
```

You can create Postgres with different [roles](d-pgsql.md) by declaring them: primary, replica, standby, delayed, offline, cascade, etc...

</details>


<details><summary>Deploy Databases Clusters</summary>

You can deploy different types of databases & clusters with corresponding playbooks.

* [`pgsql.yml`](p-pgsql.md#pgsql): Deploy HA PostgreSQL clusters.
* [`redis.yml`](p-redis.md#redis): Deploy Redis clusters.
* [`pigsty-matrixdb.yml`](p-pgsql.md#pgsql-matrix): Deploy matrixdb data warehouse (greenplum7).

```bash
./pgsql.yml         -l pg-test      # init 1-primary & 2-replica pgsql cluster
./redis.yml         -l redis-test   # init redis cluster redis-test
./pigsty-matrixdb.yml -l mx-*         # init MatrixDB cluster mx-mdw,mx-sdw .....
```

</details>




## About

> Pigsty (/ˈpɪɡˌstaɪ/) is the abbreviation of "PostgreSQL In Graphic STYle."

Author: [Vonng](https://vonng.com/en) ([rh@vonng.com](mailto:rh@vonng.com))

License: [Apache 2.0 License](https://github.com/Vonng/Capslock/blob/master/LICENSE)

Beian: [浙ICP备15016890-2号](https://beian.miit.gov.cn/)
