# Install Applications

Pigsty can be used to deploy and monitor PostgreSQL and make and distribute data **Applications**. 

Pigsty provides three sample applications.

* [`pglog`](#PGLOG-CSVLOG-Sample-Analysis), which analyzes PostgreSQL CSV log samples.
* [`covid`](#COVID), which visualizes WHO COVID-19 data and accesses country outbreak data.
* [`pglog`](#ISD), NOAA ISD, allows querying weather observation records from 1901 for 30,000 surface weather stations.



## Structure of the application

A Pigsty application typically includes at least one or all of the following.

* A graphical interface (Grafana Dashboard Definition) placed in the `ui` dir.
* Data definitions (PostgreSQL DDL File), placed in the `sql` dir.
* Data files (various resources, files to download), placed in the `data` dir.
* Logical scripts (executing various types of logic), placed in the `bin` dir.

A Pigsty application will provide an installation script in the application root dir: `install` or a shortcut to it. You need to use an [admin user](d-prepare.md#admin-provisioning) to install the [meta node](d-prepare.md#meta-node-provisioning). The installation script detects the current environment (gets `METADB_URL`, `PIGSTY_HOME`, `GRAFANA_ENDPOINT` to perform the installation).

Dashboards with the `APP` label are included in the App drop-down menu in the Pigsty Grafana home page navigation. The home page dashboard navigation includes dashboards with the  `APP` and  `Overview` labels.

You can download the app with the base data from https://github.com/Vonng/pigsty/releases/download/v1.5.0-rc/app.tgz.





## COVID

A more straightforward sample data application: visualize WHO COVID-19 data and access country outbreak data.

Public demo: http://demo.pigsty.cc/d/covid-overview

### Installation method

```bash
cd covid
make all # Full installation (will download the latest data from WHO)
make all2 # Complete installation (will use the local downloaded data directly)
```

For finer control.

```bash
make ui # install covid dashboards to grafana
make sql # Create covid database table definitions into metadb
make download # Download the latest WHO data
make load # Load the downloaded WHO data
make reload # download + load
```

If data is already downloaded (e.g., get applications via downloading app.tgz), run `make all2` instead to skip the download.





## ISD

A feature-complete data application that queries 30,000 surface weather stations worldwide for weather observations from 1901 onwards.

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



## PGLOG CSVLOG Sample Analysis

PGLOG Analysis & PGLOG Session provide introspection about PostgreSQL csvlog sample (via table `pglog.sample` on cmdb).
* [PGLOG Analysis](http://demo.pigsty.cc/d/pglog-overview): Analysis of csvlog sample on CMDB (focusing on **entire** log sample).
* [PGLOG Session](http://demo.pigsty.cc/d/pglog-session): Analysis of csvlog sample (focusing on the single **session**).


There are some handy alias & func sets on the meta node.

Load csvlog from stdin into sample table.
```bash
alias pglog="psql service=meta -AXtwc 'TRUNCATE pglog.sample; COPY pglog.sample FROM STDIN CSV;'"  # useful alias
```

Get log from pgsql node.

```bash
# default: get pgsql csvlog (localhost @ today) 
function catlog(){ # getlog <ip|host> <date:YYYY-MM-DD>
    local node=${1-'127.0.0.1'}
    local today=$(date '+%Y-%m-%d')
    local ds=${2-${today}}
    ssh -t "${node}" "sudo cat /pg/data/log/postgresql-${ds}.csv"
}
```

Combine theme to fetch and load csvlog sample.

```bash
catlog | pglog                       # get local (metadb) today's log
catlog node-1 '2021-07-15' | pglog   # get node-1's csvlog @ 2021-07-15 
```

