# PostgreSQL 备份与PITR

> Pigsty 使用 [pgBackRest](https://pgbackrest.org/) 进行 PITR 备份和恢复。

对于硬件故障来说，基于物理复制的高可用故障切换可能会是最佳选择。而对于数据损坏（无论是机器还是人为错误），时间点恢复（PITR）则更为合适：它提供了对最坏情况的兜底。



----------------

## 备份

使用以下命令[备份](https://pgbackrest.org/command.html#command-backup) PostgreSQL 数据库集群：


```bash
# stanza 是 pgbackrest 在同一个存储库中区别不同的集群的标识，默认 stanza 名称 = {{ pg_cluster }}
pgbackrest --stanza=${stanza} --type=full|diff|incr backup

# 你也可以在 pigsty 中使用 dbsu 执行以下命令 (/pg/bin/pg-backup) 进行备份
pg-backup       # 执行备份，如有必要，执行增量或全量备份
pg-backup full  # 执行全量备份
pg-backup diff  # 执行差异备份
pg-backup incr  # 执行增量备份
```

使用以下命令打印备份信息：

```bash
pb info   # pgbackrest info 打印备份信息
```

<details><summary>备份信息示例</summary>

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

您也可以从监控系统查阅备份信息：[PGCAT 实例 - 备份](https://demo.pigsty.cc/d/pgcat-instance/pgcat-instance?viewPanel=158)



----------------

## 恢复

以下命令可以用于 PostgreSQL 数据库集群的 [恢复](https://pgbackrest.org/command.html#command-restore)

```
pg-pitr                                 # 恢复到WAL存档流的结束位置（例如在整个数据中心故障的情况下使用）
pg-pitr -i                              # 恢复到最近备份完成的时间（不常用）
pg-pitr --time="2022-12-30 14:44:44+08" # 恢复到指定的时间点（在删除数据库或表的情况下使用）
pg-pitr --name="my-restore-point"       # 恢复到使用 pg_create_restore_point 创建的命名恢复点
pg-pitr --lsn="0/7C82CB8" -X            # 在LSN之前立即恢复
pg-pitr --xid="1234567" -X -P           # 在指定的事务ID之前立即恢复，然后将集群直接提升为主库
pg-pitr --backup=latest                 # 恢复到最新的备份集
pg-pitr --backup=20221108-105325        # 恢复到特定备份集，备份集可以使用 pgbackrest info 列出

pg-pitr                                 # pgbackrest --stanza=pg-meta restore
pg-pitr -i                              # pgbackrest --stanza=pg-meta --type=immediate restore
pg-pitr -t "2022-12-30 14:44:44+08"     # pgbackrest --stanza=pg-meta --type=time --target="2022-12-30 14:44:44+08" restore
pg-pitr -n "my-restore-point"           # pgbackrest --stanza=pg-meta --type=name --target=my-restore-point restore
pg-pitr -b 20221108-105325F             # pgbackrest --stanza=pg-meta --type=name --set=20221230-120101F restore
pg-pitr -l "0/7C82CB8" -X               # pgbackrest --stanza=pg-meta --type=lsn --target="0/7C82CB8" --target-exclusive restore
pg-pitr -x 1234567 -X -P                # pgbackrest --stanza=pg-meta --type=xid --target="0/7C82CB8" --target-exclusive --target-action=promote restore
``` 

Pigsty 提供的 `pg-pitr` 脚本会帮助您生成进行 PITR 指令，例如，如果您希望将当前集群状态回滚至 `"2023-02-07 12:38:00+08"`：

```bash
$ pg-pitr -t "2023-02-07 12:38:00+08"
pgbackrest --stanza=pg-meta --type=time --target='2023-02-07 12:38:00+08' restore
执行pg-meta时间点恢复
[1. 停止PostgreSQL] ===========================================
   1.1 暂停Patroni（如果有任何副本）
       $ pg pause <cls>  # 暂停patroni自动故障转移
   1.2 关闭Patroni
       $ pt-stop         # sudo systemctl stop patroni
   1.3 关闭Postgres
       $ pg-stop         # pg_ctl -D /pg/data stop -m fast

[2. 执行PITR] ===========================================
   2.1 恢复备份
       $ pgbackrest --stanza=pg-meta --type=time --target='2023-02-07 12:38:00+08' restore
   2.2 启动PG以重放WAL
       $ pg-start        # pg_ctl -D /pg/data start
   2.3 验证并提升
     - 如果数据库内容正确，提升它以完成恢复，否则转到2.1
       $ pg-promote      # pg_ctl -D /pg/data promote

[3. 重启Patroni] ===========================================
   3.1 启动Patroni
       $ pt-start;        # sudo systemctl start patroni
   3.2 再次启用归档
       $ psql -c 'ALTER SYSTEM SET archive_mode = on; SELECT pg_reload_conf();'
   3.3 重启Patroni
       $ pt-restart      # sudo systemctl start patroni

[4. 恢复集群] ===========================================
   3.1 重新初始化所有副本（如果有任何副本）
       $ pg reinit <cls> <ins>
   3.2 恢复Patroni
       $ pg resume <cls> # 恢复patroni自动故障转移
   3.2 完整备份（可选）
       $ pg-backup full  # pgbackrest --stanza=pg-meta backup --type=full
```

安装说明依次操作，即可完成集群的恢复。



----------------

## 备份策略

您可以使用[`node_crontab`](PARAM#node_crontab) 和 [`pgbackrest_repo`](PARAM#pgbackrest_repo)自定义备份策略。

- 使用[`node_crontab`](PARAM#node_crontab)设置定时备份任务
- 使用[`pgbackrest_repo`](PARAM#pgbackrest_repo)设置备份保留策略

**本地备份仓库**

例如，默认的`pg-meta`将每天凌晨1点进行一次全量备份。

```bash
node_crontab:  # 每天凌晨1点进行全量备份
  - '00 01 * * * postgres /pg/bin/pg-backup full'
```

使用默认的本地备份仓库保留策略，它最多保留两个完整备份，在备份过程中临时允许第三个备份存在。

```yaml
pgbackrest_repo:                  # pgbackrest 仓库定义: https://pgbackrest.org/configuration.html#section-repository
  local:                          # 默认使用本地文件系统的 pgbackrest 备份仓库
    path: /pg/backup              # 本地备份目录，默认为`/pg/backup`
    retention_full_type: count    # 指定全量备份保留数量：2
    retention_full: 2             # 使用本地文件系统仓库时，最多保留2个完整备份，备份时临时允许3个
```

您的备份磁盘存储空间至少应该能放下最近三个数据库全量备份文件，以及这段期间（3天）内的WAL归档文件。



**MinIO备份仓库**

使用MinIO时，存储容量通常不是问题。您可以按需保留备份。例如，默认的`pg-test`将在星期一进行全量备份，其他工作日进行增量备份。

```yaml
node_crontab:  # 周一凌晨1点进全量备份，其他工作日进行增量备份
  - '00 01 * * 1 postgres /pg/bin/pg-backup full'
  - '00 01 * * 2,3,4,5,6,7 postgres /pg/bin/pg-backup'
```

MinIO备份仓库可以使用14天的时间保留策略，这将保留最近两周内的备份。

```yaml
pgbackrest_repo:                  # pgbackrest 仓库: https://pgbackrest.org/configuration.html#section-repository=
  minio:                          # pgbackrest 的可选minio仓库
    type: s3                      # minio 是s3兼容的，因此使用s3
    s3_endpoint: sss.pigsty       # minio终端域名，默认为`sss.pigsty`
    s3_region: us-east-1          # minio区域，默认为us-east-1，对minio来说没有用
    s3_bucket: pgsql              # minio桶名，默认为`pgsql`
    s3_key: pgbackrest            # pgbackrest的minio用户访问密钥
    s3_key_secret: S3User.Backup  # pgbackrest的minio用户密钥，这里请按实际情况填写密码，最好不要使用默认密码。
    s3_uri_style: path            # 使用路径风格的uri，而不是主机风格的uri
    path: /pgbackrest             # minio备份路径，默认为`/pgbackrest`
    storage_port: 9000            # minio端口，默认为9000
    storage_ca_file: /etc/pki/ca.crt  # minio的ca文件路径，默认为`/etc/pki/ca.crt`
    bundle: y                     # 将小文件打包成一个文件
    cipher_type: aes-256-cbc      # 为远程备份仓库启用AES加密
    cipher_pass: pgBackRest       # AES加密密码，默认为'pgBackRest'，这里最好按需修改以下
    retention_full_type: time     # 在minio仓库上按时间保留完整备份
    retention_full: 14            # 保留过去14天的完整备份
```

