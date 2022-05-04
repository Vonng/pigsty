# Bytebase

Schema Migrator for PostgreSQL

## TL;DR

```bash
cd app/bytebase
docker-compose up -d
```

Visit http://10.10.10.10:8887 or [http://ddl.pigsty](http://ddl.pigsty)

## Database

By default, following database & user are used:

```yaml
# postgres://dbuser_bytebase:DBUser.Bytebase@10.10.10.10:5432/bytebase
- { name: bytebase,   owner: dbuser_bytebase   , revokeconn: true , comment: bytebase primary database }
- { name: dbuser_bytebase , password: DBUser.Bytebase ,pgbouncer: true , roles: [ dbrole_admin ] , comment: admin user for bytebase database }
```

## Scripts

```yaml
version: "3"
services:
  bytebase:
    container_name: bytebase
    image: bytebase/bytebase:1.0.4
    restart: unless-stopped
    ports:
      - "8887:8887"
    command: |
      --host http://ddl.pigsty --port 8887 --data /var/opt/bytebase
```

```bash
mkdir -p /data/bytebase/data;
docker run --init --name bytebase \
    --restart always --detach \
    --publish 8887:8887 \
    --volume /data/bytebase/data:/var/opt/bytebase \
    bytebase/bytebase:1.0.4 \
    --data /var/opt/bytebase \
    --host http://ddl.pigsty \
    --port 8887 \
```

```bash
docker stop bytebase; docker rm bytebase;
```

## Use Existing PGSQL

if you wish to user an external PostgreSQL, drop extension pg_stat_statements & pg_repack, then add following lines:

```bash
--pg postgres://dbuser_bytebase:DBUser.Bytebase@10.10.10.10:5432/bytebase
```
