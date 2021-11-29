# PostgreSQL Installation

The PG Install section is responsible for completing the installation of all PostgreSQL dependencies on a machine with the base software. The user can configure the name, ID, permissions, and access of the database superuser, configure the sources used for the installation, configure the installation address, the version to be installed, and the required packages and extension plugins.

Most of the parameters here only need to be modified when upgrading a major version of the database as a whole. Users can specify the software version to be installed via `pg_version` and override it at the cluster level to install different database versions for different clusters.


## Overview

|                            Name                             |    Type    | Level  | Description |
| :----------------------------------------------------------: | :--------: | :---: | ---- |
|               [pg_dbsu](v-pg-install.md#pg_dbsu)               |  `string`  |  G/C  | os dbsu for postgres |
|           [pg_dbsu_uid](v-pg-install.md#pg_dbsu_uid)           |  `number`  |  G/C  | dbsu UID |
|          [pg_dbsu_sudo](v-pg-install.md#pg_dbsu_sudo)          |  `enum`  |  G/C  | sudo priv mode for dbsu |
|          [pg_dbsu_home](v-pg-install.md#pg_dbsu_home)          |  `string`  |  G/C  | home dir for dbsu |
|  [pg_dbsu_ssh_exchange](v-pg-install.md#pg_dbsu_ssh_exchange)  |  `bool`  |  G/C  | exchange dbsu ssh keys? |
|            [pg_version](v-pg-install.md#pg_version)            |  `string`  |  G/C  | major PG version to be installed |
|             [pgdg_repo](v-pg-install.md#pgdg_repo)             |  `bool`  |  G/C  | add official PGDG repo? |
|           [pg_add_repo](v-pg-install.md#pg_add_repo)           |  `bool`  |  G/C  | add extra upstream PG repo? |
|            [pg_bin_dir](v-pg-install.md#pg_bin_dir)            |  `string`  |  G/C  | PG binary dir |
|           [pg_packages](v-pg-install.md#pg_packages)           |  `string[]`  |  G/C  | PG packages to be installed |
|         [pg_extensions](v-pg-install.md#pg_extensions)         |  `string[]`  |  G/C  | PG extension pkgs to be installed |



## Defaults

```yaml
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
  - citus_${pg_version}                       # citus
  - timescaledb_${pg_version}                 # timescaledb
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

```





## Details

The user name of the default operating system user (superuser) used by the database, which defaults to `postgres`, is not recommended to be changed.




### pg_dbsu_uid

The UID of the OS user (superuser) used by the database by default, default is `26`.

Consistent with the configuration of the official PostgreSQL RPM package under CentOS, no modifications are recommended.



### pg_dbsu_sudo

Default permissions for the database superuser.

* `none`: no sudo privileges
* `limit`: limited sudo privileges, can execute systemctl commands for database related components, default
* `all`: with full `sudo` privileges, but requires a password.
* `nopass`: full `sudo` privileges without password (not recommended)



### pg_dbsu_home

Home directory of the database superuser, default is `/var/lib/pgsql`




### pg_dbsu_ssh_exchange

Whether to exchange the superuser's SSH public-private key between machines that execute



### pg_version

The desired version of PostgreSQL to install, default is 13

It is recommended to override this variable on an as-needed basis at the cluster level.




### pgdg_repo

Flag, whether to use official PostgreSQL sources? Not used by default

Use this option to download and install PostgreSQL-related packages directly from official Internet sources without local sources.



### pg_add_repo

If used, the official source of PGDG will be added before installing PostgreSQL

Enabling this option allows you to perform database initialization directly without performing infrastructure initialization, which can be slow, but is especially useful for scenarios where infrastructure is missing.



### pg_bin_dir

PostgreSQL binary directory

Defaults to `/pusr/pgsql/bin/`, which is a softlink created manually during the installation process that points to the specific Postgres version directory installed.

For example `/usr/pgsql -> /usr/pgsql-13`.




### pg_packages

The default installed PostgreSQL packages

The `${pg_version}` in the packages will be replaced with the actual installed PostgreSQL version.

When you specify a specific `pg_version` for a particular cluster, you can adjust this parameter at the cluster level accordingly (e.g. when installing PG14 beta some extensions do not exist yet)

```bash
- postgresql${pg_version}* # postgresql kernel packages
- postgis31_${pg_version}* # postgis
- citus_${pg_version} # citus
- timescaledb_${pg_version} # timescaledb
- pgbouncer patroni pg_exporter pgbadger # 3rd utils
- patroni patroni-consul patroni-etcd pgbouncer pgbadger pg_activity
- python3 python3-psycopg2 python36-requests python3-etcd python3-consul
- python36-urllib3 python36-idna python36-pyOpenSSL python36-cryptography
```

### pg_extensions

PostgreSQL extensions plugin packages to be installed

The `${pg_version}` in the package will be replaced with the actual installed PostgreSQL version.

The plugins installed by default include.

```sql
pg_repack${pg_version}
pg_qualstats${pg_version}
pg_stat_kcache${pg_version}
wal2json${pg_version}
```

Enable as needed, but it is highly recommended to install the `pg_repack` extension.