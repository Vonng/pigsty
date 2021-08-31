# 管理节点基础设施

这一节定义了部署于元节点上的 [**基础设施**](c-arch.md#基础设施) ，包括：

## 参数概览

|                           名称                            |    类型    | 层级 | 说明                         |
| :-------------------------------------------------------: | :--------: | :--: | ---------------------------- |
|                  [ca_method](#ca_method)                  |   `enum`   |  G   | CA的创建方式                 |
|                 [ca_subject](#ca_subject)                 |  `string`  |  G   | 自签名CA主题                 |
|                 [ca_homedir](#ca_homedir)                 |  `string`  |  G   | CA证书根目录                 |
|                    [ca_cert](#ca_cert)                    |  `string`  |  G   | CA证书                       |
|                     [ca_key](#ca_key)                     |  `string`  |  G   | CA私钥名称                   |
|             [nginx_upstream](#nginx_upstream)             | `object[]` |  G   | Nginx上游服务器              |
|                [dns_records](#dns_records)                | `string[]` |  G   | 动态DNS解析记录              |
|        [prometheus_data_dir](#prometheus_data_dir)        |  `string`  |  G   | Prometheus数据库目录         |
|         [prometheus_options](#prometheus_options)         |  `string`  |  G   | Prometheus命令行参数         |
|          [prometheus_reload](#prometheus_reload)          |   `bool`   |  A   | Reload而非Recreate           |
|       [prometheus_sd_method](#prometheus_sd_method)       |   `enum`   |  G   | 服务发现机制：static\|consul |
| [prometheus_scrape_interval](#prometheus_scrape_interval) | `interval` |  G   | Prom抓取周期                 |
|  [prometheus_scrape_timeout](#prometheus_scrape_timeout)  | `interval` |  G   | Prom抓取超时                 |
|     [prometheus_sd_interval](#prometheus_sd_interval)     | `interval` |  G   | Prom服务发现刷新周期         |
|      [grafana_endpoint](#grafana_endpoint)                |  `string`  |  G   | Grafana地址                  |
| [grafana_admin_username](#grafana_admin_username)          |  `string`  |  G   | Grafana管理员用户名          |
|     [grafana_admin_password](#grafana_admin_password)     |  `string`  |  G   | Grafana管理员密码            |
|  [grafana_database](#grafana_database)                     |  `string`  |  G  | Grafana后端数据库类型 |
|     [grafana_pgurl](#grafana_pgurl)                        |  `string`  |  G  | Grafana的PG数据库连接串 |
|             [grafana_plugin](#grafana_plugin)             |   `enum`   |  G   | 如何安装Grafana插件          |
|              [grafana_cache](#grafana_cache)              |  `string`  |  G   | Grafana插件缓存地址          |
|            [grafana_plugins](#grafana_plugins)            | `string[]` |  G   | 安装的Grafana插件列表        |
|        [grafana_git_plugins](#grafana_git_plugins)        | `string[]` |  G   | 从Git安装的Grafana插件       |
|        [loki_clean](#loki_clean)                          | `bool` |  A   | 是否在安装Loki时清理数据库目录       |
|        [loki_data_dir](#loki_data_dir)                    | `string` |  G   | Loki的数据目录      |




## 默认参数

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



## 参数详解

### ca_method

* create：创建新的公私钥用于CA
* copy：拷贝现有的CA公私钥用于构建CA

（Pigsty开源版暂未使用CA基础设施高级安全特性）




### ca_subject

CA自签名的主题

默认主题为：

```
"/CN=root-ca"
```



### ca_homedir

CA文件的根目录

默认为`/ca`



### ca_cert

CA公钥证书名称

默认为：`ca.crt`



### ca_key

CA私钥文件名称

默认为`ca.key`



### nginx_upstream

Nginx上游服务的URL与域名

Nginx会通过Host进行流量转发，因此确保访问Pigsty基础设施服务时，配置有正确的域名。

不要修改`name` 部分的定义。

```yaml
nginx_upstream:
- { name: home,          host: pigsty,   url: "127.0.0.1:3000"}
- { name: consul,        host: c.pigsty, url: "127.0.0.1:8500" }
- { name: grafana,       host: g.pigsty, url: "127.0.0.1:3000" }
- { name: prometheus,    host: p.pigsty, url: "127.0.0.1:9090" }
- { name: alertmanager,  host: a.pigsty, url: "127.0.0.1:9093" }
- { name: haproxy,       host: h.pigsty, url: "127.0.0.1:9091" }
```



### dns_records

动态DNS解析记录

每一条记录都会写入元节点的`/etc/hosts`中，并由元节点上的域名服务器提供解析。




### prometheus_data_dir

Prometheus数据目录

默认位于`/export/prometheus/data`



### prometheus_options

Prometheus命令行参数

默认参数为：`--storage.tsdb.retention=30d`，即保留30天的监控数据

参数`prometheus_retention`的功能被此参数覆盖，于v0.6后弃用。



### prometheus_reload

如果为`true`，执行Prometheus任务时不会清除已有数据目录。

默认为：`false`，即执行`prometheus`剧本时会清除已有监控数据。



### prometheus_sd_method

Prometheus使用的服务发现机制，默认为`static`，可选项：

* `static`：基于本地配置文件进行服务发现
* `consul`：基于Consul进行服务发现

Pigsty建议使用`static`服务发现，该方式提供了更高的可靠性与灵活性。

`static`服务发现依赖`/etc/pigsty/targets/pgsql/*.yml`中的配置进行服务发现。
采用这种方式的优势是不依赖Consul。当Pigsty监控系统与外部管控方案集成时，这种模式对原系统的侵入性较小。

手动维护时，可以根据以下命令从配置文件生成Prometheus所需的监控对象配置文件。

```bash
./pgsql.yml -t register_prometheus
```

详细信息请参考：[**服务发现**](m-discovery.md)


### prometheus_scrape_interval

Prometheus抓取周期，默认为`10s`



### prometheus_scrape_timeout

Prometheus抓取超时，默认为`8s`



### prometheus_sd_interval

Prometheus刷新服务发现列表的周期，默认为`10s`。



### grafana_endpoint

Grafana对外提供服务的端点，需要带上用户名与密码。

Grafana初始化与安装监控面板会使用该端点调用Grafana API

默认为`http://10.10.10.10:3000`，其中`10.10.10.10`会在`configure`过程中被实际IP替换。



### grafana_admin_username

Grafana默认管理用户，默认为`admin`



### grafana_admin_password

Grafana管理用户的密码，默认为`pigsty`


### grafana_database

Grafana本身数据存储使用的数据库，默认为`sqlite3`文件数据库。

可选为`postgres`，使用`postgres`时，必须确保目标数据库已经存在并可以访问
（即首次初始化基础设施前无法使用管理节点上的Postgres，因为Grafana先于该数据库而创建）


### grafana_pgurl

当 `grafana_database` 类型为 `postgres`时，所使用的 Postgres连接串。


### grafana_plugin

Grafana插件的供给方式

* `none`：不安装插件
* `install`: 安装Grafana插件（默认）
* `reinstall`: 强制重新安装Grafana插件

Grafana需要访问互联网以下载若干扩展插件，如果您的元节点没有互联网访问，离线安装包中已经包含了所有下载好的Grafana插件。Pigsty会在插件下载完成后重新制作新的插件缓存安装包。



### grafana_cache

Grafana插件缓存文件地址

离线安装包中已经包含了所有下载并打包好的Grafana插件，如果插件包目录已经存在，Pigsty就不会尝试从互联网重新下载Grafana插件。

默认的离线插件缓存地址为：`/www/pigsty/plugins.tar.gz` （假设本地Yum源名为`pigsty`）



### grafana_plugins

Grafana插件列表

数组，每个元素是一个插件名称。

插件会通过`grafana-cli plugins install`的方式进行安装。

默认安装的插件有：

```yaml
grafana_plugins:                              # plugins that will be downloaded via grafana-cli
  - marcusolsson-csv-datasource
  - marcusolsson-json-datasource
  - marcusolsson-treemap-panel


```






### grafana_git_plugins

Grafana的Git插件

一些插件无法通过官方命令行下载，但可以通过Git Clone的方式下载，则可以考虑使用本参数。

数组，每个元素是一个插件名称。

插件会通过`cd /var/lib/grafana/plugins && git clone `的方式进行安装。

默认会下载一个可视化插件：`vonng-echarts-panel`

```yaml
grafana_git_plugins:                          # plugins that will be downloaded via git
  - https://github.com/Vonng/vonng-echarts-panel
```



### loki_clean

bool类型，命令行参数，用于指明安装Loki时是否先清理Loki数据目录？

Loki不属于默认安装的监控组件，该参数目前只会被 `infra-loki.yml` 剧本使用。



### loki_data_dir

字符串类型，文件系统路径，用于指定Loki数据目录位置。

默认位于`/export/loki/`

Loki不属于默认安装的监控组件，该参数目前只会被 `infra-loki.yml` 剧本使用。

