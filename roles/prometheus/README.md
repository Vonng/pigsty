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
#            ^-----@infra.yml        # infrastructure metrics & alert rules
#            ^-----@nodes.yml        # common nodes metrics & alert rules
#            ^-----@pgsql.yml        # postgres metrics & alert rules
#            ^-----@redis.yml        # redis metrics & alert rules
#  ^-----@targets                    # file based service discovery targets definition
#            ^-----@infra/*.yml      # infra static targets definition
#            ^-----@nodes/*.yml      # pgsql static targets definition
#            ^-----@pgsql/*.yml      # pgsql static targets definition
#            ^-----@redis/*.yml      # redis static targets definition
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
  * [`infra.yml`](files/rules/infra.yml) infra record and alert rules 
  * [`nodes.yml`](files/rules/nodes.yml) nodes record and alert rules
  * [`pgsql.yml`](files/rules/pgsql.yml) pgsql record and alert rules
  * [`redis.yml`](files/rules/redis.yml) redis record and alert rules

### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Install prometheus and alertmanager	TAGS: [infra-svcs, prometheus]
Wipe out prometheus config dir	TAGS: [infra-svcs, prometheus, prometheus_clean]
Wipe out existing prometheus data	TAGS: [infra-svcs, prometheus, prometheus_clean]
Create prometheus directories	TAGS: [infra-svcs, prometheus, prometheus_config]
Copy prometheus bin scripts	TAGS: [infra-svcs, prometheus, prometheus_config]
Copy prometheus rules	TAGS: [infra-svcs, prometheus, prometheus_config, prometheus_rules]
Render prometheus config	TAGS: [infra-svcs, prometheus, prometheus_conf, prometheus_config]
Render altermanager config	TAGS: [infra-svcs, prometheus, prometheus_config]
Config /etc/prometheus opts	TAGS: [infra-svcs, prometheus, prometheus_config]
Launch prometheus service	TAGS: [infra-svcs, prometheus, prometheus_launch]
Wait for prometheus online	TAGS: [infra-svcs, prometheus, prometheus_launch]
Launch alertmanager service	TAGS: [infra-svcs, prometheus, prometheus_launch]
Wait for alertmanager online	TAGS: [infra-svcs, prometheus, prometheus_launch]
Render infra file-sd targets targets for prometheus	TAGS: [infra-svcs, prometheus, prometheus_infra_targets]
Reload prometheus service	TAGS: [infra-svcs, prometheus, prometheus_reload]
Copy prometheus service definition	TAGS: [infra-svcs, prometheus, prometheus_register]
Copy alertmanager service definition	TAGS: [infra-svcs, prometheus, prometheus_register]
Reload consul to register prometheus	TAGS: [infra-svcs, prometheus, prometheus_register]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
#-----------------------------------------------------------------
# PROMETHEUS
#-----------------------------------------------------------------
prometheus_data_dir: /data/prometheus/data
prometheus_options: '--storage.tsdb.retention=15d --enable-feature=promql-negative-offset'
prometheus_reload: false        # reload prometheus instead of recreate it?
prometheus_sd_method: static    # service discovery method: static|consul
prometheus_scrape_interval: 10s # global scrape & evaluation interval
prometheus_scrape_timeout: 8s   # scrape timeout
prometheus_sd_interval: 10s     # service discovery refresh interval

#-----------------------------------------------------------------
# EXPORTER (Reference)
#-----------------------------------------------------------------
exporter_metrics_path: /metrics  # default metric path for pg related exporter
#-----------------------------------------------------------------
# NODE_EXPORTER (Reference)
#-----------------------------------------------------------------
node_exporter_port: 9100         # default port for node exporter
#-----------------------------------------------------------------
# PG_EXPORTER (Reference)
#-----------------------------------------------------------------
pg_exporter_port: 9630           # pg_exporter listen port
pgbouncer_exporter_port: 9631    # pgbouncer_exporter listen port
#-----------------------------------------------------------------
# PG_SERVICE (Reference)
#-----------------------------------------------------------------
haproxy_exporter_port: 9101                   # default admin/exporter port
#-----------------------------------------------------------------
# DCS (Reference)
#-----------------------------------------------------------------
dcs_registry: consul        # where to register services: none | consul | etcd | both
```