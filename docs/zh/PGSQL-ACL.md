# PostgreSQL 访问控制

> Pigsty 提供了一套开箱即用的，基于[角色系统](#角色系统)和[权限系统](#权限系统)的访问控制模型。

权限控制很重要，但很多用户做不好。因此 Pigsty 提供了一套开箱即用的精简访问控制模型，为您的集群安全性提供一个兜底。


---------------------

## 角色系统

Pigsty 默认的角色系统包含四个[默认角色](#默认角色)和四个[默认用户](#默认用户)：

| 角色名称               | 属性            | 所属                          | 描述          |
|--------------------|---------------|-----------------------------|-------------|
| `dbrole_readonly`  | `NOLOGIN`     |                             | 角色：全局只读访问   |
| `dbrole_readwrite` | `NOLOGIN`     | dbrole_readonly             | 角色：全局读写访问   |
| `dbrole_admin`     | `NOLOGIN`     | pg_monitor,dbrole_readwrite | 角色：管理员/对象创建 |
| `dbrole_offline`   | `NOLOGIN`     |                             | 角色：受限的只读访问  |
| `postgres`         | `SUPERUSER`   |                             | 系统超级用户      |
| `replicator`       | `REPLICATION` | pg_monitor,dbrole_readonly  | 系统复制用户      |
| `dbuser_dba`       | `SUPERUSER`   | dbrole_admin                | pgsql 管理用户  |
| `dbuser_monitor`   |               | pg_monitor                  | pgsql 监控用户  |

这些[角色与用户](PGSQL-USER#定义用户)的详细定义如下所示：

```yaml
pg_default_roles:                 # 全局默认的角色与系统用户
  - { name: dbrole_readonly  ,login: false ,comment: role for global read-only access     }
  - { name: dbrole_offline   ,login: false ,comment: role for restricted read-only access }
  - { name: dbrole_readwrite ,login: false ,roles: [dbrole_readonly] ,comment: role for global read-write access }
  - { name: dbrole_admin     ,login: false ,roles: [pg_monitor, dbrole_readwrite] ,comment: role for object creation }
  - { name: postgres     ,superuser: true  ,comment: system superuser }
  - { name: replicator ,replication: true  ,roles: [pg_monitor, dbrole_readonly] ,comment: system replicator }
  - { name: dbuser_dba   ,superuser: true  ,roles: [dbrole_admin]  ,pgbouncer: true ,pool_mode: session, pool_connlimit: 16 ,comment: pgsql admin user }
  - { name: dbuser_monitor ,roles: [pg_monitor] ,pgbouncer: true ,parameters: {log_min_duration_statement: 1000 } ,pool_mode: session ,pool_connlimit: 8 ,comment: pgsql monitor user }
```


---------------------

## 默认角色

Pigsty 中有四个默认角色：

- 业务只读 (`dbrole_readonly`): 用于全局只读访问的角色。如果别的业务想要此库只读访问权限，可以使用此角色。
- 业务读写 (`dbrole_readwrite`): 用于全局读写访问的角色，主属业务使用的生产账号应当具有数据库读写权限
- 业务管理员 (`dbrole_admin`): 拥有DDL权限的角色，通常用于业务管理员，或者需要在应用中建表的场景（比如各种业务软件）
- 离线只读访问 (`dbrole_offline`): 受限的只读访问角色（只能访问 [offline](PGSQL-CONF#offline) 实例，通常是个人用户，ETL工具账号）

默认角色在 [`pg_default_roles`](PARAM#pg_default_roles) 中定义，除非您确实知道自己在干什么，建议不要更改默认角色的名称。

```yaml
- { name: dbrole_readonly  , login: false , comment: role for global read-only access  }                            # 生产环境的只读角色
- { name: dbrole_offline ,   login: false , comment: role for restricted read-only access (offline instance) }      # 受限的只读角色
- { name: dbrole_readwrite , login: false , roles: [dbrole_readonly], comment: role for global read-write access }  # 生产环境的读写角色
- { name: dbrole_admin , login: false , roles: [pg_monitor, dbrole_readwrite] , comment: role for object creation } # 生产环境的 DDL 更改角色
```


---------------------

## 默认用户

Pigsty 也有四个默认用户（系统用户）：

- 超级用户 (`postgres`)，集群的所有者和创建者，与操作系统 dbsu 名称相同。
- 复制用户 (`replicator`)，用于主-从复制的系统用户。
- 监控用户 (`dbuser_monitor`)，用于监控数据库和连接池指标的用户。
- 管理用户 (`dbuser_dba`)，执行日常操作和数据库更改的管理员用户。

这4个默认用户的用户名/密码通过4对专用参数进行定义，并在很多地方引用：

- [`pg_dbsu`](PARAM#pg_dbsu)：操作系统 dbsu 名称，默认为 postgres，最好不要更改它
- [`pg_dbsu_password`](PARAM#pg_dbsu_password)：dbsu 密码，默认为空字符串意味着不设置 dbsu 密码，最好不要设置。
- [`pg_replication_username`](PARAM#pg_replication_username)：postgres 复制用户名，默认为 `replicator`
- [`pg_replication_password`](PARAM#pg_replication_password)：postgres 复制密码，默认为 `DBUser.Replicator`
- [`pg_admin_username`](PARAM#pg_admin_username)：postgres 管理员用户名，默认为 `dbuser_dba`
- [`pg_admin_password`](PARAM#pg_admin_password)：postgres 管理员密码的明文，默认为 `DBUser.DBA`
- [`pg_monitor_username`](PARAM#pg_monitor_username)：postgres 监控用户名，默认为 `dbuser_monitor`
- [`pg_monitor_password`](PARAM#pg_monitor_password)：postgres 监控密码，默认为 `DBUser.Monitor`

> **在生产部署中记得更改这些密码，不要使用默认值！** 

```yaml
pg_dbsu: postgres                             # 数据库超级用户名，这个用户名建议不要修改。
pg_dbsu_password: ''                          # 数据库超级用户密码，这个密码建议留空！禁止dbsu密码登陆。
pg_replication_username: replicator           # 系统复制用户名
pg_replication_password: DBUser.Replicator    # 系统复制密码，请务必修改此密码！
pg_monitor_username: dbuser_monitor           # 系统监控用户名
pg_monitor_password: DBUser.Monitor           # 系统监控密码，请务必修改此密码！
pg_admin_username: dbuser_dba                 # 系统管理用户名
pg_admin_password: DBUser.DBA                 # 系统管理密码，请务必修改此密码！
```

如果您修改默认用户的参数，在 [`pg_default_roles`](PARAM#pg_default_roles) 中修改相应的角色[定义](PGSQL-USER#定义用户)即可：

```yaml
- { name: postgres     ,superuser: true                                          ,comment: system superuser }
- { name: replicator ,replication: true  ,roles: [pg_monitor, dbrole_readonly]   ,comment: system replicator }
- { name: dbuser_dba   ,superuser: true  ,roles: [dbrole_admin]  ,pgbouncer: true ,pool_mode: session, pool_connlimit: 16 , comment: pgsql admin user }
- { name: dbuser_monitor   ,roles: [pg_monitor, dbrole_readonly] ,pgbouncer: true ,parameters: {log_min_duration_statement: 1000 } ,pool_mode: session ,pool_connlimit: 8 ,comment: pgsql monitor user }
```



---------------------

## 权限系统

Pigsty has a battery-included privilege model that works with [default roles](#default-roles).

* All users have access to all schemas.
* Read-Only user can read from all tables. (SELECT, EXECUTE)
* Read-Write user can write to all tables run DML. (INSERT, UPDATE, DELETE).
* Admin user can create object and run DDL (CREATE, USAGE, TRUNCATE, REFERENCES, TRIGGER). 
* Offline user is Read-Only user with limited access on offline instance (`pg_role = 'offline'` or `pg_offline_query = true`)
* Object created by admin users will have correct privilege.
* Default privileges are installed on all databases, including template database. 
* Database connect privilege is covered by database [definition](PGSQL-DB#define-database) 
* `CREATE` privileges of database & public schema are revoked from `PUBLIC` by default 



---------------------

## 对象权限

数据库中新建对象的默认权限由参数 [`pg_default_privileges`](PARAM#pg_default_privileges) 所控制：

```yaml
- GRANT USAGE      ON SCHEMAS   TO dbrole_readonly
- GRANT SELECT     ON TABLES    TO dbrole_readonly
- GRANT SELECT     ON SEQUENCES TO dbrole_readonly
- GRANT EXECUTE    ON FUNCTIONS TO dbrole_readonly
- GRANT USAGE      ON SCHEMAS   TO dbrole_offline
- GRANT SELECT     ON TABLES    TO dbrole_offline
- GRANT SELECT     ON SEQUENCES TO dbrole_offline
- GRANT EXECUTE    ON FUNCTIONS TO dbrole_offline
- GRANT INSERT     ON TABLES    TO dbrole_readwrite
- GRANT UPDATE     ON TABLES    TO dbrole_readwrite
- GRANT DELETE     ON TABLES    TO dbrole_readwrite
- GRANT USAGE      ON SEQUENCES TO dbrole_readwrite
- GRANT UPDATE     ON SEQUENCES TO dbrole_readwrite
- GRANT TRUNCATE   ON TABLES    TO dbrole_admin
- GRANT REFERENCES ON TABLES    TO dbrole_admin
- GRANT TRIGGER    ON TABLES    TO dbrole_admin
- GRANT CREATE     ON SCHEMAS   TO dbrole_admin
```

由管理员**新创建**的对象，默认将会上述权限。使用 `\ddp+` 可以查看这些默认权限：

| 类型  | 访问权限                 |
|-----|----------------------|
| 函数  | =X                   |
|     | dbrole_readonly=X    |
|     | dbrole_offline=X     |
|     | dbrole_admin=X       |
| 模式  | dbrole_readonly=U    |
|     | dbrole_offline=U     |
|     | dbrole_admin=UC      |
| 序列号 | dbrole_readonly=r    |
|     | dbrole_offline=r     |
|     | dbrole_readwrite=wU  |
|     | dbrole_admin=rwU     |
| 表   | dbrole_readonly=r    |
|     | dbrole_offline=r     |
|     | dbrole_readwrite=awd |
|     | dbrole_admin=arwdDxt |




---------------------

## 默认权限

[`ALTER DEFAULT PRIVILEGES`](https://www.postgresql.org/docs/current/sql-alterdefaultprivileges.html) 允许您设置将来创建的对象的权限。 它不会影响已经存在对象的权限，也不会影响非管理员用户创建的对象。

在 Pigsty 中，默认权限针对三个角色进行定义：

```sql
{% for priv in pg_default_privileges %}
ALTER DEFAULT PRIVILEGES FOR ROLE {{ pg_dbsu }} {{ priv }};
{% endfor %}

{% for priv in pg_default_privileges %}
ALTER DEFAULT PRIVILEGES FOR ROLE {{ pg_admin_username }} {{ priv }};
{% endfor %}

-- 对于其他业务管理员而言，它们应当在执行 DDL 前执行 SET ROLE dbrole_admin，从而使用对应的默认权限配置。
{% for priv in pg_default_privileges %}
ALTER DEFAULT PRIVILEGES FOR ROLE "dbrole_admin" {{ priv }};
{% endfor %}
```

这些内容将会被 PG集群初始化模板 [`pg-init-template.sql`](https://github.com/Vonng/pigsty/blob/master/roles/pgsql/templates/pg-init-template.sql) 所使用，在集群初始化的过程中渲染并输出至 `/pg/tmp/pg-init-template.sql`。
该命令会在 `template1` 与 `postgres` 数据库中执行，新创建的数据库会通过模板 `template1` 继承这些默认权限配置。




也就是说，为了维持正确的对象权限，您必须用**管理员用户**来执行 DDL，它们可以是：

1. [`{{ pg_dbsu }}`](https://chat.openai.com/PARAM#pg_dbsu)，默认为 `postgres`
2. [`{{ pg_admin_username }}`](https://chat.openai.com/PARAM#pg_admin_username)，默认为 `dbuser_dba`
3. 授予了 `dbrole_admin` 角色的业务管理员用户（通过 `SET ROLE` 切换为 `dbrole_admin` 身份）。

使用 `postgres` 作为全局对象所有者是明智的。如果您希望以业务管理员用户身份创建对象，创建之前必须使用 `SET ROLE dbrole_admin` 来维护正确的权限。

当然，您也可以在数据库中通过 `ALTER DEFAULT PRIVILEGE FOR ROLE <some_biz_admin> XXX` 来显式对业务管理员授予默认权限。



---------------------

## 数据库权限

在 Pigsty 中，数据库（Database）层面的权限在[数据库定义](#定义数据库)中被涵盖。

数据库有三个级别的权限：`CONNECT`、`CREATE`、`TEMP`，以及一个特殊的'权限'：`OWNERSHIP`。

```yaml
- name: meta         # 必选，`name` 是数据库定义中唯一的必选字段
  owner: postgres    # 可选，数据库所有者，默认为 postgres
  allowconn: true    # 可选，是否允许连接，默认为 true。显式设置 false 将完全禁止连接到此数据库
  revokeconn: false  # 可选，撤销公共连接权限。默认为 false，设置为 true 时，属主和管理员之外用户的 CONNECT 权限会被回收
```

* If `owner` exists, it will be used as database owner instead of default [`{{ pg_dbsu }}`](PARAM#pg_dbsu)
* If `revokeconn` is `false`, all users have the `CONNECT` privilege of the database, this is the default behavior.
* If `revokeconn` is set to `true` explicitly:
  * `CONNECT` privilege of the database will be revoked from `PUBLIC`
  * `CONNECT` privilege will be granted to `{{ pg_replication_username }}`, `{{ pg_monitor_username }}` and `{{ pg_admin_username }}` 
  * `CONNECT` privilege will be granted to database owner with `GRANT OPTION`

`revokeconn` flag can be used for database access isolation, you can create different business users as the owners for each database and set the `revokeconn` option for all of them. 


- 如果 `owner` 参数存在，它作为数据库属主，替代默认的 [`{{ pg_dbsu }}`](https://chat.openai.com/PARAM#pg_dbsu)（通常也就是`postgres`）
- 如果 `revokeconn` 为 `false`，所有用户都有数据库的 `CONNECT` 权限，这是默认的行为。
- 如果显式设置了 `revokeconn` 为 `true`：
  - 数据库的 `CONNECT` 权限将从 `PUBLIC` 中撤销：普通用户无法连接上此数据库
  - `CONNECT` 权限将被显式授予 `{{ pg_replication_username }}`、`{{ pg_monitor_username }}` 和 `{{ pg_admin_username }}`
  - `CONNECT` 权限将 `GRANT OPTION` 被授予数据库属主，数据库属主用户可以自行授权其他用户连接权限。
- `revokeconn` 选项可用于在同一个集群间隔离跨数据库访问，您可以为每个数据库创建不同的业务用户作为属主，并为它们设置 `revokeconn` 选项。


<details><summary>示例：数据库隔离</summary>

```yaml
pg-infra:
  hosts:
    10.10.10.40: { pg_seq: 1, pg_role: primary }
    10.10.10.41: { pg_seq: 2, pg_role: replica , pg_offline_query: true }
  vars:
    pg_cluster: pg-infra
    pg_users:
      - { name: dbuser_confluence, password: mc2iohos , pgbouncer: true, roles: [ dbrole_admin ] }
      - { name: dbuser_gitlab, password: sdf23g22sfdd , pgbouncer: true, roles: [ dbrole_readwrite ] }
      - { name: dbuser_jira, password: sdpijfsfdsfdfs , pgbouncer: true, roles: [ dbrole_admin ] }
    pg_databases:
      - { name: confluence , revokeconn: true, owner: dbuser_confluence , connlimit: 100 }
      - { name: gitlab , revokeconn: true, owner: dbuser_gitlab, connlimit: 100 }
      - { name: jira , revokeconn: true, owner: dbuser_jira , connlimit: 100 }

```

</details>




---------------------

## CREATE权限

出于安全考虑，Pigsty 默认从 `PUBLIC` 撤销数据库上的 `CREATE` 权限，从 PostgreSQL 15 开始这也是默认行为。

数据库属主总是可以根据实际需要，来自行调整 CREATE 权限。

