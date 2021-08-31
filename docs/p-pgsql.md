# PostgreSQL Initialization

> How to define and pull-up PostgreSQL Clusters ?

## Overview

After [**infra init**](p-infra.md), you can use [ `pgsql.yml`](https://github.com/Vonng/pigsty/blob/master/pgsql.yml) to init postgres on it.

First, define new database cluster on [config](c-config.md) file, then apply changes with:

```bash
./pgsql.yml                      # init all nodes in inventory (extreamly dangerous!)
./pgsql.yml -l pg-test           # init cluster `pg-test` 
./pgsql.yml -l pg-meta,pg-test   # init cluster `pg-test` and `pg-meta` simultaneously
./pgsql.yml -l 10.10.10.11       # init instance on `10.10.10.11` (which is pg-test.pg-test-1)
```

!> improper use of this playbook may lead to database deletion.
The [safe guard parameter](#safe-guard) provides control to avoid this sort of accident.
which allowing to automatically abort or skip high-risk operations when an existing running instance is detected during initialization to avoid worst-case sending. Nevertheless, when using `pgsql.yml`, double-check that the `-tags|-t` and `-limit|-l` parameters are correct. Make sure you are performing the right task on the right target. Using `-pgsql.yml` without parameters is a high-risk operation in a production environment, so think twice before you use it. **


![](_media/playbook/pgsql.svg)



## Notice

* It is strongly recommended adding the `-l` parameter to the execution to limit the scope of the objects for which the command is executed.

* **Separately** when executing initialization for a cluster slave, the user must make sure **the master has completed initialization** on their own

* When a cluster is expanded, if `Patroni` takes too long to pull up a slave, the Ansible script may abort due to a timeout. (However, the process of making the slave will continue, for example in scenarios where the slave needs to be made for more than 1 day). You can continue to perform subsequent steps from the `-Wait for patroni replica online` task via Ansible's `-start-at-task` after the slave is automatically made.


## Safe Guard

`-pgsql.yml` provides a **protection mechanism**, determined by the configuration parameter `pg_exists_action`. When there is a running instance of PostgreSQL on the target machine before executing the script, Pigsty will act according to the configuration `abort|clean|skip` of `pg_exists_action`.

* `abort`: recommended to be set as the default configuration to abort script execution if an existing instance is encountered to avoid accidental library deletion.
* `clean`: recommended to be used in local sandbox environment, to clear existing database in case of existing instances.
* `skip`: Execute subsequent logic directly on the existing database cluster.
* You can use `. /pgsql.yml -e pg_exists_action=clean` to override the configuration file option and force wipe the existing instance

The ``pg_disable_purge`'' option provides double protection; if enabled, ``pg_exists_action`'' is forced to be set to ``abort`' and will not wipe out running database instances under any circumstances.

``dcs_exists_action` and ``dcs_disable_purge` have the same effect as the above two options, but for DCS (Consul Agent) instances.



## Selective Execution

You can execute a subset of the playbook through tags.

As an example, if you want to refresh cluster service definition, run with:

```bash
./pgsql.yml --tags=service      # refresh cluster service definition
```

common subsets:

```bash
# infra init
./pgsql.yml --tags=infra        # init infra on targets

./pgsql.yml --tags=node         # perform node provision (usually not affect running instance)
./pgsql.yml --tags=dcs          # init dcs service: consul or etcd
./pgsql.yml --tags=dcs -e dcs_exists_action=clean      # init dcs with force (r)

# pgsql init
./pgsql.yml --tags=pgsql        # init pgsql part: database, monitor, and service

./pgsql.yml --tags=postgres     # install, provision, customize postgres & patroni & pgbouncer
./pgsql.yml --tags=monitor      # setup monitor system
./pgsql.yml --tags=service      # deploy haproxy & setup service access layer (Haproxy & VIP)
./pgsql.yml --tags=register     # register database cluster/instance to infrastructure
```



## Daily Operation Tasks

You can perform some daily operation with `./pgsql.yml`, such as:

```bash
. /pgsql.yml --tags=node_admin # Create admin user on the target node
# If the current administrator does not have ssh to the target node, you can use another user with ssh to create an administrator (enter the password)
. /pgsql.yml --tags=node_admin -e ansible_user=other_admin -k

. /pgsql.yml --tags=pg_scripts # Update the /pg/bin/ directory script
. /pgsql.yml --tags=pg_hba # Regenerate and apply cluster HBA rules
. /pgsql.yml --tags=pgbouncer # Reset Pgbouncer
. /pgsql.yml --tags=pg_user # Fully refresh business users
. /pgsql.yml --tags=pg_db # Full refresh of business database

. /pgsql.yml --tags=register_consul # Register the Consul service locally with the target instance (local execution)
. /pgsql.yml --tags=register_prometheus # Register monitoring objects in Prometheus (proxy to all Meta nodes for execution)
. /pgsql.yml --tags=register_grafana # Register monitoring objects in Grafana (only once)
. /pgsql.yml --tags=register_nginx # Register the load balancer with Nginx (proxy to all Meta nodes for execution)

# Redeploy monitoring using a binary install
. /pgsql.yml --tags=monitor -e exporter_install=binary

# Refresh the cluster's service definitions (performed when cluster membership or service definitions change)
. /pgsql.yml --tags=haproxy_config,haproxy_reload
```

```bash
./pgsql.yml --tags=node_admin           # create admin user on target

# If current admin does not have ssh access to remote, you can use another admin with ssh access:
./pgsql.yml --tags=node_admin -e ansible_user=other_admin -k 

./pgsql.yml --tags=pg_scripts           # update /pg/bin/ scripts
./pgsql.yml --tags=pg_hba               # render and reload pg_hba rules
./pgsql.yml --tags=pgbouncer            # reset pgbouncer
./pgsql.yml --tags=pg_user              # refresh all business users
./pgsql.yml --tags=pg_db                # refresh all business databases

./pgsql.yml --tags=register_consul      # register service to consul (on node)
./pgsql.yml --tags=register_prometheus  # register monitor target on prometheus (on meta)
./pgsql.yml --tags=register_grafana     # register postgres data source to grafana (on meta)
./pgsql.yml --tags=register_nginx       # register haproxy admin to nginx (on meta)

# update monitor exporter with binary mode
./pgsql.yml --tags=monitor -e exporter_install=binary

# refresh cluster service definition
./pgsql.yml --tags=haproxy_config,haproxy_reload
```



## Description

[`pgsql.yml`](https://github.com/Vonng/pigsty/blob/master/pgsql.yml) does the following, among others.

* Initialize the database node infrastructure (`node`)
* Initialize the DCS Agent (service (`consul`) (or DCS Server if the current node is the management node)
* Installation, deployment, and initialization of PostgreSQL, Pgbouncer, and Patroni (`postgres`)
* Installation of PostgreSQL monitoring system (`monitor`)
* Install and deploy Haproxy and VIP, and expose services to the public (`service`)
* Registering database instances to the infrastructure for supervision (`register`)

Please refer to [**task details**](#details) for the precise label of the task

```yaml
#!/usr/bin/env ansible-playbook
---
#==============================================================#
# File      :   pgsql.yml
# Mtime     :   2020-05-12
# Mtime     :   2021-03-15
# Desc      :   initialize pigsty cluster
# Path      :   pgsql.yml
# Copyright (C) 2018-2021 Ruohang Feng
#==============================================================#


#------------------------------------------------------------------------------
# init node and database
#------------------------------------------------------------------------------
- name: Pgsql Initialization
  become: yes
  hosts: all
  gather_facts: no
  roles:

    - role: node                            # init node
      tags: [infra, node]

    - role: consul                          # init consul
      tags: [infra, dcs]

    - role: postgres                        # init postgres
      tags: [pgsql, postgres]

    - role: monitor                         # init monitor system
      tags: [pgsql, monitor]

    - role: service                         # init service
      tags: [service]

...

```





## Tasks

List available tasks & tags with following commands

```bash
./pgsql.yml --list-tasks
```


<details>

```yaml
playbook: ./pgsql.yml

  play #1 (all): Infra Init	TAGS: [infra]
    tasks:
      node : Update node hostname	TAGS: [infra, node, node_name]
      node : Add new hostname to /etc/hosts	TAGS: [infra, node, node_name]
      node : Write static dns records	TAGS: [infra, node, node_dns]
      node : Get old nameservers	TAGS: [infra, node, node_resolv]
      node : Write tmp resolv file	TAGS: [infra, node, node_resolv]
      node : Write resolv options	TAGS: [infra, node, node_resolv]
      node : Write additional nameservers	TAGS: [infra, node, node_resolv]
      node : Append existing nameservers	TAGS: [infra, node, node_resolv]
      node : Swap resolv.conf	TAGS: [infra, node, node_resolv]
      node : Node configure disable firewall	TAGS: [infra, node, node_firewall]
      node : Node disable selinux by default	TAGS: [infra, node, node_firewall]
      node : Backup existing repos	TAGS: [infra, node, node_repo]
      node : Install upstream repo	TAGS: [infra, node, node_repo]
      node : Install local repo	TAGS: [infra, node, node_repo]
      node : Install node basic packages	TAGS: [infra, node, node_pkgs]
      node : Install node extra packages	TAGS: [infra, node, node_pkgs]
      node : Install meta specific packages	TAGS: [infra, node, node_pkgs]
      node : Install node basic packages	TAGS: [infra, node, node_pkgs]
      node : Install node extra packages	TAGS: [infra, node, node_pkgs]
      node : Install meta specific packages	TAGS: [infra, node, node_pkgs]
      node : Install pip3 packages on meta node	TAGS: [infra, node, node_pip, node_pkgs]
      node : Node configure disable numa	TAGS: [infra, node, node_feature]
      node : Node configure disable swap	TAGS: [infra, node, node_feature]
      node : Node configure unmount swap	TAGS: [infra, node, node_feature]
      node : Node setup static network	TAGS: [infra, node, node_feature]
      node : Node configure disable firewall	TAGS: [infra, node, node_feature]
      node : Node configure disk prefetch	TAGS: [infra, node, node_feature]
      node : Enable linux kernel modules	TAGS: [infra, node, node_kernel]
      node : Enable kernel module on reboot	TAGS: [infra, node, node_kernel]
      node : Get config parameter page count	TAGS: [infra, node, node_tuned]
      node : Get config parameter page size	TAGS: [infra, node, node_tuned]
      node : Tune shmmax and shmall via mem	TAGS: [infra, node, node_tuned]
      node : Create tuned profiles	TAGS: [infra, node, node_tuned]
      node : Render tuned profiles	TAGS: [infra, node, node_tuned]
      node : Active tuned profile	TAGS: [infra, node, node_tuned]
      node : Change additional sysctl params	TAGS: [infra, node, node_tuned]
      node : Copy default user bash profile	TAGS: [infra, node, node_profile]
      node : Setup node default pam ulimits	TAGS: [infra, node, node_ulimit]
      node : Create os user group admin	TAGS: [infra, node, node_admin]
      node : Create os user admin	TAGS: [infra, node, node_admin]
      node : Grant admin group nopass sudo	TAGS: [infra, node, node_admin]
      node : Add no host checking to ssh config	TAGS: [infra, node, node_admin]
      node : Add admin ssh no host checking	TAGS: [infra, node, node_admin]
      node : Fetch all admin public keys	TAGS: [infra, node, node_admin]
      node : Exchange all admin ssh keys	TAGS: [infra, node, node_admin]
      node : Install public keys	TAGS: [infra, node, node_admin, node_admin_pks]
      node : Install current public key	TAGS: [infra, node, node_admin, node_admin_pk_current]
      node : Install ntp package	TAGS: [infra, node, ntp_install]
      node : Install chrony package	TAGS: [infra, node, ntp_install]
      node : Setup default node timezone	TAGS: [infra, node, ntp_config]
      node : Copy the ntp.conf file	TAGS: [infra, node, ntp_config]
      node : Copy the chrony.conf template	TAGS: [infra, node, ntp_config]
      node : Launch ntpd service	TAGS: [infra, node, ntp_launch]
      node : Launch chronyd service	TAGS: [infra, node, ntp_launch]
      consul : Check for existing consul	TAGS: [consul, consul_check, dcs, infra]
      consul : Consul exists flag fact set	TAGS: [consul, consul_check, dcs, infra]
      consul : Abort due to consul exists	TAGS: [consul, consul_check, dcs, infra]
      consul : Clean existing consul instance	TAGS: [consul, consul_clean, dcs, infra]
      consul : Stop any running consul instance	TAGS: [consul, consul_clean, dcs, infra]
      consul : Remove existing consul dir	TAGS: [consul, consul_clean, dcs, infra]
      consul : Recreate consul dir	TAGS: [consul, consul_clean, dcs, infra]
      consul : Make sure consul is installed	TAGS: [consul, consul_install, dcs, infra]
      consul : Make sure consul dir exists	TAGS: [consul, consul_config, dcs, infra]
      consul : Get dcs server node names	TAGS: [consul, consul_config, dcs, infra]
      consul : Get dcs node name from var nodename	TAGS: [consul, consul_config, dcs, infra]
      consul : Get dcs node name from pgsql ins name	TAGS: [consul, consul_config, dcs, infra]
      consul : Fetch hostname as dcs node name	TAGS: [consul, consul_config, dcs, infra]
      consul : Get dcs name from hostname	TAGS: [consul, consul_config, dcs, infra]
      consul : Copy /etc/consul.d/consul.json	TAGS: [consul, consul_config, dcs, infra]
      consul : Copy consul agent service	TAGS: [consul, consul_config, dcs, infra]
      consul : Get dcs bootstrap expect quroum	TAGS: [consul, consul_server, dcs, infra]
      consul : Copy consul server service unit	TAGS: [consul, consul_server, dcs, infra]
      consul : Launch consul server service	TAGS: [consul, consul_server, dcs, infra]
      consul : Wait for consul server online	TAGS: [consul, consul_server, dcs, infra]
      consul : Launch consul agent service	TAGS: [consul, consul_agent, dcs, infra]
      consul : Wait for consul agent online	TAGS: [consul, consul_agent, dcs, infra]

  play #2 (all): Pgsql Init	TAGS: [pgsql]
    tasks:
      postgres : Create os group postgres	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Make sure dcs group exists	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Create dbsu {{ pg_dbsu }}	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Grant dbsu nopass sudo	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Grant dbsu all sudo	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Grant dbsu limited sudo	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Config watchdog onwer to dbsu	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Add dbsu ssh no host checking	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Fetch dbsu public keys	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Exchange dbsu ssh keys	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Install offical pgdg yum repo	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Install pg packages	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Install pg extensions	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Link /usr/pgsql to current version	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Add pg bin dir to profile path	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Fix directory ownership	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Remove default postgres service	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Check necessary variables exists	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Fetch variables via pg_cluster	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Set cluster basic facts for hosts	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Assert cluster primary singleton	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Setup cluster primary ip address	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Setup repl upstream for primary	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Setup repl upstream for replicas	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Debug print instance summary	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Check for existing postgres instance	TAGS: [pg_check, pgsql, postgres, prepare]
      postgres : Set fact whether pg port is open	TAGS: [pg_check, pgsql, postgres, prepare]
      postgres : Abort due to existing postgres instance	TAGS: [pg_check, pgsql, postgres, prepare]
      postgres : Clean existing postgres instance	TAGS: [pg_check, pgsql, postgres, prepare]
      postgres : Shutdown existing postgres service	TAGS: [pg_clean, pgsql, postgres, prepare]
      postgres : Remove registerd consul service	TAGS: [pg_clean, pgsql, postgres, prepare]
      postgres : Remove postgres metadata in consul	TAGS: [pg_clean, pgsql, postgres, prepare]
      postgres : Remove existing postgres data	TAGS: [pg_clean, pgsql, postgres, prepare]
      postgres : Make sure main and backup dir exists	TAGS: [pg_dir, pgsql, postgres, prepare]
      postgres : Create postgres directory structure	TAGS: [pg_dir, pgsql, postgres, prepare]
      postgres : Create pgbouncer directory structure	TAGS: [pg_dir, pgsql, postgres, prepare]
      postgres : Create links from pgbkup to pgroot	TAGS: [pg_dir, pgsql, postgres, prepare]
      postgres : Create links from current cluster	TAGS: [pg_dir, pgsql, postgres, prepare]
      postgres : Copy pg_cluster to /pg/meta/cluster	TAGS: [pg_meta, pgsql, postgres, prepare]
      postgres : Copy pg_version to /pg/meta/version	TAGS: [pg_meta, pgsql, postgres, prepare]
      postgres : Copy pg_instance to /pg/meta/instance	TAGS: [pg_meta, pgsql, postgres, prepare]
      postgres : Copy pg_seq to /pg/meta/sequence	TAGS: [pg_meta, pgsql, postgres, prepare]
      postgres : Copy pg_role to /pg/meta/role	TAGS: [pg_meta, pgsql, postgres, prepare]
      postgres : Copy postgres scripts to /pg/bin/	TAGS: [pg_scripts, pgsql, postgres, prepare]
      postgres : Copy alias profile to /etc/profile.d	TAGS: [pg_scripts, pgsql, postgres, prepare]
      postgres : Copy psqlrc to postgres home	TAGS: [pg_scripts, pgsql, postgres, prepare]
      postgres : Setup hostname to pg instance name	TAGS: [pg_hostname, pgsql, postgres, prepare]
      postgres : Copy consul node-meta definition	TAGS: [pg_nodemeta, pgsql, postgres, prepare]
      postgres : Restart consul to load new node-meta	TAGS: [pg_nodemeta, pgsql, postgres, prepare]
      postgres : Get config parameter page count	TAGS: [pg_config, pgsql, postgres]
      postgres : Get config parameter page size	TAGS: [pg_config, pgsql, postgres]
      postgres : Tune shared buffer and work mem	TAGS: [pg_config, pgsql, postgres]
      postgres : Hanlde small size mem occasion	TAGS: [pg_config, pgsql, postgres]
      postgres : Calculate postgres mem params	TAGS: [pg_config, pgsql, postgres]
      postgres : create patroni config dir	TAGS: [pg_config, pgsql, postgres]
      postgres : use predefined patroni template	TAGS: [pg_config, pgsql, postgres]
      postgres : Render default /pg/conf/patroni.yml	TAGS: [pg_config, pgsql, postgres]
      postgres : Link /pg/conf/patroni to /pg/bin/	TAGS: [pg_config, pgsql, postgres]
      postgres : Link /pg/bin/patroni.yml to /etc/patroni/	TAGS: [pg_config, pgsql, postgres]
      postgres : Config patroni watchdog support	TAGS: [pg_config, pgsql, postgres]
      postgres : Copy patroni systemd service file	TAGS: [pg_config, pgsql, postgres]
      postgres : create patroni systemd drop-in dir	TAGS: [pg_config, pgsql, postgres]
      postgres : Copy postgres systemd service file	TAGS: [pg_config, pgsql, postgres]
      postgres : Drop-In systemd config for patroni	TAGS: [pg_config, pgsql, postgres]
      postgres : Launch patroni on primary instance	TAGS: [pg_primary, pgsql, postgres]
      postgres : Wait for patroni primary online	TAGS: [pg_primary, pgsql, postgres]
      postgres : Wait for postgres primary online	TAGS: [pg_primary, pgsql, postgres]
      postgres : Check primary postgres service ready	TAGS: [pg_primary, pgsql, postgres]
      postgres : Check replication connectivity on primary	TAGS: [pg_primary, pgsql, postgres]
      postgres : Render init roles sql	TAGS: [pg_init, pg_init_role, pgsql, postgres]
      postgres : Render init template sql	TAGS: [pg_init, pg_init_tmpl, pgsql, postgres]
      postgres : Render default pg-init scripts	TAGS: [pg_init, pg_init_main, pgsql, postgres]
      postgres : Execute initialization scripts	TAGS: [pg_init, pg_init_exec, pgsql, postgres]
      postgres : Check primary instance ready	TAGS: [pg_init, pg_init_exec, pgsql, postgres]
      postgres : Add dbsu password to pgpass if exists	TAGS: [pg_pass, pgsql, postgres]
      postgres : Add system user to pgpass	TAGS: [pg_pass, pgsql, postgres]
      postgres : Check replication connectivity to primary	TAGS: [pg_replica, pgsql, postgres]
      postgres : Launch patroni on replica instances	TAGS: [pg_replica, pgsql, postgres]
      postgres : Wait for patroni replica online	TAGS: [pg_replica, pgsql, postgres]
      postgres : Wait for postgres replica online	TAGS: [pg_replica, pgsql, postgres]
      postgres : Check replica postgres service ready	TAGS: [pg_replica, pgsql, postgres]
      postgres : Render hba rules	TAGS: [pg_hba, pgsql, postgres]
      postgres : Reload hba rules	TAGS: [pg_hba, pgsql, postgres]
      postgres : Pause patroni	TAGS: [pg_patroni, pgsql, postgres]
      postgres : Stop patroni on replica instance	TAGS: [pg_patroni, pgsql, postgres]
      postgres : Stop patroni on primary instance	TAGS: [pg_patroni, pgsql, postgres]
      postgres : Launch raw postgres on primary	TAGS: [pg_patroni, pgsql, postgres]
      postgres : Launch raw postgres on replicas	TAGS: [pg_patroni, pgsql, postgres]
      postgres : Wait for postgres online	TAGS: [pg_patroni, pgsql, postgres]
      postgres : Check pgbouncer is installed	TAGS: [pgbouncer, pgbouncer_check, pgsql, postgres]
      postgres : Stop existing pgbouncer service	TAGS: [pgbouncer, pgbouncer_clean, pgsql, postgres]
      postgres : Remove existing pgbouncer dirs	TAGS: [pgbouncer, pgbouncer_clean, pgsql, postgres]
      postgres : Recreate dirs with owner postgres	TAGS: [pgbouncer, pgbouncer_clean, pgsql, postgres]
      postgres : Copy /etc/pgbouncer/pgbouncer.ini	TAGS: [pgbouncer, pgbouncer_config, pgbouncer_ini, pgsql, postgres]
      postgres : Copy /etc/pgbouncer/pgb_hba.conf	TAGS: [pgbouncer, pgbouncer_config, pgbouncer_hba, pgsql, postgres]
      postgres : Touch userlist and database list	TAGS: [pgbouncer, pgbouncer_config, pgsql, postgres]
      postgres : Add default users to pgbouncer	TAGS: [pgbouncer, pgbouncer_config, pgsql, postgres]
      postgres : Init pgbouncer business database list	TAGS: [pgbouncer, pgbouncer_config, pgbouncer_db, pgsql, postgres]
      postgres : Init pgbouncer business user list	TAGS: [pgbouncer, pgbouncer_config, pgbouncer_user, pgsql, postgres]
      postgres : Copy pgbouncer systemd service	TAGS: [pgbouncer, pgbouncer_launch, pgsql, postgres]
      postgres : Launch pgbouncer pool service	TAGS: [pgbouncer, pgbouncer_launch, pgsql, postgres]
      postgres : Wait for pgbouncer service online	TAGS: [pgbouncer, pgbouncer_launch, pgsql, postgres]
      postgres : Check pgbouncer service is ready	TAGS: [pgbouncer, pgbouncer_launch, pgsql, postgres]
      include_tasks	TAGS: [pg_user, pgsql, postgres]
      include_tasks	TAGS: [pg_db, pgsql, postgres]
      postgres : Reload pgbouncer to add db and users	TAGS: [pgbouncer_reload, pgsql, postgres]
      monitor : Install exporter yum repo	TAGS: [exporter_install, exporter_yum_install, monitor, pgsql]
      monitor : Install node_exporter and pg_exporter	TAGS: [exporter_install, exporter_yum_install, monitor, pgsql]
      monitor : Copy exporter binaries	TAGS: [exporter_binary_install, exporter_install, monitor, pgsql]
      monitor : Create /etc/pg_exporter conf dir	TAGS: [monitor, pg_exporter, pgsql]
      monitor : Copy default pg_exporter.yaml	TAGS: [monitor, pg_exporter, pgsql]
      monitor : Config /etc/default/pg_exporter	TAGS: [monitor, pg_exporter, pgsql]
      monitor : Config pg_exporter service unit	TAGS: [monitor, pg_exporter, pgsql]
      monitor : Launch pg_exporter systemd service	TAGS: [monitor, pg_exporter, pgsql]
      monitor : Wait for pg_exporter service online	TAGS: [monitor, pg_exporter, pgsql]
      monitor : Config pgbouncer_exporter opts	TAGS: [monitor, pgbouncer_exporter, pgsql]
      monitor : Config pgbouncer_exporter service	TAGS: [monitor, pgbouncer_exporter, pgsql]
      monitor : Launch pgbouncer_exporter service	TAGS: [monitor, pgbouncer_exporter, pgsql]
      monitor : Wait for pgbouncer_exporter online	TAGS: [monitor, pgbouncer_exporter, pgsql]
      monitor : Copy node_exporter systemd service	TAGS: [monitor, node_exporter, pgsql]
      monitor : Config default node_exporter options	TAGS: [monitor, node_exporter, pgsql]
      monitor : Launch node_exporter service unit	TAGS: [monitor, node_exporter, pgsql]
      monitor : Wait for node_exporter online	TAGS: [monitor, node_exporter, pgsql]
      service : Make sure haproxy is installed	TAGS: [haproxy, haproxy_install, pgsql, service]
      service : Create haproxy directory	TAGS: [haproxy, haproxy_install, pgsql, service]
      service : Copy haproxy systemd service file	TAGS: [haproxy, haproxy_install, haproxy_unit, pgsql, service]
      service : Fetch postgres cluster memberships	TAGS: [haproxy, haproxy_config, pgsql, service]
      service : Templating /etc/haproxy/haproxy.cfg	TAGS: [haproxy, haproxy_config, pgsql, service]
      service : Launch haproxy load balancer service	TAGS: [haproxy, haproxy_launch, haproxy_restart, pgsql, service]
      service : Wait for haproxy load balancer online	TAGS: [haproxy, haproxy_launch, pgsql, service]
      service : Reload haproxy load balancer service	TAGS: [haproxy, haproxy_reload, pgsql, service]
      service : Make sure vip-manager is installed	TAGS: [pgsql, service, vip, vip_l2_install]
      service : Copy vip-manager systemd service file	TAGS: [pgsql, service, vip, vip_l2_install]
      service : create vip-manager systemd drop-in dir	TAGS: [pgsql, service, vip, vip_l2_install]
      service : create vip-manager systemd drop-in file	TAGS: [pgsql, service, vip, vip_l2_install]
      service : Templating /etc/default/vip-manager.yml	TAGS: [pgsql, service, vip, vip_l2_config, vip_manager_config]
      service : Launch vip-manager	TAGS: [pgsql, service, vip, vip_l2_reload]
      service : Fetch postgres cluster memberships	TAGS: [pgsql, service, vip, vip_l4_config]
      service : Render L4 VIP configs	TAGS: [pgsql, service, vip, vip_l4_config]
      include_tasks	TAGS: [pgsql, service, vip, vip_l4_reload]
      register : Register postgres service to consul	TAGS: [pgsql, postgres, register, register_consul, register_consul_postgres]
      register : Register patroni service to consul	TAGS: [pgsql, postgres, register, register_consul, register_consul_patroni]
      register : Register pgbouncer service to consul	TAGS: [pgbouncer, pgsql, register, register_consul, register_consul_pgbouncer]
      register : Register node-exporter service to consul	TAGS: [node_exporter, pgsql, register, register_consul, register_consul_node_exporter]
      register : Register pg_exporter service to consul	TAGS: [pg_exporter, pgsql, register, register_consul, register_consul_pg_exporter]
      register : Register pgbouncer_exporter service to consul	TAGS: [pgbouncer_exporter, pgsql, register, register_consul, register_consul_pgbouncer_exporter]
      register : Register haproxy (exporter) service to consul	TAGS: [haproxy, pgsql, register, register_consul, register_consul_haproxy_exporter]
      register : Register cluster service to consul	TAGS: [haproxy, pgsql, register, register_consul, register_consul_cluster_service]
      register : Reload consul to finish register	TAGS: [pgsql, register, register_consul, register_consul_reload]
      register : Register pgsql instance as prometheus target	TAGS: [pgsql, register, register_prometheus]
      register : Render datasource definition on meta node	TAGS: [pgsql, register, register_grafana]
      register : Load grafana datasource on meta node	TAGS: [pgsql, register, register_grafana]
      register : Create haproxy config dir resource dirs on /etc/pigsty	TAGS: [pgsql, register, register_nginx]
      register : Register haproxy upstream to nginx	TAGS: [pgsql, register, register_nginx]
      register : Register haproxy url location to nginx	TAGS: [pgsql, register, register_nginx]
      register : Reload nginx to finish haproxy register	TAGS: [pgsql, register, register_nginx]

```

</details>

