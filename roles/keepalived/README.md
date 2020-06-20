# Keepalived (ansible role)

This role will setup a keep alived instance amoung cluster
* render keepalived config

### Example Config

```
global_defs {
   router_id pg-meta                # use cluster name as router_id
   enable_script_security
   script_user root
}

vrrp_instance pg-meta {
  state BACKUP                      # host variable keepalived_role, default=BACKUP
  interface eth1                    # REQUIRED variable keepalived_nic
  virtual_router_id 189             # first byte as int from md5(cluster)
  priority 100                      # MASTER have priority 101, others is 100
  advert_int 1                      # interval between advertisements
  unicast_src_ip 10.10.10.10        # who am i
  unicast_peer {                    # who's my peers
  }

  authentication {                  # use cluster name as password
    auth_type PASS
    auth_pass pg-meta
  }

  virtual_ipaddress {               # REQUIRED variable keepalived_vip
    10.10.10.2
  }
}
```

### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
tasks:
  keepalived : Copy keepalived.conf for cluster	TAGS: [meta, pg_vip]
  keepalived : Reload keepalived to eanble vip	TAGS: [meta, pg_vip]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
# keepalived_vip: 10.10.10.2    # REQUIRED field virtual vip address
# keepalived_nic: eth1          # REQUIRED field nic interface
# keepalived_rip: xxxx          # REQUIRED field rip list
```