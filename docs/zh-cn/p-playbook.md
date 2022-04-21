# Pigsty剧本

> 了解Pigsty提供的预置剧本，功能、使用方式与注意事项。

Pigsty在底层通过 [Ansible Playbook](#Ansible快速上手) 实现核心管控功能，Pigsty提供的预置剧本分为四大类：

* [`infra`](p-infra.md) : 使用 `infra` 系列剧本在元节点上单机安装Pigsty，并加装可选功能。
* [`nodes`](p-nodes.md) : 使用 `nodes` 系列剧本将更多节点纳入Pigsty监控管理，并供后续使用。
* [`pgsql`](p-pgsql.md) : 使用 `pgsql` 系列剧本在已有节点上部署与管理PostgreSQL数据库集群。
* [`redis`](p-redis.md) : 使用 `redis` 系列剧本在已有节点上部署与管理各种模式的Redis集群。 

## 剧本概览

| 剧本 | 功能                                                           | 链接                                                         |
|--------|----------------------------------------------------------------| ------------------------------------------------------------ |
|  [**infra**](p-infra.md#infra)                        |        **在元节点上完整安装Pigsty**                                 |        [`src`](https://github.com/vonng/pigsty/blob/master/infra.yml)            |
|  [`infra-demo`](p-infra.md#infra-demo)              |        一次性完整初始化四节点演示沙箱环境的特殊剧本                           |        [`src`](https://github.com/vonng/pigsty/blob/master/infra-demo.yml)       |
|  [`infra-jupyter`](p-infra.md#infra-jupyter)        |        在元节点上加装**可选**数据分析服务组件Jupyter Lab              |        [`src`](https://github.com/vonng/pigsty/blob/master/infra-jupyter.yml)    |
|  [`infra-pgweb`](p-infra.md#infra-pgweb)            |        在元节点上加装**可选**的Web客户端工具PGWeb                     |        [`src`](https://github.com/vonng/pigsty/blob/master/infra-pgweb.yml)      |
|  [**nodes**](p-nodes.md#nodes)                        |        **节点置备，将节点纳入Pigsty管理，可用于后续数据库部署**                    |        [`src`](https://github.com/vonng/pigsty/blob/master/nodes.yml)            |
|  [`nodes-remove`](p-nodes.md#nodes-remove)          |        节点移除，卸载节点DCS与监控，不再纳入Pigsty管理                     |        [`src`](https://github.com/vonng/pigsty/blob/master/nodes-remove.yml)     |
|  [**pgsql**](p-pgsql.md#pgsql)                        |        **部署PostgreSQL集群，或集群扩容**                             |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql.yml)            |
|  [`pgsql-remove`](p-pgsql.md#pgsql-remove)          |        下线PostgreSQL集群，或集群缩容                             |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-remove.yml)     |
|  [`pgsql-createuser`](p-pgsql.md#pgsql-createuser)  |        创建PostgreSQL业务用户                                 |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-createuser.yml) |
|  [`pgsql-createdb`](p-pgsql.md#pgsql-createdb)      |        创建PostgreSQL业务数据库                                |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-createdb.yml)   |
|  [`pgsql-monly`](p-pgsql.md#pgsql-monly)            |        仅监控模式，接入现存PostgreSQL实例或RDS                       |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-monly.yml)      |
|  [`pgsql-migration`](p-pgsql.md#pgsql-migration)    |        生成PostgreSQL半自动数据库迁移方案（Beta）                     |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-migration.yml)  |
|  [`pgsql-audit`](p-pgsql.md#pgsql-audit)            |        生成PostgreSQL审计合规报告（Beta）                         |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-audit.yml)      |
|  [`pgsql-matrix`](p-pgsql.md#pgsql-matrix)          |        复用PG角色部署一套MatrixDB数据仓库集群（Beta）                   |        [`src`](https://github.com/vonng/pigsty/blob/master/pgsql-matrix.yml)     |
|  [**redis**](p-redis.md#redis)                        |        **部署集群/主从/Sentinel模式的Redis数据库**              |        [`src`](https://github.com/vonng/pigsty/blob/master/redis.yml)            |
|  [`redis-remove`](p-redis.md#redis-remove)          |        Redis集群/节点下线                                     |        [`src`](https://github.com/vonng/pigsty/blob/master/redis-remove.yml)     |

典型使用流程如下：

1. 使用 [`infra`](p-infra.md) 系列剧本在元节点/本机安装 Pigsty ，部署基础设施。
   
   所有剧本都在元节点上发起执行，`infra` 系列剧本只作用于元节点本身。

2. 使用 [`nodes`](p-nodes.md) 系列剧本将其他节点纳入或移除Pigsty管理

   节点被托管后，可从元节点Grafana访问节点监控与日志，节点加入Consul集群。

3. 使用 [`pgsql`](p-pgsql.md) 系列剧本在纳入管理的节点上部署PostgreSQL集群

   在托管节点上执行部署后，可以从元节点访问PostgreSQL监控与日志。

4. 使用 [`redis`](p-redis.md) 系列剧本在纳入管理的节点上部署Redis集群

   在托管节点上执行部署后，可以从元节点访问Redis监控与日志。

```
                                           meta     node
[infra.yml]  ./infra.yml [-l meta]        +pigsty 
[nodes.yml]  ./nodes.yml -l pg-test                 +consul +monitor
[pgsql.yml]  ./pgsql.yml -l pg-test                 +pgsql
[redis.yml]  ./redis.yml -l pg-test                 +redis
```



绝大多数剧本都是幂等设计，这意味着一些部署剧本在没有开启保护选项的情况下，可能会抹除现有数据库并创建新数据库。
当您处理现有数据库集群，或在生产环境进行操作时，请充分阅读并理解文档，再三校对命令，谨慎操作。对于误操作导致的数据库损失，作者不负任何责任。

------------------



## Ansible快速上手

Pigsty剧本使用Ansible编写，您并不需要完全理解Ansible的原理，只需要很少的知识即足以充分利用 Ansible 剧本。

* [Ansible安装](#Ansible安装)：如何安装Ansible？（Pigsty用户通常无需操心）
* [主机子集](#主机子集)：如何针对特定主机执行剧本？
* [任务子集](#任务子集)：如何执行剧本中的某些特定任务？
* [额外参数](#额外参数)：如何传入额外的命令行参数以控制剧本行为？

### Ansible安装

Ansible剧本需要使用`ansible-playbook`可执行命令，在EL7兼容系统中可通过以下命令安装 Ansible。

```bash
yum install ansible
```

当使用离线软件包时，Pigsty会在Configure阶段尝试从离线软件包中安装ansible。

执行Ansible剧本时，直接将剧本作为可执行程序执行即可。执行剧本时有三个核心的参数需要关注：`-l|-t|-e`，分别用于限制执行的主机，与执行的任务，以及传入额外的参数。

### 主机子集

可以通过 `-l|--limit <selector>` 参数选择执行的目标，不指定此参数时，大多数剧本默认会以配置文件中定义的所有主机作为执行对象，这是非常危险的。
强烈建议在执行剧本时，指定执行的对象。

常用的对象有两种，集群与主机，例如：

```bash
./pgsql.yml                 # 在配置清单的所有主机上执行pgsql剧本（危险！）
./pgsql.yml -l pg-test      # 针对 pg-test 集群中的主机执行pgsql剧本
./pgsql.yml -l 10.10.10.10  # 针对 10.10.10.10 的主机执行pgsql剧本
./pgsql.yml -l pg-*         # 针对符合 pg-* 模式 (glob) 的集群执行剧本
```


### 任务子集

可以通过`-t|--tags <tags>`来选择执行的任务子集，不指定此参数时，会执行完整的剧本，指定此参数时，则将执行所选的任务子集，这是非常实用的。

```bash
./pgsql.yml -t pg_hba                            # 重新生成并应用集群HBA规则
```

用户可以通过`,`分隔，一次执行多个任务，例如当集群角色成员发生变化时，可以使用以下命令调整集群负载均衡配置。

```bash
./pgsql.yml -t haproxy_config,haproxy_reload     # 重新生成集群负载均衡器配置并应用
```



### 额外参数

可以通过`-e|--extra-vars KEY=VALUE` 传入额外的命令行参数，覆盖已有参数，或控制一些特殊的行为。

例如，以下剧本的部分行为可以通过命令行参数进行控制。

```bash
./nodes.yml -e ansible_user=admin -k -K      # 在配置节点时，使用另一个管理员用户 admin，并输入ssh与sudo密码
./pgsql.yml -e pg_exists_action=clean        # 在安装PG时，强制抹除已有运行中数据库实例（危险）
./infra-remove.yml -e rm_metadata=true       # 在卸载Pigsty时，一并移除数据
./infra-remove.yml -e rm_metadpkgs=true      # 在卸载Pigsty时，一并卸载软件
./nodes-remove.yml -e rm_dcs_server=true     # 在移除节点时，即使上面有DCS Server也强制移除
./pgsql-remove.yml -e rm_pgdata=true         # 在移除PG时，一并移除数据
./pgsql-remove.yml -e rm_pgpkgs=true         # 在移除PG时，一并卸载软件
```

