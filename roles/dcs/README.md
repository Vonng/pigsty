# DCS (ansible role)

This role will provision dcs (consul or etcd)

* install etcd or consul according to `dcs_type` (consul by default)
* cleaning existing dcs instance
* create fresh new dcs instance


### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Check for existing consul		  TAGS: [consul_check, dcs]
Consul exists flag fact set		  TAGS: [consul_check, dcs]
Abort due to consul exists		  TAGS: [consul_check, dcs]
Clean existing consul instance	  TAGS: [consul_check, dcs]
Purge existing consul instance	  TAGS: [consul_check, dcs]
Make sure consul is installed	  TAGS: [consul_install, dcs]
Get dcs server node names		  TAGS: [consul_config, dcs]
Get dcs node name from var		  TAGS: [consul_config, dcs]
Fetch hostname as dcs node name	  TAGS: [consul_config, dcs]
Get dcs name from hostname		  TAGS: [consul_config, dcs]
Copy /etc/consul.d/consul.json	  TAGS: [consul_config, dcs]
Get dcs bootstrap expect quroum	  TAGS: [consul_server, dcs]
Copy consul server service unit	  TAGS: [consul_server, dcs]
Launch consul server service	  TAGS: [consul_server, dcs]
Wait for consul server online	  TAGS: [consul_server, dcs]
Copy consul agent service		  TAGS: [consul_agent, dcs]
Launch consul agent service		  TAGS: [consul_agent, dcs]
Wait for consul agent online	  TAGS: [consul_agent, dcs]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
dcs_type:    consul                               # default dcs server type: consul
dcs_servers: []                                   # default dcs servers
dcs_purge: false                                  # force remove existing server
# dcs_check_interval: 15s                         # default service check interval (not used)
# dcs_check_timeout:  3s                          # default service check timeout  (not used)
```