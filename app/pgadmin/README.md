# PgAdmin4

PGADMIN4: https://www.pgadmin.org/

pgAdmin is the most popular and feature rich Open Source administration and development platform for PostgreSQL, 
the most advanced Open Source database in the world.

## TL;DR

Check default username/password in [`.env`](.env)

```bash
PGADMIN_PORT=admin@pigsty.cc
PGADMIN_USERNAME=admin@pigsty.cc
PGADMIN_PASSWORD=pigsty
```

Then launch pgadmin4 with

```bash
cd ~/pigsty/app/pgadmin
make up       # pull up pgadmin4 server
make conf     # load pigsty server list into pgadmin
```

Visit [http://adm.pigsty](http://adm.pigsty) or http://10.10.10.10:8885 with:

Public demo: http://adm.pigsty.cc

username: `admin@pigsty.cc` and password: `pigsty`

## Makefile

```bash
make up         # pull up pgadmin with docker-compose
make run        # launch pgadmin with docker
make view       # print pgadmin access point
make log        # tail -f pgadmin logs
make info       # introspect pgadmin with jq
make stop       # stop pgadmin container
make clean      # remove pgadmin container
make conf       # provision pgadmin with pigsty pg servers list 
make dump       # dump servers.json from pgadmin container
make pull       # pull latest pgadmin image
make rmi        # remove pgadmin image
make save       # save pgadmin image to /tmp/pgadmin.tgz
make load       # load pgadmin image from /tmp
```
