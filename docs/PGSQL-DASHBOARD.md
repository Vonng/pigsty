# PGSQL Dashboard

> Grafana Dashboards for Pigsty managed PostgreSQL clusters

![pigsty-dashboard](https://github.com/Vonng/pigsty/assets/8587410/cd4e6620-bc36-44dc-946b-b9ae56f93c90)

There are 26 default grafana dashboards about PostgreSQL and categorized into 4 levels. and categorized into [PGSQL](#overview), [PGCAT](#pgcat) & [PGLOG](#pglog) by datasource.

|                         Overview                          |                             Cluster                             |                          Instance                           |                         Database                          |
|:---------------------------------------------------------:|:---------------------------------------------------------------:|:-----------------------------------------------------------:|:---------------------------------------------------------:|
| [PGSQL Overview](https://demo.pigsty.cc/d/pgsql-overview) |     [PGSQL Cluster](https://demo.pigsty.cc/d/pgsql-cluster)     |  [PGSQL Instance](https://demo.pigsty.cc/d/pgsql-instance)  | [PGSQL Database](https://demo.pigsty.cc/d/pgsql-database) |
|    [PGSQL Alert](https://demo.pigsty.cc/d/pgsql-alert)    |     [PGRDS Cluster](https://demo.pigsty.cc/d/pgrds-cluster)     |  [PGRDS Instance](https://demo.pigsty.cc/d/pgrds-instance)  | [PGCAT Database](https://demo.pigsty.cc/d/pgcat-database) |
|    [PGSQL Shard](https://demo.pigsty.cc/d/pgsql-shard)    |    [PGSQL Activity](https://demo.pigsty.cc/d/pgsql-activity)    |  [PGCAT Instance](https://demo.pigsty.cc/d/pgcat-instance)  |   [PGSQL Tables](https://demo.pigsty.cc/d/pgsql-tables)   |
|                                                           | [PGSQL Replication](https://demo.pigsty.cc/d/pgsql-replication) |   [PGSQL Persist](https://demo.pigsty.cc/d/pgsql-persist)   |    [PGSQL Table](https://demo.pigsty.cc/d/pgsql-table)    |
|                                                           |     [PGSQL Service](https://demo.pigsty.cc/d/pgsql-service)     |     [PGSQL Proxy](https://demo.pigsty.cc/d/pgsql-proxy)     |    [PGCAT Table](https://demo.pigsty.cc/d/pgcat-table)    |
|                                                           |   [PGSQL Databases](https://demo.pigsty.cc/d/pgsql-databases)   | [PGSQL Pgbouncer](https://demo.pigsty.cc/d/pgsql-pgbouncer) |    [PGSQL Query](https://demo.pigsty.cc/d/pgsql-query)    |
|                                                           |                                                                 |   [PGSQL Session](https://demo.pigsty.cc/d/pgsql-session)   |    [PGCAT Query](https://demo.pigsty.cc/d/pgcat-query)    |
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

[![pgsql-overview](https://github.com/Vonng/pigsty/assets/8587410/703fe5bf-2688-4d60-b6c3-009f16a81d2b)](https://demo.pigsty.cc/d/pgsql-overview)

</details>


[PGSQL Alert](https://demo.pigsty.cc/d/pgsql-alert) : Global PGSQL key metrics and alerting events

<details><summary>PGSQL Alert</summary>

[![pgsql-alert](https://github.com/Vonng/pigsty/assets/8587410/3c019b87-bede-481c-984c-e0009f6a5cda)](https://demo.pigsty.cc/d/pgsql-alert/)

</details>


[PGSQL Shard](https://demo.pigsty.cc/d/pgsql-shard) : Overview of a horizontal sharded PGSQL cluster, e.g. CITUS / GPSQL cluster

<details><summary>PGSQL Shard</summary>

[![pgsql-shard](https://github.com/Vonng/pigsty/assets/8587410/0c442f35-3b1b-4ac3-8c9a-f245e90c586f)](https://demo.pigsty.cc/d/pgsql-shard)

</details>



-------------------

## Cluster

[PGSQL Cluster](https://demo.pigsty.cc/d/pgsql-cluster): The main dashboard for a PGSQL cluster

<details><summary>PGSQL Cluster</summary>

[![pgsql-cluster](https://github.com/Vonng/pigsty/assets/8587410/6315dc43-16aa-4235-bdff-041756e156fc)](https://demo.pigsty.cc/d/pgsql-cluster)

</details>

[PGRDS Cluster](https://demo.pigsty.cc/d/pgrds-cluster): The PGSQL Cluster dashboard for RDS, focus on all postgres metrics only.

<details><summary>PGRDS Cluster</summary>

[![pgrds-cluster](https://github.com/Vonng/pigsty/assets/8587410/3e60b7f8-8db0-4e03-880e-9d16effd55fe)](https://demo.pigsty.cc/d/pgrds-cluster)

</details>

[PGSQL Service](https://demo.pigsty.cc/d/pgsql-service): Cares about PGSQL cluster services, proxies, routes, and load balancers.

<details><summary>PGSQL Service</summary>

[![pgsql-service](https://github.com/Vonng/pigsty/assets/8587410/52b1502c-e074-46ca-a860-f1361dab3ca0)](https://demo.pigsty.cc/d/pgsql-service)

</details>

[PGSQL Activity](https://demo.pigsty.cc/d/pgsql-activity): Cares about the Session/Load/QPS/TPS/Locks of a PGSQL cluster

<details><summary>PGSQL Activity</summary>

[![pgsql-activity](https://github.com/Vonng/pigsty/assets/8587410/c3832607-7ff4-4cfa-bb17-e9c76b56c703)](https://demo.pigsty.cc/d/pgsql-activity)

</details>

[PGSQL Replication](https://demo.pigsty.cc/d/pgsql-replication): Cares about PGSQL cluster replication, slots, and pub/sub.

<details><summary>PGSQL Replication</summary>

[![pgsql-replication](https://github.com/Vonng/pigsty/assets/8587410/f0cd896a-f7fa-4147-a385-530fbafbbeaa)](https://demo.pigsty.cc/d/pgsql-replication)

</details>


[PGSQL Databases](https://demo.pigsty.cc/d/pgsql-databases): Cares about database CRUD, slow queries, and table statistics cross all instances.

<details><summary>PGSQL Databases</summary>

[![pgsql-databases](https://github.com/Vonng/pigsty/assets/8587410/0e0b9dca-44d6-4995-810f-241689d38dd1)](https://demo.pigsty.cc/d/pgsql-databases)

</details>



-------------------

## Instance

[PGSQL Instance](https://demo.pigsty.cc/d/pgsql-instance): The main dashboard for a single PGSQL instance

<details><summary>PGSQL Instance</summary>

[![pgsql-instance](https://github.com/Vonng/pigsty/assets/8587410/25e98b4a-a1b2-473f-8135-02db34378b6e)](https://demo.pigsty.cc/d/pgsql-instance/)

</details>


[PGRDS Instance](https://demo.pigsty.cc/d/pgrds-instance): The PGSQL Instance dashboard for RDS, focus on all postgres metrics only.

<details><summary>PGRDS Instance</summary>

[![pgrds-instance](https://github.com/Vonng/pigsty/assets/8587410/3e60b7f8-8db0-4e03-880e-9d16effd55fe)](https://demo.pigsty.cc/d/pgrds-instance)

</details>


[PGSQL Proxy](https://demo.pigsty.cc/d/pgsql-proxy): Metrics about haproxy the service provider

<details><summary>PGSQL Proxy</summary>

[![pgsql-proxy](https://github.com/Vonng/pigsty/assets/8587410/303f60ff-8979-4a12-86dd-2a95d30e6126)](https://demo.pigsty.cc/d/pgsql-proxy/)

</details>


[PGSQL Pgbouncer](https://demo.pigsty.cc/d/pgsql-pgbouncer): Metrics about one single pgbouncer connection pool instance

<details><summary>PGSQL Pgbouncer</summary>

[![pgsql-pgbouncer](https://github.com/Vonng/pigsty/assets/8587410/9f221b7c-43dd-474e-ae6c-4e5be77bb481)](https://demo.pigsty.cc/d/pgsql-pgbouncer/)

</details>


[PGSQL Persist](https://demo.pigsty.cc/d/pgsql-persist): Metrics about persistence: WAL, XID, Checkpoint, Archive, IO

<details><summary>PGSQL Persist</summary>

[![pgsql-persist](https://github.com/Vonng/pigsty/assets/8587410/9d404a4e-aab8-40d3-8e0e-34e57779eb6b)](https://demo.pigsty.cc/d/pgsql-persist/)

</details>


[PGSQL Xacts](https://demo.pigsty.cc/d/pgsql-xacts): Metrics about transactions, locks, queries, etc...

<details><summary>PGSQL Xacts</summary>

[![pgsql-xacts](https://github.com/Vonng/pigsty/assets/8587410/0ca83694-a775-4a4a-8c33-15f4cb5bdbcf)](https://demo.pigsty.cc/d/pgsql-xacts/)

</details>


[PGSQL Session](https://demo.pigsty.cc/d/pgsql-session): Metrics about sessions and active/idle time in a single instance

<details><summary>PGSQL Session</summary>

[![pgsql-session](https://github.com/Vonng/pigsty/assets/8587410/e6eeeb0d-56ec-4297-b337-aa86e91a7a39)](https://demo.pigsty.cc/d/pgsql-session/)

</details>




-------------------

## Database


[PGSQL Database](https://demo.pigsty.cc/d/pgsql-database): The main dashboard for a single PGSQL database

<details><summary>PGSQL Database</summary>

[![pgsql-database](https://github.com/Vonng/pigsty/assets/8587410/55fcc046-22a9-4e46-aa97-e6aa4ab26dac)](https://demo.pigsty.cc/d/pgsql-database/)

</details>


[PGSQL Tables](https://demo.pigsty.cc/d/pgsql-tables) : Table/Index access metrics inside a single database

<details><summary>PGSQL Tables</summary>

[![pgsql-tables](https://github.com/Vonng/pigsty/assets/8587410/fb746f65-83ff-41c9-8b2f-61b40679df22)](https://demo.pigsty.cc/d/pgsql-tables/)

</details>


[PGSQL Table](https://demo.pigsty.cc/d/pgsql-table): Detailed information (QPS/RT/Index/Seq...) about a single table

<details><summary>PGSQL Table</summary>

[![pgsql-table](https://github.com/Vonng/pigsty/assets/8587410/7043cb9a-69c4-4902-a2f9-b5be31e78710)](https://demo.pigsty.cc/d/pgsql-table/)

</details>


[PGSQL Query](https://demo.pigsty.cc/d/pgsql-query): Detailed information (QPS/RT) about a single query

<details><summary>PGSQL Query</summary>

[![pgsql-query](https://github.com/Vonng/pigsty/assets/8587410/97184217-8b74-4f5c-bb37-0a7d9a1e4c8c)](https://demo.pigsty.cc/d/pgsql-query/)

</details>




-------------------

## PGCAT

[PGCAT Instance](https://demo.pigsty.cc/d/pgcat-instance): Instance information from database catalog directly

<details><summary>PGCAT Instance</summary>

[![pgcat-instance](https://github.com/Vonng/pigsty/assets/8587410/baa8166c-6f07-484f-8ad4-e5457c995ee6)](https://demo.pigsty.cc/d/pgcat-instance/)

</details>


[PGCAT Database](https://demo.pigsty.cc/d/pgcat-database): Database information from database catalog directly

<details><summary>PGCAT Database</summary>

[![pgcat-database](https://github.com/Vonng/pigsty/assets/8587410/0a158fcf-90b1-445c-843d-f04cb44e9e9b)](https://demo.pigsty.cc/d/pgcat-database/)

</details>



[PGCAT Schema](https://demo.pigsty.cc/d/pgcat-schema): Detailed information about one single schema from database catalog directly

<details><summary>PGCAT Schema</summary>

[![pgcat-schema](https://github.com/Vonng/pigsty/assets/8587410/df3d70f3-ab6c-40a7-9f0e-47aded61f613)](https://demo.pigsty.cc/d/pgcat-schema/)

</details>




[PGCAT Table](https://demo.pigsty.cc/d/pgcat-table): Detailed information about one single table from database catalog directly

<details><summary>PGCAT Table</summary>

[![pgcat-table](https://github.com/Vonng/pigsty/assets/8587410/31fcbc63-c9a7-4185-8460-0eb2490c2e70)](https://demo.pigsty.cc/d/pgcat-table/)

</details>



[PGCAT Query](https://demo.pigsty.cc/d/pgcat-query): Detailed information about one single type of query from database catalog directly

<details><summary>PGCAT Query</summary>

[![pgcat-query](https://github.com/Vonng/pigsty/assets/8587410/0dbde63d-135d-4148-a27a-40edefb74229)](https://demo.pigsty.cc/d/pgcat-query/)

</details>



[PGCAT Locks](https://demo.pigsty.cc/d/pgcat-locks): Detailed information about live locks & activity from database catalog directly

<details><summary>PGCAT Locks</summary>

[![pgcat-locks](https://github.com/Vonng/pigsty/assets/8587410/60eb2afb-6129-468f-b622-f674aa49b424)](https://demo.pigsty.cc/d/pgcat-locks/)

</details>



-------------------

## PGLOG

[PGLOG Overview](https://demo.pigsty.cc/d/pglog-overview): Overview of csv log sample in pigsty meta database

<details><summary>PGLOG Overview</summary>

[![pglog-overview](https://github.com/Vonng/pigsty/assets/8587410/c9ff0225-1d87-4386-9ecb-5b9fc2d38afa)](https://demo.pigsty.cc/d/pglog-overview)

</details>



[PGLOG Overview](https://demo.pigsty.cc/d/pglog-overview): Detail of one single session of csv log sample in pigsty meta database

<details><summary>PGLOG Session</summary>

[![pglog-session](https://github.com/Vonng/pigsty/assets/8587410/de229cb8-e79e-4479-aad9-c404278e5d4e)](https://demo.pigsty.cc/d/pglog-session)

</details>





----------------

## Gallery








<details><summary>PGSQL Shard</summary>

[![pgsql-shard](https://github.com/Vonng/pigsty/assets/8587410/0c442f35-3b1b-4ac3-8c9a-f245e90c586f)](https://demo.pigsty.cc/d/pgsql-shard)

</details>


<details><summary>PGSQL Cluster</summary>

[![pgsql-cluster](https://github.com/Vonng/pigsty/assets/8587410/6315dc43-16aa-4235-bdff-041756e156fc)](https://demo.pigsty.cc/d/pgsql-cluster)

</details>


<details><summary>PGSQL Service</summary>

[![pgsql-service](https://github.com/Vonng/pigsty/assets/8587410/52b1502c-e074-46ca-a860-f1361dab3ca0)](https://demo.pigsty.cc/d/pgsql-service)

</details>


<details><summary>PGSQL Activity</summary>

[![pgsql-activity](https://github.com/Vonng/pigsty/assets/8587410/c3832607-7ff4-4cfa-bb17-e9c76b56c703)](https://demo.pigsty.cc/d/pgsql-activity)

</details>


<details><summary>PGSQL Replication</summary>

[![pgsql-replication](https://github.com/Vonng/pigsty/assets/8587410/f0cd896a-f7fa-4147-a385-530fbafbbeaa)](https://demo.pigsty.cc/d/pgsql-replication)

</details>


<details><summary>PGSQL Databases</summary>

[![pgsql-databases](https://github.com/Vonng/pigsty/assets/8587410/0e0b9dca-44d6-4995-810f-241689d38dd1)](https://demo.pigsty.cc/d/pgsql-databases)

</details>


<details><summary>PGSQL Instance</summary>

[![pgsql-instance](https://github.com/Vonng/pigsty/assets/8587410/25e98b4a-a1b2-473f-8135-02db34378b6e)](https://demo.pigsty.cc/d/pgsql-instance/)

</details>


<details><summary>PGSQL Proxy</summary>

[![pgsql-proxy](https://github.com/Vonng/pigsty/assets/8587410/303f60ff-8979-4a12-86dd-2a95d30e6126)](https://demo.pigsty.cc/d/pgsql-proxy/)

</details>


<details><summary>PGSQL Pgbouncer</summary>

[![pgsql-pgbouncer](https://github.com/Vonng/pigsty/assets/8587410/9f221b7c-43dd-474e-ae6c-4e5be77bb481)](https://demo.pigsty.cc/d/pgsql-pgbouncer/)

</details>


<details><summary>PGSQL Session</summary>

[![pgsql-session](https://github.com/Vonng/pigsty/assets/8587410/e6eeeb0d-56ec-4297-b337-aa86e91a7a39)](https://demo.pigsty.cc/d/pgsql-session/)

</details>


<details><summary>PGSQL Xacts</summary>

[![pgsql-xacts](https://github.com/Vonng/pigsty/assets/8587410/0ca83694-a775-4a4a-8c33-15f4cb5bdbcf)](https://demo.pigsty.cc/d/pgsql-xacts/)

</details>


<details><summary>PGSQL Persist</summary>

[![pgsql-persist](https://github.com/Vonng/pigsty/assets/8587410/9d404a4e-aab8-40d3-8e0e-34e57779eb6b)](https://demo.pigsty.cc/d/pgsql-persist/)

</details>


<details><summary>PGSQL Database</summary>

[![pgsql-database](https://github.com/Vonng/pigsty/assets/8587410/55fcc046-22a9-4e46-aa97-e6aa4ab26dac)](https://demo.pigsty.cc/d/pgsql-database/)

</details>


<details><summary>PGSQL Tables</summary>

[![pgsql-tables](https://github.com/Vonng/pigsty/assets/8587410/fb746f65-83ff-41c9-8b2f-61b40679df22)](https://demo.pigsty.cc/d/pgsql-tables/)

</details>


<details><summary>PGSQL Table</summary>

[![pgsql-table](https://github.com/Vonng/pigsty/assets/8587410/7043cb9a-69c4-4902-a2f9-b5be31e78710)](https://demo.pigsty.cc/d/pgsql-table/)


</details>


<details><summary>PGSQL Query</summary>

[![pgsql-query](https://github.com/Vonng/pigsty/assets/8587410/97184217-8b74-4f5c-bb37-0a7d9a1e4c8c)](https://demo.pigsty.cc/d/pgsql-query/)

</details>


<details><summary>PGCAT Instance</summary>

[![pgcat-instance](https://github.com/Vonng/pigsty/assets/8587410/baa8166c-6f07-484f-8ad4-e5457c995ee6)](https://demo.pigsty.cc/d/pgcat-instance/)

</details>


<details><summary>PGCAT Database</summary>

[![pgcat-database](https://github.com/Vonng/pigsty/assets/8587410/0a158fcf-90b1-445c-843d-f04cb44e9e9b)](https://demo.pigsty.cc/d/pgcat-database/)

</details>


<details><summary>PGCAT Schema</summary>

[![pgcat-schema](https://github.com/Vonng/pigsty/assets/8587410/df3d70f3-ab6c-40a7-9f0e-47aded61f613)](https://demo.pigsty.cc/d/pgcat-schema/)

</details>


<details><summary>PGCAT Table</summary>

[![pgcat-table](https://github.com/Vonng/pigsty/assets/8587410/31fcbc63-c9a7-4185-8460-0eb2490c2e70)](https://demo.pigsty.cc/d/pgcat-table/)

</details>


<details><summary>PGCAT Lock</summary>

[![pgcat-locks](https://github.com/Vonng/pigsty/assets/8587410/60eb2afb-6129-468f-b622-f674aa49b424)](https://demo.pigsty.cc/d/pgcat-locks/)

</details>


<details><summary>PGCAT Query</summary>

[![pgcat-query](https://github.com/Vonng/pigsty/assets/8587410/0dbde63d-135d-4148-a27a-40edefb74229)](https://demo.pigsty.cc/d/pgcat-query/)

</details>



<details><summary>PGLOG Overview</summary>

[![pglog-overview](https://github.com/Vonng/pigsty/assets/8587410/c9ff0225-1d87-4386-9ecb-5b9fc2d38afa)](https://demo.pigsty.cc/d/pglog-overview)


</details>


<details><summary>PGLOG Session</summary>

[![pglog-session](https://github.com/Vonng/pigsty/assets/8587410/de229cb8-e79e-4479-aad9-c404278e5d4e)](https://demo.pigsty.cc/d/pglog-session)

</details>


