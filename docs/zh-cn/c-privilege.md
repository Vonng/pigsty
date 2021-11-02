# 权限

PostgreSQL提供了标准的访问控制机制：[认证](c-auth.md)（Authentication）与[权限](c-privilege.md)（Privileges），认证与权限都基于[角色](c-user.md)（Role）与[用户](c-user.md)（User）系统。Pigsty提供了开箱即用的访问控制模型，可覆盖绝大多数场景下的安全需求。

本文介绍Pigsty使用的默认权限系统。

Pigsty的默认用户体系包含**四个默认用户**与**四类默认角色**。

## 对象的权限

权限模型与[默认角色](c-user.md)紧密关联。

使用Pigsty访问控制模型时，新创建的业务用户都应当属于四种默认角色之一，默认角色拥有的权限如下所示：

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


* 所有用户都可以访问所有模式
* 只读用户可以读取所有表
* 读写用户可以对所有表进行DML操作（INSERT, UPDATE, DELETE）
* 管理员可以执行DDL变更操作（CREATE, USAGE, TRUNCATE, REFERENCES, TRIGGER）
* 离线用户与只读用户类似，但只允许访问`pg_role == 'offline'` 或 `pg_offline_query = true` 的实例


## 对象权限的维护

数据库对象的默认访问权限通过PostgreSQL的`ALTER DEFAULT PRIVILEGES`确保。

所有由 `{{ dbsu }}`, `{{ pg_admin_username }}`, `{{ dbrole_admin }}` 创建的对象，都会拥有以上默认权限。
反过来说，如果是由其他角色创建的对象，则并不会配置有正确的默认访问权限。

Pigsty非常不建议使用**业务用户**执行DDL变更，因为PostgreSQL的`ALTER DEFAULT PRIVILEGE`仅针对“由特定用户创建的对象”生效，默认情况下超级用户`postgres`和`dbuser_dba`创建的对象拥有默认的权限配置，如果希望授予业务用户执行DDL的权限，那么除了为业务用户赋予 `dbrole_admin` 角色外，使用者还需牢记在执行DDL变更时首先要执行：

```sql
SET ROLE dbrole_admin; -- dbrole_admin 创建的对象具有正确的默认权限
```

这样创建的对象才会具有默认的访问权限


## 数据库的权限

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



## 创建对象的权限

默认情况下，出于安全考虑，Pigsty会撤销`PUBLIC`用户在数据库下`CREATE`新模式的权限，
同时也会撤销`PUBLIC`用户在`public`模式下创建新关系的权限。
数据库超级用户与管理员不受此限制，他们总是可以在任何地方执行DDL变更。

**在数据库中创建对象的权限与用户是否为数据库属主无关，这只取决于创建该用户时是否为该用户赋予管理员权限**。

```yaml
pg_users:
  - {name: test1, password: xxx , groups: [dbrole_readwrite]}  # 不能创建Schema与对象
  - {name: test2, password: xxx , groups: [dbrole_admin]}      # 可以创建Schema与对象
```
