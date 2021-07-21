# ISD —— Intergrated Surface Data



## SYNOPSIS

Download, Parse, Visualize Intergrated Suface Dataset.

Including 30000 meteorology station, sub-hourly observation records, from 1900-2020.



## Quick Started

1. **Clone repo**

    ```bash
   git clone https://github.com/Vonng/isd && cd isd 
   ```

2. **Prepare a postgres database** 

    Connect via something like `isd` or `postgres://user:pass@host/dbname`)
   
   ```bash
   # skip this if you already have a viable database
   PGURL=postgres
   psql ${PGURL} -c 'CREATE DATABASE isd;'
   
   # database connection string, something like `isd` or `postgres://user:pass@host/dbname`
   PGURL='isd'
   psql ${PGURL} -AXtwc 'CREATE EXTENSION postgis;'
   
   # create tables, partitions, functions
   psql ${PGURL} -AXtwf 'sql/schema.sql'
   ```
   
3. **Download data**

    * [ISD Station](https://www1.ncdc.noaa.gov/pub/data/noaa/isd-history.csv): Station metadata, id, name, location, country, etc...  
    * [ISD History](https://www1.ncdc.noaa.gov/pub/data/noaa/isd-inventory.csv.z): Station observation records: observation count per month 
    * [ISD Hourly](https://www.ncei.noaa.gov/data/global-hourly/archive/csv/): Yearly archived station (sub-)hourly observation records  
    * [ISD Daily](https://www.ncei.noaa.gov/data/global-summary-of-the-day/archive/): Yearly archvied station daily aggregated summary
    
    ```bash
    git clone https://github.com/Vonng/isd && cd isd
    bin/get-isd-station.sh         # download isd station from noaa (proxy makes it faster)
    bin/get-isd-history.sh         # download isd history observation from noaa
    bin/get-isd-hourly.sh <year>   # download isd hourly data (yearly tarball 1901-2020)
    bin/get-isd-daily.sh <year>    # download isd daily data  (yearly tarball 1929-2020) 
    ```

4. **Build Parser**

   There are two ISD dataset parsers written in Golang : [`isdh`](parser/isdh/isdh.go) for isd hourly dataset and [`isdd`](parser/isdd/isdd.go) for isd daily dataset.
   
   `make isdh` and `make isdd` will build it and copy to bin. These parsers are required for loading data into database. 
   
   You can [download](https://github.com/Vonng/isd/releases/tag/v0.1.0) pre-compiled binary to [bin/](bin/) dir to skip this phase.
   
5. **Load data**

   Metadata includes `world_fences`, `china_fences`, `isd_elements`, `isd_mwcode`, `isd_station`, `isd_history`. These are gzipped csv file lies in [`data/meta/`](data/meta/). `world_fences`, `china_fences`, `isd_elements`, `isd_mwcode` are constant dict table. But  `isd_station` and `isd_history` are frequently updated. You'll have to download it from noaa before loading it.   
   
   ```bash
   # load metadata: fences, dicts, station, history,...
   bin/load-meta.sh 
   
   # load a year's daily data to database 
   bin/load-isd-daily <year> 
   
   # load a year's hourly data to database
   bin/laod-isd-hourly <year>
   ```
   
      > Note that the original `isd_daily` dataset has some un-cleansed data, refer [caveat](doc/isd-daily-caveat.md) for detail.  
   
   

## Data

### Dataset

| Dataset     | Sample                                             | Document                                               | Comment                           |
| ----------- | -------------------------------------------------- | ------------------------------------------------------ | --------------------------------- |
| ISD Hourly  | [isd-hourly-sample.csv](doc/isd-hourly-sample.csv) | [isd-hourly-document.pdf](doc/isd-hourly-document.pdf) | (Sub-) Hour oberservation records |
| ISD Daily   | [isd-daily-sample.csv](doc/isd-daily-sample.csv)   | [isd-daily-format.txt](doc/isd-daily-format.txt)       | Daily summary                     |
| ISD Monthly | N/A                                                | [isd-gsom-document.pdf](doc/isd-gsom-document.pdf)     | Not used, gen from daily          |
| ISD Yearly  | N/A                                                | [isd-gsoy-document.pdf](doc/isd-gsoy-document.pdf)     | Not used, gen from monthly        |

Hourly Data: Oringinal tarball size 105GB, Table size 1TB (+600GB Indexes).

Daily Data: Oringinal tarball size 3.2GB, table size 24 GB

It is recommended to have 2TB storage for a full installation, and at least 40GB for daily data only installation.  



### Schema

Data schema [definition](sql/schema.sql)

#### Station

```sql
CREATE TABLE public.isd_station
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
CREATE TABLE public.isd_hourly
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
CREATE TABLE public.isd_daily
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

### Update

ISD Daily and ISD hourly dataset will rolling update each day. Run following scripts to load latest data into database.

```bash
# download, clean, reload latest hourly dataset
bin/get-isd-daily.sh
bin/load-isd-daily.sh

# download, clean, reload latest daily dataset
bin/get-isd-daily.sh
bin/load-isd-daily.sh

# recalculate latest partition of monthly and yearly
bin/refresh-latest.sh
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



