# Features

> The battery-include, auto-piloting, handy & thrifty distribution for open-source databases.


![](_media/WHAT_EN.svg)


* Battery-Include Open-Source Postgres [Distribution](#PostgreSQL-distribution)
* Auto-Piloting monitoring and management [SRE Solution](#SRE-Solution)
* Easy-to-use Database-as-Code [Developer Toolbox](#Developer-Toolbox)
* Safe & Thrifty open-source alternative to Cloud [RDS](#open-source-rds)/PaaS

 [High Availability](#High-Availability) / [Ultimate Observability](#Ultimate-Observability) / [Handy Toolbox](#Handy-Toolbox) / [Database as Code](#database-as-code) / [Versatile Scenario](#Versatile-Scenario) /  [Safety & Thrifty](#Safety-and-Thrifty)



## PostgreSQL Distribution

> RedHat for Linux!

* Pigsty deeply integrates the latest [PostgreSQL](https://www.postgresql.org/) kernel (14) with powerful extensions: [TimescaleDB](https://www.timescale.com/)  2.6,  [PostGIS]( https://postgis.net/) 3.2,  [Citus](https://www.citusdata.com/) 10, and hundreds+ of extensions, all Battery-include.
* Pigsty packs the infrastructure needed for large-scale production environments: [Grafana](https://grafana.com/), [Prometheus](https://prometheus.io/), [Loki](https://grafana.com/oss/loki/ ), [Ansible](https://docs.ansible.com/), [Consul](https://www.consul.io/), [Docker](https://www.docker.com/), etc. It can also be used as a deployment monitor for other database and application runtimes.

* Pigsty integrates with common tools for data analysis ecology: [Jupyter](https://jupyter.org/), [ECharts](https://echarts.apache.org/zh/index.html), [Grafana](https://), [PostgREST](https://postgrest.org/), [Postgres](https://www.postgresql.org/), which can be used as a [data analysis](#Data-Analytics) environment, or a low-code data visualization application development platform.

[![](_media/DISTRIBUTION.gif)](c-infra.md#Overview)




## SRE Solution

> Auto-Pilot for Postgres! Auto-Pilot! From something to something better for users **Use it for fun**!

* Pigsty comes with an unparalleled database [monitoring system](#monitoring-system) that presents over 1200 types of metrics through 30+ carefully designed and organized monitoring panels, providing the ultimate observability from a global overview to individual repository objects at a glance!
* Pigsty provides a [highly available](#high-availability) PostgreSQL database cluster, with any member surviving to provide normal services to the public; each instance is idempotent, providing a distributed database-like experience; self-healing from failure, greatly simplifying operations and maintenance work!
* Pigsty supports the deployment of different kinds of database clusters and instances: classic [PGSQL](d-pgsql.md) [master-slave replication cluster](d-pgsql.md#M-S-replication)/[disaster recovery cluster](d-pgsql.md#Standby-cluster), [synchronization](d-pgsql.md#Sync-standby)/[delay](d-pgsql.md#delayed-slaves)/[offline](d-pgsql.md#offline-replicas)/[cascade instances](d-pgsql.md#cascade-instance), [Citus](d-pgsql.md#Citus-cluster-deployment)/[Greenplum cluster](d-matrixdb.md), [Redis](d-redis.md) [master-slave](d-redis.md#cluster-definition)/[sentinel](d-redis.md#redis-sentinel-cluster-example)/[native cluster](d-redis.md#redis-native-clustee-example).

[![](_media/ARCH.gif)](c-arch.md)





## Developer Toolbox

> HashiCorp for Database!

* Pigsty upholds the Infra as Data design philosophy, users can create it in one click using an idempotent [playbook ](p-playbook.md)with just a few lines of declarative [config](v-config.md#Config-file) file describing the database they want. Just like Kubernetes!
* Pigsty delivers an easy-to-use database toolkit to developers: one-click download [installation](s-install.md#singleton-installation), automatic [configuration](v-config.md#configure); one-click deployment of various open-source databases, one-click migration backup, expansion, and reduction, greatly lowering the threshold of database management use, mass production DBA!
* Pigsty can simplify database deployment and delivery, solve the problem of unified environment configuration: whether thousands of databases tens of thousands of core production environments, or a local 1C1G laptop can be fully operational; Vagrant-based [local sandbox](d-sandbox.md) and Terraform-based [multi-cloud deployment](d-sandbox.md#cloud-sandbox), cloud on cloud off, pull up with one click!

[![](_media/interface.jpg)](s-install.md)



## Open Source RDS

> Alternative for RDS!

* Pigsty can save 50% - 80% of database hardware and software costs compared to cloud vendor RDS with a lower usage threshold and richer features, and junior R&D staff can manage hundreds of databases on their own.
* Pigsty is modular and can be freely combined and extended on demand. It can [deploy](d-deploy.md) and [manage](r-sop.md) various databases in a production environment, or just use them as a host to monitor; it can be used to develop data [database visualization demos](t-application.md) or support various [SaaS applications](t-docker.md).

* Open source, free production-grade database solution to fill in the last missing piece of the cloud-native ecosystem. Stable and reliable, proven over time in large-scale production deployments, with optional professional technical support services.

[![](_media/overview-monitor.jpg)](http://demo.pigsty.cc)



-----------------------



## High Availability

> Self-healing & Auto-Piloting.

Taking PostgreSQL as an example, Pigsty creates a database cluster that is **distributed and highly available** [database cluster](c-arch.md#PGSQL-Cluster). As long as any instance of the cluster survives, the cluster can provide complete [read-write service](c-service.md#primary-service) and [read-only service](c-service.md#replica-service) to the outside world.

Pigsty's high availability architecture has been tested in production environments. Pigsty uses Patroni + Consul for fault detection, Fencing, automatic failover, and HAProxy, VIP, or DNS for automatic traffic switching, achieving a complete high availability solution at a very low complexity cost, allowing the master-slave architecture of the database to be used with a cloth-like experience. Database-like experience.

The database cluster can automatically perform fault detection and master-slave switching, and common faults can be self-healing within seconds to tens of seconds: RTO < 1min for master failure, read-only traffic is almost unaffected, [synchronous cluster](d-pgsql.md#sync-standby) RPO = 0 without data loss.

Each database instance in the database cluster is idempotent in use, and any instance can provide full read and write services through the built-in load balancing component HAProxy. Anyone or more Haproxy instances can act as a load balancer for the cluster and distribute traffic through health checks, shielding the cluster members from the outside world. Users can flexibly define [services](c-service.md#service) through config and [access](c-service.md#access) through various optional methods.

![](_media/HA-PGSQL.svg)





## Ultimate Observability

> You can't manage you don't measure.

Monitoring systems provide metrics on the state of the system and are the cornerstone of operations and maintenance management. [[DEMO](http://demo.pigsty.cc)]

Pigsty comes with a professional-grade monitoring system designed for large-scale database cluster management, based on industry best practices, using Prometheus, Alertmanager, Grafana, and Loki as the monitoring infrastructure. Open source, easy to customize, reusable, portable, no vendor lock-in.

Pigsty is unmatched in PostgreSQL monitoring, presenting about 1200+ categories of metrics through 30+ monitoring panels and thousands of dashboards, covering detailed information from the big global picture to individual objects. Compared with similar products, the coverage of metrics and the richness of monitoring panels are unparalleled, providing irreplaceable value for professional users. The appropriate level of detail is designed to provide an intuitive and convenient management experience for amateur users.

Pigsty's monitoring system can be used to monitor all kinds of database instances deployed natively: PGSQL, REDIS, GPSQL, etc. It can also be used [standalone](d-monly.md) to monitor existing database instances or remote cloud vendor RDS, or just as a host monitoring, it can also be used as a showcase for data visualization works.

![](_media/overview-monitor.jpg)







## Handy Toolbox

> Every additional command line in the install script halves the number of users.

Pigsty takes ease-of-use to the extreme: one command installs and pulls up all components, ready to install in 10 minutes, no dependency on containers and Kubernetes, no Internet access required when using offline packages, and a very low threshold for getting started.

Pigsty has two typical usage models: **Standalone** and **Cluster**. It can run completely on local single-core virtual machines and can be used for large-scale production environment database management. Simple operation and maintenance, no worries, no fuss, a one-time solution to all kinds of problems in production environments and personal use of PG.

In **standalone mode**, Pigsty deploys a complete **infrastructure runtime** with a single-node PostgreSQL **database cluster** on that node. For individual users, simple scenarios, and small and micro businesses, you can use this database right out of the box. The single-node model itself is fully functional and self-manageable and comes with a fully-armed and ready-to-use PG database for software development, testing, experiment, demonstration; or data cleansing, analysis, visualization, storage, or direct support for upper-tier applications: Gitlab, Jira, Confluence, UF, Kingdee, Qunhui, etc. ......

Pigsty has a built-in database management solution with Ansible as the core and is based on this package of command-line tools and graphical interface. It integrates the core functions of database management, including database cluster creation, destruction, expansion and contraction, user, database and service creation, etc.

What's more, Pigsty packages and provides a complete set of application runtime, which allows users to use the node to manage any number of database clusters. You can initiate control from the node where Pigsty is installed (aka "meta node") to bring more nodes under Pigsty's management. You can use it to monitor existing database instances (including cloud vendor RDS) or deploy your own highly available fail-safe PostgreSQL database cluster directly on the node, as well as other kinds of applications or databases, such as [Redis](d-redis.md) and [MatrixDB](d-matrixdb.md), and Get real-time insights about nodes, databases, and applications.

![](_media/SANDBOX.gif)

In addition, Pigsty provides templates for **Local Sandbox** and **Multi-Cloud Deployment** based on Vagrant and Terraform, so you can prepare the resources you need for your Pigsty deployment with one click.



## Database as Code

A database is a software that manages the data, and a control system is software that manages the database.


Pigsty adopts the design philosophy of *Infra as Data*, using a declarative configuration similar to Kubernetes, with a large number of optional configuration options to describe the database and the operating environment, and an idempotent preconfigured script to automatically create the required database clusters, providing a private cloud experience.

Pigsty creates the required database clusters from bare metal nodes in minutes based on a list of user config files.

For example, creating a one-master-two-slave database cluster `pg-test` on three machines requires only a few lines of config and a single command `pgsql.yml -l pg-test` to create a highly available database cluster as described in the following section.

![](_media/PROVISION.gif)

<details>
<summary>Example: Customize PGSQL Clusters</summary>

```yaml
#----------------------------------#
# cluster: pg-meta (on meta node)  #
#----------------------------------#
# pg-meta is the default SINGLE-NODE pgsql cluster deployed on meta node (10.10.10.10)
# if you have multiple n meta nodes, consider deploying pg-meta as n-node cluster too

pg-meta:                                # required, ansible group name , pgsql cluster name. should be unique among environment
  hosts:                                # `<cluster>.hosts` holds instances definition of this cluster
    10.10.10.10:                        # INSTANCE-LEVEL CONFIG: ip address is the key. values are instance level config entries (dict)
      pg_seq: 1                         # required, unique identity parameter (+integer) among pg_cluster
      pg_role: primary                  # required, pg_role is mandatory identity parameter, primary|replica|offline|delayed
      pg_offline_query: true            # instance with `pg_offline_query: true` will take offline traffic (saga, etl,...)
      # some variables can be overwritten on instance level. e.g: pg_upstream, pg_weight, etc...
    #---------------
    # mandatory                         # all configuration above (`ip`, `pg_seq`, `pg_role`) and `pg_cluster` are mandatory
    #---------------
  vars:                                 # `<cluster>.vars` holds CLUSTER LEVEL CONFIG of this pgsql cluster
    pg_cluster: pg-meta                 # required, pgsql cluster name, unique among cluster, used as namespace of cluster resources

    #---------------
    # optional                          # all configuration below are OPTIONAL for a pgsql cluster (Overwrite global default)
    #---------------
    pg_version: 14                      # pgsql version to be installed (use global version if missing)
    node_tune: tiny                     # node optimization profile: {oltp|olap|crit|tiny}, use tiny for vm sandbox
    pg_conf: tiny.yml                   # pgsql template:  {oltp|olap|crit|tiny}, use tiny for sandbox
    patroni_mode: default               # entering patroni pause mode after bootstrap  {default|pause|remove}
    patroni_watchdog_mode: off          # disable patroni watchdog on meta node        {off|require|automatic}
    pg_lc_ctype: en_US.UTF8             # use en_US.UTF8 locale for i18n char support  (required by `pg_trgm`)

    #---------------
    # biz databases                     # Defining Business Databases (Optional)
    #---------------
    pg_databases:                       # define business databases on this cluster, array of database definition
      # define the default `meta` database
      - name: meta                      # required, `name` is the only mandatory field of a database definition
        baseline: cmdb.sql              # optional, database sql baseline path, (relative path among ansible search path, e.g files/)
        # owner: postgres               # optional, database owner, postgres by default
        # template: template1           # optional, which template to use, template1 by default
        # encoding: UTF8                # optional, database encoding, UTF8 by default. (MUST same as template database)
        # locale: C                     # optional, database locale, C by default.  (MUST same as template database)
        # lc_collate: C                 # optional, database collate, C by default. (MUST same as template database)
        # lc_ctype: C                   # optional, database ctype, C by default.   (MUST same as template database)
        # tablespace: pg_default        # optional, default tablespace, 'pg_default' by default.
        # allowconn: true               # optional, allow connection, true by default. false will disable connect at all
        # revokeconn: false             # optional, revoke public connection privilege. false by default. (leave connect with grant option to owner)
        # pgbouncer: true               # optional, add this database to pgbouncer database list? true by default
        comment: pigsty meta database   # optional, comment string for this database
        connlimit: -1                   # optional, database connection limit, default -1 disable limit
        schemas: [pigsty]               # optional, additional schemas to be created, array of schema names
        extensions:                     # optional, additional extensions to be installed: array of schema definition `{name,schema}`
          - { name: adminpack, schema: pg_catalog }    # install adminpack to pg_catalog
          - { name: postgis, schema: public }          # if schema is omitted, extension will be installed according to search_path.
          - { name: timescaledb }                      # some extensions are not relocatable, you can just omit the schema part

      # define an additional database named grafana & prometheus (optional)
      # - { name: grafana,    owner: dbuser_grafana    , revokeconn: true , comment: grafana    primary database }
      # - { name: prometheus, owner: dbuser_prometheus , revokeconn: true , comment: prometheus primary database , extensions: [{ name: timescaledb }]}

    #---------------
    # biz users                         # Defining Business Users (Optional)
    #---------------
    pg_users:                           # define business users/roles on this cluster, array of user definition
      # define admin user for meta database (This user are used for pigsty app deployment by default)
      - name: dbuser_meta               # required, `name` is the only mandatory field of a user definition
        password: md5d3d10d8cad606308bdb180148bf663e1  # md5 salted password of 'DBUser.Meta'
        # optional, plain text and md5 password are both acceptable (prefixed with `md5`)
        login: true                     # optional, can login, true by default  (new biz ROLE should be false)
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
        # search_path: public         # key value config parameters according to postgresql documentation (e.g: use pigsty as default search_path)
      - {name: dbuser_view , password: DBUser.Viewer  ,pgbouncer: true ,roles: [dbrole_readonly], comment: read-only viewer for meta database}

      # define additional business users for prometheus & grafana (optional)
      - {name: dbuser_grafana    , password: DBUser.Grafana    ,pgbouncer: true ,roles: [dbrole_admin], comment: admin user for grafana database }
      - {name: dbuser_prometheus , password: DBUser.Prometheus ,pgbouncer: true ,roles: [dbrole_admin], comment: admin user for prometheus database , createrole: true }

    #---------------
    # hba rules                                         # Defining extra HBA rules on this cluster (Optional)
    #---------------
    pg_hba_rules_extra:                                 # Extra HBA rules to be installed on this cluster
      - title: reject grafana non-local access          # required, rule title (used as hba description & comment string)
        role: common                                    # required, which roles will be applied? ('common' applies to all roles)
        rules:                                          # required, rule content: array of hba string
          - local   grafana         dbuser_grafana                          md5
          - host    grafana         dbuser_grafana      127.0.0.1/32        md5
          - host    grafana         dbuser_grafana      10.10.10.10/32      md5

    vip_mode: l2                        # setup a level-2 vip for cluster pg-meta
    vip_address: 10.10.10.2             # virtual ip address that binds to primary instance of cluster pg-meta
    vip_cidrmask: 8                     # cidr network mask length
    vip_interface: eth1                 # interface to add virtual ip

```

</details>


In addition, in addition to PostgreSQL, support for Redis deployment and monitoring has been provided since Pigsty v1.3
<details>
<summary>Example: Redis Cache Cluster</summary>

```yaml
#----------------------------------#
# redis sentinel example           #
#----------------------------------#
redis-meta:
  hosts:
    10.10.10.10:
      redis_node: 1
      redis_instances:  { 6001 : {} ,6002 : {} , 6003 : {} }
  vars:
    redis_cluster: redis-meta
    redis_mode: sentinel
    redis_max_memory: 128MB

#----------------------------------#
# redis cluster example            #
#----------------------------------#
redis-test:
  hosts:
    10.10.10.11:
      redis_node: 1
      redis_instances: { 6501 : {} ,6502 : {} ,6503 : {} ,6504 : {} ,6505 : {} ,6506 : {} }
    10.10.10.12:
      redis_node: 2
      redis_instances: { 6501 : {} ,6502 : {} ,6503 : {} ,6504 : {} ,6505 : {} ,6506 : {} }
  vars:
    redis_cluster: redis-test           # name of this redis 'cluster'
    redis_mode: cluster                 # standalone,cluster,sentinel
    redis_max_memory: 64MB              # max memory used by each redis instance
    redis_mem_policy: allkeys-lru       # memory eviction policy

#----------------------------------#
# redis standalone example         #
#----------------------------------#
redis-common:
  hosts:
    10.10.10.13:
      redis_node: 1
      redis_instances:
        6501: {}
        6502: { replica_of: '10.10.10.13 6501' }
        6503: { replica_of: '10.10.10.13 6501' }
  vars:
    redis_cluster: redis-common         # name of this redis 'cluster'
    redis_mode: standalone              # standalone,cluster,sentinel
    redis_max_memory: 64MB              # max memory used by each redis instance
```

</details>


Starting with Pigsty v1.4, initial support for MatrixDB (Greenplum7) is provided
<details>
<summary>Example: MatrixDB Data WareHouse</summary>

```yaml
#----------------------------------#
# cluster: mx-mdw (gp master)
#----------------------------------#
mx-mdw:
  hosts:
    10.10.10.10: { pg_seq: 1, pg_role: primary , nodename: mx-mdw-1 }
  vars:
    gp_role: master          # this cluster is used as greenplum master
    pg_shard: mx             # pgsql sharding name & gpsql deployment name
    pg_cluster: mx-mdw       # this master cluster name is mx-mdw
    pg_databases:
      - { name: matrixmgr , extensions: [ { name: matrixdbts } ] }
      - { name: meta }
    pg_users:
      - { name: meta , password: DBUser.Meta , pgbouncer: true }
      - { name: dbuser_monitor , password: DBUser.Monitor , roles: [ dbrole_readonly ], superuser: true }
    
    pgbouncer_enabled: true                # enable pgbouncer for greenplum master
    pgbouncer_exporter_enabled: false      # enable pgbouncer_exporter for greenplum master
    pg_exporter_params: 'host=127.0.0.1&sslmode=disable'  # use 127.0.0.1 as local monitor host

#----------------------------------#
# cluster: mx-sdw (gp master)
#----------------------------------#
mx-sdw:
  hosts:
    10.10.10.11:
      nodename: mx-sdw-1        # greenplum segment node
      pg_instances:             # greenplum segment instances
        6000: { pg_cluster: mx-seg1, pg_seq: 1, pg_role: primary , pg_exporter_port: 9633 }
        6001: { pg_cluster: mx-seg2, pg_seq: 2, pg_role: replica , pg_exporter_port: 9634 }
    10.10.10.12:
      nodename: mx-sdw-2
      pg_instances:
        6000: { pg_cluster: mx-seg2, pg_seq: 1, pg_role: primary , pg_exporter_port: 9633  }
        6001: { pg_cluster: mx-seg3, pg_seq: 2, pg_role: replica , pg_exporter_port: 9634  }
    10.10.10.13:
      nodename: mx-sdw-3
      pg_instances:
        6000: { pg_cluster: mx-seg3, pg_seq: 1, pg_role: primary , pg_exporter_port: 9633 }
        6001: { pg_cluster: mx-seg1, pg_seq: 2, pg_role: replica , pg_exporter_port: 9634 }
  vars:
    gp_role: segment               # these are nodes for gp segments
    pg_shard: mx                   # pgsql sharding name & gpsql deployment name
    pg_cluster: mx-sdw             # these segment clusters name is mx-sdw
    pg_preflight_skip: true        # skip preflight check (since pg_seq & pg_role & pg_cluster not exists)
    pg_exporter_config: pg_exporter_basic.yml                             # use basic config to avoid segment server crash
    pg_exporter_params: 'options=-c%20gp_role%3Dutility&sslmode=disable'  # use gp_role = utility to connect to segments

```

</details>



## Ubiquitous Deployment

Pigsty can use Vagrant and Virtualbox to pull up and install the required virtual machine environment on your own laptop, or through Terraform, automatically request ECS/VPC resources from your cloud provider, creating and destroying them with a single click.

The virtual machines in the sandbox environment have fixed resource names and IP addresses, making them very suitable for software development testing and experimental demonstrations.

The default sandbox configuration is a single node with 2 cores and 4GB, IP address 10.10.10.10, with a single database instance named `pg-meta-1` deployed.

A full version of the sandbox is also available in a four-node version with three additional database nodes, which can be used to fully demonstrate the capabilities of Pigsty's highly available architecture and monitoring system.



[![](_media/SANDBOX.gif)](d-sandbox.md)

<details>
<summary>System Requirements</summary>
**System Requirements**

* Linux kernel, x86_64 processor
* Use CentOS 7 / RedHat 7 / Oracle Linux 7 or other equivalent operating system distribution
* CentOS 7.8.2003 x86_64 is highly recommended and has been tested in production environments for a long time

**Single Node Basic  Specifications**

* Min specification: 1 core, 1GB (OOM prone, at least 2GB of RAM recommended)
* Recommended specifications: 2 cores, 4GB (sandbox default configuration)
* A single PostgreSQL instance `pg-meta-1` will be deployed
* In the sandbox, the IP of this node is fixed to `10.10.10.10`

**Four node basic specifications** 

* The meta node requirements are the same as described for a single node

* Deploy an additional three-node PostgreSQL database cluster `pg-test`
* Common database node with min specs: 1 core, 1GB, 2GB RAM recommended.
* Three nodes with fixed IP addresses: `10.10.10.11`, `10.10.10.12`, `10.10.10.13`

</details>







## Versatile Scenario

> One-click to pull up production SaaS applications, data analysis quickly, low code development visualization large screen

### SaaS Software

Pigsty installs Docker by default on the meta node, and you can pull up all kinds of SaaS applications with one click: Gitlab, an open-source private code hosting platform; Discourse, an open-source forum; Mastodon, an open-source social network; Odoo, an open-source ERP software; and UFIDA, Kingdee, and other software.

You can use Docker to pull up stateless parts, modify their database connection strings to use external databases, and get a silky smooth cloud-native management experience with production-grade data persistence. For more details, please refer to [Tutorial: Docker Application](t-docker.md).


### Data Analysis

Pigsty is both a battery-include PostgreSQL distribution and can be used as a data analysis environment, or to make low-code visualization applications. You can go directly from SQL data processing to Echarts plotting in one step, or you can use more elaborate workflows: for example, using PG as the main database, storing data and implementing business logic with SQL; using the built-in PostgREST to automate the back-end API, using the built-in JupyterLab to perform complex data analysis in Python, and using Echarts for data visualization, and Grafana for interaction capabilities.

Pigsty comes with several sample applications for reference.

* Analysis of PG CSV log samples [`pglog`](http://demo.pigsty.cc/d/pglog-overview)
* Visualization of new crown outbreak data [`covid`](http://demo.pigsty.cc/d/covid-overview)
* The global surface weather station data query [`isd`](http://demo.pigsty.cc/d/isd-overview) 
* Database prevalence ranking trend [`dbeng`](http://demo.pigsty.cc/d/dbeng-overview) 
* Query the work commuting schedule of a large factory's [`worktime`](http://demo.pigsty.cc/d/worktime-query) 

![](_media/overview-covid.jpg)



## Safety and Thrifty

> Pigsty can reduce the total cost of ownership of a database by 50% to 80% and put the data in the hands of the users themselves!

The public cloud database/RDS is a so-called "out-of-the-box" solution, but it delivers a long way from satisfying users: expensive compared to building your own database, many features that require super-user privileges are neutered, stupid UI and pot-luck features, but among all the problems, the most important one is the cloud software **safty** and **cost** issues.

#### Safty

- Software that runs on your own computer can continue to run even if the software provider goes out of business. But if the company/department providing the cloud software goes out of business or decides to stop supporting it, that software won't work, and the data you created with that software is locked up. Because the data is only stored in the cloud, not on your own server's disk, and the only compensation you can expect is usually a chicken scratch voucher.
- The problem of not being able to customize or scale is further exacerbated in cloud databases. Cloud databases typically do not offer database super users to users, which locks out a whole host of advanced features, as well as the ability to add extensions on your own. In contrast, 'stream replication', 'high availability', which should be standard in databases, are often sold to users as value-added items.
- Cloud services may suddenly suspend your account without warning or recourse. You could be judged by an automated system to be in violation of the TOS when you are completely innocent: undocumented use of ports 80 & 53, account blasted and used to send malware or phishing emails, triggering a breach of the TOS. Or hammered over by a cloud vendor for some political reason, such as Parler.
- The domestic habit of not using SaaS to insist on self-research or open-source is educated by the poor ecological industrial environment for real money. Putting your core asset -- data, on someone else's storage is just like leaving gold over the counter. There is nothing you can do to prevent, monitor, or even be aware of cloud vendors, or simply malicious or curious OPS and DBAs snooping around and stealing your precious data.

Not so with Pigsty, which can be deployed anywhere, including on your own servers. It is open source and free, requires no License, no Internet access, and does not collect any user data. You can run it on your own server until the sea runs out.

#### Thrifty

The cost of cloud databases is another issue: saving money is an immediate need for users. Public cloud vendors' RDS may have advantages over traditional commercial databases, but they are still sky-high before building their own open-source databases. According to statistics, the comprehensive holding cost of RDS is up to **2~3x higher** than self-build based on cloud servers, and even higher **5~10 times higher** than self-build hosted by IDC.

| 52C/400GB/3TB x 2 | Price 5Y | Cost/Year |
| ----------------- | -------- | --------- |
| IDC & Your own    | 810K ¥   | 160K ¥    |
| ECS               | 310K ¥   | 63K ¥     |
| RDS               | 150K ¥   | 30K ¥     |

Pigsty has significant cost advantages over using a cloud database. For example, you can buy **the same size cloud server** for half the overhead of a cloud database and deploy the database yourself using Pigsty. In this case, you can enjoy most of the ease and convenience of managing a public cloud (IaaS), while instantly saving more than half the overhead.

What's more, Pigsty can significantly improve user performance: it allows one or two senior DBAs to leave all the trivial chores to the software and easily manage hundreds of database clusters; it also allows a junior R&D staff, after a simple learning training, can quickly reach a senior DBA's cheap 70% correct level.

**Pigsty open source and free, in the premise of providing similar or even exceed the cloud vendor RDS experience, can reduce the comprehensive cost of ownership of the database by 50% ~ 80%, and let the data really control in the hands of the user himself! **
