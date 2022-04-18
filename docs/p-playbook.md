# Playbooks

> Learn about the pre-set playbooks provided by Pigsty，the features, how to use them and the considerations.

Pigsty implements core control functions at the bottom through the [Ansible Playbook](#Ansible-quick-start) , and Pigsty provides pre-set playbooks in four main categories:

* [`infra`](p-infra.md) : Use the `infra` series of playbooks to install Pigsty standalone on the meta node with optional features.
* [`nodes`](p-nodes.md) : Use the `nodes` series of playbooks to include more nodes in Pigsty monitoring and management and for subsequent use.
* [`pgsql`](p-pgsql.md) : Use the `pgsql` series of playbooks to deploy and manage PostgreSQL database clusters on existing nodes.
* [`redis`](p-redis.md) : Use the `redis` series of playbooks to deploy and manage various modes of Redis clusters on existing nodes.



## Overview

| Playbook | Function                                                   | Link                                                     |
|--------|----------------------------------------------------------------| ------------------------------------------------------------ |
|  [**infra**](p-infra.md#infra)                        | **Full installation of Pigsty on the meta node** |        [`src`](https://github.com/vonng/pigsty/blob/master/infra.yml)            |
|  [`infra-demo`](p-infra.md#infra-demo)              | Special script for complete initialization of a four-node demo sandbox environment in one go |        [`src`](https://github.com/vonng/pigsty/blob/master/infra-demo.yml)       |
|  [`infra-jupyter`](p-infra.md#infra-jupyter)        | Adding the **Optional** data analysis service component Jupyter Lab to the meta node |        [`src`](https://github.com/vonng/pigsty/blob/master/infra-jupyter.yml)    |
|  [`infra-pgweb`](p-infra.md#infra-pgweb)            | Add the **optional** web client tool PGWeb to the meta node |        [`src`](https://github.com/vonng/pigsty/blob/master/infra-pgweb.yml)      |
|  [**nodes**](p-nodes.md#nodes)                        | **Node provisioning to include nodes in Pigsty for subsequent database deployment** |        [`src`](https://github.com/vonng/pigsty/blob/master/nodes.yml)            |
|  [`nodes-remove`](p-nodes.md#nodes-remove)          | Node removal, offloading node DCS and monitoring, no longer included in Pigsty |        [`src`](https://github.com/vonng/pigsty/blob/master/nodes-remove.yml)     |
|  [**pgsql**](p-pgsql.md#pgsql)                        | **Deploy a PostgreSQL cluster, or cluster expansion** |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql.yml)            |
|  [`pgsql-remove`](p-pgsql.md#pgsql-remove)          | Offline PostgreSQL cluster, or cluster shrinkage |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-remove.yml)     |
|  [`pgsql-createuser`](p-pgsql.md#pgsql-createuser)  |      Creating PostgreSQL business users |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-createuser.yml) |
|  [`pgsql-createdb`](p-pgsql.md#pgsql-createdb)      | Creating a PostgreSQL Business Database |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-createdb.yml)   |
|  [`pgsql-monly`](p-pgsql.md#pgsql-monly)            | Monitor-only mode, with access to existing PostgreSQL instances or RDS |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-monly.yml)      |
|  [`pgsql-migration`](p-pgsql.md#pgsql-migration)    | Generate PostgreSQL semi-automatic database migration solution (Beta) |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-migration.yml)  |
|  [`pgsql-audit`](p-pgsql.md#pgsql-audit)            | Generate PostgreSQL Audit Compliance Report (Beta) |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-audit.yml)      |
|  [`pgsql-matrix`](p-pgsql.md#pgsql-matrix)          | Reuse the PG role to deploy a MatrixDB data warehouse clusters (Beta) |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-matrix.yml)     |
|  [**redis**](p-redis.md#redis)                        | **Deploy a Redis database in cluster/master-slave/Sentinel mode** |        [`src`](https://github.com/vonng/pigsty/blob/master/redis.yml)            |
|  [`redis-remove`](p-redis.md#redis-remove)          |        Redis cluster/node offline           |        [`src`](https://github.com/vonng/pigsty/blob/master/redis-remove.yml)     |

The typical use process is as follows：

1. Use the `infra` series of playbooks to install Pigsty on the meta node/local machine and deploy the infrastructure.
   
   All playbooks initiate execution on the meta node, and the `infra` series of playbooks only works on the meta node itself.

2. Use the  [`nodes`](p-nodes.md) series of playbooks to include or remove other nodes from Pigsty.

   After a node is hosted, node monitoring and logging can be accessed from the meta node Grafana and the node joins the Consul cluster.

3. Use the [`pgsql`](p-pgsql.md) series of playbooks to deploy a PostgreSQL cluster on managed nodes.

   After deployment on the managed node, you can access PostgreSQL monitoring and logs from the meta node.

4. Use the [`redis`](p-redis.md) series of playbooks to deploy a Redis cluster on managed nodes.

   After deployment on the managed node, Redis monitoring and logs can be accessed from the meta node.

```
                                           meta     node
[infra.yml]  ./infra.yml [-l meta]        +pigsty 
[nodes.yml]  ./nodes.yml -l pg-test                 +consul +monitor
[pgsql.yml]  ./pgsql.yml -l pg-test                 +pgsql
[redis.yml]  ./redis.yml -l pg-test                 +redis
```



Most playbooks are idempotent, which means that some deployment playbooks may erase existing databases and create new ones without the protection option turned on.
When you are dealing with an existing database cluster or operating in a production environment, please fully read and understand the documents, proofread the commands again and again. The author is not responsible for the loss of the database caused by misuse.

------------------



## Ansible Quick Start

Pigsty playbooks are written in Ansible and you don't need to fully understand Ansible's principles, only a little knowledge is enough to take full advantage of Ansible playbooks.

* [Ansible Installation](#Instalation)：How to install Ansible?（Pigsty users usually don't have to worry about）
* [Host Subset](#limit-host)：How to execute a playbook for a specific host?
* [Task Subset](#task-subset)：How to perform certain specific tasks in the playbook？
* [Additional parameters](#extra-params)：How to pass in additional command line arguments to control playbook behavior？

### Installation

The Ansible playbook requires the `ansible-playbook` executable command, and Ansible can be installed on EL7-compatible systems with the following command.

```bash
yum install ansible
```

When using offline packages, Pigsty will attempt to install ansible from the offline package during the Configure phase.

When executing Ansible playbooks, just execute the playbook directly as an executable.There are three core parameters to focus on when executing the playbook：`-l|-t|-e`，are used to restrict the host for execution, with the task to be performed, and to pass in additional parameters, respectively.

### Limit Host

The target of execution can be selected with the `-l|-limit <selector>` parameter. When this parameter is not specified, most playbooks default to all hosts defined in the configuration file as the target of execution, which is very dangerous.
It is strongly recommended to specify the object of execution when executing the playbook.

There are two types of objects commonly used, clusters and hosts, e.g.

```bash
./pgsql.yml                 # Execute the pgsql playbook on all hosts of the configuration list (this is dangerous!)
./pgsql.yml -l pg-test      # Execute the pgsql playbook against the hosts in the pg-test cluster
./pgsql.yml -l 10.10.10.10  # Execute the pgsql playbook against the host at 10.10.10.10
./pgsql.yml -l pg-*         # Execute the playbook against a cluster that matches the pg-* pattern (glob)
```


### Task Subset

You can select the subset of tasks to be executed with `-t|--tags <tags>`. When this parameter is not specified, the full playbook will be executed, and when specified, the selected subset of tasks will be executed.

```bash
./pgsql.yml -t pg_hba                            # Regenerate and apply cluster HBA rules
```

Users can separate each task by `,` and perform multiple tasks at once, for example, when the cluster role members change, you can adjust the cluster load balancing configuration using the following command.

```bash
./pgsql.yml -t haproxy_config,haproxy_reload     # Regenerate the cluster load balancer configuration and apply
```

### Extra Params

Additional command line arguments can be passed in via `-e|-extra-vars KEY=VALUE` to override existing arguments or to control some special behavior.

For example, some of the behavior of the following playbooks can be controlled via command line arguments.

```bash
./nodes.yml -e ansible_user=admin -k -K      # When configuring the node, use another admin user, admin, and enter ssh with the sudo password
./pgsql.yml -e pg_exists_action=clean        # Force wipe existing running database instances when installing PG (dangerous)
./infra-remove.yml -e rm_metadata=true       # Remove data when uninstalling Pigsty
./infra-remove.yml -e rm_metadpkgs=true      # Uninstall the software when uninstalling Pigsty
./nodes-remove.yml -e rm_dcs_server=true     # When removing a node, force removal even if there is a DCS server on it
./pgsql-remove.yml -e rm_pgdata=true         # When removing PG, remove data together
./pgsql-remove.yml -e rm_pgpkgs=true         # When removing the PG, uninstall the software as well
```

