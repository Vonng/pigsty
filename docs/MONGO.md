# MongoDB (FerretDB)

> Pigsty allow you to add MongoDB compatibility to PostgreSQL with [FerretDB](https://ferretdb.io) 

 
----------------

## Playbook

There's a built-in playbook: [`mongo.yml`](https://github.com/Vonng/pigsty/blob/master/mongo.yml) for installing the FerretDB cluster. But you have to [define](#configuration) it first.

```bash
./mongo.yml -l ferret   # install ferretdb cluster on group 'ferret'
```

This playbook is consist of following sub-tasks:

- mongo_check     : check mongo identity
- mongo_dbsu      : create os user mongod
- mongo_install   : install mongo/ferretdb rpm
- mongo_config    : config mongo/ferretdb
  - mongo_cert    : issue mongo/ferretdb ssl certs
- mongo_launch    : launch mongo/ferretdb service
- mongo_register  : register mongo/ferretdb to prometheus


----------------

## Configuration

You have to define a Mongo (FerretDB) cluster before deploying it. There are some [parameters](#parameters) for it:

```yaml
ferret:
  hosts:
    10.10.10.45: { mongo_seq: 1 }
    10.10.10.46: { mongo_seq: 2 }
    10.10.10.47: { mongo_seq: 3 }
  vars:
    mongo_cluster: ferret
    mongo_pgurl: 'postgres://test:test@10.10.10.3:5436/test'
```

The `mongo_cluster` and `mongo_seq` are required identity parameters, you also need `mongo_pgurl` to specify the underlying PostgreSQL URL for FerretDB.




----------------

## Administration

**Install mongosh on bare metal**

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

Then you connect to FerretDB cluster and issue mongo command with `mongosh`

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

The `mongosh` commands will be translated into `SQL` commands and run in underlying PostgreSQL:

```bash
use test
-- CREATE SCHEMA test;

db.dropDatabase()
-- DROP SCHEMA test;

db.createCollection('posts')
-- CREATE TABLE posts(_data JSONB,...)

db.posts.insert({
title: 'Post One',body: 'Body of post one',category: 'News',tags: ['news', 'events'],
user: {name: 'John Doe',status: 'author'},date: Date()}
)
-- INSERT INTO posts VALUES(...);

db.posts.find().limit(2).pretty()
-- SELECT * FROM posts LIMIT 2;

db.posts.createIndex({ title: 1 })
-- CREATE INDEX ON posts(_data->>'title');
```

You can also connect to ferretdb with a different user and password.

```bash
mongosh 'mongodb://test:test@10.10.10.45:27017/test?authMechanism=PLAIN'
```



----------------

## Dashboards

There is one dashboard for [`MONGO`](MONGO) module for now.

[Mongo Overview](https://demo.pigsty.cc/d/mongo-overview): Overview of a Mongo/FerretDB cluster

<details><summary>Mongo Overview Dashboard</summary>

[![mongo-overview](https://github.com/Vonng/pigsty/assets/8587410/406fc2ad-3935-4da9-b77c-2485afb57af8)](https://demo.pigsty.cc/d/mongo-overview)

</details><br>



----------------

## Parameters

There are 9 parameters in [`MONGO`](MONGO) module.


| Parameter             |  Type  | Level | Comment                                      |
|-----------------------|:------:|:-----:|----------------------------------------------|
| `mongo_seq`           |  int   |   I   | mongo instance identifier, REQUIRED          |
| `mongo_cluster`       | string |   C   | mongo cluster name, MONGO by default         |
| `mongo_pgurl`         | pgurl  |  C/I  | underlying postgres URL for ferretdb         |
| `mongo_ssl_enabled`   |  bool  |   C   | mongo/ferretdb ssl enabled, false by default |
| `mongo_listen`        |   ip   |   C   | mongo listen address, empty for all addr     |
| `mongo_port`          |  port  |   C   | mongo service port, 27017 by default         |
| `mongo_ssl_port`      |  port  |   C   | mongo tls listen port, 27018 by default      |
| `mongo_exporter_port` |  port  |   C   | mongo exporter port, 9216 by default         |
| `mongo_extra_vars`    | string |   C   | extra environment variables for MONGO server |

```yaml
# mongo_cluster:        #CLUSTER  # mongo cluster name, required identity parameter
# mongo_seq: 0          #INSTANCE # mongo instance seq number, required identity parameter
# mongo_pgurl: 'postgres:///'     # mongo/ferretdb underlying postgresql url, required
mongo_ssl_enabled: false          # mongo/ferretdb ssl enabled, false by default
mongo_listen: ''                  # mongo/ferretdb listen address, '' for all addr
mongo_port: 27017                 # mongo/ferretdb listen port, 27017 by default
mongo_ssl_port: 27018             # mongo/ferretdb tls listen port, 27018 by default
mongo_exporter_port: 9216         # mongo/ferretdb exporter port, 9216 by default
mongo_extra_vars: ''              # extra environment variables for mongo/ferretdb
```