# Grafana (ansible role)

This role will provision a grafana server
* install and launch grafana
* provision grafana plugins (and use cache if exists)
* provision grafana with sqlitedb


### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Make sure grafana is installed	  	TAGS: [grafana_install]
Check grafana plugin cache exists	TAGS: [grafana_install]
Provision grafana plugin via cache  TAGS: [grafana_install]
Download grafana plugins from web	TAGS: [grafana_install]
Create grafana plugins cache		TAGS: [grafana_install]
Copy /etc/grafana/grafana.ini		TAGS: [grafana_install]
Launch grafana service			  	TAGS: [grafana_install]
Wait for grafana online			  	TAGS: [grafana_install]
Register consul grafana service	  	TAGS: [grafana_install]
Reload consul						TAGS: [grafana_install]
Launch meta grafana service		  	TAGS: [grafana_provision]
Copy grafana.db to data dir		  	TAGS: [grafana_provision]
Restart meta grafana service		TAGS: [grafana_provision]
Wait for meta grafana online		TAGS: [grafana_provision]
Remove grafana dashboard dir		TAGS: [grafana_provision]
Copy grafana dashboards json		TAGS: [grafana_provision]
Preprocess grafana dashboards		TAGS: [grafana_provision]
Provision prometheus datasource	  	TAGS: [grafana_provision]
Provision grafana dashboards		TAGS: [grafana_provision]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
grafana_force_download_plugins: false         # force redownload grafana plugins
grafana_time_interval: 2s                     # force redownload grafana plugins
grafana_provision_via_db: true                # provision via copy sqlite db by default
grafana_dashboards: []                        # default dashboards
grafana_plugins_install:                      # install grafana plugins ?
grafana_plugins_force_download:               # force re-download grafana plugins ?
grafana_plugins:                              # default grafana plugins list
  - camptocamp-prometheus-alertmanager-datasource
  - simpod-json-datasource
  - ryantxu-ajax-panel
  - jdbranham-diagram-panel

# - reference : dcs metadata - #
dcs_type: consul                  # default dcs server type: consul
consul_check_interval: 15s        # default service check interval
consul_check_timeout:  1s         # default service check timeout
```