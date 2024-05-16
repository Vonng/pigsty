# PostgreSQL 扩展插件

> 扩展是 PostgreSQL 的灵魂所在，完整的扩展列表，请参考[这里](https://pigsty.cc/zh/docs/reference/extension/)

Pigsty 收录了超过 160 个预先编译打包、开箱即用的 PostgreSQL 强力扩展插件，其中包括一些强力扩展：

- [**PostGIS**](https://postgis.net/)：提供地理空间数据类型与索引支持，GIS 事实标准 （& [**pgPointCloud**](https://pgpointcloud.github.io/pointcloud/) 点云，[**pgRouting**](https://pgrouting.org/) 寻路）
- [**TimescaleDB**](https://www.timescale.com/)：添加时间序列/持续聚合/分布式/列存储/自动压缩的能力
- [**PGVector**](https://github.com/pgvector/pgvector)：添加 AI 向量/嵌入数据类型支持，以及 ivfflat 与 hnsw 向量索引。（& [**pg_sparse**](https://github.com/paradedb/paradedb/tree/dev/pg_sparse) 稀疏向量支持）
- [**Citus**](https://www.citusdata.com/)：将经典的主从PG集群原地改造为水平分片的分布式数据库集群。
- [**Hydra**](https://www.hydra.so/)：添加列式存储与分析能力，提供比肩 ClickHouse 的强力分析能力。
- [**ParadeDB**](https://www.paradedb.com/)：添加 ElasticSearch 水准的全文搜索能力与混合检索的能力。（& [**zhparser**](https://github.com/amutu/zhparser) 中文分词）
- [**Apache AGE**](https://age.apache.org/)：图数据库扩展，为 PostgreSQL 添加类 Neo4J 的 OpenCypher 查询支持，
- [**PG GraphQL**](https://github.com/supabase/pg_graphql)：为 PostgreSQL 添加原生内建的 GraphQL 查询语言支持。
- [**ParadeDB**](https://www.paradedb.com/)：添加 ElasticSearch 水准的全文搜索能力，BM25算法支持以及与稀疏向量执行混合检索。
- [**DuckDB FDW**](https://github.com/alitrack/duckdb_fdw)：允许您通过 PostgreSQL 直接读写强力的嵌入式分析数据库 [**DuckDB**](https://github.com/Vonng/pigsty/tree/master/app/duckdb) 文件 （& DuckDB CLI 本体）。
- [**Supabase**](https://github.com/Vonng/pigsty/tree/master/app/supabase)：基于 PostgreSQL 的开源的 Firebase 替代，提供完整的应用开发存储解决方案。
- [**FerretDB**](https://github.com/Vonng/pigsty/tree/master/app/ferretdb)：基于 PostgreSQL 的开源 MongoDB 替代，兼容 MongoDB API / 驱动协议。
- [**PostgresML**](https://github.com/Vonng/pigsty/tree/master/app/pgml)：使用SQL完成经典机器学习算法，调用、部署、训练 AI 模型。

[![pigsty-extension.jpg](https://repo.pigsty.cc/img/pigsty-extension.jpg)](#扩展列表)

绝大部分扩展都是可以并存甚至组合使用的，妙用扩展可以产生 1+1 远大于 2 的协同增幅效应（例外：hydra 与 citus 互斥），实现 PostgreSQL for Everything！

绝大多数插件插件都已经收录放置在基础设施节点上的本地软件源中，可以直接通过 `yum`/`apt` 命令安装。您可以通过 Pigsty 配置文件指定需要下载、安装、启用的扩展，并自动完成安装与配置。

此外，有一些“数据库”其实并不是 PostgreSQL 扩展插件，但是基于 PostgreSQL，或与其密切相关。因此也收录在 Pigsty 中提供原生支持，
比如基于 PostgreSQL 提供开源 MongoDB 替代的 [FerretDB](https://github.com/Vonng/pigsty/tree/master/app/ferretdb)，提供开源 Airtable 替代的 [NocoDB](https://github.com/Vonng/pigsty/tree/master/app/nocodb)，提供交互式分析检视的 [Metabase](https://github.com/Vonng/pigsty/tree/master/app/metabase) 等。



----------------

## 默认扩展

当您初始化 PostgreSQL 集群时，列于 [`pg_packages`](PARAM#pg_packages) 与 [`pg_extensions`](PARAM#pg_extension) 中列出的扩展插件将会被安装。

在 EL 系列系统（默认）和 Ubuntu/Debian 系列系统中，包的名称略有不同。但通常包含 `pg` (el) / `postgres` (deb)，和 PG 大版本号（目前默认为 16）。 

Pigsty 允许在这两个变量中使用 `${pg_version}` 占位符，它将被自动替换成集群安装的 PG 大版本号。

在 EL / RPM （默认）系统中，默认安装的扩展为：

```yaml
pg_packages:     # 这三个扩展插件总是随主干大版本一起安装： pg_repack, wal2json, passwordcheck_cracklib
  - pg_repack_${pg_version}* wal2json_${pg_version}* passwordcheck_cracklib_${pg_version}*
pg_extensions:   # 待安装的 pg 扩展列表，默认安装 postgis，timescaledb，pgvector
  - postgis34_${pg_version}* timescaledb-2-postgresql-${pg_version}* pgvector_${pg_version}*
```

在 Ubuntu / Debian 系统中，默认安装的扩展为：

```yaml
pg_packages:    # 这两个扩展插件总是随主干大版本一起安装： pg_repack, wal2json
  - postgresql-${pg_version}-repack postgresql-${pg_version}-wal2json
pg_extensions:  # 待安装的 pg 扩展列表，默认安装 postgis，timescaledb，pgvector，citus
  - postgresql-${pg_version}-postgis* timescaledb-2-postgresql-${pg_version} postgresql-${pg_version}-pgvector postgresql-${pg_version}-citus-12.1
```

因此，Pigsty 默认安装的扩展为：

- `postgis`：地理空间数据库扩展（注意：EL7 的版本为 3.3，Ubuntu20 需要在线安装）
- `timescaledb`：时序数据库扩展插件（从 TimescaleDB 独立的仓库下载安装，特殊的包名）
- `pgvector`：向量数据类型与IVFFLAT/HNSW索引，向量数据库替代。
- `pg_repack`：在线处理表膨胀的维护性扩展：对于维护数据库健康非常重要，默认启用。
- `wal2json`：通过逻辑解码抽取JSON格式的变更：对于抽取数据库变更非常实用，无需显式启用。
- `passwordcheck_cracklib`：强制用户密码强度/过期策略，此扩展默认安装但可选，仅在EL中可用。
- `citus`：默认在 Debian/Ubuntu 中安装，EL系因为与 Fork 出来的列存插件 `hydra`冲突，用户可以二者择一安装。

您也可以在集群初始化完成后再安装新扩展插件，如下一节所示。


----------------

## 扩展安装

当集群已经完成初始化后，如果您需要向集群中安装新扩展，可以向 [`pg_extensions`](PARAM#pg_extensions) 中添加扩展名称，并通过剧本完成安装。

例如，如果您想在 `pg-meta` 集群中安装用于分析的 `hydra` 与 `pg_analytics` 扩展，可以在集群配置文件中添加：

```yaml
pg-meta:
  hosts: { 10.10.10.10: { pg_seq: 1 ,pg_role: primary } }
  vars:
    pg_cluster: pg-meta
    pg_databases:
      - name: test
        extensions:  # <----- 在数据库中启用这些扩展 (`CREATE EXTENSION`)
          - { name: postgis, schema: public }
          - { name: timescaledb  }
          - { name: pg_analytics } # <---- 新增扩展
          - { name: duckdb_fdw   } # <---- 新增扩展
          - { name: hydra        } # <---- 新增扩展

    pg_libs: 'timescaledb, pg_cron, pg_stat_statements, auto_explain' # <- 个别扩展需要加载动态库方可运行
    pg_extensions:   # 安装到集群中的扩展列表 (yum/apt install)
      - postgis34_${pg_version}* timescaledb-2-postgresql-${pg_version}* pgvector_${pg_version}*          # 默认安装的三个扩展，如果需要，不要忘记保留
      - pg_analytics_${pg_version}* duckdb_fdw_${pg_version}* hydra_${pg_version}* #citus_${pg_version}*  # <-----+ 新增扩展
      
      #- pg_bm25_${pg_version}* pg_sparse_${pg_version}* zhparser_${pg_version}*                          # 其他备选扩展
      #- pg_graphql_${pg_version} pg_net_${pg_version}* pgsql-http_${pg_version}* vault_${pg_version} pgjwt_${pg_version} pg_tle_${pg_version}*
      #- pgml_${pg_version}* apache-age_${pg_version}* pg_roaringbitmap_${pg_version}* pointcloud_${pg_version}* pgsql-gzip_${pg_version}* pglogical_${pg_version}* pg_cron_${pg_version}*
      #- orafce_${pg_version}* mongo_fdw_${pg_version}* tds_fdw_${pg_version}* mysql_fdw_${pg_version} hdfs_fdw_${pg_version} sqlite_fdw_${pg_version} pgbouncer_fdw_${pg_version} powa_${pg_version}* pg_stat_kcache_${pg_version}* pg_stat_monitor_${pg_version}* pg_qualstats_${pg_version} pg_track_settings_${pg_version} pg_wait_sampling_${pg_version} hll_${pg_version} pgaudit_${pg_version}
      #- plprofiler_${pg_version}* plsh_${pg_version}* pldebugger_${pg_version} plpgsql_check_${pg_version}* pgtt_${pg_version} pgq_${pg_version}* pgsql_tweaks_${pg_version} count_distinct_${pg_version} hypopg_${pg_version} timestamp9_${pg_version}* semver_${pg_version}* prefix_${pg_version}* periods_${pg_version} ip4r_${pg_version} tdigest_${pg_version} pgmp_${pg_version} extra_window_functions_${pg_version} topn_${pg_version}
      #- pg_background_${pg_version} e-maj_${pg_version} pg_prioritize_${pg_version} pgcryptokey_${pg_version} logerrors_${pg_version} pg_top_${pg_version} pg_comparator_${pg_version} pg_ivm_${pg_version}* pgsodium_${pg_version}* pgfincore_${pg_version}* ddlx_${pg_version} credcheck_${pg_version} safeupdate_${pg_version} pg_squeeze_${pg_version}* pg_fkpart_${pg_version} pg_jobmon_${pg_version}
      #- pg_partman_${pg_version} pg_permissions_${pg_version} pgexportdoc_${pg_version} pgimportdoc_${pg_version} pg_statement_rollback_${pg_version}* pg_hint_plan_${pg_version}* pg_auth_mon_${pg_version} pg_checksums_${pg_version} pg_failover_slots_${pg_version} pg_readonly_${pg_version}* pg_uuidv7_${pg_version}* set_user_${pg_version}* rum_${pg_version}
```

使用 [`pgsql.yml`](PGSQL-PLAYBOOK#pgsqlyml) 的 `pg_extension` 子任务，为已经创建好的集群添加扩展：

```bash
./pgsql.yml -l pg-meta -t pg_extension    # 为集群安装指定的扩展插件
```

您也可以在数据库服务器上使用 `yum` | `apt` 命令直接安装扩展软件包，或者使用 Ansible 模块来批量完成安装，但是这样您必须显式指明扩展的大版本号（目前为 16）：

```bash
cd ~/pigsty;               # 在管理节点上进入 pigsty 源码目录，为 pg-test 集群安装 pg_analytics 与 hydra 扩展
ansible pg-meta -m package -b -a 'name=pg_analytics_16'     # 扩展的名称通常后缀以 `_<pgmajorversion>`
ansible pg-meta -m package -b -a 'name=hydra_16*'           # 例如，您的数据库大版本为16，那么就应该在扩展yum包之后添加 `_16`
```

请注意，Pigsty 默认只下载 PG 主版本（PG16）上的主流扩展插件，当您使用其他大版本的 PostgreSQL 时，应当调整 [`repo_packages`](PARAM#repo_packages) 中下载的插件名称。


----------------

## 扩展启用

安装 PostgreSQL 扩展后，您可以在 PostgreSQL 的 `pg_available_extensions` 视图中看到它们。但想要实际启用扩展，通常还需要额外的步骤：

1. 一部分扩展要求被添加到 `shared_preload_libraries` 中动态加载，例如 `timescaledb`，`citus` 等。
2. 大部分扩展都需要通过 SQL 语句：`CREATE EXTENSION <name>;` 启用，极少量扩展不需要，例如 `wal2json`。  

* 修改 `shared_preload_libraries`：
  * 在数据库集群初始化前，可以通过 [`pg_libs`](PARAM#pg_libs) 参数手工预先指定；
  * 当数据库已经初始化完毕后，您可以修改[集群配置](PGSQL-ADMIN#配置集群)，直接修改 `shared_preload_libraries` 参数并应用（无需重启）。
  * 需要动态加载的典型插件：`citus`, `timescaledb`, `pg_cron`, `pg_net`, `pg_tle`
* 执行 `CREATE EXTENSION`：
    * 在数据库集群初始化前，可以在 [`pg_databases`](PARAM#pg_databases).`extensions` 列表中指定。
    * 当数据库已经初始化完毕后，您可以直接连接数据库执行此 SQL 命令，或使用其他模式变更工具管理扩展。

> 从原理上讲：PostgreSQL 的扩展通常由 Control文件（元数据，一定存在），SQL文件（SQL语句，可选），So文件（二进制动态连接库，可选）三部分组成。
> 提供 `.so` 文件的扩展有可能需要添加到 `shared_preload_libraries` 才能生效，例如 `citus` 与 `timescaledb`，但也有许多扩展不用，例如 `postgis`，`pgvector`。
> 不通过 SQL 接口对外服务的扩展不需要执行 `CREATE EXTENSION`，例如提供 CDC 抽取能力的 `wal2json` 扩展。

在您希望启用扩展的数据库中执行 `CREATE EXTENSION` SQL 语句，即可完成扩展的创建：

```sql
CREATE EXTENSION vector;  -- 安装向量数据库扩展
CREATE EXTENSION hydra;   -- 安装列存数据库扩展
```


----------------

## 扩展下载

Pigsty 默认从 PostgreSQL 官方软件源下载扩展插件，如果您希望使用 Pigsty 没有收录的扩展，可以选择直接编译安装，
或者下载 RPM/DEB 包放置于管理节点上的本地软件源中（`/www/pigsty`），供所有节点使用，详情参考管理SOP-[添加软件](PGSQL-ADMIN#添加软件)。

- YUM: https://download.postgresql.org/pub/repos/yum/16/redhat/
- APT: http://apt.postgresql.org/pub/repos/apt/



``

----------------

## 扩展列表

其中由 Pigsty 维护编译打包的 33 个 PostgreSQL 插件由下表所列出：

Pigsty has maintained and packaged 33 extensions for PostgreSQL 16 on EL systems, which are available on Pigsty's PGSQL repo for EL8 & EL9 systems:

| name                                                                       |  version  |   source   | comment                                                                                      |
|----------------------------------------------------------------------------|:---------:|:----------:|----------------------------------------------------------------------------------------------|
| [pgml](https://github.com/postgresml/postgresml)                           |   2.8.1   | **PIGSTY** | PostgresML: access most advanced machine learning algorithms and pretrained models with SQL  |
| [age](https://github.com/apache/age)                                       |   1.5.0   | **PIGSTY** | Apache AGE graph database extension                                                          |
| [pointcloud](https://github.com/pgpointcloud/pointcloud)                   |   1.2.5   | **PIGSTY** | A PostgreSQL extension for storing point cloud (LIDAR) data.                                 |
| [pgsql-http](https://github.com/pramsey/pgsql-http)                        |    1.6    | **PIGSTY** | HTTP client for PostgreSQL, allows web page retrieval inside the database.                   |
| [pgsql-gzip](https://github.com/pramsey/pgsql-gzip)                        |    1.0    | **PIGSTY** | Gzip and unzip with SQL                                                                      |
| [pg_tle](https://github.com/aws/pg_tle)                                    |   1.4.0   | **PIGSTY** | Trusted Language Extensions for PostgreSQL                                                   |
| [roaringbitmap](https://github.com/ChenHuajun/pg_roaringbitmap)            |    0.5    | **PIGSTY** | Support for Roaring Bitmaps                                                                  |
| [zhparser](https://github.com/amutu/zhparser)                              |    2.2    | **PIGSTY** | Parser for full-text search of Chinese                                                       |
| [pg_net](https://github.com/supabase/pg_net)                               |   0.9.1   | **PIGSTY** | A PostgreSQL extension that enables asynchronous (non-blocking) HTTP/HTTPS requests with SQL |
| [pgjwt](https://github.com/michelp/pgjwt)                                  |   0.2.0   | **PIGSTY** | JSON Web Token API for Postgresql                                                            |
| [pg_graphql](https://github.com/supabase/pg_graphql)                       |   1.5.4   | **PIGSTY** | GraphQL support to your PostgreSQL database.                                                 |
| [pg_jsonschema](https://github.com/supabase/pg_jsonschema)                 |   0.3.1   | **PIGSTY** | PostgreSQL extension providing JSON Schema validation                                        |
| [vault](https://github.com/supabase/vault)                                 |   0.2.9   | **PIGSTY** | Extension for storing encrypted secrets in the Vault                                         |
| [hydra](https://github.com/hydradatabase/hydra)                            |   1.1.2   | **PIGSTY** | Hydra is open source, column-oriented Postgres extension                                     |
| [wrappers](https://github.com/supabase/wrappers)                           |   0.3.1   | **PIGSTY** | Postgres Foreign Data Wrappers Collections by Supabase                                       |
| [duckdb_fdw](https://github.com/alitrack/duckdb_fdw)                       |    1.1    | **PIGSTY** | DuckDB Foreign Data Wrapper                                                                  |
| [pg_search](https://github.com/paradedb/paradedb/tree/dev/pg_search)       |   0.7.0   | **PIGSTY** | Full text search over SQL tables using the BM25 algorithm                                    |
| [pg_lakehouse](https://github.com/paradedb/paradedb/tree/dev/pg_lakehouse) |   0.7.0   | **PIGSTY** | ery engine over object stores like S3 and table formats like Delta Lake                      |
| [pg_analytics](https://github.com/paradedb/pg_analytics)                   |   0.6.1   | **PIGSTY** | Accelerates analytical query processing inside Postgres                                      |
| [pgmq](https://github.com/tembo-io/pgmq)                                   |   1.5.2   | **PIGSTY** | A lightweight message queue. Like AWS SQS and RSMQ but on Postgres.                          |
| [pg_tier](https://github.com/tembo-io/pg_tier)                             |   0.0.3   | **PIGSTY** | Postgres Extension written in Rust, to enable data tiering to AWS S3                         |
| [pg_vectorize](https://github.com/tembo-io/pg_vectorize)                   |  0.15.0   | **PIGSTY** | The simplest way to orchestrate vector search on Postgres                                    |
| [pg_later](https://github.com/tembo-io/pg_later)                           |   0.1.0   | **PIGSTY** | Execute SQL now and get the results later.                                                   |
| [pg_idkit](https://github.com/VADOSWARE/pg_idkit)                          |   0.2.3   | **PIGSTY** | Generating many popular types of identifiers                                                 |
| [plprql](https://github.com/kaspermarstal/plprql)                          |   0.1.0   | **PIGSTY** | Use PRQL in PostgreSQL                                                                       |
| [pgsmcrypto](https://github.com/zhuobie/pgsmcrypto)                        |   0.1.0   | **PIGSTY** | PostgreSQL SM Algorithm Extension                                                            |
| [pg_tiktoken](https://github.com/kelvich/pg_tiktoken)                      |   0.0.1   | **PIGSTY** | OpenAI tiktoken tokenizer for postgres                                                       |
| [pgdd](https://github.com/rustprooflabs/pgdd)                              |   0.5.2   | **PIGSTY** | Access Data Dictionary metadata with pure SQL                                                |
| [parquet_s3_fdw](https://github.com/pgspider/parquet_s3_fdw)               |   1.1.0   | **PIGSTY** | ParquetS3 Foreign Data Wrapper for PostgresSQL                                               |
| [plv8](https://github.com/plv8/plv8)                                       |   3.2.2   | **PIGSTY** | V8 Engine Javascript Procedural Language add-on for PostgreSQL                               |
| [md5hash](https://github.com/tvondra/md5hash)                              |   1.0.1   | **PIGSTY** | Custom data type for storing MD5 hashes rather than text                                     |
| [pg_tde](https://github.com/Percona-Lab/pg_tde)                            | 1.0-alpha | **PIGSTY** | Experimental encrypted access method for PostgreSQL                                          |
| [pg_dirtyread](https://github.com/df7cb/pg_dirtyread)                      |    2.6    | **PIGSTY** | Read dead but unvacuumed tuples from a PostgreSQL relation                                   |
| pg_bm25 ❋                                                                  |   0.5.6   | **PIGSTY** | ParadeDB: pg_bm25: Full text search for PostgreSQL using BM25 (rename to pg_search)          |
| svector ❋                                                                  |   0.5.6   | **PIGSTY** | pg_sparse: Sparse vector data type and sparse HNSW access methods (depreciated)              |
| imgsmlr ❋                                                                  |   1.0.0   | **PIGSTY** | ImgSmlr method is based on Haar wavelet transform (pg 16 not supported)                      |
| pg_similarity ❋                                                            |   1.0.0   | **PIGSTY** | set of functions and operators for executing similarity queries(covered by pgvector)         |
| pg_bigm ❋                                                                  |   1.2.0   | **PIGSTY** | full text search capability with create 2-gram (bigram) index. (pg 16 not supported)         |

> 注意：一些扩展在 Debian/Ubuntu 系统上不可用，您可以从源码构建安装，包括：`http`, `gzip`, `pg_tle`, `roaringbitmap`, `zhparser`, `pgjwt`, `vault`, `hydra`, `imgsmlr`, `pg_bigm`, `duckdb_fdw`。其中图扩展 `age`， 点云扩展 `pointcloud` 在 Deb 仓库中默认可用，`pg_graphql`，`pg_net`，`pg_bm25`，`pg_analytics`，`svector` 在 Ubuntu 22.04 上可用。


以下是被 Pigsty 收录，可以直接启用的完整插件列表：

| 名称                           |   版本   |     来源     |  类型   | 系统      | 说明                                        |
|------------------------------|:------:|:----------:|:-----:|---------|-------------------------------------------|
| pgml                         | 2.8.1  | **PIGSTY** | FEAT  | rpm     | PostgresML：用SQL运行机器学习算法并训练模型              |
| age                          | 1.5.0  | **PIGSTY** | FEAT  | rpm,deb | Apache AGE，图数据库扩展 （Deb可用）                 |
| pg_graphql                   | 1.5.0  | **PIGSTY** | FEAT  | rpm,u22 | PG内的 GraphQL 支持 (RUST, supabase)          |
| hydra                        | 1.1.1  | **PIGSTY** | FEAT  | rpm     | 开源列式存储扩展                                  |
| pg_analytics                 | 0.5.6  | **PIGSTY** | FEAT  | rpm,u22 | ParadeDB 列存x向量执行分析加速插件                    |
| pg_bm25                      | 0.5.6  | **PIGSTY** | FEAT  | rpm,u22 | ParadeDB BM25算法全文检索插件，ElasticSearch 全文检索  |
| zhparse                      |  2.2   | **PIGSTY** | FEAT  | rpm     | 中文分词，全文搜索解析器                              |
| pg_bigm ❋                    | 1.2.0  | **PIGSTY** | FEAT  | rpm     | 基于二字组的多语言全文检索扩展                           |
| svector                      | 0.5.6  | **PIGSTY** | FEAT  | rpm     | ParadeDB 稀疏向量数据库类型与HNSW索引                 |
| emaj                         | 4.3.1  |    PGDG    | FEAT  | rpm     | 让数据库的子集具有细粒度日志和时间旅行功能                     |
| periods                      |  1.2   |    PGDG    | FEAT  | rpm     | 为 PERIODs 和 SYSTEM VERSIONING 提供标准 SQL 功能 |
| pg_ivm                       |  1.7   |    PGDG    | FEAT  | rpm     | 增量维护的物化视图                                 |
| pgq                          | 3.5.1  |    PGDG    | FEAT  | rpm     | 通用队列的PG实现                                 |
| pgq_node                     |  3.5   |    PGDG    | FEAT  | deb     | 级联队列基础设施                                  |
| pgsodium                     | 3.1.9  |    PGDG    | FEAT  | rpm     | 表数据加密存储 TDE                               |
| **timescaledb**              | 2.14.1 |    PGDG    | FEAT  | rpm     | **时序数据库扩展插件**                             |
| **wal2json**                 | 2.5.3  |    PGDG    | FEAT  | rpm     | **用逻辑解码捕获 JSON 格式的 CDC 变更**               |
| **vector**                   | 0.6.0  |    PGDG    | FEAT  | rpm     | **向量数据类型和 ivfflat / hnsw 访问方法**           |
| safeupdate                   |  1.4   |    PGDG    | FEAT  | rpm     | 强制在 UPDATE 和 DELETE 时提供 Where 条件          |
| pg_hint_plan                 | 1.6.0  |    PGDG    | FEAT  | rpm     | 添加强制指定执行计划的能力                             |
| pg_snakeoil                  |   1    |    PGDG    | FEAT  | deb     | PostgreSQL 反病毒                            |
| jsquery                      |  1.1   |    PGDG    | FEAT  | deb     | 用于内省 JSONB 数据类型的查询类型                      |
| omnidb_plpgsql_debugger      | 1.0.0  |    PGDG    | FEAT  | deb     | 在 OmniDB 中启用 PL/pgSQL 调试器                 |
| icu_ext                      |  1.8   |    PGDG    | FEAT  | deb     | 访问 ICU 库函数                                |
| pgmemcache                   | 2.3.0  |    PGDG    | FEAT  | deb     | 为 PG 提供 memcached 借口                      |
| pre_prepare                  |  0.4   |    PGDG    | FEAT  | deb     | 预先在服务段准备好你的 Prepare Statement             |
| credcheck                    | 2.2.0  |    PGDG    | ADMIN | rpm     | 明文凭证检查器                                   |
| **pg_cron**                  |  1.6   |    PGDG    | ADMIN | rpm,deb | **定时任务调度器**                               |
| pg_background                |  1.0   |    PGDG    | ADMIN | rpm     | 在后台运行 SQL 查询                              |
| pg_jobmon                    | 1.4.1  |    PGDG    | ADMIN | rpm     | 记录和监控函数                                   |
| pg_readonly                  | 1.0.0  |    PGDG    | ADMIN | rpm     | 将集群设置为只读                                  |
| **pg_repack**                | 1.5.0  |    PGDG    | ADMIN | rpm     | **在线垃圾清理与表膨胀治理**                          |
| pg_squeeze                   |  1.6   |    PGDG    | ADMIN | rpm     | 从关系中删除未使用空间                               |
| pgfincore                    | 1.3.1  |    PGDG    | ADMIN | rpm     | 检查和管理操作系统缓冲区缓存                            |
| **pglogical**                | 2.4.4  |    PGDG    | ADMIN | rpm     | **第三方逻辑复制支持**                             |
| pglogical_origin             | 1.0.0  |    PGDG    | ADMIN | rpm     | 用于从 Postgres 9.4 升级时的兼容性虚拟扩展              |
| pglogical_ticker             |  1.4   |    PGDG    | ADMIN | deb     | 展示 pglogical 精确复制延迟的视图                    |
| pgl_ddl_deploy               |  2.2   |    PGDG    | ADMIN | deb     | 使用 pglogical 执行自动 DDL 部署                  |
| toastinfo                    |   1    |    PGDG    | ADMIN | deb     | 显示 Toasted 数据项详情                          |
| pg_fact_loader               |  2.0   |    PGDG    | ADMIN | deb     | 在 Postgres 中构建事实表                         |
| pgautofailover               |  2.1   |    PGDG    | ADMIN | deb     | pg 自动故障迁移                                 |
| mimeo                        | 1.5.1  |    PGDG    | ADMIN | deb     | 跨 PostgreSQL 实例的表级复制                      |
| prioritize                   |  1.0   |    PGDG    | ADMIN | rpm     | 获取和设置 PostgreSQL 后端的优先级                   |
| pg_tle                       | 1.3.4  | **PIGSTY** | ADMIN | rpm     | AWS 可信语言扩展                                |
| set_user                     | 4.0.1  |    PGDG    | AUDIT | rpm     | 增加了日志记录的 SET ROLE                         |
| **passwordcracklib**         | 3.0.0  |    PGDG    | AUDIT | rpm     | **强制密码策略**                                |
| pgaudit ❋                    |  16.0  |    PGDG    | AUDIT | rpm,deb | 提供审计功能                                    |
| pgauditlogtofile             |  1.5   |    PGDG    | AUDIT | deb     | pgAudit 子扩展，将审计日志写入单独的文件中                 |
| pgcryptokey                  |  1.0   |    PGDG    | AUDIT | rpm     | PG密钥管理                                    |
| duckdb_fdw                   |  1.1   | **PIGSTY** |  FDW  | rpm     | DuckDB 外部数据源包装器 (libduck 0.9.2)           |
| hdfs_fdw                     | 2.0.5  |    PGDG    |  FDW  | rpm     | hdfs 外部数据包装器                              |
| mongo_fdw                    |  1.1   |    PGDG    |  FDW  | rpm     | MongoDB 外部数据包装器                           |
| multicorn ❋                  |  2.4   |    PGDG    |  FDW  | rpm     | 用 Python 3.6 编写字定义的外部数据源包装器               |
| mysql_fdw                    |  1.2   |    PGDG    |  FDW  | rpm     | MySQL外部数据包装器                              |
| pgbouncer_fdw                | 1.1.0  |    PGDG    |  FDW  | rpm     | 用 SQL 查询 pgbouncer 统计信息，执行 pgbouncer 命令。  |
| sqlite_fdw                   |  1.1   |    PGDG    |  FDW  | rpm     | SQLite 外部数据包装器                            |
| tds_fdw                      | 2.0.3  |    PGDG    |  FDW  | rpm     | TDS 数据库（Sybase/SQL Server）外部数据包装器         |
| oracle_fdw                   |  1.2   |    PGDG    |  FDW  | deb     | Oracle 数据库外部数据源包装器                        |
| ogr_fdw                      |  1.1   |    PGDG    |  FDW  | deb     | GIS 数据外部数据源包装器                            |
| count_distinct               | 3.0.1  |    PGDG    | FUNC  | rpm     | COUNT(DISTINCT ...) 聚合的替代方案               |
| ddlx                         |  0.27  |    PGDG    | FUNC  | rpm     | DDL 提取器                                   |
| extra_window_functions       |  1.0   |    PGDG    | FUNC  | rpm     | 额外的窗口函数                                   |
| first_last_agg               | 0.1.4  |    PGDG    | FUNC  | deb     | first() 与 last() 聚合函数                     |
| mysqlcompat ❋                | 0.0.7  |    PGDG    | FUNC  | rpm     | MySQL 兼容性函数                               |
| orafce                       |  4.9   |    PGDG    | FUNC  | rpm     | 模拟 Oracle RDBMS 的一部分函数和包的函数和运算符           |
| pgsql_tweaks                 | 0.10.2 |    PGDG    | FUNC  | rpm     | 一些便利函数与视图                                 |
| tdigest                      | 1.4.1  |    PGDG    | FUNC  | rpm     | tdigest 聚合函数                              |
| topn                         | 2.6.0  |    PGDG    | FUNC  | rpm     | top-n JSONB 的类型                           |
| unaccent                     |  1.1   |    PGDG    | FUNC  | rpm     | 删除重音的文本搜索字典                               |
| table_log                    | 0.6.1  |    PGDG    | FUNC  | deb     | 一个记录表变更日志的模块 tables                       |
| pg_sphere                    | 1.4.2  |    PGDG    | FUNC  | deb     | 球面对象的实用函数，运算符与索引支持                        |
| pgpcre                       |   1    |    PGDG    | FUNC  | deb     | 兼容 Perl 的正则表达式函数支持（PCRE）                  |
| q3c                          | 2.0.1  |    PGDG    | FUNC  | deb     | q3c 天空索引插件                                |
| **postgis**                  | 3.4.2  |    PGDG    |  GIS  | rpm     | PostGIS 几何和地理空间扩展                         |
| postgis_raster               | 3.4.2  |    PGDG    |  GIS  | rpm     | PostGIS 光栅类型和函数                           |
| postgis_sfcgal               | 3.4.2  |    PGDG    |  GIS  | rpm     | PostGIS SFCGAL 函数                         |
| postgis_tiger_geocoder       | 3.4.2  |    PGDG    |  GIS  | rpm     | PostGIS tiger 地理编码器和反向地理编码器               |
| postgis_topology             | 3.4.2  |    PGDG    |  GIS  | rpm     | PostGIS 拓扑空间类型和函数                         |
| address_standardizer         | 3.4.2  |    PGDG    |  GIS  | rpm     | 地址标准化函数。                                  |
| address_standardizer_data_us | 3.4.2  |    PGDG    |  GIS  | rpm     | 地址标准化函数：美国数据集示例                           |
| pointcloud                   | 1.2.5  | **PIGSTY** |  GIS  | rpm,deb | 提供激光雷达点云数据类型支持                            |
| bloom                        |  1.0   |    PGDG    | INDEX | rpm     | bloom 索引-基于指纹的索引                          |
| hll ❋                        |  2.18  |    PGDG    | INDEX | rpm     | hyperloglog 数据类型                          |
| pgtt                         | 3.1.0  |    PGDG    | INDEX | rpm     | 全局临时表功能                                   |
| rum                          |  1.3   |    PGDG    | INDEX | rpm     | RUM 索引访问方法                                |
| hstore_plperl                |  1.0   |    PGDG    | LANG  | rpm     | 在 hstore 和 plperl 之间转换适配类型                |
| hstore_plperlu               |  1.0   |    PGDG    | LANG  | rpm     | 在 hstore 和 plperlu 之间转换适配类型               |
| plpgsql_check                |  2.7   |    PGDG    | LANG  | rpm     | 对 plpgsql 函数进行扩展检查                        |
| plsh                         |   2    |    PGDG    | LANG  | rpm     | PL/sh 程序语言                                |
| pllua                        |  2.0   |    PGDG    | LANG  | deb     | Lua 程序语言                                  |
| plluau                       |  2.0   |    PGDG    | LANG  | deb     | Lua 程序语言（不受信任的）                           |
| hstore_plluau                |  1.0   |    PGDG    | LANG  | deb     | 在 hstore 和 plluau 之间转换适配类型                |
| **citus**                    | 12.1-1 |    PGDG    | SHARD | rpm     | **Citus 分布式数据库**                          |
| citus_columnar               | 11.3-1 |    PGDG    | SHARD | rpm     | **Citus 列式存储**                            |
| pg_fkpart                    |  1.7   |    PGDG    | SHARD | rpm     | 按外键实用程序进行表分区的扩展                           |
| pg_partman                   | 5.0.1  |    PGDG    | SHARD | rpm     | 用于按时间或 ID 管理分区表的扩展                        |
| plproxy ❋                    | 2.10.0 |    PGDG    | SHARD | rpm,deb | 作为过程语言实现的数据库分区                            |
| pg_show_plans                |  2.0   |    PGDG    | STAT  | deb     | 打印当前运行 SQL 语句的查询计划                        |
| hypopg                       | 1.4.0  |    PGDG    | STAT  | rpm     | 假设索引，用于创建一个虚拟索引检验执行计划                     |
| logerrors                    |  2.1   |    PGDG    | STAT  | rpm     | 用于收集日志文件中消息统计信息的函数                        |
| pg_auth_mon                  |  1.1   |    PGDG    | STAT  | rpm     | 监控每个用户的连接尝试                               |
| pg_permissions               |  1.1   |    PGDG    | STAT  | rpm     | 查看对象权限并将其与期望状态进行比较                        |
| pg_qualstats                 | 2.1.0  |    PGDG    | STAT  | rpm     | 收集有关 quals 的统计信息的扩展                       |
| pg_stat_kcache               | 2.2.3  |    PGDG    | STAT  | rpm     | 内核统计信息收集                                  |
| pg_stat_monitor              |  2.0   |    PGDG    | STAT  | rpm     | 提供查询聚合统计、客户端信息、执行计划详细信息和直方图               |
| pg_store_plans ❋             |  1.7   |    PGDG    | STAT  | rpm     | 跟踪所有执行的 SQL 语句的计划统计信息                     |
| pg_track_settings            | 2.1.2  |    PGDG    | STAT  | rpm     | 跟踪设置更改                                    |
| pg_wait_sampling             |  1.1   |    PGDG    | STAT  | rpm     | 基于采样的等待事件统计                               |
| pldbgapi                     |  1.1   |    PGDG    | STAT  | rpm     | 用于调试 PL/pgSQL 函数的服务器端支持                   |
| plprofiler                   |  4.2   |    PGDG    | STAT  | rpm     | 剖析 PL/pgSQL 函数                            |
| powa                         | 4.2.2  |    PGDG    | STAT  | rpm     | PostgreSQL 工作负载分析器-核心                     |
| system_stats ❋               |  1.0   |    PGDG    | STAT  | rpm     | PostgreSQL 的系统统计函数                        |
| asn1oid                      |   1    |    PGDG    | TYPE  | deb     | 提供 ASN.1 OID 数据类型                         |
| citext                       |  1.6   |    PGDG    | TYPE  | deb     | 提供大小写不敏感的字符串类型                            |
| debversion                   |  1.1   |    PGDG    | TYPE  | deb     | Debian 版本号数据类型                            |
| geoip ❋                      | 0.2.4  |    PGDG    | TYPE  | rpm     | IP 地理位置扩展（围绕 MaxMind GeoLite 数据集的包装器）     |
| ip4r                         |  2.4   |    PGDG    | TYPE  | rpm     | PostgreSQL 的 IPv4/v6 和 IPv4/v6 范围索引类型     |
| pg_uuidv7                    |  1.4   |    PGDG    | TYPE  | rpm     | UUIDv7 支持                                 |
| pgmp                         |  1.1   |    PGDG    | TYPE  | rpm     | 多精度算术扩展                                   |
| semver                       | 0.32.1 |    PGDG    | TYPE  | rpm     | 语义版本号数据类型                                 |
| timestamp9                   | 1.4.0  |    PGDG    | TYPE  | rpm     | 纳秒分辨率时间戳                                  |
| unit ❋                       |   7    |    PGDG    | TYPE  | rpm,deb | SI 国标单位扩展                                 |
| numeral                      |   1    |    PGDG    | TYPE  | deb     | 将数字转换为各语言的文本表示                            |
| pg_rational                  | 0.0.1  |    PGDG    | TYPE  | deb     | 有理数数据里诶行，可以表示 bigint 的分数                  |
| roaringbitmap                |  0.5   | **PIGSTY** | TYPE  | rpm     | 支持RoaringBitmap数据类型                       |
| amcheck                      |  1.3   |    PGDG    | INDEX | rpm     | 校验关系完整性                                   |
| adminpack                    |  2.1   |  CONTRIB   | ADMIN | sys     | PostgreSQL 管理函数集合                         |
| lo                           |  1.1   |  CONTRIB   | ADMIN | sys     | 大对象维护                                     |
| old_snapshot                 |  1.0   |  CONTRIB   | ADMIN | sys     | 支持 old_snapshot_threshold 的实用程序           |
| pg_prewarm                   |  1.2   |  CONTRIB   | ADMIN | sys     | 预热关系数据                                    |
| pg_surgery                   |  1.0   |  CONTRIB   | ADMIN | sys     | 对损坏的关系进行手术                                |
| dblink                       |  1.2   |  CONTRIB   |  FDW  | sys     | 从数据库内连接到其他 PostgreSQL 数据库                 |
| file_fdw                     |  1.0   |  CONTRIB   |  FDW  | sys     | 访问外部文件的外部数据包装器                            |
| postgres_fdw                 |  1.1   |  CONTRIB   |  FDW  | sys     | 用于远程 PostgreSQL 服务器的外部数据包装器               |
| gzip                         |  1.0   | **PIGSTY** | FUNC  | rpm     | 使用SQL执行Gzip压缩与解压缩                         |
| http                         |  1.6   | **PIGSTY** | FUNC  | rpm     | HTTP客户端，允许在数据库内收发HTTP请求 (supabase)        |
| pg_net                       | 0.8.0  | **PIGSTY** | FUNC  | rpm,u22 | 用 SQL 进行异步非阻塞HTTP/HTTPS 请求的扩展 (supabase)  |
| pgjwt                        | 0.2.0  | **PIGSTY** | FUNC  | rpm     | JSON Web Token API 的PG实现 (supabase)       |
| vault                        | 0.2.9  | **PIGSTY** | FUNC  | rpm     | 在 Vault 中存储加密凭证的扩展  (supabase)            |
| imgsmlr ❋                    | 1.0.0  | **PIGSTY** | FUNC  | rpm     | 使用Haar小波分析计算图片相似度                         |
| pg_similarity ❋              | 1.0.0  | **PIGSTY** | FUNC  | rpm,deb | 提供17种距离度量函数                               |
| autoinc                      |  1.0   |  CONTRIB   | FUNC  | sys     | 用于自动递增字段的函数                               |
| dict_int                     |  1.0   |  CONTRIB   | FUNC  | sys     | 用于整数的文本搜索字典模板                             |
| dict_xsyn                    |  1.0   |  CONTRIB   | FUNC  | sys     | 用于扩展同义词处理的文本搜索字典模板                        |
| earthdistance                |  1.1   |  CONTRIB   | FUNC  | sys     | 计算地球表面上的大圆距离                              |
| fuzzystrmatch                |  1.1   |  CONTRIB   | FUNC  | sys     | 确定字符串之间的相似性和距离                            |
| insert_username              |  1.0   |  CONTRIB   | FUNC  | sys     | 用于跟踪谁更改了表的函数                              |
| intagg                       |  1.1   |  CONTRIB   | FUNC  | sys     | 整数聚合器和枚举器（过时）                             |
| intarray                     |  1.5   |  CONTRIB   | FUNC  | sys     | 1维整数数组的额外函数、运算符和索引支持                      |
| moddatetime                  |  1.0   |  CONTRIB   | FUNC  | sys     | 跟踪最后修改时间                                  |
| pg_trgm                      |  1.6   |  CONTRIB   | FUNC  | sys     | 文本相似度测量函数与模糊检索                            |
| pgcrypto                     |  1.3   |  CONTRIB   | FUNC  | sys     | 实用加解密函数                                   |
| refint                       |  1.0   |  CONTRIB   | FUNC  | sys     | 实现引用完整性的函数                                |
| tablefunc                    |  1.0   |  CONTRIB   | FUNC  | sys     | 交叉表函数                                     |
| tcn                          |  1.0   |  CONTRIB   | FUNC  | sys     | 用触发器通知变更                                  |
| tsm_system_rows              |  1.0   |  CONTRIB   | FUNC  | sys     | 接受行数限制的 TABLESAMPLE 方法                    |
| tsm_system_time              |  1.0   |  CONTRIB   | FUNC  | sys     | 接受毫秒数限制的 TABLESAMPLE 方法                   |
| uuid-ossp                    |  1.1   |  CONTRIB   | FUNC  | sys     | 生成通用唯一标识符（UUIDs）                          |
| btree_gin                    |  1.3   |  CONTRIB   | FUNC  | sys     | 用GIN索引常见数据类型                              |
| btree_gist                   |  1.7   |  CONTRIB   | FUNC  | sys     | 用GiST索引常见数据类型                             |
| bool_plperl                  |  1.0   |  CONTRIB   | LANG  | sys     | 在 bool 和 plperl 之间转换                      |
| bool_plperlu                 |  1.0   |  CONTRIB   | LANG  | sys     | 在 bool 和 plperlu 之间转换                     |
| hstore_plpython3u            |  1.0   |  CONTRIB   | LANG  | sys     | 在 hstore 和 plpython3u 之间转换                |
| jsonb_plperl                 |  1.0   |  CONTRIB   | LANG  | sys     | 在 jsonb 和 plperl 之间转换                     |
| jsonb_plperlu                |  1.0   |  CONTRIB   | LANG  | sys     | 在 jsonb 和 plperlu 之间转换                    |
| jsonb_plpython3u             |  1.0   |  CONTRIB   | LANG  | sys     | 在 jsonb 和 plpython3u 之间转换                 |
| ltree_plpython3u             |  1.0   |  CONTRIB   | LANG  | sys     | 在 ltree 和 plpython3u 之间转换                 |
| plperl                       |  1.0   |  CONTRIB   | LANG  | sys     | PL/Perl 存储过程语言                            |
| plperlu                      |  1.0   |  CONTRIB   | LANG  | sys     | PL/PerlU 存储过程语言（未受信/高权限）                  |
| plpgsql                      |  1.0   |  CONTRIB   | LANG  | sys     | PL/pgSQL 程序设计语言                           |
| plpython3u                   |  1.0   |  CONTRIB   | LANG  | sys     | PL/Python3 存储过程语言（未受信/高权限）                |
| pltcl                        |  1.0   |  CONTRIB   | LANG  | sys     | PL/TCL 存储过程语言                             |
| pltclu                       |  1.0   |  CONTRIB   | LANG  | sys     | PL/TCL 存储过程语言（未受信/高权限）                    |
| pageinspect                  |  1.12  |  CONTRIB   | STAT  | sys     | 检查数据库页面二进制内容                              |
| pg_buffercache               |  1.3   |  CONTRIB   | STAT  | sys     | 检查共享缓冲区缓存                                 |
| pg_freespacemap              |  1.2   |  CONTRIB   | STAT  | sys     | 检查自由空间映射的内容（FSM）                          |
| pg_stat_statements           |  1.10  |  CONTRIB   | STAT  | sys     | 跟踪所有执行的 SQL 语句的计划和执行统计信息                  |
| pg_visibility                |  1.2   |  CONTRIB   | STAT  | sys     | 检查可见性图（VM）和页面级可见性信息                       |
| pg_walinspect                |  1.1   |  CONTRIB   | STAT  | sys     | 用于检查 PostgreSQL WAL 日志内容的函数               |
| pgrowlocks                   |  1.2   |  CONTRIB   | STAT  | sys     | 显示行级锁信息                                   |
| pgstattuple                  |  1.5   |  CONTRIB   | STAT  | sys     | 显示元组级统计信息                                 |
| sslinfo                      |  1.2   |  CONTRIB   | STAT  | sys     | 关于 SSL 证书的信息                              |
| cube                         |  1.5   |  CONTRIB   | TYPE  | sys     | 用于存储多维立方体的数据类型                            |
| hstore                       |  1.8   |  CONTRIB   | TYPE  | sys     | 用于存储（键，值）对集合的数据类型                         |
| isn                          |  1.2   |  CONTRIB   | TYPE  | sys     | 用于国际产品编号标准的数据类型                           |
| ltree                        |  1.2   |  CONTRIB   | TYPE  | sys     | 用于表示分层树状结构的数据类型                           |
| prefix                       | 1.2.0  |  CONTRIB   | TYPE  | sys     | 前缀树数据类型                                   |
| seg                          |  1.4   |  CONTRIB   | TYPE  | sys     | 表示线段或浮点间隔的数据类型                            |
| xml2                         |  1.1   |  CONTRIB   | TYPE  | sys     | XPath 查询和 XSLT                            |

> 带有 '❋' 标记的扩展目前尚未提供对 PG16 的支持，但仍可在旧版本（15-）的 PostgreSQL 上使用。
