## Realtime Log Collection

Pigsty have **OPTIONAL** logging collection support based on [loki](https://grafana.com/oss/loki/) and [promtail](https://grafana.com/docs/loki/latest/clients/promtail/)

Since you may have different ideas on how to collect & analyze logs. Loki & promtail are optional and require extra setup


## Download

Normally, the user does not need to worry about downloading the software. Just make sure you have the required binaries in `files/bin`.

Before performing the installation, you need to download the four binaries, loki, promtail, logcli, and loki-canary.

When using the offline installer for `./configure`, the relevant binaries will be extracted automatically, no need to worry about it.

If you do `bin/get_loki` manually, you will download the binaries from the Internet to the `/tmp` directory, and the downloaded binaries will be placed in the `files/bin/` directory.


## Enable

```bash
./infra-loki.yml         # install loki (logging server) on meta node
./pgsql-promtail.yml     # install promtail (logging agent) on pgsql node
```

PGLOG Instance dashboard will be available after loki is installed


## GUI

There are 1 logging related dashboards:

* PGLOG Instance: Query & search raw log (postgres, patroni, pgbouncer) on specific instance (Powered by loki + promtail)
