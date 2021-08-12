# Pigsty部署

部署Pigsty分为三步：[准备工作](t-prepare.md)，[修改配置](c-config.md)，[执行剧本](#执行剧本)

Pigsty在部署前需要进行一些[准备工作](t-prepare.md)：配置带有正确权限配置的节点，下载安装相关软件。置备完成后，用户应当按照自己的需求[修改配置](v-config.md)，并[执行剧本](#执行剧本)将系统调整至配置描述的状态。其中，**配置**是部署Pigsty的重点所在。

## 部署方式

* [标准部署](t-deploy.md)：在准备好的机器节点上完成标准Pigsty部署流程。
* [沙箱部署](s-sandbox.md) ： 通过`vagrant`自动准备环境确定的虚拟机资源，极大简化了Pigsty部署流程。
* [仅监控部署](t-monly.md) ： 使用Pigsty监控现有数据库集群的特殊部署模式。

无论何种部署，其流程都分为三步：[准备资源](t-prepare.md)，[修改配置](c-config.md)，[执行剧本](p-playbook.md)。Pigsty在部署前需要进行一些[准备工作](t-prepare.md)：配置带有正确权限配置的节点，下载安装相关软件。置备完成后，用户应当按照自己的需求[修改配置](c-config.md)，并[执行剧本](p-playbook.md)将系统调整至配置描述的状态。其中准备与执行这两个步骤非常简单，**配置** 是部署Pigsty的关键点所在。

## [准备工作](t-prepare.md)

- [节点置备](t-prepare.md#节点置备)
- [管理节点置备](t-prepare.md#管理节点置备)
- [管理用户置备](t-prepare.md#管理用户置备)
- [软件置备](t-prepare.md#软件置备)

## [修改配置](c-config.md)

- [配置项](c-config#配置项)
- [配置文件](c-config#配置文件)
- [基础设施配置](c-config#基础设施配置)
- [数据库集群配置](c-config#数据库集群配置)
- [身份参数](c-config#身份参数)
- [连接信息](c-config#连接信息)
- [定制业务用户](c-user.md)
- [定制业务数据库](c-database.md)
- [定制Patroni配置模板](t-patroni-template.md)
- [深度定制数据库模板](t-customize-template.md)


## 执行剧本

* [基础设施初始化](p-infra.md)
* [数据库初始化](p-pgsql.md) （集群创建，新增实例）
* [数据库下线](p-pgsql-remove.md)（移除实例，移除集群）
* [创建业务用户](p-pgsql-createuser.md)
* [创建业务数据库](p-pgsql-createdb.md)







