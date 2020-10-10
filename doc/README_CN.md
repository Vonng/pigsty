# Pigsty —— 图形化PostgreSQL环境

> PIGSTY: Postgres in Graphic STYle （图形化PostgreSQL环境）

本项目为图形化PostgreSQL（`pigsty`）的演示项目，带有一套高可用集群方案与集成的监控系统。

本项目经过真实生产环境的长期考验，可以直接用于开发，测试、生产，并提供基于[vagrant](https://vagrantup.com/)的四虚拟机沙箱环境用于功能演示。

[English Document](../README.md)

![](img/logo-small.jpg)

## 亮点

* 高可用PostgreSQL数据库集群，生产验证的部署方案，用于管理维护大规模数据库集群
* 自包含的监控、报警、日志收集系统
* 基于DCS的配置管理与自动服务发现
* 离线安装所有组件，无需外网访问
* 代码定义的基础设施，完全客制化
* 预设四种优化方案：OLTP，OLAP，核心库，虚拟机
* 使用简单，声明式的配置参数，幂等的剧本，本地演示沙箱。
* 支持PostgreSQL 13与Patroni 2.0，在CentOS 7下进行了充分测试




## 快速开始

1. **准备机器**

   使用预分配好的机器，或基于预定义的沙箱[Vagrantfile](../vagrant/Vagrant)在本地生成演示虚拟机，选定一台作为中控机。

   配置中控机到其他机器的SSH免密码访问，并确认所使用的的SSH用户在机器上具有免密码`sudo`的权限。

   使用Vagrant演示沙箱环境初始化虚拟机的过程可以参考：([Vagrant Provision Guide](vagrant-provision.md))

2. **准备项目**

   在中控机上安装Ansible，克隆本项目，并下载可选的离线安装包。（离线安装请参考[离线安装指南](bootstrap.md) ）

   ```bash
   git clone https://github.com/vonng/pigsty && cd pigsty 
   ```

3. **修改配置**

   **按需修改配置文件**。配置文件使用YAML格式与Ansible清单语义，格式参考 ([配置教程](configuration.md))

   ```bash
   vi conf/all.yml			# 默认配置文件路径
   ```

  4. **初始化基础设施**

     ```bash
     ./infra.yml         # 执行此剧本，将基础设施定义参数实例化
     ```

  5. **初始化数据库集群**

     ```bash
     ./postgres.yml     # 执行此剧本，将所有数据库集群定义实例化
     ```

6. **开始探索**

   执行`sudo make dns`可以将沙箱所需域名写入本机`/etc/hosts`，亦可直接通过IP端口访问。

   访问 http://pigsty 进入系统主页。监控系统Grafana的默认密码为admin:admin。详情参阅[监控系统介绍]()



## 架构概览

以沙箱演示环境为例，沙箱的[Vagrantfile](vagrant/Vagrantfile)定义了一个由四个虚拟机节点组成的集群: `meta` , `node-1` , `node-2`, `node-3`. 

### 集群架构

![](img/arch.png)

* 节点运行有`postgres`, `pgbouncer`, `patroni`, `haproxy`, `node_exporter`, `pg_exporter`, `pgbouncer_exporter`,`consul`等服务
* 集群中有两套数据库集群：`pg-meta` 与 `pg-test`。其中`pg-test`为一主两从结构，`pg-meta`为单主结构。
* `meta`节点上运行有基础设施服务：`nginx`, `repo`, `ntp`, `dns`, `consul server/etcd`, `prometheus`, `grafana`, `alertmanager`等
* 接入层使用DNS与VIP对外暴露服务，将流量导引至对应的服务节点（可选）。

### 服务概览

用户可以通过多种方式访问数据库服务

在实例层次，可以通过5432端口直连Postgres数据库，也可以通过6432端口经由Pgbouncer访问数据库。即可以通过IP地址直接访问，也可以通过节点域名解析访问。

在集群层次，每个集群带有一个可选的绑定至主库所在节点的VIP。可以通过VIP访问主库实例。同时，集群中的所有成员都运行有无状态的Haproxy负载均衡器。访问任意一个Haproxy实例都可以将只读流量与读写流量路由至集群的对应实例上。Haproxy本身的高可用亦通过绑定在主库的VIP实现。

![](img/proxy.png)

[Database Access Guide](doc/database-access.md) 介绍了访问数据库的方式与可选配置。



## 配置要求

**系统环境**

* CentOS 7  ，建议使用CentOS 7.6，在最小安装环境下进行过充分测试

**最低配置**

* 自包含单节点，自身即为控制节点，包含单实例数据库集群`pg-meta`。
* 最低配置要求：CPU 2核，内存2GB

**演示环境 ( TINY模板，vagrant沙箱)**

* 四节点，包含一个控制节点与三个数据库节点。单实例数据库集群`pg-meta`与三实例数据库集群`pg-test`
* 推荐配置要求，控制节点2核8GB，数据库节点1核1G

**生产环境 ( OLTP/OLAP/CRIT模板 )**

* 200+节点，包含三个控制节点与300+数据库节点。约100套数据库集群

* 默认使用配置：64核，400GB，3TB PCI-E SSD



## 商业支持

Pigsty提供商业支持，包括下列扩展内容与服务支持，详情请[联系](mailto:fengruohang@outlook.com)。

* 完整的监控系统，包含约三千余项监控指标，几十幅信息详实美观精准的监控面板
* 生产级部署运维管理方案
* 元数据库建设，全局数据字典
* 日志收集系统，日志摘要信息聚合汇总
* 备份/恢复，并发备份、延时备份、备份校验等一条龙解决方案。
* 协助部署，系统集成，对接监控报警基础设施或接入已有数据库
* n x 24小时支持与答疑，故障诊断服务。



## 路线规划

[Roadmap](doc/roadmap.md)



## 关于猪圈

作者：冯若航  ([fengruohang@outlook.com](mailto:fengruohang@outlook.com))

[Apache Apache License Version 2.0](LICENSE)


