# PostgreSQL Extensions

Extensions are the soul of PostgreSQL, and Pigsty deeply integrates the core extension plugins of the PostgreSQL ecosystem, providing you with battery-included distributed temporal, geospatial text, graph, and vector database capabilities! Check [**extension list**](#extension-list) for details.

Pigsty includes over **150+** PostgreSQL extension plugins and has compiled, packaged, integrated, and maintained many extensions not included in the official PGDG source. 
It also ensures through thorough testing that all these plugins can work together seamlessly. Including some potent extensions:

- PostGIS: Add geospatial data support to PostgreSQL
- TimescaleDB: Add time-series/continuous-aggregation support to PostgreSQL
- PGVector: AI vector/embedding data type support, and ivfflat / hnsw index access method
- Citus: Turn a standalone primary-replica postgres cluster into a horizontally scalable distributed cluster
- Apache AGE: Add OpenCypher graph query language support to PostgreSQL, works like Neo4J
- PG GraphQL: Add GraphQL language support to PostgreSQL
- zhparser : Add Chinese word segmentation support to PostgreSQL, works like ElasticSearch
- [Supabase](https://github.com/Vonng/pigsty/tree/master/app/supabase): Open-Source Firebase alternative based on PostgreSQL
- [FerretDB](https://github.com/Vonng/pigsty/tree/master/app/ferretdb): Open-Source MongoDB alternative based on PostgreSQL
- [PostgresML](https://github.com/Vonng/pigsty/tree/master/app/pgml): Use machine learning algorithms and pretrained models with SQL
- [ParadeDB](https://www.paradedb.com/): Open-Source ElasticSearch Alternative (based on PostgreSQL)

Plugins are already included and placed in the yum repo of the infra nodes, which can be directly enabled through PGSQL [Cluster Config](#install-extension). Pigsty also introduces a complete compilation environment and infrastructure, allowing you to [compile extensions](https://github.com/Vonng/pigsty-rpm) not included in Pigsty & PGDG.

[![pigsty-extension.jpg](https://repo.pigsty.cc/img/pigsty-extension.jpg)](https://repo.pigsty.cc/img/pigsty-extension.jpg)

Some "database" are not actual PostgreSQL extensions, but also supported by pigsty, such as:

- [Supabase](https://github.com/Vonng/pigsty/tree/master/app/supabase): Open-Source Firebase Alternative (based on PostgreSQL)
- [FerretDB](https://github.com/Vonng/pigsty/tree/master/app/ferretdb): Open-Source MongoDB Alternative (based on PostgreSQL)
- [NocoDB](https://github.com/Vonng/pigsty/tree/master/app/nocodb): Open-Source Airtable Alternative (based on PostgreSQL)
- [DuckDB](https://github.com/Vonng/pigsty/tree/master/app/duckdb): Open-Source Analytical SQLite Alternative (PostgreSQL Compatible)


----------------

## Install Extension

When you init a PostgreSQL cluster, the extensions listed in [`pg_packages`](PARAM#pg_packages) & [`pg_extensions`](PARAM#pg_extension) will be installed.

For default EL systems, the default values of `pg_packages` and `pg_extensions` are defined as follows:

```yaml
pg_packages:     # these extensions are always installed by default : pg_repack, wal2json, passwordcheck_cracklib
  - pg_repack_${pg_version}* wal2json_${pg_version}* passwordcheck_cracklib_${pg_version}* # important extensions
pg_extensions:   # install postgis, timescaledb, pgvector by default
  - postgis34_${pg_version}* timescaledb-2-postgresql-${pg_version}* pgvector_${pg_version}*
```

For ubuntu / debian, package names are different, and `passwordcheck_cracklib` is not available. 

```yaml
pg_packages:    # these extensions are always installed by default : pg_repack, wal2json
  - postgresql-${pg_version}-repack postgresql-${pg_version}-wal2json
pg_extensions:  # these extensions are installed by default:
  - postgresql-${pg_version}-postgis* timescaledb-2-postgresql-${pg_version} postgresql-${pg_version}-pgvector postgresql-${pg_version}-citus-12.1
```

Here, `${pg_version}` is a placeholder that will be replaced with the actual major version number [`pg_version`](PARAM#pg_version) of that PostgreSQL cluster
Therefore, the default configuration will install these extensions:

- `pg_repack`: Extension for online table bloat processing.
- `wal2json`: Extracts changes in JSON format through logical decoding.
- `passwordcheck_cracklib`: Enforce password policy. (EL only)
- `postgis`: Geospatial database extension (postgis34, EL7: postgis33)
- `timescaledb`: Time-series database extension
- `pgvector`: Vector datatype and ivfflat/hnsw index
- `citus`: Distributed/columnar storage extension, (citus is conflict with `hydra`, choose one of them on EL systems)


If you want to enable certain extensions in a target cluster that has not yet been created, you can directly declare them with the parameters:


```yaml
pg-meta:
  hosts: { 10.10.10.10: { pg_seq: 1 ,pg_role: primary } }
  vars:
    pg_cluster: pg-meta
    pg_databases:
      - name: test
        extensions:                 # <----- install these extensions for database `test`
          - { name: postgis, schema: public }
          - { name: timescaledb }
          - { name: pg_cron }
          - { name: vector }
          - { name: age }
    pg_libs: 'timescaledb, pg_cron, pg_stat_statements, auto_explain' # <- some extension require a share library to work
    pg_extensions:
      - postgis34_${pg_version}* timescaledb-2-postgresql-${pg_version}* pgvector_${pg_version}* hydra_${pg_version}*   # default extensions to be installed
      - pg_cron_${pg_version}*        # <---- new extension: pg_cron
      - apache-age_${pg_version}*     # <---- new extension: apache-age
      - zhparser_${pg_version}*       # <---- new extension: zhparser
```

You can run the `pg_extension` sub-task in [`pgsql.yml`](PGSQL-PLAYBOOK#pgsqlyml) to add extensions to clusters that have already been created.

```bash
./pgsql.yml -l pg-meta -t pg_extension    # install specified extensions for cluster pg-v15
```

To install **all** available extensions in one pass, you can just specify `pg_extensions: ['*${pg_version}*']`, which is really a bold move.


----------------

### Install Manually

After the PostgreSQL cluster is inited, you can manually install plugins via Ansible or Shell commands. For example, if you want to enable a specific extension on a cluster that has already been initialized:

```bash
cd ~/pigsty;    # enter pigsty home dir and install the apache age extension for the pg-test cluster
ansible pg-test -m yum -b -a 'name=apache-age_16*'     # The extension name usually has a suffix like `_<pgmajorversion>`
```

Most plugins are already included in the yum repository on the infrastructure node and can be installed directly using the yum command. If not included, you can consider downloading from the PGDG upstream source using the `repotrack` / `apt download` command or compiling source code into RPMs for distribution.

After the extension installation, you should be able to see them in the `pg_available_extensions` view of the target database cluster. Next, execute in the database where you want to install the extension:

```sql
CREATE EXTENSION age;          -- install the graph database extension
```




------

## Extension List

Currently, the major version PostgreSQL 16 has the following extensions available, here are the extensions RPMs maintained by Pigsty (only available on EL7/8/9):

| name             | version |   source   | comment                                                                                      |
|------------------|:-------:|:----------:|----------------------------------------------------------------------------------------------|
| pgml             |  2.8.1  | **PIGSTY** | PostgresML: access most advanced machine learning algorithms and pretrained models with SQL  |
| age              |  1.5.0  | **PIGSTY** | Apache AGE graph database extension                                                          |
| pointcloud       |  1.2.5  | **PIGSTY** | A PostgreSQL extension for storing point cloud (LIDAR) data.                                 |
| http             |   1.6   | **PIGSTY** | HTTP client for PostgreSQL, allows web page retrieval inside the database.                   |
| gzip             |   1.0   | **PIGSTY** | Gzip and unzip with SQL                                                                      |
| pg_tle           |  1.3.4  | **PIGSTY** | Trusted Language Extensions for PostgreSQL                                                   |
| roaringbitmap    |   0.5   | **PIGSTY** | Support for Roaring Bitmaps                                                                  |
| zhparser         |   2.2   | **PIGSTY** | Parser for full-text search of Chinese                                                       |
| pg_net           |  0.8.0  | **PIGSTY** | A PostgreSQL extension that enables asynchronous (non-blocking) HTTP/HTTPS requests with SQL |
| pgjwt            |  0.2.0  | **PIGSTY** | JSON Web Token API for Postgresql                                                            |
| vault            |  0.2.9  | **PIGSTY** | Extension for storing encrypted secrets in the Vault                                         |
| pg_graphql       |  1.5.0  | **PIGSTY** | GraphQL support for PostgreSQL                                                               |
| hydra            |  1.1.1  | **PIGSTY** | Hydra is open source, column-oriented Postgres extension                                     |
| imgsmlr ❋        |  1.0.0  | **PIGSTY** | ImgSmlr method is based on Haar wavelet transform                                            |
| pg_similarity ❋  |  1.0.0  | **PIGSTY** | set of functions and operators for executing similarity queries                              |
| pg_bigm ❋        |  1.2.0  | **PIGSTY** | full text search capability with create 2-gram (bigram) index.                               |
| svector          |  0.5.6  | **PIGSTY** | pg_sparse: Sparse vector data type and sparse HNSW access methods                            |
| pg_bm25          |  0.5.6  | **PIGSTY** | ParadeDB: pg_bm25: Full text search for PostgreSQL using BM25                                |
| pg_analytics     |  0.5.6  | **PIGSTY** | ParadeDB: Real-time analytics for PostgreSQL using columnar storage and vectorized execution |
| duckdb_fdw       |   1.1   | **PIGSTY** | DuckDB Foreign Data Wrapper                                                                  |

> Caveat: some extensions are **not** available on Debian/Ubuntu systems, you can build from source, including: `http`, `gzip`, `pg_tle`, `roaringbitmap`, `zhparser`, `pgjwt`, `vault`, `hydra`, `imgsmlr`, `pg_bigm`, `duckdb_fdw`.
> `age` and `pointcloud` are included in deb repo. `pg_graphql`, `pg_net`, `pg_bm25`, `pg_analytics`, `svector` is available on Ubuntu 22.04.

Pigsty enlisted extensions:

| name                         | version |   source   | type  | pkg | comment                                                                                                             |
|------------------------------|:-------:|:----------:|:-----:|-----|---------------------------------------------------------------------------------------------------------------------|
| pgml                         |  2.8.1  | **PIGSTY** | FEAT  | rpm | PostgresML: access most advanced machine learning algorithms and pretrained models with SQL                         |
| age                          |  1.5.0  | **PIGSTY** | FEAT  | rpm | Apache AGE graph database extension                                                                                 |
| pg_graphql                   |  1.5.0  | **PIGSTY** | FEAT  | rpm | GraphQL support for PostgreSQL (RUST, supabase)                                                                     |
| hydra                        |  1.1.1  | **PIGSTY** | FEAT  | rpm | Hydra is open source, column-oriented Postgres extension                                                            |
| pg_analytics                 |  0.5.6  | **PIGSTY** | FEAT  | rpm | ParadeDB: Real-time analytics for PostgreSQL using columnar storage and vectorized execution                        |
| pg_bm25                      |  0.5.6  | **PIGSTY** | FEAT  | rpm | ParadeDB: pg_bm25: Full text search for PostgreSQL using BM25                                                       |
| svector                      |  0.5.6  | **PIGSTY** | FEAT  | rpm | ParadeDB: pg_sparse: Sparse vector data type and sparse HNSW access methods                                         |
| zhparser                     |   2.2   | **PIGSTY** | FEAT  | rpm | Parser for full-text search of Chinese                                                                              |
| pg_bigm ❋                    |  1.2.0  | **PIGSTY** | FEAT  | rpm | full text search capability with create 2-gram (bigram) index.                                                      |
| emaj                         |  4.3.1  |    PGDG    | FEAT  | rpm | E-Maj extension enables fine-grained write logging and time travel on subsets of the database.                      |
| periods                      |   1.2   |    PGDG    | FEAT  | rpm | Provide Standard SQL functionality for PERIODs and SYSTEM VERSIONING                                                |
| pg_ivm                       |   1.7   |    PGDG    | FEAT  | rpm | incremental view maintenance on PostgreSQL                                                                          |
| pgq                          |  3.5.1  |    PGDG    | FEAT  | rpm | Generic queue for PostgreSQL                                                                                        |
| pgq_node                     |   3.5   |    PGDG    | FEAT  | deb | Cascaded queue infrastructure                                                                                       |
| pgsodium                     |  3.1.9  |    PGDG    | FEAT  | rpm | Postgres extension for libsodium functions                                                                          |
| **timescaledb**              | 2.14.1  |    PGDG    | FEAT  | rpm | Enables scalable inserts and complex queries for time-series data (Apache 2 Edition)                                |
| **wal2json**                 |  2.5.3  |    PGDG    | FEAT  | rpm | Capture JSON format CDC change via logical decoding                                                                 |
| decoderbufs                  |  0.1.0  |    PGDG    | FEAT  | deb | Logical decoding plugin that delivers WAL stream changes using a Protocol Buffer format                             |
| **vector**                   |  0.6.0  |    PGDG    | FEAT  | rpm | vector data type and ivfflat / hnsw access method                                                                   |
| safeupdate                   |   1.4   |    PGDG    | FEAT  | rpm | Require criteria for UPDATE and DELETE                                                                              |
| pg_hint_plan                 |  1.6.0  |    PGDG    | FEAT  | rpm | Give PostgreSQL ability to manually force some decisions in execution plans                                         |
| pg_snakeoil                  |    1    |    PGDG    | FEAT  | deb | The PostgreSQL Antivirus                                                                                            |
| jsquery                      |   1.1   |    PGDG    | FEAT  | deb | data type for jsonb inspection                                                                                      |
| omnidb_plpgsql_debugger      |  1.0.0  |    PGDG    | FEAT  | deb | PostgreSQL extension for enabling PL/pgSQL debugger in OmniDB                                                       |
| icu_ext                      |   1.8   |    PGDG    | FEAT  | deb | Access ICU functions                                                                                                |
| pgmemcache                   |  2.3.0  |    PGDG    | FEAT  | deb | memcached interface                                                                                                 |
| pre_prepare                  |   0.4   |    PGDG    | FEAT  | deb | Pre Prepare your Statement server side                                                                              |
| credcheck                    |  2.6.0  |    PGDG    | ADMIN | rpm | credcheck - postgresql plain text credential checker                                                                |
| **pg_cron**                  |   1.6   |    PGDG    | ADMIN | rpm | Job scheduler for PostgreSQL                                                                                        |
| pg_background                |   1.0   |    PGDG    | ADMIN | rpm | Run SQL queries in the background                                                                                   |
| pg_jobmon                    |  1.4.1  |    PGDG    | ADMIN | rpm | Extension for logging and monitoring functions in PostgreSQL                                                        |
| pg_readonly                  |  1.0.0  |    PGDG    | ADMIN | rpm | cluster database read only                                                                                          |
| **pg_repack**                |  1.5.0  |    PGDG    | ADMIN | rpm | Reorganize tables in PostgreSQL databases with minimal locks                                                        |
| pg_squeeze                   |   1.6   |    PGDG    | ADMIN | rpm | A tool to remove unused space from a relation.                                                                      |
| pgfincore                    |  1.3.1  |    PGDG    | ADMIN | rpm | examine and manage the os buffer cache                                                                              |
| **pglogical**                |  2.4.4  |    PGDG    | ADMIN | rpm | PostgreSQL Logical Replication                                                                                      |
| pglogical_origin             |  1.0.0  |    PGDG    | ADMIN | rpm | Dummy extension for compatibility when upgrading from Postgres 9.4                                                  |
| pglogical_ticker             |   1.4   |    PGDG    | ADMIN | deb | Have an accurate view on pglogical replication delay                                                                |
| pgl_ddl_deploy               |   2.2   |    PGDG    | ADMIN | deb | automated ddl deployment using pglogical                                                                            |
| toastinfo                    |    1    |    PGDG    | ADMIN | deb | show details on toasted datums                                                                                      |
| pg_fact_loader               |   2.0   |    PGDG    | ADMIN | deb | build fact tables with Postgres                                                                                     |
| pgautofailover               |   2.1   |    PGDG    | ADMIN | deb | pg_auto_failover                                                                                                    |
| mimeo                        |  1.5.1  |    PGDG    | ADMIN | deb | Extension for specialized, per-table replication between PostgreSQL instances                                       |
| prioritize                   |   1.0   |    PGDG    | ADMIN | rpm | get and set the priority of PostgreSQL backends                                                                     |
| pg_tle                       |  1.3.4  | **PIGSTY** | ADMIN | rpm | Trusted Language Extensions for PostgreSQL                                                                          |
| set_user                     |  4.0.1  |    PGDG    | AUDIT | rpm | similar to SET ROLE but with added logging                                                                          |
| **passwordcracklib**         |  3.0.0  |    PGDG    | AUDIT | rpm | Enforce password policy                                                                                             |
| pgaudit ❋                    |  16.0   |    PGDG    | AUDIT | rpm | provides auditing functionality                                                                                     |
| pgauditlogtofile             |   1.5   |    PGDG    | AUDIT | deb | pgAudit addon to redirect audit log to an independent file                                                          |
| pgcryptokey                  |   1.0   |    PGDG    | AUDIT | rpm | cryptographic key management                                                                                        |
| duckdb_fdw                   |   1.1   | **PIGSTY** |  FDW  | rpm | DuckDB Foreign Data Wrapper                                                                                         |
| hdfs_fdw                     |  2.0.5  |    PGDG    |  FDW  | rpm | foreign-data wrapper for remote hdfs servers                                                                        |
| mongo_fdw                    |   1.1   |    PGDG    |  FDW  | rpm | foreign data wrapper for MongoDB access                                                                             |
| multicorn ❋                  |   2.4   |    PGDG    |  FDW  | rpm | Multicorn2 Python3.6+ bindings for Postgres 11++ Foreign Data Wrapper                                               |
| mysql_fdw                    |   1.2   |    PGDG    |  FDW  | rpm | Foreign data wrapper for querying a MySQL server                                                                    |
| pgbouncer_fdw                |  1.1.0  |    PGDG    |  FDW  | rpm | Extension for querying pgbouncer stats from normal SQL views & running pgbouncer commands from normal SQL functions |
| sqlite_fdw                   |   1.1   |    PGDG    |  FDW  | rpm | SQLite Foreign Data Wrapper                                                                                         |
| tds_fdw                      |  2.0.3  |    PGDG    |  FDW  | rpm | Foreign data wrapper for querying a TDS database (Sybase or Microsoft SQL Server)                                   |
| oracle_fdw                   |   1.2   |    PGDG    |  FDW  | deb | foreign data wrapper for Oracle access                                                                              |
| ogr_fdw                      |   1.1   |    PGDG    |  FDW  | deb | foreign-data wrapper for GIS data access                                                                            |
| count_distinct               |  3.0.1  |    PGDG    | FUNC  | rpm | An alternative to COUNT(DISTINCT ...) aggregate, usable with HashAggregate                                          |
| ddlx                         |  0.27   |    PGDG    | FUNC  | rpm | DDL eXtractor functions                                                                                             |
| extra_window_functions       |   1.0   |    PGDG    | FUNC  | rpm | Additional window functions to PostgreSQL                                                                           |
| first_last_agg               |  0.1.4  |    PGDG    | FUNC  | deb | first() and last() aggregate functions                                                                              |
| mysqlcompat ❋                |  0.0.7  |    PGDG    | FUNC  | rpm | MySQL compatibility functions                                                                                       |
| orafce                       |   4.9   |    PGDG    | FUNC  | rpm | Functions and operators that emulate a subset of functions and packages from the Oracle RDBMS                       |
| pgsql_tweaks                 | 0.10.2  |    PGDG    | FUNC  | rpm | Some functions and views for daily usage                                                                            |
| tdigest                      |  1.4.1  |    PGDG    | FUNC  | rpm | Provides tdigest aggregate function.                                                                                |
| topn                         |  2.6.0  |    PGDG    | FUNC  | rpm | type for top-n JSONB                                                                                                |
| unaccent                     |   1.1   |    PGDG    | FUNC  | rpm | text search dictionary that removes accents                                                                         |
| table_log                    |  0.6.1  |    PGDG    | FUNC  | deb | Module to log changes on tables                                                                                     |
| pg_sphere                    |  1.4.2  |    PGDG    | FUNC  | deb | spherical objects with useful functions, operators and index support                                                |
| pgpcre                       |    1    |    PGDG    | FUNC  | deb | Perl Compatible Regular Expression functions                                                                        |
| q3c                          |  2.0.1  |    PGDG    | FUNC  | deb | q3c sky indexing plugin                                                                                             |
| **postgis**                  |  3.4.2  |    PGDG    |  GIS  | rpm | PostGIS geometry and geography spatial types and functions                                                          |
| postgis_raster               |  3.4.2  |    PGDG    |  GIS  | rpm | PostGIS raster types and functions                                                                                  |
| postgis_sfcgal               |  3.4.2  |    PGDG    |  GIS  | rpm | PostGIS SFCGAL functions                                                                                            |
| postgis_tiger_geocoder       |  3.4.2  |    PGDG    |  GIS  | rpm | PostGIS tiger geocoder and reverse geocoder                                                                         |
| postgis_topology             |  3.4.2  |    PGDG    |  GIS  | rpm | PostGIS topology spatial types and functions                                                                        |
| address_standardizer         |  3.4.2  |    PGDG    |  GIS  | rpm | Used to parse an address into constituent elements. Generally used to support geocoding address normalization step. |
| address_standardizer_data_us |  3.4.2  |    PGDG    |  GIS  | rpm | Address Standardizer US dataset example                                                                             |
| pointcloud                   |  1.2.5  | **PIGSTY** |  GIS  | rpm | A PostgreSQL extension for storing point cloud (LIDAR) data.                                                        |
| bloom                        |   1.0   |    PGDG    | INDEX | rpm | bloom access method - signature file based index                                                                    |
| hll ❋                        |  2.18   |    PGDG    | INDEX | rpm | type for storing hyperloglog data                                                                                   |
| pgtt                         |  3.1.0  |    PGDG    | INDEX | rpm | Extension to add Global Temporary Tables feature to PostgreSQL                                                      |
| rum                          |   1.3   |    PGDG    | INDEX | rpm | RUM index access method                                                                                             |
| hstore_plperl                |   1.0   |    PGDG    | LANG  | rpm | transform between hstore and plperl                                                                                 |
| hstore_plperlu               |   1.0   |    PGDG    | LANG  | rpm | transform between hstore and plperlu                                                                                |
| plpgsql_check                |   2.7   |    PGDG    | LANG  | rpm | extended check for plpgsql functions                                                                                |
| plsh                         |    2    |    PGDG    | LANG  | rpm | PL/sh procedural language                                                                                           |
| pllua                        |   2.0   |    PGDG    | LANG  | deb | Lua as a procedural language                                                                                        |
| plluau                       |   2.0   |    PGDG    | LANG  | deb | Lua as an untrusted procedural language                                                                             |
| hstore_plluau                |   1.0   |    PGDG    | LANG  | deb | Hstore transform for untrusted Lua                                                                                  |
| **citus**                    | 12.1-1  |    PGDG    | SHARD | rpm | Citus distributed database                                                                                          |
| citus_columnar               | 11.3-1  |    PGDG    | SHARD | rpm | Citus Columnar extension                                                                                            |
| pg_fkpart                    |   1.7   |    PGDG    | SHARD | rpm | Table partitioning by foreign key utility                                                                           |
| pg_partman                   |  5.0.1  |    PGDG    | SHARD | rpm | Extension to manage partitioned tables by time or ID                                                                |
| plproxy ❋                    | 2.10.0  |    PGDG    | SHARD | rpm | Database partitioning implemented as procedural language                                                            |
| pg_show_plans                |   2.0   |    PGDG    | STAT  | deb | show query plans of all currently running SQL statements                                                            |
| hypopg                       |  1.4.0  |    PGDG    | STAT  | rpm | Hypothetical indexes for PostgreSQL                                                                                 |
| logerrors                    |   2.1   |    PGDG    | STAT  | rpm | Function for collecting statistics about messages in logfile                                                        |
| pg_auth_mon                  |   1.1   |    PGDG    | STAT  | rpm | monitor connection attempts per user                                                                                |
| pg_permissions               |   1.1   |    PGDG    | STAT  | rpm | view object permissions and compare them with the desired state                                                     |
| pg_qualstats                 |  2.1.0  |    PGDG    | STAT  | rpm | An extension collecting statistics about quals                                                                      |
| pg_stat_kcache               |  2.2.3  |    PGDG    | STAT  | rpm | Kernel statistics gathering                                                                                         |
| pg_stat_monitor              |   2.0   |    PGDG    | STAT  | rpm | aggregated statistics, client information, plan details including plan, and histogram information.                  |
| pg_store_plans ❋             |   1.7   |    PGDG    | STAT  | rpm | track plan statistics of all SQL statements executed                                                                |
| pg_track_settings            |  2.1.2  |    PGDG    | STAT  | rpm | Track settings changes                                                                                              |
| pg_wait_sampling             |   1.1   |    PGDG    | STAT  | rpm | sampling based statistics of wait events                                                                            |
| pldbgapi                     |   1.1   |    PGDG    | STAT  | rpm | server-side support for debugging PL/pgSQL functions                                                                |
| plprofiler                   |   4.2   |    PGDG    | STAT  | rpm | server-side support for profiling PL/pgSQL functions                                                                |
| powa                         |  4.2.2  |    PGDG    | STAT  | rpm | PostgreSQL Workload Analyser-core                                                                                   |
| system_stats ❋               |   1.0   |    PGDG    | STAT  | rpm | System statistic functions for PostgreSQL                                                                           |
| asn1oid                      |    1    |    PGDG    | TYPE  | deb | ASN.1 OID Data Type                                                                                                 |
| citext                       |   1.6   |    PGDG    | TYPE  | rpm | data type for case-insensitive character strings                                                                    |
| debversion                   |   1.1   |    PGDG    | TYPE  | deb | Debian version number data type                                                                                     |
| ip4r                         |   2.4   |    PGDG    | TYPE  | rpm | IPv4/v6 and IPv4/v6 range index type for PostgreSQL                                                                 |
| pg_uuidv7                    |   1.4   |    PGDG    | TYPE  | rpm | pg_uuidv7: create UUIDv7 values in postgres                                                                         |
| pgmp                         |   1.1   |    PGDG    | TYPE  | rpm | Multiple Precision Arithmetic extension                                                                             |
| semver                       | 0.32.1  |    PGDG    | TYPE  | rpm | Semantic version data type                                                                                          |
| timestamp9                   |  1.4.0  |    PGDG    | TYPE  | rpm | timestamp nanosecond resolution                                                                                     |
| unit ❋                       |    7    |    PGDG    | TYPE  | rpm | SI units extension                                                                                                  |
| numeral                      |    1    |    PGDG    | TYPE  | deb | numeral datatypes extension                                                                                         |
| pg_rational                  |  0.0.1  |    PGDG    | TYPE  | deb | bigint fractions                                                                                                    |
| roaringbitmap                |   0.5   | **PIGSTY** | TYPE  | rpm | Support for Roaring Bitmaps                                                                                         |
| amcheck                      |   1.3   |  CONTRIB   | INDEX | rpm | functions for verifying relation integrity                                                                          |
| adminpack                    |   2.1   |  CONTRIB   | ADMIN | sys | administrative functions for PostgreSQL                                                                             |
| lo                           |   1.1   |  CONTRIB   | ADMIN | sys | Large Object maintenance                                                                                            |
| old_snapshot                 |   1.0   |  CONTRIB   | ADMIN | sys | utilities in support of old_snapshot_threshold                                                                      |
| pg_prewarm                   |   1.2   |  CONTRIB   | ADMIN | sys | prewarm relation data                                                                                               |
| pg_surgery                   |   1.0   |  CONTRIB   | ADMIN | sys | extension to perform surgery on a damaged relation                                                                  |
| dblink                       |   1.2   |  CONTRIB   |  FDW  | sys | connect to other PostgreSQL databases from within a database                                                        |
| file_fdw                     |   1.0   |  CONTRIB   |  FDW  | sys | foreign-data wrapper for flat file access                                                                           |
| postgres_fdw                 |   1.1   |  CONTRIB   |  FDW  | sys | foreign-data wrapper for remote PostgreSQL servers                                                                  |
| gzip                         |   1.0   | **PIGSTY** | FUNC  | rpm | Gzip and unzip with SQL                                                                                             |
| http                         |   1.6   | **PIGSTY** | FUNC  | rpm | HTTP client for PostgreSQL, allows web page retrieval inside the database.                                          |
| pg_net                       |  0.8.0  | **PIGSTY** | FUNC  | rpm | A PostgreSQL extension that enables asynchronous (non-blocking) HTTP/HTTPS requests with SQL                        |
| pgjwt                        |  0.2.0  | **PIGSTY** | FUNC  | rpm | JSON Web Token API for Postgresql                                                                                   |
| vault                        |  0.2.9  | **PIGSTY** | FUNC  | rpm | Extension for storing encrypted secrets in the Vault                                                                |
| imgsmlr ❋                    |  1.0.0  | **PIGSTY** | FUNC  | rpm | ImgSmlr method is based on Haar wavelet transform                                                                   |
| pg_similarity ❋              |  1.0.0  | **PIGSTY** | FUNC  | rpm | set of functions and operators for executing similarity queries                                                     |
| autoinc                      |   1.0   |  CONTRIB   | FUNC  | sys | functions for autoincrementing fields                                                                               |
| dict_int                     |   1.0   |  CONTRIB   | FUNC  | sys | text search dictionary template for integers                                                                        |
| dict_xsyn                    |   1.0   |  CONTRIB   | FUNC  | sys | text search dictionary template for extended synonym processing                                                     |
| earthdistance                |   1.1   |  CONTRIB   | FUNC  | sys | calculate great-circle distances on the surface of the Earth                                                        |
| fuzzystrmatch                |   1.2   |  CONTRIB   | FUNC  | sys | determine similarities and distance between strings                                                                 |
| insert_username              |   1.0   |  CONTRIB   | FUNC  | sys | functions for tracking who changed a table                                                                          |
| intagg                       |   1.1   |  CONTRIB   | FUNC  | sys | integer aggregator and enumerator (obsolete)                                                                        |
| intarray                     |   1.5   |  CONTRIB   | FUNC  | sys | functions, operators, and index support for 1-D arrays of integers                                                  |
| moddatetime                  |   1.0   |  CONTRIB   | FUNC  | sys | functions for tracking last modification time                                                                       |
| pg_trgm                      |   1.6   |  CONTRIB   | FUNC  | sys | text similarity measurement and index searching based on trigrams                                                   |
| pgcrypto                     |   1.3   |  CONTRIB   | FUNC  | sys | cryptographic functions                                                                                             |
| refint                       |   1.0   |  CONTRIB   | FUNC  | sys | functions for implementing referential integrity (obsolete)                                                         |
| tablefunc                    |   1.0   |  CONTRIB   | FUNC  | sys | functions that manipulate whole tables, including crosstab                                                          |
| tcn                          |   1.0   |  CONTRIB   | FUNC  | sys | Triggered change notifications                                                                                      |
| tsm_system_rows              |   1.0   |  CONTRIB   | FUNC  | sys | TABLESAMPLE method which accepts number of rows as a limit                                                          |
| tsm_system_time              |   1.0   |  CONTRIB   | FUNC  | sys | TABLESAMPLE method which accepts time in milliseconds as a limit                                                    |
| uuid-ossp                    |   1.1   |  CONTRIB   | FUNC  | sys | generate universally unique identifiers (UUIDs)                                                                     |
| btree_gin                    |   1.3   |  CONTRIB   | FUNC  | sys | support for indexing common datatypes in GIN                                                                        |
| btree_gist                   |   1.7   |  CONTRIB   | FUNC  | sys | support for indexing common datatypes in GiST                                                                       |
| bool_plperl                  |   1.0   |  CONTRIB   | LANG  | sys | transform between bool and plperl                                                                                   |
| bool_plperlu                 |   1.0   |  CONTRIB   | LANG  | sys | transform between bool and plperlu                                                                                  |
| hstore_plpython3u            |   1.0   |  CONTRIB   | LANG  | sys | transform between hstore and plpython3u                                                                             |
| jsonb_plperl                 |   1.0   |  CONTRIB   | LANG  | sys | transform between jsonb and plperl                                                                                  |
| jsonb_plperlu                |   1.0   |  CONTRIB   | LANG  | sys | transform between jsonb and plperlu                                                                                 |
| jsonb_plpython3u             |   1.0   |  CONTRIB   | LANG  | sys | transform between jsonb and plpython3u                                                                              |
| ltree_plpython3u             |   1.0   |  CONTRIB   | LANG  | sys | transform between ltree and plpython3u                                                                              |
| plperl                       |   1.0   |  CONTRIB   | LANG  | sys | PL/Perl procedural language                                                                                         |
| plperlu                      |   1.0   |  CONTRIB   | LANG  | sys | PL/PerlU untrusted procedural language                                                                              |
| plpgsql                      |   1.0   |  CONTRIB   | LANG  | sys | PL/pgSQL procedural language                                                                                        |
| plpython3u                   |   1.0   |  CONTRIB   | LANG  | sys | PL/Python3U untrusted procedural language                                                                           |
| pltcl                        |   1.0   |  CONTRIB   | LANG  | sys | PL/TCL procedural language                                                                                          |
| pltclu                       |   1.0   |  CONTRIB   | LANG  | sys | PL/TCLU untrusted procedural language                                                                               |
| pageinspect                  |  1.12   |  CONTRIB   | STAT  | sys | inspect the contents of database pages at a low level                                                               |
| pg_buffercache               |   1.3   |  CONTRIB   | STAT  | sys | examine the shared buffer cache                                                                                     |
| pg_freespacemap              |   1.2   |  CONTRIB   | STAT  | sys | examine the free space map (FSM)                                                                                    |
| pg_stat_statements           |  1.10   |  CONTRIB   | STAT  | sys | track planning and execution statistics of all SQL statements executed                                              |
| pg_visibility                |   1.2   |  CONTRIB   | STAT  | sys | examine the visibility map (VM) and page-level visibility info                                                      |
| pg_walinspect                |   1.1   |  CONTRIB   | STAT  | sys | functions to inspect contents of PostgreSQL Write-Ahead Log                                                         |
| pgrowlocks                   |   1.2   |  CONTRIB   | STAT  | sys | show row-level locking information                                                                                  |
| pgstattuple                  |   1.5   |  CONTRIB   | STAT  | sys | show tuple-level statistics                                                                                         |
| sslinfo                      |   1.2   |  CONTRIB   | STAT  | sys | information about SSL certificates                                                                                  |
| cube                         |   1.5   |  CONTRIB   | TYPE  | sys | data type for multidimensional cubes                                                                                |
| hstore                       |   1.8   |  CONTRIB   | TYPE  | sys | data type for storing sets of (key, value) pairs                                                                    |
| isn                          |   1.2   |  CONTRIB   | TYPE  | sys | data types for international product numbering standards                                                            |
| ltree                        |   1.2   |  CONTRIB   | TYPE  | sys | data type for hierarchical tree-like structures                                                                     |
| prefix                       |  1.2.0  |  CONTRIB   | TYPE  | sys | Prefix Range module for PostgreSQL                                                                                  |
| seg                          |   1.4   |  CONTRIB   | TYPE  | sys | data type for representing line segments or floating-point intervals                                                |
| xml2                         |   1.1   |  CONTRIB   | TYPE  | sys | XPath querying and XSLT                                                                                             |

> Extension marked with `❋` is not support PostgreSQL 16 yet, but can be installed on lower version: 12/13/14/15.
