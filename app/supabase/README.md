# Supabase

[Supabase](https://supabase.com/), The open-source Firebase alternative based on PostgreSQL.

Pigsty allow you to self-host **supabase** with existing managed HA postgres cluster, and launch the stateless part of supabase with docker-compose.

> Notice: Supabase is [GA](https://supabase.com/ga) since 2024.04.15

> Complete Tutorial: https://pigsty.io/docs/kernel/supabase

-----------------------

## Quick Start

To run supabase with existing postgres instance, prepare the [database](#database) with [`supabase.yml`](https://github.com/Vonng/pigsty/blob/master/conf/sample/supabase.yml)

then launch the [stateless part](#stateless-part) with the [`docker-compose`](docker-compose.yml) file:

```bash
cd app/supabase; make up    # https://supabase.com/docs/guides/self-hosting/docker
```

Then you can access the supabase studio dashboard via `http://<admin_ip>:8000` by default, the default dashboard username is `supabase` and password is `pigsty`.

You can also configure the `infra_portal` to expose the WebUI to the public through Nginx and SSL.



-----------------------

## Database

Supabase require certain PostgreSQL extensions, schemas, and roles to work, which can be pre-configured by Pigsty: [`supabase.yml`](https://github.com/Vonng/pigsty/blob/master/conf/dbms/supabase.yml).

Provisioning a cluster with that configuration, then the database is now ready for supabase!

![](https://pigsty.io/img/pigsty/supa.jpg)



-----------------------

## Stateless Part

Supabase stateless part is managed by `docker-compose`, the [`docker-compose`](docker-compose.yml) file we use here is a simplified version of [github.com/supabase/docker/docker-compose.yml](https://github.com/supabase/supabase/blob/master/docker/docker-compose.yml).

Everything you need to care about is in the [`.env`](.env) file, which contains important settings for supabase. It is already configured to use the `pg-meta`.`supa` database by default, You have to change that according to your actual deployment. 

```bash
POSTGRES_PASSWORD=DBUser.Supa       # supabase dbsu password (shared by multiple supabase biz users)
JWT_SECRET=your-super-secret-jwt-token-with-at-least-32-characters-long
ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE
SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJzZXJ2aWNlX3JvbGUiLAogICAgImlzcyI6ICJzdXBhYmFzZS1kZW1vIiwKICAgICJpYXQiOiAxNjQxNzY5MjAwLAogICAgImV4cCI6IDE3OTk1MzU2MDAKfQ.DaYlNEoUrrEn2Ig7tqibS-PHK5vgusbcbo7X36XVt4Q
DASHBOARD_USERNAME=supabase         # change to your own username
DASHBOARD_PASSWORD=pigsty           # change to your own password

POSTGRES_HOST=10.10.10.10           # change to Pigsty managed PostgreSQL cluster/instance VIP/IP/Hostname
POSTGRES_PORT=5432                  # you can use other service port such as 5433, 5436, 6432, etc...
POSTGRES_DB=postgres                # change to supabase database name, `supa` by default in pigsty
```

Usually you'll have to change these parameters accordingly. Here we'll use fixed username, password and IP:Port database connect string for simplicity.

The postgres username is fixed as `supabase_admin` and the password is `DBUser.Supa`, change that according to your [`supabase.yml`](https://github.com/Vonng/pigsty/blob/master/conf/sample/supabase.yml#L43)
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



-----------------------

## Expose Service

The supabase studio dashboard is exposed on port `8000` by default, you can add this service to the `infra_portal` to expose it to the public through Nginx and SSL. 

```yaml
    infra_portal:                     # domain names and upstream servers
      # ...
      supa         : { domain: supa.pigsty ,endpoint: "10.10.10.10:8000", websocket: true }
```

To expose the service, you can run the `infra.yml` playbook with the `nginx` tag:

```bash
./infra.yml -t nginx
```

Make suare `supa.pigsty` or your own domain is resolvable to the `infra_portal` server, and you can access the supabase studio dashboard via `https://supa.pigsty`.
