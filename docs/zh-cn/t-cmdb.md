# 使用CMDB

您可以使用 `postgres` 作为 Pigsty 的配置源，替代静态配置文件。

使用 CMDB 作为 Ansible 的动态 Inventory具有一些优点：元数据以高度结构化的方式以数据表的形式呈现，并通过数据库约束确保一致性。同时CMDB允许您使用第三方的工具来编辑管理Pigsty元数据，便于与外部系统相互集成。

目前 Pigsty 的CMDB仅支持 PostgreSQL 集群，如果您的 pigsty.yml 中包含 Redis与MatrixDB，则会报错，建议使用单独的 pigsty.yml 配置文件管理Redis与Greenplum集群。 

## 加载配置

Pigsty CMDB的模式会在`pg-meta`元数据库初始化时自动创建（[`files/cmdb.sql`](https://github.com/Vonng/pigsty/blob/master/files/cmdb.sql)），位于`meta`数据库的`pigsty` 模式中。使用`bin/inventory_load`可以将静态配置文件加载至CMDB中。

!> 必须在元节点完整执行`infra.yml`，安装完毕后，方可使用CMDB

```bash
usage: inventory_load [-h] [-p PATH] [-d CMDB_URL]

load config arguments

optional arguments:
  -h, --help            show this help message and exit„
  -p PATH, --path PATH  config path, ${PIGSTY_HOME}/pigsty.yml by default
  -d DATA, --data DATA  postgres cmdb pgurl, ${METADB_URL} by default
```

默认情况下，不带参数执行该脚本将会把`$PIGSTY_HOME/pigsty.yml`的名称载入默认CMDB中。

```bash
bin/inventory_load
bin/inventory_load -p files/conf/pigsty-demo.yml
bin/inventory_load -p files/conf/pigsty-dcs3.yml -d postgresql://dbuser_meta:DBUser.Meta@10.10.10.10:5432/meta
```



## 使用CMDB作为配置源

当原有配置文件加载至CMDB作为初始数据后，即可配置Ansible使用CMDB作为配置源：


```bash
bin/inventory_cmdb
```

您可以切换回静态配置文件：

```bash
bin/inventory_conf
```


修改配置源实质上是编辑Pigsty目录下的 `ansible.cfg` 实现的。

```bash
---
inventory = pigsty.yml
+++
inventory = inventory.sh
```


