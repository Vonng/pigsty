# CMDB Usage

Instead of a static config file, you can use `postgres` as an inventory for Pigsty.

Using CMDB as a dynamic Inventory for Ansible has several advantages: metadata is presented as data tables in a highly structured way, and database constraints ensure consistency. The CMDB also allows you to use third-party tools to manage Pigsty metadata.

Currently, Pigsty's CMDB only supports PostgreSQL clusters. If your pigsty.yml contains Redis and MatrixDB, it will report an error. It is recommended to use a separate pigsty.yml config file to manage Redis and Greenplum clusters. 

The Pigsty CMDBmode is automatically created during the initialization of the `pg-meta` meta DB ([`files/cmdb.sql`](https://github.com/Vonng/pigsty/blob/master/files/cmdb.sql)) and is located in the `meta` database's ` pigsty` mode of the meta DB. Static config files can be loaded into the CMDB using `bin/load_conf.py`.

!>  You must execute `infra.yml` entirely in the meta node after installation before you can use CMDB.

```bash 
usage: load_conf.py [-h] [-n NAME] [-p PATH] [-d DATA]

load config arguments

optional arguments:
  -h, --help            show this help message and exit
  -n NAME, --name NAME  config profile name, pgsql by default
  -p PATH, --path PATH  config path, ${PIGSTY_HOME}/pigsty.yml by default
  -d DATA, --data DATA  postgres cmdb pgurl, ${METADB_URL} by default
```

By default, executing the script without parameters will load `$PIGSTY_HOME/pigsty.yml` into the CMDB under the name `pgsql`.

```bash
bin/load_conf.py
```

You can load multiple different config files and give them different names. Existing config files with the same name will be overwritten. For example, the default config file ``pigsty-demo4.yml`` is loaded into CMDB and enabled.

```bash
bin/load_conf.py  -n demo4  -p files/conf/pigsty-demo4.yml
```



### CMDB as Inventory

Once the original config file is loaded into the CMDB as the initial data, Ansible can be configured to use the CMDB as the inventory.


```bash
bin/inventory_cmdb
```

You can switch back to a static config file. 

```bash
bin/inventory_conf
```


Modifying the inventory is essentially a matter of editing ``ansible. cfg`` in the Pigsty dir.

```bash
---
inventory = pigsty.yml
+++
inventory = inventory.sh
```



### CMDB Manifest

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
pigsty.setting

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

Also, some built-in functions:

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
pigsty.upsert_clusters
pigsty.upsert_config
pigsty.upsert_instance
pigsty.upsert_node
```