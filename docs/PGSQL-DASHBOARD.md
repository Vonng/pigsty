# PGSQL Dashboard

> Grafana Dashboards for PostgreSQL clusters:  [Demo](https://demo.pigsty.cc/d/pgsql-overview) & [Gallery](https://github.com/Vonng/pigsty/wiki/Gallery).

[![pigsty-dashboard.jpg](https://repo.pigsty.cc/img/pigsty-dashboard.jpg)](https://github.com/Vonng/pigsty/wiki/Gallery)

There are 26 default grafana dashboards about PostgreSQL and categorized into 4 levels. and categorized into [PGSQL](#overview), [PGCAT](#pgcat) & [PGLOG](#pglog) by datasource.

|                         Overview                          |                             Cluster                             |                          Instance                           |                         Database                          |
|:---------------------------------------------------------:|:---------------------------------------------------------------:|:-----------------------------------------------------------:|:---------------------------------------------------------:|
| [PGSQL Overview](https://demo.pigsty.cc/d/pgsql-overview) |     [PGSQL Cluster](https://demo.pigsty.cc/d/pgsql-cluster)     |  [PGSQL Instance](https://demo.pigsty.cc/d/pgsql-instance)  | [PGSQL Database](https://demo.pigsty.cc/d/pgsql-database) |
|    [PGSQL Alert](https://demo.pigsty.cc/d/pgsql-alert)    |     [PGRDS Cluster](https://demo.pigsty.cc/d/pgrds-cluster)     |  [PGRDS Instance](https://demo.pigsty.cc/d/pgrds-instance)  | [PGCAT Database](https://demo.pigsty.cc/d/pgcat-database) |
|    [PGSQL Shard](https://demo.pigsty.cc/d/pgsql-shard)    |    [PGSQL Activity](https://demo.pigsty.cc/d/pgsql-activity)    |  [PGCAT Instance](https://demo.pigsty.cc/d/pgcat-instance)  |   [PGSQL Tables](https://demo.pigsty.cc/d/pgsql-tables)   |
|                                                           | [PGSQL Replication](https://demo.pigsty.cc/d/pgsql-replication) |   [PGSQL Persist](https://demo.pigsty.cc/d/pgsql-persist)   |    [PGSQL Table](https://demo.pigsty.cc/d/pgsql-table)    |
|                                                           |     [PGSQL Service](https://demo.pigsty.cc/d/pgsql-service)     |     [PGSQL Proxy](https://demo.pigsty.cc/d/pgsql-proxy)     |    [PGCAT Table](https://demo.pigsty.cc/d/pgcat-table)    |
|                                                           |   [PGSQL Databases](https://demo.pigsty.cc/d/pgsql-databases)   | [PGSQL Pgbouncer](https://demo.pigsty.cc/d/pgsql-pgbouncer) |    [PGSQL Query](https://demo.pigsty.cc/d/pgsql-query)    |
|                                                           |     [PGSQL Patroni](https://demo.pigsty.cc/d/pgsql-patroni)     |   [PGSQL Session](https://demo.pigsty.cc/d/pgsql-session)   |    [PGCAT Query](https://demo.pigsty.cc/d/pgcat-query)    |
|                                                           |                                                                 |     [PGSQL Xacts](https://demo.pigsty.cc/d/pgsql-xacts)     |    [PGCAT Locks](https://demo.pigsty.cc/d/pgcat-locks)    |
|                                                           |                                                                 |  [PGSQL Exporter](https://demo.pigsty.cc/d/pgsql-exporter)  |   [PGCAT Schema](https://demo.pigsty.cc/d/pgcat-schema)   |



**Overview**

- [pgsql-overview](https://demo.pigsty.cc/d/pgsql-overview) : The main dashboard for PGSQL module
- [pgsql-alert](https://demo.pigsty.cc/d/pgsql-alert) : Global PGSQL key metrics and alerting events
- [pgsql-shard](https://demo.pigsty.cc/d/pgsql-shard) : Overview of a horizontal sharded PGSQL cluster, e.g. citus / gpsql cluster

**Cluster**

- [pgsql-cluster](https://demo.pigsty.cc/d/pgsql-cluster): The main dashboard for a PGSQL cluster
- [pgrds-cluster](https://demo.pigsty.cc/d/pgrds-cluster): The PGSQL Cluster dashboard for RDS, focus on all postgres metrics only.
- [pgsql-activity](https://demo.pigsty.cc/d/pgsql-activity): Cares about the Session/Load/QPS/TPS/Locks of a PGSQL cluster
- [pgsql-replication](https://demo.pigsty.cc/d/pgsql-replication): Cares about PGSQL cluster replication, slots, and pub/sub.
- [pgsql-service](https://demo.pigsty.cc/d/pgsql-service): Cares about PGSQL cluster services, proxies, routes, and load balancers.
- [pgsql-databases](https://demo.pigsty.cc/d/pgsql-databases): Cares about database CRUD, slow queries, and table statistics cross all instances.
- [pgsql-patroni](https://demo.pigsty.cc/d/pgsql-databases): Cares about cluster HA agent: patroni status.

**Instance**

- [pgsql-instance](https://demo.pigsty.cc/d/pgsql-instance): The main dashboard for a single PGSQL instance
- [pgrds-instance](https://demo.pigsty.cc/d/pgrds-instance): The PGSQL Instance dashboard for RDS, focus on all postgres metrics only.
- [pgcat-instance](https://demo.pigsty.cc/d/pgcat-instance): Instance information from database catalog directly
- [pgsql-persist](https://demo.pigsty.cc/d/pgsql-persist): Metrics about persistence: WAL, XID, Checkpoint, Archive, IO
- [pgsql-proxy](https://demo.pigsty.cc/d/pgsql-proxy): Metrics about haproxy the service provider
- [pgsql-queries](https://demo.pigsty.cc/d/pgsql-queries): Overview of all queries in a single instance
- [pgsql-session](https://demo.pigsty.cc/d/pgsql-session): Metrics about sessions and active/idle time in a single instance
- [pgsql-xacts](https://demo.pigsty.cc/d/pgsql-xacts): Metrics about transactions, locks, queries, etc...
- [pgsql-exporter](https://demo.pigsty.cc/d/pgsql-exporter): Postgres & Pgbouncer exporter self monitoring metrics

**Database**

- [pgsql-database](https://demo.pigsty.cc/d/pgsql-database): The main dashboard for a single PGSQL database
- [pgcat-database](https://demo.pigsty.cc/d/pgcat-database): Database information from database catalog directly
- [pgsql-tables](https://demo.pigsty.cc/d/pgsql-tables) : Table/Index access metrics inside a single database
- [pgsql-table](https://demo.pigsty.cc/d/pgsql-table): Detailed information (QPS/RT/Index/Seq...) about a single table
- [pgcat-table](https://demo.pigsty.cc/d/pgcat-table): Detailed information (Stats/Bloat/...) about a single table from database catalog directly
- [pgsql-query](https://demo.pigsty.cc/d/pgsql-query): Detailed information (QPS/RT) about a single query
- [pgcat-query](https://demo.pigsty.cc/d/pgcat-query): Detailed information (SQL/Stats) about a single query from database catalog directly




-------------------

## Overview

[PGSQL Overview](https://demo.pigsty.cc/d/pgsql-overview) : The main dashboard for PGSQL module

<details><summary>PGSQL Overview</summary>

[![pgsql-overview.jpg](https://repo.pigsty.cc/img/pgsql-overview.jpg)](https://demo.pigsty.cc/d/pgsql-overview)

</details>


[PGSQL Alert](https://demo.pigsty.cc/d/pgsql-alert) : Global PGSQL key metrics and alerting events

<details><summary>PGSQL Alert</summary>

[![pgsql-alert.jpg](https://repo.pigsty.cc/img/pgsql-alert.jpg)](https://demo.pigsty.cc/d/pgsql-alert)

</details>


[PGSQL Shard](https://demo.pigsty.cc/d/pgsql-shard) : Overview of a horizontal sharded PGSQL cluster, e.g. CITUS / GPSQL cluster

<details><summary>PGSQL Shard</summary>

[![pgsql-shard.jpg](https://repo.pigsty.cc/img/pgsql-shard.jpg)](https://demo.pigsty.cc/d/pgsql-shard)

</details>



-------------------

## Cluster

[PGSQL Cluster](https://demo.pigsty.cc/d/pgsql-cluster): The main dashboard for a PGSQL cluster

<details><summary>PGSQL Cluster</summary>

[![pgsql-cluster.jpg](https://repo.pigsty.cc/img/pgsql-cluster.jpg)](https://demo.pigsty.cc/d/pgsql-cluster)

</details>

[PGRDS Cluster](https://demo.pigsty.cc/d/pgrds-cluster): The PGSQL Cluster dashboard for RDS, focus on all postgres metrics only.

<details><summary>PGRDS Cluster</summary>

[![pgrds-cluster.jpg](https://repo.pigsty.cc/img/pgrds-cluster.jpg)](https://demo.pigsty.cc/d/pgrds-cluster)

</details>

[PGSQL Service](https://demo.pigsty.cc/d/pgsql-service): Cares about PGSQL cluster services, proxies, routes, and load balancers.

<details><summary>PGSQL Service</summary>

[![pgsql-service.jpg](https://repo.pigsty.cc/img/pgsql-service.jpg)](https://demo.pigsty.cc/d/pgsql-service)

</details>

[PGSQL Activity](https://demo.pigsty.cc/d/pgsql-activity): Cares about the Session/Load/QPS/TPS/Locks of a PGSQL cluster

<details><summary>PGSQL Activity</summary>

[![pgsql-activity.jpg](https://repo.pigsty.cc/img/pgsql-activity.jpg)](https://demo.pigsty.cc/d/pgsql-activity)

</details>

[PGSQL Replication](https://demo.pigsty.cc/d/pgsql-replication): Cares about PGSQL cluster replication, slots, and pub/sub.

<details><summary>PGSQL Replication</summary>

[![pgsql-replication.jpg](https://repo.pigsty.cc/img/pgsql-replication.jpg)](https://demo.pigsty.cc/d/pgsql-replication)

</details>


[PGSQL Databases](https://demo.pigsty.cc/d/pgsql-databases): Cares about database CRUD, slow queries, and table statistics cross all instances.

<details><summary>PGSQL Databases</summary>

[![pgsql-databases.jpg](https://repo.pigsty.cc/img/pgsql-databases.jpg)](https://demo.pigsty.cc/d/pgsql-databases)

</details>


[PGSQL Patroni](https://demo.pigsty.cc/d/pgsql-patroni): Cares about cluster HA agent: patroni status.

<details><summary>PGSQL Patroni</summary>

[![pgsql-patroni.jpg](https://repo.pigsty.cc/img/pgsql-patroni.jpg)](https://demo.pigsty.cc/d/pgsql-patroni)

</details>




-------------------

## Instance

[PGSQL Instance](https://demo.pigsty.cc/d/pgsql-instance): The main dashboard for a single PGSQL instance

<details><summary>PGSQL Instance</summary>

[![pgsql-instance.jpg](https://repo.pigsty.cc/img/pgsql-instance.jpg)](https://demo.pigsty.cc/d/pgsql-instance)

</details>


[PGRDS Instance](https://demo.pigsty.cc/d/pgrds-instance): The PGSQL Instance dashboard for RDS, focus on all postgres metrics only.

<details><summary>PGRDS Instance</summary>

[![pgrds-instance.jpg](https://repo.pigsty.cc/img/pgrds-instance.jpg)](https://demo.pigsty.cc/d/pgrds-instance)

</details>


[PGSQL Proxy](https://demo.pigsty.cc/d/pgsql-proxy): Metrics about haproxy the service provider

<details><summary>PGSQL Proxy</summary>

[![pgsql-proxy.jpg](https://repo.pigsty.cc/img/pgsql-proxy.jpg)](https://demo.pigsty.cc/d/pgsql-proxy)

</details>


[PGSQL Pgbouncer](https://demo.pigsty.cc/d/pgsql-pgbouncer): Metrics about one single pgbouncer connection pool instance

<details><summary>PGSQL Pgbouncer</summary>

[![pgsql-pgbouncer.jpg](https://repo.pigsty.cc/img/pgsql-pgbouncer.jpg)](https://demo.pigsty.cc/d/pgsql-pgbouncer)

</details>


[PGSQL Persist](https://demo.pigsty.cc/d/pgsql-persist): Metrics about persistence: WAL, XID, Checkpoint, Archive, IO

<details><summary>PGSQL Persist</summary>

[![pgsql-persist.jpg](https://repo.pigsty.cc/img/pgsql-persist.jpg)](https://demo.pigsty.cc/d/pgsql-persist)

</details>


[PGSQL Xacts](https://demo.pigsty.cc/d/pgsql-xacts): Metrics about transactions, locks, queries, etc...

<details><summary>PGSQL Xacts</summary>

[![pgsql-xacts.jpg](https://repo.pigsty.cc/img/pgsql-xacts.jpg)](https://demo.pigsty.cc/d/pgsql-xacts)

</details>


[PGSQL Session](https://demo.pigsty.cc/d/pgsql-session): Metrics about sessions and active/idle time in a single instance

<details><summary>PGSQL Session</summary>

[![pgsql-session.jpg](https://repo.pigsty.cc/img/pgsql-session.jpg)](https://demo.pigsty.cc/d/pgsql-session)

</details>


[PGSQL Exporter](https://demo.pigsty.cc/d/pgsql-exporter): Postgres & Pgbouncer exporter self monitoring metrics

<details><summary>PGSQL Exporter</summary>

[![pgsql-exporter.jpg](https://repo.pigsty.cc/img/pgsql-exporter.jpg)](https://demo.pigsty.cc/d/pgsql-exporter)

</details>


-------------------

## Database


[PGSQL Database](https://demo.pigsty.cc/d/pgsql-database): The main dashboard for a single PGSQL database

<details><summary>PGSQL Database</summary>

[![pgsql-database.jpg](https://repo.pigsty.cc/img/pgsql-database.jpg)](https://demo.pigsty.cc/d/pgsql-database)

</details>


[PGSQL Tables](https://demo.pigsty.cc/d/pgsql-tables) : Table/Index access metrics inside a single database

<details><summary>PGSQL Tables</summary>

[![pgsql-tables.jpg](https://repo.pigsty.cc/img/pgsql-tables.jpg)](https://demo.pigsty.cc/d/pgsql-tables)

</details>


[PGSQL Table](https://demo.pigsty.cc/d/pgsql-table): Detailed information (QPS/RT/Index/Seq...) about a single table

<details><summary>PGSQL Table</summary>

[![pgsql-table.jpg](https://repo.pigsty.cc/img/pgsql-table.jpg)](https://demo.pigsty.cc/d/pgsql-table)

</details>


[PGSQL Query](https://demo.pigsty.cc/d/pgsql-query): Detailed information (QPS/RT) about a single query

<details><summary>PGSQL Query</summary>

[![pgsql-query.jpg](https://repo.pigsty.cc/img/pgsql-query.jpg)](https://demo.pigsty.cc/d/pgsql-query)

</details>




-------------------

## PGCAT

[PGCAT Instance](https://demo.pigsty.cc/d/pgcat-instance): Instance information from database catalog directly

<details><summary>PGCAT Instance</summary>

[![pgcat-instance.jpg](https://repo.pigsty.cc/img/pgcat-instance.jpg)](https://demo.pigsty.cc/d/pgcat-instance)

</details>


[PGCAT Database](https://demo.pigsty.cc/d/pgcat-database): Database information from database catalog directly

<details><summary>PGCAT Database</summary>

[![pgcat-database.jpg](https://repo.pigsty.cc/img/pgcat-database.jpg)](https://demo.pigsty.cc/d/pgcat-database)

</details>



[PGCAT Schema](https://demo.pigsty.cc/d/pgcat-schema): Detailed information about one single schema from database catalog directly

<details><summary>PGCAT Schema</summary>

[![pgcat-schema.jpg](https://repo.pigsty.cc/img/pgcat-schema.jpg)](https://demo.pigsty.cc/d/pgcat-schema)

</details>




[PGCAT Table](https://demo.pigsty.cc/d/pgcat-table): Detailed information about one single table from database catalog directly

<details><summary>PGCAT Table</summary>

[![pgcat-table.jpg](https://repo.pigsty.cc/img/pgcat-table.jpg)](https://demo.pigsty.cc/d/pgcat-table)

</details>



[PGCAT Query](https://demo.pigsty.cc/d/pgcat-query): Detailed information about one single type of query from database catalog directly

<details><summary>PGCAT Query</summary>

[![pgcat-query.jpg](https://repo.pigsty.cc/img/pgcat-query.jpg)](https://demo.pigsty.cc/d/pgcat-query)

</details>



[PGCAT Locks](https://demo.pigsty.cc/d/pgcat-locks): Detailed information about live locks & activity from database catalog directly

<details><summary>PGCAT Locks</summary>

[![pgcat-locks.jpg](https://repo.pigsty.cc/img/pgcat-locks.jpg)](https://demo.pigsty.cc/d/pgcat-locks)

</details>



-------------------

## PGLOG

[PGLOG Overview](https://demo.pigsty.cc/d/pglog-overview): Overview of csv log sample in pigsty meta database

<details><summary>PGLOG Overview</summary>

[![pglog-overview.jpg](https://repo.pigsty.cc/img/pglog-overview.jpg)](https://demo.pigsty.cc/d/pglog-overview)

</details>



[PGLOG Overview](https://demo.pigsty.cc/d/pglog-overview): Detail of one single session of csv log sample in pigsty meta database

<details><summary>PGLOG Session</summary>

[![pglog-session.jpg](https://repo.pigsty.cc/img/pglog-session.jpg)](https://demo.pigsty.cc/d/pglog-session)

</details>





----------------

## Gallery








<details><summary>PGSQL Shard</summary>

[![pgsql-shard.jpg](https://repo.pigsty.cc/img/pgsql-shard.jpg)](https://demo.pigsty.cc/d/pgsql-shard)

</details>


<details><summary>PGSQL Cluster</summary>

[![pgsql-cluster.jpg](https://repo.pigsty.cc/img/pgsql-cluster.jpg)](https://demo.pigsty.cc/d/pgsql-cluster)

</details>


<details><summary>PGSQL Service</summary>

[![pgsql-service.jpg](https://repo.pigsty.cc/img/pgsql-service.jpg)](https://demo.pigsty.cc/d/pgsql-service)

</details>


<details><summary>PGSQL Activity</summary>

[![pgsql-activity.jpg](https://repo.pigsty.cc/img/pgsql-activity.jpg)](https://demo.pigsty.cc/d/pgsql-activity)

</details>


<details><summary>PGSQL Replication</summary>

[![pgsql-replication.jpg](https://repo.pigsty.cc/img/pgsql-replication.jpg)](https://demo.pigsty.cc/d/pgsql-replication)

</details>


<details><summary>PGSQL Databases</summary>

[![pgsql-databases.jpg](https://repo.pigsty.cc/img/pgsql-databases.jpg)](https://demo.pigsty.cc/d/pgsql-databases)

</details>


<details><summary>PGSQL Instance</summary>

[![pgsql-instance.jpg](https://repo.pigsty.cc/img/pgsql-instance.jpg)](https://demo.pigsty.cc/d/pgsql-instance)

</details>


<details><summary>PGSQL Proxy</summary>

[![pgsql-proxy.jpg](https://repo.pigsty.cc/img/pgsql-proxy.jpg)](https://demo.pigsty.cc/d/pgsql-proxy)

</details>


<details><summary>PGSQL Pgbouncer</summary>

[![pgsql-pgbouncer.jpg](https://repo.pigsty.cc/img/pgsql-pgbouncer.jpg)](https://demo.pigsty.cc/d/pgsql-pgbouncer)

</details>


<details><summary>PGSQL Session</summary>

[![pgsql-session.jpg](https://repo.pigsty.cc/img/pgsql-session.jpg)](https://demo.pigsty.cc/d/pgsql-session)

</details>


<details><summary>PGSQL Xacts</summary>

[![pgsql-xacts.jpg](https://repo.pigsty.cc/img/pgsql-xacts.jpg)](https://demo.pigsty.cc/d/pgsql-xacts)

</details>


<details><summary>PGSQL Persist</summary>

[![pgsql-persist.jpg](https://repo.pigsty.cc/img/pgsql-persist.jpg)](https://demo.pigsty.cc/d/pgsql-persist)

</details>


<details><summary>PGSQL Database</summary>

[![pgsql-database.jpg](https://repo.pigsty.cc/img/pgsql-database.jpg)](https://demo.pigsty.cc/d/pgsql-database)

</details>


<details><summary>PGSQL Tables</summary>

[![pgsql-tables.jpg](https://repo.pigsty.cc/img/pgsql-tables.jpg)](https://demo.pigsty.cc/d/pgsql-tables)

</details>


<details><summary>PGSQL Table</summary>

[![pgsql-table.jpg](https://repo.pigsty.cc/img/pgsql-table.jpg)](https://demo.pigsty.cc/d/pgsql-table)


</details>


<details><summary>PGSQL Query</summary>

[![pgsql-query.jpg](https://repo.pigsty.cc/img/pgsql-query.jpg)](https://demo.pigsty.cc/d/pgsql-query)

</details>


<details><summary>PGCAT Instance</summary>

[![pgcat-instance.jpg](https://repo.pigsty.cc/img/pgcat-instance.jpg)](https://demo.pigsty.cc/d/pgcat-instance)

</details>


<details><summary>PGCAT Database</summary>

[![pgcat-database.jpg](https://repo.pigsty.cc/img/pgcat-database.jpg)](https://demo.pigsty.cc/d/pgcat-database)

</details>


<details><summary>PGCAT Schema</summary>

[![pgcat-schema.jpg](https://repo.pigsty.cc/img/pgcat-schema.jpg)](https://demo.pigsty.cc/d/pgcat-schema)

</details>


<details><summary>PGCAT Table</summary>

[![pgcat-table.jpg](https://repo.pigsty.cc/img/pgcat-table.jpg)](https://demo.pigsty.cc/d/pgcat-table)

</details>


<details><summary>PGCAT Lock</summary>

[![pgcat-locks.jpg](https://repo.pigsty.cc/img/pgcat-locks.jpg)](https://demo.pigsty.cc/d/pgcat-locks)

</details>


<details><summary>PGCAT Query</summary>

[![pgcat-query.jpg](https://repo.pigsty.cc/img/pgcat-query.jpg)](https://demo.pigsty.cc/d/pgcat-query)

</details>



<details><summary>PGLOG Overview</summary>

[![pglog-overview.jpg](https://repo.pigsty.cc/img/pglog-overview.jpg)](https://demo.pigsty.cc/d/pglog-overview)


</details>


<details><summary>PGLOG Session</summary>

[![pglog-session.jpg](https://repo.pigsty.cc/img/pglog-session.jpg)](https://demo.pigsty.cc/d/pglog-session)

</details>


