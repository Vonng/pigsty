# Dev Log

## 2021-07-12

* alert panel now links to alertmanager
* add click-able data-link to most graph
* release pg_exporter v0.4.0 (remove beta)
* adjust home & overview & cluster & instance layout

## 2021-07-09

* now comes to the juice part, monitoring dashboard designing
* add links between pgcat & pgsql, e.g table level dashboard
* add a pgcat-query dashboard which aims at pg_stat_statements view
* add alertmanager links on alert timeline panel
* add links to graph, so user can click graphic element and jump to corresponding dashboard
* finish pgsql-queries, and back port to pgsql query



## 2021-07-08

* use [acpgh].pigsty as placeholder, passing `nginx_upstream` via environ, replace http host when provisioning dashboards
* add pgsql-queries dashboard which runs on instance level, focusing on instance pgbouncer queries and rt, table qps, query qps, etc...


## 2021-07-07

* Add baidu netdisk download for mainland China
  百度云盘 链接: https://pan.baidu.com/s/1DZIa9X2jAxx69Zj-aRHoaw 提取码: 8su9
* Grafana static provision have some down-sides: root privileges / can't update home dashboard. I wonder if we could switch to API provisioning instead.
* Use pure python for grafana provisioning `grafana.py`


## 2021-07-06

* Use v1.0.0-alpha1 instead. Since the change are significant, it is not appropriate to use v0.10. 
* Remove the crud haproxy index pages, using grafana table & data links instead 
* At last register by instance may be the easiest way to implement and manage
* Add new role `loki`
* Add new role `promtail`
* Register datasource when create new database with `pgsql-createdb.yml`


## 2021-07-05

* Extract a new role named `register` to handler all interaction between pgsql & infra.
* Extract a new role named `envrion` to setup meta node environment including: ssh, metadb, env vars, etc... 
* Dashboard tags now have hierarchy:  `Pigsty` is the top tier, Application name `PGSQL` `PGLOG` is second tier 
  * `Overview`, `Cluster`, `Instance`,`Database` are filter with `Pigsty` and `<Level>` tags. which means the nav-link can cross multiple applications

## 2021-07-04

* Milestone chart of Pigsty

![](../img/milestone.svg)


## 2021-06-30

* Rough implementation on v0.10.0-alpha1
* Setup environment for admin user (pgpass, pg_service, env vars,)
* Application install script will have environ
* Fix nofile limit on postgres|pgbouncer|patroni
* [Milestone](./milestone.md) planning.


## 2021-06-29

* Remake release system
* Have a draft on application installation standard
* Use 'v' prefixed fully qualified version string
* remove polysh from default pkg (unstable when downloading) 
* remove grafana plugins, since lot's of them were covered in grafana 8.0


## 2021-06-28

* Remake alerting rules 


## 2021-06-25

* Remake infra-rules and pgsql-rules

## 2021-06-23

* Remake PGSQL node


## 2021-06-10

It's time to have an overhaul on monitoring system, which includes:
* Upgrade `pg_exporter` to 0.4.0 , re-write metric definition and add support for PostgreSQL 14  
* Use static file service discovery by default to reduce dependency for monitoring system
* Use static label set (job,cls,ins), remove (svc,role,ip) from labels, Which makes identity immutable
* Redesign entire monitoring system to use new label system and embrace Grafana 8.0
* Using grafana 8.0 new features

## 2021-06-01

Well it's good to write some dev logs.