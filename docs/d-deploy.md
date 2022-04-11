# Pigsty Deployment

> It takes 3 steps to deploy Pigsty：[Prepare](d-prepare.md), [Configure](v-config.md), [Playbook](p-playbook)

----------------



## [Preparation](d-prepare.md)

> 安装Pigsty前，您需要准备符合要求的资源：物理机/虚拟机节点，管理用户，下载Pigsty软件。

- [节点置备](d-prepare.md#节点置备)
- [管理节点置备](d-prepare.md#管理节点置备)
- [管理用户置备](d-prepare.md#管理用户置备)
- [软件置备](d-prepare.md#软件置备)


----------------



## [Configuration](v-config.md)

> 完成准备工作后，您需要通过[配置](v-config.md#配置过程)向Pigsty表明自己的需求。我需要什么样的基础设施与数据库服务。

* [Configure Infra](v-infra.md)
* [Configure Nodes](v-nodes.md)
* [Configure PGSQL Cluster](v-pgsql.md) / [Customize PGSQL Cluster](v-pgsql-customize.md) /[Deploy PGSQL Cluster](d-pgsql.md)
* [Configure Redis Cluster](v-redis.md)  / [Deploy Redis Cluster](d-redis.md)
* [Deploy MatrixDB Cluster](d-matrixdb.md)

----------------



## [Playbook Execution](p-playbook.md)

> 修改配置后，您已经向Pigsty表明了自己的需求。接下来便可以通过[执行剧本](p-playbook.md)，将需求落地。

* [Install Pigsty on Meta](p-infra.md#infra) / [Pigsty Uninstall](p-infra.md#infra-remove)
* [添加节点](p-nodes.md#nodes) / [移除节点](p-nodes.md#nodes-remove)
* [部署PGSQL集群](p-pgsql.md#pgsql) / [下线PGSQL集群](p-pgsql.md#pgsql-remove)
* [创建PGSQL业务用户](p-pgsql.md#pgsql-createuser) / [创建PGSQL业务数据库](p-pgsql.md#pgsql-createdb)
* [部署Redis集群](p-redis.md#redis) / [下线Redis集群](p-redis.md#redis-remove)





----------------

## Deployment

* [标准部署](d-deploy.md)：您自己准备全新节点，完成标准Pigsty部署流程。
* [沙箱部署](d-sandbox.md.md) ： 通过预制的`vagrant`模板一键拉起本地虚拟机沙箱环境。
* 多云部署：使用`terraform`模板在云服务供应商处拉起所需虚拟机资源，并执行部署。
* [仅监控部署](d-monly) ： 使用单节点Pigsty监控现有数据库集群。



