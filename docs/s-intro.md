# Introduction

> Different users have different concerns. If you encounter problems, you are welcome to check the [FAQ](s-faq.md), submit an [Issue](https://github.com/Vonng/pigsty/issues/new), or ask the [Community](community.md) for help.



## Beginners

Users new to PostgreSQL and Pigsty can visit the Pigsty demo site: [http://demo.pigsty.cc](http://demo.pigsty.cc) for an overview of its features.

Two Pigsty-based [data applications](t-application.md) are built into the Pigsty demo to demonstrate the capabilities of this haircut version.

  * WHO COVID-19 Dashboards: [`covid`](http://demo.pigsty.cc/d/covid-overview)

  * NOAA ISD Data Visualization: [`isd`](http://demo.pigsty.cc/d/isd-overview)



## Developer

Developers are more concerned about the fastest way to [download](d-prepare.md#software-download), [install](s-install.md) and [access](c-service.md#access) the database, please refer to [Quick Start](s-install.md)

Pigsty has been heavily optimized for ease of use, with a one-click installation on the new CentOS 7.8 node [no internet access required](t-offline.md).

Pigsty provides pre-built [Vagrant](d-sandbox.md#local-sandbox) & [Terraform](d-sandbox.md#cloud-sandbox) templates for pulling up 4 VMs with one click to deploy a [sandbox environment](d-sandbox.md.md) on a local x86 laptop/PC or cloud.

Users can also [prepare](d-prepare.md) their own VMs, cloud VMs, or production physical machines for the standard [deployment](d-deploy.md) process.

The database in Pigsty is delivered externally as a [service](c-service.md) and users [access](c-service.md#access) it through a PG connection string.

After deployment, developers can refer to the content in the **Tutorial** to get familiar with [basic management operations](r-sop.md) and understand how to [access the database](c-service.md#access) if they have questions

If you want to go deeper into the design and architecture of Pigsty itself, you can refer to the topics in the chapter **Concepts**.

   * [Architecture](c-arch.md)
   * [Entity Model](c-entity.md)
   * [config](v-config.md)
   * [PGSQL service](c-service.md#service) and [PGSQL access](c-service.md#access)
   * [PGSQL Privilege](c-privilege.md#privilege) and [PGSQL Authentication](c-privilege.md#authentication)
   * [PGSQL business user](c-pgdbuser.md#user) with [PGSQL business database](c-pgdbuser.md#database)



## Operators

Operations staff are more concerned with the details of implementing deployments, and the following tutorial will cover the details of Pigsty installation and deployment.

   * [Pigsty deployment](d-deploy.md)
   * [Pigsty resource preparation](d-prepare.md)
   * [Make offline installer](t-offline.md)
   * [Infrastructure initialization](p-infra.md)
   * [PostgreSQL database initialization](p-pgsql.md)
   * [Redis database initialization](p-redis.md)

The tutorial [Upgrade Grafana backend database](t-grafana-upgrade.md) shows a complete, representative example of putting the above topics into practice by building and using a Postgres database cluster dedicated to Grafana.



## DBA

DBAs are usually more concerned with the usage of monitoring systems and the specific ways in which they are maintained daily.

#### Monitoring System Tutorial

- [Introduction to Monitoring Metrics](m-metric.md)
- [Introduction to Monitoring Panel](m-dashboard.md)
- [Introduction to Alert System](r-alert.md)
- [Service discovery mechanism](m-discovery.md)
- [Analysis of CSV logs](t-application.md#PGLOG)


#### Daily maintenance management

- [Cluster create/expand](r-sop.md#Case-1：Cluster-Create/Expand)
- [Cluster destruction/downsize](r-sop.md#Case-2：Cluster-Destruction/Downsize)
- [Cluster config change/restart](r-sop.md#Case-3：Cluster-Config-Change/Restart)
- [Cluster business user creation](r-sop.md#Case-4：Create-PGSQL-Biz-User)
- [Cluster business database creation](r-sop.md#Case-5：Create-PGSQL-BIZ-DB)
- [Cluster HBA rule adjustment](r-sop.md#Case-6：APPLY-PGSQL-HBA)
- [Cluster Traffic control](r-sop.md#Case-7：PGSQL-LB-Traffic-Control)
- [Cluster Role adjustment](r-sop.md#Case-8：PGSQL-Role-Adjustment)
- [Monitoring object adjustment](r-sop.md#Case-9：Monitoring-Targets)
- [Cluster master-slave switch](r-sop.md#Case-10：Cluster-Switchover)
- [Reset component](r-sop.md#Case-11：Reset-Component)
- [Replace Cluster DCS Server](r-sop.md#Case-12：Switching-DCS-Servers)



## Professional

For professional users (deep customization, secondary development), Pigsty provides a rich [config entry](v-config.md#Config-entry) with a customization interface.

Almost all config entries are configured with reasonable default values and can be used without modification. Professional users can refer to the [config entry doc](v-config.md) to tweak it themselves or [customize it](v-pgsql-customize.md) on demand.

