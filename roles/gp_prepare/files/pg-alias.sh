##########################################################
#                         admin                          #
##########################################################
# - postgres - #
alias pg-up='sudo systemctl restart postgres'
alias pg-dw='sudo systemctl stop postgres'
alias pg-st='systemctl status postgres'
alias pg-reload='sudo systemctl reload postgres'
alias pg-restart='sudo systemctl restart postgres'
alias pg-stop='pg_ctl -D /pg/data stop'
alias pg-start='pg_ctl -D /pg/data start'
alias pg-tlog='tail -f /pg/data/log/*.csv'
alias pg-log='vi /pg/data/log/postgresql-$(date +%a).csv'

alias pg-d="cd /pg/data"
alias pg-l="cd /pg/data/log"
alias pg-c="vi /pg/data/postgresql.conf"
alias pg-h="vi /pg/data/pg_hba.conf"

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

# - patroni - #
alias pt-up='sudo systemctl start patroni'
alias pt-dw='sudo systemctl stop  patroni'
alias pt-st='systemctl status patroni'
alias pt-ps='ps aux | grep patroni'
alias pt-log='tail -f /pg/log/patroni.log'
alias pt-tlog='tail -f /pg/log/*.log'


##########################################################
# pgsql info
##########################################################
alias pg-db="oid2name | grep -v postgres | grep -v template"
alias pg-r="psql -qAXtwc \"SELECT CASE pg_is_in_recovery() WHEN TRUE THEN 'replica' ELSE 'primary' END\";"
alias pg-repl='psql -qAXtwc "TABLE pg_stat_replication;"'
alias pg-recv='psql -qAXtwc "TABLE pg_stat_wal_receiver;"'
alias pg-md=" sed 's/+/|/g' | sed 's/^/|/' | sed 's/$/|/' |  grep -v rows | grep -v '||'"

##########################################################
# exporter info
##########################################################
alias node-mt="curl -sL localhost:9100/metrics | grep -v '#' | grep node_"
alias pg-mt="curl -sL localhost:9630/metrics | grep -v '#' | grep pg_"
alias pg-mt="curl -sL localhost:9631/metrics | grep -v '#' | grep pg_"

##########################################################
# misc
##########################################################
alias synctime="sudo ntpdate -u time.pool.aliyun.com"
alias psa="ps aux | grep "
alias wal=walarchiver

