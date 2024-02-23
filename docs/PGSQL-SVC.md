# PGSQL Service

> Split read & write, route traffic to the right place, and achieve stable & reliable access to the PostgreSQL cluster.

Service is an abstraction to seal the details of the underlying cluster, especially during cluster failover/switchover. 


---------------

## Personal User

Service is meaningless to personal users. You can access the database with raw IP address or whatever method you like.

```bash
psql postgres://dbuser_dba:DBUser.DBA@10.10.10.10/meta     # dbsu direct connect
psql postgres://dbuser_meta:DBUser.Meta@10.10.10.10/meta   # default business admin user
psql postgres://dbuser_view:DBUser.View@pg-meta/meta       # default read-only user
```

---------------

## Service Overview

We utilize a PostgreSQL database **cluster** based on replication in real-world production environments. Within the cluster, only one instance is the leader (primary) that can accept writes. Other instances (replicas) continuously fetch WAL from the leader to stay synchronized. Additionally, replicas can handle read-only queries and offload the primary in read-heavy, write-light scenarios. Thus, distinguishing between write and read-only requests is a common practice.

Moreover, we pool requests through a connection pooling middleware (Pgbouncer) for high-frequency, short-lived connections to reduce the overhead of connection and backend process creation. And, for scenarios like ETL and change execution, we need to bypass the connection pool and directly access the database servers.
Furthermore, high-availability clusters may undergo failover during failures, causing a change in the cluster leadership. Therefore, the RW requests should be re-routed automatically to the new leader.

These varied requirements (read-write separation, pooling vs. direct connection, and client request failover) have led to the abstraction of the **service** concept.

Typically, a database cluster must provide this basic service:

- **Read-write service (primary)**: Can read and write to the database.

For production database clusters, at least these two services should be provided:

- **Read-write service (primary)**: Write data: Only carried by the primary.
- **Read-only service (replica)**: Read data: Can be carried by replicas, but fallback to the primary if no replicas are available.

Additionally, there might be other services, such as:

- **Direct access service (default)**: Allows (admin) users to bypass the connection pool and directly access the database.
- **Offline replica service (offline)**: A dedicated replica that doesn't handle online read traffic, used for ETL and analytical queries.
- **Synchronous replica service (standby)**: A read-only service with no replication delay, handled by [synchronous standby](PGSQL-CONF#synchronous-standby)/primary for read queries.
- **Delayed replica service (delayed)**: Accesses older data from the same cluster from a certain time ago, handled by [delayed replicas](PGSQL-CONF#delayed-cluster).


---------------

## Default Service

Pigsty will enable four default services for each PostgreSQL cluster:

| service | port | description                                           |
|---------|------|-------------------------------------------------------|
| [primary](#primary-service) | 5433 | pgbouncer read/write, connect to primary 5432 or 6432 |
| [replica](#replica-service) | 5434 | pgbouncer read-only, connect to replicas 5432/6432    |
| [default](#default-service) | 5436 | admin or direct access to primary                     |
| [offline](#offline-service) | 5438 | OLAP, ETL, personal user, interactive queries         |

Take the default `pg-meta` cluster as an example, you can access these services in the following ways:

```bash
psql postgres://dbuser_meta:DBUser.Meta@pg-meta:5433/meta   # pg-meta-primary : production read/write via primary pgbouncer(6432)
psql postgres://dbuser_meta:DBUser.Meta@pg-meta:5434/meta   # pg-meta-replica : production read-only via replica pgbouncer(6432)
psql postgres://dbuser_dba:DBUser.DBA@pg-meta:5436/meta     # pg-meta-default : Direct connect primary via primary postgres(5432)
psql postgres://dbuser_stats:DBUser.Stats@pg-meta:5438/meta # pg-meta-offline : Direct connect offline via offline postgres(5432)
```

[![pgsql-ha.jpg](https://repo.pigsty.cc/img/pgsql-ha.jpg)](PGSQL-ARCH#high-availability)

Here the `pg-meta` domain name point to the cluster's L2 VIP, which in turn points to the haproxy load balancer on the primary instance. It is responsible for routing traffic to different instances, check [Access Services](#access-services) for details.



---------------

## Service Implementation

In Pigsty, services are implemented using [haproxy](PARAM#haproxy) on [nodes](NODE), differentiated by different ports on the host node.

Every node has Haproxy enabled to expose services. From the database perspective, nodes in the cluster may be primary or replicas, but from the service perspective, all nodes are the same. This means even if you access a replica node, as long as you use the correct service port, you can still use the primary's read-write service. This design seals the complexity: as long as you can access any instance on the PostgreSQL cluster, you can fully access all services.

This design is akin to the NodePort service in Kubernetes. Similarly, in Pigsty, every service includes these two core elements:

1. Access endpoints exposed via NodePort (port number, from where to access?)
2. Target instances chosen through Selectors (list of instances, who will handle it?)

The boundary of Pigsty's service delivery stops at the cluster's HAProxy. Users can access these load balancers in various ways. Please refer to [Access Service](#access-service).

All services are declared through configuration files. For instance, the default PostgreSQL service is defined by the [`pg_default_services`](PARAM#pg_default_services) parameter:

```yaml
- { name: primary ,port: 5433 ,dest: default  ,check: /primary   ,selector: "[]" }
- { name: replica ,port: 5434 ,dest: default  ,check: /read-only ,selector: "[]" , backup: "[? pg_role == `primary` || pg_role == `offline` ]" }
- { name: default ,port: 5436 ,dest: postgres ,check: /primary   ,selector: "[]" }
- { name: offline ,port: 5438 ,dest: postgres ,check: /replica   ,selector: "[? pg_role == `offline` || pg_offline_query ]" , backup: "[? pg_role == `replica` && !pg_offline_query]"}
```

You can also define new service in [`pg_services`](PARAM#pg_services). And `pg_default_services` 与 `pg_services` are both array of [Service Definition](#define-service).


---------------

## Define Service

The default services are defined in [`pg_default_services`](PARAM#pg_default_services).

While you can define your extra PostgreSQL services with [`pg_services`](PARAM#pg_services) @ the global or cluster level.

These two parameters are both arrays of service objects. Each service definition will be rendered as a haproxy config in `/etc/haproxy/<svcname>.cfg`, check [`service.j2`](https://github.com/Vonng/pigsty/blob/master/roles/pgsql/templates/service.j2) for details.

Here is an example of an extra service definition: `standby`

```yaml
- name: standby                   # required, service name, the actual svc name will be prefixed with `pg_cluster`, e.g: pg-meta-standby
  port: 5435                      # required, service exposed port (work as kubernetes service node port mode)
  ip: "*"                         # optional, service bind ip address, `*` for all ip by default
  selector: "[]"                  # required, service member selector, use JMESPath to filter inventory
  dest: default                   # optional, destination port, default|postgres|pgbouncer|<port_number>, 'default' by default
  check: /sync                    # optional, health check url path, / by default
  backup: "[? pg_role == `primary`]"  # backup server selector
  maxconn: 3000                   # optional, max allowed front-end connection
  balance: roundrobin             # optional, haproxy load balance algorithm (roundrobin by default, other: leastconn)
  options: 'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'
```

And it will be translated to a haproxy config file `/etc/haproxy/pg-test-standby.conf`:

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
    http-check send meth OPTIONS uri /sync  # <--- true for primary & sync standby
    http-check expect status 200
    default-server inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100
    # servers
    server pg-test-1 10.10.10.11:6432 check port 8008 weight 100 backup   # the primary is used as backup server
    server pg-test-3 10.10.10.13:6432 check port 8008 weight 100
    server pg-test-2 10.10.10.12:6432 check port 8008 weight 100
```



---------------

## Primary Service

The primary service may be the most critical service for production usage.

It will route traffic to the primary instance, depending on [`pg_default_service_dest`](PARAM#pg_default_service_dest):

* `pgbouncer`: route traffic to primary pgbouncer port (6432), which is the default behavior
* `postgres`: route traffic to primary postgres port (5432) directly if you don't want to use pgbouncer

```yaml
- { name: primary ,port: 5433 ,dest: default  ,check: /primary   ,selector: "[]" }
```

It means all cluster members will be included in the primary service (`selector: "[]"`), but the one and only one instance that past health check (`check: /primary`) will be used as the primary instance.
Patroni will guarantee that only one instance is primary at any time, so the primary service will always route traffic to THE primary instance.

<details><summary>Example: pg-test-primary haproxy config</summary>

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

## Replica Service

The replica service is used for production read-only traffic. 

There may be many more read-only queries than read-write queries in real-world scenarios. You may have many replicas.

The replica service will route traffic to Pgbouncer or postgres depending on [`pg_default_service_dest`](PARAM#pg_default_service_dest), just like the [primary service](#primary-service).

```yaml
- { name: replica ,port: 5434 ,dest: default  ,check: /read-only ,selector: "[]" , backup: "[? pg_role == `primary` || pg_role == `offline` ]" }
```

The `replica` service traffic will try to use common pg instances with [`pg_role`](PARAM#pg_role) = `replica` to alleviate the load on the `primary` instance as much as possible. It will try NOT to use instances with [`pg_role`](PARAM#pg_role) = `offline` to avoid mixing OLAP & OLTP queries as much as possible.

All cluster members will be included in the replica service (`selector: "[]"`) when it passes the read-only health check (`check: /read-only`). 
 `primary` and `offline` instances are used as backup servers, which will take over in case of all `replica` instances are down.


<details><summary>Example: pg-test-replica haproxy config</summary>

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

### Default Service

The default service will route to primary postgres (5432) by default.  

It is quite like the primary service, except it will always bypass pgbouncer, regardless of [`pg_default_service_dest`](PARAM#pg_default_service_dest).
Which is useful for administration connection, ETL writes, CDC changing data capture, etc... 

```yaml
- { name: primary ,port: 5433 ,dest: default  ,check: /primary   ,selector: "[]" }
```


<details><summary>Example: pg-test-default haproxy config</summary>

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

### Offline Service


The Offline service will route traffic to dedicate postgres instance directly.

Which could be a [`pg_role`](PARAM#pg_role) = `offline` instance, or a [`pg_offline_query`](PARAM#pg_offline_query) flagged instance.

If no such instance is found, it will fall back to any replica instances. the bottom line is: it will never route traffic to the primary instance.

```yaml
- { name: offline ,port: 5438 ,dest: postgres ,check: /replica   ,selector: "[? pg_role == `offline` || pg_offline_query ]" , backup: "[? pg_role == `replica` && !pg_offline_query]"}
```

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







---------------

## Reload Service

When cluster membership has changed, such as append / remove replicas, switchover/failover, or adjust relative weight,
You have to [reload service](PGSQL-ADMIN#reload-service) to make the changes take effect.

```bash
bin/pgsql-svc <cls> [ip...]         # reload service for lb cluster or lb instance
# ./pgsql.yml -t pg_service         # the actual ansible task to reload service
```



---------------

## Access Service

Pigsty expose [service](#service) with haproxy. Which is enabled on all nodes by default.

haproxy load balancers are idempotent among same pg cluster by default, you use **ANY** / **ALL** of them by all means.

The typical method is access via cluster domain name, which resolve to cluster L2 VIP, or all instances ip address in a round-robin manner.

Service can be implemented in different ways, You can even implement you own access method such as L4 LVS, F5, etc... instead of haproxy.

![pgsql-access.jpg](https://repo.pigsty.cc/img/pgsql-access.jpg)

You can use different combination of host & port, they are provide PostgreSQL service in different ways.

**Host**

| type                | sample        | description                                                          |
|---------------------|---------------|----------------------------------------------------------------------|
| Cluster Domain Name | `pg-test`     | via cluster domain name (resolved by dnsmasq @ infra nodes)          |
| Cluster VIP Address | `10.10.10.3`  | via a L2 VIP address managed by `vip-manager`, bind to primary       |
| Instance Hostname   | `pg-test-1`   | Access via any instance hostname (resolved by dnsmasq @ infra nodes) |
| Instance IP Address | `10.10.10.11` | Access any instance ip address                                       |


**Port**

Pigsty uses different **ports** to distinguish between [pg services](#service)

| port | service   | type       | description                                           |
|------|-----------|------------|-------------------------------------------------------|
| 5432 | postgres  | database   | Direct access to postgres server                      |
| 6432 | pgbouncer | middleware | Go through connection pool middleware before postgres |
| 5433 | primary   | service    | Access primary pgbouncer (or postgres)                |
| 5434 | replica   | service    | Access replica pgbouncer (or postgres)                |
| 5436 | default   | service    | Access primary postgres                               |
| 5438 | offline   | service    | Access offline postgres                               |

**Combinations**

```bash
# Access via cluster domain
postgres://test@pg-test:5432/test # DNS -> L2 VIP -> primary direct connection
postgres://test@pg-test:6432/test # DNS -> L2 VIP -> primary connection pool -> primary
postgres://test@pg-test:5433/test # DNS -> L2 VIP -> HAProxy -> Primary Connection Pool -> Primary
postgres://test@pg-test:5434/test # DNS -> L2 VIP -> HAProxy -> Replica Connection Pool -> Replica
postgres://dbuser_dba@pg-test:5436/test # DNS -> L2 VIP -> HAProxy -> Primary direct connection (for Admin)
postgres://dbuser_stats@pg-test:5438/test # DNS -> L2 VIP -> HAProxy -> offline direct connection (for ETL/personal queries)

# Direct access via cluster VIP
postgres://test@10.10.10.3:5432/test # L2 VIP -> Primary direct access
postgres://test@10.10.10.3:6432/test # L2 VIP -> Primary Connection Pool -> Primary
postgres://test@10.10.10.3:5433/test # L2 VIP -> HAProxy -> Primary Connection Pool -> Primary
postgres://test@10.10.10.3:5434/test # L2 VIP -> HAProxy -> Repilca Connection Pool -> Replica
postgres://dbuser_dba@10.10.10.3:5436/test # L2 VIP -> HAProxy -> Primary direct connection (for Admin)
postgres://dbuser_stats@10.10.10.3::5438/test # L2 VIP -> HAProxy -> offline direct connect (for ETL/personal queries)

# Specify any cluster instance name directly
postgres://test@pg-test-1:5432/test # DNS -> Database Instance Direct Connect (singleton access)
postgres://test@pg-test-1:6432/test # DNS -> connection pool -> database
postgres://test@pg-test-1:5433/test # DNS -> HAProxy -> connection pool -> database read/write
postgres://test@pg-test-1:5434/test # DNS -> HAProxy -> connection pool -> database read-only
postgres://dbuser_dba@pg-test-1:5436/test # DNS -> HAProxy -> database direct connect
postgres://dbuser_stats@pg-test-1:5438/test # DNS -> HAProxy -> database offline read/write

# Directly specify any cluster instance IP access
postgres://test@10.10.10.11:5432/test # Database instance direct connection (directly specify instance, no automatic traffic distribution)
postgres://test@10.10.10.11:6432/test # Connection Pool -> Database
postgres://test@10.10.10.11:5433/test # HAProxy -> connection pool -> database read/write
postgres://test@10.10.10.11:5434/test # HAProxy -> connection pool -> database read-only
postgres://dbuser_dba@10.10.10.11:5436/test # HAProxy -> Database Direct Connections
postgres://dbuser_stats@10.10.10.11:5438/test # HAProxy -> database offline read-write

# Smart client automatic read/write separation (connection pooling)
postgres://test@10.10.10.11:6432,10.10.10.12:6432,10.10.10.13:6432/test?target_session_attrs=primary
postgres://test@10.10.10.11:6432,10.10.10.12:6432,10.10.10.13:6432/test?target_session_attrs=prefer-standby
```



---------------

## Override Service

You can override default service configuration with several ways:

**Bypass Pgbouncer**

When defining a service, if `svc.dest='default'`, this parameter [`pg_default_service_dest`](PARAM#pg_default_service_dest) will be used as the default value.
`pgbouncer` is used by default, you can use `postgres` instead, so the default primary & replica service will bypass pgbouncer and route traffic to postgres directly

If you don't need connection pooling at all, you can change [`pg_default_service_dest`](PARAM#pg_default_service_dest) to `postgres`, and remove `default` and `offline` services.

If you don't need read-only replicas for online traffic, you can remove `replica` from `pg_default_services` too.  

```yaml
pg_default_services:
  - { name: primary ,port: 5433 ,dest: default  ,check: /primary   ,selector: "[]" }
  - { name: replica ,port: 5434 ,dest: default  ,check: /read-only ,selector: "[]" , backup: "[? pg_role == `primary` || pg_role == `offline` ]" }
  - { name: default ,port: 5436 ,dest: postgres ,check: /primary   ,selector: "[]" }
  - { name: offline ,port: 5438 ,dest: postgres ,check: /replica   ,selector: "[? pg_role == `offline` || pg_offline_query ]" , backup: "[? pg_role == `replica` && !pg_offline_query]"}
```




---------------

## Delegate Service

Pigsty expose PostgreSQL services with haproxy on node. All haproxy instances among the cluster are configured with the same service definition.

However, you can delegate pg service to a specific node group (e.g. dedicate haproxy lb cluster) rather than cluster members. 

To do so, you will have to override the default service definition with [`pg_default_services`](PARAM#pg_default_services) and set [`pg_service_provider`](PARAM#pg_service_provider) to the proxy group name.

For example, this configuration will expose pg cluster primary service on haproxy node group `proxy` with port 10013. 

```yaml
pg_service_provider: proxy       # use load balancer on group `proxy` with port 10013
pg_default_services:  [{ name: primary ,port: 10013 ,dest: postgres  ,check: /primary   ,selector: "[]" }]
```

It's user's responsibility to make sure each delegate service port is **unique** among the proxy cluster.

