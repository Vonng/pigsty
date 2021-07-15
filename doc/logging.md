# Logging

There are 3 logging related dashboards:

* PGLOG Instance: Query & search raw log (postgres, patroni, pgbouncer) on specific instance (Powered by loki + promtail) 
* PGLOG Analysis: Analysis csvlog sample on CMDB (focusing on entire log)
* PGLOG Analysis: Analysis csvlog sample (focusing on single session)



## Loki + Promtail

Pigsty have OPTIONAL logging support: based on [loki](https://grafana.com/oss/loki/) and [promtail](https://grafana.com/docs/loki/latest/clients/promtail/)

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




## csvlog sample analysis

PGLOG Analysis & PGLOG Session provide introspection about PostgreSQL csvlog sample (in table `pigsty.csvlog`)

To load your log sample, use `bin/load_log` script.

```bash
bin/load_log  <path_to_csvlog>
```

Or, just feed `pigsty.csvlog` with copy.

Example: copy pg-meta 20210715 csvlog file into sample table:

```bash
sudo cat /pg/data/log/postgresql-2021-07-15.csv | psql -c 'TRUNCATE pigsty.csvlog; COPY pigsty.csvlog FROM STDIN CSV;'
```