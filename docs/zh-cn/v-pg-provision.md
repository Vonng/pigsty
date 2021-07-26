PostgreSQL部署

**PG部署**，是在一台安装完Postgres的机器上，创建并拉起一套数据库的过程，包括：

* **集群身份定义**，清理现有实例，创建目录结构，拷贝工具与脚本，配置环境变量
* 渲染Patroni模板配置文件，使用Patroni拉起主库，使用Patroni拉起从库
* 配置Pgbouncer，初始化业务用户与数据库，将数据库与数据源服务注册至DCS。


## 参数概览


|                      名称                       |    类型    | 层级  | 说明                                             |
| :---------------------------------------------: | :--------: | :---: | ------------------------------------------------ |
|            [pg_cluster](#pg_cluster)            |  `string`  | **C** | **PG数据库集群名称** （[身份参数](#身份参数)）   |
|                [pg_seq](#pg_seq)                |  `number`  | **I** | **PG数据库实例序号**（[身份参数](#身份参数)）    |
|               [pg_role](#pg_role)               |   `enum`   | **I** | **PG数据库实例角色** （[身份参数](#身份参数)）   |
|              [pg_shard](#pg_shard)              |  `string`  | **C** | **PG数据库分片集簇名** （[身份参数](#身份参数)） |
|             [pg_sindex](#pg_sindex)             |  `number`  | **C** | **PG数据库分片集簇号** （[身份参数](#身份参数)） |
|           [pg_hostname](#pg_hostname)           |   `bool`   |  G/C  | 将PG实例名称设为HOSTNAME            |
|           [pg_nodename](#pg_nodename)           |   `bool`   |  G/C  | 将PG实例名称设为Consul节点名           |
|             [pg_exists](#pg_exists)             |   `bool`   |   A   | 标记位，PG是否已存在                  |
|      [pg_exists_action](#pg_exists_action)      |   `enum`   |  G/A  | PG存在时如何处理                    |
|      [pg_disable_purge](#pg_disable_purge)      |   `enum`   | G/C/I | 禁止清除存在的PG实例                  |
|               [pg_data](#pg_data)               |  `string`  |   G   | PG数据目录                       |
|            [pg_fs_main](#pg_fs_main)            |  `string`  |   G   | PG主数据盘挂载点                    |
|            [pg_fs_bkup](#pg_fs_bkup)            |   `path`   |   G   | PG备份盘挂载点                     |
|             [pg_listen](#pg_listen)             |    `ip`    |   G   | PG监听的IP地址                    |
|               [pg_port](#pg_port)               |  `number`  |   G   | PG监听的端口                      |
|          [pg_localhost](#pg_localhost)          |  `string`  |  G/C  | PG使用的UnixSocket地址            |
|           [pg_upstream](#pg_upstream)           |  `string`  |   I   | 实例的复制上游节点                    |
|             [pg_backup](#pg_backup)             |   `bool`   |   I   | 是否在实例上存储备份                   |
|              [pg_delay](#pg_delay)              | `interval` |   I   | 若实例为延迟从库，采用的延迟时长             |
|          [patroni_mode](#patroni_mode)          |   `enum`   |  G/C  | Patroni配置模式                  |
|          [pg_namespace](#pg_namespace)          |  `string`  |  G/C  | Patroni使用的DCS命名空间            |
|          [patroni_port](#patroni_port)          |  `string`  |  G/C  | Patroni服务端口                  |
| [patroni_watchdog_mode](#patroni_watchdog_mode) |   `enum`   |  G/C  | Patroni Watchdog模式           |
|               [pg_conf](#pg_conf)               |   `enum`   |  G/C  | Patroni使用的配置模板               |
|  [pg_shared_libraries](#pg_shared_libraries)    |  `string`  |  G/C  | PG默认加载的共享库                    |
|           [pg_encoding](#pg_encoding)           |  `string`  |  G/C  | PG字符集编码                      |
|             [pg_locale](#pg_locale)             |   `enum`   |  G/C  | PG使用的本地化规则                   |
|         [pg_lc_collate](#pg_lc_collate)         |   `enum`   |  G/C  | PG使用的本地化排序规则                 |
|           [pg_lc_ctype](#pg_lc_ctype)           |   `enum`   |  G/C  | PG使用的本地化字符集定义                |
|        [pgbouncer_port](#pgbouncer_port)        |  `number`  |  G/C  | Pgbouncer端口                  |
|    [pgbouncer_poolmode](#pgbouncer_poolmode)    |   `enum`   |  G/C  | Pgbouncer池化模式                |
| [pgbouncer_max_db_conn](#pgbouncer_max_db_conn) |  `number`  |  G/C  | Pgbouncer最大单DB连接数            |

## 默认参数

```yaml
#------------------------------------------------------------------------------
# POSTGRES PROVISION
#------------------------------------------------------------------------------
# - identity - #
# pg_cluster:                                 # [REQUIRED] cluster name (cluster level,  validated during pg_preflight)
# pg_seq: 0                                   # [REQUIRED] instance seq (instance level, validated during pg_preflight)
# pg_role: replica                            # [REQUIRED] service role (instance level, validated during pg_preflight)
# pg_shard:                                   # [OPTIONAL] shard name  (cluster level)
# pg_sindex:                                  # [OPTIONAl] shard index (cluster level)

# - identity option -#
pg_hostname: false                            # overwrite node hostname with pg instance name
pg_nodename: true                             # overwrite consul nodename with pg instance name

# - retention - #
# pg_exists_action, available options: abort|clean|skip
#  - abort: abort entire play's execution (default)
#  - clean: remove existing cluster (dangerous)
#  - skip: end current play for this host
# pg_exists: false                            # auxiliary flag variable (DO NOT SET THIS)
pg_exists_action: abort                       # what to do when found running postgres instance ? (clean are JUST FOR DEMO! do not use this on production)
pg_disable_purge: false                       # set to true to disable pg purge functionality for good (force pg_exists_action = abort)

# - storage - #
pg_data: /pg/data                             # postgres data directory (soft link)
pg_fs_main: /data                             # primary data disk mount point   /pg   -> {{ pg_fs_main }}/postgres/{{ pg_instance }}
pg_fs_bkup: /data/backups                     # backup disk mount point         /pg/* -> {{ pg_fs_bkup }}/postgres/{{ pg_instance }}/*

# - connection - #
pg_listen: '0.0.0.0'                          # postgres listen address, '0.0.0.0' (all ipv4 addr) by default
pg_port: 5432                                 # postgres port, 5432 by default
pg_localhost: /var/run/postgresql             # localhost unix socket dir for connection
# pg_upstream:                                # [OPTIONAL] specify replication upstream, instance level
# Set on primary instance will transform this cluster into a standby cluster
# - patroni - #
# patroni_mode, available options: default|pause|remove
#   - default: default ha mode
#   - pause:   into maintenance mode
#   - remove:  remove patroni after bootstrap
patroni_mode: default                         # pause|default|remove
pg_namespace: /pg                             # top level key namespace in dcs
patroni_port: 8008                            # default patroni port
patroni_watchdog_mode: automatic              # watchdog mode: off|automatic|required

pg_conf: tiny.yml                             # pgsql template:  {oltp|olap|crit|tiny}.yml , use tiny for sandbox
# use oltp|olap|crit for production, or fork your own templates (in ansible templates dir)
# extension shared libraries to be added
pg_shared_libraries: 'citus, timescaledb, pg_stat_statements, auto_explain'

# - flags - #
pg_backup: false                              # store base backup on this node          (instance level, TBD)
pg_delay: 0                                   # apply delay for offline|delayed replica (instance level, TBD)

# - localization - #
pg_encoding: UTF8                             # database cluster encoding, UTF8 by default
pg_locale: C                                  # database cluster local, C by default
pg_lc_collate: C                              # database cluster collate, C by default
pg_lc_ctype: en_US.UTF8                       # database character type, en_US.UTF8 by default (for i18n full-text search)

# - pgbouncer - #
pgbouncer_port: 6432                          # pgbouncer port, 6432 by default
pgbouncer_poolmode: transaction               # pooling mode: session|transaction|statement, transaction pooling by default
pgbouncer_max_db_conn: 100                    # max connection to single database, DO NOT set this larger than postgres max conn or db connlimit
```





## 身份参数

|           名称            |   类型   | 层级  | 说明                            |
| :-----------------------: | :------: | :---: | ------------------------------- |
| [pg_cluster](#pg_cluster) | `string` | **C** | **PG数据库集群名称**            |
|     [pg_seq](#pg_seq)     | `number` | **I** | **PG数据库实例序号**            |
|    [pg_role](#pg_role)    |  `enum`  | **I** | **PG数据库实例角色**            |
|   [pg_shard](#pg_shard)   | `string` | **C** | **PG数据库分片集簇名** （占位） |
|  [pg_sindex](#pg_sindex)  | `number` | **C** | **PG数据库分片集簇号** （占位） |

`pg_cluster`，`pg_role`，`pg_seq` 属于 **身份参数**

除了IP地址外，这三个参数是定义一套新的数据库集群的最小必须参数集，如下面的配置所示。

其他参数都可以继承自全局配置或默认配置，但身份参数必须**显式指定**，**手工分配**。

* `pg_cluster` 标识了集群的名称，在集群层面进行配置。
* `pg_role` 在实例层面进行配置，标识了实例的角色，只有`primary`角色会进行特殊处理，如果不填，默认为`replica`角色，此外，还有特殊的`delayed`与`offline`角色。
* `pg_seq` 用于在集群内标识实例，通常采用从0或1开始递增的整数，一旦分配不再更改。
* `{{ pg_cluster }}-{{ pg_seq }}` 被用于唯一标识实例，即`pg_instance`
* `{{ pg_cluster }}-{{ pg_role }}` 用于标识集群内的服务，即`pg_service`

```yaml
pg-test:
  hosts:
    10.10.10.11: {pg_seq: 1, pg_role: replica}
    10.10.10.12: {pg_seq: 2, pg_role: primary}
    10.10.10.13: {pg_seq: 3, pg_role: replica}
  vars:
    pg_cluster: pg-test
```

`pg_shard` 与 `pg_sindex` 用于水平分片集群，目前在v1.0.0中未实际使用，为后续Citus支持预留。





## 参数详解

### pg_cluster         

PG数据库集群的名称，将用作集群内资源的命名空间。

集群命名需要遵循特定命名规则：`[a-z][a-z0-9-]*`，以兼容不同约束对身份标识的要求。

**身份参数，必填参数，集群级参数**



### pg_seq

数据库实例的序号，在**集群内部唯一**，用于区别与标识集群内的不同实例，从0或1开始分配。

**身份参数，必填参数，实例级参数**



### pg_role    

数据库实例的角色，默认角色包括：`primary`, `replica`。

后续可选角色包括：`offline`与`delayed`。

**身份参数，必填参数，实例级参数**



### pg_shard

只有分片集群需要设置此参数。

当多个数据库集群以水平分片的方式共同服务于同一个 业务时，Pigsty将这一组集群称为 **分片集簇（Sharding Cluster）** 。`pg_shard`是数据库集群所属分片集簇的名称，一个分片集簇可以指定任意名称，但Pigsty建议采用具有意义的命名规则。

例如参与分片集簇的集群，可以使用 分片集簇名 [`pg_shard`](#pg_shard) + `shard` + 集群所属分片编号[`pg_sindex`](#pg_sindex)构成集群名称：

```
shard:  test
pg-testshard1
pg-testshard2
pg-testshard3
pg-testshard4
```

**身份参数，可选参数，集群级参数**



### pg_sindex

集群在分片集簇中的编号，通常从0或1开始依次分配。

只有分片集群需要设置此参数。

**身份参数，选填参数，集群级参数**



### pg_hostname

是否将PG实例的名称`pg_instance` 注册为主机名，默认禁用。



### pg_nodename

是否将PG实例的名称注册为Consul中的节点名称，默认启用。



### pg_exists

PG实例是否存在的标记位，不可配置。



### pg_exists_action

安全保险，当PostgreSQL实例已经存在时，系统应当执行的动作

* abort: 中止整个剧本的执行（默认行为）
* clean: 抹除现有实例并继续（极端危险）
* skip: 忽略存在实例的目标（中止），在其他目标机器上继续执行。

如果您真的需要强制清除已经存在的数据库实例，建议先使用`pgsql-rm.yml`完成集群与实例的下线与销毁，在重新执行初始化。否则，则需要通过命令行参数`-e pg_exists_action=clean`完成覆写，强制在初始化过程中抹除已有实例。



### pg_disable_purge

双重安全保险，默认为`false`。如果为`true`，强制设置`pg_exists_action`变量为`abort`。

等效于关闭`pg_exists_action`的清理功能，确保任何情况下Postgres实例都不会被抹除。

这意味着您需要通过专用下线脚本`pgsql-rm.yml`来完成已有实例的清理，然后才可以在清理干净的节点上重新完成数据库的初始化。



### pg_data

默认数据目录，默认为`/pg/data`



### pg_fs_main

主数据盘目录，默认为`/export`

Pigsty的默认[目录结构](/zh/docs/concepts/provision/fhs/)假设系统中存在一个主数据盘挂载点，用于盛放数据库目录。



### pg_fs_bkup

归档与备份盘目录，默认为`/var/backups`

Pigsty的默认[目录结构](/zh/docs/concepts/provision/fhs/)假设系统中存在一个备份数据盘挂载点，用于盛放备份与归档数据。备份盘并不是必选项，如果系统中不存在备份盘，用户也可以指定一个主数据盘上的子目录作为备份盘根目录挂载点。



### pg_listen

数据库监听的IP地址，默认为所有IPv4地址`0.0.0.0`，如果要包括所有IPv6地址，可以使用`*`。



### pg_port

数据库监听的端口，默认端口为`5432`，不建议修改。



### pg_localhost

Unix Socket目录，用于盛放PostgreSQL与Pgbouncer的Unix socket文件。

默认为`/var/run/postgresql`



### pg_upstream

实例级配置项，内容为IP地址或主机名，用于指明流复制上游节点。

当为集群的从库配置该参数时，填入的IP地址必须为集群内的其他节点。实例会从该节点进行流复制，此选项可用于构建**级连复制**。

当为集群的主库配置该参数时，意味着整个集群将以 **备份集群**（Standby Cluster） 的形式运行，从上游节点接受变更。集群中的`primary`将扮演`standby leader` 的角色。



### pg_backup

标记，实例级配置项，带有该标记的实例会用于存储基础备份（未实现，保留标记位）



### pg_delay

若实例为延迟从库，采用的延迟时长。（未实现，保留标记位）

使用PG接受的时间区间字符串格式，如`1h`，`30min`等。



### patroni_mode

Patroni的工作模式：
* `default`: 启用Patroni
* `pause`: 启用Patroni，但在完成初始化后自动进入维护模式（不自动执行主从切换）
* `remove`: 依然使用Patroni初始化集群，但初始化完成后移除Patroni



### pg_namespace

Patroni在DCS中使用的KV存储顶层命名空间

默认为`pg`



### patroni_port

Patroni API服务器默认监听的端口

默认端口为`8008`



### patroni_watchdog_mode

当发生主从切换时，Patroni会尝试在提升从库前关闭主库。如果指定超时时间内主库仍未成功关闭，Patroni会根据配置使用Linux内核功能softdog进行fencing关机。

* `off`：不使用`watchdog`
* `automatic`：如果内核启用了`softdog`，则启用`watchdog`，不强制，默认行为。
* `required`：强制使用`watchdog`，如果系统未启用`softdog`则拒绝启动。



### pg_conf

拉起Postgres集群所用的Patroni模板。Pigsty预制了4种模板

* [`oltp.yml`](#oltp) 常规OLTP模板，默认配置
* [`olap.yml`](#olap) OLAP模板，提高并行度，针对吞吐量优化，针对长时间运行的查询进行优化。
* [`crit.yml`](#crit)) 核心业务模板，基于OLTP模板针对安全性，数据完整性进行优化，采用同步复制，强制启用数据校验和。
* [`tiny.yml`](#tiny) 微型数据库模板，针对低资源场景进行优化，例如运行于虚拟机中的演示数据库集群。


### pg_shared_libraries

填入Patroni模板中`shared_preload_libraries`参数的字符串，控制PG启动预加载的动态库。

在当前版本中，默认会加载以下库：`citus, timescaledb, pg_stat_statements, auto_explain`


### pg_encoding

PostgreSQL实例初始化时，使用的字符集编码。

默认为`UTF8`，如果没有特殊需求，不建议修改此参数。



### pg_locale

PostgreSQL实例初始化时，使用的本地化规则。

默认为`C`，如果没有特殊需求，不建议修改此参数。



### pg_lc_collate

PostgreSQL实例初始化时，使用的本地化字符串排序规则。

默认为`C`，如果没有特殊需求，**强烈不建议**修改此参数。用户总是可以通过`COLLATE`表达式实现本地化排序相关功能，错误的本地化排序规则可能导致某些操作产生成倍的性能损失，请在真的有本地化需求的情况下修改此参数。



### pg_lc_ctype

PostgreSQL实例初始化时，使用的本地化字符集定义

默认为`en_US.UTF8`，因为一些PG扩展（`pg_trgm`）需要额外的字符分类定义才可以针对国际化字符正常工作，因此Pigsty默认会使用`en_US.UTF8`字符集定义，不建议修改此参数。



### pgbouncer_port

Pgbouncer连接池默认监听的端口

默认为`6432`



### pgbouncer_poolmode

Pgbouncer连接池默认使用的Pool模式

默认为`transaction`，即事务级连接池。其他可选项包括：`session|statemente`



### pgbouncer_max_db_conn

允许连接池与单个数据库之间建立的最大连接数

默认值为`100`

使用事务Pooling模式时，活跃服务端连接数通常处于个位数。如果采用会话Pooling，可以适当增大此参数。