## Architecture

A Pigsty **Deployment** is architecturally divided into two parts: one infrastructure, and multiple database clusters

* **[Infrastructure](#infrastructure) (Infra)** : deployed on **meta nodes**, monitoring, DNS, NTP, DCS, Yum sources, etc. Providing runtime for databases.
* **[Database Clusters](#database-clusters) (PgSQL)** : Deployed on **Database Nodes**, providing **Database Services** to the outside world as a cluster.

Infrastructure and database cluster are **loosely coupled**, removing infrastructure will not affect the operation of database cluster (except DCS).

!> DCS is used for fault detection and master selection to support high database availability. **Stopping DCS services in default mode will cause all database clusters to reject writes**, so be sure to ensure the reliability of DCS services (increase the number of meta nodes, or use an external, independently maintained, highly available DCS cluster).

Nodes (physical machines, virtual machines, Pods) are divided into two categories too:

* [Meta Nodes](#meta-node) (Meta): deploys the infrastructure, performs the control logic, and requires at least one meta node per Pigsty deployment.
* [Database Node](#database-node) (Node): used to deploy database clusters/instances, PG instances usually correspond to nodes one by one.

**The meta node can also be reused as a common database node**, on meta nodes, there is a PostgreSQL database cluster named `pg-meta` running by default.
Provides additional extensions: CMDB, inspection reports, extended applications, log analysis, data analysis and processing, etc.

Taking the four-node sandbox environment that comes with Pigsty as an example, the distribution of components on the nodes is shown in the following figure.

![](_media/sandbox.svg)

The sandbox consists of 1 [meta node](#meta-node) with four [database-nodes](#database-node) (the meta node is also reused as a database node), deployed with one set of [infrastructure](#infrastructure) and two sets of [database clusters](#database clusters). `meta` is a meta-node, deployed with **infrastructure** components, also multiplexed as a common database node, deployed with a single master database cluster `pg-meta`. `node-1`, `node-2`, `node-3` are normal database nodes, deployed with database cluster `pg-test`.


----------


## Infrastructure

In every Pigsty **Deployment** (Deployment) set, there is some infrastructure required to make the whole system work properly.

The infrastructure is usually handled by a dedicated Ops team or cloud vendor, but Pigsty, as an out-of-the-box product solution, integrates the basic infrastructure into the provisioning solution.

* Domain infrastructure: Dnsmasq (some requests are forwarded to Consul DNS for processing)
* Time infrastructure: NTP
* Monitoring infrastructure: Prometheus
* Alarm infrastructure: AlterManager
* Visualization infrastructure: Grafana
* Local source infrastructure: Yum/Nginx
* Distributed Configuration Storage: etcd/consul
* Metadatabase/CMDB: `pg-meta`
* Remote node control component: Ansible
* Data analysis visualization suite: Jupyterlab, Echarts, etc.
* Other: timed tasks, patrol scripts, backup scripts, command line tools, configuration GUI, other extended applications

The main relationships between the infrastructures are as follows.

* Nginx externally **exposes** all web services and forwards them differently by domain name.
* Dnsmasq provides DNS **resolution** services within the environment
  * DNS services are optional and can use existing DNS servers
  * Partial DNS resolution will be **forwarded** by Consul DNS
* Yum Repo is the default server for Nginx, providing the ability to install software from offline for all nodes in the environment.
* Grafana is the carrier for the Pigsty monitoring system, used to **visualize** data in Prometheus and CMDB.
* Prometheus is the chronological database for monitoring.
  * Prometheus obtains monitoring objects by default through local static file service discovery and associates identity information for them.
  * Prometheus can optionally use Consul service discovery to get monitoring objects automatically.
  * Prometheus pulls monitoring indicator data from Exporter, precomputes and processes it, and then stores it in its own TSDB.
  * Prometheus calculates alarm rules and sends the alarm events to Alertmanager for processing.
* Consul Server is used to save the status of DCS, reach consensus, and provide metadata query service.
* NTP Service is used to synchronize the time of all nodes in the environment (external NTP service is optional)
* Pigsty-related components.
  * MetaDB for supporting various advanced features (also a standard database cluster, pulled up by Ansible)
  * Ansible for executing scripts, initiating control, and accessing CMDB when using dynamic Inventory
  * Timed task controller (supports backup, cleanup, statistics, patrol, etc.), which accesses CMDB
  * Command line tool pigsty-cli will call Ansible Playbook

![](_media/meta.svg)

The infrastructure is deployed on [meta-node](#meta-node). A set of environments containing one or more meta nodes for infrastructure deployment.
All infrastructure components are deployed replica-style, except for **Distributed Configuration Storage (DCS)**.

?> If multiple meta nodes are configured, the DCSs (etcd/consul) on the meta nodes act together as a cluster of DCS servers.


## Meta Node

In each environment, **Pigsty requires at least one meta node, which will act as the control center** for the entire environment. The meta node is responsible for various administrative tasks: saving state, managing configuration, initiating tasks, collecting metrics, and so on. The infrastructure components of the entire environment, Nginx, Grafana, Prometheus, Alertmanager, NTP, DNS Nameserver, and DCS, will be deployed on the meta node.

The meta node will also be used to deploy the meta-database (Consul or Etcd), and users can also use existing **external DCS clusters**. If deploying DCS to the meta nodes, it is recommended that 3 meta nodes be used in a **production environment** to fully guarantee the availability of DCS services. infrastructure components outside of DCS will be deployed as peer-to-peer copies on all meta nodes. The number of meta nodes requires a minimum of 1, recommends 3, and recommends no more than 5.

The default services running on the meta nodes are shown below.

| Component | Port | Default Domain | Description |
| :-----------: | :--: | :----------: | ------------------------------- |
| Grafana | 3000 | `g.pigsty` | Pigsty Monitoring System GUI |
| Prometheus | 9090 | `p.pigsty` | Monitoring Timing Database |
| AlertManager | 9093 | `a.pigsty` | Alarm aggregation management component |
| Consul | 8500 | `c.pigsty` | Distributed Configuration Management, Service Discovery |
| Consul DNS | 8600 | - | Consul-provided DNS services |
| Nginx | 80 | `pigsty` | Entry proxy for all services |
| Yum Repo | 80 | `yum.pigsty` | Local Yum sources |
| Haproxy Index | 80 | `h.pigsty` | Access proxy for all Haproxy management interfaces |
| NTP | 123 | `n.pigsty` | The NTP time server used uniformly by the environment |
| Dnsmasq | 53 | - | The DNS name resolution server used by the environment |
| Loki | 3100 | - | Real-time log collection infrastructure (optional) |



## Database Cluster

The production environment's databases are organized in **clusters**,
which are a **logical entity** consisting of a set of database **instances** associated by **master-slave replication**.
Each database cluster is  autonomous business unit consisting of at least one **database instance**.

Clusters are the basic business service units,
and the following diagram shows the replication topology in a sandbox environment.
Where `pg-meta-1` alone constitutes a database cluster `pg-meta`,
while `pg-test-1`, `pg-test-2`, and `pg-test-3` together constitute another logical cluster `pg-test`.

```
pg-meta-1
(primary)

pg-test-1 -------------> pg-test-2
(primary)      |         (replica)
               |
               ^-------> pg-test-3
                         (replica)
```

The following figure rearranges the location of related components in the `pg-test` cluster from the perspective of a database cluster.

![](_media/access.svg)


Pigsty is a database provisioning solution that creates **highly available database clusters** on demand. Pigsty can **automatically failover**, with business-side read-only traffic unaffected; the impact of read and write traffic is usually in the range of a few seconds to tens of seconds, depending on the specific configuration and load.

In Pigsty, each "database instance" is **idempotent** , using a NodePort-like approach to expose [**service**](c-service.md) to the public.
By default, Port 5433 of **any instance** routes to the primary, and port 5434 routes the replicas. 
You can also access to the database with different approaches, refer to: [**Database Access**](c-access.md) for details.



## Database Node

A **database node** is responsible for running **database instances**. In Pigsty database instances are fixed using **exclusive deployment**, where there is one and only one database instance on a node, so nodes and database instances can be uniquely identified with each other (IP address and instance name).

A typical service running on a database node is shown below.

| component | port | description |
| :------------------: | :--: | ----------------------------------------------------- |
| Postgres | 5432 | Postgres Database Service |              
| Pgbouncer | 6432 | Pgbouncer Connection Pooling Service |              
| Patroni | 8008 | Patroni High Availability Components |              
| Consul | 8500 | Distributed Configuration Management, Local Agent for Service Discovery Component Consul |              
| Haproxy Primary | 5433 | Cluster read and write service (primary connection pool) agent |              
| Haproxy Replica | 5434 | Cluster Read-Only Service (Slave Connection Pool) Agent |              
| Haproxy Default | 5436 | Cluster Master Direct Connect Service (for management, DDL/DML changes) |              
| Haproxy Offline | 5438 | Cluster Offline Read Service (directly connected offline instances, for ETL, interactive queries) |
| Haproxy `service` | 543x | *Additional custom services provided by the cluster will be assigned ports in sequence* |              
| Haproxy Admin | 9101 | Haproxy Monitoring Metrics and Traffic Management Page |              
| PG Exporter | 9630 | Postgres Monitoring Metrics Exporter |              
| PGBouncer Exporter | 9631 | Pgbouncer Monitoring Metrics Exporter |              
| Node Exporter | 9100 | Machine Node Monitoring Metrics Exporter |              
| promtail | 9080 | Real-time collection of Postgres, Pgbouncer, Patroni logs (optional) |
| Consul DNS | 8600 | Consul-provided DNS service |              
| vip-manager | x | Bind VIPs to the cluster master |


![](_media/node.svg)

The main interactions are as follows.

* vip-manager obtains cluster master information by **querying** Consul and binds the cluster-specific L2 VIP to the master node (default sandbox access scheme).
* Haproxy is the database **traffic** portal for exposing services to the outside world, using different ports (543x) to distinguish different services.
  * Haproxy port 9101 exposes Haproxy's internal monitoring metrics, while providing an Admin interface to control traffic.
  * Haproxy port 5433 points to the cluster master connection pool port 6432 by default
  * Haproxy port 5434 points to the cluster slave connection pool port 6432 by default
  * Haproxy 5436 port points directly to the cluster master 5432 port by default
  * Haproxy 5438 port defaults to point directly to the cluster offline instance port 5432
* Pgbouncer for **pooling** database connections, buffering failure shocks, and exposing additional metrics.
  * Production services (high frequency non-interactive, 5433/5434) must be accessed through Pgbouncer.
  * Directly connected services (management and ETL, 5436/5438) must bypass the Pgbouncer direct connection.
* Postgres provides the actual database service, which constitutes a master-slave database cluster via stream replication.
* Patroni is used to **oversee** the Postgres service and is responsible for master-slave election and switchover, health checks, and configuration management.
  * Patroni uses Consul to reach **consensus** as the basis for cluster leader election.
* Consul Agent is used to issue configurations, accept service registrations, service discovery, and provide DNS queries.
  * All process services using the port are **registered** into Consul
* PGB Exporter, PG Exporter, and Node Exporter are used to **expose** database, connection pool, and node monitoring metrics respectively
* Promtail is an optional log collection component that sends captured PG, PGB, Patroni logs to infrastructure Loki


## Interaction

Here is an example of a single [meta node](#meta-node) and a single [database node](#database-node).

![](_media/infra.svg)

The interaction between the meta nodes and the database nodes mainly consists of.
* The domain name of the database cluster/node depends on the Nameserver of the meta node for **resolution** (optional).
* Database node software **installation** requires the use of Yum Repo on the meta node.
* Database cluster/node monitoring **metrics** will be collected by Prometheus on the meta node.
* Logs from Postgres, Patroni, Pgbouncer in the database cluster will be collected by Protail and sent to Loki.
* Pigsty will initiate **administration** of database nodes from the meta node:
  * Perform cluster creation, expansion and contraction, instance/cluster recycling
  * creating business users, business databases, modifying services, HBA modifications.
  * Performing log collection, garbage cleanup, backup, patrol, etc.
* Consul of database node will synchronize locally registered services to DCS of meta node and proxy state read/write operations.
* Database node will synchronize time from meta node (or other NTP server)
