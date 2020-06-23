# Primary (ansible role)

This role will provision a meta node with following tasks:
* Re-init nginx server
* Nginx exporter
* Dnsmasq setup
* Prometheus setup
* Grafana setup


### Tasks

[tasks/main.yml](tasks/main.yml)
* [`check.yml`](check.yml)
* [`clean.yml`](clean.yml)
* [`initdb.yml`](initdb.yml)
* [`bootstrap.yml`](bootstrap.yml)
* [`role.yml`](role.yml)
* [`template.yml`](template.yml)
* [`createdb.yml`](createdb.yml)
* [`register.yml`](register.yml)


```yaml

```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml

```