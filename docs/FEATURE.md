# Features

Pigsty is a **Me-Better, Battery-Included, Open-Source RDS PG Alternative**:

- [Battery-Included RDS](#battery-included-rds): Delivers production-ready PostgreSQL services from version 12-16 on Linux x86, spanning kernel to RDS distribution.
- [Plentiful Extensions](#plentiful-extensions): Integrates 150+ extensions, providing turnkey capabilities for time-series, geospatial, full-text-search, vector and more!
- [Flexible Architecture](#flexible-architecture): Compose Redis/Etcd/MinIO/Mongo modules on nodes, monitoring existing cluster and remote RDS, self hosting Supabase/PostgresML.
- [Stunning Observability](#stunning-observability): Leveraging the Prometheus/Grafana modern observability stack, and provides unmatched database insights.
- [Proven Reliability](#proven-reliability): Self-healing HA architecture with automatic failover and uninterrupted client access, and auto-configured PITR.
- [Great Maintainability](#great-maintainability): Declarative API, GitOps ready, foolproof design, Database/Infra-as-Code, and management SOP seals complexity!
- [Sound Security](#sound-security): Nothing needs to be worried about database security, as long as your hardware & credentials are safe.
- [Versatile Application](#versatile-application): Lots of applications work well with PostgreSQL. Run them in one command with docker.
- [Open Source & Free](#open-source-amp-free): Pigsty is a free & open source software under AGPLv3. It was built for PostgreSQL with love.

[![pigsty-home.jpg](https://repo.pigsty.cc/img/pigsty-home.jpg)](https://demo.pigsty.cc)


----------------

## Battery-Included RDS

**Run production-grade RDS for PostgreSQL on your own machine in 10 minutes!**

While PostgreSQL shines as a database kernel, it excels as a Relational Database [Service](PGSQL-SVC#service-overview) (RDS) with Pigsty's touch.

Pigsty is compatible with PostgreSQL 12-16 and runs seamlessly on EL 7, 8, 9, Debian 11/12, Ubuntu 20/22 and similar [OS](README#compatibility) distributions.
It integrates the kernel with a rich set of extensions, provides all the essentials for a production-ready RDS, an entire set of infrastructure runtime coupled with fully automated deployment playbooks.
With everything bundled for offline installation without internet connectivity.

You can transit from a fresh node to a production-ready state effortlessly, deploy a top-tier PostgreSQL RDS service in a mere 10 minutes.
Pigsty will tune parameters to your hardware, handling everything from kernel, extensions, pooling, load balancing, high-availability, monitoring & logging, backups & PITR, security and more!
All you need to do is run the command and connect with the given URL.

[![pigsty-arch.jpg](https://repo.pigsty.cc/img/pigsty-arch.jpg)](ARCH.md#singleton-meta)




----------------

## Plentiful Extensions

**Harness the might of the most advanced Open-Source RDBMS or the world!**

PostgreSQL's has an unique [extension](PGSQL-EXTENSION#extension-list) ecosystem. Pigsty seamlessly integrates these powerful extensions, delivering turnkey distributed solutions for time-series, geospatial, and vector capabilities.

Pigsty boasts over **150** PostgreSQL extensions, and maintaining some not found in official PGDG repositories. Rigorous testing ensures flawless integration for **core** extensions: Leverage [PostGIS](https://postgis.net/) for geospatial data, [TimescaleDB](https://www.timescale.com/) for time-series analysis, [Citus](https://www.citusdata.com/) for horizontal scale out, [PGVector](https://github.com/pgvector/pgvector) for AI embeddings, [Apache AGE](https://age.apache.org/) for graph data, and [zhparser](https://github.com/amutu/zhparser) for Full-Text Search.

You can also run self-hosted [Supabase](https://github.com/Vonng/pigsty/tree/master/app/supabase/README.md) & [PostgresML](https://github.com/Vonng/pigsty/tree/master/app/pgml) with Pigsty managed HA PostgreSQL. If you want to add your own extension, feel free to [suggest](https://github.com/Vonng/pigsty/discussions/333) or [compile](PGSQL-EXTENSION.md#compile-extension) it by yourself.

[![pigsty-distro.jpg](https://repo.pigsty.cc/img/pigsty-distro.jpg)](PGSQL-EXTENSION.md)




----------------

## Flexible Architecture

**modular design, composable, Redis/MinIO/Etcd/Mongo support, and monitoring existing PG & RDS**

All functionality is abstracted as [Modules](ARCH.md#modules) that can be freely composed for different scenarios.
[`INFRA`](INFRA.md) gives you a modern observability stack, while [`NODE`](NODE.md) can be used for host monitoring.
Installing the [`PGSQL`](PGSQL.md) module on multiple nodes will automatically form a HA cluster.

And you can also have dedicated [`ETCD`](ETCD.md) clusters for distributed consensus & [`MinIO`](MINIO.md) clusters for backup storage.
[`REDIS`](REDIS.md) are also supported since they work well with PostgreSQL.
You can reuse Pigsty infra and extend it with your Modules (e.g. `GPSQL`, `KAFKA`, `MONGO`, `MYSQL`...).

Moreover, Pigsty's `INFRA` module can be used alone — ideal for monitoring hosts, databases, or cloud [RDS](PGSQL-MONITOR#monitor-rds).


[![pigsty-sandbox.jpg](https://repo.pigsty.cc/img/sandbox.jpg)](ARCH.md#模块)




----------------

## Stunning Observability

**Unparalleled monitoring system based on modern observability stack and open-source best-practice!**

Pigsty will automatically monitor any newly deployed components such as Node, Docker, HAProxy, Postgres, Patroni, Pgbouncer, Redis, Minio, and itself. There are 30+ default dashboards and pre-configured alerting rules, which will upgrade your system's observability to a whole new level. Of course, it can be used as your application monitoring infrastructure too.

There are over 3K+ metrics that describe every aspect of your environment, from the topmost overview dashboard to a detailed table/index/func/seq. As a result, you can have complete insight into the past, present, and future. 

Check the [dashboard gallery](https://github.com/Vonng/pigsty/wiki/Gallery) and [public demo](https://demo.pigsty.cc) for more details.

[![pigsty-dashboard.jpg](https://repo.pigsty.cc/img/pigsty-dashboard.jpg)](https://github.com/Vonng/pigsty/wiki/Gallery)



----------------

## Proven Reliability

**Pigsty has pre-configured HA & PITR for PostgreSQL to ensure your database service is always reliable.**

Hardware failures are covered by self-healing HA architecture powered by `patroni`, `etcd`, and `haproxy`, which will perform auto failover in case of leader failure (RTO < 30s), and there will be no data loss (RPO = 0) in **sync** mode. Moreover, with the self-healing traffic control proxy, the client may not even notice a switchover/replica failure. 

Software Failures, human errors, and Data Center Failures are covered with Cold backups & PITR, which are implemented with `pgBackRest`. It allows you to travel time to any point in your database's history as long as your storage is capable. You can store them in the local backup disk, built-in MinIO cluster, or S3 service.

Large organizations have used Pigsty for several years. One of the largest deployments has 25K CPU cores and 200+ massive PostgreSQL instances. In the past three years, there have been dozens of hardware failures & incidents, but the overall availability remains several nines (99.999% +).

[![pgsql-ha.jpg](https://repo.pigsty.cc/img/pgsql-ha.jpg)](PGSQL-ARCH.md#high-availability)



----------------

## Great Maintainability

**Infra as Code, Database as Code, Declarative API & Idempotent Playbooks, GitOPS works like a charm.**

Pigsty provides a **declarative** interface: Describe everything in a config file, and Pigsty operates it to the desired state. It works like Kubernetes CRDs & Operators but for databases and infrastructures on any nodes: bare metal or virtual machines. 

To create cluster/database/user/extension, expose services, or add replicas. All you need to do is to modify the cluster definition and run the idempotent playbook. Databases & Nodes are tuned automatically according to their hardware specs, and monitoring & alerting is pre-configured. As a result, database administration becomes much more manageable. 

Pigsty has a full-featured sandbox powered by **Vagrant**, a pre-configured one or 4-node environment for testing & demonstration purposes. You can also provision required IaaS resources from cloud vendors with **Terraform** templates.

[![pigsty-iac.jpg](https://repo.pigsty.cc/img/pigsty-iac.jpg)](CONFIG.md)



----------------

## Sound Security

**Nothing needs to be worried about database security, as long as your hardware & credentials are safe.**

Pigsty use SSL for API & network traffic, Encryption for password & backups, HBA rules for host & clients, and access control for users & objects.

Pigsty has an easy-to-use, fine-grained, and fully customizable [access control](PGSQL-ACL) framework based on roles, privileges, and HBA rules. It has four default roles: read-only, read-write, admin (DDL), offline (ETL), and four default users: dbsu, replicator, monitor, and admin. Newly created database objects will have proper default privileges for those roles. And client access is restricted by a set of [HBA](PGSQL-HBA) rules that follows the least privilege principle.

Your entire network communication can be secured with SSL. Pigsty will automatically create a self-signed CA and issue certs for that. Database credentials are encrypted with the scram-sha-256 algorithm, and cold backups are encrypted with the AES-256 algorithm when using MinIO/S3. Admin Pages and dangerous APIs are protected with HTTPS, and access is restricted from specific admin/infra nodes.

[![pigsty-acl.jpg](https://repo.pigsty.cc/img/pigsty-acl.jpg)](SECURITY.md)



----------------

## Versatile Application

**Lots of applications work well with PostgreSQL. Run them in one command with docker.**

The database is usually the most tricky part of most software. Since Pigsty already provides the RDS. It could be nice to have a series of docker templates to run software in stateless mode and persist their data with Pigsty-managed HA PostgreSQL (or Redis, MinIO), including Gitlab, Gitea, Wiki.js, NocoDB, Odoo, Jira, Confluence, Harbour, Mastodon, Discourse, and KeyCloak.

Pigsty also provides a toolset to help you manage your database and build data applications in a low-code fashion: PGAdmin4, PGWeb, ByteBase, PostgREST, Kong, and higher "Database" that use Postgres as underlying storage, such as EdgeDB, FerretDB, and Supabase. And since you already have Grafana & Postgres, You can quickly make an interactive data application demo with them. In addition, advanced visualization can be achieved with the built-in ECharts panel.

[![pigsty-app.jpg](https://repo.pigsty.cc/img/pigsty-app.jpg)](APP.md)




----------------

## Open Source & Free

**Pigsty is a free & open source software under AGPLv3. It was built for PostgreSQL with love.**

Pigsty allows you to run production-grade RDS on **your** hardware without suffering from human resources. As a result, you can achieve the same or even better reliability & performance & maintainability with only 5% ~ 40% cost compared to Cloud RDS PG. As a result, you may have an RDS with a lower price even than ECS.

There will be no vendor lock-in, annoying license fee, and node/CPU/core limit. You can have as many RDS as possible and run them as long as possible. All your data belongs to you and is under your control.

Pigsty is free software under AGPLv3. It's free of charge, but beware that freedom is not free, so use it at your own risk! It's not very difficult, and we are glad to help. For those enterprise users who seek professional consulting services, we do have a subscription for that.

[![pigsty-price.jpg](https://repo.pigsty.cc/img/pigsty-price.jpg)](SUPPORT)

