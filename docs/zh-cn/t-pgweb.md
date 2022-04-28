# PGWeb


## PGWEB配置

| ID  | Name                                    |           Section           | Type   | Level | Comment                       |
|-----|-----------------------------------------|-----------------------------|--------|-------|-------------------------------|
| 230  | [`pgweb_enabled`](v-infra.md#pgweb_enabled)                  | [`PGWEB`](v-infra.md#PGWEB)                     | G     | 是否启用PgWeb                        |
| 231  | [`pgweb_username`](v-infra.md#pgweb_username)                | [`PGWEB`](v-infra.md#PGWEB)                     | G     | PgWeb使用的操作系统用户              |


PGWeb 是基于浏览器的PostgreSQL客户端工具，可用于小批量个人数据查询等场景。目前为可选Beta功能，默认只在Demo中启用

在Demo中该功能默认启用，其他情况下默认关闭，可以使用 [`infra-pgweb`](p-infra.md#infra-pgweb) 在元节点上手动部署。


### `pgweb_enabled`

是否启用PgWeb, 类型：`bool`，层级：G，默认值为：`false`，对于演示与个人使用默认启用，对于生产环境部署默认不启用。

PGWEB的网页界面默认只能通过域名由 Nginx 代理访问，默认为`cli.pigsty`，默认会使用名为`pgweb`的操作系统用户运行。

```yaml
- { name: pgweb,        domain: cli.pigsty, endpoint: "127.0.0.1:8081" }
```


### `pgweb_username`

PgWeb使用的操作系统用户, 类型：`bool`，层级：G，默认值为：`"pgweb"`

运行PGWEB服务器的操作系统用户。默认为`pgweb`，即会创建一个低权限的默认用户`pgweb`。

特殊用户名`default`会使用当前执行安装的用户（通常为管理员）运行 PGWEB。

您需要数据库的连接串方可通过PgWeb访问环境中的数据库。例如：`p



## PGWEB剧本

### `infra-pgweb`

PGWeb 是基于浏览器的PostgreSQL客户端工具，可用于小批量个人数据查询等场景。目前为可选Beta功能，默认只在Demo中启用

[`infra-pgweb.yml`](https://github.com/Vonng/pigsty/blob/master/infra-pgweb.yml) 剧本用于在元节点上加装 PGWeb 服务。

请参照：[配置: PGWEB](v-infra.md#PGWEB) 中的说明调整配置清单，然后执行此剧本即可。

```bash
./infra-pgweb.yml
```






