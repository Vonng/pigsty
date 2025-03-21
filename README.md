# Pigsty

[![Webite: pigsty.io](https://img.shields.io/badge/website-pigsty.io-slategray?style=flat&logo=cilium&logoColor=white)](https://pigsty.io)
[![Docs](https://img.shields.io/badge/docs-slategray?style=flat&logo=cilium&logoColor=white)](https://pigsty.io/docs)
[![Version: v3.3.0](https://img.shields.io/badge/version-v3.3.0-slategray?style=flat&logo=cilium&logoColor=white)](https://github.com/pgsty/pigsty/releases/tag/v3.3.0)
[![License: AGPLv3](https://img.shields.io/github/license/pgsty/pigsty?logo=opensourceinitiative&logoColor=green&color=slategray)](https://pigsty.io/docs/about/license/)
[![GitHub Stars](https://img.shields.io/github/stars/pgsty/pigsty?style=flat&logo=github&logoColor=black&color=slategray)](https://star-history.com/#pgsty/pigsty&Date)
[![Extensions: 405](https://img.shields.io/badge/extensions-405-%233E668F?style=flat&logo=postgresql&logoColor=white&labelColor=3E668F)](https://pigsty.io/ext/list)

Battery-Included, Local-First **PostgreSQL** Distribution as a Free & Better **RDS** Alternative!

> "**P**ostgreSQL **I**n **G**reat **STY**le": **P**ostgres, **I**nfras, **G**raphics, **S**ervice, **T**oolbox, it's all **Y**ours.

[Website](https://pigsty.io/) | [Docs](https://pigsty.io/docs/) | [Extensions](https://pigsty.io/ext/) | [Demo](https://demo.pigsty.cc) | [Blog](https://pigsty.io/blog) | [Discuss](https://github.com/pgsty/pigsty/discussions) | [Support](https://pigsty.io/price) | [Extension](https://pigsty.io/about/ext) | [中文站](https://pigsty.cc) | [博客](https://pigsty.cc/blog)

[**Get Started**](https://pigsty.io/docs/setup/install/) with the latest [**v3.3.0**](https://github.com/pgsty/pigsty/releases/tag/v3.3.0): `curl -fsSL https://repo.pigsty.io/get`

[![pigsty-desc](https://pigsty.io/img/pigsty/banner.en.jpg)](https://pigsty.io)


--------

## Features

- [**Extensible**](https://pigsty.io/img/pigsty/extension.png): **405** [**PG Extensions**](https://pigsty.io/ext/list) & **6** [**PG Kernel**](https://pigsty.io/docs/kernel) replacements available (e.g., [**MSSQL**](https://pigsty.io/docs/kernel/babelfish/), [**Oracle**](https://pigsty.io/docs/kernel/ivorysql/) compatibility).
- [**Reliable**](https://pigsty.io/img/pigsty/arch.jpg): Self-healing [**HA**](https://pigsty.io/docs/concept/ha/) clusters with pre-configured [**PITR**](https://pigsty.io/docs/pgsql/arch#point-in-time-recovery) and built-in [**ACL**](https://pigsty.io/docs/pgsql/acl), [**CA & SSL**](https://pigsty.io/docs/reference/param/#ca) secure best practice.
- [**Observable**](https://pigsty.io/img/pigsty/dashboard.jpg): SOTA monitoring for [**PG**](https://demo.pigsty.cc/d/pgrds-instance/pgrds-instance) / [**Infra**](https://pigsty.io/docs/infra) / [**Node**](https://pigsty.io/docs/node) based on **Prometheus** & **Grafana** stack: [**Demo**](https://demo.pigsty.cc) & [**Gallery**](https://github.com/pgsty/pigsty/wiki/Gallery).
- [**Available**](https://pigsty.io/img/pigsty/ha.png): Auto-routed & pooled customizable database [**Services**](https://pigsty.io/docs/concept/svc#default-service) [**Access**](https://pigsty.io/docs/concept/svc#access-service) with **haproxy**, **pgbouncer**, and **VIP**.
- [**Maintainable**](https://pigsty.io/img/pigsty/iac.jpg): [**One-Cmd Install**](https://pigsty.io/docs/setup/install), [**Admin SOP**](https://pigsty.io/docs/pgsql/admin), **Auto-Tune**, **Local Repo**, [**IaC**](https://pigsty.io/docs/pgsql/config) and [**Vagrant**](https://pigsty.io/docs/setup/provision#vagrant) / [**Terraform**](https://pigsty.io/docs/setup/provision#terraform) support.
- [**Composable**](https://pigsty.io/img/pigsty/sandbox.jpg): Bonus [**Modules**](https://pigsty.io/docs/about/modules) such as [**Redis**](https://pigsty.io/docs/redis), [**MinIO**](https://pigsty.io/docs/minio), [**Etcd**](https://pigsty.io/docs/etcd), [**Docker**](https://pigsty.io/docs/app), [**DuckDB**](https://pigsty.io/docs/pro/duckdb), [**FerretDB**](https://pigsty.io/docs/ferret), [**Supabase**](https://pigsty.io/docs/kernel/supabase/), [**& More**](https://pigsty.io/docs/pro/)!

### Advantages

- **Unparalleled Extension**: [**405**](https://pigsty.io/ext/list) PostgreSQL extensions available in addition to the official **PGDG** repo.
- **Stunning Observability**: Ultimate experience with **3000+** metrics visualized in **30+** organized dashboards.
- **Reliable Best Practices**: Proven & Polished in large-scale production environment (**25K** vCPU) for **6** years+.
- **NO Docker/Kubernetes**: We choose the hard way to deliver RDS based on bare OS **WITHOUT** [**Containers**](https://pigsty.io/blog/db/db-in-k8s/)!
- **Infrastructure as Code**: Describe everything with declarative API and provision with idempotent playbooks!
- **Free OSS & Local-First**: Pigsty is a free software under [**AGPLv3**](https://pigsty.io/docs/about/license/). Build for PostgreSQL with passion & love.

### Benefits

- **Full Control**: Unleash the full power of PostgreSQL with 405+ extensions, and gain full control of your data!
- **Rest Assured**: Self-healing HA from hardware failures and Point-In-Time-Recovery from human error & bugs!
- **Keen Insight**: You can't manage what you can't measure. Gain penetrating insight through all-seeing panels!
- **Self-Reliant**: Self-serving enterprise RDS service with all its dependencies in the absence of a dedicated DBA!
- **Anti-Entropy**: Describe everything in code, minimize complexity with IaC & SOP, Administration with GitOps!
- **Get more, Pay less**: No vendor lock-in, Run your own RDS to reclaim 90%+ hardware bonus from the Cloud!

[![landscape](https://pigsty.io/img/pigsty/ecosystem.jpg)](https://pigsty.io/ext/list)


----------------

## Get Started

[![Postgres: 17.4](https://img.shields.io/badge/PostgreSQL-17.2-%233E668F?style=flat&logo=postgresql&labelColor=3E668F&logoColor=white)](https://pigsty.io/docs/pgsql)
[![Linux](https://img.shields.io/badge/Linux-AMD64-%23FCC624?style=flat&logo=linux&labelColor=FCC624&logoColor=black)](https://pigsty.io/docs/node)
[![Linux](https://img.shields.io/badge/Linux-ARM64-%23FCC624?style=flat&logo=linux&labelColor=FCC624&logoColor=black)](https://pigsty.io/docs/node)
[![EL Support: 8/9](https://img.shields.io/badge/EL-7/8/9-red?style=flat&logo=redhat&logoColor=red)](https://pigsty.io/ext/list/rpm)
[![Debian Support: 12](https://img.shields.io/badge/Debian-11/12-%23A81D33?style=flat&logo=debian&logoColor=%23A81D33)](https://pigsty.io/ext/list/deb)
[![Ubuntu Support: 22/24](https://img.shields.io/badge/Ubuntu-20/22/24-%23E95420?style=flat&logo=ubuntu&logoColor=%23E95420)](https://pigsty.io/ext/list/deb)

[**Prepare**](https://pigsty.io/docs/setup/prepare/) a fresh `x86_64` / `aarch64` node runs any [**compatible**](#compatibility) **Linux** OS Distros, then [**Download**](https://pigsty.io/docs/setup/install/) **Pigsty** with:

```bash
curl -fsSL https://repo.pigsty.io/get | bash; cd ~/pigsty;
```

Next, [**bootstrap**](https://pigsty.io/docs/setup/offline/#bootstrap), [**configure**](https://pigsty.io/docs/setup/install#configure), and run the [**`install.yml`**](https://pigsty.io/docs/setup/install#install) playbook with an [**admin user**](https://pigsty.io/docs/setup/prepare/#admin-user) (**nopass** `ssh` & `sudo`):

```bash
./bootstrap; ./configure; ./install.yml;
```

Finally, you will get a pigsty singleton node [**ready**](https://pigsty.io/docs/setup/install/#interface), with Web service on port `80/443` and Postgres on port `5432`.

> Consider [**Slim Installation**](https://pigsty.io/docs/setup/slim/) if you only want essential components for HA PostgreSQL.


<details><summary>Install with the pig cli</summary><br>

```bash
curl -fsSL https://repo.pigsty.io/pig | bash
curl -fsSL https://repo.pigsty.cc/pig | bash  # mirror
```

Then you can launch pigsty with `pig sty` sub command:

```bash
pig sty init     # install embed pigsty to ~/pigsty 
pig sty boot     # install ansible and other pre-deps 
pig sty conf     # auto-generate pigsty.yml config file
pig sty install  # run the install.yml playbook
```

</details>


<details><summary>Install with get script</summary><br>

```
$ curl -fsSL https://repo.pigsty.io/get | bash
[v3.3.0] ===========================================
$ curl -fsSL https://repo.pigsty.io/get | bash
[Site] https://pigsty.io
[Demo] https://demo.pigsty.cc
[Repo] https://github.com/pgsty/pigsty
[Docs] https://pigsty.io/docs/setup/install
[Download] ===========================================
[ OK ] version = v3.3.0 (from default)
curl -fSL https://repo.pigsty.io/src/pigsty-v3.3.0.tgz -o /tmp/pigsty-v3.3.0.tgz
######################################################################## 100.0%
[ OK ] md5sums = xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  /tmp/pigsty-v3.3.0.tgz
[Install] ===========================================
[WARN] os user = root , it's recommended to install as a sudo-able admin
[ OK ] install = /root/pigsty, from /tmp/pigsty-v3.3.0.tgz
[TodoList] ===========================================
cd /root/pigsty
./bootstrap      # [OPTIONAL] install ansible & use offline package
./configure      # [OPTIONAL] preflight-check and config generation
./install.yml    # install pigsty modules according to your config.
[Complete] ===========================================
```

> HINT: To install a specific version, pass the version string as the first parameter:
>
> ```bash
> curl -fsSL https://repo.pigsty.io/get | bash -s v3.3.0
> ```

</details>


<details><summary>Or clone src with git</summary><br>

You can also download the pigsty source with `git`, remember to check out a specific version tag, the `main` branch is for development.

```bash
git clone https://github.com/pgsty/pigsty; cd pigsty; git checkout v3.3.0
```

</details>


----------------

**Example: Singleton Installation on RockyLinux 9:**

[![asciicast](https://asciinema.org/a/673459.svg)](https://asciinema.org/a/673459)



----------------

## Architecture


Pigsty uses a [**modular**](https://pigsty.io/docs/concept/arch/) design. There are **4** **CORE** [**modules**](https://pigsty.io/docs/about/module/) available by default:

[![PGSQL](https://img.shields.io/badge/PGSQL-%233E668F?style=flat&logo=postgresql&labelColor=3E668F&logoColor=white)](https://pigsty.io/docs/pgsql) Self-healing PostgreSQL HA cluster powered by Patroni, Pgbouncer, PgBackrest & HAProxy

[![INFRA](https://img.shields.io/badge/INFRA-%23009639?style=flat&logo=nginx&labelColor=009639&logoColor=white)](https://pigsty.io/docs/infra) Nginx, Local Repo, DNSMasq, and the entire Prometheus & Grafana observability stack.

[![NODE](https://img.shields.io/badge/NODE-%23FCC624?style=flat&logo=linux&labelColor=FCC624&logoColor=black)](https://pigsty.io/docs/node) Init node name, repo, pkg, NTP, ssh, admin, tune, expose services, collect logs & metrics.

[![ETCD](https://img.shields.io/badge/ETCD-%23419EDA?style=flat&logo=etcd&labelColor=419EDA&logoColor=white)](https://pigsty.io/docs/etcd) Etcd cluster is used as a reliable distributive configuration store by PostgreSQL HA Agents.

You can compose them freely in a declarative manner. `INFRA` & `NODE` will suffice for host monitoring.
`ETCD` and `PGSQL` are used for HA PG clusters; Installing them on multiple nodes automatically forms HA clusters.

The default [`install.yml`](https://github.com/pgsty/pigsty/blob/main/install.yml) playbook will install `INFRA`, `NODE`, `ETCD` & `PGSQL` on the current node.
Which gives you an out-of-the-box PostgreSQL singleton instance (`admin_ip:5432`) with everything ready.

[![pigsty-arch.jpg](https://pigsty.io/img/pigsty/arch.jpg)](https://pigsty.io/docs/concept/arch/)

The node can be used as an admin controller to deploy & monitor more nodes & clusters. For example, you can install these **4** **OPTIONAL** [extended modules](https://pigsty.io/docs/about/module/#extended-modules) for advanced use cases:

[![MinIO](https://img.shields.io/badge/MINIO-%23C72E49?style=flat&logo=minio&logoColor=white)](https://pigsty.io/docs/etcd) S3-compatible object storage service; used as an optional central backup server for `PGSQL`.

[![Redis](https://img.shields.io/badge/REDIS-%23FF4438?style=flat&logo=redis&logoColor=white)](https://pigsty.io/docs/infra) Deploy Redis servers in standalone master-replica, sentinel, and native cluster mode.

[![Ferret](https://img.shields.io/badge/FERRET-%23042133?style=flat&logo=ferretdb&logoColor=white)](https://pigsty.io/docs/ferret) Native support for FerretDB — adding MongoDB wire protocol compatibility to Postgres!

[![Docker](https://img.shields.io/badge/DOCKER-%232496ED?style=flat&logo=docker&logoColor=white)](https://pigsty.io/docs/docker) Launch optional docker daemons to run other stateless parts besides Pigsty RDS.

Of course, you can deploy different kinds of HA **PostgreSQL** clusters on multiple nodes, as much as you want.


----------------

## PostgreSQL RDS

To deploy an additional 3-node HA Postgres cluster `pg-test`. Add the cluster [**definition**](https://github.com/pgsty/pigsty/blob/main/conf/full.yml#L46) to the [**config inventory**](https://pigsty.io/docs/setup/config/):

```yaml 
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
    10.10.10.13: { pg_seq: 3, pg_role: offline }
  vars: { pg_cluster: pg-test }
```

The default config file is [`pigsty.yml`](https://github.com/pgsty/pigsty/blob/main/pigsty.yml) under pigsty home, add the snippet above to the `all.children.pg-test`,
Then, create the cluster with built-in playbooks in one command:

```bash
bin/pgsql-add pg-test   # init pg-test cluster 
```

<details><summary>Example: Complex PostgreSQL Customization</summary><br>

This config file provides a detailed example of a complex PostgreSQL cluster `pg-meta` with multiple databases, users, and service definition:

```yaml
pg-meta:
  hosts: { 10.10.10.10: { pg_seq: 1, pg_role: primary , pg_offline_query: true } }
  vars:
    pg_cluster: pg-meta
    pg_databases:                       # define business databases on this cluster, array of database definition
      - name: meta                      # REQUIRED, `name` is the only mandatory field of a database definition
        baseline: cmdb.sql              # optional, database sql baseline path, (relative path among ansible search path, e.g files/)
        pgbouncer: true                 # optional, add this database to pgbouncer database list? true by default
        schemas: [pigsty]               # optional, additional schemas to be created, array of schema names
        extensions:                     # optional, additional extensions to be installed: array of `{name[,schema]}`
          - { name: postgis , schema: public }
          - { name: timescaledb }
        comment: pigsty meta database   # optional, comment string for this database
        owner: postgres                # optional, database owner, postgres by default
        template: template1            # optional, which template to use, template1 by default
        encoding: UTF8                 # optional, database encoding, UTF8 by default. (MUST same as template database)
        locale: C                      # optional, database locale, C by default.  (MUST same as template database)
        lc_collate: C                  # optional, database collate, C by default. (MUST same as template database)
        lc_ctype: C                    # optional, database ctype, C by default.   (MUST same as template database)
        tablespace: pg_default         # optional, default tablespace, 'pg_default' by default.
        allowconn: true                # optional, allow connection, true by default. false will disable connect at all
        revokeconn: false              # optional, revoke public connection privilege. false by default. (leave connect with grant option to owner)
        register_datasource: true      # optional, register this database to grafana datasources? true by default
        connlimit: -1                  # optional, database connection limit, default -1 disable limit
        pool_auth_user: dbuser_meta    # optional, all connection to this pgbouncer database will be authenticated by this user
        pool_mode: transaction         # optional, pgbouncer pool mode at database level, default transaction
        pool_size: 64                  # optional, pgbouncer pool size at database level, default 64
        pool_size_reserve: 32          # optional, pgbouncer pool size reserve at database level, default 32
        pool_size_min: 0               # optional, pgbouncer pool size min at database level, default 0
        pool_max_db_conn: 100          # optional, max database connections at database level, default 100
      - { name: grafana  ,owner: dbuser_grafana  ,revokeconn: true ,comment: grafana primary database }
      - { name: bytebase ,owner: dbuser_bytebase ,revokeconn: true ,comment: bytebase primary database }
      - { name: kong     ,owner: dbuser_kong     ,revokeconn: true ,comment: kong the api gateway database }
      - { name: gitea    ,owner: dbuser_gitea    ,revokeconn: true ,comment: gitea meta database }
      - { name: wiki     ,owner: dbuser_wiki     ,revokeconn: true ,comment: wiki meta database }
    pg_users:                           # define business users/roles on this cluster, array of user definition
      - name: dbuser_meta               # REQUIRED, `name` is the only mandatory field of a user definition
        password: DBUser.Meta           # optional, password, can be a scram-sha-256 hash string or plain text
        login: true                     # optional, can log in, true by default  (new biz ROLE should be false)
        superuser: false                # optional, is superuser? false by default
        createdb: false                 # optional, can create database? false by default
        createrole: false               # optional, can create role? false by default
        inherit: true                   # optional, can this role use inherited privileges? true by default
        replication: false              # optional, can this role do replication? false by default
        bypassrls: false                # optional, can this role bypass row level security? false by default
        pgbouncer: true                 # optional, add this user to pgbouncer user-list? false by default (production user should be true explicitly)
        connlimit: -1                   # optional, user connection limit, default -1 disable limit
        expire_in: 3650                 # optional, now + n days when this role is expired (OVERWRITE expire_at)
        expire_at: '2030-12-31'         # optional, YYYY-MM-DD 'timestamp' when this role is expired  (OVERWRITTEN by expire_in)
        comment: pigsty admin user      # optional, comment string for this user/role
        roles: [dbrole_admin]           # optional, belonged roles. default roles are: dbrole_{admin,readonly,readwrite,offline}
        parameters: {}                  # optional, role level parameters with `ALTER ROLE SET`
        pool_mode: transaction          # optional, pgbouncer pool mode at user level, transaction by default
        pool_connlimit: -1              # optional, max database connections at user level, default -1 disable limit
      - {name: dbuser_view     ,password: DBUser.Viewer   ,pgbouncer: true ,roles: [dbrole_readonly], comment: read-only viewer for meta database}
      - {name: dbuser_grafana  ,password: DBUser.Grafana  ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for grafana database   }
      - {name: dbuser_bytebase ,password: DBUser.Bytebase ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for bytebase database  }
      - {name: dbuser_kong     ,password: DBUser.Kong     ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for kong api gateway   }
      - {name: dbuser_gitea    ,password: DBUser.Gitea    ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for gitea service      }
      - {name: dbuser_wiki     ,password: DBUser.Wiki     ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: admin user for wiki.js service    }
    pg_services:                        # extra services in addition to pg_default_services, array of service definition
      # standby service will route {ip|name}:5435 to sync replica's pgbouncer (5435->6432 standby)
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
    pg_hba_rules:
      - {user: dbuser_view , db: all ,addr: infra ,auth: pwd ,title: 'allow grafana dashboard access cmdb from infra nodes'}
    pg_vip_enabled: true
    pg_vip_address: 10.10.10.2/24
    pg_vip_interface: eth1
    node_crontab:  # make a full backup 1 am everyday
      - '00 01 * * * postgres /pg/bin/pg-backup full'

```

[![home](https://pigsty.io/img/pigsty/home.jpg)](https://pigsty.io/img/pigsty/home.jpg)

</details>

It will create a cluster with everything properly configured: [**High Availability**](https://pigsty.io/docs/concept/ha) powered by patroni & etcd; [**Point-In-Time-Recovery**](https://pigsty.io/docs/concept/pitr) powered by pgBackRest & optional MinIO / S3;
auto-routed, pooled [**Services & Access**](https://pigsty.io/docs/concept/svc#default-service) pooled by pgBouncer and exposed by haproxy; and out-of-the-box [**Monitoring**](https://pigsty.io/docs/pgsql/dashboard/) & alerting powered by the **`INFRA`** module.

[![HA PostgreSQL Arch](https://pigsty.io/img/pigsty/ha.png)](https://pigsty.io/docs/concept/ha/)

The cluster keeps serving as long as **ANY** instance survives, with excellent fault-tolerance performance:

> [**RPO**](https://pigsty.io/docs/concept/ha#rpo) **= 0** on sync mode, **RPO < 1MB** on async mode; [**RTO**](https://pigsty.io/docs/concept/ha#rpo) **< 1s** on switchover, **RTO ≈ 15s** on failover.




----------------

## Customization

Pigsty is highly customizable, You can describe the entire database and infra deployment with **300+** [**parameters**](https://pigsty.io/docs/reference/param/) in a single config file and materialize them with one command.
There are many built-in configuration [templates](https://pigsty.io/docs/conf) that can be used directly.

<details><summary>Example: Sandbox (4-node) with two PG cluster</summary><br>

The [`conf/full.yml`](https://github.com/pgsty/pigsty/blob/main/conf/full.yml) utilize four nodes to deploy two PostgreSQL clusters `pg-meta` and `pg-test`:

```yaml
pg-meta:
  hosts: { 10.10.10.10: { pg_seq: 1, pg_role: primary } }
  vars:
    pg_cluster: pg-meta
    pg_users:
      - {name: dbuser_meta     ,password: DBUser.Meta     ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: pigsty admin user }
      - {name: dbuser_view     ,password: DBUser.Viewer   ,pgbouncer: true ,roles: [dbrole_readonly] ,comment: read-only viewer for meta database }
    pg_databases:
      - {name: meta ,baseline: cmdb.sql ,comment: pigsty meta database ,schemas: [pigsty]}
    pg_hba_rules:
      - {user: dbuser_view , db: all ,addr: infra ,auth: pwd ,title: 'allow grafana dashboard access cmdb from infra nodes'}
    pg_vip_enabled: true
    pg_vip_address: 10.10.10.2/24
    pg_vip_interface: eth1

# pgsql 3 node ha cluster: pg-test
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }   # primary instance, leader of cluster
    10.10.10.12: { pg_seq: 2, pg_role: replica }   # replica instance, follower of leader
    10.10.10.13: { pg_seq: 3, pg_role: replica, pg_offline_query: true } # replica with offline access
  vars:
    pg_cluster: pg-test           # define pgsql cluster name
    pg_users:  [{ name: test , password: test , pgbouncer: true , roles: [ dbrole_admin ] }]
    pg_databases: [{ name: test }]
    pg_vip_enabled: true
    pg_vip_address: 10.10.10.3/24
    pg_vip_interface: eth1
```

You can even deploy PostgreSQL with different major versions and kernel forks in the same deployment:

[![kernels](https://pigsty.io/img/pigsty/kernels.jpg)](https://pigsty.io/img/pigsty/kernels.jpg)

</details>

<details><summary>Example: Security Setup & Delayed Replica</summary><br>

The following [`conf/safe.yml`](https://github.com/pgsty/pigsty/blob/main/conf/safe.yml) provision a 4-node [security](https://pigsty.io/docs/setup/security/) enhanced postgres cluster `pg-meta` with a delayed replica `pg-meta-delay`:

```yaml
pg-meta:      # 3 instance postgres cluster `pg-meta`
  hosts:
    10.10.10.10: { pg_seq: 1, pg_role: primary }
    10.10.10.11: { pg_seq: 2, pg_role: replica }
    10.10.10.12: { pg_seq: 3, pg_role: replica , pg_offline_query: true }
  vars:
    pg_cluster: pg-meta
    pg_conf: crit.yml
    pg_users:
      - { name: dbuser_meta , password: DBUser.Meta   , pgbouncer: true , roles: [ dbrole_admin ] , comment: pigsty admin user }
      - { name: dbuser_view , password: DBUser.Viewer , pgbouncer: true , roles: [ dbrole_readonly ] , comment: read-only viewer for meta database }
    pg_databases:
      - {name: meta ,baseline: cmdb.sql ,comment: pigsty meta database ,schemas: [pigsty] ,extensions: [{name: postgis, schema: public}, {name: timescaledb}]}
    pg_default_service_dest: postgres
    pg_services:
      - { name: standby ,src_ip: "*" ,port: 5435 , dest: default ,selector: "[]" , backup: "[? pg_role == `primary`]" }
    pg_vip_enabled: true
    pg_vip_address: 10.10.10.2/24
    pg_vip_interface: eth1
    pg_listen: '${ip},${vip},${lo}'
    patroni_ssl_enabled: true
    pgbouncer_sslmode: require
    pgbackrest_method: minio
    pg_libs: 'timescaledb, $libdir/passwordcheck, pg_stat_statements, auto_explain' # add passwordcheck extension to enforce strong password
    pg_default_roles:                 # default roles and users in postgres cluster
      - { name: dbrole_readonly  ,login: false ,comment: role for global read-only access     }
      - { name: dbrole_offline   ,login: false ,comment: role for restricted read-only access }
      - { name: dbrole_readwrite ,login: false ,roles: [dbrole_readonly]               ,comment: role for global read-write access }
      - { name: dbrole_admin     ,login: false ,roles: [pg_monitor, dbrole_readwrite]  ,comment: role for object creation }
      - { name: postgres     ,superuser: true  ,expire_in: 7300                        ,comment: system superuser }
      - { name: replicator ,replication: true  ,expire_in: 7300 ,roles: [pg_monitor, dbrole_readonly]   ,comment: system replicator }
      - { name: dbuser_dba   ,superuser: true  ,expire_in: 7300 ,roles: [dbrole_admin]  ,pgbouncer: true ,pool_mode: session, pool_connlimit: 16 , comment: pgsql admin user }
      - { name: dbuser_monitor ,roles: [pg_monitor] ,expire_in: 7300 ,pgbouncer: true ,parameters: {log_min_duration_statement: 1000 } ,pool_mode: session ,pool_connlimit: 8 ,comment: pgsql monitor user }
    pg_default_hba_rules:             # postgres host-based auth rules by default
      - {user: '${dbsu}'    ,db: all         ,addr: local     ,auth: ident ,title: 'dbsu access via local os user ident'  }
      - {user: '${dbsu}'    ,db: replication ,addr: local     ,auth: ident ,title: 'dbsu replication from local os ident' }
      - {user: '${repl}'    ,db: replication ,addr: localhost ,auth: ssl   ,title: 'replicator replication from localhost'}
      - {user: '${repl}'    ,db: replication ,addr: intra     ,auth: ssl   ,title: 'replicator replication from intranet' }
      - {user: '${repl}'    ,db: postgres    ,addr: intra     ,auth: ssl   ,title: 'replicator postgres db from intranet' }
      - {user: '${monitor}' ,db: all         ,addr: localhost ,auth: pwd   ,title: 'monitor from localhost with password' }
      - {user: '${monitor}' ,db: all         ,addr: infra     ,auth: ssl   ,title: 'monitor from infra host with password'}
      - {user: '${admin}'   ,db: all         ,addr: infra     ,auth: ssl   ,title: 'admin @ infra nodes with pwd & ssl'   }
      - {user: '${admin}'   ,db: all         ,addr: world     ,auth: cert  ,title: 'admin @ everywhere with ssl & cert'   }
      - {user: '+dbrole_readonly',db: all    ,addr: localhost ,auth: ssl   ,title: 'pgbouncer read/write via local socket'}
      - {user: '+dbrole_readonly',db: all    ,addr: intra     ,auth: ssl   ,title: 'read/write biz user via password'     }
      - {user: '+dbrole_offline' ,db: all    ,addr: intra     ,auth: ssl   ,title: 'allow etl offline tasks from intranet'}
    pgb_default_hba_rules:            # pgbouncer host-based authentication rules
      - {user: '${dbsu}'    ,db: pgbouncer   ,addr: local     ,auth: peer  ,title: 'dbsu local admin access with os ident'}
      - {user: 'all'        ,db: all         ,addr: localhost ,auth: pwd   ,title: 'allow all user local access with pwd' }
      - {user: '${monitor}' ,db: pgbouncer   ,addr: intra     ,auth: ssl   ,title: 'monitor access via intranet with pwd' }
      - {user: '${monitor}' ,db: all         ,addr: world     ,auth: deny  ,title: 'reject all other monitor access addr' }
      - {user: '${admin}'   ,db: all         ,addr: intra     ,auth: ssl   ,title: 'admin access via intranet with pwd'   }
      - {user: '${admin}'   ,db: all         ,addr: world     ,auth: deny  ,title: 'reject all other admin access addr'   }
      - {user: 'all'        ,db: all         ,addr: intra     ,auth: ssl   ,title: 'allow all user intra access with pwd' }

# OPTIONAL delayed cluster for pg-meta
pg-meta-delay:                    # delayed instance for pg-meta (1 hour ago)
  hosts: { 10.10.10.13: { pg_seq: 1, pg_role: primary, pg_upstream: 10.10.10.10, pg_delay: 1h } }
  vars: { pg_cluster: pg-meta-delay }
```

</details>

You can deploy different kinds of PostgreSQL instance such as primary, replica, offline, delayed, sync standby, etc.,
and customize with scene-optimize [**templates**](https://github.com/pgsty/pigsty/tree/dev/conf), pre-defined [**stacks**](https://pigsty.io/docs/pgext/usage/stack) and all **405** [**extensions**](https://pigsty.io/ext/list).

You can define [**Users**](https://pigsty.io/docs/pgsql/user/), [**Databases**](https://pigsty.io/docs/pgsql/db/), [**Service**](https://pigsty.io/docs/pgsql/svc/), [**HBAs**](https://pigsty.io/docs/pgsql/hba/) and other entities in code and provision them in one pass.
You can even replace the vanilla [**`PostgreSQL`**](https://pigsty.io/docs/pgsql) [**Kernel**](https://pigsty.io/docs/kernel/) with other forks as an in-place replacement: [**`Babelfish`**](https://pigsty.io/docs/kernel/babelfish/) for MSSQL compatibility,
[**`IvorySQL`**](https://pigsty.io/docs/kernel/ivorysql) and [**`PolarDB`**](https://pigsty.io/docs/kernel/polardb/) for ORACLE compatibility:

<details><summary>Example: Babelfish Cluster (MSSQL Compatible)</summary><br>

The [`conf/mssql.yml`](https://github.com/pgsty/pigsty/blob/main/conf/mssql.yml) Provision a [Babelfish](https://pigsty.io/docs/kernel/babelfish/) cluster with Microsoft SQL Server compatibility:

```yaml
# ./pgsql.yml -l pg-mssql
pg-mssql:
  hosts:
    10.10.10.41: { pg_seq: 1 ,pg_role: primary }
    10.10.10.42: { pg_seq: 2 ,pg_role: replica }
    10.10.10.43: { pg_seq: 3 ,pg_role: replica }
    10.10.10.44: { pg_seq: 4 ,pg_role: replica }
  vars:
    pg_cluster: pg-mssql
    pg_vip_enabled: true
    pg_vip_address: 10.10.10.3/24
    pg_vip_interface: eth1
    pg_users:                           # create MSSQL superuser
      - {name: dbuser_mssql ,password: DBUser.MSSQL ,superuser: true, pgbouncer: true ,roles: [dbrole_admin], comment: superuser & owner for babelfish  }
    pg_primary_db: mssql                # use `mssql` as the primary sql server database
    pg_databases:
      - name: mssql
        baseline: mssql.sql             # init babelfish database & user
        extensions:
          - { name: uuid-ossp          }
          - { name: babelfishpg_common }
          - { name: babelfishpg_tsql   }
          - { name: babelfishpg_tds    }
          - { name: babelfishpg_money  }
          - { name: pg_hint_plan       }
          - { name: system_stats       }
          - { name: tds_fdw            }
        owner: dbuser_mssql
        parameters: { 'babelfishpg_tsql.migration_mode' : 'single-db' }
        comment: babelfish cluster, a MSSQL compatible pg cluster
    node_repo_modules: local,mssql     # add local & mssql modules to node repo (Internet Required)
    pg_version: 15                     # The current WiltonDB major version is 15
    pg_packages:                       # install forked version of postgresql with babelfishpg support
      - wiltondb sqlcmd patroni pgbouncer pgbackrest pg_exporter pgbadger vip-manager
    pg_extensions: [ ]                 # do not install any vanilla postgresql extensions
    pg_mode: mssql                    # Microsoft SQL Server Compatible Mode
    pg_libs: 'babelfishpg_tds, pg_stat_statements, auto_explain' # add timescaledb to shared_preload_libraries
    pg_default_hba_rules: # overwrite default HBA rules for babelfish cluster
      - { user: '${dbsu}'    ,db: all         ,addr: local     ,auth: ident ,title: 'dbsu access via local os user ident' }
      - { user: '${dbsu}'    ,db: replication ,addr: local     ,auth: ident ,title: 'dbsu replication from local os ident' }
      - { user: '${repl}'    ,db: replication ,addr: localhost ,auth: pwd   ,title: 'replicator replication from localhost' }
      - { user: '${repl}'    ,db: replication ,addr: intra     ,auth: pwd   ,title: 'replicator replication from intranet' }
      - { user: '${repl}'    ,db: postgres    ,addr: intra     ,auth: pwd   ,title: 'replicator postgres db from intranet' }
      - { user: '${monitor}' ,db: all         ,addr: localhost ,auth: pwd   ,title: 'monitor from localhost with password' }
      - { user: '${monitor}' ,db: all         ,addr: infra     ,auth: pwd   ,title: 'monitor from infra host with password' }
      - { user: '${admin}'   ,db: all         ,addr: infra     ,auth: ssl   ,title: 'admin @ infra nodes with pwd & ssl' }
      - { user: '${admin}'   ,db: all         ,addr: world     ,auth: ssl   ,title: 'admin @ everywhere with ssl & pwd' }
      - { user: dbuser_mssql ,db: mssql       ,addr: intra     ,auth: md5   ,title: 'allow mssql dbsu intranet access' } # <--- use md5 auth method for mssql user
      - { user: '+dbrole_readonly',db: all    ,addr: localhost ,auth: pwd   ,title: 'pgbouncer read/write via local socket' }
      - { user: '+dbrole_readonly',db: all    ,addr: intra     ,auth: pwd   ,title: 'read/write biz user via password' }
      - { user: '+dbrole_offline' ,db: all    ,addr: intra     ,auth: pwd   ,title: 'allow etl offline tasks from intranet' }
    pg_default_services: # route primary & replica service to mssql port 1433
      - { name: primary ,port: 5433 ,dest: 1433  ,check: /primary   ,selector: "[]" }
      - { name: replica ,port: 5434 ,dest: 1433  ,check: /read-only ,selector: "[]" , backup: "[? pg_role == `primary` || pg_role == `offline` ]" }
      - { name: default ,port: 5436 ,dest: postgres ,check: /primary   ,selector: "[]" }
      - { name: offline ,port: 5438 ,dest: postgres ,check: /replica   ,selector: "[? pg_role == `offline` || pg_offline_query ]" , backup: "[? pg_role == `replica` && !pg_offline_query]" }
```

[![mssql](https://pigsty.io/img/pigsty/mssql.jpg)](https://pigsty.io/img/pigsty/mssql.jpg)

</details>

<details><summary>Example: IvorySQL Cluster (Oracle Compatible)</summary><br>

The [`conf/ivory.yml`](https://github.com/pgsty/pigsty/blob/main/conf/mssql.yml) define an [IvorySQL](https://pigsty.io/docs/kernel/ivorysql/) cluster, which aims to be Oracle compatible:

```yaml
# ./pgsql.yml -l pg-ivory
pg-ivory:
  hosts:
    10.10.10.45: { pg_seq: 1 ,pg_role: primary }
    10.10.10.46: { pg_seq: 2 ,pg_role: replica }
    10.10.10.47: { pg_seq: 3 ,pg_role: replica }
  vars:
    pg_cluster: pg-ivory
    pg_version: 16                    # The current IvorySQL compatible major version is 16
    pg_mode: ivory                    # IvorySQL Oracle Compatible Mode
    pg_packages: [ 'ivorysql patroni pgbouncer pgbackrest pg_exporter pgbadger vip-manager' ]
    pg_libs: 'liboracle_parser, pg_stat_statements, auto_explain'
    pgbackrest_enabled: false         # got checksum error when using oracle compatible mode
    repo_modules: node,pgsql,infra,ivory
    repo_packages: [ node-bootstrap, infra-package, infra-addons, node-package1, node-package2, pgsql-utility ] #docker
    repo_extra_packages: [ ivorysql ] # replace default postgresql kernel with ivroysql packages

```

[![ivorysql](https://pigsty.io/img/pigsty/ivory.jpg)](https://pigsty.io/img/pigsty/ivory.jpg)

</details>


You can also wrap existing kernel with add-ons: horizontal sharding with [**`CITUS`**](https://pigsty.io/docs/kernel/citus/),
serving MongoDB wire protocol with [**`FERRET`**](https://pigsty.io/docs/ferret/), or self-hosting firebase alternative with [**`SUPABASE`**](https://pigsty.io/docs/kernel/supabase/):


<details><summary>Example: Citus Distributed Cluster: 10-Node</summary><br>

The [`conf/simu.yml`](https://github.com/pgsty/pigsty/blob/main/conf/simu.yml) provision a 10-node [**Citus**](https://pigsty.io/docs/kernel/citus/) cluster as below:

```yaml
# pg-citus: 10 node citus cluster (5 x primary-replica pair)
pg-citus: # citus group
  hosts:
    10.10.10.50: { pg_group: 0, pg_cluster: pg-citus0 ,pg_vip_address: 10.10.10.60/24 ,pg_seq: 0, pg_role: primary }
    10.10.10.51: { pg_group: 0, pg_cluster: pg-citus0 ,pg_vip_address: 10.10.10.60/24 ,pg_seq: 1, pg_role: replica }
    10.10.10.52: { pg_group: 1, pg_cluster: pg-citus1 ,pg_vip_address: 10.10.10.61/24 ,pg_seq: 0, pg_role: primary }
    10.10.10.53: { pg_group: 1, pg_cluster: pg-citus1 ,pg_vip_address: 10.10.10.61/24 ,pg_seq: 1, pg_role: replica }
    10.10.10.54: { pg_group: 2, pg_cluster: pg-citus2 ,pg_vip_address: 10.10.10.62/24 ,pg_seq: 0, pg_role: primary }
    10.10.10.55: { pg_group: 2, pg_cluster: pg-citus2 ,pg_vip_address: 10.10.10.62/24 ,pg_seq: 1, pg_role: replica }
    10.10.10.56: { pg_group: 3, pg_cluster: pg-citus3 ,pg_vip_address: 10.10.10.63/24 ,pg_seq: 0, pg_role: primary }
    10.10.10.57: { pg_group: 3, pg_cluster: pg-citus3 ,pg_vip_address: 10.10.10.63/24 ,pg_seq: 1, pg_role: replica }
    10.10.10.58: { pg_group: 4, pg_cluster: pg-citus4 ,pg_vip_address: 10.10.10.64/24 ,pg_seq: 0, pg_role: primary }
    10.10.10.59: { pg_group: 4, pg_cluster: pg-citus4 ,pg_vip_address: 10.10.10.64/24 ,pg_seq: 1, pg_role: replica }
  vars:
    pg_mode: citus                    # pgsql cluster mode: citus
    pg_shard: pg-citus                # citus shard name: pg-citus
    pg_primary_db: test               # primary database used by citus
    pg_dbsu_password: DBUser.Postgres # all dbsu password access for citus cluster
    pg_vip_enabled: true
    pg_vip_interface: eth1
    pg_extensions: [ 'citus postgis timescaledb pgvector' ]
    pg_libs: 'citus, timescaledb, pg_stat_statements, auto_explain' # citus will be added by patroni automatically
    pg_users: [ { name: test ,password: test ,pgbouncer: true ,roles: [ dbrole_admin ] } ]
    pg_databases: [ { name: test ,owner: test ,extensions: [ { name: citus }, { name: postgis } ] } ]
    pg_hba_rules:
      - { user: 'all' ,db: all  ,addr: 10.10.10.0/24 ,auth: trust ,title: 'trust citus cluster members'        }
      - { user: 'all' ,db: all  ,addr: 127.0.0.1/32  ,auth: ssl   ,title: 'all user ssl access from localhost' }
      - { user: 'all' ,db: all  ,addr: intra         ,auth: ssl   ,title: 'all user ssl access from intranet'  }
```

[![citus](https://pigsty.io/img/pigsty/citus.jpg)](https://pigsty.io/img/pigsty/citus.jpg)

</details>

<details><summary>Example: PostgreSQL for Self-hosting Supabase</summary><br>

You can launch a self-hosting supabase with MinIO and PostgreSQL with just two commands:

```bash
./install.yml
./supabase.yml
```

The [`conf/supa.yml`](https://github.com/pgsty/pigsty/blob/main/conf/supa.yml) just describe everything you need:

```yaml
# pg-meta, the underlying postgres database for supabase
pg-meta:
  hosts: { 10.10.10.10: { pg_seq: 1, pg_role: primary } }
  vars:
    pg_cluster: pg-meta
    pg_users:
      # supabase roles: anon, authenticated, dashboard_user
      - { name: anon           ,login: false }
      - { name: authenticated  ,login: false }
      - { name: dashboard_user ,login: false ,replication: true ,createdb: true ,createrole: true }
      - { name: service_role   ,login: false ,bypassrls: true }
      # supabase users: please use the same password
      - { name: supabase_admin             ,password: 'DBUser.Supa' ,pgbouncer: true ,inherit: true   ,roles: [ dbrole_admin ] ,superuser: true ,replication: true ,createdb: true ,createrole: true ,bypassrls: true }
      - { name: authenticator              ,password: 'DBUser.Supa' ,pgbouncer: true ,inherit: false  ,roles: [ dbrole_admin, authenticated ,anon ,service_role ] }
      - { name: supabase_auth_admin        ,password: 'DBUser.Supa' ,pgbouncer: true ,inherit: false  ,roles: [ dbrole_admin ] ,createrole: true }
      - { name: supabase_storage_admin     ,password: 'DBUser.Supa' ,pgbouncer: true ,inherit: false  ,roles: [ dbrole_admin, authenticated ,anon ,service_role ] ,createrole: true }
      - { name: supabase_functions_admin   ,password: 'DBUser.Supa' ,pgbouncer: true ,inherit: false  ,roles: [ dbrole_admin ] ,createrole: true }
      - { name: supabase_replication_admin ,password: 'DBUser.Supa' ,replication: true ,roles: [ dbrole_admin ]}
      - { name: supabase_read_only_user    ,password: 'DBUser.Supa' ,bypassrls: true ,roles: [ dbrole_readonly, pg_read_all_data ] }
    pg_databases:
      - name: postgres
        baseline: supabase.sql
        owner: supabase_admin
        comment: supabase postgres database
        schemas: [ extensions ,auth ,realtime ,storage ,graphql_public ,supabase_functions ,_analytics ,_realtime ]
        extensions:
          - { name: pgcrypto  ,schema: extensions  } # 1.3   : cryptographic functions
          - { name: pg_net    ,schema: extensions  } # 0.9.2 : async HTTP
          - { name: pgjwt     ,schema: extensions  } # 0.2.0 : json web token API for postgres
          - { name: uuid-ossp ,schema: extensions  } # 1.1   : generate universally unique identifiers (UUIDs)
          - { name: pgsodium        }                # 3.1.9 : pgsodium is a modern cryptography library for Postgres.
          - { name: supabase_vault  }                # 0.2.8 : Supabase Vault Extension
          - { name: pg_graphql      }                # 1.5.9 : pg_graphql: GraphQL support
          - { name: pg_jsonschema   }                # 0.3.3 : pg_jsonschema: Validate json schema
          - { name: wrappers        }                # 0.4.3 : wrappers: FDW collections
          - { name: http            }                # 1.6   : http: allows web page retrieval inside the database.
          - { name: pg_cron         }                # 1.6   : pg_cron: Job scheduler for PostgreSQL
          - { name: timescaledb     }                # 2.17  : timescaledb: Enables scalable inserts and complex queries for time-series data
          - { name: pg_tle          }                # 1.2   : pg_tle: Trusted Language Extensions for PostgreSQL
          - { name: vector          }                # 0.8.0 : pgvector: the vector similarity search
    # supabase required extensions
    pg_libs: 'pg_stat_statements, plpgsql, plpgsql_check, pg_cron, pg_net, timescaledb, auto_explain, pg_tle, plan_filter'
    pg_extensions: # extensions to be installed on this cluster
      - supabase   # essential extensions for supabase
      - timescaledb postgis pg_graphql pg_jsonschema wrappers pg_search pg_analytics pg_parquet plv8 duckdb_fdw pg_cron pg_timetable pgqr
      - supautils pg_plan_filter passwordcheck plpgsql_check pgaudit pgsodium pg_vault pgjwt pg_ecdsa pg_session_jwt index_advisor
      - pgvector pgvectorscale pg_summarize pg_tiktoken pg_tle pg_stat_monitor hypopg pg_hint_plan pg_http pg_net pg_smtp_client pg_idkit
    pg_parameters:
      cron.database_name: postgres
      pgsodium.enable_event_trigger: off
    pg_hba_rules: # supabase hba rules, require access from docker network
      - { user: all ,db: postgres  ,addr: intra         ,auth: pwd ,title: 'allow supabase access from intranet'    }
      - { user: all ,db: postgres  ,addr: 172.17.0.0/16 ,auth: pwd ,title: 'allow access from local docker network' }
```

![](https://pigsty.io/img/pigsty/supa.jpg)

</details>

There are other pro, beta, or pilot modules, and there will be more coming in the future:

[![BABELFISH](https://img.shields.io/badge/WILTONDB-%2388A3CA?style=flat&logo=postgresql&labelColor=88A3CA&logoColor=black)](https://pigsty.io/docs/kernel/babelfish)
[![POLARDB PG](https://img.shields.io/badge/POLARDB_PG-%23DF6F2E?style=flat&logo=postgresql&labelColor=DF6F2E&logoColor=black)](https://pigsty.io/docs/kernel/polardb)
[![POLARDB ORACLE](https://img.shields.io/badge/POLARDB_ORACLE-%23DF6F2E?style=flat&logo=postgresql&labelColor=DF6F2E&logoColor=black)](https://pigsty.io/docs/kernel/polardb-o)
[![IVORYSQL](https://img.shields.io/badge/IVORYSQL-%23E8AC52?style=flat&logo=postgresql&labelColor=E8AC52&logoColor=black)](https://pigsty.io/docs/kernel/ivorysql)
[![GREENPLUM](https://img.shields.io/badge/GREENPLUM-%23578B09?style=flat&logo=postgresql&labelColor=578B09&logoColor=black)](https://pigsty.io/docs/kernel/greenplum)
[![CLOUDBERRY](https://img.shields.io/badge/CLOUDBERRY-orange?style=flat&logo=postgresql&labelColor=orange&logoColor=black)](https://pigsty.io/docs/kernel/cloudberry)
[![NEON](https://img.shields.io/badge/NEON-%2366D9C6?style=flat&logo=postgresql&labelColor=66D9C6&logoColor=black)](https://pigsty.io/docs/kernel/neon)
[![SUPABASE](https://img.shields.io/badge/SUPABASE-%233FCF8E?style=flat&logo=supabase&labelColor=3FCF8E&logoColor=white)](https://pigsty.io/docs/kernel/supabase)

[![KAFKA](https://img.shields.io/badge/KAFKA-%23231F20?style=flat&logo=apachekafka&labelColor=231F20&logoColor=white)](https://pigsty.io/docs/pro/kafka)
[![MYSQL](https://img.shields.io/badge/MYSQL-%234479A1?style=flat&logo=mysql&labelColor=4479A1&logoColor=white)](https://pigsty.io/docs/pro/kafka)
[![DUCKDB](https://img.shields.io/badge/DUCKDB-%23FFF000?style=flat&logo=duckdb&labelColor=FFF000&logoColor=white)](https://pigsty.io/docs/pro/duckdb)
[![TIGERBEETLE](https://img.shields.io/badge/TIGERBEETLE-%231919191?style=flat&logo=openbugbounty&labelColor=1919191&logoColor=white)](https://pigsty.io/docs/pro/tigerbeetle)
[![VICTORIA](https://img.shields.io/badge/VICTORIA-%23621773?style=flat&logo=victoriametrics&labelColor=621773&logoColor=white)](https://pigsty.io/docs/pro/victoria)
[![KUBERNETES](https://img.shields.io/badge/KUBERNETES-%23326CE5?style=flat&logo=kubernetes&labelColor=326CE5&logoColor=white)](https://pigsty.io/docs/pro/kube)
[![CONSUL](https://img.shields.io/badge/CONSUL-%23F24C53?style=flat&logo=consul&labelColor=F24C53&logoColor=white)](https://pigsty.io/docs/pro/consul)
[![JUPYTER](https://img.shields.io/badge/JUPYTER-%23F37626?style=flat&logo=jupyter&labelColor=F37626&logoColor=white)](https://pigsty.io/docs/pro/jupyter)
[![COCKROACH](https://img.shields.io/badge/COCKROACH-%236933FF?style=flat&logo=cockroachlabs&labelColor=6933FF&logoColor=white)](https://pigsty.io/docs/pro/)


----------------

## Compatibility

Pigsty focus on active maintained mainstream LTS Linux distros:

|  Code   | Distro                            |   `x86_64`   | Status |   `aarch64`   | Status |
|:-------:|-----------------------------------|:------------:|:------:|:-------------:|:------:|
| **U24** | Ubuntu 24.04 (noble)              | `u24.x86_64` |   ✔    | `u24.aarch64` |   ✔    |
| **U22** | Ubuntu 22.04 (jammy)              | `u22.x86_64` |   ✔    | `u22.aarch64` |   ✔    |
| **D12** | Debian 12 (bookworm)              | `d12.x86_64` |   ✔    | `d12.aarch64` |   ✔    |
| **EL9** | RHEL 9 / Rocky9 / Alma9 / ...     | `el9.x86_64` |   ✔    | `el9.aarch64` |   ✔    |
| **EL8** | RHEL 8 / Rocky8 / Alma8 / Anolis8 | `el8.x86_64` |   ✔    | `el8.aarch64` |   ✘    |
| **EL7** | RHEL7 / CentOS7 / Oracle7...      | `d12.x86_64` |   ✘    | `el7.aarch64` |   ✘    |
| **D11** | Debian 11 (bullseye)              | `d12.x86_64` |   ✘    | `d11.aarch64` |   ✘    |
| **U20** | Ubuntu 20.04 (focal)              | `d12.x86_64` |   ✘    | `u20.aarch64` |   ✘    |

For legacy distros such as (el7, d11, u20), we have [pro support](https://pigsty.io/price) for them.
Check [**compatibility**](https://pigsty.io/docs/reference/compatibility/) for details.

----------------

## About

[![Webite: pigsty.io](https://img.shields.io/badge/Website-pigsty.io-slategray?style=flat)](https://pigsty.io)
[![Github: Discussions](https://img.shields.io/badge/GitHub-Discussions-slategray?style=flat&logo=github&logoColor=black)](https://github.com/pgsty/pigsty/discussions)
[![Telegram: gV9zfZraNPM3YjFh](https://img.shields.io/badge/Telegram-gV9zfZraNPM3YjFh-cornflowerblue?style=flat&logo=telegram&logoColor=cornflowerblue)](https://t.me/joinchat/gV9zfZraNPM3YjFh)
[![Discord: j5pG8qfKxU](https://img.shields.io/badge/Discord-j5pG8qfKxU-mediumpurple?style=flat&logo=discord&logoColor=mediumpurple)](https://discord.gg/j5pG8qfKxU)
[![Wechat: pigsty-cc](https://img.shields.io/badge/WeChat-pigsty--cc-green?style=flat&logo=wechat&logoColor=green)](https://pigsty.io/img/pigsty/pigsty-cc.jpg)

[![Author: RuohangFeng](https://img.shields.io/badge/Author-Ruohang_Feng-steelblue?style=flat)](https://vonng.com/)
[![About: @Vonng](https://img.shields.io/badge/%40Vonng-steelblue?style=flat)](https://vonng.com/en/)
[![Mail: rh@vonng.com](https://img.shields.io/badge/rh%40vonng.com-steelblue?style=flat)](mailto:rh@vonng.com)
[![Copyright: 2018-2025 rh@Vonng.com](https://img.shields.io/badge/Copyright-2018--2025_(rh%40vonng.com)-red?logo=c&color=steelblue)](https://github.com/Vonng)
[![License: AGPLv3](https://img.shields.io/badge/License-AGPLv3-steelblue?style=flat&logo=opensourceinitiative&logoColor=green)](https://pigsty.io/docs/about/license/)
[![Service: PGSTY PRO](https://img.shields.io/badge/Service-PGSTY-steelblue?style=flat)](https://pigsty.io/price)