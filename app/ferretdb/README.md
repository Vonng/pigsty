# FerretDB

MongoDB API for PostgreSQL

```bash
cd app/ferretdb; docker compose up -d
```

```bash
make up         # pull up ferretdb with docker compose in minimal mode
make run        # launch ferretdb with docker , local data dir and external PostgreSQL
make view       # print ferretdb access point
make log        # tail -f ferretdb logs
make info       # introspect ferretdb with jq
make stop       # stop ferretdb container
make clean      # remove ferretdb container
make pull       # pull latest ferretdb image
make rmi        # remove ferretdb image
make save       # save ferretdb image to /tmp/ferretdb.tgz
make load       # load ferretdb image from /tmp
```


## Docker Compose 

```yaml
version: "3"
services:
  ferretdb:
    image: ghcr.io/ferretdb/ferretdb:latest
    container_name: ferretdb
    restart: on-failure
    ports:
      - 27017:27017
    command: ["-listen-addr=:27017", "-postgresql-url=postgres://dbuser_meta:DBUser.Meta@10.10.10.10:5432/meta"]
```


## Access

```bash
docker run --rm -it --network=ferretdb --entrypoint=mongosh mongo:5 mongodb://10.10.10.10:27017/
```


## Cheat Sheet

```bash
show dbs
use test
db.dropDatabase()
db.createCollection('posts')
db.posts.insert({
  title: 'Post One',
  body: 'Body of post one',
  category: 'News',
  tags: ['news', 'events'],
  user: {
    name: 'John Doe',
    status: 'author'
  },
  date: Date()
})

db.posts.find().limit(2).pretty()
db.posts.createIndex({ title: 'text' })
```
