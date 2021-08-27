# Access

Access is designed to solve the problem of high concurrency, high availability, and large-scale management in **production environments**. **Individual users** can choose to ignore the access mechanism, bypass domain names, VIPs, load balancers, connection pools, and access the database directly via IP address.

In Pigsty's default configuration, a fully functional load balancer (HAProxy) is deployed on each database instance/node, so **any instance** of the entire database cluster can serve as the access point for the entire cluster. You need to decide your own access policy: **how to distribute business traffic to one, multiple, or all load-balanced instances** in the cluster.

Pigsty provides a rich set of access methods that you can choose based on your network infrastructure and preferences. As a sample, the Pigsty sandbox uses an L2 VIP bound to the cluster master and a domain name bound to that VIP. The application accesses the load balancing instance on the cluster master through the L2 VIP via the domain name. When this node becomes unavailable, the VIP drifts with the cluster master and the traffic is then carried by the load balancer on the new master, as shown in the following figure.

![](_media/access.svg)

Another classic strategy is to use DNS polling directly to resolve DNS domain names to all instances.

Several common access patterns will be given in this article.



## User Interface

From the user's point of view, access to the database requires only a connection string; the interface delivered by Pigsty to the end user is, in turn, a database connection string.

The formal difference between the different **access methods** is the difference between the [host] (# host) and [port] (# port) parts of the connection string.

### Port

Pigsty uses different **ports** to distinguish between [database services](c-services.md), which provide Postgres equivalent services, as follows

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

### Available connection string combinations

In a single-node sandbox environment, for example, the following connection strings are available for the `test` database on the database cluster `pg-test`.

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

At the cluster level, users can access the [**four default services**] (c-service#default service) provided by the cluster by using **cluster domain** + service port, which Pigsty strongly recommends. Of course users can also bypass the domain name and access the database cluster directly using the cluster's VIP (L2 or L4).

At the instance level, users can connect directly to the Postgres database via the node IP/domain name + port 5432, or they can use port 6432 to access the database via Pgbouncer. Services provided by the cluster to which the instance belongs can also be accessed via Haproxy via 5433~543x.




## Typical Access Solutions

Pigsty recommends the use of Haproxy-based access schemes (1/2), and in production environments where infrastructure support is available, L4VIP (or equivalent load balancing services) based access schemes (3) can also be used.

| Serial Number | Solution | Description |
| ---- | ---------------------------------- | --------------------------------------------------------- |
| 1 | [L2VIP + Haproxy](#l2-vip-haproxy) | Standard access architecture used by Pigsty sandboxes, using L2 VIP to ensure high availability of Haproxy |
| 2 | [DNS + Haproxy](#dns-haproxy) | Standard high availability access scheme, no single point of system.                          | 2
| 3 | [L4VIP + Haproxy](#l4-vip-haproxy) | A variant of Scenario 2, using L4 VIP to ensure Haprxoy is highly available.                | | [l4-vip-haproxy
| 4 | [L4 VIP](#l4-vip) | Large-scale **high-performance production environments** are recommended to use DPVS L4 VIP direct access |
| 5 | [Consul DNS](#consul-dns) | Use Consul DNS for service discovery, bypassing VIPs and Haproxy | 5 | [Consul DNS](#consul-dns)
| 6 | [Static DNS](#static-dns) | Traditional static DNS access |
| 7 | [IP](#ip) | Using Smart Client Access |

! [](... /_media/access-decision.svg)




## L2 VIP + Haproxy

### Solution Description

The standard access scheme used by Pigsty sandboxes uses a single domain name bound to a single L2 VIP, with the VIP pointing to the Haproxy in the cluster.

The Haproxy in the cluster uses Node Port to expose [**service**](c-service/) to the public in a unified way. Each Haproxy is an idempotent instance, providing complete load balancing and service distribution. haproxy is deployed on each database node, so that each member of the entire cluster is idempotent in terms of usage effect. (For example, accessing port 5433 of any member connects to the master connection pool, and accessing port 5434 of any member connects to the connection pool of some slave)

The availability of the Haproxy itself **is achieved through idempotent replicas**, where each Haproxy can be used as an access portal and users can use one, two, or more, of all Haproxy instances, each of which provides exactly the same functionality.

Each cluster is assigned **one** L2 VIP, which is fixedly bound to the cluster master. When a switch of master occurs, that L2 VIP drifts to the new master as well. This is achieved through `vip-manager`: `vip-manager` will query Consul to get the cluster's current master information, and then listen to the VIP address on the master.

The L2 VIP of the cluster has a **domain name** corresponding to it. The domain name is fixed to resolve to this L2 VIP and does not change during the lifecycle.

### Solution Superiority

* No single point, high availability

* VIP fixed binding to the main library, can be flexible access

### Solution limitations

* One more hop

* Client IP address is lost, and some HBA policies cannot take effect normally

* All candidate master libraries must ** be located in the same Layer 2 network **.

  * As an alternative, users can also bypass this restriction by using L4 VIP, but there will be one extra hop compared to L2 VIP.
  * As an alternative, users can also choose not to use L2 VIP and use DNS to point directly to HAProxy, but may be affected by client DNS caching.


### Schematic of the solution

! [](. /_media/access.svg)



## DNS + Haproxy

### Solution Description

Standard high availability access solution with no single point of system. A good balance of flexibility, applicability, and performance.

Haproxy in a cluster uses Node Port to expose [**service**](c-service/) to the public in a unified way. Each Haproxy is an idempotent instance, providing complete load balancing and service distribution. haproxy is deployed on each database node, so that each member of the entire cluster is idempotent in terms of usage effect. (For example, accessing port 5433 of any member connects to the master connection pool, and accessing port 5434 of any member connects to the connection pool of some slave)

The availability of Haproxy itself **is achieved through idempotent copies**, where each Haproxy can be used as an access portal and the user can use one, two, or more, all Haproxy instances, each providing exactly the same functionality.

**The user needs to ensure on his own that the application can access any of the healthy Haproxy instances**. As one of the most rudimentary implementations, users can resolve the DNS domain name of a database cluster to a number of Haproxy instances with DNS polling responses enabled. And the client can choose not to cache DNS at all, or use long connections and implement a mechanism to retry after a failed connection is established. Or refer to Option 2 and ensure high availability of Haproxy itself with additional L2/L4 VIPs on the architecture side.

### Solution Superiority

* No single point, high availability

* VIP fixed binding to the main library, can be flexible access

### Solution limitations

* One more hop

* Client IP address is lost, some HBA policies can not take effect properly

* **Haproxy itself is highly available through idempotent copy, DNS polling and client reconnection**

  DNS should have a polling mechanism, clients should use long connections, and there should be a retry mechanism for failing to build a connection. This is so that a single Haproxy failure can automatically drift to other Haproxy instances in the cluster. If this is not possible, consider using **Access Scenario 2**, which uses L2/L4 VIPs to ensure Haproxy high availability.

### Schematic of the solution

! [](. /_media/access-dns-ha.svg)





## L4 VIP + Haproxy

### Solution overview

Another variant of access solution 1/2, ensuring high availability of Haproxy via L4 VIP

### Solution advantages

* No single point, high availability
* Can use **all** Haproxy instances simultaneously to carry traffic evenly
* All candidate primary libraries ** do not need to ** be located in the same Layer 2 network.
* Can operate a single VIP to complete traffic switching (if multiple Haproxy's are used at the same time, no need to adjust each one)

### Solution limitations

* More than two hops, more wasteful, if the conditions can be directly used program 4: L4 VIP direct access.
* Client IP address is lost, part of the HBA policy can not take effect properly





## L4 VIP

### Program Description

Large-scale ** high-performance production environment ** recommended to use L4 VIP access (FullNAT, DPVS)

### Solution Superiority

* Good performance and high throughput
* The correct client IP address can be obtained through `toa` module, and HBA can be fully effective.

### Solution limitation

* Still one more article.
* Need to rely on external infrastructure, complicated to deploy.
* Still lose client IP addresses when `toa` kernel module is not enabled.
* No Haproxy to mask master-slave differences, and each node in the cluster is no longer "**idempotent**".





## Consul DNS

### Solution Description

L2 VIPs are not always available, especially since the requirement that all candidate master libraries must **be located on the same Layer 2 network** may not always be met.

In such cases, DNS resolution can be used instead of L2 VIP for

### Solution Superiority

* One less hop

### Solution Limitations

* Reliance on Consul DNS
* User needs to configure DNS caching policy properly





## Static DNS

### Solution Introduction

Traditional static DNS access method

### Advantages of the solution

* One less hop
* Simple implementation

### Solution Limitations

* No flexibility
* Prone to traffic loss during master-slave switching





## IP

### Solution Introduction

Direct database IP access using smart clients

### Solution advantages

* Direct connection to database/connection pool, one less
* No reliance on additional components for master-slave differentiation, reducing system complexity.

### Solution limitations

* Too inflexible, cumbersome to expand and reduce cluster capacity.





