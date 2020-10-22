# Provisioning [Draft]

Pigsty works on bare metal or virtual box.

[Ansible](https://docs.ansible.com/) is used for the pigsty provisioning procedure.



## Create New Cluster

Create new cluster is simple, first, define that cluster in your configuration file:

```bash
vi conf/all.yml
```

then, execute playbooks to 'materialize' your config into real-world.

```bash
./infra.yml
./initdb.yml
```



## Add Node

Adding new instance to existing cluster is simple, You just

```
vi conf/all.yml
```

Add new host definition to `all.children.<cluster>.hosts`

```yaml
    pg-test: # define cluster named 'pg-test'

      # - cluster configs - #
      vars:
        # basic settings
        pg_cluster: pg-test                 # define actual cluster name
        pg_version: 13                      # define installed pgsql version

# - cluster members - #
      hosts:
        10.10.10.11:
          ansible_host: node-1            # comment this if not access via ssh alias
          pg_role: primary                # initial role: primary & replica
          pg_seq: 1                       # instance sequence among cluster

        10.10.10.12:
          ansible_host: node-2            # comment this if not access via ssh alias
          pg_role: replica                # initial role: primary & replica
          pg_seq: 2                       # instance sequence among cluster


        #---------------------------------------------------------------------------#
        # ADD NEW NODE DEFINITION HERE
        #---------------------------------------------------------------------------#       
        10.10.10.13:
          ansible_host: node-3            # comment this if not access via ssh alias
          pg_role: replica                # initial role: primary & replica
          pg_seq: 3                       # instance sequence among cluster
        #---------------------------------------------------------------------------#

```

Then, play following playbook will setup the new instance for you.

```bash
./ins-add.yml -l 10.10.10.13
```

### Caution

Pigsty will abort if detecting any existing postgres instance running. But that action can be override by specify variable `pg_exists_action`

```bash
./ins-add.yml -e pg_exists_action=clean
```

And then existing postgres instance will be purged. Use with caution.

Consul instance also have similar safe guard:

```bash
./ins-add.yml -e dcs_exists_action=clean
```

This will remove any existing dcs instance during execution, use with caution.





## Remove Node

Remove instance from cluster is also simple, You just

```bash
./ins-del.yml -l 10.10.10.13
```

and that instance will be removed and purged.

Then you could remove that instance from your confguration.

You may wonder why we handle 'remove' action differently. i.e. (Not removing configuration first then execute playbook to reach the new status). That is removing existing database cluster is really dangerous, Which is reasonable to require a special manual operation.

