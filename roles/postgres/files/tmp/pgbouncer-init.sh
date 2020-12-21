#!/bin/bash
set -euo pipefail
#==============================================================#
# File      :   pgbourcer-init.sh
# Mtime     :   2020-09-02
# Desc      :   create default pgbouncer database and user
# Path      :   /pg/bin/pgbouncer-init.sh
# Depend    :   CentOS 7
# Author    :   Vonng(fengruohang@outlook.com)
# Note      :   Run this as {{ PG_DBSU }}
#==============================================================#
PROG_NAME="$(basename $0))"
PROG_DIR="$(cd $(dirname $0) && pwd)"


#---------------------------------------------------------------------------
function log() {
    printf "[$(date "+%Y-%m-%d %H:%M:%S")][$HOSTNAME][INITDB] $*\n" >> /pg/log/initdb.log
}
#---------------------------------------------------------------------------

#----------------------------------------------------------------------------
# template variables
#----------------------------------------------------------------------------
PG_DBSU='{{ pg_dbsu }}'
PG_REPLICATION_USERNAME='{{ pg_replication_username }}'
PG_REPLICATION_PASSWORD='{{ pg_replication_password }}'
PG_MONITOR_USERNAME='{{ pg_monitor_username }}'
PG_MONITOR_PASSWORD='{{ pg_monitor_password }}'
PG_DEFAULT_USERNAME='{{ pg_default_username }}'
PG_DEFAULT_PASSWORD='{{ pg_default_password }}'
PG_DEFAULT_DATABASE='{{ pg_default_database }}'


#----------------------------------------------------------------------------
# create /etc/pgbouncer/userlist.txt
#----------------------------------------------------------------------------
log "pgbouncer-init: modify /etc/pgbouncer/userlist.txt"
# # equiv: psql -Atq -U postgres -d postgres -c "SELECT concat('\"', usename, '\" \"', passwd, '\"') FROM pg_shadow WHERE NOT (NOT usesuper AND userepl)" > /etc/pgbouncer/userlist.txt
function add_userlist(){
	local username=$1
	local md5pass=$(psql -AXtwq -U postgres -d postgres -c "SELECT concat('\"', usename, '\" \"', passwd, '\"') FROM pg_shadow WHERE usename = '${username}'" 2>/dev/null)
	touch /etc/pgbouncer/userlist.txt
	if grep -q ${username} /etc/pgbouncer/userlist.txt; then
		sed -i "/${username}/d" /etc/pgbouncer/userlist.txt
	fi
	if [[ -z "${md5pass}" ]]; then
		echo "\"${username}\" \"\"" >> /etc/pgbouncer/userlist.txt
	else
		echo $md5pass >> /etc/pgbouncer/userlist.txt
	fi
	chmod 0600 /etc/pgbouncer/userlist.txt
}

for user in "${PG_DBSU}" "${PG_MONITOR_USERNAME}" "${PG_DEFAULT_USERNAME}"
do
	log "pgbouncer-init: add pgbouncer user: ${user}"
	add_userlist ${user}
done


#----------------------------------------------------------------------------
# default database
#----------------------------------------------------------------------------
if [ ${PG_DEFAULT_DATABASE} != 'postgres' ]; then
	log "pgbouncer-init: create pgbouncer database entry: ${PG_DEFAULT_DATABASE}"
	echo "" >> /etc/pgbouncer/database.txt
	if grep -q ${PG_DEFAULT_DATABASE} /etc/pgbouncer/database.txt; then
		sed -i "/${PG_DEFAULT_DATABASE}/d" /etc/pgbouncer/database.txt
	fi
	echo "${PG_DEFAULT_DATABASE}   =   host=/var/run/postgresql" >> /etc/pgbouncer/database.txt
fi




function userpass_md5(){
	local username=$1
	local password=$2
	echo "md5$(echo -n "${password}${username}" | md5sum | awk '{print $1}')"
}

function userpass_entry(){
	local username=$1
	local password=$2
	local md5_mon_pass="md5$(echo -n "${password}${username}" | md5sum | awk '{print $1}')"
	echo \"${username}\" \"${md5_mon_pass}\"
}

function userlist_add(){
	local username=$1
	local password=$2
	local md5_mon_pass="md5$(echo -n "${password}${username}" | md5sum | awk '{print $1}')"
	local userlist_entry="\"${username}\" \"${md5_mon_pass}\""

	if grep -q ${username} /etc/pgbouncer/userlist.txt; then
		sed -i "/${username}/d" /etc/pgbouncer/userlist.txt
	fi
	if [[ -z "${md5pass}" ]]; then
		echo "\"${username}\" \"\"" >> /etc/pgbouncer/userlist.txt
	else
		echo ${userlist_entry} >> /etc/pgbouncer/userlist.txt
	fi
}

#        md5_mon_pass="md5$(echo -n '{{ pg_monitor_password }}{{ pg_monitor_username }}' | md5sum | awk '{print $1}')"
#        md5_biz_pass="md5$(echo -n '{{ pg_default_password }}{{ pg_default_username }}' | md5sum | awk '{print $1}')"
#        echo '"postgres" ""' > /etc/pgbouncer/userlist.txt
#        echo \"{{ pg_monitor_username }}\" \"${md5_mon_pass}\" >> /etc/pgbouncer/userlist.txt
#        echo \"{{ pg_default_username }}\" \"${md5_biz_pass}\" >> /etc/pgbouncer/userlist.txt
#        chmod 0600 /etc/pgbouncer/userlist.txt
#        chown -R {{ pg_dbsu }}:postgres /var/run/pgbouncer /var/log/pgbouncer /etc/pgbouncer

	local md5pass=$(psql -AXtwq -U postgres -d postgres -c "SELECT concat('\"', usename, '\" \"', passwd, '\"') FROM pg_shadow WHERE usename = '${username}'" 2>/dev/null)
	touch /etc/pgbouncer/userlist.txt
	if grep -q ${username} /etc/pgbouncer/userlist.txt; then
		sed -i "/${username}/d" /etc/pgbouncer/userlist.txt
	fi
	if [[ -z "${md5pass}" ]]; then
		echo "\"${username}\" \"\"" >> /etc/pgbouncer/userlist.txt
	else
		echo $md5pass >> /etc/pgbouncer/userlist.txt
	fi
	chmod 0600 /etc/pgbouncer/userlist.txt
}






#----------------------------------------------------------------------------
# customize commands
#----------------------------------------------------------------------------
log "pgbouncer-init: completed!"
