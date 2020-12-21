# PG Init (ansible role)

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
6. Business
    * Setup business users and databases
7. Register
    * Register service to database





### Tasks

[tasks/main.yml](tasks/main.yml)
* [`check.yml`](check.yml)
* [`clean.yml`](clean.yml)
* [`directory.yml`](directory.yml)
* [`initdb.yml`](initdb.yml) (primary)
* [`config.yml`](config.yml)
* [`bootstrap.yml`](bootstrap.yml)
* [`role.yml`](role.yml)
* [`template.yml`](template.yml)
* [`createdb.yml`](createdb.yml)
* [`pgpass.yml`](pgpass.yml)
* [`replica.yml`](replica.yml)
* [`register.yml`](register.yml)


```yaml
      pg_init : Check activated postgres version		TAGS: [pg_precheck]
      pg_init : Check for existing postgres instance	TAGS: [pg_precheck]
      pg_init : Set fact whether pg port is open		TAGS: [pg_precheck]
      pg_init : Abort due to existing postgres instance	TAGS: [pg_precheck]
      pg_init : Clean existing postgres instance		TAGS: [pg_precheck]
      pg_init : Shutdown existing postgres service		TAGS: [pg_clean]
      pg_init : Remove existing postgres directories	TAGS: [pg_clean]
      pg_init : Make sure main and backup dir exists	TAGS: [pg_directory]
      pg_init : Create postgres directory structure		TAGS: [pg_directory]
      pg_init : Create links from pgbkup to pgroot		TAGS: [pg_directory]
      pg_init : Create links from current cluster		TAGS: [pg_directory]
      pg_init : Initialize primary database cluster		TAGS: [pg_initdb]
      pg_init : Rename conf to postgresql.base.conf		TAGS: [pg_initdb]
      pg_init : Copy primary default postgresql.conf	TAGS: [pg_config]
      pg_init : Copy primary default pg_hba.conf		TAGS: [pg_config]
      pg_init : Gather fact memory total size			TAGS: [pg_config]
      pg_init : Calcuate shared buffer from mem			TAGS: [pg_config]
      pg_init : Remove some important parameters		TAGS: [pg_config]
      pg_init : Override some important parameters		TAGS: [pg_config]
      pg_init : Copy postgres systemd service file		TAGS: [pg_primary]
      pg_init : Launch postgres service on primary		TAGS: [pg_primary]
      pg_init : Waits for primary postgres online		TAGS: [pg_primary]
      pg_init : Check primary postgres service ready	TAGS: [pg_primary]
      pg_init : Create postgres replication user		TAGS: [pg_bootstrap]
      pg_init : Grant function usage to replicator		TAGS: [pg_bootstrap]
      pg_init : Create cluster default monitor user		TAGS: [pg_bootstrap]
      pg_init : Create pgpass with replication user		TAGS: [pg_bootstrap]
      pg_init : Check replication user connectivity		TAGS: [pg_bootstrap]
      pg_init : Create default role for read or write	TAGS: [pg_role]
      pg_init : Grant dbrole_readonly to readwrite		TAGS: [pg_role]
      pg_init : Create cluster default admin role		TAGS: [pg_role]
      pg_init : Grant dbrole_admin to dbsu postgres		TAGS: [pg_role]
      pg_init : Alter default privileges for roles		TAGS: [pg_role]
      pg_init : Render template scripts to remote		TAGS: [pg_template]
      pg_init : Execute templating scripts on remote	TAGS: [pg_template]
      pg_init : Create default business admin user		TAGS: [pg_createdb]
      pg_init : Create default business database		TAGS: [pg_createdb]
      pg_init : Create pgpass with business userinfo	TAGS: [pg_createdb]
      pg_init : Check business database connectivity	TAGS: [pg_createdb]
      pg_init : Render template scripts to remote		TAGS: [pg_createdb]
      pg_init : Provision default database scripts		TAGS: [pg_createdb]
      pg_init : Write pgpass with default userinfo		TAGS: [pg_pass]
      pg_init : Add default database user to pgpass		TAGS: [pg_pass]
      pg_init : Check replica connectivity to primary	TAGS: [pg_replica]
      pg_init : Create basebackup replica from primary	TAGS: [pg_replica]
      pg_init : Config replica replication source		TAGS: [pg_replica]
      pg_init : Copy postgres replica service file		TAGS: [pg_replica]
      pg_init : Launch postgres service on primary		TAGS: [pg_replica]
      pg_init : Waits for replica postgres online		TAGS: [pg_replica]
      pg_init : Check replica postgres service ready	TAGS: [pg_replica]
      pg_init : Setup hostname to pg instance name		TAGS: [pg_hostname]
      pg_init : Copy postgres service definition		TAGS: [pg_register]
      pg_init : Copy consul node-meta definition		TAGS: [pg_register]
      pg_init : Restart consul to load new node-meta	TAGS: [pg_register]
      pg_init : Create grafana datasource postgres		TAGS: [pg_register]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
#==============================================================#
# Postgres Dynamic Vars
#==============================================================#
pg_bin_dir:       "{{ pg_home }}/bin"
pg_cluster_dir:   "{{ pg_fs_main }}/postgres/{{ pg_cluster }}-{{ pg_version }}"
pg_backup_dir:    "{{ pg_fs_bkup }}/postgres/{{ pg_cluster }}-{{ pg_version }}"

# this are variables build from pg_version and pg_role
# they will be override by  pg_conf_path and pg_hba_path if provided
pg_default_conf:  "postgresql-{{ pg_version }}.conf"
pg_default_hba:   "pg_hba-{{ pg_role }}.conf"

#==============================================================#
# Postgres Install Options
#==============================================================#
pg_version: 12                  # default postgresql version
pg_dbsu:  postgres              # postgresql dbsu (currently setup during node provision)
pg_home:  /usr/pgsql            # postgresql binary installed path


#==============================================================#
# Postgres Initdb Options
#==============================================================#
# important host variables
# pg_cluster:                   # [REQUIRED] cluster name (already validate during pg_preflight)
# pg_seq: 0                     # [REQUIRED] instance seq (already validate during pg_preflight)
pg_role: replica                # [REQUIRED] service role (already validate during pg_preflight)

pg_exists: false
pg_exists_action: skip          # if cluster already eixsts, what to do:
                                #     - abort: abort entire play's execution (default)
                                #     - clean: remove existing cluster
                                #     - skip: only

pg_data: /pg/data               # postgres data directory
pg_port: 5432                   # postgres port

# directory structure
pg_fs_main: /export             # main disk monutpoint (or /data is another common mountpoint)
pg_fs_bkup: /var/backups        # backup mountpoint

pg_overwrite_hostname: true     # overwrite node hostname with pg instance name
pg_standby_cluster: false       # if set to true, init this cluster as a standby cluster
pg_initdb_method: initdb        # option: initdb  | backup | upstream
                                #   - initdb:  create a new database cluster with initdb
                                #   - backup:  extract a baebackup from file
                                #   - pg_baesbackup: make online backup from upstream
                                #   - standby_cluster: mark this cluster as standby cluster


# used when method=initdb : locale=C.UTF8 and enable datachecksum
pg_initdb_opts: '--encoding=UTF8 --locale=C --data-checksum'
pg_initdb_backup_path:          # used when method=backup : standard backup file path:
pg_initdb_upstream_url:         # used when method=pg_basebackup|standby_cluster

pg_listen_address: '*'          # postgres listen address, '*' by default
# pg_conf_path:                 # user-providede postgresql.conf
# pg_hba_path:                  # user-providede pg_hba.conf


# system user: replication and monitor (important!)
pg_replication_username: 'replicator'   # replication user
pg_replication_password: 'replicator'
pg_monitor_username: 'dbuser_monitor'   # monitor user
pg_monitor_password: 'dbuser_monitor'

# pg scripts that modify template1 database
pg_template_scripts:
  - monitor-schema.sql

# default database and users
pg_default_database: 'postgres'
pg_default_username: 'postgres'
pg_default_password: 'postgres'
pg_default_scripts: []                 # sql scripts to init default database


```