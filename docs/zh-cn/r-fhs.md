# 目录结构

## Pigsty目录结构


```bash
#------------------------------------------------------------------------------
# pigsty
#  ^-----@app                    # extra demo application resources
#  ^-----@bin                    # bin scripts
#  ^-----@docs                   # document (can be docsified)
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
#            ^-----@infra        # infra static targets definition
#            ^-----@pgsql        # pgsql static targets definition
#            ^-----@redis (n/a)  # redis static targets definition (not exists for now)
#  ^-----@dashboards             # static grafana dashboards
#  ^-----@datasources            # static grafana datasources
#  ^-----@playbooks              # extra ansible playbooks
#------------------------------------------------------------------------------
```


## Prometheus目录结构

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
#            ^-----@pgsql-rules      # database metrics definition
#            ^-----@infra-alert      # database alert definition
# /etc/pigsty/
#  ^-----@targets                    # file based service discovery targets definition
#            ^-----@infra            # infra static targets definition
#            ^-----@pgsql            # pgsql static targets definition
#            ^-----@redis (n/a)      # redis static targets definition (not exists for now)
#
#------------------------------------------------------------------------------
```


## Postgres目录结构

以下参数与PostgreSQL数据库目录相关

* [pg_dbsu_home](#pg_dbsu_home)：Postgres默认用户的家目录，默认为`/var/lib/pgsql`
* [pg_bin_dir](#pg_bin_dir)：Postgres二进制目录，默认为`/usr/pgsql/bin/`
* [pg_data](#pg_data)：Postgres数据库目录，默认为`/pg/data`
* [pg_fs_main](#pg_fs_main)：Postgres主数据盘挂载点，默认为`/export`
* [pg_fs_bkup](#pg_fs_bkup)：Postgres备份盘挂载点，默认为`/var/backups`（可选，也可以选择备份到主数据盘上的子目录）


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



## PG二进制目录结构

在RedHat/CentOS上，默认的Postgres发行版安装位置为

```bash
/usr/pgsql-${pg_version}/
```

安装剧本会自动创建指向当前安装版本的软连接，例如，如果安装了14版本的Postgres，则有：

```bash
/usr/pgsql -> /usr/pgsql-14
```

因此，默认的`pg_bin_dir`为`/usr/pgsql/bin/`，该路径会在`/etc/profile.d/pgsql.sh`中添加至所有用户的`PATH`环境变量中。



## PG数据目录结构

Pigsty假设用于部署数据库实例的单个节点上至少有一块主数据盘（`pg_fs_main`），以及一块可选的备份数据盘（`pg_fs_bkup`）。通常主数据盘是高性能SSD，而备份盘是大容量廉价HDD。

```yaml
#------------------------------------------------------------------------------
# Create Directory
#------------------------------------------------------------------------------
# this assumes that
#   /pg is shortcut for postgres home
#   {{ pg_fs_main }} contains the main data             (MUST ALREADY MOUNTED)
#   {{ pg_fs_bkup }} contains archive and backup data   (MAYBE ALREADY MOUNTED)
#   {{ pg_cluster }}-{{ pg_version }} is the default parent folder 
#    for pgdata (e.g pg-test-14)
#------------------------------------------------------------------------------
# default variable:
#     pg_fs_main = /export           fast ssd
#     pg_fs_bkup = /var/backups      cheap hdd
#
#     /pg      -> /export/postgres/pg-test-14
#     /pg/data -> /export/postgres/pg-test-14/data
```



## PG数据库集簇目录结构

```bash
# basic
{{ pg_fs_main }}     /export                      # contains all business data (pg,consul,etc..)
{{ pg_dir_main }}    /export/postgres             # contains postgres main data
{{ pg_cluster_dir }} /export/postgres/pg-test-14  # contains cluster `pg-test` data (of version 13)
                     /export/postgres/pg-test-14/bin            # binary scripts
                     /export/postgres/pg-test-14/log            # misc logs
                     /export/postgres/pg-test-14/tmp            # tmp, sql files, records
                     /export/postgres/pg-test-14/conf           # configurations
                     /export/postgres/pg-test-14/data           # main data directory
                     /export/postgres/pg-test-14/meta           # identity information
                     /export/postgres/pg-test-14/stat           # stats information
                     /export/postgres/pg-test-14/change         # changing records

{{ pg_fs_bkup }}     /var/backups                      # contains all backup data (pg,consul,etc..)
{{ pg_dir_bkup }}    /var/backups/postgres             # contains postgres backup data
{{ pg_backup_dir }}  /var/backups/postgres/pg-test-14  # contains cluster `pg-test` backup (of version 13)
                     /var/backups/postgres/pg-test-14/backup   # base backup
                     /var/backups/postgres/pg-test-14/arcwal   # WAL archive
                     /var/backups/postgres/pg-test-14/remote   # mount NFS/S3 remote resources here

# links
/pg             -> /export/postgres/pg-test-14               # pg root link
/pg/data        -> /export/postgres/pg-test-14/data          # real data dir
/pg/backup      -> /var/backups/postgres/pg-test-14/backup   # base backup
/pg/arcwal      -> /var/backups/postgres/pg-test-14/arcwal   # WAL archive
/pg/remote      -> /var/backups/postgres/pg-test-14/remote   # mount NFS/S3 remote resources here

```



## Pgbouncer配置文件结构

Pgbouncer使用Postgres用户运行，配置文件位于`/etc/pgbouncer`。配置文件包括：

* `pgbouncer.ini`，主配置文件
* `userlist.txt`：列出连接池中的用户
* `pgb_hba.conf`：列出连接池用户的访问权限
* `database.txt`：列出连接池中的数据库


