# PGSQL Monitor

> How to use Pigsty to monitor remote (existing) PostgreSQL cluster and [RDS](#monitor-rds)?

----------------

## Overview

Pigsty uses the modern observability stack for PostgreSQL monitoring:

* Grafana for metrics visualization and PostgreSQL datasource.
* Prometheus for PostgreSQL / Pgbouncer / Patroni / HAProxy / Node metrics
* Loki for PostgreSQL / Pgbouncer / Patroni / pgBackRest logs
* Battery-Include [dashboards](PGSQL-DASHBOARD) for PostgreSQL and everything else

**Metrics**

PostgreSQL's metrics are defined by collector files: [`pg_exporter.yml`](https://github.com/Vonng/pigsty/blob/master/roles/pgsql/templates/pg_exporter.yml). Prometheus record rules and alert evaluation will further process it: [`files/prometheus/rules/pgsql.yml`](https://github.com/Vonng/pigsty/blob/master/files/prometheus/rules/pgsql.yml)

There are three identity labels: `cls`, `ins`, `ip`, which will be attached to all metrics & logs. node & haproxy will try to reuse the same identity to provide consistent metrics & logs.

```yaml
{ cls: pg-meta, ins: pg-meta-1, ip: 10.10.10.10 }
{ cls: pg-meta, ins: pg-test-1, ip: 10.10.10.11 }
{ cls: pg-meta, ins: pg-test-2, ip: 10.10.10.12 }
{ cls: pg-meta, ins: pg-test-3, ip: 10.10.10.13 }
```

**Logs**

PostgreSQL-related logs are collected by promtail and sent to Loki on infra nodes by default.

- [`pg_log_dir`](PARAM#pg_log_dir) : postgres log dir, `/pg/log/postgres` by default
- [`pgbouncer_log_dir`](PARAM#pgbouncer_log_dir) : pgbouncer log dir, `/pg/log/pgbouncer` by default
- [`patroni_log_dir`](PARAM#patroni_log_dir) : patroni log dir, `/pg/log/patroni` by default
- [`pgbackrest_log_dir`](PARAM#pgbackrest_log_dir) : pgbackrest log dir, `/pg/log/pgbackrest` by default

**Targets**

Prometheus monitoring targets are defined in static files under `/etc/prometheus/targets/pgsql/`. Each instance will have a corresponding file. Take `pg-meta-1` as an example:

```yaml
# pg-meta-1 [primary] @ 10.10.10.10
- labels: { cls: pg-meta, ins: pg-meta-1, ip: 10.10.10.10 }
  targets:
    - 10.10.10.10:9630    # <--- pg_exporter for PostgreSQL metrics
    - 10.10.10.10:9631    # <--- pg_exporter for Pgbouncer metrics
    - 10.10.10.10:8008    # <--- patroni metrics
```

When the global flag [`patroni_ssl_enabled`](PARAM#patroni_ssl_enabled) is set, the patroni target will be managed as `/etc/prometheus/targets/patroni/<ins>.yml` because it requires a different scrape endpoint (https).

Prometheus monitoring target will be removed when a cluster is removed by `bin/pgsql-rm` or `pgsql-rm.yml`. You can use playbook subtasks, or remove them manually:

```bash
bin/pgmon-rm <ins>      # remove prometheus targets from all infra nodes
```

Remote RDS targets are managed as `/etc/prometheus/targets/pgrds/<cls>.yml`. It will be created by the [`pgsql-monitor.yml`](PGSQL-PLAYBOOK#pgsql-monitor) playbook or `bin/pgmon-add` script.


----------------

## Monitor Mode

There are three ways to monitor PostgreSQL instances in Pigsty:

|        Item \ Level        |                   L1                   |                       L2                        |               L3                |
| :------------------------: | :------------------------------------: | :---------------------------------------------: | :-----------------------------: |
|            Name            | [Remote Database Service](monitor-rds) | [Existing Deployment](monitor-existing-cluster) |    Fully Managed Deployment     |
|            Abbr            |                **RDS**                 |                   **MANAGED**                   |            **FULL**             |
|           Scenes           |        connect string URL only         |                  ssh-sudo-able                  |   Instances created by Pigsty   |
|    PGCAT Functionality     |          ✅ Full Availability           |               ✅ Full Availability               |       ✅ Full Availability       |
|    PGSQL Functionality     |           ✅ PG metrics only            |             ✅  PG and node metrics              |         ✅ Full Support          |
|  Connection Pool Metrics   |            ❌ Not available             |                   ⚠️ Optional                    |        ✅ Pre-Configured         |
|   Load Balancer Metrics    |            ❌ Not available             |                   ⚠️ Optional                    |        ✅ Pre-Configured         |
|    PGLOG Functionality     |            ❌  Not Available            |                   ⚠️  Optional                   |           ⚠️  Optional           |
|        PG Exporter         |            ⚠️ On infra nodes            |                  ✅ On DB nodes                  |          ✅ On DB nodes          |
|       Node Exporter        |             ❌ Not Deployed             |                 ✅  On DB nodes                  |          ✅ On DB nodes          |
|  Intrusion into DB nodes   |            ✅ Non-Intrusive             |              ⚠️ Installing Exporter              |    ⚠️ Fully Managed by Pigsty    |
|  Instance Already Exists   |                 ✅ Yes                  |                      ✅ Yes                      |       ⚠️ Created by Pigsty       |
| Monitoring users and views |            ⚠️Manually Setup             |                 ⚠️Manually Setup                 |        ✅ Auto configured        |
| Deployment Usage Playbook  |         `bin/pgmon-add <cls>`          |        subtasks of `pgsql.ym`/`node.yml`        |           `pgsql.yml`           |
|    Required Privileges     |   connectable PGURL from infra nodes   |         DB node ssh and sudo privileges         | DB node ssh and sudo privileges |
|     Function Overview      |             PGCAT + PGRDS              |               Most Functionality                |       Full Functionality        |


----------------

## Monitor Existing Cluster

Suppose the target DB node can be managed by Pigsty (accessible via ssh and sudo is available). In that case, you can use the `pg_exporter` task in the [`pgsql.yml`](PGSQL-PLAYBOOK#pgsqlyml) playbook to deploy the monitoring component PG Exporter on the target node in the same manner as a standard deployment. 

You can also deploy the connection pool and its monitoring on existing instance nodes using the `pgbouncer` and `pgbouncer_exporter` tasks from the same playbook. Additionally, you can deploy host monitoring, load balancing, and log collection components using the `node_exporter`, `haproxy`, and `promtail` tasks from the [`node.yml`](NODE#nodeyml) playbook, achieving a similar user experience with the native Pigsty cluster.

The definition method for existing clusters is very similar to the normal clusters managed by Pigsty. Selectively run certain tasks from the `pgsql.yml` playbook instead of running the entire playbook.

```bash
./node.yml  -l <cls> -t node_repo,node_pkg           # Add YUM sources for INFRA nodes on host nodes and install packages.
./node.yml  -l <cls> -t node_exporter,node_register  # Configure host monitoring and add to Prometheus.
./node.yml  -l <cls> -t promtail                     # Configure host log collection and send to Loki.
./pgsql.yml -l <cls> -t pg_exporter,pg_register      # Configure PostgreSQL monitoring and register with Prometheus/Grafana.
```

Since the target database cluster already exists, you must manually [setup monitoring users, schemas, and extensions](#monitor-setup) on the target database cluster.


----------------

## Monitor RDS

If you can **only access the target database via PGURL** (database connection string), you can refer to the instructions here for configuration. In this mode, Pigsty deploys the corresponding PG Exporter on the [INFRA node](NODE#INFRA节点) to fetch metrics from the remote database, as shown below:


```
------ infra ------
|                 |
|   prometheus    |            v---- pg-foo-1 ----v
|       ^         |  metrics   |         ^        |
|   pg_exporter <-|------------|----  postgres    |
|   (port: 20001) |            | 10.10.10.10:5432 |
|       ^         |            ^------------------^
|       ^         |                      ^
|       ^         |            v---- pg-foo-2 ----v
|       ^         |  metrics   |         ^        |
|   pg_exporter <-|------------|----  postgres    |
|   (port: 20002) |            | 10.10.10.11:5433 |
-------------------            ^------------------^
```

The monitoring system will no longer have host/pooler/load balancer metrics. But the PostgreSQL metrics & catalog info are still available. Pigsty has two dedicated dashboards for that: [PGRDS Cluster](https://demo.pigsty.cc/d/pgrds-cluster) and [PGRDS Instance](https://demo.pigsty.cc/d/pgrds-instance). Overview and Database level dashboards are reused. Since Pigsty cannot manage your RDS, you have to [setup monitor](#monitor-setup) on the target database in advance.

Below, we use a sandbox environment as an example: now we assume that the `pg-meta` cluster is an RDS instance `pg-foo-1` to be monitored, and the `pg-test` cluster is an RDS cluster `pg-bar` to be monitored:

1. Create monitoring schemas, users, and permissions on the target. Refer to [Monitoring Object Configuration](#MonitoringObjectConfiguration) for details.

2. Declare the cluster in the configuration list. For example, suppose we want to monitor the "remote" `pg-meta` & `pg-test` clusters:

   ```yaml
   infra:            # Infra cluster for proxies, monitoring, alerts, etc.
     hosts: { 10.10.10.10: { infra_seq: 1 } }
     vars:           # Install pg_exporter on 'infra' group for remote postgres RDS
       pg_exporters: # List all remote instances here, assign a unique unused local port for k
         20001: { pg_cluster: pg-foo, pg_seq: 1, pg_host: 10.10.10.10 , pg_databases: [{ name: meta }] } # Register meta database as Grafana data source

         20002: { pg_cluster: pg-bar, pg_seq: 1, pg_host: 10.10.10.11 , pg_port: 5432 } # Several different connection string concatenation methods
         20003: { pg_cluster: pg-bar, pg_seq: 2, pg_host: 10.10.10.12 , pg_exporter_url: 'postgres://dbuser_monitor:DBUser.Monitor@10.10.10.12:5432/postgres?sslmode=disable'}
         20004: { pg_cluster: pg-bar, pg_seq: 3, pg_host: 10.10.10.13 , pg_monitor_username: dbuser_monitor, pg_monitor_password: DBUser.Monitor }
   ```

   The databases listed in the `pg_databases` field will be registered in Grafana as a PostgreSQL data source, providing data support for the PGCAT monitoring panel. If you don't want to use PGCAT and register the database in Grafana, set `pg_databases` to an empty array or leave it blank.

   ![pigsty-monitor.jpg](https://repo.pigsty.cc/img/pgsql-monitor.jpg)

3. Execute the command to add monitoring: `bin/pgmon-add <clsname>`

   ```bash
   bin/pgmon-add pg-foo  # Bring the pg-foo cluster into monitoring
   bin/pgmon-add pg-bar  # Bring the pg-bar cluster into monitoring
   ```

4. To remove a remote cluster from monitoring, use `bin/pgmon-rm <clsname>`

   ```bash
   bin/pgmon-rm pg-foo  # Remove pg-foo from Pigsty monitoring
   bin/pgmon-rm pg-bar  # Remove pg-bar from Pigsty monitoring
   ```

You can use more parameters to override the default `pg_exporter` options. Here is an example for monitoring Aliyun RDS and PolarDB with Pigsty:

<details><summary>Example: Monitor Aliyun RDS PG & PolarDB</summary>

Check [remote.yml](https://github.com/Vonng/pigsty/blob/master/files/pigsty/remote.yml) config for details.

```yaml
infra:            # infra cluster for proxy, monitor, alert, etc..
  hosts: { 10.10.10.10: { infra_seq: 1 } }
  vars:           # install pg_exporter for remote postgres RDS on a group 'infra'
    pg_exporters: # list all remote instances here, alloc a unique unused local port as k
      20001: { pg_cluster: pg-foo, pg_seq: 1, pg_host: 10.10.10.10 }
      20002: { pg_cluster: pg-bar, pg_seq: 1, pg_host: 10.10.10.11 , pg_port: 5432 }
      20003: { pg_cluster: pg-bar, pg_seq: 2, pg_host: 10.10.10.12 , pg_exporter_url: 'postgres://dbuser_monitor:DBUser.Monitor@10.10.10.12:5432/postgres?sslmode=disable'}
      20004: { pg_cluster: pg-bar, pg_seq: 3, pg_host: 10.10.10.13 , pg_monitor_username: dbuser_monitor, pg_monitor_password: DBUser.Monitor }

      20011:
        pg_cluster: pg-polar                        # RDS Cluster Name (Identity, Explicitly Assigned, used as 'cls')
        pg_seq: 1                                   # RDS Instance Seq (Identity, Explicitly Assigned, used as part of 'ins')
        pg_host: pxx.polardbpg.rds.aliyuncs.com     # RDS Host Address
        pg_port: 1921                               # RDS Port
        pg_exporter_include_database: 'test'        # Only monitoring database in this list
        pg_monitor_username: dbuser_monitor         # monitor username, overwrite default
        pg_monitor_password: DBUser_Monitor         # monitor password, overwrite default
        pg_databases: [{ name: test }]              # database to be added to grafana datasource

      20012:
        pg_cluster: pg-polar                        # RDS Cluster Name (Identity, Explicitly Assigned, used as 'cls')
        pg_seq: 2                                   # RDS Instance Seq (Identity, Explicitly Assigned, used as part of 'ins')
        pg_host: pe-xx.polarpgmxs.rds.aliyuncs.com  # RDS Host Address
        pg_port: 1521                               # RDS Port
        pg_databases: [{ name: test }]              # database to be added to grafana datasource

      20014:
        pg_cluster: pg-rds
        pg_seq: 1
        pg_host: pgm-xx.pg.rds.aliyuncs.com
        pg_port: 5432
        pg_exporter_auto_discovery: true
        pg_exporter_include_database: 'rds'
        pg_monitor_username: dbuser_monitor
        pg_monitor_password: DBUser_Monitor
        pg_databases: [ { name: rds } ]

      20015:
        pg_cluster: pg-rdsha
        pg_seq: 1
        pg_host: pgm-2xx8wu.pg.rds.aliyuncs.com
        pg_port: 5432
        pg_exporter_auto_discovery: true
        pg_exporter_include_database: 'rds'
        pg_databases: [{ name: test }, {name: rds}]

      20016:
        pg_cluster: pg-rdsha
        pg_seq: 2
        pg_host: pgr-xx.pg.rds.aliyuncs.com
        pg_exporter_auto_discovery: true
        pg_exporter_include_database: 'rds'
        pg_databases: [{ name: test }, {name: rds}]
```

</details>



----------------

## Monitor Setup

When you want to monitor existing instances, whether it's RDS or a self-built PostgreSQL instance, you need to make some configurations on the target database so that Pigsty can access them.

To bring an external existing PostgreSQL instance into monitoring, you need a connection string that can access that instance/cluster. Any accessible connection string (business user, superuser) can be used, but we recommend using a dedicated monitoring user to avoid permission leaks.

- [ ] [Monitor User](#monitor-user): The default username used is `dbuser_monitor`. This user belongs to the `pg_monitor` group, or ensure it has the necessary view permissions.
- [ ] [Monitor HBA](#monitor-hba): Default password is `DBUser.Monitor`. You need to ensure that the HBA policy allows the monitoring user to access the database from the infra nodes.
- [ ] [Monitor Schema](#monitor-schema): It's optional but recommended to create a dedicate schema `monitor` for monitoring views and extensions.
- [ ] [Monitor Extension](#monitor-extension)：It is strongly recommended to enable the built-in extension `pg_stat_statements`.
- [ ] [Monitor View](#monitor-view): Monitoring views are optional but can provide additional metrics. Which is recommended.


---------------------

### Monitor User

Create a monitor user on the target database cluster. For example, `dbuser_monitor` is used by default in Pigsty.

```sql
CREATE USER dbuser_monitor;                                       -- create the monitor user
COMMENT ON ROLE dbuser_monitor IS 'system monitor user';          -- comment the monitor user
GRANT pg_monitor TO dbuser_monitor;                               -- grant system role pg_monitor to monitor user

ALTER USER dbuser_monitor PASSWORD 'DBUser.Monitor';              -- set password for monitor user
ALTER USER dbuser_monitor SET log_min_duration_statement = 1000;  -- set this to avoid log flooding
ALTER USER dbuser_monitor SET search_path = monitor,public;       -- set this to avoid pg_stat_statements extension not working
```

The monitor user here should have consistent [`pg_monitor_username`](param#pg_monitor_username) and [`pg_monitor_password`](param#pg_monitor_password) with Pigsty config inventory.

---------------------

### Monitor HBA

You also need to configure `pg_hba.conf` to allow monitoring user access from infra/admin nodes.

```ini
# allow local role monitor with password
local   all  dbuser_monitor                    md5
host    all  dbuser_monitor  127.0.0.1/32      md5
host    all  dbuser_monitor  <admin_ip>/32     md5
host    all  dbuser_monitor  <infra_ip>/32     md5
```

If your RDS does not support the RAW HBA format, add admin/infra node IP to the whitelist.


---------------------

### Monitor Schema

Monitor schema is **optional**, but we strongly recommend creating one.

```sql
CREATE SCHEMA IF NOT EXISTS monitor;               -- create dedicate monitor schema
GRANT USAGE ON SCHEMA monitor TO dbuser_monitor;   -- allow monitor user to use this schema
```

---------------------

### Monitor Extension

Monitor extension is **optional**, but we strongly recommend enabling `pg_stat_statements` extension.

Note that this extension must be listed in `shared_preload_libraries` to take effect, and changing this parameter requires a database restart.

```sql
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "monitor";
```

You should create this extension inside the admin database: `postgres`. If your RDS does not grant `CREATE` on the database `postgres`. You can create that extension in the default `public` schema:

```sql
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
ALTER USER dbuser_monitor SET search_path = monitor,public;
```

As long as your monitor user can access `pg_stat_statements` view without schema qualification, it should be fine.



---------------------

### Monitor View

It's recommended to create the monitor views in all databases that need to be monitored.

<details><summary>Monitor Schema & View Definition</summary>

```sql
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

GRANT SELECT ON monitor.pg_table_bloat TO pg_monitor;

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

GRANT SELECT ON monitor.pg_index_bloat TO pg_monitor;

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
GRANT SELECT ON monitor.pg_bloat TO pg_monitor;

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
GRANT SELECT ON monitor.pg_index_bloat_human TO pg_monitor;


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
GRANT SELECT ON monitor.pg_table_bloat_human TO pg_monitor;


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
GRANT SELECT ON monitor.pg_session TO pg_monitor;


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
GRANT SELECT ON monitor.pg_seq_scan TO pg_monitor;
```

</details>


<details><summary>Shmem allocation for PostgreSQL 13+</summary>

```sql
DROP FUNCTION IF EXISTS monitor.pg_shmem() CASCADE;
CREATE OR REPLACE FUNCTION monitor.pg_shmem() RETURNS SETOF
    pg_shmem_allocations AS $$ SELECT * FROM pg_shmem_allocations;$$ LANGUAGE SQL SECURITY DEFINER;
COMMENT ON FUNCTION monitor.pg_shmem() IS 'security wrapper for system view pg_shmem';
REVOKE ALL ON FUNCTION monitor.pg_shmem() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION monitor.pg_shmem() TO pg_monitor;
```

</details>