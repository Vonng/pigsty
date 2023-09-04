# MongoDB (FerretDB)

> 使用 [FerretDB](https://ferretdb.io) 为 PostgreSQL 添加 MongoDB 兼容的协议支持！ [配置](#配置) | [管理](#管理) | [剧本](#剧本) | [监控](#监控) | [参数](#参数)


----------------

## 配置

在部署 Mongo (FerretDB) 集群前，你需要先在配置清单中使用相关[参数](#参数)定义好它。 

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

这里 `mongo_cluster` 与 `mongo_seq` 属于不可或缺的身份参数，对于 FerretDB 来说，还有一个必须提供的参数是 `mongo_pgurl`。





----------------

## 管理


### 创建Mongo集群

在[配置清单](CONFIG)中[定义](#配置)好MONGO集群后，您可以使用以下命令完成安装。

```bash
./mongo.yml -l ferret   # 在 ferret 分组上安装“MongoDB/FerretDB”
```


**在裸机上安装 MongoSH 客户端工具**

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

**连接到 FerretDB，并使用mongosh执行增删改查命令：**

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

这些 MongoDB 命令会被翻译为对应的 SQL 在 PostgreSQL 上执行：

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

您也可以使用其他的 PostgreSQL 用户密码来访问 FerretDB：

```bash
mongosh 'mongodb://test:test@10.10.10.45:27017/test?authMechanism=PLAIN'
```



----------------

## 剧本

Pigsty 提供了一个内置的剧本： [`mongo.yml`](mongoyml)，用于在节点上安装 FerretDB 集群。

### `mongo.yml`

该剧本由以下子任务组成：

- `mongo_check`   ：检查 mongo 身份参数
- `mongo_dbsu`    ：创建操作系统用户 mongod
- `mongo_install` ：安装 mongo/ferretdb RPM包
- `mongo_config`  ：配置 mongo/ferretdb
  - `mongo_cert`    ：签发 mongo/ferretdb SSL证书
- `mongo_launch`  ：启动 mongo/ferretdb 服务
- `mongo_register`：将 mongo/ferretdb 注册到 Prometheus 监控中




----------------

## 监控

MONGO 模块提供了一个简单的监控面板：Mongo Overview

### Mongo Overview

[Mongo Overview](https://demo.pigsty.cc/d/mongo-overview): Mongo/FerretDB 集群概览

这个监控面板提供了关于 FerretDB 的基本监控指标，因为 FerretDB 底层使用了 PostgreSQL，所以更多的监控指标，还请参考 PostgreSQL 监控。

[![mongo-overview](https://github.com/Vonng/pigsty/assets/8587410/406fc2ad-3935-4da9-b77c-2485afb57af8)](https://demo.pigsty.cc/d/mongo-overview)





----------------

## 参数

[`MONGO`](MONGO) 模块中提供了9个相关的配置参数，如下表所示：

| 参数                    |   类型   | 级别  | 注释                                 |
|-----------------------|:------:|:---:|------------------------------------|
| `mongo_seq`           |  int   |  I  | mongo 实例号，必选身份参数                   |
| `mongo_cluster`       | string |  C  | mongo 集群名，必选身份参数                   |
| `mongo_pgurl`         | pgurl  | C/I | mongo/ferretdb 底层使用的 PGURL 连接串，必选  |
| `mongo_ssl_enabled`   |  bool  |  C  | mongo/ferretdb 是否启用SSL？默认为 `false` |
| `mongo_listen`        |   ip   |  C  | mongo 监听地址，默认留控则监听所有地址             |
| `mongo_port`          |  port  |  C  | mongo 服务端口，默认使用 27017              |
| `mongo_ssl_port`      |  port  |  C  | mongo TLS 监听端口，默认使用 27018          |
| `mongo_exporter_port` |  port  |  C  | mongo exporter 端口，默认使用 9216        |
| `mongo_extra_vars`    | string |  C  | MONGO 服务器额外环境变量，默认为空白字符串           |

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