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
#------------------------------------------------------------------------------
# POSTGRES INSTALLATION
#------------------------------------------------------------------------------
# - dbsu - #
pg_dbsu: postgres                             # os user for database, postgres by default (change it is not recommended!)
pg_dbsu_uid: 26                               # os dbsu uid and gid, 26 for default postgres users and groups
pg_dbsu_sudo: limit                           # none|limit|all|nopass (Privilege for dbsu, limit is recommended)
pg_dbsu_home: /var/lib/pgsql                  # postgresql binary
pg_dbsu_ssh_exchange: false                   # exchange ssh key among same cluster

# - postgres packages - #
pg_version: 12                                # default postgresql version
pgdg_repo: false                              # use official pgdg yum repo (disable if you have local mirror)
pg_add_repo: false                            # add postgres related repo before install (useful if you want a simple install)
pg_bin_dir: /usr/pgsql/bin                    # postgres binary dir
pg_packages:                                 # packages to be installed  (comment this will use role default)
  - postgresql${pg_version}*
  - postgis30_${pg_version}* timescaledb_${pg_version} citus_${pg_version} pglogical_${pg_version}   # postgres ${pg_version} basic
  - pg_qualstats${pg_version} pg_cron_${pg_version} pg_top${pg_version} pg_repack${pg_version} pg_squeeze${pg_version} pg_stat_kcache${pg_version} wal2json${pg_version}
  - pgpool-II-${pg_version} pgpool-II-${pg_version}-extensions
  - pgbouncer patroni pg_exporter pg_top pgbadger # postgres common utils

# - 3rd party extensions #
 pg_extensions: []                           # available extensions (comment this will use role default)
  - ddlx_${pg_version} bgw_replstatus${pg_version} count_distinct${pg_version} extra_window_functions_${pg_version}
  - geoip${pg_version} hll_${pg_version} hypopg_${pg_version} ip4r${pg_version} jsquery_${pg_version} multicorn${pg_version}
  - osm_fdw${pg_version} mysql_fdw_${pg_version} ogr_fdw${pg_version} mongo_fdw${pg_version} hdfs_fdw_${pg_version} cstore_fdw_${pg_version}
  - wal2mongo${pg_version} orafce${pg_version} pagila${pg_version} pam-pgsql${pg_version} passwordcheck_cracklib${pg_version} periods_${pg_version}
  - pg_auto_failover_${pg_version} pg_bulkload${pg_version} pg_catcheck${pg_version} pg_comparator${pg_version} pg_filedump${pg_version}
  - pg_fkpart${pg_version} pg_jobmon${pg_version} pg_partman${pg_version} pg_pathman${pg_version} pg_track_settings${pg_version}
  - pg_wait_sampling_${pg_version} pgagent_${pg_version} pgaudit14_${pg_version} pgauditlogtofile-${pg_version} pgbconsole${pg_version}
  - pgcryptokey${pg_version} pgexportdoc${pg_version} pgfincore${pg_version} pgimportdoc${pg_version} pgmemcache-${pg_version} pgmp${pg_version}
  - pgq-${pg_version} pgrouting_${pg_version} pgtap${pg_version} plpgsql_check_${pg_version} plr${pg_version} plsh${pg_version}
  - postgresql_anonymizer${pg_version} postgresql-unit${pg_version} powa_${pg_version} prefix${pg_version} repmgr${pg_version}
  - safeupdate_${pg_version} semver${pg_version} slony1-${pg_version} sqlite_fdw${pg_version} sslutils_${pg_version} system_stats_${pg_version}
  - table_version${pg_version} topn_${pg_version}


#------------------------------------------------------------------------------
# POSTGRES CLUSTER PROVISION
#------------------------------------------------------------------------------
# - identity - #
pg_cluster:                                 # [REQUIRED] cluster name (validated during pg_preflight)
pg_seq: 0                                   # [REQUIRED] instance seq (validated during pg_preflight)
pg_role: replica                            # [REQUIRED] service role (validated during pg_preflight)
pg_hostname: false                          # overwrite node hostname with pg instance name

# - retention - #
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

# - patroni - #
# patroni_mode, available options: default|pause|remove
# default: default ha mode
# pause:   into maintainance mode
# remove:  remove patroni after bootstrap
patroni_mode: default                         # pause|default|remove
pg_namespace: /pg                             # top level key namespace in dcs
patroni_port: 8008                            # default patroni port
patroni_watchdog_mode: automatic              # watchdog mode: off|automatic|required

# - template - #
pg_conf: patroni.yml                          # user provided patroni config template path
pg_init: initdb.sh                            # user provided post-init script path, default: initdb.sh

# - authentication - #
pg_hba_common:
  - '"# allow: meta node access with password"'
  - host    all     all                         10.10.10.10/32      md5
  - '"# allow: intranet admin role with password"'
  - host    all     +dbrole_admin               10.0.0.0/8          md5
  - host    all     +dbrole_admin               192.168.0.0/16      md5
  - '"# allow local (pgbouncer) read-write user (production user) password access"'
  - local   all     +dbrole_readwrite                               md5
  - host    all     +dbrole_readwrite           127.0.0.1/32        md5
  - '"# intranet common user password access"'
  - host    all             all                 10.0.0.0/8          md5
  - host    all             all                 192.168.0.0/16      md5
pg_hba_primary: []
pg_hba_replica:
  - '"# allow remote readonly user (stats, personal user) password access (directly)"'
  - local   all     +dbrole_readonly                               md5
  - host    all     +dbrole_readonly           127.0.0.1/32        md5
pg_hba_pgbouncer:
  - '# biz_user intranet password access'
  - local  all          all                                     md5
  - host   all          all                     127.0.0.1/32    md5
  - host   all          all                     10.0.0.0/8      md5
  - host   all          all                     192.168.0.0/16  md5

# - credential - #
pg_dbsu_password: ''                          # dbsu password (leaving blank will disable sa password login)
pg_replication_username: replicator           # replication user
pg_replication_password: replicator           # replication password
pg_monitor_username: dbuser_monitor           # monitor user
pg_monitor_password: dbuser_monitor           # monitor password

# - default - #
pg_default_username: postgres                 # non 'postgres' will create a default admin user (not superuser)
pg_default_password: postgres                 # dbsu password, omit for 'postgres'
pg_default_database: postgres                 # non 'postgres' will create a default database
pg_default_schema: public                     # default schema will be create under default database and used as first element of search_path
pg_default_extensions: "tablefunc,postgres_fdw,file_fdw,btree_gist,btree_gin,pg_trgm"

# - pgbouncer - #
pgbouncer_port: 6432                          # default pgbouncer port
pgbouncer_poolmode: transaction               # default pooling mode: transaction pooling
pgbouncer_max_db_conn: 100                    # important! do not set this larger than postgres max conn or conn limit


#------------------------------------------------------------------------------
# MONITOR PROVISION
#------------------------------------------------------------------------------
# - monitor options -
node_exporter_port: 9100                # default port for node exporter
pg_exporter_port: 9630                  # default port for pg exporter
pgbouncer_exporter_port: 9631           # default port for pgbouncer exporter
exporter_metrics_path: /metrics         # default metric path for pg related exporter


#------------------------------------------------------------------------------
# PROXY PROVISION
#------------------------------------------------------------------------------
# - vip - #
vip_enabled: false                            # level2 vip requires primary/standby under same switch
vip_address: 127.0.0.1                        # virtual ip address ip/cidr
vip_cidrmask: 32                              # virtual ip address cidr mask
vip_interface: eth0                           # virtual ip network interface

# - haproxy - #
haproxy_enabled: true                         # enable haproxy among every cluster members
haproxy_policy: leastconn                     # roundrobin, leastconn
haproxy_admin_username: admin                 # default haproxy admin username
haproxy_admin_password: admin                 # default haproxy admin password
haproxy_client_timeout: 3h                    # client side connection timeout
haproxy_server_timeout: 3h                    # server side connection timeout
haproxy_exporter_port: 9101                   # default admin/exporter port
haproxy_check_port: 8008                      # default health check port (patroni 8008 by default)
haproxy_primary_port:  5433                   # default primary port 5433
haproxy_replica_port:  5434                   # default replica port 5434
haproxy_backend_port:  6432                   # default target port: pgbouncer:6432 postgres:5432

```





## Playbook

[`postgres.yml`](../postgres.yml) will bootstrap PostgreSQL cluster according to inventory (assume infra provisioned)

```yaml
  play #1 (all): Init database cluster	TAGS: []
    tasks:
      postgres : Create os group postgres	TAGS: [instal, pg_dbsu, postgres]
      postgres : Make sure dcs group exists	TAGS: [instal, pg_dbsu, postgres]
      postgres : Create dbsu {{ pg_dbsu }}	TAGS: [instal, pg_dbsu, postgres]
      postgres : Grant dbsu nopass sudo	TAGS: [instal, pg_dbsu, postgres]
      postgres : Grant dbsu all sudo	TAGS: [instal, pg_dbsu, postgres]
      postgres : Grant dbsu limited sudo	TAGS: [instal, pg_dbsu, postgres]
      postgres : Config patroni watchdog support	TAGS: [instal, pg_dbsu, postgres]
      postgres : Add dbsu ssh no host checking	TAGS: [instal, pg_dbsu, postgres]
      postgres : Fetch dbsu public keys	TAGS: [instal, pg_dbsu, postgres]
      postgres : Exchange dbsu ssh keys	TAGS: [instal, pg_dbsu, postgres]
      postgres : Install offical pgdg yum repo	TAGS: [instal, pg_install, postgres]
      postgres : Install pg packages	TAGS: [instal, pg_install, postgres]
      postgres : Install pg extensions	TAGS: [instal, pg_install, postgres]
      postgres : Link /usr/pgsql to current version	TAGS: [instal, pg_install, postgres]
      postgres : Add pg bin dir to profile path	TAGS: [instal, pg_install, postgres]
      postgres : Fix directory ownership	TAGS: [instal, pg_install, postgres]
      postgres : Remove default postgres service	TAGS: [instal, pg_install, postgres]
      postgres : Check necessary variables exists	TAGS: [always, pg_preflight, postgres, preflight]
      postgres : Fetch variables via pg_cluster	TAGS: [always, pg_preflight, postgres, preflight]
      postgres : Set cluster basic facts for hosts	TAGS: [always, pg_preflight, postgres, preflight]
      postgres : Assert cluster primary singleton	TAGS: [always, pg_preflight, postgres, preflight]
      postgres : Setup cluster primary ip address	TAGS: [always, pg_preflight, postgres, preflight]
      postgres : Setup repl upstream for primary	TAGS: [always, pg_preflight, postgres, preflight]
      postgres : Setup repl upstream for replicas	TAGS: [always, pg_preflight, postgres, preflight]
      postgres : Debug print instance summary	TAGS: [always, pg_preflight, postgres, preflight]
      postgres : Check for existing postgres instance	TAGS: [pg_check, postgres, prepare]
      postgres : Set fact whether pg port is open	TAGS: [pg_check, postgres, prepare]
      postgres : Abort due to existing postgres instance	TAGS: [pg_check, postgres, prepare]
      postgres : Clean existing postgres instance	TAGS: [pg_check, postgres, prepare]
      postgres : Shutdown existing postgres service	TAGS: [pg_clean, postgres, prepare]
      postgres : Remove registerd consul service	TAGS: [pg_clean, postgres, prepare]
      postgres : Remove postgres metadata in consul	TAGS: [pg_clean, postgres, prepare]
      postgres : Remove existing postgres data	TAGS: [pg_clean, postgres, prepare]
      postgres : Make sure main and backup dir exists	TAGS: [pg_dir, postgres, prepare]
      postgres : Create postgres directory structure	TAGS: [pg_dir, postgres, prepare]
      postgres : Create pgbouncer directory structure	TAGS: [pg_dir, postgres, prepare]
      postgres : Create links from pgbkup to pgroot	TAGS: [pg_dir, postgres, prepare]
      postgres : Create links from current cluster	TAGS: [pg_dir, postgres, prepare]
      postgres : Copy postgres scripts to /pg/bin/	TAGS: [pg_scripts, postgres, prepare]
      postgres : Copy alias profile to /etc/profile.d	TAGS: [pg_scripts, postgres, prepare]
      postgres : Copy psqlrc to postgres home	TAGS: [pg_scripts, postgres, prepare]
      postgres : Setup hostname to pg instance name	TAGS: [pg_hostname, postgres, prepare]
      postgres : Copy consul node-meta definition	TAGS: [postgres, prepare]
      postgres : Restart consul to load new node-meta	TAGS: [postgres, prepare]
      postgres : Config patroni watchdog support	TAGS: [pg_watchdog, postgres, prepare]
      postgres : Get config parameter page count	TAGS: [pg_config, postgres]
      postgres : Get config parameter page size	TAGS: [pg_config, postgres]
      postgres : Tune shared buffer and work mem	TAGS: [pg_config, postgres]
      postgres : Hanlde small size mem occasion	TAGS: [pg_config, postgres]
      postgres : Calculate postgres mem params	TAGS: [pg_config, postgres]
      postgres : Render default initdb scripts	TAGS: [pg_config, postgres]
      postgres : create patroni config dir	TAGS: [pg_config, postgres]
      postgres : use predefined patroni template	TAGS: [pg_config, postgres]
      postgres : Render default /pg/conf/patroni.yml	TAGS: [pg_config, postgres]
      postgres : Link /pg/conf/patroni to /pg/bin/	TAGS: [pg_config, postgres]
      postgres : Link /pg/bin/patroni.yml to /etc/patroni/	TAGS: [pg_config, postgres]
      postgres : Config patroni watchdog support	TAGS: [pg_config, postgres]
      postgres : create patroni systemd drop-in dir	TAGS: [pg_config, postgres]
      postgres : Copy postgres systemd service file	TAGS: [pg_config, postgres]
      postgres : create patroni systemd drop-in file	TAGS: [pg_config, postgres]
      postgres : Launch patroni on primary instance	TAGS: [pg_primary, postgres]
      postgres : Wait for patroni primary online	TAGS: [pg_primary, postgres]
      postgres : Wait for postgres primary online	TAGS: [pg_primary, postgres]
      postgres : Check primary postgres service ready	TAGS: [pg_primary, postgres]
      postgres : Check replication connectivity to primary	TAGS: [pg_primary, postgres]
      postgres : Check replication connectivity to primary	TAGS: [pg_replica, postgres]
      postgres : Launch patroni on replica instances	TAGS: [pg_replica, postgres]
      postgres : Wait for patroni replica online	TAGS: [pg_replica, postgres]
      postgres : Wait for postgres replica online	TAGS: [pg_replica, postgres]
      postgres : Check replica postgres service ready	TAGS: [pg_replica, postgres]
      postgres : Pause patroni	TAGS: [pg_patroni, postgres]
      postgres : Stop patroni on replica instance	TAGS: [pg_patroni, postgres]
      postgres : Stop patroni on primary instance	TAGS: [pg_patroni, postgres]
      postgres : Launch raw postgres on primary	TAGS: [pg_patroni, postgres]
      postgres : Launch raw postgres on primary	TAGS: [pg_patroni, postgres]
      postgres : Wait for postgres online	TAGS: [pg_patroni, postgres]
      postgres : Check pgbouncer is installed	TAGS: [pgbouncer, pgbouncer_check, postgres]
      postgres : Stop existing pgbouncer service	TAGS: [pgbouncer, pgbouncer_cleanup, postgres]
      postgres : Remove existing pgbouncer dirs	TAGS: [pgbouncer, pgbouncer_cleanup, postgres]
      postgres : Recreate dirs with owner postgres	TAGS: [pgbouncer, pgbouncer_cleanup, postgres]
      postgres : Copy /etc/pgbouncer/pgbouncer.ini	TAGS: [pgbouncer, pgbouncer_config, postgres]
      postgres : Copy /etc/pgbouncer/pgb_hba.conf	TAGS: [pgbouncer, pgbouncer_config, postgres]
      postgres : Add system users to pgbouncer	TAGS: [pgbouncer, pgbouncer_config, postgres]
      postgres : Add default users to pgbouncer	TAGS: [pgbouncer, pgbouncer_config, postgres]
      postgres : Add default database to pgbouncer	TAGS: [pgbouncer, pgbouncer_config, postgres]
      postgres : Copy pgbouncer systemd service	TAGS: [pgbouncer, pgbouncer_launch, postgres]
      postgres : Launch pgbouncer pool service	TAGS: [pgbouncer, pgbouncer_launch, postgres]
      postgres : Wait for pgbouncer service online	TAGS: [pgbouncer, pgbouncer_launch, postgres]
      postgres : Check pgbouncer service is ready	TAGS: [pgbouncer, pgbouncer_launch, postgres]
      postgres : Check pgbouncer connectivity	TAGS: [pgbouncer, pgbouncer_launch, postgres]
      postgres : Copy postgres service definition	TAGS: [pg_register, postgres, register]
      postgres : Reload consul service	TAGS: [pg_register, postgres, register]
      postgres : Create grafana datasource postgres	TAGS: [pg_register, postgres, register]
      monitor : Create /etc/pg_exporter conf dir	TAGS: [monitor, pg_exporter]
      monitor : Copy default pg_exporter.yaml	TAGS: [monitor, pg_exporter]
      monitor : Config /etc/default/pg_exporter	TAGS: [monitor, pg_exporter]
      monitor : Config pg_exporter service unit	TAGS: [monitor, pg_exporter]
      monitor : Launch pg_exporter systemd service	TAGS: [monitor, pg_exporter]
      monitor : Wait for pg_exporter service online	TAGS: [monitor, pg_exporter]
      monitor : Register pg-exporter consul service	TAGS: [monitor, pg_exporter]
      monitor : Reload pg-exporter consul service	TAGS: [monitor, pg_exporter]
      monitor : Config pgbouncer_exporter opts	TAGS: [monitor, pgbouncer_exporter]
      monitor : Config pgbouncer_exporter service	TAGS: [monitor, pgbouncer_exporter]
      monitor : Launch pgbouncer_exporter service	TAGS: [monitor, pgbouncer_exporter]
      monitor : Wait for pgbouncer_exporter online	TAGS: [monitor, pgbouncer_exporter]
      monitor : Register pgb-exporter consul service	TAGS: [monitor, pgbouncer_exporter]
      monitor : Reload pgb-exporter consul service	TAGS: [monitor, pgbouncer_exporter]
      monitor : Copy node_exporter systemd service	TAGS: [monitor, node_exporter]
      monitor : Config default node_exporter options	TAGS: [monitor, node_exporter]
      monitor : Launch node_exporter service unit	TAGS: [monitor, node_exporter]
      monitor : Wait for node_exporter online	TAGS: [monitor, node_exporter]
      monitor : Register node-exporter service	TAGS: [monitor, node_exporter]
      monitor : Reload node-exporter consul service	TAGS: [monitor, node_exporter]
      proxy : Templating /etc/default/vip-manager.yml	TAGS: [proxy, vip]
      proxy : create vip-manager. systemd drop-in dir	TAGS: [proxy, vip]
      proxy : create vip-manager systemd drop-in file	TAGS: [proxy, vip]
      proxy : Launch vip-manager	TAGS: [proxy, vip]
      proxy : Set pg_instance in case of absence	TAGS: [haproxy, proxy]
      proxy : Fetch postgres cluster memberships	TAGS: [haproxy, proxy]
      proxy : Templating /etc/haproxyhaproxy.cfg	TAGS: [haproxy, proxy]
      proxy : Copy haproxy systemd service file	TAGS: [haproxy, proxy]
      proxy : Launch haproxy load balancer service	TAGS: [haproxy, proxy]
      proxy : Wait for haproxy load balancer online	TAGS: [haproxy, proxy]
      proxy : Copy haproxy service definition	TAGS: [haproxy_register, proxy]
      proxy : Reload haproxy consul service	TAGS: [haproxy_register, proxy]
```

