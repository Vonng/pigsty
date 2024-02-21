# DuckDB

[DuckDB](https://duckdb.org/) is a fast in-process analytical database, similar to SQLite, but for analytics.

Pigsty has pre-packed `duckdbcli` (0.10.0), `libduckdb` (0.9.2) and `duckdb_fdw` RPMs, you can just install them via:

```bash
yum install duckdb
```

Notices: these packages are not available for debian / ubuntu yet. 



## Get Started

Check duckdb documentation for more details: https://duckdb.org/docs/guides/index

The [`duckdb_fdw`](https://github.com/alitrack/duckdb_fdw) RPM is available on EL 8 and EL 9. To install it, define it in `pg_extensions` in `pigsty.yml`:

```bash
pg_extensions: # citus & hydra are exclusive
  - postgis34_${pg_version}* timescaledb-2-postgresql-${pg_version}* pgvector_${pg_version}*
  - duckdb_fdw_${pg_version}*   # <-------- add duckdb_fdw here
```

The dependency `libduckdb` will be automatically installed when `duckdb_fdw` is installed.

```sql
CREATE EXTENSION duckdb_fdw;

-- map duckdb file to foreign server 
CREATE SERVER duckdb_server
    FOREIGN DATA WRAPPER duckdb_fdw
    OPTIONS (database '/tmp/duck.db');

-- create foreign table
CREATE FOREIGN TABLE t1 (
    a integer,
    b text
)
SERVER duckdb_server OPTIONS (table 't1_duckdb');
```