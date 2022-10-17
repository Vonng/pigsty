# Pigsty 快速上手

> Pigsty的安装分为三个步骤：[部署准备](d-prepare.md)，[修改配置](v-config.md)，[执行剧本](p-playbook)

----------------

![](../_media/HOW_ZH.svg)

Pigsty有两种典型使用模式：[单机安装](#单机安装) 与 [集群管理](#集群管理)。

* **单机**：在单个节点上安装Pigsty，将其作为开箱即用的Postgres数据库使用（开发测试）
* **集群**：在单机安装的基础上，部署、监控、管理其他节点与多种不同种类的数据库（运维管理）


---------------------

## 单机安装

在一台节点上安装Pigsty时，Pigsty会在该节点上部署完整的**基础设施运行时** 与 一个单节点PostgreSQL**数据库集群**。对于个人用户、简单场景、小微企业来说，您可以直接开箱使用此数据库。

准备好**新装**机器（Linux x86_64 CentOS 7.9.2009）一台，配置[管理用户](d-prepare.md#管理用户置备)ssh本机sudo访问，然后[下载Pigsty](d-prepare.md#软件下载)。

```bash
bash -c "$(curl -fsSL http://download.pigsty.cc/get)"  # 下载最新pigsty源代码
cd ~/pigsty; ./configure                               # 根据当前环境生成配置
./infra.yml                                            # 在当前节点上完成安装
```

```bash
bash -c "$(curl -fsSL http://download.pigsty.cc/get)"
cd ~/pigsty;    # 下载最新pigsty源代码
./boostrap -y   # 下载离线软件包，安装Ansible（可选，您也可以自行准备并直接在后续步骤中从上游下载）
./configure     # 根据当前环境生成配置文件 pigsty.yml
./infra.yml     # 在当前元节点上完成Pigsty安装
```

> 测试的Linux发行版: centos7.9, rocky8.6, rocky9.0, rhel7, rhel8, rhel9


> 如果您有可用的Macbook/PC/笔记本或云厂商账号，可使用[沙箱部署](d-sandbox.md)在本机或云端自动创建虚拟机。

执行完毕后，您已经在**当前节点**完成了Pigsty的安装，上面带有完整的基础设施与一个开箱即用的PostgreSQL数据库实例，当前节点的5432对外提供数据库[服务](c-service.md#服务)，80端口对外提供所有WebUI类服务。

80端口为所有Web图形界面服务的访问端点。尽管可以绕过Nginx直接使用端口访问各项服务，例如3000端口的Grafana，但强烈建议用户通过在本机[配置静态DNS](d-sandbox.md#DNS配置)的方式，使用域名访问各项Web子服务。

> 访问 http://g.pigsty 或 `http://<primary_ip>:3000` 即可浏览 Pigsty监控系统主页 (用户名: admin, 密码: pigsty)

![](../_media/ARCH.gif)


----------------

## 集群管理


Pigsty还可以用作大规模生产环境的集群/数据库管理。您可以从单机安装Pigsty的节点（将作为集群的[元节点](c-nodes.md#元节点)，或称作**元节点/Meta**）上发起控制，将更多的 [机器节点](p-nodes.md) 纳入Pigsty的管理与监控中。
更重要的是，Pigsty还可以在这些节点上部署并管理各式各样的数据库集群与应用：创建高可用的[PostgreSQL数据库集群](d-pgsql.md)；创建不同类型的[Redis集簇](d-redis.md)；部署 [Greenplum/MatrixDB](d-matrixdb.md) 数据仓库，并获取关于节点、数据库与应用的实时洞察。

```bash
# 在四节点本地沙箱/云端演示环境中，可以使用以下命令在其他三台节点上部署数据库集群
./nodes.yml  -l pg-test      # 初始化集群pg-test包含的三台机器节点（配置节点+纳入监控）
./pgsql.yml  -l pg-test      # 初始化高可用PGSQL数据库集群pg-test
./redis.yml  -l redis-test   # 初始化Redis集群 redis-test
./pigsty-matrixdb.yml -l mx-*  # 初始化MatrixDB集群mx-mdw,mx-sdw
```



----------------

## 沙箱环境

Pigsty设计了一个标准的，4节点的演示教学环境,称为**沙箱环境**，您可以参考[教程](d-sandbox.md)，使用Vagrant或Terraform快速在本机或公有云上拉起所需的四台虚拟机资源，并进行部署测试。跑通流程后稍作修改，便可用于生产环境[部署](d-deploy.md)。


[![](../_media/SANDBOX.gif)](d-sandbox.md)

以默认的[沙箱环境](d-sandbox.md)为例，假设您已经在`10.10.10.10`元节点上完成单机Pigsty的安装：

```bash
./infra.yml # 在沙箱环境的 10.10.10.10 meta 机器上，完成完整的单机Pigsty安装
```

#### 主机初始化

现希望将三个节点：`10.10.10.11`, `10.10.10.12`, `10.10.10.13` 纳入管理，则可使用 [`nodes.yml`](p-nodes.md#nodes) 剧本：

```bash
./nodes.yml -l pg-test      # 初始化集群pg-test包含的三台机器节点（配置节点+纳入监控）
```

执行完毕后，这三台节点已经带有DCS服务，主机监控与日志收集。可以用于后续的数据库集群部署。详情请参考节点 [配置](v-nodes.md) 与 [剧本](p-nodes.md)。


#### PostgreSQL部署

使用 [`pgsql.yml`](p-pgsql.md#pgsql) 剧本，可以在这三台节点上初始化一主两从的高可用PostgreSQL数据库集群 `pg-test`。

```bash
./pgsql.yml  -l pg-test      # 初始化高可用PGSQL数据库集群pg-test
```

部署完成后，即可从[监控系统](http://demo.pigsty.cc/d/pgsql-cluster/pgsql-cluster?var-cls=pg-test) 中看到新创建的PostgreSQL集群。

详情请参考：PgSQL数据库集群 [配置](v-pgsql.md)、[定制](v-pgsql-customize.md) 与 [剧本](p-pgsql.md)。


### Redis部署

除了标准的PostgreSQL集群，您还可以部署各种其他类型的集群，甚至其他类型的数据库。

例如在沙箱中部署[Redis](d-redis.md)，可以使用Redis数据库集群 [配置](v-redis.md) 与 [剧本](p-redis.md)。

```bash   
./configure -m redis
./nodes.yml    # 配置所有用于安装Redis的节点
./redis.yml    # 在所有节点上按照配置声明Redis
```

#### MatrixDB部署

例如在沙箱中部署开源数据仓库[MatrixDB](d-matrixdb.md)（Greenplum7），可以使用以下命令：

```bash
./configure -m mxdb  # 使用沙箱环境MatrixDB配置文件模板
./download matrix    # 下载MatrixDB软件包并构建本地源
./infra.yml -e no_cmdb=true  # 如果您准备在meta节点上部署 MatrixDB Master，添加no_cmdb选项，否则正常安装即可。   
./nodes.yml                  # 配置所有用于安装MatrixDB的节点
./pigsty-matrixdb.yml          # 在上述节点上安装MatrixDB
```



