# Vagrant Environment

[Vagrant](https://www.vagrantup.com/) can create local VMs according to [specifications](#Specifications) in a declarative way.

[Virtualbox](https://www.virtualbox.org/) is used as the default provider, and [`libvirt`](https://vagrant-libvirt.github.io/vagrant-libvirt/) is also supported.



--------

## Quick Start

Create pre-configured environment with `make` shortcuts:

```bash
make meta       # 1-node devbox for quick start, dev, test & playground
make full       # 4-node sandbox for HA-testing & feature demonstration
make prod       # 43-node simubox for production environment simulation

# seldom used templates:
make dual       # 2-node env
make trio       # 3-node env
```

You can use variant alias to create environment with different base image:

```bash
make meta9      # create singleton-meta node with generic/rocky9 image
make full22     # create 4-node sandbox with generic/ubuntu22 image
make prod12     # create 43-node production env simubox with generic/debian12 image
...             # available suffix: 7,8,9,11,12,20,22,24
```

You can also launch pigsty building env with these alias, base image will not be substituted:

```bash
make build      # 4-node building environment 
make rpm        # 3-node el7/8/9 building env
make deb        # 5-node debian11/12 ubuntu20/22/24
make all        # 7-node building env with all base images
```


--------

## Specifications

`Vagranfile` is a ruby script file describing VM nodes. Here are some default specs of Pigsty. 

|        Templates        |  Nodes  |      Spec       |         Comment         |  Alias   |
|:-----------------------:|:-------:|:---------------:|:-----------------------:|:--------:|
| [meta.rb](spec/meta.rb) | 1 node  |    2c4g x 1     |    Single Node Meta     |  Devbox  |
| [dual.rb](spec/dual.rb) | 2 node  |    1c2g x 2     |       Dual Nodes        |          |
| [trio.rb](spec/trio.rb) | 3 node  |    1c2G x 3     |       Three Nodes       |          |
| [full.rb](spec/full.rb) | 4 node  | 2c4g + 1c2g x 3 |  Full-Featured 4 Node   | Sandbox  |
| [prod.rb](spec/prod.rb) | 36 node |      misc       |   Prod Env Simulation   | Simubox  |
| [build.rb](spec/oss.rb) | 5 node  |    1c2g x 4     |   4-Node Building Env   | Buildbox |
|  [rpm.rb](spec/rpm.rb)  | 3 node  |    1c2G x 3     | 3-Node EL Building Env  |          |
|  [deb.rb](spec/deb.rb)  | 5 node  |    1c2G x 5     | 5-Node Deb Building Env |          |
|  [all.rb](spec/all.rb)  | 7 node  |    1c2G x 7     | 7-Node All Building Env |          |

Each spec file contains a `Specs` variable describe VM nodes. For example, the [`full.rb`](spec/full.rb) contains:

```ruby
# full: pigsty full-featured 4-node sandbox for HA-testing & tutorial & practices

Specs = [
  { "name" => "meta"   , "ip" => "10.10.10.10" ,  "cpu" => "2" ,  "mem" => "4096" ,  "image" => "generic/rocky8"  },
  { "name" => "node-1" , "ip" => "10.10.10.11" ,  "cpu" => "1" ,  "mem" => "2048" ,  "image" => "generic/rocky8"  },
  { "name" => "node-2" , "ip" => "10.10.10.12" ,  "cpu" => "1" ,  "mem" => "2048" ,  "image" => "generic/rocky8"  },
  { "name" => "node-3" , "ip" => "10.10.10.13" ,  "cpu" => "1" ,  "mem" => "2048" ,  "image" => "generic/rocky8"  },
]

```

You can use specs with the [`config`](config) script, it will render the final `Vagrantfile` according to the spec and other options

```bash
cd ~/pigsty
vagrant/config [spec] [image] [scale] [provider]

vagrant/config meta                # use the 1-node spec, default el8 image
vagrant/config dual el9            # use the 2-node spec, use el9 image instead 
vagrant/config trio d12 2          # use the 3-node spec, use debian12 image, double the cpu/mem resource
vagrant/config full u22 4          # use the 4-node spec, use ubuntu22 image instead, use 4x cpu/mem resource         
vagrant/config prod u20 1 libvirt  # use the 43-node spec, use ubuntu20 image instead, use libvirt as provider instead of virtualbox 
```

You can scale the resource unit with environment variable `VM_SCALE`, the default value is `1`.

For example, if you use `VM_SCALE=2` with `vagrant/config meta`, it will double the cpu / mem resources of the meta node.

```bash
# pigsty singleton-meta environment (4C8G)

Specs = [
  { "name" => "meta"          , "ip" => "10.10.10.10"   , "cpu" => "8"    , "mem" => "16384"    , "image" => "generic/rocky8"   },
]
````



--------

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



--------

## Caveat

If you are using virtualbox, you have to add `10.0.0.0/8` to `/etc/vbox/networks.conf` first to use 10.x.x.x in host-only networks.

```bash
# /etc/vbox/networks.conf
* 10.0.0.0/8
```

Reference: https://discuss.hashicorp.com/t/vagran-can-not-assign-ip-address-to-virtualbox-machine/30930/3