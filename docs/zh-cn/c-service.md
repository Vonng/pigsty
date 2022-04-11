# PGSQL服务与接入

> 如何定义PostgreSQL[服务](#服务)，并通过负载均衡与连接池实现稳定可靠高性能的[接入](#接入)

[单机用户](#单机用户)无需关注[**服务**](#服务)与[**接入**](#接入)的概念，这是针对在生产环境中使用高可用PostgreSQL数据库集群所提出的概念。



---------------

### 单机用户

完成单机部署后，该节点的5432端口对外提供PostgreSQL数据库服务，80端口对外提供UI类服务。

在当前管理节点上，使用管理用户无参数执行 `psql` 可以直接连接到本机预定义的 `meta` 数据库，开箱即用。

从外部（宿主机）使用客户端工具访问PG时，可以使用以下URL：

```bash
psql postgres://dbuser_dba:DBUser.DBA@10.10.10.10/meta         # 默认超级用户 直连
psql postgres://dbuser_meta:DBUser.Meta@10.10.10.10/meta       # 默认业务用户 直连
```

您可以使用由 [`pg_admin_username`](v-pgsql.md#pg_admin_username) 与 [`pg_admin_password`](v-pgsql.md#pg_admin_password) 指定的管理员用户，或预先在`meta`数据库中定义的其他业务用户（`dbuser_meta`）访问该数据库。

在生产环境使用Pigsty部署的高可用数据库集群，强烈不建议使用IP直连的方式[接入](#接入)数据库[服务](#服务)。



---------------

## 服务

**服务（Service）**是数据库集群对外提供功能的形式。

在真实世界的生产环境中，我们会使用基于复制的主从数据库集群。集群中有且仅有一个实例作为领导者（主库），可以接受写入，而其他实例（从库）则会从持续从集群领导者获取变更日志，与领导者保持一致。同时从库还可以承载只读请求，对于读多写少的场景可以显著分担主库负载，因此区分集群的写入请求与只读请求是一个常规实践。

此外对于高频短连接的生产环境，我们还会通过连接池中间件（Pgbouncer）对请求进行池化，减少连接与后端进程的创建开销。但对于ETL与变更执行等场景，我们又需要绕过连接池，直接访问数据库。

此外，高可用集群在故障时会出现**故障切换（Failover）**，故障切换会导致集群的领导者出现变更。因此高可用的数据库方案要求写入流量可以自动适配集群的领导者变化。

这些不同的访问需求（读写分离，池化与直连，故障切换自动适配）最终抽象为**服务**的概念。

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




---------------

## 默认服务



Pigsty默认对外提供四种服务：[`primary`](#Primary服务), [`replica`](Replica服务), [`default`](Default服务), [`offline`](Offline服务)

您可以通过配置文件为全局或单个集群定义新的服务

| 服务                      | 端口 | 用途         | 说明                         |
|-------------------------| ---- | ------------ | ---------------------------- |
| [`primary`](#primary服务) | 5433 | 生产读写     | 通过**连接池**连接至集群主库 |
| [`replica`](#replica服务) | 5434 | 生产只读     | 通过**连接池**连接至集群从库 |
| [`default`](#default服务) | 5436 | 管理         | 直接连接至集群主库           |
| [`offline`](#offline服务) | 5438 | ETL/个人用户 | 直接连接至集群可用的离线实例 |

以默认的元数据库`pg-meta`为例

```bash
psql postgres://dbuser_meta:DBUser.Meta@pg-meta:5433/meta     # 生产读写
psql postgres://dbuser_meta:DBUser.Meta@pg-meta:5434/meta     # 生产只读
psql postgres://dbuser_dba:DBUser.DBA@pg-meta:5436/meta       # 直连主库
psql postgres://dbuser_stats:DBUser.Stats@pg-meta:5438/meta   # 直连离线
```

下面将详细介绍这四种服务


### Primary服务

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
  selector: "[]"            # select all instance as primary service candidate
```

主库上的高可用组件Patroni针对Primary健康检查返回200，用于确保集群不会出现一个以上的主库实例。

当集群发生故障切换时，新主库的健康检查为真，老主库的健康检查为假，因此流量将迁移至新主库上。业务方会察觉到约30秒的 Primary服务 不可用时间。



### Replica服务

Replica服务服务于**线上生产只读访问**，它将集群的5434端口，映射为 **从库连接池（默认6432）** 端口。

Replica服务选择集群中的**所有**实例作为其成员，但只有健康检查`/read-only`为真者，才能实际承接流量，该健康检查对所有可以承接只读流量的实例（包括主库）返回成功。所以集群中的任何成员都可以承载只读流量。

但默认情况下，只有从库承载只读请求，Replica服务定义了`selector_backup`，该选择器将集群的主库作为 **备份实例** 加入到Replica服务中。只要当Replica服务中所有其他实例，即**所有从库宕机时，主库才会开始承接只读流量**。

另一个作为**备份实例**的角色是`offline`角色，Offline实例通常专用于OLAP/ETL/个人交互式查询，不适合与在线查询混合，因此只有当集群中所有的`replica`宕机后，`offline`才会被用于承接只读流量。

```yaml
# replica service will route {ip|name}:5434 to replica pgbouncer (5434->6432 ro)
- name: replica           # service name {{ pg_cluster }}-replica
  src_ip: "*"
  src_port: 5434
  dst_port: pgbouncer
  check_url: /read-only   # read-only health check. (including primary)
  selector: "[]"          # select all instance as replica service candidate
  selector_backup: "[? pg_role == `primary` || pg_role == `offline` ]"
```



### Default服务

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



### Offline服务

Offline服务用于离线访问与个人查询。它将集群的**5438**端口，映射为**离线实例Postgres**端口（默认5432）。

Offline服务针对交互式的只读访问，包括：ETL，离线大型分析查询，个人用户查询。交互式的操作**不应当**通过连接池访问，因此Default服务将流量直接转发至离线实例的Postgres，绕过了Pgbouncer。

离线实例指的是 [`pg_role`](v-pgsql.md#pg_role) 为 `offline` 或带有 [`pg_offline_query`](v-pgsql.md#pg_offline_query) 标记的实例。离线实例外的其他**其他从库**将作为Offline的备份实例，这样当Offline实例宕机时，Offline服务仍然可以从其他从库获取服务。

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




---------------

## 自定义服务

在以上由 [`pg_services`](v-pgsql.md#pg_services) 配置的默认服务之外，用户可以使用相同的服务定义，在 [`pg_services_extra`](v-pgsql.md#pg_services_extra) 配置项中为PostgreSQL数据库集群定义额外的服务。

一个集群都可以定义多个服务，每个服务包含任意数量的集群成员，服务通过**端口**进行区分。以下代码定义了一个新的服务`standby`，使用`5435`端口对外提供**同步读取**功能。该服务会从集群中的同步从库（或主库）进行读取，从而确保所有读取都不存在延迟。

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

#### 必选项目

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


### 服务实现

目前Pigsty默认使用基于HAProxy的服务实现，也有基于DPVS 4层负载均衡（L4VIP）的私有实现。两者相互等效，各有优势。详情请参考[接入](#接入)一节。





---------------


## 接入

接入是为了解决**生产环境**中高并发，高可用，高性能的问题。**个人用户**可以选择无视接入机制，绕过域名、VIP、负载均衡器、连接池，直接通过IP地址访问数据库。

> 个人用户可直接用连接串 `postgres://dbuser_dba:DBUser.DBA@10.10.10.10:5432/meta` 访问默认数据库 （注意替换IP地址与密码，沙箱环境可从宿主机访问）

在Pigsty的默认配置中，每一个数据库实例/节点上都一一对应部署有一个功能完整的负载均衡器（HAProxy），因此整个数据库集群中的**任意实例**都可以作为整个集群的服务接入点。Pigsty数据库集群的交付边界止步于接入层负载均衡器（HAProxy）；您需要自行决定接入策略：**如何将业务流量分发至集群中的一台、多台、或全部负载均衡实例**。

Pigsty提供了丰富的接入方式，用户可以根据自己的网络基础设施情况与喜好自行选择。作为样例，Pigsty沙箱中使用了一个绑定在集群主库上的L2 VIP，一个绑定在该VIP上的域名。应用程序通过域名透过L2 VIP访问集群主库上的负载均衡实例。当该节点不可用时，VIP会随集群主库漂移，流量也随之由新主库上的负载均衡器承载，如下图所示：

![](../_media/access.svg)

另一种经典的策略是直接使用DNS轮询的方式，将DNS域名解析至所有实例，本文会给出几种常见的接入模式。


## 用户接口

从用户的角度来看，访问数据库只需要一个连接串；而Pigsty向最终用户交付的接口，也是一个数据库连接串。

不同的**接入方式**在形式上的区别是连接串中[主机](#主机)与[端口](#端口)部分的不同。

### 端口

Pigsty使用不同的**端口**来区分[数据库服务](c-service.md)，提供Postgres等效服务的端口如下：

| 端口 | 服务      | 类型                    | 说明                                 |
| ---- |---------|-----------------------| ------------------------------------ |
| 5432 | postgres | 数据库                   | 直接访问当前节点数据库实例           |
| 6432 | pgbouncer | 连接池                   | 通过连接池访问当前节点数据库         |
| 5433 | primary | [服务](c-service.md#服务) | 负载均衡并通过**连接池**访问集群主库 |
| 5434 | replica | [服务](c-service.md#服务) | 负载均衡并通过**连接池**访问集群主库 |
| 5436 | default | [服务](c-service.md#服务) | 通过负载均衡直达集群主库             |
| 5438 | offline | [服务](c-service.md#服务) | 通过负载均衡直达集群离线访问实例     |

### 主机

| 类型         | 样例                | 说明                                 |
| ------------ | ------------------- | ------------------------------------ |
| 集群域名     | `pg-test`           | 直接访问当前节点数据库实例           |
| 集群VIP      | `10.10.10.3`        | 通过连接池访问当前节点数据库         |
| 特定实例域名 | `pg-test-1`         | 负载均衡并通过**连接池**访问集群主库 |
| 特定实例IP   | `10.10.10.11`       | 负载均衡并通过**连接池**访问集群主库 |
| 所有IP地址   | `10.10,10.11,10.12` | 使用Multihost特性，需要客户端支持    |

根据`host`部分填入的内容，与可用的`port`值，可以排列组合出多种连接串来。


### 可用连接串组合

以单节点沙箱环境为例，以下连接串都可以用于数据库集群`pg-test`上的`test`数据库：

<details><summary>可用连接串排列组合</summary>

```bash
# 通过集群域名接入
postgres://test@pg-test:5432/test               # DNS -> L2 VIP -> 主库直连
postgres://test@pg-test:6432/test               # DNS -> L2 VIP -> 主库连接池 -> 主库
postgres://test@pg-test:5433/test               # DNS -> L2 VIP -> HAProxy -> 主库连接池 -> 主库
postgres://test@pg-test:5434/test               # DNS -> L2 VIP -> HAProxy -> 从库连接池 -> 从库
postgres://dbuser_dba@pg-test:5436/test         # DNS -> L2 VIP -> HAProxy -> 主库直连（管理用）
postgres://dbuser_stats@pg-test:5438/test       # DNS -> L2 VIP -> HAProxy -> 离线库直连（ETL/个人查询用）

# 通过集群VIP直接接入
postgres://test@10.10.10.3:5432/test            # L2 VIP -> 主库直连
postgres://test@10.10.10.3:6432/test            # L2 VIP -> 主库连接池 -> 主库
postgres://test@10.10.10.3:5433/test            # L2 VIP -> HAProxy -> 主库连接池 -> 主库
postgres://test@10.10.10.3:5434/test            # L2 VIP -> HAProxy -> 从库连接池 -> 从库
postgres://dbuser_dba@10.10.10.3:5436/test      # L2 VIP -> HAProxy -> 主库直连（管理用）
postgres://dbuser_stats@10.10.10.3::5438/test   # L2 VIP -> HAProxy -> 离线库直连（ETL/个人查询用）

# 直接指定任意集群实例名
postgres://test@pg-test-1:5432/test             # DNS -> 数据库实例直连 （单实例接入）
postgres://test@pg-test-1:6432/test             # DNS -> 连接池 -> 数据库
postgres://test@pg-test-1:5433/test             # DNS -> HAProxy -> 连接池 -> 数据库读写
postgres://test@pg-test-1:5434/test             # DNS -> HAProxy -> 连接池 -> 数据库只读
postgres://dbuser_dba@pg-test-1:5436/test       # DNS -> HAProxy -> 数据库直连
postgres://dbuser_stats@pg-test-1:5438/test     # DNS -> HAProxy -> 数据库离线读写

# 直接指定任意集群实例IP接入
postgres://test@10.10.10.11:5432/test           # 数据库实例直连 （直接指定实例，无自动流量分发）
postgres://test@10.10.10.11:6432/test           # 连接池 -> 数据库
postgres://test@10.10.10.11:5433/test           # HAProxy -> 连接池 -> 数据库读写
postgres://test@10.10.10.11:5434/test           # HAProxy -> 连接池 -> 数据库只读
postgres://dbuser_dba@10.10.10.11:5436/test     # HAProxy -> 数据库直连
postgres://dbuser_stats@10.10.10.11:5438/test   # HAProxy -> 数据库离线读写

# 直接指定任意集群实例IP接入
postgres://test@10.10.10.11:5432/test           # 数据库实例直连 （直接指定实例，无自动流量分发）
postgres://test@10.10.10.11:6432/test           # 连接池 -> 数据库
postgres://test@10.10.10.11:5433/test           # HAProxy -> 连接池 -> 数据库读写
postgres://test@10.10.10.11:5434/test           # HAProxy -> 连接池 -> 数据库只读
postgres://dbuser_dba@10.10.10.11:5436/test     # HAProxy -> 数据库直连
postgres://dbuser_stats@10.10.10.11:5438/test   # HAProxy -> 数据库离线读写

# 智能客户端自动读写分离（连接池）
postgres://test@10.10.10.11:6432,10.10.10.12:6432,10.10.10.13:6432/test?target_session_attrs=primary
postgres://test@10.10.10.11:6432,10.10.10.12:6432,10.10.10.13:6432/test?target_session_attrs=prefer-standby

# 智能客户端自动读写分离（数据库）
postgres://test@10.10.10.11:5432,10.10.10.12:5432,10.10.10.13:5432/test?target_session_attrs=primary
postgres://test@10.10.10.11:5432,10.10.10.12:5432,10.10.10.13:5432/test?target_session_attrs=prefer-standby

```

</details>

在集群层次，用户可以通过**集群域名**+服务端口的方式访问集群提供的 [**四种默认服务**](c-service#默认服务)，Pigsty强烈建议使用这种方式。当然用户也可以绕开域名，直接使用集群的VIP（L2 or L4）访问数据库集群。

在实例层次，用户可以通过节点IP/域名 + 5432端口直连Postgres数据库，也可以用6432端口经由Pgbouncer访问数据库。还可以通过Haproxy经由5433~543x访问实例所属集群提供的服务。





## 典型接入方案

Pigsty推荐使用基于Haproxy的接入方案（1/2），在生产环境中如果有基础设施支持，也可以使用基于L4VIP（或与之等效的负载均衡服务）的接入方案（3）。

| 序号 | 方案                               | 说明                                                      |
| ---- | ---------------------------------- | --------------------------------------------------------- |
| 1    | [L2VIP + Haproxy](#l2-vip-haproxy) | Pigsty沙箱使用的标准接入架构，使用L2 VIP确保Haproxy高可用 |
| 2    | [DNS + Haproxy](#dns-haproxy)      | 标准高可用接入方案，系统无单点。                          |
| 3    | [L4VIP + Haproxy](#l4-vip-haproxy) | 方案2的变体，使用L4 VIP确保Haprxoy高可用。                |
| 4    | [L4 VIP](#l4-vip)                  | 大规模**高性能生产环境**建议使用DPVS L4 VIP直接接入       |
| 5    | [Consul DNS](#consul-dns)          | 使用Consul DNS进行服务发现，绕开VIP与Haproxy              |
| 6    | [Static DNS](#static-dns)          | 传统静态DNS接入方式                                       |
| 7    | [IP](#ip)                          | 采用智能客户端接入                                        |

![](../_media/access-decision.svg)




### L2 VIP + Haproxy

#### 方案简介

Pigsty沙箱使用的标准接入方案，采用单个域名绑定至单个L2 VIP，VIP指向集群中的HAProxy。

集群中的Haproxy采用Node Port的方式统一对外暴露 [**服务**](c-service/)。每个Haproxy都是幂等的实例，提供完整的负载均衡与服务分发功能。Haproxy部署于每一个数据库节点上，因此整个集群的每一个成员在使用效果上都是幂等的。（例如访问任何一个成员的5433端口都会连接至主库连接池，访问任意成员的5434端口都会连接至某个从库的连接池）

Haproxy本身的可用性**通过幂等副本实现**，每一个Haproxy都可以作为访问入口，用户可以使用一个、两个、多个，所有Haproxy实例，每一个Haproxy提供的功能都是完全相同的。

每个集群都分配有**一个**L2 VIP，固定绑定至集群主库。当主库发生切换时，该L2 VIP也会随之漂移至新的主库上。这是通过`vip-manager`实现的：`vip-manager`会查询Consul获取集群当前主库信息，然后在主库上监听VIP地址。

集群的L2 VIP有与之对应的**域名**。域名固定解析至该L2 VIP，在生命周期中不发生变化。

#### 方案优越性

* 无单点，高可用
* VIP固定绑定至主库，可以灵活访问

#### 方案局限性

* 多一跳
* Client IP地址丢失，部分HBA策略无法正常生效
* 所有候选主库必须**位于同一二层网络**。
  * 作为备选，用户也可以通过使用L4 VIP绕开此限制，但相比L2 VIP会额外多一跳。
  * 作为备选，用户也可以选择不用L2 VIP，而用DNS直接指向HAProxy，但可能会受到客户端DNS缓存的影响。
  
#### 方案示意

![](../_media/access.svg)



### DNS + Haproxy

#### 方案简介

标准高可用接入方案，系统无单点。灵活性，适用性，性能达到一个较好的平衡。

集群中的Haproxy采用Node Port的方式统一对外暴露 [**服务**](c-service/)。每个Haproxy都是幂等的实例，提供完整的负载均衡与服务分发功能。Haproxy部署于每一个数据库节点上，因此整个集群的每一个成员在使用效果上都是幂等的。（例如访问任何一个成员的5433端口都会连接至主库连接池，访问任意成员的5434端口都会连接至某个从库的连接池）

Haproxy本身的可用性**通过幂等副本实现**，每一个Haproxy都可以作为访问入口，用户可以使用一个、两个、多个，所有Haproxy实例，每一个Haproxy提供的功能都是完全相同的。

**用户需要自行确保应用能够访问到任意一个健康的Haproxy实例**。作为最朴素的一种实现，用户可以将数据库集群的DNS域名解析至若干Haproxy实例，并启用DNS轮询响应。而客户端可以选择完全不缓存DNS，或者使用长连接并实现建立连接失败后重试的机制。又或者参考方案2，在架构侧通过额外的L2/L4 VIP确保Haproxy本身的高可用。

#### 方案优越性

* 无单点，高可用
* VIP固定绑定至主库，可以灵活访问

#### 方案局限性

* 多一跳
* Client IP地址丢失，部分HBA策略无法正常生效
* **Haproxy本身的高可用通过幂等副本，DNS轮询与客户端重连实现**

  DNS应有轮询机制，客户端应当使用长连接，并有建连失败重试机制。以便单Haproxy故障时可以自动漂移至集群中的其他Haproxy实例。如果无法做到这一点，可以考虑使用**接入方案2**，使用L2/L4 VIP确保Haproxy高可用。

#### 方案示意

![](../_media/access-dns-ha.svg)





### L4 VIP + Haproxy

<details><summary>四层负载均衡 + HAProxy接入</summary>

#### 方案简介

接入方案1/2的另一种变体，通过L4 VIP确保Haproxy的高可用

#### 方案优越性

* 无单点，高可用
* 可以同时使用**所有**的Haproxy实例，均匀承载流量。
* 所有候选主库**不需要**位于同一二层网络。
* 可以操作单一VIP完成流量切换（如果同时使用了多个Haproxy，不需要逐个调整）

#### 方案局限性

* 多两跳，较为浪费，如果有条件可以直接使用方案4: L4 VIP直接接入。
* Client IP地址丢失，部分HBA策略无法正常生效

</details>



### L4 VIP

<details><summary>四层负载均衡接入</summary>

#### 方案简介

大规模**高性能生产环境**建议使用 L4 VIP接入（FullNAT，DPVS）

#### 方案优越性

* 性能好，吞吐量大
* 可以通过`toa`模块获取正确的客户端IP地址，HBA可以完整生效。

#### 方案局限性

* 仍然多一条。
* 需要依赖外部基础设施，部署复杂。
* 未启用`toa`内核模块时，仍然会丢失客户端IP地址。
* 没有Haproxy屏蔽主从差异，集群中的每个节点不再“**幂等**”。

</details>



### Consul DNS

<details><summary>Consul DNS接入</summary>

#### 方案简介

L2 VIP并非总是可用，特别是所有候选主库必须**位于同一二层网络**的要求可能不一定能满足。

在这种情况下，可以使用DNS解析代替L2 VIP，进行

#### 方案优越性

* 少一跳

#### 方案局限性

* 依赖Consul DNS
* 用户需要合理配置DNS缓存策略

</details>



### Static DNS

<details><summary>静态DNS接入</summary>

#### 方案简介

传统静态DNS接入方式

#### 方案优越性

* 少一跳
* 实施简单

#### 方案局限性

* 没有灵活性
* 主从切换时容易导致流量损失

</details>



### IP

<details><summary>IP直连接入</summary>

#### 方案简介

采用智能客户端直连数据库IP接入

#### 方案优越性

* 直连数据库/连接池，少一条
* 不依赖额外组件进行主从区分，降低系统复杂性。

#### 方案局限性

* 灵活性太差，集群扩缩容繁琐。

</details>