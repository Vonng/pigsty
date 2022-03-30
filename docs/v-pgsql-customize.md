# 定制：PGSQL深度定制与修改

> [Patroni模板](#Patorni模板)用于定制PostgreSQL集群的**规格配置**，而[Postgres模板](#Postgres模板)用于定制PostgreSQL集群的**内容**。

Pigsty默认提供了近100关于[PGSQL](v-pgsql.md)的参数，描述用户所需的PostgreSQL集群，通常可以满足绝大多数用户需求。

但如果您对Pigsty创建的数据库集群进行更深一步的定制，则可以参考本文内容，对[Patroni模板](#Patroni模板)与[Postgres模板](#Postgres模板)进行定制


## Patroni模板

Pigsty使用 [Patroni](https://github.com/zalando/patroni) 管理与初始化Postgres数据库集群。
如果用户希望修改PostgreSQL数据库集群的默认配置参数，规格与调优方案，高可用策略，DCS访问，管控API，可以通过修改Patroni模板的方式实现。

Pigsty使用Patroni完成供给的主体工作，即使用户选择了 [无Patroni模式](v-pgsql.md#patroni_mode)，拉起数据库集群也会由Patroni负责，并在创建完成后移除Patroni组件。
用户可以通过Patroni配置文件，完成大部分的PostgreSQL集群定制工作，Patroni配置文件格式详情请参考 [**Patroni官方文档**](https://patroni.readthedocs.io/en/latest/SETTINGS.html)。


## 预制Patroni模板

Pigsty提供了几种预定义的初始化模板，初始化模板是用于初始化数据库集群的定义文件，默认位于[`roles/postgres/templates/`](https://github.com/Vonng/pigsty/tree/master/roles/postgres/templates)。包括：


|     Conf     | CPU  |  Mem  | Disk  | 说明 |
| :--------------: | :--: | :---: | :---: | ----- |
|     [`oltp`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/oltp.yml)           |  64  | 400GB |  4TB  |  生产OLTP模板，默认配置，针对生产机型优化延迟与性能  |
|     [`olap`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/olap.yml)           |  64  | 400GB |  4TB  |  生产OLAP模板，提高并行度，针对吞吐量，长查询进行优化。  |
|     [`crit`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/crit.yml)           |  64  | 400GB |  4TB  |  生产核心业务模板，基于OLTP模板针对RPO、安全性、数据完整性进行优化，启用同步复制与数据校验和。  |
|     [`tiny`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/tiny.yml)      |  1   |  1GB  | 40GB  | 微型数据库模板，针对低资源场景进行优化，例如运行于虚拟机中的演示数据库集群。 |
|     [`mini`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/mini.yml)      |  2   |  4GB  | 100GB | 2C4G 机型OLTP模板 |
|     [`small`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/small.yml)      |  4   |  8GB  | 200GB | 4C8G 机型OLTP模板 |
|     [`medium`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/medium.yml)     |  8   | 16GB  | 500GB | 8C16G 机型OLTP模板 |
|     [`large`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/large.yml)      |  16  | 32GB  |  1TB  |  16C32G 机型OLTP模板  |
|     [`xlarge`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/xlarge.yml)     |  32  | 64GB  |  2TB  |  32C64G 机型OLTP模板  |


通过 [`pg_conf`](v-pgsql.md#pg_conf) 参数指定所需使用的模板路径，如果使用预制模板，则只需填入模板文件名称即可。如果使用定制的 [Patroni配置模板](v-pgsql.md#pg_conf)，通常也应当针对机器节点使用配套的 [节点优化模板](v-nodes.md#node_tune)。

```yaml
pg_conf:   tiny.yml      # 使用 tiny.yml 调优模板
node_tune: tiny          # 节点调优模式：oltp|olap|crit|tiny
```

在安装Pigsty进行Configure的过程中，Pigsty会检测根据当前机器（管理机）的规格，自动选择对应的默认规格。



## 定制Patroni模板


定制您自己的Patroni模板时，您可以用已有的几种基础模板作为基线，在此基础上进行修改。

并放置于[`templates/`](https://github.com/Vonng/pigsty/tree/master/roles/postgres/templates)目录中，以`<mode>.yml`格式命名即可。

Patroni中的模板变量请保留，否则相关参数可能无法正常工作。例如 [`pg_shared_libraries`](v-pgsql.md#pg_shared_libraries)

最后，在配置文件的 [`pg_conf`](v-pgsql.md#pg_conf) 配置项，指定您新创建的模板名称即可，例如 `olap-32C128G-nvme.yml`



## Postgres模板

可以使用 [PG模板](v-pgsql.md) 配置项，对集群中的模板数据库 `template1` 进行定制，进而。

通过这种方式确保任何在该数据库集群中**新创建**的数据库都带有相同的默认配置：模式，扩展，默认权限。


### 相关文件

定制数据库模板时，相关参数会首先被渲染为SQL脚本后，在部署好的数据库集群上执行。


```ini
^---/pg/bin/pg-init
          |
          ^---(1)--- /pg/tmp/pg-init-roles.sql
          ^---(2)--- /pg/tmp/pg-init-template.sql
          ^---(3)--- <other customize logic in pg-init>

# 业务用户与数据库并不是在模版定制中创建的，但在此列出。
^-------------(4)--- /pg/tmp/pg-user-{{ user.name }}.sql
^-------------(5)--- /pg/tmp/pg-db-{{ db.name }}.sql
```

## `pg-init`

[`pg-init`](v-pgsql.md#pg_init)是用于自定义初始化模板的Shell脚本路径，该脚本将以postgres用户身份，**仅在主库上执行**，执行时数据库集群主库已经被拉起，可以执行任意Shell命令，或通过psql执行任意SQL命令。

如果不指定该配置项，Pigsty会使用默认的[`pg-init`](https://github.com/Vonng/pigsty/blob/master/roles/postgres/templates/pg-init) Shell脚本，如下所示。

```shell
#!/usr/bin/env bash
set -uo pipefail


#==================================================================#
#                          Default Roles                           #
#==================================================================#
psql postgres -qAXwtf /pg/tmp/pg-init-roles.sql


#==================================================================#
#                          System Template                         #
#==================================================================#
# system default template
psql template1 -qAXwtf /pg/tmp/pg-init-template.sql

# make postgres same as templated database (optional)
psql postgres  -qAXwtf /pg/tmp/pg-init-template.sql



#==================================================================#
#                          Customize Logic                         #
#==================================================================#
# add your template logic here
```

如果用户需要执行复杂的定制逻辑，可在该脚本的基础上进行追加。注意 `pg-init` 用于定制**数据库集群**，通常这是通过修改 **模板数据库** 实现的。在该脚本执行时，数据库集群已经启动，但业务用户与业务数据库尚未创建。因此模板数据库的修改会反映在默认定义的业务数据库中。

