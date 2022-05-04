# PostgREST


## TL;DR
```bash
cd ~/pigsty/app/pgweb
docker-compose up -d
```

Check http://10.10.10.10:8884 for list of available apis


## Scripts

```yaml
version: "3"
services:
  postgrest:
    container_name: postgrest
    image: postgrest/postgrest
    restart: always
    environment:
      PGRST_DB_URI: postgres://dbuser_dba:DBUser.DBA@10.10.10.10:5432/meta
      PGRST_DB_SCHEMA: pigsty
      PGRST_DB_ANON_ROLE: dbuser_dba
      PGRST_SERVER_PORT: 8884
      PGRST_JWT_SECRET: some-random-secret
    ports:
      - "8884:8884"
```

**Manual Launch**

```bash
docker run --init --name postgrest --restart always --detach --net=host -p 8082:8082 \
  -e PGRST_DB_URI="postgres://dbuser_dba:DBUser.DBA@10.10.10.10/meta" -e PGRST_DB_SCHEMA="pigsty" -e PGRST_DB_ANON_ROLE="dbuser_dba" -e PGRST_SERVER_PORT=8082 -e PGRST_JWT_SECRET=haha \
  postgrest/postgrest
```

**Remove Container**

```bash
docker stop postgrest; docker rm postgrest
```

