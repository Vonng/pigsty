# Quick Start

This document shows how to pull up a local sandbox environment on your laptop.



> ### Notice
>
> **Pigsty only works on CentOS 7**, bare metal or virtual machine.



## TL;DR

If you already have [vagrant](https://www.vagrantup.com/) and [virtualbox](https://www.virtualbox.org/) properly installed. Just run following commands:

```bash
# run under pigsty home dir
make up          # pull up all vagrant nodes
make ssh         # setup vagrant ssh access
make init        # init infrastructure and databaes clusters
sudo make dns    # write static DNS record to your host (sudo required)
make mon-view    # monitoring system home page (default: admin:admin) 
```

> Verified version: MacOS 10.15, Vagrant 2.2.10, Virtualbox 6.1.14, CentOS 7.8





## Preparation

**System Requirement**

* CentOS 7 / Red Hat 7 / Oracle Linux 7
* CentOS 7.6/7.8 is highly recommened (which are fully tested under minimal installtion)

**Minimal setup**

* Self-contained single node, singleton database `pg-meta`
* Minimal requirement: 2 CPU Core & 2 GB RAM

**Standard setup ( TINY mode, vagrant demo)**

* 4 Node, including single meta node, singleton databaes cluster `pg-meta` and 3-instances database cluster `pg-test`
* Recommend Spec: 2Core/2GB for meta controller node, 1Core/1GB for database node 

**Production setup (OLTP/OLAP/CRIT mode)**

* 200~1000 nodes,  3~5 meta nodes

> Verified environment: Dell R740 / 64 Core / 400GB Mem / 3TB PCI-E SSD x 200

If you wish to run pigsty on virtual machine in your laptop. Consider using vagrant and virtualbox. Which enables you create and destroy virtual machine easily. Check [Vagrant Provision](vagrant-provision.md) for more information. Other virtual machine solution such as vmware also works.



## Get Started

### Step 1: Prepare

* Prepare nodes, bare metal or virtual machine.

  > Currently only CentOS 7 is supported and fully tested.
  >
  > You will need one node for minial setup, and four nodes for a complete demonstration. 

* Pick one node as **meta node**, Which is controller of entire system.

  > Meta node is controller of the system. Which will run essential service such as Nginx, Yum Repo, DNS Server, NTP Server, Consul Server, Prometheus, AlterManager, Grafana, and other components. It it recommended to have 1 meta node in sandbox/dev environment, and 3 ~ 5 meta nodes in production environment.

* Create admin user on these nodes which has **nopassword sudo** privilege.

  ```bash
  echo "<username> ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/<username>
  ```

* Setup admin user **SSH nopass access** from **meta** node. 

  ```bash
  ssh-copy-id <address>
  ```

  > You could execute playbooks on your **host** machine directly instead of **meta** node when running pigsty inside virtual machines.  It is convenient for development and testing. 

* Install [Ansible](https://docs.ansible.com/) on meta node (or your host machine if you prefer running playbooks there)

  ```bash
  yum install ansible     # centos
  brew install ansible    # macos
  ```

  > If your **meta** node does not have Internet access. You could perform an [Offline Installation](offline-installation.md). Or figure out your own way installing ansible there.

* Clone this repo to **meta** node

  ```bash
  git clone https://github.com/vonng/pigsty && cd pigsty 
  ```

* **[Optional]**: download pre-packaged offline installation resource tarball to `${PIGSTY_HOME}/files/pkg.tgz`

  > If you happen to have exactly same OS (e.g CentOS 7.8 [pkg](https://github.com/Vonng/pigsty/releases/download/v0.3.0/pkg.tgz)). You could download it and put it there. So the first-time provision will be extremely fast.



### Step 2: Configuration

[Configuration](configuration.md) is essential to pigsty.

 [`dev.yml`](../conf/dev.yml) is the Configuration file for vagrant sandbox environment. And `conf/all.yml` is the default configuration file path, which is a soft link to `conf/dev.yml` by default.

You can leave most parameters intact, only small portion of parameters need adjustment such as cluster inventory definition. A typical cluster definition only require 3 variables to work: `pg_cluster` , `pg_role`, and `pg_seq`. Check configuration guide for more detail.

```yaml
    #-----------------------------
    # cluster: pg-test
    #-----------------------------
    pg-test: # define cluster named 'pg-test'

      # - cluster configs - #
      vars:
        # basic settings
        pg_cluster: pg-test                 # define actual cluster name
        pg_version: 13                      # define installed pgsql version
        node_tune: tiny                     # tune node into oltp|olap|crit|tiny mode
        pg_conf: tiny.yml                   # tune pgsql into oltp/olap/crit/tiny mode

        # bootstrap template
        pg_init: initdb.sh                  # bootstrap postgres cluster with initdb.sh
        pg_default_username: test           # default business username
        pg_default_password: test           # default business password
        pg_default_database: test           # default database name

        # vip settings
        vip_enabled: true                   # enable/disable vip (require members in same LAN)
        vip_address: 10.10.10.3             # virtual ip address
        vip_cidrmask: 8                     # cidr network mask length
        vip_interface: eth1                 # interface to add virtual ip


      # - cluster members - #
      hosts:
        10.10.10.11:
          ansible_host: node-1            # comment this if not access via ssh alias
          pg_role: primary                # initial role: primary & replica
          pg_seq: 1                       # instance sequence among cluster

        10.10.10.12:
          ansible_host: node-2            # comment this if not access via ssh alias
          pg_role: replica                # initial role: primary & replica
          pg_seq: 2                       # instance sequence among cluster

        10.10.10.13:
          ansible_host: node-3            # comment this if not access via ssh alias
          pg_role: replica                # initial role: primary & replica
          pg_seq: 3                       # instance sequence among cluster


```



### Step 3: Provision

It is straight forward to materialize that configuration about infrastructure & database cluster:

```bash
./infra.yml    # init infrastructure according to config
./initdb.yml   # init database cluster according to config
```

It may take around 5~30min to download all necessary rpm packages from internet according to your network condition. (Only for the first time, you could cache downloaded packages by running `make cache`)

> (Consider using other upstream yum repo if not applicable , check `conf/all.yml` , `all.vars.repo_upstreams`)



### Step 4: Explore

Start exploring Pigsty.

* Main Page: http://pigsty or `http://<meta-ip-address>`
* Grafana: http://g.pigsty   or `http://<meta-ip-address>:3000` (default credential: admin:admin)

* Consul: http://c.pigsty   or `http://<meta-ip-address>:8500` (consul only listen on localhost)

* Prometheus: http://p.pigsty   or `http://<meta-ip-address>:9090`

* AlertManager: http://a.pigsty   or `http://<meta-ip-address>:9093`

You may need to write [DNS](../files/dns) to your host before accessing pigsty via domain names.

```bash
sudo make dns				   # write local DNS record to your /etc/hosts, sudo required
```

 



# 快速开始

本节介绍如何快速拉起Pigsty沙箱环境，更多信息请参阅[快速上手](quick-start.md)

1. **准备机器**

   * 使用预分配好的机器，或基于预定义的沙箱[Vagrantfile](../vagrant/Vagrant)在本地生成演示虚拟机，选定一台作为中控机。

   * 配置中控机到其他机器的SSH免密码访问，并确认所使用的的SSH用户在机器上具有免密码`sudo`的权限。

   * 如果您在本机安装有vagrant和virtualbox，则可直接在项目根目录下执行以`make up`拉个四节点虚拟机环境，详见[Vagrant供给](vagrant-provision.md)

   ```bash
   make up
   ```

2. **准备项目**

   在中控机上安装Ansible，并克隆本项目。如果采用本地虚拟机环境，亦可在宿主机上安装ansible执行命令。

   ```bash
   git clone https://github.com/vonng/pigsty && cd pigsty 
   ```

   如果目标环境没有互联网访问，或者速度不佳，考虑下载预打包的离线安装包，或使用有互联网访问/代理的同系统的另一台机器制作离线安装包。离线安装细节请参考[离线安装](offline-installation.md)教程。

3. **修改配置**

   **按需修改配置文件**。配置文件使用YAML格式与Ansible清单语义，配置项与格式详情请参考[配置教程](configuration.md)

   ```bash
   vi conf/all.yml			# 默认配置文件路径
   ```

  4. **初始化基础设施**

     执行此剧本，将基础设施定义参数实例化，详情请参阅 [基础设施供给](infra-provision.md)

     ```bash
     ./infra.yml         # 执行此剧本，将基础设施定义参数实例化
     ```

  5. **初始化数据库集群**

     执行此剧本，将拉起所有的数据库集群，数据库集群供给详情请参阅 [数据库集群供给](postgres-provision.md)

     ```bash
     ./initdb.yml        # 执行此剧本，将所有数据库集群定义实例化
     ```

6. **开始探索**

   可以通过参数`nginx_upstream`中自定义的域名（沙箱环境中默认为`http://pigsty`）访问Pigsty主页。

   监控系统的默认域名为`http://g.pigsty`，默认用户名与密码均为`admin`

   监控系统可以直接通过`meta`节点上的3000端口访问，如需从本地通过域名访问，可以执行`sudo make dns`将所需的DNS记录写入宿主机中。

