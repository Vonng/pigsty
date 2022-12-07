# etcd

install etcd server on nodes.

trusted ca file: `/etc/pki/ca.crt` should exist on all servers.

which is generated in `role: ca` and loaded & trusted by default in `role: node`



## Available Tasks

* etcd_install
* etcd_clean
  * etcd_check
  * etcd_purge
* etcd_dir
* etcd_config
  * etcd_cert
    * etcd_cert_copy
  * etcd_conf
* etcd_launch
* etcd_register



## Example Definition

```yaml
etcd:
  hosts:
    10.10.10.10: { etcd_seq: 1 }
    10.10.10.11: { etcd_seq: 2 }
    10.10.10.12: { etcd_seq: 3 }
  vars:
    etcd_cluster: etcd
```

```yaml
./etcd.yml    # deploy 3-node etcd cluster
```


## Shortcuts

```bash
alias e="etcdctl"
alias em="etcdctl member"
export ETCDCTL_API=3
export ETCDCTL_CACERT=/etc/pki/ca.crt
export ETCDCTL_CERT=/etc/etcd/server.crt
export ETCDCTL_KEY=/etc/etcd/server.key
export ETCDCTL_ENDPOINTS=https://10.10.10.10:2379
```

CRUD example: 

```bash
e put a 10 ; e get a; e del a ; # V3 API
```






### New cluster

```bash
./etcd.yml                # deploy etcd cluster according to the definition
```

### Destroy cluster

```bash
./etcd.yml -t etcd_purge  # purge existing etcd cluster
```

### Remove a member

Reference: [Remove a member](https://etcd.io/docs/v3.5/op-guide/runtime-configuration/#remove-a-member)



```bash
# first, change all client endpoint to new list
etcdctl member remove <memberid>
./etcd.yml -t etcd_purge <target_ip_addr>

# update etcd server endpoint reference
./etcd.yml -t etcd_conf   # then restart
./pgsql.yml -t pg_conf    # then reload patroni 
```



### Add a member

Reference: [Add a member](https://etcd.io/docs/v3.5/op-guide/runtime-configuration/#add-a-new-member)

Use `member add` to safely add a member. 

```bash
# run on etcd server
em add --learner <name> <peerurl>

# promote leaner to follower after catch-up
em member promote <member_id>
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
./pgsql.yml -t pg_conf    # then reload patroni
```
