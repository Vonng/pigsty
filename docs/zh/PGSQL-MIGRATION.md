# PostgreSQL 集群迁移

> 如何将现有的 PostgreSQL 集群以最小的停机时间迁移至新的、由Pigsty管理的 PostgreSQL 集群？


Pigsty 内置了一个剧本 [`pgsql-migration.yml`](https://github.com/Vonng/pigsty/blob/master/pgsql-migration.yml) ，基于逻辑复制来实现在线数据库迁移。

通过预生成的自动化脚本，应用停机时间可以缩减到几秒内。但请注意，逻辑复制需要 PostgreSQL 10 以上的版本才能工作。

当然如果您有充足的停机时间预算，那么总是可以使用 `pg_dump | psql` 的方式进行停机迁移。


----------------

## 定义迁移任务

想要使用Pigsty提供的在线迁移剧本，您需要创建一个定义文件，来描述迁移任务的细节。

请查看任务定义文件示例作为参考： [`files/migration/pg-meta.yml`](https://github.com/Vonng/pigsty/blob/master/files/migration/pg-meta.yml) 。

这个迁移任务要将 `pg-meta.meta` 在线迁移到 `pg-test.test`，前者称为 **源集群（SRC）**， 后者称为 **宿集群（DST）**。

```
pg-meta-1	10.10.10.10  --> pg-test-1	10.10.10.11 (10.10.10.12,10.10.10.13)
```

基于逻辑复制的迁移以数据库为单位，您需要指定需要迁移的数据库名称，以及数据库源宿集群主节点的 IP 地址，以及超级用户的连接信息。

```yaml
---
#-----------------------------------------------------------------
# PG_MIGRATION
#-----------------------------------------------------------------
context_dir: ~/migration  # 迁移手册 & 脚本的放置目录
#-----------------------------------------------------------------
# SRC Cluster (旧集群)
#-----------------------------------------------------------------
src_cls: pg-meta      # 源集群名称                  <必填>
src_db: meta          # 源数据库名称                <必填>
src_ip: 10.10.10.10   # 源集群主 IP                <必填>
#src_pg: ''            # 如果定义，使用此作为源 dbsu pgurl 代替：
#                      # postgres://{{ pg_admin_username }}@{{ src_ip }}/{{ src_db }}
#                      # 例如: 'postgres://dbuser_dba:DBUser.DBA@10.10.10.10:5432/meta'
#sub_conn: ''          # 如果定义，使用此作为订阅连接字符串代替：
#                      # host={{ src_ip }} dbname={{ src_db }} user={{ pg_replication_username }}'
#                      # 例如: 'host=10.10.10.10 dbname=meta user=replicator password=DBUser.Replicator'
#-----------------------------------------------------------------
# DST Cluster (新集群)
#-----------------------------------------------------------------
dst_cls: pg-test      # 宿集群名称                  <必填>
dst_db: test          # 宿数据库名称                 <必填>
dst_ip: 10.10.10.11   # 宿集群主 IP                <必填>
#dst_pg: ''            # 如果定义，使用此作为目标 dbsu pgurl 代替：
#                      # postgres://{{ pg_admin_username }}@{{ dst_ip }}/{{ dst_db }}
#                      # 例如: 'postgres://dbuser_dba:DBUser.DBA@10.10.10.11:5432/test'
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

默认情况下，源宿集群两侧的超级用户连接串会使用全局的管理员用户和各自主库的 IP 地址拼接而成，但您总是可以通过 `src_pg` 和 `dst_pg` 参数来覆盖这些默认值。
同理，您也可以通过 `sub_conn` 参数来覆盖订阅连接串的默认值。



----------------

## 生成迁移计划

此剧本不会主动完成集群的迁移工作，但它会生成迁移所需的操作手册与自动化脚本。

默认情况下，你会在 `~/migration/pg-meta.meta` 下找到迁移上下文目录。
按照 `README.md` 的说明，依次执行这些脚本，你就可以完成数据库迁移了！


```bash
# 激活迁移上下文：启用相关环境变量
. ~/migration/pg-meta.meta/activate

# 这些脚本用于检查 src 集群状态，并帮助在 pigsty 中生成新的集群定义
./check-user     # 检查 src 用户
./check-db       # 检查 src 数据库
./check-hba      # 检查 src hba 规则
./check-repl     # 检查 src 复制身份
./check-misc     # 检查 src 特殊对象

# 这些脚本用于在现有的 src 集群和由 pigsty 管理的 dst 集群之间建立逻辑复制，除序列外的数据将实时同步
./copy-schema    # 将模式复制到目标
./create-pub     # 在 src 上创建发布
./create-sub     # 在 dst 上创建订阅
./copy-progress  # 打印逻辑复制进度
./copy-diff      # 通过计数表快速比较 src 和 dst 的差异

# 这些脚本将在在线迁移中运行，该迁移将停止 src 集群，复制序列号（逻辑复制不复制序列号！）
./copy-seq [n]   # 同步序列号，如果给出了 n，则会应用额外的偏移

# 你必须根据你的访问方式（dns,vip,haproxy,pgbouncer等），将应用流量切换至新的集群！
#./disable-src   # 将 src 集群访问限制为管理节点和新集群（你的实现）
#./re-routing    # 从 SRC 到 DST 重新路由应用流量！（你的实现）

# 然后进行清理以删除订阅和发布
./drop-sub       # 迁移后在 dst 上删除订阅
./drop-pub       # 迁移后在 src 上删除发布
```


**注意事项**

如果担心拷贝序列号时出现主键冲突，您可以在拷贝时将所有序列号向前推进一段距离，例如 +1000 ，你可以使用 `./copy-seq` 加一个参数 `1000` 来实现这一点。

你必须实现自己的 `./re-routing` 脚本，以将你的应用流量从 src 路由到 dst。 因为我们不知道你的流量是如何路由的（例如 dns, VIP, haproxy 或 pgbouncer）。 当然，您也可以手动完成这项操作...

你可以实现一个 `./disable-src` 脚本来限制应用对 src 集群的访问，这是可选的：如果你能确保所有应用流量都在 `./re-routing` 中干净利落地切完，其实不用这一步。

但如果您有未知来源的各种访问无法梳理干净，那么最好使用更为彻底的方式：更改 HBA 规则并重新加载来实现（推荐），或者只是简单粗暴地关停源主库上的 postgres、pgbouncer 或 haproxy 进程。
