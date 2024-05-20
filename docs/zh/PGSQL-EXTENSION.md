# PostgreSQL 扩展插件

> 扩展是 PostgreSQL 的灵魂所在，完整的扩展列表，请参考[这里](https://pigsty.cc/zh/docs/reference/extension/)

Pigsty 收录了超过 255 个预先编译打包、开箱即用的 PostgreSQL 强力扩展插件，其中包括一些强力扩展：

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


Pigsty 提供了丰富的 PostgreSQL 扩展插件支持，包括 **230** 个 [**RPM扩展**](#rpm扩展) 与 **189** 个 [**DEB扩展**](#deb扩展)。

Pigsty 总共提供了 **255** 个可用扩展，其中含 PostgreSQL 自带的 **73** 个[**内置扩展**](#自带扩展)）。 [**Pigsty 仓库**](#pigsty扩展)的 维护了 **34** 个 RPM 扩展与 **10** 个 DEB 扩展。


-----------------

### RPM扩展

Pigsty 在 [EL系操作系统](/zh/docs/reference/compatibility#el系发行版支持) 上共有 **230** 个扩展，其中包括 **73** 个 PostgreSQL [自带扩展](#自带扩展) 和 **157** 个额外的 RPM 扩展，其中由 Pigsty 维护的占 **34** 个。

> 统计以 EL8 版本为基准，有 6 个扩展尚未针对 PG 16 完成适配（带有 `❋` 标记） —— 故目前实际可用扩展为 224 个。

| 扩展                           | 版本      | 包名     | 仓库              | 包名                          | 说明                                        | 备注                  |
|:-----------------------------|:--------|:-------|:----------------|:----------------------------|:------------------------------------------|:--------------------|
| ddlx                         | 0.27    | ADMIN  | pgdg16          | ddlx_16                     | DDL 提取器                                   |                     |
| **pg_cron**                  | 1.6     | ADMIN  | pgdg16          | pg_cron_16                  | 定时任务调度器                                   |                     |
| pg_dirtyread                 | 2       | ADMIN  | pigsty-pgsql    | pg_dirtyread_16             | 从表中读取尚未垃圾回收的行                             |                     |
| pg_readonly                  | 1.0.0   | ADMIN  | pgdg16          | pg_readonly_16              | 将集群设置为只读                                  |                     |
| **pg_repack**                | 1.5.0   | ADMIN  | pgdg16          | pg_repack_16                | 在线垃圾清理与表膨胀治理                              |                     |
| pg_squeeze                   | 1.6     | ADMIN  | pgdg16          | pg_squeeze_16               | 从关系中删除未使用空间                               |                     |
| pgagent                      | 4.2     | ADMIN  | pgdg16          | pgagent_16                  | PostgreSQL任务调度工具，与PGADMIN配合使用             |                     |
| pgautofailover               | 2.1     | ADMIN  | pgdg16          | pg_auto_failover_16         | PG 自动故障迁移                                 |                     |
| pgdd                         | 0.5.2   | ADMIN  | pigsty-pgsql    | pgdd_16                     | 提供通过标准SQL查询数据库目录集簇的能力                     |                     |
| pgfincore                    | 1.3.1   | ADMIN  | pgdg16          | pgfincore_16                | 检查和管理操作系统缓冲区缓存                            |                     |
| pgl_ddl_deploy               | 2.2     | ADMIN  | pgdg16          | pgl_ddl_deploy_16           | 使用 pglogical 执行自动 DDL 部署                  |                     |
| pgpool_adm                   | 1.5     | ADMIN  | pgdg16          | pgpool-II-pg16-extensions   | PGPool 管理函数                               |                     |
| pgpool_recovery              | 1.4     | ADMIN  | pgdg16          | pgpool-II-pg16-extensions   | PGPool辅助扩展，从v4.3提供的恢复函数                   |                     |
| pgpool_regclass              | 1.0     | ADMIN  | pgdg16          | pgpool-II-pg16-extensions   | PGPool辅助扩展，RegClass替代                     |                     |
| prioritize                   | 1.0     | ADMIN  | pgdg16          | prioritize_16               | 获取和设置 PostgreSQL 后端的优先级                   |                     |
| safeupdate                   | 1.4     | ADMIN  | pgdg16          | safeupdate_16               | 强制在 UPDATE 和 DELETE 时提供 Where 条件          |                     |
| pg_tiktoken                  | 0.0.1   | AI     | pigsty-pgsql    | pg_tiktoken_16              | 在PostgreSQL中计算OpenAI使用的Token数             |                     |
| **pgml**                     | 2.8.1   | AI     | pigsty-pgsql    | pgml_16                     | PostgresML：用SQL运行机器学习算法并训练模型              |                     |
| svector                      | 0.6.1   | AI     | pigsty-pgsql    | pg_sparse_16                | ParadeDB 稀疏向量数据库类型与HNSW索引                 | obsolete            |
| **vector**                   | 0.7.0   | AI     | pgdg16          | pgvector_16                 | 向量数据类型和 ivfflat / hnsw 访问方法               |                     |
| vectorize                    | 0.15.0  | AI     | pigsty-pgsql    | pg_vectorize_16             | 在PostgreSQL中封装RAG向量检索服务                   | deps: pgmq, pg_cron |
| decoderbufs                  | 0.1.0   | ETL    | pgdg16          | postgres-decoderbufs_16     | 将WAL逻辑解码为ProtocolBuffer协议的消息              |                     |
| pg_bulkload                  | 3.1.21  | ETL    | pgdg16          | pg_bulkload_16              | 向 PostgreSQL 中高速加载数据                      |                     |
| pg_fact_loader               | 2.0     | ETL    | pgdg16          | pg_fact_loader_16           | 在 Postgres 中构建事实表                         |                     |
| **wal2json**                 | 2.5.3   | ETL    | pgdg16          | wal2json_16                 | 用逻辑解码捕获 JSON 格式的 CDC 变更                   |                     |
| db2_fdw                      | 6.0.1   | FDW    | pgdg16-non-free | db2_fdw_16                  | 提供对DB2的外部数据源包装器                           | extra db2 deps      |
| hdfs_fdw                     | 2.0.5   | FDW    | pgdg16          | hdfs_fdw_16                 | hdfs 外部数据包装器                              |                     |
| mongo_fdw                    | 1.1     | FDW    | pgdg16          | mongo_fdw_16                | MongoDB 外部数据包装器                           |                     |
| mysql_fdw                    | 1.2     | FDW    | pgdg16          | mysql_fdw_16                | MySQL外部数据包装器                              |                     |
| ogr_fdw                      | 1.1     | FDW    | pgdg16          | ogr_fdw_16                  | GIS 数据外部数据源包装器                            |                     |
| oracle_fdw                   | 1.2     | FDW    | pgdg16-non-free | oracle_fdw_16               | 提供对Oracle的外部数据源包装器                        | extra oracle deps   |
| pgbouncer_fdw                | 1.1.0   | FDW    | pgdg16          | pgbouncer_fdw_16            | 用 SQL 查询 pgbouncer 统计信息，执行 pgbouncer 命令。  |                     |
| sqlite_fdw                   | 1.1     | FDW    | pgdg16          | sqlite_fdw_16               | SQLite 外部数据包装器                            |                     |
| tds_fdw                      | 2.0.3   | FDW    | pgdg16          | tds_fdw_16                  | TDS 数据库（Sybase/SQL Server）外部数据包装器         |                     |
| **wrappers**                 | 0.3.1   | FDW    | pigsty-pgsql    | wrappers_16                 | Supabase提供的外部数据源包装器捆绑包                    |                     |
| **age**                      | 1.5.0   | FEAT   | pigsty-pgsql    | age_16                      | Apache AGE，图数据库扩展 （Deb可用）                 |                     |
| emaj                         | 4.4.0   | FEAT   | pgdg16          | e-maj_16                    | 让数据库的子集具有细粒度日志和时间旅行功能                     |                     |
| hll                          | 2.18    | FEAT   | pgdg16          | hll_16                      | hyperloglog 数据类型                          |                     |
| hypopg                       | 1.4.1   | FEAT   | pgdg16          | hypopg_16                   | 假设索引，用于创建一个虚拟索引检验执行计划                     |                     |
| jsquery                      | 1.1     | FEAT   | pgdg16          | jsquery_16                  | 用于内省 JSONB 数据类型的查询类型                      |                     |
| periods                      | 1.2     | FEAT   | pgdg16          | periods_16                  | 为 PERIODs 和 SYSTEM VERSIONING 提供标准 SQL 功能 |                     |
| **pg_graphql**               | 1.5.4   | FEAT   | pigsty-pgsql    | pg_graphql_16               | PG内的 GraphQL 支持 (RUST, supabase)          |                     |
| pg_hint_plan                 | 1.6.0   | FEAT   | pgdg16          | pg_hint_plan_16             | 添加强制指定执行计划的能力                             |                     |
| pg_ivm                       | 1.8     | FEAT   | pgdg16          | pg_ivm_16                   | 增量维护的物化视图                                 |                     |
| **pg_jsonschema**            | 0.3.1   | FEAT   | pigsty-pgsql    | pg_jsonschema_16            | 提供JSON Schema校验能力                         |                     |
| **pg_strom**                 | 5.1     | FEAT   | pgdg16-non-free | pg_strom_16                 | 使用GPU与NVMe加速大数据处理                         | extra cuda deps     |
| **pgmq**                     | 1.1.1   | FEAT   | pigsty-pgsql    | pgmq_16                     | 基于Postgres实现类似AWS SQS/RSMQ的消息队列           |                     |
| **pgq**                      | 3.5.1   | FEAT   | pgdg16          | pgq_16                      | 通用队列的PG实现                                 |                     |
| pgtt                         | 3.1.0   | FEAT   | pgdg16          | pgtt_16                     | 全局临时表功能                                   |                     |
| rum                          | 1.3     | FEAT   | pgdg16          | rum_16                      | RUM 索引访问方法                                |                     |
| table_version                | 1.10.3  | FEAT   | pgdg16          | table_version_16            | PostgreSQL 版本控制表扩展                        |                     |
| temporal_tables              | 1.2.2   | FEAT   | pgdg16          | temporal_tables_16          | 时态表功能支持                                   |                     |
| count_distinct               | 3.0.1   | FUNC   | pgdg16          | count_distinct_16           | COUNT(DISTINCT ...) 聚合的替代方案               |                     |
| extra_window_functions       | 1.0     | FUNC   | pgdg16          | extra_window_functions_16   | 额外的窗口函数                                   |                     |
| gzip                         | 1.0     | FUNC   | pgdg16          | pgsql_gzip_16               | 使用SQL执行Gzip压缩与解压缩                         | new in pgdg         |
| http                         | 1.6     | FUNC   | pgdg16          | pgsql_http_16               | HTTP客户端，允许在数据库内收发HTTP请求 (supabase)        | new in pgdg         |
| pg_background                | 1.0     | FUNC   | pgdg16          | pg_background_16            | 在后台运行 SQL 查询                              |                     |
| pg_idkit                     | 0.2.3   | FUNC   | pigsty-pgsql    | pg_idkit_16                 | 生成各式各样的唯一标识符：UUIDv6, ULID, KSUID          |                     |
| pg_later                     | 0.1.0   | FUNC   | pigsty-pgsql    | pg_later_16                 | 执行查询，并在稍后异步获取查询结果                         | dep: pgmq           |
| **pg_net**                   | 0.9.1   | FUNC   | pgdg16          | pg_net_16                   | 用 SQL 进行异步非阻塞HTTP/HTTPS 请求的扩展 (supabase)  |                     |
| pgjwt                        | 0.2.0   | FUNC   | pigsty-pgsql    | pgjwt_16                    | JSON Web Token API 的PG实现 (supabase)       |                     |
| pgsql_tweaks                 | 0.10.2  | FUNC   | pgdg16          | pgsql_tweaks_16             | 一些便利函数与视图                                 |                     |
| tdigest                      | 1.4.1   | FUNC   | pgdg16          | tdigest_16                  | tdigest 聚合函数                              |                     |
| topn                         | 2.6.0   | FUNC   | pgdg16          | topn_16                     | top-n JSONB 的类型                           |                     |
| address_standardizer         | 3.4.2   | GIS    | pgdg16          | postgis34_16                | 地址标准化函数。                                  |                     |
| address_standardizer_data_us | 3.4.2   | GIS    | pgdg16          | postgis34_16                | 地址标准化函数：美国数据集示例                           |                     |
| h3                           | 4.1.3   | GIS    | pgdg16          | h3-pg_16                    | H3六边形层级索引支持                               |                     |
| h3_postgis                   | 4.1.3   | GIS    | pgdg16          | h3-pg_16                    | 将 H3 与 PostGIS相集成                         |                     |
| pgrouting                    | 3.6.0   | GIS    | pgdg16          | pgrouting_16                | 提供寻路能力                                    |                     |
| pointcloud                   | 1.2.5   | GIS    | pigsty-pgsql    | pointcloud_16               | 提供激光雷达点云数据类型支持                            |                     |
| pointcloud_postgis           | 1.2.5   | GIS    | pgdg16          | pointcloud_16               | 将激光雷达点云与PostGIS几何类型相集成                    |                     |
| **postgis**                  | 3.4.2   | GIS    | pgdg16          | postgis34_16                | PostGIS 几何和地理空间扩展                         |                     |
| postgis_raster               | 3.4.2   | GIS    | pgdg16          | postgis34_16                | PostGIS 光栅类型和函数                           |                     |
| postgis_sfcgal               | 3.4.2   | GIS    | pgdg16          | postgis34_16                | PostGIS SFCGAL 函数                         |                     |
| postgis_tiger_geocoder       | 3.4.2   | GIS    | pgdg16          | postgis34_16                | PostGIS tiger 地理编码器和反向地理编码器               |                     |
| postgis_topology             | 3.4.2   | GIS    | pgdg16          | postgis34_16                | PostGIS 拓扑空间类型和函数                         |                     |
| pg_tle                       | 1.4.0   | LANG   | pigsty-pgsql    | pg_tle_16                   | AWS 可信语言扩展                                |                     |
| pldbgapi                     | 1.1     | LANG   | pgdg16          | pldebugger_16               | 用于调试 PL/pgSQL 函数的服务器端支持                   |                     |
| pllua                        | 2.0     | LANG   | pgdg16          | pllua_16                    | Lua 程序语言                                  |                     |
| plluau                       | 2.0     | LANG   | pgdg16          | pllua_16                    | Lua 程序语言（不受信任的）                           |                     |
| plpgsql_check                | 2.7     | LANG   | pgdg16          | plpgsql_check_16            | 对 plpgsql 函数进行扩展检查                        |                     |
| plprql                       | 0.1.0   | LANG   | pigsty-pgsql    | plprql_16                   | 在PostgreSQL使用PRQL——管线式关系查询语言              |                     |
| plr                          | 8.4.6   | LANG   | pgdg16          | plr_16                      | 从数据库中加载R语言解释器并执行R脚本                       |                     |
| plsh                         | 2       | LANG   | pgdg16          | plsh_16                     | PL/sh 程序语言                                |                     |
| **plv8**                     | 3.2.2   | LANG   | pigsty-pgsql    | plv8_16                     | PL/JavaScript (v8) 可信过程程序语言               |                     |
| citus_columnar               | 11.3-1  | OLAP   | pgdg16          | citus_16                    | Citus 列式存储                                | citus               |
| **columnar**                 | 11.1-11 | OLAP   | pigsty-pgsql    | hydra_16                    | 开源列式存储扩展                                  | hydra 1.1.2         |
| **duckdb_fdw**               | 1.1     | OLAP   | pigsty-pgsql    | duckdb_fdw_16               | DuckDB 外部数据源包装器 (libduck 0.10.2)          | libduckdb 0.10.2    |
| **parquet_s3_fdw**           | 0.3     | OLAP   | pigsty-pgsql    | parquet_s3_fdw_16           | 针对S3/MinIO上的Parquet文件的外部数据源包装器            | deps: libarrow-s3   |
| **pg_analytics**             | 0.6.1   | OLAP   | pigsty-pgsql    | pg_analytics_16             | ParadeDB 列存x向量执行分析加速插件                    |                     |
| **pg_lakehouse**             | 0.7.0   | OLAP   | pigsty-pgsql    | pg_lakehouse_16             | ParadeDB 湖仓分析引擎                           | rust                |
| pg_tier                      | 0.0.3   | OLAP   | pigsty-pgsql    | pg_tier_16                  | 将冷数据分级存储至S3                               | 依赖parquet_s3_fdw    |
| **timescaledb**              | 2.15.0  | OLAP   | timescaledb     | timescaledb-2-postgresql-16 | 时序数据库扩展插件                                 |                     |
| **pglogical**                | 2.4.4   | REPL   | pgdg16          | pglogical_16                | 第三方逻辑复制支持                                 |                     |
| pglogical_origin             | 1.0.0   | REPL   | pgdg16          | pglogical_16                | 用于从 Postgres 9.4 升级时的兼容性虚拟扩展              |                     |
| repmgr                       | 5.4     | REPL   | pgdg16          | repmgr_16                   | PostgreSQL复制管理组件                          |                     |
| pg_bigm                      | 1.2     | SEARCH | pgdg16          | pg_bigm_16                  | 基于二字组的多语言全文检索扩展                           |                     |
| **pg_search**                | 0.7.0   | SEARCH | pigsty-pgsql    | pg_search_16                | ParadeDB BM25算法全文检索插件，ES全文检索              | old name: pg_bm25   |
| **zhparser**                 | 2.2     | SEARCH | pigsty-pgsql    | zhparser_16                 | 中文分词，全文搜索解析器                              | deps: scws          |
| anon                         | 1.3.2   | SEC    | pgdg16          | postgresql_anonymizer_16    | 数据匿名化处理工具                                 |                     |
| credcheck                    | 2.7.0   | SEC    | pgdg16          | credcheck_16                | 明文凭证检查器                                   |                     |
| logerrors                    | 2.1     | SEC    | pgdg16          | logerrors_16                | 用于收集日志文件中消息统计信息的函数                        |                     |
| login_hook                   | 1.5     | SEC    | pgdg16          | login_hook_16               | 在用户登陆时执行login_hook.login()函数              |                     |
| passwordcracklib             | 3.0.0   | SEC    | pgdg16          | passwordcracklib_16         | 使用cracklib加固PG用户密码                        |                     |
| pg_auth_mon                  | 1.1     | SEC    | pgdg16          | pg_auth_mon_16              | 监控每个用户的连接尝试                               |                     |
| pg_jobmon                    | 1.4.1   | SEC    | pgdg16          | pg_jobmon_16                | 记录和监控函数                                   |                     |
| **pg_tde**                   | 1.0     | SEC    | pigsty-pgsql    | pg_tde_16                   | 试点性质的加密存储引擎                               | alpha               |
| pgaudit                      | 16.0    | SEC    | pgdg16          | pgaudit_16                  | 提供审计功能                                    |                     |
| pgauditlogtofile             | 1.5     | SEC    | pgdg16          | pgauditlogtofile_16         | pgAudit 子扩展，将审计日志写入单独的文件中                 |                     |
| pgcryptokey                  | 1.0     | SEC    | pgdg16          | pgcryptokey_16              | PG密钥管理                                    |                     |
| **pgsmcrypto**               | 0.1.0   | SEC    | pigsty-pgsql    | pgsmcrypto_16               | 为PostgreSQL提供商密算法支持：SM2,SM3,SM4           |                     |
| pgsodium                     | 3.1.9   | SEC    | pgdg16          | pgsodium_16                 | 表数据加密存储 TDE                               |                     |
| set_user                     | 4.0.1   | SEC    | pgdg16          | set_user_16                 | 增加了日志记录的 SET ROLE                         |                     |
| supabase_vault               | 0.2.8   | SEC    | pigsty-pgsql    | vault_16                    | 在 Vault 中存储加密凭证的扩展 (supabase)             |                     |
| **citus**                    | 12.1-1  | SHARD  | pgdg16          | citus_16                    | Citus 分布式数据库                              |                     |
| pg_fkpart                    | 1.7     | SHARD  | pgdg16          | pg_fkpart_16                | 按外键实用程序进行表分区的扩展                           |                     |
| pg_partman                   | 5.1.0   | SHARD  | pgdg16          | pg_partman_16               | 用于按时间或 ID 管理分区表的扩展                        |                     |
| orafce                       | 4.10    | SIM    | pgdg16          | orafce_16                   | 模拟 Oracle RDBMS 的一部分函数和包的函数和运算符           |                     |
| pg_dbms_job                  | 1.5.0   | SIM    | pgdg16          | pg_dbms_job_16              | 添加 Oracle DBMS_JOB 兼容性支持的扩展               |                     |
| pg_dbms_lock                 | 1.0.0   | SIM    | pgdg16          | pg_dbms_lock_16             | 为PG添加对 Oracle DBMS_LOCK 的完整兼容性支持          |                     |
| pg_dbms_metadata             | 1.0.0   | SIM    | pgdg16          | pg_dbms_metadata_16         | 添加 Oracle DBMS_METADATA 兼容性支持的扩展          |                     |
| pg_extra_time                | 1.1.2   | SIM    | pgdg16          | pg_extra_time_16            | 一些关于日期与时间的扩展函数                            |                     |
| pgmemcache                   | 2.3.0   | SIM    | pgdg16          | pgmemcache_16               | 为 PG 提供 memcached 借口                      |                     |
| pg_permissions               | 1.1     | STAT   | pgdg16          | pg_permissions_16           | 查看对象权限并将其与期望状态进行比较                        |                     |
| pg_profile                   | 4.6     | STAT   | pgdg16          | pg_profile_16               | PostgreSQL 数据库负载记录与AWR报表工具                |                     |
| pg_qualstats                 | 2.1.0   | STAT   | pgdg16          | pg_qualstats_16             | 收集有关 quals 的统计信息的扩展                       |                     |
| pg_show_plans                | 2.1     | STAT   | pgdg16          | pg_show_plans_16            | 打印所有当前正在运行查询的执行计划                         |                     |
| pg_stat_kcache               | 2.2.3   | STAT   | pgdg16          | pg_stat_kcache_16           | 内核统计信息收集                                  |                     |
| pg_stat_monitor              | 2.0     | STAT   | pgdg16          | pg_stat_monitor_16          | 提供查询聚合统计、客户端信息、执行计划详细信息和直方图               |                     |
| pg_statviz                   | 0.6     | STAT   | pgdg16          | pg_statviz_extension_16     | 可视化统计指标并分析时间序列                            |                     |
| pg_store_plans               | 1.8     | STAT   | pgdg16          | pg_store_plans_16           | 跟踪所有执行的 SQL 语句的计划统计信息                     |                     |
| pg_track_settings            | 2.1.2   | STAT   | pgdg16          | pg_track_settings_16        | 跟踪设置更改                                    |                     |
| pg_wait_sampling             | 1.1     | STAT   | pgdg16          | pg_wait_sampling_16         | 基于采样的等待事件统计                               |                     |
| pgexporter_ext               | 0.2.3   | STAT   | pgdg16          | pgexporter_ext_16           | PGExporter的额外指标支持                         |                     |
| pgmeminfo                    | 1.0     | STAT   | pgdg16          | pgmeminfo_16                | 显示内存使用情况                                  |                     |
| plprofiler                   | 4.2     | STAT   | pgdg16          | plprofiler_16               | 剖析 PL/pgSQL 函数                            |                     |
| powa                         | 4.2.2   | STAT   | pgdg16          | powa_16                     | PostgreSQL 工作负载分析器-核心                     |                     |
| system_stats                 | 2.0     | STAT   | pgdg16          | system_stats_16             | PostgreSQL 的系统统计函数                        |                     |
| dbt2                         | 0.45.0  | TEST   | pgdg16          | dbt2-pg16-extensions        | OSDL-DBT-2 测试组件                           |                     |
| faker                        | 0.5.3   | TEST   | pgdg16          | postgresql_faker_16         | 插入生成的测试伪造数据，Python库的包装                    | postgresql_faker    |
| pgtap                        | 1.3.3   | TEST   | pgdg16          | pgtap_16                    | PostgreSQL单元测试框架                          |                     |
| ip4r                         | 2.4     | TYPE   | pgdg16          | ip4r_16                     | PostgreSQL 的 IPv4/v6 和 IPv4/v6 范围索引类型     |                     |
| md5hash                      | 1.0.1   | TYPE   | pigsty-pgsql    | md5hash_16                  | 提供128位MD5的原生数据类型                          |                     |
| pg_uuidv7                    | 1.5     | TYPE   | pgdg16          | pg_uuidv7_16                | UUIDv7 支持                                 |                     |
| pgmp                         | 1.1     | TYPE   | pgdg16          | pgmp_16                     | 多精度算术扩展                                   |                     |
| prefix                       | 1.2.0   | TYPE   | pgdg16          | prefix_16                   | 前缀树数据类型                                   |                     |
| roaringbitmap                | 0.5     | TYPE   | pigsty-pgsql    | pg_roaringbitmap_16         | 支持RoaringBitmap数据类型                       |                     |
| semver                       | 0.32.1  | TYPE   | pgdg16          | semver_16                   | 语义版本号数据类型                                 |                     |
| timestamp9                   | 1.4.0   | TYPE   | pgdg16          | timestamp9_16               | 纳秒分辨率时间戳                                  |                     |
| uint                         | 0       | TYPE   | pgdg16          | uint_16                     | 无符号整型数据类型                                 |                     |
| unit                         | 7       | TYPE   | pgdg16          | postgresql-unit_16          | SI 国标单位扩展                                 |                     |
| imgsmlr ❋                    | 1.0.0   | AI     | pigsty-pgsql    | imgsmlr_16                  | 使用Haar小波分析计算图片相似度                         |                     |
| pg_similarity ❋              | 1.0.0   | AI     | pigsty-pgsql    | pg_similarity_16            | 提供17种距离度量函数                               |                     |
| multicorn ❋                  | 2.4     | FDW    | pgdg16          | multicorn2_16               | 用Python编写自定义的外部数据源包装器                     |                     |
| geoip ❋                      | 0.2.4   | GIS    | pgdg16          | geoip_16                    | IP 地理位置扩展（围绕 MaxMind GeoLite 数据集的包装器）     |                     |
| plproxy ❋                    | 2.10.0  | SHARD  | pgdg16          | plproxy_16                  | 作为过程语言实现的数据库分区                            |                     |
| mysqlcompat ❋                | 0.0.7   | SIM    | pgdg16          | mysqlcompat_16              | 尽可能在PG中实现MySQL的提供的函数                      |                     |


<details><summary>安装所有 EL8 扩展插件</summary>

```bash
yum install postgis34_16* timescaledb-2-postgresql-16* pgvector_16* pglogical_16* pg_cron_16* vault_16* pgjwt_16* pg_roaringbitmap_16* zhparser_16* hydra_16* apache-age_16* duckdb_fdw_16* pg_tde_16* md5hash_16* pg_dirtyread_16* plv8_16* parquet_s3_fdw_16* pgml_16 pg_graphql_16 wrappers_16 pg_jsonschema_16 pg_search_16 pg_lakehouse_16 pg_analytics_16 pgmq_16 pg_tier_16 pg_later_16 pg_vectorize_16 pg_tiktoken_16 pgdd_16 plprql_16 pgsmcrypto_16 pg_idkit_16 scws libduckdb libarrow-s3 pgFormatter pgxnclient luapgsql pgcopydb bgw_replstatus_16* count_distinct_16* credcheck_16* ddlx_16* e-maj_16* extra_window_functions_16* h3-pg_16* hdfs_fdw_16* hll_16* hypopg_16* ip4r_16* jsquery_16* logerrors_16* login_hook_16* mongo_fdw_16* mysql_fdw_16* ogr_fdw_16* orafce_16* passwordcheck_cracklib_16* periods_16* pg_auth_mon_16* pg_auto_failover_16* pg_background_16* pg_bigm_16* pg_bulkload_16* pg_catcheck_16* pg_checksums_16* pg_comparator_16* pg_dbms_job_16* pg_dbms_lock_16* pg_dbms_metadata_16* pg_extra_time_16* pg_fact_loader_16* pg_failover_slots_16* pg_filedump_16* pg_fkpart_16* pg_hint_plan_16* pg_ivm_16* pg_jobmon_16* pg_net_16* pg_partman_16* pg_permissions_16* pg_prioritize_16* pg_profile_16* pg_qualstats_16* pg_readonly_16* pg_show_plans_16* pg_squeeze_16* pg_stat_kcache_16* pg_stat_monitor_16* pg_statement_rollback_16* pg_statviz_extension_16 pg_store_plans_16* pg_tle_16* pg_top_16* pg_track_settings_16* pg_uuidv7_16* pg_wait_sampling_16* pgagent_16* pgaudit_16* pgauditlogtofile_16* pgbouncer_fdw_16* pgcryptokey_16* pgexportdoc_16* pgfincore_16* pgimportdoc_16* pgl_ddl_deploy_16* pgmemcache_16* pgmeminfo_16* pgmp_16* pgq_16* pgrouting_16* pgsodium_16* pgsql_gzip_16* pgsql_http_16* pgsql_tweaks_16* pgtap_16* pgtt_16* pguint_16* pldebugger_16* pllua_16* plpgsql_check_16* plprofiler_16* plsh_16* pointcloud_16* postgres-decoderbufs_16* postgresql_anonymizer_16* postgresql_faker_16* powa-archivist_16* powa_16* prefix_16* rum_16 safeupdate_16* semver_16* set_user_16* sqlite_fdw_16* system_stats_16* table_version_16* tdigest_16* tds_fdw_16* temporal_tables_16* timescaledb_16* timestamp9_16* topn_16*
```

- 尚未在 PGDG el8 pg16 仓库中准备就绪，因此未收录的扩展插件： `mysqlcompat_16 multicorn2_16* plproxy_16* geoip_16* postgresql-unit_16*`
- 收录于 PGDG el8 pg16 仓库中，但因为依赖过重而略过的扩展集： `plr_16* repmgr_16* pgexporter_ext_16* dbt2-pg16-extensions* pgpool-II-pg16-extensions`
- 收录在 PGDG el8 pg16-non-free 仓库中，需要额外依赖的扩展： `oracle_fdw_16* db2_fdw_16* pg_strom_16*`
- 因为与 hydra_16 扩展名冲突，需要从分支中二选一，而略过的扩展： `citus_16*`

</details>


<details><summary>安装所有 EL9 扩展插件</summary>

```bash
yum install postgis34_16* timescaledb-2-postgresql-16* pgvector_16* pglogical_16* pg_cron_16* vault_16* pgjwt_16* pg_roaringbitmap_16* zhparser_16* hydra_16* apache-age_16* duckdb_fdw_16* pg_tde_16* md5hash_16* pg_dirtyread_16* plv8_16* parquet_s3_fdw_16* pgml_16 pg_graphql_16 wrappers_16 pg_jsonschema_16 pg_search_16 pg_lakehouse_16 pg_analytics_16 pgmq_16 pg_tier_16 pg_later_16 pg_vectorize_16 pg_tiktoken_16 pgdd_16 plprql_16 pgsmcrypto_16 pg_idkit_16 scws libduckdb libarrow-s3 pgFormatter luapgsql pgcopydb bgw_replstatus_16* count_distinct_16* credcheck_16* ddlx_16* e-maj_16* extra_window_functions_16* h3-pg_16* hdfs_fdw_16* hll_16* hypopg_16* ip4r_16* jsquery_16* logerrors_16* login_hook_16* mongo_fdw_16* mysql_fdw_16* ogr_fdw_16* orafce_16* passwordcheck_cracklib_16* periods_16* pg_auth_mon_16* pg_auto_failover_16* pg_background_16* pg_bigm_16* pg_bulkload_16* pg_catcheck_16* pg_checksums_16* pg_comparator_16* pg_dbms_job_16* pg_dbms_lock_16* pg_dbms_metadata_16* pg_extra_time_16* pg_fact_loader_16* pg_failover_slots_16* pg_filedump_16* pg_fkpart_16* pg_hint_plan_16* pg_ivm_16* pg_jobmon_16* pg_net_16* pg_partman_16* pg_permissions_16* pg_prioritize_16* pg_profile_16* pg_qualstats_16* pg_readonly_16* pg_show_plans_16* pg_squeeze_16* pg_stat_kcache_16* pg_stat_monitor_16* pg_statement_rollback_16* pg_statviz_extension_16 pg_store_plans_16* pg_tle_16* pg_top_16* pg_track_settings_16* pg_uuidv7_16* pg_wait_sampling_16* pgagent_16* pgaudit_16* pgauditlogtofile_16* pgbouncer_fdw_16* pgcryptokey_16* pgexportdoc_16* pgfincore_16* pgimportdoc_16* pgl_ddl_deploy_16* pgmemcache_16* pgmeminfo_16* pgmp_16* pgq_16* pgrouting_16* pgsodium_16* pgsql_gzip_16* pgsql_http_16* pgsql_tweaks_16* pgtap_16* pgtt_16* pguint_16* pldebugger_16* pllua_16* plpgsql_check_16* plprofiler_16* plsh_16* pointcloud_16* postgres-decoderbufs_16* postgresql_anonymizer_16* postgresql_faker_16* powa-archivist_16* powa_16* prefix_16* rum_16 safeupdate_16* semver_16* set_user_16* sqlite_fdw_16* system_stats_16* tdigest_16* tds_fdw_16* temporal_tables_16* timescaledb_16* timestamp9_16* topn_16* firebird_fdw_16* sequential_uuids_16*
```

- 尚未在 PGDG el9 pg16 仓库中准备就绪，因此未收录的扩展插件： `mysqlcompat_16 multicorn2_16* plproxy_16* geoip_16* postgresql-unit_16* table_version_16* pgxnclient`
- 收录于 PGDG el9 pg16 仓库中，但因为依赖过重而略过的扩展集： `plr_16* repmgr_16* pgexporter_ext_16* dbt2-pg16-extensions* pgpool-II-pg16-extensions pljava_16`
- 收录在 PGDG el9 pg16-non-free 仓库中，需要额外依赖的扩展： `oracle_fdw_16* db2_fdw_16* pg_strom_16*`
- 因为与 hydra_16 扩展名冲突，需要从分支中二选一，而略过的扩展： `citus_16*`
- EL9 相对于EL8独有的软件包：`sequential_uuids_16* pljava*，firebird_fdw`
  - 增加：`pljava_16` 1.6.6  PL/Java procedural language (https://tada.github.io/pljava/)
  - 增加：`firebird_fdw_16` 1.3.0 foreign data wrapper for Firebird
  - 增加：`sequential_uuids` 1.0.2 generator of sequential UUIDs
  - 减少：`pgxnclient` 不可用
  - 减少：`table_version_16*` 不可用

</details>


-----------------

### DEB扩展

Pigsty 在 [EL系操作系统](/zh/docs/reference/compatibility#el系发行版支持) 上共有 **189** 个可用扩展，其中包括 **73** 个 PostgreSQL [自带扩展](#自带扩展) 和 **116** 个额外的 DEB 扩展，其中由 Pigsty 维护的占 **10** 个。

> DEB 扩展统计以 Debian 12 与 Ubuntu 22.04 为准，两者仅有个别扩展差异，见备注。

| 扩展                           | 版本      | 包名     | 仓库              | 包名                          | 说明                                        | 备注                  |
|:-----------------------------|:--------|:-------|:----------------|:----------------------------|:------------------------------------------|:--------------------|
| ddlx                         | 0.27    | ADMIN  | pgdg16          | ddlx_16                     | DDL 提取器                                   |                     |
| **pg_cron**                  | 1.6     | ADMIN  | pgdg16          | pg_cron_16                  | 定时任务调度器                                   |                     |
| pg_dirtyread                 | 2       | ADMIN  | pigsty-pgsql    | pg_dirtyread_16             | 从表中读取尚未垃圾回收的行                             |                     |
| pg_readonly                  | 1.0.0   | ADMIN  | pgdg16          | pg_readonly_16              | 将集群设置为只读                                  |                     |
| **pg_repack**                | 1.5.0   | ADMIN  | pgdg16          | pg_repack_16                | 在线垃圾清理与表膨胀治理                              |                     |
| pg_squeeze                   | 1.6     | ADMIN  | pgdg16          | pg_squeeze_16               | 从关系中删除未使用空间                               |                     |
| pgagent                      | 4.2     | ADMIN  | pgdg16          | pgagent_16                  | PostgreSQL任务调度工具，与PGADMIN配合使用             |                     |
| pgautofailover               | 2.1     | ADMIN  | pgdg16          | pg_auto_failover_16         | PG 自动故障迁移                                 |                     |
| pgdd                         | 0.5.2   | ADMIN  | pigsty-pgsql    | pgdd_16                     | 提供通过标准SQL查询数据库目录集簇的能力                     |                     |
| pgfincore                    | 1.3.1   | ADMIN  | pgdg16          | pgfincore_16                | 检查和管理操作系统缓冲区缓存                            |                     |
| pgl_ddl_deploy               | 2.2     | ADMIN  | pgdg16          | pgl_ddl_deploy_16           | 使用 pglogical 执行自动 DDL 部署                  |                     |
| pgpool_adm                   | 1.5     | ADMIN  | pgdg16          | pgpool-II-pg16-extensions   | PGPool 管理函数                               |                     |
| pgpool_recovery              | 1.4     | ADMIN  | pgdg16          | pgpool-II-pg16-extensions   | PGPool辅助扩展，从v4.3提供的恢复函数                   |                     |
| pgpool_regclass              | 1.0     | ADMIN  | pgdg16          | pgpool-II-pg16-extensions   | PGPool辅助扩展，RegClass替代                     |                     |
| prioritize                   | 1.0     | ADMIN  | pgdg16          | prioritize_16               | 获取和设置 PostgreSQL 后端的优先级                   |                     |
| safeupdate                   | 1.4     | ADMIN  | pgdg16          | safeupdate_16               | 强制在 UPDATE 和 DELETE 时提供 Where 条件          |                     |
| pg_tiktoken                  | 0.0.1   | AI     | pigsty-pgsql    | pg_tiktoken_16              | 在PostgreSQL中计算OpenAI使用的Token数             |                     |
| **pgml**                     | 2.8.1   | AI     | pigsty-pgsql    | pgml_16                     | PostgresML：用SQL运行机器学习算法并训练模型              |                     |
| svector                      | 0.6.1   | AI     | pigsty-pgsql    | pg_sparse_16                | ParadeDB 稀疏向量数据库类型与HNSW索引                 | obsolete            |
| **vector**                   | 0.7.0   | AI     | pgdg16          | pgvector_16                 | 向量数据类型和 ivfflat / hnsw 访问方法               |                     |
| vectorize                    | 0.15.0  | AI     | pigsty-pgsql    | pg_vectorize_16             | 在PostgreSQL中封装RAG向量检索服务                   | deps: pgmq, pg_cron |
| decoderbufs                  | 0.1.0   | ETL    | pgdg16          | postgres-decoderbufs_16     | 将WAL逻辑解码为ProtocolBuffer协议的消息              |                     |
| pg_bulkload                  | 3.1.21  | ETL    | pgdg16          | pg_bulkload_16              | 向 PostgreSQL 中高速加载数据                      |                     |
| pg_fact_loader               | 2.0     | ETL    | pgdg16          | pg_fact_loader_16           | 在 Postgres 中构建事实表                         |                     |
| **wal2json**                 | 2.5.3   | ETL    | pgdg16          | wal2json_16                 | 用逻辑解码捕获 JSON 格式的 CDC 变更                   |                     |
| db2_fdw                      | 6.0.1   | FDW    | pgdg16-non-free | db2_fdw_16                  | 提供对DB2的外部数据源包装器                           | extra db2 deps      |
| hdfs_fdw                     | 2.0.5   | FDW    | pgdg16          | hdfs_fdw_16                 | hdfs 外部数据包装器                              |                     |
| mongo_fdw                    | 1.1     | FDW    | pgdg16          | mongo_fdw_16                | MongoDB 外部数据包装器                           |                     |
| mysql_fdw                    | 1.2     | FDW    | pgdg16          | mysql_fdw_16                | MySQL外部数据包装器                              |                     |
| ogr_fdw                      | 1.1     | FDW    | pgdg16          | ogr_fdw_16                  | GIS 数据外部数据源包装器                            |                     |
| oracle_fdw                   | 1.2     | FDW    | pgdg16-non-free | oracle_fdw_16               | 提供对Oracle的外部数据源包装器                        | extra oracle deps   |
| pgbouncer_fdw                | 1.1.0   | FDW    | pgdg16          | pgbouncer_fdw_16            | 用 SQL 查询 pgbouncer 统计信息，执行 pgbouncer 命令。  |                     |
| sqlite_fdw                   | 1.1     | FDW    | pgdg16          | sqlite_fdw_16               | SQLite 外部数据包装器                            |                     |
| tds_fdw                      | 2.0.3   | FDW    | pgdg16          | tds_fdw_16                  | TDS 数据库（Sybase/SQL Server）外部数据包装器         |                     |
| **wrappers**                 | 0.3.1   | FDW    | pigsty-pgsql    | wrappers_16                 | Supabase提供的外部数据源包装器捆绑包                    |                     |
| **age**                      | 1.5.0   | FEAT   | pigsty-pgsql    | age_16                      | Apache AGE，图数据库扩展 （Deb可用）                 |                     |
| emaj                         | 4.4.0   | FEAT   | pgdg16          | e-maj_16                    | 让数据库的子集具有细粒度日志和时间旅行功能                     |                     |
| hll                          | 2.18    | FEAT   | pgdg16          | hll_16                      | hyperloglog 数据类型                          |                     |
| hypopg                       | 1.4.1   | FEAT   | pgdg16          | hypopg_16                   | 假设索引，用于创建一个虚拟索引检验执行计划                     |                     |
| jsquery                      | 1.1     | FEAT   | pgdg16          | jsquery_16                  | 用于内省 JSONB 数据类型的查询类型                      |                     |
| periods                      | 1.2     | FEAT   | pgdg16          | periods_16                  | 为 PERIODs 和 SYSTEM VERSIONING 提供标准 SQL 功能 |                     |
| **pg_graphql**               | 1.5.4   | FEAT   | pigsty-pgsql    | pg_graphql_16               | PG内的 GraphQL 支持 (RUST, supabase)          |                     |
| pg_hint_plan                 | 1.6.0   | FEAT   | pgdg16          | pg_hint_plan_16             | 添加强制指定执行计划的能力                             |                     |
| pg_ivm                       | 1.8     | FEAT   | pgdg16          | pg_ivm_16                   | 增量维护的物化视图                                 |                     |
| **pg_jsonschema**            | 0.3.1   | FEAT   | pigsty-pgsql    | pg_jsonschema_16            | 提供JSON Schema校验能力                         |                     |
| **pg_strom**                 | 5.1     | FEAT   | pgdg16-non-free | pg_strom_16                 | 使用GPU与NVMe加速大数据处理                         | extra cuda deps     |
| **pgmq**                     | 1.1.1   | FEAT   | pigsty-pgsql    | pgmq_16                     | 基于Postgres实现类似AWS SQS/RSMQ的消息队列           |                     |
| **pgq**                      | 3.5.1   | FEAT   | pgdg16          | pgq_16                      | 通用队列的PG实现                                 |                     |
| pgtt                         | 3.1.0   | FEAT   | pgdg16          | pgtt_16                     | 全局临时表功能                                   |                     |
| rum                          | 1.3     | FEAT   | pgdg16          | rum_16                      | RUM 索引访问方法                                |                     |
| table_version                | 1.10.3  | FEAT   | pgdg16          | table_version_16            | PostgreSQL 版本控制表扩展                        |                     |
| temporal_tables              | 1.2.2   | FEAT   | pgdg16          | temporal_tables_16          | 时态表功能支持                                   |                     |
| count_distinct               | 3.0.1   | FUNC   | pgdg16          | count_distinct_16           | COUNT(DISTINCT ...) 聚合的替代方案               |                     |
| extra_window_functions       | 1.0     | FUNC   | pgdg16          | extra_window_functions_16   | 额外的窗口函数                                   |                     |
| gzip                         | 1.0     | FUNC   | pgdg16          | pgsql_gzip_16               | 使用SQL执行Gzip压缩与解压缩                         | new in pgdg         |
| http                         | 1.6     | FUNC   | pgdg16          | pgsql_http_16               | HTTP客户端，允许在数据库内收发HTTP请求 (supabase)        | new in pgdg         |
| pg_background                | 1.0     | FUNC   | pgdg16          | pg_background_16            | 在后台运行 SQL 查询                              |                     |
| pg_idkit                     | 0.2.3   | FUNC   | pigsty-pgsql    | pg_idkit_16                 | 生成各式各样的唯一标识符：UUIDv6, ULID, KSUID          |                     |
| pg_later                     | 0.1.0   | FUNC   | pigsty-pgsql    | pg_later_16                 | 执行查询，并在稍后异步获取查询结果                         | dep: pgmq           |
| **pg_net**                   | 0.9.1   | FUNC   | pgdg16          | pg_net_16                   | 用 SQL 进行异步非阻塞HTTP/HTTPS 请求的扩展 (supabase)  |                     |
| pgjwt                        | 0.2.0   | FUNC   | pigsty-pgsql    | pgjwt_16                    | JSON Web Token API 的PG实现 (supabase)       |                     |
| pgsql_tweaks                 | 0.10.2  | FUNC   | pgdg16          | pgsql_tweaks_16             | 一些便利函数与视图                                 |                     |
| tdigest                      | 1.4.1   | FUNC   | pgdg16          | tdigest_16                  | tdigest 聚合函数                              |                     |
| topn                         | 2.6.0   | FUNC   | pgdg16          | topn_16                     | top-n JSONB 的类型                           |                     |
| address_standardizer         | 3.4.2   | GIS    | pgdg16          | postgis34_16                | 地址标准化函数。                                  |                     |
| address_standardizer_data_us | 3.4.2   | GIS    | pgdg16          | postgis34_16                | 地址标准化函数：美国数据集示例                           |                     |
| h3                           | 4.1.3   | GIS    | pgdg16          | h3-pg_16                    | H3六边形层级索引支持                               |                     |
| h3_postgis                   | 4.1.3   | GIS    | pgdg16          | h3-pg_16                    | 将 H3 与 PostGIS相集成                         |                     |
| pgrouting                    | 3.6.0   | GIS    | pgdg16          | pgrouting_16                | 提供寻路能力                                    |                     |
| pointcloud                   | 1.2.5   | GIS    | pigsty-pgsql    | pointcloud_16               | 提供激光雷达点云数据类型支持                            |                     |
| pointcloud_postgis           | 1.2.5   | GIS    | pgdg16          | pointcloud_16               | 将激光雷达点云与PostGIS几何类型相集成                    |                     |
| **postgis**                  | 3.4.2   | GIS    | pgdg16          | postgis34_16                | PostGIS 几何和地理空间扩展                         |                     |
| postgis_raster               | 3.4.2   | GIS    | pgdg16          | postgis34_16                | PostGIS 光栅类型和函数                           |                     |
| postgis_sfcgal               | 3.4.2   | GIS    | pgdg16          | postgis34_16                | PostGIS SFCGAL 函数                         |                     |
| postgis_tiger_geocoder       | 3.4.2   | GIS    | pgdg16          | postgis34_16                | PostGIS tiger 地理编码器和反向地理编码器               |                     |
| postgis_topology             | 3.4.2   | GIS    | pgdg16          | postgis34_16                | PostGIS 拓扑空间类型和函数                         |                     |
| pg_tle                       | 1.4.0   | LANG   | pigsty-pgsql    | pg_tle_16                   | AWS 可信语言扩展                                |                     |
| pldbgapi                     | 1.1     | LANG   | pgdg16          | pldebugger_16               | 用于调试 PL/pgSQL 函数的服务器端支持                   |                     |
| pllua                        | 2.0     | LANG   | pgdg16          | pllua_16                    | Lua 程序语言                                  |                     |
| plluau                       | 2.0     | LANG   | pgdg16          | pllua_16                    | Lua 程序语言（不受信任的）                           |                     |
| plpgsql_check                | 2.7     | LANG   | pgdg16          | plpgsql_check_16            | 对 plpgsql 函数进行扩展检查                        |                     |
| plprql                       | 0.1.0   | LANG   | pigsty-pgsql    | plprql_16                   | 在PostgreSQL使用PRQL——管线式关系查询语言              |                     |
| plr                          | 8.4.6   | LANG   | pgdg16          | plr_16                      | 从数据库中加载R语言解释器并执行R脚本                       |                     |
| plsh                         | 2       | LANG   | pgdg16          | plsh_16                     | PL/sh 程序语言                                |                     |
| **plv8**                     | 3.2.2   | LANG   | pigsty-pgsql    | plv8_16                     | PL/JavaScript (v8) 可信过程程序语言               |                     |
| citus_columnar               | 11.3-1  | OLAP   | pgdg16          | citus_16                    | Citus 列式存储                                | citus               |
| **columnar**                 | 11.1-11 | OLAP   | pigsty-pgsql    | hydra_16                    | 开源列式存储扩展                                  | hydra 1.1.2         |
| **duckdb_fdw**               | 1.1     | OLAP   | pigsty-pgsql    | duckdb_fdw_16               | DuckDB 外部数据源包装器 (libduck 0.10.2)          | libduckdb 0.10.2    |
| **parquet_s3_fdw**           | 0.3     | OLAP   | pigsty-pgsql    | parquet_s3_fdw_16           | 针对S3/MinIO上的Parquet文件的外部数据源包装器            | deps: libarrow-s3   |
| **pg_analytics**             | 0.6.1   | OLAP   | pigsty-pgsql    | pg_analytics_16             | ParadeDB 列存x向量执行分析加速插件                    |                     |
| **pg_lakehouse**             | 0.7.0   | OLAP   | pigsty-pgsql    | pg_lakehouse_16             | ParadeDB 湖仓分析引擎                           | rust                |
| pg_tier                      | 0.0.3   | OLAP   | pigsty-pgsql    | pg_tier_16                  | 将冷数据分级存储至S3                               | 依赖parquet_s3_fdw    |
| **timescaledb**              | 2.15.0  | OLAP   | timescaledb     | timescaledb-2-postgresql-16 | 时序数据库扩展插件                                 |                     |
| **pglogical**                | 2.4.4   | REPL   | pgdg16          | pglogical_16                | 第三方逻辑复制支持                                 |                     |
| pglogical_origin             | 1.0.0   | REPL   | pgdg16          | pglogical_16                | 用于从 Postgres 9.4 升级时的兼容性虚拟扩展              |                     |
| repmgr                       | 5.4     | REPL   | pgdg16          | repmgr_16                   | PostgreSQL复制管理组件                          |                     |
| pg_bigm                      | 1.2     | SEARCH | pgdg16          | pg_bigm_16                  | 基于二字组的多语言全文检索扩展                           |                     |
| **pg_search**                | 0.7.0   | SEARCH | pigsty-pgsql    | pg_search_16                | ParadeDB BM25算法全文检索插件，ES全文检索              | old name: pg_bm25   |
| **zhparser**                 | 2.2     | SEARCH | pigsty-pgsql    | zhparser_16                 | 中文分词，全文搜索解析器                              | deps: scws          |
| anon                         | 1.3.2   | SEC    | pgdg16          | postgresql_anonymizer_16    | 数据匿名化处理工具                                 |                     |
| credcheck                    | 2.7.0   | SEC    | pgdg16          | credcheck_16                | 明文凭证检查器                                   |                     |
| logerrors                    | 2.1     | SEC    | pgdg16          | logerrors_16                | 用于收集日志文件中消息统计信息的函数                        |                     |
| login_hook                   | 1.5     | SEC    | pgdg16          | login_hook_16               | 在用户登陆时执行login_hook.login()函数              |                     |
| passwordcracklib             | 3.0.0   | SEC    | pgdg16          | passwordcracklib_16         | 使用cracklib加固PG用户密码                        |                     |
| pg_auth_mon                  | 1.1     | SEC    | pgdg16          | pg_auth_mon_16              | 监控每个用户的连接尝试                               |                     |
| pg_jobmon                    | 1.4.1   | SEC    | pgdg16          | pg_jobmon_16                | 记录和监控函数                                   |                     |
| **pg_tde**                   | 1.0     | SEC    | pigsty-pgsql    | pg_tde_16                   | 试点性质的加密存储引擎                               | alpha               |
| pgaudit                      | 16.0    | SEC    | pgdg16          | pgaudit_16                  | 提供审计功能                                    |                     |
| pgauditlogtofile             | 1.5     | SEC    | pgdg16          | pgauditlogtofile_16         | pgAudit 子扩展，将审计日志写入单独的文件中                 |                     |
| pgcryptokey                  | 1.0     | SEC    | pgdg16          | pgcryptokey_16              | PG密钥管理                                    |                     |
| **pgsmcrypto**               | 0.1.0   | SEC    | pigsty-pgsql    | pgsmcrypto_16               | 为PostgreSQL提供商密算法支持：SM2,SM3,SM4           |                     |
| pgsodium                     | 3.1.9   | SEC    | pgdg16          | pgsodium_16                 | 表数据加密存储 TDE                               |                     |
| set_user                     | 4.0.1   | SEC    | pgdg16          | set_user_16                 | 增加了日志记录的 SET ROLE                         |                     |
| supabase_vault               | 0.2.8   | SEC    | pigsty-pgsql    | vault_16                    | 在 Vault 中存储加密凭证的扩展 (supabase)             |                     |
| **citus**                    | 12.1-1  | SHARD  | pgdg16          | citus_16                    | Citus 分布式数据库                              |                     |
| pg_fkpart                    | 1.7     | SHARD  | pgdg16          | pg_fkpart_16                | 按外键实用程序进行表分区的扩展                           |                     |
| pg_partman                   | 5.1.0   | SHARD  | pgdg16          | pg_partman_16               | 用于按时间或 ID 管理分区表的扩展                        |                     |
| orafce                       | 4.10    | SIM    | pgdg16          | orafce_16                   | 模拟 Oracle RDBMS 的一部分函数和包的函数和运算符           |                     |
| pg_dbms_job                  | 1.5.0   | SIM    | pgdg16          | pg_dbms_job_16              | 添加 Oracle DBMS_JOB 兼容性支持的扩展               |                     |
| pg_dbms_lock                 | 1.0.0   | SIM    | pgdg16          | pg_dbms_lock_16             | 为PG添加对 Oracle DBMS_LOCK 的完整兼容性支持          |                     |
| pg_dbms_metadata             | 1.0.0   | SIM    | pgdg16          | pg_dbms_metadata_16         | 添加 Oracle DBMS_METADATA 兼容性支持的扩展          |                     |
| pg_extra_time                | 1.1.2   | SIM    | pgdg16          | pg_extra_time_16            | 一些关于日期与时间的扩展函数                            |                     |
| pgmemcache                   | 2.3.0   | SIM    | pgdg16          | pgmemcache_16               | 为 PG 提供 memcached 借口                      |                     |
| pg_permissions               | 1.1     | STAT   | pgdg16          | pg_permissions_16           | 查看对象权限并将其与期望状态进行比较                        |                     |
| pg_profile                   | 4.6     | STAT   | pgdg16          | pg_profile_16               | PostgreSQL 数据库负载记录与AWR报表工具                |                     |
| pg_qualstats                 | 2.1.0   | STAT   | pgdg16          | pg_qualstats_16             | 收集有关 quals 的统计信息的扩展                       |                     |
| pg_show_plans                | 2.1     | STAT   | pgdg16          | pg_show_plans_16            | 打印所有当前正在运行查询的执行计划                         |                     |
| pg_stat_kcache               | 2.2.3   | STAT   | pgdg16          | pg_stat_kcache_16           | 内核统计信息收集                                  |                     |
| pg_stat_monitor              | 2.0     | STAT   | pgdg16          | pg_stat_monitor_16          | 提供查询聚合统计、客户端信息、执行计划详细信息和直方图               |                     |
| pg_statviz                   | 0.6     | STAT   | pgdg16          | pg_statviz_extension_16     | 可视化统计指标并分析时间序列                            |                     |
| pg_store_plans               | 1.8     | STAT   | pgdg16          | pg_store_plans_16           | 跟踪所有执行的 SQL 语句的计划统计信息                     |                     |
| pg_track_settings            | 2.1.2   | STAT   | pgdg16          | pg_track_settings_16        | 跟踪设置更改                                    |                     |
| pg_wait_sampling             | 1.1     | STAT   | pgdg16          | pg_wait_sampling_16         | 基于采样的等待事件统计                               |                     |
| pgexporter_ext               | 0.2.3   | STAT   | pgdg16          | pgexporter_ext_16           | PGExporter的额外指标支持                         |                     |
| pgmeminfo                    | 1.0     | STAT   | pgdg16          | pgmeminfo_16                | 显示内存使用情况                                  |                     |
| plprofiler                   | 4.2     | STAT   | pgdg16          | plprofiler_16               | 剖析 PL/pgSQL 函数                            |                     |
| powa                         | 4.2.2   | STAT   | pgdg16          | powa_16                     | PostgreSQL 工作负载分析器-核心                     |                     |
| system_stats                 | 2.0     | STAT   | pgdg16          | system_stats_16             | PostgreSQL 的系统统计函数                        |                     |
| dbt2                         | 0.45.0  | TEST   | pgdg16          | dbt2-pg16-extensions        | OSDL-DBT-2 测试组件                           |                     |
| faker                        | 0.5.3   | TEST   | pgdg16          | postgresql_faker_16         | 插入生成的测试伪造数据，Python库的包装                    | postgresql_faker    |
| pgtap                        | 1.3.3   | TEST   | pgdg16          | pgtap_16                    | PostgreSQL单元测试框架                          |                     |
| ip4r                         | 2.4     | TYPE   | pgdg16          | ip4r_16                     | PostgreSQL 的 IPv4/v6 和 IPv4/v6 范围索引类型     |                     |
| md5hash                      | 1.0.1   | TYPE   | pigsty-pgsql    | md5hash_16                  | 提供128位MD5的原生数据类型                          |                     |
| pg_uuidv7                    | 1.5     | TYPE   | pgdg16          | pg_uuidv7_16                | UUIDv7 支持                                 |                     |
| pgmp                         | 1.1     | TYPE   | pgdg16          | pgmp_16                     | 多精度算术扩展                                   |                     |
| prefix                       | 1.2.0   | TYPE   | pgdg16          | prefix_16                   | 前缀树数据类型                                   |                     |
| roaringbitmap                | 0.5     | TYPE   | pigsty-pgsql    | pg_roaringbitmap_16         | 支持RoaringBitmap数据类型                       |                     |
| semver                       | 0.32.1  | TYPE   | pgdg16          | semver_16                   | 语义版本号数据类型                                 |                     |
| timestamp9                   | 1.4.0   | TYPE   | pgdg16          | timestamp9_16               | 纳秒分辨率时间戳                                  |                     |
| uint                         | 0       | TYPE   | pgdg16          | uint_16                     | 无符号整型数据类型                                 |                     |
| unit                         | 7       | TYPE   | pgdg16          | postgresql-unit_16          | SI 国标单位扩展                                 |                     |
| imgsmlr ❋                    | 1.0.0   | AI     | pigsty-pgsql    | imgsmlr_16                  | 使用Haar小波分析计算图片相似度                         |                     |
| pg_similarity ❋              | 1.0.0   | AI     | pigsty-pgsql    | pg_similarity_16            | 提供17种距离度量函数                               |                     |
| multicorn ❋                  | 2.4     | FDW    | pgdg16          | multicorn2_16               | 用Python编写自定义的外部数据源包装器                     |                     |
| geoip ❋                      | 0.2.4   | GIS    | pgdg16          | geoip_16                    | IP 地理位置扩展（围绕 MaxMind GeoLite 数据集的包装器）     |                     |
| plproxy ❋                    | 2.10.0  | SHARD  | pgdg16          | plproxy_16                  | 作为过程语言实现的数据库分区                            |                     |
| mysqlcompat ❋                | 0.0.7   | SIM    | pgdg16          | mysqlcompat_16              | 尽可能在PG中实现MySQL的提供的函数                      |                     |



-----------------

### 自带扩展

PostgreSQL 自带了 **73** 个扩展插件，在所有操作系统发行版上均可用。

| 扩展                  | 版本   | 类目     | 说明                              |
|:--------------------|:-----|:-------|:--------------------------------|
| adminpack           | 2.1  | ADMIN  | PostgreSQL 管理函数集合               |
| amcheck             | 1.3  | ADMIN  | 校验关系完整性                         |
| auth_delay          |      | SEC    | 在返回认证失败前暂停一会，避免爆破               |
| auto_explain        |      | STAT   | 提供一种自动记录执行计划的手段                 |
| autoinc             | 1.0  | FUNC   | 用于自动递增字段的函数                     |
| basebackup_to_shell |      | ADMIN  | 添加一种备份到Shell终端到基础备份方式           |
| basic_archive       |      | ADMIN  | 归档模块样例                          |
| bloom               | 1.0  | FEAT   | bloom 索引-基于指纹的索引                |
| bool_plperl         | 1.0  | LANG   | 在 bool 和 plperl 之间转换            |
| bool_plperlu        | 1.0  | LANG   | 在 bool 和 plperlu 之间转换           |
| btree_gin           | 1.3  | FUNC   | 用GIN索引常见数据类型                    |
| btree_gist          | 1.7  | FUNC   | 用GiST索引常见数据类型                   |
| citext              | 1.6  | TYPE   | 提供大小写不敏感的字符串类型                  |
| cube                | 1.5  | TYPE   | 用于存储多维立方体的数据类型                  |
| dblink              | 1.2  | FDW    | 从数据库内连接到其他 PostgreSQL 数据库       |
| dict_int            | 1.0  | FUNC   | 用于整数的文本搜索字典模板                   |
| dict_xsyn           | 1.0  | FUNC   | 用于扩展同义词处理的文本搜索字典模板              |
| earthdistance       | 1.1  | GIS    | 计算地球表面上的大圆距离                    |
| file_fdw            | 1.0  | FDW    | 访问外部文件的外部数据包装器                  |
| fuzzystrmatch       | 1.2  | SEARCH | 确定字符串之间的相似性和距离                  |
| hstore              | 1.8  | TYPE   | 用于存储（键，值）对集合的数据类型               |
| hstore_plperl       | 1.0  | LANG   | 在 hstore 和 plperl 之间转换适配类型      |
| hstore_plperlu      | 1.0  | LANG   | 在 hstore 和 plperlu 之间转换适配类型     |
| hstore_plpython     |      | LANG   | 在 hstore 和 plpython 之间转换适配类型    |
| hstore_plpython3u   | 1.0  | LANG   | 在 hstore 和 plpython3u 之间转换      |
| insert_username     | 1.0  | FUNC   | 用于跟踪谁更改了表的函数                    |
| intagg              | 1.1  | FUNC   | 整数聚合器和枚举器（过时）                   |
| intarray            | 1.5  | FUNC   | 1维整数数组的额外函数、运算符和索引支持            |
| isn                 | 1.2  | TYPE   | 用于国际产品编号标准的数据类型                 |
| jsonb_plperl        | 1.0  | LANG   | 在 jsonb 和 plperl 之间转换           |
| jsonb_plperlu       | 1.0  | LANG   | 在 jsonb 和 plperlu 之间转换          |
| jsonb_plpython      |      | LANG   | 在 jsonb 和 plpython 之间转换适配类型     |
| jsonb_plpython3u    | 1.0  | LANG   | 在 jsonb 和 plpython3u 之间转换       |
| lo                  | 1.1  | ADMIN  | 大对象维护                           |
| ltree               | 1.2  | TYPE   | 用于表示分层树状结构的数据类型                 |
| ltree_plpython      |      | LANG   | 在 ltree 和 plpython 之间转换适配类型     |
| ltree_plpython3u    | 1.0  | LANG   | 在 ltree 和 plpython3u 之间转换       |
| moddatetime         | 1.0  | FUNC   | 跟踪最后修改时间                        |
| oid2name            |      | ADMIN  | 用于检查PG文件结构的实用命令行工具              |
| old_snapshot        | 1.0  | ADMIN  | 支持 old_snapshot_threshold 的实用程序 |
| pageinspect         | 1.12 | STAT   | 检查数据库页面二进制内容                    |
| passwordcheck       |      | SEC    | 用于强制拒绝修改弱密码的扩展                  |
| pg_buffercache      | 1.4  | STAT   | 检查共享缓冲区缓存                       |
| pg_freespacemap     | 1.2  | STAT   | 检查自由空间映射的内容（FSM）                |
| pg_prewarm          | 1.2  | ADMIN  | 预热关系数据                          |
| pg_stat_statements  | 1.10 | STAT   | 跟踪所有执行的 SQL 语句的计划和执行统计信息        |
| pg_surgery          | 1.0  | ADMIN  | 对损坏的关系进行手术                      |
| pg_trgm             | 1.6  | SEARCH | 文本相似度测量函数与模糊检索                  |
| pg_visibility       | 1.2  | STAT   | 检查可见性图（VM）和页面级可见性信息             |
| pg_walinspect       | 1.1  | STAT   | 用于检查 PostgreSQL WAL 日志内容的函数     |
| pgcrypto            | 1.3  | SEC    | 实用加解密函数                         |
| pgrowlocks          | 1.2  | STAT   | 显示行级锁信息                         |
| pgstattuple         | 1.5  | STAT   | 显示元组级统计信息                       |
| plperl              | 1.0  | LANG   | PL/Perl 存储过程语言                  |
| plperlu             | 1.0  | LANG   | PL/PerlU 存储过程语言（未受信/高权限）        |
| plpgsql             | 1.0  | LANG   | PL/pgSQL 程序设计语言                 |
| plpython3u          | 1.0  | LANG   | PL/Python3 存储过程语言（未受信/高权限）      |
| pltcl               | 1.0  | LANG   | PL/TCL 存储过程语言                   |
| pltclu              | 1.0  | LANG   | PL/TCL 存储过程语言（未受信/高权限）          |
| postgres_fdw        | 1.1  | FDW    | 用于远程 PostgreSQL 服务器的外部数据包装器     |
| refint              | 1.0  | FUNC   | 实现引用完整性的函数                      |
| seg                 | 1.4  | TYPE   | 表示线段或浮点间隔的数据类型                  |
| sepgsql             |      | SEC    | 基于SELinux标签的强制访问控制              |
| sslinfo             | 1.2  | STAT   | 关于 SSL 证书的信息                    |
| tablefunc           | 1.0  | OLAP   | 交叉表函数                           |
| tcn                 | 1.0  | FUNC   | 用触发器通知变更                        |
| test_decoding       |      | REPL   | 基于SQL的WAL逻辑解码样例                 |
| tsm_system_rows     | 1.0  | FUNC   | 接受行数限制的 TABLESAMPLE 方法          |
| tsm_system_time     | 1.0  | FUNC   | 接受毫秒数限制的 TABLESAMPLE 方法         |
| unaccent            | 1.1  | FUNC   | 删除重音的文本搜索字典                     |
| uuid-ossp           | 1.1  | FUNC   | 生成通用唯一标识符（UUIDs）                |
| vacuumlo            |      | ADMIN  | 从PostgreSQL中移除孤儿数据库文件的实用命令行工具   |
| xml2                | 1.1  | TYPE   | XPath 查询和 XSLT                  |


-----------------

### Pigsty扩展

Pigsty 维护了 **34** 个 RPM 扩展插件，以及 **10** 个 DEB 扩展插件，详情参考：[Pigsty RPMs](https://github.com/Vonng/pigsty-rpm)。

| 扩展                                                                         |    版本     | 说明                                       |
|----------------------------------------------------------------------------|:---------:|------------------------------------------|
| [pgml](https://github.com/postgresml/postgresml)                           |   2.8.1   | 使用 SQL 进行机器学习训练与推理                       |
| [age](https://github.com/apache/age)                                       |   1.5.0   | Apache AGE 图数据库扩展，提供 OpenCypher 查询语言     |
| [pointcloud](https://github.com/pgpointcloud/pointcloud)                   |   1.2.5   | 用于存储（激光雷达）点云数据的扩展插件                      |
| [pg_bigm](https://github.com/pgbigm/pg_bigm)                               |   1.2.0   | 基于二字组的多语言全文检索扩展                          |
| [pg_tle](https://github.com/aws/pg_tle)                                    |   1.4.0   | AWS 可信语言扩展                               |
| [roaringbitmap](https://github.com/ChenHuajun/pg_roaringbitmap)            |    0.5    | 支持RoaringBitmap数据类型                      |
| [zhparser](https://github.com/amutu/zhparser)                              |    2.2    | 中文分词，全文搜索解析器                             |
| [pgjwt](https://github.com/michelp/pgjwt)                                  |   0.2.0   | JSON Web Token API 的PG实现 (supabase)      |
| [pg_graphql](https://github.com/supabase/pg_graphql)                       |   1.5.4   | PG内的 GraphQL 支持 (RUST, supabase)         |
| [pg_jsonschema](https://github.com/supabase/pg_jsonschema)                 |   0.3.1   | 提供JSON Schema校验能力                        |
| [vault](https://github.com/supabase/vault)                                 |   0.2.9   | 在 Vault 中存储加密凭证的扩展 (supabase)            |
| [hydra](https://github.com/hydradatabase/hydra)                            |   1.1.2   | 开源列式存储扩展                                 |
| [wrappers](https://github.com/supabase/wrappers)                           |   0.3.1   | Supabase提供的外部数据源包装器捆绑包                   |
| [duckdb_fdw](https://github.com/alitrack/duckdb_fdw)                       |    1.1    | DuckDB 外部数据源包装器 (libduck 0.10.2)         |
| [pg_search](https://github.com/paradedb/paradedb/tree/dev/pg_search)       |   0.7.0   | ParadeDB BM25算法全文检索插件，ES全文检索             |
| [pg_lakehouse](https://github.com/paradedb/paradedb/tree/dev/pg_lakehouse) |   0.7.0   | ParadeDB 湖仓分析引擎                          |
| [pg_analytics](https://github.com/paradedb/pg_analytics)                   |   0.6.1   | 加速 PostgreSQL 内部的分析查询处理                  |
| [pgmq](https://github.com/tembo-io/pgmq)                                   |   1.5.2   | 轻量级消息队列，类似于 AWS SQS 和 RSMQ.              |
| [pg_tier](https://github.com/tembo-io/pg_tier)                             |   0.0.3   | 支将将冷数据分级存储到 AWS S3                       |
| [pg_vectorize](https://github.com/tembo-io/pg_vectorize)                   |  0.15.0   | 在 PG 中实现 RAG 向量检索的封装                     |
| [pg_later](https://github.com/tembo-io/pg_later)                           |   0.1.0   | 现在执行 SQL，并在稍后获取结果                        |
| [pg_idkit](https://github.com/VADOSWARE/pg_idkit)                          |   0.2.3   | 生成各式各样的唯一标识符：UUIDv6, ULID, KSUID         |
| [plprql](https://github.com/kaspermarstal/plprql)                          |   0.1.0   | 在PostgreSQL使用PRQL——管线式关系查询语言             |
| [pgsmcrypto](https://github.com/zhuobie/pgsmcrypto)                        |   0.1.0   | 为PostgreSQL提供商密算法支持：SM2,SM3,SM4          |
| [pg_tiktoken](https://github.com/kelvich/pg_tiktoken)                      |   0.0.1   | 计算 OpenAI 使用的 Token 数量                   |
| [pgdd](https://github.com/rustprooflabs/pgdd)                              |   0.5.2   | 提供通过标准SQL查询数据库目录集簇的能力                    |
| [parquet_s3_fdw](https://github.com/pgspider/parquet_s3_fdw)               |   1.1.0   | 针对S3/MinIO上的Parquet文件的外部数据源包装器           |
| [plv8](https://github.com/plv8/plv8)                                       |   3.2.2   | PL/JavaScript (v8) 可信过程程序语言              |
| [md5hash](https://github.com/tvondra/md5hash)                              |   1.0.1   | 提供128位MD5的原生数据类型                         |
| [pg_tde](https://github.com/Percona-Lab/pg_tde)                            | 1.0-alpha | PostgreSQL 的实验性加密存储引擎。                   |
| [pg_dirtyread](https://github.com/df7cb/pg_dirtyread)                      |    2.6    | 从 PostgreSQL 表中读取未清理的死元组，用于脏读            |
| [pg_sparse](https://github.com/paradedb/paradedb/tree/v0.6.1/pg_sparse) ❋  |   0.6.1   | ParadeDB 稀疏向量数据库类型与HNSW索引                |
| [imgsmlr](https://github.com/postgrespro/imgsmlr) ❋                        |   1.0.0   | 使用Haar小波分析计算图片相似度                        |
| [pg_similarity](https://github.com/eulerto/pg_similarity) ❋                |   1.0.0   | 提供17种距离度量函数                              |
| [pg_net](https://github.com/supabase/pg_net) ※                             |   0.9.1   | 用 SQL 进行异步非阻塞HTTP/HTTPS 请求的扩展 (supabase) |
| [pgsql-http](https://github.com/pramsey/pgsql-http) ※                      |    1.6    | HTTP客户端，允许在数据库内收发HTTP请求                  |
| [pgsql-gzip](https://github.com/pramsey/pgsql-gzip) ※                      |    1.0    | 使用SQL执行Gzip压缩与解压缩                        |

> 注意：带有 ❋ 标记的扩展由于各种原因尚未适配 PostgreSQL 16
>
> 带有 ※ 标记的扩展曾经由 Pigsty 维护管理，现在已经收纳至 PGDG 官方源中