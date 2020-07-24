# Meta (ansible role)

This role will provision a meta node with following tasks:
* Re-init nginx server
* Nginx exporter
* Dnsmasq setup
* Prometheus setup
* Grafana setup


### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
tasks:
  meta : Install meta packages from yum     TAGS: [init-meta]
  meta : Make sure nginx package installed  TAGS: [init-meta, meta_nginx]
  meta : Copy additional nginx proxy conf   TAGS: [init-meta, meta_nginx]
  meta : Update default nginx index page    TAGS: [init-meta, meta_nginx]
  meta : Restart pigsty nginx service       TAGS: [init-meta, meta_nginx]
  meta : Wait for nginx service online      TAGS: [init-meta, meta_nginx]
  meta : Config nginx_exporter options      TAGS: [init-meta, meta_nginx_exporter]
  meta : Restart nginx_exporter service     TAGS: [init-meta, meta_nginx_exporter]
  meta : Wait for nginx exporter online     TAGS: [init-meta, meta_nginx_exporter]
  meta : Copy dnsmasq /etc/dnsmasq.d/config TAGS: [init-meta, meta_dns]
  meta : Add dynamic dns records to meta    TAGS: [init-meta, meta_dns]
  meta : Launch meta dnsmasq service        TAGS: [init-meta, meta_dns]
  meta : Wait for meta dnsmasq online       TAGS: [init-meta, meta_dns]
  meta : Wipe out prometheus config dir     TAGS: [init-meta, meta_prometheus]
  meta : Wipe out existing prometheus data  TAGS: [init-meta, meta_prometheus]
  meta : Recreate prometheus data dir       TAGS: [init-meta, meta_prometheus]
  meta : Copy /etc/prometheus configs       TAGS: [init-meta, meta_prometheus]
  meta : Launch meta prometheus service     TAGS: [init-meta, meta_prometheus]
  meta : Launch meta alertmanager service   TAGS: [init-meta, meta_prometheus]
  meta : Wait for meta prometheus online    TAGS: [init-meta, meta_prometheus]
  meta : Wait for meta alertmanager online  TAGS: [init-meta, meta_prometheus]
  meta : Make sure grafana is installed     TAGS: [grafana_install, init-meta]
  meta : Check grafana plugin cache exists  TAGS: [grafana_install, init-meta]
  meta : Download grafana plugins from web  TAGS: [grafana_install, init-meta]
  meta : Create grafana plugins cache       TAGS: [grafana_install, init-meta]
  meta : Provision grafana plugin via cache TAGS: [grafana_install, init-meta]
  meta : Copy /etc/grafana/grafana.ini      TAGS: [grafana_install, init-meta]
  meta : Launch meta grafana service        TAGS: [grafana_install, init-meta]
  meta : Wait for meta grafana online       TAGS: [grafana_install, init-meta]
  meta : Remove grafana dashboard dir       TAGS: [grafana_provision, init-meta]
  meta : Copy grafana dashboards json       TAGS: [grafana_provision, init-meta]
  meta : Preprocess grafana dashboards      TAGS: [grafana_provision, init-meta]
  meta : Provision prometheus datasource    TAGS: [grafana_provision, init-meta]
  meta : Provision grafana dashboards       TAGS: [grafana_provision, init-meta]
  meta : Copy meta service definition       TAGS: [init-meta, meta_register]
  meta : Reload consul to register service  TAGS: [init-meta, meta_register]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
prometheus_scrape_interval: 15s               # global scrape & evaluation interval
prometheus_scrape_timeout: 5s                 # scrape timeout
prometheus_metrics_path: /metrics             # default metrics path (only for job 'pg')
prometheus_data_dir: /var/lib/prometheus/data # prometheus data dir
prometheus_retention: 90d                     # how long to keep

# - reference : dcs metadata - #
dcs_type: consul                  # default dcs server type: consul
consul_check_interval: 15s        # default service check interval
consul_check_timeout:  1s         # default service check timeout
```