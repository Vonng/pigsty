# ETCD

> ETCD is a distributed, reliable key-value store for the most critical data of a distributed system

Pigsty use **etcd** as **DCS**: Distributed configuration storage (or distributed consensus service). Which is critical to PostgreSQL High-Availability & Auto-Failover.

You have to install [`ETCD`](ETCD) module before any [`PGSQL`](PGSQL) modules, since patroni & vip-manager will rely on etcd to work. Unless you are using an external etcd cluster.

You have to install [`ETCD`](ETCD) after [`NODE`](NODE) module, since etcd require the trusted CA to work. Check [ETCD Administration SOP](ETCD-ADMIN) for more details. 


----------------

## Playbook

There's a built-in playbook: `etcd.yml` for installing etcd cluster. But you have to [define](#configuration) it first.

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



If [`etcd_safeguard`](PARAM#etcd_safeguard) is `true`, or [`etcd_clean`](PARAM#etcd_clean) is `false`,
the playbook will abort if any running etcd instance exists to prevent purge etcd by accident.

[![asciicast](https://asciinema.org/a/566414.svg)](https://asciinema.org/a/566414)



----------------

## Configuration

You have to define an etcd cluster before deploying it. There some [parameters](#parameters) about etcd.

It is recommending to have at least 3 instances for a serious production environment.


**Single Node**

Define a group `etcd` in the inventory, It will create a singleton etcd instance.

```yaml
# etcd cluster for ha postgres
etcd: { hosts: { 10.10.10.10: { etcd_seq: 1 } }, vars: { etcd_cluster: etcd } }
```

This is good enough for development, testing & demonstration, but not recommended in serious production environment.


**Three Nodes**

You can define etcd cluster with multiple nodes. Remember to use odd number for cluster size.

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

**More Nodes**

You can also add members to existing etcd cluster, and you have to tell the existing cluster with `etcdctl member add` first:  

```bash
etcdctl member add <etcd-?> --peer-urls=https://<new_ins_ip>:2380
./etcd.yml -l <new_ins_ip> -e etcd_init=existing
```

Check [ETCD Administration](ETCD-ADMIN) for more details.


----------------

## Administration

Here are some useful commands for etcd administration, check [ETCD ADMIN](ETCD-ADMIN) for more details.

**Cluster Management**

- [Create Cluster](ETCD-ADMIN#create-cluster)
- [Destroy Cluster](ETCD-ADMIN#destroy-cluster)
- [Reload Config](ETCD-ADMIN#reload-config)
- [Add Member](ETCD-ADMIN#add-member)
- [Remove Member](ETCD-ADMIN#remove-member)
- [Environment](ETCD-ADMIN#environment)

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


----------------

## Dashboards

There is one dashboard for ETCD module:

- [ETCD Overview](https://demo.pigsty.cc/d/etcd-overview): Overview of the ETCD cluster 


[![etcd-overview](https://github.com/Vonng/pigsty/assets/8587410/3f268146-9242-42e7-b78f-b5b676155f3f)](https://demo.pigsty.cc/d/etcd-overview)



----------------

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
