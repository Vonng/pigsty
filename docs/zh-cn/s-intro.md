# 入门指南


## 新用户

新接触PostgreSQL与Pigsty的用户，数据分析师，数据研发人员，可以从Pigsty官方演示站点：[http://demo.pigsty.cc](http://demo.pigsty.cc)获取第一印象。

Pigsty演示中内置了两个基于Pigsty开发的[数据应用](t-application.md)，用于演示此发型版的能力：
  * WHO新冠疫情数据大盘：[`covid`](http://demo.pigsty.cc/d/covid-overview)
  * 全球地表气象站历史数据查询：[`isd`](http://demo.pigsty.cc/d/isd-overview)


## 开发者（Dev）

开发者更关注的是：如何最快地拥有，并接入数据库。

Pigsty中的数据库，对外以[服务](c-service.md)的方式交付，用户通过PG连接串进行[接入](c-access.md)。

具有研发经验的开发者，可以开始尝试[安装](s-install.md)Pigsty。
Pigsty针对易用性进行了大量优化，在全新CentOS7虚拟机上可以做到一键安装，且无需互联网访问。

用户可以在本机拉起Pigsty[沙箱](s-sandbox.md)。
沙箱是由vagrant托管的本地Virtualbox虚拟机，可运行于用户自己的笔记本上，省去了虚拟机环境搭建的繁琐工作。
用户也可以[准备](t-prepare.md)自建虚拟机，云虚拟机，或生产物理机器来进行标准[部署](t-deploy.md)。

部署完成后，开发者可以参考**教程**中的内容，熟悉[基本管理操作](t-operation.md)，并了解[访问数据库](c-access.md)的方法。

如果您想要深入了解Pigsty本身的设计与架构，可以参考**概念**一章中的主题：
   * [架构](c-arch.md)
   * [实体](c-entity.md)
   * [服务](c-service.md)
   * [接入](c-access.md)
   * [权限](c-privilege.md)
   * [认证](c-auth.md)
   * [配置](c-config.md)
   * [业务用户](c-user.md)
   * [业务数据库](c-database.md)

## 运维人员 （OPS）

运维人员更关注实施部署的细节，以下教程将介绍Pigsty安装部署的细节：

   * [Pigsty部署](t-deploy.md)
   * [Pigsty资源准备](t-prepare.md)
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
  * [定制Patroni模板](t-patroni-template.md)
  * [定制数据库模板](t-customize-template.md)

几乎所有配置项都配置有合理的默认值，无需修改即可使用，专业用户可以参考[配置项文档](v-config.md)按需自行调整。
