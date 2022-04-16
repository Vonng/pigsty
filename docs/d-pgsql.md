# PostgreSQL Deployment

> This article describes a few different ways to deploy a PostgreSQL cluster using Pigsty: PGSQL-related [playbook](p-pgsql.md) and [config](v-pgsql.md) please refer to the related doc.



* [Identity Parameters](#Identity Parameters): Introduces the identity parameters required to define a standard PostgreSQL high availability cluster.
* [Singleton Deployment](# Single Deployment) defines a single instance PostgreSQL cluster.
* [Master-Slave Cluster](#Master-Slave Cluster): Defines a standard availability cluster with one master and one slave.
* [Synchronous Slave](# Synchronous Slave): Define a highly consistent cluster with synchronous replication and RPO = 0.
* [Quorum Synchronous Commit](# Quorum Synchronous Commit): defines a cluster with higher data consistency: most slaves return commits on the successful side.
* [Offline Slave](# Offline Slave): dedicated instance for hosting OLAP analysis, ETL, and interactive personal queries separately.
* [Backup Cluster](#Backup Cluster): Produces real-time online clones of existing clusters for offsite disaster recovery or deferred slave.
* [Delayed Slave](# Delayed Slave): for software/human failures such as accidental table deletion and library deletion, faster than PITR.
* [Cascade Replication](#Cascade Replication): Used to build cascade replication within a cluster, for a large number of slave scenarios (20+), to reduce master replication pressure.
* [Citus Cluster Deployment](#Citus Cluster Deployment): Deploy Citus distributed database cluster.
* [MatrixDB Cluster Deployment](#MatrixDB Cluster Deployment): Deploy Greenplum7/PostgreSQL12 compatible chronological data warehouse.



## Identity

The **Core Identity Parameters** are information that must be provided when defining a PostgreSQL cluster and include:

|                 Name                  |        Properties        |   Description   |       Example        |
| :-----------------------------------: | :----------------------: | :-------------: | :------------------: |
| [`pg_cluster`](v-pgsql.md#pg_cluster) | **MUST**, cluster level  |  Cluster name   |      `pg-test`       |
|    [`pg_role`](v-pgsql.md#pg_role)    | **MUST**, instance level |  Instance Role  | `primary`, `replica` |
|     [`pg_seq`](v-pgsql.md#pg_seq)     | **MUST**, instance level | Instance number | `1`, `2`, `3`,`...`  |

The content of the identity parameter follows the [entity naming convention](c-entity.md). Where [`pg_cluster`](v-pgsql.md#pg_cluster), [`pg_role`](v-pgsql.md#pg_role), and [`pg_seq`](v-pgsql.md#pg_seq) belong to the core identity parameters, which are the **minimum set of mandatory parameters required to define the database cluster**, the core identity parameters **must be explicitly specified** and cannot be ignored.

- `pg_cluster` identifies the name of the cluster, configured at the cluster level, and serves as the top-level namespace for cluster resources.

- `pg_role` identifies the role that the instance plays in the cluster, configured at the instance level, with optional values including:

  - `primary`: the **only master** in the cluster, the cluster leader, provides writing services.
  - `replica`: **normal slave** in the cluster, takes regular production read-only traffic.
  - `offline`: **offline slave** in the cluster, takes ETL/SAGA/personal user/interactive/analytical queries.
  - `standby`: **synchronous slave** in the cluster, with synchronous replication and no replication latency (retention).
  - `delayed`: **delayed slave** in the cluster, explicitly specifying replication delay, used to perform backtracking queries and data salvage (reserved).

- `pg_seq` is used to identify the instance within the cluster, usually as an integer incrementing from 0 or 1, and will not be changed once assigned.

- `pg_shard` Used to identify the upper-level **shard cluster** to which the cluster belongs, only required if the cluster is a member of a horizontally sharded cluster.

- `pg_sindex` is used to identify the cluster's **slice cluster** number, and only needs to be set if the cluster is a member of a horizontal slice cluster.

- `pg_instance` is the **derived identity parameter** that uniquely identifies a database instance, with the following composition rules

  `{{ pg_cluster }}-{{ pg_seq }}`. Since `pg_seq` is unique within the cluster, this identifier is globally unique.



### Sharding Cluster

`pg_shard` and `pg_sindex` are used to define special sharded clusters and are optional identity parameters, currently reserved for Citus and Greenplum.

Suppose a user has a horizontal **sharded database cluster (Shard)** with the name `test`. This cluster consists of four separate clusters: `pg-test1`, `pg-test2`, `pg-test3`, and `pg-test-4`. Then the user can bind the identity of `pg_shard: test` to each database cluster and `pg_sindex: 1|2|3|4` to each database cluster separately. This is shown as follows.

```yaml
pg-test1:
  vars: {pg_cluster: pg-test1, pg_shard: test, pg_sindex: 1}
  hosts: {10.10.10.10: {pg_seq: 1, pg_role: primary}}
pg-test2:
  vars: {pg_cluster: pg-test1, pg_shard: test, pg_sindex: 2}
  hosts: {10.10.10.11: {pg_seq: 1, pg_role: primary}}
pg-test3:
  vars: {pg_cluster: pg-test1, pg_shard: test, pg_sindex: 3}
  hosts: {10.10.10.12: {pg_seq: 1, pg_role: primary}}
pg-test4:
  vars: {pg_cluster: pg-test1, pg_shard: test, pg_sindex: 4}
  hosts: {10.10.10.13: {pg_seq: 1, pg_role: primary}}
```

With this definition, you can easily observe the cross-sectional metrics comparison of these four horizontally sharded clusters from the PGSQL Shard monitoring panel. The same functionality works for [Citus](#Citus cluster) and MatrixDB clusters as well.



## Singleton

Let's start with the simplest case.

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
  vars:
    pg_cluster: pg-test
```

Use the following command to create a single master database instance on the `10.10.10.11` node.

```bash
bin/createpg pg-test
```





## M-S Replication

Replication can greatly increase database system reliability and is the best means of dealing with hardware failures.

Pigsty natively supports setting up master-slave replication, for example, to declare a typical one-master-one-slave highly available database cluster, you can use:

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
  vars:
    pg_cluster: pg-test
```

Use `bin/createpg pg-test` to create the cluster. If you have already deployed `10.10.10.11` in the first step of [standalone deployment](#standalone deployment), you can also use `bin/createpg 10.10.10.12` to expand the cluster.





## Sync Standby

Under normal circumstances, PostgreSQL's replication latency is on the order of tens of KB/10ms, which is approximately negligible for regular business.

The important thing is that when the master fails, data that has not yet completed replication will be lost! Replication latency can be an issue when you are dealing with very critical and sophisticated business queries (dealing with money). In addition, when you query the slave for a read-your-write immediately after the master writes, you can also be very sensitive to replication latency.

To solve such problems, synchronous slave libraries are used. A simple way to configure a synchronous slave is to use the [`pg_conf`](v-pgsql.md#pg_conf) = `crit` template, which automatically enables synchronous replication.

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
    10.10.10.13: { pg_seq: 3, pg_role: replica }
  vars:
    pg_cluster: pg-test
    pg_conf: crit.yml
```

Alternatively, you can edit the cluster config file by executing `pg edit-config <cluster.name>` on the meta node after the cluster has been created, changing the value of the parameter `synchronous_mode` to `true` and applying it.

```bash
$ pg edit-config pg-test
---
+++
-synchronous_mode: false
+synchronous_mode: true
 synchronous_mode_strict: false

Apply these changes? [y/N]: y
```





## Quorum Commit

By default, synchronous replication picks one instance **from all candidate slaves** as a synchronous slave, and any master transaction is only considered successfully committed and returned when it is replicated to the slave and flushed to disk. If we expect higher data persistence guarantees, for example, in a four-instance cluster with one master and three slaves, where at least two slaves successfully flush the disk before confirming the commit, then we can use quorum commit.

When using quorum commit, you need to modify the value of the `synchronous_standby_names` parameter in PostgreSQL and the accompanying modify [`synchronous_node_count`](https://patroni.readthedocs.io/en) in Patroni. Assuming that the three slave libraries are `pg-test-2, pg-test-3, and pg-test-4`, then the following should be configured.

* `synchronous_standby_names = ANY 2 (pg-test-2, pg-test-3, pg-test-4)`
* `synchronous_node_count : 2`

```bash
pg-test:
  hosts:
    10.10.10.10: { pg_seq: 1, pg_role: primary } # pg-test-1
    10.10.10.11: { pg_seq: 2, pg_role: replica } # pg-test-2
    10.10.10.12: { pg_seq: 3, pg_role: replica } # pg-test-3
    10.10.10.13: { pg_seq: 4, pg_role: replica } # pg-test-4
  vars:
    pg_cluster: pg-test
```

Execute `pg edit-config pg-test` and modify the config as follows.

```bash
$ pg edit-config pg-test
---
+++
@@ -82,10 +82,12 @@
     work_mem: 4MB
+    synchronous_standby_names: 'ANY 2 (pg-test-2, pg-test-3, pg-test-4)'
 
-synchronous_mode: false
+synchronous_mode: true
+synchronous_node_count: 2
 synchronous_mode_strict: false

Apply these changes? [y/N]: y
```

After the application, you can see that the config takes effect and two Sync Standby appear. When the cluster has Failover or expansion and contraction, please adjust these parameters accordingly to avoid service unavailability.

```bash
+ Cluster: pg-test (7080814403632534854) +---------+----+-----------+-----------------+
| Member    | Host        | Role         | State   | TL | Lag in MB | Tags            |
+-----------+-------------+--------------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.10 | Leader       | running |  1 |           | clonefrom: true |
| pg-test-2 | 10.10.10.11 | Sync Standby | running |  1 |         0 | clonefrom: true |
| pg-test-3 | 10.10.10.12 | Sync Standby | running |  1 |         0 | clonefrom: true |
| pg-test-4 | 10.10.10.13 | Replica      | running |  1 |         0 | clonefrom: true |
+-----------+-------------+--------------+---------+----+-----------+-----------------+
```






## Offline Replica

When the load level of your online business requests is high, placing data analysis/ETL/personal interactive queries on a dedicated offline read-only slave library is a more appropriate option.

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
    10.10.10.13: { pg_seq: 2, pg_role: offline } # 定义一个新的Offline实例
  vars:
    pg_cluster: pg-test
```

Use `bin/createpg pg-test` to create the cluster. If you have already completed step 1 [standalone deployment](#standalone deployment) and step 2 [master-slave cluster](#master-slave cluster), then you can use `bin/createpg 10.10.10.13` to expand the cluster and add an offline slave instance to the cluster.

Offline slaves do not host the [`replica`](c-service.md#replica service) service by default, and the offline instance will only be used to host read-only traffic in an emergency if all instances in the [`replica`](c-service.md#replica service) service are unavailable. If you have only one master and one slave, or simply one master and no dedicated offline instance, you can set the [`pg_offline_query`](v-pgsql.md#pg_offline_query) flag for that instance by setting it to still play the original role, but also to host [`offline`](c- service.md#offline service) service, which is used as a **quasi-offline instance**.








## Standby Cluster

You can make a clone of an existing cluster using the Standby Cluster approach, using which you can migrate smoothly from an existing database to a Pigsty cluster.

Creating a Standby Cluster is incredibly simple, you just need to make sure that the backup cluster has the appropriate [`pg_upstream`](v-pgsql.md#pg_upstream) parameter configured on the primary library to automatically pull backups from the original upstream.

```yaml
# pg-test is the original database
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
  vars:
    pg_cluster: pg-test
    pg_version: 14


# Pg-test2 will be the standby cluster of pg-test1.
pg-test2:
  hosts:
    10.10.10.12: { pg_seq: 1, pg_role: primary , pg_upstream: 10.10.10.11 } # The actual role is Standby Leader
    10.10.10.13: { pg_seq: 2, pg_role: replica }
  vars:
    pg_cluster: pg-test2
    pg_version: 14          # When making a Standby Cluster, the database major version must be consistent!
```

```bash
bin/createpg pg-test     # Creating the original cluster
bin/createpg pg-test2    # Creating a Backup Cluster
```

### Promote Standby Cluster

When you want to promote the whole backup cluster to a standalone operation, edit the Patroni config file of the new cluster to remove all `standby_cluster` configs and the Standby Leader in the backup cluster will be promoted to a standalone master.

```bash
pg edit-config pg-test2  # Remove the standby_cluster config definition and apply
```

Remove the following config: the entire `standby_cluster` definition section.

```bash
-standby_cluster:
-  create_replica_methods:
-  - basebackup
-  host: 10.10.10.11
-  port: 5432
```

### Change Replication Upstream

You need to adjust the replication source of the backup cluster when the source cluster undergoes a Failover master change. Execute `pg edit-config <cluster>` and change the source address in `standby_cluster` to the new master, and the application will take effect. Note here that replication from the slave of the source cluster is **feasible**, and a Failover in the source cluster does not affect the replication of the backup cluster. However, the new cluster cannot create replication slots on the read-only slave, and there may be related error reports and potential risk of replication interruption, so it is recommended to adjust the upstream replication repo of the backup cluster in time.

```yaml
 standby_cluster:
   create_replica_methods:
   - basebackup
-  host: 10.10.10.13
+  host: 10.10.10.12
   port: 5432
```

Modify the IP address of the replication upstream in `standby_cluster.host` and the application will take effect (no need to reboot, just Reload).





## Delayed Slave

High availability and master-slave replication can solve the problems caused by machine hardware failure, but cannot solve the problems caused by software Bugs and human operation, for example, mistakenly deleting libraries and tables. A  [cold backup](t-backup.md) is usually needed for accidental data deletion, but a more elegant and efficient way is to prepare a delayed slave beforehand.

You can use the function [backup cluster](#backup cluster) to create a delayed slave. For example, now you want to specify a delayed slave for the `pg-test` cluster: `pg-testdelay`, which is the state of `pg-test` 1 hour ago. So if there is a mistaken deletion of data, you can immediately retrieve it from the delayed slave and pour it back into the original cluster.


```yaml
# pg-test is the original database
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
  vars:
    pg_cluster: pg-test
    pg_version: 14

# pg-testdelay will be used as a delay slave for the pg-test library
pg-testdelay:
  hosts:
    10.10.10.12: { pg_seq: 1, pg_role: primary , pg_upstream: 10.10.10.11 } # The actual role is Standby Leader
  vars:
    pg_cluster: pg-testdelay
    pg_version: 14          
```

After creation, edit the Patroni config file for the delayed cluster with `pg edit-config pg-testdelay` on the meta node, change `standby_cluster.recovery_min_apply_delay` to the value you expect, e.g. `1h`, and apply it.

```bash
 standby_cluster:
   create_replica_methods:
   - basebackup
   host: 10.10.10.11
   port: 5432
+  recovery_min_apply_delay: 1h
```




## Cascade Instance

When creating a cluster, if the [`pg_upstream`](v-pgsql.md#pg_upstream) parameter is specified for one of the **slave libraries** in the cluster (specified as **another slave library** in the cluster), then the instance will attempt to build logical replication from that specified slave library.

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica } # Try to replicate from slave 2 instead of the master
    10.10.10.13: { pg_seq: 2, pg_role: replica, pg_upstream: 10.10.10.12 }
  vars:
    pg_cluster: pg-test
```









## Citus Cluster Deployment

[Citus](https://www.citusdata.com/) is a distributed extension plugin for the PostgreSQL ecology. By default, Pigsty installs Citus but does not enable it. [`pigsty-citus.yml`](https://github.com/Vonng/pigsty/blob/master/files/conf/pigsty-citus.yml) provides a config file case for deploying a Citus cluster. To enable Citus, you need to modify the following parameters.

* `max_prepared_transaction`: Modify to a value greater than `max_connections`, e.g. 800.
* [`pg_shared_libraries`](v-pgsql.md#pg_shared_libraries): must contain `citus` and be placed in the top position.
* You need to include the `citus` extension plugin in the [business database](c-pgdbuser.md#database) (but you can also manually install it yourself afterward via `CREATE EXTENSION`).

<details><summary>Citus cluster sample config</summary>


```yaml
#----------------------------------#
# cluster: citus coordinator
#----------------------------------#
pg-meta:
  hosts:
    10.10.10.10: { pg_seq: 1, pg_role: primary , pg_offline_query: true }
  vars:
    pg_cluster: pg-meta
    vip_address: 10.10.10.2
    pg_users: [ { name: citus , password: citus , pgbouncer: true , roles: [ dbrole_admin ] } ]
    pg_databases: [ { name: meta , owner: citus , extensions: [ { name: citus } ] } ]

#----------------------------------#
# cluster: citus data nodes
#----------------------------------#
pg-node1:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
  vars:
    pg_cluster: pg-node1
    vip_address: 10.10.10.3
    pg_users: [ { name: citus , password: citus , pgbouncer: true , roles: [ dbrole_admin ] } ]
    pg_databases: [ { name: meta , owner: citus , extensions: [ { name: citus } ] } ]

pg-node2:
  hosts:
    10.10.10.12: { pg_seq: 1, pg_role: primary  , pg_offline_query: true }
  vars:
    pg_cluster: pg-node2
    vip_address: 10.10.10.4
    pg_users: [ { name: citus , password: citus , pgbouncer: true , roles: [ dbrole_admin ] } ]
    pg_databases: [ { name: meta , owner: citus , extensions: [ { name: citus } ] } ]

pg-node3:
  hosts:
    10.10.10.13: { pg_seq: 1, pg_role: primary  , pg_offline_query: true }
  vars:
    pg_cluster: pg-node3
    vip_address: 10.10.10.5
    pg_users: [ { name: citus , password: citus , pgbouncer: true , roles: [ dbrole_admin ] } ]
    pg_databases: [ { name: meta , owner: citus , extensions: [ { name: citus } ] } ]

```



Next, you need to refer to the [Citus Multi-Node Deployment Guide,](https://docs.citusdata.com/en/latest/installation/multi_node_rhel.html) and on the Coordinator node, execute the following command to add a data node.

```bash
sudo su - postgres; psql meta 
SELECT * from citus_add_node('10.10.10.11', 5432);
SELECT * from citus_add_node('10.10.10.12', 5432);
SELECT * from citus_add_node('10.10.10.13', 5432);
```

```bash
SELECT * FROM citus_get_active_worker_nodes();
  node_name  | node_port
-------------+-----------
 10.10.10.11 |      5432
 10.10.10.13 |      5432
 10.10.10.12 |      5432
(3 rows)
```

After successfully adding data nodes, you can use the following command to create sample data tables on the coordinator and distribute them to each data node.

```sql
-- Declare a distributed table
CREATE TABLE github_events
(
    event_id     bigint,
    event_type   text,
    event_public boolean,
    repo_id      bigint,
    payload      jsonb,
    repo         jsonb,
    actor        jsonb,
    org          jsonb,
    created_at   timestamp
) PARTITION BY RANGE (created_at);
-- Creating Distributed Tables
SELECT create_distributed_table('github_events', 'repo_id');
```

For more Citus-related features, please refer to the [Citus official doc](https://docs.citusdata.com/en/v11.0-beta/).





## MatrixDB Cluster Deployment

MatrixDB is a branch of Greenplum, based on Greenplum 7 and using the PostgreSQL 12 kernel. Because Greenplum 7 has not been officially released yet, Pigsty currently uses MatrixDB as an alternative implementation of Greenplum.

Since MatrixDB is based on the PostgreSQL ecosystem, most PostgreSQL scripts and tasks can be reused on MatrixDB. there are only two additional parameters specific to MatrixDB.

* [`gp_role`](v-pgsql.md#gp_role): defines the identity of the Greenplum cluster, `master,` or `segment`.
* [`pg_instances`](v-pgsql.md#pg_instances): defines the Segment instance, which is used to deploy Segment instance monitoring.

For details, please refer to [MatrixDB Deployment](d-matrixdb.md).

<details><summary>MatrixDB cluster sample config--4 nodes</summary>


```yaml
#----------------------------------#
# cluster: mx-mdw (gp master)
#----------------------------------#
mx-mdw:
  hosts:
    10.10.10.10: { pg_seq: 1, pg_role: primary , nodename: mx-mdw-1 }
  vars:
    gp_role: master          # this cluster is used as greenplum master
    pg_shard: mx             # pgsql sharding name & gpsql deployment name
    pg_cluster: mx-mdw       # this master cluster name is mx-mdw
    pg_databases:
      - { name: matrixmgr , extensions: [ { name: matrixdbts } ] }
      - { name: meta }
    pg_users:
      - { name: meta , password: DBUser.Meta , pgbouncer: true }
      - { name: dbuser_monitor , password: DBUser.Monitor , roles: [ dbrole_readonly ], superuser: true }

    pgbouncer_enabled: true                # enable pgbouncer for greenplum master
    pgbouncer_exporter_enabled: false      # enable pgbouncer_exporter for greenplum master
    pg_exporter_params: 'host=127.0.0.1&sslmode=disable'  # use 127.0.0.1 as local monitor host

#----------------------------------#
# cluster: mx-sdw (gp master)
#----------------------------------#
mx-sdw:
  hosts:
    10.10.10.11:
      nodename: mx-sdw-1        # greenplum segment node
      pg_instances:             # greenplum segment instances
        6000: { pg_cluster: mx-seg1, pg_seq: 1, pg_role: primary , pg_exporter_port: 9633 }
        6001: { pg_cluster: mx-seg2, pg_seq: 2, pg_role: replica , pg_exporter_port: 9634 }
    10.10.10.12:
      nodename: mx-sdw-2
      pg_instances:
        6000: { pg_cluster: mx-seg2, pg_seq: 1, pg_role: primary , pg_exporter_port: 9633  }
        6001: { pg_cluster: mx-seg3, pg_seq: 2, pg_role: replica , pg_exporter_port: 9634  }
    10.10.10.13:
      nodename: mx-sdw-3
      pg_instances:
        6000: { pg_cluster: mx-seg3, pg_seq: 1, pg_role: primary , pg_exporter_port: 9633 }
        6001: { pg_cluster: mx-seg1, pg_seq: 2, pg_role: replica , pg_exporter_port: 9634 }
  vars:
    gp_role: segment               # these are nodes for gp segments
    pg_shard: mx                   # pgsql sharding name & gpsql deployment name
    pg_cluster: mx-sdw             # these segment clusters name is mx-sdw
    pg_preflight_skip: true        # skip preflight check (since pg_seq & pg_role & pg_cluster not exists)
    pg_exporter_config: pg_exporter_basic.yml   # use basic config to avoid segment server crash
    pg_exporter_params: 'options=-c%20gp_role%3Dutility&sslmode=disable'  # use gp_role = utility to connect to segments

```

