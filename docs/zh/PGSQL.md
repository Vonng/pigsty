# PGSQL

> **世界上最先进的开源关系型数据库！**
>
> 而 Pigsty 帮它进入全盛状态：开箱即用、可靠、可观测、可维护、可伸缩！ [配置](PGSQL-CONF) | [管理](PGSQL-ADMIN) | [剧本](PGSQL-PLAYBOOK) | [监控](PGSQL-DASHBOARD) | [参数](#参数)


----------------

## 概览

> 了解关于 PostgreSQL 的重要主题与概念。

- [系统架构](PGSQL-ARCH)
- [集群配置](PGSQL-CONF)
- [扩展插件](PGSQL-EXTENSION)
- [用户/角色](PGSQL-USER)
- [数据库](PGSQL-DB)
- [服务/接入](PGSQL-SVC)
- [认证/HBA](PGSQL-HBA)
- [访问控制](PGSQL-ACL)
- [管理预案](PGSQL-ADMIN)
- [备份恢复](PGSQL-PITR)
- [监控接入](PGSQL-MONITOR)
- [集群迁移](PGSQL-MIGRATION)
- [仪表盘](PGSQL-DASHBOARD)


----------------

## 配置

> [描述](PGSQL-CONF) 你想要的 PostgreSQL 集群

- [身份参数](PGSQL-ARCH#身份参数)：定义PostgreSQL集群的身份参数
- [读写主库](PGSQL-CONF#读写主库)：创建由单一主库构成的单实例“集群“
- [只读从库](PGSQL-CONF#只读从库)：创建一主一从的两节点基础高可用集群
- [离线从库](PGSQL-CONF#离线从库)：创建专用于OLAP/ETL/交互式查询的特殊只读实例
- [同步备库](PGSQL-CONF#同步备库)：启用同步提交，以确保没有数据丢失
- [法定人数](PGSQL-CONF#法定人数提交)：使用法定人数同步提交以获得更高的一致性级别
- [备份集群](PGSQL-CONF#备份集群)：克隆现有集群，并保持同步（异地灾备集群）
- [延迟集群](PGSQL-CONF#延迟集群)：克隆现有集群，并延迟重放，用于紧急数据恢复
- [Citus集群](PGSQL-CONF#citus集群)：定义并创建 Citus 水平分布式数据库集群
- [大版本切换](PGSQL-CONF#大版本切换)：使用不同的PostgreSQL大版本部署集群


----------------

## 管理

> [管理](PGSQL-ADMIN) 您所创建的 PostgreSQL 集群。

- [命令速查](PGSQL-ADMIN#命令速查)
- [创建集群](PGSQL-ADMIN#创建集群)
- [创建用户](PGSQL-ADMIN#创建用户)
- [创建数据库](PGSQL-ADMIN#创建数据库)
- [重载服务](PGSQL-ADMIN#重载服务)
- [重载HBA](PGSQL-ADMIN#重载HBA)
- [配置集群](PGSQL-ADMIN#配置集群)
- [添加实例](PGSQL-ADMIN#添加实例)
- [移除实例](PGSQL-ADMIN#移除实例)
- [下线集群](PGSQL-ADMIN#下线集群)
- [主动切换](PGSQL-ADMIN#主动切换)
- [备份集群](PGSQL-ADMIN#备份集群)
- [恢复集群](PGSQL-ADMIN#恢复集群)
- [疑难杂症](FAQ#PGSQL)


----------------

## 剧本

> 使用幂等的[剧本](PGSQL-PLAYBOOK)，将您的描述变为现实。

- [`pgsql.yml`](PGSQL-PLAYBOOK#pgsqlyml) ：初始化PostgreSQL集群或添加新的从库。
- [`pgsql-rm.yml`](PGSQL-PLAYBOOK#pgsql-rmyml) ：移除PostgreSQL集群，或移除某个实例
- [`pgsql-user.yml`](PGSQL-PLAYBOOK#pgsql-useryml) ：在现有的PostgreSQL集群中添加新的业务用户
- [`pgsql-db.yml`](PGSQL-PLAYBOOK#pgsql-dbyml) ：在现有的PostgreSQL集群中添加新的业务数据库
- [`pgsql-monitor.yml`](PGSQL-PLAYBOOK#pgsql-monitoryml) ：将远程postgres实例纳入监控中
- [`pgsql-migration.yml`](PGSQL-PLAYBOOK#pgsql-migrationyml) ：为现有的PostgreSQL集群生成迁移手册和脚本

<details><summary>样例：安装 PGSQL 模块</summary>

[![asciicast](https://asciinema.org/a/566417.svg)](https://asciinema.org/a/566417)

</details>


<details><summary>样例：移除 PGSQL 模块</summary>

[![asciicast](https://asciinema.org/a/566418.svg)](https://asciinema.org/a/566418)

</details>



----------------

## 监控

>  在 Grafana [仪表盘](PGSQL-DASHBOARD) 中查阅 PostgreSQL 的详情状态。

在 Pigsty 中共有 26 个与 PostgreSQL 相关的监控面板：

|                            总览                             |                               集群                                |                             实例                              |                            数据库                            |
|:---------------------------------------------------------:|:---------------------------------------------------------------:|:-----------------------------------------------------------:|:---------------------------------------------------------:|
| [PGSQL Overview](https://demo.pigsty.cc/d/pgsql-overview) |     [PGSQL Cluster](https://demo.pigsty.cc/d/pgsql-cluster)     |  [PGSQL Instance](https://demo.pigsty.cc/d/pgsql-instance)  | [PGSQL Database](https://demo.pigsty.cc/d/pgsql-database) |
|    [PGSQL Alert](https://demo.pigsty.cc/d/pgsql-alert)    |     [PGRDS Cluster](https://demo.pigsty.cc/d/pgrds-cluster)     |  [PGRDS Instance](https://demo.pigsty.cc/d/pgrds-instance)  | [PGCAT Database](https://demo.pigsty.cc/d/pgcat-database) |
|    [PGSQL Shard](https://demo.pigsty.cc/d/pgsql-shard)    |    [PGSQL Activity](https://demo.pigsty.cc/d/pgsql-activity)    |  [PGCAT Instance](https://demo.pigsty.cc/d/pgcat-instance)  |   [PGSQL Tables](https://demo.pigsty.cc/d/pgsql-tables)   |
|                                                           | [PGSQL Replication](https://demo.pigsty.cc/d/pgsql-replication) |   [PGSQL Persist](https://demo.pigsty.cc/d/pgsql-persist)   |    [PGSQL Table](https://demo.pigsty.cc/d/pgsql-table)    |
|                                                           |     [PGSQL Service](https://demo.pigsty.cc/d/pgsql-service)     |     [PGSQL Proxy](https://demo.pigsty.cc/d/pgsql-proxy)     |    [PGCAT Table](https://demo.pigsty.cc/d/pgcat-table)    |
|                                                           |   [PGSQL Databases](https://demo.pigsty.cc/d/pgsql-databases)   | [PGSQL Pgbouncer](https://demo.pigsty.cc/d/pgsql-pgbouncer) |    [PGSQL Query](https://demo.pigsty.cc/d/pgsql-query)    |
|                                                           |                                                                 |   [PGSQL Session](https://demo.pigsty.cc/d/pgsql-session)   |    [PGCAT Query](https://demo.pigsty.cc/d/pgcat-query)    |
|                                                           |                                                                 |     [PGSQL Xacts](https://demo.pigsty.cc/d/pgsql-xacts)     |    [PGCAT Locks](https://demo.pigsty.cc/d/pgcat-locks)    |
|                                                           |                                                                 |   [Logs Instance](https://demo.pigsty.cc/d/logs-instance)   |   [PGCAT Schema](https://demo.pigsty.cc/d/pgcat-schema)   |



----------------

## 参数

> [PGSQL](PARAM#pgsql) 模块的配置参数列表

- [`PG_ID`](PARAM#pg_id) : 计算和校验 PostgreSQL 实例身份
- [`PG_BUSINESS`](PARAM#pg_business) : PostgreSQL业务对象定义
- [`PG_INSTALL`](PARAM#pg_install) : 安装 PostgreSQL 内核，支持软件包与扩展插件
- [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) : 使用 Patroni 初始化高可用 PostgreSQL 集群
- [`PG_PROVISION`](PARAM#pg_provision) : 创建 PostgreSQL 用户、数据库和其他数据库内对象
- [`PG_BACKUP`](PARAM#pg_backup) : 使用 pgbackrest 设置备份仓库
- [`PG_SERVICE`](PARAM#pg_service) : 暴露 PostgreSQL 服务，绑定 VIP （可选），以及注册DNS
- [`PG_EXPORTER`](PARAM#pg_exporter) : 为 PostgreSQL 实例添加监控，并注册至基础设施中。


<details><summary>完整参数列表</summary>

| 参数                                                                   | 参数组                                  |     类型      |  级别   | 说明                                                                            | 中文说明                                                                         |
|----------------------------------------------------------------------|--------------------------------------|:-----------:|:-----:|-------------------------------------------------------------------------------|------------------------------------------------------------------------------|
| [`pg_mode`](PARAM#pg_mode)                                           | [`PG_ID`](PARAM#pg_id)               |    enum     |   C   | pgsql cluster mode: pgsql,citus,gpsql                                         | pgsql 集群模式: pgsql,citus,gpsql                                                |
| [`pg_cluster`](PARAM#pg_cluster)                                     | [`PG_ID`](PARAM#pg_id)               |   string    |   C   | pgsql cluster name, REQUIRED identity parameter                               | pgsql 集群名称, 必选身份参数                                                           |
| [`pg_seq`](PARAM#pg_seq)                                             | [`PG_ID`](PARAM#pg_id)               |     int     |   I   | pgsql instance seq number, REQUIRED identity parameter                        | pgsql 实例号, 必选身份参数                                                            |
| [`pg_role`](PARAM#pg_role)                                           | [`PG_ID`](PARAM#pg_id)               |    enum     |   I   | pgsql role, REQUIRED, could be primary,replica,offline                        | pgsql 实例角色, 必选身份参数, 可为 primary，replica，offline                               |
| [`pg_instances`](PARAM#pg_instances)                                 | [`PG_ID`](PARAM#pg_id)               |    dict     |   I   | define multiple pg instances on node in `{port:ins_vars}` format              | 在一个节点上定义多个 pg 实例，使用 `{port:ins_vars}` 格式                                     |
| [`pg_upstream`](PARAM#pg_upstream)                                   | [`PG_ID`](PARAM#pg_id)               |     ip      |   I   | repl upstream ip addr for standby cluster or cascade replica                  | 级联从库或备份集群或的复制上游节点IP地址                                                        |
| [`pg_shard`](PARAM#pg_shard)                                         | [`PG_ID`](PARAM#pg_id)               |   string    |   C   | pgsql shard name, optional identity for sharding clusters                     | pgsql 分片名，对 citus 与 gpsql 等水平分片集群为必选身份参数                                     |
| [`pg_group`](PARAM#pg_group)                                         | [`PG_ID`](PARAM#pg_id)               |     int     |   C   | pgsql shard index number, optional identity for sharding clusters             | pgsql 分片号，正整数，对 citus 与 gpsql 等水平分片集群为必选身份参数                                 |
| [`gp_role`](PARAM#gp_role)                                           | [`PG_ID`](PARAM#pg_id)               |    enum     |   C   | greenplum role of this cluster, could be master or segment                    | 这个集群的 greenplum 角色，可以是 master 或 segment                                      |
| [`pg_exporters`](PARAM#pg_exporters)                                 | [`PG_ID`](PARAM#pg_id)               |    dict     |   C   | additional pg_exporters to monitor remote postgres instances                  | 在该节点上设置额外的 pg_exporters 用于监控远程 postgres 实例                                   |
| [`pg_offline_query`](PARAM#pg_offline_query)                         | [`PG_ID`](PARAM#pg_id)               |    bool     |   I   | set to true to enable offline query on this instance                          | 设置为 true 将此只读实例标记为特殊的离线从库，承载 Offline 服务，允许离线查询                               |
| [`pg_users`](PARAM#pg_users)                                         | [`PG_BUSINESS`](PARAM#pg_business)   |   user[]    |   C   | postgres business users                                                       | postgres 业务用户                                                                |
| [`pg_databases`](PARAM#pg_databases)                                 | [`PG_BUSINESS`](PARAM#pg_business)   | database[]  |   C   | postgres business databases                                                   | postgres 业务数据库                                                               |
| [`pg_services`](PARAM#pg_services)                                   | [`PG_BUSINESS`](PARAM#pg_business)   |  service[]  |   C   | postgres business services                                                    | postgres 业务服务                                                                |
| [`pg_hba_rules`](PARAM#pg_hba_rules)                                 | [`PG_BUSINESS`](PARAM#pg_business)   |    hba[]    |   C   | business hba rules for postgres                                               | postgres 的业务 hba 规则                                                          |
| [`pgb_hba_rules`](PARAM#pgb_hba_rules)                               | [`PG_BUSINESS`](PARAM#pg_business)   |    hba[]    |   C   | business hba rules for pgbouncer                                              | pgbouncer 的业务 hba 规则                                                         |
| [`pg_replication_username`](PARAM#pg_replication_username)           | [`PG_BUSINESS`](PARAM#pg_business)   |  username   |   G   | postgres replication username, `replicator` by default                        | postgres 复制用户名，默认为 `replicator`                                              |
| [`pg_replication_password`](PARAM#pg_replication_password)           | [`PG_BUSINESS`](PARAM#pg_business)   |  password   |   G   | postgres replication password, `DBUser.Replicator` by default                 | postgres 复制密码，默认为 `DBUser.Replicator`                                        |
| [`pg_admin_username`](PARAM#pg_admin_username)                       | [`PG_BUSINESS`](PARAM#pg_business)   |  username   |   G   | postgres admin username, `dbuser_dba` by default                              | postgres 管理员用户名，默认为 `dbuser_dba`                                             |
| [`pg_admin_password`](PARAM#pg_admin_password)                       | [`PG_BUSINESS`](PARAM#pg_business)   |  password   |   G   | postgres admin password in plain text, `DBUser.DBA` by default                | postgres 管理员明文密码，默认为 `DBUser.DBA`                                            |
| [`pg_monitor_username`](PARAM#pg_monitor_username)                   | [`PG_BUSINESS`](PARAM#pg_business)   |  username   |   G   | postgres monitor username, `dbuser_monitor` by default                        | postgres 监控用户名，默认为 `dbuser_monitor`                                          |
| [`pg_monitor_password`](PARAM#pg_monitor_password)                   | [`PG_BUSINESS`](PARAM#pg_business)   |  password   |   G   | postgres monitor password, `DBUser.Monitor` by default                        | postgres 监控密码，默认为 `DBUser.Monitor`                                           |
| [`pg_dbsu_password`](PARAM#pg_dbsu_password)                         | [`PG_BUSINESS`](PARAM#pg_business)   |  password   |  G/C  | dbsu password, empty string means no dbsu password by default                 | dbsu 密码，默认为空字符串意味着不设置 dbsu 密码，最好不要设置。                                        |
| [`pg_dbsu`](PARAM#pg_dbsu)                                           | [`PG_INSTALL`](PARAM#pg_install)     |  username   |   C   | os dbsu name, postgres by default, better not change it                       | 操作系统 dbsu 名称，默认为 postgres，最好不要更改                                             |
| [`pg_dbsu_uid`](PARAM#pg_dbsu_uid)                                   | [`PG_INSTALL`](PARAM#pg_install)     |     int     |   C   | os dbsu uid and gid, 26 for default postgres users and groups                 | 操作系统 dbsu uid 和 gid，对于默认的 postgres 用户和组为 26                                  |
| [`pg_dbsu_sudo`](PARAM#pg_dbsu_sudo)                                 | [`PG_INSTALL`](PARAM#pg_install)     |    enum     |   C   | dbsu sudo privilege, none,limit,all,nopass. limit by default                  | dbsu sudo 权限, none,limit,all,nopass，默认为 limit，有限sudo权限                       |
| [`pg_dbsu_home`](PARAM#pg_dbsu_home)                                 | [`PG_INSTALL`](PARAM#pg_install)     |    path     |   C   | postgresql home directory, `/var/lib/pgsql` by default                        | postgresql 主目录，默认为 `/var/lib/pgsql`                                          |
| [`pg_dbsu_ssh_exchange`](PARAM#pg_dbsu_ssh_exchange)                 | [`PG_INSTALL`](PARAM#pg_install)     |    bool     |   C   | exchange postgres dbsu ssh key among same pgsql cluster                       | 在 pgsql 集群之间交换 postgres dbsu ssh 密钥                                          |
| [`pg_version`](PARAM#pg_version)                                     | [`PG_INSTALL`](PARAM#pg_install)     |    enum     |   C   | postgres major version to be installed, 15 by default                         | 要安装的 postgres 主版本，默认为 15                                                     |
| [`pg_bin_dir`](PARAM#pg_bin_dir)                                     | [`PG_INSTALL`](PARAM#pg_install)     |    path     |   C   | postgres binary dir, `/usr/pgsql/bin` by default                              | postgres 二进制目录，默认为 `/usr/pgsql/bin`                                          |
| [`pg_log_dir`](PARAM#pg_log_dir)                                     | [`PG_INSTALL`](PARAM#pg_install)     |    path     |   C   | postgres log dir, `/pg/log/postgres` by default                               | postgres 日志目录，默认为 `/pg/log/postgres`                                         |
| [`pg_packages`](PARAM#pg_packages)                                   | [`PG_INSTALL`](PARAM#pg_install)     |  string[]   |   C   | pg packages to be installed, `${pg_version}` will be replaced                 | 要安装的 pg 包，`${pg_version}` 将被替换为实际主版本号                                        |
| [`pg_extensions`](PARAM#pg_extensions)                               | [`PG_INSTALL`](PARAM#pg_install)     |  string[]   |   C   | pg extensions to be installed, `${pg_version}` will be replaced               | 要安装的 pg 扩展，`${pg_version}` 将被替换为实际主版本号                                       |
| [`pg_safeguard`](PARAM#pg_safeguard)                                 | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    bool     | G/C/A | prevent purging running postgres instance? false by default                   | 防误删保险，禁止清除正在运行的 postgres 实例？默认为 false                                        |
| [`pg_clean`](PARAM#pg_clean)                                         | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    bool     | G/C/A | purging existing postgres during pgsql init? true by default                  | 在 pgsql 初始化期间清除现有的 postgres？默认为 true                                         |
| [`pg_data`](PARAM#pg_data)                                           | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    path     |   C   | postgres data directory, `/pg/data` by default                                | postgres 数据目录，默认为 `/pg/data`                                                 |
| [`pg_fs_main`](PARAM#pg_fs_main)                                     | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    path     |   C   | mountpoint/path for postgres main data, `/data` by default                    | postgres 主数据的挂载点/路径，默认为 `/data`                                              |
| [`pg_fs_bkup`](PARAM#pg_fs_bkup)                                     | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    path     |   C   | mountpoint/path for pg backup data, `/data/backup` by default                 | pg 备份数据的挂载点/路径，默认为 `/data/backup`                                            |
| [`pg_storage_type`](PARAM#pg_storage_type)                           | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    enum     |   C   | storage type for pg main data, SSD,HDD, SSD by default                        | pg 主数据的存储类型，SSD、HDD，默认为 SSD，影响自动优化的参数。                                       |
| [`pg_dummy_filesize`](PARAM#pg_dummy_filesize)                       | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    size     |   C   | size of `/pg/dummy`, hold 64MB disk space for emergency use                   | `/pg/dummy` 的大小，默认保留 64MB 磁盘空间用于紧急抢修                                         |
| [`pg_listen`](PARAM#pg_listen)                                       | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    ip(s)    |  C/I  | postgres/pgbouncer listen addresses, comma separated list                     | postgres/pgbouncer 的监听地址，用逗号分隔的IP列表，默认为 `0.0.0.0`                            |
| [`pg_port`](PARAM#pg_port)                                           | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    port     |   C   | postgres listen port, 5432 by default                                         | postgres 监听端口，默认为 5432                                                       |
| [`pg_localhost`](PARAM#pg_localhost)                                 | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    path     |   C   | postgres unix socket dir for localhost connection                             | postgres 的 Unix 套接字目录，用于本地连接                                                 |
| [`pg_namespace`](PARAM#pg_namespace)                                 | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    path     |   C   | top level key namespace in etcd, used by patroni & vip                        | 在 etcd 中的顶级键命名空间，被 patroni & vip 用于高可用管理                                     |
| [`patroni_enabled`](PARAM#patroni_enabled)                           | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    bool     |   C   | if disabled, no postgres cluster will be created during init                  | 如果禁用，初始化期间不会创建 postgres 集群                                                   |
| [`patroni_mode`](PARAM#patroni_mode)                                 | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    enum     |   C   | patroni working mode: default,pause,remove                                    | patroni 工作模式：default,pause,remove                                            |
| [`patroni_port`](PARAM#patroni_port)                                 | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    port     |   C   | patroni listen port, 8008 by default                                          | patroni 监听端口，默认为 8008                                                        |
| [`patroni_log_dir`](PARAM#patroni_log_dir)                           | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    path     |   C   | patroni log dir, `/pg/log/patroni` by default                                 | patroni 日志目录，默认为 `/pg/log/patroni`                                           |
| [`patroni_ssl_enabled`](PARAM#patroni_ssl_enabled)                   | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    bool     |   G   | secure patroni RestAPI communications with SSL?                               | 使用 SSL 保护 patroni RestAPI 通信？                                                |
| [`patroni_watchdog_mode`](PARAM#patroni_watchdog_mode)               | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    enum     |   C   | patroni watchdog mode: automatic,required,off. off by default                 | patroni 看门狗模式：automatic,required,off，默认为 off                                 |
| [`patroni_username`](PARAM#patroni_username)                         | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |  username   |   C   | patroni restapi username, `postgres` by default                               | patroni restapi 用户名，默认为 `postgres`                                           |
| [`patroni_password`](PARAM#patroni_password)                         | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |  password   |   C   | patroni restapi password, `Patroni.API` by default                            | patroni restapi 密码，默认为 `Patroni.API`                                         |
| [`patroni_citus_db`](#patroni_citus_db)                              | [`PG_BOOTSTRAP`](#pg_bootstrap)      |   string    |   C   | citus database managed by patroni, postgres by default                        | 由 Patroni 所管理的 Citus 数据库名称，默认为 `postgres`                                    |
| [`pg_conf`](PARAM#pg_conf)                                           | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    enum     |   C   | config template: oltp,olap,crit,tiny. `oltp.yml` by default                   | 配置模板：oltp,olap,crit,tiny，默认为 `oltp.yml`                                      |
| [`pg_max_conn`](PARAM#pg_max_conn)                                   | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |     int     |   C   | postgres max connections, `auto` will use recommended value                   | postgres 最大连接数，`auto` 将使用推荐值                                                 |
| [`pg_shared_buffer_ratio`](PARAM#pg_shared_buffer_ratio)             | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    float    |   C   | postgres shared buffer memory ratio, 0.25 by default, 0.1~0.4                 | postgres 共享缓冲区内存比率，默认为 0.25，范围 0.1~0.4                                       |
| [`pg_rto`](PARAM#pg_rto)                                             | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |     int     |   C   | recovery time objective in seconds, `30s` by default                          | 恢复时间目标（秒），默认为 `30s`                                                          |
| [`pg_rpo`](PARAM#pg_rpo)                                             | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |     int     |   C   | recovery point objective in bytes, `1MiB` at most by default                  | 恢复点目标（字节），默认为 `1MiB`                                                         |
| [`pg_libs`](PARAM#pg_libs)                                           | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |   string    |   C   | preloaded libraries, `timescaledb,pg_stat_statements,auto_explain` by default | 预加载的库，默认为 `timescaledb,pg_stat_statements,auto_explain`                      |
| [`pg_delay`](PARAM#pg_delay)                                         | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |  interval   |   I   | replication apply delay for standby cluster leader                            | 备份集群主库的WAL重放应用延迟，用于制备延迟从库                                                    |
| [`pg_checksum`](PARAM#pg_checksum)                                   | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    bool     |   C   | enable data checksum for postgres cluster?                                    | 为 postgres 集群启用数据校验和？                                                        |
| [`pg_pwd_enc`](PARAM#pg_pwd_enc)                                     | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    enum     |   C   | passwords encryption algorithm: md5,scram-sha-256                             | 密码加密算法：md5,scram-sha-256                                                     |
| [`pg_encoding`](PARAM#pg_encoding)                                   | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    enum     |   C   | database cluster encoding, `UTF8` by default                                  | 数据库集群编码，默认为 `UTF8`                                                           |
| [`pg_locale`](PARAM#pg_locale)                                       | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    enum     |   C   | database cluster local, `C` by default                                        | 数据库集群本地化设置，默认为 `C`                                                           |
| [`pg_lc_collate`](PARAM#pg_lc_collate)                               | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    enum     |   C   | database cluster collate, `C` by default                                      | 数据库集群排序，默认为 `C`                                                              |
| [`pg_lc_ctype`](PARAM#pg_lc_ctype)                                   | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    enum     |   C   | database character type, `en_US.UTF8` by default                              | 数据库字符类型，默认为 `en_US.UTF8`                                                     |
| [`pgbouncer_enabled`](PARAM#pgbouncer_enabled)                       | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    bool     |   C   | if disabled, pgbouncer will not be launched on pgsql host                     | 如果禁用，则不会配置 pgbouncer 连接池                                                     |
| [`pgbouncer_port`](PARAM#pgbouncer_port)                             | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    port     |   C   | pgbouncer listen port, 6432 by default                                        | pgbouncer 监听端口，默认为 6432                                                      |
| [`pgbouncer_log_dir`](PARAM#pgbouncer_log_dir)                       | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    path     |   C   | pgbouncer log dir, `/pg/log/pgbouncer` by default                             | pgbouncer 日志目录，默认为 `/pg/log/pgbouncer`                                       |
| [`pgbouncer_auth_query`](PARAM#pgbouncer_auth_query)                 | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    bool     |   C   | query postgres to retrieve unlisted business users?                           | 使用 AuthQuery 来从 postgres 获取未列出的业务用户？                                         |
| [`pgbouncer_poolmode`](PARAM#pgbouncer_poolmode)                     | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    enum     |   C   | pooling mode: transaction,session,statement, transaction by default           | 池化模式：transaction,session,statement，默认为 transaction                           |
| [`pgbouncer_sslmode`](PARAM#pgbouncer_sslmode)                       | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    enum     |   C   | pgbouncer client ssl mode, disable by default                                 | pgbouncer 客户端 SSL 模式，默认为禁用                                                   |
| [`pg_provision`](PARAM#pg_provision)                                 | [`PG_PROVISION`](PARAM#pg_provision) |    bool     |   C   | provision postgres cluster after bootstrap                                    | 在引导后置备 postgres 集群内部的业务对象？                                                   |
| [`pg_init`](PARAM#pg_init)                                           | [`PG_PROVISION`](PARAM#pg_provision) |   string    |  G/C  | provision init script for cluster template, `pg-init` by default              | 为集群模板提供初始化脚本，默认为 `pg-init`                                                   |
| [`pg_default_roles`](PARAM#pg_default_roles)                         | [`PG_PROVISION`](PARAM#pg_provision) |   role[]    |  G/C  | default roles and users in postgres cluster                                   | postgres 集群中的默认预定义角色和系统用户                                                    |
| [`pg_default_privileges`](PARAM#pg_default_privileges)               | [`PG_PROVISION`](PARAM#pg_provision) |  string[]   |  G/C  | default privileges when created by admin user                                 | 由管理员用户创建数据库内对象时的默认权限                                                         |
| [`pg_default_schemas`](PARAM#pg_default_schemas)                     | [`PG_PROVISION`](PARAM#pg_provision) |  string[]   |  G/C  | default schemas to be created                                                 | 要创建的默认模式列表                                                                   |
| [`pg_default_extensions`](PARAM#pg_default_extensions)               | [`PG_PROVISION`](PARAM#pg_provision) | extension[] |  G/C  | default extensions to be created                                              | 要创建的默认扩展列表                                                                   |
| [`pg_reload`](PARAM#pg_reload)                                       | [`PG_PROVISION`](PARAM#pg_provision) |    bool     |   A   | reload postgres after hba changes                                             | 更改HBA后，是否立即重载 postgres 配置                                                    |
| [`pg_default_hba_rules`](PARAM#pg_default_hba_rules)                 | [`PG_PROVISION`](PARAM#pg_provision) |    hba[]    |  G/C  | postgres default host-based authentication rules                              | postgres 基于主机的认证规则，全局PG默认HBA                                                 |
| [`pgb_default_hba_rules`](PARAM#pgb_default_hba_rules)               | [`PG_PROVISION`](PARAM#pg_provision) |    hba[]    |  G/C  | pgbouncer default host-based authentication rules                             | pgbouncer 默认的基于主机的认证规则，全局PGB默认HBA                                            |
| [`pgbackrest_enabled`](PARAM#pgbackrest_enabled)                     | [`PG_BACKUP`](PARAM#pg_backup)       |    bool     |   C   | enable pgbackrest on pgsql host?                                              | 在 pgsql 主机上启用 pgbackrest？                                                    |
| [`pgbackrest_clean`](PARAM#pgbackrest_clean)                         | [`PG_BACKUP`](PARAM#pg_backup)       |    bool     |   C   | remove pg backup data during init?                                            | 在初始化时删除以前的 pg 备份数据？                                                          |
| [`pgbackrest_log_dir`](PARAM#pgbackrest_log_dir)                     | [`PG_BACKUP`](PARAM#pg_backup)       |    path     |   C   | pgbackrest log dir, `/pg/log/pgbackrest` by default                           | pgbackrest 日志目录，默认为 `/pg/log/pgbackrest`                                     |
| [`pgbackrest_method`](PARAM#pgbackrest_method)                       | [`PG_BACKUP`](PARAM#pg_backup)       |    enum     |   C   | pgbackrest repo method: local,minio,etc...                                    | pgbackrest 使用的仓库：local,minio,等...                                            |
| [`pgbackrest_repo`](PARAM#pgbackrest_repo)                           | [`PG_BACKUP`](PARAM#pg_backup)       |    dict     |  G/C  | pgbackrest repo: https://pgbackrest.org/configuration.html#section-repository | pgbackrest 仓库定义：https://pgbackrest.org/configuration.html#section-repository |
| [`pg_weight`](PARAM#pg_weight)                                       | [`PG_SERVICE`](PARAM#pg_service)     |     int     |   I   | relative load balance weight in service, 100 by default, 0-255                | 在服务中的相对负载均衡权重，默认为 100，范围 0-255                                               |
| [`pg_service_provider`](PARAM#pg_service_provider)                   | [`PG_SERVICE`](PARAM#pg_service)     |    enum     |  G/C  | dedicate haproxy node group name, or empty string for local nodes by default  | 专用的 haproxy 节点组名称，或默认空字符，使用本地节点上的 haproxy                                    |
| [`pg_default_service_dest`](PARAM#pg_default_service_dest)           | [`PG_SERVICE`](PARAM#pg_service)     |    enum     |  G/C  | default service destination if svc.dest='default'                             | 如果 svc.dest='default'，默认服务指向哪里？postgres 或 pgbouncer，默认指向 pgbouncer           |
| [`pg_default_services`](PARAM#pg_default_services)                   | [`PG_SERVICE`](PARAM#pg_service)     |  service[]  |  G/C  | postgres default service definitions                                          | postgres 默认服务定义列表，全局共用。                                                      |
| [`pg_vip_enabled`](PARAM#pg_vip_enabled)                             | [`PG_SERVICE`](PARAM#pg_service)     |    bool     |   C   | enable a l2 vip for pgsql primary? false by default                           | 是否为 pgsql 主节点启用 L2 VIP？默认不启用                                                 |
| [`pg_vip_address`](PARAM#pg_vip_address)                             | [`PG_SERVICE`](PARAM#pg_service)     |    cidr4    |   C   | vip address in `<ipv4>/<mask>` format, require if vip is enabled              | vip 地址的格式为 <ipv4>/<mask>，启用 vip 时为必选参数                                       |
| [`pg_vip_interface`](PARAM#pg_vip_interface)                         | [`PG_SERVICE`](PARAM#pg_service)     |   string    |  C/I  | vip network interface to listen, eth0 by default                              | 监听的 vip 网络接口，默认为 eth0                                                        |
| [`pg_dns_suffix`](PARAM#pg_dns_suffix)                               | [`PG_SERVICE`](PARAM#pg_service)     |   string    |   C   | pgsql dns suffix, '' by default                                               | pgsql dns 后缀，默认为空                                                            |
| [`pg_dns_target`](PARAM#pg_dns_target)                               | [`PG_SERVICE`](PARAM#pg_service)     |    enum     |   C   | auto, primary, vip, none, or ad hoc ip                                        | PG DNS 解析到哪里？auto、primary、vip、none 或者特定的 IP 地址                               |
| [`pg_exporter_enabled`](PARAM#pg_exporter_enabled)                   | [`PG_EXPORTER`](PARAM#pg_exporter)   |    bool     |   C   | enable pg_exporter on pgsql hosts?                                            | 在 pgsql 主机上启用 pg_exporter 吗？                                                 |
| [`pg_exporter_config`](PARAM#pg_exporter_config)                     | [`PG_EXPORTER`](PARAM#pg_exporter)   |   string    |   C   | pg_exporter configuration file name                                           | pg_exporter 配置文件/模板名称                                                        |
| [`pg_exporter_cache_ttls`](PARAM#pg_exporter_cache_ttls)             | [`PG_EXPORTER`](PARAM#pg_exporter)   |   string    |   C   | pg_exporter collector ttl stage in seconds, '1,10,60,300' by default          | pg_exporter 收集器阶梯TTL配置，默认为4个由逗号分隔的秒数：'1,10,60,300'                           |
| [`pg_exporter_port`](PARAM#pg_exporter_port)                         | [`PG_EXPORTER`](PARAM#pg_exporter)   |    port     |   C   | pg_exporter listen port, 9630 by default                                      | pg_exporter 监听端口，默认为 9630                                                    |
| [`pg_exporter_params`](PARAM#pg_exporter_params)                     | [`PG_EXPORTER`](PARAM#pg_exporter)   |   string    |   C   | extra url parameters for pg_exporter dsn                                      | pg_exporter dsn 中传入的额外 URL 参数                                                |
| [`pg_exporter_url`](PARAM#pg_exporter_url)                           | [`PG_EXPORTER`](PARAM#pg_exporter)   |    pgurl    |   C   | overwrite auto-generate pg dsn if specified                                   | 如果指定，则覆盖自动生成的 postgres DSN 连接串                                               |
| [`pg_exporter_auto_discovery`](PARAM#pg_exporter_auto_discovery)     | [`PG_EXPORTER`](PARAM#pg_exporter)   |    bool     |   C   | enable auto database discovery? enabled by default                            | 监控是否启用自动数据库发现？默认启用                                                           |
| [`pg_exporter_exclude_database`](PARAM#pg_exporter_exclude_database) | [`PG_EXPORTER`](PARAM#pg_exporter)   |   string    |   C   | csv of database that WILL NOT be monitored during auto-discovery              | 启用自动发现时，排除在外的数据库名称列表，用逗号分隔                                                   |
| [`pg_exporter_include_database`](PARAM#pg_exporter_include_database) | [`PG_EXPORTER`](PARAM#pg_exporter)   |   string    |   C   | csv of database that WILL BE monitored during auto-discovery                  | 启用自动发现时，只监控这个列表中的数据库，名称用逗号分隔                                                 |
| [`pg_exporter_connect_timeout`](PARAM#pg_exporter_connect_timeout)   | [`PG_EXPORTER`](PARAM#pg_exporter)   |     int     |   C   | pg_exporter connect timeout in ms, 200 by default                             | pg_exporter 连接超时，单位毫秒，默认为 200                                                |
| [`pg_exporter_options`](PARAM#pg_exporter_options)                   | [`PG_EXPORTER`](PARAM#pg_exporter)   |     arg     |   C   | overwrite extra options for pg_exporter                                       | pg_exporter 的额外命令行参数选项                                                       |
| [`pgbouncer_exporter_enabled`](PARAM#pgbouncer_exporter_enabled)     | [`PG_EXPORTER`](PARAM#pg_exporter)   |    bool     |   C   | enable pgbouncer_exporter on pgsql hosts?                                     | 在 pgsql 主机上启用 pgbouncer_exporter 吗？                                          |
| [`pgbouncer_exporter_port`](PARAM#pgbouncer_exporter_port)           | [`PG_EXPORTER`](PARAM#pg_exporter)   |    port     |   C   | pgbouncer_exporter listen port, 9631 by default                               | pgbouncer_exporter 监听端口，默认为 9631                                             |
| [`pgbouncer_exporter_url`](PARAM#pgbouncer_exporter_url)             | [`PG_EXPORTER`](PARAM#pg_exporter)   |    pgurl    |   C   | overwrite auto-generate pgbouncer dsn if specified                            | 如果指定，则覆盖自动生成的 pgbouncer dsn 连接串                                              |
| [`pgbouncer_exporter_options`](PARAM#pgbouncer_exporter_options)     | [`PG_EXPORTER`](PARAM#pg_exporter)   |     arg     |   C   | overwrite extra options for pgbouncer_exporter                                | pgbouncer_exporter 的额外命令行参数选项                                                |

</details>



----------------

## 教程

> 一些使用/管理 Pigsty中 PostgreSQL 数据库的教程。

- 克隆一套现有的 PostgreSQL 集群
- 创建一套现有 PostgreSQL 集群的在线备份集群。
- 创建一套现有 PostgreSQL 集群的延迟备份集群
- 监控一个已有的 postgres 实例？
- 使用逻辑复制从外部 PostgreSQL 迁移至 Pigsty 托管的 PostgreSQL 实例？
- 使用 MinIO 作为集中的 pgBackRest 备份仓库。
- 使用专门的 etcd 集群作为 PostgreSQL / Patroni 的 DCS ？
- 使用专用的 haproxy 负载均衡器集群对外暴露暴露 PostgreSQL 服务。
- 使用 pg-meta CMDB 替代 pigsty.yml 作为配置清单源。
- 使用 PostgreSQL 作为 Grafana 的后端存储数据库？
- 使用 PostgreSQL 作为 Prometheus 后端存储数据库？
