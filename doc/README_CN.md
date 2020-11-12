# Pigsty —— 图形化PostgreSQL环境

> PIGSTY: Postgres in Graphic STYle （图形化PostgreSQL环境）
>
> ![](logo/logo-full.svg)

Pigsty针对大规模数据库集群监控与管理而设计，提供简单便利的高可用数据库供给管理方案与业界一流的图形化的监控管理界面。Pigsty旨在降低数据库使用与管理的门槛，提高PostgreSQL数据库使用管理水平的下限。

本项目经过真实生产环境的长期考验，亦提供基于[vagrant](https://vagrantup.com/)的四虚拟机沙箱环境用于功能演示。

本项目采用Apache License 2.0，可免费用于开发测试生产商业，作者不对使用本项目导致的任何损失负责，但亦有可选的商业支持。

[English Document](../README.md)



## 功能简介

### 亮点

* 专门针对PostgreSQL设计的[监控系统](monitoring-system.md)，开箱即用，遵循监控最佳实践。
* PostgreSQL数据库集群[供给方案](provision.md)，一键拉起，全面定制化，扩缩自如。
* [高可用](ha.md)数据库集群，故障自愈，秒级切换。
* 基于DCS的配置管理与[自动服务发现](service-discovery.md)
* [离线安装](offline-installation.md)所有组件，无需外网访问
* [参数定制](configuration.md)，代码定义的基础设施，完全客制化
* 优化方案模板，带有四种预设方案：OLTP，OLAP，核心库，虚拟机。覆盖绝大多数场景
* 使用简单，声明式的配置参数，幂等的剧本，本地演示沙箱。
* 支持PostgreSQL 13与Patroni 2.0，在CentOS 7下进行充分测试
* 免费，可选商业支持。



### 监控系统

Pigsty提供了开箱即用的监控系统，针对大规模数据库集群管理而设计。查看[监控系统简介](monitoring-system.md)获取更多信息。

Pigsty提供了全方位多维度多层次的系统洞察。系统提供了概览，分片，集群，服务，实例，节点，数据库，对象八个层次的监控，可以通过丰富的导航连接迅速下钻上卷。每个实例都有至少3000+监控指标，并在几十个监控面板中进行分类展示。

Pigsty的监控系统遵循业内最佳实践，基于Prometheus与Grafana研发，便于与其他现有监控系统集成整合。

![](img/pg-overview.jpg)

### 供给方案

Pigsty针对大规模数据库集群监控与管理而设计，用户可以通过类似Kubernetes清单的方式声明，创建，修改，扩缩容PostgreSQL数据库集群。修改配置文件，并运行幂等的Ansible剧本，即可一键将目标实例调整至声明的状态。

详情可以参考[系统架构](architecture.md)与[配置手册](configuration.md)

```bash
# 常用管理操作 （创建新集群/修改新集群/添加&移除实例）
vi conf/all.yml           # 编辑配置文件，声明集群状态
./ins-add.yml  -l <host>  # 根据配置文件创建&修改实例
./ins-del.yml  -l <host>  # 移除实例

# 其他操作
./infra.yml -l meta      --tags repo_download  # 根据配置中的列表更新本地yum源的包
./infra.yml -l <host>    --tags dcs      -e dcs_exists_action=clean  # 重置<host>上的节点
./postgres.yml -l <host> --tags postgres -e pg_exists_action=clean   # 重制<host>上的实例
./postgres.yml -l <host> --tags proxy          # 调整<host>上的负载均衡器
./postgres.yml -l <host> --tags monitor        # 重新部署<host>上的监控系统组件
```

以本项目自带的vagrant 4节点沙箱演示环境为例，沙箱的[Vagrantfile](vagrant/Vagrantfile)定义了一个由四个虚拟机节点组成的集群: `meta` , `node-1` , `node-2`, `node-3`，执行`make new`将初始化一套下图所示的环境。

![](img/arch.png)

### 高可用

Pigsty内置了基于Patroni 2.0的高可用方案，详情请参考[高可用简介](ha.md)。

在Pigsty的监管下，常规故障均可自愈，保障业务平稳运行。

故障转移与手工切换极为简单且丝般顺滑，可在秒级内完成切换，且不会影响从库查询。（PG13）

![](img/proxy.png)

```bash
# 在集群任意一台实例上以postgres用户执行，一行命令完成Failover
$ pt failover
Candidate ['pg-test-2', 'pg-test-3'] []: pg-test-3
Current cluster topology
+ Cluster: pg-test (6886641621295638555) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Leader  | running |  1 |           | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  1 |         0 | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Replica | running |  1 |         0 | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+
Are you sure you want to failover cluster pg-test, demoting current master pg-test-1? [y/N]: y
+ Cluster: pg-test (6886641621295638555) -----+----+-----------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+
| pg-test-1 | 10.10.10.11 | Replica | running |  2 |         0 | clonefrom: true |
| pg-test-2 | 10.10.10.12 | Replica | running |  2 |         0 | clonefrom: true |
| pg-test-3 | 10.10.10.13 | Leader  | running |  2 |           | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+
```

### 服务发现

Pigsty内置了基于DCS的配置管理与自动服务发现，用户可以直观地察看系统中的所有节点与服务信息，以及健康状态。Pigsty中的所有服务都会自动注册至DCS中，因此创建、销毁、修改数据库集群时，元数据会自动修正，监控系统能够自动发现监控目标，无需手动维护配置。

目前仅支持Consul作为DCS，用户亦可通过Consul提供的DNS与服务发现机制，实现基于DNS的自动流量切换。

![](img/service-discovery.jpg)

### 离线安装

Pigsty支持离线安装，针对没有互联网访问的生产环境部署尤为实用。

Pigsty带有一个本地Yum源，集成了所有需要的软件包与依赖，可以在裸机上获得如Docker般的丝滑体验，显著提升系统交付速度并杜绝联网安全隐患。



## 快速开始

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



## 配置要求

**操作系统**

* CentOS 7  ，建议使用CentOS 7.6+，在最小安装环境下进行过充分测试

**最低配置**

* 自包含单节点，自身即为控制节点，包含单实例数据库集群`pg-meta`。
* 最低配置要求：CPU 2核，内存2GB，更小的内存可能发生组件OOM

**演示环境 ( TINY模板，vagrant沙箱)**

* 四节点，包含一个控制节点与三个数据库节点。单实例数据库集群`pg-meta`与三实例数据库集群`pg-test`
* 推荐配置要求，控制节点2核8GB，数据库节点1核1G

**生产环境 ( OLTP/OLAP/CRIT模板 )**

* 200+节点，包含三个控制节点与300+数据库节点。约100套数据库集群

* 默认使用配置：64核，400GB，3TB PCI-E SSD



## 支持

Pigsty是一个开源系统，欢迎各位贡献[PR](https://github.com/Vonng/pigsty/pulls)或[ISSUE](https://github.com/Vonng/pigsty/issues)。

Pigsty亦提供可选的商业支持，包括下列扩展内容与服务支持。

* 完整的监控系统，包含约三千余项监控指标。
* 额外的监控面板，提供更为丰富的集群监控信息。
* 生产级部署运维管理方案
* 元数据库建设，全局数据字典
* 日志收集系统，日志摘要信息聚合汇总
* 备份/恢复，并发备份、延时备份、备份校验等一条龙解决方案
* 协助部署，系统集成，对接监控报警基础设施或接入已有数据库
* n x 24小时支持与答疑，故障诊断服务
* 其他定制化需求

更多信息请参考 [商业支持](support.md)



## 路线规划

[项目路线规划](doc/roadmap.md)



## 关于

作者：冯若航  ([fengruohang@outlook.com](mailto:fengruohang@outlook.com))

[Apache Apache License Version 2.0](LICENSE)


