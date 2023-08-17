-- ######################################################################
-- # File      :   cmdb.sql
-- # Desc      :   Pigsty CMDB baseline
-- # Ctime     :   2021-04-21
-- # Mtime     :   2023-01-07
-- # License   :   AGPLv3
-- # Author    :   Ruohang Feng (rh@vonng.com)
-- # License   :   AGPLv3
-- ######################################################################


--===========================================================--
--                          schema                           --
--===========================================================--
DROP SCHEMA IF EXISTS pigsty CASCADE; -- cleanse
CREATE SCHEMA IF NOT EXISTS pigsty;
SET search_path TO pigsty, public;


--===========================================================--
--                          type                             --
--===========================================================--
CREATE TYPE pigsty.pg_role AS ENUM ('unknown','primary', 'replica', 'offline', 'standby', 'delayed', 'common');
COMMENT ON TYPE pigsty.pg_role IS 'available postgres roles';

CREATE TYPE pigsty.job_status AS ENUM ('draft', 'ready', 'run', 'done', 'fail');
COMMENT ON TYPE pigsty.job_status IS 'pigsty job status';

CREATE TYPE pigsty.var_level AS ENUM ('default', 'global', 'group', 'host', 'ins', 'arg');
COMMENT ON TYPE pigsty.var_level IS 'pigsty parameters level';


--===========================================================--
--                         cluster                           --
--===========================================================--
-- DROP TABLE IF EXISTS pigsty.group CASCADE;
CREATE TABLE IF NOT EXISTS pigsty.group
(
    cls     TEXT PRIMARY KEY,
    ctime   TIMESTAMPTZ   NOT NULL DEFAULT now(),
    mtime   TIMESTAMPTZ   NOT NULL DEFAULT now()
);
COMMENT ON TABLE pigsty.group IS 'pigsty inventory group';
COMMENT ON COLUMN pigsty.group.cls IS 'group name, primary key, can not change';
COMMENT ON COLUMN pigsty.group.ctime IS 'group entry creation time';
COMMENT ON COLUMN pigsty.group.mtime IS 'group modification time';


--===========================================================--
--                          host                             --
--===========================================================--
-- host belongs to group, can be assigned to multiple groups

-- DROP TABLE IF EXISTS pigsty.host CASCADE;
CREATE TABLE IF NOT EXISTS pigsty.host
(
    cls    TEXT        NOT NULL REFERENCES pigsty.group (cls) ON DELETE CASCADE ON UPDATE CASCADE,
    ip     INET        NOT NULL,
    ctime  TIMESTAMPTZ NOT NULL DEFAULT now(),
    mtime  TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (cls, ip)
);

COMMENT ON TABLE pigsty.host IS 'pigsty hosts';
COMMENT ON COLUMN pigsty.host.cls IS 'host primary key: cls & ip';
COMMENT ON COLUMN pigsty.host.ip IS 'host primary key: cls & host ip';
COMMENT ON COLUMN pigsty.host.ctime IS 'host entry creation time';
COMMENT ON COLUMN pigsty.host.mtime IS 'host modification time';


--===========================================================--
--                      default_vars                          --
--===========================================================--
-- hold default var definition (roles.default)

-- DROP TABLE IF EXISTS pigsty.default_var;
CREATE TABLE IF NOT EXISTS pigsty.default_var
(
    id      INTEGER       NOT NULL,
    key     TEXT PRIMARY KEY CHECK (key != ''),
    value   JSONB         NULL,
    module  VARCHAR(16)   NOT NULL,
    section VARCHAR(64)   NOT NULL,
    type    VARCHAR(16)   NOT NULL,
    level   VARCHAR(16)   NOT NULL,
    summary VARCHAR(512)  NOT NULL,
    detail  VARCHAR(2048) NULL
);
COMMENT ON TABLE pigsty.default_var IS 'pigsty parameters table';
COMMENT ON COLUMN pigsty.default_var.id       IS '';
COMMENT ON COLUMN pigsty.default_var.key      IS 'param name, primary key';
COMMENT ON COLUMN pigsty.default_var.value    IS 'param default value, null means no default value';
COMMENT ON COLUMN pigsty.default_var.module   IS 'module name of this param, INFRA/NODE/PGSQL/REDIS/MINIO/ETCD...';
COMMENT ON COLUMN pigsty.default_var.section  IS 'section name of this param';
COMMENT ON COLUMN pigsty.default_var.type     IS 'param type';
COMMENT ON COLUMN pigsty.default_var.level    IS 'param level: G/C/N/I/A';
COMMENT ON COLUMN pigsty.default_var.summary  IS 'param short description';
COMMENT ON COLUMN pigsty.default_var.detail   IS 'param long description';


--===========================================================--
--                      global_vars                          --
--===========================================================--
-- hold global var definition (all.vars)

-- DROP TABLE IF EXISTS pigsty.global_var;
CREATE TABLE IF NOT EXISTS pigsty.global_var
(
    key   TEXT PRIMARY KEY CHECK (key != ''),
    value JSONB NULL,
    mtime TIMESTAMPTZ DEFAULT now()
);
COMMENT ON TABLE pigsty.global_var IS 'global variables';
COMMENT ON COLUMN pigsty.global_var.key IS 'global config entry name';
COMMENT ON COLUMN pigsty.global_var.value IS 'global config entry value';
COMMENT ON COLUMN pigsty.global_var.mtime IS 'global config entry last modified time';


--===========================================================--
--                       group_vars                          --
--===========================================================--
-- hold cluster var definition (all.children.<pg_cluster>.vars)

-- DROP TABLE IF EXISTS pigsty.group_var;
CREATE TABLE IF NOT EXISTS pigsty.group_var
(
    cls   TEXT  NOT NULL REFERENCES pigsty.group (cls) ON DELETE CASCADE ON UPDATE CASCADE,
    key   TEXT  NOT NULL CHECK (key != ''),
    value JSONB NULL,
    mtime TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (cls, key)
);
COMMENT ON TABLE pigsty.group_var IS 'group config entries';
COMMENT ON COLUMN pigsty.group_var.cls IS 'group name';
COMMENT ON COLUMN pigsty.group_var.key IS 'group config entry name';
COMMENT ON COLUMN pigsty.group_var.value IS 'group entry value';
COMMENT ON COLUMN pigsty.group_var.mtime IS 'group config entry last modified time';

--===========================================================--
--                        host_var                           --
--===========================================================--
-- DROP TABLE IF EXISTS pigsty.host_var;
CREATE TABLE IF NOT EXISTS pigsty.host_var
(
    cls   TEXT  NOT NULL,
    ip    INET  NOT NULL,
    key   TEXT  NOT NULL CHECK (key != ''),
    value JSONB NULL,
    mtime TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (cls, ip, key),
    FOREIGN KEY (cls, ip) REFERENCES pigsty.host (cls, ip) ON DELETE CASCADE ON UPDATE CASCADE
);
COMMENT ON TABLE pigsty.host_var IS 'host config entries';
COMMENT ON COLUMN pigsty.host_var.cls IS 'host group name';
COMMENT ON COLUMN pigsty.host_var.ip IS 'host ip addr';
COMMENT ON COLUMN pigsty.host_var.key IS 'host config entry name';
COMMENT ON COLUMN pigsty.host_var.value IS 'host entry value';
COMMENT ON COLUMN pigsty.host_var.mtime IS 'host config entry last modified time';

--===========================================================--
--                           job                             --
--===========================================================--
-- DROP TABLE IF EXISTS job;
CREATE TABLE IF NOT EXISTS pigsty.job
(
    id        BIGSERIAL PRIMARY KEY,                   -- use job_id() after serial creation
    name      TEXT,                                    -- job name (optional)
    type      TEXT,                                    -- job type
    data      JSONB       DEFAULT '{}'::JSONB,         -- job data specific to type
    log       TEXT,                                    -- log content (write after done|fail)
    log_path  TEXT,                                    -- where to tail latest log ?
    status    job_status  DEFAULT 'draft'::job_status, -- draft,ready,run,done,fail
    ctime     TIMESTAMPTZ DEFAULT now(),               -- job creation time
    mtime     TIMESTAMPTZ DEFAULT now(),               -- job latest modification time
    start_at  TIMESTAMPTZ,                             -- job start running at
    finish_at TIMESTAMPTZ                              -- job done|fail at
);
COMMENT ON TABLE pigsty.job IS 'pigsty job table';
COMMENT ON COLUMN pigsty.job.id IS 'job id generated by job_id()';
COMMENT ON COLUMN pigsty.job.name IS 'job name (optional)';
COMMENT ON COLUMN pigsty.job.type IS 'job type (optional)';
COMMENT ON COLUMN pigsty.job.data IS 'job data (json)';
COMMENT ON COLUMN pigsty.job.log IS 'job log content, load after execution';
COMMENT ON COLUMN pigsty.job.log_path IS 'job log path, can be tailed while running';
COMMENT ON COLUMN pigsty.job.status IS 'job status enum: draft,ready,run,done,fail';
COMMENT ON COLUMN pigsty.job.ctime IS 'job creation time';
COMMENT ON COLUMN pigsty.job.mtime IS 'job modification time';
COMMENT ON COLUMN pigsty.job.start_at IS 'job start time';
COMMENT ON COLUMN pigsty.job.finish_at IS 'job done|fail time';

-- DROP FUNCTION IF EXISTS job_id();
CREATE OR REPLACE FUNCTION pigsty.job_id() RETURNS BIGINT AS
$func$
SELECT (FLOOR(EXTRACT(EPOCH FROM clock_timestamp()) * 1000) - 748569600000 /* epoch */) :: BIGINT <<
       23 /* 41 bit timestamp */ | ((nextval('pigsty.job_id_seq') & 1023) << 12) | (random() * 4095)::INTEGER
$func$
    LANGUAGE sql VOLATILE;
COMMENT ON FUNCTION pigsty.job_id() IS 'generate snowflake-like id for job';
ALTER TABLE pigsty.job
    ALTER COLUMN id SET DEFAULT pigsty.job_id(); -- use job_id as id generator

-- DROP FUNCTION IF EXISTS job_id_ts(BIGINT);
CREATE OR REPLACE FUNCTION pigsty.job_id_ts(id BIGINT) RETURNS TIMESTAMP AS
$func$
SELECT to_timestamp(((id >> 23) + 748569600000)::DOUBLE PRECISION / 1000)::TIMESTAMP
$func$ LANGUAGE sql IMMUTABLE;
COMMENT ON FUNCTION pigsty.job_id_ts(BIGINT) IS 'extract timestamp from job id';

--===========================================================--
--                      pigsty.vars_agg                      --
--===========================================================--
CREATE AGGREGATE pigsty.vars_agg(jsonb) (
    SFUNC = 'jsonb_concat', STYPE = jsonb, INITCOND = '{}'
);
COMMENT ON AGGREGATE pigsty.vars_agg(jsonb) IS 'aggregate jsonb into one';

--===========================================================--
--                     pigsty.host_config                    --
--===========================================================--
DROP VIEW IF EXISTS pigsty.host_config;
CREATE OR REPLACE VIEW pigsty.host_config AS
SELECT node.ip, g.groups, node.vars FROM
    (
        SELECT i.ip, pigsty.vars_agg(coalesce(coalesce(cv.vars, '{}'::JSONB) || coalesce(iv.vars, '{}'::JSONB), '{}'::JSONB) ORDER BY c.cls) AS vars
        FROM pigsty.group c
                 LEFT JOIN pigsty.host i ON c.cls = i.cls
                 LEFT JOIN (SELECT cls, jsonb_object_agg(key, value) AS vars FROM pigsty.group_var GROUP BY cls) cv ON c.cls = cv.cls
                 LEFT JOIN (SELECT cls, ip, jsonb_object_agg(key, value) AS vars FROM pigsty.host_var GROUP BY cls, ip) iv ON i.cls = iv.cls AND i.ip = iv.ip
        GROUP BY i.ip
    ) node LEFT OUTER JOIN (SELECT ip, array_agg(cls) AS groups FROM pigsty.host GROUP BY ip) g ON node.ip = g.ip;

COMMENT ON VIEW pigsty.host_config IS 'pigsty host config, groups + host vars merged on host level';


--===========================================================--
--                    pigsty.group_config                    --
--===========================================================--
DROP VIEW IF EXISTS pigsty.group_config CASCADE;
CREATE OR REPLACE VIEW pigsty.group_config AS
SELECT cls, gh.hosts, gc.vars FROM pigsty.group g LEFT JOIN
    (SELECT cls, jsonb_object_agg(ip, vars) AS hosts
        FROM (SELECT coalesce(h.cls, h2.cls) AS cls, coalesce(h.ip, h2.ip) AS ip, coalesce(h.vars, '{}'::JSONB) AS vars
        FROM (SELECT cls, ip, jsonb_object_agg(key, value) AS vars FROM pigsty.host_var GROUP BY cls, ip) h FULL JOIN pigsty.host h2 USING (cls, ip)) hv
        GROUP BY cls) gh USING (cls)
    LEFT JOIN (SELECT cls, jsonb_object_agg(key, value) AS vars FROM pigsty.group_var GROUP BY cls) gc USING (cls);

COMMENT ON VIEW pigsty.group_config IS 'pigsty group config view: name, hosts, vars';


--===========================================================--
--                    pigsty.global_config                   --
--===========================================================--
DROP VIEW IF EXISTS pigsty.global_config;
CREATE OR REPLACE VIEW pigsty.global_config AS
SELECT coalesce(gv.key, dv.key) AS key, coalesce(gv.value, dv.value) AS value,
       CASE when gv.value IS NULL THEN 'default'::pigsty.var_level ELSE 'global'::pigsty.var_level END AS level  FROM
    pigsty.default_var dv FULL OUTER JOIN pigsty.global_var gv ON dv.key = gv.key;

COMMENT ON VIEW pigsty.global_config IS 'pigsty global config, default + global vars merged';


CREATE OR REPLACE FUNCTION pigsty.get_param(_in TEXT) RETURNS TEXT
AS $$
SELECT value #>> '{}' FROM pigsty.global_config WHERE key = _in LIMIT 1;
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION pigsty.get_param(TEXT) IS 'get global param value string by name';



--===========================================================--
--                    pigsty.raw_config                      --
--===========================================================--
DROP VIEW IF EXISTS pigsty.raw_config;
CREATE OR REPLACE VIEW pigsty.raw_config AS
    SELECT jsonb_build_object('all', jsonb_build_object('children', children, 'vars', vars)) FROM
    (SELECT jsonb_object_agg(cls, jsonb_build_object('hosts', hosts, 'vars', vars)) AS children FROM pigsty.group_config) a1,
    (SELECT jsonb_object_agg(key, value) AS vars FROM pigsty.global_var) a2;
COMMENT ON VIEW pigsty.raw_config IS 'pigsty raw config file in json format';


--===========================================================--
--                     pigsty.inventory                      --
--===========================================================--
DROP VIEW IF EXISTS pigsty.inventory;
CREATE OR REPLACE VIEW pigsty.inventory AS
    SELECT groups.data || hosts.data || variables.data AS text
    FROM (SELECT jsonb_build_object('all', jsonb_build_object('children', '["meta"]' || jsonb_agg(cls))) AS data FROM pigsty.group) groups,
         (SELECT jsonb_object_agg(cls, cc.member) AS data FROM (SELECT cls, jsonb_build_object('hosts', jsonb_agg(host(ip))) AS member FROM pigsty.host i GROUP BY cls) cc) hosts,
         (
            SELECT jsonb_build_object('_meta', jsonb_build_object('hostvars', jsonb_object_agg(ip, vars))) AS data
            FROM (SELECT ip, coalesce(gv.vars, '{}'::JSONB) || hv.vars AS vars FROM
                      (SELECT i.ip, pigsty.vars_agg(coalesce(coalesce(cv.vars, '{}'::JSONB) || coalesce(iv.vars, '{}'::JSONB), '{}'::JSONB) ORDER BY c.cls) AS vars FROM pigsty.group c
                            LEFT JOIN pigsty.host i ON c.cls = i.cls
                            LEFT JOIN (SELECT cls, jsonb_object_agg(key, value) AS vars FROM pigsty.group_var GROUP BY cls) cv ON c.cls = cv.cls
                            LEFT JOIN (SELECT cls, ip, jsonb_object_agg(key, value) AS vars FROM pigsty.host_var GROUP BY cls, ip) iv ON i.cls = iv.cls AND i.ip = iv.ip
                   GROUP BY i.ip) hv, (SELECT jsonb_object_agg(key, value) AS vars FROM pigsty.global_var) gv) mm) variables;
COMMENT ON VIEW pigsty.inventory IS 'pigsty config inventory in ansible dynamic inventory format';




--===========================================================--
--                    pigsty.pg_cluster                      --
--===========================================================--
DROP VIEW IF EXISTS pigsty.pg_cluster CASCADE;
CREATE OR REPLACE VIEW pigsty.pg_cluster AS
    SELECT cls,
           vars ->> 'pg_cluster'                                                 AS name,
           hosts,
           vars,
           coalesce(vars -> 'pg_databases', '[]'::JSONB)                         AS pg_databases,
           coalesce(vars -> 'pg_users', '[]'::JSONB)                             AS pg_users,
           coalesce((gsvc.global || vars) -> 'pg_services', '[]'::JSONB) ||
           coalesce((gsvc.global || vars) -> 'pg_default_services', '[]'::JSONB)   AS pg_services,
           coalesce((gsvc.global || vars) -> 'pg_hba_rules', '[]'::JSONB) ||
           coalesce((gsvc.global || vars) -> 'pg_default_hba_rules', '[]'::JSONB)  AS pg_hba,
           coalesce((gsvc.global || vars) -> 'pgb_hba_rules', '[]'::JSONB) ||
           coalesce((gsvc.global || vars) -> 'pgb_default_hba_rules', '[]'::JSONB) AS pgbouncer_hba
    FROM pigsty.group_config,
         (SELECT jsonb_object_agg(key, value) AS global FROM pigsty.global_config WHERE key ~ '_services$' OR key ~ '_hba_rules$') gsvc
    WHERE vars ? 'pg_cluster';
COMMENT ON VIEW pigsty.pg_cluster IS 'pigsty cluster definition for pg_cluster';


--===========================================================--
--                    pigsty.pg_instance                     --
--===========================================================--
DROP VIEW IF EXISTS pigsty.pg_instance;
CREATE OR REPLACE VIEW pigsty.pg_instance AS
    SELECT cls,
           key                                                      AS ip,
           cls || '-' || (value ->> 'pg_seq')                       AS ins,
           (value ->> 'pg_seq')::INTEGER                            AS seq,
           (value ->> 'pg_role')::pigsty.pg_role                    AS role,
           coalesce((value ->> 'pg_offline_query')::BOOLEAN, false) AS offline_query,
           coalesce((value ->> 'pg_weight')::INTEGER, 100)          AS weight,
           (value ->> 'pg_upstream')::INET                          AS upstream,
           value                                                    AS instance
    FROM pigsty.pg_cluster, jsonb_each(hosts) ORDER BY 1, 4;
COMMENT ON VIEW pigsty.pg_instance IS 'pigsty instance definition';

--===========================================================--
--                    pigsty.pg_service                      --
--===========================================================--
DROP VIEW IF EXISTS pigsty.pg_service;
CREATE OR REPLACE VIEW pigsty.pg_service AS
    SELECT cls,
           cls || '-' || (value ->> 'name') AS svc,
           value ->> 'name'                 AS name,
           value ->> 'ip'                   AS src_ip,
           value ->> 'port'                 AS src_port,
           value ->> 'dest'                 AS dst_port,
           value ->> 'check'                AS check_url,
           value ->> 'selector'             AS selector,
           value ->> 'selector_backup'      AS selector_backup,
           (value ->> 'maxconn')::INTEGER   AS maxconn,
           (value ->> 'balance')            AS balance,
           (value ->> 'options')            AS options,
           value                            AS service
    FROM pigsty.pg_cluster, jsonb_array_elements(pg_services) ORDER BY 1 ,3;
COMMENT ON VIEW pigsty.pg_service IS 'pigsty service definition';

--===========================================================--
--                   pigsty.pg_databases                     --
--===========================================================--
DROP VIEW IF EXISTS pigsty.pg_database;
CREATE OR REPLACE VIEW pigsty.pg_database AS
    SELECT cls,
           value ->> 'name'                                      AS datname,
           value ->> 'owner'                                     AS owner,
           value ->> 'template'                                  AS template,
           value ->> 'encoding'                                  AS encoding,
           value ->> 'locale'                                    AS locale,
           value ->> 'lc_collate'                                AS lc_collate,
           value ->> 'lc_ctype'                                  AS lc_ctype,
           coalesce((value ->> 'allowconn')::BOOLEAN, true)      AS allowconn,
           coalesce((value ->> 'revokeconn')::BOOLEAN, false)    AS revokeconn,
           (value ->> 'tablespace')                              AS tablespace,
           coalesce((value ->> 'connlimit')::INTEGER, -1)        AS connlimit,
           coalesce((value -> 'pgbouncer')::BOOLEAN, true)       AS pgbouncer,
           coalesce((value ->> 'comment'), '')                   AS comment,
           coalesce((value -> 'schemas')::JSONB, '[]'::JSONB)    AS schemas,
           coalesce((value -> 'extensions')::JSONB, '[]'::JSONB) AS extensions,
           coalesce((value -> 'parameters')::JSONB, '{}'::JSONB) AS parameters,
           (value ->> 'pool_mode')                               AS pool_mode,
           (value ->> 'pool_connlimit')::INTEGER                 AS pool_connlimit,
           value                                                 AS database
    FROM pigsty.pg_cluster, jsonb_array_elements(pg_databases);
COMMENT ON VIEW pigsty.pg_database IS 'pigsty postgres databases definition';


--===========================================================--
--                     pigsty.pg_users                       --
--===========================================================--
DROP VIEW IF EXISTS pigsty.pg_users;
CREATE OR REPLACE VIEW pigsty.pg_users AS
    SELECT cls,
       (u ->> 'name')                                  AS name,
       (u ->> 'password')                              AS password,
       starts_with(u ->> 'password', 'md5')            AS is_md5pwd,
       coalesce((u ->> 'login')::BOOLEAN, true)        AS login,
       coalesce((u ->> 'superuser') ::BOOLEAN, false)  AS superuser,
       coalesce((u ->> 'createdb')::BOOLEAN, false)    AS createdb,
       coalesce((u ->> 'createrole')::BOOLEAN, false)  AS createrole,
       coalesce((u ->> 'inherit')::BOOLEAN, false)     AS inherit,
       coalesce((u ->> 'replication')::BOOLEAN, false) AS replication,
       coalesce((u ->> 'bypassrls')::BOOLEAN, false)   AS bypassrls,
       coalesce((u ->> 'pgbouncer')::BOOLEAN, false)   AS pgbouncer,
       coalesce((u ->> 'connlimit')::INTEGER, -1)      AS connlimit,
       (u ->> 'expire_in')::INTEGER                    AS expire_in,
       (u ->> 'expire_at')::DATE                       AS expire_at,
       (u ->> 'comment')                               AS comment,
       (u -> 'roles')                                  AS roles,
       (u -> 'parameters')                             AS parameters,
       (u ->> 'pool_auth_user')                        AS pool_auth_user,
       (u ->> 'pool_mode')                             AS pool_mode,
       (u ->> 'pool_size')::INTEGER                    AS pool_size,
       (u ->> 'pool_size_reserve')::INTEGER            AS pool_size_reserve,
       (u ->> 'pool_size_min')::INTEGER                AS pool_size_min,
       (u ->> 'pool_max_db_conn')::INTEGER             AS pool_max_db_conn,
       u                                               AS "user"
    FROM pigsty.pg_cluster, jsonb_array_elements(pg_users) AS u;
COMMENT ON VIEW pigsty.pg_users IS 'pigsty postgres users definition';

--===========================================================--
--                     pigsty.pg_hba                         --
--===========================================================--
DROP VIEW IF EXISTS pigsty.pg_hba;
CREATE OR REPLACE VIEW pigsty.pg_hba AS
    SELECT cls,
           hba ->> 'title'   AS title,
           (hba ->> 'role')::pigsty.pg_role,
           (hba -> 'rules') AS rules,
           (hba ->> 'user') AS "user",
           (hba ->> 'db')   AS db,
           (hba ->> 'addr') AS addr,
           (hba ->> 'auth') AS auth,
           hba
    FROM pigsty.pg_cluster, jsonb_array_elements(pg_hba) AS hba;
COMMENT ON VIEW pigsty.pg_hba IS 'pigsty postgres hba rules';

--===========================================================--
--                  pigsty.pgbouncer_hba                     --
--===========================================================--
DROP VIEW IF EXISTS pigsty.pgb_hba;
CREATE OR REPLACE VIEW pigsty.pgb_hba AS
    SELECT cls,
           hba ->> 'title'   AS title,
           (hba ->> 'role')::pigsty.pg_role,
           (hba -> 'rules') AS rules,
           (hba ->> 'user') AS "user",
           (hba ->> 'db')   AS db,
           (hba ->> 'addr') AS addr,
           (hba ->> 'auth') AS auth,
           hba
    FROM pigsty.pg_cluster,jsonb_array_elements(pgbouncer_hba) AS hba;
COMMENT ON VIEW pigsty.pg_hba IS 'pigsty pgbouncer hba rules';

--===========================================================--
--                    pigsty.pg_remote                       --
--===========================================================--
DROP VIEW IF EXISTS pigsty.pg_remote;
CREATE OR REPLACE VIEW pigsty.pg_remote AS
SELECT p.key                                                            AS local_port,
       (p.value ->> 'pg_cluster')                                       AS cls,
       (p.value ->> 'pg_seq')::INTEGER                                  AS seq,
       (p.value ->> 'pg_host')                                          AS host,
       coalesce((p.value ->> 'pg_port'), v.vars ->> 'pg_port')::INTEGER AS port,
       p.value                                                          AS ins_var,
       v.vars                                                           AS cls_var
FROM group_var gv,
     jsonb_each(value) p,
     (SELECT vars
      FROM group_config
      WHERE cls IN (SELECT cls FROM pigsty.group_var WHERE key = 'pg_exporters' LIMIT 1)) v
WHERE gv.key = 'pg_exporters';
COMMENT ON VIEW pigsty.pg_remote IS 'pigsty remote postgres instances';

--===========================================================--
--                   pigsty.gp_cluster                       --
--===========================================================--
DROP VIEW IF EXISTS pigsty.gp_cluster CASCADE;
CREATE OR REPLACE VIEW pigsty.gp_cluster AS
    SELECT cls,
           vars ->> 'pg_cluster'                                          AS name,
           vars ->> 'gp_role'                                             AS gp_role,
           vars ->> 'pg_shard'                                            AS pg_shard,
           hosts,
           vars,
           coalesce((gsvc.global || vars) -> 'pg_hba_rules', '[]'::JSONB) ||
           coalesce((gsvc.global || vars) -> 'pg_default_hba_rules', '[]'::JSONB) AS pg_hba
    FROM pigsty.group_config,
         (SELECT jsonb_object_agg(key, value) AS global FROM pigsty.global_var WHERE key ~ '^pg_services' or key ~ 'hba_rules') gsvc
    WHERE vars ? 'gp_role';

COMMENT ON VIEW pigsty.gp_cluster IS 'pigsty greenplum/matrixdb cluster definition';

--===========================================================--
--                     pigsty.gp_node                        --
--===========================================================--
DROP VIEW IF EXISTS pigsty.gp_node CASCADE;
CREATE OR REPLACE VIEW pigsty.gp_node AS
    SELECT cls,
           key                                            AS ip,
           (value ->> 'nodename')                         AS node,
           coalesce(value -> 'pg_instances', '{}'::JSONB) AS instances
    FROM pigsty.gp_cluster, jsonb_each(hosts)
    ORDER BY 3;

COMMENT ON VIEW pigsty.gp_node IS 'pigsty greenplum/matrixdb node definition';


--===========================================================--
--                   pigsty.gp_instance                      --
--===========================================================--
DROP VIEW IF EXISTS pigsty.gp_instance CASCADE;
CREATE OR REPLACE VIEW pigsty.gp_instance AS
    SELECT (value ->> 'pg_cluster')                         AS cls,
           (value ->> 'pg_cluster') || (value ->> 'pg_seq') AS ins,
           ip,node,key::INTEGER AS port,
           (value ->> 'pg_role')::pigsty.pg_role            AS pg_role,
           (value ->> 'pg_seq')::INTEGER                    AS pg_seq,
           (value ->> 'pg_exporter_port')::INTEGER          AS exporter_port,
           value                                            AS instance
    FROM pigsty.gp_node, jsonb_each(instances)
    ORDER BY cls, node, port;
COMMENT ON VIEW pigsty.gp_instance IS 'pigsty greenplum/matrixdb instance definition';

--===========================================================--
--                   pigsty.redis_cluster                    --
--===========================================================--
DROP VIEW IF EXISTS pigsty.redis_cluster CASCADE;
CREATE OR REPLACE VIEW pigsty.redis_cluster AS
    SELECT cls,
           vars ->> 'redis_cluster'                                              AS name,
           coalesce((gsvc.global || vars) ->> 'redis_mode', 'standalone')        AS mode,
           coalesce((gsvc.global || vars) ->> 'redis_conf', 'redis.conf')        AS conf,
           coalesce((gsvc.global || vars) ->> 'redis_max_memory', '1GB')         AS max_memory,
           coalesce((gsvc.global || vars) ->> 'redis_mem_policy', 'allkeys-lru') AS mem_policy,
           (gsvc.global || vars) ->> 'redis_password' AS password,
           hosts,vars
    FROM pigsty.group_config,
         (SELECT jsonb_object_agg(key, value) AS global FROM pigsty.global_config WHERE key ~ '^redis') gsvc
    WHERE vars ? 'redis_cluster';
COMMENT ON VIEW pigsty.redis_cluster IS 'pigsty redis cluster definition';

--===========================================================--
--                   pigsty.redis_node                    --
--===========================================================--
DROP VIEW IF EXISTS pigsty.redis_node CASCADE;
CREATE OR REPLACE VIEW pigsty.redis_node AS
    SELECT name AS cls, r.mode AS mode, key as ip,
           cls || '-' || (value ->> 'redis_node') AS redis_node,
           (value ->> 'redis_node')::INTEGER AS node_id,
           coalesce(value -> 'redis_instances', '{}'::JSONB) AS instances
    FROM pigsty.redis_cluster r, jsonb_each(hosts) ORDER BY 1,4;
COMMENT ON VIEW pigsty.redis_node IS 'pigsty redis node definition';

--===========================================================--
--                   pigsty.redis_instance                    --
--===========================================================--
-- DROP VIEW IF EXISTS pigsty.redis_instance CASCADE;
CREATE OR REPLACE VIEW pigsty.redis_instance AS
    SELECT cls, mode, ip , redis_node, node_id , key::INTEGER AS port, redis_node || '-' || key AS ins,
           value->>'replica_of' AS replica_of, value AS instance
    FROM pigsty.redis_node, jsonb_each(instances)
    ORDER BY cls, node_id, port;
COMMENT ON VIEW pigsty.redis_instance IS 'pigsty redis instance definition';


--===========================================================--
--                   pigsty.minio_cluster                    --
--===========================================================--
DROP VIEW IF EXISTS pigsty.minio_cluster CASCADE;
CREATE OR REPLACE VIEW pigsty.minio_cluster AS
    SELECT cls,
           vars ->> 'minio_cluster' AS name,
           ((gsvc.global || vars) ->> 'minio_port')::INTEGER AS port,
           ((gsvc.global || vars) ->> 'minio_admin_port')::INTEGER AS admin_port,
           (gsvc.global || vars) ->> 'minio_user' AS os_user,
           (gsvc.global || vars) ->> 'minio_node' AS node,
           (gsvc.global || vars) ->> 'minio_data' AS data,
           hosts,vars
    FROM pigsty.group_config,
         (SELECT jsonb_object_agg(key, value) AS global FROM pigsty.global_config WHERE key ~ '^minio') gsvc
    WHERE vars ? 'minio_cluster';
COMMENT ON VIEW pigsty.minio_cluster IS 'pigsty minio cluster definition';

--===========================================================--
--                   pigsty.minio_instance                    --
--===========================================================--
DROP VIEW IF EXISTS pigsty.minio_instance;
CREATE OR REPLACE VIEW pigsty.minio_instance AS
    SELECT cls,
           key                                AS ip,
           cls || '-' || (value ->> 'minio_seq') AS ins,
           (value ->> 'minio_seq')::INTEGER   AS seq,
           replace(replace(node, '${minio_cluster}', cls),'${minio_seq}', (value ->> 'minio_seq')) AS nodename,
           data,
           value                              AS instance
    FROM pigsty.minio_cluster, jsonb_each(hosts) ORDER BY 1, 4;
    COMMENT ON VIEW pigsty.minio_instance IS 'pigsty minio instances';

--===========================================================--
--                   pigsty.etcd_cluster                    --
--===========================================================--
DROP VIEW IF EXISTS pigsty.etcd_cluster CASCADE;
CREATE OR REPLACE VIEW pigsty.etcd_cluster AS
    SELECT cls,
           vars ->> 'etcd_cluster' AS name,
           ((gsvc.global || vars) ->> 'etcd_port')::INTEGER AS port,
           ((gsvc.global || vars) ->> 'etcd_peer_port')::INTEGER AS peer_port,
           (gsvc.global || vars) ->> 'etcd_data' AS data_dir,
           ((gsvc.global || vars) ->> 'etcd_clean')::BOOLEAN AS clean,
           ((gsvc.global || vars) ->> 'etcd_safeguard')::BOOLEAN AS safeguard,
           (SELECT count(*) FROM pigsty.host WHERE cls = 'etcd') AS size,
           ceil((SELECT count(*) FROM pigsty.host WHERE cls = 'etcd') / 2.0) AS quorum,
           hosts,vars
    FROM pigsty.group_config,
         (SELECT jsonb_object_agg(key, value) AS global FROM pigsty.global_config WHERE key ~ '^etcd') gsvc
    WHERE vars ? 'etcd_cluster';

COMMENT ON VIEW pigsty.etcd_cluster IS 'pigsty etcd cluster definition';

DROP VIEW IF EXISTS pigsty.etcd_instance CASCADE;
CREATE OR REPLACE VIEW pigsty.etcd_instance AS
SELECT cls,
       key                                AS ip,
       cls || '-' || (value ->> 'etcd_seq') AS ins,
       (value ->> 'etcd_seq')::INTEGER   AS seq,
       value                              AS instance
FROM pigsty.etcd_cluster, jsonb_each(hosts) ORDER BY 1, 4;
COMMENT ON VIEW pigsty.etcd_instance IS 'pigsty etcd instances';

--===========================================================--
--                          pglog                            --
--===========================================================--
DROP SCHEMA IF EXISTS pglog CASCADE;
CREATE SCHEMA pglog;

CREATE TYPE pglog.level AS ENUM (
    'LOG',
    'INFO',
    'NOTICE',
    'WARNING',
    'ERROR',
    'FATAL',
    'PANIC',
    'DEBUG'
    );
COMMENT
    ON TYPE pglog.level IS 'PostgreSQL Log Level';


CREATE TYPE pglog.cmd_tag AS ENUM (
    -- ps display
    '',
    'initializing',
    'authentication',
    'startup',
    'notify interrupt',
    'idle',
    'idle in transaction',
    'idle in transaction (aborted)',
    'BIND',
    'PARSE',
    '<FASTPATH>',
    -- command tags
    '???',
    'ALTER ACCESS METHOD',
    'ALTER AGGREGATE',
    'ALTER CAST',
    'ALTER COLLATION',
    'ALTER CONSTRAINT',
    'ALTER CONVERSION',
    'ALTER DATABASE',
    'ALTER DEFAULT PRIVILEGES',
    'ALTER DOMAIN',
    'ALTER EVENT TRIGGER',
    'ALTER EXTENSION',
    'ALTER FOREIGN DATA WRAPPER',
    'ALTER FOREIGN TABLE',
    'ALTER FUNCTION',
    'ALTER INDEX',
    'ALTER LANGUAGE',
    'ALTER LARGE OBJECT',
    'ALTER MATERIALIZED VIEW',
    'ALTER OPERATOR',
    'ALTER OPERATOR CLASS',
    'ALTER OPERATOR FAMILY',
    'ALTER POLICY',
    'ALTER PROCEDURE',
    'ALTER PUBLICATION',
    'ALTER ROLE',
    'ALTER ROUTINE',
    'ALTER RULE',
    'ALTER SCHEMA',
    'ALTER SEQUENCE',
    'ALTER SERVER',
    'ALTER STATISTICS',
    'ALTER SUBSCRIPTION',
    'ALTER SYSTEM',
    'ALTER TABLE',
    'ALTER TABLESPACE',
    'ALTER TEXT SEARCH CONFIGURATION',
    'ALTER TEXT SEARCH DICTIONARY',
    'ALTER TEXT SEARCH PARSER',
    'ALTER TEXT SEARCH TEMPLATE',
    'ALTER TRANSFORM',
    'ALTER TRIGGER',
    'ALTER TYPE',
    'ALTER USER MAPPING',
    'ALTER VIEW',
    'ANALYZE',
    'BEGIN',
    'CALL',
    'CHECKPOINT',
    'CLOSE',
    'CLOSE CURSOR',
    'CLOSE CURSOR ALL',
    'CLUSTER',
    'COMMENT',
    'COMMIT',
    'COMMIT PREPARED',
    'COPY',
    'COPY FROM',
    'CREATE ACCESS METHOD',
    'CREATE AGGREGATE',
    'CREATE CAST',
    'CREATE COLLATION',
    'CREATE CONSTRAINT',
    'CREATE CONVERSION',
    'CREATE DATABASE',
    'CREATE DOMAIN',
    'CREATE EVENT TRIGGER',
    'CREATE EXTENSION',
    'CREATE FOREIGN DATA WRAPPER',
    'CREATE FOREIGN TABLE',
    'CREATE FUNCTION',
    'CREATE INDEX',
    'CREATE LANGUAGE',
    'CREATE MATERIALIZED VIEW',
    'CREATE OPERATOR',
    'CREATE OPERATOR CLASS',
    'CREATE OPERATOR FAMILY',
    'CREATE POLICY',
    'CREATE PROCEDURE',
    'CREATE PUBLICATION',
    'CREATE ROLE',
    'CREATE ROUTINE',
    'CREATE RULE',
    'CREATE SCHEMA',
    'CREATE SEQUENCE',
    'CREATE SERVER',
    'CREATE STATISTICS',
    'CREATE SUBSCRIPTION',
    'CREATE TABLE',
    'CREATE TABLE AS',
    'CREATE TABLESPACE',
    'CREATE TEXT SEARCH CONFIGURATION',
    'CREATE TEXT SEARCH DICTIONARY',
    'CREATE TEXT SEARCH PARSER',
    'CREATE TEXT SEARCH TEMPLATE',
    'CREATE TRANSFORM',
    'CREATE TRIGGER',
    'CREATE TYPE',
    'CREATE USER MAPPING',
    'CREATE VIEW',
    'DEALLOCATE',
    'DEALLOCATE ALL',
    'DECLARE CURSOR',
    'DELETE',
    'DISCARD',
    'DISCARD ALL',
    'DISCARD PLANS',
    'DISCARD SEQUENCES',
    'DISCARD TEMP',
    'DO',
    'DROP ACCESS METHOD',
    'DROP AGGREGATE',
    'DROP CAST',
    'DROP COLLATION',
    'DROP CONSTRAINT',
    'DROP CONVERSION',
    'DROP DATABASE',
    'DROP DOMAIN',
    'DROP EVENT TRIGGER',
    'DROP EXTENSION',
    'DROP FOREIGN DATA WRAPPER',
    'DROP FOREIGN TABLE',
    'DROP FUNCTION',
    'DROP INDEX',
    'DROP LANGUAGE',
    'DROP MATERIALIZED VIEW',
    'DROP OPERATOR',
    'DROP OPERATOR CLASS',
    'DROP OPERATOR FAMILY',
    'DROP OWNED',
    'DROP POLICY',
    'DROP PROCEDURE',
    'DROP PUBLICATION',
    'DROP REPLICATION SLOT',
    'DROP ROLE',
    'DROP ROUTINE',
    'DROP RULE',
    'DROP SCHEMA',
    'DROP SEQUENCE',
    'DROP SERVER',
    'DROP STATISTICS',
    'DROP SUBSCRIPTION',
    'DROP TABLE',
    'DROP TABLESPACE',
    'DROP TEXT SEARCH CONFIGURATION',
    'DROP TEXT SEARCH DICTIONARY',
    'DROP TEXT SEARCH PARSER',
    'DROP TEXT SEARCH TEMPLATE',
    'DROP TRANSFORM',
    'DROP TRIGGER',
    'DROP TYPE',
    'DROP USER MAPPING',
    'DROP VIEW',
    'EXECUTE',
    'EXPLAIN',
    'FETCH',
    'GRANT',
    'GRANT ROLE',
    'IMPORT FOREIGN SCHEMA',
    'INSERT',
    'LISTEN',
    'LOAD',
    'LOCK TABLE',
    'MERGE',
    'MOVE',
    'NOTIFY',
    'PREPARE',
    'PREPARE TRANSACTION',
    'REASSIGN OWNED',
    'REFRESH MATERIALIZED VIEW',
    'REINDEX',
    'RELEASE',
    'RESET',
    'REVOKE',
    'REVOKE ROLE',
    'ROLLBACK',
    'ROLLBACK PREPARED',
    'SAVEPOINT',
    'SECURITY LABEL',
    'SELECT',
    'SELECT FOR KEY SHARE',
    'SELECT FOR NO KEY UPDATE',
    'SELECT FOR SHARE',
    'SELECT FOR UPDATE',
    'SELECT INTO',
    'SET',
    'SET CONSTRAINTS',
    'SHOW',
    'START TRANSACTION',
    'TRUNCATE TABLE',
    'UNLISTEN',
    'UPDATE',
    'VACUUM'
    );
COMMENT
    ON TYPE pglog.cmd_tag IS 'PostgreSQL Log Command Tag';

CREATE TYPE pglog.code AS ENUM (
-- Class 00 — Successful Completion
    '00000', -- 	successful_completion
-- Class 01 — Warning
    '01000', -- 	warning
    '0100C', -- 	dynamic_result_sets_returned
    '01008', -- 	implicit_zero_bit_padding
    '01003', -- 	null_value_eliminated_in_set_function
    '01007', -- 	privilege_not_granted
    '01006', -- 	privilege_not_revoked
    '01004', -- 	string_data_right_truncation
    '01P01', -- 	deprecated_feature
-- Class 02 — No Data (this is also a warning class per the SQL standard)
    '02000', -- 	no_data
    '02001', -- 	no_additional_dynamic_result_sets_returned
-- Class 03 — SQL Statement Not Yet Complete
    '03000', -- 	sql_statement_not_yet_complete
-- Class 08 — Connection Exception
    '08000', -- 	connection_exception
    '08003', -- 	connection_does_not_exist
    '08006', -- 	connection_failure
    '08001', -- 	sqlclient_unable_to_establish_sqlconnection
    '08004', -- 	sqlserver_rejected_establishment_of_sqlconnection
    '08007', -- 	transaction_resolution_unknown
    '08P01', -- 	protocol_violation
-- Class 09 — Triggered Action Exception
    '09000', -- 	triggered_action_exception
-- Class 0A — Feature Not Supported
    '0A000', -- 	feature_not_supported
-- Class 0B — Invalid Transaction Initiation
    '0B000', -- 	invalid_transaction_initiation
-- Class 0F — Locator Exception
    '0F000', -- 	locator_exception
    '0F001', -- 	invalid_locator_specification
-- Class 0L — Invalid Grantor
    '0L000', -- 	invalid_grantor
    '0LP01', -- 	invalid_grant_operation
-- Class 0P — Invalid Role Specification
    '0P000', -- 	invalid_role_specification
-- Class 0Z — Diagnostics Exception
    '0Z000', -- 	diagnostics_exception
    '0Z002', -- 	stacked_diagnostics_accessed_without_active_handler
-- Class 20 — Case Not Found
    '20000', -- 	case_not_found
-- Class 21 — Cardinality Violation
    '21000', -- 	cardinality_violation
-- Class 22 — Data Exception
    '22000', -- 	data_exception
    '2202E', -- 	array_subscript_error
    '22021', -- 	character_not_in_repertoire
    '22008', -- 	datetime_field_overflow
    '22012', -- 	division_by_zero
    '22005', -- 	error_in_assignment
    '2200B', -- 	escape_character_conflict
    '22022', -- 	indicator_overflow
    '22015', -- 	interval_field_overflow
    '2201E', -- 	invalid_argument_for_logarithm
    '22014', -- 	invalid_argument_for_ntile_function
    '22016', -- 	invalid_argument_for_nth_value_function
    '2201F', -- 	invalid_argument_for_power_function
    '2201G', -- 	invalid_argument_for_width_bucket_function
    '22018', -- 	invalid_character_value_for_cast
    '22007', -- 	invalid_datetime_format
    '22019', -- 	invalid_escape_character
    '2200D', -- 	invalid_escape_octet
    '22025', -- 	invalid_escape_sequence
    '22P06', -- 	nonstandard_use_of_escape_character
    '22010', -- 	invalid_indicator_parameter_value
    '22023', -- 	invalid_parameter_value
    '22013', -- 	invalid_preceding_or_following_size
    '2201B', -- 	invalid_regular_expression
    '2201W', -- 	invalid_row_count_in_limit_clause
    '2201X', -- 	invalid_row_count_in_result_offset_clause
    '2202H', -- 	invalid_tablesample_argument
    '2202G', -- 	invalid_tablesample_repeat
    '22009', -- 	invalid_time_zone_displacement_value
    '2200C', -- 	invalid_use_of_escape_character
    '2200G', -- 	most_specific_type_mismatch
    '22004', -- 	null_value_not_allowed
    '22002', -- 	null_value_no_indicator_parameter
    '22003', -- 	numeric_value_out_of_range
    '2200H', -- 	sequence_generator_limit_exceeded
    '22026', -- 	string_data_length_mismatch
    '22001', -- 	string_data_right_truncation
    '22011', -- 	substring_error
    '22027', -- 	trim_error
    '22024', -- 	unterminated_c_string
    '2200F', -- 	zero_length_character_string
    '22P01', -- 	floating_point_exception
    '22P02', -- 	invalid_text_representation
    '22P03', -- 	invalid_binary_representation
    '22P04', -- 	bad_copy_file_format
    '22P05', -- 	untranslatable_character
    '2200L', -- 	not_an_xml_document
    '2200M', -- 	invalid_xml_document
    '2200N', -- 	invalid_xml_content
    '2200S', -- 	invalid_xml_comment
    '2200T', -- 	invalid_xml_processing_instruction
    '22030', -- 	duplicate_json_object_key_value
    '22031', -- 	invalid_argument_for_sql_json_datetime_function
    '22032', -- 	invalid_json_text
    '22033', -- 	invalid_sql_json_subscript
    '22034', -- 	more_than_one_sql_json_item
    '22035', -- 	no_sql_json_item
    '22036', -- 	non_numeric_sql_json_item
    '22037', -- 	non_unique_keys_in_a_json_object
    '22038', -- 	singleton_sql_json_item_required
    '22039', -- 	sql_json_array_not_found
    '2203A', -- 	sql_json_member_not_found
    '2203B', -- 	sql_json_number_not_found
    '2203C', -- 	sql_json_object_not_found
    '2203D', -- 	too_many_json_array_elements
    '2203E', -- 	too_many_json_object_members
    '2203F', -- 	sql_json_scalar_required
    '2203G', --	    sql_json_item_cannot_be_cast_to_target_type
-- Class 23 — Integrity Constraint Violation
    '23000', -- 	integrity_constraint_violation
    '23001', -- 	restrict_violation
    '23502', -- 	not_null_violation
    '23503', -- 	foreign_key_violation
    '23505', -- 	unique_violation
    '23514', -- 	check_violation
    '23P01', -- 	exclusion_violation
-- Class 24 — Invalid Cursor State
    '24000', -- 	invalid_cursor_state
-- Class 25 — Invalid Transaction State
    '25000', -- 	invalid_transaction_state
    '25001', -- 	active_sql_transaction
    '25002', -- 	branch_transaction_already_active
    '25008', -- 	held_cursor_requires_same_isolation_level
    '25003', -- 	inappropriate_access_mode_for_branch_transaction
    '25004', -- 	inappropriate_isolation_level_for_branch_transaction
    '25005', -- 	no_active_sql_transaction_for_branch_transaction
    '25006', -- 	read_only_sql_transaction
    '25007', -- 	schema_and_data_statement_mixing_not_supported
    '25P01', -- 	no_active_sql_transaction
    '25P02', -- 	in_failed_sql_transaction
    '25P03', -- 	idle_in_transaction_session_timeout
-- Class 26 — Invalid SQL Statement Name
    '26000', -- 	invalid_sql_statement_name
-- Class 27 — Triggered Data Change Violation
    '27000', -- 	triggered_data_change_violation
-- Class 28 — Invalid Authorization Specification
    '28000', -- 	invalid_authorization_specification
    '28P01', -- 	invalid_password
-- Class 2B — Dependent Privilege Descriptors Still Exist
    '2B000', -- 	dependent_privilege_descriptors_still_exist
    '2BP01', -- 	dependent_objects_still_exist
-- Class 2D — Invalid Transaction Termination
    '2D000', -- 	invalid_transaction_termination
-- Class 2F — SQL Routine Exception
    '2F000', -- 	sql_routine_exception
    '2F005', -- 	function_executed_no_return_statement
    '2F002', -- 	modifying_sql_data_not_permitted
    '2F003', -- 	prohibited_sql_statement_attempted
    '2F004', -- 	reading_sql_data_not_permitted
-- Class 34 — Invalid Cursor Name
    '34000', -- 	invalid_cursor_name
-- Class 38 — External Routine Exception
    '38000', -- 	external_routine_exception
    '38001', -- 	containing_sql_not_permitted
    '38002', -- 	modifying_sql_data_not_permitted
    '38003', -- 	prohibited_sql_statement_attempted
    '38004', -- 	reading_sql_data_not_permitted
-- Class 39 — External Routine Invocation Exception
    '39000', -- 	external_routine_invocation_exception
    '39001', -- 	invalid_sqlstate_returned
    '39004', -- 	null_value_not_allowed
    '39P01', -- 	trigger_protocol_violated
    '39P02', -- 	srf_protocol_violated
    '39P03', -- 	event_trigger_protocol_violated
-- Class 3B — Savepoint Exception
    '3B000', --     savepoint_exception
    '3B001', -- 	invalid_savepoint_specification
-- Class 3D — Invalid Catalog Name
    '3D000', -- 	invalid_catalog_name
-- Class 3F — Invalid Schema Name
    '3F000', -- 	invalid_schema_name
-- Class 40 — Transaction Rollback
    '40000', --     transaction_rollback
    '40002', -- 	transaction_integrity_constraint_violation
    '40001', -- 	serialization_failure
    '40003', -- 	statement_completion_unknown
    '40P01', -- 	deadlock_detected
-- Class 42 — Syntax Error or Access Rule Violation
    '42000', -- 	syntax_error_or_access_rule_violation
    '42601', -- 	syntax_error
    '42501', -- 	insufficient_privilege
    '42846', -- 	cannot_coerce
    '42803', -- 	grouping_error
    '42P20', -- 	windowing_error
    '42P19', -- 	invalid_recursion
    '42830', -- 	invalid_foreign_key
    '42602', -- 	invalid_name
    '42622', -- 	name_too_long
    '42939', -- 	reserved_name
    '42804', -- 	datatype_mismatch
    '42P18', -- 	indeterminate_datatype
    '42P21', -- 	collation_mismatch
    '42P22', -- 	indeterminate_collation
    '42809', -- 	wrong_object_type
    '428C9', -- 	generated_always
    '42703', -- 	undefined_column
    '42883', -- 	undefined_function
    '42P01', -- 	undefined_table
    '42P02', -- 	undefined_parameter
    '42704', -- 	undefined_object
    '42701', -- 	duplicate_column
    '42P03', -- 	duplicate_cursor
    '42P04', -- 	duplicate_database
    '42723', -- 	duplicate_function
    '42P05', -- 	duplicate_prepared_statement
    '42P06', -- 	duplicate_schema
    '42P07', -- 	duplicate_table
    '42712', -- 	duplicate_alias
    '42710', -- 	duplicate_object
    '42702', -- 	ambiguous_column
    '42725', -- 	ambiguous_function
    '42P08', -- 	ambiguous_parameter
    '42P09', -- 	ambiguous_alias
    '42P10', -- 	invalid_column_reference
    '42611', -- 	invalid_column_definition
    '42P11', -- 	invalid_cursor_definition
    '42P12', -- 	invalid_database_definition
    '42P13', -- 	invalid_function_definition
    '42P14', -- 	invalid_prepared_statement_definition
    '42P15', -- 	invalid_schema_definition
    '42P16', -- 	invalid_table_definition
    '42P17', -- 	invalid_object_definition
-- Class 44 — WITH CHECK OPTION Violation
    '44000', -- 	with_check_option_violation
-- Class 53 — Insufficient Resources
    '53000', -- 	insufficient_resources
    '53100', -- 	disk_full
    '53200', -- 	out_of_memory
    '53300', -- 	too_many_connections
    '53400', -- 	configuration_limit_exceeded
-- Class 54 — Program Limit Exceeded
    '54000', -- 	program_limit_exceeded
    '54001', -- 	statement_too_complex
    '54011', -- 	too_many_columns
    '54023', -- 	too_many_arguments
-- Class 55 — Object Not In Prerequisite State
    '55000', -- 	object_not_in_prerequisite_state
    '55006', -- 	object_in_use
    '55P02', -- 	cant_change_runtime_param
    '55P03', -- 	lock_not_available
    '55P04', -- 	unsafe_new_enum_value_usage
-- Class 57 — Operator Intervention
    '57000', -- 	operator_intervention
    '57014', -- 	query_canceled
    '57P01', -- 	admin_shutdown
    '57P02', -- 	crash_shutdown
    '57P03', -- 	cannot_connect_now
    '57P04', -- 	database_dropped
    '57P05', -- 	idle_session_timeout
-- Class 58 — System Error (errors external to PostgreSQL itself)
    '58000', -- 	system_error
    '58030', -- 	io_error
    '58P01', -- 	undefined_file
    '58P02', -- 	duplicate_file
-- Class 72 — Snapshot Failure
    '72000', -- 	snapshot_too_old
-- Class F0 — Configuration File Error
    'F0000', -- 	config_file_error
    'F0001', -- 	lock_file_exists
-- Class HV — Foreign Data Wrapper Error (SQL/MED)
    'HV000', -- 	fdw_error
    'HV005', -- 	fdw_column_name_not_found
    'HV002', -- 	fdw_dynamic_parameter_value_needed
    'HV010', -- 	fdw_function_sequence_error
    'HV021', -- 	fdw_inconsistent_descriptor_information
    'HV024', -- 	fdw_invalid_attribute_value
    'HV007', -- 	fdw_invalid_column_name
    'HV008', -- 	fdw_invalid_column_number
    'HV004', -- 	fdw_invalid_data_type
    'HV006', -- 	fdw_invalid_data_type_descriptors
    'HV091', -- 	fdw_invalid_descriptor_field_identifier
    'HV00B', -- 	fdw_invalid_handle
    'HV00C', -- 	fdw_invalid_option_index
    'HV00D', -- 	fdw_invalid_option_name
    'HV090', -- 	fdw_invalid_string_length_or_buffer_length
    'HV00A', -- 	fdw_invalid_string_format
    'HV009', -- 	fdw_invalid_use_of_null_pointer
    'HV014', -- 	fdw_too_many_handles
    'HV001', -- 	fdw_out_of_memory
    'HV00P', -- 	fdw_no_schemas
    'HV00J', -- 	fdw_option_name_not_found
    'HV00K', -- 	fdw_reply_handle
    'HV00Q', -- 	fdw_schema_not_found
    'HV00R', -- 	fdw_table_not_found
    'HV00L', -- 	fdw_unable_to_create_execution
    'HV00M', -- 	fdw_unable_to_create_reply
    'HV00N', -- 	fdw_unable_to_establish_connection
-- Class P0 — PL/pgSQL Error
    'P0000', -- 	plpgsql_error
    'P0001', -- 	raise_exception
    'P0002', -- 	no_data_found
    'P0003', -- 	too_many_rows
    'P0004', -- 	assert_failure
-- Class XX — Internal Error
    'XX000', -- 	internal_error
    'XX001', -- 	data_corrupted
    'XX002'  -- 	index_corrupted
);
COMMENT ON TYPE pglog.code IS 'PostgreSQL Log SQL State Code (v14)';


DROP TABLE IF EXISTS pglog.sample;
CREATE TABLE pglog.sample
(
    ts       TIMESTAMPTZ, -- ts
    username TEXT,        -- usename
    datname  TEXT,        -- datname
    pid      INTEGER,     -- process_id
    conn     TEXT,        -- connect_from
    sid      TEXT,        -- session id
    sln      BIGINT,      -- session line number
    cmd_tag  TEXT,        -- command tag
    stime    TIMESTAMPTZ, -- session start time
    vxid     TEXT,        -- virtual transaction id
    txid     bigint,      -- transaction id
    level    pglog.level, -- log level
    code     pglog.code,  -- sql state code
    msg      TEXT,        -- message
    detail   TEXT,
    hint     TEXT,
    iq       TEXT,        -- internal query
    iqp      INTEGER,     -- internal query position
    context  TEXT,
    q        TEXT,        -- query
    qp       INTEGER,     -- query position
    location TEXT,        -- location
    appname  TEXT,        -- application name
    PRIMARY KEY (sid, sln)
);
CREATE INDEX ON pglog.sample (ts);
CREATE INDEX ON pglog.sample (username);
CREATE INDEX ON pglog.sample (datname);
CREATE INDEX ON pglog.sample (code);
CREATE INDEX ON pglog.sample (level);
COMMENT ON TABLE pglog.sample IS 'PostgreSQL CSVLOG sample for Pigsty PGLOG analysis';

-- child tables
CREATE TABLE pglog.sample12() INHERITS (pglog.sample);
CREATE TABLE pglog.sample13(backend TEXT) INHERITS (pglog.sample);
CREATE TABLE pglog.sample14(backend TEXT, leader_pid INTEGER, query_id BIGINT) INHERITS (pglog.sample);
COMMENT ON TABLE pglog.sample12 IS 'PostgreSQL 12- CSVLOG sample';
COMMENT ON TABLE pglog.sample13 IS 'PostgreSQL 13 CSVLOG sample';
COMMENT ON TABLE pglog.sample14 IS 'PostgreSQL 14/15 CSVLOG';









--===========================================================--
--                 default config entries                    --
--===========================================================--
DROP VIEW IF EXISTS pigsty.parameters;
CREATE OR REPLACE VIEW pigsty.parameters AS
    SELECT id AS "ID",
           format('[`%s`](#%s)', key, key)                AS "Name",
           format('[`%s`](#%s)', module, lower(module))   AS "Module",
           format('[`%s`](#%s)', section, lower(section)) AS "Section",
           type                                           AS "Type",
           level                                          AS "Level",
           summary                                        AS "Comment"
    FROM pigsty.default_var
    ORDER BY id;

TRUNCATE pigsty.default_var;
INSERT INTO pigsty.default_var VALUES

-- INFRA PARAMETERS
(101, 'version', '"v2.2.0"', 'INFRA', 'META', 'string', 'G', 'pigsty version string', NULL),
(102, 'admin_ip', '"10.10.10.10"', 'INFRA', 'META', 'ip', 'G', 'admin node ip address', NULL),
(103, 'region', '"default"', 'INFRA', 'META', 'enum', 'G', 'upstream mirror region: default,china,europe', NULL),
(104, 'proxy_env', '{"no_proxy": "localhost,127.0.0.1,10.0.0.0/8,192.168.0.0/16,*.pigsty,*.aliyun.com,mirrors.*,*.myqcloud.com,*.tsinghua.edu.cn"}', 'INFRA', 'META', 'dict', 'G', 'global proxy env when downloading packages', NULL),
(105, 'ca_method', '"create"', 'INFRA', 'CA', 'enum', 'G', 'create,recreate,copy, create by default', NULL),
(106, 'ca_cn', '"pigsty-ca"', 'INFRA', 'CA', 'string', 'G', 'ca common name, fixed as pigsty-ca', NULL),
(107, 'cert_validity', '"7300d"', 'INFRA', 'CA', 'interval', 'G', 'cert validity, 20 years by default', NULL),
(108, 'infra_seq', NULL, 'INFRA', 'INFRA_ID', 'int', 'I', 'infra node identity, REQUIRED', NULL),
(109, 'infra_portal', '{"home": {"domain": "h.pigsty"}, "loki": {"endpoint": "${admin_ip}:3100"}, "grafana": {"domain": "g.pigsty", "endpoint": "${admin_ip}:3000", "websocket": true}, "blackbox": {"endpoint": "${admin_ip}:9115"}, "prometheus": {"domain": "p.pigsty", "endpoint": "${admin_ip}:9090"}, "alertmanager": {"domain": "a.pigsty", "endpoint": "${admin_ip}:9093"}}', 'INFRA', 'INFRA_ID', 'dict', 'G', 'infra services exposed via portal', NULL),

(110, 'repo_enabled', 'true', 'INFRA', 'REPO', 'bool', 'G/I', 'create a yum repo on this infra node?', NULL),
(111, 'repo_home', '"/www"', 'INFRA', 'REPO', 'path', 'G', 'repo home dir, `/www` by default', NULL),
(112, 'repo_name', '"pigsty"', 'INFRA', 'REPO', 'string', 'G', 'repo name, pigsty by default', NULL),
(113, 'repo_endpoint', '"http://${admin_ip}:80"', 'INFRA', 'REPO', 'url', 'G', 'access point to this repo by domain or ip:port', NULL),
(114, 'repo_remove', 'true', 'INFRA', 'REPO', 'bool', 'G/A', 'remove existing upstream repo', NULL),
(115, 'repo_modules', '"node,pgsql,infra"', 'INFRA', 'REPO', 'string', 'G/A', 'which repo modules are installed in repo_upstream', NULL),
(116, 'repo_upstream', '[{"name": "base", "module": "node", "baseurl": {"china": "https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/os/$basearch/", "europe": "https://mirrors.xtom.de/centos/$releasever/os/$basearch/", "default": "http://mirror.centos.org/centos/$releasever/os/$basearch/"}, "releases": [7], "description": "EL 7 Base"}, {"name": "updates", "module": "node", "baseurl": {"china": "https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/updates/$basearch/", "europe": "https://mirrors.xtom.de/centos/$releasever/updates/$basearch/", "default": "http://mirror.centos.org/centos/$releasever/updates/$basearch/"}, "releases": [7], "description": "EL 7 Updates"}, {"name": "extras", "module": "node", "baseurl": {"china": "https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/extras/$basearch/", "europe": "https://mirrors.xtom.de/centos/$releasever/extras/$basearch/", "default": "http://mirror.centos.org/centos/$releasever/extras/$basearch/"}, "releases": [7], "description": "EL 7 Extras"}, {"name": "epel", "module": "node", "baseurl": {"china": "https://mirrors.tuna.tsinghua.edu.cn/epel/$releasever/$basearch/", "europe": "https://mirrors.xtom.de/epel/$releasever/$basearch/", "default": "http://download.fedoraproject.org/pub/epel/$releasever/$basearch/"}, "releases": [7], "description": "EL 7 EPEL"}, {"name": "centos-sclo", "module": "node", "baseurl": {"china": "https://mirrors.aliyun.com/centos/$releasever/sclo/$basearch/sclo/", "europe": "https://mirrors.xtom.de/centos/$releasever/sclo/$basearch/sclo/", "default": "http://mirror.centos.org/centos/$releasever/sclo/$basearch/sclo/"}, "releases": [7], "description": "EL 7 SCLo"}, {"name": "centos-sclo-rh", "module": "node", "baseurl": {"china": "https://mirrors.aliyun.com/centos/$releasever/sclo/$basearch/rh/", "europe": "https://mirrors.xtom.de/centos/$releasever/sclo/$basearch/rh/", "default": "http://mirror.centos.org/centos/$releasever/sclo/$basearch/rh/"}, "releases": [7], "description": "EL 7 SCLo rh"}, {"name": "baseos", "module": "node", "baseurl": {"china": "https://mirrors.aliyun.com/rockylinux/$releasever/BaseOS/$basearch/os/", "europe": "https://mirrors.xtom.de/rocky/$releasever/BaseOS/$basearch/os/", "default": "https://dl.rockylinux.org/pub/rocky/$releasever/BaseOS/$basearch/os/"}, "releases": [8, 9], "description": "EL 8+ BaseOS"}, {"name": "appstream", "module": "node", "baseurl": {"china": "https://mirrors.aliyun.com/rockylinux/$releasever/AppStream/$basearch/os/", "europe": "https://mirrors.xtom.de/rocky/$releasever/AppStream/$basearch/os/", "default": "https://dl.rockylinux.org/pub/rocky/$releasever/AppStream/$basearch/os/"}, "releases": [8, 9], "description": "EL 8+ AppStream"}, {"name": "extras", "module": "node", "baseurl": {"china": "https://mirrors.aliyun.com/rockylinux/$releasever/extras/$basearch/os/", "europe": "https://mirrors.xtom.de/rocky/$releasever/extras/$basearch/os/", "default": "https://dl.rockylinux.org/pub/rocky/$releasever/extras/$basearch/os/"}, "releases": [8, 9], "description": "EL 8+ Extras"}, {"name": "epel", "module": "node", "baseurl": {"china": "https://mirrors.tuna.tsinghua.edu.cn/epel/$releasever/Everything/$basearch/", "europe": "https://mirrors.xtom.de/epel/$releasever/Everything/$basearch/", "default": "http://download.fedoraproject.org/pub/epel/$releasever/Everything/$basearch/"}, "releases": [8, 9], "description": "EL 8+ EPEL"}, {"name": "powertools", "module": "node", "baseurl": {"china": "https://mirrors.aliyun.com/rockylinux/$releasever/PowerTools/$basearch/os/", "europe": "https://mirrors.xtom.de/rocky/$releasever/PowerTools/$basearch/os/", "default": "https://dl.rockylinux.org/pub/rocky/$releasever/PowerTools/$basearch/os/"}, "releases": [8], "description": "EL 8 PowerTools"}, {"name": "crb", "module": "node", "baseurl": {"china": "https://mirrors.aliyun.com/rockylinux/$releasever/CRB/$basearch/os/", "europe": "https://mirrors.xtom.de/rocky/$releasever/CRB/$basearch/os/", "default": "https://dl.rockylinux.org/pub/rocky/$releasever/CRB/$basearch/os/"}, "releases": [9], "description": "EL 9 CRB"}, {"name": "pgdg-common", "module": "pgsql", "baseurl": {"china": "https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/redhat/rhel-$releasever-$basearch", "europe": "https://mirrors.xtom.de/postgresql/repos/yum/common/redhat/rhel-$releasever-$basearch", "default": "https://download.postgresql.org/pub/repos/yum/common/redhat/rhel-$releasever-$basearch"}, "releases": [7, 8, 9], "description": "PostgreSQL Common"}, {"name": "pgdg-extras", "module": "pgsql", "baseurl": {"china": "https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/pgdg-rhel$releasever-extras/redhat/rhel-$releasever-$basearch", "europe": "https://mirrors.xtom.de/postgresql/repos/yum/common/pgdg-rhel$releasever-extras/redhat/rhel-$releasever-$basearch", "default": "https://download.postgresql.org/pub/repos/yum/common/pgdg-rhel$releasever-extras/redhat/rhel-$releasever-$basearch"}, "releases": [7, 8, 9], "description": "PostgreSQL Extra"}, {"name": "pgdg-el8fix", "module": "pgsql", "baseurl": {"china": "https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/pgdg-centos8-sysupdates/redhat/rhel-8-x86_64/", "europe": "https://mirrors.xtom.de/postgresql/repos/yum/common/pgdg-centos8-sysupdates/redhat/rhel-8-x86_64/", "default": "https://download.postgresql.org/pub/repos/yum/common/pgdg-centos8-sysupdates/redhat/rhel-8-x86_64/"}, "releases": [8], "description": "PostgreSQL EL8FIX"}, {"name": "pgdg-el9fix", "module": "pgsql", "baseurl": {"china": "https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/pgdg-rocky9-sysupdates/redhat/rhel-9-x86_64/", "europe": "https://mirrors.xtom.de/postgresql/repos/yum/common/pgdg-rocky9-sysupdates/redhat/rhel-9-x86_64/", "default": "https://download.postgresql.org/pub/repos/yum/common/pgdg-rocky9-sysupdates/redhat/rhel-9-x86_64/"}, "releases": [9], "description": "PostgreSQL EL9FIX"}, {"name": "pgdg12", "module": "pgsql", "baseurl": {"china": "https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/12/redhat/rhel-$releasever-$basearch", "europe": "https://mirrors.xtom.de/postgresql/repos/yum/12/redhat/rhel-$releasever-$basearch", "default": "https://download.postgresql.org/pub/repos/yum/12/redhat/rhel-$releasever-$basearch"}, "releases": [7, 8, 9], "description": "PostgreSQL 12"}, {"name": "pgdg13", "module": "pgsql", "baseurl": {"china": "https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/13/redhat/rhel-$releasever-$basearch", "europe": "https://mirrors.xtom.de/postgresql/repos/yum/13/redhat/rhel-$releasever-$basearch", "default": "https://download.postgresql.org/pub/repos/yum/13/redhat/rhel-$releasever-$basearch"}, "releases": [7, 8, 9], "description": "PostgreSQL 13"}, {"name": "pgdg14", "module": "pgsql", "baseurl": {"china": "https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/14/redhat/rhel-$releasever-$basearch", "europe": "https://mirrors.xtom.de/postgresql/repos/yum/14/redhat/rhel-$releasever-$basearch", "default": "https://download.postgresql.org/pub/repos/yum/14/redhat/rhel-$releasever-$basearch"}, "releases": [7, 8, 9], "description": "PostgreSQL 14"}, {"name": "pgdg15", "module": "pgsql", "baseurl": {"china": "https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/15/redhat/rhel-$releasever-$basearch", "europe": "https://mirrors.xtom.de/postgresql/repos/yum/15/redhat/rhel-$releasever-$basearch", "default": "https://download.postgresql.org/pub/repos/yum/15/redhat/rhel-$releasever-$basearch"}, "releases": [7, 8, 9], "description": "PostgreSQL 15"}, {"name": "pgdg16beta", "module": "pgsql", "baseurl": {"china": "https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/testing/16/redhat/rhel-$releasever-$basearch", "europe": "https://mirrors.xtom.de/postgresql/repos/yum/testing/16/redhat/rhel-$releasever-$basearch", "default": "https://download.postgresql.org/pub/repos/yum/testing/16/redhat/rhel-$releasever-$basearch"}, "releases": [7, 8, 9], "description": "PostgreSQL 16 Beta"}, {"name": "timescaledb", "module": "pgsql", "baseurl": {"default": "https://packagecloud.io/timescale/timescaledb/el/$releasever/$basearch"}, "releases": [7, 8, 9], "description": "TimescaleDB"}, {"name": "nginx", "module": "infra", "baseurl": {"default": "https://nginx.org/packages/centos/$releasever/$basearch/"}, "releases": [7, 8, 9], "description": "Nginx Repo"}, {"name": "docker-ce", "module": "infra", "baseurl": {"china": "https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/$releasever/$basearch/stable", "europe": "https://mirrors.xtom.de/docker-ce/linux/centos/$releasever/$basearch/stable", "default": "https://download.docker.com/linux/centos/$releasever/$basearch/stable"}, "releases": [7, 8, 9], "description": "Docker CE"}, {"name": "pigsty-el", "module": "infra", "baseurl": {"default": "http://get.pigsty.cc/yum/el.x86_64"}, "releases": [7, 8, 9], "description": "Pigsty EL Common"}, {"name": "pigsty-misc", "module": "infra", "baseurl": {"default": "http://get.pigsty.cc/yum/el$releasever.$basearch"}, "releases": [7, 8, 9], "description": "Pigsty EL Misc"}, {"name": "prometheus", "module": "infra", "baseurl": {"default": "https://packagecloud.io/prometheus-rpm/release/el/$releasever/$basearch"}, "releases": [7, 8, 9], "description": "Prometheus"}, {"name": "grafana", "module": "infra", "baseurl": {"default": "https://rpm.grafana.com"}, "releases": [7, 8, 9], "description": "Grafana"}]', 'INFRA', 'REPO', 'upstream[]', 'G', 'where to download upstream packages', NULL),
(117, 'repo_packages', '["ansible python3 python3-pip python3-requests python3.11-jmespath dnf-utils modulemd-tools", "grafana loki logcli promtail prometheus2 alertmanager karma pushgateway node_exporter blackbox_exporter nginx_exporter redis_exporter mysqld_exporter karma", "redis etcd minio mcli haproxy vip-manager pg_exporter nginx createrepo_c sshpass chrony dnsmasq docker-ce docker-compose-plugin flamegraph", "lz4 unzip bzip2 zlib yum pv jq git ncdu make patch bash lsof wget uuid tuned perf nvme-cli numactl grubby sysstat iotop htop rsync tcpdump", "netcat socat ftp lrzsz net-tools ipvsadm bind-utils telnet audit ca-certificates openssl openssh-clients readline vim-minimal keepalived ferretdb", "postgresql13* wal2json_13* pg_repack_13* passwordcheck_cracklib_13* postgresql12* wal2json_12* pg_repack_12* passwordcheck_cracklib_12* postgresql16* timescaledb-tools", "postgresql15 postgresql15* citus_15* pglogical_15* wal2json_15* pg_repack_15* pgvector_15* timescaledb-2-postgresql-15* postgis33_15* passwordcheck_cracklib_15* pg_cron_15*", "postgresql14 postgresql14* citus_14* pglogical_14* wal2json_14* pg_repack_14* pgvector_14* timescaledb-2-postgresql-14* postgis33_14* passwordcheck_cracklib_14* pg_cron_14*", "patroni patroni-etcd pgbouncer pgbadger pgbackrest pgloader pg_activity pg_partman_15 pg_permissions_15 pgaudit17_15 pgexportdoc_15 pgimportdoc_15 pg_statement_rollback_15*", "orafce_15* mysqlcompat_15 mongo_fdw_15* tds_fdw_15* mysql_fdw_15 hdfs_fdw_15 sqlite_fdw_15 pgbouncer_fdw_15 multicorn2_15* powa_15* pg_stat_kcache_15* pg_stat_monitor_15* pg_qualstats_15 pg_track_settings_15 pg_wait_sampling_15 system_stats_15", "plprofiler_15* plproxy_15 plsh_15* pldebugger_15 plpgsql_check_15*  pgtt_15 pgq_15* pgsql_tweaks_15 count_distinct_15 hypopg_15 timestamp9_15* semver_15* prefix_15* rum_15 geoip_15 periods_15 ip4r_15 tdigest_15 hll_15 pgmp_15 extra_window_functions_15 topn_15", "pg_background_15 e-maj_15 pg_catcheck_15 pg_prioritize_15 pgcopydb_15 pg_filedump_15 pgcryptokey_15 logerrors_15 pg_top_15 pg_comparator_15 pg_ivm_15* pgsodium_15* pgfincore_15* ddlx_15 credcheck_15 safeupdate_15 pg_squeeze_15* pg_fkpart_15 pg_jobmon_15"]', 'INFRA', 'REPO', 'string[]', 'G', 'which packages to be included', NULL),
(118, 'repo_url_packages', '["http://get.pigsty.cc/rpm/pev.html", "http://get.pigsty.cc/rpm/chart.tgz"]', 'INFRA', 'REPO', 'string[]', 'G', 'extra packages from url', NULL),

(120, 'infra_packages', '["grafana,loki,logcli,promtail,prometheus2,alertmanager,karma,pushgateway", "node_exporter,blackbox_exporter,nginx_exporter,redis_exporter,pg_exporter", "nginx,dnsmasq,ansible,postgresql15,redis,mcli,python3-requests"]', 'INFRA', 'INFRA_PACKAGE', 'string[]', 'G', 'packages to be installed on infra nodes', NULL),
(121, 'infra_packages_pip', '""', 'INFRA', 'INFRA_PACKAGE', 'string', 'G', 'pip installed packages for infra nodes', NULL),

(130, 'nginx_enabled', 'true', 'INFRA', 'NGINX', 'bool', 'G/I', 'enable nginx on this infra node?', NULL),
(131, 'nginx_exporter_enabled', 'true', 'INFRA', 'NGINX', 'bool', 'G/I', 'enable nginx_exporter on this infra node?', NULL),
(132, 'nginx_sslmode', '"enable"', 'INFRA', 'NGINX', 'enum', 'G', 'nginx ssl mode? disable,enable,enforce', NULL),
(133, 'nginx_home', '"/www"', 'INFRA', 'NGINX', 'path', 'G', 'nginx content dir, `/www` by default', NULL),
(134, 'nginx_port', '80', 'INFRA', 'NGINX', 'port', 'G', 'nginx listen port, 80 by default', NULL),
(135, 'nginx_ssl_port', '443', 'INFRA', 'NGINX', 'port', 'G', 'nginx ssl listen port, 443 by default', NULL),
(136, 'nginx_navbar', '[{"url": "/ca.crt", "desc": "pigsty self-signed ca.crt", "name": "CA Cert"}, {"url": "/pigsty", "desc": "local yum repo packages", "name": "Package"}, {"url": "/pigsty/pev.html", "desc": "postgres explain visualizer", "name": "Explain"}, {"url": "/logs", "desc": "postgres raw csv logs", "name": "PG Logs"}, {"url": "/report", "desc": "pgbadger summary report", "name": "Reports"}]', 'INFRA', 'NGINX', 'index[]', 'G', 'nginx index page navigation links', NULL),

(140, 'dns_enabled', 'true', 'INFRA', 'DNS', 'bool', 'G/I', 'setup dnsmasq on this infra node?', NULL),
(141, 'dns_port', '53', 'INFRA', 'DNS', 'port', 'G', 'dns server listen port, 53 by default', NULL),
(142, 'dns_records', '["${admin_ip} h.pigsty a.pigsty p.pigsty g.pigsty", "${admin_ip} api.pigsty adm.pigsty cli.pigsty ddl.pigsty lab.pigsty git.pigsty sss.pigsty wiki.pigsty"]', 'INFRA', 'DNS', 'string[]', 'G', 'dynamic dns records resolved by dnsmasq', NULL),

(150, 'prometheus_enabled', 'true', 'INFRA', 'PROMETHEUS', 'bool', 'G/I', 'enable prometheus on this infra node?', NULL),
(151, 'prometheus_clean', 'true', 'INFRA', 'PROMETHEUS', 'bool', 'G/A', 'clean prometheus data during init?', NULL),
(152, 'prometheus_data', '"/data/prometheus"', 'INFRA', 'PROMETHEUS', 'path', 'G', 'prometheus data dir, `/data/prometheus` by default', NULL),
(153, 'prometheus_sd_interval', '"5s"', 'INFRA', 'PROMETHEUS', 'interval', 'G', 'prometheus target refresh interval, 5s by default', NULL),
(154, 'prometheus_scrape_interval', '"10s"', 'INFRA', 'PROMETHEUS', 'interval', 'G', 'prometheus scrape & eval interval, 10s by default', NULL),
(155, 'prometheus_scrape_timeout', '"8s"', 'INFRA', 'PROMETHEUS', 'interval', 'G', 'prometheus global scrape timeout, 8s by default', NULL),
(156, 'prometheus_options', '"--storage.tsdb.retention.time=15d"', 'INFRA', 'PROMETHEUS', 'arg', 'G', 'prometheus extra server options', NULL),
(157, 'pushgateway_enabled', 'true', 'INFRA', 'PROMETHEUS', 'bool', 'G/I', 'setup pushgateway on this infra node?', NULL),
(158, 'pushgateway_options', '"--persistence.interval=1m"', 'INFRA', 'PROMETHEUS', 'arg', 'G', 'pushgateway extra server options', NULL),
(159, 'blackbox_enabled', 'true', 'INFRA', 'PROMETHEUS', 'bool', 'G/I', 'setup blackbox_exporter on this infra node?', NULL),
(160, 'blackbox_options', '""', 'INFRA', 'PROMETHEUS', 'arg', 'G', 'blackbox_exporter extra server options', NULL),
(161, 'alertmanager_enabled', 'true', 'INFRA', 'PROMETHEUS', 'bool', 'G/I', 'setup alertmanager on this infra node?', NULL),
(162, 'alertmanager_options', '""', 'INFRA', 'PROMETHEUS', 'arg', 'G', 'alertmanager extra server options', NULL),
(163, 'exporter_metrics_path', '"/metrics"', 'INFRA', 'PROMETHEUS', 'path', 'G', 'exporter metric path, `/metrics` by default', NULL),
(164, 'exporter_install', '"none"', 'INFRA', 'PROMETHEUS', 'enum', 'G', 'how to install exporter? none,yum,binary', NULL),
(165, 'exporter_repo_url', '""', 'INFRA', 'PROMETHEUS', 'url', 'G', 'exporter repo file url if install exporter via yum', NULL),

(170, 'grafana_enabled', 'true', 'INFRA', 'GRAFANA', 'bool', 'G/I', 'enable grafana on this infra node?', NULL),
(171, 'grafana_clean', 'true', 'INFRA', 'GRAFANA', 'bool', 'G/A', 'clean grafana data during init?', NULL),
(172, 'grafana_admin_username', '"admin"', 'INFRA', 'GRAFANA', 'username', 'G', 'grafana admin username, `admin` by default', NULL),
(173, 'grafana_admin_password', '"pigsty"', 'INFRA', 'GRAFANA', 'password', 'G', 'grafana admin password, `pigsty` by default', NULL),
(174, 'grafana_plugin_cache', '"/www/pigsty/plugins.tgz"', 'INFRA', 'GRAFANA', 'path', 'G', 'path to grafana plugins cache tarball', NULL),
(175, 'grafana_plugin_list', '["volkovlabs-echarts-panel", "volkovlabs-image-panel", "volkovlabs-form-panel", "volkovlabs-grapi-datasource", "marcusolsson-dynamictext-panel", "marcusolsson-treemap-panel", "marcusolsson-calendar-panel", "marcusolsson-static-datasource"]', 'INFRA', 'GRAFANA', 'string[]', 'G', 'grafana plugins to be downloaded with grafana-cli', NULL),
(176, 'loki_enabled', 'true', 'INFRA', 'LOKI', 'bool', 'G/I', 'enable loki on this infra node?', NULL),
(177, 'loki_clean', 'false', 'INFRA', 'LOKI', 'bool', 'G/A', 'whether remove existing loki data?', NULL),
(178, 'loki_data', '"/data/loki"', 'INFRA', 'LOKI', 'path', 'G', 'loki data dir, `/data/loki` by default', NULL),
(179, 'loki_retention', '"15d"', 'INFRA', 'LOKI', 'interval', 'G', 'loki log retention period, 15d by default', NULL),

-- NODE PARAMETERS
(201, 'nodename', NULL, 'NODE', 'NODE_ID', 'string', 'I', 'node instance identity, use hostname if missing, optional', NULL),
(202, 'node_cluster', '"nodes"', 'NODE', 'NODE_ID', 'string', 'C', 'node cluster identity, use ''nodes'' if missing, optional', NULL),
(203, 'nodename_overwrite', 'true', 'NODE', 'NODE_ID', 'bool', 'C', 'overwrite node''s hostname with nodename?', NULL),
(204, 'nodename_exchange', 'false', 'NODE', 'NODE_ID', 'bool', 'C', 'exchange nodename among play hosts?', NULL),
(205, 'node_id_from_pg', 'true', 'NODE', 'NODE_ID', 'bool', 'C', 'use postgres identity as node identity if applicable?', NULL),

(210, 'node_default_etc_hosts', '["${admin_ip} h.pigsty a.pigsty p.pigsty g.pigsty"]', 'NODE', 'NODE_DNS', 'string[]', 'G', 'static dns records in `/etc/hosts`', NULL),
(211, 'node_etc_hosts', '[]', 'NODE', 'NODE_DNS', 'string[]', 'C', 'extra static dns records in `/etc/hosts`', NULL),
(212, 'node_dns_method', '"add"', 'NODE', 'NODE_DNS', 'enum', 'C', 'how to handle dns servers: add,none,overwrite', NULL),
(213, 'node_dns_servers', '["${admin_ip}"]', 'NODE', 'NODE_DNS', 'string[]', 'C', 'dynamic nameserver in `/etc/resolv.conf`', NULL),
(214, 'node_dns_options', '["options single-request-reopen timeout:1"]', 'NODE', 'NODE_DNS', 'string[]', 'C', 'dns resolv options in `/etc/resolv.conf`', NULL),

(220, 'node_repo_method', '"local"', 'NODE', 'NODE_PACKAGE', 'enum', 'C/A', 'how to setup node repo: none,local,public,both', NULL),
(221, 'node_repo_remove', 'true', 'NODE', 'NODE_PACKAGE', 'bool', 'C/A', 'remove existing repo on node?', NULL),
(222, 'node_repo_local_urls', '["http://${admin_ip}/pigsty.repo"]', 'NODE', 'NODE_PACKAGE', 'string[]', 'C', 'local repo url, if node_repo_method = local,both', NULL),
(223, 'node_packages', '[]', 'NODE', 'NODE_PACKAGE', 'string[]', 'C', 'packages to be installed current nodes', NULL),
(224, 'node_default_packages', '["lz4,unzip,bzip2,zlib,yum,pv,jq,git,ncdu,make,patch,bash,lsof,wget,uuid,tuned,nvme-cli,numactl,grubby,sysstat,iotop,htop,rsync,tcpdump", "netcat,socat,ftp,lrzsz,net-tools,ipvsadm,bind-utils,telnet,audit,ca-certificates,openssl,readline,vim-minimal,node_exporter,etcd,haproxy,python3,python3-pip"]', 'NODE', 'NODE_PACKAGE', 'string[]', 'G', 'default packages to be installed on all nodes', NULL),

(230, 'node_disable_firewall', 'true', 'NODE', 'NODE_TUNE', 'bool', 'C', 'disable node firewall? true by default', NULL),
(231, 'node_disable_selinux', 'true', 'NODE', 'NODE_TUNE', 'bool', 'C', 'disable node selinux? true by default', NULL),
(232, 'node_disable_numa', 'false', 'NODE', 'NODE_TUNE', 'bool', 'C', 'disable node numa, reboot required', NULL),
(233, 'node_disable_swap', 'false', 'NODE', 'NODE_TUNE', 'bool', 'C', 'disable node swap, use with caution', NULL),
(234, 'node_static_network', 'true', 'NODE', 'NODE_TUNE', 'bool', 'C', 'preserve dns resolver settings after reboot', NULL),
(235, 'node_disk_prefetch', 'false', 'NODE', 'NODE_TUNE', 'bool', 'C', 'setup disk prefetch on HDD to increase performance', NULL),
(236, 'node_kernel_modules', '["softdog", "br_netfilter", "ip_vs", "ip_vs_rr", "ip_vs_wrr", "ip_vs_sh"]', 'NODE', 'NODE_TUNE', 'string[]', 'C', 'kernel modules to be enabled on this node', NULL),
(237, 'node_hugepage_count', '0', 'NODE', 'NODE_TUNE', 'int', 'C', 'number of 2MB hugepage, take precedence over ratio', NULL),
(238, 'node_hugepage_ratio', '0', 'NODE', 'NODE_TUNE', 'float', 'C', 'node mem hugepage ratio, 0 disable it by default', NULL),
(239, 'node_overcommit_ratio', '0', 'NODE', 'NODE_TUNE', 'float', 'C', 'node mem overcommit ratio, 0 disable it by default', NULL),
(240, 'node_tune', '"oltp"', 'NODE', 'NODE_TUNE', 'enum', 'C', 'node tuned profile: none,oltp,olap,crit,tiny', NULL),
(241, 'node_sysctl_params', '{}', 'NODE', 'NODE_TUNE', 'dict', 'C', 'sysctl parameters in k:v format in addition to tuned', NULL),

(250, 'node_data', '"/data"', 'NODE', 'NODE_ADMIN', 'path', 'C', 'node main data directory, `/data` by default', NULL),
(251, 'node_admin_enabled', 'true', 'NODE', 'NODE_ADMIN', 'bool', 'C', 'create a admin user on target node?', NULL),
(252, 'node_admin_uid', '88', 'NODE', 'NODE_ADMIN', 'int', 'C', 'uid and gid for node admin user', NULL),
(253, 'node_admin_username', '"dba"', 'NODE', 'NODE_ADMIN', 'username', 'C', 'name of node admin user, `dba` by default', NULL),
(254, 'node_admin_ssh_exchange', 'true', 'NODE', 'NODE_ADMIN', 'bool', 'C', 'exchange admin ssh key among node cluster', NULL),
(255, 'node_admin_pk_current', 'true', 'NODE', 'NODE_ADMIN', 'bool', 'C', 'add current user''s ssh pk to admin authorized_keys', NULL),
(256, 'node_admin_pk_list', '[]', 'NODE', 'NODE_ADMIN', 'string[]', 'C', 'ssh public keys to be added to admin user', NULL),

(260, 'node_timezone', '""', 'NODE', 'NODE_TIME', 'string', 'C', 'setup node timezone, empty string to skip', NULL),
(261, 'node_ntp_enabled', 'true', 'NODE', 'NODE_TIME', 'bool', 'C', 'enable chronyd time sync service?', NULL),
(262, 'node_ntp_servers', '["pool pool.ntp.org iburst"]', 'NODE', 'NODE_TIME', 'string[]', 'C', 'ntp servers in `/etc/chrony.conf`', NULL),
(263, 'node_crontab_overwrite', 'true', 'NODE', 'NODE_TIME', 'bool', 'C', 'overwrite or append to `/etc/crontab`?', NULL),
(264, 'node_crontab', '[]', 'NODE', 'NODE_TIME', 'string[]', 'C', 'crontab entries in `/etc/crontab`', NULL),

(270, 'haproxy_enabled', 'true', 'NODE', 'HAPROXY', 'bool', 'C', 'enable haproxy on this node?', NULL),
(271, 'haproxy_clean', 'false', 'NODE', 'HAPROXY', 'bool', 'G/C/A', 'cleanup all existing haproxy config?', NULL),
(272, 'haproxy_reload', 'true', 'NODE', 'HAPROXY', 'bool', 'A', 'reload haproxy after config?', NULL),
(273, 'haproxy_auth_enabled', 'true', 'NODE', 'HAPROXY', 'bool', 'G', 'enable authentication for haproxy admin page', NULL),
(274, 'haproxy_admin_username', '"admin"', 'NODE', 'HAPROXY', 'username', 'G', 'haproxy admin username, `admin` by default', NULL),
(275, 'haproxy_admin_password', '"pigsty"', 'NODE', 'HAPROXY', 'password', 'G', 'haproxy admin password, `pigsty` by default', NULL),
(276, 'haproxy_exporter_port', '9101', 'NODE', 'HAPROXY', 'port', 'C', 'haproxy admin/exporter port, 9101 by default', NULL),
(277, 'haproxy_client_timeout', '"24h"', 'NODE', 'HAPROXY', 'interval', 'C', 'client side connection timeout, 24h by default', NULL),
(278, 'haproxy_server_timeout', '"24h"', 'NODE', 'HAPROXY', 'interval', 'C', 'server side connection timeout, 24h by default', NULL),
(279, 'haproxy_services', '[]', 'NODE', 'HAPROXY', 'service[]', 'C', 'list of haproxy service to be exposed on node', NULL),

(280, 'node_exporter_enabled', 'true', 'NODE', 'NODE_EXPORTER', 'bool', 'C', 'setup node_exporter on this node?', NULL),
(281, 'node_exporter_port', '9100', 'NODE', 'NODE_EXPORTER', 'port', 'C', 'node exporter listen port, 9100 by default', NULL),
(282, 'node_exporter_options', '"--no-collector.softnet --no-collector.nvme --collector.ntp --collector.tcpstat --collector.processes"', 'NODE', 'NODE_EXPORTER', 'arg', 'C', 'extra server options for node_exporter', NULL),
(283, 'promtail_enabled', 'true', 'NODE', 'PROMTAIL', 'bool', 'C', 'enable promtail logging collector?', NULL),
(284, 'promtail_clean', 'false', 'NODE', 'PROMTAIL', 'bool', 'G/A', 'purge existing promtail status file during init?', NULL),
(285, 'promtail_port', '9080', 'NODE', 'PROMTAIL', 'port', 'C', 'promtail listen port, 9080 by default', NULL),
(286, 'promtail_positions', '"/var/log/positions.yaml"', 'NODE', 'PROMTAIL', 'path', 'C', 'promtail position status file path', NULL),

-- DOCKER PARAMETERS
(401, 'docker_enabled', 'false', 'NODE', 'DOCKER', 'bool', 'C', 'enable docker on this node?', NULL),
(402, 'docker_cgroups_driver', '"systemd"', 'NODE', 'DOCKER', 'enum', 'C', 'docker cgroup fs driver: cgroupfs,systemd', NULL),
(403, 'docker_registry_mirrors', '[]', 'NODE', 'DOCKER', 'string[]', 'C', 'docker registry mirror list', NULL),
(404, 'docker_image_cache', '"/tmp/docker"', 'NODE', 'DOCKER', 'path', 'C', 'docker image cache dir, `/tmp/docker` by default', NULL),

-- ETCD PARAMETERS
(501, 'etcd_seq', NULL, 'ETCD', 'ETCD', 'int', 'I', 'etcd instance identifier, REQUIRED', NULL),
(502, 'etcd_cluster', '"etcd"', 'ETCD', 'ETCD', 'string', 'C', 'etcd cluster & group name, etcd by default', NULL),
(503, 'etcd_safeguard', 'false', 'ETCD', 'ETCD', 'bool', 'G/C/A', 'prevent purging running etcd instance?', NULL),
(504, 'etcd_clean', 'true', 'ETCD', 'ETCD', 'bool', 'G/C/A', 'purging existing etcd during initialization?', NULL),
(505, 'etcd_data', '"/data/etcd"', 'ETCD', 'ETCD', 'path', 'C', 'etcd data directory, /data/etcd by default', NULL),
(506, 'etcd_port', '2379', 'ETCD', 'ETCD', 'port', 'C', 'etcd client port, 2379 by default', NULL),
(507, 'etcd_peer_port', '2380', 'ETCD', 'ETCD', 'port', 'C', 'etcd peer port, 2380 by default', NULL),
(508, 'etcd_init', '"new"', 'ETCD', 'ETCD', 'enum', 'C', 'etcd initial cluster state, new or existing', NULL),
(509, 'etcd_election_timeout', '1000', 'ETCD', 'ETCD', 'int', 'C', 'etcd election timeout, 1000ms by default', NULL),
(510, 'etcd_heartbeat_interval', '100', 'ETCD', 'ETCD', 'int', 'C', 'etcd heartbeat interval, 100ms by default', NULL),

-- MINIO PARAMETERS
(601, 'minio_seq', NULL, 'MINIO', 'MINIO', 'int', 'I', 'minio instance identifier, REQUIRED', NULL),
(602, 'minio_cluster', '"minio"', 'MINIO', 'MINIO', 'string', 'C', 'minio cluster name, minio by default', NULL),
(603, 'minio_clean', 'false', 'MINIO', 'MINIO', 'bool', 'G/C/A', 'cleanup minio during init?, false by default', NULL),
(604, 'minio_user', '"minio"', 'MINIO', 'MINIO', 'username', 'C', 'minio os user, `minio` by default', NULL),
(605, 'minio_node', '"${minio_cluster}-${minio_seq}.pigsty"', 'MINIO', 'MINIO', 'string', 'C', 'minio node name pattern', NULL),
(606, 'minio_data', '"/data/minio"', 'MINIO', 'MINIO', 'path', 'C', 'minio data dir(s), use {x...y} to specify multi drivers', NULL),
(607, 'minio_domain', '"sss.pigsty"', 'MINIO', 'MINIO', 'string', 'G', 'minio service domain name, `sss.pigsty` by default', NULL),
(608, 'minio_port', '9000', 'MINIO', 'MINIO', 'port', 'C', 'minio service port, 9000 by default', NULL),
(609, 'minio_admin_port', '9001', 'MINIO', 'MINIO', 'port', 'C', 'minio console port, 9001 by default', NULL),
(610, 'minio_access_key', '"minioadmin"', 'MINIO', 'MINIO', 'username', 'C', 'root access key, `minioadmin` by default', NULL),
(611, 'minio_secret_key', '"minioadmin"', 'MINIO', 'MINIO', 'password', 'C', 'root secret key, `minioadmin` by default', NULL),
(612, 'minio_extra_vars', '""', 'MINIO', 'MINIO', 'string', 'C', 'extra environment variables for minio server', NULL),
(613, 'minio_alias', '"sss"', 'MINIO', 'MINIO', 'string', 'G', 'alias name for local minio deployment', NULL),
(614, 'minio_buckets', '[{"name": "pgsql"}, {"name": "infra"}, {"name": "redis"}]', 'MINIO', 'MINIO', 'bucket[]', 'C', 'list of minio bucket to be created', NULL),
(615, 'minio_users', '[{"policy": "consoleAdmin", "access_key": "dba", "secret_key": "S3User.DBA"}, {"policy": "readwrite", "access_key": "pgbackrest", "secret_key": "S3User.Backup"}]', 'MINIO', 'MINIO', 'user[]', 'C', 'list of minio user to be created', NULL),

-- REDIS PARAMETERS
(701, 'redis_cluster', NULL, 'REDIS', 'REDIS', 'string', 'C', 'redis cluster name, required identity parameter', NULL),
(702, 'redis_instances', NULL, 'REDIS', 'REDIS', 'dict', 'I', 'redis instances definition on this redis node', NULL),
(703, 'redis_node', NULL, 'REDIS', 'REDIS', 'int', 'I', 'redis node sequence number, node int id required', NULL),
(710, 'redis_fs_main', '"/data"', 'REDIS', 'REDIS', 'path', 'C', 'redis main data mountpoint, `/data` by default', NULL),
(711, 'redis_exporter_enabled', 'true', 'REDIS', 'REDIS', 'bool', 'C', 'install redis exporter on redis nodes?', NULL),
(712, 'redis_exporter_port', '9121', 'REDIS', 'REDIS', 'port', 'C', 'redis exporter listen port, 9121 by default', NULL),
(713, 'redis_exporter_options', '""', 'REDIS', 'REDIS', 'string', 'C/I', 'cli args and extra options for redis exporter', NULL),
(720, 'redis_safeguard', 'false', 'REDIS', 'REDIS', 'bool', 'C', 'prevent purging running redis instance?', NULL),
(721, 'redis_clean', 'true', 'REDIS', 'REDIS', 'bool', 'C', 'purging existing redis during init?', NULL),
(722, 'redis_rmdata', 'true', 'REDIS', 'REDIS', 'bool', 'A', 'remove redis data when purging redis server?', NULL),
(723, 'redis_mode', '"standalone"', 'REDIS', 'REDIS', 'enum', 'C', 'redis mode: standalone,cluster,sentinel', NULL),
(724, 'redis_conf', '"redis.conf"', 'REDIS', 'REDIS', 'string', 'C', 'redis config template path, except sentinel', NULL),
(725, 'redis_bind_address', '"0.0.0.0"', 'REDIS', 'REDIS', 'ip', 'C', 'redis bind address, empty string will use host ip', NULL),
(726, 'redis_max_memory', '"1GB"', 'REDIS', 'REDIS', 'size', 'C/I', 'max memory used by each redis instance', NULL),
(727, 'redis_mem_policy', '"allkeys-lru"', 'REDIS', 'REDIS', 'enum', 'C', 'redis memory eviction policy', NULL),
(728, 'redis_password', '""', 'REDIS', 'REDIS', 'password', 'C', 'redis password, empty string will disable password', NULL),
(729, 'redis_rdb_save', '["1200 1"]', 'REDIS', 'REDIS', 'string[]', 'C', 'redis rdb save directives, disable with empty list', NULL),
(730, 'redis_aof_enabled', 'false', 'REDIS', 'REDIS', 'bool', 'C', 'enable redis append only file?', NULL),
(731, 'redis_rename_commands', '{}', 'REDIS', 'REDIS', 'dict', 'C', 'rename redis dangerous commands', NULL),
(732, 'redis_cluster_replicas', '1', 'REDIS', 'REDIS', 'int', 'C', 'replica number for one master in redis cluster', NULL),

-- PGSQL PARAMETERS
(801, 'pg_mode', '"pgsql"', 'PGSQL', 'PG_ID', 'enum', 'C', 'pgsql cluster mode: pgsql,citus,gpsql', NULL),
(802, 'pg_cluster', NULL, 'PGSQL', 'PG_ID', 'string', 'C', 'pgsql cluster name, REQUIRED identity parameter', NULL),
(803, 'pg_seq', NULL, 'PGSQL', 'PG_ID', 'int', 'I', 'pgsql instance seq number, REQUIRED identity parameter', NULL),
(804, 'pg_role', '"replica"', 'PGSQL', 'PG_ID', 'enum', 'I', 'pgsql role, REQUIRED, could be primary,replica,offline', NULL),
(805, 'pg_instances', NULL, 'PGSQL', 'PG_ID', 'dict', 'I', 'define multiple pg instances on node in `{port:ins_vars}` format', NULL),
(806, 'pg_upstream', NULL, 'PGSQL', 'PG_ID', 'ip', 'I', 'repl upstream ip addr for standby cluster or cascade replica', NULL),
(807, 'pg_shard', NULL, 'PGSQL', 'PG_ID', 'string', 'C', 'pgsql shard name, optional identity for sharding clusters', NULL),
(808, 'pg_group', NULL, 'PGSQL', 'PG_ID', 'int', 'C', 'pgsql shard index number, optional identity for sharding clusters', NULL),
(809, 'gp_role', '"master"', 'PGSQL', 'PG_ID', 'enum', 'C', 'greenplum role of this cluster, could be master or segment', NULL),
(810, 'pg_exporters', '{}', 'PGSQL', 'PG_ID', 'dict', 'C', 'additional pg_exporters to monitor remote postgres instances', NULL),
(811, 'pg_offline_query', 'false', 'PGSQL', 'PG_ID', 'bool', 'I', 'set to true to enable offline query on this instance', NULL),

(820, 'pg_users', '[]', 'PGSQL', 'PG_BUSINESS', 'user[]', 'C', 'postgres business users', NULL),
(821, 'pg_databases', '[]', 'PGSQL', 'PG_BUSINESS', 'database[]', 'C', 'postgres business databases', NULL),
(822, 'pg_services', '[]', 'PGSQL', 'PG_BUSINESS', 'service[]', 'C', 'postgres business services', NULL),
(823, 'pg_hba_rules', '[]', 'PGSQL', 'PG_BUSINESS', 'hba[]', 'C', 'business hba rules for postgres', NULL),
(824, 'pgb_hba_rules', '[]', 'PGSQL', 'PG_BUSINESS', 'hba[]', 'C', 'business hba rules for pgbouncer', NULL),
(831, 'pg_replication_username', '"replicator"', 'PGSQL', 'PG_BUSINESS', 'username', 'G', 'postgres replication username, `replicator` by default', NULL),
(832, 'pg_replication_password', '"DBUser.Replicator"', 'PGSQL', 'PG_BUSINESS', 'password', 'G', 'postgres replication password, `DBUser.Replicator` by default', NULL),
(833, 'pg_admin_username', '"dbuser_dba"', 'PGSQL', 'PG_BUSINESS', 'username', 'G', 'postgres admin username, `dbuser_dba` by default', NULL),
(834, 'pg_admin_password', '"DBUser.DBA"', 'PGSQL', 'PG_BUSINESS', 'password', 'G', 'postgres admin password in plain text, `DBUser.DBA` by default', NULL),
(835, 'pg_monitor_username', '"dbuser_monitor"', 'PGSQL', 'PG_BUSINESS', 'username', 'G', 'postgres monitor username, `dbuser_monitor` by default', NULL),
(836, 'pg_monitor_password', '"DBUser.Monitor"', 'PGSQL', 'PG_BUSINESS', 'password', 'G', 'postgres monitor password, `DBUser.Monitor` by default', NULL),
(837, 'pg_dbsu_password', '""', 'PGSQL', 'PG_BUSINESS', 'password', 'G/C', 'postgres dbsu password, empty string disable it by default', NULL),

(840, 'pg_dbsu', '"postgres"', 'PGSQL', 'PG_INSTALL', 'username', 'C', 'os dbsu name, postgres by default, better not change it', NULL),
(841, 'pg_dbsu_uid', '26', 'PGSQL', 'PG_INSTALL', 'int', 'C', 'os dbsu uid and gid, 26 for default postgres users and groups', NULL),
(842, 'pg_dbsu_sudo', '"limit"', 'PGSQL', 'PG_INSTALL', 'enum', 'C', 'dbsu sudo privilege, none,limit,all,nopass. limit by default', NULL),
(843, 'pg_dbsu_home', '"/var/lib/pgsql"', 'PGSQL', 'PG_INSTALL', 'path', 'C', 'postgresql home directory, `/var/lib/pgsql` by default', NULL),
(844, 'pg_dbsu_ssh_exchange', 'true', 'PGSQL', 'PG_INSTALL', 'bool', 'C', 'exchange postgres dbsu ssh key among same pgsql cluster', NULL),
(845, 'pg_version', '15', 'PGSQL', 'PG_INSTALL', 'enum', 'C', 'postgres major version to be installed, 15 by default', NULL),
(846, 'pg_bin_dir', '"/usr/pgsql/bin"', 'PGSQL', 'PG_INSTALL', 'path', 'C', 'postgres binary dir, `/usr/pgsql/bin` by default', NULL),
(847, 'pg_log_dir', '"/pg/log/postgres"', 'PGSQL', 'PG_INSTALL', 'path', 'C', 'postgres log dir, `/pg/log/postgres` by default', NULL),
(848, 'pg_packages', '["postgresql${pg_version}*", "pgbouncer pg_exporter pgbadger vip-manager patroni patroni-etcd pgbackrest"]', 'PGSQL', 'PG_INSTALL', 'string[]', 'C', 'pg packages to be installed, `${pg_version}` will be replaced', NULL),
(849, 'pg_extensions', '["pg_repack_${pg_version} wal2json_${pg_version}", "postgis33_${pg_version} postgis33_${pg_version}-devel postgis33_${pg_version}-utils", "timescaledb-2-postgresql-${pg_version}", "citus*${pg_version}*", "pgvector_${pg_version}*"]', 'PGSQL', 'PG_INSTALL', 'string[]', 'C', 'pg extensions to be installed, `${pg_version}` will be replaced', NULL),
(850, 'pg_safeguard', 'false', 'PGSQL', 'PG_BOOTSTRAP', 'bool', 'G/C/A', 'prevent purging running postgres instance? false by default', NULL),
(851, 'pg_clean', 'true', 'PGSQL', 'PG_BOOTSTRAP', 'bool', 'G/C/A', 'purging existing postgres during pgsql init? true by default', NULL),
(852, 'pg_data', '"/pg/data"', 'PGSQL', 'PG_BOOTSTRAP', 'path', 'C', 'postgres data directory, `/pg/data` by default', NULL),
(853, 'pg_fs_main', '"/data"', 'PGSQL', 'PG_BOOTSTRAP', 'path', 'C', 'mountpoint/path for postgres main data, `/data` by default', NULL),
(854, 'pg_fs_bkup', '"/data/backups"', 'PGSQL', 'PG_BOOTSTRAP', 'path', 'C', 'mountpoint/path for pg backup data, `/data/backup` by default', NULL),
(855, 'pg_storage_type', '"SSD"', 'PGSQL', 'PG_BOOTSTRAP', 'enum', 'C', 'storage type for pg main data, SSD,HDD, SSD by default', NULL),
(856, 'pg_dummy_filesize', '"64MiB"', 'PGSQL', 'PG_BOOTSTRAP', 'size', 'C', 'size of `/pg/dummy`, hold 64MB disk space for emergency use', NULL),
(857, 'pg_listen', '"0.0.0.0"', 'PGSQL', 'PG_BOOTSTRAP', 'ip(s)', 'C/I', 'postgres/pgbouncer listen addresses, comma separated list', NULL),
(858, 'pg_port', '5432', 'PGSQL', 'PG_BOOTSTRAP', 'port', 'C', 'postgres listen port, 5432 by default', NULL),
(859, 'pg_localhost', '"/var/run/postgresql"', 'PGSQL', 'PG_BOOTSTRAP', 'path', 'C', 'postgres unix socket dir for localhost connection', NULL),
(860, 'pg_namespace', '"/pg"', 'PGSQL', 'PG_BOOTSTRAP', 'path', 'C', 'top level key namespace in etcd, used by patroni & vip', NULL),
(861, 'patroni_enabled', 'true', 'PGSQL', 'PG_BOOTSTRAP', 'bool', 'C', 'if disabled, no postgres cluster will be created during init', NULL),
(862, 'patroni_mode', '"default"', 'PGSQL', 'PG_BOOTSTRAP', 'enum', 'C', 'patroni working mode: default,pause,remove', NULL),
(863, 'patroni_port', '8008', 'PGSQL', 'PG_BOOTSTRAP', 'port', 'C', 'patroni listen port, 8008 by default', NULL),
(864, 'patroni_log_dir', '"/pg/log/patroni"', 'PGSQL', 'PG_BOOTSTRAP', 'path', 'C', 'patroni log dir, `/pg/log/patroni` by default', NULL),
(865, 'patroni_ssl_enabled', 'false', 'PGSQL', 'PG_BOOTSTRAP', 'bool', 'G', 'secure patroni RestAPI communications with SSL?', NULL),
(866, 'patroni_watchdog_mode', '"off"', 'PGSQL', 'PG_BOOTSTRAP', 'enum', 'C', 'patroni watchdog mode: automatic,required,off. off by default', NULL),
(867, 'patroni_username', '"postgres"', 'PGSQL', 'PG_BOOTSTRAP', 'username', 'C', 'patroni restapi username, `postgres` by default', NULL),
(868, 'patroni_password', '"Patroni.API"', 'PGSQL', 'PG_BOOTSTRAP', 'password', 'C', 'patroni restapi password, `Patroni.API` by default', NULL),
(869, 'patroni_citus_db', '"postgres"', 'PGSQL', 'PG_BOOTSTRAP', 'string', 'C', 'citus database managed by patroni, postgres by default', NULL),
(870, 'pg_conf', '"oltp.yml"', 'PGSQL', 'PG_BOOTSTRAP', 'enum', 'C', 'config template: oltp,olap,crit,tiny. `oltp.yml` by default', NULL),
(871, 'pg_max_conn', '"auto"', 'PGSQL', 'PG_BOOTSTRAP', 'int', 'C', 'postgres max connections, `auto` will use recommended value', NULL),
(872, 'pg_shared_buffer_ratio', '0.25', 'PGSQL', 'PG_BOOTSTRAP', 'float', 'C', 'postgres shared buffer memory ratio, 0.25 by default, 0.1~0.4', NULL),
(873, 'pg_rto', '30', 'PGSQL', 'PG_BOOTSTRAP', 'int', 'C', 'recovery time objective in seconds,  `30s` by default', NULL),
(874, 'pg_rpo', '1048576', 'PGSQL', 'PG_BOOTSTRAP', 'int', 'C', 'recovery point objective in bytes, `1MiB` at most by default', NULL),
(875, 'pg_libs', '"timescaledb, pg_stat_statements, auto_explain"', 'PGSQL', 'PG_BOOTSTRAP', 'string', 'C', 'preloaded libraries, `pg_stat_statements,auto_explain` by default', NULL),
(876, 'pg_delay', '0', 'PGSQL', 'PG_BOOTSTRAP', 'interval', 'I', 'replication apply delay for standby cluster leader', NULL),
(877, 'pg_checksum', 'false', 'PGSQL', 'PG_BOOTSTRAP', 'bool', 'C', 'enable data checksum for postgres cluster?', NULL),
(878, 'pg_pwd_enc', '"scram-sha-256"', 'PGSQL', 'PG_BOOTSTRAP', 'enum', 'C', 'passwords encryption algorithm: md5,scram-sha-256', NULL),
(879, 'pg_encoding', '"UTF8"', 'PGSQL', 'PG_BOOTSTRAP', 'enum', 'C', 'database cluster encoding, `UTF8` by default', NULL),
(880, 'pg_locale', '"C"', 'PGSQL', 'PG_BOOTSTRAP', 'enum', 'C', 'database cluster local, `C` by default', NULL),
(881, 'pg_lc_collate', '"C"', 'PGSQL', 'PG_BOOTSTRAP', 'enum', 'C', 'database cluster collate, `C` by default', NULL),
(882, 'pg_lc_ctype', '"en_US.UTF8"', 'PGSQL', 'PG_BOOTSTRAP', 'enum', 'C', 'database character type, `en_US.UTF8` by default', NULL),

(890, 'pgbouncer_enabled', 'true', 'PGSQL', 'PG_BOOTSTRAP', 'bool', 'C', 'if disabled, pgbouncer will not be launched on pgsql host', NULL),
(891, 'pgbouncer_port', '6432', 'PGSQL', 'PG_BOOTSTRAP', 'port', 'C', 'pgbouncer listen port, 6432 by default', NULL),
(892, 'pgbouncer_log_dir', '"/pg/log/pgbouncer"', 'PGSQL', 'PG_BOOTSTRAP', 'path', 'C', 'pgbouncer log dir, `/pg/log/pgbouncer` by default', NULL),
(893, 'pgbouncer_auth_query', 'false', 'PGSQL', 'PG_BOOTSTRAP', 'bool', 'C', 'query postgres to retrieve unlisted business users?', NULL),
(894, 'pgbouncer_poolmode', '"transaction"', 'PGSQL', 'PG_BOOTSTRAP', 'enum', 'C', 'pooling mode: transaction,session,statement, transaction by default', NULL),
(895, 'pgbouncer_sslmode', '"disable"', 'PGSQL', 'PG_BOOTSTRAP', 'enum', 'C', 'pgbouncer client ssl mode, disable by default', NULL),

(900, 'pg_provision', 'true', 'PGSQL', 'PG_PROVISION', 'bool', 'C', 'provision postgres cluster after bootstrap', NULL),
(901, 'pg_init', '"pg-init"', 'PGSQL', 'PG_PROVISION', 'string', 'G/C', 'provision init script for cluster template, `pg-init` by default', NULL),
(902, 'pg_default_roles', '[{"name": "dbrole_readonly", "login": false, "comment": "role for global read-only access"}, {"name": "dbrole_offline", "login": false, "comment": "role for restricted read-only access"}, {"name": "dbrole_readwrite", "login": false, "roles": ["dbrole_readonly"], "comment": "role for global read-write access"}, {"name": "dbrole_admin", "login": false, "roles": ["pg_monitor", "dbrole_readwrite"], "comment": "role for object creation"}, {"name": "postgres", "comment": "system superuser", "superuser": true}, {"name": "replicator", "roles": ["pg_monitor", "dbrole_readonly"], "comment": "system replicator", "replication": true}, {"name": "dbuser_dba", "roles": ["dbrole_admin"], "comment": "pgsql admin user", "pgbouncer": true, "pool_mode": "session", "superuser": true, "pool_connlimit": 16}, {"name": "dbuser_monitor", "roles": ["pg_monitor"], "comment": "pgsql monitor user", "pgbouncer": true, "pool_mode": "session", "parameters": {"log_min_duration_statement": 1000}, "pool_connlimit": 8}]', 'PGSQL', 'PG_PROVISION', 'role[]', 'G/C', 'default roles and users in postgres cluster', NULL),
(903, 'pg_default_privileges', '["GRANT USAGE      ON SCHEMAS   TO dbrole_readonly", "GRANT SELECT     ON TABLES    TO dbrole_readonly", "GRANT SELECT     ON SEQUENCES TO dbrole_readonly", "GRANT EXECUTE    ON FUNCTIONS TO dbrole_readonly", "GRANT USAGE      ON SCHEMAS   TO dbrole_offline", "GRANT SELECT     ON TABLES    TO dbrole_offline", "GRANT SELECT     ON SEQUENCES TO dbrole_offline", "GRANT EXECUTE    ON FUNCTIONS TO dbrole_offline", "GRANT INSERT     ON TABLES    TO dbrole_readwrite", "GRANT UPDATE     ON TABLES    TO dbrole_readwrite", "GRANT DELETE     ON TABLES    TO dbrole_readwrite", "GRANT USAGE      ON SEQUENCES TO dbrole_readwrite", "GRANT UPDATE     ON SEQUENCES TO dbrole_readwrite", "GRANT TRUNCATE   ON TABLES    TO dbrole_admin", "GRANT REFERENCES ON TABLES    TO dbrole_admin", "GRANT TRIGGER    ON TABLES    TO dbrole_admin", "GRANT CREATE     ON SCHEMAS   TO dbrole_admin"]', 'PGSQL', 'PG_PROVISION', 'string[]', 'G/C', 'default privileges when created by admin user', NULL),
(904, 'pg_default_schemas', '["monitor"]', 'PGSQL', 'PG_PROVISION', 'string[]', 'G/C', 'default schemas to be created', NULL),
(905, 'pg_default_extensions', '[{"name": "adminpack", "schema": "pg_catalog"}, {"name": "pg_stat_statements", "schema": "monitor"}, {"name": "pgstattuple", "schema": "monitor"}, {"name": "pg_buffercache", "schema": "monitor"}, {"name": "pageinspect", "schema": "monitor"}, {"name": "pg_prewarm", "schema": "monitor"}, {"name": "pg_visibility", "schema": "monitor"}, {"name": "pg_freespacemap", "schema": "monitor"}, {"name": "postgres_fdw", "schema": "public"}, {"name": "file_fdw", "schema": "public"}, {"name": "btree_gist", "schema": "public"}, {"name": "btree_gin", "schema": "public"}, {"name": "pg_trgm", "schema": "public"}, {"name": "intagg", "schema": "public"}, {"name": "intarray", "schema": "public"}, {"name": "pg_repack"}]', 'PGSQL', 'PG_PROVISION', 'extension[]', 'G/C', 'default extensions to be created', NULL),
(906, 'pg_reload', 'true', 'PGSQL', 'PG_PROVISION', 'bool', 'A', 'reload postgres after hba changes', NULL),
(907, 'pg_default_hba_rules', '[{"db": "all", "addr": "local", "auth": "ident", "user": "${dbsu}", "title": "dbsu access via local os user ident"}, {"db": "replication", "addr": "local", "auth": "ident", "user": "${dbsu}", "title": "dbsu replication from local os ident"}, {"db": "replication", "addr": "localhost", "auth": "pwd", "user": "${repl}", "title": "replicator replication from localhost"}, {"db": "replication", "addr": "intra", "auth": "pwd", "user": "${repl}", "title": "replicator replication from intranet"}, {"db": "postgres", "addr": "intra", "auth": "pwd", "user": "${repl}", "title": "replicator postgres db from intranet"}, {"db": "all", "addr": "localhost", "auth": "pwd", "user": "${monitor}", "title": "monitor from localhost with password"}, {"db": "all", "addr": "infra", "auth": "pwd", "user": "${monitor}", "title": "monitor from infra host with password"}, {"db": "all", "addr": "infra", "auth": "ssl", "user": "${admin}", "title": "admin @ infra nodes with pwd & ssl"}, {"db": "all", "addr": "world", "auth": "ssl", "user": "${admin}", "title": "admin @ everywhere with ssl & pwd"}, {"db": "all", "addr": "localhost", "auth": "pwd", "user": "+dbrole_readonly", "title": "pgbouncer read/write via local socket"}, {"db": "all", "addr": "intra", "auth": "pwd", "user": "+dbrole_readonly", "title": "read/write biz user via password"}, {"db": "all", "addr": "intra", "auth": "pwd", "user": "+dbrole_offline", "title": "allow etl offline tasks from intranet"}]', 'PGSQL', 'PG_PROVISION', 'hba[]', 'G/C', 'postgres default host-based authentication rules', NULL),
(908, 'pgb_default_hba_rules', '[{"db": "pgbouncer", "addr": "local", "auth": "peer", "user": "${dbsu}", "title": "dbsu local admin access with os ident"}, {"db": "all", "addr": "localhost", "auth": "pwd", "user": "all", "title": "allow all user local access with pwd"}, {"db": "pgbouncer", "addr": "intra", "auth": "pwd", "user": "${monitor}", "title": "monitor access via intranet with pwd"}, {"db": "all", "addr": "world", "auth": "deny", "user": "${monitor}", "title": "reject all other monitor access addr"}, {"db": "all", "addr": "intra", "auth": "pwd", "user": "${admin}", "title": "admin access via intranet with pwd"}, {"db": "all", "addr": "world", "auth": "deny", "user": "${admin}", "title": "reject all other admin access addr"}, {"db": "all", "addr": "intra", "auth": "pwd", "user": "all", "title": "allow all user intra access with pwd"}]', 'PGSQL', 'PG_PROVISION', 'hba[]', 'G/C', 'pgbouncer default host-based authentication rules', NULL),
(910, 'pgbackrest_enabled', 'true', 'PGSQL', 'PG_BACKUP', 'bool', 'C', 'enable pgbackrest on pgsql host?', NULL),
(911, 'pgbackrest_clean', 'true', 'PGSQL', 'PG_BACKUP', 'bool', 'C', 'remove pg backup data during init?', NULL),
(912, 'pgbackrest_log_dir', '"/pg/log/pgbackrest"', 'PGSQL', 'PG_BACKUP', 'path', 'C', 'pgbackrest log dir, `/pg/log/pgbackrest` by default', NULL),
(913, 'pgbackrest_method', '"local"', 'PGSQL', 'PG_BACKUP', 'enum', 'C', 'pgbackrest repo method: local,minio,etc...', NULL),
(914, 'pgbackrest_repo', '{"local": {"path": "/pg/backup", "retention_full": 2, "retention_full_type": "count"}, "minio": {"path": "/pgbackrest", "type": "s3", "bundle": "y", "s3_key": "pgbackrest", "s3_bucket": "pgsql", "s3_region": "us-east-1", "cipher_pass": "pgBackRest", "cipher_type": "aes-256-cbc", "s3_endpoint": "sss.pigsty", "s3_uri_style": "path", "storage_port": 9000, "s3_key_secret": "S3User.Backup", "retention_full": 14, "storage_ca_file": "/etc/pki/ca.crt", "retention_full_type": "time"}}', 'PGSQL', 'PG_BACKUP', 'dict', 'G/C', 'pgbackrest repo: https://pgbackrest.org/configuration.html#section-repository', NULL),

(921, 'pg_weight', '100', 'PGSQL', 'PG_SERVICE', 'int', 'I', 'relative load balance weight in service, 100 by default, 0-255', NULL),
(922, 'pg_service_provider', '""', 'PGSQL', 'PG_SERVICE', 'string', 'G/C', 'dedicate haproxy node group name, or empty string for local nodes by default', NULL),
(923, 'pg_default_service_dest', '"pgbouncer"', 'PGSQL', 'PG_SERVICE', 'enum', 'G/C', 'default service destination if svc.dest=''default''', NULL),
(924, 'pg_default_services', '[{"dest": "default", "name": "primary", "port": 5433, "check": "/primary", "selector": "[]"}, {"dest": "default", "name": "replica", "port": 5434, "check": "/read-only", "backup": "[? pg_role == `primary` || pg_role == `offline` ]", "selector": "[]"}, {"dest": "postgres", "name": "default", "port": 5436, "check": "/primary", "selector": "[]"}, {"dest": "postgres", "name": "offline", "port": 5438, "check": "/replica", "backup": "[? pg_role == `replica` && !pg_offline_query]", "selector": "[? pg_role == `offline` || pg_offline_query ]"}]', 'PGSQL', 'PG_SERVICE', 'service[]', 'G/C', 'postgres default service definitions', NULL),
(931, 'pg_vip_enabled', 'false', 'PGSQL', 'PG_SERVICE', 'bool', 'C', 'enable a l2 vip for pgsql primary? false by default', NULL),
(932, 'pg_vip_address', '"127.0.0.1/24"', 'PGSQL', 'PG_SERVICE', 'cidr4', 'C', 'vip address in `<ipv4>/<mask>` format, require if vip is enabled', NULL),
(933, 'pg_vip_interface', '"eth0"', 'PGSQL', 'PG_SERVICE', 'string', 'C/I', 'vip network interface to listen, eth0 by default', NULL),
(934, 'pg_dns_suffix', '""', 'PGSQL', 'PG_SERVICE', 'string', 'C', 'pgsql dns suffix, '''' by default', NULL),
(935, 'pg_dns_target', '"auto"', 'PGSQL', 'PG_SERVICE', 'enum', 'C', 'auto, primary, vip, none, or ad hoc ip', NULL),

(940, 'pg_exporter_enabled', 'true', 'PGSQL', 'PG_EXPORTER', 'bool', 'C', 'enable pg_exporter on pgsql hosts?', NULL),
(941, 'pg_exporter_config', '"pg_exporter.yml"', 'PGSQL', 'PG_EXPORTER', 'string', 'C', 'pg_exporter configuration file name', NULL),
(942, 'pg_exporter_cache_ttls', '"1,10,60,300"', 'PGSQL', 'PG_EXPORTER', 'string', 'C', 'pg_exporter collector ttl stage in seconds, ''1,10,60,300'' by default', NULL),
(943, 'pg_exporter_port', '9630', 'PGSQL', 'PG_EXPORTER', 'port', 'C', 'pg_exporter listen port, 9630 by default', NULL),
(944, 'pg_exporter_params', '"sslmode=disable"', 'PGSQL', 'PG_EXPORTER', 'string', 'C', 'extra url parameters for pg_exporter dsn', NULL),
(945, 'pg_exporter_url', '""', 'PGSQL', 'PG_EXPORTER', 'pgurl', 'C', 'overwrite auto-generate pg dsn if specified', NULL),
(946, 'pg_exporter_auto_discovery', 'true', 'PGSQL', 'PG_EXPORTER', 'bool', 'C', 'enable auto database discovery? enabled by default', NULL),
(947, 'pg_exporter_exclude_database', '"template0,template1,postgres"', 'PGSQL', 'PG_EXPORTER', 'string', 'C', 'csv of database that WILL NOT be monitored during auto-discovery', NULL),
(948, 'pg_exporter_include_database', '""', 'PGSQL', 'PG_EXPORTER', 'string', 'C', 'csv of database that WILL BE monitored during auto-discovery', NULL),
(949, 'pg_exporter_connect_timeout', '200', 'PGSQL', 'PG_EXPORTER', 'int', 'C', 'pg_exporter connect timeout in ms, 200 by default', NULL),
(950, 'pg_exporter_options', '""', 'PGSQL', 'PG_EXPORTER', 'arg', 'C', 'overwrite extra options for pg_exporter', NULL),
(951, 'pgbouncer_exporter_enabled', 'true', 'PGSQL', 'PG_EXPORTER', 'bool', 'C', 'enable pgbouncer_exporter on pgsql hosts?', NULL),
(952, 'pgbouncer_exporter_port', '9631', 'PGSQL', 'PG_EXPORTER', 'port', 'C', 'pgbouncer_exporter listen port, 9631 by default', NULL),
(953, 'pgbouncer_exporter_url', '""', 'PGSQL', 'PG_EXPORTER', 'pgurl', 'C', 'overwrite auto-generate pgbouncer dsn if specified', NULL),
(954, 'pgbouncer_exporter_options', '""', 'PGSQL', 'PG_EXPORTER', 'arg', 'C', 'overwrite extra options for pgbouncer_exporter', NULL)
;

