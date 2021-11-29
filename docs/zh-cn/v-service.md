# 服务接入参数

## 参数概览

|                           名称                            |    类型     | 层级  | 说明                          |
| :-------------------------------------------------------: | :---------: | :---: | ----------------------------- |
|                  [pg_weight](#pg_weight)                  |  `number`   | **I** | 实例在负载均衡中的相对权重    |
|                [pg_services](#pg_services)                | `service[]` |   G   | 全局通用服务定义              |
|          [pg_services_extra](#pg_services_extra)          | `service[]` |   C   | 集群专有服务定义              |
|            [haproxy_enabled](#haproxy_enabled)            |   `bool`    | G/C/I | 是否启用Haproxy               |
|             [haproxy_reload](#haproxy_reload)             |   `bool`    |   A   | 是否重载Haproxy配置           |
| [haproxy_admin_auth_enabled](#haproxy_admin_auth_enabled) |   `bool`    |  G/C  | 是否对Haproxy管理界面启用认证 |
|     [haproxy_admin_username](#haproxy_admin_username)     |  `string`   |  G/C  | HAproxy管理员名称             |
|     [haproxy_admin_password](#haproxy_admin_password)     |  `string`   |  G/C  | HAproxy管理员密码             |
|      [haproxy_exporter_port](#haproxy_exporter_port)      |  `number`   |  G/C  | HAproxy指标暴露器端口         |
|     [haproxy_client_timeout](#haproxy_client_timeout)     | `interval`  |  G/C  | HAproxy客户端超时             |
|     [haproxy_server_timeout](#haproxy_server_timeout)     | `interval`  |  G/C  | HAproxy服务端超时             |
|                   [vip_mode](#vip_mode)                   |   `enum`    |  G/C  | VIP模式：`none`               |
|                 [vip_reload](#vip_reload)                 |   `bool`    |  G/C  | 是否重载VIP配置               |
|                [vip_address](#vip_address)                |  `string`   |  G/C  | 集群使用的VIP地址             |
|               [vip_cidrmask](#vip_cidrmask)               |  `number`   |  G/C  | VIP地址的网络CIDR掩码         |
|              [vip_interface](#vip_interface)              |  `string`   |  G/C  | VIP使用的网卡                 |
|        [dns_mode](#dns_mode)                 |  `enum`  |  G/C  | DNS配置模式 |
|       [dns_selector](#dns_selector)          |  `string`  |  G/C  | DNS解析对象选择器 |

## 默认参数

```yaml
#------------------------------------------------------------------------------
# SERVICE PROVISION
#------------------------------------------------------------------------------
pg_weight: 100              # default load balance weight (instance level)

# - service - #
pg_services:               # how to expose postgres service in cluster?
  # primary service will route {ip|name}:5433 to primary pgbouncer (5433->6432 rw)
  - name: primary           # service name {{ pg_cluster }}-primary
    src_ip: "*"
    src_port: 5433
    dst_port: pgbouncer     # 5433 route to pgbouncer
    check_url: /primary     # primary health check, success when instance is primary
    selector: "[]"          # select all instance as primary service candidate

  # replica service will route {ip|name}:5434 to replica pgbouncer (5434->6432 ro)
  - name: replica           # service name {{ pg_cluster }}-replica
    src_ip: "*"
    src_port: 5434
    dst_port: pgbouncer
    check_url: /read-only   # read-only health check. (including primary)
    selector: "[]"          # select all instance as replica service candidate
    selector_backup: "[? pg_role == `primary`]"   # primary are used as backup server in replica service

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

  # offline service will route {ip|name}:5438 to offline postgres (5438->5432 offline)
  - name: offline           # service name {{ pg_cluster }}-offline
    src_ip: "*"
    src_port: 5438
    dst_port: postgres
    check_url: /replica     # offline MUST be a replica
    selector: "[? pg_role == `offline` || pg_offline_query ]"         # instances with pg_role == 'offline' or instance marked with 'pg_offline_query == true'
    selector_backup: "[? pg_role == `replica` && !pg_offline_query]"  # replica are used as backup server in offline service

pg_services_extra: []        # extra services to be added

# - haproxy - #
haproxy_enabled: true                         # enable haproxy among every cluster members
haproxy_reload: true                          # reload haproxy after config
haproxy_admin_auth_enabled: false             # enable authentication for haproxy admin?
haproxy_admin_username: admin                 # default haproxy admin username
haproxy_admin_password: pigsty                # default haproxy admin password
haproxy_exporter_port: 9101                   # default admin/exporter port
haproxy_client_timeout: 12h                   # client side connection timeout
haproxy_server_timeout: 12h                   # server side connection timeout

# - vip - #
vip_mode: none                                # none | l2 | l4
vip_reload: true                              # whether reload service after config
# vip_address: 127.0.0.1                      # virtual ip address ip (l2 or l4)
# vip_cidrmask: 24                            # virtual ip address cidr mask (l2 only)
# vip_interface: eth0                         # virtual ip network interface (l2 only)

# - dns - #                                   # NOT IMPLEMENTED
# dns_mode: vip                               # vip|all|selector: how to resolve cluster DNS?
# dns_selector: '[]'                          # if dns_mode == vip, filter instances been resolved
```





## 参数详解



### pg_weight

当执行负载均衡时，数据库实例的相对权重。默认为100



### pg_services

由服务定义对象构成的数组，定义了每一个数据库集群中对外暴露的服务。

每一个集群都可以定义多个服务，每个服务包含任意数量的集群成员，服务通过**端口**进行区分。

每一个服务的定义结构如下例所示：

```yaml
- name: default           # service's actual name is {{ pg_cluster }}-{{ service.name }}
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

#### **必选项目**

* **名称（`service.name`）**：

  **服务名称**，服务的完整名称以数据库集群名为前缀，以`service.name`为后缀，通过`-`连接。例如在`pg-test`集群中`name=primary`的服务，其完整服务名称为`pg-test-primary`。

* **端口（`service.port`）**：

  在Pigsty中，服务默认采用NodePort的形式对外暴露，因此暴露端口为必选项。但如果使用外部负载均衡服务接入方案，您也可以通过其他的方式区分服务。

* **选择器（`service.selector`）**：

  **选择器**指定了服务的实例成员，采用JMESPath的形式，从所有集群实例成员中筛选变量。默认的`[]`选择器会选取所有的集群成员。

  

#### 可选项目

* **备份选择器（`service.selector`）**：

  可选的 **备份选择器**`service.selector_backup`会选择或标记用于服务备份的实例列表，即集群中所有其他成员失效时，备份实例才接管服务。例如可以将`primary`实例加入`replica`服务的备选集中，当所有从库失效后主库依然可以承载集群的只读流量。

* **源端IP（`service.src_ip`）** ：

  表示**服务**对外使用的IP地址，默认为`*`，即本机所有IP地址。使用`vip`则会使用`vip_address`变量取值，或者也可以填入网卡支持的特定IP地址。

* **宿端口（`service.dst_port`）**：

  服务的流量将指向目标实例上的哪个端口？`postgres` 会指向数据库监听的端口，`pgbouncer`会指向连接池所监听的端口，也可以填入固定的端口号。

* **健康检查方式（`service.check_method`）**:

  服务如何检查实例的健康状态？目前仅支持HTTP

* **健康检查端口（`service.check_port`）**:

  服务检查实例的哪个端口获取实例的健康状态？ `patroni`会从Patroni（默认8008）获取，`pg_exporter`会从PG Exporter（默认9630）获取，用户也可以填入自定义的端口号。

* **健康检查路径（`service.check_url`）**:

  服务执行HTTP检查时，使用的URL PATH。默认会使用`/`作为健康检查，PG Exporter与Patroni提供了多样的健康检查方式，可以用于主从流量区分。例如，`/primary`仅会对主库返回成功，`/replica`仅会对从库返回成功。`/read-only`则会对任何支持只读的实例（包括主库）返回成功。

* **健康检查代码（`service.check_code`）**:

  HTTP健康检查所期待的代码，默认为200

* **Haproxy特定配置（`service.haproxy`）** ：

  关于服务供应软件（HAproxy）的专有配置项



### pg_services_extra

由服务定义对象构成的数组，在集群层面定义，追加至全局的服务定义中。

如果用户希望为某一个数据库集群创建特殊的服务，例如单独为某一套带有延迟从库的集群创建特殊的服务，则可以使用本配置项。



### haproxy_enabled

是否启用Haproxy组件

Pigsty默认会在所有数据库节点上部署Haproxy，您可以通过覆盖实例级变量，仅在特定实例/节点上启用Haproxy负载均衡器。



### haproxy_admin_auth_enabled

是否启用为Haproxy管理界面启用基本认证

默认不启用，建议在生产环境启用，或在Nginx或其他接入层添加访问控制。



### haproxy_admin_username

启用Haproxy管理界面认证默认用户名，默认为`admin`



### haproxy_admin_password

启用Haproxy管理界面认证默认密码，默认为`admin`



### haproxy_client_timeout

Haproxy客户端连接超时，默认为3小时



### haproxy_server_timeout

Haproxy服务端连接超时，默认为3小时



### haproxy_exporter_port

Haproxy管理界面与监控指标暴露端点所监听的端口。

默认端口为9101



### vip_mode

VIP的模式，枚举类型，可选值包括：

* none：不设置VIP
* l2：配置绑定在主库上的二层VIP（需要所有成员位于同一个二层网络广播域中）
* l4 ：通过外部L4负载均衡器进行流量分发。（未纳入Pigsty当前实现中）

VIP用于确保**读写服务**与**负载均衡器**的高可用，当使用L2 VIP时，Pigsty的VIP由`vip-manager`托管，会绑定在**集群主库**上。

这意味着您始终可以通过VIP访问集群主库，或者通过VIP访问主库上的负载均衡器（如果主库的压力很大，这样做可能会有性能压力）。

注意，您必须保证VIP候选实例处于同一个二层网络（VLAN、交换机）下。



### vip_reload

是否在执行任务时重载VIP配置？默认重载


### vip_address

VIP地址，可用于L2或L4 VIP。

`vip_address`没有默认值，用户必须为每一个集群显式指定并分配VIP地址



### vip_cidrmask

VIP的CIDR网络长度，仅当使用L2 VIP时需要。

`vip_cidrmask`没有默认值，用户必须为每一个集群显式指定VIP的网络CIDR。



### vip_interface

VIP网卡名称，仅当使用L2 VIP时需要。

默认为`eth0`，用户必须为每一个集群/实例指明VIP使用的网卡名称。


### dns_mode

用于控制注册DNS域名的模式

保留参数，目前未实际使用。


### dns_selector

用于选择DNS域名解析到的实例列表

保留参数，目前未实际使用。



## HAProxy转有配置项

这些参数现在服务中定义，使用`haproxy`来覆盖默认参数。


### maxconn

HAProxy最大前后端连接数，默认为3000


### balance

haproxy负载均衡所使用的算法，可选策略为`roundrobin`与`leastconn`

默认为`roundrobin`



### default_server_options

Haproxy 后端服务器实例的默认选项

默认为： `'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'`
