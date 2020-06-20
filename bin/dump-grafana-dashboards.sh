#!/usr/bin/env bash

HOST="http://admin:admin@10.10.10.10:3000"

[ ! -d dashboards ] && mkdir -p dashboards

for dash in $(curl -sSL -k $HOST/api/search\?query\=\& | jq '.' | grep -i uri | awk -F '"uri": "' '{ print $2 }' | awk -F '"' '{print $1 }'); do
	curl -sSL -k "${HOST}/api/dashboards/${dash}" >dashboards/$(echo ${dash} | sed 's,db/,,g').json
done
