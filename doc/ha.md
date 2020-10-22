# HA Guide  [DRAFT]



## Quick Start

Use `patronictl` to trigger failover or switchover.

```bash
alias pt='patronictl -c /pg/bin/patroni.yml'
```

### Failover

```bash
# run as postgres @ any member of cluster `pg-test`
$ pt failover
Candidate ['pg-test-2', 'pg-test-3'] []: pg-test-3
Current cluster topology
+ Cluster: pg-test (6886641621295638555) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Leader  | running |  1 |           | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  1 |         0 | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Replica | running |  1 |         0 | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+
Are you sure you want to failover cluster pg-test, demoting current master pg-test-1? [y/N]: y
+ Cluster: pg-test (6886641621295638555) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Replica | running |  2 |         0 | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  2 |         0 | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Leader  | running |  2 |           | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+
```

### Switchover

```
$ pt switchover
Master [pg-test-3]: pg-test-3
Candidate ['pg-test-1', 'pg-test-2'] []: pg-test-1
When should the switchover take place (e.g. 2020-10-23T17:06 )  [now]: now
Current cluster topology
+ Cluster: pg-test (6886641621295638555) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Replica | running |  2 |         0 | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  2 |         0 | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Leader  | running |  2 |           | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+
Are you sure you want to switchover cluster pg-test, demoting current master pg-test-3? [y/N]: y
2020-10-23 16:06:11.76252 Successfully switched over to "pg-test-1"
```

### Maintenance Mode

https://patroni.readthedocs.io/en/latest/pause.html

```bash
pt pause <cluster>
```





## HA Procedure

### Failure Detection

https://patroni.readthedocs.io/en/latest/SETTINGS.html#dynamic-configuration-settings



### Fencing

#### Configure Watchdog

https://patroni.readthedocs.io/en/latest/watchdog.html

#### Bad Cases





### Traffic Routing

#### DNS

#### VIP

#### HAproxy

#### Pgbouncer

![](img/proxy.png)

