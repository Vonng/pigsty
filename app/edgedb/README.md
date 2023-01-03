# edgedb

Launch edgedb service on port 3001

```bash
cd ~/pigsty/app/edgedb; make up
```

```bash
docker run -p 5656:5656 \
  --name edgedb \
  -e "EDGEDB_SERVER_PASSWORD=edge" \
  -e "EDGEDB_SERVER_SECURITY=insecure_dev_mode" \
  -e "EDGEDB_SERVER_BACKEND_DSN=postgres://dbuser_meta:DBUser.Meta@10.10.10.10:5432/meta" \
  -v /data/edgedb:/var/lib/edgedb/data \
  -d edgedb/edgedb
```

```bash
make up         # pull up edgedb with docker-compose
make run        # launch edgedb with docker
make view       # print edgedb access point
make log        # tail -f edgedb logs
make info       # introspect edgedb with jq
make stop       # stop edgedb container
make clean      # remove edgedb container
make pull       # pull latest edgedb image
make rmi        # remove edgedb image
make save       # save edgedb image to /tmp/edgedb.tgz
make load       # load edgedb image from /tmp
```


## Usage

Check edge quick start for details: https://www.edgedb.com/docs/intro/quickstart

```bash
# run edgedb-cli , default password is 'edge'
docker exec -it edgedb edgedb -H 127.0.0.1 -P 5656 --password --tls-security=insecure
```

