# Installation

> It takes 3 steps to install Pigsty: [Prepare](d-prepare.md), [Configure](v-config.md#configure), [Execute Playbook](p-playbook.md)


----------------

![](_media/HOW_EN.svg)

There two typical modes: Singleton & Cluster Management

* Singleton Meta: Install pigsty on one single meta node. (for dev/test postgres alone, monitoring RDS, etc...)
* Cluster Manage:  Manage & monitoring more nodes & databases. Initiate control from meta node

---------------------

## Singleton Meta

When Pigsty is installed on one single node. It will init pigsty infra with a battery included Postgres as CMDB. You may use that database directly.

#### TL; DR

[Prepare](#prepare) a **new** node : Linux x86_64 CentOS 7.8.2003, with **root** or **sudo** access, then [download](d-prepare.md#software-provisioning) pigsty

```bash
bash -c "$(curl -fsSL http://download.pigsty.cc/get)"  # Download Latest Pigsty Source
cd ~/pigsty; ./configure                               # Configure pigsty with ip & template
./infra.yml                                            # Install pigsty on current meta node
```

> If you have available Mac/PC/Laptop/Cloud Account, [Sandbox](d-sandbox.md) could be handy to create vm for you. 

After installation. port `5432` is ready for postgres database connection @ `postgres://dbuser_dba:DBUser.DBA@10.10.10.10:5432/meta`.
And a nginx is serving & proxy all WebUI service @ port `80`. 

<details><summary>Download Directly via Curl</summary>

```bash
curl https://github.com/Vonng/pigsty/releases/download/v1.4.0/pigsty.tgz -o /tmp/pigsty.tgz
curl https://github.com/Vonng/pigsty/releases/download/v1.4.0/pkg.tgz    -o /tmp/pkg.tgz  
```

</details>

#### Access Web Services

Nginx port 80 is the default access endpoint for all Web GUI services. Although it is possible to bypass nginx add access services directly by port, such as Grafana on 3000, it is highly recommended using domain names. If you don't have public domain names, considering use [static DNS](d-sandbox.md#DNS-configuration) on your localhost with `make dns`.

> http://g.pigsty or `http://<primary_ip>:3000` is the portol of monitoring system (username: admin, password: pigsty)

> Visit `http://<primary_ip>:3000` / http://g.pigsty to visit Pigsty [Grafana](http://demo.pigsty.cc/d/home) (username: `admin`, password: `pigsty`)




----------------

## Cluster Mange

Pigsty can also be used as controller & monitoring infrastructure for large scale nodes & databases.

You can initiate control from [meta](c-arch.md) node, and add more [nodes](p-nodes.md) into Pigsty.

You can deploy diffferent types of High available [PostgreSQL](d-pgsql.md) Clusters, [Redis](d-redis.md) clusters, or [Greenplum/MatrixDB](d-matrixdb.md) data warehouse.

```bash
./nodes.yml  -l pg-test      # init 3 nodes of cluster pg-test
./pgsql.yml  -l pg-test      # init HA PGSQL Cluster pg-test
./redis.yml  -l redis-test   # init redis cluster redis-test
./pigsty-matrix.yml -l mx-*  # init MatrixDB: mx-mdw,mx-sdw
```



----------------

## Sandbox

There's a standard 4-node demonstration environment for pigsty, named 'Sandbox'. You can create sandbox on your laptop with [Vagrant](d-prepare.md#vagrant), or create them on cloud with [terraform](d-prepare.md#terraform). The same deploy procedure could apply to production [deployment](d-deploy.md).

[![](_media/SANDBOX.gif)](d-sandbox.md)

Take sandbox as example, install pigsty on meta node `10.10.10.10` with:

```bash
. /infra.yml     # install pigsty on meta node 10.10.10.10
```

#### Nodes Init

Now add 3 more nodes `10.10.10.11`, `10.10.10.12`, `10.10.10.13` into pigsty [`nodes.yml`](p-nodes.md#nodes) 

```bash
./nodes.yml -l pg-test        # init 3 nodes of cluster pg-test
```

After that, these 3 nodes are set with DCS service, node metrics exporter & logging collector. And can be used for subsequent database deployment. check [Config: Nodes](v-nodes.md) & [Playbook: Nodes](p-nodes.md) for details.  


#### PostgreSQL Deploy

Create a classic 1 primary & 2 replica HA PostgreSQL cluster with [`pgsql.yml`](p-pgsql.md#pgsql) playbook.

```bash
./pgsql.yml -l pg-test  # init pgsql cluster pg-test
```

Once complete, you can check the newly created PostgreSQL cluster from [monitoring system](http://demo.pigsty.cc/d/pgsql-cluster/pgsql-cluster?var-cls=pg-test). 

Check [Config: PGSQL](v-pgsql.md), [Customize: PGSQL](v-pgsql-customize.md) and [Playbook: PGSQL](p-pgsql.md) for more details.


### Redis Deployment

In addition to PostgreSQL cluster, you can deploy various other types of clusters, and even other types of databases.

For example, to deploy [Redis](d-redis.md) in sandbox(p-redis.md).

```bash   
. /configure -m redis    # use redis config template
. /nodes.yml             # init nodes for redis cluster
. /redis.yml             # create redis on those nodes
```

Check [Config: REDIS](v-redis.md) with [script], [Playbook: REDIS](p-redis.md) for more details.


#### MatrixDB Deployment

To deploy the open source timeseries data warehouse [MatrixDB](d-matrixdb.md)(Greenplum7):

```bash
./configure -m mxdb   # Use the sandbox environment MatrixDB configuration file template
./download matrix     # Download the MatrixDB package and build the local source
./infra.yml -e no_cmdb=true # If you are going to deploy MatrixDB Master on a meta node, add the no_cmdb option, otherwise just install it normally.
./nodes.yml           # configure all nodes for MatrixDB installation
./pigsty-matrix.yml   # Install MatrixDB on the above nodes
```
