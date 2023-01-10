# Administration


## Cheatsheet

### Cluster Admin

Manage PostgreSQL clusters and instances by executing the following commands on the meta node using the admin user.

```bash
# Cluster creation/cluster expansion
. /pgsql.yml -l pg-test # Create cluster: initialize pg-test cluster on new machine
. /pgsql.yml -l 10.10.10.13 # Add instance (expansion), initialize 10.10.10.13 node in pg-test cluster

# Cluster destruction/instance destruction
. /pgsql-rm.yml -l pg-test # Cluster destruction: destroy the pg-test cluster, destroy all non-master instances first, and destroy the master instance last
. /pgsql-rm.yml -l 10.10.10.13 # Instance destruction (shrinkage): destroy the 10.10.10.13 nodes in the pg-test cluster

# Business database/user creation
. /pgsql-user.yml -l pg-test -e pg_user=test # Create a user named test in the pg-test cluster
. /pgsql-db.yml -l pg-test -e pg_database=test # Create a database named test in the pg-test cluster

# Cluster membership adjustment
. /pgsql.yml -l pg-test -t pg_hba # Adjust cluster HBA rules and apply
. /pgsql.yml -l pg-test -t haproxy_config,haproxy_reload # Adjust cluster load balancer config and apply

# Service registration information adjustment
. /pgsql.yml -l pg-test -t register_prometheus # Register the cluster as a monitoring target to the Prometheus of the meta node
. /pgsql.yml -l pg-test -t register_grafana # Register the cluster as a data source to Grafana on the meta node
```

### Patroni Admin

Pigsty uses Patroni to manage PostgreSQL instance databases by default. You need to use the `patronictl` command to manage Postgres clusters, including cluster config changes, restarts, Failover, Switchover, redoing specific instances, switching automatic/manual HA mode, etc.

Users can use `patronictl` to manage all database clusters as `postgres` on the meta node, with alias `pt` already created on all hosted machines: `alias pt='patronictl -c /pg/bin/patroni.yml'`.

The commonly used management commands are shown below. For more orders, please refer to `pg --help`.

```bash
pg list [cluster] 				# Print cluster information
pg edit-config [cluster] 		# Edit the config file for a cluster 

pg reload [cluster] [instance] 	# reload the config of a cluster or instance
pg restart [cluster] [instance] # Restart a cluster or instance 
pg reinit [cluster] [instance] 	# reset an instance in a cluster (recreate the replica)

pg pause [cluster] 				# enter maintenance mode (does not trigger automatic failover, Patroni no longer operates Postgres)
pg resume [cluster]		 		# exit maintenance mode

pg failover [cluster] 			# Manually trigger Failover for a cluster
pg switchover [cluster] 		# Manually trigger a Switchover for a cluster
```

### Component Admin

In Pigsty deployments, all components are managed by `systemd`; except for PostgreSQL, which Patroni manages. 

> Exception: exception when [`patroni_mode`](parameter.md#pgsqlpatroni_mode) is `remove`, Pigsty will use `systemd` to manage Postgres directly.

```bash
systemctl stop patroni               # Close Patroni & Postgres
systemctl stop pgbouncer             # Close Pgbouncer 
systemctl stop pg_exporter           # Close PG Exporter
systemctl stop pgbouncer_exporter    # Close Pgbouncer Exporter
systemctl stop node_exporter         # Close Node Exporter
systemctl stop haproxy               # Close Haproxy
systemctl stop vip-manager           # Close Vip-Manager
systemctl stop consul                # Close Consul
systemctl stop postgres              # Close Postgres (Use only when patroni_mode = remove)
```

The following components can be reloaded via `systemctl reload`.

```bash
systemctl reload patroni             # Overload config: Patroni
systemctl reload postgres            # Overload config: Postgres （Use only when patroni_mode = Remove ）
systemctl reload pgbouncer           # Overload config:  Pgbouncer 
systemctl reload pg_exporter         # Overload config: PG Exporter
systemctl reload pgbouncer_exporter  # Overload config:  Pgbouncer Exporter
systemctl reload haproxy             # Overload config:  Haproxy
systemctl reload vip-manager         # Overload config:  vip-manager
systemctl reload consul              # Overload config: Consul
```

The config of the infra components can also be reloaded via `systemctl reload` on the meta node.

```bash
systemctl reload nginx          # Overload config: nginx (update the index of haproxy management interface and external access domain name)
systemctl reload prometheus     # Overload config: Prometheus (update pre calculation index calculation logic and alarm rules)
systemctl reload alertmanager   # Overload config: Alertmanager
systemctl reload grafana-server # Overload config： Grafana
```

When Patroni manages Postgres, do not use `pg_ctl` to manipulate the database cluster (`/pg/data`).

After entering maintenance mode via `pg pause <cluster>`, you can manually manage the database.

### Common Tasks

```bash
./infra.yml -t environ             # Re-configure environment variables and access credentials on the meta node
./infra.yml -t repo_upstream       # Re-add the upstream repo to the meta node
./infra.yml -t repo_download       # Re-download the package on the meta node
./infra.yml -t nginx_home          # Regenerate the Nginx home page content
./infra.yml -t nginx_config,nginx_restart # Regenerate the Nginx config file and restart
./infra.yml -t prometheus_config   # Reset Prometheus config
./infra.yml -t grafana_provision   # Reset the Grafana monitoring dashboard
```

```bash
./pgsql.yml -l pg-test -t=pgsql    # Complete database deployment: database, monitoring, services
./pgsql.yml -l pg-test -t=postgres # Complete database deployment
./pgsql.yml -l pg-test -t=monitor  # Complete the monitoring deployment
./pgsql.yml -l pg-test -t=service  # Complete load balancing deployment, (Haproxy & VIP)
./pgsql.yml -l pg-test -t=register # Register the service to the infrastructure
./pgsql.yml -l pg-test -t=register # Register the service to the infrastructure
./pgsql.yml -l pg-test -t=consul   # Reset the DCS server, you need to configure the cluster to maintenance mode first
```



-----------------------

# SOP Tasks

## Case 1: Cluster Create and Expand

Cluster create/expand uses the playbook [`pgsql.yml`](p-pgsql.md#pgsql) to create a cluster using the cluster name as the execution object and to create a new instance/cluster expand using a single instance in the cluster as the execution object.

### **Cluster Creation**

```bash
./nodes.yml -l pg-test      # Initialize the machine nodes contained in pg-test
./pgsql.yml -l pg-test      # Initialize the pg-test database cluster
```

The above two playbooks can be simplified as follows.

```bash
bin/pgsql-add pg-test
```

### Cluster Expansion

Suppose you have a test cluster `pg-test` with two instances `10.10.10.11` and `10.10.10.12`, and now you expand one additional `10.10.10.13`.

**Modify config**

First, you need to modify the corresponding config in the inventory (`pigsty.yml` or CMDB). 

!> Please make sure to note that the `pg_seq` **must be unique** for each instance in the cluster.

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
    10.10.10.13: { pg_seq: 3, pg_role: replica, pg_offline_query: true } # New Forces
  vars: { pg_cluster: pg-test }
```

**Execute changes**

Then, execute the following command to complete the initialization of cluster members.

```bash
./nodes.yml -l 10.10.10.13      # Initialize the pg-test machine node 10.10.10.13
./pgsql.yml -l 10.10.10.13      # Initialize the pg-test instance pg-test-3

# The above two commands can be simplified as follows:
bin/pgsql-add 10.10.10.13
```

**Adjusting Roles**

Cluster expansion will result in changes in cluster membership. Please refer to [Case 8: Cluster Role Adjustment](#case-8-PGSQL-role-adjustment) to distribute the traffic to the new instance.

### Frequently Asked Questions

#### FAQ 1: Database and Consul already exist, execution aborted

Pigsty uses a SafeGuard to avoid accidental deletion of running instances; please use the [`pgsql-rm`](p-pgsql.md#pgsql-rm) playbook to complete the instance destruction first and then reuse the node. For an emergency overwrite installation, you can use the following parameters to force the running instance to be erased during the installation (Danger!!!)

* [`pg_clean`](parameter.md#pgsqlpg_clean) = clean
* [`pg_safeguard`](parameter.md#pgsqlpg_safeguard) = false
* [`dcs_clean`](parameter.md#pgsqlpg_clean) = clean
* [`dcs_safeguard`](parameter.md#pgsqlpg_safeguard) = false

For example: `. /pgsql.yml -l pg-test -e pg_exists_action=clean` will force an override install of the `pg-test` cluster.

When the execution of a Consul instance is aborted, you can also take the above parameters to force the running instance to be erased.


#### FAQ 2: The database is too extensive, waiting for the replica to come online timeout

When an expansion operation gets stuck at the `Wait for postgres replica online` step and aborts, it is usually because the existing database instance is too large and exceeds Ansible's timeout wait time.

If you abort with an error, the instance will continue to pull up the replica instance in the background. You can use the `pg list pg-test` command to list the current status of the cluster, and when the status of the new replica is `running`, you can use the following command to continue the Ansible Playbook from where it was aborted.

```bash
./pgsql.yml -l 10.10.10.13 --start-at-task 'Wait for postgres replica online'
```

Another way is to directly and explicitly specify subsequent tasks.

```bash
./pgsql.yml -l 10.10.10.13 -t pg_hba,pg_patroni,pgbouncer,pg_user,pg_db,monitor,service,register
```

If pulling up a new replica node is aborted due to some accident, please refer to FAQ 1.



#### FAQ 3: The cluster is in maintenance mode, and the replica is not automatically pulled up.

Solution 1: Use `pg resume pg-test` to configure the cluster in auto switchover mode and perform the replica creation operation.

Solution 2, use `pg reinit pg-test pg-test-3` to manually complete the instance initialization. This command can also be used to **redo existing instances in the cluster**.



#### FAQ 4: Cluster replica with `clonefrom` tag, but not suitable for use or pull failed due to data corruption

Find the problem machine, switch to `postgres` user, modify the patroni config file and reload it to take effect。

```bash
sudo su postgres
sed -ie 's/clonefrom: true/clonefrom: false/' /pg/bin/patroni.yml
sudo systemctl reload patroni
pg list -W # Check the cluster status and confirm that the failed instance does not have the clonefrom tag
```



#### FAQ 5: How to create a fixed admin user using an existing user

By default, the system uses `dba` as the admin user, which should be able to ssh into the remote database node and execute sudo commands password-free from the admin machine.

If the assigned machine does not have this user by default, but you have another admin user (e.g., `vagrant`) that can ssh into the remote node and execute sudo, you can run the following command to log into the remote machine using the other user and automatically create the standard admin user.

```bash
./nodes.yml -t node_admin -l pg-test -e ansible_user=vagrant -k -K
SSH password:
BECOME password[defaults to SSH password]:
```

If you specify the `-k|--ask-pass -K|--ask-become-pass` parameter, you should enter the admin user's SSH login password and sudo password before executing.

Once executed, you can log in to the target database machine from the admin user on the meta node (default `dba`) and run other playbooks.



#### FAQ 6: Cluster replica with clonefrom tag, but not usable or failed to pull due to data corruption

Find the machine in question, switch to the `postgres` user, modify the patroni config file and reload it to take effect.

```bash
sudo su postgres
sed -ie 's/clonefrom: true/clonefrom: false/' /pg/bin/patroni.yml
sudo systemctl reload patroni
pg list -W # Check the cluster status and confirm that the failed instance does not have the clonefrom tag
```





-----------------------

## Case 2: Cluster Destruction and Downsize

Cluster destruction/downsize uses a dedicated playbook [`pgsql-rm`](p-pgsql.md#pgsql-rm) that, when used against a cluster, will take the entire cluster destruction.

When used against a single instance in the cluster, the instance will be removed from the cluster.

Note that removing the cluster primary directly will cause the cluster to Failover, so please remove all replicas first when removing instances one by one.

!> Note that the `pgsql-rm` playbook is not affected by the [security insurance](p-pgsql.md#SafeGuard) parameter and will remove the database instance and the cluster directly, so please use it carefully!

### **Cluster Destruction**

```bash
# Destroy the pg-test cluster: destroy all non-primary instances first and the primary instance last
. /pgsql-rm.yml -l pg-test

# When destroying the cluster, remove the data dir and packages together
. /pgsql-rm.yml -l pg-test -e rm_pgdata=true -e rm_pgpkgs=true

# Remove the nodes contained in pg-test, optionally
. /nodes-remove.yml -l pg-test 
```

### Cluster Downsize

```bash
. /pgsql-rm.yml -l 10.10.10.13  # Instance destruction (shrinkage): destroy the 10.10.10.13 node in the pg-test cluster 
. /nodes-remove.yml -l 10.10.10.13  # Remove 10.10.10.13 nodes from Pigsty (optional)
```

**Adjustment of roles**

Note: Cluster downsizing will result in a change in cluster membership. When downsizing, the health check of this instance is false, and the traffic carried initially by this instance will be immediately transferred to other members. However, you still need to refer to the instructions in Reference [Case 8: PGSQL Role Adjustment](#case-8-PGSQL-Role-Adjustment) to completely remove this offline instance from the cluster config.

**Downline Offline Instance**

Note that in the default config, if an instance with `pg_role = offline` or `pg_offline_query = true` is taken offline, only the `primary` instance remains in the cluster. Then there will be **no instances left to carry offline read traffic.**



-----------------------



## Case 3: Cluster Config Change and Restart

### Cluster config modification

Modifying the PostgreSQL cluster config needs to be done via `pg edit-config <cluster>`, especially for the synchronous replication option `synchronous_mode`, which must be changed in the Patroni config entry (`.synchronous_mode`), not (`postgresql. parameters.synchronous_mode` and other parameters).

After the config is saved, configs that do not require a restart can take effect by confirmation.

Please note that the parameters modified by `pg edit-config` are **cluster parameters**. The config parameters in the scope of individual instances (e.g., Patroni's Clonefrom tag, etc.) need to be modified directly in the Patroni config file (`/pg/bin/patroni.yml`), and `systemctl reload patroni` to take effect.

!> Please note that HBA rules are created automatically by Pigsty. Please do not use Patroni to manage HBA rules.

### Cluster reboot

Configs that require a restart then need to schedule a database restart. Restarting the cluster can be done with the following command.

```bash
pg restart [cluster] [instance] # Restart a cluster or instance 
```

The ``pending restart`` notation is displayed in the ``pg list <cluster>` with the instances that need to be restarted to take effect.





-----------------------



## Case 4: Create PGSQL Biz User

A new [business user](c-pgdbuser.md#default-users) can be created in an existing database via [`pgsql-user.yml`](p-pgsql.md#pgsql-user).

Business users are usually those used by software programs in a production environment, and users who need to access the database through connection pools **must** be managed in this way. Other users can be created and managed using Pigsty or can be maintained and managed.

```bash
# Create a user named test in the pg-test cluster
. /pgsql-user.yml -l pg-test -e pg_user=test
```

The above command can be abbreviated as:

```bash
bin/pgsql-user pg-test test # Create a user named test in the pg-test cluster
```

If you need to create both the business user and the business database, you should usually create the business user first.

If the database is configured with an OWNER, create the corresponding OWNER user first and then make the corresponding database.





-----------------------



## Case 5: Create PGSQL BIZ DB

A new [business database](c-pgdbuser.md#default-users) can be created in an existing database cluster by [`pgsql-db.yml`](p-pgsql.md#pgsql-db).

A business database refers to a database object that is created and used by a user. If you wish to access this database through a connection pool, it must be created using the playbook provided by Pigsty to maintain the config in the connection pool consistent with PostgreSQL.

```bash
# Create a database named test in the pg-test cluster
. /pgsql-db.yml -l pg-test -e pg_database=test
```

The above command can be abbreviated as:

```bash
bin/pgsql-db pg-test test # Create a database named test in the pg-test cluster
```

If the database is configured with an OWNER, please create the corresponding OWNER user first before creating the corresponding database.



**Register the new database as a Grafana data source**

Executing the following command will register all the business databases on all instances in the `pg-test` cluster into Grafana as PostgreSQL data sources for use by the PGCAT application.

```bash
./pgsql.yml -t register_grafana -l pg-test
```



-----------------------





## Case 6: APPLY PGSQL HBA

Users can adjust the HBA config of an existing database cluster/instance via the `pg_hba` subtask of [`pgsql.yml`](p-pgsql.md#pgsql).

This task should be re-executed when the cluster undergoes Failover, Switchover, and HBA rule adjustments to adjust the cluster's IP black and white list rules to the expected behavior.

Pigsty strongly recommends using config files to automatically manage HBA rules unless you know exactly what you do.

The HBA config is generated by combining [`pg_hba_rules`](parameter.md#pgsqlpg_hba_rules) with [`pg_hba_rules_extra`](parameter.md#pgsqlpg_hba_rules_extra), both of which are arrays of rule config objects. The sample example is as follows.

```yaml
- title: allow internal infra service direct access
  role: common
  rules:
    - host putong-confluence     dbuser_confluence     10.0.0.0/8  md5
    - host putong-jira           dbuser_jira           10.0.0.0/8  md5
    - host putong-newjira        dbuser_newjira        10.0.0.0/8  md5
    - host putong-gitlab         dbuser_gitlab         10.0.0.0/8  md5
```

The following command will regenerate the HBA rule and apply it to take reloadable.

```bash
./pgsql.yml -t pg_hba -l pg-test
```

The above command can be abbreviated as follows:

```bash
bin/reloadhba pg-test
```



-----------------------





## Case 7: PGSQL LB Traffic Control

HAProxy controls the cluster traffic of PostgreSQL in Pigsty by default, and users can control the cluster traffic directly through the WebUI provided by HAProxy.



**Controlling traffic using HAProxy Admin UI**

Pigsty's HAProxy provides an Admin UI on port 9101 ([`haproxy_exporter_port`](parameter.md#pgsqlhaproxy_exporter_port) by default, which can be accessed by default via Pigsty's default domain name suffixed with the instance name (`pg_ cluster-pg_seq`) to access it. The admin UI comes with optional auth options enabled by the parameter ([`haproxy_auth_enabled`](v-pgsql#haproxy_auth_enabled)). Admin interface auth is not enabled by default, and when enabled, it is required to use the username specified by [`haproxy_admin_username`](parameter.md#pgsqlhaproxy_admin_username) and [`haproxy_admin_password`](parameter.md#pgsqlhaproxy_admin_password) with the username and password to log in.

Use your browser to access `http://pigsty/<ins>` (the domain name varies by configuration, you can also click there from the PGSQL Cluster Dashboard) to access the LB admin interface on the corresponding instance. [Sample Interface](http://home.pigsty.cc/pg-meta-1/)

Here you can control the traffic of one [service](c-service.md) per set of masses and each back-end server. For example, you can select that Server to drain the corresponding Server, set the `MAINT` state, and apply it. If you are using multiple HAProxy for load balancing simultaneously, you will need to perform this action on each LB in turn.



**Modify Cluster Configuration**

When a cluster changes its members, you should adjust the load balancing config of all cluster members at the appropriate time to faithfully reflect the cluster architecture changes, such as when a primary-replica switch occurs.

In addition, by configuring the [`pg_weight`](parameter.md#pgsqlpg_weight) parameter, you can explicitly control the percentage of load carried by each instance in the cluster. The change requires regenerating the HAProxy config file in the cluster and reloading the reload to take effect. For example, this config reduces the relative weight of instance 2 in all services from the default of 100 to 0.

```
10.10.10.11: { pg_seq: 1, pg_role: primary}
10.10.10.12: { pg_seq: 2, pg_role: replica, pg_weight: 0 }
10.10.10.13: { pg_seq: 3, pg_role: replica,  }
```

Use the following command to adjust the cluster config and take effect.

```bash
# Regenerate the HAProxy config for pg-test (but not applied)
. /pgsql.yml -l pg-test -t haproxy_config 

# Reload the HAProxy config for pg-test and enable it to take effect
. /pgsql.yml -l pg-test -t haproxy_config -e haproxy_reload=true 
```

The config and enable commands can be combined and abbreviated as follows:

```bash
bin/pgsql-svc pg-test  # Adjusting all HAPROXY for the pg-test cluster and reloading the config usually does not affect existing traffic.
```



-----------------------



## Case 8: PGSQL Role Adjustment

This describes Pigsty's default HAProxy access method, which may be different if you are using L4 VIP or other access methods.

This adjustment is required when any kind of role change occurs in the cluster. The [`pg_role`](parameter.md#pgsqlpg_role)  parameter of the cluster and instance in the inventory does not truly reflect the server state.

For example, when a cluster is scaled downsize, cluster load balancing immediately redistributes traffic **based on health checks** but **does not remove config entries** for downstream instances.

After cluster expansion, **the LB config of existing instances will not change**. You can access all current cluster members via HAProxy on the new instance. Still, the HAProxy config on the old instance remains unchanged, so no traffic is distributed to the new instance.



**1. Modify the config file pg_role**

When a primary-replica switch of the cluster has occurred, the `pg_role` of the cluster members should be adjusted according to the current actual situation.
For example, when `pg-test` has a Failover or Switchover that causes the `pg-test-3` instance to become the new primary, you should modify the role of `pg-test-3` to `primary` and configure the original primary `pg_role` to the `replica`.

Also, you should ensure that at least one instance in the cluster can be used to provide Offline services, so configure the instance parameter for `pg-test-1`: `pg_offline_query: true`.
It is highly discouraged to configure more than one Offline instance for a cluster, as slow queries and long transactions may cause online read-only traffic to suffer.

```yaml
10.10.10.11: { pg_seq: 1, pg_role: replica, pg_offline_query: true }
10.10.10.12: { pg_seq: 2, pg_role: replica }
10.10.10.13: { pg_seq: 3, pg_role: primary }
```

**2. Adjusting cluster instance HBAs**

The HBA rules that apply to different roles should also be returned when the cluster role changes.

Use the method described in [Case 6: APPLY PGSQL HBA](#case-6-APPLY-PGSQL-HBA) to adjust the cluster HBA rules

**3. Adjusting the cluster load balancing config**

HAProxy dynamically distributes request traffic based on the health check results returned by Patroni in the cluster, so node failure does not affect external requests. However, users should adjust the cluster load balancing config at the right time (e.g., after waking up in the morning). For example, take the failure out of the cluster config entirely instead of continuing to freeze in the cluster with a health check DOWN status.

Use the method described in [Case 7: PGSQL LB Traffic Control](#case-7-PGSQL-LB-Traffic-control) to tune the cluster load balancing config.

**4. Consolidation Operations**

You can use the following commands after modifying the config to complete the tuning of the cluster roles.

```bash
. /pgsql.yml -l pg-test -t pg_hba,pgbouncer_hba,pgbouncer_reload,pg_service_config,pg_service_reload
```

Or just use the equivalent abbreviated script.

```bash
bin/pgsql-hba pg-test  # Adjust cluster HBA config
bin/pgsql-svc pg-test  # Reload cluster HAProxy config
```



-----------------------





## Case 9: Monitor Targets

Pigsty manages Prometheus monitor objects by default using static file service discovery, default location: `/etc/prometheus/targets`.

Using Consul service discovery is optional, and in this mode, there is usually no need to manage monitor objects manually. When using static file service discovery, all monitor objects are automatically handled together with the execution instance when it goes online and offline: registered or logged out. However, some particular scenarios cannot be fully covered (e.g., changing cluster names).

**Adding Prometheus monitor objects manually.**

```bash
# Register all members of the pg-test cluster as prometheus monitor objects
. /pgsql.yml -t register_prometheus -l pg-test
```

PostgreSQL service discovery object definitions are stored by default in the `/etc/prometheus/targets/pgsql` dir of all managed nodes. Each instance corresponds to a yml file containing the target's label, with the port exposed by the Exporter.

```yaml
# pg-meta-1 [primary] @ 10.10.10.10
- labels: { cls: pg-meta, ins: pg-meta-1, ip: 10.10.10.10 }
  targets: [10.10.10.10:9630, 10.10.10.10:9631, 10.10.10.10:9101, 10.10.10.10:8008]
```

**Manually remove Prometheus monitor objects.**

```bash
# Remove the monitor object file
rm -rf /etc/prometheus/targets/pgsql/pg-test-*.yml
```

**Add Grafana data source manually**

```bash
# Register each database object in the pg-test cluster as a grafana data source
. /pgsql.yml -t register_grafana -l pg-test
```

**Remove Grafana data source manually**

In Grafana, click Data Source Management and manually remove it.





-----------------------





## Case 10: Cluster Switchover

For example, if you want to perform a Failover on the three-node demo cluster `pg-test`, you can execute the following command.

```
pg failover <cluster>
```

Then follow the wizard prompts to execute Failover. After cluster Failover, you should refer to the instructions in [Case 8: Cluster Role Adjustment](#case-8-PGSQL-Role-Adjustment) to fix the cluster role.

<details>
<summary>Execute Failover's operation log</summary>



```bash
[08-05 17:00:30] postgres@pg-meta-1:~
$ pg list pg-test
+ Cluster: pg-test (6988888117682961035) -----+----+-----------+-----------------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Pending restart | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+-----------------+
| pg-test-1 | 172.21.0.3  | Leader  | running |  1 |           |                 | clonefrom: true |
| pg-test-2 | 172.21.0.4  | Replica | running |  1 |         0 | *               | clonefrom: true |
| pg-test-3 | 172.21.0.16 | Replica | running |  1 |         0 | *               | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+-----------------+

[08-05 17:00:34] postgres@pg-meta-1:~
$ pg failover pg-test
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
$ pg list pg-test
+ Cluster: pg-test (6988888117682961035) -----+----+-----------+-----------------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Pending restart | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+-----------------+
| pg-test-1 | 172.21.0.3  | Replica | running |  2 |         0 | *               | clonefrom: true |
| pg-test-2 | 172.21.0.4  | Replica | running |  2 |         0 | *               | clonefrom: true |
| pg-test-3 | 172.21.0.16 | Leader  | running |  2 |           | *               | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+-----------------+
```

</details>



-----------------------





## Case 11: Reset Component

> As the saying goes, a reboot can solve 90% of the problems, while reinstallation can solve the remaining 10%.

Resetting the problem component is a simple and effective means of stopping it. Using Pigsty's initialization playbook [`infra.yml `](p-infra.md#infra) with [`pgsql.yml `](p-pgsql.md#pgsql) can reset the infra with the database cluster, but usually, we only need to use specific subtasks to reset particular components.

### Infrastructure Reset

Common infra reconfig commands include.

```bash
./infra.yml -t repo_upstream       # Re-add the upstream repo to the meta node
./infra.yml -t repo_download       # Re-download the package on the meta node
./infra.yml -t nginx_home          # Regenerate the Nginx home page content
./infra.yml -t prometheus_config   # Reset Prometheus configuration
./infra.yml -t grafana_provision   # Reset the Grafana monitoring dashboard
```

You can also forcibly reinstall these components.

```bash
./infra.yml -t nginx      # Reset Nginx
./infra.yml -t prometheus # Reset Prometheus
./infra.yml -t grafana    # Reset Grafana
./infra-jupyter.yml       # Reset Jupyterlab
./infra-pgweb.yml         # Reset PGWeb
```

In addition, you can reset specific components on the database node using the following command.

```bash
<<<<<<< HEAD
# The more commonly used, safe reset command, re-install monitoring and re-registration will not affect the service
. /pgsql.yml -l pg-test -t=monitor  # Redeploy monitoring
. /pgsql.yml -l pg-test -t=register # Re-register the service to the infrastructure (Nginx, Prometheus, Grafana, CMDB...)
. /nodes.yml -l pg-test -t=consul -e dcs_clean=clean # Reset DCS Agent in maintenance mode
=======
# The more commonly used, safe reset command, re-install monitor and re-registration will not affect the service
. /pgsql.yml -l pg-test -t=monitor  # Redeploy monitor
. /pgsql.yml -l pg-test -t=register # Re-register the service to the infra (Nginx, Prometheus, Grafana, CMDB...)
. /nodes.yml -l pg-test -t=consul -e dcs_exists_action=clean # Reset DCS Agent in maintenance mode
>>>>>>> 3a8ad098dc81da2857a34806aca8b1c9065951c6

# A slightly risky reset operation
. /pgsql.yml -l pg-test -t=service   # Redeploy load balancing, may cause service to flash off
. /pgsql.yml -l pg-test -t=pgbouncer  # Redeploy connection pooling, may cause service to flash

# Very dangerous reset task
. /pgsql.yml -l pg-test -t=postgres # Reset databases (including Patroni, Postgres, Pgbouncer)
. /pgsql.yml -l pg-test -t=pgsql    # Redo the complete database deployment: database, monitoring, services
. /nodes.yml -l pg-test -t=consul   # Reset DCS server directly when HA auto-switchover mode is enabled

# Extremely dangerous reset task
. /nodes.yml -l pg-test -t=consul -e rm_dcs_servers=true # Force wipe DCS servers, may cause all DB clusters to be unwritable
```

For example, if there is a problem with the cluster's connection pool, a default way to stop the damage is to restart or reinstall the Pgbouncer connection pool.

```bash
. /pgsql.yml -l pg-test -t=pgbouncer # reinstall the connection pool (all users and DBs will be regenerated), manually modified config will be lost
```



-----------------------





## Case 12: Switching DCS Servers

DCS (Consul/Etcd) is a very reliable service.

According to Patroni's working logic, once the cluster primary finds that the DCS server is unreachable, it will immediately follow the Fencing logic and downgrade itself to a normal replica, unable to write.

### **Maintenance Mode**

Unless the cluster is currently in "maintenance mode" (enter with `pg pause <cluster>` and exit with `pg resume <cluster>`).

```bash
# Put the target cluster into maintenance mode
pg pause pg-test

# Restore the target cluster to automatic failover mode (optional)
pg resume pg-test
```



### **Reset DCS service for PGSQL Nodes**

When DCS fails to be available, and you need to migrate to a new DCS (Consul) cluster, you can use the following actions.

First, create the new DCS cluster, then edit the inventory [``dcs_servers``](parameter.md#dcs_servers) and fill in the new DCS Servers address.

```bash
# Force reset the Consul Agent on the target cluster (since HA is in maintenance mode and will not affect the new database cluster)
. /nodes.yml -l pg-test -t consul -e dcs_clean=clean

```

When Patroni finishes restarting (in maintenance mode, Patroni restart will not cause Postgres shutdown), it will write the cluster metadata K-V to the new Consul cluster, so you must make sure the Patroni service on the original primary database finishes restarting first.

```bash
# Important! Restart Patroni on the target primary first, then restart Patroni on the remaining replica nodes
ansible pg-test-1 -b -a 'sudo systemctl reload patroni'
ansible pg-test-2,pg-test-3 -b -a 'sudo systemctl restart patroni'
```
