# Pigsty

## v1.4.0 中文文档

**开箱即用**的**开源**PostgreSQL**发行版**。

[![logo](../_media/icon.svg)](/)

> 最新版本: [v1.4.0](https://github.com/Vonng/pigsty/releases/tag/v1.4.0)  |  [Github项目](https://github.com/Vonng/pigsty) | [公开Demo](http://home.pigsty.cc)
>
> 文档地址: [英文文档](https://pigsty.cc/) | [中文文档](https://pigsty.cc/#/zh-cn/) | [Github Pages文档](https://vonng.github.io/pigsty/#/)


## Pigsty是什么？

* **开箱即用** 的PostgreSQL[数据库发行版](s-feature.md#PostgreSQL数据库发行版)
* **自动驾驶** 的智能监控管控[运维解决方案](s-feature.md#开源监控管控运维解决方案)
* **简单易用** 的数据库即代码[开发者工具箱](s-feature.md#数据库即代码开发者工具箱)
* **降本增效** 的开源云数据库[整体替代方案](s-feature.md#开源云数据库整体替代方案)

[![](../_media/WHAT_ZH.svg)](s-feature.md)


**Pigsty** 是开源的数据库发行版，以 **PostgreSQL** 为核心，带有全面专业的**监控系统**，与简单易用的**高可用**数据库部署管控方案，一次性解决个人与中小企业使用数据库时会遇到的一系列问题。

Pigsty基于开源数据库内核与扩展插件进行封装与整合，将顶级DBA在实际生产环境的经验沉淀为产品，为用户提供开箱即用的数据库 (PostgreSQL, Redis, Greenplum, etc...)使用体验。

相比使用云数据库，简运维、低成本、全功能、优体验，可节约 **50% ~ 80%** 的软硬件成本，并显著节省数据库运维人力。对各类企业用户、ISV、个人用户都具有显著的价值与吸引力。

更多特性说明，请参考 [亮点特性](s-feature.md) 一节。


## 快速上手

准备全新机器节点一台，**Linux x86_64 CentOS 7.8**，确保您可以登陆该节点并免密码执行`sudo`命令。

```bash
bash -c "$(curl -fsSL http://download.pigsty.cc/get)" # 下载
cd ~/pigsty && ./configure                            # 配置
make install                                          # 安装
```

更多安装细节，请参考 [快速上手](s-install.md)。

[![](../_media/HOW_ZH.svg)](s-install.md)



## 亮点特性


### PostgreSQL数据库发行版

> RedHat for Linux! 开箱即用！ 从无到有，让用户**用得上**！

* Pigsty深度整合最新 [PostgreSQL](https://www.postgresql.org/) 内核 (14) 与强力扩展：时序数据 [TimescaleDB](https://www.timescale.com/) 2.6，地理空间 [PostGIS](https://postgis.net/) 3.2，分布式 [Citus](https://www.citusdata.com/) 10，及上百+海量扩展插件，全部开箱即用。

* Pigsty打包了大规模生产环境所需的基础设施：[Grafana](https://grafana.com/)，[Prometheus](https://prometheus.io/)，[Loki](https://grafana.com/oss/loki/)，[Ansible](https://docs.ansible.com/)，[Consul](https://www.consul.io/)，[Docker](https://www.docker.com/)等， 亦可作为部署监控其他数据库与应用的运行时。

* Pigsty集成了数据分析生态的常用工具：[Jupyter](https://jupyter.org/)，[ECharts](https://echarts.apache.org/zh/index.html)，[Grafana](https://grafana.com/)，[PostgREST](https://postgrest.org/)，[Postgres](https://www.postgresql.org/)，可作为[数据分析](#数据分析)环境，或低代码数据可视化应用开发平台。

![](../_media/ARCH.svg)


### 开源监控管控运维解决方案

> Auto-Pilot for Postgres! 自动驾驶！ 从有到优，让用户**用的爽**！

* Pigsty带有一个无可比拟的数据库[监控系统](s-feature.md#监控系统)，通过30+精心设计组织的监控面板呈现超1200类指标，从全局概览到单个库内对象一览无余，提供终极的可观测性！

* Pigsty提供[高可用](s-feature.md#高可用)的 PostgreSQL 数据库集群，任意成员存活即可正常对外提供服务；各实例幂等，提供类分布式数据库的体验；故障自愈，极大简化运维工作！

* Pigsty支持部署不同种类的数据库集群与实例：经典 [PGSQL](d-pgsql.md) [主从复制集群](d-pgsql.md#主从集群)/[灾备集群](d-pgsql.md#备份集群)，[同步](v-pgsql.md#同步从库)/[延迟](v-pgsql.md#延迟从库)/[离线](v-pgsql.md#离线从库)/[级联实例](v-pgsql.md#级联从库)，[Citus](v-pgsql.md#Citus集群部署)/[Greenplum集群](d-matrixdb.md)，[Redis](d-redis.md) [主从](d-redis.md#redis普通主从实例定义)/[哨兵](d-redis.md#redis-sentinel集群定义)/[原生集群](d-redis.md#redis原生集群定义)。

![](../_media/HA-PGSQL.svg)


### 数据库即代码开发者工具箱

> HashiCorp for Database! 简单易用！从优到易，让用户**省心**！

* Pigsty秉持 Infra as Data 的设计理念，用户只需用几行声明式的[配置](v-config.md#配置文件)文件描述自己想要的数据库，即可使用幂等[剧本](p-playbook.md)，一键将其创建。Just like Kubernetes!

* Pigsty向开发者交付简单易用的数据库工具箱：一键[下载](s-install.md)，无需互联网即可[离线安装](t-offline.md)，自动[配置](v-config.md#配置过程)；一键部署各类开源数据库，一键迁移备份、扩容缩容，极大拉低数据库管理使用门槛，量产DBA！
  
* Pigsty能够简化数据库部署与交付、解决环境配置统一的难题：无论是上千套数据库几万核的生产环境，还是本地1C1G的笔记本均可完整运行；基于Vagrant的[本地沙箱](d-sandbox.md)与基于Terraform的[多云部署](d-sandbox.md#云端沙箱)，云上云下，一键拉起！

![](../_media/SANDBOX.gif)


### 开源云数据库整体替代方案

> Alternative for RDS! 降本增效！从易到廉，给用户**省钱**！

* Pigsty相比云厂商RDS，在拥有更低使用⻔槛与更丰富功能的前提下，可节约 50% - 80% 的数据库软硬件成本，初级研发人员即可自主管理成百上千套数据库。

* Pigsty采用模块化设计，可自由组合，按需定制扩展。可在生产环境[部署](d-deploy.md)[管理](r-sop.md)各种数据库，或仅仅将其当成主机监控；可用于开发数[据库可视化Demo](t-application.md)、或支撑各类[SaaS应用](t-docker.md)。

* 开源免费的生产级数据库解决方案，用于补全云原生生态缺失的最后一块拼图。稳定可靠，经过长时间大规模生产部署验证，提供可选的专业技术支持服务。

![](../_media/overview-monitor.jpg)



## 协议

Pigsty基于Apache 2.0协议开源，可以免费用于商业目的，但改装与衍生需遵守[Apache License 2.0](https://raw.githubusercontent.com/Vonng/pigsty/master/LICENSE)的显著声明条款。如需帮助或专业支持，请参阅[社区交流](community.md)。


## 关于

[![](https://star-history.com/#vonng/pigsty&Date)](https://github.com/Vonng/pigsty)

作者: [冯若航](https://vonng.com/en/) ([rh@vonng.com](mailto:rh@vonng.com))

协议: [Apache 2.0 License](https://github.com/Vonng/Capslock/blob/master/LICENSE)

备案: [浙ICP备15016890-2号](https://beian.miit.gov.cn/)
