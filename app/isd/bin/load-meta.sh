#!/usr/bin/env bash
set -uo pipefail

#==============================================================#
# File      :   load-meta.sh
# Mtime     :   2020-09-09
# Desc      :   Load isd mwcode/elements china|world fences into db
# Path      :   bin/load-meta.sh
# Author    :   Vonng (fengruohang@outlook.com)
#==============================================================#

PROG_DIR="$(cd $(dirname $0) && pwd)"
PROG_NAME="$(basename $0)"
PROJ_DIR=$(dirname $PROG_DIR)

function log_info (){
    [ -t 2 ] && printf "\033[0;32m[$(date "+%Y-%m-%d %H:%M:%S")][INFO] $*\033[0m\n" 1>&2 || printf "[$(date "+%Y-%m-%d %H:%M:%S")][INFO] $*\n" 1>&2
}

# data are downloaded to ../data/meta/isd-inventory.csv.z
DATA_DIR="${PROJ_DIR}/data/meta"
cd ${DATA_DIR}

# PGURL specify target database connection string
PGURL=${1-'postgres:///'}


log_info "truncate meta tables"
psql ${PGURL} -AtXwc 'TRUNCATE isd.china_fences, isd.world_fences, isd.elements, isd.mwcode;'

# load dict tables
log_info "load meta data"
cat ${DATA_DIR}/china_fences.csv.gz | gzip -d | psql ${PGURL} -AtXwc 'COPY isd.china_fences FROM stdin CSV HEADER;'
cat ${DATA_DIR}/world_fences.csv.gz | gzip -d | psql ${PGURL} -AtXwc 'COPY isd.world_fences FROM stdin CSV HEADER;'
cat ${DATA_DIR}/isd_elements.csv.gz | gzip -d | psql ${PGURL} -AtXwc 'COPY isd.elements FROM stdin CSV HEADER;'
cat ${DATA_DIR}/isd_mwcode.csv.gz   | gzip -d | psql ${PGURL} -AtXwc 'COPY isd.mwcode FROM stdin CSV HEADER;'


# load isd station data
log_info "create isd.t_station temp table"
psql ${PGURL} -AXtw <<-EOF
-----------------------------------------------------------------------
-- Temp Table isd.t_station
-----------------------------------------------------------------------
DROP TABLE IF EXISTS isd.t_station;
CREATE TABLE isd.t_station
(
    usaf       TEXT,
    wban       TEXT,
    name       TEXT,
    ctry       TEXT,
    st         TEXT,
    icao       TEXT,
    lat        TEXT,
    lon        TEXT,
    elev       TEXT,
    begin_date DATE,
    end_date   DATE
);
EOF

log_info "load isd station data into isd.t_station"
cat ${DATA_DIR}/isd_station.csv.gz | gzip -d |
  psql ${PGURL} -AXtwc "COPY isd.t_station FROM STDIN WITH (FORMAT CSV, HEADER ,FORCE_NULL (usaf,wban,name,ctry,st,icao,lat,lon,elev,begin_date,end_date));"

log_info "build isd.station from isd.t_station"
psql ${PGURL} -AXtw <<-EOF
-----------------------------------------------------------------------
-- Build Final Data
-----------------------------------------------------------------------
TRUNCATE isd.station;
INSERT INTO isd.station(station, name, country, province, icao, location, elevation, period)
SELECT (usaf || wban)::VARCHAR(12)                                     AS station,
       name::VARCHAR(32),
       ctry::VARCHAR(2)                                                AS country,
       st::VARCHAR(2)                                                  AS province,
       icao::VARCHAR(4),
       ST_SetSRID(ST_Point(lon::numeric, lat::numeric), 4326)          AS location,
       CASE WHEN elev ~ '-0999' THEN NULL ELSE elev::NUMERIC::FLOAT END AS elevation,
       daterange(begin_date::DATE, end_date::DATE, '[]')               AS duration
FROM isd.t_station;
DROP TABLE IF EXISTS isd.t_station;
EOF


# load isd history data
log_info "create isd.t_history temp table"
psql ${PGURL} -AXtw <<-EOF
-----------------------------------------------------------------------
-- Temp Table isd.t_history
-----------------------------------------------------------------------
DROP TABLE IF EXISTS isd.t_history;
CREATE TABLE isd.t_history
(
    usaf VARCHAR(6),
    wban VARCHAR(5),
    year INTEGER,
    m1   INTEGER,
    m2   INTEGER,
    m3   INTEGER,
    m4   INTEGER,
    m5   INTEGER,
    m6   INTEGER,
    m7   INTEGER,
    m8   INTEGER,
    m9   INTEGER,
    m10  INTEGER,
    m11  INTEGER,
    m12  INTEGER,
    PRIMARY KEY (usaf, wban, year)
);
EOF

log_info "load isd history data into isd.t_history"
cat ${DATA_DIR}/isd_history.csv.gz | gzip -d |
  psql ${PGURL} -AXtwc "COPY isd.t_history FROM STDIN WITH (FORMAT CSV, HEADER,FORCE_NULL(usaf,wban,year,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12));"

log_info "build isd.history from isd.t_history"
psql ${PGURL} -AXtw <<-EOF
-----------------------------------------------------------------------
-- Build Final Data
-----------------------------------------------------------------------
TRUNCATE isd.history;
INSERT INTO isd.history(station, year, country, active_month, total, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12)
SELECT i.station,year,country,active_month,total,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12
FROM (SELECT usaf || wban                                                 AS station,
             make_date(year, 1, 1)::DATE                                  AS year,
             m1 + m2 + m3 + m4 + m5 + m6 + m7 + m8 + m9 + m10 + m11 + m12 AS total,
             m1::BOOLEAN::INT + m2::BOOLEAN::INT + m3::BOOLEAN::INT + m4::BOOLEAN::INT + m5::BOOLEAN::INT +
             m6::BOOLEAN::INT + m7::BOOLEAN::INT + m8::BOOLEAN::INT + m9::BOOLEAN::INT + m10::BOOLEAN::INT +
             m11::BOOLEAN::INT + m12::BOOLEAN::INT                        AS active_month,
             m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12
      FROM isd.t_history
      ORDER BY 1, 2
     ) i,
     LATERAL (SELECT coalesce(country, 'NA') AS country FROM isd.station h WHERE h.station = i.station) res;
DROP TABLE IF EXISTS isd.t_history;
EOF
