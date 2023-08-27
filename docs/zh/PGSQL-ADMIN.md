# PostgreSQL 管理预案

> 本文整理了 Pigsty 中常用的 PostgreSQL 管理预案，用于维护生产环境中的数据库集群。

这里是一些常见 PostgreSQL 管理任务的 SOP 预案：

- 案例1：  [创建集群](#创建集群)
- 案例2：  [创建用户](#创建用户)
- 案例3：  [创建数据库](#创建数据库)
- 案例4：  [重载服务](#重载服务)
- 案例5：  [重载HBA](#重载HBA)
- 案例6：  [配置集群](#配置集群)
- 案例7：  [添加实例](#添加实例)
- 案例8：  [移除实例](#移除实例)
- 案例9：  [下线集群](#下线集群)
- 案例10： [主动切换](#主动切换)
- 案例11： [备份集群](#备份集群)
- 案例12： [恢复集群](#恢复集群)
- 案例13： [添加软件](#添加软件)
- 案例14： [安装扩展](#安装扩展)
- 案例15： [小版本升级](#小版本升级)
- 案例16： [大版本升级](#大版本升级)


----------------

## 命令速查

PGSQL 剧本与快捷方式：

```bash
bin/pgsql-add   <cls>                   # 创建 pgsql 集群 <cls>
bin/pgsql-user  <cls> <username>        # 在 <cls> 上创建 pg 用户 <username>
bin/pgsql-db    <cls> <dbname>          # 在 <cls> 上创建 pg 数据库 <dbname>
bin/pgsql-svc   <cls> [...ip]           # 重新加载集群 <cls> 的 pg 服务
bin/pgsql-hba   <cls> [...ip]           # 重新加载集群 <cls> 的 postgres/pgbouncer HBA 规则
bin/pgsql-add   <cls> [...ip]           # 为集群 <cls> 添加从库副本
bin/pgsql-rm    <cls> [...ip]           # 从集群 <cls> 移除实例
bin/pgsql-rm    <cls>                   # 删除 pgsql 集群 <cls>
```

Patroni 管理命令与快捷方式：

```bash
pg list        <cls>                    # 打印集群信息
pg edit-config <cls>                    # 编辑集群配置
pg reload      <cls> [ins]              # 重新加载集群配置
pg restart     <cls> [ins]              # 重启 PostgreSQL 集群
pg reinit      <cls> [ins]              # 重新初始化集群成员
pg pause       <cls>                    # 进入维护模式（自动故障转移暂停）
pg resume      <cls>                    # 退出维护模式
pg switchover  <cls>                    # 在集群 <cls> 上进行主动主从切换（主库健康）
pg failover    <cls>                    # 在集群 <cls> 上进行故障转移（主库故障）
```

pgBackRest 备份/恢复命令与快捷方式：

```bash
pb info                                 # 打印 pgbackrest 备份仓库信息
pg-backup                               # 进行备份，默认进行增量备份，如果没有完整备份过就做全量备份
pg-backup full                          # 进行全量备份
pg-backup diff                          # 进行差异备份
pg-backup incr                          # 进行增量备份
pg-pitr -i                              # 恢复到最近备份完成的时间（不常用）
pg-pitr --time="2022-12-30 14:44:44+08" # 恢复到特定时间点（如在删除数据库或表的情况下）
pg-pitr --name="my-restore-point"       # 恢复到由 pg_create_restore_point 创建的命名还原点
pg-pitr --lsn="0/7C82CB8" -X            # 恢复到 LSN 之前
pg-pitr --xid="1234567" -X -P           # 恢复到特定的事务ID之前，然后将其提升为主库
pg-pitr --backup=latest                 # 恢复到最新的备份集
pg-pitr --backup=20221108-105325        # 恢复到特定的备份集，使用名称指定，可以使用 pgbackrest info 进行检查
```

使用 Systemd 管理系统组件的命令：

```bash
systemctl stop patroni                  # 启动 停止 重启 重载
systemctl stop pgbouncer                # 启动 停止 重启 重载
systemctl stop pg_exporter              # 启动 停止 重启 重载
systemctl stop pgbouncer_exporter       # 启动 停止 重启 重载
systemctl stop node_exporter            # 启动 停止 重启
systemctl stop haproxy                  # 启动 停止 重启 重载
systemctl stop vip-manager              # 启动 停止 重启 重载
systemctl stop postgres                 # 仅当 patroni_mode == 'remove' 时使用这个服务
```



----------------

## 创建集群

To create a new Postgres cluster, define it in the inventory first, then init with:

```bash
bin/node-add <cls>                # init nodes for cluster <cls>           # ./node.yml  -l <cls> 
bin/pgsql-add <cls>               # init pgsql instances of cluster <cls>  # ./pgsql.yml -l <cls>
```

<details><summary>Example: Create Cluster</summary>

[![asciicast](https://asciinema.org/a/568810.svg)](https://asciinema.org/a/568810)

</details>



----------------

## 创建用户

To create a new business user on the existing Postgres cluster, add user definition to `all.children.<cls>.pg_users`, then create the user as follows:

```bash
bin/pgsql-user <cls> <username>   # ./pgsql-user.yml -l <cls> -e username=<username>
```

<details><summary>Example: Create Business User</summary>

[![asciicast](https://asciinema.org/a/568789.svg)](https://asciinema.org/a/568789)

</details>



----------------

## 创建数据库

To create a new database user on the existing Postgres cluster, add database definition to `all.children.<cls>.pg_databases`, then create the database as follows:

```bash
bin/pgsql-db <cls> <dbname>       # ./pgsql-db.yml -l <cls> -e dbname=<dbname>
```

Note: If the database has specified an owner, the user should already exist, or you'll have to [Create User](#create-user) first.

<details><summary>Example: Create Business Database</summary>

[![asciicast](https://asciinema.org/a/568790.svg)](https://asciinema.org/a/568790)

</details>



----------------

## 重载服务

Services are exposed access point served by HAProxy.

This task is used when cluster membership has changed, e.g., [append](#append-replica)/[remove](#remove-replica) replicas, [switchover](#switchover)/failover / exposing new service or updating existing service's config (e.g., LB Weight)

To create new services or reload existing services on entire proxy cluster or specific instances:

```bash
bin/pgsql-svc <cls>               # pgsql.yml -l <cls> -t pg_service -e pg_reload=true
bin/pgsql-svc <cls> [ip...]       # pgsql.yml -l ip... -t pg_service -e pg_reload=true
```

<details><summary>Example: Reload PG Service to Kick one Instance</summary>

[![asciicast](https://asciinema.org/a/568815.svg)](https://asciinema.org/a/568815)

</details>




----------------

## 重载HBA

This task is used when your Postgres/Pgbouncer HBA rules have changed, you *may* have to reload hba to apply changes.

If you have any role-specific HBA rules, you may have to reload hba after a switchover/failover, too.

To reload postgres & pgbouncer HBA rules on entire cluster or specific instances:

```bash
bin/pgsql-hba <cls>               # pgsql.yml -l <cls> -t pg_hba,pgbouncer_hba,pgbouncer_reload -e pg_reload=true
bin/pgsql-hba <cls> [ip...]       # pgsql.yml -l ip... -t pg_hba,pgbouncer_hba,pgbouncer_reload -e pg_reload=true
```

<details><summary>Example: Reload Cluster HBA Rules</summary>

[![asciicast](https://asciinema.org/a/568794.svg)](https://asciinema.org/a/568794)

</details>



----------------

## 配置集群

To change the config of a existing Postgres cluster, you have to initiate control command on **admin node with admin user**:

```bash
pg edit-config <cls>              # interactive config a cluster with patronictl
```

Change patroni parameters & `postgresql.parameters`, save & apply changes with the wizard.

<details><summary>Example: Config Cluster in Non-Interactive Manner</summary>

You can skip interactive mode and use `-p` option to override postgres parameters, for example: 

```bash
pg edit-config -p log_min_duration_statement=1000 pg-test
pg edit-config --force -p shared_preload_libraries='timescaledb, pg_cron, pg_stat_statements, auto_explain'
```

</details>

<details><summary>Example: Change Cluster Config with Patroni REST API</summary>

You can also use [Patroni REST API](https://patroni.readthedocs.io/en/latest/rest_api.html) to change the config in a non-interactive mode, for example:

```bash
$ curl -s 10.10.10.11:8008/config | jq .  # get current config
$ curl -u 'postgres:Patroni.API' \
        -d '{"postgresql":{"parameters": {"log_min_duration_statement":200}}}' \
        -s -X PATCH http://10.10.10.11:8008/config | jq .
```

Note: patroni unsafe RestAPI access is limit from infra/admin nodes and protected with an HTTP basic auth username/password and an optional HTTPS mode.

</details>

<details><summary>Example: Config Cluster with PatroniCtl</summary>

[![asciicast](https://asciinema.org/a/568799.svg)](https://asciinema.org/a/568799)

</details>



----------------

## 添加实例

To add a new replica to the existing Postgres cluster, you have to add its definition to the inventory: `all.children.<cls>.hosts`, then:

```bash
bin/node-add <ip>                 # init node <ip> for the new replica               
bin/pgsql-add <cls> <ip>          # init pgsql instances on <ip> for cluster <cls>  
```

It will add node `<ip>` to pigsty and init it as a replica of the cluster `<cls>`. 

Cluster services will be [reloaded](#reload-service) to adopt the new member  


<details><summary>Example: Add replica to pg-test </summary>

[![asciicast](https://asciinema.org/a/566421.svg)](https://asciinema.org/a/566421)

For example, if you want to add a `pg-test-3 / 10.10.10.13` to the existing cluster `pg-test`, you'll have to update the inventory first:

```bash
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary } # existing member
    10.10.10.12: { pg_seq: 2, pg_role: replica } # existing member
    10.10.10.13: { pg_seq: 3, pg_role: replica } # <--- new member
  vars: { pg_cluster: pg-test }
```

then apply the change as follows:

```bash
bin/node-add          10.10.10.13   # add node to pigsty
bin/pgsql-add pg-test 10.10.10.13   # init new replica on 10.10.10.13 for cluster pg-test
```

which is similar to cluster init but only works on single instance。

```bash
[ OK ] init instances  10.10.10.11 to pgsql cluster 'pg-test':
[WARN]   reminder: add nodes to pigsty, then install additional module 'pgsql'
[HINT]     $ bin/node-add  10.10.10.11  # run this ahead, except infra nodes
[WARN]   init instances from cluster:
[ OK ]     $ ./pgsql.yml -l '10.10.10.11,&pg-test'
[WARN]   reload pg_service on existing instances:
[ OK ]     $ ./pgsql.yml -l 'pg-test,!10.10.10.11' -t pg_service
```

</details>




----------------

## 移除实例

To remove a replica from the existing PostgreSQL cluster:

```bash
bin/pgsql-rm <cls> <ip...>        # ./pgsql-rm.yml -l <ip>
```

It will remove instance `<ip>` from cluster `<cls>`.
Cluster services will be [reloaded](#reload-service) to kick the removed instance from load balancer.

<details><summary>Example: Remove replica from pg-test </summary>

[![asciicast](https://asciinema.org/a/566419.svg)](https://asciinema.org/a/566419)

For example, if you want to remove `pg-test-3 / 10.10.10.13` from the existing cluster `pg-test`:

```bash
bin/pgsql-rm pg-test 10.10.10.13  # remove pgsql instance 10.10.10.13 from pg-test
bin/node-rm  10.10.10.13          # remove that node from pigsty (optional)
vi pigsty.yml                     # remove instance definition from inventory
bin/pgsql-svc pg-test             # refresh pg_service on existing instances to kick removed instance from load balancer
```

```bash
[ OK ] remove pgsql instances from  10.10.10.13 of 'pg-test':
[WARN]   remove instances from cluster:
[ OK ]     $ ./pgsql-rm.yml -l '10.10.10.13,&pg-test'
```

And remove instance definition from the inventory:

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
    10.10.10.13: { pg_seq: 3, pg_role: replica } # <--- remove this after execution
  vars: { pg_cluster: pg-test }
```

Finally, you can update pg service and kick the removed instance from load balancer:

```bash
bin/pgsql-svc pg-test             # reload pg service on pg-test
```

</details>



----------------

## 下线集群

To remove the entire Postgres cluster, just run:

```bash
bin/pgsql-rm <cls>                # ./pgsql-rm.yml -l <cls>
```

<details><summary>Example: Remove Cluster</summary>

[![asciicast](https://asciinema.org/a/566418.svg)](https://asciinema.org/a/566418)

</details>

<details><summary>Example: Force removing a cluster</summary>

Note: if [`pg_safeguard`](PARAM#pg_safeguard) is configured for this cluster (or globally configured to `true`), `pgsql-rm.yml` will abort to avoid removing a cluster by accident.

You can use playbook command line args to explicitly overwrite it to force the purge:

```bash
./pgsql-rm.yml -l pg-meta -e pg_safeguard=false    # force removing pg cluster pg-meta
```

</details>




----------------

## 主动切换

You can perform a PostgreSQL cluster switchover with patroni cmd.

```bash
pg switchover <cls>   # interactive mode, you can skip that with following options
pg switchover --leader pg-test-1 --candidate=pg-test-2 --scheduled=now --force pg-test
```

<details><summary>Example: Switchover pg-test</summary>

[![asciicast](https://asciinema.org/a/566248.svg)](https://asciinema.org/a/566248)

```bash
$ pg switchover pg-test
Master [pg-test-1]:
Candidate ['pg-test-2', 'pg-test-3'] []: pg-test-2
When should the switchover take place (e.g. 2022-12-26T07:39 )  [now]: now
Current cluster topology
+ Cluster: pg-test (7181325041648035869) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Leader  | running |  1 |           | clonefrom: true |
|           |             |         |         |    |           | conf: tiny.yml  |
|           |             |         |         |    |           | spec: 1C.2G.50G |
|           |             |         |         |    |           | version: '15'   |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-2 | 10.10.10.12 | Replica | running |  1 |         0 | clonefrom: true |
|           |             |         |         |    |           | conf: tiny.yml  |
|           |             |         |         |    |           | spec: 1C.2G.50G |
|           |             |         |         |    |           | version: '15'   |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-3 | 10.10.10.13 | Replica | running |  1 |         0 | clonefrom: true |
|           |             |         |         |    |           | conf: tiny.yml  |
|           |             |         |         |    |           | spec: 1C.2G.50G |
|           |             |         |         |    |           | version: '15'   |
+-----------+-------------+---------+---------+----+-----------+-----------------+
Are you sure you want to switchover cluster pg-test, demoting current master pg-test-1? [y/N]: y
2022-12-26 06:39:58.02468 Successfully switched over to "pg-test-2"
+ Cluster: pg-test (7181325041648035869) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Replica | stopped |    |   unknown | clonefrom: true |
|           |             |         |         |    |           | conf: tiny.yml  |
|           |             |         |         |    |           | spec: 1C.2G.50G |
|           |             |         |         |    |           | version: '15'   |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-2 | 10.10.10.12 | Leader  | running |  1 |           | clonefrom: true |
|           |             |         |         |    |           | conf: tiny.yml  |
|           |             |         |         |    |           | spec: 1C.2G.50G |
|           |             |         |         |    |           | version: '15'   |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-3 | 10.10.10.13 | Replica | running |  1 |         0 | clonefrom: true |
|           |             |         |         |    |           | conf: tiny.yml  |
|           |             |         |         |    |           | spec: 1C.2G.50G |
|           |             |         |         |    |           | version: '15'   |
+-----------+-------------+---------+---------+----+-----------+-----------------+
```

To do so with Patroni API (schedule a switchover from 2 to 1 at a specific time):

```bash
curl -u 'postgres:Patroni.API' \
  -d '{"leader":"pg-test-2", "candidate": "pg-test-1","scheduled_at":"2022-12-26T14:47+08"}' \
  -s -X POST http://10.10.10.11:8008/switchover
```

</details>




----------------

## 备份集群

To create a backup with pgBackRest, run as local dbsu:

```bash
pg-backup                         # make a postgres base backup
pg-backup full                    # make a full backup
pg-backup diff                    # make a differential backup
pg-backup incr                    # make a incremental backup
pb info                           # check backup information
```

Check [Backup](PGSQL-PITR) & PITR for details.

<details><summary>Example: Make Backups</summary>

You can add crontab to [`node_crontab`](PARAM#node_crontab) to specify your backup policy.

[![asciicast](https://asciinema.org/a/568813.svg)](https://asciinema.org/a/568813)

</details>


<details><summary>Example: Create routine backup crontab</summary>

You can add crontab to [`node_crontab`](PARAM#node_crontab) to specify your backup policy. 

```yaml
# make a full backup 1 am everyday
- '00 01 * * * postgres /pg/bin/pg-backup full'

# rotate backup: make a full backup on monday 1am, and an incremental backup during weekdays
- '00 01 * * 1 postgres /pg/bin/pg-backup full'
- '00 01 * * 2,3,4,5,6,7 postgres /pg/bin/pg-backup'
```

</details>



----------------

## 恢复集群

To restore a cluster to a previous time point (PITR), run as local dbsu:

```bash
pg-pitr -i                              # restore to the time of latest backup complete (not often used)
pg-pitr --time="2022-12-30 14:44:44+08" # restore to specific time point (in case of drop db, drop table)
pg-pitr --name="my-restore-point"       # restore TO a named restore point create by pg_create_restore_point
pg-pitr --lsn="0/7C82CB8" -X            # restore right BEFORE a LSN
pg-pitr --xid="1234567" -X -P           # restore right BEFORE a specific transaction id, then promote
pg-pitr --backup=latest                 # restore to latest backup set
pg-pitr --backup=20221108-105325        # restore to a specific backup set, which can be checked with pgbackrest info
```

And follow the instructions wizard, Check Backup & [PITR](PGSQL-PITR) for details.

<details><summary>Example: PITR with raw pgBackRest Command</summary>

```bash
# restore to the latest available point (e.g. hardware failure)
pgbackrest --stanza=pg-meta restore

# PITR to specific time point (e.g. drop table by accident)
pgbackrest --stanza=pg-meta --type=time --target="2022-11-08 10:58:48" \
   --target-action=promote restore

# restore specific backup point and then promote (or pause|shutdown)
pgbackrest --stanza=pg-meta --type=immediate --target-action=promote \
  --set=20221108-105325F_20221108-105938I restore
```

</details>



----------------

## 添加软件

To add newer version of RPM packages, you have to add them to [`repo_packages`](PARAM#repo_packages) and [`repo_url_packages`](PARAM#repo_url_packages)

And remove `/www/pigsty/repo_complete` flag file then rebuild repo with `./infra.yml -t repo_build`. 

Then you can install these packages with `ansible` module `package`:

```bash
ansible pg-test -b -m package -a "name=pg_cron_15,topn_15,pg_stat_monitor_15*"  # install some packages
```

<details><summary>Update Packages Manually</summary>

```bash
# add repo upstream on admin node, then download them manually
cd ~/pigsty; ./infra.yml -t repo_upstream                 # add upstream repo (internet)
cd /www/pigsty;  repotrack "some_new_package_name"        # download the latest RPMs
cd ~/pigsty; ./infra.yml -t repo_create                   # re-create local yum repo
ansible all -b -a 'yum clean all'                         # clean node repo cache
ansible all -b -a 'yum makecache'                         # remake yum cache from the new repo
```

For example, you can then install or upgrade packages with:

```bash
ansible pg-test -b -m package -a "name=postgresql15* state=latest"
```

</details>



----------------

## 安装扩展

If you want to install extension on pg clusters, Add them to [`pg_extensions`](PARAM#pg_extensions) and make sure them installed with:

```bash
./pgsql.yml -t pg_extension     # install extensions
```

Some extension needs to be loaded in `shared_preload_libraries`, You can add them to [`pg_libs`](PARAM#pg_libs), or [Config](#config-cluster) an existing cluster.

Finally, `CREATE EXTENSION <extname>;` on the cluster primary instance to install it. 

<details><summary>Example: Install pg_cron on pg-test cluster</summary>

```bash
ansible pg-test -b -m package -a "name=pg_cron_15"          # install pg_cron packages on all nodes
# add pg_cron to shared_preload_libraries
pg edit-config --force -p shared_preload_libraries='timescaledb, pg_cron, pg_stat_statements, auto_explain'
pg restart --force pg-test                                  # restart cluster
psql -h pg-test -d postgres -c 'CREATE EXTENSION pg_cron;'  # install pg_cron on primary
```

</details>



----------------

## 小版本升级

To perform a minor server version upgrade/downgrade, you have to [添加软件](#添加软件) to yum repo first.

Then perform a rolling upgrade/downgrade from all replicas, then switchover the cluster to upgrade the leader.

```bash
ansible <cls> -b -a "yum upgrade/downgrade -y <pkg>"    # upgrade/downgrade packages
pg restart --force <cls>                                # restart cluster
```

<details><summary>Example: Downgrade PostgreSQL 15.2 to 15.1</summary>

Add 15.1 packages to yum repo and refresh node yum cache:

```bash
cd ~/pigsty; ./infra.yml -t repo_upstream               # add upstream repo backup
cd /www/pigsty; repotrack postgresql15-*-15.1           # add 15.1 packages to yum repo
cd ~/pigsty; ./infra.yml -t repo_create                 # re-create repo
ansible pg-test -b -a 'yum clean all'                   # clean node repo cache
ansible pg-test -b -a 'yum makecache'                   # remake yum cache from the new repo
``` 

Perform a downgrade and restart the cluster:

```bash
ansible pg-test -b -a "yum downgrade -y postgresql15*"  # downgrade packages
pg restart --force pg-test                              # restart entire cluster to finish upgrade
```

</details>

<details><summary>Example: Upgrade PostgreSQL 15.1 back to 15.2</summary>

This time we upgrade in a rolling fashion:

```bash
ansible pg-test -b -a "yum upgrade -y postgresql15*"    # upgrade packages
ansible pg-test -b -a '/usr/pgsql/bin/pg_ctl --version' # check binary version is 15.2
pg restart --role replica --force pg-test               # restart replicas
pg switchover --leader pg-test-1 --candidate=pg-test-2 --scheduled=now --force pg-test    # switchover
pg restart --role primary --force pg-test               # restart primary
```

</details>




----------------

## 大版本升级

The simplest way to achieve a major version upgrade is to create a new cluster with the new version, then [migration](PGSQL-MIGRATION) with logical replication. 

You can also perform an in-place major upgrade, which is not recommended especially when certain extensions are installed. But it is possible.

Assume you want to upgrade PostgreSQL 14 to 15, you have to [add packages](#adding-packages) to yum repo, and guarantee the extensions has exact same version too. 

```bash
./pgsql.yml -t pg_pkg -e pg_version=15                         # install packages for pg 15
sudo su - postgres; mkdir -p /data/postgres/pg-meta-15/data/   # prepare directories for 15
pg_upgrade -b /usr/pgsql-14/bin/ -B /usr/pgsql-15/bin/ -d /data/postgres/pg-meta-14/data/ -D /data/postgres/pg-meta-15/data/ -v -c # preflight
pg_upgrade -b /usr/pgsql-14/bin/ -B /usr/pgsql-15/bin/ -d /data/postgres/pg-meta-14/data/ -D /data/postgres/pg-meta-15/data/ --link -j8 -v -c
rm -rf /usr/pgsql; ln -s /usr/pgsql-15 /usr/pgsql;             # fix binary links 
mv /data/postgres/pg-meta-14 /data/postgres/pg-meta-15         # rename data directory
rm -rf /pg; ln -s /data/postgres/pg-meta-15 /pg                # fix data dir links
```
