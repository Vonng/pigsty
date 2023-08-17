# FerretDB

A truly Open Source MongoDB alternative, built on Postgres.

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
    environment:
      - FERRETDB_POSTGRESQL_URL=postgres://dbuser_meta:DBUser.Meta@10.10.10.10:5432/meta
      - FERRETDB_LISTEN_ADDR=:27017
    ports:
      - 27017:27017                     # expose default mongodb port
      #- 28088:8080                      # expose metrics port
```



## MongoDB Cli

**Use mongosh inside container**

```bash
docker run --rm -it --network=ferretdb --entrypoint=mongosh mongo:5 mongodb://10.10.10.10:27017/
```

**Or Install it on bare metal**

```bash
cat > /etc/yum.repos.d/mongo.repo <<EOF
[mongodb-org-6.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/6.0/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc
EOF

yum install -y mongodb-mongosh

# or just install via rpm & links
rpm -ivh https://mirrors.tuna.tsinghua.edu.cn/mongodb/yum/el7/RPMS/mongodb-mongosh-1.9.1.x86_64.rpm
```


**Examples**

```bash
$ mongosh mongodb://dbuser_meta:DBUser.Meta@127.0.0.1:27017

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
db.posts.createIndex({ title: 1 })
```
