# Playbook：NODES

> Use the `nodes` series [playbook](p-playbook.md)  to bring more nodes into Pigsty, adjusting the nodes to the state described in [configuration](v-nodes.md).

Once you have completed a complete installation of Pigsty on the meta node using [`infra.yml`](p-infra.md) ,you can add more nodes to Pigsty using [`nodes.yml`](#nodes)  or remove them from the environment using [`nodes-remove.yml`](nodes-remove) .

| Playbook                                  | Function                                                     | Link                                                         |
| ----------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| [`nodes`](p-nodes.md#nodes)               | **Node provisioning to include nodes in Pigsty for subsequent database deployment** | [`src`](https://github.com/vonng/pigsty/blob/master/nodes.yml) |
| [`nodes-remove`](p-nodes.md#nodes-remove) | Node removal, offloading node DCS and monitoring, no longer included in Pigsty | [`src`](https://github.com/vonng/pigsty/blob/master/nodes-remove.yml) |


---------------

## `nodes`

The [`nodes.yml`](p-nodes.md) playbook to add more nodes to Pigsty. This playbook needs to be initiated on the **meta node** and executed against the target node.

This playbook adjusts the target machine nodes to the state described in the configuration list, installs the Consul service and incorporates it into the Pigsty monitoring system, and allows you to further deploy different types of database clusters.

The behavior of the `nodes.yml` playbook is determined by the [node configuration](v-nodes.md). The full execution of this playbook may take 1 to 3 minutes when using local sources, depending on the machine configuration.

```bash
./nodes.yml                      # Initialize all nodes in the list (danger!)
./nodes.yml -l pg-test           # Initialize the machines under the pg-test group (recommended!)
./nodes.yml -l pg-meta,pg-test   # Initialize the nodes in both pg-meta and pg-test clusters at the same time
./nodes.yml -l 10.10.10.11       # Initialize the machine node 10.10.10.11
```

![](_media/playbook/nodes.svg)


This playbook contains the following functions and tasks:

* Generate node identity parameters
* Initialize Node
  * Configure the node name
  * Configure node static DNS resolution
  * Configure the node's dynamic DNS resolution server
  * Configure the node's Yum source
  * Install the specified RPM packages
  * Configure features such as numa/swap/firewall
  * Configure node tuned tuning templates
  * Configure shortcut commands and environment variables for the node
  * Create node administrator and configure SSH
  * Configure node time zone
  * Configure the node NTP service
* Initialize the DCS service on the node: Consul
  * Erase existing Consul
  * Initialize the Consul Agent or Server service for the current node
* Initialize the node monitoring component and incorporate Pigsty
  * Install Node Exporter on the node
  * Register the Node Exporter to Prometheus on the management node.

**It is necessary to be careful to execute this playbook on the node where the existing database is running. Improper use may lead to temporary unavailability of the database, because initializing the node will erase the DCS agent .**

Node provisioning configures the node's DCS service (Consul Agent), so be careful when running this playbook on a node running a PostgreSQL database!
The [dcs_exists_action](v-nodes.md#dcs_exists_action) parameter provides the option to avoid accidental deletion. During initialization, when an existing DCS in operation is detected, it is allowed to automatically stop or skip high-risk operations to avoid the worst case.
Nevertheless，when **using the full `nodes.yml` playbook or the section on `dcs|consul` therein, please check several times that the `-tags|-t` and `-limit|-l` parameters are correct. Make sure you are performing the right task on the right target. **


### Protection mechanism

The `nodes.yml` provides **protection mechanism** determined by configuration parameter [`dcs_exists_action`](v-nodes.md#dcs_exists_action). When there is a running PostgreSQL instance on the target machine before the playbook is executed, pigsty will take action according to the configuration `abort|clean|skip` of  [`dcs_exists_action`](v-nodes.md#dcs_exists_action).

* `abort`：Set the default configuration. In case of an existing DCS instance, stop the script execution to avoid deleting the library by mistake.
* `clean`：Use it in the local sandbox environment. In case of existing instances, clear the existing DCS instances.
* `skip`：Skip this host and perform subsequent logic on other hosts.
* Use `./nodes.yml -e pg_exists_action=clean` to overwrite the configuration file option and force the existing instance to be erased.

The [`dcs_disable_purge`](v-nodes.md#dcs_disable_purge) option provides dual protection, If this option is enabled, the [`dcs_exists_action`](v-nodes.md#dcs_exists_action) will be forcibly set to `abort`, and no running database instances will be wiped out under any circumstances.



### Selective execution

Users can **selectively execute** a subset of this playbook through Ansible's tagging mechanism. For example, if you only want to perform the task of node monitoring deployment, you can pass the following command:

```bash
./nodes.yml --tags=node-monitor
```

For specific labels, please refer to [**task details**](#任务详情)

Some common task subsets include:

```bash
# play
./nodes.yml --tags=node-id         # Print node identity parameters: name and cluster
./nodes.yml --tags=node-init       # Initialize the node and complete the configuration
./nodes.yml --tags=dcs-init        # Initialize the DCS service on the node: Consul
./nodes.yml --tags=node-monitor    # Initialize the node monitoring component and incorporate Pigsty

# tasks
./nodes.yml --tags=node_name       # Configure node name
./nodes.yml --tags=node_dns        # Configure node static DNS resolution
./nodes.yml --tags=node_resolv     # Configuring a Node Dynamic DNS Resolution Server
./nodes.yml --tags=node_repo       # Configure the node's Yum source
./nodes.yml --tags=node_pkgs       # Install the specified RPM package
./nodes.yml --tags=node_feature    # Configure numa/swap/firewall
./nodes.yml --tags=node_tuned      # Configure node tuned tuning templates
./nodes.yml --tags=node_profile    # Configure the node's  shortcut commands and environment variables
./nodes.yml --tags=node_admin      # Create node administrator and configure SSH
./nodes.yml --tags=node_timezone   # Configure node time zone
./nodes.yml --tags=node_ntp        # Configure the node NTP service
./nodes.yml --tags=consul          # Configure the consul agent/server on the node
./nodes.yml --tags=consul -e dcs_exists_action=clean   # Force wipe reconfigure consul on node

./nodes.yml --tags=node_exporter   # Configure node_exporter on the node and register it
./nodes.yml --tags=node_deregister # Deregister node monitoring from meta node
./nodes.yml --tags=node_register   # Registering node monitoring to a meta node

```


### Create admin user

Creating admin user is a chicken-and-egg problem.In order to execute Ansible playbooks, you need to have an admin user. In order to create a dedicated admin user, you need to execute this Ansible playbook.

Pigsty recommends that the creation, permission configuration and key distribution of admin users be completed in the provisioning phase of virtual machines as part of the delivery of machine resources. For production environments, the machine should be delivered with such a user already configured with a password-free remote SSH login and performing password-free sudo. Usually most cloud platforms and ops systems can do this.

If you can only use SSH and sudo password, you must add additional parameters `--ask-pass|-k` and `--ask-become-pass|-K`, when all playbooks are executed, and enter SSH and sudo password when prompted. You can create a dedicated admin user using the current user using the function to create an admin user in `nodes.yml`. The following parameters are used to create the default admin user:

* [`node_admin_setup`](v-nodes.md#node_admin_setup)
* [`node_admin_uid`](v-nodes.md#node_admin_uid)
* [`node_admin_username`](v-nodes.md#node_admin_username)
* [`node_admin_pks`](v-nodes.md#node_admin_pks)

```bash
./nodes.yml -t node_admin -l <Target machine> --ask-pass --ask-become-pass
```

The default admin user is dba (uid=88), please **do not** use postgres or dbsu as the admin user, please try to avoid using root as the admin user directly.

The default user vagrant in the sandbox environment has been configured with password free login and password free sudo. You can use vagrant to log in to all database nodes from the host or sandbox meta node.

For example：

```bash
./nodes.yml --limit <target_hosts>  --tags node_admin  -e ansible_user=<another_admin> --ask-pass --ask-become-pass 
```

For details, please refer to: [Preparation：Admin user provisioning](d-prepare.md#管理用户置备)







---------------

## `nodes-remove`

The [`nodes-remove.yml`](#nodes-remove) playbook is the reverse of the [`nodes`](#nodes) playbook, used to remove nodes from Pigsty.

The playbook needs to be initiated on the **meta node** and executed against the target node.

```bash
./nodes.yml                      # Remove all nodes (dangerous!)
./nodes.yml -l nodes-test        # Remove machines from the nodes-test group
./nodes.yml -l 10.10.10.11       # Remove the machine node 10.10.10.11
./nodes.yml -l 10.10.10.10 -e rm_dcs_servers=true # If the node is a DCS Server, additional parameters need to be removed.
```

![](_media/playbook/nodes-remove.svg)

### Task subset

```bash
# play
./nodes-remove.yml --tags=register      # Remove node registration information
./nodes-remove.yml --tags=node-exporter # Remove node indicator collector
./nodes-remove.yml --tags=promtail      # Remove the Protail log collection component
./nodes-remove.yml --tags=consul        # Remove Consul Agent service
./nodes-remove.yml --tags=consul -e rm_dcs_servers=true # Remove Consul services (including Server!)
```