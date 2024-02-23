# PGSQL Architecture

> Overview of the PGSQL module and key concepts 

PGSQL for production environments is organized in **clusters**, which **clusters** are **logical entities** consisting of a set of database **instances** associated by **primary-replica**. 
Each **database cluster** is an autonomous serving unit consisting of at least one  **database instance** (primary).


----------------

## ER Diagram

Let's get started with ER diagram. There are four types of core entities in Pigsty's PGSQL module:

* **PGSQL Cluster**: An autonomous PostgreSQL business unit, used as the top-level namespace for other entities.
* **PGSQL Service**: A named abstraction of cluster ability, route traffics, and expose postgres services with node ports.
* **PGSQL Instance**: A single postgres server which is a group of running processes & database files on a single node.
* **PGSQL Node**: An abstraction of hardware resources, which can be bare metal, virtual machine, or even k8s pods.

![pgsql-er.jpg](https://repo.pigsty.cc/img/pgsql-er.jpg)

**Naming Convention**

* The cluster name should be a valid domain name, without any dot: `[a-zA-Z0-9-]+`
* Service name should be prefixed with cluster name, and suffixed with a single word: such as `primary`, `replica`, `offline`, `delayed`, join by `-`
* Instance name is prefixed with cluster name and suffixed with an integer, join by `-`, e.g., `${cluster}-${seq}`.
* Node is identified by its IP address, and its hostname is usually the same as the instance name since they are 1:1 deployed.




----------------

## Identity Parameter

Pigsty uses **identity parameters** to identify entities: [`PG_ID`](PARAM#pg_id).

In addition to the node IP address, three parameters: [`pg_cluster`](PARAM#pg_cluster), [`pg_role`](PARAM#pg_role), and [`pg_seq`](PARAM#pg_seq) are the minimum set of parameters necessary to define a postgres cluster.
Take the [sandbox](PROVISION#sandbox) testing cluster `pg-test` as an example:

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
    10.10.10.13: { pg_seq: 3, pg_role: replica }
  vars:
    pg_cluster: pg-test
```

The three members of the cluster are identified as follows.

|  cluster  | seq |   role    |   host / ip   |  instance   |      service      |  nodename   |
|:---------:|:---:|:---------:|:-------------:|:-----------:|:-----------------:|:-----------:|
| `pg-test` | `1` | `primary` | `10.10.10.11` | `pg-test-1` | `pg-test-primary` | `pg-test-1` |
| `pg-test` | `2` | `replica` | `10.10.10.12` | `pg-test-2` | `pg-test-replica` | `pg-test-2` |
| `pg-test` | `3` | `replica` | `10.10.10.13` | `pg-test-3` | `pg-test-replica` | `pg-test-3` |

There are:

* One Cluster: The cluster is named as `pg-test`.
* Two Roles: `primary` and `replica`.
* Three Instances: The cluster consists of three instances: `pg-test-1`, `pg-test-2`, `pg-test-3`.
* Three Nodes: The cluster is deployed on three nodes: `10.10.10.11`, `10.10.10.12`, and `10.10.10.13`.
* Four services:
  *  read-write service:  [`pg-test-primary`](PGSQL-SVC#primary-service)
  * read-only service: [`pg-test-replica`](PGSQL-SVC#replica-service)
  * directly connected management service: [`pg-test-default`](PGSQL-SVC#default-service)
  * offline read service: [`pg-test-offline`](PGSQL-SVC#offline-service)

And in the monitoring system (Prometheus/Grafana/Loki), corresponding metrics will be labeled with these identities：

```yaml
pg_up{cls="pg-meta", ins="pg-meta-1", ip="10.10.10.10", job="pgsql"}
pg_up{cls="pg-test", ins="pg-test-1", ip="10.10.10.11", job="pgsql"}
pg_up{cls="pg-test", ins="pg-test-2", ip="10.10.10.12", job="pgsql"}
pg_up{cls="pg-test", ins="pg-test-3", ip="10.10.10.13", job="pgsql"}
```




----------------

## Component Overview

Here is how PostgreSQL module components and their interactions. From top to bottom:

* Cluster DNS is resolved by DNSMASQ on infra nodes
* Cluster VIP is manged by `vip-manager`, which will bind to cluster primary. 
  * `vip-manager` will acquire cluster leader info written by `patroni` from `etcd` cluster directly
* Cluster services are exposed by Haproxy on nodes, services are distinguished by node ports (543x).
  * Haproxy port 9101: monitoring metrics & stats & admin page
  * Haproxy port 5433: default service that routes to primary pgbouncer: [primary](PGSQL-SVC#primary-service)
  * Haproxy port 5434: default service that routes to replica pgbouncer: [replica](PGSQL-SVC#replica-service)
  * Haproxy port 5436: default service that routes to primary postgres: [default](PGSQL-SVC#default-service)
  * Haproxy port 5438: default service that routeroutesto offline postgres: [offline](PGSQL-SVC#offline-service)
  * HAProxy will route traffic based on health check information provided by `patroni`. 
* Pgbouncer is a connection pool middleware that buffers connections, exposes extra metrics, and brings extra flexibility @ port 6432
  * Pgbouncer is stateless and deployed with the Postgres server in a 1:1 manner through a local unix socket.
  * Production traffic (Primary/Replica) will go through pgbouncer by default (can be skipped by [`pg_default_service_dest`](PARAM#pg_default_service_dest) ) 
  * Default/Offline service will always bypass pgbouncer and connect to target Postgres directly.
* Postgres provides relational database services @ port 5432
  * Install PGSQL module on multiple nodes will automatically form a HA cluster based on streaming replication
  * PostgreSQL is supervised by `patroni` by default.
* Patroni will **supervise** PostgreSQL server @ port 8008 by default
  * Patroni spawn postgres servers as the child process
  * Patroni uses `etcd` as DCS: config storage, failure detection, and leader election.
  * Patroni will provide Postgres information through a health check. Which is used by HAProxy
  * Patroni metrics will be scraped by prometheus on infra nodes
* PG Exporter will expose postgres metrics @ port 9630
  * PostgreSQL's metrics will be scraped by prometheus on infra nodes
* Pgbouncer Exporter will expose pgbouncer metrics @ port 9631
  * Pgbouncer's metrics will be scraped by prometheus on infra nodes
* pgBackRest will work on the local repo by default ([`pgbackrest_method`](PARAM#pgbackrest_method))
  * If `local` (default) is used as the backup repo, pgBackRest will create local repo under the primary's [`pg_fs_bkup`](PARAM#pg_fs_bkup) 
  * If `minio` is used as the backup repo, pgBackRest will create the repo on the dedicated MinIO cluster in [`pgbackrest_repo`.`minio`](PARAM#pgbackrest_repo)
* Postgres-related logs (postgres,pgbouncer,patroni,pgbackrest) are exposed by promtail @ port 9080
  * Promtail will send logs to Loki on infra nodes

[![pigsty-arch.jpg](https://repo.pigsty.cc/img/pigsty-arch.jpg)](INFRA)



----------------

## High Availability

> Primary Failure RTO ≈ 30s, RPO < 1MB, Replica Failure RTO≈0 (reset current conn)

Pigsty's PostgreSQL cluster has battery-included high-availability powered by [patroni](https://patroni.readthedocs.io/en/latest/), [etcd](https://etcd.io/), and [haproxy](http://www.haproxy.org/) 

![pgsql-ha.jpg](https://repo.pigsty.cc/img/pgsql-ha.jpg)

When the primary fails, one of the replicas will be promoted to primary automatically, and read-write traffic will be routed to the new primary immediately. The impact is: write queries will be blocked for 15 ~ 40s until the new leader is elected.

When a replica fails, read-only traffic will be routed to the other replicas, if all replicas fail, read-only traffic will fall back to the primary. The impact would be very small: a few running queries on that replica will abort due to a connection reset.

Failure detection is done by `patroni` and `etcd`, the leader will hold a lease, and if it fails, the lease will be released due to timeout, and the other instance will elect a new leader to take over.

The ttl can be tuned with [`pg_rto`](PARAM#pg_rto), which is 30s by default, increasing it will cause longer failover wait time, while decreasing it will increase the false-positive failover rate (e.g. network jitter).

Pigsty will use **availability first** mode by default, which means when primary fails, it will try to failover ASAP, data not replicated to the replica may be lost (usually 100KB), and the max potential data loss is controlled by [`pg_rpo`](PARAM#pg_rpo), which is 1MB by default. 


----------------

## Point-In-Time Recovery

> Rollback clusters to a past state to mitigate data loss from software bugs or human errors.

Pigsty's PostgreSQL cluster features auto-configured PITR, leveraging [pgBackRest](https://pgbackrest.org/) and, optionally, [MinIO](MINIO).

While high availability counters hardware failures, it's not effective against unintentional data deletions or overwrites: changes sync and apply to replicas instantly. PITR fill this gap. If operating a single instance, PITR can serve as a high availability substitute, providing a safety net.

For cluster rollback to a specific backup, users should maintain regular base backups. For rollbacks to arbitrary points, WAL archives since the last backup are required. Pigsty automates these with pgBackRest for backup management, WAL archiving, and PITR execution. 
Backup repositories are configurable ([`pgbackrest_repo`](PARAM#pgbackrest_repo)): defaulting to the primary's local file system (`local`), but alternatives include other disk paths, bundled [MinIO](MINIO) (`minio`), or cloud S3 services.

```yaml
pgbackrest_repo:                  # pgbackrest repo: https://pgbackrest.org/configuration.html#section-repository
  local:                          # default pgbackrest repo with local posix fs
    path: /pg/backup              # local backup directory, `/pg/backup` by default
    retention_full_type: count    # retention full backups by count
    retention_full: 2             # keep 2, at most 3 full backup when using local fs repo
  minio:                          # optional minio repo for pgbackrest
    type: s3                      # minio is s3-compatible, so s3 is used
    s3_endpoint: sss.pigsty       # minio endpoint domain name, `sss.pigsty` by default
    s3_region: us-east-1          # minio region, us-east-1 by default, useless for minio
    s3_bucket: pgsql              # minio bucket name, `pgsql` by default
    s3_key: pgbackrest            # minio user access key for pgbackrest
    s3_key_secret: S3User.Backup  # minio user secret key for pgbackrest
    s3_uri_style: path            # use path style uri for minio rather than host style
    path: /pgbackrest             # minio backup path, default is `/pgbackrest`
    storage_port: 9000            # minio port, 9000 by default
    storage_ca_file: /etc/pki/ca.crt  # minio ca file path, `/etc/pki/ca.crt` by default
    bundle: y                     # bundle small files into a single file
    cipher_type: aes-256-cbc      # enable AES encryption for remote backup repo
    cipher_pass: pgBackRest       # AES encryption password, default is 'pgBackRest'
    retention_full_type: time     # retention full backup by time on minio repo
    retention_full: 14            # keep full backup for last 14 days
```


Out-of-the-box, Pigsty has two [backup strategies](PGSQL-PITR#policy): local file system repository with daily full backups or dedicated MinIO/S3 storage with weekly full and daily incremental backups, retaining two weeks' worth by default.