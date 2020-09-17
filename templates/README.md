# Postgres Provision Template

Here are templates for **postgres cluster provision**.

There are two kinds of provision templates:

* The yaml format patroni template are used for cluster provision, there are four default templates
  * [`oltp.yml`](oltp.yml) default template, transactional processing template, optimized for latency 
  * [`olap.yml`](olap.yml) analysis processing template, optimized for throughput
  * [`crit.yml`](crit.yml) critical database template, optimized for security and RPO
  * [`tiny.yml`](tiny.yml) minimum database template, optimized for small instance (e.g 1CPU 1G RAM VM)

* The shell scripts will be executed after cluster bootstrap
  * [`initdb.sh`](initdb.sh) is the default init scripts which create default roles, businesses database and users


## Customization

You can provide your own templates for cluster provision. Just fork existing examples and make your own modifications.
Note that templates are really ansible jinja2 templates, so some of the variables will be passed via `{{ jinjia2 }}` syntax.

To use a customized provision template, passing following variables (by group_vars, inventory vars, or extra args) to `postgres.yml` playbook

```yaml
pg_conf: patroni.yml
pg_init: initdb.sh  
```

For example, the following bash command will use `olap.yml` template and `my-init-script.sh` for cluster provision

```bash
./postgres -l pg-test  -e pg_conf=olap.yml pg_init=my-init-script.sh
```

Templates in `templates` directory will not need absolute path.



# 中文文档：数据库供给模板

有两种类型的数据库模板：初始化模板与初始化脚本。

初始化模板用于控制数据库集群的初始化，使用Patroni的配置文件格式（即时配置为不使用Patroni，系统也会安装Patroni并利用Patroni完成集群的初始化）

初始化脚本则是在数据库被拉起后所执行的自定义Shell脚本。用户可以在这里统一初始化自己的用户与权限系统，创建模板，修改默认权限，创建业务数据库等。


**数据库初始化模板**

初始化模板是用于初始化数据库集群的定义文件，默认位于`roles/postgres/templates/patroni.yml`，采用`patroni.yml` [配置文件格式](https://patroni.readthedocs.io/en/latest/SETTINGS.html)
在[`templates/`](templates/)目录中，有四种预定义好的初始化模板：
* [`oltp.yml`](oltp.yml) 常规OLTP模板，默认配置
* [`olap.yml`](olap.yml) OLAP模板，提高并行度，针对吞吐量优化，针对长时间运行的查询进行优化。
* [`crit.yml`](crit.yml) 核心业务模板，基于OLTP模板针对安全性，数据完整性进行优化，采用同步复制，启用数据校验和。
* [`tiny.yml`](tiny.yml) 微型数据库模板，针对低资源场景进行优化，例如运行于虚拟机中的演示数据库集群。

用户也可以基于上述模板进行定制与修改，并通过`pg_conf`参数使用相应的模板。

**数据库初始化脚本**

当数据库初始化完毕后，用户通常希望对数据库进行自定义的定制脚本，例如创建统一的默认角色，用户，创建默认的模式，配置默认权限等。
本项目提供了一个默认的初始化脚本`roles/postgres/templates/initdb.sh`，基于以下几个变量创建默认的数据库与用户。

```yaml
pg_default_username: postgres                 # non 'postgres' will create a default admin user (not superuser)
pg_default_password: postgres                 # dbsu password, omit for 'postgres'
pg_default_database: postgres                 # non 'postgres' will create a default database
pg_default_schema: public                     # default schema will be create under default database and used as first element of search_path
pg_default_extensions: "tablefunc,postgres_fdw,file_fdw,btree_gist,btree_gin,pg_trgm"
```

用户可以基于本脚本进行定制，并通过`pg_init`参数使用相应的自定义脚本。

