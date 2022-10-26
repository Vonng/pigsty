# Pigsty Dashboards

Pigsty provides a professional and easy-to-use PostgreSQL monitor system that distills the industry's monitoring best practices.

The Pigsty monitoring dashboard consists of several relatively independent boards.

| Application                          | Description                 |
| ------------------------------------ | --------------------------- |
| [Home](http://demo.pigsty.cc/d/home) | Home                        |
| [`PGSQL`](#PGSQL)                    | PostgreSQL Database Monitor |
| [`REDIS`](#REDIS)                    | Redis Database Monitor      |
| [`NODES`](#NODES)                    | Host Node Monitor           |
| [`INFRA`](#INFRA)                    | Infra monitoring/logging    |
| [ APP](#APP)                         | Extra added applications    |



## HOME

Pigsty's home page provides navigation to the various boards.

* [HOME](http://demo.pigsty.cc/d/home)



## PGSQL

The PostgreSQL monitoring dashboard has its level, from the top down, as follows：

* Global: Focuses on the entire **environment**, the big picture global metrics.
* Cluster: Focuses on aggregated metrics for a single database cluster.
* Instance: Focuses on singleton instance objects: database instances, nodes, LBs, and various topic boards.
* Database (objects): Detailed information about activities, tables, and queries within the database.

Most of the monitoring dashboards can be jumped level through tables and tuples.


|                         Overview                         |                           Cluster                            |                         Instance                         |                           Database                           |
| :------------------------------------------------------: | :----------------------------------------------------------: | :------------------------------------------------------: | :----------------------------------------------------------: |
| [PGSQL Overview](http://demo.pigsty.cc/d/pgsql-overview) |    [PGSQL Cluster](http://demo.pigsty.cc/d/pgsql-cluster)    | [PGSQL Instance](http://demo.pigsty.cc/d/pgsql-instance) |   [PGSQL Database](http://demo.pigsty.cc/d/pgsql-database)   |
|   [PGSQL Alert](http://demo.pigsty.cc/d/pgsql-alert/)    |    [PGSQL Service](http://demo.pigsty.cc/d/pgsql-service)    |    [PGSQL Node](http://demo.pigsty.cc/d/pgsql-node/)     |     [PGSQL Tables](http://demo.pigsty.cc/d/pgsql-tables)     |
|    [PGSQL Shard](http://demo.pigsty.cc/d/pgsql-shard)    |  [PGSQL Database](http://demo.pigsty.cc/d/pgsql-databases)   |    [PGSQL Proxy](http://demo.pigsty.cc/d/pgsql-proxy)    |      [PGSQL Table](http://demo.pigsty.cc/d/pgsql-table)      |
| [PGSQL MatrixDB](http://demo.pigsty.cc/d/gpsql-overview) | [PGSQL Replication](http://demo.pigsty.cc/d/pgsql-replication) |    [PGSQL Xacts](http://demo.pigsty.cc/d/pgsql-xacts)    |      [PGSQL Query](http://demo.pigsty.cc/d/pgsql-query)      |
|                                                          |   [PGSQL Activity](http://demo.pigsty.cc/d/pgsql-activity)   |  [PGSQL Queries](http://demo.pigsty.cc/d/pgsql-queries)  | [PGCAT Table](http://demo.pigsty.cc/d/pgcat-table/pgcat-table) |
|                                                          | [PGSQL Cluster Monly](http://demo.pigsty.cc/d/pgsql-cluster-monly) |  [PGSQL Session](http://demo.pigsty.cc/d/pgsql-session)  |      [PGCAT Query](http://demo.pigsty.cc/d/pgcat-query)      |
|                                                          |                                                              | [PGCAT Instance](http://demo.pigsty.cc/d/pgcat-instance) |   [PGCAT Database](http://demo.pigsty.cc/d/pgcat-database)   |



## REDIS

REDIS monitor is divided into a global overview, singleton clusters, and singleton instances.

* [Redis Overview](http://demo.pigsty.cc/d/redis-overview)
* [Redis Cluster](http://demo.pigsty.cc/d/redis-cluster)
* [Redis Instance](http://demo.pigsty.cc/d/redis-instance)



## NODES

NODES monitor is divided into a global overview, single-node clusters, and single nodes.

* [Nodes Overview](http://demo.pigsty.cc/d/nodes-overview)
* [Nodes Cluster](http://demo.pigsty.cc/d/nodes-cluster)
* [Nodes Instance](http://demo.pigsty.cc/d/nodes-instance)
* [Nodes Alert](http://demo.pigsty.cc/d/nodes-alert)



## INFRA

INFRA Monitor is used to monitoring the infra and contains the following Dashboards.

* [Infra Overview](http://demo.pigsty.cc/d/infra-overview): Overview of the infra
* [Logs Instance](http://demo.pigsty.cc/d/logs-instance): View logs on single nodes
* [Nodes Alert](http://demo.pigsty.cc/d/nodes-alert): Host Alert
* [PGSQL Alert](http://demo.pigsty.cc/d/pgsql-alert/): PostgreSQL Alert



## APP

Pigsty comes with a typical application, PGLOG, for analyzing CSV log samples from PG.

* [PGLOG Overview](http://demo.pigsty.cc/d/pglog-overview)
* [PGLOG Session](http://demo.pigsty.cc/d/pglog-session)

Visit https://github.com/vonng/pigsty-app for more sample applications.
