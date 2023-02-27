# PGSQL Backup & Point-In-Time-Recovery

> Pigsty uses [pgBackRest](https://pgbackrest.org/) for PITR backup & restore.

In the case of a hardware failure, a physical replica failover could be the best choice. Whereas for data corruption scenarios (whether machine or human errors), Point-in-Time Recovery (PITR) is often more appropriate.



## Backup

Use the following command to perform the [backup](https://pgbackrest.org/command.html#command-backup):

```bash
# stanza name = {{ pg_cluster }} by default
pgbackrest --stanza=${stanza} --type=full|diff|incr backup

# you can also use the following command in pigsty (/pg/bin/pg-backup)
pg-backup       # make a backup, incr, or full backup if necessary
pg-backup full  # make a full backup
pg-backup diff  # make a differential backup
pg-backup incr  # make a incremental backup
```

Use the following command to print backup info:

```bash
pb info  # print backup info
```

You can also acquire backup info from the monitoring system: [PGCAT Instance - Backup](http://demo.pigsty.cc/d/pgcat-instance/pgcat-instance?from=now-1h&to=now&var-job=pgsql&var-ds=Prometheus&orgId=1&viewPanel=158)


<details><summary>Backup Info Example</summary>

```bash
$ pb info
stanza: pg-meta
    status: ok
    cipher: none

    db (current)
        wal archive min/max (14): 000000010000000000000001/000000010000000000000023

        full backup: 20221108-105325F
            timestamp start/stop: 2022-11-08 10:53:25 / 2022-11-08 10:53:29
            wal start/stop: 000000010000000000000004 / 000000010000000000000004
            database size: 96.6MB, database backup size: 96.6MB
            repo1: backup set size: 18.9MB, backup size: 18.9MB

        incr backup: 20221108-105325F_20221108-105938I
            timestamp start/stop: 2022-11-08 10:59:38 / 2022-11-08 10:59:41
            wal start/stop: 00000001000000000000000F / 00000001000000000000000F
            database size: 246.7MB, database backup size: 167.3MB
            repo1: backup set size: 35.4MB, backup size: 20.4MB
            backup reference list: 20221108-105325F
```

</details>



## Restore

Use the following command to perform [restore](https://pgbackrest.org/command.html#command-restore)

```
pg-pitr                                 # restore to wal archive stream end (e.g. used in case of entire DC failure)
pg-pitr -i                              # restore to the time of latest backup complete (not often used)
pg-pitr --time="2022-12-30 14:44:44+08" # restore to specific time point (in case of drop db, drop table)
pg-pitr --name="my-restore-point"       # restore TO a named restore point create by pg_create_restore_point
pg-pitr --lsn="0/7C82CB8" -X            # restore right BEFORE a LSN
pg-pitr --xid="1234567" -X -P           # restore right BEFORE a specific transaction id, then promote
pg-pitr --backup=latest                 # restore to latest backup set
pg-pitr --backup=20221108-105325        # restore to a specific backup set, which can be checked with pgbackrest info

pg-pitr                                 # pgbackrest --stanza=pg-meta restore
pg-pitr -i                              # pgbackrest --stanza=pg-meta --type=immediate restore
pg-pitr -t "2022-12-30 14:44:44+08"     # pgbackrest --stanza=pg-meta --type=time --target="2022-12-30 14:44:44+08" restore
pg-pitr -n "my-restore-point"           # pgbackrest --stanza=pg-meta --type=name --target=my-restore-point restore
pg-pitr -b 20221108-105325F             # pgbackrest --stanza=pg-meta --type=name --set=20221230-120101F restore
pg-pitr -l "0/7C82CB8" -X               # pgbackrest --stanza=pg-meta --type=lsn --target="0/7C82CB8" --target-exclusive restore
pg-pitr -x 1234567 -X -P                # pgbackrest --stanza=pg-meta --type=xid --target="0/7C82CB8" --target-exclusive --target-action=promote restore
```

The `pg-pitr` script will generate instructions for you to perform PITR. 

For example, if you wish to rollback current cluster status back to `"2023-02-07 12:38:00+08"`:

```bash
$ pg-pitr -t "2023-02-07 12:38:00+08"
pgbackrest --stanza=pg-meta --type=time --target='2023-02-07 12:38:00+08' restore
Perform time PITR on pg-meta
[1. Stop PostgreSQL] ===========================================
   1.1 Pause Patroni (if there are any replicas)
       $ pg pause <cls>  # pause patroni auto failover
   1.2 Shutdown Patroni
       $ pt-stop         # sudo systemctl stop patroni
   1.3 Shutdown Postgres
       $ pg-stop         # pg_ctl -D /pg/data stop -m fast

[2. Perform PITR] ===========================================
   2.1 Restore Backup
       $ pgbackrest --stanza=pg-meta --type=time --target='2023-02-07 12:38:00+08' restore
   2.2 Start PG to Replay WAL
       $ pg-start        # pg_ctl -D /pg/data start
   2.3 Validate and Promote
     - If database content is ok, promote it to finish recovery, otherwise goto 2.1
       $ pg-promote      # pg_ctl -D /pg/data promote

[3. Restart Patroni] ===========================================
   3.1 Start Patroni
       $ pt-start;        # sudo systemctl start patroni
   3.2 Enable Archive Again
       $ psql -c 'ALTER SYSTEM SET archive_mode = on; SELECT pg_reload_conf();'
   3.3 Restart Patroni
       $ pt-restart      # sudo systemctl start patroni

[4. Restore Cluster] ===========================================
   3.1 Re-Init All Replicas (if any replicas)
       $ pg reinit <cls> <ins>
   3.2 Resume Patroni
       $ pg resume <cls> # resume patroni auto failover
   3.2 Make Full Backup (optional)
       $ pg-backup full  # pgbackrest --stanza=pg-meta backup --type=full
```





## Policy

You can customize your backup policy with [`node_crontab`](PARAM#node_crontab) and [`pgbackrest_repo`](PARAM#pgbackrest_repo)

* Schedule full or incr backup with [`node_crontab`](PARAM#node_crontab)
* setup backup retention policy with [`pgbackrest_repo`](PARAM#pgbackrest_repo)


**local repo**

For example, the default `pg-meta` will take a full backup every day at 1 am.

```
node_crontab:  # make a full backup 1 am everyday
  - '00 01 * * * postgres /pg/bin/pg-backup full'
```

With the default local repo retention policy, it will keep at most two full backups and temporarily allow three during backup.

```yaml
pgbackrest_repo:                  # pgbackrest repo: https://pgbackrest.org/configuration.html#section-repository
  local:                          # default pgbackrest repo with local posix fs
    path: /pg/backup              # local backup directory, `/pg/backup` by default
    retention_full_type: count    # retention full backups by count
    retention_full: 2             # keep 2, at most 3 full backup when using local fs repo
```

Your backup disk storage should be at least three x database file size + WAL archive in 3 days.

**MinIO repo**

When using MinIO, storage capacity is usually not a problem. You can keep backups as long as you want.

For example, the default `pg-test` will take a full backup on Monday and incr backup on other weekdays.

```yaml
node_crontab:  # make a full backup 1 am everyday
  - '00 01 * * 1 postgres /pg/bin/pg-backup full'
  - '00 01 * * 2,3,4,5,6,7 postgres /pg/bin/pg-backup'
```

And with a 14-day time retention policy, backup in the last two weeks will be kept. But beware, this guarantees a week's PITR period only.

```yaml
pgbackrest_repo:                  # pgbackrest repo: https://pgbackrest.org/configuration.html#section-repository=
  minio:                          # optional minio repo for pgbackrest
    type: s3                      # minio is s3-compatible, so s3 is used
    s3_endpoint: sss.pigsty       # minio endpoint domain name, `sss.pigsty` by default
    s3_region: us-east-1          # minio region, us-east-1 by default, useless for minio
    s3_bucket: pgsql              # minio bucket name, `pgsql` by default
    s3_key: pgbackrest            # minio user access key for pgbackrest
    s3_key_secret: S3User.Backup  # minio user secret key for pgbackrest
    s3_uri_style: path            # use path style uri for minio rather than host style
    path: /pgbackrest             # minio backup path, default is `/pgbackrest`
    storage_port: 9000            # minio port, 9000 by default
    storage_ca_file: /etc/pki/ca.crt  # minio ca file path, `/etc/pki/ca.crt` by default
    bundle: y                     # bundle small files into a single file
    cipher_type: aes-256-cbc      # enable AES encryption for remote backup repo
    cipher_pass: pgBackRest       # AES encryption password, default is 'pgBackRest'
    retention_full_type: time     # retention full backup by time on minio repo
    retention_full: 14            # keep full backup for last 14 days
```

