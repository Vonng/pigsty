# minio

Launch minio (s3) service on 9000 & 9001, you can also use the built-in minio support.

```bash
cd ~/pigsty/app/minio ; make up
```

```bash
docker run -p 9000:9000 -p 9001:9001 \
  -e "MINIO_ROOT_USER=admin" \
  -e "MINIO_ROOT_PASSWORD=pigsty.minio" \
  minio/minio server /data --console-address ":9001"
```

visit http://10.10.10.10:9000 with user `admin` and password `pigsty.minio`

## Makefile

```bash
make up         # pull up minio with docker-compose
make run        # launch minio with docker
make view       # print minio access point
make log        # tail -f minio logs
make info       # introspect minio with jq
make stop       # stop minio container
make clean      # remove minio container
make pull       # pull latest minio image
make rmi        # remove minio image
make save       # save minio image to /tmp/docker/minio.tgz
make load       # load minio image from /tmp/docker/minio.tgz
```
