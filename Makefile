#==============================================================#
# File      :   Makefile
# Desc      :   pigsty shortcuts
# Ctime     :   2019-04-13
# Mtime     :   2024-05-17
# Path      :   Makefile
# Author    :   Ruohang Feng (rh@vonng.com)
# License   :   AGPLv3
#==============================================================#
# pigsty version string
VERSION?=v2.7.0

# variables
SRC_PKG=pigsty-$(VERSION).tgz
APP_PKG=pigsty-app-$(VERSION).tgz
DOCKER_PKG=pigsty-docker-$(VERSION).tgz
EL7_PKG=pigsty-pkg-$(VERSION).el7.x86_64.tgz
EL8_PKG=pigsty-pkg-$(VERSION).el8.x86_64.tgz
EL9_PKG=pigsty-pkg-$(VERSION).el9.x86_64.tgz
D11_PKG=pigsty-pkg-$(VERSION).debian11.x86_64.tgz
D12_PKG=pigsty-pkg-$(VERSION).debian12.x86_64.tgz
U20_PKG=pigsty-pkg-$(VERSION).ubuntu20.x86_64.tgz
U22_PKG=pigsty-pkg-$(VERSION).ubuntu22.x86_64.tgz


###############################################################
#                      1. Quick Start                         #
###############################################################
# run with nopass SUDO user (or root) on CentOS 7.x node
default: tip
tip:
	@echo "# Run on Linux node with nopass sudo & ssh access"
	@echo 'bash -c "$$(curl -fsSL https://get.pigsty.cc/install)"'
	@echo "./bootstrap     # prepare local repo & ansible"
	@echo "./configure     # pre-check and templating config"
	@echo "./install.yml   # install pigsty on current node"

# print pkg download links
link:
	@echo 'bash -c "$$(curl -fsSL https://get.pigsty.cc/install)"'
	@echo "[Github Download]"
	@echo "curl -SL https://github.com/Vonng/pigsty/releases/download/${VERSION}/${SRC_PKG} | gzip -d | tar -xC ~ ; cd ~/pigsty"
	@echo "[CDN Download]"
	@echo "curl -SL https://get.pigsty.cc/${VERSION}/${SRC_PKG} | gzip -d | tar -xC ~ ; cd ~/pigsty"


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
###############################################################



###############################################################
#                      3. Configure                           #
###############################################################
# there are several things needs to be checked before install
# use ./configure or `make config` to run interactive wizard
# it will install ansible (from offline rpm repo if available)

# common interactive configuration procedure
c: config
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

repo-check:
	./install.yml -t node_repo,node_pkg,infra_pkg,pg_install

# download repo packages
repo-build:
	ansible infra -b -a 'rm -rf /www/pigsty/repo_complete'
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
	sudo vagrant/dns

#------------------------------#
# 3. start
#------------------------------#
# start will pull-up node and write ssh-config
# it may take a while to download centos/7 box for the first time
start: up ssh      # 1-node version
ssh:               # add current ssh config to your ~/.ssh/pigsty_config
	vagrant/ssh
sshb:              # add build ssh config to your ~/.ssh/build_config
	vagrant/ssh build

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
nuke:
	cd vagrant && ./nuke
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
	cd vagrant && make v1
v4:
	cd vagrant && make v4
v7:
	cd vagrant && make v7
v8:
	cd vagrant && make v8
v9:
	cd vagrant && make v9
vb:
	cd vagrant && make vb
vr:
	cd vagrant && make vr
vd:
	cd vagrant && make vd
vc:
	cd vagrant && make vc
vm:
	cd vagrant && make vm
vo:
	cd vagrant && make vo
vu:
	cd vagrant && make vu
vp: vp8  # use rocky 8 as default
vp7:
	cd vagrant && make vp7
vp8:
	cd vagrant && make vp8
vp9:
	cd vagrant && make vp9
vp11:
	cd vagrant && make vp11
vp12:
	cd vagrant && make vp12
vp20:
	cd vagrant && make vp20
vp22:
	cd vagrant && make vp22
vnew: new ssh

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
	while true; do pgbench -nv -P1 -c8 --rate=256 -S -T10 postgres://dbuser_meta:DBUser.Meta@meta:5434/meta; done
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
	while true; do pgbench -nv -P1 -c8 -S --rate=256 -T10 postgres://test:test@pg-test:5434/test; done
# pgbench read-write / read-only traffic (maximum speed)
test-rw2:
	while true; do pgbench -nv -P1 -c16 -T10 postgres://test:test@pg-test:5433/test; done
test-ro2:
	while true; do pgbench -nv -P1 -c64 -T10 -S postgres://test:test@pg-test:5434/test; done
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
copy-el7:
	scp dist/${VERSION}/${EL7_PKG} meta:/tmp/pkg.tgz
copy-el8:
	scp dist/${VERSION}/${EL8_PKG} meta:/tmp/pkg.tgz
copy-el9:
	scp dist/${VERSION}/${EL9_PKG} meta:/tmp/pkg.tgz
copy-d11:
	scp dist/${VERSION}/${D11_PKG} meta:/tmp/pkg.tgz
copy-d12:
	scp dist/${VERSION}/${D12_PKG} meta:/tmp/pkg.tgz
copy-u20:
	scp dist/${VERSION}/${U20_PKG} meta:/tmp/pkg.tgz
copy-u22:
	scp dist/${VERSION}/${U22_PKG} meta:/tmp/pkg.tgz
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

#------------------------------#
# push / pull
#------------------------------#
push:
	rsync -avz ./ sv:~/pigsty/ --delete --exclude-from 'vagrant/Vagrantfile'
pull:
	rsync -avz sv:~/pigsty/ ./ --exclude-from 'vagrant/Vagrantfile' --exclude-from 'vagrant/.vagrant'

###############################################################



###############################################################
#                       8. Release                            #
###############################################################
# make pigsty release (source code tarball)
r: release
release:
	bin/release ${VERSION}

rr: remote-release
remote-release: release copy-src use-src
	ssh meta "cd pigsty; make release"
	scp meta:~/pigsty/dist/${VERSION}/${SRC_PKG} dist/${VERSION}/${SRC_PKG}

# release offline packages with build environment
rp: release-package
release-package:
	bin/release-pkg ${VERSION}
release-oss:
	bin/release-oss ${VERSION}
# publish pigsty packages to https://get.pigsty.cc
pb: publish
publish:
	bin/publish ${VERSION}


###############################################################
#                     9. Environment                          #
###############################################################
# validate offline packages with build environment
check-all: check-src check-repo check-boot
check-src:
	scp dist/${VERSION}/${SRC_PKG} build-el7:~/pigsty.tgz ; ssh build-el7 "tar -xf pigsty.tgz";
	scp dist/${VERSION}/${SRC_PKG} build-el8:~/pigsty.tgz ; ssh build-el8 "tar -xf pigsty.tgz";
	scp dist/${VERSION}/${SRC_PKG} build-el9:~/pigsty.tgz ; ssh build-el9 "tar -xf pigsty.tgz";
	scp dist/${VERSION}/${SRC_PKG} debian12:~/pigsty.tgz ; ssh debian12  "tar -xf pigsty.tgz";
	scp dist/${VERSION}/${SRC_PKG} ubuntu22:~/pigsty.tgz ; ssh ubuntu22  "tar -xf pigsty.tgz";
check-repo:
	scp dist/${VERSION}/pigsty-pkg-${VERSION}.el7.x86_64.tgz build-el7:/tmp/pkg.tgz ; ssh build-el7 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'
	scp dist/${VERSION}/pigsty-pkg-${VERSION}.el8.x86_64.tgz build-el8:/tmp/pkg.tgz ; ssh build-el8 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'
	scp dist/${VERSION}/pigsty-pkg-${VERSION}.el9.x86_64.tgz build-el9:/tmp/pkg.tgz ; ssh build-el9 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'
	scp dist/${VERSION}/pigsty-pkg-${VERSION}.debian12.x86_64.tgz debian12:/tmp/pkg.tgz ; ssh debian12 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'
	scp dist/${VERSION}/pigsty-pkg-${VERSION}.ubuntu22.x86_64.tgz ubuntu22:/tmp/pkg.tgz ; ssh ubuntu22 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'
check-boot:
	ssh build-el7 "cd pigsty; ./bootstrap -n ; ./configure -m el7  -i 10.10.10.7 -n";
	ssh build-el8 "cd pigsty; ./bootstrap -n ; ./configure -m el   -i 10.10.10.8 -n";
	ssh build-el9 "cd pigsty; ./bootstrap -n ; ./configure -m el   -i 10.10.10.9 -n";
	ssh debian12 "cd pigsty; ./bootstrap -n ; ./configure -m el   -i 10.10.10.12 -n";
	ssh ubuntu22 "cd pigsty; ./bootstrap -n ; ./configure -m el   -i 10.10.10.22 -n";

meta: del v1 new ssh copy-el8 use-pkg
	cp files/pigsty/demo.yml pigsty.yml
full: del v4 new ssh copy-el8 use-pkg
	cp files/pigsty/demo.yml pigsty.yml
el7: del v7 new ssh copy-el7 use-pkg
	cp files/pigsty/test.yml pigsty.yml
el8: del v8 new ssh copy-el8 use-pkg
	cp files/pigsty/test.yml pigsty.yml
el9: del v9 new ssh copy-el9 use-pkg
	cp files/pigsty/test.yml pigsty.yml
minio: del vm new ssh copy-el8 use-pkg
	cp files/pigsty/citus.yml pigsty.yml
oss: del vo new ssh
	cp files/pigsty/oss.yml pigsty.yml
ubuntu: del vu new ssh copy-u22 use-pkg
	cp files/pigsty/ubuntu.yml pigsty.yml
build: del vb new ssh
	cp files/pigsty/build.yml pigsty.yml
rpm: del vr new ssh
	cp files/pigsty/rpm.yml pigsty.yml
deb: del vd new ssh
	cp files/pigsty/deb.yml pigsty.yml
build-boot:
	bin/build-boot
check: del vc new ssh
	cp files/pigsty/check.yml pigsty.yml
checkb: del vc new ssh check-all
	cp files/pigsty/check.yml pigsty.yml
prod7: del vp7 new ssh
	cp files/pigsty/prod.yml pigsty.yml
	scp dist/${VERSION}/pigsty-pkg-${VERSION}.el7.x86_64.tgz meta-1:/tmp/pkg.tgz ; ssh meta-1 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'
	scp dist/${VERSION}/pigsty-pkg-${VERSION}.el7.x86_64.tgz meta-2:/tmp/pkg.tgz ; ssh meta-2 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'
prod8: del vp8 new ssh
	cp files/pigsty/prod.yml pigsty.yml
	scp dist/${VERSION}/pigsty-pkg-${VERSION}.el8.x86_64.tgz meta-1:/tmp/pkg.tgz ; ssh meta-1 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'
	scp dist/${VERSION}/pigsty-pkg-${VERSION}.el8.x86_64.tgz meta-2:/tmp/pkg.tgz ; ssh meta-2 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'
prod9: del vp9 new ssh
	cp files/pigsty/prod.yml pigsty.yml
	scp dist/${VERSION}/pigsty-pkg-${VERSION}.el9.x86_64.tgz meta-1:/tmp/pkg.tgz ; ssh meta-1 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'
	scp dist/${VERSION}/pigsty-pkg-${VERSION}.el9.x86_64.tgz meta-2:/tmp/pkg.tgz ; ssh meta-2 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'
prod12: del vp12 new ssh
	cp files/pigsty/prod-deb.yml pigsty.yml
	scp dist/${VERSION}/pigsty-pkg-${VERSION}.debian12.x86_64.tgz meta-1:/tmp/pkg.tgz ; ssh meta-1 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'
	scp dist/${VERSION}/pigsty-pkg-${VERSION}.debian12.x86_64.tgz meta-2:/tmp/pkg.tgz ; ssh meta-2 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'
prod22: del vp22 new ssh
	cp files/pigsty/prod-deb.yml pigsty.yml
	scp dist/${VERSION}/pigsty-pkg-${VERSION}.ubuntu22.x86_64.tgz meta-1:/tmp/pkg.tgz ; ssh meta-1 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'
	scp dist/${VERSION}/pigsty-pkg-${VERSION}.ubuntu22.x86_64.tgz meta-2:/tmp/pkg.tgz ; ssh meta-2 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'

###############################################################



###############################################################
#                        Inventory                            #
###############################################################
.PHONY: default tip link doc all bootstrap config install \
        src pkg \
        c \
        infra pgsql repo repo-upstream repo-build prometheus grafana loki docker \
        deps dns start ssh sshb demo \
        up dw del new clean up-test dw-test del-test new-test clean \
        st status suspend resume v1 v4 v7 v8 v9 vb vr vd vm vo vc vu vp vp7 vp9 vnew \
        ri rc rw ro rh rhc test-ri test-rw test-ro test-rw2 test-ro2 test-rc test-st test-rb1 test-rb2 test-rb3 \
        di dd dc du dashboard-init dashboard-dump dashboard-clean \
        copy copy-src copy-pkg copy-el7 copy-el8 copy-el9 copy-u22 copy-app copy-docker load-docker copy-all use-src use-pkg use-all cmdb \
        r release rr remote-release rp release-pkg release-oss release-el7 release-el8 release-el9 check-all check-src check-repo check-boot pp package pb publish \
        meta full el7 el8 el9 check minio oss ubuntu prod7 prod8 prod9 prod12 prod22 build rpm deb
###############################################################