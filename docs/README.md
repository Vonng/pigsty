# Pigsty

## Pigsty v1.4.0 Documentation

**Battery-Included Open-Source PostgreSQL Distribution**

> Latest Version: [1.4.0](https://github.com/Vonng/pigsty/releases/tag/v1.4.0)  |  [Github Repo](https://github.com/Vonng/pigsty) | [Demo](http://demo.pigsty.cc)
>
> Documentation: [EN Docs](https://pigsty.cc/) | [中文文档](https://pigsty.cc/#/zh-cn/) | [Github Pages](https://vonng.github.io/pigsty/#/)



## What is Pigsty?

* [**Battery-Included**](#Distribution) Distribution: PostgreSQL, PostGIS, TimescaleDB, Citus, even Redis, United in One!
* [**Unparalleled Monitoring**](#Observability): Grafana, Prometheus, Loki, AlertManager, bring the ultimate observability!
* [**High-Available**](#High-Available): Auto-Piloting Postgres with idempotent instances & services, self-healing from hardware failures!
* [**Infra as Data**](#infra-as-data): Describe & Create: Primary/Replica/Standby/Delayed/Offline/Cascade/Citus/Greenplum in minutes!
* [**Ubiquitous**](#Ubiquitous): Prod env or 1C1G VM sandbox with vagrant/terraform deployed with one click!
* [**Versatile**](#versatile):  Databases management or host monitoring. Supporting SaaS or developing data apps.
* [**Open Source & Free**](#Specification): 50% - 80% cost saving versus Cloud RDS. Proven in real-world, large-scale env.

[![](_media/WHAT_EN.svg)](docs/s-feature.md)

Check [Features](docs/s-feature.md) & [Highlights](#highlights) for Detail.



## TL; DR

Get a new Linux x86_64 CentOS 7.8 node. with nopass `sudo` & `ssh` access, then:

```bash
bash -c "$(curl -fsSL http://download.pigsty.cc/get)"  # get latest pigsty source
cd ~/pigsty && ./configure                             # pre-check and config templating 
./infra.yml                                            # install pigsty on current node
```

Now you have a battery-included Postgres on port **5432**, and infra web services available on port **80**.

Check [Installation](docs/s-install.md) & [Demo](http://demo.pigsty.cc) for details.

<details><summary>Download Packages Directly</summary>

Pigsty source & software packages can be downloaded directly via `curl` in case of no Internet connection:

```bash
curl -SL https://github.com/Vonng/pigsty/releases/download/v1.4.0/pkg.tgz -o /tmp/pkg.tgz
curl -SL https://github.com/Vonng/pigsty/releases/download/v1.4.0/pigsty.tgz | gzip -d | tar -xC
```

</details>


<details><summary>Mange More Nodes</summary>

You can add more nodes to Pigsty with [`nodes.yml`](p-nodes.md#nodes) after meta node is installed with [`infra.yml`](p-infra.md#infra).

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

* [`pgsql.yml`](p-pgsql.md#pgsql): Deploy PostgreSQL HA clusters.
* [`redis.yml`](p-redis.md#redis): Deploy Redis clusters.
* [`pgsql-matrix.yml`](p-pgsql.md#pgsql-matrix): Deploy matrixdb data warehouse (greenplum7).

```bash
./pgsql.yml         -l pg-test      # init 1-primary-2-replica pgsql cluster
./redis.yml         -l redis-test   # init redis cluster redis-test
./pigsty-matrix.yml -l mx-*         # init MatrixDB cluster mx-mdw,mx-sdw .....
```

</details>





## Highlights


### Battery-Included PostgreSQL Distribution

> Just like RedHat for Linux!

Packaging the latest PostgreSQL kernel & TimescaleDB, PostGIS, Citus, and hundreds of extensions, all battery-included!

It Also ships infrastructure components: Grafana, Prometheus, Loki, Ansible, Docker,… can be used as a runtime for other databases & applications.

It also includes common tools for data analysis: Jupyter, ECharts, Grafana, PostgREST, and Postgres, which can be used as a low-code data app development IDE, too.

![](_media/ARCH.svg)



### Observability

> You can't manage you don't measure

Unparalleled monitoring system with 30+ dashboards & 1200+ metrics. Just bring the ultimate observability for you!

Pigsty comes with a professional-grade PostgreSQL monitoring system specially designed for large-scale PostgreSQL cluster management, which supports: PGSQL monitoring, Redis monitoring, Nodes monitoring & self-monitoring.

It is built upon popular open-source components such as Prometheus & Grafana. There's no vendor locking, and the infra can be easily reused for other purposes, e.g.: data-visualization platforms.

![](_media/overview-monitor.jpg)


### High-Available

> Auto-Piloting & Self-Healing

**High** **Available** PostgreSQL cluster. Idempotent instances & services, self-healing from hardware failures.

The clusters created by Pigsty are **distributive** HA clusters powered by Patroni & HAProxy. Each instance is idempotent from the application's point of view. As long as any instance in the cluster survives, the cluster serves.


![](_media/HA-PGSQL.svg)


### Infra as Data

> HashiCorp for Database!

Pigsty follows the philosophy of **"Database as Data"**, just like Kubernetes. Describe the database you want and pull them up in one click.

You can create a common primary-replica replication PGSQL cluster with several lines. And assign different roles: primary, replica, standby, offline, delayed, cascade.

You can also create a horizontal sharding cluster with Citus or deploy a time-series data warehouse MatrixDB. Redis standalone/sentinel/cluster are also supported!

```yaml
pg-test:
  hosts:
    10.10.10.11: {pg_seq: 1, pg_role: primary}
    10.10.10.12: {pg_seq: 2, pg_role: replica}
    10.10.10.13: {pg_seq: 3, pg_role: replica}
  vars: 
    pg_cluster: pg-test
    vip_address: 10.10.10.3
```

![](_media/interface.jpg)


</details>

<details>
<summary>Example of Redis Native Cluster</summary>

```yaml
redis-test:
  hosts:
    10.10.10.11:
      redis_node: 1
      redis_instances: { 6501 : {} ,6502 : {} ,6503 : {} ,6504 : {} ,6505 : {} ,6506 : {} }
    10.10.10.12:
      redis_node: 2
      redis_instances: { 6501 : {} ,6502 : {} ,6503 : {} ,6504 : {} ,6505 : {} ,6506 : {} }
  vars:
    redis_cluster: redis-test           # name of this redis 'cluster'
    redis_mode: cluster                 # standalone,cluster,sentinel
    redis_max_memory: 64MB              # max memory used by each redis instance
    redis_mem_policy: allkeys-lru       # memory eviction policy

```

</details>

<details>
<summary>Example of MatrixDB Data Warehouse</summary>

```yaml
#----------------------------------#
# cluster: mx-mdw (gp master)
#----------------------------------#
mx-mdw:
  hosts:
    10.10.10.10: { pg_seq: 1, pg_role: primary , nodename: mx-mdw-1 }
  vars:
    gp_role: master          # this cluster is used as greenplum master
    pg_shard: mx             # pgsql sharding name & gpsql deployment name
    pg_cluster: mx-mdw       # this master cluster name is mx-mdw
    pg_databases:
      - { name: matrixmgr , extensions: [ { name: matrixdbts } ] }
      - { name: meta }
    pg_users:
      - { name: meta , password: DBUser.Meta , pgbouncer: true }
      - { name: dbuser_monitor , password: DBUser.Monitor , roles: [ dbrole_readonly ], superuser: true }

    pgbouncer_enabled: true                # enable pgbouncer for greenplum master
    pgbouncer_exporter_enabled: false      # enable pgbouncer_exporter for greenplum master
    pg_exporter_params: 'host=127.0.0.1&sslmode=disable'  # use 127.0.0.1 as local monitor host

#----------------------------------#
# cluster: mx-sdw (gp master)
#----------------------------------#
mx-sdw:
  hosts:
    10.10.10.11:
      nodename: mx-sdw-1        # greenplum segment node
      pg_instances:             # greenplum segment instances
        6000: { pg_cluster: mx-seg1, pg_seq: 1, pg_role: primary , pg_exporter_port: 9633 }
        6001: { pg_cluster: mx-seg2, pg_seq: 2, pg_role: replica , pg_exporter_port: 9634 }
    10.10.10.12:
      nodename: mx-sdw-2
      pg_instances:
        6000: { pg_cluster: mx-seg2, pg_seq: 1, pg_role: primary , pg_exporter_port: 9633  }
        6001: { pg_cluster: mx-seg3, pg_seq: 2, pg_role: replica , pg_exporter_port: 9634  }
    10.10.10.13:
      nodename: mx-sdw-3
      pg_instances:
        6000: { pg_cluster: mx-seg3, pg_seq: 1, pg_role: primary , pg_exporter_port: 9633 }
        6001: { pg_cluster: mx-seg1, pg_seq: 2, pg_role: replica , pg_exporter_port: 9634 }
  vars:
    gp_role: segment               # these are nodes for gp segments
    pg_shard: mx                   # pgsql sharding name & gpsql deployment name
    pg_cluster: mx-sdw             # these segment clusters name is mx-sdw
    pg_preflight_skip: true        # skip preflight check (since pg_seq & pg_role & pg_cluster not exists)
    pg_exporter_config: pg_exporter_basic.yml                             # use basic config to avoid segment server crash
    pg_exporter_params: 'options=-c%20gp_role%3Dutility&sslmode=disable'  # use gp_role = utility to connect to segments
```

</details>




### Ubiquitous

> Local **sandbox** or multi-cloud deployment, It's all the same!

Pigsty is designed for large-scale production usage but can also be operational on a local 1C1G VM node.

You can run the complete 4-node sandbox on your laptop with vagrant with one command `make up`. Or prepare cloud ECS/VPC with Terraform with the same procedure.

Everything is described in the `pigsty.yml` config file, it's the only difference between different envs: prod, staging/UAT, dev/test sandbox.

![](_media/SANDBOX.gif)





### Versatile

> Data apps, SaaS, Database & Host monitoring, Analysis or Visualization, it's all your choice!

#### SaaS with Docker

Pigsty has docker installed on meta nodes by default. You can pull up all kinds of SaaS applications with one command： Gitlab, Jira, Confluence, Mastodon, Discourse, Odoo, Kingdee, etc...

You can also pull up stateless parts and use external databases by changing their connection string to acquire production-grade durability.

Other handy tools such as Jupyter lab server, PGWeb CLI tools, PGAdmin4, pgbadger, ByteBase, and PostgREST can also be served with docker. Check [Tutorial: Docker Applications](docs/t-docker.md) for detail.

#### Analysis

Pigsty ships with handy tools such as Jupyterlab, PostgreSQL, Grafana, and ECharts. Which is great for data analysis & visualization.

You can turn pigsty sandbox into an IDE for making data-intensive applications and demos: Processing data with SQL & Python, Backend API auto-gen with PostGREST. Visualize with Grafana & ECharts.

Pigsty comes with some example apps:  [`covid`](http://demo.pigsty.cc/d/covid-overview) for covid-19 data visualization and [`isd`](http://demo.pigsty.cc/d/isd-overview) for visualizing global surface weather station data.

* PG CSV Log Sample Analysis: [`pglog`](http://demo.pigsty.cc/d/pglog-overview)
* COVID-19 WHO Data Query [`covid`](http://demo.pigsty.cc/d/covid-overview)
* NOAA ISD Surface Station Weather Data Query: [`isd`](http://demo.pigsty.cc/d/isd-overview)
* DB-Engine Popularity Trending [`dbeng`](http://demo.pigsty.cc/d/dbeng-overview)

[![](_media/overview-covid.jpg)](http://demo.pigsty.cc/d/covid-overview)

Check [Tutorial: Pigsty Applications](t-application.md) for detail.




## About

> Pigsty (/ˈpɪɡˌstaɪ/) is the abbreviation of "PostgreSQL In Graphic STYle"

Author: [Vonng](https://vonng.com/en) ([rh@vonng.com](mailto:rh@vonng.com))

License: [Apache 2.0 License](https://github.com/Vonng/Capslock/blob/master/LICENSE)

Beian: [浙ICP备15016890-2号](https://beian.miit.gov.cn/)