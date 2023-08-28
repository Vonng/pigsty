# PostgreSQL 认证与HBA

> Pigsty 中基于主机的身份认证 HBA（Host-Based Authentication）详解。

认证是 [访问控制](PGSQL-ACL) 与 [权限系统](PGSQL-ACL#权限系统) 的基石，PostgreSQL拥有多种[认证](https://www.postgresql.org/docs/current/client-authentication.html)方法。

这里主要介绍 HBA：Host Based Authentication，HBA规则定义了哪些用户能够通过哪些方式从哪些地方访问哪些数据库。


----------------

## 客户端认证

要连接到PostgreSQL数据库，用户必须先经过认证（默认使用密码）。

您可以在连接字符串中提供密码（不安全）或使用`PGPASSWORD`环境变量或`.pgpass`文件传递密码。参考[`psql`](https://www.postgresql.org/docs/current/app-psql.html#usage)文档和[PostgreSQL连接字符串](https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING)以获取更多详细信息。

```bash
psql 'host=<host> port=<port> dbname=<dbname> user=<username> password=<password>'
psql postgres://<username>:<password>@<host>:<port>/<dbname>
PGPASSWORD=<password>; psql -U <username> -h <host> -p <port> -d <dbname>
```

例如，连接 Pigsty 默认的 `meta` 数据库，可以使用以下连接串：

```bash
psql 'host=10.10.10.10 port=5432 dbname=meta user=dbuser_dba password=DBUser.DBA'
psql postgres://dbuser_dba:DBUser.DBA@10.10.10.10:5432/meta
PGPASSWORD=DBUser.DBA; psql -U dbuser_dba -h 10.10.10.10 -p 5432 -d meta
```

默认配置下，Pigsty会启用服务端 SSL 加密，但不验证客户端 SSL 证书。要使用客户端SSL证书连接，你可以使用`PGSSLCERT`和`PGSSLKEY`环境变量或`sslkey`和`sslcert`参数提供客户端参数。

```bash
psql 'postgres://dbuser_dba:DBUser.DBA@10.10.10.10:5432/meta?sslkey=/path/to/dbuser_dba.key&sslcert=/path/to/dbuser_dba.crt'
```

客户端证书（`CN` = 用户名）可以使用本地CA与[cert.yml](https://github.com/Vonng/pigsty/blob/master/cert.yml)剧本签发。




----------------

## 定义HBA

在Pigsty中，有四个与HBA规则有关的参数：

- [`pg_hba_rules`](PARAM#pg_hba_rules)：postgres HBA规则
- [`pg_default_hba_rules`](PARAM#pg_default_hba_rules)：postgres 全局默认HBA规则
- [`pgb_hba_rules`](PARAM#pgb_hba_rules)：pgbouncer HBA规则
- [`pgb_default_hba_rules`](PARAM#pgb_default_hba_rules)：pgbouncer 全局默认HBA规则

这些都是 HBA 规则对象的数组，每个HBA规则都是以下两种形式之一的对象：


### 1. 原始形式

原始形式的 HBA 与 PostgreSQL `pg_hba.conf` 的格式几乎完全相同： 

```yaml
- title: allow intranet password access
  role: common
  rules:
    - host   all  all  10.0.0.0/8      md5
    - host   all  all  172.16.0.0/12   md5
    - host   all  all  192.168.0.0/16  md5
```

在这种形式中，`rules` 字段是字符串数组，每一行都是条原始形式的 [HBA规则](https://www.postgresql.org/docs/current/auth-pg-hba-conf.html)。`title` 字段会被渲染为一条注释，解释下面规则的作用。

`role` 字段用于说明该规则适用于哪些实例角色，当实例的[`pg_role`](PARAM#pg_role)与`role`相同时，HBA规则将被添加到这台实例的 HBA 中。
- `role: common`的HBA规则将被添加到所有实例上。
- `role: primary` 的 HBA 规则只会添加到主库实例上。
- `role: replica` 的 HBA 规则只会添加到从库实例上。
- `role: offline`的HBA规则将被添加到离线实例上（ [`pg_role`](PARAM#pg_role) = `offline`或[`pg_offline_query`](PARAM#pg_offline_query) = `true`）




### 2. 别名形式

别名形式允许您用更简单清晰便捷的方式维护 HBA 规则：它用`addr`、`auth`、`user`和`db` 字段替换了 `rules`。 `title` 和 `role` 字段则仍然生效。

```yaml
- addr: 'intra'    # world|intra|infra|admin|local|localhost|cluster|<cidr>
  auth: 'pwd'      # trust|pwd|ssl|cert|deny|<official auth method>
  user: 'all'      # all|${dbsu}|${repl}|${admin}|${monitor}|<user>|<group>
  db: 'all'        # all|replication|....
  rules: []        # raw hba string precedence over above all
  title: allow intranet password access
```

- `addr`: **where** 哪些IP地址段受本条规则影响？
  - `world`: 所有的IP地址
  - `intra`: 所有的内网IP地址段： `'10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16'`
  - `infra`: Infra节点的IP地址
  - `admin`: `admin_ip` 管理节点的IP地址
  - `local`: 本地 Unix Socket
  - `localhost`: 本地 Unix Socket 以及TCP 127.0.0.1/32 环回地址
  - `cluster`: 同一个 PostgresQL 集群所有成员的IP地址  
  - `<cidr>`: 一个特定的 CIDR 地址块或IP地址
- `auth`: **how** 本条规则指定的认证方式？
  - `deny`: 拒绝访问
  - `trust`: 直接信任，不需要认证
  - `pwd`: 密码认证，根据 [`pg_pwd_enc`](PARAM#pg_pwd_enc) 参数选用 `md5` 或 `scram-sha-256` 认证
  - `sha`/`scram-sha-256`：强制使用 `scram-sha-256` 密码认证方式。
  - `md5`: `md5` 密码认证方式，但也可以兼容  `scram-sha-256` 认证，不建议使用。
  - `ssl`: 在密码认证 `pwd` 的基础上，强制要求启用SSL
  - `ssl-md5`: 在密码认证 `md5` 的基础上，强制要求启用SSL
  - `ssl-sha`: 在密码认证 `sha` 的基础上，强制要求启用SSL
  - `os`/`ident`: 使用操作系统用户的身份进行 `ident` 认证 
  - `peer`: 使用 `peer` 认证方式，类似于 `os ident`
  - `cert`: 使用基于客户端SSL证书的认证方式，证书CN为用户名
- `user`: **who**：哪些用户受本条规则影响？
  - `all`: 所有用户
  - `${dbsu}`: 默认数据库超级用户 [`pg_dbsu`](PARAM#pg_dbsu)
  - `${repl}`: 默认数据库复制用户 [`pg_replication_username`](PARAM#pg_replication_username)
  - `${admin}`: 默认数据库管理用户 [`pg_admin_username`](PARAM#pg_admin_username)
  - `${monitor}`: 默认数据库监控用户 [`pg_monitor_username`](PARAM#pg_monitor_username)
  - 其他特定的用户或者角色 
- `db`: **which**：哪些数据库受本条规则影响？
  - `all`: 所有数据库
  - `replication`: 允许建立复制连接（不指定特定数据库）
  - 某个特定的数据库




----------------

## 重载HBA

HBA 是一个静态的规则配置文件，修改后需要重载才能生效。默认的 HBA 规则集合因为不涉及 Role 与集群成员，所以通常不需要重载。

如果您设计的 HBA 使用了特定的实例角色限制，或者集群成员限制，那么当集群实例成员发生变化（新增/下线/主从切换），一部分HBA规则的生效条件/涉及范围发生变化，通常也需要[重载HBA](PGSQL-ADMIN#重载hba)以反映最新变化。

要重新加载 postgres/pgbouncer 的 hba 规则：

```bash
bin/pgsql-hba <cls>                 # 重新加载集群 `<cls>` 的 hba 规则
bin/pgsql-hba <cls> ip1 ip2...      # 重新加载特定实例的 hba 规则
```

底层实际执行的 Ansible 剧本命令为：

```bash
./pgsql.yml -l <cls> -e pg_reload=true -t pg_hba
./pgsql.yml -l <cls> -e pg_reload=true -t pgbouncer_hba,pgbouncer_reload
```




----------------

## 默认HBA

Pigsty 有一套默认的 HBA 规则，对于绝大多数场景来说，它已经足够安全了。这些规则使用别名形式，因此基本可以自我解释。

```yaml
pg_default_hba_rules:             # postgres 全局默认的HBA规则 
  - {user: '${dbsu}'    ,db: all         ,addr: local     ,auth: ident ,title: 'dbsu access via local os user ident'  }
  - {user: '${dbsu}'    ,db: replication ,addr: local     ,auth: ident ,title: 'dbsu replication from local os ident' }
  - {user: '${repl}'    ,db: replication ,addr: localhost ,auth: pwd   ,title: 'replicator replication from localhost'}
  - {user: '${repl}'    ,db: replication ,addr: intra     ,auth: pwd   ,title: 'replicator replication from intranet' }
  - {user: '${repl}'    ,db: postgres    ,addr: intra     ,auth: pwd   ,title: 'replicator postgres db from intranet' }
  - {user: '${monitor}' ,db: all         ,addr: localhost ,auth: pwd   ,title: 'monitor from localhost with password' }
  - {user: '${monitor}' ,db: all         ,addr: infra     ,auth: pwd   ,title: 'monitor from infra host with password'}
  - {user: '${admin}'   ,db: all         ,addr: infra     ,auth: ssl   ,title: 'admin @ infra nodes with pwd & ssl'   }
  - {user: '${admin}'   ,db: all         ,addr: world     ,auth: ssl   ,title: 'admin @ everywhere with ssl & pwd'   }
  - {user: '+dbrole_readonly',db: all    ,addr: localhost ,auth: pwd   ,title: 'pgbouncer read/write via local socket'}
  - {user: '+dbrole_readonly',db: all    ,addr: intra     ,auth: pwd   ,title: 'read/write biz user via password'     }
  - {user: '+dbrole_offline' ,db: all    ,addr: intra     ,auth: pwd   ,title: 'allow etl offline tasks from intranet'}
pgb_default_hba_rules:            # pgbouncer 全局默认的HBA规则 
  - {user: '${dbsu}'    ,db: pgbouncer   ,addr: local     ,auth: peer  ,title: 'dbsu local admin access with os ident'}
  - {user: 'all'        ,db: all         ,addr: localhost ,auth: pwd   ,title: 'allow all user local access with pwd' }
  - {user: '${monitor}' ,db: pgbouncer   ,addr: intra     ,auth: pwd   ,title: 'monitor access via intranet with pwd' }
  - {user: '${monitor}' ,db: all         ,addr: world     ,auth: deny  ,title: 'reject all other monitor access addr' }
  - {user: '${admin}'   ,db: all         ,addr: intra     ,auth: pwd   ,title: 'admin access via intranet with pwd'   }
  - {user: '${admin}'   ,db: all         ,addr: world     ,auth: deny  ,title: 'reject all other admin access addr'   }
  - {user: 'all'        ,db: all         ,addr: intra     ,auth: pwd   ,title: 'allow all user intra access with pwd' }
```

<details><summary>示例：渲染 pg_hba.conf</summary>

```ini
#==============================================================#
# File      :   pg_hba.conf
# Desc      :   Postgres HBA Rules for pg-meta-1 [primary]
# Time      :   2023-01-11 15:19
# Host      :   pg-meta-1 @ 10.10.10.10:5432
# Path      :   /pg/data/pg_hba.conf
# Note      :   ANSIBLE MANAGED, DO NOT CHANGE!
# Author    :   Ruohang Feng (rh@vonng.com)
# License   :   AGPLv3
#==============================================================#

# addr alias
# local     : /var/run/postgresql
# admin     : 10.10.10.10
# infra     : 10.10.10.10
# intra     : 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16

# user alias
# dbsu    :  postgres
# repl    :  replicator
# monitor :  dbuser_monitor
# admin   :  dbuser_dba

# dbsu access via local os user ident [default]
local    all                postgres                              ident

# dbsu replication from local os ident [default]
local    replication        postgres                              ident

# replicator replication from localhost [default]
local    replication        replicator                            scram-sha-256
host     replication        replicator         127.0.0.1/32       scram-sha-256

# replicator replication from intranet [default]
host     replication        replicator         10.0.0.0/8         scram-sha-256
host     replication        replicator         172.16.0.0/12      scram-sha-256
host     replication        replicator         192.168.0.0/16     scram-sha-256

# replicator postgres db from intranet [default]
host     postgres           replicator         10.0.0.0/8         scram-sha-256
host     postgres           replicator         172.16.0.0/12      scram-sha-256
host     postgres           replicator         192.168.0.0/16     scram-sha-256

# monitor from localhost with password [default]
local    all                dbuser_monitor                        scram-sha-256
host     all                dbuser_monitor     127.0.0.1/32       scram-sha-256

# monitor from infra host with password [default]
host     all                dbuser_monitor     10.10.10.10/32     scram-sha-256

# admin @ infra nodes with pwd & ssl [default]
hostssl  all                dbuser_dba         10.10.10.10/32     scram-sha-256

# admin @ everywhere with ssl & pwd [default]
hostssl  all                dbuser_dba         0.0.0.0/0          scram-sha-256

# pgbouncer read/write via local socket [default]
local    all                +dbrole_readonly                      scram-sha-256
host     all                +dbrole_readonly   127.0.0.1/32       scram-sha-256

# read/write biz user via password [default]
host     all                +dbrole_readonly   10.0.0.0/8         scram-sha-256
host     all                +dbrole_readonly   172.16.0.0/12      scram-sha-256
host     all                +dbrole_readonly   192.168.0.0/16     scram-sha-256

# allow etl offline tasks from intranet [default]
host     all                +dbrole_offline    10.0.0.0/8         scram-sha-256
host     all                +dbrole_offline    172.16.0.0/12      scram-sha-256
host     all                +dbrole_offline    192.168.0.0/16     scram-sha-256

# allow application database intranet access [common] [DISABLED]
#host    kong            dbuser_kong         10.0.0.0/8          md5
#host    bytebase        dbuser_bytebase     10.0.0.0/8          md5
#host    grafana         dbuser_grafana      10.0.0.0/8          md5

```

</details>



<details><summary>示例: 渲染 pgb_hba.conf</summary>

```ini
#==============================================================#
# File      :   pgb_hba.conf
# Desc      :   Pgbouncer HBA Rules for pg-meta-1 [primary]
# Time      :   2023-01-11 15:28
# Host      :   pg-meta-1 @ 10.10.10.10:5432
# Path      :   /etc/pgbouncer/pgb_hba.conf
# Note      :   ANSIBLE MANAGED, DO NOT CHANGE!
# Author    :   Ruohang Feng (rh@vonng.com)
# License   :   AGPLv3
#==============================================================#

# PGBOUNCER HBA RULES FOR pg-meta-1 @ 10.10.10.10:6432
# ansible managed: 2023-01-11 14:30:58

# addr alias
# local     : /var/run/postgresql
# admin     : 10.10.10.10
# infra     : 10.10.10.10
# intra     : 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16

# user alias
# dbsu    :  postgres
# repl    :  replicator
# monitor :  dbuser_monitor
# admin   :  dbuser_dba

# dbsu local admin access with os ident [default]
local    pgbouncer          postgres                              peer

# allow all user local access with pwd [default]
local    all                all                                   scram-sha-256
host     all                all                127.0.0.1/32       scram-sha-256

# monitor access via intranet with pwd [default]
host     pgbouncer          dbuser_monitor     10.0.0.0/8         scram-sha-256
host     pgbouncer          dbuser_monitor     172.16.0.0/12      scram-sha-256
host     pgbouncer          dbuser_monitor     192.168.0.0/16     scram-sha-256

# reject all other monitor access addr [default]
host     all                dbuser_monitor     0.0.0.0/0          reject

# admin access via intranet with pwd [default]
host     all                dbuser_dba         10.0.0.0/8         scram-sha-256
host     all                dbuser_dba         172.16.0.0/12      scram-sha-256
host     all                dbuser_dba         192.168.0.0/16     scram-sha-256

# reject all other admin access addr [default]
host     all                dbuser_dba         0.0.0.0/0          reject

# allow all user intra access with pwd [default]
host     all                all                10.0.0.0/8         scram-sha-256
host     all                all                172.16.0.0/12      scram-sha-256
host     all                all                192.168.0.0/16     scram-sha-256
```

</details>






----------------

## 安全加固

对于那些需要更高安全性的场合，我们提供了一个安全加固的配置模板 [security.yml](https://github.com/Vonng/pigsty/blob/master/files/pigsty/security.yml)，使用了以下的默认 HBA 规则集： 

```yaml
pg_default_hba_rules:             # postgres host-based auth rules by default
  - {user: '${dbsu}'    ,db: all         ,addr: local     ,auth: ident ,title: 'dbsu access via local os user ident'  }
  - {user: '${dbsu}'    ,db: replication ,addr: local     ,auth: ident ,title: 'dbsu replication from local os ident' }
  - {user: '${repl}'    ,db: replication ,addr: localhost ,auth: ssl   ,title: 'replicator replication from localhost'}
  - {user: '${repl}'    ,db: replication ,addr: intra     ,auth: ssl   ,title: 'replicator replication from intranet' }
  - {user: '${repl}'    ,db: postgres    ,addr: intra     ,auth: ssl   ,title: 'replicator postgres db from intranet' }
  - {user: '${monitor}' ,db: all         ,addr: localhost ,auth: pwd   ,title: 'monitor from localhost with password' }
  - {user: '${monitor}' ,db: all         ,addr: infra     ,auth: ssl   ,title: 'monitor from infra host with password'}
  - {user: '${admin}'   ,db: all         ,addr: infra     ,auth: ssl   ,title: 'admin @ infra nodes with pwd & ssl'   }
  - {user: '${admin}'   ,db: all         ,addr: world     ,auth: cert  ,title: 'admin @ everywhere with ssl & cert'   }
  - {user: '+dbrole_readonly',db: all    ,addr: localhost ,auth: ssl   ,title: 'pgbouncer read/write via local socket'}
  - {user: '+dbrole_readonly',db: all    ,addr: intra     ,auth: ssl   ,title: 'read/write biz user via password'     }
  - {user: '+dbrole_offline' ,db: all    ,addr: intra     ,auth: ssl   ,title: 'allow etl offline tasks from intranet'}
pgb_default_hba_rules:            # pgbouncer host-based authentication rules
  - {user: '${dbsu}'    ,db: pgbouncer   ,addr: local     ,auth: peer  ,title: 'dbsu local admin access with os ident'}
  - {user: 'all'        ,db: all         ,addr: localhost ,auth: pwd   ,title: 'allow all user local access with pwd' }
  - {user: '${monitor}' ,db: pgbouncer   ,addr: intra     ,auth: ssl   ,title: 'monitor access via intranet with pwd' }
  - {user: '${monitor}' ,db: all         ,addr: world     ,auth: deny  ,title: 'reject all other monitor access addr' }
  - {user: '${admin}'   ,db: all         ,addr: intra     ,auth: ssl   ,title: 'admin access via intranet with pwd'   }
  - {user: '${admin}'   ,db: all         ,addr: world     ,auth: deny  ,title: 'reject all other admin access addr'   }
  - {user: 'all'        ,db: all         ,addr: intra     ,auth: ssl   ,title: 'allow all user intra access with pwd' }
```

更多信息，请参考[安全加固](SECURITY)一节。

