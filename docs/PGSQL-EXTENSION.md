# PostgreSQL Extensions

Extensions are the soul of PostgreSQL, and Pigsty deeply integrates the core extension plugins of the PostgreSQL ecosystem, providing you with battery-included distributed temporal, geospatial text, graph, and vector database capabilities! Check [extension list](PGSQL-EXTENSION#extension-list) for details.

Pigsty includes over **150+** PostgreSQL extension plugins and has compiled, packaged, integrated, and maintained many extensions not included in the official PGDG source. It also ensures through thorough testing that all these plugins can work together seamlessly. Including some potent extensions, such as [PostGIS](https://postgis.net/) to process geospatial data, [TimescaleDB](https://www.timescale.com/) to analyze time series/event stream data,  [Citus](https://www.citusdata.com/) to transform a standalone database into a horizontally scalable distributed cluster,  [PGVector](https://github.com/pgvector/pgvector) to store and search AI embeddings, [Apache AGE](https://age.apache.org/) for graph data storage and retrieval to works like Neo4J, and [zhparser](https://github.com/amutu/zhparser) for Chinese word segmentation to work like ElasticSearch.

Plugins are already included and placed in the yum repo of the infra nodes, which can be directly enabled through PGSQL [Cluster Config](#install-extension) or [installed manually](#install-manually) using `yum`. Pigsty also introduces a complete compilation environment and infrastructure, allowing you to [compile extensions](#compile-extension) not included in Pigsty & PGDG.

![pigsty-extension.jpg](https://repo.pigsty.cc/img/pigsty-extension.jpg)

Some "database" are not actual PostgreSQL extensions, but also supported by pigsty, such as:

 - [Supabase](https://github.com/Vonng/pigsty/tree/master/app/supabase): Open-Source Firebase Alternative (based on PostgreSQL)
 - [FerretDB](https://github.com/Vonng/pigsty/tree/master/app/ferretdb): Open-Source MongoDB Alternative (based on PostgreSQL)
 - [NocoDB](https://github.com/Vonng/pigsty/tree/master/app/nocodb): Open-Source Airtable Alternative (based on PostgreSQL)
 - EdgeDB: A GRAPH-LIKE SCHEMA WITH A RELATIONAL CORE, (based on PostgreSQL)


------

## Extension List

Currently, the main version 15 of PostgreSQL in Pigsty provides the following extension plugins (other major versions only include core extensions but can be downloaded from the upstream repo). `sources` indicate where the extension comes from: PostgreSQL's own `CONTRIB` module, extensions provided by the official `PGDG` repo, and extensions packaged and maintained by `PIGSTY`. 

The `type` has the following categories:

- `FEAT`: New Features
- `GIS`: Geospatial, PostGIS
- `TYPE`: New Data type
- `FUNC`: Functions and stored procedures
- `INDEX`: Index access methods
- `LANG`: Programming language support
- `SHARD`: Horizontal Sharding
- `ADMIN`: Management Tools
- `AUDIT`: Audit Tools
- `FDW`: Foreign Data Wrapper and Utils
- `STAT`: Statistic & Observability

There are some powerful extensions, such as: `postgis`, `timescaledb`, `citus`, `age`, `vector`, `zhparser`, `pg_repack`, `wal2json`, `passwordcracklib`, `pg_cron`, `age`, `hydra`, `PostgresML`, etc...

Here are extensions maintained by Pigsty and included in the Pigsty RPM repo:

| name          | version |   source   | type | comment                                                                                      |
|---------------|:-------:|:----------:|:----:|----------------------------------------------------------------------------------------------|
| pgml          |  2.7.9  | **PIGSTY** | FEAT | PostgresML: access most advanced machine learning algorithms and pretrained models with SQL  |
| age           |  1.4.0  | **PIGSTY** | FEAT | Apache AGE graph database extension                                                          |
| pointcloud    |  1.2.5  | **PIGSTY** | FEAT | A PostgreSQL extension for storing point cloud (LIDAR) data.                                 |
| http          |   1.6   | **PIGSTY** | FEAT | HTTP client for PostgreSQL, allows web page retrieval inside the database.                   |
| pg_tle        |  1.2.0  | **PIGSTY** | FEAT | Trusted Language Extensions for PostgreSQL                                                   |
| roaringbitmap |   0.5   | **PIGSTY** | FEAT | Support for Roaring Bitmaps                                                                  |
| zhparser      |   2.2   | **PIGSTY** | FEAT | Parser for full-text search of Chinese                                                       |
| pg_net        |  0.7.3  | **PIGSTY** | FEAT | A PostgreSQL extension that enables asynchronous (non-blocking) HTTP/HTTPS requests with SQL |
| vault         |  0.2.9  | **PIGSTY** | FEAT | Extension for storing encrypted secrets in the Vault                                         |
| pg_graphql    |  1.4.0  | **PIGSTY** | FEAT | GraphQL support for PostgreSQL                                                               |
| hydra         |  1.0.0  | **PIGSTY** | FEAT | Hydra is open source, column-oriented Postgres extension                                     |
| imgsmlr       |  1.0.0  | **PIGSTY** | FEAT | ImgSmlr method is based on Haar wavelet transform                                            |
| pg_similarity |  1.0.0  | **PIGSTY** | FEAT | set of functions and operators for executing similarity queries                              |
| pg_bigm       |  1.2.0  | **PIGSTY** | FEAT | full text search capability with create 2-gram (bigram) index.                               |


Extensions maintained by PGDG and included in the Pigsty offline pacakge:

| name                         | version |   source   | type  | comment                                                                                                                    |
|------------------------------|:-------:|:----------:|:-----:|----------------------------------------------------------------------------------------------------------------------------|
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
| lo                           |   1.1   |  CONTRIB   | ADMIN | Large Object maintenance                                                                                                   |
| old_snapshot                 |   1.0   |  CONTRIB   | ADMIN | utilities in support of old_snapshot_threshold                                                                             |
| pg_prewarm                   |   1.2   |  CONTRIB   | ADMIN | prewarm relation data                                                                                                      |
| pg_surgery                   |   1.0   |  CONTRIB   | ADMIN | extension to perform surgery on a damaged relation                                                                         |
| dblink                       |   1.2   |  CONTRIB   |  FDW  | connect to other PostgreSQL databases from within a database                                                               |
| file_fdw                     |   1.0   |  CONTRIB   |  FDW  | foreign-data wrapper for flat file access                                                                                  |
| postgres_fdw                 |   1.1   |  CONTRIB   |  FDW  | foreign-data wrapper for remote PostgreSQL servers                                                                         |
| autoinc                      |   1.0   |  CONTRIB   | FUNC  | functions for autoincrementing fields                                                                                      |
| dict_int                     |   1.0   |  CONTRIB   | FUNC  | text search dictionary template for integers                                                                               |
| dict_xsyn                    |   1.0   |  CONTRIB   | FUNC  | text search dictionary template for extended synonym processing                                                            |
| earthdistance                |   1.1   |  CONTRIB   | FUNC  | calculate great-circle distances on the surface of the Earth                                                               |
| fuzzystrmatch                |   1.1   |  CONTRIB   | FUNC  | determine similarities and distance between strings                                                                        |
| insert_username              |   1.0   |  CONTRIB   | FUNC  | functions for tracking who changed a table                                                                                 |
| intagg                       |   1.1   |  CONTRIB   | FUNC  | integer aggregator and enumerator (obsolete)                                                                               |
| intarray                     |   1.5   |  CONTRIB   | FUNC  | functions, operators, and index support for 1-D arrays of integers                                                         |
| moddatetime                  |   1.0   |  CONTRIB   | FUNC  | functions for tracking last modification time                                                                              |
| pg_trgm                      |   1.6   |  CONTRIB   | FUNC  | text similarity measurement and index searching based on trigrams                                                          |
| pgcrypto                     |   1.3   |  CONTRIB   | FUNC  | cryptographic functions                                                                                                    |
| refint                       |   1.0   |  CONTRIB   | FUNC  | functions for implementing referential integrity (obsolete)                                                                |
| tablefunc                    |   1.0   |  CONTRIB   | FUNC  | functions that manipulate whole tables, including crosstab                                                                 |
| tcn                          |   1.0   |  CONTRIB   | FUNC  | Triggered change notifications                                                                                             |
| tsm_system_rows              |   1.0   |  CONTRIB   | FUNC  | TABLESAMPLE method which accepts number of rows as a limit                                                                 |
| tsm_system_time              |   1.0   |  CONTRIB   | FUNC  | TABLESAMPLE method which accepts time in milliseconds as a limit                                                           |
| uuid-ossp                    |   1.1   |  CONTRIB   | FUNC  | generate universally unique identifiers (UUIDs)                                                                            |
| btree_gin                    |   1.3   |  CONTRIB   | INDEX | support for indexing common datatypes in GIN                                                                               |
| btree_gist                   |   1.7   |  CONTRIB   | INDEX | support for indexing common datatypes in GiST                                                                              |
| bool_plperl                  |   1.0   |  CONTRIB   | LANG  | transform between bool and plperl                                                                                          |
| bool_plperlu                 |   1.0   |  CONTRIB   | LANG  | transform between bool and plperlu                                                                                         |
| hstore_plpython3u            |   1.0   |  CONTRIB   | LANG  | transform between hstore and plpython3u                                                                                    |
| jsonb_plperl                 |   1.0   |  CONTRIB   | LANG  | transform between jsonb and plperl                                                                                         |
| jsonb_plperlu                |   1.0   |  CONTRIB   | LANG  | transform between jsonb and plperlu                                                                                        |
| jsonb_plpython3u             |   1.0   |  CONTRIB   | LANG  | transform between jsonb and plpython3u                                                                                     |
| ltree_plpython3u             |   1.0   |  CONTRIB   | LANG  | transform between ltree and plpython3u                                                                                     |
| plperl                       |   1.0   |  CONTRIB   | LANG  | PL/Perl procedural language                                                                                                |
| plperlu                      |   1.0   |  CONTRIB   | LANG  | PL/PerlU untrusted procedural language                                                                                     |
| plpgsql                      |   1.0   |  CONTRIB   | LANG  | PL/pgSQL procedural language                                                                                               |
| plpython3u                   |   1.0   |  CONTRIB   | LANG  | PL/Python3U untrusted procedural language                                                                                  |
| pltcl                        |   1.0   |  CONTRIB   | LANG  | PL/TCL procedural language                                                                                                 |
| pltclu                       |   1.0   |  CONTRIB   | LANG  | PL/TCLU untrusted procedural language                                                                                      |
| pageinspect                  |  1.11   |  CONTRIB   | STAT  | inspect the contents of database pages at a low level                                                                      |
| pg_buffercache               |   1.3   |  CONTRIB   | STAT  | examine the shared buffer cache                                                                                            |
| pg_freespacemap              |   1.2   |  CONTRIB   | STAT  | examine the free space map (FSM)                                                                                           |
| **pg_stat_statements**       |  1.10   |  CONTRIB   | STAT  | track planning and execution statistics of all SQL statements executed                                                     |
| pg_visibility                |   1.2   |  CONTRIB   | STAT  | examine the visibility map (VM) and page-level visibility info                                                             |
| pg_walinspect                |   1.0   |  CONTRIB   | STAT  | functions to inspect contents of PostgreSQL Write-Ahead Log                                                                |
| pgrowlocks                   |   1.2   |  CONTRIB   | STAT  | show row-level locking information                                                                                         |
| pgstattuple                  |   1.5   |  CONTRIB   | STAT  | show tuple-level statistics                                                                                                |
| sslinfo                      |   1.2   |  CONTRIB   | STAT  | information about SSL certificates                                                                                         |
| cube                         |   1.5   |  CONTRIB   | TYPE  | data type for multidimensional cubes                                                                                       |
| hstore                       |   1.8   |  CONTRIB   | TYPE  | data type for storing sets of (key, value) pairs                                                                           |
| isn                          |   1.2   |  CONTRIB   | TYPE  | data types for international product numbering standards                                                                   |
| ltree                        |   1.2   |  CONTRIB   | TYPE  | data type for hierarchical tree-like structures                                                                            |
| prefix                       |  1.2.0  |  CONTRIB   | TYPE  | Prefix Range module for PostgreSQL                                                                                         |
| seg                          |   1.4   |  CONTRIB   | TYPE  | data type for representing line segments or floating-point intervals                                                       |
| xml2                         |   1.1   |  CONTRIB   | TYPE  | XPath querying and XSLT                                                                                                    |



----------------

## Install Extension

When you init a PostgreSQL cluster, the extensions listed in [`pg_extensions`](PARAM#pg_extension) will be installed. The default value for this parameter is:

```yaml
pg_extensions:  # pg extensions to be installed, `${pg_version}` will be replaced
  - pg_repack_${pg_version}* wal2json_${pg_version}* passwordcheck_cracklib_${pg_version}*
  - postgis34_${pg_version}* timescaledb-2-postgresql-${pg_version}* pgvector_${pg_version}*
```


Here, `${pg_version}` is a placeholder that will be replaced with the actual major version number [`pg_version`](PARAM#pg_version) of that PostgreSQL cluster
Therefore, the default configuration will install these extensions:

- `postgis34`: Geospatial database extension
- `timescaledb`: Time-series database extension
- `citus`: Distributed/columnar storage extension
- `pgvector`: Vector database/index extension
- `pg_repack`: Extension for online table bloat processing
- `wal2json`: Extracts changes in JSON format through logical decoding.
- `passwordcheck_cracklib`: Enforce password policy

Please note that not all PostgreSQL major versions offer all of the above extensions, except for 15, the main supported versions by Pigsty. For example, as of 2023-09-15, when PostgreSQL 16 was just released, PG 16 still needs the `pg_repack`, `citus`, and `timescaledb` extensions. In such cases, you should modify the `pg_extensions` parameter in the cluster configuration to remove unsupported extensions.

If you want to enable certain extensions in a target cluster that has not yet been created, you can directly declare them with the parameters:


```yaml
pg-v15:
  hosts: { 10.10.10.10: { pg_seq: 1 ,pg_role: primary } }
  vars:
    pg_cluster: pg-v15
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
      - pg_repack_${pg_version}* wal2json_${pg_version}* passwordcheck_cracklib_${pg_version}*
      - postgis34_${pg_version}* timescaledb-2-postgresql-${pg_version}* pgvector_${pg_version}*
      - pg_cron_${pg_version}*        # <---- new extension: pg_cron
      - apache-age_${pg_version}*     # <---- new extension: apache-age
      - zhparser_${pg_version}*       # <---- new extension: zhparser
```

You can run the `pg_extension` sub-task in [`pgsql.yml`](PGSQL-PLAYBOOK#pgsqlyml) to add extensions to clusters that have already been created.

```bash
./pgsql.yml -l pg-v15 -t pg_extension    # install specified extensions for cluster pg-v15
```

To install **all** available extensions in one pass, you can just specify `pg_extensions: ['*${pg_version}*']`, which is really a bold move.


----------------

### Install Manually

After the PostgreSQL cluster is inited, you can manually install plugins via Ansible or Shell commands. For example, if you want to enable a specific extension on a cluster that has already been initialized:

```bash
cd ~/pigsty;  # enter pigsty home dir and install the apache age extension for the pg-test cluster
ansible pg-test -m yum -b -a 'name=apache-age_15*'     # The extension name usually has a suffix like `_<pgmajorversion>`
```

Most plugins are already included in the yum repository on the infrastructure node and can be installed directly using the yum command. If not included, you can consider downloading from the PGDG upstream source using the `repotrack` command or compiling source code into RPMs for distribution.

After the extension installation, you should be able to see them in the `pg_available_extensions` view of the target database cluster. Next, execute in the database where you want to install the extension:

```sql
CREATE EXTENSION age;          -- install the graph database extension
```



----------------

## Compile Extension

If the extension you want is not included in Pigsty or the official [PGDG](https://download.postgresql.org/pub/repos/yum/) repo, you can compile them into RPMs.

To compile the extension, you need to install `rpmbuild`, `gcc/clang`, and other related `-devel` packages; you also need `pgdg-srpm-macros` to build standard PGDG-style extension RPMs.

The installed 3-node el7-9 building environment [`build.yml`](https://github.com/Vonng/pigsty/blob/master/files/pigsty/full.yml) could be used as a base for compiling extensions.
You can install the dependencies required for compilation in this environment:

```bash
make build check-repo install    # setup building VMs, copy pkg.tgz and init
bin/repo-add infra node,pgsql    # add upstream repo to all 3 infra nodes

# add srpm repo to infra nodes
cat > /etc/yum.repos.d/pgdg-srpm.repo <<-'EOF'
[pgdg-common-srpm]
name = PostgreSQL 15 SRPM $releasever - $basearch
baseurl=https://download.postgresql.org/pub/repos/yum/srpms/common/redhat/rhel-$releasever-x86_64/
gpgcheck = 0
enabled = 1
module_hotfixes=1
EOF

# install compiling tools, build deps and PG major versions
yum groupinstall -y 'Development Tools'
yum install -y pgdg-srpm-macros clang ccache rpm-build rpmdevtools postgresql1*-server flex bison postgresql1*-devel readline-devel zlib-devel lz4-devel libzstd-devel openssl-devel krb5-devel libcurl-devel libxml2-devel CUnit cmake
rpmdev-setuptree
```


For example, here are the instructions for compiling the PostgreSQL `pgsql-http` extension:

Let's add the package specification file to: `/root/rpmbuild/SPECS/pgsql-http.spec`.

<details><summary>Example: RPM SPEC for http extension</summary>

```
%global pname http
%global sname pgsql-http
%global pginstdir /usr/pgsql-%{pgmajorversion}

%ifarch ppc64 ppc64le s390 s390x armv7hl
 %if 0%{?rhel} && 0%{?rhel} == 7
  %{!?llvm:%global llvm 0}
 %else
  %{!?llvm:%global llvm 1}
 %endif
%else
 %{!?llvm:%global llvm 1}
%endif

Name:		%{sname}_%{pgmajorversion}
Version:	1.6.0
Release:	PIGSTY1%{?dist}
Summary:	HNSW algorithm for vector similarity search in PostgreSQL.
License:	MIT
URL:		https://github.com/pramsey/%{sname}
Source0:	https://github.com/pramsey/%{sname}/archive/refs/tags/v%{version}.tar.gz
#           https://github.com/pramsey/pgsql-http/archive/refs/tags/v1.6.0.tar.gz

BuildRequires:	postgresql%{pgmajorversion}-devel pgdg-srpm-macros >= 1.0.27
Requires:	postgresql%{pgmajorversion}-server

%description
Wouldn't it be nice to be able to write a trigger that called a web service? Either to get back a result,
 or to poke that service into refreshing itself against the new state of the database? This extension is for that.


%if %llvm
%package llvmjit
Summary:	Just-in-time compilation support for %{sname}
Requires:	%{name}%{?_isa} = %{version}-%{release}
%if 0%{?rhel} && 0%{?rhel} == 7
%ifarch aarch64
Requires:	llvm-toolset-7.0-llvm >= 7.0.1
%else
Requires:	llvm5.0 >= 5.0
%endif
%endif
%if 0%{?suse_version} >= 1315 && 0%{?suse_version} <= 1499
BuildRequires:	llvm6-devel clang6-devel
Requires:	llvm6
%endif
%if 0%{?suse_version} >= 1500
BuildRequires:	llvm15-devel clang15-devel
Requires:	llvm15
%endif
%if 0%{?fedora} || 0%{?rhel} >= 8
Requires:	llvm => 13.0
%endif

%description llvmjit
This packages provides JIT support for %{sname}
%endif


%prep
%setup -q -n %{sname}-%{version}

%build
PATH=%{pginstdir}/bin:$PATH %{__make} %{?_smp_mflags}

%install
%{__rm} -rf %{buildroot}
PATH=%{pginstdir}/bin:$PATH %{__make} %{?_smp_mflags} install DESTDIR=%{buildroot}

%files
%doc README.md
%{pginstdir}/lib/%{pname}.so
%{pginstdir}/share/extension/%{pname}.control
%{pginstdir}/share/extension/%{pname}*sql
%if %llvm
%files llvmjit
   %{pginstdir}/lib/bitcode/*
%endif

%changelog
* Wed Sep 13 2023 Vonng <rh@vonng.com> - 1.6.0
- Initial RPM release, used by Pigsty <https://pigsty.cc>
```

</details>

You can download the source code package of this extension to `/root/rpmbuild/SOURCES`, and then use the `rpmbuild` command to compile for different PG major versions:


```bash
rpmbuild --define "pgmajorversion 16" -ba ~/rpmbuild/SPECS/pgsql-http.spec;
rpmbuild --define "pgmajorversion 15" -ba ~/rpmbuild/SPECS/pgsql-http.spec;
rpmbuild --define "pgmajorversion 14" -ba ~/rpmbuild/SPECS/pgsql-http.spec;
rpmbuild --define "pgmajorversion 13" -ba ~/rpmbuild/SPECS/pgsql-http.spec;
rpmbuild --define "pgmajorversion 12" -ba ~/rpmbuild/SPECS/pgsql-http.spec;
```

The compilation results will be placed in `/root/rpmbuild/RPMS`.
Move them to the Pigsty local source `/www/pigsty` and execute `./infra.yml -t repo_create` to rebuild the local source.
You can then use the compiled extension RPM package on other hosts.

For more details, please refer to the RPM build documentation, which will not be expanded further.