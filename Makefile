default: start


###############################################################
# Public objective
###############################################################
# create a new cluster
new: clean start init

# write dns record to your own host, sudo required
dns:
	if ! grep --quiet "pigsty dns records" /etc/hosts ; then cat ansible/files/dnsmasq/hosts >> /etc/hosts; fi

# copy yum packages to your own host, pigsty/pkg
cache:
	rm -rf pkg/* && mkdir -p pkg && scp -r meta:/www/pigsty/* pkg/

# init will pull up entire cluster
init:
	cd ansible && ./infra.yml
	cd ansible && ./pg-meta.yml
	cd ansible && ./pg-test.yml

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
	echo node0 node1 node2 node3 | xargs -n1 -P4 -I{} ssh {} 'sudo chronyc -a makestep'; true
# append pigsty ssh config to ~/.ssh
ssh:
	cd vagrant && vagrant ssh-config > ~/.ssh/pigsty_config 2>/dev/null; true
	if ! grep --quiet "pigsty_config" ~/.ssh/config ; then (echo 'Include ~/.ssh/pigsty_config' && cat ~/.ssh/config) >  ~/.ssh/config.tmp; mv ~/.ssh/config.tmp ~/.ssh/config && chmod 0600 ~/.ssh/config; fi
	if ! grep --quiet "StrictHostKeyChecking=no" ~/.ssh/config ; then (echo 'StrictHostKeyChecking=no' && cat ~/.ssh/config) >  ~/.ssh/config.tmp; mv ~/.ssh/config.tmp ~/.ssh/config && chmod 0600 ~/.ssh/config; fi

start: up ssh sync
stop: halt


###############################################################
# grafna management
###############################################################
dump-monitor:
	ssh node0 "sudo cp /var/lib/grafana/grafana.db /tmp/grafana.db; sudo chmod a+r /tmp/grafana.db"
	scp node0:/tmp/grafana.db ansible/roles/meta_grafana/files/grafana.db
	ssh node0 "sudo rm -rf /tmp/grafana.db"

restore-monitor:
	scp ansible/roles/meta_grafana/files/grafana.db node0:/tmp/grafana.db
	ssh node0 "sudo mv /tmp/grafana.db /var/lib/grafana/grafana.db;sudo chown grafana /var/lib/grafana/grafana.db"
	ssh node0 "sudo rm -rf /etc/grafana/provisioning/dashboards/* ;sudo systemctl restart grafana-server"


.PHONY: default ssh dns cache init node meta infra clean up halt status suspend resume start stop down new
