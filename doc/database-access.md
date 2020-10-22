# Database Access  [DRAFT]

You can access provisioned database cluster via different approach. Take standard demo as an example:

* If you want ultimate performance and complete database features, connect to 5432 (or haproxy, routes to 5432)
* If you have thousands of perishable connections, using pgbouncer via 6432 (or haproxy, routes to 6432, default).
* If you wish to connect to cluster primary via any cluster member, using haproxy primary via 5433 (to primary 5432/6432).
* If you wish to connect to cluster replica via any cluster member, using haproxy replica via 5434  (to replicas 5432/6432)

```ini
VIP:              10.10.10.3 → active_primary([10.10.10.11, 10.10.10.12, 10.10.10.13])
DNS:              pg-test  → 10.10.10.3 (VIP)
                  pg-test-primary → active_primary([10.10.10.11, 10.10.10.12, 10.10.10.13])
                  pg-test-replica → active_replicas([10.10.10.11, 10.10.10.12, 10.10.10.13]) 
 
Primary Raw:      postgres://10.10.10.11
Primary Raw Pool: postgres://10.10.10.11:6432
Primary Raw Auto: postgres://10.10.10.11,10.10.10.12,10.10.10.13?target_session_attrs=read-write
Primary VIP:      postgres://10.10.10.2
Primary Proxy:    postgres://10.10.10.11:5433 , postgres://10.10.10.12:5433, postgres://10.10.10.13:5433
Primary DNS:      postgres://pg-test ,  postgres://pg-test:5433, postgres://pg-test-primary

Replica Raw:      postgres://10.10.10.12,      postgres://10.10.10.13
Replica Raw Pool: postgres://10.10.10.12:6432, postgres://10.10.10.13:6432
Replica Raw Auto: postgres://10.10.10.11,10.10.10.12,10.10.10.13:5432
Replica Proxy:    postgres://10.10.10.11:5434 , postgres://10.10.10.12:5434, postgres://10.10.10.13:5434
Replica DNS:      postgres://pg-test:5434, postgres://pg-test-replica
```

Default VIP for `pg-meta` is `10.10.10.2` , and default VIP for `pg-test` is `10.10.10.3`.





## 访问数据库

用户可以通过多种方式访问数据库服务

在实例层次，可以通过5432端口直连Postgres数据库，也可以通过6432端口经由Pgbouncer访问数据库。即可以通过IP地址直接访问，也可以通过节点域名解析访问。

在集群层次，每个集群带有一个可选的绑定至主库所在节点的VIP。可以通过VIP访问主库实例。同时，集群中的所有成员都运行有无状态的Haproxy负载均衡器。访问任意一个Haproxy实例都可以将只读流量与读写流量路由至集群的对应实例上。Haproxy本身的高可用亦通过绑定在主库的VIP实现。

![](/Users/vonng/pigsty/doc/img/proxy.png)

