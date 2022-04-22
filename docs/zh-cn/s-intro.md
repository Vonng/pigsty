# Pigsty入门指南

不同的用户有不同的关注点，如果遇到问题，欢迎查阅[FAQ](s-faq.md)，提交[Issue](https://github.com/Vonng/pigsty/issues/new)，或向[社区](community.md)求助。



## 新用户

新接触PostgreSQL与Pigsty的用户，可以访问Pigsty演示站点：[http://demo.pigsty.cc](http://demo.pigsty.cc) 概览其功能。

Pigsty演示中内置了两个基于Pigsty开发的[数据应用](t-application.md)，用于演示此发行版的能力：
  * WHO新冠疫情数据大盘：[`covid`](http://demo.pigsty.cc/d/covid-overview)
  * 全球地表气象站历史数据查询：[`isd`](http://demo.pigsty.cc/d/isd-overview)


## 开发者（Dev）

开发者更关注的问题是：如何最快地[下载](d-prepare.md#软件下载)，[安装](s-install.md)并[接入](c-service.md#接入)数据库，请参考 [快速上手](s-install.md)

Pigsty针对易用性进行了大量优化，在全新CentOS 7.8节点上，[无需互联网访问](t-offline.md)即可完成一键安装。

Pigsty提供了预置的 [Vagrant](d-sandbox.md#本地沙箱) & [Terraform](d-sandbox.md#云端沙箱) 模板，用于在本地x86笔记本/PC或云上一键拉起4台虚拟机，部署[沙箱环境](d-sandbox.md.md)。

用户也可以自行[准备](d-prepare.md)虚拟机，云虚拟机，或生产物理机器来进行标准[部署](d-deploy.md)流程。

Pigsty中的数据库，对外以[服务](c-service.md)的方式交付，用户通过PG连接串进行[接入](c-service.md#接入)。

部署完成后，开发者可以参考**教程**中的内容，熟悉[基本管理操作](r-sop.md)，并了解[访问数据库](c-service.md#接入)的方法。

如果您想要深入了解Pigsty本身的设计与架构，可以参考**概念**一章中的主题：
   * [架构](c-arch.md)
   * [实体](c-entity.md)
   * [配置](v-config.md)
   * [PGSQL服务](c-service.md#服务) 与 [PGSQL接入](c-service.md#接入)
   * [PGSQL权限](c-privilege.md#权限) 与 [PGSQL认证](c-privilege.md#认证)
   * [PGSQL业务用户](c-pgdbuser.md#用户) 与 [PGSQL业务数据库](c-pgdbuser.md#数据库)

   


## 运维人员 （OPS）

运维人员更关注实施部署的细节，以下教程将介绍Pigsty安装部署的细节：

   * [Pigsty部署](d-deploy.md)
   * [Pigsty资源准备](d-prepare.md)
   * [制作离线安装包](t-offline.md)
   * [基础设施初始化](p-infra.md)
   * [PostgreSQL数据库初始化](p-pgsql.md)
   * [Redis数据库初始化](p-redis.md)

其中，教程[升级Grafana后端数据库](t-grafana-upgrade.md)展示了一个完整的，具有代表性的案例：搭建并使用一套专供Grafana使用的Postgres数据库集群，将上述主题的内容付诸于实践。



## 管理员（DBA）

DBA通常更关注监控系统的用法与日常维护的具体方式。

#### 监控系统教程

- [监控指标简介](m-metric.md)
- [监控面板简介](m-dashboard.md)
- [告警系统简介](r-alert.md)
- [服务发现机制](m-discovery.md)
- [分析CSV日志](t-application.md#PGLOG)


#### 日常维护管理

- [集群创建/扩容](r-sop.md#case-1：集群创建扩容)
- [集群下线/缩容](r-sop.md#Case-2：集群下线缩容)
- [集群配置变更/重启](r-sop.md#Case-3：集群配置变更重启)
- [集群业务用户创建](r-sop.md#Case-4：集群业务用户创建)
- [集群业务数据库创建](r-sop.md#Case-5：集群业务数据库创建)
- [集群HBA规则调整](r-sop.md#Case-6：集群HBA规则调整)
- [集群流量控制](r-sop.md#Case-7：集群流量控制)
- [集群角色调整](r-sop.md#Case-8：集群角色调整)
- [监控对象调整](r-sop.md#Case-9：监控对象调整)
- [集群主从切换](r-sop.md#Case-10：集群主从切换)
- [重置组件](r-sop.md#Case-11：重置组件)
- [替换集群DCS服务器](r-sop.md#Case-12：替换集群DCS服务器)


## 专业用户

对于专业用户（深度定制，二次开发），Pigsty提供了丰富的[配置项](v-config.md#配置项)与定制接口。

几乎所有配置项都配置有合理的默认值，无需修改即可使用。专业用户可以参考[配置项文档](v-config.md)按需自行调整或按需[定制](v-pgsql-customize.md)。
