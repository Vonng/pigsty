# 数据库服务

> 如何在Pigsty中定义服务

## 个人用户

个人/沙箱用户无需关注**服务**，这是针对在生产环境中使用数据库所提出的概念。

Pigsty会**在管理节点上为管理用户**配置相关环境，个人用户可以直接通过IP地址直连数据库，例如：

```bash
psql # 默认会使用 dbuser_dba 连接至本地的 meta 数据库 vagrant@meta
psql -h 10.10.10.11  # 默认会使用 dbuser_dba 连接至 10.10.10.10 postgres 数据库
````

从外部（宿主机）使用工具访问时，可以使用URL：

```bash
psql postgres://dbuser_dba:DBUser.DBA@10.10.10.10/meta         # 超级用户 直连
psql postgres://dbuser_meta:DBUser.Meta@10.10.10.10/meta       # 业务用户 直连
psql postgres://dbuser_meta:DBUser.Meta@10.10.10.10:5433/meta  # 走负载均衡与连接池
```

在生产环境部署Pigsty时，需要关注**服务**。

## 什么是服务

**服务（Service）**是数据库集群对外提供功能的形式。

在真实世界的生产环境中，我们会使用基于复制的主从数据库集群。集群中有且仅有一个实例作为领导者（主库），可以接受写入，而其他实例（从库）则会从持续从集群领导者获取变更日志，与领导者保持一致。同时从库还可以承载只读请求，对于读多写少的场景可以显著分担主库负载，因此区分集群的写入请求与只读请求是一个常规实践。

此外对于高频短连接的生产环境，我们还会通过连接池中间件（Pgbouncer）对请求进行池化，减少连接与后端进程的创建开销。但对于ETL与变更执行等场景，我们又需要绕过连接池，直接访问数据库。

此外，高可用集群在故障时会出现**故障切换（Failover）**，故障切换会导致集群的领导者出现变更。因此高可用的数据库方案要求写入流量可以自动适配集群的领导者变化。

这些不同的访问需求（读写分离，池化与直连，故障切换自动适配）最终抽象为**服务**的概念。


## 服务的表现形式

服务对外的表现形式通常是一个**访问端点**，例如一个PostgreSQL数据库的连接URL，
用户可以通过该端点获取相应的数据库功能。

通常来说，数据库集群**必须提供一种服务**：

- **读写服务（primary）** ：可以写入数据库

对于生产数据库集群**至少应当提供两种服务**：

- **读写服务（primary）** ：可以写入数据库

- **只读服务（replica）** ：可以访问只读数据副本

此外，根据具体的业务场景，可能还会有其他的服务，例如：

- **离线从库服务（offline）**：不承接线上只读流量的专用从库，用于ETL与个人查询
- **同步从库服务（standby）** ：采用同步提交，没有复制延迟的只读服务
- **延迟从库服务（delayed）** ： 允许业务访问固定时间间隔之前的旧数据
- **默认直连服务（default）** ： 允许（管理）用户绕过连接池直接管理数据库的服务



## 默认服务

Pigsty默认对外提供四种服务：`primary`, `replica`, `default`, `offline`

您可以通过配置文件为全局或单个集群定义新的服务

| 服务    | 端口 | 用途         | 说明                         |
| ------- | ---- | ------------ | ---------------------------- |
| primary | 5433 | 生产读写     | 通过**连接池**连接至集群主库 |
| replica | 5434 | 生产只读     | 通过**连接池**连接至集群从库 |
| default | 5436 | 管理         | 直接连接至集群主库           |
| offline | 5438 | ETL/个人用户 | 直接连接至集群可用的离线实例 |

以元数据库`pg-meta`为例

```bash
psql postgres://dbuser_meta:DBUser.Meta@pg-meta:5433/meta     # 生产读写
psql postgres://dbuser_meta:DBUser.Meta@pg-meta:5434/meta     # 生产只读
psql postgres://dbuser_dba:DBUser.DBA@pg-meta:5436/meta       # 直连主库
psql postgres://dbuser_stats:DBUser.Stats@pg-meta:5438/meta   # 直连离线
```

以沙箱测试集群`pg-test`为例

| 服务    | 端口 | 说明                       | 样例                                                         |
| ------- | ---- | -------------------------- | ------------------------------------------------------------ |
| primary | 5433 | 只有生产用户可以连接       | postgres://test@pg-test:5433/test                            |
| replica | 5434 | 只有生产用户可以连接       | postgres://test@pg-test:5434/test                            |
| default | 5436 | 管理员与DML执行者可以连接  | postgres://dbuser_admin@pg-test:5436/test                    |
| offline | 5438 | ETL/STATS 个人用户可以连接 | postgres://dbuser_stats@pg-test-tt:5438/test<br />postgres://dbp_vonng@pg-test:5438/test |

下面将详细介绍这四种服务


## Primary服务

Primary服务服务于**线上生产读写访问**，它将集群的5433端口，映射为 **主库连接池（默认6432）** 端口。

Primary服务选择集群中的**所有**实例作为其成员，但只有健康检查`/primary`为真者，才能实际承接流量。

在集群中有且仅有一个实例是主库，只有其健康检查为真。

```yaml
# primary service will route {ip|name}:5433 to primary pgbouncer (5433->6432 rw)
- name: primary           # service name {{ pg_cluster }}-primary
  src_ip: "*"
  src_port: 5433
  dst_port: pgbouncer     # 5433 route to pgbouncer
  check_url: /primary     # primary health check, success when instance is primary
  selector: "[]"          # select all instance as primary service candidate
```



## Replica服务

Replica服务服务于**线上生产只读访问**，它将集群的5434端口，映射为 **从库连接池（默认6432）** 端口。

Replica服务选择集群中的**所有**实例作为其成员，但只有健康检查`/read-only`为真者，才能实际承接流量，该健康检查对所有可以承接只读流量的实例（包括主库）返回成功。所以集群中的任何成员都可以承载只读流量。

但默认情况下，只有从库承载只读请求，Replica服务定义了`selector_backup`，该选择器将集群的主库作为 **备份实例** 加入到Replica服务中。只要当Replica服务中所有其他实例，即**所有从库宕机时，主库才会开始承接只读流量**。

```yaml
# replica service will route {ip|name}:5434 to replica pgbouncer (5434->6432 ro)
- name: replica           # service name {{ pg_cluster }}-replica
  src_ip: "*"
  src_port: 5434
  dst_port: pgbouncer
  check_url: /read-only   # read-only health check. (including primary)
  selector: "[]"          # select all instance as replica service candidate
  selector_backup: "[? pg_role == `primary`]"   # primary are used as backup server in replica service
```



## Default服务

Default服务服务于**线上主库直连**，它将集群的5436端口，映射为**主库Postgres**端口（默认5432）。

Default服务针对交互式的读写访问，包括：执行管理命令，执行DDL变更，连接至主库执行DML，执行CDC。交互式的操作**不应当**通过连接池访问，因此Default服务将流量直接转发至Postgres，绕过了Pgbouncer。

Default服务与Primary服务类似，采用相同的配置选项。出于演示目显式填入了默认参数。

```yaml
# default service will route {ip|name}:5436 to primary postgres (5436->5432 primary)
- name: default           # service's actual name is {{ pg_cluster }}-default
  src_ip: "*"             # service bind ip address, * for all, vip for cluster virtual ip address
  src_port: 5436          # bind port, mandatory
  dst_port: postgres      # target port: postgres|pgbouncer|port_number , pgbouncer(6432) by default
  check_method: http      # health check method: only http is available for now
  check_port: patroni     # health check port:  patroni|pg_exporter|port_number , patroni by default
  check_url: /primary     # health check url path, / as default
  check_code: 200         # health check http code, 200 as default
  selector: "[]"          # instance selector
  haproxy:                # haproxy specific fields
    maxconn: 3000         # default front-end connection
    balance: roundrobin   # load balance algorithm (roundrobin by default)
    default_server_options: 'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'
```



## Offline服务

Offline服务用于离线访问与个人查询。它将集群的**5438**端口，映射为**离线实例Postgres**端口（默认5432）。

Offline服务针对交互式的只读访问，包括：ETL，离线大型分析查询，个人用户查询。交互式的操作**不应当**通过连接池访问，因此Default服务将流量直接转发至离线实例的Postgres，绕过了Pgbouncer。

离线实例指的是 `pg_role == offline` 或带有`pg_offline_query`标记的实例。离线实例外的其他**其他从库**将作为Offline的备份实例，这样当Offline实例宕机时，Offline服务仍然可以从其他从库获取服务。

```yaml
# offline service will route {ip|name}:5438 to offline postgres (5438->5432 offline)
- name: offline           # service name {{ pg_cluster }}-offline
  src_ip: "*"
  src_port: 5438
  dst_port: postgres
  check_url: /replica     # offline MUST be a replica
  selector: "[? pg_role == `offline` || pg_offline_query ]"         # instances with pg_role == 'offline' or instance marked with 'pg_offline_query == true'
  selector_backup: "[? pg_role == `replica` && !pg_offline_query]"  # replica are used as backup server in offline service
```

## 服务定义

由服务定义对象构成的数组，定义了每一个数据库集群中对外暴露的服务。每一个集群都可以定义多个服务，每个服务包含任意数量的集群成员，服务通过**端口**进行区分。

服务通过 [**`pg_services`**] 与 [**`pg_services_extra`**]进行定义。前者用于定义整个环境中通用的服务，后者用于定义集群特定的额外服务。两者都是由**服务定义**组成的数组。

以下代码定义了一个新的服务`standby`，使用`5435`端口对外提供**同步读取**功能。该服务会从集群中的同步从库（或主库）进行读取，从而确保所有读取都不存在延迟。

```yaml
# standby service will route {ip|name}:5435 to sync replica's pgbouncer (5435->6432 standby)
- name: standby                   # required, service name, the actual svc name will be prefixed with `pg_cluster`, e.g: pg-meta-standby
  src_ip: "*"                     # required, service bind ip address, `*` for all ip, `vip` for cluster `vip_address`
  src_port: 5435                  # required, service exposed port (work as kubernetes service node port mode)
  dst_port: postgres              # optional, destination port, postgres|pgbouncer|<port_number>   , pgbouncer(6432) by default
  check_method: http              # optional, health check method: http is the only available method for now
  check_port: patroni             # optional, health check port: patroni|pg_exporter|<port_number> , patroni(8008) by default
  check_url: /read-only?lag=0     # optional, health check url path, / by default
  check_code: 200                 # optional, health check expected http code, 200 by default
  selector: "[]"                  # required, JMESPath to filter inventory ()
  selector_backup: "[? pg_role == `primary`]"  # primary used as backup server for standby service (will not work because /sync for )
  haproxy:                        # optional, adhoc parameters for haproxy service provider (vip_l4 is another service provider)
    maxconn: 3000                 # optional, max allowed front-end connection
    balance: roundrobin           # optional, haproxy load balance algorithm (roundrobin by default, other: leastconn)
    default_server_options: 'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'


```

#### **必选项目**[ ](http://localhost:1313/zh/docs/config/10-service/#必选项目)

- **名称（`service.name`）**：

  **服务名称**，服务的完整名称以数据库集群名为前缀，以`service.name`为后缀，通过`-`连接。例如在`pg-test`集群中`name=primary`的服务，其完整服务名称为`pg-test-primary`。

- **端口（`service.port`）**：

  在Pigsty中，服务默认采用NodePort的形式对外暴露，因此暴露端口为必选项。但如果使用外部负载均衡服务接入方案，您也可以通过其他的方式区分服务。

- **选择器（`service.selector`）**：

  **选择器**指定了服务的实例成员，采用JMESPath的形式，从所有集群实例成员中筛选变量。默认的`[]`选择器会选取所有的集群成员。

#### 可选项目

- **备份选择器（`service.selector`）**：

  可选的 **备份选择器**`service.selector_backup`会选择或标记用于服务备份的实例列表，即集群中所有其他成员失效时，备份实例才接管服务。例如可以将`primary`实例加入`replica`服务的备选集中，当所有从库失效后主库依然可以承载集群的只读流量。

- **源端IP（`service.src_ip`）** ：

  表示**服务**对外使用的IP地址，默认为`*`，即本机所有IP地址。使用`vip`则会使用`vip_address`变量取值，或者也可以填入网卡支持的特定IP地址。

- **宿端口（`service.dst_port`）**：

  服务的流量将指向目标实例上的哪个端口？`postgres` 会指向数据库监听的端口，`pgbouncer`会指向连接池所监听的端口，也可以填入固定的端口号。

- **健康检查方式（`service.check_method`）**:

  服务如何检查实例的健康状态？目前仅支持HTTP

- **健康检查端口（`service.check_port`）**:

  服务检查实例的哪个端口获取实例的健康状态？ `patroni`会从Patroni（默认8008）获取，`pg_exporter`会从PG Exporter（默认9630）获取，用户也可以填入自定义的端口号。

- **健康检查路径（`service.check_url`）**:

  服务执行HTTP检查时，使用的URL PATH。默认会使用`/`作为健康检查，PG Exporter与Patroni提供了多样的健康检查方式，可以用于主从流量区分。例如，`/primary`仅会对主库返回成功，`/replica`仅会对从库返回成功。`/read-only`则会对任何支持只读的实例（包括主库）返回成功。

- **健康检查代码（`service.check_code`）**:

  HTTP健康检查所期待的代码，默认为200

- **Haproxy特定配置（`service.haproxy`）** ：

  关于服务供应软件（HAProxy）的专有配置项



## 服务实现

目前Pigsty默认使用基于HAProxy的服务实现，也提供了基于4层负载均衡（L4VIP）的实现样例，两者相互等效，各有优势。详情请参考[接入](c-access.md)一节。

