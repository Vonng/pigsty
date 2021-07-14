# Dashboards

## Baseline Dashboards (core application)

## [pgsql](pgsql/)

    PostgreSQL Metrics Monitoring


## [pglog](pglog/)

    PostgreSQL Log Analysis


## [pgdog](pgcat/)
    
    PostgreSQL Catalog Explore


## Provisioning Script

[grafana.py](grafana.py)


```bash
./grafana.py init       # init pigsty baseline dashboards
./grafana.py dump .     # dump pigsty dashboards to current dir
./grafana.py load .     # load pigsty dashboards fomr current dir
./grafana.py clean .    # remove target grafana dashboards & folders
```