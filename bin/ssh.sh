#!/bin/bash
set -euo pipefail

#==============================================================#
# File      :   ssh.sh
# Ctime     :   2021-04-20
# Mtime     :   2021-04-20
# Desc      :   setup ssh access for local vagrant SANDBOX
# Note      :   vagrant required
# Path      :   bin/ssh.sh
# Copyright (C) 2018-2021 Ruohang Feng
#==============================================================#

PROG_NAME="$(basename $0))"
PROG_DIR="$(cd $(dirname $0) && pwd)"

PIGSTY_HOME="$(cd $(dirname ${PROG_DIR}) && pwd)"
VAGRANT_DIR=${PIGSTY_HOME}/vagrant

# check vagrant installed
if ! command -v vagrant &> /dev/null
then
	printf "\033[0;31m[ERROR] vagrant not found \033[0m\n" >&2
	exit 1
fi

# check Vagrantfile exists
cd ${VAGRANT_DIR}
if [[ ! -f Vagrantfile ]]
then
	printf "\033[0;31m[ERROR] Vagrantfile not found \033[0m\n" >&2
	exit 1
fi

printf "\033[0;32m[INFO] vagrant ssh-config (please wait... about 10s) \033[0m\n" >&2

# write vagrant config to ~/.ssh/pigsty_config
vagrant ssh-config > ~/.ssh/pigsty_config 2>/dev/null; true
vagrant ssh-config | sed 's/meta/10.10.10.10/g' | sed 's/node-1/10.10.10.11/g' | sed 's/node-2/10.10.10.12/g' | sed 's/node-3/10.10.10.13/g' >> ~/.ssh/pigsty_config 2>/dev/null; true

# write vagrant vm ssh config
vagrant ssh-config > ${HOME}/.ssh/pigsty_config 2>/dev/null; true
cat ${HOME}/.ssh/pigsty_config | sed 's/meta/10.10.10.10/g' | sed 's/node-1/10.10.10.11/g' | sed 's/node-2/10.10.10.12/g' | sed 's/node-3/10.10.10.13/g' >> ${HOME}/.ssh/pigsty_config

# append Include to .ssh/config
if ! grep --quiet "pigsty_config" ~/.ssh/config ; then
	(echo 'Include ~/.ssh/pigsty_config' && cat ~/.ssh/config) >  ~/.ssh/config.tmp;
	mv ~/.ssh/config.tmp ~/.ssh/config && chmod 0600 ~/.ssh/config;
fi

# append StrictHostKeyChecking=no to .ssh/config
if ! grep --quiet "StrictHostKeyChecking=no" ~/.ssh/config ; then
	(echo 'StrictHostKeyChecking=no' && cat ~/.ssh/config) >  ~/.ssh/config.tmp;
	mv ~/.ssh/config.tmp ~/.ssh/config && chmod 0600 ~/.ssh/config;
fi

printf "\033[0;32m[INFO] ~/.ssh/pigsty_config \033[0m\n" >&2
cat ${HOME}/.ssh/pigsty_config