# PGURL (default to 'meta')
PGURL?=postgres://dbuser_dba:DBUser.DBA@:5432/meta
UIDIR?=/var/lib/pigsty/dashboards/

default: all

#-----------------------------#
# install
#-----------------------------#
all: sql ui restart

ui:
	sudo mkdir -p ${UIDIR}
	sudo rm -rf ${UIDIR}/pgsql       # maybe backup it first?
	sudo cp -rf ui/* ${UIDIR}/       # copy ui/pgsql to target

sql:
	psql ${PGURL} -f sql/baseline.sql    # base schema

load:
	bin/load_pglog_today.sh ${PGURL}

# restart
restart:
	sudo systemctl restart grafana-server

.PHONY: default all ui sql restart