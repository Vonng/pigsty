# Playbook：INFRA

> Use the `infra` series [playbook ](p-playbook.md)to install Pigsty on the current management node and add optional features.

| Playbook                                | Function                           | Link                                                                 |
|---------------------------------------------|--------------------------------------|------------------------------------------------------------------------|
| [`infra`](p-infra.md#infra)                 | Complete installation of Pigsty on the management node | [`src`](https://github.com/vonng/pigsty/blob/master/infra.yml)         |
| [`infra-demo`](p-infra.md#infra-demo)       | Special script for complete initialization of a four-node demo sandbox environment in one go | [`src`](https://github.com/vonng/pigsty/blob/master/infra-demo.yml)    |
| [`infra-remove`](p-infra.md#infra-remove)   | Uninstall Pigsty on the management node | [`src`](https://github.com/vonng/pigsty/blob/master/infra-remove.yml)  |
| [`infra-jupyter`](p-infra.md#infra-jupyter) | Adding the **Optional** data analysis service component Jupyter Lab to the management node | [`src`](https://github.com/vonng/pigsty/blob/master/infra-jupyter.yml) |
| [`infra-pgweb`](p-infra.md#infra-pgweb)     | Add the **optional** web client tool PGWeb to the management node | [`src`](https://github.com/vonng/pigsty/blob/master/infra-pgweb.yml)   |








---------------

## `infra`

The [`infra.yml`](https://github.com/Vonng/pigsty/blob/master/infra.yml) playbook will complete the installation and deployment of **Pigsty** on the **management node** (default is the current node).

When you use Pigsty as an out-of-the-box database, just execute `infra.yml` directly on this node to complete the installation.

![](_media/playbook/infra.svg)

### What

Executing this playbook will accomplish the following tasks:

* Configure the directory and environment variables of the management node
* Download and create a local yum repository to speed up the subsequent installation. (If using offline packages, skip the download phase)
* Incorporate the current management node into Pigsty management as a [common node](p-nodes.md).
* Deploy **infrastructure** components, including Prometheus, Grafana, Loki, Alertmanager, Consul Server, etc.
* Deploy a common [PostgreSQL](p-pgsql.md) single instance cluster on the current node to incorporate monitoring.

### Where

This playbook is executed by default for **managed nodes**.

* Pigsty will use **the node currently executing this playbook** as Pigsty's management node by default.
* Pigsty will mark the current node as the management node by default during Configure and replace the placeholder IP address `10.10.10.10` in the configuration template with **Current node primary IP address**.
* **Management node** can initiate management, in addition to deploying infrastructure. It is otherwise indistinguishable from a regular managed node with a PG deployed.
* Pigsty uses a management node by default to deploy DCS Server for database high availability, but you can absolutely opt for an external DCS cluster.
* Using multiple management nodes is possible, refer to the [DCS3](https://github.com/Vonng/pigsty/blob/master/files/conf/pigsty-dcs3.yml#L33) configuration template: deploying a 3-node DCS Server, allowing one of them to go down.

### How

Some notes on executing this playbook:

* This playbook is an idempotent playbook, repeated execution will erase Consul Server and CMDB on the management node (with protection option turned off)
* When using the offline package, the full execution of this playbook takes about 5-8 minutes, depending on the machine configuration.
* When downloading the software directly from the original upstream of the Internet without using the offline package, it may take 10-20 minutes, depending on your network conditions.
* This playbook incorporates the management node as a normal node and deploys the PG database, overwriting everything in [`nodes.yml`](p-nodes.md) and [`pgsql.yml`](p-pgsql.md), so if `infra.yml` can be successfully executed on the management node, it must be successfully completed on the normal node in the same state If `infra.yml` can be successfully executed on the management node, then it must be successfully deployed on the normal node in the same state.
* The default [`pg-meta`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml#L43) on the management node will be used as the Pigsty meta-database to host advanced features.


### Tasks

The playbook
```bash
./infra.yml --tags=environ                       # Reconfigure the environment on the management node
./infra.yml --tags=repo -e repo_rebuild=true     # Forced re-creation of local sources
./infra.yml --tags=repo_upstream                 # Join upstream YumRepo
./infra.yml --tags=prometheus                    # Recreate Prometheus
./infra.yml --tags=nginx_config,nginx_restart    # Regenerate the Nginx configuration file and restart
……
```



In the [configuration manifest](v-config.md), nodes belonging to the `meta` grouping will be set with the [`meta_node`](v-meta#meta_node) tag to be used as a management node for Pigsty.








---------------

## `infra-demo`

The [`infra-demo.yml`](https://github.com/Vonng/pigsty/blob/master/infra-demo.yml) is a special playbook for the demo environment, which can be used to initialize a 4-node sandbox environment at once by interweaving the management node with the normal node initialization.
In a four-node sandbox, this playbook can be equated to the following command:

```bash
./infra.yml              # Install Pigsty on the management node
./infra-pgweb.yml        # Adding PgWeb to the management node
./infra-jupyter.yml      # Adding Jupyter to the management node
./nodes.yml -l pg-test   # Include the three nodes belonging to pg-test in the management
./pgsql.yml -l pg-test   # Deploy a database cluster on three nodes of pg-test
```

In addition, when you try to deploy multiple management nodes, you can also use this playbook to pull up all management nodes and the DCS and database clusters on them at once if you choose to deploy DCS Server on all management nodes by default.

Note that in case of improper configuration, this playbook has the miraculous effect of wiping out the entire environment at once, and can be removed in production environments to avoid the risk of "Fat Finger".

![](_media/playbook/infra-demo.svg)







---------------

## `infra-remove`

The [`infra-remove.yml`](https://github.com/Vonng/pigsty/blob/master/infra-remove.yml) playbook is a reverse operation of the [infra](#infra) playbook.

This action uninstalls Pigsty from the management node, and the playbook uninstalls the following components in turn.

![](_media/playbook/infra-remove.svg)

- grafana-server
- prometheus
- alertmanager
- node_exporter
- consul
- jupyter
- pgweb
- loki
- promtail




---------------

## `infra-jupyter`

The [`infra-jupyter.yml`](https://github.com/Vonng/pigsty/blob/master/infra-jupyter.yml) playbook is used to add the Jupyter Lab service to the management node.

Jupyter Lab is a very useful Python data analysis environment, but comes with a WebShell, which is risky. So by default, JupyterLab will be enabled in the demo environment, standalone configuration template, and it will not be enabled in the production environment deployment template by default.J

Please refer to the instructions in: [Configuration:Jupyter](v-infra.md#JUPYTER) to adjust the configuration list, and then just execute this playbook.

```bash
./infra-jupyter.yml
```


 If you have Jupyter enabled in your production environment, be sure to change the Jupyter password.



---------------

## `infra-pgweb`

PGWeb is a browser-based PostgreSQL client tool that can be used for scenarios such as small batch personal data queries. It is currently an optional Beta feature and is only enabled in the Demo by default.

The [`infra-pgweb.yml`](https://github.com/Vonng/pigsty/blob/master/infra-pgweb.yml) playbook  is used to install the PGWeb service on the management node.

Please refer to the instructions in: [Configuration:PGWEB](v-infra.md#PGWEB) to adjust the configuration list, and then just execute this playbook.

```bash
./infra-pgweb.yml
```











