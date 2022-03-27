# 入门指南



## 新用户

新接触PostgreSQL与Pigsty的用户，可以访问Pigsty演示站点：[http://demo.pigsty.cc](http://demo.pigsty.cc) 概览其功能。

Pigsty演示中内置了两个基于Pigsty开发的[数据应用](t-application.md)，用于演示此发型版的能力：
  * WHO新冠疫情数据大盘：[`covid`](http://demo.pigsty.cc/d/covid-overview)
  * 全球地表气象站历史数据查询：[`isd`](http://demo.pigsty.cc/d/isd-overview)

## 安装

Pigsty有两种典型使用模式：**单机**与**集群**。

* **单机**：在单个节点上安装Pigsty，将其作为开箱即用的Postgres数据库使用（开发测试）
* **集群**：在单机部署的基础上，部署、监控、管理其他节点与多种不同种类的数据库（运维管理）

在一台节点上安装Pigsty时，Pigsty会在该节点上部署完整的**基础设施运行时** 与 一个单节点PostgreSQL**数据库集群**。对于个人用户、简单场景、小微企业来说，您可以直接开箱使用此数据库。

Pigsty还可以用作大规模生产环境的集群/数据库管理。您可以从安装Pigsty的节点（又名"管理节点"/"元节点"）上发起控制，将更多节点纳入Pigsty的管理中。
更重要的是，Pigsty还可以在这些节点上部署并管理各式各样的数据库集群与应用：创建高可用的PostgreSQL数据库集群；创建不同类型的Redis集簇；部署 Greenplum / MatrixDB 数据仓库，并获取关于节点、数据库与应用的实时洞察。


## 开发者（Dev）

开发者更关注的问题是：如何最快地[安装](s-install.md)并[访问](c-access.md)数据库。

Pigsty针对易用性进行了大量优化，在全新CentOS 7.8节点上，[无需互联网访问](t-offline.md)即可完成一键安装。

Pigsty提供了预置的 vagrant & terraform 模板，用于在本地x86笔记本/PC或云上一键拉起4台虚拟机，部署[沙箱环境](d-sandbox.md.md)。

用户也可以自行[准备](d-prepare.md)虚拟机，云虚拟机，或生产物理机器来进行标准[部署](d-deploy.md)流程。

Pigsty中的数据库，对外以[服务](c-service.md)的方式交付，用户通过PG连接串进行[接入](c-access.md)。

部署完成后，开发者可以参考**教程**中的内容，熟悉[基本管理操作](t-operation.md)，并了解[访问数据库](c-access.md)的方法。

如果您想要深入了解Pigsty本身的设计与架构，可以参考**概念**一章中的主题：
   * [架构](c-arch.md)
   * [实体](c-entity.md)
   * [服务](c-service.md#服务)
   * [接入](c-service.md#接入)
   * [权限](c-privilege.md#权限)
   * [认证](c-privilege.md#认证)
   * [配置](v-config.md)
   * [业务用户](c-pgdbuser.md#用户)
   * [业务数据库](c-pgdbuser.md#数据库)

## 运维人员 （OPS）

运维人员更关注实施部署的细节，以下教程将介绍Pigsty安装部署的细节：

   * [Pigsty部署](d-deploy.md)
   * [Pigsty资源准备](d-prepare.md)
   * [制作离线安装包](t-offline.md)
   * [基础设施初始化](p-infra.md)
   * [数据库初始化](p-pgsql.md)

其中，教程[升级Grafana后端数据库](t-grafana-upgrade.md)展示了一个完整的，具有代表性的案例：
搭建并使用一套专供Grafana使用的Postgres数据库集群，将上述主题的内容付诸于实践。



## 管理员（DBA）

DBA通常更关注监控系统的用法与日常维护的具体方式。

#### 监控系统教程
   * 监控系统架构
   * [监控指标简介](m-metric.md)
   * [监控面板简介](m-dashboard.md)
   * [告警系统简介](r-alert.md)
   * [服务发现机制](m-discovery.md)
   * [部署日志收集组件](t-logging.md)
   * [分析CSV日志](t-log-analysis.md)
   * 分析定位慢查询
   * 常见故障的症状

#### 日常维护管理
   * 数据库集群扩缩容
   * [数据库集群下线](p-pgsql-remove.md)
   * [创建新业务数据库](p-pgsql-createdb.md)
   * [创建新业务用户](p-pgsql-createuser.md)
   * [备份与恢复](t-backup.md)
   * 修改HBA规则

## 专业用户

对于专业用户（深度定制，二次开发），Pigsty提供了丰富的配置项与定制接口。

  * [配置Pigsty](v-config.md#配置项清单)
  * [定制数据库模板](v-pgsql-customize.md)

几乎所有配置项都配置有合理的默认值，无需修改即可使用。

专业用户可以参考[配置项文档](v-config.md)按需自行调整。
