# PGSQL Monitor

> How to use Pigsty to monitor remote (existing) PostgreSQL instances?

----------------

## Overview

Pigsty use modern observability stack for PostgreSQL monitoring:

* Grafana for metrics visualization and PostgreSQL datasource.
* Prometheus for PostgreSQL / Pgbouncer / Patroni / HAProxy / Node metrics
* Loki for PostgreSQL / Pgbouncer / Patroni / pgBackRest logs


----------------

## Dashboards

There are 23 default grafana dashboards about PostgreSQL and categorized into 4 levels:

**Overview**

- [pgsql-overview](http://demo.pigsty.cc/d/pgsql-overview) : The main dashboard for PGSQL module
- [pgsql-alert](http://demo.pigsty.cc/d/pgsql-alert) : Global PGSQL key metrics and alerting events
- [pgsql-shard](http://demo.pigsty.cc/d/pgsql-shard) : Overview of a horizontal sharded PGSQL cluster, e.g. citus / gpsql cluster

**Cluster**

- [pgsql-cluster](http://demo.pigsty.cc/d/pgsql-cluster): The main dashboard for a PGSQL cluster
- [pgsql-cluster-remote](http://demo.pigsty.cc/d/pgsql-cluster-remote): Trimmed version of PGSQL Cluster, for remote PGSQL cluster
- [pgsql-activity](http://demo.pigsty.cc/d/pgsql-activity): Cares about the Session/Load/QPS/TPS/Locks of a PGSQL cluster
- [pgsql-replication](http://demo.pigsty.cc/d/pgsql-replication): Cares about PGSQL cluster replication, slots, and pub/sub.
- [pgsql-service](http://demo.pigsty.cc/d/pgsql-service): Cares about PGSQL cluster services, proxies, routes, and load balancers.
- [pgsql-databases](http://demo.pigsty.cc/d/pgsql-databases): Cares about database CRUD, slow queries, and table statistics cross all instances.

**Instance**

- [pgsql-instance](http://demo.pigsty.cc/d/pgsql-instance): The main dashboard for a single PGSQL instance
- [pgcat-instance](http://demo.pigsty.cc/d/pgcat-instance): Instance information from database catalog directly
- [pgsql-persist](http://demo.pigsty.cc/d/pgsql-persist): Metrics about persistence: WAL, XID, Checkpoint, Archive, IO
- [pgsql-proxy](http://demo.pigsty.cc/d/pgsql-proxy): Metrics about haproxy the service provider
- [pgsql-queries](http://demo.pigsty.cc/d/pgsql-queries): Overview of all queries in a single instance
- [pgsql-session](http://demo.pigsty.cc/d/pgsql-session): Metrics about sessions and active/idle time in a single instance
- [pgsql-xacts](http://demo.pigsty.cc/d/pgsql-xacts): Metrics about transactions, locks, queries, etc...

**Database**

- [pgsql-database](http://demo.pigsty.cc/d/pgsql-database): The main dashboard for a single PGSQL database
- [pgcat-database](http://demo.pigsty.cc/d/pgcat-database): Database information from database catalog directly
- [pgsql-tables](http://demo.pigsty.cc/d/pgsql-tables) : Table/Index access metrics inside a single database
- [pgsql-table](http://demo.pigsty.cc/d/pgsql-table): Detailed information (QPS/RT/Index/Seq...) about a single table 
- [pgcat-table](http://demo.pigsty.cc/d/pgcat-table): Detailed information (Stats/Bloat/...) about a single table from database catalog directly
- [pgsql-query](http://demo.pigsty.cc/d/pgsql-query): Detailed information (QPS/RT) about a single query
- [pgcat-query](http://demo.pigsty.cc/d/pgcat-query): Detailed information (SQL/Stats) about a single query from database catalog directly



----------------

## Metrics

PostgreSQL's metrics are defined by collector files: [`pg_exporter.yml`](https://github.com/Vonng/pigsty/blob/master/roles/pgsql/templates/pg_exporter.yml)

And it will further be processed by Prometheus record rules & Alert evaluation: [`files/prometheus/rules/pgsql.yml`](https://github.com/Vonng/pigsty/blob/master/files/prometheus/rules/pgsql.yml)

3 labels: `cls`, `ins`, `ip` will be attached to all metrics & logs, such as `{ cls: pg-meta, ins: pg-meta-1, ip: 10.10.10.10 }`


----------------

## Logs

PostgreSQL related logs are collected by promtail and sending to loki on infra nodes by default.

- [`pg_log_dir`](PARAM#pg_log_dir) : postgres log dir, `/pg/log/postgres` by default
- [`pgbouncer_log_dir`](PARAM#pgbouncer_log_dir) : pgbouncer log dir, `/pg/log/pgbouncer` by default
- [`patroni_log_dir`](PARAM#patroni_log_dir) : patroni log dir, `/pg/log/patroni` by default
- [`pgbackrest_log_dir`](PARAM#pgbackrest_log_dir) : pgbackrest log dir, `/pg/log/pgbackrest` by default




----------------

## Target Management

Prometheus monitoring targets are defined in static files under `/etc/prometheus/targets/pgsql/`, each instance will have a corresponding file.

Take `pg-meta-1` as an example:

```yaml
# pg-meta-1 [primary] @ 10.10.10.10
- labels: { cls: pg-meta, ins: pg-meta-1, ip: 10.10.10.10 }
  targets:
    - 10.10.10.10:9630    # <--- pg_exporter for PostgreSQL metrics
    - 10.10.10.10:9631    # <--- pg_exporter for pgbouncer metrics
    - 10.10.10.10:8008    # <--- patroni metrics
```

When the global flag [`patroni_ssl_enabled`](PARAM#patroni_ssl_enabled) is set, patroni target will be moved to a separate file `/etc/prometheus/targets/patroni/<ins>.yml`.
Since https scrape endpoint is used for that.

Prometheus monitoring target will be removed when cluster is removed with `bin/pgsql-rm` or `pgsql-rm.yml`. You can also remove it manually, or using playbook subtasks:

```bash
bin/pgmon-rm <ins>      # remove prometheus targets from all infra nodes
```



----------------

## Remote Postgres


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


**Procedure**

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