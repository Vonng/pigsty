# Database high availability scenario experiment

You can strengthen your confidence in the cluster's high availability capability through a high availability scenario experiment.

Below is a list of 24 typical high availability failure scenarios, divided into three categories: master failure, slave failure, and DCS failure, with 8 specific scenarios in each category.

All experiments assume that **high availability auto-switchover mode** is enabled, where Patroni should correctly handle master and slave failures.

|               Number               | Case Name                                                    |               Auto Mode                |  Manual switch  |
| :--------------------------------: | :----------------------------------------------------------- | :------------------------------------: | :-------------: |
|         [A](#主库故障演练)         | **Master Node Failures**                                     |                                        |                 |
|      [1A](#_1a-主库节点宕机)       | Master Node node down                                        |         **Automated Failover**         |  Manual switch  |
|  [2A](#_2a-主库postgres进程关停)   | Master Node Postgres process shutdown (`pg_ctl or kill -9`)  |         **Automated Failover**         |  Manual reboot  |
| [3A](#_3a-主库patroni进程正常关停) | The Master Node Patroni process is shut down normally (`systemctl stop patroni`) |         **Automated Failover**         |  Manual reboot  |
| [4A](#_4a-主库patroni进程异常关停) | Abnormal shutdown of the Master Node Patroni process (`kill -9`) |         **Needs confirmation**         |    No effect    |
|                 5A                 | Master Node load hit full, false death (watchdog)            |         **Needs confirmation**         |    No effect    |
|                 6A                 | Master DCS Agent is not available (`systemctl stop consul`)  |      **Cluster master demotion**       |    No effect    |
|                 7A                 | Master Node network jitter                                   |   **Automatic Failover on timeout**    | Need to observe |
|                 8A                 | Erroneous deletion of master data dir                        |         **Automatic Failover**         |  Manual switch  |
|         [B](#从库故障演练)         | **Slave bank failure (1/n , n>1)**                           |                                        |                 |
|                 1B                 | Slave Node down                                              |               No effect                |    No effect    |
|                 2B                 | Slave Node Postgres process shutdown (`pg_ctl or kill -9`)   |               No effect                |    No effect    |
|                 3B                 | Slave Slave Node process Postgres  Manual Shutdown (`pg_ctl`) |               No effect                |    No effect    |
|                 4B                 | Slave Node Patroni process exception Kill (`kill -9`)        |               No effect                |    No effect    |
|                 5B                 | Slave DCS Agent is not available (`systemctl stop consul`)   |               No effect                |    No effect    |
|                 6B                 | Slave Node Load hit full, false death                        |                Depends                 |     Depends     |
|                 7B                 | Slave Node network jitter                                    |               No effect                |    No effect    |
|                 8B                 | Boosting a slave node by mistake (`pg_ctl promte`)           |         **Automatic recovery**         | **Split Brain** |
|         [C](#dcs故障演练)          | **DCS failure**                                              |                                        |                 |
|                 1C                 | DCS Server is completely unavailable (most nodes are unavailable) | **Downgrade all cluster master nodes** |    No effect    |
|                 2C                 | DCS pass master, not slave (1 master, 1 slave)               |               No effect                |    No effect    |
|                 3C                 | DCS pass master, not slave (1 master n slave, n>1)           |               No effect                |    No effect    |
|                 4C                 | DCS pass slave, not master (1 master, 1 slave)               |               No effect                |    No effect    |
|                 5C                 | DCS pass slave, not master (1 master n slave, n>1)           |         **Automatic Failover**         |    No effect    |
|                 6C                 | DCS network jitter: simultaneous outages, <br />master and slave nodes recover simultaneously, or the master node recovers first |               No effect                |    No effect    |
|                 7C                 | DCS network jitter: simultaneous outages, <br />slave nodes recover first, master nodes recover later (1 master, 1 slave) |               No effect                |    No effect    |
|                 8C                 | DCS network jitter: simultaneous interruptions,<br />slave nodes recover first, master nodes recover later (1 master n slave, n>1) |      Automatic Failover over TTL       |    No effect    |

-----------------------



## Experiment environment description

The following is a walkthrough of a local Pigsty four-node sandbox.

**Prepare load**

In the experiment, you can use `pgbench` to generate virtual loads and observe the state of load traffic under various failures.

```bash
make test-ri     # Initialize the pgbench table in the pg-test cluster
make test-rw     # Generate pgbench write traffic
make test-ro     # Generate pgbench read-only traffic
```

If you wish to emulate other styles of traffic, you can directly adjust the load generation commands and execute them.

```bash
# 4 connections, total 64 read/write TPS
while true; do pgbench -nv -P1 -c4 --rate=64 -T10 postgres://test:test@pg-test:5433/test; done

# 8 connections, total 512 read-only TPS
while true; do pgbench -nv -P1 -c8 --select-only --rate=512 -T10 postgres://test:test@pg-test:5434/test; done
```

**Observation Status**

The [PGSQL Cluster](http://demo.pigsty.cc/d/pgsql-cluster/pgsql-cluster?orgId=1&var-cls=pg-test&var-primary=pg-test-1) panel provides important monitoring information about the `pg-test` cluster, you can review the last 5-15 minutes of metrics and set it to automatically refresh every 5 seconds.

Pigsty's monitoring metrics collection period is 10 seconds by default, while the typical time taken for Patroni master-slave switchover is usually between a few and a dozen seconds. You can use `patronictl` to obtain sub-second observation accuracy.

```bash
pg list pg-test          # View pg-test cluster status (in a separate window)
pg list pg-test -w 0.1   # View pg-test cluster status, refreshed every 0.1s
```

You can open four Terminal windows for.

* Execute administrative commands on the meta node (the command used to trigger a simulated failure)
* Initiate and observe read and write request loads (`pgbench`)
* Initiate and observe read-only request load (`pgbench --select-only`)
* Real-time access to cluster master-slave status (`pg list`)



## Master Node Failure Experiment

### 1A-Master node down

**Operating Instructions**

```bash
ssh 10.10.10.3 sudo reboot    # Reboot the pg-test-1 master node directly (VIP points to the actual master node)
```

**Operation results**

Patroni can handle the master node downtime normally, performing automatic Failover.

When the cluster is in maintenance mode, manual intervention is required (manual execution of `pg failover <cluster>`)

<details><summary>patronictl list results</summary>


```bash
# Normal: pg-test-3 is the current cluster master with a timeline of 3 (this cluster has experienced two Failovers)
+ Cluster: pg-test (7037005266924312648) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Replica | running |  3 |         0 | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  3 |         0 | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Leader  | running |  3 |           | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+

# ssh 10.10.10.13 sudo reboot reboots the node where the pg-test-3 master instance resides and the patroni of the pg-test-3 instance disappears from the cluster
# After going offline for more than TTL, the pg-test-1 instance grabs the Leader Key and becomes the new cluster leader.
+ Cluster: pg-test (7037005266924312648) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Leader  | running |  3 |           | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  3 |         0 | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+

# The pg-test-1 instance completes the Promote and becomes the new leader of the cluster, and the timeline changes to 4
+ Cluster: pg-test (7037005266924312648) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Leader  | running |  4 |           | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  3 |         0 | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+

# The pg-test-2 instance modifies its upstream to the new leader, pg-test-1, and the timeline changes from 3 to 4, entering a new era and looking at the new core.
+ Cluster: pg-test (7037005266924312648) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Leader  | running |  4 |           | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  4 |         0 | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+

# pg-test-3 finished restarting, Postgres is in a stopped state, Patroni rejoins the cluster
+ Cluster: pg-test (7037005266924312648) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Leader  | running |  4 |           | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  4 |         1 | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Replica | stopped |    |   unknown | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+

# Postgres on pg-test-3 is pulled up as a slave to synchronize data from the new master, pg-test-1.
+ Cluster: pg-test (7037005266924312648) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Leader  | running |  4 |           | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  4 |         1 | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Replica | running |  3 |        10 | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+

# pg-test-3 Catch up with the new leader, timeline goes to 4, keep up with the new leader.
+ Cluster: pg-test (7037005266924312648) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Leader  | running |  4 |           | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  4 |         1 | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Replica | running |  4 |         0 | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+
```

</details>





### 2A-Master Node Postgres process shutdown

**Operating Instructions**

Two different ways to shut down the master Postgres instance: regular `pg_ctl` and brute-force `kill -9`.

```bash
# Shut down the Postgres master process on the mater node
ssh 10.10.10.3 'sudo -iu postgres /usr/pgsql/bin/pg_ctl -D /pg/data stop'

# Query the master PID and force a Kill
ssh 10.10.10.3 'sudo kill -9 $(sudo cat /pg/data/postmaster.pid | head -n1)'
```

**Operation results**

After shutting down Postgres, Patroni tries to pull up the Postgres process again. If successful, the cluster returns to normal.

If the PostgreSQL process cannot be pulled up properly, the cluster will automatically Failover.

<details><summary>patronictl list results</summary>


```bash
# After the master node instance is forced to kill, the status is shown as crashed, and then immediately pulled back up and restored to Running
+ Cluster: pg-test (7037005266924312648) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Leader  | crashed |    |           | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  7 |         0 | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Replica | running |  7 |         0 | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+

# If the persistent Kill master causes the master to fail to pull up (status changes to start failed), then Failover will be triggered
+ Cluster: pg-test (7037005266924312648) ----------+----+-----------+-----------------+
| Member    | Host        | Role    | State        | TL | Lag in MB | Tags            |
+-----------+-------------+---------+--------------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Replica | running      | 11 |         0 | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Leader  | running      | 12 |           | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Replica | start failed |    |   unknown | clonefrom: true |
+-----------+-------------+---------+--------------+----+-----------+-----------------+
```

</details>



### 3A-Master Node Patroni process shut down normally

**Operating Instructions**

```bash
# Shut down the Postgres master process on the master node
ssh 10.10.10.3 'sudo systemctl stop patroni'
```

**Operation results**

Shutting down the master Patroni in the normal way **causes the PostgreSQL instances managed by Patroni to shut down together** and **immediately** trigger a cluster Failover.

Shutting down Patroni in maintenance mode in the normal way, shutting down Patroni does not affect the managed PostgreSQL instances, which can be used to restart Patroni to reload the config (e.g. change the DCS used).

<details><summary>patronictl list results</summary>


```bash
# Master node Patroni (pg-test-3) after shutdown
+ Cluster: pg-test (7037370797549923387) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Replica | running |  2 |         0 | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  2 |         0 | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Leader  | running |  2 |           | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+

# pg-test-3 enters the stopped state
+ Cluster: pg-test (7037370797549923387) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Replica | running |  2 |         0 | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  2 |         0 | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Replica | stopped |    |   unknown | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+

# New master node pg-test-2 When selected, the timeline goes from 2 to 3
+ Cluster: pg-test (7037370797549923387) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Replica | running |  2 |         0 | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Leader  | running |  3 |           | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Replica | stopped |    |   unknown | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+

# Another healthy slave, pg-test-1, re-follows the new master, pg-test-2, into timeline 3, and the old master, pg-test-3, disappears from the cluster after some time
+ Cluster: pg-test (7037370797549923387) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Replica | running |  3 |         0 | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Leader  | running |  3 |           | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+

# Use systemctl start patroni to pull up the old master node pg-test-3 again, and the instance automatically enters replication mode, following the new leader.
+ Cluster: pg-test (7037370797549923387) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Replica | running |  3 |         0 | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Leader  | running |  3 |           | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Replica | running |  3 |         0 | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+
```

</details>





### 4A-Master Node Patroni process abnormally shut down

!> This situation requires special attention!

If you use Kill -9 to forcibly kill the master Patroni, there is a high probability that the master Patroni will not be able to shut down the managed PostgreSQL master instances. This will cause the original master PostgreSQL instance to survive Patroni's death, while the remaining slave nodes in the cluster will hold a leadership election to elect a new master, **leading to a split brain**.

**Operating Instructions**

```bash
# Shutting down the Patroni master process on the master node
ssh 10.10.10.3 "ps aux | grep /usr/bin/patroni | grep -v grep | awk '{print $2}'"
ssh 10.10.10.3 'sudo kill -9 723'
```

**Operation results**

This operation may cause a cluster split-brain: because Patroni dies violently and has no time to kill the PostgreSQL process it manages. Instead, the other cluster members conduct a new round of elections to elect a new master node after the TTL timeout.

If you use the standard load balancing health check-based service [access](c-service#接入) mechanism, **there will be no problem** because the original master node Patroni is dead and the health check is false. The load balancer will not distribute traffic to this instance even if that master is alive. However, if you continue to write to this master by other means, **then you may have a split brain!

Patroni uses the Watchdog mechanism to underwrite this situation, which you need to use as appropriate (parameter [`patroni_watchdog_mode`](v-pgsql.md#patroni_watchdog_mode)). When watchdog is enabled, if the original master cannot shut down the PG master in time to avoid split-brain in Failover for various reasons (Patroni crash, machine load fake death, VM scheduling, PG shutdown too slow), etc., the Linux kernel module `softdog` will be used to force a shutdown to avoid split brain.

<details><summary>patronictl list results</summary>


```bash
# Use Kill-9 to force kill the main Patroni library (pg-test-2) 
+ Cluster: pg-test (7037370797549923387) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Replica | running |  3 |         0 | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Leader  | running |  3 |           | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Replica | running |  3 |         0 | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+
# Because Patroni dies, the PostgreSQL process is usually still alive and in master state
# Because Patroni died, the health check of the original master node will immediately fail, resulting in no instances of master traffic being carried and the cluster being unwritable.

# Because Patroni dies violently, it has no time to release the Leader Key in the DCS, so the above state will remain TTL for a long time.
# It is not until the Leader Lease in DCS is released due to timeout (about 15s) that the cluster realizes the master is dead and initiates a Failover
+ Cluster: pg-test (7037370797549923387) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Replica | running |  3 |         0 | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Replica | running |  3 |         0 | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+

# The cluster triggers Failover, pg-test-1 becomes the new cluster leader and starts carrying read-only traffic, and the cluster write service resumes
+ Cluster: pg-test (7037370797549923387) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Leader  | running |  4 |           | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Replica | running |  3 |         0 | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+

# Attention must be paid at this point! The original cluster master is still alive and allowing writes!!!
# If you use the standard load balancing health check based traffic distribution mechanism there will be no problem because Patroni is dead and the health check is false.
# The master is alive, but the load balancer will not distribute traffic to this instance. However, if you write directly to this master through other means, you will have a split brain!
$ psql -AXtwh 10.10.10.12 -d postgres -c 'select pg_is_in_recovery();'
t
```

</details>



**Recovering from this situation**

When Patroni dies violently, you should first manually shut down the original PostgreSQL master instance that is managed by it and still running. Then restart Patroni again and have the PostgreSQL instance pulled up by Patroni, as follows.

```bash
/usr/pgsql/bin/pg_ctl -D /pg/data stop
systemctl restart patroni
```

If not, an error may occur where Patroni does not start properly.

```bash
2021-12-03 14:16:18 +0800 INFO:  stderr=2021-12-03 14:16:18.752 HKT [7852] FATAL:  lock file "postmaster.pid" already exists
2021-12-03 14:16:18.752 HKT [7852] HINT:  Is another postmaster (PID 887) running in data directory "/pg/data"?
```



> Explanation of parameter [`patroni_watchdog_mode`](v-pgsql.md#patroni_watchdog_mode).
>
> * If mode is `required` but `/dev/watchdog` is not available, it will not affect Patroni startup, only the leadership candidacy of the current instance.
> * If the mode is the `required`, but `/dev/watchdog` is not available, then the instance cannot be a qualified master candidate, i.e., it cannot participate in Failover, even if manually forced to specify it: a `Switchover failed, details: 412, switchover is not possible possible: no good candidates have been found` error. To solve this problem, change the `patroni_watchdog` option in the `/pg/bin/patroni.yml` file to `automatic|off`.
> * If the mode is `automatic`, there is no restriction and the instance will be able to run in the master election regardless of whether `/dev/watchdog` is available or not.
> * Two conditions are required for `/dev/watchdog` to be available, the `softdog` kernel module is loaded, and `/dev/watchdog` is owned by `postgres` (dbsu).





### 5A - Master DCS Agent is not available

In this case, the Patroni on the master will demote itself to a normal slave because it cannot connect to the DCS service, but if the slave Patroni is still aware that the master is alive (e.g., streaming replication is still going on normally), it does not trigger Failover!

In this case, Pigsty's access mechanism will cause **the whole cluster to enter a masterless state and be unwritable because the original master node health check is false and requires special attention!**


In maintenance mode, no changes will occur.



### 6A-Master Node load hit full, false death

TBD

### 7A-Master Node network jitter


### 8A-Made-deletion of the master data dir



-----------------------





## Slave node failure experiment

### 1B - Slave node down

**Operating Instructions**

```bash
ssh 10.10.10.3 sudo reboot    # Reboot the pg-test-1 master node directly (VIP points to the actual master node)
```

**Operation Result**

A slave node going down will cause services such as `HAPorxy`, `Patroni`, `Postgres`, etc. on that node to become unavailable. Usually, the business side will notice a very small number of transient error reports (the connection to the failed instance will be broken), and then the other load balancers in the cluster will take this failed node off the backend list.

Note that if the cluster is a one-master-one-slave structure and the only slave is down, the offline query service may be affected (no available bearer instances).

Once the node restart is complete, the Patroni service will automatically pull up and the instance will automatically rejoin the cluster.

### 2B-Slave node Postgres process shutdown

**Operating Instructions**

Two different ways of shutting down the slave Postgres instance: regular `pg_ctl` and brute-force `kill -9`.

```bash
# Shut down the Postgres master process on the slave node
ssh 10.10.10.3 'sudo -iu postgres /usr/pgsql/bin/pg_ctl -D /pg/data stop'

# Query the slave PID and force Kill
ssh 10.10.10.3 'sudo kill -9 $(sudo cat /pg/data/postmaster.pid | head -n1)'
```

**Operation Results**

After shutting down Postgres, Patroni tries to pull up the Postgres process again. If successful, the cluster returns to normal. If the slave goes down causes the health check for that instance to be Down, the cluster's load balancer will not redistribute traffic to that instance and a small number of transient errors will be reported for application read-only requests.





### 3B-Slave node Postgres process manually shut down


### 4B-Slave Patroni process abnormally kills


### 5B-Slave DCS Agent is not available


### 6B-Slave node load hit full, fake death


### 7B-Slave network jitter


### 8B-Mislocated a slave node


-----------------------





## DCS Failure Experiment

### 1C-DCS Server is completely unavailable

**DCS is completely unavailable is an extremely serious failure that will cause all database clusters to be unwritable by default**. If you use L2 VIP access, the L2 VIP bound to the master node is also unavailable by default, which means the whole cluster may not be able to read or write! You should do your best to avoid this failure!

The good thing is that DCS itself is designed to solve this problem: it has a distributed architecture and a reliable disaster recovery mechanism that can tolerate all kinds of common hardware failures. For example, a 3-node DCS cluster allows one server to fail, while a 5-node DCS cluster allows up to two server nodes to fail at the same time.

There are a number of ways to mitigate this issue.



After shutting down Consul, **all** database cluster masters with high availability auto-switchover mode enabled to trigger the demotion logic (because the Patroni of the master are not aware of the presence of other cluster members and have to assume that the other slaves already constitute a quorum majority of the partition and are elected, thus demoting themselves as slaves to avoid split-brain)

**Operating Instructions**

Shut down the DCS Server on the meta node, at least 2 if there are 3 and at least 3 if there are 5.

```bash
systemctl stop consul
```

### Solution

1. In maintenance mode, the user loses the ability to automatically Failover, but a DCS failure will not cause the master node to be unwritable. (manual fast switchover is still possible).
2. Use more DCS instances to ensure DCS availability (DCS itself was created to solve this problem).
3. Configure a long enough timeout retry time for Patroni and set the highest response priority for DCS failures.



### 2C-DCS pass master, not a slave (1 master, 1 slave)


### 3C-DCS pass master, no slave (1 master n slave, n>1)


### 4C-DCS pass slave, not pass master (1 master, 1 slave)


### 5C-DCS pass slave, no master (1 master n slave, n>1)


### 6C-DCS network jitter: simultaneous outages, master and slave recover at the same time, or master recovers first


### 7C-DCS network jitter: simultaneous interruption, slave recovers first, master recovers later (1 master, 1 slave)


### 8C-DCS network jitter: simultaneous interruption, slave recovers first, master recovers later (1 master n slave, n>1)



