new: clean up


###############################################################
# node creation
###############################################################
meta:
	cd vagrant && vagrant up node0
	cd ansible && ./init-yum.yml && ./init-control.yml
# copy yum dir to accelerate next vm creation
cache:
	rm -rf pkg/* && mkdir -p pkg && scp -r node0:/www/pigsty/* pkg/

###############################################################
# vm management
###############################################################
status:
	cd vagrant && vagrant status
up:
	cd vagrant && vagrant up
	bin/setup-ssh.sh
suspend:
	cd vagrant && vagrant suspend
halt:
	cd vagrant && vagrant halt
resume:
	cd vagrant && vagrant resume
clean: halt
	cd vagrant && vagrant destroy -f --parallel
	exit 0
# sync node clock via ntp
sync-time:
	echo node0 node1 node2 node3 | xargs -n1 -P4 -I{} ssh {} sudo ntpdate -u time.pool.aliyun.com




.PHONY: status meta up suspend halt resume clean
