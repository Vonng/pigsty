#==============================================================#
# File      :   Makefile
# Ctime     :   2021-10-10
# Mtime     :   2021-10-10
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
all: clean sql ui     # if data is NOT downloaded

#-----------------------------#
# install
#-----------------------------#
ui:
	cd ui && ./grafana.py load

sql:
	psql ${METADB_URL-''} -f sql/000_base.sql    # baseline schema

#-----------------------------#
# clean data
#-----------------------------#
clean:
	psql ${METADB_URL} -c 'TRUNCATE applog.t_privacy_log;TRUNCATE applog.privacy_log;'


.PHONY: default all ui sql clean