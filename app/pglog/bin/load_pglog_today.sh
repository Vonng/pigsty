#!/bin/bash

# get current pglog filename from meta db and load it into pglog.sample;

PGURL=${1-'postgres:///postgres?sslmode=disable'}
current_logfile=$(psql ${PGURL} -AXtqc "select current_setting('data_directory') || '/' || pg_current_logfile();")
sudo cat /pg/data/log/postgresql-2021-05-21.csv | psql 'postgres://dbuser_dba:DBUser.DBA@:5432/meta' -AXtqc 'TRUNCATE pglog.sample;COPY pglog.sample FROM STDIN CSV;'