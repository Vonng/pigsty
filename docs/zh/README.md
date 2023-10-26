# Pigsty

> "**P**ostgreSQL **I**n **G**reat **STY**le."
>
> —— **开箱即用，本地优先的 RDS PostgreSQL 开源替代**
>
> 最新版本：[v2.5.0](https://github.com/Vonng/pigsty/releases/tag/v2.5.0) | [仓库](https://github.com/Vonng/pigsty) | [演示](https://demo.pigsty.cc) | [文档](https://doc.pigsty.cc/) | [网站](https://pigsty.cc/zh/) | [博客](https://pigsty.cc/zh/blog) | [论坛](https://github.com/Vonng/pigsty/discussions) | [微信公众号](https://mp.weixin.qq.com/s/-E_-HZ7LvOze5lmzy3QbQA)  | [英文文档](/)
>
> [快速上手](INSTALL.md)：`curl -fsSL https://get.pigsty.cc/latest | bash`


----------------

## 功能特性

Pigsty 是一个更好的本地开源 RDS for PostgreSQL 替代，具有以下特点：

- 开箱即用的 [PostgreSQL](https://www.postgresql.org/) 发行版，深度整合地理、时序、分布式、图、向量、分词、AI等 150 余个[扩展插件](PGSQL-EXTENSION.md)！
- 运行于裸操作系统之上，无需容器支持，支持主流操作系统： EL7/8/9, Ubuntu 20.04/22.04 以及 Debian 11/12。
- 基于现代的 [Prometheus](https://prometheus.io/) 与 [Grafana](https://grafana.com/) 技术栈，提供令人惊艳，无可比拟的数据库观测能力：[画廊](https://github.com/Vonng/pigsty/wiki/Gallery) & [演示站点](https://demo.pigsty.cc)
- 基于 [patroni](https://patroni.readthedocs.io/en/latest/), [haproxy](http://www.haproxy.org/), 与[etcd](https://etcd.io/)，打造故障自愈的高可用架构：硬件故障自动切换，流量无缝衔接。
- 基于 [pgBackRest](https://pgbackrest.org/) 与可选的 [MinIO](https://min.io/) 集群提供开箱即用的 PITR 时间点恢复，为软件缺陷与人为删库兜底。
- 基于 [Ansible](https://www.ansible.com/) 提供声明式的 API 对复杂度进行抽象，以 **Database-as-Code** 的方式极大简化了日常运维管理操作。
- Pigsty用途广泛，可用作完整应用运行时，开发演示数据/可视化应用，大量使用 PG 的软件可用 [Docker](https://www.docker.com/) 模板一键拉起。
- 提供基于 [Vagrant](https://www.vagrantup.com/) 的本地开发测试沙箱环境，与基于 [Terraform](https://www.terraform.io/) 的云端自动部署方案，开发测试生产保持环境一致。
- 部署并监控专用的 [Redis](https://redis.io/)（主从，哨兵，集群），MinIO，Etcd，Haproxy，MongoDB([FerretDB](https://www.ferretdb.io/)) 集群

[![pigsty-distro.jpg](https://repo.pigsty.cc/img/pigsty-distro.jpg)](FEATURE.md)

- [开箱即用的RDS](FEATURE.md#开箱即用的rds)：从内核到RDS发行版，在 EL7-9 下提供 12-16 版本的生产级 PostgreSQL 数据库服务。
- [丰富的扩展插件](FEATURE.md#丰富的扩展插件)：深度整合 150+ 核心扩展，提供开箱即用的分布式的时序地理空间图文向量数据库能力。
- [灵活的模块架构](FEATURE.md#灵活的模块架构)：灵活组合，自由扩展：Redis/Etcd/MinIO/Mongo；可独立使用，监控现有RDS/主机/数据库。
- [惊艳的观测能力](FEATURE.md#惊艳的观测能力)：基于现代可观测性技术栈 Prometheus/Grafana，提供令人惊艳，无可比拟的数据库观测能力。
- [验证过的可靠性](FEATURE.md#验证过的可靠性)：故障自愈的高可用架构：硬件故障自动切换，流量无缝衔接。并提供自动配置的 PITR 兜底删库！
- [简单易用可维护](FEATURE.md#简单易用可维护)：声明式API，GitOps就位，傻瓜式操作，Database/Infra-as-Code 以及管理SOP封装管理复杂度！
- [扎实的安全实践](FEATURE.md#扎实的安全实践)：加密备份一应俱全，自带基础ACL最佳实践。只要硬件与密钥安全，您无需操心数据库的安全性！
- [广泛的应用场景](FEATURE.md#广泛的应用场景)：低代码数据应用开发，或使用预置的 Docker Compose 模板，一键拉起使用PostgreSQL的海量软件！
- [开源的自由软件](FEATURE.md#开源的自由软件)：以云数据库1/10不到的成本拥有与更好的数据库服务！帮您真正“拥有”自己的数据，实现自主可控！

[![pigsty-dashboard.jpg](https://repo.pigsty.cc/img/pigsty-dashboard.jpg)](https://demo.pigsty.cc)

<details><summary>生态组件与可用扩展列表</summary>

Pigsty 收录了超过 150 个预先编译好、开箱即用的 PostgreSQL [扩展插件](PGSQL-EXTENSION.md)。其中有一些非常强力的扩展：

- PostGIS：地理空间扩展，GIS 事实标准
- TimescaleDB：添加时序/持续聚合/分布式/列存储/自动压缩的能力
- PGVector：添加 AI 向量/嵌入数据类型支持，以及 ivfflat 与 hnsw 索引。
- Citus：将经典的主从PG集群原地改造为一个水平分片的分布式数据库集群。
- Apache AGE：图数据库扩展，为 PostgreSQL 添加 OpenCypher 查询支持，类似 Neo4J
- PG GraphQL：为 PostgreSQL 添加原生内建的 GraphQL 查询语言支持。
- zhparser： 添加中文分词支持，用于支持类似 ElasticSearch 的全文搜索功能。
- [Supabase](https://github.com/Vonng/pigsty/tree/master/app/supabase)：基于 PostgreSQL 的开源的 Firebase 替代。
- [FerretDB](https://github.com/Vonng/pigsty/tree/master/app/ferretdb)：基于 PostgreSQL 的开源 MongoDB 替代。
- [PostgresML](https://github.com/Vonng/pigsty/tree/master/app/pgml)：使用SQL完成经典机器学习算法，调用大语言模型。

[PostgreSQL](https://www.postgresql.org/) + [PostGIS](https://postgis.net/) + [TimescaleDB](https://www.timescale.com/) + [Citus](https://www.citusdata.com/) + [PGVector](https://github.com/pgvector/pgvector) + [Age](https://age.apache.org/) +[Supabase](https://github.com/Vonng/pigsty/tree/master/app/supabase) + [PostgresML](https://github.com/Vonng/pigsty/tree/master/app/pgml) + [...](PGSQL-EXTENSION.md)

[![pigsty-extension.jpg](https://repo.pigsty.cc/img/pigsty-extension.jpg)](PGSQL-EXTENSION.md)

| 名称                           |   版本   |     来源     |  类型   | 说明                                                |
|------------------------------|:------:|:----------:|:-----:|---------------------------------------------------|
| **age**                      | 1.4.0  | **PIGSTY** | FEAT  | **Apache AGE， 图数据库扩展**                            |
| **pointcloud**               | 1.2.5  | **PIGSTY** | FEAT  | **提供激光雷达点云数据类型支持**                                |
| **http**                     |  1.6   | **PIGSTY** | FEAT  | **HTTP 客户端**，允许在数据库内收发HTTP请求                      |
| pg_tle                       | 1.2.0  | **PIGSTY** | FEAT  | AWS 可信语言扩展                                        |
| roaringbitmap                |  0.5   | **PIGSTY** | FEAT  | 支持Roaring Bitmaps                                 |
| **zhparser**                 |  2.2   | **PIGSTY** | FEAT  | **中文全文搜索解析器**                                     |
| **pgml**                     | 2.7.9  | **PIGSTY** | FEAT  | **PostgresML**: 用SQL运行最先进的机器学习算法和预训练模型            |
| pg_net                       | 0.7.3  | **PIGSTY** | FEAT  | 用 SQL 进行异步非阻塞HTTP/HTTPS 请求的扩展                     |
| vault                        | 0.2.9  | **PIGSTY** | FEAT  | 在 Vault 中存储加密凭证的扩展                                |
| **pg_graphql**               | 1.4.0  | **PIGSTY** | FEAT  | **PG内的GraphQL支持**                                 |
| **hydra**                    | 1.0.0  | **PIGSTY** | FEAT  | **开源列式存储扩展**                                      |
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

</details>



----------------

## 快速上手

Pigsty可以一键安装! 详情请参阅[**快速上手**](install)。

准备一个使用 Linux x86_64 [兼容系统](#兼容性)的全新节点，使用带有免密 `sudo` 权限的用户执行：

```bash
bash -c "$(curl -fsSL https://get.pigsty.cc/latest)" && cd ~/pigsty   
./bootstrap  && ./configure && ./install.yml # 安装最新的 Pigsty 源码
```

安装完成后，您可以通过域名或`80/443`端口通过 Nginx 访问 [WEB界面](INFRA#概览)，通过 `5432` 端口[访问](PGSQL-SVC#单机用户)默认的 PostgreSQL 数据库[服务](PGSQL-SVC#服务概述)。


<details><summary>一键安装脚本</summary>

```bash
$ curl https://get.pigsty.cc/latest | bash
...
[Checking] ===========================================
[ OK ] SOURCE from CDN due to GFW
FROM CDN    : bash -c "$(curl -fsSL https://get.pigsty.cc/latest)"
FROM GITHUB : bash -c "$(curl -fsSL https://raw.githubusercontent.com/Vonng/pigsty/master/bin/latest)"
[Downloading] ===========================================
[ OK ] download pigsty source code from CDN
[ OK ] $ curl -SL https://get.pigsty.cc/v2.5.0/pigsty-v2.5.0.tgz
...
MD5: d5dc4a51efc81932a03d7c010d0d5d64  /tmp/pigsty-v2.5.0.tgz
[Extracting] ===========================================
[ OK ] extract '/tmp/pigsty-v2.5.0.tgz' to '/home/vagrant/pigsty'
[ OK ] $ tar -xf /tmp/pigsty-v2.5.0.tgz -C ~;
[Reference] ===========================================
Official Site:   https://pigsty.cc
Get Started:     https://doc.pigsty.cc/#/INSTALL
Documentation:   https://doc.pigsty.cc
Github Repo:     https://github.com/Vonng/pigsty
Public Demo:     https://demo.pigsty.cc
[Proceeding] ===========================================
cd ~/pigsty      # entering pigsty home directory before proceeding
./bootstrap      # install ansible & download the optional offline packages
./configure      # preflight-check and generate config according to your env
./install.yml    # install pigsty on this node and init it as the admin node
[ OK ] ~/pigsty is ready to go now!
```

</details>


<details><summary>Git检出安装</summary>

你也可以使用 `git` 来下载安装 Pigsty 源代码，不要忘了检出特定的版本。

```bash
git clone https://github.com/Vonng/pigsty;
cd pigsty; git checkout v2.5.0
```

</details>


<details><summary>直接下载</summary>

您还可以直接从 GitHub 发布页面下载源代码包与离线软件包：

```bash
# 执行 Github 上的下载脚本
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Vonng/pigsty/master/bin/latest)"

# 或者直接使用 curl 从 GitHub 上下载
curl -L https://github.com/Vonng/pigsty/releases/download/v2.5.0/pigsty-v2.5.0.tgz -o ~/pigsty.tgz                 # 源码包
curl -L https://github.com/Vonng/pigsty/releases/download/v2.5.0/pigsty-pkg-v2.5.0.el9.x86_64.tgz -o /tmp/pkg.tgz  # EL9 离线软件包
curl -L https://github.com/Vonng/pigsty/releases/download/v2.5.0/pigsty-pkg-v2.5.0.el8.x86_64.tgz -o /tmp/pkg.tgz  # EL8 离线软件包
curl -L https://github.com/Vonng/pigsty/releases/download/v2.5.0/pigsty-pkg-v2.5.0.el7.x86_64.tgz -o /tmp/pkg.tgz  # EL7 离线软件包

# 对于中国大陆用户来说，也可以选择从中国 CDN 下载
curl -L https://get.pigsty.cc/v2.5.0/pigsty-v2.5.0.tgz -o ~/pigsty.tgz                 # 源码包
curl -L https://get.pigsty.cc/v2.5.0/pigsty-pkg-v2.5.0.el9.x86_64.tgz -o /tmp/pkg.tgz  # EL9 离线软件包
curl -L https://get.pigsty.cc/v2.5.0/pigsty-pkg-v2.5.0.el8.x86_64.tgz -o /tmp/pkg.tgz  # EL8 离线软件包
curl -L https://get.pigsty.cc/v2.5.0/pigsty-pkg-v2.5.0.el7.x86_64.tgz -o /tmp/pkg.tgz  # EL7 离线软件包
```

</details>

[![asciicast](https://asciinema.org/a/603609.svg)](https://asciinema.org/a/603609)



----------------

## 系统架构

Pigsty 采用模块化设计，有六个主要的默认模块：[`PGSQL`](pgsql)、[`INFRA`](infra)、[`NODE`](node)、[`ETCD`](etcd)、[`REDIS`](redis) 和 [`MINIO`](minio)。

* [`PGSQL`](pgsql)：由 Patroni、Pgbouncer、HAproxy、PgBackrest 等驱动的自治高可用 Postgres 集群。
* [`INFRA`](infra)：本地软件仓库、Prometheus、Grafana、Loki、AlertManager、PushGateway、Blackbox Exporter...
* [`NODE`](node)：调整节点到所需状态、名称、时区、NTP、ssh、sudo、haproxy、docker、promtail...
* [`ETCD`](etcd)：分布式键值存储，用作高可用 Postgres 集群的 DCS：共识选主/配置管理/服务发现。
* [`REDIS`](redis)：Redis 服务器，支持独立主从、哨兵、集群模式，并带有完整的监控支持。
* [`MINIO`](minio)：与 S3 兼容的简单对象存储服务器，可作为 PG数据库备份的可选目的地。

你可以声明式地自由组合它们。如果你想要主机监控，[`INFRA`](infra) 和 [`NODE`](node) 就足够了。
额外的 [`ETCD`](etcd) 和 [`PGSQL`](pgsql) 用于 HA PG 集群，在多个节点上部署它们将自动组成一个高可用集群。
您可以重复使用 pigsty 基础架构并开发您的模块，[`REDIS`](redis) 和 [`MINIO`](minio) 可以作为一个样例。
后续还会有更多的模块加入，例如对 Mongo, MySQL 的支持已经初步提上了日程。

[`install.yml`](https://github.com/Vonng/pigsty/blob/master/install.yml) 剧本将在**当前**节点上安装 [`INFRA`](infra)、[`ETCD`](etcd)、[`PGSQL`](pgsql) 和可选的 [`MINIO`](minio) 模块，
这将为你提供一个功能完备的可观测性技术栈全家桶 (Prometheus、Grafana、Loki、AlertManager、PushGateway、BlackboxExporter 等) ，以及一个内置的 PostgreSQL 单机实例作为 CMDB，也可以开箱即用。 (集群名 `pg-meta`，库名为 `meta`)。
这个节点现在会有完整的自我监控系统、可视化工具集，以及一个自动配置有 PITR 的 Postgres 数据库（单机安装时HA不可用，因为你只有一个节点）。你可以使用此节点作为开发箱、测试、运行演示以及进行数据可视化和分析。或者，还可以把这个节点当作管理节点，部署纳管更多的节点！

[![pigsty-arch.jpg](https://repo.pigsty.cc/img/pigsty-arch.jpg)](ARCH.md)




----------------

## 更多集群

要部署一个使用流复制组建的三节点高可用 PostgreSQL 集群，首先要在配置文件 [`pigsty.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml) 的 `all.children.pg-test` 中进行[定义](https://github.com/Vonng/pigsty/blob/master/pigsty.yml#L54)

```yaml 
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
    10.10.10.13: { pg_seq: 3, pg_role: offline }
  vars:  { pg_cluster: pg-test }
```

定义完后，可以使用[剧本](playbook)将其创建：

```bash
bin/pgsql-add pg-test   # 初始化 pg-test 集群 
```

[![pgsql-ha.jpg](https://repo.pigsty.cc/img/pgsql-ha.jpg)](PGSQL-ARCH.md)

你可以使用不同的的实例角色，例如 [主库](PGSQL-CONF#读写主库)（primary），[从库](PGSQL-CONF#只读从库)（replica），[离线从库](PGSQL-CONF#读写主库)（offline），[延迟从库](PGSQL-CONF#延迟集群)（delayed），[同步备库](PGSQL-CONF#同步备库)（sync standby）；
以及不同的集群：例如[备份集群](PGSQL-CONF#备份集群)（Standby Cluster），[Citus集群](PGSQL-CONF#citus集群)，甚至是 [Redis](REDIS) / [MinIO](MINIO) / [Etcd](ETCD) 集群，如下所示：


<details><summary>示例：复杂的 PostgreSQL 集群定制</summary>

```yaml
pg-meta:
  hosts: { 10.10.10.10: { pg_seq: 1, pg_role: primary , pg_offline_query: true } }
  vars:
    pg_cluster: pg-meta
    pg_databases:                       # define business databases on this cluster, array of database definition
      - name: meta                      # REQUIRED, `name` is the only mandatory field of a database definition
        baseline: cmdb.sql              # optional, database sql baseline path, (relative path among ansible search path, e.g files/)
        pgbouncer: true                 # optional, add this database to pgbouncer database list? true by default
        schemas: [pigsty]               # optional, additional schemas to be created, array of schema names
        extensions:                     # optional, additional extensions to be installed: array of `{name[,schema]}`
          - { name: postgis , schema: public }
          - { name: timescaledb }
        comment: pigsty meta database   # optional, comment string for this database
        owner: postgres                # optional, database owner, postgres by default
        template: template1            # optional, which template to use, template1 by default
        encoding: UTF8                 # optional, database encoding, UTF8 by default. (MUST same as template database)
        locale: C                      # optional, database locale, C by default.  (MUST same as template database)
        lc_collate: C                  # optional, database collate, C by default. (MUST same as template database)
        lc_ctype: C                    # optional, database ctype, C by default.   (MUST same as template database)
        tablespace: pg_default         # optional, default tablespace, 'pg_default' by default.
        allowconn: true                # optional, allow connection, true by default. false will disable connect at all
        revokeconn: false              # optional, revoke public connection privilege. false by default. (leave connect with grant option to owner)
        register_datasource: true      # optional, register this database to grafana datasources? true by default
        connlimit: -1                  # optional, database connection limit, default -1 disable limit
        pool_auth_user: dbuser_meta    # optional, all connection to this pgbouncer database will be authenticated by this user
        pool_mode: transaction         # optional, pgbouncer pool mode at database level, default transaction
        pool_size: 64                  # optional, pgbouncer pool size at database level, default 64
        pool_size_reserve: 32          # optional, pgbouncer pool size reserve at database level, default 32
        pool_size_min: 0               # optional, pgbouncer pool size min at database level, default 0
        pool_max_db_conn: 100          # optional, max database connections at database level, default 100
      - { name: grafana  ,owner: dbuser_grafana  ,revokeconn: true ,comment: grafana primary database }
      - { name: bytebase ,owner: dbuser_bytebase ,revokeconn: true ,comment: bytebase primary database }
      - { name: kong     ,owner: dbuser_kong     ,revokeconn: true ,comment: kong the api gateway database }
      - { name: gitea    ,owner: dbuser_gitea    ,revokeconn: true ,comment: gitea meta database }
      - { name: wiki     ,owner: dbuser_wiki     ,revokeconn: true ,comment: wiki meta database }
    pg_users:                           # define business users/roles on this cluster, array of user definition
      - name: dbuser_meta               # REQUIRED, `name` is the only mandatory field of a user definition
        password: DBUser.Meta           # optional, password, can be a scram-sha-256 hash string or plain text
        login: true                     # optional, can log in, true by default  (new biz ROLE should be false)
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
        parameters: {}                  # optional, role level parameters with `ALTER ROLE SET`
        pool_mode: transaction          # optional, pgbouncer pool mode at user level, transaction by default
        pool_connlimit: -1              # optional, max database connections at user level, default -1 disable limit
      - {name: dbuser_view     ,password: DBUser.Viewer   ,pgbouncer: true ,roles: [dbrole_readonly], comment: read-only viewer for meta database}
      - {name: dbuser_grafana  ,password: DBUser.Grafana  ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for grafana database   }
      - {name: dbuser_bytebase ,password: DBUser.Bytebase ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for bytebase database  }
      - {name: dbuser_kong     ,password: DBUser.Kong     ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for kong api gateway   }
      - {name: dbuser_gitea    ,password: DBUser.Gitea    ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for gitea service      }
      - {name: dbuser_wiki     ,password: DBUser.Wiki     ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for wiki.js service    }
    pg_services:                        # extra services in addition to pg_default_services, array of service definition
      # standby service will route {ip|name}:5435 to sync replica's pgbouncer (5435->6432 standby)
      - name: standby                   # required, service name, the actual svc name will be prefixed with `pg_cluster`, e.g: pg-meta-standby
        port: 5435                      # required, service exposed port (work as kubernetes service node port mode)
        ip: "*"                         # optional, service bind ip address, `*` for all ip by default
        selector: "[]"                  # required, service member selector, use JMESPath to filter inventory
        dest: default                   # optional, destination port, default|postgres|pgbouncer|<port_number>, 'default' by default
        check: /sync                    # optional, health check url path, / by default
        backup: "[? pg_role == `primary`]"  # backup server selector
        maxconn: 3000                   # optional, max allowed front-end connection
        balance: roundrobin             # optional, haproxy load balance algorithm (roundrobin by default, other: leastconn)
        options: 'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'
    pg_hba_rules:
      - {user: dbuser_view , db: all ,addr: infra ,auth: pwd ,title: 'allow grafana dashboard access cmdb from infra nodes'}
    pg_vip_enabled: true
    pg_vip_address: 10.10.10.2/24
    pg_vip_interface: eth1
    node_crontab:  # make a full backup 1 am everyday
      - '00 01 * * * postgres /pg/bin/pg-backup full'

```

</details>

<details><summary>示例：带有延迟从库的安全加固PG集群</summary>

```yaml
pg-meta:      # 3 instance postgres cluster `pg-meta`
  hosts:
    10.10.10.10: { pg_seq: 1, pg_role: primary }
    10.10.10.11: { pg_seq: 2, pg_role: replica }
    10.10.10.12: { pg_seq: 3, pg_role: replica , pg_offline_query: true }
  vars:
    pg_cluster: pg-meta
    pg_conf: crit.yml
    pg_users:
      - { name: dbuser_meta , password: DBUser.Meta   , pgbouncer: true , roles: [ dbrole_admin ] , comment: pigsty admin user }
      - { name: dbuser_view , password: DBUser.Viewer , pgbouncer: true , roles: [ dbrole_readonly ] , comment: read-only viewer for meta database }
    pg_databases:
      - {name: meta ,baseline: cmdb.sql ,comment: pigsty meta database ,schemas: [pigsty] ,extensions: [{name: postgis, schema: public}, {name: timescaledb}]}
    pg_default_service_dest: postgres
    pg_services:
      - { name: standby ,src_ip: "*" ,port: 5435 , dest: default ,selector: "[]" , backup: "[? pg_role == `primary`]" }
    pg_vip_enabled: true
    pg_vip_address: 10.10.10.2/24
    pg_vip_interface: eth1
    pg_listen: '${ip},${vip},${lo}'
    patroni_ssl_enabled: true
    pgbouncer_sslmode: require
    pgbackrest_method: minio
    pg_libs: 'timescaledb, $libdir/passwordcheck, pg_stat_statements, auto_explain' # add passwordcheck extension to enforce strong password
    pg_default_roles:                 # default roles and users in postgres cluster
      - { name: dbrole_readonly  ,login: false ,comment: role for global read-only access     }
      - { name: dbrole_offline   ,login: false ,comment: role for restricted read-only access }
      - { name: dbrole_readwrite ,login: false ,roles: [dbrole_readonly]               ,comment: role for global read-write access }
      - { name: dbrole_admin     ,login: false ,roles: [pg_monitor, dbrole_readwrite]  ,comment: role for object creation }
      - { name: postgres     ,superuser: true  ,expire_in: 7300                        ,comment: system superuser }
      - { name: replicator ,replication: true  ,expire_in: 7300 ,roles: [pg_monitor, dbrole_readonly]   ,comment: system replicator }
      - { name: dbuser_dba   ,superuser: true  ,expire_in: 7300 ,roles: [dbrole_admin]  ,pgbouncer: true ,pool_mode: session, pool_connlimit: 16 , comment: pgsql admin user }
      - { name: dbuser_monitor ,roles: [pg_monitor] ,expire_in: 7300 ,pgbouncer: true ,parameters: {log_min_duration_statement: 1000 } ,pool_mode: session ,pool_connlimit: 8 ,comment: pgsql monitor user }
    pg_default_hba_rules:             # postgres host-based auth rules by default
      - {user: '${dbsu}'    ,db: all         ,addr: local     ,auth: ident ,title: 'dbsu access via local os user ident'  }
      - {user: '${dbsu}'    ,db: replication ,addr: local     ,auth: ident ,title: 'dbsu replication from local os ident' }
      - {user: '${repl}'    ,db: replication ,addr: localhost ,auth: ssl   ,title: 'replicator replication from localhost'}
      - {user: '${repl}'    ,db: replication ,addr: intra     ,auth: ssl   ,title: 'replicator replication from intranet' }
      - {user: '${repl}'    ,db: postgres    ,addr: intra     ,auth: ssl   ,title: 'replicator postgres db from intranet' }
      - {user: '${monitor}' ,db: all         ,addr: localhost ,auth: pwd   ,title: 'monitor from localhost with password' }
      - {user: '${monitor}' ,db: all         ,addr: infra     ,auth: ssl   ,title: 'monitor from infra host with password'}
      - {user: '${admin}'   ,db: all         ,addr: infra     ,auth: ssl   ,title: 'admin @ infra nodes with pwd & ssl'   }
      - {user: '${admin}'   ,db: all         ,addr: world     ,auth: cert  ,title: 'admin @ everywhere with ssl & cert'   }
      - {user: '+dbrole_readonly',db: all    ,addr: localhost ,auth: ssl   ,title: 'pgbouncer read/write via local socket'}
      - {user: '+dbrole_readonly',db: all    ,addr: intra     ,auth: ssl   ,title: 'read/write biz user via password'     }
      - {user: '+dbrole_offline' ,db: all    ,addr: intra     ,auth: ssl   ,title: 'allow etl offline tasks from intranet'}
    pgb_default_hba_rules:            # pgbouncer host-based authentication rules
      - {user: '${dbsu}'    ,db: pgbouncer   ,addr: local     ,auth: peer  ,title: 'dbsu local admin access with os ident'}
      - {user: 'all'        ,db: all         ,addr: localhost ,auth: pwd   ,title: 'allow all user local access with pwd' }
      - {user: '${monitor}' ,db: pgbouncer   ,addr: intra     ,auth: ssl   ,title: 'monitor access via intranet with pwd' }
      - {user: '${monitor}' ,db: all         ,addr: world     ,auth: deny  ,title: 'reject all other monitor access addr' }
      - {user: '${admin}'   ,db: all         ,addr: intra     ,auth: ssl   ,title: 'admin access via intranet with pwd'   }
      - {user: '${admin}'   ,db: all         ,addr: world     ,auth: deny  ,title: 'reject all other admin access addr'   }
      - {user: 'all'        ,db: all         ,addr: intra     ,auth: ssl   ,title: 'allow all user intra access with pwd' }

# OPTIONAL delayed cluster for pg-meta
pg-meta-delay:                    # delayed instance for pg-meta (1 hour ago)
  hosts: { 10.10.10.13: { pg_seq: 1, pg_role: primary, pg_upstream: 10.10.10.10, pg_delay: 1h } }
  vars: { pg_cluster: pg-meta-delay }
```

</details>

<details><summary>示例：Citus 5节点分布式集群</summary>

```yaml
all:
  children:
    pg-citus0: # citus coordinator, pg_group = 0
      hosts: { 10.10.10.10: { pg_seq: 1, pg_role: primary } }
      vars: { pg_cluster: pg-citus0 , pg_group: 0 }
    pg-citus1: # citus data node 1
      hosts: { 10.10.10.11: { pg_seq: 1, pg_role: primary } }
      vars: { pg_cluster: pg-citus1 , pg_group: 1 }
    pg-citus2: # citus data node 2
      hosts: { 10.10.10.12: { pg_seq: 1, pg_role: primary } }
      vars: { pg_cluster: pg-citus2 , pg_group: 2 }
    pg-citus3: # citus data node 3, with an extra replica
      hosts:
        10.10.10.13: { pg_seq: 1, pg_role: primary }
        10.10.10.14: { pg_seq: 2, pg_role: replica }
      vars: { pg_cluster: pg-citus3 , pg_group: 3 }
  vars:                               # global parameters for all citus clusters
    pg_mode: citus                    # pgsql cluster mode: citus
    pg_shard: pg-citus                # citus shard name: pg-citus
    patroni_citus_db: meta            # citus distributed database name
    pg_dbsu_password: DBUser.Postgres # all dbsu password access for citus cluster
    pg_users: [ { name: dbuser_meta ,password: DBUser.Meta ,pgbouncer: true ,roles: [ dbrole_admin ] } ]
    pg_databases: [ { name: meta ,extensions: [ { name: citus }, { name: postgis }, { name: timescaledb } ] } ]
    pg_hba_rules:
      - { user: 'all' ,db: all  ,addr: 127.0.0.1/32 ,auth: ssl ,title: 'all user ssl access from localhost' }
      - { user: 'all' ,db: all  ,addr: intra        ,auth: ssl ,title: 'all user ssl access from intranet'  }
```


</details>

<details><summary>示例：Redis 集群/哨兵/主从</summary>

```yaml
redis-ms: # redis classic primary & replica
  hosts: { 10.10.10.10: { redis_node: 1 , redis_instances: { 6379: { }, 6380: { replica_of: '10.10.10.10 6379' } } } }
  vars: { redis_cluster: redis-ms ,redis_password: 'redis.ms' ,redis_max_memory: 64MB }

redis-meta: # redis sentinel x 3
  hosts: { 10.10.10.11: { redis_node: 1 , redis_instances: { 26379: { } ,26380: { } ,26381: { } } } }
  vars:
    redis_cluster: redis-meta
    redis_password: 'redis.meta'
    redis_mode: sentinel
    redis_max_memory: 16MB
    redis_sentinel_monitor: # primary list for redis sentinel, use cls as name, primary ip:port
      - { name: redis-ms, host: 10.10.10.10, port: 6379 ,password: redis.ms, quorum: 2 }

redis-test: # redis native cluster: 3m x 3s
  hosts:
    10.10.10.12: { redis_node: 1 ,redis_instances: { 6379: { } ,6380: { } ,6381: { } } }
    10.10.10.13: { redis_node: 2 ,redis_instances: { 6379: { } ,6380: { } ,6381: { } } }
  vars: { redis_cluster: redis-test ,redis_password: 'redis.test' ,redis_mode: cluster, redis_max_memory: 32MB }
```

</details>

<details><summary>示例：3节点ETCD集群</summary>

```yaml
etcd: # dcs service for postgres/patroni ha consensus
  hosts:  # 1 node for testing, 3 or 5 for production
    10.10.10.10: { etcd_seq: 1 }  # etcd_seq required
    10.10.10.11: { etcd_seq: 2 }  # assign from 1 ~ n
    10.10.10.12: { etcd_seq: 3 }  # odd number please
  vars: # cluster level parameter override roles/etcd
    etcd_cluster: etcd  # mark etcd cluster name etcd
    etcd_safeguard: false # safeguard against purging
    etcd_clean: true # purge etcd during init process
```

</details>

<details><summary>示例：3节点MinIO部署</summary>

```yaml
minio:
  hosts:
    10.10.10.10: { minio_seq: 1 }
    10.10.10.11: { minio_seq: 2 }
    10.10.10.12: { minio_seq: 3 }
  vars:
    minio_cluster: minio
    minio_data: '/data{1...2}'          # 每个节点使用两块磁盘
    minio_node: '${minio_cluster}-${minio_seq}.pigsty' # 节点名称的模式
    haproxy_services:
      - name: minio                     # [必选] 服务名称，需要唯一
        port: 9002                      # [必选] 服务端口，需要唯一
        options:
          - option httpchk
          - option http-keep-alive
          - http-check send meth OPTIONS uri /minio/health/live
          - http-check expect status 200
        servers:
          - { name: minio-1 ,ip: 10.10.10.10 , port: 9000 , options: 'check-ssl ca-file /etc/pki/ca.crt check port 9000' }
          - { name: minio-2 ,ip: 10.10.10.11 , port: 9000 , options: 'check-ssl ca-file /etc/pki/ca.crt check port 9000' }
          - { name: minio-3 ,ip: 10.10.10.12 , port: 9000 , options: 'check-ssl ca-file /etc/pki/ca.crt check port 9000' }
```

</details>

<details><summary>示例：安装Pigsty四节点沙箱</summary>

[![asciicast](https://asciinema.org/a/566220.svg)](https://asciinema.org/a/566220)

</details><br>

详情请参考 [**Pigsty配置**](config) 与 [**PGSQL配置**](pgsql-conf)。



----------------

## 兼容性

我们建议使用 RockyLinux 8.8， Ubuntu 22.04 (jammy)， Debian 12 (bookworm) 作为安装 Pigsty 的操作系统。

任何与 EL 7,8,9 / Ubuntu 20.04,22.04 / Debian 11/12 兼容的操作系统发行版都应当可以正常工作。

| 代码  | 操作系统发行版 / PG 大版本                  | PG16 | PG15 | PG14 | PG13 | PG12 | 局限性                                          |
|:---:|-----------------------------------|:----:|:----:|:----:|:----:|:----:|----------------------------------------------|
| EL7 | RHEL7 / CentOS7                   |  ⚠️  |  ⭐️  |  ✅   |  ✅   |  ✅   | PG16, supabase, pgml, pg_graphql, pg_net 不可用 |
| EL8 | RHEL 8 / Rocky8 / Alma8 / Anolis8 |  ✅   |  ⭐️  |  ✅   |  ✅   |  ✅   | **EL功能基准**                                   |
| EL9 | RHEL 9 / Rocky9 / Alma9           |  ✅   |  ⭐️  |  ✅   |  ✅   |  ✅   | pgxnclient missing, perf 依赖冲突                |
| D11 | Debian 11 (bullseye)              |  ✅   |  ⭐️  |  ✅   |  ✅   |  ✅   | supabase, pgml, RDKit 不可用                    |
| D12 | Debian 12 (bookworm)              |  ✅   |  ⭐️  |  ✅   |  ✅   |  ✅   | supabase, pgml 不可用                           |
| U20 | Ubuntu 20.04 (focal)              |  ✅   |  ⭐️  |  ✅   |  ✅   |  ✅   | supabase, PostGIS3, RDKit, pgml 不可用          |
| U22 | Ubuntu 22.04 (jammy)              |  ✅   |  ⭐️  |  ✅   |  ✅   |  ✅   | **DEB功能基准**     (supabase 不可用)               |


* ⭐️ PostgreSQL 15 是当前主要支持的大版本，在离线软件包中带有所有的功能扩展集。
* ⭐ PostgreSQL 16 是备选的主要支持大版本，当时机成熟后（重要扩展均完成适配）会被提升为主要大版本。
* ⚠️ EL7 将于 2024 年 EOL，并且 PGDG 官方已经不再提供 PG 16 的支持。
* ⚠️ Ubuntu & Debian 支持在 Pigsty v2.5.0 引入，尚未经过大规模生产测试，请小心使用。


----------------

## 关于

> Pigsty (/ˈpɪɡˌstaɪ/) 是 "**P**ostgreSQL **I**n **G**reat **STY**le" 的缩写，即“全盛状态的PostgreSQL”

文档: https://doc.pigsty.cc/

网站: https://pigsty.cc/en/ | https://pigsty.cc/zh/

微信: 搜索 `pigsty-cc` 加入 PGSQL x Pigsty 交流群

Telegram: https://t.me/joinchat/gV9zfZraNPM3YjFh

Discord: https://discord.gg/Mu2b6Wxr

作者: [Vonng](https://vonng.com/en) ([rh@vonng.com](mailto:rh@vonng.com))

协议: [AGPL-3.0](LICENSE)

版权所有 2018-2023 rh@vonng.com