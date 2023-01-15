# ETCD

> ETCD is a distributed, reliable key-value store for the most critical data of a distributed system

Pigsty use etcd as DCS: Distributed configuration storage (or distributed consensus service). Which is critical to PostgreSQL High-Availability & Auto-Failover.

You have to install [`ETCD`](ETCD) module before installing any [`PGSQL`](PGSQL) modules, since patroni & vip-manager will use etcd as DCS. You have to install it after [`NODE`](NODE) module is installed, because etcd require the trusted CA to work.



## Playbook

There's a built-in playbook: `etcd.yml` for installing etcd cluster. But you have to define it first.

```bash
./etcd.yml    # install etcd cluster on group 'etcd'
```

Here are available sub tasks:

- `etcd_assert`   : generate minio identity
- `etcd_install`  : install etcd rpm packages
- `etcd_clean`    : cleanup existing etcd
  - `etcd_check`  : check etcd instance is running
  - `etcd_purge`  : remove running etcd instance & data
- `etcd_dir`      : create etcd data & conf dir
- `etcd_dir`     : create etcd directories
- `etcd_config`   : generate etcd config
  - `etcd_conf`   : generate etcd main config
  - `etcd_cert`   : generate etcd ssl cert
- `etcd_launch`   : launch etcd service
- `etcd_register` : register etcd to prometheus



If [`etcd_safeguard`](PARAM#etcd_safeguard) is enabled, or [`etcd_clean`](PARAM#etcd_clean) is false, the playbook will abort if any running etcd instance exists to prevent purge etcd accidently.





## Configuration

You have to define an etcd cluster before deploying it. There some [parameters](#parameters) about etcd.

It is recommending to have 3 instances at least.
Single node etcd is NOT Reliable enough for a serious production HA deployment. 


**Single Node**

Define a group `etcd` in the inventory

```yaml
# etcd cluster for ha postgres
etcd: { hosts: { 10.10.10.10: { etcd_seq: 1 } }, vars: { etcd_cluster: etcd } }
```

It will create a singleton etcd instance.

This is good enough for devbox, testing & demonstration, but not recommended in serious production environment.


**Three Nodes**

You can define etcd cluster with multiple nodes.

Remember to use odd number for cluster size.

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





## Administration


**Environment**

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

**New cluster**

```bash
./etcd.yml                # deploy etcd cluster according to the definition
```

**Destroy cluster**

```bash
./etcd.yml -t etcd_purge  # purge existing etcd cluster
```

**Remove a member**

Reference: [Remove a Member](https://etcd.io/docs/v3.5/op-guide/runtime-configuration/#remove-a-member)

**Add a member**

Reference: [Add a member](https://etcd.io/docs/v3.5/op-guide/runtime-configuration/#add-a-new-member)

Use `member add` to safely add a member. 

```bash
# run on etcd server
etcdctl member add --learner <name> <peerurl>

# promote leaner to follower after catch-up
etcdctl member promote <member_id>
```

EXAMPLE: upgrade etcd from 1 node to 2 node

```yaml
etcd:
  hosts:
    10.10.10.10: { etcd_seq: 1 }
    10.10.10.11: { etcd_seq: 2 }  # newly added host
  vars:
    etcd_cluster: etcd
```

```bash
# add new member name & peer url to existing cluster
em add etcd-2 https://10.10.10.11:2380

# setup a new member with initial-cluster-state=existing 
./etcd.yml -e etcd_init=existing -l 10.10.10.11

# update etcd server endpoint reference
./etcd.yml -t etcd_conf   # then restart
```

**Update Client Config**

You also need to update client config, if etcd cluster membership is changed.

ETCD is used by `patroni` and `vip-manager` by default

```bash
# refresh config
./pgsql.yml -t pg_conf       # re-generate patroni config
./pgsql.yml -t pg_vip_config # re-generate vip-manager config 

# reload config
ansible all -b -a 'systemctl reload patroni;'
ansible all -b -a 'systemctl reload vip-manager;'
```




## Parameters

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
