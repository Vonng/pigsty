#==============================================================#
# File      :   Makefile
# Ctime     :   2019-04-13
# Mtime     :   2021-04-22
# Desc      :   Makefile shortcuts
# Path      :   Makefile
# Copyright (C) 2018-2021 Ruohang Feng
#==============================================================#

VERSION=0.9

# make default will pull up vm nodes
default: up

###############################################################
# Sandbox Quick Start Guide
###############################################################

# FIRST-TIME PREPAREDNESS
# 1. make deps           Install MacOS deps with homebrew
# 2. make download       Get pigsty.tgz and pkg.tgz from CDN
# 3. make start          Pull-up vm nodes and setup ssh access
# 4. make dns            Write static DNS (only run on first time)

# BOOTSTRAP
# 1. make meta           Bootstrap meta node (extract pkg.tgz, install ansible, get binaries)
# 2. make infra          Init infrastructure on meta node (and a pg-meta database, minimal setup)
# 3. make pgsql          Init additional 3-node pgsql cluster `pg-test` on node-1, node-2, node-3


###############################################################
# BOOTSTRAP
###############################################################
# upload pigsty & pkg tarball and bootstrap meta node
# (which means you can initiate control from meta node then)
# before running this, make sure pigsty resource file exists
# files/release/v${VERSION}/{pigsty,pkg}.tgz
meta: upload boot

# standard infra init procedure (init infra on meta)
infra:
	ssh meta 'cd pigsty && ansible-playbook infra.yml'

# standard pgsql init procedure (init 3-node cluster pg-test)
pgsql:
	ssh meta 'cd pigsty && ansible-playbook node.yml pgsql.yml -l pg-test'

# sandbox init playbook (init 4-node at one-pass, 2~3x faster than infra + pgsql)
init: sandbox


###############################################################
# FIRST-TIME Preparedness
###############################################################
# download pigsty resources
download: pigsty.tgz pkg.tgz

# start will pull-up node and write ssh-config
start: up ssh sync

# write sandbox vm ssh config (only run on first time)
ssh:
	bin/ssh

# write static dns records (sudo password required) (only run on first time)
dns:
	sudo bin/dns


###############################################################
# MacOS Sandbox Deps
###############################################################
brew:
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	brew install vagrant virtualbox ansible


###############################################################
# Playbooks
###############################################################
# remove pgsql cluster pg-test
pgsql-rm:
	ssh meta 'cd pigsty && ansible-playbook pgsql-remove.yml -l pg-test'

# fast sandbox init playbook (2~4x fast than infra first pgsql next)
sandbox:
	ssh meta 'cd pigsty && ./sandbox.yml -l pg-test'


###############################################################
# Bootstrap
###############################################################
# upload pigsty.tgz and extract to ~/pigsty
upload:
	ssh -t meta 'sudo rm -rf ~/pigsty.tgz ~/pigsty'
	scp files/release/v${VERSION}/pigsty.tgz meta:~/pigsty.tgz
	ssh -t meta 'tar -xf pigsty.tgz'
	scp files/release/v${VERSION}/pkg.tgz meta:~/pigsty/files/pkg.tgz

# bootstrap meta node with pkg.tgz and extract binaries
boot:
	ssh -t meta 'sudo bash ~/pigsty/bin/boot'
	ssh -t meta 'sudo bash ~/pigsty/bin/get_bin'


###############################################################
# Download Resource
###############################################################
# pigsty source code packages
pigsty.tgz:
	mkdir -p files/release/v${VERSION}/
	curl http://pigsty-1304147732.cos.accelerate.myqcloud.com/v${VERSION}/pigsty.tgz -o /tmp/pigsty.tgz

# offline installation packages
pkg.tgz:
	mkdir -p files/release/v${VERSION}/
	curl http://pigsty-1304147732.cos.accelerate.myqcloud.com/v${VERSION}/pkg.tgz -o files/pkg.tgz


###############################################################
# vagrant management
###############################################################
# create a new local sandbox (assume cache exists)
new: clean up
min: meta-up meta infra
clean:
	cd vagrant && vagrant destroy -f --parallel; exit 0
up:
	cd vagrant && vagrant up
halt:
	cd vagrant && vagrant halt
down: halt
status:
	cd vagrant && vagrant status
suspend:
	cd vagrant && vagrant suspend
resume:
	cd vagrant && vagrant resume
provision:
	cd vagrant && vagrant provision
# sync ntp time
sync:
	echo meta node-1 node-2 node-3 | xargs -n1 -P4 -I{} ssh {} 'sudo ntpdate -u pool.ntp.org'; true
	# echo meta node-1 node-2 node-3 | xargs -n1 -P4 -I{} ssh {} 'sudo chronyc -a makestep'; true

# show vagrant cluster status
st: status

# halt vm nodes
stop: halt

# partial node bootstrap
meta-up:
	cd vagrant && vagrant up meta
node-up:
	cd vagrant && vagrant up node-1 node-2 node-3
meta-new:
	cd vagrant && vagrant destroy -f meta
node-new:
	cd vagrant && vagrant destroy -f node-1 node-2 node-3
	cd vagrant && vagrant up node-1 node-2 node-3


###############################################################
# Bench Shortcuts
###############################################################

# list pg-test clusters
rl:
	ssh -t node-1 "sudo -iu postgres patronictl -c /pg/bin/patroni.yml list -W"

# init pgbench with factor 10
ri:
	ssh -t node-1 'sudo -iu postgres pgbench test -is10'

# pgbench small read-write / read-only traffic (rw=50TPS, ro=1000TPS)
rw:
	while true; do pgbench -nv -P1 -c2 --rate=50 -T10 postgres://test:test@pg-test:5433/test; done
ro:
	while true; do pgbench -nv -P1 -c4 --select-only --rate=1000 -T10 postgres://test:test@pg-test:5434/test; done

# pgbench read-write / read-only traffic (conn x 10, no TPS limit)
rw2:
	while true; do pgbench -nv -P1 -c20 -T10 postgres://test:test@pg-test:5433/test; done
ro2:
	while true; do pgbench -nv -P1 -c80 -T10 --select-only postgres://test:test@pg-test:5434/test; done

# reboot node 1,2,3
r1:
	ssh -t node-1 "sudo reboot"
r2:
	ssh -t node-2 "sudo reboot"
r3:
	ssh -t node-3 "sudo reboot"



###############################################################
# project
###############################################################
# generate playbook svg graph
svg:
	bin/play_svg

# use local meta node make offline installation packages
cache:
	scp bin/cache meta:/tmp/cache
	ssh meta 'sudo /tmp/cache'
	scp meta:/tmp/pkg.tgz files/release/v${VERSION}/pkg.tgz

# make pigsty source code tarball
release:
	bin/release ${VERSION}

# copy pigsty source to meta node (DEBUG)
cp: release
	scp files/release/v${VERSION}/pigsty.tgz meta:~/pigsty.tgz
	ssh meta 'sudo rm -rf pigsty; tar -xf pigsty.tgz; rm -rf pigsty.tgz'


.PHONY: default ssh dns cache init node meta infra clean up halt status suspend resume start stop down new
