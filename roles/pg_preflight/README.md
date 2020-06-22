# PG Pre-Flight (ansible role)

This role will perform a pre-flight check before initializing clusters
It basically check inventory locally and set & modify some variables


### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
tasks:
  pg_preflight : Check necessary variables exists	TAGS: [pg_preflight]
  pg_preflight : Fetch variables via pg_cluster		TAGS: [pg_preflight]
  pg_preflight : Set cluster basic facts for hosts	TAGS: [pg_preflight]
  pg_preflight : Assert cluster primary singleton	TAGS: [pg_preflight]
  pg_preflight : Setup cluster primary ip address	TAGS: [pg_preflight]
  pg_preflight : Setup repl upstream for primary	TAGS: [pg_preflight]
  pg_preflight : Setup repl upstream for replicas	TAGS: [pg_preflight]
  pg_preflight : Debug print instance summary		TAGS: [pg_preflight]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
---
################################################################
# Default PostgreSQL Settings
################################################################

#==============================================================#
# Postgres Installation Options
#==============================================================#
# install option
pg_dbsu:  postgres               # postgresql dbsu (currently setup during node provision)
pg_home:  /usr/pgsql             # postgresql binary
pg_bin:   /usr/pgsql/bin         # postgresql binary

pg_version: 12                    # default postgresql version
pg_pgdg_repo: true                # use official pgdg yum repo (disable if you have local mirror)

pg_postgis_install: true        # install postgis extension?
pg_postgis_version: 30          # install postgis extension?
pg_timescaledb_install: true    # install postgis extension?

pg_adiitional_packages:
  - pgbouncer                   # connection pooler
  - patroni                     # ha agent
  - pg_exporter                 # ()
  - haproxy                     # (provisioned in role node)
  - keepalived                  # (provisioned in role node)

# keep prefix intact here
pg_version_specific_packages:
  - pg_repack
  - wal2json
  - pg_repack
  - pg_qualstats
  - pg_stat_kcache
  - pg_cron_
  - timescaledb_
  - pglogical_



#==============================================================#
# Postgres Initdb Options
#==============================================================#
pg_cluster: test                # [REQUIRED] cluster name [VERY Important!]
pg_dbsu: postgres               # os user that holds postgres cluster
pg_data: /pg/data               # postgres data directory
pg_port: 5432                   # postgres port
pg_purge: false                 # force removing existing cluster ???!!! [DANGEROUS]
pg_overwrite_hostname: false    # overwrite node hostname with pg instance name

pg_standby_cluster: false       # if set to true, init this cluster as a standby cluster
pg_initdb_method: initdb        # option: initdb  | backup | upstream
                                #  * initdb:  create a new cluster
                                #  * data:    use existing data dir (if version match)
                                #  * backup:  extract a baebackup from file
                                #  * pg_baesbackup: make online backup from upstream
                                #  * standby_cluster: mark this cluster as standby cluster


# used when method=initdb : locale=C.UTF8 and enable datachecksum
pg_initdb_opts: '--encoding=UTF8 --locale=C --data-checksum'
pg_initdb_backup_path:          # used when method=backup : standard backup file path:
pg_initdb_upstream_url:         # used when method=pg_basebackup|standby_cluster

pg_listen_address: '*'          # postgres listen address, '*' by default
postgresql_conf_path: "postgresql.conf"               # config path: if provided
pg_primary_hba_path: "pg_hba-primary.conf"            # primary hba config file
pg_replica_hba_path: "pg_hba-replica.conf"            # replica hba config file
pg_archive_hba_path: "pg_hba-archive.conf"            # archive hba config file

# system user: replication and monitor (important!)
pg_replication_username: 'replicator'
pg_replication_password: 'replicator'
pg_monitor_username: 'dbuser_monitor'
pg_monitor_password: 'monitor'

# pg scripts that modify template1 database
pg_template_scripts:
  - default-role.sql
  - monitor-schema.sql

# default database and users ()
pg_default_database: 'postgres'
pg_default_username: 'postgres'
pg_default_password: 'postgres'

#==============================================================#
# Pgbouncer Settings
#==============================================================#
pg_pgbouncer_enabled: true                # default pooler
pg_pgbouncer_port: 6432                   # default pgbouncer port
pg_pgbouncer_poolmode: transaction        # default pooling mode: transaction pooling
pg_pgbouncer_max_db_conn: 100             # important! do not set this larger than postgres max conn or conn limit

#==============================================================#
# Patroni Settings
#==============================================================#
pg_patroni_enabled: true                  # default ha agent
pg_patroni_watchdog: true                 # use watchdog?
pg_patroni_watchdog_path: /dev/watchdog   # watchdog path, if set

#==============================================================#
# Monitor Settings
#==============================================================#
pg_exporter_conf: /etc/pg_exporter/pg_exporter.yaml   # postgres export port
pg_exporter_metric_path: /metrics         # default telemetry path
pg_postgres_exporter_port: 9630           # postgres export port
pg_pgbouncer_exporter_port: 9631          # default pgbouncer monitor port

#==============================================================#
# Load Balancer Settings
#==============================================================#
pg_lb_enabled:       true           # default load balancer type
pg_lb_type:          haproxy        # haproxy | vip
pg_lb_role:          backup          # default lb role: master , backup
pg_lb_policy:        leastconn       # roundrobin, leastconn
pg_lb_admin:         admin           # default admin user
pg_lb_password:      admin           # default admin password
pg_lb_admin_port:    9101            # default admin port 9101
pg_lb_primary_port:  5433            # default primary port 5433
pg_lb_replica_port:  5434            # default replica port 5434
pg_lb_timeout_client: 3h
pg_lb_timeout_server: 3h
pg_lb_socket: /var/run/haproxy.socket
pg_lb_nic: eth1                      # default network interface for vip
# pg_lb_vip: 10.10.10.1              # [REQUIRED] field virtual vip address

...
```