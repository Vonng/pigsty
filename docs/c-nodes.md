# Concept: Nodes

> Pigsty uses **Nodes** for installation and deployment, which can be physical machines, VMs, or even Pods.



Pigsty has two types of nodes: [meta node](#Meta-Node) and [node](#node).

Meta nodes are used to initiate management, and nodes are included in Pigsty management.

* [Meta node](#Meta-Node): execute [`infra.yml`](p-infra.md) playbook to install Pigsty, **NODES**, and **PGSQL** modules.
* [Node](#node): execute [`nodes.yml`](p-nodes.md#nodes) playbook to include management, and install the **NODES** module by default.



## Meta Node

Meta-nodes are nodes with a complete installation of Pigsty with management functions deployed with an entire [infra](c-infra.md).

When you execute `./configure`, that node defaults to a meta node, populated in the [config](v-config.md) `meta` subgroup.

In each environment, **Pigsty needs at least one meta node that will act as the control center for the whole environment**. The meta node is responsible for various management tasks: saving state, managing configuration, initiating tasks, collecting metrics, etc. The infra components of the environment, Nginx, Grafana, Prometheus, Alertmanager, NTP, DNS Nameserver, and DCS, will all be deployed on the meta node.



### Meta Node Reuse

**The meta node can also be reused as a regular database node**, and a PostgreSQL cluster named `pg-meta` is run by default on the meta-node. Provides extended functions: CMDB, patrol reports, extended apps, log analysis, data analysis, etc.

Taking the four-node sandbox brought by Pigsty as an example, the distribution of components on the nodes is shown in the following figure.

![](_media/SANDBOX.gif)

The sandbox consists of a [meta node](#meta-node) with four [nodes](#nodes). The sandbox is deployed with one set of [infra](c-infra.md) and two sets of [database clusters](c-pgsql.md#cluster). `meta` is a meta node, deployed with **infra** and reused as a regular node, deployed with meta DB cluster `pg-meta`. `node-1`, `node-2`, and `node-3` are normal nodes deployed with cluster `pg-test`.


### Meta Node Service

The services running on the meta node are shown below.

|             Component     | Port | Description               |   Default Domain   |
| :---------------------------: | :--: | ----------------------------- | :----------: |
| Nginx        |  80  | Web Service Portal |   `pigsty`   |
| Yum      |  80  | LocalYum Repo    | `yum.pigsty` |
| Grafana      | 3000 | Monitoring System/Visualization Platform |  `g.pigsty`  |
| AlertManager | 9093 | Alert aggregation management component |  `a.pigsty`  |
| Prometheus   | 9090 | Monitoring Time Series Database |  `p.pigsty`  |
| Loki         | 3100 | Log Collection |  `l.pigsty`  |
| Consul (Server) | 8500 | Distributed Configuration Management and Service Discovery |  `c.pigsty`  |
| Docker       | 2375 | Container Platform |      -       |
| PostgreSQL   | 5432 | Pigsty CMDB                   |      -       |
| Ansible      |  -   | Initiate management commands |      -       |
| Consul DNS | 8600 | DNS Service（Optional） |      -       |
| Dnsmasq      |  53  | DNS Server（Optional） |      -       |
| NTP          | 123  | NTP Time Server（Optional） |      -       |
|           Pgbouncer           | 6432 | Pgbouncer Connection Pooling Service | - |
| Patroni | 8008 | Patroni HA Component | - |
| Haproxy Primary | 5433 | Primary connection pool: Read/Write Service | - |
| Haproxy Replica | 5434 | Replica connection pool: Read-only Service | - |
| Haproxy Default | 5436 | Primary Direct Connect Service | - |
| Haproxy Offline | 5438 | Offline Direct Connect: Offline Read Service | - |
| Haproxy Admin | 9101 | Monitoring metrics and traffic management | - |
| PG Exporter | 9630 | PG Monitoring Metrics Exporter | - |
| PGBouncer Exporter | 9631 | PGBouncer Monitoring Metrics Exporter | - |
| Node Exporter | 9100 | Node Monitoring Metrics Exporter | - |
| Promtail | 9080 | Collect Logs | - |
| vip-manager | - | Bind VIP to the primary |  |

![](_media/ARCH.gif)



### Meta Node & DCS

By default, a meta DB (Consul or Etcd) will be deployed on the meta node, or you can use **External DCS Cluster**. Any infra outside DCS will be deployed on the meta node as a peer-to-peer copy. The number of meta nodes requires a minimum of 1, recommends 3, and recommends no more than 5.

!> DCS is used to support fault detection and master selection for the HA database. **In default mode, stopping the DCS service will cause all clusters to reject writes,** so be sure to increase the number of meta nodes or use an external, independently maintained, HA DCS cluster.



### Multiple Meta Nodes

Usually, one meta node is sufficient, two meta nodes can be used as backups, and three meta nodes can be deployed for production-level DCS Server clusters. Pigsty recommends using 3-5 external dedicated DCS Server clusters to ensure HA of the meta DB. However, due to the battery-included principle, Pigsty deploys DCS Server on all meta nodes by default.

The node address of the meta node is configured in the `all.children.meta.host` subgroup of the config file with the `meta_node: true` flag. The current node performing the installation is configured as a meta node during [`configure`](v-config.md#configure), while multiple meta nodes need to be configured manually. See the sample config file for three managed nodes: [`pigsty-dcs3.yml`](https://github.com/Vonng/pigsty/files/conf/pigsty-dcs3.yml).



## Node

You can use Pigsty to manage more nodes and use these nodes to deploy various databases or your applications.

The nodes managed by Pigsty are adjusted by [`nodes.yml`](p-nodes.md#nodes) to the state described by [Config: NODES](v-nodes.md), and the node monitoring and log collection components are installed so you can check the node status and logs from the monitoring system.



### Node Identity

Each node has **identity parameters** that are configured by parameters in `<cluster>.hosts` and `<cluster>.vars`.

Pigsty uses an **IP address** as a unique identity for **database nodes**, **which must be the IP that the database instance listens to and serves externally**. Still, it is not appropriate to use a public IP address. Users also manage the target node through SSH tunneling or springboard machine relay. However, the IPv4 is still the core identity of the node, **which is very important**. The IP address, `inventory_hostname` of the host in the inventory, is reflected as the `key` in the `<cluster>.hosts` object.

In addition, nodes have two important identity parameters in the Pigsty monitoring system: [`nodename`](v-nodes.md#nodename) and [`node_cluster`](v-nodes.md#node-cluster), which will be used in the monitoring system as the node's **instance identity** (`ins`) and **cluster identity** (`cls`), when performing the default PostgreSQL deployment, since Pigsty defaults to a node-exclusive 1:1 deployment, the identity parameter of the database instance ([`pg_cluster`](v-pgsql.md#pg-hostname) and `pg_instance`) can be borrowed to the node's `ins` and `cls` via the [`pg_hostname`](v-pgsql.md#pg-hostname) tags on the node. 

|                   Name                    |   Type   | Level | Attribute | Description           |
| :---------------------------------------: | :------: | :---: | --------- | --------------------- |
|           `inventory_hostname`            |   `ip`   | **-** | **MUST**  | **Node IP**           |
|     [`nodename`](v-nodes.md#nodename)     | `string` | **I** | Optional  | **Node Name**         |
| [`node_cluster`](v-nodes.md#node-cluster) | `string` | **C** | Optional  | **Node Cluster Name** |

The following cluster configuration declares a three-node cluster.

```yaml
node-test:
  hosts:
    10.10.10.11: { nodename: node-test-1 }
    10.10.10.12: { pg_hostname: true } #Borrowed identity pg-test-2
    10.10.10.13: {  } # Use the original hostname: node-3
  vars:
    node_cluster: node-test
```

|     host      | node_cluster |   nodename    |  instance   |
| :-----------: | :----------: | :-----------: | :---------: |
| `10.10.10.11` | `node-test`  | `node-test-1` | `pg-test-1` |
| `10.10.10.12` | `node-test`  |  `pg-test-2`  | `pg-test-2` |
| `10.10.10.13` | `node-test`  |   `node-3`    | `pg-test-3` |

IIn the monitoring system, the time-series monitoring data are labeled as follows.

```json
node_load1{cls="pg-meta", ins="pg-meta-1", ip="10.10.10.10", job="nodes"}
node_load1{cls="pg-test", ins="pg-test-1", ip="10.10.10.11", job="nodes"}
node_load1{cls="pg-test", ins="pg-test-2", ip="10.10.10.12", job="nodes"}
node_load1{cls="pg-test", ins="pg-test-3", ip="10.10.10.13", job="nodes"}
```

### Node Services

|   Component   | Port | Description                                                |
| :-----------: | :--: | ---------------------------------------------------------- |
| Consul Agent  | 8500 | Distributed Configuration Management and Service Discovery |
| Node Exporter | 9100 | Node Monitoring Metrics Exporter                           |
|   Promtail    | 9080 | Collection of Postgres, Pgbouncer, Patroni logs (Optional) |
|  Consul DNS   | 8600 | DNS Service                                                |

### PGSQL Node Services

A **PGSQL node** is a node used to deploy a PostgreSQL cluster. In Pigsty, PGSQL instances are deployed **exclusively**, with one and only one database instance on a node, so the node and database instance can be uniquely identified with each other. In this case, you can use the [`pg_hostname`](v-pgsql.md#pg-hostname) parameter to assign the identity parameter of the database to the node.

In addition to [node default services]((c-nodes.md#node default services)), the following services are available on PGSQL nodes.

|     Component      | Port | Description                                                |
| :----------------: | :--: | ---------------------------------------------------------- |
|      Postgres      | 5432 | Pigsty CMDB                                                |
|     Pgbouncer      | 6432 | Pgbouncer Connection Pooling Service                       |
|      Patroni       | 8008 | Patroni HA Component                                       |
|       Consul       | 8500 | Distributed Configuration Management and Service Discovery |
|  Haproxy Primary   | 5433 | Primary connection pool: Read/Write Service                |
|  Haproxy Replica   | 5434 | Replica connection pool: Read-only Service                 |
|  Haproxy Default   | 5436 | Primary Direct Connect Service                             |
|  Haproxy Offline   | 5438 | Offline Direct Connect: Offline Read Service               |
| Haproxy `service`  | 543x | Customized Services                                        |
|   Haproxy Admin    | 9101 | Monitoring metrics and traffic management                  |
|    PG Exporter     | 9630 | PG Monitoring Metrics Exporter                             |
| PGBouncer Exporter | 9631 | PGBouncer Monitoring Metrics Exporter                      |
|   Node Exporter    | 9100 | Node Monitoring Metrics Exporter                           |
|      Promtail      | 9080 | Collection of Postgres, Pgbouncer, Patroni logs (Optional) |
|     Consul DNS     | 8600 | DNS Service                                                |
|    vip-manager     |  -   | Bind VIP to the primary                                    |



## Node Interaction

As an example of an environment consisting of a singleton [meta node](#Meta-Node) and a singleton [node](#node), the architecture is shown in the following figure.

![](_media/ARCH.gif)

The interaction between the meta node and the node consists mainly of:

* Database cluster/node domain name relies on Nameserver on the meta node for **resolution** (optional).
* Database node software **installation** requires the use of Yum Repo on the meta node.
* Prometheus collects database cluster/node monitoring **metrics** on the meta node.
* Database logs are collected by Protail and sent to Loki.
* Pigsty will initiate **management** of the database nodes from the meta node:
  * Cluster creation, expansion, and contraction, instance/cluster recovery
  * Creating business users, business databases, modifying services, and HBA modifications.
  * Log collection, garbage cleanup, backups, patrols, etc.
* The Consul of the database node synchronizes locally registered services to the DCS of the meta node.
* The database node will synchronize the time from the meta node (or other NTP server).
