#!/bin/bash
set -euo pipefail

#==============================================================#
# File      :   download-exporter.sh
# Ctime     :   2021-02-19
# Mtime     :   2021-02-19
# Desc      :   Download Node & PG Exporter from github
# Path      :   files/download-exporter.sh
# Depend    :   wget
# Copyright (C) 2018-2021 Ruohang Feng
#==============================================================#

#--------------------------------------------------------------#
# Name: download_node_exporter
# Desc: Guarantee a usable node_exporter in ${target_location}
# Arg1: target node_exporter location      (/usr/local/bin/node_exporter)
# Arg2: node_exporter version to download  (1.1.2)
#--------------------------------------------------------------#
function download_node_exporter() {
    local target_location=${1-'./node_exporter'}
    local node_exporter_version=${3-'1.1.2'}

    # if exact same version already in target location, skip
    if [[ -x ${target_location} ]]; then
        echo "warn: found node_exporter ${node_exporter_version} on ${target_location}, skip"
        return 0
    fi
    local node_exporter_filename="node_exporter-${node_exporter_version}.linux-amd64.tar.gz"
    if [[ -x ${node_exporter_filename} ]]; then
        echo "warn: found node_exporter ${node_exporter_filename}, skip"
        return 0
    fi

    # download from github
    local node_exporter_url="https://github.com/prometheus/node_exporter/releases/download/v${node_exporter_version}/${node_exporter_filename}"
    echo "info: download node_exporter from ${node_exporter_url}"
    if ! wget ${node_exporter_url} 2> /dev/null; then
        echo 'error: download node_exporter failed'
        return 2
    fi
    if ! tar -xf ${node_exporter_filename} 2> /dev/null; then
        echo 'error: unzip node_exporter failed'
        return 3
    fi
    rm -rf "node_exporter-${node_exporter_version}.linux-amd64"
    rm -rf ${node_exporter_filename}
    mv -f "node_exporter-${node_exporter_version}.linux-amd64"/node_exporter ${target_location}
    return 0
}


#--------------------------------------------------------------#
# Name: download_pg_exporter
# Desc: Guarantee a usable pg_exporter in ${target_location}
# Arg1: target pg_exporter location
# Arg2: pg_exporter version to download  (0.3.2)
#--------------------------------------------------------------#
function download_pg_exporter() {
    local target_location=${1-'./pg_exporter'}
    local pg_exporter_version=${3-'0.3.2'}

    # if exact same version already in target location, skip
    if [[ -x ${target_location} ]]; then
        echo "warn: found pg_exporter ${pg_exporter_version} on ${target_location}, skip"
        return 0
    fi
    local pg_exporter_filename="pg_exporter_v${pg_exporter_version}_linux-amd64.tar.gz"
    if [[ -x ${pg_exporter_filename} ]]; then
        echo "warn: found pg_exporter ${pg_exporter_filename}, skip"
        return 0
    fi

    # download from github
    local pg_exporter_url="https://github.com/Vonng/pg_exporter/releases/download/v${pg_exporter_version}/${pg_exporter_filename}"
    echo "info: download pg_exporter from ${pg_exporter_url}"
    if ! wget ${pg_exporter_url} 2> /dev/null; then
        echo 'error: download pg_exporter failed'
        return 2
    fi
    if ! tar -xf ${pg_exporter_filename} 2> /dev/null; then
        echo 'error: unzip pg_exporter failed'
        return 3
    fi
    mv -f "pg_exporter_v${pg_exporter_version}_linux-amd64"/pg_exporter ${target_location}
    rm -rf "pg_exporter_v${pg_exporter_version}_linux-amd64"
    rm -rf ${pg_exporter_filename}
    return 0
}

download_node_exporter ./node_exporter  1.1.1
download_pg_exporter   ./pg_exporter    0.3.2