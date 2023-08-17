# NODE

> Tune nodes into the desired state and monitor it.


----------------

## Concept

Node is an abstraction of hardware resources, which can be bare metal, virtual machines, or even k8s pods.

There are different types of nodes in Pigsty:

* Common nodes, nodes that managed by Pigsty
* Admin node, the node where pigsty is installed and issue admin commands
* The Infra node, the node where the INFRA module is installed, admin node are usually the first of all infra nodes.


**Common Node**

You can manage nodes with Pigsty, and install modules on them. The `node.yml` playbook will adjust the node to desired state.

Some services will be added to all nodes by default:

|   Component   | Port | Description                      |
|:-------------:|:----:|----------------------------------|
| Node Exporter | 9100 | Node Monitoring Metrics Exporter |
| HAProxy Admin | 9101 | HAProxy admin page               |
|   Promtail    | 9080 | Log collecting agent             |


**Admin Node**

There is one and only one admin node in a pigsty deployment, which is specified by [`admin_ip`](PARAM#admin_ip). It is set to the local primary IP during [configure](INSTALL#configure).

The node will have ssh / sudo access to all other nodes, which is critical; ensure it's fully secured.

**INFRA Node**

A pigsty deployment may have one or more infra nodes, usually 2 ~ 3, in a large production environment.

The `infra` group specifies infra nodes in the inventory. And infra nodes will have [INFRA](INFRA) module installed (DNS, Nginx, Prometheus, Grafana, etc...),

The admin node is also the default and first infra node, and infra nodes can be used as 'backup' admin nodes.

**PGSQL Node**

The node with [PGSQL](PGSQL) module installed is called a PGSQL node. The node and pg instance is 1:1 deployed. And node instance can be borrowed from corresponding pg instances with [`node_id_from_pg`](PARAM#node_id_from_pg).

|     Component      | Port | Description                                  |
|:------------------:|:----:|----------------------------------------------|
|      Postgres      | 5432 | Pigsty CMDB                                  |
|     Pgbouncer      | 6432 | Pgbouncer Connection Pooling Service         |
|      Patroni       | 8008 | Patroni HA Component                         |
|  Haproxy Primary   | 5433 | Primary connection pool: Read/Write Service  |
|  Haproxy Replica   | 5434 | Replica connection pool: Read-only Service   |
|  Haproxy Default   | 5436 | Primary Direct Connect Service               |
|  Haproxy Offline   | 5438 | Offline Direct Connect: Offline Read Service |
| Haproxy `service`  | 543x | Customized Services                          |
|   Haproxy Admin    | 9101 | Monitoring metrics and traffic management    |
|    PG Exporter     | 9630 | PG Monitoring Metrics Exporter               |
| PGBouncer Exporter | 9631 | PGBouncer Monitoring Metrics Exporter        |
|   Node Exporter    | 9100 | Node Monitoring Metrics Exporter             |
|      Promtail      | 9080 | Collect Postgres, Pgbouncer, Patroni logs    |
|    vip-manager     |  -   | Bind VIP to the primary                      |



----------------

## Administration

**Add Node**

To add a node into Pigsty, you need to have nopass ssh/sudo access to the node 

```bash
bin/node-add [ip...]      # add node to pigsty:  ./node.yml -l <cls|ip|group>
```

**Remove Node**

To remove a node from Pigsty, you can use the following:

```bash
bin/node-rm [ip...]       # remove node from pigsty: ./node-rm.yml -l <cls|ip|group>
```

**Create Admin**

If the current user does not have nopass ssh/sudo access to the node, you can use another admin user to bootstrap the node:

```bash
node.yml -t node_admin -k -K -e ansible_user=<another admin>   # input ssh/sudo password for another admin 
```




----------------

## Playbooks

* [`node.yml`](https://github.com/vonng/pigsty/blob/master/node.yml) : Init node for pigsty
* [`node-rm.yml`](https://github.com/vonng/pigsty/blob/master/node-rm.yml) : Remove node from pigsty

[![asciicast](https://asciinema.org/a/568807.svg)](https://asciinema.org/a/568807)



----------------

## Dashboards

There are four dashboards for [`NODE`](NODE) module.

- [NODE Overview](http://demo.pigsty.cc/d/node-overview): Overview of all nodes
- [NODE Cluster](http://demo.pigsty.cc/d/node-cluster): Detail information about a node cluster
- [NODE Instance](http://demo.pigsty.cc/d/node-instance): Detail information about a Node instance
- [NODE HAProxy](http://demo.pigsty.cc/d/node-haproxy): Detail information about haproxy service on the node 



----------------

## Parameters

There are 9 sections, 58 parameters about [`NODE`](PARAM#node) module.


- [`NODE_ID`](PARAM#node_id)             : Node identity parameters        
- [`NODE_DNS`](PARAM#node_dns)           : Node Domain Name Resolution     
- [`NODE_PACKAGE`](PARAM#node_package)   : Upstream Repo & Install Packages
- [`NODE_TUNE`](PARAM#node_tune)         : Node Tuning & Features          
- [`NODE_ADMIN`](PARAM#node_admin)       : Admin User & SSH Keys           
- [`NODE_TIME`](PARAM#node_time)         : Timezone, NTP, Crontab          
- [`HAPROXY`](PARAM#haproxy)             : Expose services with HAProxy    
- [`NODE_EXPORTER`](PARAM#node_exporter) : Node monitoring agent           
- [`PROMTAIL`](PARAM#promtail)           : Promtail logging agent          


<details><summary>Parameters</summary>

| Parameter                                                  | Section                                |   Type    | Level | Comment                                                     |
|------------------------------------------------------------|----------------------------------------|:---------:|:-----:|-------------------------------------------------------------|
| [`nodename`](PARAM#nodename)                               | [`NODE_ID`](PARAM#node_id)             |  string   |   I   | node instance identity, use hostname if missing, optional   |
| [`node_cluster`](PARAM#node_cluster)                       | [`NODE_ID`](PARAM#node_id)             |  string   |   C   | node cluster identity, use 'nodes' if missing, optional     |
| [`nodename_overwrite`](PARAM#nodename_overwrite)           | [`NODE_ID`](PARAM#node_id)             |   bool    |   C   | overwrite node's hostname with nodename?                    |
| [`nodename_exchange`](PARAM#nodename_exchange)             | [`NODE_ID`](PARAM#node_id)             |   bool    |   C   | exchange nodename among play hosts?                         |
| [`node_id_from_pg`](PARAM#node_id_from_pg)                 | [`NODE_ID`](PARAM#node_id)             |   bool    |   C   | use postgres identity as node identity if applicable?       |
| [`node_default_etc_hosts`](PARAM#node_default_etc_hosts)   | [`NODE_DNS`](PARAM#node_dns)           | string[]  |   G   | static dns records in `/etc/hosts`                          |
| [`node_etc_hosts`](PARAM#node_etc_hosts)                   | [`NODE_DNS`](PARAM#node_dns)           | string[]  |   C   | extra static dns records in `/etc/hosts`                    |
| [`node_dns_method`](PARAM#node_dns_method)                 | [`NODE_DNS`](PARAM#node_dns)           |   enum    |   C   | how to handle dns servers: add,none,overwrite               |
| [`node_dns_servers`](PARAM#node_dns_servers)               | [`NODE_DNS`](PARAM#node_dns)           | string[]  |   C   | dynamic nameserver in `/etc/resolv.conf`                    |
| [`node_dns_options`](PARAM#node_dns_options)               | [`NODE_DNS`](PARAM#node_dns)           | string[]  |   C   | dns resolv options in `/etc/resolv.conf`                    |
| [`node_repo_method`](PARAM#node_repo_method)               | [`NODE_PACKAGE`](PARAM#node_package)   |   enum    |  C/A  | how to setup node repo: none,local,public,both              |
| [`node_repo_remove`](PARAM#node_repo_remove)               | [`NODE_PACKAGE`](PARAM#node_package)   |   bool    |  C/A  | remove existing repo on node?                               |
| [`node_repo_local_urls`](PARAM#node_repo_local_urls)       | [`NODE_PACKAGE`](PARAM#node_package)   | string[]  |   C   | local repo url, if node_repo_method = local,both            |
| [`node_packages`](PARAM#node_packages)                     | [`NODE_PACKAGE`](PARAM#node_package)   | string[]  |   C   | packages to be installed current nodes                      |
| [`node_default_packages`](PARAM#node_default_packages)     | [`NODE_PACKAGE`](PARAM#node_package)   | string[]  |   G   | default packages to be installed on all nodes               |
| [`node_disable_firewall`](PARAM#node_disable_firewall)     | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | disable node firewall? true by default                      |
| [`node_disable_selinux`](PARAM#node_disable_selinux)       | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | disable node selinux? true by default                       |
| [`node_disable_numa`](PARAM#node_disable_numa)             | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | disable node numa, reboot required                          |
| [`node_disable_swap`](PARAM#node_disable_swap)             | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | disable node swap, use with caution                         |
| [`node_static_network`](PARAM#node_static_network)         | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | preserve dns resolver settings after reboot                 |
| [`node_disk_prefetch`](PARAM#node_disk_prefetch)           | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | setup disk prefetch on HDD to increase performance          |
| [`node_kernel_modules`](PARAM#node_kernel_modules)         | [`NODE_TUNE`](PARAM#node_tune)         | string[]  |   C   | kernel modules to be enabled on this node                   |
| [`node_hugepage_count`](PARAM#node_hugepage_count)         | [`NODE_TUNE`](PARAM#node_tune)         |    int    |   C   | number of 2MB hugepage, take precedence over ratio          |
| [`node_hugepage_ratio`](PARAM#node_hugepage_ratio)         | [`NODE_TUNE`](PARAM#node_tune)         |   float   |   C   | node mem hugepage ratio, 0 disable it by default            |
| [`node_overcommit_ratio`](PARAM#node_overcommit_ratio)     | [`NODE_TUNE`](PARAM#node_tune)         |    int    |   C   | node mem overcommit ratio (50-100), 0 disable it by default |
| [`node_tune`](PARAM#node_tune)                             | [`NODE_TUNE`](PARAM#node_tune)         |   enum    |   C   | node tuned profile: none,oltp,olap,crit,tiny                |
| [`node_sysctl_params`](PARAM#node_sysctl_params)           | [`NODE_TUNE`](PARAM#node_tune)         |   dict    |   C   | sysctl parameters in k:v format in addition to tuned        |
| [`node_data`](PARAM#node_data)                             | [`NODE_ADMIN`](PARAM#node_admin)       |   path    |   C   | node main data directory, `/data` by default                |
| [`node_admin_enabled`](PARAM#node_admin_enabled)           | [`NODE_ADMIN`](PARAM#node_admin)       |   bool    |   C   | create a admin user on target node?                         |
| [`node_admin_uid`](PARAM#node_admin_uid)                   | [`NODE_ADMIN`](PARAM#node_admin)       |    int    |   C   | uid and gid for node admin user                             |
| [`node_admin_username`](PARAM#node_admin_username)         | [`NODE_ADMIN`](PARAM#node_admin)       | username  |   C   | name of node admin user, `dba` by default                   |
| [`node_admin_ssh_exchange`](PARAM#node_admin_ssh_exchange) | [`NODE_ADMIN`](PARAM#node_admin)       |   bool    |   C   | exchange admin ssh key among node cluster                   |
| [`node_admin_pk_current`](PARAM#node_admin_pk_current)     | [`NODE_ADMIN`](PARAM#node_admin)       |   bool    |   C   | add current user's ssh pk to admin authorized_keys          |
| [`node_admin_pk_list`](PARAM#node_admin_pk_list)           | [`NODE_ADMIN`](PARAM#node_admin)       | string[]  |   C   | ssh public keys to be added to admin user                   |
| [`node_timezone`](PARAM#node_timezone)                     | [`NODE_TIME`](PARAM#node_time)         |  string   |   C   | setup node timezone, empty string to skip                   |
| [`node_ntp_enabled`](PARAM#node_ntp_enabled)               | [`NODE_TIME`](PARAM#node_time)         |   bool    |   C   | enable chronyd time sync service?                           |
| [`node_ntp_servers`](PARAM#node_ntp_servers)               | [`NODE_TIME`](PARAM#node_time)         | string[]  |   C   | ntp servers in `/etc/chrony.conf`                           |
| [`node_crontab_overwrite`](PARAM#node_crontab_overwrite)   | [`NODE_TIME`](PARAM#node_time)         |   bool    |   C   | overwrite or append to `/etc/crontab`?                      |
| [`node_crontab`](PARAM#node_crontab)                       | [`NODE_TIME`](PARAM#node_time)         | string[]  |   C   | crontab entries in `/etc/crontab`                           |
| [`haproxy_enabled`](PARAM#haproxy_enabled)                 | [`HAPROXY`](PARAM#haproxy)             |   bool    |   C   | enable haproxy on this node?                                |
| [`haproxy_clean`](PARAM#haproxy_clean)                     | [`HAPROXY`](PARAM#haproxy)             |   bool    | G/C/A | cleanup all existing haproxy config?                        |
| [`haproxy_reload`](PARAM#haproxy_reload)                   | [`HAPROXY`](PARAM#haproxy)             |   bool    |   A   | reload haproxy after config?                                |
| [`haproxy_auth_enabled`](PARAM#haproxy_auth_enabled)       | [`HAPROXY`](PARAM#haproxy)             |   bool    |   G   | enable authentication for haproxy admin page                |
| [`haproxy_admin_username`](PARAM#haproxy_admin_username)   | [`HAPROXY`](PARAM#haproxy)             | username  |   G   | haproxy admin username, `admin` by default                  |
| [`haproxy_admin_password`](PARAM#haproxy_admin_password)   | [`HAPROXY`](PARAM#haproxy)             | password  |   G   | haproxy admin password, `pigsty` by default                 |
| [`haproxy_exporter_port`](PARAM#haproxy_exporter_port)     | [`HAPROXY`](PARAM#haproxy)             |   port    |   C   | haproxy admin/exporter port, 9101 by default                |
| [`haproxy_client_timeout`](PARAM#haproxy_client_timeout)   | [`HAPROXY`](PARAM#haproxy)             | interval  |   C   | client side connection timeout, 24h by default              |
| [`haproxy_server_timeout`](PARAM#haproxy_server_timeout)   | [`HAPROXY`](PARAM#haproxy)             | interval  |   C   | server side connection timeout, 24h by default              |
| [`haproxy_services`](PARAM#haproxy_services)               | [`HAPROXY`](PARAM#haproxy)             | service[] |   C   | list of haproxy service to be exposed on node               |
| [`node_exporter_enabled`](PARAM#node_exporter_enabled)     | [`NODE_EXPORTER`](PARAM#node_exporter) |   bool    |   C   | setup node_exporter on this node?                           |
| [`node_exporter_port`](PARAM#node_exporter_port)           | [`NODE_EXPORTER`](PARAM#node_exporter) |   port    |   C   | node exporter listen port, 9100 by default                  |
| [`node_exporter_options`](PARAM#node_exporter_options)     | [`NODE_EXPORTER`](PARAM#node_exporter) |    arg    |   C   | extra server options for node_exporter                      |
| [`promtail_enabled`](PARAM#promtail_enabled)               | [`PROMTAIL`](PARAM#promtail)           |   bool    |   C   | enable promtail logging collector?                          |
| [`promtail_clean`](PARAM#promtail_clean)                   | [`PROMTAIL`](PARAM#promtail)           |   bool    |  G/A  | purge existing promtail status file during init?            |
| [`promtail_port`](PARAM#promtail_port)                     | [`PROMTAIL`](PARAM#promtail)           |   port    |   C   | promtail listen port, 9080 by default                       |
| [`promtail_positions`](PARAM#promtail_positions)           | [`PROMTAIL`](PARAM#promtail)           |   path    |   C   | promtail position status file path                          |

</details>