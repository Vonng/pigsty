# 扩展应用

Pigsty除了用于部署、监控PostgreSQL，还可以用于制作，分发数据类**应用**（Application）。

用于监控系统的`PGSQL`，`PGLOG`，`PGCAT`也是以应用的方式开发并分发的。此外，Pigsty还提供了两个样例应用：[`covid`](#covid)与 [`isd`](#isd)



## 应用的结构

一个Pigsty应用通常包括以下内容中的至少一样或全部：

* 图形界面（Grafana Dashboard定义） 放置于`ui`目录
* 数据定义（PostgreSQL DDL File），放置于 `sql` 目录
* 数据文件（各类资源，需要下载的文件），放置于`data`目录
* 逻辑脚本（执行各类逻辑），放置于`bin`目录

一个Pigsty应用会在应用根目录提供一个安装脚本：`install`或相关快捷方式。您需要使用[管理用户](d-prepare.md#管理应用置备)在[管理节点](d-prepare.md#管理节点置备)执行安装。安装脚本会检测当前的环境（获取 `METADB_URL`， `PIGSTY_HOME`，`GRAFANA_ENDPOINT`等信息以执行安装）

您可以从 https://github.com/Vonng/pigsty/releases/download/v1.4.0-rc/app.tgz 下载带有基础数据的应用安装。



## COVID

一个较为简单的数据应用样例：可视化WHO COVID-19数据，查阅各国疫情数据。

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

