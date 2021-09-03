# Configuration

Every Pigsty deployment has a corresponding **Configuration**:
whether it's for production environment with hundreds of clusters,
or a local 1C/1GB sandbox, there is no real difference, except for the config content.

Pigsty defines infrastructure and database clusters through **Configuration Inventory** (Inventory). 
The actual implementation of inventory can be either local [config file](#config-file) (DEFAULT),
or dynamic config data from [CMDB](t-cmdb.md) (OPTIONAL). 
The default YAML config file approach is used as example in this article.
A sample of a typical configuration file: [`pigsty.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml)

Config file is consist of [config entries](#config-entry). 
Pigsty provides 175 config entries, and can be configured at different [levels](#hierarchy). 
Most of them can be directly used with default values, and the rest can be customized on demand. config entries can be divided into two major categories: [Infrastructure Configuration](#Infrastructure Configuration) and [Database Cluster](#Database Cluster Configuration), and further subdivided into ten groups.

| No | Group | Category | Quantity | Function |
| :--: | :-------------------------------: | :------: | :--: | -------------------------------------- |
| 1 | [connect](v-connect.md) | infra | 1 | Proxy server configuration, connection information for managed objects |
| 2 | [repo](v-repo.md) | infra | 10 | Customize local Yum sources, install packages offline |
| 3 | [node](v-node.md) | infra | 31 | Configuring infrastructure on a normal node |
| 4 | [meta](v-meta.md) | infra | 26 | Installing and enabling infrastructure services on a meta node |
| 5 | [dcs](v-dcs.md) | infra | 8 | Configure DCS services (consul/etcd) on all nodes |
| 6 | [pg-install](v-pg-install.md) | pgsql | 11 | Installing the PostgreSQL database |
| 7 | [pg-provision](v-pg-provision.md) | pgsql | 32 | Pulling up a PostgreSQL database cluster |
| 8 | [pg-template](v-pg-template.md) | pgsql | 19 | Customizing PostgreSQL database content |
| 9 | [monitor](v-monitor.md) | pgsql | 21 | Installing Pigsty database monitoring system |
| 10 | [service](v-service.md) | pgsql | 17 | Expose database services to the public via Haproxy or VIP |

For the specific available config entries, please refer to [config entry list](v-config.md#config-entries)


## Config Entry

Configuration entry are in the form of key-value pairs: the key is the **name** of the config entry, and the value is the content of it. The schema of the value varies, it may be a simple single string, or a complex array of objects.

Pigsty's parameters can be configured at different **levels** and are inherited and overwritten according to rules, with higher priority config entries overwriting lower priority config entries of the same name. This allows users to target specific clusters and instances at different levels and at different granularities for **fine** configuration.

### Hierarchy

In Pigsty's [config file](#config-file), **configuration entries** can appear in 3 different locations: **global**, **cluster**, **instance**.

config entries defined in **cluster's** `vars` will override **global** config entries by name,
and config entries defined in **instance's** `vars` will override cluster's config entries too.

| Granularity | Scope | Priority | Description | Location |
| :----------: | ---- | ------ | -------------------------- | ------------------------------------ |
| **G**lobal | global | low | consistent within the same set of **deployment environments** | `all.vars.xxx` |
| **C**luster | Cluster | Medium | Consistent within the same set of **clusters** | `all.children.<cls>.vars.xxx` |
| **I**nstance | Instance | High | Finest Granularity of Configuration Hierarchy | `all.children.<cls>.hosts.<ins>.xxx` |

Not all config entries are **suitable** for use at all levels. 
For example, infrastructure parameters will usually only be defined in the **global** configuration,
database instance labels, roles, load balancing weights, etc. can only be configured at the **instance** level,
and some operational options can only be provided using command line parameters (e.g. the name of the database to be created).
For details and scope of config entries, please refer to the [list of config entries](v-config.md#config-entries).

### Defaults and Overwrite

In addition to the three types of configuration granularity in the configuration file, there are two additional levels of priority in the Pigsty config entries: default value pocketing and command line parameter forced override.

* **Default**: When a configuration item does not appear at either the global/cluster/instance level, the default configuration item will be used. The default value has the lowest priority, and all config entries have default values. The default parameters are defined in `roles/<role>/default/main.yml`.
* **Parameters**: When the user passes in parameters via the command line, the config entries specified by the parameters have the highest priority and will override all levels of configuration. Some config entries can only be specified and used by means of command line arguments.

| hierarchy | source | priority | description | location |
| :----------: | ---- | ------ | -------------------------- | ------------------------------------ |
| **D**efault | Default | Minimum | Code Logic Defined Default | `roles/<role>/default/main.yml` |
| **G**lobal | global | low | consistent within the same set of **deployment environments** | `all.vars.xxx` |
| **C**luster | Cluster | Medium | Consistent within the same set of **clusters** | `all.children.<cls>.vars.xxx` |
| **I**nstance | Instance | High | Finest Granularity of Configuration Hierarchy | `all.children.<cls>.hosts.<ins>.xxx` |
| **A**rgument | parameters | highest | passed in via command line arguments | `-e ` |






## Config File

A specific sample configuration file is available in the root of the Pigsty project: [`pigsty.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml)

The top level of the config file is a single object with the only key `all`,
Which value is another object consist of two child items: `vars` and `children`.

```yaml
all: # top-level object all
  vars: <123 keys> # global configuration all.vars

  children: # Grouping definition: all.children Each item defines a database cluster 
    meta: <2 keys>...     # Special grouping meta that defines environment management nodes
    
    pg-meta: <2 keys>...  # Detailed definition of the database cluster pg-meta
    pg-test: <2 keys>...  # Detailed definition of database cluster pg-test
    ...
```

The contents of `vars` are KV key-value pairs that define global configuration parameters, K is the name of the configuration item and V is the content of the configuration item.

The content of `children` is also a KV structure, K is the cluster name, V is the specific cluster definition, and the definition of a sample cluster is shown below.

* The cluster definition also includes two sub-items: `vars` defines the configuration at **cluster level**. `hosts` defines the cluster's instance members.
* The parameters in the cluster configuration override the corresponding parameters in the global configuration, and the cluster configuration parameters are in turn overridden by the configuration parameters of the same name at the instance level. The only mandatory parameter in the cluster configuration is `pg_cluster`, which is the name of the cluster and must be consistent with the higher-level cluster name.
* The cluster instance members are defined in `hosts` using KV, K is the IP address (must be ssh reachable), V is the specific instance configuration parameters
* There are two mandatory parameters in the instance configuration parameters: `pg_seq`, and `pg_role`, which are the unique serial number of the instance and the role of the instance, respectively.

```yaml
pg-test: # The database cluster name is used as the cluster name by default
  vars: # database cluster level variable
    pg_cluster: pg-test # A mandatory configuration item defined at the cluster level, consistent throughout pg-test 
  hosts: # Database cluster members
    10.10.10.11: {pg_seq: 1, pg_role: primary} # Database instance members
    10.10.10.12: {pg_seq: 2, pg_role: replica} # Must define identity parameters pg_role and pg_seq
    10.10.10.13: {pg_seq: 3, pg_role: offline} # Instance-level variables can be specified here
```

Pigsty configuration files follow the [**Ansible Rules**](https://docs.ansible.com/ansible/2.5/user_guide/playbooks_variables.html) in YAML format and use a single configuration file by default. default configuration file path is [`pigsty.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml) in the root directory of the Pigsty source code. The default configuration file is specified via `inventory = pigsty.yml` in [`ansible.cfg`](https://github.com/Vonng/pigsty/blob/master/ansible.cfg) in the same directory. You can specify additional configuration files with the `-i <config_path>` parameter when executing any script.

The configuration file needs to be used in conjunction with [**Ansible**](https://docs.ansible.com/). Ansible is a popular DevOps tool, but the average user does not need to know the specifics of Ansible. If you are proficient in Ansible, you can adapt the configuration file organization and structure according to Ansible's inventory organization rules: for example, use a discrete configuration file with separate cluster definition and variable definition files for each cluster.

The content of the configuration file consists of two main parts.

* [Infrastructure Config](#infrastructure-config): defines or describes the infrastructure of the current environment, relatively constant
* [Database Cluster Config](#database-cluster-config): defines the database clusters required by the user, added and modified as needed




## Infrastructure Config

Infrastructure configuration deals with such issues: local Yum sources, machine node base services: DNS, NTP, kernel modules, parameter tuning, managing users, installing packages, DCS Server setup, monitoring infrastructure installation and initialization (Grafana, Prometheus, Alertmanager), global traffic portal Nginx configuration, etc.

Generally speaking, the infrastructure part requires very few changes, and usually involves only text replacement of the IP addresses of the management nodes, a step that is automatically performed during `. /configure` process automatically, the other change sometimes needed is the access domain defined in [`nginx_upstream`](v-meta.md#nginx_upstream).

Other parameters rarely need to be tweaked, just as needed. For example, if your VM provider has configured DNS servers with NTP servers for you, then you can set [`node_dns_server`](v-node.md#node_dns_server) with [`node_ntp_config`](v-node.md#node_ntp_config) is set to `none` and `false`, skipping the DNS and NTP settings.

Pigsty provides typical configuration files as **templates** for several typical deployment environments. See the [`files/conf`](https://github.com/Vonng/pigsty/tree/master/files/conf) directory for details

During [`configure`](s-install.md#configure), the configuration wizard will automatically select a configuration template** based on the current machine environment**, but the user can manually specify the use of a configuration template via `-m <mode>`, e.g.

- [`demo4`] project default configuration file, 4-node sandbox
- [`pg14`] 4-node sandbox deployment using PG14 Beta as the default version
- [`pub4`] Configuration file used by the official Pigsty demo site (4 cloud VMs)
- [`demo`] Single node sandbox, this configuration will be used if the current sandbox VM is detected
- [`tiny`] Single node deployment, if you use a normal node (micro: cpu < 8) deployment, this configuration will be used
- [`oltp`] Production single-node deployment, this configuration is used if you are using a normal node (high: cpu >= 8)

You can use the appropriate deployment template according to your actual deployment environment.









## Database Cluster Config

Users need to focus more on the definition and configuration of database clusters.

Pigsty manage cluster/instance with **Identity**.
When defining a database cluster, user **MUST** provide [Identity](#identity-parameters) and [Connection](#connection-information) information about it.

**Identity** (e.g., cluster name, instance number) is used to identify [entities](c-entity.md) among the system.
while **Connection Information** (e.g., IP address) is used to **access** the **database node**.

There are four groups of config entires that are related to PostgreSQL:

### [Install PostgreSQL Software](v-pg-install.md)

> What version to install, which plugins to install, what users to use

Usually the parameters in this section can be used directly without modifying anything, and need to be adjusted when the PG version is upgraded.

### [Provisioning PostgreSQL Cluster](v-pg-provision.md)

> Where to create the directory, what cluster to create, what IP ports to listen to, and what connection pooling mode to use.

[**identity**](#identity-parameters) are mandatory, other than that there are few default parameters to change.

With [`pg_conf`](v-pg-provision.md#pg_conf) you can use the default database cluster templates
(Normal Transactional OLTP / Normal Analytical OLAP / Core Financial CRIT / Micro Virtual Machine TINY).
If you wish to create custom templates, you can clone the default configuration in `roles/postgres/templates` and adopt it with your own modifications,
check [Patroni Template Customization](t-patroni-template.md) for details.



### [Customize Cluster Template](v-pg-template.md)

> Which roles, users, databases, schemas to create, which extensions to enable, how to set permissions and whitelist

This section cares about what's inside your database.

- [business-user](c-user.md): (which users to use to access the database?) Attributes, restrictions, roles, permissions ......)
- [business-database](c-database.md): (What kind of database is needed? Extensions, schema, parameters, permissions ......)
- [default-template database](v-pg-template.md) (template1) (schema, extensions, default permissions)
- [access-control-system](c-auth.md) (role, user, HBA)
- [exposed-services](c-service.md) (which ports to use, which instances to direct traffic to, health checks, weights ......)

You may change some of these according to your needs.



### [pull up database monitoring](v-monitor.md)

> Deploy Pigsty monitoring system components

No change is needed, but in [monitor-only deployment](t-monly.md) mode needs to be focused on and tuned.

### [Expose Cluster Service](v-service.md)

> Expose database services externally via HAProxy/VIP

No need to adjust the configuration here unless the user wants to change the default [service](c-service) and [access method](c-access).









## Identity Parameters

**Identity parameters** are the information that must be provided when defining a database cluster, including.

| name | attributes | description | examples |
| :-----------------------------------------: | :----------------: | :------: | :------------------: |
| [`pg_cluster`](v-pg-provision.md#pg_cluster) | **must**, cluster level | cluster name | `pg-test` |
| [`pg_role`](v-pg-provision.md#pg_role) | **MUST OPTIONAL**, instance level | instance role | `primary`, `replica` |
| [`pg_seq`](v-pg-provision.md#pg_seq) | **MUST OPTIONAL**, instance level | instance serial number | `1`, `2`, `3`,`... ` |

The content of the identity parameter follows the [entity naming convention](c-entity.md),
where [`pg_cluster`](v-pg-template.md#pg_cluster) , [`pg_role`](v-pg-template.md#pg_role), [`pg_seq`](v-pg-template.md#pg_seq) belong to the core identity parameters,
which are the **minimum set of mandatory parameters** required to define the database cluster,
and the core identity parameters must be **explicitly specified** and cannot be ignored.

- `pg_cluster` identifies the name of the cluster, which is configured at the cluster level and serves as the top-level namespace for cluster resources.
- `pg_role` identifies the role that the instance plays in the cluster, configured at the instance level, with optional values including

  - `primary`: the **unique primary repository** in the cluster, the cluster leader, which provides write services.
  - `replica`: the **ordinary slave library** in the cluster, which takes on regular production read-only traffic.
  - `offline`: **offline slave** in the cluster, takes ETL/SAGA/personal user/interactive/analytical queries.
  - `standby`: **synchronous slave** in the cluster, with synchronous replication and no replication latency.
  - `delayed`: **delayed slave** in the cluster, explicitly specifying replication delay, used to perform backtracking queries and data salvage.

- `pg_seq` is used to identify instances within the cluster, usually with an integer number incremented from 0 or 1, which is not changed once assigned.
- `pg_shard` Used to identify the upper level **shard cluster** to which the cluster belongs, only required if the cluster is a member of a horizontally sharded cluster.
- `pg_sindex` is used to identify the cluster's **slice cluster** number, and only needs to be set if the cluster is a member of a horizontal slice cluster.
- `pg_instance` is the **derived identity parameter** that uniquely identifies a database instance, with the following composition rules

  `{{ pg_cluster }}-{{ pg_seq }}`. Since `pg_seq` is unique within the cluster, this identifier is globally unique.


### Defining horizontally sharded database clusters

`pg_shard` and `pg_sindex` are used to define special sharded database clusters and are optional identity parameters that are currently reserved and not actually used.

Suppose a user has a horizontally sharded **Sharded Database Cluster (Shard)** with the name `test`. This cluster consists of four separate clusters: `pg-test1`, `pg-test2`, `pg-test3`, and `pg-test-4`. Then the user can bind the identity of `pg_shard: test` to each database cluster and `pg_sindex: 1|2|3|4` to each database cluster separately. As follows.

```yaml
pg-test1:
  vars: {pg_cluster: pg-test1, pg_shard: test, pg_sindex: 1}
  hosts: {10.10.10.10: {pg_seq: 1, pg_role: primary}}
pg-test2:
  vars: {pg_cluster: pg-test1, pg_shard: test, pg_sindex: 2}
  hosts: {10.10.10.11: {pg_seq: 1, pg_role: primary}}
pg-test3:
  vars: {pg_cluster: pg-test1, pg_shard: test, pg_sindex: 3}
  hosts: {10.10.10.12: {pg_seq: 1, pg_role: primary}}
pg-test4:
  vars: {pg_cluster: pg-test1, pg_shard: test, pg_sindex: 4}
  hosts: {10.10.10.13: {pg_seq: 1, pg_role: primary}}
```



## Connect Parameters

If the identity parameter is the identity of the database cluster, then **connection information is the identity of the database node**.

Database clusters need to be deployed on database nodes, and Pigsty uses the **database node to database instance one-to-one** deployment model.

The **database node uses an IP address as an identifier** and the database instance uses an identifier in the shape of `pg-test-1`. The identifiers of **Database Node** and **Database Instance** can correspond to each other and be converted to each other.

For example, in the example defining a database cluster, the database instance (`pg-test-1`) with `pg_seq = 1` in the database cluster `pg_cluster = pg-test` is deployed on the database node with IP address `10.10.10.11`. The IP address `10.10.10.11` here is the **connection information**.

Pigsty uses **IP address** as a unique identifier for the **database node**, **which must be the IP address that the database instance listens to and serves externally**, but it is not appropriate to use a public IP address. Nevertheless, users do not necessarily have to connect to that database via that IP address. For example, it is also possible to operate the management target node indirectly through SSH tunnels or springboard machine transit. However, the primary IPv4 address remains the core identifier of the node when identifying the database node.** This is very important and users should ensure this during configuration. **

### Other Connection methods

If your target machine is hidden behind an SSH springboard machine, or if it is not possible to scheme directly by way of `ssh ip`, consider using [Ansible connection parameters](v-connect.md).

For example, in the example below, [`ansible_host`](v-connect.md#ansible_host) tells Pigsty to access the target database node by way of ``ssh node-1`` instead of ``ssh 10.10.10.11`` by way of SSH alias.

```yaml
  pg-test:
    vars: { pg_cluster: pg-test }
    hosts:
      10.10.10.11: { pg_seq: 1, pg_role: primary, ansible_host: node-1}
      10.10.10.12: {pg_seq: 2, pg_role: replica, ansible_host: node-2}
      10.10.10.13: {pg_seq: 3, pg_role: offline, ansible_host: node-3}
```

In this way, users can freely specify the connection method of the database node and save the connection configuration in `~/.ssh/config` of the administrative user for independent management.



