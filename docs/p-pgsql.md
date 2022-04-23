# Playbook：PGSQL

> Pull up a defined cluster of highly available PostgreSQL databases using the PGSQL series [playbook](p-playbook.md).



## Overview

| Playbook | Function                                                   | Link                                                     |
|--------|----------------------------------------------------------------| ------------------------------------------------------------ |
|  [`pgsql`](p-pgsql.md#pgsql)                        | **Deploy a PostgreSQL cluster, or cluster expansion** |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql.yml)            |
|  [`pgsql-remove`](p-pgsql.md#pgsql-remove)          | Offline PostgreSQL cluster, or cluster shrinkage |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-remove.yml)     |
|  [`pgsql-createuser`](p-pgsql.md#pgsql-createuser)  |      Creating PostgreSQL business users |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-createuser.yml) |
|  [`pgsql-createdb`](p-pgsql.md#pgsql-createdb)      | Creating a PostgreSQL Business Database |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-createdb.yml)   |
|  [`pgsql-monly`](p-pgsql.md#pgsql-monly)            | Monitor-only mode, with access to existing PostgreSQL instances or RDS |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-monly.yml)      |
|  [`pgsql-migration`](p-pgsql.md#pgsql-migration)    | Generate PostgreSQL semi-automatic database migration solution (Beta) |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-migration.yml)  |
|  [`pgsql-audit`](p-pgsql.md#pgsql-audit)            | Generate PostgreSQL Audit Compliance Report (Beta) |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-audit.yml)      |
|  [`pgsql-matrix`](p-pgsql.md#pgsql-matrix)          | Reuse the PG role to deploy a set of MatrixDB data warehouse clusters (Beta) |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-matrix.yml)     |



------------------

## `pgsql`

After completing the [**infrastructure initialization**](p-infra.md)，users can use[ `pgsql.yml`](https://github.com/Vonng/pigsty/blob/master/pgsql.yml) to complete the **initialization** of the database cluster.

First complete the definition of the database cluster in the **Pigsty configuration file** and then apply the changes to the actual environment by executing `pgsql.yml`.

```bash
./pgsql.yml                      # Perform database cluster initialization operations on all machines in the list (Danger!)
./pgsql.yml -l pg-test           # Perform database cluster initialization on the machines under the pg-test group (recommended!)
./pgsql.yml -l pg-meta,pg-test   # Initialize both pg-meta and pg-test clusters
./pgsql.yml -l 10.10.10.11       # Initialize the database instance on the machine 10.10.10.11
```

This playbook accomplishes the following：

* Install, deploy, initialize PostgreSQL, Pgbouncer, Patroni (`postgres`)
* Installing the PostgreSQL monitor (`monitor`)
* Install and deploy Haproxy and VIP, expose services to the public (`service`)
* Register the database instance to the infrastructure to be supervised (`register`)

**This script use will delete the database by mistake, because initializing the database will erase traces of the original database**.
The [insurance parameter](#protection mechanism) provides options to avoid accidental deletion and automatically abort or skip high-risk operations during initialization when an existing running instance is detected. 

Nevertheless, when **using `pgsql.yml`，double-check that the `--tags|-t` and `--limit|-l` parameters are correct. Make sure you are performing the right task on the right target.  Using `-pgsql.yml` without parameters is a high-risk operation in a production environment.** 


![](_media/playbook/pgsql.svg)



### Cautions

* It is strongly recommended to add the `-l` parameter to the execution to limit the range of objects for which the command can be executed.

* **Separately** when performing initialization for a cluster slave, you must ensure that the **master library has completed initialization**.

* When a cluster is expanded, if `Patroni` takes too long to pull up a slave, the Ansible playbook may abort due to a timeout. (But the process of making the slave library will continue, e.g. it takes more than 1 day to make the slave library).
* You can continue with subsequent steps from the `Wait for patroni replica online`  task via Ansible's `--start-at-task` after the slave library is automatically made. Please refer to [SOP](r-sop.md)。



### SafeGuard

The`pgsql.yml`provides **SafeGuard** determined by configuration parameter [`pg_exists_action`](v-pgsql.md#pg_exists_action).  When there is a running PostgreSQL instance on the target machine before the playbook is executed, pigsty will take action according to the configuration `abort|clean|skip` of [`pg_exists_action`](v-pgsql.md#pg_exists_action).

* `abort`：Set as the default configuration to abort script execution in case of existing instances to avoid accidental library deletion.
* `clean`：Use in a local sandbox environment and clear the existing database if an existing instance is encountered.
* `skip`： Execute subsequent logic directly on an existing database cluster. 
* You can  use `./pgsql.yml -e pg_exists_action=clean` to override the configuration file options and force the erasure of existing instances.

The [`pg_disable_purge`](v-pgsql.md#pg_disable_purge) provides dual protection. If this option is enabled, [`pg_exists_action`](v-pgsql.md#pg_exists_action) will be forced to be set to`abort`，and the running database instance will not be erased under any circumstances.

`dcs_exists_action ` and `dcs_disable_purge` has the same effect as the above two options, but it is for DCS。



### Selective execution

Users can choose to execute a subset of playbooks through ansible's tag mechanism.

For example, if you only want to perform the service initialization part, you can use the following command:

```bash
./pgsql.yml --tags=service      # Refreshing the service definition of a cluster
```

The common subsets of commands are as follows:

```bash
# Infrastructure initialization
./pgsql.yml --tags=infra        # Complete infrastructure initialization, including machine node initialization and DCS deployment


# Database initialization
./pgsql.yml --tags=pgsql        # Complete database deployment: database, monitoring, services

./pgsql.yml --tags=postgres     # Complete database deployment
./pgsql.yml --tags=monitor      # Complete monitoring deployment
./pgsql.yml --tags=service      # Complete load balancing deployment（Haproxy & VIP）
./pgsql.yml --tags=register     # Registering services to the infrastructure
```



### Daily management tasks

Daily management can also be used `./pgsql.yml` to modify the state of the database cluster. The common command subsets are as follows:

```bash
./pgsql.yml --tags=node_admin           # Create an administrator user on the target node

# If the current administrator does not have ssh to the target node, you can use another user with ssh to create an administrator (enter the password)
./pgsql.yml --tags=node_admin -e ansible_user=other_admin -k 

./pgsql.yml --tags=pg_scripts           # Update the /pg/bin/ directory script
./pgsql.yml --tags=pg_hba               # Regenerate and apply cluster HBA rules
./pgsql.yml --tags=pgbouncer            # Reset Pgbouncer
./pgsql.yml --tags=pg_user              # Full volume refresh business users
./pgsql.yml --tags=pg_db                # Full volume refresh of business database

./pgsql.yml --tags=register_consul      # Register the Consul service locally with the target instance (local execution)
./pgsql.yml --tags=register_prometheus  # Register monitoring objects in Prometheus (proxy to all Meta nodes for execution)
./pgsql.yml --tags=register_grafana     # Register monitoring objects in Grafana (only once)
./pgsql.yml --tags=register_nginx       # Register a load balancer with Nginx (proxy to all Meta nodes for execution)

# Redeploy monitoring using binary installation
./pgsql.yml --tags=monitor -e exporter_install=binary

# Refresh the service definition of the cluster (changes in cluster membership or service definition)
./pgsql.yml --tags=haproxy_config,haproxy_reload
```


------------------

## `pgsql-remove`


Database offline: **Remove** existing database cluster or instance, reclaim node: [`pgsql-remove.yml`](https://github.com/Vonng/pigsty/blob/master/pgsql-remove.yml)

The `pgsql-remove.yml` is the reverse of [`pgsql.yml`](p-pgsql.md) and will do the following ：

* Unregister the database instance from the infrastructure（`register`）
* Stop the load balancer, service component（`service`）
* Removal of monitoring system components（`monitor`）
* Remove Pgbouncer, Patroni, Postgres（`postgres`）
* Remove database directory（`rm_pgdata: true`）
* Remove Package（`rm_pkgs: true`）

The playbook has two command line options to remove the database directory and packages (the default offline does not remove data and installers).

```
rm_pgdata: false        # remove postgres data? false by default
rm_pgpkgs: false        # uninstall pg_packages? false by default
```

![](_media/playbook/pgsql-remove.svg)


### Daily management

```bash
./pgsql-remove.yml -l pg-test          # Offline pg-test cluster
./pgsql-remove.yml -l 10.10.10.13      # Offline instance 10.10.10.13 (actually pg-test.pg-test-3)
./pgsql-remove.yml -l 10.10.10.13 -e rm_pgdata=true # Offline and remove the data directory (may be slow)
./pgsql-remove.yml -l 10.10.10.13 -e rm_pkgs=true   # Offline and remove the installed PG-related packages
```





------------------

## `pgsql-createdb`

[**created business database**](#pgsql-createdb): Create a new database in an existing cluster or modify an existing **database**: [`pgsql-createdb.yml`](https://github.com/Vonng/pigsty/blob/master/pgsql-createdb.yml)

![](_media/playbook/pgsql-createdb.svg)

The author recommends creating a new database in an existing cluster via a playbook or scripting tool, which ensures that.

* Configuration file list is consistent with the actual situation
* Pgbouncer connection pools are consistent with the database
* The data sources registered in Grafana are consistent with the actual situation.



### Daily management

Please refer to the section [Database](c-pgdbuser.md#create-databsae) for the creation of the database.

```bash
# Create a database named test in the pg-test cluster
./pgsql-createdb.yml -l pg-test -e pg_database=test
```

Simplify commands using wrapper scripts:

```bash
bin/createdb <pg_cluster> <dbname>
```


------------------

## `pgsql-createuser`

[**create business users**](#pgsql-createuser)：Create a new user or modify an existing **user** in an existing cluster：[`pgsql-createuser.yml`](https://github.com/Vonng/pigsty/blob/master/pgsql-createuser.yml)

![](_media/playbook/pgsql-createuser.svg)

### Daily management

Please refer to the section [User](c-pgdbuser.md#create-user) for the create of business users.

```bash
# Create a user named test in the pg-test cluster
./pgsql-createuser.yml -l pg-test -e pg_user=test
```

Simplify commands using wrapper scripts:

```bash
bin/createuser <pg_cluster> <username>
```

Note, ` PG_ User ` the specified user, **must**  already exist in the cluster `pg_users`, otherwise an error will be reported. This means that the user must define before creating.


------------------

## `pgsql-monly`

Dedicated playbook for performing monitoring deployments, see:  [monitor-only deployments](d-monly.md) for details.


![](_media/playbook/pgsql-monly.svg)


------------------

## `pgsql-matrix`

Dedicated playbook for deploying MatrixDB, see: [Deploying MatrixDB Cluster](d-matrixdb.md) for details.

![](_media/playbook/pgsql-matrix.svg)


------------------

## `pgsql-migration`

Playbook for automated database migration, still in Beta status, see [database cluster migration](t-migration.md) for details.

![](_media/playbook/pgsql-migration.svg)