# Postgres Provision



## TL;DR

1. Configure postgres parameters in config file

   ```bash
   vi config/all.yml
   ```
   
2. Run postgres provision playbook

   ```bash
   ./initdb.yml
   ```



## Parameters

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

# - storage - #
pg_data: /pg/data                             # postgres data directory
pg_fs_main: /export                           # data disk mount point     /pg -> {{ pg_fs_main }}/postgres/{{ pg_instance }}
pg_fs_bkup: /var/backups                      # backup disk mount point   /pg/* -> {{ pg_fs_bkup }}/postgres/{{ pg_instance }}/*

# - connection - #
pg_listen: '0.0.0.0'                          # postgres listen address, '0.0.0.0' by default (all ipv4 addr)
pg_port: 5432                                 # postgres port (5432 by default)
pg_localhost: /var/run/postgresql
pg_shared_libraries: pg_stat_statements, auto_explain

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
  - username: dbrole_readonly                 # sample user:
    options: NOLOGIN                          # role can not login
    comment: role for readonly access         # comment string

  - username: dbrole_readwrite                # sample user: one object for each user
    options: NOLOGIN
    comment: role for read-write access
    groups: [ dbrole_readonly ]               # read-write includes read-only access

  - username: dbrole_admin                    # sample user: one object for each user
    options: NOLOGIN BYPASSRLS                # admin can bypass row level security
    comment: role for object creation
    groups: [dbrole_readwrite,pg_monitor,pg_signal_backend]

  # NOTE: replicator, monitor, admin password are overwrite by separated config entry
  - username: postgres                        # reset dbsu password to NULL (if dbsu is not postgres)
    options: SUPERUSER LOGIN
    comment: system superuser

  - username: replicator
    options: REPLICATION LOGIN
    groups: [pg_monitor, dbrole_readonly]
    comment: system replicator

  - username: dbuser_monitor
    options: LOGIN CONNECTION LIMIT 10
    comment: system monitor user
    groups: [pg_monitor, dbrole_readonly]

  - username: dbuser_admin
    options: LOGIN BYPASSRLS
    comment: system admin user
    groups: [dbrole_admin]

  - username: dbuser_stats
    password: DBUser.Stats
    options: LOGIN
    comment: business read-only user for statistics
    groups: [dbrole_readonly]


# object created by dbsu and admin will have their privileges properly set
pg_default_privilegs:
  - GRANT USAGE                         ON SCHEMAS   TO dbrole_readonly
  - GRANT SELECT                        ON TABLES    TO dbrole_readonly
  - GRANT SELECT                        ON SEQUENCES TO dbrole_readonly
  - GRANT EXECUTE                       ON FUNCTIONS TO dbrole_readonly
  - GRANT INSERT, UPDATE, DELETE        ON TABLES    TO dbrole_readwrite
  - GRANT USAGE,  UPDATE                ON SEQUENCES TO dbrole_readwrite
  - GRANT TRUNCATE, REFERENCES, TRIGGER ON TABLES    TO dbrole_admin
  - GRANT CREATE                        ON SCHEMAS   TO dbrole_admin
  - GRANT USAGE                         ON TYPES     TO dbrole_admin

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

  - title: allow local read-write access (local production user via pgbouncer)
    role: common
    rules:
      - local   all     +dbrole_readwrite                               md5
      - host    all     +dbrole_readwrite           127.0.0.1/32        md5

  - title: allow read-only user (stats, personal) password directly access
    role: replica
    rules:
      - local   all     +dbrole_readonly                               md5
      - host    all     +dbrole_readonly           127.0.0.1/32        md5

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

#------------------------------------------------------------------------------
# BUSINESS TEMPLATE
#------------------------------------------------------------------------------
# - business - #
# users that are ad hoc to each cluster
pg_users:
  - username: dbuser_test
    password: DBUser.Test
    options: LOGIN NOINHERIT
    comment: business read-write user
    groups: [dbrole_readwrite]

pg_databases: # additional business database
  - name: test                                # one object for each database
    owner: dbuser_test
    schemas: [monitor, public]
    extensions: [{name: "postgis", schema: "public"}]
    parameters:
      search_path: 'yay,public,monitor'       # set default search path

...
```





## Playbook

[`initdb.yml`](../initdb.yml) will bootstrap PostgreSQL cluster according to inventory (assume infra provisioned)

```yaml
tasks:
  Create os group postgres								TAGS: [instal, pg_dbsu, postgres]
  postgres : Make sure dcs group exists					TAGS: [instal, pg_dbsu, postgres]
  postgres : Create dbsu {{ pg_dbsu }}					TAGS: [instal, pg_dbsu, postgres]
  postgres : Grant dbsu nopass sudo						TAGS: [instal, pg_dbsu, postgres]
  postgres : Grant dbsu all sudo						TAGS: [instal, pg_dbsu, postgres]
  postgres : Grant dbsu limited sudo					TAGS: [instal, pg_dbsu, postgres]
  postgres : Config patroni watchdog support			TAGS: [instal, pg_dbsu, postgres]
  postgres : Add dbsu ssh no host checking				TAGS: [instal, pg_dbsu, postgres]
  postgres : Fetch dbsu public keys						TAGS: [instal, pg_dbsu, postgres]
  postgres : Exchange dbsu ssh keys						TAGS: [instal, pg_dbsu, postgres]
  postgres : Install offical pgdg yum repo				TAGS: [instal, pg_install, postgres]
  postgres : Install pg packages						TAGS: [instal, pg_install, postgres]
  postgres : Install pg extensions						TAGS: [instal, pg_install, postgres]
  postgres : Link /usr/pgsql to current version			TAGS: [instal, pg_install, postgres]
  postgres : Add pg bin dir to profile path				TAGS: [instal, pg_install, postgres]
  postgres : Fix directory ownership					TAGS: [instal, pg_install, postgres]
  Remove default postgres service						TAGS: [instal, pg_install, postgres]
  postgres : Check necessary variables exists			TAGS: [always, pg_preflight, postgres, preflight]
  postgres : Fetch variables via pg_cluster				TAGS: [always, pg_preflight, postgres, preflight]
  postgres : Set cluster basic facts for hosts			TAGS: [always, pg_preflight, postgres, preflight]
  postgres : Assert cluster primary singleton			TAGS: [always, pg_preflight, postgres, preflight]
  postgres : Setup cluster primary ip address			TAGS: [always, pg_preflight, postgres, preflight]
  postgres : Setup repl upstream for primary			TAGS: [always, pg_preflight, postgres, preflight]
  postgres : Setup repl upstream for replicas			TAGS: [always, pg_preflight, postgres, preflight]
  postgres : Debug print instance summary				TAGS: [always, pg_preflight, postgres, preflight]
  Check for existing postgres instance					TAGS: [pg_check, postgres, prepare]
  postgres : Set fact whether pg port is open			TAGS: [pg_check, postgres, prepare]
  Abort due to existing postgres instance				TAGS: [pg_check, postgres, prepare]
  Clean existing postgres instance						TAGS: [pg_check, postgres, prepare]
  Shutdown existing postgres service					TAGS: [pg_clean, postgres, prepare]
  postgres : Remove registerd consul service			TAGS: [pg_clean, postgres, prepare]
  Remove postgres metadata in consul					TAGS: [pg_clean, postgres, prepare]
  Remove existing postgres data							TAGS: [pg_clean, postgres, prepare]
  postgres : Make sure main and backup dir exists		TAGS: [pg_dir, postgres, prepare]
  Create postgres directory structure					TAGS: [pg_dir, postgres, prepare]
  postgres : Create pgbouncer directory structure		TAGS: [pg_dir, postgres, prepare]
  postgres : Create links from pgbkup to pgroot			TAGS: [pg_dir, postgres, prepare]
  postgres : Create links from current cluster			TAGS: [pg_dir, postgres, prepare]
  postgres : Copy pg_cluster to /pg/meta/cluster		TAGS: [pg_meta, postgres, prepare]
  postgres : Copy pg_version to /pg/meta/version		TAGS: [pg_meta, postgres, prepare]
  postgres : Copy pg_instance to /pg/meta/instance		TAGS: [pg_meta, postgres, prepare]
  postgres : Copy pg_seq to /pg/meta/sequence			TAGS: [pg_meta, postgres, prepare]
  postgres : Copy pg_role to /pg/meta/role				TAGS: [pg_meta, postgres, prepare]
  Copy postgres scripts to /pg/bin/						TAGS: [pg_scripts, postgres, prepare]
  postgres : Copy alias profile to /etc/profile.d		TAGS: [pg_scripts, postgres, prepare]
  Copy psqlrc to postgres home							TAGS: [pg_scripts, postgres, prepare]
  postgres : Setup hostname to pg instance name			TAGS: [pg_hostname, postgres, prepare]
  postgres : Copy consul node-meta definition			TAGS: [pg_nodemeta, postgres, prepare]
  postgres : Restart consul to load new node-meta		TAGS: [pg_nodemeta, postgres, prepare]
  postgres : Config patroni watchdog support			TAGS: [pg_watchdog, postgres, prepare]
  postgres : Get config parameter page count			TAGS: [pg_config, postgres]
  postgres : Get config parameter page size				TAGS: [pg_config, postgres]
  postgres : Tune shared buffer and work mem			TAGS: [pg_config, postgres]
  postgres : Hanlde small size mem occasion				TAGS: [pg_config, postgres]
  Calculate postgres mem params							TAGS: [pg_config, postgres]
  postgres : create patroni config dir					TAGS: [pg_config, postgres]
  postgres : use predefined patroni template			TAGS: [pg_config, postgres]
  postgres : Render default /pg/conf/patroni.yml		TAGS: [pg_config, postgres]
  postgres : Link /pg/conf/patroni to /pg/bin/			TAGS: [pg_config, postgres]
  postgres : Link /pg/bin/patroni.yml to /etc/patroni/	TAGS: [pg_config, postgres]
  postgres : Config patroni watchdog support			TAGS: [pg_config, postgres]
  postgres : create patroni systemd drop-in dir			TAGS: [pg_config, postgres]
  Copy postgres systemd service file					TAGS: [pg_config, postgres]
  postgres : create patroni systemd drop-in file		TAGS: [pg_config, postgres]
  postgres : Render default initdb scripts				TAGS: [pg_config, postgres]
  postgres : Launch patroni on primary instance			TAGS: [pg_primary, postgres]
  postgres : Wait for patroni primary online			TAGS: [pg_primary, postgres]
  Wait for postgres primary online						TAGS: [pg_primary, postgres]
  Check primary postgres service ready					TAGS: [pg_primary, postgres]
  postgres : Check replication connectivity to primary	TAGS: [pg_primary, postgres]
  postgres : Render default pg-init scripts				TAGS: [pg_init, pg_init_config, postgres]
  postgres : Render template init script				TAGS: [pg_init, pg_init_config, postgres]
  postgres : Execute initialization scripts				TAGS: [pg_init, postgres]
  postgres : Check primary instance ready				TAGS: [pg_init, postgres]
  postgres : Add dbsu password to pgpass if exists		TAGS: [pg_pass, postgres]
  postgres : Add system user to pgpass					TAGS: [pg_pass, postgres]
  postgres : Check replication connectivity to primary	TAGS: [pg_replica, postgres]
  postgres : Launch patroni on replica instances		TAGS: [pg_replica, postgres]
  postgres : Wait for patroni replica online			TAGS: [pg_replica, postgres]
  Wait for postgres replica online						TAGS: [pg_replica, postgres]
  Check replica postgres service ready					TAGS: [pg_replica, postgres]
  postgres : Render hba rules							TAGS: [pg_hba, postgres]
  postgres : Reload hba rules							TAGS: [pg_hba, postgres]
  postgres : Pause patroni								TAGS: [pg_patroni, postgres]
  postgres : Stop patroni on replica instance			TAGS: [pg_patroni, postgres]
  postgres : Stop patroni on primary instance			TAGS: [pg_patroni, postgres]
  Launch raw postgres on primary						TAGS: [pg_patroni, postgres]
  Launch raw postgres on primary						TAGS: [pg_patroni, postgres]
  Wait for postgres online								TAGS: [pg_patroni, postgres]
  postgres : Check pgbouncer is installed				TAGS: [pgbouncer, pgbouncer_check, postgres]
  postgres : Stop existing pgbouncer service			TAGS: [pgbouncer, pgbouncer_clean, postgres]
  postgres : Remove existing pgbouncer dirs				TAGS: [pgbouncer, pgbouncer_clean, postgres]
  Recreate dirs with owner postgres						TAGS: [pgbouncer, pgbouncer_clean, postgres]
  postgres : Copy /etc/pgbouncer/pgbouncer.ini			TAGS: [pgbouncer, pgbouncer_config, postgres]
  postgres : Copy /etc/pgbouncer/pgb_hba.conf			TAGS: [pgbouncer, pgbouncer_config, postgres]
  postgres : Touch userlist and database list			TAGS: [pgbouncer, pgbouncer_config, postgres]
  postgres : Add default users to pgbouncer				TAGS: [pgbouncer, pgbouncer_config, postgres]
  postgres : Copy pgbouncer systemd service				TAGS: [pgbouncer, pgbouncer_launch, postgres]
  postgres : Launch pgbouncer pool service				TAGS: [pgbouncer, pgbouncer_launch, postgres]
  postgres : Wait for pgbouncer service online			TAGS: [pgbouncer, pgbouncer_launch, postgres]
  postgres : Check pgbouncer service is ready			TAGS: [pgbouncer, pgbouncer_launch, postgres]
  postgres : Render business init script				TAGS: [business, pg_biz_config, pg_biz_init, postgres]
  postgres : Render database baseline sql				TAGS: [business, pg_biz_config, pg_biz_init, postgres]
  postgres : Execute business init script				TAGS: [business, pg_biz_init, postgres]
  postgres : Execute database baseline sql				TAGS: [business, pg_biz_init, postgres]
  postgres : Add pgbouncer busniess users				TAGS: [business, pg_biz_pgbouncer, postgres]
  postgres : Add pgbouncer busniess database			TAGS: [business, pg_biz_pgbouncer, postgres]
  postgres : Restart pgbouncer							TAGS: [business, pg_biz_pgbouncer, postgres]
  Copy postgres service definition						TAGS: [pg_register, postgres, register]
  postgres : Reload consul service						TAGS: [pg_register, postgres, register]
  postgres : Render grafana datasource definition		TAGS: [pg_grafana, postgres, register]
  postgres : Register datasource to grafana				TAGS: [pg_grafana, postgres, register]
  monitor : Create /etc/pg_exporter conf dir			TAGS: [monitor, pg_exporter]
  monitor : Copy default pg_exporter.yaml				TAGS: [monitor, pg_exporter]
  monitor : Config /etc/default/pg_exporter				TAGS: [monitor, pg_exporter]
  monitor : Config pg_exporter service unit				TAGS: [monitor, pg_exporter]
  monitor : Launch pg_exporter systemd service			TAGS: [monitor, pg_exporter]
  monitor : Wait for pg_exporter service online			TAGS: [monitor, pg_exporter]
  monitor : Register pg-exporter consul service			TAGS: [monitor, pg_exporter]
  monitor : Reload pg-exporter consul service			TAGS: [monitor, pg_exporter]
  monitor : Config pgbouncer_exporter opts				TAGS: [monitor, pgbouncer_exporter]
  monitor : Config pgbouncer_exporter service			TAGS: [monitor, pgbouncer_exporter]
  monitor : Launch pgbouncer_exporter service			TAGS: [monitor, pgbouncer_exporter]
  monitor : Wait for pgbouncer_exporter online			TAGS: [monitor, pgbouncer_exporter]
  monitor : Register pgb-exporter consul service		TAGS: [monitor, pgbouncer_exporter]
  monitor : Reload pgb-exporter consul service			TAGS: [monitor, pgbouncer_exporter]
  monitor : Copy node_exporter systemd service			TAGS: [monitor, node_exporter]
  monitor : Config default node_exporter options		TAGS: [monitor, node_exporter]
  monitor : Launch node_exporter service unit			TAGS: [monitor, node_exporter]
  monitor : Wait for node_exporter online				TAGS: [monitor, node_exporter]
  monitor : Register node-exporter service				TAGS: [monitor, node_exporter]
  monitor : Reload node-exporter consul service			TAGS: [monitor, node_exporter]
  proxy : Templating /etc/default/vip-manager.yml		TAGS: [proxy, vip]
  proxy : create vip-manager. systemd drop-in dir		TAGS: [proxy, vip]
  proxy : create vip-manager systemd drop-in file		TAGS: [proxy, vip]
  proxy : Launch vip-manager							TAGS: [proxy, vip]
  proxy : Set pg_instance in case of absence			TAGS: [haproxy, proxy]
  proxy : Fetch postgres cluster memberships			TAGS: [haproxy, proxy]
  Templating /etc/haproxyhaproxy.cfg					TAGS: [haproxy, proxy]
  Copy haproxy systemd service file						TAGS: [haproxy, proxy]
  Launch haproxy load balancer service					TAGS: [haproxy, proxy]
  Wait for haproxy load balancer online					TAGS: [haproxy, proxy]
  Copy haproxy service definition						TAGS: [haproxy_register, proxy]
  Reload haproxy consul service							TAGS: [haproxy_register, proxy]

```

