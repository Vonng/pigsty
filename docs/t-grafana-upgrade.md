# Grafana Upgrade

You can use postgres as grafana backend database.

It could be a good chance to get start with a vivid use-case of pigsty


### 1. Create new users for grafana

Add this new business user definition to `pigsty.yml`  (`all.children.pg-meta.vars.pg_users`)

> (You can just uncomment that definition in default pigsty.yml file)

```yaml
- {name: dbuser_grafana    , password: DBUser.Grafana    ,pgbouncer: true ,roles: [dbrole_admin], comment: admin user for grafana database }
```   

Create that user with playbook `pgsql-createuser.yml` or wrapper script `bin/createuser`

```bash
bin/createuser            pg-meta            dbuser_grafana      # create user `dbuser_grafana` on cluster `pg-meta`
./pgsql-createuser.yml -l pg-meta -e pg_user=dbuser_grafana      # which actually transfer into this
```

### 2. Create new database for grafana


Add this new business database definition to `pigsty.yml`  (`all.children.pg-meta.vars.pg_databases`)

> (You can just uncomment that definition in default pigsty.yml file)

```yaml
- { name: grafana,    owner: dbuser_grafana    , revokeconn: true , comment: grafana    primary database }
```   

Create database with playbook `pgsql-createdb.yml` or wrapper script `bin/createdb`

```bash
bin/createdb            pg-meta                grafana      # create database `grafana` on cluster `pg-meta`
./pgsql-createdb.yml -l pg-meta -e pg_database=grafana      # which actually transfer into this
```




### 3. Configure grafana with PostgreSQL connection string



1. change `pigsty.yml` configuration

    * `grafana_database` : `sqlite3` to `postgres`
    * `grafana_pgurl` :  example `postgres://dbuser_grafana:DBUser.Grafana@10.10.10.10:5436/grafana`

2. re-init grafana with playbook

   ```bash
   ./infra.yml -t grafana 
   ```
   
3. re-register all pgsql datasource to grafana (optional)

    ```bash
    ./pgsql.yml -t register_grafana
    ```
   
Now grafana is using postgres as backend database.

