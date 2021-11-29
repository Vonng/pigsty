# Service Access

## Overview

|                            Name                             |    Type    | Level  | Description |
| :----------------------------------------------------------: | :--------: | :---: | ---- |
|              [pg_weight](v-service.md#pg_weight)              |  `number`  |  **I**  | relative weight in load balancer |
|            [pg_services](v-service.md#pg_services)            |  `service[]`  |  G  | global [service definition](c-service) |
|      [pg_services_extra](v-service.md#pg_services_extra)      |  `service[]`  |  C  | ad hoc [service definition](c-service.md) |
|        [haproxy_enabled](v-service.md#haproxy_enabled)        |  `bool`  |  G/C/I  | haproxy enabled ? |
|         [haproxy_reload](v-service.md#haproxy_reload)         |  `bool`  |  A  | haproxy reload instead of reset |
| [haproxy_admin_auth_enabled](v-service.md#haproxy_admin_auth_enabled) |  `bool`  |  G/C  | enable auth for haproxy admin ? |
| [haproxy_admin_username](v-service.md#haproxy_admin_username) |  `string`  |  G/C  | haproxy admin user name |
| [haproxy_admin_password](v-service.md#haproxy_admin_password) |  `string`  |  G/C  | haproxy admin password |
|  [haproxy_exporter_port](v-service.md#haproxy_exporter_port)  |  `number`  |  G/C  | haproxy exporter listen port |
| [haproxy_client_timeout](v-service.md#haproxy_client_timeout) |  `interval`  |  G/C  | haproxy client timeout |
| [haproxy_server_timeout](v-service.md#haproxy_server_timeout) |  `interval`  |  G/C  | haproxy server timeout |
|               [vip_mode](v-service.md#vip_mode)               |  `enum`  |  G/C  | vip working mode |
|             [vip_reload](v-service.md#vip_reload)             |  `bool`  |  G/C  | reload vip configuration |
|            [vip_address](v-service.md#vip_address)            |  `string`  |  G/C  | vip address used by cluster |
|           [vip_cidrmask](v-service.md#vip_cidrmask)           |  `number`  |  G/C  | vip network CIDR |
|          [vip_interface](v-service.md#vip_interface)          |  `string`  |  G/C  | vip network interface name |
|           [dns_mode](v-service.md#dns_mode)              |  `enum`  |  G/C  | cluster DNS mode |
|          [dns_selector](v-service.md#dns_selector)          |  `string`  |  G/C  | cluster DNS ins selector |


## Defaults

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





## Details


### pg_weight

The relative weight of the database instance when performing load balancing. Default is 100



### pg_services

An array of service definition objects that define the services exposed to the public in each database cluster.

Each cluster can define multiple services, each containing any number of cluster members, and the services are distinguished by **port**.

The structure of each service definition is shown in the following example.

```yaml
- name: default # service's actual name is {{ pg_cluster }}-{{ service.name }}
  src_ip: "*" # service bind ip address, * for all, vip for cluster virtual ip address
  src_port: 5436 # bind port, mandatory
  dst_port: postgres # target port: postgres|pgbouncer|port_number , pgbouncer(6432) by default
  check_method: http # health check method: only http is available for now
  check_port: patroni # health check port: patroni|pg_exporter|port_number , patroni by default
  check_url: /primary # health check url path, / as default
  check_code: 200 # health check http code, 200 as default
  selector: "[]" # instance selector
  haproxy: # haproxy specific fields
    maxconn: 3000 # default front-end connection
    balance: roundrobin # load balance algorithm (roundrobin by default)
    default_server_options: 'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'

```

#### **must-have-item**

* **name (`service.name`) **.

  **Service name**, the full name of the service is prefixed by the database cluster name and suffixed by `service.name`, connected by `-`. For example, a service with `name=primary` in the `pg-test` cluster has the full service name `pg-test-primary`.

* **Port (`service.port`)**.

  In Pigsty, services are exposed to the public by default in the form of NodePort, so exposing the port is mandatory. However, if you use an external load balancing service access scheme, you can also distinguish the services in other ways.

* **selector (`service.selector`)**.

  The **selector** specifies the instance members of the service, in the form of a JMESPath that filters variables from all cluster instance members. The default `[]` selector will pick all cluster members.



#### Optional items

* **Backup selector (`service.selector`) **.

  Optional **backup selector** `service.selector_backup` will select or mark the list of instances used for service backup, i.e. the backup instance takes over the service only when all other members of the cluster fail. For example, the `primary` instance can be added to the alternative set of `replica` services, so that the master can still carry the read-only traffic of the cluster when all the slaves fail.

* **Source IP (`service.src_ip`)**: **service.src_ip

  Indicates the IP address used externally by the **service**. The default is `*`, which is all IP addresses on the local machine. Using `vip` will use the `vip_address` variable to take the value, or you can also fill in the specific IP address supported by the NIC.

* **Host port (`service.dst_port`)**.

  Which port on the target instance will the service's traffic be directed to? `postgres` will point to the port the database is listening on, `pgbouncer` will point to the port the connection pool is listening on, or you can fill in a fixed port number.

* **health check method (`service.check_method`)**:

  How does the service check the health status of the instance? Currently only HTTP is supported

* **health_check_port (`service.check_port`)**:

  Which port of the service check instance to get the health status of the instance? `patroni` will get it from Patroni (default 8008), `pg_exporter` will get it from PG Exporter (default 9630), or user can fill in a custom port number.

* **Health check path (`service.check_url`)**:

  The URL PATH used by the service to perform HTTP checks. `/` is used by default for health checks, and PG Exporter and Patroni provide a variety of health check methods that can be used to differentiate between master and slave traffic. For example, `/primary` will only return success for the master, and `/replica` will only return success for the slave. `/read-only`, on the other hand, will return success for any instance that supports read-only (including the master).

* **health check code (`service.check_code`)**:

  Code expected for HTTP health checks, defaults to 200

* **Haproxy-specific configuration (`service.haproxy`)** :

  Proprietary configuration items about the service provisioning software (HAproxy)



### pg_services_extra

An array of service definition objects, defined at the cluster level, appended to the global service definition.

This configuration item can be used if the user wishes to create special services for a particular database cluster, for example, separately for a set of clusters with deferred slave libraries.



### haproxy_enabled

Enable or disable the Haproxy component

Pigsty deploys Haproxy on all database nodes by default, you can enable Haproxy load balancer only on specific instances/nodes by overriding the instance level variables.



### haproxy_admin_auth_enabled

Whether to enable basic authentication for the Haproxy admin interface

Not enabled by default. It is recommended to enable it in production environments or add access control to Nginx or other access layers.



### haproxy_admin_username

Enables the default username for Haproxy management interface authentication, which is `admin` by default



### haproxy_admin_password

Enable the default password for Haproxy management interface authentication, the default is `admin



### haproxy_client_timeout

Haproxy client connection timeout, default is 3 hours



### haproxy_server_timeout

Haproxy server connection timeout, default is 3 hours



### haproxy_exporter_port

The port on which the Haproxy management interface and monitoring metrics expose endpoints to listen.

The default port is 9101



### vip_mode

Mode of VIP, enumerated type, optional values include.

* none: no VIP setting
* l2 : Configure a Layer 2 VIP bound to the master (requires all members to be in the same Layer 2 network broadcast domain)
* l4 : traffic distribution via external L4 load balancer. (not included in Pigsty's current implementation)

VIPs are used to ensure high availability of **read and write services** with **load balancers**. When using L2 VIPs, Pigsty's VIPs are hosted by `vip-manager` and will be bound to the **cluster master library**.

This means that you can always access the cluster master through the VIP, or access the load balancer on the master through the VIP (this may be a performance strain if the master is under a lot of pressure).

Note that you must ensure that the VIP candidate instances are under the same Layer 2 network (VLAN, switch).



### vip_reload

Does it reload the VIP configuration when performing a task? Default reload


### vip_address

VIP address, can be used for L2 or L4 VIPs.

There is no default value for `vip_address`, users must explicitly specify and assign VIP addresses for each cluster



### vip_cidrmask

CIDR network length for VIPs, required only when using L2 VIPs.

There is no default value for `vip_cidrmask` and the user must explicitly specify and assign the VIP's network CIDR for each cluster.



### vip_interface

VIP NIC name, required only when using L2 VIP.

The default is `eth0` and the user must specify the NIC name used by the VIP for each cluster/instance.


### dns_mode

Mode used to control the registration of DNS domain names

Reserved parameter, not actually used at this time.


### dns_selector

Used to select the list of instances to which DNS domain names resolve

Reserved parameter, not actually used at this time.



## HAProxy to have configuration items

These parameters are now defined in the service, use `haproxy` to override the default parameters.


### maxconn

Maximum number of front and back end connections to HAProxy, default is 3000


### balance

The algorithm used for haproxy load balancing, with optional policies `roundrobin` and `leastconn`.

default is `roundrobin`



### default_server_options

Default options for Haproxy backend server instances

The default is: `'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'`
