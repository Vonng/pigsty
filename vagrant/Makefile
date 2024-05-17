#==============================================================#
# File      :   Makefile
# Desc      :   vagrant shortcuts
# Ctime     :   2023-07-29
# Mtime     :   2024-05-17
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
vr:
	./switch rpm
vd:
	./switch deb
vc:
	./switch check
vm:
	./switch minio
vo:
	./switch oss
vu:
	./switch ubuntu


#------------------------------#
# production template
#------------------------------#
vp: vp8  # use rocky 8 as default
vp7:
	./switch prod; sed -ie 's/rocky8/centos7/g' Vagrantfile ; rm -rf Vagrantfilee ;
vp8:
	./switch prod # the default prod template is rocky8
vp9:
	./switch prod; sed -ie 's/rocky8/rocky9/g' Vagrantfile ; rm -rf Vagrantfilee ;
vp11:
	./switch prod; sed -ie 's/rocky8/debian11/g' Vagrantfile ; rm -rf Vagrantfilee ;
vp12:
	./switch prod; sed -ie 's/rocky8/debian12/g' Vagrantfile ; rm -rf Vagrantfilee ;
vp20:
	./switch prod; sed -ie 's/rocky8/ubuntu2004/g' Vagrantfile ; rm -rf Vagrantfilee ;
vp22:
	./switch prod; sed -ie 's/rocky8/ubuntu2204/g' Vagrantfile ; rm -rf Vagrantfilee ;


meta:   del v1 up ssh
full:   del v4 up ssh
el7:    del v7 up ssh
el8:    del v8 up ssh
el9:    del v9 up ssh
check:  del vc up ssh
minio:  del vm up ssh
oss:    del vo up ssh
ubuntu: dev vu up ssh
build:  del vb up ssh
rpm:    del vbr up ssh
deb:    del vbd up ssh
prod:   del vp   up ssh
prod7:  del vp7  up ssh
prod8:  del vp8  up ssh
prod9:  del vp9  up ssh
prod11: del vp11 up ssh
prod12: del vp12 up ssh
prod20: del vp20 up ssh
prod22: del vp22 up ssh


###############################################################
#                        Inventory                            #
###############################################################
.PHONY: default new ssh sshb dns \
	start up down dw halt clean del destroy nuke st status pause suspend resume \
	v1 v4 v7 v8 v9 vb vr vd vc vm vo vu \
	vp vp7 vp8 vp9 vp11 vp12 vp20 vp22 \
	 meta full el7 el8 el9 build rpm deb check minio oss ubuntu \
	 prod prod7 prod8 prod9 prod11 prod12 prod20 prod22

###############################################################