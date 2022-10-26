# PostgreSQL Deployment

> This article describes several ways to deploy a PostgreSQL cluster using Pigsty: PGSQL-related [playbook](p-pgsql.md) and [config](v-pgsql.md). Please refer to the related doc.



* [Identity Parameters](#Identity): Introduces the identity parameters required to define a standard PostgreSQL HA cluster.
* [Singleton Deployment](#Singleton): Defines a single instance PostgreSQL cluster.
* [Primary-Replica Cluster](#M-S-Replication): Defines a standard availability cluster with one primary & one replica.
* [Sync-Standby](#Sync-standby): Define a highly consistent cluster with sync standby and RPO = 0.
* [Quorum Commit](#Quorum-Commit): Defines a cluster with higher data consistency: most replicas return commits on the successful side.
* [Offline Replica](#Offline-replica): Dedicated instances for hosting OLAP analysis, ETL, and interactive personal queries individually.
* [Standby Cluster](#standby-Cluster): Produces real-time online clones of existing clusters for offsite disaster recovery or delayed.
* [Delayed Cluster](#Delayed-Cluster): For responding to software/human failures such as mistaken table and database deletion, faster than PITR.
* [Cascade Instance](#Cascade-instance): Used to build cascade within a cluster for many replica scenarios (20+) to reduce primary pressure.
* [Citus Deployment](#Citus-Deployment): Deploy Citus distributed database cluster.
* [MatrixDB Deployment](#MatrixDB-Deployment): Deploy Greenplum7/PostgreSQL12 compatible chronological data warehouse.



## Identity

The **Core Identity Parameters** are information that must be provided when defining a PostgreSQL cluster.

|                 Name                  |        Attribute         |   Description   |       Example        |
| :-----------------------------------: | :----------------------: | :-------------: | :------------------: |
| [`pg_cluster`](v-pgsql.md#pg_cluster) | **MUST**, cluster level  |  Cluster name   |      `pg-test`       |
|    [`pg_role`](v-pgsql.md#pg_role)    | **MUST**, instance level |  Instance Role  | `primary`, `replica` |
|     [`pg_seq`](v-pgsql.md#pg_seq)     | **MUST**, instance level | Instance number | `1`, `2`, `3`,`...`  |

The content of the identity parameter follows the [entity naming pattern](c-pgsql.md). Where [`pg_cluster`](v-pgsql.md#pg_cluster), [`pg_role`](v-pgsql.md#pg_role), and [`pg_seq`](v-pgsql.md#pg_seq) belong to the core identity parameters, the **minimum set of mandatory parameters required** to define the database cluster and core identity parameters **must be explicitly specified**.

- `pg_cluster` identities the name of the cluster configured at the cluster level and serves as the top-level namespace for cluster resources.

- `pg_role` identities the role of the instance in the cluster, configured at the instance level, with optional values including:

  - `primary`: the **only primary** in the cluster, that provides writing services.
  - `replica`: the **ordinary replica** in the cluster, takes regular production read-only traffic.
  - `offline`: an **offline replica** in the cluster, takes ETL/SAGA/personal user/interactive/analytical queries.
  - `standby`: a **standby replica** in the cluster, with synchronous replication and no replication latency (reserved).
  - `delayed`: a **delayed replica** in the cluster, explicitly specifying replication delay, used to perform backtracking queries and data salvage (reserved).

- `pg_seq` is used to identify the instance within the cluster. Usually, an integer incrementing from 0 or 1 will not be changed once assigned.

- `pg_shard` is used to identify the upper-level **shard cluster** to which the cluster belongs, and only needs to be set if the cluster belongs to a horizontal sharding cluster.

- `pg_sindex` is used to identify the cluster's **slice cluster** number and only needs to be set if the cluster belongs to a horizontal sharding cluster.

- `pg_instance` is the **derived identity parameter** that uniquely identifies a database instance, with the following composition rules

  `{{ pg_cluster }}-{{ pg_seq }}`. Since `pg_seq` is unique within the cluster, this identity is globally unique.



### Sharding Cluster

`pg_shard` and `pg_sindex` define particular sharded clusters and are optional, currently reserved for Citus and Greenplum.

Suppose a user has a horizontal sharding **sharded database cluster** with the name `test`. This cluster consists of four separate clusters: `pg-test1`, `pg-test2`, `pg-test3`, and `pg-test-4`. The user can bind the identity of `pg_shard: test` to each database cluster and `pg_sindex: 1|2|3|4` to each database cluster separately. 

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

With this definition, you can easily observe the cross-sectional metrics comparison of four horizontal sharding clusters from the PGSQL Shard monitoring dashboard. The same functionality works for [Citus](#Citus-deployment) and MatrixDB clusters as well.



## Singleton

Let's start with the simplest case.

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
  vars:
    pg_cluster: pg-test
```

Use the following command to create a primary database instance on the `10.10.10.11` node.

```bash
bin/createpg pg-test
```





## M-S Replication

Pigsty natively supports M-S replication, e.g., to declare a typical one primary & one replica HA database cluster.

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
  vars:
    pg_cluster: pg-test
```

Use `bin/createpg pg-test` to create the cluster. If you have already finished deploying `10.10.10.11` in step 1 [singleton deployment](#singleton), you can also use `bin/createpg 10.10.10.12` to expand the cluster.





## Sync Standby

Under normal circumstances, PostgreSQL's replication latency is a few tens of KB/10ms, which is negligible for regular business.

When the primary fails, data that has not yet completed replication will be lost! Replication latency can be a problem when dealing with critical and sophisticated business queries. Or, in a replica, immediately read-your-write after the primary writes, which can also be very sensitive to replication latency.

Sync standbys can solve such problems. A simple way to configure a sync standby is to use the [`pg_conf`](v-pgsql.md#pg_conf) = `crit` template, which automatically enables synchronous replication.

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

After the cluster is created, you can also execute `pg edit-config <cluster.name>` on the meta node, edit the cluster configuration file, change the value of the `synchronous_mode` to `true` and apply it.

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

By default, synchronous replication picks an instance **from all candidate replicas** as a sync standby. Any primary transaction is only considered successfully committed and returned when replicated to the replica and flushed to the disk. A quorum commit can be used if more persistent data is expected. For example, in a 1primary & 3 replicas cluster, at least two replicas successfully flush to disk before a commit is confirmed.

When using quorum commit, you need to modify the `synchronous_standby_names` in PostgreSQL and the value of [`synchronous_node_count`](https://patroni.readthedocs.io/en/) in Patroni. Assuming that the three replicas are `pg-test-2, pg-test-3, and pg-test-4`, the following should be configured.

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

After the application, the configuration takes effect, and two Sync Standby appear. When the cluster has Failover or expansion and contraction, please adjust these parameters to avoid service unavailability.

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

Data analysis/ETL/personal interactive queries should be placed on the offline replica when the high online business request load.

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
    10.10.10.13: { pg_seq: 2, pg_role: offline } #Define a new offline instance
  vars:
    pg_cluster: pg-test
```

Use `bin/createpg pg-test` to create the cluster. If you have already completed [singleton deployment](#singleton) and [primary-replica-cluster](#M-S-Replication), you can use `bin/createpg 10.10.10.13` to expand the cluster and add an offline replica to the cluster.

Offline replicas do not host the [`replica`](c-service.md#replica-service) service by default, and the offline instance will only host read-only traffic if all instances in the [`replica`](c-service.md#replica-service) service are unavailable. If you have only one primary & one replica, or only one primary, you can set the [`pg_offline_query`](v-pgsql.md#pg_offline_query) flag for an offline instance that also hosts the [`offline`](c-service.md#offline-service) service to be used as a **quasi-offline instance**.






## Standby Cluster

You can make a clone of an existing cluster using the Standby Cluster method, which allows for a smooth migration from a current database to a Pigsty cluster.

Just make sure that the [`pg_upstream`](v-pgsql.md#pg_upstream) parameter is configured on the primary of the backup cluster to pull backups from the original upstream automatically.

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

When you want to promote the standby cluster to a standalone cluster, edit the Patroni configuration file of the new cluster to remove all `standby_cluster` configurations, and the Standby Leader in the standby cluster will be elevated to a standalone primary.

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

When a Failover primary change occurs in the source cluster, you need to adjust the replication source of the standby cluster. Execute `pg edit-config <cluster>` and change the source address in `standby_cluster` to the new primary, and the application will take effect. Note that replica replication from the source cluster is **feasible**, and a Failover in the source cluster will not affect the replication of the standby cluster. However, the new cluster cannot create replication slots on the read-only replica, and there may be related error reports and a risk of replication interruption. It is recommended to adjust the upstream replication source of the standby cluster in time.

```yaml
 standby_cluster:
   create_replica_methods:
   - basebackup
-  host: 10.10.10.13
+  host: 10.10.10.12
   port: 5432
```

Modify the IP of the replication upstream in `standby,_cluster.host`, and the application will take effect (no need to reboot, Reload).





## Delayed Cluster

HA and M-S replication can solve the problems caused by machine hardware failure, but cannot solve the failure caused by software bugs and human operations. A [cold standby](t-backup.md) is usually required for accidental data deletion, but another way is to prepare a delayed cluster.

You can use the function [standby cluster](#standby-cluster) to create a delayed. For example, now you want to specify a delayed for the `pg-test` cluster: `pg-testdelay`, which is the state of `pg-test` 1 hour ago.


```yaml
# pg-test is the original database
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
  vars:
    pg_cluster: pg-test
    pg_version: 14

# pg-testdelay will be used as a delayed for the pg-test
pg-testdelay:
  hosts:
    10.10.10.12: { pg_seq: 1, pg_role: primary , pg_upstream: 10.10.10.11 } # The actual role is Standby Leader
  vars:
    pg_cluster: pg-testdelay
    pg_version: 14          
```

After creation, edit the Patroni config file for the delayed cluster using `pg edit-config pg-testdelay` in the meta node and change `standby_cluster.recovery_min_apply_delay` to the delay value you expect.

```bash
 standby_cluster:
   create_replica_methods:
   - basebackup
   host: 10.10.10.11
   port: 5432
+  recovery_min_apply_delay: 1h
```




## Cascade Instance

When creating a cluster, if the [`pg_upstream`](v-pgsql.md#pg_upstream) parameter is specified for one of the **replicas** in the cluster (defined as **another replica** in the cluster), the instance will attempt to build logical replication from that specified replica.

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica } # Try to replicate from slave 2 instead of the master
    10.10.10.13: { pg_seq: 2, pg_role: replica, pg_upstream: 10.10.10.12 }
  vars:
    pg_cluster: pg-test
```









## Citus Deployment

[Citus](https://www.citusdata.com/) is a distributed extension plugin for PostgreSQL. By default, Pigsty installs Citus but does not enable it. [`pigsty-citus.yml`](https://github.com/Vonng/pigsty/blob/master/files/conf/pigsty-citus.yml) provides a config file case for deploying a Citus cluster. To allow Citus to, you need to modify the following parameters.

* `max_prepared_transaction`: Modify to a value greater than `max_connections`, e.g. 800.
* [`pg_libs`](v-pgsql.md#pg_libs): Must contain `citus` and be placed in the top position.
* You need to include the `citus` extension plugin in the [business database](c-pgsql.md#Cluster) (but you can also manually install it via `CREATE EXTENSION`).

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

</details>

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

For more information about Citus, please refer to the [Citus official doc](https://docs.citusdata.com/en/v11.0-beta/).





## MatrixDB Deployment

Greenplum is a distributed data warehouse based on the PostgreSQL ecosystem, and MatrixDB is a branch of Greenplum based on Greenplum 7, using the PostgreSQL 12 kernel. Greenplum 7 has not yet been officially released, so Pigsty is currently using MatrixDB as a replacement for Greenplum.

MatrixDB is based on the PostgreSQL ecosystem, so most PostgreSQL playbooks and tasks can be reused on MatrixDB. There are only two additional parameters specific to MatrixDB.

* [`gp_role`](v-pgsql.md#gp_role): Define the identity of the Greenplum cluster, `master,` or `segment`.
* [`pg_instances`](v-pgsql.md#pg_instances): Define the Segment instance, which is used to deploy the Segment monitoring instance.

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

</details>
