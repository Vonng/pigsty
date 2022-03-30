# Pigsty 快速上手

> Pigsty的安装分为三个步骤：[部署准备](d-prepare.md)，[修改配置](v-config.md)，[执行剧本](p-playbook)

----------------

Pigsty有两种典型使用模式：[单机安装](#单机安装) 与 [集群管理](#集群管理)。

* **单机**：在单个节点上安装Pigsty，将其作为开箱即用的Postgres数据库使用（开发测试）
* **集群**：在单机安装的基础上，部署、监控、管理其他节点与多种不同种类的数据库（运维管理）


---------------------

## 单机安装

在一台节点上安装Pigsty时，Pigsty会在该节点上部署完整的**基础设施运行时** 与 一个单节点PostgreSQL**数据库集群**。对于个人用户、简单场景、小微企业来说，您可以直接开箱使用此数据库。

准备好**新装**机器（Linux x86_64 CentOS 7.8.2003）一台，配置[管理用户](d-prepare.md#管理用户置备)ssh本机sudo访问，然后[下载Pigsty](d-prepare.md#软件下载)。

```bash
bash -c "$(curl -fsSL http://download.pigsty.cc/get)"  # 下载最新pigsty源代码
cd ~/pigsty; ./configure                               # 根据当前环境生成配置
./infra.yml                                            # 在当前节点上完成安装
```

> 如果您有可用的Macbook/PC/笔记本或云厂商账号，可使用[沙箱部署](d-sandbox.md)在本机或云端自动创建虚拟机。

安装完毕后，您可以直接访问该节点5432端口，获取开箱即用的PostgreSQL数据库[服务](c-service.md#服务)。

80端口为所有Web图形界面服务的访问端点。尽管您可以绕过Nginx直接使用端口访问各服务，例如3000端口的Grafana，但我们还是建议您在本机[配置静态DNS](d-sandbox.md#DNS配置)访问。

> 访问 http://g.pigsty 或 `http://<primary_ip>:3000` 即可浏览 Pigsty监控系统主页 (用户名: admin, 密码: pigsty)



----------------

## 集群管理

Pigsty还可以用作大规模生产环境的集群/数据库管理。您可以从单机安装Pigsty的节点（又名"[管理节点"/"元节点](c-arch.md#管理节点)"）上发起控制，将更多节点纳入Pigsty的管理中。
更重要的是，Pigsty还可以在这些节点上部署并管理各式各样的数据库集群与应用：创建高可用的[PostgreSQL数据库集群](d-pgsql.md)；创建不同类型的[Redis集簇](d-redis.md)；部署 [Greenplum/MatrixDB](d-matrixdb.md) 数据仓库，并获取关于节点、数据库与应用的实时洞察。

以默认的沙箱环境为例，假设您已经在`10.10.10.10`管理节点上完成单机Pigsty的安装，现在希望将另外三个节点：`10.10.10.11`, `10.10.10.12`, `10.10.10.13` 纳入管理，则可以使用 [`nodes.yml`](p-nodes.md#nodes) 剧本：

```bash
./nodes.yml -l pg-test      # 初始化集群pg-test包含的三台机器节点（配置节点+纳入监控）
```

执行完毕后，这三台节点已经带有DCS服务，主机监控与日志收集。可以用于后续的数据库集群部署。例如，使用 [`pgsql.yml`](p-pgsql.md#pgsql) 剧本，可以在这三台节点上初始化一个一主两从的高可用PostgreSQL数据库集群 `pg-test`。

```bash
./pgsql.yml  -l pg-test      # 初始化高可用PGSQL数据库集群pg-test
./redis.yml  -l redis-test   # 初始化Redis集群 redis-test
./pigsty-matrix.yml -l mx-*  # 初始化MatrixDB集群mx-mdw,mx-sdw
```

当部署完成后，您可以从[监控系统](http://demo.pigsty.cc/d/pgsql-cluster/pgsql-cluster?var-cls=pg-test) 中，看到新创建的集群。

* 节点 [配置](v-nodes.md) 与 [剧本](p-nodes.md) 
* PgSQL数据库集群 [配置](v-pgsql.md)、[定制](v-pgsql-customize.md) 与 [剧本](p-pgsql.md)
* Redis数据库集群 [配置](v-redis.md) 与 [剧本](p-redis.md)