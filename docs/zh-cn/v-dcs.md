# DCS元数据库

Pigsty使用DCS（Distributive Configuration Storage）作为元数据库。DCS有三个重要作用：

* 主库选举：Patroni基于DCS进行选举与切换
* 配置管理：Patroni使用DCS管理Postgres的配置
* 身份管理：监控系统基于DCS管理并维护数据库实例的身份信息。

DCS对于数据库的稳定至关重要，Pigsty出于**演示目的**提供了基本的Consul与Etcd支持，在元节点部署了DCS服务。建议在生产环境中使用专用机器部署专用DCS集群。

## 参数概览

|                             名称                     |    类型     | 层级  | 说明                                      |
| :---------------------------------------------------: | :---------: | :---: | ----------------------------------------- |
|        [service_registry](#service_registry)        |   `enum`    | G/C/I | 服务注册的位置                            |
|                [dcs_type](#dcs_type)                |   `enum`    |   G   | 使用的DCS类型                             |
|                [dcs_name](#dcs_name)                |  `string`   |   G   | DCS集群名称                               |
|             [dcs_servers](#dcs_servers)             |   `dict`    |   G   | DCS服务器名称:IP列表                      |
|       [dcs_exists_action](#dcs_exists_action)       |   `enum`    |  G/A  | 若DCS实例存在如何处理                     |
|       [dcs_disable_purge](#dcs_disable_purge)       |   `bool`    | G/C/I | 完全禁止清理DCS实例                       |
|         [consul_data_dir](#consul_data_dir)         |  `string`   |   G   | Consul数据目录                            |
|           [etcd_data_dir](#etcd_data_dir)           |  `string`   |   G   | Etcd数据目录                              |



## 默认参数

```yaml
#------------------------------------------------------------------------------
# DCS PROVISION
#------------------------------------------------------------------------------
service_registry: consul                      # where to register services: none | consul | etcd | both
dcs_type: consul                              # consul | etcd | both
dcs_name: pigsty                              # consul dc name | etcd initial cluster token
dcs_servers:                                  # dcs server dict in name:ip format
  meta-1: 10.10.10.10                         # you could use existing dcs cluster
  # meta-2: 10.10.10.11                       # host which have their IP listed here will be init as server
  # meta-3: 10.10.10.12                       # 3 or 5 dcs nodes are recommend for production environment
dcs_exists_action: clean                      # abort|skip|clean if dcs server already exists
dcs_disable_purge: false                      # set to true to disable purge functionality for good (force dcs_exists_action = abort)
consul_data_dir: /var/lib/consul              # consul data dir (/var/lib/consul by default)
etcd_data_dir: /var/lib/etcd                  # etcd data dir (/var/lib/consul by default)
```





## 参数详解

### service_registry

服务注册的地址，被多个组件引用。

* `none`：不执行服务注册（当执行**仅监控部署**时，必须指定`none`模式）
* `consul`：将服务注册至Consul中
* `etcd`：将服务注册至Etcd中（尚未支持）



### dcs_type

DCS类型，有两种选项：

* Consul

* Etcd （支持尚不完善）

  


### dcs_name

DCS集群名称，默认为`pigsty`。

在Consul中代表 DataCenter名称



### dcs_servers

DCS服务器名称与地址，采用字典格式，Key为DCS服务器实例名称，Value为服务器IP地址。

您可以使用外部的已有DCS服务器（推荐），也可以在目标机器上初始化新的DCS服务器。

如果采用初始化新DCS实例的方式，建议先在所有DCS Server（通常也是元节点）上完成DCS初始化（[`meta.yml`](p-meta.md)）。

尽管您也可以一次性初始化所有的DCS Server与DCS Agent，但必须在完整初始化时将所有Server囊括在内。
此时所有IP地址匹配`dcs_servers`项的目标机器将会在DCS初始化过程中被初始化为DCS Server。

强烈建议使用奇数个DCS Server，演示环境可使用单个DCS Server，生产环境建议使用3～5个确保DCS可用性。

您必须根据实际情况显式配置DCS Server，例如在沙箱环境中，您可以选择启用1个或3个DCS节点。

```yaml
dcs_servers:
  meta-1: 10.10.10.10
  meta-2: 10.10.10.11 
  meta-3: 10.10.10.12 
```



### dcs_exists_action

安全保险，当Consul实例已经存在时，系统应当执行的动作

* `abort`: 中止整个剧本的执行（默认行为）
* `clean`: 抹除现有DCS实例并继续（极端危险）
* `skip`: 忽略存在DCS实例的目标（中止），在其他目标机器上继续执行。

如果您真的需要强制清除已经存在的DCS实例，建议先使用[`pgsql-remove.yml`](p-pgsql-remove.md)完成集群与实例的下线与销毁，再重新执行初始化。
否则需要通过命令行参数`-e dcs_exists_action=clean`完成覆写，强制在初始化过程中抹除已有实例。



### dcs_disable_purge

双重安全保险，默认为`false`。如果为`true`，强制设置`dcs_exists_action`变量为`abort`。

等效于关闭`dcs_exists_action`的清理功能，确保**任何情况**下DCS实例都不会被抹除。



### consul_data_dir

Consul数据目录地址，默认为`/var/lib/consul`。



### etcd_data_dir

Etcd数据目录地址，默认为`/var/lib/etcd`。