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
	cat data/history.csv | psql ${PGURL} -c "COPY covid.country_history FROM STDIN CSV HEADER;";
	cat data/latest.csv  | psql ${PGURL} -c "COPY covid.country_latest FROM STDIN CSV HEADER;";

clean:
	psql ${PGURL} -c 'TRUNCATE covid.country_history, covid.country_latest;';


.PHONY: default all ui sql download load trunc