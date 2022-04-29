# Backup and Recovery

> Backup & Recovery matters.

Failures can be divided into two categories: hardware failures/insufficient resources, and software defects/human errors. Physical replication solves the former; Delayed and cold standby solves the latter.

Pigsty provides complete backup support with battery-included primary-replica physical replication without configuration. It also provides support for delayed backups and cold standby.

* [Physical Replication](#Physical-backup) (Hot/Warm Standby)
* [Delayed](#Delayed)
* [Cold Standby](#Cold-Standby)



## Physical Backup

In Pigsty, physical backups are created by specifying roles (`pg_role`) for the database instances. For example, the following configuration declares a HA database cluster with one primary & two replicas.

```bash
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary } # Primary
    10.10.10.12: { pg_seq: 2, pg_role: replica } # Hot standby
    10.10.10.13: { pg_seq: 3, pg_role: offline } # Warm standby
  vars:
    pg_cluster: pg-test
```



### Hot Standby

> `replica` = Hot Standby, which carries read-only traffic and maintains real-time synchronization with the primary, with a few replication delays.

It is consistent with the primary and will take over the work of the primary when it fails, and will also take over online read-only traffic. A hot standby that uses sync replication to keep up with the primary in real-time can also be called a sync backup. Under normal circumstances, the latency of physical replication can be in the range of 1ms-100ms / tens of KB to several MB, depending on the network conditions and load level.

Please refer to [Classic Physical Replication](d-pgsql.md#M-S-Replication).



### Warm Standby

> `offline` = Warm Standby, warm standby, does not carry online traffic. Backup, or for offline/analysis queries only.

Please refer to [offline deployment](d-pgsql.md#Offline-Replica).



### Sync Standby

> `standby` = Sync Standby. Strict real-time sync with the primary.

Use sync commit replica, also called sync standby. Please refer to [sync standby deployment](d-pgsql.md#sync-standby) for details.



## Delayed

Delayed is a quick measure of software failure/human error. Changes are received in real-time from the primary using the standard primary-replica stream replication mechanism but are delayed for a specific period (e.g., one hour, a day) before the application is executed. Thus, it is a copy of the historical state of the original primary. When there is a problem like mistaken data deletion, the delay provides a time window to salvage: immediately query the data from the delayed and backfill the original primary.

A delayed can be created using the function [standby cluster](d-pgsql#standby-cluster). For example, now you want to specify a delayed for the `pg-test` cluster: `pg-testdelay`, which is the state of `pg-test` 1 hour ago. If there is a mis-deletion of data, it can be immediately retrieved from the delayed and poured back into the original cluster.

```bash
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



## Cold Standby

> Cold backup is the final cover mechanism.

The cold backup database exists as a static file of the data-dir and is a binary backup of the database dir. Cold backups are the last resort in case of accidental deletion of databases or tables, or catastrophic failure of the whole cluster/whole server room.

Pigsty provides a script for making cold backups `pg-backup`, which can be executed as `dbsu` on the database node to create a full physical backup of the current instance and place it in the `/pg/backup` (by default located in [`{{ pg_fs_bkup }}`](v-pgsql.md#pg_fs_bkup )`/backup`).

With parameters, you can specify the backup database URL, backup-dir, file name, encryption method, retention policy for existing backups, etc.

```bash
$ pg-backup                 # Execute the backup script without any arguments
[2021-08-05 17:41:35][INFO] ================================================================
[2021-08-05 17:41:35][INFO] [INIT] pg-backup begin, checking parameters
[2021-08-05 17:41:35][DEBUG] [INIT] #====== BINARY
[2021-08-05 17:41:35][DEBUG] [INIT] pg_basebackup     :   /usr/pgsql/bin/pg_basebackup
[2021-08-05 17:41:35][DEBUG] [INIT] openssl           :   /bin/openssl
[2021-08-05 17:41:35][DEBUG] [INIT] #====== PARAMETER
[2021-08-05 17:41:35][DEBUG] [INIT] filename  (-f)    :   backup_pg-meta_20210805.tar.lz4
[2021-08-05 17:41:35][DEBUG] [INIT] src       (-s)    :   postgres:///
[2021-08-05 17:41:35][DEBUG] [INIT] dst       (-d)    :   /pg/backup
[2021-08-05 17:41:35][DEBUG] [INIT] tag       (-t)    :   pg-meta
[2021-08-05 17:41:35][DEBUG] [INIT] key       (-k)    :   pg-meta
[2021-08-05 17:41:35][DEBUG] [INIT] encrypt   (-e)    :   false
[2021-08-05 17:41:35][DEBUG] [INIT] upload    (-u)    :   false
[2021-08-05 17:41:35][DEBUG] [INIT] remove    (-r)    :   -mmin +1200
[2021-08-05 17:41:35][INFO] [LOCK] acquire lock @ /tmp/backup.lock
[2021-08-05 17:41:35][INFO] [LOCK] lock acquired success on /tmp/backup.lock, pid=25438
[2021-08-05 17:41:35][INFO] [BKUP] backup begin, from postgres:/// to /pg/backup/backup_pg-meta_20210805.tar.lz4
[2021-08-05 17:41:35][INFO] [BKUP] backup in normal mode
pg_basebackup: initiating base backup, waiting for checkpoint to complete
pg_basebackup: checkpoint completed
pg_basebackup: write-ahead log start point: 0/6B000028 on timeline 1
pg_basebackup: write-ahead log end point: 0/6B000138
pg_basebackup: syncing data to disk ...
pg_basebackup: base backup completed
[2021-08-05 17:41:45][INFO] [BKUP] backup complete!
[2021-08-05 17:41:45][INFO] [RMBK] remove local obsolete backup: 1200
[2021-08-05 17:41:45][INFO] [BKUP] find obsolete backups: find /pg/backup/ -maxdepth 1 -type f -mmin +1200 -name 'backup*.lz4'
[2021-08-05 17:41:45][WARN] [BKUP] remove obsolete backups:
[2021-08-05 17:41:45][INFO] [RMBK] remove old backup complete
[2021-08-05 17:41:45][INFO] [LOCK] release lock @ /tmp/backup.lock
[2021-08-05 17:41:45][INFO] [DONE] backup procdure complete!
[2021-08-05 17:41:45][INFO] ================================================================
```

This script will use `pg_basebackup` to initiate a backup from the specified PGURL (default is the local database instance), using a `tar` archive with `lz4` compression and optional `openssl` RC4 stream encryption.

The backup file is placed in the `/pg/backup/` dir by default, and the default file name consists of a prefix, cluster name, and date, e.g., `backup_pg-meta_20210805.tar.lz4`.

The default backup cleanup policy is to clean up old backup files 1200 minutes (20 hours old) when the latest backup completes.



### Restoring from cold backup

To use this backup, you need to set the cluster to maintenance mode (`pt pause`), stop the data cluster primary, and empty the dataset cluster dir. Then the backup file is unpacked to `/pg/data`.

```bash
# Find the latest backup file and print the information
backup_dir="/pg/backup"
data_dir=/pg/data
backup_latest=$(ls -t ${backup_dir} | head -n1)
echo "backup ${backup_latest} will be used"

# Suspend Patroni, shut down the database, and remove the data directory (dangerous)
pg pause pg-meta
pg_ctl -D /pg/data stop
rm -rf /pg/data/*                                     # Emptying the data directory (dangerous)

# Unzip the backup to the database directory
echo "unlz4 -d -c ${backup_dir}/${backup_latest} | tar -xC ${data_dir}"
unlz4 -d -c ${backup_dir}/${backup_latest} | tar -xC ${data_dir}    # Unzip to the database directory
# Optional: If the password is set when encrypting, you need to decrypt it before decompressing it
openssl enc -rc4 -d -k ${PASSWORD} -in ${backup_latest} | unlz4 -d -c | tar -xC ${data_dir}

# Pull up the database again
systemctl restart patroni

# Redo other replicas of the cluster
pg reinit <cluster> # Reset the other instance members of the cluster in turn
```
