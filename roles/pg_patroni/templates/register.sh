#!/bin/bash
set -uo pipefail
#==============================================================#
# File      :   register.sh
# Mtime     :   2020-04-07
# Desc      :   register service to consul (overwrite)
# Path      :   /pg/bin/register.sh
# Author    :   Vonng(fengruohang@outlook.com)
# Note      :   Make sure /etc/consul.d is writtable
#==============================================================#
PROG_NAME="$(basename $0))"
PROG_DIR="$(cd $(dirname $0) && pwd)"

# Example:  register.sh standby testdb will reset monitor identity to standby.testdb

function main() {
	local role=$1
	local cluster=$2
	local patroni_role=$1

	# update consul registered service according to new role

	case ${role} in
	primary | p | master | m | leader | l)
		role="primary"
		patroni_role="primary"
		;;
	standby | s | replica | r | slave)
		role="replica"
		patroni_role="replica"
		;;
	offline | o | delayed | d)
		role="replica"
		patroni_role="replica"
		;;
	*)
		echo "monitor.sh <cluster> <role>"
		exit 1
		;;
	esac

	# refresh consul registered service
	# node exporter does not change during role change

	# pg_exporter
	cat >/etc/consul.d/srv-pg-exporter.json <<-EOF
		{"service": {
			"name": "pg-exporter",
			"port": 9630,
			"tags": ["pg-exporter", "exporter"],
			"meta": {
				"type": "exporter",
				"role": "${role}",
				"seq": "{{ seq }}",
				"instance": "{{ cluster }}-{{seq}}",
				"service": "{{ cluster }}-${role}",
				"cluster": "{{ cluster }}"
			},
			"check": {"http": "http://{{ inventory_hostname }}:9630/", "interval": "5s", "timeout": "1s"}
		  }}
	EOF

	# pgbouncer_exporter
	cat >/etc/consul.d/srv-pgbouncer-exporter.json <<-EOF
		{"service": {
              "name": "pgbouncer-exporter",
              "port": 9631,
              "tags": ["pgbouncer-exporter", "exporter"],
              "meta": {
                  "type": "exporter",
                  "role": "${role}",
                  "seq": "{{ seq }}",
                  "instance": "{{ cluster }}-{{seq}}",
                  "service": "{{ cluster }}-${role}",
                  "cluster": "{{ cluster }}"
              },
              "check": {"http": "http://{{ inventory_hostname }}:9631/", "interval": "5s", "timeout": "1s"}
          }}
	EOF

	# postgres
	cat >/etc/consul.d/srv-postgres.json <<-EOF
		{"service": {
          	"name": "postgres",
          	"port": 5432,
          	"tags": ["${role}", "{{ cluster }}"],
              "meta": {
                  "type": "postgres",
                  "role": "${role}",
                  "seq": "{{ seq }}",
                  "instance": "{{ cluster }}-{{seq}}",
                  "service": "{{ cluster }}-${role}",
                  "cluster": "{{ cluster }}",
                  "version": "{{ version }}"
              },
              "check": {"tcp": "localhost:5432", "interval": "5s", "timeout": "1s"}
          }}
	EOF

	# pgbouncer
	cat >/etc/consul.d/srv-pgbouncer.json <<-EOF
		{"service": {
              "name": "pgbouncer",
              "port": 6432,
              "tags": ["${role}", "{{ cluster }}"],
              "meta": {
                  "type": "postgres",
                  "role": "${role}",
                  "seq": "{{ seq }}",
                  "instance": "{{ cluster }}-{{seq}}",
                  "service": "{{ cluster }}-${role}",
                  "cluster": "{{ cluster }}",
                  "version": "{{ version }}"
              },
              "check": {"tcp": "localhost:6432", "interval": "5s", "timeout": "1s"}
          }}
	EOF

	# patroni
	cat >/etc/consul.d/srv-patroni.json <<-EOF
		{"service": {
            "name": "patroni",
            "port": 8008,
            "tags": ["${role}", "{{ cluster }}"],
            "meta": {
                "type": "patroni",
                "role": "${role}",
                "seq": "{{ seq }}",
                "instance": "{{ cluster }}-{{seq}}",
                "service": "{{ cluster }}-${role}",
                "cluster": "{{ cluster }}",
            	"version": "{{ version }}"
            },
        	"check": {"tcp": "{{ inventory_hostname }}:8008", "interval": "5s", "timeout": "1s"}
        }}
	EOF

	# database service (export to application)
	cat >/etc/consul.d/srv-{{ cluster }}.json <<-EOF
		{"service": {
            "name": "{{ cluster }}",
            "port": 6432,
            "tags": ["${role}", "{{ seq }}", "{{ cluster }}"],
            "meta": {
                "type": "postgres",
                "role": "${role}",
                "seq": "{{ seq }}",
                "instance": "{{ cluster }}-{{seq}}",
                "service": "{{ cluster }}-${role}",
                "cluster": "{{ cluster }}",
                "version": "{{ version }}"
            },
            "check": {"http": "http://{{ inventory_hostname }}:8008/${role}", "interval": "5s", "timeout": "1s"}
        }}
	EOF

	chown consul:postgres /etc/consul.d/srv-*
	consul reload

	printf "[$(date "+%Y-%m-%d %H:%M:%S")][${HOSTNAME}][event=reigster] [cluster=${cluster}] [role=${role}]\n" >>/pg/log/register.log
	exit 0
}

main $@
