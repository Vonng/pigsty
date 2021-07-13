# Grafana Upgrade

You can use postgres as grafana backend database

1. change `pigsty.yml` configuration

    from `grafana_database: sqlite3` to `grafana_database: postgres`


2. re-init grafana with playbook

   ```bash
   ./infra.yml -t grafana 
   ```
   
3. re-register all pgsql datasource to grafana (optional)

    ```bash
    ./pgsql.yml -t register_grafana
    ```
   
Now grafana is using postgres as backend database.

Check PGCAT TABLE Dashboard for grafana database content