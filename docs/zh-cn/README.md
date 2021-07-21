# Pigsty

## Pigsty v1.0.0 中文文档

**开箱即用**的**开源**PostgreSQL**发行版**

[![logo](../_media/icon.svg)](/)

?> 此文档可通过浏览器获得更佳阅览效果：`make doc`

Pigsty是**开箱即用**的开源PostgreSQL发行版，包括完整的数据库运行时基础设施，全面专业的监控系统，简单易用的部署管理方案，一键拉起的沙箱环境。基于友好的Apache License 2.0开源。

Pigsty针对大规模生产环境的PostgreSQL数据库管理需求而设计，但亦可运行于本地微型虚拟机中，用于开发与测试、学习与实验，以及数据分析等场景。

> Pigsty (/ˈpɪɡˌstaɪ/) 是 PostgreSQL In Graphic STYle 的缩写，即 “图形化Postgres”。

![](../_media/what-is-pigsty-zh.svg)



## 亮点特性

* 全面专业的[**监控系统**](#监控系统)，基于Grafana & Prometheus & [`pg_exporter`](https://github.com/Vonng/pg_exporter)
* 稳定可靠的[**部署方案**](#部署方案)，基于Ansible的物理机/虚拟机部署。
* 简单省心的安装方式与用户界面，开箱即用的沙箱环境，降低使用门槛。
* 高可用数据库集群架构，基于Patroni实现，具有秒级故障自愈能力。
* 基于DCS的服务发现与配置管理，维护管理自动化，智能化。
* 无需互联网访问与代理的离线安装模式，快速且可靠。
* 代码定义的基础设施，可配置，可定制。
* 基于PostgreSQL 13 （14beta现已支持！）与Patroni 2.0，享受最新特性。
* 长时间的大规模生产环境验证（200+ node x 64C|400GB|3TB）


## 快速上手

![](../_media/how-zh.svg)


## 快速上手

准备一台安装有CentOS 7.8的全新机器，您需要拥有sudo或root权限，并可以通过ssh登陆。

```bash
curl -fsSL https://pigsty.cc/pigsty.tgz | gzip -d | tar -xC ~; cd ~/pigsty  # 下载源码
make config    # 配置环境
make install   # 安装软件
```

如需运行本地沙箱，可运行以下命令（MacOS）

```bash
make deps   # 安装homebrew，并通过homebrew安装vagrant与virtualbox（需重启）
make dns    # 向本机/etc/hosts写入静态域名 (需sudo输入密码)
make start  # 使用Vagrant拉起单个meta节点 （start4则为4个节点）
make demo   # 使用单节点Demo配置并安装    （demo4则为4节点demo）
```

参考 [**快速上手**](https://pigsty.cc/zh/docs/quick-start/) 获取详细说明。



## 功能介绍

### 监控系统

Pigsty带有一个针对大规模数据库集群管理而设计的专业级PostgreSQL监控系统。包括约1200**类**指标，20+监控面板，上千个监控仪表盘，覆盖了从全局大盘到单个查询的详细信息。面向专业用户，提供不可替代的价值点。

Pigsty监控系统基于业内最佳实践，采用Prometheus、Grafana作为监控基础设施。开源开放，定制便利，可复用，可移植，没有厂商锁定。可与各类已有数据库实例集成。


### 部署方案

数据库是管理数据的软件，管控系统是管理数据库的软件。

Pigsty内置了一套以Ansible为核心的数据库管控方案。并基于此封装了命令行工具与图形界面。它集成了数据库管理中的核心功能：包括数据库集群的创建，销毁，扩缩容；用户、数据库、服务的创建等。Pigsty采纳“Infra as Code”的设计哲学使用了声明式配置，通过大量可选的配置选项对数据库与运行环境进行描述与定制，并通过幂等的预置剧本自动创建所需的数据库集群，提供近似私有云般的使用体验。

![](../_media/access.jpg)

Pigsty吸纳了Kubernetes架构设计中的精髓，采用声明式的配置方式与幂等的操作剧本。用户只需要描述“自己想要什么样的数据库”，而无需关心Pigsty如何去创建它，修改它。Pigsty会根据用户的配置文件清单，在几分钟内从裸机节点上创造出所需的数据库集群。



## About

作者：[冯若航](https://vonng.com) (rh@vonng.com)

[Apache Apache License Version 2.0](LICENSE)