# MatrixDB Deployment

> Pigsty can be used to deploy and monitor MatrixDB (equivalent to Greenplum 7+ chronological database functionality).

Since MatrixDB currently uses PostgreSQL 12 kernel and native Greenplum still uses 9.6 kernels, priority is given to using MatrixDB as Greenplum implementation, and native Greenplum support will be added later.



## E-R Model

MatrixDB logically consists of two parts, Master and Segments, both of which are composed of PostgreSQL instances, which are divided into four categories: Master/Standby/Primary/Mirror.

* Master is the access endpoint directly contacted by users, used to undertake queries, there is only one set of MatrixDB deployment, usually using independent node deployment.
* Standby is the physical slave of the Master instance, used to take over when the Master fails, and is an optional component, usually deployed on a standalone node as well.
* A MatrixDB deployment typically has multiple Segments, each of which typically consists of a mandatory primary instance and an optional mirror instance.
* The primary of a Segment is responsible for the actual storage and computation, and the mirror usually does not carry the read and write traffic, but takes over when the primary is down, and is usually distributed on different nodes from the primary.
* The distribution of primary and mirror of Segment is determined by MatrixDB installation wizard, and there may be several different Segment instances on the Segments node of the cluster.

**Deployment conventions**

* Master cluster (master/standby) ([`gp_role`](v-pgsql.md#gp_role) = `master`) constitutes a PostgreSQL cluster, usually named to contain `mdw`, e.g. `mx-mdw`.
* Each Segment (primary/mirror) ([`gp_role`](v-pgsql.md#gp_role) = `segment`) constitutes a PostgreSQL cluster, usually named with `seg`, e.g. `mx-seg1`, `mx-seg2`.
* The user should explicitly name the cluster nodes, e.g. `mx-sdw-1`, `mx-sdw-2`, ...



## Download

The RPM pkgs for MatrixDB & Greenplum are not part of the standard Pigsty deployment and therefore will not be placed in the default `pkg.tgz`.
The RPM pkgs for MatrixDB & Greenplum and their complete dependencies will be packaged as a separate offline pkg [`matrix.tgz`](https://github.com/Vonng/pigsty/releases/download/v1.4.0/matrix.tgz).
You can add new `matrix` repos to the Pigsty admin node.

```bash
# Download Address（Github）：https://github.com/Vonng/pigsty/releases/download/v1.4.0/matrix.tgz
# Download Address（China CDN）：http://download.pigsty.cc/v1.4.0/matrix.tgz
# Download the script on the meta node, under the pigsty dir, directly using the download matrix to download and unzip
./download matrix
```

This command creates a `/www/matrix.repo` file, which by default you can access at `http://pigsty/matrix.repo` to get the repo, which points to the `http://pigsty/matrix` dir.



## Configure

The MatrixDB / Greenplum installation will reuse the PGSQL tasks and config with the exclusive config parameters [`gp_role`](v-pgsql.md#gp_role) and [`pg_instances`](v-pgsql.md#pg_instances).

The config file [`pigsty-mxdb.yml`](https://github.com/Vonng/pigsty/blob/master/files/conf/pigsty-mxdb.yml) gives a sample deployment of MatrixDB in a four-node sandbox env.

```bash
Using `configure -m mxdb` will automatically use this config file as a template.
./configure -m mxdb
```

This config file [`node_local_repo_url`](v-nodes.md#node_local_repo_url) adds the new Yum repo, and `http://pigsty/matrix.repo` ensures that all nodes have access to Matrix Repo.




## Execute

Deploy MatrixDB in a four-node sandbox env, note that the default will be to use DBSU `mxadmin:mxadmin` as the monitoring username and password.

```bash
#  If you deploy MatrixDB Master on a meta node, add the no_cmdb option, otherwise just install it normally.
./infra.yml -e no_cmdb=true   

# Configure all nodes for MatrixDB installation
./nodes.yml

# Install MatrixDB on the above node
./pigsty-matrix.yml
```

Once the installation is complete, you will need to complete the next installation via the WEB UI provided by MatrixDB. Open [http://matrix.pigsty](http://matrix.pigsty) or visit http://10.10.10.10:8240 and fill in the initial user password output at the end of `pgsql-matrix.yml` to enter the installation wizard. 

Follow the prompts to add MatrixDB nodes in order: 10.10.10.11, 10.10.10.12, 10.10.10.13, click to confirm installation, and wait for completion before proceeding to the next step.

Since monitoring uses `mxadmin:mxadmin` as the monitoring username password by default, please fill in `mxadmin` or your password. 

If you specified a different password in the installation wizard, change the [`pg_monitor_username`](v-pgsql.md#pg_monitor_username) and [`pg_monitor_password`](v-pgsql.md#pg_monitor_ password) variables together. password) variables (if using a different user than dbsu, additional HBAs usually need to be configured on all instances as well).

Note that the logic for MatrixDB / Greenplum to assign Segments on nodes is currently uncertain. Once initialization is complete, the definition of Segment instances in [`pg_instances`](v-pgsql.md#pg_instances) can be modified and monitoring redeployed to reflect the true topology.



## Post-Run

Finally, manually execute the following command on the Greenplum/MatrixDB Master node to allow the monitoring component to access the **slave library** and restart it to take effect.

```bash
sudo su - mxadmin
psql postgres -c "ALTER SYSTEM SET hot_standby = on;"  # Configure hot_standby=on to allow queries from the library
gpconfig -c hot_standby -v on -m on                    # Configure hot_standby=on to allow queries from the library
gpstop -a -r -M immediate                              # Restart MatrixDB immediately to take effect
```

All MatrixDB clusters can then be observed from the monitoring system. the MatrixDB Dashboard provides an overview of the overall monitoring of the data warehouse.



## Optional

You can treat MatrixDB's Master cluster as a normal PostgreSQL cluster and use [`pgsql-createdb`](p-pgsql.md#pgsql-createdb) with [`pgsql-createuser`](p-pgsql.md#pgsql- createuser) to create a business database with users.

```bash
bin/createuser mx-mdw  dbuser_monitor   # Create monitoring user on Master
bin/createdb   mx-mdw  matrixmgr        # Create a dedicated database for monitoring on the Master
bin/createdb   mx-mdw  meta             # Create a new database on the Master
```



