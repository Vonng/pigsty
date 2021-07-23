

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



