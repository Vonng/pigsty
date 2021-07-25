# ISD —— Integrated Surface Data

## SYNOPSIS

Download, Parse, Visualize Integrated Surface Dataset

Including 30000 meteorology station, sub-hourly observation records, from 1900-2021.


## Quick Start

`make all` will setup everything

> Internet (Github & noaa) access required  
> if basic data included (e.g download app.tgz), use `make all2` instead


### Make Baseline Works

Run `make baseline` will create a minimal usable production via:

```bash
make sql        # load isd database schema into postgres (via PGURL env)
make ui         # setup grafana dashboards
make download   # download meta data (dict) & parsers
make load-meta  # load meta-data into database
```

### Get This Year's Daily Summary

Get latest daily observation summary (daily, monthly, yearly)

> NOTICE: Will download directly from noaa. (check your proxy if too slow! about 60MB per year)
> around 3~4 GB original zipped file, 20 GB in database

Run `make reload` will load minimal data (this year so far) to database.

```bash
make get-daily   # get latest observation daily summary (of latest year e.g 2021)
make load-daily  # load latest daily data into database (of latest year e.g 2021)
make refresh     # refresh monthly & yearly data based on daily data 
```
ISD Daily and ISD hourly dataset will roll update each day. Run these commands to get daily update.


### Get This Year's Hourly Raw Data

Get the latest hourly observation raw data (not recommended)

> WARNING: hourly raw data are large dataset with tons of noisy. around 5GB per year
> around 100 GB original zipped file, 1TB in database 

Run `make reload-hourly` will load minimal raw data (this year so far) to database.

```bash
make get-hourly   # get latest observation daily summary (of latest year e.g 2021)
make load-hourly  # load latest daily data into database (of latest year e.g 2021) 
```

### Pour more historic data

You can download hourly & daily data by specific year.

```bash
# bin/get-daily.sh <year> will get specific year's observation daily summary (1929-2021)
bin/get-daily.sh 2020     # get 2020 data

# bin/get-hourly.sh <year> will get latest observation daily summary (1900-2021)
bin/get-hourly.sh 2020 
```

And load them into database with parser:

```bash
# bin/load-daily.sh <PGURL> <year> will load <year>'s daily summary into PGURL database 
bin/load-daily.sh service=meta 2020     # note there may have some dirty data that violate constraints

# bin/load-hourly.sh <PGURL> <year> will load <year>'s raw hourly data into PGURL database
bin/load-hourly.sh service=meta 2020
```


## Data

### Dataset

| Dataset     | Sample                                             | Document                                               | Comment                           |
| ----------- | -------------------------------------------------- | ------------------------------------------------------ | --------------------------------- |
| ISD Hourly  | [isd-hourly-sample.csv](doc/isd-hourly-sample.csv) | [isd-hourly-document.pdf](doc/isd-hourly-document.pdf) | (Sub-) Hour oberservation records |
| ISD Daily   | [isd-daily-sample.csv](doc/isd-daily-sample.csv)   | [isd-daily-format.txt](doc/isd-daily-format.txt)       | Daily summary                     |
| ISD Monthly | N/A                                                | [isd-gsom-document.pdf](doc/isd-gsom-document.pdf)     | Not used, gen from daily          |
| ISD Yearly  | N/A                                                | [isd-gsoy-document.pdf](doc/isd-gsoy-document.pdf)     | Not used, gen from monthly        |

Hourly Data: Original tarball size 105 GB, Table size 1TB (+600 GB Indexes).

Daily Data: Original tarball size 3.2GB, table size 24 GB

It is recommended to have 2 TB storage for a full installation, and at least 40 GB for daily data only installation.  



### Schema

Data schema [definition](sql/schema.sql)

#### Station

```sql
CREATE TABLE isd.station
(
    station    VARCHAR(12) PRIMARY KEY,
    usaf       VARCHAR(6) GENERATED ALWAYS AS (substring(station, 1, 6)) STORED,
    wban       VARCHAR(5) GENERATED ALWAYS AS (substring(station, 7, 5)) STORED,
    name       VARCHAR(32),
    country    VARCHAR(2),
    province   VARCHAR(2),
    icao       VARCHAR(4),
    location   GEOMETRY(POINT),
    longitude  NUMERIC GENERATED ALWAYS AS (Round(ST_X(location)::NUMERIC, 6)) STORED,
    latitude   NUMERIC GENERATED ALWAYS AS (Round(ST_Y(location)::NUMERIC, 6)) STORED,
    elevation  NUMERIC,
    period     daterange,
    begin_date DATE GENERATED ALWAYS AS (lower(period)) STORED,
    end_date   DATE GENERATED ALWAYS AS (upper(period)) STORED
);
```

#### Hourly Data

```sql
CREATE TABLE isd.hourly
(
    station    VARCHAR(11) NOT NULL,
    ts         TIMESTAMP   NOT NULL,
    temp       NUMERIC(3, 1),
    dewp       NUMERIC(3, 1),
    slp        NUMERIC(5, 1),
    stp        NUMERIC(5, 1),
    vis        NUMERIC(6),
    wd_angle   NUMERIC(3),
    wd_speed   NUMERIC(4, 1),
    wd_gust    NUMERIC(4, 1),
    wd_code    VARCHAR(1),
    cld_height NUMERIC(5),
    cld_code   VARCHAR(2),
    sndp       NUMERIC(5, 1),
    prcp       NUMERIC(5, 1),
    prcp_hour  NUMERIC(2),
    prcp_code  VARCHAR(1),
    mw_code    VARCHAR(2),
    aw_code    VARCHAR(2),
    pw_code    VARCHAR(1),
    pw_hour    NUMERIC(2),
    data       JSONB
) PARTITION BY RANGE (ts);
```

#### Daily Data

```sql
CREATE TABLE isd.daily
(
    station     VARCHAR(12) NOT NULL,
    ts          DATE        NOT NULL,
    temp_mean   NUMERIC(3, 1),
    temp_min    NUMERIC(3, 1),
    temp_max    NUMERIC(3, 1),
    dewp_mean   NUMERIC(3, 1),
    slp_mean    NUMERIC(5, 1),
    stp_mean    NUMERIC(5, 1),
    vis_mean    NUMERIC(6),
    wdsp_mean   NUMERIC(4, 1),
    wdsp_max    NUMERIC(4, 1),
    gust        NUMERIC(4, 1),
    prcp_mean   NUMERIC(5, 1),
    prcp        NUMERIC(5, 1),
    sndp        NuMERIC(5, 1),
    is_foggy    BOOLEAN,
    is_rainy    BOOLEAN,
    is_snowy    BOOLEAN,
    is_hail     BOOLEAN,
    is_thunder  BOOLEAN,
    is_tornado  BOOLEAN,
    temp_count  SMALLINT,
    dewp_count  SMALLINT,
    slp_count   SMALLINT,
    stp_count   SMALLINT,
    wdsp_count  SMALLINT,
    visib_count SMALLINT,
    temp_min_f  BOOLEAN,
    temp_max_f  BOOLEAN,
    prcp_flag   CHAR,
    PRIMARY KEY (ts, station)
) PARTITION BY RANGE (ts);
```


## Parser

There are two parser: [`isdd`](parser/isdd/isdd.go) and [`isdh`](parser/isdh/isdh.go), which takes noaa original yearly tarball as input, generate CSV as output (which could be directly consume by PostgreSQL Copy command). 

```bash
NAME
	isdh -- Intergrated Surface Dataset Hourly Parser

SYNOPSIS
	isdh [-i <input|stdin>] [-o <output|st>] -p -d -c -v

DESCRIPTION
	The isdh program takes isd hourly (yearly tarball file) as input.
	And generate csv format as output

OPTIONS
	-i	<input>		input file, stdin by default
	-o	<output>	output file, stdout by default
	-p	<profpath>	pprof file path (disable by default)	
	-v                verbose progress report
	-d                de-duplicate rows (raw, ts-first, hour-first)
	-c                add comma separated extra columns
```



