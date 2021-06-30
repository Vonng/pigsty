# PGURL (default to 'meta')
PGURL?=postgres://dbuser_dba:DBUser.DBA@:5432/meta
GFDIR?=/var/lib/grafana/dashboards/

default: all


#-----------------------------#
# install
#-----------------------------#
all: sql ui restart

ui:
	sudo mkdir -p ${GFDIR}
	sudo rm -rf ${GFDIR}/pglog
	sudo cp -rf ui/* ${GFDIR}/

sql:
	psql ${PGURL} -f sql/000_base.sql    # base schema

load:
	bin/load_pglog_today.sh ${PGURL}

# restart
restart:
	sudo systemctl restart grafana-server

.PHONY: default all ui sql restart