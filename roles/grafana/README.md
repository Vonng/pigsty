# Grafana (ansible role)

This role will provision a grafana server
* install and launch grafana
* provision grafana plugins (and use cache if exists)
* provision grafana with sqlite or postgres
* setup grafana provisioning configuration


### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Make sure grafana installed	TAGS: [grafana, grafana_install, infra-svcs]
Stop grafana service	TAGS: [grafana, grafana_stop, infra-svcs]
Check grafana plugin cache exists	TAGS: [grafana, grafana_plugins, infra-svcs]
Provision grafana plugins via cache if exists	TAGS: [grafana, grafana_plugins, grafana_plugins_unzip, infra-svcs]
Download grafana plugins via internet	TAGS: [grafana, grafana_plugins, infra-svcs]
Download grafana plugins via git	TAGS: [grafana, grafana_plugins, infra-svcs]
Remove grafana provisioning config	TAGS: [grafana, grafana_config, infra-svcs]
Remake grafana resource dir	TAGS: [grafana, grafana_config, infra-svcs]
Templating /etc/grafana/grafana.ini	TAGS: [grafana, grafana_config, infra-svcs]
Templating datasources provisioning config	TAGS: [grafana, grafana_config, infra-svcs]
Templating dashboards provisioning config	TAGS: [grafana, grafana_config, infra-svcs]
Launch grafana service	TAGS: [grafana, grafana_launch, infra-svcs]
Wait for grafana online	TAGS: [grafana, grafana_launch, infra-svcs]
Sync grafana home and core dashboards	TAGS: [dashboard, dashboard_sync, grafana, grafana_provision, infra-svcs]
Provisioning grafana with grafana.py	TAGS: [dashboard, dashboard_init, grafana, grafana_provision, infra-svcs]
Register consul grafana service	TAGS: [grafana, grafana_register, infra-svcs]
Reload consul	TAGS: [grafana, grafana_register, infra-svcs]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
---
#-----------------------------------------------------------------
# GRAFANA
#-----------------------------------------------------------------
grafana_endpoint: http://10.10.10.10:3000     # grafana endpoint url
grafana_admin_username: admin   # default grafana admin username
grafana_admin_password: pigsty  # default grafana admin password
grafana_database: sqlite3       # default grafana database type: sqlite3|postgres
grafana_pgurl: postgres://dbuser_grafana:DBUser.Grafana@meta:5436/grafana
grafana_plugin: install         # none|install, none will skip plugin installation
grafana_cache: /www/pigsty/plugins.tgz # path to grafana plugins cache tarball
grafana_plugins: [ ]            # plugins that will be downloaded via grafana-cli
grafana_git_plugins: [ ]        # plugins that will be downloaded via git

#-----------------------------------------------------------------
# DCS (Reference)
#-----------------------------------------------------------------
dcs_registry: consul        # none | consul | etcd | both
```


## How to interact with grafana ?

### Alias

```bash
# http://g.pigsty/api
alias gfget="curl -u 'admin:pigsty' -H 'Content-Type: application/json' -X GET"
alias gfput="curl -u 'admin:pigsty' -H 'Content-Type: application/json' -X PUT"
alias gfdel="curl -u 'admin:pigsty' -H 'Content-Type: application/json' -X DELETE"
alias gfpost="curl -u 'admin:pigsty' -H 'Content-Type: application/json' -X POST"
alias gfpatch="curl -u 'admin:pigsty' -H 'Content-Type: application/json' -X PATCH"

gfget http://g.pigsty/api
gfput http://g.pigsty/api
gfdel http://g.pigsty/api
gfpost http://g.pigsty/api
gfpatch http://g.pigsty/api
```

### Curl Command


```bash
curl -u 'admin:pigsty' -H 'Content-Type: application/json'  -X GET   http://g.pigsty/api/dashboards/uid/home
```


```bash
# Get Organization
curl -u 'admin:pigsty' -H 'Content-Type: application/json'  -X GET   http://g.pigsty/api/org/
# {"id":1,"name":"Main Org.","address":{"address1":"","address2":"","city":"","zipCode":"","state":"","country":""}}

# Update Organization Name
curl -u 'admin:pigsty' -H 'Content-Type: application/json'  -X PUT   http://g.pigsty/api/orgs/1    -d '{"name": "Pigsty"}'
# {"message":"Organization updated"}

# Search Dashboard by Name
curl -u 'admin:pigsty' -H 'Content-Type: application/json'  -X GET   http://g.pigsty/api/dashboards/uid/home
GRAFANA_HOME_ID=$(curl -u 'admin:pigsty' -H 'Content-Type: application/json' -sSL -X GET   http://g.pigsty/api/dashboards/uid/home | jq '.dashboard.id')

# Star the home dashboard 
curl -u 'admin:pigsty' -H 'Content-Type: application/json'  -X POST  "http://g.pigsty/api/user/stars/dashboard/${GRAFANA_HOME_ID}"

# Update preference
GRAFANA_PREF='{"theme":"light","homeDashboardId":'${GRAFANA_HOME_ID}'}'
curl -u 'admin:pigsty' -H 'Content-Type: application/json'  -X PUT "http://g.pigsty/api/org/preferences" -d ${GRAFANA_PREF}
curl -u 'admin:pigsty' -H 'Content-Type: application/json'  -X PUT "http://g.pigsty/api/user/preferences" -d ${GRAFANA_PREF}

# Create folder pgsql pglog pgcat
curl -u 'admin:pigsty' -H 'Content-Type: application/json'  -X POST  "http://g.pigsty/api/folders/" -d '{"uid": "pgsql", "title": "PGSQL"}'
curl -u 'admin:pigsty' -H 'Content-Type: application/json'  -X POST  "http://g.pigsty/api/folders/" -d '{"uid": "pglog", "title": "PGLOG"}'
curl -u 'admin:pigsty' -H 'Content-Type: application/json'  -X POST  "http://g.pigsty/api/folders/" -d '{"uid": "pgcat", "title": "PGCAT"}'

```