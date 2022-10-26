# Playbook

> Pigsty consists of several [modules](#Module) that can be combined according to different scenarios.


Pigsty implements core control functions at the bottom through the [Ansible Playbook](#ansible-quick-start), and Pigsty provides pre-built playbooks in four main categories:

* [`infra`](/en/docs/infra/playbook): Use the `infra` series of playbooks to install Pigsty singleton on the meta node with optional features.
* [`nodes`](/en/docs/nodes/playbook): Use the `nodes` series of playbooks to include more nodes in Pigsty monitoring and management and for subsequent use.
* [`pgsql`](/en/docs/pgsql/playbook): Use the `pgsql` series of playbooks to deploy and manage PostgreSQL database clusters on existing nodes.
* [`redis`](/en/docs/redis/playbook): Use the `redis` series of playbooks to deploy and manage various modes of Redis clusters on existing nodes.

## Overview

| Playbook                                                       | Function                                                                             | Link                                                                      |
|----------------------------------------------------------------|--------------------------------------------------------------------------------------|---------------------------------------------------------------------------|
| [**infra**](/en/docs/infra/playbook#infra)                     | **Full installation of Pigsty on the meta node**                                     | [`src`](https://github.com/vonng/pigsty/blob/master/infra.yml)            |
| [`infra-demo`](/en/docs/infra/playbook#infra-demo)             | Special playbook for complete initialization of a four-node demo sandbox in one go   | [`src`](https://github.com/vonng/pigsty/blob/master/infra-demo.yml)       |
| [`infra-jupyter`](/en/docs/infra/playbook#infra-jupyter)       | Adding the **optional** data analysis service component Jupyter Lab to the meta node | [`src`](https://github.com/vonng/pigsty/blob/master/infra-jupyter.yml)    |
| [**nodes**](/en/docs/nodes/playbook#nodes)                     | **Node provisioning to include nodes in Pigsty for subsequent database deployment**  | [`src`](https://github.com/vonng/pigsty/blob/master/nodes.yml)            |
| [`nodes-remove`](/en/docs/nodes/playbook#nodes-remove)         | Node remove, unloading node DCS and monitoring, no longer included in Pigsty         | [`src`](https://github.com/vonng/pigsty/blob/master/nodes-remove.yml)     |
| [**pgsql**](/en/docs/pgsql/playbook#pgsql)                     | **PostgreSQL cluster deploy, or expand**                                             | [`src`](https://github.com/vonng/pigsty/blob/master/pgsql.yml)            |
| [`pgsql-remove`](/en/docs/pgsql/playbook#pgsql-remove)         | PostgreSQL cluster destruction, or downsize                                          | [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-remove.yml)     |
| [`pgsql-createuser`](/en/docs/pgsql/playbook#pgsql-createuser) | Creating PostgreSQL business users                                                   | [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-createuser.yml) |
| [`pgsql-createdb`](/en/docs/pgsql/playbook#pgsql-createdb)     | Creating a PostgreSQL Business Database                                              | [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-createdb.yml)   |
| [`pgsql-monly`](/en/docs/pgsql/playbook#pgsql-monly)           | Monly mode, with access to existing PostgreSQL instances or RDS                      | [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-monly.yml)      |
| [`pgsql-migration`](/en/docs/pgsql/playbook#pgsql-migration)   | Generate PostgreSQL semi-automatic database migration solution (Beta)                | [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-migration.yml)  |
| [`pgsql-matrix`](/en/docs/pgsql/playbook#pgsql-matrix)         | Reuse the PG role to deploy a MatrixDB data warehouse clusters (Beta)                | [`src`](https://github.com/vonng/pigsty/blob/master/pigsty-matrixdb.yml)  |
| [**redis**](/en/docs/redis/playbook#redis)                     | **Deploy a Redis database in cluster/standalone/Sentinel mode**                      | [`src`](https://github.com/vonng/pigsty/blob/master/redis.yml)            |
| [`redis-remove`](/en/docs/redis/playbook#redis-remove)         | Redis cluster/node destruction                                                       | [`src`](https://github.com/vonng/pigsty/blob/master/redis-remove.yml)     |

The typical use process is as follows：

1. Use the `infra` series of playbooks to install Pigsty on the meta node/local machine and deploy the infra.

   All playbooks initiate execution on the meta node, and the `infra` series of playbooks only works on the meta node.

2. Use the [`nodes`](/en/docs/nodes/playbook) series of playbooks to include or remove other nodes from Pigsty.

   After a node is managed, node monitoring and logging can be accessed from the meta node Grafana, and the node joins the Consul cluster.

3. Use the [`pgsql`](/en/docs/pgsql/playbook) series of playbooks to deploy a PostgreSQL cluster on managed nodes.

   After deployment on the managed node, you can access PostgreSQL monitoring and logs from the meta node.

4. Use the [`redis`](/en/docs/redis/playbook) series of playbooks to deploy a Redis cluster on managed nodes.

   After deployment on the managed node, Redis monitoring and logs can be accessed from the meta node.

```
                                           meta     node
[infra.yml]  ./infra.yml [-l meta]        +pigsty 
[nodes.yml]  ./nodes.yml -l pg-test                 +consul +monitor
[pgsql.yml]  ./pgsql.yml -l pg-test                 +pgsql
[redis.yml]  ./redis.yml -l pg-test                 +redis
```



Most playbooks are idempotent, meaning that some deployment playbooks may erase existing databases and create new ones without the protection option turned on.

Please read the documentation carefully, proofread the commands several times, and operate with caution. The author is not responsible for any loss of databases due to misuse.

------------------



## Ansible Quick Start

The Pigsty playbooks are written in Ansible.

* [Ansible Installation](#Installation): How to install Ansible? (Pigsty users usually don't have to worry about）
* [Limit Host](#limit-host): How to execute a playbook for a limit host?
* [Task Subset](#task-subset): How to perform certain specific tasks in the playbook？
* [Extra Params](#extra-params): How to pass in extra command-line params to control playbook behavior？

### Installation

The Ansible playbook requires the `ansible-playbook` executable command, and Ansible can be installed on EL7-compatible systems with the following command.

```bash
yum install ansible
```

Pigsty will attempt to install ansible from the offline package when using offline packages during the Configure phase.

There are three core params to focus on when executing the playbook：`-l|-t|-e`, which are used to restrict the host for execution, with the task to be performed and to pass in extra params, respectively.

### Limit Host

The target of execution can be selected with the `-l|-limit <selector>` param. When this param is not specified, most playbooks default to all hosts defined in the configuration file as the target of execution.
It is highly recommended to specify the execution object when executing the playbook.

There are two types of objects commonly used, clusters and hosts.

```bash
./pgsql.yml                 # Execute the pgsql playbook on all inventory hosts(this is dangerous!)
./pgsql.yml -l pg-test      # Execute the pgsql playbook against the hosts in the pg-test cluster
./pgsql.yml -l 10.10.10.10  # Execute the pgsql playbook against the host at 10.10.10.10
./pgsql.yml -l pg-*         # Execute the playbook against a cluster that matches the pg-* pattern (glob)
```


### Task Subset

You can select the task subset to be executed with `-t|--tags <tags>`. When this param is not specified, the full playbook will be executed, and the selected task subset will be executed when set.

```bash
./pgsql.yml -t pg_hba                            # Regenerate and apply cluster HBA rules
```

Users can separate each task by `,` and perform multiple tasks at once. For example, you can adjust the cluster LB configuration using the following command when the cluster role members change.

```bash
./pgsql.yml -t haproxy_config,haproxy_reload     # Regenerate the cluster LB configuration and apply
```

### Extra Params

Extra command-line params can be passed in via `-e|-extra-vars KEY=VALUE` to override existing params or control some special behavior.

For example, some of the behavior of the following playbooks can be controlled via command-line params.

```bash
./nodes.yml -e ansible_user=admin -k -K      # When configuring the node, use another admin user, and enter ssh with the sudo password
./pgsql.yml -e pg_clean=clean        # Force erase existing running database instances when installing PG (dangerous)
./infra-remove.yml -e rm_metadata=true       # Remove data when uninstalling Pigsty
./infra-remove.yml -e rm_metadpkgs=true      # Uninstall the software when uninstalling Pigsty
./nodes-remove.yml -e rm_dcs_server=true     # When removing a node, force removal even if there is a DCS server on it
./pgsql-remove.yml -e rm_pgdata=true         # When removing PG, remove data together
./pgsql-remove.yml -e rm_pgpkgs=true         # When removing the PG, uninstall the software as well
```

