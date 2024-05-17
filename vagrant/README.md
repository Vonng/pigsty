# Vagrant Environment

[Vagrant](https://www.vagrantup.com/) can create local VMs according to [specifications](#Specifications) in a declarative way.

[Virtualbox](https://www.virtualbox.org/) is used as the default provider, and [`libvirt`](https://vagrant-libvirt.github.io/vagrant-libvirt/) is also supported.



## Quick Start

Create pre-configured environment with `make` shortcuts:

```bash
make meta     # singleton meta
make full     # 4-node sandbox
make el7      # 3-node el7 test
make el8      # 3-node el8 test
make el9      # 3-node el9 test
make prod     # 42-node prod simulation
make oss      # 3-node oss building env
make build    # 7-node pro building env
make minio    # 3-node minio env
make check    # 30-node check env
```



## Specifications

`Vagranfile` is a ruby script file describing VM nodes. Here are some default specs of Pigsty. 

|         Templates         | Shortcut |      Spec       |             Comment             |
|:-------------------------:|:--------:|:---------------:|:-------------------------------:|
|  [meta.rb](spec/meta.rb)  |   `v1`   |    4C8G x 1     |        Single Meta Node         |
|  [full.rb](spec/full.rb)  |   `v4`   | 2C4G + 1C2G x 3 |    Full 4 Nodes Sandbox Demo    |
|   [el7.rb](spec/el7.rb)   |   `v7`   | 2C4G + 1C2G x 3 |     EL7 3-node Testing Env      |
|   [el8.rb](spec/el8.rb)   |   `v8`   | 2C4G + 1C2G x 3 |     EL8 3-node Testing Env      |
|   [el9.rb](spec/el9.rb)   |   `v9`   | 2C4G + 1C2G x 3 |     EL9 3-node Testing Env      |
|   [oss.rb](spec/oss.rb)   |   `vo`   |    4C8G x 3     | 3-Node OSS Building Environment |
|   [rpm.rb](spec/oss.rb)   |   `vr`   |    4C8G x 3     | 3-Node Rpm Building Environment |
|   [deb.rb](spec/oss.rb)   |   `vd`   |    4C8G x 4     | 4-Node Deb Building Environment |
| [build.rb](spec/build.rb) |   `vb`   |    2C4G x 7     | 7-Node Pro Building Environment |
| [check.rb](spec/check.rb) |   `vc`   |    2C4G x 30    | 30 node el7-9 pg12-16 Check Env |
| [minio.rb](spec/minio.rb) |   `vm`   | 2C4G x 3 + Disk |  3-Node MinIO/etcd Testing Env  |
|  [prod.rb](spec/prod.rb)  |   `vp`   |    42 nodes     |  Prod simulation with 45 Nodes  |


Each spec file contains a `Specs` variable describe VM nodes. For example, the [`full.rb`](spec/full.rb) contains:

```ruby
Specs = [
  {"name" => "meta",   "ip" => "10.10.10.10", "cpu" => "2",  "mem" => "4096", "image" => "generic/rocky9" },
  {"name" => "node-1", "ip" => "10.10.10.11", "cpu" => "1",  "mem" => "2048", "image" => "generic/rocky9" },
  {"name" => "node-2", "ip" => "10.10.10.12", "cpu" => "1",  "mem" => "2048", "image" => "generic/rocky9" },
  {"name" => "node-3", "ip" => "10.10.10.13", "cpu" => "1",  "mem" => "2048", "image" => "generic/rocky9" },
]
```

You can switch specs with the [`switch`](switch) script, it will render the final `Vagrantfile` according to the spec.

```bash
cd ~/pigsty
vagrant/switch <spec>

vagrant/switch meta     # singleton meta        | alias:  `make v1`
vagrant/switch full     # 4-node sandbox        | alias:  `make v4`
vagrant/switch el7      # 3-node el7 test       | alias:  `make v7`
vagrant/switch el8      # 3-node el8 test       | alias:  `make v8`
vagrant/switch el9      # 3-node el9 test       | alias:  `make v9`
vagrant/switch oss      # 3-node oss build      | alias:  `make vo`
vagrant/switch rpm      # 3-node rpm build      | alias:  `make vr`
vagrant/switch deb      # 4-node deb build      | alias:  `make vd`
vagrant/switch prod     # prod simulation       | alias:  `make vp`
vagrant/switch build    # building environment  | alias:  `make vd`
vagrant/switch check    # 30-node check env
vagrant/switch minio    # 3-node minio env
```

> You can also add your own specs to [`spec/<name>.rb`] and switch to it with `vagrant/switch name`




## Shortcuts

After describing the VM nodes with specs and generate the `vagrant/Vagrantfile`. you can create the VMs with `vagrant up` command.

Pigsty templates will use your `~/.ssh/id_rsa[.pub]` as the default ssh key for vagrant provisioning. 

Make sure you have a valid ssh key pair before you start, you can generate one by: `ssh-keygen -t rsa -b 2048`

There are some makefile shortcuts that wrap the vagrant commands, you can use them to manage the VMs.

```bash
make         # = make start
make new     # destroy existing vm and create new ones
make ssh     # write VM ssh config to ~/.ssh/     (required)
make dns     # write VM DNS records to /etc/hosts (optional)
make start   # launch VMs and write ssh config    (up + ssh) 
make up      # launch VMs with vagrant up
make halt    # shutdown VMs (down,dw)
make clean   # destroy VMs (clean/del/destroy)
make status  # show VM status (st)
make pause   # pause VMs (suspend,pause)
make resume  # pause VMs (resume)
make nuke    # destroy all vm & volumes with virsh (if using libvirt) 
```



## Available Images

Pigsty on EL 7 ~ 9, you can use following OS images from vagrant cloud. It is recommended to use rocky9, rocky8, and centos7.

```ruby
Images = {
  "RHEL"   => { "7"=> "generic/rhel7"   , "8"=> "generic/rhel8"   , "9"=> "generic/rhel9"   },
  "CentOS" => { "7"=> "generic/centos7"                                                     },
  "Rocky"  => {                           "8"=> "generic/rocky8"  , "9"=> "generic/rocky9"  },
  "Oracle" => { "7"=> "generic/oracle7" , "8"=> "generic/oracle8" , "9"=> "generic/oracle9" },
  "Alma"   => {                           "8"=> "generic/alma8"   , "9"=> "generic/alma9"   },
}
```


## Caveat

If you are using virtualbox, you have to add `10.0.0.0/8` to `/etc/vbox/networks.conf` first to use 10.x.x.x in host-only networks.

```bash
# /etc/vbox/networks.conf
* 10.0.0.0/8
```

Reference: https://discuss.hashicorp.com/t/vagran-can-not-assign-ip-address-to-virtualbox-machine/30930/3