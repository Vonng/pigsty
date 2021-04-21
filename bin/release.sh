#!/bin/bash
set -euo pipefail

#==============================================================#
# File      :   release.sh
# Ctime     :   2021-04-20
# Mtime     :   2021-04-20
# Desc      :   release pigsty
# Note      :   run this as ROOT on INITIALIZED META NODE!
# Path      :   bin/release.sh
# Copyright (C) 2018-2021 Ruohang Feng
#==============================================================#

PROG_NAME="$(basename $0))"
PROG_DIR="$(cd $(dirname $0) && pwd)"

PIGSTY_VERSION=${1}

# pigsty home directory
PIGSTY_HOME="$(cd $(dirname ${PROG_DIR}) && pwd)"
RELEASE_DIR=${PIGSTY_HOME}/files/release
cd ${PIGSTY_HOME}

# create release version dir
DIR="${RELEASE_DIR}/${PIGSTY_VERSION}"
mkdir -p "${DIR}"


#==============================================================#
# source code dir
rm -rf "${DIR}/pigsty"
mkdir -p "${DIR}/pigsty"
mkdir -p "${DIR}/pigsty/files"
mkdir -p "${DIR}/pigsty/vagrant"


#==============================================================#
# copy source playbooks
#==============================================================#
cp -r ${PIGSTY_HOME}/{README.md,LICENSE,KEYS,NOTICE}        "${DIR}/pigsty/"                            # copy text files
cp -r ${PIGSTY_HOME}/ansible.cfg                            "${DIR}/pigsty/"                            # copy ansible config
cp -r ${PIGSTY_HOME}/{bin,roles,templates}                   "${DIR}/pigsty/"                           # copy scripts, playbooks
cp -r ${PIGSTY_HOME}/vagrant/{Vagrantfile,ssh,provision.sh} "${DIR}/pigsty/vagrant"                     # copy sandbox resources
cp -r ${PIGSTY_HOME}/{infra,infra-loki,sandbox,node,node-remove}.yml "${DIR}/pigsty/"                   # copy infra playbooks
cp -r ${PIGSTY_HOME}/node*.yml "${DIR}/pigsty/"                                                         # copy node playbooks
cp -r ${PIGSTY_HOME}/infra*.yml "${DIR}/pigsty/"                                                        # copy infra playbooks
cp -r ${PIGSTY_HOME}/pgsql*.yml "${DIR}/pigsty/"                                                        # copy pgsql playbooks
cp -r ${PIGSTY_HOME}/pigsty.yml "${DIR}/pigsty/"                                                        # copy pigsty config


#==============================================================#
# make minimal package pigsty.tgz
#==============================================================#
cd ${DIR} && tar -zcf "${DIR}/pigsty.tgz" pigsty


#==============================================================#
# copy additional binaries, cli,
#==============================================================#