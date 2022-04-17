# Using TimescaleDB to store Prometheus data

You can use postgres as the remote storage database used by the Prometheus backend.

While this is not the recommended behavior, it is a good opportunity to understand how the Pigsty deployment system is used.


## Preparing the Postgres database

```bash
vi pigsty.yml # Uncomment DB/User definition: dbuser_prometheus prometheus

pg_databases:                           # define business users/roles on this cluster, array of user definition
  - { name: prometheus, owner: dbuser_prometheus , revokeconn: true, comment: prometheus primary database }
pg_users:                           # define business users/roles on this cluster, array of user definition
  - {name: dbuser_prometheus , password: DBUser.Prometheus ,pgbouncer: true , createrole: true,  roles: [dbrole_admin], comment: admin user for prometheus database }
```

Create a Prometheus business database with business users.

```bash
bin/createuser  pg-meta  dbuser_prometheus
bin/createdb    pg-meta  prometheus
```

Check database availability and create extensions。

```bash
psql postgres://dbuser_prometheus:DBUser.Prometheus@10.10.10.10:5432/prometheus -c 'CREATE EXTENSION timescaledb;'
```



## Configure Promscale

Install `promscale` by executing the following command on the meta node

```bash
yum install -y promscale 
```

If not available in the default package, you can directly download it.

```bash
wget https://github.com/timescale/promscale/releases/download/0.6.1/promscale_0.6.1_Linux_x86_64.rpm
sudo rpm -ivh promscale_0.6.1_Linux_x86_64.rpm
```

Edit the `promscale` config file `/etc/sysconfig/promscale.conf`.

```bash
PROMSCALE_DB_HOST="127.0.0.1"
PROMSCALE_DB_NAME="prometheus"
PROMSCALE_DB_PASSWORD="DBUser.Prometheus"
PROMSCALE_DB_PORT="5432"
PROMSCALE_DB_SSL_MODE="disable"
PROMSCALE_DB_USER="dbuser_prometheus"
```

Finally start promscale, which will access the database instance with `timescaledb` installed and create the required schema.

```bash
# launch 
cat /usr/lib/systemd/system/promscale.service
systemctl start promscale && systemctl status promscale
```


## Configure Prometheus

Prometheus can use Remote Write/ Remote Read via Promscale, using Postgres as remote storage.

Edit Prometheus config file.

```bash
vi /etc/prometheus/prometheus.yml
```

Add the following record.

```yaml
remote_write:
  - url: "http://127.0.0.1:9201/write"
remote_read:
  - url: "http://127.0.0.1:9201/read"
```

After restarting Prometheus, the monitoring data can be placed in Postgres.

```bash
systemctl restart prometheus
```