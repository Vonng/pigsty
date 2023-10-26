# Architecture

> Modular Architecture and Declarative Interface!

* Pigsty deployment is described by config inventory and materialized with ansible playbooks.
* Pigsty works on [Linux](INSTALL#requirement) x86_64 common nodes, i.e., bare metals or virtual machines.
* Pigsty uses a modular design that can be freely composed for different scenarios.
* The config controls **where** & **how** to install modules with **parameters**
* The playbooks will adjust nodes into the desired status in an idempotent manner.


----------------

## Modules

Pigsty uses a modular design, and there are six default modules: [`PGSQL`](PGSQL), [`INFRA`](INFRA), [`NODE`](NODE), [`ETCD`](ETCD), [`REDIS`](REDIS), and [`MINIO`](MINIO).

* [`PGSQL`](PGSQL): Autonomous ha Postgres cluster powered by Patroni, Pgbouncer, HAproxy, PgBackrest, etc...
* [`INFRA`](INFRA): Local yum/apt repo, Prometheus, Grafana, Loki, AlertManager, PushGateway, Blackbox Exporter...
* [`NODE`](NODE): Tune node to desired state, name, timezone, NTP, ssh, sudo, haproxy, docker, promtail, keepalived
* [`ETCD`](ETCD): Distributed key-value store will be used as DCS for high-available Postgres clusters.
* [`REDIS`](REDIS): Redis servers in standalone master-replica, sentinel, cluster mode with Redis exporter.
* [`MINIO`](MINIO): S3 compatible simple object storage server, can be used as an optional backup center for Postgres.

You can compose them freely in a declarative manner. If you want host monitoring, [`INFRA`](INFRA) & [`NODE`](NODE) will suffice. Add additional [`ETCD`](ETCD) and [`PGSQL`](PGSQL) are used for HA PG Clusters. Deploying them on multiple nodes will form a ha cluster. You can reuse pigsty infra and develop your modules, considering optional [`REDIS`](REDIS) and [`MINIO`](MINIO) as examples.

[![pigsty-sandbox.jpg](https://repo.pigsty.cc/img/pigsty-sandbox.jpg)](PROVISION)



----------------

## Singleton Meta

Pigsty will install on a single **node** (BareMetal / VirtualMachine) by default. The [`install.yml`](https://github.com/Vonng/pigsty/blob/master/install.yml) playbook will install [`INFRA`](INFRA), [`ETCD`](ETCD),  [`PGSQL`](PGSQL), and optional [`MINIO`](MINIO) modules on the **current** node, which will give you a full-featured observability infrastructure (Prometheus, Grafana, Loki, AlertManager, PushGateway, BlackboxExporter, etc... ) and a battery-included PostgreSQL Singleton Instance (Named `meta`).

This node now has a self-monitoring system, visualization toolsets, and a  Postgres database with autoconfigured PITR. You can use this node for devbox, testing, running demos, and doing data visualization & analysis. Or, furthermore, adding more nodes to it!

[![pigsty-arch.jpg](https://repo.pigsty.cc/img/pigsty-arch.jpg)](INFRA)



----------------

## Monitoring

The installed [Singleton Meta](#singleton-meta) can be use as an **admin node** and **monitoring center**, to take more nodes & Database servers under it's surveillance & control. 

If you want to install the Prometheus / Grafana observability stack, Pigsty just deliver the best practice for you! It has fine-grained dashboards for [Nodes](https://demo.pigsty.cc/d/node-overview) & [PostgreSQL](https://demo.pigsty.cc/d/pgsql-overview), no matter these nodes or PostgreSQL servers are managed by Pigsty or not, you can have a production-grade monitoring & alerting immediately with simple configuration.

[![pigsty-dashboard.jpg](https://repo.pigsty.cc/img/pigsty-dashboard.jpg)](PGSQL-DASHBOARD)



----------------

## HA PG Cluster

With Pigsty, you can have your own local production-grade HA PostgreSQL RDS as much as you want.

And to create such a HA PostgreSQL cluster, All you have to do is describe it & run the playbook:

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
    10.10.10.13: { pg_seq: 3, pg_role: replica }
  vars: { pg_cluster: pg-test }
```

```bash
$ bin/pgsql-add pg-test  # init cluster 'pg-test'
```

Which will gives you a following cluster with monitoring , replica, backup all set.

[![pgsql-ha.jpg](https://repo.pigsty.cc/img/pgsql-ha.jpg)](PGSQL-ARCH)

Hardware failures are covered by self-healing HA architecture powered by `patroni`, `etcd`, and `haproxy`, which will perform auto failover in case of leader failure under 30 seconds.  With the self-healing traffic control powered by haproxy, the client may not even notice there's a failure at all, in case of a switchover or replica failure.

Software Failures, human errors, and DC Failure are covered by `pgbackrest`, and optional `MinIO` clusters. Which gives you the ability to perform point-in-time recovery to anytime (as long as your storage is capable)



----------------

## Database as Code

Pigsty follows IaC & GitOPS philosophy: Pigsty deployment is described by declarative [Config Inventory](config#inventory) and materialized with idempotent playbooks.

The user describes the desired status with [Parameters](PARAM) in a declarative manner, and the playbooks tune target nodes into that status in an idempotent manner. It's like Kubernetes CRD & Operator but works on Bare Metals & Virtual Machines.

[![pigsty-iac.jpg](https://repo.pigsty.cc/img/pigsty-iac.jpg)](CONFIG)

Take the default config snippet as an example, which describes a node `10.10.10.10` with modules [`INFRA`](INFRA), [`NODE`](NODE), [`ETCD`](ETCD), and [`PGSQL`](PGSQL) installed.

```yaml
# infra cluster for proxy, monitor, alert, etc...
infra: { hosts: { 10.10.10.10: { infra_seq: 1 } } }

# minio cluster, s3 compatible object storage
minio: { hosts: { 10.10.10.10: { minio_seq: 1 } }, vars: { minio_cluster: minio } }

# etcd cluster for ha postgres DCS
etcd: { hosts: { 10.10.10.10: { etcd_seq: 1 } }, vars: { etcd_cluster: etcd } }

# postgres example cluster: pg-meta
pg-meta: { hosts: { 10.10.10.10: { pg_seq: 1, pg_role: primary }, vars: { pg_cluster: pg-meta } }
```

To materialize it, use the following playbooks:

```bash
./infra.yml -l infra    # init infra module on group 'infra'
./etcd.yml  -l etcd     # init etcd module on group 'etcd'
./minio.yml -l minio    # init minio module on group 'minio'
./pgsql.yml -l pg-meta  # init pgsql module on group 'pgsql'
```

It would be straightforward to perform regular administration tasks. For example, if you wish to add a new replica/database/user to an existing HA PostgreSQL cluster, all you need to do is add a host in config & run that playbook on it, such as:

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
    10.10.10.13: { pg_seq: 3, pg_role: replica } # <-- add new instance
  vars: { pg_cluster: pg-test }
```

```bash
$ bin/pgsql-add  pg-test 10.10.10.13
```

You can even manage many PostgreSQL Entities using this approach: User/Role, Database, Service, HBA Rules, Extensions, Schemas, etc...

Check [PGSQL Conf](pgsql-conf) for details.
