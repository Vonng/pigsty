# PGSQL Migration

Pigsty has a built-in playbook [`pgsql-migration.yml`](https://github.com/Vonng/pigsty/blob/master/pgsql-migration.yml) to perform online database migration based on logical replication.

With proper automation, the downtime could be minimized to several seconds. But beware that logical replication requires PostgreSQL 10+ to work. You can still use the facility here and use a pg_dump | psql instead of logical replication.



## Define a Migration Task

You have to create a migration task definition file to use this playbook.

Check [`files/migration/pg-meta.yml`](https://github.com/Vonng/pigsty/blob/master/files/migration/pg-meta.yml) for example.

It will try to migrate the `pg-meta.meta` to `pg-test.test`.

```bash
pg-meta-1	10.10.10.10  --> pg-test-1	10.10.10.11 (10.10.10.12,10.10.10.13)
```

You have to tell pigsty where is the source cluster and destination cluster. The database to be migrated, and the primary IP address.

You should have superuser privileges on both sides to proceed

You can overwrite the superuser connection to the source cluster with `src_pg`, and logical replication connection string with `sub_conn`, Otherwise, pigsty default admin & replicator credentials will be used.


```yaml
---
#-----------------------------------------------------------------
# PG_MIGRATION
#-----------------------------------------------------------------
context_dir: ~/migration           # migration manuals & scripts
#-----------------------------------------------------------------
# SRC Cluster (The OLD Cluster)
#-----------------------------------------------------------------
src_cls: pg-meta      # src cluster name         <REQUIRED>
src_db: meta          # src database name        <REQUIRED>
src_ip: 10.10.10.10   # src cluster primary ip   <REQUIRED>
#src_pg: ''            # if defined, use this as src dbsu pgurl instead of:
#                      # postgres://{{ pg_admin_username }}@{{ src_ip }}/{{ src_db }}
#                      # e.g. 'postgres://dbuser_dba:DBUser.DBA@10.10.10.10:5432/meta'
#sub_conn: ''          # if defined, use this as subscription connstr instead of:
#                      # host={{ src_ip }} dbname={{ src_db }} user={{ pg_replication_username }}'
#                      # e.g. 'host=10.10.10.10 dbname=meta user=replicator password=DBUser.Replicator'
#-----------------------------------------------------------------
# DST Cluster (The New Cluster)
#-----------------------------------------------------------------
dst_cls: pg-test      # dst cluster name         <REQUIRED>
dst_db: test          # dst database name        <REQUIRED>
dst_ip: 10.10.10.11   # dst cluster primary ip   <REQUIRED>
#dst_pg: ''            # if defined, use this as dst dbsu pgurl instead of:
#                      # postgres://{{ pg_admin_username }}@{{ dst_ip }}/{{ dst_db }}
#                      # e.g. 'postgres://dbuser_dba:DBUser.DBA@10.10.10.11:5432/test'
#-----------------------------------------------------------------
# PGSQL
#-----------------------------------------------------------------
pg_dbsu: postgres
pg_replication_username: replicator
pg_replication_password: DBUser.Replicator
pg_admin_username: dbuser_dba
pg_admin_password: DBUser.DBA
pg_monitor_username: dbuser_monitor
pg_monitor_password: DBUser.Monitor
#-----------------------------------------------------------------
...

```



## Generate Migration Plan

The playbook does not migrate src to dst, but it will generate everything your need to do so.

After the execution, you will find migration context dir under `~/migration/pg-meta.meta`  by default

Following the `README.md` and executing these scripts one by one, you will do the trick!


```bash
# this script will setup migration context with env vars
. ~/migration/pg-meta.meta/activate

# these scripts are used for check src cluster status
# and help generating new cluster definition in pigsty
./check-user     # check src users
./check-db       # check src databases
./check-hba      # check src hba rules
./check-repl     # check src replica identities
./check-misc     # check src special objects

# these scripts are used for building logical replication
# between existing src cluster and pigsty managed dst cluster
# schema, data will be synced in realtime, except for sequences
./copy-schema    # copy schema to dest
./create-pub     # create publication on src
./create-sub     # create subscription on dst
./copy-progress  # print logical replication progress
./copy-diff      # quick src & dst diff by counting tables

# these scripts will run in an online migration, which will
# stop src cluster, copy sequence numbers (which is not synced with logical replication)
# you have to reroute you app traffic according to your access method (dns,vip,haproxy,pgbouncer,etc...)
# then perform cleanup to drop subscription and publication
./copy-seq [n]   # sync sequence numbers, if n is given, an additional shift will applied
#./disable-src   # restrict src cluster access to admin node & new cluster (YOUR IMPLEMENTATION)
#./re-routing    # ROUTING APPLICATION TRAFFIC FROM SRC TO DST!            (YOUR IMPLEMENTATION)
./drop-sub       # drop subscription on dst after migration
./drop-pub       # drop publication on src after migration
```



**Caveats**

You can use `./copy-seq 1000` to advance all sequences by a number (e.g. `1000`) after syncing sequences.
Which may prevent potential serial primary key conflict in new clusters.

You have to implement your own `./re-routing` script to route your application traffic from src to dst.
Since we don't know how your traffic is routed (e.g dns, VIP, haproxy, or pgbouncer).
Of course, you can always do that by hand...

You have to implement your own `./disable-src` script to restrict the src cluster.
You can do that by changing HBA rules & reload (recommended), or just shutting down postgres, pgbouncer, or haproxy...


