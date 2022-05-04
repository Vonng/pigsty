# PGWEB

## TL;DR
```bash
cd ~/pigsty/app/pgweb
docker-compose up -d
```

Visit [http://cli.pigsty](http://cli.pigsty) with:

Try URL with

```bash
postgres://dbuser_meta:DBUser.Meta@10.10.10.10:5432/meta?sslmode=disable
postgres://test:test@10.10.10.11:5432/test?sslmode=disable
```



## Scripts

```yaml
version: "3"
services:
  pgweb:
    container_name: pgweb
    image: sosedoff/pgweb
    restart: unless-stopped
    ports:
      - "8886:8081"
```

```bash
docker run --init --name pgweb --restart always --detach --publish 8886:8081 sosedoff/pgweb
```

**Remove Container**

```bash
docker stop pgweb; docker rm pgweb  # remove
```

