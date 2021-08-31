## Dashboards

Pigsty by provides a professional and easy-to-use PostgreSQL monitoring system that distills the industry's monitoring best practices.

Users can easily modify and customize; reuse the monitoring infrastructure or integrate with other monitoring systems.

## Applications

The Pigsty monitoring panel consists of three relatively independent applications: [`PGSQL`](http://demo.pigsty.cc/d/pgsql-overview), [`PGCAT`](http://demo.pigsty.cc/d/pgcat-table), [`PGLOG`]( http://demo.pigsty.cc/d/pglog-instance).

| Application | Description |
| ------- | -------------------------------- |
| `PGSQL` | Visual Monitoring Metrics, **Time Series** Data |
| `PGCAT` | Present, analyze system catalog metadata |
| `PGLOG` | Present and analyze **log** data |


## Hierarchy

The monitoring panel has its own hierarchy, from top to bottom, as follows

* Global: Focuses on the entire **environment**, the big picture global metrics
* Cluster: Focuses on aggregated metrics for a single database cluster
* Instance: Focuses on individual instance objects: database instances, nodes, load balancers, various topic panels
* Database (objects): detailed information about activities, tables and queries within the database

Most of the monitoring panels can be jumped through tables, graph elements.



|            Overview             |            Cluster             |           Instance             |           Database          |
| :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
|        [PGSQL Overview](http://demo.pigsty.cc/d/pgsql-overview)        |  [PGSQL Cluster](http://demo.pigsty.cc/d/pgsql-cluster)  | [PGSQL Instance](http://demo.pigsty.cc/d/pgsql-instance) | [PGSQL Database](http://demo.pigsty.cc/d/pgsql-database) |
| [PGSQL Alert](http://demo.pigsty.cc/d/pgsql-alert/) | [PGSQL Service](http://demo.pigsty.cc/d/pgsql-service) | [PGSQL Node](http://demo.pigsty.cc/d/pgsql-node/) | [PGSQL Tables](http://demo.pigsty.cc/d/pgsql-tables) |
|  | [PGSQL Activity](http://demo.pigsty.cc/d/pgsql-activity) | [PGSQL Proxy](http://demo.pigsty.cc/d/pgsql-proxy) | [PGSQL Table](http://demo.pigsty.cc/d/pgsql-table) |
|  | [PGSQL Replication](http://demo.pigsty.cc/d/pgsql-replication) | [PGSQL Xacts](http://demo.pigsty.cc/d/pgsql-xacts) | [PGSQL Query](http://demo.pigsty.cc/d/pgsql-query) |
|  |  | [PGSQL Queries](http://demo.pigsty.cc/d/pgsql-queries) |  |
|  |  |        [PGSQL Session](http://demo.pigsty.cc/d/pgsql-session)        |        |
| [Home](http://demo.pigsty.cc/d/home) |  | **PGLOG** | **PGCAT** |
|            |  |  [PGLOG Instance](http://demo.pigsty.cc/d/pglog-instance)  | [PGCAT Table](http://demo.pigsty.cc/d/pgcat-table/pgcat-table) |
|  |  | [PGLOG Analysis](http://demo.pigsty.cc/d/pglog-analysis) | [PGCAT Query](http://demo.pigsty.cc/d/pgcat-query) |
|  |  | [PGLOG Session](http://demo.pigsty.cc/d/pglog-session) | [PGCAT Bloat](http://demo.pigsty.cc/d/pgcat-bloat) |

