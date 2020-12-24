# Templates [DRAFT]



## Customize

There are two ways to customize pigsty besides of variables, which are **patroni template** and **initdb template**

### **Patroni Template** 

For the sake of unification, Pigsty use patroni for cluster bootstrap even if you choose not enabling it at all.  So you can customize your database cluster with [patroni configuration](https://patroni.readthedocs.io/en/latest/README.html#yaml-configuration).

Pigsty is shipped with four pre-defined patroni [`templates/`](roles/postgres/templates/)

* [`oltp.yml`](oltp.yml) Common OTLP database cluster, default configuration
* [`olap.yml`](olap.yml) OLAP database cluster, increasing throughput and long-run queries
* [`crit.yml`](crit.yml) Critical database cluster which values security and intergity more than availability
* [`tiny.yml`](tiny.yml) Tiny database cluster that runs on small or virtual machine. Which is default for this demo

You can customize those templates or just write your own, and specify template path with variable `pg_conf`


### **Initdb Template**

When database cluster is initialized. there's a chance that user can intercede. E.g: create default roles and users, schemas, privilleges and so forth.

Pigsty will use `../roles/postgres/templates/pg-init` as the default initdb scripts. It is a shell scripts run as dbsu that can do anything to a newly bootstrapped database.

The default initdb scripts will customize database according to following variables:

```yaml
pg_default_username: postgres                 # non 'postgres' will create a default admin user (not superuser)
pg_default_password: postgres                 # dbsu password, omit for 'postgres'
pg_default_database: postgres                 # non 'postgres' will create a default database
pg_default_schema: public                     # default schema will be create under default database and used as first element of search_path
pg_default_extensions: "tablefunc,postgres_fdw,file_fdw,btree_gist,btree_gin,pg_trgm"
```

Of course, you can customize initdb template or just write your own. and specify template path with variable `pg-init`





## 定制初始化模板

在Pigsty中，除了上述的参数变量，还提供两种定制化的方式

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



