# 准备工作

如何准备Pigsty部署所需的资源：

* [节点置备](#节点置备)
* [管理节点置备](#管理节点置备)
* [管理用户置备](#管理用户置备)
* [软件置备](#软件置备)
  * [Pigsty源代码](#pigsty源代码)
  * [Pigsty离线软件包](#pigsty离线软件包)
  * [Vagrant](#vagrant) （沙箱）
  * [Virtualbox](#Virtualbox) （沙箱）

## 节点置备

在部署Pigsty前，用户需要准备机器节点资源，包括至少一个[管理节点](c-arch.md#管理节点)，与任意数量的[数据库节点](c-arch.md#数据库节点)。

[数据库节点](c-arch.md#数据库节点)可以使用任意类型节点：物理机、本地虚拟机、云虚拟机，容器等，只需要满足以下条件：

  - [x] 处理器架构：x86_64
  - [x] 硬件规格至少为1核/1GB
  - [x] 操作系统：CentOS 7.8.2003 （或其他RHEL 7等效发行版）
  - [x] 管理用户可以从**管理节点** `ssh` 登陆数据库节点并执行`sudo`



## 管理节点置备

Pigsty需要[管理节点](c-arch.md#管理节点)作为整个环境的控制中心，并提供[基础设施](c-arch#基础设施) 服务。

**管理节点**的数量最少为1个，沙箱环境默认使用1个管理节点。Pigsty的基础设施以**副本**的形式部署在多个管理节点上，DCS（Consul/Etcd）例外，DCS以Quorum的形式存在。Pigsty的数据库集群需要使用DCS以实现高可用功能，您可以使用自动部署于管理节点上的DCS集群，或使用外部的DCS集群。使用Pigsty内置的DCS集群时，必须使用奇数个管理节点，建议在**生产环境**至少使用3个管理节点，充分保证DCS服务的可用性。

用户应当确保自己可以**登录**管理节点，并能使用[管理用户](#管理用户置备)从管理节点上通过`ssh`登陆其他数据库节点，并带有`sudo`或`root`权限。用户应当确保自己可以直接或间接**访问管理节点的80端口**，以访问Pigsty提供的用户界面。

  - [x] 管理节点数量：奇数个，至少一个
  - [x] 能够使用管理员用户登陆管理节点
  - [x] 可以通过浏览器访问管理节点80端口（直接或间接）
  - [x] **管理用户**可以从管理节点远程`ssh`登陆数据库节点并执行`sudo` （包括自身）


## 管理用户置备

Pigsty需要一个**管理用户**，该用户能够**从管理节点上SSH登陆其他节点**，并执行`sudo`命令。

  - [x] 可以在管理节点上使用该用户
  - [x] 可以使用该用户SSH登陆所有被管理节点（包括自身）
  - [x] 可以在登陆所有被管理节点后执行sudo命令（包括自身）
  - [x] 管理用户不是`postgres`或`{{ dbsu }}` （使用DBSU作为管理员有安全隐患）
  - [x] ssh 登陆免密码，sudo 命令免密码（或您知晓如何通过`-k`,`-K`手工输入）

> **执行部署与变更时**，您所使用的管理用户**必须**拥有所有节点的`ssh`与`sudo`权限。
>
> Pigsty强烈建议为管理用户配置SSH**免密码登陆**，并在所有节点上配置管理用户免密码`sudo`。

**Pigsty推荐将管理用户的创建，权限配置与密钥分发放在虚拟机的Provisioning阶段完成**，作为机器资源交付内容的一部分。对于生产环境来说，机器交付时应当已经配置有这样一个具有免密远程SSH登陆并执行免密sudo的用户。通常绝大多数云平台和运维体系都可以做到这一点。

如果您只能使用ssh密码和sudo密码，那么必须在所有剧本执行时添加额外的参数`--ask-pass|-k`与`--ask-become-pass|-K`，并在提示出现时输入ssh密码与sudo密码。您可以使用[`pgsql.yml`](p-pgsql)中创建管理员用户的功能，使用当前用户创建一个**专用管理员用户**，以下参数用于创建默认的管理员用户：

* [`node_admin_setup`](v-node#node_admin_setup)
* [`node_admin_uid`](v-node#node_admin_uid)
* [`node_admin_username`](v-node#node_admin_username)
* [`node_admin_pks`](v-node#node_admin_pks)

```bash
./pgsql.yml -t node_admin -l <目标机器> --ask-pass --ask-become-pass
```

默认创建的管理员用户为`dba` (uid=88)，请不要使用`postgres`或`dbsu`作为管理用户。

沙箱环境的默认用户`vagrant`默认已经配置有免密登陆和免密sudo，您可以从宿主机或沙箱管理节点使用vagrant登陆所有的数据库节点。

### 手工配置SSH与SUDO

手工配置SSH免密码登陆，可以通过`ssh-keygen` 与 `ssh-copy-id`的方式实现，请自行参考相关文档。

手工配置用户的免密码`sudo`，可以在`/etc/sudoers.d/<username>`文件添加以下记录实现：

```bash
%<username> ALL=(ALL) NOPASSWD: ALL
```

注意将`<username>`换成您使用的管理员名称即可。







## 软件置备

为了运行Pigsty，您需要置备以下软件：

  - [x] [Pigsty源代码](#源代码下载)
  - [x] [Pigsty离线软件包]()（可选）

如需在您自己的笔记本上运行Pigsty沙箱，您还需要在宿主机上下载并安装：

  - [x] Vagrant：虚拟机托管编排软件（跨平台，免费）
  - [x] Virtualbox：虚拟机软件（跨平台，开源免费）



### Pigsty源代码

用户应当在管理节点上获取Pigsty项目源码，通常解压至管理用户HOME目录下。

```bash
git clone https://github.com/Vonng/pigsty && cd pigsty # 获取最新代码 
```

如果没有`git`，可以使用`curl`下载。建议使用此种方式下载固定版本：`v1.3.0`为具体版本号。

```bash
curl -SL https://github.com/Vonng/pigsty/releases/download/v1.3.0/pigsty.tgz -o ~/pigsty.tgz && tar -xf pigsty.tgz # 下载特定版本的代码（推荐）
```

或从百度网盘下载源代码：https://pan.baidu.com/s/1DZIa9X2jAxx69Zj-aRHoaw (提取码: `8su9`）



### Pigsty离线软件包

离线软件包打包了所有软件依赖，大小约1GB。在没有互联网访问时，可以实现离线安装的功能。

离线软件包为**可选项**。在网络条件良好（科学上网）的情况下，您可以选择跳过离线安装包，直接从原始上游下载相关软件（约1GB）。

官方离线软件包基于CentOS 7.8.2003操作系统环境制作，如果您使用的操作系统并非此版本，出现依赖错漏问题，请参考文档在带有互联网（Github）访问的，装有同样操作系统机器上[制作离线安装包](t-offline.md)。

离线软件包可从Github Release页面下载，`v1.3.0`为具体的版本号，软件包与源代码的版本应当保持一致。

```bash
curl -SL https://github.com/Vonng/pigsty/releases/download/v1.3.0/pkg.tgz    -o /tmp/pkg.tgz
```

百度网盘亦提供`pkg.tgz`的下载，地址同Pigsty源代码。

离线软件包通常放置于所有管理节点`/tmp/pkg.tgz`路径下。




### Vagrant

通常为了测试“数据库集群”这样的系统，用户需要事先准备若干台虚拟机。尽管云服务已经非常方便，但本地虚拟机访问通常比云虚拟机访问方便，响应迅速，成本低廉。本地虚拟机配置相对繁琐，[**Vagrant**](https://www.vagrantup.com/) 可解决这一问题。

Pigsty用户无需了解vagrant的原理，只需要知道vagrant可以简单、快捷地按照用户的需求，在笔记本、PC或Mac上拉起若干台虚拟机。用户需要完成的工作，就是将自己的虚拟机需求，以**vagrant配置文件**的形式表达出来。

[https://github.com/Vonng/pigsty/blob/master/vagrant/Vagrantfile](https://github.com/Vonng/pigsty/blob/master/vagrant/Vagrantfile) 提供了一个Vagrantfile样例。

这是Pigsty沙箱所使用的Vagrantfile，定义了四台虚拟机，包括一台2核/4GB的中控机/**管理节点** `meta`和3台1核/1GB 的**数据库节点** `node-1, node-2, node3`。

通过`make up` , `make new`, `make demo`等快捷方式使用沙箱时，默认只会使用单个管理节点`meta`。而`make up4`，`make new4`，`make demo4`则会使用全部的虚拟机。这里`N`值定义了额外的数据库节点数量（3台）。如果您的机器配置不足，则可以考虑使用更小的`N`值，减少数据库节点的数量。用户还可以修改每台机器的CPU核数和内存资源等，如配置文件中的注释所述。更详情的定制请参考Vagrant与Virtualbox文档。

```ruby
IMAGE_NAME = "centos/7"
N=3  # 数据库机器节点数量，可修改为0

Vagrant.configure("2") do |config|
    config.vm.box = IMAGE_NAME
    config.vm.box_check_update = false
    config.ssh.insert_key = false

    # 管理节点
    config.vm.define "meta", primary: true do |meta|  # 管理节点默认的ssh别名为`meta`
        meta.vm.hostname = "meta"
        meta.vm.network "private_network", ip: "10.10.10.10"
        meta.vm.provider "virtualbox" do |v|
            v.linked_clone = true
            v.customize [
                    "modifyvm", :id,
                    "--memory", 4096, "--cpus", "2",   # 管理节点的内存与CPU核数：默认为2核/4GB
                    "--nictype1", "virtio", "--nictype2", "virtio",
                    "--hwv·irtex", "on", "--ioapic", "on", "--rtcuseutc", "on", "--vtxvpid", "on", "--largepages", "on"
                ]
        end
        meta.vm.provision "shell", path: "provision.sh"
    end

    # 初始化N个数据库节点
    (1..N).each do |i|
        config.vm.define "node-#{i}" do |node|  # 数据库节点默认的ssh别名分别为`node-{1,2,3}`
            node.vm.box = IMAGE_NAME
            node.vm.network "private_network", ip: "10.10.10.#{i + 10}"
            node.vm.hostname = "node-#{i}"
            node.vm.provider "virtualbox" do |v|
                v.linked_clone = true
                v.customize [
                        "modifyvm", :id,
                        "--memory", 2048, "--cpus", "1", # 数据库节点的内存与CPU核数：默认为1核/2GB
                        "--nictype1", "virtio", "--nictype2", "virtio",
                        "--hwvirtex", "on", "--ioapic", "on", "--rtcuseutc", "on", "--vtxvpid", "on", "--largepages", "on"
                    ]
            end
            node.vm.provision "shell", path: "provision.sh"
        end
    end
end
```

`vagrant` 二进制程序会根据 Vagrantfile 中的定义，默认调用 Virtualbox 完成本地虚拟机的创建工作。进入Pigsty根目录下的`vagrant`目录，执行`vagrant up`，即可拉起所有的四台虚拟机。[`Makefile`](https://github.com/Vonng/pigsty/blob/master/Makefile#L365)提供了大量对`vagrant`原始命令的封装。

沙箱环境默认使用的虚拟机镜像为`IMAGE_NAME = "centos/7"`。首次执行时会从互联网下载`centos 7.8.2003`的virtualbox镜像，后续重新创建新虚拟机时时将直接克隆此BOX。



### Virtualbox

[Virtualbox](https://www.virtualbox.org/)是一个开源免费的跨平台虚拟机软件。在MacOS上安装Virtualbox非常简单，其他操作系统上与之类似。

```bash
brew install virtualbox
```

安装Virtualbox后，可能需要重新启动计算机以加载虚拟机内核模块。



### MacOS快速安装

 在MacOS上，您可以通过homebrew与以下快捷方式下载安装Vagrant与Virtualbox：

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" # 安装Homebrew
brew install vagrant virtualbox # 在MacOS宿主机上安装Vagrant与Virtualbox
```

将项目克隆至宿主机下，进入`pigsty`目录执行`make deps`有同样的效果。

