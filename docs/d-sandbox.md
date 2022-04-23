# Sandbox

> Pigsty supports both [local sandbox](#local-sandbox) and [cloud sandbox](#cloud-sandbox) for quickly [preparing](d-prepare.md) a standard 1/4 node demo environment locally or in the cloud.

Although installing Pigsty is easy enough, setting up a virtual machine that meets the requirements is still a bit of a chore and you may need to use various virtual machine software.

Therefore Pigsty provides a **sandbox environment** to further relieve users of the hassle of preparing the environment. Complete creation and run-through of the sandbox installation and deployment process can be a great help for deployment in production environments with Pigsty.



## Introduction

The sandbox environment is a config specification, object identifier, and consistent with the default database **predetermined** for both the local and cloud versions.

The sandbox environment uses a fixed IP address for demonstration purposes. The IP address of the meta node of the sandbox is fixed to: `10.10.10.10`. `10.10.10.10` is also a placeholder for the IP address of the meta node in all config file templates, which will be the actual IP address of the meta node when executing [config](v-config.md#configure).

![](_media/SANDBOX.gif)

You can use a single-node sandbox, a deployment where there is only one meta-node `meta`, with a full infrastructure deployed on the node, and a single instance of the Postgres database `pg-meta`.

* `meta    10.10.10.10  pg-meta.pg-meta-1`

The single-node sandbox is suitable for personal development, experimentation, and learning; as an environment for data analysis and visualization; and for designing, demonstrating, and distributing interactive data applications. The four-node sandbox allows for a complete demonstration of Pigsty's capabilities and a full exploration of the highly available architecture and monitoring system, so please choose your on-demand.

In the four-node sandbox environment, there are three additional nodes, with an additional set of three-node PostgreSQL cluster `pg-test`.

* `node-1  10.10.10.11  pg-test.pg-test-1`
* `node-2  10.10.10.12  pg-test.pg-test-2`
* `node-3  10.10.10.13  pg-test.pg-test-3`

Also, the sandbox environment will use the following two IP addresses with two static DNS records for accessing the database cluster.

* `10.10.10.2  pg-meta`
* `10.10.10.2  pg-test`



Pigsty offers a local sandbox based on Vagrant (pulling up local VMs using Virtualbox), and a cloud sandbox based on Terraform (creating VMs using the cloud vendor API).

* Local sandboxes can be run on a regular Mac/PC at no cost, but to run a full 4-node sandbox environment locally, your Mac/PC should have at least 4C/8G hardware specs.

* Cloud sandbox can be easily shown and shared to others, you need to create a cloud account before use, virtual machine resources are created and used on demands, and can be destroyed with one click after use, there will be some fees (cheap).





## Local Sandbox

The Pigsty local sandbox relies on [Vagrant](https://www.vagrantup.com/) to host the local [Virtualbox](https://www.virtualbox.org/) virtual machine.

To use Pigsty sandbox, you need to install Vagrant and Virtualbox in your operating system, both are free cross-platform open-source software. You can also choose to create your own virtual machine for [standard installation and deployment](d-deploy.md) using your favorite virtual machine software (Parallels Desktop, VMWare).


### Quick Start

Make sure that [Vagrant](https://www.vagrantup.com/) and [Virtualbox](https://www.virtualbox.org/) are installed and available, just follow the official wizard to install them. On macOS, you can use `homebrew` to install both directly with one click (requires reboot).

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" # Install homebrew
brew install vagrant virtualbox # Installing Vagrant and Virtualbox on a MacOS host machine
```

On macOS operating systems, you can install software dependencies, configure local static DNS, and pull up virtual machines with the following four shortcut shortcuts. A few additional manual steps are required under Windows and Linux.

```bash
make deps    # Install homebrew, and install vagrant and virtualbox via homebrew (requires reboot)
make dns     # Write a static domain name to local /etc/hosts (requires sudo password)
make start   # Pull up a single meta node using Vagrant (4 nodes for start4)
```

Next, you can `ssh meta` to log in to the default admin node. SSH sudo for the admin node to access all nodes is already configured and you can execute the Pigsty installation directly.



### Vagrant

Often, to test a system such as a "database cluster", users need to prepare several virtual machines in advance. Although cloud services are already very convenient, local virtual machine access is usually easier, more responsive, and less expensive than cloud virtual machine access. Local VM config is relatively cumbersome, and [**Vagrant**](https://www.vagrantup.com/) can solve this problem.

Pigsty users don't need to understand how vagrant works, they just need to know that vagrant can simply and quickly pull up several virtual machines on a laptop, PC, or Mac according to the user's needs. All the user needs to accomplish is to express their virtual machine requirements in the form of a **vagrant config file**.

[https://github.com/Vonng/pigsty/blob/master/vagrant/Vagrantfile](https://github.com/Vonng/pigsty/blob/master/vagrant/Vagrantfile) A sample Vagrantfile is provided.

This is the Vagrantfile used by Pigsty sandbox, defining four virtual machines, including a 2-core/4GB central/**meta node** `meta` and three 1-core/1GB **database nodes** `node-1, node-2, node3`.


Usually, to test a system like a "database cluster", users need to prepare several virtual machines in advance. Although cloud services are already very convenient, local virtual machine access is usually easier, more responsive, and less expensive than cloud virtual machine access. Local VM config is relatively cumbersome, and [**Vagrant**](https://www.vagrantup.com/) can solve this problem.

Pigsty users don't need to understand how vagrant works, they just need to know that vagrant can simply and quickly pull up several virtual machines on a laptop, PC, or Mac according to the user's needs. All the user needs to accomplish is to express their virtual machine requirements in the form of a **Vagrant config file**.

[https://github.com/Vonng/pigsty/blob/master/vagrant/Vagrantfile](https://github.com/Vonng/pigsty/blob/master/vagrant/Vagrantfile) A sample Vagrantfile is provided. This is the Vagrantfile used by the Pigsty sandbox, defining four virtual machines, including a 2-core/4GB central control/**meta node** `meta` and three 1-core/1GB **database nodes** `node-1, node-2, node3`.

When using the sandbox through shortcuts like `make up` , `make new`, and `make start`, only a single meta node `meta` will be used by default. Whereas `make up4`, `make new4`, `make start4` will use all the virtual machines. Here the `N` value defines the number of additional database nodes (3). If your machine is under-configured, then consider using a smaller `N` value to reduce the number of database nodes. Users can also modify the number of CPU cores and memory resources per machine, etc., as described in the comments in the config file. Please refer to the Vagrant and Virtualbox doc for more detailed customization.

```ruby
IMAGE_NAME = "centos/7"
N=3  # Number of database machine nodes, can be modified to 0

Vagrant.configure("2") do |config|
    config.vm.box = IMAGE_NAME
    config.vm.box_check_update = false
    config.ssh.insert_key = false

    # Meta Nodes
    config.vm.define "meta", primary: true do |meta|  # The default ssh alias for the meta node is `meta`
        meta.vm.hostname = "meta"
        meta.vm.network "private_network", ip: "10.10.10.10"
        meta.vm.provider "virtualbox" do |v|
            v.linked_clone = true
            v.customize [
                    "modifyvm", :id,
                    "--memory", 4096, "--cpus", "2",   # Memory and CPU cores for meta nodes: default is 2 cores/4GB
                    "--nictype1", "virtio", "--nictype2", "virtio",
                    "--hwv·irtex", "on", "--ioapic", "on", "--rtcuseutc", "on", "--vtxvpid", "on", "--largepages", "on"
                ]
        end
        meta.vm.provision "shell", path: "provision.sh"
    end

    # Initialize N database nodes
    (1..N).each do |i|
        config.vm.define "node-#{i}" do |node|  # The default ssh aliases for the database nodes are `node-{1,2,3}`
            node.vm.box = IMAGE_NAME
            node.vm.network "private_network", ip: "10.10.10.#{i + 10}"
            node.vm.hostname = "node-#{i}"
            node.vm.provider "virtualbox" do |v|
                v.linked_clone = true
                v.customize [
                        "modifyvm", :id,
                        "--memory", 2048, "--cpus", "1", # Database node memory and CPU cores: default is 1 core/2GB
                        "--nictype1", "virtio", "--nictype2", "virtio",
                        "--hwvirtex", "on", "--ioapic", "on", "--rtcuseutc", "on", "--vtxvpid", "on", "--largepages", "on"
                    ]
            end
            node.vm.provision "shell", path: "provision.sh"
        end
    end
end
```

The `vagrant` binary will call Virtualbox by default to complete the creation of the local VMs as defined in the Vagrantfile. Go to the `vagrant` dir in the Pigsty root dir and execute `vagrant up` to pull up all four virtual machines. The [`Makefile`](https://github.com/Vonng/pigsty/blob/master/Makefile#L365) provides several wrappers for the original `vagrant` commands.

The default virtual machine image used by the sandbox environment is `IMAGE_NAME = "centos/7"`. The first execution will download the VirtualBox image of `centos 7.8.2003` from the Internet and will clone this BOX directly when re-creating a new virtual machine.



### Virtualbox

[Virtualbox](https://www.virtualbox.org/) is an open-source and free cross-platform virtual machine software. Installing Virtualbox on macOS is very simple: `brew install virtualbox` and is similar on other operating systems.

After installing Virtualbox, you may need to reboot your computer to load the virtual machine kernel module. Please note that Pigsty requires an x86_64 runtime environment, and Macbooks with M1 chips installed may not run Virtualbox properly.



### DNS Config

Pigsty accesses all web systems via **domain** by default. If you do not have a DNS server or public domain name, you can use local static DNS records. The static DNS records used by the sandbox environment are shown below.

```bash
# pigsty dns records
10.10.10.10 meta pigsty c.pigsty g.pigsty l.pigsty p.pigsty a.pigsty cli.pigsty lab.pigsty api.pigsty matrix.pigsty
10.10.10.11 node-1   # sandbox node node-1
10.10.10.12 node-2   # sandbox node node-2
10.10.10.13 node-3   # sandbox node node-3
10.10.10.2  pg-meta  # sandbox vip for pg-meta
10.10.10.3  pg-test  # sandbox vip for pg-test
```

On macOS and Linux, running `sudo make dns` will write the above records to `/etc/hosts` (requires sudo privileges), on Windows, you will need to add them manually to `C:\Windows\System32\drivers\etc\hosts`.












----------------


## Cloud Sandbox

If you don't have a PC, laptop, or Mac with x86_64 architecture, using a ready-to-use cloud virtual machine may be another good option.

### Terraform

[Terraform](https://www.terraform.io/) is an open-source and free infrastructure-as-code tool. Just declare the required cloud VMs, network, security group configs, etc., and pull up the corresponding resources with a single click.

To install Terraform under MacOS, simply execute `brew install terraform`. Then you need the cloud vendor account and get the AccessKey and AccessSecret credentials to start the cloud sandbox deployment.


### Config file

The project root dir `terraform/` provides Terraform resource definition files for several cloud vendors, you can use these templates to quickly request virtual machine resources on the cloud for Pigsty deployment. here is an example of Ali cloud.

```bash
cd terraform        # Go to the terraform dir
vi alicloud.tf      # Edit the config file, fill in your AliCloud AccessKey and SecretKey
```

<details><summary>AliCloud Sample Terraform Files</summary>


```ini
provider "alicloud" {
  access_key = "xxxxxx"
  secret_key = "xxxxxx"
  region = "cn-beijing"
}

# use 10.10.10.0/24 cidr block as demo network
resource "alicloud_vpc" "vpc" {
  vpc_name   = "pigsty-demo-network"
  cidr_block = "10.10.10.0/24"
}

# add virtual switch for pigsty demo network
resource "alicloud_vswitch" "vsw" {
  vpc_id     = "${alicloud_vpc.vpc.id}"
  cidr_block = "10.10.10.0/24"
  zone_id    = "cn-beijing-k"
}

# add default security group and allow all tcp traffic
resource "alicloud_security_group" "default" {
  name   = "default"
  vpc_id = "${alicloud_vpc.vpc.id}"
}
resource "alicloud_security_group_rule" "allow_all_tcp" {
  ip_protocol       = "tcp"
  type              = "ingress"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = "${alicloud_security_group.default.id}"
  cidr_ip           = "0.0.0.0/0"
}

# https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/instance
resource "alicloud_instance" "pg-meta-1" {
  instance_name              = "pg-meta-1"
  host_name                  = "pg-meta-1"
  instance_type              = "ecs.s6-c1m2.small"
  vswitch_id                 = "${alicloud_vswitch.vsw.id}"
  security_groups            = ["${alicloud_security_group.default.id}"]
  image_id                   = "centos_7_8_x64_20G_alibase_20200914.vhd"
  password                   = "PigstyDemo4"
  private_ip                 = "10.10.10.10"
  internet_max_bandwidth_out = 40 # 40Mbps , alloc a public IP
}

resource "alicloud_instance" "pg-test-1" {
  instance_name   = "pg-test-1"
  host_name       = "pg-test-1"
  instance_type   = "ecs.s6-c1m1.small"
  vswitch_id      = "${alicloud_vswitch.vsw.id}"
  security_groups = ["${alicloud_security_group.default.id}"]
  image_id        = "centos_7_8_x64_20G_alibase_20200914.vhd"
  password        = "PigstyDemo4"
  private_ip      = "10.10.10.11"
}

resource "alicloud_instance" "pg-test-2" {
  instance_name   = "pg-test-2"
  host_name       = "pg-test-2"
  instance_type   = "ecs.s6-c1m1.small"
  vswitch_id      = "${alicloud_vswitch.vsw.id}"
  security_groups = ["${alicloud_security_group.default.id}"]
  image_id        = "centos_7_8_x64_20G_alibase_20200914.vhd"
  password        = "PigstyDemo4"
  private_ip      = "10.10.10.12"
}

resource "alicloud_instance" "pg-test-3" {
  instance_name   = "pg-test-3"
  host_name       = "pg-test-3"
  instance_type   = "ecs.s6-c1m1.small"
  vswitch_id      = "${alicloud_vswitch.vsw.id}"
  security_groups = ["${alicloud_security_group.default.id}"]
  image_id        = "centos_7_8_x64_20G_alibase_20200914.vhd"
  password        = "PigstyDemo4"
  private_ip      = "10.10.10.13"
}


output "meta_ip" {
  value = "${alicloud_instance.pg-meta-1.public_ip}"
}


```

</details>



### Execution Plan

First, use the `terraform` command to create the cloud resource defined above (shared 1C1G temporary use is cheap, pay on demand).

```bash
terraform init      # Install terraform provider: aliyun (required only for the first time)
terraform apply     # Generate execution plans: create virtual machines, virtual segments/switches/security groups
```

After executing `apply` and entering yes, terraform will call AliCloud API to create the corresponding virtual machine resource.



<details><summary>Terraform Apply Execution Results</summary>


```bash
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # alicloud_instance.pg-meta-1 will be created
  + resource "alicloud_instance" "pg-meta-1" {
      + availability_zone                  = (known after apply)
      + credit_specification               = (known after apply)
      + deletion_protection                = false
      + dry_run                            = false
      + host_name                          = "pg-meta-1"
      + id                                 = (known after apply)
      + image_id                           = "centos_7_8_x64_20G_alibase_20200914.vhd"
      + instance_charge_type               = "PostPaid"
      + instance_name                      = "pg-meta-1"
      + instance_type                      = "ecs.s6-c1m2.small"
      + internet_charge_type               = "PayByTraffic"
      + internet_max_bandwidth_in          = (known after apply)
      + internet_max_bandwidth_out         = 40
      + key_name                           = (known after apply)
      + password                           = (sensitive value)
      + private_ip                         = "10.10.10.10"
      + public_ip                          = (known after apply)
      + role_name                          = (known after apply)
      + secondary_private_ip_address_count = (known after apply)
      + secondary_private_ips              = (known after apply)
      + security_groups                    = (known after apply)
      + spot_strategy                      = "NoSpot"
      + status                             = "Running"
      + subnet_id                          = (known after apply)
      + system_disk_category               = "cloud_efficiency"
      + system_disk_performance_level      = (known after apply)
      + system_disk_size                   = 40
      + volume_tags                        = (known after apply)
      + vswitch_id                         = (known after apply)
    }

  # alicloud_instance.pg-test-1 will be created
  + resource "alicloud_instance" "pg-test-1" {
      + availability_zone                  = (known after apply)
      + credit_specification               = (known after apply)
      + deletion_protection                = false
      + dry_run                            = false
      + host_name                          = "pg-test-1"
      + id                                 = (known after apply)
      + image_id                           = "centos_7_8_x64_20G_alibase_20200914.vhd"
      + instance_charge_type               = "PostPaid"
      + instance_name                      = "pg-test-1"
      + instance_type                      = "ecs.s6-c1m1.small"
      + internet_max_bandwidth_in          = (known after apply)
      + internet_max_bandwidth_out         = 0
      + key_name                           = (known after apply)
      + password                           = (sensitive value)
      + private_ip                         = "10.10.10.11"
      + public_ip                          = (known after apply)
      + role_name                          = (known after apply)
      + secondary_private_ip_address_count = (known after apply)
      + secondary_private_ips              = (known after apply)
      + security_groups                    = (known after apply)
      + spot_strategy                      = "NoSpot"
      + status                             = "Running"
      + subnet_id                          = (known after apply)
      + system_disk_category               = "cloud_efficiency"
      + system_disk_performance_level      = (known after apply)
      + system_disk_size                   = 40
      + volume_tags                        = (known after apply)
      + vswitch_id                         = (known after apply)
    }

  # alicloud_instance.pg-test-2 will be created
  + resource "alicloud_instance" "pg-test-2" {
      + availability_zone                  = (known after apply)
      + credit_specification               = (known after apply)
      + deletion_protection                = false
      + dry_run                            = false
      + host_name                          = "pg-test-2"
      + id                                 = (known after apply)
      + image_id                           = "centos_7_8_x64_20G_alibase_20200914.vhd"
      + instance_charge_type               = "PostPaid"
      + instance_name                      = "pg-test-2"
      + instance_type                      = "ecs.s6-c1m1.small"
      + internet_max_bandwidth_in          = (known after apply)
      + internet_max_bandwidth_out         = 0
      + key_name                           = (known after apply)
      + password                           = (sensitive value)
      + private_ip                         = "10.10.10.12"
      + public_ip                          = (known after apply)
      + role_name                          = (known after apply)
      + secondary_private_ip_address_count = (known after apply)
      + secondary_private_ips              = (known after apply)
      + security_groups                    = (known after apply)
      + spot_strategy                      = "NoSpot"
      + status                             = "Running"
      + subnet_id                          = (known after apply)
      + system_disk_category               = "cloud_efficiency"
      + system_disk_performance_level      = (known after apply)
      + system_disk_size                   = 40
      + volume_tags                        = (known after apply)
      + vswitch_id                         = (known after apply)
    }

  # alicloud_instance.pg-test-3 will be created
  + resource "alicloud_instance" "pg-test-3" {
      + availability_zone                  = (known after apply)
      + credit_specification               = (known after apply)
      + deletion_protection                = false
      + dry_run                            = false
      + host_name                          = "pg-test-3"
      + id                                 = (known after apply)
      + image_id                           = "centos_7_8_x64_20G_alibase_20200914.vhd"
      + instance_charge_type               = "PostPaid"
      + instance_name                      = "pg-test-3"
      + instance_type                      = "ecs.s6-c1m1.small"
      + internet_max_bandwidth_in          = (known after apply)
      + internet_max_bandwidth_out         = 0
      + key_name                           = (known after apply)
      + password                           = (sensitive value)
      + private_ip                         = "10.10.10.13"
      + public_ip                          = (known after apply)
      + role_name                          = (known after apply)
      + secondary_private_ip_address_count = (known after apply)
      + secondary_private_ips              = (known after apply)
      + security_groups                    = (known after apply)
      + spot_strategy                      = "NoSpot"
      + status                             = "Running"
      + subnet_id                          = (known after apply)
      + system_disk_category               = "cloud_efficiency"
      + system_disk_performance_level      = (known after apply)
      + system_disk_size                   = 40
      + volume_tags                        = (known after apply)
      + vswitch_id                         = (known after apply)
    }

  # alicloud_security_group.default will be created
  + resource "alicloud_security_group" "default" {
      + id                  = (known after apply)
      + inner_access        = (known after apply)
      + inner_access_policy = (known after apply)
      + name                = "default"
      + security_group_type = "normal"
      + vpc_id              = (known after apply)
    }

  # alicloud_security_group_rule.allow_all_tcp will be created
  + resource "alicloud_security_group_rule" "allow_all_tcp" {
      + cidr_ip           = "0.0.0.0/0"
      + id                = (known after apply)
      + ip_protocol       = "tcp"
      + nic_type          = "intranet"
      + policy            = "accept"
      + port_range        = "1/65535"
      + priority          = 1
      + security_group_id = (known after apply)
      + type              = "ingress"
    }

  # alicloud_vpc.vpc will be created
  + resource "alicloud_vpc" "vpc" {
      + cidr_block        = "10.10.10.0/24"
      + id                = (known after apply)
      + ipv6_cidr_block   = (known after apply)
      + name              = (known after apply)
      + resource_group_id = (known after apply)
      + route_table_id    = (known after apply)
      + router_id         = (known after apply)
      + router_table_id   = (known after apply)
      + status            = (known after apply)
      + vpc_name          = "pigsty-demo-network"
    }

  # alicloud_vswitch.vsw will be created
  + resource "alicloud_vswitch" "vsw" {
      + availability_zone = (known after apply)
      + cidr_block        = "10.10.10.0/24"
      + id                = (known after apply)
      + name              = (known after apply)
      + status            = (known after apply)
      + vpc_id            = (known after apply)
      + vswitch_name      = (known after apply)
      + zone_id           = "cn-beijing-k"
    }

Plan: 8 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + meta_ip = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

alicloud_vpc.vpc: Creating...
alicloud_vpc.vpc: Creation complete after 6s [id=vpc-2zed78z7n5z06o1dmydhj]
alicloud_security_group.default: Creating...
alicloud_vswitch.vsw: Creating...
alicloud_security_group.default: Creation complete after 1s [id=sg-2ze7x7zu8tcdsefroofa]
alicloud_security_group_rule.allow_all_tcp: Creating...
alicloud_security_group_rule.allow_all_tcp: Creation complete after 0s [id=sg-2ze7x7zu8tcdsefroofa:ingress:tcp:1/65535:intranet:0.0.0.0/0:accept:1]
alicloud_vswitch.vsw: Creation complete after 6s [id=vsw-2zejctjdr16ryz194jxz4]
alicloud_instance.pg-test-3: Creating...
alicloud_instance.pg-test-2: Creating...
alicloud_instance.pg-test-1: Creating...
alicloud_instance.pg-meta-1: Creating...
alicloud_instance.pg-test-3: Still creating... [10s elapsed]
alicloud_instance.pg-test-2: Still creating... [10s elapsed]
alicloud_instance.pg-test-1: Still creating... [10s elapsed]
alicloud_instance.pg-meta-1: Still creating... [10s elapsed]
alicloud_instance.pg-meta-1: Creation complete after 16s [id=i-2zef4frw6kezb47339wr]
alicloud_instance.pg-test-1: Still creating... [20s elapsed]
alicloud_instance.pg-test-2: Still creating... [20s elapsed]
alicloud_instance.pg-test-3: Still creating... [20s elapsed]
alicloud_instance.pg-test-2: Creation complete after 23s [id=i-2zefzvz0fyl7mloc4v30]
alicloud_instance.pg-test-1: Still creating... [30s elapsed]
alicloud_instance.pg-test-3: Still creating... [30s elapsed]
alicloud_instance.pg-test-3: Creation complete after 33s [id=i-2zeeyodo2pc8b1k2d167]
alicloud_instance.pg-test-1: Creation complete after 33s [id=i-2zef4frw6kezb47339ws]
```

</details>



### SSH Config and Tweaking

Among other things, the management machine will be assigned a pay-per-use public IP, which you can also print out using the command `terraform output`.

```bash
# Print public IP and root password
ssh_pass='PigstyDemo4'
public_ip=$(terraform output | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
echo "meta node: root:${ssh_pass}@${public_ip}"
```

Next, let's configure the SSH config for local login to the cloud management machine (default user `root`, password `PigstyDemo4`).

```bash
# Create ~/.ssh/pigsty_terraform file containing SSH definitions for the cloud management machine (optional)
cat > ~/.ssh/pigsty_terraform <<-EOF
Host demo
  User root
  HostName ${public_ip}
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication yes
EOF
chmod 0600 ~/.ssh/pigsty_terraform 

# Enable this config
if ! grep --quiet "Include ~/.ssh/pigsty_terraform" ~/.ssh/config ; then
    (echo 'Include ~/.ssh/pigsty_terraform' && cat ~/.ssh/config) >  ~/.ssh/config.tmp;
    mv ~/.ssh/config.tmp ~/.ssh/config && chmod 0600 ~/.ssh/config;
fi
```

You can then access the cloud manager via the SSH alias `demo`.

```bash
# Add local to meta node for password-free access
sshpass -p ${ssh_pass} ssh-copy-id demo 
```

The node can then be accessed locally without a password, or if only a single-node installation is required, this will do. Next, the standard installation is completed on that management node.


### DNS Config

Pigsty accesses all web systems via **domain** by default, although you can use IP: Port to access the main system's web interface, this is not the recommended behavior.

The static DNS record used by the cloud sandbox environment is shown below and you need to fill in the public IP address of the meta node.

```bash
<public_ip> meta pigsty c.pigsty g.pigsty l.pigsty p.pigsty a.pigsty cli.pigsty lab.pigsty api.pigsty matrix.pigsty
```

In macOS and Linux, you need to write the above records to `/etc/hosts` (requires sudo privileges), and in Windows, you need to add them manually to `C:\Windows\System32\drivers\etc\hosts`.



### Caveat

The AliCloud virtual machine CentOS 7.8 image is running with `nscd`, which locks out the glibc version and causes RPM dependency errors during installation.

Run `yum remove -y nscd` on all machines to resolve this issue.

After completing the above preparations, all machines are ready to start the Pigsty download config installation trilogy.