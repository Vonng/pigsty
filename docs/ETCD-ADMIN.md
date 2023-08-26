# ETCD Administration

> Here are some common administration tasks about [`ETCD`](ETCD) cluster

- [Create Cluster](#create-cluster)
- [Destroy Cluster](#destroy-cluster)
- [Reload Config](#reload-config)
- [Add Member](#add-member)
- [Remove Member](#remove-member)


----------------

## Create Cluster

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
./etcd.yml # 初始化整个etcd集群 
```


----------------

## Destroy Cluster

To destroy an etcd cluster, just use the `etcd_clean` subtask of `etcd.yml`, do think before you type.

```bash
./etcd.yml -t etcd_clean  # remove entire cluster, honor the etcd_safeguard
./etcd.yml -t etcd_purge  # purge with brutal force, omit the etcd_safeguard
```




----------------

## Reload Config

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

## Add Member

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



----------------

## Remove Member

To remove a member from existing etcd cluster, it usually takes 3 steps:

1. remove/uncomment it from inventory and [reload config](#reload-config) 
2. remove it with `etcdctl member remove <server_id>` command and kick it out of the cluster
3. temporarily add it back to inventory and purge that instance, then remove it from inventory permanently

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

