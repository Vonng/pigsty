#!/bin/bash
set -uo pipefail
#==============================================================#
# File      :   provision.sh
# Mtime     :   2020-05-30
# Desc      :   provision vagrant node with basic ssh/dns
# Path      :   vagrant/bin/provision.sh
# Author    :   Vonng(fengruohang@outlook.com)
# Note      :   Run this as root (local or remote)
#==============================================================#
PROG_NAME="$(basename $0))"
PROG_DIR="$(cd $(dirname $0) && pwd)"

function setup_ssh() {
	local ssh_dir="/home/vagrant/.ssh"
	mkdir -p ${ssh_dir}

	# setup ssh access among all vagrant nodes
	[ -f /vagrant/ssh/id_rsa ] && cp /vagrant/ssh/id_rsa ${ssh_dir}/id_rsa
	[ -f /vagrant/ssh/id_rsa.pub ] && cp /vagrant/ssh/id_rsa.pub ${ssh_dir}/id_rsa.pub
	[ -f ${ssh_dir}/id_rsa.pub ] && cat ${ssh_dir}/id_rsa.pub >>${ssh_dir}/authorized_keys

	# add ssh config entry
	[ ! -f ${ssh_dir}/config ] && [ -f /vagrant/ssh/config ] && cp /vagrant/ssh/config ${ssh_dir}/config
	touch ${ssh_dir}/config
	if ! grep -q "StrictHostKeyChecking" ${ssh_dir}/config; then
		echo "StrictHostKeyChecking=no" >>${ssh_dir}/config
	fi

	# change owner and permission
	chown -R vagrant ${ssh_dir}
	chmod 700 ${ssh_dir} && chmod 600 ${ssh_dir}/*
	printf "\033[0;32m[INFO] write ssh config to ${ssh_dir} \033[0m\n" >&2
}

function setup_dns() {
	# /etc/hosts
	if $(grep 'pigsty dns records' /etc/hosts >/dev/null 2>&1); then
		printf "\033[0;33m[WARN] dns records already set, skip  \033[0m\n" >&2
	else
		cat >>/etc/hosts <<-EOF
			# pigsty dns records
			10.10.10.10	pigsty consul.pigsty grafana.pigsty prometheus.pigsty admin.pigsty haproxy.pigsty yum.pigsty
			10.10.10.10	c.pigsty g.pigsty p.pigsty pg.pigsty am.pigsty ha.pigsty yum.pigsty k8s.pigsty k.pigsty
			
			# physical nodes
			10.10.10.10   node0 n0 node-0 pg-meta-1 control meta master
			10.10.10.11   node1 n1 node-1 pg-test-1 pg-test-primary primary
			10.10.10.12   node2 n2 node-2 pg-test-2 pg-test-standby standby
			10.10.10.13   node3 n3 node-3 pg-test-3 pg-test-delayed delayed
			
			# virtual ip
			10.10.10.2   pg-test-primary
			10.10.10.3   pg-test-standby
			10.10.10.4	 pg-test-delayed
		EOF

		printf "\033[0;32m[INFO] write dns records into /etc/hosts \033[0m\n" >&2
	fi

	return 0
}

function setup_resolv() {
	# /etc/resolv.conf
	if $(grep 'nameserver 10.10.10.10' /etc/resolv.conf >/dev/null 2>&1); then
		printf "\033[0;33m[INFO] dns resolver records already set, skip  \033[0m\n" >&2
	else
		echo "nameserver 10.10.10.10" | cat - /etc/resolv.conf >/tmp/resolv.conf
		chmod 644 /tmp/resolv.conf
		mv -f /tmp/resolv.conf /etc/resolv.conf

		printf "\033[0;32m[INFO] write resolver records into /etc/resolv.conf \033[0m\n" >&2
	fi
}

function setup_firewall() {
	# disable selinux
	sudo sed -ie 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
	sudo setenforce 0
}

# main
if [[ $(whoami) != "root" ]]; then
	printf "\033[0;31m[INFO] setup-dns.sh require root privilege \033[0m\n" >&2
	return 1
fi

setup_ssh
setup_dns
setup_resolv
setup_firewall
