----------------------------------------------------------------------
-- File      :   pg-init-template.sql
-- Ctime     :   2018-10-30
-- Mtime     :   2021-02-27
-- Desc      :   init postgres cluster template
-- Path      :   /pg/tmp/pg-init-template.sql
-- Author    :   Vonng(fengruohang@outlook.com)
-- Copyright (C) 2018-2022 Ruohang Feng
----------------------------------------------------------------------


--==================================================================--
--                           Executions                             --
--==================================================================--
-- psql template1 -AXtwqf /pg/tmp/pg-init-template.sql
-- this sql scripts is responsible for post-init procedure
-- it will
--    * create system users such as replicator, monitor user, admin user
--    * create system default roles
--    * create schema, extensions in template1 & postgres
--    * create monitor views in template1 & postgres


--==================================================================--
--                          Default Privileges                      --
--==================================================================--
{% for priv in pg_default_privileges %}
ALTER DEFAULT PRIVILEGES FOR ROLE {{ pg_dbsu }} {{ priv }};
{% endfor %}

{% for priv in pg_default_privileges %}
ALTER DEFAULT PRIVILEGES FOR ROLE {{ pg_admin_username }} {{ priv }};
{% endfor %}

-- for additional business admin, they can SET ROLE to dbrole_admin
{% for priv in pg_default_privileges %}
ALTER DEFAULT PRIVILEGES FOR ROLE "dbrole_admin" {{ priv }};
{% endfor %}

--==================================================================--
--                              Schemas                             --
--==================================================================--
{% for schema_name in pg_default_schemas %}
CREATE SCHEMA IF NOT EXISTS "{{ schema_name }}";
{% endfor %}

-- revoke public creation
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

--==================================================================--
--                             Extensions                           --
--==================================================================--
{% for extension in pg_default_extensions %}
CREATE EXTENSION IF NOT EXISTS "{{ extension.name }}"{% if 'schema' in extension %} WITH SCHEMA "{{ extension.schema }}"{% endif %};
{% endfor %}

-- always enable file_fdw and default server fs
CREATE EXTENSION IF NOT EXISTS file_fdw;
CREATE SERVER IF NOT EXISTS fs FOREIGN DATA WRAPPER file_fdw;


--==================================================================--
--                          Backup Privileges                       --
--==================================================================--
-- grant backup privileges to replication user
GRANT USAGE ON SCHEMA pg_catalog TO "{{ pg_replication_username }}";
GRANT EXECUTE ON FUNCTION pg_catalog.current_setting(text) TO "{{ pg_replication_username }}";
GRANT EXECUTE ON FUNCTION pg_catalog.set_config(text, text, boolean) TO "{{ pg_replication_username }}";
GRANT EXECUTE ON FUNCTION pg_catalog.pg_is_in_recovery() TO "{{ pg_replication_username }}";
GRANT EXECUTE ON FUNCTION pg_catalog.pg_start_backup(text, boolean, boolean) TO "{{ pg_replication_username }}";
GRANT EXECUTE ON FUNCTION pg_catalog.pg_stop_backup(boolean, boolean) TO "{{ pg_replication_username }}";
GRANT EXECUTE ON FUNCTION pg_catalog.pg_create_restore_point(text) TO "{{ pg_replication_username }}";
GRANT EXECUTE ON FUNCTION pg_catalog.pg_switch_wal() TO "{{ pg_replication_username }}";
GRANT EXECUTE ON FUNCTION pg_catalog.pg_last_wal_replay_lsn() TO "{{ pg_replication_username }}";
GRANT EXECUTE ON FUNCTION pg_catalog.txid_current() TO "{{ pg_replication_username }}";
GRANT EXECUTE ON FUNCTION pg_catalog.txid_current_snapshot() TO "{{ pg_replication_username }}";
GRANT EXECUTE ON FUNCTION pg_catalog.txid_snapshot_xmax(txid_snapshot) TO "{{ pg_replication_username }}";
GRANT EXECUTE ON FUNCTION pg_catalog.pg_control_checkpoint() TO "{{ pg_replication_username }}";



--==================================================================--
--                            Monitor Schema                        --
--==================================================================--

----------------------------------------------------------------------
-- cleanse
----------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS monitor;
GRANT USAGE ON SCHEMA monitor TO "{{ pg_monitor_username }}";
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


--==================================================================--
--                            Functions                             --
--==================================================================--

{% if pg_version >= 13 %}
----------------------------------------------------------------------
-- pg_shmem auxiliary function (PG13+ only)
----------------------------------------------------------------------
DROP FUNCTION IF EXISTS monitor.pg_shmem() CASCADE;
CREATE OR REPLACE FUNCTION monitor.pg_shmem() RETURNS SETOF
    pg_shmem_allocations AS $$ SELECT * FROM pg_shmem_allocations;$$ LANGUAGE SQL SECURITY DEFINER;
COMMENT ON FUNCTION monitor.pg_shmem() IS 'security wrapper for system view pg_shmem';
REVOKE ALL ON FUNCTION monitor.pg_shmem() FROM PUBLIC;
REVOKE ALL ON FUNCTION monitor.pg_shmem() FROM dbrole_readonly;
REVOKE ALL ON FUNCTION monitor.pg_shmem() FROM dbrole_offline;
GRANT EXECUTE ON FUNCTION monitor.pg_shmem() TO pg_monitor;
{% endif %}


----------------------------------------------------------------------
-- monitor.pgbouncer_auth for pgbouncer_auth_query
----------------------------------------------------------------------
{% if pgbouncer_enabled|bool %}
CREATE OR REPLACE FUNCTION monitor.pgbouncer_auth(p_username TEXT) RETURNS TABLE(username TEXT, password TEXT) AS
$$ BEGIN
    RAISE WARNING 'PgBouncer auth request: %', p_username;
    RETURN QUERY SELECT rolname::TEXT, rolpassword::TEXT FROM pg_authid WHERE NOT rolsuper AND rolname = p_username;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
REVOKE ALL ON FUNCTION monitor.pgbouncer_auth(p_username TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION monitor.pgbouncer_auth(p_username TEXT) FROM dbrole_readonly;
REVOKE ALL ON FUNCTION monitor.pgbouncer_auth(p_username TEXT) FROM dbrole_offline;
{% endif %}


--==================================================================--
--                         Foreign Tables                           --
--==================================================================--

----------------------------------------------------------------------
-- current log
----------------------------------------------------------------------
CREATE TYPE monitor.log_level AS ENUM (
    'LOG','INFO','NOTICE','WARNING','ERROR','FATAL','PANIC','DEBUG'
);
COMMENT ON TYPE monitor.log_level IS 'PostgreSQL Log Level';

-- current log
DROP FOREIGN TABLE monitor.pg_log;
CREATE FOREIGN TABLE monitor.pg_log
    (
        ts        TIMESTAMPTZ, -- ts
        username  TEXT,        -- user name
        datname   TEXT,        -- database name
        pid       INTEGER,     -- process_id
        conn      TEXT,        -- connect_from
        sid       TEXT,        -- session id
        sln       BIGINT,      -- session line number
        cmd_tag   TEXT,        -- command tag
        stime     TIMESTAMPTZ, -- session start time
        vxid      TEXT,        -- virtual transaction id
        txid      BIGINT,      -- transaction id
        level     monitor.log_level, -- log level
        code      VARCHAR(5),  -- sql state error code
        msg       TEXT,        -- message
        detail    TEXT,        -- detail
        hint      TEXT,        -- hint
        iq        TEXT,        -- internal query
        iqp       INTEGER,     -- internal query position
        context   TEXT,        -- context
        q         TEXT,        -- query
        qp        INTEGER,     -- query position
        location  TEXT,        -- location
        appname   TEXT         -- application name
{% if pg_version|int >= 13%}
        ,backend    TEXT      -- backend_type (PG13)
{% endif %}
{% if pg_version|int >= 14%}
        ,leader_pid INTEGER   -- parallel group leader pid, if this is worker
{% endif %}
{% if pg_version|int >= 14%}
        ,query_id   BIGINT    -- query id of the current query
{% endif %}

) SERVER fs OPTIONS (program $$cat $(cat /pg/data/current_logfiles | awk '{print $2}');$$, format 'csv');
COMMENT ON FOREIGN TABLE monitor.pg_log IS 'current log file foreign table';

REVOKE ALL ON monitor.pg_log FROM PUBLIC;
REVOKE ALL ON monitor.pg_log FROM dbrole_offline;
REVOKE ALL ON monitor.pg_log FROM dbrole_readonly;
REVOKE ALL ON monitor.pg_log FROM dbrole_readwrite;
REVOKE ALL ON monitor.pg_log FROM dbrole_admin;
GRANT SELECT ON monitor.pg_log TO pg_monitor;


----------------------------------------------------------------------
-- pgbackrest information
----------------------------------------------------------------------
DROP FOREIGN TABLE IF EXISTS monitor.pgbackrest_info CASCADE;
CREATE FOREIGN TABLE IF NOT EXISTS monitor.pgbackrest_info (data JSONB)
    SERVER fs OPTIONS (PROGRAM $$pgbackrest --output=json info$$ , FORMAT 'text');

REVOKE ALL ON monitor.pgbackrest_info FROM PUBLIC;
REVOKE ALL ON monitor.pgbackrest_info FROM dbrole_offline;
REVOKE ALL ON monitor.pgbackrest_info FROM dbrole_readonly;
REVOKE ALL ON monitor.pgbackrest_info FROM dbrole_readwrite;
GRANT SELECT ON monitor.pgbackrest_info TO pg_monitor;

DROP VIEW IF EXISTS monitor.pgbackrest;
CREATE OR REPLACE VIEW monitor.pgbackrest AS
SELECT name,
       value ->> 'type'                                          AS bk_type,
       (value ->> 'error')::BOOLEAN                              AS bk_error,
       current_archive ->> 'min'                                 as wal_min,
       current_archive ->> 'max'                                 as wal_max,
       value ->> 'label'                                         AS bk_label,
       value ->> 'prior'                                         AS bk_prior,
       (value -> 'timestamp' ->> 'start')::NUMERIC               AS bk_start_ts,
       (value -> 'timestamp' ->> 'stop')::NUMERIC                AS bk_stop_ts,
       to_timestamp((value -> 'timestamp' ->> 'start')::NUMERIC) AS bk_start_at,
       to_timestamp((value -> 'timestamp' ->> 'stop')::NUMERIC)  AS bk_stop_at,
       value -> 'lsn' ->> 'start'                                AS bk_start_lsn,
       value -> 'lsn' ->> 'stop'                                 AS bk_stop_lsn,
       (value -> 'info' ->> 'size')::BIGINT                      AS bk_size,
       (value -> 'info' ->> 'delta')::BIGINT                     AS bk_delta,
       (value -> 'info' -> 'repo' ->> 'size')::BIGINT            AS bk_repo_size,
       (value -> 'info' -> 'repo' ->> 'delta')::BIGINT           AS bk_repo_delta,
       value -> 'reference'                                      AS bk_reference,
       value -> 'annotation'                                     AS bk_annotation
FROM (SELECT value ->> 'name'   AS name,
             value -> 'backup'  AS backups,
             value -> 'archive' -> (jsonb_array_length(value -> 'archive') - 1) AS current_archive
      FROM monitor.pgbackrest_info i, jsonb_array_elements(i.data)) z, jsonb_array_elements(z.backups);

REVOKE ALL ON monitor.pgbackrest FROM PUBLIC;
REVOKE ALL ON monitor.pgbackrest FROM dbrole_offline;
REVOKE ALL ON monitor.pgbackrest FROM dbrole_readonly;
REVOKE ALL ON monitor.pgbackrest FROM dbrole_readwrite;
REVOKE ALL ON monitor.pgbackrest FROM dbrole_admin;
GRANT SELECT ON monitor.pgbackrest TO pg_monitor;


----------------------------------------------------------------------
-- patroni information
----------------------------------------------------------------------
DROP FOREIGN TABLE IF EXISTS monitor.patroni_info CASCADE;
CREATE FOREIGN TABLE IF NOT EXISTS monitor.patroni_info (data JSONB)
    SERVER fs OPTIONS (PROGRAM $$curl http{% if patroni_ssl_enabled|bool %}s{% endif %}://127.0.0.1:{{ patroni_port }}/cluster$$ , FORMAT 'text');

REVOKE ALL ON monitor.patroni_info FROM PUBLIC;
REVOKE ALL ON monitor.patroni_info FROM dbrole_offline;
REVOKE ALL ON monitor.patroni_info FROM dbrole_readonly;
REVOKE ALL ON monitor.patroni_info FROM dbrole_readwrite;
GRANT SELECT ON monitor.patroni_info TO pg_monitor;

DROP FOREIGN TABLE IF EXISTS monitor.patroni_conf CASCADE;
CREATE FOREIGN TABLE IF NOT EXISTS monitor.patroni_conf (data JSONB)
    SERVER fs OPTIONS (PROGRAM $$cat patroni.dynamic.json$$ , FORMAT 'text');

REVOKE ALL ON monitor.patroni_conf FROM PUBLIC;
REVOKE ALL ON monitor.patroni_conf FROM dbrole_offline;
REVOKE ALL ON monitor.patroni_conf FROM dbrole_readonly;
REVOKE ALL ON monitor.patroni_conf FROM dbrole_readwrite;
GRANT SELECT ON monitor.patroni_conf TO pg_monitor;

DROP VIEW IF EXISTS monitor.patroni;
CREATE OR REPLACE VIEW monitor.patroni AS
SELECT value ->> 'name'                                                             AS name,
       CASE value ->> 'role' WHEN 'leader' THEN 'primary' ELSE value ->> 'role' END AS role,
       value ->> 'host'                                                             AS host,
       value ->> 'port'                                                             AS port,
       value ->> 'state'                                                            AS state,
       (value ->> 'timeline')::INTEGER                                              AS timeline,
       (value ->> 'lag')::BIGINT                                                    AS lag,
       value ->> 'api_url'                                                          AS url,
       value -> 'tags' ->> 'replicatefrom'                                          AS replicatefrom,
       coalesce((value -> 'tags' -> 'nofailover') ::BOOLEAN, false)::BOOLEAN        AS nofailover,
       coalesce((value -> 'tags' -> 'clonefrom') ::BOOLEAN, false)::BOOLEAN         AS clonefrom,
       coalesce((value -> 'tags' -> 'noloadbalance') ::BOOLEAN, false)::BOOLEAN     AS noloadbalance,
       coalesce((value -> 'tags' -> 'nosync') ::BOOLEAN, false)::BOOLEAN            AS nosync,
       value -> 'tags'                                                              AS tags
FROM monitor.patroni_info i, jsonb_array_elements(data -> 'members');

REVOKE ALL ON monitor.patroni FROM PUBLIC;
REVOKE ALL ON monitor.patroni FROM dbrole_offline;
REVOKE ALL ON monitor.patroni FROM dbrole_readonly;
REVOKE ALL ON monitor.patroni FROM dbrole_readwrite;
GRANT SELECT ON monitor.patroni TO pg_monitor;



--==================================================================--
--                          Customize Logic                         --
--==================================================================--
-- This script will be execute on primary instance among a newly created
-- postgres cluster. it will be executed as dbsu on template1 database
-- put your own customize logic here
-- make sure they are idempotent