# 应用软件

许多软件都会用到 PostgreSQL，Pigsty 为一些流行的软件提供了一些 docker compose 模板。

你可以轻松地使用 docker 启动无状态软件，并使用外部由 Pigsty 托管的高可用 PostgreSQL 来获得更高的可靠性、可维护性与可伸缩性。

Docker 默认并没有安装，但是包含在离线软件包中。例如，您可以使用 `./docker.yml -l infra` 在 infra 分组的节点上安装并启用 Docker。

一些可用的软件列表与安装说明请参考：[pigsty/app](https://github.com/Vonng/pigsty/tree/master/app)

[![pigsty-app.jpg](https://repo.pigsty.cc/img/pigsty-app.jpg)](https://github.com/Vonng/pigsty/tree/master/app)



----------------

## PostgreSQL 管理

> 使用更先进的工具管理 PostgreSQL 实例/集群。

- [PgAdmin4](https://github.com/Vonng/pigsty/tree/master/app/pgadmin)：一个用于管理 PostgreSQL 实例的图形界面工具。
- [ByteBase](https://github.com/Vonng/pigsty/tree/master/app/bytebase)：一个用于 PostgreSQL 架构迁移的图形界面 IaC 工具。
- [PGWeb](https://github.com/Vonng/pigsty/tree/master/app/pgweb)：一个根据 PG 数据库架构自动生成后端 API 服务的工具。
- [SchemaSPY](https://github.com/Vonng/pigsty/blob/master/bin/schemaspy)：生成数据库架构模式的详细可视化报告。
- [Pgbadger](https://github.com/Vonng/pigsty/blob/master/bin/pglog-summary)：从日志样本生成 PostgreSQL 总结报告。


----------------

## 应用开发

> 使用 PostgreSQL 及其生态系统搭建你的应用。

- [Supabase](https://github.com/Vonng/pigsty/tree/master/app/supabase)：[Supabase](https://supabase.com/)，基于 PostgreSQL 的开源 Firebase 替代，流行的应用层数据库。
- [FerretDB](https://github.com/Vonng/pigsty/tree/master/app/ferretdb)：[FerretDB](https://www.ferretdb.io/)，基于 PostgreSQL 的真正开源的 MongoDB 替代品。
- [PostgREST](https://github.com/Vonng/pigsty/tree/master/app/postgrest)：[PostgREST](https://postgrest.org/en/stable/)，自动从任何 Postgres 数据库提供 RESTful API。
- [Kong](https://github.com/Vonng/pigsty/tree/master/app/kong)：[Kong](https://konghq.com/kong/)，一个可伸缩的开源 API 网关，支持 Redis/PostgreSQL/OpenResty。
- [EdgeDB](https://github.com/Vonng/pigsty/tree/master/app/edgedb)：[EdgeDB](https://www.edgedb.com/)，基于 PostgreSQL 的开源图形数据库。
- DuckDB：[DuckDB](https://duckdb.org/)，与 PostgreSQL 兼容的嵌入式 SQL olap DBMS。


----------------

## 业务软件

> 轻松地使用 PostgreSQL 启动开源软件。

- [Wiki.js](https://github.com/Vonng/pigsty/tree/master/app/wiki)：[Wiki.js](https://js.wiki/)，最强大且可扩展的开源 wiki 软件。
- [Gitea](https://github.com/Vonng/pigsty/tree/master/app/gitea)：[Gitea](https://gitea.io/)，无痛的自托管 git 服务。
- [NocoDB](https://github.com/Vonng/pigsty/tree/master/app/nocodb)：[NocoDB](https://nocodb.com/)，AirTable开源替代，您自己的云Excel。
- Gitlab：开源代码托管平台。
- Harbour：开源镜像仓库。
- Jira：开源项目管理平台。
- Confluence：开源知识托管平台。
- Odoo：开源 ERP。
- Mastodon：基于 PG 的社交网络。
- Discourse：基于 PG 和 Redis 的开源论坛。
- Jupyter Lab：一个用于数据分析和处理的内置 Python 实验室环境。
- Grafana：使用 postgres 作为后端存储。
- Promscale：使用 postgres/timescaledb 作为 prometheus 指标存储。


----------------

## 数据可视化

> 使用 PostgreSQL, Grafana 和 Echarts 进行数据可视化。

- isd：noaa 天气数据可视化：[github.com/Vonng/isd](https://github.com/Vonng/isd)，[演示](https://demo.pigsty.cc/d/isd-overview)
- pglog：PostgreSQL CSVLOG 样本分析器。[演示](https://demo.pigsty.cc/d/pglog-overview)
- covid：Covid-19 数据可视化。
- dbeng：数据库受欢迎程度可视化。
- price：RDS，ECS 价格比较。
