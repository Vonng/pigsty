# PostgreSQL模板定制参数

PG Provision负责拉起一套全新的Postgres集群，而PG Template负责在PG Provision的基础上，在这套全新的数据库集群中创建默认的对象，包括

* 基本角色：只读角色，读写角色、管理角色
* 基本用户：复制用户、超级用户、监控用户、管理用户
* 模板数据库中的默认权限
* 默认 模式
* 默认 扩展
* HBA黑白名单规则

## 参数概览

|                          名称                           |     类型      | 层级  | 说明                      |
| :-----------------------------------------------------: | :-----------: | :---: | ------------------------- |
|                   [pg_init](#pg_init)                   |   `string`    |  G/C  | 自定义PG初始化脚本        |
|   [pg_replication_username](#pg_replication_username)   |   `string`    |   G   | PG复制用户                |
|   [pg_replication_password](#pg_replication_password)   |   `string`    |   G   | PG复制用户的密码          |
|       [pg_monitor_username](#pg_monitor_username)       |   `string`    |   G   | PG监控用户                |
|       [pg_monitor_password](#pg_monitor_password)       |   `string`    |   G   | PG监控用户密码            |
|         [pg_admin_username](#pg_admin_username)         |   `string`    |   G   | PG管理用户                |
|         [pg_admin_password](#pg_admin_password)         |   `string`    |   G   | PG管理用户密码            |
|          [pg_default_roles](#pg_default_roles)          |   `role[]`    |   G   | 默认创建的角色与用户      |
|      [pg_default_privilegs](#pg_default_privilegs)      |  `string[]`   |   G   | 数据库默认权限配置        |
|        [pg_default_schemas](#pg_default_schemas)        |  `string[]`   |   G   | 默认创建的模式            |
|     [pg_default_extensions](#pg_default_extensions)     | `extension[]` |   G   | 默认安装的扩展            |
|          [pg_offline_query](#pg_offline_query)          |   `string`    | **I** | 是否允许**离线**查询      |
|                 [pg_reload](#pg_reload)                 |    `bool`     | **A** | 是否重载数据库配置（HBA） |
|              [pg_hba_rules](#pg_hba_rules)              |   `rule[]`    |   G   | 全局HBA规则               |
|        [pg_hba_rules_extra](#pg_hba_rules_extra)        |   `rule[]`    |  C/I  | 集群/实例特定的HBA规则    |
|       [pgbouncer_hba_rules](#pgbouncer_hba_rules)       |   `rule[]`    |  G/C  | Pgbouncer全局HBA规则      |
| [pgbouncer_hba_rules_extra](#pgbouncer_hba_rules_extra) |   `rule[]`    |  G/C  | Pgbounce特定HBA规则       |
|                  [pg_users](#pg_users)                  |   `user[]`    |   C   | 业务用户定义              |
|              [pg_databases](#pg_databases)              | `database[]`  |   C   | 业务数据库定义            |

## 默认参数

```yaml
#------------------------------------------------------------------------------
# POSTGRES TEMPLATE
#------------------------------------------------------------------------------
# - template - #
pg_init: pg-init                              # init script for cluster template

# - system roles - #
pg_replication_username: replicator           # system replication user
pg_replication_password: DBUser.Replicator    # system replication password
pg_monitor_username: dbuser_monitor           # system monitor user
pg_monitor_password: DBUser.Monitor           # system monitor password
pg_admin_username: dbuser_dba                 # system admin user
pg_admin_password: DBUser.DBA                 # system admin password

# - default roles - #
pg_default_roles:                             # check http://pigsty.cc/zh/docs/concepts/provision/acl/ for more detail, sequence matters
  # default roles
  - { name: dbrole_readonly  , login: false , comment: role for global read-only access  }                            # production read-only role
  - { name: dbrole_readwrite , login: false , roles: [dbrole_readonly], comment: role for global read-write access }  # production read-write role
  - { name: dbrole_offline , login: false , comment: role for restricted read-only access (offline instance) }        # restricted-read-only role
  - { name: dbrole_admin , login: false , roles: [pg_monitor, dbrole_readwrite] , comment: role for object creation }  # production DDL change role

  # default users
  - { name: postgres , superuser: true , comment: system superuser }                             # system dbsu, name is designated by `pg_dbsu`
  - { name: dbuser_dba , superuser: true , roles: [dbrole_admin] , comment: system admin user }  # admin dbsu, name is designated by `pg_admin_username`
  - { name: replicator , replication: true , bypassrls: true , roles: [pg_monitor, dbrole_readonly] , comment: system replicator }                   # replicator
  - { name: dbuser_monitor , roles: [pg_monitor, dbrole_readonly] , comment: system monitor user , parameters: {log_min_duration_statement: 1000 } } # monitor user
  - { name: dbuser_stats , password: DBUser.Stats , roles: [dbrole_offline] , comment: business offline user for offline queries and ETL }           # ETL user

# - privileges - #
# object created by dbsu and admin will have their privileges properly set
pg_default_privileges:
  - GRANT USAGE                         ON SCHEMAS   TO dbrole_readonly
  - GRANT SELECT                        ON TABLES    TO dbrole_readonly
  - GRANT SELECT                        ON SEQUENCES TO dbrole_readonly
  - GRANT EXECUTE                       ON FUNCTIONS TO dbrole_readonly
  - GRANT USAGE                         ON SCHEMAS   TO dbrole_offline
  - GRANT SELECT                        ON TABLES    TO dbrole_offline
  - GRANT SELECT                        ON SEQUENCES TO dbrole_offline
  - GRANT EXECUTE                       ON FUNCTIONS TO dbrole_offline
  - GRANT INSERT, UPDATE, DELETE        ON TABLES    TO dbrole_readwrite
  - GRANT USAGE, UPDATE                 ON SEQUENCES TO dbrole_readwrite
  - GRANT TRUNCATE, REFERENCES, TRIGGER ON TABLES    TO dbrole_admin
  - GRANT CREATE                        ON SCHEMAS   TO dbrole_admin

# - schemas - #
pg_default_schemas: [monitor]                 # default schemas to be created

# - extension - #
pg_default_extensions:                        # default extensions to be created
  - { name: 'pg_stat_statements', schema: 'monitor' }
  - { name: 'pgstattuple',        schema: 'monitor' }
  - { name: 'pg_qualstats',       schema: 'monitor' }
  - { name: 'pg_buffercache',     schema: 'monitor' }
  - { name: 'pageinspect',        schema: 'monitor' }
  - { name: 'pg_prewarm',         schema: 'monitor' }
  - { name: 'pg_visibility',      schema: 'monitor' }
  - { name: 'pg_freespacemap',    schema: 'monitor' }
  - { name: 'pg_repack',          schema: 'monitor' }
  - name: postgres_fdw
  - name: file_fdw
  - name: btree_gist
  - name: btree_gin
  - name: pg_trgm
  - name: intagg
  - name: intarray

# - hba - #
pg_offline_query: false                       # set to true to enable offline query on this instance (instance level)
pg_reload: true                               # reload postgres after hba changes
pg_hba_rules:                                 # postgres host-based authentication rules
  - title: allow meta node password access
    role: common
    rules:
      - host    all     all                         10.10.10.10/32      md5

  - title: allow intranet admin password access
    role: common
    rules:
      - host    all     +dbrole_admin               10.0.0.0/8          md5
      - host    all     +dbrole_admin               172.16.0.0/12       md5
      - host    all     +dbrole_admin               192.168.0.0/16      md5

  - title: allow intranet password access
    role: common
    rules:
      - host    all             all                 10.0.0.0/8          md5
      - host    all             all                 172.16.0.0/12       md5
      - host    all             all                 192.168.0.0/16      md5

  - title: allow local read/write (local production user via pgbouncer)
    role: common
    rules:
      - local   all     +dbrole_readonly                                md5
      - host    all     +dbrole_readonly           127.0.0.1/32         md5

  - title: allow offline query (ETL,SAGA,Interactive) on offline instance
    role: offline
    rules:
      - host    all     +dbrole_offline               10.0.0.0/8        md5
      - host    all     +dbrole_offline               172.16.0.0/12     md5
      - host    all     +dbrole_offline               192.168.0.0/16    md5

pg_hba_rules_extra: []                        # extra hba rules (overwrite by cluster/instance level config)

pgbouncer_hba_rules:                          # pgbouncer host-based authentication rules
  - title: local password access
    role: common
    rules:
      - local  all          all                                     md5
      - host   all          all                     127.0.0.1/32    md5

  - title: intranet password access
    role: common
    rules:
      - host   all          all                     10.0.0.0/8      md5
      - host   all          all                     172.16.0.0/12   md5
      - host   all          all                     192.168.0.0/16  md5

pgbouncer_hba_rules_extra: []                 # extra pgbouncer hba rules (overwrite by cluster/instance level config)
# pg_users: []                                # business users
# pg_databases: []                            # business databases
```





## 参数详解

### pg_init

用于初始化数据库模板的Shell脚本位置，默认为`pg-init`，该脚本会被拷贝至`/pg/bin/pg-init`后执行。

默认的`pg-init` 只是预渲染SQL命令的包装：

* `/pg/tmp/pg-init-roles.sql` ： 根据`pg_default_roles`生成的默认角色创建脚本
* `/pg/tmp/pg-init-template.sql`，根据[`pg_default_privileges`](#pg_default_privileges), [`pg_default_schemas`](#pg_default_schemas), [`pg_default_extensions`](#pg_default_extensions) 生产的SQL命令。会同时应用于默认模版数据库`template1`与默认管理数据库`postgres`。

```bash
# system default roles
psql postgres -qAXwtf /pg/tmp/pg-init-roles.sql

# system default template
psql template1 -qAXwtf /pg/tmp/pg-init-template.sql

# make postgres same as templated database (optional)
psql postgres  -qAXwtf /pg/tmp/pg-init-template.sql
```

用户可以在自定义的`pg-init`脚本中添加自己的集群初始化逻辑。



### pg_replication_username

用于执行PostgreSQL流复制的数据库用户名

默认为`replicator`



### pg_replication_password

用于执行PostgreSQL流复制的数据库用户密码，必须使用明文

默认为`DBUser.Replicator`，强烈建议修改！



### pg_monitor_username

用于执行PostgreSQL与Pgbouncer监控任务的数据库用户名

默认为`dbuser_monitor`



### pg_monitor_password

用于执行PostgreSQL与Pgbouncer监控任务的数据库用户密码，必须使用明文

默认为`DBUser.Monitor`，强烈建议修改！



### pg_admin_username

用于执行PostgreSQL数据库管理任务（DDL变更）的数据库用户名，默认带有超级用户权限。

默认为`dbuser_dba`



### pg_admin_password

用于执行PostgreSQL数据库管理任务（DDL变更）的数据库用户密码，必须使用明文

默认为`DBUser.DBA`，强烈建议修改！



### pg_default_roles

定义了PostgreSQL中默认的[角色与用户](c-user.md)，形式为对象数组，每一个对象定义一个用户或角色。

每一个用户或角色必须指定 `name` ，其余字段均为可选项。

* `password`是可选项，如果留空则不设置密码，可以使用MD5密文密码。
* `login`, `superuser`, `createdb`, `createrole`, `inherit`, `replication`, `bypassrls` 都是布尔类型，用于设置用户属性。如果不设置，则采用系统默认值。
* 用户通过`CREATE USER`创建，所以默认具有`login`属性，如果创建的是角色，需要指定`login: false`。
* `expire_at`与`expire_in`用于控制用户过期时间，`expire_at`使用形如`YYYY-mm-DD`的日期时间戳。`expire_in`使用从现在开始的过期天数，如果`expire_in`存在则会覆盖`expire_at`选项。
* 新用户默认**不会**添加至Pgbouncer用户列表中，必须显式定义`pgbouncer: true`，该用户才会被加入到Pgbouncer用户列表。

* 用户/角色会按顺序创建，后面定义的用户可以属于前面定义的角色。

```yaml
pg_users:                           # define business users/roles on this cluster, array of user definition
  # define admin user for meta database (This user are used for pigsty app deployment by default)
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
    parameters:                     # optional, role level parameters with `ALTER ROLE SET`
      log_min_duration_statements: 1000                  
    search_path: public         # key value config parameters according to postgresql documentation (e.g: use pigsty as default search_path)
  - {name: dbuser_view , password: DBUser.Viewer  ,pgbouncer: true ,roles: [dbrole_readonly], comment: read-only viewer for meta database}

  # define additional business users for prometheus & grafana (optional)
  - {name: dbuser_grafana    , password: DBUser.Grafana    ,pgbouncer: true ,roles: [dbrole_admin], comment: admin user for grafana database }
  - {name: dbuser_prometheus , password: DBUser.Prometheus ,pgbouncer: true ,roles: [dbrole_admin], comment: admin user for prometheus database }

```

Pigsty定义了基于四个默认角色与四个默认用户的[认证](c-auth.md)与[权限](c-privilege.md)系统。



### pg_default_privileges

定义数据库模板中的默认权限。

任何由`{{ dbsu」}}`与`{{ pg_admin_username }}`创建的对象都会具有以下默认权限：

```yaml
pg_default_privileges:
  - GRANT USAGE                         ON SCHEMAS   TO dbrole_readonly
  - GRANT SELECT                        ON TABLES    TO dbrole_readonly
  - GRANT SELECT                        ON SEQUENCES TO dbrole_readonly
  - GRANT EXECUTE                       ON FUNCTIONS TO dbrole_readonly
  - GRANT USAGE                         ON SCHEMAS   TO dbrole_offline
  - GRANT SELECT                        ON TABLES    TO dbrole_offline
  - GRANT SELECT                        ON SEQUENCES TO dbrole_offline
  - GRANT EXECUTE                       ON FUNCTIONS TO dbrole_offline
  - GRANT INSERT, UPDATE, DELETE        ON TABLES    TO dbrole_readwrite
  - GRANT USAGE,  UPDATE                ON SEQUENCES TO dbrole_readwrite
  - GRANT TRUNCATE, REFERENCES, TRIGGER ON TABLES    TO dbrole_admin
  - GRANT CREATE                        ON SCHEMAS   TO dbrole_admin
```

详细信息请参考 [访问控制](/zh/docs/deploy/customize/privileges/)。



### pg_default_schemas

创建于模版数据库的默认模式

Pigsty默认会创建名为`monitor`的模式用于安装监控扩展。

```yml
pg_default_schemas: [monitor]                 # default schemas to be created
```



### pg_default_extensions

默认安装于模板数据库的扩展，对象数组。

如果没有指定`schema`字段，扩展会根据当前的`search_path`安装至对应模式中。

```yaml
pg_default_extensions:
  - { name: 'pg_stat_statements',  schema: 'monitor' }
  - { name: 'pgstattuple',         schema: 'monitor' }
  - { name: 'pg_qualstats',        schema: 'monitor' }
  - { name: 'pg_buffercache',      schema: 'monitor' }
  - { name: 'pageinspect',         schema: 'monitor' }
  - { name: 'pg_prewarm',          schema: 'monitor' }
  - { name: 'pg_visibility',       schema: 'monitor' }
  - { name: 'pg_freespacemap',     schema: 'monitor' }
  - { name: 'pg_repack',           schema: 'monitor' }
  - name: postgres_fdw
  - name: file_fdw
  - name: btree_gist
  - name: btree_gin
  - name: pg_trgm
  - name: intagg
  - name: intarray
```



### pg_offline_query

实例级变量，布尔类型，默认为`false`。

设置为`true`时，无论当前实例的角色为何，用户组`dbrole_offline`都可以连接至该实例并执行离线查询。

对于实例数量较少（例如一主一从）的情况较为实用，用户可以将唯一的从库标记为`pg_offline_query = true`，从而接受ETL，慢查询与交互式访问。详细信息请参考 [访问控制-离线用户](/zh/docs/deploy/customize/privileges/)。



### pg_reload

命令行参数，布尔类型，默认为`true`。

设置为`true`时，Pigsty会在生成HBA规则后立刻执行`pg_ctl reload`应用。

当您希望生成`pg_hba.conf`文件，并手工比较后再应用生效时，可以指定`-e pg_reload=false`来禁用它。



### pg_hba_rules

设置数据库的客户端IP黑白名单规则。对象数组，每一个对象都代表一条规则。

每一条规则由三部分组成：

* `title`，规则标题，会转换为HBA文件中的注释
* `role`，应用角色，`common`代表应用至所有实例，其他取值（如`replica`, `offline`）则仅会安装至匹配的角色上。例如`role='replica'`代表这条规则只会应用到`pg_role == 'replica'` 的实例上。
* `rules`，字符串数组，每一条记录代表一条最终写入`pg_hba.conf`的规则。

作为一个特例，`role == 'offline'` 的HBA规则，还会额外安装至 `pg_offline_query == true` 的实例上。

```yaml
pg_hba_rules:
  - title: allow meta node password access
    role: common
    rules:
      - host    all     all                         10.10.10.10/32      md5

  - title: allow intranet admin password access
    role: common
    rules:
      - host    all     +dbrole_admin               10.0.0.0/8          md5
      - host    all     +dbrole_admin               172.16.0.0/12       md5
      - host    all     +dbrole_admin               192.168.0.0/16      md5

  - title: allow intranet password access
    role: common
    rules:
      - host    all             all                 10.0.0.0/8          md5
      - host    all             all                 172.16.0.0/12       md5
      - host    all             all                 192.168.0.0/16      md5

  - title: allow local read-write access (local production user via pgbouncer)
    role: common
    rules:
      - local   all     +dbrole_readwrite                               md5
      - host    all     +dbrole_readwrite           127.0.0.1/32        md5

  - title: allow read-only user (stats, personal) password directly access
    role: replica
    rules:
      - local   all     +dbrole_readonly                               md5
      - host    all     +dbrole_readonly           127.0.0.1/32        md5
```

建议在全局配置统一的`pg_hba_rules`，针对特定集群使用`pg_hba_rules_extra`进行额外定制。




### pg_hba_rules_extra

与`pg_hba_rules`类似，但通常用于集群层面的HBA规则设置。

`pg_hba_rules_extra` 会以同样的方式 **追加** 至`pg_hba.conf`中。

如果用户需要彻底**覆写**集群的HBA规则，即不想继承全局HBA配置，则应当在集群层面配置`pg_hba_rules`并覆盖全局配置。



### pgbouncer_hba_rules

与`pg_hba_rules`类似，用于Pgbouncer的HBA规则设置。

默认的Pgbouncer HBA规则很简单，用户可以按照自己的需求进行定制。

默认的Pgbouncer HBA规则较为宽松：

1. 允许从**本地**使用密码登陆
2. 允许从内网网断使用密码登陆

```yaml
pgbouncer_hba_rules:
  - title: local password access
    role: common
    rules:
      - local  all          all                                     md5
      - host   all          all                     127.0.0.1/32    md5

  - title: intranet password access
    role: common
    rules:
      - host   all          all                     10.0.0.0/8      md5
      - host   all          all                     172.16.0.0/12   md5
      - host   all          all                     192.168.0.0/16  md5
```



### pgbouncer_hba_rules_extra

与`pg_hba_rules_extras`类似，用于在集群层次对Pgbouncer的HBA规则进行额外配置。



### 业务模板

以下两个参数属于**业务模板**，用户应当在这里定义所需的业务用户与业务数据库。

在这里定义的用户与数据库，会在以下两个步骤中完成应用，不仅仅包括数据库中的用户与DB，还有Pgbouncer连接池中的对应配置。

```yaml
./pgsql.yml --tags=pg_biz_init,pg_biz_pgbouncer
```



### pg_users

通常用于在数据库集群层面定义业务用户，与 [`pg_default_roles`](#pg_default_roles) 采用相同的形式。

对象数组，每个对象定义一个业务用户。用户名`name`字段为必选项，密码可以使用MD5密文密码

用户可以通过`roles`字段为业务用户添加默认权限组：

* `dbrole_readonly`：默认生产只读用户，具有全局只读权限。（只读生产访问）
* `dbrole_offline`：默认离线只读用户，在特定实例上具有只读权限。（离线查询，个人账号，ETL）
* `dbrole_readwrite`：默认生产读写用户，具有全局CRUD权限。（常规生产使用）
* `dbrole_admin`：默认生产管理用户，具有执行DDL变更的权限。（管理员）

应当为生产账号配置 `pgbouncer: true`，允许其通过连接池访问，普通用户不应当通过连接池访问数据库。

下面是一个创建业务账号的例子：

```yaml
pg_users:                           # define business users/roles on this cluster, array of user definition
  # define admin user for meta database (This user are used for pigsty app deployment by default)
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
    parameters:                     # optional, role level parameters with `ALTER ROLE SET`
      log_min_duration_statements: 1000
    search_path: public         # key value config parameters according to postgresql documentation (e.g: use pigsty as default search_path)
  - {name: dbuser_view , password: DBUser.Viewer  ,pgbouncer: true ,roles: [dbrole_readonly], comment: read-only viewer for meta database}

  # define additional business users for prometheus & grafana (optional)
  - {name: dbuser_grafana    , password: DBUser.Grafana    ,pgbouncer: true ,roles: [dbrole_admin], comment: admin user for grafana database }
  - {name: dbuser_prometheus , password: DBUser.Prometheus ,pgbouncer: true ,roles: [dbrole_admin], comment: admin user for prometheus database }
```



### pg_databases

对象数组，每个对象定义一个**业务数据库**。每个数据库定义中，数据库名称 `name` 为必选项，其余均为可选项。

* `name`：数据库名称，**必选项**。
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
* `pgbouncer`：布尔选项，是否将该数据库加入到Pgbouncer中。所有数据库都会加入至Pgbouncer，除非显式指定`pgbouncer: false`。
* `comment`：数据库备注信息。

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

