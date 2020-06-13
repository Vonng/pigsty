default: start


###############################################################
# Public objective
###############################################################
# create a new cluster
new: clean start init

# write dns record to your own host, sudo required
dns:
	if ! grep --quiet "pigsty dns records" /etc/hosts ; then cat files/pigsty_dns >> /etc/hosts; fi

# copy yum packages to your own host, pigsty/pkg
cache:
	rm -rf pkg/* && mkdir -p pkg && scp -r meta:/www/pigsty/* pkg/

# init will pull up entire cluster
init:
	./pg-meta.yml
	./pg-test.yml

# down will halt all vm (not destroy)
down: halt

# show vagrant cluster status
st: status


###############################################################
# vm management
###############################################################
clean:
	cd vagrant && vagrant destroy -f --parallel; exit 0
up:
	cd vagrant && vagrant up
halt:
	cd vagrant && vagrant halt
status:
	cd vagrant && vagrant status
suspend:
	cd vagrant && vagrant suspend
resume:
	cd vagrant && vagrant resume
provision:
	cd vagrant && vagrant provision
# sync ntp time (only works after ntp been installed during init-node)
sync:
	echo meta node-1 node-2 node-3 | xargs -n1 -P4 -I{} ssh {} 'sudo chronyc -a makestep'; true
# append pigsty ssh config to ~/.ssh
ssh:
	cd vagrant && vagrant ssh-config > ~/.ssh/pigsty_config 2>/dev/null; true
	if ! grep --quiet "pigsty_config" ~/.ssh/config ; then (echo 'Include ~/.ssh/pigsty_config' && cat ~/.ssh/config) >  ~/.ssh/config.tmp; mv ~/.ssh/config.tmp ~/.ssh/config && chmod 0600 ~/.ssh/config; fi
	if ! grep --quiet "StrictHostKeyChecking=no" ~/.ssh/config ; then (echo 'StrictHostKeyChecking=no' && cat ~/.ssh/config) >  ~/.ssh/config.tmp; mv ~/.ssh/config.tmp ~/.ssh/config && chmod 0600 ~/.ssh/config; fi

start: up ssh sync
stop: halt


###############################################################
# pgbench
###############################################################
bench-init:
	pgbench -is10 postgres://test:test@pg-test:5555/test
rw:
	while true; do pgbench -nv -P1 -c2 -T10 postgres://test:test@pg-test:5555/test; done
ro:
	while true; do pgbench -nv -P1 -c8 -T10 --select-only postgres://test:test@pg-test:5556/test; done


###############################################################
# grafna management
###############################################################
view:
	open -n 'http://grafana.pigsty/d/pg-cluster/pg-cluster?refresh=5s&var-cls=pg-test'

ha:
	open -n 'http://pg-test:9101/haproxy'

dump-monitor:
	ssh meta "sudo cp /var/lib/grafana/grafana.db /tmp/grafana.db; sudo chmod a+r /tmp/grafana.db"
	scp meta:/tmp/grafana.db ansible/roles/meta_grafana/files/grafana.db
	ssh meta "sudo rm -rf /tmp/grafana.db"

restore-monitor:
	scp ansible/roles/meta/files/grafana/grafana.db meta:/tmp/grafana.db
	ssh meta "sudo mv /tmp/grafana.db /var/lib/grafana/grafana.db;sudo chown grafana /var/lib/grafana/grafana.db"
	ssh meta "sudo rm -rf /etc/grafana/provisioning/dashboards/* ;sudo systemctl restart grafana-server"

kd:
	open -n 'http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/'

.PHONY: default ssh dns cache init node meta infra clean up halt status suspend resume start stop down new
