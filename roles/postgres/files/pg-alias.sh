#!/bin/bash

#======================#
# patroni
#======================#
function pg() {
    local patroni_conf="/pg/bin/patroni.yml"
    if [ ! -r ${patroni_conf} ]; then
        patroni_conf="/etc/pigsty/patronictl.yml"
        if [ ! -r ${patroni_conf} ]; then
        	echo "error: patroni ctl config not found"
            return 1
        fi
    fi
    patronictl -c ${patroni_conf} "$@"
}
function pt-log() {
    local logdir=$(grep -A2 'log:' /pg/bin/patroni.yml | head -n3 | awk '/dir:/ {print $2}')
    [[ -f "${logdir}/patroni.log" ]] && tail -f "${logdir}/patroni.log"
}
alias pt-start='sudo systemctl start patroni'
alias pt-stop='sudo systemctl stop patroni'
alias pt-reload='sudo systemctl reload  patroni'
alias pt-restart='sudo systemctl restart  patroni'
alias pt-st='systemctl status patroni'


#======================#
# postgres
#======================#
alias pg-c="less /pg/data/postgresql.conf"
alias pg-h="less /pg/data/pg_hba.conf"
alias pg-d="cd /pg/data"
alias pg-st='ps aux | grep postgres'
alias pg-start='pg_ctl -D /pg/data start'
alias pg-stop='pg_ctl -D /pg/data stop'
alias pg-stop='pg_ctl -D /pg/data restart'
alias pg-reload='pg_ctl -D /pg/data reload'
alias pg-db="oid2name | grep -v postgres | grep -v template"
alias pg-r="psql -qAXtwc \"SELECT CASE pg_is_in_recovery() WHEN TRUE THEN 'replica' ELSE 'primary' END\";"
alias pg-repl='psql -qAXtwc "TABLE pg_stat_replication;"'
alias pg-recv='psql -qAXtwc "TABLE pg_stat_wal_receiver;"'
alias pg-md=" sed 's/+/|/g' | sed 's/^/|/' | sed 's/$/|/' |  grep -v rows | grep -v '||'"
alias pg-ts='psql -qAXtwc "SELECT CURRENT_TIMESTAMP;"'
alias pg-rc='psql -qAXtwc "SELECT pg_reload_conf();"'
alias pg-mt="curl -sL localhost:9630/metrics | grep -v '#' | grep pg_"

function pg-l() {
    local logdir=$(grep 'log_directory' /pg/data/postgresql.conf | awk '{print $3}' | tr -d "'"); cd ${logdir};
}
function pg-log() {
    local logdir=$(grep 'log_directory' /pg/data/postgresql.conf | awk '{print $3}' | tr -d "'")
    [[ -f "${logdir}/postgresql-$(date '+%Y-%m-%d').csv" ]] && tail -f "${logdir}/postgresql-$(date '+%Y-%m-%d').csv"
}


#======================#
# pgbouncer
#======================#
alias pgb='psql -p6432 -dpgbouncer'
alias pgb-st='systemctl status pgbouncer'
alias pgb-ps='ps aux | grep pgbouncer'
alias pgb-start='sudo systemctl start pgbouncer'
alias pgb-stop='sudo systemctl stop pgbouncer'
alias pgb-restart='systemctl restart pgbouncer'
alias pgb-reload='systemctl reload pgbouncer'
alias pgb-new='/usr/bin/pgbouncer -d -R /etc/pgbouncer/pgbouncer.ini'
alias pgb-stat='psql -p6432 -dpgbouncer -xc "SHOW STATS;"'
alias pgb-pool='psql -p6432 -dpgbouncer -xc "SHOW POOLS;"'
alias pgb-dir="cd /etc/pgbouncer"
alias pgb-conf="cat /etc/pgbouncer/pgbouncer.ini"
alias pgb-hba="cat /etc/pgbouncer/pgb_hba.conf"
alias pgb-user="cat /etc/pgbouncer/database.txt"
alias pgb-db="cat /etc/pgbouncer/userlist.txt"
alias pgb-mt="curl -sL localhost:9631/metrics | grep -v '#' | grep pg_"


#======================#
# pgbackrest
#======================#
function pb() {
    local stanza=$(grep -o '\[[^][]*]' /etc/pgbackrest/pgbackrest.conf | head -n1 | sed 's/.*\[\([^]]*\)].*/\1/')
    pgbackrest --stanza=$stanza $@
}
function pb-full() {
    local stanza=$(grep -o '\[[^][]*]' /etc/pgbackrest/pgbackrest.conf | head -n1 | sed 's/.*\[\([^]]*\)].*/\1/')
    pgbackrest --stanza=$stanza --type=full backup
}
function pb-diff() {
    local stanza=$(grep -o '\[[^][]*]' /etc/pgbackrest/pgbackrest.conf | head -n1 | sed 's/.*\[\([^]]*\)].*/\1/')
    pgbackrest --stanza=$stanza --type=diff backup
}
function pb-incr() {
    local stanza=$(grep -o '\[[^][]*]' /etc/pgbackrest/pgbackrest.conf | head -n1 | sed 's/.*\[\([^]]*\)].*/\1/')
    pgbackrest --stanza=$stanza --type=incr backup
}
function pb-check() {
    local stanza=$(grep -o '\[[^][]*]' /etc/pgbackrest/pgbackrest.conf | head -n1 | sed 's/.*\[\([^]]*\)].*/\1/')
    check_pgbackrest --stanza=$stanza --service=retention --output=human && printf '\n' && check_pgbackrest --stanza=$stanza --service=archives --output=human
}