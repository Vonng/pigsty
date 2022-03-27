# 配置Pigsty

Pigsty采用声明式[配置](v-config.md)：用户配置描述状态，而Pigsty负责将真实组件调整至所期待的状态。

Pigsty包含了220个固定[配置项](#配置项清单)，分为四个部分：[INFRA](v-infra.md), [NODES](v-nodes.md), [PGSQL](v-pgsql.md), [REDIS](v-redis.md)，共计32类。

通常只有节点/数据库**身份参数**是必选参数，其他配置参数可直接使用默认值，按需修改。

| Category              | Section                                         | Description      | Count |
|-----------------------|-------------------------------------------------|------------------|-------|
| [`INFRA`](v-infra.md) | [`CONNECT`](v-infra.md#CONNECT)                 | 连接参数             | 1     |
| [`INFRA`](v-infra.md) | [`REPO`](v-infra.md#REPO)                       | 本地源基础设施          | 10    |
| [`INFRA`](v-infra.md) | [`CA`](v-infra.md#CA)                           | 公私钥基础设施          | 5     |
| [`INFRA`](v-infra.md) | [`NGINX`](v-infra.md#NGINX)                     | NginxWeb服务器      | 5     |
| [`INFRA`](v-infra.md) | [`NAMESERVER`](v-infra.md#NAMESERVER)           | DNS服务器           | 1     |
| [`INFRA`](v-infra.md) | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | 监控时序数据库          | 7     |
| [`INFRA`](v-infra.md) | [`EXPORTER`](v-infra.md#EXPORTER)               | 通用Exporter配置     | 3     |
| [`INFRA`](v-infra.md) | [`GRAFANA`](v-infra.md#GRAFANA)                 | Grafana可视化平台     | 9     |
| [`INFRA`](v-infra.md) | [`LOKI`](v-infra.md#LOKI)                       | Loki日志收集平台       | 5     |
| [`INFRA`](v-infra.md) | [`DCS`](v-infra.md#DCS)                         | 分布式配置存储元数据库      | 8     |
| [`INFRA`](v-infra.md) | [`JUPYTER`](v-infra.md#JUPYTER)                 | JupyterLab数据分析环境 | 3     |
| [`INFRA`](v-infra.md) | [`PGWEB`](v-infra.md#PGWEB)                     | PGWeb网页客户端工具     | 2     |
| [`NODES`](v-nodes.md) | [`NODE_IDENTITY`](v-nodes.md#NODE_IDENTITY)     | 节点身份参数           | 5     |
| [`NODES`](v-nodes.md) | [`NODE_DNS`](v-nodes.md#NODE_DNS)               | 节点域名解析           | 5     |
| [`NODES`](v-nodes.md) | [`NODE_REPO`](v-nodes.md#NODE_REPO)             | 节点软件源            | 3     |
| [`NODES`](v-nodes.md) | [`NODE_PACKAGES`](v-nodes.md#NODE_PACKAGES)     | 节点软件包            | 4     |
| [`NODES`](v-nodes.md) | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | 节点功能特性           | 6     |
| [`NODES`](v-nodes.md) | [`NODE_MODULES`](v-nodes.md#NODE_MODULES)       | 节点内核模块           | 1     |
| [`NODES`](v-nodes.md) | [`NODE_TUNE`](v-nodes.md#NODE_TUNE)             | 节点参数调优           | 2     |
| [`NODES`](v-nodes.md) | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | 节点管理员            | 6     |
| [`NODES`](v-nodes.md) | [`NODE_TIME`](v-nodes.md#NODE_TIME)             | 节点时区与时间同步        | 4     |
| [`NODES`](v-nodes.md) | [`NODE_EXPORTER`](v-nodes.md#NODE_EXPORTER)     | 节点指标暴露器          | 3     |
| [`NODES`](v-nodes.md) | [`PROMTAIL`](v-nodes.md#PROMTAIL)               | 日志收集组件           | 5     |
| [`PGSQL`](v-pgsql.md) | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | PGSQL数据库身份参数     | 13    |
| [`PGSQL`](v-pgsql.md) | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | PGSQL业务对象定义      | 11    |
| [`PGSQL`](v-pgsql.md) | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | PGSQL安装          | 11    |
| [`PGSQL`](v-pgsql.md) | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | PGSQL集群初始化       | 24    |
| [`PGSQL`](v-pgsql.md) | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | PGSQL集群模板置备      | 9     |
| [`PGSQL`](v-pgsql.md) | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | PGSQL指标暴露器       | 13    |
| [`PGSQL`](v-pgsql.md) | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | PGSQL服务接入        | 16    |
| [`REDIS`](v-redis.md) | [`REDIS_IDENTITY`](v-redis.md#REDIS_IDENTITY)   | REDIS身份参数        | 3     |
| [`REDIS`](v-redis.md) | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | REDIS集群置备        | 14    |
| [`REDIS`](v-redis.md) | [`REDIS_EXPORTER`](v-redis.md#REDIS_EXPORTER)   | REDIS指标暴露器       | 3     |


## 配置清单

Pigsty通过**配置清单**（Inventory）来定义基础设施与数据库集群，采用"Infra as Data"的哲学。

每一套Pigsty[部署](d-deploy.md)都有一份对应的**配置**：无论是几百集群的生产环境，还是1核1GB的本地沙箱，在Pigsty中除了配置内容外没有任何区别。

在形式上，配置清单的具体实现可以是默认的本地[配置文件](#配置文件)，也可以是来自[CMDB](t-cmdb.md)中的动态配置数据（可选）。
本文介绍时均以默认YAML配置文件为例：[`pigsty.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml)

配置清单的内容主要是[配置项](#配置项)，Pigsty提供了176个配置参数，可以在多个[层次](#配置项的层次)进行配置。大多数参数可以直接使用默认值，其余按需定制即可。配置项按照类目可分为两大类：[基础设施配置](#基础设施配置) 与 [数据库集群](#数据库集群配置)，并进一步细分为十个小类：



## 配置项

配置项的形式为键值对：键是配置项的**名称**，值是配置项的内容。值的形式各异，可能是简单的单个字符串，也可能是复杂的对象数组。

Pigsty的参数可以在不同的**层次**进行配置，并依据规则继承与覆盖，高优先级的配置项会覆盖低优先级的同名配置项。因此用户可以有的放矢，可以在不同层次，不同粒度上针对具体集群与具体实例进行**精细**配置。

### 配置项的层次

在Pigsty的[配置文件](#配置文件)中，**配置项** 可以出现在三种位置，**全局**，**集群**，**实例**。**集群**`vars`中定义的配置项会以同名键覆盖的方式**覆盖全局配置项**，**实例**中定义的配置项又会覆盖集群配置项与全局配置项。

|     粒度     | 范围 | 优先级 | 说明                       | 位置                                 |
| :----------: | ---- | ------ | -------------------------- | ------------------------------------ |
|  **G**lobal  | 全局 | 低     | 在同一套**部署环境**内一致 | `all.vars.xxx`                       |
| **C**luster  | 集群 | 中     | 在同一套**集群**内保持一致 | `all.children.<cls>.vars.xxx`        |
| **I**nstance | 实例 | 高     | 最细粒度的配置层次         | `all.children.<cls>.hosts.<ins>.xxx` |

并非所有配置项都**适合**在所有层次使用。例如，基础设施的参数通常只会在**全局**配置中定义，数据库实例的标号，角色，负载均衡权重等参数只能在**实例**层次配置，而一些操作选项则只能使用命令行参数提供（例如要创建的数据库名称），关于配置项的详情与适用范围，请参考[配置项清单](v-config.md#配置项清单)。

### 兜底与覆盖

除了配置文件中的三种配置粒度，Pigsty配置项目中还有两种额外的优先级层次：默认值兜底与命令行参数强制覆盖：

* **默认**：当一个配置项在全局/集群/实例级别都没有出现时，将使用默认配置项。默认值的优先级最低，所有配置项都有默认值。默认参数定义于`roles/<role>/default/main.yml`中。
* **参数**：当用户通过命令行传入参数时，参数指定的配置项具有最高优先级，将覆盖一切层次的配置。一些配置项只能通过命令行参数的方式指定与使用。

|     层级     | 来源 | 优先级 | 说明                       | 位置                                 |
| :----------: | ---- | ------ | -------------------------- | ------------------------------------ |
| **D**efault  | 默认 | 最低   | 代码逻辑定义的默认值       | `roles/<role>/default/main.yml`      |
|  **G**lobal  | 全局 | 低     | 在同一套**部署环境**内一致 | `all.vars.xxx`                       |
| **C**luster  | 集群 | 中     | 在同一套**集群**内保持一致 | `all.children.<cls>.vars.xxx`        |
| **I**nstance | 实例 | 高     | 最细粒度的配置层次         | `all.children.<cls>.hosts.<ins>.xxx` |
| **A**rgument | 参数 | 最高   | 通过命令行参数传入         | `-e `                                |





## 配置文件

Pigsty项目根目录下有一个具体的配置文件样例：[`pigsty.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml)

配置文件顶层是一个`key`为`all`的单个对象，包含两个子项目：`vars`与`children`。

```yaml
all:                      # 顶层对象 all
  vars: <123 keys>        # 全局配置 all.vars

  children:               # 分组定义：all.children 每一个项目定义了一个数据库集群 
    meta: <2 keys>...     # 特殊分组 meta ，定义了环境管理节点
    
    pg-meta: <2 keys>...  # 数据库集群 pg-meta 的详细定义
    pg-test: <2 keys>...  # 数据库集群 pg-test 的详细定义
    ...
```

`vars`的内容为KV键值对，定义了全局配置参数，K为配置项名称，V为配置项内容。

`children` 的内容也是KV结构，K为集群名称，V为具体的集群定义，一个样例集群的定义如下所示：

* 集群定义同样包括两个子项目：`vars`定义了**集群层面**的配置。`hosts`定义了集群的实例成员。
* 集群配置中的参数会覆盖全局配置中的对应参数，而集群的配置参数又会被实例级别的同名配置参数所覆盖。集群配置参数中，唯`pg_cluster`为必选项，这是集群的名称，须与上层集群名保持一致。
* `hosts`中采用KV的方式定义集群实例成员，K为IP地址（须ssh可达），V为具体的实例配置参数
* 实例配置参数中有两个必须参数：`pg_seq`，与 `pg_role`，分别为实例的唯一序号和实例的角色。

```yaml
pg-test:                 # 数据库集群名称默认作为群组名称
  vars:                  # 数据库集群级别变量
    pg_cluster: pg-test  # 一个定义在集群级别的必选配置项，在整个pg-test中保持一致。 
  hosts:                 # 数据库集群成员
    10.10.10.11: {pg_seq: 1, pg_role: primary} # 数据库实例成员
    10.10.10.12: {pg_seq: 2, pg_role: replica} # 必须定义身份参数 pg_role 与 pg_seq
    10.10.10.13: {pg_seq: 3, pg_role: offline} # 可以在此指定实例级别的变量
```

Pigsty配置文件遵循[**Ansible规则**](https://docs.ansible.com/ansible/2.5/user_guide/playbooks_variables.html)，采用YAML格式，默认使用单一配置文件。Pigsty的默认配置文件路径为Pigsty源代码根目录下的 [`pigsty.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml) 。默认配置文件是在同目录下的[`ansible.cfg`](https://github.com/Vonng/pigsty/blob/master/ansible.cfg)通过`inventory = pigsty.yml`指定的。您可以在执行任何剧本时，通过`-i <config_path>`参数指定其他的配置文件。

配置文件需要与[**Ansible**](https://docs.ansible.com/) 配合使用。Ansible是一个流行的DevOps工具，但普通用户无需了解Ansible的具体细节。如果您精通Ansible，则可以根据Ansible的清单组织规则自行调整配置文件的组织与结构：例如，使用分立式的配置文件，为每个集群设置单独的群组定义与变量定义文件。

配置文件的内容包括两大部分：

* [基础设施配置](#基础设施配置)：定义或描述当前环境的基础设施，相对恒定
* [数据库集群配置](#数据库集群配置)：定义用户所需的数据库集群，按需添加修改



## 基础设施配置

基础设施配置主要处理此类问题：本地Yum源，机器节点基础服务：DNS，NTP，内核模块，参数调优，管理用户，安装软件包，DCS Server的架设，监控基础设施的安装与初始化（Grafana，Prometheus，Alertmanager），全局流量入口Nginx的配置等等。

通常来说，基础设施部分需要修改的内容很少，通常涉及到的主要修改只是对管理节点的IP地址进行文本替换，这一步会在`./configure`过程中自动完成，另一处有时需要改动的地方是 [`nginx_upstream`](v-infra.md#nginx_upstream)中定义的访问域名。

其他参数很少需要调整，按需即可。例如，如果您的虚拟机提供商已经为您配置了DNS服务器与NTP服务器，那么您可以将 [`node_dns_server`](v-nodes.md#node_dns_server) 与 [`node_ntp_config`](v-nodes.md#node_dns_server)设置为 `none`与`false`，跳过DNS与NTP的设置。

Pigsty针对几种典型的部署环境，提供了典型的配置文件作为**模板**。详见[`files/conf`](https://github.com/Vonng/pigsty/tree/master/files/conf)目录

在[`configure`](s-install.md#配置)过程中，配置向导会根据当前机器环境**自动选择配置模板**，但用户可以通过`-m <mode>`手工指定使用配置模板，例如：

- [`demo4`] 项目默认配置文件，4节点沙箱
- [`pg14`] 使用PG14 Beta作为默认版本的4节点沙箱部署
- [`pub4`] Pigsty官方Demo站点使用的配置文件（4台云虚拟机）
- [`demo`] 单节点沙箱，若检测到当前为沙箱虚拟机，会使用此配置
- [`tiny`] 单节点部署，若使用普通节点（微型: cpu < 8）部署，会使用此配置
- [`oltp`] 生产单节点部署，若使用普通节点（高配：cpu >= 8）部署，会使用此配置

您可以根据自己的实际部署环境，使用相应的部署模板。







## 数据库集群配置

用户更需要关注数据库集群的定义与配置。

Pigsty基于 **身份标识（Identity）** 进行管理。定义数据库集群时，**必须**提供数据库集群的[身份参数](#身份参数)与数据库节点的[连接信息](#连接信息)。**身份信息** （如集群名，实例号）用于描述**数据库集群**中的实体，而**连接信息** （如IP地址）则用于访问**数据库节点**。

在Pigsty中，关于数据库集群的配置分为五个部分：

### [安装数据库软件](v-pgsql.md)

> 安装什么版本，安装哪些插件，使用什么用户
>
> 通常这一部分的参数不需要修改任何内容即可直接使用，当PG版本升级时需要进行调整。

### [置备数据库集群](v-pgsql.md)

> 在哪创建目录，创建什么用途的集群，监听哪些IP端口，采用何种连接池模式。
>
> 在这一部分中，[**身份信息**](#身份参数) 是必选参数，除此之外需要修改默认参数的地方很少。

通过 [`pg_conf`](v-pgsql.md#pg_conf) 可以使用默认的数据库集群模板（普通事务型 OLTP/普通分析型 OLAP/核心金融型 CRIT/微型虚机 TINY）。如果希望创建自定义的模板，可以在`roles/postgres/templates`中克隆默认配置并自行修改后采用，详见**Patroni模板定制**。

### [定制数据库模板](v-pgsql.md)

> 创建哪些角色、用户、数据库、模式，启用哪些扩展，如何设置权限与白名单

需**重点关注**，因为这里是业务声明自己所需数据库的地方。用户可以通过数据库模板定制：

- [业务用户](c-user)：（使用哪些用户访问数据库？属性，限制，角色，权限……）
- [业务数据库](c-database)：（需要什么样的数据库？扩展，模式，参数，权限……）
- [默认模板数据库](v-pgsql.md) (template1) （模式、扩展、默认权限）
- [访问控制系统](c-auth)（角色，用户，HBA）
- [暴露的服务](c-service) （使用哪些端口，将流量导向哪些实例，健康检测，权重……）

### [拉起数据库监控](v-monitor.md)

> 部署Pigsty监控系统组件

通常情况下不需要调整，但在 [仅监控部署](d-monly) 模式下需要重点关注，进行调整。

### [暴露数据库服务](v-pgsql.md)

> 通过HAproxy/VIP对外提供数据库服务

除非用户希望更改默认[服务](c-service)与[接入方式](c-access)，否则不需要调整这里的配置。













## 身份参数

**身份参数**是定义数据库集群时必须提供的信息，包括：

|                    名称                     |        属性        |   说明   |         例子         |
| :-----------------------------------------: | :----------------: | :------: | :------------------: |
| [`pg_cluster`](v-pgsql.md#pg_cluster) | **必选**，集群级别 |  集群名  |      `pg-test`       |
|    [`pg_role`](v-pgsql.md#pg_role)    | **必选**，实例级别 | 实例角色 | `primary`, `replica` |
|     [`pg_seq`](v-pgsql.md#pg_seq)     | **必选**，实例级别 | 实例序号 | `1`, `2`, `3`,`...`  |

身份参数的内容遵循 [实体命名规则](c-entity.md) 。其中 [`pg_cluster`](v-pgsql.md#pg_cluster) ，[`pg_role`](v-pgsql.md#pg_role)，[`pg_seq`](v-pgsql.md#pg_seq) 属于核心身份参数，是定义数据库集群所需的**最小必须参数集**，核心身份参数**必须显式指定**，不可忽略。

- `pg_cluster` 标识了集群的名称，在集群层面进行配置，作为集群资源的顶层命名空间。
- `pg_role`标识了实例在集群中扮演的角色，在实例层面进行配置，可选值包括：

    - `primary`：集群中的**唯一主库**，集群领导者，提供写入服务。
    - `replica`：集群中的**普通从库**，承接常规生产只读流量。
    - `offline`：集群中的**离线从库**，承接ETL/SAGA/个人用户/交互式/分析型查询。
    - `standby`：集群中的**同步从库**，采用同步复制，没有复制延迟。
    - `delayed`：集群中的**延迟从库**，显式指定复制延迟，用于执行回溯查询与数据抢救。

- `pg_seq` 用于在集群内标识实例，通常采用从0或1开始递增的整数，一旦分配不再更改。
- `pg_shard` 用于标识集群所属的上层 **分片集簇**，只有当集群是水平分片集簇的一员时需要设置。
- `pg_sindex` 用于标识集群的**分片集簇**编号，只有当集群是水平分片集簇的一员时需要设置。
- `pg_instance` 是**衍生身份参数**，用于唯一标识一个数据库实例，其构成规则为

  `{{ pg_cluster }}-{{ pg_seq }}`。 因为`pg_seq`是集群内唯一的，因此该标识符全局唯一。

### 定义水平分片数据库集簇

`pg_shard` 与`pg_sindex` 用于定义特殊的分片数据库集簇，是可选的身份参数，目前保留，并未实际使用。

假设用户有一个水平分片的 **分片数据库集簇（Shard）** ，名称为`test`。这个集簇由四个独立的集群组成：`pg-test1`, `pg-test2`，`pg-test3`，`pg-test-4`。则用户可以将 `pg_shard: test` 的身份绑定至每一个数据库集群，将`pg_sindex: 1|2|3|4` 分别绑定至每一个数据库集群上。如下所示：

```yaml
pg-test1:
  vars: {pg_cluster: pg-test1, pg_shard: test, pg_sindex: 1}
  hosts: {10.10.10.10: {pg_seq: 1, pg_role: primary}}
pg-test2:
  vars: {pg_cluster: pg-test1, pg_shard: test, pg_sindex: 2}
  hosts: {10.10.10.11: {pg_seq: 1, pg_role: primary}}
pg-test3:
  vars: {pg_cluster: pg-test1, pg_shard: test, pg_sindex: 3}
  hosts: {10.10.10.12: {pg_seq: 1, pg_role: primary}}
pg-test4:
  vars: {pg_cluster: pg-test1, pg_shard: test, pg_sindex: 4}
  hosts: {10.10.10.13: {pg_seq: 1, pg_role: primary}}
```



## 连接信息

如果说身份参数是数据库集群的标识，那么**连接信息就是数据库节点的标识**。

数据库集群需要部署在数据库节点上，Pigsty使用**数据库节点与数据库实例一一对应**的部署模式。

**数据库节点使用IP地址作为标识符**，数据库实例使用形如`pg-test-1`的标识符。 **数据库节点（Node）** 与 **数据库实例（Instance）** 的标识符可以相互对应，相互转换。

例如在定义数据库集群的例子中，数据库集群`pg_cluster = pg-test` 中 `pg_seq = 1` 的数据库实例（`pg-test-1`）部署在IP地址为`10.10.10.11` 的数据库节点上。这里的IP地址`10.10.10.11`就是**连接信息**。

Pigsty使用**IP地址**作为**数据库节点**的唯一标识，**该IP地址必须是数据库实例监听并对外提供服务的IP地址**，但不宜使用公网IP地址。尽管如此，用户并不一定非要通过该IP地址连接至该数据库。例如，通过SSH隧道或跳板机中转的方式间接操作管理目标节点也是可行的。但在标识数据库节点时，首要IPv4地址依然是节点的核心标识符，**这一点非常重要，用户应当在配置时保证这一点。**

### 其他连接方式

如果您的目标机器藏在SSH跳板机之后，或者无法通过`ssh ip`的方式直接方案，则可以考虑使用[Ansible连接参数](v-infra.md.md)。

例如下面的例子中，[`ansible_host`](v-infra.md#ansible_host) 通过SSH别名的方式告知Pigsty通过`ssh node-1` 的方式而不是`ssh 10.10.10.11`的方式访问目标数据库节点。

```yaml
  pg-test:
    vars: { pg_cluster: pg-test }
    hosts:
      10.10.10.11: {pg_seq: 1, pg_role: primary, ansible_host: node-1}
      10.10.10.12: {pg_seq: 2, pg_role: replica, ansible_host: node-2}
      10.10.10.13: {pg_seq: 3, pg_role: offline, ansible_host: node-3}
```

通过这种方式，用户可以自由指定数据库节点的连接方式，并将连接配置保存在管理用户的`~/.ssh/config`中独立管理。



## 配置项清单



| ID  |                                   Name                                    |                     Section                     | Level |             Description              |
|-----|---------------------------------------------------------------------------|-------------------------------------------------|-------|--------------------------------------|
| 100 | [`proxy_env`](v-infra.md#proxy_env)                                       | [`CONNECT`](v-infra.md#CONNECT)                 | G     | 代理服务器配置                       |
| 110 | [`repo_enabled`](v-infra.md#repo_enabled)                                 | [`REPO`](v-infra.md#REPO)                       | G     | 是否启用本地源                       |
| 111 | [`repo_name`](v-infra.md#repo_name)                                       | [`REPO`](v-infra.md#REPO)                       | G     | 本地源名称                           |
| 112 | [`repo_address`](v-infra.md#repo_address)                                 | [`REPO`](v-infra.md#REPO)                       | G     | 本地源外部访问地址                   |
| 113 | [`repo_port`](v-infra.md#repo_port)                                       | [`REPO`](v-infra.md#REPO)                       | G     | 本地源端口                           |
| 114 | [`repo_home`](v-infra.md#repo_home)                                       | [`REPO`](v-infra.md#REPO)                       | G     | 本地源文件根目录                     |
| 115 | [`repo_rebuild`](v-infra.md#repo_rebuild)                                 | [`REPO`](v-infra.md#REPO)                       | A     | 是否重建Yum源                        |
| 116 | [`repo_remove`](v-infra.md#repo_remove)                                   | [`REPO`](v-infra.md#REPO)                       | A     | 是否移除已有REPO文件                 |
| 117 | [`repo_upstreams`](v-infra.md#repo_upstreams)                             | [`REPO`](v-infra.md#REPO)                       | G     | Yum源的上游来源                      |
| 118 | [`repo_packages`](v-infra.md#repo_packages)                               | [`REPO`](v-infra.md#REPO)                       | G     | Yum源需下载软件列表                  |
| 119 | [`repo_url_packages`](v-infra.md#repo_url_packages)                       | [`REPO`](v-infra.md#REPO)                       | G     | 通过URL直接下载的软件                |
| 120 | [`ca_method`](v-infra.md#ca_method)                                       | [`CA`](v-infra.md#CA)                           | G     | CA的创建方式                         |
| 121 | [`ca_subject`](v-infra.md#ca_subject)                                     | [`CA`](v-infra.md#CA)                           | G     | 自签名CA主题                         |
| 122 | [`ca_homedir`](v-infra.md#ca_homedir)                                     | [`CA`](v-infra.md#CA)                           | G     | CA证书根目录                         |
| 123 | [`ca_cert`](v-infra.md#ca_cert)                                           | [`CA`](v-infra.md#CA)                           | G     | CA证书                               |
| 124 | [`ca_key`](v-infra.md#ca_key)                                             | [`CA`](v-infra.md#CA)                           | G     | CA私钥名称                           |
| 130 | [`nginx_upstream`](v-infra.md#nginx_upstream)                             | [`NGINX`](v-infra.md#NGINX)                     | G     | Nginx上游服务器                      |
| 131 | [`app_list`](v-infra.md#app_list)                                         | [`NGINX`](v-infra.md#NGINX)                     | G     | 首页导航栏显示的应用列表             |
| 132 | [`docs_enabled`](v-infra.md#docs_enabled)                                 | [`NGINX`](v-infra.md#NGINX)                     | G     | 是否启用本地文档                     |
| 133 | [`pev2_enabled`](v-infra.md#pev2_enabled)                                 | [`NGINX`](v-infra.md#NGINX)                     | G     | 是否启用PEV2组件                     |
| 134 | [`pgbadger_enabled`](v-infra.md#pgbadger_enabled)                         | [`NGINX`](v-infra.md#NGINX)                     | G     | 是否启用Pgbadger                     |
| 140 | [`dns_records`](v-infra.md#dns_records)                                   | [`NAMESERVER`](v-infra.md#NAMESERVER)           | G     | 动态DNS解析记录                      |
| 150 | [`prometheus_data_dir`](v-infra.md#prometheus_data_dir)                   | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | G     | Prometheus数据库目录                 |
| 151 | [`prometheus_options`](v-infra.md#prometheus_options)                     | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | G     | Prometheus命令行参数                 |
| 152 | [`prometheus_reload`](v-infra.md#prometheus_reload)                       | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | A     | Reload而非Recreate                   |
| 153 | [`prometheus_sd_method`](v-infra.md#prometheus_sd_method)                 | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | G     | 服务发现机制：static|
| 154 | [`prometheus_scrape_interval`](v-infra.md#prometheus_scrape_interval)     | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | G     | Prom抓取周期                         |
| 155 | [`prometheus_scrape_timeout`](v-infra.md#prometheus_scrape_timeout)       | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | G     | Prom抓取超时                         |
| 156 | [`prometheus_sd_interval`](v-infra.md#prometheus_sd_interval)             | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | G     | Prom服务发现刷新周期                 |
| 160 | [`exporter_install`](v-infra.md#exporter_install)                         | [`EXPORTER`](v-infra.md#EXPORTER)               | G     | 安装监控组件的方式                   |
| 161 | [`exporter_repo_url`](v-infra.md#exporter_repo_url)                       | [`EXPORTER`](v-infra.md#EXPORTER)               | G     | 监控组件的YumRepo                    |
| 162 | [`exporter_metrics_path`](v-infra.md#exporter_metrics_path)               | [`EXPORTER`](v-infra.md#EXPORTER)               | G     | 监控暴露的URL Path                   |
| 170 | [`grafana_endpoint`](v-infra.md#grafana_endpoint)                         | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | Grafana地址                          |
| 171 | [`grafana_admin_username`](v-infra.md#grafana_admin_username)             | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | Grafana管理员用户名                  |
| 172 | [`grafana_admin_password`](v-infra.md#grafana_admin_password)             | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | Grafana管理员密码                    |
| 173 | [`grafana_database`](v-infra.md#grafana_database)                         | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | Grafana后端数据库类型                |
| 174 | [`grafana_pgurl`](v-infra.md#grafana_pgurl)                               | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | Grafana的PG数据库连接串              |
| 175 | [`grafana_plugin`](v-infra.md#grafana_plugin)                             | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | 如何安装Grafana插件                  |
| 176 | [`grafana_cache`](v-infra.md#grafana_cache)                               | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | Grafana插件缓存地址                  |
| 177 | [`grafana_plugins`](v-infra.md#grafana_plugins)                           | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | 安装的Grafana插件列表                |
| 178 | [`grafana_git_plugins`](v-infra.md#grafana_git_plugins)                   | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | 从Git安装的Grafana插件               |
| 180 | [`loki_endpoint`](v-infra.md#loki_endpoint)                               | [`LOKI`](v-infra.md#LOKI)                       | G     | 用于接收日志的loki服务endpoint       |
| 181 | [`loki_clean`](v-infra.md#loki_clean)                                     | [`LOKI`](v-infra.md#LOKI)                       | A     | 是否在安装Loki时清理数据库目录       |
| 182 | [`loki_options`](v-infra.md#loki_options)                                 | [`LOKI`](v-infra.md#LOKI)                       | G     | Loki的命令行参数                     |
| 183 | [`loki_data_dir`](v-infra.md#loki_data_dir)                               | [`LOKI`](v-infra.md#LOKI)                       | G     | Loki的数据目录                       |
| 184 | [`loki_retention`](v-infra.md#loki_retention)                             | [`LOKI`](v-infra.md#LOKI)                       | G     | Loki日志默认保留天数                 |
| 200 | [`dcs_servers`](v-infra.md#dcs_servers)                                   | [`DCS`](v-infra.md#DCS)                         | G     | DCS服务器名称:IP列表                 |
| 201 | [`service_registry`](v-infra.md#service_registry)                         | [`DCS`](v-infra.md#DCS)                         | G     | 服务注册的位置                       |
| 202 | [`dcs_type`](v-infra.md#dcs_type)                                         | [`DCS`](v-infra.md#DCS)                         | G     | 使用的DCS类型                        |
| 203 | [`dcs_name`](v-infra.md#dcs_name)                                         | [`DCS`](v-infra.md#DCS)                         | G     | DCS集群名称                          |
| 204 | [`dcs_exists_action`](v-infra.md#dcs_exists_action)                       | [`DCS`](v-infra.md#DCS)                         | C/A   | 若DCS实例存在如何处理                |
| 205 | [`dcs_disable_purge`](v-infra.md#dcs_disable_purge)                       | [`DCS`](v-infra.md#DCS)                         | C/A   | 完全禁止清理DCS实例                  |
| 206 | [`consul_data_dir`](v-infra.md#consul_data_dir)                           | [`DCS`](v-infra.md#DCS)                         | G     | Consul数据目录                       |
| 207 | [`etcd_data_dir`](v-infra.md#etcd_data_dir)                               | [`DCS`](v-infra.md#DCS)                         | G     | Etcd数据目录                         |
| 220 | [`jupyter_enabled`](v-infra.md#jupyter_enabled)                           | [`JUPYTER`](v-infra.md#JUPYTER)                 | G     | 是否启用JupyterLab                   |
| 221 | [`jupyter_username`](v-infra.md#jupyter_username)                         | [`JUPYTER`](v-infra.md#JUPYTER)                 | G     | Jupyter使用的操作系统用户            |
| 222 | [`jupyter_password`](v-infra.md#jupyter_password)                         | [`JUPYTER`](v-infra.md#JUPYTER)                 | G     | Jupyter Lab的密码                    |
| 230 | [`pgweb_enabled`](v-infra.md#pgweb_enabled)                               | [`PGWEB`](v-infra.md#PGWEB)                     | G     | 是否启用PgWeb                        |
| 231 | [`pgweb_username`](v-infra.md#pgweb_username)                             | [`PGWEB`](v-infra.md#PGWEB)                     | G     | PgWeb使用的操作系统用户              |
| 300 | [`meta_node`](v-nodes.md#meta_node)                                       | [`NODE_IDENTITY`](v-nodes.md#NODE_IDENTITY)     | C     | 表示此节点为元节点                   |
| 301 | [`nodename`](v-nodes.md#nodename)                                         | [`NODE_IDENTITY`](v-nodes.md#NODE_IDENTITY)     | I     | 指定节点实例标识                     |
| 302 | [`node_cluster`](v-nodes.md#node_cluster)                                 | [`NODE_IDENTITY`](v-nodes.md#NODE_IDENTITY)     | C     | 节点集群名，默认名为nodes            |
| 303 | [`nodename_overwrite`](v-nodes.md#nodename_overwrite)                     | [`NODE_IDENTITY`](v-nodes.md#NODE_IDENTITY)     | C     | 用Nodename覆盖机器HOSTNAME           |
| 304 | [`nodename_exchange`](v-nodes.md#nodename_exchange)                       | [`NODE_IDENTITY`](v-nodes.md#NODE_IDENTITY)     | C     | 是否在剧本节点间交换主机名           |
| 310 | [`node_dns_hosts`](v-nodes.md#node_dns_hosts)                             | [`NODE_DNS`](v-nodes.md#NODE_DNS)               | C     | 写入机器的静态DNS解析                |
| 311 | [`node_dns_hosts_extra`](v-nodes.md#node_dns_hosts_extra)                 | [`NODE_DNS`](v-nodes.md#NODE_DNS)               | C/I   | 同上，用于集群实例层级               |
| 312 | [`node_dns_server`](v-nodes.md#node_dns_server)                           | [`NODE_DNS`](v-nodes.md#NODE_DNS)               | C     | 如何配置DNS服务器？                  |
| 313 | [`node_dns_servers`](v-nodes.md#node_dns_servers)                         | [`NODE_DNS`](v-nodes.md#NODE_DNS)               | C     | 配置动态DNS服务器列表                |
| 314 | [`node_dns_options`](v-nodes.md#node_dns_options)                         | [`NODE_DNS`](v-nodes.md#NODE_DNS)               | C     | 配置/etc/resolv.conf                 |
| 320 | [`node_repo_method`](v-nodes.md#node_repo_method)                         | [`NODE_REPO`](v-nodes.md#NODE_REPO)             | C     | 节点使用Yum源的方式                  |
| 321 | [`node_repo_remove`](v-nodes.md#node_repo_remove)                         | [`NODE_REPO`](v-nodes.md#NODE_REPO)             | C     | 是否移除节点已有Yum源                |
| 322 | [`node_local_repo_url`](v-nodes.md#node_local_repo_url)                   | [`NODE_REPO`](v-nodes.md#NODE_REPO)             | C     | 本地源的URL地址                      |
| 330 | [`node_packages`](v-nodes.md#node_packages)                               | [`NODE_PACKAGES`](v-nodes.md#NODE_PACKAGES)     | C     | 节点安装软件列表                     |
| 331 | [`node_extra_packages`](v-nodes.md#node_extra_packages)                   | [`NODE_PACKAGES`](v-nodes.md#NODE_PACKAGES)     | C     | 节点额外安装的软件列表               |
| 332 | [`node_meta_packages`](v-nodes.md#node_meta_packages)                     | [`NODE_PACKAGES`](v-nodes.md#NODE_PACKAGES)     | G     | 元节点所需的软件列表                 |
| 333 | [`node_meta_pip_install`](v-nodes.md#node_meta_pip_install)               | [`NODE_PACKAGES`](v-nodes.md#NODE_PACKAGES)     | G     | 元节点上通过pip3安装的软件包         |
| 340 | [`node_disable_numa`](v-nodes.md#node_disable_numa)                       | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | C     | 关闭节点NUMA                         |
| 341 | [`node_disable_swap`](v-nodes.md#node_disable_swap)                       | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | C     | 关闭节点SWAP                         |
| 342 | [`node_disable_firewall`](v-nodes.md#node_disable_firewall)               | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | C     | 关闭节点防火墙                       |
| 343 | [`node_disable_selinux`](v-nodes.md#node_disable_selinux)                 | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | C     | 关闭节点SELINUX                      |
| 344 | [`node_static_network`](v-nodes.md#node_static_network)                   | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | C     | 是否使用静态DNS服务器                |
| 345 | [`node_disk_prefetch`](v-nodes.md#node_disk_prefetch)                     | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | C     | 是否启用磁盘预读                     |
| 346 | [`node_kernel_modules`](v-nodes.md#node_kernel_modules)                   | [`NODE_MODULES`](v-nodes.md#NODE_MODULES)       | C     | 启用的内核模块                       |
| 350 | [`node_tune`](v-nodes.md#node_tune)                                       | [`NODE_TUNE`](v-nodes.md#NODE_TUNE)             | C     | 节点调优模式                         |
| 351 | [`node_sysctl_params`](v-nodes.md#node_sysctl_params)                     | [`NODE_TUNE`](v-nodes.md#NODE_TUNE)             | C     | 操作系统内核参数                     |
| 360 | [`node_admin_setup`](v-nodes.md#node_admin_setup)                         | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | G     | 是否创建管理员用户                   |
| 361 | [`node_admin_uid`](v-nodes.md#node_admin_uid)                             | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | G     | 管理员用户UID                        |
| 362 | [`node_admin_username`](v-nodes.md#node_admin_username)                   | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | G     | 管理员用户名                         |
| 363 | [`node_admin_ssh_exchange`](v-nodes.md#node_admin_ssh_exchange)           | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | C     | 在实例间交换管理员SSH密钥            |
| 364 | [`node_admin_pk_current`](v-nodes.md#node_admin_pk_current)               | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | A     | 是否将当前用户的公钥加入管理员账户   |
| 365 | [`node_admin_pks`](v-nodes.md#node_admin_pks)                             | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | C     | 可登陆管理员的公钥列表               |
| 370 | [`node_timezone`](v-nodes.md#node_timezone)                               | [`NODE_TIME`](v-nodes.md#NODE_TIME)             | C     | NTP时区设置                          |
| 371 | [`node_ntp_config`](v-nodes.md#node_ntp_config)                           | [`NODE_TIME`](v-nodes.md#NODE_TIME)             | C     | 是否配置NTP服务？                    |
| 372 | [`node_ntp_service`](v-nodes.md#node_ntp_service)                         | [`NODE_TIME`](v-nodes.md#NODE_TIME)             | C     | NTP服务类型：ntp或chrony             |
| 373 | [`node_ntp_servers`](v-nodes.md#node_ntp_servers)                         | [`NODE_TIME`](v-nodes.md#NODE_TIME)             | C     | NTP服务器列表                        |
| 380 | [`node_exporter_enabled`](v-nodes.md#node_exporter_enabled)               | [`NODE_EXPORTER`](v-nodes.md#NODE_EXPORTER)     | C     | 启用节点指标收集器                   |
| 381 | [`node_exporter_port`](v-nodes.md#node_exporter_port)                     | [`NODE_EXPORTER`](v-nodes.md#NODE_EXPORTER)     | C     | 节点指标暴露端口                     |
| 382 | [`node_exporter_options`](v-nodes.md#node_exporter_options)               | [`NODE_EXPORTER`](v-nodes.md#NODE_EXPORTER)     | C/I   | 节点指标采集选项                     |
| 390 | [`promtail_enabled`](v-nodes.md#promtail_enabled)                         | [`PROMTAIL`](v-nodes.md#PROMTAIL)               | C     | 是否启用Promtail日志收集服务         |
| 391 | [`promtail_clean`](v-nodes.md#promtail_clean)                             | [`PROMTAIL`](v-nodes.md#PROMTAIL)               | C/A   | 是否在安装promtail时移除已有状态信息 |
| 392 | [`promtail_port`](v-nodes.md#promtail_port)                               | [`PROMTAIL`](v-nodes.md#PROMTAIL)               | G     | promtail使用的默认端口               |
| 393 | [`promtail_options`](v-nodes.md#promtail_options)                         | [`PROMTAIL`](v-nodes.md#PROMTAIL)               | C/I   | promtail命令行参数                   |
| 394 | [`promtail_positions`](v-nodes.md#promtail_positions)                     | [`PROMTAIL`](v-nodes.md#PROMTAIL)               | C     | promtail状态文件位置                 |
| 500 | [`pg_cluster`](v-pgsql.md#pg_cluster)                                     | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | C     | PG数据库集群名称                     |
| 501 | [`pg_shard`](v-pgsql.md#pg_shard)                                         | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | C     | PG集群所属的Shard (保留)             |
| 502 | [`pg_sindex`](v-pgsql.md#pg_sindex)                                       | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | C     | PG集群的分片号 (保留)                |
| 503 | [`gp_role`](v-pgsql.md#gp_role)                                           | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | C     | 当前PG集群在GP中的角色               |
| 504 | [`pg_role`](v-pgsql.md#pg_role)                                           | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | PG数据库实例角色                     |
| 505 | [`pg_seq`](v-pgsql.md#pg_seq)                                             | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | PG数据库实例序号                     |
| 506 | [`pg_instances`](v-pgsql.md#pg_instances)                                 | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | 当前节点上的所有PG实例               |
| 507 | [`pg_upstream`](v-pgsql.md#pg_upstream)                                   | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | 实例的复制上游节点                   |
| 508 | [`pg_offline_query`](v-pgsql.md#pg_offline_query)                         | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | 是否允许离线查询                     |
| 509 | [`pg_backup`](v-pgsql.md#pg_backup)                                       | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | 是否在实例上存储备份                 |
| 510 | [`pg_weight`](v-pgsql.md#pg_weight)                                       | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | 实例在负载均衡中的相对权重           |
| 511 | [`pg_hostname`](v-pgsql.md#pg_hostname)                                   | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | C/I   | 将PG实例名称设为HOSTNAME             |
| 512 | [`pg_preflight_skip`](v-pgsql.md#pg_preflight_skip)                       | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | C/A   | 跳过PG身份参数校验                   |
| 520 | [`pg_users`](v-pgsql.md#pg_users)                                         | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | C     | 业务用户定义                         |
| 521 | [`pg_databases`](v-pgsql.md#pg_databases)                                 | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | C     | 业务数据库定义                       |
| 522 | [`pg_services_extra`](v-pgsql.md#pg_services_extra)                       | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | C     | 集群专有服务定义                     |
| 523 | [`pg_hba_rules_extra`](v-pgsql.md#pg_hba_rules_extra)                     | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | C     | 集群/实例特定的HBA规则               |
| 524 | [`pgbouncer_hba_rules_extra`](v-pgsql.md#pgbouncer_hba_rules_extra)       | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | C     | Pgbounce特定HBA规则                  |
| 525 | [`pg_admin_username`](v-pgsql.md#pg_admin_username)                       | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | G     | PG管理用户                           |
| 526 | [`pg_admin_password`](v-pgsql.md#pg_admin_password)                       | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | G     | PG管理用户密码                       |
| 527 | [`pg_replication_username`](v-pgsql.md#pg_replication_username)           | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | G     | PG复制用户                           |
| 528 | [`pg_replication_password`](v-pgsql.md#pg_replication_password)           | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | G     | PG复制用户的密码                     |
| 529 | [`pg_monitor_username`](v-pgsql.md#pg_monitor_username)                   | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | G     | PG监控用户                           |
| 530 | [`pg_monitor_password`](v-pgsql.md#pg_monitor_password)                   | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | G     | PG监控用户密码                       |
| 540 | [`pg_dbsu`](v-pgsql.md#pg_dbsu)                                           | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | PG操作系统超级用户                   |
| 541 | [`pg_dbsu_uid`](v-pgsql.md#pg_dbsu_uid)                                   | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | 超级用户UID                          |
| 542 | [`pg_dbsu_sudo`](v-pgsql.md#pg_dbsu_sudo)                                 | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | 超级用户的Sudo权限                   |
| 543 | [`pg_dbsu_home`](v-pgsql.md#pg_dbsu_home)                                 | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | 超级用户的家目录                     |
| 544 | [`pg_dbsu_ssh_exchange`](v-pgsql.md#pg_dbsu_ssh_exchange)                 | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | 是否交换超级用户密钥                 |
| 545 | [`pg_version`](v-pgsql.md#pg_version)                                     | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | 安装的数据库大版本                   |
| 546 | [`pgdg_repo`](v-pgsql.md#pgdg_repo)                                       | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | 是否添加PG官方源？                   |
| 547 | [`pg_add_repo`](v-pgsql.md#pg_add_repo)                                   | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | 是否添加PG相关上游源？               |
| 548 | [`pg_bin_dir`](v-pgsql.md#pg_bin_dir)                                     | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | PG二进制目录                         |
| 549 | [`pg_packages`](v-pgsql.md#pg_packages)                                   | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | 安装的PG软件包列表                   |
| 550 | [`pg_extensions`](v-pgsql.md#pg_extensions)                               | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | 安装的PG插件列表                     |
| 560 | [`pg_exists_action`](v-pgsql.md#pg_exists_action)                         | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C/A   | PG存在时如何处理                     |
| 561 | [`pg_disable_purge`](v-pgsql.md#pg_disable_purge)                         | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C/A   | 禁止清除存在的PG实例                 |
| 562 | [`pg_data`](v-pgsql.md#pg_data)                                           | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG数据目录                           |
| 563 | [`pg_fs_main`](v-pgsql.md#pg_fs_main)                                     | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG主数据盘挂载点                     |
| 564 | [`pg_fs_bkup`](v-pgsql.md#pg_fs_bkup)                                     | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG备份盘挂载点                       |
| 565 | [`pg_dummy_filesize`](v-pgsql.md#pg_dummy_filesize)                       | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | 占位文件/pg/dummy的大小              |
| 566 | [`pg_listen`](v-pgsql.md#pg_listen)                                       | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG监听的IP地址                       |
| 567 | [`pg_port`](v-pgsql.md#pg_port)                                           | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG监听的端口                         |
| 568 | [`pg_localhost`](v-pgsql.md#pg_localhost)                                 | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG使用的UnixSocket地址               |
| 580 | [`patroni_enabled`](v-pgsql.md#patroni_enabled)                           | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Patroni是否启用                      |
| 581 | [`patroni_mode`](v-pgsql.md#patroni_mode)                                 | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Patroni配置模式                      |
| 582 | [`pg_namespace`](v-pgsql.md#pg_namespace)                                 | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Patroni使用的DCS命名空间             |
| 583 | [`patroni_port`](v-pgsql.md#patroni_port)                                 | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Patroni服务端口                      |
| 584 | [`patroni_watchdog_mode`](v-pgsql.md#patroni_watchdog_mode)               | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Patroni Watchdog模式                 |
| 585 | [`pg_conf`](v-pgsql.md#pg_conf)                                           | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Patroni使用的配置模板                |
| 586 | [`pg_shared_libraries`](v-pgsql.md#pg_shared_libraries)                   | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG默认加载的共享库                   |
| 587 | [`pg_encoding`](v-pgsql.md#pg_encoding)                                   | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG字符集编码                         |
| 588 | [`pg_locale`](v-pgsql.md#pg_locale)                                       | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG使用的本地化规则                   |
| 589 | [`pg_lc_collate`](v-pgsql.md#pg_lc_collate)                               | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG使用的本地化排序规则               |
| 590 | [`pg_lc_ctype`](v-pgsql.md#pg_lc_ctype)                                   | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG使用的本地化字符集定义             |
| 591 | [`pgbouncer_enabled`](v-pgsql.md#pgbouncer_enabled)                       | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | 是否启用Pgbouncer                    |
| 592 | [`pgbouncer_port`](v-pgsql.md#pgbouncer_port)                             | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Pgbouncer端口                        |
| 593 | [`pgbouncer_poolmode`](v-pgsql.md#pgbouncer_poolmode)                     | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Pgbouncer池化模式                    |
| 594 | [`pgbouncer_max_db_conn`](v-pgsql.md#pgbouncer_max_db_conn)               | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Pgbouncer最大单DB连接数              |
| 600 | [`pg_provision`](v-pgsql.md#pg_provision)                                 | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | C     | 是否在PG集群中应用模板               |
| 601 | [`pg_init`](v-pgsql.md#pg_init)                                           | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | C     | 自定义PG初始化脚本                   |
| 602 | [`pg_default_roles`](v-pgsql.md#pg_default_roles)                         | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | G/C   | 默认创建的角色与用户                 |
| 603 | [`pg_default_privilegs`](v-pgsql.md#pg_default_privilegs)                 | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | G/C   | 数据库默认权限配置                   |
| 604 | [`pg_default_schemas`](v-pgsql.md#pg_default_schemas)                     | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | G/C   | 默认创建的模式                       |
| 605 | [`pg_default_extensions`](v-pgsql.md#pg_default_extensions)               | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | G/C   | 默认安装的扩展                       |
| 606 | [`pg_reload`](v-pgsql.md#pg_reload)                                       | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | A     | 是否重载数据库配置（HBA）            |
| 607 | [`pg_hba_rules`](v-pgsql.md#pg_hba_rules)                                 | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | G/C   | 全局HBA规则                          |
| 608 | [`pgbouncer_hba_rules`](v-pgsql.md#pgbouncer_hba_rules)                   | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | G/C   | Pgbouncer全局HBA规则                 |
| 620 | [`pg_exporter_config`](v-pgsql.md#pg_exporter_config)                     | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C     | PG指标定义文件                       |
| 621 | [`pg_exporter_enabled`](v-pgsql.md#pg_exporter_enabled)                   | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C     | 启用PG指标收集器                     |
| 622 | [`pg_exporter_port`](v-pgsql.md#pg_exporter_port)                         | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C     | PG指标暴露端口                       |
| 623 | [`pg_exporter_params`](v-pgsql.md#pg_exporter_params)                     | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | PG Exporter额外的URL参数             |
| 624 | [`pg_exporter_url`](v-pgsql.md#pg_exporter_url)                           | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | 采集对象数据库的连接串（覆盖）       |
| 625 | [`pg_exporter_auto_discovery`](v-pgsql.md#pg_exporter_auto_discovery)     | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | 是否自动发现实例中的数据库           |
| 626 | [`pg_exporter_exclude_database`](v-pgsql.md#pg_exporter_exclude_database) | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | 数据库自动发现排除列表               |
| 627 | [`pg_exporter_include_database`](v-pgsql.md#pg_exporter_include_database) | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | 数据库自动发现囊括列表               |
| 628 | [`pg_exporter_options`](v-pgsql.md#pg_exporter_options)                   | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | PG Exporter命令行参数                |
| 629 | [`pgbouncer_exporter_enabled`](v-pgsql.md#pgbouncer_exporter_enabled)     | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C     | 启用PGB指标收集器                    |
| 630 | [`pgbouncer_exporter_port`](v-pgsql.md#pgbouncer_exporter_port)           | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C     | PGB指标暴露端口                      |
| 631 | [`pgbouncer_exporter_url`](v-pgsql.md#pgbouncer_exporter_url)             | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | 采集对象连接池的连接串               |
| 632 | [`pgbouncer_exporter_options`](v-pgsql.md#pgbouncer_exporter_options)     | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | PGB Exporter命令行参数               |
| 640 | [`pg_services`](v-pgsql.md#pg_services)                                   | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | G/C   | 全局通用服务定义                     |
| 641 | [`haproxy_enabled`](v-pgsql.md#haproxy_enabled)                           | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C/I   | 是否启用Haproxy                      |
| 642 | [`haproxy_reload`](v-pgsql.md#haproxy_reload)                             | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | A     | 是否重载Haproxy配置                  |
| 643 | [`haproxy_admin_auth_enabled`](v-pgsql.md#haproxy_admin_auth_enabled)     | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | G/C   | 是否对Haproxy管理界面启用认证        |
| 644 | [`haproxy_admin_username`](v-pgsql.md#haproxy_admin_username)             | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | G     | HAproxy管理员名称                    |
| 645 | [`haproxy_admin_password`](v-pgsql.md#haproxy_admin_password)             | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | G     | HAproxy管理员密码                    |
| 646 | [`haproxy_exporter_port`](v-pgsql.md#haproxy_exporter_port)               | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | HAproxy指标暴露器端口                |
| 647 | [`haproxy_client_timeout`](v-pgsql.md#haproxy_client_timeout)             | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | HAproxy客户端超时                    |
| 648 | [`haproxy_server_timeout`](v-pgsql.md#haproxy_server_timeout)             | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | HAproxy服务端超时                    |
| 649 | [`vip_mode`](v-pgsql.md#vip_mode)                                         | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | VIP模式：none                        |
| 650 | [`vip_reload`](v-pgsql.md#vip_reload)                                     | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | A     | 是否重载VIP配置                      |
| 651 | [`vip_address`](v-pgsql.md#vip_address)                                   | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | 集群使用的VIP地址                    |
| 652 | [`vip_cidrmask`](v-pgsql.md#vip_cidrmask)                                 | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | VIP地址的网络CIDR掩码长度            |
| 653 | [`vip_interface`](v-pgsql.md#vip_interface)                               | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | VIP使用的网卡                        |
| 654 | [`dns_mode`](v-pgsql.md#dns_mode)                                         | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | DNS配置模式                          |
| 655 | [`dns_selector`](v-pgsql.md#dns_selector)                                 | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | DNS解析对象选择器                    |
| 700 | [`redis_cluster`](v-redis.md#redis_cluster)                               | [`REDIS_IDENTITY`](v-redis.md#REDIS_IDENTITY)   | C     | Redis数据库集群名称                  |
| 701 | [`redis_node`](v-redis.md#redis_node)                                     | [`REDIS_IDENTITY`](v-redis.md#REDIS_IDENTITY)   | I     | Redis节点序列号                      |
| 702 | [`redis_instances`](v-redis.md#redis_instances)                           | [`REDIS_IDENTITY`](v-redis.md#REDIS_IDENTITY)   | I     | Redis实例定义                        |
| 720 | [`redis_install`](v-redis.md#redis_install)                               | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | 安装Redis的方式                      |
| 721 | [`redis_mode`](v-redis.md#redis_mode)                                     | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | Redis集群模式                        |
| 722 | [`redis_conf`](v-redis.md#redis_conf)                                     | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | Redis配置文件模板                    |
| 723 | [`redis_fs_main`](v-redis.md#redis_fs_main)                               | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | PG数据库实例角色                     |
| 724 | [`redis_bind_address`](v-redis.md#redis_bind_address)                     | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | Redis监听的端口地址                  |
| 725 | [`redis_exists_action`](v-redis.md#redis_exists_action)                   | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | Redis存在时执行何种操作              |
| 726 | [`redis_disable_purge`](v-redis.md#redis_disable_purge)                   | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | 禁止抹除现存的Redis                  |
| 727 | [`redis_max_memory`](v-redis.md#redis_max_memory)                         | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C/I   | Redis可用的最大内存                  |
| 728 | [`redis_mem_policy`](v-redis.md#redis_mem_policy)                         | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | 内存逐出策略                         |
| 729 | [`redis_password`](v-redis.md#redis_password)                             | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | Redis密码                            |
| 730 | [`redis_rdb_save`](v-redis.md#redis_rdb_save)                             | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | RDB保存指令                          |
| 731 | [`redis_aof_enabled`](v-redis.md#redis_aof_enabled)                       | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | 是否启用AOF                          |
| 732 | [`redis_rename_commands`](v-redis.md#redis_rename_commands)               | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | 重命名危险命令列表                   |
| 740 | [`redis_cluster_replicas`](v-redis.md#redis_cluster_replicas)             | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | 集群每个主库带几个从库               |
| 741 | [`redis_exporter_enabled`](v-redis.md#redis_exporter_enabled)             | [`REDIS_EXPORTER`](v-redis.md#REDIS_EXPORTER)   | C     | 是否启用Redis监控                    |
| 742 | [`redis_exporter_port`](v-redis.md#redis_exporter_port)                   | [`REDIS_EXPORTER`](v-redis.md#REDIS_EXPORTER)   | C     | Redis Exporter监听端口               |
| 743 | [`redis_exporter_options`](v-redis.md#redis_exporter_options)             | [`REDIS_EXPORTER`](v-redis.md#REDIS_EXPORTER)   | C/I   | Redis Exporter命令参数               |
