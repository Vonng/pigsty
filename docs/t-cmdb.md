# Inventory Upgrade

You can use postgres as [dynamic inventory](https://docs.ansible.com/ansible/latest/user_guide/intro_dynamic_inventory.html) instead of config file `pigsty.yml`.

CMDB Inventory enables integration with external admin tools, such as [`pigsty-cli`](https://github.com/Vonng/pigsty-cli) or other 3rd party tools.


### 1. Load Config

After `infra.yml` complete, use `bin/load_config` to upgrade static config file to cmdb dynamic inventory

```bash 
# bin/load_config [config_name=pgsql] [config_path=~/pigsty/pigsty.yml]
```

e.g : load default profile to cmdb as config profile `pgsql`
```bash
bin/load_config
```

e.g : load 4 node-demo profile to cmdb as config profile `demo4`
```bash
bin/load_config demo4 files/conf/pigsty-demo4.yml
```


### 2. Inventory Usage


After `bin/load_config`, use dynamic inventory instead of config file:
   
A dynamic inventory script `inventory.sh` will be created under pigsty home:
   
```bash
psql service=meta -AXtwc 'SELECT text FROM pigsty.inventory;'
```

`~/pigsty/ansible.cfg` will be adjusted to use `inventory.sh` as inventory: 

```bash
---
inventory = pigsty.yml
+++
inventory = inventory.sh
```

if you want rollback to static config file, change that line back to `pigsty.yml`

If your ansible.cfg not lies there, adjust your inventory with `-i <path_to_inventory.sh>`



### 3. CMDB Usage

cmdb will be installed under `pg-meta.meta` database, using schema `pigsty`

There are several tables, views and functions:

Check [cmdb.sql](https://github.com/Vonng/pigsty/blob/master/files/cmdb.sql) for detail.

```bash
# Tables
pigsty.config                   # raw config table
pigsty.global_var               # global config entries
pigsty.cluster                  # cluster
pigsty.cluster_var              # cluster config entries
pigsty.instance                 # instance
pigsty.instance_var             # instance config entries
pigsty.node                     # node
pigsty.job                      # job

# views
pigsty.inventory            # de-parsed inventory
pigsty.cluster_config       # merged config for cluster
pigsty.instance_config      # merged config for instance
pigsty.cluster_user         # cluster user definition in pg_users
pigsty.cluster_database     # cluster database definition in pg_databases
pigsty.cluster_service      # cluster service definition in pg_services & pg_services_extra

# seqs
pigsty.job_id_seq
```

Also some built-in functions:

```bash
pigsty.activate_config
pigsty.active_config
pigsty.active_config_name
pigsty.clean_config
pigsty.deactivate_config
pigsty.delete_config
pigsty.delete_node
pigsty.dump_config
pigsty.ins_cls
pigsty.ins_ip
pigsty.ins_is_meta
pigsty.ins_role
pigsty.ins_seq
pigsty.ip2ins
pigsty.job_id
pigsty.job_id_ts
pigsty.node_cls
pigsty.node_ins
pigsty.node_is_meta
pigsty.node_status
pigsty.parse_config
pigsty.select_cluster
pigsty.select_config
pigsty.select_instance
pigsty.select_instance
pigsty.select_node
pigsty.update_cluster_var
pigsty.update_cluster_vars
pigsty.update_global_var
pigsty.update_global_vars
pigsty.update_instance_var
pigsty.update_instance_vars
pigsty.update_node_status
pigsty.upsert_cluster
pigsty.upsert_config
pigsty.upsert_instance
pigsty.upsert_node
```