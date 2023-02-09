# NODE

> Tune node into desired state and monitor it.


## Concept

Node is an abstraction of hardware resource, which can be bare metal, virtual machine, or even k8s pods.

There are different types of node in pigsty:

* common node, nodes that managed by pigsty
* admin node, the node where pigsty is installed on and issue admin commands
* infra node, the node where INFRA module installed, admin node is usually the first one of all infra nodes.
* pgsql node, nodes that have [PGSQL](PGSQL) module installed

**Common Node**



**Admin Node**

There is one and only one admin node in a pigsty deployment, which is specified by [`admin_ip`](PARAM#admin_ip), it is set to local primary IP during [configure](INSTALL#configure).

The node will have ssh / sudo access to all other nodes, which is critical, make sure it's fully secured.

**INFRA Node**

A pigsty deployment may have one or more infra nodes, usually 2 ~ 3 in large production environment.

Infra nodes are specified by the `infra` group in the inventory. and infra nodes will have [INFRA](INFRA) module installed (dns,nginx,prometheus,grafana,etc...),

The admin node is also used as the only one infra node by default, and infra nodes can be used as 'backup' admin nodes.


**PGSQL Node**


## Admin

To add a node into pigsty, you need to have nopass ssh/sudo access to the node 

```bash

```


## Identity




## Playbooks

* [`node.yml`](https://github.com/vonng/pigsty/blob/master/node.yml) : Init node for pigsty
* [`node-rm.yml`](https://github.com/vonng/pigsty/blob/master/node-rm.yml) : Remove node from pigsty

## Parameters

There are 10 sections, 58 parameters about [`NODE`](PARAM#node) module.


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