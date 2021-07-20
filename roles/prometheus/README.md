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
Install prometheus and alertmanager	TAGS: [infra, prometheus]
Wipe out prometheus config dir	TAGS: [infra, prometheus, prometheus_clean]
Wipe out existing prometheus data	TAGS: [infra, prometheus, prometheus_clean]
Create prometheus directories	TAGS: [infra, prometheus, prometheus_config]
Copy prometheus bin scripts	TAGS: [infra, prometheus, prometheus_config]
Copy prometheus rules	TAGS: [infra, prometheus, prometheus_config, prometheus_rules]
Render prometheus config	TAGS: [infra, prometheus, prometheus_config]
Render altermanager config	TAGS: [infra, prometheus, prometheus_config]
Config /etc/prometheus opts	TAGS: [infra, prometheus, prometheus_config]
Launch prometheus service	TAGS: [infra, prometheus, prometheus_launch]
Wait for prometheus online	TAGS: [infra, prometheus, prometheus_launch]
Launch alertmanager service	TAGS: [infra, prometheus, prometheus_launch]
Wait for alertmanager online	TAGS: [infra, prometheus, prometheus_launch]
Render infra file-sd targets targets for prometheus	TAGS: [infra, prometheus, prometheus_infra_targets]
Reload prometheus service	TAGS: [infra, prometheus, prometheus_reload]
Copy prometheus service definition	TAGS: [infra, prometheus, prometheus_register]
Copy alertmanager service definition	TAGS: [infra, prometheus, prometheus_register]
Reload consul to register prometheus	TAGS: [infra, prometheus, prometheus_register]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
#------------------------------------------------------------------------------
# Prometheus
#------------------------------------------------------------------------------
# - prometheus - #
prometheus_data_dir: /data/prometheus/data    # prometheus data dir
prometheus_options: '--storage.tsdb.retention=30d'
prometheus_reload: false                      # reload prometheus instead of recreate it
prometheus_sd_method: static                  # service discovery method: static|consul|etcd
prometheus_scrape_interval: 10s               # global scrape & evaluation interval
prometheus_scrape_timeout: 8s                 # scrape timeout
prometheus_sd_interval: 10s                   # service discovery refresh interval

# reference
exporter_metrics_path: /metrics                 # default metrics path (only for job 'pg')
node_exporter_port: 9100                      # default port for node exporter
pg_exporter_port: 9630                        # default port for pg exporter
pgbouncer_exporter_port: 9631                 # default port for pgbouncer exporter
haproxy_exporter_port: 9101                   # default admin/exporter port
service_registry: consul                      # none | consul | etcd | both
```