# 准备工作

如何准备Pigsty部署所需的资源：

* [节点置备](#节点置备)
* [元节点置备](#元节点置备)
* [管理用户置备](#管理用户置备)
* [软件置备](#软件置备)
  * [Pigsty源代码](#pigsty源代码)
  * [Pigsty离线软件包](#pigsty离线软件包)
  * [Vagrant](#vagrant) （沙箱）
  * [Virtualbox](#Virtualbox) （沙箱）




----------------

## 节点置备

在部署Pigsty前，用户需要准备机器节点资源，包括至少一个[元节点](c-nodes.md#元节点)，与任意数量的[普通节点](c-nodes.md#节点)。

[节点](c-nodes.md#节点)可以使用任意类型：物理机、本地虚拟机、云虚拟机，容器等，只需要满足以下条件：

  - [x] 处理器架构：x86_64
  - [x] 硬件规格至少为1核/1GB
  - [x] 操作系统：CentOS 7.8.2003 （或其他RHEL 7等效发行版）
  - [x] [管理用户](#元节点置备)可以从 **元节点** `ssh` 登陆其他节点并执行`sudo`

如果您计划将Pigsty用作开箱即用的PostgreSQL数据库实例，则一台节点足矣。如果您还计划将Pigsty用作更多主机/数据库的管控，则可以准备更多的节点备用。




----------------

## 元节点置备

Pigsty需要[元节点](c-nodes.md#元节点)作为整个环境的控制中心，并提供[基础设施](c-infra.md#基础设施) 服务。

**元节点**的数量最少为1个，沙箱环境默认使用1个元节点。Pigsty的基础设施以**副本**的形式部署在多个元节点上，DCS（Consul/Etcd）例外，DCS以Quorum的形式存在。

Pigsty的数据库集群需要使用[DCS](v-infra.md#dcs)以实现高可用功能，您可以使用自动部署于元节点上的DCS集群，或使用外部的DCS集群。在**大规模生产环境**中，如果您没有专用的外部DCS集群，建议使用3个元节点以充分保证DCS服务的可用性。

用户应当确保自己可以**登录**元节点，并能使用[管理用户](#管理用户置备)从元节点上通过`ssh`登陆其他数据库节点，并带有`sudo`或`root`权限。用户应当确保自己可以直接或间接**访问元节点的80端口**，以访问Pigsty提供的用户界面。

  - [x] 元节点数量：奇数个，至少一个
  - [x] 能够使用管理员用户登陆元节点
  - [x] 能够（直接或间接）通过浏览器访问元节点80端口
  - [x] **管理用户**可以从元节点远程`ssh`登陆数据库节点并执行`sudo` （包括自身）



----------------

## 管理用户置备

Pigsty需要一个**管理用户**，该用户能够**从元节点上SSH登陆其他节点**，并执行`sudo`命令。

  - [x] 可以在元节点上使用该用户
  - [x] 可以使用该用户SSH登陆所有被元节点（包括自身）
  - [x] 可以在登陆所有被元节点后执行sudo命令（包括自身）
  - [x] 管理用户不是`postgres`或`{{ dbsu }}` （使用DBSU作为管理员有安全隐患）
  - [x] ssh 登陆免密码，sudo 命令免密码（或您知晓如何通过`-k`,`-K`手工输入）

**执行部署与变更时**，您所使用的管理用户**必须**拥有所有节点的`ssh`与`sudo`权限。免密码并非必需，您总是可以在执行剧本时通过`-k|-K`参数传入ssh与sudo的密码，甚至通过 `-e`[`ansible_host`](v-infra.md#connect)`=<another_user>` 使用其他用户来执行剧本。但Pigsty强烈建议为管理用户配置SSH**免密码登陆**与免密码`sudo`。

**Pigsty推荐将管理用户的创建，权限配置与密钥分发放在虚拟机的Provisioning阶段完成**，作为机器资源交付内容的一部分。对于生产环境来说，机器交付时应当已经配置有这样一个具有免密远程SSH登陆并执行免密sudo的用户。通常绝大多数云平台和运维体系都可以做到这一点。

Pigsty剧本[`nodes`](p-nodes.md#nodes) 可以在节点上创建管理用户，但这涉及到一个先有鸡还是先有蛋但的问题：为了在远程节点执行Ansible剧本，需要有一个管理用户。为了创建一个专用管理用户，需要在远程节点上执行Ansible剧本。 作为Bootstrap阶段的妥协，只要您有SSH登陆与SUDO权限，即使没有密码，也可以用于执行Ansible剧本，详情请参考 [Nodes:创建管理用户](v-nodes.md#创建管理用户)


### 手工配置SSH与SUDO

手工配置SSH免密码登陆，可以通过`ssh-keygen` 与 `ssh-copy-id`的方式实现，请自行参考相关文档。

手工配置用户的免密码`sudo`，可以在`/etc/sudoers.d/<username>`文件添加以下记录实现，注意将`<username>`换成您使用的管理员名称即可。

```bash
%<username> ALL=(ALL) NOPASSWD: ALL
```




----------------

## 软件下载

为了运行Pigsty，您需要置备以下软件：

  - [x] [Pigsty源代码](#Pigsty源代码)
  - [x] [Pigsty离线软件包](#Pigsty离线软件包)（可选，但非常建议）

如需在您自己的笔记本上运行Pigsty沙箱，您还需要在宿主机上下载并安装：

  - [x] [Vagrant](#Vagrant)：虚拟机托管编排软件（跨平台，免费）
  - [x] [Virtualbox](#Virtualbox)：虚拟机软件（跨平台，开源免费）

如果您希望在云厂商服务器上运行Pigsty沙箱，您需要在本地下载并安装 [Terraform](#Terraform)



----------------

## Pigsty源代码

用户应当在元节点上获取Pigsty项目源码，通常解压至管理用户`HOME`目录下。

```bash
# 推荐使用此命令下载 pigsty.tgz 源码包，该脚本将区分墙内墙外，在大陆使用CDN加速下载
bash -c "$(curl -fsSL http://download.pigsty.cc/get)"  # get latest pigsty source
```

您也可以通过其他途径下载源码压缩包：

```bash
# https://github.com/Vonng/pigsty/releases/download/v1.5.0-beta/pigsty.tgz   # Github Release 
# http://download.pigsty.cc/v1.5.0-beta/pigsty.tgz                           # China CDN
# https://pan.baidu.com/s/1DZIa9X2jAxx69Zj-aRHoaw?pwd=8su9              # 百度云网盘下载
# git clone https://github.com/Vonng/pigsty                             # 获取最新代码Master分支（不建议）
```

此外 pigsty 项目根目录下的 [`download`](https://github.com/Vonng/pigsty/blob/master/download) 脚本也可以用于下载源代码。

```bash
./download pigsty.tgz    # 从Github/CDN下载当前版本pigsty.tgz至/tmp/pigsty.tgz
./download pigsty        # 从Github/CDN下载当前版本pigsty.tgz并解压至~/pigsty（如已存在则跳过）
```



## Pigsty离线软件包

离线软件包打包了所有软件依赖，大小约1GB，为可选项。在元节点上完整安装Pigsty时，如果`/tmp/pkg.tgz`已经存在，Pigsty会直接使用该软件包构建本地源，否则Pigsty会从网络下载所有依赖的软件包。

官方离线软件包基于CentOS 7.8.2003操作系统环境制作，如果您使用的操作系统并非此版本并出现依赖错漏问题，请参考[FAQ](s-faq.md)直接从原始上游安装。或在带有互联网（Github）访问的装有同样操作系统机器上[制作离线安装包](t-offline.md)后拷贝至网络隔离的环境中使用。

您可以使用以下命令，在待安装Pigsty的元节点上提前下载离线软件包（只需要在单个元节点上下载即可，下载至`/tmp/pkg.tgz`）

```bash
curl https://github.com/Vonng/pigsty/releases/download/v1.5.0-beta/pkg.tgz -o /tmp/pkg.tgz   # Github Release，最权威 
curl http://download.pigsty.cc/v1.5.0-beta/pkg.tgz -o /tmp/pkg.tgz                           # 或在中国大陆用CDN下载
```

此外 pigsty 项目根目录下的 [`download`](https://github.com/Vonng/pigsty/bl/master/download) 脚本也可以用于下载离线软件包。

```bash
./download pkg.tgz    # 从Github/CDN下载当前版本 pkg.tgz至 /tmp/pkg.tgz
./download pkg        # 从Github/CDN下载当前版本 pkg.tgz 并解压至 /www/pigsty
```

最后，百度网盘也提供了离线软件包资源下载：https://pan.baidu.com/s/1DZIa9X2jAxx69Zj-aRHoaw?pwd=8su9


