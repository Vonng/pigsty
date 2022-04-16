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
- [x] [Admin user](#管理节点置备) can `ssh` to the meta node and execute `sudo` commands.

If you plan to use Pigsty as a battery-included PostgreSQL database instance, one node will suffice. If you also plan to use Pigsty as a control for more hosts/databases, you can prepare more nodes for backup.




----------------

## Meta Node Provisioning

Pigsty requires a [meta node](c-arch.md#meta-node) as the admin controller of the entire environment and provides [infrastructure](c-arch.md#infrastructure) services.

The minimum number of **meta nodes** is 1. The sandbox environment uses 1 meta node by default. Pigsty's infrastructure is deployed as **replicas** on multiple meta nodes, except for DCS (Consul/Etcd), which exists as Quorum.

Pigsty's database clusters require the use of [DCS](v-infra.md#dcs) for high availability functionality. You can use a DCS cluster that is automatically deployed on a meta node or use an external DCS cluster. In **large-scale production envs**, if you do not have a dedicated external DCS cluster, it is recommended to use 3 meta nodes to fully guarantee the availability of DCS services.

Users should ensure that they can **log in** to the meta node and can log in to other database nodes via `ssh` with `sudo` or `root` privileges from the meta node using the [admin user](#admin user provisioned). Users should ensure that they have direct or indirect **access to port 80** of the admin node to access the user interface provided by Pigsty.

- [x] Number of meta nodes: odd number, at least 1
- [x] Ability to log in to the meta node using the administrator user
- [x] Ability to access port 80 of the meta node via browser (directly or indirectly)
- [x] **admin user** can log in to the database node remotely `ssh` from the admin node and execute `sudo` (including itself)



----------------

## Admin User Provisioning

Pigsty requires an **admin user** that can **SSH into other nodes** from the admin node and execute `sudo` commands.

- [x] can use this user on the admin node
- [x] can SSH to all managed nodes (including itself) with this user
- [x] can execute the sudo command after logging in to all managed nodes (including itself)
- [x] Admin user is not `postgres` or `{{ dbsu }}` (using DBSU as admin is a security risk)
- [x] ssh login password-free, sudo command password-free (or you know how to enter it manually via `-k`,`-K`)

**When performing deployments and changes**, the admin user you are using **must** have `ssh` and `sudo` privileges for all nodes. Password free is not required, you can always pass in ssh and sudo passwords via the `-k|-K` parameter when executing the playbook, or even use another user to execute the playbook via `-e`[`ansible_host`](v-infra.md#connect)`=<another_user>`. However, Pigsty strongly recommends configuring SSH **passwordless login** with passwordless `sudo` for the admin user.

**Pigsty recommends that the creation of admin users, privilege config, and key distribution be done in the Provisioning phase of the virtual machine** as part of the machine resource delivery content. For production envs, the machine should be delivered with such a user already configured with unencrypted remote SSH login and performing unencrypted sudo. This is usually possible with most cloud platforms and ops systems.

Pigsty playbook [`nodes`](p-nodes.md#nodes) can create an administrative user on the node, but this involves a chicken or egg question: in order to execute Ansible playbooks on a remote node, an admin user is required. In order to create a dedicated admin user, the Ansible playbook needs to be executed on the remote node. As a compromise to the Bootstrap phase, as long as you have SSH login and SUDO access, you can use it to execute Ansible playbooks even without a password, see  [Nodes: Creating an admin user](v-nodes.md#创建管理用户) for details.

### Manual config of SSH and SUDO

Manual config of SSH password-free login can be achieved by `ssh-keygen` and `ssh-copy-id`, please refer to the related doc.

Manually configuring password-free `sudo` for a user can be done by adding the following entry to `/etc/sudoers.d/<username>` file.Note that replacing `<username>` with the name of the administrator you are using is sufficient.

```bash
%<username> ALL=(ALL) NOPASSWD: ALL
```




----------------

## Software Provisioning

In order to run Pigsty, you need to have the following software.

- [x] [Pigsty Source Code](#pigsty-source-code)
- [x] [Pigsty Offline Package](#pigsty-offline-package) (OPTIONAL)

To run the Pigsty sandbox on your own laptop, you will also need to download and install it on the host computer.

- [x] [Vagrant](#vagrant): virtual machine hosting orchestration software (cross-platform, free)
- [x] [Virtualbox](#virtualbox): virtual machine software (cross-platform, open-source, and free)

If you wish to run Pigsty sandbox on a cloud vendor server, you will need to download and install [Terraform](#Terraform) locally.



----------------

## Pigsty Source Code

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





### Pigsty offline package

The offline package packs all software dependencies and is about 1GB in size and is optional. If `/tmp/pkg.tgz` already exists during a full installation of Pigsty on the meta node, Pigsty will build the local source directly with that package, otherwise, Pigsty will download all dependent packages from the network.

The official offline package is based on CentOS 7.8.2003 operating system environment, if you are using an operating system other than this version and have problems with dependency errors, please refer to the [FAQ](s-faq.md) to install directly from the original upstream. Or [make an offline installer](t-offline.md) on a machine with the same OS with Internet (Github) access and then copy it to a network isolated environment for use.

You can download the offline package in advance on the meta node where Pigsty is to be installed (just on a single meta node to `/tmp/pkg.tgz`) using the following command.

```bash
curl https://github.com/Vonng/pigsty/releases/download/v1.4.0/pkg.tgz -o /tmp/pkg.tgz   # Github Release，Most authoritative 
curl http://download.pigsty.cc/v1.4.0/pkg.tgz -o /tmp/pkg.tgz                           # Or download with CDN in mainland China
```

Also, the [`download`](https://github.com/Vonng/pigsty/bl/master/download) script in the root of the pigsty project can be used to download offline packages.

```bash
./download pkg.tgz    # Download the current version of pkg.tgz from Github/CDN to /tmp/pkg.tgz
./download pkg        # Download the current version of pkg.tgz from Github/CDN and extract it to /www/pigsty
```

Finally, Baidu.com also provides offline package resources for download: https://pan.baidu.com/s/1DZIa9X2jAxx69Zj-aRHoaw?pwd=8su9.
