# Supabase

[Supabase](https://supabase.com/), The open-source Firebase alternative based on PostgreSQL.

Pigsty allow you to self-host **supabase** with existing managed HA postgres cluster, and launch the stateless part of supabase with docker-compose.


-----------------------

## Quick Start

To run supabase with existing postgres instance, prepare the [database](#database) with [`supabase.yml`](https://github.com/Vonng/pigsty/blob/master/files/pigsty/supabase.yml)

then launch the [stateless part](#stateless-part) with the [`docker-compose`](docker-compose.yml) file:

```bash
cd app/supabase; make up    # https://supabase.com/docs/guides/self-hosting/docker
```

Then you can access the supabase studio dashboard via `http://<admin_ip>:8000` by default, the default dashboard username is `supabase` and password is `pigsty`.

You can also configure the `infra_portal` to expose the WebUI to the public through Nginx and SSL.



-----------------------

## Database

Supabase require certain PostgreSQL extensions, schemas, and roles to work, which can be pre-configured by Pigsty: [`supabase.yml`](https://github.com/Vonng/pigsty/blob/master/files/pigsty/supabase.yml).

The following example will configure the default `pg-meta` cluster as underlying postgres for supabase:

```yaml
# supabase example cluster: pg-meta, this cluster needs to be migrated with ~/pigsty/app/supabase/migration.sql :
pg-meta:
  hosts: { 10.10.10.10: { pg_seq: 1, pg_role: primary } }
  vars:
    pg_cluster: pg-meta
    pg_version: 15
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
    pg_extensions:                                        # required extensions
      - pg_repack_15* wal2json_15* pgvector_15* pg_cron_15* pgsodium_15*
      - vault_15* pg_graphql_15* pgjwt_15* pg_net_15* pgsql-http_15*
    pg_libs: 'pg_net, pg_stat_statements, auto_explain'    # add pg_net to shared_preload_libraries
```

Beware that `baseline: supa.sql` parameter will use the [`files/supa.sql`](https://github.com/Vonng/pigsty/blob/master/files/supa.sql) as database baseline schema, which is gathered from [here](https://github.com/supabase/postgres/tree/develop/migrations/db/init-scripts).
You also have to run the migration script: [`migration.sql`](migration.sql) after the cluster provisioning, which is gathered from [supabase/postgres/migrations/db/migrations](https://github.com/supabase/postgres/tree/develop/migrations/db/migrations) in chronological order and slightly modified to fit Pigsty.

You can check the latest migration files and add them to [`migration.sql`](migration.sql), the current script is synced with [20231013070755](https://github.com/supabase/postgres/blob/develop/migrations/db/migrations/20231013070755_grant_authenticator_to_supabase_storage_admin.sql).
You can run migration on provisioned postgres cluster `pg-meta` with simple `psql` command: 

```bash
psql postgres://supabase_admin:DBUser.Supa@10.10.10.10:5432/supa -v ON_ERROR_STOP=1 --no-psqlrc -f ~/pigsty/app/supabase/migration.sql
```

Check connection to that database with the default credentials:

```bash
psql postgres://supabase_admin:DBUser.Supa@10.10.10.10:5432/supa -c '\dx'   # check connectivity & extensions
```

The database is now ready for supabase!



-----------------------

## Stateless Part

Supabase stateless part is managed by `docker-compose`, the [`docker-compose`](docker-compose.yml) file we use here is a simplified version of [github.com/supabase/docker/docker-compose.yml](https://github.com/supabase/supabase/blob/master/docker/docker-compose.yml).

Everything you need to care about is in the [`.env`](.env) file, which contains important settings for supabase. It is already configured to use the `pg-meta`.`supa` database by default, You have to change that according to your actual deployment. 

```bash
############
# Secrets - YOU MUST CHANGE THESE BEFORE GOING INTO PRODUCTION
############
# you have to change the JWT_SECRET to a random string with at least 32 characters long
# and issue new ANON_KEY/SERVICE_ROLE_KEY JWT with that new secret, check the tutorial:
# https://supabase.com/docs/guides/self-hosting/docker#securing-your-services
JWT_SECRET=your-super-secret-jwt-token-with-at-least-32-characters-long
ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE
SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJzZXJ2aWNlX3JvbGUiLAogICAgImlzcyI6ICJzdXBhYmFzZS1kZW1vIiwKICAgICJpYXQiOiAxNjQxNzY5MjAwLAogICAgImV4cCI6IDE3OTk1MzU2MDAKfQ.DaYlNEoUrrEn2Ig7tqibS-PHK5vgusbcbo7X36XVt4Q

############
# Dashboard - Credentials for the Supabase Studio WebUI
############
DASHBOARD_USERNAME=supabase         # change to your own username
DASHBOARD_PASSWORD=pigsty           # change to your own password

############
# Database - You can change these to any PostgreSQL database that has logical replication enabled.
############
POSTGRES_HOST=10.10.10.10           # change to Pigsty managed PostgreSQL cluster/instance VIP/IP/Hostname
POSTGRES_PORT=5432                  # you can use other service port such as 5433, 5436, 6432, etc...
POSTGRES_DB=supa                    # change to supabase database name, `supa` by default in pigsty
POSTGRES_PASSWORD=DBUser.Supa       # supabase dbsu password (shared by multiple supabase biz users)
```

Usually you'll have to change these parameters accordingly. Here we'll use fixed username, password and IP:Port database connstr for simplicity.

The postgres username is fixed as `supabase_admin` and the password is `DBUser.Supa`, change that according to your [`supabase.yml`](https://github.com/Vonng/pigsty/blob/master/files/pigsty/supabase.yml#L43)
And the supabase studio WebUI credential is managed by `DASHBOARD_USERNAME` and `DASHBOARD_PASSWORD`, which is `supabase` and `pigsty` by default.

The official tutorial: [Self-Hosting with Docker](https://supabase.com/docs/guides/self-hosting/docker) just have all the details you need.

> ### Hint
>
> You can use the [Primary Service](https://github.com/Vonng/pigsty/blob/master/docs/PGSQL-SVC.md#primary-service) of that cluster through DNS/VIP and other service ports, or whatever access method you like.
>
> You can also configure `supabase.storage` service to use the MinIO service managed by pigsty, too

Once configured, you can launch the stateless part with `docker-compose` or `make up` shortcut:

```bash
cd ~/pigsty/app/supabase; make up    #  = docker compose up
```


