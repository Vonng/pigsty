# MINIO

> [Min.IO](https://min.io/docs/minio/linux/reference/minio-mc/mc-mb.html): S3-Compatible Open-Source Multi-Cloud Object Storage

[Configuration](#configuration) | [Administration](#administration) | [Playbook](#playbook) | [Dashboard](#dashboard) | [Parameter](#parameter)


MinIO is an S3-compatible object storage server. It's designed to be scalable, secure, and easy to use.
It has native multi-node multi-driver HA support and can store documents, pictures, videos, and backups.

Pigsty uses MinIO as an optional PostgreSQL backup storage repo, in addition to the default local posix FS repo. 
If the MinIO repo is used, the `MINIO` module should be installed before any [`PGSQL`](PGSQL) modules.

MinIO requires a trusted CA to work, so you have to install it in addition to [`NODE`](NODE) module.



----------------

## Configuration

You have to define a MinIO cluster before deploying it. There are some [parameters](#parameter) for MinIO.

- [Single-Node Single-Drive](#single-node-single-drive)
- [Single-Node Multi-Drive](#single-node-multi-drive)
- [Multi-Node Multi-Drive](#multi-node-single-drive)
- [Expose Service](#expose-service)
- [Access Service](#access-service)
- [Expose Admin](#expose-admin)


----------------

### Single-Node Single-Drive

Reference: [deploy-minio-single-node-single-drive](https://min.io/docs/minio/linux/operations/install-deploy-manage/deploy-minio-single-node-single-drive.html)

To define a singleton MinIO instance, it's straightforward:

```yaml
# 1 Node 1 Driver (DEFAULT)
minio: { hosts: { 10.10.10.10: { minio_seq: 1 } }, vars: { minio_cluster: minio } }
```

The only required params are [`minio_seq`](PARAM#minio_seq) and [`minio_cluster`](PARAM#minio_cluster), which generate a unique identity for each MinIO instance. 

Single-Node Single-Driver mode is for development purposes, so you can use a common dir as the data dir, which is `/data/minio` by default.
Beware that in multi-driver or multi-node mode, MinIO will refuse to start if using a common dir as the data dir rather than a mount point.

----------------

### Single-Node Multi-Drive

Reference: [deploy-minio-single-node-multi-drive](https://min.io/docs/minio/linux/operations/install-deploy-manage/deploy-minio-single-node-multi-drive.html)

To use multiple disks on a single node, you have to specify the [`minio_data`](PARAM#minio_data) in the format of `{{ prefix }}{x...y}`, which defines a series of disk mount points.

```yaml
minio:
  hosts: { 10.10.10.10: { minio_seq: 1 } }
  vars:
    minio_cluster: minio         # minio cluster identifier, REQUIRED
    minio_data: '/data{1...4}'   # minio data dir(s), use {x...y} to specify multi drivers
```

This example defines a single-node MinIO cluster with 4 drivers: `/data1`, `/data2`, `/data3`, `/data4`. You have to mount them properly before launching MinIO:

```bash
mkfs.xfs /dev/sdb; mkdir /data1; mount -t xfs /dev/sdb /data1;   # mount 1st driver, ...
```


----------------

### Multi-Node Multi-Drive

Reference: [deploy-minio-multi-node-multi-drive](https://min.io/docs/minio/linux/operations/install-deploy-manage/deploy-minio-multi-node-multi-drive.html)

The extra [`minio_node`](PARAM#minio_node) param will be used for a multi-node deployment:

```yaml
minio:
  hosts:
    10.10.10.10: { minio_seq: 1 }
    10.10.10.11: { minio_seq: 2 }
    10.10.10.12: { minio_seq: 3 }
  vars:
    minio_cluster: minio
    minio_data: '/data{1...2}'                         # use two disk per node
    minio_node: '${minio_cluster}-${minio_seq}.pigsty' # minio node name pattern
```

The `${minio_cluster}` and `${minio_seq}` will be replaced with the value of [`minio_cluster`](PARAM#minio_cluster) and [`minio_seq`](PARAM#minio_seq) respectively and used as MinIO nodename.

----------------

### Expose Service

MinIO will serve on port `9000` by default. If a multi-node MinIO cluster is deployed, you can access its service via any node.
It would be better to expose MinIO service via a load balancer, such as the default [`haproxy`](PARAM#haproxy) on [`NODE`](NODE), or use the L2 [vip](PARAM#node_vip).

To expose MinIO service with haproxy, you have to define an extra service with [`haproxy_services`](PARAM#haproxy_services):

```yaml
minio:
  hosts:
    10.10.10.10: { minio_seq: 1 , nodename: minio-1 }
    10.10.10.11: { minio_seq: 2 , nodename: minio-2 }
    10.10.10.12: { minio_seq: 3 , nodename: minio-3 }
  vars:
    minio_cluster: minio
    node_cluster: minio
    minio_data: '/data{1...2}'         # use two disk per node
    minio_node: '${minio_cluster}-${minio_seq}.pigsty' # minio node name pattern
    haproxy_services:                  # EXPOSING MINIO SERVICE WITH HAPROXY
      - name: minio                    # [REQUIRED] service name, unique
        port: 9002                     # [REQUIRED] service port, unique
        options:                       # [OPTIONAL] minio health check
          - option httpchk
          - option http-keep-alive
          - http-check send meth OPTIONS uri /minio/health/live
          - http-check expect status 200
        servers:
          - { name: minio-1 ,ip: 10.10.10.10 ,port: 9000 ,options: 'check-ssl ca-file /etc/pki/ca.crt check port 9000' }
          - { name: minio-2 ,ip: 10.10.10.11 ,port: 9000 ,options: 'check-ssl ca-file /etc/pki/ca.crt check port 9000' }
          - { name: minio-3 ,ip: 10.10.10.12 ,port: 9000 ,options: 'check-ssl ca-file /etc/pki/ca.crt check port 9000' }
```

----------------

### Access Service

To use the [exposed service](#expose-service), you have to update/append the MinIO credential in the [`pgbackrest_repo`](PARAM#pgbackrest_repo) section: 

```yaml
# This is the newly added HA MinIO Repo definition, USE THIS INSTEAD!
minio_ha:
  type: s3
  s3_endpoint: minio-1.pigsty   # s3_endpoint could be any load balancer: 10.10.10.1{0,1,2}, or domain names point to any of the 3 nodes
  s3_region: us-east-1          # you could use external domain name: sss.pigsty , which resolve to any members  (`minio_domain`)
  s3_bucket: pgsql              # instance & nodename can be used : minio-1.pigsty minio-1.pigsty minio-1.pigsty minio-1 minio-2 minio-3
  s3_key: pgbackrest            # Better using a new password for MinIO pgbackrest user
  s3_key_secret: S3User.SomeNewPassWord
  s3_uri_style: path
  path: /pgbackrest
  storage_port: 9002            # Use the load balancer port 9002 instead of default 9000 (direct access)
  storage_ca_file: /etc/pki/ca.crt
  bundle: y
  cipher_type: aes-256-cbc      # Better using a new cipher password for your production environment
  cipher_pass: pgBackRest.With.Some.Extra.PassWord.And.Salt.${pg_cluster}
  retention_full_type: time
  retention_full: 14
```

----------------

### Expose Admin

MinIO will serve an admin web portal on port `9001` by default.

It's not wise to expose the admin portal to the public, but if you wish to do so, add MinIO to the [`infra_portal`](PARAM#infra_portal) and refresh the nginx server:

```yaml
infra_portal:   # domain names and upstream servers
  # ...         # MinIO admin page require HTTPS / Websocket to work
  minio1       : { domain: sss.pigsty  ,endpoint: 10.10.10.10:9001 ,scheme: https ,websocket: true }
  minio2       : { domain: sss2.pigsty ,endpoint: 10.10.10.11:9001 ,scheme: https ,websocket: true }
  minio3       : { domain: sss3.pigsty ,endpoint: 10.10.10.12:9001 ,scheme: https ,websocket: true }
```

Check the MinIO demo [config](https://github.com/Vonng/pigsty/blob/master/files/pigsty/minio.yml) and special [Vagrantfile](https://github.com/Vonng/pigsty/blob/master/vagrant/spec/minio.rb) for more details.




----------------

## Administration

Here are some common MinIO `mcli` commands for reference, check [MinIO Client](https://min.io/docs/minio/linux/reference/minio-mc.html) for more details.

----------------

### Create Cluster

To create a [defined](#configuration) minio cluster, run the [`minio.yml`](#minioyml) playbook on `minio` group:

```bash
./minio.yml -l minio   # install minio cluster on group 'minio'
```

----------------

### Client Setup

To access MinIO servers, you have to configure client `mcli` alias first:

```bash
mcli alias ls  # list minio alias (there's a sss by default)
mcli alias set sss https://sss.pigsty:9000 minioadmin minioadmin              # root user
mcli alias set pgbackrest https://sss.pigsty:9000 pgbackrest S3User.Backup    # backup user
```

You can manage business users with `mcli` as well:

```bash
mcli admin user list sss     # list all users on sss
set +o history # hide password in history and create minio user
mcli admin user add sss dba S3User.DBA
mcli admin user add sss pgbackrest S3User.Backup
set -o history 
```

----------------

### CRUD

You can CRUD minio bucket with `mcli`:

```bash
mcli ls sss/          # list buckets of alias 'sss'
mcli mb --ignore-existing sss/hello  # create a bucket named 'hello'
mcli rb --force sss/hello            # remove bucket 'hello' with force
```

Or perform object CRUD:

```bash
mcli cp -r /www/pigsty/*.rpm sss/infra/repo/         # upload files to bucket 'infra' with prefix 'repo'
mcli cp sss/infra/repo/pg_exporter-0.5.0.x86_64.rpm /tmp/  # download file from minio to local
```




----------------

## Playbook

There's a built-in playbook: [`minio.yml`](#minioyml) for installing the MinIO cluster. But you have to [define](#configuration) it first.

### `minio.yml`

[`minio.yml`](https://github.com/Vonng/pigsty/blob/master/minio.yml)

- `minio-id`        : generate minio identity
- `minio_os_user`   : create os user minio
- `minio_install`   : install minio/mcli rpm
- `minio_clean`     : remove minio data (not default)
- `minio_dir`       : create minio directories
- `minio_config`    : generate minio config
  - `minio_conf`    : minio main config
  - `minio_cert`    : minio ssl cert
  - `minio_dns`     : write minio dns records
- `minio_launch`    : launch minio service
- `minio_register`  : register minio to prometheus
- `minio_provision` : create minio aliases/buckets/users
  - `minio_alias`   : create minio client alias
  - `minio_bucket`  : create minio buckets
  - `minio_user`    : create minio biz users

Trusted ca file: `/etc/pki/ca.crt` should exist on all nodes already. which is generated in `role: ca` and loaded & trusted by default in `role: node`.

You should install [`MINIO`](MINIO) module on Pigsty-managed nodes (i.e., Install [`NODE`](NODE) first)

[![asciicast](https://asciinema.org/a/566415.svg)](https://asciinema.org/a/566415)




----------------

## Dashboard

There are two dashboards for [`MINIO`](MINIO) module.

[MinIO Overview](https://demo.pigsty.cc/d/minio-overview): Overview of one single MinIO cluster

[MinIO Instance](https://demo.pigsty.cc/d/minio-instance): Detail information about one single MinIO instance

[![minio-overview.jpg](https://repo.pigsty.cc/img/minio-overview.jpg)](https://demo.pigsty.cc/d/minio-overview)




----------------

## Parameter

There are 15 parameters in [`MINIO`](PARAM#minio) module.


| Parameter                                    |   Type   | Level | Comment                                                 |
|----------------------------------------------|:--------:|:-----:|---------------------------------------------------------|
| [`minio_seq`](PARAM#minio_seq)               |   int    |   I   | minio instance identifier, REQUIRED                     |
| [`minio_cluster`](PARAM#minio_cluster)       |  string  |   C   | minio cluster name, minio by default                    |
| [`minio_clean`](PARAM#minio_clean)           |   bool   | G/C/A | cleanup minio during init?, false by default            |
| [`minio_user`](PARAM#minio_user)             | username |   C   | minio os user, `minio` by default                       |
| [`minio_node`](PARAM#minio_node)             |  string  |   C   | minio node name pattern                                 |
| [`minio_data`](PARAM#minio_data)             |   path   |   C   | minio data dir(s), use {x...y} to specify multi drivers |
| [`minio_domain`](PARAM#minio_domain)         |  string  |   G   | minio external domain name, `sss.pigsty` by default     |
| [`minio_port`](PARAM#minio_port)             |   port   |   C   | minio service port, 9000 by default                     |
| [`minio_admin_port`](PARAM#minio_admin_port) |   port   |   C   | minio console port, 9001 by default                     |
| [`minio_access_key`](PARAM#minio_access_key) | username |   C   | root access key, `minioadmin` by default                |
| [`minio_secret_key`](PARAM#minio_secret_key) | password |   C   | root secret key, `minioadmin` by default                |
| [`minio_extra_vars`](PARAM#minio_extra_vars) |  string  |   C   | extra environment variables for minio server            |
| [`minio_alias`](PARAM#minio_alias)           |  string  |   G   | alias name for local minio deployment                   |
| [`minio_buckets`](PARAM#minio_buckets)       | bucket[] |   C   | list of minio bucket to be created                      |
| [`minio_users`](PARAM#minio_users)           |  user[]  |   C   | list of minio user to be created                        |


```yaml
#minio_seq: 1                     # minio cluster identifier, REQUIRED
#minio_cluster: minio             # minio cluster name, minio by default
minio_clean: false                # cleanup minio during init?, false by default
minio_user: minio                 # minio os user, `minio` by default
minio_node: '${minio_cluster}-${minio_seq}.pigsty' # minio node name pattern
minio_data: '/data/minio'         # minio data dir(s), use {x...y} to specify multi drivers
minio_domain: sss.pigsty          # minio external domain name, `sss.pigsty` by default
minio_port: 9000                  # minio service port, 9000 by default
minio_admin_port: 9001            # minio console port, 9001 by default
minio_access_key: minioadmin      # root access key, `minioadmin` by default
minio_secret_key: minioadmin      # root secret key, `minioadmin` by default
minio_extra_vars: ''              # extra environment variables
minio_alias: sss                  # alias name for local minio deployment
minio_buckets: [ { name: pgsql }, { name: infra },  { name: redis } ]
minio_users:
  - { access_key: dba , secret_key: S3User.DBA, policy: consoleAdmin }
  - { access_key: pgbackrest , secret_key: S3User.Backup, policy: readwrite }
```