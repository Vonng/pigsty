#==============================================================#
# File      :   Makefile
# Desc      :   pigsty shortcuts
# Ctime     :   2019-04-13
# Mtime     :   2023-03-21
# Path      :   Makefile
# Author    :   Ruohang Feng (rh@vonng.com)
# License   :   AGPLv3
#==============================================================#
# pigsty version & default develop & testing el version
VERSION?=v2.1.0-a1
EL_VER=9

# local name
SRC_PKG=pigsty-$(VERSION).tgz
APP_PKG=pigsty-app-$(VERSION).tgz
REPO_PKG=pigsty-pkg-$(VERSION).el${EL_VER}.x86_64.tgz
DOCKER_PKG=pigsty-docker-$(VERSION).tgz
EL7_PKG=pigsty-pkg-$(VERSION).el7.x86_64.tgz
EL8_PKG=pigsty-pkg-$(VERSION).el8.x86_64.tgz
EL9_PKG=pigsty-pkg-$(VERSION).el9.x86_64.tgz

###############################################################
#                      1. Quick Start                         #
###############################################################
# run with nopass SUDO user (or root) on CentOS 7.x node
default: tip
tip:
	@echo "# Run on Linux x86_64 EL7-9 node with sudo & ssh access"
	@echo 'bash -c "$$(curl -fsSL http://download.pigsty.cc/get)"'
	@echo "./bootstrap     # prepare local repo & ansible"
	@echo "./configure     # pre-check and templating config"
	@echo "./install.yml   # install pigsty on current node"

# print pkg download links
link:
	@echo 'bash -c "$$(curl -fsSL http://download.pigsty.cc/get)"'
	@echo "[Github Download]"
	@echo "curl -SL https://github.com/Vonng/pigsty/releases/download/${VERSION}/${SRC_PKG} | gzip -d | tar -xC ~ ; cd ~/pigsty"
	@echo "curl -SL https://github.com/Vonng/pigsty/releases/download/${VERSION}/${REPO_PKG} -o /tmp/pkg.tgz  # [optional]"
	@echo "[CDN Download]"
	@echo "curl -SL http://download.pigsty.cc/${VERSION}/${SRC_PKG} | gzip -d | tar -xC ~ ; cd ~/pigsty"
	@echo "curl -SL http://download.pigsty.cc/${VERSION}/${REPO_PKG} -o /tmp/pkg.tgz # [optional]"

# get pigsty source from CDN
get:
	bash -c "$(curl -fsSL http://download.pigsty.cc/get)"

# serve a local docs with docsify or python http
doc:
	docs/serve

#-------------------------------------------------------------#
# there are 3 steps launching pigsty:
all: bootstrap configure install

# (1). BOOTSTRAP  pigsty pkg & util preparedness
bootstrap:
	./boostrap

# (2). CONFIGURE  pigsty in interactive mode
config:
	./configure

# (3). INSTALL    pigsty on current node
install:
	./install.yml
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
#    pkg.tgz       :   offline rpm packages (build under 7.9)
#
# get latest stable version to ~/pigsty
src:
	curl -SL https://github.com/Vonng/pigsty/releases/download/${VERSION}/${SRC_PKG} -o ~/pigsty.tgz

# download pkg.tgz to /tmp/pkg.tgz
pkg:
	curl -SL https://github.com/Vonng/pigsty/releases/download/${VERSION}/${REPO_PKG} -o /tmp/pkg.tgz
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
	./configure --ip ${IP} --mode ${MODE}
###############################################################



###############################################################
#                      4. Install                             #
###############################################################
# pigsty is installed via ansible-playbook

# install pigsty on meta nodes
infra:
	./infra.yml

# rebuild repo
repo:
	./infra.yml --tags=repo

# write upstream repo to /etc/yum.repos.d
repo-upstream:
	./infra.yml --tags=repo_upstream

# download repo packages
repo-build:
	sudo rm -rf /www/pigsty/repo_complete
	./infra.yml --tags=repo_upstream,repo_build

# init prometheus
prometheus:
	./infra.yml --tags=prometheus

# init grafana
grafana:
	./infra.yml --tags=grafana

# init loki
loki:
	./infra.yml --tags=loki -e loki_clean=true

# init docker
docker:
	./docker.yml

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
# 1. deps (macos)
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
ssh:               # add node ssh config to your ~/.ssh/config
	bin/ssh

#------------------------------#
# 4. demo
#------------------------------#
# launch one-node demo
demo: demo-prepare
	ssh meta "cd ~ && curl -fsSLO https://github.com/Vonng/pigsty/releases/download/${VERSION}/${SRC_PKG} -o ~/pigsty.tgz && tar -xf pigsty.tgz"
	ssh meta 'cd ~/pigsty; ./bootstrap -y'
	ssh meta 'cd ~/pigsty; ./configure --ip 10.10.10.10 --non-interactive -m demo'
	ssh meta 'cd ~/pigsty; ./install.yml'

#------------------------------#
# vagrant vm management
#------------------------------#
# default node (meta)
up:
	cd vagrant && vagrant up
dw:
	cd vagrant && vagrant halt
del:
	cd vagrant && vagrant destroy -f
new: del up
clean: del
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
# status
st: status
status:
	cd vagrant && vagrant status
suspend:
	cd vagrant && vagrant suspend
resume:
	cd vagrant && vagrant resume
#------------------------------#
# vagrant templates:
v1:
	vagrant/switch meta
v4:
	vagrant/switch full
v7:
	vagrant/switch el7
v8:
	vagrant/switch el8
v9:
	vagrant/switch el9
vb:
	vagrant/switch build
vc:
	vagrant/switch citus
vnew: new ssh copy-pkg use-pkg copy-src use-src

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
rh:
	ssh meta 'sudo -iu postgres /pg/bin/pg-heartbeat'
# pg-test cluster benchmark
test-ri:
	pgbench -is10  postgres://test:test@pg-test:5436/test
test-rc:
	psql -AXtw postgres://test:test@pg-test:5433/test -c 'DROP TABLE IF EXISTS pgbench_accounts, pgbench_branches, pgbench_history, pgbench_tellers;'
# pgbench small read-write / read-only traffic (rw=64TPS, ro=512QPS)
test-rw:
	while true; do pgbench -nv -P1 -c4 --rate=32 -T10 postgres://test:test@pg-test:5433/test; done
test-ro:
	while true; do pgbench -nv -P1 -c8 --select-only --rate=256 -T10 postgres://test:test@pg-test:5434/test; done
# pgbench read-write / read-only traffic (maximum speed)
test-rw2:
	while true; do pgbench -nv -P1 -c16 -T10 postgres://test:test@pg-test:5433/test; done
test-ro2:
	while true; do pgbench -nv -P1 -c64 -T10 --select-only postgres://test:test@pg-test:5434/test; done
test-rh:
	ssh node-1 'sudo -iu postgres /pg/bin/pg-heartbeat'
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
	cd files/grafana/ && ./grafana.py init

dd: dashboard-dump                    # dump grafana dashboards
dashboard-dump:
	cd files/grafana/ && ./grafana.py dump

dc: dashboard-clean                   # cleanup grafana dashboards
dashboard-clean:
	cd files/grafana/ && ./grafana.py clean

du: dashboard-clean dashboard-init    # update grafana dashboards

#------------------------------#
# copy source & packages
#------------------------------#
# copy latest pro source code
copy: copy-src copy-pkg use-src use-pkg
cc: release copy-src copy-pkg use-src use-pkg

# copy pigsty source code
copy-src:
	scp "dist/${VERSION}/${SRC_PKG}" meta:~/pigsty.tgz
copy-pkg:
	scp dist/${VERSION}/${REPO_PKG} meta:/tmp/pkg.tgz
copy-el7:
	scp dist/${VERSION}/${EL7_PKG} meta:/tmp/pkg.tgz
copy-el8:
	scp dist/${VERSION}/${EL8_PKG} meta:/tmp/pkg.tgz
copy-el9:
	scp dist/${VERSION}/${EL9_PKG} meta:/tmp/pkg.tgz
copy-app:
	scp dist/${VERSION}/${APP_PKG} meta:~/app.tgz
	ssh -t meta 'rm -rf ~/app; tar -xf app.tgz; rm -rf app.tgz'
copy-docker:
	scp -r dist/docker meta:/tmp/
load-docker:
	ssh meta 'cat /tmp/docker.tgz | gzip -d -c - | docker load'
copy-all: copy-src copy-pkg

# extract packages
use-src:
	ssh -t meta 'rm -rf ~/pigsty; tar -xf pigsty.tgz; rm -rf pigsty.tgz'
use-pkg:
	ssh meta "sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www"
use-all: use-src use-pkg

# load config into cmdb
cmdb:
	bin/inventory_load
	bin/inventory_cmdb

###############################################################



###############################################################
#                       8. Release                            #
###############################################################
# make pigsty source release
r: release
release:
	bin/release ${VERSION}

rr: release copy-src use-src
	ssh meta "cd pigsty; make release"
	scp meta:~/pigsty/dist/${VERSION}/${SRC_PKG} dist/${VERSION}/${SRC_PKG}

# release-pkg will make cache and copy to dist dir
rp: release-pkg
release-pkg: cache
	scp meta:/tmp/pkg.tgz dist/${VERSION}/${REPO_PKG}

# create pkg.tgz on initialized meta node
cache:
	scp bin/cache meta:/tmp/cache
	ssh meta "sudo bash /tmp/cache"

# release docker packages
release-docker:
	scp meta:/tmp/docker/*.tgz dist/docker/

# publish pigsty packages
p: release publish
publish:
	bin/publish ${VERSION}

build-src:
	scp dist/${VERSION}/${SRC_PKG}   meta:~/pigsty.tgz ; ssh   meta "tar -xf pigsty.tgz";
	scp dist/${VERSION}/${SRC_PKG} node-1:~/pigsty.tgz ; ssh node-1 "tar -xf pigsty.tgz";
	scp dist/${VERSION}/${SRC_PKG} node-2:~/pigsty.tgz ; ssh node-2 "tar -xf pigsty.tgz";

build-repo:
	scp dist/${VERSION}/pigsty-pkg-${VERSION}.el7.x86_64.tgz   meta:/tmp/pkg.tgz ; ssh   meta 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'
	scp dist/${VERSION}/pigsty-pkg-${VERSION}.el8.x86_64.tgz node-1:/tmp/pkg.tgz ; ssh node-1 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'
	scp dist/${VERSION}/pigsty-pkg-${VERSION}.el9.x86_64.tgz node-2:/tmp/pkg.tgz ; ssh node-2 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'

build-boot:
	ssh meta   "cd pigsty; ./bootstrap -n ; ./configure -m el7  -i 10.10.10.10 -n";
	ssh node-1 "cd pigsty; ./bootstrap -n ; ./configure -m el8  -i 10.10.10.11 -n";
	ssh node-2 "cd pigsty; ./bootstrap -n ; ./configure -m el9  -i 10.10.10.12 -n";

build-release: r rr build-el7 build-el8 build-el9
build-el7:
	scp bin/cache   meta:/tmp/cache ; ssh   meta "sudo bash /tmp/cache"; scp   meta:/tmp/pkg.tgz dist/${VERSION}/pigsty-pkg-${VERSION}.el7.x86_64.tgz
build-el8:
	scp bin/cache node-1:/tmp/cache ; ssh node-1 "sudo bash /tmp/cache"; scp node-1:/tmp/pkg.tgz dist/${VERSION}/pigsty-pkg-${VERSION}.el8.x86_64.tgz
build-el9:
	scp bin/cache node-2:/tmp/cache ; ssh node-2 "sudo bash /tmp/cache"; scp node-2:/tmp/pkg.tgz dist/${VERSION}/pigsty-pkg-${VERSION}.el9.x86_64.tgz
buildm-el7:
	scp bin/cache   meta:/tmp/cache ; ssh   meta "sudo bash /tmp/cache"; scp   meta:/tmp/pkg.tgz dist/${VERSION}/pigsty-pkg-${VERSION}.el7.x86_64.tgz
buildm-el8:
	scp bin/cache   meta:/tmp/cache ; ssh   meta "sudo bash /tmp/cache"; scp   meta:/tmp/pkg.tgz dist/${VERSION}/pigsty-pkg-${VERSION}.el8.x86_64.tgz
buildm-el9:
	scp bin/cache   meta:/tmp/cache ; ssh   meta "sudo bash /tmp/cache"; scp   meta:/tmp/pkg.tgz dist/${VERSION}/pigsty-pkg-${VERSION}.el9.x86_64.tgz
###############################################################



###############################################################
#                     9. Environment                          #
###############################################################
meta: v1 new ssh copy-el9 use-pkg
	cp files/pigsty/demo.yml pigsty.yml
full: v4 new ssh copy-el9 use-pkg
	cp files/pigsty/demo.yml pigsty.yml
citus: vc new ssh copy-el9 use-pkg
	cp files/pigsty/citus.yml pigsty.yml
minio: vc new ssh copy-el9 use-pkg
	cp files/pigsty/citus.yml pigsty.yml
build: vb new ssh
	cp files/pigsty/build.yml pigsty.yml
build-test: vb new ssh build-repo build-src
	cp files/pigsty/build.yml pigsty.yml
el7: v7 new ssh copy-el7 use-pkg
	cp files/pigsty/test.yml pigsty.yml
el8: v8 new ssh copy-el8 use-pkg
	cp files/pigsty/test.yml pigsty.yml
el9: v9 new ssh copy-el9 use-pkg
	cp files/pigsty/test.yml pigsty.yml

###############################################################



###############################################################
#                         Appendix                            #
###############################################################
.PHONY: default tip link get all bootstrap config install \
        src pkg \
        c conf \
        infra pgsql repo repo-upstream repo-build prometheus grafana loki docker \
        deps dns start ssh demo \
        up dw del new clean up-test dw-test del-test new-test clean \
        st status suspend resume v1 v4 v7 v8 v9 vb vc vnew \
        ri rc rw ro rh rhc test-ri test-rw test-ro test-rw2 test-ro2 test-rc test-st test-rb1 test-rb2 test-rb3 \
        di dd dc du dashboard-init dashboard-dump dashboard-clean \
        copy copy-src copy-pkg copy-app copy-docker load-docker copy-all use-src use-pkg use-all cmdb \
        r releast rp release-pkg cache release-docker p publish \
        build-vagrant build build-src build-repo build-boot build-release build-el7 build-el8 build-el9 buildm-el7 buildm-el8 buildm-el9 \
        meta full build el7 el8 el9
###############################################################
