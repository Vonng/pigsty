# PGSQL Business Databases & Users

> How to define & create PostgreSQL business [users](#user) & [databases](#database)



--------------------

## Users

在PostgreSQL中，**用户（User）** 指的是数据库集簇中的一个对象，由SQL语句`CREATE USER/ROLE`所创建。

在PostgreSQL中，**用户**直接隶属于数据库集簇而非某个具体的**数据库**。因此在创建业务数据库和业务用户时，应当遵循"先用户，后数据库"的原则。

## Define User

Pigsty通过两个配置参数定义数据库集群中的角色与用户：

* [`pg_default_roles`](v-pgsql.md#pg_default_roles)
* [`pg_users`](v-pgsql.md#pg_users)

前者定义了整套环境中共有的角色，后者定义单个集群中特有的业务角色与用户。二者形式相同，均为用户定义对象数组。 下面是一个用户定义的例子：

```yaml
- name: dbuser_meta               # required, `name` is the only mandatory field of a user definition
  password: md5d3d10d8cad606308bdb180148bf663e1  # md5 salted password of 'DBUser.Meta'
  # optional, plain text and md5 password are both acceptable (prefixed with `md5`)
  login: true                     # optional, can login, true by default  (new biz ROLE should be false)
  superuser: false                # optional, is superuser? false by default
  createdb: false                 # optional, can create database? false by default
  createrole: false               # optional, can create role? false by default
  inherit: true                   # optional, can this role use inherited privileges? true by default
  replication: false              # optional, can this role do replication? false by default
  bypassrls: false                # optional, can this role bypass row level security? false by default
  pgbouncer: true                 # optional, add this user to pgbouncer user-list? false by default (production user should be true explicitly)
  connlimit: -1                   # optional, user connection limit, default -1 disable limit
  expire_in: 3650                 # optional, now + n days when this role is expired (OVERWRITE expire_at)
  expire_at: '2030-12-31'         # optional, YYYY-MM-DD 'timestamp' when this role is expired  (OVERWRITTEN by expire_in)
  comment: pigsty admin user      # optional, comment string for this user/role
  roles: [dbrole_admin]           # optional, belonged roles. default roles are: dbrole_{admin,readonly,readwrite,offline}
  parameters: {}                  # optional, role level parameters with `ALTER ROLE SET`
  # search_path: public         # key value config parameters according to postgresql documentation (e.g: use pigsty as default search_path)
```

* `name` : 每一个用户或角色必须指定 `name`，唯一的必选参数。
* `password` : 是可选项，如果留空则不设置密码，可以使用MD5密文密码。
* `login`, `superuser`, `createdb`, `createrole`, `inherit`, `replication`, `bypassrls` : 都是布尔类型标记，用于设置用户属性。如果不设置，则采用系统默认值。
  其中`pg_default_roles`的用户默认不带有`login`属性，而`pg_users`默认带有`login`属性，可通过显式配置覆盖。
* `expire_at`与`expire_in`用于控制用户过期时间，`expire_at`使用形如`YYYY-mm-DD`的日期时间戳。`expire_in`使用从现在开始的过期天数，如果`expire_in`存在则会覆盖`expire_at`选项。
* `pgbouncer: true` 用于控制是否将新用户加入Pgbouncer用户列表中，该参数必须显式定义为`true`，相应用户才会被加入到Pgbouncer用户列表。
* `roles` 为该角色/用户所属的分组，可以指定多个分组，例如为用户添加[**默认角色**](#默认角色)。



## Create User

在创建数据库集群（或主库实例）时，[`pg_default_roles`](v-pgsql.md#pg_default_roles) 与 [`pg_users`](v-pgsql.md#pg_users) 定义的角色和用户会自动依序创建。

在运行中的已有数据库集群上，使用预制剧本 [`pgsql-createuser.yml`](p-pgsql.md#pgsql-createuser) 来创建新的业务数据库。

首先，您需要在相应数据库集群配置的 [`pg_users`](v-pgsql.md#pg_users) 配置项中添加该用户的定义。然后，使用以下命令即可在对应集群上创建该用户或角色。

```bash
bin/createuser <pg_cluster> <username>    # <pg_cluster> 为集群名称，<user.name> 是新用户名。必须先定义，再执行脚本进行创建
bin/createuser pg-meta dbuser_meta        # 例：在pg-meta集群中创建dbuser_meta用户
./pgsql-createuser.yml -l <pg_cluster> -e pg_user=<user.name>  # 该脚本实际上调用了以下Ansible剧本完成对应任务
```

当目标用户已经存在时，Pigsty会修改目标用户的属性使其符合配置。

如果被创建的用户带有`pgbouncer: true`标记，该剧本会同时修改并重载数据库集群内所有Pgbouncer的配置`/etc/pgbouncer/userlist.txt`。

!> **务必通过预置剧本或脚本**添加新业务用户与业务数据库，否则难以保证连接池配置信息与数据库同步


### Pgbouncer User

Pgbouncer的操作系统用户将与数据库超级用户保持一致，都使用`{{ pg_dbsu }}`，默认为`postgres`。
Pigsty默认使用Postgres管理用户作为Pgbouncer的管理用户，使用Postgres的监控用户同时作为Pgbouncer的监控用户。

Pgbouncer的用户列表通过`/etc/pgbouncer/userlist.txt`文件进行控制，
Pgbouncer的用户权限通过`/etc/pgbouncer/pgb_hba.conf`进行控制。

只有显式添加`pgbouncer: true`配置条目的用户才会被加入到Pgbouncer用户列表中，并通过Pgbouncer访问数据库。
通常生产应用使用的账号应当通过Pgbouncer连接池访问数据库，而个人用户，管理，ETL等则应当直接访问数据库。

正常情况下请使用 [`pgsql-createuser.yml`](p-pgsql.md#pgsql-createuser) 剧本管理数据库用户。紧急情况下亦可在数据库实例上以`postgres`用户执行以下命令来手工添加用户，需要在集群中所有Pgbouncer上执行该命令并重新加载配置。

```bash
# 紧急情况下可以使用该命令手工添加用户，用法：pgbouncer-create-user <username> [password]
/pg/bin/pgbouncer-create-user

pgbouncer-create-user dbp_vonng Test.Password # 明文密码         
pgbouncer-create-user dbp_vonng md596bceae83ba2937778af09adf00ae738 # md5密码
pgbouncer-create-user dbp_vonng auto          # 从数据库查询获取密码
pgbouncer-create-user dbp_vonng null          # 使用空密码
```










--------------------------


## Database


这里的 **数据库（Database）** 所指代的既非数据库软件，也不是数据库服务器进程，而是指数据库集簇中的一个逻辑对象，由SQL语句`CREATE DATABASE`所创建。

Pigsty会对默认模板数据库`template1`进行修改与定制，创建默认模式，安装默认扩展，配置默认权限，新创建的数据库默认会从`template1`继承这些设置。

PostgreSQL提供了 模式(Schema) 作为命名空间，因此并不推荐在单个数据库集簇中创建过多数据库。

`pg_exporter` 默认会通过 **自动发现** 机制查找所有业务数据库并监控。


## Define Database

Pigsty通过 [`pg_databases`](v-pgsql.md#pg_databases) 配置参数定义数据库集群中的数据库，这是一个数据库定义构成的对象数组，
数组内的数据库按照**定义顺序**依次创建，因此后面定义的数据库可以使用先前定义的数据库作为**模板**。

下面是一个数据库定义的例子：

```yaml
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


## Create Database

在创建数据库集群（或主库实例）时，[`pg_databases`](v-pgsql.md#pg_databases) 定义的数据库会依序自动创建。

在运行中的已有数据库集群上，使用预制剧本 [`pgsql-createdb.yml`](p-pgsql.md#pgsql-createdb) 来创建新的业务数据库。

首先在相应数据库集群配置的 [`pg_databases`](v-pgsql.md#pg_databases) 配置项中添加该数据库的定义。然后，使用以下命令即可在对应集群上创建该数据库：

```bash
bin/createdb <pg_cluster>  <database.name> # <pg_cluster> 为集群名称，<database.name> 是新数据库的name。
bin/createdb pg-meta meta                  # 例：在pg-meta集群中创建meta数据库
./pgsql-createdb.yml -l <pg_cluster> -e pg_database=<dbname>  # 该脚本实际上调用了以下Ansible剧本完成对应任务
```

当目标数据库已经存在时，Pigsty会修改目标数据库的属性使其符合配置。

如果您为数据库配置了`owner`参数，则必须确保数据库创建时该用户已经存在。所以通常建议先完成[业务用户](#用户)的创建，再创建数据库。

该剧本默认会修改并重载数据库集群内所有Pgbouncer的配置`/etc/pgbouncer/database.txt`。但如果被创建的数据库带有`pgbouncer: false`标记，该剧本会跳过Pgbouncer配置阶段

!> 如果数据库会通过连接池对外服务，请**务必通过预置剧本或脚本创建**。


### Pgbouncer Database

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

正常情况下请使用 [`pgsql-createdb.yml`](p-pgsql.md#pgsql-createdb) 剧本创建新的数据库。亦可在数据库实例上以`postgres`用户执行以下命令来手工添加数据库，需要在集群中所有Pgbouncer上执行该命令并重新加载配置。

```bash
# 特殊情况下可以使用该命令手工添加数据库
# pgbouncer-create-user <dbname> [connstr] [dblist=/etc/pgbouncer/database.txt]
/pg/bin/pgbouncer-create-db
pgbouncer-create-db meta                     # 创建meta数据库，指向本机同名数据库
pgbouncer-create-db test host=10.10.10.13    # 创建test数据库并将其指向10.10.10.13上的同名数据库 
```

?> 手工修改Pgbouncer配置后，请通过`systemctl reload pgbouncer`重载生效。（切勿使用`pgbouncer -R`）


