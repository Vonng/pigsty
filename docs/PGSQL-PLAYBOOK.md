# PostgreSQL Playbook

> Pigsty has a series of playbooks for PostgreSQL

- [`pgsql.yml`](#pgsqlyml) : Init HA PostgreSQL clusters or add new replicas.
- [`pgsql-rm.yml`](#pgsql-rmyml) : Remove PostgreSQL cluster, or remove replicas
- [`pgsql-user.yml`](#pgsql-useryml) : Add new business user to existing PostgreSQL cluster
- [`pgsql-db.yml`](#pgsql-dbyml) : Add new business database to existing PostgreSQL cluster
- [`pgsql-monitor.yml`](#pgsql-monitoryml) : Monitor remote PostgreSQL instance with local exporters
- [`pgsql-migration.yml`](#pgsql-migrationyml) : Generate Migration manual & scripts for existing PostgreSQL

----------------

### Safeguard

Beware, when using the [`pgsql.yml`](#pgsqlyml) and [`pgsql-rm.yml`](#pgsql-rmyml) playbooks, it can pose a risk of accidentally deleting databases if misused!

- When using `pgsql.yml`, please check the `--tags|-t` and `--limit|-l` parameters.
- Adding the -l parameter when executing playbooks is strongly recommended to limit execution hosts.
- Think thrice before proceeding.

To prevent accidental deletions, the [PGSQL](#PGSQL) module offers a safeguard option controlled by the following two parameters:

- [`pg_safeguard`](PARAM#pg_safeguard) is set to `false` by default: do not prevent purging by default.
- [`pg_clean`](PARAM#pg_clean) is set to `true` by default, meaning it will clean existing instances.

**Effects on the init playbook**

When meeting a running instance with the same config during the execution of the [`pgsql.yml`](#pgsqlyml) playbook:

| `pg_safeguard` / `pg_clean` | `pg_clean=true` | `pg_clean=false` |
|:---------------------------:|:---------------:|:----------------:|
|    `pg_safeguard=false`     |    **Purge**     |       Abort       |
|     `pg_safeguard=true`     |      Abort       |       Abort       |

* If [`pg_safeguard`](PARAM#pg_safeguard) is enabled, the playbook will abort to avoid purging the running instance.
* If the safeguard is disabled, it will further decide whether to remove the existing instance according to the value of [`pg_clean`](PARAM#pg_clean).
  * If `pg_clean` is `true`, the playbook will directly clean up the existing instance to make room for the new instance. This is the default behavior.
  * If `pg_clean` is `false`, the playbook will abort, which requires explicit configuration.

**Effects on the remove playbook**

 When meeting a running instance with the same config during the execution of the [`pgsql-rm.yml`](#pgsql-rmyml) playbook:

| `pg_safeguard` / `pg_clean` | `pg_clean=true` | `pg_clean=false` |
|:---------------------------:|:---------------:|:----------------:|
|    `pg_safeguard=false`     |   **Purge** & rm data   |     **Purge**     |
|     `pg_safeguard=true`     |      Abort       |       Abort       |

* If [`pg_safeguard`](PARAM#pg_safeguard) is enabled, the playbook will abort to avoid purging the running instance.
* If the safeguard is disabled, it purges the running instance and will further decide whether to remove the existing data along with the instance according to the value of [`pg_clean`](PARAM#pg_clean).
  * If `pg_clean` is `true`, the playbook will directly clean up the PostgreSQL data cluster.
  * If `pg_clean` is `false`, the playbook will skip data purging, which requires explicit configuration.



----------------

## `pgsql.yml`

The [`pgsql.yml`](https://github.com/vonng/pigsty/blob/master/pgsql.yml) is used for init HA PostgreSQL clusters or adding new replicas.

[![asciicast](https://asciinema.org/a/566417.svg)](https://asciinema.org/a/566417)

**This playbook contains following subtasks**:

```yaml
# pg_clean      : cleanup existing postgres if necessary
# pg_dbsu       : setup os user sudo for postgres dbsu
# pg_install    : install postgres packages & extensions
#   - pg_pkg              : install postgres related packages
#   - pg_extension        : install postgres extensions only
#   - pg_path             : link pgsql version bin to /usr/pgsql
#   - pg_env              : add pgsql bin to system path
# pg_dir        : create postgres directories and setup fhs
# pg_util       : copy utils scripts, setup alias and env
#   - pg_bin              : sync postgres util scripts /pg/bin
#   - pg_alias            : write /etc/profile.d/pg-alias.sh
#   - pg_psql             : create psqlrc file for psql
#   - pg_dummy            : create dummy placeholder file
# patroni       : bootstrap postgres with patroni
#   - pg_config           : generate postgres config
#     - pg_conf           : generate patroni config
#     - pg_systemd        : generate patroni systemd config
#     - pgbackrest_config : generate pgbackrest config
#   -  pg_cert            : issues certificates for postgres
#   -  pg_launch          : launch postgres primary & replicas
#     - pg_watchdog       : grant watchdog permission to postgres
#     - pg_primary        : launch patroni/postgres primary
#     - pg_init           : init pg cluster with roles/templates
#     - pg_pass           : write .pgpass file to pg home
#     - pg_replica        : launch patroni/postgres replicas
#     - pg_hba            : generate pg HBA rules
#     - patroni_reload    : reload patroni config
#     - pg_patroni        : pause or remove patroni if necessary
# pg_user       : provision postgres business users
#   - pg_user_config      : render create user sql
#   - pg_user_create      : create user on postgres
# pg_db         : provision postgres business databases
#   - pg_db_config        : render create database sql
#   - pg_db_create        : create database on postgres
# pg_backup               : init pgbackrest repo & basebackup
#   - pgbackrest_init     : init pgbackrest repo
#   - pgbackrest_backup   : make a initial backup after bootstrap
# pgbouncer     : deploy a pgbouncer sidecar with postgres
#   - pgbouncer_clean     : cleanup existing pgbouncer
#   - pgbouncer_dir       : create pgbouncer directories
#   - pgbouncer_config    : generate pgbouncer config
#     -  pgbouncer_svc    : generate pgbouncer systemd config
#     -  pgbouncer_ini    : generate pgbouncer main config
#     -  pgbouncer_hba    : generate pgbouncer hba config
#     -  pgbouncer_db     : generate pgbouncer database config
#     -  pgbouncer_user   : generate pgbouncer user config
#   -  pgbouncer_launch   : launch pgbouncer pooling service
#   -  pgbouncer_reload   : reload pgbouncer config
# pg_vip        : bind vip to pgsql primary with vip-manager
#   - pg_vip_config       : generate config for vip-manager
#   - pg_vip_launch       : launch vip-manager to bind vip
# pg_dns        : register dns name to infra dnsmasq
#   - pg_dns_ins          : register pg instance name
#   - pg_dns_cls          : register pg cluster name
# pg_service    : expose pgsql service with haproxy
#   - pg_service_config   : generate local haproxy config for pg services
#   - pg_service_reload   : expose postgres services with haproxy
# pg_exporter   : expose pgsql service with haproxy
#   - pg_exporter_config  : config pg_exporter & pgbouncer_exporter
#   - pg_exporter_launch  : launch pg_exporter
#   - pgbouncer_exporter_launch : launch pgbouncer exporter
# pg_register   : register postgres to pigsty infrastructure
#   - register_prometheus : register pg as prometheus monitor targets
#   - register_grafana    : register pg database as grafana datasource
```

**Administration Tasks that use this playbook**

- [`Create Cluster`](PGSQL-ADMIN#create-cluster)
- [`Append Replica`](PGSQL-ADMIN#append-replica)
- [`Reload Service`](PGSQL-ADMIN#reload-service)
- [`Reload HBARule`](PGSQL-ADMIN#reload-hbarule)

**Some notes about this playbook**

When running this playbook on a single replica, You should make sure the cluster primary is already initialized.
* you may have to run [`Reload HBARule`](PGSQL-ADMIN#reload-hbarule) and  [`Append Replica`](PGSQL-ADMIN#append-replica) after replica init.
* The wrap script `pgsql-add` will do this, check SOP: [Add Instance](PGSQL-ADMIN#add-instance) for details.



----------------

## `pgsql-rm.yml`

The playbook [`pgsql-rm.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-rm.yml) can remove PostgreSQL cluster, or specific replicas from cluster.

[![asciicast](https://asciinema.org/a/566418.svg)](https://asciinema.org/a/566418)

**This playbook contains following subtasks**:


```yaml
# register       : remove registration in prometheus, grafana, nginx
#   - prometheus : remove monitor target from prometheus
#   - grafana    : remove datasource from grafana
# dns            : remove pg dns records
# vip            : remove pg vip manager
# pg_service     : remove service definition from haproxy
# pg_exporter    : remove pg_exporter & pgbouncer_exporter
# pgbouncer      : remove pgbouncer connection middleware
# postgres       : remove postgres instances
#   - pg_replica : remove all replicas
#   - pg_primary : remove primary instance
#   - dcs        : remove metadata from dcs
# pg_data        : remove postgres data (disable with `pg_clean=false`),
# pgbackrest     : remove postgres backup when removing primary (disable with `pgbackrest_clean=false`),
# pg_pkg         : remove postgres packages (enable with `pg_uninstall=true`)
```

本剧本可以使用一些命令行参数影响其行为：

```bash
# remove pgsql cluster `pg-test`
   pgsql-rm.yml -l pg-test       # remove cluster `pg-test`
       -e pg_clean=true          # remove postgres data by default
       -e pgbackrest_clean=true  # remove postgres backup by default (when removing primary)
       -e pg_uninstall=false     # do not uninstall pg packages by default, explicit override required
       -e pg_safeguard=false     # purge safeguard is not enabled by default, explicit override required
```

**Administration Tasks that use this playbook**

- [`Remove Replica`](PGSQL-ADMIN#remove-replica)
- [`Remove Cluster`](PGSQL-ADMIN#remove-cluster)

**Some notes about this playbook**

Do not run this playbook on single cluster primary directly when there are still replicas.
* otherwise the rest replicas will trigger automatic failover.
* It won't be a problem if you remove all replicas before removing primary.
* If you run this on the entire cluster, you don't have to worry about this.

Reload service after removing replicas from cluster
* When a replica is removed, it is still in the configuration file of the haproxy load balancer.
* It is a dead server so it won't affect the cluster service.
* But you should [reload service](PGSQL-ADMIN#reload-service) in time to ensure the consistency between the environment and the config inventory.



----------------

## `pgsql-user.yml`

The playbook [`pgsql-user.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-user.yml) can add new business user to existing PostgreSQL cluster.

Check admin SOP: [`Create User`](PGSQL-ADMIN#create-user)

----------------

## `pgsql-db.yml`

The playbook [`pgsql-db.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-db.yml) can add new business database to existing PostgreSQL cluster.

Check admin SOP: [`Create Database`](PGSQL-ADMIN#create-database)

----------------

## `pgsql-monitor.yml`

The playbook [`pgsql-monitor.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-monitor.yml) can monitor remote postgres instance with local exporters.

Check admin SOP: [`Monitor Postgres`](PGSQL-MONITOR#remote-postgres)



----------------

## `pgsql-migration.yml`

The playbook [`pgsql-migration.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-migration.yml) can generate migration manual & scripts for existing PostgreSQL cluster.

Check admin SOP: [Migration](PGSQL-MIGRATION)
