#!/bin/bash
set -uo pipefail
#==============================================================#
# File      :   provision.sh
# Mtime     :   2020-05-30
# Desc      :   provision vagrant node with basic ssh/dns
# Path      :   vagrant/provision.sh
# Note      :   currently only ssh is provisioned
# Note      :   Run this as root
# Copyright (C) 2018-2021 Ruohang Feng
#==============================================================#

PROG_NAME="$(basename $0))"
PROG_DIR="$(cd $(dirname $0) && pwd)"

# vagrant ssh access to each other
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
		cat >>${ssh_dir}/config <<-EOF
			StrictHostKeyChecking=no
			# Host *
				# ServerAliveInterval 60
				# ServerAliveCountMax 5
				# ControlMaster auto
				# ControlPath ~/.ssh/%r@%h-%p
				# ControlPersist 4h
		EOF
	fi
	# change owner and permission
	chown -R vagrant ${ssh_dir} && chmod 700 ${ssh_dir} && chmod 600 ${ssh_dir}/*
	printf "\033[0;32m[INFO] write ssh config to ${ssh_dir} \033[0m\n" >&2
}

# pigsty statistic dns records
function setup_dns() {
	# /etc/hosts
	if grep -q 'pigsty public domain name' /etc/hosts; then
		printf "\033[0;33m[WARN] dns records already set, skip  \033[0m\n" >&2
	else
		cat >>/etc/hosts <<-EOF
			# pigsty public domain name
			10.10.10.10	pigsty consul.pigsty grafana.pigsty prometheus.pigsty admin.pigsty haproxy.pigsty yum.pigsty
			10.10.10.10	c.pigsty g.pigsty p.pigsty pg.pigsty am.pigsty ha.pigsty yum.pigsty k8s.pigsty k.pigsty
			
			# pigsty nodes domain name
			10.10.10.10   node-0 meta master
			10.10.10.11   node-1 n1
			10.10.10.12   node-2 n2
			10.10.10.13   node-3 n3

			# pre-allocted pigsty virtual ip
			10.10.10.2		pg-meta
			10.10.10.3		pg-test

		EOF
		printf "\033[0;32m[INFO] write dns records into /etc/hosts \033[0m\n" >&2
	fi
	return 0
}

# pigsty dynamic dns resolver
function setup_resolv() {
	# /etc/resolv.conf
	if grep -q 'nameserver 10.10.10.10' /etc/resolv.conf; then
		printf "\033[0;33m[INFO] dns resolver records already set, skip  \033[0m\n" >&2
	else
		echo "nameserver 10.10.10.10" | cat - /etc/resolv.conf >/tmp/resolv.conf
		chmod 644 /tmp/resolv.conf
		mv -f /tmp/resolv.conf /etc/resolv.conf
		printf "\033[0;32m[INFO] write resolver records into /etc/resolv.conf \033[0m\n" >&2
	fi
}

# disable selinux
function setup_selinux() {
	sudo sed -ie 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
	sudo setenforce 0
	printf "\033[0;32m[INFO] disable selinux \033[0m\n" >&2
}


# expand vagrant cache from /vagrant
function setup_vagrant_cache() {
	mkdir -p /www
	if [[ -d /vagrant/pkg ]]; then
		rm -rf /www/pigsty
		mv /vagrant/pkg /www/pigsty
	fi

	if [[ -d /vagrant/ansible ]]; then
		rm -rf /home/vagrant/ansible
		ln -s /vagrant/ansible /home/vagrant/ansible
		chown -R vagrant /home/vagrant
	fi
}

# main
function main() {
	if [[ $(whoami) != "root" ]]; then
		printf "\033[0;31m[INFO] setup-dns.sh require root privilege \033[0m\n" >&2
		return 1
	fi
	setup_ssh
#	setup_dns
#	setup_resolv
#	setup_selinux
#	setup_vagrant_cache
}

main
