# NODE

> Tune nodes into the desired state and monitor it.

[Configuration](#configuration) | [Administration](#administration) | [Playbook](#playbook) | [Dashboard](#dashboard) | [Parameter](#parameter)


----------------

## Concept

Node is an abstraction of hardware resources, which can be bare metal, virtual machines, or even k8s pods.

There are different types of nodes in Pigsty:

* [Common nodes](#common-node), nodes that managed by Pigsty
* [Admin node](#admin-node), the node where pigsty is installed and issue admin commands
* [Infra node](#infra-node), the node where the [`INFRA`](INFRA) module is installed

The admin node is usually overlapped with the infra node, if there's more than one infra node,
the first one is often used as the default admin node, and the rest of the infra nodes can be used as backup admin nodes.


### Common Node

You can manage nodes with Pigsty, and install modules on them. The `node.yml` playbook will adjust the node to desired state.

Some services will be added to all nodes by default:

|      Component      | Port | Description                      | Status     |
|:-------------------:|:----:|----------------------------------|------------|
|    Node Exporter    | 9100 | Node Monitoring Metrics Exporter | Enabled    |
|    HAProxy Admin    | 9101 | HAProxy admin page               | Enabled    |
|      Promtail       | 9080 | Log collecting agent             | Enabled    |
|    Docker Daemon    | 9323 | Enable Container Service         | *Disabled* |
|     Keepalived      |  -   | Manage Node Cluster L2 VIP       | *Disabled* |
| Keepalived Exporter | 9650 | Monitoring Keepalived Status     | *Disabled* |

Docker & Keepalived are optional components, enabled when required. 


### ADMIN Node

There is one and only one admin node in a pigsty deployment, which is specified by [`admin_ip`](PARAM#admin_ip). It is set to the local primary IP during [configure](INSTALL#configure).

The node will have ssh / sudo access to all other nodes, which is critical; ensure it's fully secured.

### INFRA Node

A pigsty deployment may have one or more infra nodes, usually 2 ~ 3, in a large production environment.

The `infra` group specifies infra nodes in the inventory. And infra nodes will have [INFRA](INFRA) module installed (DNS, Nginx, Prometheus, Grafana, etc...),

The admin node is also the default and first infra node, and infra nodes can be used as 'backup' admin nodes.

### **PGSQL Node**

The node with [PGSQL](PGSQL) module installed is called a PGSQL node. The node and pg instance is 1:1 deployed. And node instance can be borrowed from corresponding pg instances with [`node_id_from_pg`](PARAM#node_id_from_pg).

|      Component      | Port | Description                                      |   Status    |
|:-------------------:|:----:|--------------------------------------------------|-------------|
|      Postgres       | 5432 | Pigsty CMDB                                      | Enabled     |
|      Pgbouncer      | 6432 | Pgbouncer Connection Pooling Service             | Enabled     |
|       Patroni       | 8008 | Patroni HA Component                             | Enabled     |
|   Haproxy Primary   | 5433 | Primary connection pool: Read/Write Service      | Enabled     |
|   Haproxy Replica   | 5434 | Replica connection pool: Read-only Service       | Enabled     |
|   Haproxy Default   | 5436 | Primary Direct Connect Service                   | Enabled     |
|   Haproxy Offline   | 5438 | Offline Direct Connect: Offline Read Service     | Enabled     |
|  Haproxy `service`  | 543x | Customized PostgreSQL Services                   | On Demand   |
|    Haproxy Admin    | 9101 | Monitoring metrics and traffic management        | Enabled     |
|     PG Exporter     | 9630 | PG Monitoring Metrics Exporter                   | Enabled     |
| PGBouncer Exporter  | 9631 | PGBouncer Monitoring Metrics Exporter            | Enabled     |
|    Node Exporter    | 9100 | Node Monitoring Metrics Exporter                 | Enabled     |
|      Promtail       | 9080 | Collect Postgres, Pgbouncer, Patroni logs        | Enabled     |
|    Docker Daemon    | 9323 | Docker Container Service    (disable by default) | Disabled    |
|     vip-manager     |  -   | Bind VIP to the primary                          | Disabled    |
|     keepalived      |  -   | Node Cluster L2 VIP manager (disable by default) | Disabled    |
| Keepalived Exporter | 9650 | Keepalived Metrics Exporter (disable by default) | Disabled    |




----------------

## Configuration

Each node has **identity parameters** that are configured through the parameters in `<cluster>.hosts` and `<cluster>.vars`.

Pigsty uses **IP** as a unique identifier for **database nodes**. **This IP must be the IP that the database instance listens to and serves externally**, But it would be inappropriate to use a public IP address!

**This is very important**. The IP is the `inventory_hostname` of the host in the inventory, which is reflected as the `key` in the `<cluster>.hosts` object.

You can use `ansible_*` parameters to overwrite `ssh` behavior, e.g. connect via domain name / alias, but the primary IPv4 is still the core identity of the node.

[`nodename`](param#nodename) and [`node_cluster`](param#node_cluster) are not **mandatory**; [`nodename`](param#nodename) will use the node's current hostname by default, while [`node_cluster`](param#node_cluster) will use the fixed default value: `nodes`.

If [`node_id_from_pg`](param#node_id_from_pg) is enabled, the node will borrow [`PGSQL`](PGSQL) [identity](param#pg_id) and use it as Node's identity, i.e. [`node_cluster`](param#node_cluster) is set to [`pg_cluster`](param#pg_cluster) if applicable, and [`nodename`](param#nodename) is set to `${pg_cluster}-${pg_seq}`. If [`nodename_overwrite`](param#nodename_overwrite) is enabled, node's hostname will be overwritten by [`nodename`](param#nodename)

Pigsty labels a node with identity parameters in the monitoring system. Which maps `nodename` to `ins`, and `node_cluster` into `cls`.


|              Name                    |   Type   | Level | Necessity    | Comment               |
|:------------------------------------:|:--------:|:-----:|--------------|-----------------------|
|      `inventory_hostname`            |   `ip`   | **-** | **Required** | **Node IP**           |
|     [`nodename`](param#nodename)     | `string` | **I** | Optional     | **Node Name**         |
| [`node_cluster`](param#node_cluster) | `string` | **C** | Optional     | **Node cluster name** |

The following cluster config declares a three-node node cluster:

```yaml
node-test:
  hosts:
    10.10.10.11: { nodename: node-test-1 }
    10.10.10.12: { nodename: node-test-2 }
    10.10.10.13: { nodename: node-test-3 }
  vars:
    node_cluster: node-test
```

Default values:

```yaml
#nodename:           # [INSTANCE] # node instance identity, use hostname if missing, optional
node_cluster: nodes   # [CLUSTER] # node cluster identity, use 'nodes' if missing, optional
nodename_overwrite: true          # overwrite node's hostname with nodename?
nodename_exchange: false          # exchange nodename among play hosts?
node_id_from_pg: true             # use postgres identity as node identity if applicable?
```


----------------

## Administration

Here are some common administration tasks for [`NODE`](NODE) module.

- [Add Node](#add-node)
- [Remove Node](#remove-node)
- [Create Admin](#create-admin)
- [Bind VIP](#bind-vip)
- [Other Tasks](#other-tasks)
- [FAQ：NODE](FAQ#node)


----------------

### Add Node

To add a node into Pigsty, you need to have nopass ssh/sudo access to the node 

```bash
# ./node.yml -l <cls|ip|group>        # the underlying playbook
# bin/node-add <selector|ip...>       # add cluster/node to pigsty
bin/node-add node-test                # init node cluster 'node-test'
bin/node-add 10.10.10.10              # init node '10.10.10.10'
```

----------------

### Remove Node

To remove a node from Pigsty, you can use the following:

```bash
# ./node-rm.yml -l <cls|ip|group>    # the underlying playbook
# bin/node-rm <selector|ip...>       # remove node from pigsty:
bin/node-rm node-test                # remove node cluster 'node-test'
bin/node-rm 10.10.10.10              # remove node '10.10.10.10'
```

----------------

### Create Admin

If the current user does not have nopass ssh/sudo access to the node, you can use another admin user to bootstrap the node:

```bash
node.yml -t node_admin -k -K -e ansible_user=<another admin>   # input ssh/sudo password for another admin 
```

----------------

### Bind VIP

You can bind an optional L2 VIP on a node cluster with [`vip_enabled`](PARAM#vip_enabled). 

```bash
proxy:
  hosts:
    10.10.10.29: { nodename: proxy-1 } 
    10.10.10.30: { nodename: proxy-2 } # , vip_role: master }
  vars:
    node_cluster: proxy
    vip_enabled: true
    vip_vrid: 128
    vip_address: 10.10.10.99
    vip_interface: eth1
```

```bash
./node.yml -l proxy -t node_vip     # enable for the first time
./node.yml -l proxy -t vip_refresh  # refresh vip config (e.g. designated master) 
```

----------------

### Other Tasks

```bash
# Play
./node.yml -t node                            # init node itself (haproxy monitor not included）
./node.yml -t haproxy                         # setup haproxy on node to expose services
./node.yml -t monitor                         # setup node_exporter & promtail for metrics & logs
./node.yml -t node_vip                        # enable keepalived for node cluster L2 VIP
./node.yml -t vip_config,vip_reload           # refresh L2 VIP configuration
./node.yml -t haproxy_config,haproxy_reload   # refresh haproxy services definition on node cluster
./node.yml -t register_prometheus             # register node to Prometheus
./node.yml -t register_nginx                  # register haproxy admin page url to Nginx on infra nodes

# Task
./node.yml -t node-id        # generate node identity
./node.yml -t node_name      # setup hostname
./node.yml -t node_hosts     # setup /etc/hosts records
./node.yml -t node_resolv    # setup dns resolver
./node.yml -t node_firewall  # setup firewall & selinux
./node.yml -t node_ca        # add & trust ca certificate
./node.yml -t node_repo      # add upstream repo
./node.yml -t node_pkg       # install yum packages
./node.yml -t node_feature   # setup numa, grub, static network
./node.yml -t node_kernel    # enable kernel modules
./node.yml -t node_tune      # setup tuned profile
./node.yml -t node_sysctl    # setup additional sysctl parameters
./node.yml -t node_profile   # write /etc/profile.d/node.sh
./node.yml -t node_ulimit    # setup resource limits
./node.yml -t node_data      # setup main data dir
./node.yml -t node_admin     # setup admin user and ssh key
./node.yml -t node_timezone  # setup timezone
./node.yml -t node_ntp       # setup ntp server/clients
./node.yml -t node_crontab   # add/overwrite crontab tasks
./node.yml -t node_vip       # setup optional l2 vrrp vip for node cluster
```




----------------

## Playbook

There are two node playbooks [node.yml](#nodeyml) and [node-rm.yml](#node-rmyml)

### `node.yml`

The playbook [`node.yml`](https://github.com/vonng/pigsty/blob/master/node.yml) will init node for pigsty

Subtasks of this playbook:

```bash
# node-id       : generate node identity
# node_name     : setup hostname
# node_hosts    : setup /etc/hosts records
# node_resolv   : setup dns resolver
# node_firewall : setup firewall & selinux
# node_ca       : add & trust ca certificate
# node_repo     : add upstream repo
# node_pkg      : install yum packages
# node_feature  : setup numa, grub, static network
# node_kernel   : enable kernel modules
# node_tune     : setup tuned profile
# node_sysctl   : setup additional sysctl parameters
# node_profile  : write /etc/profile.d/node.sh
# node_ulimit   : setup resource limits
# node_data     : setup main data dir
# node_admin    : setup admin user and ssh key
# node_timezone : setup timezone
# node_ntp      : setup ntp server/clients
# node_crontab  : add/overwrite crontab tasks
# node_vip      : setup optional l2 vrrp vip for node cluster
#   - vip_install
#   - vip_config
#   - vip_launch
#   - vip_reload
# haproxy       : setup haproxy on node to expose services
#   - haproxy_install
#   - haproxy_config
#   - haproxy_launch
#   - haproxy_reload
# monitor       : setup node_exporter & promtail for metrics & logs
#   - haproxy_register
#   - vip_dns
#   - node_exporter
#     - node_exporter_config
#     - node_exporter_launch
#   - vip_exporter
#     - vip_exporter_config
#     - vip_exporter_launch
#   - node_register
#   - promtail
#     - promtail_clean
#     - promtail_config
#     - promtail_install
#     - promtail_launch
```

[![asciicast](https://asciinema.org/a/568807.svg)](https://asciinema.org/a/568807)


### `node-rm.yml`

The playbook [`node-rm.yml`](https://github.com/vonng/pigsty/blob/master/node-rm.yml) will remove node from pigsty.playbook

Subtasks of this playbook:

```bash
# register       : remove register from prometheus & nginx
#   - prometheus : remove registered prometheus monitor target
#   - nginx      : remove nginx proxy record for haproxy admin
# vip            : remove node keepalived if enabled
# haproxy        : remove haproxy load balancer
# node_exporter  : remove monitoring exporter
# vip_exporter   : remove keepalived_exporter if enabled
# promtail       : remove loki log agent
# profile        : remove /etc/profile.d/node.sh
```



----------------

## Dashboard

There are 6 dashboards for [`NODE`](NODE) module.


[NODE Overview](https://demo.pigsty.cc/d/node-overview): Overview of all nodes

<details><summary>Node Overview Dashboard</summary>

[![node-overview.jpg](https://repo.pigsty.cc/img/node-overview.jpg)](https://demo.pigsty.cc/d/node-overview)

</details>



[NODE Cluster](https://demo.pigsty.cc/d/node-cluster): Detail information about one dedicate node cluster

<details><summary>Node Cluster Dashboard</summary>

[![node-cluster.jpg](https://repo.pigsty.cc/img/node-cluster.jpg)](https://demo.pigsty.cc/d/node-cluster)

</details>



[Node Instance](https://demo.pigsty.cc/d/node-instance) : Detail information about one single node instance

<details><summary>Node Instance Dashboard</summary>

[![node-instance.jpg](https://repo.pigsty.cc/img/node-instance.jpg)](https://demo.pigsty.cc/node-instance)

</details>



[NODE Alert](https://demo.pigsty.cc/d/node-alert): Overview of key metrics of all node clusters/instances

<details><summary>Node Alert Dashboard</summary>

[![node-alert.jpg](https://repo.pigsty.cc/img/node-alert.jpg)](https://demo.pigsty.cc/d/node-alert)

</details>



[NODE VIP](https://demo.pigsty.cc/d/node-vip): Detail information about a L2 VIP on a node cluster

<details><summary>Node VIP Dashboard</summary>

[![node-vip.jpg](https://repo.pigsty.cc/img/node-vip.jpg)](https://demo.pigsty.cc/d/node-vip)

</details>



[Node Haproxy](https://demo.pigsty.cc/d/node-haproxy) : Detail information about haproxy on node instance

<details><summary>Node Haproxy Dashboard</summary>

[![node-haproxy.jpg](https://repo.pigsty.cc/img/node-haproxy.jpg)](https://demo.pigsty.cc/d/node-haproxy)

</details>



----------------

## Parameter

There are 11 sections, 66 parameters about [`NODE`](PARAM#node) module.

- [`NODE_ID`](PARAM#node_id)             : Node identity parameters
- [`NODE_DNS`](PARAM#node_dns)           : Node Domain Name Resolution
- [`NODE_PACKAGE`](PARAM#node_package)   : Upstream Repo & Install Packages
- [`NODE_TUNE`](PARAM#node_tune)         : Node Tuning & Features
- [`NODE_ADMIN`](PARAM#node_admin)       : Admin User & SSH Keys
- [`NODE_TIME`](PARAM#node_time)         : Timezone, NTP, Crontab
- [`NODE_VIP`](PARAM#node_vip)           : Optional L2 VIP among cluster
- [`HAPROXY`](PARAM#haproxy)             : Expose services with HAProxy
- [`NODE_EXPORTER`](PARAM#node_exporter) : Node monitoring agent
- [`PROMTAIL`](PARAM#promtail)           : Promtail logging agent
- [`DOCKER`](PARAM#docker)               : Docker Container Service (optional)


<details><summary>Parameters</summary>

| Parameter                                                  | Section                                |   Type    | Level | Comment                                                         |
|------------------------------------------------------------|----------------------------------------|:---------:|:-----:|-----------------------------------------------------------------|
| [`nodename`](PARAM#nodename)                               | [`NODE_ID`](PARAM#node_id)             |  string   |   I   | node instance identity, use hostname if missing, optional       |
| [`node_cluster`](PARAM#node_cluster)                       | [`NODE_ID`](PARAM#node_id)             |  string   |   C   | node cluster identity, use 'nodes' if missing, optional         |
| [`nodename_overwrite`](PARAM#nodename_overwrite)           | [`NODE_ID`](PARAM#node_id)             |   bool    |   C   | overwrite node's hostname with nodename?                        |
| [`nodename_exchange`](PARAM#nodename_exchange)             | [`NODE_ID`](PARAM#node_id)             |   bool    |   C   | exchange nodename among play hosts?                             |
| [`node_id_from_pg`](PARAM#node_id_from_pg)                 | [`NODE_ID`](PARAM#node_id)             |   bool    |   C   | use postgres identity as node identity if applicable?           |
| [`node_default_etc_hosts`](PARAM#node_default_etc_hosts)   | [`NODE_DNS`](PARAM#node_dns)           | string[]  |   G   | static dns records in `/etc/hosts`                              |
| [`node_etc_hosts`](PARAM#node_etc_hosts)                   | [`NODE_DNS`](PARAM#node_dns)           | string[]  |   C   | extra static dns records in `/etc/hosts`                        |
| [`node_dns_method`](PARAM#node_dns_method)                 | [`NODE_DNS`](PARAM#node_dns)           |   enum    |   C   | how to handle dns servers: add,none,overwrite                   |
| [`node_dns_servers`](PARAM#node_dns_servers)               | [`NODE_DNS`](PARAM#node_dns)           | string[]  |   C   | dynamic nameserver in `/etc/resolv.conf`                        |
| [`node_dns_options`](PARAM#node_dns_options)               | [`NODE_DNS`](PARAM#node_dns)           | string[]  |   C   | dns resolv options in `/etc/resolv.conf`                        |
| [`node_repo_method`](PARAM#node_repo_method)               | [`NODE_PACKAGE`](PARAM#node_package)   |   enum    |  C/A  | how to setup node repo: none,local,public,both                  |
| [`node_repo_remove`](PARAM#node_repo_remove)               | [`NODE_PACKAGE`](PARAM#node_package)   |   bool    |  C/A  | remove existing repo on node?                                   |
| [`node_repo_local_urls`](PARAM#node_repo_local_urls)       | [`NODE_PACKAGE`](PARAM#node_package)   | string[]  |   C   | local repo url, if node_repo_method = local,both                |
| [`node_packages`](PARAM#node_packages)                     | [`NODE_PACKAGE`](PARAM#node_package)   | string[]  |   C   | packages to be installed current nodes                          |
| [`node_default_packages`](PARAM#node_default_packages)     | [`NODE_PACKAGE`](PARAM#node_package)   | string[]  |   G   | default packages to be installed on all nodes                   |
| [`node_disable_firewall`](PARAM#node_disable_firewall)     | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | disable node firewall? true by default                          |
| [`node_disable_selinux`](PARAM#node_disable_selinux)       | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | disable node selinux? true by default                           |
| [`node_disable_numa`](PARAM#node_disable_numa)             | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | disable node numa, reboot required                              |
| [`node_disable_swap`](PARAM#node_disable_swap)             | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | disable node swap, use with caution                             |
| [`node_static_network`](PARAM#node_static_network)         | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | preserve dns resolver settings after reboot                     |
| [`node_disk_prefetch`](PARAM#node_disk_prefetch)           | [`NODE_TUNE`](PARAM#node_tune)         |   bool    |   C   | setup disk prefetch on HDD to increase performance              |
| [`node_kernel_modules`](PARAM#node_kernel_modules)         | [`NODE_TUNE`](PARAM#node_tune)         | string[]  |   C   | kernel modules to be enabled on this node                       |
| [`node_hugepage_count`](PARAM#node_hugepage_count)         | [`NODE_TUNE`](PARAM#node_tune)         |    int    |   C   | number of 2MB hugepage, take precedence over ratio              |
| [`node_hugepage_ratio`](PARAM#node_hugepage_ratio)         | [`NODE_TUNE`](PARAM#node_tune)         |   float   |   C   | node mem hugepage ratio, 0 disable it by default                |
| [`node_overcommit_ratio`](PARAM#node_overcommit_ratio)     | [`NODE_TUNE`](PARAM#node_tune)         |    int    |   C   | node mem overcommit ratio (50-100), 0 disable it by default     |
| [`node_tune`](PARAM#node_tune)                             | [`NODE_TUNE`](PARAM#node_tune)         |   enum    |   C   | node tuned profile: none,oltp,olap,crit,tiny                    |
| [`node_sysctl_params`](PARAM#node_sysctl_params)           | [`NODE_TUNE`](PARAM#node_tune)         |   dict    |   C   | sysctl parameters in k:v format in addition to tuned            |
| [`node_data`](PARAM#node_data)                             | [`NODE_ADMIN`](PARAM#node_admin)       |   path    |   C   | node main data directory, `/data` by default                    |
| [`node_admin_enabled`](PARAM#node_admin_enabled)           | [`NODE_ADMIN`](PARAM#node_admin)       |   bool    |   C   | create a admin user on target node?                             |
| [`node_admin_uid`](PARAM#node_admin_uid)                   | [`NODE_ADMIN`](PARAM#node_admin)       |    int    |   C   | uid and gid for node admin user                                 |
| [`node_admin_username`](PARAM#node_admin_username)         | [`NODE_ADMIN`](PARAM#node_admin)       | username  |   C   | name of node admin user, `dba` by default                       |
| [`node_admin_ssh_exchange`](PARAM#node_admin_ssh_exchange) | [`NODE_ADMIN`](PARAM#node_admin)       |   bool    |   C   | exchange admin ssh key among node cluster                       |
| [`node_admin_pk_current`](PARAM#node_admin_pk_current)     | [`NODE_ADMIN`](PARAM#node_admin)       |   bool    |   C   | add current user's ssh pk to admin authorized_keys              |
| [`node_admin_pk_list`](PARAM#node_admin_pk_list)           | [`NODE_ADMIN`](PARAM#node_admin)       | string[]  |   C   | ssh public keys to be added to admin user                       |
| [`node_timezone`](PARAM#node_timezone)                     | [`NODE_TIME`](PARAM#node_time)         |  string   |   C   | setup node timezone, empty string to skip                       |
| [`node_ntp_enabled`](PARAM#node_ntp_enabled)               | [`NODE_TIME`](PARAM#node_time)         |   bool    |   C   | enable chronyd time sync service?                               |
| [`node_ntp_servers`](PARAM#node_ntp_servers)               | [`NODE_TIME`](PARAM#node_time)         | string[]  |   C   | ntp servers in `/etc/chrony.conf`                               |
| [`node_crontab_overwrite`](PARAM#node_crontab_overwrite)   | [`NODE_TIME`](PARAM#node_time)         |   bool    |   C   | overwrite or append to `/etc/crontab`?                          |
| [`node_crontab`](PARAM#node_crontab)                       | [`NODE_TIME`](PARAM#node_time)         | string[]  |   C   | crontab entries in `/etc/crontab`                               |
| [`vip_enabled`](PARAM#vip_enabled)                         | [`NODE_VIP`](PARAM#node_vip)           |   bool    |   C   | enable vip on this node cluster?                                |
| [`vip_address`](PARAM#vip_address)                         | [`NODE_VIP`](PARAM#node_vip)           |    ip     |   C   | node vip address in ipv4 format, required if vip is enabled     |
| [`vip_vrid`](PARAM#vip_vrid)                               | [`NODE_VIP`](PARAM#node_vip)           |    int    |   C   | required, integer, 1-254, should be unique among same VLAN      |
| [`vip_role`](PARAM#vip_role)                               | [`NODE_VIP`](PARAM#node_vip)           |   enum    |   I   | optional, `master/backup`, backup by default, use as init role  |
| [`vip_preempt`](PARAM#vip_preempt)                         | [`NODE_VIP`](PARAM#node_vip)           |   bool    |  C/I  | optional, `true/false`, false by default, enable vip preemption |
| [`vip_interface`](PARAM#vip_interface)                     | [`NODE_VIP`](PARAM#node_vip)           |  string   |  C/I  | node vip network interface to listen, `eth0` by default         |
| [`vip_dns_suffix`](PARAM#vip_dns_suffix)                   | [`NODE_VIP`](PARAM#node_vip)           |  string   |   C   | node vip dns name suffix, empty string by default               |
| [`vip_exporter_port`](PARAM#vip_exporter_port)             | [`NODE_VIP`](PARAM#node_vip)           |   port    |   C   | keepalived exporter listen port, 9650 by default                |
| [`haproxy_enabled`](PARAM#haproxy_enabled)                 | [`HAPROXY`](PARAM#haproxy)             |   bool    |   C   | enable haproxy on this node?                                    |
| [`haproxy_clean`](PARAM#haproxy_clean)                     | [`HAPROXY`](PARAM#haproxy)             |   bool    | G/C/A | cleanup all existing haproxy config?                            |
| [`haproxy_reload`](PARAM#haproxy_reload)                   | [`HAPROXY`](PARAM#haproxy)             |   bool    |   A   | reload haproxy after config?                                    |
| [`haproxy_auth_enabled`](PARAM#haproxy_auth_enabled)       | [`HAPROXY`](PARAM#haproxy)             |   bool    |   G   | enable authentication for haproxy admin page                    |
| [`haproxy_admin_username`](PARAM#haproxy_admin_username)   | [`HAPROXY`](PARAM#haproxy)             | username  |   G   | haproxy admin username, `admin` by default                      |
| [`haproxy_admin_password`](PARAM#haproxy_admin_password)   | [`HAPROXY`](PARAM#haproxy)             | password  |   G   | haproxy admin password, `pigsty` by default                     |
| [`haproxy_exporter_port`](PARAM#haproxy_exporter_port)     | [`HAPROXY`](PARAM#haproxy)             |   port    |   C   | haproxy admin/exporter port, 9101 by default                    |
| [`haproxy_client_timeout`](PARAM#haproxy_client_timeout)   | [`HAPROXY`](PARAM#haproxy)             | interval  |   C   | client side connection timeout, 24h by default                  |
| [`haproxy_server_timeout`](PARAM#haproxy_server_timeout)   | [`HAPROXY`](PARAM#haproxy)             | interval  |   C   | server side connection timeout, 24h by default                  |
| [`haproxy_services`](PARAM#haproxy_services)               | [`HAPROXY`](PARAM#haproxy)             | service[] |   C   | list of haproxy service to be exposed on node                   |
| [`node_exporter_enabled`](PARAM#node_exporter_enabled)     | [`NODE_EXPORTER`](PARAM#node_exporter) |   bool    |   C   | setup node_exporter on this node?                               |
| [`node_exporter_port`](PARAM#node_exporter_port)           | [`NODE_EXPORTER`](PARAM#node_exporter) |   port    |   C   | node exporter listen port, 9100 by default                      |
| [`node_exporter_options`](PARAM#node_exporter_options)     | [`NODE_EXPORTER`](PARAM#node_exporter) |    arg    |   C   | extra server options for node_exporter                          |
| [`promtail_enabled`](PARAM#promtail_enabled)               | [`PROMTAIL`](PARAM#promtail)           |   bool    |   C   | enable promtail logging collector?                              |
| [`promtail_clean`](PARAM#promtail_clean)                   | [`PROMTAIL`](PARAM#promtail)           |   bool    |  G/A  | purge existing promtail status file during init?                |
| [`promtail_port`](PARAM#promtail_port)                     | [`PROMTAIL`](PARAM#promtail)           |   port    |   C   | promtail listen port, 9080 by default                           |
| [`promtail_positions`](PARAM#promtail_positions)           | [`PROMTAIL`](PARAM#promtail)           |   path    |   C   | promtail position status file path                              |

</details>