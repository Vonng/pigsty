# PGSQL Authentication

> Host-Based Authentication in Pigsty

PostgreSQL has various [authentication](https://www.postgresql.org/docs/current/client-authentication.html) methods. You can use all of them, while pigsty's battery-include ACL system focuses on HBA, password, and SSL authentication.



---------------------

## Client Authentication

To connect to a PostgreSQL database, the user has to be authenticated (with a password by default).

You can provide the password in the connection string (not secure) or use the `PGPASSWORD` env or `.pgpass` file. Check [`psql`](https://www.postgresql.org/docs/current/app-psql.html#usage) docs and [PostgreSQL connection string](https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING) for more details.

```bash
psql 'host=<host> port=<port> dbname=<dbname> user=<username> password=<password>'
psql postgres://<username>:<password>@<host>:<port>/<dbname>
PGPASSWORD=<password>; psql -U <username> -h <host> -p <port> -d <dbname>
```

The default connection string for the `meta` database:

```bash
psql 'host=10.10.10.10 port=5432 dbname=meta user=dbuser_dba password=DBUser.DBA'
psql postgres://dbuser_dba:DBUser.DBA@10.10.10.10:5432/meta
PGPASSWORD=DBUser.DBA; psql -U dbuser_dba -h 10.10.10.10 -p 5432 -d meta
```

To connect with the SSL certificate, you can use the `PGSSLCERT` and `PGSSLKEY` env or `sslkey` & `sslcert` parameters.

```bash
psql 'postgres://dbuser_dba:DBUser.DBA@10.10.10.10:5432/meta?sslkey=/path/to/dbuser_dba.key&sslcert=/path/to/dbuser_dba.crt'
```

While the client certificate (`CN` = username) can be issued with local CA & [cert.yml](https://github.com/Vonng/pigsty/blob/master/cert.yml).




---------------------

## Define HBA

There are four parameters for HBA Rules in Pigsty:

* [`pg_hba_rules`](PARAM#pg_hba_rules): postgres ad-hoc hba rules
* [`pg_default_hba_rules`](PARAM#pg_default_hba_rules): postgres default hba rules
* [`pgb_hba_rules`](PARAM#pgb_hba_rules): pgbouncer ad-hoc hba rules
* [`pgb_default_hba_rules`](PARAM#pgb_default_hba_rules): pgbouncer default hba rules

Which are array of hba rule objects, and each hba rule is one of the following forms:

### 1. Raw Form

```yaml
- title: allow intranet password access
  role: common
  rules:
    - host   all  all  10.0.0.0/8      md5
    - host   all  all  172.16.0.0/12   md5
    - host   all  all  192.168.0.0/16  md5
```

In the form, the `title` will be rendered as a comment line, followed by the `rules` as hba string one by one.

An HBA Rule is installed when the instance's [`pg_role`](PARAM#pg_role) is the same as the `role`.

HBA Rule with `role: common` will be installed on all instances. 

HBA Rule with `role: offline` will be installed on instances with [`pg_role`](PARAM#pg_role) = `offline` or [`pg_offline_query`](PARAM#pg_offline_query) = `true`.



### 2. Alias Form

The alias form, which replace `rules` with `addr`, `auth`, `user`, and `db` fields.

```yaml
- addr: 'intra'    # world|intra|infra|admin|local|localhost|cluster|<cidr>
  auth: 'pwd'      # trust|pwd|ssl|cert|deny|<official auth method>
  user: 'all'      # all|${dbsu}|${repl}|${admin}|${monitor}|<user>|<group>
  db: 'all'        # all|replication|....
  rules: []        # raw hba string precedence over above all
  title: allow intranet password access
```

- `addr`: **where** 
  - `world`: all IP addresses
  - `intra`: all intranet cidr: `'10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16'`
  - `infra`: IP addresses of infra nodes
  - `admin`: `admin_ip` address
  - `local`: local unix socket
  - `localhost`: local unix socket + tcp 127.0.0.1/32
  - `cluster`: all IP addresses of pg cluster members  
  - `<cidr>`: any standard CIDR blocks or IP addresses
- `auth`: **how**
  - `deny`: reject access
  - `trust`: trust authentication
  - `pwd`: use `md5` or `scram-sha-256` password auth according to [`pg_pwd_enc`](PARAM#pg_pwd_enc)
  - `sha`/`scram-sha-256`: enforce `scram-sha-256` password authentication
  - `md5`: `md5` password authentication
  - `ssl`: enforce host ssl in addition to `pwd` auth
  - `ssl-md5`: enforce host ssl in addition to `md5` password auth
  - `ssl-sha`: enforce host ssl in addition to `scram-sha-256` password auth
  - `os`/`ident`: use `ident` os user authentication 
  - `peer`: use `peer` authentication
  - `cert`: use certificate-based client authentication
- `user`: **who**
  - `all`: all users
  - `${dbsu}`: database superuser specified by [`pg_dbsu`](PARAM#pg_dbsu)
  - `${repl}`: replication user specified by [`pg_replication_username`](PARAM#pg_replication_username)
  - `${admin}`: admin user specified by [`pg_admin_username`](PARAM#pg_admin_username)
  - `${monitor}`: monitor user specified by [`pg_monitor_username`](PARAM#pg_monitor_username)
  - ad hoc users & roles. 
- `db`: **which**
  - `all`: all databases
  - `replication`: replication database
  - ad hoc database name




---------------------

## Reload HBA

To reload postgres/pgbouncer hba rules:

```bash
bin/pgsql-hba <cls>                 # reload hba rules of cluster `<cls>`
bin/pgsql-hba <cls> ip1 ip2...      # reload hba rules of specific instances
```

The underlying command: are:

```bash
./pgsql.yml -l <cls> -e pg_reload=true -t pg_hba
./pgsql.yml -l <cls> -e pg_reload=true -t pgbouncer_hba,pgbouncer_reload
```



---------------------

## Default HBA

Pigsty has a default set of HBA rules, which is pretty secure for most cases.

The rules are self-explained in alias form.

```yaml
pg_default_hba_rules:             # postgres default host-based authentication rules
  - {user: '${dbsu}'    ,db: all         ,addr: local     ,auth: ident ,title: 'dbsu access via local os user ident'  }
  - {user: '${dbsu}'    ,db: replication ,addr: local     ,auth: ident ,title: 'dbsu replication from local os ident' }
  - {user: '${repl}'    ,db: replication ,addr: localhost ,auth: pwd   ,title: 'replicator replication from localhost'}
  - {user: '${repl}'    ,db: replication ,addr: intra     ,auth: pwd   ,title: 'replicator replication from intranet' }
  - {user: '${repl}'    ,db: postgres    ,addr: intra     ,auth: pwd   ,title: 'replicator postgres db from intranet' }
  - {user: '${monitor}' ,db: all         ,addr: localhost ,auth: pwd   ,title: 'monitor from localhost with password' }
  - {user: '${monitor}' ,db: all         ,addr: infra     ,auth: pwd   ,title: 'monitor from infra host with password'}
  - {user: '${admin}'   ,db: all         ,addr: infra     ,auth: ssl   ,title: 'admin @ infra nodes with pwd & ssl'   }
  - {user: '${admin}'   ,db: all         ,addr: world     ,auth: cert  ,title: 'admin @ everywhere with ssl & cert'   }
  - {user: '+dbrole_readonly',db: all    ,addr: localhost ,auth: pwd   ,title: 'pgbouncer read/write via local socket'}
  - {user: '+dbrole_readonly',db: all    ,addr: intra     ,auth: pwd   ,title: 'read/write biz user via password'     }
  - {user: '+dbrole_offline' ,db: all    ,addr: intra     ,auth: pwd   ,title: 'allow etl offline tasks from intranet'}
pgb_default_hba_rules:            # pgbouncer default host-based authentication rules
  - {user: '${dbsu}'    ,db: pgbouncer   ,addr: local     ,auth: peer  ,title: 'dbsu local admin access with os ident'}
  - {user: 'all'        ,db: all         ,addr: localhost ,auth: pwd   ,title: 'allow all user local access with pwd' }
  - {user: '${monitor}' ,db: pgbouncer   ,addr: intra     ,auth: pwd   ,title: 'monitor access via intranet with pwd' }
  - {user: '${monitor}' ,db: all         ,addr: world     ,auth: deny  ,title: 'reject all other monitor access addr' }
  - {user: '${admin}'   ,db: all         ,addr: intra     ,auth: pwd   ,title: 'admin access via intranet with pwd'   }
  - {user: '${admin}'   ,db: all         ,addr: world     ,auth: deny  ,title: 'reject all other admin access addr'   }
  - {user: 'all'        ,db: all         ,addr: intra     ,auth: pwd   ,title: 'allow all user intra access with pwd' }
```

<details><summary>Example: Rendered pg_hba.conf</summary>

```ini
#==============================================================#
# File      :   pg_hba.conf
# Desc      :   Postgres HBA Rules for pg-meta-1 [primary]
# Time      :   2023-01-11 15:19
# Host      :   pg-meta-1 @ 10.10.10.10:5432
# Path      :   /pg/data/pg_hba.conf
# Note      :   ANSIBLE MANAGED, DO NOT CHANGE!
# Author    :   Ruohang Feng (rh@vonng.com)
# License   :   AGPLv3
#==============================================================#

# addr alias
# local     : /var/run/postgresql
# admin     : 10.10.10.10
# infra     : 10.10.10.10
# intra     : 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16

# user alias
# dbsu    :  postgres
# repl    :  replicator
# monitor :  dbuser_monitor
# admin   :  dbuser_dba

# dbsu access via local os user ident [default]
local    all                postgres                              ident

# dbsu replication from local os ident [default]
local    replication        postgres                              ident

# replicator replication from localhost [default]
local    replication        replicator                            scram-sha-256
host     replication        replicator         127.0.0.1/32       scram-sha-256

# replicator replication from intranet [default]
host     replication        replicator         10.0.0.0/8         scram-sha-256
host     replication        replicator         172.16.0.0/12      scram-sha-256
host     replication        replicator         192.168.0.0/16     scram-sha-256

# replicator postgres db from intranet [default]
host     postgres           replicator         10.0.0.0/8         scram-sha-256
host     postgres           replicator         172.16.0.0/12      scram-sha-256
host     postgres           replicator         192.168.0.0/16     scram-sha-256

# monitor from localhost with password [default]
local    all                dbuser_monitor                        scram-sha-256
host     all                dbuser_monitor     127.0.0.1/32       scram-sha-256

# monitor from infra host with password [default]
host     all                dbuser_monitor     10.10.10.10/32     scram-sha-256

# admin @ infra nodes with pwd & ssl [default]
hostssl  all                dbuser_dba         10.10.10.10/32     scram-sha-256

# admin @ everywhere with ssl & cert [default]
hostssl  all                dbuser_dba         0.0.0.0/0          cert

# pgbouncer read/write via local socket [default]
local    all                +dbrole_readonly                      scram-sha-256
host     all                +dbrole_readonly   127.0.0.1/32       scram-sha-256

# read/write biz user via password [default]
host     all                +dbrole_readonly   10.0.0.0/8         scram-sha-256
host     all                +dbrole_readonly   172.16.0.0/12      scram-sha-256
host     all                +dbrole_readonly   192.168.0.0/16     scram-sha-256

# allow etl offline tasks from intranet [default]
host     all                +dbrole_offline    10.0.0.0/8         scram-sha-256
host     all                +dbrole_offline    172.16.0.0/12      scram-sha-256
host     all                +dbrole_offline    192.168.0.0/16     scram-sha-256

# allow application database intranet access [common] [DISABLED]
#host    kong            dbuser_kong         10.0.0.0/8          md5
#host    bytebase        dbuser_bytebase     10.0.0.0/8          md5
#host    grafana         dbuser_grafana      10.0.0.0/8          md5

```

</details>





<details><summary>Example: Rendered pgb_hba.conf</summary>

```ini
#==============================================================#
# File      :   pgb_hba.conf
# Desc      :   Pgbouncer HBA Rules for pg-meta-1 [primary]
# Time      :   2023-01-11 15:28
# Host      :   pg-meta-1 @ 10.10.10.10:5432
# Path      :   /etc/pgbouncer/pgb_hba.conf
# Note      :   ANSIBLE MANAGED, DO NOT CHANGE!
# Author    :   Ruohang Feng (rh@vonng.com)
# License   :   AGPLv3
#==============================================================#

# PGBOUNCER HBA RULES FOR pg-meta-1 @ 10.10.10.10:6432
# ansible managed: 2023-01-11 14:30:58

# addr alias
# local     : /var/run/postgresql
# admin     : 10.10.10.10
# infra     : 10.10.10.10
# intra     : 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16

# user alias
# dbsu    :  postgres
# repl    :  replicator
# monitor :  dbuser_monitor
# admin   :  dbuser_dba

# dbsu local admin access with os ident [default]
local    pgbouncer          postgres                              peer

# allow all user local access with pwd [default]
local    all                all                                   scram-sha-256
host     all                all                127.0.0.1/32       scram-sha-256

# monitor access via intranet with pwd [default]
host     pgbouncer          dbuser_monitor     10.0.0.0/8         scram-sha-256
host     pgbouncer          dbuser_monitor     172.16.0.0/12      scram-sha-256
host     pgbouncer          dbuser_monitor     192.168.0.0/16     scram-sha-256

# reject all other monitor access addr [default]
host     all                dbuser_monitor     0.0.0.0/0          reject

# admin access via intranet with pwd [default]
host     all                dbuser_dba         10.0.0.0/8         scram-sha-256
host     all                dbuser_dba         172.16.0.0/12      scram-sha-256
host     all                dbuser_dba         192.168.0.0/16     scram-sha-256

# reject all other admin access addr [default]
host     all                dbuser_dba         0.0.0.0/0          reject

# allow all user intra access with pwd [default]
host     all                all                10.0.0.0/8         scram-sha-256
host     all                all                172.16.0.0/12      scram-sha-256
host     all                all                192.168.0.0/16     scram-sha-256
```

</details>






---------------------

## Security Enhancement

For those critical cases, we have a [security.yml](https://github.com/Vonng/pigsty/blob/master/files/pigsty/security.yml) template with the following hba rule set as a reference:

```yaml
pg_default_hba_rules:             # postgres host-based auth rules by default
  - {user: '${dbsu}'    ,db: all         ,addr: local     ,auth: ident ,title: 'dbsu access via local os user ident'  }
  - {user: '${dbsu}'    ,db: replication ,addr: local     ,auth: ident ,title: 'dbsu replication from local os ident' }
  - {user: '${repl}'    ,db: replication ,addr: localhost ,auth: ssl   ,title: 'replicator replication from localhost'}
  - {user: '${repl}'    ,db: replication ,addr: intra     ,auth: ssl   ,title: 'replicator replication from intranet' }
  - {user: '${repl}'    ,db: postgres    ,addr: intra     ,auth: ssl   ,title: 'replicator postgres db from intranet' }
  - {user: '${monitor}' ,db: all         ,addr: localhost ,auth: pwd   ,title: 'monitor from localhost with password' }
  - {user: '${monitor}' ,db: all         ,addr: infra     ,auth: ssl   ,title: 'monitor from infra host with password'}
  - {user: '${admin}'   ,db: all         ,addr: infra     ,auth: ssl   ,title: 'admin @ infra nodes with pwd & ssl'   }
  - {user: '${admin}'   ,db: all         ,addr: world     ,auth: cert  ,title: 'admin @ everywhere with ssl & cert'   }
  - {user: '+dbrole_readonly',db: all    ,addr: localhost ,auth: ssl   ,title: 'pgbouncer read/write via local socket'}
  - {user: '+dbrole_readonly',db: all    ,addr: intra     ,auth: ssl   ,title: 'read/write biz user via password'     }
  - {user: '+dbrole_offline' ,db: all    ,addr: intra     ,auth: ssl   ,title: 'allow etl offline tasks from intranet'}
pgb_default_hba_rules:            # pgbouncer host-based authentication rules
  - {user: '${dbsu}'    ,db: pgbouncer   ,addr: local     ,auth: peer  ,title: 'dbsu local admin access with os ident'}
  - {user: 'all'        ,db: all         ,addr: localhost ,auth: pwd   ,title: 'allow all user local access with pwd' }
  - {user: '${monitor}' ,db: pgbouncer   ,addr: intra     ,auth: ssl   ,title: 'monitor access via intranet with pwd' }
  - {user: '${monitor}' ,db: all         ,addr: world     ,auth: deny  ,title: 'reject all other monitor access addr' }
  - {user: '${admin}'   ,db: all         ,addr: intra     ,auth: ssl   ,title: 'admin access via intranet with pwd'   }
  - {user: '${admin}'   ,db: all         ,addr: world     ,auth: deny  ,title: 'reject all other admin access addr'   }
  - {user: 'all'        ,db: all         ,addr: intra     ,auth: ssl   ,title: 'allow all user intra access with pwd' }
```

