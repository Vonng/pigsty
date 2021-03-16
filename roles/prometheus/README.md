# Prometheus (ansible role)

* Location: node0 (meta)
* Binary Path: `/bin/prometheus`
* Data Directory: `/var/lib/prometheus/data`
* Config Directory: `/etc/prometheus`

## TL;DR

How to reload prometheus configuration

```bash
ssh node0
sudo su
cd /etc/prometheus

bin/check
bin/reload
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
Install prometheus and alertmanager		  TAGS: [prometheus_install]
Wipe out prometheus config dir			  TAGS: [prometheus_clean]
Wipe out existing prometheus data		  TAGS: [prometheus_clean]
Recreate prometheus data dir			  TAGS: [prometheus_config]
Copy /etc/prometheus configs			  TAGS: [prometheus_config]
Copy /etc/prometheus opts				  TAGS: [prometheus_config]
Overwrite prometheus scrape_interval	  TAGS: [prometheus_config]
Overwrite prometheus evaluation_interval  TAGS: [prometheus_config]
Overwrite prometheus scrape_timeout		  TAGS: [prometheus_config]
Overwrite prometheus pg metrics path	  TAGS: [prometheus_config]
Launch prometheus service				  TAGS: [prometheus_launch]
Launch alertmanager service				  TAGS: [prometheus_launch]
Wait for prometheus online				  TAGS: [prometheus_launch]
Wait for alertmanager online			  TAGS: [prometheus_launch]
Copy prometheus service definition		  TAGS: [prometheus_register]
Copy alertmanager service definition	  TAGS: [prometheus_register]
Reload consul to register prometheus	  TAGS: [prometheus_register]
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
prometheus_reload: false                      # reload prometheus instead of recreate it
prometheus_sd_method: consul                  # service discovery method: static|consul|etcd
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