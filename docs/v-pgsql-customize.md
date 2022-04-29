# Customize: PGSQL

> The [Patroni template](#Patorni-templates) is used to customize the **specification config** of the PostgreSQL cluster, while the [Postgres template](#Postgres-templates) is used to customize the **content** of the PostgreSQL cluster.

Pigsty provides nearly 100 parameters on [PGSQL](v-pgsql.md) describing the PostgreSQL cluster.

However, if you are deeply customizing the database cluster created by Pigsty, you can see the [Patroni template](#Patroni-templates) and [Postgres template](#Postgres-templates).



## Patroni Templates

Pigsty uses [Patroni](https://github.com/zalando/patroni) to manage and initialize Postgres clusters.
If you wish to modify the default config params, specifications and tuning schemes, high availability policies, DCS access, and control APIs of the PostgreSQL cluster, you can do so by modifying the Patroni template.

Pigsty uses Patroni to do the main work of provisioning, even if the user selects [no Patroni mode](v-pgsql.md#patroni_mode), pulling up the database cluster will be taken care of by Patroni, and removing the Patroni component after the creation is completed.
Users can do most of the PostgreSQL cluster customization through the Patroni config file. Please refer to [**Patroni's official doc**](https://patroni.readthedocs.io/en/latest/SETTINGS.) for details of the Patroni config file format. 


### Predefined Patroni templates

Pigsty provides several predefined initialization templates for initializing the cluster definition files, located by default in [`roles/postgres/templates/`](https://github.com/Vonng/pigsty/tree/master/roles/postgres/templates). Including:


|     Conf     | CPU  |  Mem  | Disk  | Description |
| :--------------: | :--: | :---: | :---: | ----- |
|     [`oltp`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/oltp.yml)           |  64  | 400GB |  4TB  |  Production OLTP template, default config, optimized latency and performance for production models.  |
|     [`olap`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/olap.yml)           |  64  | 400GB |  4TB  |  Produce OLAP templates, improve parallelism, optimize for throughput, long queries.  |
|     [`crit`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/crit.yml)           |  64  | 400GB |  4TB  |  Production core business templates, based on OLTP templates optimized for RPO, security, and data integrity, with synchronous replication and data checksum, enabled.  |
|     [`tiny`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/tiny.yml)      |  1   |  1GB  | 40GB  | Micro templates optimized for low-resource scenarios, such as demo clusters running in virtual machines. |
|     [`mini`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/mini.yml)      |  2   |  4GB  | 100GB | 2C4G model OLTP template |
|     [`small`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/small.yml)      |  4   |  8GB  | 200GB | 4C8G model OLTP template |
|     [`medium`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/medium.yml)     |  8   | 16GB  | 500GB | 8C16G model OLTP template |
|     [`large`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/large.yml)      |  16  | 32GB  |  1TB  |  16C32G model OLTP template  |
|     [`xlarge`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/xlarge.yml)     |  32  | 64GB  |  2TB  |  32C64G model OLTP template  |


Specify the path to the template to be used via the [`pg_conf`](v-pgsql.md#pg_conf), or simply fill in the template name if using a pre-built template. If a custom [Patroni config template](v-pgsql.md#pg_conf) is used, the companion [node optimization template](v-nodes.md#node_tune) should usually be used for the machine nodes as well.

```yaml
pg_conf:   tiny.yml      # Using tiny.yml to tune templates
node_tune: tiny          # Node Tuning Mode：oltp|olap|crit|tiny
```

During the installation of Pigsty for Configure, Pigsty detects the corresponding default specifications that are automatically selected based on the specifications of the current machine (meta machine).



## Custom Patroni templates

When customizing Patroni templates, you can use several existing templates as a baseline from which to make changes.

Place them in the [`templates/`](https://github.com/Vonng/pigsty/tree/master/roles/postgres/templates) dir, just name them in `<mode>.yml` format.

Please keep the template variables in Patroni, otherwise, the related parameters may not work properly. For example [`pg_libs`](v-pgsql.md#pg_libs).

Finally, in the [`pg_conf`](v-pgsql.md#pg_conf) config file, specify the name of your newly created template, e.g. `olap-32C128G-nvme.yml`.

## Postgres templates

The template `template1` in the cluster can be customized using the [PG template](v-pgsql.md) config entry, and thus.

In this way ensure that any database **newly created** in that cluster comes with the same default config: schema, extensions, and default permissions.


### Related docs

When customizing a template, the relevant parameters are first rendered as SQL scripts to be executed on the deployed cluster.


```ini
^---/pg/bin/pg-init
          |
          ^---(1)--- /pg/tmp/pg-init-roles.sql
          ^---(2)--- /pg/tmp/pg-init-template.sql
          ^---(3)--- <other customize logic in pg-init>

# Business users and DB are not created in the template customization, but are listed here.
^-------------(4)--- /pg/tmp/pg-user-{{ user.name }}.sql
^-------------(5)--- /pg/tmp/pg-db-{{ db.name }}.sql
```

## `pg-init`

[`pg-init`](v-pgsql.md#pg_init) is the path to a Shell script for customizing the initialization template that will be executed as a Postgres user, **only on the master**, with the cluster master pulled up at the time of execution, and can execute any shell command, or any SQL command via psql.

If this config entry is not specified, Pigsty will use the default [`pg-init`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/pg-init) shell script, as shown below:

```shell
#!/usr/bin/env bash
set -uo pipefail


#==================================================================#
#                          Default Roles                           #
#==================================================================#
psql postgres -qAXwtf /pg/tmp/pg-init-roles.sql


#==================================================================#
#                          System Template                         #
#==================================================================#
# system default template
psql template1 -qAXwtf /pg/tmp/pg-init-template.sql

# make postgres same as templated database (optional)
psql postgres  -qAXwtf /pg/tmp/pg-init-template.sql



#==================================================================#
#                          Customize Logic                         #
#==================================================================#
# add your template logic here
```

This script can be appended if the user needs to perform complex customization logic. Note `pg-init` is used to customize **database clusters**, which is usually achieved by modifying **database templates**. At the time this script is executed, the cluster has been started, but the business users and DB have not yet been created. Therefore the changes to the database templates are reflected in the business database defined by default.

