# Vagrant Sandbox

[Vagrant](https://www.vagrantup.com/) can create local VMs according to [specifications](#Specifications).

[Virtualbox](https://www.virtualbox.org/) is used as the default provider.

Apple M1 now has arm64 support with Parallel Desktop.



## Specifications

[Vagranfile](https://github.com/Vonng/pigsty/blob/master/vagrant/Vagrantfile) is a ruby script defining VM nodes. Here are the default specs of Pigsty. 


|           Templates           | Shortcut |      Spec       |               Comment               |
| :---------------------------: | :------: | :-------------: | :---------------------------------: |
| [default.rb](spec/default.rb) |   `v1`   |    3C6G x 1     |             Single Node             |
|    [full.rb](spec/full.rb)    |   `v4`   | 2C4G + 1C2G x 3 |          Full 4 Node Demo           |
|   [build.rb](spec/build.rb)   |   `vb`   |    2C4G x 3     | 3-Node EL7,8,9 Building Environment |
|     [el7.rb](spec/el7.rb)     |   `v7`   | 2C4G + 1C2G x 3 |       EL7 4-nodes Testing Env       |
|     [el8.rb](spec/el8.rb)     |   `v8`   | 2C4G + 1C2G x 3 |       EL8 4-nodes Testing Env       |
|     [el9.rb](spec/el9.rb)     |   `v9`   | 2C4G + 1C2G x 3 |       EL9 4-nodes Testing Env       |



## Switch Spec

```bash
vagrant/switch <spec>

# example
vagrant/switch default  # shortcut: make v1
vagrant/switch full     # shortcut: make v4
vagrant/switch build    # shortcut: make vb
vagrant/switch el7      # shortcut: make v7
vagrant/switch el8      # shortcut: make v8
vagrant/switch el9      # shortcut: make v9
...
```

> Add your node spec definition to `spec/<spec>.rb` to customize. Example spec file:

```ruby
Specs = [
  {"name" => "meta"  ,"ip"=>"10.10.10.10","cpu" => "2","mem"=>"4096","image"=>"generic/rhel9"  },
  {"name" => "node-1","ip"=>"10.10.10.11","cpu" => "1","mem"=>"2048","image"=>"generic/centos7" },
  {"name" => "node-2","ip"=>"10.10.10.12","cpu" => "1","mem"=>"2048","image"=>"generic/oracle9"},
  {"name" => "node-3","ip"=>"10.10.10.13","cpu" => "1","mem"=>"2048","image"=>"generic/centos7"  },
]
```



## Shortcuts

Some makefile shorts for vagrant VM management.

```makefile
new: del up  # destroy & recreate VMs
clean: del
up:
	cd vagrant && vagrant up
dw:
	cd vagrant && vagrant halt
del:
	cd vagrant && vagrant destroy -f
status:
	cd vagrant && vagrant status
suspend:
	cd vagrant && vagrant suspend
resume:
	cd vagrant && vagrant resume
```

Examples:

```bash
make v1     # switch to Vagrantfile: default single node mode    
make v4     # switch to Vagrantfile: 4-node full demo mode
make vb     # switch to Vagrantfile: 3-node building environment
make v7     # switch to Vagrantfile: el7 testing environment
make v8     # switch to Vagrantfile: el8 testing environment
make v9     # switch to Vagrantfile: el9 testing environment
make new    # create Vagrant VM nodes
make ssh    # write Vagrant VM nodes ssh host config to ~/.ssh/
make dns    # write dns configuration to local host
```




## Caveat

Newer version of virtualbox have problem alloc host-only 10.x.x.x address. Add cidr to `/etc/vbox/networks.conf`:

```bash
# /etc/vbox/networks.conf
* 10.0.0.0/8
```

Reference: https://discuss.hashicorp.com/t/vagran-can-not-assign-ip-address-to-virtualbox-machine/30930/3