## PGLOG csvlog sample analysis

PGLOG Analysis & PGLOG Session provide introspection about PostgreSQL csvlog sample (via table `pglog.sample` on cmdb)
  * [PGLOG Analysis](http://g.pigsty.cc/pglog-analysis): Analysis csvlog sample on CMDB (focusing on **entire** log sample)
  * [PGLOG Session](http://g.pigsty.cc/pglog-session): Analysis csvlog sample (focusing on single **session**)


There are some handy alias & func set on meta node:

Load csvlog from stdin into sample table:
```bash
alias pglog="psql service=meta -AXtwc 'TRUNCATE pglog.sample; COPY pglog.sample FROM STDIN CSV;'"  # useful alias
```

Get log from pgsql node

```bash
# default: get pgsql csvlog (localhost @ today) 
function catlog(){ # getlog <ip|host> <date:YYYY-MM-DD>
    local node=${1-'127.0.0.1'}
    local today=$(date '+%Y-%m-%d')
    local ds=${2-${today}}
    ssh -t "${node}" "sudo cat /pg/data/log/postgresql-${ds}.csv"
}
```

Combine theme to fetch and load csvlog sample

```bash
catlog | pglog                       # get local (metadb) today's log
catlog node-1 '2021-07-15' | pglog   # get node-1's csvlog @ 2021-07-15 
```

