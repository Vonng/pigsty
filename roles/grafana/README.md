# Grafana (ansible role)

This role will provision a grafana server
* install and launch grafana
* provision grafana plugins (and use cache if exists)
* provision grafana with sqlitedb


### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
tasks:
  - Make sure grafana is installed			TAGS: [grafana, grafana_install, meta]
  - Check grafana plugin cache exists		TAGS: [grafana, grafana_plugin, meta]
  - Provision grafana plugins via cache		TAGS: [grafana, grafana_plugin, meta]
  - Download grafana plugins from web		TAGS: [grafana, grafana_plugin, meta]
  - Download grafana plugins from web		TAGS: [grafana, grafana_plugin, meta]
  - Create grafana plugins cache			TAGS: [grafana, grafana_plugin, meta]
  - Copy /etc/grafana/grafana.ini			TAGS: [grafana, grafana_config, meta]
  - Copy grafana.db to data dir				TAGS: [grafana, grafana_config, meta]
  - Launch grafana service					TAGS: [grafana, grafana_launch, meta]
  - Wait for grafana online					TAGS: [grafana, grafana_launch, meta]
  - Register consul grafana service			TAGS: [grafana, grafana_register, meta]
  - Reload consul							TAGS: [grafana, grafana_register, meta]
  - Remove grafana dashboard dir			TAGS: [grafana, grafana_provision, meta]
  - Copy grafana dashboards json			TAGS: [grafana, grafana_provision, meta]
  - Preprocess grafana dashboards			TAGS: [grafana, grafana_provision, meta]
  - Provision prometheus datasource			TAGS: [grafana, grafana_provision, meta]
  - Provision grafana dashboards			TAGS: [grafana, grafana_provision, meta]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
grafana_url: http://admin:admin@localhost:3000 # grafana url
grafana_plugin: install                        # none|install|reinstall
grafana_cache: /tmp/plugins.tar.gz             # path to grafana plugins tarball
grafana_provision_mode: db                     # none|db|api

grafana_plugins:                               # default grafana plugins list
  - redis-datasource
  - simpod-json-datasource
  - fifemon-graphql-datasource
  - sbueringer-consul-datasource
  - camptocamp-prometheus-alertmanager-datasource
  - ryantxu-ajax-panel
  - marcusolsson-hourly-heatmap-panel
  - michaeldmoore-multistat-panel
  - marcusolsson-treemap-panel
  - pr0ps-trackmap-panel
  - dalvany-image-panel
  - magnesium-wordcloud-panel
  - cloudspout-button-panel
  - speakyourcode-button-panel
  - jdbranham-diagram-panel
  - grafana-piechart-panel
  - snuids-radar-panel
  - digrich-bubblechart-panel

grafana_git_plugins:
  - https://github.com/Vonng/grafana-echarts

grafana_dashboards: []                        # default dashboards
```