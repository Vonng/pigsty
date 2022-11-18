-- ######################################################################
-- # File      :   cmdb.sql
-- # Desc      :   Pigsty CMDB baseline
-- # Ctime     :   2021-04-21
-- # Mtime     :   2022-05-05
-- # Copyright (C) 2018-2022 Ruohang Feng
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
    key   TEXT PRIMARY KEY CHECK (key != ''),
    value JSONB NULL,
    mtime TIMESTAMPTZ DEFAULT now()
);
COMMENT ON TABLE pigsty.default_var IS 'default variables';
COMMENT ON COLUMN pigsty.default_var.key IS 'default config entry name';
COMMENT ON COLUMN pigsty.default_var.value IS 'default config entry value';
COMMENT ON COLUMN pigsty.default_var.mtime IS 'default config entry last modified time';


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


--===========================================================--
--                    pigsty.raw_config                      --
--===========================================================--
DROP VIEW IF EXISTS pigsty.raw_config;
CREATE OR REPLACE VIEW pigsty.raw_config AS
    SELECT jsonb_build_object('all', jsonb_build_object('children', children, 'vars', vars)) FROM
    (SELECT jsonb_object_agg(cls, jsonb_build_object('hosts', hosts, 'vars', vars)) AS children FROM pigsty.group_config) a1,
    (SELECT jsonb_object_agg(key, value) AS vars FROM pigsty.global_var) a2;
COMMENT ON VIEW pigsty.inventory IS 'pigsty config file in json format';


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
           value ->> 'src_ip'               AS src_ip,
           value ->> 'src_port'             AS src_port,
           value ->> 'dst_port'             AS dst_port,
           value ->> 'check_url'            AS check_url,
           value ->> 'selector'             AS selector,
           value ->> 'selector_backup'      AS selector_backup,
           value -> 'haproxy'               AS haproxy,
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
           u                                               AS user
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
           hba
    FROM pigsty.pg_cluster,jsonb_array_elements(pgbouncer_hba) AS hba;
COMMENT ON VIEW pigsty.pg_hba IS 'pigsty pgbouncer hba rules';

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
         (SELECT jsonb_object_agg(key, value) AS global
          FROM global_var
          WHERE key ~ '^pg_services'
             or key ~ 'hba_rules') gsvc
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
         (SELECT jsonb_object_agg(key, value) AS global FROM global_config WHERE key ~ '^redis') gsvc
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
           ((gsvc.global || vars) ->> 'minio_admin_port')::INTEGER AS console_port,
           (gsvc.global || vars) ->> 'minio_domain' AS domain,
           hosts,vars
    FROM pigsty.group_config,
         (SELECT jsonb_object_agg(key, value) AS global FROM global_config WHERE key ~ '^minio') gsvc
    WHERE vars ? 'minio_cluster';
COMMENT ON VIEW pigsty.minio_cluster IS 'pigsty minio cluster definition';




--===========================================================--
--                   pigsty.etcd_cluster                    --
--===========================================================--
DROP VIEW IF EXISTS pigsty.etcd_cluster CASCADE;
CREATE OR REPLACE VIEW pigsty.etcd_cluster AS
    SELECT cls,
           vars ->> 'etcd_cluster' AS name,
           ((gsvc.global || vars) ->> 'etcd_api')::INTEGER AS api,
           ((gsvc.global || vars) ->> 'etcd_port')::INTEGER AS port,
           ((gsvc.global || vars) ->> 'etcd_peer_port')::INTEGER AS peer_port,
           (gsvc.global || vars) ->> 'etcd_data' AS data_dir,
           ((gsvc.global || vars) ->> 'etcd_clean')::BOOLEAN AS clean,
           ((gsvc.global || vars) ->> 'etcd_safeguard')::BOOLEAN AS safeguard,
           (SELECT count(*) FROM host WHERE cls = 'etcd') AS size,
           ceil((SELECT count(*) FROM host WHERE cls = 'etcd') / 2.0) AS quorum,
           hosts,vars
    FROM pigsty.group_config,
         (SELECT jsonb_object_agg(key, value) AS global FROM global_config WHERE key ~ '^etcd') gsvc
    WHERE vars ? 'etcd_cluster';

COMMENT ON VIEW pigsty.etcd_cluster IS 'pigsty etcd cluster definition';



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
    '3B000', -- savepoint_exception
    '3B001', -- 	invalid_savepoint_specification
-- Class 3D — Invalid Catalog Name
    '3D000', -- 	invalid_catalog_name
-- Class 3F — Invalid Schema Name
    '3F000', -- 	invalid_schema_name
-- Class 40 — Transaction Rollback
    '40000', -- transaction_rollback
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
    'XX002' -- 	index_corrupted
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