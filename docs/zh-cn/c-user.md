# 角色与用户

PostgreSQL提供了标准的访问控制机制：[认证](c-auth.md)（Authentication）与[权限](c-privilege.md)（Privileges），认证与权限都基于[角色](c-user.md)（Role）与[用户](c-user.md)（User）系统。Pigsty提供了开箱即用的访问控制模型，可覆盖绝大多数场景下的安全需求。

本文介绍Pigsty使用的默认角色体系。

Pigsty的默认用户体系包含**四个默认用户**与**四类默认角色**。



## 默认角色

Pigsty带有四个默认角色：

* 只读角色（`dbrole_readonly`）：对所有数据表具有只读权限。
* 读写角色（`dbrole_readwrite`）：对所有数据表具有写入权限，继承`dbrole_readonly`
* 管理角色（`dbrole_admin`）：可以执行DDL变更，继承`dbrole_readwrite`
* 离线角色（`dbrole_offline`）：特殊只读角色，用于执行慢查询/ETL/交互查询，仅允许在特定实例上访问。

其定义如下所示

```yaml
- { name: dbrole_readonly  , login: false , comment: role for global read-only access  }                            # production read-only role
- { name: dbrole_offline ,   login: false , comment: role for restricted read-only access (offline instance) }      # restricted-read-only role
- { name: dbrole_readwrite , login: false , roles: [dbrole_readonly], comment: role for global read-write access }  # production read-write role
- { name: dbrole_admin , login: false , roles: [pg_monitor, dbrole_readwrite] , comment: role for object creation } # production DDL change role
```

!> 不建议新用户修改默认角色的名称



## 默认用户

Pigsty带有四个默认用户：

* 超级用户（`postgres`），数据库的拥有者与创建者，与操作系统用户一致
* 复制用户（`replicator`），用于主从复制的系统用户
* 监控用户（`dbuser_monitor`），用于监控数据库与连接池指标的用户
* 管理员（`dbuser_dba`），执行日常管理操作与数据库变更的管理员用户

其定义如下所示：

```yaml
- { name: postgres , superuser: true , comment: system superuser }                             # system dbsu, name is designated by `pg_dbsu`
- { name: dbuser_dba , superuser: true , roles: [dbrole_admin] , comment: system admin user }  # admin dbsu, name is designated by `pg_admin_username`
- { name: replicator , replication: true , bypassrls: true , roles: [pg_monitor, dbrole_readonly] , comment: system replicator }                   # replicator
- { name: dbuser_monitor , roles: [pg_monitor, dbrole_readonly] , comment: system monitor user , parameters: {log_min_duration_statement: 1000 } } # monitor user
- { name: dbuser_stats , password: DBUser.Stats , roles: [dbrole_offline] , comment: business offline user for offline queries and ETL }           # ETL user
```


## 角色系统

以下是Pigsty自带的8个默认用户/角色的定义

| name             | attr                                                         | roles                                                   | desc                                                    |
| ---------------- | ------------------------------------------------------------ | ------------------------------------------------------- | ------------------------------------------------------- |
| dbrole_readonly  | Cannot login                                                 |                                                         | role for global readonly access                         |
| dbrole_readwrite | Cannot login                                                 | dbrole_readonly                                         | role for global read-write access                       |
| dbrole_offline   | Cannot login                                                 |                                                         | role for restricted read-only access (offline instance) |
| dbrole_admin     | Cannot login<br /> Bypass RLS                                | pg_monitor<br />pg_signal_backend<br />dbrole_readwrite | role for object creation                                |
| postgres         | Superuser<br />Create role<br />Create DB<br />Replication<br />Bypass RLS |                                                         | system superuser                                        |
| replicator       | Replication<br />Bypass RLS                                  | pg_monitor<br />dbrole_readonly                         | system replicator                                       |
| dbuser_monitor   | 16 connections                                               | pg_monitor<br />dbrole_readonly                         | system monitor user                                     |
| dbuser_dba     | Bypass RLS<br />Superuser                                    | dbrole_admin                                            | system admin user                                       |


<details>
<summary>查看原始定义</summary>

```yaml
pg_dbsu: postgres                             # os user for database

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
```

此外，用户可以在 `pg_users` 定义集群特定的业务用户，定义方式与 `pg_default_roles` 一致。

</details>

!> 如果有较高数据安全需求，建议移除 `dbuser_monitor` 的 `dborle_readony` 角色，部分监控系统功能会不可用。


## 密码管理

定义**用户**时，可以通过 `password` 字段为用户指定密码。但三个默认用户的密码由专门的参数独立管理，会覆盖 `pg_default_roles` 中的密码定义，无需在其中进行设置。

```bash
pg_dbsu: postgres                             # os user for database
pg_replication_username: replicator           # system replication user
pg_replication_password: DBUser.Replicator    # system replication password
pg_monitor_username: dbuser_monitor           # system monitor user
pg_monitor_password: DBUser.Monitor           # system monitor password
pg_admin_username: dbuser_dba                 # system admin user
pg_admin_password: DBUser.DBA                 # system admin password
```

出于安全考虑，不建议为默认超级用户`postgres`设置密码或允许远程访问，所以没有专门的`dbsu_password`选项。
如果有此类需求，可在`pg_default_roles`中为超级用户设置密码。 

!> **在生产环境使用时，请务必修改所有默认用户的密码**


## 用户定义

Pigsty通过两个配置参数定义数据库集群中的角色与用户：

* `pg_default_roles`
* `pg_users`

前者定义了整套环境中共有的角色，后者定义单个集群中特有的业务角色与用户。二者形式相同，均为用户定义对象数组。

`pg_default_roles` 定义的角色/用户先于 `pg_users` 创建，数组内的角色/用户按照**定义顺序**创建，后面定义的用户可以属于前面定义的角色。

下面是一个用户定义的例子：

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


## 用户创建

在创建数据库集群（或主库实例）时，`pg_default_roles` 与 `pg_users` 定义的角色和用户会自动依序创建。

可以通过预制的剧本 `pgsql-createuser.yml` 在运行中的已有数据库上创建新的业务用户。

首先，您需要在相应数据库集群配置的 `pg_users` 配置项中添加该用户的定义。然后，使用以下命令即可在对应集群上创建该用户或角色。

```bash
# <pg_cluster> 为集群名称，<username> 是新用户名。
# 必须先定义，再执行脚本进行创建
bin/createuser <pg_cluster> <username>
bin/createuser pg-meta dbuser_meta  # 例：在pg-meta集群中创建dbuser_meta用户

# 该脚本实际上调用了以下Ansible剧本完成对应任务
./pgsql-createuser.yml -l <pg_cluster> -e pg_user=<user.name>
```

当目标用户已经存在时，Pigsty会修改目标用户的属性使其符合配置。

如果被创建的用户带有`pgbouncer: true`标记，该剧本会同时修改并重载数据库集群内所有Pgbouncer的配置`/etc/pgbouncer/userlist.txt`。

!> **务必通过预置剧本或脚本**添加新业务用户与业务数据库，否则难以保证连接池配置信息与数据库同步


## Pgbouncer

Pgbouncer的操作系统用户将与数据库超级用户保持一致，都使用`{{ pg_dbsu }}`，默认为`postgres`。
Pigsty默认使用Postgres管理用户作为Pgbouncer的管理用户，使用Postgres的监控用户同时作为Pgbouncer的监控用户。

Pgbouncer的用户列表通过`/etc/pgbouncer/userlist.txt`文件进行控制，
Pgbouncer的用户权限通过`/etc/pgbouncer/pgb_hba.conf`进行控制。

只有显式添加`pgbouncer: true`配置条目的用户才会被加入到Pgbouncer用户列表中，并通过Pgbouncer访问数据库。
通常生产应用使用的账号应当通过Pgbouncer连接池访问数据库，而个人用户，管理，ETL等则应当直接访问数据库。

正常情况下请使用 `pgsql-createuser.yml` 剧本管理数据库用户。紧急情况下亦可在数据库实例上以`postgres`用户执行以下命令来手工添加用户，需要在集群中所有Pgbouncer上执行该命令并重新加载配置。

```bash
# 紧急情况下可以使用该命令手工添加用户
/pg/bin/pgbouncer-create-user
# 用法：pgbouncer-create-user <username> [password]

pgbouncer-create-user dbp_vonng Test.Password # 明文密码         
pgbouncer-create-user dbp_vonng md596bceae83ba2937778af09adf00ae738 # md5密码
pgbouncer-create-user dbp_vonng auto          # 从数据库查询获取密码
pgbouncer-create-user dbp_vonng null          # 使用空密码
```

