#==============================================================#
# File      :   Makefile
# Ctime     :   2019-04-13
# Mtime     :   2020-09-17
# Desc      :   Makefile shortcuts
# Path      :   Makefile
# Copyright (C) 2018-2021 Ruohang Feng
#==============================================================#

VERSION=0.9

###############################################################
# Sandbox Shortcuts
###############################################################
# default cmd will pull up all vm nodes and setup ssh access
default: start
start: up ssh sync

# create a new local sandbox (assume cache exists)
new: clean start upload init

# write sandbox vm ssh config [RUN ONCE]
ssh:
	bin/ssh

# write static dns records (sudo password required) [RUN ONCE]
dns:
	sudo bin/dns

# upload rpm cache to meta controller
upload:
	scp files/release/${VERSION}/pigsty.tgz meta:~/pigsty.tgz
	ssh -t meta 'tar -xf pigsty.tgz'
	scp files/release/${VERSION}/pkg.tgz meta:~/pigsty/files/pkg.tgz

# boot will copy pigsty resources and bootstrap meta node
boot:
	ssh -t meta 'sudo bash ~/pigsty/bin/boot'
	ssh -t meta 'sudo bash ~/pigsty/bin/get_bin'



# fast provisioning on sandbox
init:
	./sandbox.yml                       # interleave sandbox provisioning

# provisioning on production
init2:
	./infra.yml                         # provision meta node infrastructure
	./node.yml  -l pg-test              # provision meta node infrastructure
	./pgsql.yml -l pg-test		        # provision pg-test and pg-meta

# recreate database cluster
reinit:
	./pgsql.yml --tags=pgsql -e pg_exists_action=clean

###############################################################
# Download Resource
###############################################################
dw: download-pigsty download-bin download-bin
download: download-pkg

download-pkg:
	curl http://pigsty-1304147732.cos.accelerate.myqcloud.com/latest/pkg.tgz -o files/pkg.tgz

download-bin:
	curl http://pigsty-1304147732.cos.accelerate.myqcloud.com/latest/bin.tgz -o files/bin.tgz

download-pigsty:
	curl http://pigsty-1304147732.cos.accelerate.myqcloud.com/latest/pigsty.tar.gz -o /tmp/pigsty.tgz


###############################################################
# vm management
###############################################################
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

stop: halt

# partial bootstrap
min: meta-up     # minimal setup: one node only
meta-up:
	cd vagrant && vagrant up meta
node-up:
	cd vagrant && vagrant up node-1 node-2 node-3
node-new:
	cd vagrant && vagrant destroy -f node-1 node-2 node-3
	cd vagrant && vagrant up node-1 node-2 node-3

###############################################################
# pgbench (init/read-write/read-only)
###############################################################
ri:
	ssh -t node-1 'sudo -iu postgres pgbench test -is10'
ri2:
	pgbench -is10 postgres://test:test@pg-test:5433/test
rw:
	while true; do pgbench -nv -P1 -c2 --rate=50 -T10 postgres://test:test@pg-test:5433/test; done
ro:
	while true; do pgbench -nv -P1 -c4 --select-only --rate=1000 -T10 postgres://test:test@pg-test:5434/test; done
rw2:
	while true; do pgbench -nv -P1 -c20 -T10 postgres://test:test@pg-test:5433/test; done
ro2:
	while true; do pgbench -nv -P1 -c80 -T10 --select-only postgres://test:test@pg-test:5434/test; done
rl:
	ssh -t node-1 "sudo -iu postgres patronictl -c /pg/bin/patroni.yml list -W"
r1:
	ssh -t node-1 "sudo reboot"
r2:
	ssh -t node-2 "sudo reboot"
r3:
	ssh -t node-3 "sudo reboot"
ckpt:
	ansible all -b --become-user=postgres -a "psql -c 'CHECKPOINT;'"
lb:
	./pgsql.yml -l pg-test --tags=haproxy_config,haproxy_reload


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
	scp meta:/tmp/pkg.tgz files/release/${VERSION}/pkg.tgz

release:
	bin/release ${VERSION}

deploy: release
	scp files/release/${VERSION}/pigsty.tgz meta:~/pigsty.tgz
	ssh meta 'rm -rf pigsty; tar -xf pigsty.tgz'


.PHONY: default ssh dns cache init node meta infra clean up halt status suspend resume start stop down new
