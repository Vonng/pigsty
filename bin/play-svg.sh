#!/bin/bash
set -euo pipefail

#==============================================================#
# File      :   play-svg.sh
# Ctime     :   2021-04-20
# Mtime     :   2021-04-20
# Desc      :   generate playbook svg @ files/svg
# Path      :   bin/play-svg.sh
# Copyright (C) 2018-2021 Ruohang Feng
#==============================================================#

PROG_NAME="$(basename $0))"
PROG_DIR="$(cd $(dirname $0) && pwd)"

# pigsty home directory
PIGSTY_HOME="$(cd $(dirname ${PROG_DIR}) && pwd)"
SVG_DIR=${PIGSTY_HOME}/files/svg

cd ${PIGSTY_HOME}
mkdir -p ${SVG_DIR}


ansible-playbook-grapher                        sandbox.yml              -o ${SVG_DIR}/sandbox
ansible-playbook-grapher                        infra.yml                -o ${SVG_DIR}/infra
ansible-playbook-grapher                        pgsql.yml                -o ${SVG_DIR}/pgsql
ansible-playbook-grapher                        node.yml                 -o ${SVG_DIR}/node
ansible-playbook-grapher                        node-remove.yml          -o ${SVG_DIR}/node-remove
ansible-playbook-grapher                        pgsql-remove.yml         -o ${SVG_DIR}/pgsql-remove
ansible-playbook-grapher                        pgsql-monitor.yml        -o ${SVG_DIR}/pgsql-monitor
ansible-playbook-grapher                        pgsql-createuser.yml     -o ${SVG_DIR}/pgsql-createuser
ansible-playbook-grapher                        pgsql-createdb.yml       -o ${SVG_DIR}/pgsql-createdb
ansible-playbook-grapher                        pgsql-service.yml        -o ${SVG_DIR}/pgsql-service

ansible-playbook-grapher  --include-role-tasks  sandbox.yml              -o ${SVG_DIR}/sandbox-full
ansible-playbook-grapher  --include-role-tasks  infra.yml                -o ${SVG_DIR}/infra-full
ansible-playbook-grapher  --include-role-tasks  pgsql.yml                -o ${SVG_DIR}/pgsql-full
ansible-playbook-grapher  --include-role-tasks  node.yml                 -o ${SVG_DIR}/node-full
ansible-playbook-grapher  --include-role-tasks  node-remove.yml          -o ${SVG_DIR}/node-remove-full
ansible-playbook-grapher  --include-role-tasks  pgsql-remove.yml         -o ${SVG_DIR}/pgsql-remove-full
ansible-playbook-grapher  --include-role-tasks  pgsql-monitor.yml        -o ${SVG_DIR}/pgsql-monitor-full
ansible-playbook-grapher  --include-role-tasks  pgsql-createuser.yml     -o ${SVG_DIR}/pgsql-createuser-full
ansible-playbook-grapher  --include-role-tasks  pgsql-createdb.yml       -o ${SVG_DIR}/pgsql-createdb-full
ansible-playbook-grapher  --include-role-tasks  pgsql-service.yml        -o ${SVG_DIR}/pgsql-service-full

