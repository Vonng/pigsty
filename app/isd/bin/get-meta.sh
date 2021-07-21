#!/usr/bin/env bash
set -uo pipefail

#==============================================================#
# File      :   get-meta.sh
# Mtime     :   2021-07-21
# Desc      :   Get ISD Meta Data from Github
# Path      :   bin/get-meta.sh
# Note      :   Data are downloaded to data/meta
# Author    :   Vonng (rh@vonng.com)
# Depend    :   curl
# Usage     :   bin/get-meta.sh
#==============================================================#
PROG_DIR="$(cd $(dirname $0) && pwd)"
PROG_NAME="$(basename $0)"
PROJ_DIR=$(dirname $PROG_DIR)


function log_info (){
    [ -t 2 ] && printf "\033[0;32m[$(date "+%Y-%m-%d %H:%M:%S")][INFO] $*\033[0m\n" 1>&2 || printf "[$(date "+%Y-%m-%d %H:%M:%S")][INFO] $*\n" 1>&2
}

DATA_DIR="${PROJ_DIR}/data/meta"
log_info "mkdir ${DATA_DIR}"
mkdir -p ${DATA_DIR}
cd ${DATA_DIR}

log_info "download isd_elements, isd_mwcode, china_fences, world_fences from github"

log_info "get isd_elements"
curl -SLO https://github.com/Vonng/isd/raw/main/data/meta/isd_elements.csv.gz

log_info "get isd_mwcode"
curl -SLO https://github.com/Vonng/isd/raw/main/data/meta/isd_mwcode.csv.gz

log_info "get china_fences"
curl -SLO https://github.com/Vonng/isd/raw/main/data/meta/china_fences.csv.gz

log_info "get world_fences"
curl -SLO https://github.com/Vonng/isd/raw/main/data/meta/world_fences.csv.gz

log_info "meta data download complete, load with 'make load-meta'"
