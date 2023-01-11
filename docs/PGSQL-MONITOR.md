# Monitor Remote Postgres

> How to use Pigsty to monitor remote (existing) PostgreSQL instances?

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

1. Create monitoring schema, user and privilege on target.

2. Declare the cluster in the inventory. For example, assume we want to monitor 'remote' pg-meta & pg-test cluster
   With the name of `pg-foo` and `pg-bar`, we can declare them in the inventory as: 

```yaml
infra:            # infra cluster for proxy, monitor, alert, etc..
  hosts: { 10.10.10.10: { infra_seq: 1 } }
  vars:           # install pg_exporter for remote postgres RDS on a group 'infra'
    pg_exporters: # list all remote instances here, alloc a unique unused local port as k

      20001: { pg_cluster: pg-foo, pg_seq: 1, pg_host: 10.10.10.10 }

      20002: { pg_cluster: pg-bar, pg_seq: 1, pg_host: 10.10.10.11 , pg_port: 5432 }
      20003: { pg_cluster: pg-bar, pg_seq: 2, pg_host: 10.10.10.12 , pg_exporter_url: 'postgres://dbuser_monitor:DBUser.Monitor@10.10.10.12:5432/postgres?sslmode=disable'}
      20004: { pg_cluster: pg-bar, pg_seq: 3, pg_host: 10.10.10.13 , pg_monitor_username: dbuser_monitor, pg_monitor_password: DBUser.Monitor }

```

3. Execute the playbook against the cluster: `bin/pgmon-add <clsname>`.


To remove a remote cluster monitoring target:

```bash
bin/pgmon-rm <clsname>
```