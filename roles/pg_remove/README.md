# PG Remove (Ansible role)

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

* Remove pgbouncer
* Remove postgres
* Remove postgres data 
* Remove postgres packages


```yaml
---
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

### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Remove pgsql target from prometheus	TAGS: [pg-remove, prometheus, register]
Remove grafana datasource on meta node	TAGS: [grafana, pg-remove, register]
Remove haproxy upstream from nginx	TAGS: [nginx, pg-remove, register]
Remove haproxy url location from nginx	TAGS: [nginx, pg-remove, register]
Reload nginx to remove haproxy upstream	TAGS: [nginx, pg-remove, register]
Remove cluster service from consul	TAGS: [consul_registry, haproxy, pg-remove, service]
Remove haproxy service from consul	TAGS: [consul_registry, haproxy, pg-remove, service]
Reload consul to dereigster haproxy	TAGS: [haproxy, pg-remove, service]
Stop and disable haproxy load balancer	TAGS: [haproxy, pg-remove, service]
Stop and disable vip-manager	TAGS: [pg-remove, service, vip]
Remove pg_exporter service from consul	TAGS: [consul_registry, monitor, pg-remove, pg_exporter]
Reload consul to dereigster pg_exporter	TAGS: [monitor, pg-remove, pg_exporter]
Stop and disable pg_exporter service	TAGS: [monitor, pg-remove, pg_exporter]
Remove pgbouncer_exporter service from consul	TAGS: [consul_registry, monitor, pg-remove, pgbouncer_exporter]
Reload consul to dereigster pgbouncer_exporter	TAGS: [monitor, pg-remove, pgbouncer_exporter]
Stop and disable pgbouncer_exporter service	TAGS: [monitor, pg-remove, pgbouncer_exporter]
Stop and disable promtail service	TAGS: [monitor, pg-remove, promtail]
Remove pgbouncer service from consul	TAGS: [consul_registry, pg-remove, pgbouncer]
Reload consul to dereigster pgbouncer	TAGS: [pg-remove, pgbouncer]
Stop and disable pgbouncer service	TAGS: [pg-remove, pgbouncer]
Get actuall pg_role	TAGS: [pg-remove, postgres]
Get pg_role from result	TAGS: [pg-remove, postgres]
Set pg_role if applicable	TAGS: [pg-remove, postgres]
Remove follower postgres service from consul	TAGS: [consul_registry, pg-remove, postgres]
Remove follower patroni service from consul	TAGS: [consul_registry, pg-remove, postgres]
Reload follower consul to dereigster postgres & patroni	TAGS: [pg-remove, postgres]
Stop and disable follower patroni service	TAGS: [pg-remove, postgres]
Stop and disable follower postgres service	TAGS: [pg-remove, postgres]
Force follower postgres shutdown	TAGS: [pg-remove, postgres]
Remove leader postgres service from consul	TAGS: [consul_registry, pg-remove, postgres]
Remove leader patroni service from consul	TAGS: [consul_registry, pg-remove, postgres]
Reload leader consul to dereigster postgres & patroni	TAGS: [pg-remove, postgres]
Stop and disable leader patroni service	TAGS: [pg-remove, postgres]
Stop and disable leader postgres service	TAGS: [pg-remove, postgres]
Force leader postgres shutdown	TAGS: [pg-remove, postgres]
Remove consul metadata about pgsql cluster	TAGS: [pg-remove, postgres]
Remove postgres data	TAGS: [pg-remove, pgdata]
Remove pg packages	TAGS: [pg-remove, pgpkgs]
Remove pg extensions	TAGS: [pg-remove, pgpkgs]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

no default variables