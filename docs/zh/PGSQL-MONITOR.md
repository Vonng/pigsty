# PostgreSQL 监控接入

> Pigsty监控系统架构概览，以及如何监控现存的 PostgreSQL 实例？


本文介绍了 Pigsty 的监控系统架构，包括[监控指标](#监控指标)，[日志](#日志)，与[目标管理](#目标管理)的方式。同时还介绍了如何监控现有 PostgreSQL 集群与远程 RDS 服务。


----------------

## 监控概览

Pigsty使用现代的可观测技术栈对 PostgreSQL 进行监控：

- 使用Grafana进行指标可视化和PostgreSQL数据源。
- 使用Prometheus来监控PostgreSQL / Pgbouncer / Patroni / HAProxy / Node的指标
- 使用Loki来记录PostgreSQL / Pgbouncer / Patroni / pgBackRest的日志
- Pigsty 提供了开箱即用的 Grafana [仪表盘](PGSQL-DASHBOARD)，展示与 PostgreSQL 有关的方方面面。

### 监控指标

PostgreSQL 本身的监控指标完全由 pg_exporter 配置文件所定义：[`pg_exporter.yml`](https://github.com/Vonng/pigsty/blob/master/roles/pgsql/templates/pg_exporter.yml)

它将进一步被 Prometheus 记录规则和告警规则进行加工处理：[`files/prometheus/rules/pgsql.yml`](https://github.com/Vonng/pigsty/blob/master/files/prometheus/rules/pgsql.yml)

3个标签：`cls`、`ins`、`ip`将附加到所有指标和日志上，例如`{ cls: pg-meta, ins: pg-meta-1, ip: 10.10.10.10 }`

此外，Pgbouncer的监控指标，主机节点 NODE，与负载均衡器的监控指标也会被 Pigsty 所使用。

### 日志

与 PostgreSQL 有关的日志由 promtail 负责收集，并发送至 infra 节点上的 Loki 日志存储/查询服务。

- [`pg_log_dir`](PARAM#pg_log_dir) : postgres日志目录，默认为`/pg/log/postgres`
- [`pgbouncer_log_dir`](PARAM#pgbouncer_log_dir) : pgbouncer日志目录，默认为`/pg/log/pgbouncer`
- [`patroni_log_dir`](PARAM#patroni_log_dir) : patroni日志目录，默认为`/pg/log/patroni`
- [`pgbackrest_log_dir`](PARAM#pgbackrest_log_dir) : pgbackrest日志目录，默认为`/pg/log/pgbackrest`

### 目标管理

Prometheus的监控目标在 `/etc/prometheus/targets/pgsql/` 下的静态文件中定义，每个实例都有一个相应的文件。

以 `pg-meta-1` 为例：

```yaml
# pg-meta-1 [primary] @ 10.10.10.10
- labels: { cls: pg-meta, ins: pg-meta-1, ip: 10.10.10.10 }
  targets:
    - 10.10.10.10:9630    # <--- pg_exporter 用于PostgreSQL指标
    - 10.10.10.10:9631    # <--- pg_exporter 用于pgbouncer指标
    - 10.10.10.10:8008    # <--- patroni指标（未启用 API SSL 时）
```

当全局标志 [`patroni_ssl_enabled`](PARAM#patroni_ssl_enabled) 被设置时，patroni目标将被移动到单独的文件 `/etc/prometheus/targets/patroni/<ins>.yml`。 因为此时使用的是 https 抓取端点。

当使用 `bin/pgsql-rm` 或 `pgsql-rm.yml` 移除集群时，Prometheus监控目标将被移除。您也可以手动移除它，或使用剧本里的子任务：

```bash
bin/pgmon-rm <ins>      # 从所有infra节点中移除prometheus监控目标
```
当您监控现有 RDS ，已有的 PostgreSQL 实例时，监控目标会被单独放置于： `/etc/prometheus/targets/pgrds/` 目录下，并以集群为单位进行管理。



----------------

## 监控模式

Pigsty 提供三种监控模式，以适应不同的监控需求。

|   事项\等级    |          L1           |                              L2                              |                              L3                              |
| :------------: | :-------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
|      名称      |       基础部署        |                           托管部署                           |                           完整部署                           |
|      英文      |         rds         |                           managed                            |                             full                             |
|      场景      |      只有连接串，例如RDS       |                     DB已存在，节点可管理                     |                       实例由Pigsty创建                       |
|   PGCAT功能    |      ✅ 完整可用       |                          ✅ 完整可用                          |                          ✅ 完整可用                          |
|   PGSQL功能    |      ✅ 限PG指标       |                       ✅ 限PG与节点指标                       |                          ✅ 完整功能                          |
|   连接池指标   |       ❌ 不可用        |                            ⚠️ 选装                            |                           ✅ 预装项                           |
| 负载均衡器指标 |       ❌ 不可用        |                            ⚠️ 选装                            |                           ✅ 预装项                           |
|   PGLOG功能    |       ❌ 不可用        |                            ⚠️ 选装                            |                           ✅ 预装项                           |
|  PG Exporter   |   ⚠️ 部署于Infra节点    |                        ✅ 部署于DB节点                        |                        ✅ 部署于DB节点                        |
| Node Exporter  |       ❌ 不部署        |                        ✅ 部署于DB节点                        |                        ✅ 部署于DB节点                        |
|   侵入DB节点   |       ✅ 无侵入        |                        ⚠️ 安装Exporter                        |                      ⚠️ 完全由Pigsty管理                      |
|  监控现有实例  |       ✅ 可支持        |                           ✅ 可支持                           |                    ❌ 仅用于Pigsty托管实例                    |
| 监控用户与视图 |       人工创建        |                           人工创建                           |                        Pigsty自动创建                        |
|  部署使用剧本  |   `bin/pgmon-add <cls>`   | `pgsql.yml -t pg_exporter`<br />`node.yml -t node_exporter`<br />`node.yml -t promtail` |       `pgsql.yml` |
|    所需权限    |  Infra 节点可达的PGURL  |                     DB节点ssh与sudo权限                      |                     DB节点ssh与sudo权限                      |
|    功能概述    | 基础功能：PGCAT+PGSQL |                          大部分功能                          |                           完整功能                           |


由Pigsty完全管理的数据库会自动纳入监控，并拥有最好的监控支持，通常不需要任何配置。

如果目标DB节点**可以被Pigsty所管理**（ssh可达，sudo可用），那么您可以使用 [`pgsql.yml`](PGSQL-PLAYBOOK#pgsqlyml) 剧本中的`pg_exporter`任务，
使用相同的的方式，在目标节点上部署监控组件：PG Exporter。您也可以使用该剧本的 `pgbouncer`，`pgbouncer_exporter` 任务在已有实例节点上部署连接池及其监控。
此外，您也可以使用 [`node.yml`](NODE#nodeyml) 中的 `node_exporter`， `haproxy`， `promtail` 部署主机监控，负载均衡，日志收集组件。从而获得与原生Pigsty数据库实例完全一致的使用体验。
因为目标数据库集群已存在，您需要参考本节的内容手工在目标数据库集群上[创建监控用户、模式与扩展](#监控对象配置)。其余流程与完整部署并无区别。但您依然可以将 Pigsty 作为独立的监控系统使用，监控已有的 PostgreSQL 实例与 RDS。

如果您**只能通过PGURL**（数据库连接串）的方式访问目标数据库，例如远程的RDS服务，则可以考虑使用 [**精简模式**](#监控rds) 监控目标数据库。
在此模式下，所有监控组件均部署在安装Pigsty的基础设施节点上。**监控系统不会有 节点，连接池，负载均衡器，高可用组件的相关指标**，但数据库本身，以及数据目录（Catalog）中的实时状态信息仍然可用。
您同样需要在远端数据库上[创建监控用户、模式与扩展](#监控对象配置)。




----------------

## 监控RDS

Pigsty 可以单独作为一个监控系统，监控已有的 PostgreSQL 实例，比如 RDS 或其他自建 PG，但是这通常需要一些额外的配置工作，也有一些额外的局限性。
好处是这样做不需要您拥有节点的 ssh/sudo 权限，您只需要一个连接串就可以将目标实例纳入监控。

监控现有 PostgreSQL 实例时，您需要在 Infra 节点上部署对应数量的 PG Exporter，抓取远端数据库指标信息。

```
------ infra ------
|                 |
|   prometheus    |            v---- pg-foo-1 ----v
|       ^         |  metrics   |         ^        |
|   pg_exporter <-|------------|----  postgres    |
|   (port: 20001) |            | 10.10.10.10:5432 |
|       ^         |            ^------------------^
|       ^         |                      ^
|       ^         |            v---- pg-foo-2 ----v
|       ^         |  metrics   |         ^        |
|   pg_exporter <-|------------|----  postgres    |
|   (port: 20002) |            | 10.10.10.11:5433 |
-------------------            ^------------------^
```

下面我们使用沙箱环境作为示例：现在我们假设 `pg-meta` 集群是一个有待监控的现有 PostgreSQL 集群 `pg-foo`，而 `pg-test` 集群则是一个有待监控的现有 PostgreSQL 集群 `pg-bar`：

1. 在目标上创建监控模式、用户和权限。详情请参考[监控对象配置](#监控对象配置)
2. 在库存中声明集群。例如，假设我们想要监控“远端”的 `pg-meta` & `pg-test` 集群，名称为 `pg-foo` 和 `pg-bar`，我们可以在库存中声明它们如下：

```yaml
infra:            # 代理、监控、警报等的infra集群..
  hosts: { 10.10.10.10: { infra_seq: 1 } }

  vars:           # 在组'infra'上为远程postgres RDS安装pg_exporter

    pg_exporters: # 在此列出所有远程实例，为k分配一个唯一的未使用的本地端口

      20001: { pg_cluster: pg-foo, pg_seq: 1, pg_host: 10.10.10.10 }

      20002: { pg_cluster: pg-bar, pg_seq: 1, pg_host: 10.10.10.11 , pg_port: 5432 }
      20003: { pg_cluster: pg-bar, pg_seq: 2, pg_host: 10.10.10.12 , pg_exporter_url: 'postgres://dbuser_monitor:DBUser.Monitor@10.10.10.12:5432/postgres?sslmode=disable'}
      20004: { pg_cluster: pg-bar, pg_seq: 3, pg_host: 10.10.10.13 , pg_monitor_username: dbuser_monitor, pg_monitor_password: DBUser.Monitor }
```

<details><summary>示例：监控阿里云 RDS for PostgreSQL 与 PolarDB</summary>

详情请参考：[remote.yml](https://github.com/Vonng/pigsty/blob/master/files/pigsty/remote.yml)

```yaml
      20011:
        pg_cluster: pg-polar                        # RDS Cluster Name (Identity, Explicitly Assigned, used as 'cls')
        pg_seq: 1                                   # RDS Instance Seq (Identity, Explicitly Assigned, used as part of 'ins')
        pg_host: pxx.polardbpg.rds.aliyuncs.com     # RDS Host Address
        pg_port: 1921                               # RDS Port
        pg_exporter_include_database: 'test'        # Only monitoring database in this list
        pg_monitor_username: dbuser_monitor         # monitor username, overwrite default
        pg_monitor_password: DBUser_Monitor         # monitor password, overwrite default
        pg_databases: [{ name: test }]              # database to be added to grafana datasource

      20012:
        pg_cluster: pg-polar                        # RDS Cluster Name (Identity, Explicitly Assigned, used as 'cls')
        pg_seq: 2                                   # RDS Instance Seq (Identity, Explicitly Assigned, used as part of 'ins')
        pg_host: pe-xx.polarpgmxs.rds.aliyuncs.com  # RDS Host Address
        pg_port: 1521                               # RDS Port
        pg_databases: [{ name: test }]              # database to be added to grafana datasource

      20014:
        pg_cluster: pg-rds
        pg_seq: 1
        pg_host: pgm-xx.pg.rds.aliyuncs.com
        pg_port: 5432
        pg_exporter_auto_discovery: true
        pg_exporter_include_database: 'rds'
        pg_monitor_username: dbuser_monitor
        pg_monitor_password: DBUser_Monitor
        pg_databases: [ { name: rds } ]

      20015:
        pg_cluster: pg-rdsha
        pg_seq: 1
        pg_host: pgm-2xx8wu.pg.rds.aliyuncs.com
        pg_port: 5432
        pg_exporter_auto_discovery: true
        pg_exporter_include_database: 'rds'
        pg_databases: [{ name: test }, {name: rds}]

      20016:
        pg_cluster: pg-rdsha
        pg_seq: 2
        pg_host: pgr-xx.pg.rds.aliyuncs.com
        pg_exporter_auto_discovery: true
        pg_exporter_include_database: 'rds'
        pg_databases: [{ name: test }, {name: rds}]
```

</details>

3. 执行添加监控命令：`bin/pgmon-add <clsname>`。
4. 要删除远程集群的监控目标，可以使用 `bin/pgmon-rm <clsname>`



---------------------

## 监控对象配置

当您想要监控现有实例时，不论是 RDS，还是自建的 PostgreSQL 实例，您都需要在目标数据库上进行一些配置，以便 Pigsty 可以访问它们。

为了将外部现存PostgreSQL实例纳入监控，您需要有一个可用于访问该实例/集群的连接串。任何可达连接串（业务用户，超级用户）均可使用，但我们建议使用一个专用监控用户以避免权限泄漏。

- [ ] 监控用户：默认使用的用户名为 `dbuser_monitor`， 该用户属于 `pg_monitor` 角色组，或确保具有相关视图访问权限。
- [ ] 监控认证：默认使用密码访问，您需要确保HBA策略允许监控用户从管理机或DB节点本地访问数据库。
- [ ] 监控模式：固定使用名称 `monitor`，用于安装额外的**监控视图**与扩展插件，非必选，但强烈建议创建。
- [ ] 监控扩展：强烈建议启用PG自带的监控扩展 `pg_stat_statements`


### 监控用户

以Pigsty默认使用的监控用户`dbuser_monitor`为例，在目标数据库集群创建以下用户。

```sql
CREATE USER dbuser_monitor;
GRANT pg_monitor TO dbuser_monitor;
COMMENT ON ROLE dbuser_monitor IS 'system monitor user';
ALTER USER dbuser_monitor SET log_min_duration_statement = 1000;
ALTER USER dbuser_monitor PASSWORD 'DBUser.Monitor'; -- 按需修改监控用户密码（建议修改！！）
```

请注意，这里创建的监控用户与密码需要与 [`pg_monitor_username`](param#pg_monitor_username) 与 [`pg_monitor_password`](param#pg_monitor_password) 保持一致。

---------------------

### 监控认证

配置数据库 `pg_hba.conf` 文件，添加以下规则以允许监控用户从本地，以及管理机使用密码访问所有数据库。

```ini
# allow local role monitor with password
local   all  dbuser_monitor                    md5
host    all  dbuser_monitor  127.0.0.1/32      md5
host    all  dbuser_monitor  <管理机器IP地址>/32 md5
```

---------------------

### 监控模式

监控模式**可选项**，即使没有，Pigsty监控系统的主体也可以正常工作，但我们强烈建议设置此模式。

```sql
CREATE SCHEMA IF NOT EXISTS monitor;               -- 创建监控专用模式
GRANT USAGE ON SCHEMA monitor TO dbuser_monitor;   -- 允许监控用户使用
```

---------------------

### 监控扩展

监控扩展是可选项，但我们强烈建议启用 `pg_stat_statements` 扩展该扩展提供了关于查询性能的重要数据。

注意：该扩展必须列入数据库参数 `shared_preload_libraries` 中方可生效，而修改该参数需要重启数据库。

```sql
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "monitor";
```

### 监控视图

监控视图提供了若干常用的预处理结果，并对某些需要高权限的监控指标进行权限封装（例如共享内存分配），便于查询与使用。强烈建议在所有需要监控的数据库中创建

<details><summary>监控模式与监控视图定义</summary>

```sql
----------------------------------------------------------------------
-- Table bloat estimate : monitor.pg_table_bloat
----------------------------------------------------------------------
DROP VIEW IF EXISTS monitor.pg_table_bloat CASCADE;
CREATE OR REPLACE VIEW monitor.pg_table_bloat AS
SELECT CURRENT_CATALOG AS datname, nspname, relname , tblid , bs * tblpages AS size,
       CASE WHEN tblpages - est_tblpages_ff > 0 THEN (tblpages - est_tblpages_ff)/tblpages::FLOAT ELSE 0 END AS ratio
FROM (
         SELECT ceil( reltuples / ( (bs-page_hdr)*fillfactor/(tpl_size*100) ) ) + ceil( toasttuples / 4 ) AS est_tblpages_ff,
                tblpages, fillfactor, bs, tblid, nspname, relname, is_na
         FROM (
                  SELECT
                      ( 4 + tpl_hdr_size + tpl_data_size + (2 * ma)
                          - CASE WHEN tpl_hdr_size % ma = 0 THEN ma ELSE tpl_hdr_size % ma END
                          - CASE WHEN ceil(tpl_data_size)::INT % ma = 0 THEN ma ELSE ceil(tpl_data_size)::INT % ma END
                          ) AS tpl_size, (heappages + toastpages) AS tblpages, heappages,
                      toastpages, reltuples, toasttuples, bs, page_hdr, tblid, nspname, relname, fillfactor, is_na
                  FROM (
                           SELECT
                               tbl.oid AS tblid, ns.nspname , tbl.relname, tbl.reltuples,
                               tbl.relpages AS heappages, coalesce(toast.relpages, 0) AS toastpages,
                               coalesce(toast.reltuples, 0) AS toasttuples,
                               coalesce(substring(array_to_string(tbl.reloptions, ' ') FROM 'fillfactor=([0-9]+)')::smallint, 100) AS fillfactor,
                               current_setting('block_size')::numeric AS bs,
                               CASE WHEN version()~'mingw32' OR version()~'64-bit|x86_64|ppc64|ia64|amd64' THEN 8 ELSE 4 END AS ma,
                               24 AS page_hdr,
                               23 + CASE WHEN MAX(coalesce(s.null_frac,0)) > 0 THEN ( 7 + count(s.attname) ) / 8 ELSE 0::int END
                                   + CASE WHEN bool_or(att.attname = 'oid' and att.attnum < 0) THEN 4 ELSE 0 END AS tpl_hdr_size,
                               sum( (1-coalesce(s.null_frac, 0)) * coalesce(s.avg_width, 0) ) AS tpl_data_size,
                               bool_or(att.atttypid = 'pg_catalog.name'::regtype)
                                   OR sum(CASE WHEN att.attnum > 0 THEN 1 ELSE 0 END) <> count(s.attname) AS is_na
                           FROM pg_attribute AS att
                                    JOIN pg_class AS tbl ON att.attrelid = tbl.oid
                                    JOIN pg_namespace AS ns ON ns.oid = tbl.relnamespace
                                    LEFT JOIN pg_stats AS s ON s.schemaname=ns.nspname AND s.tablename = tbl.relname AND s.inherited=false AND s.attname=att.attname
                                    LEFT JOIN pg_class AS toast ON tbl.reltoastrelid = toast.oid
                           WHERE NOT att.attisdropped AND tbl.relkind = 'r' AND nspname NOT IN ('pg_catalog','information_schema')
                           GROUP BY 1,2,3,4,5,6,7,8,9,10
                       ) AS s
              ) AS s2
     ) AS s3
WHERE NOT is_na;
COMMENT ON VIEW monitor.pg_table_bloat IS 'postgres table bloat estimate';

GRANT SELECT ON monitor.pg_table_bloat TO pg_monitor;

----------------------------------------------------------------------
-- Index bloat estimate : monitor.pg_index_bloat
----------------------------------------------------------------------
DROP VIEW IF EXISTS monitor.pg_index_bloat CASCADE;
CREATE OR REPLACE VIEW monitor.pg_index_bloat AS
SELECT CURRENT_CATALOG AS datname, nspname, idxname AS relname, tblid, idxid, relpages::BIGINT * bs AS size,
       COALESCE((relpages - ( reltuples * (6 + ma - (CASE WHEN index_tuple_hdr % ma = 0 THEN ma ELSE index_tuple_hdr % ma END)
                                               + nulldatawidth + ma - (CASE WHEN nulldatawidth % ma = 0 THEN ma ELSE nulldatawidth % ma END))
                                  / (bs - pagehdr)::FLOAT  + 1 )), 0) / relpages::FLOAT AS ratio
FROM (
         SELECT nspname,idxname,indrelid AS tblid,indexrelid AS idxid,
                reltuples,relpages,
                current_setting('block_size')::INTEGER                                                               AS bs,
                (CASE WHEN version() ~ 'mingw32' OR version() ~ '64-bit|x86_64|ppc64|ia64|amd64' THEN 8 ELSE 4 END)  AS ma,
                24                                                                                                   AS pagehdr,
                (CASE WHEN max(COALESCE(pg_stats.null_frac, 0)) = 0 THEN 2 ELSE 6 END)                               AS index_tuple_hdr,
                sum((1.0 - COALESCE(pg_stats.null_frac, 0.0)) *
                    COALESCE(pg_stats.avg_width, 1024))::INTEGER                                                     AS nulldatawidth
         FROM pg_attribute
                  JOIN (
             SELECT pg_namespace.nspname,
                    ic.relname                                                   AS idxname,
                    ic.reltuples,
                    ic.relpages,
                    pg_index.indrelid,
                    pg_index.indexrelid,
                    tc.relname                                                   AS tablename,
                    regexp_split_to_table(pg_index.indkey::TEXT, ' ') :: INTEGER AS attnum,
                    pg_index.indexrelid                                          AS index_oid
             FROM pg_index
                      JOIN pg_class ic ON pg_index.indexrelid = ic.oid
                      JOIN pg_class tc ON pg_index.indrelid = tc.oid
                      JOIN pg_namespace ON pg_namespace.oid = ic.relnamespace
                      JOIN pg_am ON ic.relam = pg_am.oid
             WHERE pg_am.amname = 'btree' AND ic.relpages > 0 AND nspname NOT IN ('pg_catalog', 'information_schema')
         ) ind_atts ON pg_attribute.attrelid = ind_atts.indexrelid AND pg_attribute.attnum = ind_atts.attnum
                  JOIN pg_stats ON pg_stats.schemaname = ind_atts.nspname
             AND ((pg_stats.tablename = ind_atts.tablename AND pg_stats.attname = pg_get_indexdef(pg_attribute.attrelid, pg_attribute.attnum, TRUE))
                 OR (pg_stats.tablename = ind_atts.idxname AND pg_stats.attname = pg_attribute.attname))
         WHERE pg_attribute.attnum > 0
         GROUP BY 1, 2, 3, 4, 5, 6
     ) est;
COMMENT ON VIEW monitor.pg_index_bloat IS 'postgres index bloat estimate (btree-only)';

GRANT SELECT ON monitor.pg_index_bloat TO pg_monitor;

----------------------------------------------------------------------
-- Relation Bloat : monitor.pg_bloat
----------------------------------------------------------------------
DROP VIEW IF EXISTS monitor.pg_bloat CASCADE;
CREATE OR REPLACE VIEW monitor.pg_bloat AS
SELECT coalesce(ib.datname, tb.datname)                                                   AS datname,
       coalesce(ib.nspname, tb.nspname)                                                   AS nspname,
       coalesce(ib.tblid, tb.tblid)                                                       AS tblid,
       coalesce(tb.nspname || '.' || tb.relname, ib.nspname || '.' || ib.tblid::RegClass) AS tblname,
       tb.size                                                                            AS tbl_size,
       CASE WHEN tb.ratio < 0 THEN 0 ELSE round(tb.ratio::NUMERIC, 6) END                 AS tbl_ratio,
       (tb.size * (CASE WHEN tb.ratio < 0 THEN 0 ELSE tb.ratio::NUMERIC END)) ::BIGINT    AS tbl_wasted,
       ib.idxid,
       ib.nspname || '.' || ib.relname                                                    AS idxname,
       ib.size                                                                            AS idx_size,
       CASE WHEN ib.ratio < 0 THEN 0 ELSE round(ib.ratio::NUMERIC, 5) END                 AS idx_ratio,
       (ib.size * (CASE WHEN ib.ratio < 0 THEN 0 ELSE ib.ratio::NUMERIC END)) ::BIGINT    AS idx_wasted
FROM monitor.pg_index_bloat ib
         FULL OUTER JOIN monitor.pg_table_bloat tb ON ib.tblid = tb.tblid;

COMMENT ON VIEW monitor.pg_bloat IS 'postgres relation bloat detail';
GRANT SELECT ON monitor.pg_bloat TO pg_monitor;

----------------------------------------------------------------------
-- monitor.pg_index_bloat_human
----------------------------------------------------------------------
DROP VIEW IF EXISTS monitor.pg_index_bloat_human CASCADE;
CREATE OR REPLACE VIEW monitor.pg_index_bloat_human AS
SELECT idxname                            AS name,
       tblname,
       idx_wasted                         AS wasted,
       pg_size_pretty(idx_size)           AS idx_size,
       round(100 * idx_ratio::NUMERIC, 2) AS idx_ratio,
       pg_size_pretty(idx_wasted)         AS idx_wasted,
       pg_size_pretty(tbl_size)           AS tbl_size,
       round(100 * tbl_ratio::NUMERIC, 2) AS tbl_ratio,
       pg_size_pretty(tbl_wasted)         AS tbl_wasted
FROM monitor.pg_bloat
WHERE idxname IS NOT NULL;
COMMENT ON VIEW monitor.pg_index_bloat_human IS 'postgres index bloat info in human-readable format';
GRANT SELECT ON monitor.pg_index_bloat_human TO pg_monitor;


----------------------------------------------------------------------
-- monitor.pg_table_bloat_human
----------------------------------------------------------------------
DROP VIEW IF EXISTS monitor.pg_table_bloat_human CASCADE;
CREATE OR REPLACE VIEW monitor.pg_table_bloat_human AS
SELECT tblname                                          AS name,
       idx_wasted + tbl_wasted                          AS wasted,
       pg_size_pretty(idx_wasted + tbl_wasted)          AS all_wasted,
       pg_size_pretty(tbl_wasted)                       AS tbl_wasted,
       pg_size_pretty(tbl_size)                         AS tbl_size,
       tbl_ratio,
       pg_size_pretty(idx_wasted)                       AS idx_wasted,
       pg_size_pretty(idx_size)                         AS idx_size,
       round(idx_wasted::NUMERIC * 100.0 / idx_size, 2) AS idx_ratio
FROM (SELECT datname,
             nspname,
             tblname,
             coalesce(max(tbl_wasted), 0)                         AS tbl_wasted,
             coalesce(max(tbl_size), 1)                           AS tbl_size,
             round(100 * coalesce(max(tbl_ratio), 0)::NUMERIC, 2) AS tbl_ratio,
             coalesce(sum(idx_wasted), 0)                         AS idx_wasted,
             coalesce(sum(idx_size), 1)                           AS idx_size
      FROM monitor.pg_bloat
      WHERE tblname IS NOT NULL
      GROUP BY 1, 2, 3
     ) d;
COMMENT ON VIEW monitor.pg_table_bloat_human IS 'postgres table bloat info in human-readable format';
GRANT SELECT ON monitor.pg_table_bloat_human TO pg_monitor;


----------------------------------------------------------------------
-- Activity Overview: monitor.pg_session
----------------------------------------------------------------------
DROP VIEW IF EXISTS monitor.pg_session CASCADE;
CREATE OR REPLACE VIEW monitor.pg_session AS
SELECT coalesce(datname, 'all') AS datname, numbackends, active, idle, ixact, max_duration, max_tx_duration, max_conn_duration
FROM (
         SELECT datname,
                count(*)                                         AS numbackends,
                count(*) FILTER ( WHERE state = 'active' )       AS active,
                count(*) FILTER ( WHERE state = 'idle' )         AS idle,
                count(*) FILTER ( WHERE state = 'idle in transaction'
                    OR state = 'idle in transaction (aborted)' ) AS ixact,
                max(extract(epoch from now() - state_change))
                FILTER ( WHERE state = 'active' )                AS max_duration,
                max(extract(epoch from now() - xact_start))      AS max_tx_duration,
                max(extract(epoch from now() - backend_start))   AS max_conn_duration
         FROM pg_stat_activity
         WHERE backend_type = 'client backend'
           AND pid <> pg_backend_pid()
         GROUP BY ROLLUP (1)
         ORDER BY 1 NULLS FIRST
     ) t;
COMMENT ON VIEW monitor.pg_session IS 'postgres activity group by session';
GRANT SELECT ON monitor.pg_session TO pg_monitor;


----------------------------------------------------------------------
-- Sequential Scan: monitor.pg_seq_scan
----------------------------------------------------------------------
DROP VIEW IF EXISTS monitor.pg_seq_scan CASCADE;
CREATE OR REPLACE VIEW monitor.pg_seq_scan AS
SELECT schemaname                                                        AS nspname,
       relname,
       seq_scan,
       seq_tup_read,
       seq_tup_read / seq_scan                                           AS seq_tup_avg,
       idx_scan,
       n_live_tup + n_dead_tup                                           AS tuples,
       round(n_live_tup * 100.0::NUMERIC / (n_live_tup + n_dead_tup), 2) AS live_ratio
FROM pg_stat_user_tables
WHERE seq_scan > 0
  and (n_live_tup + n_dead_tup) > 0
ORDER BY seq_scan DESC;
COMMENT ON VIEW monitor.pg_seq_scan IS 'table that have seq scan';
GRANT SELECT ON monitor.pg_seq_scan TO pg_monitor;
```

</details>


<details><summary>查看共享内存分配的函数（PG13以上可用）</summary>

```sql
DROP FUNCTION IF EXISTS monitor.pg_shmem() CASCADE;
CREATE OR REPLACE FUNCTION monitor.pg_shmem() RETURNS SETOF
    pg_shmem_allocations AS $$ SELECT * FROM pg_shmem_allocations;$$ LANGUAGE SQL SECURITY DEFINER;
COMMENT ON FUNCTION monitor.pg_shmem() IS 'security wrapper for system view pg_shmem';
REVOKE ALL ON FUNCTION monitor.pg_shmem() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION monitor.pg_shmem() TO pg_monitor;
```

</details>