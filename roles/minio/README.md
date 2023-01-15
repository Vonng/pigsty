# Minio

> [Min.IO](https://min.io/docs/minio/linux/reference/minio-mc/mc-mb.html): S3-Compatible Open-Source Multi-Cloud Object Storage


## Playbooks

There's a built-in playbook: `minio.yml` for installing minio cluster

```bash
./minio.yml    # install minio cluster on group 'minio'
```

- minio-id        : generate minio identity
- minio_os_user   : create os user minio
- minio_install   : install minio/mcli rpm
- minio_clean     : remove minio data (not default)
- minio_dir       : create minio directories
- minio_config    : generate minio config
    - minio_conf    : minio main config
    - minio_cert    : minio ssl cert
    - minio_dns     : write minio dns records
- minio_launch    : launch minio service
- minio_register  : register minio to prometheus
- minio_provision : create minio aliases/buckets/users
-   - minio_alias   : create minio client alias
-   - minio_bucket  : create minio buckets
-   - minio_user    : create minio biz users



## Deployment

Run on admin node with admin user

### Alias

```bash
mcli alias ls  # list minio alias (there's a sss by default)
mcli alias set sss https://sss.pigsty:9000 minioadmin minioadmin
mcli alias set patroni https://sss.pigsty:9000 patroni S3User.Patroni
mcli alias set pgbackrest https://sss.pigsty:9000 pgbackrest S3User.Backup
```


### Admin

```bash
mcli admin user list sss     # list all users on sss
set +o history # hide password in history and create minio user
mcli admin user add sss dba S3User.DBA
mcli admin user add sss patroni S3User.Patroni
mcli admin user add sss pgbackrest S3User.Backup
set -o history 
```


### Bucket

```bash
mcli ls sss/          # list buckets of alias 'sss'
mcli mb --ignore-existing sss/hello  # create a bucket named 'hello'
mcli rb --force sss/hello            # remove bucket 'hello' with force
```


### CRUD

```bash
mcli cp -r /www/pigsty/*.rpm sss/infra/repo/         # upload files to bucket 'infra' with prefix 'repo'
mcli cp sss/infra/repo/pg_exporter-0.5.0.x86_64.rpm /tmp/  # download file from minio to local
```