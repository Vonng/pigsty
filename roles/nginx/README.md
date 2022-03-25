# Nginx (ansible role)

* Update or install nginx
* Upstream proxy for prometheus, grafana, altermanager and etc,...
* Render home page with app_list
* Install and activate nginx-exporter
* Register nginx and nginx-exporter to dcs


### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Make sure nginx installed	TAGS: [infra-svcs, nginx, nginx_install]
Create local html directory	TAGS: [infra-svcs, nginx, nginx_dir, nginx_index]
Copy pigsty logo file	TAGS: [infra-svcs, nginx, nginx_dir, nginx_index]
Render default nginx home page	TAGS: [infra-svcs, nginx, nginx_home, nginx_index]
Create nginx haproxy config dir	TAGS: [infra-svcs, nginx, nginx_config]
Copy nginx default config	TAGS: [infra-svcs, nginx, nginx_config]
Copy nginx upstream conf	TAGS: [infra-svcs, nginx, nginx_config]
Create docs tarball	TAGS: [infra-svcs, nginx, nginx_docs]
Copy pigsty docs to /tmp	TAGS: [infra-svcs, nginx, nginx_docs]
Extract pigsty docs to repo home	TAGS: [infra-svcs, nginx, nginx_docs]
Extract pev2 resource to repo home	TAGS: [infra-svcs, nginx, nginx_pev2]
Restart meta nginx service	TAGS: [infra-svcs, nginx, nginx_restart]
Wait for nginx service online	TAGS: [infra-svcs, nginx, nginx_restart]
Make sure nginx exporter installed	TAGS: [infra-svcs, nginx, nginx_exporter]
Config nginx_exporter options	TAGS: [infra-svcs, nginx, nginx_exporter]
Restart nginx_exporter service	TAGS: [infra-svcs, nginx, nginx_exporter]
Wait for nginx exporter online	TAGS: [infra-svcs, nginx, nginx_exporter]
Register cosnul nginx service	TAGS: [infra-svcs, nginx, nginx_register]
Register consul nginx-exporter service	TAGS: [infra-svcs, nginx, nginx_register]
Reload consul	TAGS: [infra-svcs, nginx, nginx_register]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
#-----------------------------------------------------------------
# NGINX
#-----------------------------------------------------------------
nginx_upstream:                  # domain names and upstream servers
  - { name: home,         domain: pigsty,     endpoint: "10.10.10.10:80" }
  - { name: grafana,      domain: g.pigsty,   endpoint: "10.10.10.10:3000" }
  - { name: loki,         domain: l.pigsty,   endpoint: "10.10.10.10:3100" }
  - { name: prometheus,   domain: p.pigsty,   endpoint: "10.10.10.10:9090" }
  - { name: alertmanager, domain: a.pigsty,   endpoint: "10.10.10.10:9093" }
  - { name: consul,       domain: c.pigsty,   endpoint: "127.0.0.1:8500" }
  - { name: pgweb,        domain: cli.pigsty, endpoint: "127.0.0.1:8081" }
  - { name: jupyter,      domain: lab.pigsty, endpoint: "127.0.0.1:8888" }
app_list:                            # application nav links on home page
  - { name: Pev2    , url : '/pev2'        , comment: 'postgres explain visualizer 2' }
  - { name: Logs    , url : '/logs'        , comment: 'realtime pgbadger log sample' }
  - { name: Report  , url : '/report'      , comment: 'daily log summary report ' }
  - { name: Pkgs    , url : '/pigsty'      , comment: 'local yum repo packages' }
  - { name: Repo    , url : '/pigsty.repo' , comment: 'local yum repo file' }
  - { name: ISD     , url : '${grafana}/d/isd-overview'   , comment: 'noaa isd data visualization' }
  - { name: Covid   , url : '${grafana}/d/covid-overview' , comment: 'covid data visualization' }
  - { name: Applog  , url : '${grafana}/d/applog-overview', comment: 'apple privacy log analysis' }
docs_enabled: true              # setup local document under nginx?
pev2_enabled: true              # setup pev2 query visualizer under nginx?
pgbadger_enabled: true          # setup pgbadger under nginx?
```