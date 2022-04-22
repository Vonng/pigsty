# Introduction

> Different users have different concerns. 



## Beginners

Beginners can visit the Pigsty demo site: [http://demo.pigsty.cc](http://demo.pigsty.cc) for an overview of its features.

Two [data applications](t-application.md) based on Pigsty are built into the Pigsty demo.

  * WHO COVID-19 Dashboards: [`covid`](http://demo.pigsty.cc/d/covid-overview)

  * NOAA ISD Data Visualization: [`isd`](http://demo.pigsty.cc/d/isd-overview)



## Developer

Developers are more concerned about the fastest way to [download](d-prepare.md#software-download), [install](s-install.md) and [access](c-service.md#access) the database, please refer to [Installation](s-install.md).

On CentOS 7.8 nodes, Pigsty can be installed in one click [without Internet access](t-offline.md).

Pigsty provides  [Vagrant](d-sandbox.md#local-sandbox) & [Terraform](d-sandbox.md#cloud-sandbox) templates for pulling up 4 VMs with one click to deploy a [sandbox](d-sandbox.md.md) on a local x86 laptop/PC or cloud.

Users can also [prepare](d-prepare.md) VMs, cloud VMs, or physical machines for the standard [deployment](d-deploy.md) process.

The user [accesses](c-service.md#access) the database in Pigsty through a PG connection string.

After deployment, developers can refer to the **Tutorial** to get familiar with [basic management](r-sop.md) and learn how to [access the database](c-service.md#access).

For a deeper understanding of Pigsty's design and architecture, you can refer to the **concept** chapter.

   * [Architecture](c-arch.md)
   * [Entity](c-entity.md)
   * [Config](v-config.md)
   * [PGSQL service](c-service.md#service) and [PGSQL access](c-service.md#access)
   * [PGSQL Privilege](c-privilege.md#privilege) and [PGSQL Auth](c-privilege.md#authentication)
   * [PGSQL user](c-pgdbuser.md#user) with [PGSQL database](c-pgdbuser.md#database)



## Operators

Operators are more concerned with the details of the deployment. The following tutorials provide the details of Pigsty's installation and deployment.

   * [Pigsty deployment](d-deploy.md)
   * [Pigsty preparation](d-prepare.md)
   * [Offline installation](t-offline.md)
   * [Infra init](p-infra.md)
   * [PostgreSQL init](p-pgsql.md)
   * [Redis init](p-redis.md)

The tutorial [Upgrade Grafana](t-grafana-upgrade.md) shows a complete and representative example of building a Postgres cluster exclusively for Grafana.



## DBA

DBAs are more concerned with the usage of monitoring systems and the way of daily maintenance.

#### Monitoring System Tutorial

- [Introduction of Monitoring Metrics](m-metric.md)
- [Introduction of Monitoring Dashboard](m-dashboard.md)
- [Introduction of Alerting System](r-alert.md)
- [Service Discovery Mechanism](m-discovery.md)
- [Analysis of CSVLOG](t-application.md#PGLOG-CSVLOG-Sample-Analysis)


#### Daily maintenance management

- [Cluster Create/Expand](r-sop.md#Case-1：Cluster-Create/Expand)
- [Cluster Destruction/Downsize](r-sop.md#Case-2：Cluster-Destruction/Downsize)
- [Cluster Config Change/Restart](r-sop.md#Case-3：Cluster-Config-Change/Restart)
- [Create PGSQL BIZ User](r-sop.md#Case-4：Create-PGSQL-Biz-User)
- [Create PGSQL BIZ DB](r-sop.md#Case-5：Create-PGSQL-BIZ-DB)
- [Apply PGSQL HBA](r-sop.md#Case-6：APPLY-PGSQL-HBA)
- [PGSQL LB Traffic Control](r-sop.md#Case-7：PGSQL-LB-Traffic-Control)
- [Cluster Role adjustment](r-sop.md#Case-8：PGSQL-Role-Adjustment)
- [Monitoring object adjustment](r-sop.md#Case-9：Monitoring-Targets)
- [Cluster master-slave switch](r-sop.md#Case-10：Cluster-Switchover)
- [Reset component](r-sop.md#Case-11：Reset-Component)
- [Replace Cluster DCS Server](r-sop.md#Case-12：Switching-DCS-Servers)



## Professional

For professional users (deep customization, secondary development), Pigsty provides a rich [config entry](v-config.md#Config-entry) with a customization interface.

Almost all config entries are configured with reasonable default values and can be used without modification. Professional users can refer to the [config entry doc](v-config.md) to tweak it themselves or [customize it](v-pgsql-customize.md) on demand.

