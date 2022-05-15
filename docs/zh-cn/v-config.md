# 配置Pigsty

> Pigsty采用声明式[配置](v-config.md)：用户配置描述状态，而Pigsty负责将真实组件调整至所期待的状态。

Pigsty通过**配置清单**（Inventory）来定义基础设施与数据库集群，每一套Pigsty[部署](d-deploy.md)都有一份对应的**配置**：无论是几百集群的生产环境，还是1核1GB的本地沙箱，在Pigsty中除了配置内容外没有任何区别。Pigsty的配置采用"Infra as Data"的哲学：用户通过声明式的配置描述自己的需求，而Pigsty负责将真实组件调整至所期待的状态。

在形式上，配置清单的具体实现可以是默认的本地[配置文件](#配置文件)，也可以是来自[CMDB](t-cmdb.md)中的动态配置数据，本文介绍时均以默认YAML配置文件[`pigsty.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml) 为例。在 [配置过程](#配置过程) 中，Pigsty会检测当前节点环境，并自动生成推荐的配置文件。

**配置清单**的内容主要是[配置项](#配置项)，Pigsty提供了220个配置参数，可以在多个[层次](#配置项的层次)进行配置，大多数参数可以直接使用默认值。配置项按照[类目](#配置类目)可以分为四大类：[INFRA/基础设施](v-infra.md)， [NODES/主机节点](v-nodes.md)， [PGSQL/PG数据库](v-pgsql.md)， [REDIS/Redis数据库](v-redis.md)，并可进一步细分为32个小类。




--------------

## 配置过程

进入 Pigsty 项目目录执行 `configure`，Pigsty会检测根据当前机器环境生成推荐**配置文件**，这一过程称作 **配置** / **Configure**。

```bash
./configure [-n|--non-interactive] [-d|--download] [-i|--ip <ipaddr>] [-m|--mode {auto|demo}]
```

`configure`会检查下列事项，小问题会自动尝试修复，否则提示报错退出。

```bash
check_kernel     # kernel        = Linux
check_machine    # machine       = x86_64
check_release    # release       = CentOS 7.x
check_sudo       # current_user  = NOPASSWD sudo
check_ssh        # current_user  = NOPASSWD ssh
check_ipaddr     # primary_ip (arg|probe|input)              (INTERACTIVE: ask for ip)
check_admin      # check current_user@primary_ip nopass ssh sudo
check_mode       # check machine spec to determine node mode (tiny|oltp|olap|crit)
check_config     # generate config according to primary_ip and mode
check_pkg        # check offline installation package exists (INTERACTIVE: ask for download)
check_repo       # create repo from pkg.tgz if exists
check_repo_file  # create local file repo file if repo exists
check_utils      # check ansible sshpass and other utils installed
```

直接运行 `./configure` 将启动交互式命令行向导，提示用户回答以下三个问题：

**IP地址**

当检测到当前机器上有多块网卡与多个IP地址时，配置向导会提示您输入**主要**使用的IP地址， 即您用于从内部网络访问该节点时使用的IP地址。注意请不要使用公网IP地址。

**下载软件包**

当节点的`/tmp/pkg.tgz`路径下未找到离线软件包时，配置向导会询问是否从Github下载。 选择`Y`即会开始下载，选择`N`则会跳过。如果您的节点有良好的互联网访问与合适的代理配置，或者需要自行制作离线软件包，可以选择`N`。

**配置模板**

使用什么样的配置文件模板。 配置向导会根据当前机器环境**自动选择配置模板**，因此不会询问用户这个问题，用户通常也无需关心。 但用户总是可以通过命令行参数`-m <mode>`手工指定想要使用的配置模板，例如：

- [`demo`](https://github.com/Vonng/pigsty/blob/master/files/conf/pigsty-demo.yml) 项目默认配置文件，4节点沙箱使用的配置文件，启用全部功能。
- [`auto`](https://github.com/Vonng/pigsty/blob/master/files/conf/pigsty-auto.yml) 在生产环境中部署时推荐的配置文件模板，配置更加稳定保守。
- 此外Pigsty预置了几种配置模板，可以直接通过`-m`参数指定并使用，详见[`files/conf`](https://github.com/Vonng/pigsty/tree/master/files/conf)目录

在[`configure`](#配置过程)过程中，配置向导会根据当前机器环境**自动选择配置模板**，但用户可以通过`-m <mode>`手工指定使用配置模板。配置模板最重要的部分是将模板中占位IP地址`10.10.10.10`替换为当前机器的真实IP地址（内网主IP），并根据当前机器的配置选择合适的数据库规格模板。您可以直接使用默认生成的配置文件，或基于自动生成的配置文件进行进一步的定制与修改。

<details><summary>配置过程的标准输出</summary>

```bash
$ ./configure
configure pigsty v1.5.0-beta begin
[ OK ] kernel = Linux
[ OK ] machine = x86_64
[ OK ] release = 7.8.2003 , perfect
[ OK ] sudo = root ok
[ OK ] ssh = root@127.0.0.1 ok
[ OK ] primary_ip = 10.10.10.10  (from probe)
[ OK ] admin = root@10.10.10.10 ok
[ OK ] spec = mini (cpu = 2)
[ OK ] config = auto @ 10.10.10.10
[ OK ] cache = /tmp/pkg.tgz exists
[ OK ] repo = /www/pigsty ok
[ OK ] repo file = /etc/yum.repos.d/pigsty-local.repo
[ OK ] utils = install from local file repo
[ OK ] ansible = ansible 2.9.27
configure pigsty done. Use 'make install' to proceed
```

</details>





## 配置文件

Pigsty项目根目录下有一个具体的配置文件样例：[`pigsty.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml)

配置文件顶层是一个`key`为`all`的单个对象，包含两个子项目：`vars`与`children`。

```yaml
all:                      # 顶层对象 all
  vars: <123 keys>        # 全局配置 all.vars

  children:               # 分组定义：all.children 每一个项目定义了一个数据库集群 
    meta: <2 keys>...     # 特殊分组 meta ，定义了环境元节点
    
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

您并不需要精通Ansible，用几分钟时间浏览[Ansible快速上手](p-playbook.md#Ansible快速上手)，便足以开始使用Ansible执行剧本。





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

--------------


## 配置类目

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



<details><summary>配置项清单</summary>

| ID   | Name                                                         | Section                                         | Level | Description                          |
| ---- | ------------------------------------------------------------ | ----------------------------------------------- | ----- | ------------------------------------ |
| 100  | [`proxy_env`](v-infra.md#proxy_env)                          | [`CONNECT`](v-infra.md#CONNECT)                 | G     | 代理服务器配置                       |
| 110  | [`nginx_enabled`](v-infra.md#nginx_enabled)                    | [`REPO`](v-infra.md#REPO)                       | G     | 是否启用本地源                       |
| 111  | [`repo_name`](v-infra.md#repo_name)                          | [`REPO`](v-infra.md#REPO)                       | G     | 本地源名称                           |
| 112  | [`repo_address`](v-infra.md#repo_address)                    | [`REPO`](v-infra.md#REPO)                       | G     | 本地源外部访问地址                   |
| 113  | [`nginx_port`](v-infra.md#nginx_port)                          | [`REPO`](v-infra.md#REPO)                       | G     | 本地源端口                           |
| 114  | [`nginx_home`](v-infra.md#nginx_home)                          | [`REPO`](v-infra.md#REPO)                       | G     | 本地源文件根目录                     |
| 115  | [`repo_rebuild`](v-infra.md#repo_rebuild)                    | [`REPO`](v-infra.md#REPO)                       | A     | 是否重建Yum源                        |
| 116  | [`repo_remove`](v-infra.md#repo_remove)                      | [`REPO`](v-infra.md#REPO)                       | A     | 是否移除已有REPO文件                 |
| 117  | [`repo_upstreams`](v-infra.md#repo_upstreams)                | [`REPO`](v-infra.md#REPO)                       | G     | Yum源的上游来源                      |
| 118  | [`repo_packages`](v-infra.md#repo_packages)                  | [`REPO`](v-infra.md#REPO)                       | G     | Yum源需下载软件列表                  |
| 119  | [`repo_url_packages`](v-infra.md#repo_url_packages)          | [`REPO`](v-infra.md#REPO)                       | G     | 通过URL直接下载的软件                |
| 120  | [`ca_method`](v-infra.md#ca_method)                          | [`CA`](v-infra.md#CA)                           | G     | CA的创建方式                         |
| 121  | [`ca_subject`](v-infra.md#ca_subject)                        | [`CA`](v-infra.md#CA)                           | G     | 自签名CA主题                         |
| 122  | [`ca_homedir`](v-infra.md#ca_homedir)                        | [`CA`](v-infra.md#CA)                           | G     | CA证书根目录                         |
| 123  | [`ca_cert`](v-infra.md#ca_cert)                              | [`CA`](v-infra.md#CA)                           | G     | CA证书                               |
| 124  | [`ca_key`](v-infra.md#ca_key)                                | [`CA`](v-infra.md#CA)                           | G     | CA私钥名称                           |
| 130  | [`nginx_upstream`](v-infra.md#nginx_upstream)                | [`NGINX`](v-infra.md#NGINX)                     | G     | Nginx上游服务器                      |
| 131  | [`nginx_indexes`](v-infra.md#nginx_indexes)                            | [`NGINX`](v-infra.md#NGINX)                     | G     | 首页导航栏显示的应用列表             |
| 132  | [`docs_enabled`](v-infra.md#docs_enabled)                    | [`NGINX`](v-infra.md#NGINX)                     | G     | 是否启用本地文档                     |
| 133  | [`pev2_enabled`](v-infra.md#pev2_enabled)                    | [`NGINX`](v-infra.md#NGINX)                     | G     | 是否启用PEV2组件                     |
| 134  | [`pgbadger_enabled`](v-infra.md#pgbadger_enabled)            | [`NGINX`](v-infra.md#NGINX)                     | G     | 是否启用Pgbadger                     |
| 140  | [`dns_records`](v-infra.md#dns_records)                      | [`NAMESERVER`](v-infra.md#NAMESERVER)           | G     | 动态DNS解析记录                      |
| 150  | [`prometheus_data_dir`](v-infra.md#prometheus_data_dir)      | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | G     | Prometheus数据库目录                 |
| 151  | [`prometheus_options`](v-infra.md#prometheus_options)        | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | G     | Prometheus命令行参数                 |
| 152  | [`prometheus_reload`](v-infra.md#prometheus_reload)          | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | A     | Reload而非Recreate                   |
| 153  | [`prometheus_sd_method`](v-infra.md#prometheus_sd_method)    | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | G     | 服务发现机制：static                 |
| 154  | [`prometheus_scrape_interval`](v-infra.md#prometheus_scrape_interval) | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | G     | Prom抓取周期                         |
| 155  | [`prometheus_scrape_timeout`](v-infra.md#prometheus_scrape_timeout) | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | G     | Prom抓取超时                         |
| 156  | [`prometheus_sd_interval`](v-infra.md#prometheus_sd_interval) | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | G     | Prom服务发现刷新周期                 |
| 160  | [`exporter_install`](v-infra.md#exporter_install)            | [`EXPORTER`](v-infra.md#EXPORTER)               | G     | 安装监控组件的方式                   |
| 161  | [`exporter_repo_url`](v-infra.md#exporter_repo_url)          | [`EXPORTER`](v-infra.md#EXPORTER)               | G     | 监控组件的YumRepo                    |
| 162  | [`exporter_metrics_path`](v-infra.md#exporter_metrics_path)  | [`EXPORTER`](v-infra.md#EXPORTER)               | G     | 监控暴露的URL Path                   |
| 170  | [`grafana_endpoint`](v-infra.md#grafana_endpoint)            | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | Grafana地址                          |
| 171  | [`grafana_admin_username`](v-infra.md#grafana_admin_username) | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | Grafana管理员用户名                  |
| 172  | [`grafana_admin_password`](v-infra.md#grafana_admin_password) | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | Grafana管理员密码                    |
| 173  | [`grafana_database`](v-infra.md#grafana_database)            | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | Grafana后端数据库类型                |
| 174  | [`grafana_pgurl`](v-infra.md#grafana_pgurl)                  | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | Grafana的PG数据库连接串              |
| 175  | [`grafana_plugin_method`](v-infra.md#grafana_plugin_method)                | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | 如何安装Grafana插件                  |
| 176  | [`grafana_plugin_cache`](v-infra.md#grafana_plugin_cache)                  | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | Grafana插件缓存地址                  |
| 177  | [`grafana_plugin_list`](v-infra.md#grafana_plugin_list)              | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | 安装的Grafana插件列表                |
| 178  | [`grafana_plugin_git`](v-infra.md#grafana_plugin_git)      | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | 从Git安装的Grafana插件               |
| 180  | [`loki_endpoint`](v-infra.md#loki_endpoint)                  | [`LOKI`](v-infra.md#LOKI)                       | G     | 用于接收日志的loki服务endpoint       |
| 181  | [`loki_clean`](v-infra.md#loki_clean)                        | [`LOKI`](v-infra.md#LOKI)                       | A     | 是否在安装Loki时清理数据库目录       |
| 182  | [`loki_options`](v-infra.md#loki_options)                    | [`LOKI`](v-infra.md#LOKI)                       | G     | Loki的命令行参数                     |
| 183  | [`loki_data_dir`](v-infra.md#loki_data_dir)                  | [`LOKI`](v-infra.md#LOKI)                       | G     | Loki的数据目录                       |
| 184  | [`loki_retention`](v-infra.md#loki_retention)                | [`LOKI`](v-infra.md#LOKI)                       | G     | Loki日志默认保留天数                 |
| 200  | [`dcs_servers`](v-infra.md#dcs_servers)                      | [`DCS`](v-infra.md#DCS)                         | G     | DCS服务器名称:IP列表                 |
| 201  | [`dcs_registry`](v-infra.md#dcs_registry)            | [`DCS`](v-infra.md#DCS)                         | G     | 服务注册的位置                       |
| 202  | [`pg_dcs_type`](v-infra.md#pg_dcs_type)                            | [`DCS`](v-infra.md#DCS)                         | G     | 使用的DCS类型                        |
| 203  | [`dcs_name`](v-infra.md#dcs_name)                            | [`DCS`](v-infra.md#DCS)                         | G     | DCS集群名称                          |
| 204  | [`dcs_clean`](v-infra.md#dcs_clean)          | [`DCS`](v-infra.md#DCS)                         | C/A   | 若DCS实例存在如何处理                |
| 205  | [`dcs_safeguard`](v-infra.md#dcs_safeguard)          | [`DCS`](v-infra.md#DCS)                         | C/A   | 完全禁止清理DCS实例                  |
| 206  | [`consul_data_dir`](v-infra.md#consul_data_dir)              | [`DCS`](v-infra.md#DCS)                         | G     | Consul数据目录                       |
| 207  | [`etcd_data_dir`](v-infra.md#etcd_data_dir)                  | [`DCS`](v-infra.md#DCS)                         | G     | Etcd数据目录                         |
| 300  | [`meta_node`](v-nodes.md#meta_node)                          | [`NODE_IDENTITY`](v-nodes.md#NODE_IDENTITY)     | C     | 表示此节点为元节点                   |
| 301  | [`nodename`](v-nodes.md#nodename)                            | [`NODE_IDENTITY`](v-nodes.md#NODE_IDENTITY)     | I     | 指定节点实例标识                     |
| 302  | [`node_cluster`](v-nodes.md#node_cluster)                    | [`NODE_IDENTITY`](v-nodes.md#NODE_IDENTITY)     | C     | 节点集群名，默认名为nodes            |
| 303  | [`nodename_overwrite`](v-nodes.md#nodename_overwrite)        | [`NODE_IDENTITY`](v-nodes.md#NODE_IDENTITY)     | C     | 用Nodename覆盖机器HOSTNAME           |
| 304  | [`nodename_exchange`](v-nodes.md#nodename_exchange)          | [`NODE_IDENTITY`](v-nodes.md#NODE_IDENTITY)     | C     | 是否在剧本节点间交换主机名           |
| 310  | [`node_etc_hosts_default`](v-nodes.md#node_etc_hosts_default)                | [`NODE_DNS`](v-nodes.md#NODE_DNS)               | C     | 写入机器的静态DNS解析                |
| 311  | [`node_etc_hosts`](v-nodes.md#node_etc_hosts)    | [`NODE_DNS`](v-nodes.md#NODE_DNS)               | C/I   | 同上，用于集群实例层级               |
| 312  | [`node_dns_method`](v-nodes.md#node_dns_method)              | [`NODE_DNS`](v-nodes.md#NODE_DNS)               | C     | 如何配置DNS服务器？                  |
| 313  | [`node_dns_servers`](v-nodes.md#node_dns_servers)            | [`NODE_DNS`](v-nodes.md#NODE_DNS)               | C     | 配置动态DNS服务器列表                |
| 314  | [`node_dns_options`](v-nodes.md#node_dns_options)            | [`NODE_DNS`](v-nodes.md#NODE_DNS)               | C     | 配置/etc/resolv.conf                 |
| 320  | [`node_repo_method`](v-nodes.md#node_repo_method)            | [`NODE_REPO`](v-nodes.md#NODE_REPO)             | C     | 节点使用Yum源的方式                  |
| 321  | [`node_repo_remove`](v-nodes.md#node_repo_remove)            | [`NODE_REPO`](v-nodes.md#NODE_REPO)             | C     | 是否移除节点已有Yum源                |
| 322  | [`node_repo_local_urls`](v-nodes.md#node_repo_local_urls)      | [`NODE_REPO`](v-nodes.md#NODE_REPO)             | C     | 本地源的URL地址                      |
| 330  | [`node_packages_default`](v-nodes.md#node_packages_default)                  | [`NODE_PACKAGES`](v-nodes.md#NODE_PACKAGES)     | C     | 节点安装软件列表                     |
| 331  | [`node_packages`](v-nodes.md#node_packages)      | [`NODE_PACKAGES`](v-nodes.md#NODE_PACKAGES)     | C     | 节点额外安装的软件列表               |
| 332  | [`node_packages_meta`](v-nodes.md#node_packages_meta)        | [`NODE_PACKAGES`](v-nodes.md#NODE_PACKAGES)     | G     | 元节点所需的软件列表                 |
| 333  | [`node_packages_meta_pip`](v-nodes.md#node_packages_meta_pip)  | [`NODE_PACKAGES`](v-nodes.md#NODE_PACKAGES)     | G     | 元节点上通过pip3安装的软件包         |
| 340  | [`node_disable_numa`](v-nodes.md#node_disable_numa)          | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | C     | 关闭节点NUMA                         |
| 341  | [`node_disable_swap`](v-nodes.md#node_disable_swap)          | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | C     | 关闭节点SWAP                         |
| 342  | [`node_disable_firewall`](v-nodes.md#node_disable_firewall)  | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | C     | 关闭节点防火墙                       |
| 343  | [`node_disable_selinux`](v-nodes.md#node_disable_selinux)    | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | C     | 关闭节点SELINUX                      |
| 344  | [`node_static_network`](v-nodes.md#node_static_network)      | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | C     | 是否使用静态DNS服务器                |
| 345  | [`node_disk_prefetch`](v-nodes.md#node_disk_prefetch)        | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | C     | 是否启用磁盘预读                     |
| 346  | [`node_kernel_modules`](v-nodes.md#node_kernel_modules)      | [`NODE_MODULES`](v-nodes.md#NODE_MODULES)       | C     | 启用的内核模块                       |
| 350  | [`node_tune`](v-nodes.md#node_tune)                          | [`NODE_TUNE`](v-nodes.md#NODE_TUNE)             | C     | 节点调优模式                         |
| 351  | [`node_sysctl_params`](v-nodes.md#node_sysctl_params)        | [`NODE_TUNE`](v-nodes.md#NODE_TUNE)             | C     | 操作系统内核参数                     |
| 360  | [`node_admin_enabled`](v-nodes.md#node_admin_enabled)            | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | G     | 是否创建管理员用户                   |
| 361  | [`node_admin_uid`](v-nodes.md#node_admin_uid)                | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | G     | 管理员用户UID                        |
| 362  | [`node_admin_username`](v-nodes.md#node_admin_username)      | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | G     | 管理员用户名                         |
| 363  | [`node_admin_ssh_exchange`](v-nodes.md#node_admin_ssh_exchange) | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | C     | 在实例间交换管理员SSH密钥            |
| 364  | [`node_admin_pk_current`](v-nodes.md#node_admin_pk_current)  | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | A     | 是否将当前用户的公钥加入管理员账户   |
| 365  | [`node_admin_pk_list`](v-nodes.md#node_admin_pk_list)                | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | C     | 可登陆管理员的公钥列表               |
| 370  | [`node_timezone`](v-nodes.md#node_timezone)                  | [`NODE_TIME`](v-nodes.md#NODE_TIME)             | C     | NTP时区设置                          |
| 371  | [`node_ntp_enabled`](v-nodes.md#node_ntp_enabled)              | [`NODE_TIME`](v-nodes.md#NODE_TIME)             | C     | 是否配置NTP服务？                    |
| 372  | [`node_ntp_service`](v-nodes.md#node_ntp_service)            | [`NODE_TIME`](v-nodes.md#NODE_TIME)             | C     | NTP服务类型：ntp或chrony             |
| 373  | [`node_ntp_servers`](v-nodes.md#node_ntp_servers)            | [`NODE_TIME`](v-nodes.md#NODE_TIME)             | C     | NTP服务器列表                        |
| 380  | [`node_exporter_enabled`](v-nodes.md#node_exporter_enabled)  | [`NODE_EXPORTER`](v-nodes.md#NODE_EXPORTER)     | C     | 启用节点指标收集器                   |
| 381  | [`node_exporter_port`](v-nodes.md#node_exporter_port)        | [`NODE_EXPORTER`](v-nodes.md#NODE_EXPORTER)     | C     | 节点指标暴露端口                     |
| 382  | [`node_exporter_options`](v-nodes.md#node_exporter_options)  | [`NODE_EXPORTER`](v-nodes.md#NODE_EXPORTER)     | C/I   | 节点指标采集选项                     |
| 390  | [`promtail_enabled`](v-nodes.md#promtail_enabled)            | [`PROMTAIL`](v-nodes.md#PROMTAIL)               | C     | 是否启用Promtail日志收集服务         |
| 391  | [`promtail_clean`](v-nodes.md#promtail_clean)                | [`PROMTAIL`](v-nodes.md#PROMTAIL)               | C/A   | 是否在安装promtail时移除已有状态信息 |
| 392  | [`promtail_port`](v-nodes.md#promtail_port)                  | [`PROMTAIL`](v-nodes.md#PROMTAIL)               | G     | promtail使用的默认端口               |
| 393  | [`promtail_options`](v-nodes.md#promtail_options)            | [`PROMTAIL`](v-nodes.md#PROMTAIL)               | C/I   | promtail命令行参数                   |
| 394  | [`promtail_positions`](v-nodes.md#promtail_positions)        | [`PROMTAIL`](v-nodes.md#PROMTAIL)               | C     | promtail状态文件位置                 |
| 500  | [`pg_cluster`](v-pgsql.md#pg_cluster)                        | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | C     | PG数据库集群名称                     |
| 501  | [`pg_shard`](v-pgsql.md#pg_shard)                            | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | C     | PG集群所属的Shard (保留)             |
| 502  | [`pg_sindex`](v-pgsql.md#pg_sindex)                          | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | C     | PG集群的分片号 (保留)                |
| 503  | [`gp_role`](v-pgsql.md#gp_role)                              | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | C     | 当前PG集群在GP中的角色               |
| 504  | [`pg_role`](v-pgsql.md#pg_role)                              | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | PG数据库实例角色                     |
| 505  | [`pg_seq`](v-pgsql.md#pg_seq)                                | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | PG数据库实例序号                     |
| 506  | [`pg_instances`](v-pgsql.md#pg_instances)                    | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | 当前节点上的所有PG实例               |
| 507  | [`pg_upstream`](v-pgsql.md#pg_upstream)                      | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | 实例的复制上游节点                   |
| 508  | [`pg_offline_query`](v-pgsql.md#pg_offline_query)            | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | 是否允许离线查询                     |
| 509  | [`pg_backup`](v-pgsql.md#pg_backup)                          | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | 是否在实例上存储备份                 |
| 510  | [`pg_weight`](v-pgsql.md#pg_weight)                          | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | 实例在负载均衡中的相对权重           |
| 511  | [`pg_hostname`](v-pgsql.md#pg_hostname)                      | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | C/I   | 将PG实例名称设为HOSTNAME             |
| 512  | [`pg_preflight_skip`](v-pgsql.md#pg_preflight_skip)          | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | C/A   | 跳过PG身份参数校验                   |
| 520  | [`pg_users`](v-pgsql.md#pg_users)                            | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | C     | 业务用户定义                         |
| 521  | [`pg_databases`](v-pgsql.md#pg_databases)                    | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | C     | 业务数据库定义                       |
| 522  | [`pg_services_extra`](v-pgsql.md#pg_services_extra)          | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | C     | 集群专有服务定义                     |
| 523  | [`pg_hba_rules_extra`](v-pgsql.md#pg_hba_rules_extra)        | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | C     | 集群/实例特定的HBA规则               |
| 524  | [`pgbouncer_hba_rules_extra`](v-pgsql.md#pgbouncer_hba_rules_extra) | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | C     | Pgbounce特定HBA规则                  |
| 525  | [`pg_admin_username`](v-pgsql.md#pg_admin_username)          | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | G     | PG管理用户                           |
| 526  | [`pg_admin_password`](v-pgsql.md#pg_admin_password)          | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | G     | PG管理用户密码                       |
| 527  | [`pg_replication_username`](v-pgsql.md#pg_replication_username) | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | G     | PG复制用户                           |
| 528  | [`pg_replication_password`](v-pgsql.md#pg_replication_password) | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | G     | PG复制用户的密码                     |
| 529  | [`pg_monitor_username`](v-pgsql.md#pg_monitor_username)      | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | G     | PG监控用户                           |
| 530  | [`pg_monitor_password`](v-pgsql.md#pg_monitor_password)      | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | G     | PG监控用户密码                       |
| 540  | [`pg_dbsu`](v-pgsql.md#pg_dbsu)                              | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | PG操作系统超级用户                   |
| 541  | [`pg_dbsu_uid`](v-pgsql.md#pg_dbsu_uid)                      | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | 超级用户UID                          |
| 542  | [`pg_dbsu_sudo`](v-pgsql.md#pg_dbsu_sudo)                    | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | 超级用户的Sudo权限                   |
| 543  | [`pg_dbsu_home`](v-pgsql.md#pg_dbsu_home)                    | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | 超级用户的家目录                     |
| 544  | [`pg_dbsu_ssh_exchange`](v-pgsql.md#pg_dbsu_ssh_exchange)    | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | 是否交换超级用户密钥                 |
| 545  | [`pg_version`](v-pgsql.md#pg_version)                        | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | 安装的数据库大版本                   |
| 546  | [`pgdg_repo`](v-pgsql.md#pgdg_repo)                          | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | 是否添加PG官方源？                   |
| 547  | [`pg_add_repo`](v-pgsql.md#pg_add_repo)                      | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | 是否添加PG相关上游源？               |
| 548  | [`pg_bin_dir`](v-pgsql.md#pg_bin_dir)                        | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | PG二进制目录                         |
| 549  | [`pg_packages`](v-pgsql.md#pg_packages)                      | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | 安装的PG软件包列表                   |
| 550  | [`pg_extensions`](v-pgsql.md#pg_extensions)                  | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | 安装的PG插件列表                     |
| 560  | [`pg_clean`](v-pgsql.md#pg_clean)            | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C/A   | PG存在时如何处理                     |
| 561  | [`pg_safeguard`](v-pgsql.md#pg_safeguard)            | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C/A   | 禁止清除存在的PG实例                 |
| 562  | [`pg_data`](v-pgsql.md#pg_data)                              | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG数据目录                           |
| 563  | [`pg_fs_main`](v-pgsql.md#pg_fs_main)                        | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG主数据盘挂载点                     |
| 564  | [`pg_fs_bkup`](v-pgsql.md#pg_fs_bkup)                        | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG备份盘挂载点                       |
| 565  | [`pg_dummy_filesize`](v-pgsql.md#pg_dummy_filesize)          | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | 占位文件/pg/dummy的大小              |
| 566  | [`pg_listen`](v-pgsql.md#pg_listen)                          | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG监听的IP地址                       |
| 567  | [`pg_port`](v-pgsql.md#pg_port)                              | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG监听的端口                         |
| 568  | [`pg_localhost`](v-pgsql.md#pg_localhost)                    | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG使用的UnixSocket地址               |
| 580  | [`patroni_enabled`](v-pgsql.md#patroni_enabled)              | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Patroni是否启用                      |
| 581  | [`patroni_mode`](v-pgsql.md#patroni_mode)                    | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Patroni配置模式                      |
| 582  | [`pg_namespace`](v-pgsql.md#pg_namespace)                    | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Patroni使用的DCS命名空间             |
| 583  | [`patroni_port`](v-pgsql.md#patroni_port)                    | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Patroni服务端口                      |
| 584  | [`patroni_watchdog_mode`](v-pgsql.md#patroni_watchdog_mode)  | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Patroni Watchdog模式                 |
| 585  | [`pg_conf`](v-pgsql.md#pg_conf)                              | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Patroni使用的配置模板                |
| 586  | [`pg_libs`](v-pgsql.md#pg_libs)      | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG默认加载的共享库                   |
| 587  | [`pg_encoding`](v-pgsql.md#pg_encoding)                      | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG字符集编码                         |
| 588  | [`pg_locale`](v-pgsql.md#pg_locale)                          | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG使用的本地化规则                   |
| 589  | [`pg_lc_collate`](v-pgsql.md#pg_lc_collate)                  | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG使用的本地化排序规则               |
| 590  | [`pg_lc_ctype`](v-pgsql.md#pg_lc_ctype)                      | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG使用的本地化字符集定义             |
| 591  | [`pgbouncer_enabled`](v-pgsql.md#pgbouncer_enabled)          | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | 是否启用Pgbouncer                    |
| 592  | [`pgbouncer_port`](v-pgsql.md#pgbouncer_port)                | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Pgbouncer端口                        |
| 593  | [`pgbouncer_poolmode`](v-pgsql.md#pgbouncer_poolmode)        | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Pgbouncer池化模式                    |
| 594  | [`pgbouncer_max_db_conn`](v-pgsql.md#pgbouncer_max_db_conn)  | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Pgbouncer最大单DB连接数              |
| 600  | [`pg_provision`](v-pgsql.md#pg_provision)                    | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | C     | 是否在PG集群中应用模板               |
| 601  | [`pg_init`](v-pgsql.md#pg_init)                              | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | C     | 自定义PG初始化脚本                   |
| 602  | [`pg_default_roles`](v-pgsql.md#pg_default_roles)            | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | G/C   | 默认创建的角色与用户                 |
| 603  | [`pg_default_privilegs`](v-pgsql.md#pg_default_privilegs)    | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | G/C   | 数据库默认权限配置                   |
| 604  | [`pg_default_schemas`](v-pgsql.md#pg_default_schemas)        | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | G/C   | 默认创建的模式                       |
| 605  | [`pg_default_extensions`](v-pgsql.md#pg_default_extensions)  | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | G/C   | 默认安装的扩展                       |
| 606  | [`pg_reload`](v-pgsql.md#pg_reload)                          | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | A     | 是否重载数据库配置（HBA）            |
| 607  | [`pg_hba_rules`](v-pgsql.md#pg_hba_rules)                    | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | G/C   | 全局HBA规则                          |
| 608  | [`pgbouncer_hba_rules`](v-pgsql.md#pgbouncer_hba_rules)      | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | G/C   | Pgbouncer全局HBA规则                 |
| 620  | [`pg_exporter_config`](v-pgsql.md#pg_exporter_config)        | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C     | PG指标定义文件                       |
| 621  | [`pg_exporter_enabled`](v-pgsql.md#pg_exporter_enabled)      | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C     | 启用PG指标收集器                     |
| 622  | [`pg_exporter_port`](v-pgsql.md#pg_exporter_port)            | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C     | PG指标暴露端口                       |
| 623  | [`pg_exporter_params`](v-pgsql.md#pg_exporter_params)        | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | PG Exporter额外的URL参数             |
| 624  | [`pg_exporter_url`](v-pgsql.md#pg_exporter_url)              | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | 采集对象数据库的连接串（覆盖）       |
| 625  | [`pg_exporter_auto_discovery`](v-pgsql.md#pg_exporter_auto_discovery) | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | 是否自动发现实例中的数据库           |
| 626  | [`pg_exporter_exclude_database`](v-pgsql.md#pg_exporter_exclude_database) | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | 数据库自动发现排除列表               |
| 627  | [`pg_exporter_include_database`](v-pgsql.md#pg_exporter_include_database) | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | 数据库自动发现囊括列表               |
| 628  | [`pg_exporter_options`](v-pgsql.md#pg_exporter_options)      | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | PG Exporter命令行参数                |
| 629  | [`pgbouncer_exporter_enabled`](v-pgsql.md#pgbouncer_exporter_enabled) | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C     | 启用PGB指标收集器                    |
| 630  | [`pgbouncer_exporter_port`](v-pgsql.md#pgbouncer_exporter_port) | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C     | PGB指标暴露端口                      |
| 631  | [`pgbouncer_exporter_url`](v-pgsql.md#pgbouncer_exporter_url) | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | 采集对象连接池的连接串               |
| 632  | [`pgbouncer_exporter_options`](v-pgsql.md#pgbouncer_exporter_options) | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | PGB Exporter命令行参数               |
| 640  | [`pg_services`](v-pgsql.md#pg_services)                      | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | G/C   | 全局通用服务定义                     |
| 641  | [`haproxy_enabled`](v-pgsql.md#haproxy_enabled)              | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C/I   | 是否启用Haproxy                      |
| 642  | [`haproxy_reload`](v-pgsql.md#haproxy_reload)                | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | A     | 是否重载Haproxy配置                  |
| 643  | [`haproxy_auth_enabled`](v-pgsql.md#haproxy_auth_enabled) | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | G/C   | 是否对Haproxy管理界面启用认证        |
| 644  | [`haproxy_admin_username`](v-pgsql.md#haproxy_admin_username) | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | G     | HAproxy管理员名称                    |
| 645  | [`haproxy_admin_password`](v-pgsql.md#haproxy_admin_password) | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | G     | HAproxy管理员密码                    |
| 646  | [`haproxy_exporter_port`](v-pgsql.md#haproxy_exporter_port)  | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | HAproxy指标暴露器端口                |
| 647  | [`haproxy_client_timeout`](v-pgsql.md#haproxy_client_timeout) | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | HAproxy客户端超时                    |
| 648  | [`haproxy_server_timeout`](v-pgsql.md#haproxy_server_timeout) | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | HAproxy服务端超时                    |
| 649  | [`vip_mode`](v-pgsql.md#vip_mode)                            | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | VIP模式：none                        |
| 650  | [`vip_reload`](v-pgsql.md#vip_reload)                        | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | A     | 是否重载VIP配置                      |
| 651  | [`vip_address`](v-pgsql.md#vip_address)                      | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | 集群使用的VIP地址                    |
| 652  | [`vip_cidrmask`](v-pgsql.md#vip_cidrmask)                    | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | VIP地址的网络CIDR掩码长度            |
| 653  | [`vip_interface`](v-pgsql.md#vip_interface)                  | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | VIP使用的网卡                        |
| 654  | [`dns_mode`](v-pgsql.md#dns_mode)                            | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | DNS配置模式                          |
| 655  | [`dns_selector`](v-pgsql.md#dns_selector)                    | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | DNS解析对象选择器                    |
| 700  | [`redis_cluster`](v-redis.md#redis_cluster)                  | [`REDIS_IDENTITY`](v-redis.md#REDIS_IDENTITY)   | C     | Redis数据库集群名称                  |
| 701  | [`redis_node`](v-redis.md#redis_node)                        | [`REDIS_IDENTITY`](v-redis.md#REDIS_IDENTITY)   | I     | Redis节点序列号                      |
| 702  | [`redis_instances`](v-redis.md#redis_instances)              | [`REDIS_IDENTITY`](v-redis.md#REDIS_IDENTITY)   | I     | Redis实例定义                        |
| 720  | [`redis_install_method`](v-redis.md#redis_install_method)                  | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | 安装Redis的方式                      |
| 721  | [`redis_mode`](v-redis.md#redis_mode)                        | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | Redis集群模式                        |
| 722  | [`redis_conf`](v-redis.md#redis_conf)                        | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | Redis配置文件模板                    |
| 723  | [`redis_fs_main`](v-redis.md#redis_fs_main)                  | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | PG数据库实例角色                     |
| 724  | [`redis_bind_address`](v-redis.md#redis_bind_address)        | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | Redis监听的端口地址                  |
| 725  | [`redis_clean`](v-redis.md#redis_clean)      | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | Redis存在时执行何种操作              |
| 726  | [`redis_safeguard`](v-redis.md#redis_safeguard)      | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | 禁止抹除现存的Redis                  |
| 727  | [`redis_max_memory`](v-redis.md#redis_max_memory)            | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C/I   | Redis可用的最大内存                  |
| 728  | [`redis_mem_policy`](v-redis.md#redis_mem_policy)            | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | 内存逐出策略                         |
| 729  | [`redis_password`](v-redis.md#redis_password)                | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | Redis密码                            |
| 730  | [`redis_rdb_save`](v-redis.md#redis_rdb_save)                | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | RDB保存指令                          |
| 731  | [`redis_aof_enabled`](v-redis.md#redis_aof_enabled)          | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | 是否启用AOF                          |
| 732  | [`redis_rename_commands`](v-redis.md#redis_rename_commands)  | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | 重命名危险命令列表                   |
| 740  | [`redis_cluster_replicas`](v-redis.md#redis_cluster_replicas) | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | 集群每个主库带几个从库               |
| 741  | [`redis_exporter_enabled`](v-redis.md#redis_exporter_enabled) | [`REDIS_EXPORTER`](v-redis.md#REDIS_EXPORTER)   | C     | 是否启用Redis监控                    |
| 742  | [`redis_exporter_port`](v-redis.md#redis_exporter_port)      | [`REDIS_EXPORTER`](v-redis.md#REDIS_EXPORTER)   | C     | Redis Exporter监听端口               |
| 743  | [`redis_exporter_options`](v-redis.md#redis_exporter_options) | [`REDIS_EXPORTER`](v-redis.md#REDIS_EXPORTER)   | C/I   | Redis Exporter命令参数               |

</details>

