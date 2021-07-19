## Realtime Log Collection

Pigsty have **OPTIONAL** logging collection support based on [loki](https://grafana.com/oss/loki/) and [promtail](https://grafana.com/docs/loki/latest/clients/promtail/)

Since you may have different ideas on how to collect & analyze logs. Loki & promtail are optional and require extra setup

## GUI

There are 1 logging related dashboards:

* PGLOG Instance: Query & search raw log (postgres, patroni, pgbouncer) on specific instance (Powered by loki + promtail)


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



