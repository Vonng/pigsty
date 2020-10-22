#!/bin/bash
set -euo pipefail
#==============================================================#
# File      :   initdb.sh
# Mtime     :   2020-09-02
# Desc      :   initdb.sh
# Path      :   /pg/bin/initdb.sh
# Depend    :   CentOS 7
# Author    :   Vonng(fengruohang@outlook.com)
# Note      :   Run this as dbsu (postgres)
#==============================================================#
PROG_NAME="$(basename $0))"
PROG_DIR="$(cd $(dirname $0) && pwd)"


#---------------------------------------------------------------------------
function log() {
    printf "[$(date "+%Y-%m-%d %H:%M:%S")][$HOSTNAME][INITDB] $*\n" >> /pg/log/initdb.log
}
#---------------------------------------------------------------------------


#----------------------------------------------------------------------------
# template variables
#----------------------------------------------------------------------------
PG_DBSU='{{ pg_dbsu }}'
PG_REPLICATION_USERNAME='{{ pg_replication_username }}'
PG_REPLICATION_PASSWORD='{{ pg_replication_password }}'
PG_MONITOR_USERNAME='{{ pg_monitor_username }}'
PG_MONITOR_PASSWORD='{{ pg_monitor_password }}'
PG_DEFAULT_USERNAME='{{ pg_default_username }}'
PG_DEFAULT_PASSWORD='{{ pg_default_password }}'
PG_DEFAULT_DATABASE='{{ pg_default_database }}'
PG_DEFAULT_SCHEMA='{{ pg_default_schema }}'
PG_DEFAULT_EXTENSIONS='{{ pg_default_extensions }}'

#----------------------------------------------------------------------------
# system users
#----------------------------------------------------------------------------
log "initdb: create system users: ${PG_REPLICATION_USERNAME} , ${PG_MONITOR_USERNAME}"
psql -AXtwq postgres <<- EOF
	-- dbsu
	CREATE USER ${PG_DBSU};
	ALTER USER "${PG_DBSU}" SUPERUSER;
	COMMENT ON ROLE "${PG_REPLICATION_USERNAME}" IS 'system default sa';

	-- replication user (also used as rewind user)
	CREATE USER ${PG_REPLICATION_USERNAME};
	COMMENT ON ROLE "${PG_REPLICATION_USERNAME}" IS 'system user for replication';
	ALTER  USER  ${PG_REPLICATION_USERNAME} REPLICATION PASSWORD '${PG_REPLICATION_PASSWORD}';
	GRANT EXECUTE ON function pg_catalog.pg_ls_dir(text, boolean, boolean) TO "${PG_REPLICATION_USERNAME}";
	GRANT EXECUTE ON function pg_catalog.pg_stat_file(text, boolean) TO "${PG_REPLICATION_USERNAME}";
	GRANT EXECUTE ON function pg_catalog.pg_read_binary_file(text) TO "${PG_REPLICATION_USERNAME}";
	GRANT EXECUTE ON function pg_catalog.pg_read_binary_file(text, bigint, bigint, boolean) TO  "${PG_REPLICATION_USERNAME}";

	-- system user: dbuser_monitor
	CREATE USER "${PG_MONITOR_USERNAME}";
	COMMENT ON ROLE "${PG_MONITOR_USERNAME}" IS 'system user for monitor';
	ALTER USER "${PG_MONITOR_USERNAME}" LOGIN NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOREPLICATION;
	ALTER USER "${PG_MONITOR_USERNAME}" PASSWORD '${PG_MONITOR_PASSWORD}' CONNECTION LIMIT 8;
	ALTER USER "${PG_MONITOR_USERNAME}" SET search_path = public,monitor;
	GRANT pg_monitor TO "${PG_MONITOR_USERNAME}";
EOF


#----------------------------------------------------------------------------
# default roles
#----------------------------------------------------------------------------
log "initdb: create default roles: dbrole_admin, dbrole_readwrite, dbrole_readonly"
psql -AXtwq postgres <<- EOF
	-- default read-only role: personal account, analysis & etl purpose
	CREATE ROLE dbrole_readonly;        -- analysis , personal account, etc...
	COMMENT ON ROLE dbrole_readonly IS 'read-only role, for personal, analysis, etl purpose';
	ALTER ROLE dbrole_readonly NOLOGIN NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOREPLICATION NOBYPASSRLS;

	-- default read-write role: common production account
	CREATE ROLE dbrole_readwrite;       -- common read-write, production account
	ALTER ROLE dbrole_readwrite NOLOGIN NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOREPLICATION NOBYPASSRLS;
	COMMENT ON ROLE dbrole_readwrite IS 'read-write role, common production account';

	-- default admin role: create database,role,table, partition, index, etc...
	CREATE ROLE dbrole_admin;			-- admin role, create db, role, table, partition, index, etc...
	COMMENT ON ROLE dbrole_admin IS 'admin role, create db, role, table, partition, index, etc...';
	ALTER ROLE dbrole_admin NOLOGIN NOSUPERUSER INHERIT CREATEROLE CREATEDB NOREPLICATION BYPASSRLS;

	-- grant
	GRANT dbrole_readonly TO dbrole_readwrite;
	GRANT dbrole_readonly TO "${PG_MONITOR_USERNAME}"; -- since monitor user can only access from local or meta nodes
	GRANT dbrole_readwrite TO dbrole_admin;
EOF


#----------------------------------------------------------------------------
# default user (business account)
#----------------------------------------------------------------------------
if [ ${PG_DEFAULT_USERNAME} != 'postgres' ]; then
	log "initdb: create default business user: ${PG_DEFAULT_USERNAME}"
	psql -AXtwq postgres <<- EOF
		-- default user
		CREATE USER "${PG_DEFAULT_USERNAME}";
		COMMENT ON ROLE "${PG_DEFAULT_USERNAME}" IS 'default business user';
		ALTER USER "${PG_DEFAULT_USERNAME}" LOGIN NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOREPLICATION BYPASSRLS;
		ALTER USER "${PG_DEFAULT_USERNAME}" PASSWORD '${PG_DEFAULT_PASSWORD}';
		GRANT dbrole_readwrite TO "${PG_DEFAULT_USERNAME}";
	EOF
fi


#----------------------------------------------------------------------------
# create pgpass
#----------------------------------------------------------------------------
log "initdb: create pgpass file"
echo "" >> ~/.pgpass
function add_pgpass(){
	local username=$1
	local password=$2
	if grep -q "${username}": ~/.pgpass; then
		sed -i "/${username}/d" ~/.pgpass
	fi
	echo '*:*:*'"${username}:${password}" >> ~/.pgpass
	chmod 0600 ~/.pgpass
}
add_pgpass ${PG_REPLICATION_USERNAME} ${PG_REPLICATION_PASSWORD}
add_pgpass ${PG_MONITOR_USERNAME} ${PG_MONITOR_PASSWORD}
if [[ ${PG_DEFAULT_USERNAME} != 'postgres' ]]; then
	add_pgpass ${PG_DEFAULT_USERNAME} ${PG_DEFAULT_PASSWORD}
fi


#----------------------------------------------------------------------------
# default privilege
#----------------------------------------------------------------------------
log "initdb: alter default privilege: postgres template1"
for database in postgres template1
do
	psql -AXtwq ${database} <<- EOF
		ALTER DEFAULT PRIVILEGES FOR ROLE dbrole_admin GRANT USAGE ON SCHEMAS TO dbrole_readonly;
		ALTER DEFAULT PRIVILEGES FOR ROLE dbrole_admin GRANT SELECT ON TABLES TO dbrole_readonly;
		ALTER DEFAULT PRIVILEGES FOR ROLE dbrole_admin GRANT SELECT ON SEQUENCES TO dbrole_readonly;
		ALTER DEFAULT PRIVILEGES FOR ROLE dbrole_admin GRANT EXECUTE ON FUNCTIONS TO dbrole_readonly;
		ALTER DEFAULT PRIVILEGES FOR ROLE dbrole_admin GRANT INSERT, UPDATE, DELETE ON TABLES TO dbrole_readwrite;
		ALTER DEFAULT PRIVILEGES FOR ROLE dbrole_admin GRANT USAGE, UPDATE ON SEQUENCES TO dbrole_readwrite;
		ALTER DEFAULT PRIVILEGES FOR ROLE dbrole_admin GRANT TRUNCATE, REFERENCES, TRIGGER ON TABLES TO dbrole_admin;
		ALTER DEFAULT PRIVILEGES FOR ROLE dbrole_admin GRANT CREATE ON SCHEMAS TO dbrole_admin;
		ALTER DEFAULT PRIVILEGES FOR ROLE dbrole_admin GRANT USAGE ON TYPES TO dbrole_admin;

		ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT USAGE ON SCHEMAS TO dbrole_readonly;
		ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT SELECT ON TABLES TO dbrole_readonly;
		ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT SELECT ON SEQUENCES TO dbrole_readonly;
		ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT EXECUTE ON FUNCTIONS TO dbrole_readonly;
		ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT INSERT, UPDATE, DELETE ON TABLES TO dbrole_readwrite;
		ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT USAGE, UPDATE ON SEQUENCES TO dbrole_readwrite;
		ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT TRUNCATE, REFERENCES, TRIGGER ON TABLES TO dbrole_admin;
		ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT CREATE ON SCHEMAS TO dbrole_admin;
		ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT USAGE ON TYPES TO dbrole_admin;
	EOF
done


#----------------------------------------------------------------------------
# template database
#----------------------------------------------------------------------------
log "initdb: init database template: postgres, template1"
for database in postgres template1; do
	psql -AXtwq ${database} <<-EOF
		CREATE SCHEMA IF NOT EXISTS monitor;
		SET search_path = public, monitor;

		-- create stats extensions within monitor schema
		CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA monitor;
		CREATE EXTENSION IF NOT EXISTS pgstattuple WITH SCHEMA monitor;
		CREATE EXTENSION IF NOT EXISTS pg_qualstats WITH SCHEMA monitor;
		CREATE EXTENSION IF NOT EXISTS pg_buffercache WITH SCHEMA monitor;
		CREATE EXTENSION IF NOT EXISTS pageinspect WITH SCHEMA monitor;
		CREATE EXTENSION IF NOT EXISTS pg_prewarm WITH SCHEMA monitor;
		CREATE EXTENSION IF NOT EXISTS pg_visibility WITH SCHEMA monitor;
		CREATE EXTENSION IF NOT EXISTS pg_freespacemap WITH SCHEMA monitor;
		CREATE EXTENSION IF NOT EXISTS pg_repack WITH SCHEMA monitor;
		CREATE EXTENSION IF NOT EXISTS pg_stat_kcache WITH SCHEMA monitor;
		-- CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA monitor;

		-- Table bloat estimate
		CREATE OR REPLACE VIEW monitor.pg_table_bloat AS
		    SELECT CURRENT_CATALOG AS datname, nspname, relname , bs * tblpages AS size,
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


		-- Index bloat estimate
		CREATE OR REPLACE VIEW monitor.pg_index_bloat AS
		    SELECT CURRENT_CATALOG AS datname, nspname, idxname AS relname, relpages::BIGINT * bs AS size,
		           COALESCE((relpages - ( reltuples * (6 + ma - (CASE WHEN index_tuple_hdr % ma = 0 THEN ma ELSE index_tuple_hdr % ma END)
		                                                   + nulldatawidth + ma - (CASE WHEN nulldatawidth % ma = 0 THEN ma ELSE nulldatawidth % ma END))
		                                      / (bs - pagehdr)::FLOAT  + 1 )), 0) / relpages::FLOAT AS ratio
		    FROM (
		             SELECT nspname,
		                    idxname,
		                    reltuples,
		                    relpages,
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
		         ) est
		    LIMIT 512;


		-- index bloat overview
		CREATE OR REPLACE VIEW monitor.pg_table_bloat_human AS
		SELECT nspname || '.' || relname AS name,
		       pg_size_pretty(size)      AS size,
		       pg_size_pretty((size * ratio)::BIGINT) AS wasted,
		       round(100 * ratio::NUMERIC, 2)  as ratio
		FROM monitor.pg_table_bloat ORDER BY wasted DESC NULLS LAST;

		CREATE OR REPLACE VIEW monitor.pg_index_bloat_human AS
		SELECT nspname || '.' || relname              AS name,
		       pg_size_pretty(size)                   AS size,
		       pg_size_pretty((size * ratio)::BIGINT) AS wasted,
		       round(100 * ratio::NUMERIC, 2)         as ratio
		FROM monitor.pg_index_bloat;


		-- pg session
		DROP VIEW IF EXISTS monitor.pg_session;
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
		COMMENT ON VIEW monitor.pg_session IS 'postgres session stats';

		DROP VIEW IF EXISTS monitor.pg_kill;
		CREATE OR REPLACE VIEW monitor.pg_kill AS
		SELECT pid,
		       pg_terminate_backend(pid)                 AS killed,
		       datname                                   AS dat,
		       usename                                   AS usr,
		       application_name                          AS app,
		       client_addr                               AS addr,
		       state,
		       extract(epoch from now() - state_change)  AS query_time,
		       extract(epoch from now() - xact_start)    AS xact_time,
		       extract(epoch from now() - backend_start) AS conn_time,
		       substring(query, 1, 40)                   AS query
		FROM pg_stat_activity
		WHERE backend_type = 'client backend'
		  AND pid <> pg_backend_pid();
		COMMENT ON VIEW monitor.pg_kill IS 'kill all backend session';

		-- quick cancel view
		DROP VIEW IF EXISTS monitor.pg_cancel;
		CREATE OR REPLACE VIEW monitor.pg_cancel AS
		SELECT pid,
		       pg_cancel_backend(pid)                    AS cancel,
		       datname                                   AS dat,
		       usename                                   AS usr,
		       application_name                          AS app,
		       client_addr                               AS addr,
		       state,
		       extract(epoch from now() - state_change)  AS query_time,
		       extract(epoch from now() - xact_start)    AS xact_time,
		       extract(epoch from now() - backend_start) AS conn_time,
		       substring(query, 1, 40)
		FROM pg_stat_activity
		WHERE state = 'active'
		  AND backend_type = 'client backend'
		  and pid <> pg_backend_pid();
		COMMENT ON VIEW monitor.pg_cancel IS 'cancel backend queries';

		-- seq scan
		DROP VIEW IF EXISTS monitor.pg_seq_scan;
		CREATE OR REPLACE VIEW monitor.pg_seq_scan AS
		SELECT schemaname                             AS nspname,
		       relname,
		       seq_scan,
		       seq_tup_read,
		       seq_tup_read / seq_scan                AS seq_tup_avg,
		       idx_scan,
		       n_live_tup + n_dead_tup                AS tuples,
		       n_live_tup / (n_live_tup + n_dead_tup) AS dead_ratio
		FROM pg_stat_user_tables
		WHERE seq_scan > 0
		  and (n_live_tup + n_dead_tup) > 0
		ORDER BY seq_tup_read DESC
		LIMIT 50;
		COMMENT ON VIEW monitor.pg_seq_scan IS 'table that have seq scan';
	EOF

	psql -AXtwq ${database} <<-'EOF'
		CREATE OR REPLACE FUNCTION monitor.pg_shmem() RETURNS SETOF pg_shmem_allocations AS $$ SELECT * FROM pg_shmem_allocations;$$ LANGUAGE SQL SECURITY DEFINER;
	EOF

done


#----------------------------------------------------------------------------
# default database
#----------------------------------------------------------------------------
if [ ${PG_DEFAULT_DATABASE} != 'postgres' ]; then
	log "initdb: create default database: ${PG_DEFAULT_DATABASE}"
	psql -AXtwq postgres <<- EOF
		CREATE DATABASE "${PG_DEFAULT_DATABASE}";
	EOF

	if [ ${PG_DEFAULT_SCHEMA} != 'public' ]; then
		log "initdb: create default schema on ${PG_DEFAULT_DATABASE} : ${PG_DEFAULT_SCHEMA}"
		psql -AXtwq ${PG_DEFAULT_DATABASE} <<- EOF
			CREATE SCHEMA IF NOT EXISTS ${PG_DEFAULT_SCHEMA};
			ALTER USER "${PG_DBSU}" SET search_path = ${PG_DEFAULT_SCHEMA},public,monitor;
		EOF
	fi

	if [ ${PG_DEFAULT_EXTENSIONS} != '' ]; then
		log "initdb: create default extensions on ${PG_DEFAULT_DATABASE} : ${PG_DEFAULT_EXTENSIONS}"
		for ext in ${PG_DEFAULT_EXTENSIONS//,/ }
		do
			log "initdb: create extension ${ext};"
			psql -AXtwq ${PG_DEFAULT_DATABASE} <<- EOF
				CREATE EXTENSION IF NOT EXISTS ${ext} WITH SCHEMA public;
			EOF
		done
	fi
fi


#----------------------------------------------------------------------------
# customize commands
#----------------------------------------------------------------------------
log "initdb: completed!"
