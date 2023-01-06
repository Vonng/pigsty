# Migration Manual: {{ src_cls }}.{{ src_db }}


## TL;DR


```bash
# this script will setup migration context with env vars
. {{ dir_path }}/activate

# these scripts are used for check src cluster status
# and help generating new cluster definition in pigsty
./check-user     # check src users
./check-db       # check src databases
./check-hba      # check src hba rules
./check-repl     # check src replica identities
./check-misc     # check src special objects

# these scripts are used for building logical replication
# between existing src cluster and pigsty managed dst cluster
# schema, data will be synced in realtime, except for sequences
./copy-schema    # copy schema to dest
./create-pub     # create publication on src
./create-sub     # create subscription on dst
./copy-progress  # print logical replication progress
./copy-diff      # quick src & dst diff by counting tables 

# these scripts will run in an online migration, which will
# stop src cluster, copy sequence numbers (which is not synced with logical replication)
# you have to reroute you app traffic according to your access method (dns,vip,haproxy,pgbouncer,etc...)
# then perform cleanup to drop subscription and publication
./copy-seq [n]   # sync sequence numbers, if n is given, an additional shift will applied
#./disable-src   # restrict src cluster access to admin node & new cluster (YOUR IMPLEMENTATION)
#./re-routing    # ROUTING APPLICATION TRAFFIC FROM SRC TO DST!            (YOUR IMPLEMENTATION)
./drop-sub       # drop subscription on dst after migration
./drop-pub       # drop publication on src after migration
```


**Caveats**

You can use `./copy-seq 1000` to advance all sequence by a number (e.g. `1000`) after syncing sequences.
Which may prevent potential serial primary key conflict in new clusters.

You have to implement your own `./re-routing` script to route your application traffic from src to dst.
Since we don't know how your traffic is routed (e.g dns, vip, haproxy or pgbouncer).
Of course, you can always to that by hand...

You have to implement you own `./disable-src` script to restrict src cluster.
You can do that by changing HBA rules & reload (recommended), or just shuttling down postgres, pgbouncer or haproxy...

