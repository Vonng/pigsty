# Install Applications

Pigsty can be used not only for deploying and monitoring PostgreSQL, but also for creating and distributing data-like **applications** (Applications).

The `PGSQL`, `PGLOG`, and `PGCAT` used to monitor the system are also developed and distributed as applications. In addition, Pigsty provides two sample applications: [`covid`](#covid) and [`isd`](#isd)



## Structure of the application

A Pigsty application typically includes at least one or all of the following.

* Graphical interface (Grafana Dashboard definition) Placed in the `ui` directory
* Data definitions (PostgreSQL DDL File) placed in the `sql` directory
* Data files (various resources, files to download), placed in the `data` directory
* Logical scripts (executing various types of logic), placed in the `bin` directory

A Pigsty application will provide an installation script in the application root directory: `install` or a shortcut to it. You need to use [admin-user](t-prepare.md#manage application provisioning) to perform the installation at [admin-node](t-prepare.md#manage node provisioning). The installation script will check the current environment (get `METADB_URL`, `PIGSTY_HOME`, `GRAFANA_ENDPOINT`, etc. to perform the installation)

You can download the application installation with the base data from https://github.com/Vonng/pigsty/releases/download/v1.4.0/app.tgz.



## COVID

A simpler sample data application: visualize WHO COVID-19 data and access country outbreak data.

Public demo: http://demo.pigsty.cc/d/covid-overview

### Installation method

```bash
cd covid
make all # Full installation (will download the latest data from WHO)
make all2 # Complete installation (will use the local downloaded data directly)
```

For finer control.

```
make ui # install covid dashboards to grafana
make sql # Create covid database table definitions into metadb
make download # Download the latest WHO data
make load # Load the downloaded WHO data
make reload # download + load
```

Or just use `make all` to setup all stuff for you. If data is already downloaded (e.g get applications via downloading app.tgz), run `make all2` instead to skip download.





## ISD

A feature-complete data application that queries 30,000 surface weather stations around the world for weather observations from 1901 onwards.

Public demo: http://demo.pigsty.cc/d/isd-overview

Project address: https://github.com/Vonng/isd

### Installation

```bash
cd isd
make all # Complete installation (will download the latest data from Github and NOAA)
make all2 # Complete installation (will use the locally downloaded data directly)
```

For more fine-grained control.

```bash
make ui # install covid dashboards to grafana
make sql # Create covid database table definitions into metadb
make download # Download the latest NOAA data, ISD Parser, dictionary tables
make baseline # Initialize the most basic global schema functions with the downloaded data
make reload # Download the latest daily summary from NOAA and parse and load it
```



## PGLOG csvlog sample analysis

PGLOG Analysis & PGLOG Session provide introspection about PostgreSQL csvlog sample (via table `pglog.sample` on cmdb)
* [PGLOG Analysis](http://g.pigsty.cc/pglog-analysis): Analysis csvlog sample on CMDB (focusing on **entire** log sample)
* [PGLOG Session](http://g.pigsty.cc/pglog-session): Analysis csvlog sample (focusing on single **session**)


There are some handy alias & func set on meta node:

Load csvlog from stdin into sample table:
```bash
alias pglog="psql service=meta -AXtwc 'TRUNCATE pglog.sample; COPY pglog.sample FROM STDIN CSV;'"  # useful alias
```

Get log from pgsql node

```bash
# default: get pgsql csvlog (localhost @ today) 
function catlog(){ # getlog <ip|host> <date:YYYY-MM-DD>
    local node=${1-'127.0.0.1'}
    local today=$(date '+%Y-%m-%d')
    local ds=${2-${today}}
    ssh -t "${node}" "sudo cat /pg/data/log/postgresql-${ds}.csv"
}
```

Combine theme to fetch and load csvlog sample

```bash
catlog | pglog                       # get local (metadb) today's log
catlog node-1 '2021-07-15' | pglog   # get node-1's csvlog @ 2021-07-15 
```

