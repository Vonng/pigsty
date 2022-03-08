# 使用CMDB

您可以使用 `postgres` 作为 Pigsty 的配置源，替代静态配置文件。

使用 CMDB 作为 Ansible 的动态 Inventory具有一些优点：元数据以高度结构化的方式以数据表的形式呈现，并通过数据库约束确保一致性。同时CMDB允许您使用第三方的工具来编辑管理Pigsty元数据，便于与外部系统相互集成。

目前 Pigsty 的CMDB仅支持 PostgreSQL 集群，如果您的 pigsty.yml 中包含 Redis与MatrixDB，则会报错，建议使用单独的 pigsty.yml 配置文件管理 Redis与Greenplum集群。 

## 加载配置

Pigsty CMDB的模式会在`pg-meta`元数据库初始化时自动创建（[`files/cmdb.sql`](https://github.com/Vonng/pigsty/blob/master/files/cmdb.sql)），位于`meta`数据库的`pigsty` 模式中。使用`bin/load_conf.py`可以将静态配置文件加载至CMDB中。

!> 必须在管理节点完整执行`meta.yml`，安装完毕后，方可使用CMDB

```bash
usage: load_conf.py [-h] [-n NAME] [-p PATH] [-d DATA]

load config arguments

optional arguments:
  -h, --help            show this help message and exit„
  -n NAME, --name NAME  config profile name, pgsql by default
  -p PATH, --path PATH  config path, ${PIGSTY_HOME}/pigsty.yml by default
  -d DATA, --data DATA  postgres cmdb pgurl, ${METADB_URL} by default
```

默认情况下，不带参数执行该脚本将会把`$PIGSTY_HOME/pigsty.yml`以`pgsql`的名称载入CMDB中。

```bash
bin/load_conf.py
```

您可以加载多份不同的配置文件，并给它们设置不同的名字。已有的同名配置文件会被覆盖。例如，将默认配置文件`pigsty-demo4.yml`加载至CMDB中并启用：

```bash
bin/load_conf.py  -n demo4  -p files/conf/pigsty-demo4.yml
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





## CMDB模式

```bash
# Tables
pigsty.config                   # raw config table
pigsty.global_var               # global config entries
pigsty.cluster                  # cluster
pigsty.cluster_var              # cluster config entries
pigsty.instance                 # instance
pigsty.instance_var             # instance config entries
pigsty.node                     # node
pigsty.job                      # job

# views
pigsty.inventory            # de-parsed inventory
pigsty.cluster_config       # merged config for cluster
pigsty.instance_config      # merged config for instance
pigsty.cluster_user         # cluster user definition in pg_users
pigsty.cluster_database     # cluster database definition in pg_databases
pigsty.cluster_service      # cluster service definition in pg_services & pg_services_extra

# seqs
pigsty.job_id_seq
```

Also some built-in functions:

```bash
pigsty.activate_config
pigsty.active_config
pigsty.active_config_name
pigsty.clean_config
pigsty.deactivate_config
pigsty.delete_config
pigsty.delete_node
pigsty.dump_config
pigsty.ins_cls
pigsty.ins_ip
pigsty.ins_is_meta
pigsty.ins_role
pigsty.ins_seq
pigsty.ip2ins
pigsty.job_id
pigsty.job_id_ts
pigsty.node_cls
pigsty.node_ins
pigsty.node_is_meta
pigsty.node_status
pigsty.parse_config
pigsty.select_cluster
pigsty.select_config
pigsty.select_instance
pigsty.select_instance
pigsty.select_node
pigsty.update_cluster_var
pigsty.update_cluster_vars
pigsty.update_global_var
pigsty.update_global_vars
pigsty.update_instance_var
pigsty.update_instance_vars
pigsty.update_node_status
pigsty.upsert_clusters
pigsty.upsert_config
pigsty.upsert_instance
pigsty.upsert_node
```