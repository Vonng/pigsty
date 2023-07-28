#!/usr/bin/ruby

# powered by a Dell R730 72C 256G 4T bare metal
# the host is running libvirtd and provisioned with vagrant-libvirtd plugin

Specs = [

    { "name" => "build-el7"     , "ip" => "10.10.10.7",  "cpu" => "8",   "mem" => "32768" , "image" =>  "generic/rocky9"  },
    { "name" => "build-el8"     , "ip" => "10.10.10.8",  "cpu" => "8",   "mem" => "32768" , "image" =>  "generic/rocky8"  },
    { "name" => "build-el9"     , "ip" => "10.10.10.9",  "cpu" => "8",   "mem" => "32768" , "image" =>  "generic/centos7" },

]

# Get Preset SSH Key from vagrant/ssh dir (REGENERATE FOR NON-DEVELOPMENT USE)
ssh_prv_key = File.read(File.join('/root', '.ssh', 'id_rsa'))
ssh_pub_key = File.readlines(File.join('/root', '.ssh', 'id_rsa.pub')).first.strip

Vagrant.configure("2") do |config|
    config.ssh.insert_key = false
    config.vm.box_check_update = false
    config.vm.provision "shell" do |s|
      s.inline = <<-SHELL
        if grep -sq "#{ssh_pub_key}" /home/vagrant/.ssh/authorized_keys; then
          echo "SSH keys already provisioned." ; exit 0;
        fi
        echo "SSH key provisioning."
        sshd=/home/vagrant/.ssh
        mkdir -p ${sshd}; touch ${sshd}/{authorized_keys,config}
        echo #{ssh_pub_key}   >> ${sshd}/authorized_keys
        echo #{ssh_pub_key}   >  ${sshd}/id_rsa.pub      ; chmod 644 ${sshd}/id_rsa.pub
        echo "#{ssh_prv_key}" >  ${sshd}/id_rsa          ; chmod 600 ${sshd}/id_rsa
        if ! grep -q "StrictHostKeyChecking" ${sshd}/config; then
            echo 'StrictHostKeyChecking=no' >> ${sshd}/config
        fi
        chown -R vagrant:vagrant /home/vagrant
        exit 0
      SHELL
    end

    Specs.each_with_index do |spec, index|
        config.vm.define spec["name"] do |node|
            node.vm.box = spec["image"]
            node.vm.network "private_network", ip: spec["ip"]
            node.vm.hostname = spec["name"]
            node.vm.provider "libvirt" do |v|
                v.cpus   =  spec["cpu"]
                v.memory =  spec["mem"]
                if spec["name"].start_with?("minio")
                    v.storage :file, :size => '128G', :device => 'vdb'
                    node.vm.provision "shell" do |s|
                      s.inline = <<-SHELL
                        mkdir -p /data; mkfs.ext4 /dev/vdb;
                        mount -o noatime -o nodiratime -t ext4 /dev/vdb /data;
                        echo "/dev/vdb /data ext4 defaults,noatime,nodiratime 0 0" >> /etc/fstab;
                      SHELL
                    end
                end
            end
        end
    end
end