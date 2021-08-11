# 深度定制Postgres数据库模板



## 相关参数

可以使用 [PG模板](v-pg-template) 配置项，对集群中的模板数据库 `template1` 进行定制。

通过这种方式确保任何在该数据库集群中**新创建**的数据库都带有相同的默认配置：模式，扩展，默认权限。

|                             名称                             |     类型      | 层级  | 说明                      |
| :----------------------------------------------------------: | :-----------: | :---: | ------------------------- |
|             [pg_init](v-pg-template.md#pg_init)              |   `string`    |  G/C  | 自定义PG初始化脚本        |
| [pg_replication_username](v-pg-template.md#pg_replication_username) |   `string`    |   G   | PG复制用户                |
| [pg_replication_password](v-pg-template.md#pg_replication_password) |   `string`    |   G   | PG复制用户的密码          |
| [pg_monitor_username](v-pg-template.md#pg_monitor_username)  |   `string`    |   G   | PG监控用户                |
| [pg_monitor_password](v-pg-template.md#pg_monitor_password)  |   `string`    |   G   | PG监控用户密码            |
|   [pg_admin_username](v-pg-template.md#pg_admin_username)    |   `string`    |   G   | PG管理用户                |
|   [pg_admin_password](v-pg-template.md#pg_admin_password)    |   `string`    |   G   | PG管理用户密码            |
|    [pg_default_roles](v-pg-template.md#pg_default_roles)     |   `role[]`    |   G   | 默认创建的角色与用户      |
| [pg_default_privilegs](v-pg-template.md#pg_default_privilegs) |  `string[]`   |   G   | 数据库默认权限配置        |
|  [pg_default_schemas](v-pg-template.md#pg_default_schemas)   |  `string[]`   |   G   | 默认创建的模式            |
| [pg_default_extensions](v-pg-template.md#pg_default_extensions) | `extension[]` |   G   | 默认安装的扩展            |
|    [pg_offline_query](v-pg-template.md#pg_offline_query)     |    `bool`     | **I** | 是否允许**离线**查询      |
|           [pg_reload](v-pg-template.md#pg_reload)            |    `bool`     | **A** | 是否重载数据库配置（HBA） |
|        [pg_hba_rules](v-pg-template.md#pg_hba_rules)         |   `rule[]`    |   G   | 全局HBA规则               |
|  [pg_hba_rules_extra](v-pg-template.md#pg_hba_rules_extra)   |   `rule[]`    |  C/I  | 集群/实例特定的HBA规则    |
| [pgbouncer_hba_rules](v-pg-template.md#pgbouncer_hba_rules)  |   `rule[]`    |  G/C  | Pgbouncer全局HBA规则      |
| [pgbouncer_hba_rules_extra](v-pg-template.md#pgbouncer_hba_rules_extra) |   `rule[]`    |  G/C  | Pgbounce特定HBA规则       |
|        [pg_databases](v-pg-template.md#pg_databases)         | `database[]`  |  G/C  | **业务数据库定义**        |
|            [pg_users](v-pg-template.md#pg_users)             |   `user[]`    |  G/C  | **业务用户定义**          |



## 相关文件

定制数据库模板时，相关参数会首先被渲染为SQL脚本后，在部署好的数据库集群上执行。


```ini
^---/pg/bin/pg-init
          |
          ^---(1)--- /pg/tmp/pg-init-roles.sql
          ^---(2)--- /pg/tmp/pg-init-template.sql
          ^---(3)--- <other customize logic in pg-init>

# 业务用户与数据库并不是在模版定制中创建的，但在此列出。
^-------------(4)--- /pg/tmp/pg-user-{{ user.name }}.sql
^-------------(5)--- /pg/tmp/pg-db-{{ db.name }}.sql
```

## [pg-init](v-pg-template.md#pg_init)

[`pg-init`](v-pg-template.md#pg_init)是用于自定义初始化模板的Shell脚本路径，该脚本将以postgres用户身份，**仅在主库上执行**，执行时数据库集群主库已经被拉起，可以执行任意Shell命令，或通过psql执行任意SQL命令。

如果不指定该配置项，Pigsty会使用默认的[`pg-init`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/pg-init) Shell脚本，如下所示。

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

如果用户需要执行复杂的定制逻辑，可在该脚本的基础上进行追加。注意 `pg-init` 用于定制**数据库集群**，通常这是通过修改 **模板数据库** 实现的。在该脚本执行时，数据库集群已经启动，但业务用户与业务数据库尚未创建。因此模板数据库的修改会反映在默认定义的业务数据库中。



## `pg-init-roles.sql`

在 [`pg_default_roles` ](v-pg-template.md#pg_default_roles)中可以自定义**全局统一**的角色体系。其中的定义会被渲染为`/pg/tmp/pg-init-roles.sql`，`pg-meta`集群中的渲染样例如下所示：

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
-- Copyright (C) 2018-2021 Ruohang Feng
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

