# PostgreSQL Provisioning

Provisioning, is about creating & pulling-up postgres clusters on node with PG [installed](v-pg-install.md).


## Overview

|                            Name                             |    Type    | Level  | Description |
| :----------------------------------------------------------: | :--------: | :---: | ---- |
|           [pg_cluster](v-pg-provision.md#pg_cluster)           |  `string`  |  **C**  | **PG Cluster Name** |
|               [pg_seq](v-pg-provision.md#pg_seq)               |  `number`  |  **I**  | **PG Instance Sequence** |
|              [pg_role](v-pg-provision.md#pg_role)              |  `enum`  |  **I**  | **PG Instance Role** |
|          [pg_hostname](v-pg-provision.md#pg_hostname)          |  `bool`  |  G/C  | set PG ins name as hostname |
|          [pg_nodename](v-pg-provision.md#pg_nodename)          |  `bool`  |  G/C  | set PG ins name as consul nodename |
|            [pg_exists](v-pg-provision.md#pg_exists)            |  `bool`  |  A  | flag indicate pg exists |
|     [pg_exists_action](v-pg-provision.md#pg_exists_action)     |  `enum`  |  G/A  | how to deal with existing pg ins |
| [pg_disable_purge](v-pg-provision.md#pg_disable_purge)         | `bool`  | G/C/I | disable pg instance purge |
|              [pg_data](v-pg-provision.md#pg_data)              |  `string`  |  G  | pg data dir |
|           [pg_fs_main](v-pg-provision.md#pg_fs_main)           |  `string`  |  G  | pg main data disk mountpoint |
|           [pg_fs_bkup](v-pg-provision.md#pg_fs_bkup)           |  `path`  |  G  | pg backup disk mountpoint |
|            [pg_listen](v-pg-provision.md#pg_listen)            |  `ip`  |  G  | pg listen IP address |
|              [pg_port](v-pg-provision.md#pg_port)              |  `number`  |  G  | pg listen port |
|         [pg_localhost](v-pg-provision.md#pg_localhost)         |  `string`  |  G/C  | pg unix socket path |
|            [pg_upstream](v-pg-provision.md#pg_upstream)        | `string` | I | pg upstream IP address |
|            [pg_backup](v-pg-provision.md#pg_backup)            | `bool`    | I | make base backup on this ins? |
|            [pg_delay](v-pg-provision.md#pg_delay)              | `interval` | I | apply lag for delayed instance |
|         [patroni_mode](v-pg-provision.md#patroni_mode)         |  `enum`  |  G/C  | patroni working mode |
|         [pg_namespace](v-pg-provision.md#pg_namespace)         |  `string`  |  G/C  | namespace for patroni |
|         [patroni_port](v-pg-provision.md#patroni_port)         |  `string`  |  G/C  | patroni listen port (8080) |
| [patroni_watchdog_mode](v-pg-provision.md#patroni_watchdog_mode) |  `enum`  |  G/C  | patroni watchdog policy |
|              [pg_conf](v-pg-provision.md#pg_conf)              |  `enum`  |  G/C  | patroni template |
|   [pg_shared_libraries](v-pg-provision.md#pg_shared_libraries) |  `string`  |  G/C  | default preload shared libraries |
|          [pg_encoding](v-pg-provision.md#pg_encoding)          |  `string`  |  G/C  | character encoding |
|            [pg_locale](v-pg-provision.md#pg_locale)            |  `enum`  |  G/C  | locale |
|        [pg_lc_collate](v-pg-provision.md#pg_lc_collate)        |  `enum`  |  G/C  | collate rule of locale |
|          [pg_lc_ctype](v-pg-provision.md#pg_lc_ctype)          |  `enum`  |  G/C  | ctype of locale |
|       [pgbouncer_port](v-pg-provision.md#pgbouncer_port)       |  `number`  |  G/C  | pgbouncer listen port |
|   [pgbouncer_poolmode](v-pg-provision.md#pgbouncer_poolmode)   |  `enum`  |  G/C  | pgbouncer pooling mode |
| [pgbouncer_max_db_conn](v-pg-provision.md#pgbouncer_max_db_conn) |  `number`  |  G/C  | max connection per database |


## Defaults

```yaml
#------------------------------------------------------------------------------
# POSTGRES PROVISION
#------------------------------------------------------------------------------
# - identity - #
# pg_cluster:                                 # [REQUIRED] cluster name (cluster level,  validated during pg_preflight)
# pg_seq: 0                                   # [REQUIRED] instance seq (instance level, validated during pg_preflight)
# pg_role: replica                            # [REQUIRED] service role (instance level, validated during pg_preflight)
# pg_shard:                                   # [OPTIONAL] shard name  (cluster level)
# pg_sindex:                                  # [OPTIONAl] shard index (cluster level)

# - identity option -#
pg_hostname: false                            # overwrite node hostname with pg instance name
pg_nodename: true                             # overwrite consul nodename with pg instance name

# - retention - #
# pg_exists_action, available options: abort|clean|skip
#  - abort: abort entire play's execution (default)
#  - clean: remove existing cluster (dangerous)
#  - skip: end current play for this host
# pg_exists: false                            # auxiliary flag variable (DO NOT SET THIS)
pg_exists_action: abort                       # what to do when found running postgres instance ? (clean are JUST FOR DEMO! do not use this on production)
pg_disable_purge: false                       # set to true to disable pg purge functionality for good (force pg_exists_action = abort)

# - storage - #
pg_data: /pg/data                             # postgres data directory (soft link)
pg_fs_main: /data                             # primary data disk mount point   /pg   -> {{ pg_fs_main }}/postgres/{{ pg_instance }}
pg_fs_bkup: /data/backups                     # backup disk mount point         /pg/* -> {{ pg_fs_bkup }}/postgres/{{ pg_instance }}/*

# - connection - #
pg_listen: '0.0.0.0'                          # postgres listen address, '0.0.0.0' (all ipv4 addr) by default
pg_port: 5432                                 # postgres port, 5432 by default
pg_localhost: /var/run/postgresql             # localhost unix socket dir for connection
# pg_upstream:                                # [OPTIONAL] specify replication upstream, instance level
# Set on primary instance will transform this cluster into a standby cluster
# - patroni - #
# patroni_mode, available options: default|pause|remove
#   - default: default ha mode
#   - pause:   into maintenance mode
#   - remove:  remove patroni after bootstrap
patroni_mode: default                         # pause|default|remove
pg_namespace: /pg                             # top level key namespace in dcs
patroni_port: 8008                            # default patroni port
patroni_watchdog_mode: automatic              # watchdog mode: off|automatic|required

pg_conf: tiny.yml                             # pgsql template:  {oltp|olap|crit|tiny}.yml , use tiny for sandbox
# use oltp|olap|crit for production, or fork your own templates (in ansible templates dir)
# extension shared libraries to be added
pg_shared_libraries: 'timescaledb, pg_stat_statements, auto_explain'

# - flags - #
pg_backup: false                              # store base backup on this node          (instance level, TBD)
pg_delay: 0                                   # apply delay for offline|delayed replica (instance level, TBD)

# - localization - #
pg_encoding: UTF8                             # database cluster encoding, UTF8 by default
pg_locale: C                                  # database cluster local, C by default
pg_lc_collate: C                              # database cluster collate, C by default
pg_lc_ctype: en_US.UTF8                       # database character type, en_US.UTF8 by default (for i18n full-text search)

# - pgbouncer - #
pgbouncer_port: 6432                          # pgbouncer port, 6432 by default
pgbouncer_poolmode: transaction               # pooling mode: session|transaction|statement, transaction pooling by default
pgbouncer_max_db_conn: 100                    # max connection to single database, DO NOT set this larger than postgres max conn or db connlimit
```





## Identity Parameters

|           名称            |   类型   | 层级  | 说明                            |
| :-----------------------: | :------: | :---: | ------------------------------- |
| [pg_cluster](#pg_cluster) | `string` | **C** | **PG Cluster Name**            |
|     [pg_seq](#pg_seq)     | `number` | **I** | **PG Instance Serial**            |
|    [pg_role](#pg_role)    |  `enum`  | **I** | **PG Instance Role**            |
|   [pg_shard](#pg_shard)   | `string` | **C** | **PG Sharding Name** (TODO) |
|  [pg_sindex](#pg_sindex)  | `number` | **C** | **PG Sharding Index** (TODO) |

`pg_cluster`， `pg_role`， `pg_seq` are **identity parameters** .

They are a minimal set of parameters for defining a new postgres cluster. They MUST be explicitly set.

* `pg_cluster` identifies the name of the cluster and is configured at the cluster level.
* `pg_role` identifies the role of the instance, configured at the instance level. Only the `primary` role will be handled specially, if left unfilled, the default is the `replica` role, in addition to the special `delayed` and `offline` roles.
* `pg_seq` is used to identify the instance within the cluster, usually as an integer incrementing from 0 or 1, and will not be changed once assigned.
* `{{ pg_cluster }}-{{ pg_seq }}` is used to uniquely identify the instance, i.e. `pg_instance`
* `{{ pg_cluster }}-{{ pg_role }}` is used to identify the services within the cluster, i.e. `pg_service`

```yaml
pg-test:
  hosts:
    10.10.10.11: {pg_seq: 1, pg_role: replica}
    10.10.10.12: {pg_seq: 2, pg_role: primary}
    10.10.10.13: {pg_seq: 3, pg_role: replica}
  vars:
    pg_cluster: pg-test
```

`pg_shard` 与 `pg_sindex` is reserved for horizontal sharding clusters. for future support for citus.



## Details

### pg_cluster         

The name of the PG database cluster will be used as the namespace for the resources within the cluster.

Cluster naming needs to follow specific naming rules: `[a-z][a-z0-9-]*` to be compatible with different constraints on identity identification.

**Identity parameters, required parameters, cluster-level parameters**



### pg_seq

Serial number of the database instance, unique within the **cluster**, used to distinguish and identify different instances within the cluster, assigned starting from 0 or 1.

**identity parameter, required parameter, instance-level parameter**



### pg_role

Role of the database instance, default roles include: `primary`, `replica`.

Subsequent optional roles include: `offline` and `delayed`.

**identity parameters, required parameters, instance-level parameters**



### pg_shard

Only sharded clusters require this parameter to be set.

When multiple database clusters serve the same business in a horizontally sharded fashion, Pigsty refers to this group of clusters as a **Sharding Cluster**. A sharding cluster can be assigned any name, but Pigsty recommends a meaningful naming convention.

For example, for a cluster participating in a shard cluster, you can use the shard cluster name [`pg_shard`](#pg_shard) + `shard` + the shard number [`pg_sindex`](#pg_sindex) of the cluster to which the cluster belongs to form the cluster name.

```
shard: test
pg-testshard1
pg-testshard2
pg-testshard3
pg-testshard4
```

**identity parameters, optional parameters, cluster-level parameters**



### pg_sindex

The number of the cluster in the sharded cluster, usually assigned sequentially starting from 0 or 1.

Only sharded clusters require this parameter to be set.

**Identity parameters, optional parameters, cluster-level parameters**



### pg_hostname

Whether to register the name of the PG instance `pg_instance` as a hostname, disabled by default.



### pg_nodename

Whether to register the name of the PG instance as a node name in Consul, enabled by default.



### pg_exists

Flag bit for whether the PG instance exists, not configurable.



### pg_exists_action

Security insurance, action the system should perform when a PostgreSQL instance already exists

* abort: Abort the execution of the entire script (default behavior)
* clean: wipe the existing instance and continue (extremely dangerous)
* skip: ignore the target of the existing instance (abort) and continue execution on the other target machine.

If you really need to force wipe an existing database instance, it is recommended to use `pgsql-rm.yml` to finish offline and destroy the cluster and instance first, before re-executing the initialization. Otherwise, you need to complete the overwrite with the command line parameter `-e pg_exists_action=clean` to force the wiping of existing instances during the initialization process.



### pg_disable_purge

Double safety, default is `false`. If `true`, forces the `pg_exists_action` variable to be set to `abort`.

Equivalent to turning off the purge feature for `pg_exists_action`, ensuring that Postgres instances are not wiped out under any circumstances.

This means that you will need to complete the cleanup of existing instances with the dedicated offline script `pgsql-rm.yml` before you can re-initialize the database on a cleaned node.



### pg_data

Default data directory, default is `/pg/data`



### pg_fs_main

Main data disk directory, defaults to `/export`

Pigsty's default [directory structure] (/zh/docs/concepts/provision/fhs/) assumes that there is a master data disk mount point on the system to hold the database directory.



### pg_fs_bkup

Archive and backup disk directory, default is `/var/backups`

Pigsty's default [directory structure] (/zh/docs/concepts/provision/fhs/) assumes that there is a backup data disk mount point on the system for backup and archive data. The backup disk is not mandatory. If the backup disk does not exist on the system, the user can also specify a subdirectory on the primary data disk as the backup disk root mount point.



### pg_listen

The IP address that the database listens to, default is all IPv4 addresses `0.0.0.0`, if you want to include all IPv6 addresses, you can use `*`.



### pg_port

The port that the database listens on, the default port is `5432`, it is not recommended to modify it.



### pg_localhost

Unix socket directory to hold PostgreSQL and Pgbouncer's Unix socket files.

The default is `/var/run/postgresql`.



### pg_upstream

Instance-level configuration item with an IP address or hostname to indicate the upstream node for stream replication.

When configuring this parameter for a slave of the cluster, the IP address filled in must be another node within the cluster. Instances will be stream replicated from this node, and this option can be used to build **level concatenated replication**.

When configuring this parameter for the master of the cluster, it means that the entire cluster will run as a **Standby Cluster**, receiving changes from the upstream node. The `primary` in the cluster will play the role of `standby leader`.



### pg_backup

tag, instance-level configuration item, instances with this tag will be used to store base backups (not implemented, keep the tag bit)



### pg_delay

If the instance is a delayed slave, the delay duration used. (not implemented, keep the tag bit)

Use the time interval string format accepted by PG, such as `1h`, `30min`, etc.



### patroni_mode

Patroni's operating modes.
* `default`: enable Patroni
* `pause`: enables Patroni, but automatically enters maintenance mode after initialization (does not automatically perform master-slave switchover)
* `remove`: still uses Patroni to initialize the cluster, but removes Patroni after initialization is complete



### pg_namespace

KV storage top-level namespace used by Patroni in DCS

Default is `pg`



### patroni_port

The default port that the Patroni API server listens on

The default port is `8008`



### patroni_watchdog_mode

When a master-slave switch occurs, Patroni will try to shut down the master before elevating the slave. If the master is still not successfully shut down within the specified timeout period, Patroni will fencing shutdown using the Linux kernel feature softdog according to the configuration.

* `off`: do not use `watchdog`
* `automatic`: enable `watchdog` if the kernel has `softdog` enabled, not mandatory, default behavior.
* `required`: force `watchdog`, refuse to start if `softdog` is not enabled on the system.



### pg_conf

Patroni templates used to pull up Postgres clusters. pigsty has 4 pre-built templates

* [`oltp.yml`](#oltp) Regular OLTP template, default configuration
* [`olap.yml`](#olap) OLAP template, improves parallelism, optimized for throughput, optimized for long-running queries.
* [`crit.yml`](#crit)) Core business template, based on OLTP templates optimized for security, data integrity, using synchronous replication, forcing data checksums to be enabled.
* [`tiny.yml`](#tiny) Micro database template optimized for low resource scenarios, such as demo database clusters running in virtual machines.


### pg_shared_libraries

Fills in the string of the `shared_preload_libraries` parameter in the Patroni template, controlling the dynamic libraries preloaded by PG startup.

In the current version, the following libraries are loaded by default: `citus, timescaledb, pg_stat_statements, auto_explain`


### pg_encoding

The character set encoding to use when the PostgreSQL instance is initialized.

The default is `UTF8`, and it is not recommended to change this parameter if there is no special need.



### pg_locale

The localization rule to be used when initializing the PostgreSQL instance.

Default is `C`, it is not recommended to modify this parameter if there is no special need.



### pg_lc_collate

The localization rule to be used when initializing a PostgreSQL instance.

Defaults to `C`, and it is **strongly discouraged** to modify this parameter if there is no special need. Users can always implement localization sorting related functions with `COLLATE` expressions, wrong localization sorting rules may cause exponential performance loss for some operations, please modify this parameter if there is a real localization need.



### pg_lc_ctype

Definition of the localized character set to be used when the PostgreSQL instance is initialized

The default is `en_US.UTF8`, because some PG extensions (`pg_trgm`) require additional character set definitions to work properly for internationalized characters, so Pigsty will use the `en_US.UTF8` character set definition by default, and it is not recommended to modify this parameter.



### pgbouncer_port

The default port that the Pgbouncer connection pool listens on

Default is `6432`



### pgbouncer_poolmode

The default Pool mode used by the Pgbouncer connection pool

The default is `transaction`, which is a transaction-level connection pool. Other options available include: `session|statemente`



### pgbouncer_max_db_conn

Maximum number of connections allowed to be established between the connection pool and a single database

The default value is `100`

When using transaction Pooling mode, the number of active server-side connections is usually in the single digits. If session Pooling is used, this parameter can be increased appropriately.