# 使用TimescaleDB存储Prometheus数据

您可以使用 postgres 作为 Prometheus 后端使用的远程存储数据库。

虽然这并不是推荐的行为，但这是了解Pigsty部署系统使用方式的好机会。


## 准备Postgres数据库

```bash
vi pigsty.yml # 取消注释DB/User定义：dbuser_prometheus  prometheus

pg_databases:                           # define business users/roles on this cluster, array of user definition
  - { name: prometheus, owner: dbuser_prometheus , revokeconn: true, comment: prometheus primary database }
pg_users:                           # define business users/roles on this cluster, array of user definition
  - {name: dbuser_prometheus , password: DBUser.Prometheus ,pgbouncer: true , createrole: true,  roles: [dbrole_admin], comment: admin user for prometheus database }
```

创建 Prometheus 业务数据库与业务用户。

```bash
bin/createuser  pg-meta  dbuser_prometheus
bin/createdb    pg-meta  prometheus
```

检查数据库可用性并创建扩展

```bash
psql postgres://dbuser_prometheus:DBUser.Prometheus@10.10.10.10:5432/prometheus -c 'CREATE EXTENSION timescaledb;'
```



## 配置Promscale

在元节点上执行以下命令安装 `promscale`

```bash
yum install -y promscale 
```

如果默认软件包中没有，可以直接下载：

```bash
wget https://github.com/timescale/promscale/releases/download/0.6.1/promscale_0.6.1_Linux_x86_64.rpm
sudo rpm -ivh promscale_0.6.1_Linux_x86_64.rpm
```

编辑 `promscale` 的配置文件 `/etc/sysconfig/promscale.conf`

```bash
PROMSCALE_DB_HOST="127.0.0.1"
PROMSCALE_DB_NAME="prometheus"
PROMSCALE_DB_PASSWORD="DBUser.Prometheus"
PROMSCALE_DB_PORT="5432"
PROMSCALE_DB_SSL_MODE="disable"
PROMSCALE_DB_USER="dbuser_prometheus"
```

最后启动promscale，它会访问安装有 `timescaledb` 的数据库实例，并创建所需的schema

```bash
# launch 
cat /usr/lib/systemd/system/promscale.service
systemctl start promscale && systemctl status promscale
```


## 配置Prometheus

Prometheus可以使用Remote Write/ Remote Read的方式，通过Promscale，使用Postgres作为远程存储。

编辑Prometheus配置文件：

```bash
vi /etc/prometheus/prometheus.yml
```

添加以下记录：

```yaml
remote_write:
  - url: "http://127.0.0.1:9201/write"
remote_read:
  - url: "http://127.0.0.1:9201/read"
```

重启Prometheus后，监控数据即可放入Postgres中。

```bash
systemctl restart prometheus
```