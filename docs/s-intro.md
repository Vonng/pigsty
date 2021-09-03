# Introduction

## Beginners

Users new to PostgreSQL and Pigsty, data analysts, data developers, 
can get first impressions from the public Pigsty demo: [http://demo.pigsty.cc](http://demo.pigsty.cc).

Two built-in data [applications](t-application.md) that build upon pigsty:  
  * WHO COVID-19 Dashboards: [`covid`](http://demo.pigsty.cc/d/covid-overview)
  * NOAA ISD Data Visualization: [`isd`](http://demo.pigsty.cc/d/isd-overview)


## DEV

Developer cares about how to get a viable database ASAP, and how to access it.

Pigsty deliver it's [services](c-service.md) through connect string. 
User can [access](c-access.md) it via PGURL.

Developers familiar with terminal could try [installing](s-install.md) Pigsty on your own computers.
Pigsty is optimized for accessibility , which can be installed with one-command on a fresh new CentOS 7 node.

If no vm nodes available, Pigsty [sandbox](s-sandbox.md) could help with it.
The sandbox is local Virtualbox VM managed by vagrant that runs entirely on your laptop.
You can also [prepare](t-prepare.md) your own VMs, cloud VMs, or bare-metal nodes for standard [deployment](t-deploy.md).

Once installed. Check **Tutorial** about [basic operations](t-operation.md) & [access the database](c-access.md) to begin your jounary./

If you want to go deeper into the design and architecture of Pigsty itself, you can refer to the topics in the chapter **Concepts**.
* [Architecture](c-arch.md)
* [Entity Model](c-entity.md)
* [Services](c-service.md)
* [Access](c-access.md)
* [Privilege](c-privilege.md)
* [Authentication](c-auth.md)
* [Configuration](c-config.md)
* [Business User](c-user.md)
* [Business Database](c-database.md)

## OPS

Operations personnel are more concerned with the details of implementing the deployment, and the following tutorial will cover the details of Pigsty installation and deployment.

* [Pigsty Deployment](t-deploy.md)
* [Preparation](t-prepare.md)
* [Offline Installation](t-offline.md)
* [Init Infrastructure](p-infra.md)
* [Init PgSQL Clusters](p-pgsql.md)

Besides, the tutorial [Upgrade Grafana Backend Database](t-grafana-upgrade.md) shows a complete example of 
provisioning a new database cluster/user/database that is dedicated for grafana.


## DBA

DBAs are usually more concerned with the usage of monitoring systems and the specific ways in which they are maintained on a daily basis.

#### Monitoring System Tutorial
* Monitoring System Architecture
* [Metrics](m-metric.md)
* [Dashboards](m-dashboard.md)
* [Alerting System](r-alert.md)
* [Service Discovery](m-discovery.md)
* [Logging Components](t-logging.md)
* [Analysis CSV logs](t-log-analysis.md)
* Optimize Slow Queries
* Symptom of common Failures

#### Daily maintenance management
* Database cluster expansion and contraction
* [Database cluster offline](p-pgsql-remove.md)
* [create new business database](p-pgsql-createdb.md)
* [Create new business user](p-pgsql-createuser.md)
* [Backup and restore](t-backup.md)
* Change HBA rules

## PRO

For professional users (deep customization), 
Pigsty provides rich configuration items and customization interfaces.

* [Configure Pigsty](v-config.md#config-entries)
* [Customize Patroni template](t-patroni-template.md)
* [Customize database template](t-customize-template.md)

Almost all configuration items are configured with reasonable default values and can be used without modification. 
Pro users can refer to the [configuration guide](v-config.md) to adjust it by themselves as needed.
