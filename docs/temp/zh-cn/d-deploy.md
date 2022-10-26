# Pigsty部署

> 部署Pigsty分为三步：[部署准备](d-prepare.md)，[修改配置](v-config.md)，[执行剧本](p-playbook)

Pigsty的资源准备、下载安装、部署扩容缩容均为一键傻瓜式，真正的灵魂在于 [**配置**](v-config.md)。

----------------

## [准备工作](d-prepare.md)

> 安装Pigsty前，您需要准备符合要求的资源：物理机/虚拟机节点，管理用户，下载Pigsty软件。

- [节点置备](d-prepare.md#节点置备)
- [元节点置备](d-prepare.md#元节点置备)
- [管理用户置备](d-prepare.md#管理用户置备)
- [软件置备](d-prepare.md#软件置备)


----------------

## [修改配置](v-config.md)

> 完成准备工作后，您需要通过[配置](v-config.md#配置过程)向Pigsty表明自己的需求。我需要什么样的基础设施与数据库服务。

* [配置基础设施](v-infra.md)
* [配置主机节点](v-nodes.md)
* [配置PGSQL集群](v-pgsql.md) / [定制PGSQL集群](v-pgsql-customize.md) / [部署PGSQL集群](d-pgsql.md)
* [配置Redis集群](v-redis.md)  / [部署Redis集群](d-redis.md)
* [部署MatrixDB集群](d-matrixdb.md)



----------------

## [执行剧本](p-playbook.md)

> 修改配置后，您已经向Pigsty表明了自己的需求。接下来便可以通过[执行剧本](p-playbook.md)，将需求落地。

* [元节点安装](p-infra.md#infra) / [Pigsty卸载](p-infra.md#infra-remove)
* [添加节点](p-nodes.md#nodes) / [移除节点](p-nodes.md#nodes-remove)
* [部署PGSQL集群](p-pgsql.md#pgsql) / [下线PGSQL集群](p-pgsql.md#pgsql-remove)
* [创建PGSQL业务用户](p-pgsql.md#pgsql-createuser) / [创建PGSQL业务数据库](p-pgsql.md#pgsql-createdb)
* [部署Redis集群](p-redis.md#redis) / [下线Redis集群](p-redis.md#redis-remove)




----------------

## 部署方式

* [标准部署](d-deploy.md)：您自己准备全新节点，完成标准Pigsty部署流程。
* [沙箱部署](d-sandbox.md.md) ： 通过预制的`vagrant`模板一键拉起本地虚拟机沙箱环境。
* 多云部署：使用`terraform`模板在云服务供应商处拉起所需虚拟机资源，并执行部署。
* [仅监控部署](d-monly.md) ： 使用单节点Pigsty监控现有数据库集群。
