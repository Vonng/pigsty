# Pigsty Quick Start

> It takes 3 steps to install Pigsty: [Prepare](d-prepare.md), [Configure](v-config.md#configure), [Execute Playbook](p-playbook.md)


----------------

![](_media/HOW_EN.svg)

There are two typical modes: [Singleton](#单机安装) & [Cluster Management](#集群管理)

* **Singleton**: Install Pigsty on a single node and use it as a battery-included Postgres database (development testing)
* **Cluster Manage**:  Deploy, monitor, and manage other nodes with many different kinds of databases on top of a single installation (O&M management)

---------------------

## Singleton installation 

When Pigsty is installed on one node, Pigsty deploys a complete **infrastructure runtime** with a single node PostgreSQL **database cluster** on that node. For individual users, simple scenarios, and small and micro businesses, you can use this database right out of the box.

Prepare a **new installation** machine (Linux x86_64 CentOS 7.8.2003), configure [admin user](d-prepare.md#admin user placement) ssh local sudo access, then [download Pigsty](d-prepare.md#software download).

```bash
bash -c "$(curl -fsSL http://download.pigsty.cc/get)" 	# Download the latest pigsty source code
cd ~/pigsty; . /configure 								# Generate configuration based on current environment
. /infra.yml 											# Complete the installation on the current node
```

>  If you have an available Macbook/PC/laptop or cloud vendor account, you can use [sandbox deployment](d-sandbox.md) to automatically create a virtual machine locally or in the cloud.

After execution, you have completed the installation of Pigsty on the **current node** with a complete infrastructure and an out-of-the-box PostgreSQL database instance. 5432 of the current node provides database [services](c-service.md# services) externally, and port 80 provides all WebUI-type services externally.

Port 80 is the access endpoint for all Web GUI services. Although it is possible to bypass Nginx and access services directly using the port, such as Grafana on port 3000, it is highly recommended that you access each Web subservice using a domain name by [configuring static DNS](d-sandbox.md#DNS configuration) on the local machine.

> Visit http://g.pigsty or `http://<primary_ip>:3000` to view the Pigsty monitoring system home page (username: admin, password: pigsty)

![](./_media/ARCH.svg)


----------------

## Cluster Mange

Pigsty can also be used as a cluster/database manager for large-scale production environments. You can initiate control from a single machine installation of Pigsty on a node that will act as the [meta node](c-arch.md#management node) of the cluster, or **meta-node/Meta**, to include more [machine nodes](p-nodes.md) in the management and monitoring of Pigsty.
More importantly, Pigsty can also deploy and manage various database clusters and applications on these nodes: create highly available [PostgreSQL database clusters](d-pgsql.md); create different types of [Redis clusters](d-redis.md); deploy [Greenplum/MatrixDB](d-matrixdb.md) data warehouse and get real-time insights about nodes, databases, and applications.

```bash
# In a four-node local sandbox/cloud demo environment, the database cluster can be deployed on the other three nodes using the following command
. /nodes.yml -l pg-test 		# Initialize the three machine nodes included in cluster pg-test (configure nodes + incorporate monitoring)
. /pgsql.yml -l pg-test 		# Initialize the highly available PGSQL database cluster pg-test
. /redis.yml -l redis-test 		# Initialize the Redis cluster redis-test
. /pigsty-matrix.yml -l mx-* 	# Initialize MatrixDB cluster mx-mdw,mx-sdw
```



----------------

## Sandbox Environment

Pigsty has designed a standard, 4-node demo teaching environment called **sandbox environment** that you can refer to [tutorial](d-sandbox.md) and use Vagrant or Terraform to quickly pull up the required four VM resources on local or public cloud and deploy them for testing. After running through the process with minor modifications, it can be used for production environment [deployment](d-deploy.md).

[![](_media/SANDBOX.gif)](d-sandbox.md)

Using the default [sandbox environment](d-sandbox.md) as an example, assume you have completed a standalone Pigsty installation on the ``10.10.10.10`` admin node.

```bash
. /infra.yml # Complete the full standalone Pigsty installation on the 10.10.10.10 meta machine in the sandbox environment
```

#### Host Init

Three nodes: ``10.10.10.11``, ``10.10.10.12``, ``10.10.10.13`` are now managed using the [``nodes.yml``](p-nodes.md#nodes) playbook.

```bash
. /nodes.yml -l pg-test     # Initialize the three machine nodes contained in cluster pg-test (configure nodes + incorporate monitoring)
```

After execution, these three nodes already come with DCS services, host monitoring, and log collection. They can be used for subsequent database cluster deployments. Please refer to the node [config](v-nodes.md) and [playbook](p-nodes.md) for details.

#### PostgreSQL Deployment

Using the [`pgsql.yml`](p-pgsql.md#pgsql) playbook, you can initialize a highly available PostgreSQL database cluster `pg-test` with one master and two slaves on these three nodes.

```bash
./pgsql.yml  -l pg-test      # Initializing the highly available PGSQL database cluster pg-test
```

Once the deployment is completed, you can see the newly created PostgreSQL cluster in [Monitor](http://demo.pigsty.cc/d/pgsql-cluster/pgsql-cluster?var-cls=pg-test).

For details, please refer to PgSQL Database Cluster [Config](v-pgsql.md), [Customize,](v-pgsql-customize.md) and [Playbook](p-pgsql.md).


### Redis Deployment

In addition to the standard PostgreSQL cluster, you can deploy various other types of clusters, and even other types of databases.

For example, to deploy [Redis](d-redis.md) in a sandbox, you can use the Redis database cluster [config](v-redis.md) with the [playbook](p-redis.md).

```bash   
. /configure -m redis
. /nodes.yml 	# Configure all nodes for Redis installation
. /redis.yml 	# Declare Redis on all nodes as configured
```

Check [Config: REDIS](v-redis.md) with [script], [Playbook: REDIS](p-redis.md) for more details.


#### MatrixDB Deployment

To deploy the open-source data warehouse [MatrixDB](d-matrixdb.md) in a sandbox (Greenplum7), the following command can be used.

```bash
. /configure -m mxdb   		# Use the sandbox environment MatrixDB config file template
. /download matrix   		# Download MatrixDB package and build local repos
. /infra.yml -e no_cmdb=true # If you are going to deploy MatrixDB Master on a meta node, add the no_cmdb option, otherwise just install it normally.   
. /nodes.yml 				# Configure all nodes for MatrixDB installation
. /pigsty-matrix.yml 		# Install MatrixDB on the above nodes
```
