# 升级Grafana后端数据库

您可以使用 postgres 作为Grafana后端使用的数据库。

这是一个很好的机会，了解Pigsty部署系统的使用方式。



## 创建Grafana数据库集群

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

使用以下命令完成数据库集群`pg-grafana`的创建。

```bash
bin/createpg pg-grafana    # 初始化pg-grafana集群
./pgsql.yml -l pg-grafana  # 实际执行的等效Ansible剧本命令 
```

定义在`pg_users`与`pg_databases`中的业务用户与业务数据库会在集群初始化时自动创建，因此使用该配置时，集群创建完毕后，（在没有DNS支持的情况下）您可以使用以下连接串访问数据库（任一即可）：

```bash
postgres://dbuser_grafana:DBUser.Grafana@10.10.10.11:5432/grafana # 主库直连
postgres://dbuser_grafana:DBUser.Grafana@10.10.10.11:5436/grafana # 直连default服务
postgres://dbuser_grafana:DBUser.Grafana@10.10.10.11:5433/grafana # 连接串读写服务
```

因为默认情况下Pigsty安装在单个管理节点上，接下来的步骤我们会在已有的`pg-meta`数据库集群上创建Grafana所需的用户与数据库。



## 创建Grafana业务用户

通常业务对象管理的惯例是：先创建用户，再创建数据库。因为如果为数据库配置了`owner`，数据库对相应的用户存在依赖。

### 定义用户

要在`pg-meta`集群上创建用户`dbuser_grafana`，首先将以下用户定义添加至`pg-meta`的集群定义中：

 (`all.children.pg-meta.vars.pg_users`)

```yaml
- name: dbuser_grafana
  password: DBUser.Grafana
  comment: admin user for grafana database
  pgbouncer: true
  roles: [ dbrole_admin ]
```

> 如果您在这里定义了不同的密码，请在后续步骤中替换为新密码

### 创建用户

使用以下命令完成`dbuser_grafana`用户的创建（任一均可）。

```bash
bin/createuser pg-meta dbuser_grafana # 在pg-meta集群上创建`dbuser_grafana`用户
```

实际上调用了Ansible Playbook [`pgsql-createuser.yml`](p-pgsql-createuser.md) 创建用户

```bash
./pgsql-createuser.yml -l pg-meta -e pg_user=dbuser_grafana  # Ansible
```





## 创建Grafana业务数据库

### 定义数据库

创建业务数据库的方式与业务用户一致，首先在`pg-meta`的集群定义中添加新数据库`grafana`的定义。

 (`all.children.pg-meta.vars.pg_databases`)

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

检查连接串是否可达，以及是否有权限执行DDL命令。

```bash
psql postgres://dbuser_grafana:DBUser.Grafana@meta:5436/grafana -c \
  'CREATE TABLE t(); DROP TABLE t;'
```

 您可以使用不同的[服务](c-service.md)或[接入](c-access.md)方式访问数据库，例如：

```bash
postgres://dbuser_grafana:DBUser.Grafana@meta:5432/grafana # 直连
postgres://dbuser_grafana:DBUser.Grafana@meta:5436/grafana # default服务
postgres://dbuser_grafana:DBUser.Grafana@meta:5433/grafana # primary服务
```

### 修改Pigsty配置

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
systemctl restart grafana
```

从监控系统中看到新增的 [`grafana`](http://g.pigsty.cc/d/pgsql-database/pgsql-database?var-cls=pg-meta&var-ins=pg-meta-1&var-datname=grafana&orgId=1) 数据库已经开始有活动，则说明Grafana已经开始使用Postgres作为首要后端数据库了。

