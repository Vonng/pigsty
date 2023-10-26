# ETCD

> ETCD is a distributed, reliable key-value store for the most critical data of a distributed system

[Configuration](#configuration) | [Administration](#administration) | [Playbook](#playbook) | [Dashboard](#dashboard) | [Parameter](#parameter)

Pigsty use  [**etcd**](https://etcd.io/) as  [**DCS**](https://patroni.readthedocs.io/en/latest/dcs_failsafe_mode.html): Distributed configuration storage (or distributed consensus service). Which is critical to PostgreSQL High-Availability & Auto-Failover.

You have to install [`ETCD`](ETCD) module before any [`PGSQL`](PGSQL) modules, since patroni & vip-manager will rely on etcd to work. Unless you are using an external etcd cluster.

You don't need [`NODE`](NODE) module to install [`ETCD`](ETCD), but it requires a valid `CA` on your local `files/pki/ca`. Check [ETCD Administration SOP](etcd#administration) for more details.



----------------

## Configuration

You have to define an etcd cluster before deploying it. There some [parameters](#parameter) about etcd.

It is recommending to have at least 3 instances for a serious production environment.

### Single Node

Define a group `etcd` in the inventory, It will create a singleton etcd instance.

```yaml
# etcd cluster for ha postgres
etcd: { hosts: { 10.10.10.10: { etcd_seq: 1 } }, vars: { etcd_cluster: etcd } }
```

This is good enough for development, testing & demonstration, but not recommended in serious production environment.


### Three Nodes

You can define etcd cluster with multiple nodes.

```yaml
etcd: # dcs service for postgres/patroni ha consensus
  hosts:  # 1 node for testing, 3 or 5 for production
    10.10.10.10: { etcd_seq: 1 }  # etcd_seq required
    10.10.10.11: { etcd_seq: 2 }  # assign from 1 ~ n
    10.10.10.12: { etcd_seq: 3 }  # odd number please
  vars: # cluster level parameter override roles/etcd
    etcd_cluster: etcd  # mark etcd cluster name etcd
    etcd_safeguard: false # safeguard against purging
    etcd_clean: true # purge etcd during init process
```

You can use more nodes for production environment, but 3 or 5 nodes are recommended. Remember to use odd number for cluster size.



----------------

## Administration

Here are some useful administration tasks for etcd:

- [Create Cluster](#create-cluster)
- [Destroy Cluster](#destroy-cluster)
- [CLI Environment](#cli-environment)
- [Reload Config](#reload-config)
- [Add Member](#add-member)
- [Remove Member](#remove-member)


----------------

### Create Cluster

If [`etcd_safeguard`](PARAM#etcd_safeguard) is `true`, or [`etcd_clean`](PARAM#etcd_clean) is `false`,
the playbook will abort if any running etcd instance exists to prevent purge etcd by accident.


```yaml
etcd:
  hosts:
    10.10.10.10: { etcd_seq: 1 }
    10.10.10.11: { etcd_seq: 2 }
    10.10.10.12: { etcd_seq: 3 }
  vars: { etcd_cluster: etcd }
```

```bash
./etcd.yml   # init etcd module on group 'etcd'
```


----------------

### Destroy Cluster

To destroy an etcd cluster, just use the `etcd_clean` subtask of `etcd.yml`, do think before you type.

```bash
./etcd.yml -t etcd_clean  # remove entire cluster, honor the etcd_safeguard
./etcd.yml -t etcd_purge  # purge with brutal force, omit the etcd_safeguard
```



----------------

### CLI Environment

Here's an example of client environment config.

Pigsty use etcd v3 API by default.

```bash
alias e="etcdctl"
alias em="etcdctl member"
export ETCDCTL_API=3
export ETCDCTL_ENDPOINTS=https://10.10.10.10:2379
export ETCDCTL_CACERT=/etc/pki/ca.crt
export ETCDCTL_CERT=/etc/etcd/server.crt
export ETCDCTL_KEY=/etc/etcd/server.key
```

**CRUD**

You can do CRUD with following commands.

```bash
e put a 10 ; e get a; e del a ; # V3 API
```


----------------

### Reload Config

If etcd cluster membership changes, we need to refresh etcd endpoints references:

* config file of existing etcd members
* etcdctl client environment variables
* patroni dcs endpoint config
* vip-manager dcs endpoint config


To refresh etcd config file `/etc/etcd/etcd.conf` on existing members:

```bash
./etcd.yml -t etcd_conf                           # refresh /etc/etcd/etcd.conf with latest status
ansible etcd -f 1 -b -a 'systemctl restart etcd'  # optional: restart etcd
```

To refresh `etcdctl` client environment variables

```bash
$ ./etcd.yml -t etcd_env                          # refresh /etc/profile.d/etcdctl.sh
```

To update etcd endpoints reference on `patroni`:

```bash
./pgsql.yml -t pg_conf                            # regenerate patroni config
ansible all -f 1 -b -a 'systemctl reload patroni' # reload patroni config
```

To update etcd endpoints reference on `vip-manager`, (optional, if you are using a L2 vip)

```bash
./pgsql.yml -t pg_vip_config                           # regenerate vip-manager config
ansible all -f 1 -b -a 'systemctl restart vip-manager' # restart vip-manager to use new config
```



----------------

### Add Member

ETCD Reference: [Add a member](https://etcd.io/docs/v3.5/op-guide/runtime-configuration/#add-a-new-member)

You can add new members to existing etcd cluster in 5 steps:

1. issue `etcdctl member add` command to tell existing cluster that a new member is coming (use learner mode)
2. update inventory group `etcd` with new instance
3. init the new member with `etcd_init=existing`, to join the existing cluster rather than create a new one (**VERY IMPORTANT**)
4. promote the new member from leaner to follower
5. update etcd endpoints reference with [reload-config](#reload-config)

**Short Version**

```bash
etcdctl member add <etcd-?> --learner=true --peer-urls=https://<new_ins_ip>:2380
./etcd.yml -l <new_ins_ip> -e etcd_init=existing
etcdctl member promote <new_ins_server_id>
```

<details><summary>Detail: Add member to etcd cluster</summary>

Here's the detail, let's start from one single etcd instance.

```yaml
etcd:
  hosts:
    10.10.10.10: { etcd_seq: 1 } # <--- this is the existing instance
    10.10.10.11: { etcd_seq: 2 } # <--- add this new member definition to inventory
  vars: { etcd_cluster: etcd }
```

Add a learner instance `etcd-2` to cluster with `etcd member add`:

```bash
# tell the existing cluster that a new member etcd-2 is coming
$ etcdctl member add etcd-2 --learner=true --peer-urls=https://10.10.10.11:2380
Member 33631ba6ced84cf8 added to cluster 6646fbcf5debc68f

ETCD_NAME="etcd-2"
ETCD_INITIAL_CLUSTER="etcd-2=https://10.10.10.11:2380,etcd-1=https://10.10.10.10:2380"
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://10.10.10.11:2380"
ETCD_INITIAL_CLUSTER_STATE="existing"
```

Check the member list with `etcdctl member list` (or `em list`), we can see an `unstarted` member:

```
33631ba6ced84cf8, unstarted, , https://10.10.10.11:2380, , true
429ee12c7fbab5c1, started, etcd-1, https://10.10.10.10:2380, https://10.10.10.10:2379, false
```

Init the new etcd instance `etcd-2` with `etcd.yml` playbook, we can see the new member is started:

```bash
$ ./etcd.yml -l 10.10.10.11 -e etcd_init=existing    # etcd_init=existing must be set
...
33631ba6ced84cf8, started, etcd-2, https://10.10.10.11:2380, https://10.10.10.11:2379, true
429ee12c7fbab5c1, started, etcd-1, https://10.10.10.10:2380, https://10.10.10.10:2379, false
```

Promote the new member, from leaner to follower:

```bash
$ etcdctl member promote 33631ba6ced84cf8   # promote the new learner
Member 33631ba6ced84cf8 promoted in cluster 6646fbcf5debc68f

$ em list                # check again, the new member is started
33631ba6ced84cf8, started, etcd-2, https://10.10.10.11:2380, https://10.10.10.11:2379, false
429ee12c7fbab5c1, started, etcd-1, https://10.10.10.10:2380, https://10.10.10.10:2379, fals
```


The new member is added, don't forget to [reload config](#reload-config).

Repeat the steps above to add more members. remember to use at least 3 members for production.

</details>


----------------

### Remove Member

To remove a member from existing etcd cluster, it usually takes 3 steps:

1. remove/uncomment it from inventory and [reload config](#reload-config)
2. remove it with `etcdctl member remove <server_id>` command and kick it out of the cluster
3. temporarily add it back to inventory and purge that instance, then remove it from inventory permanently

<details><summary>Detail: Remove member from etcd cluster</summary>

Here's the detail, let's start from a 3 instance etcd cluster:

```yaml
etcd:
  hosts:
    10.10.10.10: { etcd_seq: 1 }
    10.10.10.11: { etcd_seq: 2 }
    10.10.10.12: { etcd_seq: 3 }   # <---- comment this line, then reload-config
  vars: { etcd_cluster: etcd }
```

Then, you'll have to actually kick it from cluster with `etcdctl member remove` command:

```bash
$ etcdctl member list
429ee12c7fbab5c1, started, etcd-1, https://10.10.10.10:2380, https://10.10.10.10:2379, false
33631ba6ced84cf8, started, etcd-2, https://10.10.10.11:2380, https://10.10.10.11:2379, false
93fcf23b220473fb, started, etcd-3, https://10.10.10.12:2380, https://10.10.10.12:2379, false  # <--- remove this

$ etcdctl member remove 93fcf23b220473fb  # kick it from cluster
Member 93fcf23b220473fb removed from cluster 6646fbcf5debc68f
```

Finally, you have to shutdown the instance, and purge it from node, you have to uncomment the member in inventory temporarily, then purge it with `etcd.yml` playbook:

```bash
./etcd.yml -t etcd_purge -l 10.10.10.12   # purge it (the member is in inventory again)
```

After that, remove the member from inventory permanently, all clear!

</details>




----------------

## Playbook

There's a built-in playbook: `etcd.yml` for installing etcd cluster. But you have to [define](#configuration) it first.

```bash
./etcd.yml    # install etcd cluster on group 'etcd'
```

Here are available sub tasks:

- `etcd_assert`   : generate etcd identity
- `etcd_install`  : install etcd rpm packages
- `etcd_clean`    : cleanup existing etcd
  - `etcd_check`  : check etcd instance is running
  - `etcd_purge`  : remove running etcd instance & data
- `etcd_dir`      : create etcd data & conf dir
- `etcd_config`   : generate etcd config
  - `etcd_conf`   : generate etcd main config
  - `etcd_cert`   : generate etcd ssl cert
- `etcd_launch`   : launch etcd service
- `etcd_register` : register etcd to prometheus

If [`etcd_safeguard`](PARAM#etcd_safeguard) is `true`, or [`etcd_clean`](PARAM#etcd_clean) is `false`,
the playbook will abort if any running etcd instance exists to prevent purge etcd by accident.

[![asciicast](https://asciinema.org/a/566414.svg)](https://asciinema.org/a/566414)




----------------

## Dashboard

There is one dashboard for ETCD module:

[ETCD Overview](https://demo.pigsty.cc/d/etcd-overview): Overview of the ETCD cluster

<details><summary>ETCD Overview Dashboard</summary>

[![etcd-overview.jpg](https://repo.pigsty.cc/img/etcd-overview.jpg)](https://demo.pigsty.cc/d/etcd-overview)

</details>




----------------

## Parameter

There are 10 parameters about [`ETCD`](PARAM#etcd) module.

| Parameter                                                  |  Type  | Level | Comment                                      |
|------------------------------------------------------------|:------:|:-----:|----------------------------------------------|
| [`etcd_seq`](PARAM#etcd_seq)                               |  int   |   I   | etcd instance identifier, REQUIRED           |
| [`etcd_cluster`](PARAM#etcd_cluster)                       | string |   C   | etcd cluster & group name, etcd by default   |
| [`etcd_safeguard`](PARAM#etcd_safeguard)                   |  bool  | G/C/A | prevent purging running etcd instance?       |
| [`etcd_clean`](PARAM#etcd_clean)                           |  bool  | G/C/A | purging existing etcd during initialization? |
| [`etcd_data`](PARAM#etcd_data)                             |  path  |   C   | etcd data directory, /data/etcd by default   |
| [`etcd_port`](PARAM#etcd_port)                             |  port  |   C   | etcd client port, 2379 by default            |
| [`etcd_peer_port`](PARAM#etcd_peer_port)                   |  port  |   C   | etcd peer port, 2380 by default              |
| [`etcd_init`](PARAM#etcd_init)                             |  enum  |   C   | etcd initial cluster state, new or existing  |
| [`etcd_election_timeout`](PARAM#etcd_election_timeout)     |  int   |   C   | etcd election timeout, 1000ms by default     |
| [`etcd_heartbeat_interval`](PARAM#etcd_heartbeat_interval) |  int   |   C   | etcd heartbeat interval, 100ms by default    |
