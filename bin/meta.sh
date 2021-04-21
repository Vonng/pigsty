#!/bin/bash
set -euo pipefail

#==============================================================#
# File      :   meta.sh
# Ctime     :   2021-04-20
# Mtime     :   2021-04-20
# Desc      :   meta node bootstrap (install ansible)
# Note      :   run as root
#               1. try unzip ./pkg.tgz as local repo first
#               2. install ansible from local repo
#               3. try install ansible from internet if not applicable
# Path      :   files/meta.sh
# Copyright (C) 2018-2021 Ruohang Feng
#==============================================================#

PROG_NAME="$(basename $0))"
PROG_DIR="$(cd $(dirname $0) && pwd)"


#==============================================================#
# Arg1      :   pkg.tgz path (./pkg.tgz)
# Arg2      :   repo name (pigsty by default)
# Arg3      :   repo home (/www by default)
#==============================================================#
DEFAULT_PKG_PATH=${PROG_DIR}/pkg.tgz

PKG_PATH=${1-${DEFAULT_PKG_PATH}}
REPO_NAME=${2-'pigsty'}
REPO_HOME=${3-'/www'}

echo "[INFO] extract ${PKG_PATH} to ${REPO_HOME}/${REPO_NAME}"

# run this as root
if [[ "$(whoami)" != "root" ]]; then
    echo "[ERROR] permission denied: run this as root"
    exit 1
fi

# check files/pkg.tgz exists
if [[ -e ${PKG_PATH} ]]; then
    echo "[INFO] ${PKG_PATH} exists"
else
    echo "[ERROR] ${PKG_PATH} not exists, try boot from internet"
    yum install -y createrepo sshpass wget yum yum-utils epel-release
    yum install -y ansible
    exit 0
fi

# make sure repo home exists
if [[ -d ${REPO_HOME} ]]; then
    echo "[INFO] ${REPO_HOME} not found, create"
    mkdir -p ${REPO_HOME}
fi

# make sure repo name dir not exists
if [[ -d "${REPO_HOME}/${REPO_NAME}" ]]; then
    echo "[WARN] ${REPO_HOME}/${REPO_NAME} exists, remove"
    rm -rf "${REPO_HOME:?}/${REPO_NAME:?}" "${REPO_HOME:?}/pigsty"
fi

# unzip pkg.tgz -> ${REPO_HOME}/pigsty
tar -xf ${PKG_PATH} -C ${REPO_HOME}
if [[ ${REPO_NAME} != "pigsty" ]]; then
    echo "[INFO] move ${REPO_HOME}/pigsty to ${REPO_HOME}/${REPO_NAME}"
fi

# backup all repos in /etc/yum.repos.d
echo "[INFO] mv -f /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/"
mkdir -p /etc/yum.repos.d/backup
mv -f /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/ 2> /dev/null || true
touch /etc/yum.repos.d/backup/${REPO_NAME}.repo

echo "[INFO] create ${REPO_NAME}.repo"
cat >/etc/yum.repos.d/${REPO_NAME}.repo  <<-EOF
[${REPO_NAME}]
name=${REPO_NAME} \$releasever - \$basearch
baseurl=file://${REPO_HOME}/${REPO_NAME}/
enabled=1
gpgcheck=0
EOF

echo "[INFO] remake yum cache"
yum clean all
yum makecache

echo "[INFO] install ansible utils"
yum install -y createrepo sshpass wget yum unzip yum-utils
yum install -y ansible


# if you already have full pkg.tgz , why not install meta packages at all?
# echo "[INFO] install additional meta packages"
# yum install -y nginx wget yum-utils yum createrepo sshpass
# yum install -y wget yum-utils ntp chrony tuned uuid lz4 vim-minimal make patch bash lsof wget unzip git readline zlib openssl
# yum install -y numactl grubby sysstat dstat iotop bind-utils net-tools tcpdump socat ipvsadm telnet tuned pv jq
# yum install -y python3 python3-psycopg2 python36-requests python3-etcd python3-consul
# yum install -y python36-urllib3 python36-idna python36-pyOpenSSL python36-cryptography
# yum install -y node_exporter consul consul-template etcd haproxy keepalived vip-manager
# yum install -y patroni patroni-consul patroni-etcd pgbouncer pgbadger pg_activity
# yum install -y grafana prometheus2 alertmanager nginx_exporter blackbox_exporter pushgateway
# yum install -y dnsmasq nginx ansible pgbadger polysh