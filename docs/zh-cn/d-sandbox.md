# 沙箱环境

> Pigsty支持使用 [本地沙箱](#本地沙箱) 与 [云端沙箱](#多云部署) 两种方式，可用于快速在本机或云端[准备](d-prepare.md)标准的1/4节点演示环境。

尽管安装Pigsty已经非常简单了，但是搭建满足要求虚拟机仍然是比较费事的，您可能需要用到各类虚拟机软件。

因此Pigsty提供了**沙箱环境**，进一步免除用户准备环境的烦恼。完整地创建并跑通沙箱安装部署流程，对于在生产环境中部署有Pigsty 很大的帮助。



## 沙箱环境简介

沙箱环境是一个配置规格、对象标识符、与默认数据库**预先确定**的环境，无论是本地版还是云端版都保持一致。

沙箱环境使用固定的IP地址，以便于演示说明，沙箱的元节点IP地址固定为：`10.10.10.10`。`10.10.10.10` 也是所有配置文件模板中元节点IP地址的占位符，执行 [配置](v-config.md#配置过程) 时，该IP地址会被作为元节点的实际IP地址

![](../_media/SANDBOX.gif)

您可以使用单节点沙箱，这种部署下，只有一个元节点`meta`，节点上部署有完整的基础设施，和一个单例Postgres数据库`pg-meta`。

* `meta    10.10.10.10  pg-meta.pg-meta-1`

单节点沙箱则适合用于个人开发、实验、学习；作为数据分析与可视化的环境；以及设计、演示、分发交互式数据应用，四节点沙箱可以完整演示Pigsty的功能，充分探索高可用架构与监控系统的能力，请您自行按需选择。

在四节点沙箱环境中，有三个额外的节点，与一个额外一套三节点PostgreSQL集群 `pg-test`

* `node-1  10.10.10.11  pg-test.pg-test-1`
* `node-2  10.10.10.12  pg-test.pg-test-2`
* `node-3  10.10.10.13  pg-test.pg-test-3`

同时，沙箱环境还会使用以下两个IP地址与两条静态DNS记录，用于接入数据库集群。

* `10.10.10.2  pg-meta`
* `10.10.10.2  pg-test`



Pigsty提供了基于Vagrant的本地沙箱（使用Virtualbox拉起本地虚拟机），以及基于Terraform的云端沙箱（使用云厂商API创建虚拟机）。

* 本地沙箱可以在普通Mac/PC上运行，不需要任何费用，但若想在本机运行完整的4节点沙箱环境，您的Mac/PC应当至少有 4C/8G的硬件规格。

* 云端沙箱可以方便地向他人展示与共享，使用前需要您创建一个云账号，虚拟机资源按需创建使用，用后可以一键销毁，会有一些费用（通常非常便宜，一天几块钱）





## 本地沙箱

Pigsty本地沙箱底层依托于 [Vagrant](https://www.vagrantup.com/) 托管本地的 [Virtualbox](https://www.virtualbox.org/) 虚拟机。

使用Pigsty沙箱前，您需要在操作系统中安装 Vagrant 与 Virtualbox，两者都是免费的跨平台开源软件。您也可以选择自己使用喜爱的虚拟机软件（Parallel Desktop，VMWare）自行创建虚拟机进行[标准安装部署](d-deploy.md)。


### 快速开始

确保 [Vagrant](https://www.vagrantup.com/) 与 [Virtualbox](https://www.virtualbox.org/) 安装并可用，按照官方向导安装即可。在MacOS上，您可以直接使用 `homebrew` 一键完成两者的安装（需要重启）。

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" # 安装Homebrew
brew install vagrant virtualbox # 在MacOS宿主机上安装Vagrant与Virtualbox
```

在 MacOS 操作系统中，可以通过以下四条快捷方式来安装软件依赖，配置本地静态DNS，拉起虚拟机。在Windows与Linux下则需要少量额外手工步骤。

```bash
make deps    # 安装homebrew，并通过homebrew安装vagrant与virtualbox（需重启）
make dns     # 向本机/etc/hosts写入静态域名 (需sudo输入密码)
make start   # 使用Vagrant拉起单个meta节点  (start4则为4个节点)
```

接下来，您可以 `ssh meta` 登陆默认元节点，元节点访问所有节点的SSH sudo已经配置完毕，您可以直接执行Pigsty安装。



### Vagrant


通常为了测试“数据库集群”这样的系统，用户需要事先准备若干台虚拟机。尽管云服务已经非常方便，但本地虚拟机访问通常比云虚拟机访问方便，响应迅速，成本低廉。本地虚拟机配置相对繁琐，[**Vagrant**](https://www.vagrantup.com/) 可解决这一问题。

Pigsty用户无需了解vagrant的原理，只需要知道vagrant可以简单、快捷地按照用户的需求，在笔记本、PC或Mac上拉起若干台虚拟机。用户需要完成的工作，就是将自己的虚拟机需求，以**Vagrant配置文件**的形式表达出来。

[https://github.com/Vonng/pigsty/blob/master/vagrant/Vagrantfile](https://github.com/Vonng/pigsty/blob/master/vagrant/Vagrantfile) 提供了一个Vagrantfile样例。这是Pigsty沙箱所使用的Vagrantfile，定义了四台虚拟机，包括一台2核/4GB的中控机/**元节点** `meta`和3台1核/1GB 的**数据库节点** `node-1, node-2, node3`。

通过`make up` , `make new`, `make start`等快捷方式使用沙箱时，默认只会使用单个元节点`meta`。而`make up4`，`make new4`，`make start4`则会使用全部的虚拟机。这里`N`值定义了额外的数据库节点数量（3台）。如果您的机器配置不足，则可以考虑使用更小的`N`值，减少数据库节点的数量。用户还可以修改每台机器的CPU核数和内存资源等，如配置文件中的注释所述。更详情的定制请参考Vagrant与Virtualbox文档。

<details><summary>Vagrantfile样例</summary>

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

</details>

`vagrant` 二进制程序会根据 Vagrantfile 中的定义，默认调用 Virtualbox 完成本地虚拟机的创建工作。进入Pigsty根目录下的`vagrant`目录，执行`vagrant up`，即可拉起所有的四台虚拟机。[`Makefile`](https://github.com/Vonng/pigsty/blob/master/Makefile#L365)提供了大量对`vagrant`原始命令的封装。

沙箱环境默认使用的虚拟机镜像为`IMAGE_NAME = "centos/7"`。首次执行时会从互联网下载`centos 7.8.2003`的virtualbox镜像，后续重新创建新虚拟机时时将直接克隆此BOX。



### Virtualbox

[Virtualbox](https://www.virtualbox.org/)是一个开源免费的跨平台虚拟机软件。在MacOS上安装Virtualbox非常简单：`brew install virtualbox`，其他操作系统上与之类似。

安装Virtualbox后，可能需要重新启动计算机以加载虚拟机内核模块。请注意Pigsty需要x86_64运行环境，安装有M1芯片的Macbook可能无法正常运行Virtualbox。



### DNS配置

Pigsty默认通过**域名**访问所有Web系统，如果您没有DNS服务器或公共域名，可以使用本地静态DNS记录，沙箱环境使用的静态DNS记录如下所示：

```bash
# pigsty dns records
10.10.10.10 meta pigsty c.pigsty g.pigsty l.pigsty p.pigsty a.pigsty cli.pigsty lab.pigsty api.pigsty matrix.pigsty
10.10.10.11 node-1   # sandbox node node-1
10.10.10.12 node-2   # sandbox node node-2
10.10.10.13 node-3   # sandbox node node-3
10.10.10.2  pg-meta  # sandbox vip for pg-meta
10.10.10.3  pg-test  # sandbox vip for pg-test
```

在MacOS与Linux中，执行`sudo make dns`会将上述记录写入 `/etc/hosts` （需要sudo权限），在Windows中，则需要您手工添加上述记录至：`C:\Windows\System32\drivers\etc\hosts`中。




----------------


## 多云部署

如果您手头没有x86_64架构的PC、笔记本、Mac，使用即用即毁的云虚拟机可能是另一个不错的选择。

### Terraform

[Terraform](https://www.terraform.io/) 是开源免费的 基础设施即代码 工具。您只需要声明好所需的云虚拟机、网络与安全组配置等，一键即可拉起对应的资源。

在MacOS下安装Terraform，只需要执行`brew install terraform`即可。然后您需要有云厂商账号，并获取AccessKey与AccessSecret凭证，充点钱，就可以开始云端沙箱部署之旅啦。


### 配置文件

项目根目录 `terraform/` 中提供了若干云厂商的 Terraform 资源定义文件，您可以使用这些模板快速在云上申请虚拟机资源用于部署Pigsty。这里以阿里云为例：

```bash
cd terraform        # 进入terraform目录中
vi alicloud.tf      # 编辑配置文件，填入您的阿里云AccessKey与SecretKey
```


<details><summary>阿里云样例Terraform文件</summary>

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



### 执行计划

首先，使用`terraform`命令，创建上面定义的云资源（共享1C1G临时用用很便宜，按需付费）

```bash
terraform init      # 安装 terraform provider: aliyun （仅第一次需要）
terraform apply     # 生成执行计划：创建虚拟机，虚拟网段/交换机/安全组
```

执行 `apply` 并输入 yes后，terraform会调用阿里云API创建对应的虚拟机资源。


<details><summary>Terraform Apply执行结果</summary>

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



### SSH配置与微调

其中，管理机将分配一个按量付费的公网IP，您也可以使用命令`terraform output`将其打印出来。

```bash
# 打印公网IP与root密码
ssh_pass='PigstyDemo4'
public_ip=$(terraform output | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
echo "meta node: root:${ssh_pass}@${public_ip}"
```

接下来，我们先来配置本地登录云端管理机器的SSH配置（默认用户`root`，密码`PigstyDemo4`）

```bash
# 创建 ~/.ssh/pigsty_terraform 文件，包含云端管理机器的SSH定义（可选，好用一点）
cat > ~/.ssh/pigsty_terraform <<-EOF
Host demo
  User root
  HostName ${public_ip}
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication yes
EOF
chmod 0600 ~/.ssh/pigsty_terraform 

# 启用该配置
if ! grep --quiet "Include ~/.ssh/pigsty_terraform" ~/.ssh/config ; then
    (echo 'Include ~/.ssh/pigsty_terraform' && cat ~/.ssh/config) >  ~/.ssh/config.tmp;
    mv ~/.ssh/config.tmp ~/.ssh/config && chmod 0600 ~/.ssh/config;
fi
```

然后，您可以通过SSH别名`demo`访问该云端管理机了。

```bash
# 添加本地到元节点的免密访问
sshpass -p ${ssh_pass} ssh-copy-id demo 
```

然后，您就可以免密从本地访问该节点了，如果只需要进行单节点安装，这样就行了。接下来，在该元节点上完成标准安装


### DNS配置

Pigsty默认通过**域名**访问所有Web系统，尽管您可以使用 IP：Port的方式访问主要系统的Web界面，但这并不是推荐的行为。

云端沙箱环境使用的静态DNS记录如下所示，您需要填入元节点的公网IP地址

```bash
<public_ip> meta pigsty c.pigsty g.pigsty l.pigsty p.pigsty a.pigsty cli.pigsty lab.pigsty api.pigsty matrix.pigsty
```

在MacOS与Linux中，需要将上述记录写入 `/etc/hosts` （需要sudo权限），在Windows中，则需要您手工添加至：`C:\Windows\System32\drivers\etc\hosts`中。



### 特殊注意事项

阿里云虚拟机CentOS 7.8镜像中运行有 `nscd` ，锁死了 glibc 版本，会导致安装时出现RPM依赖错误。

在所有机器上执行 `yum remove -y nscd` 即可解决此问题。

完成上述准备工作后，所有机器准备工作已经就绪，可以开始常规的 Pigsty下载配置安装三部曲啦。