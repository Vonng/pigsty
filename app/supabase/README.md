# Supabase

The open source Firebase alternative.

```bash
cd app/supabase; make up
```

```bash
make up         # pull up supabase with docker compose
make view       # print supabase access point
make log        # tail -f supabase logs
make info       # introspect supabase with jq
make stop       # stop supabase container
make clean      # remove supabase container
make pull       # pull latest supabase image
make rmi        # remove supabase image
make save       # save supabase image to /tmp/supabase.tgz
make load       # load supabase image from /tmp
```


## Docker Compose

The `.env` file provides configuration parameters for supabase docker compose.

You have to change the following parameters according to your environment:

```bash
# Secrets: YOU MUST CHANGE THESE BEFORE GOING INTO PRODUCTION
POSTGRES_PASSWORD=DBUser.Supa     # supabase dbsu password (shared by multiple supabase biz users)
DASHBOARD_USERNAME=supabase       # supabase WebUI Username
DASHBOARD_PASSWORD=pigsty         # supabase WebUI Password
JWT_SECRET=your-super-secret-jwt-token-with-at-least-32-characters-long
ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE
SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJzZXJ2aWNlX3JvbGUiLAogICAgImlzcyI6ICJzdXBhYmFzZS1kZW1vIiwKICAgICJpYXQiOiAxNjQxNzY5MjAwLAogICAgImV4cCI6IDE3OTk1MzU2MDAKfQ.DaYlNEoUrrEn2Ig7tqibS-PHK5vgusbcbo7X36XVt4Q

# Database - You can change these to any PostgreSQL database that has logical replication enabled.
POSTGRES_HOST=10.10.10.10         # change to Pigsty managed PostgreSQL cluster/instance VIP/IP/Hostname
POSTGRES_DB=supa                  # change to supabase database name
POSTGRES_PORT=5432                # you can use other service port such as 5433, 5436, 6432, etc...
```

Then you can pull up supabase with docker compose: `docker compose up` or `make up`



## Database

You have to prepare a PostgreSQL cluster/instance before launching supabase:

The [`supabase.yml`](https://github.com/Vonng/pigsty/blob/master/files/pigsty/supabase.yml) provides a sample configuration for supabase.

It will create a cluster with `supa` database, related users and roles, schemas and extensions ready. It will run the [init-scripts](https://github.com/supabase/postgres/tree/develop/migrations/db/init-scripts) as database baseline.

```yaml
# supabase example cluster: pg-meta, this cluster needs to be migrated with app/supabase/migration.sql :
pg-meta:
  hosts: { 10.10.10.10: { pg_seq: 1, pg_role: primary } }
  vars:
    pg_cluster: pg-meta
    pg_libs: 'pg_net, pg_stat_statements, auto_explain'    # add pg_net to shared_preload_libraries
    pg_extensions:                                        # required extensions
      - pg_repack_${pg_version}* wal2json_${pg_version}* pgvector_${pg_version}* pg_cron_${pg_version}* pgsodium_${pg_version}*
      - vault_${pg_version}* pg_graphql_${pg_version}* pgjwt_${pg_version}* pg_net_${pg_version}* pgsql-http_${pg_version}*
    pg_users:
      # supabase roles: anon, authenticated, dashboard_user
      - { name: anon           ,login: false }
      - { name: authenticated  ,login: false }
      - { name: dashboard_user ,login: false ,replication: true ,createdb: true ,createrole: true }
      - { name: service_role   ,login: false ,bypassrls: true }
      # supabase users: please use the same password
      - { name: supabase_admin             ,password: 'DBUser.Supa' ,pgbouncer: true ,inherit: true   ,superuser: true ,replication: true ,createdb: true ,createrole: true ,bypassrls: true }
      - { name: authenticator              ,password: 'DBUser.Supa' ,pgbouncer: true ,inherit: false  ,roles: [ authenticated ,anon ,service_role ] }
      - { name: supabase_auth_admin        ,password: 'DBUser.Supa' ,pgbouncer: true ,inherit: false  ,createrole: true }
      - { name: supabase_storage_admin     ,password: 'DBUser.Supa' ,pgbouncer: true ,inherit: false  ,createrole: true ,roles: [ authenticated ,anon ,service_role ] }
      - { name: supabase_functions_admin   ,password: 'DBUser.Supa' ,pgbouncer: true ,inherit: false  ,createrole: true }
      - { name: supabase_replication_admin ,password: 'DBUser.Supa' ,replication: true }
      - { name: supabase_read_only_user    ,password: 'DBUser.Supa' ,bypassrls: true ,roles: [ pg_read_all_data ] }
    pg_databases:
      - { name: meta ,baseline: cmdb.sql ,comment: pigsty meta database ,schemas: [ pigsty ]} # the pigsty cmdb, optional
      - name: supa
        baseline: supa.sql    # the init-scripts: https://github.com/supabase/postgres/tree/develop/migrations/db/init-scripts
        owner: supabase_admin
        comment: supabase postgres database
        schemas: [ extensions ,auth ,realtime ,storage ,graphql_public ,supabase_functions ,_analytics ,_realtime ]
        extensions:
          - { name: pgcrypto  ,schema: extensions  } # 1.3   : cryptographic functions
          - { name: pg_net    ,schema: extensions  } # 0.7.1 : Async HTTP
          - { name: pgjwt     ,schema: extensions  } # 0.2.0 : JSON Web Token API for Postgresql
          - { name: uuid-ossp ,schema: extensions  } # 1.1   : generate universally unique identifiers (UUIDs)
          - { name: pgsodium        }                # 3.1.8 : pgsodium is a modern cryptography library for Postgres.
          - { name: supabase_vault  }                # 0.2.8 : Supabase Vault Extension
          - { name: pg_graphql      }                # 1.3.0 : pg_graphql: GraphQL support
    pg_hba_rules:
      - { user: all ,db: supa ,addr: intra       ,auth: pwd ,title: 'allow supa database access from intranet'}
      - { user: all ,db: supa ,addr: 172.0.0.0/8 ,auth: pwd ,title: 'allow supa database access from docker network'}
```

After bootstrap, you also have to run migrations with [`app/supabase/migration.sql`](https://github.com/Vonng/pigsty/blob/master/app/supabase/migration.sql):

```bash
psql postgres://supabase_admin:DBUser.Supa@10.10.10.10:5432/supa -v ON_ERROR_STOP=1 --no-psqlrc -f ~pigsty/app/supabase/migration.sql
```

Supabase will use the same password for all supabase business users, which is `DBUser.Supa` in this example. You can change it to whatever you like.
