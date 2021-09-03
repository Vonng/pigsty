# 数据库

这里的 **数据库（Database）** 所指代的既非数据库软件，也不是数据库服务器进程，而是指数据库集簇中的一个逻辑对象。
即SQL语句`CREATE DATABASE`所创建的数据库对象。

Pigsty会对默认模板数据库`template1`进行修改与定制，创建默认模式，安装默认扩展，配置默认权限，新创建的数据库默认会从`template1`继承这些设置。

PostgreSQL提供了 模式(Schema) 作为命名空间，因此并不推荐在单个数据库集簇中创建过多数据库。

`pg_exporter` 默认会通过 自动发现 机制查找所有业务数据库并监控。


## 定义数据库

Pigsty通过 `pg_databases` 配置参数定义数据库集群中的数据库，这是一个数据库定义构成的对象数组，
数组内的数据库按照**定义顺序**依次创建，因此后面定义的数据库可以使用先前定义的数据库作为**模板**。

下面是一个数据库定义的例子：

```yaml
pg_databases:                       # define business databases on this cluster, array of database definition
  
  # define the default `meta` database
  - name: meta                      # required, `name` is the only mandatory field of a database definition
    baseline: cmdb.sql              # optional, database sql baseline path, (relative path among ansible search path, e.g files/)
    owner: postgres                 # optional, database owner, postgres by default
    template: template1             # optional, which template to use, template1 by default
    encoding: UTF8                  # optional, database encoding, UTF8 by default. (MUST same as template database)
    locale: C                       # optional, database locale, C by default.  (MUST same as template database)
    lc_collate: C                   # optional, database collate, C by default. (MUST same as template database)
    lc_ctype: C                     # optional, database ctype, C by default.   (MUST same as template database)
    tablespace: pg_default          # optional, default tablespace, 'pg_default' by default.
    allowconn: true                 # optional, allow connection, true by default. false will disable connect at all
    revokeconn: false               # optional, revoke public connection privilege. false by default. (leave connect with grant option to owner)
    pgbouncer: true                 # optional, add this database to pgbouncer database list? true by default
    comment: pigsty meta database   # optional, comment string for this database
    connlimit: -1                   # optional, database connection limit, default -1 disable limit
    schemas: [pigsty]               # optional, additional schemas to be created, array of schema names
    extensions:                     # optional, additional extensions to be installed: array of schema definition `{name,schema}`
      - {name: adminpack, schema: pg_catalog}    # install adminpack to pg_catalog and install postgis to public
      - {name: postgis, schema: public}          # if schema is omitted, extension will be installed according to search_path.
```

* `name`：数据库名称，**必选项**。
* `baseline`：SQL文件路径（Ansible搜索路径，通常位于`files`），用于初始化数据库内容。
* `owner`：数据库属主，默认为`postgres`
* `template`：数据库创建时使用的模板，默认为`template1`
* `encoding`：数据库默认字符编码，默认为`UTF8`，默认与实例保持一致。建议不要配置与修改。
* `locale`：数据库默认的本地化规则，默认为`C`，建议不要配置，与实例保持一致。
* `lc_collate`：数据库默认的本地化字符串排序规则，默认与实例设置相同，建议不要修改，必须与模板数据库一致。强烈建议不要配置，或配置为`C`。
* `lc_ctype`：数据库默认的LOCALE，默认与实例设置相同，建议不要修改或设置，必须与模板数据库一致。建议配置为C或`en_US.UTF8`。
* `allowconn`：是否允许连接至数据库，默认为`true`，不建议修改。
* `revokeconn`：是否回收连接至数据库的权限？默认为`false`。如果为`true`，则数据库上的`PUBLIC CONNECT`权限会被回收。只有默认用户（`dbsu|monitor|admin|replicator|owner`）可以连接。此外，`admin|owner` 会拥有GRANT OPTION，可以赋予其他用户连接权限。
* `tablespace`：数据库关联的表空间，默认为`pg_default`。
* `connlimit`：数据库连接数限制，默认为`-1`，即没有限制。
* `extensions`：对象数组 ，每一个对象定义了一个数据库中的**扩展**，以及其安装的**模式**。
* `parameters`：KV对象，每一个KV定义了一个需要针对数据库通过`ALTER DATABASE`修改的参数。
* `pgbouncer`：布尔选项，是否将该数据库加入到Pgbouncer中。所有数据库都会加入至Pgbouncer列表，除非显式指定`pgbouncer: false`。
* `comment`：数据库备注信息。

**如何为某一个数据库指定不同的Collation规则？**

TBD


## 创建数据库

在创建数据库集群（或主库实例）时，`pg_databases` 定义的数据库会依序自动创建。

可以通过预制的剧本 `pgsql-createdb.yml` 在运行中的已有数据库集群上创建新的业务数据库。

首先，您需要在相应数据库集群配置的 `pg_databases` 配置项中添加该数据库的定义。然后，使用以下命令即可在对应集群上创建该数据库：

```bash
# <pg_cluster> 为集群名称，<dbname> 是新用户名。
# 必须先定义，再执行脚本进行创建
bin/createdb <pg_cluster> <dbname>
bin/createdb pg-meta meta       # 例：在pg-meta集群中创建meta数据库

# 该脚本实际上调用了以下Ansible剧本完成对应任务
./pgsql-createdb.yml -l <pg_cluster> -e pg_database=<dbname>
```

当目标数据库已经存在时，Pigsty会修改目标数据库的属性使其符合配置。

如果您为数据库配置了`owner`参数，则必须确保数据库创建时该用户已经存在。
所以通常建议先完成业务用户的创建，再创建数据库。

该剧本默认会修改并重载数据库集群内所有Pgbouncer的配置`/etc/pgbouncer/database.txt`
但如果被创建的数据库带有`pgbouncer: false`标记，该剧本会跳过Pgbouncer配置阶段

!> 如果数据库会通过连接池对外服务，请**务必通过预置剧本或脚本创建**。


## Pgbouncer

Pgbouncer的操作系统用户将与数据库超级用户保持一致，都使用`{{ pg_dbsu }}`，默认为`postgres`。
Pgbouncer的管理数据库名为`pgbouncer`，可以使用`postgres`与`dbuser_dba`用户进行管理，在操作系统用户`postgres`下执行快捷方式`pgb`即可以管理员身份连接至pgbouncer

Pgbouncer中的数据库列表通过`/etc/pgbouncer/database.txt`文件进行控制，默认内容类似以下格式

```bash
# 数据库名 = 实际目标连接信息
meta = host=/var/run/postgresql
grafana = host=/var/run/postgresql
prometheus = host=/var/run/postgresql
```

在Pigsty中，Pgbouncer与Postgres实例采用1:1同机部署，使用 `/var/run/postgresql` Unix Socket通信。

通常情况下，所有新数据库都会被加入到Pgbouncer的数据库列表中。如果您希望某数据库无法通过Pgbouncer访问，可以在数据库定义中显式指定`pgbouncer: false`。

正常情况下请使用 `pgsql-createdb.yml` 剧本创建新的数据库。亦可在数据库实例上以`postgres`用户执行以下命令来手工添加数据库，需要在集群中所有Pgbouncer上执行该命令并重新加载配置。

```bash
# 特殊情况下可以使用该命令手工添加数据库
/pg/bin/pgbouncer-create-db
# 用法：pgbouncer-create-user <dbname> [connstr] [dblist=/etc/pgbouncer/database.txt]

pgbouncer-create-db meta                     # 创建meta数据库，指向本机同名数据库
pgbouncer-create-db test host=10.10.10.13    # 创建test数据库并将其指向10.10.10.13上的同名数据库 
```

?> 手工修改Pgbouncer配置后，请通过`systemctl reload pgbouncer`重载生效。（切勿使用`pgbouncer -R`）


