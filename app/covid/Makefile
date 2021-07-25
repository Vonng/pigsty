#==============================================================#
# File      :   Makefile
# Ctime     :   2020-11-03
# Mtime     :   2021-07-25
# Desc      :   Makefile shortcuts
# Path      :   Makefile
# Copyright (C) 2019-2020 Ruohang Feng
#==============================================================#

# pigsty environment
METADB_URL?=postgres://dbuser_dba:DBUser.DBA@10.10.10.10/meta
GRAFANA_USERNAME?=admin
GRAFANA_PASSWORD?=pigsty
GRAFANA_ENDPOINT?=http://10.10.10.10:3000

#-----------------------------#
# entry
#-----------------------------#
default: all
all: sql ui reload

#-----------------------------#
# install
#-----------------------------#
ui:
	cd ui && ./grafana.py load

sql:
	psql ${METADB_URL-''} -f sql/000_base.sql    # baseline schema

#-----------------------------#
# download data
#-----------------------------#
reload: download load
download:
	mkdir -p data/
	curl -fSL https://covid19.who.int/WHO-COVID-19-global-table-data.csv -o data/latest.csv
	curl -fSL https://covid19.who.int/WHO-COVID-19-global-data.csv       -o data/history.csv

#-----------------------------#
# load / clean data
#-----------------------------#
load: clean
	cat data/history.csv | psql ${METADB_URL} -c "COPY covid.country_history FROM STDIN CSV HEADER;";
	cat data/latest.csv  | psql ${METADB_URL} -c "COPY covid.country_latest FROM STDIN CSV HEADER;";

clean:
	psql ${METADB_URL} -c 'TRUNCATE covid.country_history, covid.country_latest;';


.PHONY: default all ui sql download load trunc