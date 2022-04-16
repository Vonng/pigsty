# PGSQL 权限认证与访问控制

Pigsty提供了一套开箱即用的访问控制模型，简单实用，可满足基本安全需求。

PostgreSQL提供了标准的访问控制机制：[认证](#认证)（Authentication）与[权限](#权限)（Privileges），认证与权限都基于[角色](#角色)（Role）体系进行。

---------------------

## 角色

Pigsty的默认角色体系包含四个[默认角色](#默认角色)，以及四个[默认用户](#默认用户)。

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


### 默认角色

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

!> 不建议普通用户修改默认角色的名称

### 默认用户

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
```

在Pigsty中，4个默认的重要用户的用户名和密码是由独立参数控制与管理的：

```yaml
pg_dbsu: postgres                             # os user for database

# - system roles - #
pg_replication_username: replicator           # system replication user
pg_replication_password: DBUser.Replicator    # system replication password
pg_monitor_username: dbuser_monitor           # system monitor user
pg_monitor_password: DBUser.Monitor           # system monitor password
pg_admin_username: dbuser_dba                 # system admin user
pg_admin_password: DBUser.DBA                 # system admin password
```

出于安全考虑，不建议为默认超级用户`postgres`设置密码或允许远程访问，所以没有专门的`dbsu_password`选项。
如果有此类需求，可在[`pg_default_roles`](v-pgsql.md#pg_default_roles)中为超级用户设置密码。

!> **在生产环境使用时，请务必修改所有默认用户的密码**

此外，用户可以在 [`pg_users`](p-pgsql.md#pg_users) 定义集群特定的[业务用户](c-pgdbuser.md#用户)，定义方式与 [`pg_default_roles`](v-pgsql.md#pg_default_roles) 一致。


!> 如果有较高数据安全需求，建议移除 `dbuser_monitor` 的 `dborle_readony` 角色，部分监控系统功能会不可用。








---------------------

## 认证

认证是数据库验证来访连接身份的过程。Pigsty默认使用`md5`密码认证，并基于PostgreSQL HBA机制提供访问控制。

> HBA是Host Based Authentication的缩写，可以将其视作IP黑白名单。

### HBA配置方式

在Pigsty中，所有实例的HBA都由配置文件生成而来，最终生成的HBA规则因实例的角色（`pg_role`）而不同。
Pigsty的HBA由下列变量控制：

* [`pg_hba_rules`](v-pgsql.md#pg_hba_rules): 环境统一的HBA规则
* [`pg_hba_rules_extra`](v-pgsql.md#pg_hba_rules_extra): 特定于实例或集群的HBA规则
* [`pgbouncer_hba_rules`](v-pgsql.md#pgbouncer_hba_rules): 链接池使用的HBA规则
* [`pgbouncer_hba_rules_extra`](v-pgsql.md#pgbouncer_hba_rules_extra): 特定于实例或集群的链接池HBA规则

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

作为**特例**，`role: offline` 的HBA规则，除了会安装至`pg_role == 'offline'`的实例，也会安装至`pg_offline_query == true`的实例上。

HBA的渲染优先级规则为：

* `hard_coded_rules`           全局硬编码规则
* `pg_hba_rules_extra.common`  集群通用规则
* `pg_hba_rules_extra.pg_role` 集群角色规则
* `pg_hba_rules.pg_role`       全局角色规则
* `pg_hba_rules.offline`       集群离线规则
* `pg_hba_rules_extra.offline` 全局离线规则
* `pg_hba_rules.common`        全局通用规则


### 默认HBA规则

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


<details><summary>默认HBA规则详情</summary>

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



### 修改HBA规则

HBA规则会在集群/实例初始化时自动生成。

用户可以在数据库集群/实例创建并运行后通过剧本修改并应用新的HBA规则：

```bash
./pgsql.yml -t pg_hba    # 通过-l指定目标集群
bin/reloadhba <cluster>  # 重载目标集群的HBA规则
```
当数据库集簇目录被销毁重建后，新副本会拥有和集群主库相同的HBA规则（因为从库的数据集簇目录是主库的二进制副本，而HBA规则也在数据集簇目录中）。
这通常不是用户期待的行为。您可以使用上面的命令针对特定实例进行HBA修复。




### Pgbouncer的HBA

在Pigsty中，Pgbouncer亦使用HBA进行访问控制，用法与Postgres HBA基本一致

* [`pgbouncer_hba_rules`](v-pgsql.md#pgbouncer_hba_rules): 链接池使用的HBA规则
* [`pgbouncer_hba_rules_extra`](v-pgsql.md#pgbouncer_hba_rules_extra): 特定于实例或集群的链接池HBA规则

默认的Pgbouncer HBA规则允许从本地和内网通过密码访问

```bash
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


```






---------------------

## 权限

Pigsty的默认权限模型与[默认角色](#默认角色)紧密关联。使用Pigsty访问控制模型时，新创建的业务用户都应当属于四种默认角色之一，默认角色拥有的权限如下所示：


* 所有用户都可以访问所有模式
* 只读用户可以读取所有表
* 读写用户可以对所有表进行DML操作（INSERT, UPDATE, DELETE）
* 管理员可以执行DDL变更操作（CREATE, USAGE, TRUNCATE, REFERENCES, TRIGGER）
* 离线用户与只读用户类似，但只允许访问`pg_role == 'offline'` 或 `pg_offline_query = true` 的实例

```sql
GRANT USAGE                         ON SCHEMAS   TO dbrole_readonly;
GRANT SELECT                        ON TABLES    TO dbrole_readonly;
GRANT SELECT                        ON SEQUENCES TO dbrole_readonly;
GRANT EXECUTE                       ON FUNCTIONS TO dbrole_readonly;
GRANT USAGE                         ON SCHEMAS   TO dbrole_offline;
GRANT SELECT                        ON TABLES    TO dbrole_offline;
GRANT SELECT                        ON SEQUENCES TO dbrole_offline;
GRANT EXECUTE                       ON FUNCTIONS TO dbrole_readonly;
GRANT INSERT, UPDATE, DELETE        ON TABLES    TO dbrole_readwrite;
GRANT USAGE,  UPDATE                ON SEQUENCES TO dbrole_readwrite;
GRANT TRUNCATE, REFERENCES, TRIGGER ON TABLES    TO dbrole_admin;
GRANT CREATE                        ON SCHEMAS   TO dbrole_admin;
GRANT USAGE                         ON TYPES     TO dbrole_admin;
```

| Owner    | Schema | Type     | Access privileges             |
| -------- | ------ | -------- | ----------------------------- |
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
| username |        | function | =X/postgres                   |
|          |        |          | postgres=X/postgres           |
|          |        |          | dbrole_readonly=X/postgres    |
|          |        |          | dbrole_offline=X/postgres     |


### 对象权限的维护

数据库对象的默认访问权限通过PostgreSQL的`ALTER DEFAULT PRIVILEGES`确保。

所有由 `{{ dbsu }}`, `{{ pg_admin_username }}`, `{{ dbrole_admin }}` 创建的对象，都会拥有以上默认权限。
反过来说，如果是由其他角色创建的对象，则并不会配置有正确的默认访问权限。

Pigsty非常不建议使用**业务用户**执行DDL变更，因为PostgreSQL的`ALTER DEFAULT PRIVILEGE`仅针对“由特定用户创建的对象”生效，默认情况下超级用户`postgres`和`dbuser_dba`创建的对象拥有默认的权限配置，如果希望授予业务用户执行DDL的权限，那么除了为业务用户赋予 `dbrole_admin` 角色外，使用者还需牢记在执行DDL变更时首先要执行：

```sql
SET ROLE dbrole_admin; -- dbrole_admin 创建的对象具有正确的默认权限
```

这样创建的对象才会具有默认的访问权限。


### 数据库的权限

数据库有三种权限：`CONNECT`, `CREATE`, `TEMP`，以及特殊的属主`OWNERSHIP`。数据库的定义由参数`pg_database`控制。一个完整的数据库定义如下所示：

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

默认情况下，如果数据库没有配置属主，那么数据库超级用户`dbsu`将会作为数据库的默认`OWNER`，否则将为指定用户。

默认情况下，所有用户都具有对新创建数据库的`CONNECT` 权限，如果希望回收该权限，设置 `revokeconn == true`，则该权限会被回收。只有默认用户（dbsu|admin|monitor|replicator）与数据库的属主才会被显式赋予`CONNECT`权限。同时，`admin|owner`将会具有`CONNECT`权限的`GRANT OPTION`，可以将`CONNECT`权限转授他人。

如果希望实现不同数据库之间的**访问隔离**，可以为每一个数据库创建一个相应的业务用户作为`owner`，并全部设置`revokeconn`选项，这种配置对于多租户实例尤为实用。

<details>
<summary>一个进行权限隔离的数据库样例</summary>

```yaml
#--------------------------------------------------------------#
# pg-infra (example database for cluster loading)
#--------------------------------------------------------------#
pg-infra:
  hosts:
    10.10.10.40: { pg_seq: 1, pg_role: primary }
    10.10.10.41: { pg_seq: 2, pg_role: replica , pg_offline_query: true }
  vars:
    pg_cluster: pg-infrastructure
    pg_version: 14
    vip_address: 10.10.10.4
    pgbouncer_poolmode: session
    pg_hba_rules_extra:
      - title: allow confluence jira gitlab eazybi direct access
        role: common
        rules:
          - host    confluence dbuser_confluence   10.0.0.0/8        md5
          - host    jira       dbuser_jira         10.0.0.0/8        md5
          - host    gitlab     dbuser_gitlab       10.0.0.0/8        md5

    pg_users:
      # infra prod user
      - { name: dbuser_hybridcloud, password: ssag-2xd, pgbouncer: true, roles: [ dbrole_readwrite ] }
      - { name: dbuser_confluence, password: mc2iohos , pgbouncer: true, roles: [ dbrole_admin ] }
      - { name: dbuser_gitlab, password: sdf23g22sfdd , pgbouncer: true, roles: [ dbrole_readwrite ] }
      - { name: dbuser_jira, password: sdpijfsfdsfdfs , pgbouncer: true, roles: [ dbrole_admin ] }
    pg_databases:
      # infra database
      - { name: hybridcloud , revokeconn: true, owner: dbuser_hybridcloud , parameters: { search_path: yay,public } , connlimit: 100 }
      - { name: confluence , revokeconn: true, owner: dbuser_confluence , connlimit: 100 }
      - { name: gitlab , revokeconn: true, owner: dbuser_gitlab, connlimit: 100 }
      - { name: jira , revokeconn: true, owner: dbuser_jira , connlimit: 100 }

```

</details>



### 创建对象的权限

默认情况下，出于安全考虑，Pigsty会撤销`PUBLIC`用户在数据库下`CREATE`新模式的权限，
同时也会撤销`PUBLIC`用户在`public`模式下创建新关系的权限。
数据库超级用户与管理员不受此限制，他们总是可以在任何地方执行DDL变更。

**在数据库中创建对象的权限与用户是否为数据库属主无关，这只取决于创建该用户时是否为该用户赋予管理员权限**。

```yaml
pg_users:
  - {name: test1, password: xxx , groups: [dbrole_readwrite]}  # 不能创建Schema与对象
  - {name: test2, password: xxx , groups: [dbrole_admin]}      # 可以创建Schema与对象
```
