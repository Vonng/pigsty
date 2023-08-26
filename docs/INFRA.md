# INFRA

> Pigsty has a battery-included, production-ready INFRA module, to provide ultimate observability.


----------------

## Overview

Each Pigsty deployment requires a set of infrastructure components to work properly. which including:

|    Component     | Port |   Domain   | Description                                |
|:----------------:|:----:|:----------:|--------------------------------------------|
|      Nginx       |  80  | `h.pigsty` | Web Service Portal (Also used as Yum Repo) |
|   AlertManager   | 9093 | `a.pigsty` | Alert Aggregation and delivery             |
|    Prometheus    | 9090 | `p.pigsty` | Monitoring Time Series Database            |
|     Grafana      | 3000 | `g.pigsty` | Visualization Platform                     |
|       Loki       | 3100 |     -      | Logging Collection Server                  |
|   PushGateway    | 9091 |     -      | Collect One-Time Job Metrics               |
| BlackboxExporter | 9115 |     -      | Blackbox Probing                           |
|     Dnsmasq      |  53  |     -      | DNS Server                                 |
|     Chronyd      | 123  |     -      | NTP Time Server                            |
|    PostgreSQL    | 5432 |     -      | Pigsty CMDB & default database             |
|     Ansible      |  -   |     -      | Run playbooks                              |

Pigsty will set up these components for you on infra nodes. You can expose them to the outside world by configuring the [`infra_portal`](PARAM#infra_portal) parameter.

```yaml
infra_portal:  # domain names and upstream servers
  home         : { domain: h.pigsty }
  grafana      : { domain: g.pigsty ,endpoint: "${admin_ip}:3000" , websocket: true }
  prometheus   : { domain: p.pigsty ,endpoint: "${admin_ip}:9090" }
  alertmanager : { domain: a.pigsty ,endpoint: "${admin_ip}:9093" }
  blackbox     : { endpoint: "${admin_ip}:9115" }
  loki         : { endpoint: "${admin_ip}:3100" }
  #minio        : { domain: sss.pigsty  ,endpoint: "${admin_ip}:9001" ,scheme: https ,websocket: true }
```

![pigsty-infra](https://user-images.githubusercontent.com/8587410/206972543-664ae71b-7ed1-4e82-90bd-5aa44c73bca4.gif)




----------------

## Playbooks

- [`install.yml`](https://github.com/vonng/pigsty/blob/master/install.yml)   : Install Pigsty on current node in one-pass
- [`infra.yml`](https://github.com/vonng/pigsty/blob/master/infra.yml)       : Init pigsty infrastructure on infra nodes
- [`infra-rm.yml`](https://github.com/vonng/pigsty/blob/master/infra-rm.yml) : Remove infrastructure components from infra nodes

[![asciicast](https://asciinema.org/a/566412.svg)](https://asciinema.org/a/566412)


----------------

## Dashboards


[Pigsty Home](https://demo.pigsty.cc/d/pigsty) : Home dashboard for pigsty's grafana

<details><summary>Pigsty Home Dashboard</summary>

[![pigsty-home](https://github.com/Vonng/pigsty/assets/8587410/b9679741-5baf-4a89-b6d0-e9eb4a13814d)](https://demo.pigsty.cc/d/pigsty/)

</details>


[INFRA Overview](https://demo.pigsty.cc/d/infra-overview) : Overview of all infra components

<details><summary>INFRA Overview Dashboard</summary>

[![infra-overview](https://github.com/Vonng/pigsty/assets/8587410/d262ceaa-2d73-4817-88e7-1790c77a5498)](https://demo.pigsty.cc/d/infra-overview/)

</details>


[Nginx Overview](https://demo.pigsty.cc/d/nginx-overview) : Nginx metrics & logs

<details><summary>Nginx Overview Dashboard</summary>

[![nginx-overview](https://github.com/Vonng/pigsty/assets/8587410/08bff428-5f2a-4adb-9c96-479da59ccd2a)](https://demo.pigsty.cc/d/nginx-overview)

</details>


[Grafana Overview](https://demo.pigsty.cc/d/grafana-overview): Grafana metrics & logs

<details><summary>Grafana Overview Dashboard</summary>

[![grafana-overview](https://github.com/Vonng/pigsty/assets/8587410/6801fe16-1b47-4c1b-99aa-6af8b07aee4a)](https://demo.pigsty.cc/d/grafana-overview)

</details>


[Prometheus Overview](https://demo.pigsty.cc/d/prometheus-overview): Prometheus metrics & logs

<details><summary>Prometheus Overview Dashboard</summary>

[![prometheus-overview](https://github.com/Vonng/pigsty/assets/8587410/553f2f60-67a8-401d-abef-a58dd52a5bee)](https://demo.pigsty.cc/d/prometheus-overview)

</details>


[Loki Overview](https://demo.pigsty.cc/d/loki-overview): Loki metrics & logs

<details><summary>Loki Overview Dashboard</summary>

[![loki-overview](https://github.com/Vonng/pigsty/assets/8587410/a70a5d3a-bc8d-4fef-9708-4eabdd0436ff)](https://demo.pigsty.cc/d/loki-overview)

</details>


[Logs Instance](https://demo.pigsty.cc/d/logs-instance): Logs for a single instance

<details><summary>Logs Instance Dashboard</summary>

[![logs-instance](https://github.com/Vonng/pigsty/assets/8587410/246eff0e-d47d-4740-99db-20aca4b8ec55)](https://demo.pigsty.cc/d/logs-instance)

</details>


[Logs Overview](https://demo.pigsty.cc/d/logs-overview): Overview of all logs

<details><summary>Logs Overview Dashboard</summary>

[![logs-overview](https://github.com/Vonng/pigsty/assets/8587410/e0a6c0f5-8cb1-4d70-a327-d9fa815e3f27)](https://demo.pigsty.cc/d/logs-overview)

</details>


[CMDB Overview](https://demo.pigsty.cc/d/cmdb-overview): CMDB visualization

<details><summary>CMDB Overview Dashboard</summary>

[![cmdb-overview](https://github.com/Vonng/pigsty/assets/8587410/9e187204-9d8d-4c31-8885-313f00bbc73f)](https://demo.pigsty.cc/d/cmdb-overview)

</details>


[ETCD Overview](https://demo.pigsty.cc/d/etcd-overview): etcd metrics & logs

<details><summary>ETCD Overview Dashboard</summary>

[![etcd-overview](https://github.com/Vonng/pigsty/assets/8587410/3f268146-9242-42e7-b78f-b5b676155f3f)](https://demo.pigsty.cc/d/etcd-overview)

</details>




----------------

## Parameters

API Reference for [`INFRA`](PARAM#INFRA) module:

- [`META`](PARAM#meta): infra meta data
- [`CA`](PARAM#ca): self-signed CA
- [`INFRA_ID`](PARAM#infra_id) : Portals and identity
- [`REPO`](PARAM#repo): local yum repo
- [`INFRA_PACKAGE`](PARAM#infra_package) : packages to be installed
- [`NGINX`](PARAM#nginx) : nginx web server
- [`DNS`](PARAM#dns): dnsmasq nameserver
- [`PROMETHEUS`](PARAM#prometheus) : prometheus, alertmanager, pushgateway & blackbox_exporter  
- [`GRAFANA`](PARAM#grafana) : Grafana, the visualization platform
- [`LOKI`](PARAM#loki) : Loki, the logging server


<details><summary>Parameters</summary>

| Parameter                                                        | Section                                |    Type    | Level | Comment                                            |
|------------------------------------------------------------------|----------------------------------------|:----------:|:-----:|----------------------------------------------------|
| [`version`](PARAM#version)                                       | [`META`](PARAM#meta)                   |   string   |   G   | pigsty version string                              |
| [`admin_ip`](PARAM#admin_ip)                                     | [`META`](PARAM#meta)                   |     ip     |   G   | admin node ip address                              |
| [`region`](PARAM#region)                                         | [`META`](PARAM#meta)                   |    enum    |   G   | upstream mirror region: default,china,europe       |
| [`proxy_env`](PARAM#proxy_env)                                   | [`META`](PARAM#meta)                   |    dict    |   G   | global proxy env when downloading packages         |
| [`ca_method`](PARAM#ca_method)                                   | [`CA`](PARAM#ca)                       |    enum    |   G   | create,recreate,copy, create by default            |
| [`ca_cn`](PARAM#ca_cn)                                           | [`CA`](PARAM#ca)                       |   string   |   G   | ca common name, fixed as pigsty-ca                 |
| [`cert_validity`](PARAM#cert_validity)                           | [`CA`](PARAM#ca)                       |  interval  |   G   | cert validity, 20 years by default                 |
| [`infra_seq`](PARAM#infra_seq)                                   | [`INFRA_ID`](PARAM#infra_id)           |    int     |   I   | infra node identity, REQUIRED                      |
| [`infra_portal`](PARAM#infra_portal)                             | [`INFRA_ID`](PARAM#infra_id)           |    dict    |   G   | infra services exposed via portal                  |
| [`repo_enabled`](PARAM#repo_enabled)                             | [`REPO`](PARAM#repo)                   |    bool    |  G/I  | create a yum repo on this infra node?              |
| [`repo_home`](PARAM#repo_home)                                   | [`REPO`](PARAM#repo)                   |    path    |   G   | repo home dir, `/www` by default                   |
| [`repo_name`](PARAM#repo_name)                                   | [`REPO`](PARAM#repo)                   |   string   |   G   | repo name, pigsty by default                       |
| [`repo_endpoint`](PARAM#repo_endpoint)                           | [`REPO`](PARAM#repo)                   |    url     |   G   | access point to this repo by domain or ip:port     |
| [`repo_remove`](PARAM#repo_remove)                               | [`REPO`](PARAM#repo)                   |    bool    |  G/A  | remove existing upstream repo                      |
| [`repo_modules`](#repo_modules)                                  | [`REPO`](PARAM#repo)                   |   string   |  G/A  | which repo modules are installed in repo_upstream  |
| [`repo_upstream`](PARAM#repo_upstream)                           | [`REPO`](PARAM#repo)                   | upstream[] |   G   | where to download upstream packages                |
| [`repo_packages`](PARAM#repo_packages)                           | [`REPO`](PARAM#repo)                   |  string[]  |   G   | which packages to be included                      |
| [`repo_url_packages`](PARAM#repo_url_packages)                   | [`REPO`](PARAM#repo)                   |  string[]  |   G   | extra packages from url                            |
| [`infra_packages`](PARAM#infra_packages)                         | [`INFRA_PACKAGE`](PARAM#infra_package) |  string[]  |   G   | packages to be installed on infra nodes            |
| [`infra_packages_pip`](PARAM#infra_packages_pip)                 | [`INFRA_PACKAGE`](PARAM#infra_package) |   string   |   G   | pip installed packages for infra nodes             |
| [`nginx_enabled`](PARAM#nginx_enabled)                           | [`NGINX`](PARAM#nginx)                 |    bool    |  G/I  | enable nginx on this infra node?                   |
| [`nginx_exporter_enabled`](PARAM#nginx_exporter_enabled)         | [`NGINX`](PARAM#nginx)                 |    bool    |  G/I  | enable nginx_exporter on this infra node?          |
| [`nginx_sslmode`](PARAM#nginx_sslmode)                           | [`NGINX`](PARAM#nginx)                 |    enum    |   G   | nginx ssl mode? disable,enable,enforce             |
| [`nginx_home`](PARAM#nginx_home)                                 | [`NGINX`](PARAM#nginx)                 |    path    |   G   | nginx content dir, `/www` by default               |
| [`nginx_port`](PARAM#nginx_port)                                 | [`NGINX`](PARAM#nginx)                 |    port    |   G   | nginx listen port, 80 by default                   |
| [`nginx_ssl_port`](PARAM#nginx_ssl_port)                         | [`NGINX`](PARAM#nginx)                 |    port    |   G   | nginx ssl listen port, 443 by default              |
| [`nginx_navbar`](PARAM#nginx_navbar)                             | [`NGINX`](PARAM#nginx)                 |  index[]   |   G   | nginx index page navigation links                  |
| [`dns_enabled`](PARAM#dns_enabled)                               | [`DNS`](PARAM#dns)                     |    bool    |  G/I  | setup dnsmasq on this infra node?                  |
| [`dns_port`](PARAM#dns_port)                                     | [`DNS`](PARAM#dns)                     |    port    |   G   | dns server listen port, 53 by default              |
| [`dns_records`](PARAM#dns_records)                               | [`DNS`](PARAM#dns)                     |  string[]  |   G   | dynamic dns records resolved by dnsmasq            |
| [`prometheus_enabled`](PARAM#prometheus_enabled)                 | [`PROMETHEUS`](PARAM#prometheus)       |    bool    |  G/I  | enable prometheus on this infra node?              |
| [`prometheus_clean`](PARAM#prometheus_clean)                     | [`PROMETHEUS`](PARAM#prometheus)       |    bool    |  G/A  | clean prometheus data during init?                 |
| [`prometheus_data`](PARAM#prometheus_data)                       | [`PROMETHEUS`](PARAM#prometheus)       |    path    |   G   | prometheus data dir, `/data/prometheus` by default |
| [`prometheus_sd_interval`](PARAM#prometheus_sd_interval)         | [`PROMETHEUS`](PARAM#prometheus)       |  interval  |   G   | prometheus target refresh interval, 5s by default  |
| [`prometheus_scrape_interval`](PARAM#prometheus_scrape_interval) | [`PROMETHEUS`](PARAM#prometheus)       |  interval  |   G   | prometheus scrape & eval interval, 10s by default  |
| [`prometheus_scrape_timeout`](PARAM#prometheus_scrape_timeout)   | [`PROMETHEUS`](PARAM#prometheus)       |  interval  |   G   | prometheus global scrape timeout, 8s by default    |
| [`prometheus_options`](PARAM#prometheus_options)                 | [`PROMETHEUS`](PARAM#prometheus)       |    arg     |   G   | prometheus extra server options                    |
| [`pushgateway_enabled`](PARAM#pushgateway_enabled)               | [`PROMETHEUS`](PARAM#prometheus)       |    bool    |  G/I  | setup pushgateway on this infra node?              |
| [`pushgateway_options`](PARAM#pushgateway_options)               | [`PROMETHEUS`](PARAM#prometheus)       |    arg     |   G   | pushgateway extra server options                   |
| [`blackbox_enabled`](PARAM#blackbox_enabled)                     | [`PROMETHEUS`](PARAM#prometheus)       |    bool    |  G/I  | setup blackbox_exporter on this infra node?        |
| [`blackbox_options`](PARAM#blackbox_options)                     | [`PROMETHEUS`](PARAM#prometheus)       |    arg     |   G   | blackbox_exporter extra server options             |
| [`alertmanager_enabled`](PARAM#alertmanager_enabled)             | [`PROMETHEUS`](PARAM#prometheus)       |    bool    |  G/I  | setup alertmanager on this infra node?             |
| [`alertmanager_options`](PARAM#alertmanager_options)             | [`PROMETHEUS`](PARAM#prometheus)       |    arg     |   G   | alertmanager extra server options                  |
| [`exporter_metrics_path`](PARAM#exporter_metrics_path)           | [`PROMETHEUS`](PARAM#prometheus)       |    path    |   G   | exporter metric path, `/metrics` by default        |
| [`exporter_install`](PARAM#exporter_install)                     | [`PROMETHEUS`](PARAM#prometheus)       |    enum    |   G   | how to install exporter? none,yum,binary           |
| [`exporter_repo_url`](PARAM#exporter_repo_url)                   | [`PROMETHEUS`](PARAM#prometheus)       |    url     |   G   | exporter repo file url if install exporter via yum |
| [`grafana_enabled`](PARAM#grafana_enabled)                       | [`GRAFANA`](PARAM#grafana)             |    bool    |  G/I  | enable grafana on this infra node?                 |
| [`grafana_clean`](PARAM#grafana_clean)                           | [`GRAFANA`](PARAM#grafana)             |    bool    |  G/A  | clean grafana data during init?                    |
| [`grafana_admin_username`](PARAM#grafana_admin_username)         | [`GRAFANA`](PARAM#grafana)             |  username  |   G   | grafana admin username, `admin` by default         |
| [`grafana_admin_password`](PARAM#grafana_admin_password)         | [`GRAFANA`](PARAM#grafana)             |  password  |   G   | grafana admin password, `pigsty` by default        |
| [`grafana_plugin_cache`](PARAM#grafana_plugin_cache)             | [`GRAFANA`](PARAM#grafana)             |    path    |   G   | path to grafana plugins cache tarball              |
| [`grafana_plugin_list`](PARAM#grafana_plugin_list)               | [`GRAFANA`](PARAM#grafana)             |  string[]  |   G   | grafana plugins to be downloaded with grafana-cli  |
| [`loki_enabled`](PARAM#loki_enabled)                             | [`LOKI`](PARAM#loki)                   |    bool    |  G/I  | enable loki on this infra node?                    |
| [`loki_clean`](PARAM#loki_clean)                                 | [`LOKI`](PARAM#loki)                   |    bool    |  G/A  | whether remove existing loki data?                 |
| [`loki_data`](PARAM#loki_data)                                   | [`LOKI`](PARAM#loki)                   |    path    |   G   | loki data dir, `/data/loki` by default             |
| [`loki_retention`](PARAM#loki_retention)                         | [`LOKI`](PARAM#loki)                   |  interval  |   G   | loki log retention period, 15d by default          |


</details>
