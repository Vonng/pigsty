#!/usr/bin/env bash
set -uo pipefail

#==============================================================#
# File      :   load-hourly.sh
# Mtime     :   2020-11-03
# Desc      :   Get ISD hourly data (specific year) to database
# Path      :   bin/load-hourly.sh
# Author    :   Vonng(fengruohang@outlook.com)
# Depend    :   curl
# Usage     :   bin/load-hourly.sh [pgurl=postgres:///] [year=this-year]
#==============================================================#

PROG_DIR="$(cd $(dirname $0) && pwd)"
PROG_NAME="$(basename $0)"
PROJ_DIR=$(dirname $PROG_DIR)

function log_info (){
    [ -t 2 ] && printf "\033[0;32m[$(date "+%Y-%m-%d %H:%M:%S")][INFO] $*\033[0m\n" 1>&2 || printf "[$(date "+%Y-%m-%d %H:%M:%S")][INFO] $*\n" 1>&2
}

function get_daily_url(){
  local this_year=$(date '+%Y')
  local year=${1-${this_year}}
  echo "https://www.ncei.noaa.gov/data/global-summary-of-the-day/archive/${year}.tar.gz"
}

# PGURL specify target database connection string
PGURL=${1-'isd'}
PARSER="${PROJ_DIR}/bin/isdh"
DATA_DIR="${PROJ_DIR}/data/hourly"
LOG_DIR="${PROJ_DIR}/log"
mkdir -p ${LOG_DIR}

year=${2-$(date '+%Y')}
next_year=$((year+1))

if (( year > 2030 )); then
  log_info "year ${year} overflow"
  exit 1
fi

if (( year < 1900 )); then
  log_info "year ${year} underflow"
    exit 1
fi


log_info "create isd.hourly partition for year ${year}"
psql ${PGURL} -AXtwc "SELECT isd.create_partition(${year})";

log_info "truncate isd.hourly partition for year ${year}"
psql ${PGURL} -AXtwc "TRUNCATE isd.hourly_${year}";

log_info "load isd.hourly data for year ${year}"
${PARSER} -v -i "${DATA_DIR}/${year}.tar.gz" | psql ${PGURL} -AXtwc "COPY isd.hourly FROM STDIN CSV;"
