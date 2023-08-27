# 亮点特性

Pigsty 是一个更好的本地开源 RDS for PostgreSQL 替代，具有以下特点：

- 开箱即用的 [PostgreSQL](https://www.postgresql.org/) 发行版，深度整合地理时序分布式向量等核心扩展： [PostGIS](https://postgis.net/), [TimescaleDB](https://www.timescale.com/), [Citus](https://www.citusdata.com/)，[PGVector](https://github.com/pgvector/pgvector)……
- 基于现代的 [Prometheus](https://prometheus.io/) 与 [Grafana](https://grafana.com/) 技术栈，提供令人惊艳，无可比拟的数据库观测能力：[演示站点](https://demo.pigsty.cc)
- 基于 [patroni](https://patroni.readthedocs.io/en/latest/), [haproxy](http://www.haproxy.org/), 与[etcd](https://etcd.io/)，打造故障自愈的高可用架构：硬件故障自动切换，流量无缝衔接。
- 基于 [pgBackRest](https://pgbackrest.org/) 与可选的 [MinIO](https://min.io/) 集群提供开箱即用的 PITR 时间点恢复，为软件缺陷与人为删库兜底。
- 基于 [Ansible](https://www.ansible.com/) 提供声明式的 API 对复杂度进行抽象，以 **Database-as-Code** 的方式极大简化了日常运维管理操作。
- Pigsty用途广泛，可用作完整应用运行时，开发演示数据/可视化应用，大量使用 PG 的软件可用 [Docker](https://www.docker.com/) 模板一键拉起。
- 提供基于 [Vagrant](https://www.vagrantup.com/) 的本地开发测试沙箱环境，与基于 [Terraform](https://www.terraform.io/) 的云端自动部署方案，开发测试生产保持环境一致。
- 部署并监控专用的 [Redis](https://redis.io/)（主从，哨兵，集群），MinIO，Etcd，Haproxy，MongoDB([FerretDB](https://www.ferretdb.io/)) 集群


----------------

## 强力的发行版

**彻底释放世界上最先进的关系型数据库的力量!**

PostgreSQL 是一个足够完美的数据库内核，但它需要更多工具与系统的配合，才能成为一个足够好的数据库服务（RDS），而 Pigsty 帮助 PostgreSQL 完成这一步飞跃。

Pigsty 深度整合 PostgreSQL 生态的核心扩展插件：您可以使用 **PostGIS** 处理地理空间数据，使用 **TimescaleDB** 分析时序/事件流数据，使用 **Citus** 原地进行分布式水平扩展，使用 **PGVector** 存储并搜索 AI Embedding，以及其他海量扩展插件。
Pigsty 确保这些插件可以协同工作，提供开箱即用的分布式的时序地理空间向量数据库能力。此外，Pigsty 还提供了运行企业级 RDS 服务的所需软件，打包所有依赖为离线软件包，所有组件均可在无需互联网访问的情况下一键完成安装部署，进入生产可用状态。

在 Pigsty 中功能组件被抽象 [**模块**](ARCH#modules)，可以自由组合以应对多变的需求场景。[`INFRA`](INFRA.md) 模块带有完整的现代监控技术栈，而 [`NODE`](NODE.md) 模块则将节点调谐至指定状态并纳入监控。
在多个节点上安装 [`PGSQL`](PGSQL.md) 模块会自动组建出一个基于主从复制的高可用数据库集群，而同样的 [`ETCD`](ETCD.md) 模块则为数据库高可用提供共识与元数据存储。可选的 [`MINIO`](MINIO.md)模块可以用作图像视频等大文件存储并可选用为数据库备份仓库。
与 PG 有着极佳相性的 [`REDIS`](REDIS.md) 亦为 Pigsty 所支持，更多的模块（如`GPSQL`, `MYSQL`, `KAFKA`, `MONGO`）将会在后续加入，你也可以开发自己的模块并自行扩展 Pigsty 的能力。

[![pigsty-distro](https://user-images.githubusercontent.com/8587410/226076217-77e76e0c-94ac-4faa-9014-877b4a180e09.jpg)](PGSQL.md)



----------------

## 惊艳的观测能力

**使用现代开源可观测性技术栈，提供无与伦比的监控最佳实践！**

Pigsty 提供了基于开源的 Grafana / Prometheus 可观测性技术栈做监控的最佳实践：Prometheus 用于收集监控指标，Grafana 负责可视化呈现，Loki 用于日志收集与查询，Alertmanager 用于告警通知。 PushGateway 用于批处理任务监控，Blackbox Exporter 负责检查服务可用性。整套系统同样被设计为一键拉起，开箱即用的 INFRA 模块。

Pigsty 所管理的任何组件都会被自动纳入监控之中，包括主机节点，负载均衡 HAProxy，数据库 Postgres，连接池 Pgbouncer，元数据库 ETCD，KV缓存 Redis，对象存储 MinIO，……，以及整套监控基础设施本身。大量的 Grafana 监控面板与预置告警规则会让你的系统观测能力有质的提升，当然，这套系统也可以被复用于您的应用监控基础设施，或者监控已有的数据库实例或 RDS。

无论是故障分析还是慢查询优化、无论是水位评估还是资源规划，Pigsty 为您提供全面的数据支撑，真正做到数据驱动。在 Pigsty 中，超过三千类监控指标被用于描述整个系统的方方面面，并被进一步加工、聚合、处理、分析、提炼并以符合直觉的可视化模式呈现在您的面前。从全局大盘总揽，到某个数据库实例中单个对象（表，索引，函数）的增删改查详情都能一览无余。您可以随意上卷下钻横向跳转，浏览系统现状与历史趋势，并预测未来的演变。

访问 [截图画廊](https://github.com/Vonng/pigsty/wiki/Gallery)与[在线演示](https://demo.pigsty.cc) 获取更多详情。

[![Dashboards](https://github-production-user-asset-6210df.s3.amazonaws.com/8587410/258681605-cf6b99e5-9c8f-4db2-9bce-9ded95407c0c.jpg)](https://github.com/Vonng/pigsty/wiki/Gallery)




----------------

## 久经考验的可靠性

**开箱即用的高可用与时间点恢复能力，确保你的数据库坚如磐石！**

对于软件缺陷或人为误操作造成的删表删库，Pigsty 提供了开箱即用的 PITR 时间点恢复能力，无需额外配置即默认启用。只要存储空间管够，基于 `pgBackRest` 的基础备份与 WAL 归档让您拥有快速回到过去任意时间点的能力。您可以使用本地目录/磁盘，亦或专用的 MinIO 集群或 S3 对象存储服务保留更长的回溯期限，丰俭由人。

更重要的是，Pigsty 让高可用与故障自愈成为 PostgreSQL 集群的标配，基于 `patroni`, `etcd`, 与 `haproxy` 打造的故障自愈架构，让您在面对硬件故障时游刃有余：主库故障自动切换的 RTO < 30s，一致性优先模式下确保数据零损失 RPO = 0。只要集群中有任意实例存活，集群就可以对外提供完整的服务，而客户端只要连接至集群中的任意节点，即可获得完整的服务。

Pigsty 内置了 HAProxy 负载均衡器用于自动流量切换，提供 DNS/VIP/LVS 等多种接入方式供客户端选用。故障切换与主动切换对业务侧除零星闪断外几乎无感知，应用不需要修改连接串重启。极小的维护窗口需求带来了极大的灵活便利：您完全可以在无需应用配合的情况下滚动维护升级整个集群。硬件故障可以等到第二天再抽空善后处置的特性，让研发，运维与 DBA 都能安心睡个好觉。
许多大型组织与核心机构已经在生产环境中长时间使用 Pigsty ，最大的部署有 25K CPU 核心与 200+ PostgreSQL 实例，在这一部署案例中， Pigsty 在三年内经历了数十次硬件故障与各类事故，但依然可以保持 99.999% 以上的整体可用性。


[![pigsty-ha](https://user-images.githubusercontent.com/8587410/206971583-74293d7b-d29a-4ca2-8728-75d50421c371.gif)](PGSQL-ARCH.md#high-availability)



----------------

## 简单易用可维护

**Infra as Code, 数据库即代码，声明式的API将数据库管理的复杂度来封装。**

Pigsty 使用声明式的接口对外提供服务，将系统的可控制性拔高到一个全新水平：用户通过配置清单告诉 Pigsty "我想要什么样的数据库集群"，而不用去操心到底需要怎样去做。从效果上讲，这类似于 K8S 中的 CRD 与 Operator，但 Pigsty 可用于任何节点上的数据库与基础设施：不论是容器，虚拟机，还是物理机。

无论是创建/销毁集群，添加/移除从库，还是新增数据库/用户/服务/扩展/黑白名单规则，您只需要修改配置清单并运行 Pigsty 提供的幂等剧本，而 Pigsty 负责将系统调整到您期望的状态。
用户无需操心配置的细节，Pigsty将自动根据机器的硬件配置进行调优，您只需要关心诸如集群叫什么名字，有几个实例放在哪几台机器上，使用什么配置模版：事务/分析/核心/微型，这些基础信息，研发也可以自助服务。但如果您愿意跳入兔子洞中，Pigsty 也提供了丰富且精细的控制参数，满足最龟毛 DBA 的苛刻定制需求。

除此之外，Pigsty 本身的安装部署也是一键傻瓜式的，所有依赖被预先打包，在安装时可以无需互联网访问。而安装所需的机器资源，也可以通过 Vagrant 或 Terraform 模板自动获取，让您在十几分钟内就可以从零在本地笔记本或云端虚拟机上拉起一套完整的 Pigsty 部署。本地沙箱环境可以跑在1核2G的微型虚拟机中，提供与生产环境完全一致的功能模拟，可以用于开发、测试、演示与学习。

[![pigsty-iac](https://user-images.githubusercontent.com/8587410/206972039-e13746ab-72ae-4cab-8de7-7b2ef543f3e5.gif)](CONFIG.md)



----------------

## 扎实的安全性

**加密备份一应俱全，只要硬件与密钥安全，您无需操心数据库的安全性。**

每套 Pigsty 部署都会创建一套自签名的 CA 用于证书签发，所有的网络通信都可以使用 SSL 加密。数据库密码使用合规的 `scram-sha-256` 算法加密存储，远端备份会使用 `AES-256` 算法加密。此外还针对 PGSQL 提供了一套开箱即用的的访问控制体系，足以应对绝大多数应用场景下的安全需求。

Pigsty 针对 PostgreSQL 提供了一套开箱即用，简单易用，精炼灵活的，便于扩展的[访问控制体系](PGSQL-ACL.md)，包括职能分离的四类默认角色：读(DQL) / 写(DML) / 管理(DDL) / 离线(ETL) ，与四个默认用户：dbsu / replicator / monitor / admin。
所有数据库模板都针对这些角色与用户配置有合理的默认权限，而任何新建的数据库对象也会自动遵循这套权限体系，而客户端的访问则受到一套基于最小权限原则的设计的 HBA 规则组限制，任何敏感操作都会记入日志审计。

任何网络通信都可以使用 SSL 加密，需要保护的敏感管理页面与API端点都受到多重保护：使用用户名与密码进行认证，限制从管理节点/基础设施节点IP地址/网段访问，要求使用 HTTPS 加密网络流量。Patroni API 与 Pgbouncer 因为性能因素默认不启用 SSL ，但亦提供安全开关便于您在需要时开启。
合理配置的系统通过等保三级毫无问题，只要您遵循安全性最佳实践，内网部署并合理配置安全组与防火墙，数据库安全性将不再是您的痛点。

[![pigsty-dashboard2](https://user-images.githubusercontent.com/8587410/198838841-b0796703-03c3-483b-bf52-dbef9ea10913.gif)](SECURITY.md)



----------------

## 广泛的应用场景

**使用预置的Docker模板，一键拉起使用PostgreSQL的海量软件！**

在各类数据密集型应用中，数据库往往是最为棘手的部分。例如 Gitlab 企业版与社区版的核心区别就是底层 PostgreSQL 数据库的监控与高可用，如果您已经有了足够好的本地 PG RDS，完全可以拒绝为软件自带的土法手造数据库组件买单。

Pigsty 提供了 Docker 模块与大量开箱即用的 Compose 模板。您可以使用 Pigsty 管理的高可用 PostgreSQL （以及 Redis 与 MinIO ）作为后端存储，以无状态的模式一键拉起这些软件： Gitlab、Gitea、Wiki.js、NocoDB、Odoo、Jira、Confluence、Habour、Mastodon、Discourse、KeyCloak 等等。如果您的应用需要一个靠谱的 PostgreSQL 数据库， Pigsty 也许是最简单的获取方案。

Pigsty 也提供了与 PostgreSQL 紧密联系的应用开发工具集：PGAdmin4、PGWeb、ByteBase、PostgREST、Kong、以及 EdgeDB、FerretDB、Supabase 这些使用 PostgreSQL 作为存储的"上层数据库"。更奇妙的是，您完全可以基于 Pigsty 内置了的 Grafana 与 Postgres ，以低代码的方式快速搭建起一个交互式的数据应用来，甚至还可以使用 Pigsty 内置的 ECharts 面板创造更有表现力的交互可视化作品。

[![pigsty-app](https://user-images.githubusercontent.com/8587410/198838829-f0ea4af2-d33f-4978-a31a-ed81897aa8d1.gif)](APP.md)



----------------

## 开源免费的自由软件

**Pigsty是基于 AGPLv3 开源的自由软件，由热爱 PostgreSQL 的社区成员用热情浇灌**

Pigsty 是完全[开源免费](LICENSE.md)的自由软件，它允许您在缺乏数据库专家的情况下，用几乎接近纯硬件的成本来运行企业级的 PostgreSQL 数据库服务。作为对比，公有云厂商提供的 RDS 会收取底层硬件资源几倍到十几倍不等的溢价作为 "服务费"。

很多用户选择上云，正是因为自己搞不定数据库；很多用户使用 RDS，是因为别无他选。我们将打破云厂商的垄断，为用户提供一个云中立的，更好的 RDS 开源替代： Pigsty 紧跟 PostgreSQL 上游主干，不会有供应商锁定，不会有恼人的 "授权费"，不会有节点数量限制，不会收集您的任何数据。您的所有的核心资产 —— 数据，都能"自主可控"，掌握在自己手中。

Pigsty 本身旨在用数据库自动驾驶软件，替代大量无趣的人肉数据库运维工作，但再好的软件也没法解决所有的问题。总会有一些的冷门低频疑难杂症需要专家介入处理。这也是为什么我们也提供专业的[订阅服务](SUPPORT.md#服务协议)，来为有需要的企业级用户使用 PostgreSQL 提供兜底。几万块的订阅咨询费不到顶尖 DBA 每年工资的几十分之一，让您彻底免除后顾之忧，把成本真正花在刀刃上。对于社区用户，我们亦[用爱发电](SUPPORT.md#赞助我们)，提供免费的支持与日常答疑。

[![pigsty-rds-cost](https://user-images.githubusercontent.com/8587410/225852971-577be00f-b2df-427c-a590-f8b4c5a63a4b.png)](https://instances.vantage.sh/)
