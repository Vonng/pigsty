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
Create os group postgres	TAGS: [instal, pg_dbsu, pgsql, postgres]
Make sure dcs group exists	TAGS: [instal, pg_dbsu, pgsql, postgres]
Create dbsu {{ pg_dbsu }}	TAGS: [instal, pg_dbsu, pgsql, postgres]
Grant dbsu nopass sudo	TAGS: [instal, pg_dbsu, pgsql, postgres]
Grant dbsu all sudo	TAGS: [instal, pg_dbsu, pgsql, postgres]
Grant dbsu limited sudo	TAGS: [instal, pg_dbsu, pgsql, postgres]
Config watchdog onwer to dbsu	TAGS: [instal, pg_dbsu, pgsql, postgres]
Add dbsu ssh no host checking	TAGS: [instal, pg_dbsu, pgsql, postgres]
Fetch dbsu public keys	TAGS: [instal, pg_dbsu, pgsql, postgres]
Exchange dbsu ssh keys	TAGS: [instal, pg_dbsu, pgsql, postgres]
Install offical pgdg yum repo	TAGS: [instal, pg_install, pgsql, postgres]
Install pg packages	TAGS: [instal, pg_install, pgsql, postgres]
Install pg extensions	TAGS: [instal, pg_install, pgsql, postgres]
Link /usr/pgsql to current version	TAGS: [instal, pg_install, pgsql, postgres]
Add pg bin dir to profile path	TAGS: [instal, pg_install, pgsql, postgres]
Fix directory ownership	TAGS: [instal, pg_install, pgsql, postgres]
Remove default postgres service	TAGS: [instal, pg_install, pgsql, postgres]
Check necessary variables exists	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
Fetch variables via pg_cluster	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
Set cluster basic facts for hosts	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
Assert cluster primary singleton	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
Setup cluster primary ip address	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
Setup repl upstream for primary	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
Setup repl upstream for replicas	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
Debug print instance summary	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
Check for existing postgres instance	TAGS: [pg_check, pgsql, postgres, prepare]
Set fact whether pg port is open	TAGS: [pg_check, pgsql, postgres, prepare]
Abort due to existing postgres instance	TAGS: [pg_check, pgsql, postgres, prepare]
Clean existing postgres instance	TAGS: [pg_check, pgsql, postgres, prepare]
Shutdown existing postgres service	TAGS: [pg_clean, pgsql, postgres, prepare]
Remove registerd consul service	TAGS: [pg_clean, pgsql, postgres, prepare]
Remove postgres metadata in consul	TAGS: [pg_clean, pgsql, postgres, prepare]
Remove existing postgres data	TAGS: [pg_clean, pgsql, postgres, prepare]
Make sure main and backup dir exists	TAGS: [pg_dir, pgsql, postgres, prepare]
Create postgres directory structure	TAGS: [pg_dir, pgsql, postgres, prepare]
Create pgbouncer directory structure	TAGS: [pg_dir, pgsql, postgres, prepare]
Create links from pgbkup to pgroot	TAGS: [pg_dir, pgsql, postgres, prepare]
Create links from current cluster	TAGS: [pg_dir, pgsql, postgres, prepare]
Copy pg_cluster to /pg/meta/cluster	TAGS: [pg_meta, pgsql, postgres, prepare]
Copy pg_version to /pg/meta/version	TAGS: [pg_meta, pgsql, postgres, prepare]
Copy pg_instance to /pg/meta/instance	TAGS: [pg_meta, pgsql, postgres, prepare]
Copy pg_seq to /pg/meta/sequence	TAGS: [pg_meta, pgsql, postgres, prepare]
Copy pg_role to /pg/meta/role	TAGS: [pg_meta, pgsql, postgres, prepare]
Copy postgres scripts to /pg/bin/	TAGS: [pg_scripts, pgsql, postgres, prepare]
Copy alias profile to /etc/profile.d	TAGS: [pg_scripts, pgsql, postgres, prepare]
Copy psqlrc to postgres home	TAGS: [pg_scripts, pgsql, postgres, prepare]
Setup hostname to pg instance name	TAGS: [pg_hostname, pgsql, postgres, prepare]
Copy consul node-meta definition	TAGS: [pg_nodemeta, pgsql, postgres, prepare]
Restart consul to load new node-meta	TAGS: [pg_nodemeta, pgsql, postgres, prepare]
Get config parameter page count	TAGS: [pg_config, pgsql, postgres]
Get config parameter page size	TAGS: [pg_config, pgsql, postgres]
Tune shared buffer and work mem	TAGS: [pg_config, pgsql, postgres]
Hanlde small size mem occasion	TAGS: [pg_config, pgsql, postgres]
Calculate postgres mem params	TAGS: [pg_config, pgsql, postgres]
create patroni config dir	TAGS: [pg_config, pgsql, postgres]
use predefined patroni template	TAGS: [pg_config, pgsql, postgres]
Render default /pg/conf/patroni.yml	TAGS: [pg_config, pgsql, postgres]
Link /pg/conf/patroni to /pg/bin/	TAGS: [pg_config, pgsql, postgres]
Link /pg/bin/patroni.yml to /etc/patroni/	TAGS: [pg_config, pgsql, postgres]
Config patroni watchdog support	TAGS: [pg_config, pgsql, postgres]
Copy patroni systemd service file	TAGS: [pg_config, pgsql, postgres]
create patroni systemd drop-in dir	TAGS: [pg_config, pgsql, postgres]
Copy postgres systemd service file	TAGS: [pg_config, pgsql, postgres]
Drop-In systemd config for patroni	TAGS: [pg_config, pgsql, postgres]
Launch patroni on primary instance	TAGS: [pg_primary, pgsql, postgres]
Wait for patroni primary online	TAGS: [pg_primary, pgsql, postgres]
Wait for postgres primary online	TAGS: [pg_primary, pgsql, postgres]
Check primary postgres service ready	TAGS: [pg_primary, pgsql, postgres]
Check replication connectivity on primary	TAGS: [pg_primary, pgsql, postgres]
Render init roles sql	TAGS: [pg_init, pg_init_role, pgsql, postgres]
Render init template sql	TAGS: [pg_init, pg_init_tmpl, pgsql, postgres]
Render default pg-init scripts	TAGS: [pg_init, pg_init_main, pgsql, postgres]
Execute initialization scripts	TAGS: [pg_init, pg_init_exec, pgsql, postgres]
Check primary instance ready	TAGS: [pg_init, pg_init_exec, pgsql, postgres]
Add dbsu password to pgpass if exists	TAGS: [pg_pass, pgsql, postgres]
Add system user to pgpass	TAGS: [pg_pass, pgsql, postgres]
Check replication connectivity to primary	TAGS: [pg_replica, pgsql, postgres]
Launch patroni on replica instances	TAGS: [pg_replica, pgsql, postgres]
Wait for patroni replica online	TAGS: [pg_replica, pgsql, postgres]
Wait for postgres replica online	TAGS: [pg_replica, pgsql, postgres]
Check replica postgres service ready	TAGS: [pg_replica, pgsql, postgres]
Render hba rules	TAGS: [pg_hba, pgsql, postgres]
Reload hba rules	TAGS: [pg_hba, pgsql, postgres]
Pause patroni	TAGS: [pg_patroni, pgsql, postgres]
Stop patroni on replica instance	TAGS: [pg_patroni, pgsql, postgres]
Stop patroni on primary instance	TAGS: [pg_patroni, pgsql, postgres]
Launch raw postgres on primary	TAGS: [pg_patroni, pgsql, postgres]
Launch raw postgres on replicas	TAGS: [pg_patroni, pgsql, postgres]
Wait for postgres online	TAGS: [pg_patroni, pgsql, postgres]
Check pgbouncer is installed	TAGS: [pgbouncer, pgbouncer_check, pgsql, postgres]
Stop existing pgbouncer service	TAGS: [pgbouncer, pgbouncer_clean, pgsql, postgres]
Remove existing pgbouncer dirs	TAGS: [pgbouncer, pgbouncer_clean, pgsql, postgres]
Recreate dirs with owner postgres	TAGS: [pgbouncer, pgbouncer_clean, pgsql, postgres]
Copy /etc/pgbouncer/pgbouncer.ini	TAGS: [pgbouncer, pgbouncer_config, pgbouncer_ini, pgsql, postgres]
Copy /etc/pgbouncer/pgb_hba.conf	TAGS: [pgbouncer, pgbouncer_config, pgbouncer_hba, pgsql, postgres]
Touch userlist and database list	TAGS: [pgbouncer, pgbouncer_config, pgsql, postgres]
Add default users to pgbouncer	TAGS: [pgbouncer, pgbouncer_config, pgsql, postgres]
Copy pgbouncer systemd service	TAGS: [pgbouncer, pgbouncer_launch, pgsql, postgres]
Launch pgbouncer pool service	TAGS: [pgbouncer, pgbouncer_launch, pgsql, postgres]
Wait for pgbouncer service online	TAGS: [pgbouncer, pgbouncer_launch, pgsql, postgres]
Check pgbouncer service is ready	TAGS: [pgbouncer, pgbouncer_launch, pgsql, postgres]
# include_tasks	TAGS: [pg_user, pgsql, postgres]
# include_tasks	TAGS: [pg_db, pgsql, postgres]
Reload pgbouncer to add db and users	TAGS: [pgbouncer_reload, pgsql, postgres]
Register postgres service to consul	TAGS: [pgsql, postgres, register, register_consul, register_consul_postgres]
Register patroni service to consul	TAGS: [pgsql, postgres, register, register_consul, register_consul_patroni]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
---
#------------------------------------------------------------------------------
# POSTGRES INSTALLATION
#------------------------------------------------------------------------------
# - dbsu - #
pg_dbsu: postgres                             # os user for database, postgres by default (unwise to change it)
pg_dbsu_uid: 26                               # os dbsu uid and gid, 26 for default postgres users and groups
pg_dbsu_sudo: limit                           # dbsu sudo privilege: none|limit|all|nopass, limit by default
pg_dbsu_home: /var/lib/pgsql                  # postgresql home directory
pg_dbsu_ssh_exchange: true                    # exchange postgres dbsu ssh key among same cluster ?

# - postgres packages - #
pg_version: 13                                # default postgresql version to be installed
pgdg_repo: false                              # add pgdg official repo before install (in case of no local repo available)
pg_add_repo: false                            # add postgres related repo before install (useful if you want a simple install)
pg_bin_dir: /usr/pgsql/bin                    # postgres binary dir, default is /usr/pgsql/bin, which use /usr/pgsql -> /usr/pgsql-{ver}
pg_packages:                                  # postgresql related packages. `${pg_version} will be replaced by `pg_version`
   - postgresql${pg_version}*                  # postgresql kernel packages
   - postgis31_${pg_version}*                  # postgis
   - pgbouncer patroni pg_exporter pgbadger    # 3rd utils
   - patroni patroni-consul patroni-etcd pgbouncer pgbadger pg_activity
   - python3 python3-psycopg2 python36-requests python3-etcd python3-consul
   - python36-urllib3 python36-idna python36-pyOpenSSL python36-cryptography

pg_extensions:                                # postgresql extensions. `${pg_version} will be replaced by `pg_version`
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
# pg_cluster:                                 # [REQUIRED] cluster name (cluster level,  validated during pg_preflight)
# pg_seq: 0                                   # [REQUIRED] instance seq (instance level, validated during pg_preflight)
# pg_role: replica                            # [REQUIRED] service role (instance level, validated during pg_preflight)
# pg_shard:                                   # [OPTIONAL] shard name  (cluster level)
# pg_sindex:                                  # [OPTIONAl] shard index (cluster level)

# - identity option -#
pg_hostname: false                            # overwrite node hostname with pg instance name
pg_nodename: true                             # overwrite consul nodename with pg instance name

# - retention - #
# pg_exists_action, available options: abort|clean|skip
#  - abort: abort entire play's execution (default)
#  - clean: remove existing cluster (dangerous)
#  - skip: end current play for this host
# pg_exists: false                            # auxiliary flag variable (DO NOT SET THIS)
pg_exists_action: clean                       # what to do when found running postgres instance ? (clean are JUST FOR DEMO! do not use this on production)
pg_disable_purge: false                       # set to true to disable pg purge functionality for good (force pg_exists_action = abort)

# - storage - #
pg_data: /pg/data                             # postgres data directory (soft link)
pg_fs_main: /data                             # primary data disk mount point   /pg   -> {{ pg_fs_main }}/postgres/{{ pg_instance }}
pg_fs_bkup: /data/backups                     # backup disk mount point         /pg/* -> {{ pg_fs_bkup }}/postgres/{{ pg_instance }}/*

# - connection - #
pg_listen: '0.0.0.0'                          # postgres listen address, '0.0.0.0' (all ipv4 addr) by default
pg_port: 5432                                 # postgres port, 5432 by default
pg_localhost: /var/run/postgresql             # localhost unix socket dir for connection
# pg_upstream:                                # [OPTIONAL] specify replication upstream, instance level
# Set on primary instance will transform this cluster into a standby cluster

# - patroni - #
# patroni_mode, available options: default|pause|remove
#   - default: default ha mode
#   - pause:   into maintenance mode
#   - remove:  remove patroni after bootstrap
patroni_mode: default                         # pause|default|remove
pg_namespace: /pg                             # top level key namespace in dcs
patroni_port: 8008                            # default patroni port
patroni_watchdog_mode: automatic              # watchdog mode: off|automatic|required
pg_conf: tiny.yml                             # pgsql template:  {oltp|olap|crit|tiny}.yml , use tiny for sandbox
# use oltp|olap|crit for production, or fork your own templates (in ansible templates dir)
pg_shared_libraries: 'pg_stat_statements, auto_explain' # extension shared libraries to be added

# - flags - #
pg_backup: false                              # store base backup on this node          (instance level, TBD)
pg_delay: 0                                   # apply delay for offline|delayed replica (instance level, TBD)

# - localization - #
pg_encoding: UTF8                             # database cluster encoding, UTF8 by default
pg_locale: C                                  # database cluster local, C by default
pg_lc_collate: C                              # database cluster collate, C by default
pg_lc_ctype: en_US.UTF8                       # database character type, en_US.UTF8 by default (for i18n full-text search)

# - pgbouncer - #
pgbouncer_port: 6432                          # pgbouncer port, 6432 by default
pgbouncer_poolmode: transaction               # pooling mode: session|transaction|statement, transaction pooling by default
pgbouncer_max_db_conn: 100                    # max connection to single database, DO NOT set this larger than postgres max conn or db connlimit


#------------------------------------------------------------------------------
# POSTGRES TEMPLATE
#------------------------------------------------------------------------------
# - template - #
pg_init: pg-init                              # init script for cluster template

# - system roles - #
pg_replication_username: replicator           # system replication user
pg_replication_password: DBUser.Replicator    # system replication password
pg_monitor_username: dbuser_monitor           # system monitor user
pg_monitor_password: DBUser.Monitor           # system monitor password
pg_admin_username: dbuser_dba                 # system admin user
pg_admin_password: DBUser.DBA                 # system admin password

# - default roles - #
pg_default_roles:                             # check https://pigsty.cc/#/zh-cn/c-user for more detail, sequence matters
   # default roles
   - { name: dbrole_readonly  , login: false , comment: role for global read-only access  }                            # production read-only role
   - { name: dbrole_readwrite , login: false , roles: [dbrole_readonly], comment: role for global read-write access }  # production read-write role
   - { name: dbrole_offline , login: false , comment: role for restricted read-only access (offline instance) }        # restricted-read-only role
   - { name: dbrole_admin , login: false , roles: [pg_monitor, dbrole_readwrite] , comment: role for object creation }  # production DDL change role

   # default users
   - { name: postgres , superuser: true , comment: system superuser }                             # system dbsu, name is designated by `pg_dbsu`
   - { name: dbuser_dba , superuser: true , roles: [dbrole_admin] , comment: system admin user }  # admin dbsu, name is designated by `pg_admin_username`
   - { name: replicator , replication: true , bypassrls: true , roles: [pg_monitor, dbrole_readonly] , comment: system replicator }                   # replicator
   - { name: dbuser_monitor , roles: [pg_monitor, dbrole_readonly] , comment: system monitor user , parameters: {log_min_duration_statement: 1000 } } # monitor user
   - { name: dbuser_stats , password: DBUser.Stats , roles: [dbrole_offline] , comment: business offline user for offline queries and ETL }           # ETL user

# - privileges - #
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

# - schemas - #
pg_default_schemas: [monitor]                 # default schemas to be created

# - extension - #
pg_default_extensions:                        # default extensions to be created
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
pg_offline_query: false                       # set to true to enable offline query on this instance (instance level)
pg_reload: true                               # reload postgres after hba changes
pg_hba_rules:                                 # postgres host-based authentication rules
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

pg_hba_rules_extra: []                        # extra hba rules (overwrite by cluster/instance level config)

pgbouncer_hba_rules:                          # pgbouncer host-based authentication rules
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

pgbouncer_hba_rules_extra: []                 # extra pgbouncer hba rules (overwrite by cluster/instance level config)


#------------------------------------------------------------------------------
# BUSINESS TEMPLATE
#------------------------------------------------------------------------------
# - business - #

# users that are ad hoc to each cluster
pg_users: []

# databases that are ad hoc to each cluster
pg_databases: []

# - reference - #
service_registry: consul                      # none | consul | etcd | both
dcs_type: consul                              # none | consul | etcd
...
```