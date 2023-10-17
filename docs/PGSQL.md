# PGSQL

> **The most advanced open-source relational database in the world!**
>
> With battery-included observability, reliability, and maintainability powered by Pigsty 


## Concept

> Overview of PostgreSQL in Pigsty

- [Architecture](PGSQL-ARCH)
- [Configuration](PGSQL-CONF)
- [Extensions](PGSQL-EXTENSION)
- [Database](PGSQL-DB)
- [User/Role](PGSQL-USER)
- [Service/Access](PGSQL-SVC)
- [Authentication](PGSQL-HBA)
- [Access Control](PGSQL-ACL)
- [Administration](PGSQL-ADMIN)
- [Backup & PITR](PGSQL-PITR)
- [Monitor](PGSQL-MONITOR)
- [Migration](PGSQL-MIGRATION)


----------------

## Configuration

> [Describe](PGSQL-CONF) the cluster you want

- [Identity](PGSQL-CONF#identity): Parameters used for describing a PostgreSQL cluster
- [Primary](PGSQL-CONF#primary): Define a single instance cluster
- [Replica](PGSQL-CONF#replica): Define a basic HA cluster with one primary & one replica
- [Offline](PGSQL-CONF#offline): Define a dedicated instance for OLAP/ETL/Interactive queries.
- [Sync Standby](PGSQL-CONF#sync-standby): Enable synchronous commit to ensure no data loss
- [Quorum Commit](PGSQL-CONF#quorum-commit):   Use quorum sync commit for an even higher consistency level
- [Standby Cluster](PGSQL-CONF#standby-cluster): Clone an existing cluster and follow it
- [Delayed Cluster](PGSQL-CONF#delayed-cluster): Clone an existing cluster for emergency data recovery
- [Citus Cluster](PGSQL-CONF#citus-cluster): Define a Citus distributed database cluster
- [Major Version](PGSQL-CONF#major-version): Define a PostgreSQL cluster with specific major version


----------------

## Administration

> [Admin](PGSQL-ADMIN) your existing clusters

- [`Admin Cheatsheet`](PGSQL-ADMIN#cheatsheet)
- [`Create Cluster`](PGSQL-ADMIN#create-cluster)
- [`Create User`](PGSQL-ADMIN#create-user)
- [`Create Database`](PGSQL-ADMIN#create-database)
- [`Reload Service`](PGSQL-ADMIN#reload-service)
- [`Reload HBARule`](PGSQL-ADMIN#reload-hbarule)
- [`Config Cluster`](PGSQL-ADMIN#config-cluster)
- [`Append Replica`](PGSQL-ADMIN#append-replica)
- [`Remove Replica`](PGSQL-ADMIN#remove-replica)
- [`Remove Cluster`](PGSQL-ADMIN#remove-cluster)
- [`Switchover Cluster`](PGSQL-ADMIN#switchover)
- [`Backup Cluster`](PGSQL-ADMIN#backup-cluster)
- [`Restore Cluster`](PGSQL-ADMIN#restore-cluster)



----------------

## Playbook

> Materialize the cluster with idempotent [playbooks](PGSQL-PLAYBOOK)

- [`pgsql.yml`](PGSQL-PLAYBOOk#pgsqlyml) : Init HA PostgreSQL clusters or add new replicas.
- [`pgsql-rm.yml`](PGSQL-PLAYBOOk#pgsql-rmyml) : Remove PostgreSQL cluster, or remove replicas
- [`pgsql-user.yml`](PGSQL-PLAYBOOk#pgsql-useryml) : Add new business user to existing PostgreSQL cluster
- [`pgsql-db.yml`](PGSQL-PLAYBOOk#pgsql-dbyml) : Add new business database to existing PostgreSQL cluster
- [`pgsql-monitor.yml`](PGSQL-PLAYBOOk#pgsql-monitoryml) : Monitor remote PostgreSQL instance with local exporters
- [`pgsql-migration.yml`](PGSQL-PLAYBOOk#pgsql-migrationyml) : Generate Migration manual & scripts for existing PostgreSQL

<details><summary>Example: Install PGSQL module</summary>

[![asciicast](https://asciinema.org/a/566417.svg)](https://asciinema.org/a/566417)

</details>


<details><summary>Example: Remove PGSQL module</summary>

[![asciicast](https://asciinema.org/a/566418.svg)](https://asciinema.org/a/566418)

</details>



----------------

## Dashboard

There are 26 default grafana dashboards about PostgreSQL and categorized into 4 levels. Check [Dashboards](PGSQL-DASHBOARD) for details.

|                         Overview                          |                                Cluster                                |                          Instance                           |                         Database                          |
|:---------------------------------------------------------:|:---------------------------------------------------------------------:|:-----------------------------------------------------------:|:---------------------------------------------------------:|
| [PGSQL Overview](https://demo.pigsty.cc/d/pgsql-overview) |        [PGSQL Cluster](https://demo.pigsty.cc/d/pgsql-cluster)        |  [PGSQL Instance](https://demo.pigsty.cc/d/pgsql-instance)  | [PGSQL Database](https://demo.pigsty.cc/d/pgsql-database) |
|    [PGSQL Alert](https://demo.pigsty.cc/d/pgsql-alert)    |        [PGRDS Cluster](https://demo.pigsty.cc/d/pgrds-cluster)        |  [PGRDS Instance](https://demo.pigsty.cc/d/pgrds-instance)  | [PGCAT Database](https://demo.pigsty.cc/d/pgcat-database)  |
|    [PGSQL Shard](https://demo.pigsty.cc/d/pgsql-shard)    |       [PGSQL Activity](https://demo.pigsty.cc/d/pgsql-activity)       |  [PGCAT Instance](https://demo.pigsty.cc/d/pgcat-instance)  |   [PGSQL Tables](https://demo.pigsty.cc/d/pgsql-tables)   |
|                                                           |    [PGSQL Replication](https://demo.pigsty.cc/d/pgsql-replication)    |   [PGSQL Persist](https://demo.pigsty.cc/d/pgsql-persist)   |    [PGSQL Table](https://demo.pigsty.cc/d/pgsql-table)    |
|                                                           |        [PGSQL Service](https://demo.pigsty.cc/d/pgsql-service)        |     [PGSQL Proxy](https://demo.pigsty.cc/d/pgsql-proxy)     |    [PGCAT Table](https://demo.pigsty.cc/d/pgcat-table)    |
|                                                           |      [PGSQL Databases](https://demo.pigsty.cc/d/pgsql-databases)      | [PGSQL Pgbouncer](https://demo.pigsty.cc/d/pgsql-pgbouncer) |    [PGSQL Query](https://demo.pigsty.cc/d/pgsql-query)    |
|                                                           |                                                                       |   [PGSQL Session](https://demo.pigsty.cc/d/pgsql-session)   |    [PGCAT Query](https://demo.pigsty.cc/d/pgcat-query)    |
|                                                           |                                                                       |     [PGSQL Xacts](https://demo.pigsty.cc/d/pgsql-xacts)     |    [PGCAT Locks](https://demo.pigsty.cc/d/pgcat-locks)    |
|                                                           |                                                                       |   [Logs Instance](https://demo.pigsty.cc/d/logs-instance)   |   [PGCAT Schema](https://demo.pigsty.cc/d/pgcat-schema)   |



----------------

## Parameter

> API Reference for [PGSQL](PARAM#pgsql) module:

- [`PG_ID`](PARAM#pg_id)               : Calculate & Check Postgres Identity
- [`PG_BUSINESS`](PARAM#pg_business)   : Postgres Business Object Definition
- [`PG_INSTALL`](PARAM#pg_install)     : Install PGSQL Packages & Extensions
- [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) : Init a HA Postgres Cluster with Patroni
- [`PG_PROVISION`](PARAM#pg_provision) : Create users, databases, and in-database objects
- [`PG_BACKUP`](PARAM#pg_backup)       : Setup backup repo with pgbackrest
- [`PG_SERVICE`](PARAM#pg_service)     : Exposing pg service, bind vip and register DNS
- [`PG_EXPORTER`](PARAM#pg_exporter)   : Add Monitor for PGSQL Instance


<details><summary>Parameters</summary>

| Parameter                                                            | Section                              |    Type     | Level | Comment                                                                       |
|----------------------------------------------------------------------|--------------------------------------|:-----------:|:-----:|-------------------------------------------------------------------------------|
| [`pg_mode`](PARAM#pg_mode)                                           | [`PG_ID`](PARAM#pg_id)               |    enum     |   C   | pgsql cluster mode: pgsql,citus,gpsql                                         |
| [`pg_cluster`](PARAM#pg_cluster)                                     | [`PG_ID`](PARAM#pg_id)               |   string    |   C   | pgsql cluster name, REQUIRED identity parameter                               |
| [`pg_seq`](PARAM#pg_seq)                                             | [`PG_ID`](PARAM#pg_id)               |     int     |   I   | pgsql instance seq number, REQUIRED identity parameter                        |
| [`pg_role`](PARAM#pg_role)                                           | [`PG_ID`](PARAM#pg_id)               |    enum     |   I   | pgsql role, REQUIRED, could be primary,replica,offline                        |
| [`pg_instances`](PARAM#pg_instances)                                 | [`PG_ID`](PARAM#pg_id)               |    dict     |   I   | define multiple pg instances on node in `{port:ins_vars}` format              |
| [`pg_upstream`](PARAM#pg_upstream)                                   | [`PG_ID`](PARAM#pg_id)               |     ip      |   I   | repl upstream ip addr for standby cluster or cascade replica                  |
| [`pg_shard`](PARAM#pg_shard)                                         | [`PG_ID`](PARAM#pg_id)               |   string    |   C   | pgsql shard name, optional identity for sharding clusters                     |
| [`pg_group`](PARAM#pg_group)                                         | [`PG_ID`](PARAM#pg_id)               |     int     |   C   | pgsql shard index number, optional identity for sharding clusters             |
| [`gp_role`](PARAM#gp_role)                                           | [`PG_ID`](PARAM#pg_id)               |    enum     |   C   | greenplum role of this cluster, could be master or segment                    |
| [`pg_exporters`](PARAM#pg_exporters)                                 | [`PG_ID`](PARAM#pg_id)               |    dict     |   C   | additional pg_exporters to monitor remote postgres instances                  |
| [`pg_offline_query`](PARAM#pg_offline_query)                         | [`PG_ID`](PARAM#pg_id)               |    bool     |   I   | set to true to enable offline query on this instance                          |
| [`pg_users`](PARAM#pg_users)                                         | [`PG_BUSINESS`](PARAM#pg_business)   |   user[]    |   C   | postgres business users                                                       |
| [`pg_databases`](PARAM#pg_databases)                                 | [`PG_BUSINESS`](PARAM#pg_business)   | database[]  |   C   | postgres business databases                                                   |
| [`pg_services`](PARAM#pg_services)                                   | [`PG_BUSINESS`](PARAM#pg_business)   |  service[]  |   C   | postgres business services                                                    |
| [`pg_hba_rules`](PARAM#pg_hba_rules)                                 | [`PG_BUSINESS`](PARAM#pg_business)   |    hba[]    |   C   | business hba rules for postgres                                               |
| [`pgb_hba_rules`](PARAM#pgb_hba_rules)                               | [`PG_BUSINESS`](PARAM#pg_business)   |    hba[]    |   C   | business hba rules for pgbouncer                                              |
| [`pg_replication_username`](PARAM#pg_replication_username)           | [`PG_BUSINESS`](PARAM#pg_business)   |  username   |   G   | postgres replication username, `replicator` by default                        |
| [`pg_replication_password`](PARAM#pg_replication_password)           | [`PG_BUSINESS`](PARAM#pg_business)   |  password   |   G   | postgres replication password, `DBUser.Replicator` by default                 |
| [`pg_admin_username`](PARAM#pg_admin_username)                       | [`PG_BUSINESS`](PARAM#pg_business)   |  username   |   G   | postgres admin username, `dbuser_dba` by default                              |
| [`pg_admin_password`](PARAM#pg_admin_password)                       | [`PG_BUSINESS`](PARAM#pg_business)   |  password   |   G   | postgres admin password in plain text, `DBUser.DBA` by default                |
| [`pg_monitor_username`](PARAM#pg_monitor_username)                   | [`PG_BUSINESS`](PARAM#pg_business)   |  username   |   G   | postgres monitor username, `dbuser_monitor` by default                        |
| [`pg_monitor_password`](PARAM#pg_monitor_password)                   | [`PG_BUSINESS`](PARAM#pg_business)   |  password   |   G   | postgres monitor password, `DBUser.Monitor` by default                        |
| [`pg_dbsu_password`](PARAM#pg_dbsu_password)                         | [`PG_BUSINESS`](PARAM#pg_business)   |  password   |  G/C  | dbsu password, empty string means no dbsu password by default                 |
| [`pg_dbsu`](PARAM#pg_dbsu)                                           | [`PG_INSTALL`](PARAM#pg_install)     |  username   |   C   | os dbsu name, postgres by default, better not change it                       |
| [`pg_dbsu_uid`](PARAM#pg_dbsu_uid)                                   | [`PG_INSTALL`](PARAM#pg_install)     |     int     |   C   | os dbsu uid and gid, 26 for default postgres users and groups                 |
| [`pg_dbsu_sudo`](PARAM#pg_dbsu_sudo)                                 | [`PG_INSTALL`](PARAM#pg_install)     |    enum     |   C   | dbsu sudo privilege, none,limit,all,nopass. limit by default                  |
| [`pg_dbsu_home`](PARAM#pg_dbsu_home)                                 | [`PG_INSTALL`](PARAM#pg_install)     |    path     |   C   | postgresql home directory, `/var/lib/pgsql` by default                        |
| [`pg_dbsu_ssh_exchange`](PARAM#pg_dbsu_ssh_exchange)                 | [`PG_INSTALL`](PARAM#pg_install)     |    bool     |   C   | exchange postgres dbsu ssh key among same pgsql cluster                       |
| [`pg_version`](PARAM#pg_version)                                     | [`PG_INSTALL`](PARAM#pg_install)     |    enum     |   C   | postgres major version to be installed, 15 by default                         |
| [`pg_bin_dir`](PARAM#pg_bin_dir)                                     | [`PG_INSTALL`](PARAM#pg_install)     |    path     |   C   | postgres binary dir, `/usr/pgsql/bin` by default                              |
| [`pg_log_dir`](PARAM#pg_log_dir)                                     | [`PG_INSTALL`](PARAM#pg_install)     |    path     |   C   | postgres log dir, `/pg/log/postgres` by default                               |
| [`pg_packages`](PARAM#pg_packages)                                   | [`PG_INSTALL`](PARAM#pg_install)     |  string[]   |   C   | pg packages to be installed, `${pg_version}` will be replaced                 |
| [`pg_extensions`](PARAM#pg_extensions)                               | [`PG_INSTALL`](PARAM#pg_install)     |  string[]   |   C   | pg extensions to be installed, `${pg_version}` will be replaced               |
| [`pg_safeguard`](PARAM#pg_safeguard)                                 | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    bool     | G/C/A | prevent purging running postgres instance? false by default                   |
| [`pg_clean`](PARAM#pg_clean)                                         | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    bool     | G/C/A | purging existing postgres during pgsql init? true by default                  |
| [`pg_data`](PARAM#pg_data)                                           | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    path     |   C   | postgres data directory, `/pg/data` by default                                |
| [`pg_fs_main`](PARAM#pg_fs_main)                                     | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    path     |   C   | mountpoint/path for postgres main data, `/data` by default                    |
| [`pg_fs_bkup`](PARAM#pg_fs_bkup)                                     | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    path     |   C   | mountpoint/path for pg backup data, `/data/backup` by default                 |
| [`pg_storage_type`](PARAM#pg_storage_type)                           | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    enum     |   C   | storage type for pg main data, SSD,HDD, SSD by default                        |
| [`pg_dummy_filesize`](PARAM#pg_dummy_filesize)                       | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    size     |   C   | size of `/pg/dummy`, hold 64MB disk space for emergency use                   |
| [`pg_listen`](PARAM#pg_listen)                                       | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    ip(s)    |  C/I  | postgres/pgbouncer listen addresses, comma separated list                     |
| [`pg_port`](PARAM#pg_port)                                           | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    port     |   C   | postgres listen port, 5432 by default                                         |
| [`pg_localhost`](PARAM#pg_localhost)                                 | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    path     |   C   | postgres unix socket dir for localhost connection                             |
| [`pg_namespace`](PARAM#pg_namespace)                                 | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    path     |   C   | top level key namespace in etcd, used by patroni & vip                        |
| [`patroni_enabled`](PARAM#patroni_enabled)                           | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    bool     |   C   | if disabled, no postgres cluster will be created during init                  |
| [`patroni_mode`](PARAM#patroni_mode)                                 | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    enum     |   C   | patroni working mode: default,pause,remove                                    |
| [`patroni_port`](PARAM#patroni_port)                                 | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    port     |   C   | patroni listen port, 8008 by default                                          |
| [`patroni_log_dir`](PARAM#patroni_log_dir)                           | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    path     |   C   | patroni log dir, `/pg/log/patroni` by default                                 |
| [`patroni_ssl_enabled`](PARAM#patroni_ssl_enabled)                   | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    bool     |   G   | secure patroni RestAPI communications with SSL?                               |
| [`patroni_watchdog_mode`](PARAM#patroni_watchdog_mode)               | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    enum     |   C   | patroni watchdog mode: automatic,required,off. off by default                 |
| [`patroni_username`](PARAM#patroni_username)                         | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |  username   |   C   | patroni restapi username, `postgres` by default                               |
| [`patroni_password`](PARAM#patroni_password)                         | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |  password   |   C   | patroni restapi password, `Patroni.API` by default                            |
| [`patroni_citus_db`](#patroni_citus_db)                              | [`PG_BOOTSTRAP`](#pg_bootstrap)      |   string    |   C   | citus database managed by patroni, postgres by default                        |
| [`pg_conf`](PARAM#pg_conf)                                           | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    enum     |   C   | config template: oltp,olap,crit,tiny. `oltp.yml` by default                   |
| [`pg_max_conn`](PARAM#pg_max_conn)                                   | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |     int     |   C   | postgres max connections, `auto` will use recommended value                   |
| [`pg_shared_buffer_ratio`](PARAM#pg_shared_buffer_ratio)             | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    float    |   C   | postgres shared buffer memory ratio, 0.25 by default, 0.1~0.4                 |
| [`pg_rto`](PARAM#pg_rto)                                             | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |     int     |   C   | recovery time objective in seconds, `30s` by default                          |
| [`pg_rpo`](PARAM#pg_rpo)                                             | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |     int     |   C   | recovery point objective in bytes, `1MiB` at most by default                  |
| [`pg_libs`](PARAM#pg_libs)                                           | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |   string    |   C   | preloaded libraries, `timescaledb,pg_stat_statements,auto_explain` by default |
| [`pg_delay`](PARAM#pg_delay)                                         | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |  interval   |   I   | replication apply delay for standby cluster leader                            |
| [`pg_checksum`](PARAM#pg_checksum)                                   | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    bool     |   C   | enable data checksum for postgres cluster?                                    |
| [`pg_pwd_enc`](PARAM#pg_pwd_enc)                                     | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    enum     |   C   | passwords encryption algorithm: md5,scram-sha-256                             |
| [`pg_encoding`](PARAM#pg_encoding)                                   | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    enum     |   C   | database cluster encoding, `UTF8` by default                                  |
| [`pg_locale`](PARAM#pg_locale)                                       | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    enum     |   C   | database cluster local, `C` by default                                        |
| [`pg_lc_collate`](PARAM#pg_lc_collate)                               | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    enum     |   C   | database cluster collate, `C` by default                                      |
| [`pg_lc_ctype`](PARAM#pg_lc_ctype)                                   | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    enum     |   C   | database character type, `en_US.UTF8` by default                              |
| [`pgbouncer_enabled`](PARAM#pgbouncer_enabled)                       | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    bool     |   C   | if disabled, pgbouncer will not be launched on pgsql host                     |
| [`pgbouncer_port`](PARAM#pgbouncer_port)                             | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    port     |   C   | pgbouncer listen port, 6432 by default                                        |
| [`pgbouncer_log_dir`](PARAM#pgbouncer_log_dir)                       | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    path     |   C   | pgbouncer log dir, `/pg/log/pgbouncer` by default                             |
| [`pgbouncer_auth_query`](PARAM#pgbouncer_auth_query)                 | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    bool     |   C   | query postgres to retrieve unlisted business users?                           |
| [`pgbouncer_poolmode`](PARAM#pgbouncer_poolmode)                     | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    enum     |   C   | pooling mode: transaction,session,statement, transaction by default           |
| [`pgbouncer_sslmode`](PARAM#pgbouncer_sslmode)                       | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap) |    enum     |   C   | pgbouncer client ssl mode, disable by default                                 |
| [`pg_provision`](PARAM#pg_provision)                                 | [`PG_PROVISION`](PARAM#pg_provision) |    bool     |   C   | provision postgres cluster after bootstrap                                    |
| [`pg_init`](PARAM#pg_init)                                           | [`PG_PROVISION`](PARAM#pg_provision) |   string    |  G/C  | provision init script for cluster template, `pg-init` by default              |
| [`pg_default_roles`](PARAM#pg_default_roles)                         | [`PG_PROVISION`](PARAM#pg_provision) |   role[]    |  G/C  | default roles and users in postgres cluster                                   |
| [`pg_default_privileges`](PARAM#pg_default_privileges)               | [`PG_PROVISION`](PARAM#pg_provision) |  string[]   |  G/C  | default privileges when created by admin user                                 |
| [`pg_default_schemas`](PARAM#pg_default_schemas)                     | [`PG_PROVISION`](PARAM#pg_provision) |  string[]   |  G/C  | default schemas to be created                                                 |
| [`pg_default_extensions`](PARAM#pg_default_extensions)               | [`PG_PROVISION`](PARAM#pg_provision) | extension[] |  G/C  | default extensions to be created                                              |
| [`pg_reload`](PARAM#pg_reload)                                       | [`PG_PROVISION`](PARAM#pg_provision) |    bool     |   A   | reload postgres after hba changes                                             |
| [`pg_default_hba_rules`](PARAM#pg_default_hba_rules)                 | [`PG_PROVISION`](PARAM#pg_provision) |    hba[]    |  G/C  | postgres default host-based authentication rules                              |
| [`pgb_default_hba_rules`](PARAM#pgb_default_hba_rules)               | [`PG_PROVISION`](PARAM#pg_provision) |    hba[]    |  G/C  | pgbouncer default host-based authentication rules                             |
| [`pgbackrest_enabled`](PARAM#pgbackrest_enabled)                     | [`PG_BACKUP`](PARAM#pg_backup)       |    bool     |   C   | enable pgbackrest on pgsql host?                                              |
| [`pgbackrest_clean`](PARAM#pgbackrest_clean)                         | [`PG_BACKUP`](PARAM#pg_backup)       |    bool     |   C   | remove pg backup data during init?                                            |
| [`pgbackrest_log_dir`](PARAM#pgbackrest_log_dir)                     | [`PG_BACKUP`](PARAM#pg_backup)       |    path     |   C   | pgbackrest log dir, `/pg/log/pgbackrest` by default                           |
| [`pgbackrest_method`](PARAM#pgbackrest_method)                       | [`PG_BACKUP`](PARAM#pg_backup)       |    enum     |   C   | pgbackrest repo method: local,minio,etc...                                    |
| [`pgbackrest_repo`](PARAM#pgbackrest_repo)                           | [`PG_BACKUP`](PARAM#pg_backup)       |    dict     |  G/C  | pgbackrest repo: https://pgbackrest.org/configuration.html#section-repository |
| [`pg_weight`](PARAM#pg_weight)                                       | [`PG_SERVICE`](PARAM#pg_service)     |     int     |   I   | relative load balance weight in service, 100 by default, 0-255                |
| [`pg_service_provider`](PARAM#pg_service_provider)                   | [`PG_SERVICE`](PARAM#pg_service)     |    enum     |  G/C  | dedicate haproxy node group name, or empty string for local nodes by default  |
| [`pg_default_service_dest`](PARAM#pg_default_service_dest)           | [`PG_SERVICE`](PARAM#pg_service)     |    enum     |  G/C  | default service destination if svc.dest='default'                             |
| [`pg_default_services`](PARAM#pg_default_services)                   | [`PG_SERVICE`](PARAM#pg_service)     |  service[]  |  G/C  | postgres default service definitions                                          |
| [`pg_vip_enabled`](PARAM#pg_vip_enabled)                             | [`PG_SERVICE`](PARAM#pg_service)     |    bool     |   C   | enable a l2 vip for pgsql primary? false by default                           |
| [`pg_vip_address`](PARAM#pg_vip_address)                             | [`PG_SERVICE`](PARAM#pg_service)     |    cidr4    |   C   | vip address in `<ipv4>/<mask>` format, require if vip is enabled              |
| [`pg_vip_interface`](PARAM#pg_vip_interface)                         | [`PG_SERVICE`](PARAM#pg_service)     |   string    |  C/I  | vip network interface to listen, eth0 by default                              |
| [`pg_dns_suffix`](PARAM#pg_dns_suffix)                               | [`PG_SERVICE`](PARAM#pg_service)     |   string    |   C   | pgsql dns suffix, '' by default                                               |
| [`pg_dns_target`](PARAM#pg_dns_target)                               | [`PG_SERVICE`](PARAM#pg_service)     |    enum     |   C   | auto, primary, vip, none, or ad hoc ip                                        |
| [`pg_exporter_enabled`](PARAM#pg_exporter_enabled)                   | [`PG_EXPORTER`](PARAM#pg_exporter)   |    bool     |   C   | enable pg_exporter on pgsql hosts?                                            |
| [`pg_exporter_config`](PARAM#pg_exporter_config)                     | [`PG_EXPORTER`](PARAM#pg_exporter)   |   string    |   C   | pg_exporter configuration file name                                           |
| [`pg_exporter_cache_ttls`](PARAM#pg_exporter_cache_ttls)             | [`PG_EXPORTER`](PARAM#pg_exporter)   |   string    |   C   | pg_exporter collector ttl stage in seconds, '1,10,60,300' by default          |
| [`pg_exporter_port`](PARAM#pg_exporter_port)                         | [`PG_EXPORTER`](PARAM#pg_exporter)   |    port     |   C   | pg_exporter listen port, 9630 by default                                      |
| [`pg_exporter_params`](PARAM#pg_exporter_params)                     | [`PG_EXPORTER`](PARAM#pg_exporter)   |   string    |   C   | extra url parameters for pg_exporter dsn                                      |
| [`pg_exporter_url`](PARAM#pg_exporter_url)                           | [`PG_EXPORTER`](PARAM#pg_exporter)   |    pgurl    |   C   | overwrite auto-generate pg dsn if specified                                   |
| [`pg_exporter_auto_discovery`](PARAM#pg_exporter_auto_discovery)     | [`PG_EXPORTER`](PARAM#pg_exporter)   |    bool     |   C   | enable auto database discovery? enabled by default                            |
| [`pg_exporter_exclude_database`](PARAM#pg_exporter_exclude_database) | [`PG_EXPORTER`](PARAM#pg_exporter)   |   string    |   C   | csv of database that WILL NOT be monitored during auto-discovery              |
| [`pg_exporter_include_database`](PARAM#pg_exporter_include_database) | [`PG_EXPORTER`](PARAM#pg_exporter)   |   string    |   C   | csv of database that WILL BE monitored during auto-discovery                  |
| [`pg_exporter_connect_timeout`](PARAM#pg_exporter_connect_timeout)   | [`PG_EXPORTER`](PARAM#pg_exporter)   |     int     |   C   | pg_exporter connect timeout in ms, 200 by default                             |
| [`pg_exporter_options`](PARAM#pg_exporter_options)                   | [`PG_EXPORTER`](PARAM#pg_exporter)   |     arg     |   C   | overwrite extra options for pg_exporter                                       |
| [`pgbouncer_exporter_enabled`](PARAM#pgbouncer_exporter_enabled)     | [`PG_EXPORTER`](PARAM#pg_exporter)   |    bool     |   C   | enable pgbouncer_exporter on pgsql hosts?                                     |
| [`pgbouncer_exporter_port`](PARAM#pgbouncer_exporter_port)           | [`PG_EXPORTER`](PARAM#pg_exporter)   |    port     |   C   | pgbouncer_exporter listen port, 9631 by default                               |
| [`pgbouncer_exporter_url`](PARAM#pgbouncer_exporter_url)             | [`PG_EXPORTER`](PARAM#pg_exporter)   |    pgurl    |   C   | overwrite auto-generate pgbouncer dsn if specified                            |
| [`pgbouncer_exporter_options`](PARAM#pgbouncer_exporter_options)     | [`PG_EXPORTER`](PARAM#pg_exporter)   |     arg     |   C   | overwrite extra options for pgbouncer_exporter                                |

</details>



## Tutorials

- Fork an existing PostgreSQL cluster.
- Create a standby cluster of an existing PostgreSQL cluster.
- Create a delayed cluster of another pgsql cluster?
- Monitoring an existing postgres instance?
- Migration from an external PostgreSQL with logical replication?
- Use MinIO as a central pgBackRest repo.
- Use dedicate etcd cluster for DCS?
- Use dedicated haproxy for exposing PostgreSQL service.
- Deploy a multi-node MinIO cluster?
- Use CMDB instead of Config as inventory.
- Use PostgreSQL as grafana backend storage ?
- Use PostgreSQL as prometheus backend storage ?
