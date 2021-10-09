# Applog Visualization

Visualize apple privacy log

```bash
make ui          # install applog dashboards to grafana
make sql         # install applog database schema to metadb 
make load        # load log.csv into database 
```

Or just use `make all` to prepare all stuff for you.

```bash
make all   # setup everything
```

How to pour data into table?

```bash
cat /tmp/App_Privacy_Report_v4_2021-10-09T09_35_45.ndjson \
  | psql -AXtwc 'TRUNCATE applog.t_privacy_log;COPY applog.t_privacy_log FROM STDIN;REFRESH MATERIALIZED VIEW applog.privacy_log;'
```




