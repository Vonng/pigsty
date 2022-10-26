# Introduction

> Different users have different concerns. If you encounter problems, you are welcome to check the [FAQ](s-faq.md), submit an [Issue](https://github.com/Vonng/pigsty/issues/new), or ask the [Community](community.md) for help.



## Beginners

Beginners can visit the Pigsty demo site: [http://demo.pigsty.cc](http://demo.pigsty.cc) for a quick glance.

There are several [data applications](t-application.md) that are built upon Pigsty to illustrate this distribution: [`pglog`](http://demo.pigsty.cc/d/pglog-overview), [`covid`](http://demo.pigsty.cc/d/covid-overview), [`isd`](http://demo.pigsty.cc/d/isd-overview), [`dbeng`](http://demo.pigsty.cc/d/dbeng-overview), [`worktime`](http://demo.pigsty.cc/d/worktime-query). 

You can also deploy SaaS software with [docker](t-docker.md) and get production-grade durability with an external pigsty database.



## Developer

Developers are more concerned about the fastest way to [download](d-prepare.md#software-download), [install](s-install.md) and [access](c-service.md#access) the database, please refer to [Installation](s-install.md).

Pigsty aims at simplicity: you can launch pigsty on fresh CentOS 7.8 nodes with one command [without](t-offline.md) Internet Access.

Pigsty provides  [Vagrant](d-sandbox.md#local-sandbox) & [Terraform](d-sandbox.md#cloud-sandbox) templates for pulling up 4 VMs with one click to deploy a [sandbox](d-sandbox.md.md) on a local x86 laptop/PC or cloud. Users can also [prepare](d-prepare.md) VMs, cloud VMs, or physical machines for the standard [deployment](d-deploy.md) process.

The user can [access](c-service.md#access) database [service](c-service.md) through connstr, and perform essential operation tasks with [SOP](r-sop.md).

For a deeper understanding of Pigsty's design and architecture, you can refer to the [concept](c-concept.md) chapter.

* [Architecture](c-arch.md)
* [Infrastructure](c-infra.md)
* [Meta Node](c-nodes.md#meta) & [Node](c-nodes.md#node)
* [PGSQL Cluster](c-pgsql.md)
* [PGSQL Service](c-service.md#service) / [PGSQL Access](c-service.md#access)
* [PGSQL Privilege](c-privilege.md#privilege) / [PGSQL Authentication](c-privilege.md#authentication)
* [PGSQL Biz User](c-pgdbuser.md#user) / [PGSQL BIZ DB](c-pgdbuser.md#database)



## Operators

Operators are more concerned with the details of the deployment. The following tutorials provide the details of Pigsty's installation and deployment.

   * [Pigsty Deployment](d-deploy.md)
   * [Pigsty Preparation](d-prepare.md)
   * [Offline Installation](t-offline.md)
   * [Infra Init](p-infra.md)
   * [PostgreSQL Init](p-pgsql.md)
   * [Redis Init](p-redis.md)

The tutorial [Grafana Backend Database Upgrade](t-grafana-upgrade.md) shows a complete and representative example of preparing a Postgres cluster exclusively for Grafana.





## DBA

DBAs are usually more concerned with the usage of monitoring systems and the specific ways in which they are maintained daily.

DBAs are more concerned with the usage of monitoring systems and the way of daily maintenance.

#### Monitoring System Tutorial

- [Introduction of Monitoring Metrics](m-metric.md)
- [Introduction of Monitoring Dashboard](m-dashboard.md)
- [Introduction of Alerting System](r-alert.md)
- [Service Discovery Mechanism](m-discovery.md)
- [Analysis of CSVLOG](t-application.md#PGLOG-CSVLOG-Sample-Analysis)


#### Daily maintenance management

- [Cluster Create/Expand](r-sop.md#Case-1-Cluster-Create-and-Expand)
- [Cluster Destruction/Downsize](r-sop.md#Case-2-Cluster-Destruction-and-Downsize)
- [Cluster Config Change/Restart](r-sop.md#Case-3-Cluster-Config-Change-and-Restart)
- [Create PGSQL BIZ User](r-sop.md#Case-4-Create-PGSQL-Biz-User)
- [Create PGSQL BIZ DB](r-sop.md#Case-5-Create-PGSQL-BIZ-DB)
- [Apply PGSQL HBA](r-sop.md#Case-6-APPLY-PGSQL-HBA)
- [PGSQL LB Traffic Control](r-sop.md#Case-7-PGSQL-LB-Traffic-Control)
- [PGSQL Role Adjustment](r-sop.md#Case-8-PGSQL-Role-Adjustment)
- [Monitor Targets](r-sop.md#Case-9-Monitor-Targets)
- [Cluster Switchover](r-sop.md#Case-10-Cluster-Switchover)
- [Reset Component](r-sop.md#Case-11-Reset-Component)
- [Switching DCS Servers](r-sop.md#Case-12-Switching-DCS-Servers)



## Professional

For professional users (deep customization, secondary development), Pigsty provides a rich [config entry](v-config.md#Config-entry) with a customization interface.
