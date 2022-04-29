# Consul (ansible role)

This role will install consul on hosts

* if target server in dcs_servers, init it as a server
* otherwise, init a consul client and join dcs_servers
* if consul already exists, the action depends on variable `consul_clean`, where:
    * `skip (default)` will skip this **play** on that host
    * `clean (dangerous)` will force remove existing consul instance
    * `abort` treat this as an error and will abort entire playbook for all hosts  
* variable `consul_name` will be used as consul data center name
* key in `dcs_servers` will be used as consul server node name
* host variable `nodename` or node's `hostname` will be used as consul node name

### Tricks

```
./infra.yml --tags=dcs -e consul_clean=true
```

### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Check for existing consul	TAGS: [consul, consul_check, dcs, infra-node]
Consul exists flag fact set	TAGS: [consul, consul_check, dcs, infra-node]
Abort due to consul exists	TAGS: [consul, consul_check, dcs, infra-node]
Skip due to consul exists	TAGS: [consul, consul_check, dcs, infra-node]
Clean existing consul instance	TAGS: [consul, consul_clean, dcs, infra-node]
Stop any running consul instance	TAGS: [consul, consul_clean, dcs, infra-node]
Remove existing consul dir	TAGS: [consul, consul_clean, dcs, infra-node]
Recreate consul dir	TAGS: [consul, consul_clean, dcs, infra-node]
Make sure consul is installed	TAGS: [consul, consul_install, dcs, infra-node]
Make sure consul dir exists	TAGS: [consul, consul_config, dcs, infra-node]
Get dcs server node names	TAGS: [consul, consul_config, dcs, infra-node]
Get dcs node name from var nodename	TAGS: [consul, consul_config, dcs, infra-node]
Fetch hostname as dcs node name	TAGS: [consul, consul_config, dcs, infra-node]
Get dcs name from hostname	TAGS: [consul, consul_config, dcs, infra-node]
Make sure consul hcl absent	TAGS: [consul, consul_config, dcs, infra-node]
Copy /etc/consul.d/consul.json	TAGS: [consul, consul_config, dcs, infra-node]
Copy consul agent service	TAGS: [consul, consul_config, dcs, infra-node]
Copy consul node-meta definition	TAGS: [consul, consul_config, consul_meta, dcs, infra-node]
Restart consul to load new node-meta	TAGS: [consul, consul_config, consul_meta, dcs, infra-node]
Get dcs bootstrap expect quroum	TAGS: [consul, consul_server, dcs, infra-node]
Copy consul server service unit	TAGS: [consul, consul_server, dcs, infra-node]
Launch consul server service	TAGS: [consul, consul_server, dcs, infra-node]
Wait for consul server online	TAGS: [consul, consul_server, dcs, infra-node]
Launch consul agent service	TAGS: [consul, consul_agent, dcs, infra-node]
Wait for consul agent online	TAGS: [consul, consul_agent, dcs, infra-node]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
#-----------------------------------------------------------------
# DCS
#-----------------------------------------------------------------
dcs_servers:                    # dcs server dict in name:ip format
  meta-1: 10.10.10.10           # using existing external dcs cluster is recommended for HA
  # pg-meta-2: 10.10.10.11      # node with ip in dcs_servers will be initialized as dcs servers
  # pg-meta-3: 10.10.10.12      # it's recommend to reuse meta nodes as dcs servers if no ad hoc cluster available

dcs_registry: consul        # where to register services: none | consul | etcd | both
dcs_type: consul                 # consul | etcd | both
consul_name: pigsty                 # consul dc name | etcd initial cluster token
consul_clean: abort         # abort|skip|clean if dcs server already exists (FOR DEMO ONLY!)
consul_safeguard: false         # set to true to disable purge functionality for good (force consul_clean = abort)
consul_data_dir: /var/lib/consul # consul data dir (/var/lib/consul by default)
consul_exists: false             # internal flag that indicate consul existence (DO NOT CHANGE!)
etcd_data_dir: /var/lib/etcd     # etcd data dir (/var/lib/consul by default)
```