#!/bin/bash

# generate new ssh key in this dir

PROG_NAME="$(basename $0))"
PROG_DIR="$(cd $(dirname $0) && pwd)"

[ -f "${PROG_DIR}/id_rsa" ] && rm -f "${PROG_DIR}/id_rsa"
[ -f "${PROG_DIR}/id_rsa.pub" ] && rm -f "${PROG_DIR}/id_rsa.pub"

ssh-keygen -q -t rsa -b 1024 -C 'vagrant@pigsty.com' -f "$PROG_DIR/id_rsa" -N ""

chmod 600 ${PROG_DIR}/id_rsa*
