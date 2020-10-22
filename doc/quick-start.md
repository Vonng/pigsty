# Quick Start [DRAFT]

1. Prepare nodes, pick one as meta node which have nopass ssh & sudo on other nodes ([Vagrant Provision Guide](vagrant-provision.md))

2. Install ansible on meta nodes and clone this repo. If you does not have internet access, consider using [Offline Installation](offline-installation.md)

   ```bash
   git clone https://github.com/vonng/pigsty && cd pigsty 
   ```

3. **Configure** your infrastructure and defining you database clusters ([Configuration Guide](configuration.md))

   ```bash
   conf/all.yml				 # default configuration path
   ```


4. Run`infra.yml` on meta node to provision infrastructure. ([Infrastructure Provision Guide](infra-provision.md))

   ```bash
   ./infra.yml          # setup infrastructure properly
   ```

5. Run`initdb.yml` on meta node to provision database cluster ([Postgres Provision Guide](postgres-provision.md))

   ```bash
   ./initdb.yml       # pull up all postgres clusters  
   ```

6. Start exploring ([Monitoring System](monitoring-system.md))

   ```bash
   # GUI access:
   sudo make dns				   # write local DNS record to your /etc/hosts, sudo required
   open http://g.pigsty   # monitor system grafana, default credential: admin:admin
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

