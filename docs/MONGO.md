# MongoDB (FerretDB)

> Pigsty allows you to add MongoDB compatibility to PostgreSQL with [FerretDB](https://ferretdb.io) 

[Configuration](#configuration) | [Administration](#administration) | [Playbook](#playbook) | [Dashboard](#dashboard) | [Parameter](#parameter)


----------------

## Overview

[MongoDB](https://www.mongodb.com/licensing/server-side-public-license/faq) was once a stunning technology, allowing developers to cast aside the "schema constraints" of relational databases and quickly build applications. However, over time, MongoDB abandoned its open-source nature, changing its license to SSPL, which made it unusable for many open-source projects and early commercial projects. Most MongoDB users actually do not need the advanced features provided by MongoDB, but they do need an easy-to-use open-source document database solution. To fill this gap, FerretDB was born.

PostgreSQL's JSON functionality is already well-rounded: binary storage JSONB, GIN arbitrary field indexing, various JSON processing functions, JSON PATH, and JSON Schema, it has long been a fully-featured, high-performance document database. However, providing alternative functionality and direct emulation are not the same. FerretDB can provide a smooth transition to PostgreSQL for applications driven by MongoDB drivers.

Pigsty provided a [Docker-Compose](https://github.com/Vonng/pigsty/tree/master/app) support for FerretDB in 1.x, and [native deployment](https://pigsty.io/docs/mongo) support since v2.3. As an optional feature, it greatly benefits the enrichment of the PostgreSQL ecosystem. The Pigsty community has already become a partner with the FerretDB community, and we shall find more opportunities to work together in the future.



----------------

## Configuration

You have to define a Mongo (FerretDB) cluster before deploying it. There are some [parameters](#parameter) for it:

Here's an example to utilize the default single-node `pg-meta` cluster as MongoDB:

```yaml
ferret:
  hosts: { 10.10.10.10: { mongo_seq: 1 } }
  vars:
    mongo_cluster: ferret
    mongo_pgurl: 'postgres://dbuser_meta:DBUser.Meta@10.10.10.10:5432/meta'
```

The `mongo_cluster` and `mongo_seq` are required identity parameters, you also need `mongo_pgurl` to specify the underlying PostgreSQL URL for FerretDB.

You can also setup multiple replicas and bind an L2 VIP to them, utilize the underlying HA Postgres cluster through [Services](PGSQL-SVC)

```yaml
mongo-test:
  hosts:
    10.10.10.11: { mongo_seq: 1 }
    10.10.10.12: { mongo_seq: 2 }
    10.10.10.13: { mongo_seq: 3 }
  vars:
    mongo_cluster: mongo-test
    mongo_pgurl: 'postgres://test:test@10.10.10.11:5436/test'
    vip_enabled: true
    vip_vrid: 128
    vip_address: 10.10.10.99
    vip_interface: eth1
```



----------------

## Administration


### Create Cluster

To create a [defined](#configuration) mongo/ferretdb cluster, run the [`mongo.yml`](#mongoyml) playbook:

```bash
./mongo.yml -l ferret    # install mongo/ferretdb on group 'ferret'
```

Since FerretDB saves all data in underlying PostgreSQL, it is safe to run the playbook multiple times.


### Remove Cluster

To remove a mongo/ferretdb cluster, run the [`mongo.yml`](#mongoyml) playbook with `mongo_purge` subtask and `mongo_purge` flag.

```bash
./mongo.yml -e mongo_purge=true -t mongo_purge
```


### Install mongosh

```bash
cat > /etc/yum.repos.d/mongo.repo <<EOF
[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/7.0/x86_64/
gpgcheck=0
enabled=1
EOF

yum install -y mongodb-mongosh

# or just install via rpm & links
rpm -ivh https://mirrors.tuna.tsinghua.edu.cn/mongodb/yum/el7/RPMS/mongodb-mongosh-1.9.1.x86_64.rpm
```

### FerretDB Connect

You can connect to FerretDB with any MongoDB driver using the MongoDB connection string, here we use the `mongosh` command line tool installed above as an example:

```bash
mongosh 'mongodb://dbuser_meta:DBUser.Meta@10.10.10.10:27017?authMechanism=PLAIN'
mongosh 'mongodb://test:test@10.10.10.11:27017/test?authMechanism=PLAIN'
```

Since Pigsty uses the `scram-sha-256` as the default auth method, you must use the `PLAIN` auth mechanism to connect to FerretDB. Check [FerretDB: authentication](https://docs.ferretdb.io/security/authentication/) for details.

You can also use other **PostgreSQL** users to connect to FerretDB, just specify them in the connection string:

```bash
mongosh 'mongodb://dbuser_dba:DBUser.DBA@10.10.10.10:27017?authMechanism=PLAIN'
```


----------------

## Quick Start

You can connect to FerretDB, and pretend it is a MongoDB cluster.

```bash
$ mongosh 'mongodb://dbuser_meta:DBUser.Meta@10.10.10.10:27017?authMechanism=PLAIN'
```

The MongoDB commands will be translated into `SQL` commands and run in underlying PostgreSQL:

```bash
use test                            # CREATE SCHEMA test;
db.dropDatabase()                   # DROP SCHEMA test;
db.createCollection('posts')        # CREATE TABLE posts(_data JSONB,...)
db.posts.insert({                   # INSERT INTO posts VALUES(...);
    title: 'Post One',body: 'Body of post one',category: 'News',tags: ['news', 'events'],
    user: {name: 'John Doe',status: 'author'},date: Date()}
)
db.posts.find().limit(2).pretty()   # SELECT * FROM posts LIMIT 2;
db.posts.createIndex({ title: 1 })  # CREATE INDEX ON posts(_data->>'title');
```

If you are not familiar with MongoDB, here is a quick start: [Perform CRUD Operations with MongoDB Shell](https://www.mongodb.com/docs/mongodb-shell/crud/)

To generate some load, you can run a simple benchmark with `mongosh`:

```bash
cat > benchmark.js <<'EOF'
const coll = "testColl";
const numDocs = 10000;

for (let i = 0; i < numDocs; i++) {  // insert
  db.getCollection(coll).insert({ num: i, name: "MongoDB Benchmark Test" });
}

for (let i = 0; i < numDocs; i++) {  // select
  db.getCollection(coll).find({ num: i });
}

for (let i = 0; i < numDocs; i++) {  // update
  db.getCollection(coll).update({ num: i }, { $set: { name: "Updated" } });
}

for (let i = 0; i < numDocs; i++) {  // delete
  db.getCollection(coll).deleteOne({ num: i });
}
EOF

mongosh 'mongodb://dbuser_meta:DBUser.Meta@10.10.10.10:27017?authMechanism=PLAIN' benchmark.js
```

You can check supported Mongo commands on [ferretdb: supported commands](https://docs.ferretdb.io/reference/supported-commands/), and there may be some differences between MongoDB and FerretDB. Check [ferretdb: differences](https://docs.ferretdb.io/diff/) for details, it's not a big deal for sane usage.



----------------

## Playbook

There's a built-in playbook [`mongo.yml`](#mongoyml) for installing the FerretDB cluster. But you have to [define](#configuration) it first.


### `mongo.yml`

[`mongo.yml`](https://github.com/Vonng/pigsty/blob/master/mongo.yml): Install MongoDB/FerretDB on the target host.

This playbook consists of the following sub-tasks:

- `mongo_check`     : check mongo identity
- `mongo_dbsu`      : create os user mongod
- `mongo_install`   : install mongo/ferretdb rpm
- `mongo_purge`     : purge mongo/ferretdb
- `mongo_config`    : config mongo/ferretdb
  - `mongo_cert`    : issue mongo/ferretdb ssl certs
- `mongo_launch`    : launch mongo/ferretdb service
- `mongo_register`  : register mongo/ferretdb to prometheus



----------------

## Dashboard

There is one dashboard for [`MONGO`](MONGO) module for now.

### Mongo Overview

[Mongo Overview](https://demo.pigsty.cc/d/mongo-overview): Overview of a Mongo/FerretDB cluster

[![mongo-overview.jpg](https://repo.pigsty.cc/img/mongo-overview.jpg)](https://demo.pigsty.cc/d/mongo-overview)



----------------

## Parameter

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