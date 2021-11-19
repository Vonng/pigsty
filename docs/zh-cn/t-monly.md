# 监控系统部署

> 如何使用Pigsty监控已有PostgreSQL实例？

对于由Pigsty所创建的实例，所有监控组件均已自动配置妥当。但对于非Pigsty所创建的现存Pigsty实例，若希望使用Pigsty监控系统的部分对其监控，则需一些额外的配置。



## 太长；不看

1. 在目标实例创建监控对象：[监控对象配置](#监控对象配置) 

2. 在配置清单中声明该集群：

   ```yaml
   pg-test:
     hosts:                                # 为每个实例分配唯一本地端口
       10.10.10.11: { pg_seq: 1, pg_role: primary , pg_exporter_port: 20001}
       10.10.10.12: { pg_seq: 2, pg_role: replica , pg_exporter_port: 20002}
       10.10.10.13: { pg_seq: 3, pg_role: offline , pg_exporter_port: 20003}
     vars:
       pg_cluster: pg-test                 # 填入集群名称
       pg_version: 14                      # 填入数据库大版本
       pg_databases: [{ name: test }]      # 填入数据库列表（每个数据库对象作为一个数组元素）
       
   # 在全局/集群/实例配置中提供监控用户密码 pg_monitor_username/pg_monitor_password
   ```

3. 针对该集群执行剧本：`./pgsql-monly.yml -l pg-test`





## 监控部署概述

如果用户只希望使用Pigsty的**监控系统**部分，比如希望使用Pigsty监控系统监控已有的PostgreSQL实例，那么可以使用 **仅监控部署（monitor only）** 模式。仅监控模式下，您可以使用Pigsty管理监控其他PostgreSQL实例（目前默认支持10+以上的版本，更老的版本可以通过手工修改 pg_exporter 配置文件支持）

首先，您需要在1台（或多台）管理节点上完成标准的Pigsty的标准安装流程，然后便可以将更多的数据库实例接入监控。按照目标数据库节点的访问权限，又可以分为两种情况：



**如果目标节点可被管理**

如果目标DB节点**可以被Pigsty所管理**（ssh可达，sudo可用），那么您可以使用 [`pgsql.yml`](p-pgsql.md) 剧本中的`monitor`任务，使用相同的的方式，在目标节点上部署监控组件：PG Exporter, Node Exporter。您也可以使用该剧本的其他任务，在已有实例节点上部署额外的组件及其监控：连接池Pgbouncer与负载均衡器HAProxy，日志收集的Agent，从而获得与原生Pigsty数据库实例完全一致的使用体验。

因为目标数据库集群已存在，您需要参考本节的内容手工在目标数据库集群上[创建监控用户、模式与扩展](#监控对象配置)。其余流程与完整部署并无区别。



**如果只有数据库连接串**

如果您**只能通过PGURL**（数据库连接串）的方式访问目标数据库，则可以考虑使用**仅监控模式/精简模式**（Monitor Only：Monly）监控目标数据库。在此模式下，所有监控组件均部署在安装Pigsty的管理节点上。监控系统不会有 节点，连接池，负载均衡器的相关指标，但数据库本身，以及数据目录（Catalog）中的实时状态信息仍然可用。

为了执行精简监控部署，您同样需要参考本节的内容手工在目标数据库集群上[创建监控用户、模式与扩展](#监控对象配置)，并确保可以从管理节点上使用监控用户访问目标数据库。此后，针对目标集群执行`pgsql-monly.yml`剧本即可完成部署。

**本文着重介绍此种监控部署模式**。



![](../_media/monly.svg)

> 图：仅监控模式架构示意图，部署于管理机本地的多个PG Exporter用于监控多个远程数据库实例。





## 精简部署与标准部署的区别

Pigsty监控系统由三个核心模块组成：

* PGCAT：基于数据库数据字典的信息展示，呈现当前数据库状态信息，但无法回溯历史数据。
* PGSQL：基于指标数据的监控，由Prometheus采集数据库/连接池/机器节点/负载均衡器相关指标并呈现，是Pigsty监控的主体部分。
* PGLOG：数据库日志，提供实时日志查阅能力，与额外的监控指标。基于Grafana Loki / Promtail，选装项目。

|   事项\等级    |          L1           |           L2           |           L3           |
| :------------: | :-------------------: | :--------------------: | :--------------------: |
|      名称      |       基础部署        |        托管部署        |        完整部署        |
|      英文      |         basic         |        managed         |          full          |
|      场景      |      只有连接串       |  DB已存在，节点可管理  |    实例由Pigsty创建    |
|   PGCAT功能    |      ✅ 完整可用       |       ✅ 完整可用       |       ✅ 完整可用       |
|   PGSQL功能    |      ✅ 限PG指标       |    ✅ 限PG与节点指标    |       ✅ 完整功能       |
|   连接池指标   |       ❌ 不可用        |         ⚠️ 选装         |        ✅ 预装项        |
| 负载均衡器指标 |       ❌ 不可用        |         ⚠️ 选装         |        ✅ 预装项        |
|   PGLOG功能    |       ❌ 不可用        |         ⚠️ 选装         |         ⚠️ 选装         |
|  PG Exporter   |   ⚠️ 部署于管理节点    |     ✅ 部署于DB节点     |     ✅ 部署于DB节点     |
| Node Exporter  |       ❌ 不部署        |     ✅ 部署于DB节点     |     ✅ 部署于DB节点     |
|   侵入DB节点   |       ✅ 无侵入        |     ⚠️ 安装Exporter     |   ⚠️ 完全由Pigsty管理   |
|  监控现有实例  |       ✅ 可支持        |        ✅ 可支持        | ❌ 仅用于Pigsty托管实例 |
| 监控用户与视图 |       人工创建        |        人工创建        |     Pigsty自动创建     |
|  部署使用剧本  |   `pgsql-monly.yml`   | `pgsql.yml -t monitor` | `pgsql.yml -t monitor` |
|    所需权限    |  管理节点可达的PGURL  |  DB节点ssh与sudo权限   |  DB节点ssh与sudo权限   |
|    功能概述    | 基础功能：PGCAT+PGSQL |       大部分功能       |        完整功能        |









## 监控已有实例：精简模式

为数据库实例部署监控系统分为三步：[准备监控对象](#准备监控对象)，[修改配置清单](#修改配置清单)，[执行部署剧本](#执行部署剧本)。



### 准备监控对象

为了将外部现存PostgreSQL实例纳入监控，您需要有一个可用于访问该实例/集群的连接串。任何可达连接串（业务用户，超级用户）均可使用，但我们建议使用一个专用监控用户以避免权限泄漏。

- [ ] 监控用户：默认使用的用户名为 `dbuser_monitor`， 该用户需要属于 `pg_monitor` 角色组，或确保具有相关视图访问权限。
- [ ] 监控认证：默认使用密码访问，您需要确保HBA策略允许监控用户从管理机或DB节点本地访问数据库。
- [ ] 监控模式：固定使用名称 `monitor`，用于安装额外的**监控视图**与扩展插件，非必选，但强烈建议创建。
- [ ] 监控扩展：强烈建议启用PG自带的监控扩展 `pg_stat_statements`

关于监控对象的准备细节，请参考文后：[监控对象配置](#监控对象配置) 一节。




### 修改配置清单

如同部署一个全新的Pigsty实例一样，您需要在配置清单（配置文件或CMDB）中声明该目标集群。例如，为集群与实例指定[身份标识](c-config.md#身份参数)。不同之处在于，您还需要在**实例层次**为每一个实例手工分配一个唯一的本地端口号（`pg_exporter_port`）。

下面是一个数据库集群声明样例：

```yaml
pg-test:
  hosts:                                # 为每个实例分配唯一本地端口
    10.10.10.11: { pg_seq: 1, pg_role: primary , pg_exporter_port: 20001}
    10.10.10.12: { pg_seq: 2, pg_role: replica , pg_exporter_port: 20002}
    10.10.10.13: { pg_seq: 3, pg_role: offline , pg_exporter_port: 20003}
  vars:
    pg_cluster: pg-test                 # 填入集群名称
    pg_version: 14                      # 填入数据库大版本
    pg_databases: [{ name: test }]      # 填入数据库列表（每个数据库对象作为一个数组元素）
    
# 在全局/集群/实例配置中提供监控用户密码 pg_monitor_username/pg_monitor_password
```

> 注，即使您通过域名访问数据库，依然需要通过填入实际IP地址的方式来声明数据库集群。

若要启用PGCAT功能，您需要显式在`pg_databases` 中列出目标集群的数据库名称列表，在此列表中的数据库将被注册为Grafana的数据源，您可以直接通过Grafana访问该实例的Catalog数据。若您不希望使用PGCAT相关功能，不设置该变量，或置为空数组即可。



#### 连接信息

说明：Pigsty将默认使用以下规则生成监控连接串。但参数 `pg_exporter_url` 存在时，将直接覆盖拼接连接串。

```bash
postgres://{{ pg_monitor_username }}:{{ pg_monitor_password }}@{{ inventory_hostname }}:{{ pg_port }}/postgres?sslmode=disable
```

您可以在全局使用统一的监控用户/密码设置，或者在**集群层面**或**实例层次**根据实际情况按需配置以下连接参数

```yaml
pg_monitor_username: dbuser_monitor  # 监控用户名，若使用全局统一配置则无需在此配置
pg_monitor_password: DBUser.Monitor  # 监控用户密码，若使用全局统一配置则无需在此配置
pg_port: 5432                        # 若使用非标准的数据库端口，在此修改
```

<details><summary>示例：在实例层面指定连接信息</summary>


```yaml
pg-test:
  hosts:                                # 直接为实例指定访问URL
    10.10.10.11: 
      pg_seq: 1
      pg_role: primary
      pg_exporter_port: 20001
      pg_monitor_username: monitor_user1
      pg_monitor_password: monitor_pass1
    10.10.10.12: 
      pg_seq: 2
      pg_role: replica
      pg_exporter_port: 20002           # 直接指定 pg_exporter_url
      pg_exporter_url: 'postgres://someuser:pass@rds.pg.hongkong.xxx:5432/postgres?sslmode=disable''
    10.10.10.13: 
      pg_seq: 3
      pg_role: offline
      pg_exporter_port: 20003
      pg_monitor_username: monitor_user3
      pg_monitor_password: monitor_pass3
  vars:
    pg_cluster: pg-test                 # 填入集群名称
    pg_version: 14                      # 填入数据库大版本
    pg_databases: [{ name: test }]      # 填入数据库列表（每个数据库对象作为一个数组元素）
```

</details>





### 执行部署剧本

集群声明完成后，将其纳入监控非常简单，在管理节点上针对目标集群使用剧本 `pgsql-monitor.yml` 即可：

```bash
./pgsql-monitor.yml  -l  <cluster>     # 在指定集群上完成监控部署
```





---------------------





## 监控对象配置

### 监控用户

以Pigsty默认使用的监控用户`dbuser_monitor`为例，在目标数据库集群创建以下用户。

```sql
CREATE USER dbuser_monitor;
GRANT pg_monitor TO dbuser_monitor;
COMMENT ON ROLE dbuser_monitor IS 'system monitor user';
ALTER USER dbuser_monitor SET log_min_duration_statement = 1000;
ALTER USER dbuser_monitor PASSWORD 'DBUser.Password'; -- 按需修改监控用户密码
```

配置数据库 `pg_hba.conf` 文件，添加以下规则以允许监控用户从本地，以及管理机使用密码访问数据库。

```ini
# allow local role monitor with password
local   all  dbuser_monitor                    md5
host    all  dbuser_monitor  127.0.0.1/32      md5
host    all  dbuser_monitor  <管理机器IP地址>/32 md5
```

### 监控模式

监控模式与扩展是**可选项**，即使没有，Pigsty监控系统的主体也可以正常工作，但我们强烈建议创建监控模式，并至少启用PG官方自带的 `pg_stat_statements`，该扩展提供了关于查询性能的重要数据。注意：该扩展必须列入数据库参数`shared_preload_libraries` 中方可生效，修改该参数需要重启数据库。

创建扩展模式：

```sql
CREATE SCHEMA IF NOT EXISTS monitor;               -- 创建监控专用模式
GRANT USAGE ON SCHEMA monitor TO dbuser_monitor;   -- 允许监控用户使用
```

### 监控扩展

创建扩展插件：

```sql
-- 强烈建议启用 pg_stat_statements 扩展
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "monitor"; 

-- 可选的其他扩展
CREATE EXTENSION IF NOT EXISTS "pgstattuple" WITH SCHEMA "monitor";
CREATE EXTENSION IF NOT EXISTS "pg_qualstats" WITH SCHEMA "monitor";
CREATE EXTENSION IF NOT EXISTS "pg_buffercache" WITH SCHEMA "monitor";
CREATE EXTENSION IF NOT EXISTS "pageinspect" WITH SCHEMA "monitor";
CREATE EXTENSION IF NOT EXISTS "pg_prewarm" WITH SCHEMA "monitor";
CREATE EXTENSION IF NOT EXISTS "pg_visibility" WITH SCHEMA "monitor";
CREATE EXTENSION IF NOT EXISTS "pg_freespacemap" WITH SCHEMA "monitor";
```

### 监控视图

监控视图提供了若干常用的预处理结果，并对某些需要高权限的监控指标进行权限封装（例如共享内存分配），便于查询与使用。强烈建议在所有需要监控的数据库中创建

<details><summary>监控模式与监控视图定义</summary>

```sql
--==================================================================--
--                            Monitor Schema                        --
--==================================================================--

----------------------------------------------------------------------
-- cleanse
----------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS monitor;
GRANT USAGE ON SCHEMA monitor TO dbuser_monitor;
GRANT USAGE ON SCHEMA monitor TO "{{ pg_admin_username }}";
GRANT USAGE ON SCHEMA monitor TO "{{ pg_replication_username }}";

--==================================================================--
--                            Monitor Views                         --
--==================================================================--

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

```



如果您的PostgreSQL版本大于等于13，此视图可用于查看共享内存分配情况：

```sql
DROP FUNCTION IF EXISTS monitor.pg_shmem() CASCADE;
CREATE OR REPLACE FUNCTION monitor.pg_shmem() RETURNS SETOF
    pg_shmem_allocations AS $$ SELECT * FROM pg_shmem_allocations;$$ LANGUAGE SQL SECURITY DEFINER;
COMMENT ON FUNCTION monitor.pg_shmem() IS 'security wrapper for pg_shmem';
```



</details>

