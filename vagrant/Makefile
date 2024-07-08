#==============================================================#
# File      :   Makefile
# Desc      :   vagrant shortcuts
# Ctime     :   2023-07-29
# Mtime     :   2024-07-08
# Path      :   vagrant/Makefile
# Author    :   Ruohang Feng (rh@vonng.com)
# License   :   AGPLv3
#==============================================================#


###############################################################
#                         Environment                         #
###############################################################
# VAGRANT_SPEC='meta'
# VAGRANT_IMAGE='generic/rocky8'
# VAGRANT_SCALE='1'
# VAGRANT_PROVIDER='virtualbox'


###############################################################
#                         Management                          #
###############################################################

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
# libvirtd info
#------------------------------#
info:
	virsh list
	virsh net-list
	virsh vol-list --pool=default


###############################################################
#                       Specifications                        #
###############################################################

#------------------------------#
#     Building Environment     #
#------------------------------#
build: del vb up ssh
rpm:   del vr up ssh
deb:   del vd up ssh
all:   del va up ssh
old:   del vo up ssh

vb: # pigsty building environment
	./switch build
vr: # rpm building environment
	./switch rpm
vd: # deb building environment
	./switch deb
va: # deb building environment
	./switch all
vo: # old building environment
	./switch old

#------------------------------#
# meta, single node, the devbox
#------------------------------#
# simple 1-node devbox for quick setup, demonstration, and development

meta:   del vmeta   up ssh
meta7:  del vmeta7  up ssh
meta8:  del vmeta8  up ssh
meta9:  del vmeta9  up ssh
meta11: del vmeta11 up ssh
meta12: del vmeta12 up ssh
meta20: del vmeta20 up ssh
meta22: del vmeta22 up ssh

vm: vmeta
vmeta:
	./config meta
vmeta7:
	./config meta el7
vmeta8:
	./config meta el8
vmeta9:
	./config meta el9
vmeta12:
	./config meta debian12
vmeta20:
	./config meta ubuntu20
vmeta22:
	./config meta ubuntu22

#------------------------------#
# full, four nodes, the sandbox
#------------------------------#
# full-featured 4-node sandbox for HA-testing & tutorial & practices

full:   del vfull   up ssh
full7:  del vfull7  up ssh
full8:  del vfull8  up ssh
full9:  del vfull9  up ssh
full11: del vfull11 up ssh
full12: del vfull12 up ssh
full20: del vfull20 up ssh
full22: del vfull22 up ssh

vf: vfull
vfull:
	./config full
vfull7:
	./config full el7
vfull8:
	./config full el8
vfull9:
	./config full el9
vfull11:
	./config full debian11
vfull12:
	./config full debian12
vfull20:
	./config full ubuntu20
vfull22:
	./config full ubuntu22

#------------------------------#
# prod, 43 nodes, the simubox
#------------------------------#
# complex 43-node simubox for production simulation & complete testing

prod:   del vprod   up ssh
prod7:  del vprod7  up ssh
prod8:  del vprod8  up ssh
prod9:  del vprod9  up ssh
prod11: del vprod11 up ssh
prod12: del vprod12 up ssh
prod20: del vprod20 up ssh
prod22: del vprod22 up ssh

vp: vprod
vprod:
	./config prod
vprod7:
	./config prod el7
vprod8:
	./config prod el8
vprod9:
	./config prod el9
vprod11:
	./config prod debian11
vprod12:
	./config prod debian12
vprod20:
	./config prod ubuntu20
vprod22:
	./config prod ubuntu22

#------------------------------#
# dual, 2-node, seldom used
#------------------------------#
# 2-node environment

dual:   del vdual   up ssh
dual7:  del vdual7  up ssh
dual8:  del vdual8  up ssh
dual9:  del vdual9  up ssh
dual11: del vdual11 up ssh
dual12: del vdual12 up ssh
dual20: del vdual20 up ssh
dual22: del vdual22 up ssh

vdual:
	./config dual
vdual7:
	./config dual el7
vdual8:
	./config dual el8
vdual9:
	./config dual el9
vdual12:
	./config dual debian12
vdual20:
	./config dual ubuntu20
vdual22:
	./config dual ubuntu22

#------------------------------#
# trio, 3-node, seldom used
#------------------------------#
# 3-node environment

trio:   del vtrio   up ssh
trio7:  del vtrio7  up ssh
trio8:  del vtrio8  up ssh
trio9:  del vtrio9  up ssh
trio11: del vtrio11 up ssh
trio12: del vtrio12 up ssh
trio20: del vtrio20 up ssh
trio22: del vtrio22 up ssh

vtrio:
	./config trio
vtrio7:
	./config trio el7
vtrio8:
	./config trio el8
vtrio9:
	./config trio el9
vtrio12:
	./config trio debian12
vtrio20:
	./config trio ubuntu20
vtrio22:
	./config trio ubuntu22


###############################################################
#                        Inventory                            #
###############################################################
.PHONY: default new ssh sshb dns start up down dw halt clean del destroy nuke st status pause suspend resume info \
	build rpm deb all old vb vr vd vm vf vp va vo\
	meta meta7 meta8 meta9 meta11 meta12 meta20 meta22 vmeta vmeta7 vmeta8 vmeta9 vmeta12 vmeta20 vmeta22 \
	dual dual7 dual8 dual9 dual11 dual12 dual20 dual22 vdual vdual7 vdual8 vdual9 vdual11 vdual12 vdual20 vdual22 \
	trio trio7 trio8 trio9 trio11 trio12 trio20 trio22 vtrio vtrio7 vtrio8 vtrio9 vtrio11 vtrio12 vtrio20 vtrio22 \
	full full7 full8 full9 full11 full12 full20 full22 vfull vfull7 vfull8 vfull9 vfull11 vfull12 vfull20 vfull22 \
	prod prod7 prod8 prod9 prod11 prod12 prod20 prod22 vprod vprod7 vprod8 vprod9 vprod11 vprod12 vprod20 vprod22
###############################################################