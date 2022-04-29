# Upgrade Grafana Backend Database

You can use postgres as the database used by the Grafana backend.

In this tutorial, you will learn about the following.

* How to [create a new cluster](#create-cluster)
* How to [create a new biz user](#create-biz-user) in an existing database cluster
* How to [create a new biz database](#create-biz-database) in an existing database cluster
* How to [access databases](#access-database) created by Pigsty
* How to [manage dashboards](#manage-dashboard) in Grafana
* How to manage [PostgreSQL DataSources](#manage-datasources)  in Grafana
* How to do [upgrade the grafana database](#update-grafana-database)



## TL; DR


```bash
vi pigsty.yml   # uncomment user/db definition：dbuser_grafana  grafana 
bin/createuser  pg-meta  dbuser_grafana
bin/createdb    pg-meta  grafana

psql postgres://dbuser_grafana:DBUser.Grafana@meta:5436/grafana -c \
  'CREATE TABLE t(); DROP TABLE t;'    # check pgurl connectivity
  
vi /etc/grafana/grafana.ini            # edit [database] section: type & url
systemctl restart grafana-server
```



## Create Postgres Cluster

We can define a new database `grafana` on `pg-meta`.
A Grafana-specific database cluster can also be created on a new machine node: `pg-grafana`.

### Define Cluster

To create a new dedicated database cluster `pg-grafana` on two bare nodes `10.10.10.11`, `10.10.10.12`, 
define it in the config file.

```yaml
pg-grafana: 
  hosts: 
    10.10.10.11: {pg_seq: 1, pg_role: primary}
    10.10.10.12: {pg_seq: 2, pg_role: replica}
  vars:
    pg_cluster: pg-grafana
    pg_databases:
      - name: grafana
        owner: dbuser_grafana
        revokeconn: true
        comment: grafana primary database
    pg_users:
      - name: dbuser_grafana
        password: DBUser.Grafana
        pgbouncer: true
        roles: [dbrole_admin]
        comment: admin user for grafana database
```

---------------


### Create Cluster

Complete the creation of the database cluster `pg-grafana` with the following command: [`pgsql.yml`](p-pgsql.yml).

```bash
bin/createpg pg-grafana # Initialize the pg-grafana cluster
```

This command calls Ansible Playbook [`pgsql.yml`](p-pgsq.md) to create the database cluster.

```bash
. /pgsql.yml -l pg-grafana # The actual equivalent Ansible playbook command executed 
```

The business users and databases defined in `pg_users` and `pg_databases` are created automatically when the cluster is initialized. After creating the cluster using this configuration, the following connection string [access](c-service.md#access) database can be used.

```bash
postgres://dbuser_grafana:DBUser.Grafana@10.10.10.11:5432/grafana # direct connection to the primary
postgres://dbuser_grafana:DBUser.Grafana@10.10.10.11:5436/grafana # direct connection to the default service
postgres://dbuser_grafana:DBUser.Grafana@10.10.10.11:5433/grafana # Connect to the string read/write service

postgres://dbuser_grafana:DBUser.Grafana@10.10.10.12:5432/grafana # direct connection to the primary
postgres://dbuser_grafana:DBUser.Grafana@10.10.10.12:5436/grafana # Direct connection to default service
postgres://dbuser_grafana:DBUser.Grafana@10.10.10.12:5433/grafana # Connected string read/write service
```

By default, Pigsty is installed on a **single meta node**. Then the required users and databases for Grafana are created on the existing `pg-meta` database cluster instead of using the `pg-grafana` cluster.


---------------



## Create Biz User

The convention for business object management is to create users first and then create the database.


### Define User

To create a user `dbuser_grafana` on a `pg-meta` cluster, add the following user definition to `pg-meta`'s [cluster definition](#define-cluster).

Add location: `all.children.pg-meta.vars.pg_users`.

```yaml
- name: dbuser_grafana
  password: DBUser.Grafana
  comment: admin user for grafana database
  pgbouncer: true
  roles: [ dbrole_admin ]
```

> If you have defined a different password here, replace the corresponding parameter with the new password.

### Create User

Complete the creation of the `dbuser_grafana` user with the following command.

```bash
bin/createuser pg-meta dbuser_grafana # Create the `dbuser_grafana` user on the pg-meta cluster
```

Calls Ansible Playbook [`pgsql-createuser.yml`](p-pgsql-createuser.md) to create the user

```bash
. /pgsql-createuser.yml -l pg-meta -e pg_user=dbuser_grafana # Ansible
```

The `dbrole_admin` role has the privilege to perform DDL changes in the database, which is precisely what Grafana needs.



---------------

## Create Biz Database

### Define database

Create business databases in the same way as business users. First, add the [definition](#define-cluster) of the new database `grafana` to the cluster definition of `pg-meta`.

Add location: `all.children.pg-meta.vars.pg_databases`.

```yaml
- { name: grafana, owner: dbuser_grafana, revokeconn: true }
```

### Create database

Use the following command to complete the creation of the `grafana` database.

```bash
bin/createdb pg-meta grafana # Create the `grafana` database on the `pg-meta` cluster
```

Calls Ansible Playbook [`pgsql-createdb.yml`](p-pgsql-createdb.md) to create the database.

```bash
. /pgsql-createdb.yml -l pg-meta -e pg_database=grafana # The actual Ansible playbook to execute
```


---------------



## Access Database

### Check Connectivity

You can access the database using different [services](c-service.md) or [access](c-service.md) methods.

```bash
postgres://dbuser_grafana:DBUser.Grafana@meta:5432/grafana # Direct connection
postgres://dbuser_grafana:DBUser.Grafana@meta:5436/grafana # default service
postgres://dbuser_grafana:DBUser.Grafana@meta:5433/grafana # primary service
```

We will use the [default service](c-service.md#default-services) that accesses the database directly from the primary through the LB.

First, check if the connection string is reachable and if you have privileges to execute DDL commands.

```bash
psql postgres://dbuser_grafana:DBUser.Grafana@meta:5436/grafana -c \
  'CREATE TABLE t(); DROP TABLE t;'
```

### Config Grafana

For Grafana to use the Postgres data source, you need to edit `/etc/grafana/grafana.ini` and modify the config entries.


```ini
[database]
;type = sqlite3
;host = 127.0.0.1:3306
;name = grafana
;user = root
# If the password contains # or ; you have to wrap it with triple quotes. Ex """#password;"""
;password =
;url =
```

Change the default config entries.

```ini
[database]
type = postgres
url = postgres://dbuser_grafana:DBUser.Grafana@meta/grafana
```

Subsequently, restart Grafana.

```bash
systemctl restart grafana-server
```

See from the monitor system that the new [`grafana`](http://g.pigsty.cc/d/pgsql-database/pgsql-database?var-cls=pg-meta&var-ins=pg-meta-1&var-datname=grafana&orgId=1) database is already active, then Grafana has started using Postgres as the primary backend database. However, the original Dashboards and Datasources in Grafana have disappeared. You need to re-import [Dashboards](#Manage-Dashboard) and [Postgres Datasources](#Manage-Datasources).




---------------


## Manage Dashboard


You can reload the Pigsty monitor dashboard by going to the ``files/ui`` dir in the Pigsty dir using the admin user and executing ``grafana.py init``.

```bash
cd ~/pigsty/files/ui
. /grafana.py init # Initialize the Grafana monitor dashboard using the Dashboards in the current directory
```

Execution results in:

```bash
vagrant@meta:~/pigsty/files/ui
$ ./grafana.py init
Grafana API: admin:pigsty @ http://10.10.10.10:3000
init dashboard : home.json
init folder pgcat
init dashboard: pgcat / pgcat-table.json
init dashboard: pgcat / pgcat-bloat.json
init dashboard: pgcat / pgcat-query.json
init folder pgsql
init dashboard: pgsql / pgsql-replication.json
init dashboard: pgsql / pgsql-table.json
init dashboard: pgsql / pgsql-activity.json
init dashboard: pgsql / pgsql-cluster.json
init dashboard: pgsql / pgsql-node.json
init dashboard: pgsql / pgsql-database.json
init dashboard: pgsql / pgsql-xacts.json
init dashboard: pgsql / pgsql-overview.json
init dashboard: pgsql / pgsql-session.json
init dashboard: pgsql / pgsql-tables.json
init dashboard: pgsql / pgsql-instance.json
init dashboard: pgsql / pgsql-queries.json
init dashboard: pgsql / pgsql-alert.json
init dashboard: pgsql / pgsql-service.json
init dashboard: pgsql / pgsql-persist.json
init dashboard: pgsql / pgsql-proxy.json
init dashboard: pgsql / pgsql-query.json
init folder pglog
init dashboard: pglog / pglog-instance.json
init dashboard: pglog / pglog-analysis.json
init dashboard: pglog / pglog-session.json
```


This script detects the current environment (defined at `~/pigsty` during installation), gets Grafana access information, and replaces the URL connection placeholder domain name (`*.pigsty`) in the monitor dashboard with the real one in use.

```bash
export GRAFANA_ENDPOINT=http://10.10.10.10:3000
export GRAFANA_USERNAME=admin
export GRAFANA_PASSWORD=pigsty

export NGINX_UPSTREAM_YUMREPO=yum.pigsty
export NGINX_UPSTREAM_CONSUL=c.pigsty
export NGINX_UPSTREAM_PROMETHEUS=p.pigsty
export NGINX_UPSTREAM_ALERTMANAGER=a.pigsty
export NGINX_UPSTREAM_GRAFANA=g.pigsty
export NGINX_UPSTREAM_HAPROXY=h.pigsty
```

As a reminder, using `grafana.py clean` will clear the target monitor dashboard, and using `grafana.py load` will load all the monitor dashboards in the current dir. When Pigsty's monitor dashboard changes, you can use these two commands to upgrade all the monitor dashboards.



---------------


## Manage DataSources

When creating a new PostgreSQL cluster with [`pgsql.yml`](p-pgsql) or a new business database with [`pgsql-createdb.yml`](p-pgsql.md#p-pgsql-createdb), Pigsty will register the new PostgreSQL data source in Grafana, and you can access the target database instance directly through Grafana using the default admin user. Most of the functionality of the application `pgcat` relies on this.

To register a Postgres database, you can use the `register_grafana` task in [`pgsql.yml`](p-pgsql.md).

```bash
./pgsql.yml -t register_grafana # Re-register all Postgres data sources in the current environment
./pgsql.yml -t register_grafana -l pg-test # Re-register all the databases in the pg-test cluster
```




---------------


## Update Grafana Database

You can directly change the backend data source used by Grafana by modifying the Pigsty config file. Edit the [`grafana_database`](v-infra.md#grafana_database) and [`grafana_pgurl`](v-infra.md#grafana_pgurl) parameters in `pigsty.yml` and change them.

```yaml
grafana_database: postgres
grafana_pgurl: postgres://dbuser_grafana:DBUser.Grafana@meta:5436/grafana
```

Then re-execute the `grafana` task in [`infral.yml`](p-infra.md) to complete the Grafana upgrade.

```bash
./infra.yml -t grafana
```

