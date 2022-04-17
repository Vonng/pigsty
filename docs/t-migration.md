# Migration Tutorial

There's an auxiliary playbook [`pgsql-migration.yml`](p-pgsql.md#pgsql-migration) which provides a battery ，提供了一个开箱即用的基于逻辑复制的不停机数据库迁移方案。

填入源集群与宿集群相关信息，该剧本即会自动创建出迁移中所需的脚本，在数据库迁移时只需要依次执行即可，包括：

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

执行`pgsql-migration.yml`，该脚本默认会在管理节点上创建 `~/migration/pg-meta.meta` 目录，包含有迁移使用的资源与脚本。



## Templates

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
