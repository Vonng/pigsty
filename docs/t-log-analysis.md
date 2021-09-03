# PGLOG Analysis CSV Log Analysis

Pigsty provides a practical application for analyzing PG CSV log samples (PG 13+). It can be used to finely analyze failure site logs, slow query logs.

The CSV log format of > PostgreSQL 13 has changed to add a new `backend_type` field. For access to older versions of PostgreSQL CSV logs, please adjust the `pglog.sample` table definition (e.g. via `ALTER TABLE DROP COLUMN`)



## Graphical interface

You can access the following link to view a sample log analysis interface.

* [PGLOG Analysis](http://demo.pigsty.cc/d/pglog-analysis): Presents the entire sample CSV log details, aggregated by multiple dimensions.
* [PGLOG Session](http://demo.pigsty.cc/d/pglog-session): presents the details of one specific connection in the log sample.



## Usage

PGLOG uses the `pglog.sample` table in MetaDB as the data source, you just need to fill the logs into this table and then access the Dashboard.
Pigsty provides some handy commands for pulling csv logs and pouring them into the sample table.



### `pglog`

The `pglog` command reads CSV logs from stdin and pours them into the sample table

```bash
alias pglog="psql service=meta -AXtwc 'TRUNCATE pglog.sample; COPY pglog.sample FROM STDIN CSV;'" # useful alias
```

For example, suppose you have a ``postgresql-Tue.csv`` log, then you can use the following

```bash
postgresql-Tue.csv | pglog
```

to pour it into the analysis sample table.

### `catlog`

The ``catlog`` command pulls CSV database logs from a specific node for a specific date and writes them to ``stdout`

```bash
### default: get pgsql csvlog (localhost @ today) 
function catlog(){ # getlog <ip|host> <date:YYYY-MM-DD>
    local node=${1-'127.0.0.1'}
    local today=$(date '+%Y-%m-%d')
    local ds=${2-${today}}
    ssh -t "${node}" "sudo cat /pg/data/log/postgresql-${ds}.csv"
}
```

By default, `catlog` pulls the logs for the current node for the current day, you can specify the node with the date via the parameter.

### Shortcuts

Use a combination of `pglog` and `catlog` to quickly pull database CSV logs for analysis.

```bash
catlog | pglog # Analyze the current node's logs for the current day
catlog node-1 '2021-07-15' | pglog # Analyze node-1's csvlog on 2021-07-15
```

