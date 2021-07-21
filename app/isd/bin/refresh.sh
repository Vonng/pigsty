#!/usr/bin/env bash
set -uo pipefail

#==============================================================#
# File      :   load-isd-daily.sh
# Mtime     :   2020-11-03
# Desc      :   Load ISD daily Dataset (specific year) to database
# Path      :   bin/load-isd-daily.sh
# Author    :   Vonng(fengruohang@outlook.com)
# Depend    :   curl
# Usage     :   bin/load-isd-daily.sh [pgurl=isd] [year=2020]
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

log_info "refresh latest monthly & yearly data"
psql ${PGURL} -AXtwqc 'SELECT isd.refresh()'

