# Applications

Lots of software using PostgreSQL. Pigsty has some docker compose template for some popular software.

You can launch stateless software with docker easily and using external HA PostgreSQL for higher availability & durability.

Docker is **not** installed by default, You can install docker with `docker.yml` playbook, e.g.: `./docker.yml -l infra`

Available software and their docker-compose template can be found in [pigsty/app](https://github.com/Vonng/pigsty/tree/master/app)

[![pigsty-app.jpg](https://repo.pigsty.cc/img/pigsty-app.jpg)](https://github.com/Vonng/pigsty/tree/master/app)


----------------

## PostgreSQL Administration

> Use more advanced tools to manage PostgreSQL instances / clusters.

* [PgAdmin4](https://github.com/Vonng/pigsty/tree/master/app/pgadmin): A GUI tool for managing PostgreSQL instances.
* [ByteBase](https://github.com/Vonng/pigsty/tree/master/app/bytebase): A GUI IaC tool for PostgreSQL schema migration.
* [PGWeb](https://github.com/Vonng/pigsty/tree/master/app/pgweb): A tool automatically generates back-end API services based on PG database schema.
* [SchemaSPY](https://github.com/Vonng/pigsty/blob/master/bin/schemaspy): Generates detailed visual reports of database schemas.
* [Pgbadger](https://github.com/Vonng/pigsty/blob/master/bin/pglog-summary): Generate PostgreSQL summary report from log samples.


----------------

## Application Development

> Scaffold your application with PostgreSQL and its ecosystem.

* [Supabase](https://github.com/Vonng/pigsty/tree/master/app/supabase): [Supabase](https://supabase.com/) is an open source Firebase alternative based on PostgreSQL
* [FerretDB](https://github.com/Vonng/pigsty/tree/master/app/ferretdb): [FerretDB](https://www.ferretdb.io/), a truly open source MongoDB alternative in PostgreSQL.
* [EdgeDB](https://github.com/Vonng/pigsty/tree/master/app/edgedb): [EdgeDB](https://www.edgedb.com/), open source graph-like database based on PostgreSQL
* [PostgREST](https://github.com/Vonng/pigsty/tree/master/app/postgrest): [PostgREST](https://postgrest.org/en/stable/), serve a RESTful API from any Postgres database automatically.
* [Kong](https://github.com/Vonng/pigsty/tree/master/app/kong): [Kong](https://konghq.com/kong/), a scalable, open source API Gateway with Redis/PostgreSQL/OpenResty
* DuckDB: [DuckDB](https://duckdb.org/), in-process SQL olap DBMS that works well with PostgreSQL

----------------

## Business Software 

> Launch open-source software with PostgreSQL at ease.

* [Wiki.js](https://github.com/Vonng/pigsty/tree/master/app/wiki): [Wiki.js](https://js.wiki/), the most powerful and extensible open source wiki software
* [Gitea](https://github.com/Vonng/pigsty/tree/master/app/gitea): [Gitea](https://gitea.io/), a painless self-hosted git service
* [NocoDB](https://github.com/Vonng/pigsty/tree/master/app/nocodb): [NocoDB](https://nocodb.com/), Open source AirTable alternative.
* Gitlab: open-source code hosting platform.
* Harbour: open-source mirror repo
* Jira: open-source project management platform.
* Confluence: open-source knowledge hosting platform.
* Odoo: open-source ERP
* Mastodon: PG-based social network
* Discourse: open-source forum based on PG and Redis
* Jupyter Lab: A battery-included Python lab environment for data analysis and processing.
* Grafana: use postgres as backend storage
* Promscale: use postgres/timescaledb as prometheus metrics storage


----------------

## Visualization

> Perform data visualization with PostgreSQL, Grafana & Echarts.

* isd: noaa weather data visualization: [github.com/Vonng/isd](https://github.com/Vonng/isd), [Demo](https://demo.pigsty.cc/d/isd-overview)
* pglog: PostgreSQL CSVLOG sample analyzer.  [Demo](https://demo.pigsty.cc/d/pglog-overview)
* covid: Covid-19 data visualization
* dbeng: Database popularity visualization
* price: RDS, ECS price comparison


<details><summary>PGLOG Overview</summary>

[![pglog-overview.jpg](https://repo.pigsty.cc/img/pglog-overview.jpg)](https://demo.pigsty.cc/d/pglog-overview)

</details>


<details><summary>PGLOG Session</summary>

[![pglog-session.jpg](https://repo.pigsty.cc/img/pglog-session.jpg)](https://demo.pigsty.cc/d/pglog-session)

</details>
