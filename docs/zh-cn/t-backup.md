# 备份与恢复

备份是DBA的安身立命之本，也是数据库管理中最为关键的工作之一。这里仅讨论物理备份，物理备份通常可以分为以下四种：

## 备份的分类

### 热备（Hot Standby）  

与主库保持一致，当主库出现故障时会接管主库的工作，同时也会用于承接线上只读流量。其中，采用同步复制与主库保持实时一致的热备又可以称为同步备份。

### 温备（Warm Standby）

温备（Warm Standby）：与热备类似，但不承载线上流量。通常数据库集群需要一个延迟备库，以便出现错误（例如误删数据）时能及时恢复。在这种情况下，因为延迟备库与主库内容不一致，因此不能服务线上查询。

### 冷备（Code Backup）

冷备（Code Backup）：冷备数据库以数据目录静态文件的形式存在，是数据库目录的二进制备份。便于制作，管理简单，便于放到其他AZ实现容灾。是数据库的最终保险。


在Pigsty中，可以通过为集群中的数据库实例指定角色（ `pg_role` ），可以创建热备，用于从机器与硬件故障中恢复。但逻辑错误（误删库，误删表）只能使用冷备或温备修复。
误删库误删表，或整集群/整机房出现灾难性故障时，数据备份（冷备）是最后的兜底

> 目前（Pigsty v1.0.0）温备（`offline`），同步备份（`standby`）并未实现，效果与热备（`replica`） 相同。


## 冷备份

当前版本（v1.0.0）中，Pigsty提供了**备份机制**，但不设置默认的**备份策略**。用户应当根据自身的数据可靠性要求，硬件配置，磁盘容量制定**冷备份计划**。

一种基本的备份策略是在集群的主库上进行WAL归档（默认启用，保留一天），在从库上通过crontab进行全量备份（每日备份），这样允许您将回滚至一天内的任意状态。更灵活与高级的备份方式是使用一个单独的实例作为离线延时从库。

Pigsty内置了一个简易备份脚本：`pg-backup`，以`dbsu`身份在本机执行即可创建当前实例的全量物理备份，放置于 `/pg/backup` 目录中。
用户可以通过参数来指定备份的数据库URL，备份目录，文件名，加密方式，已有备份的保留策略等。


```bash
$ pg-backup # 不带任何参数执行备份脚本
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

该脚本将使用 `pg_basebackup` 从指定的PGURL（默认为本地数据库实例）发起备份，使用`tar`归档与`lz4`压缩，并加以可选的`openssl` RC4流加密。
备份文件默认放置于`/pg/backup/`目录下，默认文件名由前缀，集群名，日期组成，形如：`backup_pg-meta_20210805.tar.lz4`。
默认的备份清理策略是当最新备份完成时，会清理掉1200分钟（20小时前）的旧备份文件。


## 从备份中恢复

需要使用该备份时，您需要将集群设置为维护模式（`pt pause`）并停止数据集群主库并清空数据集簇目录，然后备份文件解压至`/pg/data`中。

```bash
backup_dir="/pg/backup"
data_dir=/pg/data

backup_latest=$(ls -t ${backup_dir} | head -n1)       # 找到最新的备份文件
rm -rf /pg/data/*                                     # 清空数据目录（危险）
unlz4 -d -c ${backup_latest} | tar -xC ${data_dir}    # 解压至数据库目录

# 可选：如果加密时设置了密码，则需要先解密再解压
openssl enc -rc4 -d -k ${PASSWORD} -in ${backup_latest} | unlz4 -d -c | tar -xC ${data_dir}
```
