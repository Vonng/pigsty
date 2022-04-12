# Config: PGSQL

> Use the [PGSQL Playbook](p-pgsql.md), [l-deployPGSQL](d-pgsql.md) cluster to adjust the cluster state to the state described in the [ PGSQL config](v-pgsql.md).

You need to express the database requirements to pigsty through config. Pigsty provides 100+ parameters for a complete description of a PostgreSQL cluster. However, users usually only need to care about individual parameters in [identity parameters](#PG_IDENTITY) and [business objects](#PG_BUSINESS): the former expresses the database cluster "Who is it? Where is it?" and the latter expresses the database "What does it look like? What's in it?".

The parameters on the PostgreSQL are divided into seven main sections：

- [`PG_IDENTITY`](#PG_IDENTITY)  Defining the identity of a PostgreSQL database cluster.
- [`PG_BUSINESS`](#PG_BUSINESS) :Customized cluster templates: users, databases, services, permission rules.
- [`PG_INSTALL`](#PG_INSTALL) : Install PostgreSQL pkgs, exteand nsion plugins, prepare directory structure and tool scripts.
- [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) : Generate config template, pull up PostgreSQL cluster, build master-slave replication, enable connection pooling.
- [`PG_PROVISION`](#PG_PROVISION) : PGSQL cluster template provisioning, creating users and databases, configuring permissions role HBA, schema and extensions.
- [`PG_EXPORTER`](#PG_EXPORTER) : PGSQL metrics exposer, database and connection pool config  monitoring component.
- [`PG_SERVICE`](#PG_SERVICE) : Expose the PostgreSQL service externally, install the load balancer HAProxy, enable VIP, and configure DNS.


| ID  |                              Name                               |             Section             |    Type     | Level |              Comment              |
|-----|-----------------------------------------------------------------|---------------------------------|-------------|-------|------------------------------------|
| 500 | [`pg_cluster`](#pg_cluster)                                     | [`PG_IDENTITY`](#PG_IDENTITY)   | string      | C     | PG Cluster Name|
| 501 | [`pg_shard`](#pg_shard)                                         | [`PG_IDENTITY`](#PG_IDENTITY)   | string      | C     | PG Shard Name (Reserve)|
| 502 | [`pg_sindex`](#pg_sindex)                                       | [`PG_IDENTITY`](#PG_IDENTITY)   | int         | C     | PG Shard Index (Reserve)|
| 503 | [`gp_role`](#gp_role)                                           | [`PG_IDENTITY`](#PG_IDENTITY)   | enum        | C     | gp role of this PG cluster |
| 504 | [`pg_role`](#pg_role)                                           | [`PG_IDENTITY`](#PG_IDENTITY)   | enum        | I     | PG Instance Role|
| 505 | [`pg_seq`](#pg_seq)                                             | [`PG_IDENTITY`](#PG_IDENTITY)   | int         | I     | PG Instance Sequence|
| 506 | [`pg_instances`](#pg_instances)                                 | [`PG_IDENTITY`](#PG_IDENTITY)   | {port:ins}  | I     | PG instance on this node |
| 507 | [`pg_upstream`](#pg_upstream)                                   | [`PG_IDENTITY`](#PG_IDENTITY)   | string      | I     | PG upstream IP address |
| 508 | [`pg_offline_query`](#pg_offline_query)                         | [`PG_IDENTITY`](#PG_IDENTITY)   | bool        | I     | allow offline query?|
| 509 | [`pg_backup`](#pg_backup)                                       | [`PG_IDENTITY`](#PG_IDENTITY)   | bool        | I     | make base backup on this ins?|
| 510 | [`pg_weight`](#pg_weight)                                       | [`PG_IDENTITY`](#PG_IDENTITY)   | int         | I     | relative weight in load balancer|
| 511 | [`pg_hostname`](#pg_hostname)                                   | [`PG_IDENTITY`](#PG_IDENTITY)   | bool        | C/I   | set PG ins name as hostname|
| 512 | [`pg_preflight_skip`](#pg_preflight_skip)                       | [`PG_IDENTITY`](#PG_IDENTITY)   | bool        | C/A   | skip preflight param validation|
| 520 | [`pg_users`](#pg_users)                                         | [`PG_BUSINESS`](#PG_BUSINESS)   | user[]      | C     | business users definition|
| 521 | [`pg_databases`](#pg_databases)                                 | [`PG_BUSINESS`](#PG_BUSINESS)   | database[]  | C     | business databases definition|
| 522 | [`pg_services_extra`](#pg_services_extra)                       | [`PG_BUSINESS`](#PG_BUSINESS)   | service[]   | C     | ad hoc service definition|
| 523 | [`pg_hba_rules_extra`](#pg_hba_rules_extra)                     | [`PG_BUSINESS`](#PG_BUSINESS)   | rule[]      | C     | ad hoc HBA rules|
| 524 | [`pgbouncer_hba_rules_extra`](#pgbouncer_hba_rules_extra)       | [`PG_BUSINESS`](#PG_BUSINESS)   | rule[]      | C     | ad hoc pgbouncer HBA rules|
| 525 | [`pg_admin_username`](#pg_admin_username)                       | [`PG_BUSINESS`](#PG_BUSINESS)   | string      | G     | admin user's name|
| 526 | [`pg_admin_password`](#pg_admin_password)                       | [`PG_BUSINESS`](#PG_BUSINESS)   | string      | G     | admin user's password|
| 527 | [`pg_replication_username`](#pg_replication_username)           | [`PG_BUSINESS`](#PG_BUSINESS)   | string      | G     | replication user's name|
| 528 | [`pg_replication_password`](#pg_replication_password)           | [`PG_BUSINESS`](#PG_BUSINESS)   | string      | G     | replication user's password|
| 529 | [`pg_monitor_username`](#pg_monitor_username)                   | [`PG_BUSINESS`](#PG_BUSINESS)   | string      | G     | monitor user's name|
| 530 | [`pg_monitor_password`](#pg_monitor_password)                   | [`PG_BUSINESS`](#PG_BUSINESS)   | string      | G     | monitor user's password|
| 540 | [`pg_dbsu`](#pg_dbsu)                                           | [`PG_INSTALL`](#PG_INSTALL)     | string      | C     | os dbsu for postgres|
| 541 | [`pg_dbsu_uid`](#pg_dbsu_uid)                                   | [`PG_INSTALL`](#PG_INSTALL)     | int         | C     | dbsu UID|
| 542 | [`pg_dbsu_sudo`](#pg_dbsu_sudo)                                 | [`PG_INSTALL`](#PG_INSTALL)     | enum        | C     | sudo priv mode for dbsu|
| 543 | [`pg_dbsu_home`](#pg_dbsu_home)                                 | [`PG_INSTALL`](#PG_INSTALL)     | path        | C     | home dir for dbsu|
| 544 | [`pg_dbsu_ssh_exchange`](#pg_dbsu_ssh_exchange)                 | [`PG_INSTALL`](#PG_INSTALL)     | bool        | C     | exchange dbsu ssh keys?|
| 545 | [`pg_version`](#pg_version)                                     | [`PG_INSTALL`](#PG_INSTALL)     | int         | C     | major PG version to be installed|
| 546 | [`pgdg_repo`](#pgdg_repo)                                       | [`PG_INSTALL`](#PG_INSTALL)     | bool        | C     | add official PGDG repo?|
| 547 | [`pg_add_repo`](#pg_add_repo)                                   | [`PG_INSTALL`](#PG_INSTALL)     | bool        | C     | add extra upstream PG repo?|
| 548 | [`pg_bin_dir`](#pg_bin_dir)                                     | [`PG_INSTALL`](#PG_INSTALL)     | path        | C     | PG binary dir|
| 549 | [`pg_packages`](#pg_packages)                                   | [`PG_INSTALL`](#PG_INSTALL)     | string[]    | C     | PG packages to be installed|
| 550 | [`pg_extensions`](#pg_extensions)                               | [`PG_INSTALL`](#PG_INSTALL)     | string[]    | C     | PG extension pkgs to be installed|
| 560 | [`pg_exists_action`](#pg_exists_action)                         | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | enum        | C/A   | how to deal with existing pg ins|
| 561 | [`pg_disable_purge`](#pg_disable_purge)                         | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | bool        | C/A   | disable pg instance purge|
| 562 | [`pg_data`](#pg_data)                                           | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | path        | C     | pg data dir|
| 563 | [`pg_fs_main`](#pg_fs_main)                                     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | path        | C     | pg main data disk mountpoint|
| 564 | [`pg_fs_bkup`](#pg_fs_bkup)                                     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | path        | C     | pg backup disk mountpoint|
| 565 | [`pg_dummy_filesize`](#pg_dummy_filesize)                       | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | size        | C     | /pg/dummy file size|
| 566 | [`pg_listen`](#pg_listen)                                       | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | ip          | C     | pg listen IP address|
| 567 | [`pg_port`](#pg_port)                                           | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | int         | C     | pg listen port|
| 568 | [`pg_localhost`](#pg_localhost)                                 | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | ip|path     | PG使用的UnixSocket地址         |
| 580 | [`patroni_enabled`](#patroni_enabled)                           | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | bool        | C     | Is patroni & postgres enabled?|
| 581 | [`patroni_mode`](#patroni_mode)                                 | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | enum        | C     | patroni working mode|
| 582 | [`pg_namespace`](#pg_namespace)                                 | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | path        | C     | namespace for patroni|
| 583 | [`patroni_port`](#patroni_port)                                 | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | int         | C     | patroni listen port (8080)|
| 584 | [`patroni_watchdog_mode`](#patroni_watchdog_mode)               | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | enum        | C     | patroni watchdog policy|
| 585 | [`pg_conf`](#pg_conf)                                           | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | string      | C     | patroni template|
| 586 | [`pg_shared_libraries`](#pg_shared_libraries)                   | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | string      | C     | default preload shared libraries|
| 587 | [`pg_encoding`](#pg_encoding)                                   | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | enum        | C     | character encoding|
| 588 | [`pg_locale`](#pg_locale)                                       | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | enum        | C     | locale|
| 589 | [`pg_lc_collate`](#pg_lc_collate)                               | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | enum        | C     | collate rule of locale|
| 590 | [`pg_lc_ctype`](#pg_lc_ctype)                                   | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | enum        | C     | ctype of locale|
| 591 | [`pgbouncer_enabled`](#pgbouncer_enabled)                       | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | bool        | C     | is pgbouncer enabled|
| 592 | [`pgbouncer_port`](#pgbouncer_port)                             | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | int         | C     | pgbouncer listen port|
| 593 | [`pgbouncer_poolmode`](#pgbouncer_poolmode)                     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | enum        | C     | pgbouncer pooling mode|
| 594 | [`pgbouncer_max_db_conn`](#pgbouncer_max_db_conn)               | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | int         | C     | max connection per database|
| 600 | [`pg_provision`](#pg_provision)                                 | [`PG_PROVISION`](#PG_PROVISION) | bool        | C     | provision template to pgsql?|
| 601 | [`pg_init`](#pg_init)                                           | [`PG_PROVISION`](#PG_PROVISION) | string      | C     | path to postgres init script|
| 602 | [`pg_default_roles`](#pg_default_roles)                         | [`PG_PROVISION`](#PG_PROVISION) | role[]      | G/C   | list or global default roles/users|
| 603 | [`pg_default_privilegs`](#pg_default_privilegs)                 | [`PG_PROVISION`](#PG_PROVISION) | string[]    | G/C   | list of default privileges|
| 604 | [`pg_default_schemas`](#pg_default_schemas)                     | [`PG_PROVISION`](#PG_PROVISION) | string[]    | G/C   | list of default schemas|
| 605 | [`pg_default_extensions`](#pg_default_extensions)               | [`PG_PROVISION`](#PG_PROVISION) | extension[] | G/C   | list of default extensions|
| 606 | [`pg_reload`](#pg_reload)                                       | [`PG_PROVISION`](#PG_PROVISION) | bool        | A     | reload config? |
| 607 | [`pg_hba_rules`](#pg_hba_rules)                                 | [`PG_PROVISION`](#PG_PROVISION) | rule[]      | G/C   | global HBA rules|
| 608 | [`pgbouncer_hba_rules`](#pgbouncer_hba_rules)                   | [`PG_PROVISION`](#PG_PROVISION) | rule[]      | G/C   | global pgbouncer HBA rules|
| 620 | [`pg_exporter_config`](#pg_exporter_config)                     | [`PG_EXPORTER`](#PG_EXPORTER)   | string      | C     | pg_exporter config path|
| 621 | [`pg_exporter_enabled`](#pg_exporter_enabled)                   | [`PG_EXPORTER`](#PG_EXPORTER)   | bool        | C     | pg_exporter enabled ?|
| 622 | [`pg_exporter_port`](#pg_exporter_port)                         | [`PG_EXPORTER`](#PG_EXPORTER)   | int         | C     | pg_exporter listen address|
| 623 | [`pg_exporter_params`](#pg_exporter_params)                     | [`PG_EXPORTER`](#PG_EXPORTER)   | string      | C/I   | extra params for pg_exporter url|
| 624 | [`pg_exporter_url`](#pg_exporter_url)                           | [`PG_EXPORTER`](#PG_EXPORTER)   | string      | C/I   | monitor target pgurl (overwrite)|
| 625 | [`pg_exporter_auto_discovery`](#pg_exporter_auto_discovery)     | [`PG_EXPORTER`](#PG_EXPORTER)   | bool        | C/I   | enable auto-database-discovery?|
| 626 | [`pg_exporter_exclude_database`](#pg_exporter_exclude_database) | [`PG_EXPORTER`](#PG_EXPORTER)   | string      | C/I   | excluded list of databases|
| 627 | [`pg_exporter_include_database`](#pg_exporter_include_database) | [`PG_EXPORTER`](#PG_EXPORTER)   | string      | C/I   | included list of databases|
| 628 | [`pg_exporter_options`](#pg_exporter_options)                   | [`PG_EXPORTER`](#PG_EXPORTER)   | string      | C/I   | cli args for pg_exporter|
| 629 | [`pgbouncer_exporter_enabled`](#pgbouncer_exporter_enabled)     | [`PG_EXPORTER`](#PG_EXPORTER)   | bool        | C     | pgbouncer_exporter enabled ?|
| 630 | [`pgbouncer_exporter_port`](#pgbouncer_exporter_port)           | [`PG_EXPORTER`](#PG_EXPORTER)   | int         | C     | pgbouncer_exporter listen addr?|
| 631 | [`pgbouncer_exporter_url`](#pgbouncer_exporter_url)             | [`PG_EXPORTER`](#PG_EXPORTER)   | string      | C/I   | target pgbouncer url (overwrite)|
| 632 | [`pgbouncer_exporter_options`](#pgbouncer_exporter_options)     | [`PG_EXPORTER`](#PG_EXPORTER)   | string      | C/I   | cli args for pgbouncer exporter|
| 640 | [`pg_services`](#pg_services)                                   | [`PG_SERVICE`](#PG_SERVICE)     | service[]   | G/C   | global service definition|
| 641 | [`haproxy_enabled`](#haproxy_enabled)                           | [`PG_SERVICE`](#PG_SERVICE)     | bool        | C/I   | haproxy enabled ?|
| 642 | [`haproxy_reload`](#haproxy_reload)                             | [`PG_SERVICE`](#PG_SERVICE)     | bool        | A     | haproxy reload instead of reset|
| 643 | [`haproxy_admin_auth_enabled`](#haproxy_admin_auth_enabled)     | [`PG_SERVICE`](#PG_SERVICE)     | bool        | G/C   | enable auth for haproxy admin ?|
| 644 | [`haproxy_admin_username`](#haproxy_admin_username)             | [`PG_SERVICE`](#PG_SERVICE)     | string      | G     | haproxy admin user name|
| 645 | [`haproxy_admin_password`](#haproxy_admin_password)             | [`PG_SERVICE`](#PG_SERVICE)     | string      | G     | haproxy admin password|
| 646 | [`haproxy_exporter_port`](#haproxy_exporter_port)               | [`PG_SERVICE`](#PG_SERVICE)     | int         | C     | haproxy exporter listen port|
| 647 | [`haproxy_client_timeout`](#haproxy_client_timeout)             | [`PG_SERVICE`](#PG_SERVICE)     | interval    | C     | haproxy client timeout|
| 648 | [`haproxy_server_timeout`](#haproxy_server_timeout)             | [`PG_SERVICE`](#PG_SERVICE)     | interval    | C     | haproxy server timeout|
| 649 | [`vip_mode`](#vip_mode)                                         | [`PG_SERVICE`](#PG_SERVICE)     | enum        | C     | vip working mode|
| 650 | [`vip_reload`](#vip_reload)                                     | [`PG_SERVICE`](#PG_SERVICE)     | bool        | A     | reload vip configuration|
| 651 | [`vip_address`](#vip_address)                                   | [`PG_SERVICE`](#PG_SERVICE)     | string      | C     | vip address used by cluster|
| 652 | [`vip_cidrmask`](#vip_cidrmask)                                 | [`PG_SERVICE`](#PG_SERVICE)     | int         | C     | vip network CIDR length|
| 653 | [`vip_interface`](#vip_interface)                               | [`PG_SERVICE`](#PG_SERVICE)     | string      | C     | vip network interface name|
| 654 | [`dns_mode`](#dns_mode)                                         | [`PG_SERVICE`](#PG_SERVICE)     | enum        | C     | cluster DNS mode|
| 655 | [`dns_selector`](#dns_selector)                                 | [`PG_SERVICE`](#PG_SERVICE)     | string      | C     | cluster DNS ins selector|


----------------
## `PG_IDENTITY`

[`pg_cluster`](#pg_cluster), [`pg_role`](#pg_role), [`pg_seq`](#pg_seq) belong to **identity parameters** .

In addition to the IP address, these three parameters are the minimum set of parameters necessary to define a new set of database clusters. A typical example is shown below:

```yaml
pg-test:
  hosts:
    10.10.10.11: {pg_seq: 1, pg_role: replica}
    10.10.10.12: {pg_seq: 2, pg_role: primary}
    10.10.10.13: {pg_seq: 3, pg_role: replica}
  vars:
    pg_cluster: pg-test
```

All other parameters can be inherited from the global configuration or the default configuration, but the identity parameters must be **explicitly specified** and **manually assigned**. The current PGSQL identity parameters are as follows:

|            Name             |   Type   | Level | Comment                                                |
| :-------------------------: | :------: | :---: | ------------------------------------------------------ |
| [`pg_cluster`](#pg_cluster) | `string` | **C** | **PG database cluster name**                           |
|     [`pg_seq`](#pg_seq)     | `number` | **I** | **PG database instance serial number**                 |
|    [`pg_role`](#pg_role)    |  `enum`  | **I** | **PG database instance role**                          |
|   [`pg_shard`](#pg_shard)   | `string` | **C** | **PG database slice set cluster name** (placeholder)   |
|  [`pg_sindex`](#pg_sindex)  | `number` | **C** | **PG database slice set cluster number** (placeholder) |

* [`pg_cluster`](#pg_cluster) identifies the name of the cluster, which is configured at the cluster level.
* [`pg_role`](#pg_role) Configured at the instance level, identifies the role of the instance, only the `primary` role will be handled specially, if not filled in, the default is the `replica` role, in addition to the special `delayed` and `offline` roles.
* [`pg_seq` ](#pg_seq) is used to identify the instance within the cluster, usually with an integer number incremented from 0 or 1, which is not changed once it is assigned.
* `{{ pg_cluster }}-{{ pg_seq }}` is used to uniquely identify the instance, i.e. `pg_instance`.
* `{{ pg_cluster }}-{{ pg_role }}` is used to identify the services within the cluster, i.e. `pg_service`.
* [`pg_shard`](#pg_shard) and [`pg_sindex`](#pg_sindex) are used for horizontally sharding clusters, reserved for Citus and Greenplum multicluster management.





### `pg_cluster`

PG database cluster name, type: `string`, level: cluster, no default. **Mandatory parameter, must be provided by the user**.

The cluster name will be used as the namespace for the resources within the cluster. The naming needs to follow a specific naming rule: `[a-z][a-z0-9-]*` to be compatible with the requirements of different constraints on the identity.




### `pg_shard`

Shard to which the PG cluster belongs (reserved), type: `string`, level: cluster, No default, Optional parameter.6

Only sharding clusters require this parameter to be set. When multiple database clusters serve the same business in a horizontally sharded fashion, Pigsty refers to this group of clusters as a **Sharding Cluster**.
`pg_shard` is the name of the shard set cluster to which the database cluster belongs. A shard set cluster can be specified with any name, but Pigsty recommends a meaningful naming convention.

For example, a cluster participating in a shard cluster can use the shard cluster name [`pg_shard`](#pg_shard) + `shard` + the cluster's shard number [`pg_sindex`](#pg_sindex) to form the cluster name：

```
shard:  test
pg-testshard1
pg-testshard2
pg-testshard3
pg-testshard4
```




### `pg_sindex`

PG cluster's slice number (reserved), type: `int`, level: C, no default.

The number of the cluster in the shard cluster, used in conjunction with [pg_shard](#pg_shard) is usually assigned sequentially starting from 0 or 1. Only sharded clusters require this parameter to be set.




### `gp_role`

Current role of PG cluster in GP, type: `enum`, level: C, default value：

Greenplum/MatrixDB-specific to specify the role this PG cluster plays in a GP deployment. The optional values are ：
* `master` ： Facilitator Nodes
* `segment` ： Data Nodes

**identity parameter**, **cluster level parameter**, **mandatory parameter** when deploying GPSQL



### `pg_role`

PG database instance role, type: `enum`, level: I, no default,  **mandatory parameter, must be provided by user.**

Roles for database instances, default roles include: `primary`, `replica`, `offline`.

* `primary`: Cluster master, there must be one and only one member of the cluster as `primary`.
* `replica`: Clustered slave repository for carrying online read-only traffic.
* `offline`: Clustered offline slave libraries for taking on offline read-only traffic, such as statistical analysis/ETL/personal queries, etc.

**Identity parameters, required parameters, instance-level parameters.**



### `pg_seq`

PG database instance serial number, type: `int`, level: I, no default value,  **mandatory parameter, must be provided by user.**

Serial number of the database instance, unique within the **cluster**, used to distinguish and identify different instances within the cluster, assigned starting from 0 or 1.



### `pg_instances`

All PG instances on the current node, type: `{port:ins}`, level: I, default value：

This parameter can be used to describe when the node is deployed by more than one PG instance, such as Greenplum's Segments, or when using [monitor-only mode](d-monly.md) to supervise existing instances.
[`pg_instances`](#pg_instances) is an array of objects with keys as instance ports and values as a dictionary whose contents can be parameters of any [`PGSQL`](v-pgsql.md) board, see [MatrixDB deployment](d-matrixdb.md) for details.





### `pg_upstream`

The replicated upstream node of the instance, type: `string`, level: I, default value is null.

Instance-level configuration item with IP address or host name to indicate the upstream node for stream replication.

* When configuring this parameter for a slave library of a cluster, the IP address filled in must be another node within the cluster. Instances will be stream replicated from that node, and this option can be used to build **cascade replication**.

* When this parameter is configured for the primary of the cluster, it means that the entire cluster will run as a **Standby Cluster**, receiving changes from upstream nodes. The `primary` in the cluster will play the role of `standby leader`.

Using this parameter flexibly, you can build an offsite disaster recovery cluster, complete the splitting of the sharded cluster, and realize the delayed slave library.



### `pg_offline_query`

Whether to allow offline queries, type: `bool`, level: I, default value: `false`.

When set to `true`, the user group `dbrole_offline` can connect to the instance and perform offline queries, regardless of the role of the current instance.

More practical for cases with a small number of instances (e.g. one master and one slave), the user can mark the only slave as `pg_offline_query = true`, thus accepting ETL, slow queries with interactive access.



### `pg_backup`

Whether to store cold backups on the instance, type: `bool`, level: I, default value: `false`.

Not implemented, the tag bit is reserved and the instance node with this tag is used to store the base cold backup.



### `pg_weight`

Relative weight of the instance in load balancing, type: `int`, level: I, default value: `100`.

When adjusting the relative weight of an instance in a service, this parameter can be modified at the instance level and applied to take effect as described in [SOP: Cluster Traffic Adjustment](r-sop.md).



### `pg_hostname`

Set PG instance name to HOSTNAME, type: `bool`, level: C/I, default value: `false`, which is true by default in the demo.

Whether to use the PostgreSQL instance name and cluster name as the node's name and cluster name when initializing the node, disabled by default.

When using the node:PG 1:1 exclusive deployment mode, you can assign the identity of the PG instance to the node, making the node consistent with the PG's monitoring identity.



### `pg_preflight_skip`

Skip PG identity parameter checksum, type: `bool`, level: C/A, default value: `false`.

If not initializing a new database cluster (e.g. when dealing with existing instances), the task of Patroni and Postgres initialization can be completely skipped with this parameter.





----------------
## `PG_BUSINESS`

Users need to **focus on** this part of the parameters to declare their required database objects on behalf of the business.

Customized cluster templates: users, databases, services, permission rules.

* Business User Definition： [`pg_users`](#pg_users)                                   
* Business Database Definition： [`pg_databases`](#pg_databases)                           
* Cluster Proprietary Services Definition： [`pg_services_extra`](#pg_services_extra)                 
* Cluster/instance specific HBA rules： [`pg_hba_rules_extra`](#pg_hba_rules_extra)               
* Pgbounce specific HBA rules： [`pgbouncer_hba_rules_extra`](#pgbouncer_hba_rules_extra) 

Special database users, it is recommended to change these user passwords in the production environment.

* PG Administrator User：[`pg_admin_username`](#pg_admin_username) / [`pg_admin_password`](#pg_admin_password)
* PG Copy User： [`pg_replication_username`](#pg_replication_username) / [`pg_replication_password`](#pg_replication_password)
* PG Monitoring Users：[`pg_monitor_username`](#pg_monitor_username) / [`pg_monitor_password`](#pg_monitor_password)




### `pg_users`

Business user definition, type: `user[]`, level: C, default value is an empty array.

Used to define business users at the database cluster level, each object in the array defines a [user or role] (c-pgdbuser#user), a complete user definition is as follows.

```yaml
pg_users:                           # define business users/roles on this cluster, array of user definition
  # define admin user for meta database (This user are used for pigsty app deployment by default)
  - name: dbuser_meta               # required, `name` is the only mandatory field of a user definition
    password: md5d3d10d8cad606308bdb180148bf663e1  # md5 salted password of 'DBUser.Meta'
    # optional, plain text and md5 password are both acceptable (prefixed with `md5`)
    login: true                     # optional, can login, true by default  (new biz ROLE should be false)
    superuser: false                # optional, is superuser? false by default
    createdb: false                 # optional, can create database? false by default
    createrole: false               # optional, can create role? false by default
    inherit: true                   # optional, can this role use inherited privileges? true by default
    replication: false              # optional, can this role do replication? false by default
    bypassrls: false                # optional, can this role bypass row level security? false by default
    pgbouncer: true                 # optional, add this user to pgbouncer user-list? false by default (production user should be true explicitly)
    connlimit: -1                   # optional, user connection limit, default -1 disable limit
    expire_in: 3650                 # optional, now + n days when this role is expired (OVERWRITE expire_at)
    expire_at: '2030-12-31'         # optional, YYYY-MM-DD 'timestamp' when this role is expired  (OVERWRITTEN by expire_in)
    comment: pigsty admin user      # optional, comment string for this user/role
    roles: [dbrole_admin]           # optional, belonged roles. default roles are: dbrole_{admin,readonly,readwrite,offline}
    parameters:                     # optional, role level parameters with `ALTER ROLE SET`
      log_min_duration_statements: 1000                  
    search_path: public         # key value config parameters according to postgresql documentation (e.g: use pigsty as default search_path)
  - {name: dbuser_view , password: DBUser.Viewer  ,pgbouncer: true ,roles: [dbrole_readonly], comment: read-only viewer for meta database}

  # define additional business users for prometheus & grafana (optional)
  - {name: dbuser_grafana    , password: DBUser.Grafana    ,pgbouncer: true ,roles: [dbrole_admin], comment: admin user for grafana database }
  - {name: dbuser_prometheus , password: DBUser.Prometheus ,pgbouncer: true ,roles: [dbrole_admin], comment: admin user for prometheus database }
```

* Each user or role must specify `name` and the rest of the fields are **optional**, `name` must be unique in this list.
* `password` is optional, if left blank then no password is set, you can use MD5 ciphertext password.
* `login`, `superuser`, `createdb`, `createrole`, `inherit`, `replication`, `bypassrls` are all boolean types used to set user attributes. If not set, the system defaults are used.
* Users are created by `CREATE USER`, so they have the `login` attribute by default. If the role is created, you need to specify `login: false`.
* `expire_at` and `expire_in` are used to control the user expiration time. `expire_at` uses a date timestamp in the shape of `YYYY-mm-DD`. `expire_in` uses the number of days to expire from now, and overrides the `expire_at` option if `expire_in` exists.
* New users are **not** added to the Pgbouncer user list by default, and `pgbouncer: true` must be explicitly defined for the user to be added to the Pgbouncer user list.
* Users/roles are created sequentially, and users defined later can belong to the roles defined earlier.
* Users can add [default permission]() groups for business users via the `roles` field:
    * `dbrole_readonly`：Default production read-only user with global read-only privileges. (Read-only production access)
    * `dbrole_offline`：Default offline read-only user with read-only access on a specific instance. (offline query, personal account, ETL)
    * `dbrole_readwrite`：Default production read/write user with global CRUD privileges. (Regular production use)
    * `dbrole_admin`：Default production management user with permission to execute DDL changes. (Administrator)

Configure `pgbouncer: true` for the production account to allow it to access through the connection pool; regular users should not access the database through the connection pool.





### `pg_databases`

Business database definition, type: `database[]`, level: C, default value is an empty array.

Used to define business users at the database cluster level, each object in the array defines a [business database](c-pgdbuser#数据库), a complete database definition as follows:

```yaml
pg_databases:                       # define business databases on this cluster, array of database definition
  # define the default `meta` database
  - name: meta                      # required, `name` is the only mandatory field of a database definition
    baseline: cmdb.sql              # optional, database sql baseline path, (relative path among ansible search path, e.g files/)
    owner: postgres                 # optional, database owner, postgres by default
    template: template1             # optional, which template to use, template1 by default
    encoding: UTF8                  # optional, database encoding, UTF8 by default. (MUST same as template database)
    locale: C                       # optional, database locale, C by default.  (MUST same as template database)
    lc_collate: C                   # optional, database collate, C by default. (MUST same as template database)
    lc_ctype: C                     # optional, database ctype, C by default.   (MUST same as template database)
    tablespace: pg_default          # optional, default tablespace, 'pg_default' by default.
    allowconn: true                 # optional, allow connection, true by default. false will disable connect at all
    revokeconn: false               # optional, revoke public connection privilege. false by default. (leave connect with grant option to owner)
    pgbouncer: true                 # optional, add this database to pgbouncer database list? true by default
    comment: pigsty meta database   # optional, comment string for this database
    connlimit: -1                   # optional, database connection limit, default -1 disable limit
    schemas: [pigsty]               # optional, additional schemas to be created, array of schema names
    extensions:                     # optional, additional extensions to be installed: array of schema definition `{name,schema}`
      - {name: adminpack, schema: pg_catalog}    # install adminpack to pg_catalog and install postgis to public
      - {name: postgis, schema: public}          # if schema is omitted, extension will be installed according to search_path.

```

In each database definition, the database name `name` is mandatory and the rest are optional.

* `name`：Database name, **required option**.
* `owner`：Database owner, default is `postgres`.
* `template`：The template used for database creation, default is `template1`.
* `encoding`：The default character encoding of the database, which is `UTF8` by default, is consistent with the instance by default. It is recommended not to configure and modify it.
* `locale`：The default localization rule for the database, which defaults to `C`, is recommended not to be configured to be consistent with the instance.
* `lc_collate`：The default localized string sorting rule for the database, which is set the same as the instance by default, should not be modified and must be consistent with the template database. It is strongly recommended not to configure, or configure to `C`.
* `lc_ctype`：The default LOCALE of the database, by default, is the same as the instance setting, do not modify or set it, it must be consistent with the template database. Configure to C or `en_US.UTF8`.
* `allowconn`：Whether to allow connection to database, default is `true`, not recommended to change.
* `revokeconn`：Reclaim permission to connect to the database. The default is `false`. To `true`, the `PUBLIC CONNECT` permission on the database will be reclaimed. Only the default user (`dbsu|monitor|admin|replicator|owner`) can connect. In addition, `admin|owner` will have GRANT OPTION, which can give other users connection privileges.
* `tablespace`：The tablespace associated with the database, the default is `pg_default`.
* `connlimit`：Database connection limit, default is `-1`, i.e. no limit.
* `extensions`：An array of objects , each of which defines an **extension** in the database, and its installed **schema**.
* `parameters`：KV objects, each KV defines a parameter that needs to be modified against the database via `ALTER DATABASE`.
* `pgbouncer`：Boolean option to join this database to Pgbouncer or not. All databases are joined to Pgbouncer unless `pgbouncer: false` is explicitly specified.
* `comment`：Database note information.






### `pg_services_extra`

Cluster Proprietary Service Definition, Type: `service[]`, Level: C, Default:

Used to define additional services at the database cluster level, each object in the array defines a [service] (c-services#service), a complete service definition is as follows:

```yaml
- name: default           # service's actual name is {{ pg_cluster }}-{{ service.name }}
  src_ip: "*"             # service bind ip address, * for all, vip for cluster virtual ip address
  src_port: 5436          # bind port, mandatory
  dst_port: postgres      # target port: postgres|pgbouncer|port_number , pgbouncer(6432) by default
  check_method: http      # health check method: only http is available for now
  check_port: patroni     # health check port:  patroni|pg_exporter|port_number , patroni by default
  check_url: /primary     # health check url path, / as default
  check_code: 200         # health check http code, 200 as default
  selector: "[]"          # instance selector
  haproxy:                # haproxy specific fields
    maxconn: 3000         # default front-end connection
    balance: roundrobin   # load balance algorithm (roundrobin by default)
    default_server_options: 'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'

```

Each cluster can define multiple services, each containing any number of cluster members. Services are distinguished by **port**, `name` and `src_port` are mandatory and must be unique within the array.

**MUST OPTION**

* **Name（`service.name`）**：

  **service name**, the full name of the service is prefixed by the database cluster name and suffixed by `service.name`, connected by `-`. For example, the service with `name=primary` in the `pg-test` cluster has the full service name `pg-test-primary`.

* **Port（`service.port`）**：

  In Pigsty, services are exposed to the public by default in the form of NodePort, so exposing the port is mandatory. However, if you use an external load balancing service access scheme, you can also differentiate the services in other ways.

* **Selector（`service.selector`）**：

  The **selector** specifies the instance members of the service, in the form of JMESPath, filtering variables from all cluster instance members. The default `[]` selector will pick all cluster members.

**Optional**

* **Backup Selector（`service.selector`）**：

  The optional **backup selector** `service.selector_backup` selects or marks the list of instances used for service backup, i.e. the backup instance takes over the service only when all other members of the cluster fail. For example, the `primary` instance can be added to the `replica` service's alternative set, so that the master can still carry the cluster's read-only traffic when all slaves fail.

* **Source IP（`service.src_ip`）** ：

  Indicates the IP address used externally by the **service**. The default is `*`, which is all IP addresses on the local machine. Using `vip` will use the `vip_address` variable to take the value, or you can fill in the specific IP address supported by the NIC.

* **Host port（`service.dst_port`）**：

  Which port on the target instance will the service's traffic be directed to? `postgres` will point to the port the database is listening on, `pgbouncer` will point to the port the connection pool is listening on, or you can fill in a fixed port number.

* **Health Check method（`service.check_method`）**:

  How does the service check the health status of the instance? Currently only HTTP is supported.

* **Health Check Port（`service.check_port`）**:

  Which port of the service check instance gets the health status of the instance? `patroni` will get it from Patroni (default 8008), `pg_exporter` will get it from PG Exporter (default 9630), or you can fill in a custom port number.

* **Health Check Path（`service.check_url`）**:

  The service performs HTTP checks using the URL PATH. `/` is used as a health check by default, and PG Exporter and Patroni provide a variety of health checks that can be used to differentiate between master and slave traffic. For example, `/primary` will only return success for the master, and `/replica` will only return success for the slave. `/read-only`, on the other hand, will return success for any instance that supports read-only (including the master).

* **Health Check Code（`service.check_code`）**:

  The code expected by the HTTP health check, default is 200.

* **Haproxy Specific Placement（`service.haproxy`）** ：

  Proprietary configuration items for service provisioning software (HAproxy).

  * `<service>.haproxy`

  These parameters are now defined in [**service**](c-service.md#service), using `service.haproxy` to override the parameter configuration of the instance.

  * `maxconn`

  HAProxy maximum number of front and back-end connections, default is 3000.

  * `balance`

  The algorithm used by haproxy load balancing, the optional policy is `roundrobin` and `leastconn`, the default is `roundrobin`.

  * `default_server_options`

  Default options for Haproxy backend server instances:

  `'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'`








### `pg_hba_rules_extra`

Cluster/instance specific HBA rule, Type: `rule[]`, Level: C, Default:

Set the client IP black and white list rules for the database. An array of objects, each of which represents a rule, each of which consists of three parts:

* `title`: Rule headings, which are converted to comments in the HBA file
* `role`: Apply roles, `common` means apply to all instances, other values (e.g. `replica`, `offline`) will only be installed to matching roles. For example, `role='replica'` means that this rule will only be applied to instances with `pg_role == 'replica'`.
* `rules`: Array of strings, each record represents a rule that will eventually be written to `pg_hba.conf`.

As a special case, the HBA rule for `role == 'offline'` is additionally installed on instances of `pg_offline_query == true`.

[`pg_hba_rules`](#pg_hba_rules) is similar, but is typically used for global uniform HBA rule settings, and [`pg_hba_rules_extra`](#pg_hba_rules_extra) will **append** to `pg_hba.conf` in the same way.

If you need to completely **overwrite** the cluster's HBA rules and do not want to inherit the global HBA configuration, you should configure [`pg_hba_rules`](#pg_hba_rules) at the cluster level and override the global configuration.





### `pgbouncer_hba_rules_extra`

Pgbounce specific HBA rule, type: `rule[]`, level: C, default value is an empty array.

Similar to [`pg_hba_rules_extra`](#pg_hba_rules_extra) for additional configuration of Pgbouncer's HBA rules at the cluster level.







### `pg_admin_username`

PG admin user, type: `string`, level: G, default value: `"dbuser_dba"`.

The database username used to perform PostgreSQL database administration tasks (DDL changes), with superuser privileges by default.

### `pg_admin_password`

PG admin user password, type: `string`, level: G, default value: `"DBUser.DBA"`.

The database user password used to perform PostgreSQL database administration tasks (DDL changes) must be in plaintext, the default is `DBUser.DBA` and highly recommended changes!!

It is highly recommended to change this parameter when deploying in production environments!



### `pg_replication_username`

PG copy user, type: `string`, level: G, default value: `"replicator"`.

For performing PostgreSQL stream replication, it is recommended to keep global consistency.

### `pg_replication_password`

PG replicates the user's password, type: `string`, level: G, default value: `"DBUser.Replicator"`.

The password of the database user used to perform PostgreSQL stream replication must be in plaintext. The default is `DBUser.Replicator`.

It is highly recommended to change this parameter when deploying in production environments!



### `pg_monitor_username`

PG monitor user, type: `string`, level: G, default value: `"dbuser_monitor"`.

The database user name used to perform PostgreSQL and Pgbouncer monitoring tasks.



### `pg_monitor_password`

PG monitor user password, type: `string`, level: G, default value: `"DBUser.Monitor"`.

The password of the database user used to perform PostgreSQL and Pgbouncer monitoring tasks, must be in plaintext.

It is highly recommended to change this parameter when deploying in production environments!





----------------
## `PG_INSTALL`

PG Install is responsible for completing the installation of all PostgreSQL dependencies on a machine with the base software. The user can configure the name, ID, permissions, and access of the database superuser, configure the sources used for the installation, configure the installation address, the version to be installed, and the required packages and extensions plugins.

Such parameters only need to be modified when upgrading a major version of the database as a whole. Users can specify the software version to be installed via [`pg_version`](#pg_version) and override it at the cluster level to install different database versions for different clusters.





### `pg_dbsu`

PG OS superuser, type: `string`, level: C, default value: `"postgres"`, not recommended to modify.

When installing Greenplum / MatrixDB, modify this parameter to the corresponding recommended value: `gpadmin|mxadmin`.


### `pg_dbsu_uid`

Superuser UID, type: `int`, level: C, default value: `26`.

UID of the OS user (superuser) used by the database by default. default value is `26`, consistent with the official RPM package configuration of PostgreSQL under CentOS, no modification is recommended.




### `pg_dbsu_sudo`

Sudo privileges for superuser, type: `enum`, level: C, default value: `"limit"`.

* `none`：No sudo privileges
* `limit`：Limited sudo privileges to execute systemctl commands for database related components, default.
* `all`：Full `sudo` privileges, password required.
* `nopass`：Full `sudo` access without password (not recommended).

The database superuser [`pg_dbsu`](#pg_dbsu) has restricted `sudo` privileges by default: `limit`.




### `pg_dbsu_home`

Root directory of database superuser [`pg_dbsu`](#pg_dbsu), type: `path`, level: C, default value: `"/var/lib/pgsql"`.



### `pg_dbsu_ssh_exchange`

Whether to exchange the SSH public-private key of superuser [`pg_dbsu`](#pg_dbsu) between executing machines. Type: `bool`, Level: C, Default: `true`.

### `pg_version`

Installed database major version, type: `int`, level: C, default value: `14`.

The current instance's installed PostgreSQL major version number, default is 14, supported as low as 10.

Note that PostgreSQL physical stream replication cannot span major versions, please configure this variable at the global/cluster level to ensure that all instances within the entire cluster have the same major version number.

### `pgdg_repo`

Whether to add the official PG source? , type: `bool`, level: C, default value: `false`.

Use this option to download and install PostgreSQL-related packages directly from official Internet sources without local sources.




### `pg_add_repo`

Whether to add PG-related upstream sources? , type: `bool`, level: C, default value: `false`

If used, the official source of PGDG will be added before installing PostgreSQL.




### `pg_bin_dir`

PG binary directory, type: `path`, level: C, default value: `"/usr/pgsql/bin"`.

The default value is a softlink created manually during the installation process, pointing to the specific Postgres version directory installed.

For example `/usr/pgsql -> /usr/pgsql-14`. For more details, please see  [FHS](r-fhs.md).



### `pg_packages`

List of installed PG packages, type: `string[]`, level: C, default value:

```yaml
- postgresql${pg_version}*
- postgis32_${pg_version}*
- citus_${pg_version}*
- timescaledb-2-postgresql-${pg_version}
- pgbouncer pg_exporter pgbadger pg_activity node_exporter consul haproxy vip-manager
- patroni patroni-consul patroni-etcd python3 python3-psycopg2 python36-requests python3-etcd
- python3-consul python36-urllib3 python36-idna python36-pyOpenSSL python36-cryptography
```

`${pg_version}` in the package will be replaced with the actual installed PostgreSQL version [`pg_version`](#pg_version).

When you specify a special [`pg_version`](#pg_version) for a particular cluster, you can adjust this parameter at the cluster level accordingly (e.g. some extensions did not exist when PG14 beta was installed).





### `pg_extensions`

PG plugin list, type: `string[]`, level: C, default value:

```yaml
pg_repack_${pg_version}
pg_qualstats_${pg_version}
pg_stat_kcache_${pg_version}
pg_stat_monitor_${pg_version}
wal2json_${pg_version}"
```

`${pg_version}` will be replaced with the PostgreSQL major version number [`pg_version`](#pg_version).





----------------
## `PG_BOOTSTRAP`

On a machine with Postgres, create a set of databases.

* **Cluster identity definition**, clean up existing instances, create directory structure, copy tools and playbooks, configure environment variables.
* Render Patroni template configuration files, pull up master and slave libraries using Patroni.
* Configure Pgbouncer, initialize the business users and database, and register the database and data source services to DCS.

With [`pg_conf`](#pg_conf) you can use the default database cluster templates (OLTP / OLAP / CRIT / TINY). If you create a custom template, you can clone the default configuration in `roles/postgres/templates` and adopt it after modifying it yourself, please refer to: [customize pgsql cluster](v-pgsql-customize.md) for details.



### `pg_exists_action`

Action when PG exists, type: `enum`, level: C/A, default value: `"clean"`.

System actions when a PostgreSQL instance exists:

* `abort`: Abort playbook execution (default behavior)
* `clean`: Erase existing instances and continue (dangerous)
* `skip`: Ignore targets for which instances exist (abort) and continue execution on other target machines.

To force wipe existing database instances, please use [`pgsql-remove.yml`](p-pgsql.md#pgsql-remove) to complete the cluster and instance offline first, and then reinitialize.
Otherwise, overwriting needs to be done with the command line argument `-e pg_exists_action=clean` to force the wiping of existing instances during initialization.




### `pg_disable_purge`

Prohibit clearing existing PG instances, type: `bool`, level: C/A, default value: `false`.

If `true`, force set [`pg_exists_action`](#pg_exists_action) to `abort`, i.e. turn off the cleanup of [`pg_exists_action`](#pg_exists_action) to ensure that Postgres instances are not wiped out under any circumstances.

Then, you need to clean up the existing instances by [`pgsql-remove.yml`](p-pgsql.md#pgsql-remove), and then finish the database initialization again.





### `pg_data`

PG data directory, type: `path`, level: C, default value: `"/pg/data"`, not recommended to change.





### `pg_fs_main`

PG master data disk mount point, type: `path`, level: C, default value: `"/data"`.

Pigsty's default [directory structure](r-fhs) assumes that there is a master data disk mount point on the system that holds the database directory along with other state.



### `pg_fs_bkup`

PG backup disk mount point, type: `path`, level: C, default value: `"/data/backups"`.

Pigsty's default [directory structure](r-fhs) assumes that there is a backup data disk mount point on the system that holds backup and archive data. However, users can also specify a subdirectory on the primary data disk as the backup disk root mount point.



### `pg_dummy_filesize`

Size of the placeholder file `/pg/dummy`, type: `size`, level: C, default value: `"64MiB"`.

A placeholder file is a pre-allocated empty file that takes up disk space. When the disk is full, removing the placeholder file can free up some space, it is recommended to use `4GiB`, `8GiB` for production env.





### `pg_listen`

IP address of PG listening, type: `ip`, level: C, default value: `"0.0.0.0"`.

IP address of database listening,default all IPv4 addresses `0.0.0.0`, if you want to include all IPv6 addresses, you can use `*`.



### `pg_port`

Port of PG listening, type: `int`, level: C, default value: `5432`, not recommended to change.




### `pg_localhost`

UnixSocket address used by PG, type: `ip|path`, level: C, default value: `"/var/run/postgresql"`.

The Unix socket directory holds the Unix socket files for PostgreSQL and Pgbouncer, which are accessed through the local Unix socket when the client does not specify an IP address to access the database.



### `patroni_enabled`

Whether Patroni is enabled or not, type: `bool`, level: C, default value: `true`.

If false, Pigsty will skip the process of Patroni pulling up with Postgres directly. This option is used when accessing an existing instance.

### `patroni_mode`

Patroni configuration mode, type: `enum`, level: C, default value: `"default"`.

* `default`: Enable Patroni to enter high availability auto-switching mode.
* `pause`: Enable Patroni to automatically enter maintenance mode after completing initialization (no automatic master-slave switching).
* `remove`: Initialize the cluster with Patroni and remove Patroni after initialization.



### `pg_namespace`

DCS namespace used by Patroni, type: `path`, level: C, default value: `"/pg"`.





### `patroni_port`

Patroni服务端口, 类型：`int`，层级：C，默认值为：`8008`

Patroni API服务器默认监听并对外暴露服务与健康检查的端口。




### `patroni_watchdog_mode`

Patroni Watchdog模式, 类型：`enum`，层级：C，默认值为：`"automatic"`

当发生主从切换时，Patroni会尝试在提升从库前关闭主库。如果指定超时时间内主库仍未成功关闭，Patroni会根据配置使用Linux内核模块`softdog`进行fencing关机。

* `off`：不使用`watchdog`
* `automatic`：如果内核启用了`softdog`，则启用`watchdog`，不强制，默认行为。
* `required`：强制使用`watchdog`，如果系统未启用`softdog`则拒绝启动。

启用Watchdog意味着系统会优先确保数据一致性，而放弃可用性，如果您的系统更重视可用性，则可以关闭Watchdog，建议关闭管理节点上的Watchdog。




### `pg_conf`

Patroni使用的配置模板, 类型：`string`，层级：C，默认值为：`"tiny.yml"`

拉起Postgres集群所用的[Patroni模板](v-pgsql-customize.md)。Pigsty预制了4种模板

* [`oltp.yml`](#oltp) 常规OLTP模板，默认配置
* [`olap.yml`](#olap) OLAP模板，提高并行度，针对吞吐量优化，针对长时间运行的查询进行优化。
* [`crit.yml`](#crit)) 核心业务模板，基于OLTP模板针对安全性，数据完整性进行优化，采用同步复制，强制启用数据校验和。
* [`tiny.yml`](#tiny) 微型数据库模板，针对低资源场景进行优化，例如运行于虚拟机中的演示数据库集群。




### `pg_shared_libraries`

PG默认加载的共享库, 类型：`string`，层级：C，默认值为：`"timescaledb, pg_stat_statements, auto_explain"`

填入Patroni模板中`shared_preload_libraries`参数的字符串，控制PG启动预加载的动态库。在当前版本中，默认会加载以下库：`timescaledb, pg_stat_statements, auto_explain`

如果您希望默认启用Citus支持，则需要修改该参数，将 `citus` 添加至首位：`citus, timescaledb, pg_stat_statements, auto_explain`





### `pg_encoding`

PG字符集编码, 类型：`enum`，层级：C，默认值为：`"UTF8"`。如无特殊需求，不建议修改此参数。



### `pg_locale`

PG使用的本地化规则, 类型：`enum`，层级：C，默认值为：`"C"`

如无特殊需求，不建议修改此参数，不当的排序规则可能对数据库性能产生显著影响。




### `pg_lc_collate`

PG使用的本地化排序规则, 类型：`enum`，层级：C，默认值为：`"C"`

默认为`C`，如无特殊需求，，**强烈不建议**修改此参数。用户总是可以通过`COLLATE`表达式实现本地化排序相关功能，错误的本地化排序规则可能导致某些操作产生成倍的性能损失，请在真的有本地化需求的情况下修改此参数。



### `pg_lc_ctype`

PG使用的本地化字符集定义, 类型：`enum`，层级：C，默认值为：`"en_US.UTF8"`

默认为`en_US.UTF8`，因为一些PG扩展（`pg_trgm`）需要额外的字符分类定义才可以针对国际化字符正常工作，因此Pigsty默认会使用`en_US.UTF8`字符集定义，不建议修改此参数。



### `pgbouncer_enabled`

是否启用Pgbouncer, 类型：`bool`，层级：C，默认值为：`true`




### `pgbouncer_port`

Pgbouncer端口, 类型：`int`，层级：C，默认值为：`6432`




### `pgbouncer_poolmode`

Pgbouncer池化模式, 类型：`enum`，层级：C，默认值为：`"transaction"`

* `transaction`，事务级连接池，默认，性能好，但影响 PreparedStatements 与其他一些会话级功能的使用。
* `session`，会话级连接池，兼容性最强。
* `statements`，语句级连接池，若您的查询均为点查，可以考虑使用此模式。



### `pgbouncer_max_db_conn`

Pgbouncer最大单DB连接数, 类型：`int`，层级：C，默认值为：`100`

允许连接池与单个数据库之间建立的最大连接数，默认值为`100`

使用Transaction Pooling模式时，活跃服务端连接数通常处于个位数。如果采用Session Pooling模式，可以适当增大此参数。





----------------
## `PG_PROVISION`

[`PG_BOOTSTRAP`](#PG_BOOTSTRAP)负责拉起一套全新的Postgres集群，而[`PG_PROVISION`](#PG_PROVISION)负责在这套全新的数据库集群中创建默认的对象，包括

* 基本角色：只读角色，读写角色、管理角色
* 基本用户：复制用户、超级用户、监控用户、管理用户
* 模板数据库中的默认权限
* 默认 模式
* 默认 扩展
* HBA黑白名单规则

Pigsty提供了丰富的定制选项，如果您希望进一步客制化PG集群，可以参考 [定制：PGSQL集群](v-pgsql-customize.md)



### `pg_provision`

是否置备PG集群？（应用模板）, 类型：`bool`，层级：C，默认值为：`true`

是否对拉起的PostgreSQL集群执行置备任务？设置为假会跳过 [`PG_TEMPLATE`](#PG_TEMPALTE)定义的任务。
但注意，数据库超级用户、复制用户、管理用户、监控用户四个默认用户的创建不受此影响。



### `pg_init`

自定义PG初始化脚本, 类型：`string`，层级：C，默认值为：`"pg-init"`

用于初始化数据库模板的Shell脚本位置，默认为`pg-init`，该脚本会被拷贝至`/pg/bin/pg-init`后执行。

默认的`pg-init` 只是预渲染SQL命令的包装：

* `/pg/tmp/pg-init-roles.sql` ： 根据[`pg_default_roles`](#pg_default_roles)生成的默认角色创建脚本
* `/pg/tmp/pg-init-template.sql`，根据[`pg_default_privileges`](#pg_default_privileges), [`pg_default_schemas`](#pg_default_schemas), [`pg_default_extensions`](#pg_default_extensions) 生产的SQL命令。会同时应用于默认模版数据库`template1`与默认管理数据库`postgres`。

```bash
# system default roles
psql postgres -qAXwtf /pg/tmp/pg-init-roles.sql

# system default template
psql template1 -qAXwtf /pg/tmp/pg-init-template.sql

# make postgres same as templated database (optional)
psql postgres  -qAXwtf /pg/tmp/pg-init-template.sql
```

用户可以在自定义的`pg-init`脚本中添加自己的集群初始化逻辑。





### `pg_default_roles`

默认创建的角色与用户, 类型：`role[]`，层级：G/C，默认值为：

```yaml
# - default roles - #
pg_default_roles:
  # default roles
  - { name: dbrole_readonly  , login: false , comment: role for global read-only access  }                            # production read-only role
  - { name: dbrole_readwrite , login: false , roles: [dbrole_readonly], comment: role for global read-write access }  # production read-write role
  - { name: dbrole_offline , login: false , comment: role for restricted read-only access (offline instance) }        # restricted-read-only role
  - { name: dbrole_admin , login: false , roles: [pg_monitor, dbrole_readwrite] , comment: role for object creation }  # production DDL change role

  # default users
  - { name: postgres , superuser: true , comment: system superuser }                             # system dbsu, name is designated by `pg_dbsu`
  - { name: dbuser_dba , superuser: true , roles: [dbrole_admin] , comment: system admin user }  # admin dbsu, name is designated by `pg_admin_username`
  - { name: replicator , replication: true , bypassrls: true , roles: [pg_monitor, dbrole_readonly] , comment: system replicator }                   # replicator
  - { name: dbuser_monitor , roles: [pg_monitor, dbrole_readonly] , comment: system monitor user , parameters: {log_min_duration_statement: 1000 } } # monitor user
  - { name: dbuser_stats , password: DBUser.Stats , roles: [dbrole_offline] , comment: business offline user for offline queries and ETL }           # ETL user
```

本参数定义了PostgreSQL中的[默认角色](c-privilege.md#默认角色)与[默认用户](c-privilege.md#默认用户)，形式为对象数组，对象定义形式与 [`pg_users`](#pg_users) 中保持一致。






### `pg_default_privilegs`

定义数据库模板中的默认权限, 类型：`string[]`，层级：G/C，默认值为：

```yaml
pg_default_privileges:
  - GRANT USAGE                         ON SCHEMAS   TO dbrole_readonly
  - GRANT SELECT                        ON TABLES    TO dbrole_readonly
  - GRANT SELECT                        ON SEQUENCES TO dbrole_readonly
  - GRANT EXECUTE                       ON FUNCTIONS TO dbrole_readonly
  - GRANT USAGE                         ON SCHEMAS   TO dbrole_offline
  - GRANT SELECT                        ON TABLES    TO dbrole_offline
  - GRANT SELECT                        ON SEQUENCES TO dbrole_offline
  - GRANT EXECUTE                       ON FUNCTIONS TO dbrole_offline
  - GRANT INSERT, UPDATE, DELETE        ON TABLES    TO dbrole_readwrite
  - GRANT USAGE,  UPDATE                ON SEQUENCES TO dbrole_readwrite
  - GRANT TRUNCATE, REFERENCES, TRIGGER ON TABLES    TO dbrole_admin
  - GRANT CREATE                        ON SCHEMAS   TO dbrole_admin
```

详细信息请参考 [默认权限](c-privilege.md#权限)。




### `pg_default_schemas`

默认创建的模式, 类型：`string[]`，层级：G/C，默认值为：`[monitor]`

Pigsty默认会创建名为`monitor`的模式用于安装监控扩展。




### `pg_default_extensions`

默认安装于模板数据库的扩展，对象数组，类型为`extension[]`，层级：G/C，默认值为：

```yaml
pg_default_extensions:
  - { name: 'pg_stat_statements',  schema: 'monitor' }
  - { name: 'pgstattuple',         schema: 'monitor' }
  - { name: 'pg_qualstats',        schema: 'monitor' }
  - { name: 'pg_buffercache',      schema: 'monitor' }
  - { name: 'pageinspect',         schema: 'monitor' }
  - { name: 'pg_prewarm',          schema: 'monitor' }
  - { name: 'pg_visibility',       schema: 'monitor' }
  - { name: 'pg_freespacemap',     schema: 'monitor' }
  - { name: 'pg_repack',           schema: 'monitor' }
  - name: postgres_fdw
  - name: file_fdw
  - name: btree_gist
  - name: btree_gin
  - name: pg_trgm
  - name: intagg
  - name: intarray
```

如果扩展没有指定`schema`字段，扩展会根据当前的`search_path`安装至对应模式中，例如`public`。




### `pg_reload`

是否重载数据库配置（HBA）, 类型：`bool`，层级：A，默认值为：`true`

设置为`true`时，Pigsty会在生成HBA规则后立刻执行`pg_ctl reload`应用。

当您希望生成`pg_hba.conf`文件，并手工比较后再应用生效时，可以指定`-e pg_reload=false`来禁用它。



### `pg_hba_rules`

PostgreSQL全局HBA规则, 类型：`rule[]`，层级：G/C，默认值为：

```yaml
pg_hba_rules:
  - title: allow meta node password access
    role: common
    rules:
      - host    all     all                         10.10.10.10/32      md5

  - title: allow intranet admin password access
    role: common
    rules:
      - host    all     +dbrole_admin               10.0.0.0/8          md5
      - host    all     +dbrole_admin               172.16.0.0/12       md5
      - host    all     +dbrole_admin               192.168.0.0/16      md5

  - title: allow intranet password access
    role: common
    rules:
      - host    all             all                 10.0.0.0/8          md5
      - host    all             all                 172.16.0.0/12       md5
      - host    all             all                 192.168.0.0/16      md5

  - title: allow local read-write access (local production user via pgbouncer)
    role: common
    rules:
      - local   all     +dbrole_readwrite                               md5
      - host    all     +dbrole_readwrite           127.0.0.1/32        md5

  - title: allow read-only user (stats, personal) password directly access
    role: replica
    rules:
      - local   all     +dbrole_readonly                               md5
      - host    all     +dbrole_readonly           127.0.0.1/32        md5
```

本参数在形式上与 [`pg_hba_rules_extra`](#pg_hba_rules_extra) 完全一致，建议在全局配置统一的 [`pg_hba_rules`](#pg_hba_rules)，针对特定集群使用 [`pg_hba_rules_extra`](#pg_hba_rules_extra) 进行额外定制。两个参数中的规则都会依次应用，后者优先级更高。









### `pgbouncer_hba_rules`

PgbouncerL全局HBA规则, 类型：`rule[]`，层级：G/C，默认值为：

```yaml
pgbouncer_hba_rules:
  - title: local password access
    role: common
    rules:
      - local  all          all                                     md5
      - host   all          all                     127.0.0.1/32    md5

  - title: intranet password access
    role: common
    rules:
      - host   all          all                     10.0.0.0/8      md5
      - host   all          all                     172.16.0.0/12   md5
      - host   all          all                     192.168.0.0/16  md5
```

默认的Pgbouncer HBA规则很简单：

1. 允许从**本地**使用密码登陆
2. 允许从内网网断使用密码登陆

用户可以按照自己的需求进行定制。






----------------
## `PG_EXPORTER`

PG Exporter 用于监控Postgres数据库与Pgbouncer连接池



### `pg_exporter_config`

PG指标定义配置文件, 类型：`string`，层级：C，默认值为：`"pg_exporter.yml"`

`pg_exporter`使用的默认配置文件，定义了Pigsty中的数据库与连接池监控指标。默认为 [`pg_exporter.yml`](https://github.com/Vonng/pigsty/blob/master/roles/pg_exporter/files/pg_exporter.yml)

Pigsty使用的PG Exporter配置文件默认从PostgreSQL 10.0 开始提供支持，目前支持至最新的PG 14版本。此外还有一些可选的配置模板：

* [`pg_exporter_basic.yml`](https://github.com/Vonng/pigsty/blob/master/roles/pg_exporter/files/pg_exporter_basic.yml)：只包含基本指标，不包含数据库内对象监控指标
* [`pg_exporter_fast.yml`](https://github.com/Vonng/pigsty/blob/master/roles/pg_exporter/files/pg_exporter_fast.yml)：缓存时间更短的指标定义




### `pg_exporter_enabled`

启用PG指标收集器, 类型：`bool`，层级：C，默认值为：`true`

是否安装并配置`pg_exporter`，为`false`时，将跳过当前节点上 `pg_exporter` 的配置，并在注册监控目标时跳过此Exporter。



### `pg_exporter_port`

PG指标暴露端口, 类型：`int`，层级：C，默认值为：`9630`




### `pg_exporter_params`

PG Exporter额外的URL参数, 类型：`string`，层级：C/I，默认值为：`"sslmode=disable"`




### `pg_exporter_url`

采集对象数据库的连接串（覆盖）, 类型：`string`，层级：C/I，默认值为：`""`

PG Exporter用于连接至数据库的PGURL，应当为访问`postgres`管理数据库的URL，该选项以环境变量的方式配置于 `/etc/default/pg_exporter` 中。

可选参数，默认为空字符串，如果配置了 [`pg_exporter_url`](#pg_exporter_url) 选项，则会直接使用该URL作为监控连接串。否则Pigsty将使用以下规则生成监控的目标URL：

* [`pg_monitor_username`](#pg_monitor_username) : 监控用户名
* [`pg_monitor_password`](#pg_monitor_password) : 监控用户密码
* [`pg_localhost`](#pg_localhost) : PG监听的本地IP地址或Unix Socket Dir
* [`pg_port`](#pg_port) : PG监听的端口
* [`pg_exporter_params`](#pg_exporter_params) : PG Exporter需要的额外参数

以上参数将按下列方式进行拼接

```bash
postgres://{{ pg_monitor_username }}:{{ pg_monitor_password }}@:{{ pg_port }}/postgres{% if pg_exporter_params != '' %}?{{ pg_exporter_params }}{% if pg_localhost != '' %}&host={{ pg_localhost }}{% endif %}{% endif %}
```

如果指定了[`pg_exporter_url`](#pg_exporter_url) 参数，则Exporter会直接使用该连接串。

注意：当您只需要监控某一个特定业务数据库时，您可以直接使用该数据库的PGURL。如果您希望监控某一个数据库实例上**所有**的业务数据库，则建议使用管理数据库`postgres`的PGURL。




### `pg_exporter_auto_discovery`

是否自动发现实例中的数据库, 类型：`bool`，层级：C/I，默认值为：`true`

是否启用自动数据库发现，默认开启。开启后，PG Exporter会自动检测目标实例中数据库列表的变化，并为每一个数据库创建一条抓取连接

关闭时，库内对象监控不可用。（如果您不希望在监控系统中暴露业务相关数据，可以关闭此特性）

!> 注意如果您有很多数据库（100+），或数据库内对象非常多（几k，十几k），请审慎评估对象监控产生的开销。




### `pg_exporter_exclude_database`

数据库自动发现排除列表, 类型：`string`，层级：C/I，默认值为：`"template0,template1,postgres"`

逗号分隔的数据库名称列表，启用自动数据库发现时，此列表中的数据库**不会被监控**（被排除在监控对象之外）。



### `pg_exporter_include_database`

数据库自动发现囊括列表, 类型：`string`，层级：C/I，默认值为：`""`

逗号分隔的数据库名称列表，启用自动数据库发现时，不在此列表中的数据库不会被监控（显式指定需要监控的数据库）。




### `pg_exporter_options`

PG Exporter命令行参数, 类型：`string`，层级：C/I，默认值为：`"--log.level=info --log.format=\"logger:syslog?appname=pg_exporter&local=7\""`




### `pgbouncer_exporter_enabled`

启用PGB指标收集器, 类型：`bool`，层级：C，默认值为：`true`




### `pgbouncer_exporter_port`

PGB指标暴露端口, 类型：`int`，层级：C，默认值为：`9631`





### `pgbouncer_exporter_url`

采集对象连接池的连接串, 类型：`string`，层级：C/I，默认值为：`""`

PGBouncer Exporter用于连接至数据库的URL，应当为访问`pgbouncer`管理数据库的URL。可选参数，默认为空字符串。

Pigsty默认使用以下规则生成监控的目标URL，如果配置了`pgbouncer_exporter_url`选项，则会直接使用该URL作为连接串。

```bash
PG_EXPORTER_URL='postgres://{{ pg_monitor_username }}:{{ pg_monitor_password }}@:{{ pgbouncer_port }}/pgbouncer?host={{ pg_localhost }}&sslmode=disable'
```

该选项以环境变量的方式配置于 `/etc/default/pgbouncer_exporter` 中。





### `pgbouncer_exporter_options`

PGB Exporter命令行参数, 类型：`string`，层级：C/I，默认值为：`"--log.level=info --log.format=\"logger:syslog?appname=pgbouncer_exporter&local=7\""`

即将INFO级日志打入syslog中。





----------------
## `PG_SERVICE`

对外暴露PostgreSQL服务，安装负载均衡器 HAProxy，启用VIP，配置DNS。



### `pg_services`

全局通用PG服务定义, 类型：`[]service`，层级：G，默认值为：

```yaml
pg_services:                     # how to expose postgres service in cluster?
  - name: primary                # service name {{ pg_cluster }}-primary
    src_ip: "*"
    src_port: 5433
    dst_port: pgbouncer          # 5433 route to pgbouncer
    check_url: /primary          # primary health check, success when instance is primary
    selector: "[]"               # select all instance as primary service candidate
 
  - name: replica                # service name {{ pg_cluster }}-replica
    src_ip: "*"
    src_port: 5434
    dst_port: pgbouncer
    check_url: /read-only        # read-only health check. (including primary)
    selector: "[]"               # select all instance as replica service candidate
    selector_backup: "[? pg_role == `primary` || pg_role == `offline` ]"
  
  - name: default                # service's actual name is {{ pg_cluster }}-default
    src_ip: "*"                  # service bind ip address, * for all, vip for cluster virtual ip address
    src_port: 5436               # bind port, mandatory
    dst_port: postgres           # target port: postgres|pgbouncer|port_number , pgbouncer(6432) by default
    check_method: http           # health check method: only http is available for now
    check_port: patroni          # health check port:  patroni|pg_exporter|port_number , patroni by default
    check_url: /primary          # health check url path, / as default
    check_code: 200              # health check http code, 200 as default
    selector: "[]"               # instance selector
    haproxy:                     # haproxy specific fields
      maxconn: 3000              # default front-end connection
      balance: roundrobin        # load balance algorithm (roundrobin by default)
      default_server_options: 'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'
 
  - name: offline                # service name {{ pg_cluster }}-offline
    src_ip: "*"
    src_port: 5438
    dst_port: postgres
    check_url: /replica          # offline MUST be a replica
    selector: "[? pg_role == `offline` || pg_offline_query ]"         # instances with pg_role == 'offline' or instance marked with 'pg_offline_query == true'
    selector_backup: "[? pg_role == `replica` && !pg_offline_query]"  # replica are used as backup server in offline service
```

由[服务定义](c-service.md#自定义服务)对象构成的数组，定义了每一个数据库集群中对外暴露的服务。形式上与 [`pg_service_extra`](#pg_services_extra) 保持一致。




### `haproxy_enabled`

是否启用Haproxy, 类型：`bool`，层级：C/I，默认值为：`true`

Pigsty默认会在所有数据库节点上部署Haproxy，您可以通过覆盖实例级变量，仅在特定实例/节点上启用Haproxy负载均衡器。




### `haproxy_reload`

是否重载Haproxy配置, 类型：`bool`，层级：A，默认值为：`true`

如果关闭，则Pigsty在渲染HAProxy配置文件后不会执行Reload操作，给用户手工介入检查确认的机会。




### `haproxy_admin_auth_enabled`

是否对Haproxy管理界面启用认证, 类型：`bool`，层级：G/C，默认值为：`false`

默认不启用，建议在生产环境启用，或在Nginx或其他接入层添加访问控制。



### `haproxy_admin_username`

HAproxy管理员名称, 类型：`string`，层级：G，默认值为：`"admin"`





### `haproxy_admin_password`

HAproxy管理员密码, 类型：`string`，层级：G，默认值为：`"pigsty"`





### `haproxy_exporter_port`

HAproxy指标暴露器端口, 类型：`int`，层级：C，默认值为：`9101`





### `haproxy_client_timeout`

HAproxy客户端超时, 类型：`interval`，层级：C，默认值为：`"24h"`





### `haproxy_server_timeout`

HAproxy服务端超时, 类型：`interval`，层级：C，默认值为：`"24h"`





### `vip_mode`

VIP模式：none, 类型：`enum`，层级：C，默认值为：`"none"`

* `none`：不设置VIP，默认选项。
* `l2`：配置绑定在主库上的二层VIP（需要所有成员位于同一个二层网络广播域中）
* `l4` ：预留值，通过外部L4负载均衡器进行流量分发。（未纳入Pigsty当前实现中）

VIP用于确保**读写服务**与**负载均衡器**的高可用，当使用L2 VIP时，Pigsty的VIP由`vip-manager`托管，会绑定在**集群主库**上。

这意味着您始终可以通过VIP访问集群主库，或者通过VIP访问主库上的负载均衡器（如果主库的压力很大，这样做可能会有性能压力）。

> 注意，使用二层VIP时，您必须保证VIP候选实例处于同一个二层网络（VLAN、交换机）下。



### `vip_reload`

是否重载VIP配置, 类型：`bool`，层级：A，默认值为：`true`





### `vip_address`

集群使用的VIP地址, 类型：`string`，层级：C，默认值为：





### `vip_cidrmask`

VIP地址的网络CIDR掩码长度, 类型：`int`，层级：C，默认值为：





### `vip_interface`

VIP使用的网卡, 类型：`string`，层级：C/I，默认值为：





### `dns_mode`

DNS配置模式（保留参数）, 类型：`enum`，层级：C，默认值为：





### `dns_selector`

DNS解析对象选择器（保留参数）, 类型：`string`，层级：C，默认值为：