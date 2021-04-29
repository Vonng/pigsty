-- ######################################################################
-- # File      :   meta.sql
-- # Desc      :   Pigsty MetaDB baseline
-- # Ctime     :   2021-04-21
-- # Mtime     :   2021-04-29
-- # Copyright (C) 2018-2021 Ruohang Feng
-- ######################################################################

--===========================================================--
--                          schema                           --
--===========================================================--
DROP SCHEMA IF EXISTS pigsty CASCADE; -- cleanse
CREATE SCHEMA IF NOT EXISTS pigsty;
SET search_path TO pigsty, public;

CREATE TYPE status AS ENUM ('unknown', 'failed', 'available', 'creating', 'deleting');
CREATE TYPE pg_role AS ENUM ('unknown','primary', 'replica', 'offline', 'standby', 'delayed');
CREATE TYPE job_status AS ENUM ('draft', 'ready', 'run', 'done', 'fail');
COMMENT ON TYPE status IS 'entity status';
COMMENT ON TYPE pg_role IS 'available postgres roles';
COMMENT ON TYPE job_status IS 'pigsty job status';

--===========================================================--
--                          config                           --
--===========================================================--
-- config hold raw config with additional meta data (id, name, ctime)
-- It is intent to use date_trunc('second', epoch) as part of auto-gen config name
-- which imply a constraint that no more than one config can be loaded on same second

-- DROP TABLE IF EXISTS config;
CREATE TABLE IF NOT EXISTS config
(
    name      VARCHAR(128) PRIMARY KEY,           -- unique config name, specify or auto-gen
    data      JSON        NOT NULL,               -- unparsed json string
    is_active BOOLEAN     NOT NULL DEFAULT FALSE, -- is config currently in use, unique on true?
    ctime     TIMESTAMPTZ NOT NULL default now(), -- ctime
    mtime     TIMESTAMPTZ NOT NULL DEFAULT now()  -- mtime
);
COMMENT ON TABLE config IS 'pigsty raw configs';
COMMENT ON COLUMN config.name IS 'unique config file name, use ts as default';
COMMENT ON COLUMN config.data IS 'json format data';
COMMENT ON COLUMN config.ctime IS 'config creation time, unique';
COMMENT ON COLUMN config.mtime IS 'config latest modification time, unique';

-- at MOST one config can be activated simultaneously
CREATE UNIQUE INDEX IF NOT EXISTS config_is_active_key ON config (is_active) WHERE is_active = true;


--===========================================================--
--                         cluster                           --
--===========================================================--
-- DROP TABLE IF EXISTS cluster CASCADE;
CREATE TABLE IF NOT EXISTS cluster
(
    cls    TEXT PRIMARY KEY,
    shard  TEXT,
    sindex INTEGER CHECK (sindex IS NULL OR sindex >= 0),
    status status      NOT NULL DEFAULT 'unknown'::status,
    ctime  TIMESTAMPTZ NOT NULL DEFAULT now(),
    mtime  TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE cluster IS 'pigsty pgsql clusters from config';
COMMENT ON COLUMN cluster.cls IS 'cluster name, primary key, can not change';
COMMENT ON COLUMN cluster.shard IS 'cluster shard name (if applicable)';
COMMENT ON COLUMN cluster.sindex IS 'cluster shard index (if applicable)';
COMMENT ON COLUMN cluster.status IS 'cluster status: unknown|failed|available|creating|deleting';
COMMENT ON COLUMN cluster.ctime IS 'cluster entry creation time';
COMMENT ON COLUMN cluster.mtime IS 'cluster modification time';



--===========================================================--
--                          node                             --
--===========================================================--
-- node belongs to cluster, have 1:1 relation with pgsql instance
-- it's good to have a 'pg-buffer' cluster to hold all unused nodes

-- DROP TABLE IF EXISTS node CASCADE;
CREATE TABLE IF NOT EXISTS node
(
    ip      INET PRIMARY KEY,
    cls     TEXT        NULL REFERENCES cluster (cls) ON DELETE CASCADE ON UPDATE CASCADE,
    is_meta BOOLEAN     NOT NULL DEFAULT FALSE,
    status  status      NOT NULL DEFAULT 'unknown'::status,
    ctime   TIMESTAMPTZ NOT NULL DEFAULT now(),
    mtime   TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE node IS 'pigsty nodes';
COMMENT ON COLUMN node.ip IS 'node primary key: ip address';
COMMENT ON COLUMN node.cls IS 'node must belong to a cluster, e.g pg-buffer ';
COMMENT ON COLUMN node.is_meta IS 'true if node is a meta node';
COMMENT ON COLUMN node.status IS 'node status: unknown|failed|available|creating|deleting';
COMMENT ON COLUMN node.ctime IS 'node entry creation time';
COMMENT ON COLUMN node.mtime IS 'node modification time';

--===========================================================--
--                        instance                           --
--===========================================================--
-- DROP TABLE IF EXISTS instance CASCADE;
CREATE TABLE IF NOT EXISTS instance
(
    ins    TEXT PRIMARY KEY CHECK (ins = cls || '-' || seq::TEXT),
    ip     INET UNIQUE NOT NULL REFERENCES node (ip) ON DELETE CASCADE ON UPDATE CASCADE,
    cls    TEXT        NOT NULL REFERENCES cluster (cls) ON DELETE CASCADE ON UPDATE CASCADE,
    seq    INTEGER     NOT NULL CHECK ( seq >= 0 ),
    role   pg_role     NOT NULL CHECK (role != 'unknown'::pg_role),
    role_d pg_role     NOT NULL DEFAULT 'unknown'::pg_role CHECK (role_d = ANY ('{unknown,primary,replica}'::pg_role[]) ),
    status status      NOT NULL DEFAULT 'unknown'::status,
    ctime  TIMESTAMPTZ NOT NULL DEFAULT now(),
    mtime  TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE instance IS 'pigsty pgsql instance';
COMMENT ON COLUMN instance.ins IS 'instance name, pk, format as $cls-$seq';
COMMENT ON COLUMN instance.ip IS 'ip address, semi-primary key, ref node.ip, unique';
COMMENT ON COLUMN instance.cls IS 'cluster name: ref cluster.cls';
COMMENT ON COLUMN instance.seq IS 'unique sequence among cluster';
COMMENT ON COLUMN instance.role IS 'configured role';
COMMENT ON COLUMN instance.role_d IS 'dynamic detected role: unknown|primary|replica ';
COMMENT ON COLUMN instance.status IS 'instance status: unknown|failed|available|creating|deleting';
COMMENT ON COLUMN instance.ctime IS 'instance entry creation time';
COMMENT ON COLUMN instance.mtime IS 'instance modification time';


--===========================================================--
--                      global_vars                          --
--===========================================================--
-- hold global var definition (all.vars)

-- DROP TABLE IF EXISTS global_var;
CREATE TABLE IF NOT EXISTS global_var
(
    key   TEXT PRIMARY KEY CHECK (key != ''),
    value JSONB NULL,
    mtime TIMESTAMPTZ DEFAULT now()
);
COMMENT ON TABLE global_var IS 'global variables';
COMMENT ON COLUMN global_var.key IS 'global config entry name';
COMMENT ON COLUMN global_var.value IS 'global config entry value';
COMMENT ON COLUMN global_var.mtime IS 'global config entry last modified time';

--===========================================================--
--                      cluster_vars                         --
--===========================================================--
-- hold cluster var definition (all.children.<pg_cluster>.vars)

-- DROP TABLE IF EXISTS cluster_vars;
CREATE TABLE IF NOT EXISTS cluster_var
(
    cls   TEXT  NOT NULL REFERENCES cluster (cls) ON DELETE CASCADE ON UPDATE CASCADE,
    key   TEXT  NOT NULL CHECK (key != ''),
    value JSONB NULL,
    mtime TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (cls, key)
);
COMMENT ON TABLE cluster_var IS 'cluster config entries';
COMMENT ON COLUMN cluster_var.cls IS 'cluster name, ref cluster.cls';
COMMENT ON COLUMN cluster_var.key IS 'cluster config entry name';
COMMENT ON COLUMN cluster_var.value IS 'cluster entry value';
COMMENT ON COLUMN cluster_var.mtime IS 'cluster config entry last modified time';

--===========================================================--
--                       instance_var                        --
--===========================================================--
-- DROP TABLE IF EXISTS instance_var;
CREATE TABLE IF NOT EXISTS instance_var
(
    ins   TEXT  NOT NULL REFERENCES instance (ins) ON DELETE CASCADE ON UPDATE CASCADE,
    key   TEXT  NOT NULL CHECK (key != ''),
    value JSONB NULL,
    mtime TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (ins, key)
);
COMMENT ON TABLE instance_var IS 'instance config entries';
COMMENT ON COLUMN instance_var.ins IS 'instance name, ref instance.ins';
COMMENT ON COLUMN instance_var.key IS 'instance config entry name';
COMMENT ON COLUMN instance_var.value IS 'instance entry value';
COMMENT ON COLUMN instance_var.mtime IS 'instance config entry last modified time';


--===========================================================--
--                      instance_config                      --
--===========================================================--
-- cluster_config contains MERGED vars
-- ( vars = +cluster,  all_vars = +global & +cluster )

-- DROP VIEW IF EXISTS instance_config;
CREATE OR REPLACE VIEW instance_config AS
SELECT c.cls,
       shard,
       sindex,
       i.ins,
       ip,
       iv.vars                       AS vars,         -- instance vars
       cv.vars                       AS cls_vars,     -- cluster vars
       cv.vars || iv.vars            AS cls_ins_vars, -- cluster + instance vars
       gv.vars || cv.vars || iv.vars AS all_vars      -- global + cluster + instance vars
FROM cluster c
         JOIN instance i USING (cls)
         JOIN (SELECT cls, jsonb_object_agg(key, value) AS vars FROM cluster_var GROUP BY cls) cv ON c.cls = cv.cls
         JOIN (SELECT ins, jsonb_object_agg(key, value) AS vars FROM instance_var GROUP BY ins) iv ON i.ins = iv.ins,
     (SELECT jsonb_object_agg(key, value) AS vars FROM global_var) gv;
COMMENT ON VIEW instance_config IS 'instance config view';



--===========================================================--
--                      cluster_config                       --
--===========================================================--
-- cluster_config contains MERGED vars (+global)
-- DROP VIEW IF EXISTS cluster_config CASCADE;
CREATE OR REPLACE VIEW cluster_config AS
SELECT c.cls,
       shard,
       sindex,
       hosts,                                                                              -- cluster's members
       cv.vars                                                                 AS vars,    -- cluster vars
       jsonb_build_object(c.cls,
                          jsonb_build_object('hosts', hosts, 'vars', cv.vars)) AS config,  -- raw config: cls:{hosts:{},vars{}}
       gv.vars || cv.vars                                                      AS all_vars -- global + cluster vars
FROM cluster c
         JOIN (SELECT cls, jsonb_object_agg(key, value) AS vars FROM cluster_var GROUP BY cls) cv ON c.cls = cv.cls
         JOIN (SELECT cls, jsonb_object_agg(host(ip), vars) AS hosts FROM instance_config GROUP BY cls) cm
              ON c.cls = cm.cls,
     (SELECT jsonb_object_agg(key, value) AS vars FROM global_var) gv;
COMMENT ON VIEW cluster_config IS 'cluster config view';


--===========================================================--
--                        cluster_user                       --
--===========================================================--
-- business user definition in pg_users

-- DROP VIEW IF EXISTS cluster_user;
CREATE OR REPLACE VIEW cluster_user AS
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
FROM cluster_var cv,
     jsonb_array_elements(value) AS u
WHERE cv.key = 'pg_users';
COMMENT ON VIEW cluster_user IS 'pg_users definition from cluster level vars';


--===========================================================--
--                      cluster_database                     --
--===========================================================--
-- business database definition in pg_databases

-- DROP VIEW IF EXISTS cluster_database;
CREATE OR REPLACE VIEW cluster_database AS
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
FROM cluster_var cv,
     jsonb_array_elements(value) AS db
WHERE cv.key = 'pg_databases';
COMMENT ON VIEW cluster_database IS 'pg_databases definition from cluster level vars';


--===========================================================--
--                      cluster_service                      --
--===========================================================--
-- business database definition in pg_databases
CREATE OR REPLACE VIEW cluster_service AS
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
               FROM cluster c
                        JOIN (SELECT cls, jsonb_object_agg(key, value) AS vars FROM cluster_var GROUP BY cls) cv
                             ON c.cls = cv.cls,
                    (SELECT jsonb_object_agg(key, value) AS vars FROM global_var) gv
           ) cf) s1,
     jsonb_array_elements(svcs) s2;
COMMENT ON VIEW cluster_service IS 'services definition from cluster|global level vars';



--===========================================================--
--                           job                             --
--===========================================================--
-- DROP TABLE IF EXISTS job;
CREATE TABLE IF NOT EXISTS job
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
COMMENT ON TABLE job IS 'pigsty job table';
COMMENT ON COLUMN job.id IS 'job id generated by job_id()';
COMMENT ON COLUMN job.name IS 'job name (optional)';
COMMENT ON COLUMN job.type IS 'job type (optional)';
COMMENT ON COLUMN job.data IS 'job data (json)';
COMMENT ON COLUMN job.log IS 'job log content, load after execution';
COMMENT ON COLUMN job.log_path IS 'job log path, can be tailed while running';
COMMENT ON COLUMN job.status IS 'job status enum: draft,ready,run,done,fail';
COMMENT ON COLUMN job.ctime IS 'job creation time';
COMMENT ON COLUMN job.mtime IS 'job modification time';
COMMENT ON COLUMN job.start_at IS 'job start time';
COMMENT ON COLUMN job.finish_at IS 'job done|fail time';

-- DROP FUNCTION IF EXISTS job_id();
CREATE OR REPLACE FUNCTION job_id() RETURNS BIGINT AS
$func$
SELECT (FLOOR(EXTRACT(EPOCH FROM clock_timestamp()) * 1000) - 748569600000 /* epoch */) :: BIGINT <<
       23 /* 41 bit timestamp */ | ((nextval('job_id_seq') & 1023) << 12) | (random() * 4095)::INTEGER
$func$
    LANGUAGE sql VOLATILE;
COMMENT ON FUNCTION job_id() IS 'generate snowflake-like id for job';
ALTER TABLE job ALTER COLUMN id SET DEFAULT job_id(); -- use job_id as id generator

-- DROP FUNCTION IF EXISTS job_id_ts(BIGINT);
CREATE OR REPLACE FUNCTION job_id_ts(id BIGINT) RETURNS TIMESTAMP AS
$func$
SELECT to_timestamp(((id >> 23) + 748569600000)::DOUBLE PRECISION / 1000)::TIMESTAMP
$func$ LANGUAGE sql IMMUTABLE;
COMMENT ON FUNCTION job_id_ts(BIGINT) IS 'extract timestamp from job id';







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
DROP FUNCTION IF EXISTS select_config(_name TEXT);
CREATE OR REPLACE FUNCTION select_config(_name TEXT) RETURNS JSONB AS
$$
SELECT data::JSONB
FROM config
WHERE name = _name
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION select_config(TEXT) IS 'return config data by name';

-----------------------------------------------
-- active_config_name() text
-----------------------------------------------
DROP FUNCTION IF EXISTS active_config_name();
CREATE OR REPLACE FUNCTION active_config_name() RETURNS TEXT AS
$$
SELECT name
FROM config
WHERE is_active
LIMIT 1;
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION active_config_name() IS 'return active config name, null if non is active';


-----------------------------------------------
-- active_config() jsonb
-----------------------------------------------
DROP FUNCTION IF EXISTS active_config();
CREATE OR REPLACE FUNCTION active_config() RETURNS JSONB AS
$$
SELECT data::JSONB
FROM config
WHERE is_active
LIMIT 1;
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION active_config() IS 'return activated config data';


-----------------------------------------------
-- upsert_config(jsonb,text) text
-----------------------------------------------
DROP FUNCTION IF EXISTS upsert_config(JSONB, TEXT);
CREATE OR REPLACE FUNCTION upsert_config(_config JSONB, _name TEXT DEFAULT NULL) RETURNS TEXT AS
$$
INSERT INTO config(name, data, ctime, mtime)
VALUES ( coalesce(_name, 'config-' || (extract(epoch FROM date_trunc('second', now())))::BIGINT::TEXT)
       , _config::JSON
       , date_trunc('second', now()), date_trunc('second', now()))
ON CONFLICT (name) DO UPDATE SET data  = EXCLUDED.data,
                                 mtime = EXCLUDED.mtime
RETURNING name;
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION upsert_config(JSONB,TEXT) IS 'upsert config with unique (manual|auto) config name';
-- if name is given, upsert with config name, otherwise use 'config-epoch' as unique config name

-----------------------------------------------
-- delete_config(name text) jsonb
-----------------------------------------------
DROP FUNCTION IF EXISTS delete_config(TEXT);
CREATE OR REPLACE FUNCTION delete_config(_name TEXT) RETURNS JSONB AS
$$
DELETE
FROM config
WHERE name = _name
RETURNING data;
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION delete_config(TEXT) IS 'delete config by name, return its content';

-----------------------------------------------
-- clean_config
-----------------------------------------------
-- WARNING: TRUNCATE pigsty config RELATED tables!
DROP FUNCTION IF EXISTS clean_config();
CREATE OR REPLACE FUNCTION clean_config() RETURNS VOID AS
$$
TRUNCATE cluster,instance,node,global_var,cluster_var,instance_var CASCADE;
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION clean_config() IS 'TRUNCATE pigsty config RELATED tables cascade';


-----------------------------------------------
-- parse_config(jsonb) (private API)
-----------------------------------------------
-- WARNING: DO NOT USE THIS DIRECTLY (PRIVATE API)
DROP FUNCTION IF EXISTS parse_config(JSONB);
CREATE OR REPLACE FUNCTION parse_config(_data JSONB) RETURNS VOID AS
$$
DECLARE
    _clusters JSONB := _data #> '{all,children}';
BEGIN
    -- trunc tables
    -- TRUNCATE cluster,instance,node,global_var,cluster_var,instance_var CASCADE;

    -- load clusters
    INSERT INTO cluster(cls, shard, sindex) -- abort on conflict
    SELECT key, value #>> '{vars,pg_shard}' AS shard, (value #>> '{vars,pg_sindex}')::INTEGER AS sindex
    FROM jsonb_each((_clusters))
    WHERE key != 'meta';

    -- load nodes
    INSERT INTO node(ip)
    SELECT key::INET AS ip
    FROM -- abort on duplicate ip
         (SELECT key AS cls, value #> '{hosts}' AS hosts
          FROM jsonb_each(_clusters)
          WHERE key != 'meta') c, jsonb_each(c.hosts);

    -- load meta nodes
    INSERT INTO node(ip)
    SELECT key::INET AS ip
    FROM -- set is_meta flag for meta_node
         (SELECT key AS cls, value #> '{hosts}' AS hosts
          FROM jsonb_each((SELECT _data #> '{all,children}'))
          WHERE key = 'meta') c, jsonb_each(c.hosts)
    ON CONFLICT(ip) DO UPDATE SET is_meta = true;

    -- load instances
    INSERT INTO instance(ins, ip, cls, seq, role)
    SELECT cls || '-' || (value ->> 'pg_seq') AS ins,
           key::INET                          AS ip,
           cls,
           (value ->> 'pg_seq')::INTEGER      AS seq,
           (value ->> 'pg_role')::pg_role     AS role
    FROM (SELECT key AS cls, value #> '{hosts}' AS hosts
          FROM jsonb_each(_clusters)
          WHERE key != 'meta') c, jsonb_each(c.hosts);

    -- load global_var
    INSERT INTO global_var
    SELECT key, value
    FROM jsonb_each((SELECT _data #> '{all,vars}'))
    ON CONFLICT(key) DO UPDATE SET value = EXCLUDED.value;

    -- load cluster_var
    INSERT INTO cluster_var(cls, key, value) -- abort on conflict
    SELECT cls, key, value
    FROM (SELECT key AS cls, value -> 'vars' AS vars
          FROM
              jsonb_each(_clusters)
          WHERE key != 'meta') c, jsonb_each(c.vars)
    ON CONFLICT(cls, key) DO UPDATE set value = EXCLUDED.value;

    -- load instance_var
    INSERT INTO instance_var(ins, key, value) -- abort on conflict
    SELECT ins, key, value
    FROM (SELECT cls, cls || '-' || (value ->> 'pg_seq') AS ins, value AS vars
          FROM (SELECT key AS cls, value -> 'hosts' AS hosts
                FROM
                    jsonb_each(_clusters)
                WHERE key != 'meta') c,
              jsonb_each(c.hosts)) i, jsonb_each(vars)
    ON CONFLICT(ins, key) DO UPDATE SET value = EXCLUDED.value;

    -- inject meta_node config to instance_var
    INSERT INTO instance_var(ins, key, value)
    SELECT ins, 'meta_node' AS key, 'true'::JSONB AS value
    FROM (SELECT ins
          FROM (SELECT key::INET AS ip
                FROM (SELECT key AS cls, value #> '{hosts}' AS hosts
                      FROM jsonb_each(_clusters)
                      WHERE key = 'meta') c, jsonb_each(c.hosts)) n
                   JOIN instance i ON n.ip = i.ip
         ) metains
    ON CONFLICT(ins, key) DO UPDATE SET value = excluded.value;

END;
$$ LANGUAGE PlPGSQL VOLATILE;
COMMENT ON FUNCTION parse_config(JSONB) IS 'parse pigsty config file into tables';


-----------------------------------------------
-- deactivate_config
-----------------------------------------------
DROP FUNCTION IF EXISTS deactivate_config();
CREATE OR REPLACE FUNCTION deactivate_config() RETURNS JSONB AS
$$
SELECT clean_config();
UPDATE config
SET is_active = false
WHERE is_active
RETURNING data;
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION deactivate_config() IS 'deactivate current config';


--------------------------------
-- activate_config
--------------------------------
DROP FUNCTION IF EXISTS activate_config(TEXT);
CREATE OR REPLACE FUNCTION activate_config(_name TEXT) RETURNS JSONB AS
$$
SELECT deactivate_config();
SELECT parse_config(select_config(_name));
UPDATE config
SET is_active = true
WHERE name = _name
RETURNING data;
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION activate_config(TEXT) IS 'activate config by name';

-- example: SELECT activate_config('prod');


--------------------------------
-- dump_config
--------------------------------
-- generate ansible inventory from separated tables
-- depend on instance_config view

DROP FUNCTION IF EXISTS dump_config() CASCADE;
CREATE OR REPLACE FUNCTION dump_config() RETURNS JSONB AS
$$
SELECT (hostvars.data || allgroup.data || metagroup.data || groups.data) AS data
FROM (SELECT jsonb_build_object('_meta', jsonb_build_object('hostvars', jsonb_object_agg(host(ip), all_vars))) AS data
      FROM instance_config) hostvars,
     (SELECT jsonb_build_object('all', jsonb_build_object('children', '["meta"]' || jsonb_agg(cls))) AS data
      FROM cluster) allgroup,
     (SELECT jsonb_build_object('meta', jsonb_build_object('hosts', jsonb_agg(host(ip)))) AS data FROM node WHERE is_meta) metagroup,
     (SELECT jsonb_object_agg(cls, cc.member) AS data
      FROM (SELECT cls, jsonb_build_object('hosts', jsonb_agg(host(ip))) AS member
            FROM instance i
            GROUP BY cls) cc) groups;
$$ LANGUAGE SQL;
COMMENT ON FUNCTION dump_config() IS 'dump ansible inventory config from entity tables';


--------------------------------
-- view: inventory
--------------------------------
-- return inventory in different format
CREATE OR REPLACE VIEW inventory AS
SELECT data, data::TEXT as text, jsonb_pretty(data) AS pretty
FROM (SELECT dump_config() AS data) i;







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
DROP FUNCTION IF EXISTS select_node(INET);
CREATE OR REPLACE FUNCTION select_node(_ip INET) RETURNS JSONB AS
$$
SELECT row_to_json(node.*)::JSONB
FROM node
WHERE ip = _ip
LIMIT 1;
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION select_node(INET) IS 'return node json by ip';

-- SELECT select_node('10.189.201.88');

--------------------------------
-- node_cls(ip inet) (cls text)
--------------------------------
CREATE OR REPLACE FUNCTION node_cls(_ip INET) RETURNS TEXT AS
$$
SELECT cls
FROM node
WHERE ip = _ip
LIMIT 1;
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION node_cls(INET) IS 'return node belonged cluster according to ip';
-- example: SELECT node_cls('10.10.10.10') -> pg-test

--------------------------------
-- node_is_meta(ip inet) bool
--------------------------------
DROP FUNCTION IF EXISTS node_is_meta(INET);
CREATE OR REPLACE FUNCTION node_is_meta(_ip INET) RETURNS BOOLEAN AS
$$
SELECT EXISTS(SELECT FROM node WHERE is_meta AND ip = _ip);
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION node_is_meta(INET) IS 'check whether an node (ip) is meta node';

--------------------------------
-- node_status(ip inet) status
--------------------------------
DROP FUNCTION IF EXISTS node_status(INET);
CREATE OR REPLACE FUNCTION node_status(_ip INET) RETURNS status AS
$$
SELECT status
FROM node
WHERE ip = _ip;
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION node_status(INET) IS 'get node status by ip';


--------------------------------
-- node_ins(ip text) (ins text)
--------------------------------
DROP FUNCTION MODIFIES EXISTS node_ins(INET);
CREATE OR REPLACE FUNCTION node_ins(_ip INET) RETURNS TEXT AS
$$
SELECT ins
FROM instance
WHERE ip = _ip
LIMIT 1;
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION node_ins(INET) IS 'return node corresponding pgsql instance according to ip';

--------------------------------
-- upsert_node(ip inet, cls text)
--------------------------------
-- insert new node with optional cluster
-- leave is_meta, ctime intact on upsert, reset cluster on non-null cluster, reset node status is cls has changed!

DROP FUNCTION IF EXISTS upsert_node(INET, TEXT);
CREATE OR REPLACE FUNCTION upsert_node(_ip INET, _cls TEXT DEFAULT NULL) RETURNS INET AS
$$
INSERT INTO node(ip, cls)
VALUES (_ip, _cls)
ON CONFLICT (ip) DO UPDATE SET cls    = CASE WHEN _cls ISNULL THEN node.cls ELSE excluded.cls END,
                               status = CASE
                                            WHEN _cls IS NOT NULL AND _cls != node.cls THEN 'unknown'::status
                                            ELSE node.status END, -- keep status if cls not changed
                               mtime  = now()
RETURNING ip;
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION upsert_node(INET, TEXT) IS 'upsert new node (with optional cls)';

-- example
-- SELECT upsert_node('10.10.10.10', 'pg-meta');

--------------------------------
-- delete_node(ip inet )
--------------------------------
DROP FUNCTION IF EXISTS delete_node(INET);
CREATE OR REPLACE FUNCTION delete_node(_ip INET) RETURNS INET AS
$$
DELETE
FROM node
WHERE ip = _ip
RETURNING ip;
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION delete_node(INET) IS 'delete node by ip';

-- example
-- SELECT delete_node('10.10.10.10');

-----------------------------------------------
-- update_node_status(ip inet, status status) status
-----------------------------------------------
DROP FUNCTION IF EXISTS update_node_status(INET, status);
CREATE OR REPLACE FUNCTION update_node_status(_ip INET, _status status) RETURNS status AS
$$
UPDATE node
SET status = _status
WHERE ip = _ip
RETURNING status;
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION update_node_status(INET,status) IS 'update node status and return it';

-- example:  SELECT update_node_status('10.10.10.10', 'available');


--===========================================================--
--                        instance var                       --
--===========================================================--

-----------------------------------------------
-- update_instance_vars(ins text, vars jsonb) jsonb
-----------------------------------------------

-- overwrite all instance vars
DROP FUNCTION IF EXISTS update_instance_vars(TEXT, JSONB);
CREATE OR REPLACE FUNCTION update_instance_vars(_ins TEXT, _vars JSONB) RETURNS VOID AS
$$
DELETE
FROM instance_var
WHERE ins = _ins; -- delete all instance vars
INSERT INTO instance_var(ins, key, value)
SELECT _ins, key, value
FROM jsonb_each(_vars);
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION update_instance_vars(TEXT, JSONB) IS 'batch overwrite instance config';


-----------------------------------------------
-- update_instance_var(ins text, key text, value jsonb)
-----------------------------------------------

-- overwrite single instance entry
DROP FUNCTION IF EXISTS update_instance_var(TEXT, TEXT, JSONB);
CREATE OR REPLACE FUNCTION update_instance_var(_ins TEXT, _key TEXT, _value JSONB) RETURNS VOID AS
$$
INSERT INTO instance_var(ins, key, value)
VALUES (_ins, _key, _value)
ON CONFLICT (ins, key) DO UPDATE SET value = EXCLUDED.value,
                                     mtime = now();
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION update_instance_var(TEXT,TEXT,JSONB) IS 'upsert single instance config entry';



--===========================================================--
--                      getter                               --
--===========================================================--
CREATE OR REPLACE FUNCTION ins_ip(_ins TEXT) RETURNS TEXT AS
$$
SELECT host(ip)
FROM instance
WHERE ins = _ins
LIMIT 1;
$$ LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION ins_cls(_ins TEXT) RETURNS TEXT AS
$$
SELECT cls
FROM instance
WHERE ins = _ins
LIMIT 1;
$$ LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION ins_role(_ins TEXT) RETURNS TEXT AS
$$
SELECT role
FROM instance
WHERE ins = _ins
LIMIT 1;
$$ LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION ins_seq(_ins TEXT) RETURNS INTEGER AS
$$
SELECT seq
FROM instance
WHERE ins = _ins
LIMIT 1;
$$ LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION ins_is_meta(_ins TEXT) RETURNS BOOLEAN AS
$$
SELECT EXISTS(SELECT FROM node WHERE is_meta AND ip = (SELECT ip FROM instance WHERE ins = _ins));
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION ins_is_meta(TEXT) IS 'check whether an instance name is meta node';

-- reverse lookup (lookup ins via ip)
CREATE OR REPLACE FUNCTION ip2ins(_ip INET) RETURNS TEXT AS
$$
SELECT ins
FROM instance
WHERE ip = _ip
LIMIT 1;
$$ LANGUAGE SQL STABLE;



--===========================================================--
--                     instance CRUD                         --
--===========================================================--

-----------------------------------------------
-- select_instance(ins text)
-----------------------------------------------
DROP FUNCTION IF EXISTS select_instance(TEXT);
CREATE OR REPLACE FUNCTION select_instance(_ins TEXT) RETURNS JSONB AS
$$
SELECT row_to_json(instance.*)::JSONB
FROM instance
WHERE ins = _ins
LIMIT 1;
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION select_instance(TEXT) IS 'return instance json via ins';
-- example: SELECT select_instance('pg-test-1')


-----------------------------------------------
-- select_instance(ip inet)
-----------------------------------------------
DROP FUNCTION IF EXISTS select_instance(INET);
CREATE OR REPLACE FUNCTION select_instance(_ip INET) RETURNS JSONB AS
$$
SELECT row_to_json(instance.*)::JSONB
FROM instance
WHERE ip = _ip
LIMIT 1;
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION select_instance(INET) IS 'return instance json via ip';


-----------------------------------------------
-- upsert_instance(ins text, ip inet, data jsonb)
-----------------------------------------------
DROP FUNCTION IF EXISTS upsert_instance(TEXT, INET, JSONB);
CREATE OR REPLACE FUNCTION upsert_instance(_cls TEXT, _ip INET, _data JSONB) RETURNS VOID AS
$$
DECLARE
    _seq  INTEGER := (_data ->> 'pg_seq')::INTEGER;
    _role pg_role := (_data ->> 'pg_role')::pg_role;
    _ins  TEXT    := _cls || '-' || _seq;
BEGIN
    PERFORM upsert_node(_ip, _cls); -- make sure node exists
    INSERT INTO instance(ins, ip, cls, seq, role)
    VALUES (_ins, _ip, _cls, _seq, _role)
    ON CONFLICT DO UPDATE SET ip    = excluded.ip,
                              cls   = excluded.cls,
                              seq   = excluded.seq,
                              role  = excluded.role,
                              mtime = now();
    PERFORM update_instance_vars(_ins, _data); -- refresh instance_var
END
$$ LANGUAGE PlPGSQL VOLATILE;
COMMENT ON FUNCTION upsert_instance(TEXT, INET, JSONB) IS 'create new instance from cls, ip, vars';



--===========================================================--
--                      cluster var update                   --
--===========================================================--

-- overwrite all cluster config
DROP FUNCTION IF EXISTS update_cluster_vars(TEXT, JSONB);
CREATE OR REPLACE FUNCTION update_cluster_vars(_cls TEXT, _vars JSONB) RETURNS VOID AS
$$
DELETE
FROM cluster_var
WHERE cls = _cls; -- delete all cluster vars
INSERT INTO cluster_var(cls, key, value)
SELECT _cls, key, value
FROM jsonb_each(_vars);
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION update_cluster_vars(TEXT, JSONB) IS 'batch overwrite cluster config';

-- overwrite single cluster config entry
DROP FUNCTION IF EXISTS update_cluster_var(TEXT, TEXT, JSONB);
CREATE OR REPLACE FUNCTION update_cluster_var(_cls TEXT, _key TEXT, _value JSONB) RETURNS VOID AS
$$
INSERT INTO cluster_var(cls, key, value, mtime)
VALUES (_cls, _key, _value, now())
ON CONFLICT (cls, key) DO UPDATE SET value = EXCLUDED.value,
                                     mtime = EXCLUDED.mtime;
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION update_cluster_var(_cls TEXT, key TEXT, value JSONB) IS 'upsert single cluster config entry';



--===========================================================--
--                        cluster crud                        --
--===========================================================--
DROP FUNCTION IF EXISTS select_cluster(TEXT);
CREATE OR REPLACE FUNCTION select_cluster(_cls TEXT) RETURNS JSONB AS
$$
SELECT row_to_json(cluster.*)::JSONB
FROM cluster
WHERE cls = _cls
LIMIT 1;
$$ LANGUAGE SQL STABLE;
COMMENT ON FUNCTION select_cluster(TEXT) IS 'return cluster json via cls';
-- example: SELECT select_cluster('pg-meta-tt')


-- SELECT jsonb_build_object('hosts', jsonb_object_agg(ip, row_to_json(instance.*))) AS ij FROM instance WHERE cls = 'pg-meta-tt' GROUP BY cls;
-- SELECT jsonb_build_object('vars', jsonb_object_agg(key, value)) AS ij FROM cluster_var WHERE cls = 'pg-meta-tt' GROUP BY cls;


-- create new cluster from config file cluster k:v (k=cluster_name,v=cluster_define)
DROP FUNCTION IF EXISTS upsert_cluster(_cls TEXT, _data JSONB);
CREATE OR REPLACE FUNCTION upsert_cluster(_cls TEXT, _data JSONB) RETURNS VOID AS
$$
DECLARE
    _hosts  JSONB   := _data -> 'hosts';
    _vars   JSONB   := _data -> 'vars';
    _shard  TEXT    := _vars ->> 'pg_shard';
    _sindex INTEGER := (_vars ->> 'pg_sindex')::INTEGER;
BEGIN

    -- upsert new cluster
    INSERT INTO cluster(cls, shard, sindex)
    VALUES (_cls, _shard, _sindex)
    ON CONFLICT(cls) DO UPDATE SET shard = excluded.shard, sindex = excluded.sindex;

    -- delete not exists vars and upsert new vars (keep ctime intact)
    DELETE FROM cluster_var WHERE cls = _cls AND key NOT IN (SELECT key FROM jsonb_each(_vars));
    INSERT INTO cluster_var(cls, key, value)
    SELECT _cls, key, value
    FROM jsonb_each(_vars)
    ON CONFLICT(cls, key) DO UPDATE SET value = excluded.value, mtime = excluded.mtime;

    -- delete not exists instances and upsert new instances (keep existing instance info)
    DELETE FROM cluster_var WHERE cls = _cls AND key NOT IN (SELECT key FROM jsonb_each(_vars));
    INSERT INTO cluster_var(cls, key, value)
    SELECT _cls, key, value
    FROM jsonb_each(_vars)
    ON CONFLICT(cls, key) DO UPDATE SET value = excluded.value, mtime = excluded.mtime;

END
$$ LANGUAGE PlPGSQL VOLATILE;
COMMENT ON FUNCTION upsert_cluster(TEXT, JSONB) IS 'upsert_cluster from k,v config';


--===========================================================--
--                      global var update                    --
--===========================================================--
-- update_global_vars(vars JSON) will overwrite existing global config
-- update_global_var(key TEXT,value JSON) will upsert single global config entry

--------------------------------
-- update_global_vars(vars jsonb)
--------------------------------
DROP FUNCTION IF EXISTS update_global_vars(JSONB);
CREATE OR REPLACE FUNCTION update_global_vars(_vars JSONB) RETURNS VOID AS
$$
DELETE
FROM global_var
WHERE true; -- use vars will remove all existing config files
INSERT INTO global_var(key, value)
SELECT key, value
FROM jsonb_each(_vars);
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION update_global_vars(JSONB) IS 'batch overwrite global config';

--------------------------------
-- update_global_var(key text, value jsonb)
--------------------------------
DROP FUNCTION IF EXISTS update_global_var(TEXT, JSONB);
CREATE OR REPLACE FUNCTION update_global_var(_key TEXT, _value JSONB) RETURNS VOID AS
$$
INSERT INTO global_var(key, value, mtime)
VALUES (_key, _value, now())
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value,
                                mtime = EXCLUDED.mtime;
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION update_global_var(TEXT,JSONB) IS 'upsert single global config entry';

