# CMDB Usage

Instead of a static config file, you can use `postgres` as an inventory for Pigsty.

Using CMDB as a dynamic Inventory for Ansible has several advantages: metadata is presented as data tables in a highly structured way, and database constraints ensure consistency. The CMDB also allows you to use third-party tools to manage Pigsty metadata.

Currently, Pigsty's CMDB only supports PostgreSQL clusters. If your pigsty.yml contains Redis and MatrixDB, it will report an error. It is recommended to use a separate pigsty.yml config file to manage Redis and Greenplum clusters. 

The Pigsty CMDBmode is automatically created during the initialization of the `pg-meta` meta DB ([`files/cmdb.sql`](https://github.com/Vonng/pigsty/blob/master/files/cmdb.sql)) and is located in the `meta` database's ` pigsty` mode of the meta DB. Static config files can be loaded into the CMDB using `bin/inventory_load`.

!>  You must execute [`infra.yml`](p-infra.md#infra) entirely in the meta node after installation before you can use CMDB.

```bash 
usage: inventory_load [-h] [-p PATH] [-d CMDB_URL]

load config arguments

optional arguments:
  -h, --help            show this help message and exit
  -p PATH, --path PATH  config path, ${PIGSTY_HOME}/pigsty.yml by default
  -d DATA, --data DATA  postgres cmdb pgurl, ${METADB_URL} by default
```

By default, executing the script without parameters will load `$PIGSTY_HOME/pigsty.yml` into the CMDB under the name `pgsql`.

```bash
bin/inventory_load # load default config to default cmdb
bin/inventory_load -p files/conf/pigsty-demo.yml
bin/inventory_load -p files/conf/pigsty-dcs3.yml -d postgresql://dbuser_meta:DBUser.Meta@10.10.10.10:5432/meta
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
