# Pigsty

## Pigsty v1.4.0 Documentation

**Battery-Included Open-Source PostgreSQL Distribution**

> Latest Version: [1.4.0](https://github.com/Vonng/pigsty/releases/tag/1.4.0)  |  [Github Repo](https://github.com/Vonng/pigsty) | [Public Demo](http://home.pigsty.cc)
>
> Documentation: [En Docs](https://pigsty.cc/) | [中文文档](https://pigsty.cc/#/zh-cn/) | [Github Pages](https://vonng.github.io/pigsty/#/)

## What is Pigsty?

[![](_media/WHAT_EN.svg)](s-feature.md)

* **Battery-Included** PostgreSQL [Distribution](s-feature.md#Distribution) with popular extensions & Infra Components & Data Science Tools.
* **Unparalleled Monitoring** & Auto-Piloting **HA** PG Clusters & Multiple DB support: Redis/Citus/MatrixDB
* **Handy Toolbox** for Database Deployment & Administration. Sandbox & Multi-cloud with Vagrant/Terraform. 
* **Thrifty alternative to Cloud RDS**, up to 80% cost saving! Proven in real-world prod env for long time.

Check [Highlights](s-feature.md) for more details about Pigsty Features!



## Quick Start

Run on fresh Linux x86_64 CentOS 7.8.2003 node with ssh root access:

```bash
bash -c "$(curl -fsSL http://download.pigsty.cc/get)" # Download
cd ~/pigsty && ./configure                            # Configure
make install                                          # Install
```

Check [Installation](s-install.md) for more details.

[![](_media/HOW_EN.svg)](s-install.md)




## Highlights


### Battery-Included PostgreSQL Distribution

> RedHat for Linux!

Packaging the latest PostgreSQL kernel & TimescaleDB, PostGIS, Citus, and hundreds of extensions, all battery-included!
Shipping infrastructure components: Grafana, Prometheus, Loki, Ansible, Docker,… Runtime for other databases & applications
Common tools for data analysis: Jupyter, ECharts, Grafana, PostgREST, Postgres. Can be used as low-code data app development IDE.


**Distribution** refers to the overall solution consisting of a kernel and peripheral software packages. For example, Linux is an OS kernel, while RedHat, Debian, and SUSE are OS distributions based on Linux kernel.

Pigsty is an entire **solution** for using postgres in your production environment. It will setup everything for your with one-click:
creating & scaling clusters, switchover & auto failover. manage databases, users, roles, hbas, schemas, hbas with configuration, connection pooling, load balancing, monitoring & logging & alerting, service discovery, etc...

![](_media/ARCH.svg)


### Monitoring & HA Database Solution

> Auto-Pilot for Postgres!

The clusters created by Pigsty are **distributive** HA postgres database cluster powered by Patroni & HAProxy.
As long as any instance in the cluster survives, the cluster serves. Each instance is idempotent from application's point of view.

PostgreSQL is the most advanced open source relational database, but its ecosystem lacks a open source monitoring system which is **good enough**. Pigsty aims to solve this by delivering the best **Open Source Monitoring Solution for PostgreSQL**.

![](_media/HA-PGSQL.svg)

Pigsty comes with a professional-grade PostgreSQL monitoring system which is specially designed for large-scale postgres cluster management. Including 1200+ metrics, 20+ Dashboards, thousands of panels which covering detailed information from the biggest overview to the smallest individual object. Which brings irreplaceable value for professional users.

Pigsty consists of three monitor apps: `pgsql`, which focus on time-series metrics. `pgcat`, which explores database catalog directly. And `pglog`, which collect realtime logs from postgres, patroni and pgbouncer, and visualize csvlog samples. More will come later.

Pigsty is build upon popular open source components such as Prometheus & Grafana. There's no vendor locking, and the infra can be easily reused for other purpose.

![](_media/overview-monitor.jpg)


### Infra as Data

> HashiCorp for Databases!


PostgreSQL cluster comes before monitoring system. That's why pigsty is shipping with a handy **Provisioning Solution**.
It allows you to create, update, scale, and manage your postgres cluster in kubernetes style: Describe what your want and pigsty will just do that for ya.

For example, creating a one-leader-with-two-replica cluster `pg-test` on three nodes requires only a few lines of configuration, and one command `pgsql.yml -l pg-test` to instantiate it.

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



### Deploy Everywhere

> Alternative for Linux!

Pigsty is designed for real world production env with hundreds of high spec nodes, but it can also run inside a tiny 1C|1GB vm node.
Which is great for developing, testing, demonstrating, data analysing & visualizing and other purposes.

Pigsty sandbox can be pulled up with one command on your Macbook, powered by virtualbox & vagrant. or created upon cloud vm with terraform.
There are two specs of sandbox: 1 node (the default) and 4 node (full sandbox)

![](docs/_media/SANDBOX.gif)


### Versatile

> Monitoring, Deploying, SaaS, Analysis, It's all your choice!

Pigsty ships with handy tools such as Jupyterlab, PostgreSQL, Grafana, Echarts. Which is great for data analysis & visualization.
You can turn pigsty sandbox into an IDE for making data-intensive applications and demos: Processing data with SQL & Python, Visualize with Grafana & Echarts.

Pigsty comes with two example apps:  [`covid`](http://demo.pigsty.cc/d/covid-overview) for covid-19 data visualization, and [`isd`](http://demo.pigsty.cc/d/isd-overview) for visualizing global surface weather station data.

![](_media/overview-covid.jpg)

![](_media/overview-isd.jpg)



## About

> Pigsty (/ˈpɪɡˌstaɪ/) is the abbreviation of "PostgreSQL In Graphic STYle"

Author: [Vonng](https://vonng.com/en) ([rh@vonng.com](mailto:rh@vonng.com))

License: [Apache 2.0 License](https://github.com/Vonng/Capslock/blob/master/LICENSE)

Beian: [浙ICP备15016890-2号](https://beian.miit.gov.cn/)