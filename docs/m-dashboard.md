# Pigsty Dashboards

Pigsty provides a professional and easy-to-use PostgreSQL monitoring system that distills the industry's monitoring best practices.

Users can easily modify and customize it; reuse the monitoring infrastructure or integrate it with other monitoring systems.

The Pigsty monitoring panel consists of several relatively independent panels.

| Application                          | Description                       |
| ------------------------------------ | --------------------------------- |
| [Home](http://demo.pigsty.cc/d/home) | Home                              |
| [`PGSQL`](#PGSQL)                    | PostgreSQL Database Monitor       |
| [`REDIS`](#REDIS)                    | Redis Database Monitor            |
| [`NODES`](#NODES)                    | Host Node Monitor                 |
| [`INFRA`](#INFRA)                    | Infrastructure monitoring/logging |
| [ APP](#APP)                         | Additional retrofit applications  |



## HOME

Pigsty's home page provides navigation to the various boards.

* [HOME](http://demo.pigsty.cc/d/home)



## PGSQL

The PostgreSQL monitoring panel has its level, from the top down, as follows：

* Global: Focuses on the entire **environment**, the big picture global metrics
* Cluster: Focuses on aggregated metrics for a single database cluster
* Instance: Focuses on individual instance objects: database instances, nodes, load balancers, various topic panels
* Database (objects): detailed information about activities, tables, and queries within the database

Most of the monitoring panels can be jumped level through tables, and tuples, allowing you to quickly scroll up and drill down.


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

REDIS monitoring is divided into three levels: a global overview, individual clusters, and individual instances.

* [Redis Overview](http://demo.pigsty.cc/d/redis-overview)
* [Redis Cluster](http://demo.pigsty.cc/d/redis-cluster)
* [Redis Instance](http://demo.pigsty.cc/d/redis-instance)



## NODES

NODES monitoring is divided into three levels: a global overview, individual node clusters, and individual nodes.

* [Nodes Overview](http://demo.pigsty.cc/d/nodes-overview)
* [Nodes Cluster](http://demo.pigsty.cc/d/nodes-cluster)
* [Nodes Instance](http://demo.pigsty.cc/d/nodes-instance)
* [Nodes Alert](http://demo.pigsty.cc/d/nodes-alert)



## INFRA

INFRA Monitor is used to monitoring the infrastructure itself and contains the following Dashboards.

* [Infra Overview](http://demo.pigsty.cc/d/infra-overview): Overview of the infrastructure
* [Logs Instance](http://demo.pigsty.cc/d/logs-instance): View logs on individual nodes
* [Nodes Alert](http://demo.pigsty.cc/d/nodes-alert): Host Alert
* [PGSQL Alert](http://demo.pigsty.cc/d/pgsql-alert/): PostgreSQL database alert



## APP

Pigsty comes with a typical application, PGLOG, for analyzing CSV log samples from PG itself.

* [PGLOG Overview](http://demo.pigsty.cc/d/pglog-overview)
* [PGLOG Session](http://demo.pigsty.cc/d/pglog-session)

Visit https://github.com/vonng/pigsty-app for more sample applications.
