# Backup and Recovery

> Backup & Recovery matters.

Backup is the foundation of DBA's life and one of the most critical tasks in database management. Only physical backups are discussed here. Physical backups can usually be classified into the following four types.



## Backup Types

### Hot Standby

It is consistent with the master and takes over when the master fails and is also used to take over online read-only traffic. One of the hot spares that use synchronous replication to keep up with the master in real-time can also be called synchronous backup.


### Warm Standby

Warm Standby: Similar to a hot standby, but does not carry online traffic. Usually, a database cluster needs a delayed standby so that it can recover in time in case of an error (e.g. data deletion by mistake). In this case, the delayed standby cannot serve online queries because its content is not the same as the primary.

### Code Backup

Cold Backup: The cold backup database exists as a static file of the data directory and is a binary backup of the database dir. Easy to make, easy to manage, and easy to put into other AZ to achieve disaster recovery. It is the ultimate insurance for the database.


In Pigsty, a hot standby can be created by assigning roles (`pg_role`) to database instances in the cluster for recovery from machine and hardware failures. However, logical errors (mistakenly deleted libraries, mistakenly deleted tables) can only be repaired using cold or warm spares.
In the case of mistaken deletion of libraries and tables, or catastrophic failure of the whole cluster/house, data backup (cold backup) is the last resort

> Currently, (Pigsty 1.4.0), warm (`offline`), and synchronous (`standby`) backups are not implemented and have the same effect as hot (`replica`) standbys.



## Cold backup

In the current version (1.4.0), Pigsty provides a **backup mechanism** but does not set a default **backup policy**. Users should make a **cold backup plan** according to their data reliability requirements, hardware config, and disk capacity.

A basic backup policy is to do WAL archiving on the master of the cluster (enabled by default and kept for one day) and full backup (daily backup) via crontab on the slave, which allows you to roll back to any state within a day. A more flexible and advanced way of backup is to use a separate instance as an offline delayed slave.

Pigsty has a built-in simple backup script: `pg-backup`, which can be executed locally as `dbsu` to create a full physical backup of the current instance in the `/pg/backup` dir.
The user can specify the backup database URL, backup-dir, file name, encryption method, retention policy for existing backups, etc. with parameters.


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
The default backup cleanup policy is to clean up old backup files that are 1200 minutes old (20 hours old) when the latest backup completes.

## Restoring from a backup

To use this backup, you need to set the cluster to maintenance mode (`pt pause`) and stop the data cluster master and empty the dataset cluster dir Then the backup file is unpacked to `/pg/data`.

```bash
backup_dir="/pg/backup"
data_dir=/pg/data

backup_latest=$(ls -t ${backup_dir} | head -n1)       # find latest backup
rm -rf /pg/data/*                                     # clean up existing folder (dangerous)
unlz4 -d -c ${backup_latest} | tar -xC ${data_dir}    # extract backup into data dir

# optional: if encryption set, unencrypted with openssl & password before extraction
openssl enc -rc4 -d -k ${PASSWORD} -in ${backup_latest} | unlz4 -d -c | tar -xC ${data_dir}
```
