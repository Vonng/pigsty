# Dify

Dify: https://dify.ai/

The Innovation Engine for GenAI Applications, Dify is an open-source LLM app development platform. Orchestrate LLM apps from agents to complex AI workflows, with an RAG engine.


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

Check [`.env`](.env) file for database credentials, then launch [Dify](https://dify.ai/) with:

```bash
make up  # docker compose up
```

Visit [http://dify.pigsty](http://dify.pigsty) or http://10.10.10.10:8001



------

## Makefile

some shortcuts:

```bash
make up         # pull up dify with docker compose in minimal mode
make run        # launch dify with docker , local data dir and external PostgreSQL
make view       # print dify access point
make log        # tail -f dify logs
make info       # introspect dify with jq
make stop       # stop dify container
make clean      # remove dify container
make pull       # pull latest dify image
make rmi        # remove dify image
make save       # save dify image to /tmp/docker/dify.tgz
make load       # load dify image from /tmp/docker/dify.tgz
```



------ 

## Create PostgreSQL & Redis

Dify can use external PostgreSQL & Redis,

```yaml
pg-meta:
  hosts: { 10.10.10.10: { pg_seq: 1, pg_role: primary } }
  vars:
    pg_cluster: pg-meta
    pg_users: [ { name: dbuser_dify ,password: DBUser.Dify  ,superuser: true ,pgbouncer: true ,roles: [ dbrole_admin ] } ]
    pg_databases: [ { name: dify, owner: dbuser_dify, extensions: [ { name: pgvector } ] } ]
    pg_hba_rules: [ { user: dbuser_dify , db: all ,addr: world ,auth: pwd ,title: 'allow dify user world pwd access' } ]

redis-dify:
  hosts: { 10.10.10.10: { redis_node: 1 , redis_instances: { 6379: { }, 6380: { replica_of: '10.10.10.10 6379' } } } }
  vars: { redis_cluster: redis-dify ,redis_password: 'redis.dify' ,redis_max_memory: 64MB }
```

And create business user & database with:

```bash
bin/pgsql-user  pg-meta  dbuser_dify
bin/pgsql-db    pg-meta  dify
```

Check connectivity:

```bash
psql postgres://dbuser_dify:DBUser.Dify@10.10.10.10:5432/dify
```