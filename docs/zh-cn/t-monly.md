# 仅监控部署

> 如何将Pigsty与外部供给方案相集成，只使用Pigsty的监控系统部分。

如果用户只希望使用Pigsty的**监控系统**部分，比如希望使用Pigsty监控系统监控已有的PostgreSQL实例，那么可以使用 **仅监控部署（monitor only）** 模式。

仅监控模式下，您可以使用Pigsty管理监控其他PostgreSQL实例（目前默认支持10+以上的版本，更老的版本可以通过手工修改 pg_exporter 配置文件支持）

首先，您需要在1台（或多台）管理节点上完成Pigsty的标准安装流程，然后便可以将更多的数据库实例接入监控。



## 监控部署的类型

监控部署分为三种情况:

[**完整部署**](p-pgsql.md)

**目标机器由Pigsty所管理，数据库由Pigsty创建，访问遵循标准实践**。

在这种模式下，Pigsty监控系统将工作在最完美的状态。监控部署将在数据库部署时自动完成，无需手工干预。

Pigsty管理节点上本身的PG数据库即采用此模式进行自我监控。


[**精简部署**](#精简部署)

**目标机器SSH可达并有root权限，数据库已存在**。

在这种模式下，Pigsty将在目标机器上部署 `node_exporter` 与 `pg_exporter`，以及可选的 `pgbouncer_exporter`, `haproxy`。

Pigsty监控系统的绝大多数监控项都可以正常使用，但如果您的外部PG实例没有使用Pgbouncer与HAProxy，则相关指标会出现缺失。

在这种情况下，您需要执行 [`pgsql.yml`](p-pgsql) 的一个任务子集（`monitor`），来完成监控系统的精简部署。



[**最小部署**](#最小部署)

**目标机器不可达，只有目标数据库实例的连接权限**。

在这种模式下，您无法获取远程机器节点的系统监控指标，只有PG本身的监控指标，Pigsty监控系统的大部分功能受到限制。

例如，您需要通过 PGSQL Cluster Monly 而非默认的 PGSQL Cluster 面板来获取较为完整的可视化体验。

在这种情况下，您需要使用专用的 [`pgsql-monly.yml`]() 剧本，来完成监控系统的最小部署。



## 监控用户

无论采用何种部署模式，您都需要一个用于监控的用户。

- [ ] 监控用户：默认使用的用户名为 `dbuser_monitor`， 该用户需要属于 `pg_monitor` 角色组。
- [ ] 监控认证：默认使用密码访问，您需要确保HBA策略允许监控用户从（本地：精简部署模式）或（管理机：最小部署模式）访问数据库
- [ ] 监控模式：固定使用名称 `monitor`
- [ ] 监控扩展：PG自带的监控扩展 `pg_stat_statements` 需启用（需要确保该扩展位于 shared_preload_libraries中）
- [ ] 监控视图：可选的扩展监控对象

在完整模式中，Pigsty创建的数据库集群会在 [数据库部署](v-pg-provision) 阶段中自动创建用于监控的系统用户，而在精简模式与最小模式下，您需要自行确保监控用户存在。

您需要手工在目标数据库集群中创建监控用户（默认为`dbuser_monitor`），以及监控相关的**模式**与**扩展**。
并调整目标数据库集群的[访问控制](c-auth.md)机制，允许使用该用户连接至数据库并访问监控相关对象。创建监控对象的参考SQL语句如下：

<details>
<summary>监控对象创建</summary>
```sql
-- 创建监控用户
CREATE USER dbuser_monitor;
ALTER ROLE dbuser_monitor PASSWORD 'DBUser.Monitor';
ALTER USER dbuser_monitor CONNECTION LIMIT 16;
GRANT pg_monitor TO dbuser_monitor;
    
-- 创建监控模式
CREATE SCHEMA IF NOT EXISTS monitor;
GRANT USAGE ON SCHEMA monitor TO dbuser_monitor;

-- 创建监控扩展（您需要确保该扩展位于 shared_preload_libraries中 ）
CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA monitor;
```
</details>


<details>
<summary>监控HBA规则</summary>

```ini
# 允许监控用户从本地访问（完整部署模式/精简部署模式）
local   all        dbuser_monitor                        md5
host    all        dbuser_monitor      127.0.0.1/32      md

# 允许监控用户从管理机访问（最小部署模式）
host    all        dbuser_monitor      10.10.10.10/32      md5
```

</details>


<details>
<summary>监控视图定义</summary>

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
SELECT coalesce(datname, 'all') AS datname,
       numbackends,
       active,
       idle,
       ixact,
       max_duration,
       max_tx_duration,
       max_conn_duration
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



{% if pg_version >= 13 %}
----------------------------------------------------------------------
-- pg_shmem auxiliary function
-- PG 13 ONLY!
----------------------------------------------------------------------
DROP FUNCTION IF EXISTS monitor.pg_shmem() CASCADE;
CREATE OR REPLACE FUNCTION monitor.pg_shmem() RETURNS SETOF
    pg_shmem_allocations AS $$ SELECT * FROM pg_shmem_allocations;$$ LANGUAGE SQL SECURITY DEFINER;
COMMENT ON FUNCTION monitor.pg_shmem() IS 'security wrapper for pg_shmem';
{% endif %}
```


</details>





-------------------


## 精简部署

### 精简模式的工作假设

- 数据库采用**独占式部署**，与节点存在**一一对应**关系。只有这样，节点指标才能有意义地与数据库指标关联。
- 目标节点可以被Ansible管理（NOPASS SSH与NOPASS SUDO），一些云厂商RDS产品并不允许这样做。
- 数据库需要创建可用于访问监控指标的**监控用户**，安装必须的监控模式与扩展，并合理配置其访问控制权限

### 精简模式的优点

Pigsty监控系统的绝大多数监控项都可以正常使用，但如果您的外部PG实例没有使用Pgbouncer与HAProxy，则相关指标会出现缺失。


### 精简模式的局限性

**指标缺失**

Pigsty会集成多种[来源](m-metric.md#指标数量)的指标，包括机器节点，数据库，Pgbouncer连接池，Haproxy负载均衡器。如果用户自己的供给方案中缺少这些组件，则相应指标也会发生缺失。

通常Node与PG的监控指标总是存在，而PGbouncer与Haproxy的缺失通常会导致**100～200**个不等的指标损失。

特别是，Pgbouncer监控指标中包含极其重要的PG QPS，TPS，RT，而这些指标是**无法从PostgreSQL本身获取**的。

**服务发现**

外部供给方案通常拥有自己的身份管理机制，因此Pigsty不会越俎代庖地部署DCS用于**服务发现**。这意味着用户只能采用 **静态配置文件** 的方式管理监控对象的身份，通常这并不是一个问题，因为Pigsty v1.0.0默认使用基于静态文件的服务发现机制。

**身份变更**

在Pigsty沙箱中，当实例的角色身份发生变化时，系统会通过回调函数与反熵过程及时修正实例的角色信息，如将`primary`修改为`replica`，将其他角色修改为`primary`。

```json
pg_up{cls="pg-meta", ins="pg-meta-1", instance="10.10.10.10:9630", ip="10.10.10.10", job="pg"}
```

Pigsty的监控系统中不会使用与身份相关的标签（例如`svc`，`role`），因此时间序列的标签不会因为主从切换而变化。
如果您的外部系统，脚本，工具使用Consul服务注册中的角色信息（`service`，`role`），有必要关注自动主从切换导致的身份变化问题。

**管理权限**

Pigsty的监控指标依赖 `node_exporter` 与 `pg_exporter` 获取。

尽管`pg_exporter`可以采用exporter拉取远程数据库实例信息的方式部署，但`node_exporter`必须部署在数据库所属的节点上。

这意味着，用户必须拥有数据库所在机器的SSH登陆与`sudo`权限才能完成部署。该权限仅在部署时需要：目标节点必须可以被Ansible**纳入管理**，而云厂商RDS通常不会给出此类权限。

### 精简模式部署流程

- 在**元节点**上完成[**基础设施初始化**](p-infra.md)的部分，与标准流程**一致**。

- 修改配置文件，在仅监控模式中，通常只需要提供目标集群的[身份参数](c-config.md#身份参数)，并按需调整[监控系统](v-monitor.md)部分的参数。

- 确认无误后，针对目标集群执行 [`pgsql.yml`](p-pgsql) 剧本的子集任务（`-t monitor`），完成监控系统的精简部署。


### 监控连接串

默认情况下，Pigsty会尝试使用以下规则生成数据库与连接池的连接串。

```bash
PG_EXPORTER_URL='postgres://{{ pg_monitor_username }}:{{ pg_monitor_password }}@:{{ pg_port }}/postgres?host={{ pg_localhost }}&sslmode=disable'
PGBOUNCER_EXPORTER_URL='postgres://{{ pg_monitor_username }}:{{ pg_monitor_password }}@:{{ pgbouncer_port }}/pgbouncer?host={{ pg_localhost }}&sslmode=disable'
```

如果用户使用的监控角色连接串无法通过该规则生成，则可以使用以下参数直接配置数据库与连接池的连接信息：

- [`pg_exporter_url`](v-monitor.md#pg_exporter_url)
- [`pgbouncer_exporter_url`](v-monitor.md#pgbouncer_exporter_url)

作为样例，沙箱环境中元节点连接至数据库的连接串为：

```bash
PG_EXPORTER_URL='postgres://dbuser_monitor:DBUser.Monitor@:5432/postgres?host=/var/run/postgresql&sslmode=disable'
```

> ### 懒人方案
>
> 如果不怎么关心安全性与权限，也可以直接使用dbsu ident认证的方式，例如`postgres`用户进行监控。
>
> `pg_exporter` 默认以 `dbsu` 的用户执行，如果允许`dbsu`通过本地`ident`认证免密访问数据库（Pigsty默认配置），则可以直接使用超级用户监控数据库。
>
> Pigsty**非常不推荐**这种部署方式，但它确实很方便，既不用创建新用户，也不用配置权限。
>
> ```bash
> PG_EXPORTER_URL='postgres:///postgres?host=/var/run/postgresql&sslmode=disable'
> ```



### 相关参数

使用**仅监控部署**时，只会用到Pigsty参数的一个子集。

**基础设施部分**

基础设施与元节点仍然与常规部署保持一致，除了以下两个参数必须强制使用指定的配置选项。

```yml
service_registry: none            # 须关闭服务注册，因为目标环境可能没有DCS基础设施。
prometheus_sd_method: static      # 须使用静态文件服务发现，因为目标实例可能并没有使用服务发现与服务注册
```

**目标节点部分**

目标节点的[身份参数](c-config.md#身份参数)仍然为必选项，因为这些参数定义了数据库实例在监控系统中的身份标识。

除此之外，通常只需要调整[监控系统参数](v-monitor)。


```yaml

#------------------------------------------------------------------------------
# MONITOR PROVISION
#------------------------------------------------------------------------------
# - install - #
exporter_install: none                        # none|yum|binary, none by default
exporter_repo_url: ''                         # if set, repo will be added to /etc/yum.repos.d/ before yum installation

# - collect - #
exporter_metrics_path: /metrics               # default metric path for pg related exporter

# - node exporter - #
node_exporter_enabled: true                   # setup node_exporter on instance
node_exporter_port: 9100                      # default port for node exporter
node_exporter_options: '--no-collector.softnet --no-collector.nvme --collector.ntp --collector.tcpstat --collector.processes'

# - pg exporter - #
pg_exporter_config: pg_exporter.yml           # default config files for pg_exporter
pg_exporter_enabled: true                     # setup pg_exporter on instance
pg_exporter_port: 9630                        # default port for pg exporter
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

# - promtail - #                              # promtail is a beta feature which requires manual deployment
promtail_enabled: true                        # enable promtail logging collector?
promtail_clean: false                         # remove promtail status file? false by default
promtail_port: 9080                           # default listen address for promtail
promtail_status_file: /tmp/promtail-status.yml
promtail_send_url: http://10.10.10.10:3100/loki/api/v1/push  # loki url to receive logs

```

通常来说，需要调整的参数包括：

```yaml
exporter_install: binary          # none|yum|binary 建议使用拷贝二进制的方式安装Exporter
pgbouncer_exporter_enabled: false # 如果目标实例没有关联的Pgbouncer实例，则需关闭Pgbouncer监控
pg_exporter_url: ''               # 连接至 Postgres  的URL，如果不采用默认的URL拼合规则，则可使用此参数
pgbouncer_exporter_url: ''        # 连接至 Pgbouncer 的URL，如果不采用默认的URL拼合规则，则可使用此参数
pg_exporter_auto_discovery: true              # optional, discovery available database on target instance ?
pg_exporter_exclude_database: 'template0,template1,postgres' # optional, comma separated list of database that WILL NOT be monitored when auto-discovery enabled
pg_exporter_include_database: ''             # optional, comma separated list of database that WILL BE monitored when auto-discovery enabled, empty string will disable include mode
```



### 执行部署

参数调整完毕后，在目标集群`<cluster>`上执行以下剧本，即可完成监控部署：

```bash
./pgsql.yml -t monitor -l <cluster>
```

!> 忘记使用 `-t` 指定`monitor`任务会执行数据库实例初始化，执行前请确保命令正确

监控组件部署完成后，您可以通过以下命令，将其注册至基础设施中：

```bash
./pgsql.yml -t register_prometheus,register_grafana -l <cluster>
```

`register_prometheus` 任务会将目标数据库实例加入到Prometheus的监控对象列表中，而`register_grafana`则会将集群中所有业务数据库作为数据源注册至Grafana。








-------------------

## 最小部署

### 优越性

当目标机器不可达，只有目标数据库实例的连接权限时，只能使用最小部署模式，例如云厂商的RDS服务。

### 局限性

在这种模式下，您无法获取远程机器节点的系统监控指标，只有PG本身的监控指标，Pigsty监控系统的大部分功能受到限制。

例如，您需要通过 PGSQL Cluster Monly 而非默认的 PGSQL Cluster 面板来获取较为完整的可视化体验。


### 最小部署的方式

最小部署只会部署 `pg_exporter`，而且是通过部署在管理节点本地启动新的进程的方式进行。

每一个待监控的实例，都需要您手工为其分配一个唯一不冲突的本地端口，用于启动 `pg_exporter`，该参数必须在实例层次上指定。

 [`pgsql-monly.yml`]() 剧本用于完成监控系统的最小部署。

