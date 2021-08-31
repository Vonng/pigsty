# DCS

Pigsty uses DCS (Distributive Configuration Storage) as a meta-database. dcs has three important roles.

* Primary repository election: Patroni performs election and switchover based on DCS
* Configuration Management: Patroni uses DCS to manage the configuration of Postgres
* Identity Management: The monitoring system manages and maintains the identity information of the database instances based on DCS.

DCS is critical to the stability of the database. 
Pigsty provides basic Consul and Etcd support for **demonstration purposes**, 
with DCS services deployed in the meta-node. 
It is recommended that a dedicated DCS cluster be deployed in a production environment using a dedicated machine.



## Overview

|                            Name                             |    Type    | Level  | Description |
| :----------------------------------------------------------: | :--------: | :---: | ---- |
|         [service_registry](#service_registry)          |  `enum`  |  G/C/I  | where to register service? |
|                 [dcs_type](#dcs_type)                  |  `enum`  |  G  | which dcs to use (consul/etcd) |
|                 [dcs_name](#dcs_name)                  |  `string`  |  G  | dcs cluster name (dc) |
|              [dcs_servers](#dcs_servers)               |  `dict`  |  G  | dcs server dict |
|        [dcs_exists_action](#dcs_exists_action)         |  `enum`  |  G/A  | how to deal with existing dcs |
|        [dcs_disable_purge](#dcs_disable_purge)         |  `bool`  |  G/C/I  | disable dcs purge |
|          [consul_data_dir](#consul_data_dir)           |  `string`  |  G  | consul data dir path |
|            [etcd_data_dir](#etcd_data_dir)             |  `string`  |  G  | etcd data dir path |


## Defaults

```yaml
#------------------------------------------------------------------------------
# DCS PROVISION
#------------------------------------------------------------------------------
service_registry: consul                      # where to register services: none | consul | etcd | both
dcs_type: consul                              # consul | etcd | both
dcs_name: pigsty                              # consul dc name | etcd initial cluster token
dcs_servers:                                  # dcs server dict in name:ip format
  meta-1: 10.10.10.10                         # you could use existing dcs cluster
  # meta-2: 10.10.10.11                       # host which have their IP listed here will be init as server
  # meta-3: 10.10.10.12                       # 3 or 5 dcs nodes are recommend for production environment
dcs_exists_action: clean                      # abort|skip|clean if dcs server already exists
dcs_disable_purge: false                      # set to true to disable purge functionality for good (force dcs_exists_action = abort)
consul_data_dir: /var/lib/consul              # consul data dir (/var/lib/consul by default)
etcd_data_dir: /var/lib/etcd                  # etcd data dir (/var/lib/consul by default)
```





## Details

### service_registry

The address of a service registration that is referenced by multiple components.

* `none`: does not perform service registration (when performing **monitoring deployment only**, `none` mode must be specified)
* `consul`: registers the service to Consul
* `etcd`: register the service to Etcd (not yet supported)



### dcs_type

DCS type, with two options.

* Consul

* Etcd (support is not yet complete)




### dcs_name

DCS cluster name

Default is `pigsty`

Represents the DataCenter name in Consul



### dcs_servers

DCS server name and address, in dictionary format, Key is the DCS server instance name, Value is the corresponding IP address.

You can use an external existing DCS server or initialize a new DCS server on the target machine.

If you use the initialization of a new DCS instance, it is recommended that you complete the DCS initialization on all DCS Servers (usually also meta-nodes) first.

Although you can also initialize all DCS Servers with the DCS Agent at once, you must include all Servers in the complete initialization. At this point all target machines with IP addresses matching the `dcs_servers` entry will be initialized as DCS Servers during the DCS initialization process.

It is highly recommended to use an odd number of DCS Servers, a single DCS Server for demo environments and 3 to 5 for production environments to ensure DCS availability.

You must explicitly configure the DCS Server as appropriate, for example in a sandbox environment you can choose to enable 1 or 3 DCS nodes.

```yaml
dcs_servers:
  meta-1: 10.10.10.10
  meta-2: 10.10.10.11 
  meta-3: 10.10.10.12 
```




### dcs_exists_action

Safety insurance, the action the system should perform when a Consul instance already exists

* abort: abort the entire script execution (default behavior)
* clean: erase the existing DCS instance and continue (extremely dangerous)
* skip: ignore the target where the DCS instance exists (abort) and continue execution on the other target machine.

If you really need to force wipe the already existing DCS instances, it is recommended to use `pgsql-rm.yml` to complete the cluster and instance offline and destruction first, before re-executing the initialization. Otherwise, you need to complete the overwrite with the command line parameter `-e dcs_exists_action=clean` to force the wiping of existing instances during the initialization process.



### dcs_disable_purge

Double safety, default is `false`. If `true`, forces the `dcs_exists_action` variable to be set to `abort`.

Equivalent to disabling purge for `dcs_exists_action`, ensuring that no DCS instances will be wiped under any circumstances.



### consul_data_dir

Consul data directory address

Default is `/var/lib/consul`



### etcd_data_dir

Etcd data directory address

Default is `/var/lib/etcd`