##########################################################
#                         admin                          #
##########################################################
# - patroni - #
alias pg-up='sudo systemctl start patroni'
alias pg-start='pg_ctl -D /pg/data start'
alias pg-dw='sudo systemctl stop  patroni'
alias pg-stop='pg_ctl -D /pg/data stop'
alias pg-st='systemctl status patroni'
alias pg-reload='sudo systemctl reload patroni'
alias pg-restart='sudo systemctl restart patroni'
alias pg-ps='ps aux | grep postgres'
alias pg-d="cd /pg/data"
function pg-l() {
    if [ ! -r /pg/data/postgresql.conf ]; then
        echo "error: postgres conf not found"
        return 1
    else
    local logpath=$(grep 'log_directory' /pg/data/postgresql.conf | awk '{print $3}' | tr -d "'")
    cd $logpath
    fi
}
alias pg-c="less /pg/data/postgresql.conf"
alias pg-h="less /pg/data/pg_hba.conf"
function pt-log() {
    if [ ! -r /pg/bin/patroni.yml ]; then
        echo "error: patroni ctl config not found"
        return 1
    else
    local logpath=$(grep -A2 'log:' /pg/bin/patroni.yml | head -n3 | awk '/dir:/ {print $2}')
    tail -f $logpath/patroni.log
    fi
}
function pg-log() {
    if [ ! -r /pg/data/postgresql.conf ]; then
        echo "error: postgres conf not found"
        return 1
    else
    local logpath=$(grep 'log_directory' /pg/data/postgresql.conf | awk '{print $3}' | tr -d "'")
    tail -f $logpath/postgresql-$(date '+%Y-%m-%d').csv
    fi
}

# - pgbackrest - #
function pgbr-full() {
    if [ ! -r /etc/pgbackrest.conf ]; then
        echo "error: pgbackrest config not found"
        return 1
    else
        local stanza=$(grep -o '\[[^][]*]' /etc/pgbackrest.conf | tail -1 | sed 's/.*\[\([^]]*\)].*/\1/')
        pgbackrest --stanza=$stanza --type=full backup
    fi
}
function pgbr-diff() {
    if [ ! -r /etc/pgbackrest.conf ]; then
        echo "error: pgbackrest config not found"
        return 1
    else
        local stanza=$(grep -o '\[[^][]*]' /etc/pgbackrest.conf | tail -1 | sed 's/.*\[\([^]]*\)].*/\1/')
        pgbackrest --stanza=$stanza --type=diff backup
    fi
}
function pgbr-incr() {
    if [ ! -r /etc/pgbackrest.conf ]; then
        echo "error: pgbackrest config not found"
        return 1
    else
        local stanza=$(grep -o '\[[^][]*]' /etc/pgbackrest.conf | tail -1 | sed 's/.*\[\([^]]*\)].*/\1/')
        pgbackrest --stanza=$stanza --type=incr backup
    fi
}
function pgbr-check() {
    if [ ! -r /etc/pgbackrest.conf ]; then
        echo "error: pgbackrest config not found"
        return 1
    else
        local stanza=$(grep -o '\[[^][]*]' /etc/pgbackrest.conf | tail -1 | sed 's/.*\[\([^]]*\)].*/\1/')
        check_pgbackrest --stanza=$stanza --service=retention --output=human && printf '\n' && check_pgbackrest --stanza=$stanza --service=archives --output=human
    fi
}
alias pgbr-up='sudo systemctl start pgbackrest'
alias pgbr-down='sudo systemctl stop pgbackrest'
alias pgbr-status='sudo systemctl status pgbackrest'
alias pgbr-restart='sudo systemctl restart pgbackrest'

# - pgbouncer - #
alias pgb='psql -p6432 -dpgbouncer'
alias pgb-st='systemctl status pgbouncer'
alias pgb-ps='ps aux | grep pgbouncer'
alias pgb-up='sudo systemctl restart pgbouncer'
alias pgb-dw='sudo systemctl stop pgbouncer'
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

##########################################################
# pgsql info
##########################################################
alias pg-db="oid2name | grep -v postgres | grep -v template"
alias pg-r="psql -qAXtwc \"SELECT CASE pg_is_in_recovery() WHEN TRUE THEN 'replica' ELSE 'primary' END\";"
alias pg-repl='psql -qAXtwc "TABLE pg_stat_replication;"'
alias pg-recv='psql -qAXtwc "TABLE pg_stat_wal_receiver;"'
alias pg-md=" sed 's/+/|/g' | sed 's/^/|/' | sed 's/$/|/' |  grep -v rows | grep -v '||'"
alias pg-ts='psql -qAXtwc "SELECT CURRENT_TIMESTAMP;"'
alias pg-rc='psql -qAXtwc "SELECT pg_reload_conf();"'

##########################################################
# exporter info
##########################################################
alias node-mt="curl -sL localhost:9100/metrics | grep -v '#' | grep node_"
alias pg-mt="curl -sL localhost:9630/metrics | grep -v '#' | grep pg_"
alias pgb-mt="curl -sL localhost:9631/metrics | grep -v '#' | grep pg_"

##########################################################
# misc
##########################################################
alias synctime="sudo ntpdate -u time.pool.aliyun.com"
alias psa="ps aux | grep "
alias wal=walarchiver

