# PostgreSQL 数据库

> 在这里的上下文中，数据库指的是使用 SQL 命令 `CREATE DATABASE` 创建的，数据库集簇内的逻辑对象。

一组 PostgreSQL 服务器可以同时服务于多个 **数据库** （Database）。在 Pigsty 中，你可以在集群配置中[定义](#定义数据库)好所需的数据库。

Pigsty会对默认模板数据库`template1`进行修改与定制，创建默认模式，安装默认扩展，配置默认权限，新创建的数据库默认会从`template1`继承这些设置。

默认情况下，所有业务数据库都会被1:1添加到 Pgbouncer 连接池中；`pg_exporter` 默认会通过 **自动发现** 机制查找所有业务数据库并进行库内对象监控。


----------------

## 定义数据库

业务数据库定义在数据库集群参数  [`pg_databases`](PARAM#pg_databases) 中，这是一个数据库定义构成的对象数组。
数组内的数据库按照**定义顺序**依次创建，因此后面定义的数据库可以使用先前定义的数据库作为**模板**。

下面是 Pigsty 演示环境中默认集群 `pg-meta` 中的数据库定义：

```yaml
pg-meta:
  hosts: { 10.10.10.10: { pg_seq: 1, pg_role: primary } }
  vars:
    pg_cluster: pg-meta
    pg_databases:
      - { name: meta ,baseline: cmdb.sql ,comment: pigsty meta database ,schemas: [pigsty] ,extensions: [{name: postgis, schema: public}, {name: timescaledb}]}
      - { name: grafana  ,owner: dbuser_grafana  ,revokeconn: true ,comment: grafana primary database }
      - { name: bytebase ,owner: dbuser_bytebase ,revokeconn: true ,comment: bytebase primary database }
      - { name: kong     ,owner: dbuser_kong     ,revokeconn: true ,comment: kong the api gateway database }
      - { name: gitea    ,owner: dbuser_gitea    ,revokeconn: true ,comment: gitea meta database }
      - { name: wiki     ,owner: dbuser_wiki     ,revokeconn: true ,comment: wiki meta database }
      - { name: noco     ,owner: dbuser_noco     ,revokeconn: true ,comment: nocodb database }
```

每个数据库定义都是一个 object，可能包括以下字段，以 `meta` 数据库为例：

```yaml
- name: meta                      # 必选，`name` 是数据库定义的唯一必选字段
  baseline: cmdb.sql              # 可选，数据库 sql 的基线定义文件路径（ansible 搜索路径中的相对路径，如 files/）
  pgbouncer: true                 # 可选，是否将此数据库添加到 pgbouncer 数据库列表？默认为 true
  schemas: [pigsty]               # 可选，要创建的附加模式，由模式名称字符串组成的数组
  extensions:                     # 可选，要安装的附加扩展： 扩展对象的数组
    - { name: postgis , schema: public }  # 可以指定将扩展安装到某个模式中，也可以不指定（不指定则安装到 search_path 首位模式中）
    - { name: timescaledb }               # 例如有的扩展会创建并使用固定的模式，就不需要指定模式。
  comment: pigsty meta database   # 可选，数据库的说明与备注信息
  owner: postgres                 # 可选，数据库所有者，默认为 postgres
  template: template1             # 可选，要使用的模板，默认为 template1，目标必须是一个模板数据库
  encoding: UTF8                  # 可选，数据库编码，默认为 UTF8（必须与模板数据库相同）
  locale: C                       # 可选，数据库地区设置，默认为 C（必须与模板数据库相同）
  lc_collate: C                   # 可选，数据库 collate 排序规则，默认为 C（必须与模板数据库相同），没有理由不建议更改。
  lc_ctype: C                     # 可选，数据库 ctype 字符集，默认为 C（必须与模板数据库相同）
  tablespace: pg_default          # 可选，默认表空间，默认为 'pg_default'
  allowconn: true                 # 可选，是否允许连接，默认为 true。显式设置 false 将完全禁止连接到此数据库
  revokeconn: false               # 可选，撤销公共连接权限。默认为 false，设置为 true 时，属主和管理员之外用户的 CONNECT 权限会被回收
  register_datasource: true       # 可选，是否将此数据库注册到 grafana 数据源？默认为 true，显式设置为 false 会跳过注册
  connlimit: -1                   # 可选，数据库连接限制，默认为 -1 ，不限制，设置为正整数则会限制连接数。
  pool_auth_user: dbuser_meta     # 可选，连接到此 pgbouncer 数据库的所有连接都将使用此用户进行验证（启用 pgbouncer_auth_query 才有用）
  pool_mode: transaction          # 可选，数据库级别的 pgbouncer 池化模式，默认为 transaction
  pool_size: 64                   # 可选，数据库级别的 pgbouncer 默认池子大小，默认为 64
  pool_size_reserve: 32           # 可选，数据库级别的 pgbouncer 池子保留空间，默认为 32，当默认池子不够用时，最多再申请这么多条突发连接。
  pool_size_min: 0                # 可选，数据库级别的 pgbouncer 池的最小大小，默认为 0
  pool_max_db_conn: 100           # 可选，数据库级别的最大数据库连接数，默认为 100
```

唯一必选的字段是 `name`，它应该是当前 PostgreSQL 集群中有效且唯一的数据库名称，其他参数都有合理的默认值。

- `name`：数据库名称，**必选项**。
- `baseline`：SQL文件路径（Ansible搜索路径，通常位于`files`），用于初始化数据库内容。
- `owner`：数据库属主，默认为`postgres`
- `template`：数据库创建时使用的模板，默认为`template1`
- `encoding`：数据库默认字符编码，默认为`UTF8`，默认与实例保持一致。建议不要配置与修改。
- `locale`：数据库默认的本地化规则，默认为`C`，建议不要配置，与实例保持一致。
- `lc_collate`：数据库默认的本地化字符串排序规则，默认与实例设置相同，建议不要修改，必须与模板数据库一致。强烈建议不要配置，或配置为`C`。
- `lc_ctype`：数据库默认的LOCALE，默认与实例设置相同，建议不要修改或设置，必须与模板数据库一致。建议配置为C或`en_US.UTF8`。
- `allowconn`：是否允许连接至数据库，默认为`true`，不建议修改。
- `revokeconn`：是否回收连接至数据库的权限？默认为`false`。如果为`true`，则数据库上的`PUBLIC CONNECT`权限会被回收。只有默认用户（`dbsu|monitor|admin|replicator|owner`）可以连接。此外，`admin|owner` 会拥有GRANT OPTION，可以赋予其他用户连接权限。
- `tablespace`：数据库关联的表空间，默认为`pg_default`。
- `connlimit`：数据库连接数限制，默认为`-1`，即没有限制。
- `extensions`：对象数组 ，每一个对象定义了一个数据库中的**扩展**，以及其安装的**模式**。
- `parameters`：KV对象，每一个KV定义了一个需要针对数据库通过`ALTER DATABASE`修改的参数。
- `pgbouncer`：布尔选项，是否将该数据库加入到Pgbouncer中。所有数据库都会加入至Pgbouncer列表，除非显式指定`pgbouncer: false`。
- `comment`：数据库备注信息。
- `pool_auth_user`：启用 [`pgbouncer_auth_query`](PARAM#pgbouncer_auth_query) 时，连接到此 pgbouncer 数据库的所有连接都将使用这里指定的用户执行认证查询。你需要使用一个具有访问 `pg_shadow` 表权限的用户。
- `pool_mode`：数据库级别的 pgbouncer 池化模式，默认为 transaction，即事物池化。如果留空，会使用 [`pgbouncer_pool_mode`](PARAM#pgbouncer_pool_mode) 参数作为默认值。
- `pool_size`：数据库级别的 pgbouncer 默认池子大小，默认为 64
- `pool_size_reserve`：数据库级别的 pgbouncer 池子保留空间，默认为 32，当默认池子不够用时，最多再申请这么多条突发连接。
- `pool_size_min`： 数据库级别的 pgbouncer 池的最小大小，默认为 0
- `pool_max_db_conn`： 数据库级别的 pgbouncer 连接池最大数据库连接数，默认为 100

新创建的数据库默认会从 `template1` 数据库 Fork 出来，这个模版数据库会在 [`PG_PROVISION`](PARAM#pg_provision) 阶段进行定制修改：
配置好扩展，模式以及默认权限，因此新创建的数据库也会继承这些配置，除非您显式使用一个其他的数据库作为模板。

关于数据库的访问权限，请参考 [ACL：数据库权限](PGSQL-ACL#数据库权限) 一节。


----------------

## 创建数据库

在 [`pg_databases`](PARAM#pg_databases) 中[定义](#定义数据库)的数据库将在集群初始化时自动创建。
如果您希望在现有集群上[创建数据库](PGSQL-ADMIN#创建数据库)，可以使用 `bin/pgsql-db` 包装脚本。
将新的数据库定义添加到 `all.children.<cls>.pg_databases` 中，并使用以下命令创建该数据库：

```bash
bin/pgsql-db <cls> <dbname>    # pgsql-db.yml -l <cls> -e dbname=<dbname>
```

下面是新建数据库时的一些注意事项：

创建数据库的剧本默认为幂等剧本，不过当您当使用 `baseline` 脚本时就不一定了：这种情况下，通常不建议在现有数据库上重复执行此操作，除非您确定所提供的 baseline SQL也是幂等的。

我们不建议您手工创建新的数据库，特别当您使用默认的 pgbouncer 连接池时：除非您愿意手工负责维护 Pgbouncer 中的数据库列表并与 PostgreSQL 保持一致。
使用 `pgsql-db` 工具或 `pgsql-db.yml` 剧本创建新数据库时，会将此数据库一并添加到 [Pgbouncer 数据库](#pgbouncer数据库) 列表中。

如果您的数据库定义有一个非常规 `owner`（默认为 dbsu `postgres`），那么请确保在创建该数据库前，属主用户已经存在。
最佳实践永远是在创建数据库之前[创建](PGSQL-ADMIN#创建用户) [用户](PGSQL-USER)。



----------------

## Pgbouncer数据库

Pigsty 会默认为 PostgreSQL 实例 1:1 配置启用一个 Pgbouncer 连接池，使用 `/var/run/postgresql` Unix Socket 通信。

连接池可以优化短连接性能，降低并发征用，以避免过高的连接数冲垮数据库，并在数据库迁移时提供额外的灵活处理空间。

Pigsty 默认将 [`pg_databases`](PARAM#pg_databases) 中的所有数据库都添加到 pgbouncer 的数据库列表中。
您可以通过在数据库[定义](#定义数据库)中显式设置 `pgbouncer: false` 来禁用特定数据库的 pgbouncer 连接池支持。

Pgbouncer数据库列表在 `/etc/pgbouncer/database.txt` 中定义，数据库定义中关于连接池的参数会体现在这里：

```yaml
meta                        = host=/var/run/postgresql mode=session
grafana                     = host=/var/run/postgresql mode=transaction
bytebase                    = host=/var/run/postgresql auth_user=dbuser_meta
kong                        = host=/var/run/postgresql pool_size=32 reserve_pool=64
gitea                       = host=/var/run/postgresql min_pool_size=10
wiki                        = host=/var/run/postgresql
noco                        = host=/var/run/postgresql
mongo                       = host=/var/run/postgresql
```

当您[创建数据库](#创建数据库)时，Pgbouncer 的数据库列表定义文件将会被刷新，并通过在线重载配置的方式生效，正常不会影响现有的连接。

Pgbouncer 使用和 PostgreSQL 同样的 `dbsu` 运行，默认为 `postgres` 操作系统用户，您可以使用 `pgb` 别名，使用 dbsu 访问 pgbouncer 管理功能。

Pigsty 还提供了一个实用函数 `pgb-route` ，可以将 pgbouncer 数据库流量快速切换至集群中的其他节点，用于零停机迁移：

```bash
# route pgbouncer traffic to another cluster member
function pgb-route(){
  local ip=${1-'\/var\/run\/postgresql'}
  sed -ie "s/host=[^[:space:]]\+/host=${ip}/g" /etc/pgbouncer/pgbouncer.ini
  cat /etc/pgbouncer/pgbouncer.ini
}
```
