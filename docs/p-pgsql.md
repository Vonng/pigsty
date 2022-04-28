# Playbook: PGSQL

> Pull up a defined cluster of HA PostgreSQL cluster using the PGSQL series [playbook](p-playbook.md).



## Overview

| Playbook | Function                                                   | Link                                                     |
|--------|----------------------------------------------------------------| ------------------------------------------------------------ |
|  [`pgsql`](p-pgsql.md#pgsql)                        | **Deploy a PostgreSQL cluster, or cluster expand** |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql.yml)            |
|  [`pgsql-remove`](p-pgsql.md#pgsql-remove)          | Destroy PostgreSQL cluster, or cluster downsize |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-remove.yml)     |
|  [`pgsql-createuser`](p-pgsql.md#pgsql-createuser)  |     Create PostgreSQL business users |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-createuser.yml) |
|  [`pgsql-createdb`](p-pgsql.md#pgsql-createdb)      | Create a PostgreSQL Business Database |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-createdb.yml)   |
|  [`pgsql-monly`](p-pgsql.md#pgsql-monly)            | Monly mode, with access to existing PostgreSQL instances or RDS |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-monly.yml)      |
|  [`pgsql-migration`](p-pgsql.md#pgsql-migration)    | Generate PostgreSQL semi-automatic database migration solution (Beta) |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-migration.yml)  |
|  [`pgsql-audit`](p-pgsql.md#pgsql-audit)            | Generate PostgreSQL Audit Compliance Report (Beta) |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-audit.yml)      |
|  [`pgsql-matrix`](p-pgsql.md#pgsql-matrix)          | Reuse the PG to deploy a set of MatrixDB clusters (Beta) |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-matrix.yml)     |



------------------

## `pgsql`

After completing the [**infra initialization**](p-infra.md), users can use [ `pgsql.yml`](https://github.com/Vonng/pigsty/blob/master/pgsql.yml) to complete the **initialization** of the database cluster.

Complete the cluster definition in the **Pigsty configuration file** and then apply the changes to the environment by executing `pgsql.yml`.

```bash
./pgsql.yml                      # Perform cluster initialization on all machines in the list (Danger!)
./pgsql.yml -l pg-test           # Perform cluster initialization on the machines under the pg-test group (recommended!)
./pgsql.yml -l pg-meta,pg-test   # Initialize both pg-meta and pg-test clusters
./pgsql.yml -l 10.10.10.11       # Initialize the instance on the machine 10.10.10.11
```

This playbook accomplishes the following.

* Install, deploy, and initialize PostgreSQL, Pgbouncer, Patroni (`postgres`).
* Install the PostgreSQL monitor (`monitor`).
* Install and deploy Haproxy and VIP, expose services (`service`).
* Register the database instance to the infra to be monitored (`register`).

**This playbook can be misused to accidentally delete the database, as initializing the database will erase the existing database**.

The [insurance param](#SafeGuard) prevents accidental deletion by allowing automatic aborting or skipping of high-risk operations during initialization when an existing running instance is detected. 

Nevertheless, **when using `pgsql.yml`, double-check that `-tags|-t` and `-limit|-l` is correct**.


![](_media/playbook/pgsql.svg)



### Cautions

* It is strongly recommended to add the `-l` parameter to the execution to limit the scope of the command execution.
* When performing initialization for a replica, the user must ensure that **the primary has completed initialization.**
* If `Patroni` takes too long to pull up a replica when a cluster is expanded, the Ansible playbook may abort due to a timeout. (However, making the replica will continue, for example, in scenarios where making the replica takes more than one day).
* It is possible to perform subsequent steps from the `-Wait for patroni replica online` task via Ansible's `-start-at-task` after the replica has been automatically crafted. Please refer to [SOP](r-sop.md) for details.



### SafeGuard

`pgsql.yml` provides a **SafeGuard** determined by the parameter [`pg_exists_action`](v-pgsql.md#pg_exists_action). Pigsty will act according to the configuration `abort|clean|skip` of [`pg_exists_action`](v-pgsql.md#pg_exists_action) when the target machine has a running instance before executing the playbook.

* `abort`: Set as the default configuration to abort playbook execution in case of existing instances to avoid accidental database deletion.
* `clean`: To use in a local sandbox and clear the existing database in case of current instances.
* `skip`: Execute subsequent logic directly on an existing database cluster. 
* You can use `./pgsql.yml -e pg_exists_action=clean` to override the configuration file options and force the erasure of existing instances.

The [`pg_disable_purge`](v-pgsql.md#pg_disable_purge) provides double protection. If this option is enabled, [`pg_exists_action`](v-pgsql.md#pg_exists_action) will be forced to be set to `abort`, and the running database instance will not be erased under any circumstances.

`consul_clean ` and `consul_safeguard` have the same effect as the above two options, but it is for DCS。



### Selective execution

An ansible's tagging mechanism can select a subset of the execution playbook.

For example, if you want to perform only service initialization, you can use the following command.

```bash
./pgsql.yml --tags=service      # Refreshing the service definition of a cluster
```

The common subsets of commands are as follows.

```bash
# Infra initialization
./pgsql.yml --tags=infra        # Complete infra initialization, including machine node initialization and DCS deployment


# Database initialization
./pgsql.yml --tags=pgsql        # Complete database deployment: database, monitoring, services

./pgsql.yml --tags=postgres     # Complete database deployment
./pgsql.yml --tags=monitor      # Complete monitoring deployment
./pgsql.yml --tags=service      # Complete load balancing deployment（Haproxy & VIP）
./pgsql.yml --tags=register     # Registering services to the infra
```



### Daily management tasks

Daily management can also be used `./pgsql.yml` to modify the state of the cluster. The common command subsets are as follows.

```bash
./pgsql.yml --tags=node_admin           # Create an admin user on the target node

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
./pgsql.yml --tags=register_nginx       # Register a LB with Nginx (proxy to all Meta nodes for execution)

# Redeploy monitoring using binary installation
./pgsql.yml --tags=monitor -e exporter_install=binary

# Refresh the service definition of the cluster (changes in cluster membership or service definition)
./pgsql.yml --tags=haproxy_config,haproxy_reload
```


------------------

## `pgsql-remove`


Database Destruction: **Remove** existing database cluster or instance, reclaim node: [`pgsql-remove.yml`](https://github.com/Vonng/pigsty/blob/master/pgsql-remove.yml).

The `pgsql-remove.yml` is the reverse of [`pgsql.yml`](p-pgsql.md) and will do the following ：

* Unregister the database instance from the infra（`register`）
* Stop the LB, service component（`service`）
* Removal of monitoring system components（`monitor`）
* Remove Pgbouncer, Patroni, Postgres（`postgres`）
* Remove database dir（`rm_pgdata: true`）
* Remove Package（`rm_pkgs: true`）

The playbook has two command-line options to remove the database dir and packages (the default destruction does not remove data and packages).

```
rm_pgdata: false        # remove postgres data? false by default
rm_pgpkgs: false        # uninstall pg_packages? false by default
```

![](_media/playbook/pgsql-remove.svg)


### Daily management

```bash
./pgsql-remove.yml -l pg-test          # Destruction pg-test cluster
./pgsql-remove.yml -l 10.10.10.13      # Destruction instance 10.10.10.13 (pg-test.pg-test-3)
./pgsql-remove.yml -l 10.10.10.13 -e rm_pgdata=true # Destruction and remove the data dir (slow)
./pgsql-remove.yml -l 10.10.10.13 -e rm_pkgs=true   # Destruction and remove the installed PG-related packages
```





------------------

## `pgsql-createdb`

[**Created business database**](#pgsql-createdb): Create a new database in an existing cluster or modify a current **database**: [`pgsql-createdb.yml`](https://github.com/Vonng/pigsty/blob/master/pgsql-createdb.yml).

![](_media/playbook/pgsql-createdb.svg)

To ensure that, the author recommends creating a new database in an existing cluster via a playbook or scripting tool.

* The inventory is consistent with the actual situation.
* Pgbouncer connection pools are consistent with the database.
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

[**Create business users**](#pgsql-createuser): Create a new user or modify an existing **user** in an existing cluster：[`pgsql-createuser.yml`](https://github.com/Vonng/pigsty/blob/master/pgsql-createuser.yml).

![](_media/playbook/pgsql-createuser.svg)

### Daily management

Please refer to the section [User](c-pgdbuser.md#create-user) for the creation of business users.

```bash
# Create a user named test in the pg-test cluster
./pgsql-createuser.yml -l pg-test -e pg_user=test
```

Simplify commands using wrapper scripts.

```bash
bin/createuser <pg_cluster> <username>
```

Note that the user-specified by `pg_user` **must** already be in the definition of the cluster `pg_users`. Otherwise, an error will be reported.


------------------

## `pgsql-monly`

Dedicated playbook for performing monitoring deployments. See [monly deployments](d-monly.md) for details.


![](_media/playbook/pgsql-monly.svg)


------------------

## `pgsql-matrix`

Dedicated playbook for deploying MatrixDB. See [Deploying MatrixDB Cluster](d-matrixdb.md) for details.

![](_media/playbook/pgsql-matrix.svg)


------------------

## `pgsql-migration`

Playbook for automated database migration, still in Beta status. See [database cluster migration](t-migration.md) for details.

![](_media/playbook/pgsql-migration.svg)