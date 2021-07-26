# 准备工作



## 节点置备

在部署Pigsty前，用户需要准备机器节点资源，包括**至少**一个管理节点，与任意数量的数据库节点。当使用[沙箱](s-sandbox)时，虚拟机的创建将由[Vagrant](#vagrant)与[Virtualbox](#virtualbox)负责，默认会创建1个管理节点，使用4节点版本沙箱时则会额外创建3台数据库节点虚拟机。您也可以自行准备物理机或虚拟机，采用常规的流程部署Pigsty。



## 管理用户

Pigsty需要一个**管理用户**，该用户能够**从管理节点上免密码SSH登陆其他节点**，并免密码执行`sudo`命令。

> SSH登陆与sudo是必选项，免密码是建议项。如果您真的无法配置免密码SSH登陆与sudo，可以通过Ansible Playbook的`--ask-pass|-k`与`--ask-become-pass|-K`选项在执行过程中手工输入SSH与SUDO密码。

沙箱环境的默认用户`vagrant`，默认已经配置有免密登陆和免密sudo，您可以从宿主机或沙箱元节点使用vagrant登陆所有的数据库节点。

对于生产环境来说，即机器交付时，应当已经配置有这样一个具有免密远程SSH登陆并执行免密sudo的用户。

**Pigsty推荐将管理用户的创建，权限配置与密钥分发放在虚拟机的Provisioning阶段完成**，作为机器资源交付内容的一部分。通常绝大多数云平台和运维体系都可以做到这一点。否则您需要参考下面的说明配，置SSH免密码访问与免密码SUDO。



## SSH免密码访问

配置SSH免密码（公钥）的前提是您**可以通过密码SSH登陆目标节点**。

下面假设执行命令的管理用户名为`vagrant`。

### 生成密钥

以`vagrant`用户的身份执行以下命令，会为`vagrant`生成公私钥对，用于登陆。

```bash
ssh-keygegn
```

* 默认公钥：`~/.ssh/id_rsa.pub`
* 默认私钥：`~/.ssh/id_rsa`

### 安装密钥

将公钥添加至需要登陆机器的对应用户上：`/home/vagrant/.ssh/authorized_keys`

如果您已经可以直接通过密码访问远程机器，可以直接通过`ssh-copy-id`的方式拷贝公钥。

```bash
# 输入密码以完成公钥拷贝
ssh-copy-id <ip>

# 直接将密码嵌入命令中，避免交互式密码输入
sshpass -p <password> ssh-copy-id <ip>
```

然后便可以通过该用户免密码SSH登陆远程机器。



## SUDO免密码

假设用户名为`vagrant`，则通过`visudo` 命令，或创建`/etc/sudoers.d/vagrant` 文件添加以下记录：

```bash
%vagrant ALL=(ALL) NOPASSWD: ALL
```

则 vagrant 用户即可免密`sudo`执行所有命令





## 自动创建管理用户

如果您已经拥有一个可以SSH登陆且能执行sudo的用户（无需免密码），那么可以临时使用该用户的身份创建一个满足需求的**管理用户**。

假设您希望通过名为`dba`的管理员用户管理数据库，拥有免密码SSH与Sudo的权限。则可以通过[`pgsql.yml`](p-pgsql)剧本提供的`node_admin`任务自动完成管理员用户的创建。

在目标机器上执行以下剧本，当出现提示时输入所使用临时管理用户的SSH密码与sudo密码，即可在目标机器上创建 [`node_admin_username`](v-node#node_admin_username) 所定义的管理员用户。

```
./pgsql -l <目标机器> -t node_admin -e ansible_user=临时管理用户 -k -K
```





## 沙箱环境软件依赖

使用本地沙箱拉起Pigsty时，用户还需要在**宿主机**上安装：Virtualbox与Vagrant。

### Vagrant

通常为了测试“数据库集群”这样的系统，用户需要事先准备若干台虚拟机。尽管云服务已经非常方便，但本地虚拟机访问通常比云虚拟机访问方便，响应迅速，成本低廉。本地虚拟机配置相对繁琐，[**Vagrant**](https://www.vagrantup.com/) 可解决这一问题。

Pigsty用户无需了解vagrant的原理，只需要知道vagrant可以简单、快捷地按照用户的需求，在笔记本、PC或Mac上拉起若干台虚拟机。用户需要完成的工作，就是将自己的虚拟机需求，以**vagrant配置文件**的形式表达出来。

**Vagrant配置文件**

[https://github.com/Vonng/pigsty/blob/master/vagrant/Vagrantfile](https://github.com/Vonng/pigsty/blob/master/vagrant/Vagrantfile) 提供了一个Vagrantfile样例。

这是Pigsty沙箱所使用的Vagrantfile，定义了四台虚拟机，包括一台2核/4GB的中控机/**元节点**，和3台 1核/1GB 的**数据库节点**。

`vagrant` 二进制程序根据 Vagrantfile 中的定义，默认调用 Virtualbox 完成本地虚拟机的创建工作。

进入Pigsty根目录下的`vagrant`目录，执行`vagrant up`，即可拉起所有的四台虚拟机。其他快捷命令请参考`Makefile`

```ruby
IMAGE_NAME = "centos/7"
N=3  # 数据库机器节点数量，可修改为0

Vagrant.configure("2") do |config|
    config.vm.box = IMAGE_NAME
    config.vm.box_check_update = false
    config.ssh.insert_key = false

    # 元节点
    config.vm.define "meta", primary: true do |meta|  # 元节点默认的ssh别名为`meta`
        meta.vm.hostname = "meta"
        meta.vm.network "private_network", ip: "10.10.10.10"
        meta.vm.provider "virtualbox" do |v|
            v.linked_clone = true
            v.customize [
                    "modifyvm", :id,
                    "--memory", 4096, "--cpus", "2",   # 元节点的内存与CPU核数：默认为2核/4GB
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

如果用户的机器配置不足，则可以考虑使用更小的`N`值，减少数据库节点的数量。如果只希望运行单个**元节点**，将其修改为0即可。用户还可以修改每台机器的CPU核数和内存资源等，如配置文件中的注释所述，详情参阅Vagrant与Pigsty文档。

沙箱环境默认使用`IMAGE_NAME = "centos/7"`，首次执行时会从vagrant官方下载`centos 7.8` virtualbox 镜像，确保宿主机拥有合适的网络访问权限（科学上网）

## Virtualbox

Virtualbox是一个开源免费的跨平台虚拟机软件。在MacOS上安装Virtualbox非常简单，其他操作系统上与之类似。

```bash
brew install virtualbox
```

