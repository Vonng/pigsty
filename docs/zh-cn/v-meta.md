# 管理节点基础设施

这一节定义了部署于元节点上的 [**基础设施**](c-arch.md#基础设施) 

`nginx`, `prometheus`, `grafana` 为必选基础设施，而`nameserver`, `loki`, `jupyter`, `pgweb`属于可选基础设施。

## 参数概览

|                           名称                            |    类型    | 层级 | 说明                         |
| :-------------------------------------------------------: | :--------: | :--: | ---------------------------- |
|                  [ca_method](#ca_method)                  |   `enum`   |  G   | CA的创建方式                 |
|                 [ca_subject](#ca_subject)                 |  `string`  |  G   | 自签名CA主题                 |
|                 [ca_homedir](#ca_homedir)                 |  `string`  |  G   | CA证书根目录                 |
|                    [ca_cert](#ca_cert)                    |  `string`  |  G   | CA证书                       |
|                     [ca_key](#ca_key)                     |  `string`  |  G   | CA私钥名称                   |
|             [nginx_upstream](#nginx_upstream)             | `object[]` |  G   | Nginx上游服务器              |
|           [app_list](#app_list)                          |  `object[]`  |  G  | 首页导航栏显示的应用列表 |
|      [docs_enabled](#docs_enabled)                       |  `bool`      |  G  | 是否启用本地文档 |
|      [pev2_enabled](#pev2_enabled)                       |  `bool`      |  G  | 是否启用PEV2组件 |
|      [pgbadger_enabled](#pgbadger_enabled)               |  `bool`      |  G  | 是否启用Pgbadger |
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
|      [loki_enabled](#loki_enabled)                        |  `bool`      |  G  | 是否启用Loki |
|        [loki_clean](#loki_clean)                          | `bool` |  A   | 是否在安装Loki时清理数据库目录       |
|        [loki_data_dir](#loki_data_dir)                    | `string` |  G   | Loki的数据目录      |
|      [jupyter_enabled](#jupyter_enabled)               |  `bool`      |  G  | 是否启用JupyterLab |
|      [jupyter_username](#jupyter_username)               |  `bool`      |  G  | Jupyter使用的操作系统用户 |
|      [pgweb_enabled](#pgweb_enabled)               |  `bool`      |  G  | 是否启用PgWeb |
|      [pgweb_username](#pgweb_username)               |  `bool`      |  G  | PgWeb使用的操作系统用户 |


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
  - { name: home,          domain: pigsty,        endpoint: "10.10.10.10:80" }     # default -> index.html (80)
  - { name: grafana,       domain: g.pigsty,      endpoint: "10.10.10.10:3000" }   # pigsty grafana (3000)
  - { name: prometheus,    domain: p.pigsty,      endpoint: "10.10.10.10:9090" }   # pigsty prometheus (9090)
  - { name: alertmanager,  domain: a.pigsty,      endpoint: "10.10.10.10:9093" }   # pigsty alertmanager (9093)
  # some service can only be accessed via domain name due to security reasons (e.g consul, pgweb, jupyter)
  - { name: consul,        domain: c.pigsty,      endpoint: "127.0.0.1:8500" }     # pigsty consul UI (8500) (domain required)
  - { name: pgweb,         domain: cli.pigsty,    endpoint: "127.0.0.1:8081" }     # pgweb console (8081)
  - { name: jupyter,       domain: lab.pigsty,    endpoint: "127.0.0.1:8888" }     # jupyter lab (8888)

# - app - #
app_list:                                      # show extra application links on home page
  - { name: Pev2    , url : '/pev2'        , comment: 'postgres explain visualizer 2' }
  - { name: Logs    , url : '/logs'        , comment: 'realtime pgbadger log sample' }
  - { name: Report  , url : '/report'      , comment: 'daily log summary report ' }
  - { name: Pkgs    , url : '/pigsty'      , comment: 'local yum repo packages' }
  - { name: Repo    , url : '/pigsty.repo' , comment: 'local yum repo file' }
  - { name: ISD     , url : '${grafana}/d/isd-overview'   , comment: 'noaa isd data visualization' }
  - { name: Covid   , url : '${grafana}/d/covid-overview' , comment: 'covid data visualization' }

docs_enabled: true                            # setup local document under default server?
pev2_enabled: true                            # setup pev2 explain visualizer under default server?
pgbadger_enabled: true                        # setup pgbadger under default server?

# - nameserver - #
dns_records:                                  # dynamic dns record resolved by dnsmasq
  - 10.10.10.2  pg-meta    # sandbox vip for pg-meta
  - 10.10.10.3  pg-test    # sandbox vip for pg-test
  - 10.10.10.10 meta-1     # sandbox node meta-1
  - 10.10.10.11 node-1     # sandbox node node-1
  - 10.10.10.12 node-2     # sandbox node node-2
  - 10.10.10.13 node-3     # sandbox node node-3
  - 10.10.10.10 pg-meta-1  # sandbox instance pg-meta-1
  - 10.10.10.11 pg-test-1  # sandbox instance node-1
  - 10.10.10.12 pg-test-2  # sandbox instance node-2
  - 10.10.10.13 pg-test-3  # sandbox instance node-3

# - prometheus - #
prometheus_data_dir: /data/prometheus/data    # prometheus data dir
prometheus_options: '--storage.tsdb.retention=15d --enable-feature=promql-negative-offset'
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
grafana_plugin: install                       # none|install|always
grafana_cache: /www/pigsty/plugins.tgz        # path to grafana plugins cache tarball
grafana_plugins:                              # plugins that will be downloaded via grafana-cli
  - marcusolsson-csv-datasource
  - marcusolsson-json-datasource
  - marcusolsson-treemap-panel
grafana_git_plugins:                          # plugins that will be downloaded via git
  - https://github.com/Vonng/vonng-echarts-panel

# - loki - #                                  # note that loki is not installed by default
loki_enabled: false                           # enable loki?
loki_clean: false                             # whether remove existing loki data
loki_data_dir: /data/loki                     # default loki data dir

# - jupyter - #
jupyter_enabled: true                         # setup jupyter lab server?
jupyter_username: jupyter                     # os user name, special names: default|root (dangerous!)

# - pgweb - #
pgweb_enabled: true                           # setup pgweb server?
pgweb_username: pgweb                         # os user name, special names: default|root (dangerous!)
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

部分基础设施默认只能通过Nginx代理访问（监听地址为`127.0.0.1`的服务：Consul, Pgweb, Jupyter）

不要修改`name` 部分的定义，默认基础设施的`name`是硬编码在任务中的。

```yaml
nginx_upstream:                               # domain names that will be used for accessing pigsty services
  - { name: home,          domain: pigsty,        endpoint: "10.10.10.10:80" }     # default -> index.html (80)
  - { name: grafana,       domain: g.pigsty,      endpoint: "10.10.10.10:3000" }   # pigsty grafana (3000)
  - { name: prometheus,    domain: p.pigsty,      endpoint: "10.10.10.10:9090" }   # pigsty prometheus (9090)
  - { name: alertmanager,  domain: a.pigsty,      endpoint: "10.10.10.10:9093" }   # pigsty alertmanager (9093)
  # some service can only be accessed via domain name due to security reasons (e.g consul, pgweb, jupyter)
  - { name: consul,        domain: c.pigsty,      endpoint: "127.0.0.1:8500" }     # pigsty consul UI (8500) (domain required)
  - { name: pgweb,         domain: cli.pigsty,    endpoint: "127.0.0.1:8081" }     # pgweb console (8081)
  - { name: jupyter,       domain: lab.pigsty,    endpoint: "127.0.0.1:8888" }     # jupyter lab (8888)
```

### app_list

用于渲染Pigsty首页的应用列表，每一项都会备渲染为首页导航栏App下拉选单的按钮

其中，`url`中的`${grafana}`会被自动替换为[`nginx_upstream`](#nginx_upstream) 中定义的 Grafana域名。


```yaml
app_list:                                   # show extra application links on home page
 - { name: Pev2    , url : '/pev2'        , comment: 'postgres explain visualizer 2' }
 - { name: Logs    , url : '/logs'        , comment: 'realtime pgbadger log sample' }
 - { name: Report  , url : '/report'      , comment: 'daily log summary report ' }
 - { name: Pkgs    , url : '/pigsty'      , comment: 'local yum repo packages' }
 - { name: Repo    , url : '/pigsty.repo' , comment: 'local yum repo file' }
 - { name: ISD     , url : '${grafana}/d/isd-overview'   , comment: 'noaa isd data visualization' }
 - { name: Covid   , url : '${grafana}/d/covid-overview' , comment: 'covid data visualization' }
```

大部分应用均为可选项。



### docs_enabled

是否在默认首页中启用本地文档支持？默认启用

本地文档是静态页面，由默认的Nginx提供服务，挂载于`/docs`路径下。



### pev2_enabled

是否在默认首页中启用Pev2组件？默认启用

Pev2是一个方便的PostgreSQL执行计划可视化工具，为静态单页应用。

Pev2由默认的Nginx提供服务，挂载于`/pev2`路径下。



### pgbadger_enabled

是否在默认首页中启用Pgbadger组件？默认启用

Pgbadger是一个方便的PostgreSQL日志分析工具，可以从PG日志中生成全面美观的网页报告。

Pgabdger由默认的Nginx提供服务，挂载于`/logs`路径与`/report`路径下。



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

可选为`postgres`，使用`postgres`时，必须确保目标数据库已经存在并可以访问。
（即首次初始化基础设施前无法使用管理节点上的Postgres，因为Grafana先于该数据库而创建）

详情请参考【[教程:使用Postgres作为Grafana后端数据库](t-grafana-upgrade.md)】


### grafana_pgurl

当 `grafana_database` 类型为 `postgres`时，所使用的 Postgres 数据库连接串。


### grafana_plugin

Grafana插件的供给方式

* `none`：不安装插件
* `install`: 安装Grafana插件（默认）
* `reinstall`: 强制重新安装Grafana插件

Grafana需要访问互联网以下载若干扩展插件，如果您的元节点没有互联网访问，则应当确保使用了离线安装包。
离线安装包中默认已经包含了所有下载好的Grafana插件，位于 [`grafana_cache`](#grafana_cache) 指定的路径下。
当从互联网下载插件时，Pigsty会在下载完成后打包下载好的插件，并放置于 [`grafana_cache`](#grafana_cache) 路径下。



### grafana_cache

Grafana插件缓存文件地址

离线安装包中已经包含了所有下载并打包好的Grafana插件，如果插件包目录已经存在，Pigsty就不会尝试从互联网重新下载Grafana插件。

默认的离线插件缓存地址为：`/www/pigsty/plugins.tar.gz` （假设本地Yum源名为`pigsty`）



### grafana_plugins

需要从Grafana官方安装的插件列表

数组，每个数组元素是一个字符串，为插件的名称。

插件会通过`grafana-cli plugins install`的方式进行安装。

默认安装的插件包括：

```yaml
grafana_plugins:                              # plugins that will be downloaded via grafana-cli
  - marcusolsson-csv-datasource
  - marcusolsson-json-datasource
  - marcusolsson-treemap-panel


```



### grafana_git_plugins

需要通过Git的方式下载的Grafana插件列表

数组，每个数组元素是一个字符串，为插件的Git URL。

一些插件无法通过官方命令行下载，但可以通过Git Clone的方式下载。

插件会通过`cd /var/lib/grafana/plugins && git clone `的方式进行安装。

默认会下载一个可视化插件：`vonng-echarts-panel`，提供为Grafana提供Echarts绘图支持。

```yaml
grafana_git_plugins:                          # plugins that will be downloaded via git
  - https://github.com/Vonng/vonng-echarts-panel
```


### loki_enabled

是否启用Loki？布尔类型，对于演示与个人使用默认启用，对于生产环境部署默认不启用。

Loki是与Grafana搭配的轻量级实时日志收集检索解决方案，因为萝卜白菜各有所爱，所以默认不会在生产环境中启用



### loki_clean

bool类型，命令行参数，用于指明安装Loki时是否先清理Loki数据目录。

Loki不属于默认安装的监控组件，该参数目前只会被 [`infra-loki.yml`] 剧本使用。



### loki_data_dir

字符串类型，文件系统路径，用于指定Loki数据目录位置。

默认位于`/export/loki/`

Loki不属于默认安装的监控组件，该参数目前只会被 [`infra-loki.yml`] 剧本使用。



### jupyter_enabled

是否启用Jupyter Lab服务器？对于演示与个人使用默认启用，对于生产环境部署默认不启用。

对于数据分析、个人学习研究、演示环境，Jupyter Lab非常有用，可以用于完成各类数据分析、处理、演示的工作。

但是Jupyter Lab提供的网页终端与任意代码执行能力对于生产环境非常危险，您必须在充分意识到这一风险的前提下手工启用该功能。

Jupyter Lab的网页界面默认只能通过域名由 Nginx 代理访问，默认为`lab.pigsty`，默认的密码为`pigsty`，默认会使用名为`jupyter`的操作系统用户运行。

```yaml
- { name: jupyter,       domain: lab.pigsty,    endpoint: "127.0.0.1:8888" }     # jupyter lab (8888)
```



### jupyter_username

运行Jupyter Lab服务器的操作系统用户。默认为`jupyter`，即会创建一个低权限的默认用户`jupyter`。

其他用户名亦同理，但特殊用户名`default`会使用当前执行安装的用户（通常为管理员）运行 Jupyter Lab，这会更方便，但也更危险。



### pgweb_enabled

是否启用PGWeb服务器？对于演示与个人使用默认启用，对于生产环境部署默认不启用。

PGWEB是一个开箱即用的网页PostgreSQL客户端，可以浏览数据库内对象，执行简单SQL。

PGWEB的网页界面默认只能通过域名由 Nginx 代理访问，默认为`cli.pigsty`，默认会使用名为`pgweb`的操作系统用户运行。

```yaml
- { name: jupyter,       domain: lab.pigsty,    endpoint: "127.0.0.1:8888" }     # jupyter lab (8888)
```


### pgweb_username

运行PGWEB服务器的操作系统用户。默认为`pgweb`，即会创建一个低权限的默认用户`pgweb`。

其他用户名亦同理，但特殊用户名`default`会使用当前执行安装的用户（通常为管理员）运行 PGWEB。

您需要数据库的连接串方可通过PGWEB访问环境中的数据库。例如：`postgres://dbuser_dba:DBUser.DBA@127.0.0.1:5432/meta`