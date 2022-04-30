# Installation

> It takes 3 steps to install Pigsty: [Prepare](d-prepare.md), [Configure](v-config.md#configure), [Execute Playbook](p-playbook.md)


----------------

![](_media/HOW_EN.svg)

There are two typical modes: Singleton & Cluster Management

* [Singleton Meta](#Singleton-Meta): Install pigsty on one single meta node. (for PostgreSQL dev/test, RDS monitoring, etc...)
* [Cluster Manage](#Cluster-Manage):  Initiate control from meta node, and manage & monitoring more nodes & databases. 



---------------------



## Singleton Meta

When Pigsty is installed on one single node. It will init pigsty infra with a battery including Postgres as CMDB. You may use that database directly.

#### TL; DR

[Prepare](d-prepare.md) a **new** node : Linux x86_64 CentOS 7.8.2003, with **root** or **sudo** access, then [download](d-prepare.md#software-provisioning) pigsty

```bash
bash -c "$(curl -fsSL http://download.pigsty.cc/get)"  # Download Latest Pigsty Source
cd ~/pigsty; ./configure                               # Configure pigsty with ip & template
./infra.yml                                            # Install pigsty on current meta node
```

> If you have available Mac/PC/Laptop/Cloud Account, [Sandbox](d-sandbox.md) could be handy to create vm for you.

After installation. port `5432` is ready for postgres database connection @ `postgres://dbuser_dba:DBUser.DBA@10.10.10.10:5432/meta`. 

And a Nginx is serving & proxy all WebUI services @ port `80`.

<details><summary>Download Directly via Curl</summary>

```bash
curl https://github.com/Vonng/pigsty/releases/download/v1.4.1/pigsty.tgz -o /tmp/pigsty.tgz
curl https://github.com/Vonng/pigsty/releases/download/v1.4.1/pkg.tgz    -o /tmp/pkg.tgz  
```

</details>

#### Access Web Services

Nginx port 80 is the default access endpoint for all Web GUI services. Although it is possible to bypass Nginx add access services directly by port, such as Grafana on 3000, it is highly recommended to use domain names. If you don't have public domain names, considering use [Static DNS](d-sandbox.md#DNS-Config) on your localhost with `make dns`.

> http://g.pigsty or `http://<primary_ip>:3000` is the portal of the monitoring system (username: admin, password: pigsty)

> Visit `http://<primary_ip>:3000` / http://g.pigsty to visit Pigsty [Grafana](http://demo.pigsty.cc/d/home) (username: `admin`, password: `pigsty`)




----------------

## Cluster Manage

Pigsty can also be used as a controller & monitoring infrastructure for production-grade large-scale nodes & databases.

You can initiate control from [meta](c-nodes.md#Meta-Node) node, and add more [nodes](c-nodes.md#node) into Pigsty.

You can deploy different types of High available [PostgreSQL](d-pgsql.md) Clusters, [Redis](d-redis.md) clusters, or [Greenplum/MatrixDB](d-matrixdb.md) data warehouse.

```bash
./nodes.yml  -l pg-test      # init 3 nodes of cluster pg-test
./pgsql.yml  -l pg-test      # init HA PGSQL Cluster pg-test
./redis.yml  -l redis-test   # init redis cluster redis-test
./pigsty-matrix.yml -l mx-*  # init MatrixDB: mx-mdw,mx-sdw
```



----------------

## Sandbox

There's a standard 4-node demo env for pigsty, named '[Sandbox](d-sandbox.md)'. You can create a sandbox on your laptop with [Vagrant](d-prepare.md#vagrant), or create them on public cloud with [Terraform](d-sandbox.md#Terraform). The same deployment procedure could apply to production [deployment](d-deploy.md). 

[![](_media/SANDBOX.gif)](d-sandbox.md)

Take [sandbox](d-sandbox.md) as an example, install pigsty on meta node `10.10.10.10` with:

```bash
. /infra.yml     # install pigsty on meta node 10.10.10.10
```

#### Nodes Init

Now add 3 more nodes `10.10.10.11`, `10.10.10.12`, `10.10.10.13` into pigsty [`nodes.yml`](p-nodes.md#nodes)

```bash
./nodes.yml -l pg-test        # init 3 nodes of cluster pg-test
```

After that, these 3 nodes are set with DCS service, node exporter & promtail logger. And can be used for subsequent database deployment. check [Config: Nodes](v-nodes.md) & [Playbook: Nodes](p-nodes.md) for details.


#### PostgreSQL Deploy

Create a classic 1 primary & 2 replicas HA PostgreSQL cluster with [`pgsql.yml`](p-pgsql.md#pgsql) playbook.

```bash
./pgsql.yml -l pg-test  # init pgsql cluster pg-test
```

Once complete, you can check the newly created PostgreSQL cluster from [Monitoring Dashboards](http://demo.pigsty.cc/d/pgsql-cluster/pgsql-cluster?var-cls=pg-test).

Check [Config: PGSQL](v-pgsql.md), [Customize: PGSQL,](v-pgsql-customize.md) and [Playbook: PGSQL](p-pgsql.md) for more details.


### Redis Deployment

In addition to the PostgreSQL cluster, you can deploy various other types of clusters and even other types of databases.

For example, to deploy [Redis](d-redis.md):

```bash   
. /configure -m redis    # use redis config template
. /nodes.yml             # init nodes for redis cluster
. /redis.yml             # create redis on those nodes
```

Check [Config: REDIS](v-redis.md) and [Playbook: REDIS](p-redis.md) for more details.


#### MatrixDB Deployment

To deploy the open-source time-series data warehouse [MatrixDB](d-matrixdb.md) (Greenplum7):

```bash
./configure -m mxdb   # Use the sandbox environment MatrixDB configuration file template
./download matrix     # Download the MatrixDB package and build the local source
./infra.yml -e no_cmdb=true # If meta node is part of it, add no_cmdb var to skip CMDB creation
./nodes.yml           # configure all nodes for MatrixDB installation
./pigsty-matrix.yml   # Install MatrixDB on those nodes
```
