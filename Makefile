#==============================================================#
# File      :   Makefile
# Desc      :   pigsty shortcuts
# Ctime     :   2019-04-13
# Mtime     :   2024-08-09
# Path      :   Makefile
# Author    :   Ruohang Feng (rh@vonng.com)
# License   :   AGPLv3
#==============================================================#
# pigsty version string
VERSION?=v3.0.0-b1

# variables
SRC_PKG=pigsty-$(VERSION).tgz
APP_PKG=pigsty-app-$(VERSION).tgz
DOCKER_PKG=pigsty-docker-$(VERSION).tgz
EL7_PKG=pigsty-pkg-$(VERSION).el7.x86_64.tgz
EL8_PKG=pigsty-pkg-$(VERSION).el8.x86_64.tgz
EL9_PKG=pigsty-pkg-$(VERSION).el9.x86_64.tgz
D11_PKG=pigsty-pkg-$(VERSION).d11.x86_64.tgz
D12_PKG=pigsty-pkg-$(VERSION).d12.x86_64.tgz
U20_PKG=pigsty-pkg-$(VERSION).u20.x86_64.tgz
U22_PKG=pigsty-pkg-$(VERSION).u22.x86_64.tgz
USE_PRO=""
USE_PRO="pro/"

###############################################################
#                      1. Quick Start                         #
###############################################################
# run with nopass SUDO user (or root) on CentOS 7.x node
default: tip
tip:
	@echo "# Run on Linux node with nopass sudo & ssh access"
	@echo 'curl -fsSL https://repo.pigsty.io/get | bash'
	@echo "./bootstrap     # prepare local repo & ansible"
	@echo "./configure     # pre-check and templating config"
	@echo "./install.yml   # install pigsty on current node"

# print pkg download links
link:
	@echo 'curl -fsSL https://repo.pigsty.io/get | bash'

# serve a local docs with docsify or python http
doc:
	docs/serve

#-------------------------------------------------------------#
# (1). BOOTSTRAP  pigsty pkg & util preparedness
boot: bootstrap
bootstrap:
	./bootstrap

# (2). CONFIGURE  pigsty in interactive mode
conf: configure
configure:
	./configure

# (3). INSTALL    pigsty on current node
i: install
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
	./install.yml -t node_repo,node_pkg,infra_pkg,pg_pkg

# download repo packages
repo-build: repo-clean
	./infra.yml --tags=repo_upstream,repo_pkg

repo-clean:
	ansible all -b -a 'rm -rf /www/pigsty/repo_complete'

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
#                       5. Vagrant                            #
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
# copy latest source code
copy: copy-src copy-pkg use-src use-pkg
cc: release copy-src copy-pkg use-src use-pkg

# copy pigsty source code
copy-src:
	scp "dist/${VERSION}/${SRC_PKG}" meta:~/pigsty.tgz
copy-el8:
	scp dist/${VERSION}/$(USE_PRO)${EL8_PKG} meta:/tmp/pkg.tgz
copy-el9:
	scp dist/${VERSION}/$(USE_PRO)${EL9_PKG} meta:/tmp/pkg.tgz
copy-d12:
	scp dist/${VERSION}/$(USE_PRO)${D12_PKG} meta:/tmp/pkg.tgz
copy-u22:
	scp dist/${VERSION}/$(USE_PRO)${U22_PKG} meta:/tmp/pkg.tgz
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
# build env shortcuts
#------------------------------#
# copy src to build environment
csa: copy-src-all
copy-src-all:
	scp "dist/${VERSION}/${SRC_PKG}" el8:~/pigsty.tgz
	scp "dist/${VERSION}/${SRC_PKG}" el9:~/pigsty.tgz
	scp "dist/${VERSION}/${SRC_PKG}" d12:~/pigsty.tgz
	scp "dist/${VERSION}/${SRC_PKG}" u22:~/pigsty.tgz
	ssh -t el8 'rm -rf ~/pigsty; tar -xf pigsty.tgz; rm -rf pigsty.tgz'
	ssh -t el9 'rm -rf ~/pigsty; tar -xf pigsty.tgz; rm -rf pigsty.tgz'
	ssh -t d12 'rm -rf ~/pigsty; tar -xf pigsty.tgz; rm -rf pigsty.tgz'
	ssh -t u22 'rm -rf ~/pigsty; tar -xf pigsty.tgz; rm -rf pigsty.tgz'
csr: copy-src-rpm
copy-src-rpm:
	scp "dist/${VERSION}/${SRC_PKG}" el7:~/pigsty.tgz
	scp "dist/${VERSION}/${SRC_PKG}" el8:~/pigsty.tgz
	scp "dist/${VERSION}/${SRC_PKG}" el9:~/pigsty.tgz
	ssh -t el7 'rm -rf ~/pigsty; tar -xf pigsty.tgz; rm -rf pigsty.tgz'
	ssh -t el8 'rm -rf ~/pigsty; tar -xf pigsty.tgz; rm -rf pigsty.tgz'
	ssh -t el9 'rm -rf ~/pigsty; tar -xf pigsty.tgz; rm -rf pigsty.tgz'
	ssh -t el7 'cd ~/pigsty && ./configure -i 10.10.10.7'
	ssh -t el8 'cd ~/pigsty && ./configure -i 10.10.10.8'
	ssh -t el9 'cd ~/pigsty && ./configure -i 10.10.10.9'
csd: copy-src-deb
copy-src-deb:
	scp "dist/${VERSION}/${SRC_PKG}" d11:~/pigsty.tgz
	scp "dist/${VERSION}/${SRC_PKG}" d12:~/pigsty.tgz
	scp "dist/${VERSION}/${SRC_PKG}" u20:~/pigsty.tgz
	scp "dist/${VERSION}/${SRC_PKG}" u22:~/pigsty.tgz
	ssh -t d11 'rm -rf ~/pigsty; tar -xf pigsty.tgz; rm -rf pigsty.tgz'
	ssh -t d12 'rm -rf ~/pigsty; tar -xf pigsty.tgz; rm -rf pigsty.tgz'
	ssh -t u20 'rm -rf ~/pigsty; tar -xf pigsty.tgz; rm -rf pigsty.tgz'
	ssh -t u22 'rm -rf ~/pigsty; tar -xf pigsty.tgz; rm -rf pigsty.tgz'
	ssh -t  d11 'cd ~/pigsty && ./configure -i 10.10.10.11'
	ssh -t  d12 'cd ~/pigsty && ./configure -i 10.10.10.12'
	ssh -t  u20 'cd ~/pigsty && ./configure -i 10.10.10.20'
	ssh -t  u22 'cd ~/pigsty && ./configure -i 10.10.10.22'
dfx: deb-fix
deb-fix:
	scp /etc/resolv.conf u22:/tmp/resolv.conf;
	ssh -t u22 'sudo mv /tmp/resolv.conf /etc/resolv.conf'
	scp /etc/resolv.conf d12:/tmp/resolv.conf;
	ssh -t d12 'sudo mv /tmp/resolv.conf /etc/resolv.conf'

#------------------------------#
# push / pull
#------------------------------#
push:
	rsync -avz ./ sv:~/pigsty/ --delete --exclude-from 'vagrant/Vagrantfile'
pull:
	rsync -avz sv:~/pigsty/ ./ --exclude-from 'vagrant/Vagrantfile' --exclude-from 'vagrant/.vagrant'
ss:
	rsync -avz --exclude=temp --exclude=dist --exclude=vagrant/ --exclude=terraform --delete ./ sv:/data/pigsty/
	ssh sv 'chown -R root:root /data/pigsty/'
gsync:
	rsync -avz --delete .git/ sv:/data/pigsty/.git
	ssh sv 'chown -R root:root /data/pigsty/.git'
grestore:
	git restore pigsty.yml
	git restore vagrant/Vagrantfile
gpush:
	git push origin master
gpull:
	git pull origin master
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
rp: release-pkg
release-pkg:
	bin/release-pkg ${VERSION}
rpp: release-pro
release-pro:
	bin/release-pkg ${VERSION} pro
pb: publish
publish:
	bin/publish ${VERSION}


###############################################################
#                     9. Environment                          #
###############################################################

#------------------------------#
#     Change Configuration     #
#------------------------------#
cmeta:
	cp conf/sandbox/meta.yml pigsty.yml
cdual:
	cp conf/sandbox/dual.yml pigsty.yml
ctrio:
	cp conf/sandbox/trio.yml pigsty.yml
cfull:
	cp conf/sandbox/full.yml pigsty.yml
cprod:
	cp conf/sandbox/prod.yml pigsty.yml
cbuild:
	cp conf/build/oss.yml pigsty.yml
cpro:
	cp conf/build/pro.yml pigsty.yml
cext:
	cp conf/build/ext.yml pigsty.yml
crpm:
	cp conf/build/rpm.yml pigsty.yml
cdeb:
	cp conf/build/deb.yml pigsty.yml

#------------------------------#
#     Building Environment     #
#------------------------------#
build: cbuild del vb new ssh dfx
pro: cpro del va new ssh copy-src-rpm copy-src-deb
build-boot:
	bin/build-boot
rpm: crpm del vr new ssh copy-src-rpm
deb: cdeb del vd new ssh copy-src-deb
old: del va new ssh
vb: # pigsty building environment
	vagrant/config build
vr: # rpm building environment
	vagrant/config rpm
vd: # deb building environment
	vagrant/config deb
va: # all building environment
	vagrant/config all
vo: # old building environment
	vagrant/config old

#------------------------------#
# meta, single node, the devbox
#------------------------------#
# simple 1-node devbox for quick setup, demonstration, and development

meta: meta8
meta7:  cmeta del vmeta7  up ssh copy-el7 use-pkg
meta8:  cmeta del vmeta8  up ssh copy-el8 use-pkg
meta9:  cmeta del vmeta9  up ssh copy-el9 use-pkg
meta11: cmeta del vmeta11 up ssh copy-d11 use-pkg
meta12: cmeta del vmeta12 up ssh copy-d12 use-pkg
meta20: cmeta del vmeta20 up ssh copy-u20 use-pkg
meta22: cmeta del vmeta22 up ssh copy-u22 use-pkg

vm: vmeta
vmeta:
	vagrant/config meta
vmeta7:
	vagrant/config meta el7
vmeta8:
	vagrant/config meta el8
vmeta9:
	vagrant/config meta el9
vmeta12:
	vagrant/config meta debian12
vmeta20:
	vagrant/config meta ubuntu20
vmeta22:
	vagrant/config meta ubuntu22

#------------------------------#
# full, four nodes, the sandbox
#------------------------------#
# full-featured 4-node sandbox for HA-testing & tutorial & practices

full:   full8
full7:  cfull del vfull7  up ssh copy-el7 use-pkg
full8:  cfull del vfull8  up ssh copy-el8 use-pkg
full9:  cfull del vfull9  up ssh copy-el9 use-pkg
full11: cfull del vfull11 up ssh copy-d11 use-pkg
full12: cfull del vfull12 up ssh copy-d12 use-pkg
full20: cfull del vfull20 up ssh copy-u20 use-pkg
full22: cfull del vfull22 up ssh copy-u22 use-pkg

vf: vfull
vfull:
	vagrant/config full
vfull7:
	vagrant/config full el7
vfull8:
	vagrant/config full el8
vfull9:
	vagrant/config full el9
vfull11:
	vagrant/config full debian11
vfull12:
	vagrant/config full debian12
vfull20:
	vagrant/config full ubuntu20
vfull22:
	vagrant/config full ubuntu22

#------------------------------#
# prod, 43 nodes, the simubox
#------------------------------#
# complex 43-node simubox for production simulation & complete testing
prod-conf:
	cp conf/sandbox/prod.yml pigsty.yml
vp: vprod
vprod:
	vagrant/config prod
vprod8:
	vagrant/config prod el8
vprod9:
	vagrant/config prod el9
vprod12:
	vagrant/config prod debian12
vprod22:
	vagrant/config prod ubuntu22

prod: prod8
prod8: cprod del vprod8 new ssh
	scp dist/${VERSION}/$(USE_PRO)pigsty-pkg-${VERSION}.el8.x86_64.tgz meta-1:/tmp/pkg.tgz ; ssh meta-1 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'
	scp dist/${VERSION}/$(USE_PRO)pigsty-pkg-${VERSION}.el8.x86_64.tgz meta-2:/tmp/pkg.tgz ; ssh meta-2 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'
prod9: cprod del vprod9 new ssh
	scp dist/${VERSION}/$(USE_PRO)pigsty-pkg-${VERSION}.el9.x86_64.tgz meta-1:/tmp/pkg.tgz ; ssh meta-1 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'
	scp dist/${VERSION}/$(USE_PRO)pigsty-pkg-${VERSION}.el9.x86_64.tgz meta-2:/tmp/pkg.tgz ; ssh meta-2 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'
prod12: cprod del vprod12 new ssh
	scp dist/${VERSION}/$(USE_PRO)pigsty-pkg-${VERSION}.d12.x86_64.tgz meta-1:/tmp/pkg.tgz ; ssh meta-1 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'
	scp dist/${VERSION}/$(USE_PRO)pigsty-pkg-${VERSION}.d12.x86_64.tgz meta-2:/tmp/pkg.tgz ; ssh meta-2 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'
prod22: cprod del vprod22 new ssh
	scp dist/${VERSION}/$(USE_PRO)pigsty-pkg-${VERSION}.u22.x86_64.tgz meta-1:/tmp/pkg.tgz ; ssh meta-1 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'
	scp dist/${VERSION}/$(USE_PRO)pigsty-pkg-${VERSION}.u22.x86_64.tgz meta-2:/tmp/pkg.tgz ; ssh meta-2 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'

#------------------------------#
# dual & trio
#------------------------------#
dual:   cdual del vdual   up ssh
dual8:  cdual del vdual8  up ssh
dual9:  cdual del vdual9  up ssh
dual12: cdual del vdual12 up ssh
dual22: cdual del vdual22 up ssh

vdual:
	vagrant/config dual
vdual8:
	vagrant/config dual el8
vdual9:
	vagrant/config dual el9
vdual12:
	vagrant/config dual debian12
vdual20:
	vagrant/config dual ubuntu20
vdual22:
	vagrant/config dual ubuntu22

trio:   ctrio del vtrio   up ssh
trio8:  ctrio del vtrio8  up ssh
trio9:  ctrio del vtrio9  up ssh
trio12: ctrio del vtrio12 up ssh
trio22: ctrio del vtrio22 up ssh
vtrio:
	vagrant/config trio
vtrio8:
	vagrant/config trio el8
vtrio9:
	vagrant/config trio el9
vtrio12:
	vagrant/config trio debian12
vtrio22:
	vagrant/config trio ubuntu22

###############################################################



###############################################################
#                        Inventory                            #
###############################################################
.PHONY: default tip link doc all boot conf i bootstrap config install \
        src pkg \
        c \
        infra pgsql repo repo-upstream repo-build repo-clean prometheus grafana loki docker \
        deps dns start ssh \
        up dw del new clean up-test dw-test del-test new-test clean \
        st status suspend resume v1 v4 v7 v8 v9 vb vr vd vm vo vc vu vp vp7 vp9 \
        ri rc rw ro rh rhc test-ri test-rw test-ro test-rw2 test-ro2 test-rc test-st test-rb1 test-rb2 test-rb3 \
        di dd dc du dashboard-init dashboard-dump dashboard-clean \
        copy copy-src copy-pkg copy-el8 copy-el9 copy-u22 copy-app copy-docker load-docker copy-all use-src use-pkg use-all cmdb \
        csa copy-src-all csr copy-src-rpm csd copy-src-deb df deb-fix push pull git-sync git-restore \
        r release rr remote-release rp rpp release-pkg release-pro release-el8 release-el9 pp package pb publish \
        build build-pro build-boot rpm deb vb vr vd vm vf vp all old va vo \
        meta meta7 meta8 meta9 meta11 meta12 meta20 meta22 vmeta vmeta7 vmeta8 vmeta9 vfull11 vmeta12 vmeta20 vmeta22 \
        full full7 full8 full9 full11 full12 full20 full22 vfull vfull7 vfull8 vfull9 vfull11 vfull12 vfull20 vfull22 \
        prod prod8 prod9 prod12 prod20 prod22 vprod vprod8 vprod9 vprod12 vprod20 vprod22 \
        dual dual8 dual9 dual12 dual20 dual22 vdual vdual8 vdual9 vdual12 vdual20 vdual22 \
        trio trio8 trio9 trio12 trio20 trio22 vtrio vtrio8 vtrio9 vtrio12 vtrio20 vtrio22 \
        cmeta cdual ctrio cfull cprod cbuild cpro cext crpm cdeb
###############################################################