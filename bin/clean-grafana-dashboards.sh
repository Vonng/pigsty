#!/usr/bin/env bash

HOST="http://admin:admin@10.10.10.10:3000"

[ ! -d dashboards ] && mkdir -p dashboards

for dash in $(curl -sSL -k $HOST/api/search\?query\=\& | jq '.' | grep -i uid | grep -v "folderUid" | awk -F '"uid": "' '{print $2}' | awk -F '"' '{print $1}'); do
	curl -sSL -X DELETE -k "${HOST}/api/dashboards/uid/${dash}"
done
