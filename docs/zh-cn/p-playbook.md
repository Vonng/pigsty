# Ansible剧本

> 了解Pigsty提供的预置剧本，以及如何使用

Pigsty在底层使用Ansible Playbook对节点进行管理。

## 剧本概览

Pigsty提供了以下预置剧本

**基础设施初始化**

* [`infra.yml`](https://github.com/vonng/pigsty/blob/master/infra.yml) ：基础设施初始化
* [`infra-demo.yml`](https://github.com/vonng/pigsty/blob/master/infra-demo.yml) ：基础设施初始化（一趟完成管理节点与数据库节点的完整初始化）
* [`infra-jupyter.yml`](https://github.com/vonng/pigsty/blob/master/infra-jupyter.yml) ：基础设施：可选数据分析服务组件组件Jupyter Lab安装
* [`infra-loki.yml`](https://github.com/vonng/pigsty/blob/master/infra-loki.yml) ：基础设施：可选日志收集组件Loki安装
* [`infra-pgweb.yml`](https://github.com/vonng/pigsty/blob/master/infra-pgweb.yml) ：基础设施：可选的Web客户端工具PGWeb安装


**PostgreSQL初始化**

* [`pgsql.yml`](https://github.com/vonng/pigsty/blob/master/pgsql.yml) ：PostgreSQL：集群与实例初始化
* [`pgsql-remove.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-remove.yml) ：PostgreSQL：集群/实例下线
* [`pgsql-createdb.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-createdb.yml) ：PostgreSQL：创建业务数据库
* [`pgsql-createuser.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-createuser.yml) ：PostgreSQL：创建业务用户
* [`pgsql-monly.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-monly.yml) ：PostgreSQL：仅监控模式，接入已有实例。


**PostgreSQL管理(可选)**

* [`pgsql-migration.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-migration.yml) ：PostgreSQL：半自动数据库迁移方案
* [`pgsql-audit.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-audit.yml) ：PostgreSQL：生成审计合规报告
* [`pgsql-promtail.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-promtail.yml) ：PostgreSQL：实时日志收集组件Promtail

**Redis初始化**
* [`redis.yml`](https://github.com/vonng/pigsty/blob/master/redis.yml) ：Redis：集群/实例初始化

