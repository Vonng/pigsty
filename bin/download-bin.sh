#!/bin/bash
set -euo pipefail

#==============================================================#
# File      :   download-bin.sh
# Ctime     :   2021-02-19
# Mtime     :   2021-02-19
# Desc      :   Download Binary Packages
# Path      :   files/download-bin.sh
# Depend    :   wget
# Copyright (C) 2018-2021 Ruohang Feng
#==============================================================#



echo "[NODE_EXPORTER] BEGIN ================================"
NODE_EXPORTER_VERSION=1.1.2
NODE_EXPORTER_FILENAME="node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64"
NODE_EXPORTER_URL="https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/${NODE_EXPORTER_FILENAME}.tar.gz"
rm -rf ${NODE_EXPORTER_FILENAME} "${NODE_EXPORTER_FILENAME}.tar.gz"
wget ${NODE_EXPORTER_URL}
tar -xf "${NODE_EXPORTER_FILENAME}.tar.gz"
mv -f "${NODE_EXPORTER_FILENAME}/node_exporter" bin/node_exporter
rm -rf ${NODE_EXPORTER_FILENAME} "${NODE_EXPORTER_FILENAME}.tar.gz"
echo "[NODE_EXPORTER] DONE ================================="



echo "[PG_EXPORTER] BEGIN ================================"
PG_EXPORTER_VERSION=0.3.2
PG_EXPORTER_FILENAME="pg_exporter_v${PG_EXPORTER_VERSION}_linux-amd64"
PG_EXPORTER_URL="https://github.com/Vonng/pg_exporter/releases/download/v${PG_EXPORTER_VERSION}/${PG_EXPORTER_FILENAME}.tar.gz"
rm -rf ${PG_EXPORTER_FILENAME} "${PG_EXPORTER_FILENAME}.tar.gz"
wget ${PG_EXPORTER_URL}
tar -xf "${PG_EXPORTER_FILENAME}.tar.gz"
mv -f "${PG_EXPORTER_FILENAME}/pg_exporter" bin/pg_exporter
rm -rf ${PG_EXPORTER_FILENAME} "${PG_EXPORTER_FILENAME}.tar.gz"
echo "[PG_EXPORTER] DONE ================================="


echo "[PROMETHEUS] BEGIN ================================="
PROMETHEUS_VERSION=2.26.0
PROMETHEUS_FILENAME="prometheus-${PROMETHEUS_VERSION}.linux-amd64"
PROMETHEUS_URL="https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/${PROMETHEUS_FILENAME}.tar.gz"
rm -rf ${PROMETHEUS_FILENAME} "${PROMETHEUS_FILENAME}.tar.gz"
wget ${PROMETHEUS_URL}
tar -xf "${PROMETHEUS_FILENAME}.tar.gz"
mv -f "${PROMETHEUS_FILENAME}/prometheus" bin/prometheus
mv -f "${PROMETHEUS_FILENAME}/promtool" bin/promtool
rm -rf ${PROMETHEUS_FILENAME} "${PROMETHEUS_FILENAME}.tar.gz"
echo "[PROMETHEUS] DONE ================================="


echo "[LOKI] BEGIN ================================="
LOKI_VERSION=2.2.0
rm -rf loki promtail logcli loki-canary loki-linux-amd64.zip promtail-linux-amd64.zip loki-canary-linux-amd64.zip
echo https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/loki-linux-amd64.zip
echo https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/promtail-linux-amd64.zip
echo https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/logcli-linux-amd64.zip
echo https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/loki-canary-linux-amd64.zip

unzip loki-linux-amd64.zip && mv loki-linux-amd64 bin/loki
unzip promtail-linux-amd64.zip && mv promtail-linux-amd64 bin/promtail
unzip logcli-linux-amd64.zip && mv logcli-linux-amd64 bin/logcli
unzip loki-canary-linux-amd64.zip && mv loki-canary-linux-amd64 bin/loki-canary

chmod a+x bin/*
# rm -rf loki-linux-amd64.zip promtail-linux-amd64.zip logcli-linux-amd64.zip loki-canary-linux-amd64.zip
echo "[LOKI] DONE ================================="


#echo "[GRAFANA] BEGIN ================================="
#GRAFANA_VERSION=7.5.2
#GRAFANA_FILENAME="grafana-${GRAFANA_VERSION}-1.x86_64.rpm"
#GRAFANA_URL="https://dl.grafana.com/oss/release/${GRAFANA_FILENAME}"
#wget ${GRAFANA_URL}
#mv ${GRAFANA_FILENAME} bin/
#echo "[PG_EXPORTER] DONE =============================="