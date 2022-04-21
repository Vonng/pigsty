# 扩展应用

Pigsty除了用于部署、监控PostgreSQL，还可以用于制作，分发数据类**应用**（Application）。

Pigsty提供了三个样例应用：

* [`pglog`](#PGLOG)， 分析PostgreSQL CSV日志样本。
* [`covid`](#COVID)， 可视化WHO COVID-19数据，查阅各国疫情数据。
* [`pglog`](#ISD)， NOAA ISD，可以查询全球30000个地表气象站从1901年来的气象观测记录。



## 应用的结构

一个Pigsty应用通常包括以下内容中的至少一样或全部：

* 图形界面（Grafana Dashboard定义） 放置于`ui`目录
* 数据定义（PostgreSQL DDL File），放置于 `sql` 目录
* 数据文件（各类资源，需要下载的文件），放置于`data`目录
* 逻辑脚本（执行各类逻辑），放置于`bin`目录

一个Pigsty应用会在应用根目录提供一个安装脚本：`install`或相关快捷方式。您需要使用[管理用户](d-prepare.md#管理应用置备)在[元节点](d-prepare.md#元节点置备)执行安装。安装脚本会检测当前的环境（获取 `METADB_URL`， `PIGSTY_HOME`，`GRAFANA_ENDPOINT`等信息以执行安装）

通常，带有`APP`标签的面板会被列入Pigsty Grafana首页导航中App下拉菜单中，带有`APP`和`Overview`标签的面板则会列入首页面板导航中。

您可以从 https://github.com/Vonng/pigsty/releases/download/v1.4.1/app.tgz 下载带有基础数据的应用进行安装。







## PGLOG

PGLOG是Pigsty自带的一个样例应用，固定使用MetaDB中`pglog.sample`表作为数据来源。您只需要将日志灌入该表，然后访问相关Dashboard即可。

Pigsty提供了一些趁手的命令，用于拉取csv日志，并灌入样本表中。在元节点上，默认提供下列快捷命令：

```bash
catlog  [node=localhost]  [date=today]   # 打印CSV日志到标准输出
pglog                                    # 从标准输入灌入CSVLOG
pglog12                                  # 灌入PG12格式的CSVLOG
pglog12                                  # 灌入PG13格式的CSVLOG
pglog12                                  # 灌入PG14格式的CSVLOG (=pglog)

catlog | pglog                       # 分析当前节点当日的日志
catlog node-1 '2021-07-15' | pglog   # 分析node-1在2021-07-15的csvlog
```

接下来，您可以访问以下的连接，查看样例日志分析界面。

  * [PGLOG Overview](http://demo.pigsty.cc/d/pglog-overview):  呈现整份CSV日志样本详情，按多种维度聚合。
  * [PGLOG Session](http://demo.pigsty.cc/d/pglog-session):  呈现日志样本中一条具体连接的详细信息。



`catlog`命令从特定节点拉取特定日期的CSV数据库日志，写入`stdout`

默认情况下，`catlog`会拉取当前节点当日的日志，您可以通过参数指定节点与日期。

组合使用`pglog`与`catlog`，即可快速拉取数据库CSV日志进行分析。

```bash
catlog | pglog                       # 分析当前节点当日的日志
catlog node-1 '2021-07-15' | pglog   # 分析node-1在2021-07-15的csvlog
```







## COVID

COVID是一个可视化WHO COVID-19数据，查阅各国疫情数据的应用样例。

公开演示：http://demo.pigsty.cc/d/covid-overview 

### 安装方式

```bash
cd covid
make all         # 完整安装（会从WHO下载最新数据）
make all2        # 完整安装（会直接使用本地下载好的数据）
```

更精细的控制：

```
make ui          # 将covid dashboards安装至grafana
make sql         # 将covid 数据库表定义创建至metadb中
make download    # 下载WHO最新数据
make load        # 加载下载好的WHO数据
make reload      # download + load
```

Or just use `make all` to setup all stuff for you.If data already download (e.g get applications via downloading app.tgz), run `make all2` instead to skip download.





## ISD

一个功能完成的数据应用，可以查询全球30000个地表气象站从1901年来的气象观测记录。

公开演示：http://demo.pigsty.cc/d/isd-overview

项目地址：https://github.com/Vonng/isd

### 安装方式

```bash
cd isd
make all         # 完整安装（会从Github与NOAA下载最新数据）
make all2        # 完整安装（会直接使用本地下载好的数据）
```

更精细的控制：

```bash
make ui          # 将covid dashboards安装至grafana
make sql         # 将covid 数据库表定义创建至metadb中
make download    # 下载NOAA最新数据，ISD Parser，字典表
make baseline    # 使用下载好的数据初始化最基本的全局大盘功能
make reload      # 从NOAA下载最新的每日摘要并解析加载
```

