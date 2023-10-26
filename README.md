# Pigsty

> "**P**ostgreSQL **I**n **G**reat **STY**le."
>
> —— **A battery-included, local-first, open-source PostgreSQL RDS alternative.**
>
> [Release v2.5.0](https://github.com/Vonng/pigsty/releases/tag/v2.5.0) | [Repo](https://github.com/Vonng/pigsty) | [Demo](https://demo.pigsty.cc) | [Docs](https://doc.pigsty.cc/) | [Blog](https://pigsty.cc/en/) | [Roadmap](https://github.com/users/Vonng/projects/2/views/3) | [Discuss](https://github.com/Vonng/pigsty/discussions) | [Discord](https://discord.gg/Mu2b6Wxr) ｜ [中文文档](https://doc.pigsty.cc/#/zh/)
>
> [Get Started](docs/INSTALL.md) latest [v2.5.0](https://github.com/Vonng/pigsty/releases/tag/v2.5.0) beta with `curl -fsSL https://get.pigsty.cc/beta | bash`



----------------

## Features

Free RDS for PostgreSQL. Check [**Features**](docs/FEATURE.md) | [**特性**](docs/zh/FEATURE.md) for details.

- Battery-Included PostgreSQL distribution with **150+** optional [extensions](docs/PGSQL-EXTENSION.md).
- Run on bare [OS](#compatibility) without container: [EL](files/pigsty/el.yml) 7/8/9, [Ubuntu](files/pigsty/ubuntu.yml) 20/22 and [Debian](files/pigsty/debian.yml) 11/12.
- Incredible observability powered by [Prometheus](https://prometheus.io/) & [Grafana](https://grafana.com/) stack. [Demo](https://demo.pigsty.cc) & [Gallery](https://github.com/Vonng/pigsty/wiki/Gallery).
- Self-healing [HA](docs/PGSQL-ARCH.md) PGSQL cluster, powered by [patroni](https://patroni.readthedocs.io/en/latest/), [haproxy](http://www.haproxy.org/), [etcd](https://etcd.io/). auto-tuned.
- Auto-Configured [PITR](docs/PGSQL-PITR.md), powered by [pgBackRest](https://pgbackrest.org/) and optional [MinIO](https://min.io/) repo (or S3/FS).
- Declarative [API](docs/CONFIG.md), Database-as-Code implemented with [Ansible](https://www.ansible.com/) playbooks: [SOP](docs/PGSQL-ADMIN.md).
- Handy IaC Templates, provisioning Infra with [Terraform](terraform/README.md) and try [sandbox](docs/PROVISION.md) with [Vagrant](vagrant/README.md).
- Pre-pack stable versions, create [local repos](docs/INSTALL.md#offline-packages) and install without Internet access.

[![pigsty-distro.jpg](https://github.com/Vonng/pigsty/assets/8587410/a0550ad2-7bb9-4051-8758-9e5e3b294e54)](docs/FEATURE.md)

Pigsty can be used in different scenarios:
- Run HA [PostgreSQL](docs/PGSQL.md) RDS for production usage, with PostGIS, TimescaleDB, Citus, etc...
- Run AI infra stack with [PostgresML](app/pgml/README.md) & `pgvector`.
- Develop low-code apps with self-hosted [Supabase](app/supabase/README.md), [FerretDB](docs/MONGO.md), and [NocoDB](app/nocodb/README.md).
- Run various business software & [apps](app/README.md) with docker-compose templates.
- Run demos & data apps, analyze data, and [visualize](https://demo.pigsty.cc/d/isd-overview/) them with ECharts panels.
- Run dedicated [Redis](docs/REDIS.md), [MinIO](docs/MINIO.md), [ETCD](docs/ETCD.md), and HAProxy clusters with HA & observability, too.
- Run as a pure [monitoring](docs/PGSQL-MONITOR.md#monitor-mode) system for existing PostgreSQL clusters and cloud [RDS](docs/PGSQL-MONITOR.md#monitor-rds).

[![pigsty-dashboard.jpg](https://github.com/Vonng/pigsty/assets/8587410/cd4e6620-bc36-44dc-946b-b9ae56f93c90)](https://demo.pigsty.cc)


<details><summary>Ecosystem & Available Extensions</summary></br>

Pigsty has over **150+** **OPTIONAL** [extensions](docs/PGSQL-EXTENSION.md) pre-compiled and packaged, including some not included in the official PGDG repo. Some of the most potent extensions are:

- [Supabase](app/supabase/README.md): Open-Source Firebase alternative based on PostgreSQL
- [FerretDB](app/ferretdb/README.md): Open-Source MongoDB alternative based on PostgreSQL
- [PostgresML](app/pgml/README.md): Use machine learning algorithms and pretrained models with SQL
- [PostGIS](https://postgis.net/): Add geospatial data support to PostgreSQL
- [TimescaleDB](https://www.timescale.com/): Add time-series/continuous-aggregation support to PostgreSQL
- [PGVector](https://github.com/pgvector/pgvector) / PG Embedding: AI vector/embedding data type support, and ivfflat / hnsw index access method
- [Citus](https://www.citusdata.com/): Turn a standalone primary-replica postgres cluster into a horizontally scalable distributed cluster
- [Apache AGE](https://age.apache.org/): Add OpenCypher graph query language support to PostgreSQL, works like Neo4J
- ...

[![pigsty-extension.jpg](https://github.com/Vonng/pigsty/assets/8587410/91dfee81-3193-4505-b33f-0c5949dabf02)](docs/PGSQL-EXTENSION.md)

Some non-trivial extensions:

| name                         | version |   source   | type  | comment                                                                                                                    |
|------------------------------|:-------:|:----------:|:-----:|----------------------------------------------------------------------------------------------------------------------------|
| **age**                      |  1.4.0  | **PIGSTY** | FEAT  | Apache AGE graph database extension                                                                                        |
| **pointcloud**               |  1.2.5  | **PIGSTY** | FEAT  | A PostgreSQL extension for storing point cloud (LIDAR) data.                                                               |
| **http**                     |   1.6   | **PIGSTY** | FEAT  | HTTP client for PostgreSQL, allows web page retrieval inside the database.                                                 |
| pg_tle                       |  1.2.0  | **PIGSTY** | FEAT  | Trusted Language Extensions for PostgreSQL                                                                                 |
| roaringbitmap                |   0.5   | **PIGSTY** | FEAT  | Support for Roaring Bitmaps                                                                                                |
| **zhparser**                 |   2.2   | **PIGSTY** | FEAT  | Parser for full-text search of Chinese                                                                                     |
| **pgml**                     |  2.7.9  | **PIGSTY** | FEAT  | PostgresML: Use the expressive power of SQL along with the most advanced machine learning algorithms and pretrained models |
| pg_net                       |  0.7.3  | **PIGSTY** | FEAT  | A PostgreSQL extension that enables asynchronous (non-blocking) HTTP/HTTPS requests with SQL                               |
| vault                        |  0.2.9  | **PIGSTY** | FEAT  | Extension for storing encrypted secrets in the Vault                                                                       |
| **pg_graphql**               |  1.4.0  | **PIGSTY** | FEAT  | GraphQL support for PostgreSQL                                                                                             |
| **hydra**                    |  1.0.0  | **PIGSTY** | FEAT  | Hydra is open source, column-oriented Postgres extension                                                                   |
| credcheck                    |  2.1.0  |    PGDG    | ADMIN | credcheck - postgresql plain text credential checker                                                                       |
| **pg_cron**                  |   1.5   |    PGDG    | ADMIN | Job scheduler for PostgreSQL                                                                                               |
| pg_background                |   1.0   |    PGDG    | ADMIN | Run SQL queries in the background                                                                                          |
| pg_jobmon                    |  1.4.1  |    PGDG    | ADMIN | Extension for logging and monitoring functions in PostgreSQL                                                               |
| pg_readonly                  |  1.0.0  |    PGDG    | ADMIN | cluster database read only                                                                                                 |
| **pg_repack**                |  1.4.8  |    PGDG    | ADMIN | Reorganize tables in PostgreSQL databases with minimal locks                                                               |
| pg_squeeze                   |   1.5   |    PGDG    | ADMIN | A tool to remove unused space from a relation.                                                                             |
| pgfincore                    |   1.2   |    PGDG    | ADMIN | examine and manage the os buffer cache                                                                                     |
| **pglogical**                |  2.4.3  |    PGDG    | ADMIN | PostgreSQL Logical Replication                                                                                             |
| pglogical_origin             |  1.0.0  |    PGDG    | ADMIN | Dummy extension for compatibility when upgrading from Postgres 9.4                                                         |
| prioritize                   |   1.0   |    PGDG    | ADMIN | get and set the priority of PostgreSQL backends                                                                            |
| set_user                     |  4.0.1  |    PGDG    | AUDIT | similar to SET ROLE but with added logging                                                                                 |
| **passwordcracklib**         |  3.0.0  |    PGDG    | AUDIT | Enforce password policy                                                                                                    |
| pgaudit                      |   1.7   |    PGDG    | AUDIT | provides auditing functionality                                                                                            |
| pgcryptokey                  |   1.0   |    PGDG    | AUDIT | cryptographic key management                                                                                               |
| hdfs_fdw                     |  2.0.5  |    PGDG    |  FDW  | foreign-data wrapper for remote hdfs servers                                                                               |
| mongo_fdw                    |   1.1   |    PGDG    |  FDW  | foreign data wrapper for MongoDB access                                                                                    |
| multicorn                    |   2.4   |    PGDG    |  FDW  | Multicorn2 Python3.6+ bindings for Postgres 11++ Foreign Data Wrapper                                                      |
| mysql_fdw                    |   1.2   |    PGDG    |  FDW  | Foreign data wrapper for querying a MySQL server                                                                           |
| pgbouncer_fdw                |   0.4   |    PGDG    |  FDW  | Extension for querying pgbouncer stats from normal SQL views & running pgbouncer commands from normal SQL functions        |
| sqlite_fdw                   |   1.1   |    PGDG    |  FDW  | SQLite Foreign Data Wrapper                                                                                                |
| tds_fdw                      |  2.0.3  |    PGDG    |  FDW  | Foreign data wrapper for querying a TDS database (Sybase or Microsoft SQL Server)                                          |
| emaj                         |  4.2.0  |    PGDG    | FEAT  | E-Maj extension enables fine-grained write logging and time travel on subsets of the database.                             |
| periods                      |   1.2   |    PGDG    | FEAT  | Provide Standard SQL functionality for PERIODs and SYSTEM VERSIONING                                                       |
| pg_ivm                       |   1.5   |    PGDG    | FEAT  | incremental view maintenance on PostgreSQL                                                                                 |
| pgq                          |   3.5   |    PGDG    | FEAT  | Generic queue for PostgreSQL                                                                                               |
| pgsodium                     |  3.1.8  |    PGDG    | FEAT  | Postgres extension for libsodium functions                                                                                 |
| **timescaledb**              | 2.11.2  |    PGDG    | FEAT  | Enables scalable inserts and complex queries for time-series data (Apache 2 Edition)                                       |
| **wal2json**                 |  2.5.1  |    PGDG    | FEAT  | Capture JSON format CDC change via logical decoding                                                                        |
| **vector**                   |  0.5.0  |    PGDG    | FEAT  | vector data type and ivfflat / hnsw access method                                                                          |
| count_distinct               |  3.0.1  |    PGDG    | FUNC  | An alternative to COUNT(DISTINCT ...) aggregate, usable with HashAggregate                                                 |
| ddlx                         |  0.23   |    PGDG    | FUNC  | DDL eXtractor functions                                                                                                    |
| extra_window_functions       |   1.0   |    PGDG    | FUNC  | Additional window functions to PostgreSQL                                                                                  |
| mysqlcompat                  |  0.0.7  |    PGDG    | FUNC  | MySQL compatibility functions                                                                                              |
| orafce                       |   4.5   |    PGDG    | FUNC  | Functions and operators that emulate a subset of functions and packages from the Oracle RDBMS                              |
| pgsql_tweaks                 | 0.10.0  |    PGDG    | FUNC  | Some functions and views for daily usage                                                                                   |
| tdigest                      |  1.4.0  |    PGDG    | FUNC  | Provides tdigest aggregate function.                                                                                       |
| topn                         |  2.4.0  |    PGDG    | FUNC  | type for top-n JSONB                                                                                                       |
| unaccent                     |   1.1   |    PGDG    | FUNC  | text search dictionary that removes accents                                                                                |
| address_standardizer         |  3.3.3  |    PGDG    |  GIS  | Used to parse an address into constituent elements. Generally used to support geocoding address normalization step.        |
| address_standardizer_data_us |  3.3.3  |    PGDG    |  GIS  | Address Standardizer US dataset example                                                                                    |
| **postgis**                  |  3.3.3  |    PGDG    |  GIS  | PostGIS geometry and geography spatial types and functions                                                                 |
| postgis_raster               |  3.3.3  |    PGDG    |  GIS  | PostGIS raster types and functions                                                                                         |
| postgis_sfcgal               |  3.3.3  |    PGDG    |  GIS  | PostGIS SFCGAL functions                                                                                                   |
| postgis_tiger_geocoder       |  3.3.3  |    PGDG    |  GIS  | PostGIS tiger geocoder and reverse geocoder                                                                                |
| postgis_topology             |  3.3.3  |    PGDG    |  GIS  | PostGIS topology spatial types and functions                                                                               |
| amcheck                      |   1.3   |    PGDG    | INDEX | functions for verifying relation integrity                                                                                 |
| bloom                        |   1.0   |    PGDG    | INDEX | bloom access method - signature file based index                                                                           |
| hll                          |  2.16   |    PGDG    | INDEX | type for storing hyperloglog data                                                                                          |
| pgtt                         | 2.10.0  |    PGDG    | INDEX | Extension to add Global Temporary Tables feature to PostgreSQL                                                             |
| rum                          |   1.3   |    PGDG    | INDEX | RUM index access method                                                                                                    |
| hstore_plperl                |   1.0   |    PGDG    | LANG  | transform between hstore and plperl                                                                                        |
| hstore_plperlu               |   1.0   |    PGDG    | LANG  | transform between hstore and plperlu                                                                                       |
| plpgsql_check                |   2.3   |    PGDG    | LANG  | extended check for plpgsql functions                                                                                       |
| plsh                         |    2    |    PGDG    | LANG  | PL/sh procedural language                                                                                                  |
| **citus**                    | 12.0-1  |    PGDG    | SHARD | Citus distributed database                                                                                                 |
| citus_columnar               | 11.3-1  |    PGDG    | SHARD | Citus Columnar extension                                                                                                   |
| pg_fkpart                    |   1.7   |    PGDG    | SHARD | Table partitioning by foreign key utility                                                                                  |
| pg_partman                   |  4.7.3  |    PGDG    | SHARD | Extension to manage partitioned tables by time or ID                                                                       |
| plproxy                      | 2.10.0  |    PGDG    | SHARD | Database partitioning implemented as procedural language                                                                   |
| hypopg                       |  1.4.0  |    PGDG    | STAT  | Hypothetical indexes for PostgreSQL                                                                                        |
| logerrors                    |   2.1   |    PGDG    | STAT  | Function for collecting statistics about messages in logfile                                                               |
| pg_auth_mon                  |   1.1   |    PGDG    | STAT  | monitor connection attempts per user                                                                                       |
| pg_permissions               |   1.1   |    PGDG    | STAT  | view object permissions and compare them with the desired state                                                            |
| pg_qualstats                 |  2.0.4  |    PGDG    | STAT  | An extension collecting statistics about quals                                                                             |
| pg_stat_kcache               |  2.2.2  |    PGDG    | STAT  | Kernel statistics gathering                                                                                                |
| pg_stat_monitor              |   2.0   |    PGDG    | STAT  | aggregated statistics, client information, plan details including plan, and histogram information.                         |
| pg_store_plans               |   1.7   |    PGDG    | STAT  | track plan statistics of all SQL statements executed                                                                       |
| pg_track_settings            |  2.1.2  |    PGDG    | STAT  | Track settings changes                                                                                                     |
| pg_wait_sampling             |   1.1   |    PGDG    | STAT  | sampling based statistics of wait events                                                                                   |
| pldbgapi                     |   1.1   |    PGDG    | STAT  | server-side support for debugging PL/pgSQL functions                                                                       |
| plprofiler                   |   4.2   |    PGDG    | STAT  | server-side support for profiling PL/pgSQL functions                                                                       |
| powa                         |  4.1.4  |    PGDG    | STAT  | PostgreSQL Workload Analyser-core                                                                                          |
| system_stats                 |   1.0   |    PGDG    | STAT  | System statistic functions for PostgreSQL                                                                                  |
| citext                       |   1.6   |    PGDG    | TYPE  | data type for case-insensitive character strings                                                                           |
| geoip                        |  0.2.4  |    PGDG    | TYPE  | An IP geolocation extension (a wrapper around the MaxMind GeoLite dataset)                                                 |
| ip4r                         |   2.4   |    PGDG    | TYPE  | IPv4/v6 and IPv4/v6 range index type for PostgreSQL                                                                        |
| pg_uuidv7                    |   1.1   |    PGDG    | TYPE  | pg_uuidv7: create UUIDv7 values in postgres                                                                                |
| pgmp                         |   1.1   |    PGDG    | TYPE  | Multiple Precision Arithmetic extension                                                                                    |
| semver                       | 0.32.1  |    PGDG    | TYPE  | Semantic version data type                                                                                                 |
| timestamp9                   |  1.3.0  |    PGDG    | TYPE  | timestamp nanosecond resolution                                                                                            |
| unit                         |    7    |    PGDG    | TYPE  | SI units extension                                                                                                         |


</details>



----------------

## Get Started

Bootstrap with one command! Check [**Get Started**](docs/INSTALL.md) | [**快速上手**](docs/zh/INSTALL.md) for details.

```bash
# Linux x86_64 node with nopass sudo/ssh
bash -c "$(curl -fsSL https://get.pigsty.cc/latest)";
cd ~/pigsty; ./bootstrap; ./configure; ./install.yml;
```

Then you will have a pigsty singleton node ready, with Web Services on port `80` and Postgres on port `5432`.

<details><summary>Download with Get</summary>

```bash
$ curl https://get.pigsty.cc/latest | bash
...
[Checking] ===========================================
[ OK ] SOURCE from CDN due to GFW
FROM CDN    : bash -c "$(curl -fsSL https://get.pigsty.cc/latest)"
FROM GITHUB : bash -c "$(curl -fsSL https://raw.githubusercontent.com/Vonng/pigsty/master/bin/latest)"
[Downloading] ===========================================
[ OK ] download pigsty source code from CDN
[ OK ] $ curl -SL https://get.pigsty.cc/v2.5.0/pigsty-v2.5.0.tgz
...
MD5: d5dc4a51efc81932a03d7c010d0d5d64  /tmp/pigsty-v2.5.0.tgz
[Extracting] ===========================================
[ OK ] extract '/tmp/pigsty-v2.5.0.tgz' to '/home/vagrant/pigsty'
[ OK ] $ tar -xf /tmp/pigsty-v2.5.0.tgz -C ~;
[Reference] ===========================================
Official Site:   https://pigsty.cc
Get Started:     https://doc.pigsty.cc/#/INSTALL
Documentation:   https://doc.pigsty.cc
Github Repo:     https://github.com/Vonng/pigsty
Public Demo:     https://demo.pigsty.cc
[Proceeding] ===========================================
cd ~/pigsty      # entering pigsty home directory before proceeding
./bootstrap      # install ansible & download the optional offline packages
./configure      # preflight-check and generate config according to your env
./install.yml    # install pigsty on this node and init it as the admin node
[ OK ] ~/pigsty is ready to go now!
```

</details>


<details><summary>Download with Git</summary>

You can also download pigsty source with `git`, don't forget to checkout a specific version.

```bash
git clone https://github.com/Vonng/pigsty;
cd pigsty; git checkout v2.5.0
```

</details>


<details><summary>Download Directly</summary>

You can also download pigsty source & offline pkgs directly from GitHub release page.

```bash
# get from GitHub
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Vonng/pigsty/master/bin/latest)"

# or download tarball directly with curl
curl -L https://github.com/Vonng/pigsty/releases/download/v2.5.0/pigsty-v2.5.0.tgz -o ~/pigsty.tgz                 # SRC
curl -L https://github.com/Vonng/pigsty/releases/download/v2.5.0/pigsty-pkg-v2.5.0.el9.x86_64.tgz -o /tmp/pkg.tgz  # EL9
curl -L https://github.com/Vonng/pigsty/releases/download/v2.5.0/pigsty-pkg-v2.5.0.el8.x86_64.tgz -o /tmp/pkg.tgz  # EL8
curl -L https://github.com/Vonng/pigsty/releases/download/v2.5.0/pigsty-pkg-v2.5.0.el7.x86_64.tgz -o /tmp/pkg.tgz  # EL7
```

</details>

[![asciicast](https://asciinema.org/a/603609.svg)](https://asciinema.org/a/603609)



----------------

## Architecture

Pigsty uses a **modular** design. There are six default modules available:

* [`INFRA`](docs/INFRA.md): Local yum repo, Nginx, DNS, and entire Prometheus & Grafana observability stack.
* [`NODE`](docs/NODE.md):   Init node name, repo, pkg, NTP, ssh, admin, tune, expose services, collect logs & metrics.
* [`ETCD`](docs/ETCD.md):   Init etcd cluster for HA Postgres DCS or Kubernetes, used as distributed config store.
* [`PGSQL`](docs/PGSQL.md): Autonomous self-healing PostgreSQL cluster powered by Patroni, Pgbouncer, PgBackrest & HAProxy
* [`REDIS`](docs/REDIS.md): Deploy Redis servers in standalone master-replica, sentinel, and native cluster mode, optional.
* [`MINIO`](docs/MINIO.md): S3-compatible object storage service used as an optional central backup server for `PGSQL`.

You can compose them freely in a declarative manner. If you want host monitoring, `INFRA` & `NODE` will suffice.
`ETCD` and `PGSQL` are used for HA PG clusters, install them on multiple nodes will automatically form a HA cluster.
You can also reuse pigsty infra and develop your own modules, `KAFKA`, `MYSQL`, `GPSQL`, and more will come.

The default [`install.yml`](install.yml) playbook in [Get Started](#get-started) will install `INFRA`, `NODE`, `ETCD` & `PGSQL` on the current node. 
which gives you a battery-included PostgreSQL singleton instance (`admin_ip:5432`) with everything ready.
This node can be used as an admin center & infra provider to manage, deploy & monitor more nodes & clusters.

[![pigsty-arch.jpg](https://github.com/Vonng/pigsty/assets/8587410/7b226641-e61b-4e79-bc31-759204778bd5)](docs/ARCH.md)



----------------

## More Clusters

To deploy a 3-node HA Postgres Cluster with streaming replication, [define](https://github.com/Vonng/pigsty/blob/master/pigsty.yml#L54) a new cluster on `all.children.pg-test` of [`pigsty.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml):

```yaml 
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
    10.10.10.13: { pg_seq: 3, pg_role: offline }
  vars:  { pg_cluster: pg-test }
```

Then create it with built-in playbooks:

```bash
bin/pgsql-add pg-test   # init pg-test cluster 
```

![pgsql-ha.jpg](https://github.com/Vonng/pigsty/assets/8587410/645501d1-384e-4009-b41b-8488654f17d3)

You can deploy different kinds of instance roles such as primary, replica, offline, delayed, sync standby, and different kinds of clusters, such as standby clusters, Citus clusters, and even Redis/MinIO/Etcd clusters.

<details><summary>Example: Complex Postgres Customize</summary>

```yaml
pg-meta:
  hosts: { 10.10.10.10: { pg_seq: 1, pg_role: primary , pg_offline_query: true } }
  vars:
    pg_cluster: pg-meta
    pg_databases:                       # define business databases on this cluster, array of database definition
      - name: meta                      # REQUIRED, `name` is the only mandatory field of a database definition
        baseline: cmdb.sql              # optional, database sql baseline path, (relative path among ansible search path, e.g files/)
        pgbouncer: true                 # optional, add this database to pgbouncer database list? true by default
        schemas: [pigsty]               # optional, additional schemas to be created, array of schema names
        extensions:                     # optional, additional extensions to be installed: array of `{name[,schema]}`
          - { name: postgis , schema: public }
          - { name: timescaledb }
        comment: pigsty meta database   # optional, comment string for this database
        owner: postgres                # optional, database owner, postgres by default
        template: template1            # optional, which template to use, template1 by default
        encoding: UTF8                 # optional, database encoding, UTF8 by default. (MUST same as template database)
        locale: C                      # optional, database locale, C by default.  (MUST same as template database)
        lc_collate: C                  # optional, database collate, C by default. (MUST same as template database)
        lc_ctype: C                    # optional, database ctype, C by default.   (MUST same as template database)
        tablespace: pg_default         # optional, default tablespace, 'pg_default' by default.
        allowconn: true                # optional, allow connection, true by default. false will disable connect at all
        revokeconn: false              # optional, revoke public connection privilege. false by default. (leave connect with grant option to owner)
        register_datasource: true      # optional, register this database to grafana datasources? true by default
        connlimit: -1                  # optional, database connection limit, default -1 disable limit
        pool_auth_user: dbuser_meta    # optional, all connection to this pgbouncer database will be authenticated by this user
        pool_mode: transaction         # optional, pgbouncer pool mode at database level, default transaction
        pool_size: 64                  # optional, pgbouncer pool size at database level, default 64
        pool_size_reserve: 32          # optional, pgbouncer pool size reserve at database level, default 32
        pool_size_min: 0               # optional, pgbouncer pool size min at database level, default 0
        pool_max_db_conn: 100          # optional, max database connections at database level, default 100
      - { name: grafana  ,owner: dbuser_grafana  ,revokeconn: true ,comment: grafana primary database }
      - { name: bytebase ,owner: dbuser_bytebase ,revokeconn: true ,comment: bytebase primary database }
      - { name: kong     ,owner: dbuser_kong     ,revokeconn: true ,comment: kong the api gateway database }
      - { name: gitea    ,owner: dbuser_gitea    ,revokeconn: true ,comment: gitea meta database }
      - { name: wiki     ,owner: dbuser_wiki     ,revokeconn: true ,comment: wiki meta database }
    pg_users:                           # define business users/roles on this cluster, array of user definition
      - name: dbuser_meta               # REQUIRED, `name` is the only mandatory field of a user definition
        password: DBUser.Meta           # optional, password, can be a scram-sha-256 hash string or plain text
        login: true                     # optional, can log in, true by default  (new biz ROLE should be false)
        superuser: false                # optional, is superuser? false by default
        createdb: false                 # optional, can create database? false by default
        createrole: false               # optional, can create role? false by default
        inherit: true                   # optional, can this role use inherited privileges? true by default
        replication: false              # optional, can this role do replication? false by default
        bypassrls: false                # optional, can this role bypass row level security? false by default
        pgbouncer: true                 # optional, add this user to pgbouncer user-list? false by default (production user should be true explicitly)
        connlimit: -1                   # optional, user connection limit, default -1 disable limit
        expire_in: 3650                 # optional, now + n days when this role is expired (OVERWRITE expire_at)
        expire_at: '2030-12-31'         # optional, YYYY-MM-DD 'timestamp' when this role is expired  (OVERWRITTEN by expire_in)
        comment: pigsty admin user      # optional, comment string for this user/role
        roles: [dbrole_admin]           # optional, belonged roles. default roles are: dbrole_{admin,readonly,readwrite,offline}
        parameters: {}                  # optional, role level parameters with `ALTER ROLE SET`
        pool_mode: transaction          # optional, pgbouncer pool mode at user level, transaction by default
        pool_connlimit: -1              # optional, max database connections at user level, default -1 disable limit
      - {name: dbuser_view     ,password: DBUser.Viewer   ,pgbouncer: true ,roles: [dbrole_readonly], comment: read-only viewer for meta database}
      - {name: dbuser_grafana  ,password: DBUser.Grafana  ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for grafana database   }
      - {name: dbuser_bytebase ,password: DBUser.Bytebase ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for bytebase database  }
      - {name: dbuser_kong     ,password: DBUser.Kong     ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for kong api gateway   }
      - {name: dbuser_gitea    ,password: DBUser.Gitea    ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for gitea service      }
      - {name: dbuser_wiki     ,password: DBUser.Wiki     ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for wiki.js service    }
    pg_services:                        # extra services in addition to pg_default_services, array of service definition
      # standby service will route {ip|name}:5435 to sync replica's pgbouncer (5435->6432 standby)
      - name: standby                   # required, service name, the actual svc name will be prefixed with `pg_cluster`, e.g: pg-meta-standby
        port: 5435                      # required, service exposed port (work as kubernetes service node port mode)
        ip: "*"                         # optional, service bind ip address, `*` for all ip by default
        selector: "[]"                  # required, service member selector, use JMESPath to filter inventory
        dest: default                   # optional, destination port, default|postgres|pgbouncer|<port_number>, 'default' by default
        check: /sync                    # optional, health check url path, / by default
        backup: "[? pg_role == `primary`]"  # backup server selector
        maxconn: 3000                   # optional, max allowed front-end connection
        balance: roundrobin             # optional, haproxy load balance algorithm (roundrobin by default, other: leastconn)
        options: 'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'
    pg_hba_rules:
      - {user: dbuser_view , db: all ,addr: infra ,auth: pwd ,title: 'allow grafana dashboard access cmdb from infra nodes'}
    pg_vip_enabled: true
    pg_vip_address: 10.10.10.2/24
    pg_vip_interface: eth1
    node_crontab:  # make a full backup 1 am everyday
      - '00 01 * * * postgres /pg/bin/pg-backup full'

```

</details>

<details><summary>Example: Security Enhanced PG Cluster with Delayed Replica</summary>

```yaml
pg-meta:      # 3 instance postgres cluster `pg-meta`
  hosts:
    10.10.10.10: { pg_seq: 1, pg_role: primary }
    10.10.10.11: { pg_seq: 2, pg_role: replica }
    10.10.10.12: { pg_seq: 3, pg_role: replica , pg_offline_query: true }
  vars:
    pg_cluster: pg-meta
    pg_conf: crit.yml
    pg_users:
      - { name: dbuser_meta , password: DBUser.Meta   , pgbouncer: true , roles: [ dbrole_admin ] , comment: pigsty admin user }
      - { name: dbuser_view , password: DBUser.Viewer , pgbouncer: true , roles: [ dbrole_readonly ] , comment: read-only viewer for meta database }
    pg_databases:
      - {name: meta ,baseline: cmdb.sql ,comment: pigsty meta database ,schemas: [pigsty] ,extensions: [{name: postgis, schema: public}, {name: timescaledb}]}
    pg_default_service_dest: postgres
    pg_services:
      - { name: standby ,src_ip: "*" ,port: 5435 , dest: default ,selector: "[]" , backup: "[? pg_role == `primary`]" }
    pg_vip_enabled: true
    pg_vip_address: 10.10.10.2/24
    pg_vip_interface: eth1
    pg_listen: '${ip},${vip},${lo}'
    patroni_ssl_enabled: true
    pgbouncer_sslmode: require
    pgbackrest_method: minio
    pg_libs: 'timescaledb, $libdir/passwordcheck, pg_stat_statements, auto_explain' # add passwordcheck extension to enforce strong password
    pg_default_roles:                 # default roles and users in postgres cluster
      - { name: dbrole_readonly  ,login: false ,comment: role for global read-only access     }
      - { name: dbrole_offline   ,login: false ,comment: role for restricted read-only access }
      - { name: dbrole_readwrite ,login: false ,roles: [dbrole_readonly]               ,comment: role for global read-write access }
      - { name: dbrole_admin     ,login: false ,roles: [pg_monitor, dbrole_readwrite]  ,comment: role for object creation }
      - { name: postgres     ,superuser: true  ,expire_in: 7300                        ,comment: system superuser }
      - { name: replicator ,replication: true  ,expire_in: 7300 ,roles: [pg_monitor, dbrole_readonly]   ,comment: system replicator }
      - { name: dbuser_dba   ,superuser: true  ,expire_in: 7300 ,roles: [dbrole_admin]  ,pgbouncer: true ,pool_mode: session, pool_connlimit: 16 , comment: pgsql admin user }
      - { name: dbuser_monitor ,roles: [pg_monitor] ,expire_in: 7300 ,pgbouncer: true ,parameters: {log_min_duration_statement: 1000 } ,pool_mode: session ,pool_connlimit: 8 ,comment: pgsql monitor user }
    pg_default_hba_rules:             # postgres host-based auth rules by default
      - {user: '${dbsu}'    ,db: all         ,addr: local     ,auth: ident ,title: 'dbsu access via local os user ident'  }
      - {user: '${dbsu}'    ,db: replication ,addr: local     ,auth: ident ,title: 'dbsu replication from local os ident' }
      - {user: '${repl}'    ,db: replication ,addr: localhost ,auth: ssl   ,title: 'replicator replication from localhost'}
      - {user: '${repl}'    ,db: replication ,addr: intra     ,auth: ssl   ,title: 'replicator replication from intranet' }
      - {user: '${repl}'    ,db: postgres    ,addr: intra     ,auth: ssl   ,title: 'replicator postgres db from intranet' }
      - {user: '${monitor}' ,db: all         ,addr: localhost ,auth: pwd   ,title: 'monitor from localhost with password' }
      - {user: '${monitor}' ,db: all         ,addr: infra     ,auth: ssl   ,title: 'monitor from infra host with password'}
      - {user: '${admin}'   ,db: all         ,addr: infra     ,auth: ssl   ,title: 'admin @ infra nodes with pwd & ssl'   }
      - {user: '${admin}'   ,db: all         ,addr: world     ,auth: cert  ,title: 'admin @ everywhere with ssl & cert'   }
      - {user: '+dbrole_readonly',db: all    ,addr: localhost ,auth: ssl   ,title: 'pgbouncer read/write via local socket'}
      - {user: '+dbrole_readonly',db: all    ,addr: intra     ,auth: ssl   ,title: 'read/write biz user via password'     }
      - {user: '+dbrole_offline' ,db: all    ,addr: intra     ,auth: ssl   ,title: 'allow etl offline tasks from intranet'}
    pgb_default_hba_rules:            # pgbouncer host-based authentication rules
      - {user: '${dbsu}'    ,db: pgbouncer   ,addr: local     ,auth: peer  ,title: 'dbsu local admin access with os ident'}
      - {user: 'all'        ,db: all         ,addr: localhost ,auth: pwd   ,title: 'allow all user local access with pwd' }
      - {user: '${monitor}' ,db: pgbouncer   ,addr: intra     ,auth: ssl   ,title: 'monitor access via intranet with pwd' }
      - {user: '${monitor}' ,db: all         ,addr: world     ,auth: deny  ,title: 'reject all other monitor access addr' }
      - {user: '${admin}'   ,db: all         ,addr: intra     ,auth: ssl   ,title: 'admin access via intranet with pwd'   }
      - {user: '${admin}'   ,db: all         ,addr: world     ,auth: deny  ,title: 'reject all other admin access addr'   }
      - {user: 'all'        ,db: all         ,addr: intra     ,auth: ssl   ,title: 'allow all user intra access with pwd' }

# OPTIONAL delayed cluster for pg-meta
pg-meta-delay:                    # delayed instance for pg-meta (1 hour ago)
  hosts: { 10.10.10.13: { pg_seq: 1, pg_role: primary, pg_upstream: 10.10.10.10, pg_delay: 1h } }
  vars: { pg_cluster: pg-meta-delay }
```

</details>

<details><summary>Example: Citus Distributed Cluster: 5 Nodes</summary>

```yaml
all:
  children:
    pg-citus0: # citus coordinator, pg_group = 0
      hosts: { 10.10.10.10: { pg_seq: 1, pg_role: primary } }
      vars: { pg_cluster: pg-citus0 , pg_group: 0 }
    pg-citus1: # citus data node 1
      hosts: { 10.10.10.11: { pg_seq: 1, pg_role: primary } }
      vars: { pg_cluster: pg-citus1 , pg_group: 1 }
    pg-citus2: # citus data node 2
      hosts: { 10.10.10.12: { pg_seq: 1, pg_role: primary } }
      vars: { pg_cluster: pg-citus2 , pg_group: 2 }
    pg-citus3: # citus data node 3, with an extra replica
      hosts:
        10.10.10.13: { pg_seq: 1, pg_role: primary }
        10.10.10.14: { pg_seq: 2, pg_role: replica }
      vars: { pg_cluster: pg-citus3 , pg_group: 3 }
  vars:                               # global parameters for all citus clusters
    pg_mode: citus                    # pgsql cluster mode: citus
    pg_shard: pg-citus                # citus shard name: pg-citus
    patroni_citus_db: meta            # citus distributed database name
    pg_dbsu_password: DBUser.Postgres # all dbsu password access for citus cluster
  pg_libs: 'citus, timescaledb, pg_stat_statements, auto_explain' # citus will be added by patroni automatically
    pg_extensions: 
      - pg_repack_${ pg_version }* wal2json_${ pg_version }* passwordcheck_cracklib_${ pg_version }* 
      - postgis3*_${ pg_version }* timescaledb-2-postgresql-${ pg_version }* pgvector_${ pg_version }* citus_${ pg_version }*
    pg_users: [ { name: dbuser_meta ,password: DBUser.Meta ,pgbouncer: true ,roles: [ dbrole_admin ] } ]
    pg_databases: [ { name: meta ,extensions: [ { name: citus }, { name: postgis }, { name: timescaledb } ] } ]
    pg_hba_rules:
      - { user: 'all' ,db: all  ,addr: 127.0.0.1/32 ,auth: ssl ,title: 'all user ssl access from localhost' }
      - { user: 'all' ,db: all  ,addr: intra        ,auth: ssl ,title: 'all user ssl access from intranet'  }
```

</details>

<details><summary>Example: Redis Cluster/Sentinel/Standalone</summary>

```yaml
redis-ms: # redis classic primary & replica
  hosts: { 10.10.10.10: { redis_node: 1 , redis_instances: { 6379: { }, 6380: { replica_of: '10.10.10.10 6379' } } } }
  vars: { redis_cluster: redis-ms ,redis_password: 'redis.ms' ,redis_max_memory: 64MB }

redis-meta: # redis sentinel x 3
  hosts: { 10.10.10.11: { redis_node: 1 , redis_instances: { 26379: { } ,26380: { } ,26381: { } } } }
  vars:
    redis_cluster: redis-meta
    redis_password: 'redis.meta'
    redis_mode: sentinel
    redis_max_memory: 16MB
    redis_sentinel_monitor: # primary list for redis sentinel, use cls as name, primary ip:port
      - { name: redis-ms, host: 10.10.10.10, port: 6379 ,password: redis.ms, quorum: 2 }

redis-test: # redis native cluster: 3m x 3s
  hosts:
    10.10.10.12: { redis_node: 1 ,redis_instances: { 6379: { } ,6380: { } ,6381: { } } }
    10.10.10.13: { redis_node: 2 ,redis_instances: { 6379: { } ,6380: { } ,6381: { } } }
  vars: { redis_cluster: redis-test ,redis_password: 'redis.test' ,redis_mode: cluster, redis_max_memory: 32MB }
```

</details>

<details><summary>Example: ETCD 3 Node Cluster</summary>

```yaml
etcd: # dcs service for postgres/patroni ha consensus
  hosts:  # 1 node for testing, 3 or 5 for production
    10.10.10.10: { etcd_seq: 1 }  # etcd_seq required
    10.10.10.11: { etcd_seq: 2 }  # assign from 1 ~ n
    10.10.10.12: { etcd_seq: 3 }  # odd number please
  vars: # cluster level parameter override roles/etcd
    etcd_cluster: etcd  # mark etcd cluster name etcd
    etcd_safeguard: false # safeguard against purging
    etcd_clean: true # purge etcd during init process
```

</details>

<details><summary>Example: Minio 3 Node Deployment</summary>

```yaml
minio:
  hosts:
    10.10.10.10: { minio_seq: 1 }
    10.10.10.11: { minio_seq: 2 }
    10.10.10.12: { minio_seq: 3 }
  vars:
    minio_cluster: minio
    minio_data: '/data{1...2}'        # use two disk per node
    minio_node: '${minio_cluster}-${minio_seq}.pigsty' # minio node name pattern
    haproxy_services:
      - name: minio                     # [REQUIRED] service name, unique
        port: 9002                      # [REQUIRED] service port, unique
        options:
          - option httpchk
          - option http-keep-alive
          - http-check send meth OPTIONS uri /minio/health/live
          - http-check expect status 200
        servers:
          - { name: minio-1 ,ip: 10.10.10.10 , port: 9000 , options: 'check-ssl ca-file /etc/pki/ca.crt check port 9000' }
          - { name: minio-2 ,ip: 10.10.10.11 , port: 9000 , options: 'check-ssl ca-file /etc/pki/ca.crt check port 9000' }
          - { name: minio-3 ,ip: 10.10.10.12 , port: 9000 , options: 'check-ssl ca-file /etc/pki/ca.crt check port 9000' }
```

</details>

Check [**Configuration**](docs/CONFIG.md) for details.



----------------

## Compatibility

We recommend using RockyLinux 8.8, Ubuntu 22.04 (jammy), Debian 12 (bookworm) as the base OS for Pigsty.

While any EL 7,8,9 / Ubuntu 20.04,22.04 / Debian 11/12 compatible OS Distribution should work.

| Code | OS Distro / PG Ver                | PG16 | PG15 | PG14 | PG13 | PG12 | Limitation                                           |
|:----:|-----------------------------------|:----:|:----:|:----:|:----:|:----:|------------------------------------------------------|
| EL7  | RHEL7 / CentOS7                   |  ⚠️  |  ⭐️  |  ✅   |  ✅   |  ✅   | PG16, supabase, pgml, pg_graphql, pg_net unavailable |
| EL8  | RHEL 8 / Rocky8 / Alma8 / Anolis8 |  ✅   |  ⭐️  |  ✅   |  ✅   |  ✅   | **EL default feature set**                           |
| EL9  | RHEL 9 / Rocky9 / Alma9           |  ✅   |  ⭐️  |  ✅   |  ✅   |  ✅   | pgxnclient missing, perf dependency conflict         |
| D11  | Debian 11 (bullseye)              |  ✅   |  ⭐️  |  ✅   |  ✅   |  ✅   | supabase, pgml, RDKit unavailable                    |
| D12  | Debian 12 (bookworm)              |  ✅   |  ⭐️  |  ✅   |  ✅   |  ✅   | supabase, pgml unavailable                           |
| U20  | Ubuntu 20.04 (focal)              |  ✅   |  ⭐️  |  ✅   |  ✅   |  ✅   | supabase, PostGIS3, RDKit, pgml unavailable          |
| U22  | Ubuntu 22.04 (jammy)              |  ✅   |  ⭐️  |  ✅   |  ✅   |  ✅   | **DEB default feature set** (supabase unavailable)   |

* ⭐️ PostgreSQL 15 is currently the Major supported version with full extension support.
* ⭐ PostgreSQL 16 is the major support candidate, will be promoted when ready.
* ⚠️ EL7 Does not have an official PostgreSQL 16 support, and will EOL in 2024.
* ⚠️ Ubuntu & Debian support is introduced in Pigsty v2.5.0, use with caution.



----------------

## About

> Pigsty (/ˈpɪɡˌstaɪ/) is the abbreviation of "**P**ostgreSQL **I**n **G**reat **STY**le."

Docs: https://doc.pigsty.cc/

Website: https://pigsty.cc/en/ | https://pigsty.cc/zh/

WeChat: Search `pigsty-cc` to join the WeChat group.

Telegram: https://t.me/joinchat/gV9zfZraNPM3YjFh

Discord: https://discord.gg/Mu2b6Wxr

Author: [Vonng](https://vonng.com/en) ([rh@vonng.com](mailto:rh@vonng.com))

License: [AGPL-3.0](LICENSE)

Copyright: 2018-2023 rh@vonng.com