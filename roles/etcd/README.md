# etcd (ansible role)

This role will provision dcs:etcd

* install etcd according to `dcs_type` (etcd)
* cleaning existing etcd instance
* create fresh new etcd instance


### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
dcs_type: etcd                    # consul | etcd | both
dcs_name: pigsty                  # etcd initial cluster token
dcs_servers: {}                   # dcs name:ip dict (e.g: pg-meta-1: 10.10.10.10)
dcs_exists_action: skip           # skip|abort|clean if dcs server already exists

# default value for inner variable
etcd_exists: false
```