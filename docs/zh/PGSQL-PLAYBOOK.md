# PostgreSQL 剧本

> Pigsty提供了一系列剧本，用于集群上下线扩缩容，用户/数据库管理，监控或迁移已有实例。

- [`pgsql.yml`](#pgsqlyml) ：初始化PostgreSQL集群或添加新的从库。
- [`pgsql-rm.yml`](#pgsql-rmyml) ：移除PostgreSQL集群，或移除某个实例
- [`pgsql-user.yml`](#pgsql-useryml) ：在现有的PostgreSQL集群中添加新的业务用户
- [`pgsql-db.yml`](#pgsql-dbyml) ：在现有的PostgreSQL集群中添加新的业务数据库
- [`pgsql-monitor.yml`](#pgsql-monitoryml) ：将远程postgres实例纳入监控中
- [`pgsql-migration.yml`](#pgsql-migrationyml) ：为现有的PostgreSQL集群生成迁移手册和脚本


----------------

### 保护机制

使用 [`PGSQL`](PGSQL) 剧本时需要**特别注意**，剧本 [`pgsql.yml`](#pgsqlyml) 与 [`pgsql-rm.yml`](#pgsql-rmyml) 使用不当会有误删数据库的风险！
* 在使用`pgsql.yml`时，请再三检查`--tags|-t` 与 `--limit|-l` 参数是否正确。
* 强烈建议在执行时添加`-l`参数，限制命令执行的对象范围，并确保自己在正确的目标上执行正确的任务。
* 限制范围通常以一个数据库集群为宜，使用不带参数的`pgsql.yml`在生产环境中是一个高危操作，务必三思而后行。

出于防止误删的目的，Pigsty 的 PGSQL 模块提供了[防误删保险](#保护机制)，由以下两个参数控制：
* [`pg_safeguard`](PARAM#pg_safeguard) 默认为 `false`，不打开。
* [`pg_clean`](PARAM#pg_clean) 默认为 `true`，默认清理已有实例。

**对初始化剧本的影响**

当 [`pgsql.yml`](#pgsqlyml) 剧本执行中遭遇配置相同的运行中现存实例时，会有以下行为表现：

| `pg_safeguard` / `pg_clean` | `pg_clean=true` | `pg_clean=false` |
|:---------------------------:|:---------------:|:----------------:|
|    `pg_safeguard=false`     |    **抹除实例**     |       中止执行       |
|     `pg_safeguard=true`     |      中止执行       |       中止执行       |

* 如果 [`pg_safeguard`](PARAM#pg_safeguard) 启用，那么该剧本会中止执行，避免误删。
* 如果没有启用，那么会进一步根据 [`pg_clean`](PARAM#pg_clean) 的取值，来决定是否移除现有的实例。
  * 如果 `pg_clean` 为 `true`，该剧本会直接清理现有实例，为新实例腾出空间。这是默认行为。
  * 如果 `pg_clean` 为 `false`，该剧本会中止执行，这需要显式配置。

**对下线剧本的影响**

当 [`pgsql-rm.yml`](#pgsql-rmyml) 剧本执行中遭遇配置相同的运行中现存实例时，会有以下行为表现：

| `pg_safeguard` / `pg_clean` | `pg_clean=true` | `pg_clean=false` |
|:---------------------------:|:---------------:|:----------------:|
|    `pg_safeguard=false`     |   **抹除实例与数据**   |     **抹除实例**     |
|     `pg_safeguard=true`     |      中止执行       |       中止执行       |

* 如果 [`pg_safeguard`](PARAM#pg_safeguard) 启用，那么该剧本会中止执行，避免误删。
* 如果没有启用，那么会继续抹除实例，同时 [`pg_clean`](PARAM#pg_clean) 在本剧本中会被解释为：是否移除数据目录。
  * 如果 `pg_clean` 为 `true`，该剧本会直接一并清理 PostgreSQL 数据目录，即所谓“删库”，这是默认行为。
  * 如果 `pg_clean` 为 `false`，该剧本保留数据目录，继续完成其他清理工作，这需要显式配置。



----------------

## `pgsql.yml`

剧本 [`pgsql.yml`](https://github.com/vonng/pigsty/blob/master/pgsql.yml) 用于初始化PostgreSQL集群或添加新的从库。

下面是使用此剧本初始化沙箱环境中 PostgreSQL 集群的过程：

[![asciicast](https://asciinema.org/a/566417.svg)](https://asciinema.org/a/566417)

本剧本包含以下子任务：

```yaml
# pg_clean      : 清理现有的 postgres（如有必要）
# pg_dbsu       : 为 postgres dbsu 设置操作系统用户sudo
# pg_install    : 安装 postgres 包和扩展
#   - pg_pkg              : 安装 postgres 相关包
#   - pg_extension        : 仅安装 postgres 扩展
#   - pg_path             : 将 pgsql 版本 bin 链接到 /usr/pgsql
#   - pg_env              : 将 pgsql bin 添加到系统路径
# pg_dir        : 创建 postgres 目录并设置 fhs
# pg_util       : 复制工具脚本，设置别名和环境
#   - pg_bin              : 同步 postgres 工具脚本 /pg/bin
#   - pg_alias            : 写入 /etc/profile.d/pg-alias.sh
#   - pg_psql             : 为 psql 创建 psqlrc 文件
#   - pg_dummy            : 创建 dummy 占位文件
# patroni       : 使用 patroni 引导 postgres
#   - pg_config           : 生成 postgres 配置
#   - pg_conf           : 生成 patroni 配置
#   - pg_systemd        : 生成 patroni systemd 配置
#   - pgbackrest_config : 生成 pgbackrest 配置
#   -  pg_cert            : 为 postgres 签发证书
#   -  pg_launch          : 启动 postgres 主服务器和副本
#   - pg_watchdog       : 授予 postgres watchdog 权限
#   - pg_primary        : 启动 patroni/postgres 主服务器
#   - pg_init           : 使用角色/模板初始化 pg 集群
#   - pg_pass           : 将 .pgpass 文件写入 pg 主目录
#   - pg_replica        : 启动 patroni/postgres 副本
#   - pg_hba            : 生成 pg HBA 规则
#   - patroni_reload    : 重新加载 patroni 配置
#   - pg_patroni        : 必要时暂停或删除 patroni
# pg_user       : 配置 postgres 业务用户
#   - pg_user_config      : 渲染创建用户的 sql
#   - pg_user_create      : 在 postgres 上创建用户
# pg_db         : 配置 postgres 业务数据库
#   - pg_db_config        : 渲染创建数据库的 sql
#   - pg_db_create        : 在 postgres 上创建数据库
# pg_backup               : 初始化 pgbackrest 仓库和基础备份
#   - pgbackrest_init     : 初始化 pgbackrest 仓库
#   - pgbackrest_backup   : 引导后进行初始备份
# pgbouncer     : 与 postgres 一起部署 pgbouncer 边车
#   - pgbouncer_clean     : 清理现有的 pgbouncer
#   - pgbouncer_dir       : 创建 pgbouncer 目录
#   - pgbouncer_config    : 生成 pgbouncer 配置
#       -  pgbouncer_svc    : 生成 pgbouncer systemd 配置
#       -  pgbouncer_ini    : 生成 pgbouncer 主配置
#       -  pgbouncer_hba    : 生成 pgbouncer hba 配置
#       -  pgbouncer_db     : 生成 pgbouncer 数据库配置
#       -  pgbouncer_user   : 生成 pgbouncer 用户配置
#   -  pgbouncer_launch   : 启动 pgbouncer 池化服务
#   -  pgbouncer_reload   : 重新加载 pgbouncer 配置
# pg_vip        : 使用 vip-manager 将 vip 绑定到 pgsql 主服务器
#   - pg_vip_config       : 为 vip-manager 生成配置
#   - pg_vip_launch       : 启动 vip-manager 绑定 vip
# pg_dns        : 将 dns 名称注册到 infra dnsmasq
#   - pg_dns_ins          : 注册 pg 实例名称
#   - pg_dns_cls          : 注册 pg 集群名称
# pg_service    : 使用 haproxy 公开 pgsql 服务
#   - pg_service_config   : 为 pg 服务生成本地 haproxy 配置
#   - pg_service_reload   : 使用 haproxy 公开 postgres 服务
# pg_exporter   : 使用 haproxy 公开 pgsql 服务
#   - pg_exporter_config  : 配置 pg_exporter 和 pgbouncer_exporter
#   - pg_exporter_launch  : 启动 pg_exporter
#   - pgbouncer_exporter_launch : 启动 pgbouncer 导出器
# pg_register   : 将 postgres 注册到 pigsty 基础设施
#   - register_prometheus : 将 pg 注册为 prometheus 监控目标
#   - register_grafana    : 将 pg 数据库注册为 grafana 数据源
```

**以下管理任务使用到了此剧本**

- [创建集群](PGSQL-ADMIN#创建集群)
- [添加实例](PGSQL-ADMIN#添加实例)
- [重载服务](PGSQL-ADMIN#重载服务)
- [重载HBA](PGSQL-ADMIN#重载hba)

**一些关于本剧本的注意事项**

单独针对某一集群从库执行此剧本时，用户应当确保 **集群主库已经完成初始化！**
* 扩容完成后，您需要[重载服务](PGSQL-ADMIN#重载服务)与[重载HBA](PGSQL-ADMIN#重载hba)，包装脚本 `pgsql-add` 会完成这些任务。
* 详情请参考管理 SOP： [添加实例](PGSQL-ADMIN#添加实例)

集群扩容时，如果`Patroni`拉起从库的时间过长，Ansible剧本可能会因为超时而中止。
* 典型错误信息为：`wait for postgres/patroni replica` 任务执行很长时间后中止
* 但制作从库的进程会继续，例如制作从库需超过1天的场景，后续处理请参考 [FAQ](FAQ#pgsql)：制作从库失败。



----------------

## `pgsql-rm.yml`

剧本 [`pgsql-rm.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-rm.yml) 用于移除PostgreSQL集群，或移除某个实例。

下面是使用此剧本移除沙箱环境中 PostgreSQL 集群的过程：

[![asciicast](https://asciinema.org/a/566418.svg)](https://asciinema.org/a/566418)

**本剧本包含以下子任务**：

```yaml
# register       : 在 prometheus、grafana、nginx 中移除注册
#   - prometheus : 从 prometheus 移除监控目标
#   - grafana    : 从 grafana 移除数据源
# dns            : 移除 INFRA节点上 DNSMASQ 的 pg dns 记录
# vip            : 移除 vip-manager，与绑定在集群主库上的 VIP
# pg_service     : 从 haproxy 上移除 PostgreSQL 服务定义并重载生效
# pg_exporter    : 移除 pg_exporter 和 pgbouncer_exporter 监控组件
# pgbouncer      : 移除 pgbouncer 连接池中间件
# postgres       : 移除 postgres 实例数据库实例
#   - pg_replica : 移除所有从库
#   - pg_primary : 最后移除主库
#   - dcs        : 从 dcs:etcd 移除元数据
# pg_data        : 移除 PostgreSQL 数据目录（使用 `pg_clean=false` 禁用）
# pgbackrest     : 移除主实例时，一并移除 PostgreSQL 备份（使用 `pgbackrest_clean=false` 禁用）
# pg_pkg         : 移除 PostgreSQL 软件包（使用 `pg_uninstall=true` 启用）
```

本剧本可以使用一些命令行参数影响其行为：

```bash
./pgsql-rm.yml -l pg-test     # 移除集群 `pg-test`
    -e pg_clean=true          # 是否一并移除 PostgreSQL 数据库目录？默认移除数据目录。
    -e pgbackrest_clean=true  # 是否一并移除 PostgreSQL 备份？（只针对主库执行时生效），默认移除备份数据。
    -e pg_uninstall=false     # 默认不会卸载 PostgreSQL 软件包，需要显式指定此参数才会卸载。
    -e pg_safeguard=false     # 防误删保险默认不打开，如果打开，可以在这里用命令行参数强行覆盖。
```

**以下管理任务使用到了此剧本**

- [移除实例](PGSQL-ADMIN#移除实例)
- [下线集群](PGSQL-ADMIN#下线集群)

**一些关于本剧本的注意事项**

**请不要直接对还有从库的集群主库单独直接执行此剧本**
* 否则抹除主库后，其余从库会自动触发高可用自动故障切换。
* 总是先下线所有从库后，再下线主库，当一次性下线整个集群时不需要操心此问题。

**实例下线后请刷新集群服务**
* 当您从集群中下线掉某一个从库实例时，它仍然存留于在负载均衡器的配置文件中。
* 因为任何健康检查都无法通过，所以下线后的实例不会对集群产生影响。
* 但您应当在恰当的时间点 [重载服务](PGSQL-ADMIN#重载服务)，确保生产环境与配置清单的一致性。 



----------------

## `pgsql-user.yml`

剧本 [`pgsql-user.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-user.yml) 用于在现有的PostgreSQL集群中添加新的业务用户

详情请参考：[管理SOP：创建用户](PGSQL-ADMIN#创建用户)

----------------

## `pgsql-db.yml`

剧本 [`pgsql-db.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-db.yml) 用于在现有的PostgreSQL集群中添加新的业务数据库

详情请参考：[管理SOP：创建数据库](PGSQL-ADMIN#创建数据库)

----------------

## `pgsql-monitor.yml`

剧本 [`pgsql-monitor.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-monitor.yml) 用于将远程postgres实例纳入监控中

详情请参考：[管理SOP：监控现有PG](PGSQL-MONITOR#监控rds)


----------------

## `pgsql-migration.yml`

剧本 [`pgsql-migration.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-migration.yml) 用于为现有的PostgreSQL集群生成迁移手册和脚本

详情请参考：[管理SOP：迁移数据库集群](PGSQL-MIGRATION)
