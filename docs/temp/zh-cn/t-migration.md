# 数据库迁移教程

Pigsty内置了一个 数据库在线迁移的辅助脚本：[`pgsql-migration.yml`](p-pgsql.md#pgsql-migration) ，提供了一个开箱即用的基于逻辑复制的不停机数据库迁移方案。

填入源集群与宿集群相关信息，该剧本即会自动创建出迁移中所需的脚本，在数据库迁移时只需要依次执行即可，包括：

```bash
activate                          # 激活迁移上下文，注册环境变量
check-replica-identity            # 准备阶段：检查源集群所有表是否都具有复制身份（主键，或非空唯一候选键）
check-replica-identity-solution   # 准备阶段：针对没有合理复制身份表，生成修复SQL语句
check-special-object              # 准备阶段：检查物化视图，复合类型等特殊对象
compare                           # 比较：对源宿集群中的表进行快速比较（行数计算）
copy-schema                       # 存量迁移：将源集群中的模式复制到宿集群中（可以幂等执行）
create-pub                        # 存量迁移：在源集群中创建发布
create-sub                        # 存量迁移：在宿集群中创建订阅，建立源宿集群之间的逻辑复制
progress                          # 存量迁移：打印逻辑复制的进度
copy-seq                          # 存量/增量迁移：将源集群中的序列号复制到宿集群中（可以幂等执行，在切换时需要再次执行）
next-seq                          # 切换时刻：将宿集群的所有序列号紧急步进1000，以避免主键冲突。
remove-sub                        # 移除宿集群中的逻辑订阅
```


## 准备工作

### 准备源宿集群

现在假设我们希望迁移沙箱中的`pg-meta`集群（包含Pigsty元数据库与pgbench测试表）至`pg-test`集群。

```bash
pg-meta-1	10.10.10.10  --> pg-test-1	10.10.10.11 (10.10.10.12,10.10.10.13)
```

首先，新创建好空的目标集群`pg-test`，然后编辑`pgsql-migration.yml` 中的变量清单部分，填入相关信息（原宿集群主库的连接信息）

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

执行`pgsql-migration.yml`，该脚本默认会在元节点上创建 `~/migration/pg-meta.meta` 目录，包含有迁移使用的资源与脚本。


## 迁移模板

[**公告**](#公告)

* [操作周知](#操作周知)
* [业务方周知](#业务方周知)

[**准备工作**](#准备工作)

* [ ] [准备源宿集群](#准备源宿集群)
* [ ] [修复源库HBA](#修复源库HBA)
* [ ] [创建源库复制用户](#创建源库复制用户)
* [ ] [外部资源申请](#外部资源申请)
* [ ] [创建集群配置文件](#创建集群配置文件)
* [ ] [配置业务用户](#配置业务用户)
* [ ] [配置业务数据库](#配置业务数据库)
* [ ] [配置业务白名单](#配置业务白名单)
* [ ] [创建业务集群](#创建业务集群)
* [ ] [修复复制标识](#修复复制标识)
* [ ] [确定迁移对象](#确定迁移对象)
* [ ] [生成模式同步命令](#生成模式同步命令)
* [ ] [生成序列号同步命令](#生成序列号同步命令)
* [ ] [生成创建发布命令](#生成创建发布命令)
* [ ] [生成创建订阅命令](#生成创建订阅命令)
* [ ] [生成进度检查命令](#生成进度检查命令)
* [ ] [生成校验命令](#生成校验命令)

[**存量迁移**](#存量迁移)

- [ ] [同步数据库模式](#同步数据库模式)
- [ ] [在源端创建发布](#在源端创建发布)
- [ ] [在宿端创建订阅](#在宿端创建订阅)
- [ ] [等待逻辑复制同步](#等待逻辑复制同步)

[**切换时刻**](#切换时刻)

- [ ] [准备工作](#准备工作)
- [ ] [停止源端写入流量](#停止源端写入流量)
- [ ] [同步序列号与其他对象](#同步序列号与其他对象)
- [ ] [校验数据一致性](#同步序列号与其他对象)
- [ ] [流量切换](#流量切换)
- [ ] [善后工作](#善后工作)
