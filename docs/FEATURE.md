# Features

Pigsty is a **Me-Better Open Source RDS Alternative** with:

- Battery-Included [PostgreSQL](https://www.postgresql.org/) Distribution, with [PostGIS](https://postgis.net/), [TimescaleDB](https://www.timescale.com/), [Citus](https://www.citusdata.com/), [PGVector](https://github.com/pgvector/pgvector) ...
- Incredible observability powered by [Prometheus](https://prometheus.io/) & [Grafana](https://grafana.com/) stack.
- Self-healing HA PGSQL cluster, powered by [patroni](https://patroni.readthedocs.io/en/latest/), [haproxy](http://www.haproxy.org/), [etcd](https://etcd.io/)...
- Auto-Configured PITR, powered by [pgbackrest](https://pgbackrest.org/) and optional [MinIO](https://min.io/) cluster
- Declarative API, Database-as-Code implemented with [Ansible](https://www.ansible.com/) playbooks.
- Versatile UseCases, Run [Docker](https://www.docker.com/) Apps, Run demos, Visualize data with [ECharts](https://echarts.apache.org/).
- Handy Tools, provision IaaS with [Terraform](https://www.terraform.io/), and try with local [Vagrant](https://www.vagrantup.com/) sandbox.
- Run [Redis](https://redis.io/) (standalone, sentinel, cluster), MinIO, Etcd, Haproxy, MongoDB([FerretDB](https://www.ferretdb.io/)) clusters


----------------

## Powerful Distribution

**Unleash the power of The World's Most Advanced Open Source Relational Database!**

PostgreSQL is a great database kernel but needs more to become a good enough Relational Database Service (RDS). And Pigsty helps you with that.

You can have all the powerful features of PostgreSQL ecosystem at once: Handle spatial data with **PostGIS**, analyze time-series and event stream with **TimescaleDB**, scale out with **Citus**, and search AI embedding with **PGVector**, and more...
It delivers all the software toolkits required to run a production-grade RDS and ansible playbooks to orchestrate them. Everything can be installed in one line of code, and all dependencies are packed into offline installation packages to eliminate Internet access.

All functionality is abstracted as Modules that can be freely composed for different scenarios. [`INFRA`](INFRA.md) gives you a modern observability stack, while [`NODE`](NODE.md) can be used for host monitoring. Installing the [`PGSQL`](PGSQL.md) module on multiple nodes will automatically form a HA cluster. And you can also have dedicated [`ETCD`](ETCD.md) clusters for distributed consensus & [`MinIO`](MINIO.md) clusters for backup storage. [`REDIS`](REDIS.md) are also supported since they work well with PostgreSQL. You can reuse Pigsty infra and extend it with your Modules (e.g. `GPSQL`, `KAFKA`, `MONGO`, `MYSQL`...).

[![pigsty-distro](https://user-images.githubusercontent.com/8587410/226076217-77e76e0c-94ac-4faa-9014-877b4a180e09.jpg)](PGSQL.md)




----------------

## Incredible Observability

**Unparalleled monitoring system based on modern observability stack and open-source best-practice!**

Pigsty will automatically monitor any newly deployed components such as Node, Docker, HAProxy, Postgres, Patroni, Pgbouncer, Redis, Minio, and itself. There are 30+ default dashboards and pre-configured alerting rules, which will upgrade your system's observability to a whole new level. Of course, it can be used as your application monitoring infrastructure too.

There are over 3K+ metrics that describe every aspect of your environment, from the topmost overview dashboard to a detailed table/index/func/seq. As a result, you can have complete insight into the past, present, and future. 

Check the [dashboard gallery](https://github.com/Vonng/pigsty/wiki/Gallery) and [public demo](https://demo.pigsty.cc) for more details.

[![Dashboards](https://github-production-user-asset-6210df.s3.amazonaws.com/8587410/258681605-cf6b99e5-9c8f-4db2-9bce-9ded95407c0c.jpg)](https://github.com/Vonng/pigsty/wiki/Gallery)



----------------

## Proven Reliability

**Pigsty has pre-configured HA & PITR for PostgreSQL to ensure your database service is always reliable.**

Hardware failures are covered by self-healing HA architecture powered by `patroni`, `etcd`, and `haproxy`, which will perform auto failover in case of leader failure (RTO < 30s), and there will be no data loss (RPO = 0) in **sync** mode. Moreover, with the self-healing traffic control proxy, the client may not even notice a switchover/replica failure. 

Software Failures, human errors, and Data Center Failures are covered with Cold backups & PITR, which are implemented with `pgBackRest`. It allows you to travel time to any point in your database's history as long as your storage is capable. You can store them in the local backup disk, built-in MinIO cluster, or S3 service.

Large organizations have used Pigsty for several years. One of the largest deployments has 25K CPU cores and 200+ massive PostgreSQL instances. In the past three years, there have been dozens of hardware failures & incidents, but the overall availability remains several nines (99.999% +).

[![pigsty-ha](https://user-images.githubusercontent.com/8587410/206971583-74293d7b-d29a-4ca2-8728-75d50421c371.gif)](PGSQL-ARCH.md#high-availability)



----------------

## Great Maintainability

**Infra as Code, Database as Code, Declarative API & Idempotent Playbooks, GitOPS works like a charm.**

Pigsty provides a **declarative** interface: Describe everything in a config file, and Pigsty operates it to the desired state. It works like Kubernetes CRDs & Operators but for databases and infrastructures on any nodes: bare metal or virtual machines. 

To create cluster/database/user/extension, expose services, or add replicas. All you need to do is to modify the cluster definition and run the idempotent playbook. Databases & Nodes are tuned automatically according to their hardware specs, and monitoring & alerting is pre-configured. As a result, database administration becomes much more manageable. 

Pigsty has a full-featured sandbox powered by **Vagrant**, a pre-configured one or 4-node environment for testing & demonstration purposes. You can also provision required IaaS resources from cloud vendors with **Terraform** templates.

[![pigsty-iac](https://user-images.githubusercontent.com/8587410/206972039-e13746ab-72ae-4cab-8de7-7b2ef543f3e5.gif)](CONFIG.md)



----------------

## Sound Security

**Nothing needs to be worried about database security, as long as your hardware & credentials are safe.**

Pigsty use SSL for API & network traffic, Encryption for password & backups, HBA rules for host & clients, and access control for users & objects.

Pigsty has an easy-to-use, fine-grained, and fully customizable [access control](PGSQL-ACL) framework based on roles, privileges, and HBA rules. It has four default roles: read-only, read-write, admin (DDL), offline (ETL), and four default users: dbsu, replicator, monitor, and admin. Newly created database objects will have proper default privileges for those roles. And client access is restricted by a set of [HBA](PGSQL-HBA) rules that follows the least privilege principle.

Your entire network communication can be secured with SSL. Pigsty will automatically create a self-signed CA and issue certs for that. Database credentials are encrypted with the scram-sha-256 algorithm, and cold backups are encrypted with the AES-256 algorithm when using MinIO/S3. Admin Pages and dangerous APIs are protected with HTTPS, and access is restricted from specific admin/infra nodes.

[![pigsty-dashboard2](https://user-images.githubusercontent.com/8587410/198838841-b0796703-03c3-483b-bf52-dbef9ea10913.gif)](SECURITY.md)



----------------

## Versatile Application

**Lots of applications work well with PostgreSQL. Run them in one command with docker.**

The database is usually the most tricky part of most software. Since Pigsty already provides the RDS. It could be nice to have a series of docker templates to run software in stateless mode and persist their data with Pigsty-managed HA PostgreSQL (or Redis, MinIO), including Gitlab, Gitea, Wiki.js, NocoDB, Odoo, Jira, Confluence, Harbour, Mastodon, Discourse, and KeyCloak.

Pigsty also provides a toolset to help you manage your database and build data applications in a low-code fashion: PGAdmin4, PGWeb, ByteBase, PostgREST, Kong, and higher "Database" that use Postgres as underlying storage, such as EdgeDB, FerretDB, and Supabase. And since you already have Grafana & Postgres, You can quickly make an interactive data application demo with them. In addition, advanced visualization can be achieved with the built-in ECharts panel.

[![pigsty-app](https://user-images.githubusercontent.com/8587410/198838829-f0ea4af2-d33f-4978-a31a-ed81897aa8d1.gif)](APP.md)

  > If your software requires a PostgreSQL, Pigsty may be the easiest way to get one.



----------------

## Open Source & Free

**Pigsty is a free & open source software under AGPLv3. It was built for PostgreSQL with love.**

Pigsty allows you to run production-grade RDS on **your** hardware without suffering from human resources. As a result, you can achieve the same or even better reliability & performance & maintainability with only 5% ~ 40% cost compared to Cloud RDS PG. As a result, you may have an RDS with a lower price even than ECS.

There will be no vendor lock-in, annoying license fee, and node/CPU/core limit. You can have as many RDS as possible and run them as long as possible. All your data belongs to you and is under your control.

Pigsty is free software under AGPLv3. It's free of charge, but beware that freedom is not free, so use it at your own risk! It's not very difficult, and we are glad to help. For those enterprise users who seek professional consulting services, we do have a subscription for that.

[![pigsty-rds-cost](https://user-images.githubusercontent.com/8587410/225852971-577be00f-b2df-427c-a590-f8b4c5a63a4b.png)](https://instances.vantage.sh/)

