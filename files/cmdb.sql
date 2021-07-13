-- ######################################################################
-- # File      :   cmdb.sql
-- # Desc      :   Pigsty CMDB baseline (pg-meta.meta)
-- # Ctime     :   2021-04-21
-- # Mtime     :   2021-07-13
-- # Copyright (C) 2018-2021 Ruohang Feng
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
    cls     TEXT        NULL REFERENCES pigsty.cluster (cls) ON DELETE CASCADE ON UPDATE CASCADE,
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
    INSERT INTO pigsty.node(ip)
    SELECT key::INET AS ip
    FROM -- abort on duplicate ip
         (SELECT key AS cls, value #> '{hosts}' AS hosts
          FROM jsonb_each(_clusters)
          WHERE key != 'meta') c, jsonb_each(c.hosts);

    -- load meta nodes
    INSERT INTO pigsty.node(ip)
    SELECT key::INET AS ip
    FROM -- set is_meta flag for meta_node
         (SELECT key AS cls, value #> '{hosts}' AS hosts
          FROM jsonb_each((SELECT _data #> '{all,children}'))
          WHERE key = 'meta') c, jsonb_each(c.hosts)
    ON CONFLICT(ip) DO UPDATE SET is_meta = true;

    -- load instances
    INSERT INTO pigsty.instance(ins, ip, cls, seq, role)
    SELECT cls || '-' || (value ->> 'pg_seq') AS ins,
           key::INET                          AS ip,
           cls,
           (value ->> 'pg_seq')::INTEGER      AS seq,
           (value ->> 'pg_role')::pigsty.pg_role     AS role
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
                   JOIN instance i ON n.ip = i.ip
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
    _seq  INTEGER := (_data ->> 'pg_seq')::INTEGER;
    _role pigsty.pg_role := (_data ->> 'pg_role')::pigsty.pg_role;
    _ins  TEXT    := _cls || '-' || _seq;
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


-- SELECT jsonb_build_object('hosts', jsonb_object_agg(ip, row_to_json(instance.*))) AS ij FROM instance WHERE cls = 'pg-meta-tt' GROUP BY cls;
-- SELECT jsonb_build_object('vars', jsonb_object_agg(key, value)) AS ij FROM cluster_var WHERE cls = 'pg-meta-tt' GROUP BY cls;

-- TODO: fix instance
-- update existing cluster from config file cluster k:v (k=cluster_name,v=cluster_define)
DROP FUNCTION IF EXISTS pigsty.upsert_cluster(_cls TEXT, _data JSONB);
CREATE OR REPLACE FUNCTION pigsty.upsert_cluster(_cls TEXT, _data JSONB) RETURNS VOID AS
$$
DECLARE
    _hosts  JSONB   := _data -> 'hosts';
    _vars   JSONB   := _data -> 'vars';
    _shard  TEXT    := _vars ->> 'pg_shard';
    _sindex INTEGER := (_vars ->> 'pg_sindex')::INTEGER;
BEGIN

    -- upsert new cluster
    INSERT INTO pigsty.cluster(cls, shard, sindex)
    VALUES (_cls, _shard, _sindex)
    ON CONFLICT(cls) DO UPDATE SET shard = excluded.shard, sindex = excluded.sindex;

    -- delete not exists vars and upsert new vars (keep ctime intact)
    DELETE FROM pigsty.cluster_var WHERE cls = _cls AND key NOT IN (SELECT key FROM jsonb_each(_vars));
    INSERT INTO pigsty.cluster_var(cls, key, value)
    SELECT _cls, key, value
    FROM jsonb_each(_vars)
    ON CONFLICT(cls, key) DO UPDATE SET value = excluded.value, mtime = excluded.mtime;

    -- delete not exists instances and upsert new instances (keep existing instance info)
    -- DELETE FROM instance WHERE cls = _cls;
    -- TODO: insert instance
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
--                          log                             --
--===========================================================--
CREATE TYPE pigsty.log_level AS ENUM (
    'LOG',
    'INFO',
    'NOTICE',
    'WARNING',
    'ERROR',
    'FATAL',
    'PANIC',
    'DEBUG'
    );

COMMENT ON TYPE pigsty.log_level IS 'PostgreSQL Log Level';

CREATE TYPE pigsty.cmd_tag AS ENUM (
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
COMMENT ON TYPE pigsty.cmd_tag IS 'PostgreSQL Log Command Tag';

CREATE TYPE pigsty.err_code AS ENUM (
    -- Class 00 - Successful Completion
    '00000', -- 'successful_completion',
    -- Class 01 - Warning
    '01000', -- 'warning',
    '0100C', -- 'dynamic_result_sets_returned',
    '01008', -- 'implicit_zero_bit_padding',
    '01003', -- 'null_value_eliminated_in_set_function',
    '01007', -- 'privilege_not_granted',
    '01006', -- 'privilege_not_revoked',
    '01004', -- 'string_data_right_truncation',
    '01P01', -- 'deprecated_feature',
    -- Class 02 - No Data (this is also a warning class per the SQL standard)
    '02000', -- 'no_data',
    '02001', -- 'no_additional_dynamic_result_sets_returned',
    -- Class 03 - SQL Statement Not Yet Complete
    '03000', -- 'sql_statement_not_yet_complete',
    -- Class 08 - Connection Exception
    '08000', -- 'connection_exception',
    '08003', -- 'connection_does_not_exist',
    '08006', -- 'connection_failure',
    '08001', -- 'sqlclient_unable_to_establish_sqlconnection',
    '08004', -- 'sqlserver_rejected_establishment_of_sqlconnection',
    '08007', -- 'transaction_resolution_unknown',
    '08P01', -- 'protocol_violation',
    -- Class 09 - Triggered Action Exception
    '09000', -- 'triggered_action_exception',
    -- Class 0A - Feature Not Supported
    '0A000', -- 'feature_not_supported',
    -- Class 0B - Invalid Transaction Initiation
    '0B000', -- 'invalid_transaction_initiation',
    -- Class 0F - Locator Exception
    '0F000', -- 'locator_exception',
    '0F001', -- 'invalid_locator_specification',
    -- Class 0L - Invalid Grantor
    '0L000', -- 'invalid_grantor',
    '0LP01', -- 'invalid_grant_operation',
    -- Class 0P - Invalid Role Specification
    '0P000', -- 'invalid_role_specification',
    -- Class 0Z - Diagnostics Exception
    '0Z000', -- 'diagnostics_exception',
    '0Z002', -- 'stacked_diagnostics_accessed_without_active_handler',
    -- Class 20 - Case Not Found
    '20000', -- 'case_not_found',
    -- Class 21 - Cardinality Violation
    '21000', -- 'cardinality_violation',
    -- Class 22 - Data Exception
    '22000', -- 'data_exception',
    '2202E', -- 'array_subscript_error',
    '22021', -- 'character_not_in_repertoire',
    '22008', -- 'datetime_field_overflow',
    '22012', -- 'division_by_zero',
    '22005', -- 'error_in_assignment',
    '2200B', -- 'escape_character_conflict',
    '22022', -- 'indicator_overflow',
    '22015', -- 'interval_field_overflow',
    '2201E', -- 'invalid_argument_for_logarithm',
    '22014', -- 'invalid_argument_for_ntile_function',
    '22016', -- 'invalid_argument_for_nth_value_function',
    '2201F', -- 'invalid_argument_for_power_function',
    '2201G', -- 'invalid_argument_for_width_bucket_function',
    '22018', -- 'invalid_character_value_for_cast',
    '22007', -- 'invalid_datetime_format',
    '22019', -- 'invalid_escape_character',
    '2200D', -- 'invalid_escape_octet',
    '22025', -- 'invalid_escape_sequence',
    '22P06', -- 'nonstandard_use_of_escape_character',
    '22010', -- 'invalid_indicator_parameter_value',
    '22023', -- 'invalid_parameter_value',
    '2201B', -- 'invalid_regular_expression',
    '2201W', -- 'invalid_row_count_in_limit_clause',
    '2201X', -- 'invalid_row_count_in_result_offset_clause',
    '22009', -- 'invalid_time_zone_displacement_value',
    '2200C', -- 'invalid_use_of_escape_character',
    '2200G', -- 'most_specific_type_mismatch',
    '22004', -- 'null_value_not_allowed',
    '22002', -- 'null_value_no_indicator_parameter',
    '22003', -- 'numeric_value_out_of_range',
    '2200H', -- 'sequence_generator_limit_exceeded',
    '22026', -- 'string_data_length_mismatch',
    '22001', -- 'string_data_right_truncation',
    '22011', -- 'substring_error',
    '22027', -- 'trim_error',
    '22024', -- 'unterminated_c_string',
    '2200F', -- 'zero_length_character_string',
    '22P01', -- 'floating_point_exception',
    '22P02', -- 'invalid_text_representation',
    '22P03', -- 'invalid_binary_representation',
    '22P04', -- 'bad_copy_file_format',
    '22P05', -- 'untranslatable_character',
    '2200L', -- 'not_an_xml_document',
    '2200M', -- 'invalid_xml_document',
    '2200N', -- 'invalid_xml_content',
    '2200S', -- 'invalid_xml_comment',
    '2200T', -- 'invalid_xml_processing_instruction',
    -- Class 23 - Integrity Constraint Violation
    '23000', -- 'integrity_constraint_violation',
    '23001', -- 'restrict_violation',
    '23502', -- 'not_null_violation',
    '23503', -- 'foreign_key_violation',
    '23505', -- 'unique_violation',
    '23514', -- 'check_violation',
    '23P01', -- 'exclusion_violation',
    -- Class 24 - Invalid Cursor State
    '24000', -- 'invalid_cursor_state',
    -- Class 25 - Invalid Transaction State
    '25000', -- 'invalid_transaction_state',
    '25001', -- 'active_sql_transaction',
    '25002', -- 'branch_transaction_already_active',
    '25008', -- 'held_cursor_requires_same_isolation_level',
    '25003', -- 'inappropriate_access_mode_for_branch_transaction',
    '25004', -- 'inappropriate_isolation_level_for_branch_transaction',
    '25005', -- 'no_active_sql_transaction_for_branch_transaction',
    '25006', -- 'read_only_sql_transaction',
    '25007', -- 'schema_and_data_statement_mixing_not_supported',
    '25P01', -- 'no_active_sql_transaction',
    '25P02', -- 'in_failed_sql_transaction',
    -- Class 26 - Invalid SQL Statement Name
    '26000', -- 'invalid_sql_statement_name',
    -- Class 27 - Triggered Data Change Violation
    '27000', -- 'triggered_data_change_violation',
    -- Class 28 - Invalid Authorization Specification
    '28000', -- 'invalid_authorization_specification',
    '28P01', -- 'invalid_password',
    -- Class 2B - Dependent Privilege Descriptors Still Exist
    '2B000', -- 'dependent_privilege_descriptors_still_exist',
    '2BP01', -- 'dependent_objects_still_exist',
    -- Class 2D - Invalid Transaction Termination
    '2D000', -- 'invalid_transaction_termination',
    -- Class 2F - SQL Routine Exception
    '2F000', -- 'sql_routine_exception',
    '2F005', -- 'function_executed_no_return_statement',
    '2F002', -- 'modifying_sql_data_not_permitted',
    '2F003', -- 'prohibited_sql_statement_attempted',
    '2F004', -- 'reading_sql_data_not_permitted',
    -- Class 34 - Invalid Cursor Name
    '34000', -- 'invalid_cursor_name',
    -- Class 38 - External Routine Exception
    '38000', -- 'external_routine_exception',
    '38001', -- 'containing_sql_not_permitted',
    '38002', -- 'modifying_sql_data_not_permitted',
    '38003', -- 'prohibited_sql_statement_attempted',
    '38004', -- 'reading_sql_data_not_permitted',
    -- Class 39 - External Routine Invocation Exception
    '39000', -- 'external_routine_invocation_exception',
    '39001', -- 'invalid_sqlstate_returned',
    '39004', -- 'null_value_not_allowed',
    '39P01', -- 'trigger_protocol_violated',
    '39P02', -- 'srf_protocol_violated',
    -- Class 3B - Savepoint Exception
    '3B000', -- 'savepoint_exception',
    '3B001', -- 'invalid_savepoint_specification',
    -- Class 3D - Invalid Catalog Name
    '3D000', -- 'invalid_catalog_name',
    -- Class 3F - Invalid Schema Name
    '3F000', -- 'invalid_schema_name',
    -- Class 40 - Transaction Rollback
    '40000', -- 'transaction_rollback',
    '40002', -- 'transaction_integrity_constraint_violation',
    '40001', -- 'serialization_failure',
    '40003', -- 'statement_completion_unknown',
    '40P01', -- 'deadlock_detected',
    -- Class 42 - Syntax Error or Access Rule Violation
    '42000', -- 'syntax_error_or_access_rule_violation',
    '42601', -- 'syntax_error',
    '42501', -- 'insufficient_privilege',
    '42846', -- 'cannot_coerce',
    '42803', -- 'grouping_error',
    '42P20', -- 'windowing_error',
    '42P19', -- 'invalid_recursion',
    '42830', -- 'invalid_foreign_key',
    '42602', -- 'invalid_name',
    '42622', -- 'name_too_long',
    '42939', -- 'reserved_name',
    '42804', -- 'datatype_mismatch',
    '42P18', -- 'indeterminate_datatype',
    '42P21', -- 'collation_mismatch',
    '42P22', -- 'indeterminate_collation',
    '42809', -- 'wrong_object_type',
    '42703', -- 'undefined_column',
    '42883', -- 'undefined_function',
    '42P01', -- 'undefined_table',
    '42P02', -- 'undefined_parameter',
    '42704', -- 'undefined_object',
    '42701', -- 'duplicate_column',
    '42P03', -- 'duplicate_cursor',
    '42P04', -- 'duplicate_database',
    '42723', -- 'duplicate_function',
    '42P05', -- 'duplicate_prepared_statement',
    '42P06', -- 'duplicate_schema',
    '42P07', -- 'duplicate_table',
    '42712', -- 'duplicate_alias',
    '42710', -- 'duplicate_object',
    '42702', -- 'ambiguous_column',
    '42725', -- 'ambiguous_function',
    '42P08', -- 'ambiguous_parameter',
    '42P09', -- 'ambiguous_alias',
    '42P10', -- 'invalid_column_reference',
    '42611', -- 'invalid_column_definition',
    '42P11', -- 'invalid_cursor_definition',
    '42P12', -- 'invalid_database_definition',
    '42P13', -- 'invalid_function_definition',
    '42P14', -- 'invalid_prepared_statement_definition',
    '42P15', -- 'invalid_schema_definition',
    '42P16', -- 'invalid_table_definition',
    '42P17', -- 'invalid_object_definition',
    -- Class 44 - WITH CHECK OPTION Violation
    '44000', -- 'with_check_option_violation',
    -- Class 53 - Insufficient Resources
    '53000', -- 'insufficient_resources',
    '53100', -- 'disk_full',
    '53200', -- 'out_of_memory',
    '53300', -- 'too_many_connections',
    '53400', -- 'configuration_limit_exceeded',
    -- Class 54 - Program Limit Exceeded
    '54000', -- 'program_limit_exceeded',
    '54001', -- 'statement_too_complex',
    '54011', -- 'too_many_columns',
    '54023', -- 'too_many_arguments',
    -- Class 55 - Object Not In Prerequisite State
    '55000', -- 'object_not_in_prerequisite_state',
    '55006', -- 'object_in_use',
    '55P02', -- 'cant_change_runtime_param',
    '55P03', -- 'lock_not_available',
    -- Class 57 - Operator Intervention
    '57000', -- 'operator_intervention',
    '57014', -- 'query_canceled',
    '57P01', -- 'admin_shutdown',
    '57P02', -- 'crash_shutdown',
    '57P03', -- 'cannot_connect_now',
    '57P04', -- 'database_dropped',
    -- Class 58 - System Error (errors external to PostgreSQL itself)
    '58000', -- 'system_error',
    '58030', -- 'io_error',
    '58P01', -- 'undefined_file',
    '58P02', -- 'duplicate_file',
    -- Class F0 - Configuration File Error
    'F0000', -- 'config_file_error',
    'F0001', -- 'lock_file_exists',
    -- Class HV - Foreign Data Wrapper Error (SQL/MED)
    'HV000', -- 'fdw_error',
    'HV005', -- 'fdw_column_name_not_found',
    'HV002', -- 'fdw_dynamic_parameter_value_needed',
    'HV010', -- 'fdw_function_sequence_error',
    'HV021', -- 'fdw_inconsistent_descriptor_information',
    'HV024', -- 'fdw_invalid_attribute_value',
    'HV007', -- 'fdw_invalid_column_name',
    'HV008', -- 'fdw_invalid_column_number',
    'HV004', -- 'fdw_invalid_data_type',
    'HV006', -- 'fdw_invalid_data_type_descriptors',
    'HV091', -- 'fdw_invalid_descriptor_field_identifier',
    'HV00B', -- 'fdw_invalid_handle',
    'HV00C', -- 'fdw_invalid_option_index',
    'HV00D', -- 'fdw_invalid_option_name',
    'HV090', -- 'fdw_invalid_string_length_or_buffer_length',
    'HV00A', -- 'fdw_invalid_string_format',
    'HV009', -- 'fdw_invalid_use_of_null_pointer',
    'HV014', -- 'fdw_too_many_handles',
    'HV001', -- 'fdw_out_of_memory',
    'HV00P', -- 'fdw_no_schemas',
    'HV00J', -- 'fdw_option_name_not_found',
    'HV00K', -- 'fdw_reply_handle',
    'HV00Q', -- 'fdw_schema_not_found',
    'HV00R', -- 'fdw_table_not_found',
    'HV00L', -- 'fdw_unable_to_create_execution',
    'HV00M', -- 'fdw_unable_to_create_reply',
    'HV00N', -- 'fdw_unable_to_establish_connection',
    -- Class P0 - PL/pgSQL Error
    'P0000', -- 'plpgsql_error',
    'P0001', -- 'raise_exception',
    'P0002', -- 'no_data_found',
    'P0003', -- 'too_many_rows',
    -- Class XX - Internal Error
    'XX000', -- 'internal_error',
    'XX001', -- 'data_corrupted',
    'XX002' -- 'index_corrupted',
    );
COMMENT ON TYPE pigsty.err_code IS 'PostgreSQL Error Code';

-- csvlog sample table
-- DROP TABLE pigsty.csvlog;
CREATE TABLE IF NOT EXISTS pigsty.csvlog
(
    ts       TIMESTAMP,        -- ts
    username TEXT,             -- usename
    datname  TEXT,             -- datname
    pid      integer,          -- process_id
    conn     TEXT,             -- connect_from
    sid      TEXT,             -- session id
    sln      bigint,           -- session line number
    cmd_tag  pigsty.cmd_tag,   -- command tag
    stime    TIMESTAMP,        -- session start time
    vxid     TEXT,             -- virtual transaction id
    txid     bigint,           -- transaction id
    level    pigsty.log_level, -- log level
    code     pigsty.err_code,  -- sql state code
    msg      TEXT,             -- message
    detail   TEXT,
    hint     TEXT,
    iq       TEXT,             -- internal query
    iqp      INTEGER,          -- internal query position
    context  TEXT,
    q        TEXT,             -- query
    qp       INTEGER,          -- query position
    location TEXT,             -- location
    appname  TEXT,             -- application name
    backend  TEXT              -- backend_type
);
CREATE INDEX ON pigsty.csvlog (ts);
CREATE INDEX ON pigsty.csvlog (username);
CREATE INDEX ON pigsty.csvlog (datname);
CREATE INDEX ON pigsty.csvlog (code);
CREATE INDEX ON pigsty.csvlog (level);
CREATE INDEX ON pigsty.csvlog (sid, sln);

