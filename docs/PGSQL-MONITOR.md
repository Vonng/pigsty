# Monitor Existing Postgres

> How to use Pigsty to monitor existing PostgreSQL instances?

For existing PostgreSQL instances, such as RDS, or homemade PostgreSQL that is not managed by Pigsty,
 some additional configuration is required if you wish to monitoring them with Pigsty


```
------ infra ------
|                 |
|   prometheus    |            v---- pg-foo-1 ----v
|       ^         |  metrics   |         ^        |
|   pg_exporter <-|------------|----  postgres    |
|   (port: 20001) |            | 10.10.10.10:5432 |
|       ^         |            ^------------------^
|       ^         |                      ^
|       ^         |            v---- pg-foo-2 ----v
|       ^         |  metrics   |         ^        |
|   pg_exporter <-|------------|----  postgres    |
|   (port: 20002) |            | 10.10.10.11:5433 |
-------------------            ^------------------^
```


## TL; DR

1. Setup the monitoring schema, user and privilege on target.

2. Declare the cluster in the inventory.

```yaml
remote:
    hosts:          # a group contains any nodes that have prometheus enabled (infra nodes)
        10.10.10.10:    # k,v format, where k is distinct local port that is not used,
            pg_exporters: # list all remote instances here, alloc a unique unused local port as k
                20001: { pg_cluster: pg-foo, pg_seq: 1, pg_host: 10.10.10.10 }
                20004: { pg_cluster: pg-foo, pg_seq: 2, pg_host: 10.10.10.11 }
                20002: { pg_cluster: pg-bar, pg_seq: 1, pg_host: 10.10.10.12 }
                20003: { pg_cluster: pg-bar, pg_seq: 1, pg_host: 10.10.10.13 }
```

3. Execute the playbook against the cluster: `. /pgsql-monitor.yml -l monitor`.

