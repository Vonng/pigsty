# Dify

Dify: https://dify.ai/

The Innovation Engine for GenAI Applications, Dify is an open-source LLM app development platform. Orchestrate LLM apps from agents to complex AI workflows, with an RAG engine.

- [Detailed setup tutorial](https://pigsty.io/zh/blog/pg/dify-setup/)
- [GitHub: langgenius/Dify](https://github.com/langgenius/dify/)
- [Pigsty: Dify Docker Compose Template](https://github.com/Vonng/pigsty/tree/master/app/dify)


------

## Get Started

Define & Create required PostgreSQL & Redis with Pigsty:

```yaml
pg-meta:
  hosts: { 10.10.10.10: { pg_seq: 1, pg_role: primary } }
  vars:
    pg_cluster: pg-meta
    pg_users: [ { name: dbuser_dify ,password: DBUser.Dify  ,superuser: true ,pgbouncer: true ,roles: [ dbrole_admin ] } ]
    pg_databases: [ { name: dify, owner: dbuser_dify, extensions: [ { name: pgvector } ] } ]
    pg_hba_rules: [ { user: dbuser_dify , db: all ,addr: world ,auth: pwd ,title: 'allow dify user world pwd access' } ]

redis-dify:
  hosts: { 10.10.10.10: { redis_node: 1 , redis_instances: { 6379: { } } } }
  vars: { redis_cluster: redis-dify ,redis_password: 'redis.dify' ,redis_max_memory: 64MB }
```

Then create them with pigsty playbooks:

```bash
bin/pgsql-add  pg-meta                # create the dify database cluster
bin/pgsql-user pg-meta dbuser_dify    # create dify biz user
bin/pgsql-db   pg-meta dify           # create dify biz database
bin/redis-add  redis-dify             # create redis cluster
```

Check [`.env`](.env) file for database credentials:

```bash
# meta parameter
DIFY_PORT=8001 # expose dify nginx service with port 8001 by default
LOG_LEVEL=INFO # The log level for the application. Supported values are `DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL`
SECRET_KEY=sk-9f73s3ljTXVcMT3Blb3ljTqtsKiGHXVcMT3BlbkFJLK7U # A secret key for signing and encryption, gen with `openssl rand -base64 42`

# postgres credential
PG_USERNAME=dbuser_dify
PG_PASSWORD=DBUser.Dify
PG_HOST=10.10.10.10
PG_PORT=5432
PG_DATABASE=dify

# redis credential
REDIS_HOST=10.10.10.10
REDIS_PORT=6379
REDIS_USERNAME=''
REDIS_PASSWORD=redis.dify

# minio/s3 [OPTIONAL] when STORAGE_TYPE=s3
STORAGE_TYPE=local
S3_ENDPOINT='https://sss.pigsty'
S3_BUCKET_NAME='infra'
S3_ACCESS_KEY='dba'
S3_SECRET_KEY='S3User.DBA'
S3_REGION='us-east-1'
```

then launch [Dify](https://dify.ai/) with:

```bash
make up  # docker compose up
```

Visit [http://dify.pigsty](http://dify.pigsty) or http://10.10.10.10:8001


------

## Expose Dify Web Service

Change `infra_portal` in `pigsty.yml`, with the new `dify` line:

```yaml
infra_portal:                     # domain names and upstream servers
  home         : { domain: h.pigsty }
  grafana      : { domain: g.pigsty ,endpoint: "${admin_ip}:3000" , websocket: true }
  prometheus   : { domain: p.pigsty ,endpoint: "${admin_ip}:9090" }
  alertmanager : { domain: a.pigsty ,endpoint: "${admin_ip}:9093" }
  blackbox     : { endpoint: "${admin_ip}:9115" }
  loki         : { endpoint: "${admin_ip}:3100" }
  
  dify         : { domain: dify.pigsty ,endpoint: "10.10.10.10:8001", websocket: true }
```

Then expose dify web service via Pigsty's Nginx server:

```bash
./infra.yml -t nginx
```

Don't forget to add `dify.pigsty` to your DNS or local `/etc/hosts` / `C:\Windows\System32\drivers\etc\hosts` to access via domain name.