# PG Exporter

This is an example of running pg_exporter inside docker

```bash
cd ~/pigsty/app/pg_exporter ; docker compose up -d
```

```bash
make up         # pull up pg_exporter with docker compose
make run        # launch pg_exporter with docker
make view       # curl pg_exporter metrics
make log        # tail -f pg_exporter logs
make info       # introspect pg_exporter with jq
make stop       # stop pg_exporter container
make clean      # remove pg_exporter container
make pull       # pull latest pg_exporter image
make rmi        # remove pg_exporter image
make save       # save pg_exporter image to /tmp/pg_exporter.tgz
make load       # load pg_exporter image from /tmp
```


## Usage

Replace bare metal pg_exporter with docker: 

```bash
systemctl stop pg_exporter # stop existing pg_exporter on bare metal
docker run --init --name pg_exporter -p 9630:9630 \
    -e PG_EXPORTER_URL='postgres://dbuser_monitor:DBUser.Monitor@10.10.10.10:5432/postgres?sslmode=disable' \
    -e PG_EXPORTER_AUTO_DISCOVERY='true' \
    vonng/pg_exporter
```

```bash
curl http://127.0.0.1:9630/metrics  # get metrics from pg_exporter inside docker
```
