# Preparation

How to prepare the resources required for Pigsty deployment.

* [Node Provisioning](#node-provisioning)
* [Meta Node Provisioning](#meta-provisioning)
* [Admin User Provisioning](#admin-provisioning)
* [Software Provisioning](#software-provisioning)
  * [Pigsty source code](#pigsty-source-code)
  * [Pigsty offline package](#pigsty-offline-package)
  * [Vagrant](#vagrant) (sandbox)
  * [Virtualbox](#virtualbox) (sandbox)



## Node Provisioning

Before deploying Pigsty, the user needs to prepare machine node resources,
including at least one [meta node](c-arch.md#meta-node), with arbitrary [database nodes](c-arch.md#database-node).

The [nodes](c-arch.md#database-node) can use any type of nodes: bare metals, local VMS, cloud VMS, containers, etc...
only if the following conditions are met:

- [x] Processor architecture: x86_64
- [x] Hardware specifications: 1C/1GB at least
- [x] Operating System: CentOS 7.8.2003 (or RHEL7 equivalent)
- [x] [Admin User](#Admin-Provisioning) can `ssh` to the meta node and execute `sudo` commands.

If you plan to use Pigsty as a battery-included PostgreSQL database instance, one node will suffice. If you also plan to use Pigsty as a control for more hosts/databases, you can prepare more nodes for backup.




----------------

## Meta Node Provisioning

Pigsty requires a [meta node](c-arch.md#meta-node) as the admin controller of the entire environment and provides [infrastructure](c-arch.md#infrastructure) services.

The minimum number of **meta nodes** is 1. The sandbox environment uses 1 meta node by default. Pigsty's infrastructure is deployed as **replicas** on multiple meta nodes, except for DCS (Consul/Etcd), which exists as Quorum.

Pigsty's database clusters require the use of [DCS](v-infra.md#dcs) for high availability functionality. You can use a DCS cluster that is automatically deployed on a meta node or use an external DCS cluster. In **large-scale production envs**, if you do not have a dedicated external DCS cluster, it is recommended to use 3 meta nodes to fully guarantee the availability of DCS services.

Users should ensure that they can **log in** to the meta node and can log in to other database nodes via `ssh` with `sudo` or `root` privileges from the meta node using the [admin user](#admin-provisioning). Users should ensure that they have direct or indirect **access to port 80** of the admin node to access the user interface provided by Pigsty.

- [x] Number of meta nodes: odd number, at least 1
- [x] Ability to log in to the meta node using the admin user
- [x] Ability to access port 80 of the meta node via browser (directly or indirectly)
- [x] **admin user** can log in to the database node remotely `ssh` from the admin node and execute `sudo` (including itself)



## Admin Provisioning

> Pigsty requires an **admin user** that can **SSH into other nodes** from the admin node and execute `sudo` commands.

- [x] can use this user on the admin node
- [x] can SSH to all managed nodes (including itself) with this user
- [x] can execute the sudo command after logging in to all managed nodes (including itself)
- [x] Admin user is not `postgres` or `{{ dbsu }}` (using DBSU as admin is a security risk)
- [x] ssh login password-free, sudo command password-free (or you know how to enter it manually via `-k`,`-K`)

**When performing deployments and changes**, the admin user you are using **must** have `ssh` and `sudo` privileges for all nodes. Password free is not required, you can always pass in ssh and sudo passwords via the `-k|-K` parameter when executing the playbook, or even use another user to execute the playbook via `-e`[`ansible_host`](v-infra.md#connect)`=<another_user>`. However, Pigsty strongly recommends configuring SSH **passwordless login** with passwordless `sudo` for the admin user.

**Pigsty recommends that the creation of admin users, privilege config, and key distribution be done in the Provisioning phase of the virtual machine** as part of the machine resource delivery content. For production envs, the machine should be delivered with such a user already configured with unencrypted remote SSH login and performing unencrypted sudo. This is usually possible with most cloud platforms and ops systems.

If you can only use the ssh password and sudo password, then you must add the additional parameters `--ask-pass|-k` and `--ask-become-pass|-K` to all script executions and enter the ssh password and sudo password when prompted. You can create a **dedicated admin user** using the current user using the function to create an admin user in [`pgsql.yml`](p-pgsql.md#pgsql), and the following parameters are used to create the default admin user.


### Manual config of SSH and SUDO

Manual config of SSH password-free login can be achieved by `ssh-keygen` and `ssh-copy-id`, please refer to the related doc.

Manually configuring password-free `sudo` for a user can be done by adding the following entry to `/etc/sudoers.d/<username>` file.Note that replacing `<username>` with the name of the administrator you are using is sufficient.

```bash
%<username> ALL=(ALL) NOPASSWD: ALL
```

Note that replacing `<username>` with the name of the admin you are using is sufficient.



----------------

## Software Provisioning

In order to run Pigsty, you need to have the following software.

- [x] [Pigsty Source Code](#pigsty-source-code)
- [x] [Pigsty Offline Package](#pigsty-offline-package) (OPTIONAL)

To run the Pigsty sandbox on your own laptop, you will also need to download and install it on the host computer.

- [x] [Vagrant](#vagrant): virtual machine hosting orchestration software (cross-platform, free)
- [x] [Virtualbox](#virtualbox): virtual machine software (cross-platform, open-source, and free)

If you wish to run Pigsty sandbox on a cloud vendor server, you will need to download and install [Terraform](https://www.terraform.io/) locally.



----------------

### Pigsty Source Code

Users should get the Pigsty project source code on the admin node, usually unpacked to the admin user `HOME` dir.

```bash
# It is recommended to use this command to download pigsty.tgz source package, the script will distinguish between inside and outside the wall, use CDN to accelerate the download in mainland
bash -c "$(curl -fsSL http://download.pigsty.cc/get)"  # get latest pigsty source
```

You can also download the source tarball in other ways.

```bash
# https://github.com/Vonng/pigsty/releases/download/v1.4.0/pigsty.tgz   # Github Release 
# http://download.pigsty.cc/v1.4.0/pigsty.tgz                           # China CDN
# https://pan.baidu.com/s/1DZIa9X2jAxx69Zj-aRHoaw?pwd=8su9              # Baidu Cloud Download
# git clone https://github.com/Vonng/pigsty                             # Get the latest code Master branch (not recommended)
```

Also, the [`download`](https://github.com/Vonng/pigsty/blob/master/download) script in the root of the pigsty project can be used to download the source code.

```bash
./download pigsty.tgz    # Download the current version of pigsty.tgz from Github/CDN to /tmp/pigsty.tgz
./download pigsty        # Download the current version of pigsty.tgz from Github/CDN and extract it to ~/pigsty (skip it if it already exists)
```


It's recommend to get latest stable pigsty with following command

```bash
bash -c "$(curl -fsSL http://download.pigsty.cc/get)" 
```

You can download pigsty source code & software packages directly via `curl` from github release: 

```bash
https://github.com/Vonng/pigsty/releases/download/v1.4.0/pigsty.tgz   # Github Release
```

You can also download pigsty source again with the [`download`](https://github.com/Vonng/pigsty/blob/master/download) script:

```bash
./download pigsty.tgz    # Get latest stable pigsty.tgz to /tmp/pigsty.tgz
./download pigsty        # Get pigsty.tgz and release to ~/pigsty (skip if already eixsts)
```



### Pigsty Offline Package

The offline package packs all software dependencies and is about 1GB in size and is optional. If `/tmp/pkg.tgz` already exists during a full installation of Pigsty on the meta node, Pigsty will build the local source directly with that package, otherwise, Pigsty will download all dependent packages from the network.

The official offline package is based on CentOS 7.8.2003 operating system environment, if you are using an operating system other than this version and have problems with dependency errors, please refer to the [FAQ](s-faq.md) to install directly from the original upstream. Or [make an offline installer](t-offline.md) on a machine with the same OS with Internet (Github) access and then copy it to a network isolated environment for use.

You can download the offline package in advance on the meta node where Pigsty is to be installed (just on a single meta node to `/tmp/pkg.tgz`) using the following command.

```bash
curl https://github.com/Vonng/pigsty/releases/download/v1.4.0/pkg.tgz -o /tmp/pkg.tgz   # Github Release，Most authoritative 
curl http://download.pigsty.cc/v1.4.0/pkg.tgz -o /tmp/pkg.tgz                           # Or download with CDN in mainland China

Also, the [`download`](https://github.com/Vonng/pigsty/bl/master/download) script in the root of the pigsty project can be used to download offline packages.

```bash
./download pkg.tgz    # Download the current version of pkg.tgz from Github/CDN to /tmp/pkg.tgz
./download pkg        # Download the current version of pkg.tgz from Github/CDN and extract it to /www/pigsty
```

Finally, Baidu.com also provides offline package resources for download: https://pan.baidu.com/s/1DZIa9X2jAxx69Zj-aRHoaw?pwd=8su9.




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

