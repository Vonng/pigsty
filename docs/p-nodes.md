# Playbook: NODES

> Use the `NODES` [playbook](p-playbook.md) to bring more nodes to Pigsty, adjusting nodes to the state described in the [config](v-nodes.md).

Once pigsty is installed on the meta node with [`infra.yml`](p-infra.md), You can add more nodes to Pigsty with [`nodes.yml`](#nodes) or remove them from Pigsty with [`nodes-remove.yml`](#nodes-remove).

| Playbook                                  | Function                                                     | Link                                                         |
| ----------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| [`nodes`](p-nodes.md#nodes)               | Node Provisioning. Register node into Pigsty and prepare for database deployment | [`src`](https://github.com/vonng/pigsty/blob/master/nodes.yml) |
| [`nodes-remove`](p-nodes.md#nodes-remove) | Node Removal, uninstall DCS & Monitoring & Logging, de-register from Pigsty | [`src`](https://github.com/vonng/pigsty/blob/master/nodes-remove.yml) |





---------------

## `nodes`

The [`nodes.yml`](https://github.com/vonng/pigsty/blob/master/nodes.yml) playbook will register nodes to Pigsty.

This playbook adjusts the target nodes to the state described in the [inventory](v-nodes.md), installs the Consul service, and incorporates it into the Pigsty monitoring system. Nodes can be used for database deployment once provisioning is complete.

The behavior of this playbook is determined by the [Config: NODES](v-nodes.md). The complete execution of this playbook may take 1 to 3 minutes when using the local yum repo, depending on the machine spec.

```bash
./nodes.yml             # init all nodes in inventory    (danger!)
./nodes.yml -l pg-test  # init nodes under group pg-test (recommended!)
./nodes.yml -l pg-meta,pg-test   # init nodes in both clusters: pg-meta and pg-test
./nodes.yml -l 10.10.10.11       # init node with ip address 10.10.10.11
```

![](_media/playbook/nodes.svg)


This playbook will run the following tasks:

* Generate node [identity parameters](v-nodes.md#NODE_IDENTITY) 
* Provisioning Node
  * Configure the node's hostname
  * Configure static DNS records
  * Configure dynamic DNS resolver
  * Configure yum repo
  * Install specified RPM packages
  * Configure features such as NUMA/SWAP/firewall
  * Configure node tuned tuning templates
  * Configure shortcuts and environment variables for the node
  * Create node admin user and configure its SSH access
  * Configure timezone
  * Configure NTP service
* Initialize the DCS service on the node: Consul
  * Erase existing Consul if it exists (with protection disabled)
  * Initialize the Consul Agent or Server service for the current node
* Initialize the node monitoring component and incorporate Pigsty
  * Install Node Exporter
  * Register Node Exporter to Prometheus on meta nodes.



!> **Be careful when running this playbook on provisioned nodes. It may lead to the database being temporarily unavailable because of the removal of the consul service.** 

The [`consul_clean`](v-nodes.md#consul_clean) provides a [SafeGuard](#SafeGuard) to avoid accidental purge. When existing Consul Instance is detected during playbook execution. It will take action about it.

!> When using the complete `nodes.yml` playbook or just the section on `dcs|consul`, please double-check that the `-tags|-t` and `-limit|-l` is correct. Make sure you are running the right tasks on the correct targets. 



### SafeGuard

Pigsty provides a SafeGuard to avoid purging running consul instances with fat fingers. There are two parameters.

* [`consul_safeguard`](v-nodes.md#consul_safeguard): Disabled by default, if enabled, running consul will not be purged by any circumstance.
* [`consul_clean`](v-nodes.md#consul_clean): disabled by default, [`nodes.yml`](#nodes) will purge running consul during node init.

When running consul exists, [`nodes.yml`](#nodes) will act as:

| `consul_safeguard` / `pg_clean` | `consul_clean=true` | `consul_clean=false` |
| :-----------------------------: | :-----------------: | :------------------: |
|     `consul_safeguard=true`     |        ABORT        |        ABORT         |
|    `consul_safeguard=false`     |      **PURGE**      |        ABORT         |

When running consul exists,  [`nodes-remove.yml`](#nodes-remove) will act as:

| `consul_safeguard` / `pg_clean` | `consul_clean=true` | `consul_clean=false` |
| :-----------------------------: | :-----------------: | :------------------: |
|     `consul_safeguard=true`     |        ABORT        |        ABORT         |
|    `consul_safeguard=false`     |      **PURGE**      |      **PURGE**       |







### Selective Execution

You can **selectively** execute a subset of this playbook through **tags**.

For example, if you want to re-deploy node monitor components only:

```bash
./nodes.yml --tags=node-monitor
```

Common tasks are listed below:

```bash
# play
./nodes.yml --tags=node-id         # generate & print node identity params
./nodes.yml --tags=node-init       # provisoning the node
./nodes.yml --tags=dcs-init        # init dcs on node
./nodes.yml --tags=node-monitor    # init monitor (metrics & logs) on node

# tasks
./nodes.yml --tags=node_name       # Configure node‘s hostname
./nodes.yml --tags=node_dns        # Configure node's static DNS records
./nodes.yml --tags=node_resolv     # Configuring Dynamic DNS Resolver
./nodes.yml --tags=node_repo       # Configure yum repo
./nodes.yml --tags=node_pkgs       # Install specified RPM package
./nodes.yml --tags=node_feature    # Configure NUMA/SWAP/FIREWALL...
./nodes.yml --tags=node_tuned      # Configure tuned tuning templates
./nodes.yml --tags=node_profile    # Configure shortcuts & env variables
./nodes.yml --tags=node_admin      # Create node admin user and configure SSH access
./nodes.yml --tags=node_timezone   # Configure node time zone
./nodes.yml --tags=node_ntp        # Configure NTP service
./nodes.yml --tags=docker          # Configure dockerd daemon
./nodes.yml --tags=consul          # Configure consul agent/server
./nodes.yml --tags=consul -e consul_clean=clean   # Force consul reinit

./nodes.yml --tags=node_exporter   # Configure node_exporter on the node and register it
./nodes.yml --tags=node_register   # Registering node monitoring to a meta node
./nodes.yml --tags=node_deregister # Deregister node monitoring from meta node
```





### Admin User Provision

Admin user provisioning is a chicken-and-egg problem. To execute playbooks, you need to have an admin user. To create a dedicated admin user, you need to run this playbook.

Pigsty recommends leaving admin user provisioning to your vendor. It's common to deliver the node with an admin user with ssh & sudo access.

It may require a password to execute ssh & sudo. You can pass them via extra params  `--ask-pass|-k` and `--ask-become-pass|-K`,  entering SSH and sudo password when prompted. You can create a dedicated admin user (with no pass sudo & ssh) with another admin user (with password sudo & ssh).

The following parameters are used to describe the dedicated admin user.

* [`node_admin_enabled`](v-nodes.md#node_admin_enabled)
* [`node_admin_uid`](v-nodes.md#node_admin_uid)
* [`node_admin_username`](v-nodes.md#node_admin_username)
* [`node_admin_pk_list`](v-nodes.md#node_admin_pk_list)

```bash
./nodes.yml -t node_admin -l <target_hosts> --ask-pass --ask-become-pass
```

The default admin user is dba (uid=88). Please **do not** use `postgres` or `{{ dbsu }}` as the admin user. Please try to avoid using root as the admin user directly.

The default user `vagrant` in the local [sandbox](d-sandbox.md) has been provisioned with nopass ssh & sudo. You can use `vagrant` to ssh to all other nodes from the sandbox meta node.

```bash
./nodes.yml --limit <target_hosts>  --tags node_admin  \
            -e ansible_user=<another_admin> --ask-pass --ask-become-pass 
```

Refer to: [Prepare: Admin User](d-prepare.md#Admin-Provisioning) for more details.





---------------

## `nodes-remove`

The [`nodes-remove.yml`](https://github.com/vonng/pigsty/blob/master/nodes-remove.yml) playbook is used to remove nodes from Pigsty.

The playbook needs to be executed on **meta nodes**, and targeting nodes need to be removed.

```bash
./nodes.yml                      # Remove all nodes (dangerous!)
./nodes.yml -l nodes-test        # Remove nodes under group nodes-test 
./nodes.yml -l 10.10.10.11       # Remove node 10.10.10.11
./nodes.yml -l 10.10.10.10 -e rm_dcs_servers=true # Remove even If there's a DCS Server
```

![](_media/playbook/nodes-remove.svg)



### Task Subsets

```bash
# play
./nodes-remove.yml --tags=register      # Remove node registration
./nodes-remove.yml --tags=node-exporter # Remove node metrics collector
./nodes-remove.yml --tags=promtail      # Remove Promtail log agent
./nodes-remove.yml --tags=consul        # Remove Consul Agent service
./nodes-remove.yml --tags=docker        # Remove Docker service
./nodes-remove.yml --tags=consul -e rm_dcs_servers=true # Remove Consul (Including Server!)
```

