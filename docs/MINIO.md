# MINIO

> [Min.IO](https://min.io/docs/minio/linux/reference/minio-mc/mc-mb.html): S3-Compatible Open-Source Multi-Cloud Object Storage

It has native multi-node multi-driver support, can be used for storing documents, pictures, videos, backups.

Pigsty use MinIO as an optional PostgreSQL backup storage repo instead of local repo. 
In that case, MINIO module should be installed ahead of all [`PGSQL`](PGSQL) module.

And etcd require a trusted CA to work, so you have to install it after [`NODE`](NODE) module.




## Playbook

There's a built-in playbook: `minio.yml` for installing minio cluster. But you have to define it first.

```bash
./minio.yml    # install minio cluster on group 'minio'
```

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

You should install [`MINIO`](MINIO) module on Pigsty managed nodes (i.e. Install [`NODE`](NODE) first)



## Configuration

You have to define a minio cluster before deploying it. There some [parameters](#parameters) about minio.


**Single Node, Single Drive**

https://min.io/docs/minio/linux/operations/install-deploy-manage/deploy-minio-single-node-single-drive.html

To deploy a singleton minio instance:

```yaml
# 1 Node 1 Driver (DEFAULT)
minio: { hosts: { 10.10.10.10: { minio_seq: 1 } }, vars: { minio_cluster: minio } }
```

[`minio_seq`](PARAM#minio_seq) and [`minio_cluster`](PARAM#minio_cluster) is required identity parameter.

Single Node mode is for development purpose, you can set [`minio_data`](PARAM#minio_data) to a common directory (`/data/minio` by default).



**Single-Node Multi-Drive**

https://min.io/docs/minio/linux/operations/install-deploy-manage/deploy-minio-single-node-multi-drive.html

If you have multiple disks/drivers, mount them in sequence order.

If multiple drive is specified, MinIO will treat it as a serious production deployment, refues to start if volumn is a common dir rather than a mountpoint.


```bash
mkfs.xfs /dev/sdb;  mkfs.xfs /dev/sdc mkfs.xfs
mkdir    /data1     mkdir /data2
mount -t xfs /dev/sdb /data1        
mount -t xfs /dev/sdb /data2
...
```

And set a [`minio_data`](PARAM#minio_data) on cluster level : `minio_data: '/data{1...2}'`.




**Multi-Node Multi-Drive**

https://min.io/docs/minio/linux/operations/install-deploy-manage/deploy-minio-multi-node-multi-drive.html

To deploy a distributed minio cluster, you have to define them in following format.

The [`minio_node`](PARAM#minio_node) param will define domain names for minio instances

```yaml
minio:
  hosts:
    10.10.10.10: { minio_seq: 1 }
    10.10.10.11: { minio_seq: 2 }
    10.10.10.12: { minio_seq: 3 }
  vars:
    minio_cluster: minio
    minio_data: '/data{1...2}'        # use two disk per node
    minio_node: '${minio_cluster}-${minio_seq}.pigsty' # minio node name pattern
```


**Expose Service**

You can expose a multi-node minio cluster with [`haproxy_service`](PARAM#haproxy_service)

Here's an example of expose a 3-node minio cluster on their nodes。

```yaml
minio:
  hosts:
    10.10.10.10: { minio_seq: 1 }
    10.10.10.11: { minio_seq: 2 }
    10.10.10.12: { minio_seq: 3 }
  vars:
    minio_cluster: minio
    minio_data: '/data{1...2}'        # use two disk per node
    minio_node: '${minio_cluster}-${minio_seq}.pigsty' # minio node name pattern
    haproxy_services:
      - name: minio                     # [REQUIRED] service name, unique
        port: 9002                      # [REQUIRED] service port, unique
        options:
            - option httpchk
            - option http-keep-alive
            - http-check send meth OPTIONS uri /minio/health/live
            - http-check expect status 200
        servers:
            - { name: minio-1 ,ip: 10.10.10.10 , port: 9000 , options: 'check-ssl ca-file /etc/pki/ca.crt check port 9000' }
            - { name: minio-2 ,ip: 10.10.10.11 , port: 9000 , options: 'check-ssl ca-file /etc/pki/ca.crt check port 9000' }
            - { name: minio-3 ,ip: 10.10.10.12 , port: 9000 , options: 'check-ssl ca-file /etc/pki/ca.crt check port 9000' }
```

If minio cluster is defined in Pigsty inventory, you can materialize it with [`minio.yml`](playbook) playbook.
An admin web portal is served on https://sss.pigsty:9001 by default, and you can interact with minio with [`mcli`](#administration)



## Administration


**Set Alias**

```bash
mcli alias ls  # list minio alias (there's a sss by default)
mcli alias set sss https://sss.pigsty:9000 minioadmin minioadmin
mcli alias set patroni https://sss.pigsty:9000 patroni S3User.Patroni
mcli alias set pgbackrest https://sss.pigsty:9000 pgbackrest S3User.Backup
```

**User Admin**

```bash
mcli admin user list sss     # list all users on sss
set +o history # hide password in history and create minio user
mcli admin user add sss dba S3User.DBA
mcli admin user add sss patroni S3User.Patroni
mcli admin user add sss pgbackrest S3User.Backup
set -o history 
```

**Bucket CRUD**

```bash
mcli ls sss/          # list buckets of alias 'sss'
mcli mb --ignore-existing sss/hello  # create a bucket named 'hello'
mcli rb --force sss/hello            # remove bucket 'hello' with force
```


**Object CRUD**

```bash
mcli cp -r /www/pigsty/*.rpm sss/infra/repo/         # upload files to bucket 'infra' with prefix 'repo'
mcli cp sss/infra/repo/pg_exporter-0.5.0.x86_64.rpm /tmp/  # download file from minio to local
```



## Parameters

There are 15 parameters about [`MINIO`](PARAM#MINIO) module.


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
