# PostgreSQL 用户与角色

> 在这里的上下文中，用户指的是使用 SQL 命令 `CREATE USER/ROLE` 创建的，数据库集簇内的逻辑对象。

在PostgreSQL中，用户直接隶属于数据库集簇而非某个具体的数据库。因此在创建业务数据库和业务用户时，应当遵循"先用户，后数据库"的原则。


----------------

## 定义用户

Pigsty通过两个配置参数定义数据库集群中的角色与用户：

- [`pg_default_roles`](PARAM#pg_default_roles)：定义全局统一使用的角色和用户
- [`pg_users`](PARAM#pg_users)：在数据库集群层面定义业务用户和角色

前者用于定义了整套环境中共用的角色与用户，后者定义单个集群中特有的业务角色与用户。二者形式相同，均为用户定义对象的数组。

你可以定义多个用户/角色，它们会按照先全局，后集群，最后按数组内排序的顺序依次创建，所以后面的用户可以属于前面定义的角色。

下面是 Pigsty 演示环境中默认集群 `pg-meta` 中的业务用户定义：

```yaml
pg-meta:
  hosts: { 10.10.10.10: { pg_seq: 1, pg_role: primary } }
  vars:
    pg_cluster: pg-meta
    pg_users:
      - {name: dbuser_meta     ,password: DBUser.Meta     ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: pigsty admin user }
      - {name: dbuser_view     ,password: DBUser.Viewer   ,pgbouncer: true ,roles: [dbrole_readonly] ,comment: read-only viewer for meta database }
      - {name: dbuser_grafana  ,password: DBUser.Grafana  ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for grafana database    }
      - {name: dbuser_bytebase ,password: DBUser.Bytebase ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for bytebase database   }
      - {name: dbuser_kong     ,password: DBUser.Kong     ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for kong api gateway    }
      - {name: dbuser_gitea    ,password: DBUser.Gitea    ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for gitea service       }
      - {name: dbuser_wiki     ,password: DBUser.Wiki     ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for wiki.js service     }
      - {name: dbuser_noco     ,password: DBUser.Noco     ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for nocodb service      }
```

每个用户/角色定义都是一个 object，可能包括以下字段，以 `dbuser_meta` 用户为例：

```yaml
- name: dbuser_meta               # 必需，`name` 是用户定义的唯一必选字段
  password: DBUser.Meta           # 可选，密码，可以是 scram-sha-256 哈希字符串或明文
  login: true                     # 可选，默认情况下可以登录
  superuser: false                # 可选，默认为 false，是超级用户吗？
  createdb: false                 # 可选，默认为 false，可以创建数据库吗？
  createrole: false               # 可选，默认为 false，可以创建角色吗？
  inherit: true                   # 可选，默认情况下，此角色可以使用继承的权限吗？
  replication: false              # 可选，默认为 false，此角色可以进行复制吗？
  bypassrls: false                # 可选，默认为 false，此角色可以绕过行级安全吗？
  pgbouncer: true                 # 可选，默认为 false，将此用户添加到 pgbouncer 用户列表吗？（使用连接池的生产用户应该显式定义为 true）
  connlimit: -1                   # 可选，用户连接限制，默认 -1 禁用限制
  expire_in: 3650                 # 可选，此角色过期时间：从创建时 + n天计算（优先级比 expire_at 更高）
  expire_at: '2030-12-31'         # 可选，此角色过期的时间点，使用 YYYY-MM-DD 格式的字符串指定一个特定日期（优先级没 expire_in 高）
  comment: pigsty admin user      # 可选，此用户/角色的说明与备注字符串
  roles: [dbrole_admin]           # 可选，默认角色为：dbrole_{admin,readonly,readwrite,offline}
  parameters: {}                  # 可选，使用 `ALTER ROLE SET` 针对这个角色，配置角色级的数据库参数
  pool_mode: transaction          # 可选，默认为 transaction 的 pgbouncer 池模式，用户级别
  pool_connlimit: -1              # 可选，用户级别的最大数据库连接数，默认 -1 禁用限制
  search_path: public             # 可选，根据 postgresql 文档的键值配置参数（例如：使用 pigsty 作为默认 search_path）
```

- 唯一必需的字段是 `name`，它应该是 PostgreSQL 集群中的一个有效且唯一的用户名。
- 角色不需要 `password`，但对于可登录的业务用户，通常是需要指定一个密码的。
- `password` 可以是明文或 scram-sha-256 / md5 哈希字符串，请最好不要使用明文密码。
- 用户/角色按数组顺序逐一创建，因此，请确保角色/分组的定义在成员之前。
- `login`、`superuser`、`createdb`、`createrole`、`inherit`、`replication`、`bypassrls` 是布尔标志。
- `pgbouncer` 默认是禁用的：要将业务用户添加到 pgbouncer 用户列表，您应当显式将其设置为 `true`。 

**ACL系统**

Pigsty 具有一套内置的，开箱即用的访问控制 / [ACL](PGSQL-ACL#默认角色) 系统，您只需将以下四个默认角色分配给业务用户即可轻松使用：

- `dbrole_readwrite`：全局读写访问的角色（主属业务使用的生产账号应当具有数据库读写权限）
- `dbrole_readonly`：全局只读访问的角色（如果别的业务想要只读访问，可以使用此角色）
- `dbrole_admin`：拥有DDL权限的角色 （业务管理员，需要在应用中建表的场景）
- `dbrole_offline`：受限的只读访问角色（只能访问 [offline](PGSQL-CONF#离线从库) 实例，通常是个人用户）

如果您希望重新设计您自己的 ACL 系统，可以考虑定制以下参数和模板：

- [`pg_default_roles`](PARAM#pg_default_roles)：系统范围的角色和全局用户
- [`pg_default_privileges`](PARAM#pg_default_privileges)：新建对象的默认权限
- [`roles/pgsql/templates/pg-init-role.sql`](https://github.com/Vonng/pigsty/blob/master/roles/pgsql/templates/pg-init-role.sql)：角色创建 SQL 模板
- [`roles/pgsql/templates/pg-init-template.sql`](https://github.com/Vonng/pigsty/blob/master/roles/pgsql/templates/pg-init-template.sql)：权限 SQL 模板



----------------

## 创建用户

在 [`pg_default_roles`](PARAM#pg_default_roles) 和 [`pg_users`](PARAM#pg_users) 中[定义](#定义用户)的用户和角色，将在集群初始化的 PROVISION 阶段中自动逐一创建。
如果您希望在现有的集群上[创建用户](PGSQL-ADMIN#创建用户)，可以使用 `bin/pgsql-user` 工具。
将新用户/角色定义添加到 `all.children.<cls>.pg_users`，并使用以下方法创建该用户：

```bash
bin/pgsql-user <cls> <username>    # pgsql-user.yml -l <cls> -e username=<username>
```

不同于数据库，创建用户的剧本总是幂等的。当目标用户已经存在时，Pigsty会修改目标用户的属性使其符合配置。所以在现有集群上重复运行它通常不会有问题。

我们不建议您手工创建新的业务用户，特别当您想要创建的用户使用默认的 pgbouncer 连接池时：除非您愿意手工负责维护 Pgbouncer 中的用户列表并与 PostgreSQL 保持一致。
使用 `pgsql-db` 工具或 `pgsql-db.yml` 剧本创建新数据库时，会将此数据库一并添加到  [Pgbouncer用户](#pgbouncer用户) 列表中。



----------------

## Pgbouncer用户

默认情况下启用 Pgbouncer，并作为连接池中间件，其用户默认被管理。

Pigsty 默认将 [`pg_users`](PARAM#pg_users) 中显式带有 `pgbouncer: true` 标志的所有用户添加到 pgbouncer 用户列表中。

Pgbouncer 连接池中的用户在 `/etc/pgbouncer/userlist.txt` 中列出：

```ini
"postgres" ""
"dbuser_wiki" "SCRAM-SHA-256$4096:+77dyhrPeFDT/TptHs7/7Q==$KeatuohpKIYzHPCt/tqBu85vI11o9mar/by0hHYM2W8=:X9gig4JtjoS8Y/o1vQsIX/gY1Fns8ynTXkbWOjUfbRQ="
"dbuser_view" "SCRAM-SHA-256$4096:DFoZHU/DXsHL8MJ8regdEw==$gx9sUGgpVpdSM4o6A2R9PKAUkAsRPLhLoBDLBUYtKS0=:MujSgKe6rxcIUMv4GnyXJmV0YNbf39uFRZv724+X1FE="
"dbuser_monitor" "SCRAM-SHA-256$4096:fwU97ZMO/KR0ScHO5+UuBg==$CrNsmGrx1DkIGrtrD1Wjexb/aygzqQdirTO1oBZROPY=:L8+dJ+fqlMQh7y4PmVR/gbAOvYWOr+KINjeMZ8LlFww="
"dbuser_meta" "SCRAM-SHA-256$4096:leB2RQPcw1OIiRnPnOMUEg==$eyC+NIMKeoTxshJu314+BmbMFpCcspzI3UFZ1RYfNyU=:fJgXcykVPvOfro2MWNkl5q38oz21nSl1dTtM65uYR1Q="
"dbuser_kong" "SCRAM-SHA-256$4096:bK8sLXIieMwFDz67/0dqXQ==$P/tCRgyKx9MC9LH3ErnKsnlOqgNd/nn2RyvThyiK6e4=:CDM8QZNHBdPf97ztusgnE7olaKDNHBN0WeAbP/nzu5A="
"dbuser_grafana" "SCRAM-SHA-256$4096:HjLdGaGmeIAGdWyn2gDt/Q==$jgoyOB8ugoce+Wqjr0EwFf8NaIEMtiTuQTg1iEJs9BM=:ed4HUFqLyB4YpRr+y25FBT7KnlFDnan6JPVT9imxzA4="
"dbuser_gitea" "SCRAM-SHA-256$4096:l1DBGCc4dtircZ8O8Fbzkw==$tpmGwgLuWPDog8IEKdsaDGtiPAxD16z09slvu+rHE74=:pYuFOSDuWSofpD9OZhG7oWvyAR0PQjJBffgHZLpLHds="
"dbuser_dba" "SCRAM-SHA-256$4096:zH8niABU7xmtblVUo2QFew==$Zj7/pq+ICZx7fDcXikiN7GLqkKFA+X5NsvAX6CMshF0=:pqevR2WpizjRecPIQjMZOm+Ap+x0kgPL2Iv5zHZs0+g="
"dbuser_bytebase" "SCRAM-SHA-256$4096:OMoTM9Zf8QcCCMD0svK5gg==$kMchqbf4iLK1U67pVOfGrERa/fY818AwqfBPhsTShNQ=:6HqWteN+AadrUnrgC0byr5A72noqnPugItQjOLFw0Wk="
```

而用户级别的连接池参数则是使用另一个单独的文件： `/etc/pgbouncer/useropts.txt` 进行维护，比如：

```ini
dbuser_dba                  = pool_mode=session max_user_connections=16
dbuser_monitor              = pool_mode=session max_user_connections=8
```

当您[创建数据库](#创建数据库)时，Pgbouncer 的数据库列表定义文件将会被刷新，并通过在线重载配置的方式生效，不会影响现有的连接。

Pgbouncer 使用和 PostgreSQL 同样的 `dbsu` 运行，默认为 `postgres` 操作系统用户，您可以使用 `pgb` 别名，使用 dbsu 访问 pgbouncer 管理功能。

Pigsty 还提供了一个实用函数 `pgb-route` ，可以将 pgbouncer 数据库流量快速切换至集群中的其他节点，用于零停机迁移：

连接池用户配置文件 `userlist.txt` 与 `useropts.txt` 会在您[创建用户](#创建用户)时自动刷新，并通过在线重载配置的方式生效，正常不会影响现有的连接。

请注意，[`pgbouncer_auth_query`](PARAM#pgbouncer_auth_query) 参数允许你使用动态查询来完成连接池用户认证，当您懒得管理连接池中的用户时，这是一种折中的方案。

