# for testing purpose

alias synctime="sudo ntpdate -u time.pool.aliyun.com"
alias viconf="vi /pg/data/postgresql.conf"
alias vihba="vi /pg/data/pg_hba.conf"
alias vilog='tail -f /pg/data/log/postgresql-$(date +%a).csv'
alias cdlog='cd /pg/data/log'
alias cddata='cd /pg/data'

alias pr="psql -qAtc \"SELECT CASE pg_is_in_recovery() WHEN TRUE THEN 'standby' ELSE 'primary' END\";"
alias pgrepl='psql -Axc "TABLE pg_stat_replication;"'
alias pgrecv='psql -Axc "TABLE pg_stat_replication;"'
alias psa="ps aux | grep "
alias pst='ps aux | grep postgres'
alias pst='ps aux | grep postgres'

alias nexp="curl -sL localhost:9100/metrics | grep -v '#' | grep node_"
alias pexp="curl -sL localhost:9630/metrics | grep -v '#' | grep pg_"
alias pgup='sudo systemctl restart postgres'
alias pgdw='sudo systemctl stop postgres'
alias pgst='systemctl status postgres'
alias pgreload='sudo systemctl reload postgres'
alias pgrestart='sudo systemctl restart postgres'
alias stoppg='pg_ctl -D /pg/data stop'
alias startpg='pg_ctl -D /pg/data start'

alias ptup='sudo systemctl start patroni'
alias ptdw='sudo systemctl stop  patroni'
alias ptst='systemctl status patroni'
alias ptlog='tail -f /pg/log/patroni.log'
alias pgb='psql -p6432 -dpgbouncer'
alias pgbup='sudo systemctl restart pgbouncer'
alias pgbdw='sudo systemctl stop pgbouncer'
alias pgbrestart='systemctl restart pgbouncer'
alias pgbst='sudo systemctl status pgbouncer'
alias pgbstat='psql -p6432 -dpgbouncer -xc "SHOW STATS;"'
alias pgbpool='psql -p6432 -dpgbouncer -xc "SHOW POOLS;"'
alias pgbreload='/usr/bin/pgbouncer -d -R /etc/pgbouncer/pgbouncer.ini'
alias pglog='tail -f /pg/data/log/*.csv'
alias plog='tail -f /pg/log/*.log'
alias pg2md=" sed 's/+/|/g' | sed 's/^/|/' | sed 's/$/|/' |  grep -v rows | grep -v '||'"
alias wal=walarchiver
