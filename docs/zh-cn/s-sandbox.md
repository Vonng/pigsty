## 本地沙箱

尽管安装Pigsty已经非常简单了，但是搭建一台满足要求虚拟机仍然是比较费事的。

因此Pigsty提供了**沙箱环境**，进一步免除用户准备环境的烦恼。
完整地创建并跑通沙箱安装部署流程，对于在生产环境中部署有Pigsty 很大的帮助。

您可以使用 [本地沙箱](#本地沙箱) 与 [云端沙箱](#云端沙箱) 两种方式，快速在本机或云端拉起标准的4节点演示环境。





## 沙箱环境简介

沙箱环境是一个配置规格与对象标识符**预先确定**的环境，无论是本地版还是云端版都保持一致。

例如，默认节点的IP地址一定是`10.10.10.10`，4节点沙箱换的架构如下图所示：

![](../_media/sandbox.svg)

沙箱环境使用固定的IP地址，以便于演示说明，沙箱的管理节点IP地址固定为：`10.10.10.10`。

> 10.10.10.10 是所有配置文件模板中IP地址的占位符，执行普通部署时，该IP地址会被为管理节点的实际IP地址

无论是何种沙箱，都会有一个管理节点`meta`，节点上部署有一个单例Postgres数据库`pg-meta`。

* `meta    10.10.10.10  pg-meta.pg-meta-1`

在四节点沙箱环境中，有三个额外的数据库节点，会部署一套三节点的数据库集群`pg-test`

* `node-1  10.10.10.11  pg-test.pg-test-1`
* `node-2  10.10.10.12  pg-test.pg-test-2`
* `node-3  10.10.10.13  pg-test.pg-test-3`

同时，沙箱环境还会使用以下两个IP地址与两条静态DNS记录，用于接入数据库集群。

* `10.10.10.2  pg-meta`
* `10.10.10.2  pg-test`



## 本地与云端的区别

Pigsty提供了基于Vagrant的本地沙箱（使用Virtualbox拉起本地虚拟机），以及基于Terraform的云端沙箱（使用云厂商API创建虚拟机）。

* 本地沙箱可以在普通Mac/PC上运行，不需要任何费用，但若想在本机运行完整的4节点沙箱环境，您的Mac/PC应当至少有 4C/8G的硬件规格。

* 云端沙箱可以方便地向他人展示与共享，使用前需要您创建一个云账号，虚拟机资源按需创建使用，用后可以一键销毁，会有一些费用（通常非常便宜，几块钱）



## 本地沙箱

Pigsty沙箱底层依托于是 [Vagrant](https://www.vagrantup.com/) 托管的 [Virtualbox](https://www.virtualbox.org/) 虚拟机（默认：1台，完整模式：4台）。

使用Pigsty沙箱前，您需要在操作系统中安装 Vagrant 与 Virtualbox，两者都是免费的跨平台开源软件。

您也可以选择自己使用喜爱的虚拟机软件（Parallel Desktop，VMWare）自行创建虚拟机，或直接使用云虚拟机，进行[标准安装部署](t-deploy.md)。

Pigsty沙箱有单节点与四节点两种不同规格，单节点沙箱为默认配置。
单节点沙箱则适合用于个人开发、实验、学习；作为数据分析与可视化的环境；以及设计、演示、分发交互式数据应用，
四节点沙箱可以完整演示Pigsty的功能，充分探索高可用架构与监控系统的能力，请您自行按需选择。


### 快速开始

1. 确保 [Vagrant](https://www.vagrantup.com/) 与 [Virtualbox](https://www.virtualbox.org/) 安装并可用，按照官方向导即可（需要重启）。
2. [下载](s-install.md#下载) pigsty 至 **宿主机**，进入pigsty目录，执行 `make start`拉起虚拟机
3. 在宿主机执行 `make demo` 开始自动安装默认的单节点沙箱
4. （可选）添加静态DNS记录以通过域名访问Pigsty Web UI

沙箱可以在 MacOS 操作系统中一键拉起，在Windows与Linux下则需要少量额外手工步骤。
在MacOS中可以使用以下四条`make`快捷方式来安装软件依赖，配置本地静态DNS，拉起虚拟机，并执行安装。

```bash
make deps   # 安装homebrew，并通过homebrew安装vagrant与virtualbox（需重启）
make dns    # 向本机/etc/hosts写入静态域名 (需sudo输入密码)
make start  # 使用Vagrant拉起单个meta节点  (start4则为4个节点)
make demo   # 使用单节点Demo配置并安装     (demo4则为4节点demo)
```


### 使用4节点沙箱

将拉起沙箱的两条命令替换为以下命令，即可拉起4节点的沙箱环境。

```bash
make start4 
make demo4
```

### 其他操作系统

其他操作系统需要自行下载并安装Vagrant与Virtualbox，配置静态DNS域名，其余步骤与MacOS一致。

```bash
make start && make demo
```

### DNS配置

Pigsty默认通过**域名**访问所有Web系统，沙箱环境使用的静态DNS记录如下所示：

```bash
# pigsty dns records
10.10.10.10 pigsty c.pigsty g.pigsty p.pigsty a.pigsty cli.pigsty lab.pigsty

10.10.10.10 meta     # sandbox meta node
10.10.10.11 node-1   # sandbox node node-1
10.10.10.12 node-2   # sandbox node node-2
10.10.10.13 node-3   # sandbox node node-3

10.10.10.2  pg-meta  # sandbox vip for pg-meta
10.10.10.3  pg-test  # sandbox vip for pg-test
```

在MacOS与Linux中，执行`make dns`会将上述记录写入 `/etc/hosts` （需要sudo权限），在Windows中，则需要您手工添加至：`C:\Windows\System32\drivers\etc\hosts`中。




----------------





## 云端沙箱

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
# 添加本地到管理节点的免密访问
sshpass -p ${ssh_pass} ssh-copy-id demo 
```

然后，您就可以免密从本地访问该节点了，如果只需要进行单节点安装，这样就行了。接下来，在该管理节点上完成标准安装



### 特殊注意事项

阿里云虚拟机CentOS 7.8镜像中运行有 `nscd` ，锁死了 glibc 版本，会导致安装时出现RPM依赖错误。

在所有机器上执行 `yum remove -y nscd` 即可解决此问题。



### 标准安装

标准安装使用以下命令即可

```bash
curl -SL https://github.com/Vonng/pigsty/releases/download/v1.3.1/pkg.tgz -o /tmp/pkg.tgz
curl -SL https://github.com/Vonng/pigsty/releases/download/v1.3.1/pigsty.tgz | gzip -d | tar -xC ~ && cd ~/pigsty  
./configure
make install
```

如果您的网络条件不佳（无法访问Github），可以从别的地方（如百度云盘）下载好手工上传，例如：

```bash
make upload-terraform  #  将本地 dist/ 目录中的 pigsty.tgz pkg.tgz 上传，等效于以下命令
scp dist/v1.3.1/pigsty.tgz demo:~/
scp dist/v1.3.1/pkg.tgz demo:/tmp/pkg.tgz
```

接下来执行常规的`configure`，`install` 流程即可

```bash
ssh demo
cd pigsty
./configure
make install
```



### DNS配置

Pigsty默认通过**域名**访问所有Web系统，尽管您可以使用 IP：Port的方式访问主要系统的Web界面，但这并不是推荐的行为。

云端沙箱环境使用的静态DNS记录如下所示，您需要填入管理节点的公网IP地址

```bash
<public_ip> pigsty c.pigsty g.pigsty p.pigsty a.pigsty cli.pigsty lab.pigsty
```

在MacOS与Linux中，需要将上述记录写入 `/etc/hosts` （需要sudo权限），在Windows中，则需要您手工添加至：`C:\Windows\System32\drivers\etc\hosts`中。

