# App

These are some applications that can runs on pigsty environment.

If you have trouble downloading data from Github and other original datasource. 
Download `app.tgz` from Github release page which includes basic data

You can install most application by `cd <app> && make all`

If you are using `app.tgz` version, use `make all2` instead which skip data dowloading


## Built-in Application

There are three built-in applications:

* PostgreSQL Monitoring System `<pgsql/>`
* PostgreSQL Log Analyser `<pglog/>`
* PostgreSQL Catalog Explorer `<pgcat/>`


## Demonstration Application

There are several built-in example applications

### [covid](covid/)

* Visualize covid-19 data by country
* new_cases new_death cum_cases cum_death map via echarts

### [isd](isd/)

* Vivid example of Pigsty Datalet, application made of PostgreSQL, Grafana and Echarts
* Download, Parse, Visualize Integrated Surface Dataset.
* Including 30000 meteorology station, sub-hourly observation records, from 1900-2020.
