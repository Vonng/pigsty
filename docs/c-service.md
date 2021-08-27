# Database Services

> How to define services in Pigsty

## Personal users

Personal/sandbox users do not need to be concerned about **services**, a concept proposed for using databases in production environments.

Pigsty will **configure the relevant environment for administrative users** on the administrative node, and individual users can connect directly to the database via IP address, e.g.

```bash
psql # by default will use dbuser_dba to connect to the local meta database vagrant@meta
psql -h 10.10.10.11 # The default will be to use dbuser_dba to connect to the 10.10.10.10 postgres database
````

When accessing from the outside (host) using the tools, you can use the URL

```bash
psql postgres://dbuser_dba:DBUser.DBA@10.10.10.10/meta # superuser Direct connection
psql postgres://dbuser_meta:DBUser.Meta@10.10.10.10/meta # business user direct connect
psql postgres://dbuser_meta:DBUser.Meta@10.10.10.10:5433/meta # go load balancing with connection pooling
```

When deploying Pigsty in a production environment, you need to focus on **services**.

## What is a Service

A **Service** is the form of functionality that a database cluster provides to the outside world.

In a real-world production environment, we would use a replication-based master-slave database cluster. There is one and only one instance in the cluster that acts as the leader (master) and can accept writes, while the other instances (slaves) will continuously get change logs from the cluster leader to keep up with the leader. The slave can also carry read-only requests, which can significantly share the load of the master for read-more-write-less scenarios, so it is a regular practice to distinguish write requests from read-only requests for the cluster.

In addition, for production environments with high frequency and short connections, we also pool requests through a connection pooling middleware (Pgbouncer) to reduce the connection and back-end process creation overhead. However, for scenarios such as ETL and change execution, we need to bypass the connection pool and access the database directly.

In addition, a highly available cluster will fail over **Failover** and the failover will cause the cluster leader to change. Highly available database solutions therefore require write traffic to automatically adapt to cluster leader changes.

These different access requirements (read/write separation, pooling and direct connection, failover auto-adaptation) are eventually abstracted into the concept of **service**.


## Service Representation

The external manifestation of a service is usually an **access endpoint**, such as a connection URL to a PostgreSQL database.
The user can access the corresponding database functionality through this endpoint.

In general, a database cluster **must provide a service** that

- **read and write service (primary)**: can write to the database

For a production database cluster** at least two services should be provided**.

- **read-write service (primary)**: can write to the database

- **read-only service (replica)**: access to read-only data copies

In addition, depending on the specific business scenario, there may be other services, such as

- **offline slave service (offline)**: dedicated slave that does not take online read-only traffic, used for ETL and personal queries
- **synchronous slave service (standby)**: read-only service with synchronous commit and no replication delay
- **delayed**: allows services to access old data before a fixed time interval
- **default** : A service that allows (administrative) users to manage the database directly, bypassing the connection pool



## Default Services

Pigsty provides four services to the public by default: `primary`, `replica`, `default`, `offline`.

You can define new services globally or for individual clusters via configuration files

| service | port | purpose | description |
| ------- | ---- | ------------ | ---------------------------- |
| primary | 5433 | production read/write | connect to cluster primary via **connection pool** | replica | 5434 | production read/write
| replica | 5434 | production read-only | connection to cluster slave via **connection pool** | default | 5436 | management
| default | 5436 | management | direct connection to cluster master |
| offline | 5438 | ETL/personal user | connects directly to an available offline instance of the cluster |

Take the metadatabase `pg-meta` as an example

```bash
psql postgres://dbuser_meta:DBUser.Meta@pg-meta:5433/meta # production read/write
psql postgres://dbuser_meta:DBUser.Meta@pg-meta:5434/meta # production read-only
psql postgres://dbuser_dba:DBUser.DBA@pg-meta:5436/meta # Directly connected to the master
psql postgres://dbuser_stats:DBUser.Stats@pg-meta:5438/meta # Direct connect offline
```

Take the sandbox test cluster `pg-test` as an example

| service | port | description | sample |
| ------- | ---- | -------------------------- | ------------------------------------------------------------ |
| primary | 5433 | Only production users can connect | postgres://test@pg-test:5433/test |
| replica | 5434 | Only production users can connect | postgres://test@pg-test:5434/test |
| default | 5436 | Administrator and DML executor can connect | postgres://dbuser_admin@pg-test:5436/test |
| offline | 5438 | ETL/STATS Individual users can connect | postgres://dbuser_stats@pg-test:5438/test<br />postgres://dbp_vonng@pg-test:5438/test |

These four services are described in detail below



## Primary Service

The Primary service serves **online production read and write access**, which maps the cluster's port 5433, to the **primary connection pool (default 6432)** port.

The Primary service selects **all** instances in the cluster as its members, but only those with a true health check `/primary` can actually take on traffic.

There is one and only one instance in the cluster that is the primary, and only its health check is true.

```yaml
# primary service will route {ip|name}:5433 to primary pgbouncer (5433->6432 rw)
- name: primary # service name {{ pg_cluster }}-primary
  src_ip: "*"
  src_port: 5433
  dst_port: pgbouncer # 5433 route to pgbouncer
  check_url: /primary # primary health check, success when instance is primary
  selector: "[]" # select all instance as primary service candidate
```

## Replica service

The Replica service serves **online production read-only access**, which maps the cluster's port 5434, to the **slave connection pool (default 6432)** port.

The Replica service selects **all** instances in the cluster as its members, but only those with a true health check `/read-only` can actually take on traffic, and that health check returns success for all instances (including the master) that can take on read-only traffic. So any member of the cluster can carry read-only traffic.

But by default, only slave libraries carry read-only requests. The Replica service defines `selector_backup`, a selector that adds the cluster's master library to the Replica service as a **backup instance**. The master will start taking read-only traffic** only when all other instances in the Replica service, i.e. **all slaves, are down.

```yaml
# replica service will route {ip|name}:5434 to replica pgbouncer (5434->6432 ro)
- name: replica # service name {{ pg_cluster }}-replica
  src_ip: "*"
  src_port: 5434
  dst_port: pgbouncer
  check_url: /read-only # read-only health check.(including primary)
  selector: "[]" # select all instance as replica service candidate
  selector_backup: "[? pg_role == `primary`]" # primary are used as backup server in replica service
```



## Default service

The Default service serves the **online primary direct connection**, which maps the cluster's port 5436, to the **primary Postgres** port (default 5432).

The Default service targets interactive read and write access, including: executing administrative commands, executing DDL changes, connecting to the primary library to execute DML, and executing CDC. interactive operations **should not** be accessed through connection pools, so the Default service forwards traffic directly to Postgres, bypassing the Pgbouncer.

The Default service is similar to the Primary service, using the same configuration options. The Default parameters are filled in explicitly for demonstration purposes.

```yaml
# default service will route {ip|name}:5436 to primary postgres (5436->5432 primary)
- name: default # service's actual name is {{ pg_cluster }}-default
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



## Offline Services

Offline service is used for offline access and personal queries. It maps the cluster's **5438** port, to the **offline instance Postgres** port (default 5432).

The Offline service is for interactive read-only access, including: ETL, offline large analytics queries, and individual user queries. Interactive operations **should not** be accessed through connection pools, so the Default service forwards traffic directly to the offline instance of Postgres, bypassing the Pgbouncer.

Offline instances are those with `pg_role == offline` or with the `pg_offline_query` flag. Other **other slave libraries** outside the Offline instance will act as backup instances for Offline, so that when the Offline instance goes down, the Offline service can still get services from other slave libraries.

```yaml
# offline service will route {ip|name}:5438 to offline postgres (5438->5432 offline)
- name: offline # service name {{ pg_cluster }}-offline
  src_ip: "*"
  src_port: 5438
  dst_port: postgres
  check_url: /replica # offline MUST be a replica
  selector: "[? pg_role == `offline` || pg_offline_query ]" # instances with pg_role == 'offline' or instance marked with 'pg_offline_query == true'
  selector_backup: "[? pg_role == `replica` && !pg_offline_query]" # replica are used as backup server in offline service
```


## Service Definitions

An array of service definition objects defines the services exposed to the public in each database cluster. Each cluster can define multiple services, each containing any number of cluster members, and services are distinguished by **ports**.

Services are defined via [**`pg_services`**] and [**`pg_services_extra`**]. The former is used to define services that are common across the environment, and the latter is used to define cluster-specific additional services. Both are arrays consisting of **service definitions**.

The following code defines a new service `standby` that uses port `5435` to provide **synchronous read** functionality to the outside world. This service will read from a synchronous slave (or master) in the cluster, thus ensuring that all reads are done without latency.



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

  **service name**, the full name of the service is prefixed by the database cluster name and suffixed by `service.name`, connected by `-`. For example, a service with `name=primary` in the `pg-test` cluster has the full service name `pg-test-primary`.

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

  How does the service check the health status of the instance? Currently only HTTP is supported

- **Health check port (`service.check_port`)**:

  Which port does the service check the instance on to get the health status of the instance? `patroni` will get it from Patroni (default 8008), `pg_exporter` will get it from PG Exporter (default 9630), or user can fill in a custom port number.

- **Health check path (`service.check_url`)**:

  The URL PATH used by the service to perform HTTP checks. `/` is used by default for health checks, and PG Exporter and Patroni provide a variety of health check methods that can be used to differentiate between master and slave traffic. For example, `/primary` will only return success for the master, and `/replica` will only return success for the slave. `/read-only`, on the other hand, will return success for any instance that supports read-only (including the master).

- **health check code (`service.check_code`)**:

  The code expected for HTTP health checks, default is 200

- **Haproxy-specific configuration (`service.haproxy`)** :

  Proprietary configuration items about the service provisioning software (HAProxy)



## Service Implementation

Pigsty currently uses HAProxy-based service implementation by default, and also provides a sample implementation based on Layer 4 load balancing (L4VIP), which are equivalent to each other and have their own advantages. For details, please refer to the section [access](c-access.md).

