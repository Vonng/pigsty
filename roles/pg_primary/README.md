# Primary (ansible role)

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
#==============================================================#
# DCS settings
#==============================================================#
dcs_type:    consul         # default dcs server type: consul
dcs_check_interval: 15s     # default service check interval (not used)
dcs_check_timeout:  3s      # default service check timeout  (not used)


#==============================================================#
# Meta node packages
#==============================================================#
# download proxy
meta_proxy_env: {}

# install for meta nodes only
meta_package_list:
  - ansible,python,python-pip,python-ipython,python-psycopg2                    # ansible and python environment
  - nginx,haproxy,keepalived,dnsmasq                                            # proxy and dns
  - grafana,prometheus2,pushgateway,alertmanager,node_exporter,nginx_exporter   # monitoring packages

#==============================================================#
# Meta Prometheus
#==============================================================#
#meta_prometheus_retention: 30d
#meta_prometheus_scrape_interval: 2s
#meta_prometheus_evaluation_interval: 2s
#meta_prometheus_scrape_timeout: 1s

#==============================================================#
# Meta Grafana
#==============================================================#
meta_grafana_server: http://grafana.pigsty      # use pre-defined prometheus data source
meta_grafana_force_download_plugins: false      # force redownload grafana plugins
meta_grafana_time_interval: 2s                  # force redownload grafana plugins

meta_grafana_plugins:                           # default grafana plugins
  - simpod-json-datasource
  - camptocamp-prometheus-alertmanager-datasource
  - ryantxu-ajax-panel
  - grafana-piechart-panel
  - jdbranham-diagram-panel
  - aidanmountford-html-panel
  - alexandra-trackmap-panel
  - snuids-radar-panel
  - digrich-bubblechart-panel

meta_grafana_dashboards: []                       # default dashboards



#==============================================================#
# Meta DNS
#==============================================================#
# DNS record that resolved by DNS server on meta node
meta_dynamic_dns:
  - host: 10.10.10.10       # meta service domain name
    domain: [pigsty, consul.pigsty, grafana.pigsty, prometheus.pigsty, alertmanager.pigsty, admin.pigsty, yum.pigsty]
  - host: 10.10.10.10       # short alias
    domain: [c.pigsty, g.pigsty, p.pigsty, pg.pigsty, am.pigsty, ha.pigsty, k8s.pigsty, k.pigsty]
  - host: 10.10.10.2        # pg-meta default vip
    domain: [pg-meta, haproxy.pg-meta]
  - host: 10.10.10.3        # pg-test default vip
    domain: [pg-test, haproxy.pg-meta]
```