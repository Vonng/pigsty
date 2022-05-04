# PgAdmin4

## TL;DR

```bash
cd ~/pigsty/app/pgadmin
docker-compose up -d
```

Visit [http://adm.pigsty](http://adm.pigsty) or http://10.10.10.10:8885 with:

* username: `admin@pigsty.cc` 
* password: `pigsty`


Load Pigsty Postgres Instance List:

```bash
docker cp ~/.servers.json pgadmin:/tmp/servers.json;
docker cp ~/.pgpass pgadmin:/pgpass;  
docker exec -u 0 -it pgadmin chown pgadmin /tmp/servers.json /pgpass;
docker exec -it pgadmin /venv/bin/python3 /pgadmin4/setup.py --user admin@pigsty.cc --load-servers /tmp/servers.json
```


## Script

```yaml
version: "3"
services:
  pgadmin:
    container_name: pgadmin
    image: dpage/pgadmin4
    restart: unless-stopped
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@pigsty.cc
      PGADMIN_DEFAULT_PASSWORD: pigsty
    ports:
      - "8885:80"
```

```bash
docker run --init --name pgadmin \
    --restart always --detach \
    --publish 8885:80 \
    -e PGADMIN_DEFAULT_EMAIL=admin@pigsty.cc \
    -e PGADMIN_DEFAULT_PASSWORD=pigsty \
    dpage/pgadmin4
```

**Remove Container**

```bash
docker stop pgadmin; docker rm pgadmin  # remove
docker exec -u 0 -it pgadmin /bin/sh    # introspect
```


## Config Dump/Load 

import `servers.json` from `~/.servers.json` and `./pgpass`

```bash
docker cp ~/.servers.json pgadmin:/tmp/servers.json ;
docker cp ~/.pgpass pgadmin:/pgpass ;  
docker exec -u 0 -it pgadmin chown pgadmin /tmp/servers.json /pgpass
docker exec -it pgadmin /venv/bin/python3 /pgadmin4/setup.py --user admin@pigsty.cc --load-servers /tmp/servers.json
```


export pgadmin `servers.json` to `/tmp`

```bash
docker exec -it pgadmin /venv/bin/python3 /pgadmin4/setup.py --user admin@pigsty.cc --dump-servers /tmp/servers.json
docker cp pgadmin:/tmp/servers.json /tmp/servers.json
```

