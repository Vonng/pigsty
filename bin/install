#!/bin/bash
# set -o pipefail
#==============================================================#
# File      :   install
# Desc      :   download & install pigsty src
# Ctime     :   2022-10-30
# Mtime     :   2024-09-27
# Path      :   https://repo.pigsty.io/get (global, default)
# Usage     :   curl -fsSL https://repo.pigsty.io/get | bash
# Deps      :   curl
# Author    :   Ruohang Feng (rh@vonng.com)
# License   :   AGPLv3
#==============================================================#
DEFAULT_VERSION=v3.0.3
DEFAULT_REGION=global

# To install the latest version of pigsty (v3.0.3):
# curl -fsSL https://repo.pigsty.io/get | bash

# To install a specific version of pigsty (e.g. v3.0.3)
# curl -fsSL https://repo.pigsty.io/get | bash -s v3.0.3


#--------------------------------------------------------------#
# Log Util
#--------------------------------------------------------------#
# if output is a terminal, setup color alias, else use empty str
if [[ -t 1 ]]; then
    __CN='\033[0m';__CB='\033[0;30m';__CR='\033[0;31m';__CG='\033[0;32m';
    __CY='\033[0;33m';__CB='\033[0;34m';__CM='\033[0;35m';__CC='\033[0;36m';__CW='\033[0;37m';
else
    __CN='';__CB='';__CR='';__CG='';__CY='';__CB='';__CM='';__CC='';__CW='';
fi
function log_info()  { printf "[${__CG} OK ${__CN}] ${__CG}$*${__CN}\n"; }
function log_warn()  { printf "[${__CY}WARN${__CN}] ${__CY}$*${__CN}\n"; }
function log_error() { printf "[${__CR}FAIL${__CN}] ${__CR}$*${__CN}\n"; }
function log_red()   { printf "[${__CR}WARN${__CN}] ${__CR}$*${__CN}\n"; }
function log_debug() { printf "[${__CB}HINT${__CN}] ${__CB}$*${__CN}\n"; }
function log_title() { printf "[${__CG}$1${__CN}] ${__CG}$2${__CN}\n";   }
function log_hint()  { printf "${__CB}$*${__CN}\n"; }
function log_line()  { printf "${__CM}[$*] ===========================================${__CN}\n"; }


#--------------------------------------------------------------#
# Version
#--------------------------------------------------------------#
VALID_VERSIONS="\
v1.0.0 v1.1.1 v1.2.0 v1.3.0 v1.4.0 v1.4.1 v1.5.0 v1.5.1 v2.0.0 \
v2.0.1 v2.0.2 v2.1.0 v2.2.0 v2.3.0 v2.3.1 v2.4.0 v2.4.1 v2.5.0 \
v2.5.1 v2.6.0 v2.7.0 v3.0.0 v3.0.1 v3.0.2 v3.0.3 v3.0.4 v3.1.0"

VERSION=${DEFAULT_VERSION}
VERSION_FROM="default"
KERNEL=$(uname)
ARCH=$(uname -m)

# arg1 > env > default
if [[ -n "$1" ]]; then
    VERSION=$1
    VERSION_FROM="arg"
fi

# validate version string
function check_version(){
    local found=false

    # validate version format
    if [[ ! ${VERSION} =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-[a-z]+[0-9]+)?$ ]]; then
        log_error "invalid version string from ${VERSION_FROM}: ${VERSION}"
        exit 1
    fi

    # check version in table
    for ver in ${VALID_VERSIONS}; do
        if [ "${ver}" = "${VERSION}" ]; then
            found="true"
            break
        fi
    done

    # print version string if valid
    if [[ "${found}" != "true" ]]; then
        log_error "invalid version from ${VERSION_FROM}: ${VERSION}"
        log_hint "valid pigsty versions:"
        for ver in ${VALID_VERSIONS}; do
            log_hint "  - ${ver}"
        done
        exit 1
    fi
}

check_version


#--------------------------------------------------------------#
# Reference
#--------------------------------------------------------------#
log_line "${VERSION}"
log_hint "$ curl -fsSL https://repo.pigsty.io/get | bash"
log_title "Site" "https://pigsty.io"
log_title "Demo" "https://demo.pigsty.cc"
log_title "Repo" "https://github.com/Vonng/pigsty"
log_title "Docs" "https://pigsty.io/docs/setup/install"

log_line "Download"

log_info "version = ${VERSION} (from ${VERSION_FROM})"


#--------------------------------------------------------------#
# Download
#--------------------------------------------------------------#
SRC_FILENAME="pigsty-${VERSION}.tgz"
DOWNLOAD_TO="/tmp/${SRC_FILENAME}"

PIGSTY_IO_BASEURL="https://repo.pigsty.io"
PIGSTY_CC_BASEURL="https://repo.pigsty.cc"

if [[ ${DEFAULT_REGION} == "global" ]]; then
    PRIMARY_SRC_URL="${PIGSTY_IO_BASEURL}/src/${SRC_FILENAME}"
    SECONDARY_SRC_URL="${PIGSTY_CC_BASEURL}/src/${SRC_FILENAME}"
else
    PRIMARY_SRC_URL="${PIGSTY_CC_BASEURL}/src/${SRC_FILENAME}"
    SECONDARY_SRC_URL="${PIGSTY_IO_BASEURL}/src/${SRC_FILENAME}"
fi


# download file from url, if file already exists with same size, skip download
function download_file(){
    local data_url=$1
    local data_file=$2

    log_hint "curl -fSL ${data_url} -o ${data_file}"
    # if file exists and have the exact same size, just use it and skip downloading
    if [[ -f ${data_file} ]]; then
        if [[ "$(uname)" == "Darwin" ]]; then
            size=$(stat -f %z "${data_file}")
        else
            size=$(stat -c %s "${data_file}")
        fi
        curl_size=$(curl -fsLI ${data_url} | grep -i 'Content-Length' | awk '{print $2}' | tr -d '\r')
        if [[ ${size} -eq ${curl_size} ]]; then
        log_warn "tarball = ${data_file} exists, size = ${size}, use it"
        #log_hint "rm -rf ${data_file};  # remove it to redownload source tarball"
        return 0
        fi
    fi
    curl -# -fSL ${data_url} -o ${data_file}
    return $?
}

download_file "${PRIMARY_SRC_URL}" "${DOWNLOAD_TO}"
if [[ $? -ne 0 ]]; then
    log_error "fail to download pigsty source from ${PRIMARY_SRC_URL}"
    log_hint "check: https://pigsty.io/docs/setup/install"
    log_hint "alternative url: ${SECONDARY_SRC_URL}"
    exit 2
fi
log_info "md5sums = $(md5sum ${DOWNLOAD_TO})"


#--------------------------------------------------------------#
# Install
#--------------------------------------------------------------#
INSTALL_TO="${HOME}/pigsty"
INSTALL_DIR=$(dirname ${INSTALL_TO})

log_line "Install"
if [[ $(whoami) == "root" ]]; then
    log_warn "os user = root , it's recommended to install as a sudo-able admin"
fi

# extract to home dir if ~/pigsty not exists
if [[ ! -d ${INSTALL_TO} ]]; then
    log_info "install = ${INSTALL_TO}, from ${DOWNLOAD_TO}"
    tar -xf "${DOWNLOAD_TO}" -C "${INSTALL_DIR}";
else
    log_warn "pigsty already installed on '${INSTALL_TO}', if you wish to overwrite:"
    log_hint "sudo rm -rf /tmp/pigsty_bk; cp -r ${INSTALL_TO} /tmp/pigsty_bk; # backup old"
    log_hint "sudo rm -rf /tmp/pigsty;    tar -xf ${DOWNLOAD_TO} -C /tmp/; # extract new"
    log_hint "rsync -av --exclude='/pigsty.yml' --exclude='/files/pki/***' /tmp/pigsty/ ${INSTALL_TO}/; # rsync src"
fi


#--------------------------------------------------------------#
# Next Hint
#--------------------------------------------------------------#
log_line "TodoList"
log_hint "cd ${INSTALL_TO}"
log_hint './bootstrap      # [OPTIONAL] install ansible & use offline package'
log_hint './configure      # [OPTIONAL] preflight-check and config generation'
log_hint './install.yml    # install pigsty modules according to your config.'

log_line "Complete"
