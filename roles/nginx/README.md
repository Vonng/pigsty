# Nginx (ansible role)

* Update or install nginx
* Upstream proxy for prometheus, grafana, altermanager and etc,...
* Install and activate nginx-exporter
* Register nginx and nginx-exporter to dcs


### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Make sure nginx package installed	      TAGS: [nginx]
Copy nginx upstream conf			      TAGS: [nginx]
Update default nginx index page		      TAGS: [nginx]
Restart meta nginx service			      TAGS: [nginx]
Wait for nginx service online		      TAGS: [nginx]
Make sure nginx exporter installed	      TAGS: [nginx_exporter]
Config nginx_exporter options		      TAGS: [nginx_exporter]
Restart nginx_exporter service		      TAGS: [nginx_exporter]
Wait for nginx exporter online		      TAGS: [nginx_exporter]
Register cosnul nginx service		      TAGS: [nginx_register]
Register consul nginx-exporter service    TAGS: [nginx_register]
Reload consul					          TAGS: [nginx_register]
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