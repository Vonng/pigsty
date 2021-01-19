#==============================================================#
# File      :   Makefile
# Ctime     :   2019-04-13
# Mtime     :   2020-09-17
# Desc      :   Makefile shortcuts
# Path      :   Makefile
# Copyright (C) 2018-2021 Ruohang Feng
#==============================================================#
default: start


###############################################################
# Public objective
###############################################################
# create a new cluster
new: clean start upload init

# write dns record to your own host, sudo required
dns:
	if ! grep --quiet "pigsty dns records" /etc/hosts ; then cat files/dns >> /etc/hosts; fi

# write pigsty ssh config to ~/.ssh/pigsty_config
ssh:
	cd vagrant && vagrant ssh-config > ~/.ssh/pigsty_config 2>/dev/null; true
	if ! grep --quiet "pigsty_config" ~/.ssh/config ; then (echo 'Include ~/.ssh/pigsty_config' && cat ~/.ssh/config) >  ~/.ssh/config.tmp; mv ~/.ssh/config.tmp ~/.ssh/config && chmod 0600 ~/.ssh/config; fi
	if ! grep --quiet "StrictHostKeyChecking=no" ~/.ssh/config ; then (echo 'StrictHostKeyChecking=no' && cat ~/.ssh/config) >  ~/.ssh/config.tmp; mv ~/.ssh/config.tmp ~/.ssh/config && chmod 0600 ~/.ssh/config; fi

# upload rpm cache to meta controller
upload:
	ssh -t meta "sudo rm -rf /tmp/pkg.tgz"
	scp -r files/pkg.tgz meta:/tmp/pkg.tgz
	ssh -t meta "sudo mkdir -p /www/pigsty/; sudo rm -rf /www/pigsty/*; sudo tar -xf /tmp/pkg.tgz --strip-component=1 -C /www/pigsty/"

# cache rpm packages from meta controller
cache:
	rm -rf pkg/* && mkdir -p pkg;
	ssh -t meta "sudo tar -zcf /tmp/pkg.tgz -C /www pigsty; sudo chmod a+r /tmp/pkg.tgz"
	scp -r meta:/tmp/pkg.tgz files/pkg.tgz
	ssh -t meta "sudo rm -rf /tmp/pkg.tgz"

# fast provisioning on sandbox
init:
	./sandbox.yml                       # interleave sandbox provisioning

# provisioning on production
init2:
	./meta.yml                          # provision meta node infrastructure
	./pgsql.yml -l pg-meta,pg-test		# provision pg-test and pg-meta

# recreate database cluster
reinit:
	./pgsql.yml --tags=pgsql,proxy -e pg_exists_action=clean

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
	echo meta node-1 node-2 node-3 | xargs -n1 -P4 -I{} ssh {} 'sudo ntpdate pool.ntp.org'; true
	# echo meta node-1 node-2 node-3 | xargs -n1 -P4 -I{} ssh {} 'sudo chronyc -a makestep'; true
# show vagrant cluster status
st: status
start: up ssh sync
stop: halt

# only init partial of cluster
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
# monitoring management
###############################################################
mon-view:
	open -n 'http://g.pigsty/'

mon-clean:
	rm -rf roles/grafana/files/grafana/grafana.db roles/grafana/files/grafana/dashboards

mon-full: mon-clean
	cp files/monitor/grafana-full.db roles/grafana/files/grafana/grafana.db

mon-skim: mon-clean
	cp files/monitor/grafana-skim.db roles/grafana/files/grafana/grafana.db

mon-dump:
	ssh meta "sudo cp /var/lib/grafana/grafana.db /tmp/grafana.db; sudo chmod a+r /tmp/grafana.db"
	scp meta:/tmp/grafana.db files/monitor/grafana-full.db
	ssh meta "sudo rm -rf /tmp/grafana.db"

mon-upload:
	scp files/monitor/grafana-full.db meta:/tmp/grafana.db
	ssh meta "sudo mv /tmp/grafana.db /var/lib/grafana/grafana.db;sudo chown grafana /var/lib/grafana/grafana.db"
	ssh meta "sudo rm -rf /etc/grafana/provisioning/dashboards/* ;sudo systemctl restart grafana-server"

mon-dump-skim:
	ssh meta "sudo cp /var/lib/grafana/grafana.db /tmp/grafana.db; sudo chmod a+r /tmp/grafana.db"
	scp meta:/tmp/grafana.db files/monitor/grafana-skim.db
	ssh meta "sudo rm -rf /tmp/grafana.db"

mon-upload-skim:
	scp files/monitor/grafana-skim.db meta:/tmp/grafana.db
	ssh meta "sudo mv /tmp/grafana.db /var/lib/grafana/grafana.db;sudo chown grafana /var/lib/grafana/grafana.db"
	ssh meta "sudo rm -rf /etc/grafana/provisioning/dashboards/* ;sudo systemctl restart grafana-server"


###############################################################
# dashboards management
###############################################################
dashboard-dump:
	./dashboard.yml -e action=dump

dashboard-clean:
	./dashboard.yml -e action=clean

dashboard-rm-skim:
	./dashboard.yml -e action=clean -e skim=true

dashboard-install:
	./dashboard.yml -e action=install

dashboard-install-skim:
	./dashboard.yml -e action=install -e skim=true

###############################################################
# environment management
###############################################################
env: env-dev

env-clean:
	rm -rf conf/all.yml

env-dev: env-clean
	ln -s dev.yml conf/all.yml

env-vps: env-clean
	ln -s vps.yml conf/all.yml

env-vm: env-clean
	ln -s vm.yml conf/all.yml

env-pre: env-clean
	ln -s pre.yml conf/all.yml

env-prod: env-clean
	ln -s prod.yml conf/all.yml


###############################################################
# kubernetes management (Obsolete)
###############################################################
# open kubernetes dashboard
k8s:
	./init-k8s.yml

kd:
	open -n 'http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/'

k-conf:
	ssh meta 'sudo cat /etc/kubernetes/admin.conf' > ~/.kube/config

# copy kubernetes admin token to files/admin.token
k-token:
	# ssh meta 'kubectl get secret $(kubectl get sa dashboard-admin-sa -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode' | pbcopy
	ssh meta 'kubectl get secret $(kubectl get sa dashboard-admin-sa -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode' > files/admin.token

.PHONY: default ssh dns cache init node meta infra clean up halt status suspend resume start stop down new
