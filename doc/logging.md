# Logging

There are 3 logging related dashboards:

* PGLOG Instance: Query & search raw log (postgres, patroni, pgbouncer) on specific instance (Powered by loki + promtail) 
* PGLOG Analysis: Analysis csvlog sample on CMDB (focusing on **entire** log sample)
* PGLOG Session: Analysis csvlog sample (focusing on single **session**)


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



## Realtime Log Collection

Pigsty have **OPTIONAL** logging collection support based on [loki](https://grafana.com/oss/loki/) and [promtail](https://grafana.com/docs/loki/latest/clients/promtail/)

Since you may have different ideas on how to collect & analyze logs. Loki & promtail are optional and require extra setup

## Install Loki & Promtail

```bash
./infra-loki.yml         # install loki (logging server) on meta node
./pgsql-promtail.yml     # install promtail (logging agent) on pgsql node
```

PGLOG Instance dashboard will be available after loki is installed


## Download Loki

loki, promtail, logcli, loki-canary are included in default pkg.tgz. They will be extracted to `files/bin/` during `configure`

If you want to download loki , use:

```bash
bin/get_loki
```

It will download loki binaries (`loki,promtail,logcli,loki-canary`) to `/tmp` 



