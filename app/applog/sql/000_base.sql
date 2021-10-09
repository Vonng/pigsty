-------------------------------------------------------------------------
-- Top level namespace applog
-------------------------------------------------------------------------
DROP SCHEMA IF EXISTS applog CASCADE;
CREATE SCHEMA IF NOT EXISTS applog;
SET search_path TO applog,public;


-------------------------------------------------------------------------
-- temp base table applog.t_privacy_log
-------------------------------------------------------------------------
CREATE TABLE applog.t_privacy_log
(
    data JSONB
);
-- COPY t_privacy_log FROM '/tmp/App_Privacy_Report_v4_2021-10-09T09_35_45.ndjson';

-------------------------------------------------------------------------
-- analyze view: applog.privacy_log
-------------------------------------------------------------------------
CREATE MATERIALIZED VIEW applog.privacy_log AS
SELECT (data ->> 'timeStamp')::TIMESTAMPTZ      AS ts,
       ((data ->> 'identifier'))::UUID          AS id,
       data ->> 'type'                          AS type,
       data ->> 'kind'                          AS kind,
       data #>> '{accessor,identifier}'         AS app,
       data ->> 'category'                      AS category,
       data ->> 'accessor'                      AS accessor,
       data ->> 'bundleID'                      AS bundle_id,
       data ->> 'domain'                        AS domain,
       data ->> 'domainOwner'                   AS domain_owner,
       data ->> 'context'                       AS context,
       data ->> 'domainType'                    AS domain_type,
       (data ->> 'firstTimeStamp')::TIMESTAMPTZ AS first_ts,
       data ->> 'initiatedType'                 AS initiated_type,
       data ->> 'hits'                          AS hits
FROM applog.t_privacy_log
ORDER BY 1;

CREATE INDEX ON applog.privacy_log (ts);
CREATE INDEX ON applog.privacy_log (app);
CREATE INDEX ON applog.privacy_log (category);
REFRESH MATERIALIZED VIEW applog.privacy_log;
