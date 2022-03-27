# Pigsty部署

部署Pigsty分为三步：[准备工作](d-prepare.md)，[修改配置](v-config.md)，[执行剧本](#p-playbook)

Pigsty在部署前需要进行一些[准备工作](d-prepare.md)：配置带有正确权限配置的节点，下载安装相关软件。置备完成后，用户应当按照自己的需求[修改配置](v-config.md)，并[执行剧本](#p-playbook)将系统调整至配置描述的状态。其中，**配置**是部署Pigsty的重点所在。

## 部署方式

* [标准部署](d-deploy.md)：您自己准备全新节点，完成标准Pigsty部署流程。
* [沙箱部署](d-sandbox.md.md) ： 通过预制的`vagrant`模板一键拉起本地虚拟机沙箱环境。
* 多云部署：使用`terraform`模板在云服务供应商处拉起所需虚拟机资源，并执行部署。
* [仅监控部署](d-monly) ： 使用单节点Pigsty监控现有数据库集群。

无论何种部署，其流程都分为三步：[准备资源](d-prepare.md)，[修改配置](v-config.md)，[执行剧本](p-playbook.md)。Pigsty在部署前需要进行一些[准备工作](d-prepare.md)：配置带有正确权限配置的节点，下载安装相关软件。置备完成后，用户应当按照自己的需求[修改配置](v-config.md)，并[执行剧本](p-playbook.md)将系统调整至配置描述的状态。其中准备与执行这两个步骤非常简单，**配置** 是部署Pigsty的关键点所在。

## [准备工作](d-prepare.md)

- [节点置备](d-prepare.md#节点置备)
- [管理节点置备](d-prepare.md#管理节点置备)
- [管理用户置备](d-prepare.md#管理用户置备)
- [软件置备](d-prepare.md#软件置备)


## [修改配置](v-config.md)

- [配置项](v-config.md#配置项)
- [配置文件](v-config.md#配置文件)
- [基础设施配置](v-config.md#基础设施配置)
- [数据库集群配置](v-config.md#数据库集群配置)
- [身份参数](v-config.md#身份参数)
- [连接信息](v-config.md#连接信息)
- [定制PG业务用户](c-pgdbuser.md#用户)
- [定制PG业务数据库](c-pgdbuser.md#用户)
- [定制PG模板](v-pgsql-customize.md)


## [执行剧本](p-playbook.md)

* [基础设施初始化](p-infra.md)
* [数据库初始化](p-pgsql.md) （集群创建，新增实例）
* [数据库下线](p-pgsql-remove.md)（移除实例，移除集群）
* [创建业务用户](p-pgsql-createuser.md)
* [创建业务数据库](p-pgsql-createdb.md)







