# Postgres (ansible role)

This role will provision a postgres cluster

It is a complex role consist of several stages:

1. Precheck
    * Local inventory integrity check
2. Prepare 
    * Check exists, clean, create structure, copy scripts
3. Install
    * Install postgres, create users, admin ssh setup
4. Postgres
    * Launch and bootstrap postgres cluster
    * patroni, pg-init, pg_hba, pgpass, check
5. Pgbouncer
    * Launch and bootstrap pgbouncer     
6. Users
    * Setup business users
7. Users
    * Setup business databases
8. Register
    * Register service and datasource to meta 



### Tasks

[tasks/main.yml](tasks/main.yml)
* [`business.yml`](tasks/business.yml)
* [`install.yml`](tasks/install.yml)
* [`main.yml`](tasks/main.yml)
* [`pgbouncer.yml`](tasks/pgbouncer.yml)
* [`postgres.yml`](tasks/postgres.yml)
* [`preflight.yml`](tasks/preflight.yml)
* [`prepare.yml`](tasks/prepare.yml)
* [`register.yml`](tasks/register.yml)


```yaml
    tasks:
      postgres : Create os group postgres	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Make sure dcs group exists	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Create dbsu {{ pg_dbsu }}	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Grant dbsu nopass sudo	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Grant dbsu all sudo	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Grant dbsu limited sudo	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Config patroni watchdog support	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Add dbsu ssh no host checking	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Fetch dbsu public keys	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Exchange dbsu ssh keys	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Install offical pgdg yum repo	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Install pg packages	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Install pg extensions	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Link /usr/pgsql to current version	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Add pg bin dir to profile path	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Fix directory ownership	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Remove default postgres service	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Check necessary variables exists	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Fetch variables via pg_cluster	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Set cluster basic facts for hosts	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Assert cluster primary singleton	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Setup cluster primary ip address	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Setup repl upstream for primary	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Setup repl upstream for replicas	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Debug print instance summary	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Check for existing postgres instance	TAGS: [pg_check, pgsql, postgres, prepare]
      postgres : Set fact whether pg port is open	TAGS: [pg_check, pgsql, postgres, prepare]
      postgres : Abort due to existing postgres instance	TAGS: [pg_check, pgsql, postgres, prepare]
      postgres : Clean existing postgres instance	TAGS: [pg_check, pgsql, postgres, prepare]
      postgres : Shutdown existing postgres service	TAGS: [pg_clean, pgsql, postgres, prepare]
      postgres : Remove registerd consul service	TAGS: [pg_clean, pgsql, postgres, prepare]
      postgres : Remove postgres metadata in consul	TAGS: [pg_clean, pgsql, postgres, prepare]
      postgres : Remove existing postgres data	TAGS: [pg_clean, pgsql, postgres, prepare]
      postgres : Make sure main and backup dir exists	TAGS: [pg_dir, pgsql, postgres, prepare]
      postgres : Create postgres directory structure	TAGS: [pg_dir, pgsql, postgres, prepare]
      postgres : Create pgbouncer directory structure	TAGS: [pg_dir, pgsql, postgres, prepare]
      postgres : Create links from pgbkup to pgroot	TAGS: [pg_dir, pgsql, postgres, prepare]
      postgres : Create links from current cluster	TAGS: [pg_dir, pgsql, postgres, prepare]
      postgres : Copy pg_cluster to /pg/meta/cluster	TAGS: [pg_meta, pgsql, postgres, prepare]
      postgres : Copy pg_version to /pg/meta/version	TAGS: [pg_meta, pgsql, postgres, prepare]
      postgres : Copy pg_instance to /pg/meta/instance	TAGS: [pg_meta, pgsql, postgres, prepare]
      postgres : Copy pg_seq to /pg/meta/sequence	TAGS: [pg_meta, pgsql, postgres, prepare]
      postgres : Copy pg_role to /pg/meta/role	TAGS: [pg_meta, pgsql, postgres, prepare]
      postgres : Copy postgres scripts to /pg/bin/	TAGS: [pg_scripts, pgsql, postgres, prepare]
      postgres : Copy alias profile to /etc/profile.d	TAGS: [pg_scripts, pgsql, postgres, prepare]
      postgres : Copy psqlrc to postgres home	TAGS: [pg_scripts, pgsql, postgres, prepare]
      postgres : Setup hostname to pg instance name	TAGS: [pg_hostname, pgsql, postgres, prepare]
      postgres : Copy consul node-meta definition	TAGS: [pg_nodemeta, pgsql, postgres, prepare]
      postgres : Restart consul to load new node-meta	TAGS: [pg_nodemeta, pgsql, postgres, prepare]
      postgres : Config patroni watchdog support	TAGS: [pg_watchdog, pgsql, postgres, prepare]
      postgres : Get config parameter page count	TAGS: [pg_config, pgsql, postgres]
      postgres : Get config parameter page size	TAGS: [pg_config, pgsql, postgres]
      postgres : Tune shared buffer and work mem	TAGS: [pg_config, pgsql, postgres]
      postgres : Hanlde small size mem occasion	TAGS: [pg_config, pgsql, postgres]
      postgres : Calculate postgres mem params	TAGS: [pg_config, pgsql, postgres]
      postgres : create patroni config dir	TAGS: [pg_config, pgsql, postgres]
      postgres : use predefined patroni template	TAGS: [pg_config, pgsql, postgres]
      postgres : Render default /pg/conf/patroni.yml	TAGS: [pg_config, pgsql, postgres]
      postgres : Link /pg/conf/patroni to /pg/bin/	TAGS: [pg_config, pgsql, postgres]
      postgres : Link /pg/bin/patroni.yml to /etc/patroni/	TAGS: [pg_config, pgsql, postgres]
      postgres : Config patroni watchdog support	TAGS: [pg_config, pgsql, postgres]
      postgres : Copy patroni systemd service file	TAGS: [pg_config, pgsql, postgres]
      postgres : create patroni systemd drop-in dir	TAGS: [pg_config, pgsql, postgres]
      postgres : Copy postgres systemd service file	TAGS: [pg_config, pgsql, postgres]
      postgres : Drop-In consul dependency for patroni	TAGS: [pg_config, pgsql, postgres]
      postgres : Render default initdb scripts	TAGS: [pg_config, pgsql, postgres]
      postgres : Launch patroni on primary instance	TAGS: [pg_primary, pgsql, postgres]
      postgres : Wait for patroni primary online	TAGS: [pg_primary, pgsql, postgres]
      postgres : Wait for postgres primary online	TAGS: [pg_primary, pgsql, postgres]
      postgres : Check primary postgres service ready	TAGS: [pg_primary, pgsql, postgres]
      postgres : Check replication connectivity to primary	TAGS: [pg_primary, pgsql, postgres]
      postgres : Render init roles sql	TAGS: [pg_init, pg_init_role, pgsql, postgres]
      postgres : Render init template sql	TAGS: [pg_init, pg_init_tmpl, pgsql, postgres]
      postgres : Render default pg-init scripts	TAGS: [pg_init, pg_init_main, pgsql, postgres]
      postgres : Execute initialization scripts	TAGS: [pg_init, pg_init_exec, pgsql, postgres]
      postgres : Check primary instance ready	TAGS: [pg_init, pg_init_exec, pgsql, postgres]
      postgres : Add dbsu password to pgpass if exists	TAGS: [pg_pass, pgsql, postgres]
      postgres : Add system user to pgpass	TAGS: [pg_pass, pgsql, postgres]
      postgres : Check replication connectivity to primary	TAGS: [pg_replica, pgsql, postgres]
      postgres : Launch patroni on replica instances	TAGS: [pg_replica, pgsql, postgres]
      postgres : Wait for patroni replica online	TAGS: [pg_replica, pgsql, postgres]
      postgres : Wait for postgres replica online	TAGS: [pg_replica, pgsql, postgres]
      postgres : Check replica postgres service ready	TAGS: [pg_replica, pgsql, postgres]
      postgres : Render hba rules	TAGS: [pg_hba, pgsql, postgres]
      postgres : Reload hba rules	TAGS: [pg_hba, pgsql, postgres]
      postgres : Pause patroni	TAGS: [pg_patroni, pgsql, postgres]
      postgres : Stop patroni on replica instance	TAGS: [pg_patroni, pgsql, postgres]
      postgres : Stop patroni on primary instance	TAGS: [pg_patroni, pgsql, postgres]
      postgres : Launch raw postgres on primary	TAGS: [pg_patroni, pgsql, postgres]
      postgres : Launch raw postgres on primary	TAGS: [pg_patroni, pgsql, postgres]
      postgres : Wait for postgres online	TAGS: [pg_patroni, pgsql, postgres]
      postgres : Check pgbouncer is installed	TAGS: [pgbouncer, pgbouncer_check, pgsql, postgres]
      postgres : Stop existing pgbouncer service	TAGS: [pgbouncer, pgbouncer_clean, pgsql, postgres]
      postgres : Remove existing pgbouncer dirs	TAGS: [pgbouncer, pgbouncer_clean, pgsql, postgres]
      postgres : Recreate dirs with owner postgres	TAGS: [pgbouncer, pgbouncer_clean, pgsql, postgres]
      postgres : Copy /etc/pgbouncer/pgbouncer.ini	TAGS: [pgbouncer, pgbouncer_config, pgbouncer_ini, pgsql, postgres]
      postgres : Copy /etc/pgbouncer/pgb_hba.conf	TAGS: [pgbouncer, pgbouncer_config, pgbouncer_hba, pgsql, postgres]
      postgres : Touch userlist and database list	TAGS: [pgbouncer, pgbouncer_config, pgsql, postgres]
      postgres : Add default users to pgbouncer	TAGS: [pgbouncer, pgbouncer_config, pgsql, postgres]
      postgres : Copy pgbouncer systemd service	TAGS: [pgbouncer, pgbouncer_launch, pgsql, postgres]
      postgres : Launch pgbouncer pool service	TAGS: [pgbouncer, pgbouncer_launch, pgsql, postgres]
      postgres : Wait for pgbouncer service online	TAGS: [pgbouncer, pgbouncer_launch, pgsql, postgres]
      postgres : Check pgbouncer service is ready	TAGS: [pgbouncer, pgbouncer_launch, pgsql, postgres]
      include_tasks	TAGS: [pg_user, pgsql, postgres]
      include_tasks	TAGS: [pg_db, pgsql, postgres]
      postgres : Reload pgbouncer to add db and users	TAGS: [pgbouncer_reload, pgsql, postgres]
      postgres : Copy pg service definition to consul	TAGS: [pg_register, pgsql, postgres, register]
      postgres : Reload postgres consul service	TAGS: [pg_register, pgsql, postgres, register]
      postgres : Render grafana datasource definition	TAGS: [pg_grafana, pgsql, postgres, register]
      postgres : Register datasource to grafana	TAGS: [pg_grafana, pgsql, postgres, register]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
---
#------------------------------------------------------------------------------
# POSTGRES INSTALLATION
#------------------------------------------------------------------------------
# - dbsu - #
pg_dbsu: postgres                             # os user for database, postgres by default (change it is not recommended!)
pg_dbsu_uid: 26                               # os dbsu uid and gid, 26 for default postgres users and groups
pg_dbsu_sudo: limit                           # none|limit|all|nopass (Privilege for dbsu, limit is recommended)
pg_dbsu_home: /var/lib/pgsql                  # postgresql binary
pg_dbsu_ssh_exchange: false                   # exchange ssh key among same cluster

# - packages - #
pg_version: 12                                # default postgresql version
pgdg_repo: false                              # use official pgdg yum repo (disable if you have local mirror)
pg_add_repo: false                            # add postgres related repo before install (useful if you want a simple install)
pg_bin_dir: /usr/pgsql/bin                    # postgres binary dir
pg_packages: # packages to be installed (Postgres 13)
  - postgresql${pg_version}*
  - postgis31_${pg_version}*
  - pgbouncer patroni pg_exporter pgbadger
  - patroni patroni-consul patroni-etcd pgbouncer pgbadger pg_activity
  - python3 python3-psycopg2 python36-requests python3-etcd python3-consul
  - python36-urllib3 python36-idna python36-pyOpenSSL python36-cryptography

pg_extensions:
  - pg_repack${pg_version} pg_qualstats${pg_version} pg_stat_kcache${pg_version} wal2json${pg_version}
  # - ogr_fdw${pg_version} mysql_fdw_${pg_version} redis_fdw_${pg_version} mongo_fdw${pg_version} hdfs_fdw_${pg_version}
  # - count_distinct${version}  ddlx_${version}  geoip${version}  orafce${version}
  # - hypopg_${version}  ip4r${version}  jsquery_${version}  logerrors_${version}  periods_${version}  pg_auto_failover_${version}  pg_catcheck${version}
  # - pg_fkpart${version}  pg_jobmon${version}  pg_partman${version}  pg_prioritize_${version}  pg_track_settings${version}  pgaudit15_${version}
  # - pgcryptokey${version}  pgexportdoc${version}  pgimportdoc${version}  pgmemcache-${version}  pgmp${version}  pgq-${version}  pgquarrel pgrouting_${version}
  # - pguint${version}  pguri${version}  prefix${version}   safeupdate_${version}  semver${version}   table_version${version}  tdigest${version}

#------------------------------------------------------------------------------
# POSTGRES PROVISION
#------------------------------------------------------------------------------
# - identity - #
# pg_cluster:                                 # [REQUIRED] cluster name (validated during pg_preflight)
# pg_seq: 0                                   # [REQUIRED] instance seq (validated during pg_preflight)
pg_role: replica                              # [REQUIRED] service role (validated during pg_preflight)
pg_hostname: false                            # overwrite node hostname with pg instance name

# - cleanup - #
# pg_exists_action, available options: abort|clean|skip
#  - abort: abort entire play's execution (default)
#  - clean: remove existing cluster (dangerous)
#  - skip: end current play for this host
pg_exists: false                              # auxiliary flag variable (DO NOT SET THIS)
pg_exists_action: abort
pg_disable_purge: false                       # if true, it will abort on any running instance regardless pg_exists_action

# - storage - #
pg_data: /pg/data                             # postgres data directory
pg_fs_main: /export                           # data disk mount point     /pg -> {{ pg_fs_main }}/postgres/{{ pg_instance }}
pg_fs_bkup: /var/backups                      # backup disk mount point   /pg/* -> {{ pg_fs_bkup }}/postgres/{{ pg_instance }}/*

# - connection - #
pg_listen: '0.0.0.0'                          # postgres listen address, '0.0.0.0' by default (all ipv4 addr)
pg_port: 5432                                 # postgres port (5432 by default)
pg_localhost: /var/run/postgresql             # default unix socket directory
pg_shared_libraries: pg_stat_statements, auto_explain      # default shared libraries



#------------------------------------------------------------------------------
# PATRONI PROVISION
#------------------------------------------------------------------------------
# - patroni - #
# patroni_mode, available options: default|pause|remove
# default: default ha mode
# pause:   into maintainance mode
# remove:  remove patroni after bootstrap
patroni_mode: default                         # pause|default|remove
pg_namespace: /pg                             # top level key namespace in dcs
patroni_port: 8008                            # default patroni port
patroni_watchdog_mode: automatic              # watchdog mode: off|automatic|required
pg_conf: patroni.yml                          # user provided patroni config template path


#------------------------------------------------------------------------------
# PGBOUNCER PROVISION
#------------------------------------------------------------------------------
# - pgbouncer - #
pgbouncer_port: 6432                          # default pgbouncer port
pgbouncer_poolmode: transaction               # default pooling mode: transaction pooling
pgbouncer_max_db_conn: 100                    # important! do not set this larger than postgres max conn or conn limit


#------------------------------------------------------------------------------
# CLUSTER TEMPLATE
#------------------------------------------------------------------------------
pg_init: pg-init                              # init script for cluster template

# - system roles - #
pg_replication_username: replicator           # system replication user
pg_replication_password: DBUser.Replicator    # system replication password
pg_monitor_username: dbuser_monitor           # system monitor user
pg_monitor_password: DBUser.Monitor           # system monitor password
pg_admin_username: dbuser_admin               # system admin user
pg_admin_password: DBUser.Admin               # system admin password

# - default roles - #
pg_default_roles:

  # common production readonly user
  - name: dbrole_readonly                 # production read-only roles
    login: false
    comment: role for global readonly access

  # common production read-write user
  - name: dbrole_readwrite                # production read-write roles
    login: false
    roles: [dbrole_readonly]             # read-write includes read-only access
    comment: role for global read-write access

  # offline have same privileges as readonly, but with limited hba access on offline instance only
  # for the purpose of running slow queries, interactive queries and perform ETL tasks
  - name: dbrole_offline
    login: false
    comment: role for restricted read-only access (offline instance)

  # admin have the privileges to issue DDL changes
  - name: dbrole_admin
    login: false
    bypassrls: true
    comment: role for object creation
    roles: [dbrole_readwrite,pg_monitor,pg_signal_backend]

  # dbsu, name is designated by `pg_dbsu`. It's not recommend to set password for dbsu
  - name: postgres
    superuser: true
    comment: system superuser

  # default replication user, name is designated by `pg_replication_username`, and password is set by `pg_replication_password`
  - name: replicator
    replication: true
    roles: [pg_monitor, dbrole_readonly]
    comment: system replicator

  # default replication user, name is designated by `pg_monitor_username`, and password is set by `pg_monitor_password`
  - name: dbuser_monitor
    connlimit: 16
    comment: system monitor user
    roles: [pg_monitor, dbrole_readonly]

  # default admin user, name is designated by `pg_admin_username`, and password is set by `pg_admin_password`
  - name: dbuser_admin
    bypassrls: true
    comment: system admin user
    roles: [dbrole_admin]

  # default stats user, for ETL and slow queries
  - name: dbuser_stats
    password: DBUser.Stats
    comment: business offline user for offline queries and ETL
    roles: [dbrole_offline]



# object created by dbsu and admin will have their privileges properly set
pg_default_privileges:
  - GRANT USAGE                         ON SCHEMAS   TO dbrole_readonly
  - GRANT SELECT                        ON TABLES    TO dbrole_readonly
  - GRANT SELECT                        ON SEQUENCES TO dbrole_readonly
  - GRANT EXECUTE                       ON FUNCTIONS TO dbrole_readonly
  - GRANT USAGE                         ON SCHEMAS   TO dbrole_offline
  - GRANT SELECT                        ON TABLES    TO dbrole_offline
  - GRANT SELECT                        ON SEQUENCES TO dbrole_offline
  - GRANT EXECUTE                       ON FUNCTIONS TO dbrole_offline
  - GRANT INSERT, UPDATE, DELETE        ON TABLES    TO dbrole_readwrite
  - GRANT USAGE,  UPDATE                ON SEQUENCES TO dbrole_readwrite
  - GRANT TRUNCATE, REFERENCES, TRIGGER ON TABLES    TO dbrole_admin
  - GRANT CREATE                        ON SCHEMAS   TO dbrole_admin

# schemas
pg_default_schemas: [monitor]

# extension
pg_default_extensions:
  - { name: 'pg_stat_statements',  schema: 'monitor' }
  - { name: 'pgstattuple',         schema: 'monitor' }
  - { name: 'pg_qualstats',        schema: 'monitor' }
  - { name: 'pg_buffercache',      schema: 'monitor' }
  - { name: 'pageinspect',         schema: 'monitor' }
  - { name: 'pg_prewarm',          schema: 'monitor' }
  - { name: 'pg_visibility',       schema: 'monitor' }
  - { name: 'pg_freespacemap',     schema: 'monitor' }
  - { name: 'pg_repack',           schema: 'monitor' }
  - name: postgres_fdw
  - name: file_fdw
  - name: btree_gist
  - name: btree_gin
  - name: pg_trgm
  - name: intagg
  - name: intarray

# - hba - #
pg_offline_query: false                     # set to true to enable offline query on instance
pg_hba_rules:
  - title: allow meta node password access
    role: common
    rules:
      - host    all     all                         10.10.10.10/32      md5

  - title: allow intranet admin password access
    role: common
    rules:
      - host    all     +dbrole_admin               10.0.0.0/8          md5
      - host    all     +dbrole_admin               172.16.0.0/12       md5
      - host    all     +dbrole_admin               192.168.0.0/16      md5

  - title: allow intranet password access
    role: common
    rules:
      - host    all             all                 10.0.0.0/8          md5
      - host    all             all                 172.16.0.0/12       md5
      - host    all             all                 192.168.0.0/16      md5

  - title: allow local read/write (local production user via pgbouncer)
    role: common
    rules:
      - local   all     +dbrole_readonly                                md5
      - host    all     +dbrole_readonly           127.0.0.1/32         md5

  - title: allow offline query (ETL,SAGA,Interactive) on offline instance
    role: offline
    rules:
      - host    all     +dbrole_offline               10.0.0.0/8        md5
      - host    all     +dbrole_offline               172.16.0.0/12     md5
      - host    all     +dbrole_offline               192.168.0.0/16    md5

pg_hba_rules_extra: []

# pgbouncer host-based authentication rules
pgbouncer_hba_rules:
  - title: local password access
    role: common
    rules:
      - local  all          all                                     md5
      - host   all          all                     127.0.0.1/32    md5

  - title: intranet password access
    role: common
    rules:
      - host   all          all                     10.0.0.0/8      md5
      - host   all          all                     172.16.0.0/12   md5
      - host   all          all                     192.168.0.0/16  md5

pgbouncer_hba_rules_extra: []

#------------------------------------------------------------------------------
# BUSINESS TEMPLATE
#------------------------------------------------------------------------------
# - business - #
# users that are ad hoc to each cluster
pg_users: []

pg_databases: []

# - reference - #
service_registry: consul                      # none | consul | etcd | both
dcs_type: consul                              # none | consul | etcd
...
```