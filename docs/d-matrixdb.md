# MatrixDB Deployment

> Pigsty can be used to deploy and monitor MatrixDB (equal to Greenplum 7+ Time-Series database).

Currently, MatrixDB uses PostgreSQL 12 kernel, while native Greenplum uses 9.6 kernels, so MatrixDB is used instead of Greenplum implementation, and Greenplum support will be added later.



## E-R Model

MatrixDB is logically divided into two parts, Master and Segments, composed of PostgreSQL instances, divided into four categories: Master/Standby/Primary/Mirror.

* Master is the port directly accessed by the user to take over queries. There is only one MatrixDB deployment, usually deployed using a standalone node.
* Standby is a physical replica of the Master instance, which takes over when the Master fails and is usually deployed using a standalone node, which is optional.
* A MatrixDB deployment typically has multiple Segments, each of which consists of a mandatory primary instance and an optional mirror instance.
* The segment's primary is responsible for the actual storage and computation, and the mirror does not carry the read and write traffic. It takes over for the primary when the primary is down, usually distributed on different nodes from the primary.
* MatrixDB installation wizard determines the distribution of primary and mirror of Segment, and there may be different Segment instances on Segments nodes of the cluster.

**Deployment conventions**

* Master cluster (master/standby) ([`gp_role`](v-pgsql.md#gp_role) = `master`) constitutes a PostgreSQL cluster, usually named to contain `mdw`, e.g., `mx-mdw`.
* Each Segment (primary/mirror) ([`gp_role`](v-pgsql.md#gp_role) = `segment`) constitutes a PostgreSQL cluster, usually named with `seg`, e.g., `mx-seg1`, `mx-seg2`.
* The user should explicitly name the cluster nodes, e.g., `mx-sdw-1`, `mx-sdw-2`, ...



## Download

The RPM pkgs for MatrixDB & Greenplum are not part of the standard Pigsty deployment and will not be placed in the default `pkg.tgz`.

The RPM pkgs for MatrixDB & Greenplum and their complete dependencies will be packaged as a separate offline pkg [`matrix.tgz`](https://github.com/Vonng/pigsty/releases/download/v1.4.1/matrix.tgz).

You can add new `matrix` sources to the Pigsty meta node.

```bash
# Download Address（Github）：https://github.com/Vonng/pigsty/releases/download/v1.4.1/matrix.tgz
# Download Address（China CDN）：http://download.pigsty.cc/v1.4.1/matrix.tgz
# Download the script on the meta node, under the pigsty dir, directly using the download matrix to download and unzip
./download matrix
```

This command creates a `/www/matrix.repo` file, which by default you can access at `http://pigsty/matrix.repo` to get the repo, which points to the `http://pigsty/matrix`.



## Configure

The MatrixDB / Greenplum installation will reuse the PGSQL tasks and config with the exclusive config parameters [`gp_role`](v-pgsql.md#gp_role) and [`pg_instances`](v-pgsql.md#pg_instances).

The config file [`pigsty-mxdb.yml`](https://github.com/Vonng/pigsty/blob/master/files/conf/pigsty-mxdb.yml) gives a sample deployment of MatrixDB in a four-node sandbox.

```bash
Using `configure -m mxdb` will automatically use this config file as a template.
./configure -m mxdb
```

This config file [`node_repo_local_urls`](v-nodes.md#node_repo_local_urls) adds the new Yum repo, and `http://pigsty/matrix.repo` ensures that all nodes access Matrix Repo.




## Execute

Deploy MatrixDB in a four-node sandbox. Note. Otherwise, the default will be to use DBSU `mxadmin:mxadmin` as the monitoring username and password.

```bash
#  If you deploy MatrixDB Master on a meta node, add the no_cmdb option; otherwise, install it normally.
./infra.yml -e no_cmdb=true   

# Configure all nodes for MatrixDB installation
./nodes.yml

# Install MatrixDB on the above node
./pigsty-matrix.yml
```

Once the installation is complete, you need to complete the next installation through the WEB UI provided by MatrixDB. Open [http://matrix.pigsty](http://matrix.pigsty) or visit http://10.10.10.10:8240 and fill in `pgsql-matrix.yml` with the initial user password output at the end to enter the installation wizard. 

Follow the prompts to add the MatrixDB nodes: 10.10.10.11, 10.10.10.12, 10.10.10.13, click Confirm Installation and proceed to the next step.

Monitoring uses `mxadmin:mxadmin` as the monitoring username password by default. Please fill in `mxadmin` or your password. 

If a different password was specified in the installation wizard, change the [`pg_monitor_username`](v-pgsql.md#pg_monitor_username) and [`pg_monitor_password`](v-pgsql.md#pg_monitor_password ) variables (using another user than dbsu, additional HBAs will usually need to be configured on all instances as well).

Note that the logic for MatrixDB / Greenplum to assign Segments on nodes is currently uncertain. Once initialization is complete, you can modify the definition of Segment instances in [`pg_instances`](v-pgsql.md#pg_instances) and redeploy monitoring to reflect the true topology.



## Post-Run

Finally, manually execute the following command on the Greenplum/MatrixDB Master node to allow the monitoring component to access the **replica** and restart it to take effect.

```bash
sudo su - mxadmin
psql postgres -c "ALTER SYSTEM SET hot_standby = on;"  # Configure hot_standby=on to allow queries from the replica
gpconfig -c hot_standby -v on -m on                    # Configure hot_standby=on to allow queries from the replica
gpstop -a -r -M immediate                              # Restart MatrixDB immediately to take effect
```

All MatrixDB clusters can then be observed from the monitoring system. The MatrixDB Dashboard provides an overview of the overall monitoring of the data warehouse.



## Optional

You can treat MatrixDB's Master cluster as a standard PostgreSQL cluster and use [`pgsql-createdb`](p-pgsql.md#pgsql-createdb) with [`pgsql-createuser`](p-pgsql.md#pgsql-createuser) to create a business database with users.

```bash
bin/createuser mx-mdw  dbuser_monitor   # Create a monitoring user on Master
bin/createdb   mx-mdw  matrixmgr        # Create a dedicated database for monitoring on the Master
bin/createdb   mx-mdw  meta             # Create a new database on the Master
```



