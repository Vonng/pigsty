# Provisioning

> A crude intro to provision VMs for pigsty with **vagrant** & **terraform**

Pigsty runs on nodes, which are Bare Metals or Virtual Machines. You can prepare them manually, or using terraform & vagrant for provionsing.


----------------

## Sandbox

Pigsty has a sandbox, which is a 4-node deployment with fixed IP addresses and other identifiers. Check [`demo.yml`](https://github.com/Vonng/pigsty/blob/master/files/pigsty/demo.yml) for details.

The sandbox consists of 4 nodes with fixed IP addresses: `10.10.10.10`, `10.10.10.11`, `10.10.10.12`, `10.10.10.13`.

and a 3-instance PostgreSQL HA cluster: `pg-test` 

There's a primary singleton PostgreSQL cluster: `pg-meta` on the `meta` node, which can be used alone if you don't care about PostgreSQL high availability.

* `meta    10.10.10.10  pg-meta pg-meta-1`

There are 3 additional nodes in the sandbox, with a 3-instance PostgreSQL HA cluster `pg-test`.

* `node-1  10.10.10.11  pg-test.pg-test-1`
* `node-2  10.10.10.12  pg-test.pg-test-2`
* `node-3  10.10.10.13  pg-test.pg-test-3`

Two optional L2 VIP are bind on primary instances of  `pg-meta`  and `pg-test`:

* `10.10.10.2  pg-meta`
* `10.10.10.2  pg-test`

There's also a 1-instance `etcd` cluster, and 1-instance `minio` cluster on the `meta` node, too.

  ![pigsty-sandbox](https://user-images.githubusercontent.com/8587410/206972073-f204fb7a-b91c-4f50-9d5e-3104ea2e7d70.gif)



You can run sandbox on local VMs or cloud VMs. Pigsty offers a local sandbox based on Vagrant (pulling up local VMs using Virtualbox), and a cloud sandbox based on Terraform (creating VMs using the cloud vendor API).

* Local sandbox can be run on your Mac/PC for free.  Your Mac/PC should have at least 4C/8G to run the full 4-node sandbox.

* Cloud sandbox can be easily created and shared. You will have to create a cloud account for that. VMs are created on-demand and can be destroyed with one command, which is also very cheap for a quick glance.





----------------

## Vagrant

Local sandbox require [Vagrant](https://www.vagrantup.com/) and [Virtualbox](https://www.virtualbox.org/) to work.

Make sure [Vagrant](https://www.vagrantup.com/) and [Virtualbox](https://www.virtualbox.org/) are installed and available on your OS. 



### MacOS Quick Start

If you are using macOS, You can use `homebrew` to install both of them with one command (reboot required).

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" # Install homebrew
brew install vagrant VirtualBox # Installing Vagrant and Virtualbox on a MacOS host
```

There are some shortcuts to help you get started quickly: install deps, write static DNS and pull up the 1-node/4-node sandbox.

```bash
make deps           # Install homebrew, and install vagrant and Virtualbox via homebrew (requires reboot)
make dns            # Write static DNS records to local /etc/hosts (requires sudo password)
make meta install   # pull up a single meta node and install pigsty on it  1-NODE Sandbox
make full install   # pull up 4 nodes and install pigsty on them           4-NODE Sandbox
```


### Vagrant Templates

Pigsty have some Vagrant [templates](https://github.com/Vonng/pigsty/tree/master/vagrant) for different scenarios.

|         Templates         | Shortcut |      Spec       |               Comment               |
|:-------------------------:|:--------:|:---------------:|:-----------------------------------:|
|  [meta.rb](spec/meta.rb)  |   `v1`   |    4C8G x 1     |          Single Meta Node           |
|  [full.rb](spec/full.rb)  |   `v4`   | 2C4G + 1C2G x 3 |          Full 4 Node Demo           |
| [build.rb](spec/build.rb) |   `vb`   |    2C4G x 3     | 3-Node EL7,8,9 Building Environment |
|   [el7.rb](spec/el7.rb)   |   `v7`   | 2C4G + 1C2G x 3 |       EL7 4-nodes Testing Env       |
|   [el8.rb](spec/el8.rb)   |   `v8`   | 2C4G + 1C2G x 3 |       EL8 4-nodes Testing Env       |
|   [el9.rb](spec/el9.rb)   |   `v9`   | 2C4G + 1C2G x 3 |       EL9 4-nodes Testing Env       |

You can customize the [`vagrant/Vagrantfile`](https://github.com/Vonng/pigsty/blob/master/vagrant/Vagrantfile) to fit your need:

```ruby
Specs = [
  {"name" => "meta",   "ip" => "10.10.10.10", "cpu" => "2",  "mem" => "4096", "image" => "generic/centos7" },
  {"name" => "node-1", "ip" => "10.10.10.11", "cpu" => "1",  "mem" => "2048", "image" => "generic/centos7" },
  {"name" => "node-2", "ip" => "10.10.10.12", "cpu" => "1",  "mem" => "2048", "image" => "generic/centos7" },
  {"name" => "node-3", "ip" => "10.10.10.13", "cpu" => "1",  "mem" => "2048", "image" => "generic/centos7" },
]
```

And here are some makefile shortcuts to help you manage the VMs:

```bash
new: del up   # destroy & recreate VMs
clean: del    # destroy VMs
up:           # pull up all VMs
	cd vagrant && vagrant up
dw:           # stop all VMs
	cd vagrant && vagrant halt
del:          # remove all VMs
	cd vagrant && vagrant destroy -f
status:       # show VM status
	cd vagrant && vagrant status
suspend:      # pause VMs
	cd vagrant && vagrant suspend
resume:       # resume VMs
	cd vagrant && vagrant resume
```



----------------


## Terraform

[Terraform](https://www.terraform.io/) is an open-source tool to practice 'Infra as Code'. Describe the cloud resource you want and create them with one command.

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


