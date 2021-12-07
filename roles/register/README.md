# Register (Ansible role)

Register pgsql cluster/instance to infrastructure
* Register/Refresh consul service 
* Register prometheus targets
* Register grafana datasources
* Register postgres metadb records (TBD)

### Tasks

[tasks/main.yml](tasks/main.yml)


```yaml
---
Register postgres service to consul	TAGS: [pgsql, postgres, register, register_consul, register_consul_postgres]
Register patroni service to consul	TAGS: [pgsql, postgres, register, register_consul, register_consul_patroni]
Register pgbouncer service to consul	TAGS: [pgbouncer, pgsql, register, register_consul, register_consul_pgbouncer]
Register node-exporter service to consul	TAGS: [node_exporter, pgsql, register, register_consul, register_consul_node_exporter]
Register pg_exporter service to consul	TAGS: [pg_exporter, pgsql, register, register_consul, register_consul_pg_exporter]
Register pgbouncer_exporter service to consul	TAGS: [pgbouncer_exporter, pgsql, register, register_consul, register_consul_pgbouncer_exporter]
Register haproxy (exporter) service to consul	TAGS: [haproxy, pgsql, register, register_consul, register_consul_haproxy_exporter]
Register cluster service to consul	TAGS: [haproxy, pgsql, register, register_consul, register_consul_cluster_service]
Reload consul to finish register	TAGS: [pgsql, register, register_consul, register_consul_reload]
Register pgsql instance as prometheus target	TAGS: [pgsql, register, register_prometheus]
Render datasource definition on meta node	TAGS: [pgsql, register, register_grafana]
Load grafana datasource on meta node	TAGS: [pgsql, register, register_grafana]
Create haproxy config dir resource dirs on /etc/pigsty	TAGS: [pgsql, register, register_nginx]
Register haproxy upstream to nginx	TAGS: [pgsql, register, register_nginx]
Register haproxy url location to nginx	TAGS: [pgsql, register, register_nginx]
Reload nginx to finish haproxy register	TAGS: [pgsql, register, register_nginx]
...
```


### Default variables

No default variables.


### Caveats

Patroni's (v2.1.2) metrics path can not be adjusted (hard coded as `/metrics`).
If you are using `exporter_metrics_path` other than that, beware of it.