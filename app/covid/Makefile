#==============================================================#
# File      :   Makefile
# Ctime     :   2020-11-03
# Mtime     :   2022-03-30
# Desc      :   Makefile shortcuts
# Path      :   Makefile
# Copyright (C) 2019-2022 Ruohang Feng
#==============================================================#

# pigsty environment
METADB_URL?=postgres://dbuser_dba:DBUser.DBA@10.10.10.10/meta
GRAFANA_USERNAME?=admin
GRAFANA_PASSWORD?=pigsty
GRAFANA_ENDPOINT?=http://10.10.10.10:3000

#-----------------------------#
# entrypoint
#-----------------------------#
default: install

# if local data available, use `make install`
install: sql ui data-local

# if local data unavailable, use `make all` to download
all: sql ui data


#-----------------------------#
# install
#-----------------------------#
ui:
	cd ui && ./grafana.py load

sql:
	psql ${METADB_URL-''} -f sql/000_base.sql    # baseline schema

data-local: load
data: reload


#-----------------------------#
# data
#-----------------------------#
download:
	mkdir -p data/
	curl -fSL https://covid19.who.int/WHO-COVID-19-global-data.csv -o data/covid.csv

load: clean
	cat data/history.csv | psql ${METADB_URL} -c "COPY covid.country_history FROM STDIN CSV HEADER;";

clean:
	psql ${METADB_URL} -c 'TRUNCATE app.covid;';

reload: download load

.PHONY: default install all ui sql data-local data-fetch download load clean reload