# Database Migration Tutorial

Pigsty has a built-in database online migration helper script: [`pgsql-migration.yml`](p-pgsql.md#pgsql-migration), which provides an out-of-the-box logical replication-based non-stop database migration solution.

By filling in the information about the source and host clusters, the playbook will automatically create the scripts needed for the migration and simply execute them in sequence during the database migration.

```bash
activate 							# Activate the migration context and register environment variables
check-replica-identity 				# Prep phase: check if all tables in the source cluster have replicated identities (primary keys, or non-null unique candidate keys)
check-replica-identity-solution 	# Prep phase: Generate repair SQL statements for tables that do not have a reasonable replica identity
check-special-object 				# Prep phase: check materialized views, composite types, and other special objects
compare 							# Compare: fast comparison of tables in source and host clusters (row count)
copy-schema 						# Stock migration: copy schema from the source cluster to the host cluster (can be executed idempotently)
create-pub 							# Stock migration: create a release in the source cluster
create-sub 							# Stock migration: create subscriptions in the host cluster, creating a logical replication between the source and host clusters
progress 							# Stock migration: print the progress of logical replication
copy-seq 							# Stock/Incremental migration: copy the sequence number from the source cluster to the host cluster (can be executed idempotently and needs to be executed again at switchover time)
next-seq 							# Switching moment: emergency step all sequence numbers in the host cluster by 1000 to avoid primary key conflicts
remove-sub 							# Remove logical subscriptions from the host cluster
```

## Preparations

### Preparing the source and host clusters

Now suppose we want to migrate the `pg-meta` cluster in the sandbox (containing the Pigsty meta-database with the pgbench test tables) to the `pg-test` cluster.

```bash
pg-meta-1	10.10.10.10  --> pg-test-1	10.10.10.11 (10.10.10.12,10.10.10.13)
```

First, create a new empty target cluster `pg-test`, then edit the variables list in `pgsql-migration.yml` and fill in the relevant information (connection information for the host cluster's master library).

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


## Migration Templates

[**Announcement**](#Announcement)

* [Operation Notice](#Operation Notice)
* [Business Party Notification](#Business Party Notification)

[**Preparations**](#Preparations)

* [ ] [Prepare source and host clusters](# Prepare source and host clusters)
* [ ] [Repair Source HBA](# Repair Source HBA)
* [ ] [Create Source Replication User](# Create Source Replication User)
* [ ] [External Resource Request](# External Resource Request)
* [ ] [Create Cluster Profile](# Create Cluster Profile)
* [ ] [Configure business users](# Configure business users)
* [ ] [Configure business database](# Configure business database)
* [ ] [Configure business whitelist](# Configure business whitelist)
* [ ] [Create business cluster](# Create business cluster)
* [ ] [Fix Replication Identity](# Fix Replication Identity)
* [ ] [Identify migration target](# Identify migration target)
* [ ] [Generate schema synchronization command](# Generate schema synchronization command)
* [ ] [Generate serial number synchronization command](# Generate serial number synchronization command)
* [ ] [generate create publish command](# generate create publish command)
* [ ] [Generate create subscription command](# Generate create subscription command)
* [ ] [generate progress check command](# generate progress check command)
* [ ] [Generate check command](#生成校验命令)

[**Stock Migration**](#Stock Migration)

- [ ] [Synchronize database schema](# Synchronize database schema)
- [ ] [Create publish at the source](# Create publish at source)
- [ ] [Create a subscription to host](# Create subscription on host)
- [ ] [Wait for logical replication synchronization](# Wait for logical replication synchronization)

[ **Switch moment**](#Switch moment)

- [ ] [Ready to work](# Ready to work)
- [ ] [Stop source write traffic](# Stop source write traffic)
- [ ] [Synchronize sequence numbers with other objects](# Synchronize sequence number with other objects)
- [ ] [Verify data consistency](# Synchronize sequence number with other objects)
- [ ] [Flow Switching](# Flow Switching)
- [ ] [Aftercare](#善后工作)
