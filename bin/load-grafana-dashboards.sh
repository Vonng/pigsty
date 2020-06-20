#!/usr/bin/env bash

HOST="http://admin:admin@10.10.10.10:3000"

function load_dashboard_dir() {
	local json_dir=${1-'/tmp/dashboards'}
	for dash in $(ls ${json_dir}/ | grep '.json$'); do
		local src=${json_dir}/${dash}
		local dest=${src}.payload
		cat >${dest} <<-EOF
			{"overwrite": false, "dashboard": $(cat $src)}
		EOF
		echo curl -sSL -k -X POST "${HOST}/api/dashboards/db" --header '"Content-Type: application/json"' -d @${dest}
		curl -sSL -k -X POST "${HOST}/api/dashboards/db" --header "Content-Type: application/json" -d @${dest}
	done
}
load_dashboard_dir
