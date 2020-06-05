#!/bin/bash
set -uo pipefail
#==============================================================#
# File      :   callback.sh
# Mtime     :   2020-04-07
# Desc      :   Patroni event callback scripts
# Path      :   /pg/bin/callback.sh
# Depend    :   CentOS 7
# Author    :   Vonng(fengruohang@outlook.com)
# Note      :   Run this as dbsu (postgres)
#==============================================================#
PROG_NAME="$(basename $0))"
PROG_DIR="$(cd $(dirname $0) && pwd)"

#==============================================================#
function usage() {
	cat <<-'EOF'
		NAME
			callback.sh event role cluster
		
		SYNOPSIS
			This is patroni pg event callback scripts
	EOF
	exit 1
}
#==============================================================#

function on_role_change_handler() {
	local role=$1
	local cluster=$2

	# change registered services with new role
	/pg/bin/register.sh ${role} ${cluster}

	psql -c 'CHECKPOINT;'

	# TODO
}

function on_stop_handler() {
	local role=$1
	local cluster=$2
	exit 0
}

function on_start_handler() {
	local role=$1
	local cluster=$2
	exit 0
}

function main() {
	local event=$1
	local role=$2
	local cluster=$3

	# log event and call handler
	printf "\033[0;32m[$(date "+%Y-%m-%d %H:%M:%S")][${HOSTNAME}][event=${event}}] [cluster=${cluster}] [role=${role}]\033[0m\n" >>/pg/log/callback.log
	case ${event} in
	on_stop)
		on_stop_handler ${role} ${cluster}
		;;
	on_start)
		on_start_handler ${role} ${cluster}
		;;
	on_role_change)
		on_role_change_handler ${role} ${cluster}
		;;
	*)
		usage
		;;
	esac
}

main $@
