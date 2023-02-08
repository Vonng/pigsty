# PGSQL Service

> Split read & write, route traffic to the right place, and achieve stable & reliable access to the PostgreSQL cluster.

Service is an abstraction to seal the details of the underlying cluster, especially during cluster failover/switchover. 


---------------

## Personal User

Service is meaningless to personal users. You can access the database with raw IP address directly or whatever method you like.

```bash
psql postgres://dbuser_dba:DBUser.DBA@10.10.10.10/meta         # dbsu direct connect
psql postgres://dbuser_meta:DBUser.Meta@10.10.10.10/meta       # bizuser direct connect
```



---------------

## Service

**Service** is a logical abstraction for PostgreSQL cluster abilities. Which consist of:

1. Access Point via NodePort
2. Target Instances via Selectors

It's quite like a Kubernetes service (NodePort mode), but it is implemented differently (haproxy on the nodes).

Here are the default PostgreSQL services and their definition:

| service | port | description                                      |
| ------- | ---- | ------------------------------------------------ |
| primary | 5433 | PROD read/write, connect to primary 5432 or 6432 |
| replica | 5434 | PROD read-only, connect to replicas 5432/6432    |
| default | 5436 | admin or direct access to primary                |
| offline | 5438 | OLAP, ETL, personal user, interactive queries    |

```yaml
- { name: primary ,port: 5433 ,dest: default  ,check: /primary   ,selector: "[]" }
- { name: replica ,port: 5434 ,dest: default  ,check: /read-only ,selector: "[]" , backup: "[? pg_role == `primary` || pg_role == `offline` ]" }
- { name: default ,port: 5436 ,dest: postgres ,check: /primary   ,selector: "[]" }
- { name: offline ,port: 5438 ,dest: postgres ,check: /replica   ,selector: "[? pg_role == `offline` || pg_offline_query ]" , backup: "[? pg_role == `replica` && !pg_offline_query]"}
```

![pgsql-ha](https://user-images.githubusercontent.com/8587410/206971583-74293d7b-d29a-4ca2-8728-75d50421c371.gif)


Take the default `pg-meta` cluster & `meta` database as an example, it will have four default services:

```bash
psql postgres://dbuser_meta:DBUser.Meta@pg-meta:5433/meta   # pg-meta-primary : production read/write via primary pgbouncer(6432)
psql postgres://dbuser_meta:DBUser.Meta@pg-meta:5434/meta   # pg-meta-replica : production read-only via replica pgbouncer(6432)
psql postgres://dbuser_dba:DBUser.DBA@pg-meta:5436/meta     # pg-meta-default : Direct connect primary via primary postgres(5432)
psql postgres://dbuser_stats:DBUser.Stats@pg-meta:5438/meta # pg-meta-offline : Direct connect offline via offline postgres(5432)
```

EVERY INSTANCE of `pg-meta` cluster will have these four services exposed; you can access service via ANY / ALL of them.



---------------

## Primary Service

The primary service may be the most critical service for production usage.

It will route traffic to the primary instance, depending on [`pg_default_service_dest`](PARAM#pg_default_service_dest):

* `pgbouncer`: route traffic to primary pgbouncer port (6432), which is the default behavior
* `postgres`: route traffic to primary postgres port (5432) directly, if you don't want to use pgbouncer

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

The replica service is used for production read-only traffics. 

There may be many more read-only queries than read-write queries in real-world scenarios, you may have many replicas for that.

The replica service will route traffic to pgbouncer or postgres depending on [`pg_default_service_dest`](PARAM#pg_default_service_dest), just like [primary service](#primary-service).

```yaml
- { name: replica ,port: 5434 ,dest: default  ,check: /read-only ,selector: "[]" , backup: "[? pg_role == `primary` || pg_role == `offline` ]" }
```

The `replica` service traffic will try to use common pg instances with [`pg_role`](PARAM#pg_role) = `replica` to alleviate the load on the `primary` instance as much as possible.
And it will try NOT to use instances with [`pg_role`](PARAM#pg_role) = `offline` to avoid mixing OLAP & OLTP queries as much as possible.

All cluster members will be included in the replica service (`selector: "[]"`) when it passes the read-only health check (`check: /read-only`). 
While `primary` and `offline` instances are used as backup servers, which will take over in case of all `replica` instances are down.


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

It is quite like primary service, except that it will always bypass pgbouncer, regardless of [`pg_default_service_dest`](PARAM#pg_default_service_dest).
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
    http-check send meth OPTIONS uri /
    http-check expect status 200
    default-server inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100
    # servers
    server pg-test-1 10.10.10.11:6432 check port 8008 weight 100 backup
    server pg-test-3 10.10.10.13:6432 check port 8008 weight 100
    server pg-test-2 10.10.10.12:6432 check port 8008 weight 100
```




---------------

## Reload Service

When cluster membership has changed, such as append / remove replicas, switchover/failover, or adjust relative weight,
You have to [reload service](PGSQL-ADMIN#reload-service) to make the changes take effect.

```bash
bin/pgsql-svc <cls> [ip...]         # reload service for lb cluster or lb instance
```



---------------

## Access Service

Pigsty expose [service](#service) with haproxy. Which is enabled on all nodes by default.

haproxy load balancers are idempotent among same pg cluster by default, you use **ANY** / **ALL** of them by all means.

The typical method is access via cluster domain name, which resolve to cluster L2 VIP, or all instances ip address in a round-robin manner.

Service can be implemented in different ways, You can even implement you own access method such as L4 LVS, F5, etc... instead of haproxy.

You can use different combination of [host](#host) and [port](#port), they are provide PostgreSQL service in different ways.

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

# Directly specify any cluster instance IP access
postgres://test@10.10.10.11:5432/test # Database instance direct connection (directly specify instance, no automatic traffic distribution)
postgres://test@10.10.10.11:6432/test # Connection pool -> database
postgres://test@10.10.10.11:5433/test # HAProxy -> connection pool -> database read/write
postgres://test@10.10.10.11:5434/test # HAProxy -> connection pool -> database read-only
postgres://dbuser_dba@10.10.10.11:5436/test # HAProxy -> Database Direct Connections
postgres://dbuser_stats@10.10.10.11:5438/test # HAProxy -> database offline read-write

# Smart client automatic read/write separation (connection pooling)
postgres://test@10.10.10.11:6432,10.10.10.12:6432,10.10.10.13:6432/test?target_session_attrs=primary
postgres://test@10.10.10.11:6432,10.10.10.12:6432,10.10.10.13:6432/test?target_session_attrs=prefer-standby

# Intelligent client automatic read/write separation (database)
postgres://test@10.10.10.11:5432,10.10.10.12:5432,10.10.10.13:5432/test?target_session_attrs=primary
postgres://test@10.10.10.11:5432,10.10.10.12:5432,10.10.10.13:5432/test?target_session_attrs=prefer-standby

```