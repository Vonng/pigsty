# PostgreSQL 服务与接入

> 分离读写操作，正确路由流量，稳定可靠地交付 PostgreSQL 集群提供的能力。

服务是一种抽象：用于封装底数据库层集群的细节，特别是集群故障转移/切换期间。

---------------

## 个人用户

“服务” 的概念是给生产环境用的，个人用户/单机集群，就别折腾什么服务了，直接拿实例名/IP地址一把梭连上去。

```bash
psql postgres://dbuser_dba:DBUser.DBA@10.10.10.10/meta     # 直接用 DBA 超级用户连上去
psql postgres://dbuser_meta:DBUser.Meta@10.10.10.10/meta   # 用默认的业务管理员用户连上去
psql postgres://dbuser_view:DBUser.View@pg-meta/meta       # 用默认的只读用户走实例域名连上去
```


---------------

## 服务

**服务**（**Service**） 是 PostgreSQL 集群功能的逻辑抽象，它包括：

1. 通过 NodePort 的访问点
2. 通过 Selectors 的目标实例

这很像 Kubernetes 的服务（NodePort 模式），但它的实现方式不同（节点上的 haproxy）。

以下是默认的 PostgreSQL 服务及其定义：

| 服务    | 端口 | 描述                                  |
| ------- | ---- | ------------------------------------- |
| primary | 5433 | PROD 读/写，连接到主要的 5432 或 6432 |
| replica | 5434 | PROD 只读，连接到备份的 5432/6432     |
| default | 5436 | 管理或直接访问主要的                  |
| offline | 5438 | OLAP、ETL、个人用户、交互式查询       |

```yaml
- { name: primary ,port: 5433 ,dest: default  ,check: /primary   ,selector: "[]" }
- { name: replica ,port: 5434 ,dest: default  ,check: /read-only ,selector: "[]" , backup: "[? pg_role == `primary` || pg_role == `offline` ]" }
- { name: default ,port: 5436 ,dest: postgres ,check: /primary   ,selector: "[]" }
- { name: offline ,port: 5438 ,dest: postgres ,check: /replica   ,selector: "[? pg_role == `offline` || pg_offline_query ]" , backup: "[? pg_role == `replica` && !pg_offline_query]"}
```

![pgsql-ha](https://user-images.githubusercontent.com/8587410/206971583-74293d7b-d29a-4ca2-8728-75d50421c371.gif)

以默认的 `pg-meta` 集群和 `meta` 数据库为例，它将有四个默认服务：

```bash
psql postgres://dbuser_meta:DBUser.Meta@pg-meta:5433/meta   # pg-meta-primary : 通过主要的 pgbouncer(6432) 进行生产读写
psql postgres://dbuser_meta:DBUser.Meta@pg-meta:5434/meta   # pg-meta-replica : 通过备份的 pgbouncer(6432) 进行生产只读
psql postgres://dbuser_dba:DBUser.DBA@pg-meta:5436/meta     # pg-meta-default : 通过主要的 postgres(5432) 直接连接
psql postgres://dbuser_stats:DBUser.Stats@pg-meta:5438/meta # pg-meta-offline : 通过离线的 postgres(5432) 直接连接
```

`pg-meta` 集群的每一个实例都会暴露这四个服务；你可以通过它们中的任何一个/所有来访问服务。



---------------

## Primary服务

Primary服务可能是生产环境中最关键的服务。

根据[`pg_default_service_dest`](#pg_default_service_dest)将流量路由到主实例：

- `pgbouncer`：将流量路由到主pgbouncer端口（6432），这是默认行为
- `postgres`：如果您不想使用pgbouncer，直接将流量路由到主postgres端口（5432）

```yaml
- { name: primary ,port: 5433 ,dest: default  ,check: /primary   ,selector: "[]" }
```

这意味着所有集群成员都将被包括在Primary服务中（`selector: "[]"`），但唯一通过健康检查的实例（`check: /primary`）将被用作主实例。 Patroni将确保任何时候只有一个实例是主实例，因此Primary服务将始终将流量路由到主实例。

<details><summary>示例：pg-test-primary 的 haproxy 配置</summary>

```ini
listen pg-test-primary
    bind *:5433
    mode tcp
    maxconn 5000
    balance roundrobin
    option httpchk
    option http-keep-alive
    http-check send meth OPTIONS uri /primary
    http-check expect status 200
    default-server inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100
    # servers
    server pg-test-1 10.10.10.11:6432 check port 8008 weight 100
    server pg-test-3 10.10.10.13:6432 check port 8008 weight 100
    server pg-test-2 10.10.10.12:6432 check port 8008 weight 100
```

</details>




---------------

## Replica服务

Replica服务用于生产环境的只读流量。

在实际场景中，可能有更多的只读查询而不是读写查询，因此您可能有很多副本。

Replica服务将根据[`pg_default_service_dest`](#pg_default_service_dest)将流量路由到pgbouncer或postgres，就像[Primary服务](#primary-service)一样。

```yaml
- { name: replica ,port: 5434 ,dest: default  ,check: /read-only ,selector: "[]" , backup: "[? pg_role == `primary` || pg_role == `offline` ]" }
```

`replica`服务流量会尝试使用[`pg_role`](#pg_role) = `replica`的普通pg实例，尽量减轻`primary`实例的负担。 它将尽量不使用[`pg_role`](#pg_role) = `offline`的实例，以尽可能避免混合OLAP和OLTP查询。

当所有集群成员通过只读健康检查（`check: /read-only`）时，都将被包括在Replica服务中（`selector: "[]"`）。 而当所有`replica`实例都宕机时，`primary`和`offline`实例将被用作备用服务器。

<details><summary>示例：pg-test-replica 的 haproxy 配置</summary> 

```ini
listen pg-test-replica
    bind *:5434
    mode tcp
    maxconn 5000
    balance roundrobin
    option httpchk
    option http-keep-alive
    http-check send meth OPTIONS uri /read-only
    http-check expect status 200
    default-server inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100
    # servers
    server pg-test-1 10.10.10.11:6432 check port 8008 weight 100 backup
    server pg-test-3 10.10.10.13:6432 check port 8008 weight 100
    server pg-test-2 10.10.10.12:6432 check port 8008 weight 100
```

</details>





---------------

### Default服务

Default服务默认会路由到主postgres（5432）。

它很像Primary服务，不同之处在于，无论[`pg_default_service_dest`](#pg_default_service_dest)如何，它总是会绕过pgbouncer。 这对于管理连接、ETL写入、CDC数据变更捕获等都很有用。

```
yamlCopy code
- { name: primary ,port: 5433 ,dest: default  ,check: /primary   ,selector: "[]" }
```

<details><summary>示例：pg-test-default 的 haproxy 配置</summary> 

```ini
listen pg-test-default
    bind *:5436
    mode tcp
    maxconn 5000
    balance roundrobin
    option httpchk
    option http-keep-alive
    http-check send meth OPTIONS uri /primary
    http-check expect status 200
    default-server inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100
    # servers
    server pg-test-1 10.10.10.11:5432 check port 8008 weight 100
    server pg-test-3 10.10.10.13:5432 check port 8008 weight 100
    server pg-test-2 10.10.10.12:5432 check port 8008 weight 100
```

</details>




---------------

### Offline服务

Offline服务将流量直接路由到专用的postgres实例。

这可能是一个[`pg_role`](#pg_role) = `offline`的实例，或者是一个被[`pg_offline_query`](#pg_offline_query)标记的实例。

如果没有找到此类实例，它将回退到任何副本实例。最基本的是：它永远不会将流量路由到主实例。

```yaml
- { name: offline ,port: 5438 ,dest: postgres ,check: /replica   ,selector: "[? pg_role == `offline` || pg_offline_query ]" , backup: "[? pg_role == `replica` && !pg_offline_query]"}
```

<details><summary>示例：pg-test-offline 的 haproxy 配置</summary> 

```ini
listen pg-test-offline
    bind *:5438
    mode tcp
    maxconn 5000
    balance roundrobin
    option httpchk
    option http-keep-alive
    http-check send meth OPTIONS uri /replica
    http-check expect status 200
    default-server inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100
    # servers
    server pg-test-3 10.10.10.13:5432 check port 8008 weight 100
    server pg-test-2 10.10.10.12:5432 check port 8008 weight 100 backup
```

</details>


---------------

## 定义服务

默认服务在 [`pg_default_services`](PARAM#pg_default_services) 中定义。

你可以在全局或集群级别使用 [`pg_services`](PARAM#pg_services) 定义额外的 PostgreSQL 服务。

这两个参数都是服务对象的数组。每个服务定义都会在 `/etc/haproxy/<svcname>.cfg` 中呈现为一个 haproxy 配置，详见 [`service.j2`](https://github.com/Vonng/pigsty/blob/master/roles/pgsql/templates/service.j2)。

以下是一个额外服务定义的示例：`standby`

```yaml
- name: standby                   # 必需，服务名称，实际的 svc 名称会有 `pg_cluster` 作为前缀，例如：pg-meta-standby
  port: 5435                      # 必需，暴露的服务端口（作为 kubernetes 服务节点端口模式）
  ip: "*"                         # 可选，服务绑定的 IP 地址，默认情况下为所有 IP
  selector: "[]"                  # 必需，服务成员选择器，使用 JMESPath 来筛选库存
  dest: default                   # 可选，目标端口，default|postgres|pgbouncer|<port_number>，默认为 'default'
  check: /sync                    # 可选，健康检查 URL 路径，默认为 /
  backup: "[? pg_role == `primary`]"  # 备份服务器选择器
  maxconn: 3000                   # 可选，允许的前端连接最大数
  balance: roundrobin             # 可选，haproxy 负载均衡算法（默认为 roundrobin，其他选项：leastconn）
  options: 'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'
```

它将被转换为一个 haproxy 配置文件 `/etc/haproxy/pg-test-standby.conf`：

```ini
#---------------------------------------------------------------------
# service: pg-test-standby @ 10.10.10.11:5435
#---------------------------------------------------------------------
# service instances 10.10.10.11, 10.10.10.13, 10.10.10.12
# service backups   10.10.10.11
listen pg-test-standby
    bind *:5435
    mode tcp
    maxconn 5000
    balance roundrobin
    option httpchk
    option http-keep-alive
    http-check send meth OPTIONS uri /
    http-check expect status 200
    default-server inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100
    # servers
    server pg-test-1 10.10.10.11:6432 check port 8008 weight 100 backup
    server pg-test-3 10.10.10.13:6432 check port 8008 weight 100
    server pg-test-2 10.10.10.12:6432 check port 8008 weight 100
```




---------------

## 重载服务

当集群成员发生变化，如添加/删除副本、主备切换或调整相对权重时， 你必须 [重载服务](PGSQL-ADMIN#reload-service) 以使更改生效。

```
bashCopy code
bin/pgsql-svc <cls> [ip...]         # 为 lb 集群或 lb 实例重载服务
# ./pgsql.yml -t pg_service         # 重载服务的实际 ansible 任务
```


---------------

## 接入服务

Pigsty 使用 haproxy 提供 [service](#service)。默认情况下，所有节点都启用了它。

haproxy 负载均衡器默认在相同的 pg 集群之间是幂等的，你可以通过任何方式使用它们。

典型的方法是通过集群域名访问，它解析为集群的 L2 VIP，或者以轮询方式解析所有实例的 IP 地址。

Service 可以以不同的方式实现，你甚至可以实现你自己的访问方法，如 L4 LVS、F5 等，而不是使用 haproxy。

你可以使用不同的 [host](#host) 和 [port](#port) 组合，它们以不同的方式提供 PostgreSQL 服务。

**主机**

| 类型        | 样例            | 描述                                       |
|-----------|---------------|------------------------------------------|
| 集群域名      | `pg-test`     | 通过集群域名访问（由 dnsmasq @ infra 节点解析）         |
| 集群 VIP 地址 | `10.10.10.3`  | 通过由 `vip-manager` 管理的 L2 VIP 地址访问，绑定到主节点 |
| 实例主机名     | `pg-test-1`   | 通过任何实例主机名访问（由 dnsmasq @ infra 节点解析）      |
| 实例 IP 地址  | `10.10.10.11` | 访问任何实例的 IP 地址                            |

**端口**

Pigsty 使用不同的 **端口** 来区分 [pg services](#service)

| 端口   | 服务        | 类型  | 描述                          |
|------|-----------|-----|-----------------------------|
| 5432 | postgres  | 数据库 | 直接访问 postgres 服务器           |
| 6432 | pgbouncer | 中间件 | 访问 postgres 前先通过连接池中间件      |
| 5433 | primary   | 服务  | 访问主 pgbouncer (或 postgres)  |
| 5434 | replica   | 服务  | 访问备份 pgbouncer (或 postgres) |
| 5436 | default   | 服务  | 访问主 postgres                |
| 5438 | offline   | 服务  | 访问离线 postgres               |

**组合**


```bash
# 通过集群域名访问
postgres://test@pg-test:5432/test # DNS -> L2 VIP -> 主直接连接
postgres://test@pg-test:6432/test # DNS -> L2 VIP -> 主连接池 -> 主
postgres://test@pg-test:5433/test # DNS -> L2 VIP -> HAProxy -> 主连接池 -> 主
postgres://test@pg-test:5434/test # DNS -> L2 VIP -> HAProxy -> 备份连接池 -> 备份
postgres://dbuser_dba@pg-test:5436/test # DNS -> L2 VIP -> HAProxy -> 主直接连接 (用于管理员)
postgres://dbuser_stats@pg-test:5438/test # DNS -> L2 VIP -> HAProxy -> 离线直接连接 (用于 ETL/个人查询)

# 通过集群 VIP 直接访问
postgres://test@10.10.10.3:5432/test # L2 VIP -> 主直接访问
postgres://test@10.10.10.3:6432/test # L2 VIP -> 主连接池 -> 主
postgres://test@10.10.10.3:5433/test # L2 VIP -> HAProxy -> 主连接池 -> 主
postgres://test@10.10.10.3:5434/test # L2 VIP -> HAProxy -> 备份连接池 -> 备份
postgres://dbuser_dba@10.10.10.3:5436/test # L2 VIP -> HAProxy -> 主直接连接 (用于管理员)
postgres://dbuser_stats@10.10.10.3::5438/test # L2 VIP -> HAProxy -> 离线直接连接 (用于 ETL/个人查询)

# 直接指定任何集群实例名
postgres://test@pg-test-1:5432/test # DNS -> 数据库实例直接连接 (单例访问)
postgres://test@pg-test-1:6432/test # DNS -> 连接池 -> 数据库
postgres://test@pg-test-1:5433/test # DNS -> HAProxy -> 连接池 -> 数据库读/写
postgres://test@pg-test-1:5434/test # DNS -> HAProxy -> 连接池 -> 数据库只读
postgres://dbuser_dba@pg-test-1:5436/test # DNS -> HAProxy -> 数据库直接连接
postgres://dbuser_stats@pg-test-1:5438/test # DNS -> HAProxy -> 数据库离线读/写

# 直接指定任何集群实例 IP 访问
postgres://test@10.10.10.11:5432/test # 数据库实例直接连接 (直接指定实例, 没有自动流量分配)
postgres://test@10.10.10.11:6432/test # 连接池 -> 数据库
postgres://test@10.10.10.11:5433/test # HAProxy -> 连接池 -> 数据库读/写
postgres://test@10.10.10.11:5434/test # HAProxy -> 连接池 -> 数据库只读
postgres://dbuser_dba@10.10.10.11:5436/test # HAProxy -> 数据库直接连接
postgres://dbuser_stats@10.10.10.11:5438/test # HAProxy -> 数据库离线读-写

# 智能客户端：自动进行读写分离
postgres://test@10.10.10.11:6432,10.10.10.12:6432,10.10.10.13:6432/test?target_session_attrs=primary
postgres://test@10.10.10.11:6432,10.10.10.12:6432,10.10.10.13:6432/test?target_session_attrs=prefer-standby
```



---------------

## 覆盖服务

你可以通过多种方式覆盖默认的服务配置：

**绕过Pgbouncer**

当定义一个服务时，如果 `svc.dest='default'`，此参数 [`pg_default_service_dest`](#pg_default_service_dest) 将被用作默认值。 默认使用 `pgbouncer`，你可以改为使用 `postgres`，这样默认的主和副本服务将绕过pgbouncer，直接将流量路由到postgres。

如果你完全不需要连接池，你可以将 [`pg_default_service_dest`](#pg_default_service_dest) 更改为 `postgres`，并移除 `default` 和 `offline` 服务。

如果你不需要只读副本来处理在线流量，你也可以从 `pg_default_services` 中移除 `replica`。

```yaml
pg_default_services:
  - { name: primary ,port: 5433 ,dest: default  ,check: /primary   ,selector: "[]" }
  - { name: replica ,port: 5434 ,dest: default  ,check: /read-only ,selector: "[]" , backup: "[? pg_role == `primary` || pg_role == `offline` ]" }
  - { name: default ,port: 5436 ,dest: postgres ,check: /primary   ,selector: "[]" }
  - { name: offline ,port: 5438 ,dest: postgres ,check: /replica   ,selector: "[? pg_role == `offline` || pg_offline_query ]" , backup: "[? pg_role == `replica` && !pg_offline_query]"}
```


---------------

## 委托服务

Pigsty 通过节点上的 haproxy 暴露 PostgreSQL 服务。整个集群中的所有 haproxy 实例都使用相同的服务定义进行配置。

但是，你可以将 pg 服务委托给特定的节点组（例如，专门的 haproxy 负载均衡器集群），而不是集群成员。

为此，你需要使用 [`pg_default_services`](#pg_default_services) 覆盖默认的服务定义，并将 [`pg_service_provider`](#pg_service_provider) 设置为代理组名称。

例如，此配置将在端口 10013 的 `proxy` haproxy 节点组上公开 pg 集群的主服务。

```yaml

pg_service_provider: proxy       # 使用端口 10013 上的 `proxy` 组的负载均衡器
pg_default_services:  [{ name: primary ,port: 10013 ,dest: postgres  ,check: /primary   ,selector: "[]" }]
```

用户需要确保每个委托服务的端口，在代理集群中都是**唯一**的。
