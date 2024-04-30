# PolarDB for PostgreSQL

[Polar PG](https://openpolardb.com/document?type=PolarDB-PG) -- Open Source RAC for PostgreSQL

PolarDB is a "so-called" national database in China... Which can be handy in certain scenarios.

> Pigsty 可用于管理并监控 PolarDB。根据 【[安全可靠测评结果公告（2023年第1号）](http://www.itsec.gov.cn/aqkkcp/cpgg/202312/t20231226_162074.html)】，附表三、集中式数据库。PolarDB 属于自主可控，安全可靠的国产信创数据库。


```bash
cd app/polardb; docker compose up -d
```

```bash
make up         # pull up polardb with docker compose in minimal mode
make run        # launch polardb with docker , local data dir and external PostgreSQL
make view       # print polardb access point
make log        # tail -f polardb logs
make info       # introspect polardb with jq
make stop       # stop polardb container
make clean      # remove polardb container
make pull       # pull latest polardb image
make rmi        # remove polardb image
make save       # save polardb image to /tmp/polardb.tgz
make load       # load polardb image from /tmp
```


-------------

## Docker Compose 

```yaml
version: "3"
services:
  polardb:
    image: polardb/polardb_pg_local_instance
    container_name: polardb
    restart: on-failure
    environment:
      POLARDB_PORT: ${POLARDB_PORT}
      POLARDB_USER: ${POLARDB_USER}
      POLARDB_PASSWORD: ${POLARDB_PASSWORD}
    volumes:
      - ${POLARDB_DATA}:/var/polardb
    ports:
      - 5532:5432
```


-------------

## How to Monitor PolarDB?

You can define PolarDB as a remote Postgres instance:

```yaml
all:
  children:
    infra:
      hosts: { 10.10.10.10: { infra_seq: 1 } }
      vars:
        pg_exporters:
          20001: { pg_cluster: pg-polar, pg_seq: 1, pg_host: 10.10.10.10 , pg_exporter_url: 'postgres://postgres:postgres@10.10.10.10:5532/postgres' }
```

And monitor it with Pigsty's observability stack with:

```bash
bin/pgmon-add pg-polar
```