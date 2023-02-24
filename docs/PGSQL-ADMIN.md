# PGSQL Administration

> How to maintain an existing PostgreSQL cluster with Pigsty?

Here are 12 SOP for common pgsql admin tasks

- Case 1:  [Create Cluster](#create-cluster)
- Case 2:  [Create User](#create-user)
- Case 3:  [Create Database](#create-database)
- Case 4:  [Reload Service](#reload-service)
- Case 5:  [Reload HBARule](#reload-hbarule)
- Case 6:  [Config Cluster](#config-cluster)
- Case 7:  [Append Replica](#append-replica)
- Case 8:  [Remove Replica](#remove-replica)
- Case 9:  [Remove Cluster](#remove-cluster)
- Case 10: [Switchover](#switchover)
- Case 11: [Backup Cluster](#backup-cluster)
- Case 12: [Restore Cluster](#restore-cluster)


## Cheatsheet

PGSQL playbooks and shortcuts:

```bash
bin/pgsql-add   <cls>                   # create pgsql cluster <cls>
bin/pgsql-user  <cls> <username>        # create pg user <username> on <cls>
bin/pgsql-db    <cls> <dbname>          # create pg database <dbname> on <cls>
bin/pgsql-svc   <cls> [...ip]           # reload pg service of cluster <cls>
bin/pgsql-hba   <cls> [...ip]           # reload postgres/pgbouncer HBA rules of cluster <cls>
bin/pgsql-add   <cls> [...ip]           # append replicas for cluster <cls>
bin/pgsql-rm    <cls> [...ip]           # remove replicas from cluster <cls>
bin/pgsql-rm    <cls>                   # remove pgsql cluster <cls>
```

Patroni admin command and shortcuts:

```bash
pg list        <cls>                    # print cluster info
pg edit-config <cls>                    # edit cluster config 
pg reload      <cls> [ins]              # reload cluster config
pg restart     <cls> [ins]              # restart pgsql cluster
pg reinit      <cls> [ins]              # reinit cluster members
pg pause       <cls>                    # entering maintenance mode (no auto failover)
pg resume      <cls>                    # exiting maintenance mode
pg switchover  <cls>                    # switchover on cluster <cls>
pg failover    <cls>                    # failover on cluster <cls>
```

pgBackRest backup & restore command and shortcuts:

```bash
pb info                                 # print pgbackrest repo info
pg-backup                               # make a backup, incr, or full backup if necessary
pg-backup full                          # make a full backup
pg-backup diff                          # make a differential backup
pg-backup incr                          # make a incremental backup
pg-pitr -i                              # restore to the time of latest backup complete (not often used)
pg-pitr --time="2022-12-30 14:44:44+08" # restore to specific time point (in case of drop db, drop table)
pg-pitr --name="my-restore-point"       # restore TO a named restore point create by pg_create_restore_point
pg-pitr --lsn="0/7C82CB8" -X            # restore right BEFORE a LSN
pg-pitr --xid="1234567" -X -P           # restore right BEFORE a specific transaction id, then promote
pg-pitr --backup=latest                 # restore to latest backup set
pg-pitr --backup=20221108-105325        # restore to a specific backup set, which can be checked with pgbackrest info
```

Systemd components quick reference

```bash
systemctl stop patroni                  # start stop restart reload
systemctl stop pgbouncer                # start stop restart reload
systemctl stop pg_exporter              # start stop restart reload
systemctl stop pgbouncer_exporter       # start stop restart reload
systemctl stop node_exporter            # start stop restart
systemctl stop haproxy                  # start stop restart reload
systemctl stop vip-manager              # start stop restart reload
systemctl stop postgres                 # only when patroni_mode == 'remove'
```





## Create Cluster

To create a new Postgres cluster, define it in the inventory first, then init with:

```bash
bin/node-add <cls>                # init nodes for cluster <cls>           # ./node.yml  -l <cls> 
bin/pgsql-add <cls>               # init pgsql instances of cluster <cls>  # ./pgsql.yml -l <cls>
```



## Create User

To create a new business user on the existing Postgres cluster, add user definition to `all.children.<cls>.pg_users`, then create the user as follows:

```bash
bin/pgsql-user <cls> <username>   # ./pgsql-user.yml -l <cls> -e username=<username>
```




## Create Database

To create a new database user on the existing Postgres cluster, add database definition to `all.children.<cls>.pg_databases`, then create the database as follows:

```bash
bin/pgsql-db <cls> <dbname>       # ./pgsql-db.yml -l <cls> -e dbname=<dbname>
```

Note: If the database has specified an owner, the user should already exist, or you'll have to [Create User](#create-user) first.




## Reload Service

Services are exposed access point served by HAProxy.

This task is used when cluster membership has changed, e.g., [append](#append-replica)/[remove](#remove-replica) replicas, [switchover](#switchover)/failover / exposing new service or updating existing service's config (e.g., LB Weight)

To create new services or reload existing services on entire proxy cluster or specific instances:

```bash
bin/pgsql-svc <cls>               # pgsql.yml -l <cls> -t pg_service -e pg_reload=true
bin/pgsql-svc <cls> [ip...]       # pgsql.yml -l ip... -t pg_service -e pg_reload=true
```




## Reload HBARule

This task is used when your Postgres/Pgbouncer HBA rules have changed, you *may* have to reload hba to apply changes.

If you have any role-specific HBA rules, you may have to reload hba after a switchover/failover, too.

To reload postgres & pgbouncer HBA rules on entire cluster or specific instances:

```bash
bin/pgsql-hba <cls>               # pgsql.yml -l <cls> -t pg_hba,pgbouncer_hba,pgbouncer_reload -e pg_reload=true
bin/pgsql-hba <cls> [ip...]       # pgsql.yml -l ip... -t pg_hba,pgbouncer_hba,pgbouncer_reload -e pg_reload=true
```





## Config Cluster

To change the config of a existing Postgres cluster, you have to initiate control command on **admin node with admin user**:

```bash
pg edit-config <cls>              # interactive config a cluster with patronictl
```

Change patroni parameters & `postgresql.parameters`, save & apply changes with the wizard.

<details><summary>Example: Change Cluster Config with Patroni REST API</summary>

You can also use [Patroni REST API](https://patroni.readthedocs.io/en/latest/rest_api.html) to change the config in a non-interactive mode, for example:

```bash
$ curl -s 10.10.10.11:8008/config | jq .  # get current config
$ curl -u 'postgres:Patroni.API' \
        -d '{"postgresql":{"parameters": {"log_min_duration_statement":200}}}' \
        -s -X PATCH http://10.10.10.11:8008/config | jq .
```

Note: patroni unsafe RestAPI access is limit from infra/admin nodes and protected with an HTTP basic auth username/password and an optional HTTPS mode.

</details>





## Append Replica

To add a new replica to the existing Postgres cluster, you have to add its definition to the inventory: `all.children.<cls>.hosts`, then:

```bash
bin/node-add <ip>                 # init node <ip> for the new replica               
bin/pgsql-add <cls> <ip>          # init pgsql instances on <ip> for cluster <cls>  
```

It will add node `<ip>` to pigsty and init it as a replica of the cluster `<cls>`. 

Cluster services will be [reloaded](#reload-service) to adopt the new member  


<details><summary>Example: Add replica to pg-test </summary>

For example, if you want to add a `pg-test-3 / 10.10.10.13` to the existing cluster `pg-test`, you'll have to update the inventory first:

```bash
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary } # existing member
    10.10.10.12: { pg_seq: 2, pg_role: replica } # existing member
    10.10.10.13: { pg_seq: 3, pg_role: replica } # <--- new member
  vars: { pg_cluster: pg-test }
```

then apply the change as follows:

```bash
bin/node-add          10.10.10.13   # add node to pigsty
bin/pgsql-add pg-test 10.10.10.13   # init new replica on 10.10.10.13 for cluster pg-test
```

which is similar to cluster init but only works on single instance。

```bash
[ OK ] init instances  10.10.10.11 to pgsql cluster 'pg-test':
[WARN]   reminder: add nodes to pigsty, then install additional module 'pgsql'
[HINT]     $ bin/node-add  10.10.10.11  # run this ahead, except infra nodes
[WARN]   init instances from cluster:
[ OK ]     $ ./pgsql.yml -l '10.10.10.11,&pg-test'
[WARN]   reload pg_service on existing instances:
[ OK ]     $ ./pgsql.yml -l 'pg-test,!10.10.10.11' -t pg_service
```

</details>






## Remove Replica

To remove a replica from the existing PostgreSQL cluster:

```bash
bin/pgsql-rm <cls> <ip...>        # ./pgsql-rm.yml -l <ip>
```

It will remove instance `<ip>` from cluster `<cls>`.
Cluster services will be [reloaded](#reload-service) to kick the removed instance from load balancer.

<details><summary>Example: Remove replica from pg-test </summary>

For example, if you want to remove `pg-test-3 / 10.10.10.13` from the existing cluster `pg-test`:

```bash
bin/pgsql-rm pg-test 10.10.10.13  # remove pgsql instance 10.10.10.13 from pg-test
bin/node-rm  10.10.10.13          # remove that node from pigsty (optional)
vi pigsty.yml                     # remove instance definition from inventory
bin/pgsql-svc pg-test             # refresh pg_service on existing instances to kick removed instance from load balancer
```

```bash
[ OK ] remove pgsql instances from  10.10.10.13 of 'pg-test':
[WARN]   remove instances from cluster:
[ OK ]     $ ./pgsql-rm.yml -l '10.10.10.13,&pg-test'
```

And remove instance definition from the inventory:

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
    10.10.10.13: { pg_seq: 3, pg_role: replica } # <--- remove this after execution
  vars: { pg_cluster: pg-test }
```

Finally, you can update pg service and kick the removed instance from load balancer:

```bash
bin/pgsql-svc pg-test             # reload pg service on pg-test
```

</details>




## Remove Cluster

To remove the entire Postgres cluster, just run:

```bash
bin/pgsql-rm <cls>                # ./pgsql-rm.yml -l <cls>
```

<details><summary>Example: Force removing a cluster</summary>

Note: if [`pg_safeguard`](PARAM#pg_safeguard) is configured for this cluster (or globally configured to `true`), `pgsql-rm.yml` will abort to avoid removing a cluster by accident.

You can use playbook command line args to explicitly overwrite it to force the purge:

```bash
./pgsql-rm.yml -l pg-meta -e pg_safeguard=false    # force removing pg cluster pg-meta
```

</details>







## Switchover

You can perform a PostgreSQL cluster switchover with patroni cmd.

```bash
pg switchover <cls>
```

<details><summary>Example: Switchover pg-test</summary>

```bash
$ pg switchover pg-test
Master [pg-test-1]:
Candidate ['pg-test-2', 'pg-test-3'] []: pg-test-2
When should the switchover take place (e.g. 2022-12-26T07:39 )  [now]: now
Current cluster topology
+ Cluster: pg-test (7181325041648035869) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Leader  | running |  1 |           | clonefrom: true |
|           |             |         |         |    |           | conf: tiny.yml  |
|           |             |         |         |    |           | spec: 1C.2G.50G |
|           |             |         |         |    |           | version: '15'   |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-2 | 10.10.10.12 | Replica | running |  1 |         0 | clonefrom: true |
|           |             |         |         |    |           | conf: tiny.yml  |
|           |             |         |         |    |           | spec: 1C.2G.50G |
|           |             |         |         |    |           | version: '15'   |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-3 | 10.10.10.13 | Replica | running |  1 |         0 | clonefrom: true |
|           |             |         |         |    |           | conf: tiny.yml  |
|           |             |         |         |    |           | spec: 1C.2G.50G |
|           |             |         |         |    |           | version: '15'   |
+-----------+-------------+---------+---------+----+-----------+-----------------+
Are you sure you want to switchover cluster pg-test, demoting current master pg-test-1? [y/N]: y
2022-12-26 06:39:58.02468 Successfully switched over to "pg-test-2"
+ Cluster: pg-test (7181325041648035869) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Replica | stopped |    |   unknown | clonefrom: true |
|           |             |         |         |    |           | conf: tiny.yml  |
|           |             |         |         |    |           | spec: 1C.2G.50G |
|           |             |         |         |    |           | version: '15'   |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-2 | 10.10.10.12 | Leader  | running |  1 |           | clonefrom: true |
|           |             |         |         |    |           | conf: tiny.yml  |
|           |             |         |         |    |           | spec: 1C.2G.50G |
|           |             |         |         |    |           | version: '15'   |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-3 | 10.10.10.13 | Replica | running |  1 |         0 | clonefrom: true |
|           |             |         |         |    |           | conf: tiny.yml  |
|           |             |         |         |    |           | spec: 1C.2G.50G |
|           |             |         |         |    |           | version: '15'   |
+-----------+-------------+---------+---------+----+-----------+-----------------+
```

To do so with Patroni API (schedule a switchover from 2 to 1 at a specific time):

```bash
curl -u 'postgres:Patroni.API' \
  -d '{"leader":"pg-test-2", "candidate": "pg-test-1","scheduled_at":"2022-12-26T14:47+08"}' \
  -s -X POST http://10.10.10.11:8008/switchover
```


</details>





## Backup Cluster

To create a backup with pgBackRest, run as local dbsu:

```bash
pg-backup                         # make a postgres base backup
pg-backup full                    # make a full backup
pg-backup diff                    # make a differential backup
pg-backup incr                    # make a incremental backup
pb info                           # check backup information
```

Check [Backup](PGSQL-PITR) & PITR for details.

<details><summary>Example: Create routine backup crontab</summary>

You can add crontab to [`node_crontab`](PARAM#node_crontab) to specify your backup policy. 

```yaml
# make a full backup 1 am everyday
- '00 01 * * * postgres /pg/bin/pg-backup full'

# rotate backup: make a full backup on monday 1am, and an incremental backup during weekdays
- '00 01 * * 1 postgres /pg/bin/pg-backup full'
- '00 01 * * 2,3,4,5,6,7 postgres /pg/bin/pg-backup'
```

</details>



## Restore Cluster

To restore a cluster to a previous time point (PITR), run as local dbsu:

```bash
pg-pitr -i                              # restore to the time of latest backup complete (not often used)
pg-pitr --time="2022-12-30 14:44:44+08" # restore to specific time point (in case of drop db, drop table)
pg-pitr --name="my-restore-point"       # restore TO a named restore point create by pg_create_restore_point
pg-pitr --lsn="0/7C82CB8" -X            # restore right BEFORE a LSN
pg-pitr --xid="1234567" -X -P           # restore right BEFORE a specific transaction id, then promote
pg-pitr --backup=latest                 # restore to latest backup set
pg-pitr --backup=20221108-105325        # restore to a specific backup set, which can be checked with pgbackrest info
```

And follow the instructions wizard, Check Backup & [PITR](PGSQL-PITR) for details.

<details><summary>Example: PITR with raw pgBackRest Command</summary>

```bash
# restore to the latest available point (e.g. hardware failure)
pgbackrest --stanza=pg-meta restore

# PITR to specific time point (e.g. drop table by accident)
pgbackrest --stanza=pg-meta --type=time --target="2022-11-08 10:58:48" \
   --target-action=promote restore

# restore specific backup point and then promote (or pause|shutdown)
pgbackrest --stanza=pg-meta --type=immediate --target-action=promote \
  --set=20221108-105325F_20221108-105938I restore
```

</details>