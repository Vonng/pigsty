# 幂等剧本

在 Pigsty 中，剧本 / Playbooks 用于在节点上安装[模块](arch#模块)。

剧本可以视作可执行文件直接执行，例如：`./install.yml`.


----------------

## 剧本

以下是 Pigsty 中默认包含的剧本：

| 剧本                                                                                       | 功能                               |
|------------------------------------------------------------------------------------------|----------------------------------|
| [`install.yml`](https://github.com/vonng/pigsty/blob/master/install.yml)                 | 在当前节点上一次性完整安装 Pigsty             |
| [`infra.yml`](https://github.com/vonng/pigsty/blob/master/infra.yml)                     | 在 infra 节点上初始化 pigsty 基础设施       |
| [`infra-rm.yml`](https://github.com/vonng/pigsty/blob/master/infra-rm.yml)               | 从 infra 节点移除基础设施组件               |
| [`node.yml`](https://github.com/vonng/pigsty/blob/master/node.yml)                       | 纳管节点，并调整节点到期望的状态                 |
| [`node-rm.yml`](https://github.com/vonng/pigsty/blob/master/node-rm.yml)                 | 从 pigsty 中移除纳管节点                 |
| [`pgsql.yml`](https://github.com/vonng/pigsty/blob/master/pgsql.yml)                     | 初始化 HA PostgreSQL 集群或添加新的从库实例    |
| [`pgsql-rm.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-rm.yml)               | 移除 PostgreSQL 集群或移除从库实例          |
| [`pgsql-user.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-user.yml)           | 向现有的 PostgreSQL 集群添加新的业务用户       |
| [`pgsql-db.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-db.yml)               | 向现有的 PostgreSQL 集群添加新的业务数据库      |
| [`pgsql-monitor.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-monitor.yml)     | 监控纳管远程 postgres 实例               |
| [`pgsql-migration.yml`](https://github.com/vonng/pigsty/blob/master/pgsql-migration.yml) | 为现有的 PostgreSQL 生成迁移手册和脚本        |
| [`redis.yml`](https://github.com/vonng/pigsty/blob/master/redis.yml)                     | 初始化 redis 集群/节点/实例               |
| [`redis-rm.yml`](https://github.com/vonng/pigsty/blob/master/redis-rm.yml)               | 移除 redis 集群/节点/实例                |
| [`etcd.yml`](https://github.com/vonng/pigsty/blob/master/etcd.yml)                       | 初始化 etcd 集群（patroni HA DCS所需）    |
| [`minio.yml`](https://github.com/vonng/pigsty/blob/master/minio.yml)                     | 初始化 minio 集群（pgbackrest 备份仓库备选项） |
| [`cert.yml`](https://github.com/vonng/pigsty/blob/master/cert.yml)                       | 使用 pigsty 自签名 CA 颁发证书（例如用于客户端）   |
| [`docker.yml`](https://github.com/vonng/pigsty/blob/master/docker.yml)                   | 在节点上安装 docker                    |
| [`mongo.yml`](https://github.com/vonng/pigsty/blob/master/mongo.yml)                     | 在节点上安装 Mongo/FerretDB            |


----------------

### 一次性安装

特殊的剧本 `install.yml` 实际上是一个复合剧本，它在当前环境上安装所有以下组件。

```bash

  playbook  / command / group         infra           nodes    etcd     minio     pgsql
[infra.yml] ./infra.yml [-l infra]   [+infra][+node] 
[node.yml]  ./node.yml                               [+node]  [+node]  [+node]   [+node]
[etcd.yml]  ./etcd.yml  [-l etcd ]                            [+etcd]
[minio.yml] ./minio.yml [-l minio]                                     [+minio]
[pgsql.yml] ./pgsql.yml                                                          [+pgsql]
```

请注意，[`NODE`](node) 和 [`INFRA`](infra) 之间存在循环依赖：为了在 INFRA 上注册 NODE，INFRA 应该已经存在，而 INFRA 模块依赖于 INFRA节点上的 NODE 模块才能工作。

为了解决这个问题，INFRA 模块的安装剧本也会在 INFRA 节点上安装 NODE 模块。所以，请确保首先初始化 INFRA 节点。

如果您非要一次性初始化包括 INFRA 在内的所有节点，`install.yml` 剧本就是用来解决这个问题的：它会正确的处理好这里的循环依赖，一次性完成整个环境的初始化。



----------------

## Ansible

执行剧本需要 `ansible-playbook` 可执行文件，该文件包含在 `ansible` 包中。

Pigsty 将在 [准备](install#准备) 期间在 `admin` 节点上安装 `ansible`。

您可以自己使用 `yum` / `apt` / `brew`  `install ansible` 来安装 Ansible，它含在各大发行版的默认仓库中。

了解 ansible 对于使用 Pigsty 很有帮助，但也不是必要的。对于基本使用，您只需要注意三个参数就足够了：

- `-l|--limit <pattern>` : 限制剧本在特定的组/主机/模式上执行目标（在哪里/Where）
- `-t|--tags <tags>`: 只运行带有特定标签的任务（做什么/What）
- `-e|--extra-vars <vars>`: 传递额外的命令行参数（怎么做/How）


----------------

## 指定执行对象

您可以使用 `-l|-limit <selector>` 限制剧本的执行目标。

缺少此值可能很危险，因为大多数剧本会在 `all` 分组，也就是所有主机上执行，使用时务必小心。

以下是一些主机限制的示例：

```bash
./pgsql.yml                              # 在所有主机上运行（非常危险！）
./pgsql.yml   -l pg-test                 # 在 pg-test 集群上运行
./pgsql.yml   -l 10.10.10.10             # 在单个主机 10.10.10.10 上运行
./pgsql.yml   -l pg-*                    # 在与通配符 `pg-*` 匹配的主机/组上运行
./pgsql.yml   -l '10.10.10.11,&pg-test'  # 在组 pg-test 的 10.10.10.10 上运行
/pgsql-rm.yml -l 'pg-test,!10.10.10.11'  # 在 pg-test 上运行，除了 10.10.10.11 以外
./pgsql.yml   -l pg-test                 # 在 pg-test 集群的主机上执行 pgsql 剧本
````


----------------

## 执行剧本子集

你可以使用 `-t|--tags <tag>` 执行剧本的子集。 你可以在逗号分隔的列表中指定多个标签，例如 `-t tag1,tag2`。

如果指定了任务子集，将执行给定标签的任务，而不是整个剧本。以下是任务限制的一些示例：

```bash
./pgsql.yml -t pg_clean    # 如果必要，清理现有的 postgres
./pgsql.yml -t pg_dbsu     # 为 postgres dbsu 设置操作系统用户 sudo
./pgsql.yml -t pg_install  # 安装 postgres 包和扩展
./pgsql.yml -t pg_dir      # 创建 postgres 目录并设置 fhs
./pgsql.yml -t pg_util     # 复制工具脚本，设置别名和环境
./pgsql.yml -t patroni     # 使用 patroni 引导 postgres
./pgsql.yml -t pg_user     # 提供 postgres 业务用户
./pgsql.yml -t pg_db       # 提供 postgres 业务数据库
./pgsql.yml -t pg_backup   # 初始化 pgbackrest 仓库和 basebackup
./pgsql.yml -t pgbouncer   # 与 postgres 一起部署 pgbouncer sidecar
./pgsql.yml -t pg_vip      # 使用 vip-manager 将 vip 绑定到 pgsql 主库
./pgsql.yml -t pg_dns      # 将 dns 名称注册到 infra dnsmasq
./pgsql.yml -t pg_service  # 使用 haproxy 暴露 pgsql 服务
./pgsql.yml -t pg_exporter # 使用 haproxy 暴露 pgsql 服务
./pgsql.yml -t pg_register # 将 postgres 注册到 pigsty 基础设施

# 运行多个任务：重新加载 postgres 和 pgbouncer hba 规则
./pgsql.yml -t pg_hba,pgbouncer_hba,pgbouncer_reload

# 运行多个任务：刷新 haproxy 配置并重新加载
./node.yml -t haproxy_config,haproxy_reload
```


----------------

## 传递额外参数

您可以通过 `-e|-extra-vars KEY=VALUE` 传递额外的命令行参数。

命令行参数具有压倒性的优先级，以下是一些额外参数的示例：

```bash
./node.yml -e ansible_user=admin -k -K                  # 作为另一个用户运行剧本（带有 admin sudo 密码）
./pgsql.yml -e pg_clean=true                            # 在初始化 pgsql 实例时强制清除现有的 postgres
./pgsql-rm.yml -e pg_uninstall=true                     # 在 postgres 实例被删除后明确卸载 rpm
./redis.yml -l 10.10.10.11 -e redis_port=6379 -t redis  # 初始化一个特定的 redis 实例：10.10.10.11:6379
./redis-rm.yml -l 10.10.10.13 -e redis_port=6379        # 删除一个特定的 redis 实例：10.10.10.11:6379
```

大多数剧本都是幂等的，这意味着在未打开保护选项的情况下，一些部署剧本可能会 **删除现有的数据库** 并创建新的数据库。

**请仔细阅读文档，多次校对命令，并小心操作。作者不对因误用造成的任何数据库损失负责**。

