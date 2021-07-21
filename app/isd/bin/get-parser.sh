#!/usr/bin/env bash
set -uo pipefail

#==============================================================#
# File      :   get-parser.sh
# Mtime     :   2021-07-21
# Desc      :   Get ISD Daily & Hourly Parser Binary from Github
# Path      :   bin/get-parser.sh
# Note      :   Parser are downloaded to bin/{isdh,isdd}
# Author    :   Vonng (rh@vonng.com)
# Depend    :   curl
# Usage     :   bin/get-parser.sh [version]
#==============================================================#
PROG_DIR="$(cd $(dirname $0) && pwd)"
PROG_NAME="$(basename $0)"
PROJ_DIR=$(dirname $PROG_DIR)

function log_info (){
    [ -t 2 ] && printf "\033[0;32m[$(date "+%Y-%m-%d %H:%M:%S")][INFO] $*\033[0m\n" 1>&2 || printf "[$(date "+%Y-%m-%d %H:%M:%S")][INFO] $*\n" 1>&2
}

PARSER_VER=${1-v0.1.0}
PARSER_URL=https://github.com/Vonng/isd/releases/download/v0.1.0/isd_linux-amd64.tar.gz

unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
    PARSER_URL="https://github.com/Vonng/isd/releases/download/${PARSER_VER}/isd_linux-amd64.tar.gz"
    log_info "download Linux parser from ${PARSER_URL}"
elif [[ "$unamestr" == 'Darwin' ]]; then
    PARSER_URL="https://github.com/Vonng/isd/releases/download/${PARSER_VER}/isd_darwin-amd64.tar.gz"
    log_info "download MacOs parser from ${PARSER_URL}"
fi

curl -SL ${PARSER_URL} -o bin/isd.tar.gz
cd bin && tar -xf isd.tar.gz

log_info "bin/isdd & bin/isdh for ${unamestr} now available"
