#==============================================================#
# File      :   Makefile
# Ctime     :   2019-04-13
# Mtime     :   2021-04-29
# Desc      :   Makefile shortcuts
# Path      :   Makefile
# Copyright (C) 2018-2021 Ruohang Feng
#==============================================================#

# the latest version of pigsty is 0.9
VERSION=0.9

# make default will pull up vm nodes
default: up

###############################################################
#               META NODE BOOTSTRAP COMMAND                   #
###############################################################

#=============================================================#
# quick start:
#   1.  /bin/bash -c "$(curl -fsSL https://pigsty.cc/install)"
#   2.  cd ~/pigsty ; make pkg                     # (optional)
#   3.  make meta
#=============================================================#

# install pigsty on ~/pigsty
install:
	/bin/bash -c "$(curl -fsSL https://pigsty.cc/install)"

# download optional offline installation packages (optional, for centos7.8 only)
# BUT if your meta node DOES NOT HAVE INTERNET ACCESS
# You may have to copy/ftp/scp pkg.tgz & pigsty.tgz into meta node manually
pkg:
	bin/get_pkg ${VERSION}

# install ansible and init infrastructure
meta: boot infra

# install ansible (and use /tmp/pkg.tgz if exists)
boot:
	sudo bin/boot

# init infrastructure with ansible on meta node
infra:
	./infra.yml

# make offline installation packages (to /tmp/pkg.tgz)
cache:
	sudo bin/cache

# upgrade switch to meta db inventory instead of static config
upgrade:
	bin/upgrade


###############################################################
#                SANDBOX BOOTSTRAP COMMAND                    #
###############################################################
# these command are used for local vagrant sandbox environment

# PREPAREDNESS (on your host, to setup vagrant sandbox env)
# 1. make deps           Install MacOS deps with homebrew
# 2. make download       Get pigsty.tgz and pkg.tgz from CDN
# 3. make start          Pull-up vm nodes and setup ssh access
# 4. make dns            Write static DNS (only run on first time)
# 5. make copy           Copy pigsty resource to sandbox meta node

# BOOTSTRAP (inside vm meta node, same as standard procedure)
# make meta              Bootstrap meta node (extract pkg.tgz, install ansible, get binaries)


#=============================================================#
# PREPAREDNESS
#=============================================================#
# install macos sandbox software dependencies
deps:
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	brew install vagrant virtualbox ansible

# download pigsty resources (to files/release/v*.*/{pkg,pigsty}.tgz)
download: pkg
	mkdir files/release/v${VERSION}/
	cp -f /tmp/pkg.tgz files/release/v${VERSION}/pkg.tgz
	curl -fsSL https://pigsty.cc/pigsty.tgz -o files/release/v${VERSION}/pigsty.tgz

# start will pull-up node and write ssh-config
start: meta-up ssh

# start4 will pull-up all node and write ssh-config
start4: up ssh

# write static dns records (sudo password required) (only run on first time)
dns:
	sudo bin/dns

# write sandbox vm ssh config (only run on first time)
ssh:
	bin/ssh

# copy pigsty.tgz and pkg.tgz to sandbox meta node
copy:
	scp files/release/v${VERSION}/pigsty.tgz meta:~/pigsty.tgz
	scp files/release/v${VERSION}/pkg.tgz meta:/tmp/pkg.tgz
	ssh -t meta 'tar -xf pigsty.tgz'

#=============================================================#
# vagrant management
#=============================================================#
# create a new local sandbox (assume cache exists)
new: clean meta-up
new4: clean up
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
	cd vagrant && vagrant up meta
node-new:
	cd vagrant && vagrant destroy -f node-1 node-2 node-3
	cd vagrant && vagrant up node-1 node-2 node-3



#=============================================================#
# benchmark Shortcuts
#=============================================================#
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



#=============================================================#
# project misc
#=============================================================#

# generate playbook svg graph
svg:
	bin/play_svg

# copy cached pkg.tgz from meta node
pkg.tgz:
	scp meta:/tmp/pkg.tgz files/pkg.tgz

# make pigsty source code tarball
release:
	bin/release ${VERSION}

# publish will publish pigsty to pigsty.cc
publish:
	bin/publish ${VERSION}

# print quick-start tips
tip:
	cat bin/install | tail -n1

.PHONY: default install pkg meta boot infra deps download start dns ssh copy new min clean up halt down status suspend resume provision sync st stop meta-up node-up meta-new node-new rl ri rw ro rw2 ro2 r1 r2 r3 svg cache release pub cp
