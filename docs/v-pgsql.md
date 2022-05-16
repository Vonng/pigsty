# Config: PGSQL

> Use the [PGSQL Playbook](p-pgsql.md), and [deploy the PGSQL](d-pgsql.md) cluster to adjust the cluster state to the state described in the [ PGSQL config](v-pgsql.md).

Pigsty has 100+ config parameters for describing a PostgreSQL cluster. However, users usually only need to care about a few parameters in [identity params](#PG_IDENTITY) and [business objects](#PG_BUSINESS): the former expresses the database cluster "Who is it? Where is it?" and the latter represents the database "What does it look like? What's in it?".

The params on the PostgreSQL are divided into seven main sections：

- [`PG_IDENTITY`](#PG_IDENTITY): Defining the identity of a PostgreSQL cluster.
- [`PG_BUSINESS`](#PG_BUSINESS): Customized cluster templates: users, databases, services, privilege rules.
- [`PG_INSTALL`](#PG_INSTALL): Install PostgreSQL pkgs, extension plugins, and prepare dir and tool scripts.
- [`PG_BOOTSTRP`](#PG_BOOTSTRAP): Generate config template, pull up PostgreSQL cluster, build M-S replication, and enable connection pooling.
- [`PG_PROVISION`](#PG_PROVISION): PGSQL cluster template provisioning, creating users and databases, configuring privileges role HBA, mode and extensions.
- [`PG_EXPORTER`](#PG_EXPORTER): PGSQL-exporter, database, and connection pool config monitoring component.
- [`PG_SERVICE`](#PG_SERVICE): Expose the PostgreSQL service, install the LB HAProxy, enable VIP, and configure DNS.


| ID  | Name                                                            |             Section             | Type        | Level | Comment                            |
|-----|-----------------------------------------------------------------|---------------------------------|-------------|-------|------------------------------------|
| 500 | [`pg_cluster`](#pg_cluster)                                     | [`PG_IDENTITY`](#PG_IDENTITY)   | string      | C     | PG Cluster Name                    |
| 501 | [`pg_shard`](#pg_shard)                                         | [`PG_IDENTITY`](#PG_IDENTITY)   | string      | C     | PG Shard Name (Reserve)            |
| 502 | [`pg_sindex`](#pg_sindex)                                       | [`PG_IDENTITY`](#PG_IDENTITY)   | int         | C     | PG Shard Index (Reserve)           |
| 503 | [`gp_role`](#gp_role)                                           | [`PG_IDENTITY`](#PG_IDENTITY)   | enum        | C     | gp role of this PG cluster         |
| 504 | [`pg_role`](#pg_role)                                           | [`PG_IDENTITY`](#PG_IDENTITY)   | enum        | I     | PG Instance Role                   |
| 505 | [`pg_seq`](#pg_seq)                                             | [`PG_IDENTITY`](#PG_IDENTITY)   | int         | I     | PG Instance Sequence               |
| 506 | [`pg_instances`](#pg_instances)                                 | [`PG_IDENTITY`](#PG_IDENTITY)   | {port:ins}  | I     | PG instance on this node           |
| 507 | [`pg_upstream`](#pg_upstream)                                   | [`PG_IDENTITY`](#PG_IDENTITY)   | string      | I     | PG upstream IP                     |
| 508 | [`pg_offline_query`](#pg_offline_query)                         | [`PG_IDENTITY`](#PG_IDENTITY)   | bool        | I     | allow offline query?               |
| 509 | [`pg_backup`](#pg_backup)                                       | [`PG_IDENTITY`](#PG_IDENTITY)   | bool        | I     | make base backup on this ins?      |
| 510 | [`pg_weight`](#pg_weight)                                       | [`PG_IDENTITY`](#PG_IDENTITY)   | int         | I     | relative weight in LB              |
| 511 | [`pg_hostname`](#pg_hostname)                                   | [`PG_IDENTITY`](#PG_IDENTITY)   | bool        | C/I   | set PG ins name as hostname        |
| 512 | [`pg_preflight_skip`](#pg_preflight_skip)                       | [`PG_IDENTITY`](#PG_IDENTITY)   | bool        | C/A   | skip preflight param validation    |
| 520 | [`pg_users`](#pg_users)                                         | [`PG_BUSINESS`](#PG_BUSINESS)   | user[]      | C     | business users definition          |
| 521 | [`pg_databases`](#pg_databases)                                 | [`PG_BUSINESS`](#PG_BUSINESS)   | database[]  | C     | business databases definition      |
| 522 | [`pg_services_extra`](#pg_services_extra)                       | [`PG_BUSINESS`](#PG_BUSINESS)   | service[]   | C     | ad hoc service definition          |
| 523 | [`pg_hba_rules_extra`](#pg_hba_rules_extra)                     | [`PG_BUSINESS`](#PG_BUSINESS)   | rule[]      | C     | ad hoc HBA rules                   |
| 524 | [`pgbouncer_hba_rules_extra`](#pgbouncer_hba_rules_extra)       | [`PG_BUSINESS`](#PG_BUSINESS)   | rule[]      | C     | ad hoc pgbouncer HBA rules         |
| 525 | [`pg_admin_username`](#pg_admin_username)                       | [`PG_BUSINESS`](#PG_BUSINESS)   | string      | G     | admin user's name                  |
| 526 | [`pg_admin_password`](#pg_admin_password)                       | [`PG_BUSINESS`](#PG_BUSINESS)   | string      | G     | admin user's password              |
| 527 | [`pg_replication_username`](#pg_replication_username)           | [`PG_BUSINESS`](#PG_BUSINESS)   | string      | G     | replication user's name            |
| 528 | [`pg_replication_password`](#pg_replication_password)           | [`PG_BUSINESS`](#PG_BUSINESS)   | string      | G     | replication user's password        |
| 529 | [`pg_monitor_username`](#pg_monitor_username)                   | [`PG_BUSINESS`](#PG_BUSINESS)   | string      | G     | monitor user's name                |
| 530 | [`pg_monitor_password`](#pg_monitor_password)                   | [`PG_BUSINESS`](#PG_BUSINESS)   | string      | G     | monitor user's password            |
| 540 | [`pg_dbsu`](#pg_dbsu)                                           | [`PG_INSTALL`](#PG_INSTALL)     | string      | C     | os dbsu for postgres               |
| 541 | [`pg_dbsu_uid`](#pg_dbsu_uid)                                   | [`PG_INSTALL`](#PG_INSTALL)     | int         | C     | dbsu UID                           |
| 542 | [`pg_dbsu_sudo`](#pg_dbsu_sudo)                                 | [`PG_INSTALL`](#PG_INSTALL)     | enum        | C     | sudo priv mode for dbsu            |
| 543 | [`pg_dbsu_home`](#pg_dbsu_home)                                 | [`PG_INSTALL`](#PG_INSTALL)     | path        | C     | home dir for dbsu                  |
| 544 | [`pg_dbsu_ssh_exchange`](#pg_dbsu_ssh_exchange)                 | [`PG_INSTALL`](#PG_INSTALL)     | bool        | C     | exchange dbsu ssh keys?            |
| 545 | [`pg_version`](#pg_version)                                     | [`PG_INSTALL`](#PG_INSTALL)     | int         | C     | major PG version to be installed   |
| 546 | [`pgdg_repo`](#pgdg_repo)                                       | [`PG_INSTALL`](#PG_INSTALL)     | bool        | C     | add official PGDG repo?            |
| 547 | [`pg_add_repo`](#pg_add_repo)                                   | [`PG_INSTALL`](#PG_INSTALL)     | bool        | C     | add extra upstream PG repo?        |
| 548 | [`pg_bin_dir`](#pg_bin_dir)                                     | [`PG_INSTALL`](#PG_INSTALL)     | path        | C     | PG binary dir                      |
| 549 | [`pg_packages`](#pg_packages)                                   | [`PG_INSTALL`](#PG_INSTALL)     | string[]    | C     | PG packages to be installed        |
| 550 | [`pg_extensions`](#pg_extensions)                               | [`PG_INSTALL`](#PG_INSTALL)     | string[]    | C     | PG extension pkgs to be installed  |
| 560 | [`pg_safeguard`](#pg_safeguard)                                 | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | bool        | C/A   | disable pg instance purge          |
| 561 | [`pg_clean`](#pg_clean)                                         | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | bool        | C/A   | purge existing pgsql during init   |
| 562 | [`pg_data`](#pg_data)                                           | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | path        | C     | pg data dir                        |
| 563 | [`pg_fs_main`](#pg_fs_main)                                     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | path        | C     | pg main data disk mountpoint       |
| 564 | [`pg_fs_bkup`](#pg_fs_bkup)                                     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | path        | C     | pg backup disk mountpoint          |
| 565 | [`pg_dummy_filesize`](#pg_dummy_filesize)                       | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | size        | C     | /pg/dummy file size                |
| 566 | [`pg_listen`](#pg_listen)                                       | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | ip          | C     | pg listen IP                       |
| 567 | [`pg_port`](#pg_port)                                           | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | int         | C     | pg listen port                     |
| 568 | [`pg_localhost`](#pg_localhost)                                 | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | ip          | path  | pg's UnixSocket address            |
| 580 | [`patroni_enabled`](#patroni_enabled)                           | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | bool        | C     | Is patroni & postgres enabled?     |
| 581 | [`patroni_mode`](#patroni_mode)                                 | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | enum        | C     | patroni working mode               |
| 582 | [`pg_dcs_type`](#pg_dcs_type)                                   | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | enum        | G     | dcs to be used consul/etcd         |
| 583 | [`pg_namespace`](#pg_namespace)                                 | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | path        | C     | namespace for patroni              |
| 584 | [`patroni_port`](#patroni_port)                                 | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | int         | C     | patroni listen port (8080)         |
| 585 | [`patroni_watchdog_mode`](#patroni_watchdog_mode)               | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | enum        | C     | patroni watchdog policy            |
| 586 | [`pg_conf`](#pg_conf)                                           | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | string      | C     | patroni template                   |
| 587 | [`pg_libs`](#pg_libs)                                           | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | string      | C     | default preload shared database    |
| 588 | [`pg_delay`](#pg_delay)                                         | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | interval    | I     | apply delay for standby leader     |
| 589 | [`pg_checksum`](#pg_checksum)                                   | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | bool        | C     | enable data checksum               |
| 590 | [`pg_encoding`](#pg_encoding)                                   | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | enum        | C     | character encoding                 |
| 591 | [`pg_locale`](#pg_locale)                                       | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | enum        | C     | locale                             |
| 592 | [`pg_lc_collate`](#pg_lc_collate)                               | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | enum        | C     | collate rule of locale             |
| 593 | [`pg_lc_ctype`](#pg_lc_ctype)                                   | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | enum        | C     | ctype of locale                    |
| 594 | [`pgbouncer_enabled`](#pgbouncer_enabled)                       | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | bool        | C     | is pgbouncer enabled               |
| 595 | [`pgbouncer_port`](#pgbouncer_port)                             | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | int         | C     | pgbouncer listen port              |
| 596 | [`pgbouncer_poolmode`](#pgbouncer_poolmode)                     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | enum        | C     | pgbouncer pooling mode             |
| 597 | [`pgbouncer_max_db_conn`](#pgbouncer_max_db_conn)               | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | int         | C     | max connection per database        |
| 600 | [`pg_provision`](#pg_provision)                                 | [`PG_PROVISION`](#PG_PROVISION) | bool        | C     | provision template to pgsql?       |
| 601 | [`pg_init`](#pg_init)                                           | [`PG_PROVISION`](#PG_PROVISION) | string      | C     | path to postgres init script       |
| 602 | [`pg_default_roles`](#pg_default_roles)                         | [`PG_PROVISION`](#PG_PROVISION) | role[]      | G/C   | list or global default roles/users |
| 603 | [`pg_default_privilegs`](#pg_default_privilegs)                 | [`PG_PROVISION`](#PG_PROVISION) | string[]    | G/C   | list of default privileges         |
| 604 | [`pg_default_schemas`](#pg_default_schemas)                     | [`PG_PROVISION`](#PG_PROVISION) | string[]    | G/C   | list of default modes              |
| 605 | [`pg_default_extensions`](#pg_default_extensions)               | [`PG_PROVISION`](#PG_PROVISION) | extension[] | G/C   | list of default extensions         |
| 606 | [`pg_reload`](#pg_reload)                                       | [`PG_PROVISION`](#PG_PROVISION) | bool        | A     | reload config?                     |
| 607 | [`pg_hba_rules`](#pg_hba_rules)                                 | [`PG_PROVISION`](#PG_PROVISION) | rule[]      | G/C   | global HBA rules                   |
| 608 | [`pgbouncer_hba_rules`](#pgbouncer_hba_rules)                   | [`PG_PROVISION`](#PG_PROVISION) | rule[]      | G/C   | global pgbouncer HBA rules         |
| 620 | [`pg_exporter_config`](#pg_exporter_config)                     | [`PG_EXPORTER`](#PG_EXPORTER)   | string      | C     | pg_exporter config path            |
| 621 | [`pg_exporter_enabled`](#pg_exporter_enabled)                   | [`PG_EXPORTER`](#PG_EXPORTER)   | bool        | C     | pg_exporter enabled ?              |
| 622 | [`pg_exporter_port`](#pg_exporter_port)                         | [`PG_EXPORTER`](#PG_EXPORTER)   | int         | C     | pg_exporter listen address         |
| 623 | [`pg_exporter_params`](#pg_exporter_params)                     | [`PG_EXPORTER`](#PG_EXPORTER)   | string      | C/I   | extra params for pg_exporter url   |
| 624 | [`pg_exporter_url`](#pg_exporter_url)                           | [`PG_EXPORTER`](#PG_EXPORTER)   | string      | C/I   | monitor target pgurl (overwrite)   |
| 625 | [`pg_exporter_auto_discovery`](#pg_exporter_auto_discovery)     | [`PG_EXPORTER`](#PG_EXPORTER)   | bool        | C/I   | enable auto-database-discovery?    |
| 626 | [`pg_exporter_exclude_database`](#pg_exporter_exclude_database) | [`PG_EXPORTER`](#PG_EXPORTER)   | string      | C/I   | excluded list of databases         |
| 627 | [`pg_exporter_include_database`](#pg_exporter_include_database) | [`PG_EXPORTER`](#PG_EXPORTER)   | string      | C/I   | included list of databases         |
| 628 | [`pg_exporter_options`](#pg_exporter_options)                   | [`PG_EXPORTER`](#PG_EXPORTER)   | string      | C/I   | cli args for pg_exporter           |
| 629 | [`pgbouncer_exporter_enabled`](#pgbouncer_exporter_enabled)     | [`PG_EXPORTER`](#PG_EXPORTER)   | bool        | C     | pgbouncer_exporter enabled ?       |
| 630 | [`pgbouncer_exporter_port`](#pgbouncer_exporter_port)           | [`PG_EXPORTER`](#PG_EXPORTER)   | int         | C     | pgbouncer_exporter listen addr?    |
| 631 | [`pgbouncer_exporter_url`](#pgbouncer_exporter_url)             | [`PG_EXPORTER`](#PG_EXPORTER)   | string      | C/I   | target pgbouncer url (overwrite)   |
| 632 | [`pgbouncer_exporter_options`](#pgbouncer_exporter_options)     | [`PG_EXPORTER`](#PG_EXPORTER)   | string      | C/I   | cli args for pgbouncer exporter    |
| 640 | [`pg_services`](#pg_services)                                   | [`PG_SERVICE`](#PG_SERVICE)     | service[]   | G/C   | global service definition          |
| 641 | [`haproxy_enabled`](#haproxy_enabled)                           | [`PG_SERVICE`](#PG_SERVICE)     | bool        | C/I   | haproxy enabled ?                  |
| 642 | [`haproxy_reload`](#haproxy_reload)                             | [`PG_SERVICE`](#PG_SERVICE)     | bool        | A     | haproxy reload instead of reset    |
| 643 | [`haproxy_auth_enabled`](#haproxy_auth_enabled)                 | [`PG_SERVICE`](#PG_SERVICE)     | bool        | G/C   | enable auth for haproxy admin ?    |
| 644 | [`haproxy_admin_username`](#haproxy_admin_username)             | [`PG_SERVICE`](#PG_SERVICE)     | string      | G     | haproxy admin user name            |
| 645 | [`haproxy_admin_password`](#haproxy_admin_password)             | [`PG_SERVICE`](#PG_SERVICE)     | string      | G     | haproxy admin password             |
| 646 | [`haproxy_exporter_port`](#haproxy_exporter_port)               | [`PG_SERVICE`](#PG_SERVICE)     | int         | C     | haproxy exporter listen port       |
| 647 | [`haproxy_client_timeout`](#haproxy_client_timeout)             | [`PG_SERVICE`](#PG_SERVICE)     | interval    | C     | haproxy client timeout             |
| 648 | [`haproxy_server_timeout`](#haproxy_server_timeout)             | [`PG_SERVICE`](#PG_SERVICE)     | interval    | C     | haproxy server timeout             |
| 649 | [`vip_mode`](#vip_mode)                                         | [`PG_SERVICE`](#PG_SERVICE)     | enum        | C     | vip working mode                   |
| 650 | [`vip_reload`](#vip_reload)                                     | [`PG_SERVICE`](#PG_SERVICE)     | bool        | A     | reload vip configuration           |
| 651 | [`vip_address`](#vip_address)                                   | [`PG_SERVICE`](#PG_SERVICE)     | string      | C     | vip address used by cluster        |
| 652 | [`vip_cidrmask`](#vip_cidrmask)                                 | [`PG_SERVICE`](#PG_SERVICE)     | int         | C     | vip network CIDR length            |
| 653 | [`vip_interface`](#vip_interface)                               | [`PG_SERVICE`](#PG_SERVICE)     | string      | C     | vip network interface name         |
| 654 | [`dns_mode`](#dns_mode)                                         | [`PG_SERVICE`](#PG_SERVICE)     | enum        | C     | cluster DNS mode                   |
| 655 | [`dns_selector`](#dns_selector)                                 | [`PG_SERVICE`](#PG_SERVICE)     | string      | C     | cluster DNS ins selector           |





----------------

## `PG_IDENTITY`

[`pg_cluster`](#pg_cluster), [`pg_role`](#pg_role), [`pg_seq`](#pg_seq) belong to **identity params** .

In addition to the IP, these three parameters are the minimum set of parameters necessary to define a new set of clusters. A typical example is shown below:

```yaml
pg-test:
  hosts:
    10.10.10.11: {pg_seq: 1, pg_role: replica}
    10.10.10.12: {pg_seq: 2, pg_role: primary}
    10.10.10.13: {pg_seq: 3, pg_role: replica}
  vars:
    pg_cluster: pg-test
```

All other params can be inherited from the global config or the default config, but the identity params must be **explicitly specified** and **manually assigned**. The current PGSQL identity params are as follows:

|            Name             |   Type   | Level | Description                                            |
| :-------------------------: | :------: | :---: | ------------------------------------------------------ |
| [`pg_cluster`](#pg_cluster) | `string` | **C** | **PG database cluster name**                           |
|     [`pg_seq`](#pg_seq)     | `number` | **I** | **PG database ins serial number**                      |
|    [`pg_role`](#pg_role)    |  `enum`  | **I** | **PG database ins role**                               |
|   [`pg_shard`](#pg_shard)   | `string` | **C** | **PG database slice set cluster name** (placeholder)   |
|  [`pg_sindex`](#pg_sindex)  | `number` | **C** | **PG database slice set cluster number** (placeholder) |

* [`pg_cluster`](#pg_cluster): It identifies the name of the cluster, which is configured at the cluster level.
* [`pg_role`](#pg_role): Configured at the instance level, identifies the role of the ins. Only the `primary` role will be handled specially. If not filled in, the default is the `replica` role and the special `delayed` and `offline` roles.
* [`pg_seq`](#pg_seq): Used to identify the ins within the cluster, usually with an integer number incremented from 0 or 1, which is not changed once it is assigned.
* `{{ pg_cluster }}-{{ pg_seq }}` is used to uniquely identify the ins, i.e. `pg_instance`.
* `{{ pg_cluster }}-{{ pg_role }}` is used to identify the services within the cluster, i.e. `pg_service`.
* [`pg_shard`](#pg_shard) and [`pg_sindex`](#pg_sindex) are used for horizontally sharding clusters, reserved for Citus and Greenplum multicluster management.





### `pg_cluster`

PG cluster name, type: `string`, level: cluster, no default. **A mandatory parameter must be provided by the user**.

The cluster name will be used as the namespace for the resources within the cluster. The naming needs to follow a specific naming pattern: `[a-z][a-z0-9-]*` to be compatible with the requirements of different constraints on the identity.




### `pg_shard`

Shard to which the PG cluster belongs (reserved), type: `string`, level: cluster, No default.

Only sharding clusters require this parameter to be set. When multiple clusters serve the same business in a horizontally sharded fashion, Pigsty refers to this group of clusters as a **Sharding Cluster**.

`pg_shard` is the name of the shard set cluster to which the cluster belongs. A shard set cluster can be specified with any name, but Pigsty recommends a meaningful naming pattern.

For example, a cluster participating in a sharded cluster can use the shard cluster name [`pg_shard`](#pg_shard) + `shard` + the cluster's shard number [`pg_sindex`](#pg_sindex) to form the cluster name：

```
shard:  test
pg-testshard1
pg-testshard2
pg-testshard3
pg-testshard4
```




### `pg_sindex`

PG cluster's slice number (reserved), type: `int`, level: C, no default.

The sharded cluster's slice number, used in conjunction with [pg_shard](#pg_shard) is usually assigned sequentially starting from 0 or 1. Only sharded clusters require this param to be set.




### `gp_role`

Current role of PG cluster in GP, type: `enum`, level: C, default value：

Greenplum/MatrixDB-specific to specify the role this PG cluster plays in a GP deployment. The optional values are ：
* `master`: Facilitator Nodes
* `segment`: Data Nodes

**Identity parameter**, **cluster level parameter**, and **mandatory parameter** when deploying GPSQL.



### `pg_role`

PG instance role, type: `enum`, level: I, no default,  **mandatory parameter, must be provided by the user.**

Roles for PG ins, default roles include   `primary`, `replica`, and `offline`.

* `primary`: Primary, there must be one and only one member of the cluster as `primary`.
* `replica`: Replica for carrying online read-only traffic.
* `offline`: Offline replica for taking on offline read-only traffic, such as statistical analysis/ETL/personal queries, etc.

**Identity params, required params, and instance-level params.**



### `pg_seq`

PG ins serial number, type: `int`, level: I, no default value,  **mandatory parameter, must be provided by the user.**

A serial number of the database ins, unique within the **cluster**, is used to distinguish and identify different instances within the cluster, assigned starting from 0 or 1.



### `pg_instances`

All PG instances on the current node, type: `{port:ins}`, level: I, default value：

This parameter can be used to describe when the node is deployed by more than one PG ins, such as Greenplum's Segments, or when using [monly mode](d-monly.md) to supervise existing ins.
[`pg_instances`](#pg_instances) is an array of objects with keys as ins ports and values as a dictionary whose contents can be parameters of any [`PGSQL`](v-pgsql.md) board, see [MatrixDB deploy](d-matrixdb.md) for details.





### `pg_upstream`

The replicated upstream node of the instance, type: `string`, level: I, the default value is null.

Ins-level config entry with IP or hostname to indicate the upstream node for stream replication.

* When configuring this parameter for a replica, the IP filled in must be another node within the cluster. Instances will be stream replicated from that node, and this option can be used to build **cascaded replication**.

* When this parameter is configured for the primary of the cluster, it means that the entire cluster will run as a **Standby Cluster**, receiving changes from upstream nodes. The `primary` in the cluster will play the role of `standby leader`.

Using this parameter flexibly, you can build a standby cluster, complete the splitting of the sharded cluster, and realize the delayed cluster.



### `pg_offline_query`

Allow offline queries, type: `bool`, level: I, default value: `false`.

When set to `true`, the user group `dbrole_offline` can connect to the ins and perform offline queries, regardless of the role of the current ins.

More practical for cases with a small number of ins (one primary & one replica), the user can mark the only replica as `pg_offline_query = true`, thus accepting ETL, slow queries with interactive access.



### `pg_backup`

Store cold standbys on the ins, type: `bool`, level: I, default value: `false`.

Not implemented, the tag bit is reserved and the ins node with this tag is used to store the base cold standby.



### `pg_weight`

The relative weight of the ins in load balancing, type: `int`, level: I, default value: `100`.

When adjusting the relative weight of an instance in service, this parameter can be modified at the instance level and applied to take effect as described in [SOP: Cluster Traffic Adjustment](r-sop.md).



### `pg_hostname`

Set PG ins name to HOSTNAME, type: `bool`, level: C/I, default value: `false`, which is true by default in the demo.

Use the PG ins name and cluster name as the node's name and cluster name when initializing the nodean , disabled by default.

When using the node: PG 1:1 exclusive deploy mode, you can assign the identity of the PG ins to the node, making the node consistent with the PG's monitor identity.



### `pg_preflight_skip`

Skip preflight param validation, type: `bool`, level: C/A, default value: `false`.

If not initializing a new cluster, the task of Patroni and Postgres initialization can be completely skipped with this parameter.





----------------
## `PG_BUSINESS`

Users need to **focus on** this part of the parameters to declare their required database objects on behalf of the business.

Customized cluster templates: users, databases, services, privilege patterns.

* Business User Definition: [`pg_users`](#pg_users)                                   
* Business Database Definition: [`pg_databases`](#pg_databases)                           
* Cluster Proprietary Services Definition: [`pg_services_extra`](#pg_services_extra)                 
* Cluster/ins specific HBA rules: [`pg_hba_rules_extra`](#pg_hba_rules_extra)               
* Pgbounce specific HBA rules: [`pgbouncer_hba_rules_extra`](#pgbouncer_hba_rules_extra) 

Special DB users, it is recommended to change these user passwords in the production env.

* PG Admin User: [`pg_admin_username`](#pg_admin_username) / [`pg_admin_password`](#pg_admin_password)
* PG Replication User:  [`pg_replication_username`](#pg_replication_username) / [`pg_replication_password`](#pg_replication_password)
* PG Monitor Users: [`pg_monitor_username`](#pg_monitor_username) / [`pg_monitor_password`](#pg_monitor_password)




### `pg_users`

Business user definition, type: `user[]`, level: C, default value is an empty array.

Used to define business users at the cluster level, each object in the array defines a [user or role](c-pgdbuser#users), a complete user definition is as follows:

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

* Each user or role must specify a `name` and the rest of the fields are **optional**, a `name` must be unique in this list.
* `password` is optional, if left blank then no password is set, you can use the MD5 ciphertext password.
* `login`, `superuser`, `createdb`, `createrole`, `inherit`, `replication` and ` bypassrls` are all boolean types used to set user attributes. If not set, the system defaults are used.
* Users are created by `CREATE USER`, so they have the `login` attribute by default. If the role is created, you need to specify `login: false`.
* `expire_at` and `expire_in` are used to control the user expiration time. `expire_at` uses a date timestamp in the shape of `YYYY-mm-DD`. `expire_in` uses the number of days to expire from now, and overrides the `expire_at` option if `expire_in` exists.
* New users are **not** added to the Pgbouncer user list by default, and `pgbouncer: true` must be explicitly defined for the user to be added to the Pgbouncer user list.
* Users/roles are created sequentially, and users defined later can belong to the roles defined earlier.
* Users can add [default privilegs](#pg_default_privilegs) groups for business users via the `roles` field:
    * `dbrole_readonly`: Default production read-only user with global read-only privileges. (Read-only production access)
    * `dbrole_offline`: Default offline read-only user with read-only access on a specific ins. (offline query, personal account, ETL)
    * `dbrole_readwrite`: Default production read/write user with global CRUD privileges. (Regular production use)
    * `dbrole_admin`: Default production management user with the privilege to execute DDL changes. (Admin User)

Configure `pgbouncer: true` for the production account to allow it to access through the connection pool; regular users should not access the database through the connection pool.





### `pg_databases`

Business database definition, type: `database[]`, level: C, default value is an empty array.

Used to define business users at the cluster level, each object in the array defines a [business database](c-pgdbuser#database), a complete database definition as follows:

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

In each DB definition, the DB  `name` is mandatory and the rest are optional.

* `name`: Database name, **Must**.
* `owner`: Database owner, default is `postgres`
* `template`: The template used for database creation, default is `template1`.
* `encoding`: The default character encoding of the database, which is `UTF8` by default, is consistent with the ins by default. It is recommended not to configure and modify it.
* `locale`: The default localization rule for the database, which defaults to `C`, is recommended not to be configured to be consistent with the instance.
* `lc_collate`: The default localized string sorting rule for the database, which is set the same as the instance by default, should not be modified and must be consistent with the DB template. It is strongly recommended not to configure, or configure to `C`.
* `lc_ctype`: The default LOCALE of the database, by default, is the same as the ins setting, do not modify or set it, it must be consistent with the DB template. Configure to C or `en_US.UTF8`.
* `allowconn`: Allow database connection, default is `true`, not recommended to change.
* `revokeconn`: Reclaim privilege to connect to the database. The default is `false`. To be `true`, the `PUBLIC CONNECT` privilege on the database will be reclaimed. Only the default user (`dbsu|monitor|admin|replicator|owner`) can connect. In addition, the `admin|owner` will have GRANT OPTION, which can give other users connection privileges.
* `tablespace`: The tablespace associated with the database, the default is `pg_default`.
* `connlimit`: Database connection limit, default is `-1`, i.e. no limit.
* `extensions`: An array of objects, each of which defines an **extension** in the database, and its installed **mode**.
* `parameters`: K-V objects, each K-V defines a parameter that needs to be modified against the database via `ALTER DATABASE`.
* `pgbouncer`: Boolean option to join this database to Pgbouncer or not. All databases are joined to Pgbouncer unless `pgbouncer: false` is explicitly specified.
* `comment`: Database note information.






### `pg_services_extra`

Cluster Proprietary Service Definition, Type: `service[]`, Level: C, Default:

Used to define additional services at the cluster level, each object in the array defines a [service](c-service#service), a complete service definition is as follows:

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

Each cluster can define multiple services, each containing any number of cluster members. Services are distinguished by **port**, `name`, and `src_port` are mandatory and must be unique within the array.

**MUST OPTION**

* **Name（`service.name`）**：

  The full name of the service is prefixed by the cluster name and suffixed by `service.name`, connected by `-`. For example, the service with `name=primary` in the `pg-test` cluster has the full-service name `pg-test-primary`.

* **Port（`service.port`）**：

  In Pigsty, services are exposed to the public by default in the form of NodePort, so exposing the port is mandatory. However, if you use an external LB service access scheme, you can also differentiate the services in other ways.

* **Selector（`service.selector`）**：

  The **selector** specifies the ins members of the service, in the form of JMESPath, filtering variables from all cluster ins members. The default `[]` selector will pick all cluster members.

**Optional**

* **Backup Selector（`service.selector`）**：

  The optional **backup selector** `service.selector_backup` selects or marks the list of ins used for service backup, i.e. the backup ins take over the service only when all other members of the cluster fail. For example, the `primary` ins can be added to the `replica` service's alternative set, so that the primary can still carry the cluster's read-only traffic when all replicas fail.

* **Source IP（`service.src_ip`）** ：

  Indicates the IP used externally by the **service**. The default is `*`, which is all IPs on the local. Using `vip` will use the `vip_address` variable to take the value, or you can fill in the specific IP supported by the NIC.

* **Host port（`service.dst_port`）**：

  Which port on the target ins will the service's traffic be directed to? `postgres` will point to the port the database is listening on, `pgbouncer` will point to the port the connection pool is listening on, or you can fill in a fixed port.

* **Health Check method（`service.check_method`）**:

  How does the service check the health status of the instance? Currently, only HTTP is supported.

* **Health Check Port（`service.check_port`）**:

  Which port of the service check-ins gets the health status of the ins? `patroni` will get it from Patroni (default 8008), `pg_exporter` will get it from PG Exporter (default 9630), or you can fill in a custom port.

* **Health Check Path（`service.check_url`）**:

  The service performs HTTP checks using the URL PATH. `/` is used as a health check by default, and PG Exporter and Patroni provide a variety of health checks that can be used to differentiate between primary & replica traffic. For example, `/primary` will only return success for the primary, and `/replica` will only return success for the replica. `/read-only` will return success for any instance that supports read-only (including the primary).

* **Health Check Code（`service.check_code`）**:

  The code expected by the HTTP health check, default is 200.

* **Haproxy Specific Placement（`service.haproxy`）** ：

  Proprietary config entries for service provisioning software (HAproxy).

  * `<service>.haproxy`

  These parameters are now defined in [**service**](c-service.md#service), using `service.haproxy` to override the parameter config of the ins.

  * `maxconn`

  HAProxy maximum number of front and back-end connections, default is 3000.

  * `balance`

  In the algorithm used by haproxy LB, the optional policy is `roundrobin`, and `leastconn`, the default is `roundrobin`.

  * `default_server_options`

  Default options for Haproxy backend server ins:

  `'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'`








### `pg_hba_rules_extra`

Cluster/ins specific HBA rule, Type: `rule[]`, Level: C, Default:

Set the client IP black and white list rules for the database. An array of objects, each of which represents a rule, each of which consists of three parts:

* `title`: Rule headings, which are converted to comments in the HBA file
* `role`: Apply for roles, `common` means apply to all instances, other values (e.g. `replica`, `offline`) will only be installed to matching roles. For example, `role='replica'` means that this rule will only be applied to instances with `pg_role == 'replica'`.
* `rules`: Array of strings, each record represents a rule that will eventually be written to `pg_hba.conf`.

As a special case, the HBA rule for `role == 'offline'` is additionally installed on instance of `pg_offline_query == true`.

[`pg_hba_rules`](#pg_hba_rules) is similar, but is typically used for global uniform HBA rule settings, and [`pg_hba_rules_extra`](#pg_hba_rules_extra) will **append** to `pg_hba.conf` in the same way.

If you need to completely **overwrite** the cluster's HBA rules and do not want to inherit the global HBA config, you should configure [`pg_hba_rules`](#pg_hba_rules) at the cluster level and override the global config.





### `pgbouncer_hba_rules_extra`

Pgbounce HBA rule, type: `rule[]`, level: C, default value is an empty array.

Similar to [`pg_hba_rules_extra`](#pg_hba_rules_extra) for extra config of Pgbouncer's HBA rules at the cluster level.







### `pg_admin_username`

PG admin user, type: `string`, level: G, default value: `"dbuser_dba"`.

The DB username is used to perform PG management tasks (DDL changes), with superuser privileges by default.

### `pg_admin_password`

PG admin user password, type: `string`, level: G, default value: `"DBUser.DBA"`.

The database user password used to perform PG management tasks (DDL changes) must be in plaintext. The default is `DBUser.DBA` and highly recommended changes!

It is highly recommended to change this parameter when deploying in production envs!



### `pg_replication_username`

PG replication user's name, type: `string`, level: G, default value: `"replicator"`.

For performing PostgreSQL stream replication, it is recommended to keep global consistency.

### `pg_replication_password`

PG's Replication User Password, type: `string`, level: G, default value: `"DBUser.Replicator"`.

The password of the database user used to perform PostgreSQL stream replication must be in plaintext. The default is `DBUser.Replicator`.

It is highly recommended to change this parameter when deploying in production envs!



### `pg_monitor_username`

PG monitor user, type: `string`, level: G, default value: `"dbuser_monitor"`.

The database user name is used to perform PostgreSQL and Pgbouncer monitoring tasks.



### `pg_monitor_password`

PG monitor user password, type: `string`, level: G, default value: `"DBUser.Monitor"`.

The password of the database user used to perform PostgreSQL and Pgbouncer monitoring tasks, must be in plaintext.

It is highly recommended to change this parameter when deploying in production envs!





----------------
## `PG_INSTALL`

PG Install is responsible for completing the installation of all PostgreSQL dependencies on a machine with the base software. The user can configure the name, ID, privileges, and access of the dbsu, configure the sources used for the installation, configure the installation address, the version to be installed, and the required pkgs and extensions plugins.

Such parameters only need to be modified when upgrading a major version of the database as a whole. Users can specify the software version to be installed via [`pg_version`](#pg_version) and override it at the cluster level to install different database versions for different clusters.





### `pg_dbsu`

PG OS dbsu, type: `string`, level: C, default value: `"postgres"`, not recommended to modify.

When installing Greenplum / MatrixDB, modify this parameter to the corresponding recommended value: `gpadmin|mxadmin`.


### `pg_dbsu_uid`

dbsu UID, type: `int`, level: C, default value: `26`.

UID of the dbsu is used by the database by default. The default value is `26`, consistent with the official RPM pkg-config of PG under CentOS, no modification is recommended.




### `pg_dbsu_sudo`

Sudo privilege for dbsu, type: `enum`, level: C, default value: `"limit"`.

* `none`: No Sudo privilege
* `limit`: Limited sudo privilege to execute systemctl commands for database-related components, default.
* `all`: Full `sudo` privilege, password required.
* `nopass`: Full `sudo` privileges without a password (not recommended).

The database superuser [`pg_dbsu`](#pg_dbsu) has restricted `sudo` privilege by default: `limit`.




### `pg_dbsu_home`

Home dir of dbsu [`pg_dbsu`](#pg_dbsu), type: `path`, level: C, default value: `"/var/lib/pgsql"`.



### `pg_dbsu_ssh_exchange`

Exchange the SSH key of dbsu [`pg_dbsu`](#pg_dbsu) between executing machines. Type: `bool`, Level: C, Default: `true`.

### `pg_version`

Installed major PG version, type: `int`, level: C, default value: `14`.

The current instance's installed a major PG version. Default is 14, supported as low as 10.

Note that PostgreSQL physical stream replication cannot span major versions, please configure this variable at the global/cluster level to ensure that all ins within the entire cluster have the same major version number.

### `pgdg_repo`

Add the official PG repo? , type: `bool`, level: C, default value: `false`.

Use this option to download and install PostgreSQL-related pkgs directly from official Internet repos without local repos.




### `pg_add_repo`

Add PG-related upstream repos? , type: `bool`, level: C, default value: `false`

If used, the official PGDG repo will be added before installing PostgreSQL.




### `pg_bin_dir`

PG binary dir, type: `path`, level: C, default value: `"/usr/pgsql/bin"`.

The default value is a softlink created manually during the installation process, pointing to the specific Postgres version dir installed.

For example `/usr/pgsql -> /usr/pgsql-14`. For more details, please see  [FHS](r-fhs.md).



### `pg_packages`

List of installed PG pkgs, type: `string[]`, level: C, default value:

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

`${pg_version}` will be replaced with the major PG version number [`pg_version`](#pg_version).





----------------
## `PG_BOOTSTRAP`

On a machine with Postgres, create a set of databases.

* **Cluster identity definition**, clean up existing ins, make dir, copy tools and scripts, configure environment variables.
* Render Patroni config templates, and pull up primary and replica using Patroni.
* Configure Pgbouncer, initialize the business users and database, and register the database and data source services to DCS.

With [`pg_conf`](#pg_conf) you can use the default cluster templates (OLTP / OLAP / CRIT / TINY). If you create a custom template, you can clone the default config in `roles/postgres/templates` and adapt it after modifying. Please refer to [customize pgsql cluster](v-pgsql-customize.md) for details.






### `pg_safeguard`

Assure that any running pg instance will not be purged by any [`pgsql`](p-pgsql.md) playbook., level: C/A, default: `false`

Check [SafeGuard](p-pgsql.md#SafeGuard) for details.



### `pg_clean`

Remove existing pg during node init? level: C/A, default: `false`

This allows the removal of any running pg instance during [`pgsql.yml`](#p-pgsql.md), which makes it a true idempotent playbook.

It's a dangerous option so you'd better disable it by default and use it with `-e` CLI args.

!> This parameter not working when [`pg_safeguard`](#pg_safeguard) is set to `true`




### `pg_data`

PG data dir, type: `path`, level: C, default value: `"/pg/data"`, not recommended to change.





### `pg_fs_main`

PG main data disk mountpoint, type: `path`, level: C, default value: `"/data"`.

Pigsty's default [dir structure](r-fhs.md) assumes that there is a main data disk mountpoint on the system that holds the DB dir along with another state.



### `pg_fs_bkup`

PG backup disk mountpoint, type: `path`, level: C, default value: `"/data/backups"`.

Pigsty's default [dir structure](r-fhs.md) assumes that there is a backup data disk mountpoint on the system that holds backup and archive data. However, users can also specify a sub-dir on the primary data disk as the backup disk home mountpoint.



### `pg_dummy_filesize`

Size of the file `/pg/dummy`, type: `size`, level: C, default value: `"64MiB"`.

A placeholder file is a pre-allocated empty file that takes up disk space. When the disk is full, removing the placeholder file can free up some space, it is recommended to use `4GiB`, `and 8GiB` for production env.





### `pg_listen`

PG listen IP address, type: `ip`, level: C, default value: `"0.0.0.0"`.

PG listen to IP address, default all IPv4 `0.0.0.0`, if you want to include all IPv6, you can use `*`.



### `pg_port`

PG listen to Port, type: `int`, level: C, default value: `5432`, not recommended to change.




### `pg_localhost`

PG's UnixSocket dir, type: `ip|path`, level: C, default value: `"/var/run/postgresql"`.

The Unix socket dir holds the Unix socket files for PostgreSQL and Pgbouncer, which are accessed through the local Unix socket when the client does not specify an IP to access the database.



### `patroni_enabled`

Enabled Patroni, type: `bool`, level: C, default value: `true`.

If disable, Pigsty will skip pulling up patroni. This option is used when setting up extra staff for an existing ins.



### `patroni_mode`

Patroni work mode, type: `enum`, level: C, default value: `"default"`.

* `default`: Enable Patroni to enter HA auto-switching mode.
* `pause`: Enable Patroni to automatically enter maintenance mode after completing initialization (no automatic M-S S switching).
* `remove`: Initialize the cluster with Patroni and remove Patroni after initialization.



### `pg_dcs_type`

Which type of DCS to be used, type: `enum`, hierarchy: G, default value: `"consul"`.

There are two available options: `consul` and `etcd`.

[`consul_enabled`](v-infra.md#consul_enabled) or [`etcd_enabled`](v-infra.md#etcd_enabled) should be true if default internal DCS are used.



### `pg_namespace`

DCS namespace used by Patroni, type: `path`, level: C, default value: `"/pg"`.





### `patroni_port`

Patroni listens to port, type: `int`, level: C, default value: `8008`.

The Patroni API server listens to the port for service and health checks to the public by default.




### `patroni_watchdog_mode`

Patroni Watchdog mode, type: `enum`, level: C, default value: `"automatic"`.

When an M-S switchover occurs, Patroni will try to shut down the primary before elevating the replica. If the primary is still not shut down within the specified time, Patroni will use the Linux kernel module `softdog` to fence shutdown according to the config.

* `off`: No using `watchdog`.
* `automatic`: Enable `watchdog` if the kernel has `softdog` enabled, not forced, default behavior.
* `required`: Force `watchdog`, or refuse to start if `softdog` is not enabled on the system.

Enabling Watchdog means that the system prioritizes ensuring data consistency and drops availability. If availability is more important to your system, it is recommended to turn off Watchdog on the meta node.




### `pg_conf`

Patroni's template, type: `string`, level: C, default value: `"tiny.yml"`

The [Patroni template](v-pgsql-customize.md) was used to pull up the Postgres cluster. Pigsty has 4 pre-built templates:

* [`oltp.yml`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/oltp.yml) Regular OLTP template, default config.
* [`olap.yml`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/olap.yml)OLAP templates to improve parallelism, optimize for throughput, and optimize for long-running queries.
* [`crit.yml`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/crit.yml) Core business templates, based on OLTP templates optimized for security, data integrity, using synchronous replication, forced to enable data checksum.
* [`tiny.yml`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/tiny.yml) Micro templates optimized for low-resource scenarios have demo clusters running in VMs.




### `pg_libs`

Shared database loaded by PG, type: `string`, level: C, default value: `"timescaledb, pg_stat_statements, auto_explain"`.

Fill in the string of the `shared_preload_libraries` parameter in the Patroni template to control the dynamic database that PG starts preloading. In the current version, the following databases are loaded by default: `timescaledb, pg_stat_statements, auand to_explain`.

If Citus support is enabled by default, you need to modify this parameter by adding `citus` to the first position: `citus, timescaledb, pg_stat_statements, auto_explain`.



### `pg_delay`

Apply delay for delayed standby cluster, type: `interval`, level: I, default: `0`

Specify a recovery min apply delay for [Delayed Replica](d-pgsql.md#延迟从库), can only be set on standby cluster initialization.



### `pg_checksum`

Enable data checksums? , type: `bool`, class: C , default: `"false"`

Data checksum is enforced when using `crit` template.




### `pg_encoding`

PG character set encoding, type: `enum`, level: C, default value: `"UTF8"`. It is not recommended to modify this parameter if there is no special need.



### `pg_locale`

The locale for PG, type: `enum`, level: C, default value: `"C"`.

It is not recommended to modify this parameter if there is no special need, improper sorting rules may have a significant impact on database performance.




### `pg_lc_collate`

Collate rule of locale, type: `enum`, level: C, default value: `"C"`.

Users can implement the localization sorting function by `COLLATE` expression, wrong localization sorting rule may cause exponential performance loss for some operations, please modify this parameter when you ensure there is a localization requirement.



### `pg_lc_ctype`

C-type of locale, type: `enum`, level: C, default value: `"en_US.UTF8"`

Some PG extensions (`pg_trgm`) require extra character classification definitions to work properly for internationalized characters, so Pigsty will use the `en_US.UTF8` character set definition by default, and it is not recommended to modify this parameter.



### `pgbouncer_enabled`

Enable Pgbouncer, type: `bool`, level: C, default value: `true`.




### `pgbouncer_port`

Pgbouncer listen port, type: `int`, level: C, default value: `6432`.




### `pgbouncer_poolmode`

Pgbouncer pooling mode, type: `int`, level: C, default value: `6432`.

* `transaction`, Transaction-level connection pooling, by default, has good performance but affects the use of PreparedStatements with some other session-level features.
* `session`, Session-level connection pooling for maximum compatibility.
* `statements`, Statement-level join pooling, consider using this pattern if the queries are all point-and-click.



### `pgbouncer_max_db_conn`

Max connection per database, type: `int`, level: C, default value: `100`.

When using Transaction Pooling mode, the number of active server connections is usually in single digits. If Session Pooling mode is used, this parameter can be increased appropriately.





----------------
## `PG_PROVISION`

[`PG_BOOTSTRAP`](#PG_BOOTSTRAP) is responsible for creating a completely new set of Postgres clusters, while [`PG_PROVISION`](#PG_PROVISION) is responsible for creating the default objects in this new set of database clusters, including:

* Basic roles: read-only role, read-write role, admin role
* Basic users: replica user, dbsu, monitor user, the admin user
* Default privileges in the template database
* Default mode
* Default Extensions
* HBA black and white list rules

Pigsty provides rich customization options, if you want to further customize the PG cluster, you can see [Customize: PGSQL Cluster](v-pgsql-customize.md).



### `pg_provision`

Provision template to pgsql (app template), type: `bool`, level: C, default: `true.`

Provision of the PostgreSQL cluster. Setting to false will skip the tasks defined by [`pg_provision`](#pg_provision). Note, however, that the creation of the four default dbsu, replication user, admin user, and monitor user is not affected by this.

### `pg_init`

Custom PG init script, type: `string`, level: C, default value: `"pg-init"`.

The path to pg-inits Shell script, which defaults to `pg-init`, is copied to `/pg/bin/pg-init` and then executed.

The default `pg-init` is just a wrapper for the SQL command:

* `/pg/tmp/pg-init-roles.sql`: Default role creation script generated from [`pg_default_roles`](#pg_default_roles).
* `/pg/tmp/pg-init-template.sql`: SQL commands produced according to [`pg_default_privileges`](#pg_default_privileges), [`pg_default_schemas`](#pg_default_schemas), [`pg_default_extensions`](#pg_default_extensions). Will be applied to both the default database template `template1` and the default admin `postgres`.

```bash
# system default roles
psql postgres -qAXwtf /pg/tmp/pg-init-roles.sql

# system default template
psql template1 -qAXwtf /pg/tmp/pg-init-template.sql

# make postgres same as templated database (optional)
psql postgres  -qAXwtf /pg/tmp/pg-init-template.sql
```

Users can add their cluster init logic in a custom `pg-init` script.





### `pg_default_roles`

List or global default roles/users, type: `role[]`, level: G/C, default value:

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

This parameter defines the [default role](c-privilege.md#default-roles) and [default user](c-privilege.md#default-users) in PostgreSQL in the form of an array of objects, which are defined in the same form as in [`pg_users`](#pg_users).






### `pg_default_privileges`

List of default privilegs, type: `string[]`, level: G/C, default value:

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

Please refer to [default privilege](c-privilege.md#privilege) for details.




### `pg_default_schemas`

List of default schemas, type: `string[]`, hierarchy: G/C, default value: `[monitor]`.

Pigsty creates a schema named `monitor` for installing monitoring extensions by default.




### `pg_default_extensions`

List of defalut extensions, array of objects, type `extension[]`, hierarchy: G/C, default value:

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

If the extension does not specify a `schema` field, the extension will install to the corresponding schema based on the current `search_path`, e.g., `public`.




### `pg_reload`

Reload Database Config (HBA), type: `bool`, level: A, default value: `true`.

When set to `true`, Pigsty will execute the `pg_ctl reload` application immediately after generating HBA rules.

When generating the `pg_hba.conf` file and manually comparing it before applying it to take effect, you can specify `-e pg_reload=false` to disable it.



### `pg_hba_rules`

PostgreSQL global HBA rule, type: `rule[]`, hierarchy: G/C, default value:

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

This parameter is formally identical to [`pg_hba_rules_extra`](#pg_hba_rules_extra), and it is recommended to configure a uniform [`pg_hba_rules`](#pg_hba_rules) globally and use [`pg_hba_rules_extra`](#pg_hba_rules_extra) for extra customization. The rules in both parameters are applied sequentially, with the latter taking higher priority.









### `pgbouncer_hba_rules`

PgbouncerL global HBA rule, type: `rule[]`, level: G/C, default value:

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

The default Pgbouncer HBA rules are simple:

1. Allow login from **local** with password
2. Allow password login from the intranet network break

Users can customize it.






----------------
## `PG_EXPORTER`

PG Exporter for monitoring Postgres with Pgbouncer connection pools.



### `pg_exporter_config`

PG-exporter config file, type: `string`, level: C, default value: `"pg_exporter.yml"`.

The default config file used by `pg_exporter` defines the database and connection pool monitor metrics in Pigsty. The default is [`pg_exporter.yml`](https://github.com/Vonng/pigsty/blob/master/roles/pg_exporter/files/pg_exporter.yml).

The PG-exporter config file used by Pigsty is supported by default from PostgreSQL 10.0 and is currently supported up to the latest PG 14 release. There are several of optional templates.

* [`pg_exporter_basic.yml`](https://github.com/Vonng/pigsty/blob/master/roles/pg_exporter/files/pg_exporter_basic.yml): contains only basic metrics, not Object monitor metrics within the database.
* [`pg_exporter_fast.yml`](https://github.com/Vonng/pigsty/blob/master/roles/pg_exporter/files/pg_exporter_fast.yml): metrics with shorter cache time definitions.


### `pg_exporter_enabled`

Enable PG-exporter, type: `bool`, level: C, default value: `true`.

Whether to install and configure `pg_exporter`, when `false`, the config of `pg_exporter` on the current node will be skipped, and this Exporter will be skipped when registering monitoring targets.



### `pg_exporter_port`

PG-exposure listen to Port, type: `int`, level: C, default value: `9630`.




### `pg_exporter_params`

Extra params for PG-exporter URL , type: `string`, level: C/I, default value: `"sslmode=disable"`.




### `pg_exporter_url`

Monitor target pgurl(override), type: `string`, level: C/I, default value: `""`.

The PG URL used by PG-exporter to connect to the database should be the URL to access the `postgres` managed database, which is configured as an environment variable in `/etc/default/pg_exporter`.

Optional param, defaults to the empty string, if the [`pg_exporter_url`](#pg_exporter_url) option is configured, the URL will be used directly as the monitor target pgurl. Otherwise, Pigsty will generate the target URL for monitoring using the following rule:

* [`pg_monitor_username`](#pg_monitor_username): Monitor User Name
* [`pg_monitor_password`](#pg_monitor_password): Monitor User password
* [`pg_localhost`](#pg_localhost): PG listen to Local IP or Unix Socket Dir
* [`pg_port`](#pg_port): PG Listen Port
* [`pg_exorter_params`](#pg_exporter_params): Extra Params for PG-exporter

The above params will be stitched together in the following manner:

```bash
postgres://{{ pg_monitor_username }}:{{ pg_monitor_password }}@:{{ pg_port }}/postgres{% if pg_exporter_params != '' %}?{{ pg_exporter_params }}{% if pg_localhost != '' %}&host={{ pg_localhost }}{% endif %}{% endif %}
```

If the [`pg_exporter_url`](#pg_exporter_url) param is specified, Exporter will use that connection string directly.

Note: When only a specific business database needs to be monitored, you can use the PGURL of that database directly. if you need to monitor **all** business databases on a particular database ins, it is recommended to use the PGURL of the meta database `postgres`.


### `pg_exporter_auto_discovery`

Auto-database-discovery, type: `bool`, level: C/I, default value: `true`.

Enable auto-database-discovery, enabled by default. When enabled, PG Exporter automatically detects changes to the list of databases and creates a crawl connection for each database.

When off, monitoring of objects in the library is not available.

!> Note that if you have many databases (100+) or a very large number of objects in the database (several k, a dozen), please carefully evaluate the overhead incurred by object monitoring.




### `pg_exporter_exclude_database`

DB auto-discovery exclusion list, type: `string`, level: C/I, default value: `"template0,template1,postgres"`.

Database name list, when auto-database-discovery is enabled, databases in this list **will not be monitored** (excluded from monitor objects).



### `pg_exporter_include_database`

Auto-database-discovery capsule list, type: `string`, level: C/I, default value: `""`.

Database name list, when auto-database-discovery is enabled, databases that are not in this column table will not be monitored.




### `pg_exporter_options`

Cli args for PG-exporter , type: `string`, level: C/I, default value:`"--log.level=info --log.format=\"logger:syslog?appname=pg_exporter&local=7\""`.




### `pgbouncer_exporter_enabled`

Pgbouncer-exporter enabled, type: `bool`, level: C, default value: `true`.




### `pgbouncer_exporter_port`

PGB-exporter listens to Port, type: `int`, level: C, default value: `9631`.





### `pgbouncer_exporter_url`

Monitor target pgurl, type: `string`, level: C/I, default value: `""`.

The DB's URL used by PGBouncer Exporter to connect, should be the URL to access the `pgbouncer` managed database. An optional parameter, default is the empty string.

Pigsty generates the target URL for monitoring by default using the following rules, if the `pgbouncer_exporter_url` option is configured, this URL will be used directly as the connection string.

```bash
PG_EXPORTER_URL='postgres://{{ pg_monitor_username }}:{{ pg_monitor_password }}@:{{ pgbouncer_port }}/pgbouncer?host={{ pg_localhost }}&sslmode=disable'
```

This option is configured as an environment variable in `/etc/default/pgbouncer_exporter`.





### `pgbouncer_exporter_options`

Cli args for PGB Exporter, type: `string`, level: C/I, default value: `"--log.level=info --log.format=\"logger:syslog?appname=pgbouncer_exporter&local=7\"`.

The INFO level log is about to be typed into syslog.





----------------
## `PG_SERVICE`

Listen to PostgreSQL service, install the load balancer HAProxy, enable VIP, and configure DNS.

### `pg_services`

Global generic PG service definition, type: `[]service`, level: G, default value:

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

An array consisting of [service definition](c-service.md#service) objects that define the services listened to the public. The form is consistent with [`pg_service_extra`](#pg_services_extra).




### `haproxy_enabled`

Enable Haproxy, type: `bool`, tier: C/I, default value: `true`.

Pigsty deploys Haproxy on all database nodes by default, enabling Haproxy LB only on specific instance/nodes by overriding ins-level variables.


### `haproxy_reload`

Reload Haproxy config, type: `bool`, level: A, default value: `true`.

If turned off, Pigsty will not perform Reload operation after rendering the HAProxy config file, and users can check it by themselves.




### `haproxy_auth_enabled`

Enable auth for Haproxy, type: `bool`, level: G/C, default value: `false`.

Not enabled by default, we recommend enabling it in production envs or adding access control to Nginx or other access layers.



### `haproxy_admin_username`

HAproxy admin user name, type: `string`, level: G, default value: `"admin"`.





### `haproxy_admin_password`

HAproxy admin user password, type: `string`, level: G, default value: `"pigsty"`.





### `haproxy_exporter_port`

HAproxy-exporter listen port, type: `int`, tier: C, default value: `9101`.



### `haproxy_client_timeout`

HAproxy client timeout, type: `interval`, level: C, default value: `"24h"`.





### `haproxy_server_timeout`

HAproxy server timeout, type: `interval`, level: C, default value: `"24h"`.





### `vip_mode`

VIP mode: none, type: `enum`, level: C, default value: `"none"`.

* `none`: No VIP setting, default option.
* `l2`: Layer 2 VIP bound to the primary (requires all members to be in the same Layer 2 network broadcast domain).
* `l4`: Reserved value for traffic distribution via an external L4 load balancer. (not included in Pigsty's current implementation).

VIPs are used to ensure the HA of **reading and writing services** with **LBs**. When using L2 VIPs, Pigsty's VIPs are hosted by a `vip-manager` and will be bound to the **cluster primary**.

This means that it is always possible to access the cluster primary through a VIP, or the LB on the primary through a VIP (which may have performance pressure).

> Note that when using Layer 2 VIP, you must ensure that the VIP candidate ins are under the same Layer 2 network (VLAN, switch).



### `vip_reload`

Overloaded VIP config, type: `bool`, level: A, default value: `true`.





### `vip_address`

VIP address used by the cluster, type: `string`, level: C, default value.





### `vip_cidrmask`

Network CIDR mask length for VIP address, type: `int`, level: C, default value.





### `vip_interface`

Network CIDR mask length for VIP address, type: `int`, level: C, default value.





### `dns_mode`

DNS config mode (reserved parameter), type: `enum`, level: C, default value.





### `dns_selector`

DNS resolution object selector (reserved parameter), type: `string`, level: C, default value.