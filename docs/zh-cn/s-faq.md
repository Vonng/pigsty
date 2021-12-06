## 下载问题

#### **源码包从哪里下载？**

Pigsty源码包：`pigsty.tgz` 可以从以下位置获取：

* [Github Release](https://github.com/Vonng/pigsty/releases) 是最权威最全面的下载地址，包含所有历史发行版本。
* 大陆用户无法访问Github时，可以访问百度云盘下载：[https://pan.baidu.com/s/1DZIa9X2jAxx69Zj-aRHoaw](https://pan.baidu.com/s/1DZIa9X2jAxx69Zj-aRHoaw) (提取码: `8su9`)
* 如果用户需要进行离线安装，则可以预先从Github或其他渠道下载源码包与离线安装包，并通过scp，ftp等方式上传至服务器。

```bash
curl -SL https://github.com/Vonng/pigsty/releases/download/1.3.1/pigsty.tgz -o ~/pigsty.tgz
```

-----------

#### **源码包的版本策略**

Pigsty遵循语义版本号规则: `<major>.<minor>.<release>`。大版本更新意味着重大的根本性架构调整（通常不会发生），
次版本号增长意味着一次显著更新，通常意味着软件包版本更新，API的微小变动，以及其它增量功能变更，通常会包含一份升级注意事项说明。
release版本号通常用于Bug修复与文档更新，Release版本号增长不会变更软件包版本（即 v1.1.0 与 v1.0.0对应的 `pkg.tgz`是相同的）。

-----------

#### 离线安装包从哪里下载？

`configure`过程中，如果离线安装包`/tmp/pkg.tgz`不存在，将会自动提示用户下载，默认从Github Release下载。

如果用户需要在**没有互联网访问**，或Github访问受限的环境下进行安装，就需要自行下载并将其上传至目标服务器指定位置。

```bash  
# curl -SL https://github.com/Vonng/pigsty/releases/download/1.3.1/pkg.tgz    -o /tmp/pkg.tgz
```

-----------

#### 离线安装包如何使用

将下载好的离线安装包`pkg.tgz`，其放置于安装机器的 `/tmp/pkg.tgz` 路径下，即可在安装过程中自动使用。

离线软件包默认会解压至：`/www/pigsty`。在安装过程中， 当`/www/pigsty/`目录与标记文件 `/www/pigsty/repo_complete` 同时存在时，Pigsty将直接使用该软件包，跳过冗长的下载环节。

-----------

#### 不使用离线安装包？

离线安装包中包含了从各路Yum源与Github Release中收集下载的软件包，用户也可以选择不使用预先打包好的离线安装包，而是直接从原始上游下载。

当`/www/pigsty/`目录不存在，或者标记文件 `/www/pigsty/repo_complete`不存在时，Pigsty会从 [`repo_upsteram`](v-repo#repo_upstream) 指定的原始上游下载所有软件依赖。

不使用离线安装包只需要在`configure`过程中提示下载时选择否 `n`即可。

-----------

#### 安装yum软件包时报错

默认的离线软件安装包基于CentOS 7.8.2003 Linux x86_64 环境制作，在全新安装该操作系统的节点上可以确保安装成功。

绝大多数CentOS 7.x及其兼容发行版，可能有极个别软件包存在依赖问题。当用户使用非 CentOS 7.8.2003 操作系统版本时需要注意。

如果出现RPM依赖与版本问题，可以考虑不使用离线安装，直接从上游Repo下载正确的RPM依赖包，通常可以使用这种方式解决绝大多数依赖错漏问题。

如果只有零星个别的RPM包有兼容性问题，您可以考虑删除`/www/pigsty`中出现问题的相关RPM包，以及`/www/pigsty/repo_complete`标记文件，
这样在标准安装中，只会实际下载缺失的问题RPM包，加快速度。

-------------

#### **有些软件包下载速度太慢**

Pigsty已经尽可能使用国内yum镜像进行下载，然而少量软件包仍然受到**GFW**的影响，导致下载缓慢，例如直接从Github下载的相关软件。有以下解决方案：

1. Pigsty提供**离线软件安装包**，预先打包了所有软件及其依赖。在`configure`时会自动提示下载。

2. 通过[`proxy_env`](v-connect#proxy_env)指定代理服务器，通过代理服务器下载，或直接使用墙外服务器。


-----------

#### **Vagrant沙箱第一次启动太慢**

Pigsty沙箱默认使用CentOS 7虚拟机，Vagrant首次启动虚拟机时，会下载`CentOS/7`的ISO镜像Box，尺寸不小。（当然用户也可以选择自行下载CentOS 7 安装盘ISO安装）。
使用代理会提高下载速度，下载CentOS7 Box只需要在首次启动沙箱时进行，后续重建沙箱时会直接复用。


-----------

#### 1.0 GA意味着什么？

Pigsty从0.3版本开始就实际应用于真实世界的生产环境中，并不是1.0才真正General Available。
1.0是一个里程碑节点，对监控系统进行了彻底的升级改造，1.0后的新版本都会给出版本升级方案指导。


-----------

#### **编辑Pigsty配置文件的GUI工具是什么？**

一个单独的命令行工具[`pigsty-cli`](https://github.com/Vonng/pigsty-cli)，目前处于beta状态。


-----------







## 环境问题


#### **Pigsty的安装环境**

安装Pigsty需要至少一个机器节点：规格至少为1核2GB，采用Linux内核，安装CentOS 7发行版，处理器为x86_64架构。建议使用**全新**节点（刚装完操作系统）。

在生产环境中，建议使用更高规格的机器，并部署**多个管理节点**作为容灾冗余。生产环境中**管理节点**负责发出控制命令，管理部署数据库集群，采集监控数据，运行定时任务等。

-----------


#### **Pigsty的操作系统要求**

Pigsty强烈建议使用CentOS 7.8操作系统安装元节点与数据库节点，这是一个经过充分验证的操作系统版本，可以有效避免将精力消耗在无谓的问题上。

Pigsty的默认开发、测试、部署环境都基于CentOS 7.8，CentOS 7.6也经过充分的验证。其他CentOS 7.x及其等效版本RHEL7 , Oracle Linux 7理论上没有问题，但并未进行测试与验证。

Pigsty在使用仅监控模式监控已有的PostgreSQL实例时，对目标节点的操作系统没有要求。


-----------

#### 为什么不使用Docker与Kubernetes？

虽然Docker对于提高环境兼容性有非常好的效果，然而数据库并不属于容器使用的最佳场景。此外Docker与Kubernetes本身也有使用门槛。为了满足“降低门槛”的主旨，Pigsty采用裸机部署。

Pigsty在设计之初就考虑到容器化云化的需求，这体现在其配置定义的声明式实现中。并不需要太多修改就可以迁移改造为云原生解决方案。当时机成熟时，会使用Kubernetes Operator的方式进行重构。


-----------







## 集成问题


#### **是否可以监控已有的PG实例？**

对于非Pigsty供给方案创建的外部数据库，可以使用[仅监控模式](t-monly.md)部署，详情请参考文档。

如果该实例可以被Pigsty管理，您可以考虑采用与标准部署相同的方式，在目标节点上部署 node_exporter, pg_exporter 等组件。

如果您只有访问该数据库的URL（例如RDS云数据库实例），则可以使用 仅监控部署 模式，在该模式下，Pigsty会通过部署于管理节点本地的 pg_exporter 实例监控远程PG实例。


#### **是否可以使用已有的DCS集群**

当然可以，只需要在 [`dcs_servers`](v-meta.md#dcs_servers)) 中填入对应的集群，即可使用外部DCS集群。


#### **是否可以使用已有的Grafana与Prometheus实例**

Pigsty在安装过程中会直接在管理节点上安装与配置Prometheus与Grafana，并在创建/销毁 实例/集群 时维护其中的配置。

因此不支持使用已有Prometheus与Grafana，但您可以将Prometheus的配置文件`/etc/prometheus`，以及Grafana的所有面板与数据源复制至新集群中。



-----------

## 监控系统问题

-----------

#### **为什么PG Instance Log面板没有数据？**

日志收集目前是一个Beta特性，需要额外的安装步骤。执行`make logging`会安装`loki`与`promtail`，执行后该面板方可用。

详情请参考：[启用实时日志收集](t-logging.md)

loki是比较新的日志收集方案，不是所有人都愿意接受，因此作为选装项目。

-----------

#### **监控系统的数据量有多大？**

这取决于用户数据库的复杂程度（workload），作为参考：200个生产数据库实例1天产生的监控数据量约为16GB。Pigsty默认保留两周的监控数据，可以通过参数调整。

-----------




## 架构问题

#### Pigsty都装了什么东西？

详情请参考[**系统架构**](c-arch.md)

![](../_media/infra.svg)

Pigsty是一套带有完整运行时的数据库解决方案。在本机上，Pigsty可以作为开发、测试、数据分析的环境。在生产环境中，Pigsty可以用于部署，管理，监控大规模PostgreSQL集群。

-----------


#### **Pigsty数据库如何保证高可用**

Patroni 2.0作为HA Agent，Consul作为DCS，Haproxy作为默认流量分发器。Pigsty的数据库集群成员在使用上幂等：只要集群还有任意一个实例存活，读写与只读流量都可以继续工作。

DCS自身的可用性通过多节点共识保证，故生产环境中建议部署3个或更多管理节点，或使用外部的DCS集群。

-----------



## 软件问题


#### 使用**ipython**时报错。

这是因为当前版本`pip3`默认安装的ipython版本存在BUG：其依赖`jedi`的版本过高（`0.18`）。您需要手动安装低版本的`jedi`（`0.17`）：

```bash
pip3 install jedi==0.17.2
```

-----------

#### 关机后虚拟机内没有监控数据

Virtualbox虚拟机关机后虚拟机内时间可能与宿主机不一致。

可以尝试使用以下命令：`make sync`，强制执行NTP时间同步。

```bash
sudo ntpdate -u pool.ntp.org
```

即可解决长时间休眠或关机重启后监控系统没有数据的问题。






## DCS相关问题


-----------
#### Abort because consul instance already exists

在执行数据库&基础设施初始化时，为了避免误删库，提供了一个保护机制。

当Pigsty发现Consul已经在运行时，会根据参数 [`dcs_exists_action`](v-dcs.md#dcs_exists_action) 来采取不同的行为

默认 `abort` 意味着整个剧本的执行会立即中止。 `clean` 则会强制关停删除现有实例，请谨慎使用此参数。

此外，若参数 [`dcs_disable_purge`](v-dcs.md#dcs_disable_purge) 为真，则 `dcs_exists_action` 将会强制配置为 `abort`，以免误删DCS实例。


-----------



## Postgres相关问题

-----------
#### Abort because postgres instance already exists

在执行数据库&基础设施初始化时，为了避免误删Postgres实例，提供了一个保护机制。

当Pigsty发现Postgres已经在运行时，会根据参数 [`pg_exists_action`](v-pg-provision.md#pg_exists_action) 来采取不同的行为

默认 `abort` 意味着整个剧本的执行会立即中止。 `clean` 则会强制关停删除现有实例，请谨慎使用此参数。

此外，若参数 [`pg_disable_purge`](v-pg-provision.md#pg_disable_purge) 为真，则 `pg_exists_action` 将会强制配置为 `abort`，以免误删数据库实例。


-----------