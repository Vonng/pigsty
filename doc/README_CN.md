# Pigsty —— 图形化PostgreSQL环境

> PIGSTY: Postgres in Graphic STYle （图形化PostgreSQL环境）

本项目为图形化PostgreSQL（`pigsty`）的演示项目，带有一套高可用集群方案与集成的监控系统。

本项目经过真实生产环境的长期考验，可以直接用于开发，测试、生产，并提供基于[vagrant](https://vagrantup.com/)的四虚拟机沙箱环境用于功能演示。



## 亮点

* 高可用PostgreSQL数据库集群，生产验证的部署方案
* 自包含的监控、报警、日志收集系统，基于DCS的自动服务发现
* 自包含的本地源，离线安装所有依赖，无需外网访问。
* 针对四种主要场景：OLTP，OLAP，核心库，虚拟机进行专项优化
* 常用管理，维护，备份，恢复脚本
* 参数化，声明式定义的基础设施，幂等式的执行方式。

  


## 快速开始

1. **准备机器**

   * 使用预分配好的机器，或基于预定义的沙箱[Vagrantfile](vagrant/Vagrant)在本地生成演示虚拟机，选定一台作为中控机。

   * 配置中控机到其他机器的SSH免密码访问，并确认所使用的的SSH用户在机器上具有免密码`sudo`的权限。

2. **准备项目**

   在中控机上安装Ansible，克隆本项目，并下载离线安装包（可选）

   ```bash
   git clone https://github.com/vonng/pigsty && cd pigsty 
   ```

3. **修改配置**

   根据需求修改配置文件根据需求修改全局参数，并按需修改初始化模板。
    * [`cls/inventory.yml`](cls/inventory.yml)定义了目标机器的连接信息与主机级变量，通常需要修改其中的机器IP信息。
    * [`group_vars/all.yml`](group_vars/all.yml)定义了默认的组变量，包含全局一致的基础设施配置信息，通常只需少量修改。
    * [`templates/`](templates/) 中定义了数据库的通用初始化模板，通常不需要修改，但可以按需定制。
   
  4. **初始化基础设施**

     ```bash
     ./infra.yml
     ```

  5. **初始化数据库集群**

     ```bash
     ./postgres.yml
     ```

6. **开始探索**

   执行`sudo make dns`可以将沙箱所需域名写入本机`/etc/hosts`，然后即可访问 http://pigsty

   初始化完成后，可以访问控制节点上的3000端口，admin:admin查看Grafana监控。

   

## 配置详情

项目的配置文件分为四部分：

**全局变量定义**

全局变量默认定义于`group_vars/all.yml`，针对不同的环境（开发，测试，生产），可以使用不同的全局变量，并通过软连接将`all.yml`指向对应的环境配置。
全局变量针对所有机器生效，当用户希望使用统一的配置时，例如在所有机器上配置相同的 DNS，NTP Server，安装相同的软件包，使用统一的su密码时，可以修改全局变量
全局变量定义分为8个部分，具体的配置项请参阅文档

* 连接信息
* 本地源定义
* 机器节点初始化
* 控制节点初始化
* DCS元数据库初始化
* Postgres安装
* Postgres集群初始化
* 监控初始化
* 负载均衡代理初始化



**主机变量定义**

主机清单（IP，ssh信息，主机变量）默认定义于`cls/inventory.yml`，该文件包含了一套环境中所有主机相关的信息。可以通过`ansible -i <path>`使用其他的主机清单文件。
主机清单使用`ini`格式，定义了一系列分组，默认分组`meta`包含了控制节点的信息。其他分组每个都包含了一个数据库集群的定义。
例如，下面的例子定义了一个名为`pg-test`的集群，其中有三个实例，`10.10.10.11`为主库，`10.10.10.12`与`10.10.10.13`为从库，安装12版本的PostgreSQL数据库。

```ini
[pg-test]
10.10.10.11 ansible_host=node-1 pg_role=primary pg_seq=1
10.10.10.12 ansible_host=node-2 pg_role=replica pg_seq=2
10.10.10.13 ansible_host=node-3 pg_role=replica pg_seq=3

[pg-test:vars]
pg_cluster = pg-test
pg_version = 12
```

**数据库初始化模板**

初始化模板是用于初始化数据库集群的定义文件，默认位于`roles/postgres/templates/patroni.yml`，采用`patroni.yml` [配置文件格式](https://patroni.readthedocs.io/en/latest/SETTINGS.html)
在[`templates/`](templates/)目录中，有四种预定义好的初始化模板：
* [`oltp.yml`](oltp.yml) 常规OLTP模板，默认配置
* [`olap.yml`](olap.yml) OLAP模板，提高并行度，针对吞吐量优化，针对长时间运行的查询进行优化。
* [`crit.yml`](crit.yml) 核心业务模板，基于OLTP模板针对安全性，数据完整性进行优化，采用同步复制，启用数据校验和。
* [`tiny.yml`](tiny.yml) 微型数据库模板，针对低资源场景进行优化，例如运行于虚拟机中的演示数据库集群。

用户也可以基于上述模板进行定制与修改，并通过`pg_conf`参数使用相应的模板。


**数据库初始化脚本**

当数据库初始化完毕后，用户通常希望对数据库进行自定义的定制脚本，例如创建统一的默认角色，用户，创建默认的模式，配置默认权限等。
本项目提供了一个默认的初始化脚本`roles/postgres/templates/initdb.sh`，基于以下几个变量创建默认的数据库与用户。

```yaml
pg_default_username: postgres                 # non 'postgres' will create a default admin user (not superuser)
pg_default_password: postgres                 # dbsu password, omit for 'postgres'
pg_default_database: postgres                 # non 'postgres' will create a default database
pg_default_schema: public                     # default schema will be create under default database and used as first element of search_path
pg_default_extensions: "tablefunc,postgres_fdw,file_fdw,btree_gist,btree_gin,pg_trgm"
```

用户可以基于本脚本进行定制，并通过`pg_init`参数使用相应的自定义脚本。


