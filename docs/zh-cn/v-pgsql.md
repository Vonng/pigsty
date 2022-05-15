# 配置：PGSQL

> 使用 [PGSQL剧本](p-pgsql.md)，[部署PGSQL](d-pgsql.md)集群，将集群状态调整至 [PGSQL配置](v-pgsql.md)所描述的状态。

您需要通过配置，向Pigsty表达自己对数据库的需求。Pigsty提供了100+参数来对PostgreSQL集群进行完备的描述。但用户通常只需要关心 [身份参数](#PG_IDENTITY) 与 [业务对象](#PG_BUSINESS) 中的个别参数即可：前者表达数据库集群“是谁？在哪？”，后者表达这个数据库“啥样？有啥？”。

Pigsty中，关于PostgreSQL数据库的参数分为7个主要章节：

- [`PG_IDENTITY`](#PG_IDENTITY) : 定义PostgreSQL数据库集群的身份
- [`PG_BUSINESS`](#PG_BUSINESS) : 定制集群模板：用户，数据库，服务，权限规则
- [`PG_INSTALL`](#PG_INSTALL) : 安装PostgreSQL软件包，扩展插件，准备目录结构与工具脚本
- [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) : 生成配置模板，拉起PostgreSQL集群，搭建主从复制，启用连接池
- [`PG_PROVISION`](#PG_PROVISION) : PGSQL集群模板置备，创建用户与数据库，配置权限角色HBA，模式与扩展。
- [`PG_EXPORTER`](#PG_EXPORTER) : PGSQL指标暴露器，数据库与连接池配置监控组件
- [`PG_SERVICE`](#PG_SERVICE) : 对外暴露PostgreSQL服务，安装负载均衡器 HAProxy，启用VIP，配置DNS。


| ID  | Name                                                            |             Section             |    Type     | Level | Comment             |
|-----|-----------------------------------------------------------------|---------------------------------|-------------|-------|---------------------|
| 500 | [`pg_cluster`](#pg_cluster)                                     | [`PG_IDENTITY`](#PG_IDENTITY)   | string      | C     | PG数据库集群名称           |
| 501 | [`pg_shard`](#pg_shard)                                         | [`PG_IDENTITY`](#PG_IDENTITY)   | string      | C     | PG集群所属的Shard (保留)   |
| 502 | [`pg_sindex`](#pg_sindex)                                       | [`PG_IDENTITY`](#PG_IDENTITY)   | int         | C     | PG集群的分片号 (保留)       |
| 503 | [`gp_role`](#gp_role)                                           | [`PG_IDENTITY`](#PG_IDENTITY)   | enum        | C     | 当前PG集群在GP中的角色       |
| 504 | [`pg_role`](#pg_role)                                           | [`PG_IDENTITY`](#PG_IDENTITY)   | enum        | I     | PG数据库实例角色           |
| 505 | [`pg_seq`](#pg_seq)                                             | [`PG_IDENTITY`](#PG_IDENTITY)   | int         | I     | PG数据库实例序号           |
| 506 | [`pg_instances`](#pg_instances)                                 | [`PG_IDENTITY`](#PG_IDENTITY)   | {port:ins}  | I     | 当前节点上的所有PG实例        |
| 507 | [`pg_upstream`](#pg_upstream)                                   | [`PG_IDENTITY`](#PG_IDENTITY)   | string      | I     | 实例的复制上游节点           |
| 508 | [`pg_offline_query`](#pg_offline_query)                         | [`PG_IDENTITY`](#PG_IDENTITY)   | bool        | I     | 是否允许离线查询            |
| 509 | [`pg_backup`](#pg_backup)                                       | [`PG_IDENTITY`](#PG_IDENTITY)   | bool        | I     | 是否在实例上存储备份          |
| 510 | [`pg_weight`](#pg_weight)                                       | [`PG_IDENTITY`](#PG_IDENTITY)   | int         | I     | 实例在负载均衡中的相对权重       |
| 511 | [`pg_hostname`](#pg_hostname)                                   | [`PG_IDENTITY`](#PG_IDENTITY)   | bool        | C/I   | 将PG实例名称设为HOSTNAME   |
| 512 | [`pg_preflight_skip`](#pg_preflight_skip)                       | [`PG_IDENTITY`](#PG_IDENTITY)   | bool        | C/A   | 跳过PG身份参数校验          |
| 520 | [`pg_users`](#pg_users)                                         | [`PG_BUSINESS`](#PG_BUSINESS)   | user[]      | C     | 业务用户定义              |
| 521 | [`pg_databases`](#pg_databases)                                 | [`PG_BUSINESS`](#PG_BUSINESS)   | database[]  | C     | 业务数据库定义             |
| 522 | [`pg_services_extra`](#pg_services_extra)                       | [`PG_BUSINESS`](#PG_BUSINESS)   | service[]   | C     | 集群专有服务定义            |
| 523 | [`pg_hba_rules_extra`](#pg_hba_rules_extra)                     | [`PG_BUSINESS`](#PG_BUSINESS)   | rule[]      | C     | 集群/实例特定的HBA规则       |
| 524 | [`pgbouncer_hba_rules_extra`](#pgbouncer_hba_rules_extra)       | [`PG_BUSINESS`](#PG_BUSINESS)   | rule[]      | C     | Pgbounce特定HBA规则     |
| 525 | [`pg_admin_username`](#pg_admin_username)                       | [`PG_BUSINESS`](#PG_BUSINESS)   | string      | G     | PG管理用户              |
| 526 | [`pg_admin_password`](#pg_admin_password)                       | [`PG_BUSINESS`](#PG_BUSINESS)   | string      | G     | PG管理用户密码            |
| 527 | [`pg_replication_username`](#pg_replication_username)           | [`PG_BUSINESS`](#PG_BUSINESS)   | string      | G     | PG复制用户              |
| 528 | [`pg_replication_password`](#pg_replication_password)           | [`PG_BUSINESS`](#PG_BUSINESS)   | string      | G     | PG复制用户的密码           |
| 529 | [`pg_monitor_username`](#pg_monitor_username)                   | [`PG_BUSINESS`](#PG_BUSINESS)   | string      | G     | PG监控用户              |
| 530 | [`pg_monitor_password`](#pg_monitor_password)                   | [`PG_BUSINESS`](#PG_BUSINESS)   | string      | G     | PG监控用户密码            |
| 540 | [`pg_dbsu`](#pg_dbsu)                                           | [`PG_INSTALL`](#PG_INSTALL)     | string      | C     | PG操作系统超级用户          |
| 541 | [`pg_dbsu_uid`](#pg_dbsu_uid)                                   | [`PG_INSTALL`](#PG_INSTALL)     | int         | C     | 超级用户UID             |
| 542 | [`pg_dbsu_sudo`](#pg_dbsu_sudo)                                 | [`PG_INSTALL`](#PG_INSTALL)     | enum        | C     | 超级用户的Sudo权限         |
| 543 | [`pg_dbsu_home`](#pg_dbsu_home)                                 | [`PG_INSTALL`](#PG_INSTALL)     | path        | C     | 超级用户的家目录            |
| 544 | [`pg_dbsu_ssh_exchange`](#pg_dbsu_ssh_exchange)                 | [`PG_INSTALL`](#PG_INSTALL)     | bool        | C     | 是否交换超级用户密钥          |
| 545 | [`pg_version`](#pg_version)                                     | [`PG_INSTALL`](#PG_INSTALL)     | int         | C     | 安装的数据库大版本           |
| 546 | [`pgdg_repo`](#pgdg_repo)                                       | [`PG_INSTALL`](#PG_INSTALL)     | bool        | C     | 是否添加PG官方源？          |
| 547 | [`pg_add_repo`](#pg_add_repo)                                   | [`PG_INSTALL`](#PG_INSTALL)     | bool        | C     | 是否添加PG相关上游源？        |
| 548 | [`pg_bin_dir`](#pg_bin_dir)                                     | [`PG_INSTALL`](#PG_INSTALL)     | path        | C     | PG二进制目录             |
| 549 | [`pg_packages`](#pg_packages)                                   | [`PG_INSTALL`](#PG_INSTALL)     | string[]    | C     | 安装的PG软件包列表          |
| 550 | [`pg_extensions`](#pg_extensions)                               | [`PG_INSTALL`](#PG_INSTALL)     | string[]    | C     | 安装的PG插件列表           |
| 560 | [`pg_safeguard`](#pg_safeguard)                                 | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | bool        | C/A   | 彻底禁止清除存在的PG实例       |
| 561 | [`pg_clean`](#pg_clean)                                         | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | bool     | C/A   | 允许初始化时清除现存PG        |
| 562 | [`pg_data`](#pg_data)                                           | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | path        | C     | PG数据目录              |
| 563 | [`pg_fs_main`](#pg_fs_main)                                     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | path        | C     | PG主数据盘挂载点           |
| 564 | [`pg_fs_bkup`](#pg_fs_bkup)                                     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | path        | C     | PG备份盘挂载点            |
| 565 | [`pg_dummy_filesize`](#pg_dummy_filesize)                       | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | size        | C     | 占位文件/pg/dummy的大小    |
| 566 | [`pg_listen`](#pg_listen)                                       | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | ip          | C     | PG监听的IP地址           |
| 567 | [`pg_port`](#pg_port)                                           | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | int         | C     | PG监听的端口             |
| 568 | [`pg_localhost`](#pg_localhost)                                 | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | ip|path     | PG使用的UnixSocket地址   |
| 580 | [`patroni_enabled`](#patroni_enabled)                           | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | bool        | C     | Patroni是否启用         |
| 581 | [`patroni_mode`](#patroni_mode)                                 | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | enum        | C     | Patroni配置模式         |
| 201 | [`pg_dcs_type`](#pg_dcs_type)                                   | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP)  | enum       | G     | PG使用的DCS类型          |
| 582 | [`pg_namespace`](#pg_namespace)                                 | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | path        | C     | Patroni使用的DCS命名空间   |
| 583 | [`patroni_port`](#patroni_port)                                 | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | int         | C     | Patroni服务端口         |
| 584 | [`patroni_watchdog_mode`](#patroni_watchdog_mode)               | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | enum        | C     | Patroni Watchdog模式  |
| 585 | [`pg_conf`](#pg_conf)                                           | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | string      | C     | Patroni使用的配置模板      |
| 586 | [`pg_libs`](#pg_libs)                                           | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | string      | C     | PG默认加载的共享库          |
| 587 | [`pg_encoding`](#pg_encoding)                                   | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | enum        | C     | PG字符集编码             |
| 588 | [`pg_locale`](#pg_locale)                                       | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | enum        | C     | PG使用的本地化规则          |
| 589 | [`pg_lc_collate`](#pg_lc_collate)                               | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | enum        | C     | PG使用的本地化排序规则        |
| 590 | [`pg_lc_ctype`](#pg_lc_ctype)                                   | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | enum        | C     | PG使用的本地化字符集定义       |
| 591 | [`pgbouncer_enabled`](#pgbouncer_enabled)                       | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | bool        | C     | 是否启用Pgbouncer       |
| 592 | [`pgbouncer_port`](#pgbouncer_port)                             | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | int         | C     | Pgbouncer端口         |
| 593 | [`pgbouncer_poolmode`](#pgbouncer_poolmode)                     | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | enum        | C     | Pgbouncer池化模式       |
| 594 | [`pgbouncer_max_db_conn`](#pgbouncer_max_db_conn)               | [`PG_BOOTSTRAP`](#PG_BOOTSTRAP) | int         | C     | Pgbouncer最大单DB连接数   |
| 600 | [`pg_provision`](#pg_provision)                                 | [`PG_PROVISION`](#PG_PROVISION) | bool        | C     | 是否在PG集群中应用模板        |
| 601 | [`pg_init`](#pg_init)                                           | [`PG_PROVISION`](#PG_PROVISION) | string      | C     | 自定义PG初始化脚本          |
| 602 | [`pg_default_roles`](#pg_default_roles)                         | [`PG_PROVISION`](#PG_PROVISION) | role[]      | G/C   | 默认创建的角色与用户          |
| 603 | [`pg_default_privilegs`](#pg_default_privilegs)                 | [`PG_PROVISION`](#PG_PROVISION) | string[]    | G/C   | 数据库默认权限配置           |
| 604 | [`pg_default_schemas`](#pg_default_schemas)                     | [`PG_PROVISION`](#PG_PROVISION) | string[]    | G/C   | 默认创建的模式             |
| 605 | [`pg_default_extensions`](#pg_default_extensions)               | [`PG_PROVISION`](#PG_PROVISION) | extension[] | G/C   | 默认安装的扩展             |
| 606 | [`pg_reload`](#pg_reload)                                       | [`PG_PROVISION`](#PG_PROVISION) | bool        | A     | 是否重载数据库配置（HBA）      |
| 607 | [`pg_hba_rules`](#pg_hba_rules)                                 | [`PG_PROVISION`](#PG_PROVISION) | rule[]      | G/C   | 全局HBA规则             |
| 608 | [`pgbouncer_hba_rules`](#pgbouncer_hba_rules)                   | [`PG_PROVISION`](#PG_PROVISION) | rule[]      | G/C   | Pgbouncer全局HBA规则    |
| 620 | [`pg_exporter_config`](#pg_exporter_config)                     | [`PG_EXPORTER`](#PG_EXPORTER)   | string      | C     | PG指标定义文件            |
| 621 | [`pg_exporter_enabled`](#pg_exporter_enabled)                   | [`PG_EXPORTER`](#PG_EXPORTER)   | bool        | C     | 启用PG指标收集器           |
| 622 | [`pg_exporter_port`](#pg_exporter_port)                         | [`PG_EXPORTER`](#PG_EXPORTER)   | int         | C     | PG指标暴露端口            |
| 623 | [`pg_exporter_params`](#pg_exporter_params)                     | [`PG_EXPORTER`](#PG_EXPORTER)   | string      | C/I   | PG Exporter额外的URL参数 |
| 624 | [`pg_exporter_url`](#pg_exporter_url)                           | [`PG_EXPORTER`](#PG_EXPORTER)   | string      | C/I   | 采集对象数据库的连接串（覆盖）     |
| 625 | [`pg_exporter_auto_discovery`](#pg_exporter_auto_discovery)     | [`PG_EXPORTER`](#PG_EXPORTER)   | bool        | C/I   | 是否自动发现实例中的数据库       |
| 626 | [`pg_exporter_exclude_database`](#pg_exporter_exclude_database) | [`PG_EXPORTER`](#PG_EXPORTER)   | string      | C/I   | 数据库自动发现排除列表         |
| 627 | [`pg_exporter_include_database`](#pg_exporter_include_database) | [`PG_EXPORTER`](#PG_EXPORTER)   | string      | C/I   | 数据库自动发现囊括列表         |
| 628 | [`pg_exporter_options`](#pg_exporter_options)                   | [`PG_EXPORTER`](#PG_EXPORTER)   | string      | C/I   | PG Exporter命令行参数    |
| 629 | [`pgbouncer_exporter_enabled`](#pgbouncer_exporter_enabled)     | [`PG_EXPORTER`](#PG_EXPORTER)   | bool        | C     | 启用PGB指标收集器          |
| 630 | [`pgbouncer_exporter_port`](#pgbouncer_exporter_port)           | [`PG_EXPORTER`](#PG_EXPORTER)   | int         | C     | PGB指标暴露端口           |
| 631 | [`pgbouncer_exporter_url`](#pgbouncer_exporter_url)             | [`PG_EXPORTER`](#PG_EXPORTER)   | string      | C/I   | 采集对象连接池的连接串         |
| 632 | [`pgbouncer_exporter_options`](#pgbouncer_exporter_options)     | [`PG_EXPORTER`](#PG_EXPORTER)   | string      | C/I   | PGB Exporter命令行参数   |
| 640 | [`pg_services`](#pg_services)                                   | [`PG_SERVICE`](#PG_SERVICE)     | service[]   | G/C   | 全局通用服务定义            |
| 641 | [`haproxy_enabled`](#haproxy_enabled)                           | [`PG_SERVICE`](#PG_SERVICE)     | bool        | C/I   | 是否启用Haproxy         |
| 642 | [`haproxy_reload`](#haproxy_reload)                             | [`PG_SERVICE`](#PG_SERVICE)     | bool        | A     | 是否重载Haproxy配置       |
| 643 | [`haproxy_auth_enabled`](#haproxy_auth_enabled)                 | [`PG_SERVICE`](#PG_SERVICE)     | bool        | G/C   | 是否对Haproxy管理界面启用认证  |
| 644 | [`haproxy_admin_username`](#haproxy_admin_username)             | [`PG_SERVICE`](#PG_SERVICE)     | string      | G     | HAproxy管理员名称        |
| 645 | [`haproxy_admin_password`](#haproxy_admin_password)             | [`PG_SERVICE`](#PG_SERVICE)     | string      | G     | HAproxy管理员密码        |
| 646 | [`haproxy_exporter_port`](#haproxy_exporter_port)               | [`PG_SERVICE`](#PG_SERVICE)     | int         | C     | HAproxy指标暴露器端口      |
| 647 | [`haproxy_client_timeout`](#haproxy_client_timeout)             | [`PG_SERVICE`](#PG_SERVICE)     | interval    | C     | HAproxy客户端超时        |
| 648 | [`haproxy_server_timeout`](#haproxy_server_timeout)             | [`PG_SERVICE`](#PG_SERVICE)     | interval    | C     | HAproxy服务端超时        |
| 649 | [`vip_mode`](#vip_mode)                                         | [`PG_SERVICE`](#PG_SERVICE)     | enum        | C     | VIP模式：none          |
| 650 | [`vip_reload`](#vip_reload)                                     | [`PG_SERVICE`](#PG_SERVICE)     | bool        | A     | 是否重载VIP配置           |
| 651 | [`vip_address`](#vip_address)                                   | [`PG_SERVICE`](#PG_SERVICE)     | string      | C     | 集群使用的VIP地址          |
| 652 | [`vip_cidrmask`](#vip_cidrmask)                                 | [`PG_SERVICE`](#PG_SERVICE)     | int         | C     | VIP地址的网络CIDR掩码长度    |
| 653 | [`vip_interface`](#vip_interface)                               | [`PG_SERVICE`](#PG_SERVICE)     | string      | C     | VIP使用的网卡            |
| 654 | [`dns_mode`](#dns_mode)                                         | [`PG_SERVICE`](#PG_SERVICE)     | enum        | C     | DNS配置模式             |
| 655 | [`dns_selector`](#dns_selector)                                 | [`PG_SERVICE`](#PG_SERVICE)     | string      | C     | DNS解析对象选择器          |


----------------
## `PG_IDENTITY`


[`pg_cluster`](#pg_cluster)，[`pg_role`](#pg_role)，[`pg_seq`](#pg_seq) 属于 **身份参数** 。

除IP地址外，这三个参数是定义一套新的数据库集群的最小必须参数集，一个典型案例如下所示。

```yaml
pg-test:
  hosts:
    10.10.10.11: {pg_seq: 1, pg_role: replica}
    10.10.10.12: {pg_seq: 2, pg_role: primary}
    10.10.10.13: {pg_seq: 3, pg_role: replica}
  vars:
    pg_cluster: pg-test
```

其他参数都可以继承自全局配置或默认配置，但身份参数必须**显式指定**，**手工分配**，目前PGSQL身份参数如下：

|            名称             |   类型   | 层级  | 说明                            |
|:-------------------------:| :------: | :---: | ------------------------------- |
| [`pg_cluster`](#pg_cluster) | `string` | **C** | **PG数据库集群名称**            |
|     [`pg_seq`](#pg_seq)     | `number` | **I** | **PG数据库实例序号**            |
|    [`pg_role`](#pg_role)    |  `enum`  | **I** | **PG数据库实例角色**            |
|   [`pg_shard`](#pg_shard)   | `string` | **C** | **PG数据库分片集簇名** （占位） |
|  [`pg_sindex`](#pg_sindex)  | `number` | **C** | **PG数据库分片集簇号** （占位） |

* [`pg_cluster`](#pg_cluster) 标识了集群的名称，在集群层面进行配置。
* [`pg_role`](#pg_role) 在实例层面进行配置，标识了实例的角色，只有`primary`角色会进行特殊处理，如果不填，默认为`replica`角色，此外，还有特殊的`delayed`与`offline`角色。
* [`pg_seq` ](#pg_seq)用于在集群内标识实例，通常采用从0或1开始递增的整数，一旦分配不再更改。
* `{{ pg_cluster }}-{{ pg_seq }}` 被用于唯一标识实例，即`pg_instance`
* `{{ pg_cluster }}-{{ pg_role }}` 用于标识集群内的服务，即`pg_service`
* [`pg_shard`](#pg_shard) 与 [`pg_sindex`](#pg_sindex) 用于水平分片集群，为Citus与Greenplum多集群管理预留。





### `pg_cluster`

PG数据库集群名称，类型：`string`，层级：集群，没有默认值。**必选参数，必须由用户提供**。

集群名将用作集群内资源的命名空间，命名需要遵循特定命名规则：`[a-z][a-z0-9-]*`，以兼容不同约束对身份标识的要求。




### `pg_shard`

PG集群所属的Shard (保留), 类型：`string`，层级：集群，没有默认值，可选参数。

只有分片集群需要设置此参数。当多个数据库集群以水平分片的方式共同服务于同一个 业务时，Pigsty将这一组集群称为 **分片集簇（Sharding Cluster）** 。
`pg_shard`是数据库集群所属分片集簇的名称，一个分片集簇可以指定任意名称，但Pigsty建议采用具有意义的命名规则。

例如参与分片集簇的集群，可以使用 分片集簇名 [`pg_shard`](#pg_shard) + `shard` + 集群所属分片编号[`pg_sindex`](#pg_sindex)构成集群名称：

```
shard:  test
pg-testshard1
pg-testshard2
pg-testshard3
pg-testshard4
```




### `pg_sindex`

PG集群的分片号 (保留), 类型：`int`，层级：C，无默认值。

集群在分片集簇中的编号，与 [pg_shard](#pg_shard) 配合使用通常从0或1开始依次分配。只有分片集群需要设置此参数。




### `gp_role`

当前PG集群在GP中的角色, 类型：`enum`，层级：C，默认值为：

Greenplum/MatrixDB 专用，用于指定GP部署中，此PG集群扮演的角色，可选值为： 
* `master` ： 协调者节点
* `segment` ： 数据节点

为**身份参数**，**集群级参数**，当部署GPSQL时为**必选参数**。



### `pg_role`

PG数据库实例角色, 类型：`enum`，层级：I，无默认值，**必选参数，必须由用户提供**。

数据库实例的角色，默认角色包括：`primary`, `replica`, `offline`

* `primary`: 集群主库，集群中必须有一个且只能有一个成员为`primary`
* `replica`: 集群从库，用于承担在线只读流量。
* `offline`: 集群离线从库，用于承担离线只读流量，例如统计分析/ETL/个人查询等。

**身份参数，必填参数，实例级参数**



### `pg_seq`

PG数据库实例序号, 类型：`int`，层级：I，无默认值，**必选参数，必须由用户提供**。

数据库实例的序号，在**集群内部唯一**，用于区别与标识集群内的不同实例，从0或1开始分配。



### `pg_instances`

当前节点上的所有PG实例, 类型：`{port:ins}`，层级：I，默认值为：

当节点上部署由超过一个PG实例时，例如Greenplum的Segments，或使用[仅监控模式](d-monly.md)监管已有实例，可使用此参数描述。
[`pg_instances`](#pg_instances) 是一个对象数组，键为实例端口，值为一个字典，内容可以是任意[`PGSQL`](v-pgsql.md)板块的参数，详情请参考 [MatrixDB部署](d-matrixdb.md)





### `pg_upstream`

实例的复制上游节点, 类型：`string`，层级：I，默认值为空。

实例级配置项，内容为IP地址或主机名，用于指明流复制上游节点。

* 当为集群的从库配置该参数时，填入的IP地址必须为集群内的其他节点。实例会从该节点进行流复制，此选项可用于构建**级连复制**。

* 当为集群的主库配置该参数时，意味着整个集群将以 **备集群**（Standby Cluster） 的形式运行，从上游节点接受变更。集群中的`primary`将扮演`standby leader` 的角色。

灵活使用此参数的能力，可以搭建异地灾备的集群，完成分片集群的分裂，实现延时从库。



### `pg_offline_query`

是否允许离线查询, 类型：`bool`，层级：I，默认值为：`false`

设置为`true`时，无论当前实例的角色为何，用户组`dbrole_offline`都可以连接至该实例并执行离线查询。

对于实例数量较少（例如一主一从）的情况较为实用，用户可以将唯一的从库标记为`pg_offline_query = true`，从而接受ETL，慢查询与交互式访问。



### `pg_backup`

是否在实例上存储冷备份, 类型：`bool`，层级：I，默认值为：`false`

未实现，保留标记位，带有该标记的实例节点会用于存储基础冷备份。



### `pg_weight`

实例在负载均衡中的相对权重, 类型：`int`，层级：I，默认值为：`100`

当您希望调整实例在服务中的相对权重时，可在实例层次修改此参数，并按 [SOP：集群流量调整](r-sop.md) 中介绍的方法应用生效。



### `pg_hostname`

将PG实例名称设为HOSTNAME, 类型：`bool`，层级：C/I，默认值为：`false`，在Demo中默认为真。

是否在初始化节点时，将PostgreSQL的实例名与集群名一并用作节点的名称与集群名，默认禁用。

当采用 节点:PG 1:1 独占部署模式时，您可以将PG实例的身份赋予节点，保持节点与PG的监控身份一致。



### `pg_preflight_skip`

跳过PG身份参数校验, 类型：`bool`，层级：C/A，默认值为：`false`

如果您不希望初始化新的数据库集群（例如与已有实例打交道时），则可以通过此参数完整跳过Patroni与Postgres初始化的任务。





----------------
## `PG_BUSINESS`

用户需**重点关注**此部分参数，因为这里是业务声明自己所需数据库对象的地方。

定制集群模板：用户，数据库，服务，权限规则。

* 业务用户定义： [`pg_users`](#pg_users)                                   
* 业务数据库定义： [`pg_databases`](#pg_databases)                           
* 集群专有服务定义： [`pg_services_extra`](#pg_services_extra)                 
* 集群/实例特定的HBA规则： [`pg_hba_rules_extra`](#pg_hba_rules_extra)               
* Pgbounce特定HBA规则： [`pgbouncer_hba_rules_extra`](#pgbouncer_hba_rules_extra) 

特殊的数据库用户，强烈建议在生产环境中修改这些用户的密码。

* PG管理员用户：[`pg_admin_username`](#pg_admin_username) / [`pg_admin_password`](#pg_admin_password)
* PG复制用户： [`pg_replication_username`](#pg_replication_username) / [`pg_replication_password`](#pg_replication_password)
* PG监控用户：[`pg_monitor_username`](#pg_monitor_username) / [`pg_monitor_password`](#pg_monitor_password)




### `pg_users`

业务用户定义, 类型：`user[]`，层级：C，默认值为空数组。

用于在数据库集群层面定义业务用户，数组中的每一个对象定义了一个[用户或角色](c-pgdbuser#用户)，一个完整的用户定义如下：

```yaml
pg_users:                           # define business users/roles on this cluster, array of user definition
  # define admin user for meta database (This user are used for pigsty app deployment by default)
  - name: dbuser_meta               # required, `name` is the only mandatory field of a user definition
    password: md5d3d10d8cad606308bdb180148bf663e1  # md5 salted password of 'DBUser.Meta'
    # optional, plain text and md5 password are both acceptable (prefixed with `md5`)
    login: true                     # optional, can login, true by default  (new biz ROLE should be false)
    superuser: false                # optional, is superuser? false by default
    createdb: false                 # optional, can create database? false by default
    createrole: false               # optional, can create role? false by default
    inherit: true                   # optional, can this role use inherited privileges? true by default
    replication: false              # optional, can this role do replication? false by default
    bypassrls: false                # optional, can this role bypass row level security? false by default
    pgbouncer: true                 # optional, add this user to pgbouncer user-list? false by default (production user should be true explicitly)
    connlimit: -1                   # optional, user connection limit, default -1 disable limit
    expire_in: 3650                 # optional, now + n days when this role is expired (OVERWRITE expire_at)
    expire_at: '2030-12-31'         # optional, YYYY-MM-DD 'timestamp' when this role is expired  (OVERWRITTEN by expire_in)
    comment: pigsty admin user      # optional, comment string for this user/role
    roles: [dbrole_admin]           # optional, belonged roles. default roles are: dbrole_{admin,readonly,readwrite,offline}
    parameters:                     # optional, role level parameters with `ALTER ROLE SET`
      log_min_duration_statements: 1000                  
    search_path: public         # key value config parameters according to postgresql documentation (e.g: use pigsty as default search_path)
  - {name: dbuser_view , password: DBUser.Viewer  ,pgbouncer: true ,roles: [dbrole_readonly], comment: read-only viewer for meta database}

  # define additional business users for prometheus & grafana (optional)
  - {name: dbuser_grafana    , password: DBUser.Grafana    ,pgbouncer: true ,roles: [dbrole_admin], comment: admin user for grafana database }
  - {name: dbuser_prometheus , password: DBUser.Prometheus ,pgbouncer: true ,roles: [dbrole_admin], comment: admin user for prometheus database }
```

* 每一个用户或角色必须指定 `name` ，其余字段均为**可选项**，`name`必须在此列表中唯一。
* `password`是可选项，如果留空则不设置密码，可以使用MD5密文密码。
* `login`, `superuser`, `createdb`, `createrole`, `inherit`, `replication`, `bypassrls` 都是布尔类型，用于设置用户属性。如果不设置，则采用系统默认值。
* 用户通过`CREATE USER`创建，所以默认具有`login`属性，如果创建的是角色，需要指定`login: false`。
* `expire_at`与`expire_in`用于控制用户过期时间，`expire_at`使用形如`YYYY-mm-DD`的日期时间戳。`expire_in`使用从现在开始的过期天数，如果`expire_in`存在则会覆盖`expire_at`选项。
* 新用户默认**不会**添加至Pgbouncer用户列表中，必须显式定义`pgbouncer: true`，该用户才会被加入到Pgbouncer用户列表。
* 用户/角色会按顺序创建，后面定义的用户可以属于前面定义的角色。
* 用户可以通过`roles`字段为业务用户添加[默认权限]()组：
    * `dbrole_readonly`：默认生产只读用户，具有全局只读权限。（只读生产访问）
    * `dbrole_offline`：默认离线只读用户，在特定实例上具有只读权限。（离线查询，个人账号，ETL）
    * `dbrole_readwrite`：默认生产读写用户，具有全局CRUD权限。（常规生产使用）
    * `dbrole_admin`：默认生产管理用户，具有执行DDL变更的权限。（管理员）

应当为生产账号配置 `pgbouncer: true`，允许其通过连接池访问，普通用户不应当通过连接池访问数据库。





### `pg_databases`

业务数据库定义, 类型：`database[]`，层级：C，默认值为空数组。

用于在数据库集群层面定义业务用户，数组中的每一个对象定义了一个[业务数据库](c-pgdbuser#数据库)，一个完整的数据库定义如下：

```yaml
pg_databases:                       # define business databases on this cluster, array of database definition
  # define the default `meta` database
  - name: meta                      # required, `name` is the only mandatory field of a database definition
    baseline: cmdb.sql              # optional, database sql baseline path, (relative path among ansible search path, e.g files/)
    owner: postgres                 # optional, database owner, postgres by default
    template: template1             # optional, which template to use, template1 by default
    encoding: UTF8                  # optional, database encoding, UTF8 by default. (MUST same as template database)
    locale: C                       # optional, database locale, C by default.  (MUST same as template database)
    lc_collate: C                   # optional, database collate, C by default. (MUST same as template database)
    lc_ctype: C                     # optional, database ctype, C by default.   (MUST same as template database)
    tablespace: pg_default          # optional, default tablespace, 'pg_default' by default.
    allowconn: true                 # optional, allow connection, true by default. false will disable connect at all
    revokeconn: false               # optional, revoke public connection privilege. false by default. (leave connect with grant option to owner)
    pgbouncer: true                 # optional, add this database to pgbouncer database list? true by default
    comment: pigsty meta database   # optional, comment string for this database
    connlimit: -1                   # optional, database connection limit, default -1 disable limit
    schemas: [pigsty]               # optional, additional schemas to be created, array of schema names
    extensions:                     # optional, additional extensions to be installed: array of schema definition `{name,schema}`
      - {name: adminpack, schema: pg_catalog}    # install adminpack to pg_catalog and install postgis to public
      - {name: postgis, schema: public}          # if schema is omitted, extension will be installed according to search_path.

```

每个数据库定义中，数据库名称 `name` 为必选项，其余均为可选项。

* `name`：数据库名称，**必选项**。
* `owner`：数据库属主，默认为`postgres`
* `template`：数据库创建时使用的模板，默认为`template1`
* `encoding`：数据库默认字符编码，默认为`UTF8`，默认与实例保持一致。建议不要配置与修改。
* `locale`：数据库默认的本地化规则，默认为`C`，建议不要配置，与实例保持一致。
* `lc_collate`：数据库默认的本地化字符串排序规则，默认与实例设置相同，建议不要修改，必须与模板数据库一致。强烈建议不要配置，或配置为`C`。
* `lc_ctype`：数据库默认的LOCALE，默认与实例设置相同，建议不要修改或设置，必须与模板数据库一致。建议配置为C或`en_US.UTF8`。
* `allowconn`：是否允许连接至数据库，默认为`true`，不建议修改。
* `revokeconn`：是否回收连接至数据库的权限？默认为`false`。如果为`true`，则数据库上的`PUBLIC CONNECT`权限会被回收。只有默认用户（`dbsu|monitor|admin|replicator|owner`）可以连接。此外，`admin|owner` 会拥有GRANT OPTION，可以赋予其他用户连接权限。
* `tablespace`：数据库关联的表空间，默认为`pg_default`。
* `connlimit`：数据库连接数限制，默认为`-1`，即没有限制。
* `extensions`：对象数组 ，每一个对象定义了一个数据库中的**扩展**，以及其安装的**模式**。
* `parameters`：KV对象，每一个KV定义了一个需要针对数据库通过`ALTER DATABASE`修改的参数。
* `pgbouncer`：布尔选项，是否将该数据库加入到Pgbouncer中。所有数据库都会加入至Pgbouncer，除非显式指定`pgbouncer: false`。
* `comment`：数据库备注信息。






### `pg_services_extra`

集群专有服务定义, 类型：`service[]`，层级：C，默认值为：

用于在数据库集群层面定义额外的服务，数组中的每一个对象定义了一个[服务](c-service#服务)，一个完整的服务定义如下：

```yaml
- name: default           # service's actual name is {{ pg_cluster }}-{{ service.name }}
  src_ip: "*"             # service bind ip address, * for all, vip for cluster virtual ip address
  src_port: 5436          # bind port, mandatory
  dst_port: postgres      # target port: postgres|pgbouncer|port_number , pgbouncer(6432) by default
  check_method: http      # health check method: only http is available for now
  check_port: patroni     # health check port:  patroni|pg_exporter|port_number , patroni by default
  check_url: /primary     # health check url path, / as default
  check_code: 200         # health check http code, 200 as default
  selector: "[]"          # instance selector
  haproxy:                # haproxy specific fields
    maxconn: 3000         # default front-end connection
    balance: roundrobin   # load balance algorithm (roundrobin by default)
    default_server_options: 'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'

```

每一个集群都可以定义多个服务，每个服务包含任意数量的集群成员，服务通过**端口**进行区分，`name`与`src_port`为必选项，且必须在数组内唯一。

**必选项目**

* **名称（`service.name`）**：

  **服务名称**，服务的完整名称以数据库集群名为前缀，以`service.name`为后缀，通过`-`连接。例如在`pg-test`集群中`name=primary`的服务，其完整服务名称为`pg-test-primary`。

* **端口（`service.port`）**：

  在Pigsty中，服务默认采用NodePort的形式对外暴露，因此暴露端口为必选项。但如果使用外部负载均衡服务接入方案，您也可以通过其他的方式区分服务。

* **选择器（`service.selector`）**：

  **选择器**指定了服务的实例成员，采用JMESPath的形式，从所有集群实例成员中筛选变量。默认的`[]`选择器会选取所有的集群成员。


**可选项目**

* **备份选择器（`service.selector`）**：

  可选的 **备份选择器**`service.selector_backup`会选择或标记用于服务备份的实例列表，即集群中所有其他成员失效时，备份实例才接管服务。例如可以将`primary`实例加入`replica`服务的备选集中，当所有从库失效后主库依然可以承载集群的只读流量。

* **源端IP（`service.src_ip`）** ：

  表示**服务**对外使用的IP地址，默认为`*`，即本机所有IP地址。使用`vip`则会使用`vip_address`变量取值，或者也可以填入网卡支持的特定IP地址。

* **宿端口（`service.dst_port`）**：

  服务的流量将指向目标实例上的哪个端口？`postgres` 会指向数据库监听的端口，`pgbouncer`会指向连接池所监听的端口，也可以填入固定的端口号。

* **健康检查方式（`service.check_method`）**:

  服务如何检查实例的健康状态？目前仅支持HTTP

* **健康检查端口（`service.check_port`）**:

  服务检查实例的哪个端口获取实例的健康状态？ `patroni`会从Patroni（默认8008）获取，`pg_exporter`会从PG Exporter（默认9630）获取，用户也可以填入自定义的端口号。

* **健康检查路径（`service.check_url`）**:

  服务执行HTTP检查时，使用的URL PATH。默认会使用`/`作为健康检查，PG Exporter与Patroni提供了多样的健康检查方式，可以用于主从流量区分。例如，`/primary`仅会对主库返回成功，`/replica`仅会对从库返回成功。`/read-only`则会对任何支持只读的实例（包括主库）返回成功。

* **健康检查代码（`service.check_code`）**:

  HTTP健康检查所期待的代码，默认为200

* **Haproxy特定配置（`service.haproxy`）** ：

  关于服务供应软件（HAproxy）的专有配置项

  * `<service>.haproxy`

  这些参数现在[**服务**](c-service.md#服务)中定义，使用`service.haproxy`来覆盖实例的参数配置。

  * `maxconn`

  HAProxy最大前后端连接数，默认为3000

  * `balance`

  haproxy负载均衡所使用的算法，可选策略为`roundrobin`与`leastconn`，默认为`roundrobin`

  * `default_server_options`

  Haproxy 后端服务器实例的默认选项

  默认为： `'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'`








### `pg_hba_rules_extra`

集群/实例特定的HBA规则, 类型：`rule[]`，层级：C，默认值为：

设置数据库的客户端IP黑白名单规则。对象数组，每一个对象都代表一条规则，每一条规则由三部分组成：

* `title`，规则标题，会转换为HBA文件中的注释
* `role`，应用角色，`common`代表应用至所有实例，其他取值（如`replica`, `offline`）则仅会安装至匹配的角色上。例如`role='replica'`代表这条规则只会应用到`pg_role == 'replica'` 的实例上。
* `rules`，字符串数组，每一条记录代表一条最终写入`pg_hba.conf`的规则。

作为一个特例，`role == 'offline'` 的HBA规则，还会额外安装至 `pg_offline_query == true` 的实例上。

[`pg_hba_rules`](#pg_hba_rules) 与之类似，但通常用于全局统一的HBA规则设置，[`pg_hba_rules_extra`](#pg_hba_rules_extra) 会以同样的方式 **追加** 至`pg_hba.conf`中。

如果用户需要彻底**覆写**集群的HBA规则，即不想继承全局HBA配置，则应当在集群层面配置  [`pg_hba_rules`](#pg_hba_rules) 并覆盖全局配置。





### `pgbouncer_hba_rules_extra`

Pgbounce特定HBA规则, 类型：`rule[]`，层级：C，默认值为空数组。

与 [`pg_hba_rules_extra`](#pg_hba_rules_extra)类似，用于在集群层次对Pgbouncer的HBA规则进行额外配置。







### `pg_admin_username`

PG管理用户, 类型：`string`，层级：G，默认值为：`"dbuser_dba"`

用于执行PostgreSQL数据库管理任务（DDL变更）的数据库用户名，默认带有超级用户权限。



### `pg_admin_password`

PG管理用户密码, 类型：`string`，层级：G，默认值为：`"DBUser.DBA"`

用于执行PostgreSQL数据库管理任务（DDL变更）的数据库用户密码，必须使用明文，默认为`DBUser.DBA`，强烈建议修改！

在生产环境部署时，强烈建议修改此参数！



### `pg_replication_username`

PG复制用户, 类型：`string`，层级：G，默认值为：`"replicator"`

用于执行PostgreSQL流复制，建议在全局保持一致。



### `pg_replication_password`

PG复制用户的密码, 类型：`string`，层级：G，默认值为：`"DBUser.Replicator"`

用于执行PostgreSQL流复制的数据库用户密码，必须使用明文。默认为`DBUser.Replicator`。

在生产环境部署时，强烈建议修改此参数！



### `pg_monitor_username`

PG监控用户, 类型：`string`，层级：G，默认值为：`"dbuser_monitor"`

用于执行PostgreSQL与Pgbouncer监控任务的数据库用户名



### `pg_monitor_password`

PG监控用户密码, 类型：`string`，层级：G，默认值为：`"DBUser.Monitor"`

用于执行PostgreSQL与Pgbouncer监控任务的数据库用户密码，必须使用明文。

在生产环境部署时，强烈建议修改此参数。





----------------
## `PG_INSTALL`

PG Install 部分负责在一台装有基本软件的机器上完成所有PostgreSQL依赖项的安装。用户可以配置数据库超级用户的名称、ID、权限、访问，配置安装所用的源，配置安装地址，安装的版本，所需的软件包与扩展插件。

这里的大多数参数只需要在整体升级数据库大版本时修改，用户可以通过 [`pg_version`](#pg_version)指定需要安装的软件版本，并在集群层面进行覆盖，为不同的集群安装不同的数据库版本。





### `pg_dbsu`

PG操作系统超级用户, 类型：`string`，层级：C，默认值为：`"postgres"`

数据库默认使用的操作系统用户（超级用户）的用户名称，默认为`postgres`，通常不建议修改。
当安装 Greenplum / MatrixDB 时，建议修改本参数为对应推荐值：`gpadmin|mxadmin`。




### `pg_dbsu_uid`

超级用户UID, 类型：`int`，层级：C，默认值为：`26`

数据库默认使用的操作系统用户（超级用户）的UID。默认值为`26`，与CentOS下PostgreSQL官方RPM包配置一致，不建议修改。




### `pg_dbsu_sudo`

超级用户的Sudo权限, 类型：`enum`，层级：C，默认值为：`"limit"`

* `none`：没有sudo权限
* `limit`：有限的sudo权限，可以执行数据库相关组件的systemctl命令，默认
* `all`：带有完整`sudo`权限，但需要密码。
* `nopass`：不需要密码的完整`sudo`权限（不建议）

数据库超级用户 [`pg_dbsu`](#pg_dbsu) 的默认权限为受限的`sudo`权限：`limit`。




### `pg_dbsu_home`

超级用户的家目录, 类型：`path`，层级：C，默认值为：`"/var/lib/pgsql"`

数据库超级用户[`pg_dbsu`](#pg_dbsu)的家目录，默认为`/var/lib/pgsql`



### `pg_dbsu_ssh_exchange`

是否交换超级用户密钥, 类型：`bool`，层级：C，默认值为：`true`

是否在执行的机器之间交换 [`pg_dbsu`](#pg_dbsu) 的SSH公私钥。



### `pg_version`

安装的数据库大版本, 类型：`int`，层级：C，默认值为：`14`

当前实例安装的PostgreSQL大版本号，默认为14，最低支持至10。

请注意，PostgreSQL的物理流复制无法跨越大版本，请在全局/集群层面配置此变量，确保整个集群内所有实例都有着相同的大版本号。



### `pgdg_repo`

是否添加PG官方源？, 类型：`bool`，层级：C，默认值为：`false`

标记，是否使用PostgreSQL官方源？默认不使用。使用该选项，可以在没有本地源的情况下，直接从互联网官方源下载安装PostgreSQL相关软件包。




### `pg_add_repo`

是否添加PG相关上游源？, 类型：`bool`，层级：C，默认值为：`false`

如果使用，则会在安装PostgreSQL前添加PGDG的官方源。




### `pg_bin_dir`

PG二进制目录, 类型：`path`，层级：C，默认值为：`"/usr/pgsql/bin"`

默认为`/usr/pgsql/bin/`，这是一个安装过程中手动创建的软连接，指向安装的具体Postgres版本目录。

例如`/usr/pgsql -> /usr/pgsql-14`。详情请参考 [FHS](r-fhs.md)



### `pg_packages`

安装的PG软件包列表, 类型：`string[]`，层级：C，默认值为：

```yaml
- postgresql${pg_version}*
- postgis32_${pg_version}*
- citus_${pg_version}*
- timescaledb-2-postgresql-${pg_version}
- pgbouncer pg_exporter pgbadger pg_activity node_exporter consul haproxy vip-manager
- patroni patroni-consul patroni-etcd python3 python3-psycopg2 python36-requests python3-etcd
- python3-consul python36-urllib3 python36-idna python36-pyOpenSSL python36-cryptography
```

软件包中的`${pg_version}`会被替换为实际安装的PostgreSQL版本 [`pg_version`](#pg_version)。

当您为某一个特定集群指定特殊的 [`pg_version`](#pg_version) 时，可以相应在集群层面调整此参数（例如安装PG14 beta时某些扩展还不存在）





### `pg_extensions`

安装的PG插件列表, 类型：`string[]`，层级：C，默认值为：

```yaml
pg_repack_${pg_version}
pg_qualstats_${pg_version}
pg_stat_kcache_${pg_version}
pg_stat_monitor_${pg_version}
wal2json_${pg_version}"
```

软件包中的`${pg_version}`会被替换为实际安装的PostgreSQL大版本号 [`pg_version`](#pg_version)。





----------------
## `PG_BOOTSTRAP`

在一台安装完Postgres的机器上，创建并拉起一套数据库。

* **集群身份定义**，清理现有实例，创建目录结构，拷贝工具与脚本，配置环境变量
* 渲染Patroni模板配置文件，使用Patroni拉起主库，使用Patroni拉起从库
* 配置Pgbouncer，初始化业务用户与数据库，将数据库与数据源服务注册至DCS。

通过 [`pg_conf`](#pg_conf) 可以使用默认的数据库集群模板（普通事务型 OLTP/普通分析型 OLAP/核心金融型 CRIT/微型虚机 TINY）。如果希望创建自定义的模板，可以在`roles/postgres/templates`中克隆默认配置并自行修改后采用，详情请参考：[定制PGSQL集群](v-pgsql-customize.md) 。



### `pg_safeguard`

安全保险，禁止清除存在的PostgreSQL实例, 类型：`bool`，层级：C/A，默认值为：`false`

如果为`true`，任何情况下，Pigsty剧本都不会移除运行中的PostgreSQL实例，包括 [`pgsql-remove.yml`](p-pgsql.md#pgsql-remove)。

详情请参考 [保护机制](p-pgsql.md#保护机制)。



### `pg_clean`

是否抹除运行中的PostgreSQL实例？类型：`bool`，层级：C/A，默认值为：`false`。

针对 [`pgsql.yml`](p-pgsql.md#pgsql) 剧本的抹除豁免，如果指定该参数为真，那么在 [`pgsql.yml`](p-pgsql.md#pgsql) 剧本执行时，会自动抹除已有的PostgreSQL实例

这是一个危险的操作，因此必须显式指定。

当安全保险参数 [`pg_safeguard`](#pg_safeguard) 打开时，本参数无效。



### `pg_data`

PostgreSQL数据目录, 类型：`path`，层级：C，默认值为：`"/pg/data"`，不建议更改。





### `pg_fs_main`

PostgreSQL主数据盘挂载点, 类型：`path`，层级：C，默认值为：`"/data"`

主数据盘目录，默认为`/data`，Pigsty的默认[目录结构](r-fhs)假设系统中存在一个主数据盘挂载点，用于盛放数据库目录与其他状态。



### `pg_fs_bkup`

PostgreSQL备份盘挂载点, 类型：`path`，层级：C，默认值为：`"/data/backups"`

Pigsty的默认[目录结构](r-fhs)假设系统中存在一个备份数据盘挂载点，用于盛放备份与归档数据。备份盘并不是必选项，如果系统中不存在备份盘，用户也可以指定一个主数据盘上的子目录作为备份盘根目录挂载点。



### `pg_dummy_filesize`

占位文件`/pg/dummy`的大小, 类型：`size`，层级：C，默认值为：`"64MiB"`

占位文件是一个预分配的空文件，占据一定量的磁盘空间。当出现磁盘满故障时，移除该占位文件可以紧急释放一些磁盘空间应急使用，生产环境建议使用`4GiB`，`8GiB`。



### `pg_listen`

PG监听的IP地址, 类型：`ip`，层级：C，默认值为：`"0.0.0.0"`

数据库监听的IP地址，默认为所有IPv4地址`0.0.0.0`，如果要包括所有IPv6地址，可以使用`*`。



### `pg_port`

PG监听的端口, 类型：`int`，层级：C，默认值为：`5432`，不建议修改。




### `pg_localhost`

PG使用的UnixSocket地址, 类型：`ip|path`，层级：C，默认值为：`"/var/run/postgresql"`

Unix Socket目录用于盛放PostgreSQL与Pgbouncer的Unix socket文件，当客户端未指定IP地址访问数据库时，会通过本地Unix Socket访问，默认为`/var/run/postgresql`。



### `patroni_enabled`

Patroni是否启用, 类型：`bool`，层级：C，默认值为：`true`

布尔类型，标记位，默认为真，是否启用 Patroni （与Postgres）？如果为假，那么Pigsty将直接跳过Patroni与Postgres拉起的流程。该选项通常在接入已有实例时使用。



### `patroni_mode`

Patroni配置模式, 类型：`enum`，层级：C，默认值为：`"default"`

* `default`: 正常启用Patroni，并进入高可用自动切换模式。
* `pause`: 启用Patroni，但在完成初始化后自动进入维护模式（不自动执行主从切换）
* `remove`: 依然使用Patroni初始化集群，但初始化完成后移除Patroni



### `pg_dcs_type`

PG高可用使用的DCS类型, 类型: `enum`， 层级: G， 默认值为: `"consul"`.

有两种可用的DCS类型：`consul` 与 `etcd`，默认为Consul，对应的DCS类型[`consul_enabled`](v-infra.md#consul_enabled) 或 [`etcd_enabled`](v-infra.md#etcd_enabled) 需要在Pigsty全局配置启用。



### `pg_namespace`

Patroni使用的DCS命名空间, 类型：`path`，层级：C，默认值为：`"/pg"`




### `patroni_port`

Patroni服务端口, 类型：`int`，层级：C，默认值为：`8008`

Patroni API服务器默认监听并对外暴露服务与健康检查的端口。




### `patroni_watchdog_mode`

Patroni Watchdog模式, 类型：`enum`，层级：C，默认值为：`"automatic"`

当发生主从切换时，Patroni会尝试在提升从库前关闭主库。如果指定超时时间内主库仍未成功关闭，Patroni会根据配置使用Linux内核模块`softdog`进行fencing关机。

* `off`：不使用`watchdog`
* `automatic`：如果内核启用了`softdog`，则启用`watchdog`，不强制，默认行为。
* `required`：强制使用`watchdog`，如果系统未启用`softdog`则拒绝启动。

启用Watchdog意味着系统会优先确保数据一致性，而放弃可用性，如果您的系统更重视可用性，则可以关闭Watchdog，建议关闭元节点上的Watchdog。




### `pg_conf`

Patroni使用的配置模板, 类型：`string`，层级：C，默认值为：`"tiny.yml"`

拉起Postgres集群所用的[Patroni模板](v-pgsql-customize.md)。Pigsty预制了4种模板

* [`oltp.yml`](#oltp) 常规OLTP模板，默认配置
* [`olap.yml`](#olap) OLAP模板，提高并行度，针对吞吐量优化，针对长时间运行的查询进行优化。
* [`crit.yml`](#crit)) 核心业务模板，基于OLTP模板针对安全性，数据完整性进行优化，采用同步复制，强制启用数据校验和。
* [`tiny.yml`](#tiny) 微型数据库模板，针对低资源场景进行优化，例如运行于虚拟机中的演示数据库集群。




### `pg_libs`

PG默认加载的共享库, 类型：`string`，层级：C，默认值为：`"timescaledb, pg_stat_statements, auto_explain"`

填入Patroni模板中`shared_preload_libraries`参数的字符串，控制PG启动预加载的动态库。在当前版本中，默认会加载以下库：`timescaledb, pg_stat_statements, auto_explain`

如果您希望默认启用Citus支持，则需要修改该参数，将 `citus` 添加至首位：`citus, timescaledb, pg_stat_statements, auto_explain`





### `pg_encoding`

PG字符集编码, 类型：`enum`，层级：C，默认值为：`"UTF8"`。如无特殊需求，不建议修改此参数。



### `pg_locale`

PG使用的本地化规则, 类型：`enum`，层级：C，默认值为：`"C"`

如无特殊需求，不建议修改此参数，不当的排序规则可能对数据库性能产生显著影响。




### `pg_lc_collate`

PG使用的本地化排序规则, 类型：`enum`，层级：C，默认值为：`"C"`

默认为`C`，如无特殊需求，，**强烈不建议**修改此参数。用户总是可以通过`COLLATE`表达式实现本地化排序相关功能，错误的本地化排序规则可能导致某些操作产生成倍的性能损失，请在真的有本地化需求的情况下修改此参数。



### `pg_lc_ctype`

PG使用的本地化字符集定义, 类型：`enum`，层级：C，默认值为：`"en_US.UTF8"`

默认为`en_US.UTF8`，因为一些PG扩展（`pg_trgm`）需要额外的字符分类定义才可以针对国际化字符正常工作，因此Pigsty默认会使用`en_US.UTF8`字符集定义，不建议修改此参数。



### `pgbouncer_enabled`

是否启用Pgbouncer, 类型：`bool`，层级：C，默认值为：`true`




### `pgbouncer_port`

Pgbouncer端口, 类型：`int`，层级：C，默认值为：`6432`




### `pgbouncer_poolmode`

Pgbouncer池化模式, 类型：`enum`，层级：C，默认值为：`"transaction"`

* `transaction`，事务级连接池，默认，性能好，但影响 PreparedStatements 与其他一些会话级功能的使用。
* `session`，会话级连接池，兼容性最强。
* `statements`，语句级连接池，若您的查询均为点查，可以考虑使用此模式。



### `pgbouncer_max_db_conn`

Pgbouncer最大单DB连接数, 类型：`int`，层级：C，默认值为：`100`

允许连接池与单个数据库之间建立的最大连接数，默认值为`100`

使用Transaction Pooling模式时，活跃服务端连接数通常处于个位数。如果采用Session Pooling模式，可以适当增大此参数。





----------------
## `PG_PROVISION`

[`PG_BOOTSTRAP`](#PG_BOOTSTRAP)负责拉起一套全新的Postgres集群，而[`PG_PROVISION`](#PG_PROVISION)负责在这套全新的数据库集群中创建默认的对象，包括

* 基本角色：只读角色，读写角色、管理角色
* 基本用户：复制用户、超级用户、监控用户、管理用户
* 模板数据库中的默认权限
* 默认 模式
* 默认 扩展
* HBA黑白名单规则

Pigsty提供了丰富的定制选项，如果您希望进一步客制化PG集群，可以参考 [定制：PGSQL集群](v-pgsql-customize.md)



### `pg_provision`

是否置备PG集群？（应用模板）, 类型：`bool`，层级：C，默认值为：`true`

是否对拉起的PostgreSQL集群执行置备任务？设置为假会跳过 [`PG_TEMPLATE`](#PG_TEMPALTE)定义的任务。
但注意，数据库超级用户、复制用户、管理用户、监控用户四个默认用户的创建不受此影响。



### `pg_init`

自定义PG初始化脚本, 类型：`string`，层级：C，默认值为：`"pg-init"`

用于初始化数据库模板的Shell脚本位置，默认为`pg-init`，该脚本会被拷贝至`/pg/bin/pg-init`后执行。

默认的`pg-init` 只是预渲染SQL命令的包装：

* `/pg/tmp/pg-init-roles.sql` ： 根据[`pg_default_roles`](#pg_default_roles)生成的默认角色创建脚本
* `/pg/tmp/pg-init-template.sql`，根据[`pg_default_privileges`](#pg_default_privileges), [`pg_default_schemas`](#pg_default_schemas), [`pg_default_extensions`](#pg_default_extensions) 生产的SQL命令。会同时应用于默认模版数据库`template1`与默认管理数据库`postgres`。

```bash
# system default roles
psql postgres -qAXwtf /pg/tmp/pg-init-roles.sql

# system default template
psql template1 -qAXwtf /pg/tmp/pg-init-template.sql

# make postgres same as templated database (optional)
psql postgres  -qAXwtf /pg/tmp/pg-init-template.sql
```

用户可以在自定义的`pg-init`脚本中添加自己的集群初始化逻辑。





### `pg_default_roles`

默认创建的角色与用户, 类型：`role[]`，层级：G/C，默认值为：

```yaml
# - default roles - #
pg_default_roles:
  # default roles
  - { name: dbrole_readonly  , login: false , comment: role for global read-only access  }                            # production read-only role
  - { name: dbrole_readwrite , login: false , roles: [dbrole_readonly], comment: role for global read-write access }  # production read-write role
  - { name: dbrole_offline , login: false , comment: role for restricted read-only access (offline instance) }        # restricted-read-only role
  - { name: dbrole_admin , login: false , roles: [pg_monitor, dbrole_readwrite] , comment: role for object creation }  # production DDL change role

  # default users
  - { name: postgres , superuser: true , comment: system superuser }                             # system dbsu, name is designated by `pg_dbsu`
  - { name: dbuser_dba , superuser: true , roles: [dbrole_admin] , comment: system admin user }  # admin dbsu, name is designated by `pg_admin_username`
  - { name: replicator , replication: true , bypassrls: true , roles: [pg_monitor, dbrole_readonly] , comment: system replicator }                   # replicator
  - { name: dbuser_monitor , roles: [pg_monitor, dbrole_readonly] , comment: system monitor user , parameters: {log_min_duration_statement: 1000 } } # monitor user
  - { name: dbuser_stats , password: DBUser.Stats , roles: [dbrole_offline] , comment: business offline user for offline queries and ETL }           # ETL user
```

本参数定义了PostgreSQL中的[默认角色](c-privilege.md#默认角色)与[默认用户](c-privilege.md#默认用户)，形式为对象数组，对象定义形式与 [`pg_users`](#pg_users) 中保持一致。






### `pg_default_privilegs`

定义数据库模板中的默认权限, 类型：`string[]`，层级：G/C，默认值为：

```yaml
pg_default_privileges:
  - GRANT USAGE                         ON SCHEMAS   TO dbrole_readonly
  - GRANT SELECT                        ON TABLES    TO dbrole_readonly
  - GRANT SELECT                        ON SEQUENCES TO dbrole_readonly
  - GRANT EXECUTE                       ON FUNCTIONS TO dbrole_readonly
  - GRANT USAGE                         ON SCHEMAS   TO dbrole_offline
  - GRANT SELECT                        ON TABLES    TO dbrole_offline
  - GRANT SELECT                        ON SEQUENCES TO dbrole_offline
  - GRANT EXECUTE                       ON FUNCTIONS TO dbrole_offline
  - GRANT INSERT, UPDATE, DELETE        ON TABLES    TO dbrole_readwrite
  - GRANT USAGE,  UPDATE                ON SEQUENCES TO dbrole_readwrite
  - GRANT TRUNCATE, REFERENCES, TRIGGER ON TABLES    TO dbrole_admin
  - GRANT CREATE                        ON SCHEMAS   TO dbrole_admin
```

详细信息请参考 [默认权限](c-privilege.md#权限)。




### `pg_default_schemas`

默认创建的模式, 类型：`string[]`，层级：G/C，默认值为：`[monitor]`

Pigsty默认会创建名为`monitor`的模式用于安装监控扩展。




### `pg_default_extensions`

默认安装于模板数据库的扩展，对象数组，类型为`extension[]`，层级：G/C，默认值为：

```yaml
pg_default_extensions:
  - { name: 'pg_stat_statements',  schema: 'monitor' }
  - { name: 'pgstattuple',         schema: 'monitor' }
  - { name: 'pg_qualstats',        schema: 'monitor' }
  - { name: 'pg_buffercache',      schema: 'monitor' }
  - { name: 'pageinspect',         schema: 'monitor' }
  - { name: 'pg_prewarm',          schema: 'monitor' }
  - { name: 'pg_visibility',       schema: 'monitor' }
  - { name: 'pg_freespacemap',     schema: 'monitor' }
  - { name: 'pg_repack',           schema: 'monitor' }
  - name: postgres_fdw
  - name: file_fdw
  - name: btree_gist
  - name: btree_gin
  - name: pg_trgm
  - name: intagg
  - name: intarray
```

如果扩展没有指定`schema`字段，扩展会根据当前的`search_path`安装至对应模式中，例如`public`。




### `pg_reload`

是否重载数据库配置（HBA）, 类型：`bool`，层级：A，默认值为：`true`

设置为`true`时，Pigsty会在生成HBA规则后立刻执行`pg_ctl reload`应用。

当您希望生成`pg_hba.conf`文件，并手工比较后再应用生效时，可以指定`-e pg_reload=false`来禁用它。



### `pg_hba_rules`

PostgreSQL全局HBA规则, 类型：`rule[]`，层级：G/C，默认值为：

```yaml
pg_hba_rules:
  - title: allow meta node password access
    role: common
    rules:
      - host    all     all                         10.10.10.10/32      md5

  - title: allow intranet admin password access
    role: common
    rules:
      - host    all     +dbrole_admin               10.0.0.0/8          md5
      - host    all     +dbrole_admin               172.16.0.0/12       md5
      - host    all     +dbrole_admin               192.168.0.0/16      md5

  - title: allow intranet password access
    role: common
    rules:
      - host    all             all                 10.0.0.0/8          md5
      - host    all             all                 172.16.0.0/12       md5
      - host    all             all                 192.168.0.0/16      md5

  - title: allow local read-write access (local production user via pgbouncer)
    role: common
    rules:
      - local   all     +dbrole_readwrite                               md5
      - host    all     +dbrole_readwrite           127.0.0.1/32        md5

  - title: allow read-only user (stats, personal) password directly access
    role: replica
    rules:
      - local   all     +dbrole_readonly                               md5
      - host    all     +dbrole_readonly           127.0.0.1/32        md5
```

本参数在形式上与 [`pg_hba_rules_extra`](#pg_hba_rules_extra) 完全一致，建议在全局配置统一的 [`pg_hba_rules`](#pg_hba_rules)，针对特定集群使用 [`pg_hba_rules_extra`](#pg_hba_rules_extra) 进行额外定制。两个参数中的规则都会依次应用，后者优先级更高。





### `pgbouncer_hba_rules`

PgbouncerL全局HBA规则, 类型：`rule[]`，层级：G/C，默认值为：

```yaml
pgbouncer_hba_rules:
  - title: local password access
    role: common
    rules:
      - local  all          all                                     md5
      - host   all          all                     127.0.0.1/32    md5

  - title: intranet password access
    role: common
    rules:
      - host   all          all                     10.0.0.0/8      md5
      - host   all          all                     172.16.0.0/12   md5
      - host   all          all                     192.168.0.0/16  md5
```

默认的Pgbouncer HBA规则很简单：

1. 允许从**本地**使用密码登陆
2. 允许从内网网断使用密码登陆

用户可以按照自己的需求进行定制。






----------------
## `PG_EXPORTER`

PG Exporter 用于监控Postgres数据库与Pgbouncer连接池



### `pg_exporter_config`

PG指标定义配置文件, 类型：`string`，层级：C，默认值为：`"pg_exporter.yml"`

`pg_exporter`使用的默认配置文件，定义了Pigsty中的数据库与连接池监控指标。默认为 [`pg_exporter.yml`](https://github.com/Vonng/pigsty/blob/master/roles/pg_exporter/files/pg_exporter.yml)

Pigsty使用的PG Exporter配置文件默认从PostgreSQL 10.0 开始提供支持，目前支持至最新的PG 14版本。此外还有一些可选的配置模板：

* [`pg_exporter_basic.yml`](https://github.com/Vonng/pigsty/blob/master/roles/pg_exporter/files/pg_exporter_basic.yml)：只包含基本指标，不包含数据库内对象监控指标
* [`pg_exporter_fast.yml`](https://github.com/Vonng/pigsty/blob/master/roles/pg_exporter/files/pg_exporter_fast.yml)：缓存时间更短的指标定义




### `pg_exporter_enabled`

启用PG指标收集器, 类型：`bool`，层级：C，默认值为：`true`

是否安装并配置`pg_exporter`，为`false`时，将跳过当前节点上 `pg_exporter` 的配置，并在注册监控目标时跳过此Exporter。



### `pg_exporter_port`

PG指标暴露端口, 类型：`int`，层级：C，默认值为：`9630`




### `pg_exporter_params`

PG Exporter额外的URL参数, 类型：`string`，层级：C/I，默认值为：`"sslmode=disable"`




### `pg_exporter_url`

采集对象数据库的连接串（覆盖）, 类型：`string`，层级：C/I，默认值为：`""`

PG Exporter用于连接至数据库的PGURL，应当为访问`postgres`管理数据库的URL，该选项以环境变量的方式配置于 `/etc/default/pg_exporter` 中。

可选参数，默认为空字符串，如果配置了 [`pg_exporter_url`](#pg_exporter_url) 选项，则会直接使用该URL作为监控连接串。否则Pigsty将使用以下规则生成监控的目标URL：

* [`pg_monitor_username`](#pg_monitor_username) : 监控用户名
* [`pg_monitor_password`](#pg_monitor_password) : 监控用户密码
* [`pg_localhost`](#pg_localhost) : PG监听的本地IP地址或Unix Socket Dir
* [`pg_port`](#pg_port) : PG监听的端口
* [`pg_exporter_params`](#pg_exporter_params) : PG Exporter需要的额外参数

以上参数将按下列方式进行拼接

```bash
postgres://{{ pg_monitor_username }}:{{ pg_monitor_password }}@:{{ pg_port }}/postgres{% if pg_exporter_params != '' %}?{{ pg_exporter_params }}{% if pg_localhost != '' %}&host={{ pg_localhost }}{% endif %}{% endif %}
```

如果指定了[`pg_exporter_url`](#pg_exporter_url) 参数，则Exporter会直接使用该连接串。

注意：当您只需要监控某一个特定业务数据库时，您可以直接使用该数据库的PGURL。如果您希望监控某一个数据库实例上**所有**的业务数据库，则建议使用管理数据库`postgres`的PGURL。




### `pg_exporter_auto_discovery`

是否自动发现实例中的数据库, 类型：`bool`，层级：C/I，默认值为：`true`

是否启用自动数据库发现，默认开启。开启后，PG Exporter会自动检测目标实例中数据库列表的变化，并为每一个数据库创建一条抓取连接

关闭时，库内对象监控不可用。（如果您不希望在监控系统中暴露业务相关数据，可以关闭此特性）

!> 注意如果您有很多数据库（100+），或数据库内对象非常多（几k，十几k），请审慎评估对象监控产生的开销。




### `pg_exporter_exclude_database`

数据库自动发现排除列表, 类型：`string`，层级：C/I，默认值为：`"template0,template1,postgres"`

逗号分隔的数据库名称列表，启用自动数据库发现时，此列表中的数据库**不会被监控**（被排除在监控对象之外）。



### `pg_exporter_include_database`

数据库自动发现囊括列表, 类型：`string`，层级：C/I，默认值为：`""`

逗号分隔的数据库名称列表，启用自动数据库发现时，不在此列表中的数据库不会被监控（显式指定需要监控的数据库）。




### `pg_exporter_options`

PG Exporter命令行参数, 类型：`string`，层级：C/I，默认值为：`"--log.level=info --log.format=\"logger:syslog?appname=pg_exporter&local=7\""`




### `pgbouncer_exporter_enabled`

启用PGB指标收集器, 类型：`bool`，层级：C，默认值为：`true`




### `pgbouncer_exporter_port`

PGB指标暴露端口, 类型：`int`，层级：C，默认值为：`9631`





### `pgbouncer_exporter_url`

采集对象连接池的连接串, 类型：`string`，层级：C/I，默认值为：`""`

PGBouncer Exporter用于连接至数据库的URL，应当为访问`pgbouncer`管理数据库的URL。可选参数，默认为空字符串。

Pigsty默认使用以下规则生成监控的目标URL，如果配置了`pgbouncer_exporter_url`选项，则会直接使用该URL作为连接串。

```bash
PG_EXPORTER_URL='postgres://{{ pg_monitor_username }}:{{ pg_monitor_password }}@:{{ pgbouncer_port }}/pgbouncer?host={{ pg_localhost }}&sslmode=disable'
```

该选项以环境变量的方式配置于 `/etc/default/pgbouncer_exporter` 中。





### `pgbouncer_exporter_options`

PGB Exporter命令行参数, 类型：`string`，层级：C/I，默认值为：`"--log.level=info --log.format=\"logger:syslog?appname=pgbouncer_exporter&local=7\""`

即将INFO级日志打入syslog中。





----------------
## `PG_SERVICE`

对外暴露PostgreSQL服务，安装负载均衡器 HAProxy，启用VIP，配置DNS。



### `pg_services`

全局通用PG服务定义, 类型：`[]service`，层级：G，默认值为：

```yaml
pg_services:                     # how to expose postgres service in cluster?
  - name: primary                # service name {{ pg_cluster }}-primary
    src_ip: "*"
    src_port: 5433
    dst_port: pgbouncer          # 5433 route to pgbouncer
    check_url: /primary          # primary health check, success when instance is primary
    selector: "[]"               # select all instance as primary service candidate
 
  - name: replica                # service name {{ pg_cluster }}-replica
    src_ip: "*"
    src_port: 5434
    dst_port: pgbouncer
    check_url: /read-only        # read-only health check. (including primary)
    selector: "[]"               # select all instance as replica service candidate
    selector_backup: "[? pg_role == `primary` || pg_role == `offline` ]"
  
  - name: default                # service's actual name is {{ pg_cluster }}-default
    src_ip: "*"                  # service bind ip address, * for all, vip for cluster virtual ip address
    src_port: 5436               # bind port, mandatory
    dst_port: postgres           # target port: postgres|pgbouncer|port_number , pgbouncer(6432) by default
    check_method: http           # health check method: only http is available for now
    check_port: patroni          # health check port:  patroni|pg_exporter|port_number , patroni by default
    check_url: /primary          # health check url path, / as default
    check_code: 200              # health check http code, 200 as default
    selector: "[]"               # instance selector
    haproxy:                     # haproxy specific fields
      maxconn: 3000              # default front-end connection
      balance: roundrobin        # load balance algorithm (roundrobin by default)
      default_server_options: 'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'
 
  - name: offline                # service name {{ pg_cluster }}-offline
    src_ip: "*"
    src_port: 5438
    dst_port: postgres
    check_url: /replica          # offline MUST be a replica
    selector: "[? pg_role == `offline` || pg_offline_query ]"         # instances with pg_role == 'offline' or instance marked with 'pg_offline_query == true'
    selector_backup: "[? pg_role == `replica` && !pg_offline_query]"  # replica are used as backup server in offline service
```

由[服务定义](c-service.md#自定义服务)对象构成的数组，定义了每一个数据库集群中对外暴露的服务。形式上与 [`pg_service_extra`](#pg_services_extra) 保持一致。




### `haproxy_enabled`

是否启用Haproxy, 类型：`bool`，层级：C/I，默认值为：`true`

Pigsty默认会在所有数据库节点上部署Haproxy，您可以通过覆盖实例级变量，仅在特定实例/节点上启用Haproxy负载均衡器。




### `haproxy_reload`

是否重载Haproxy配置, 类型：`bool`，层级：A，默认值为：`true`

如果关闭，则Pigsty在渲染HAProxy配置文件后不会执行Reload操作，给用户手工介入检查确认的机会。




### `haproxy_auth_enabled`

是否对Haproxy管理界面启用认证, 类型：`bool`，层级：G/C，默认值为：`false`

默认不启用，建议在生产环境启用，或在Nginx或其他接入层添加访问控制。



### `haproxy_admin_username`

HAproxy管理员名称, 类型：`string`，层级：G，默认值为：`"admin"`





### `haproxy_admin_password`

HAproxy管理员密码, 类型：`string`，层级：G，默认值为：`"pigsty"`





### `haproxy_exporter_port`

HAproxy指标暴露器端口, 类型：`int`，层级：C，默认值为：`9101`





### `haproxy_client_timeout`

HAproxy客户端超时, 类型：`interval`，层级：C，默认值为：`"24h"`





### `haproxy_server_timeout`

HAproxy服务端超时, 类型：`interval`，层级：C，默认值为：`"24h"`





### `vip_mode`

VIP模式：none, 类型：`enum`，层级：C，默认值为：`"none"`

* `none`：不设置VIP，默认选项。
* `l2`：配置绑定在主库上的二层VIP（需要所有成员位于同一个二层网络广播域中）
* `l4` ：预留值，通过外部L4负载均衡器进行流量分发。（未纳入Pigsty当前实现中）

VIP用于确保**读写服务**与**负载均衡器**的高可用，当使用L2 VIP时，Pigsty的VIP由`vip-manager`托管，会绑定在**集群主库**上。

这意味着您始终可以通过VIP访问集群主库，或者通过VIP访问主库上的负载均衡器（如果主库的压力很大，这样做可能会有性能压力）。

> 注意，使用二层VIP时，您必须保证VIP候选实例处于同一个二层网络（VLAN、交换机）下。



### `vip_reload`

是否重载VIP配置, 类型：`bool`，层级：A，默认值为：`true`





### `vip_address`

集群使用的VIP地址, 类型：`string`，层级：C，默认值为：





### `vip_cidrmask`

VIP地址的网络CIDR掩码长度, 类型：`int`，层级：C，默认值为：





### `vip_interface`

VIP使用的网卡, 类型：`string`，层级：C/I，默认值为：





### `dns_mode`

DNS配置模式（保留参数）, 类型：`enum`，层级：C，默认值为：





### `dns_selector`

DNS解析对象选择器（保留参数）, 类型：`string`，层级：C，默认值为：