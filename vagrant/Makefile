#==============================================================#
# File      :   Makefile
# Desc      :   vagrant shortcuts
# Ctime     :   2023-07-29
# Mtime     :   2023-07-29
# Path      :   vagrant/Makefile
# Author    :   Ruohang Feng (rh@vonng.com)
# License   :   AGPLv3
#==============================================================#

VM_PROVIDER='virtualbox'
# VM_PROVIDER='libvirtd'

#------------------------------#
# default: launch vagrant vms
#------------------------------#
default: start
new: del up ssh

#------------------------------#
# dns
#------------------------------#
dns:
	sudo ./dns

#------------------------------#
# add ssh config to ~/.ssh/
#------------------------------#
ssh:
	./ssh
sshb:
	./ssh build

#------------------------------#
# Start & Up
#------------------------------#
start: up ssh
up:
	vagrant up

#------------------------------#
# Stop & Halt
#------------------------------#
down: halt
dw: halt
halt:
	vagrant halt

#------------------------------#
# destroy
#------------------------------#
clean: destroy
del: destroy
destroy:
	vagrant destroy -f
nuke:
	./nuke
#------------------------------#
# status
#------------------------------#
st: status
status:
	vagrant status
list:
	virsh list --all

#------------------------------#
# suspend & resume
#------------------------------#
pause: suspend
suspend:
	vagrant suspend
resume:
	vagrant resume

#------------------------------#
# vagrant templates:
#------------------------------#
v1:
	./switch meta
v4:
	./switch full
v7:
	./switch el7
v8:
	./switch el8
v9:
	./switch el9
vb:
	./switch build
vp:
	./switch prod
vc:
	./switch check
vm:
	./switch minio
vo:
	./switch os

# switch to production env with rocky8
vp8:
	./switch prod
	sed -ie 's/rocky9/rocky8/g' Vagrantfile
	rm -rf Vagrantfilee

# switch to prod env with centos7
vp7:
	./switch prod
	sed -ie 's/rocky9/centos7/g' Vagrantfile
	rm -rf Vagrantfilee

meta:  del v1 up ssh
full:  del v4 up ssh
el7:   del v7 up ssh
el8:   del v8 up ssh
el9:   del v9 up ssh
build: del vb up ssh
prod:  del vp up ssh
check: del vc up ssh
minio: del vm up ssh
os:    del vo up ssh
prod8: del vp8 up ssh
prod7: del vp7 up ssh


###############################################################
#                        Inventory                            #
###############################################################
.PHONY: default new ssh sshb dns \
	start up down dw halt clean del destroy nuke st status pause suspend resume \
	v1 v4 v7 v8 v9 vb vp vc vm vp8 vp7 meta full el7 el8 el9 build check prod minio prod8 prod7
###############################################################