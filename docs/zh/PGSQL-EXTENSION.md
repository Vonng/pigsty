# PostgreSQL 扩展插件

扩展是 PostgreSQL 的灵魂，而 Pigsty 深度整合了 PostgreSQL 生态的核心扩展插件，为您提供开箱即用的分布式的时序地理空间图文向量数据库能力！详见[扩展列表](PGSQL-EXTENSION#扩展列表)。

Pigsty 收录了超过 **150+** PostgreSQL 扩展插件，并编译打包整合维护了许多官方 PGDG 源没有收录的扩展。并且通过充分的测试确保所有这些插件可以正常协同工作。其中还包括了一些非常强力的组件，例如：
您可以使用 [PostGIS](https://postgis.net/) 处理地理空间数据，使用 [TimescaleDB](https://www.timescale.com/) 分析时序/事件流数据，
使用 [Citus](https://www.citusdata.com/) 将单机数据库原地改造为水平扩展的分布式集群，使用 [PGVector](https://github.com/pgvector/pgvector) 存储并搜索 AI 嵌入，
使用 [Apache AGE](https://age.apache.org/) 进行图数据存储与检索实现 Neo4J 的效果，使用 [zhparser](https://github.com/amutu/zhparser) 进行中文分词实现 ElasticSearch 的效果。

绝大多数插件插件都已经收录放置在基础设施节点上的本地软件源中，可以直接通过 PGSQL [集群配置](#扩展安装) 自动启用，或使用 `yum` 命令[手工安装](#手工安装扩展)。Pigsty 还包含了完整的编译环境与基础设施，允许您方便地自行[编译加装](#扩展编译)其他未收录的扩展。

![pigsty-extension.jpg](https://repo.pigsty.cc/img/pigsty-extension.jpg)

有一些“数据库”其实并不是 PostgreSQL 扩展插件，但是基于 PostgreSQL，或与其密切相关。因此也收录在 Pigsty 中，提供原生支持：

 - [Supabase](https://github.com/Vonng/pigsty/tree/master/app/supabase): 开源 Firebase 替代 (基于PostgreSQL)
 - [FerretDB](https://github.com/Vonng/pigsty/tree/master/app/ferretdb): 开源 MongoDB 替代 (基于PostgreSQL)
 - [NocoDB](https://github.com/Vonng/pigsty/tree/master/app/nocodb): 开源 Airtable 替代 (基于PostgreSQL)
 - EdgeDB: 提供了不同于 Apache Age 的另一种图数据库实现 (基于PostgreSQL)



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

其中包括一些非常知名的扩展插件，例如 `postgis`, `timescaledb`, `citus`, `age`, `vector`，`zhparser`， `pg_repack`， `wal2json`, `passwordcracklib`，`pg_cron`，`age`，`PostgresML`，等等……

由 Pigsty 维护编译打包的 PostgreSQL 插件 （RPM）

| 名称            |  版本   |     来源     |  类型  | 说明                                |
|---------------|:-----:|:----------:|:----:|-----------------------------------|
| pgml          | 2.7.9 | **PIGSTY** | FEAT | PostgresML：用SQL运行最先进的机器学习算法和预训练模型 |
| age           | 1.4.0 | **PIGSTY** | FEAT | Apache AGE， 图数据库扩展                |
| pointcloud    | 1.2.5 | **PIGSTY** | FEAT | 提供激光雷达点云数据类型支持                    |
| http          |  1.6  | **PIGSTY** | FEAT | HTTP客户端，允许在数据库内收发HTTP请求           |
| pg_tle        | 1.2.0 | **PIGSTY** | FEAT | AWS 可信语言扩展                        |
| roaringbitmap |  0.5  | **PIGSTY** | FEAT | 支持Roaring Bitmaps                 |
| zhparse       |  2.2  | **PIGSTY** | FEAT | 中文全文搜索解析器                         |
| pg_net        | 0.7.3 | **PIGSTY** | FEAT | 用 SQL 进行异步非阻塞HTTP/HTTPS 请求的扩展     |
| vault         | 0.2.9 | **PIGSTY** | FEAT | 在 Vault 中存储加密凭证的扩展                |
| pg_graphql    | 1.4.0 | **PIGSTY** | FEAT | PG内的GraphQL支持                     |
| hydra         | 1.0.0 | **PIGSTY** | FEAT | 开源列式存储扩展                          |
| imgsmlr       | 1.0.0 | **PIGSTY** | FEAT | 使用Haar小波分析计算图片相似度                 |
| pg_similarity | 1.0.0 | **PIGSTY** | FEAT | 提供17种距离度量函数                       |
| pg_bigm       | 1.2.0 | **PIGSTY** | FEAT | 基于二字组的多语言全文检索扩展                   |



由 PostgreSQL 全球开发组，PGDG 维护，并被 Pigsty 收录的的官方插件：

| 名称                           |   版本   |     来源     |  类型   | 说明                                                |
|------------------------------|:------:|:----------:|:-----:|---------------------------------------------------|
| credcheck                    | 2.1.0  |    PGDG    | ADMIN | 明文凭证检查器                                           |
| **pg_cron**                  |  1.5   |    PGDG    | ADMIN | **定时任务调度器**                                       |
| pg_background                |  1.0   |    PGDG    | ADMIN | 在后台运行 SQL 查询                                      |
| pg_jobmon                    | 1.4.1  |    PGDG    | ADMIN | 记录和监控函数                                           |
| pg_readonly                  | 1.0.0  |    PGDG    | ADMIN | 将集群设置为只读                                          |
| **pg_repack**                | 1.4.8  |    PGDG    | ADMIN | **在线垃圾清理与表膨胀治理**                                  |
| pg_squeeze                   |  1.5   |    PGDG    | ADMIN | 从关系中删除未使用空间                                       |
| pgfincore                    |  1.2   |    PGDG    | ADMIN | 检查和管理操作系统缓冲区缓存                                    |
| **pglogical**                | 2.4.3  |    PGDG    | ADMIN | **第三方逻辑复制支持**                                     |
| pglogical_origin             | 1.0.0  |    PGDG    | ADMIN | 用于从 Postgres 9.4 升级时的兼容性虚拟扩展                      |
| prioritize                   |  1.0   |    PGDG    | ADMIN | 获取和设置 PostgreSQL 后端的优先级                           |
| set_user                     | 4.0.1  |    PGDG    | AUDIT | 增加了日志记录的 SET ROLE                                 |
| **passwordcracklib**         | 3.0.0  |    PGDG    | AUDIT | **强制密码策略**                                        |
| pgaudit                      |  1.7   |    PGDG    | AUDIT | 提供审计功能                                            |
| pgcryptokey                  |  1.0   |    PGDG    | AUDIT | 密钥管理                                              |
| hdfs_fdw                     | 2.0.5  |    PGDG    |  FDW  | hdfs 外部数据包装器                                      |
| mongo_fdw                    |  1.1   |    PGDG    |  FDW  | MongoDB 外部数据包装器                                   |
| multicorn                    |  2.4   |    PGDG    |  FDW  | 用 Python 3.6 编写字定义的外部数据源包装器                       |
| mysql_fdw                    |  1.2   |    PGDG    |  FDW  | MySQL外部数据包装器                                      |
| pgbouncer_fdw                |  0.4   |    PGDG    |  FDW  | 用 SQL 查询 pgbouncer 统计信息，执行 pgbouncer 命令。          |
| sqlite_fdw                   |  1.1   |    PGDG    |  FDW  | SQLite 外部数据包装器                                    |
| tds_fdw                      | 2.0.3  |    PGDG    |  FDW  | TDS 数据库（Sybase/SQL Server）外部数据包装器                 |
| emaj                         | 4.2.0  |    PGDG    | FEAT  | 让数据库的子集具有细粒度日志和时间旅行功能                             |
| periods                      |  1.2   |    PGDG    | FEAT  | 为 PERIODs 和 SYSTEM VERSIONING 提供标准 SQL 功能         |
| pg_ivm                       |  1.5   |    PGDG    | FEAT  | 增量维护的物化视图                                         |
| pgq                          |  3.5   |    PGDG    | FEAT  | 通用队列的PG实现                                         |
| pgsodium                     | 3.1.8  |    PGDG    | FEAT  | 表数据加密存储 TDE                                       |
| **timescaledb**              | 2.11.2 |    PGDG    | FEAT  | **时序数据库扩展插件**                                     |
| **wal2json**                 | 2.5.1  |    PGDG    | FEAT  | **用逻辑解码捕获 JSON 格式的 CDC 变更**                       |
| **vector**                   | 0.5.0  |    PGDG    | FEAT  | **向量数据类型和 ivfflat / hnsw 访问方法**                   |
| count_distinct               | 3.0.1  |    PGDG    | FUNC  | COUNT(DISTINCT ...) 聚合的替代方案，可与 HashAggregate 一起使用 |
| ddlx                         |  0.23  |    PGDG    | FUNC  | DDL 提取器                                           |
| extra_window_functions       |  1.0   |    PGDG    | FUNC  | 额外的窗口函数                                           |
| mysqlcompat                  | 0.0.7  |    PGDG    | FUNC  | MySQL 兼容性函数                                       |
| orafce                       |  4.5   |    PGDG    | FUNC  | 模拟 Oracle RDBMS 的一部分函数和包的函数和运算符                   |
| pgsql_tweaks                 | 0.10.0 |    PGDG    | FUNC  | 一些便利函数与视图                                         |
| tdigest                      | 1.4.0  |    PGDG    | FUNC  | tdigest 聚合函数                                      |
| topn                         | 2.4.0  |    PGDG    | FUNC  | top-n JSONB 的类型                                   |
| unaccent                     |  1.1   |    PGDG    | FUNC  | 删除重音的文本搜索字典                                       |
| address_standardizer         | 3.3.3  |    PGDG    |  GIS  | 地址标准化函数。                                          |
| address_standardizer_data_us | 3.3.3  |    PGDG    |  GIS  | 地址标准化函数：美国数据集示例                                   |
| **postgis**                  | 3.3.3  |    PGDG    |  GIS  | PostGIS 几何和地理空间扩展                                 |
| postgis_raster               | 3.3.3  |    PGDG    |  GIS  | PostGIS 光栅类型和函数                                   |
| postgis_sfcgal               | 3.3.3  |    PGDG    |  GIS  | PostGIS SFCGAL 函数                                 |
| postgis_tiger_geocoder       | 3.3.3  |    PGDG    |  GIS  | PostGIS tiger 地理编码器和反向地理编码器                       |
| postgis_topology             | 3.3.3  |    PGDG    |  GIS  | PostGIS 拓扑空间类型和函数                                 |
| amcheck                      |  1.3   |    PGDG    | INDEX | 校验关系完整性                                           |
| bloom                        |  1.0   |    PGDG    | INDEX | bloom 索引-基于指纹的索引                                  |
| hll                          |  2.16  |    PGDG    | INDEX | hyperloglog 数据类型                                  |
| pgtt                         | 2.10.0 |    PGDG    | INDEX | 全局临时表功能                                           |
| rum                          |  1.3   |    PGDG    | INDEX | RUM 索引访问方法                                        |
| hstore_plperl                |  1.0   |    PGDG    | LANG  | 在 hstore 和 plperl 之间转换                            |
| hstore_plperlu               |  1.0   |    PGDG    | LANG  | 在 hstore 和 plperlu 之间转换                           |
| plpgsql_check                |  2.3   |    PGDG    | LANG  | 对 plpgsql 函数进行扩展检查                                |
| plsh                         |   2    |    PGDG    | LANG  | PL/sh 程序语言                                        |
| **citus**                    | 12.0-1 |    PGDG    | SHARD | **Citus 分布式数据库**                                  |
| citus_columnar               | 11.3-1 |    PGDG    | SHARD | **Citus 列式存储**                                    |
| pg_fkpart                    |  1.7   |    PGDG    | SHARD | 按外键实用程序进行表分区的扩展                                   |
| pg_partman                   | 4.7.3  |    PGDG    | SHARD | 用于按时间或 ID 管理分区表的扩展                                |
| plproxy                      | 2.10.0 |    PGDG    | SHARD | 作为过程语言实现的数据库分区                                    |
| hypopg                       | 1.4.0  |    PGDG    | STAT  | 假设索引，用于创建一个虚拟索引检验执行计划                             |
| logerrors                    |  2.1   |    PGDG    | STAT  | 用于收集日志文件中消息统计信息的函数                                |
| pg_auth_mon                  |  1.1   |    PGDG    | STAT  | 监控每个用户的连接尝试                                       |
| pg_permissions               |  1.1   |    PGDG    | STAT  | 查看对象权限并将其与期望状态进行比较                                |
| pg_qualstats                 | 2.0.4  |    PGDG    | STAT  | 收集有关 quals 的统计信息的扩展                               |
| pg_stat_kcache               | 2.2.2  |    PGDG    | STAT  | 内核统计信息收集                                          |
| pg_stat_monitor              |  2.0   |    PGDG    | STAT  | 提供查询聚合统计、客户端信息、计划详细信息（包括计划）和直方图信息。                |
| pg_store_plans               |  1.7   |    PGDG    | STAT  | 跟踪所有执行的 SQL 语句的计划统计信息                             |
| pg_track_settings            | 2.1.2  |    PGDG    | STAT  | 跟踪设置更改                                            |
| pg_wait_sampling             |  1.1   |    PGDG    | STAT  | 基于采样的等待事件统计                                       |
| pldbgapi                     |  1.1   |    PGDG    | STAT  | 用于调试 PL/pgSQL 函数的服务器端支持                           |
| plprofiler                   |  4.2   |    PGDG    | STAT  | 剖析 PL/pgSQL 函数                                    |
| powa                         | 4.1.4  |    PGDG    | STAT  | PostgreSQL 工作负载分析器-核心                             |
| system_stats                 |  1.0   |    PGDG    | STAT  | PostgreSQL 的系统统计函数                                |
| citext                       |  1.6   |    PGDG    | TYPE  | 用于不区分大小写字符字符串的数据类型                                |
| geoip                        | 0.2.4  |    PGDG    | TYPE  | IP 地理位置扩展（围绕 MaxMind GeoLite 数据集的包装器）             |
| ip4r                         |  2.4   |    PGDG    | TYPE  | PostgreSQL 的 IPv4/v6 和 IPv4/v6 范围索引类型             |
| pg_uuidv7                    |  1.1   |    PGDG    | TYPE  | UUIDv7 支持                                         |
| pgmp                         |  1.1   |    PGDG    | TYPE  | 多精度算术扩展                                           |
| semver                       | 0.32.1 |    PGDG    | TYPE  | 语义版本号数据类型                                         |
| timestamp9                   | 1.3.0  |    PGDG    | TYPE  | 纳秒分辨率时间戳                                          |
| unit                         |   7    |    PGDG    | TYPE  | SI 国标单位扩展                                         |
| lo                           |  1.1   |  CONTRIB   | ADMIN | 大对象维护                                             |
| old_snapshot                 |  1.0   |  CONTRIB   | ADMIN | 支持 old_snapshot_threshold 的实用程序                   |
| pg_prewarm                   |  1.2   |  CONTRIB   | ADMIN | 预热关系数据                                            |
| pg_surgery                   |  1.0   |  CONTRIB   | ADMIN | 对损坏的关系进行手术                                        |
| dblink                       |  1.2   |  CONTRIB   |  FDW  | 从数据库内连接到其他 PostgreSQL 数据库                         |
| file_fdw                     |  1.0   |  CONTRIB   |  FDW  | 访问外部文件的外部数据包装器                                    |
| postgres_fdw                 |  1.1   |  CONTRIB   |  FDW  | 用于远程 PostgreSQL 服务器的外部数据包装器                       |
| autoinc                      |  1.0   |  CONTRIB   | FUNC  | 用于自动递增字段的函数                                       |
| dict_int                     |  1.0   |  CONTRIB   | FUNC  | 用于整数的文本搜索字典模板                                     |
| dict_xsyn                    |  1.0   |  CONTRIB   | FUNC  | 用于扩展同义词处理的文本搜索字典模板                                |
| earthdistance                |  1.1   |  CONTRIB   | FUNC  | 计算地球表面上的大圆距离                                      |
| fuzzystrmatch                |  1.1   |  CONTRIB   | FUNC  | 确定字符串之间的相似性和距离                                    |
| insert_username              |  1.0   |  CONTRIB   | FUNC  | 用于跟踪谁更改了表的函数                                      |
| intagg                       |  1.1   |  CONTRIB   | FUNC  | 整数聚合器和枚举器（过时）                                     |
| intarray                     |  1.5   |  CONTRIB   | FUNC  | 1维整数数组的额外函数、运算符和索引支持                              |
| moddatetime                  |  1.0   |  CONTRIB   | FUNC  | 跟踪最后修改时间                                          |
| pg_trgm                      |  1.6   |  CONTRIB   | FUNC  | 文本相似度测量函数与模糊检索                                    |
| pgcrypto                     |  1.3   |  CONTRIB   | FUNC  | 实用加解密函数                                           |
| refint                       |  1.0   |  CONTRIB   | FUNC  | 实现引用完整性的函数                                        |
| tablefunc                    |  1.0   |  CONTRIB   | FUNC  | 交叉表函数                                             |
| tcn                          |  1.0   |  CONTRIB   | FUNC  | 用触发器通知变更                                          |
| tsm_system_rows              |  1.0   |  CONTRIB   | FUNC  | 接受行数限制的 TABLESAMPLE 方法                            |
| tsm_system_time              |  1.0   |  CONTRIB   | FUNC  | 接受毫秒数限制的 TABLESAMPLE 方法                           |
| uuid-ossp                    |  1.1   |  CONTRIB   | FUNC  | 生成通用唯一标识符（UUIDs）                                  |
| btree_gin                    |  1.3   |  CONTRIB   | INDEX | 用GIN索引常见数据类型                                      |
| btree_gist                   |  1.7   |  CONTRIB   | INDEX | 用GiST索引常见数据类型                                     |
| bool_plperl                  |  1.0   |  CONTRIB   | LANG  | 在 bool 和 plperl 之间转换                              |
| bool_plperlu                 |  1.0   |  CONTRIB   | LANG  | 在 bool 和 plperlu 之间转换                             |
| hstore_plpython3u            |  1.0   |  CONTRIB   | LANG  | 在 hstore 和 plpython3u 之间转换                        |
| jsonb_plperl                 |  1.0   |  CONTRIB   | LANG  | 在 jsonb 和 plperl 之间转换                             |
| jsonb_plperlu                |  1.0   |  CONTRIB   | LANG  | 在 jsonb 和 plperlu 之间转换                            |
| jsonb_plpython3u             |  1.0   |  CONTRIB   | LANG  | 在 jsonb 和 plpython3u 之间转换                         |
| ltree_plpython3u             |  1.0   |  CONTRIB   | LANG  | 在 ltree 和 plpython3u 之间转换                         |
| plperl                       |  1.0   |  CONTRIB   | LANG  | PL/Perl 存储过程语言                                    |
| plperlu                      |  1.0   |  CONTRIB   | LANG  | PL/PerlU 存储过程语言（未受信/高权限）                          |
| plpgsql                      |  1.0   |  CONTRIB   | LANG  | PL/pgSQL 程序设计语言                                   |
| plpython3u                   |  1.0   |  CONTRIB   | LANG  | PL/Python3 存储过程语言（未受信/高权限）                        |
| pltcl                        |  1.0   |  CONTRIB   | LANG  | PL/TCL 存储过程语言                                     |
| pltclu                       |  1.0   |  CONTRIB   | LANG  | PL/TCL 存储过程语言（未受信/高权限）                            |
| pageinspect                  |  1.11  |  CONTRIB   | STAT  | 检查数据库页面二进制内容                                      |
| pg_buffercache               |  1.3   |  CONTRIB   | STAT  | 检查共享缓冲区缓存                                         |
| pg_freespacemap              |  1.2   |  CONTRIB   | STAT  | 检查自由空间映射的内容（FSM）                                  |
| **pg_stat_statements**       |  1.10  |  CONTRIB   | STAT  | 跟踪所有执行的 SQL 语句的计划和执行统计信息                          |
| pg_visibility                |  1.2   |  CONTRIB   | STAT  | 检查可见性图（VM）和页面级可见性信息                               |
| pg_walinspect                |  1.0   |  CONTRIB   | STAT  | 用于检查 PostgreSQL WAL 日志内容的函数                       |
| pgrowlocks                   |  1.2   |  CONTRIB   | STAT  | 显示行级锁信息                                           |
| pgstattuple                  |  1.5   |  CONTRIB   | STAT  | 显示元组级统计信息                                         |
| sslinfo                      |  1.2   |  CONTRIB   | STAT  | 关于 SSL 证书的信息                                      |
| cube                         |  1.5   |  CONTRIB   | TYPE  | 用于存储多维立方体的数据类型                                    |
| hstore                       |  1.8   |  CONTRIB   | TYPE  | 用于存储（键，值）对集合的数据类型                                 |
| isn                          |  1.2   |  CONTRIB   | TYPE  | 用于国际产品编号标准的数据类型                                   |
| ltree                        |  1.2   |  CONTRIB   | TYPE  | 用于表示分层树状结构的数据类型                                   |
| prefix                       | 1.2.0  |  CONTRIB   | TYPE  | 前缀树数据类型                                           |
| seg                          |  1.4   |  CONTRIB   | TYPE  | 表示线段或浮点间隔的数据类型                                    |
| xml2                         |  1.1   |  CONTRIB   | TYPE  | XPath 查询和 XSLT                                    |


----------------

## 扩展安装

当您初始化 PostgreSQL 集群时，列于 [`pg_extensions`](PARAM#pg_extension) 的扩展插件将会被安装。该参数的默认值为：

```yaml
pg_extensions:     # 待安装的 pg 扩展列表，`${pg_version}` 会被替换为真实的数据库大版本 pg_version
  - pg_repack_${pg_version}* wal2json_${pg_version}* passwordcheck_cracklib_${pg_version}*
  - postgis34_${pg_version}* timescaledb-2-postgresql-${pg_version}* pgvector_${pg_version}*
```

其中 `${pg_version}` 是一个占位符变量，将在实际安装时被替换为 PostgreSQL 数据库集群大版本号。因此，默认的配置文件会安装这些扩展：

- `postgis34`：地理空间数据库扩展
- `timescaledb`：时序流式数据库扩展
- `pgvector`：向量数据库/索引扩展
- `pg_repack`：在线处理表膨胀的扩展
- `wal2json`：通过逻辑解码抽取JSON格式的变更。
- `passwordcheck_cracklib`：强制用户密码强度/过期策略

请注意，除了 Pigsty 当前支持的主力版本外（15），并不是所有的 PostgreSQL 大版本都完整提供了以上扩展。
例如截止至 2023-10-13，PG 16 仍然缺少 `pg_repack`，与 `timescaledb` 扩展。
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
      - pg_repack_${pg_version}* wal2json_${pg_version}* passwordcheck_cracklib_${pg_version}*
      - postgis34_${pg_version}* timescaledb-2-postgresql-${pg_version}* pgvector_${pg_version}*
      - pg_cron_${pg_version}*        # <---- 新增的扩展：pg_cron
      - apache-age_${pg_version}*     # <---- 新增的扩展：apache-age
      - zhparser_${pg_version}*       # <---- 新增的扩展：zhparser
```

您也可以使用 [`pgsql.yml`](PGSQL-PLAYBOOK#pgsqlyml) 的 `pg_extension` 子任务，为已经创建好的集群添加扩展。

```bash
./pgsql.yml -l pg-v15 -t pg_extension    # 为 pg-v15 集群安装指定的扩展插件
```

如果您想一次性把所有可用的扩展都安装齐全，那么可以指定 `pg_extensions: ['*${pg_version}*']`，简单粗暴，大力出奇迹！


----------------

### 手工安装扩展

您也可以在集群创建之后，使用 Ansible 或 Shell 手工安装插件，例如，如果想在某个已经初始化好的集群上启用特定扩展：

```bash
cd ~/pigsty;               # 进入 pigsty 源码目录，为 pg-test 集群安装 age 与 zhparser 扩展
ansible pg-test -m yum -b -a 'name=apache-age_15*'     # 扩展的名称通常后缀以 `_<pgmajorversion>`
ansible pg-test -m yum -b -a 'name=zhparser_15*'       # 例如，您的数据库大版本为15，那么就应该在扩展yum包之后添加 `_15`
```

绝大多数插件插件都已经收录放置在基础设施节点上的软件源中，可以直接通过 yum/apt 命令安装。
如果没有收录，您可以考虑从 PGDG 上游源使用 `repotrack`/`apt download` 命令下载，或者选择在本地[编译](#扩展编译)好后打包成 RPM/DEB 包分发。

扩展安装完成后，您应当能在目标数据库集群的 `pg_available_extensions` 视图中看到它们，接下来在想要安装扩展的数据库中执行：

```sql
CREATE EXTENSION age;          -- 安装图数据库扩展
CREATE EXTENSION zhparser;     -- 安装中文分词全文检索扩展
```



----------------

## 扩展编译

如果您想要的扩展包不在 Pigsty 中，也不在 [PGDG](https://download.postgresql.org/pub/repos/yum/) 官方源里，那么您可以考虑编译安装，或者将编译好的扩展打包成 RPM 包分发。

想要编译扩展，您需要安装 `rpmbuild`，`gcc/clang`，以及其他相关的 `-devel` 软件包，特别是您还需要 `pgdg-srpm-macros` 来构建标准的 PGDG 式扩展 RPM。

完整安装完毕的 Pigsty 的三节点构建环境 [`build.yml`](https://github.com/Vonng/pigsty/blob/master/files/pigsty/full.yml) 可以作为编译环境的基础，您可以在此环境中安装编译所需的依赖：

```bash
make build check-repo install    # 创建一个 3 节点构建环境，拷贝离线软件包，并进行完整初始化。
bin/repo-add infra node,pgsql    # 将上游的操作系统/PostgreSQL源加入到3台INFRA节点的本地yum源中

# 您还需要将 SRPM 的仓库添加至机器的yum源中
cat > /etc/yum.repos.d/pgdg-srpm.repo <<-'EOF'
[pgdg-common-srpm]
name = PostgreSQL 15 SRPM $releasever - $basearch
baseurl=https://download.postgresql.org/pub/repos/yum/srpms/common/redhat/rhel-$releasever-x86_64/
gpgcheck = 0
enabled = 1
module_hotfixes=1
EOF

# 安装编译工具，构建依赖，以及 PostgreSQL 各大版本
yum groupinstall -y 'Development Tools'
yum install -y pgdg-srpm-macros clang ccache rpm-build rpmdevtools postgresql1*-server flex bison postgresql1*-devel readline-devel zlib-devel lz4-devel libzstd-devel openssl-devel krb5-devel libcurl-devel libxml2-devel CUnit cmake
rpmdev-setuptree  # 初始化 rpm 构建目录结构
```

下面是编译一个 PostgreSQL 扩展 `pgsql-http` 的说明：首先撰写软件包的规格说明文件，放置于： `/root/rpmbuild/SPECS/pgsql-http.spec`。

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
您可能还需要清空使用本地仓库的其他节点上的本地 Yum 缓存：`ansible all -b -a 'yum clean all'`。

这样，您就可以在其他主机上使用编译好的扩展 RPM 包了。具体细节请参考 rpm 构建资料，不再展开。
