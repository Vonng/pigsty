# 配置

> **Pigsty将基础设施和数据库视为代码**：Database as Code & Infra as Code 

你可以通过声明式的接口/配置文件来描述基础设施和数据库集群，你只需在 [配置清单](#配置清单) （Inventory） 中描述你的需求，然后用简单的幂等剧本使其生效即可。


----------------

## 配置清单

每一套 Pigsty 部署都有一个相应的 **配置清单**（Inventory）。它可以以 [YAML](https://docs.ansible.com/ansible/2.9/user_guide/playbooks_variables.html) 的形式存储在本地，并使用 `git` 管理；或从 [CMDB](https://docs.ansible.com/ansible/2.9/user_guide/intro_dynamic_inventory.html) 或任何 ansible 兼容的方式动态生成。

Pigsty 默认使用一个名为 [`pigsty.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml) 的单体 YAML 配置文件作为默认的配置清单，它[位于](https://github.com/Vonng/pigsty/blob/master/ansible.cfg#L3) Pigsty 源码主目录下，但你也可以通过命令行参数`-i`指定路径以使用别的配置清单。

清单由两部分组成：**全局变量** 和多个 **组定义** 。 前者 `all.vars` 通常用于描述基础设施，并为集群设置全局默认参数。后者 `all.children` 则负责定义新的集群（PGSQL/Redis/MinIO/ETCD等等）。一个配置清单文件从最顶层来看大概如下所示：

```yaml
all:                  # 顶层对象：all
  vars: {...}         # 全局参数
  children:           # 组定义
    infra:            # 组定义：'infra'
      hosts: {...}        # 组成员：'infra'
      vars:  {...}        # 组参数：'infra'
    etcd:    {...}    # 组定义：'etcd'
    pg-meta: {...}    # 组定义：'pg-meta'
    pg-test: {...}    # 组定义：'pg-test'
    redis-test: {...} # 组定义：'redis-test'
    # ...
```

在 Pigsty 的 [`files/pigsty`](https://github.com/Vonng/pigsty/blob/master/files/pigsty/README.md) 目录中，有许多不同场景的预置配置模板可供参考选用。



----------------

## 集群

每个组定义通常代表一个集群，可以是节点集群、PostgreSQL 集群、Redis 集群、Etcd 集群或 Minio 集群等。它们都使用相同的格式：`hosts` 和 `vars`。
你可以用 `all.children.<cls>.hosts` 定义集群成员，并使用 `all.children.<cls>.vars` 中的集群参数描述集群。以下是名为 `pg-test` 的三节点 PostgreSQL 高可用集群的定义示例：

```yaml
pg-test:   # 集群名称
  vars:    # 集群参数
    pg_cluster: pg-test
  hosts:   # 集群成员
    10.10.10.11: { pg_seq: 1, pg_role: primary } # 实例1，在 10.10.10.11 上，主库
    10.10.10.12: { pg_seq: 2, pg_role: replica } # 实例2，在 10.10.10.12 上，从库
    10.10.10.13: { pg_seq: 3, pg_role: offline } # 实例3，在 10.10.10.13 上，从库
```

你也可以为特定的主机/实例定义参数，也称为实例参数。它将覆盖集群参数和全局参数，实例参数通常用于为节点和数据库实例分配身份（实例号，角色）。



----------------

## 参数

全局变量、组变量和主机变量都是由一系列 **键值对** 组成的字典对象。每一对都是一个命名的参数，由一个字符串名作为键，和一个值组成。值是五种类型之一：布尔值、字符串、数字、数组或对象。查看[配置参数](PARAM)以了解详细的参数语法语义。

绝大多数参数都有着合适的默认值，**身份参数** 除外；它们被用作标识符，并必须显式配置，例如 [`pg_cluster`](PARAM#pg_cluster)， [`pg_role`](PARAM#pg_role)，以及 [`pg_seq`](PARAM#pg_seq)。

参数可以被更高优先级的同名参数定义覆盖，优先级如下所示：

```bash
命令行参数 > 剧本变量  >  主机变量（实例参数）  >  组变量（集群参数）  >  全局变量（全局参数） >  默认值
```

例如：

- 使用命令行参数 `-e pg_clean=true` 强制删除现有数据库
- 使用实例参数 `pg_role` 和 `pg_seq` 来为一个数据库实例分配角色与标号。
- 使用集群变量来为集群设置默认值，如集群名称 `pg_cluster` 和数据库版本 `pg_version`
- 使用全局变量为所有 PGSQL 集群设置默认值，如使用的默认参数和插件列表
- 如果没有显式配置 `pg_version` ，默认值 `16` 版本号会作为最后兜底的缺省值。



----------------

## 参考

Pigsty 带有 280+ 配置参数，分为以下32个参数组，详情请参考 [配置参数](PARAM) 。

|            模块            | 参数组                                    | 描述                      | 数量 |
|:------------------------:|----------------------------------------|-------------------------|----|
|  [`INFRA`](PARAM#infra)  | [`META`](PARAM#meta)                   | Pigsty 元数据              | 4  |
|  [`INFRA`](PARAM#infra)  | [`CA`](PARAM#ca)                       | 自签名公私钥基础设施 CA           | 3  |
|  [`INFRA`](PARAM#infra)  | [`INFRA_ID`](PARAM#infra_id)           | 基础设施门户，Nginx域名          | 2  |
|  [`INFRA`](PARAM#infra)  | [`REPO`](PARAM#repo)                   | 本地软件仓库                  | 9  |
|  [`INFRA`](PARAM#infra)  | [`INFRA_PACKAGE`](PARAM#infra_package) | 基础设施软件包                 | 2  |
|  [`INFRA`](PARAM#infra)  | [`NGINX`](PARAM#nginx)                 | Nginx 网络服务器             | 7  |
|  [`INFRA`](PARAM#infra)  | [`DNS`](PARAM#dns)                     | DNSMASQ 域名服务器           | 3  |
|  [`INFRA`](PARAM#infra)  | [`PROMETHEUS`](PARAM#prometheus)       | Prometheus 时序数据库全家桶     | 16 |
|  [`INFRA`](PARAM#infra)  | [`GRAFANA`](PARAM#grafana)             | Grafana 可观测性全家桶         | 6  |
|  [`INFRA`](PARAM#infra)  | [`LOKI`](PARAM#loki)                   | Loki 日志服务               | 4  |
|   [`NODE`](PARAM#node)   | [`NODE_ID`](PARAM#node_id)             | 节点身份参数                  | 5  |
|   [`NODE`](PARAM#node)   | [`NODE_DNS`](PARAM#node_dns)           | 节点域名 & DNS解析            | 5  |
|   [`NODE`](PARAM#node)   | [`NODE_PACKAGE`](PARAM#node_package)   | 节点仓库源 & 安装软件包           | 5  |
|   [`NODE`](PARAM#node)   | [`NODE_TUNE`](PARAM#node_tune)         | 节点调优与内核特性开关             | 10 |
|   [`NODE`](PARAM#node)   | [`NODE_ADMIN`](PARAM#node_admin)       | 管理员用户与SSH凭证管理           | 7  |
|   [`NODE`](PARAM#node)   | [`NODE_TIME`](PARAM#node_time)         | 时区，NTP服务与定时任务           | 5  |
|   [`NODE`](PARAM#node)   | [`NODE_VIP`](PARAM#node_vip)           | 可选的主机节点集群L2 VIP         | 8  |
|   [`NODE`](PARAM#node)   | [`HAPROXY`](PARAM#haproxy)             | 使用HAProxy对外暴露服务         | 10 |
|   [`NODE`](PARAM#node)   | [`NODE_EXPORTER`](PARAM#node_exporter) | 主机节点监控与注册               | 3  |
|   [`NODE`](PARAM#node)   | [`PROMTAIL`](PARAM#promtail)           | Promtail日志收集组件          | 4  |
| [`DOCKER`](PARAM#docker) | [`DOCKER`](PARAM#docker)               | Docker容器服务（可选）          | 4  |
|   [`ETCD`](PARAM#etcd)   | [`ETCD`](PARAM#etcd)                   | ETCD DCS 集群             | 10 |
|  [`MINIO`](PARAM#minio)  | [`MINIO`](PARAM#minio)                 | MINIO S3 对象存储           | 15 |
|  [`REDIS`](PARAM#redis)  | [`REDIS`](PARAM#redis)                 | Redis 缓存                | 20 |
|  [`PGSQL`](PARAM#pgsql)  | [`PG_ID`](PARAM#pg_id)                 | PG 身份参数                 | 11 |
|  [`PGSQL`](PARAM#pgsql)  | [`PG_BUSINESS`](PARAM#pg_business)     | PG 业务对象定义               | 12 |
|  [`PGSQL`](PARAM#pgsql)  | [`PG_INSTALL`](PARAM#pg_install)       | 安装 PG 软件包 & 扩展          | 10 |
|  [`PGSQL`](PARAM#pgsql)  | [`PG_BOOTSTRAP`](PARAM#pg_bootstrap)   | 使用 Patroni 初始化 HA PG 集群 | 39 |
|  [`PGSQL`](PARAM#pgsql)  | [`PG_PROVISION`](PARAM#pg_provision)   | 创建 PG 数据库内对象            | 9  |
|  [`PGSQL`](PARAM#pgsql)  | [`PG_BACKUP`](PARAM#pg_backup)         | 使用 pgBackRest 设置备份仓库    | 5  |
|  [`PGSQL`](PARAM#pgsql)  | [`PG_SERVICE`](PARAM#pg_service)       | 对外暴露服务, 绑定 vip, dns     | 9  |
|  [`PGSQL`](PARAM#pgsql)  | [`PG_EXPORTER`](PARAM#pg_exporter)     | PG 监控，服务注册              | 15 |
