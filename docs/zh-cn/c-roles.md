# 访问控制

> 介绍Pigsty中的访问控制模型

PostgreSQL提供了两类访问控制机制：**[认证](c-auth.md)（Authentication）**  与  **[权限](c-privileges.md)（Privileges）**

Pigsty带有基本的访问控制模型，足以覆盖绝大多数应用场景。



## 用户体系

Pigsty的默认权限系统包含**四个默认用户**与**四类默认角色** 。

用户可以通过修改 `pg_default_roles` 变量 来修改默认**用户**的名字，但默认**角色**的名字不建议新用户自行修改。

### 默认角色

Pigsty带有四个默认角色：

* 只读角色（`dbrole_readonly`）：只读
* 读写角色（`dbrole_readwrite`）：读写，继承`dbrole_readonly`
* 管理角色（`dbrole_admin`）：执行DDL变更，继承`dbrole_readwrite`
* 离线角色（`dbrole_offline`）：只读，用于执行慢查询/ETL/交互查询，仅允许在特定实例上访问。

```yaml
- { name: dbrole_readonly  , login: false , comment: role for global read-only access  }                            # production read-only role
- { name: dbrole_offline ,   login: false , comment: role for restricted read-only access (offline instance) }      # restricted-read-only role
- { name: dbrole_readwrite , login: false , roles: [dbrole_readonly], comment: role for global read-write access }  # production read-write role
- { name: dbrole_admin , login: false , roles: [pg_monitor, dbrole_readwrite] , comment: role for object creation } # production DDL change role
```

### 默认用户

!> 在生产环境使用时，务必修改默认用户密码！

Pigsty带有四个默认用户：

* 超级用户（`postgres`），数据库的拥有者与创建者，与操作系统用户一致
* 复制用户（`replicator`），用于主从复制的用户。
* 监控用户（`dbuser_monitor`），用于监控数据库指标的用户。
* 管理员（`dbuser_dba`），执行日常管理操作与数据库变更，通常供DBA使用

其定义如下所示：

```yaml
- { name: postgres , superuser: true , comment: system superuser }                             # system dbsu, name is designated by `pg_dbsu`
- { name: dbuser_dba , superuser: true , roles: [dbrole_admin] , comment: system admin user }  # admin dbsu, name is designated by `pg_admin_username`
- { name: replicator , replication: true , bypassrls: true , roles: [pg_monitor, dbrole_readonly] , comment: system replicator }                   # replicator
- { name: dbuser_monitor , roles: [pg_monitor, dbrole_readonly] , comment: system monitor user , parameters: {log_min_duration_statement: 1000 } } # monitor user
- { name: dbuser_stats , password: DBUser.Stats , roles: [dbrole_offline] , comment: business offline user for offline queries and ETL }           # ETL user
```

### 默认角色系统

以下是8个默认用户/角色的的定义

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

其中，四个默认用户有专用的用户名与密码配置选项，会覆盖`pg_default_roles`中的选项。因此无需在其中为默认用户配置密码。

```bash
pg_dbsu: postgres                             # os user for database
pg_replication_username: replicator           # system replication user
pg_replication_password: DBUser.Replicator    # system replication password
pg_monitor_username: dbuser_monitor           # system monitor user
pg_monitor_password: DBUser.Monitor           # system monitor password
pg_admin_username: dbuser_dba                 # system admin user
pg_admin_password: DBUser.DBA                 # system admin password
```

?> 出于安全考虑，不建议为默认超级用户`postgres`设置密码或允许远程访问。



<details>
<summary>默认角色系统相关参数</summary>

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

### Pgbouncer用户

Pgbouncer的操作系统用户将与数据库超级用户保持一致，默认都使用`{{ pg_dbsu }}`。

Pigsty默认使用Postgres管理用户作为Pgbouncer的管理用户，使用Postgres的监控用户同时作为Pgbouncer的监控用户。

Pgbouncer的用户权限通过`/etc/pgbouncer/pgb_hba.conf`进行控制。

Pgbounce的用户列表通过`/etc/pgbouncer/userlist.txt`文件进行控制。

定义用户时，只有显式添加`pgbouncer: true` 的用户，才会被加入到Pgbouncer的用户列表中。

!> **务必通过预置剧本或脚本**添加新业务用户与业务数据库，否则难以保证连接池配置信息与数据库同步



----------------------



## 权限模型

默认情况下，角色拥有的权限如下所示：

```sql
GRANT USAGE                         ON SCHEMAS   TO dbrole_readonly
GRANT SELECT                        ON TABLES    TO dbrole_readonly
GRANT SELECT                        ON SEQUENCES TO dbrole_readonly
GRANT EXECUTE                       ON FUNCTIONS TO dbrole_readonly
GRANT USAGE                         ON SCHEMAS   TO dbrole_offline
GRANT SELECT                        ON TABLES    TO dbrole_offline
GRANT SELECT                        ON SEQUENCES TO dbrole_offline
GRANT EXECUTE                       ON FUNCTIONS TO dbrole_readonly
GRANT INSERT, UPDATE, DELETE        ON TABLES    TO dbrole_readwrite
GRANT USAGE,  UPDATE                ON SEQUENCES TO dbrole_readwrite
GRANT TRUNCATE, REFERENCES, TRIGGER ON TABLES    TO dbrole_admin
GRANT CREATE                        ON SCHEMAS   TO dbrole_admin
GRANT USAGE                         ON TYPES     TO dbrole_admin
```

其他业务用户默认都应当属于四种默认角色之一：**只读**，**读写**，**管理员**，**离线访问**。

| Owner    | Schema | Type     | Access privileges             |
| -------- | ------ | -------- | ----------------------------- |
| username |        | function | =X/postgres                   |
|          |        |          | postgres=X/postgres           |
|          |        |          | dbrole_readonly=X/postgres    |
|          |        |          | dbrole_offline=X/postgres     |
| username |        | schema   | postgres=UC/postgres          |
|          |        |          | dbrole_readonly=U/postgres    |
|          |        |          | dbrole_offline=U/postgres     |
|          |        |          | dbrole_admin=C/postgres       |
| username |        | sequence | postgres=rwU/postgres         |
|          |        |          | dbrole_readonly=r/postgres    |
|          |        |          | dbrole_readwrite=wU/postgres  |
|          |        |          | dbrole_offline=r/postgres     |
| username |        | table    | postgres=arwdDxt/postgres     |
|          |        |          | dbrole_readonly=r/postgres    |
|          |        |          | dbrole_readwrite=awd/postgres |
|          |        |          | dbrole_offline=r/postgres     |
|          |        |          | dbrole_admin=Dxt/postgres     |



所有用户都可以访问所有模式，只读用户可以读取所有表，读写用户可以对所有表进行DML操作，管理员可以执行DDL变更操作。离线用户与只读用户类似，但只允许访问`pg_role == 'offline'` 或带有 `pg_offline_query = true` 的实例。


### 数据库权限

数据库有三种权限：`CONNECT`, `CREATE`, `TEMP`，以及特殊的属主`OWNERSHIP`。数据库的定义由参数 [`pg_database`](../../..//config/8-pg-template/#pg_databases)  控制。一个完整的数据库定义如下所示：

```yaml
pg_databases:
  - name: meta                      # name is the only required field for a database
    owner: postgres                 # optional, database owner
    template: template1             # optional, template1 by default
    encoding: UTF8                  # optional, UTF8 by default
    locale: C                       # optional, C by default
    allowconn: true                 # optional, true by default, false disable connect at all
    revokeconn: false               # optional, false by default, true revoke connect from public # (only default user and owner have connect privilege on database)
    tablespace: pg_default          # optional, 'pg_default' is the default tablespace
    connlimit: -1                   # optional, connection limit, -1 or none disable limit (default)
    extensions:                     # optional, extension name and where to create
      - {name: postgis, schema: public}
    parameters:                     # optional, extra parameters with ALTER DATABASE
      enable_partitionwise_join: true
    pgbouncer: true                 # optional, add this database to pgbouncer list? true by default
    comment: pigsty meta database   # optional, comment string for database
```

默认情况下，如果数据库没有配置属主，那么数据库超级用户`dbsu`将会作为数据库的默认`OWNER`，否则将为指定用户。

默认情况下，所有用户都具有对新创建数据库的`CONNECT` 权限，如果希望回收该权限，设置 `revokeconn == true`，则该权限会被回收。只有默认用户（dbsu|admin|monitor|replicator）与数据库的属主才会被显式赋予`CONNECT`权限。同时，`admin|owner`将会具有`CONNECT`权限的`GRANT OPTION`，可以将`CONNECT`权限转授他人。

如果希望实现不同数据库之间的**访问隔离**，可以为每一个数据库创建一个相应的业务用户作为`owner`，并全部设置`revokeconn`选项。这种配置对于多租户实例尤为实用。

### 创建新对象

默认情况下，出于安全考虑，Pigsty会撤销`PUBLIC`用户在数据库下`CREATE`新模式的权限，同时也会撤销`PUBLIC`用户在`public`模式下创建新关系的权限。数据库超级用户与管理员不受此限制，他们总是可以在任何地方执行DDL变更。

Pigsty非常不建议使用业务用户执行DDL变更，因为PostgreSQL的`ALTER DEFAULT PRIVILEGE`仅针对“由特定用户创建的对象”生效，默认情况下超级用户`postgres`和`dbuser_dba`创建的对象拥有默认的权限配置，如果用户希望授予业务用户`dbrole_admin`，请在使用该业务管理员执行DDL变更时首先执行：

```sql
SET ROLE dbrole_admin; -- dbrole_admin 创建的对象具有正确的默认权限
```

在数据库中创建对象的权限与用户是否为数据库属主无关，这只取决于创建该用户时是否为该用户赋予管理员权限。

```yaml
pg_users:
  - {name: test1, password: xxx , groups: [dbrole_readwrite]}  # 不能创建Schema与对象
  - {name: test2, password: xxx , groups: [dbrole_admin]}      # 可以创建Schema与对象
```






## 认证模型

HBA是Host Based Authentication的缩写，可以将其视作IP黑白名单。

### HBA配置方式

在Pigsty中，所有实例的HBA都由配置文件生成而来，最终生成的HBA规则取决于实例的角色（`pg_role`）
Pigsty的HBA由下列变量控制：

* `pg_hba_rules`: 环境统一的HBA规则
* `pg_hba_rules_extra`: 特定于实例或集群的HBA规则
* `pgbouncer_hba_rules`: 链接池使用的HBA规则
* `pgbouncer_hba_rules_extra`: 特定于实例或集群的链接池HBA规则

每个变量都是由下列样式的规则组成的数组：

```yaml
- title: allow intranet admin password access
  role: common
  rules:
    - host    all     +dbrole_admin               10.0.0.0/8          md5
    - host    all     +dbrole_admin               172.16.0.0/12       md5
    - host    all     +dbrole_admin               192.168.0.0/16      md5
```



### 基于角色的HBA

`role = common`的HBA规则组会安装到所有的实例上，而其他的取值，例如（`role : primary`）则只会安装至`pg_role = primary`的实例上。因此用户可以通过角色体系定义灵活的HBA规则。

作为一个**特例**，`role: offline` 的HBA规则，除了会安装至`pg_role == 'offline'`的实例，也会安装至`pg_offline_query == true`的实例上。



### 默认配置

在默认配置下，主库与从库会使用以下的HBA规则：

* 超级用户通过本地操作系统认证访问
* 其他用户可以从本地用密码访问
* 复制用户可以从局域网段通过密码访问
* 监控用户可以通过本地访问
* 所有人都可以在元节点上使用密码访问
* 管理员可以从局域网通过密码访问
* 所有人都可以从内网通过密码访问
* 读写用户（生产业务账号）可以通过本地（链接池）访问
  （部分访问控制转交链接池处理）
* 在从库上：只读用户（个人）可以从本地（链接池）访问。
  （意味主库上拒绝只读用户连接）
* `pg_role == 'offline'` 或带有`pg_offline_query == true`的实例上，会添加允许`dbrole_offline`分组用户访问的HBA规则。

<details>

```ini
#==============================================================#
# Default HBA
#==============================================================#
# allow local su with ident"
local   all             postgres                               ident
local   replication     postgres                               ident

# allow local user password access
local   all             all                                    md5

# allow local/intranet replication with password
local   replication     replicator                              md5
host    replication     replicator         127.0.0.1/32         md5
host    all             replicator         10.0.0.0/8           md5
host    all             replicator         172.16.0.0/12        md5
host    all             replicator         192.168.0.0/16       md5
host    replication     replicator         10.0.0.0/8           md5
host    replication     replicator         172.16.0.0/12        md5
host    replication     replicator         192.168.0.0/16       md5

# allow local role monitor with password
local   all             dbuser_monitor                          md5
host    all             dbuser_monitor      127.0.0.1/32        md5

#==============================================================#
# Extra HBA
#==============================================================#
# add extra hba rules here




#==============================================================#
# primary HBA
#==============================================================#


#==============================================================#
# special HBA for instance marked with 'pg_offline_query = true'
#==============================================================#



#==============================================================#
# Common HBA
#==============================================================#
#  allow meta node password access
host    all     all                         10.10.10.10/32      md5

#  allow intranet admin password access
host    all     +dbrole_admin               10.0.0.0/8          md5
host    all     +dbrole_admin               172.16.0.0/12       md5
host    all     +dbrole_admin               192.168.0.0/16      md5

#  allow intranet password access
host    all             all                 10.0.0.0/8          md5
host    all             all                 172.16.0.0/12       md5
host    all             all                 192.168.0.0/16      md5

#  allow local read/write (local production user via pgbouncer)
local   all     +dbrole_readonly                                md5
host    all     +dbrole_readonly           127.0.0.1/32         md5





#==============================================================#
# Ad Hoc HBA
#===========================================================
```

</details>

