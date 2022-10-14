#==============================================================#
# File      :   Vagrantfile
# Mtime     :   2022-10-12
# Ctime     :   2022-10-12
# Desc      :   Pigsty sandbox with 4 different linux distro
# Path      :   vagrant/Vagrantfile
# Note      :   change spec according to your own hardware
# Copyright (C) 2018-2022 Ruohang Feng
#==============================================================#


#==============================================================#
# RHEL RELEASE VERSION
EL_RELEASE = "7"
CENTOS_STREAM_SUFFIX =  EL_RELEASE == "9" ? "s" : ""
CENTOS_NAME= "generic/centos" + EL_RELEASE + CENTOS_STREAM_SUFFIX
ROCKY_NAME= "generic/rocky" + EL_RELEASE   # rocky7 not available
ORACLE_NAME= "generic/oracle" + EL_RELEASE
RHEL_NAME= "generic/rhel" + EL_RELEASE
#==============================================================#


#==============================================================#
# meta node
META_IMAGE = RHEL_NAME
META_NODE_CPU = "2"
META_NODE_MEM = "4096"

# # test nodes with different distributions
TEST_IMAGES = [ CENTOS_NAME, ROCKY_NAME, ORACLE_NAME]
TEST_NODE_CPU = [ "1" , "1", "1" ]
TEST_NODE_MEM = [ "2048" , "2048", "2048" ]
TEST_NODE_NUMBER = 3
#==============================================================#

Vagrant.configure("2") do |config|
    config.vm.box = META_IMAGE
    config.vm.box_check_update = false
    config.ssh.insert_key = false

    # meta node
    config.vm.define "meta", primary: true do |meta|
        meta.vm.hostname = "meta"
        meta.vm.network "private_network", ip: "10.10.10.10"
        meta.vm.provider "virtualbox" do |v|
            v.linked_clone = true
            v.customize [
                    "modifyvm", :id,
                    "--cpus", META_NODE_CPU,
                    "--memory", META_NODE_MEM,
                    "--nictype1", "virtio", "--nictype2", "virtio", "--hwvirtex", "on", "--ioapic", "on", "--rtcuseutc", "on", "--vtxvpid", "on", "--largepages", "on"
                ]
            v.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 1000]
        end
        meta.vm.provision "shell", path: "provision.sh"
    end

    # node-1 ... node-N
    (1..TEST_NODE_NUMBER).each do |i|
        config.vm.define "node-#{i}" do |node|
            node.vm.box = TEST_IMAGES[i-1]
            node.vm.network "private_network", ip: "10.10.10.#{i + 10}"
            node.vm.hostname = "node-#{i}"
            node.vm.provider "virtualbox" do |v|
                v.linked_clone = true
                v.customize [
                    "modifyvm", :id,
                    "--cpus", TEST_NODE_CPU[i-1],
                    "--memory", TEST_NODE_MEM[i-1],
                    "--nictype1", "virtio", "--nictype2", "virtio", "--hwvirtex", "on", "--ioapic", "on", "--rtcuseutc", "on", "--vtxvpid", "on", "--largepages", "on"
                  ]
                v.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 1000]
            end
            node.vm.provision "shell", path: "provision.sh"
        end
    end
end

