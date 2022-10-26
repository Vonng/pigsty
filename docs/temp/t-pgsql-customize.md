# Customization of Postgres Template

## Parameters

The template database `template1` in a cluster can be customized using the [PG template](v-pgsql.md#PG_PROVISION) configuration item.

This ensures that any database **newly created** in this database cluster comes with the same default configuration: schema, extensions, and default permissions.

| name | type | hierarchy | description |
| :----------------------------------------------------------: | :-----------: | :---: | ------------------------- |
| [pg_init](v-pgsql#pg_init) | `string` | G/C | Custom PG initialization scripts |
| [pg_replication_username](v-pgsql#pg_replication_username) | `string` | G | PG replication user |
| [pg_replication_password](v-pgsql#pg_replication_password) | `string` | G | PG replication user's password |
| [pg_monitor_username](v-pgsql#pg_monitor_username) | `string` | G | PG monitor user |
| [pg_monitor_password](v-pgsql#pg_monitor_password) | `string` | G | PG monitor user password |
| [pg_admin_username](v-pgsql#pg_admin_username) | `string` | G | PG Admin User |
| [pg_admin_password](v-pgsql#pg_admin_password) | `string` | G | PG admin user password |
| [pg_default_roles](v-pgsql#pg_default_roles) | `role[]` | G | Default created roles and users |
| [pg_default_privilegs](v-pgsql#pg_default_privilegs) | `string[]` | G | Database default permissions configuration |
| [pg_default_schemas](v-pgsql#pg_default_schemas) | `string[]` | G | The schema created by default |
| [pg_default_extensions](v-pgsql#pg_default_extensions) | `extension[]` | G | Default installed extensions |
| [pg_offline_query](v-pgsql#pg_offline_query) | `bool` | **I** | Whether to allow **offline** queries |
| [pg_reload](v-pgsql#pg_reload) | `bool` | **A** | Whether to reload database configuration (HBA) |
| [pg_hba_rules](v-pgsql#pg_hba_rules) | `rule[]` | G | Global HBA rules |
| [pg_hba_rules_extra](v-pgsql#pg_hba_rules_extra) | `rule[]` | C/I | Cluster/instance specific HBA rules |
| [pgbouncer_hba_rules](v-pgsql#pgbouncer_hba_rules) | `rule[]` | G/C | Pgbouncer global HBA rules |
| [pgbouncer_hba_rules_extra](v-pgsql#pgbouncer_hba_rules_extra) | `rule[]` | G/C | Pgbounce specific HBA rules |
| [pg_databases](v-pgsql#pg_databases) | `database[]` | G/C | **business database definitions** |
| [pg_users](v-pgsql#pg_users) | `user[]` | G/C | **business user definitions** |



## Related files

When customizing the database template, the relevant parameters are first rendered as SQL scripts and then executed on the deployed database cluster.


```ini
^---/pg/bin/pg-init
          |
          ^---(1)--- /pg/tmp/pg-init-roles.sql
          ^---(2)--- /pg/tmp/pg-init-template.sql
          ^---(3)--- <other customize logic in pg-init>

# user & database are not created during templating
^-------------(4)--- /pg/tmp/pg-user-{{ user.name }}.sql
^-------------(5)--- /pg/tmp/pg-db-{{ db.name }}.sql
```

## [pg-init](v-pgsql#pg_init)

[`pg-init`](v-pgsql#pg_init) is the path to a Shell script for customizing the initialization template that will be executed as a postgres user, **only on the master**, when the database cluster master has been pulled up for execution, and can execute any Shell command, or execute any via psql SQL commands.

If this configuration item is not specified, Pigsty will use the default [`pg-init`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/pg-init) Shell script as shown below.

```shell
#!/usr/bin/env bash
set -uo pipefail


#==================================================================#
#                          Default Roles                           #
#==================================================================#
psql postgres -qAXwtf /pg/tmp/pg-init-roles.sql


#==================================================================#
#                          System Template                         #
#==================================================================#
# system default template
psql template1 -qAXwtf /pg/tmp/pg-init-template.sql

# make postgres same as templated database (optional)
psql postgres  -qAXwtf /pg/tmp/pg-init-template.sql



#==================================================================#
#                          Customize Logic                         #
#==================================================================#
# add your template logic here
```

This script can be appended to if the user needs to perform complex customization logic. Note `pg-init` is used to customize **database clusters**, which is usually achieved by modifying **template databases**. At the time this script is executed, the database cluster has been started, but the business users and business databases have not yet been created. Therefore the changes to the template database are reflected in the business database defined by default.



## `pg-init-roles.sql`

In [`pg_default_roles`](v-pgsql#pg_default_roles) you can customize the **global unified** role system. The definitions therein are rendered as `/pg/tmp/pg-init-roles.sql`, and a sample rendering in the `pg-meta` cluster is shown below.

```sql
----------------------------------------------------------------------
-- File      :   pg-init-roles.sql
-- Path      :   /pg/tmp/pg-init-roles
-- Time      :   2021-07-26 18:17
-- Note      :   managed by ansible, DO NOT CHANGE
-- Desc      :   creation sql script for default roles
----------------------------------------------------------------------


--###################################################################--
--                         dbrole_readonly                           --
--###################################################################--
-- run as dbsu (postgres by default)
-- createuser -w -p 5432 --no-login'dbrole_readonly';
-- psql -p 5432 -AXtwqf /pg/tmp/pg-user-dbrole_readonly.sql

--==================================================================--
--                           CREATE USER                            --
--==================================================================--
CREATE USER "dbrole_readonly"  NOLOGIN;

--==================================================================--
--                           ALTER USER                             --
--==================================================================--
-- options
ALTER USER "dbrole_readonly"  NOLOGIN;

-- password

-- expire

-- conn limit

-- parameters

-- comment
COMMENT ON ROLE "dbrole_readonly" IS 'role for global read-only access';


--==================================================================--
--                           GRANT ROLE                             --
--==================================================================--


--==================================================================--
--                          PGBOUNCER USER                          --
--==================================================================--
-- user will not be added to pgbouncer user list by default,
-- unless pgbouncer is explicitly set to 'true', which means production user

-- User 'dbrole_readonly' will NOT be added to /etc/pgbouncer/userlist.txt

--==================================================================--




--###################################################################--
--                         dbrole_readwrite                           --
--###################################################################--
-- run as dbsu (postgres by default)
-- createuser -w -p 5432 --no-login'dbrole_readwrite';
-- psql -p 5432 -AXtwqf /pg/tmp/pg-user-dbrole_readwrite.sql

--==================================================================--
--                           CREATE USER                            --
--==================================================================--
CREATE USER "dbrole_readwrite"  NOLOGIN;

--==================================================================--
--                           ALTER USER                             --
--==================================================================--
-- options
ALTER USER "dbrole_readwrite"  NOLOGIN;

-- password

-- expire

-- conn limit

-- parameters

-- comment
COMMENT ON ROLE "dbrole_readwrite" IS 'role for global read-write access';


--==================================================================--
--                           GRANT ROLE                             --
--==================================================================--
GRANT "dbrole_readonly" TO "dbrole_readwrite";


--==================================================================--
--                          PGBOUNCER USER                          --
--==================================================================--
-- user will not be added to pgbouncer user list by default,
-- unless pgbouncer is explicitly set to 'true', which means production user

-- User 'dbrole_readwrite' will NOT be added to /etc/pgbouncer/userlist.txt

--==================================================================--




--###################################################################--
--                         dbrole_offline                           --
--###################################################################--
-- run as dbsu (postgres by default)
-- createuser -w -p 5432 --no-login'dbrole_offline';
-- psql -p 5432 -AXtwqf /pg/tmp/pg-user-dbrole_offline.sql

--==================================================================--
--                           CREATE USER                            --
--==================================================================--
CREATE USER "dbrole_offline"  NOLOGIN;

--==================================================================--
--                           ALTER USER                             --
--==================================================================--
-- options
ALTER USER "dbrole_offline"  NOLOGIN;

-- password

-- expire

-- conn limit

-- parameters

-- comment
COMMENT ON ROLE "dbrole_offline" IS 'role for restricted read-only access (offline instance)';


--==================================================================--
--                           GRANT ROLE                             --
--==================================================================--


--==================================================================--
--                          PGBOUNCER USER                          --
--==================================================================--
-- user will not be added to pgbouncer user list by default,
-- unless pgbouncer is explicitly set to 'true', which means production user

-- User 'dbrole_offline' will NOT be added to /etc/pgbouncer/userlist.txt

--==================================================================--




--###################################################################--
--                         dbrole_admin                           --
--###################################################################--
-- run as dbsu (postgres by default)
-- createuser -w -p 5432 --no-login'dbrole_admin';
-- psql -p 5432 -AXtwqf /pg/tmp/pg-user-dbrole_admin.sql

--==================================================================--
--                           CREATE USER                            --
--==================================================================--
CREATE USER "dbrole_admin"  NOLOGIN;

--==================================================================--
--                           ALTER USER                             --
--==================================================================--
-- options
ALTER USER "dbrole_admin"  NOLOGIN;

-- password

-- expire

-- conn limit

-- parameters

-- comment
COMMENT ON ROLE "dbrole_admin" IS 'role for object creation';


--==================================================================--
--                           GRANT ROLE                             --
--==================================================================--
GRANT "pg_monitor" TO "dbrole_admin";
GRANT "dbrole_readwrite" TO "dbrole_admin";


--==================================================================--
--                          PGBOUNCER USER                          --
--==================================================================--
-- user will not be added to pgbouncer user list by default,
-- unless pgbouncer is explicitly set to 'true', which means production user

-- User 'dbrole_admin' will NOT be added to /etc/pgbouncer/userlist.txt

--==================================================================--




--###################################################################--
--                         postgres                           --
--###################################################################--
-- run as dbsu (postgres by default)
-- createuser -w -p 5432  --superuser'postgres';
-- psql -p 5432 -AXtwqf /pg/tmp/pg-user-postgres.sql

--==================================================================--
--                           CREATE USER                            --
--==================================================================--
CREATE USER "postgres"  SUPERUSER;

--==================================================================--
--                           ALTER USER                             --
--==================================================================--
-- options
ALTER USER "postgres"  SUPERUSER;

-- password

-- expire

-- conn limit

-- parameters

-- comment
COMMENT ON ROLE "postgres" IS 'system superuser';


--==================================================================--
--                           GRANT ROLE                             --
--==================================================================--


--==================================================================--
--                          PGBOUNCER USER                          --
--==================================================================--
-- user will not be added to pgbouncer user list by default,
-- unless pgbouncer is explicitly set to 'true', which means production user

-- User 'postgres' will NOT be added to /etc/pgbouncer/userlist.txt

--==================================================================--




--###################################################################--
--                         dbuser_dba                           --
--###################################################################--
-- run as dbsu (postgres by default)
-- createuser -w -p 5432  --superuser'dbuser_dba';
-- psql -p 5432 -AXtwqf /pg/tmp/pg-user-dbuser_dba.sql

--==================================================================--
--                           CREATE USER                            --
--==================================================================--
CREATE USER "dbuser_dba"  SUPERUSER;

--==================================================================--
--                           ALTER USER                             --
--==================================================================--
-- options
ALTER USER "dbuser_dba"  SUPERUSER;

-- password

-- expire

-- conn limit

-- parameters

-- comment
COMMENT ON ROLE "dbuser_dba" IS 'system admin user';


--==================================================================--
--                           GRANT ROLE                             --
--==================================================================--
GRANT "dbrole_admin" TO "dbuser_dba";


--==================================================================--
--                          PGBOUNCER USER                          --
--==================================================================--
-- user will not be added to pgbouncer user list by default,
-- unless pgbouncer is explicitly set to 'true', which means production user

-- User 'dbuser_dba' will NOT be added to /etc/pgbouncer/userlist.txt

--==================================================================--




--###################################################################--
--                         replicator                           --
--###################################################################--
-- run as dbsu (postgres by default)
-- createuser -w -p 5432  --replication'replicator';
-- psql -p 5432 -AXtwqf /pg/tmp/pg-user-replicator.sql

--==================================================================--
--                           CREATE USER                            --
--==================================================================--
CREATE USER "replicator"  REPLICATION BYPASSRLS;

--==================================================================--
--                           ALTER USER                             --
--==================================================================--
-- options
ALTER USER "replicator"  REPLICATION BYPASSRLS;

-- password

-- expire

-- conn limit

-- parameters

-- comment
COMMENT ON ROLE "replicator" IS 'system replicator';


--==================================================================--
--                           GRANT ROLE                             --
--==================================================================--
GRANT "pg_monitor" TO "replicator";
GRANT "dbrole_readonly" TO "replicator";


--==================================================================--
--                          PGBOUNCER USER                          --
--==================================================================--
-- user will not be added to pgbouncer user list by default,
-- unless pgbouncer is explicitly set to 'true', which means production user

-- User 'replicator' will NOT be added to /etc/pgbouncer/userlist.txt

--==================================================================--




--###################################################################--
--                         dbuser_monitor                           --
--###################################################################--
-- run as dbsu (postgres by default)
-- createuser -w -p 5432 'dbuser_monitor';
-- psql -p 5432 -AXtwqf /pg/tmp/pg-user-dbuser_monitor.sql

--==================================================================--
--                           CREATE USER                            --
--==================================================================--
CREATE USER "dbuser_monitor" ;

--==================================================================--
--                           ALTER USER                             --
--==================================================================--
-- options
ALTER USER "dbuser_monitor" ;

-- password

-- expire

-- conn limit

-- parameters
ALTER USER "dbuser_monitor" SET log_min_duration_statement = 1000;

-- comment
COMMENT ON ROLE "dbuser_monitor" IS 'system monitor user';


--==================================================================--
--                           GRANT ROLE                             --
--==================================================================--
GRANT "pg_monitor" TO "dbuser_monitor";
GRANT "dbrole_readonly" TO "dbuser_monitor";


--==================================================================--
--                          PGBOUNCER USER                          --
--==================================================================--
-- user will not be added to pgbouncer user list by default,
-- unless pgbouncer is explicitly set to 'true', which means production user

-- User 'dbuser_monitor' will NOT be added to /etc/pgbouncer/userlist.txt

--==================================================================--




--###################################################################--
--                         dbuser_stats                           --
--###################################################################--
-- run as dbsu (postgres by default)
-- createuser -w -p 5432 'dbuser_stats';
-- psql -p 5432 -AXtwqf /pg/tmp/pg-user-dbuser_stats.sql

--==================================================================--
--                           CREATE USER                            --
--==================================================================--
CREATE USER "dbuser_stats" ;

--==================================================================--
--                           ALTER USER                             --
--==================================================================--
-- options
ALTER USER "dbuser_stats" ;

-- password
ALTER USER "dbuser_stats" PASSWORD 'DBUser.Stats';

-- expire

-- conn limit

-- parameters

-- comment
COMMENT ON ROLE "dbuser_stats" IS 'business offline user for offline queries and ETL';


--==================================================================--
--                           GRANT ROLE                             --
--==================================================================--
GRANT "dbrole_offline" TO "dbuser_stats";


--==================================================================--
--                          PGBOUNCER USER                          --
--==================================================================--
-- user will not be added to pgbouncer user list by default,
-- unless pgbouncer is explicitly set to 'true', which means production user

-- User 'dbuser_stats' will NOT be added to /etc/pgbouncer/userlist.txt

--==================================================================--






--==================================================================--
--                       PASSWORD OVERWRITE                         --
--==================================================================--
ALTER ROLE "replicator" PASSWORD 'DBUser.Replicator';
ALTER ROLE "dbuser_monitor" PASSWORD 'DBUser.Monitor';
ALTER ROLE "dbuser_dba" PASSWORD 'DBUser.DBA';
--==================================================================--
```





## `pg-init-template.sql`

PG模板参数大多会通过`pg-init-template.sql`的方式渲染，`pg-meta`集群中的渲染样例如下所示：

```sql
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
ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT USAGE                         ON SCHEMAS   TO dbrole_readonly;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT SELECT                        ON TABLES    TO dbrole_readonly;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT SELECT                        ON SEQUENCES TO dbrole_readonly;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT EXECUTE                       ON FUNCTIONS TO dbrole_readonly;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT USAGE                         ON SCHEMAS   TO dbrole_offline;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT SELECT                        ON TABLES    TO dbrole_offline;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT SELECT                        ON SEQUENCES TO dbrole_offline;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT EXECUTE                       ON FUNCTIONS TO dbrole_offline;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT INSERT, UPDATE, DELETE        ON TABLES    TO dbrole_readwrite;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT USAGE, UPDATE                 ON SEQUENCES TO dbrole_readwrite;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT TRUNCATE, REFERENCES, TRIGGER ON TABLES    TO dbrole_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT CREATE                        ON SCHEMAS   TO dbrole_admin;

ALTER DEFAULT PRIVILEGES FOR ROLE dbuser_dba GRANT USAGE                         ON SCHEMAS   TO dbrole_readonly;
ALTER DEFAULT PRIVILEGES FOR ROLE dbuser_dba GRANT SELECT                        ON TABLES    TO dbrole_readonly;
ALTER DEFAULT PRIVILEGES FOR ROLE dbuser_dba GRANT SELECT                        ON SEQUENCES TO dbrole_readonly;
ALTER DEFAULT PRIVILEGES FOR ROLE dbuser_dba GRANT EXECUTE                       ON FUNCTIONS TO dbrole_readonly;
ALTER DEFAULT PRIVILEGES FOR ROLE dbuser_dba GRANT USAGE                         ON SCHEMAS   TO dbrole_offline;
ALTER DEFAULT PRIVILEGES FOR ROLE dbuser_dba GRANT SELECT                        ON TABLES    TO dbrole_offline;
ALTER DEFAULT PRIVILEGES FOR ROLE dbuser_dba GRANT SELECT                        ON SEQUENCES TO dbrole_offline;
ALTER DEFAULT PRIVILEGES FOR ROLE dbuser_dba GRANT EXECUTE                       ON FUNCTIONS TO dbrole_offline;
ALTER DEFAULT PRIVILEGES FOR ROLE dbuser_dba GRANT INSERT, UPDATE, DELETE        ON TABLES    TO dbrole_readwrite;
ALTER DEFAULT PRIVILEGES FOR ROLE dbuser_dba GRANT USAGE, UPDATE                 ON SEQUENCES TO dbrole_readwrite;
ALTER DEFAULT PRIVILEGES FOR ROLE dbuser_dba GRANT TRUNCATE, REFERENCES, TRIGGER ON TABLES    TO dbrole_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE dbuser_dba GRANT CREATE                        ON SCHEMAS   TO dbrole_admin;

-- for additional business admin, they can SET ROLE to dbrole_admin
ALTER DEFAULT PRIVILEGES FOR ROLE "dbrole_admin" GRANT USAGE                         ON SCHEMAS   TO dbrole_readonly;
ALTER DEFAULT PRIVILEGES FOR ROLE "dbrole_admin" GRANT SELECT                        ON TABLES    TO dbrole_readonly;
ALTER DEFAULT PRIVILEGES FOR ROLE "dbrole_admin" GRANT SELECT                        ON SEQUENCES TO dbrole_readonly;
ALTER DEFAULT PRIVILEGES FOR ROLE "dbrole_admin" GRANT EXECUTE                       ON FUNCTIONS TO dbrole_readonly;
ALTER DEFAULT PRIVILEGES FOR ROLE "dbrole_admin" GRANT USAGE                         ON SCHEMAS   TO dbrole_offline;
ALTER DEFAULT PRIVILEGES FOR ROLE "dbrole_admin" GRANT SELECT                        ON TABLES    TO dbrole_offline;
ALTER DEFAULT PRIVILEGES FOR ROLE "dbrole_admin" GRANT SELECT                        ON SEQUENCES TO dbrole_offline;
ALTER DEFAULT PRIVILEGES FOR ROLE "dbrole_admin" GRANT EXECUTE                       ON FUNCTIONS TO dbrole_offline;
ALTER DEFAULT PRIVILEGES FOR ROLE "dbrole_admin" GRANT INSERT, UPDATE, DELETE        ON TABLES    TO dbrole_readwrite;
ALTER DEFAULT PRIVILEGES FOR ROLE "dbrole_admin" GRANT USAGE, UPDATE                 ON SEQUENCES TO dbrole_readwrite;
ALTER DEFAULT PRIVILEGES FOR ROLE "dbrole_admin" GRANT TRUNCATE, REFERENCES, TRIGGER ON TABLES    TO dbrole_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE "dbrole_admin" GRANT CREATE                        ON SCHEMAS   TO dbrole_admin;

--==================================================================--
--                              Schemas                             --
--==================================================================--
CREATE SCHEMA IF NOT EXISTS "monitor";

-- revoke public creation
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

--==================================================================--
--                             Extensions                           --
--==================================================================--
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "monitor";
CREATE EXTENSION IF NOT EXISTS "pgstattuple" WITH SCHEMA "monitor";
CREATE EXTENSION IF NOT EXISTS "pg_qualstats" WITH SCHEMA "monitor";
CREATE EXTENSION IF NOT EXISTS "pg_buffercache" WITH SCHEMA "monitor";
CREATE EXTENSION IF NOT EXISTS "pageinspect" WITH SCHEMA "monitor";
CREATE EXTENSION IF NOT EXISTS "pg_prewarm" WITH SCHEMA "monitor";
CREATE EXTENSION IF NOT EXISTS "pg_visibility" WITH SCHEMA "monitor";
CREATE EXTENSION IF NOT EXISTS "pg_freespacemap" WITH SCHEMA "monitor";
CREATE EXTENSION IF NOT EXISTS "pg_repack" WITH SCHEMA "monitor";
CREATE EXTENSION IF NOT EXISTS "postgres_fdw";
CREATE EXTENSION IF NOT EXISTS "file_fdw";
CREATE EXTENSION IF NOT EXISTS "btree_gist";
CREATE EXTENSION IF NOT EXISTS "btree_gin";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "intagg";
CREATE EXTENSION IF NOT EXISTS "intarray";



--==================================================================--
--                            Monitor Views                         --
--==================================================================--

----------------------------------------------------------------------
-- cleanse
----------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS monitor;
GRANT USAGE ON SCHEMA monitor TO "dbuser_monitor";
GRANT USAGE ON SCHEMA monitor TO "dbuser_dba";
GRANT USAGE ON SCHEMA monitor TO "replicator";

DROP VIEW IF EXISTS monitor.pg_table_bloat_human;
DROP VIEW IF EXISTS monitor.pg_index_bloat_human;
DROP VIEW IF EXISTS monitor.pg_table_bloat;
DROP VIEW IF EXISTS monitor.pg_index_bloat;
DROP VIEW IF EXISTS monitor.pg_session;
DROP VIEW IF EXISTS monitor.pg_kill;
DROP VIEW IF EXISTS monitor.pg_cancel;
DROP VIEW IF EXISTS monitor.pg_seq_scan;


----------------------------------------------------------------------
-- Table bloat estimate
----------------------------------------------------------------------
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
COMMENT ON VIEW monitor.pg_table_bloat IS 'postgres table bloat estimate';

----------------------------------------------------------------------
-- Index bloat estimate
----------------------------------------------------------------------
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
COMMENT ON VIEW monitor.pg_index_bloat IS 'postgres index bloat estimate (btree-only)';

----------------------------------------------------------------------
-- table bloat pretty
----------------------------------------------------------------------
CREATE OR REPLACE VIEW monitor.pg_table_bloat_human AS
SELECT nspname || '.' || relname AS name,
       pg_size_pretty(size)      AS size,
       pg_size_pretty((size * ratio)::BIGINT) AS wasted,
       round(100 * ratio::NUMERIC, 2)  as ratio
FROM monitor.pg_table_bloat ORDER BY wasted DESC NULLS LAST;
COMMENT ON VIEW monitor.pg_table_bloat_human IS 'postgres table bloat pretty';

----------------------------------------------------------------------
-- index bloat pretty
----------------------------------------------------------------------
CREATE OR REPLACE VIEW monitor.pg_index_bloat_human AS
SELECT nspname || '.' || relname              AS name,
       pg_size_pretty(size)                   AS size,
       pg_size_pretty((size * ratio)::BIGINT) AS wasted,
       round(100 * ratio::NUMERIC, 2)         as ratio
FROM monitor.pg_index_bloat;
COMMENT ON VIEW monitor.pg_index_bloat_human IS 'postgres index bloat pretty';


----------------------------------------------------------------------
-- pg session
----------------------------------------------------------------------
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


----------------------------------------------------------------------
-- pg kill
----------------------------------------------------------------------
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


----------------------------------------------------------------------
-- quick cancel view
----------------------------------------------------------------------
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


----------------------------------------------------------------------
-- seq scan
----------------------------------------------------------------------
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


----------------------------------------------------------------------
-- pg_shmem auxiliary function
-- PG 13 ONLY!
----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION monitor.pg_shmem() RETURNS SETOF
    pg_shmem_allocations AS $$ SELECT * FROM pg_shmem_allocations;$$ LANGUAGE SQL SECURITY DEFINER;
COMMENT ON FUNCTION monitor.pg_shmem() IS 'security wrapper for pg_shmem';


--==================================================================--
--                          Customize Logic                         --
--==================================================================--
-- This script will be execute on primary instance among a newly created
-- postgres cluster. it will be executed as dbsu on template1 database
-- put your own customize logic here
-- make sure they are idempotent
```




# Custom Patroni templates

Pigsty uses Patroni to manage and initialize Postgres database clusters.

Pigsty uses Patroni for the main work of provisioning, even if the user selects [no Patroni mode](v-pgsql.md#patroni_mode), pulling up the database cluster will be taken care of by Patroni and removing the Patroni component after the creation is complete.

Users can do most of the PostgreSQL cluster customization through Patroni configuration files. For details of Patroni configuration file format, please refer to [**Patroni official documentation**](https://patroni.readthedocs.io/en/latest/SETTINGS. html).

## Predefined templates

Pigsty provides four predefined initialization templates, the initialization templates are the definition files used to initialize the database cluster and are located by default in [`roles/postgres/templates/`](https://github.com/Vonng/pigsty/tree/master/roles/ postgres/templates). Included are.

- [`oltp.yml`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/oltp.yml) OLTP template, default configuration, optimized for latency and performance for production models.
- [`olap.yml`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/olap.yml) OLAP template, improve parallelism, optimize for throughput, long queries.
- [`crit.yml`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/crit.yml)) Core business template, based on OLTP template optimized for RPO, security, data integrity, enable synchronous replication with data checksum.
- [`tiny.yml`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/tiny.yml) Micro database template optimized for low-resource scenarios, such as demo database clusters running in virtual machines.

Specify the path to the template to be used via the [`pg_conf`](v-pgsql.md#pg_conf) parameter, or simply fill in the template file name if using a pre-built template.

If a custom [Patroni configuration template](v-pgsql.md#pg_conf) is used, the companion [node optimization template](v-nodes.md#node_tune) should usually be used for the machine node as well.



## Sample Patroni Template

When customizing your own Patroni template, you can use several existing base templates as a baseline to build upon.

and place them in the [`templates/`](https://github.com/Vonng/pigsty/tree/master/roles/postgres/templates) directory, just name them in `mode.yml` format.

Please keep the template variables in Patroni, otherwise the related parameters may not work properly.

A typical Patroni configuration file (OLTP)

```yaml
#!/usr/bin/env patroni
#==============================================================#
# File      :   patroni.yml
# Ctime     :   2020-04-08
# Mtime     :   2020-12-22
# Desc      :   patroni cluster definition for {{ pg_cluster }} (oltp)
# Path      :   /pg/bin/patroni.yml
# Real Path :   /pg/conf/{{ pg_instance }}.yml
# Link      :   /pg/bin/patroni.yml -> /pg/conf/{{ pg_instance}}.yml
# Note      :   Transactional Database Cluster Template
# Doc       :   https://patroni.readthedocs.io/en/latest/SETTINGS.html
# Copyright (C) 2018-2022 Ruohang Feng
#==============================================================#

# OLTP database are optimized for performance, rt latency
# typical spec: 64 Core | 400 GB RAM | PCI-E SSD xTB

---
#------------------------------------------------------------------------------
# identity
#------------------------------------------------------------------------------
namespace: {{ pg_namespace }}/          # namespace
scope: {{ pg_cluster }}                 # cluster name
name: {{ pg_instance }}                 # instance name

#------------------------------------------------------------------------------
# log
#------------------------------------------------------------------------------
log:
  level: INFO                           #  NOTEST|DEBUG|INFO|WARNING|ERROR|CRITICAL
  dir: /pg/log/                         #  default log file: /pg/log/patroni.log
  file_size: 33554432                   #  32MB log triggers log rotation
  file_num: 20                          #  keep at most 30x32MB = 1GB log
  dateformat: '%Y-%m-%d %H:%M:%S %z'    #  IMPORTANT: discard milli timestamp
  format: '%(asctime)s %(levelname)s: %(message)s'

#------------------------------------------------------------------------------
# dcs
#------------------------------------------------------------------------------
consul:
  host: 127.0.0.1:8500
  consistency: default         # default|consistent|stale
  register_service: true
  service_check_interval: 15s
  service_tags:
    - {{ pg_cluster }}

#------------------------------------------------------------------------------
# api
#------------------------------------------------------------------------------
# how to expose patroni service
# listen on all ipv4, connect via public ip, use same credential as dbuser_monitor
restapi:
  listen: 0.0.0.0:{{ patroni_port }}
  connect_address: {{ inventory_hostname }}:{{ patroni_port }}
  authentication:
    verify_client: none                 # none|optional|required
    username: {{ pg_monitor_username }}
    password: '{{ pg_monitor_password }}'

#------------------------------------------------------------------------------
# ctl
#------------------------------------------------------------------------------
ctl:
  optional:
    insecure: true
    # cacert: '/path/to/ca/cert'
    # certfile: '/path/to/cert/file'
    # keyfile: '/path/to/key/file'

#------------------------------------------------------------------------------
# tags
#------------------------------------------------------------------------------
tags:
  nofailover: false
  clonefrom: true
  noloadbalance: false
  nosync: false
{% if pg_upstream is defined %}
  replicatefrom: {{ pg_upstream }}    # clone from another replica rather than primary
{% endif %}

#------------------------------------------------------------------------------
# watchdog
#------------------------------------------------------------------------------
# available mode: off|automatic|required
watchdog:
  mode: {{ patroni_watchdog_mode }}
  device: /dev/watchdog
  # safety_margin: 10s

#------------------------------------------------------------------------------
# bootstrap
#------------------------------------------------------------------------------
bootstrap:

  #----------------------------------------------------------------------------
  # bootstrap method
  #----------------------------------------------------------------------------
  method: initdb
  # add custom bootstrap method here

  # default bootstrap method: initdb
  initdb:
{% if pg_encoding != '' %}
    - encoding: {{ pg_encoding }}
{% endif %}
{% if pg_locale != '' %}
    - locale: {{ pg_locale }}
{% endif %}
{% if pg_lc_collate != '' %}
    - lc-collate: {{ pg_lc_collate }}
{% endif %}
{% if pg_lc_ctype != '' %}
    - lc-ctype: {{ pg_lc_ctype }}
{% endif %}

  #----------------------------------------------------------------------------
  # bootstrap users
  #---------------------------------------------------------------------------
  # additional users which need to be created after initializing new cluster
  # replication user and monitor user are required
  users:
    {{ pg_replication_username }}:
      password: '{{ pg_replication_password }}'
    {{ pg_monitor_username }}:
      password: '{{ pg_monitor_password }}'
    {{ pg_admin_username }}:
      password: '{{ pg_admin_password }}'

  # bootstrap hba, allow local and intranet password access & replication
  # will be overwritten later
  pg_hba:
    - local   all             postgres                                ident
    - local   all             all                                     md5
    - host    all             all            0.0.0.0/0                md5
    - local   replication     postgres                                ident
    - local   replication     all                                     md5
    - host    replication     all            0.0.0.0/0                md5


  #----------------------------------------------------------------------------
  # template
  #---------------------------------------------------------------------------
  # post_init: /pg/bin/pg-init

  #----------------------------------------------------------------------------
  # bootstrap config
  #---------------------------------------------------------------------------
  # this section will be written to /{{ pg_namespace }}/{{ pg_cluster }}/config
  # if will NOT take any effect after cluster bootstrap
  dcs:

{% if pg_role == 'primary' and pg_upstream is defined %}
    #----------------------------------------------------------------------------
    # standby cluster definition
    #---------------------------------------------------------------------------
    standby_cluster:
      host: {{ pg_upstream }}
      port: {{ pg_port }}
      # primary_slot_name: patroni     # must be create manually on upstream server, if specified
      create_replica_methods:
        - basebackup
{% endif %}

    #----------------------------------------------------------------------------
    # important parameters
    #---------------------------------------------------------------------------
    # constraint: ttl >: loop_wait + retry_timeout * 2

    # the number of seconds the loop will sleep. Default value: 10
    # this is patroni check loop interval
    loop_wait: 10

    # the TTL to acquire the leader lock (in seconds). Think of it as the length of time before initiation of the automatic failover process. Default value: 30
    # config this according to your network condition to avoid false-positive failover
    ttl: 30

    # timeout for DCS and PostgreSQL operation retries (in seconds). DCS or network issues shorter than this will not cause Patroni to demote the leader. Default value: 10
    retry_timeout: 10

    # the amount of time a master is allowed to recover from failures before failover is triggered (in seconds)
    # Max RTO: 2 loop wait + master_start_timeout
    master_start_timeout: 10

    # import: candidate will not be promoted if replication lag is higher than this
    # maximum RPO: 1MB
    maximum_lag_on_failover: 1048576

    # The number of seconds Patroni is allowed to wait when stopping Postgres and effective only when synchronous_mode is enabled
    master_stop_timeout: 30

    # turns on synchronous replication mode. In this mode a replica will be chosen as synchronous and only the latest leader and synchronous replica are able to participate in leader election
    # set to true for RPO mode
    synchronous_mode: false

    # prevents disabling synchronous replication if no synchronous replicas are available, blocking all client writes to the master
    synchronous_mode_strict: false


    #----------------------------------------------------------------------------
    # postgres parameters
    #---------------------------------------------------------------------------
    postgresql:
      use_slots: true
      use_pg_rewind: true
      remove_data_directory_on_rewind_failure: true


      parameters:
        #----------------------------------------------------------------------
        # IMPORTANT PARAMETERS
        #----------------------------------------------------------------------
        max_connections: 800                    # 100 -> 800
        superuser_reserved_connections: 10      # reserve 10 connection for su
        max_locks_per_transaction: 128          # 64 -> 128
        max_prepared_transactions: 0            # 0 disable 2PC
        track_commit_timestamp: on              # enabled xact timestamp
        max_worker_processes: 64                # default 8 -> 64, set to cpu core 64
        wal_level: logical                      # logical
        wal_log_hints: on                       # wal log hints to support rewind
        max_wal_senders: 24                     # 10 -> 24
        max_replication_slots: 16               # 10 -> 16
        wal_keep_size: 100GB                    # keep at least 100GB WAL
        password_encryption: md5                # use traditional md5 auth

        #----------------------------------------------------------------------
        # RESOURCE USAGE (except WAL)
        #----------------------------------------------------------------------
        # memory: shared_buffers and maintenance_work_mem will be dynamically set
        shared_buffers: {{ pg_shared_buffers }}
        maintenance_work_mem: {{ pg_maintenance_work_mem }}
        work_mem: 32MB                          # 4MB -> 32MB
        huge_pages: try                         # try huge pages
        temp_file_limit: 100GB                  # 0 -> 100GB
        vacuum_cost_delay: 2ms                  # wait 2ms per 10000 cost
        vacuum_cost_limit: 10000                # 10000 cost each round
        bgwriter_delay: 10ms                    # check dirty page every 10ms
        bgwriter_lru_maxpages: 800              # 100 -> 800
        bgwriter_lru_multiplier: 5.0            # 2.0 -> 5.0  more cushion buffer
        max_parallel_workers: 32                # default 8 -> 32, limit by max_worker_processes
        max_parallel_maintenance_workers: 8     # default 2 -> 8, limit by parallel worker
        max_parallel_workers_per_gather: 0      # default 2 -> 0, disable parallel query in OLTP mode

        #----------------------------------------------------------------------
        # WAL
        #----------------------------------------------------------------------
        wal_buffers: 16MB                       # max to 16MB
        wal_writer_delay: 20ms                  # wait period
        wal_writer_flush_after: 1MB             # max allowed data loss
        min_wal_size: 100GB                     # at least 100GB WAL
        max_wal_size: 400GB                     # at most 400GB WAL
        commit_delay: 20                        # 200ms -> 20ms, increase speed
        commit_siblings: 10                     # 5 -> 10
        checkpoint_timeout: 60min               # checkpoint 5min -> 1h
        checkpoint_completion_target: 0.95      # 0.5 -> 0.95
        archive_mode: on
        archive_command: 'wal_dir=/pg/arcwal; [[ $(date +%H%M) == 1200 ]] && rm -rf ${wal_dir}/$(date -d"yesterday" +%Y%m%d); /bin/mkdir -p ${wal_dir}/$(date +%Y%m%d) && /usr/bin/lz4 -q -z %p > ${wal_dir}/$(date +%Y%m%d)/%f.lz4'

        #----------------------------------------------------------------------
        # REPLICATION
        #----------------------------------------------------------------------
        # synchronous_standby_names: ''
        vacuum_defer_cleanup_age: 50000         # 0->50000 last 50000 xact changes will not be vacuumed
        promote_trigger_file: promote.signal    # default promote trigger file path
        max_standby_archive_delay: 10min        # max delay before canceling queries when reading WAL from archive;
        max_standby_streaming_delay: 3min       # max delay before canceling queries when reading streaming WAL;
        wal_receiver_status_interval: 1s        # send replies at least this often
        hot_standby_feedback: on                # send info from standby to prevent query conflicts
        wal_receiver_timeout: 60s               # time that receiver waits for
        max_logical_replication_workers: 8      # 4 -> 8, 6 sync worker + 1~2 apply worker
        max_sync_workers_per_subscription: 6    # 2 -> 6, 6 sync worker

        #----------------------------------------------------------------------
        # QUERY TUNING
        #----------------------------------------------------------------------
        # planner
        # enable_partitionwise_join: on
        random_page_cost: 1.1                   # 4 for HDD, 1.1 for SSD
        effective_cache_size: 320GB             # max mem - shared buffer
        default_statistics_target: 1000         # stat bucket 100 -> 1000

        #----------------------------------------------------------------------
        # REPORTING AND LOGGING
        #----------------------------------------------------------------------
        log_destination: csvlog                 # use standard csv log
        logging_collector: on                   # enable csvlog
        log_directory: log                      # default log dir: /pg/data/log
        # log_filename: 'postgresql-%a.log'     # weekly auto-recycle
        log_filename: 'postgresql-%Y-%m-%d.log' # YYYY-MM-DD full log retention
        log_checkpoints: on                     # log checkpoint info
        log_lock_waits: on                      # log lock wait info
        log_replication_commands: on            # log replication info
        log_statement: ddl                      # log ddl change
        log_min_duration_statement: 100         # log slow query (>100ms)

        #----------------------------------------------------------------------
        # STATISTICS
        #----------------------------------------------------------------------
        track_io_timing: on                     # collect io statistics
        track_functions: all                    # track all functions (none|pl|all)
        track_activity_query_size: 8192         # max query length in pg_stat_activity

        #----------------------------------------------------------------------
        # AUTOVACUUM
        #----------------------------------------------------------------------
        log_autovacuum_min_duration: 1s         # log autovacuum activity take more than 1s
        autovacuum_max_workers: 3               # default autovacuum worker 3
        autovacuum_naptime: 1min                # default autovacuum naptime 1min
        autovacuum_vacuum_scale_factor: 0.08    # fraction of table size before vacuum   20% -> 8%
        autovacuum_analyze_scale_factor: 0.04   # fraction of table size before analyze  10% -> 4%
        autovacuum_vacuum_cost_delay: -1        # default vacuum cost delay: same as vacuum_cost_delay
        autovacuum_vacuum_cost_limit: -1        # default vacuum cost limit: same as vacuum_cost_limit
        autovacuum_freeze_max_age: 1000000000   # age > 1 billion triggers force vacuum

        #----------------------------------------------------------------------
        # CLIENT
        #----------------------------------------------------------------------
        deadlock_timeout: 50ms                  # 50ms for deadlock
        idle_in_transaction_session_timeout: 10min  # 10min timeout for idle in transaction

        #----------------------------------------------------------------------
        # CUSTOMIZED OPTIONS
        #----------------------------------------------------------------------
        # extensions
        shared_preload_libraries: '{{ pg_libs | default("pg_stat_statements, auto_explain") }}'

        # auto_explain
        auto_explain.log_min_duration: 1s       # auto explain query slower than 1s
        auto_explain.log_analyze: true          # explain analyze
        auto_explain.log_verbose: true          # explain verbose
        auto_explain.log_timing: true           # explain timing
        auto_explain.log_nested_statements: true

        # pg_stat_statements
        pg_stat_statements.max: 10000           # 5000 -> 10000 queries
        pg_stat_statements.track: all           # track all statements (all|top|none)
        pg_stat_statements.track_utility: off   # do not track query other than CRUD
        pg_stat_statements.track_planning: off  # do not track planning metrics


#------------------------------------------------------------------------------
# postgres
#------------------------------------------------------------------------------
postgresql:

  #----------------------------------------------------------------------------
  # how to connect to postgres
  #----------------------------------------------------------------------------
  bin_dir: {{ pg_bin_dir }}
  data_dir: {{ pg_data }}
  config_dir: {{ pg_data }}
  pgpass: {{ pg_dbsu_home }}/.pgpass
  listen: {{ pg_listen }}:{{ pg_port }}
  connect_address: {{ inventory_hostname }}:{{ pg_port }}
  use_unix_socket: true # default: /var/run/postgresql, /tmp

  #----------------------------------------------------------------------------
  # who to connect to postgres
  #----------------------------------------------------------------------------
  authentication:
    superuser:
      username: {{ pg_dbsu }}
    replication:
      username: {{ pg_replication_username }}
      password: '{{ pg_replication_password }}'
    rewind:
      username: {{ pg_replication_username }}
      password: '{{ pg_replication_password }}'

  #----------------------------------------------------------------------------
  # how to react to database operations
  #----------------------------------------------------------------------------
  # event callback script log: /pg/log/callback.log
  callbacks:
    on_start: /pg/bin/pg-failover-callback
    on_stop: /pg/bin/pg-failover-callback
    on_reload: /pg/bin/pg-failover-callback
    on_restart: /pg/bin/pg-failover-callback
    on_role_change: /pg/bin/pg-failover-callback

  # rewind policy: data checksum should be enabled before using rewind
  use_pg_rewind: true
  remove_data_directory_on_rewind_failure: true
  remove_data_directory_on_diverged_timelines: false

  #----------------------------------------------------------------------------
  # how to create replica
  #----------------------------------------------------------------------------
  # create replica method: default pg_basebackup
  create_replica_methods:
    - basebackup
  basebackup:
    - max-rate: '1000M'
    - checkpoint: fast
    - verbose
    - progress

  #----------------------------------------------------------------------------
  # ad hoc parameters (overwrite with default)
  #----------------------------------------------------------------------------
  # parameters:

  #----------------------------------------------------------------------------
  # host based authentication, overwrite default pg_hba.conf
  #----------------------------------------------------------------------------
  # pg_hba:
  #   - local   all             postgres                                ident
  #   - local   all             all                                     md5
  #   - host    all             all            0.0.0.0/0                md5
  #   - local   replication     postgres                                ident
  #   - local   replication     all                                     md5
  #   - host    replication     all            0.0.0.0/0                md5

...
```

