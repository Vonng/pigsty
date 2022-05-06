# FAQ: 常见问题

> 这里列出了Pigsty用户常遇到的问题，如果您遇到了难以解决的问题，可以[联系我们](community.md)，或提交[Issue](https://github.com/Vonng/pigsty/issues/new)。



* [准备](#准备)
* [下载](#下载)
* [配置](#配置)
* [安装](#安装)
* [沙箱](#沙箱)
* [监控](#监控)
* [INFRA](#INFRA)
* [NODES](#NODES)
* [PGSQL](#PGSQL)


---------------------------------

## 准备

> 您需要确保机器节点硬件规格与操作系统符合安装要求，详情参见：[准备工作](d-prepare.md)



### 机器节点要求

!> 最小规格 **1C/2GB**，节点处理器为**x86_64**架构，目前不支持 **ARM** 架构。

安装Pigsty需要至少一个机器节点：规格至少为1核2GB，1核1G也可安装但容易OOM。

如果您希望部署自我管理的高可用PostgreSQL数据库集群，建议最少使用3个规格相同的节点。



### 操作系统要求

!> **Pigsty强烈建议使用CentOS 7.8操作系统，可以节省大量无意义的DEBUG时间。**

这是一个经过充分验证的操作系统版本，Pigsty开发、测试、打包都默认基于CentOS 7.8。CentOS 7.6也经过充分的验证。其他CentOS 7.x及其等效版本RHEL7 , Oracle Linux 7理论上没有问题，但并未进行测试与验证。



### 软件版本策略

!> 请使用**特定版本**的Release，不要直接使用Github **Master**分支，该开发分支有可能处于不一致的状态。

Pigsty遵循语义版本号规则: `<major>.<minor>.<release>`。大版本更新意味着重大的根本性架构调整，次版本号增长意味着一次显著更新，通常意味着软件包版本更新，API的微小变动，以及其它增量功能变更，通常会包含一份升级注意事项说明。Release版本号通常用于Bug修复与文档更新，Release版本号增长不会变更软件包版本（即 v1.0.1 与 v1.0.0对应的 `pkg.tgz`是相同的）。

Pigsty计划会每1-3个月发布一个Minor Release，每1-2年发布一个Major Release。



### 沙箱虚拟机置备

!> 使用Vagrant一键拉起基于本地虚拟机的[本地沙箱](d-sandbox.md#本地沙箱)，或使用Terraform在公有云厂商创建[云端沙箱](d-sandbox.md#多云部署)。

部署Pigsty需要用到物理机/虚拟机节点，您可以直接自备物理机/虚拟机用于部署。但IaaS资源置备仍然是一件麻烦事，所以Pigsty提供了基于Vagrant与HashiCorp的IaaS层资源模板，您可以一键获取部署Pigsty4节点沙箱环境所需的虚拟机资源。

沙箱环境是一个配置规格、对象标识符、IP地址与默认数据库全部**预先确定**的环境，由一个元节点与三个普通节点组成，无论是本地版还是云端版都保持一致，用于开发/测试/演示/说明。使用以下命令拉起Vagrant本地沙箱：

```bash
make deps    # 安装homebrew，并通过homebrew安装vagrant与virtualbox（需重启）
make dns     # 向本机/etc/hosts写入静态域名 (需sudo输入密码)
make start   # 使用Vagrant拉起单个meta节点  (start4则为4个节点)
```







---------------------------------

## 下载

> Pigsty源码包是安装Pigsty时的必选项。离线软件包是可选的推荐项，情请参考 [软件下载](d-prepare.md#软件下载)。



### 如何下载Pigsty源码包

!> `bash -c "$(curl -fsSL http://download.pigsty.cc/get)"`

执行以上命令，可自动下载最新稳定版本 `pigsty.tgz` ，并解压至 `~/pigsty`目录。您也可以从下列位置手工下载特定版本的Pigsty[源码包](d-prepare.md#Pigsty源代码)，如果您需要在无互联网的环境中安装，可以提前下载并通过 scp/sftp 等方式上传至生产服务器。

```bash
https://github.com/Vonng/pigsty/releases/download/v1.5.0/pigsty.tgz   # Github Release 
http://download.pigsty.cc/v1.5.0/pigsty.tgz                           # 中国大陆用加速CDN
https://pan.baidu.com/s/1DZIa9X2jAxx69Zj-aRHoaw?pwd=8su9              # 百度云网盘下载
```



### 下载其他Pigsty软件包

!> `./download pigsty pkg app matrix`

Pigsty源码包内提供了一个`download`脚本，用于下载Pigsty相关资源：Pigsty源代码包本身：`pigsty.tgz` /  离线软件安装包：`pkg.tgz` / MatrixDB/Greenplum软件包：`matrix.tgz` / 一些SaaS应用镜像与可视化应用案例：`app.tgz`。其中源码包为必选项，离线软件包 `pkg.tgz`为建议项，使用 `./download pkg` 会自动下载并提取离线软件包。

```bash
# download to /tmp/*.tgz
./download pigsty.tgz   # download pigsty source tarball
./download pkg.tgz      # download pigsty offline pkgs
./download app.tgz      # download extra pigsty apps
./download matrix.tgz   # download matrixdb packages
# download and extract
./download pigsty       # download and extract pigsty to ~/pigsty
./download pkg          # download and extract pkg    to /www/pigsty
./download app          # download and extract app    to ~/app
./download matrix       # download and extract matrix to /www/matrix
```



### 如何下载Pigsty离线软件包

!> `./download pkg` 或在配置过程中根据提示自动下载。

Pigsty的[离线软件包](d-prepare.md#Pigsty离线软件包) `pkg.tgz` 打包了所有所需的软件依赖。在执行Pigsty安装时如果使用离线软件包，可以跳过从互联网下载软件的步骤。

在 [`./configure`](v-config.md#配置过程) 过程中，如果离线安装包`/tmp/pkg.tgz`不存在，向导会提示用户下载，回答“Y”即可自动从Github或CDN下载；回答“N”则会跳过下载。您也可以从下列位置手工下载离线软件包，并放置于 `/tmp/pkg.tgz`，则安装时会自动使用。

```bash
curl https://github.com/Vonng/pigsty/releases/download/v1.5.0/pkg.tgz -o /tmp/pkg.tgz
curl http://download.pigsty.cc/v1.5.0/pkg.tgz -o /tmp/pkg.tgz         # China CDN
https://pan.baidu.com/s/1DZIa9X2jAxx69Zj-aRHoaw?pwd=8su9              # Baidu Yun
```



### 离线软件包出现RPM冲突

!> 不用离线包直接从上游下载，或仅删除问题包并从可用源补缺

Pigsty离线软件包基于CentOS 7.8操作系统制作，如果您使用的不是此精确OS Release，或者并未使用全新安装操作系统的节点进行安装，有小概率会出现RPM包依赖问题。

如果只是个别RPM依赖问题，您可以在 `/www/pigsty` 中删除相关RPM包，并删除标记文件 `/www/pigsty/repo_complete`。而后，执行常规的安装流程时，Pigsty会从 [`repo_upsteram`](v-infra.md#repo_upstream) 指定的上游或其他本地可用源下载缺失的依赖RPM包。如果您没有可用的互联网访问或本地源，请使用相同OS环境的有网节点[制作离线软件包](t-offline.md#制作离线安装包) 后，拷贝至生产环境使用。





---------------------------------

## 配置

> Pigsty的安装、配置、部署都是一键傻瓜式，唯有[配置](v-config.md)是Pigsty的核心灵魂。



### 配置过程做了些什么

!> 检测环境，生成配置，启用离线软件包（可选），安装基本工具Ansible。

当您下载完 Pigsty 源码包，解压并进入其中后，需要先执行 `./configure` 完成环境[配置过程](v-config#配置过程)。

Pigsty会检测当前环境是否满足安装要求，并根据当前机器环境生成推荐配置文件 `pigsty.yml`。在`files/conf/`目录中，有一系列名为`pigsty-*.yml`的配置文件，可以作为不同场景下的配置参考模板，通过`-m`指定。

Configure过程会安装Ansible，一般节点的默认源都带有此软件包，如果离线安装包存在，则会从离线安装包内安装Ansible。



### Pigsty的配置文件在哪

!> 源码根目录下 `pigsty.yml` 是默认的、唯一的配置源。

Pigsty有且仅有一个[配置文件](v-config.md#配置文件)： [`pigsty.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml) ，位于源代码根目录下，它描述了整个环境的状态。

在同一目录的`ansible.cfg`中：`inventory = pigsty.yml` 指定了此文件为默认配置文件，您也可以在执行剧本时，使用`-i`参数，指定使用其他位置的配置文件。此外，如果您使用[CMDB](t-cmdb.md)作为配置源，那么请在CMDB中修改配置。



### 配置文件中的占位IP地址

!> Pigsty使用`10.10.10.10`作为当前节点IP地址占位符，将在配置过程中被替换为当前节点的首要IP地址。

当配置过程检测到当前机器上有多块网卡与多个IP地址时，配置向导会提示您输入**主要**使用的IP地址， 即**用户从内部网络访问该节点时使用的IP地址**，注意请不要使用公网IP地址。

该IP地址，将用于替换配置文件模板中的 `10.10.10.10`。



### 用户需要修改什么配置吗？

!> 单机部署通常啥配置也不用改，会自动调整，绝大多数参数都有合适都默认值。

Pigsty提供了220+配置参数，您可以定制整个基础设施/平台/数据库的方方面面。通常在单机安装的情况下，不需要对配置文件进行任何调整即可直接使用。但仍然有个别参数，如果有需要，可以提前调整：

* 访问Web服务组件时使用的域名：[`nginx_upstream`](v-infra.md#nginx_upstream) （一些服务只能使用域名通过Nginx代理访问）
* Pigsty假设存在一个`/data`目录用于盛放所有数据，如果您的数据盘挂载点与此不同，可以调整这些路径。





---------------------------------

## 安装



### 安装时执行了什么？

!> 执行`make install`安装时，会调用`ansible-playbook`执行预置剧本 [`infra.yml`](infra.yml)，在元节点上完成安装。

`configure`过程默认会生成配置文件，并在其中将当前节点标记为 [元节点](c-nodes.md#元节点)。而`make install`则会针对元节点执行Pigsty元节点初始化剧本  [`infra.yml`](infra.yml) ，部署基础设施组件，并将元节点作为一个普通的节点进行初始化，并在其上部署一个单例PostgreSQL数据库作为CMDB。



### 下载RPM包速度太慢

!> 如果直接从上游下不动，最好还是使用[离线软件包](t-offline.md)，或者配置[代理服务器](v-infra.md#CONNECT)，和可用本地镜像源。

Pigsty已经尽可能使用国内yum镜像进行下载，然而少量软件包仍然受到**GFW**的影响，导致下载缓慢，例如直接从Github下载的相关软件。有以下解决方案：

1. Pigsty提供[离线软件包](t-offline.md)，预先打包了所有软件及其依赖，可以跳过从互联网下载软件的步骤。

2. 通过 [`proxy_env`](v-infra.md#proxy_env) 指定代理服务器，通过代理服务器下载。

3. 通过 [`repo_upsteram`](v-infra.md#repo_upstream) 使用其他国内可用的镜像源。



### 远端节点无法通过标准SSH命令访问

!> 通过主机实例级 [`ansible连接参数`](v-infra.md#ansible_host)，指定不一样的端口。

如果您的目标机器藏在SSH跳板机之后，或者进行了某些定制化修改无法通过`ssh ip`的方式直接访问，则可以考虑使用 **Ansible连接参数**。您可以通过 `ansible_port`指定其他SSH端口，或 `ansible_host` 指定SSH Alias。

```bash
pg-test:
  vars: { pg_cluster: pg-test }
  hosts:
    10.10.10.11: {pg_seq: 1, pg_role: primary, ansible_host: node-1 }
    10.10.10.12: {pg_seq: 2, pg_role: replica, ansible_port: 22223, ansible_user: admin }
    10.10.10.13: {pg_seq: 3, pg_role: offline, ansible_port: 22224 }
```





### 远端节点SSH与SUDO需要密码

!> 使用 `-k` 与 `-K`参数，在提示符时输入密码，参考[管理用户置备](d-prepare.md#管理用户置备) 。

**执行部署与变更时**，您所使用的管理用户**必须**拥有所有节点的`ssh`与`sudo`权限。免密码并非必需，您总是可以在执行剧本时通过`-k|-K`参数传入ssh与sudo的密码，甚至通过 `-e`[`ansible_host`](v-infra.md#connect)`=<another_user>` 使用其他用户来执行剧本。但Pigsty强烈建议为管理用户配置SSH**免密码登陆**与免密码`sudo`。





---------------------------------

## 沙箱 

> Pigsty沙箱提供了标准的开发/测试/演示环境，可以在本地用Vagrant或云端用Terraform快速拉起。



### Vagrant沙箱首次启动太慢

!> 第一次使用Vagrant拉起某个操作系统镜像，会下载对应BOX。

Pigsty沙箱默认使用CentOS 7虚拟机，Vagrant首次启动虚拟机时，会下载`CentOS/7`的ISO镜像Box，尺寸不小。

使用代理可能会提高下载速度，下载CentOS7 Box只需要在首次启动沙箱时进行，后续重建沙箱时会直接复用。

用户也可以选择自行下载CentOS 7 安装ISO镜像手工创建所需虚拟机。



### 阿里云CentOS 7.8 RPM报错

!> 阿里云CentOS 7.8 服务器默认安装了DNS缓存服务 `nscd`，移除即可。

阿里云的CentOS 7.8 服务器镜像默认安装了 `nscd` ，锁死了 glibc 版本，会导致安装时出现RPM依赖错误。

```bash
"Error: Package: nscd-2.17-307.el7.1.x86_64 (@base)"
```

在所有机器上执行 `yum remove -y nscd` 即可解决此问题，使用Ansible可以批量执行：

```bash
ansible all -b -a 'yum remove -y nscd'
```



### 虚拟机时间失去同步

!> `sudo ntpdate -u pool.ntp.org` 或使用 `make sync4`

Virtualbox虚拟机关机后虚拟机内时间可能与宿主机不一致。可以尝试使用以下命令：`make sync`，强制执行NTP时间同步。

```bash
sudo ntpdate -u pool.ntp.org
make sync4 # 使用NTP POOL时间同步快捷方式
make ss    # 使用阿里云NTP服务器同步
```

即可解决长时间休眠或关机重启后监控系统没有数据的问题。此外，重启虚拟机也可以强行重置时间，且无需互联网访问：`make dw4; make up4`。



### 为什么不使用容器盛放数据库

!> 使用Docker/Kubernetes盛放数据库仍然不成熟

虽然Docker对于提高环境兼容性有非常好的效果，然而数据库并不属于容器使用的最佳场景。此外Docker与Kubernetes本身也有使用门槛。为了满足“降低门槛”的主旨，Pigsty采用裸机部署。

Pigsty在设计之初就考虑到容器化云化的需求，这体现在其配置定义的声明式实现中。并不需要太多修改就可以迁移改造为云原生解决方案。当时机成熟时，会使用Kubernetes Operator的方式进行重构。






---------------------------------

## 监控

### 监控系统的性能存储开销有多大

!> 监控查询开销微不足道，百毫秒量级，10秒一次，普通实例约产生2k ~ 5k时间序列。

一个典型的生产实例，产出5千个时间序列，一次抓取大约耗时 200ms 左右；相比抓取周期15s几乎微不足道。

存储取决于用户数据库的复杂程度（workload）。作为参考：200个生产数据库实例1天产生的监控数据量约为16GB。Pigsty默认保留两周的监控数据，可以通过参数调整。



### 是否可以监控已有的PG实例？

!> Pigsty不承诺对外部实例的监控质量：Pigsty创建的PostgreSQL在绝大多数情况下表现显著优于土法手造实例

对于非Pigsty供给方案创建的外部数据库，可以使用[仅监控模式](d-monly.md)部署，详情请参考文档。

如果该实例可以被Pigsty管理，您可以考虑采用与标准部署相同的方式，在目标节点上部署 `node_exporter`,`pg_exporter`, `promtail` 等组件。

如果您只有访问该数据库的URL（例如RDS云数据库实例），则可以使用 **精简监控部署** 模式，在该模式下，Pigsty会通过部署于元节点本地的 `pg_exporter` 实例监控远程PG实例。



### 监控已有PG实例需要怎么做？

!> 

### 监控对象被移除后为什么还能看到

!> 使用 [`pgsql-remove.yml`](p-pgsql.md#pgsql-remove) 剧本移除监控目标





---------------------------------


## INFRA

### 基础设施包括哪些组件？

!> Pigsty提供了一套完整的PaaS环境，详情请参考[**系统架构：基础设施**](c-infra.md#基础设施)

[![](../_media/ARCH.gif)](c-infra.md#基础设施)

Ansible/Pigsty CLI用于发起管理与部署；元节点上的PostgreSQL作为CMDB；Consul Server作为元数据库用于高可用；NTPD与DNS提供时间与域名解析基础服务；Docker作为无状态应用部署底座；Prometheus用于监控指标时序数据收集，Loki用于日志收集；Grafana用于监控/可视化展示，AlertManager用于汇总告警；YumRepo用于提供本地软件源；Nginx对外收拢所有WebUI类服务访问入口。



### 是否可以使用已有的DCS集群

!> Pigsty默认会在元节点上提供DCS服务，但更推荐使用外部的多个节点组成的高可用DCS服务集群。

在 [`dcs_servers`](v-infra.md#dcs_servers)中填入对应的集群，即可使用外部的DCS集群。

DCS Server与元节点并没有对应关系：在默认情况下，Pigsty会在元节点上安装一个单节点的Consul Server。如果在执行节点初始化时当前节点的IP地址在 `dcs_servers` 中被定义，则该节点会配置DCS Server服务。DCS用于其他数据库实例的高可用选主。在生产环境中，建议使用3～5个节点的专用外部DCS集群。







---------------------------------


## NODES

### Abort because consul instance already exists

!> Pigsty提供了DCS误删保护机制，配置`consul_clean = true` 可以硬干。

当目标节点的Consul服务已经存在时，[`nodes.yml`](p-nodes.md#nodes) 会根据 [`consul_clean`](v-nodes.md#consul_clean) 参数采取行动，如果为真，那么在初始化过程中现有的Consul会被抹除。

Pigsty也提供了相应的[保护机制](p-nodes.md#保护机制) 参数： [`consul_safeguard`](v-nodes.md#consul_safeguard)

您可以在配置文件 `pigsty.yml` 中修改这些参数，也可以直接在执行剧本时，通过额外参数机制指定：

```bash
./nodes.yml -e consul_clean=true
```



---------------------------------


## PGSQL

### Abort because postgres instance already exists

!> Pigsty提供了数据库误删保护机制，配置`pg_clean = true` 可以硬干。

当目标节点的PostgreSQL服务已经存在时，[`pgsql.yml`](p-pgsql.md#pgsql) 会根据 [`pg_clean`](v-pgsql.md#pgsql_clean) 参数采取行动，如果为真，那么在初始化过程中现有的PostgreSQL实例会被抹除。

Pigsty也提供了相应的[保护机制](p-pgsql.md#保护机制) 参数： [`pg_safeguard`](v-pgsql.md#pgsql_safeguard)

您可以在配置文件 `pigsty.yml` 中修改这些参数，也可以直接在执行剧本时，通过额外参数机制指定：

```bash
./pgsql.yml -e pg_clean=true
```



### PostgreSQL数据库如何保证高可用

!> Patroni 作为HA Agent，Consul作为DCS，Haproxy作为默认流量分发器，详见[高可用集群](c-pgsql.md#高可用)。

Pigsty使用Patroni代管Postgres，Patroni使用Consul达成领导者共识，当主库故障超过阈值后（30秒），会触发新一轮领导者选举，获胜者成为新的集群主库，所有其他从库追随新的集群主库，原有故障主库上线后会自动降级为从库并追随新主库。

客户端使用HAProxy服务接入数据库，HAproxy使用HTTP健康检查从Patroni处获取主从角色信息，并依此分发流量。Pigsty的数据库集群成员在使用上幂等，只要集群还有任意一个实例存活，读写与只读流量都可以继续工作，访问任意一个实例的5433端口，都可以确保访问集群主库读写服务。

DCS自身的可用性通过多节点共识保证，故生产环境中建议部署3个或更多元节点，或使用外部的DCS集群。





### 如何确保PostgreSQL集群故障不丢数据

!> 使用`pg_conf: crit.yml` 模板，或手工启用同步复制。

Crit模板针对数据一致性和持久性而优化，默认启用同步提交与数据校验和。可以确保在故障切换时没有任何数据损失，并能及时检测上报因存储故障、断电等其他异常情况导致的静默数据腐坏。



### 数据损坏导致拖从库失败

!> 找到问题机器，修改 patroni 配置文件`clonefrom: false`并重载生效

Pigsty默认为PGSQL集群中的所有成员都启用 `cloneform: true` 功能，即，制作从库时可以从该实例上拖取基础备份。如果某个实例因为数据文件损坏无法完成从库制作，那么您可以修改该实例上的Patroni配置文件，将`clonefrom`设置为`false`，以避免从损坏的实例上拉取数据。
