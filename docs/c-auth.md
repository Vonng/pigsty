# HBA

PostgreSQL provides standard access control mechanisms: [authentication](c-auth.md) (Authentication) and [privileges](c-privilege.md) (Privileges), both based on the [role](c-user.md) (Role) and [user](c-user. md) (User) systems. Pigsty provides an out-of-the-box access control model that covers the security needs of most scenarios.

This article introduces the authentication system used by Pigsty with the HBA mechanism. hba stands for Host Based Authentication and can be thought of as an IP black and white list.

## HBA configuration method

In Pigsty, the HBA of all instances is generated from the configuration file, and the final generated HBA rules vary depending on the role of the instance (`pg_role`).
Pigsty's HBA is controlled by the following variables.

* `pg_hba_rules`: Environmentally uniform HBA rules
* `pg_hba_rules_extra`: Instance- or cluster-specific HBA rules
* `pgbouncer_hba_rules`: HBA rules used by linked pools
* `pgbouncer_hba_rules_extra`: instance- or cluster-specific HBA rules for linked pools

Each variable is an array of rules in the following style.

```yaml
- title: allow intranet admin password access
  role: common
  rules:
    - host    all     +dbrole_admin               10.0.0.0/8          md5
    - host    all     +dbrole_admin               172.16.0.0/12       md5
    - host    all     +dbrole_admin               192.168.0.0/16      md5
```


## Role-based HBA

The HBA rule group with `role = common` will be installed to all instances.
while other fetch values, such as (`role : primary`) will only be installed to instances with `pg_role = primary`.
Thus, users can define flexible HBA rules through the role system.

As a **special exception**, the HBA rule for `role: offline` will be installed to instances with `pg_role == 'offline'`, in addition to instances with `pg_role == 'offline'`.
It will also be installed to instances where `pg_offline_query == true`.

The HBA rendering priority rules are.

* hard_coded_rules Global hard coded rules
* pg_hba_rules_extra.common Cluster common rules
* pg_hba_rules_extra.pg_role Cluster role rules
* pg_hba_rules.pg_role Global role rules
* pg_hba_rules.offline Cluster offline rules
* pg_hba_rules_extra.offline Global offline rules
* pg_hba_rules.common Global common rules


## Default HBA rules

Under the default configuration, the master and slave libraries use the following HBA rules.

* Super user access with local OS authentication
* Other users can access from local with password
* Replicated users can access by password from the LAN segment
* Monitoring users can access locally
* Everyone can access with a password on the meta-node
* Administrators can access via password from the LAN
* Everyone can access from the intranet with a password
* Read and write users (production business accounts) can be accessed locally (link pool)
  (some access control is transferred to the link pool for processing)
* On the slave: read-only users (individuals) can access from the local (link pool).
  (implies that read-only user connections are denied on the master)
* On instances with `pg_role == 'offline'` or with `pg_offline_query == true`, HBA rules that allow access to `dbrole_offline` grouped users are added.

<details>

```ini
#==============================================================#
# Default HBA
#==============================================================#
# allow local su with ident"
local   all             postgres                               ident
local   replication     postgres                               ident

# allow local user password access
local   all             all                                    md5

# allow local/intranet replication with password
local   replication     replicator                              md5
host    replication     replicator         127.0.0.1/32         md5
host    all             replicator         10.0.0.0/8           md5
host    all             replicator         172.16.0.0/12        md5
host    all             replicator         192.168.0.0/16       md5
host    replication     replicator         10.0.0.0/8           md5
host    replication     replicator         172.16.0.0/12        md5
host    replication     replicator         192.168.0.0/16       md5

# allow local role monitor with password
local   all             dbuser_monitor                          md5
host    all             dbuser_monitor      127.0.0.1/32        md5

#==============================================================#
# Extra HBA
#==============================================================#
# add extra hba rules here




#==============================================================#
# primary HBA
#==============================================================#


#==============================================================#
# special HBA for instance marked with 'pg_offline_query = true'
#==============================================================#



#==============================================================#
# Common HBA
#==============================================================#
#  allow meta node password access
host    all     all                         10.10.10.10/32      md5

#  allow intranet admin password access
host    all     +dbrole_admin               10.0.0.0/8          md5
host    all     +dbrole_admin               172.16.0.0/12       md5
host    all     +dbrole_admin               192.168.0.0/16      md5

#  allow intranet password access
host    all             all                 10.0.0.0/8          md5
host    all             all                 172.16.0.0/12       md5
host    all             all                 192.168.0.0/16      md5

#  allow local read/write (local production user via pgbouncer)
local   all     +dbrole_readonly                                md5
host    all     +dbrole_readonly           127.0.0.1/32         md5





#==============================================================#
# Ad Hoc HBA
#===========================================================
```

</details>




### Modify HBA rules

HBA rules are automatically generated when the cluster/instance is initialized.

Users can modify and apply new HBA rules after the database cluster/instance is created and running by scripting.

```bash
. /pgsql.yml -t pg_hba # Specify the target cluster via -l
```
When the database cluster directory is destroyed and rebuilt, the new copy will have the same HBA rules as the cluster master
(because the slave's dataset cluster directory is a binary copy of the master, and the HBA rules are also in the dataset cluster directory)
This is not usually the behavior expected by users. You can use the above command to perform HBA repair for a specific instance.




## Pgbouncer HBA

In Pigsty, Pgbouncer also uses HBA for access control, in much the same way as Postgres HBA

* `pgbouncer_hba_rules`: the HBA rules used by the link pool
* `pgbouncer_hba_rules_extra`: instance- or cluster-specific HBA rules for linked pools

The default Pgbouncer HBA rules allow password access from local and intranet

```bash
pgbouncer_hba_rules:                          # pgbouncer host-based authentication rules
  - title: local password access
    role: common
    rules:
      - local  all          all                                     md5
      - host   all          all                     127.0.0.1/32    md5

  - title: intranet password access
    role: common
    rules:
      - host   all          all                     10.0.0.0/8      md5
      - host   all          all                     172.16.0.0/12   md5
      - host   all          all                     192.168.0.0/16  md5


```