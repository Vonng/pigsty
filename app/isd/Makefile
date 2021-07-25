#==============================================================#
# File      :   Makefile
# Ctime     :   2020-11-03
# Mtime     :   2021-07-21
# Desc      :   Makefile shortcuts
# Path      :   Makefile
# Copyright (C) 2019-2020 Ruohang Feng
#==============================================================#


###############################################################
# Public API
###############################################################
reload: get-daily load-daily refresh    # reload latest (this year) daily summary data
reload-hourly: get-hourly load-hourly   # reload latest (this year) hourly raw data
all: baseline reload                    # create minimal viable product with latest data
all: download baseline reload           # if data/ is empty, download data first
baseline: sql ui load-meta              # setup postgres database & grafana dashboards
download: get-meta get-parser get-station get-history


###############################################################
# Environment
###############################################################
# your own environment
#METADB_URL?=postgres:///
#GRAFANA_USERNAME=admin
#GRAFANA_PASSWORD=admin
#GRAFANA_ENDPOINT=http://localhost:3000

# pigsty environment
METADB_URL?=postgres://dbuser_dba:DBUser.DBA@10.10.10.10/meta
GRAFANA_USERNAME?=admin
GRAFANA_PASSWORD?=pigsty
GRAFANA_ENDPOINT?=http://10.10.10.10:3000

show:
	@echo ${METADB_URL}
	psql ${METADB_URL} -c '\dt+ isd.*'
###############################################################



###############################################################
# Download
###############################################################

# download meta data to data/meta dir
get-meta:
	bin/get-meta.sh

# download isd daily & hourly data parser binaries from github
get-parser:
	bin/get-parser.sh

# download meta data: isd station list
get-station:
	bin/get-station.sh

# download meta data: isd station observation records
get-history:
	bin/get-history.sh

# download current year's daily data (add year to download specific year data)
get-daily:
	bin/get-daily.sh

# download current year's hourly data (add year to download specific year data)
get-hourly:
	bin/get-hourly.sh


###############################################################
# Init Database Schema
###############################################################
# create schema on local machine (DANGEROUS, will wipe isd schema)
sql:
	psql ${METADB_URL} -f sql/schema.sql


###############################################################
# Init Dashboards on Grafana
###############################################################
# add dashboard to grafana according to GRAFANA_X environment
ui:
	cd ui && ./grafana.py load

###############################################################
# Meta Data (dict/const tables)
###############################################################

# dump meta data to data/meta dir
dump-meta:
	bin/dump-meta.sh ${METADB_URL}

# dump meta data to data/meta dir
load-meta:
	bin/load-meta.sh ${METADB_URL}

###############################################################
# Load ISD Observation Data
###############################################################

# load current year hourly data (parser required)
load-hourly:
	bin/load-hourly.sh ${METADB_URL}

# load current year daily data  (parser required)
load-daily:
	bin/load-daily.sh ${METADB_URL}

# refresh latest partition of monthly & yearly data
refresh:
	bin/refresh.sh ${METADB_URL}


###############################################################
# PARSER (you can just use pre-compiled binaries)
###############################################################

# build hourly data parser
isdd:
	cd parser/isdd && go build
	mv -f parser/isdd/isdd bin/isdd

# build daily data parser
isdh:
	cd parser/isdh && go build
	mv -f parser/isdh/isdh bin/isdh

release-darwin:
	cd parser/isdh && CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build  -a -ldflags '-extldflags "-static"' -o isdh
	cd parser/isdd && CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build  -a -ldflags '-extldflags "-static"' -o isdd
	mv -f parser/isdh/isdh isdh
	mv -f parser/isdd/isdd isdd
	upx isdh
	upx isdd
	tar -cf bin/release/isd_darwin-amd64.tar.gz isdh isdd

release-linux:
	cd parser/isdh && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build  -a -ldflags '-extldflags "-static"' -o isdh
	cd parser/isdd && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build  -a -ldflags '-extldflags "-static"' -o isdd
	mv -f parser/isdh/isdh isdh
	mv -f parser/isdd/isdd isdd
	upx isdh
	upx isdd
	tar -cf bin/release/isd_linux-amd64.tar.gz isdh isdd

clean:
	rm -rf isdh isdd
	rm -rf bin/isdh bin/isdd

release: clean release-linux release-darwin

.PHONY: sql ui get-daily-2020 get-hourly-2020 get-isd-station get-isd-history load-meta dump-meta load-daily load-hourly createdb
