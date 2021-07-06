# Grafana (ansible role)

This role will provision a grafana server
* install and launch grafana
* provision grafana plugins (and use cache if exists)
* provision grafana with sqlite or postgres
* setup grafana provisioning configuration


### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
grafana : Make sure grafana installed	TAGS: [grafana, grafana_install, infra]
grafana : Stop grafana service	TAGS: [grafana, grafana_stop, infra]
grafana : Check grafana plugin cache exists	TAGS: [grafana, grafana_plugins, infra]
grafana : Provision grafana plugins via cache if exists	TAGS: [grafana, grafana_plugins, grafana_plugins_unzip, infra]
grafana : Download grafana plugins via internet	TAGS: [grafana, grafana_plugins, infra]
grafana : Download grafana plugins via git	TAGS: [grafana, grafana_plugins, infra]
grafana : Remove grafana provisioning config	TAGS: [grafana, grafana_config, infra]
grafana : Remake grafana resource dir	TAGS: [grafana, grafana_config, infra]
grafana : Templating /etc/grafana/grafana.ini	TAGS: [grafana, grafana_config, infra]
grafana : Templating datasources provisioning config	TAGS: [grafana, grafana_config, infra]
grafana : Templating dashboards provisioning config	TAGS: [grafana, grafana_config, infra]
grafana : Copy pigsty home dashboard	TAGS: [grafana, grafana_config, infra]
grafana : Launch grafana service	TAGS: [grafana, grafana_launch, infra]
grafana : Wait for grafana online	TAGS: [grafana, grafana_launch, infra]
grafana : Update grafana default organization	TAGS: [grafana, grafana_provision, infra]
grafana : Register consul grafana service	TAGS: [grafana, grafana_register, infra]
grafana : Reload consul	TAGS: [grafana, grafana_register, infra]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
---
#------------------------------------------------------------------------------
# Grafana
#------------------------------------------------------------------------------
# - grafana - #
grafana_endpoint: http://10.10.10.10:3000             # grafana endpoint url
grafana_admin_username: admin                         # default grafana admin username
grafana_admin_password: pigsty                        # default grafana admin password
grafana_database: sqlite3                             # default grafana database type: sqlite3|postgres, sqlite3 by default
# if postgres is used, url must be specified. The user is pre-defined in pg-meta.pg_users
grafana_pgurl: postgres://dbuser_grafana:DBUser.Grafana@10.10.10.10:5436/grafana
grafana_plugin: install                               # none|install, none will skip plugin installation
grafana_cache: /www/pigsty/plugins.tgz                # path to grafana plugins cache tarball
grafana_plugins: []                                   # plugins that will be downloaded via grafana-cli
grafana_git_plugins: []                               # plugins that will be downloaded via git
#  - https://github.com/Vonng/grafana-echarts

# - reference - #
service_registry: consul                              # none | consul | etcd | both
...
```