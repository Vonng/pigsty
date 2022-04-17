# FHS: File Hierarchy Structure



## Pigsty Source Code

The FHS of pigsty source code

Extra dir `/etc/pigsty` will be created on the meta node during installation.

```bash
#------------------------------------------------------------------------------
# pigsty
#  ^-----@app                    # extra demo application resources
#  ^-----@bin                    # bin scripts
#  ^-----@docs                   # document
#  ^-----@files                  # ansible file resources 
#            ^-----@conf         # config template files
#            ^-----@rule         # soft link to prometheus rules
#            ^-----@ui           # soft link to grafana dashboards
#  ^-----@roles                  # ansible business logic
#  ^-----@templates              # ansible templates
#  ^-----@vagrant                # sandbox resources
#  ^-----configure               # configure wizard script
#  ^-----ansible.cfg             # default ansible config file
#  ^-----pigsty.yml              # default config file
#  ^-----*.yml                   # ansible playbooks

#------------------------------------------------------------------------------
# /etc/pigsty/
#  ^-----@targets                # file based service discovery targets definition
#  ^-----@dashboards             # static grafana dashboards
#  ^-----@datasources            # static grafana datasources
#  ^-----@playbooks              # extra ansible playbooks
#------------------------------------------------------------------------------
```




## Prometheus FHS

```bash
#------------------------------------------------------------------------------
# Config FHS
#------------------------------------------------------------------------------
# /etc/prometheus/
#  ^-----prometheus.yml              # prometheus main config file
#  ^-----alertmanager.yml            # alertmanger main config file
#  ^-----@bin                        # util scripts: check,reload,status,new
#  ^-----@rules                      # record & alerting rules definition
#            ^-----@infra-rules      # infrastructure metrics definition
#            ^-----@infra-alert      # infrastructure alert definition
#            ^-----@pgsql-rules      # postgres metrics definition
#            ^-----@pgsql-alert      # postgres alert definition
#            ^-----@redis-rules      # redis metrics definition
#            ^-----@redis-alert      # redis alert definition
#            ^-----@..........       # other metrics & alerts definition
#  ^-----@targets                    # file based service discovery targets definition
#            ^-----@infra            # infra static targets definition
#            ^-----@pgsql            # pgsql static targets definition
#            ^-----@redis            # redis static targets definition
#            ^-----@.....            # other targets
#------------------------------------------------------------------------------
```



## PG FHS

These parameters are related to PostgreSQL FHS:

* [pg_dbsu_home](v-pgsql.md#pg_dbsu_home): home directory of Postgres default user, default is `/var/lib/pgsql`
* [pg_bin_dir](v-pgsql.md#pg_bin_dir): Postgres binary directory, default is `/usr/pgsql/bin/`
* [pg_data](v-pgsql.md#pg_data): Postgres database directory, default is `/pg/data`
* [pg_fs_main](v-pgsql.md#pg_fs_main): Postgres main data disk mount point, default is `/export`
* [pg_fs_bkup](v-pgsql.md#pg_fs_bkup): Postgres backup disk mount point, default is `/var/backups` (optional, can also choose to backup to a subdirectory on the main data disk)

```yaml
#------------------------------------------------------------------------------
# Create Directory
#------------------------------------------------------------------------------
# this assumes that
#   /pg is shortcut for postgres home
#   {{ pg_fs_main }} contains the main data             (MUST ALREADY MOUNTED)
#   {{ pg_fs_bkup }} contains archive and backup data   (MUST ALREADY MOUNTED)
#   cluster-version is the default parent folder for pgdata (e.g pg-test-12)
#------------------------------------------------------------------------------
# default variable:
#     pg_fs_main = /export           fast ssd
#     pg_fs_bkup = /var/backups      cheap hdd
#
#     /pg      -> /export/postgres/pg-test-12
#     /pg/data -> /export/postgres/pg-test-12/data
#------------------------------------------------------------------------------
- name: Create postgresql directories
  tags: pg_dir
  become: yes
  block:
    - name: Make sure main and backup dir exists
      file: path={{ item }} state=directory owner=root mode=0777
      with_items:
        - "{{ pg_fs_main }}"
        - "{{ pg_fs_bkup }}"

    # pg_cluster_dir:    "{{ pg_fs_main }}/postgres/{{ pg_cluster }}-{{ pg_version }}"
    - name: Create postgres directory structure
      file: path={{ item }} state=directory owner={{ pg_dbsu }} group=postgres mode=0700
      with_items:
        - "{{ pg_fs_main }}/postgres"
        - "{{ pg_cluster_dir }}"
        - "{{ pg_cluster_dir }}/bin"
        - "{{ pg_cluster_dir }}/log"
        - "{{ pg_cluster_dir }}/tmp"
        - "{{ pg_cluster_dir }}/conf"
        - "{{ pg_cluster_dir }}/data"
        - "{{ pg_cluster_dir }}/meta"
        - "{{ pg_cluster_dir }}/stat"
        - "{{ pg_cluster_dir }}/change"
        - "{{ pg_backup_dir }}/postgres"
        - "{{ pg_backup_dir }}/arcwal"
        - "{{ pg_backup_dir }}/backup"
        - "{{ pg_backup_dir }}/remote"
```

### Binary Path

On RedHat/CentOS , the default binary install path is:

```bash
/usr/pgsql-${pg_version}/
```

Pigsty will create soft link `/usr/pgsql` to omit version info:

```bash
/usr/pgsql -> /usr/pgsql-13
```


Therefore, the default `pg_bin_dir` is `/usr/pgsql/bin/`, 
and this path is added to the `PATH` environment variable for all users via `/etc/profile.d/pgsql.sh`.


### Data Directory

Pigsty assumes that there is at least one primary data disk ([`pg_fs_main`](v-pgsql.md#pg_fs_main)), 
and an optional backup data disk ([`pg_fs_bkup`](v-pgsql.md#pg_fs_backup)) on the single node used to deploy the database instance.
Usually, the primary data disk is a high-performance SSD, while the backup disk is a high-capacity inexpensive HDD.

```yaml
#------------------------------------------------------------------------------
# Create Directory
#------------------------------------------------------------------------------
# this assumes that
#   /pg is shortcut for postgres home
#   {{ pg_fs_main }} contains the main data             (MUST ALREADY MOUNTED)
#   {{ pg_fs_bkup }} contains archive and backup data   (MAYBE ALREADY MOUNTED)
#   {{ pg_cluster }}-{{ pg_version }} is the default parent folder 
#    for pgdata (e.g pg-test-12)
#------------------------------------------------------------------------------
# default variable:
#     pg_fs_main = /export           fast ssd
#     pg_fs_bkup = /var/backups      cheap hdd
#
#     /pg      -> /export/postgres/pg-test-12
#     /pg/data -> /export/postgres/pg-test-12/data
```

if there is no backup disk available, you can assign a usable dir for it.

Subdir will be created under [`pg_fs_main`](v-pgsql.md#pg_fs_main) and [`pg_fs_bkup`](v-pgsql.md#pg_fs_bkup)

```bash
# basic
{{ pg_fs_main }}     /data                                    # contains all business data (pg,consul,etc..)
{{ pg_dir_main }}    /data/postgres                           # contains postgres main data
{{ pg_cluster_dir }} /data/postgres/pg-test-13                # contains cluster `pg-test` data (of version 13)
                     /data/postgres/pg-test-13/bin            # binary scripts
                     /data/postgres/pg-test-13/log            # misc logs
                     /data/postgres/pg-test-13/tmp            # tmp, sql files, records
                     /data/postgres/pg-test-13/conf           # configurations
                     /data/postgres/pg-test-13/data           # main data directory
                     /data/postgres/pg-test-13/meta           # identity information
                     /data/postgres/pg-test-13/stat           # stats information
                     /data/postgres/pg-test-13/change         # changing records

{{ pg_fs_bkup }}     /var/backups                              # contains all backup data (pg,consul,etc..)
{{ pg_dir_bkup }}    /var/backups/postgres                     # contains postgres backup data
{{ pg_backup_dir }}  /var/backups/postgres/pg-test-13          # contains cluster `pg-test` backup (of version 13)
                     /var/backups/postgres/pg-test-13/backup   # base backup
                     /var/backups/postgres/pg-test-13/arcwal   # WAL archive
                     /var/backups/postgres/pg-test-13/remote   # mount NFS/S3 remote resources here

# links
/pg             -> /data/postgres/pg-test-14                   # pg root link
/pg/data        -> /data/postgres/pg-test-14/data              # real data dir
/pg/backup      -> /var/backups/postgres/pg-test-14/backup     # base backup
/pg/arcwal      -> /var/backups/postgres/pg-test-14/arcwal     # WAL archive
/pg/remote      -> /var/backups/postgres/pg-test-14/remote     # mount NFS/S3 remote resources here

```



## Pgbouncer FHS

Pgbouncer is run with Postgres dbsu and the configuration file is located in `/etc/pgbouncer`. The configuration file includes.

* `pgbouncer.ini`, the main configuration file
* `userlist.txt`: lists the users in the connection pool
* `pgb_hba.conf`: lists the access rights of the connection pool users
* `database.txt`: lists the databases in the connection pool



## Redis FHS

Pigsty has monitoring & deployment support for Redis since v1.3

Redis binaries are installed via `yum` or `binary` under `/bin/`, including

```bash
redis-server    
redis-server    
redis-cli       
redis-sentinel  
redis-check-rdb 
redis-check-aof 
redis-benchmark 
/usr/libexec/redis-shutdown
```

for a redis instance named `redis-test-1-6379`
* redis_cluster = redis-test
* redis_node    = 1
* port          = 6379

```bash
/usr/lib/systemd/system/redis-test-1-6379.service               # service
/etc/redis/redis-test-1-6379.conf                               # config 
/data/redis/redis-test-1-6379                                   # data dir
/data/redis/redis-test-1-6379/redis-test-1-6379.rdb             # rdb
/data/redis/redis-test-1-6379/redis-test-1-6379.aof             # aof
/var/log/redis/redis-test-1-6379.log                            # log
/var/run/redis/redis-test-1-6379.pid                            # pid
```

