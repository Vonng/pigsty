#!/usr/bin/env bash
set -uo pipefail

#==============================================================#
# File      :   load-daily.sh
# Mtime     :   2020-11-03
# Desc      :   Load ISD daily Dataset (specific year) to database
# Path      :   bin/load-daily.sh
# Author    :   Vonng(fengruohang@outlook.com)
# Depend    :   curl
# Usage     :   bin/load-daily.sh [pgurl=postgres:///] [year=this-year]
#==============================================================#
PROG_DIR="$(cd $(dirname $0) && pwd)"
PROG_NAME="$(basename $0)"
PROJ_DIR=$(dirname $PROG_DIR)

# PGURL specify target database connection string
PGURL=${1-'postgres:///'}
PARSER="${PROJ_DIR}/bin/isdd"
DATA_DIR="${PROJ_DIR}/data/daily"

function log_info (){
    [ -t 2 ] && printf "\033[0;32m[$(date "+%Y-%m-%d %H:%M:%S")][INFO] $*\033[0m\n" 1>&2 || printf "[$(date "+%Y-%m-%d %H:%M:%S")][INFO] $*\n" 1>&2
}

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

# get year record count
sql="SELECT count(*) FROM isd.daily WHERE ts >= '${year}-01-01' AND ts < '${next_year}-01-01';"
count=$(psql ${PGURL} -AXtwqc "${sql}")
log_info "Year ${year} got ${count} records"

# delete year records
log_info "DELETE FROM isd.daily WHERE ts >= '${year}-01-01' AND ts < '${next_year}-01-01';"
sql="DELETE FROM isd.daily WHERE ts >= '${year}-01-01' AND ts < '${next_year}-01-01';"
psql ${PGURL} -AXtwqc "${sql}"

log_info "VACUUM isd.daily"
psql ${PGURL} -AXtwqc 'VACUUM isd.daily;'

log_info "parser=${PARSER}, input=${DATA_DIR}/${year}.tar.gz"
${PARSER} -v -i "${DATA_DIR}/${year}.tar.gz" | psql ${PGURL} -AXtwqc "COPY isd.daily FROM STDIN CSV;"
