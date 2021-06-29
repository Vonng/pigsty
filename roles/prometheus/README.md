# Prometheus (ansible role)

* Location: meta node
* Binary Path: `/bin/prometheus`
* Data Directory: `/var/lib/prometheus/data`
* Config Directory: `/etc/prometheus`


## FHS


```bash
#------------------------------------------------------------------------------
# FHS
#------------------------------------------------------------------------------
# /etc/prometheus/
#  ^-----prometheus.yml              # prometheus main config file
#  ^-----alertmanager.yml            # alertmanger main config file
#  ^-----infrastructure.yml          # infrastructure targets definition
#  ^-----@bin                        # util scripts: check,reload,status,new
#  ^-----@rules                      # record & alerting rules definition
#            ^-----@infra-rules      # infrastructure metrics definition
#            ^-----@infra-alert      # infrastructure alert definition
#            ^-----@pgsql-rules      # database metrics definition
#            ^-----@infra-alert      # database alert definition
#  ^-----@targets                    # file based service discovery targets definition
#            ^-----@infra            # infra static targets definition
#            ^-----@pgsql            # pgsql static targets definition
#            ^-----@redis (n/a)      # redis static targets definition (not exists for now)
#
# /data/prometheus                   # prometheus data home
#            ^-----@data             # prometheus data dir(wal,lock,etc...)
#------------------------------------------------------------------------------
```



## TL;DR

**How to reload prometheus configuration**

```bash
ssh meta
sudo su && cd /etc/prometheus
bin/check
bin/reload
```

**How to destroy existing prometheus**

from meta node with ansible playbook

```bash
./infra.yml --tags=prometheus
```

manually

```bash
bin/new
```

## Files

* [`prometheus.yml`](files/prometheus.yml) Major prometheus configuration
* [`alertmanager.yml`](files/alertmanager.yml) Major alertmanager configuration
* [`rules`](files/rules/) Prometheus rules
  * [`pgsql.yml`](files/rules/alert.yaml) postgres record and alert rules 
  * [`node.yaml`](files/rules/node.yml) node record and alert rules


### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
postgres : Check necessary variables exists	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
postgres : Fetch variables via pg_cluster	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
postgres : Set cluster basic facts for hosts	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
postgres : Assert cluster primary singleton	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
postgres : Setup cluster primary ip address	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
postgres : Setup repl upstream for primary	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
postgres : Setup repl upstream for replicas	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
postgres : Debug print instance summary	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
monitor : Register pg-exporter consul service	TAGS: [exporter_register, monitor, pg_exporter_register, pgsql]
monitor : Reload pg-exporter consul service	TAGS: [exporter_register, monitor, pg_exporter_register, pgsql]
monitor : Register pgb-exporter consul service	TAGS: [exporter_register, monitor, node_exporter_register, pgsql]
monitor : Reload pgb-exporter consul service	TAGS: [exporter_register, monitor, node_exporter_register, pgsql]
monitor : Register node-exporter service to consul	TAGS: [exporter_register, monitor, node_exporter_register, pgsql]
monitor : Reload node-exporter consul service	TAGS: [exporter_register, monitor, node_exporter_register, pgsql]
service : Copy haproxy exporter definition	TAGS: [exporter_register, haproxy, haproxy_exporter_register, haproxy_register, pgsql, service]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
---
#------------------------------------------------------------------------------
# Prometheus
#------------------------------------------------------------------------------
prometheus_data_dir: /var/lib/prometheus/data # prometheus data dir
prometheus_options: '--storage.tsdb.retention=30d'
# extra cli-args, refer https://prometheus.io/docs/prometheus/latest/disabled_features/
prometheus_reload: false                      # reload prometheus instead of recreate it
prometheus_sd_method: static                  # service discovery method: static|consul|etcd
prometheus_scrape_interval: 15s               # global scrape & evaluation interval
prometheus_scrape_timeout: 5s                 # scrape timeout
prometheus_sd_interval: 5s                    # service discovery refresh interval

# reference
export_metrics_path: /metrics                 # default metrics path (only for job 'pg')
node_exporter_port: 9100                      # default port for node exporter
pg_exporter_port: 9630                        # default port for pg exporter
pgbouncer_exporter_port: 9631                 # default port for pgbouncer exporter
haproxy_exporter_port: 9101                   # default admin/exporter port
service_registry: consul                      # none | consul | etcd | both
...
```