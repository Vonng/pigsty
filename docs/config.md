# Configuration

**Pigsty treats Infra & Database as Code.** You can describe the infrastructure & database clusters through a declarative interface. All your essential work is to describe your need in the [inventory](#inventory), then materialize it with a simple idempotent playbook.



## Inventory

Each pigsty deployment has a corresponding config **inventory**. It could be stored in a local git-managed file in [YAML](https://docs.ansible.com/ansible/2.9/user_guide/playbooks_variables.html) format or dynamically generated from [CMDB](https://docs.ansible.com/ansible/2.9/user_guide/intro_dynamic_inventory.html) or any ansible compatible format. Pigsty uses a monolith YAML config file as the default config inventory, which is [`pigsty.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml),  [located](https://github.com/Vonng/pigsty/blob/master/ansible.cfg#L3) in the pigsty home directory.

The inventory consists of two parts: **global vars** & multiple **group definitions**. You can define new clusters with inventory groups: `all.children[array]`. And describe infra and set global default parameters for clusters with global vars: `all.vars[object]`. Which may look like this:

```yaml
all:                # Top-level object: all
  vars: {...}       # Global Parameters
  children:         # Group Definitions
    meta:           # Group Definition: 'meta'
      hosts: {...}  # Group membership for 'meta'
      vars:  {...}  # Group Parameters for 'meta'
    pg-meta: {...}  # Group Definition: 'pg-meta'
    pg-test: {...}  # Group Definition: 'pg-test'
    ...
```



## Cluster

Each group may represent a cluster, which could be a node cluster, PostgreSQL cluster, or Redis cluster. They all use the same format: **group vars** & **hosts**. You can define cluster members with `all.children.<cls>.hosts[object]` and describe cluster with cluster parameters in `all.children.<cls>.vars[object]`. Here is an example of 3 nodes PostgreSQL HA cluster named `pg-test`:

```yaml
pg-test:   # Group Name
  vars:    # Group Vars (Cluster Parameters)
    pg_cluster: pg-test
  hosts:   # Group Host (Cluster Membership)
    10.10.10.11: { pg_seq: 1, pg_role: primary } # Host1
    10.10.10.12: { pg_seq: 2, pg_role: replica } # Host2
    10.10.10.13: { pg_seq: 3, pg_role: offline } # Host3
```

You can also define parameters for a specific host, as known as **host vars**. It will override group vars and global vars. Which is usually used for assigning identities to nodes & database instances.



## Parameter

Global vars, Group vars, and Host vars are dict objects consisting of a series of K-V pairs. Each pair is a named **Parameter** consisting of a string name as the key and a value of one of five types:  boolean, string, number, array, or object. Check parameter reference for detailed syntax & semantics.

Every parameter has a proper default value except for mandatory **IDENTITY PARAMETERS**; they are used as identifiers and must be set explicitly, such as `pg_cluster`, `pg_role,` and `pg_seq`.

Parameters can be specified & overridden with the following precedence.

```bash
Playbook Args  >  Host Vars  >  Group Vars  >  Global Vars  >  Defaults
```

For examples:

* Force removing existing databases with Playbook CLI Args `-e pg_clean=true`
* Override an instance role with Instance Level Parameter `pg_role` on Host Vars
* Override a cluster name with Cluster Level Parameter `pg_cluster` on Group Vars.
* Specify global NTP servers with Global Parameter `node_ntp_servers` on Global Vars
* If no `pg_version` is set, it will use the default value from role implementation



## Category

Pigsty contains 200+ parameters divided into four major categories: [INFRA](v-infra.md), [NODES](parameter.md#nodes), [PGSQL](v-pgsql.md), and [REDIS](parameter.md#redis).

| Category                      | Section                                                   | Description                        | Count |
|-------------------------------|-----------------------------------------------------------|------------------------------------|:-----:|
| [`INFRA`](parameter.md#infra) | [`META`](parameter.md#META)                               | Metadata of deployment             |   4   |
| [`INFRA`](parameter.md#infra) | [`CONNECT`](parameter.md#CONNECT)                         | Connection parameters              |   1   |
| [`INFRA`](parameter.md#infra) | [`REPO`](parameter.md#REPO)                               | Local source infra                 |   7   |
| [`INFRA`](parameter.md#infra) | [`CA`](parameter.md#CA)                                   | Public-Private Key Infra           |   5   |
| [`INFRA`](parameter.md#infra) | [`NGINX`](parameter.md#NGINX)                             | Nginx Web Server                   |   5   |
| [`INFRA`](parameter.md#infra) | [`NAMESERVER`](parameter.md#NAMESERVER)                   | DNS Server                         |   2   |
| [`INFRA`](parameter.md#infra) | [`PROMETHEUS`](parameter.md#PROMETHEUS)                   | Monitoring Time Series Database    |   8   |
| [`INFRA`](parameter.md#infra) | [`EXPORTER`](parameter.md#EXPORTER)                       | Universal Exporter Config          |   3   |
| [`INFRA`](parameter.md#infra) | [`GRAFANA`](parameter.md#GRAFANA)                         | Grafana Visualization Platform     |   9   |
| [`INFRA`](parameter.md#infra) | [`LOKI`](parameter.md#LOKI)                               | Loki log collection platform       |   6   |
| [`INFRA`](parameter.md#infra) | [`DCS`](parameter.md#DCS)                                 | Distributed Config Storage Meta DB |   7   |
| [`NODES`](parameter.md#nodes) | [`NODE_IDENTITY`](parameter.md#NODE_IDENTITY)             | Node identity parameters           |   5   |
| [`NODES`](parameter.md#nodes) | [`NODE_DNS`](parameter.md#NODE_DNS)                       | Node Domain Name Resolution        |   5   |
| [`NODES`](parameter.md#nodes) | [`NODE_REPO`](parameter.md#NODE_REPO)                     | Node Upstream Repo                 |   3   |
| [`NODES`](parameter.md#nodes) | [`NODE_PACKAGE`](parameter.md#NODE_PACKAGE)               | Node Packages                      |   4   |
| [`NODES`](parameter.md#nodes) | [`NODE_KERNEL_MODULES`](parameter.md#NODE_KERNEL_MODULES) | Node Kernel Module                 |   1   |
| [`NODES`](parameter.md#nodes) | [`NODE_TUNE`](parameter.md#NODE_TUNE)                     | Node parameter tuning              |   9   |
| [`NODES`](parameter.md#nodes) | [`NODE_ADMIN`](parameter.md#NODE_ADMIN)                   | Node Admin User                    |   7   |
| [`NODES`](parameter.md#nodes) | [`NODE_TIME`](parameter.md#NODE_TIME)                     | Node time zone and time sync       |   6   |
| [`NODES`](parameter.md#nodes) | [`DOCKER`](parameter.md#DOCKER)                           | Docker daemon on node              |   4   |
| [`NODES`](parameter.md#nodes) | [`NODE_EXPORTER`](parameter.md#NODE_EXPORTER)             | Node Indicator Exposer             |   3   |
| [`NODES`](parameter.md#nodes) | [`PROMTAIL`](parameter.md#PROMTAIL)                       | Log collection component           |   5   |
| [`PGSQL`](parameter.md#pgsql) | [`PG_IDENTITY`](parameter.md#PG_IDENTITY)                 | PGSQL Identity Parameters          |  13   |
| [`PGSQL`](parameter.md#pgsql) | [`PG_BUSINESS`](parameter.md#PG_BUSINESS)                 | PGSQL Business Object Definition   |  11   |
| [`PGSQL`](parameter.md#pgsql) | [`PG_INSTALL`](parameter.md#PG_INSTALL)                   | PGSQL Installation                 |  12   |
| [`PGSQL`](parameter.md#pgsql) | [`PG_BOOTSTRAP`](parameter.md#PG_BOOTSTRAP)               | PGSQL Cluster Initialization       |  38   |
| [`PGSQL`](parameter.md#pgsql) | [`PG_PROVISION`](parameter.md#PG_PROVISION)               | PGSQL Cluster Provisioning         |   9   |
| [`PGSQL`](parameter.md#pgsql) | [`PG_EXPORTER`](parameter.md#PG_EXPORTER)                 | PGSQL Indicator Exposer            |  13   |
| [`PGSQL`](parameter.md#pgsql) | [`PG_SERVICE`](parameter.md#PG_SERVICE)                   | PGSQL Service Access               |  16   |
| [`REDIS`](parameter.md#redis) | [`REDIS_IDENTITY`](parameter.md#REDIS_IDENTITY)           | REDIS Identity Parameters          |   3   |
| [`REDIS`](parameter.md#redis) | [`REDIS_PROVISION`](parameter.md#REDIS_PROVISION)         | REDIS Cluster Provisioning         |  14   |
| [`REDIS`](parameter.md#redis) | [`REDIS_EXPORTER`](parameter.md#REDIS_EXPORTER)           | REDIS Indicator Exposer            |   3   |

Check [parameter](parameter.md) for detailed usage.