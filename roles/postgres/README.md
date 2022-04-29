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
7. Database
    * Setup business databases


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
Create os group postgres	TAGS: [install, pg_dbsu, pgsql-init, postgres]
Make sure dcs group exists	TAGS: [install, pg_dbsu, pgsql-init, postgres]
Create dbsu {{ pg_dbsu }}	TAGS: [install, pg_dbsu, pgsql-init, postgres]
Grant dbsu nopass sudo	TAGS: [install, pg_dbsu, pgsql-init, postgres]
Grant dbsu all sudo	TAGS: [install, pg_dbsu, pgsql-init, postgres]
Grant dbsu limited sudo	TAGS: [install, pg_dbsu, pgsql-init, postgres]
Config watchdog onwer to dbsu	TAGS: [install, pg_dbsu, pgsql-init, postgres]
Add dbsu ssh no host checking	TAGS: [install, pg_dbsu, pgsql-init, postgres]
Fetch dbsu public keys	TAGS: [install, pg_dbsu, pgsql-init, postgres]
Exchange dbsu ssh keys	TAGS: [install, pg_dbsu, pgsql-init, postgres]
Install offical pgdg yum repo	TAGS: [install, pg_install, pgsql-init, postgres]
Install pg packages	TAGS: [install, pg_install, pgsql-init, postgres]
Install pg extensions	TAGS: [install, pg_install, pgsql-init, postgres]
Link /usr/pgsql to current version	TAGS: [install, pg_install, pgsql-init, postgres]
Add pg bin dir to profile path	TAGS: [install, pg_install, pgsql-init, postgres]
Fix directory ownership	TAGS: [install, pg_install, pgsql-init, postgres]
Remove default postgres service	TAGS: [install, pg_install, pgsql-init, postgres]
Check necessary variables exists	TAGS: [always, pg_preflight, pgsql-init, postgres, preflight]
Fetch variables via pg_cluster	TAGS: [always, pg_preflight, pgsql-init, postgres, preflight]
Set cluster basic facts for hosts	TAGS: [always, pg_preflight, pgsql-init, postgres, preflight]
Assert cluster primary singleton	TAGS: [always, pg_preflight, pgsql-init, postgres, preflight]
Setup cluster primary ip address	TAGS: [always, pg_preflight, pgsql-init, postgres, preflight]
Setup repl upstream for primary	TAGS: [always, pg_preflight, pgsql-init, postgres, preflight]
Setup repl upstream for replicas	TAGS: [always, pg_preflight, pgsql-init, postgres, preflight]
Debug print instance summary	TAGS: [always, pg_preflight, pgsql-init, postgres, preflight]
Check for existing postgres instance	TAGS: [pg_check, pgsql-init, postgres, prepare]
Set fact whether pg port is open	TAGS: [pg_check, pgsql-init, postgres, prepare]
Abort due to existing postgres instance	TAGS: [pg_check, pgsql-init, postgres, prepare]
Skip due to running instance	TAGS: [pg_check, pgsql-init, postgres, prepare]
Clean existing postgres instance	TAGS: [pg_check, pgsql-init, postgres, prepare]
Shutdown existing postgres service	TAGS: [pg_clean, pgsql-init, postgres, prepare]
Remove registerd consul service	TAGS: [pg_clean, pgsql-init, postgres, prepare]
Remove postgres metadata in consul	TAGS: [pg_clean, pgsql-init, postgres, prepare]
Remove existing postgres data	TAGS: [pg_clean, pgsql-init, postgres, prepare]
Make sure main and backup dir exists	TAGS: [pg_dir, pgsql-init, postgres, prepare]
Create postgres directory structure	TAGS: [pg_dir, pgsql-init, postgres, prepare]
Create pgbouncer directory structure	TAGS: [pg_dir, pgsql-init, postgres, prepare]
Create links from pgbkup to pgroot	TAGS: [pg_dir, pgsql-init, postgres, prepare]
Create links from current cluster	TAGS: [pg_dir, pgsql-init, postgres, prepare]
Create dummy placeholder file	TAGS: [pg_dir, pg_dummy, pgsql-init, postgres, prepare]
Copy postgres scripts to /pg/bin/	TAGS: [pg_scripts, pgsql-init, postgres, prepare]
Copy alias profile to /etc/profile.d	TAGS: [pg_scripts, pgsql-init, postgres, prepare]
Copy psqlrc to postgres home	TAGS: [pg_scripts, pgsql-init, postgres, prepare]
Get config parameter page count	TAGS: [patroni, pg_config, pgsql-init, postgres]
Get config parameter page size	TAGS: [patroni, pg_config, pgsql-init, postgres]
Tune shared buffer and work mem	TAGS: [patroni, pg_config, pgsql-init, postgres]
Hanlde small size mem occasion	TAGS: [patroni, pg_config, pgsql-init, postgres]
Calculate postgres mem params	TAGS: [patroni, pg_config, pgsql-init, postgres]
create patroni config dir	TAGS: [patroni, pg_config, pgsql-init, postgres]
use predefined patroni template	TAGS: [patroni, pg_config, pgsql-init, postgres]
Render default /pg/conf/patroni.yml	TAGS: [patroni, pg_config, pgsql-init, postgres]
Link /pg/conf/patroni to /pg/bin/	TAGS: [patroni, pg_config, pgsql-init, postgres]
Link /pg/bin/patroni.yml to /etc/patroni/	TAGS: [patroni, pg_config, pgsql-init, postgres]
Config patroni watchdog support	TAGS: [patroni, pg_config, pgsql-init, postgres]
Copy patroni systemd service file	TAGS: [patroni, pg_config, pgsql-init, postgres]
create patroni systemd drop-in dir	TAGS: [patroni, pg_config, pgsql-init, postgres]
Copy postgres systemd service file	TAGS: [patroni, pg_config, pgsql-init, postgres]
Drop-In systemd config for patroni	TAGS: [patroni, pg_config, pgsql-init, postgres]
Launch patroni on primary instance	TAGS: [patroni, pg_primary, pgsql-init, postgres]
Wait for patroni primary online	TAGS: [patroni, pg_primary, pgsql-init, postgres]
Wait for postgres primary online	TAGS: [patroni, pg_primary, pgsql-init, postgres]
Check primary postgres service ready	TAGS: [patroni, pg_primary, pgsql-init, postgres]
Check replication connectivity on primary	TAGS: [patroni, pg_primary, pgsql-init, postgres]
Render init roles sql	TAGS: [patroni, pg_init, pg_init_role, pgsql-init, postgres]
Render init template sql	TAGS: [patroni, pg_init, pg_init_tmpl, pgsql-init, postgres]
Render default pg-init scripts	TAGS: [patroni, pg_init, pg_init_main, pgsql-init, postgres]
Execute initialization scripts	TAGS: [patroni, pg_init, pg_init_exec, pgsql-init, postgres]
Check primary instance ready	TAGS: [patroni, pg_init, pg_init_exec, pgsql-init, postgres]
Add dbsu password to pgpass if exists	TAGS: [patroni, pg_pass, pgsql-init, postgres]
Add system user to pgpass	TAGS: [patroni, pg_pass, pgsql-init, postgres]
Check replication connectivity to primary	TAGS: [patroni, pg_replica, pgsql-init, postgres]
Launch patroni on replica instances	TAGS: [patroni, pg_replica, pgsql-init, postgres]
Wait for patroni replica online	TAGS: [patroni, pg_replica, pgsql-init, postgres]
Wait for postgres replica online	TAGS: [patroni, pg_replica, pgsql-init, postgres]
Check replica postgres service ready	TAGS: [patroni, pg_replica, pgsql-init, postgres]
Render hba rules	TAGS: [patroni, pg_hba, pgsql-init, postgres]
Reload hba rules	TAGS: [patroni, pg_hba, pgsql-init, postgres]
Pause patroni	TAGS: [patroni, pg_patroni, pgsql-init, postgres]
Stop patroni on replica instance	TAGS: [patroni, pg_patroni, pgsql-init, postgres]
Stop patroni on primary instance	TAGS: [patroni, pg_patroni, pgsql-init, postgres]
Launch raw postgres on primary	TAGS: [patroni, pg_patroni, pgsql-init, postgres]
Launch raw postgres on replicas	TAGS: [patroni, pg_patroni, pgsql-init, postgres]
Wait for postgres online	TAGS: [patroni, pg_patroni, pgsql-init, postgres]
Check pgbouncer is installed	TAGS: [pgbouncer, pgbouncer_check, pgsql-init, postgres]
Stop existing pgbouncer service	TAGS: [pgbouncer, pgbouncer_clean, pgsql-init, postgres]
Remove existing pgbouncer dirs	TAGS: [pgbouncer, pgbouncer_clean, pgsql-init, postgres]
Recreate dirs with owner postgres	TAGS: [pgbouncer, pgbouncer_clean, pgsql-init, postgres]
Copy /etc/pgbouncer/pgbouncer.ini	TAGS: [pgbouncer, pgbouncer_config, pgbouncer_ini, pgsql-init, postgres]
Copy /etc/pgbouncer/pgb_hba.conf	TAGS: [pgbouncer, pgbouncer_config, pgbouncer_hba, pgsql-init, postgres]
Touch userlist and database list	TAGS: [pgbouncer, pgbouncer_config, pgsql-init, postgres]
Add default users to pgbouncer	TAGS: [pgbouncer, pgbouncer_config, pgsql-init, postgres]
Init pgbouncer business database list	TAGS: [pgbouncer, pgbouncer_config, pgbouncer_db, pgsql-init, postgres]
Init pgbouncer business user list	TAGS: [pgbouncer, pgbouncer_config, pgbouncer_user, pgsql-init, postgres]
Copy pgbouncer systemd service	TAGS: [pgbouncer, pgbouncer_launch, pgsql-init, postgres]
Launch pgbouncer pool service	TAGS: [pgbouncer, pgbouncer_launch, pgsql-init, postgres]
Wait for pgbouncer service online	TAGS: [pgbouncer, pgbouncer_launch, pgsql-init, postgres]
Check pgbouncer service is ready	TAGS: [pgbouncer, pgbouncer_launch, pgsql-init, postgres]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
#-----------------------------------------------------------------
# PG_IDENTITY
#-----------------------------------------------------------------
# pg_cluster:                    # <CLUSTER>  <REQUIRED>  : pgsql cluster name
# pg_shard:                      # <CLUSTER>              : pgsql shard name
# pg_sindex: 0                   # <CLUSTER>              : pgsql shard index
# gp_role: master                # <CLUSTER>              : gpsql role, master or segment
# pg_role: replica               # <INSTANCE> <REQUIRED>  : pg role : primary, replica, offline
# pg_seq: 0                      # <INSTANCE> <REQUIRED>  : instance seq number
# pg_instances: {}               # <INSTANCE>             : define multiple pg instances on node, used by monly & gpsql
# pg_upstream:                   # <INSTANCE>             : replication upstream ip addr
pg_offline_query: false          # <INSTANCE> [FLAG] set to true to enable offline query on this instance (instance level)
pg_backup: false                 # <INSTANCE> [FLAG] store base backup on this node (instance level, reserved)
pg_weight: 100                   # <INSTANCE> [FLAG] default load balance weight (instance level)
pg_hostname: true                # [FLAG] reuse postgres identity name as node identity?
pg_preflight_skip: false         # [FLAG] skip preflight identity check

#-----------------------------------------------------------------
# PG_BUSINESS
#-----------------------------------------------------------------
# overwrite these variables on cluster level
pg_users: []                     # business users
pg_databases: []                 # business databases
#pg_services_extra: []           # extra services
pg_hba_rules_extra: []           # extra hba rules
pgbouncer_hba_rules_extra: []    # extra pgbouncer hba rules

# WARNING: change these in production environment!
pg_admin_username: dbuser_dba
pg_admin_password: DBUser.DBA
pg_monitor_username: dbuser_monitor
pg_monitor_password: DBUser.Monitor
pg_replication_username: replicator
pg_replication_password: DBUser.Replicator

#-----------------------------------------------------------------
# PG_INSTALL
#-----------------------------------------------------------------
pg_dbsu: postgres                # os user for database, postgres by default (unwise to change it)
pg_dbsu_uid: 26                  # os dbsu uid and gid, 26 for default postgres users and groups
pg_dbsu_sudo: limit              # dbsu sudo privilege: none|limit|all|nopass, limit by default
pg_dbsu_home: /var/lib/pgsql     # postgresql home directory
pg_dbsu_ssh_exchange: true       # exchange postgres dbsu ssh key among same cluster ?
pg_version: 14                   # default postgresql version to be installed
pgdg_repo: false                 # add pgdg official repo before install (in case of no local repo available)
pg_add_repo: false               # add postgres relate repo before install ?
pg_bin_dir: /usr/pgsql/bin       # postgres binary dir, default is /usr/pgsql/bin, which use /usr/pgsql -> /usr/pgsql-{ver}
pg_packages:                     # postgresql related packages. `${pg_version} will be replaced by `pg_version`
   - postgresql${pg_version}*     # postgresql kernel packages
   - postgis32_${pg_version}*     # postgis
   - citus_${pg_version}*         # citus
   - timescaledb-2-postgresql-${pg_version}    # timescaledb
   - pgbouncer pg_exporter pgbadger pg_activity node_exporter consul haproxy vip-manager
   - patroni patroni-consul patroni-etcd python3 python3-psycopg2 python36-requests python3-etcd
   - python3-consul python36-urllib3 python36-idna python36-pyOpenSSL python36-cryptography
pg_extensions:                   # postgresql extensions, `${pg_version} will be replaced by actual `pg_version`
   - pg_repack_${pg_version} pg_qualstats_${pg_version} pg_stat_kcache_${pg_version} pg_stat_monitor_${pg_version} wal2json_${pg_version}
   # - ogr_fdw${pg_version} mysql_fdw_${pg_version} redis_fdw_${pg_version} mongo_fdw${pg_version} hdfs_fdw_${pg_version}
   # - count_distinct${version}  ddlx_${version}  geoip${version}  orafce${version}
   # - hypopg_${version}  ip4r${version}  jsquery_${version}  logerrors_${version}  periods_${version}  pg_auto_failover_${version}  pg_catcheck${version}
   # - pg_fkpart${version}  pg_jobmon${version}  pg_partman${version}  pg_prioritize_${version}  pg_track_settings${version}  pgaudit15_${version}
   # - pgcryptokey${version}  pgexportdoc${version}  pgimportdoc${version}  pgmemcache-${version}  pgmp${version}  pgq-${version}  pgquarrel pgrouting_${version}
   # - pguint${version}  pguri${version}  prefix${version}   safeupdate_${version}  semver${version}   table_version${version}  tdigest${version}


#-----------------------------------------------------------------
# PG_BOOTSTRAP
#-----------------------------------------------------------------
pg_exists: false                 # (INTERNAL) flag that indicate pg instance existence
pg_clean: false                  # abort|clean|skip (DANGEROUS!)
pg_safeguard: false              # set to true to disable pg purge functionality for good (force pg_clean = abort)
pg_data: /pg/data                # postgres data directory (soft link)
pg_fs_main: /data                # primary data disk mount point   /pg   -> {{ pg_fs_main }}/postgres/{{ pg_instance }}
pg_fs_bkup: /data/backups        # backup disk mount point         /pg/* -> {{ pg_fs_bkup }}/postgres/{{ pg_instance }}/*
pg_dummy_filesize: 64MiB         # /pg/dummy hold some disk space for emergency use
pg_listen: '0.0.0.0'             # postgres listen address, '0.0.0.0' (all ipv4 addr) by default
pg_port: 5432                    # postgres port, 5432 by default
pg_localhost: /var/run/postgresql # localhost unix socket dir for connection
patroni_enabled: true            # if not enabled, no postgres cluster will be created
patroni_mode: default            # pause|default|remove
pg_namespace: /pg                # top level key namespace in dcs
patroni_port: 8008               # default patroni port
patroni_watchdog_mode: automatic # watchdog mode: off|automatic|required
pg_conf: tiny.yml                # pgsql template:  {oltp|olap|crit|tiny}.yml
pg_libs: 'pg_stat_statements, auto_explain'  # extensions to be loaded
pg_encoding: UTF8                # database cluster encoding, UTF8 by default
pg_locale: C                     # database cluster local, C by default
pg_lc_collate: C                 # database cluster collate, C by default
pg_lc_ctype: en_US.UTF8          # database character type, en_US.UTF8 by default (for i18n full-text search)
pgbouncer_enabled: true          # if not enabled, pgbouncer will not be created
pgbouncer_port: 6432             # pgbouncer port, 6432 by default
pgbouncer_poolmode: transaction  # pooling mode: session|transaction|statement, transaction pooling by default
pgbouncer_max_db_conn: 100       # max connection to single database, DO NOT set this larger than postgres max conn or db connlimit

#-----------------------------------------------------------------
# PG_PROVISION
#-----------------------------------------------------------------
pg_provision: true               # whether provisioning postgres cluster
pg_init: pg-init                 # init script for cluster template
pg_default_roles:
   - { name: dbrole_readonly  , login: false , comment: role for global read-only access  }                            # production read-only role
   - { name: dbrole_readwrite , login: false , roles: [dbrole_readonly], comment: role for global read-write access }  # production read-write role
   - { name: dbrole_offline , login: false , comment: role for restricted read-only access (offline instance) }        # restricted-read-only role
   - { name: dbrole_admin , login: false , roles: [pg_monitor, dbrole_readwrite] , comment: role for object creation }  # production DDL change role
   - { name: postgres , superuser: true , comment: system superuser }                             # system dbsu, name is designated by `pg_dbsu`
   - { name: dbuser_dba , superuser: true , roles: [dbrole_admin] , comment: system admin user }  # admin dbsu, name is designated by `pg_admin_username`
   - { name: replicator , replication: true , bypassrls: true , roles: [pg_monitor, dbrole_readonly] , comment: system replicator }                   # replicator
   - { name: dbuser_monitor , roles: [pg_monitor, dbrole_readonly] , comment: system monitor user , parameters: {log_min_duration_statement: 1000 } } # monitor user
   - { name: dbuser_stats , password: DBUser.Stats , roles: [dbrole_offline] , comment: business offline user for offline queries and ETL }           # ETL user
pg_default_privileges:           # - privileges - #
   - GRANT USAGE                         ON SCHEMAS   TO dbrole_readonly
   - GRANT SELECT                        ON TABLES    TO dbrole_readonly
   - GRANT SELECT                        ON SEQUENCES TO dbrole_readonly
   - GRANT EXECUTE                       ON FUNCTIONS TO dbrole_readonly
   - GRANT USAGE                         ON SCHEMAS   TO dbrole_offline
   - GRANT SELECT                        ON TABLES    TO dbrole_offline
   - GRANT SELECT                        ON SEQUENCES TO dbrole_offline
   - GRANT EXECUTE                       ON FUNCTIONS TO dbrole_offline
   - GRANT INSERT, UPDATE, DELETE        ON TABLES    TO dbrole_readwrite
   - GRANT USAGE, UPDATE                 ON SEQUENCES TO dbrole_readwrite
   - GRANT TRUNCATE, REFERENCES, TRIGGER ON TABLES    TO dbrole_admin
   - GRANT CREATE                        ON SCHEMAS   TO dbrole_admin
pg_default_schemas: [ monitor ]  # default schemas to be created
pg_default_extensions:           # default extensions to be created
   - { name: 'pg_stat_statements', schema: 'monitor' }
   - { name: 'pgstattuple',        schema: 'monitor' }
   - { name: 'pg_qualstats',       schema: 'monitor' }
   - { name: 'pg_buffercache',     schema: 'monitor' }
   - { name: 'pageinspect',        schema: 'monitor' }
   - { name: 'pg_prewarm',         schema: 'monitor' }
   - { name: 'pg_visibility',      schema: 'monitor' }
   - { name: 'pg_freespacemap',    schema: 'monitor' }
   - { name: 'pg_repack',          schema: 'monitor' }
   - name: postgres_fdw
   - name: file_fdw
   - name: btree_gist
   - name: btree_gin
   - name: pg_trgm
   - name: intagg
   - name: intarray

pg_reload: true                  # reload postgres after hba changes
pg_hba_rules:                    # postgres host-based authentication rules
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
pgbouncer_hba_rules:             # pgbouncer host-based authentication rules
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



#-----------------------------------------------------------------
# DCS (Reference)
#-----------------------------------------------------------------
dcs_registry: consul              # none | consul | etcd | both
dcs_type: consul                      # none | consul | etcd
```