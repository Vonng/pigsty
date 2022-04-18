# PGSQL Service & Access

> How to define PostgreSQL [service](#service) and achieve stable, reliable, and high-performance [access](#access) through load balancing and connection pooling.

[Personal User](#Personal-User) does not need to concern itself with the concept of [**Service**](#Service) versus [**Access**](#Access), which is a concept proposed for using a highly available PostgreSQL cluster in a production env.



---------------

### Personal User



After completing the standalone deployment, port 5432 of this node provides PostgreSQL services to the outside world, and port 80 provides UI-type services to the outside world.

On the current meta node, you can directly connect to the local predefined `meta` database battery-included by executing `psql` with no parameters using the management user.

When accessing from the outside (host) using the tools, you can use the URL:

```bash
psql postgres://dbuser_dba:DBUser.DBA@10.10.10.10/meta         # superuser Direct connection
psql postgres://dbuser_meta:DBUser.Meta@10.10.10.10/meta       # business user direct connect
```

You can use the administrator user specified by [`pg_admin_username`](v-pgsql.md#pg_admin_username) and [`pg_admin_password`](v-pgsql.md#pg_admin_password), or the pre-defined `meta` Other business users defined in the database (`dbuser_meta`) access this database.

Highly available clusters deployed in production envs using Pigsty are strongly discouraged from using direct IP connections [access](#access) to the database [service](#service).



---------------

## Service

**Service** in the form of functionality that a database cluster provides to the outside world.

In a production env, we would use a replication-based master-slave database cluster. The cluster has one and only one instance as the leader (master) that can accept writes, while the other instances (slaves) will continuously get change-logs from the cluster leader to keep up with the leader. The slave can also carry read-only requests, which can significantly share the load of the master for read-more-write-less scenarios, so it is a regular practice to distinguish write requests from read-only requests for the cluster.

In addition, for production environments with high frequency and short connections, we also pool requests through a connection pooling middleware (Pgbouncer) to reduce the connection and back-end process creation overhead. However, for scenarios such as ETL and change execution, we need to bypass the connection pool and access the database directly.

In addition, a highly available cluster will fail over **Failover** and the failover will cause the cluster leader to change. Highly available database solutions, therefore, require write traffic to automatically adapt to cluster leader changes.

These different access requirements (read/write separation, pooling vs. direct connection, failover auto-adaptation) are ultimately abstracted into the concept of **service**.

In general, a database cluster **must provide a service** that:

- **read and write service (primary)**: can write to the database

For a production database cluster, **at least two services should be provided.**

- **read-write service (primary)**: can write to the database

- **read-only service (replica)**: access to read-only data copies

In addition, depending on the specific business scenario, there may be other services, such as:

- **offline slave service (offline)**: a dedicated slave that does not take online read-only traffic, used for ETL and personal queries
- **synchronous slave service (standby)**: read-only service with synchronous commit and no replication delay
- **delayed**: allows services to access old data before a fixed time interval
- **default**: A service that allows (administrative) users to manage the database directly, bypassing the connection pool




---------------

## Default Services

Pigsty provides four services to the public by default: `primary`, `replica`, `default`, and `offline`.

You can define new services globally or for individual clusters via config files:

| service | port | purpose | description |
| ------- | ---- | ------------ | ---------------------------- |
| primary | 5433 | production read/write | connect to cluster primary via **connection pool** | replica | 5434 | production read/write
| replica | 5434 | production read-only | connection to cluster slave via **connection pool** | default | 5436 | management
| default | 5436 | management | direct connection to cluster master |
| offline | 5438 | ETL/personal user | connects directly to an available offline instance of the cluster |

Take the meta-database `pg-meta` as an example:

```bash
psql postgres://dbuser_meta:DBUser.Meta@pg-meta:5433/meta # production read/write
psql postgres://dbuser_meta:DBUser.Meta@pg-meta:5434/meta # production read-only
psql postgres://dbuser_dba:DBUser.DBA@pg-meta:5436/meta # Directly connected to the master
psql postgres://dbuser_stats:DBUser.Stats@pg-meta:5438/meta # Direct connect offline
```

These four services are described in detail below.

### Primary Service

The Primary service serves **online production read and writes access**, which maps the cluster's port 5433, to the **primary connection pool (default 6432)** port.

The Primary service selects **all** instances in the cluster as its members, but only those with a true health check `/primary` can actually take on traffic.

There is one and only one instance in the cluster that is the primary, and only its health check is true.

```yaml
# primary service will route {ip|name}:5433 to primary pgbouncer (5433->6432 rw)
- name: primary           # service name {{ pg_cluster }}-primary
  src_ip: "*"
  src_port: 5433
  dst_port: pgbouncer     # 5433 route to pgbouncer
  check_url: /primary     # primary health check, success when instance is primary
  selector: "[]"            # select all instance as primary service candidate
```

The highly available component Patroni on the primary repository returns 200 against the Primary health check and is used to ensure that the cluster does not have more than one instance of the primary repository.

When the cluster fails over, the health check is true for the new primary and false for the old one, so traffic is migrated to the new primary. The business side will notice a Primary service unavailability time of about 30 seconds.



### Replica Service

The Replica service serves **online production read-only access**, which maps the cluster's port 5434, to the **slave connection pool (default 6432)** port.

The Replica service selects **all** instances in the cluster as its members, but only those with a true health check `/read-only` can actually take on traffic, and that health check returns success for all instances (including the master) that can take on read-only traffic. So any member of the cluster can carry read-only traffic.

But by default, only slave libraries carry read-only requests. The Replica service defines `selector_backup`, a selector that adds the cluster's master library to the Replica service as a **backup instance**. **The master will start taking read-only traffic** only when all other instances in the Replica service, i.e. **all slaves, are down.**

Another role that acts as a **backup instance** is the `offline` role. Offline instances are typically dedicated to OLAP/ETL/personal interactive queries and are not suitable for mixing with online queries, so `offline` is only used to take on read-only traffic when all the `replica`s in the cluster are down.

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



### Default Service

The Default service serves the **online primary direct connection**, which maps the cluster's port 5436, to the **primary Postgres** port (default 5432).

The Default service targets interactive read and writes access, including executing administrative commands, executing DDL changes, connecting to the primary library to execute DML, and executing CDC. Interactive operations **should not** be accessed through connection pools, so the Default service forwards traffic directly to Postgres, bypassing the Pgbouncer.

The Default service is similar to the Primary service, using the same config options. The Default parameters are filled in explicitly for demonstration purposes.

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



### Offline Service

Offline service is used for offline access and personal queries. It maps the cluster's **5438** port, to the **offline instance Postgres** port (default 5432).

The Offline service is for interactive read-only access, including ETL, offline large analytics queries, and individual user queries. Interactive operations **should not** be accessed through connection pools, so the Default service forwards traffic directly to the offline instance of Postgres, bypassing the Pgbouncer.

Offline instances are those with `pg_role == offline` or with the `pg_offline_query` flag. Other **slave libraries** outside the Offline instance will act as backup instances for Offline so that when the Offline instance goes down, the Offline service can still get services from other slave libraries.

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

## User-Defined Service

In addition to the default services configured by [`pg_services`](v-pgsql.md#pg_services) above, users can use the same service definitions in the [`pg_services_extra`](v-pgsql.md#pg_services_extra) config entry for the PostgreSQL database cluster that defines additional services.

A cluster can have multiple services defined, each containing any number of cluster members, and the services are distinguished by **port**. The following code defines a new service, `standby`, that provides **synchronous reads** to the outside using port `5435`. This service will read from a synchronous slave (or master) in the cluster, thus ensuring that all reads are done without latency.

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


#### Required

- **Name (`service.name`)**.

  **service name**, the full name of the service is prefixed by the database cluster name and suffixed by `service.name`, connected by `-`. For example, a service with `name=primary` in the `pg-test` cluster has the full-service name `pg-test-primary`.

- **Port (`service.port`)**.

  In Pigsty, services are exposed to the public by default in the form of NodePort, so exposing the port is mandatory. However, if you use an external load balancing service access scheme, you can also distinguish the services in other ways.

- **selector (`service.selector`)**.

  The **selector** specifies the instance members of the service, in the form of a JMESPath that filters variables from all cluster instance members. The default `[]` selector will pick all cluster members.

#### Optional

- **backup selector (`service.selector`)**.

  Optional **backup selector** `service.selector_backup` will select or mark the list of instances used for service backup, i.e. the backup instance takes over the service only when all other members of the cluster fail. For example, the `primary` instance can be added to the alternate set of the `replica` service, so that the master can still carry the read-only traffic of the cluster when all the slaves fail.

- **source_ip (`service.src_ip`)**.

  Indicates the IP address used externally by the **service**. The default is `*`, which is all IP addresses on the local machine. Using `vip` will use the `vip_address` variable to take the value, or you can also fill in the specific IP address supported by the NIC.

- **Host port (`service.dst_port`)**.

  Which port on the target instance will the service's traffic be directed to? `postgres` will point to the port that the database listens on, `pgbouncer` will point to the port that the connection pool listens on, or you can fill in a fixed port number.

- **health check method (`service.check_method`)**:

  How does the service check the health status of the instance? Currently, only HTTP is supported

- **Health check port (`service.check_port`)**:

  Which port does the service check the instance on to get the health status of the instance? `patroni` will get it from Patroni (default 8008), `pg_exporter` will get it from PG Exporter (default 9630), or the user can fill in a custom port number.

- **Health check path (`service.check_url`)**:

  The URL PATH is used by the service to perform HTTP checks. `/` is used by default for health checks, and PG Exporter and Patroni provide a variety of health check methods that can be used to differentiate between master and slave traffic. For example, `/primary` will only return success for the master, and `/replica` will only return success for the slave. `/read-only`, on the other hand, will return success for any instance that supports read-only (including the master).

- **health check code (`service.check_code`)**:

  The code expected for HTTP health checks, default is 200.

- **Haproxy-specific configuration (`service.haproxy`)** :

  Proprietary config entries about the service provisioning software (HAProxy).

### Service Implementation

Pigsty currently uses HAProxy-based service implementation by default, and also provides a sample implementation based on Layer 4 load balancing (L4VIP), which are equivalent to each other and have their own advantages. For details, please refer to the section [access](#access).






---------------

## Access

**Access** mechanism is designed to solve the problem of real-world production envs: high concurrency & high availability.
**Individual users** do not really need these. You can just ignore these access mechanisms, bypass domain names, VIPs, load balancers, and connection pools, and access the database directly via IP address.

> Access default database via `postgres://dbuser_dba:DBUser.DBA@10.10.10.10:5432/meta` (replace IP & password)

In Pigsty's default config, a fully functional load balancer (HAProxy) is deployed on each database instance/node, so **any instance** of the entire cluster can serve as the access point for the entire cluster. You need to decide your own access policy: **how to distribute business traffic to one, multiple, or all load-balanced instances** in the cluster.

Pigsty provides a rich set of access methods that you can choose based on your network infrastructure and preferences. As a sample, the Pigsty sandbox uses an L2 VIP bound to the cluster master and a domain name bound to that VIP. The application accesses the load-balancing instance on the cluster master through the L2 VIP via the domain name. When this node becomes unavailable, the VIP drifts with the cluster master, and the traffic is then carried by the load balancer on the new master, as shown in the following figure.

![](_media/access.svg)

Another classic strategy is to use DNS polling directly to resolve DNS domain names to all instances. Several common access patterns will be given in this article.



## User Interface

From the user's point of view, access to the database requires only a connection string; and the interface delivered by Pigsty to the end-user is also a database connection string.

The formal difference between the different **access methods** is the difference between the [host](#主机) and [port](#port) parts of the connection string.

### Port

Pigsty uses different **ports** to distinguish between [database services](c-service.md#service), which provide Postgres equivalent services, as follows

| port | service | type | description |
| ---- | --------- | -------------------- | ------------------------------------ |
| 5432 | postgres | database | direct access to the current node database instance |
| 6432 | pgbouncer | connection pool | Accessing the current node database through a connection pool |
| 5433 | primary | [service](c-service.md) | load-balancing and accessing the cluster primary through a **connection pool** |
| 5434 | replica | [service](c-services.md) | load-balancing and accessing the cluster primary through a **connection pool** | 5436 | default | [service](c-services.md) | load-balancing and accessing the cluster primary through a **connection pool** |
| 5436 | default | [service](c-service.md) | load-balancing and accessing the cluster master |
| 5438 | offline | [service](c-service.md) | load-balancing direct access to cluster offline instances |


### Host

| type | sample | description |
| ------------ | ------------------- | ------------------------------------ |
| cluster-domain | `pg-test` | Direct access to the current node database instance |
| Cluster VIP | `10.10.10.3` | Access the current node database through a connection pool |
| instance-specific domain name | `pg-test-1` | load-balancing and accessing the cluster master through **connection pooling** |
| instance-specific IP | `10.10.10.11` | load-balancing and accessing the cluster master through **connection pooling** |
| All IP addresses | `10.10,10.11,10.12` | Use Multihost feature, client support required |

Depending on the contents of the `host` section and the available `port` values, multiple connection strings can be combined.


### Available Combinations

In a single-node sandbox env, for example, the following connection strings are available for the `test` database on the cluster `pg-test`.

<details><summary>Available Combinations</summary>			

```bash
# Access via cluster domain
postgres://test@pg-test:5432/test # DNS -> L2 VIP -> master direct connection
postgres://test@pg-test:6432/test # DNS -> L2 VIP -> master connection pool -> master
postgres://test@pg-test:5433/test # DNS -> L2 VIP -> HAProxy -> Master Connection Pool -> Master
postgres://test@pg-test:5434/test # DNS -> L2 VIP -> HAProxy -> Slave Connection Pool -> Slave
postgres://dbuser_dba@pg-test:5436/test # DNS -> L2 VIP -> HAProxy -> Master direct connection (for management)
postgres://dbuser_stats@pg-test:5438/test # DNS -> L2 VIP -> HAProxy -> offline repository direct connection (for ETL/personal queries)

# Direct access via cluster VIP
postgres://test@10.10.10.3:5432/test # L2 VIP -> Master direct access
postgres://test@10.10.10.3:6432/test # L2 VIP -> Main Library Connection Pool -> Main Library
postgres://test@10.10.10.3:5433/test # L2 VIP -> HAProxy -> Main Library Connection Pool -> Main Library
postgres://test@10.10.10.3:5434/test # L2 VIP -> HAProxy -> Slave Connection Pool -> Slave
postgres://dbuser_dba@10.10.10.3:5436/test # L2 VIP -> HAProxy -> Master direct connection (for management)
postgres://dbuser_stats@10.10.10.3::5438/test # L2 VIP -> HAProxy -> offline library direct connect (for ETL/personal queries)

# Specify any cluster instance name directly
postgres://test@pg-test-1:5432/test # DNS -> Database Instance Direct Connect (single instance access)
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

At the cluster level, users can access the 4 [**default services**](c-service.md#default-service) provided by the cluster by using **cluster domain name** + service port, which Pigsty strongly recommends. Of course, users can also bypass the domain name and access the database cluster directly using the cluster's VIP (L2 or L4).

At the instance level, users can connect directly to the Postgres database via the node IP/domain name + port 5432, or they can use port 6432 to access the database via Pgbouncer. Services provided by the cluster to which the instance belongs can also be accessed via Haproxy via 5433~543x.



## Access Method

Pigsty recommends the use of Haproxy-based access schemes (1/2), and in production envs where infrastructure support is available, L4VIP (or equivalent load balancing services) based access schemes (3) can also be used.

| Serial Number | Solution | Description |
| ---- | ---------------------------------- | --------------------------------------------------------- |
| 1 | [L2VIP + Haproxy](#l2-vip-haproxy) | Standard access architecture used by Pigsty sandboxes, using L2 VIP to ensure high availability of Haproxy |
| 2 | [DNS + Haproxy](#dns-haproxy) | Standard high availability access scheme, no single point of system.                          |
| 3 | [L4VIP + Haproxy](#l4-vip-haproxy) | A variant of Scenario 2, using L4 VIP to ensure Haprxoy is highly available.                |
| 4 | [L4 VIP](#l4-vip) | Large-scale **high-performance production envs** are recommended to use DPVS L4 VIP direct access |
| 5 | [Consul DNS](#consul-dns) | Use Consul DNS for service discovery, bypassing VIPs and Haproxy |
| 6 | [Static DNS](#static-dns) | Traditional static DNS access |
| 7 | [IP](#ip) | Using Smart Client Access |

![](./_media/access-decision.svg)



### L2 VIP + Haproxy

#### Solution Description

The standard access scheme used by Pigsty sandboxes uses a single domain name bound to a single L2 VIP, with the VIP pointing to the Haproxy in the cluster.

The Haproxy in the cluster uses Node Port to expose [**service**](c-service.md) to the public in a unified way. Each Haproxy is an idempotent instance, providing complete load balancing and service distribution. haproxy is deployed on each database node so that each member of the entire cluster is idempotent in terms of usage effect. (For example, accessing port 5433 of any member connects to the master connection pool, and accessing port 5434 of any member connects to the connection pool of some slave).

The availability of the Haproxy itself **is achieved through idempotent replicas**, where each Haproxy can be used as an access portal and users can use one, two, or more, of all Haproxy instances, each of which provides exactly the same functionality.

Each cluster is assigned **one** L2 VIP, which is fixedly bound to the cluster master. When a switch of master occurs, that L2 VIP drifts to the new master as well. This is achieved through `vip-manager`: `vip-manager` will query Consul to get the cluster's current master information, and then listen to the VIP address on the master.

The L2 VIP of the cluster has a **domain name** corresponding to it. The domain name is fixed to resolve to this L2 VIP and does not change during the lifecycle.

#### Solution Superiority

* No single point, high availability

* VIP fixed binding to the main library, can be flexible access

#### Solution limitations

* One more hop

* A client's IP address is lost, and some HBA policies cannot take effect normally

* All candidate master libraries must **be located in the same Layer 2 network**.

  * As an alternative, users can also bypass this restriction by using L4 VIP, but there will be one extra hop compared to L2 VIP.
  * As an alternative, users can also choose not to use L2 VIP and use DNS to point directly to HAProxy, but may be affected by client DNS caching.


#### Schematic of the solution

![](./_media/access.svg)



### DNS + Haproxy

#### Solution Description

Standard high availability access solution with no single point of the system. A good balance of flexibility, applicability, and performance.

Haproxy in a cluster uses Node Port to expose [**service**](c-service.md) to the public in a unified way. Each Haproxy is an idempotent instance, providing complete load balancing and service distribution. Haproxy is deployed on each database node so that each member of the entire cluster is idempotent in terms of usage effect. (For example, accessing port 5433 of any member connects to the master connection pool, and accessing port 5434 of any member connects to the connection pool of some slave).

The availability of Haproxy itself **is achieved through idempotent copies**, where each Haproxy can be used as an access portal and the user can use one, two, or more, all Haproxy instances, each providing exactly the same functionality.

**The user needs to ensure on his own that the application can access any of the healthy Haproxy instances**. As one of the most rudimentary implementations, users can resolve the DNS domain name of a database cluster to several Haproxy instances with DNS polling responses enabled. And the client can choose not to cache DNS at all, or use long connections and implement a mechanism to retry after a failed connection is established. Or refer to Option 2 and ensure high availability of Haproxy itself with additional L2/L4 VIPs on the architecture side.

#### Solution Superiority

* No single point, high availability

* VIP fixed binding to the main library, can be flexible access

#### Solution limitations

* One more hop

* A client's IP address is lost, some HBA policies can not take effect properly

* **Haproxy itself is highly available through idempotent copy, DNS polling, and client reconnection**.

  DNS should have a polling mechanism, clients should use long connections, and there should be a retry mechanism for failing to build a connection. This is so that a single Haproxy failure can automatically drift to other Haproxy instances in the cluster. If this is not possible, consider using **Access Scenario 2**, which uses L2/L4 VIPs to ensure Haproxy high availability.

#### Schematic of the solution

![](./_media/access-dns-ha.svg)





### L4 VIP + Haproxy

<details><summary>Four-tier load balancing + HAProxy access</summary>

#### Solution overview

Another variant of access solution 1/2, ensuring high availability of Haproxy via L4 VIP.

#### Solution advantages

* No single point, high availability.
* Can use **all** Haproxy instances simultaneously to carry traffic evenly
* All candidate primary libraries **do not need to** be located in the same Layer 2 network.
* Can operate a single VIP to complete traffic switching (if multiple Haproxy's are used at the same time, no need to adjust each one).

#### Solution limitations

* More than two hops, are more wasteful, if the conditions can be directly used program 4: L4 VIP direct access.
* A client's IP address is lost, and part of the HBA policy can not take effect properly.





### L4 VIP

<details><summary>Four-tier load-balanced access</summary>

#### Program Description

Large-scale **high-performance production env** recommended using L4 VIP access (FullNAT, DPVS).

#### Solution Superiority

* Good performance and high throughput
* The correct client IP address can be obtained through the `toa` module, and HBA can be fully effective.

#### Solution limitation

* Still one more article.
* Need to rely on external infrastructure, complicated to deploy.
* Still lose client IP addresses when the `toa` kernel module is not enabled.
* No Haproxy to mask master-slave differences, and each node in the cluster is no longer "**idempotent**".





### Consul DNS

<details><summary>Consul DNS access</summary>

#### Solution Description

L2 VIPs are not always available, especially since the requirement that all candidate master libraries must **be located on the same Layer 2 network** may not always be met.

In such cases, DNS resolution can be used instead of L2 VIP.

#### Solution Superiority

* One less hop

#### Solution Limitations

* Reliance on Consul DNS
* User needs to configure DNS caching policy properly





### Static DNS

<details><summary>static DNS access</summary>

#### Solution Introduction

Traditional static DNS access method

#### Advantages of the solution

* One less hop
* Simple implementation

#### Solution Limitations

* No flexibility
* Prone to traffic loss during master-slave switching





### IP

<details><summary>IP Direct Access</summary>

#### Solution Introduction

Direct database IP access using smart clients

#### Solution advantages

* Direct connection to database/connection pool, one less
* No reliance on additional components for master-slave differentiation, reducing system complexity.

#### Solution limitations

* Too inflexible, cumbersome to expand and reduce cluster capacity.





