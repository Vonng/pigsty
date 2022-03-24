#!/bin/bash
#==============================================================#
# File      :   gen.sh
# Ctime     :   2019-04-13
# Mtime     :   2020-09-17
# Desc      :   generate ssh key pair in same dir
# Path      :   vagrant/ssh/gen.sh
# Copyright (C) 2018-2022 Ruohang Feng
#==============================================================#

PROG_NAME="$(basename $0)"
PROG_DIR="$(cd $(dirname $0) && pwd)"

# generate new ssh key in this dir
[ -f "${PROG_DIR}/id_rsa" ] && rm -f "${PROG_DIR}/id_rsa"
[ -f "${PROG_DIR}/id_rsa.pub" ] && rm -f "${PROG_DIR}/id_rsa.pub"
ssh-keygen -q -t rsa -b 1024 -C 'vagrant@pigsty.com' -f "$PROG_DIR/id_rsa" -N ""
chmod 600 ${PROG_DIR}/id_rsa*
