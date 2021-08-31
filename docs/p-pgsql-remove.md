# Remove Cluster/Instance


## Overview

Database offline: you can **remove** an existing database cluster or instance and recycle the node: [`pgsql-remove.yml`](https://github.com/Vonng/pigsty/blob/master/pgsql-remove.yml)

`pgsql-remove.yml` is the reverse operation of [`pgsql.yml`](p-pgsql.md) and will sequentially complete

* Unregistering the database instance from the infrastructure (`register`)
* Stopping the load balancer, service component (`service`)
* Remove the monitoring system component (`monitor`)
* Remove Pgbouncer, Patroni, Postgres (`postgres`)
* DCS offline (except DCS Server) (`dcs`)
* Remove database directory (`rm_pgdata: true`)
* Remove packages (`rm_pkgs: true`)

This script has two command line options for removing database directories and packages (the default offline does not remove data and install packages)

```
rm_pgdata: false        # remove postgres data? false by default
rm_pgpkgs: false        # uninstall pg_packages? false by default
```

![](_media/playbook/pgsql-remove.svg)



## Usage

```bash
./pgsql-remove.yml -l pg-test                 # Remove cluster `pg-test`
./pgsql-remove.yml -l 10.10.10.13             # Remove instance `10.10.10.13` (of cluster `pg-test`)
```



## Description

```yaml
#!/usr/bin/env ansible-playbook
---
#==============================================================#
# File      :   pgsql-remove.yml
# Mtime     :   2020-05-12
# Mtime     :   2021-07-06
# Desc      :   remove pgsql from nodes
# Path      :   pgsql-remove.yml
# Copyright (C) 2018-2021 Ruohang Feng (rh@vonng.com)
#==============================================================#


#==============================================================#
# Playbook : Remove pgsql Cluster/Instance                     #
#==============================================================#
#  Remove cluster `pg-test`
#     pgsql-remove.yml -l pg-test
#
#  Remove instance (10.10.10.13) among cluster `pg-test`
#     pgsql-remove.yml -l 10.10.10.13
#
#  Remove postgres data along with packages
#     pgsql-remove.yml -e rm_pgdata=true -e rm_pgpkgs=true
#
#  Register cluster/instance to infrastructure
#     pgsql-remove.yml --tags=register             # prometheus, grafana, nginx
#     pgsql-remove.yml --tags=service              # haproxy, vip
#     pgsql-remove.yml --tags=monitor              # pg_exporter, pgbouncer_exporter, node_exporter, promtail
#     pgsql-remove.yml --tags=pgbouncer            # pgbouncer
#     pgsql-remove.yml --tags=postgres             # postgres
#==============================================================#

#     pgsql-remove.yml --tags=haproxy              # remove haproxy

#------------------------------------------------------------------------------
# De-Register Cluster/Instance
#------------------------------------------------------------------------------

- name: Remove pgsql
  become: yes
  hosts: all
  tags: remove
  gather_facts: no
  ignore_errors: yes
  vars:

    rm_dcs_server: true     # remove dcs server? false by default
    rm_pgdata: false        # remove postgres data? false by default
    rm_pgpkgs: false        # uninstall pg_packages? false by default

    # dcs_exists_action: clean     # abort|skip|clean if dcs server already exists
    # dcs_disable_purge: false     # set to true to disable purge functionality for good (force dcs_exists_action = abort)
    # pg_exists_action: clean      # what to do when found running postgres instance ? (clean are JUST FOR DEMO! do not use this on production)
    # pg_disable_purge: false      # set to true to disable pg purge functionality for good (force pg_exists_action = abort)

  roles:
    - role: remove

...
```



## Tasks

```bash
./pgsql-remove.yml -l pg-test 
```

!> you **MUST** sepeify `-l` to limit execution targets. Unless you really want to wipe all your databases!



## Details


```yaml
playbook: ./pgsql-remove.yml

  play #1 (all): Remove pgsql	TAGS: [remove]
    tasks:
      remove : Remove pgsql target from prometheus	TAGS: [prometheus, register, remove]
      remove : Remove grafana datasource on meta node	TAGS: [grafana, register, remove]
      remove : Remove haproxy upstream from nginx	TAGS: [nginx, register, remove]
      remove : Remove haproxy url location from nginx	TAGS: [nginx, register, remove]
      remove : Reload nginx to remove haproxy upstream	TAGS: [nginx, register, remove]
      remove : Remove cluster service from consul	TAGS: [consul_registry, haproxy, remove, service]
      remove : Remove haproxy service from consul	TAGS: [consul_registry, haproxy, remove, service]
      remove : Reload consul to dereigster haproxy	TAGS: [haproxy, remove, service]
      remove : Stop and disable haproxy load balancer	TAGS: [haproxy, remove, service]
      remove : Stop and disable vip-manager	TAGS: [remove, service, vip]
      remove : Remove pg_exporter service from consul	TAGS: [consul_registry, monitor, pg_exporter, remove]
      remove : Reload consul to dereigster pg_exporter	TAGS: [monitor, pg_exporter, remove]
      remove : Stop and disable pg_exporter service	TAGS: [monitor, pg_exporter, remove]
      remove : Remove pgbouncer_exporter service from consul	TAGS: [consul_registry, monitor, pgbouncer_exporter, remove]
      remove : Reload consul to dereigster pgbouncer_exporter	TAGS: [monitor, pgbouncer_exporter, remove]
      remove : Stop and disable pgbouncer_exporter service	TAGS: [monitor, pgbouncer_exporter, remove]
      remove : Remove node_exporter service from consul	TAGS: [consul_registry, monitor, node_exporter, remove]
      remove : Reload consul to dereigster node_exporter	TAGS: [monitor, node_exporter, remove]
      remove : Stop and disable node_exporter service	TAGS: [monitor, node_exporter, remove]
      remove : Stop and disable promtail service	TAGS: [monitor, promtail, remove]
      remove : Remove pgbouncer service from consul	TAGS: [consul_registry, pgbouncer, remove]
      remove : Reload consul to dereigster pgbouncer	TAGS: [pgbouncer, remove]
      remove : Stop and disable pgbouncer service	TAGS: [pgbouncer, remove]
      remove : Get actuall pg_role	TAGS: [postgres, remove]
      remove : Get pg_role from result	TAGS: [postgres, remove]
      remove : Set pg_role if applicable	TAGS: [postgres, remove]
      remove : Remove follower postgres service from consul	TAGS: [consul_registry, postgres, remove]
      remove : Remove follower patroni service from consul	TAGS: [consul_registry, postgres, remove]
      remove : Reload follower consul to dereigster postgres & patroni	TAGS: [postgres, remove]
      remove : Stop and disable follower patroni service	TAGS: [postgres, remove]
      remove : Stop and disable follower postgres service	TAGS: [postgres, remove]
      remove : Force follower postgres shutdown	TAGS: [postgres, remove]
      remove : Remove leader postgres service from consul	TAGS: [consul_registry, postgres, remove]
      remove : Remove leader patroni service from consul	TAGS: [consul_registry, postgres, remove]
      remove : Reload leader consul to dereigster postgres & patroni	TAGS: [postgres, remove]
      remove : Stop and disable leader patroni service	TAGS: [postgres, remove]
      remove : Stop and disable leader postgres service	TAGS: [postgres, remove]
      remove : Force leader postgres shutdown	TAGS: [postgres, remove]
      remove : Remove consul metadata about pgsql cluster	TAGS: [postgres, remove]
      remove : Avoid removing dcs servers	TAGS: [consul, dcs, remove]
      remove : Consul leave cluster	TAGS: [consul, dcs, remove]
      remove : Stop and disable consul	TAGS: [consul, dcs, remove]
      remove : Remove consul config and data	TAGS: [consul, dcs, remove]
      remove : Remove postgres data	TAGS: [pgdata, remove]
      remove : Remove pg packages	TAGS: [pgpkgs, remove]
      remove : Remove pg extensions	TAGS: [pgpkgs, remove]
```

![](_media/play/pgsql-remove.svg)









