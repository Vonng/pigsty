# PostgreSQL 扩展插件

扩展是 PostgreSQL 的灵魂，而 Pigsty 深度整合了 PostgreSQL 生态的核心扩展插件，为您提供开箱即用的分布式的时序地理空间图文向量数据库能力！详见[扩展列表](PGSQL-EXTENSION#扩展列表)。

Pigsty 收录了超过 140 个 PostgreSQL 扩展插件，并编译打包整合维护了许多官方 PGDG 源没有收录的扩展。并且通过充分的测试确保所有这些插件可以正常协同工作。其中还包括了一些非常强力的组件，例如：
您可以使用 [PostGIS](https://postgis.net/) 处理地理空间数据，使用 [TimescaleDB](https://www.timescale.com/) 分析时序/事件流数据，
使用 [Citus](https://www.citusdata.com/) 将单机数据库原地改造为水平扩展的分布式集群，使用 [PGVector](https://github.com/pgvector/pgvector) 存储并搜索 AI 嵌入，
使用 [Apache AGE](https://age.apache.org/) 进行图数据存储与检索实现 Neo4J 的效果，使用 [zhparser](https://github.com/amutu/zhparser) 进行中文分词实现 ElasticSearch 的效果。

绝大多数插件插件都已经收录放置在基础设施节点上的本地软件源中，可以直接通过 PGSQL [集群配置](#扩展安装) 自动启用，或使用 `yum` 命令[手工安装](#手工安装扩展)。Pigsty 还包含了完整的编译环境与基础设施，允许您方便地自行[编译加装](#扩展编译)其他未收录的扩展。



----------------

## 扩展列表

当前，Pigsty 中的 PostgreSQL 主版本 15 提供以下扩展插件（其他大版本仅包含核心扩展，但可自行从上游下载）。

来源包括：PostgreSQL 自带的 CONTRIB 模块，PGDG 官方源提供的扩展，以及 `PIGSTY` 打包维护的扩展。分类包括

* `FEAT`：功能特性
* `GIS`：地理空间
* `TYPE`：数据类型
* `FUNC`：函数与存储过程
* `INDEX`：索引访问方法
* `LANG`：编程语言支持
* `SHARD`：水平分片
* `ADMIN`：管理工具
* `AUDIT`：审计工具
* `FDW`：外部数据源包装与对接
* `STAT`：统计信息

其中，名称加粗的为核心扩展插件，包括：`postgis`, `timescaledb`, `citus`, `age`, `vector`, `embedding`, `zhparser`, `pg_repack`, `wal2json`, `passwordcracklib` ,`pg_cron`



| name                         | version | source     | type   | comment                                                      |
| ---------------------------- | :-----: | :--------: | :----: | ------------------------------------------------------------ |
| **age**                      | 1.4.0   | PIGSTY      | FEAT      | Apache AGE graph database extension                          |
| **embedding**                | 0.3.6   | PIGSTY      | FEAT      | Vector similarity search with the HNSW algorithm             |
| **http**                     | 1.6     | PIGSTY      | FEAT      | HTTP client for PostgreSQL, allows web page retrieval inside the database. |
| pg_tle                       | 1.2.0   | PIGSTY      | FEAT      | Trusted Language Extensions for PostgreSQL                   |
| roaringbitmap                | 0.5     | PIGSTY      | FEAT      | support for Roaring Bitmaps                                  |
| **zhparser**                 | 2.2     | PIGSTY      | FEAT      | a parser for full-text search of Chinese                     |
| credcheck                    | 2.1.0   | PGDG        | ADMIN     | credcheck - postgresql plain text credential checker         |
| **pg_cron**                  | 1.5     | PGDG        | ADMIN     | Job scheduler for PostgreSQL                                 |
| pg_background                | 1.0     | PGDG        | ADMIN | Run SQL queries in the background                            |
| pg_jobmon                    | 1.4.1   | PGDG        | ADMIN     | Extension for logging and monitoring functions in PostgreSQL |
| pg_readonly                  | 1.0.0   | PGDG        | ADMIN     | cluster database read only                                   |
| **pg_repack**                | 1.4.8   | PGDG        | ADMIN     | Reorganize tables in PostgreSQL databases with minimal locks |
| pg_squeeze                   | 1.5     | PGDG        | ADMIN     | A tool to remove unused space from a relation.               |
| pgfincore                    | 1.2     | PGDG        | ADMIN     | examine and manage the os buffer cache                       |
| **pglogical**                | 2.4.3   | PGDG        | ADMIN     | PostgreSQL Logical Replication                               |
| pglogical_origin             | 1.0.0   | PGDG        | ADMIN     | Dummy extension for compatibility when upgrading from Postgres 9.4 |
| prioritize                   | 1.0     | PGDG        | ADMIN     | get and set the priority of PostgreSQL backends              |
| set_user                     | 4.0.1   | PGDG        | AUDIT     | similar to SET ROLE but with added logging                   |
| **passwordcracklib**         | 3.0.0   | PGDG        | AUDIT     | Enforce password policy                                      |
| pgaudit                      | 1.7     | PGDG        | AUDIT     | provides auditing functionality                              |
| pgcryptokey                  | 1.0     | PGDG        | AUDIT     | cryptographic key management                                 |
| hdfs_fdw                     | 2.0.5   | PGDG        | FDW       | foreign-data wrapper for remote hdfs servers                 |
| mongo_fdw                    | 1.1     | PGDG        | FDW       | foreign data wrapper for MongoDB access                      |
| multicorn                    | 2.4     | PGDG        | FDW       | Multicorn2 Python3.6+ bindings for Postgres 11++ Foreign Data Wrapper |
| mysql_fdw                    | 1.2     | PGDG        | FDW       | Foreign data wrapper for querying a MySQL server             |
| pgbouncer_fdw                | 0.4     | PGDG        | FDW       | Extension for querying pgbouncer stats from normal SQL views & running pgbouncer commands from normal SQL functions |
| sqlite_fdw                   | 1.1     | PGDG        | FDW       | SQLite Foreign Data Wrapper                                  |
| tds_fdw                      | 2.0.3   | PGDG        | FDW       | Foreign data wrapper for querying a TDS database (Sybase or Microsoft SQL Server) |
| emaj                         | 4.2.0   | PGDG        | FEAT      | E-Maj extension enables fine-grained write logging and time travel on subsets of the database. |
| periods                      | 1.2     | PGDG        | FEAT      | Provide Standard SQL functionality for PERIODs and SYSTEM VERSIONING |
| pg_ivm                       | 1.5     | PGDG        | FEAT      | incremental view maintenance on PostgreSQL                   |
| pgq                          | 3.5     | PGDG        | FEAT      | Generic queue for PostgreSQL                                 |
| pgsodium                     | 3.1.8   | PGDG        | FEAT      | Postgres extension for libsodium functions                   |
| **timescaledb**              | 2.11.2  | PGDG        | FEAT      | Enables scalable inserts and complex queries for time-series data (Apache 2 Edition) |
| **wal2json**                 | 2.5.1   | PGDG        | FEAT      | Capture JSON format CDC change via logical decoding          |
| **vector**                   | 0.5.0   | PGDG        | FEAT      | vector data type and ivfflat access method                   |
| count_distinct               | 3.0.1   | PGDG        | FUNC      | An alternative to COUNT(DISTINCT ...) aggregate, usable with HashAggregate |
| ddlx                         | 0.23    | PGDG        | FUNC      | DDL eXtractor functions                                      |
| extra_window_functions       | 1.0     | PGDG        | FUNC      |                                                              |
| mysqlcompat                  | 0.0.7   | PGDG        | FUNC      | MySQL compatibility functions                                |
| orafce                       | 4.5     | PGDG        | FUNC      | Functions and operators that emulate a subset of functions and packages from the Oracle RDBMS |
| pgsql_tweaks                 | 0.10.0  | PGDG        | FUNC      | Some functions and views for daily usage                     |
| tdigest                      | 1.4.0   | PGDG        | FUNC      | Provides tdigest aggregate function.                         |
| topn                         | 2.4.0   | PGDG        | FUNC      | type for top-n JSONB                                         |
| unaccent                     | 1.1     | PGDG        | FUNC      | text search dictionary that removes accents                  |
| address_standardizer         | 3.3.3   | PGDG        | GIS       | Used to parse an address into constituent elements. Generally used to support geocoding address normalization step. |
| address_standardizer_data_us | 3.3.3   | PGDG        | GIS       | Address Standardizer US dataset example                      |
| **postgis**                  | 3.3.3   | PGDG        | GIS       | PostGIS geometry and geography spatial types and functions   |
| postgis_raster               | 3.3.3   | PGDG        | GIS       | PostGIS raster types and functions                           |
| postgis_sfcgal               | 3.3.3   | PGDG        | GIS       | PostGIS SFCGAL functions                                     |
| postgis_tiger_geocoder       | 3.3.3   | PGDG        | GIS       | PostGIS tiger geocoder and reverse geocoder                  |
| postgis_topology             | 3.3.3   | PGDG        | GIS       | PostGIS topology spatial types and functions                 |
| amcheck                      | 1.3     | PGDG        | INDEX     | functions for verifying relation integrity                   |
| bloom                        | 1.0     | PGDG        | INDEX     | bloom access method - signature file based index             |
| hll                          | 2.16    | PGDG        | INDEX     | type for storing hyperloglog data                            |
| pgtt                         | 2.10.0  | PGDG        | INDEX     | Extension to add Global Temporary Tables feature to PostgreSQL |
| rum                          | 1.3     | PGDG        | INDEX     | RUM index access method                                      |
| hstore_plperl                | 1.0     | PGDG        | LANG      | transform between hstore and plperl                          |
| hstore_plperlu               | 1.0     | PGDG        | LANG      | transform between hstore and plperlu                         |
| plpgsql_check                | 2.3     | PGDG        | LANG      | extended check for plpgsql functions                         |
| plsh                         | 2       | PGDG        | LANG      | PL/sh procedural language                                    |
| **citus**                    | 12.0-1  | PGDG        | SHARD     | Citus distributed database                                   |
| citus_columnar               | 11.3-1  | PGDG        | SHARD     | Citus Columnar extension                                     |
| pg_fkpart                    | 1.7     | PGDG        | SHARD     | Table partitioning by foreign key utility                    |
| pg_partman                   | 4.7.3   | PGDG        | SHARD     | Extension to manage partitioned tables by time or ID         |
| plproxy                      | 2.10.0  | PGDG        | SHARD     | Database partitioning implemented as procedural language     |
| hypopg                       | 1.4.0   | PGDG        | STAT      | Hypothetical indexes for PostgreSQL                          |
| logerrors                    | 2.1     | PGDG        | STAT      | Function for collecting statistics about messages in logfile |
| pg_auth_mon                  | 1.1     | PGDG        | STAT      | monitor connection attempts per user                         |
| pg_permissions               | 1.1     | PGDG        | STAT      | view object permissions and compare them with the desired state |
| pg_qualstats                 | 2.0.4   | PGDG        | STAT      | An extension collecting statistics about quals               |
| pg_stat_kcache               | 2.2.2   | PGDG        | STAT      | Kernel statistics gathering                                  |
| pg_stat_monitor              | 2.0     | PGDG        | STAT      | The pg_stat_monitor is a PostgreSQL Query Performance Monitoring tool, based on PostgreSQL contrib module pg_stat_statements. pg_stat_monitor provides aggregated statistics, client information, plan details including plan, and histogram information. |
| pg_store_plans               | 1.7     | PGDG        | STAT      | track plan statistics of all SQL statements executed         |
| pg_track_settings            | 2.1.2   | PGDG        | STAT      | Track settings changes                                       |
| pg_wait_sampling             | 1.1     | PGDG        | STAT      | sampling based statistics of wait events                     |
| pldbgapi                     | 1.1     | PGDG        | STAT      | server-side support for debugging PL/pgSQL functions         |
| plprofiler                   | 4.2     | PGDG        | STAT      | server-side support for profiling PL/pgSQL functions         |
| powa                         | 4.1.4   | PGDG        | STAT      | PostgreSQL Workload Analyser-core                            |
| system_stats                 | 1.0     | PGDG        | STAT      | System statistic functions for PostgreSQL                    |
| citext                       | 1.6     | PGDG        | TYPE      | data type for case-insensitive character strings             |
| geoip                        | 0.2.4   | PGDG        | TYPE      | An IP geolocation extension (a wrapper around the MaxMind GeoLite dataset) |
| ip4r                         | 2.4     | PGDG        | TYPE      | NULL                                                         |
| pg_uuidv7                    | 1.1     | PGDG        | TYPE      | pg_uuidv7: create UUIDv7 values in postgres                  |
| pgmp                         | 1.1     | PGDG        | TYPE      | Multiple Precision Arithmetic extension                      |
| semver                       | 0.32.1  | PGDG        | TYPE      | Semantic version data type                                   |
| timestamp9                   | 1.3.0   | PGDG        | TYPE      | timestamp nanosecond resolution                              |
| unit                         | 7       | PGDG        | TYPE      | SI units extension                                           |
| lo                           | 1.1     | CONTRIB     | ADMIN     | Large Object maintenance                                     |
| old_snapshot                 | 1.0     | CONTRIB     | ADMIN     | utilities in support of old_snapshot_threshold               |
| pg_prewarm                   | 1.2     | CONTRIB     | ADMIN     | prewarm relation data                                        |
| pg_surgery                   | 1.0     | CONTRIB     | ADMIN     | extension to perform surgery on a damaged relation           |
| dblink                       | 1.2     | CONTRIB     | FDW       | connect to other PostgreSQL databases from within a database |
| file_fdw                     | 1.0     | CONTRIB     | FDW       | foreign-data wrapper for flat file access                    |
| postgres_fdw                 | 1.1     | CONTRIB     | FDW       | foreign-data wrapper for remote PostgreSQL servers           |
| autoinc                      | 1.0     | CONTRIB     | FUNC      | functions for autoincrementing fields                        |
| dict_int                     | 1.0     | CONTRIB     | FUNC      | text search dictionary template for integers                 |
| dict_xsyn                    | 1.0     | CONTRIB     | FUNC      | text search dictionary template for extended synonym processing |
| earthdistance                | 1.1     | CONTRIB     | FUNC      | calculate great-circle distances on the surface of the Earth |
| fuzzystrmatch                | 1.1     | CONTRIB     | FUNC      | determine similarities and distance between strings          |
| insert_username              | 1.0     | CONTRIB     | FUNC      | functions for tracking who changed a table                   |
| intagg                       | 1.1     | CONTRIB     | FUNC      | integer aggregator and enumerator (obsolete)                 |
| intarray                     | 1.5     | CONTRIB     | FUNC      | functions, operators, and index support for 1-D arrays of integers |
| moddatetime                  | 1.0     | CONTRIB     | FUNC      | functions for tracking last modification time                |
| pg_trgm                      | 1.6     | CONTRIB     | FUNC      | text similarity measurement and index searching based on trigrams |
| pgcrypto                     | 1.3     | CONTRIB     | FUNC      | cryptographic functions                                      |
| refint                       | 1.0     | CONTRIB     | FUNC      | functions for implementing referential integrity (obsolete)  |
| tablefunc                    | 1.0     | CONTRIB     | FUNC      | functions that manipulate whole tables, including crosstab   |
| tcn                          | 1.0     | CONTRIB     | FUNC      | Triggered change notifications                               |
| tsm_system_rows              | 1.0     | CONTRIB     | FUNC      | TABLESAMPLE method which accepts number of rows as a limit   |
| tsm_system_time              | 1.0     | CONTRIB     | FUNC      | TABLESAMPLE method which accepts time in milliseconds as a limit |
| uuid-ossp                    | 1.1     | CONTRIB     | FUNC      | generate universally unique identifiers (UUIDs)              |
| btree_gin                    | 1.3     | CONTRIB     | INDEX     | support for indexing common datatypes in GIN                 |
| btree_gist                   | 1.7     | CONTRIB     | INDEX     | support for indexing common datatypes in GiST                |
| bool_plperl                  | 1.0     | CONTRIB     | LANG      | transform between bool and plperl                            |
| bool_plperlu                 | 1.0     | CONTRIB     | LANG      | transform between bool and plperlu                           |
| hstore_plpython3u            | 1.0     | CONTRIB     | LANG      | transform between hstore and plpython3u                      |
| jsonb_plperl                 | 1.0     | CONTRIB     | LANG      | transform between jsonb and plperl                           |
| jsonb_plperlu                | 1.0     | CONTRIB     | LANG      | transform between jsonb and plperlu                          |
| jsonb_plpython3u             | 1.0     | CONTRIB     | LANG      | transform between jsonb and plpython3u                       |
| ltree_plpython3u             | 1.0     | CONTRIB     | LANG      | transform between ltree and plpython3u                       |
| plperl                       | 1.0     | CONTRIB     | LANG      | PL/Perl procedural language                                  |
| plperlu                      | 1.0     | CONTRIB     | LANG      | PL/PerlU untrusted procedural language                       |
| plpgsql                      | 1.0     | CONTRIB     | LANG      | PL/pgSQL procedural language                                 |
| plpython3u                   | 1.0     | CONTRIB     | LANG      | PL/Python3U untrusted procedural language                    |
| pltcl                        | 1.0     | CONTRIB     | LANG      | PL/Tcl procedural language                                   |
| pltclu                       | 1.0     | CONTRIB     | LANG      | PL/TclU untrusted procedural language                        |
| pageinspect                  | 1.11    | CONTRIB     | STAT      | inspect the contents of database pages at a low level        |
| pg_buffercache               | 1.3     | CONTRIB     | STAT      | examine the shared buffer cache                              |
| pg_freespacemap              | 1.2     | CONTRIB     | STAT      | examine the free space map (FSM)                             |
| pg_stat_statements           | 1.10    | CONTRIB     | STAT      | track planning and execution statistics of all SQL statements executed |
| pg_visibility                | 1.2     | CONTRIB     | STAT      | examine the visibility map (VM) and page-level visibility info |
| pg_walinspect                | 1.0     | CONTRIB     | STAT      | functions to inspect contents of PostgreSQL Write-Ahead Log  |
| pgrowlocks                   | 1.2     | CONTRIB     | STAT      | show row-level locking information                           |
| pgstattuple                  | 1.5     | CONTRIB     | STAT      | show tuple-level statistics                                  |
| sslinfo                      | 1.2     | CONTRIB     | STAT      | information about SSL certificates                           |
| cube                         | 1.5     | CONTRIB     | TYPE      | data type for multidimensional cubes                         |
| hstore                       | 1.8     | CONTRIB     | TYPE      | data type for storing sets of (key, value) pairs             |
| isn                          | 1.2     | CONTRIB     | TYPE      | data types for international product numbering standards     |
| ltree                        | 1.2     | CONTRIB     | TYPE      | data type for hierarchical tree-like structures              |
| prefix                       | 1.2.0   | CONTRIB     | TYPE      | Prefix Range module for PostgreSQL                           |
| seg                          | 1.4     | CONTRIB     | TYPE      | data type for representing line segments or floating-point intervals |
| xml2                         | 1.1     | CONTRIB     | TYPE      | XPath querying and XSLT                                      |




----------------

## 扩展安装

当您初始化 PostgreSQL 集群时，列于 [`pg_extensions`](PARAM#pg_extension) 的扩展插件将会被安装。该参数的默认值为：

```yaml
pg_extensions:     # 待安装的 pg 扩展列表，`${pg_version}` 会被替换为真实的数据库大版本 pg_version
  - pg_repack_${pg_version} wal2json_${pg_version}
  - postgis33_${pg_version} postgis33_${pg_version}-devel postgis33_${pg_version}-utils
  - timescaledb-2-postgresql-${pg_version}
  - citus*${pg_version}*
  - pgvector_${pg_version}*
```

其中 `${pg_version}` 是一个占位符变量，将在实际安装时被替换为 PostgreSQL 数据库集群大版本号。因此，默认的配置文件会安装这些扩展：

- `postgis33`：地理空间数据库扩展
- `timescaledb`：时序流式数据库扩展
- `citus`：分布式/列存储扩展
- `pgvector`：向量数据库/索引扩展
- `pg_repack`：在线处理表膨胀的扩展
- `wal2json`：通过逻辑解码抽取JSON格式的变更。

请注意，除了 Pigsty 当前支持的主力版本外（15），并不是所有的 PostgreSQL 大版本都完整提供了以上扩展。
例如截止至 2023-09-15 PostgreSQL 16 刚发布时，PG 16 目前仍然缺少 `pg_repack`，`citus` 与 `timescaledb` 扩展。
在这种情况下，您应当在初始化这些集群时，在集群配置中修改 `pg_extensions` 参数，移除不受支持的扩展。

当您想要在还未创建的目标集群中启用某些扩展时，可以使用参数配置直接声明所需的扩展，与安装的位置：

```yaml
pg-v15:
  hosts: { 10.10.10.10: { pg_seq: 1 ,pg_role: primary } }
  vars:
    pg_cluster: pg-v15
    pg_databases:
      - name: test
        extensions:                 # <----- 在数据库中启用这些扩展
          - { name: postgis, schema: public }
          - { name: timescaledb }
          - { name: pg_cron }
          - { name: vector }
          - { name: age }
    pg_libs: 'timescaledb, pg_cron, pg_stat_statements, auto_explain' # <- 个别扩展需要加载动态库方可运行
    pg_extensions:
      - pg_repack_${pg_version} wal2json_${pg_version}
      - postgis33_${pg_version} postgis33_${pg_version}-devel postgis33_${pg_version}-utils
      - timescaledb-2-postgresql-${pg_version}
      - citus*${pg_version}*
      - pgvector_${pg_version}*
      - pg_cron_${pg_version}*        # <---- 新增的扩展：pg_cron
      - apache-age_${pg_version}*     # <---- 新增的扩展：apache-age
      - zhparser_${pg_version}*       # <---- 新增的扩展：zhparser
```

您也可以使用 [`pgsql.yml`](PGSQL-PLAYBOOK#pgsqlyml) 的 `pg_extension` 子任务，为已经创建好的集群添加扩展。

```bash
./pgsql.yml -l pg-v15 -t pg_extension    # 为 pg-v15 集群安装指定的扩展插件
```


----------------

### 手工安装扩展

您也可以在集群创建之后，使用 Ansible 或 Shell 手工安装插件，例如，如果想在某个已经初始化好的集群上启用特定扩展：

```bash
cd ~/pigsty;               # 进入 pigsty 源码目录，为 pg-test 集群安装 age 与 zhparser 扩展
ansible pg-test -m yum -b -a 'name=apache-age_15*'     # 扩展的名称通常后缀以 `_<pgmajorversion>`
ansible pg-test -m yum -b -a 'name=zhparser_15*'       # 例如，您的数据库大版本为15，那么就应该在扩展yum包之后添加 `_15`
```

绝大多数插件插件都已经收录放置在基础设施节点上的 yum 软件源中，可以直接通过 yum 命令安装。
如果没有收录，您可以考虑从 PGDG 上游源使用 `repotrack` 命令下载，或者选择在本地编译好后打包成 RPM 包分发。

扩展安装完成后，您应当能在目标数据库集群的 `pg_available_extensions` 视图中看到它们，接下来在想要安装扩展的数据库中执行：

```sql
CREATE EXTENSION age;          -- 安装图数据库扩展
CREATE EXTENSION zhparser;     -- 安装中文分词全文检索扩展
```



----------------

## 扩展编译

如果您想要的扩展包不在 Pigsty 中，也不在 PGDG 官方源里，那么您可以考虑编译安装，或者将编译好的扩展打包成 RPM 包分发。

例如，下面是编译 PostgreSQL `pgsql-http` 扩展的说明：

想要编译扩展，您需要安装 `rpmbuild`，`gcc/clang`，以及其他相关的 `-devel` 软件包，特别是您还需要 `pgdg-srpm-macros` 来构建标准的 PGDG 式扩展 RPM。

```bash
cat > /etc/yum.repos.d/pgdg-srpm.repo <<-'EOF'
[pgdg-common-srpm]
name = PostgreSQL 15 SRPM $releasever - $basearch
baseurl=https://download.postgresql.org/pub/repos/yum/srpms/common/redhat/rhel-$releasever-x86_64/
gpgcheck = 0
enabled = 1
module_hotfixes=1
EOF

# install deps
yum install -y pgdg-srpm-macros clang ccache rpm-build rpmdevtools postgresql1*-server flex bison
yum install -y postgresql1*-devel openssl-devel krb5-devel libcurl-devel readline-devel zlib-devel
rpmdev-setuptree;
```

然后，撰写软件包的规格说明文件，放置于： `/root/rpmbuild/SPECS/pgsql-http.spec`。

<details><summary>示例：构建 http 扩展的 RPM SPEC</summary>

```
%global pname http
%global sname pgsql-http
%global pginstdir /usr/pgsql-%{pgmajorversion}

%ifarch ppc64 ppc64le s390 s390x armv7hl
 %if 0%{?rhel} && 0%{?rhel} == 7
  %{!?llvm:%global llvm 0}
 %else
  %{!?llvm:%global llvm 1}
 %endif
%else
 %{!?llvm:%global llvm 1}
%endif

Name:		%{sname}_%{pgmajorversion}
Version:	1.6.0
Release:	PIGSTY1%{?dist}
Summary:	HNSW algorithm for vector similarity search in PostgreSQL.
License:	MIT
URL:		https://github.com/pramsey/%{sname}
Source0:	https://github.com/pramsey/%{sname}/archive/refs/tags/v%{version}.tar.gz
#           https://github.com/pramsey/pgsql-http/archive/refs/tags/v1.6.0.tar.gz

BuildRequires:	postgresql%{pgmajorversion}-devel pgdg-srpm-macros >= 1.0.27
Requires:	postgresql%{pgmajorversion}-server

%description
Wouldn't it be nice to be able to write a trigger that called a web service? Either to get back a result,
 or to poke that service into refreshing itself against the new state of the database? This extension is for that.


%if %llvm
%package llvmjit
Summary:	Just-in-time compilation support for %{sname}
Requires:	%{name}%{?_isa} = %{version}-%{release}
%if 0%{?rhel} && 0%{?rhel} == 7
%ifarch aarch64
Requires:	llvm-toolset-7.0-llvm >= 7.0.1
%else
Requires:	llvm5.0 >= 5.0
%endif
%endif
%if 0%{?suse_version} >= 1315 && 0%{?suse_version} <= 1499
BuildRequires:	llvm6-devel clang6-devel
Requires:	llvm6
%endif
%if 0%{?suse_version} >= 1500
BuildRequires:	llvm15-devel clang15-devel
Requires:	llvm15
%endif
%if 0%{?fedora} || 0%{?rhel} >= 8
Requires:	llvm => 13.0
%endif

%description llvmjit
This packages provides JIT support for %{sname}
%endif


%prep
%setup -q -n %{sname}-%{version}

%build
PATH=%{pginstdir}/bin:$PATH %{__make} %{?_smp_mflags}

%install
%{__rm} -rf %{buildroot}
PATH=%{pginstdir}/bin:$PATH %{__make} %{?_smp_mflags} install DESTDIR=%{buildroot}

%files
%doc README.md
%{pginstdir}/lib/%{pname}.so
%{pginstdir}/share/extension/%{pname}.control
%{pginstdir}/share/extension/%{pname}*sql
%if %llvm
%files llvmjit
   %{pginstdir}/lib/bitcode/*
%endif

%changelog
* Wed Sep 13 2023 Vonng <rh@vonng.com> - 1.6.0
- Initial RPM release, used by Pigsty <https://pigsty.cc>
```

</details>

您可以将该扩展的源码包下载至`/root/rpmbuild/SOURCES`，然后使用 `rpmbuild` 命令针对不同的PG大版本进行编译：

```bash
rpmbuild --define "pgmajorversion 16" -ba ~/rpmbuild/SPECS/pgsql-http.spec;
rpmbuild --define "pgmajorversion 15" -ba ~/rpmbuild/SPECS/pgsql-http.spec;
rpmbuild --define "pgmajorversion 14" -ba ~/rpmbuild/SPECS/pgsql-http.spec;
rpmbuild --define "pgmajorversion 13" -ba ~/rpmbuild/SPECS/pgsql-http.spec;
rpmbuild --define "pgmajorversion 12" -ba ~/rpmbuild/SPECS/pgsql-http.spec;
```

编译成果会放置在 `/root/rpmbuild/RPMS`，将其移动到 Pigsty 本地源 `/www/pigsty`，并执行 `./infra.yml -t repo_create` 重建本地源。
您就可以在其他主机上使用编译好的扩展 RPM 包了。具体细节请参考 rpm 构建资料，不再展开。