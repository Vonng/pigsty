# Preparation

How to prepare the resources required for Pigsty deployment.

* [Node Provisioning](#node-provisioning)
* [Meta Provisioning](#meta-provisioning)
* [Admin Provisioning](#admin-provisioning)
* [Software Provisioning](#software-provisioning)
  * [Pigsty source code](#pigsty-source-code)
  * [Pigsty offline package](#pigsty-offline-package)
  * [Vagrant](#vagrant) (sandbox)
  * [Virtualbox](#virtualbox) (sandbox)

## Node Provisioning

Before deploying Pigsty, the user needs to prepare machine node resources,
including at least one [meta node](c-arch.md#meta-node), with arbitrary [database nodes](c-arch.md#database-node).

The [database nodes](c-arch.md#database-node) can use any type of nodes: bare metals, local vms, cloud vms, containers, etc...
only if the following conditions are met:

- [x] Processor architecture: x86_64
- [x] Hardware specifications: 1C/1GB at least
- [x] Operating System: CentOS 7.8.2003 (or RHEL7 equivalent)
- [x] Admin user can `ssh` to the node and execute `sudo` commands.



## Meta Provisioning

Pigsty requires an [meta node](c-arch.md#meta-node) as the admin controller of the entire environment and provides [infrastructure](c-arch.md#infrastructure) services.

The minimum number of **meta nodes** is 1. The sandbox environment uses 1 meta node by default. 
Pigsty's infrastructure is deployed as **replicas** on multiple meta nodes, except for DCS (Consul/Etcd), which exists as Quorum.

Pigsty's database cluster requires the use of DCS for HA failure detection and configuration storage,
you can Use a DCS cluster that is automatically deployed on the meta node, or use an external DCS cluster.

When using Pigsty's built-in DCS cluster, you must have odd number of meta nodes,
and it is recommended to use at least 3 meta nodes in **production environments** to fully ensure the availability of DCS services.

Of couse, you can use external DCS servers. Just change the [`dcs_servers`](v-dcs.md#dcs_servers).

Users should ensure that they have nopass `ssh` & `sudo` privileges on meta node (to initiate control), 
and direct/in-direct browser access to port 80 (to visit user interface).

- [x] Number of meta nodes: odd number, at least 1
- [x] Ability to log in to the meta node using the administrator user
- [x] Ability to access port 80 of the meta node via browser (directly or indirectly)
- [x] **admin user** can log in to the database node remotely `ssh` from the admin node and execute `sudo` (including itself)


## Admin Provisioning

Pigsty requires an **administrative user** that can **SSH into other nodes** from the admin node and execute `sudo` commands.

- [x] can use this user on the admin node
- [x] can SSH to all managed nodes (including itself) with this user
- [x] can execute the sudo command after logging in to all managed nodes (including itself)
- [x] Admin user is not `postgres` or `{{ dbsu }}` (using DBSU as admin is a security risk)
- [x] ssh login password-free, sudo command password-free (or you know how to enter it manually via `-k`,`-K`)

> `ssh` and `sudo` privileges are REQUIRED for running playbooks.
>
> Pigsty strongly recommends configuring SSH **passwordless login** for the admin user and passwordless `sudo` for the admin user on all nodes.

It's highly recommended to setup admin user during vm provisioning phase.
It's trivial to have such a user when you got a node.

If you can only use the ssh password and sudo password, then you must add the additional parameters `--ask-pass|-k` and `--ask-become-pass|-K` to all script executions and enter the ssh password and sudo password when prompted. You can create a **dedicated administrator user** using the current user using the function to create an administrator user in [`pgsql.yml`](p-pgsql), and the following parameters are used to create the default administrator user.

* [`node_admin_setup`](v-node.md#node_admin_setup)
* [`node_admin_uid`](v-node.md#node_admin_uid)
* [`node_admin_username`](v-node.md#node_admin_username)
* [`node_admin_pks`](v-node.md#node_admin_pks)

```bash
. /pgsql.yml -t node_admin -l <target machine> --ask-pass --ask-become-pass
```

The default admin user created is `dba` (uid=88), please do not use `postgres` or `dbsu` as admin user.

The default user for the sandbox environment, `vagrant`, has been configured with password-free login and password-free sudo by default, and you can use vagrant to log in to all database nodes from the host or sandbox admin node.

### Manual configuration of SSH and SUDO

Manual configuration of SSH password-free login can be achieved by `ssh-keygen` and `ssh-copy-id`, please refer to the related documentation.

Manually configuring password-free `sudo` for a user can be done by adding the following entry to `/etc/sudoers.d/<username>` file

```bash
%<username> ALL=(ALL) NOPASSWD: ALL
```

Note that replacing `<username>` with the name of the administrator you are using is sufficient.







## Software Provisioning

In order to run Pigsty, you need to have the following software.

- [x] [Pigsty Source Code](#pigsty-source-code)
- [x] [Pigsty Offline Package](#pigsty-offline-package) (OPTIONAL)

To run the Pigsty sandbox on your own laptop, you will also need to download and install on the host computer.

- [x] [Vagrant](#vagrant): virtual machine hosting orchestration software (cross-platform, free)
- [x] [Virtualbox](#virtualbox): virtual machine software (cross-platform, open source and free)



### Pigsty Source Code

Users should get the Pigsty project source code on the admin node, usually unpacked to the admin user HOME directory.

```bash
git clone https://github.com/Vonng/pigsty && cd pigsty # Get the latest code 
```

If you don't have `git`, you can use `curl` to download it. It is recommended to use this method to download a fixed version: ``v1.0.0`` is the specific version number.

```bash
curl -SL https://github.com/Vonng/pigsty/releases/download/v1.0.0/pigsty.tgz -o ~/pigsty.tgz && tar -xf pigsty.tgz # Download a specific version of the code (recommended)
```

Or download the source code from Baidu.com: https://pan.baidu.com/s/1DZIa9X2jAxx69Zj-aRHoaw (extraction code: `8su9`)



### Pigsty offline package

The offline package packs all software dependencies and is about 1GB in size. offline installation is possible when no internet access is available.

The offline package is **optional**. In case of good network conditions (scientific Internet access), you can choose to skip the offline installation package and download the relevant software directly from the original upstream (about 1 GB).

The official offline package is based on CentOS 7.8.2003 operating system environment. If you are using an operating system other than this version and have problems with dependency errors, please refer to the documentation [Making an offline installer](t-offline.md) on a machine with Internet (Github) access with the same operating system.

Offline packages can be downloaded from the Github Release page, ``v1.0.0`` is the specific version number, the package should be consistent with the source code version.

```bash
curl -SL https://github.com/Vonng/pigsty/releases/download/v1.0.0/pkg.tgz -o /tmp/pkg.tgz
```

Baidu.com also provides ``pkg.tgz`` for download from the same address as the Pigsty source code.

Offline packages are usually placed in the `/tmp/pkg.tgz` path of all administrative nodes.




### Vagrant

Usually, in order to test a system such as a "database cluster", users need to prepare several virtual machines beforehand. Although cloud services are already very convenient, local virtual machine access is usually easier, more responsive and less expensive than cloud virtual machine access. Local VM configuration is relatively cumbersome, and [**Vagrant**](https://www.vagrantup.com/) can solve this problem.

Pigsty users don't need to understand how vagrant works, they just need to know that vagrant can simply and quickly pull up several virtual machines on a laptop, PC or Mac according to the user's needs. All the user needs to accomplish is to express their virtual machine requirements in the form of a **vagrant configuration file**.

[https://github.com/Vonng/pigsty/blob/master/vagrant/Vagrantfile](https://github.com/Vonng/pigsty/blob/master/vagrant/Vagrantfile) A sample Vagrantfile is provided.

This is the Vagrantfile used by Pigsty sandbox, defining four virtual machines, including a 2-core/4GB central control/**meta node** `meta` and three 1-core/1GB **database nodes** `node-1, node-2, node3`.

When using the sandbox through shortcuts like `make up` , `make new`, `make demo`, only a single meta node `meta` will be used by default. Whereas `make up4`, `make new4`, `make demo4` will use all the virtual machines. Here the `N` value defines the number of additional database nodes (3). If your machine is under-configured, then consider using a smaller `N` value to reduce the number of database nodes. Users can also modify the number of CPU cores and memory resources per machine, etc., as described in the comments in the configuration file. Please refer to the Vagrant and Virtualbox documentation for more detailed customization.

```ruby
IMAGE_NAME = "centos/7"
N=3       # number of extra database nodes, can be 0

Vagrant.configure("2") do |config|
    config.vm.box = IMAGE_NAME
    config.vm.box_check_update = false
    config.ssh.insert_key = false

    # meta (admin) node
    config.vm.define "meta", primary: true do |meta|   # default ssh alias for admin node is `meta`
        meta.vm.hostname = "meta"
        meta.vm.network "private_network", ip: "10.10.10.10"
        meta.vm.provider "virtualbox" do |v|
            v.linked_clone = true
            v.customize [
                    "modifyvm", :id,
                    "--memory", 4096, "--cpus", "2",   # default mem and cpu for meta node: 2C/4GB by default
                    "--nictype1", "virtio", "--nictype2", "virtio",
                    "--hwv·irtex", "on", "--ioapic", "on", "--rtcuseutc", "on", "--vtxvpid", "on", "--largepages", "on"
                ]
        end
        meta.vm.provision "shell", path: "provision.sh"
    end

    # Init N database nodes
    (1..N).each do |i|
        config.vm.define "node-#{i}" do |node|      # default ssh alias for database nodes are `node-{1,2,3}`
            node.vm.box = IMAGE_NAME
            node.vm.network "private_network", ip: "10.10.10.#{i + 10}"
            node.vm.hostname = "node-#{i}"
            node.vm.provider "virtualbox" do |v|
                v.linked_clone = true
                v.customize [
                        "modifyvm", :id,
                        "--memory", 2048, "--cpus", "1",   # resource for database node: 1C/2GB by default
                        "--nictype1", "virtio", "--nictype2", "virtio",
                        "--hwvirtex", "on", "--ioapic", "on", "--rtcuseutc", "on", "--vtxvpid", "on", "--largepages", "on"
                    ]
            end
            node.vm.provision "shell", path: "provision.sh"
        end
    end
end
```

The `vagrant` binary will call Virtualbox by default to complete the creation of the local VMs as defined in the Vagrantfile. Go to the `vagrant` directory in the Pigsty root directory and execute `vagrant up` to pull up all four virtual machines. The [`Makefile`](https://github.com/Vonng/pigsty/blob/master/Makefile#L365) provides a number of wrappers for the original `vagrant` commands.

The default virtual machine image used by the sandbox environment is `IMAGE_NAME = "centos/7"`. The first time it is executed, the virtualbox image of `centos 7.8.2003` will be downloaded from the Internet and will be cloned directly when a new virtual machine is created.



### Virtualbox

[Virtualbox](https://www.virtualbox.org/) is an open source, free cross-platform virtual machine software. Installing Virtualbox on MacOS is very easy and similar on other operating systems.

```bash
brew install virtualbox
```

After installing Virtualbox, you may need to reboot your computer to load the virtual machine kernel module.



### MacOS Quick Install

On MacOS, you can download and install Vagrant and Virtualbox via homebrew with the following shortcuts.

````bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" # Install Homebrew
brew install vagrant virtualbox # Install Vagrant and Virtualbox on the MacOS host machine
```

Cloning the project to the host machine and going into the `pigsty` directory and executing `make deps` has the same effect.

