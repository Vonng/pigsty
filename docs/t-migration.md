# Migration Tutorial

An auxiliary playbook, [`pgsql-migration.yml`](p-pgsql.md#pgsql-migration), provides a battery-included migration method based on logical replication. 

By filling in the information about the source and host clusters, the playbook will automatically create the scripts needed for the migration and simply execute them in sequence during the database migration.

```bash
activate                        # activate migration context
check-replica-identity          # prepare: make sure all table have replica identity
check-replica-identity-solution # prepare: fix table without replica identity
check-special-objec             # prepare: check special object: matrialized view
compare            # compare: fast check on data consistency (by row count)
copy-schema        # migration: copy schema from src to dst cluster
create-pub         # migration: create publication on source cluster
create-sub         # migration: build logical replication between src & dst clusters
progress           # migration: print logical replication progress
copy-seq           # migration: copy sequence number from src to dst cluster
next-seq           # migration: advance dst cluster by 10000 to fix primary confliction
remove-sub         # remove subscription from dst cluster
```



## Prepare

### SRC and DST Clusters

Suppose you want to migrate the `pg-meta` cluster in the sandbox (containing the Pigsty meta DB with the pgbench test tables) to the `pg-test` cluster.


```bash
pg-meta-1	10.10.10.10  --> pg-test-1	10.10.10.11 (10.10.10.12,10.10.10.13)
```

First, create a new empty target cluster `pg-test`, then edit the variables list in `pgsql-migration.yml` and fill in the relevant information (connection information for the host cluster's primary).

```yaml
#--------------------------------------------------------------#
#                   MIGRATION CONTEXT                          #
#--------------------------------------------------------------#

# src cluster (the old cluster)
src_cls: pg-meta                       # src cluster name
src_db: meta                           # src database name
src_ip: 10.10.10.10                    # ip address of src cluster primary
src_list: [ ]                          # ip address list of src cluster members (non-primary)

#--------------------------------------------------------------#
# dst cluster (the new cluster)
dst_cls: pg-test                       # dst cluster name
dst_db: test                           # dst database name
dst_ip: 10.10.10.11                    # dst cluster leader ip addressh
dst_list: [ 10.10.10.12, 10.10.10.13 ] # dst cluster members (non-primary)

# dst cluster access information
dst_dns: pg-test                       # dst cluster dns records
dst_vip: 10.10.10.3                    # dst cluster vip records

#--------------------------------------------------------------#
# credential (assume .pgpass viable)
pg_admin_username: dbuser_dba          # superuser @ both side
pg_replicatoin_username: replicator    # repl user @ src to be used
migration_context_dir: ~/migration     # this dir will be created
#--------------------------------------------------------------#

```

Execute `pgsql-migration.yml`, which by default creates the `~/migration/pg-meta.meta` dir on the meta node, containing the resources and scripts used for the migration.





## Manual Template

**Announcement**

* Operation Notice
* Business Party Notification

**Preparations**

* [ ] Prepare source and host clusters
* [ ] Repair Source HBA
* [ ] Create Source Replication User
* [ ] External Resource Request
* [ ] Create Cluster Profile
* [ ] Configure business users
* [ ] Configure business database
* [ ] Configure business whitelist
* [ ] Create business cluster
* [ ] Fix Replication Identity
* [ ] Identify migration target
* [ ] Generate schema synchronization command
* [ ] Generate serial number synchronization command
* [ ] Generate create publish command
* [ ] Generate create subscription command
* [ ] Generate progress check command
* [ ] Generate check command

**Stock Migration**

- [ ] Synchronize database schema
- [ ] Create publish at the source
- [ ] Create a subscription to host
- [ ] Wait for logical replication sync

**Switch moment**

- [ ] Prepare
- [ ] Stop source write traffic
- [ ] Synchronize sequence numbers with other objects
- [ ] Verify data consistency
- [ ] Flow Switching
- [ ] Aftercare
