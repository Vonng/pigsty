# 配置：PGSQL

> [配置](v-config.md)PostgreSQL数据库集群，控制[PGSQL剧本](p-playbook.md)行为。

* [`PG IDENTITY`](#pg_identity) : 定义一套PostgreSQL数据库集群
* [`PG_INSTALL`](#pg_install): 安装PostgreSQL软件包，扩展插件，准备目录结构与工具脚本
* [`PG_PROVISION`](#pg_provision): 生成配置模板，拉起PostgreSQL集群，搭建主从复制，启用连接池
* [`PG_TEMPLATE`](#pg_template): 按照模板参数定制PG集群内容：创建用户与数据库，配置权限角色HBA，模式与扩展。
* [`PG_EXPORTER`](#pg_exporter): 为数据库与连接池配置监控组件
* [`SERVICE`](#service): 对外暴露PostgreSQL服务，安装负载均衡器 HAProxy，启用VIP，配置DNS。

|                             参数                              | 角色                            | 层级  |               说明               |
|---------------------------------------------------------------|-------------------------------|-------|----------------------------------|
| [pg_cluster](#pg_cluster)                                     | [pg_identity](#pg_identity)   | C     | PG数据库集群名称|
| [pg_seq](#pg_seq)                                             | [pg_identity](#pg_identity)   | I     | PG数据库实例序号|
| [pg_role](#pg_role)                                           | [pg_identity](#pg_identity)   | I     | PG数据库实例角色|
| [pg_shard](#pg_shard)                                         | [pg_identity](#pg_identity)   | C     | PG集群所属的Shard (保留)|
| [pg_sindex](#pg_sindex)                                       | [pg_identity](#pg_identity)   | C     | PG集群的分片号 (保留)|
| [pg_dbsu](#pg_dbsu)                                           | [pg_install](#pg_install)     | G/C   | PG操作系统超级用户|
| [pg_dbsu_uid](#pg_dbsu_uid)                                   | [pg_install](#pg_install)     | G/C   | 超级用户UID|
| [pg_dbsu_sudo](#pg_dbsu_sudo)                                 | [pg_install](#pg_install)     | G/C   | 超级用户的Sudo权限|
| [pg_dbsu_home](#pg_dbsu_home)                                 | [pg_install](#pg_install)     | G/C   | 超级用户的家目录|
| [pg_dbsu_ssh_exchange](#pg_dbsu_ssh_exchange)                 | [pg_install](#pg_install)     | G/C   | 是否交换超级用户密钥|
| [pg_version](#pg_version)                                     | [pg_install](#pg_install)     | G/C   | 安装的数据库大版本|
| [pgdg_repo](#pgdg_repo)                                       | [pg_install](#pg_install)     | G/C   | 是否添加PG官方源？|
| [pg_add_repo](#pg_add_repo)                                   | [pg_install](#pg_install)     | G/C   | 是否添加PG相关源？|
| [pg_bin_dir](#pg_bin_dir)                                     | [pg_install](#pg_install)     | G/C   | PG二进制目录|
| [pg_packages](#pg_packages)                                   | [pg_install](#pg_install)     | G/C   | 安装的PG软件包列表|
| [pg_extensions](#pg_extensions)                               | [pg_install](#pg_install)     | G/C   | 安装的PG插件列表|
| [pg_preflight_skip](#pg_preflight_skip)                       | [pg_provision](#pg_provision) | A/C   | 跳过PG身份参数校验|
| [pg_hostname](#pg_hostname)                                   | [pg_provision](#pg_provision) | G/C   | 将PG实例名称设为HOSTNAME|
| [pg_exists](#pg_exists)                                       | [pg_provision](#pg_provision) | A     | 标记位，PG是否已存在|
| [pg_exists_action](#pg_exists_action)                         | [pg_provision](#pg_provision) | G/A   | PG存在时如何处理|
| [pg_disable_purge](#pg_disable_purge)                         | [pg_provision](#pg_provision) | G/C/I | 禁止清除存在的PG实例|
| [pg_data](#pg_data)                                           | [pg_provision](#pg_provision) | G     | PG数据目录|
| [pg_fs_main](#pg_fs_main)                                     | [pg_provision](#pg_provision) | G     | PG主数据盘挂载点|
| [pg_fs_bkup](#pg_fs_bkup)                                     | [pg_provision](#pg_provision) | G     | PG备份盘挂载点|
| [pg_dummy_filesize](#pg_dummy_filesize)                       | [pg_provision](#pg_provision) | G/C/I | 占位文件/pg/dummy的大小|
| [pg_listen](#pg_listen)                                       | [pg_provision](#pg_provision) | G     | PG监听的IP地址|
| [pg_port](#pg_port)                                           | [pg_provision](#pg_provision) | G     | PG监听的端口|
| [pg_localhost](#pg_localhost)                                 | [pg_provision](#pg_provision) | G/C   | PG使用的UnixSocket地址|
| [pg_upstream](#pg_upstream)                                   | [pg_provision](#pg_provision) | I     | 实例的复制上游节点|
| [pg_backup](#pg_backup)                                       | [pg_provision](#pg_provision) | I     | 是否在实例上存储备份|
| [pg_delay](#pg_delay)                                         | [pg_provision](#pg_provision) | I     | 若实例为延迟从库，采用的延迟时长|
| [patroni_enabled](#patroni_enabled)                           | [pg_provision](#pg_provision) | C     | Patroni是否启用|
| [patroni_mode](#patroni_mode)                                 | [pg_provision](#pg_provision) | G/C   | Patroni配置模式|
| [pg_namespace](#pg_namespace)                                 | [pg_provision](#pg_provision) | G/C   | Patroni使用的DCS命名空间|
| [patroni_port](#patroni_port)                                 | [pg_provision](#pg_provision) | G/C   | Patroni服务端口|
| [patroni_watchdog_mode](#patroni_watchdog_mode)               | [pg_provision](#pg_provision) | G/C   | Patroni Watchdog模式|
| [pg_conf](#pg_conf)                                           | [pg_provision](#pg_provision) | G/C   | Patroni使用的配置模板|
| [pg_shared_libraries](#pg_shared_libraries)                   | [pg_provision](#pg_provision) | G/C   | PG默认加载的共享库|
| [pg_encoding](#pg_encoding)                                   | [pg_provision](#pg_provision) | G/C   | PG字符集编码|
| [pg_locale](#pg_locale)                                       | [pg_provision](#pg_provision) | G/C   | PG使用的本地化规则|
| [pg_lc_collate](#pg_lc_collate)                               | [pg_provision](#pg_provision) | G/C   | PG使用的本地化排序规则|
| [pg_lc_ctype](#pg_lc_ctype)                                   | [pg_provision](#pg_provision) | G/C   | PG使用的本地化字符集定义|
| [pgbouncer_enabled](#pgbouncer_enabled)                       | [pg_provision](#pg_provision) | G/C   | 是否启用Pgbouncer|
| [pgbouncer_port](#pgbouncer_port)                             | [pg_provision](#pg_provision) | G/C   | Pgbouncer端口|
| [pgbouncer_poolmode](#pgbouncer_poolmode)                     | [pg_provision](#pg_provision) | G/C   | Pgbouncer池化模式|
| [pgbouncer_max_db_conn](#pgbouncer_max_db_conn)               | [pg_provision](#pg_provision) | G/C   | Pgbouncer最大单DB连接数|
| [pg_init](#pg_init)                                           | [pg_template](#pg_template)   | G/C   | 自定义PG初始化脚本|
| [pg_replication_username](#pg_replication_username)           | [pg_template](#pg_template)   | G     | PG复制用户|
| [pg_replication_password](#pg_replication_password)           | [pg_template](#pg_template)   | G     | PG复制用户的密码|
| [pg_monitor_username](#pg_monitor_username)                   | [pg_template](#pg_template)   | G     | PG监控用户|
| [pg_monitor_password](#pg_monitor_password)                   | [pg_template](#pg_template)   | G     | PG监控用户密码|
| [pg_admin_username](#pg_admin_username)                       | [pg_template](#pg_template)   | G     | PG管理用户|
| [pg_admin_password](#pg_admin_password)                       | [pg_template](#pg_template)   | G     | PG管理用户密码|
| [pg_default_roles](#pg_default_roles)                         | [pg_template](#pg_template)   | G     | 默认创建的角色与用户|
| [pg_default_privilegs](#pg_default_privilegs)                 | [pg_template](#pg_template)   | G     | 数据库默认权限配置|
| [pg_default_schemas](#pg_default_schemas)                     | [pg_template](#pg_template)   | G     | 默认创建的模式|
| [pg_default_extensions](#pg_default_extensions)               | [pg_template](#pg_template)   | G     | 默认安装的扩展|
| [pg_offline_query](#pg_offline_query)                         | [pg_template](#pg_template)   | I     | 是否允许离线查询|
| [pg_reload](#pg_reload)                                       | [pg_template](#pg_template)   | A     | 是否重载数据库配置（HBA）|
| [pg_hba_rules](#pg_hba_rules)                                 | [pg_template](#pg_template)   | G     | 全局HBA规则|
| [pg_hba_rules_extra](#pg_hba_rules_extra)                     | [pg_template](#pg_template)   | C/I   | 集群/实例特定的HBA规则|
| [pgbouncer_hba_rules](#pgbouncer_hba_rules)                   | [pg_template](#pg_template)   | G/C   | Pgbouncer全局HBA规则|
| [pgbouncer_hba_rules_extra](#pgbouncer_hba_rules_extra)       | [pg_template](#pg_template)   | G/C   | Pgbounce特定HBA规则|
| [pg_databases](#pg_databases)                                 | [pg_template](#pg_template)   | G/C   | 业务数据库定义|
| [pg_users](#pg_users)                                         | [pg_template](#pg_template)   | G/C   | 业务用户定义|
| [pg_exporter_config](#pg_exporter_config)                     | [pg_exporter](#pg_exporter)   | G/C   | PG指标定义文件|
| [pg_exporter_enabled](#pg_exporter_enabled)                   | [pg_exporter](#pg_exporter)   | G/C   | 启用PG指标收集器|
| [pg_exporter_port](#pg_exporter_port)                         | [pg_exporter](#pg_exporter)   | G/C   | PG指标暴露端口|
| [pg_exporter_params](#pg_exporter_params)                     | [pg_exporter](#pg_exporter)   | G/C/I | PG Exporter额外的URL参数|
| [pg_exporter_url](#pg_exporter_url)                           | [pg_exporter](#pg_exporter)   | C/I   | 采集对象数据库的连接串（覆盖）|
| [pg_exporter_auto_discovery](#pg_exporter_auto_discovery)     | [pg_exporter](#pg_exporter)   | G/C/I | 是否自动发现实例中的数据库|
| [pg_exporter_exclude_database](#pg_exporter_exclude_database) | [pg_exporter](#pg_exporter)   | G/C/I | 数据库自动发现排除列表|
| [pg_exporter_include_database](#pg_exporter_include_database) | [pg_exporter](#pg_exporter)   | G/C/I | 数据库自动发现囊括列表|
| [pg_exporter_options](#pg_exporter_options)                   | [pg_exporter](#pg_exporter)   | G/C/I | PG Exporter命令行参数|
| [pgbouncer_exporter_enabled](#pgbouncer_exporter_enabled)     | [pg_exporter](#pg_exporter)   | G/C   | 启用PGB指标收集器|
| [pgbouncer_exporter_port](#pgbouncer_exporter_port)           | [pg_exporter](#pg_exporter)   | G/C   | PGB指标暴露端口|
| [pgbouncer_exporter_url](#pgbouncer_exporter_url)             | [pg_exporter](#pg_exporter)   | G/C   | 采集对象连接池的连接串|
| [pgbouncer_exporter_options](#pgbouncer_exporter_options)     | [pg_exporter](#pg_exporter)   | G/C/I | PGB Exporter命令行参数|
| [pg_weight](#pg_weight)                                       | [service](#service)           | I     | 实例在负载均衡中的相对权重|
| [pg_services](#pg_services)                                   | [service](#service)           | G     | 全局通用服务定义|
| [pg_services_extra](#pg_services_extra)                       | [service](#service)           | C     | 集群专有服务定义|
| [haproxy_enabled](#haproxy_enabled)                           | [service](#service)           | G/C/I | 是否启用Haproxy|
| [haproxy_reload](#haproxy_reload)                             | [service](#service)           | A     | 是否重载Haproxy配置|
| [haproxy_admin_auth_enabled](#haproxy_admin_auth_enabled)     | [service](#service)           | G/C   | 是否对Haproxy管理界面启用认证|
| [haproxy_admin_username](#haproxy_admin_username)             | [service](#service)           | G/C   | HAproxy管理员名称|
| [haproxy_admin_password](#haproxy_admin_password)             | [service](#service)           | G/C   | HAproxy管理员密码|
| [haproxy_exporter_port](#haproxy_exporter_port)               | [service](#service)           | G/C   | HAproxy指标暴露器端口|
| [haproxy_client_timeout](#haproxy_client_timeout)             | [service](#service)           | G/C   | HAproxy客户端超时|
| [haproxy_server_timeout](#haproxy_server_timeout)             | [service](#service)           | G/C   | HAproxy服务端超时|
| [vip_mode](#vip_mode)                                         | [service](#service)           | G/C   | VIP模式：none|
| [vip_reload](#vip_reload)                                     | [service](#service)           | G/C   | 是否重载VIP配置|
| [vip_address](#vip_address)                                   | [service](#service)           | G/C   | 集群使用的VIP地址|
| [vip_cidrmask](#vip_cidrmask)                                 | [service](#service)           | G/C   | VIP地址的网络CIDR掩码|
| [vip_interface](#vip_interface)                               | [service](#service)           | G/C   | VIP使用的网卡|
| [dns_mode](#dns_mode)                                         | [service](#service)           | G/C   | DNS配置模式|
| [dns_selector](#dns_selector)                                 | [service](#service)           | G/C   | DNS解析对象选择器|
| [rm_pgdata](#rm_pgdata)                                       | [pg_remove](#pg_remove)       | A     | 下线时是否一并删除数据库|
| [rm_pgpkgs](#rm_pgpkgs)                                       | [pg_remove](#pg_remove)       | A     | 下线时是否一并删除软件包|
| [pg_user](#pg_user)                                           | [createuser](#pg_user)        | A     | 需要创建的PG用户名|
| [pg_database](#pg_database)                                   | [createdb](#pg_database)      | A     | 需要创建的PG数据库名|
| [gp_cluster](#gp_cluster)                                     | [pg_exporters](#pg_exporters) | C     | 当前PG集群所属GP集群|
| [gp_role](#gp_role)                                           | [pg_exporters](#pg_exporters) | C     | 当前PG集群在GP中的角色|
| [pg_instances](#pg_instances)                                 | [pg_exporters](#pg_exporters) | I     | 当前节点上的所有PG实例|


## `PG_IDENTITY`

[`pg_cluster`](#pg_cluster)，[`pg_role`](#pg_role)，[`pg_seq`](#pg_seq) 属于 **身份参数** 。
除了IP地址外，这三个参数是定义一套新的数据库集群的最小必须参数集。

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

* `pg_cluster` 标识了集群的名称，在集群层面进行配置。
* `pg_role` 在实例层面进行配置，标识了实例的角色，只有`primary`角色会进行特殊处理，如果不填，默认为`replica`角色，此外，还有特殊的`delayed`与`offline`角色。
* `pg_seq` 用于在集群内标识实例，通常采用从0或1开始递增的整数，一旦分配不再更改。
* `{{ pg_cluster }}-{{ pg_seq }}` 被用于唯一标识实例，即`pg_instance`
* `{{ pg_cluster }}-{{ pg_role }}` 用于标识集群内的服务，即`pg_service`
* [`pg_shard`](#pg_shard) 与 [`pg_sindex`](pg_sindex) 用于水平分片集群，为Citus与Greenplum多集群管理预留。



### `pg_cluster`

PG数据库集群的名称，将用作集群内资源的命名空间。

集群命名需要遵循特定命名规则：`[a-z][a-z0-9-]*`，以兼容不同约束对身份标识的要求。

**身份参数，必填参数，集群级参数**



### `pg_seq`

数据库实例的序号，在**集群内部唯一**，用于区别与标识集群内的不同实例，从0或1开始分配。

**身份参数，必填参数，实例级参数**



### `pg_role`

数据库实例的角色，默认角色包括：`primary`, `replica`, `offline`

* `primary`: 集群主库，集群中必须有一个且只能有一个成员为`primary`
* `replica`: 集群从库，用于承担在线只读流量。
* `offline`: 集群离线从库，用于承担离线只读流量，例如统计分析/ETL/个人查询等。

**身份参数，必填参数，实例级参数**



### `pg_shard`

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

**身份参数，可选参数，集群级参数**



### `pg_sindex`

集群在分片集簇中的编号，通常从0或1开始依次分配。只有分片集群需要设置此参数。

**身份参数，选填参数，集群级参数**



### `pg_hostname`

是否在初始化节点时，将PostgreSQL的实例名与集群名一并用作节点的名称与集群名，默认禁用。

当采用 节点:PG 1:1 部署模式时，您可以将PG实例的身份赋予节点，从而在监控系统中观察同一个数据库集群所属节点集群的性能洞察。





------------------

## `PG_INSTALL`

PG Install 部分负责在一台装有基本软件的机器上完成所有PostgreSQL依赖项的安装。用户可以配置数据库超级用户的名称、ID、权限、访问，配置安装所用的源，配置安装地址，安装的版本，所需的软件包与扩展插件。

这里的大多数参数只需要在整体升级数据库大版本时修改，用户可以通过`pg_version`指定需要安装的软件版本，并在集群层面进行覆盖，为不同的集群安装不同的数据库版本。

<details>
<summary>PG_INSTALL参数默认值</summary>

```yaml
#------------------------------------------------------------------------------
# POSTGRES INSTALLATION
#------------------------------------------------------------------------------
# - dbsu - #
pg_dbsu: postgres                             # os user for database, postgres by default (unwise to change it)
pg_dbsu_uid: 26                               # os dbsu uid and gid, 26 for default postgres users and groups
pg_dbsu_sudo: limit                           # dbsu sudo privilege: none|limit|all|nopass, limit by default
pg_dbsu_home: /var/lib/pgsql                  # postgresql home directory
pg_dbsu_ssh_exchange: true                    # exchange postgres dbsu ssh key among same cluster ?

# - postgres packages - #                     # `${pg_version} will be replaced by actual `pg_version`
pg_version: 14                                # default postgresql version to be installed
pgdg_repo: false                              # add pgdg official repo before install (in case of no local repo available)
pg_add_repo: false                            # add postgres related repo before install (useful if you want a simple install)
pg_bin_dir: /usr/pgsql/bin                    # postgres binary dir, default is /usr/pgsql/bin, which use /usr/pgsql -> /usr/pgsql-{ver}
pg_packages:                                  # postgresql related packages. `${pg_version} will be replaced by `pg_version`
  - postgresql${pg_version}*                  # postgresql kernel packages
  - postgis32_${pg_version}*                  # postgis
  - citus_${pg_version}*                      # citus
  - timescaledb-2-postgresql-${pg_version}    # timescaledb
  - pgbouncer pg_exporter pgbadger pg_activity node_exporter consul haproxy vip-manager
  - patroni patroni-consul patroni-etcd python3 python3-psycopg2 python36-requests python3-etcd
  - python3-consul python36-urllib3 python36-idna python36-pyOpenSSL python36-cryptography

pg_extensions:                                # postgresql extensions. `${pg_version} will be replaced by `pg_version`
  - pg_repack_${pg_version} pg_qualstats_${pg_version} pg_stat_kcache_${pg_version} pg_stat_monitor_${pg_version} wal2json_${pg_version}
```

</details>


### `pg_dbsu`

数据库默认使用的操作系统用户（超级用户）的用户名称，默认为`postgres`，通常不建议修改。
当安装 Greenplum / MatrixDB 时，建议修改本参数为对应推荐值：`gpadmin|mxadmin`。


### `pg_dbsu_uid`

数据库默认使用的操作系统用户（超级用户）的UID。默认值为`26`，与CentOS下PostgreSQL官方RPM包配置一致，不建议修改。


### `pg_dbsu_sudo`

数据库超级用户 [`pg_dbsu`](#pg_dbsu) 的默认权限，默认为受限的`sudo`权限：`limit`。

* `none`：没有sudo权限
* `limit`：有限的sudo权限，可以执行数据库相关组件的systemctl命令，默认
* `all`：带有完整`sudo`权限，但需要密码。
* `nopass`：不需要密码的完整`sudo`权限（不建议）


### `pg_dbsu_home`

数据库超级用户[`pg_dbsu`](#pg_dbsu)的家目录，默认为`/var/lib/pgsql`


### `pg_dbsu_ssh_exchange`

是否在执行的机器之间交换 [`pg_dbsu`](#pg_dbsu) 的SSH公私钥


### `pg_version`

当前实例安装的PostgreSQL大版本号，默认为14，最低支持至10。

请注意，PostgreSQL的物理流复制无法跨越大版本，请在全局/集群层面配置此变量，确保整个集群内所有实例都有着相同的大版本号。


### `pgdg_repo`

标记，是否使用PostgreSQL官方源？默认不使用

使用该选项，可以在没有本地源的情况下，直接从互联网官方源下载安装PostgreSQL相关软件包。


### `pg_add_repo`

如果使用，则会在安装PostgreSQL前添加PGDG的官方源，


### `pg_bin_dir`

PostgreSQL二进制目录路径，会被Patroni所使用。

默认为`/usr/pgsql/bin/`，这是一个安装过程中手动创建的软连接，指向安装的具体Postgres版本目录。

例如`/usr/pgsql -> /usr/pgsql-14`。


### `pg_packages`

默认安装的PostgreSQL软件包

软件包中的`${pg_version}`会被替换为实际安装的PostgreSQL版本 [`pg_version`](#pg_version)。

当您为某一个特定集群指定特殊的`pg_version`时，可以相应在集群层面调整此参数（例如安装PG14 beta时某些扩展还不存在）

```bash
- postgresql${pg_version}*                  # postgresql kernel packages
- postgis32_${pg_version}*                  # postgis
- citus_${pg_version}*                      # citus
- timescaledb-2-postgresql-${pg_version}    # timescaledb
- pgbouncer pg_exporter pgbadger pg_activity node_exporter consul haproxy vip-manager
- patroni patroni-consul patroni-etcd python3 python3-psycopg2 python36-requests python3-etcd
- python3-consul python36-urllib3 python36-idna python36-pyOpenSSL python36-cryptography
```

### `pg_extensions`

需要安装的PostgreSQL扩展插件软件包

软件包中的`${pg_version}`会被替换为实际安装的PostgreSQL大版本号 [`pg_version`](#pg_version)。

默认安装的插件如下所示，强烈建议安装`pg_repack`扩展，用于在线处理表膨胀问题。

```sql
pg_repack${pg_version}
pg_qualstats${pg_version}
pg_stat_kcache${pg_version}
wal2json${pg_version}
```




------------------



## `PG_PROVISION`


**PG置备**，是在一台安装完Postgres的机器上，创建并拉起一套数据库的过程，包括：

* **集群身份定义**，清理现有实例，创建目录结构，拷贝工具与脚本，配置环境变量
* 渲染Patroni模板配置文件，使用Patroni拉起主库，使用Patroni拉起从库
* 配置Pgbouncer，初始化业务用户与数据库，将数据库与数据源服务注册至DCS。

<details>
<summary>PG_PROVISION参数默认值</summary>

```yaml
#------------------------------------------------------------------------------
# POSTGRES TEMPLATE
#------------------------------------------------------------------------------
pg_provision: true                            # whether provisioning postgres cluster

# - template - #
pg_init: pg-init                              # init script for cluster template

# - system roles - #
pg_replication_username: replicator           # system replication user
pg_replication_password: DBUser.Replicator    # system replication password
pg_monitor_username: dbuser_monitor           # system monitor user
pg_monitor_password: DBUser.Monitor           # system monitor password
pg_admin_username: dbuser_dba                 # system admin user
pg_admin_password: DBUser.DBA                 # system admin password

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

# - privileges - #
# object created by dbsu and admin will have their privileges properly set
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
  - GRANT USAGE, UPDATE                 ON SEQUENCES TO dbrole_readwrite
  - GRANT TRUNCATE, REFERENCES, TRIGGER ON TABLES    TO dbrole_admin
  - GRANT CREATE                        ON SCHEMAS   TO dbrole_admin

# - schemas - #
pg_default_schemas: [ monitor ]               # default schemas to be created

# - extension - #
pg_default_extensions:                        # default extensions to be created
  - { name: 'pg_stat_statements', schema: 'monitor' }
  - { name: 'pgstattuple',        schema: 'monitor' }
  - { name: 'pg_qualstats',       schema: 'monitor' }
  - { name: 'pg_buffercache',     schema: 'monitor' }
  - { name: 'pageinspect',        schema: 'monitor' }
  - { name: 'pg_prewarm',         schema: 'monitor' }
  - { name: 'pg_visibility',      schema: 'monitor' }
  - { name: 'pg_freespacemap',    schema: 'monitor' }
  - { name: 'pg_repack',          schema: 'monitor' }
  - name: postgres_fdw
  - name: file_fdw
  - name: btree_gist
  - name: btree_gin
  - name: pg_trgm
  - name: intagg
  - name: intarray

# - hba - #
pg_offline_query: false                       # set to true to enable offline query on this instance (instance level)
pg_reload: true                               # reload postgres after hba changes
pg_hba_rules:                                 # postgres host-based authentication rules
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

  - title: allow local read/write (local production user via pgbouncer)
    role: common
    rules:
      - local   all     +dbrole_readonly                                md5
      - host    all     +dbrole_readonly           127.0.0.1/32         md5

  - title: allow offline query (ETL,SAGA,Interactive) on offline instance
    role: offline
    rules:
      - host    all     +dbrole_offline               10.0.0.0/8        md5
      - host    all     +dbrole_offline               172.16.0.0/12     md5
      - host    all     +dbrole_offline               192.168.0.0/16    md5

pg_hba_rules_extra: []                        # extra hba rules (overwrite by cluster/instance level config)

pgbouncer_hba_rules:                          # pgbouncer host-based authentication rules
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

pgbouncer_hba_rules_extra: []                 # extra pgbouncer hba rules (overwrite by cluster/instance level config)
# pg_users: []                                # business users
# pg_databases: []                            # business databases
```

</details>




### `pg_exists`

PG实例是否存在的标记位，不可配置。



### `pg_exists_action`

安全保险，当PostgreSQL实例已经存在时，系统应当执行的动作

* abort: 中止整个剧本的执行（默认行为）
* clean: 抹除现有实例并继续（极端危险）
* skip: 忽略存在实例的目标（中止），在其他目标机器上继续执行。

如果您真的需要强制清除已经存在的数据库实例，建议先使用[`pgsql-remove.yml`](p-pgsql-remove.md)完成集群与实例的下线与销毁，在重新执行初始化。否则，则需要通过命令行参数`-e pg_exists_action=clean`完成覆写，强制在初始化过程中抹除已有实例。



### `pg_disable_purge`

双重安全保险，默认为`false`。如果为`true`，强制设置`pg_exists_action`变量为`abort`。

等效于关闭`pg_exists_action`的清理功能，确保任何情况下Postgres实例都不会被抹除。

这意味着您需要通过专用下线脚本[`pgsql-remove.yml`](p-pgsql-remove.md)来完成已有实例的清理，然后才可以在清理干净的节点上重新完成数据库的初始化。



### `pg_data`

默认数据目录，默认为`/pg/data`



### `pg_fs_main`

主数据盘目录，默认为`/export`

Pigsty的默认[目录结构](r-fhs)假设系统中存在一个主数据盘挂载点，用于盛放数据库目录。



### `pg_fs_bkup`

归档与备份盘目录，默认为`/var/backups`

Pigsty的默认[目录结构](r-fhs)假设系统中存在一个备份数据盘挂载点，用于盛放备份与归档数据。备份盘并不是必选项，如果系统中不存在备份盘，用户也可以指定一个主数据盘上的子目录作为备份盘根目录挂载点。


### `pg_dummy_filesize`

占位文件 `/pg/dummy` 的大小。默认为`64MiB`，生产环境建议使用`4GiB`，`8GiB`。

占位文件是一个预分配的空文件，占据一定量的磁盘空间。当出现磁盘满故障时，移除该占位文件可以紧急释放一些磁盘空间应急使用。


### `pg_listen`

数据库监听的IP地址，默认为所有IPv4地址`0.0.0.0`，如果要包括所有IPv6地址，可以使用`*`。



### `pg_port`

数据库监听的端口，默认端口为`5432`，不建议修改。



### `pg_localhost`

Unix Socket目录，用于盛放PostgreSQL与Pgbouncer的Unix socket文件。

默认为`/var/run/postgresql`



### `pg_upstream`

实例级配置项，内容为IP地址或主机名，用于指明流复制上游节点。

当为集群的从库配置该参数时，填入的IP地址必须为集群内的其他节点。实例会从该节点进行流复制，此选项可用于构建**级连复制**。

当为集群的主库配置该参数时，意味着整个集群将以 **备份集群**（Standby Cluster） 的形式运行，从上游节点接受变更。集群中的`primary`将扮演`standby leader` 的角色。



### `pg_backup`

标记，实例级配置项，带有该标记的实例会用于存储基础备份（未实现，保留标记位）



### `pg_delay`

若实例为延迟从库，采用的延迟时长。（未实现，保留标记位）

使用PG接受的时间区间字符串格式，如`1h`，`30min`等。



### `patroni_mode`

Patroni的工作模式：
* `default`: 启用Patroni
* `pause`: 启用Patroni，但在完成初始化后自动进入维护模式（不自动执行主从切换）
* `remove`: 依然使用Patroni初始化集群，但初始化完成后移除Patroni



### `pg_namespace`

Patroni在DCS中使用的KV存储顶层命名空间

默认为`pg`



### `patroni_port`

Patroni API服务器默认监听的端口

默认端口为`8008`



### `patroni_watchdog_mode`

当发生主从切换时，Patroni会尝试在提升从库前关闭主库。如果指定超时时间内主库仍未成功关闭，Patroni会根据配置使用Linux内核模块`softdog`进行fencing关机。

* `off`：不使用`watchdog`
* `automatic`：如果内核启用了`softdog`，则启用`watchdog`，不强制，默认行为。
* `required`：强制使用`watchdog`，如果系统未启用`softdog`则拒绝启动。

启用Watchdog意味着系统会优先确保数据一致性，而放弃可用性，如果您的系统更重视可用性，则可以关闭Watchdog。

建议关闭管理节点上的Watchdog。


### `pg_conf`

拉起Postgres集群所用的Patroni模板。Pigsty预制了4种模板

* [`oltp.yml`](#oltp) 常规OLTP模板，默认配置
* [`olap.yml`](#olap) OLAP模板，提高并行度，针对吞吐量优化，针对长时间运行的查询进行优化。
* [`crit.yml`](#crit)) 核心业务模板，基于OLTP模板针对安全性，数据完整性进行优化，采用同步复制，强制启用数据校验和。
* [`tiny.yml`](#tiny) 微型数据库模板，针对低资源场景进行优化，例如运行于虚拟机中的演示数据库集群。


### `pg_shared_libraries`

填入Patroni模板中`shared_preload_libraries`参数的字符串，控制PG启动预加载的动态库。

在当前版本中，默认会加载以下库：`timescaledb, pg_stat_statements, auto_explain`

如果您希望默认启用Citus支持，则需要修改该参数，将 `citus` 添加至首位：

`citus, timescaledb, pg_stat_statements, auto_explain`

并修改 [Patroni模板](t-patroni-template.md) 中 `max_prepared_transaction` 参数为一个合适的值（大于等于`max_connections`的值）


### `pg_encoding`

PostgreSQL实例初始化时，使用的字符集编码。

默认为`UTF8`，如果没有特殊需求，不建议修改此参数。



### `pg_locale`

PostgreSQL实例初始化时，使用的本地化规则。

默认为`C`，如果没有特殊需求，不建议修改此参数。



### `pg_lc_collate`

PostgreSQL实例初始化时，使用的本地化字符串排序规则。

默认为`C`，如果没有特殊需求，**强烈不建议**修改此参数。用户总是可以通过`COLLATE`表达式实现本地化排序相关功能，错误的本地化排序规则可能导致某些操作产生成倍的性能损失，请在真的有本地化需求的情况下修改此参数。



### `pg_lc_ctype`

PostgreSQL实例初始化时，使用的本地化字符集定义

默认为`en_US.UTF8`，因为一些PG扩展（`pg_trgm`）需要额外的字符分类定义才可以针对国际化字符正常工作，因此Pigsty默认会使用`en_US.UTF8`字符集定义，不建议修改此参数。



### `pgbouncer_port`

Pgbouncer连接池默认监听的端口

默认为`6432`



### `pgbouncer_poolmode`

Pgbouncer连接池默认使用的Pool模式

默认为`transaction`，即事务级连接池。其他可选项包括：`session|statemente`



### `pgbouncer_max_db_conn`

允许连接池与单个数据库之间建立的最大连接数

默认值为`100`

使用事务Pooling模式时，活跃服务端连接数通常处于个位数。如果采用会话Pooling模式，可以适当增大此参数。


------------------

## `PG_TEMPLATE`

[`PG_PROVISION`](#pg-provision)负责拉起一套全新的Postgres集群，而`PG_TEMPLATE`负责在这套全新的数据库集群中创建默认的对象，包括

* 基本角色：只读角色，读写角色、管理角色
* 基本用户：复制用户、超级用户、监控用户、管理用户
* 模板数据库中的默认权限
* 默认 模式
* 默认 扩展
* HBA黑白名单规则

<details>
<summary>PG_TEMPLATE参数默认值</summary>

```yaml
#------------------------------------------------------------------------------
# POSTGRES TEMPLATE
#------------------------------------------------------------------------------
pg_provision: true                            # whether provisioning postgres cluster

# - template - #
pg_init: pg-init                              # init script for cluster template

# - system roles - #
pg_replication_username: replicator           # system replication user
pg_replication_password: DBUser.Replicator    # system replication password
pg_monitor_username: dbuser_monitor           # system monitor user
pg_monitor_password: DBUser.Monitor           # system monitor password
pg_admin_username: dbuser_dba                 # system admin user
pg_admin_password: DBUser.DBA                 # system admin password

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

# - privileges - #
# object created by dbsu and admin will have their privileges properly set
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
  - GRANT USAGE, UPDATE                 ON SEQUENCES TO dbrole_readwrite
  - GRANT TRUNCATE, REFERENCES, TRIGGER ON TABLES    TO dbrole_admin
  - GRANT CREATE                        ON SCHEMAS   TO dbrole_admin

# - schemas - #
pg_default_schemas: [ monitor ]               # default schemas to be created

# - extension - #
pg_default_extensions:                        # default extensions to be created
  - { name: 'pg_stat_statements', schema: 'monitor' }
  - { name: 'pgstattuple',        schema: 'monitor' }
  - { name: 'pg_qualstats',       schema: 'monitor' }
  - { name: 'pg_buffercache',     schema: 'monitor' }
  - { name: 'pageinspect',        schema: 'monitor' }
  - { name: 'pg_prewarm',         schema: 'monitor' }
  - { name: 'pg_visibility',      schema: 'monitor' }
  - { name: 'pg_freespacemap',    schema: 'monitor' }
  - { name: 'pg_repack',          schema: 'monitor' }
  - name: postgres_fdw
  - name: file_fdw
  - name: btree_gist
  - name: btree_gin
  - name: pg_trgm
  - name: intagg
  - name: intarray

# - hba - #
pg_offline_query: false                       # set to true to enable offline query on this instance (instance level)
pg_reload: true                               # reload postgres after hba changes
pg_hba_rules:                                 # postgres host-based authentication rules
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

  - title: allow local read/write (local production user via pgbouncer)
    role: common
    rules:
      - local   all     +dbrole_readonly                                md5
      - host    all     +dbrole_readonly           127.0.0.1/32         md5

  - title: allow offline query (ETL,SAGA,Interactive) on offline instance
    role: offline
    rules:
      - host    all     +dbrole_offline               10.0.0.0/8        md5
      - host    all     +dbrole_offline               172.16.0.0/12     md5
      - host    all     +dbrole_offline               192.168.0.0/16    md5

pg_hba_rules_extra: []                        # extra hba rules (overwrite by cluster/instance level config)

pgbouncer_hba_rules:                          # pgbouncer host-based authentication rules
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

pgbouncer_hba_rules_extra: []                 # extra pgbouncer hba rules (overwrite by cluster/instance level config)
# pg_users: []                                # business users
# pg_databases: []                            # business databases
```

</details>


### `pg_init`

用于初始化数据库模板的Shell脚本位置，默认为`pg-init`，该脚本会被拷贝至`/pg/bin/pg-init`后执行。

默认的`pg-init` 只是预渲染SQL命令的包装：

* `/pg/tmp/pg-init-roles.sql` ： 根据`pg_default_roles`生成的默认角色创建脚本
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



### `pg_replication_username`

用于执行PostgreSQL流复制的数据库用户名

默认为`replicator`



### `pg_replication_password`

用于执行PostgreSQL流复制的数据库用户密码，必须使用明文

默认为`DBUser.Replicator`，强烈建议修改！



### `pg_monitor_username`

用于执行PostgreSQL与Pgbouncer监控任务的数据库用户名

默认为`dbuser_monitor`



### `pg_monitor_password`

用于执行PostgreSQL与Pgbouncer监控任务的数据库用户密码，必须使用明文

默认为`DBUser.Monitor`，强烈建议修改！



### `pg_admin_username`

用于执行PostgreSQL数据库管理任务（DDL变更）的数据库用户名，默认带有超级用户权限。

默认为`dbuser_dba`



### `pg_admin_password`

用于执行PostgreSQL数据库管理任务（DDL变更）的数据库用户密码，必须使用明文

默认为`DBUser.DBA`，强烈建议修改！



### `pg_default_roles`

定义了PostgreSQL中默认的[角色与用户](c-user.md)，形式为对象数组，每一个对象定义一个用户或角色。

每一个用户或角色必须指定 `name` ，其余字段均为可选项。

* `password`是可选项，如果留空则不设置密码，可以使用MD5密文密码。
* `login`, `superuser`, `createdb`, `createrole`, `inherit`, `replication`, `bypassrls` 都是布尔类型，用于设置用户属性。如果不设置，则采用系统默认值。
* 用户通过`CREATE USER`创建，所以默认具有`login`属性，如果创建的是角色，需要指定`login: false`。
* `expire_at`与`expire_in`用于控制用户过期时间，`expire_at`使用形如`YYYY-mm-DD`的日期时间戳。`expire_in`使用从现在开始的过期天数，如果`expire_in`存在则会覆盖`expire_at`选项。
* 新用户默认**不会**添加至Pgbouncer用户列表中，必须显式定义`pgbouncer: true`，该用户才会被加入到Pgbouncer用户列表。

* 用户/角色会按顺序创建，后面定义的用户可以属于前面定义的角色。

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

Pigsty定义了基于四个默认角色与四个默认用户的[认证](c-auth.md)与[权限](c-privilege.md)系统。



### `pg_default_privileges`

定义数据库模板中的默认权限。

任何由`{{ dbsu」}}`与`{{ pg_admin_username }}`创建的对象都会具有以下默认权限：

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

详细信息请参考 [默认权限](c-privilege.md#对象的权限)。



### `pg_default_schemas`

创建于模版数据库的默认模式

Pigsty默认会创建名为`monitor`的模式用于安装监控扩展。

```yml
pg_default_schemas: [monitor]                 # default schemas to be created
```



### `pg_default_extensions`

默认安装于模板数据库的扩展，对象数组。

如果没有指定`schema`字段，扩展会根据当前的`search_path`安装至对应模式中。

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



### `pg_offline_query`

实例级变量，布尔类型，默认为`false`。

设置为`true`时，无论当前实例的角色为何，用户组`dbrole_offline`都可以连接至该实例并执行离线查询。

对于实例数量较少（例如一主一从）的情况较为实用，用户可以将唯一的从库标记为`pg_offline_query = true`，从而接受ETL，慢查询与交互式访问。



### `pg_reload`

命令行参数，布尔类型，默认为`true`。

设置为`true`时，Pigsty会在生成HBA规则后立刻执行`pg_ctl reload`应用。

当您希望生成`pg_hba.conf`文件，并手工比较后再应用生效时，可以指定`-e pg_reload=false`来禁用它。



### `pg_hba_rules`

设置数据库的客户端IP黑白名单规则。对象数组，每一个对象都代表一条规则。

每一条规则由三部分组成：

* `title`，规则标题，会转换为HBA文件中的注释
* `role`，应用角色，`common`代表应用至所有实例，其他取值（如`replica`, `offline`）则仅会安装至匹配的角色上。例如`role='replica'`代表这条规则只会应用到`pg_role == 'replica'` 的实例上。
* `rules`，字符串数组，每一条记录代表一条最终写入`pg_hba.conf`的规则。

作为一个特例，`role == 'offline'` 的HBA规则，还会额外安装至 `pg_offline_query == true` 的实例上。

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

建议在全局配置统一的`pg_hba_rules`，针对特定集群使用`pg_hba_rules_extra`进行额外定制。




### `pg_hba_rules_extra`

与`pg_hba_rules`类似，但通常用于集群层面的HBA规则设置。

`pg_hba_rules_extra` 会以同样的方式 **追加** 至`pg_hba.conf`中。

如果用户需要彻底**覆写**集群的HBA规则，即不想继承全局HBA配置，则应当在集群层面配置`pg_hba_rules`并覆盖全局配置。



### `pgbouncer_hba_rules`

与`pg_hba_rules`类似，用于Pgbouncer的HBA规则设置。

默认的Pgbouncer HBA规则很简单，用户可以按照自己的需求进行定制。

默认的Pgbouncer HBA规则较为宽松：

1. 允许从**本地**使用密码登陆
2. 允许从内网网断使用密码登陆

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



### `pgbouncer_hba_rules_extra`

与`pg_hba_rules_extras`类似，用于在集群层次对Pgbouncer的HBA规则进行额外配置。



### 业务模板

以下两个参数属于**业务模板**，用户应当在这里定义所需的业务用户与业务数据库。

在这里定义的用户与数据库，会在以下两个步骤中完成应用，不仅仅包括数据库中的用户与DB，还有Pgbouncer连接池中的对应配置。

```yaml
./pgsql.yml --tags=pg_biz_init,pg_biz_pgbouncer
```



### `pg_users`

通常用于在数据库集群层面定义业务用户，与 [`pg_default_roles`](#pg_default_roles) 采用相同的形式。

对象数组，每个对象定义一个业务用户。用户名`name`字段为必选项，密码可以使用MD5密文密码

用户可以通过`roles`字段为业务用户添加默认权限组：

* `dbrole_readonly`：默认生产只读用户，具有全局只读权限。（只读生产访问）
* `dbrole_offline`：默认离线只读用户，在特定实例上具有只读权限。（离线查询，个人账号，ETL）
* `dbrole_readwrite`：默认生产读写用户，具有全局CRUD权限。（常规生产使用）
* `dbrole_admin`：默认生产管理用户，具有执行DDL变更的权限。（管理员）

应当为生产账号配置 `pgbouncer: true`，允许其通过连接池访问，普通用户不应当通过连接池访问数据库。

下面是一个创建业务账号的例子：

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



### `pg_databases`

对象数组，每个对象定义一个**业务数据库**。每个数据库定义中，数据库名称 `name` 为必选项，其余均为可选项。

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




------------------

## `PG_EXPORTER`

<details>
<summary>PG_EXPORTER参数默认值</summary>

```yaml
# - pg exporter - #
pg_exporter_config: pg_exporter.yml           # default config files for pg_exporter
pg_exporter_enabled: true                     # setup pg_exporter on instance
pg_exporter_port: 9630                        # default port for pg exporter
pg_exporter_params: 'host=/var/run/postgresql&sslmode=disable' # url query parameters for pg_exporter
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
```

</details>





### `pg_exporter_config`

`pg_exporter`使用的默认配置文件，定义了Pigsty中的数据库与连接池监控指标。

默认为 [`pg_exporter.yml`](https://github.com/Vonng/pigsty/blob/master/roles/monitor/files/pg_exporter.yml)

Pigsty使用的PG Exporter配置文件默认从PostgreSQL 10.0 开始提供支持，目前支持至最新的PG 14版本



### `pg_exporter_enabled`

是否安装并配置`pg_exporter`，默认为`true`



### `pg_exporter_url`

PG Exporter用于连接至数据库的PGURL，应当为访问`postgres`管理数据库的URL。

可选参数，默认为空字符串，如果配置了`pg_exporter_url`选项，则会直接使用该URL作为监控连接串。
否则Pigsty将使用以下规则生成监控的目标URL：

```bash
PG_EXPORTER_URL='postgres://{{ pg_monitor_username }}:{{ pg_monitor_password }}@:{{ pg_port }}/postgres?host={{ pg_localhost }}&sslmode=disable'
```

该选项以环境变量的方式配置于 `/etc/default/pg_exporter` 中。

注意：当您只需要监控某一个特定业务数据库时，您可以直接使用该数据库的PGURL。
如果您希望监控某一个数据库实例上**所有**的业务数据库，则建议使用管理数据库`postgres`的PGURL。



### `pg_exporter_auto_discovery`

PG Exporter v0.4 后的新特性：启用自动数据库发现，默认开启。

开启后，PG Exporter会自动检测目标实例中数据库列表的变化，并为每一个数据库创建一条抓取连接

关闭时，库内对象监控不可用。（如果您不希望在监控系统中暴露业务相关数据，可以关闭此特性）

!> 注意如果您有很多数据库（100+），或数据库内对象非常多（几k，十几k），请审慎评估对象监控产生的开销。



### `pg_exporter_exclude_database`

逗号分隔的数据库名称列表，启用自动数据库发现时，此列表中的数据库**不会被监控**（被排除在监控对象之外）。



### `pg_exporter_include_database`

逗号分隔的数据库名称列表，启用自动数据库发现时，不在此列表中的数据库不会被监控（显式指定需要监控的数据库）。



### `pgbouncer_exporter_enabled`

是否安装并配置`pgbouncer_exporter`，默认为`true`



### `pg_exporter_port`

`pg_exporter`监听的端口，默认端口`9630`



### `pgbouncer_exporter_port`

`pgbouncer_exporter`监听的端口，默认端口`9631`



### `pgbouncer_exporter_url`

PGBouncer Exporter用于连接至数据库的URL，应当为访问`pgbouncer`管理数据库的URL。

可选参数，默认为空字符串。

Pigsty默认使用以下规则生成监控的目标URL，如果配置了`pgbouncer_exporter_url`选项，则会直接使用该URL作为连接串。

```bash
PG_EXPORTER_URL='postgres://{{ pg_monitor_username }}:{{ pg_monitor_password }}@:{{ pgbouncer_port }}/pgbouncer?host={{ pg_localhost }}&sslmode=disable'
```

该选项以环境变量的方式配置于 `/etc/default/pgbouncer_exporter` 中。



------------------


----------------

## `SERVICE`

<details>
<summary>SERVICE参数默认值</summary>

```yaml
#------------------------------------------------------------------------------
# SERVICE PROVISION
#------------------------------------------------------------------------------
pg_weight: 100              # default load balance weight (instance level)

# - service - #
pg_services:               # how to expose postgres service in cluster?
  # primary service will route {ip|name}:5433 to primary pgbouncer (5433->6432 rw)
  - name: primary           # service name {{ pg_cluster }}-primary
    src_ip: "*"
    src_port: 5433
    dst_port: pgbouncer     # 5433 route to pgbouncer
    check_url: /primary     # primary health check, success when instance is primary
    selector: "[]"          # select all instance as primary service candidate

  # replica service will route {ip|name}:5434 to replica pgbouncer (5434->6432 ro)
  - name: replica           # service name {{ pg_cluster }}-replica
    src_ip: "*"
    src_port: 5434
    dst_port: pgbouncer
    check_url: /read-only   # read-only health check. (including primary)
    selector: "[]"          # select all instance as replica service candidate
    selector_backup: "[? pg_role == `primary` || pg_role == `offline` ]"
    # primary are used as backup server in replica service

  # default service will route {ip|name}:5436 to primary postgres (5436->5432 primary)
  - name: default           # service's actual name is {{ pg_cluster }}-default
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

  # offline service will route {ip|name}:5438 to offline postgres (5438->5432 offline)
  - name: offline           # service name {{ pg_cluster }}-offline
    src_ip: "*"
    src_port: 5438
    dst_port: postgres
    check_url: /replica     # offline MUST be a replica
    selector: "[? pg_role == `offline` || pg_offline_query ]"         # instances with pg_role == 'offline' or instance marked with 'pg_offline_query == true'
    selector_backup: "[? pg_role == `replica` && !pg_offline_query]"  # replica are used as backup server in offline service

pg_services_extra: []        # extra services to be added

# - haproxy - #
haproxy_enabled: true                         # enable haproxy among every cluster members
haproxy_reload: true                          # reload haproxy after config
haproxy_admin_auth_enabled: false             # enable authentication for haproxy admin?
haproxy_admin_username: admin                 # default haproxy admin username
haproxy_admin_password: pigsty                # default haproxy admin password
haproxy_exporter_port: 9101                   # default admin/exporter port
haproxy_client_timeout: 24h                   # client side connection timeout
haproxy_server_timeout: 24h                   # server side connection timeout

# - vip - #
vip_mode: none                                # none | l2 | l4 (l4 not implemented)
vip_reload: true                              # whether reload service after config
# vip_address: 127.0.0.1                      # virtual ip address ip (l2 or l4)
# vip_cidrmask: 24                            # virtual ip address cidr mask (l2 only)
# vip_interface: eth0                         # virtual ip network interface (l2 only)

# - dns - #                                   # NOT IMPLEMENTED
# dns_mode: vip                               # vip|all|selector: how to resolve cluster DNS?
# dns_selector: '[]'                          # if dns_mode == vip, filter instances been resolved
```

</details>





### `pg_weight`

当执行负载均衡时，数据库实例的相对权重。默认为100



### `pg_services`

由[服务定义](c-service.md#自定义服务)对象构成的数组，定义了每一个数据库集群中对外暴露的服务。

每一个集群都可以定义多个服务，每个服务包含任意数量的集群成员，服务通过**端口**进行区分。

每一个服务的定义结构如下例所示：

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

#### **必选项目**

* **名称（`service.name`）**：

  **服务名称**，服务的完整名称以数据库集群名为前缀，以`service.name`为后缀，通过`-`连接。例如在`pg-test`集群中`name=primary`的服务，其完整服务名称为`pg-test-primary`。

* **端口（`service.port`）**：

  在Pigsty中，服务默认采用NodePort的形式对外暴露，因此暴露端口为必选项。但如果使用外部负载均衡服务接入方案，您也可以通过其他的方式区分服务。

* **选择器（`service.selector`）**：

  **选择器**指定了服务的实例成员，采用JMESPath的形式，从所有集群实例成员中筛选变量。默认的`[]`选择器会选取所有的集群成员。



#### 可选项目

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



### `pg_services_extra`

由服务定义对象构成的数组，在集群层面定义，追加至全局的服务定义中。

如果用户希望为某一个数据库集群创建特殊的服务，例如单独为某一套带有延迟从库的集群创建特殊的服务，则可以使用本配置项。



### `haproxy_enabled`

是否启用Haproxy组件

Pigsty默认会在所有数据库节点上部署Haproxy，您可以通过覆盖实例级变量，仅在特定实例/节点上启用Haproxy负载均衡器。



### `haproxy_admin_auth_enabled`

是否启用为Haproxy管理界面启用基本认证

默认不启用，建议在生产环境启用，或在Nginx或其他接入层添加访问控制。



### `haproxy_admin_username`

启用Haproxy管理界面认证默认用户名，默认为`admin`



### `haproxy_admin_password`

启用Haproxy管理界面认证默认密码，默认为`admin`



### `haproxy_client_timeout`

Haproxy客户端连接超时，默认为3小时



### `haproxy_server_timeout`

Haproxy服务端连接超时，默认为3小时



### `haproxy_exporter_port`

Haproxy管理界面与监控指标暴露端点所监听的端口。默认端口为`9101`。



### `vip_mode`

VIP的模式，枚举类型，可选值包括：

* `none`：不设置VIP，默认选项。
* `l2`：配置绑定在主库上的二层VIP（需要所有成员位于同一个二层网络广播域中）
* `l4` ：通过外部L4负载均衡器进行流量分发。（未纳入Pigsty当前实现中）

VIP用于确保**读写服务**与**负载均衡器**的高可用，当使用L2 VIP时，Pigsty的VIP由`vip-manager`托管，会绑定在**集群主库**上。

这意味着您始终可以通过VIP访问集群主库，或者通过VIP访问主库上的负载均衡器（如果主库的压力很大，这样做可能会有性能压力）。

注意，您必须保证VIP候选实例处于同一个二层网络（VLAN、交换机）下。



### `vip_reload`

是否在执行任务时重载VIP配置？默认重载


### `vip_address`

VIP地址，可用于L2或L4 VIP。

`vip_address`没有默认值，用户必须为每一个集群显式指定并分配VIP地址



### `vip_cidrmask`

VIP的CIDR网络长度，仅当使用L2 VIP时需要。

`vip_cidrmask`没有默认值，用户必须为每一个集群显式指定VIP的网络CIDR。



### `vip_interface`

VIP网卡名称，仅当使用L2 VIP时需要。

默认为`eth0`，用户必须为每一个集群/实例指明VIP使用的网卡名称。


### `dns_mode`

用于控制注册DNS域名的模式

保留参数，目前未实际使用。


### `dns_selector`

用于选择DNS域名解析到的实例列表

保留参数，目前未实际使用。



### HAProxy专有配置项

这些参数现在[**服务**](c-service.md#服务)中定义，使用`service.haproxy`来覆盖实例的参数配置。


### `maxconn`

HAProxy最大前后端连接数，默认为3000


### `balance`

haproxy负载均衡所使用的算法，可选策略为`roundrobin`与`leastconn`

默认为`roundrobin`



### `default_server_options`

Haproxy 后端服务器实例的默认选项

默认为： `'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'`
