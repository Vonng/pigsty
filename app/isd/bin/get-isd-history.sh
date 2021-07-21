#!/usr/bin/env bash
set -uo pipefail

#==============================================================#
# File      :   get-isd-history.sh
# Mtime     :   2020-09-09
# Desc      :   Get ISD History (isd inventory) Dataset from noaa
# Note      :   isd-inventory.csv will be downloaded to ../data/meta/isd-history.csv.gz
# Path      :   bin/get-isd-history.sh
# Author    :   Vonng (fengruohang@outlook.com)
# Depend    :   curl, gzip
#==============================================================#
PROG_DIR="$(cd $(dirname $0) && pwd)"
PROG_NAME="$(basename $0)"
PROJ_DIR=$(dirname $PROG_DIR)

function log_info (){
    [ -t 2 ] && printf "\033[0;32m[$(date "+%Y-%m-%d %H:%M:%S")][INFO] $*\033[0m\n" 1>&2 || printf "[$(date "+%Y-%m-%d %H:%M:%S")][INFO] $*\n" 1>&2
}

# data are downloaded to ../data/meta/isd-inventory.csv.z
DATA_URL="https://www1.ncdc.noaa.gov/pub/data/noaa/isd-inventory.csv.z"
DATA_DIR="${PROJ_DIR}/data/meta"
mkdir -p ${DATA_DIR}
cd ${DATA_DIR}

# curl https://www1.ncdc.noaa.gov/pub/data/noaa/isd-inventory.csv.z -o isd_inventory.csv.z
log_info "curl ${DATA_URL} to isd_history.csv.gz"
curl ${DATA_URL} | gzip -d | gzip --best > isd_history.csv.gz
ls -lh
