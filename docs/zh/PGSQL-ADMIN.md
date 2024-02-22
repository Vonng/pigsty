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

要创建一个新的Postgres集群，请首先在配置清单中定义，然后进行初始化：

```bash
bin/node-add <cls>                # 为集群 <cls> 初始化节点                  # ./node.yml  -l <cls> 
bin/pgsql-add <cls>               # 初始化集群 <cls> 的pgsql实例             # ./pgsql.yml -l <cls>
```

> 请注意，PGSQL 模块需要在 Pigsty 纳管的节点上安装，请先使用 `bin/node-add` 纳管节点。

<details><summary>示例：创建集群</summary>

[![asciicast](https://asciinema.org/a/568810.svg)](https://asciinema.org/a/568810)

</details>



----------------

## 创建用户

要在现有的Postgres集群上创建一个新的业务用户，请将用户定义添加到 `all.children.<cls>.pg_users`，然后使用以下命令将其创建：

```bash
bin/pgsql-user <cls> <username>   # ./pgsql-user.yml -l <cls> -e username=<username>
```

<details><summary>示例：创建业务用户</summary>

[![asciicast](https://asciinema.org/a/568789.svg)](https://asciinema.org/a/568789)

</details>



----------------

## 创建数据库

要在现有的Postgres集群上创建一个新的数据库用户，请将数据库定义添加到 `all.children.<cls>.pg_databases`，然后按照以下方式创建数据库：

```bash
bin/pgsql-db <cls> <dbname>       # ./pgsql-db.yml -l <cls> -e dbname=<dbname>
```

注意：如果数据库指定了一个非默认的属主，该属主用户应当已存在，否则您必须先[创建用户](#创建用户)。

<details><summary>示例：创建业务数据库</summary>

[![asciicast](https://asciinema.org/a/568790.svg)](https://asciinema.org/a/568790)

</details>



----------------

## 重载服务

[服务](PGSQL-SVC)是 PostgreSQL 对外提供能力的访问点（PGURL可达），由主机节点上的 HAProxy 对外暴露。

当集群成员发生变化时使用此任务，例如：[添加](#添加实例)／[移除](#移除实例)副本，[主从切换](#主动切换)／故障转移 / 暴露新服务，或更新现有服务的配置（例如，LB权重）

要在整个代理集群，或特定实例上创建新服务或重新加载现有服务：

```bash
bin/pgsql-svc <cls>               # pgsql.yml -l <cls> -t pg_service -e pg_reload=true
bin/pgsql-svc <cls> [ip...]       # pgsql.yml -l ip... -t pg_service -e pg_reload=true
```

<details><summary>示例：重载PG服务以踢除一个实例</summary>

[![asciicast](https://asciinema.org/a/568815.svg)](https://asciinema.org/a/568815)

</details>




----------------

## 重载HBA

当您的 Postgres/Pgbouncer HBA 规则发生更改时，您 *可能* 需要重载 HBA 以应用更改。

如果您有任何特定于角色的 HBA 规则，或者在IP地址段中引用了集群成员的别名，那么当主从切换/集群扩缩容后也可能需要重载HBA。

要在整个集群或特定实例上重新加载 postgres 和 pgbouncer 的 HBA 规则：

```bash
bin/pgsql-hba <cls>               # pgsql.yml -l <cls> -t pg_hba,pgbouncer_hba,pgbouncer_reload -e pg_reload=true
bin/pgsql-hba <cls> [ip...]       # pgsql.yml -l ip... -t pg_hba,pgbouncer_hba,pgbouncer_reload -e pg_reload=true
```

<details><summary>示例：重载集群 HBA 规则</summary>

[![asciicast](https://asciinema.org/a/568794.svg)](https://asciinema.org/a/568794)

</details>



----------------

## 配置集群

要更改现有的 Postgres 集群配置，您需要在**管理节点**上使用**管理员用户**（安装Pigsty的用户，nopass ssh/sudo）发起控制命令：

另一种方式是在数据库集群中的任何节点上，使用 `dbsu` （默认为 postgres） ，也可以执行管理命令，但只能管理本集群。

```bash
pg edit-config <cls>              # interactive config a cluster with patronictl
```

更改 patroni 参数和 `postgresql.parameters`，根据提示保存并应用更改即可。


<details><summary>示例：非交互式方式配置集群</summary>

您可以跳过交互模式，并使用 `-p` 选项覆盖 postgres 参数，例如： 

```bash
pg edit-config -p log_min_duration_statement=1000 pg-test
pg edit-config --force -p shared_preload_libraries='timescaledb, pg_cron, pg_stat_statements, auto_explain'
```

</details>


<details><summary>示例：使用 Patroni REST API 更改集群配置</summary>

您还可以使用 [Patroni REST API](https://patroni.readthedocs.io/en/latest/rest_api.html) 以非交互式方式更改配置，例如：

```bash
$ curl -s 10.10.10.11:8008/config | jq .  # get current config
$ curl -u 'postgres:Patroni.API' \
        -d '{"postgresql":{"parameters": {"log_min_duration_statement":200}}}' \
        -s -X PATCH http://10.10.10.11:8008/config | jq .
```

注意：Patroni 敏感API（例如重启等） 访问仅限于从基础设施/管理节点发起，并且有 HTTP 基本认证（用户名/密码）以及可选的 HTTPS 保护。

</details>


<details><summary>示例：使用 patronictl 配置集群</summary>

[![asciicast](https://asciinema.org/a/568799.svg)](https://asciinema.org/a/568799)

</details>



----------------

## 添加实例

若要将新从库添加到现有的 PostgreSQL 集群中，您需要将其定义添加到配置清单：`all.children.<cls>.hosts` 中，然后：

```bash
bin/node-add <ip>                 # 将节点 <ip> 纳入 Pigsty 管理                
bin/pgsql-add <cls> <ip>          # 初始化 <ip> ，作为集群 <cls> 的新从库
```

这将会把节点 `<ip>` 添加到 pigsty 并将其初始化为集群 `<cls>` 的一个副本。

集群服务将会[重新加载](#重载服务)以接纳新成员。

<details><summary>示例：为 pg-test 添加从库</summary>

[![asciicast](https://asciinema.org/a/566421.svg)](https://asciinema.org/a/566421)

例如，如果您想将 `pg-test-3 / 10.10.10.13` 添加到现有的集群 `pg-test`，您首先需要更新配置清单：

```bash
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary } # 已存在的成员
    10.10.10.12: { pg_seq: 2, pg_role: replica } # 已存在的成员
    10.10.10.13: { pg_seq: 3, pg_role: replica } # <--- 新成员
  vars: { pg_cluster: pg-test }
```

然后按如下方式应用更改：

```bash
bin/node-add          10.10.10.13   # 将节点添加到 pigsty
bin/pgsql-add pg-test 10.10.10.13   # 在 10.10.10.13 上为集群 pg-test 初始化新的副本
```

这与集群初始化相似，但只在单个实例上工作：

```bash
[ OK ] 初始化实例  10.10.10.11 到 pgsql 集群 'pg-test' 中:
[WARN]   提醒：先将节点添加到 pigsty 中，然后再安装模块 'pgsql'
[HINT]     $ bin/node-add  10.10.10.11  # 除 infra 节点外，先运行此命令
[WARN]   从集群初始化实例：
[ OK ]     $ ./pgsql.yml -l '10.10.10.11,&pg-test'
[WARN]   重新加载现有实例上的 pg_service：
[ OK ]     $ ./pgsql.yml -l 'pg-test,!10.10.10.11' -t pg_service
```

</details>




----------------

## 移除实例

若要从现有的 PostgreSQL 集群中移除副本：

```bash
bin/pgsql-rm <cls> <ip...>        # ./pgsql-rm.yml -l <ip>
```

这将从集群 `<cls>` 中移除实例 `<ip>`。 集群服务将会[重新加载](#重载服务)以从负载均衡器中踢除已移除的实例。

<details><summary>示例：从 pg-test 移除从库</summary>

[![asciicast](https://asciinema.org/a/566419.svg)](https://asciinema.org/a/566419)

例如，如果您想从现有的集群 `pg-test` 中移除 `pg-test-3 / 10.10.10.13`：

```bash
bin/pgsql-rm pg-test 10.10.10.13  # 从 pg-test 中移除 pgsql 实例 10.10.10.13
bin/node-rm  10.10.10.13          # 从 pigsty 中移除该节点（可选）
vi pigsty.yml                     # 从目录中移除实例定义
bin/pgsql-svc pg-test             # 刷新现有实例上的 pg_service，以从负载均衡器中踢除已移除的实例
```

```bash
[ OK ] 从 'pg-test' 移除 10.10.10.13 的 pgsql 实例：
[WARN]   从集群中移除实例：
[ OK ]     $ ./pgsql-rm.yml -l '10.10.10.13,&pg-test'
```

并从配置清单中移除实例定义：

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
    10.10.10.13: { pg_seq: 3, pg_role: replica } # <--- 执行后移除此行
  vars: { pg_cluster: pg-test }
```

最后，您可以[重载PG服务](#重载服务)并从负载均衡器中踢除已移除的实例：

```bash
bin/pgsql-svc pg-test             # 重载 pg-test 上的服务
```

</details>



----------------

## 下线集群

要移除整个 Postgres 集群，只需运行：

```bash
bin/pgsql-rm <cls>                # ./pgsql-rm.yml -l <cls>
```

<details><summary>示例：移除集群</summary>

[![asciicast](https://asciinema.org/a/566418.svg)](https://asciinema.org/a/566418)

</details>

<details><summary>示例：强制移除集群</summary>

注意：如果为这个集群配置了[`pg_safeguard`](PARAM#pg_safeguard)（或全局设置为 `true`），`pgsql-rm.yml` 将中止，以避免意外移除集群。

您可以使用 playbook 命令行参数明确地覆盖它，以强制执行清除：

```bash
./pgsql-rm.yml -l pg-meta -e pg_safeguard=false    # 强制移除 pg 集群 pg-meta
```

</details>




----------------

## 主动切换

您可以使用 patroni 命令行工具执行 PostgreSQL 集群的切换操作。

```bash
pg switchover <cls>   # 交互模式，您可以使用下面的参数组合直接跳过此交互向导
pg switchover --leader pg-test-1 --candidate=pg-test-2 --scheduled=now --force pg-test
```

<details><summary>示例：pg-test 主从切换</summary>

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

要通过 Patroni API 来执行此操作（例如，在指定时间将主库从 2号实例 切换到 1号实例）

```bash
curl -u 'postgres:Patroni.API' \
  -d '{"leader":"pg-test-2", "candidate": "pg-test-1","scheduled_at":"2022-12-26T14:47+08"}' \
  -s -X POST http://10.10.10.11:8008/switchover
```

</details>




----------------

## 备份集群

使用 pgBackRest 创建备份，需要以本地 dbsu （默认为 `postgres`）的身份运行以下命令：

```bash
pg-backup       # 执行备份，如有必要，执行增量或全量备份
pg-backup full  # 执行全量备份
pg-backup diff  # 执行差异备份
pg-backup incr  # 执行增量备份
pb info         # 打印备份信息 （pgbackrest info）
```

参阅[备份恢复](PGSQL-PITR#备份)获取更多信息。


<details><summary>示例：创建备份</summary>

[![asciicast](https://asciinema.org/a/568813.svg)](https://asciinema.org/a/568813)

</details>


<details><summary>示例：创建定时备份任务</summary>

您可以将 crontab 添加到 [`node_crontab`](PARAM#node_crontab) 以指定您的备份策略。

```yaml
# 每天凌晨1点做一次全备份
- '00 01 * * * postgres /pg/bin/pg-backup full'

# 周一凌晨1点进全量备份，其他工作日进行增量备份
- '00 01 * * 1 postgres /pg/bin/pg-backup full'
- '00 01 * * 2,3,4,5,6,7 postgres /pg/bin/pg-backup'
```

</details>



----------------

## 恢复集群

要将集群恢复到先前的时间点 (PITR)，请以本地 dbsu 用户（默认为`postgres`）运行 Pigsty 提供的辅助脚本 `pg-pitr`

```bash
pg-pitr -i                              # 恢复到最近备份完成的时间（不常用）
pg-pitr --time="2022-12-30 14:44:44+08" # 恢复到指定的时间点（在删除数据库或表的情况下使用）
pg-pitr --name="my-restore-point"       # 恢复到使用 pg_create_restore_point 创建的命名恢复点
pg-pitr --lsn="0/7C82CB8" -X            # 在LSN之前立即恢复
pg-pitr --xid="1234567" -X -P           # 在指定的事务ID之前立即恢复，然后将集群直接提升为主库
pg-pitr --backup=latest                 # 恢复到最新的备份集
pg-pitr --backup=20221108-105325        # 恢复到特定备份集，备份集可以使用 pgbackrest info 列出
```

该命令会输出操作手册，请按照说明进行操作。查看[备份恢复-PITR](PGSQL-PITR#恢复)获取详细信息。

<details><summary>示例：使用原始pgBackRest命令进行 PITR</summary>

```bash
# 恢复到最新可用的点（例如硬件故障）
pgbackrest --stanza=pg-meta restore

# PITR 到特定的时间点（例如意外删除表）
pgbackrest --stanza=pg-meta --type=time --target="2022-11-08 10:58:48" \
   --target-action=promote restore

# 恢复特定的备份点，然后提升（或暂停|关闭）
pgbackrest --stanza=pg-meta --type=immediate --target-action=promote \
  --set=20221108-105325F_20221108-105938I restore
```

</details>



----------------

## 添加软件

要添加新版本的 RPM 包，你需要将它们加入到 [`repo_packages`](PARAM#repo_packages) 和 [`repo_url_packages`](PARAM#repo_url_packages) 中。

然后删除 `/www/pigsty/repo_complete` 标志文件，之后使用 `./infra.yml -t repo_build` 重新构建 repo。然后，你可以使用 `ansible` 的 `package` 模块安装这些包：

```bash
ansible pg-test -b -m package -a "name=pg_cron_15,topn_15,pg_stat_monitor_15*"  # 使用 ansible 安装一些包
```

<details><summary>示例：手动更本地新软件源中的包</summary>

```bash
# 在基础设施/管理节点上添加上游软件仓库，然后手工下载所需的软件包
cd ~/pigsty; ./infra.yml -t repo_upstream,repo_cache # 添加上游仓库（互联网）
cd /www/pigsty;  repotrack "some_new_package_name"   # 下载最新的 RPM 包

# 更新本地软件仓库元数据
cd ~/pigsty; ./infra.yml -t repo_create              # 重新创建本地软件仓库
./node.yml -t node_repo                              # 刷新所有节点上的 YUM/APT 缓存

# 也可以使用 Ansible 手工刷新节点上的 YUM/APT 缓存
ansible all -b -a 'yum clean all'                    # 清理节点软件仓库缓存
ansible all -b -a 'yum makecache'                    # 从新的仓库重建yum/apt缓存
ansible all -b -a 'apt clean'                        # 清理 APT 缓存（Ubuntu/Debian）
ansible all -b -a 'apt update'                       # 重建 APT 缓存（Ubuntu/Debian）
```

例如，你可以使用以下方式安装或升级包：

```bash
ansible pg-test -b -m package -a "name=postgresql15* state=latest"
```

</details>



----------------

## 安装扩展

如果你想在 PostgreSQL 集群上安装扩展，请将它们加入到 [`pg_extensions`](PARAM#pg_extensions) 中，并执行：

```bash
./pgsql.yml -t pg_extension     # 安装扩展
``` 

一部分扩展需要在 `shared_preload_libraries` 中加载后才能生效。你可以将它们加入到 [`pg_libs`](PARAM#pg_libs) 中，或者[配置](#配置集群)一个已有的集群。

最后，在集群的主库上执行 `CREATE EXTENSION <extname>;` 来完成扩展的安装。

<details><summary>示例：在 pg-test 集群上安装 pg_cron 扩展</summary>

```bash
ansible pg-test -b -m package -a "name=pg_cron_15"          # 在所有节点上安装 pg_cron 包
# 将 pg_cron 添加到 shared_preload_libraries 中
pg edit-config --force -p shared_preload_libraries='timescaledb, pg_cron, pg_stat_statements, auto_explain'
pg restart --force pg-test                                  # 重新启动集群
psql -h pg-test -d postgres -c 'CREATE EXTENSION pg_cron;'  # 在主库上安装 pg_cron
```

</details>

更多细节，请参考[PGSQL扩展安装](PGSQL-EXTENSION#扩展安装)。



----------------

## 小版本升级

要执行小版本的服务器升级/降级，您首先需要在本地软件仓库中[添加软件](#添加软件)：最新的PG小版本 RPM/DEB。

首先对所有从库执行滚动升级/降级，然后执行集群[主从切换](#主动切换)以升级/降级主库。

```bash
ansible <cls> -b -a "yum upgrade/downgrade -y <pkg>"    # 升级/降级软件包
pg restart --force <cls>                                # 重启集群
```

<details><summary>示例：将PostgreSQL 15.2降级到15.1</summary>

将15.1的包添加到软件仓库并刷新节点的 yum/apt 缓存：

```bash
cd ~/pigsty; ./infra.yml -t repo_upstream               # 添加上游仓库
cd /www/pigsty; repotrack postgresql15-*-15.1           # 将15.1的包添加到yum仓库
cd ~/pigsty; ./infra.yml -t repo_create                 # 重建仓库元数据
ansible pg-test -b -a 'yum clean all'                   # 清理节点仓库缓存
ansible pg-test -b -a 'yum makecache'                   # 从新仓库重新生成yum缓存

# 对于 Ubutnu/Debian 用户，使用 apt 替换 yum
ansible pg-test -b -a 'apt clean'                       # 清理节点仓库缓存
ansible pg-test -b -a 'apt update'                      # 从新仓库重新生成apt缓存
``` 

执行降级并重启集群：

```bash
ansible pg-test -b -a "yum downgrade -y postgresql15*"  # 降级软件包）
pg restart --force pg-test                              # 重启整个集群以完成升级
```

</details>


<details><summary>示例：将PostgreSQL 15.1升级回15.2</summary>

这次我们采用滚动方式升级：

```bash
ansible pg-test -b -a "yum upgrade -y postgresql15*"    # 升级软件包（或 apt upgrade）
ansible pg-test -b -a '/usr/pgsql/bin/pg_ctl --version' # 检查二进制版本是否为15.2
pg restart --role replica --force pg-test               # 重启从库
pg switchover --leader pg-test-1 --candidate=pg-test-2 --scheduled=now --force pg-test    # 切换主从
pg restart --role primary --force pg-test               # 重启主库
```

</details>




----------------

## 大版本升级

实现大版本升级的最简单办法是：创建一个使用新版本的新集群，然后通过逻辑复制进行[在线迁移](PGSQL-MIGRATION)。

您也可以进行原地大版本升级，当您只使用数据库内核本身时，这并不复杂，使用 PostgreSQL 自带的 `pg_upgrade` 即可：

假设您想将 PostgreSQL 大版本从 14 升级到 15，您首先需要在仓库中[添加软件](#添加软件)，并确保两个大版本两侧安装的核心扩展插件也具有相同的版本号。

```bash
./pgsql.yml -t pg_pkg -e pg_version=15                         # 安装pg 15的包
sudo su - postgres; mkdir -p /data/postgres/pg-meta-15/data/   # 为15准备目录
pg_upgrade -b /usr/pgsql-14/bin/ -B /usr/pgsql-15/bin/ -d /data/postgres/pg-meta-14/data/ -D /data/postgres/pg-meta-15/data/ -v -c # 预检
pg_upgrade -b /usr/pgsql-14/bin/ -B /usr/pgsql-15/bin/ -d /data/postgres/pg-meta-14/data/ -D /data/postgres/pg-meta-15/data/ --link -j8 -v -c
rm -rf /usr/pgsql; ln -s /usr/pgsql-15 /usr/pgsql;             # 修复二进制链接
mv /data/postgres/pg-meta-14 /data/postgres/pg-meta-15         # 重命名数据目录
rm -rf /pg; ln -s /data/postgres/pg-meta-15 /pg                # 修复数据目录链接
```
