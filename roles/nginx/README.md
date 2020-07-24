# Nginx (ansible role)

* Update or install nginx
* Upstream proxy for prometheus, grafana, altermanager and etc,...
* Install and activate nginx-exporter
* Register nginx and nginx-exporter to dcs


### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
nginx : Make sure nginx package installed	      TAGS: [meta, nginx]
nginx : Copy nginx upstream conf			      TAGS: [meta, nginx]
nginx : Update default nginx index page		      TAGS: [meta, nginx]
nginx : Restart meta nginx service			      TAGS: [meta, nginx]
nginx : Wait for nginx service online		      TAGS: [meta, nginx]
nginx : Make sure nginx exporter installed	      TAGS: [meta, nginx_exporter]
nginx : Config nginx_exporter options		      TAGS: [meta, nginx_exporter]
nginx : Restart nginx_exporter service		      TAGS: [meta, nginx_exporter]
nginx : Wait for nginx exporter online		      TAGS: [meta, nginx_exporter]
nginx : Register cosnul nginx service		      TAGS: [meta, nginx_register]
nginx : Register consul nginx-exporter service    TAGS: [meta, nginx_register]
nginx : Reload consul					          TAGS: [meta, nginx_register]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
nginx_upstream:
  - {name: consul,        host: c.pigsty, url: http://localhost:8500/}
  - {name: grafana,       host: g.pigsty, url: http://localhost:3000/}
  - {name: prometheus,    host: p.pigsty, url: http://localhost:9090/}
  - {name: alertmanager,  host: a.pigsty, url: http://localhost:9093/}
```