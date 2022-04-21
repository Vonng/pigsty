# 备份与恢复

> 备份是DBA的安身立命之本，也是数据库管理中最为关键的工作之一。

故障大体可以分为两类：硬件故障/资源不足（坏盘/宕机），软件缺陷/人为错误（删库/删表）。基于主从复制的物理复制用于应对前者，延迟从库与冷备份通常用于应对后者。

Pigsty提供了完善的备份支持，无需配置即可使用开箱即用的主从物理复制，绝大多数物理故障均可自愈。同时，还提供了延迟备库与冷备份支持，用于应对软件故障与人为误操作。

* [物理复制](#物理复制) （热备/温备）
* [延迟从库](#延迟从库)
* [冷备份](#冷备份)



## 物理复制

在Pigsty中，可以通过为集群中的数据库实例指定角色（ `pg_role` ），即可以创建物理复制备份，用于从机器与硬件故障中恢复。例如以下配置声明了一个一主两从的高可用数据库集群。

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary } # 主库
    10.10.10.12: { pg_seq: 2, pg_role: replica } # 热备（承载在线只读流量）
    10.10.10.13: { pg_seq: 3, pg_role: offline } # 温备（不承载在线流量）
  vars:
    pg_cluster: pg-test
```



### 热备

> `replica` = Hot Standby，承载只读流量，与主库保持实时同步，但可能存在微量复制延迟。

与主库保持一致，当主库出现故障时会接管主库的工作，同时也会用于承接线上只读流量。其中，采用同步复制与主库保持实时一致的热备又可以称为同步备份。正常情况下，物理复制的复制延迟视网络条件与负载水平，可能在1ms-100ms/几十KB ～ 几MB的范围。

请参考[经典物理副本](d-pgsql.md#主从集群)。



### 温备

> `offline` = Warm Standby，温备，不承担在线流量。备用，或仅用于离线/分析查询。

温备（Warm Standby）：与热备类似，但不承载线上流量。

请参考[离线从库部署](d-pgsql.md#离线从库)。



### 同步备库

> `standby` = Sync Standby，与主库保持严格实时同步。

请参考[同步从库部署](d-pgsql.md#同步从库)







## 延迟从库

延迟从库相比是一种快速应对软件故障/人为错误的措施。延迟从库采用标准的主从流复制机制从主库实时接收变更，但会延迟一段特定时间（例如1小时，一天）后再执行应用。因此在状态上，是原始主库的历史状态副本。当出现诸如误删数据这类问题时，实时主从同步会立即将此类变更同步至所有物理副本，但延迟从库则提供了一个抢救时间窗口：您可以立即从延迟从库中查询出数据并回补原主库。

高可用与主从复制可以解决机器硬件故障带来的问题，但无法解决软件Bug与人为操作导致的故障，例如：误删库删表。误删数据通常需要用到[冷备份](t-backup.md)，但另一种更优雅高效快速的方式是事先准备一个延迟从库。

您可以使用 [备份集群](#备份集群) 的功能创建延时从库，例如，现在您希望为`pg-test` 集群指定一个延时从库：`pg-testdelay`，该集群是`pg-test`1小时前的状态。因此如果出现了误删数据，您可以立即从延时从库中获取并回灌入原始集群中。


```yaml
# pg-test是原始数据库
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
  vars:
    pg_cluster: pg-test
    pg_version: 14

# pg-testdelay 将作为 pg-test 库的延时从库
pg-testdelay:
  hosts:
    10.10.10.12: { pg_seq: 1, pg_role: primary , pg_upstream: 10.10.10.11 } # 实际角色为 Standby Leader
  vars:
    pg_cluster: pg-testdelay
    pg_version: 14          
```

创建完毕后，在元节点使用 `pg edit-config pg-testdelay`编辑延时集群的Patroni配置文件，修改 `standby_cluster.recovery_min_apply_delay` 为你期待的值，例如`1h`，应用即可。

```bash
 standby_cluster:
   create_replica_methods:
   - basebackup
   host: 10.10.10.11
   port: 5432
+  recovery_min_apply_delay: 1h
```











## 冷备份

> 冷备份是最后的兜底机制，您可能几年都用不上一次，但真用上的时候，可以救命。 

冷备（Code Backup）：冷备数据库以数据目录静态文件的形式存在，是数据库目录的二进制备份。便于制作，管理简单，便于放到其他AZ实现容灾。误删库误删表，或整集群/整机房出现灾难性故障时，数据备份（冷备）是最后的兜底。

Pigsty提供了一个制作冷备份的脚本 `pg-backup`，在数据库节点上以`dbsu`身份执行，即可创建当前实例的全量物理备份，并放置于 `/pg/backup` 目录中（默认位于 [`{{ pg_fs_bkup }}`](v-pgsql.md#pg_fs_bkup)`/backup`）。
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

您需要根据自己的业务情况，使用该脚本制作备份并放置在合适的地方，例如专用的对象存储集群/NFS/或者本地备份盘。如果您希望将数据库回溯至任意时刻，而非仅仅回滚至数据库备份时刻，则还需要对集群WAL日志进行归档。因为此功能需要具体功能具体分析，因此Pigsty只提供工具与机制，不提供具体策略与实现。您可以使用配置于节点上的Crontab与本地目录作为最基本的冷备份实现。




### 从备份中恢复

需要使用该备份时，您需要将集群设置为维护模式（`pg pause <cluster>`）并停止数据集群主库并清空数据集簇目录，然后备份文件解压至`/pg/data`中。

```bash
# 找到最新的备份文件并打印信息
backup_dir="/pg/backup"
data_dir=/pg/data
backup_latest=$(ls -t ${backup_dir} | head -n1)
echo "backup ${backup_latest} will be used"

# 暂停Patroni，关停数据库，移除数据目录（危险）
pg pause pg-meta
pg_ctl -D /pg/data stop
rm -rf /pg/data/*                                     # 清空数据目录（危险）

# 解压备份至数据库目录
echo "unlz4 -d -c ${backup_dir}/${backup_latest} | tar -xC ${data_dir}"
unlz4 -d -c ${backup_dir}/${backup_latest} | tar -xC ${data_dir}    # 解压至数据库目录
# 可选：如果加密时设置了密码，则需要先解密再解压
openssl enc -rc4 -d -k ${PASSWORD} -in ${backup_latest} | unlz4 -d -c | tar -xC ${data_dir}

# 重新拉起数据库
systemctl restart patroni


```
