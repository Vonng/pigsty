# Pigsty部署

> 部署Pigsty分为三步：[部署准备](d-prepare.md)，[修改配置](v-config.md)，[执行剧本](p-playbook)

----------------

## [准备工作](d-prepare.md)

> 安装Pigsty前，您需要准备符合要求的资源：物理机/虚拟机节点，管理用户，以及Pigsty软件。

- [节点置备](d-prepare.md#节点置备)
- [管理节点置备](d-prepare.md#管理节点置备)
- [管理用户置备](d-prepare.md#管理用户置备)
- [软件置备](d-prepare.md#软件置备)


----------------

## [修改配置](v-config.md)

> 完成准备工作后，您需要向Pigsty表明自己的需求。我需要什么样的基础设施与数据库服务。

* [配置基础设施](v-infra.md)
* [配置主机节点](v-nodes.md)
* [配置PostgreSQL集群](v-pgsql.md)
* [配置Redis集群](v-redis.md) 

----------------

## [执行剧本](p-playbook.md)

> 修改配置后，您已经向Pigsty表明了自己的需求。接下来便可以通过执行剧本，将需求落地。

* [元节点安装](p-infra.md)
* [添加节点](p-nodes.md#nodes) / [移除节点](p-nodes.md#nodes-remove)
* [部署PG集群](p-pgsql.md#pgsql) / [下线PG集群](p-pgsql.md#pgsql-remove)
* [创建PG业务用户](p-pgsql.md#pgsql-createuser) / [创建PG业务数据库](p-pgsql.md#pgsql-createdb)
* [部署Redis集群](p-redis.md#redis) / [下线Redis集群](p-redis.md#redis-remove)







[准备工作](d-prepare.md)，[修改配置](v-config.md)，[执行剧本](p-playbook)

Pigsty在部署前需要进行一些[准备工作](d-prepare.md)：配置带有正确权限配置的节点，下载安装相关软件。置备完成后，用户应当按照自己的需求[修改配置](v-config.md)，并[执行剧本](#p-playbook)将系统调整至配置描述的状态。其中，**配置**是部署Pigsty的重点所在。

## 部署方式

* [标准部署](d-deploy.md)：您自己准备全新节点，完成标准Pigsty部署流程。
* [沙箱部署](d-sandbox.md.md) ： 通过预制的`vagrant`模板一键拉起本地虚拟机沙箱环境。
* 多云部署：使用`terraform`模板在云服务供应商处拉起所需虚拟机资源，并执行部署。
* [仅监控部署](d-monly) ： 使用单节点Pigsty监控现有数据库集群。

无论何种部署，其流程都分为三步：[准备资源](d-prepare.md)，[修改配置](v-config.md)，[执行剧本](p-playbook.md)。Pigsty在部署前需要进行一些[准备工作](d-prepare.md)：配置带有正确权限配置的节点，下载安装相关软件。置备完成后，用户应当按照自己的需求[修改配置](v-config.md)，并[执行剧本](p-playbook.md)将系统调整至配置描述的状态。其中准备与执行这两个步骤非常简单，**配置** 是部署Pigsty的关键点所在。






