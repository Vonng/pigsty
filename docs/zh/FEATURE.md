# 亮点特性

Pigsty 是一个更好的本地开源 RDS for PostgreSQL 替代：

- [开箱即用的RDS](#开箱即用的rds)：从内核到RDS发行版，在 EL7-9 下提供 12-16 版本的生产级 PostgreSQL 数据库服务。
- [丰富的扩展插件](#丰富的扩展插件)：深度整合 150+ 核心扩展，提供开箱即用的分布式的时序地理空间图文向量数据库能力。
- [灵活的模块架构](#灵活的模块架构)：灵活组合，自由扩展：Redis/Etcd/MinIO/Mongo；可独立使用，监控现有RDS/主机/数据库。
- [惊艳的观测能力](#惊艳的观测能力)：基于现代可观测性技术栈 Prometheus/Grafana，提供令人惊艳，无可比拟的数据库观测能力。
- [验证过的可靠性](#验证过的可靠性)：故障自愈的高可用架构：硬件故障自动切换，流量无缝衔接。并提供自动配置的 PITR 兜底删库！
- [简单易用可维护](#简单易用可维护)：声明式API，GitOps就位，傻瓜式操作，Database/Infra-as-Code 以及管理SOP封装管理复杂度！
- [扎实的安全实践](#扎实的安全实践)：加密备份一应俱全，自带基础ACL最佳实践。只要硬件与密钥安全，您无需操心数据库的安全性！
- [广泛的应用场景](#广泛的应用场景)：低代码数据应用开发，或使用预置的 Docker Compose 模板，一键拉起使用PostgreSQL的海量软件！
- [开源的自由软件](#开源的自由软件)：以云数据库1/10不到的成本拥有与更好的数据库服务！帮您真正“拥有”自己的数据，实现自主可控！

[![pigsty-home.jpg](https://repo.pigsty.cc/img/pigsty-home.jpg)](https://demo.pigsty.cc)


----------------

## 开箱即用的RDS

**让您立刻在本地拥有生产级的PostgreSQL数据库服务！**

PostgreSQL 是一个足够完美的数据库内核，但它需要更多工具与系统的配合才能成为一个足够好的数据库服务（RDS），而 Pigsty 帮助 PostgreSQL 完成这一步飞跃，帮助用户用好这个强大的数据库。

Pigsty 支持的数据库版本覆盖 PostgreSQL 12 ～ 16，可以运行于 EL/Debian/Ubuntu 以及[兼容](INSTALL#要求)操作系统发行版中。
除了数据库内核与大量开箱即用的扩展插件以外，Pigsty更是提供了数据库服务所需的完整运行时基础设施，与本地沙箱/生产环境/IaaS全自动部署方案。

您无需依赖任何外部组件或互联网访问，便可以在任何环境中一键拉起生产级的 PostgreSQL RDS [服务](PGSQL-SVC#服务概述)，10分钟从全新裸机进入生产可用状态。
参数将根据您的硬件规格自动进行优化调整，内核扩展安装，连接池，负载均衡，服务接入，高可用/自动切换，日志监控，备份恢复PITR，访问控制，参数调优，安全加密，证书签发，NTP，DNS，配置管理，CMDB，管理预案……，所有这些在生产环境中可能会遇到的问题，Pigsty 都帮您预先考虑好了。
您所要做的就是一键安装好，然后使用连接串URL连上去使用即可。

[![pigsty-arch.jpg](https://repo.pigsty.cc/img/pigsty-arch.jpg)](ARCH.md#单机安装)


----------------

## 丰富的扩展插件

**彻底释放世界上最先进的关系型数据库的力量!**

PostgreSQL 的灵魂在于其丰富的[扩展插件](PGSQL-EXTENSION#扩展列表)生态，而 Pigsty 深度整合了 PostgreSQL 生态扩展插件，为您提供开箱即用的分布式的时序地理空间图文向量数据库能力！

Pigsty 收录了超过 150+ PostgreSQL 扩展插件，编译维护打包了一些官方仓库没有收录的扩展，并且通过充分的测试确保所有这些插件可以正常协同工作：
您可以使用 [PostGIS](https://postgis.net/) 处理地理空间数据，使用 [TimescaleDB](https://www.timescale.com/) 分析时序/事件流数据，使用 [Citus](https://www.citusdata.com/) 将单机数据库原地改造为水平扩展的分布式数据库集群，
使用 [PGVector](https://github.com/pgvector/pgvector) 存储并搜索 AI 嵌入实现向量数据库的效果，使用 [Apache AGE](https://age.apache.org/) 进行图数据存储与检索实现 Neo4J 的效果，使用 [zhparser](https://github.com/amutu/zhparser) 进行中文分词实现 ElasticSearch 的效果。

Pigsty 还允许您在裸机高可用 PostgreSQL 集群上自行托管 [Supabase](https://github.com/Vonng/pigsty/tree/master/app/supabase/README.md) 与 [PostgresML](https://github.com/Vonng/pigsty/tree/master/app/pgml) ，并与海量扩展组合使用。
如果您想要的扩展没有被 Pigsty 收录，欢迎提出收录[建议](https://github.com/Vonng/pigsty/discussions/333) 或自行[编译](PGSQL-EXTENSION#扩展编译)加装。

[![pigsty-distro.jpg](https://repo.pigsty.cc/img/pigsty-distro.jpg)](PGSQL-EXTENSION.md)




----------------

## 灵活的模块架构

**灵活组合，自由扩展，多数据库支持，监控现有RDS/主机/数据库**

在 Pigsty 中功能组件被抽象 [模块](ARCH.md#模块)，可以自由组合以应对多变的需求场景。[`INFRA`](INFRA.md) 模块带有完整的现代监控技术栈，而 [`NODE`](NODE.md) 模块则将节点调谐至指定状态并纳入监控。
在多个节点上安装 [`PGSQL`](PGSQL.md) 模块会自动组建出一个基于主从复制的高可用数据库集群，而同样的 [`ETCD`](ETCD.md) 模块则为数据库高可用提供共识与元数据存储。可选的 [`MINIO`](MINIO.md)模块可以用作图像视频等大文件存储并可选用为数据库备份仓库。

与 PG 有着极佳相性的 [`REDIS`](REDIS.md) 亦为 Pigsty 所支持，Pigsty 也允许您使用 [`MONGO`](MONGO) 模块，利用 FerretDB 在 PostgreSQL 集群上提供 MongoDB 协议兼容的服务。
更多的模块（如`GPSQL`, `MYSQL`, `KAFKA`）将会在后续加入，你也可以开发自己的模块并自行扩展 Pigsty 的能力，并与社区用户分享。

此外，Pigsty的监控系统模块部分还可以[独立使用](PGSQL-MONITOR#监控rds) ——用它来监控现有的主机节点与数据库实例，或者是云上的 RDS 服务。只需要一个连接串一行命令，您就可以获得极致的 PostgreSQL 可观测性体验。

[![pigsty-sandbox.jpg](https://repo.pigsty.cc/img/pigsty-sandbox.jpg)](ARCH.md#模块)




----------------

## 惊艳的观测能力

**使用现代开源可观测性技术栈，提供无与伦比的监控最佳实践！**

Pigsty 提供了基于开源的 Grafana / Prometheus 现代可观测性技术栈做[监控](PGSQL-MONITOR)的最佳实践：Prometheus 用于收集监控指标，Grafana 负责可视化呈现，Loki 用于日志收集与查询，Alertmanager 用于告警通知。 PushGateway 用于批处理任务监控，Blackbox Exporter 负责检查服务可用性。整套系统同样被设计为一键拉起，开箱即用的 INFRA 模块。

Pigsty 所管理的任何组件都会被自动纳入监控之中，包括主机节点，负载均衡 HAProxy，数据库 Postgres，连接池 Pgbouncer，元数据库 ETCD，KV缓存 Redis，对象存储 MinIO，……，以及整套监控基础设施本身。大量的 Grafana 监控面板与预置告警规则会让你的系统观测能力有质的提升，当然，这套系统也可以被复用于您的应用监控基础设施，或者监控已有的数据库实例或 RDS。

无论是故障分析还是慢查询优化、无论是水位评估还是资源规划，Pigsty 为您提供全面的数据支撑，真正做到数据驱动。在 Pigsty 中，超过三千类监控指标被用于描述整个系统的方方面面，并被进一步加工、聚合、处理、分析、提炼并以符合直觉的可视化模式呈现在您的面前。从全局大盘总览，到某个数据库实例中单个对象（表，索引，函数）的增删改查详情都能一览无余。您可以随意上卷下钻横向跳转，浏览系统现状与历史趋势，并预测未来的演变。

[![pigsty-dashboard.jpg](https://repo.pigsty.cc/img/pigsty-dashboard.jpg)](https://github.com/Vonng/pigsty/wiki/Gallery)

访问 [截图画廊](https://github.com/Vonng/pigsty/wiki/Gallery)与[在线演示](https://demo.pigsty.cc) 获取更多详情。




----------------

## 验证过的可靠性

**开箱即用的高可用与时间点恢复能力，确保你的数据库坚如磐石！**

对于软件缺陷或人为误操作造成的删表删库，Pigsty 提供了开箱即用的 PITR 时间点恢复能力，无需额外配置即默认启用。只要存储空间管够，基于 `pgBackRest` 的基础备份与 WAL 归档让您拥有快速回到过去任意时间点的能力。您可以使用本地目录/磁盘，亦或专用的 MinIO 集群或 S3 对象存储服务保留更长的回溯期限，丰俭由人。

更重要的是，Pigsty 让高可用与故障自愈成为 PostgreSQL 集群的标配，基于 `patroni`, `etcd`, 与 `haproxy` 打造的故障自愈架构，让您在面对硬件故障时游刃有余：主库故障自动切换的 RTO < 30s（可配置），一致性优先模式下确保数据零损失 RPO = 0。只要集群中有任意实例存活，集群就可以对外提供完整的服务，而客户端只要连接至集群中的任意节点，即可获得完整的服务。

Pigsty 内置了 HAProxy 负载均衡器用于自动流量切换，提供 DNS/VIP/LVS 等多种接入方式供客户端选用。故障切换与主动切换对业务侧除零星闪断外几乎无感知，应用不需要修改连接串重启。极小的维护窗口需求带来了极大的灵活便利：您完全可以在无需应用配合的情况下滚动维护升级整个集群。硬件故障可以等到第二天再抽空善后处置的特性，让研发，运维与 DBA 都能安心睡个好觉。
许多大型组织与核心机构已经在生产环境中长时间使用 Pigsty ，最大的部署有 25K CPU 核心与 200+ PostgreSQL 超大规格实例；在这一部署案例中，四年内经历了数十次硬件故障与各类事故，但依然可以保持比 99.999% 更高的可用性战绩。

[![pgsql-ha.jpg](https://repo.pigsty.cc/img/pgsql-ha.jpg)](PGSQL-ARCH.md#高可用)



----------------

## 简单易用可维护

**Infra as Code, 数据库即代码，声明式的API将数据库管理的复杂度来封装。**

Pigsty 使用声明式的接口对外提供服务，将系统的可控制性拔高到一个全新水平：用户通过配置清单告诉 Pigsty "我想要什么样的数据库集群"，而不用去操心到底需要怎样去做。从效果上讲，这类似于 K8S 中的 CRD 与 Operator，但 Pigsty 可用于任何节点上的数据库与基础设施：不论是容器，虚拟机，还是物理机。

无论是创建/销毁集群，添加/移除从库，还是新增数据库/用户/服务/扩展/黑白名单规则，您只需要修改配置清单并运行 Pigsty 提供的幂等剧本，而 Pigsty 负责将系统调整到您期望的状态。
用户无需操心配置的细节，Pigsty将自动根据机器的硬件配置进行调优，您只需要关心诸如集群叫什么名字，有几个实例放在哪几台机器上，使用什么配置模版：事务/分析/核心/微型，这些基础信息，研发也可以自助服务。但如果您愿意跳入兔子洞中，Pigsty 也提供了丰富且精细的控制参数，满足最龟毛 DBA 的苛刻定制需求。

除此之外，Pigsty 本身的安装部署也是一键傻瓜式的，所有依赖被预先打包，在安装时可以无需互联网访问。而安装所需的机器资源，也可以通过 Vagrant 或 Terraform 模板自动获取，让您在十几分钟内就可以从零在本地笔记本或云端虚拟机上拉起一套完整的 Pigsty 部署。本地沙箱环境可以跑在1核2G的微型虚拟机中，提供与生产环境完全一致的功能模拟，可以用于开发、测试、演示与学习。

[![pigsty-iac.jpg](https://repo.pigsty.cc/img/pigsty-iac.jpg)](CONFIG.md)



----------------

## 扎实的安全实践

**加密备份一应俱全，只要硬件与密钥安全，您无需操心数据库的安全性。**

每套 Pigsty 部署都会创建一套自签名的 CA 用于证书签发，所有的网络通信都可以使用 SSL 加密。数据库密码使用合规的 `scram-sha-256` 算法加密存储，远端备份会使用 `AES-256` 算法加密。此外还针对 PGSQL 提供了一套开箱即用的的访问控制体系，足以应对绝大多数应用场景下的安全需求。

Pigsty 针对 PostgreSQL 提供了一套开箱即用，简单易用，精炼灵活的，便于扩展的[访问控制体系](PGSQL-ACL.md)，包括职能分离的四类默认角色：读(DQL) / 写(DML) / 管理(DDL) / 离线(ETL) ，与四个默认用户：dbsu / replicator / monitor / admin。
所有数据库模板都针对这些角色与用户配置有合理的默认权限，而任何新建的数据库对象也会自动遵循这套权限体系，而客户端的访问则受到一套基于最小权限原则的设计的 [HBA](PGSQL-HBA.md) 规则组限制，任何敏感操作都会记入日志审计。

任何网络通信都可以使用 SSL 加密，需要保护的敏感管理页面与API端点都受到多重保护：使用用户名与密码进行认证，限制从管理节点/基础设施节点IP地址/网段访问，要求使用 HTTPS 加密网络流量。Patroni API 与 Pgbouncer 因为性能因素默认不启用 SSL ，但亦提供安全开关便于您在需要时开启。
合理配置的系统通过等保三级毫无问题，只要您遵循安全性最佳实践，内网部署并合理配置安全组与防火墙，数据库安全性将不再是您的痛点。

[![pigsty-acl.jpg](https://repo.pigsty.cc/img/pigsty-acl.jpg)](SECURITY.md)



----------------

## 广泛的应用场景

**使用预置的Docker模板，一键拉起使用PostgreSQL的海量软件！**

在各类数据密集型应用中，数据库往往是最为棘手的部分。例如 Gitlab 企业版与社区版的核心区别就是底层 PostgreSQL 数据库的监控与高可用，如果您已经有了足够好的本地 PG RDS，完全可以拒绝为软件自带的土法手造数据库组件买单。

Pigsty 提供了 Docker 模块与大量开箱即用的 Compose 模板。您可以使用 Pigsty 管理的高可用 PostgreSQL （以及 Redis 与 MinIO ）作为后端存储，以无状态的模式一键拉起这些软件： Gitlab、Gitea、Wiki.js、NocoDB、Odoo、Jira、Confluence、Habour、Mastodon、Discourse、KeyCloak 等等。如果您的应用需要一个靠谱的 PostgreSQL 数据库， Pigsty 也许是最简单的获取方案。

Pigsty 也提供了与 PostgreSQL 紧密联系的应用开发工具集：PGAdmin4、PGWeb、ByteBase、PostgREST、Kong、以及 EdgeDB、FerretDB、Supabase 这些使用 PostgreSQL 作为存储的"上层数据库"。更奇妙的是，您完全可以基于 Pigsty 内置了的 Grafana 与 Postgres ，以低代码的方式快速搭建起一个交互式的数据应用来，甚至还可以使用 Pigsty 内置的 ECharts 面板创造更有表现力的交互可视化作品。

[![pigsty-app.jpg](https://repo.pigsty.cc/img/pigsty-app.jpg)](APP.md)



----------------

## 开源的自由软件

**Pigsty是基于 AGPLv3 开源的自由软件，由热爱 PostgreSQL 的社区成员用热情浇灌**

Pigsty 是完全[开源免费](LICENSE.md)的自由软件，它允许您在缺乏数据库专家的情况下，用几乎接近纯硬件的成本来运行企业级的 PostgreSQL 数据库服务。作为对比，公有云厂商提供的 RDS 会收取底层硬件资源几倍到十几倍不等的溢价作为 "服务费"。

很多用户选择上云，正是因为自己搞不定数据库；很多用户使用 RDS，是因为别无他选。我们将打破云厂商的垄断，为用户提供一个云中立的，更好的 RDS 开源替代： Pigsty 紧跟 PostgreSQL 上游主干，不会有供应商锁定，不会有恼人的 "授权费"，不会有节点数量限制，不会收集您的任何数据。您的所有的核心资产 —— 数据，都能"自主可控"，掌握在自己手中。

Pigsty 本身旨在用数据库自动驾驶软件，替代大量无趣的人肉数据库运维工作，但再好的软件也没法解决所有的问题。总会有一些的冷门低频疑难杂症需要专家介入处理。这也是为什么我们也提供专业的[订阅服务](SUPPORT.md#服务协议)，来为有需要的企业级用户使用 PostgreSQL 提供兜底。几万块的订阅咨询费不到顶尖 DBA 每年工资的几十分之一，让您彻底免除后顾之忧，把成本真正花在刀刃上。对于社区用户，我们亦[用爱发电](SUPPORT.md#赞助我们)，提供免费的支持与日常答疑。

[![pigsty-price.jpg](https://repo.pigsty.cc/img/pigsty-price.jpg)](SUPPORT)
