# 升级Grafana后端数据库

您可以使用 postgres 作为Grafana后端使用的数据库。

这是了解Pigsty部署系统使用方式的好机会，完成此教程，您会了解：

* 如何[创建新数据库集群](#创建数据库集群)
* 如何在已有数据库集群中[创建新业务用户](#创建grafana业务用户)
* 如何在已有数据库集群中[创建新业务数据库](#创建grafana业务数据库)
* 如何[访问Pigsty所创建的数据库](#使用grafana业务数据库)
* 如何[管理Grafana中的监控面板](#管理grafana监控面板)
* 如何管理Grafana中的[PostgreSQL数据源](#管理postgres数据源)
* 如何一步到位完成[Grafana数据库升级](#一步到位更新grafana)

## 太长不看

```bash
vi pigsty.yml # 取消注释DB/User定义：dbuser_grafana  grafana 
bin/createuser  pg-meta  dbuser_grafana
bin/createdb    pg-meta  grafana

psql postgres://dbuser_grafana:DBUser.Grafana@meta:5436/grafana -c \
  'CREATE TABLE t(); DROP TABLE t;' # 检查连接串可用性
  
vi /etc/grafana/grafana.ini # 修改 [database] type url
systemctl restart grafana-server
```





## 创建数据库集群

我们可以在`pg-meta`上定义一个新的数据库`grafana`，
也可以在新的机器节点上创建一个专用于Grafana的数据库集群：`pg-grafana`

### 定义集群

如果需要创建新的专用数据库集群`pg-grafana`，部署在`10.10.10.11`，`10.10.10.12`两台机器上，可以使用以下配置文件：

```yaml
pg-grafana: 
  hosts: 
    10.10.10.11: {pg_seq: 1, pg_role: primary}
    10.10.10.12: {pg_seq: 2, pg_role: replica}
  vars:
    pg_cluster: pg-grafana
    pg_databases:
      - name: grafana
        owner: dbuser_grafana
        revokeconn: true
        comment: grafana primary database
    pg_users:
      - name: dbuser_grafana
        password: DBUser.Grafana
        pgbouncer: true
        roles: [dbrole_admin]
        comment: admin user for grafana database
```

### 创建集群

使用以下命令完成数据库集群`pg-grafana`的创建：[`pgsql.yml`](p-pgsql.yml)。

```bash
bin/createpg pg-grafana    # 初始化pg-grafana集群
```

该命令实际上调用了Ansible Playbook [`pgsql.yml`](p-pgsq.md) 创建数据库集群。

```bash
./pgsql.yml -l pg-grafana  # 实际执行的等效Ansible剧本命令 
```

定义在`pg_users`与`pg_databases`中的业务用户与业务数据库会在集群初始化时自动创建，因此使用该配置时，集群创建完毕后，（在没有DNS支持的情况下）您可以使用以下连接串[访问](c-access.md)数据库（任一即可）：

```bash
postgres://dbuser_grafana:DBUser.Grafana@10.10.10.11:5432/grafana # 主库直连
postgres://dbuser_grafana:DBUser.Grafana@10.10.10.11:5436/grafana # 直连default服务
postgres://dbuser_grafana:DBUser.Grafana@10.10.10.11:5433/grafana # 连接串读写服务

postgres://dbuser_grafana:DBUser.Grafana@10.10.10.12:5432/grafana # 主库直连
postgres://dbuser_grafana:DBUser.Grafana@10.10.10.12:5436/grafana # 直连default服务
postgres://dbuser_grafana:DBUser.Grafana@10.10.10.12:5433/grafana # 连接串读写服务
```

因为默认情况下Pigsty安装在**单个元节点**上，接下来的步骤我们会在已有的`pg-meta`数据库集群上创建Grafana所需的用户与数据库，而并非使用这里创建的`pg-grafana`集群。



## 创建Grafana业务用户

通常业务对象管理的惯例是：先创建用户，再创建数据库。
因为如果为数据库配置了`owner`，数据库对相应的用户存在依赖。

### 定义用户

要在`pg-meta`集群上创建用户`dbuser_grafana`，首先将以下用户定义添加至`pg-meta`的[集群定义](#定义集群)中：

添加位置：`all.children.pg-meta.vars.pg_users`

```yaml
- name: dbuser_grafana
  password: DBUser.Grafana
  comment: admin user for grafana database
  pgbouncer: true
  roles: [ dbrole_admin ]
```

> 如果您在这里定义了不同的密码，请在后续步骤中将相应参数替换为新密码

### 创建用户

使用以下命令完成`dbuser_grafana`用户的创建（任一均可）。

```bash
bin/createuser pg-meta dbuser_grafana # 在pg-meta集群上创建`dbuser_grafana`用户
```

实际上调用了Ansible Playbook [`pgsql-createuser.yml`](p-pgsql-createuser.md) 创建用户

```bash
./pgsql-createuser.yml -l pg-meta -e pg_user=dbuser_grafana  # Ansible
```

`dbrole_admin` 角色具有在数据库中执行DDL变更的权限，这正是Grafana所需要的。



## 创建Grafana业务数据库

### 定义数据库

创建业务数据库的方式与业务用户一致，首先在`pg-meta`的集群定义中添加新数据库`grafana`的[定义](#定义集群)。

添加位置：`all.children.pg-meta.vars.pg_databases`

```yaml
- { name: grafana, owner: dbuser_grafana, revokeconn: true }
```

### 创建数据库

使用以下命令完成`grafana`数据库的创建（任一均可）。

```bash
bin/createdb pg-meta grafana # 在`pg-meta`集群上创建`grafana`数据库
```

实际上调用了Ansible Playbook [`pgsql-createdb.yml`](p-pgsql-createdb.md) 创建数据库

```bash
./pgsql-createdb.yml -l pg-meta -e pg_database=grafana # 实际执行的Ansible剧本
```



## 使用Grafana业务数据库

### 检查连接串可达性

您可以使用不同的[服务](c-service.md)或[接入](c-access.md)方式访问数据库，例如：

```bash
postgres://dbuser_grafana:DBUser.Grafana@meta:5432/grafana # 直连
postgres://dbuser_grafana:DBUser.Grafana@meta:5436/grafana # default服务
postgres://dbuser_grafana:DBUser.Grafana@meta:5433/grafana # primary服务
```

这里，我们将使用通过负载均衡器直接访问主库的[default服务](c-service.md#default服务)访问数据库。

首先检查连接串是否可达，以及是否有权限执行DDL命令。

```bash
psql postgres://dbuser_grafana:DBUser.Grafana@meta:5436/grafana -c \
  'CREATE TABLE t(); DROP TABLE t;'
```

### 直接修改Grafana配置

为了让Grafana使用 Postgres 数据源，您需要编辑 `/etc/grafana/grafana.ini`，并修改配置项：

```ini
[database]
;type = sqlite3
;host = 127.0.0.1:3306
;name = grafana
;user = root
# If the password contains # or ; you have to wrap it with triple quotes. Ex """#password;"""
;password =
;url =
```

将默认的配置项修改为：

```ini
[database]
type = postgres
url =  postgres://dbuser_grafana:DBUser.Grafana@meta/grafana
```

随后重启Grafana即可：

```bash
systemctl restart grafana-server
```

从监控系统中看到新增的 [`grafana`](http://g.pigsty.cc/d/pgsql-database/pgsql-database?var-cls=pg-meta&var-ins=pg-meta-1&var-datname=grafana&orgId=1) 数据库已经开始有活动，则说明Grafana已经开始使用Postgres作为首要后端数据库了。但一个新的问题是，Grafana中原有的Dashboards与Datasources都消失了！这里需要重新导入[监控面板](#管理grafana监控面板)与[Postgres数据源](#管理ostgres数据源)



## 管理Grafana监控面板

您可以使用管理用户前往 Pigsty 目录下的`files/ui`目录，执行`grafana.py init`重新加载Pigsty监控面板。

```bash
cd ~/pigsty/files/ui
./grafana.py init    # 使用当前目录下的Dashboards初始化Grafana监控面板
```

执行结果：

```bash
vagrant@meta:~/pigsty/files/ui
$ ./grafana.py init
Grafana API: admin:pigsty @ http://10.10.10.10:3000
init dashboard : home.json
init folder pgcat
init dashboard: pgcat / pgcat-table.json
init dashboard: pgcat / pgcat-bloat.json
init dashboard: pgcat / pgcat-query.json
init folder pgsql
init dashboard: pgsql / pgsql-replication.json
init dashboard: pgsql / pgsql-table.json
init dashboard: pgsql / pgsql-activity.json
init dashboard: pgsql / pgsql-cluster.json
init dashboard: pgsql / pgsql-node.json
init dashboard: pgsql / pgsql-database.json
init dashboard: pgsql / pgsql-xacts.json
init dashboard: pgsql / pgsql-overview.json
init dashboard: pgsql / pgsql-session.json
init dashboard: pgsql / pgsql-tables.json
init dashboard: pgsql / pgsql-instance.json
init dashboard: pgsql / pgsql-queries.json
init dashboard: pgsql / pgsql-alert.json
init dashboard: pgsql / pgsql-service.json
init dashboard: pgsql / pgsql-persist.json
init dashboard: pgsql / pgsql-proxy.json
init dashboard: pgsql / pgsql-query.json
init folder pglog
init dashboard: pglog / pglog-instance.json
init dashboard: pglog / pglog-analysis.json
init dashboard: pglog / pglog-session.json
```

该脚本会侦测当前的环境（安装时定义于`~/pigsty`），获取Grafana的访问信息，并将监控面板中的URL连接占位符域名（`*.pigsty`）替换为真实使用的域名。

```bash
export GRAFANA_ENDPOINT=http://10.10.10.10:3000
export GRAFANA_USERNAME=admin
export GRAFANA_PASSWORD=pigsty

export NGINX_UPSTREAM_YUMREPO=yum.pigsty
export NGINX_UPSTREAM_CONSUL=c.pigsty
export NGINX_UPSTREAM_PROMETHEUS=p.pigsty
export NGINX_UPSTREAM_ALERTMANAGER=a.pigsty
export NGINX_UPSTREAM_GRAFANA=g.pigsty
export NGINX_UPSTREAM_HAPROXY=h.pigsty
```

题外话，使用`grafana.py clean`会清空目标监控面板，使用`grafana.py load`会加载当前目录下所有监控面板，当Pigsty的监控面板发生变更，可以使用这两个命令升级所有的监控面板。

## 管理Postgres数据源

当使用 [`pgsql.yml`](p-pgsql) 创建新PostgreSQL集群，或使用[`pgsql-createdb.yml`](p-pgsql-createdb)创建新业务数据库时，Pigsty会在Grafana中注册新的PostgreSQL数据源，您可以使用默认的监控用户通过Grafana直接访问目标数据库实例。应用`pgcat`的绝大部分功能有赖于此。

要注册Postgres数据库，可以使用[`pgsql.yml`](p-pgsql)中的`register_grafana`任务：

```bash
./pgsql.yml -t register_grafana             # 重新注册当前环境中所有Postgres数据源
./pgsql.yml -t register_grafana -l pg-test  # 重新注册 pg-test 集群中所有的数据库
```





## 一步到位更新Grafana

您可以直接通过修改Pigsty配置文件，更改Grafana使用的后端数据源，一步到位的完成切换Grafana后端数据库的工作。编辑`pigsty.yml`中[`grafana_database`](v-infra.md#grafana_database)与[`grafana_pgurl`](v-infra.md#grafana_pgurl)参数，将其修改为：

```yaml
grafana_database: postgres
grafana_pgurl: postgres://dbuser_grafana:DBUser.Grafana@meta:5436/grafana
```

然后重新执行 [`infral.yml`](p-meta)中的`grafana`任务，即可完成Grafana升级

```bash
./infra.yml -t grafana
```

