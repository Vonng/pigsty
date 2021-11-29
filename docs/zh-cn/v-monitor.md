# 监控系统

每一个被管理的Postgres实例都包括有4个采集端口：
* 采集机器节点指标的 [Node Exporter](https://github.com/prometheus/node_exporter)
* 采集数据库指标的 [PG Exporter](https://github.com/Vonng/pg_exporter)
* 采集连接池指标的 [PGBouncer Exporter](https://github.com/Vonng/pg_exporter) （与PG Exporter使用同一二进制）
* 采集负载均衡器指标的 [HAProxy](https://github.com/Vonng/pg_exporter) （内建支持，无需单独部署）

![](../_media/node.svg)

这些采集端口会被[管理节点](c-arch.md#管理节点)上的Prometheus所采集。
此外，可选的Promtail用于收集Postgres，Patroni，Pgbouncer日志，是可选的额外安装组件。

默认情况下，所有监控端点都会被注册至Consul，但Prometheus默认会通过静态文件服务发现的方式管理这些任务。
用户可以通过配置 [`prometheus_sd_method`](v-meta.md#prometheus_sd_method) 为 `consul` 来使用Consul服务发现，动态管理实例


## 参数概览

|                           名称                            |   类型   | 层级 | 说明                           |
| :-------------------------------------------------------: | :------: | :--: | ------------------------------ |
|           [exporter_install](#exporter_install)           |  `enum`  | G/C  | 安装监控组件的方式             |
|          [exporter_repo_url](#exporter_repo_url)          | `string` | G/C  | 监控组件的YumRepo              |
|      [exporter_metrics_path](#exporter_metrics_path)      | `string` | G/C  | 监控暴露的URL Path             |
|      [node_exporter_enabled](#node_exporter_enabled)      |  `bool`  | G/C  | 启用节点指标收集器             |
|         [node_exporter_port](#node_exporter_port)         | `number` | G/C  | 节点指标暴露端口               |
|      [node_exporter_options](#node_exporter_options)      | `string` | G/C  | 节点指标采集选项               |
|         [pg_exporter_config](#pg_exporter_config)         | `string` | G/C  | PG指标定义文件                 |
|        [pg_exporter_enabled](#pg_exporter_enabled)        |  `bool`  | G/C  | 启用PG指标收集器               |
|           [pg_exporter_port](#pg_exporter_port)           | `number` | G/C  | PG指标暴露端口                 |
|            [pg_exporter_url](#pg_exporter_url)            | `string` | G/C  | 采集对象数据库的连接串（覆盖） |
| [pg_exporter_auto_discovery](#pg_exporter_auto_discovery)     |  `bool`    |  G/C  | 是否自动发现实例中的数据库 |
| [pg_exporter_exclude_database](#pg_exporter_exclude_database) |  `string`  |  G/C  | 数据库自动发现排除列表 |
| [pg_exporter_include_database](#pg_exporter_include_database) |  `string`  |  G/C  | 数据库自动发现囊括列表 |
| [pgbouncer_exporter_enabled](#pgbouncer_exporter_enabled) |  `bool`  | G/C  | 启用PGB指标收集器              |
|    [pgbouncer_exporter_port](#pgbouncer_exporter_port)    | `number` | G/C  | PGB指标暴露端口                |
|     [pgbouncer_exporter_url](#pgbouncer_exporter_url)     | `string` | G/C  | 采集对象连接池的连接串         |
|        [promtail_enabled](#promtail_enabled)        |  `bool`  | G/C  | 是否启用Promtail日志收集服务？              |
|        [promtail_clean](#promtail_clean)        |  `bool`  | G/C/A  | 是否在安装promtail时移除已有状态信息？      |
|         [promtail_port](#promtail_port)         | `number` | G/C  | promtail使用的默认端口      |
|      [promtail_status_path](#promtail_status_path)      | `string` | G/C  | 保存Promtail状态信息的文件位置      |
|     [promtail_send_url](#promtail_send_url)     | `string` | G/C  | 用于接收日志的loki服务endpoint     |



## 默认参数

```yaml
#------------------------------------------------------------------------------
# MONITOR PROVISION
#------------------------------------------------------------------------------
# - install - #
exporter_install: none                        # none|yum|binary, none by default
exporter_repo_url: ''                         # if set, repo will be added to /etc/yum.repos.d/ before yum installation

# - collect - #
exporter_metrics_path: /metrics               # default metric path for pg related exporter

# - node exporter - #
node_exporter_enabled: true                   # setup node_exporter on instance
node_exporter_port: 9100                      # default port for node exporter
node_exporter_options: '--no-collector.softnet --no-collector.nvme --collector.ntp --collector.tcpstat --collector.processes'

# - pg exporter - #
pg_exporter_config: pg_exporter.yml           # default config files for pg_exporter
pg_exporter_enabled: true                     # setup pg_exporter on instance
pg_exporter_port: 9630                        # default port for pg exporter
pg_exporter_url: ''                           # optional, if not set, generate from reference parameters
pg_exporter_auto_discovery: true              # optional, discovery available database on target instance ?
pg_exporter_exclude_database: 'template0,template1,postgres' # optional, comma separated list of database that WILL NOT be monitored when auto-discovery enabled
pg_exporter_include_database: ''             # optional, comma separated list of database that WILL BE monitored when auto-discovery enabled, empty string will disable include mode
pg_exporter_options: '--log.level=info --log.format="logger:syslog?appname=pg_exporter&local=7"'

# - pgbouncer exporter - #
pgbouncer_exporter_enabled: true              # setup pgbouncer_exporter on instance (if you don't have pgbouncer, disable it)
pgbouncer_exporter_port: 9631                 # default port for pgbouncer exporter
pgbouncer_exporter_url: ''                    # optional, if not set, generate from reference parameters
pgbouncer_exporter_options: '--log.level=info --log.format="logger:syslog?appname=pgbouncer_exporter&local=7"'

# - promtail - #                              # promtail is a beta feature which requires manual deployment
promtail_enabled: true                        # enable promtail logging collector?
promtail_clean: false                         # remove promtail status file? false by default
promtail_port: 9080                           # default listen address for promtail
promtail_status_file: /tmp/promtail-status.yml
promtail_send_url: http://10.10.10.10:3100/loki/api/v1/push  # loki url to receive logs
```





## 参数详解

### exporter_install

指明安装Exporter的方式：

* `none`：不安装，（默认行为，Exporter已经在先前由 `node.pkgs` 任务完成安装）
* `yum`：使用yum安装（如果启用yum安装，在部署Exporter前执行yum安装 `node_exporter` 与 `pg_exporter` ）
* `binary`：使用拷贝二进制的方式安装（从`files`中直接拷贝`node_exporter`与 `pg_exporter` 二进制）

使用`yum`安装时，如果指定了`exporter_repo_url`（不为空），在执行安装时会首先将该URL下的REPO文件安装至`/etc/yum.repos.d`中。这一功能可以在不执行节点基础设施初始化的环境下直接进行Exporter的安装。

使用`binary`安装时，用户需要确保已经将 `node_exporter` 与 `pg_exporter` 的Linux二进制程序放置在`files`目录中。

```bash
<meta>:<pigsty>/files/node_exporter ->  <target>:/usr/bin/node_exporter
<meta>:<pigsty>/files/pg_exporter   ->  <target>:/usr/bin/pg_exporter
```

### exporter_repo_url

包含有Node|PG Exporter监控组件的YUM源 Repo 文件的URL。

默认为空，当 `exporter_install : yum` 时，该参数指定的Repo会被添加至操作系统中。



### exporter_metrics_path

所有Exporter对外暴露指标的URL PATH，默认为`/metrics`

该变量被外部角色`prometheus`引用，Prometheus会根据这里的配置，针对`job = pgsql`的监控对象应用此配置。



### node_exporter_enabled

是否安装并配置`node_exporter`，默认为`true`


### node_exporter_port

`node_exporter`监听的端口

默认端口`9100`



### node_exporter_options

`node_exporter` 使用的额外命令行选项。

该选项主要用于定制 `node_exporter` 启用的指标收集器，Node Exporter支持的收集器列表可以参考：[Node Exporter Collectors](https://github.com/prometheus/node_exporter#collectors)

该选项的默认值为：

```yaml
node_exporter_options: '--no-collector.softnet --collector.ntp --collector.tcpstat --collector.processes'
```



### pg_exporter_config

`pg_exporter`使用的默认配置文件，定义了Pigsty中的数据库与连接池监控指标。

默认为 [`pg_exporter.yml`](https://github.com/Vonng/pigsty/blob/master/roles/monitor/files/pg_exporter.yml)

Pigsty使用的PG Exporter配置文件默认从PostgreSQL 10.0 开始提供支持，目前支持至最新的PG 14版本



### pg_exporter_enabled

是否安装并配置`pg_exporter`，默认为`true`



### pg_exporter_url

PG Exporter用于连接至数据库的PGURL，应当为访问`postgres`管理数据库的URL。

可选参数，默认为空字符串，如果配置了`pg_exporter_url`选项，则会直接使用该URL作为监控连接串。
否则Pigsty将使用以下规则生成监控的目标URL：

```bash
PG_EXPORTER_URL='postgres://{{ pg_monitor_username }}:{{ pg_monitor_password }}@:{{ pg_port }}/postgres?host={{ pg_localhost }}&sslmode=disable'
```

该选项以环境变量的方式配置于 `/etc/default/pg_exporter` 中。

注意：当您只需要监控某一个特定业务数据库时，您可以直接使用该数据库的PGURL。
如果您希望监控某一个数据库实例上**所有**的业务数据库，则建议使用管理数据库`postgres`的PGURL。



### pg_exporter_auto_discovery

PG Exporter v0.4 后的新特性：启用自动数据库发现，默认开启。

开启后，PG Exporter会自动检测目标实例中数据库列表的变化，并为每一个数据库创建一条抓取连接

关闭时，库内对象监控不可用。（如果您不希望在监控系统中暴露业务相关数据，可以关闭此特性）

!> 注意如果您有很多数据库（100+），或数据库内对象非常多（几k，十几k），请审慎评估对象监控产生的开销。



### pg_exporter_exclude_database

逗号分隔的数据库名称列表，启用自动数据库发现时，此列表中的数据库**不会被监控**（被排除在监控对象之外）。



### pg_exporter_include_database

逗号分隔的数据库名称列表，启用自动数据库发现时，不在此列表中的数据库不会被监控（显式指定需要监控的数据库）。



### pgbouncer_exporter_enabled

是否安装并配置`pgbouncer_exporter`，默认为`true`



### pg_exporter_port

`pg_exporter`监听的端口，默认端口`9630`



### pgbouncer_exporter_port

`pgbouncer_exporter`监听的端口，默认端口`9631`



### pgbouncer_exporter_url

PGBouncer Exporter用于连接至数据库的URL，应当为访问`pgbouncer`管理数据库的URL。

可选参数，默认为空字符串。

Pigsty默认使用以下规则生成监控的目标URL，如果配置了`pgbouncer_exporter_url`选项，则会直接使用该URL作为连接串。

```bash
PG_EXPORTER_URL='postgres://{{ pg_monitor_username }}:{{ pg_monitor_password }}@:{{ pgbouncer_port }}/pgbouncer?host={{ pg_localhost }}&sslmode=disable'
```

该选项以环境变量的方式配置于 `/etc/default/pgbouncer_exporter` 中。



### promtail_enabled

布尔类型，全局｜集群变量，是否启用Promtail日志收集服务？默认启用。

需要注意Loki与Promtail目前属于额外选装模块，不会在[`pgsql.yml`](p-pgsql.md)的Monitor部分安装，目前只会在 [`pgsql-promtail.yml`] 剧本中使用。



### promtail_clean

布尔类型，命令行参数。

是否在安装promtail时移除已有状态信息？
状态文件记录在[`promtail_status_file`](#promtail_status_file) 中，记录了所有日志的消费偏移量，默认不会清理。



### promtail_port

promtail使用的默认端口，默认为9080。



### promtail_status_file

字符串类型，集群｜全局变量。

内容为保存Promtail状态信息的文件位置，默认值为 `/tmp/promtail-status.yml`。



### promtail_send_url

用于接收Promtail发送日志的loki endpoint

默认值为：`http://10.10.10.10:3100/loki/api/v1/push`，其中IP地址`10.10.10.10`会在`configure`过程中被替换。
