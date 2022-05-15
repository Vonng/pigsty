# PgAdmin4

## TL;DR

```bash
cd ~/pigsty/app/pgadmin
make up
make conf view
```


```bash
cd ~/pigsty/app/pgadmin ; docker-compose up -d
```

Visit [http://adm.pigsty](http://adm.pigsty) or http://10.10.10.10:8885 with:

username: `admin@pigsty.cc` and password: `pigsty`

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
