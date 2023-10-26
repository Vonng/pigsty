# Provisioning

> A crude intro to provision VMs for pigsty with **vagrant** & **terraform**

Pigsty runs on nodes, which are Bare Metals or Virtual Machines. You can prepare them manually, or using terraform & vagrant for provisioning.



----------------

## Sandbox

Pigsty has a sandbox, which is a 4-node deployment with fixed IP addresses and other identifiers.
Check [`demo.yml`](https://github.com/Vonng/pigsty/blob/master/files/pigsty/demo.yml) for details.

The sandbox consists of 4 nodes with fixed IP addresses: `10.10.10.10`, `10.10.10.11`, `10.10.10.12`, `10.10.10.13`.

There's a primary singleton PostgreSQL cluster: `pg-meta` on the `meta` node, which can be used alone if you don't care about PostgreSQL high availability.

* `meta    10.10.10.10  pg-meta pg-meta-1`

There are 3 additional nodes in the sandbox, form a 3-instance PostgreSQL HA cluster `pg-test`.

* `node-1  10.10.10.11  pg-test.pg-test-1`
* `node-2  10.10.10.12  pg-test.pg-test-2`
* `node-3  10.10.10.13  pg-test.pg-test-3`

Two optional L2 VIP are bind on primary instances of cluster `pg-meta`  and `pg-test`:

* `10.10.10.2  pg-meta`
* `10.10.10.2  pg-test`

There's also a 1-instance `etcd` cluster, and 1-instance `minio` cluster on the `meta` node, too.

![pigsty-sandbox.jpg](https://repo.pigsty.cc/img/pigsty-sandbox.jpg)

You can run sandbox on local VMs or cloud VMs. Pigsty offers a local sandbox based on [Vagrant](#vagrant) (pulling up local VMs using Virtualbox or libvirt), and a cloud sandbox based on Terraform (creating VMs using the cloud vendor API).

* Local sandbox can be run on your Mac/PC for free.  Your Mac/PC should have at least 4C/8G to run the full 4-node sandbox.

* Cloud sandbox can be easily created and shared. You will have to create a cloud account for that. VMs are created on-demand and can be destroyed with one command, which is also very cheap for a quick glance.



----------------

## Vagrant

[Vagrant](https://www.vagrantup.com/) can create local VMs according to specs in a declarative way.
Check [Vagrant Templates Intro](https://github.com/Vonng/pigsty/tree/master/vagrant/README.md) for details 

Vagrant will use  [VirtualBox](https://www.virtualbox.org/) as the default VM provider.
however libvirt, docker, parallel desktop and vmware can also be used. We will use VirtualBox in this guide.


### Installation

Make sure [Vagrant](https://www.vagrantup.com/) and [Virtualbox](https://www.virtualbox.org/) are installed and available on your OS. 

If you are using macOS, You can use `homebrew` to install both of them with one command (reboot required). You can also use [vagrant-libvirt](https://vagrant-libvirt.github.io/vagrant-libvirt/) on Linux.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install vagrant virtualbox ansible   # Run on MacOS with one command, but only works on x86_64 Intel chips
```

### Configuration

[`vagarnt/Vagranfile`](https://github.com/Vonng/pigsty/blob/master/vagrant/Vagrantfile) is a ruby script file describing VM nodes. Here are some default specs of Pigsty.

|                                   Templates                                   | Shortcut |      Spec       |               Comment               |
|:-----------------------------------------------------------------------------:|:--------:|:---------------:|:-----------------------------------:|
|  [meta.rb](https://github.com/Vonng/pigsty/blob/master/vagrant/spec/meta.rb)  |   `v1`   |    4C8G x 1     |          Single Meta Node           |
|  [full.rb](https://github.com/Vonng/pigsty/blob/master/vagrant/spec/full.rb)  |   `v4`   | 2C4G + 1C2G x 3 |      Full 4 Nodes Sandbox Demo      |
|   [el7.rb](https://github.com/Vonng/pigsty/blob/master/vagrant/spec/el7.rb)   |   `v7`   | 2C4G + 1C2G x 3 |       EL7 3-node Testing Env        |
|   [el8.rb](https://github.com/Vonng/pigsty/blob/master/vagrant/spec/el8.rb)   |   `v8`   | 2C4G + 1C2G x 3 |       EL8 3-node Testing Env        |
|   [el9.rb](https://github.com/Vonng/pigsty/blob/master/vagrant/spec/el9.rb)   |   `v9`   | 2C4G + 1C2G x 3 |       EL9 3-node Testing Env        |
| [build.rb](https://github.com/Vonng/pigsty/blob/master/vagrant/spec/build.rb) |   `vb`   |    2C4G x 3     | 3-Node EL7,8,9 Building Environment |
| [check.rb](https://github.com/Vonng/pigsty/blob/master/vagrant/spec/check.rb) |   `vc`   |   2C4G x 30     |    30 Node EL7-EL9 PG 12-16 Env     |
| [minio.rb](https://github.com/Vonng/pigsty/blob/master/vagrant/spec/minio.rb) |   `vm`   | 2C4G x 3 + Disk |    3-Node MinIO/etcd Testing Env    |
|  [prod.rb](https://github.com/Vonng/pigsty/blob/master/vagrant/spec/prod.rb)  |   `vp`   |    45 nodes     |    Prod simulation with 45 Nodes    |


Each spec file contains a `Specs` variable describe VM nodes. For example, the `full.rb` contains the 4-node sandbox specs.

```ruby
Specs = [
  {"name" => "meta",   "ip" => "10.10.10.10", "cpu" => "2",  "mem" => "4096", "image" => "generic/rocky9" },
  {"name" => "node-1", "ip" => "10.10.10.11", "cpu" => "1",  "mem" => "2048", "image" => "generic/rocky9" },
  {"name" => "node-2", "ip" => "10.10.10.12", "cpu" => "1",  "mem" => "2048", "image" => "generic/rocky9" },
  {"name" => "node-3", "ip" => "10.10.10.13", "cpu" => "1",  "mem" => "2048", "image" => "generic/rocky9" },
]
```

You can switch specs with the `vagrant/switch` script, it will render the final `Vagrantfile` according to the spec.

```bash
cd ~/pigsty
vagrant/switch <spec>

vagrant/switch meta     # singleton meta        | alias:  `make v1`
vagrant/switch full     # 4-node sandbox        | alias:  `make v4`
vagrant/switch el7      # 3-node el7 test       | alias:  `make v7`
vagrant/switch el8      # 3-node el8 test       | alias:  `make v8`
vagrant/switch el9      # 3-node el9 test       | alias:  `make v9`
vagrant/switch prod     # prod simulation       | alias:  `make vp`
vagrant/switch build    # building environment  | alias:  `make vd`
vagrant/switch minio    # 3-node minio env
vagrant/switch check    # 30-node check env
```


### Management

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


### Shortcuts

You can create VMs with the following shortcuts:

```bash
make meta     # singleton meta
make full     # 4-node sandbox
make el7      # 3-node el7 test
make el8      # 3-node el8 test
make el9      # 3-node el9 test
make prod     # prod simulation
make build    # building environment
make minio    # 3-node minio env
make check    # 30-node check env
```

```bash
make meta  install   # create and install pigsty on 1-node singleton meta
make full  install   # create and install pigsty on 4-node sandbox
make prod  install   # create and install pigsty on 42-node KVM libvirt environment
make check install   # create and install pigsty on 30-node testing & validating environment
...
```



----------------

## Terraform

[Terraform](https://www.terraform.io/) is an open-source tool to practice 'Infra as Code'. Describe the cloud resource you want and create them with one command.

Pigsty has terraform templates for AWS, Aliyun, and Tencent Cloud, you can use them to create VMs on the cloud for Pigsty Demo.

Terraform can be easily installed with homebrew, too: `brew install terraform`. You will have to create a cloud account to obtain AccessKey and AccessSecret credentials to proceed.


The `terraform/` dir have two example templates: one for AWS, and one for Aliyun, you can adjust them to fit your need, or modify them if you are using a different cloud vendor. 

Take Aliyun as example:

```bash
cd terraform                         # goto the terraform dir
cp spec/alicloud.tf terraform.tf     # use aliyun template
```

You have to perform `terraform init` before `terraform apply`:

```bash
terraform init      # install terraform provider: aliyun (required only for the first time)
terraform apply     # generate execution plans: create VMs, virtual segments/switches/security groups
```

After running `apply` and answering `yes` to the prompt, Terraform will create the VMs and configure the network for you.

The admin node ip address will be printed out at the end of the execution, you can log in and start pigsty [installation](INSTALL) 



