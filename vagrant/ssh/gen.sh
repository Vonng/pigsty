#!/bin/bash
#==============================================================#
# File      :   gen.sh
# Ctime     :   2019-04-13
# Mtime     :   2020-09-17
# Desc      :   generate ssh key pair in same dir
# Path      :   vagrant/ssh/gen.sh
# Author    :   Ruohang Feng (rh@vonng.com)
# License   :   AGPLv3
#==============================================================#

PROG_NAME="$(basename $0)"
PROG_DIR="$(cd $(dirname $0) && pwd)"
[ -f "${PROG_DIR}/id_rsa" ] && rm -f "${PROG_DIR}/id_rsa"
[ -f "${PROG_DIR}/id_rsa.pub" ] && rm -f "${PROG_DIR}/id_rsa.pub"
ssh-keygen -q -t rsa -b 1024 -C 'vagrant@pigsty.com' -f "$PROG_DIR/id_rsa" -N ""
chmod 600 ${PROG_DIR}/id_rsa
chmod 644 ${PROG_DIR}/id_rsa.pub
