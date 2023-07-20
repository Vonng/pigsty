#!/usr/bin/ruby

# powered by a Dell R730 72C 256G 4T bare metal
# the host is running libvirtd and provisioned with vagrant-libvirtd plugin

# scp ~/pigsty/dist/v2.2.0/pigsty-pkg-v2.2.0.el9.x86_64.tgz infra-1:/tmp/pkg.tgz; ssh infra-3 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'
# scp ~/pigsty/dist/v2.2.0/pigsty-pkg-v2.2.0.el8.x86_64.tgz infra-2:/tmp/pkg.tgz; ssh infra-2 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'
# scp ~/pigsty/dist/v2.2.0/pigsty-pkg-v2.2.0.el7.x86_64.tgz infra-3:/tmp/pkg.tgz; ssh infra-1 'sudo mkdir -p /www; sudo tar -xf /tmp/pkg.tgz -C /www'

Specs = [

    # 3 infra nodes on el7, el8, el9
    { "name" => "infra-1"       , "ip" => "10.10.10.11",  "cpu" => "8",   "mem" => "32768" , "image" =>  "generic/rocky9"  },
    { "name" => "infra-2"       , "ip" => "10.10.10.12",  "cpu" => "8",   "mem" => "32768" , "image" =>  "generic/rocky8"  },
    { "name" => "infra-3"       , "ip" => "10.10.10.13",  "cpu" => "8",   "mem" => "32768" , "image" =>  "generic/centos7" },

    # 2 dedicate load balancer nodes
    { "name" => "proxy-1"       , "ip" => "10.10.10.14",  "cpu" => "2",   "mem" => "4096"  , "image" =>  "generic/rocky9"  },
    { "name" => "proxy-2"       , "ip" => "10.10.10.15",  "cpu" => "2",   "mem" => "4096"  , "image" =>  "generic/rocky9"  },

    # 3 minio nodes
    { "name" => "minio-1"       , "ip" => "10.10.10.17",  "cpu" => "2",   "mem" => "4096"  , "image" =>  "generic/rocky9"  },
    { "name" => "minio-2"       , "ip" => "10.10.10.18",  "cpu" => "2",   "mem" => "4096"  , "image" =>  "generic/rocky9"  },
    { "name" => "minio-3"       , "ip" => "10.10.10.19",  "cpu" => "2",   "mem" => "4096"  , "image" =>  "generic/rocky9"  },

    # 5 etcd and redis-sentinel
    { "name" => "etcd-1"        , "ip" => "10.10.10.31",  "cpu" => "2",   "mem" => "4096"  , "image" =>  "generic/rocky9"  },
    { "name" => "etcd-2"        , "ip" => "10.10.10.32",  "cpu" => "2",   "mem" => "4096"  , "image" =>  "generic/rocky9"  },
    { "name" => "etcd-3"        , "ip" => "10.10.10.33",  "cpu" => "2",   "mem" => "4096"  , "image" =>  "generic/rocky9"  },
    { "name" => "etcd-4"        , "ip" => "10.10.10.34",  "cpu" => "2",   "mem" => "4096"  , "image" =>  "generic/rocky9"  },
    { "name" => "etcd-5"        , "ip" => "10.10.10.35",  "cpu" => "2",   "mem" => "4096"  , "image" =>  "generic/rocky9"  },

    # 3 pg clusters with 4,3,2 nodes
    { "name" => "pg-test-1"     , "ip" => "10.10.10.41",  "cpu" => "2",   "mem" => "4096"  , "image" =>  "generic/rocky9"  },
    { "name" => "pg-test-2"     , "ip" => "10.10.10.42",  "cpu" => "2",   "mem" => "4096"  , "image" =>  "generic/rocky9"  },
    { "name" => "pg-test-3"     , "ip" => "10.10.10.43",  "cpu" => "2",   "mem" => "4096"  , "image" =>  "generic/rocky9"  },
    { "name" => "pg-test-4"     , "ip" => "10.10.10.44",  "cpu" => "2",   "mem" => "4096"  , "image" =>  "generic/rocky9"  },
    { "name" => "pg-src-1"      , "ip" => "10.10.10.45",  "cpu" => "2",   "mem" => "4096"  , "image" =>  "generic/rocky9"  },
    { "name" => "pg-src-2"      , "ip" => "10.10.10.46",  "cpu" => "2",   "mem" => "4096"  , "image" =>  "generic/rocky9"  },
    { "name" => "pg-src-3"      , "ip" => "10.10.10.47",  "cpu" => "2",   "mem" => "4096"  , "image" =>  "generic/rocky9"  },
    { "name" => "pg-dst-1"      , "ip" => "10.10.10.48",  "cpu" => "8",   "mem" => "8192"  , "image" =>  "generic/rocky9"  },
    { "name" => "pg-dst-2"      , "ip" => "10.10.10.49",  "cpu" => "1",   "mem" => "2048"  , "image" =>  "generic/rocky9"  },

    # 5 node citus distributed database cluster
    { "name" => "pg-citus0-1"   , "ip" => "10.10.10.50",  "cpu" => "2",   "mem" => "2048"  , "image" =>  "generic/rocky9"  },
    { "name" => "pg-citus0-2"   , "ip" => "10.10.10.51",  "cpu" => "2",   "mem" => "2048"  , "image" =>  "generic/rocky9"  },
    { "name" => "pg-citus1-1"   , "ip" => "10.10.10.52",  "cpu" => "2",   "mem" => "2048"  , "image" =>  "generic/rocky9"  },
    { "name" => "pg-citus1-2"   , "ip" => "10.10.10.53",  "cpu" => "2",   "mem" => "2048"  , "image" =>  "generic/rocky9"  },
    { "name" => "pg-citus2-1"   , "ip" => "10.10.10.54",  "cpu" => "2",   "mem" => "2048"  , "image" =>  "generic/rocky9"  },
    { "name" => "pg-citus2-2"   , "ip" => "10.10.10.55",  "cpu" => "2",   "mem" => "2048"  , "image" =>  "generic/rocky9"  },
    { "name" => "pg-citus3-1"   , "ip" => "10.10.10.56",  "cpu" => "2",   "mem" => "2048"  , "image" =>  "generic/rocky9"  },
    { "name" => "pg-citus3-2"   , "ip" => "10.10.10.57",  "cpu" => "2",   "mem" => "2048"  , "image" =>  "generic/rocky9"  },
    { "name" => "pg-citus4-1"   , "ip" => "10.10.10.58",  "cpu" => "2",   "mem" => "2048"  , "image" =>  "generic/rocky9"  },
    { "name" => "pg-citus4-2"   , "ip" => "10.10.10.59",  "cpu" => "2",   "mem" => "2048"  , "image" =>  "generic/rocky9"  },

    # redis native cluster with 6 nodes
    { "name" => "redis-test-1"  , "ip" => "10.10.10.71",  "cpu" => "2",   "mem" => "4096"  , "image" =>  "generic/rocky9"  },
    { "name" => "redis-test-2"  , "ip" => "10.10.10.72",  "cpu" => "2",   "mem" => "4096"  , "image" =>  "generic/rocky9"  },
    { "name" => "redis-test-3"  , "ip" => "10.10.10.73",  "cpu" => "2",   "mem" => "4096"  , "image" =>  "generic/rocky9"  },
    { "name" => "redis-test-4"  , "ip" => "10.10.10.74",  "cpu" => "2",   "mem" => "4096"  , "image" =>  "generic/rocky9"  },
    { "name" => "redis-test-5"  , "ip" => "10.10.10.75",  "cpu" => "2",   "mem" => "4096"  , "image" =>  "generic/rocky9"  },
    { "name" => "redis-test-6"  , "ip" => "10.10.10.76",  "cpu" => "2",   "mem" => "4096"  , "image" =>  "generic/rocky9"  },

    # pg adhoc version: 12 - 16
    { "name" => "pg-v12-1"      , "ip" => "10.10.10.82",  "cpu" => "1",   "mem" => "2048"  , "image" =>  "generic/rocky9"  },
    { "name" => "pg-v13-1"      , "ip" => "10.10.10.83",  "cpu" => "1",   "mem" => "2048"  , "image" =>  "generic/rocky9"  },
    { "name" => "pg-v14-1"      , "ip" => "10.10.10.84",  "cpu" => "1",   "mem" => "2048"  , "image" =>  "generic/rocky9"  },
    { "name" => "pg-v15-1"      , "ip" => "10.10.10.85",  "cpu" => "1",   "mem" => "2048"  , "image" =>  "generic/rocky9"  },
    { "name" => "pg-v16-1"      , "ip" => "10.10.10.86",  "cpu" => "1",   "mem" => "2048"  , "image" =>  "generic/rocky9"  },
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