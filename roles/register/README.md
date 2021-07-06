# Register (Ansible role)

Register pgsql cluster/instance to infrastructure
* Register/Refresh consul service 
* Register prometheus targets
* Register grafana datasources
* Register postgres metadb records (TBD)

```yaml
---
Check necessary variables exists	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
Fetch variables via pg_cluster	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
Set cluster basic facts for hosts	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
Assert cluster primary singleton	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
Setup cluster primary ip address	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
Setup repl upstream for primary	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
Setup repl upstream for replicas	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
Debug print instance summary	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
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
Register haproxy upstream to nginx	TAGS: [pgsql, register, register_nginx]
Register haproxy url location to nginx	TAGS: [pgsql, register, register_nginx]
Reload nginx to finish haproxy register	TAGS: [pgsql, register, register_nginx]
...
```