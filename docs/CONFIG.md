# Configuration

**Pigsty treats Infra & Database as Code.** You can describe the infrastructure & database clusters through a declarative interface. All your essential work is to describe your need in the [inventory](#inventory), then materialize it with a simple idempotent playbook.

----------------

## Inventory

Each pigsty deployment has a corresponding config **inventory**. It could be stored in a local git-managed file in [YAML](https://docs.ansible.com/ansible/2.9/user_guide/playbooks_variables.html) format or dynamically generated from [CMDB](https://docs.ansible.com/ansible/2.9/user_guide/intro_dynamic_inventory.html) or any ansible compatible format. Pigsty uses a monolith YAML config file as the default config inventory, which is [`pigsty.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml),  [located](https://github.com/Vonng/pigsty/blob/master/ansible.cfg#L3) in the pigsty home directory.

The inventory consists of two parts: **global vars** & multiple **group definitions**. You can define new clusters with inventory groups: `all.children`. And describe infra and set global default parameters for clusters with global vars: `all.vars`. Which may look like this:

```yaml
all:                  # Top-level object: all
  vars: {...}         # Global Parameters
  children:           # Group Definitions
    infra:            # Group Definition: 'infra'
      hosts: {...}        # Group Membership: 'infra'
      vars:  {...}        # Group Parameters: 'infra'
    etcd:    {...}    # Group Definition: 'etcd'
    pg-meta: {...}    # Group Definition: 'pg-meta'
    pg-test: {...}    # Group Definition: 'pg-test'
    redis-test: {...} # Group Definition: 'redis-test'
    # ...
```

There are lots of config examples under [`files/pigsty`](https://github.com/Vonng/pigsty/blob/master/files/pigsty/README.md)


----------------

## Cluster

Each group may represent a cluster, which could be a Node cluster, PostgreSQL cluster, Redis cluster, Etcd cluster, or Minio cluster, etc... They all use the same format: **group vars** & **hosts**. You can define cluster members with `all.children.<cls>.hosts` and describe cluster with cluster parameters in `all.children.<cls>.vars`. Here is an example of 3 nodes PostgreSQL HA cluster named `pg-test`:

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



----------------

## Parameter

Global vars, Group vars, and Host vars are dict objects consisting of a series of K-V pairs. Each pair is a named **Parameter** consisting of a string name as the key and a value of one of five types:  boolean, string, number, array, or object. Check parameter reference for detailed syntax & semantics.

Every parameter has a proper default value except for mandatory **IDENTITY PARAMETERS**; they are used as identifiers and must be set explicitly, such as [`pg_cluster`](PARAM#pg_cluster), [`pg_role`](PARAM#pg_role), and [`pg_seq`](PARAM#pg_seq).

Parameters can be specified & overridden with the following precedence.

```bash
Playbook Args  >  Host Vars  >  Group Vars  >  Global Vars  >  Defaults
```

For examples:

* Force removing existing databases with Playbook CLI Args `-e pg_clean=true`
* Override an instance role with Instance Level Parameter `pg_role` on Host Vars
* Override a cluster name with Cluster Level Parameter `pg_cluster` on Group Vars.
* Specify global NTP servers with Global Parameter `node_ntp_servers` on Global Vars
* If no `pg_version` is set, it will use the default value from role implementation (16 by default)


----------------

## Reference

Pigsty have 280+ parameters, check [Parameter](PARAM) for details.

|          Module          | Section                                | Description                      | Count |
|:------------------------:|----------------------------------------|----------------------------------|-------|
|  [`INFRA`](PARAM#infra)  | [`META`](PARAM#meta)                   | Pigsty Metadata                  | 4     |
|  [`INFRA`](PARAM#infra)  | [`CA`](PARAM#ca)                       | Self-Signed CA                   | 3     |
|  [`INFRA`](PARAM#infra)  | [`INFRA_ID`](PARAM#infra_id)           | Infra Portals & Identity         | 2     |
|  [`INFRA`](PARAM#infra)  | [`REPO`](PARAM#repo)                   | Local Software Repo              | 9     |
|  [`INFRA`](PARAM#infra)  | [`INFRA_PACKAGE`](PARAM#infra_package) | Infra Packages                   | 2     |
|  [`INFRA`](PARAM#infra)  | [`NGINX`](PARAM#nginx)                 | Nginx Web Server                 | 7     |
|  [`INFRA`](PARAM#infra)  | [`DNS`](PARAM#dns)                     | DNSMASQ Nameserver               | 3     |
|  [`INFRA`](PARAM#infra)  | [`PROMETHEUS`](PARAM#prometheus)       | Prometheus Stack                 | 16    |
|  [`INFRA`](PARAM#infra)  | [`GRAFANA`](PARAM#grafana)             | Grafana Stack                    | 6     |
|  [`INFRA`](PARAM#infra)  | [`LOKI`](PARAM#loki)                   | Loki Logging Service             | 4     |
|   [`NODE`](PARAM#node)   | [`NODE_ID`](PARAM#node_id)             | Node Identity Parameters         | 5     |
|   [`NODE`](PARAM#node)   | [`NODE_DNS`](PARAM#node_dns)           | Node domain names & resolver     | 5     |
|   [`NODE`](PARAM#node)   | [`NODE_PACKAGE`](PARAM#node_package)   | Node Repo & Packages             | 5     |
|   [`NODE`](PARAM#node)   | [`NODE_TUNE`](PARAM#node_tune)         | Node Tuning & Kernel features    | 10    |
|   [`NODE`](PARAM#node)   | [`NODE_ADMIN`](PARAM#node_admin)       | Admin User & Credentials         | 7     |
|   [`NODE`](PARAM#node)   | [`NODE_TIME`](PARAM#node_time)         | Node Timezone, NTP, Crontabs     | 5     |
|   [`NODE`](PARAM#node)   | [`NODE_VIP`](PARAM#node_vip)           | Node Keepalived L2 VIP           | 8     |
|   [`NODE`](PARAM#node)   | [`HAPROXY`](PARAM#haproxy)             | HAProxy the load balancer        | 10    |
|   [`NODE`](PARAM#node)   | [`NODE_EXPORTER`](PARAM#node_exporter) | Node Monitoring Agent            | 3     |
|   [`NODE`](PARAM#node)   | [`PROMTAIL`](PARAM#promtail)           | Promtail logging Agent           | 4     |
| [`DOCKER`](PARAM#docker) | [`DOCKER`](PARAM#docker)               | Docker Daemon                    | 4     |
|   [`ETCD`](PARAM#etcd)   | [`ETCD`](PARAM#etcd)                   | ETCD DCS Cluster                 | 10    |
|  [`MINIO`](PARAM#minio)  | [`MINIO`](PARAM#minio)                 | MINIO S3 Object Storage          | 15    |
|  [`REDIS`](PARAM#redis)  | [`REDIS`](PARAM#redis)                 | Redis the key-value NoSQL cache  | 20    |
|  [`PGSQL`](PARAM#pgsql)  | [`PG_ID`](PARAM#pg_id)                 | PG Identity Parameters           | 11    |
|  [`PGSQL`](PARAM#pgsql)  | [`PG_BUSINESS`](PARAM#pg_business)     | PG Business Object Definition    | 12    |
|  [`PGSQL`](PARAM#pgsql)  | [`PG_INSTALL`](PARAM#pg_install)       | Install PG Packages & Extensions | 10    |
|  [`PGSQL`](PARAM#pgsql)  | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap)   | Init HA PG Cluster with Patroni  | 39    |
|  [`PGSQL`](PARAM#pgsql)  | [`PG_PROVISION`](PARAM#pg_provision)   | Create in-database objects       | 9     |
|  [`PGSQL`](PARAM#pgsql)  | [`PG_BACKUP`](PARAM#pg_backup)         | Set Backup Repo with pgBackRest  | 5     |
|  [`PGSQL`](PARAM#pgsql)  | [`PG_SERVICE`](PARAM#pg_service)       | Exposing service, bind vip, dns  | 9     |
|  [`PGSQL`](PARAM#pgsql)  | [`PG_EXPORTER`](PARAM#pg_exporter)     | PG Monitor agent for Prometheus  | 15    |

