-- ######################################################################
-- # File      :   cmdb.sql
-- # Desc      :   Pigsty CMDB baseline (pg-meta.meta)
-- # Ctime     :   2021-04-21
-- # Mtime     :   2021-07-13
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
CREATE TYPE pigsty.status AS ENUM ('unknown', 'failed', 'available', 'creating', 'deleting');
CREATE TYPE pigsty.pg_role AS ENUM ('unknown','primary', 'replica', 'offline', 'standby', 'delayed');
CREATE TYPE pigsty.job_status AS ENUM ('draft', 'ready', 'run', 'done', 'fail');
COMMENT ON TYPE pigsty.status IS 'entity status';
COMMENT ON TYPE pigsty.pg_role IS 'available postgres roles';
COMMENT ON TYPE pigsty.job_status IS 'pigsty job status';

--===========================================================--
--                          config                           --
--===========================================================--
-- config hold raw config with additional meta data (id, name, ctime)
-- It is intent to use date_trunc('second', epoch) as part of auto-gen config name
-- which imply a constraint that no more than one config can be loaded on same second

-- DROP TABLE IF EXISTS config;
CREATE TABLE IF NOT EXISTS pigsty.config
(
    name      VARCHAR(128) PRIMARY KEY,           -- unique config name, specify or auto-gen
    data      JSON        NOT NULL,               -- unparsed json string
    is_active BOOLEAN     NOT NULL DEFAULT FALSE, -- is config currently in use, unique on true?
    ctime     TIMESTAMPTZ NOT NULL default now(), -- ctime
    mtime     TIMESTAMPTZ NOT NULL DEFAULT now()  -- mtime
);
COMMENT ON TABLE pigsty.config IS 'pigsty raw configs';
COMMENT ON COLUMN pigsty.config.name IS 'unique config file name, use ts as default';
COMMENT ON COLUMN pigsty.config.data IS 'json format data';
COMMENT ON COLUMN pigsty.config.ctime IS 'config creation time, unique';
COMMENT ON COLUMN pigsty.config.mtime IS 'config latest modification time, unique';

-- at MOST one config can be activated simultaneously
CREATE UNIQUE INDEX IF NOT EXISTS config_is_active_key ON config (is_active) WHERE is_active = true;


--===========================================================--
--                         cluster                           --
--===========================================================--
-- DROP TABLE IF EXISTS cluster CASCADE;
CREATE TABLE IF NOT EXISTS pigsty.cluster
(
    cls    TEXT PRIMARY KEY,
    shard  TEXT,
    sindex INTEGER CHECK (sindex IS NULL OR sindex >= 0),
    status status      NOT NULL DEFAULT 'unknown'::status,
    ctime  TIMESTAMPTZ NOT NULL DEFAULT now(),
    mtime  TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE pigsty.cluster IS 'pigsty pgsql clusters from config';
COMMENT ON COLUMN pigsty.cluster.cls IS 'cluster name, primary key, can not change';
COMMENT ON COLUMN pigsty.cluster.shard IS 'cluster shard name (if applicable)';
COMMENT ON COLUMN pigsty.cluster.sindex IS 'cluster shard index (if applicable)';
COMMENT ON COLUMN pigsty.cluster.status IS 'cluster status: unknown|failed|available|creating|deleting';
COMMENT ON COLUMN pigsty.cluster.ctime IS 'cluster entry creation time';
COMMENT ON COLUMN pigsty.cluster.mtime IS 'cluster modification time';



--===========================================================--
--                          node                             --
--===========================================================--
-- node belongs to cluster, have 1:1 relation with pgsql instance
-- it's good to have a 'pg-buffer' cluster to hold all unused nodes

-- DROP TABLE IF EXISTS node CASCADE;
CREATE TABLE IF NOT EXISTS pigsty.node
(
    ip      INET PRIMARY KEY,
    cls     TEXT        NULL REFERENCES pigsty.cluster (cls) ON DELETE SET NULL ON UPDATE CASCADE,
    is_meta BOOLEAN     NOT NULL DEFAULT FALSE,
    status  status      NOT NULL DEFAULT 'unknown'::status,
    ctime   TIMESTAMPTZ NOT NULL DEFAULT now(),
    mtime   TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE pigsty.node IS 'pigsty nodes';
COMMENT ON COLUMN pigsty.node.ip IS 'node primary key: ip address';
COMMENT ON COLUMN pigsty.node.cls IS 'node must belong to a cluster, e.g pg-buffer ';
COMMENT ON COLUMN pigsty.node.is_meta IS 'true if node is a meta node';
COMMENT ON COLUMN pigsty.node.status IS 'node status: unknown|failed|available|creating|deleting';
COMMENT ON COLUMN pigsty.node.ctime IS 'node entry creation time';
COMMENT ON COLUMN pigsty.node.mtime IS 'node modification time';

--===========================================================--
--                        instance                           --
--===========================================================--
-- DROP TABLE IF EXISTS instance CASCADE;
CREATE TABLE IF NOT EXISTS pigsty.instance
(
    ins    TEXT PRIMARY KEY CHECK (ins = cls || '-' || seq::TEXT),
    ip     INET UNIQUE    NOT NULL REFERENCES pigsty.node (ip) ON DELETE CASCADE ON UPDATE CASCADE,
    cls    TEXT           NOT NULL REFERENCES pigsty.cluster (cls) ON DELETE CASCADE ON UPDATE CASCADE,
    seq    INTEGER        NOT NULL CHECK ( seq >= 0 ),
    role   pigsty.pg_role NOT NULL CHECK (role != 'unknown'::pigsty.pg_role),
    role_d pigsty.pg_role NOT NULL DEFAULT 'unknown'::pigsty.pg_role CHECK (role_d = ANY ('{unknown,primary,replica}'::pigsty.pg_role[]) ),
    status status         NOT NULL DEFAULT 'unknown'::status,
    ctime  TIMESTAMPTZ    NOT NULL DEFAULT now(),
    mtime  TIMESTAMPTZ    NOT NULL DEFAULT now()
);
COMMENT ON TABLE pigsty.instance IS 'pigsty pgsql instance';
COMMENT ON COLUMN pigsty.instance.ins IS 'instance name, pk, format as $cls-$seq';
COMMENT ON COLUMN pigsty.instance.ip IS 'ip address, semi-primary key, ref node.ip, unique';
COMMENT ON COLUMN pigsty.instance.cls IS 'cluster name: ref cluster.cls';
COMMENT ON COLUMN pigsty.instance.seq IS 'unique sequence among cluster';
COMMENT ON COLUMN pigsty.instance.role IS 'configured role';
COMMENT ON COLUMN pigsty.instance.role_d IS 'dynamic detected role: unknown|primary|replica ';
COMMENT ON COLUMN pigsty.instance.status IS 'instance status: unknown|failed|available|creating|deleting';
COMMENT ON COLUMN pigsty.instance.ctime IS 'instance entry creation time';
COMMENT ON COLUMN pigsty.instance.mtime IS 'instance modification time';


--===========================================================--
--                      global_vars                          --
--===========================================================--
-- hold global var definition (all.vars)

-- DROP TABLE IF EXISTS global_var;
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
--                      cluster_vars                         --
--===========================================================--
-- hold cluster var definition (all.children.<pg_cluster>.vars)

-- DROP TABLE IF EXISTS cluster_vars;
CREATE TABLE IF NOT EXISTS pigsty.cluster_var
(
    cls   TEXT  NOT NULL REFERENCES pigsty.cluster (cls) ON DELETE CASCADE ON UPDATE CASCADE,
    key   TEXT  NOT NULL CHECK (key != ''),
    value JSONB NULL,
    mtime TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (cls, key)
);
COMMENT ON TABLE pigsty.cluster_var IS 'cluster config entries';
COMMENT ON COLUMN pigsty.cluster_var.cls IS 'cluster name, ref cluster.cls';
COMMENT ON COLUMN pigsty.cluster_var.key IS 'cluster config entry name';
COMMENT ON COLUMN pigsty.cluster_var.value IS 'cluster entry value';
COMMENT ON COLUMN pigsty.cluster_var.mtime IS 'cluster config entry last modified time';

--===========================================================--
--                       instance_var                        --
--===========================================================--
-- DROP TABLE IF EXISTS instance_var;
CREATE TABLE IF NOT EXISTS pigsty.instance_var
(
    ins   TEXT  NOT NULL REFERENCES pigsty.instance (ins) ON DELETE CASCADE ON UPDATE CASCADE,
    key   TEXT  NOT NULL CHECK (key != ''),
    value JSONB NULL,
    mtime TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (ins, key)
);
COMMENT ON TABLE pigsty.instance_var IS 'instance config entries';
COMMENT ON COLUMN pigsty.instance_var.ins IS 'instance name, ref instance.ins';
COMMENT ON COLUMN pigsty.instance_var.key IS 'instance config entry name';
COMMENT ON COLUMN pigsty.instance_var.value IS 'instance entry value';
COMMENT ON COLUMN pigsty.instance_var.mtime IS 'instance config entry last modified time';


--===========================================================--
--                      instance_config                      --
--===========================================================--
-- cluster_config contains MERGED vars
-- ( vars = +cluster,  all_vars = +global & +cluster )

-- DROP VIEW IF EXISTS instance_config;
CREATE OR REPLACE VIEW pigsty.instance_config AS
SELECT c.cls,
       shard,
       sindex,
       i.ins,
       ip,
       iv.vars                       AS vars,         -- instance vars
       cv.vars                       AS cls_vars,     -- cluster vars
       cv.vars || iv.vars            AS cls_ins_vars, -- cluster + instance vars
       gv.vars || cv.vars || iv.vars AS all_vars      -- global + cluster + instance vars
FROM pigsty.cluster c
         JOIN pigsty.instance i USING (cls)
         JOIN (SELECT cls, jsonb_object_agg(key, value) AS vars FROM pigsty.cluster_var GROUP BY cls) cv
              ON c.cls = cv.cls
         JOIN (SELECT ins, jsonb_object_agg(key, value) AS vars FROM pigsty.instance_var GROUP BY ins) iv
              ON i.ins = iv.ins,
     (SELECT jsonb_object_agg(key, value) AS vars FROM pigsty.global_var) gv;
COMMENT ON VIEW pigsty.instance_config IS 'instance config view';



--===========================================================--
--                      cluster_config                       --
--===========================================================--
-- cluster_config contains MERGED vars (+global)
-- DROP VIEW IF EXISTS cluster_config CASCADE;
CREATE OR REPLACE VIEW pigsty.cluster_config AS
SELECT c.cls,
       shard,
       sindex,
       hosts,                                                                              -- cluster's members
       cv.vars                                                                 AS vars,    -- cluster vars
       jsonb_build_object(c.cls,
                          jsonb_build_object('hosts', hosts, 'vars', cv.vars)) AS config,  -- raw config: cls:{hosts:{},vars{}}
       gv.vars || cv.vars                                                      AS all_vars -- global + cluster vars
FROM pigsty.cluster c
         JOIN (SELECT cls, jsonb_object_agg(key, value) AS vars FROM pigsty.cluster_var GROUP BY cls) cv
              ON c.cls = cv.cls
         JOIN (SELECT cls, jsonb_object_agg(host(ip), vars) AS hosts FROM pigsty.instance_config GROUP BY cls) cm
              ON c.cls = cm.cls,
     (SELECT jsonb_object_agg(key, value) AS vars FROM pigsty.global_var) gv;
COMMENT ON VIEW pigsty.cluster_config IS 'cluster config view';


--===========================================================--
--                        cluster_user                       --
--===========================================================--
-- business user definition in pg_users

-- DROP VIEW IF EXISTS cluster_user;
CREATE OR REPLACE VIEW pigsty.cluster_user AS
SELECT cls,
       (u ->> 'name')                 AS name,
       (u ->> 'password')             AS password,
       (u ->> 'login')::BOOLEAN       AS login,
       (u ->> 'superuser') ::BOOLEAN  AS superuser,
       (u ->> 'createdb')::BOOLEAN    AS createdb,
       (u ->> 'createrole')::BOOLEAN  AS createrole,
       (u ->> 'inherit')::BOOLEAN     AS inherit,
       (u ->> 'replication')::BOOLEAN AS replication,
       (u ->> 'bypassrls')::BOOLEAN   AS bypassrls,
       (u ->> 'pgbouncer')::BOOLEAN   AS pgbouncer,
       (u ->> 'connlimit')::INTEGER   AS connlimit,
       (u ->> 'expire_in')::INTEGER   AS expire_in,
       (u ->> 'expire_at')::DATE      AS expire_at,
       (u ->> 'comment')              AS comment,
       (u -> 'roles')                 AS roles,
       (u -> 'parameters')            AS parameters,
       u                              AS raw
FROM pigsty.cluster_var cv,
     jsonb_array_elements(value) AS u
WHERE cv.key = 'pg_users';
COMMENT ON VIEW pigsty.cluster_user IS 'pg_users definition from cluster level vars';


--===========================================================--
--                      cluster_database                     --
--===========================================================--
-- business database definition in pg_databases

-- DROP VIEW IF EXISTS cluster_database;
CREATE OR REPLACE VIEW pigsty.cluster_database AS
SELECT cls,
       db ->> 'name'                  AS datname,
       (db ->> 'owner')               AS owner,
       (db ->> 'template')            AS template,
       (db ->> 'encoding')            AS encoding,
       (db ->> 'locale')              AS locale,
       (db ->> 'lc_collate')          AS lc_collate,
       (db ->> 'lc_ctype')            AS lc_ctype,
       (db ->> 'allowconn')::BOOLEAN  AS allowconn,
       (db ->> 'revokeconn')::BOOLEAN AS revokeconn,
       (db ->> 'tablespace')          AS tablespace,
       (db ->> 'connlimit')           AS connlimit,
       (db -> 'pgbouncer')::BOOLEAN   AS pgbouncer,
       (db ->> 'comment')             AS comment,
       (db -> 'extensions')::JSONB    AS extensions,
       (db -> 'parameters')::JSONB    AS parameters,
       db                             AS raw
FROM pigsty.cluster_var cv,
     jsonb_array_elements(value) AS db
WHERE cv.key = 'pg_databases';
COMMENT ON VIEW pigsty.cluster_database IS 'pg_databases definition from cluster level vars';


--===========================================================--
--                      cluster_service                      --
--===========================================================--
-- business database definition in pg_databases
CREATE OR REPLACE VIEW pigsty.cluster_service AS
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
       value                            AS raw
FROM (SELECT cls,
             coalesce(all_vars #> '{pg_services}', '[]'::JSONB) ||
             coalesce(all_vars #> '{pg_services_extra}', '[]'::JSONB) AS svcs
      FROM (
               SELECT c.cls, gv.vars || cv.vars AS all_vars
               FROM pigsty.cluster c
                        JOIN (SELECT cls, jsonb_object_agg(key, value) AS vars FROM pigsty.cluster_var GROUP BY cls) cv
                             ON c.cls = cv.cls,
                    (SELECT jsonb_object_agg(key, value) AS vars FROM pigsty.global_var) gv
           ) cf) s1,
     jsonb_array_elements(svcs) s2;
COMMENT ON VIEW pigsty.cluster_service IS 'services definition from cluster|global level vars';



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
--                          config                           --
--===========================================================--
-- API:
-- select_config(name text) jsonb
-- active_config_name() text
-- active_config() jsonb
-- upsert_config(jsonb,text) text
-- delete_config(name text) jsonb
-- clean_config
-- parse_config(jsonb)                    [private]
-- activate_config()
-- deactivate_config()

-----------------------------------------------
-- select_config(name text) jsonb
-----------------------------------------------
DROP FUNCTION IF EXISTS pigsty.select_config(_name TEXT);
CREATE OR REPLACE FUNCTION pigsty.select_config(_name TEXT) RETURNS JSONB AS
$$
SELECT data::JSONB
FROM pigsty.config
WHERE name = _name
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION pigsty.select_config(TEXT) IS 'return config data by name';

-----------------------------------------------
-- active_config_name() text
-----------------------------------------------
DROP FUNCTION IF EXISTS pigsty.active_config_name();
CREATE OR REPLACE FUNCTION pigsty.active_config_name() RETURNS TEXT AS
$$
SELECT name
FROM pigsty.config
WHERE is_active
LIMIT 1;
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION pigsty.active_config_name() IS 'return active config name, null if non is active';


-----------------------------------------------
-- active_config() jsonb
-----------------------------------------------
DROP FUNCTION IF EXISTS pigsty.active_config();
CREATE OR REPLACE FUNCTION pigsty.active_config() RETURNS JSONB AS
$$
SELECT data::JSONB
FROM pigsty.config
WHERE is_active
LIMIT 1;
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION pigsty.active_config() IS 'return activated config data';


-----------------------------------------------
-- upsert_config(jsonb,text) text
-----------------------------------------------
DROP FUNCTION IF EXISTS pigsty.upsert_config(JSONB, TEXT);
CREATE OR REPLACE FUNCTION pigsty.upsert_config(_config JSONB, _name TEXT DEFAULT NULL) RETURNS TEXT AS
$$
INSERT INTO pigsty.config(name, data, ctime, mtime)
VALUES ( coalesce(_name, 'config-' || (extract(epoch FROM date_trunc('second', now())))::BIGINT::TEXT)
       , _config::JSON, date_trunc('second', now()), date_trunc('second', now()))
ON CONFLICT (name) DO UPDATE SET data  = EXCLUDED.data,
                                 mtime = EXCLUDED.mtime
RETURNING name;
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION pigsty.upsert_config(JSONB, TEXT) IS 'upsert config with unique (manual|auto) config name';
-- if name is given, upsert with config name, otherwise use 'config-epoch' as unique config name

-----------------------------------------------
-- delete_config(name text) jsonb
-----------------------------------------------
DROP FUNCTION IF EXISTS pigsty.delete_config(TEXT);
CREATE OR REPLACE FUNCTION pigsty.delete_config(_name TEXT) RETURNS JSONB AS
$$
DELETE
FROM pigsty.config
WHERE name = _name
RETURNING data;
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION pigsty.delete_config(TEXT) IS 'delete config by name, return its content';

-----------------------------------------------
-- clean_config
-----------------------------------------------
-- WARNING: TRUNCATE pigsty config RELATED tables!
DROP FUNCTION IF EXISTS pigsty.clean_config();
CREATE OR REPLACE FUNCTION pigsty.clean_config() RETURNS VOID AS
$$
TRUNCATE pigsty.cluster,pigsty.instance,pigsty.node,pigsty.global_var,pigsty.cluster_var,pigsty.instance_var CASCADE;
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION pigsty.clean_config() IS 'TRUNCATE pigsty config RELATED tables cascade';


-----------------------------------------------
-- parse_config(jsonb) (private API)
-----------------------------------------------
-- WARNING: DO NOT USE THIS DIRECTLY (PRIVATE API)
DROP FUNCTION IF EXISTS pigsty.parse_config(JSONB);
CREATE OR REPLACE FUNCTION pigsty.parse_config(_data JSONB) RETURNS VOID AS
$$
DECLARE
    _clusters JSONB := _data #> '{all,children}';
BEGIN
    -- trunc tables
    -- TRUNCATE cluster,instance,node,global_var,cluster_var,instance_var CASCADE;

    -- load clusters
    INSERT INTO pigsty.cluster(cls, shard, sindex) -- abort on conflict
    SELECT key, value #>> '{vars,pg_shard}' AS shard, (value #>> '{vars,pg_sindex}')::INTEGER AS sindex
    FROM jsonb_each((_clusters))
    WHERE key != 'meta';

    -- load nodes
    INSERT INTO pigsty.node(ip, cls)
    SELECT key::INET AS ip, cls
    FROM -- abort on duplicate ip
         (SELECT key AS cls, value #> '{hosts}' AS hosts
          FROM jsonb_each(_clusters)
          WHERE key != 'meta') c, jsonb_each(c.hosts)
    ON CONFLICT (ip) DO UPDATE SET cls = EXCLUDED.cls;

    -- load meta nodes
    INSERT INTO pigsty.node(ip)
    SELECT key::INET AS ip
    FROM -- set is_meta flag for meta_node
         (SELECT key AS cls, value #> '{hosts}' AS hosts
          FROM jsonb_each((_clusters))
          WHERE key = 'meta') c, jsonb_each(c.hosts)
    ON CONFLICT(ip) DO UPDATE SET is_meta = true;

    -- load instances
    INSERT INTO pigsty.instance(ins, ip, cls, seq, role)
    SELECT cls || '-' || (value ->> 'pg_seq')    AS ins,
           key::INET                             AS ip,
           cls,
           (value ->> 'pg_seq')::INTEGER         AS seq,
           (value ->> 'pg_role')::pigsty.pg_role AS role
    FROM (SELECT key AS cls, value #> '{hosts}' AS hosts
          FROM jsonb_each(_clusters)
          WHERE key != 'meta') c, jsonb_each(c.hosts);

    -- load global_var
    INSERT INTO pigsty.global_var
    SELECT key, value
    FROM jsonb_each((SELECT _data #> '{all,vars}'))
    ON CONFLICT(key) DO UPDATE SET value = EXCLUDED.value;

    -- load cluster_var
    INSERT INTO pigsty.cluster_var(cls, key, value) -- abort on conflict
    SELECT cls, key, value
    FROM (SELECT key AS cls, value -> 'vars' AS vars
          FROM
              jsonb_each(_clusters)
          WHERE key != 'meta') c, jsonb_each(c.vars)
    ON CONFLICT(cls, key) DO UPDATE set value = EXCLUDED.value;

    -- load instance_var
    INSERT INTO pigsty.instance_var(ins, key, value) -- abort on conflict
    SELECT ins, key, value
    FROM (SELECT cls, cls || '-' || (value ->> 'pg_seq') AS ins, value AS vars
          FROM (SELECT key AS cls, value -> 'hosts' AS hosts
                FROM
                    jsonb_each(_clusters)
                WHERE key != 'meta') c,
              jsonb_each(c.hosts)) i, jsonb_each(vars)
    ON CONFLICT(ins, key) DO UPDATE SET value = EXCLUDED.value;

    -- inject meta_node config to instance_var
    INSERT INTO pigsty.instance_var(ins, key, value)
    SELECT ins, 'meta_node' AS key, 'true'::JSONB AS value
    FROM (SELECT ins
          FROM (SELECT key::INET AS ip
                FROM (SELECT key AS cls, value #> '{hosts}' AS hosts
                      FROM jsonb_each(_clusters)
                      WHERE key = 'meta') c, jsonb_each(c.hosts)) n
                   JOIN pigsty.instance i ON n.ip = i.ip
         ) m
    ON CONFLICT(ins, key) DO UPDATE SET value = excluded.value;

END;
$$ LANGUAGE PlPGSQL VOLATILE;
COMMENT ON FUNCTION pigsty.parse_config(JSONB) IS 'parse pigsty config file into tables';


-----------------------------------------------
-- deactivate_config
-----------------------------------------------
DROP FUNCTION IF EXISTS pigsty.deactivate_config();
CREATE OR REPLACE FUNCTION pigsty.deactivate_config() RETURNS JSONB AS
$$
SELECT pigsty.clean_config();
UPDATE pigsty.config
SET is_active = false
WHERE is_active
RETURNING data;
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION pigsty.deactivate_config() IS 'deactivate current config';


--------------------------------
-- activate_config
--------------------------------
DROP FUNCTION IF EXISTS pigsty.activate_config(TEXT);
CREATE OR REPLACE FUNCTION pigsty.activate_config(_name TEXT) RETURNS JSONB AS
$$
SELECT pigsty.deactivate_config();
SELECT pigsty.parse_config(pigsty.select_config(_name));
UPDATE pigsty.config
SET is_active = true
WHERE name = _name
RETURNING data;
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION pigsty.activate_config(TEXT) IS 'activate config by name';

-- example: SELECT activate_config('prod');


--------------------------------
-- dump_config
--------------------------------
-- generate ansible inventory from separated tables
-- depend on instance_config view

DROP FUNCTION IF EXISTS pigsty.dump_config() CASCADE;
CREATE OR REPLACE FUNCTION pigsty.dump_config() RETURNS JSONB AS
$$
SELECT (hostvars.data || allgroup.data || metagroup.data || groups.data) AS data
FROM (SELECT jsonb_build_object('_meta', jsonb_build_object('hostvars', jsonb_object_agg(host(ip), all_vars))) AS data
      FROM pigsty.instance_config) hostvars,
     (SELECT jsonb_build_object('all', jsonb_build_object('children', '["meta"]' || jsonb_agg(cls))) AS data
      FROM pigsty.cluster) allgroup,
     (SELECT jsonb_build_object('meta', jsonb_build_object('hosts', jsonb_agg(host(ip)))) AS data
      FROM pigsty.node
      WHERE is_meta) metagroup,
     (SELECT jsonb_object_agg(cls, cc.member) AS data
      FROM (SELECT cls, jsonb_build_object('hosts', jsonb_agg(host(ip))) AS member
            FROM pigsty.instance i
            GROUP BY cls) cc) groups;
$$ LANGUAGE SQL;
COMMENT ON FUNCTION pigsty.dump_config() IS 'dump ansible inventory config from entity tables';


--------------------------------
-- view: inventory
--------------------------------
-- return inventory in different format
CREATE OR REPLACE VIEW pigsty.inventory AS
SELECT data, data::TEXT as text, jsonb_pretty(data) AS pretty
FROM (SELECT pigsty.dump_config() AS data) i;



--===========================================================--
--                         node                              --
--===========================================================--
-- API:

-- node_cls(ip inet) (cls text)
-- node_is_meta(ip inet) bool
-- node_status(ip inet) status
-- node_ins(ip text) (ins text)
-- select_node(ip inet) jsonb
-- delete_node(ip inet)
-- upsert_node(ip inet, cls text) inet
-- update_node_status(ip inet, status status) status


--------------------------------
-- select_node(ip inet) jsonb
--------------------------------
DROP FUNCTION IF EXISTS pigsty.select_node(INET);
CREATE OR REPLACE FUNCTION pigsty.select_node(_ip INET) RETURNS JSONB AS
$$
SELECT row_to_json(node.*)::JSONB
FROM pigsty.node
WHERE ip = _ip
LIMIT 1;
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION pigsty.select_node(INET) IS 'return node json by ip';

-- SELECT select_node('10.189.201.88');

--------------------------------
-- node_cls(ip inet) (cls text)
--------------------------------
CREATE OR REPLACE FUNCTION pigsty.node_cls(_ip INET) RETURNS TEXT AS
$$
SELECT cls
FROM pigsty.node
WHERE ip = _ip
LIMIT 1;
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION pigsty.node_cls(INET) IS 'return node belonged cluster according to ip';
-- example: SELECT node_cls('10.10.10.10') -> pg-test

--------------------------------
-- node_is_meta(ip inet) bool
--------------------------------
DROP FUNCTION IF EXISTS pigsty.node_is_meta(INET);
CREATE OR REPLACE FUNCTION pigsty.node_is_meta(_ip INET) RETURNS BOOLEAN AS
$$
SELECT EXISTS(SELECT FROM pigsty.node WHERE is_meta AND ip = _ip);
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION pigsty.node_is_meta(INET) IS 'check whether an node (ip) is meta node';

--------------------------------
-- node_status(ip inet) status
--------------------------------
DROP FUNCTION IF EXISTS pigsty.node_status(INET);
CREATE OR REPLACE FUNCTION pigsty.node_status(_ip INET) RETURNS status AS
$$
SELECT status
FROM pigsty.node
WHERE ip = _ip;
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION pigsty.node_status(INET) IS 'get node status by ip';


--------------------------------
-- node_ins(ip text) (ins text)
--------------------------------
DROP FUNCTION IF EXISTS pigsty.node_ins(INET);
CREATE OR REPLACE FUNCTION pigsty.node_ins(_ip INET) RETURNS TEXT AS
$$
SELECT ins
FROM pigsty.instance
WHERE ip = _ip
LIMIT 1;
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION pigsty.node_ins(INET) IS 'return node corresponding pgsql instance according to ip';

--------------------------------
-- upsert_node(ip inet, cls text)
--------------------------------
-- insert new node with optional cluster
-- leave is_meta, ctime intact on upsert, reset cluster on non-null cluster, reset node status is cls has changed!

DROP FUNCTION IF EXISTS pigsty.upsert_node(INET, TEXT);
CREATE OR REPLACE FUNCTION pigsty.upsert_node(_ip INET, _cls TEXT DEFAULT NULL) RETURNS INET AS
$$
INSERT INTO pigsty.node(ip, cls)
VALUES (_ip, _cls)
ON CONFLICT (ip) DO UPDATE SET cls    = CASE WHEN _cls ISNULL THEN node.cls ELSE excluded.cls END,
                               status = CASE
                                            WHEN _cls IS NOT NULL AND _cls != node.cls THEN 'unknown'::status
                                            ELSE node.status END, -- keep status if cls not changed
                               mtime  = now()
RETURNING ip;
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION pigsty.upsert_node(INET, TEXT) IS 'upsert new node (with optional cls)';

-- example
-- SELECT upsert_node('10.10.10.10', 'pg-meta');

--------------------------------
-- delete_node(ip inet )
--------------------------------
DROP FUNCTION IF EXISTS pigsty.delete_node(INET);
CREATE OR REPLACE FUNCTION pigsty.delete_node(_ip INET) RETURNS INET AS
$$
DELETE
FROM pigsty.node
WHERE ip = _ip
RETURNING ip;
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION pigsty.delete_node(INET) IS 'delete node by ip';

-- example
-- SELECT delete_node('10.10.10.10');

-----------------------------------------------
-- update_node_status(ip inet, status status) status
-----------------------------------------------
DROP FUNCTION IF EXISTS pigsty.update_node_status(INET, status);
CREATE OR REPLACE FUNCTION pigsty.update_node_status(_ip INET, _status status) RETURNS status AS
$$
UPDATE pigsty.node
SET status = _status
WHERE ip = _ip
RETURNING status;
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION pigsty.update_node_status(INET,status) IS 'update node status and return it';

-- example:  SELECT update_node_status('10.10.10.10', 'available');


--===========================================================--
--                        instance var                       --
--===========================================================--

-----------------------------------------------
-- update_instance_vars(ins text, vars jsonb) jsonb
-----------------------------------------------

-- overwrite all instance vars
DROP FUNCTION IF EXISTS pigsty.update_instance_vars(TEXT, JSONB);
CREATE OR REPLACE FUNCTION pigsty.update_instance_vars(_ins TEXT, _vars JSONB) RETURNS VOID AS
$$
DELETE
FROM pigsty.instance_var
WHERE ins = _ins; -- delete all instance vars
INSERT INTO pigsty.instance_var(ins, key, value)
SELECT _ins, key, value
FROM jsonb_each(_vars);
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION pigsty.update_instance_vars(TEXT, JSONB) IS 'batch overwrite instance config';


-----------------------------------------------
-- update_instance_var(ins text, key text, value jsonb)
-----------------------------------------------

-- overwrite single instance entry
DROP FUNCTION IF EXISTS pigsty.update_instance_var(TEXT, TEXT, JSONB);
CREATE OR REPLACE FUNCTION pigsty.update_instance_var(_ins TEXT, _key TEXT, _value JSONB) RETURNS VOID AS
$$
INSERT INTO pigsty.instance_var(ins, key, value)
VALUES (_ins, _key, _value)
ON CONFLICT (ins, key) DO UPDATE SET value = EXCLUDED.value,
                                     mtime = now();
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION pigsty.update_instance_var(TEXT, TEXT,JSONB) IS 'upsert single instance config entry';



--===========================================================--
--                      getter                               --
--===========================================================--
CREATE OR REPLACE FUNCTION pigsty.ins_ip(_ins TEXT) RETURNS TEXT AS
$$
SELECT host(ip)
FROM pigsty.instance
WHERE ins = _ins
LIMIT 1;
$$ LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION pigsty.ins_cls(_ins TEXT) RETURNS TEXT AS
$$
SELECT cls
FROM pigsty.instance
WHERE ins = _ins
LIMIT 1;
$$ LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION pigsty.ins_role(_ins TEXT) RETURNS TEXT AS
$$
SELECT role
FROM pigsty.instance
WHERE ins = _ins
LIMIT 1;
$$ LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION pigsty.ins_seq(_ins TEXT) RETURNS INTEGER AS
$$
SELECT seq
FROM pigsty.instance
WHERE ins = _ins
LIMIT 1;
$$ LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION pigsty.ins_is_meta(_ins TEXT) RETURNS BOOLEAN AS
$$
SELECT EXISTS(SELECT FROM pigsty.node WHERE is_meta AND ip = (SELECT ip FROM pigsty.instance WHERE ins = _ins));
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION pigsty.ins_is_meta(TEXT) IS 'check whether an instance name is meta node';

-- reverse lookup (lookup ins via ip)
CREATE OR REPLACE FUNCTION pigsty.ip2ins(_ip INET) RETURNS TEXT AS
$$
SELECT ins
FROM pigsty.instance
WHERE ip = _ip
LIMIT 1;
$$ LANGUAGE SQL STABLE;



--===========================================================--
--                     instance CRUD                         --
--===========================================================--

-----------------------------------------------
-- select_instance(ins text)
-----------------------------------------------
DROP FUNCTION IF EXISTS pigsty.select_instance(TEXT);
CREATE OR REPLACE FUNCTION pigsty.select_instance(_ins TEXT) RETURNS JSONB AS
$$
SELECT row_to_json(i.*)::JSONB
FROM pigsty.instance i
WHERE ins = _ins
LIMIT 1;
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION select_instance(TEXT) IS 'return instance json via ins';
-- example: SELECT select_instance('pg-test-1')


-----------------------------------------------
-- select_instance(ip inet)
-----------------------------------------------
DROP FUNCTION IF EXISTS pigsty.select_instance(INET);
CREATE OR REPLACE FUNCTION pigsty.select_instance(_ip INET) RETURNS JSONB AS
$$
SELECT row_to_json(i.*)::JSONB
FROM pigsty.instance i
WHERE ip = _ip
LIMIT 1;
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION select_instance(INET) IS 'return instance json via ip';


-----------------------------------------------
-- upsert_instance(ins text, ip inet, data jsonb)
-----------------------------------------------
DROP FUNCTION IF EXISTS pigsty.upsert_instance(TEXT, INET, JSONB);
CREATE OR REPLACE FUNCTION pigsty.upsert_instance(_cls TEXT, _ip INET, _data JSONB) RETURNS VOID AS
$$
DECLARE
    _seq  INTEGER        := (_data ->> 'pg_seq')::INTEGER;
    _role pigsty.pg_role := (_data ->> 'pg_role')::pigsty.pg_role;
    _ins  TEXT           := _cls || '-' || _seq;
BEGIN
    PERFORM pigsty.upsert_node(_ip, _cls); -- make sure node exists
    INSERT INTO pigsty.instance(ins, ip, cls, seq, role)
    VALUES (_ins, _ip, _cls, _seq, _role)
    ON CONFLICT DO UPDATE SET ip    = excluded.ip,
                              cls   = excluded.cls,
                              seq   = excluded.seq,
                              role  = excluded.role,
                              mtime = now();
    PERFORM pigsty.update_instance_vars(_ins, _data); -- refresh instance_var
END
$$ LANGUAGE PlPGSQL VOLATILE;
COMMENT ON FUNCTION pigsty.upsert_instance(TEXT, INET, JSONB) IS 'create new instance from cls, ip, vars';



--===========================================================--
--                      cluster var update                   --
--===========================================================--

-- overwrite all cluster config
DROP FUNCTION IF EXISTS pigsty.update_cluster_vars(TEXT, JSONB);
CREATE OR REPLACE FUNCTION pigsty.update_cluster_vars(_cls TEXT, _vars JSONB) RETURNS VOID AS
$$
DELETE
FROM pigsty.cluster_var
WHERE cls = _cls; -- delete all cluster vars
INSERT INTO pigsty.cluster_var(cls, key, value)
SELECT _cls, key, value
FROM jsonb_each(_vars);
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION pigsty.update_cluster_vars(TEXT, JSONB) IS 'batch overwrite cluster config';

-- overwrite single cluster config entry
DROP FUNCTION IF EXISTS pigsty.update_cluster_var(TEXT, TEXT, JSONB);
CREATE OR REPLACE FUNCTION pigsty.update_cluster_var(_cls TEXT, _key TEXT, _value JSONB) RETURNS VOID AS
$$
INSERT INTO pigsty.cluster_var(cls, key, value, mtime)
VALUES (_cls, _key, _value, now())
ON CONFLICT (cls, key) DO UPDATE SET value = EXCLUDED.value,
                                     mtime = EXCLUDED.mtime;
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION pigsty.update_cluster_var(_cls TEXT, key TEXT, value JSONB) IS 'upsert single cluster config entry';



--===========================================================--
--                        cluster crud                        --
--===========================================================--
DROP FUNCTION IF EXISTS pigsty.select_cluster(TEXT);
CREATE OR REPLACE FUNCTION pigsty.select_cluster(_cls TEXT) RETURNS JSONB AS
$$
SELECT row_to_json(cluster.*)::JSONB
FROM pigsty.cluster
WHERE cls = _cls
LIMIT 1;
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION pigsty.select_cluster(TEXT) IS 'return cluster json via cls';
-- example: SELECT select_cluster('pg-meta-tt')


DROP FUNCTION IF EXISTS pigsty.delete_cluster(TEXT);
CREATE OR REPLACE FUNCTION pigsty.select_cluster(_cls TEXT) RETURNS JSONB AS
$$
SELECT row_to_json(cluster.*)::JSONB
FROM pigsty.cluster
WHERE cls = _cls
LIMIT 1;
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION pigsty.select_cluster(TEXT) IS 'return cluster json via cls';


-- SELECT jsonb_build_object('hosts', jsonb_object_agg(ip, row_to_json(instance.*))) AS ij FROM instance WHERE cls = 'pg-meta-tt' GROUP BY cls;
-- SELECT jsonb_build_object('vars', jsonb_object_agg(key, value)) AS ij FROM cluster_var WHERE cls = 'pg-meta-tt' GROUP BY cls;

DROP FUNCTION IF EXISTS pigsty.upsert_clusters(_data JSONB);
CREATE OR REPLACE FUNCTION pigsty.upsert_clusters(_data JSONB) RETURNS VOID AS
$$
DECLARE
    _clusters JSONB := _data; -- input is all.children (cluster array)
BEGIN
    -- trunc tables
    -- TRUNCATE cluster,instance,node,global_var,cluster_var,instance_var CASCADE;
    DELETE
    FROM pigsty.cluster
    WHERE cls IN
          (SELECT key FROM jsonb_each((_clusters)) WHERE key != 'meta');

    -- load clusters
    INSERT INTO pigsty.cluster(cls, shard, sindex) -- abort on conflict
    SELECT key, value #>> '{vars,pg_shard}' AS shard, (value #>> '{vars,pg_sindex}')::INTEGER AS sindex
    FROM jsonb_each((_clusters))
    WHERE key != 'meta';

    -- load nodes
    INSERT INTO pigsty.node(ip, cls)
    SELECT key::INET AS ip, cls
    FROM -- abort on duplicate ip
         (SELECT key AS cls, value #> '{hosts}' AS hosts
          FROM jsonb_each(_clusters)
          WHERE key != 'meta') c, jsonb_each(c.hosts)
    ON CONFLICT(ip) DO UPDATE SET cls = EXCLUDED.cls;

    -- load meta nodes
    INSERT INTO pigsty.node(ip)
    SELECT key::INET AS ip
    FROM -- set is_meta flag for meta_node
         (SELECT key AS cls, value #> '{hosts}' AS hosts
          FROM jsonb_each((_clusters))
          WHERE key = 'meta') c, jsonb_each(c.hosts)
    ON CONFLICT(ip) DO UPDATE SET cls = EXCLUDED.cls, is_meta = true;

    -- load instances
    INSERT INTO pigsty.instance(ins, ip, cls, seq, role)
    SELECT cls || '-' || (value ->> 'pg_seq')    AS ins,
           key::INET                             AS ip,
           cls,
           (value ->> 'pg_seq')::INTEGER         AS seq,
           (value ->> 'pg_role')::pigsty.pg_role AS role
    FROM (SELECT key AS cls, value #> '{hosts}' AS hosts
          FROM jsonb_each(_clusters)
          WHERE key != 'meta') c, jsonb_each(c.hosts);

    -- load cluster_var
    INSERT INTO pigsty.cluster_var(cls, key, value) -- abort on conflict
    SELECT cls, key, value
    FROM (SELECT key AS cls, value -> 'vars' AS vars
          FROM
              jsonb_each(_clusters)
          WHERE key != 'meta') c, jsonb_each(c.vars)
    ON CONFLICT(cls, key) DO UPDATE set value = EXCLUDED.value;

    -- load instance_var
    INSERT INTO pigsty.instance_var(ins, key, value) -- abort on conflict
    SELECT ins, key, value
    FROM (SELECT cls, cls || '-' || (value ->> 'pg_seq') AS ins, value AS vars
          FROM (SELECT key AS cls, value -> 'hosts' AS hosts
                FROM jsonb_each(_clusters)
                WHERE key != 'meta') c,
              jsonb_each(c.hosts)) i, jsonb_each(vars)
    ON CONFLICT(ins, key) DO UPDATE SET value = EXCLUDED.value;

    -- inject meta_node config to instance_var
    INSERT INTO pigsty.instance_var(ins, key, value)
    SELECT ins, 'meta_node' AS key, 'true'::JSONB AS value
    FROM (SELECT ins
          FROM (SELECT key::INET AS ip
                FROM (SELECT key AS cls, value #> '{hosts}' AS hosts
                      FROM jsonb_each(_clusters)
                      WHERE key = 'meta') c, jsonb_each(c.hosts)) n
                   JOIN pigsty.instance i ON n.ip = i.ip
         ) m
    ON CONFLICT(ins, key) DO UPDATE SET value = excluded.value;

END;
$$ LANGUAGE PlPGSQL VOLATILE;

COMMENT ON FUNCTION pigsty.upsert_clusters(JSONB) IS 'upsert pgsql clusters all.childrens';


--===========================================================--
--                      global var update                    --
--===========================================================--
-- update_global_vars(vars JSON) will overwrite existing global config
-- update_global_var(key TEXT,value JSON) will upsert single global config entry

--------------------------------
-- update_global_vars(vars jsonb)
--------------------------------
DROP FUNCTION IF EXISTS pigsty.update_global_vars(JSONB);
CREATE OR REPLACE FUNCTION pigsty.update_global_vars(_vars JSONB) RETURNS VOID AS
$$
DELETE
FROM pigsty.global_var
WHERE true; -- use vars will remove all existing config files
INSERT INTO pigsty.global_var(key, value)
SELECT key, value
FROM jsonb_each(_vars);
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION pigsty.update_global_vars(JSONB) IS 'batch overwrite global config';

--------------------------------
-- update_global_var(key text, value jsonb)
--------------------------------
DROP FUNCTION IF EXISTS pigsty.update_global_var(TEXT, JSONB);
CREATE OR REPLACE FUNCTION pigsty.update_global_var(_key TEXT, _value JSONB) RETURNS VOID AS
$$
INSERT INTO pigsty.global_var(key, value, mtime)
VALUES (_key, _value, now())
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value,
                                mtime = EXCLUDED.mtime;
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION pigsty.update_global_var(TEXT,JSONB) IS 'upsert single global config entry';



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
    sln      bigint,      -- session line number
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
    backend  TEXT,        -- backend_type (new field in PG13)
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
CREATE TABLE pglog.sample14(backend TEXT, leader_pid INTEGER, query_id   BIGINT) INHERITS (pglog.sample);
COMMENT ON TABLE pglog.sample12 IS 'PostgreSQL 12- CSVLOG sample for Pigsty PGLOG analysis';
COMMENT ON TABLE pglog.sample13 IS 'PostgreSQL 13 CSVLOG sample for Pigsty PGLOG analysis';
COMMENT ON TABLE pglog.sample14 IS 'PostgreSQL 14 CSVLOG sample for Pigsty PGLOG analysis';


--===========================================================--
--                       pigsty setting                      --
--===========================================================--
DROP TABLE IF EXISTS pigsty.setting CASCADE;
CREATE TABLE pigsty.setting
(
    id            INTEGER PRIMARY KEY,
    name          VARCHAR(128) NOT NULL,
    category      VARCHAR(16)  NOT NULL,
    section       VARCHAR(32)  NOT NULL,
    type          VARCHAR(16)  NOT NULL DEFAULT 'string'::text NOT NULL,
    level         VARCHAR(16)  NOT NULL,
    comment_cn    VARCHAR(512),
    comment_en    VARCHAR(512),
    section_desc  VARCHAR(256),
    default_value JSONB,
    link_name     TEXT GENERATED ALWAYS AS ('[`'|| name || '`](#' || name || ')') STORED,
    link_section  TEXT GENERATED ALWAYS AS ('[`'|| section ||'`](#'|| section ||')') STORED,
    link_category TEXT GENERATED ALWAYS AS ('[`'|| category ||'`](v-'|| lower(category) ||'.md)') STORED,
    link_namex    TEXT GENERATED ALWAYS AS ('[`' || name || '`](v-'|| lower(category) ||'.md#' || name ||')') STORED,
    link_sectionx TEXT GENERATED ALWAYS AS ('[`' || section || '`](v-'|| lower(category) ||'.md#' || section ||')') STORED
);

INSERT INTO pigsty.setting(id,name,category,section,type,level,comment_cn,comment_en,section_desc,default_value) VALUES
(100, 'proxy_env', 'INFRA', 'CONNECT', 'dict', 'G', '代理服务器配置', 'proxy environment variables', '连接参数', '{"no_proxy": "localhost,127.0.0.1,10.0.0.0/8,192.168.0.0/16,*.pigsty,*.aliyun.com,mirrors.*,*.myqcloud.com"}'),
(110, 'repo_enabled', 'INFRA', 'REPO', 'bool', 'G', '是否启用本地源', 'enable local yum repo', '本地源基础设施', 'true'),
(111, 'repo_name', 'INFRA', 'REPO', 'string', 'G', '本地源名称', 'local yum repo name', '本地源基础设施', '"pigsty"'),
(112, 'repo_address', 'INFRA', 'REPO', 'string', 'G', '本地源外部访问地址', 'external access endpoint of repo', '本地源基础设施', '"pigsty"'),
(113, 'repo_port', 'INFRA', 'REPO', 'int', 'G', '本地源端口', 'repo listen address (80)', '本地源基础设施', '80'),
(114, 'repo_home', 'INFRA', 'REPO', 'path', 'G', '本地源文件根目录', 'repo home dir (/www)', '本地源基础设施', '"/www"'),
(115, 'repo_rebuild', 'INFRA', 'REPO', 'bool', 'A', '是否重建Yum源', 'rebuild local yum repo?', '本地源基础设施', 'false'),
(116, 'repo_remove', 'INFRA', 'REPO', 'bool', 'A', '是否移除已有REPO文件', 'remove existing repo file?', '本地源基础设施', 'true'),
(117, 'repo_upstreams', 'INFRA', 'REPO', 'repo[]', 'G', 'Yum源的上游来源', 'upstream repo definition', '本地源基础设施', '[{"name": "base", "baseurl": ["https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/os/$basearch/", "http://mirrors.aliyun.com/centos/$releasever/os/$basearch/", "http://mirrors.aliyuncs.com/centos/$releasever/os/$basearch/", "http://mirrors.cloud.aliyuncs.com/centos/$releasever/os/$basearch/", "http://mirror.centos.org/centos/$releasever/os/$basearch/"], "gpgcheck": false, "description": "CentOS-$releasever - Base"}, {"name": "updates", "baseurl": ["https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/updates/$basearch/", "http://mirrors.aliyun.com/centos/$releasever/updates/$basearch/", "http://mirrors.aliyuncs.com/centos/$releasever/updates/$basearch/", "http://mirrors.cloud.aliyuncs.com/centos/$releasever/updates/$basearch/", "http://mirror.centos.org/centos/$releasever/updates/$basearch/"], "gpgcheck": false, "description": "CentOS-$releasever - Updates"}, {"name": "extras", "baseurl": ["https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/extras/$basearch/", "http://mirrors.aliyun.com/centos/$releasever/extras/$basearch/", "http://mirrors.aliyuncs.com/centos/$releasever/extras/$basearch/", "http://mirrors.cloud.aliyuncs.com/centos/$releasever/extras/$basearch/", "http://mirror.centos.org/centos/$releasever/extras/$basearch/"], "gpgcheck": false, "description": "CentOS-$releasever - Extras"}, {"name": "epel", "baseurl": ["https://mirrors.tuna.tsinghua.edu.cn/epel/$releasever/$basearch", "http://mirrors.aliyun.com/epel/$releasever/$basearch", "http://download.fedoraproject.org/pub/epel/$releasever/$basearch"], "gpgcheck": false, "description": "CentOS $releasever - epel"}, {"name": "grafana", "baseurl": ["https://mirrors.tuna.tsinghua.edu.cn/grafana/yum/rpm", "https://packages.grafana.com/oss/rpm"], "enabled": true, "gpgcheck": false, "description": "Grafana"}, {"name": "prometheus", "baseurl": "https://packagecloud.io/prometheus-rpm/release/el/$releasever/$basearch", "gpgcheck": false, "description": "Prometheus and exporters"}, {"name": "pgdg-common", "baseurl": ["http://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/redhat/rhel-$releasever-$basearch", "https://download.postgresql.org/pub/repos/yum/common/redhat/rhel-$releasever-$basearch"], "gpgcheck": false, "description": "PostgreSQL common RPMs for RHEL/CentOS $releasever - $basearch"}, {"name": "pgdg13", "baseurl": ["https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/13/redhat/rhel-$releasever-$basearch", "https://download.postgresql.org/pub/repos/yum/13/redhat/rhel-$releasever-$basearch"], "gpgcheck": false, "description": "PostgreSQL 13 for RHEL/CentOS $releasever - $basearch"}, {"name": "pgdg14", "baseurl": ["https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/14/redhat/rhel-$releasever-$basearch", "https://download.postgresql.org/pub/repos/yum/14/redhat/rhel-$releasever-$basearch"], "gpgcheck": false, "description": "PostgreSQL 14 for RHEL/CentOS $releasever - $basearch"}, {"name": "timescaledb", "baseurl": ["https://packagecloud.io/timescale/timescaledb/el/7/$basearch"], "gpgcheck": false, "description": "TimescaleDB for RHEL/CentOS $releasever - $basearch"}, {"name": "centos-sclo", "baseurl": ["http://mirrors.aliyun.com/centos/$releasever/sclo/$basearch/sclo/", "http://repo.virtualhosting.hk/centos/$releasever/sclo/$basearch/sclo/"], "gpgcheck": false, "description": "CentOS-$releasever - SCLo"}, {"name": "centos-sclo-rh", "baseurl": ["http://mirrors.aliyun.com/centos/$releasever/sclo/$basearch/rh/", "http://repo.virtualhosting.hk/centos/$releasever/sclo/$basearch/rh/"], "gpgcheck": false, "description": "CentOS-$releasever - SCLo rh"}, {"name": "nginx", "baseurl": "http://nginx.org/packages/centos/$releasever/$basearch/", "gpgcheck": false, "description": "Nginx Official Yum Repo", "skip_if_unavailable": true}, {"name": "harbottle", "baseurl": "https://download.copr.fedorainfracloud.org/results/harbottle/main/epel-$releasever-$basearch/", "gpgcheck": false, "description": "Copr repo for main owned by harbottle", "skip_if_unavailable": true}]'),
(118, 'repo_packages', 'INFRA', 'REPO', 'string[]', 'G', 'Yum源需下载软件列表', 'packages to be downloaded', '本地源基础设施', '["epel-release nginx wget yum-utils yum createrepo sshpass zip unzip", "ntp chrony uuid lz4 bzip2 nc pv jq vim-enhanced make patch bash lsof wget git tuned perf ftp lrzsz rsync", "numactl grubby sysstat dstat iotop bind-utils net-tools tcpdump socat ipvsadm telnet ca-certificates keepalived", "readline zlib openssl openssh-clients libyaml libxml2 libxslt libevent perl perl-devel perl-ExtUtils*", "readline-devel zlib-devel uuid-devel libuuid-devel libxml2-devel libxslt-devel openssl-devel libicu-devel", "ed mlocate parted krb5-devel apr apr-util audit", "grafana prometheus2 pushgateway alertmanager consul consul_exporter consul-template etcd dnsmasq", "node_exporter postgres_exporter nginx_exporter blackbox_exporter redis_exporter", "ansible python python-pip python-psycopg2", "python3 python3-psycopg2 python36-requests python3-etcd python3-consul python36-urllib3 python36-idna python36-pyOpenSSL python36-cryptography", "patroni patroni-consul patroni-etcd pgbouncer pg_cli pgbadger pg_activity tail_n_mail", "pgcenter boxinfo check_postgres emaj pgbconsole pg_bloat_check pgquarrel barman barman-cli pgloader pgFormatter pitrery pspg pgxnclient PyGreSQL pgadmin4", "postgresql14* postgis32_14* citus_14* pglogical_14* timescaledb-2-postgresql-14 pg_repack_14 wal2json_14", "pg_qualstats_14 pg_stat_kcache_14 pg_stat_monitor_14 pg_top_14 pg_track_settings_14 pg_wait_sampling_14", "pg_statement_rollback_14 system_stats_14 plproxy_14 plsh_14 pldebugger_14 plpgsql_check_14 pgmemcache_14", "mysql_fdw_14 ogr_fdw_14 tds_fdw_14 sqlite_fdw_14 firebird_fdw_14 hdfs_fdw_14 mongo_fdw_14 osm_fdw_14 pgbouncer_fdw_14", "hypopg_14 geoip_14 rum_14 hll_14 ip4r_14 prefix_14 pguri_14 tdigest_14 topn_14 periods_14", "bgw_replstatus_14 count_distinct_14 credcheck_14 ddlx_14 extra_window_functions_14 logerrors_14 mysqlcompat_14 orafce_14", "repmgr_14 pg_auth_mon_14 pg_auto_failover_14 pg_background_14 pg_bulkload_14 pg_catcheck_14 pg_comparator_14", "pg_cron_14 pg_fkpart_14 pg_jobmon_14 pg_partman_14 pg_permissions_14 pg_prioritize_14 pgagent_14", "pgaudit16_14 pgauditlogtofile_14 pgcryptokey_14 pgexportdoc_14 pgfincore_14 pgimportdoc_14 powa_14 pgmp_14 pgq_14", "pgquarrel-0.7.0-1 pgsql_tweaks_14 pgtap_14 pgtt_14 postgresql-unit_14 postgresql_anonymizer_14 postgresql_faker_14", "safeupdate_14 semver_14 set_user_14 sslutils_14 table_version_14", "clang coreutils diffutils rpm-build rpm-devel rpmlint rpmdevtools bison flex"]'),
(119, 'repo_url_packages', 'INFRA', 'REPO', 'url[]', 'G', '通过URL直接下载的软件', 'pkgs to be downloaded via url', '本地源基础设施', '["https://github.com/cybertec-postgresql/vip-manager/releases/download/v1.0.1/vip-manager_1.0.1-1_amd64.rpm", "https://github.com/Vonng/pg_exporter/releases/download/v0.4.1/pg_exporter-0.4.1-1.el7.x86_64.rpm", "https://github.com/Vonng/pigsty-pkg/releases/download/haproxy/haproxy-2.5.5-1.el7.x86_64.rpm", "https://github.com/Vonng/loki-rpm/releases/download/v2.4.2/loki-2.4.2-1.el7.x86_64.rpm", "https://github.com/Vonng/loki-rpm/releases/download/v2.4.2/promtail-2.4.2-1.el7.x86_64.rpm", "https://github.com/Vonng/pigsty-pkg/releases/download/postgrest/postgrest-9.0.0-1.el7.x86_64.rpm", "https://github.com/Vonng/pigsty-pkg/releases/download/misc/polysh-0.4-1.noarch.rpm", "https://github.com/dalibo/pev2/releases/download/v0.24.0/pev2.tar.gz", "https://github.com/sosedoff/pgweb/releases/download/v0.11.10/pgweb_linux_amd64.zip", "https://github.com/Vonng/pigsty-pkg/releases/download/misc/redis-6.2.6-1.el7.remi.x86_64.rpm"]'),
(120, 'ca_method', 'INFRA', 'CA', 'enum', 'G', 'CA的创建方式', 'ca mode, create,copy,recreate', '公私钥基础设施', '"create"'),
(121, 'ca_subject', 'INFRA', 'CA', 'string', 'G', '自签名CA主题', 'ca subject', '公私钥基础设施', '"/CN=root-ca"'),
(122, 'ca_homedir', 'INFRA', 'CA', 'path', 'G', 'CA证书根目录', 'ca cert home dir', '公私钥基础设施', '"/ca"'),
(123, 'ca_cert', 'INFRA', 'CA', 'string', 'G', 'CA证书', 'ca cert file name', '公私钥基础设施', '"ca.crt"'),
(124, 'ca_key', 'INFRA', 'CA', 'string', 'G', 'CA私钥名称', 'ca private key name', '公私钥基础设施', '"ca.key"'),
(130, 'nginx_upstream', 'INFRA', 'NGINX', 'upstream[]', 'G', 'Nginx上游服务器', 'nginx upstream definition', 'NginxWeb服务器', '[{"name": "home", "domain": "pigsty", "endpoint": "10.10.10.10:80"}, {"name": "grafana", "domain": "g.pigsty", "endpoint": "10.10.10.10:3000"}, {"name": "loki", "domain": "l.pigsty", "endpoint": "10.10.10.10:3100"}, {"name": "prometheus", "domain": "p.pigsty", "endpoint": "10.10.10.10:9090"}, {"name": "alertmanager", "domain": "a.pigsty", "endpoint": "10.10.10.10:9093"}, {"name": "consul", "domain": "c.pigsty", "endpoint": "127.0.0.1:8500"}, {"name": "pgweb", "domain": "cli.pigsty", "endpoint": "127.0.0.1:8081"}, {"name": "jupyter", "domain": "lab.pigsty", "endpoint": "127.0.0.1:8888"}]'),
(131, 'app_list', 'INFRA', 'NGINX', 'app[]', 'G', '首页导航栏显示的应用列表', 'app list on home page navbar', 'NginxWeb服务器', '[{"url": "/pev2", "name": "Pev2", "comment": "postgres explain visualizer 2"}, {"url": "/logs", "name": "Logs", "comment": "realtime pgbadger log sample"}, {"url": "/report", "name": "Report", "comment": "daily log summary report "}, {"url": "/pigsty", "name": "Pkgs", "comment": "local yum repo packages"}, {"url": "/pigsty.repo", "name": "Repo", "comment": "local yum repo file"}, {"url": "${grafana}/d/isd-overview", "name": "ISD", "comment": "noaa isd data visualization"}, {"url": "${grafana}/d/covid-overview", "name": "Covid", "comment": "covid data visualization"}]'),
(132, 'docs_enabled', 'INFRA', 'NGINX', 'bool', 'G', '是否启用本地文档', 'enable local docs', 'NginxWeb服务器', 'true'),
(133, 'pev2_enabled', 'INFRA', 'NGINX', 'bool', 'G', '是否启用PEV2组件', 'enable pev2', 'NginxWeb服务器', 'true'),
(134, 'pgbadger_enabled', 'INFRA', 'NGINX', 'bool', 'G', '是否启用Pgbadger', 'enable pgbadger', 'NginxWeb服务器', 'true'),
(140, 'dns_records', 'INFRA', 'NAMESERVER', 'string[]', 'G', '动态DNS解析记录', 'dynamic DNS records', 'DNS服务器', '["10.10.10.2  pg-meta", "10.10.10.3  pg-test", "10.10.10.10 meta-1", "10.10.10.11 node-1", "10.10.10.12 node-2", "10.10.10.13 node-3", "10.10.10.10 pg-meta-1", "10.10.10.11 pg-test-1", "10.10.10.12 pg-test-2", "10.10.10.13 pg-test-3"]'),
(150, 'prometheus_data_dir', 'INFRA', 'PROMETHEUS', 'path', 'G', 'Prometheus数据库目录', 'prometheus data dir', '监控时序数据库', '"/data/prometheus/data"'),
(151, 'prometheus_options', 'INFRA', 'PROMETHEUS', 'string', 'G', 'Prometheus命令行参数', 'prometheus cli args', '监控时序数据库', '"--storage.tsdb.retention=15d --enable-feature=promql-negative-offset"'),
(152, 'prometheus_reload', 'INFRA', 'PROMETHEUS', 'bool', 'A', 'Reload而非Recreate', 'prom reload instead of init', '监控时序数据库', 'false'),
(153, 'prometheus_sd_method', 'INFRA', 'PROMETHEUS', 'enum', 'G', '服务发现机制：static|consul', 'service discovery method: static|consul', '监控时序数据库', '"static"'),
(154, 'prometheus_scrape_interval', 'INFRA', 'PROMETHEUS', 'interval', 'G', 'Prom抓取周期', 'prom scrape interval (10s)', '监控时序数据库', '"10s"'),
(155, 'prometheus_scrape_timeout', 'INFRA', 'PROMETHEUS', 'interval', 'G', 'Prom抓取超时', 'prom scrape timeout (8s)', '监控时序数据库', '"8s"'),
(156, 'prometheus_sd_interval', 'INFRA', 'PROMETHEUS', 'interval', 'G', 'Prom服务发现刷新周期', 'prom discovery refresh interval', '监控时序数据库', '"10s"'),
(160, 'exporter_install', 'INFRA', 'EXPORTER', 'enum', 'G', '安装监控组件的方式', 'how to install exporter?', '通用Exporter配置', '"none"'),
(161, 'exporter_repo_url', 'INFRA', 'EXPORTER', 'string', 'G', '监控组件的YumRepo', 'repo url for yum install', '通用Exporter配置', '""'),
(162, 'exporter_metrics_path', 'INFRA', 'EXPORTER', 'string', 'G', '监控暴露的URL Path', 'URL path for exporting metrics', '通用Exporter配置', '"/metrics"'),
(170, 'grafana_endpoint', 'INFRA', 'GRAFANA', 'url', 'G', 'Grafana地址', 'grafana API endpoint', 'Grafana可视化平台', '"http://10.10.10.10:3000"'),
(171, 'grafana_admin_username', 'INFRA', 'GRAFANA', 'string', 'G', 'Grafana管理员用户名', 'grafana admin username', 'Grafana可视化平台', '"admin"'),
(172, 'grafana_admin_password', 'INFRA', 'GRAFANA', 'string', 'G', 'Grafana管理员密码', 'grafana admin password', 'Grafana可视化平台', '"pigsty"'),
(173, 'grafana_database', 'INFRA', 'GRAFANA', 'enum', 'G', 'Grafana后端数据库类型', 'grafana backend database type', 'Grafana可视化平台', '"sqlite3"'),
(174, 'grafana_pgurl', 'INFRA', 'GRAFANA', 'url', 'G', 'Grafana的PG数据库连接串', 'grafana backend postgres url', 'Grafana可视化平台', '"postgres://dbuser_grafana:DBUser.Grafana@meta:5436/grafana"'),
(175, 'grafana_plugin', 'INFRA', 'GRAFANA', 'enum', 'G', '如何安装Grafana插件', 'how to install grafana plugins', 'Grafana可视化平台', '"install"'),
(176, 'grafana_cache', 'INFRA', 'GRAFANA', 'path', 'G', 'Grafana插件缓存地址', 'grafana plugins cache path', 'Grafana可视化平台', '"/www/pigsty/plugins.tgz"'),
(177, 'grafana_plugins', 'INFRA', 'GRAFANA', 'string[]', 'G', '安装的Grafana插件列表', 'grafana plugins to be installed', 'Grafana可视化平台', '["marcusolsson-csv-datasource", "marcusolsson-json-datasource", "marcusolsson-treemap-panel"]'),
(178, 'grafana_git_plugins', 'INFRA', 'GRAFANA', 'url[]', 'G', '从Git安装的Grafana插件', 'grafana plugins via git', 'Grafana可视化平台', '["https://github.com/Vonng/vonng-echarts-panel"]'),
(180, 'loki_endpoint', 'INFRA', 'LOKI', 'url', 'G', '用于接收日志的loki服务endpoint', 'loki endpoint to receive log', 'Loki日志收集平台', '"http://10.10.10.10:3100/loki/api/v1/push"'),
(181, 'loki_clean', 'INFRA', 'LOKI', 'bool', 'A', '是否在安装Loki时清理数据库目录', 'remove existing loki data?', 'Loki日志收集平台', 'false'),
(182, 'loki_options', 'INFRA', 'LOKI', 'string', 'G', 'Loki的命令行参数', 'loki cli args', 'Loki日志收集平台', '"-config.file=/etc/loki.yml -config.expand-env=true"'),
(183, 'loki_data_dir', 'INFRA', 'LOKI', 'string', 'G', 'Loki的数据目录', 'loki data path', 'Loki日志收集平台', '"/data/loki"'),
(184, 'loki_retention', 'INFRA', 'LOKI', 'interval', 'G', 'Loki日志默认保留天数', 'loki log keeping period', 'Loki日志收集平台', '"15d"'),
(200, 'dcs_servers', 'INFRA', 'DCS', 'dict', 'G', 'DCS服务器名称:IP列表', 'dcs server dict', '分布式配置存储元数据库', '{"pg-meta-1": "10.10.10.10"}'),
(201, 'service_registry', 'INFRA', 'DCS', 'enum', 'G', '服务注册的位置', 'where to register service?', '分布式配置存储元数据库', '"consul"'),
(202, 'dcs_type', 'INFRA', 'DCS', 'enum', 'G', '使用的DCS类型', 'which dcs to use (consul/etcd)', '分布式配置存储元数据库', '"consul"'),
(203, 'dcs_name', 'INFRA', 'DCS', 'string', 'G', 'DCS集群名称', 'dcs cluster name (dc)', '分布式配置存储元数据库', '"pigsty"'),
(204, 'dcs_exists_action', 'INFRA', 'DCS', 'enum', 'C/A', '若DCS实例存在如何处理', 'how to deal with existing dcs', '分布式配置存储元数据库', '"clean"'),
(205, 'dcs_disable_purge', 'INFRA', 'DCS', 'bool', 'C/A', '完全禁止清理DCS实例', 'disable dcs purge', '分布式配置存储元数据库', 'false'),
(206, 'consul_data_dir', 'INFRA', 'DCS', 'string', 'G', 'Consul数据目录', 'consul data dir path', '分布式配置存储元数据库', '"/data/consul"'),
(207, 'etcd_data_dir', 'INFRA', 'DCS', 'string', 'G', 'Etcd数据目录', 'etcd data dir path', '分布式配置存储元数据库', '"/data/etcd"'),
(220, 'jupyter_enabled', 'INFRA', 'JUPYTER', 'bool', 'G', '是否启用JupyterLab', 'enable jupyter lab', 'JupyterLab数据分析环境', 'true'),
(221, 'jupyter_username', 'INFRA', 'JUPYTER', 'bool', 'G', 'Jupyter使用的操作系统用户', 'os user for jupyter lab', 'JupyterLab数据分析环境', '"jupyter"'),
(222, 'jupyter_password', 'INFRA', 'JUPYTER', 'bool', 'G', 'Jupyter Lab的密码', 'password for jupyter lab', 'JupyterLab数据分析环境', '"pigsty"'),
(230, 'pgweb_enabled', 'INFRA', 'PGWEB', 'bool', 'G', '是否启用PgWeb', 'enable pgweb', 'PGWeb网页客户端工具', 'true'),
(231, 'pgweb_username', 'INFRA', 'PGWEB', 'bool', 'G', 'PgWeb使用的操作系统用户', 'os user for pgweb', 'PGWeb网页客户端工具', '"pgweb"'),
(300, 'meta_node', 'NODES', 'NODE_IDENTITY', 'bool', 'C', '表示此节点为元节点', 'mark this node as meta', '节点身份参数', 'false'),
(301, 'nodename', 'NODES', 'NODE_IDENTITY', 'string', 'I', '指定节点实例标识', 'node instance identity', '节点身份参数', NULL),
(302, 'node_cluster', 'NODES', 'NODE_IDENTITY', 'string', 'C', '节点集群名，默认名为nodes', 'node cluster identity', '节点身份参数', '"nodes"'),
(303, 'nodename_overwrite', 'NODES', 'NODE_IDENTITY', 'bool', 'C', '用Nodename覆盖机器HOSTNAME', 'overwrite hostname with nodename', '节点身份参数', 'true'),
(304, 'nodename_exchange', 'NODES', 'NODE_IDENTITY', 'bool', 'C', '是否在剧本节点间交换主机名', 'exchange static hostname', '节点身份参数', 'false'),
(310, 'node_dns_hosts', 'NODES', 'NODE_DNS', 'string[]', 'C', '写入机器的静态DNS解析', 'static DNS records', '节点域名解析', '["10.10.10.10 meta pigsty c.pigsty g.pigsty l.pigsty p.pigsty a.pigsty cli.pigsty lab.pigsty api.pigsty"]'),
(311, 'node_dns_hosts_extra', 'NODES', 'NODE_DNS', 'string[]', 'C/I', '同上，用于集群实例层级', 'extra static DNS records', '节点域名解析', '[]'),
(312, 'node_dns_server', 'NODES', 'NODE_DNS', 'enum', 'C', '如何配置DNS服务器？', 'how to setup dns service?', '节点域名解析', '"add"'),
(313, 'node_dns_servers', 'NODES', 'NODE_DNS', 'string[]', 'C', '配置动态DNS服务器列表', 'dynamic DNS servers', '节点域名解析', '["10.10.10.10"]'),
(314, 'node_dns_options', 'NODES', 'NODE_DNS', 'string[]', 'C', '配置/etc/resolv.conf', '/etc/resolv.conf options', '节点域名解析', '["options single-request-reopen timeout:1 rotate", "domain service.consul"]'),
(320, 'node_repo_method', 'NODES', 'NODE_REPO', 'enum', 'C', '节点使用Yum源的方式', 'how to use yum repo (local)', '节点软件源', '"local"'),
(321, 'node_repo_remove', 'NODES', 'NODE_REPO', 'bool', 'C', '是否移除节点已有Yum源', 'remove existing repo file?', '节点软件源', 'true'),
(322, 'node_local_repo_url', 'NODES', 'NODE_REPO', 'url[]', 'C', '本地源的URL地址', 'local yum repo url', '节点软件源', '["http://pigsty/pigsty.repo"]'),
(330, 'node_packages', 'NODES', 'NODE_PACKAGES', 'string[]', 'C', '节点安装软件列表', 'pkgs to be installed on all node', '节点软件包', '["wget,sshpass,ntp,chrony,tuned,uuid,lz4,make,patch,bash,lsof,wget,unzip,git,ftp,vim-minimal", "numactl,grubby,sysstat,dstat,iotop,bind-utils,net-tools,tcpdump,socat,ipvsadm,telnet,tuned,pv,jq,perf,ca-certificates", "readline,zlib,openssl,openssl-libs,openssh-clients,python3,python36-requests,node_exporter,redis_exporter,consul,etcd,promtail"]'),
(331, 'node_extra_packages', 'NODES', 'NODE_PACKAGES', 'string[]', 'C', '节点额外安装的软件列表', 'extra pkgs to be installed', '节点软件包', '[]'),
(332, 'node_meta_packages', 'NODES', 'NODE_PACKAGES', 'string[]', 'G', '元节点所需的软件列表', 'meta node only packages', '节点软件包', '["grafana,prometheus2,alertmanager,loki,nginx_exporter,blackbox_exporter,pushgateway,redis,postgresql14", "nginx,ansible,pgbadger,python-psycopg2,dnsmasq,coreutils,diffutils,polysh"]'),
(333, 'node_meta_pip_install', 'NODES', 'NODE_PACKAGES', 'string', 'G', '元节点上通过pip3安装的软件包', 'meta node pip3 packages', '节点软件包', '"jupyterlab"'),
(340, 'node_disable_numa', 'NODES', 'NODE_FEATURES', 'bool', 'C', '关闭节点NUMA', 'disable numa?', '节点功能特性', 'false'),
(341, 'node_disable_swap', 'NODES', 'NODE_FEATURES', 'bool', 'C', '关闭节点SWAP', 'disable swap?', '节点功能特性', 'false'),
(342, 'node_disable_firewall', 'NODES', 'NODE_FEATURES', 'bool', 'C', '关闭节点防火墙', 'disable firewall?', '节点功能特性', 'true'),
(343, 'node_disable_selinux', 'NODES', 'NODE_FEATURES', 'bool', 'C', '关闭节点SELINUX', 'disable selinux?', '节点功能特性', 'true'),
(344, 'node_static_network', 'NODES', 'NODE_FEATURES', 'bool', 'C', '是否使用静态DNS服务器', 'use static DNS config?', '节点功能特性', 'true'),
(345, 'node_disk_prefetch', 'NODES', 'NODE_FEATURES', 'bool', 'C', '是否启用磁盘预读', 'enable disk prefetch?', '节点功能特性', 'false'),
(346, 'node_kernel_modules', 'NODES', 'NODE_MODULES', 'string[]', 'C', '启用的内核模块', 'kernel modules to be installed', '节点内核模块', '["softdog", "br_netfilter", "ip_vs", "ip_vs_rr", "ip_vs_rr", "ip_vs_wrr", "ip_vs_sh"]'),
(350, 'node_tune', 'NODES', 'NODE_TUNE', 'enum', 'C', '节点调优模式', 'node tune mode', '节点参数调优', '"tiny"'),
(351, 'node_sysctl_params', 'NODES', 'NODE_TUNE', 'dict', 'C', '操作系统内核参数', 'extra kernel parameters', '节点参数调优', '{}'),
(360, 'node_admin_setup', 'NODES', 'NODE_ADMIN', 'bool', 'G', '是否创建管理员用户', 'create admin user?', '节点管理员', 'true'),
(361, 'node_admin_uid', 'NODES', 'NODE_ADMIN', 'int', 'G', '管理员用户UID', 'admin user UID', '节点管理员', '88'),
(362, 'node_admin_username', 'NODES', 'NODE_ADMIN', 'string', 'G', '管理员用户名', 'admin user name', '节点管理员', '"dba"'),
(363, 'node_admin_ssh_exchange', 'NODES', 'NODE_ADMIN', 'bool', 'C', '在实例间交换管理员SSH密钥', 'exchange admin ssh keys?', '节点管理员', 'true'),
(364, 'node_admin_pk_current', 'NODES', 'NODE_ADMIN', 'bool', 'A', '是否将当前用户的公钥加入管理员账户', 'pks to be added to admin', '节点管理员', 'true'),
(365, 'node_admin_pks', 'NODES', 'NODE_ADMIN', 'key[]', 'C', '可登陆管理员的公钥列表', 'add current user''s pkey?', '节点管理员', '["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQC7IMAMNavYtWwzAJajKqwdn3ar5BhvcwCnBTxxEkXhGlCO2vfgosSAQMEflfgvkiI5nM1HIFQ8KINlx1XLO7SdL5KdInG5LIJjAFh0pujS4kNCT9a5IGvSq1BrzGqhbEcwWYdju1ZPYBcJm/MG+JD0dYCh8vfrYB/cYMD0SOmNkQ== vagrant@pigsty.com"]'),
(370, 'node_timezone', 'NODES', 'NODE_TIME', 'string', 'C', 'NTP时区设置', 'node timezone', '节点时区与时间同步', '"Asia/Hong_Kong"'),
(371, 'node_ntp_enabled', 'NODES', 'NODE_TIME', 'bool', 'C', '是否配置NTP服务？', 'setup ntp on node?', '节点时区与时间同步', 'true'),
(372, 'node_ntp_service', 'NODES', 'NODE_TIME', 'enum', 'C', 'NTP服务类型：ntp或chrony', 'ntp mode: ntp or chrony?', '节点时区与时间同步', '"ntp"'),
(373, 'node_ntp_servers', 'NODES', 'NODE_TIME', 'string[]', 'C', 'NTP服务器列表', 'ntp server list', '节点时区与时间同步', '["pool cn.pool.ntp.org iburst", "pool pool.ntp.org iburst", "pool time.pool.aliyun.com iburst", "server 10.10.10.10 iburst", "server ntp.tuna.tsinghua.edu.cn iburst"]'),
(380, 'node_exporter_enabled', 'NODES', 'NODE_EXPORTER', 'bool', 'C', '启用节点指标收集器', 'node_exporter enabled?', '节点指标暴露器', 'true'),
(381, 'node_exporter_port', 'NODES', 'NODE_EXPORTER', 'int', 'C', '节点指标暴露端口', 'node_exporter listen port', '节点指标暴露器', '9100'),
(382, 'node_exporter_options', 'NODES', 'NODE_EXPORTER', 'string', 'C/I', '节点指标采集选项', 'node_exporter extra cli args', '节点指标暴露器', '"--no-collector.softnet --no-collector.nvme --collector.ntp --collector.tcpstat --collector.processes"'),
(390, 'promtail_enabled', 'NODES', 'PROMTAIL', 'bool', 'C', '是否启用Promtail日志收集服务', 'promtail enabled ?', '日志收集组件', 'true'),
(391, 'promtail_clean', 'NODES', 'PROMTAIL', 'bool', 'C/A', '是否在安装promtail时移除已有状态信息', 'remove promtail status file ?', '日志收集组件', 'false'),
(392, 'promtail_port', 'NODES', 'PROMTAIL', 'int', 'G', 'promtail使用的默认端口', 'promtail listen port', '日志收集组件', '9080'),
(393, 'promtail_options', 'NODES', 'PROMTAIL', 'string', 'C/I', 'promtail命令行参数', 'promtail cli args', '日志收集组件', '"-config.file=/etc/promtail.yml -config.expand-env=true"'),
(394, 'promtail_positions', 'NODES', 'PROMTAIL', 'string', 'C', 'promtail状态文件位置', 'path to store promtail status file', '日志收集组件', '"/var/log/positions.yaml"'),
(500, 'pg_cluster', 'PGSQL', 'PG_IDENTITY', 'string', 'C', 'PG数据库集群名称', 'PG Cluster Name', 'PGSQL数据库身份参数', NULL),
(501, 'pg_shard', 'PGSQL', 'PG_IDENTITY', 'string', 'C', 'PG集群所属的Shard (保留)', 'PG Shard Name (Reserve)', 'PGSQL数据库身份参数', NULL),
(502, 'pg_sindex', 'PGSQL', 'PG_IDENTITY', 'int', 'C', 'PG集群的分片号 (保留)', 'PG Shard Index (Reserve)', 'PGSQL数据库身份参数', NULL),
(503, 'gp_role', 'PGSQL', 'PG_IDENTITY', 'enum', 'C', '当前PG集群在GP中的角色', 'gp role of this pg cluster', 'PGSQL数据库身份参数', NULL),
(504, 'pg_role', 'PGSQL', 'PG_IDENTITY', 'enum', 'I', 'PG数据库实例角色', 'PG Instance Role', 'PGSQL数据库身份参数', NULL),
(505, 'pg_seq', 'PGSQL', 'PG_IDENTITY', 'int', 'I', 'PG数据库实例序号', 'PG Instance Sequence', 'PGSQL数据库身份参数', NULL),
(506, 'pg_instances', 'PGSQL', 'PG_IDENTITY', '{port:ins}', 'I', '当前节点上的所有PG实例', 'pg instance on this node', 'PGSQL数据库身份参数', NULL),
(507, 'pg_upstream', 'PGSQL', 'PG_IDENTITY', 'string', 'I', '实例的复制上游节点', 'pg upstream IP address', 'PGSQL数据库身份参数', NULL),
(508, 'pg_offline_query', 'PGSQL', 'PG_IDENTITY', 'bool', 'I', '是否允许离线查询', 'allow offline query?', 'PGSQL数据库身份参数', 'false'),
(509, 'pg_backup', 'PGSQL', 'PG_IDENTITY', 'bool', 'I', '是否在实例上存储备份', 'make base backup on this ins?', 'PGSQL数据库身份参数', 'false'),
(510, 'pg_weight', 'PGSQL', 'PG_IDENTITY', 'int', 'I', '实例在负载均衡中的相对权重', 'relative weight in load balancer', 'PGSQL数据库身份参数', '100'),
(511, 'pg_hostname', 'PGSQL', 'PG_IDENTITY', 'bool', 'C/I', '将PG实例名称设为HOSTNAME', 'set PG ins name as hostname', 'PGSQL数据库身份参数', 'true'),
(512, 'pg_preflight_skip', 'PGSQL', 'PG_IDENTITY', 'bool', 'C/A', '跳过PG身份参数校验', 'skip preflight param validation', 'PGSQL数据库身份参数', 'false'),
(520, 'pg_users', 'PGSQL', 'PG_BUSINESS', 'user[]', 'C', '业务用户定义', 'business users definition', 'PGSQL业务对象定义', '[]'),
(521, 'pg_databases', 'PGSQL', 'PG_BUSINESS', 'database[]', 'C', '业务数据库定义', 'business databases definition', 'PGSQL业务对象定义', '[]'),
(522, 'pg_services_extra', 'PGSQL', 'PG_BUSINESS', 'service[]', 'C', '集群专有服务定义', 'ad hoc service definition', 'PGSQL业务对象定义', '[]'),
(523, 'pg_hba_rules_extra', 'PGSQL', 'PG_BUSINESS', 'rule[]', 'C', '集群/实例特定的HBA规则', 'ad hoc HBA rules', 'PGSQL业务对象定义', '[]'),
(524, 'pgbouncer_hba_rules_extra', 'PGSQL', 'PG_BUSINESS', 'rule[]', 'C', 'Pgbounce特定HBA规则', 'ad hoc pgbouncer HBA rules', 'PGSQL业务对象定义', '[]'),
(525, 'pg_admin_username', 'PGSQL', 'PG_BUSINESS', 'string', 'G', 'PG管理用户', 'admin user''s name', 'PGSQL业务对象定义', '"dbuser_dba"'),
(526, 'pg_admin_password', 'PGSQL', 'PG_BUSINESS', 'string', 'G', 'PG管理用户密码', 'admin user''s password', 'PGSQL业务对象定义', '"DBUser.DBA"'),
(527, 'pg_replication_username', 'PGSQL', 'PG_BUSINESS', 'string', 'G', 'PG复制用户', 'replication user''s name', 'PGSQL业务对象定义', '"replicator"'),
(528, 'pg_replication_password', 'PGSQL', 'PG_BUSINESS', 'string', 'G', 'PG复制用户的密码', 'replication user''s password', 'PGSQL业务对象定义', '"DBUser.Replicator"'),
(529, 'pg_monitor_username', 'PGSQL', 'PG_BUSINESS', 'string', 'G', 'PG监控用户', 'monitor user''s name', 'PGSQL业务对象定义', '"dbuser_monitor"'),
(530, 'pg_monitor_password', 'PGSQL', 'PG_BUSINESS', 'string', 'G', 'PG监控用户密码', 'monitor user''s password', 'PGSQL业务对象定义', '"DBUser.Monitor"'),
(540, 'pg_dbsu', 'PGSQL', 'PG_INSTALL', 'string', 'C', 'PG操作系统超级用户', 'os dbsu for postgres', 'PGSQL安装', '"postgres"'),
(541, 'pg_dbsu_uid', 'PGSQL', 'PG_INSTALL', 'int', 'C', '超级用户UID', 'dbsu UID', 'PGSQL安装', '26'),
(542, 'pg_dbsu_sudo', 'PGSQL', 'PG_INSTALL', 'enum', 'C', '超级用户的Sudo权限', 'sudo priv mode for dbsu', 'PGSQL安装', '"limit"'),
(543, 'pg_dbsu_home', 'PGSQL', 'PG_INSTALL', 'path', 'C', '超级用户的家目录', 'home dir for dbsu', 'PGSQL安装', '"/var/lib/pgsql"'),
(544, 'pg_dbsu_ssh_exchange', 'PGSQL', 'PG_INSTALL', 'bool', 'C', '是否交换超级用户密钥', 'exchange dbsu ssh keys?', 'PGSQL安装', 'true'),
(545, 'pg_version', 'PGSQL', 'PG_INSTALL', 'int', 'C', '安装的数据库大版本', 'major PG version to be installed', 'PGSQL安装', '14'),
(546, 'pgdg_repo', 'PGSQL', 'PG_INSTALL', 'bool', 'C', '是否添加PG官方源？', 'add official PGDG repo?', 'PGSQL安装', 'false'),
(547, 'pg_add_repo', 'PGSQL', 'PG_INSTALL', 'bool', 'C', '是否添加PG相关上游源？', 'add extra upstream PG repo?', 'PGSQL安装', 'false'),
(548, 'pg_bin_dir', 'PGSQL', 'PG_INSTALL', 'path', 'C', 'PG二进制目录', 'PG binary dir', 'PGSQL安装', '"/usr/pgsql/bin"'),
(549, 'pg_packages', 'PGSQL', 'PG_INSTALL', 'string[]', 'C', '安装的PG软件包列表', 'PG packages to be installed', 'PGSQL安装', '["postgresql${pg_version}*", "postgis32_${pg_version}*", "citus_${pg_version}*", "timescaledb-2-postgresql-${pg_version}", "pgbouncer pg_exporter pgbadger pg_activity node_exporter consul haproxy vip-manager", "patroni patroni-consul patroni-etcd python3 python3-psycopg2 python36-requests python3-etcd", "python3-consul python36-urllib3 python36-idna python36-pyOpenSSL python36-cryptography"]'),
(550, 'pg_extensions', 'PGSQL', 'PG_INSTALL', 'string[]', 'C', '安装的PG插件列表', 'PG extension pkgs to be installed', 'PGSQL安装', '["pg_repack_${pg_version} pg_qualstats_${pg_version} pg_stat_kcache_${pg_version} pg_stat_monitor_${pg_version} wal2json_${pg_version}"]'),
(560, 'pg_exists_action', 'PGSQL', 'PG_BOOTSTRAP', 'enum', 'C/A', 'PG存在时如何处理', 'how to deal with existing pg ins', 'PGSQL集群初始化', '"clean"'),
(561, 'pg_disable_purge', 'PGSQL', 'PG_BOOTSTRAP', 'bool', 'C/A', '禁止清除存在的PG实例', 'disable pg instance purge', 'PGSQL集群初始化', 'false'),
(562, 'pg_data', 'PGSQL', 'PG_BOOTSTRAP', 'path', 'C', 'PG数据目录', 'pg data dir', 'PGSQL集群初始化', '"/pg/data"'),
(563, 'pg_fs_main', 'PGSQL', 'PG_BOOTSTRAP', 'path', 'C', 'PG主数据盘挂载点', 'pg main data disk mountpoint', 'PGSQL集群初始化', '"/data"'),
(564, 'pg_fs_bkup', 'PGSQL', 'PG_BOOTSTRAP', 'path', 'C', 'PG备份盘挂载点', 'pg backup disk mountpoint', 'PGSQL集群初始化', '"/data/backups"'),
(565, 'pg_dummy_filesize', 'PGSQL', 'PG_BOOTSTRAP', 'size', 'C', '占位文件/pg/dummy的大小', '/pg/dummy file size', 'PGSQL集群初始化', '"64MiB"'),
(566, 'pg_listen', 'PGSQL', 'PG_BOOTSTRAP', 'ip', 'C', 'PG监听的IP地址', 'pg listen IP address', 'PGSQL集群初始化', '"0.0.0.0"'),
(567, 'pg_port', 'PGSQL', 'PG_BOOTSTRAP', 'int', 'C', 'PG监听的端口', 'pg listen port', 'PGSQL集群初始化', '5432'),
(568, 'pg_localhost', 'PGSQL', 'PG_BOOTSTRAP', 'ip|path', 'C', 'PG使用的UnixSocket地址', 'pg unix socket path', 'PGSQL集群初始化', '"/var/run/postgresql"'),
(580, 'patroni_enabled', 'PGSQL', 'PG_BOOTSTRAP', 'bool', 'C', 'Patroni是否启用', 'Is patroni & postgres enabled?', 'PGSQL集群初始化', 'true'),
(581, 'patroni_mode', 'PGSQL', 'PG_BOOTSTRAP', 'enum', 'C', 'Patroni配置模式', 'patroni working mode', 'PGSQL集群初始化', '"default"'),
(582, 'pg_namespace', 'PGSQL', 'PG_BOOTSTRAP', 'path', 'C', 'Patroni使用的DCS命名空间', 'namespace for patroni', 'PGSQL集群初始化', '"/pg"'),
(583, 'patroni_port', 'PGSQL', 'PG_BOOTSTRAP', 'int', 'C', 'Patroni服务端口', 'patroni listen port (8080)', 'PGSQL集群初始化', '8008'),
(584, 'patroni_watchdog_mode', 'PGSQL', 'PG_BOOTSTRAP', 'enum', 'C', 'Patroni Watchdog模式', 'patroni watchdog policy', 'PGSQL集群初始化', '"automatic"'),
(585, 'pg_conf', 'PGSQL', 'PG_BOOTSTRAP', 'string', 'C', 'Patroni使用的配置模板', 'patroni template', 'PGSQL集群初始化', '"tiny.yml"'),
(586, 'pg_shared_libraries', 'PGSQL', 'PG_BOOTSTRAP', 'string', 'C', 'PG默认加载的共享库', 'default preload shared libraries', 'PGSQL集群初始化', '"timescaledb, pg_stat_statements, auto_explain"'),
(587, 'pg_encoding', 'PGSQL', 'PG_BOOTSTRAP', 'enum', 'C', 'PG字符集编码', 'character encoding', 'PGSQL集群初始化', '"UTF8"'),
(588, 'pg_locale', 'PGSQL', 'PG_BOOTSTRAP', 'enum', 'C', 'PG使用的本地化规则', 'locale', 'PGSQL集群初始化', '"C"'),
(589, 'pg_lc_collate', 'PGSQL', 'PG_BOOTSTRAP', 'enum', 'C', 'PG使用的本地化排序规则', 'collate rule of locale', 'PGSQL集群初始化', '"C"'),
(590, 'pg_lc_ctype', 'PGSQL', 'PG_BOOTSTRAP', 'enum', 'C', 'PG使用的本地化字符集定义', 'ctype of locale', 'PGSQL集群初始化', '"en_US.UTF8"'),
(591, 'pgbouncer_enabled', 'PGSQL', 'PG_BOOTSTRAP', 'bool', 'C', '是否启用Pgbouncer', 'is pgbouncer enabled', 'PGSQL集群初始化', 'true'),
(592, 'pgbouncer_port', 'PGSQL', 'PG_BOOTSTRAP', 'int', 'C', 'Pgbouncer端口', 'pgbouncer listen port', 'PGSQL集群初始化', '6432'),
(593, 'pgbouncer_poolmode', 'PGSQL', 'PG_BOOTSTRAP', 'enum', 'C', 'Pgbouncer池化模式', 'pgbouncer pooling mode', 'PGSQL集群初始化', '"transaction"'),
(594, 'pgbouncer_max_db_conn', 'PGSQL', 'PG_BOOTSTRAP', 'int', 'C', 'Pgbouncer最大单DB连接数', 'max connection per database', 'PGSQL集群初始化', '100'),
(600, 'pg_provision', 'PGSQL', 'PG_PROVISION', 'bool', 'C', '是否在PG集群中应用模板', 'provision template to pgsql?', 'PGSQL集群模板置备', 'true'),
(601, 'pg_init', 'PGSQL', 'PG_PROVISION', 'string', 'C', '自定义PG初始化脚本', 'path to postgres init script', 'PGSQL集群模板置备', '"pg-init"'),
(602, 'pg_default_roles', 'PGSQL', 'PG_PROVISION', 'role[]', 'G/C', '默认创建的角色与用户', 'list or global default roles/users', 'PGSQL集群模板置备', '[{"name": "dbrole_readonly", "login": false, "comment": "role for global read-only access"}, {"name": "dbrole_readwrite", "login": false, "roles": ["dbrole_readonly"], "comment": "role for global read-write access"}, {"name": "dbrole_offline", "login": false, "comment": "role for restricted read-only access (offline instance)"}, {"name": "dbrole_admin", "login": false, "roles": ["pg_monitor", "dbrole_readwrite"], "comment": "role for object creation"}, {"name": "postgres", "comment": "system superuser", "superuser": true}, {"name": "dbuser_dba", "roles": ["dbrole_admin"], "comment": "system admin user", "superuser": true}, {"name": "replicator", "roles": ["pg_monitor", "dbrole_readonly"], "comment": "system replicator", "bypassrls": true, "replication": true}, {"name": "dbuser_monitor", "roles": ["pg_monitor", "dbrole_readonly"], "comment": "system monitor user", "parameters": {"log_min_duration_statement": 1000}}, {"name": "dbuser_stats", "roles": ["dbrole_offline"], "comment": "business offline user for offline queries and ETL", "password": "DBUser.Stats"}]'),
(603, 'pg_default_privilegs', 'PGSQL', 'PG_PROVISION', 'string[]', 'G/C', '数据库默认权限配置', 'list of default privileges', 'PGSQL集群模板置备', NULL),
(604, 'pg_default_schemas', 'PGSQL', 'PG_PROVISION', 'string[]', 'G/C', '默认创建的模式', 'list of default schemas', 'PGSQL集群模板置备', '["monitor"]'),
(605, 'pg_default_extensions', 'PGSQL', 'PG_PROVISION', 'extension[]', 'G/C', '默认安装的扩展', 'list of default extensions', 'PGSQL集群模板置备', '[{"name": "pg_stat_statements", "schema": "monitor"}, {"name": "pgstattuple", "schema": "monitor"}, {"name": "pg_qualstats", "schema": "monitor"}, {"name": "pg_buffercache", "schema": "monitor"}, {"name": "pageinspect", "schema": "monitor"}, {"name": "pg_prewarm", "schema": "monitor"}, {"name": "pg_visibility", "schema": "monitor"}, {"name": "pg_freespacemap", "schema": "monitor"}, {"name": "pg_repack", "schema": "monitor"}, {"name": "postgres_fdw"}, {"name": "file_fdw"}, {"name": "btree_gist"}, {"name": "btree_gin"}, {"name": "pg_trgm"}, {"name": "intagg"}, {"name": "intarray"}]'),
(606, 'pg_reload', 'PGSQL', 'PG_PROVISION', 'bool', 'A', '是否重载数据库配置（HBA）', 'reload configuration?', 'PGSQL集群模板置备', 'true'),
(607, 'pg_hba_rules', 'PGSQL', 'PG_PROVISION', 'rule[]', 'G/C', '全局HBA规则', 'global HBA rules', 'PGSQL集群模板置备', '[{"role": "common", "rules": ["host    all     all                         10.10.10.10/32      md5"], "title": "allow meta node password access"}, {"role": "common", "rules": ["host    all     +dbrole_admin               10.0.0.0/8          md5", "host    all     +dbrole_admin               172.16.0.0/12       md5", "host    all     +dbrole_admin               192.168.0.0/16      md5"], "title": "allow intranet admin password access"}, {"role": "common", "rules": ["host    all             all                 10.0.0.0/8          md5", "host    all             all                 172.16.0.0/12       md5", "host    all             all                 192.168.0.0/16      md5"], "title": "allow intranet password access"}, {"role": "common", "rules": ["local   all     +dbrole_readonly                                md5", "host    all     +dbrole_readonly           127.0.0.1/32         md5"], "title": "allow local read/write (local production user via pgbouncer)"}, {"role": "offline", "rules": ["host    all     +dbrole_offline               10.0.0.0/8        md5", "host    all     +dbrole_offline               172.16.0.0/12     md5", "host    all     +dbrole_offline               192.168.0.0/16    md5"], "title": "allow offline query (ETL,SAGA,Interactive) on offline instance"}]'),
(608, 'pgbouncer_hba_rules', 'PGSQL', 'PG_PROVISION', 'rule[]', 'G/C', 'Pgbouncer全局HBA规则', 'global pgbouncer HBA rules', 'PGSQL集群模板置备', '[{"role": "common", "rules": ["local  all          all                                     md5", "host   all          all                     127.0.0.1/32    md5"], "title": "local password access"}, {"role": "common", "rules": ["host   all          all                     10.0.0.0/8      md5", "host   all          all                     172.16.0.0/12   md5", "host   all          all                     192.168.0.0/16  md5"], "title": "intranet password access"}]'),
(620, 'pg_exporter_config', 'PGSQL', 'PG_EXPORTER', 'string', 'C', 'PG指标定义文件', 'pg_exporter config path', 'PGSQL指标暴露器', '"pg_exporter.yml"'),
(621, 'pg_exporter_enabled', 'PGSQL', 'PG_EXPORTER', 'bool', 'C', '启用PG指标收集器', 'pg_exporter enabled ?', 'PGSQL指标暴露器', 'true'),
(622, 'pg_exporter_port', 'PGSQL', 'PG_EXPORTER', 'int', 'C', 'PG指标暴露端口', 'pg_exporter listen address', 'PGSQL指标暴露器', '9630'),
(623, 'pg_exporter_params', 'PGSQL', 'PG_EXPORTER', 'string', 'C/I', 'PG Exporter额外的URL参数', 'extra params for pg_exporter url', 'PGSQL指标暴露器', '"sslmode=disable"'),
(624, 'pg_exporter_url', 'PGSQL', 'PG_EXPORTER', 'string', 'C/I', '采集对象数据库的连接串（覆盖）', 'monitor target pgurl (overwrite)', 'PGSQL指标暴露器', '""'),
(625, 'pg_exporter_auto_discovery', 'PGSQL', 'PG_EXPORTER', 'bool', 'C/I', '是否自动发现实例中的数据库', 'enable auto-database-discovery?', 'PGSQL指标暴露器', 'true'),
(626, 'pg_exporter_exclude_database', 'PGSQL', 'PG_EXPORTER', 'string', 'C/I', '数据库自动发现排除列表', 'excluded list of databases', 'PGSQL指标暴露器', '"template0,template1,postgres"'),
(627, 'pg_exporter_include_database', 'PGSQL', 'PG_EXPORTER', 'string', 'C/I', '数据库自动发现囊括列表', 'included list of databases', 'PGSQL指标暴露器', '""'),
(628, 'pg_exporter_options', 'PGSQL', 'PG_EXPORTER', 'string', 'C/I', 'PG Exporter命令行参数', 'cli args for pg_exporter', 'PGSQL指标暴露器', '"--log.level=info --log.format=\"logger:syslog?appname=pg_exporter&local=7\""'),
(629, 'pgbouncer_exporter_enabled', 'PGSQL', 'PG_EXPORTER', 'bool', 'C', '启用PGB指标收集器', 'pgbouncer_exporter enabled ?', 'PGSQL指标暴露器', 'true'),
(630, 'pgbouncer_exporter_port', 'PGSQL', 'PG_EXPORTER', 'int', 'C', 'PGB指标暴露端口', 'pgbouncer_exporter listen addr?', 'PGSQL指标暴露器', '9631'),
(631, 'pgbouncer_exporter_url', 'PGSQL', 'PG_EXPORTER', 'string', 'C/I', '采集对象连接池的连接串', 'target pgbouncer url (overwrite)', 'PGSQL指标暴露器', '""'),
(632, 'pgbouncer_exporter_options', 'PGSQL', 'PG_EXPORTER', 'string', 'C/I', 'PGB Exporter命令行参数', 'cli args for pgbouncer exporter', 'PGSQL指标暴露器', '"--log.level=info --log.format=\"logger:syslog?appname=pgbouncer_exporter&local=7\""'),
(640, 'pg_services', 'PGSQL', 'PG_SERVICE', 'service[]', 'G/C', '全局通用服务定义', 'global service definition', 'PGSQL服务接入', '[{"name": "primary", "src_ip": "*", "dst_port": "pgbouncer", "selector": "[]", "src_port": 5433, "check_url": "/primary"}, {"name": "replica", "src_ip": "*", "dst_port": "pgbouncer", "selector": "[]", "src_port": 5434, "check_url": "/read-only", "selector_backup": "[? pg_role == `primary` || pg_role == `offline` ]"}, {"name": "default", "src_ip": "*", "haproxy": {"balance": "roundrobin", "maxconn": 3000, "default_server_options": "inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100"}, "dst_port": "postgres", "selector": "[]", "src_port": 5436, "check_url": "/primary", "check_code": 200, "check_port": "patroni", "check_method": "http"}, {"name": "offline", "src_ip": "*", "dst_port": "postgres", "selector": "[? pg_role == `offline` || pg_offline_query ]", "src_port": 5438, "check_url": "/replica", "selector_backup": "[? pg_role == `replica` && !pg_offline_query]"}]'),
(641, 'haproxy_enabled', 'PGSQL', 'PG_SERVICE', 'bool', 'C/I', '是否启用Haproxy', 'haproxy enabled ?', 'PGSQL服务接入', 'true'),
(642, 'haproxy_reload', 'PGSQL', 'PG_SERVICE', 'bool', 'A', '是否重载Haproxy配置', 'haproxy reload instead of reset', 'PGSQL服务接入', 'true'),
(643, 'haproxy_admin_auth_enabled', 'PGSQL', 'PG_SERVICE', 'bool', 'G/C', '是否对Haproxy管理界面启用认证', 'enable auth for haproxy admin ?', 'PGSQL服务接入', 'false'),
(644, 'haproxy_admin_username', 'PGSQL', 'PG_SERVICE', 'string', 'G', 'HAproxy管理员名称', 'haproxy admin user name', 'PGSQL服务接入', '"admin"'),
(645, 'haproxy_admin_password', 'PGSQL', 'PG_SERVICE', 'string', 'G', 'HAproxy管理员密码', 'haproxy admin password', 'PGSQL服务接入', '"pigsty"'),
(646, 'haproxy_exporter_port', 'PGSQL', 'PG_SERVICE', 'int', 'C', 'HAproxy指标暴露器端口', 'haproxy exporter listen port', 'PGSQL服务接入', '9101'),
(647, 'haproxy_client_timeout', 'PGSQL', 'PG_SERVICE', 'interval', 'C', 'HAproxy客户端超时', 'haproxy client timeout', 'PGSQL服务接入', '"24h"'),
(648, 'haproxy_server_timeout', 'PGSQL', 'PG_SERVICE', 'interval', 'C', 'HAproxy服务端超时', 'haproxy server timeout', 'PGSQL服务接入', '"24h"'),
(649, 'vip_mode', 'PGSQL', 'PG_SERVICE', 'enum', 'C', 'VIP模式：none', 'vip working mode', 'PGSQL服务接入', '"none"'),
(650, 'vip_reload', 'PGSQL', 'PG_SERVICE', 'bool', 'A', '是否重载VIP配置', 'reload vip configuration', 'PGSQL服务接入', 'true'),
(651, 'vip_address', 'PGSQL', 'PG_SERVICE', 'string', 'C', '集群使用的VIP地址', 'vip address used by cluster', 'PGSQL服务接入', NULL),
(652, 'vip_cidrmask', 'PGSQL', 'PG_SERVICE', 'int', 'C', 'VIP地址的网络CIDR掩码长度', 'vip network CIDR length', 'PGSQL服务接入', NULL),
(653, 'vip_interface', 'PGSQL', 'PG_SERVICE', 'string', 'C', 'VIP使用的网卡', 'vip network interface name', 'PGSQL服务接入', NULL),
(654, 'dns_mode', 'PGSQL', 'PG_SERVICE', 'enum', 'C', 'DNS配置模式', 'cluster DNS mode', 'PGSQL服务接入', NULL),
(655, 'dns_selector', 'PGSQL', 'PG_SERVICE', 'string', 'C', 'DNS解析对象选择器', 'cluster DNS ins selector', 'PGSQL服务接入', NULL),
(700, 'redis_cluster', 'REDIS', 'REDIS_IDENTITY', 'string', 'C', 'Redis数据库集群名称', 'redis cluster identity', 'REDIS身份参数', NULL),
(701, 'redis_node', 'REDIS', 'REDIS_IDENTITY', 'int', 'I', 'Redis节点序列号', 'redis node identity', 'REDIS身份参数', NULL),
(702, 'redis_instances', 'REDIS', 'REDIS_IDENTITY', 'instance[]', 'I', 'Redis实例定义', 'redis instances definition on this node', 'REDIS身份参数', NULL),
(720, 'redis_install', 'REDIS', 'REDIS_PROVISION', 'enum', 'C', '安装Redis的方式', 'Way of install redis binaries', 'REDIS集群置备', '"yum"'),
(721, 'redis_mode', 'REDIS', 'REDIS_PROVISION', 'enum', 'C', 'Redis集群模式', 'standalone,cluster,sentinel', 'REDIS集群置备', '"standalone"'),
(722, 'redis_conf', 'REDIS', 'REDIS_PROVISION', 'string', 'C', 'Redis配置文件模板', 'which config template will be used', 'REDIS集群置备', '"redis.conf"'),
(723, 'redis_fs_main', 'REDIS', 'REDIS_PROVISION', 'path', 'C', 'Redis主数据盘挂载点', 'main data disk for redis', 'REDIS集群置备', '"/data"'),
(724, 'redis_bind_address', 'REDIS', 'REDIS_PROVISION', 'ip', 'C', 'Redis监听的端口地址', 'e.g 0.0.0.0, empty will use inventory_hostname as bind address', 'REDIS集群置备', '"0.0.0.0"'),
(725, 'redis_exists_action', 'REDIS', 'REDIS_PROVISION', 'enum', 'C', 'Redis存在时执行何种操作', 'what to do when redis exists', 'REDIS集群置备', '"clean"'),
(726, 'redis_disable_purge', 'REDIS', 'REDIS_PROVISION', 'string', 'C', '禁止抹除现存的Redis', 'set to true to disable purge functionality for good (force redis_exists_action = abort)', 'REDIS集群置备', 'false'),
(727, 'redis_max_memory', 'REDIS', 'REDIS_PROVISION', 'size', 'C/I', 'Redis可用的最大内存', 'max memory used by each redis instance', 'REDIS集群置备', '"1GB"'),
(728, 'redis_mem_policy', 'REDIS', 'REDIS_PROVISION', 'enum', 'C', '内存逐出策略', 'memory eviction policy', 'REDIS集群置备', '"allkeys-lru"'),
(729, 'redis_password', 'REDIS', 'REDIS_PROVISION', 'string', 'C', 'Redis密码', 'empty password disable password auth (masterauth & requirepass)', 'REDIS集群置备', '""'),
(730, 'redis_rdb_save', 'REDIS', 'REDIS_PROVISION', 'string[]', 'C', 'RDB保存指令', 'redis RDB save directives, empty list disable it', 'REDIS集群置备', '["1200 1"]'),
(731, 'redis_aof_enabled', 'REDIS', 'REDIS_PROVISION', 'bool', 'C', '是否启用AOF', 'enable redis AOF', 'REDIS集群置备', 'false'),
(732, 'redis_rename_commands', 'REDIS', 'REDIS_PROVISION', 'object', 'C', '重命名危险命令列表', 'rename dangerous commands', 'REDIS集群置备', '{}'),
(740, 'redis_cluster_replicas', 'REDIS', 'REDIS_PROVISION', 'int', 'C', '集群每个主库带几个从库', 'how much replicas per master in redis cluster ?', 'REDIS集群置备', '1'),
(741, 'redis_exporter_enabled', 'REDIS', 'REDIS_EXPORTER', 'bool', 'C', '是否启用Redis监控', 'install redis exporter on redis nodes', 'REDIS指标暴露器', 'true'),
(742, 'redis_exporter_port', 'REDIS', 'REDIS_EXPORTER', 'int', 'C', 'Redis Exporter监听端口', 'default port for redis exporter', 'REDIS指标暴露器', '9121'),
(743, 'redis_exporter_options', 'REDIS', 'REDIS_EXPORTER', 'string', 'C/I', 'Redis Exporter命令参数', 'default cli args for redis exporter', 'REDIS指标暴露器', '""');

