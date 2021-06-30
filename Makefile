#==============================================================#
# File      :   Makefile
# Ctime     :   2019-04-13
# Mtime     :   2021-06-29
# Desc      :   Makefile shortcuts
# Path      :   Makefile
# Copyright (C) 2018-2021 Ruohang Feng (rh@vonng.com)
#==============================================================#

# pigsty version
VERSION?=v0.10.0-alpha1

# pigsty cluster (meta by default)
CLS?=meta

# pigsty release (pigsty.tgz)
SRC?=pigsty.tgz

###############################################################
#                      1. Quick Start                         #
###############################################################
# run with nopass SUDO user (or root) on CentOS 7.x node
default: tip
tip:
	@echo '# To install pigsty, run with sudo user on centos 7.x node'
	@echo 'curl -fsSL https://pigsty.cc/${SRC} | gzip -d | tar -xC ~; cd ~/pigsty'
	@echo make config
	@echo make install

#-------------------------------------------------------------#
# there are 3 steps launching pigsty:
all: download configure install

# (1). DOWNLOAD   pigsty source code to ~/pigsty
download:
	curl -fsSL https://pigsty.cc/${SRC} | gzip -d | tar -xC ~ ; cd ~/pigsty

# (2). CONFIGURE  pigsty in interactive mode
config:
	./configure

# (3). INSTALL    pigsty on current node
install:
	./infra.yml -l ${CLS}
###############################################################
# curl -fsSL https://pigsty.cc/pigsty.tgz | gzip -d | tar -xC ~ ; cd ~/pigsty
# curl -fsSL https://pigsty.cc/pigsty-beta.tgz | gzip -d | tar -xC ~ ; cd ~/pigsty
# curl -fsSL https://pigsty.cc/pigsty-pro.tgz | gzip -d | tar -xC ~ ; cd ~/pigsty




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
#    pkg.tgz       :   offline install packages (under 7.8)
#
# Besides, some binaries needs to be downloaded alone (no rpm)
# they can be downloaded via internet or extract from pkg.tgz

#------------------------------#
# -- software -- #
#------------------------------#
# download pkg.tgz to /tmp/pkg.tgz
pkg:
	bin/get_pkg ${VERSION}

# download binaries from internet (to files/bin)
# (if /www/pigsty exists, extract from it)
bin:
	bin/get_bin

#------------------------------#
# source code                  #
#------------------------------#
# official: https://github.com/Vonng/pigsty/releases/download/${VERSION}/pigsty.tgz

# get latest stable version to ~/pigsty
src:
	curl -fsSL https://pigsty.cc/pigsty.tgz | gzip -d | tar -xC ~ ; cd ~/pigsty
###############################################################








###############################################################
#                      3. Configure                           #
###############################################################
# there are several things needs to be configured before install
# use ./configure or `make c` to run interactive config wizard

# common interactive configuration procedure
c: configure

# config with parameters
# IP=10.10.10.10 MODE=oltp make conf
conf:
	./configure --ip ${IP} --mode ${MODE} --download

###############################################################










###############################################################
#                      4. Install                             #
###############################################################
# installation are executed via ansible-playbook
# it's CRUCIAL to LIMIT execution hosts! (THINK BEFORE YOU TYPE!)

# install pigsty on meta nodes
infra:
	./infra.yml -l ${CLS}

# create new pgsql cluster  (e.g:  CLS=pg-test make pgsql)
pgsql:
	./pgsql.yml -l ${CLS}

#------------------------------#
# add-on installation
#------------------------------#
# install additional logging components
logging: loki pgsql-promtail

# upgrade to pg-meta dynamic inventory
upgrade:
	bin/upgrade

#==============================================================#
#                      Infra Sub Tasks                         #
#==============================================================#
# shortcuts for managing pigsty meta (admin) node

#------------------------------#
# repo
#------------------------------#
# init local yum repo
repo:
	./infra.yml -l ${CLS} --tags=repo

# re-install upstream yum repo
repo-upstream:
	./infra.yml -l ${CLS} --tags=repo_upstream

# repo-download will re-download missing packages
repo-download:
	rm -rf /www/pigsty/repo_complete
	./infra.yml -l ${CLS} --tags=repo_download

#------------------------------#
# nginx
#------------------------------#
# update haproxy admin proxy
haproxy:
	./infra.yml -l ${CLS} --tags=nginx_haproxy,nginx_restart

#------------------------------#
# prometheus
#------------------------------#
# init prometheus
prometheus:
	./infra.yml -l ${CLS} --tags=prometheus

# refresh monitoring targets
refresh:
	./infra.yml -l ${CLS} --tags=prometheus_targets,prometheus_reload

#------------------------------#
# grafana
#------------------------------#
# init grafana
grafana:
	./infra.yml -l ${CLS} --tags=grafana

# init loki (additional logging service)
loki:
	./infra-loki.yml -l ${CLS}



#==============================================================#
#                      PGSQL Sub Tasks                         #
#==============================================================#
# shortcuts for manage pgsql clusters

#------------------------------#
# construction
#------------------------------#
# init database cluster  (force-clean)
pgsql-init:
	./infra.yml -l ${CLS} --tags=pgsql -e pg_exists_action=clean

# init node
pgsql-node:
	./pgsql.yml -l ${CLS} --tags=node

# init dcs service
pgsql-dcs:
	./pgsql.yml -l ${CLS} --tags=dcs -e dcs_exists_action=clean

# init postgres
pgsql-postgres:
	./pgsql.yml -l ${CLS} --tags=postgres

# init pgbouncer
pgsql-pgbouncer:
	./pgsql.yml -l ${CLS} --tags=pgbouncer

# init business (user & database)
pgsql-business:
	./pgsql.yml -l ${CLS} --tags=pg_user,pg_db

# init monitor
pgsql-monitor:
	./pgsql.yml -l ${CLS} --tags=monitor

# init service
pgsql-service:
	./pgsql.yml -l ${CLS} --tags=service

# install promtail (logging agent)
pgsql-promtail:
	./pgsql-promtail.yml -l ${CLS} --tags=service


#------------------------------#
# destruction
#------------------------------#
# remove pgsql node
node-remove:
	./node-remove.yml -l ${CLS}

# remove dcs service
dcs-remove:
	./node-remove.yml -l ${CLS} --tags=dcs

# remove postgres service
pgsql-remove:
	./pgsql-remove.yml -l ${CLS}

#------------------------------#
# management
#------------------------------#
# create (or update) biz user on pg-meta
# usage: CLS=pg-meta USER=dbuser_pigsty make pg-user
pg-user:
	./pgsql-createuser.yml -l ${CLS} -e pg_user=${USER}

# create (or update) biz db on pg-meta
# (define in pg-meta.vars.pg_databases with name designated via env DB)
# usage: CLS=pg-meta DB=meta make pg-db
pg-db:
	./pgsql-createdb.yml  -l ${CLS}  -e pg_database=${DB} -l pg-meta

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
# demo
#------------------------------#
# tips: (make fetch & make upload will accelerate next vm bootstrap)

# ssh meta and run standard install procedure same as Quick-Start
demo:
	ssh meta "curl -fsSL https://pigsty.cc/pigsty.tgz | gzip -d | tar -xC ~"
	ssh meta '/home/vagrant/pigsty/configure --ip 10.10.10.10 -m demo --non-interactive --download'
	ssh meta 'cd ~/pigsty; make install'

# 4-node version
demo4:
	ssh meta "curl -fsSL https://pigsty.cc/pigsty.tgz | gzip -d | tar -xC ~"
	ssh meta '/home/vagrant/pigsty/configure --ip 10.10.10.10 -m demo4 --non-interactive --download'
	ssh meta 'cd ~/pigsty; make install'
	ssh meta 'cd ~/pigsty; ./pgsql.yml -l pg-test'


#==============================================================#
#                       VM Management                          #
#==============================================================#

#------------------------------#
# single node (meta)
#------------------------------#
up:
	cd vagrant && vagrant up meta
dw:
	cd vagrant && vagrant halt meta
del:
	cd vagrant && vagrant destroy -f meta
new: del up
s:sync
sync:  # sync time
	ssh meta 'sudo ntpdate -u pool.ntp.org'; true

#------------------------------#
# pg-test nodes (node-{1,2,3})
#------------------------------#
up-test:
	cd vagrant && vagrant up node-1 node-2 node-3
dw-test:
	cd vagrant && vagrant halt node-1 node-2 node-3
del-test:
	cd vagrant && vagrant destroy -f node-1 node-2 node-3
new-test: del-test up-test
s-test: sync-test
sync-test:  # sync time
	echo node-1 node-2 node-3 | xargs -n1 -P4 -I{} ssh {} 'sudo ntpdate -u pool.ntp.org'; true

#------------------------------#
# all nodes (4)
#------------------------------#
up4:
	cd vagrant && vagrant up
dw4:
	cd vagrant && vagrant halt
del4:
	cd vagrant && vagrant destroy -f
new4: del4 up4
s4: sync4
sync4:  # sync time
	echo meta node-1 node-2 node-3 | xargs -n1 -P4 -I{} ssh {} 'sudo ntpdate -u pool.ntp.org'; true

#------------------------------#
# misc vm shortcuts
#------------------------------#
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









###############################################################
#                       7. Develop                            #
###############################################################

#------------------------------#
# datalets
#------------------------------#
datalets:
	cd ~ && git clone https://github.com/Vonng/datalets

#------------------------------#
# resource
#------------------------------#
# fetch pigsty resources from internet to your own host
# (to dist/*.*/{pkg,pigsty}.tgz)
fetch: pkg
	mkdir dist/${VERSION}/
	cp -f /tmp/pkg.tgz "dist/${VERSION}/pkg.tgz"
	curl -fsSL https://pigsty.cc/pigsty.tgz -o "dist/latest/pigsty.tgz"

# upload pigsty resource from your own host to vm
upload:
	scp "dist/${VERSION}/pigsty.tgz" meta:/home/vagrant/pigsty.tgz
	ssh -t meta 'rm -rf ~/pigsty; tar -xf pigsty.tgz; rm -rf pigsty.tgz'
	scp "dist/${VERSION}/pkg.tgz" meta:/tmp/pkg.tgz

ul: upload-latest
upload-latest: release-latest
	scp "dist/latest/pigsty.tgz" meta:/home/vagrant/pigsty.tgz
	ssh -t meta 'rm -rf ~/pigsty; tar -xf pigsty.tgz; rm -rf pigsty.tgz'
	scp "dist/latest/pkg.tgz" meta:/tmp/pkg.tgz

#------------------------------#
# copy
#------------------------------#
# copy latest pro source code
copy: release copy-pro

# copy pigsty.tgz and pkg.tgz to sandbox meta node
copy-all: copy-src copy-pkg

# copy pigsty source code
copy-src:
	scp "dist/${VERSION}/pigsty.tgz" meta:~/pigsty.tgz
	ssh -t meta 'rm -rf ~/pigsty; tar -xf pigsty.tgz; rm -rf pigsty.tgz'

# copy pkg.tgz to vm node
copy-pkg:
	scp dist/${VERSION}/pkg.tgz meta:/tmp/pkg.tgz

# copy and test configure
copy-cf:
	scp configure meta:~/pigsty/configure
	ssh meta "bash /home/vagrant/pigsty/configure -i 10.10.10.10"

# debug grafana-echarts plugins
copy-gf:
	ssh meta "sudo rm -rf /var/lib/grafana/plugins/grafana-echarts/dist /tmp/dist"
	scp -r ~/dev/grafana-echarts/dist meta:/tmp/dist
	ssh meta "sudo mv /tmp/dist /var/lib/grafana/plugins/grafana-echarts/dist"
	ssh meta "sudo systemctl restart grafana-server"

###############################################################








###############################################################
#                       8. Release                            #
###############################################################
# make latest release
r: release-latest
release-latest:
	bin/release latest

# release source code tarball
release:
	bin/release ${VERSION}

# release-pkg will make cache and copy to dist dir
rp: release-pkg
release-pkg: cache
	scp meta:/tmp/pkg.tgz dist/${VERSION}/pkg.tgz

# publish will publish pigsty to pigsty.cc
p: release publish
publish:
	bin/publish ${VERSION}

# publish-beta will publish pigsty-beta.tgz to pigsty.cc
pb: release publish-beta
publish-beta:
	bin/publish ${VERSION} beta

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

# (re)install application pgsql
app-pgsql:
	./infra-app.yml -e app=pgsql

# (re)install application cmdb
app-cmdb:
	./infra-app.yml -e app=cmdb

###############################################################






###############################################################
#                         Appendix                            #
###############################################################
.PHONY: default tip all download config install \
        pkg bin src beta pro ver \
        c conf demo demo4 \
        infra pgsql logging upgrade \
        repo repo-upstream repo haproxy prometheus refresh grafana loki \
        pgsql-init pgsql-node pgsql-dcs pgsql-postgres pgsql-pgbouncer \
        pgsql-business pgsql-monitor pgsql-service pgsql-promtail \
        node-remove dcs-remove pgsql-remove \
        pg-user pg-db \
        deps dns start start4 ssh \
        up dw del new s up-test dw-test del-test new-test s-test sync sync-test sync4\
        up4 dw4 del4 new4 s4 \
        st status suspend resume \
        rl ri rw ro rw2 ro2 r1 r2 r3 \
        fetch upload copy copy-all copy-src copy-pro copy-pkg copy-ui copy-fui copy-cf \
        r release rp release-pkg p publish pb publish-beta \
        svg app-pgsql app-cmdb

###############################################################
