# Pigsty配置

每一套Pigsty部署都有一份对应的**配置**：无论是几百集群的生产环境，还是1核1GB的本地沙箱，在Pigsty中除了配置内容外没有任何区别。

Pigsty 通过**配置清单**（Inventory）来定义基础设施与数据库集群。在形式上，配置清单的具体实现可以是默认的本地[配置文件](#配置文件)，也可以是来自[CMDB](t-cmdb.md)中的动态配置数据（可选）。本文介绍时均以默认YAML配置文件为例。典型配置文件的样例：[`pigsty.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml)

配置清单的内容主要是[配置项](#配置项)，Pigsty提供了176个配置参数，可以在多个[层次](#配置项的层次)进行配置。大多数参数可以直接使用默认值，其余按需定制即可。配置项按照类目可分为两大类：[基础设施配置](#基础设施配置) 与 [数据库集群](#数据库集群配置)，并进一步细分为十个小类：

|  No  |            类目             |               英文                |   大类   | 数量 | 功能                                   |
| :--: | :-------------------------: | :-------------------------------: | :------: | :--: | -------------------------------------- |
|  1   |  [连接参数](v-connect.md)   |      [connect](v-connect.md)      | 基础设施 |  1   | 代理服务器配置，管理对象的连接信息     |
|  2   |    [本地仓库](v-repo.md)    |         [repo](v-repo.md)         | 基础设施 |  10  | 定制本地Yum源，离线安装包              |
|  3   |    [节点供给](v-node.md)    |         [node](v-node.md)         | 基础设施 |  31  | 在普通节点上配置基础设施               |
|  4   |    [基础设施](v-meta.md)    |         [meta](v-meta.md)         | 基础设施 |  26  | 在元节点上安装启用基础设施服务         |
|  5   |    [元数据库](v-dcs.md)     |          [dcs](v-dcs.md)          | 基础设施 |  8   | 在所有节点上配置DCS服务（consul/etcd） |
|  6   |  [PG安装](v-pg-install.md)  |   [pg-install](v-pg-install.md)   |  数据库  |  11  | 安装PostgreSQL数据库                   |
|  7   | [PG供给](v-pg-provision.md) | [pg-provision](v-pg-provision.md) |  数据库  |  32  | 拉起PostgreSQL数据库集群               |
|  8   | [PG模板](v-pg-template.md)  |  [pg-template](v-pg-template.md)  |  数据库  |  19  | 定制PostgreSQL数据库内容               |
|  9   |  [监控系统](v-monitor.md)   |      [monitor](v-monitor.md)      |  数据库  |  21  | 安装Pigsty数据库监控系统               |
|  10  |  [服务供给](v-service.md)   |      [service](v-service.md)      |  数据库  |  17  | 通过Haproxy或VIP对外暴露数据库服务     |

具体可用的配置项，请参考[配置项清单](v-config.md#配置项清单)

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

通常来说，基础设施部分需要修改的内容很少，通常涉及到的主要修改只是对管理节点的IP地址进行文本替换，这一步会在`./configure`过程中自动完成，另一处有时需要改动的地方是 [`nginx_upstream`](v-meta.md#nginx_upstream)中定义的访问域名。

其他参数很少需要调整，按需即可。例如，如果您的虚拟机提供商已经为您配置了DNS服务器与NTP服务器，那么您可以将 [`node_dns_server`](v-node.md#node_dns_server) 与 [`node_ntp_config`](v-node.md#node_dns_server)设置为 `none`与`false`，跳过DNS与NTP的设置。

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

### [安装数据库软件](v-pg-install.md)

> 安装什么版本，安装哪些插件，使用什么用户
>
> 通常这一部分的参数不需要修改任何内容即可直接使用，当PG版本升级时需要进行调整。

### [置备数据库集群](v-pg-provision.md)

> 在哪创建目录，创建什么用途的集群，监听哪些IP端口，采用何种连接池模式。
>
> 在这一部分中，[**身份信息**](#身份参数) 是必选参数，除此之外需要修改默认参数的地方很少。

通过 [`pg_conf`](v-pg-provision.md#pg_conf) 可以使用默认的数据库集群模板（普通事务型 OLTP/普通分析型 OLAP/核心金融型 CRIT/微型虚机 TINY）。如果希望创建自定义的模板，可以在`roles/postgres/templates`中克隆默认配置并自行修改后采用，详见**Patroni模板定制**。

### [定制数据库模板](v-pg-template.md)

> 创建哪些角色、用户、数据库、模式，启用哪些扩展，如何设置权限与白名单

需**重点关注**，因为这里是业务声明自己所需数据库的地方。用户可以通过数据库模板定制：

- [业务用户](c-user)：（使用哪些用户访问数据库？属性，限制，角色，权限……）
- [业务数据库](c-database)：（需要什么样的数据库？扩展，模式，参数，权限……）
- [默认模板数据库](v-pg-template) (template1) （模式、扩展、默认权限）
- [访问控制系统](c-auth)（角色，用户，HBA）
- [暴露的服务](c-service) （使用哪些端口，将流量导向哪些实例，健康检测，权重……）

### [拉起数据库监控](v-monitor.md)

> 部署Pigsty监控系统组件

通常情况下不需要调整，但在 [仅监控部署](t-monly.md) 模式下需要重点关注，进行调整。

### [暴露数据库服务](v-service.md)

> 通过HAproxy/VIP对外提供数据库服务

除非用户希望更改默认[服务](c-service)与[接入方式](c-access)，否则不需要调整这里的配置。













## 身份参数

**身份参数**是定义数据库集群时必须提供的信息，包括：

|                    名称                     |        属性        |   说明   |         例子         |
| :-----------------------------------------: | :----------------: | :------: | :------------------: |
| [`pg_cluster`](v-pg-provision.md#pg_cluster) | **必选**，集群级别 |  集群名  |      `pg-test`       |
|    [`pg_role`](v-pg-provision.md#pg_role)    | **必选**，实例级别 | 实例角色 | `primary`, `replica` |
|     [`pg_seq`](v-pg-provision.md#pg_seq)     | **必选**，实例级别 | 实例序号 | `1`, `2`, `3`,`...`  |

身份参数的内容遵循 [实体命名规则](c-entity.md) 。其中 [`pg_cluster`](v-pg-template.md#pg_cluster) ，[`pg_role`](v-pg-template.md#pg_role)，[`pg_seq`](v-pg-template.md#pg_seq) 属于核心身份参数，是定义数据库集群所需的**最小必须参数集**，核心身份参数**必须显式指定**，不可忽略。

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

如果您的目标机器藏在SSH跳板机之后，或者无法通过`ssh ip`的方式直接方案，则可以考虑使用[Ansible连接参数](v-connect.md)。

例如下面的例子中，[`ansible_host`](v-connect.md#ansible_host) 通过SSH别名的方式告知Pigsty通过`ssh node-1` 的方式而不是`ssh 10.10.10.11`的方式访问目标数据库节点。

```yaml
  pg-test:
    vars: { pg_cluster: pg-test }
    hosts:
      10.10.10.11: {pg_seq: 1, pg_role: primary, ansible_host: node-1}
      10.10.10.12: {pg_seq: 2, pg_role: replica, ansible_host: node-2}
      10.10.10.13: {pg_seq: 3, pg_role: offline, ansible_host: node-3}
```

通过这种方式，用户可以自由指定数据库节点的连接方式，并将连接配置保存在管理用户的`~/.ssh/config`中独立管理。

