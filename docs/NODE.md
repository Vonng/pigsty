# Concept: Nodes

> Pigsty use **nodes** for deployment, nodes cloud be physical machines, VMs, or even Pods.



Pigsty has two types of nodes: [meta node](#Meta-Node) and (normal) [node](#node).

Meta nodes are used to initiate control, and (normal) nodes are managed under control.

* [Meta node](#Meta-Node): Run [`infra.yml`](p-infra.md) playbook to install Pigsty, **INFRA**, **NODES**, and **PGSQL** modules.
* [Node](#node): Run [`nodes.yml`](p-nodes.md#nodes) playbook to join Pigsty, and install the **NODES** module by default.



## Meta Node

Meta-Nodes are nodes installed with Pigsty, with admin capability and a complete [infra](c-infra.md) set.

Current node are marked as meta during  `./configure`, populated in the `meta` group of [inventory](v-config.md).

Pigsty requires at least one meta node per environment. It will be used as a command center for the entire environment. It's the meta node's responsibility to keep states, manage configs, launch plays, run tasks, and collect metrics & logs. The infra set is deployed on meta nodes by default: Nginx, Grafana, Prometheus, Alertmanager, NTP, DNS Nameserver, and DCS.



### Reuse Meta Node

**The meta node can also be reused as a common node**, and a PostgreSQL cluster named `pg-meta` is created by default on the meta. Supporting additional features: CMDB, routine tasks report, extended apps, log analysis & data analysis, etc.

Taking Pigsty [Sandbox](d-sandbox.md) as an example, the distribution of components on the nodes is shown below.

![](_media/SANDBOX.gif)

The sandbox consists of a [meta node](#Meta-Node) with 4 [nodes](#node). The sandbox is deployed with one set of [infra](c-infra.md) and 2 [database clusters](c-pgsql.md#cluster). `meta` is the meta node, deployed with **infra** and reused as a regular node, deployed with meta DB cluster `pg-meta`. `node-1`, `node-2`, and `node-3` are normal nodes deployed with cluster `pg-test`.



### Meta Node Service

The services running on the meta node are shown below.

|             Component     | Port | Description               |   Default Domain   |
| :---------------------------: | :--: | ----------------------------- | :----------: |
| Nginx        |  80  | Web Service Portal |   `pigsty`   |
| Yum          |  80  | LocalYum Repo    | `yum.pigsty` |
| Grafana      | 3000 | Monitoring Dashboards/Visualization Platform |  `g.pigsty`  |
| AlertManager | 9093 | Alert aggregation & notification service |  `a.pigsty`  |
| Prometheus   | 9090 | Monitoring Time-Series Database |  `p.pigsty`  |
| Loki         | 3100 | Logging Database |  `l.pigsty`  |
| Consul (Server) | 8500 | Distributed Configuration Management and Service Discovery |  `c.pigsty`  |
| Docker       | 2375 | Container Platform |      -       |
| PostgreSQL   | 5432 | Pigsty CMDB                   |      -       |
| lAnsible     |  -   | Controller |      -       |
| Consul DNS | 8600 | DNS Service Discovery powered by Consul                    |      -       |
| Dnsmasq      |  53  | DNS Name Server（Optional） |      -       |
| NTP          | 123  | NTP Time Server（Optional） |      -       |
| Pgbouncer | 6432 | Pgbouncer Connection Pooling Service | - |
| Patroni | 8008 | Patroni HA Component | - |
| Haproxy Primary | 5433 | Primary Pooling: Read/Write Service | - |
| Haproxy Replica | 5434 | Replica Pooling: Read-Only Service | - |
| Haproxy Default | 5436 | Primary Direct Connect Service | - |
| Haproxy Offline | 5438 | Offline Direct Connect: Offline Read Service | - |
| Haproxy Admin | 9101 | HAProxy admin & metrics                                    | - |
| PG Exporter | 9630 | PG Monitoring Metrics Exporter | - |
| PGBouncer Exporter | 9631 | PGBouncer Monitoring Metrics Exporter | - |
| Node Exporter | 9100 | Node monitoring metrics | - |
| Promtail | 9080 | Logger agent | - |
| vip-manager | - | Bind VIP to the primary |  |

![](_media/ARCH.gif)



### Meta Node & DCS

By default, DCS Servers (Consul or Etcd) will be deployed on the meta nodes, or you can use **External DCS Cluster**. Any infra outside DCS will be deployed on the meta node as a peer-to-peer copy. The number of meta nodes requires a minimum of 1, recommends 3, and recommends no more than 5.

!> DCS Servers are used for leader election in HA Scenarios. **Shutting down the DCS servers will demote ALL clusters, which reject any writes by default!** So make sure you have enough availability on these DCS Servers, at least stronger than PostgreSQL itself. It's recommended to add more meta nodes or use an external independently maintained, HA DCS cluster for production-grade deployment.



### Multiple Meta Nodes

Usually, one meta node is sufficient for basic usage, two meta nodes can be used as standby backup, and 3 meta nodes can support a minimal meaningful production-grade DCS Servers themselves!

Pigsty will set DCS Servers on all meta nodes by default for the sake of "Battery-Included". But it's meaningless to have more than 3 meta nodes. If you are seeking HA DCS Servies. Using an external DCS Cluster with 3~5 nodes would be more appropriate.

Meta nodes are configured under `all.children.meta.host` in the [inventory](v-config.md). They will be marked with `meta_node: true` flag. The node runs `configure` will be marked as meta, and multiple meta nodes have to be configured manually, check  [`pigsty-dcs3.yml`](https://github.com/Vonng/pigsty/files/conf/pigsty-dcs3.yml) for example.

If you are not using any external DCS as an arbiter. It requires at least 3 nodes to form a meaningful HA Cluster that allows one node failure. 



## Node

You can manage more nodes with Pigsty, and use them to deploy various databases or your applications.

The nodes managed by Pigsty are adjusted by [`nodes.yml`](p-nodes.md#nodes) to the state described by [Config: NODES](v-nodes.md), and the node monitoring and log collection components are installed so you can check the node status and logs from the monitoring system.



### Node Identity

Each node has [identity parameters](v-nodes.md#NODE_IDENTITY) that are configured by parameters in `<cluster>.hosts` and `<cluster>.vars`.

There are two important node identity parameters: [`nodename`](v-nodes.md#nodename) and [`node_cluster`](v-nodes.md#node_cluster), which will be used as the node's **instance identity** (`ins`) and **cluster identity** (`cls`)  in the monitoring system. [`nodename`](v-nodes.md#nodename) and [`node_cluster`](v-nodes.md#node_cluster) are NOT **REQUIRED** since they all have proper default values: Hostname and constant `nodes`.

Besides, Pigsty uses an **IP address** as a unique node identifier, too. Which is the `inventory_hostname`  reflected as the `key` in the `<cluster>.hosts` object. A node may have multiple interfaces & IP addresses. But you must explicitly designate one as the **PRIMARY IP ADDRESS**. **Which should be an intranet IP for service access**. It's not mandatory to use that same IP address to ssh from the meta node, you can use ssh tunnel & jump server with  [`Ansible Connect`](v-infra.md#CONNECT) parameters.

|                   Name                    |   Type   | Level | Attribute    | Description           |
| :---------------------------------------: | :------: | :---: | ------------ | --------------------- |
|           `inventory_hostname`            |   `ip`   | **-** | **REQUIRED** | **Node IP**           |
|     [`nodename`](v-nodes.md#nodename)     | `string` | **I** | Optional     | **Node Name**         |
| [`node_cluster`](v-nodes.md#node_cluster) | `string` | **C** | Optional     | **Node Cluster Name** |

The following cluster configuration declares a three-node cluster.

```yaml
node-test:
  hosts:
    10.10.10.11: { nodename: node-test-1 }
    10.10.10.12: { pg_hostname: true } # Borrowed identity pg-test-2
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



### PGSQL Node

A **PGSQL Node** is a node with a [PGSQL](c-pgsql.md) module installed.

Pigsty uses **exclusively** deploy policy for PGSQL. This means the node's identity and pgsql's identity are exchangeable.  The [`pg_hostname`](v-pgsql.md#pg_hostname) parameter is designed to assign the Postgres identity to its underlying node: `pg_instance` and `pg_cluster` will be assigned to the node's [`nodename`](v-nodes.md#nodename) & [`node_cluster`](v-nodes.md#node_cluster).

In addition to [node default services](#node-services), the following services are available on PGSQL nodes.

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

Here's an example of interactions between a meta node & a common node.

![](_media/ARCH.gif)

The interaction between the meta node and common nodes are:

* Database cluster/node domain name resolved by Nameserver on meta node. (optional)
* Database node software **installation** will use Yum Repo on meta.
* Prometheus collects database cluster/node monitoring **metrics** on meta.
* Database logs are collected by Promtail and sent to Loki.
* Pigsty will control database nodes from the meta node:
  * Cluster creation, scale in / scale out, instance/cluster recycling
  * Creating business users & databases, modifying services routes & HBA rules.
  * Log collection, vacuum analyze, backup, and other routine tasks, etc.
* Node's Consul will sync locally registered services to the DCS Servers.
* The database node will synchronize time from the meta node (or other NTP server).





## Parameters

There are 10 sections, 58 parameters about [`NODE`](PARAM#NODE) module.


- [`NODE_ID`](PARAM#node_id)             : Node identity parameters        
- [`NODE_DNS`](PARAM#node_dns)           : Node Domain Name Resolution     
- [`NODE_PACKAGE`](PARAM#node_package)   : Upstream Repo & Install Packages
- [`NODE_TUNE`](PARAM#node_tune)         : Node Tuning & Features          
- [`NODE_ADMIN`](PARAM#node_admin)       : Admin User & SSH Keys           
- [`NODE_TIME`](PARAM#node_time)         : Timezone, NTP, Crontab          
- [`HAPROXY`](PARAM#haproxy)             : Expose services with HAProxy    
- [`DOCKER`](PARAM#docker)               : Docker daemon on node           
- [`NODE_EXPORTER`](PARAM#node_exporter) : Node monitoring agent           
- [`PROMTAIL`](PARAM#promtail)           : Promtail logging agent          



| Parameter                                                  | Section                                |   Type    | Level | Comment                                                   |
|------------------------------------------------------------|----------------------------------------|:---------:|:-----:|-----------------------------------------------------------|
| [`nodename`](PARAM#nodename)                               | [`NODE_ID`](PARAM#node_id)             |  string   |   I   | node instance identity, use hostname if missing, optional |
| [`node_cluster`](PARAM#node_cluster)                       | [`NODE_ID`](PARAM#node_id)             |  string   |   C   | node cluster identity, use 'nodes' if missing, optional   |
| [`nodename_overwrite`](PARAM#nodename_overwrite)           | [`NODE_ID`](PARAM#node_id)             |   bool    |   C   | overwrite node's hostname with nodename?                  |
| [`nodename_exchange`](PARAM#nodename_exchange)             | [`NODE_ID`](PARAM#node_id)             |   bool    |   C   | exchange nodename among play hosts?                       |
| [`node_id_from_pg`](PARAM#node_id_from_pg)                 | [`NODE_ID`](PARAM#node_id)             |   bool    |   C   | use postgres identity as node identity if applicable?     |
| [`node_default_etc_hosts`](PARAM#node_default_etc_hosts)   | [`NODE_DNS`](PARAM#node_dns)           | string[]  |   G   | static dns records in `/etc/hosts`                        |
| [`node_etc_hosts`](PARAM#node_etc_hosts)                   | [`NODE_DNS`](PARAM#node_dns)           | string[]  |   C   | extra static dns records in `/etc/hosts`                  |
| [`node_dns_method`](PARAM#node_dns_method)                 | [`NODE_DNS`](PARAM#node_dns)           |   enum    |   C   | how to handle dns servers: add,none,overwrite             |
| [`node_dns_servers`](PARAM#node_dns_servers)               | [`NODE_DNS`](PARAM#node_dns)           | string[]  |   C   | dynamic nameserver in `/etc/resolv.conf`                  |
| [`node_dns_options`](PARAM#node_dns_options)               | [`NODE_DNS`](PARAM#node_dns)           | string[]  |   C   | dns resolv options in `/etc/resolv.conf`                  |
| [`node_repo_method`](PARAM#node_repo_method)               | [`NODE_PACKAGE`](PARAM#node_package)   |   enum    |   C   | how to setup node repo: none,local,public                 |
| [`node_repo_remove`](PARAM#node_repo_remove)               | [`NODE_PACKAGE`](PARAM#node_package)   |   bool    |   C   | remove existing repo on node?                             |
| [`node_repo_local_urls`](PARAM#node_repo_local_urls)       | [`NODE_PACKAGE`](PARAM#node_package)   | string[]  |   C   | local repo url, if node_repo_method = local               |
| [`node_packages`](PARAM#node_packages)                     | [`NODE_PACKAGE`](PARAM#node_package)   | string[]  |   C   | packages to be installed current nodes                    |
| [`node_default_packages`](PARAM#node_default_packages)     | [`NODE_PACKAGE`](PARAM#node_package)   | string[]  |   G   | default packages to be installed on all nodes             |
| [`node_disable_firewall`](PARAM#node_disable_firewall)     | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | disable node firewall? true by default                    |
| [`node_disable_selinux`](PARAM#node_disable_selinux)       | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | disable node selinux? true by default                     |
| [`node_disable_numa`](PARAM#node_disable_numa)             | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | disable node numa, reboot required                        |
| [`node_disable_swap`](PARAM#node_disable_swap)             | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | disable node swap, use with caution                       |
| [`node_static_network`](PARAM#node_static_network)         | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | preserve dns resolver settings after reboot               |
| [`node_disk_prefetch`](PARAM#node_disk_prefetch)           | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | setup disk prefetch on HDD to increase performance        |
| [`node_kernel_modules`](PARAM#node_kernel_modules)         | [`NODE_TUNE`](PARAM#node_tune)         | string[]  |   C   | kernel modules to be enabled on this node                 |
| [`node_hugepage_ratio`](PARAM#node_hugepage_ratio)         | [`NODE_TUNE`](PARAM#node_tune)         |   float   |   C   | node mem hugepage ratio, 0 disable it by default          |
| [`node_tune`](PARAM#node_tune)                             | [`NODE_TUNE`](PARAM#node_tune)         |   enum    |   C   | node tuned profile: none,oltp,olap,crit,tiny              |
| [`node_sysctl_params`](PARAM#node_sysctl_params)           | [`NODE_TUNE`](PARAM#node_tune)         |   dict    |   C   | sysctl parameters in k:v format in addition to tuned      |
| [`node_data`](PARAM#node_data)                             | [`NODE_ADMIN`](PARAM#node_admin)       |   path    |   C   | node main data directory, `/data` by default              |
| [`node_admin_enabled`](PARAM#node_admin_enabled)           | [`NODE_ADMIN`](PARAM#node_admin)       |   bool    |   C   | create a admin user on target node?                       |
| [`node_admin_uid`](PARAM#node_admin_uid)                   | [`NODE_ADMIN`](PARAM#node_admin)       |    int    |   C   | uid and gid for node admin user                           |
| [`node_admin_username`](PARAM#node_admin_username)         | [`NODE_ADMIN`](PARAM#node_admin)       | username  |   C   | name of node admin user, `dba` by default                 |
| [`node_admin_ssh_exchange`](PARAM#node_admin_ssh_exchange) | [`NODE_ADMIN`](PARAM#node_admin)       |   bool    |   C   | exchange admin ssh key among node cluster                 |
| [`node_admin_pk_current`](PARAM#node_admin_pk_current)     | [`NODE_ADMIN`](PARAM#node_admin)       |   bool    |   C   | add current user's ssh pk to admin authorized_keys        |
| [`node_admin_pk_list`](PARAM#node_admin_pk_list)           | [`NODE_ADMIN`](PARAM#node_admin)       | string[]  |   C   | ssh public keys to be added to admin user                 |
| [`node_timezone`](PARAM#node_timezone)                     | [`NODE_TIME`](PARAM#node_time)         |  string   |   C   | setup node timezone, empty string to skip                 |
| [`node_ntp_enabled`](PARAM#node_ntp_enabled)               | [`NODE_TIME`](PARAM#node_time)         |   bool    |   C   | enable chronyd time sync service?                         |
| [`node_ntp_servers`](PARAM#node_ntp_servers)               | [`NODE_TIME`](PARAM#node_time)         | string[]  |   C   | ntp servers in `/etc/chrony.conf`                         |
| [`node_crontab_overwrite`](PARAM#node_crontab_overwrite)   | [`NODE_TIME`](PARAM#node_time)         |   bool    |   C   | overwrite or append to `/etc/crontab`?                    |
| [`node_crontab`](PARAM#node_crontab)                       | [`NODE_TIME`](PARAM#node_time)         | string[]  |   C   | crontab entries in `/etc/crontab`                         |
| [`haproxy_enabled`](PARAM#haproxy_enabled)                 | [`HAPROXY`](PARAM#haproxy)             |   bool    |   C   | enable haproxy on this node?                              |
| [`haproxy_clean`](PARAM#haproxy_clean)                     | [`HAPROXY`](PARAM#haproxy)             |   bool    | G/C/A | cleanup all existing haproxy config?                      |
| [`haproxy_reload`](PARAM#haproxy_reload)                   | [`HAPROXY`](PARAM#haproxy)             |   bool    |   A   | reload haproxy after config?                              |
| [`haproxy_auth_enabled`](PARAM#haproxy_auth_enabled)       | [`HAPROXY`](PARAM#haproxy)             |   bool    |   G   | enable authentication for haproxy admin page              |
| [`haproxy_admin_username`](PARAM#haproxy_admin_username)   | [`HAPROXY`](PARAM#haproxy)             | username  |   G   | haproxy admin username, `admin` by default                |
| [`haproxy_admin_password`](PARAM#haproxy_admin_password)   | [`HAPROXY`](PARAM#haproxy)             | password  |   G   | haproxy admin password, `pigsty` by default               |
| [`haproxy_exporter_port`](PARAM#haproxy_exporter_port)     | [`HAPROXY`](PARAM#haproxy)             |   port    |   C   | haproxy admin/exporter port, 9101 by default              |
| [`haproxy_client_timeout`](PARAM#haproxy_client_timeout)   | [`HAPROXY`](PARAM#haproxy)             | interval  |   C   | client side connection timeout, 24h by default            |
| [`haproxy_server_timeout`](PARAM#haproxy_server_timeout)   | [`HAPROXY`](PARAM#haproxy)             | interval  |   C   | server side connection timeout, 24h by default            |
| [`haproxy_services`](PARAM#haproxy_services)               | [`HAPROXY`](PARAM#haproxy)             | service[] |   C   | list of haproxy service to be exposed on node             |
| [`docker_enabled`](PARAM#docker_enabled)                   | [`DOCKER`](PARAM#docker)               |   bool    |   C   | enable docker on this node?                               |
| [`docker_cgroups_driver`](PARAM#docker_cgroups_driver)     | [`DOCKER`](PARAM#docker)               |   enum    |   C   | docker cgroup fs driver: cgroupfs,systemd                 |
| [`docker_registry_mirrors`](PARAM#docker_registry_mirrors) | [`DOCKER`](PARAM#docker)               | string[]  |   C   | docker registry mirror list                               |
| [`docker_image_cache`](PARAM#docker_image_cache)           | [`DOCKER`](PARAM#docker)               |   path    |   C   | docker image cache dir, `/tmp/docker` by default          |
| [`node_exporter_enabled`](PARAM#node_exporter_enabled)     | [`NODE_EXPORTER`](PARAM#node_exporter) |   bool    |   C   | setup node_exporter on this node?                         |
| [`node_exporter_port`](PARAM#node_exporter_port)           | [`NODE_EXPORTER`](PARAM#node_exporter) |   port    |   C   | node exporter listen port, 9100 by default                |
| [`node_exporter_options`](PARAM#node_exporter_options)     | [`NODE_EXPORTER`](PARAM#node_exporter) |    arg    |   C   | extra server options for node_exporter                    |
| [`promtail_enabled`](PARAM#promtail_enabled)               | [`PROMTAIL`](PARAM#promtail)           |   bool    |   C   | enable promtail logging collector?                        |
| [`promtail_clean`](PARAM#promtail_clean)                   | [`PROMTAIL`](PARAM#promtail)           |   bool    |  G/A  | purge existing promtail status file during init?          |
| [`promtail_port`](PARAM#promtail_port)                     | [`PROMTAIL`](PARAM#promtail)           |   port    |   C   | promtail listen port, 9080 by default                     |
| [`promtail_positions`](PARAM#promtail_positions)           | [`PROMTAIL`](PARAM#promtail)           |   path    |   C   | promtail position status file path                        |