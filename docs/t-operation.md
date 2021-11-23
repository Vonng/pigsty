# Daily Operation Commands


## Cluster/Instance Management

Cluster management is performed at the bottom through the Ansible playbook, 
and all command line and GUI tools are used to implement cluster management functions by calling these playbooks. 
Take a three-node `pg-test` cluster as an example:

```bash
# Init Cluster
./pgsql.yml -l pg-test           # init pg-test cluster on new nodes

# Init Instance (Scale up a cluster)
# You should guaranteed primary instance exists when scale a cluster
./pgsql.yml -l 10.10.10.13       # init node 10.10.10.13 of cluster pg-test

# Destroy Cluster
# Destroy non-primary instance first, then the leader
./pgsql-remove.yml -l pg-test    # destroy pg-test cluseter

# Destroy Instance (Scale down a cluster)
# Note: destroy a non-primary instance will scale-down a cluster, destroy a primary instance directly will trigger failover
./pgsql-remove.yml -l pg-test    # destroy pg-test cluster
```

## Database/user management

New [business users](c-user.md) and [business databases](c-database.md) can be created in existing databases with [`pgsql-createuser`](p-pgsql-createuser.md) and [`pgsql-createdb`](p-pgsql-createdb.md). database.md).
Business users usually refer to users used by software programs in a production environment, e.g. users who need to access the database through connection pools **must** be managed in this way. Other users can be created and managed using Pigsty or maintained by the users themselves.

```bash
# Create a user named test in the pg-test cluster
. /pgsql-createuser.yml -l pg-test -e pg_user=test

# Create a database named test in the pg-test cluster
. /pgsql-createdb.yml -l pg-test -e pg_database=test
```

The above command can be abbreviated as

```bash
bin/createuser pg-test test  # create pg user `test` on cluster `pg-test`
bin/createdb   pg-test test  # create pg database `test` on cluster `pg-test`
```

If database have an owner, please create the owner user before creating the database.



## Systemd Service

Pigsty use `systemd` to manage all components, except for PostgreSQL, It's managed by Patroni by default.
Unless [`patroni_mode`](v-pg-provision.md#patroni_mode) is set to `remove`.

```bash
systemctl stop patroni             # Stop Patroni & Postgres
systemctl stop pgbouncer           # Stop Pgbouncer 
systemctl stop pg_exporter         # Stop PG Exporter
systemctl stop pgbouncer_exporter  # Stop Pgbouncer Exporter
systemctl stop node_exporter       # Stop Node Exporter
systemctl stop haproxy             # Stop Haproxy
systemctl stop vip-manager         # Stop Vip-Manager
systemctl stop consul              # Stop Consul
systemctl stop postgres            # Stop Postgres （仅当 patroni_mode = remove 时使用）
```

You can reload service configuration with `systemctl reload`

```bash
systemctl reload pgbouncer           # Reload: Pgbouncer 
systemctl reload pg_exporter         # Reload: PG Exporter
systemctl reload pgbouncer_exporter  # Reload: Pgbouncer Exporter
systemctl reload haproxy             # Reload: Haproxy
systemctl reload vip-manager         # Reload: vip-manager
systemctl reload consul              # Reload: Consul
systemctl reload postgres            # Reload: Postgres （仅当 patroni_mode = remove 时使用）
```

You can reload infrastructure config with `systemctl reload` on meta nodes:

```bash
systemctl reload nginx              # Reload Nginx （更新Haproxy管理界面索引，以及外部访问域名）
systemctl reload prometheus         # Reload Prometheus （更新预计算指标计算逻辑与告警规则）
systemctl reload alertmanager       # Reload Alertmanager
systemctl reload grafana-server     # Reload Grafana
```

DO NOT OPERATE POSTGRESQL DATA CLUSTER (`/pg/data`) DIRECTLY WITH `pg_ctl` when patroni is in charge.

You can do so after entering maintenance mode. (`pt pause`)





## Database Management

You can manage Patroni and Postgres with `patronictl`. 

Run as dbsu (`postgres` by default), and specify config path via `-c`. 

You can use the alias `pt` to invoke `patronictl`:

```bash
alias pt='patronictl -c /pg/bin/patroni.yml'
```

`pt --help` will print the help information:

```bash
Commands:
  configure    Create configuration file
  dsn          Generate a dsn for the provided member,...
  edit-config  Edit cluster configuration
  failover     Failover to a replica
  flush        Discard scheduled events
  history      Show the history of failovers/switchovers
  list         List the Patroni members for a given Patroni
  pause        Disable auto failover
  query        Query a Patroni PostgreSQL member
  reinit       Reinitialize cluster member
  reload       Reload cluster member configuration
  remove       Remove cluster from DCS
  restart      Restart cluster member
  resume       Resume auto failover
  scaffold     Create a structure for the cluster in DCS
  show-config  Show cluster configuration
  switchover   Switchover to a replica
  topology     Prints ASCII topology for given cluster
  version      Output version of patronictl command or a...
```

Common operation commands are listed below:

```bash
pt list [cluster]               # print cluster into
pt edit-config [cluster]        # edit cluster config
pt reload  [cluster] [instance] # reload cluster/instance config

pt pause  [cluster]             # Entering maintenance mode (release postgres from patroni control)
pt resume [cluster]             # Exit maintenance mode

pt failover [cluster]           # Trigger manual failover
pt switchover [cluster]         # Trigger manual switchover

pt restart [cluster] [instance] # restart cluster or instance 
pt reinit  [cluster] [instance] # re-initialize specific instance among cluster 
```

For example, If your wish to trigger failover on cluster `pg-test`:

<details>
<summary>Failover Procedure</summary>

```bash
[08-05 17:00:29] postgres@pg-meta-1:~
$ pt list
+ Cluster: pg-meta (6988886159426736948) ----+----+-----------+-----------------+-----------------+
| Member    | Host        | Role   | State   | TL | Lag in MB | Pending restart | Tags            |
+-----------+-------------+--------+---------+----+-----------+-----------------+-----------------+
| pg-meta-1 | 172.21.0.11 | Leader | running |  1 |           | *               | clonefrom: true |
+-----------+-------------+--------+---------+----+-----------+-----------------+-----------------+
 Maintenance mode: on

[08-05 17:00:30] postgres@pg-meta-1:~
$ pt list pg-test
+ Cluster: pg-test (6988888117682961035) -----+----+-----------+-----------------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Pending restart | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+-----------------+
| pg-test-1 | 172.21.0.3  | Leader  | running |  1 |           |                 | clonefrom: true |
| pg-test-2 | 172.21.0.4  | Replica | running |  1 |         0 | *               | clonefrom: true |
| pg-test-3 | 172.21.0.16 | Replica | running |  1 |         0 | *               | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+-----------------+

[08-05 17:00:34] postgres@pg-meta-1:~
$ pt failover pg-test
Candidate ['pg-test-2', 'pg-test-3'] []: pg-test-3
Current cluster topology
+ Cluster: pg-test (6988888117682961035) -----+----+-----------+-----------------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Pending restart | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+-----------------+
| pg-test-1 | 172.21.0.3  | Leader  | running |  1 |           |                 | clonefrom: true |
| pg-test-2 | 172.21.0.4  | Replica | running |  1 |         0 | *               | clonefrom: true |
| pg-test-3 | 172.21.0.16 | Replica | running |  1 |         0 | *               | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+-----------------+
Are you sure you want to failover cluster pg-test, demoting current master pg-test-1? [y/N]: y
2021-08-05 17:00:46.04144 Successfully failed over to "pg-test-3"
+ Cluster: pg-test (6988888117682961035) -----+----+-----------+-----------------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Pending restart | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+-----------------+
| pg-test-1 | 172.21.0.3  | Replica | stopped |    |   unknown |                 | clonefrom: true |
| pg-test-2 | 172.21.0.4  | Replica | running |  1 |         0 | *               | clonefrom: true |
| pg-test-3 | 172.21.0.16 | Leader  | running |  1 |           | *               | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+-----------------+

[08-05 17:00:46] postgres@pg-meta-1:~
$ pt list pg-test
+ Cluster: pg-test (6988888117682961035) -----+----+-----------+-----------------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Pending restart | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+-----------------+
| pg-test-1 | 172.21.0.3  | Replica | running |  2 |         0 | *               | clonefrom: true |
| pg-test-2 | 172.21.0.4  | Replica | running |  2 |         0 | *               | clonefrom: true |
| pg-test-3 | 172.21.0.16 | Leader  | running |  2 |           | *               | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+-----------------+
```

</details>





## Maintenance Operations

#### LB Configuration

The default HAProxy access method used by Pigsty is described here, and may differ if you are using L4 VIP or other access methods.

After cluster shrinkage, cluster load balancing redistributes traffic** immediately based on health checks**, but **does not remove configuration items** from downstream instances.
After cluster expansion, **the load balancer configuration of existing instances does not change**. That is, you can access all members of the existing cluster through the HAProxy on the new instance, but the HAProxy configuration on the old instance remains the same, so no traffic is distributed to the new instance.
In order for the cluster's existing HAProxy to distribute traffic to the new database instance, you need to update the cluster's load balancing configuration at the appropriate time: ``bash

```bash
# Complete update of the HAProxy load balancing configuration in the cluster and apply it (without disrupting existing traffic)
. /pgsql.yml -l pg-test -t haproxy_config,haproxy_reload
```

#### HBA Rules

The HBA rules used by Pigsty are defined based on **roles**, if you have customized different access control policies for the database master-slave role, you will need to re-tune the HBA rules for the instance after cluster failover.

```bash
# Re-render the PG HBA rules based on the configuration and apply
. /pgsql.yml -l pg-test -t pg_hba
```


#### Prometheus Targets

Pigsty uses static file service discovery to configure monitoring targets by default, with a configuration file for each instance, shaped like

```bash
# pg-meta-1 [primary] @ 172.21.0.11
- labels: { cls: pg-meta, ins: pg-meta-1 }
  targets: [172.21.0.11:9630, 172.21.0.11:9100, 172.21.0.11:9631, 172.21.0.11:9101]
```

This configuration file is automatically maintained during cluster/instance initialization and scaling, and you can also re-produce the target instance definition from the configuration list with the following command

```bash
# Register all instances in the pg-test cluster to Prometheus on the management node 
# /etc/prometheus/targets/pgsql/<instance>.yml
. /pgsql.yml -l pg-test -t register_prometheus

# Update the configuration for a single instance only
. /pgsql.yml -l 10.10.10.10 -t register_prometheus
```


#### Grafana Datasource

Each [business database](c-database.md) on each Postgres instance is automatically registered into Grafana when it is created, or you can register it manually using the following command

```bash
# Register all business databases on all instances in the pg-test cluster to Grafana on the management node
. /pgsql.yml -l pg-test -t register_grafana
```

