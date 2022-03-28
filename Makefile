#==============================================================#
# File      :   Makefile
# Ctime     :   2019-04-13
# Mtime     :   2022-03-20
# Desc      :   Makefile shortcuts
# Path      :   Makefile
# Copyright (C) 2018-2022 Ruohang Feng (rh@vonng.com)
#==============================================================#

# pigsty version
VERSION?=v1.4.0

# target cluster (meta by default)
CLS?=meta

###############################################################
#                      1. Quick Start                         #
###############################################################
# run with nopass SUDO user (or root) on CentOS 7.x node
default: tip
tip:
	@echo "# Run on Linux x86_64 CentOS 7.8 node with sudo & ssh access"
	@echo "./download pigsty pkg     # download pigsty source & pkgs"
	@echo "./configure               # pre-check and templating config"
	@echo "./infra.yml               # install pigsty on current node"

# print pkg download links
link:
	@echo 'bash -c "$$(curl -fsSL http://download.pigsty.cc/get)"'
	@echo "[Github Download]"
	@echo "curl -SL https://github.com/Vonng/pigsty/releases/download/${VERSION}/pigsty.tgz | gzip -d | tar -xC ~ ; cd ~/pigsty"
	@echo "curl -SL https://github.com/Vonng/pigsty/releases/download/${VERSION}/pkg.tgz -o /tmp/pkg.tgz           # [optional]"
	@echo "[CDN Download]"
	@echo "curl -SL http://download.pigsty.cc/${VERSION}/pigsty.tgz | gzip -d | tar -xC ~ ; cd ~/pigsty"
	@echo "curl -SL http://download.pigsty.cc/${VERSION}/pkg.tgz -o /tmp/pkg.tgz           # [optional]"

# get pigsty source from CDN
get:
	bash -c "$(curl -fsSL http://download.pigsty.cc/get)"

#-------------------------------------------------------------#
# there are 3 steps launching pigsty:
all: download configure install

# (1). DOWNLOAD   pigsty source code to ~/pigsty, pkg to /tmp/pkg.tgz
download:
	./download pigsty pkg

# (2). CONFIGURE  pigsty in interactive mode
config:
	./configure

# (3). INSTALL    pigsty on current node
install:
	./infra.yml
###############################################################



###############################################################
#                        OUTLINE                              #
###############################################################
#  (1). Quick-Start   :   shortcuts for launching pigsty (above)
#  (2). Download      :   shortcuts for downloading resources
#  (3). Configure     :   shortcuts for configure pigsty
#  (4). Install       :   shortcuts for running playbooks
#  (5). Sandbox       :   shortcuts for mange sandbox vm nodes
#  (6). Testing       :   shortcuts for testing features
#  (7). Develop       :   shortcuts for dev purpose
#  (8). Release       :   shortcuts for release and publish
#  (9). Misc          :   shortcuts for miscellaneous tasks
###############################################################



###############################################################
#                      2. Download                            #
###############################################################
# There are two things needs to be downloaded:
#    pigsty.tgz    :   source code
#    pkg.tgz       :   offline rpm packages (build under 7.8)
#
# get latest stable version to ~/pigsty
src:
	curl -SL https://github.com/Vonng/pigsty/releases/download/${VERSION}/pigsty.tgz -o ~/pigsty.tgz

# download pkg.tgz to /tmp/pkg.tgz
pkg:
	curl -SL https://github.com/Vonng/pigsty/releases/download/${VERSION}/pkg.tgz -o /tmp/pkg.tgz
###############################################################



###############################################################
#                      3. Configure                           #
###############################################################
# there are several things needs to be checked before install
# use ./configure or `make config` to run interactive wizard
# it will install ansible (from offline rpm repo if available)

# common interactive configuration procedure
c: config

# config with parameters
# IP=10.10.10.10 MODE=oltp make conf
conf:
	./configure --ip ${IP} --mode ${MODE} --download
###############################################################



###############################################################
#                      4. Install                             #
###############################################################
# pigsty is installed via ansible-playbook

# install pigsty on meta nodes
infra:
	./infra.yml

# reinit pgsql cmdb
pgsql:
	./infra.yml --tags=cmdb -e pg_exists_action=clean

# rebuild repo
repo:
	./infra.yml --tags=repo

# write upstream repo to /etc/yum.repos.d
repo-upstream:
	./infra.yml --tags=repo_upstream

# download repo packages
repo-download:
	sudo rm -rf /www/pigsty/repo_complete
	./infra.yml --tags=repo_upstream,repo_download

# init prometheus
prometheus:
	./infra.yml --tags=prometheus

# init grafana
grafana:
	./infra.yml --tags=grafana

# init loki
loki:
	./infra.yml --tags=loki -e loki_clean=true


###############################################################




###############################################################
#                       5. Sandbox                            #
###############################################################
# shortcuts to pull up vm nodes with vagrant on your own MacOS
# DO NOT RUN THESE SHORTCUTS ON YOUR META NODE!!!
# These shortcuts are running on your HOST machine which run
# pigsty sandbox via virtualbox managed by vagrant.
#=============================================================#
# to setup vagrant sandbox env on your MacOS host:
#
#  Prepare
#  (1). make deps    (once) Install MacOS deps with homebrew
#  (2). make dns     (once) Write static DNS
#  (3). make start   (once) Pull-up vm nodes and setup ssh access
#  (4). make demo           Boot meta node same as Quick-Start
#=============================================================#

#------------------------------#
# 1. deps
#------------------------------#
# install macos sandbox software dependencies
deps:
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	brew install vagrant virtualbox ansible

#------------------------------#
# 2. dns
#------------------------------#
# write static dns records (sudo password required) (only run on first time)
dns:
	sudo bin/dns

#------------------------------#
# 3. start
#------------------------------#
# start will pull-up node and write ssh-config
# it may take a while to download centos/7 box for the first time
start: up ssh      # 1-node version
start4: up4 ssh    # 4-node version
ssh:               # add node ssh config to your ~/.ssh/config
	bin/ssh

#------------------------------#
# 4. demo
#------------------------------#
# launch one-node demo
demo: demo-prepare
	ssh meta 'cd ~/pigsty; ./infra.yml'

# launch four-node demo
demo4: demo-prepare
	ssh meta 'cd ~/pigsty; ./infra-demo.yml'

# prepare demo resource by download|upload
demo-prepare: demo-upload

# download demo pkg.tgz from github
demo-download:
	ssh meta "cd ~ && curl -fsSLO https://github.com/Vonng/pigsty/releases/download/${VERSION}/pigsty.tgz && tar -xf pigsty.tgz && cd pigsty"
	ssh meta '/home/vagrant/pigsty/configure --ip 10.10.10.10 --non-interactive --download -m demo'

# upload demo pkg.tgz from local dist dir
demo-upload:
	scp "dist/${VERSION}/pigsty.tgz" meta:~/pigsty.tgz
	ssh -t meta 'rm -rf ~/pigsty; tar -xf pigsty.tgz; rm -rf pigsty.tgz'
	scp "dist/${VERSION}/pkg.tgz" meta:/tmp/pkg.tgz
	ssh meta '/home/vagrant/pigsty/configure --ip 10.10.10.10 --non-interactive -m demo'

#------------------------------#
# vagrant vm management
#------------------------------#
# default node (meta)
up:
	cd vagrant && vagrant up meta
dw:
	cd vagrant && vagrant halt meta
del:
	cd vagrant && vagrant destroy -f meta
new: del up
#------------------------------#
# extra nodes: node-{1,2,3}
up-test:
	cd vagrant && vagrant up node-1 node-2 node-3
dw-test:
	cd vagrant && vagrant halt node-1 node-2 node-3
del-test:
	cd vagrant && vagrant destroy -f node-1 node-2 node-3
new-test: del-test up-test
#------------------------------#
# all nodes (meta, node-1, node-2, node-3)
up4:
	cd vagrant && vagrant up
dw4:
	cd vagrant && vagrant halt
del4:
	cd vagrant && vagrant destroy -f
new4: del4 up4
clean: del4
#------------------------------#
# status
st: status
status:
	cd vagrant && vagrant status
suspend:
	cd vagrant && vagrant suspend
resume:
	cd vagrant && vagrant resume

#------------------------------#
# time sync
#------------------------------#
# sync meta node time
s:sync
sync:  # sync time
	ssh meta 'sudo ntpdate -u pool.ntp.org'; true

# sync 4 node time
s4: sync4
sync4:  # sync time
	echo meta node-1 node-2 node-3 | xargs -n1 -P4 -I{} ssh {} 'sudo ntpdate -u pool.ntp.org'; true
ss:     # sync time with aliyun ntp service
	echo meta node-1 node-2 node-3 | xargs -n1 -P4 -I{} ssh {} 'sudo ntpdate -u ntp.aliyun.com'; true
###############################################################



###############################################################
#                       6. Testing                            #
###############################################################
# Convenient shortcuts for add traffic to sandbox pgsql clusters
#  ri  test-ri   :  init pgbench on meta or pg-test cluster
#  rw  test-rw   :  read-write pgbench traffic on meta or pg-test
#  ro  test-ro   :  read-only pgbench traffic on meta or pg-test
#  rc  test-rc   :  clean-up pgbench tables on meta or pg-test
#  test-rw2 & test-ro2 : heavy load version of test-rw, test-ro
#  test-rb{1,2,3} : reboot node 1,2,3
#=============================================================#
# meta cmdb bench
ri:
	pgbench -is10 postgres://dbuser_meta:DBUser.Meta@meta:5433/meta
rc:
	psql -AXtw postgres://dbuser_meta:DBUser.Meta@meta:5433/meta -c 'DROP TABLE IF EXISTS pgbench_accounts, pgbench_branches, pgbench_history, pgbench_tellers;'
rw:
	while true; do pgbench -nv -P1 -c4 --rate=64 -T10 postgres://dbuser_meta:DBUser.Meta@meta:5433/meta; done
ro:
	while true; do pgbench -nv -P1 -c8 --rate=256 --select-only -T10 postgres://dbuser_meta:DBUser.Meta@meta:5434/meta; done

# pg-test cluster benchmark

test-ri:
	pgbench -is10  postgres://test:test@pg-test:5436/test
test-rc:
	psql -AXtw postgres://test:test@pg-test:5433/test -c 'DROP TABLE IF EXISTS pgbench_accounts, pgbench_branches, pgbench_history, pgbench_tellers;'
# pgbench small read-write / read-only traffic (rw=64TPS, ro=512QPS)
test-rw:
	while true; do pgbench -nv -P1 -c4 --rate=64 -T10 postgres://test:test@pg-test:5433/test; done
test-ro:
	while true; do pgbench -nv -P1 -c8 --select-only --rate=512 -T10 postgres://test:test@pg-test:5434/test; done
# pgbench read-write / read-only traffic (maximum speed)
test-rw2:
	while true; do pgbench -nv -P1 -c16 -T10 postgres://test:test@pg-test:5433/test; done
test-ro2:
	while true; do pgbench -nv -P1 -c64 -T10 --select-only postgres://test:test@pg-test:5434/test; done
#------------------------------#
# show patroni status for pg-test cluster
test-st:
	ssh -t node-1 "sudo -iu postgres patronictl -c /pg/bin/patroni.yml list -W"
# reboot node 1,2,3
test-rb1:
	ssh -t node-1 "sudo reboot"
test-rb2:
	ssh -t node-2 "sudo reboot"
test-rb3:
	ssh -t node-3 "sudo reboot"
###############################################################



###############################################################
#                       7. Develop                            #
###############################################################
#  other shortcuts for development
#=============================================================#

#------------------------------#
# grafana dashboard management
#------------------------------#
di: dashboard-init                    # init grafana dashboards
dashboard-init:
	cd roles/grafana/files/dashboards/ && ./grafana.py init

dd: dashboard-dump                    # dump grafana dashboards
dashboard-dump:
	cd roles/grafana/files/dashboards/ && ./grafana.py dump

dc: dashboard-clean                   # cleanup grafana dashboards
dashboard-clean:
	cd files/ui && ./grafana.py clean

du: dashboard-clean dashboard-init    # update grafana dashboards

#------------------------------#
# copy source & packages
#------------------------------#
# copy latest pro source code
copy: release copy-src copy-pkg use-src use-pkg

# copy pigsty source code
copy-src:
	scp "dist/${VERSION}/pigsty.tgz" meta:~/pigsty.tgz
copy-pkg:
	scp dist/${VERSION}/pkg.tgz meta:/tmp/pkg.tgz
copy-pkg2:
	scp dist/${VERSION}/matrix.tgz meta:/tmp/matrix.tgz
copy-app:
	scp dist/${VERSION}/app.tgz meta:~/app.tgz
	ssh -t meta 'rm -rf ~/app; tar -xf app.tgz; rm -rf app.tgz'
copy-all: copy-src copy-pkg

use-src:
	ssh -t meta 'rm -rf ~/pigsty; tar -xf pigsty.tgz; rm -rf pigsty.tgz'
use-pkg:
	ssh meta '/home/vagrant/pigsty/configure --ip 10.10.10.10 --non-interactive --download -m demo'
use-pkg2:
	ssh meta 'sudo tar -xf /tmp/matrix.tgz -C /www'
	scp files/matrix.repo meta:/tmp/matrix.repo
	ssh meta sudo mv -f /tmp/matrix.repo /www/matrix.repo
use-all: use-src use-pkg
use-matrix: copy-pkg2 use-pkg2

###############################################################



###############################################################
#                       8. Release                            #
###############################################################
# make release
r: release
release:
	bin/release ${VERSION}

# release-pkg will make cache and copy to dist dir
rp: release-pkg
release-pkg: cache
	scp meta:/tmp/pkg.tgz dist/${VERSION}/pkg.tgz

# release
rp2: release-matrix-pkg
release-matrix-pkg:
	#ssh meta 'sudo cp -r /www/matrix /tmp/matrix; sudo chmod -R a+r /www/matrix'
	ssh meta sudo tar zcvf /tmp/matrix.tgz -C /www matrix
	scp meta:/tmp/matrix.tgz dist/${VERSION}/matrix.tgz

# publish will publish pigsty packages
p: release publish
publish:
	bin/publish ${VERSION}

# create pkg.tgz on initialized meta node
cache:
	scp bin/cache meta:/tmp/cache
	ssh meta "sudo bash /tmp/cache"

###############################################################



###############################################################
#                         9. Misc                             #
###############################################################
# generate playbook svg graph
svg:
	bin/svg

# serve pigsty doc with docsify or python http server
d: doc
doc:
	bin/doc

###############################################################



###############################################################
#                         Appendix                            #
###############################################################
.PHONY: default tip link all download config install \
        src pkg \
        c conf \
        infra pgsql repo repo-upstream repo-download prometheus grafana loki \
        repo repo-upstream repo prometheus grafana loki \
        deps dns start start4 ssh demo demo4 demo-prepare demo-download demo-upload \
        up dw del new up-test dw-test del-test new-test up4 dw4 del4 new4 clean \
        st status suspend resume s sync s4 sync4 ss \
        ri rc rw ro test-ri test-rw test-ro test-rw2 test-ro2 test-rc test-st test-rb1 test-rb2 test-rb3 \
        di dd dc dashboard-init dashboard-dump dashboard-clean \
        copy copy2 copy-src copy-pkg copy-pkg2 copy-app copy-all use-src use-pkg use-pkg2 use-all  \
        r releast rp release-pkg rp2 release-matrix-pkg p publish cache \
        svg doc d
###############################################################
