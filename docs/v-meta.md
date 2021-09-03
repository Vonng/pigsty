# Meta Node Infrastructure

This section describes config entries about [infrastructure](c-arch.md#infrastructure) deployed on [meta node](c-arch.md#meta-node).

## Overview

|                            Name                             |    Type    | Level  | Description |
| :----------------------------------------------------------: | :--------: | :---: | ---- |
|                [ca_method](#ca_method)                |  `enum`  |  G  | ca mode |
|               [ca_subject](#ca_subject)               |  `string`  |  G  | ca subject |
|               [ca_homedir](#ca_homedir)               |  `string`  |  G  | ca cert home dir |
|                  [ca_cert](#ca_cert)                  |  `string`  |  G  | ca cert file name |
|                   [ca_key](#ca_key)                   |  `string`  |  G  | ca private key name |
|           [nginx_upstream](#nginx_upstream)           |  `object[]`  |  G  | nginx upstream definition |
|              [dns_records](#dns_records)              |  `string[]`  |  G  | dynamic DNS records |
|      [prometheus_data_dir](#prometheus_data_dir)      |  `string`  |  G  | prometheus data dir |
|       [prometheus_options](#prometheus_options)       |  `string`  |  G  | prometheus cli args |
|        [prometheus_reload](#prometheus_reload)        |  `bool`  |  A  | prom reload instead of init |
|     [prometheus_sd_method](#prometheus_sd_method)     |  `enum`  |  G  | service discovery method: static\|consul |
| [prometheus_scrape_interval](#prometheus_scrape_interval) |  `interval`  |  G  | prom scrape interval (10s) |
| [prometheus_scrape_timeout](#prometheus_scrape_timeout) |  `interval`  |  G  | prom scrape timeout (8s) |
|   [prometheus_sd_interval](#prometheus_sd_interval)   |  `interval`  |  G  | prom discovery refresh interval |
|        [grafana_endpoint](#grafana_endpoint)         |  `string`  |  G  | grafana API endpoint |
|   [grafana_admin_username](#grafana_admin_username)   |  `string`  |  G  | grafana admin username |
|   [grafana_admin_password](#grafana_admin_password)   |  `string`  |  G  | grafana admin password |
|         [grafana_database](#grafana_database)         |  `string`  |  G  | grafana backend database type |
|            [grafana_pgurl](#grafana_pgurl)            |  `string`  |  G  | grafana backend postgres url |
|           [grafana_plugin](#grafana_plugin)           |  `enum`  |  G  | how to install grafana plugins |
|            [grafana_cache](#grafana_cache)            |  `string`  |  G  | grafana plugins cache path |
|          [grafana_plugins](#grafana_plugins)          |  `string[]`  |  G  | grafana plugins to be installed |
|      [grafana_git_plugins](#grafana_git_plugins)      |  `string[]`  |  G  | grafana plugins via git |
|      [loki_clean](#loki_clean)                        |  `bool`  |  A  | remove existing loki data? |
|      [loki_data_dir](#loki_data_dir)                  |  `string`  |  G  | loki data path |



## Defaults

```yaml
#------------------------------------------------------------------------------
# META PROVISION
#------------------------------------------------------------------------------
# - ca - #
ca_method: create                             # create|copy|recreate
ca_subject: "/CN=root-ca"                     # self-signed CA subject
ca_homedir: /ca                               # ca cert directory
ca_cert: ca.crt                               # ca public key/cert
ca_key: ca.key                                # ca private key

# - nginx - #
nginx_upstream:                               # domain names that will be used for accessing pigsty services
  # some service can only be accessed via correct domain name (e.g consul)
  - { name: home,          host: pigsty,      url: "127.0.0.1:3000" }   # default -> grafana (3000)
  - { name: consul,        host: c.pigsty,    url: "127.0.0.1:8500" }   # pigsty consul UI (8500) (domain required)
  - { name: grafana,       host: g.pigsty,    url: "127.0.0.1:3000" }   # pigsty grafana (3000)
  - { name: prometheus,    host: p.pigsty,    url: "127.0.0.1:9090" }   # pigsty prometheus (9090)
  - { name: alertmanager,  host: a.pigsty,    url: "127.0.0.1:9093" }   # pigsty alertmanager (9093)
  - { name: haproxy,       host: h.pigsty,    url: "127.0.0.1:9091" }   # pigsty haproxy admin page (9091)
  - { name: server,        host: s.pigsty,    url: "127.0.0.1:9633" }   # pigsty server gui (9093)

# - nameserver - #
dns_records:                                  # dynamic dns record resolved by dnsmasq
  - 10.10.10.2  pg-meta                       # sandbox vip for pg-meta
  - 10.10.10.3  pg-test                       # sandbox vip for pg-test
  - 10.10.10.10 meta-1                        # sandbox node meta-1 (node-0)
  - 10.10.10.10 pigsty
  - 10.10.10.10 y.pigsty yum.pigsty
  - 10.10.10.10 c.pigsty consul.pigsty
  - 10.10.10.10 g.pigsty grafana.pigsty
  - 10.10.10.10 p.pigsty prometheus.pigsty
  - 10.10.10.10 a.pigsty alertmanager.pigsty
  - 10.10.10.10 n.pigsty ntp.pigsty
  - 10.10.10.10 h.pigsty haproxy.pigsty

# - prometheus - #
prometheus_data_dir: /data/prometheus/data    # prometheus data dir
prometheus_options: '--storage.tsdb.retention=30d --enable-feature=promql-negative-offset'
prometheus_reload: false                      # reload prometheus instead of recreate it
prometheus_sd_method: static                  # service discovery method: static|consul|etcd
prometheus_scrape_interval: 10s               # global scrape & evaluation interval
prometheus_scrape_timeout: 8s                 # scrape timeout
prometheus_sd_interval: 10s                   # service discovery refresh interval

# - grafana - #
grafana_endpoint: http://10.10.10.10:3000     # grafana endpoint url
grafana_admin_username: admin                 # default grafana admin username
grafana_admin_password: pigsty                # default grafana admin password
grafana_database: sqlite3                     # default grafana database type: sqlite3|postgres, sqlite3 by default
# if postgres is used, url must be specified. The user is pre-defined in pg-meta.pg_users
grafana_pgurl: postgres://dbuser_grafana:DBUser.Grafana@meta:5436/grafana
grafana_plugin: install                       # none|install, none will skip plugin installation
grafana_cache: /www/pigsty/plugins.tgz        # path to grafana plugins cache tarball
grafana_plugins:                              # plugins that will be downloaded via grafana-cli
  - marcusolsson-csv-datasource
  - marcusolsson-json-datasource
  - marcusolsson-treemap-panel
grafana_git_plugins:                          # plugins that will be downloaded via git
  - https://github.com/Vonng/vonng-echarts-panel

# - loki - #
loki_clean: false                             # whether remove existing loki data
loki_data_dir: /data/loki                     # default loki data dir
```



## Details

### ca_method

* create: create a new public-private key for the CA
* copy: copy an existing CA public-private key for building a CA

(Pigsty open source version does not use CA infrastructure advanced security features yet)




### ca_subject

CA self-signed subject

The default subject is.

```
"/CN=root-ca"
```



### ca_homedir

The root directory of the CA file

Default is `/ca`



### ca_cert

CA public key certificate name

Default is: `ca.crt`



### ca_key

CA private key file name

defaults to `ca.key`



### nginx_upstream

URL and domain name of the Nginx upstream service

Nginx forwards traffic through the Host, so make sure you have the correct domain name configured when accessing the Pigsty infrastructure service.

Do not change the definition of the ``name`` section.

```yaml
nginx_upstream:
- { name: home, host: pigsty, url: "127.0.0.1:3000"}
- { name: consul, host: c.pigsty, url: "127.0.0.1:8500" }
- { name: grafana, host: g.pigsty, url: "127.0.0.1:3000" }
- { name: prometheus, host: p.pigsty, url: "127.0.0.1:9090" }
- { name: alertmanager, host: a.pigsty, url: "127.0.0.1:9093" }
- { name: haproxy, host: h.pigsty, url: "127.0.0.1:9091" }
```



### dns_records

Dynamic DNS resolution records

Each record is written to `/etc/hosts` on the meta node, and resolution is provided by the name servers on the meta node.




### prometheus_data_dir

Prometheus data directory

Default is located in `/export/prometheus/data`



### prometheus_options

Prometheus command line parameters

The default parameter is: `--storage.ttsdb.retention=30d`, which means that 30 days of monitoring data is retained

The function of the parameter `-prometheus_retention` is overridden by this parameter and is deprecated after v0.6.



### prometheus_reload

If `true`, the Prometheus task will not clear the existing data directory when it is executed.

The default is: `false`, which means that the `prometheus` script will clear the existing monitoring data.



### prometheus_sd_method

The service discovery mechanism used by Prometheus, default is `static`, optional.

* `static`: service discovery based on local configuration files
* `consul`: service discovery based on Consul

Pigsty recommends using `static` service discovery, which provides greater reliability and flexibility.

`static` service discovery relies on the configuration in `/etc/pigsty/targets/pgsql/*.yml` for service discovery.
The advantage of this approach is that it does not rely on Consul, and when the Pigsty monitoring system is integrated with an external control solution, this mode is less invasive to the original system.

For manual maintenance, you can generate the required monitoring object configuration file for Prometheus from the configuration file according to the following command

```bash
. /pgsql.yml -t register_prometheus
```

For details, see: [**service discovery**](m-discovery.md)


### prometheus_scrape_interval

Prometheus scrape interval, default is ``10s``



### prometheus_scrape_timeout

Prometheus scrape timeout, default is `8s`



### prometheus_sd_interval

Prometheus refresh period for service discovery list, default is `10s`.



### grafana_endpoint

The endpoint for Grafana to provide services to the public, with a username and password.

The Grafana initialization and installation monitoring panel will use this endpoint to call the Grafana API

The default is `http://10.10.10.10:3000`, where `10.10.10.10` will be replaced by the actual IP during `configure`.



### grafana_admin_username

default admin username for grafana, which defaults to `admin`



### grafana_admin_password

The password for Grafana's administrative user, which defaults to `pigsty`


### grafana_database

The database used for Grafana's own data storage, default is `sqlite3` file database.

Optionally, `postgres`. When using `postgres`, you must ensure that the target database already exists and is accessible
(i.e. Postgres on the management node cannot be used before initializing the infrastructure for the first time, as Grafana was created before that database)


### grafana_pgurl

The Postgres connection string used when `grafana_database` is of type `postgres`.


### grafana_plugin

Grafana plugin provisioning methods

* `none`: no plugin installed
* `install`: install the Grafana plugin (default)
* `reinstall`: force reinstallation of Grafana plugins

Grafana requires Internet access to download several extension plugins. if your meta-node does not have Internet access, the offline installer already contains all downloaded Grafana plugins. pigsty will recreate a new plugin cache installer after the plugin download is complete.



### grafana_cache

Grafana plugin cache file address

The offline installer already contains all downloaded and packaged Grafana plugins. Pigsty will not attempt to re-download Grafana plugins from the Internet if the plugins package directory already exists.

The default offline plugin cache address is: `/www/pigsty/plugins.tar.gz` (assuming the local Yum source is named `pigsty`)



### grafana_plugins

List of Grafana plugins, array of names

Plugins are installed via `grafana-cli plugins install`.

```yaml
grafana_plugins: # plugins that will be downloaded via grafana-cli
  - marcusolsson-csv-datasource
  - marcusolsson-json-datasource
  - marcusolsson-treemap-panel
  - ...
```


### grafana_git_plugins

List of grafana plugin that installed via git

Some plugins that cannot be downloaded via the official command line, but can be downloaded via Git Clone, may be considered with this parameter.

array, each element of which is a plugin name.

Plugins will be installed via `cd /var/lib/grafana/plugins && git clone `.

A visualization plugin will be downloaded by default: ``vonng-echarts-panel``

```yaml
grafana_git_plugins: # plugins that will be downloaded via git
  - https://github.com/Vonng/vonng-echarts-panel
```



### loki_clean

bool type, command line parameter to indicate whether to clean the Loki data directory first when installing Loki?

Loki is not part of the default installation of monitoring components, and this parameter is currently only used by the `infra-loki.yml` script.



### loki_data_dir

String type, filesystem path to specify the Loki data directory location.

The default location is `/export/loki/`

Loki is not part of the default installed monitoring component, this parameter is currently only used by the `infra-loki.yml` script.

