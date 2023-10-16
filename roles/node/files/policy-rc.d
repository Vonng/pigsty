#!/bin/sh

# List of service names that should not be started by deb install/update
STOP_SERVICES="nginx loki dnsmasq haproxy keepalived docker promtail minio etcd postgresql pgbouncer patroni redis-server"

# Check if the service is in the STOP_SERVICES list
for SERVICE in $STOP_SERVICES; do
  if [ "$1" = "$SERVICE" ]; then
    exit 101
  fi
done

exit 0