# Preparation

How to prepare the resources required for Pigsty deployment.

* [Node Provisioning](#node-provisioning)
* [Meta Provisioning](#meta-node-provisioning)
* [Admin Provisioning](#admin-provisioning)
* [Software Provisioning](#software-provisioning)
  * [Pigsty source code](#pigsty-source-code)
  * [Pigsty offline package](#pigsty-offline-package)
  * [Vagrant](#vagrant) (sandbox)
  * [Virtualbox](#virtualbox) (sandbox)



## Node Provisioning

Before deploying Pigsty, the user needs to prepare machine node resources with arbitrary [database nodes](c-nodes.md#node), including at least one [meta node](c-nodes.md#meta-node).

The [nodes](c-nodes.md#node) can use any nodes: bare metals, local VMs, cloud VMs, containers, etc...
only if the following conditions are met:

- [x] Processor architecture: x86_64
- [x] Hardware specifications: 1C/1GB at least
- [x] Operating System: CentOS 7.8.2003 (or RHEL7 equivalent)
- [x] [Admin User](#Admin-Provisioning) can `ssh` to the **meta node** and execute `sudo` commands.

One node is sufficient if you are using Pigsty as a battery-included PostgreSQL database instance. If you also plan to use Pigsty as a control for more nodes/databases, you can prepare more nodes for backup.




----------------

## Meta Node Provisioning

Pigsty requires [meta nodes](c-nodes.md#meta-node) as the admin controller of the entire environment and provides [infra](c-infra.md#infrastructure) services.

The minimum number of **meta-nodes** is 1. Pigsty's infra is deployed as **replicas** on multiple meta nodes, except for DCS (Consul/Etcd), which exists as Quorum.

Pigsty clusters require the use of [DCS](v-infra.md#dcs) for HA functionality. You can use DCS clusters that are automatically deployed on meta nodes or use external DCS clusters. Using three meta nodes is recommended in **large-scale production environments** if you do not have a dedicated external DCS cluster.

Users should ensure that they can **log in** to the meta node and log in to other nodes via `ssh` with `sudo` or `root` access from the meta node using the [admin user](#admin-provisioning). Users should ensure **access to port 80** of the meta node to access the Pigsty user interface.

- [x] Number of meta nodes: odd number, at least 1
- [x] Ability to log in to the meta node using the admin user
- [x] Ability to access port 80 of the meta node via browser
- [x] **Admin users** can log in to the database node remotely `ssh` from the meta node and execute `sudo` (including itself).



## Admin Provisioning

> Pigsty requires an **admin user** to **SSH into other nodes** from the meta node and execute `sudo` commands.

- [x] Can use this user on the meta node
- [x] Can SSH to all managed nodes (including itself) with this user
- [x] Can execute the sudo command after logging in to all managed nodes (including itself)
- [x] Admin user is not `postgres` or `{{ dbsu }}` (using DBSU as admin is a security risk)
- [x] ssh login password-free, sudo command password-free (or you know how to enter it manually via `-k`,`-K`)

The admin user you are using **must** have `ssh` and `sudo` privileges for all nodes **when performing deployments and changes**. Password-free is not required. You can always pass in ssh and sudo passwords via the `-k|-K` when executing the playbook or use another user to run the playbook via `-e`[`ansible_host`](v-infra.md#connect)`=<another_user>`. However, Pigsty strongly recommends configuring SSH **password-free login** with password-free `sudo` for the admin user.

**Pigsty recommends that the creation of admin users, privilege config, and key distribution be done in the Provisioning phase of the VM**. For a production environment, the machine should be delivered with such a user configured with password-free remote SSH login and performing password-free sudo.

The Pigsty playbook [`nodes`](p-nodes.md#nodes) can be used to create admin users on nodes. In the Bootstrap phase, as long as you have an SSH login with SUDO access, you can use it to execute the Ansible playbook even without a password. Please refer to [Nodes: Create an admin user](v-nodes.md#NODE_ADMIN) for more details.


### Manual config of SSH and SUDO

Manual config of SSH password-free login can be achieved by `ssh-keygen` and `ssh-copy-id`. Please refer to the related doc.

Manually configuring password-free `sudo` for a user can be done by adding the following entry to the `/etc/sudoers.d/<username>` file. Note that replacing `<username>` with the name of the administrator.

```bash
%<username> ALL=(ALL) NOPASSWD: ALL
```



----------------

## Software Provisioning

To run Pigsty, you need to have the following software.

- [x] [Pigsty Source Code](#pigsty-source-code)
- [x] [Pigsty Offline Package](#pigsty-offline-package) (OPTIONAL)

To run the Pigsty sandbox on your own laptop, you will also need to download and install it on the host.

- [x] [Vagrant](#vagrant): VM hosting orchestration software (cross-platform, free)
- [x] [Virtualbox](#virtualbox): VM software (cross-platform, open-source, and free)

If you wish to run Pigsty sandbox on a cloud vendor server, you must. The. Use download and install [Terraform](https://www.terraform.io/) locally.



----------------

### Pigsty Source Code

Users should get the Pigsty project source on the meta node, usually unpacked to the admin user `HOME` dir.

```bash
# It is recommended to use this command to download the pigsty.tgz source, the script will distinguish between inside and outside the wall, use CDN to accelerate the download in mainland
bash -c "$(curl -fsSL http://download.pigsty.cc/get)"  # get latest pigsty source
```

You can also download the source tarball in other ways.

```bash
# https://github.com/Vonng/pigsty/releases/download/v1.5.0/pigsty.tgz   # Github Release 
# http://download.pigsty.cc/v1.5.0/pigsty.tgz                           # China CDN
# https://pan.baidu.com/s/1DZIa9X2jAxx69Zj-aRHoaw?pwd=8su9              # Baidu Cloud Download
# git clone https://github.com/Vonng/pigsty                             # Get the latest code Master branch (not recommended)
```

Also, the [`download`](https://github.com/Vonng/pigsty/blob/master/download) script in the root of the pigsty project can be used to download the source.

```bash
./download pigsty.tgz    # Download the current version of pigsty.tgz from Github/CDN to /tmp/pigsty.tgz
./download pigsty        # Download the current version of pigsty.tgz from Github/CDN and extract it to ~/pigsty (skip it if it already exists)
```



### Pigsty Offline Package

The offline package packs all software packages, is about 1GB, and is optional. If `/tmp/pkg.tgz` already exists during a complete installation of Pigsty on the meta node, Pigsty will build the local source directly with that package. Otherwise, Pigsty will download all packages from the network.

The official offline package is made based on CentOS 7.8.2003 OS. Please refer to the [FAQ](s-faq.md) to see all the dependency packages and install them directly from the upstream. Or visit Github on a machine with the same OS, [make an offline package](t-offline.md), and copy it to a network isolated environment.

You can download the offline package in advance on the meta node where Pigsty is to be installed (just on a meta node to `/tmp/pkg.tgz`).

```bash
curl https://github.com/Vonng/pigsty/releases/download/v1.5.0/pkg.tgz -o /tmp/pkg.tgz   # Github Release，Most authoritative  
curl http://download.pigsty.cc/v1.5.0/pkg.tgz -o /tmp/pkg.tgz                      # Download with CDN in China
```

Also, the [`download`](https://github.com/Vonng/pigsty/bl/master/download) script in the root of the pigsty project can be used to download offline packages.

```bash
./download pkg.tgz    # Download the current version of pkg.tgz from Github/CDN to /tmp/pkg.tgz
./download pkg        # Download the current version of pkg.tgz from Github/CDN and extract it to /www/pigsty
```

Finally, Baidu Web-Disk also provides an offline package for download: https://pan.baidu.com/s/1DZIa9X2jAxx69Zj-aRHoaw?pwd=8su9






### Vagrant

Local VM configuration is relatively cumbersome, and [**Vagrant**](https://www.vagrantup.com/) can solve this problem.

Vagrant makes it fast and straightforward to pull several VMs on a laptop, PC, or Mac, depending on the user's needs. Users need to express their requirements for VMs in a **vagrant configuration file**.

We have provided a sample Vagrant configuration file. [https://github.com/Vonng/pigsty/blob/master/vagrant/Vagrantfile](https://github.com/Vonng/pigsty/blob/master/vagrant/Vagrantfile)

In the Vagrant configuration file, four VMs, including a 2-core/4GB central control/meta node `meta` and three 1-core/1GB **database nodes** `node-1, node-2, node3`.

When using the sandbox via shortcuts like `make up`, `make new`, and `make demo`, only one meta node `meta` is used by default. And `make up4`, `make new4`, and `make demo4` use all the VMs. The `N` value defines the number of additional database nodes. The user can also modify the number of CPU cores and memory resources per machine, etc.

<details><summary>Vagrantfile Example</summary>

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

</details>

The `vagrant` binary will invoke Virtualbox by default to complete the creation of the local VMs defined in the Vagrant configuration file. Go to `vagrant` in the Pigsty root directory and execute `vagrant up` to bring up the four VMs. The [`Makefile`](https://github.com/Vonng/pigsty/blob/master/Makefile#L365) provides some wrappers for the original `vagrant` command.

The default VM image used by the sandbox is `IMAGE_NAME = "centos/7"`.



### Virtualbox

[Virtualbox](https://www.virtualbox.org/) is an open-source and free cross-platform VM software. Installing Virtualbox on MacOS is very simple: `brew install virtualbox`, and is similar on other OS.

After installing Virtualbox, you may need to reboot your computer to load the VM kernel module. Pigsty requires an x86_64 runtime environment, and Macbooks with M1 chips installed may not be able to run Virtualbox properly.
