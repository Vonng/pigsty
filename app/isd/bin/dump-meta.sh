#!/usr/bin/env bash
set -uo pipefail

#==============================================================#
# File      :   dump-meta.sh
# Mtime     :   2020-09-09
# Desc      :   Dump isd mwcode/elements china|world fences data
# Path      :   bin/dump-meta.sh
# Author    :   Vonng (fengruohang@outlook.com)
#==============================================================#
PROG_DIR="$(cd $(dirname $0) && pwd)"
PROG_NAME="$(basename $0)"
PROJ_DIR=$(dirname $PROG_DIR)

function log_info (){
    [ -t 2 ] && printf "\033[0;32m[$(date "+%Y-%m-%d %H:%M:%S")][INFO] $*\033[0m\n" 1>&2 || printf "[$(date "+%Y-%m-%d %H:%M:%S")][INFO] $*\n" 1>&2
}

# data are dump to ../data/meta/
DATA_DIR="${PROJ_DIR}/data/meta"
cd ${DATA_DIR}

# PGURL specify target database connection string
PGURL=${1-'isd'}


log_info "dump china_fences to china_fences.csv.gz"
psql ${PGURL} -c 'COPY china_fences TO stdout CSV HEADER' | gzip --best > china_fences.csv.gz

log_info "dump world_fences to world_fences.csv.gz"
psql ${PGURL} -c 'COPY world_fences TO stdout CSV HEADER' | gzip --best > world_fences.csv.gz

log_info "dump isd_elements to isd_elements.csv.gz"
psql ${PGURL} -c 'COPY isd_elements TO stdout CSV HEADER' | gzip --best > isd_elements.csv.gz

log_info "dump isd_mwcode to isd_mwcode.csv.gz"
psql ${PGURL} -c 'COPY isd_mwcode TO stdout CSV HEADER'   | gzip --best > isd_mwcode.csv.gz

