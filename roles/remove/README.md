# Remove (Ansible role)

Remove pgsql cluster/instance

* Deregister cluster/instance from infrastructure
  * Prometheus Static Monitor Targets
  * Grafana Datasource
  * HAProxy Admin Page Index Entry 

* Remove service
  * haproxy
  * vip-manager

* Remove monitor service
  * pg_exporter
  * pgbouncer_exporter
  * node_exporter
  * promtail

* Remove pgbouncer
* Remove postgres
* Remove dcs
  * consul

* Remove postgres data 
* Remove postgres packages


```yaml
---
#--------------------------------------------------------------#
# remove exporter targets from prometheus
#--------------------------------------------------------------#
- import_tasks: prometheus.yml
  tags: [ prometheus , register ]

#--------------------------------------------------------------#
# remove pgsql datasource from grafana
#--------------------------------------------------------------#
- import_tasks: grafana.yml
  tags: [ grafana , register ]

#--------------------------------------------------------------#
# remove haproxy index from nginx
#--------------------------------------------------------------#
- import_tasks: nginx.yml
  tags: [ nginx , register ]

#--------------------------------------------------------------#
# remove service (haproxy, vip)
#--------------------------------------------------------------#
- import_tasks: service.yml
  tags: [ service ]

#--------------------------------------------------------------#
# remove monitor
#--------------------------------------------------------------#
- import_tasks: monitor.yml
  tags: [ monitor ]

#--------------------------------------------------------------#
# remove pgbouncer
#--------------------------------------------------------------#
- import_tasks: pgbouncer.yml
  tags: [ pgbouncer ]

#--------------------------------------------------------------#
# remove postgres
#--------------------------------------------------------------#
- import_tasks: postgres.yml
  tags: [ postgres ]

#--------------------------------------------------------------#
# remove dcs
#--------------------------------------------------------------#
- import_tasks: dcs.yml
  tags: [ dcs ]

#--------------------------------------------------------------#
# remove data
#--------------------------------------------------------------#
- import_tasks: pgdata.yml
  when: rm_pgdata|bool
  tags: [ pgdata ]

#--------------------------------------------------------------#
# remove packages
#--------------------------------------------------------------#
- import_tasks: pgpkgs.yml
  when: rm_pgpkgs|bool
  tags: [ pgpkgs ]

...
```