default: start


###############################################################
# Public objective
###############################################################
# write dns record to your own host, sudo required
dns:
	if ! grep --quiet "pigsty dns records" /etc/hosts ; then cat ansible/files/dnsmasq/hosts >> /etc/hosts; fi

# copy yum packages to your own host, pigsty/pkg
cache:
	ssh node0 "sudo mkdir -p /www/pigsty/grafana"
	ssh node0  "sudo tar -zcf /www/pigsty/grafana/grafana.tar.gz /var/lib/grafana"
	rm -rf pkg/* && mkdir -p pkg && scp -r node0:/www/pigsty/* pkg/

# init will pull up entire cluster
init: infra

# down will halt all vm (not destroy)
down: halt

# show vagrant cluster status
st: status

###############################################################
# node init
###############################################################
node:
	cd ansible && ./init-node.yml
meta:
	cd ansible && ./init-meta.yml
infra: node meta

###############################################################
# postgres init
###############################################################
pgsql:
	cd ansible && ./init-pgsql.yml

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
	echo node0 node1 node2 node3 | xargs -n1 -P4 -I{} ssh {} 'sudo bash -c "if command -v ntpdate > /dev/null ;then ntpdate -u time.pool.aliyun.com; fi"'; true
# append pigsty ssh config to ~/.ssh
ssh:
	cd vagrant && vagrant ssh-config > ~/.ssh/pigsty_config 2>/dev/null; true
	if ! grep --quiet "pigsty_config" ~/.ssh/config ; then (echo 'Include ~/.ssh/pigsty_config' && cat ~/.ssh/config) >  ~/.ssh/config.tmp; mv ~/.ssh/config.tmp ~/.ssh/config && chmod 0600 ~/.ssh/config; fi
	if ! grep --quiet "StrictHostKeyChecking=no" ~/.ssh/config ; then (echo 'StrictHostKeyChecking=no' && cat ~/.ssh/config) >  ~/.ssh/config.tmp; mv ~/.ssh/config.tmp ~/.ssh/config && chmod 0600 ~/.ssh/config; fi

start: up ssh sync
stop: halt
new: clean start init


.PHONY: default ssh dns cache init node meta infra clean up halt status suspend resume start stop down new
