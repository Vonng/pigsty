# PostgreSQL安装参数

PG Install 部分负责在一台装有基本软件的机器上完成所有PostgreSQL依赖项的安装。用户可以配置数据库超级用户的名称、ID、权限、访问，配置安装所用的源，配置安装地址，安装的版本，所需的软件包与扩展插件。

这里的大多数参数只需要在整体升级数据库大版本时修改，用户可以通过`pg_version`指定需要安装的软件版本，并在集群层面进行覆盖，为不同的集群安装不同的数据库版本。

## 参数概览

|                     名称                      |    类型    | 层级 | 说明                 |
| :-------------------------------------------: | :--------: | :--: | -------------------- |
|              [pg_dbsu](#pg_dbsu)              |  `string`  | G/C  | PG操作系统超级用户   |
|          [pg_dbsu_uid](#pg_dbsu_uid)          |  `number`  | G/C  | 超级用户UID          |
|         [pg_dbsu_sudo](#pg_dbsu_sudo)         |   `enum`   | G/C  | 超级用户的Sudo权限   |
|         [pg_dbsu_home](#pg_dbsu_home)         |  `string`  | G/C  | 超级用户的家目录     |
| [pg_dbsu_ssh_exchange](#pg_dbsu_ssh_exchange) |   `bool`   | G/C  | 是否交换超级用户密钥 |
|           [pg_version](#pg_version)           |  `string`  | G/C  | 安装的数据库大版本   |
|            [pgdg_repo](#pgdg_repo)            |   `bool`   | G/C  | 是否添加PG官方源？   |
|          [pg_add_repo](#pg_add_repo)          |   `bool`   | G/C  | 是否添加PG相关源？   |
|           [pg_bin_dir](#pg_bin_dir)           |  `string`  | G/C  | PG二进制目录         |
|          [pg_packages](#pg_packages)          | `string[]` | G/C  | 安装的PG软件包列表   |
|        [pg_extensions](#pg_extensions)        | `string[]` | G/C  | 安装的PG插件列表     |



## 默认参数

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

# - postgres packages - #
pg_version: 13                                # default postgresql version to be installed
pgdg_repo: false                              # add pgdg official repo before install (in case of no local repo available)
pg_add_repo: false                            # add postgres related repo before install (useful if you want a simple install)
pg_bin_dir: /usr/pgsql/bin                    # postgres binary dir, default is /usr/pgsql/bin, which use /usr/pgsql -> /usr/pgsql-{ver}
pg_packages:                                  # postgresql related packages. `${pg_version} will be replaced by `pg_version`
  - postgresql${pg_version}*                  # postgresql kernel packages
  - postgis31_${pg_version}*                  # postgis
  - citus_${pg_version}                       # citus
  - timescaledb_${pg_version}                 # timescaledb
  - pgbouncer patroni pg_exporter pgbadger    # 3rd utils
  - patroni patroni-consul patroni-etcd pgbouncer pgbadger pg_activity
  - python3 python3-psycopg2 python36-requests python3-etcd python3-consul
  - python36-urllib3 python36-idna python36-pyOpenSSL python36-cryptography

pg_extensions:                                # postgresql extensions. `${pg_version} will be replaced by `pg_version`
  - pg_repack${pg_version} pg_qualstats${pg_version} pg_stat_kcache${pg_version} wal2json${pg_version}
  # - ogr_fdw${pg_version} mysql_fdw_${pg_version} redis_fdw_${pg_version} mongo_fdw${pg_version} hdfs_fdw_${pg_version}
  # - count_distinct${version}  ddlx_${version}  geoip${version}  orafce${version}
  # - hypopg_${version}  ip4r${version}  jsquery_${version}  logerrors_${version}  periods_${version}  pg_auto_failover_${version}  pg_catcheck${version}
  # - pg_fkpart${version}  pg_jobmon${version}  pg_partman${version}  pg_prioritize_${version}  pg_track_settings${version}  pgaudit15_${version}
  # - pgcryptokey${version}  pgexportdoc${version}  pgimportdoc${version}  pgmemcache-${version}  pgmp${version}  pgq-${version}  pgquarrel pgrouting_${version}
  # - pguint${version}  pguri${version}  prefix${version}   safeupdate_${version}  semver${version}   table_version${version}  tdigest${version}

```





## 参数详解

### pg_dbsu

数据库默认使用的操作系统用户（超级用户）的用户名称，默认为`postgres`，不建议修改。




### pg_dbsu_uid

数据库默认使用的操作系统用户（超级用户）的UID，默认为`26`。

与CentOS下PostgreSQL官方RPM包的配置一致，不建议修改。



### pg_dbsu_sudo

数据库超级用户的默认权限：

* `none`：没有sudo权限
* `limit`：有限的sudo权限，可以执行数据库相关组件的systemctl命令，默认
* `all`：带有完整`sudo`权限，但需要密码。
* `nopass`：不需要密码的完整`sudo`权限（不建议）



### pg_dbsu_home

数据库超级用户的家目录，默认为`/var/lib/pgsql`




### pg_dbsu_ssh_exchange

是否在执行的机器之间交换超级用户的SSH公私钥



### pg_version

希望安装的PostgreSQL版本，默认为13

建议在集群级别按需覆盖此变量。




### pgdg_repo

标记，是否使用PostgreSQL官方源？默认不使用

使用该选项，可以在没有本地源的情况下，直接从互联网官方源下载安装PostgreSQL相关软件包。



### pg_add_repo

如果使用，则会在安装PostgreSQL前添加PGDG的官方源

启用此选项，则可以在未执行基础设施初始化的前提下直接执行数据库初始化，尽管可能会很慢，但对于缺少基础设施的场景尤为实用。



### pg_bin_dir

PostgreSQL二进制目录

默认为`/usr/pgsql/bin/`，这是一个安装过程中手动创建的软连接，指向安装的具体Postgres版本目录。

例如`/usr/pgsql -> /usr/pgsql-14`。




### pg_packages

默认安装的PostgreSQL软件包

软件包中的`${pg_version}`会被替换为实际安装的PostgreSQL版本。

当您为某一个特定集群指定特殊的`pg_version`时，可以相应在集群层面调整此参数（例如安装PG14 beta时某些扩展还不存在）

```bash
- postgresql${pg_version}*                  # postgresql kernel packages
- postgis31_${pg_version}*                  # postgis
- citus_${pg_version}                       # citus
- timescaledb_${pg_version}                 # timescaledb
- pgbouncer patroni pg_exporter pgbadger    # 3rd utils
- patroni patroni-consul patroni-etcd pgbouncer pgbadger pg_activity
- python3 python3-psycopg2 python36-requests python3-etcd python3-consul
- python36-urllib3 python36-idna python36-pyOpenSSL python36-cryptography
```

### pg_extensions

需要安装的PostgreSQL扩展插件软件包

软件包中的`${pg_version}`会被替换为实际安装的PostgreSQL版本。

默认安装的插件包括：

```sql
pg_repack${pg_version}
pg_qualstats${pg_version}
pg_stat_kcache${pg_version}
wal2json${pg_version}
```

按需启用，但强烈建议安装`pg_repack`扩展。