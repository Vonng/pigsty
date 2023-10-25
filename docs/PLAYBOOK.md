# Playbook

> Run idempotent playbooks to install modules on nodes.

Playbooks are used in Pigsty to install [modules](ARCH#modules) on nodes.

To run playbooks, just treat them as executables. e.g. run with `./install.yml`.


----------------

## Playbooks

Here are default playbooks included in Pigsty.

| Playbook                                                                                 | Function                                                    |
|------------------------------------------------------------------------------------------|-------------------------------------------------------------|
| [`install.yml`](https://github.com/vonng/pigsty/blob/master/install.yml)                 | Install Pigsty on current node in one-pass                  |
| [`infra.yml`](https://github.com/vonng/pigsty/blob/master/infra.yml)                     | Init pigsty infrastructure on infra nodes                   |
| [`infra-rm.yml`](https://github.com/vonng/pigsty/blob/master/infra-rm.yml)               | Remove infrastructure components from infra nodes           |
| [`node.yml`](https://github.com/vonng/pigsty/blob/master/node.yml)                       | Init node for pigsty, tune node into desired status         |
| [`node-rm.yml`](https://github.com/vonng/pigsty/blob/master/node-rm.yml)                 | Remove node from pigsty                                     |
| [`pgsql.yml`](https://github.com/vonng/pigsty/blob/master/pgsql.yml)                     | Init HA PostgreSQL clusters, or adding new replicas         |
| [`pgsql-rm.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-rm.yml)               | Remove PostgreSQL cluster, or remove replicas               |
| [`pgsql-user.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-user.yml)           | Add new business user to existing PostgreSQL cluster        |
| [`pgsql-db.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-db.yml)               | Add new business database to existing PostgreSQL cluster    |
| [`pgsql-monitor.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-monitor.yml)     | Monitor remote postgres instance with local exporters       |
| [`pgsql-migration.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-migration.yml) | Generate Migration manual & scripts for existing PostgreSQL |
| [`redis.yml`](https://github.com/vonng/pigsty/blob/master/redis.yml)                     | Init redis cluster/node/instance                            |
| [`redis-rm.yml`](https://github.com/vonng/pigsty/blob/master/redis-rm.yml)               | Remove redis cluster/node/instance                          |
| [`etcd.yml`](https://github.com/vonng/pigsty/blob/master/etcd.yml)                       | Init etcd cluster (required for patroni HA DCS)             |
| [`minio.yml`](https://github.com/vonng/pigsty/blob/master/minio.yml)                     | Init minio cluster (optional for pgbackrest repo)           |
| [`cert.yml`](https://github.com/vonng/pigsty/blob/master/cert.yml)                       | Issue cert with pigsty self-signed CA (e.g. for pg clients) |
| [`docker.yml`](https://github.com/vonng/pigsty/blob/master/docker.yml)                   | Install docker on nodes                                     |
| [`mongo.yml`](https://github.com/vonng/pigsty/blob/master/mongo.yml)                     | 在节点上安装 Mongo/FerretDB                                       |


**One-Pass Install**

The special playbook `install.yml` is actually a composed playbook that install everything on current environment.

```bash

  playbook  / command / group         infra           nodes    etcd     minio     pgsql
[infra.yml] ./infra.yml [-l infra]   [+infra][+node] 
[node.yml]  ./node.yml                               [+node]  [+node]  [+node]   [+node]
[etcd.yml]  ./etcd.yml  [-l etcd ]                            [+etcd]
[minio.yml] ./minio.yml [-l minio]                                     [+minio]
[pgsql.yml] ./pgsql.yml                                                          [+pgsql]
```

Note that there's a circular dependency between [`NODE`](NODE) and [`INFRA`](INFRA):
to register a NODE to INFRA, the INFRA should already exist, while the INFRA module relies on NODE to work.

The solution is that `INFRA` playbook will also install [`NODE`](NODE) module in addition to [`INFRA`](INFRA) on infra nodes.
Make sure that infra nodes are init first. If you really want to init all nodes including infra in one-pass, `install.yml` is the way to go.



----------------

## Ansible

Playbooks require `ansible-playbook` executable to run, playbooks which is included in `ansible` package.

Pigsty will install ansible on admin node during [bootstrap](INSTALL#bootstrap).

You can install it by yourself with `yum|apt|brew` `install ansible`, it is included in default OS repo.

Knowledge about ansible is good but not required. Only three parameters needs your attention:

* `-l|--limit <pattern>` : Limit execution target on specific group/host/pattern (Where)
* `-t|--tags <tags>`: Only run tasks with specific tags (What)     
* `-e|--extra-vars <vars>`: Extra command line arguments (How) 


----------------

## Limit Host

The target of playbook can be limited with `-l|-limit <selector>`.

Missing this value could be dangerous since most playbooks will execute on `all` host, DO USE WITH CAUTION.

Here are some examples of host limit:

```bash
./pgsql.yml                 # run on all hosts (very dangerous!)
./pgsql.yml -l pg-test      # run on pg-test cluster
./pgsql.yml -l 10.10.10.10  # run on single host 10.10.10.10
./pgsql.yml -l pg-*         # run on host/group matching glob pattern `pg-*`
./pgsql.yml -l '10.10.10.11,&pg-test'     # run on 10.10.10.10 of group pg-test
/pgsql-rm.yml -l 'pg-test,!10.10.10.11'   # run on pg-test, except 10.10.10.11
./pgsql.yml -l pg-test      # Execute the pgsql playbook against the hosts in the pg-test cluster
```


----------------

## Limit Tags

You can execute a subset of playbook with `-t|--tags <tags>`.

You can specify multiple tags in comma separated list, e.g. `-t tag1,tag2`.

If specified, tasks with given tags will be executed instead of entire playbook.

Here are some examples of task limit:

```bash
./pgsql.yml -t pg_clean    # cleanup existing postgres if necessary
./pgsql.yml -t pg_dbsu     # setup os user sudo for postgres dbsu
./pgsql.yml -t pg_install  # install postgres packages & extensions
./pgsql.yml -t pg_dir      # create postgres directories and setup fhs
./pgsql.yml -t pg_util     # copy utils scripts, setup alias and env
./pgsql.yml -t patroni     # bootstrap postgres with patroni
./pgsql.yml -t pg_user     # provision postgres business users
./pgsql.yml -t pg_db       # provision postgres business databases
./pgsql.yml -t pg_backup   # init pgbackrest repo & basebackup
./pgsql.yml -t pgbouncer   # deploy a pgbouncer sidecar with postgres
./pgsql.yml -t pg_vip      # bind vip to pgsql primary with vip-manager
./pgsql.yml -t pg_dns      # register dns name to infra dnsmasq
./pgsql.yml -t pg_service  # expose pgsql service with haproxy
./pgsql.yml -t pg_exporter # expose pgsql service with haproxy
./pgsql.yml -t pg_register # register postgres to pigsty infrastructure

# run multiple tasks: reload postgres & pgbouncer hba rules
./pgsql.yml -t pg_hba,pgbouncer_hba,pgbouncer_reload

# run multiple tasks: refresh haproxy config & reload it
./node.yml -t haproxy_config,haproxy_reload
```


----------------

## Extra Vars

Extra command-line args can be passing via `-e|-extra-vars KEY=VALUE`.

It has the highest precedence over all other definition.

Here are some examples of extra vars

```bash
./node.yml -e ansible_user=admin -k -K   # run playbook as another user (with admin sudo password)
./pgsql.yml -e pg_clean=true             # force purging existing postgres when init a pgsql instance
./pgsql-rm.yml -e pg_uninstall=true      # explicitly uninstall rpm after postgres instance is removed
./redis.yml -l 10.10.10.10 -e redis_port=6379 -t redis  # init a specific redis instance: 10.10.10.11:6379
./redis-rm.yml -l 10.10.10.13 -e redis_port=6379        # remove a specific redis instance: 10.10.10.11:6379
```



Most playbooks are idempotent, meaning that some deployment playbooks may erase existing databases and create new ones without the protection option turned on.

Please read the documentation carefully, proofread the commands several times, and operate with caution. The author is not responsible for any loss of databases due to misuse.
