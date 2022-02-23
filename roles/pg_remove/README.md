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
  * node_exporter
  * promtail

* Remove pgbouncer
* Remove postgres
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

### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Remove pgsql target from prometheus	TAGS: [prometheus, register, remove]
Remove grafana datasource on meta node	TAGS: [grafana, register, remove]
Remove haproxy upstream from nginx	TAGS: [nginx, register, remove]
Remove haproxy url location from nginx	TAGS: [nginx, register, remove]
Reload nginx to remove haproxy upstream	TAGS: [nginx, register, remove]
Remove cluster service from consul	TAGS: [consul_registry, haproxy, remove, service]
Remove haproxy service from consul	TAGS: [consul_registry, haproxy, remove, service]
Reload consul to dereigster haproxy	TAGS: [haproxy, remove, service]
Stop and disable haproxy load balancer	TAGS: [haproxy, remove, service]
Stop and disable vip-manager	TAGS: [remove, service, vip]
Remove pg_exporter service from consul	TAGS: [consul_registry, monitor, pg_exporter, remove]
Reload consul to dereigster pg_exporter	TAGS: [monitor, pg_exporter, remove]
Stop and disable pg_exporter service	TAGS: [monitor, pg_exporter, remove]
Remove pgbouncer_exporter service from consul	TAGS: [consul_registry, monitor, pgbouncer_exporter, remove]
Reload consul to dereigster pgbouncer_exporter	TAGS: [monitor, pgbouncer_exporter, remove]
Stop and disable pgbouncer_exporter service	TAGS: [monitor, pgbouncer_exporter, remove]
Remove node_exporter service from consul	TAGS: [consul_registry, monitor, node_exporter, remove]
Reload consul to dereigster node_exporter	TAGS: [monitor, node_exporter, remove]
Stop and disable node_exporter service	TAGS: [monitor, node_exporter, remove]
Stop and disable promtail service	TAGS: [monitor, promtail, remove]
Remove pgbouncer service from consul	TAGS: [consul_registry, pgbouncer, remove]
Reload consul to dereigster pgbouncer	TAGS: [pgbouncer, remove]
Stop and disable pgbouncer service	TAGS: [pgbouncer, remove]
Get actuall pg_role	TAGS: [postgres, remove]
Get pg_role from result	TAGS: [postgres, remove]
Set pg_role if applicable	TAGS: [postgres, remove]
Remove follower postgres service from consul	TAGS: [consul_registry, postgres, remove]
Remove follower patroni service from consul	TAGS: [consul_registry, postgres, remove]
Reload follower consul to dereigster postgres & patroni	TAGS: [postgres, remove]
Stop and disable follower patroni service	TAGS: [postgres, remove]
Stop and disable follower postgres service	TAGS: [postgres, remove]
Force follower postgres shutdown	TAGS: [postgres, remove]
Remove leader postgres service from consul	TAGS: [consul_registry, postgres, remove]
Remove leader patroni service from consul	TAGS: [consul_registry, postgres, remove]
Reload leader consul to dereigster postgres & patroni	TAGS: [postgres, remove]
Stop and disable leader patroni service	TAGS: [postgres, remove]
Stop and disable leader postgres service	TAGS: [postgres, remove]
Force leader postgres shutdown	TAGS: [postgres, remove]
Remove consul metadata about pgsql cluster	TAGS: [postgres, remove]
Remove postgres data	TAGS: [pgdata, remove]
Remove pg packages	TAGS: [pgpkgs, remove]
Remove pg extensions	TAGS: [pgpkgs, remove]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

no default variables