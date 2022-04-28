# 剧本：NODES

> 使用 `NODES` 系列[剧本](p-playbook.md)将更多节点纳入Pigsty管理，将节点调整至[配置](v-nodes.md)描述的状态。

当您使用 [`infra.yml`](p-infra.md) 在元节点上完成Pigsty的完整安装后，您可以进一步使用 [`nodes.yml`](#nodes) 将更多节点添加至Pigsty中，或者使用 [`nodes-remove.yml`](nodes-remove) 将节点从环境中移除。

| 剧本                                           | 功能                                                           | 链接                                                         |
|----------------------------------------------|----------------------------------------------------------------| ------------------------------------------------------------ |
| [`nodes`](p-nodes.md#nodes)                   |        **节点置备，将节点纳入Pigsty管理，可用于后续数据库部署**                    |        [`src`](https://github.com/vonng/pigsty/blob/master/nodes.yml)            |
| [`nodes-remove`](p-nodes.md#nodes-remove)     |        节点移除，卸载节点DCS与监控，不再纳入Pigsty管理                     |        [`src`](https://github.com/vonng/pigsty/blob/master/nodes-remove.yml)     |


---------------

## `nodes`

[`nodes.yml`](p-nodes.md) 剧本将更多节点添加至Pigsty中。该剧本需要在 **元节点** 上发起，针对目标节点执行。

此剧本可以将目标机器节点调整至配置清单所描述的状态，安装Consul服务，并将其纳入Pigsty监控系统，并允许您在这些置备好的节点上进一步部署不同类型的数据库集群。

`nodes.yml` 剧本的行为由 [节点配置](v-nodes.md) 决定。在使用本地源的情况下，完整执行此剧本可能耗时1～3分钟，视机器配置而异。

```bash
./nodes.yml                      # 初始化所有清单中的节点（危险！）
./nodes.yml -l pg-test           # 初始化在 pg-test 分组下的机器（推荐！）
./nodes.yml -l pg-meta,pg-test   # 同时初始化pg-meta与pg-test两个集群中的节点
./nodes.yml -l 10.10.10.11       # 初始化10.10.10.11这台机器节点
```

![](../_media/playbook/nodes.svg)


此剧本包含的功能与任务如下：

* 生成节点[身份参数](v-nodes.md#NODE_IDENTITY)
* 初始化节点
  * 配置节点名称
  * 配置节点静态DNS解析
  * 配置节点动态DNS解析服务器
  * 配置节点的Yum源
  * 安装指定的RPM软件包
  * 配置 numa/swap/firewall等特性
  * 配置节点tuned调优模板
  * 配置节点的快捷命令与环境变量
  * 创建节点管理员并配置SSH
  * 配置节点时区
  * 配置节点NTP服务
* 在节点上初始化DCS服务：Consul
  * 抹除现有Consul
  * 初始化当前节点的 Consul Agent或Server 服务
* 初始化节点监控组件并纳入Pigsty
  * 在节点上安装 Node Exporter
  * 将 Node Exporter 注册至元节点上的 Prometheus 中。



!>  **对于已有数据库运行的节点执行该剧本需要谨慎，使用不当存在误触发短暂数据库不可用的风险，因为初始化节点会抹除DCS Agent**。

节点置备会配置节点的DCS服务（Consul Agent），因此在对运行有PostgreSQL数据库的节点运行此剧本时，请小心！
[`consul_clean`](v-nodes.md#consul_clean) 参数提供了避免误删的选项作为保险，允许以在初始化过程中，当检测到已有运行中DCS时自动中止或跳过高危操作，避免最坏情况发生。

!> 尽管如此，在**使用完整的`nodes.yml`剧本或其中关于`dcs|consul`的部分时，请再三检查`--tags|-t` 与 `--limit|-l` 参数是否正确。确保自己在正确的目标上执行正确的任务。**



### 保护机制

`nodes.yml`提供**保护机制**，由配置参数 [`consul_clean`](v-nodes.md#consul_clean) 决定。当执行剧本前会目标机器上有正在运行的Consul实例时，Pigsty会根据 [`consul_clean`](v-nodes.md#consul_clean) 的配置`abort|clean|skip`行动。

* `abort`：建议设置为默认配置，如遇现存DCS实例，中止剧本执行，避免误删库。
* `clean`：建议在本地沙箱环境使用，如遇现存实例，清除已有DCS实例。
* `skip`：  跳过此主机，在其他主机上执行后续逻辑。
* 您可以通过`./nodes.yml -e pg_exists_action=clean`的方式来覆盖配置文件选项，强制抹掉现有实例

[`consul_safeguard`](v-nodes.md#consul_safeguard) 选项提供了双重保护，如果启用该选项，则 [`consul_clean`](v-nodes.md#consul_clean) 会被强制设置为`abort`，在任何情况下都不会抹掉运行中的数据库实例，除非您显式执行 [`nodes-remove.yml`](#nodes-remove)。



### 选择性执行

用户可以通过ansible的标签机制，**选择性执行**本剧本的一个子集。例如，如果只想执行节点监控部署的任务，则可以通过以下命令：

```bash
./nodes.yml --tags=node-monitor
```

一些常用的任务子集包括：

```bash
# play
./nodes.yml --tags=node-id         # 打印节点身份参数：名称与集群
./nodes.yml --tags=node-init       # 初始化节点，完成配置
./nodes.yml --tags=dcs-init        # 在节点上初始化DCS服务：Consul
./nodes.yml --tags=node-monitor    # 初始化节点监控组件并纳入Pigsty

# tasks
./nodes.yml --tags=node_name       # 配置节点名称
./nodes.yml --tags=node_dns        # 配置节点静态DNS解析
./nodes.yml --tags=node_resolv     # 配置节点动态DNS解析服务器
./nodes.yml --tags=node_repo       # 配置节点的Yum源
./nodes.yml --tags=node_pkgs       # 安装指定的RPM软件包
./nodes.yml --tags=node_feature    # 配置 numa/swap/firewall等特性
./nodes.yml --tags=node_tuned      # 配置节点tuned调优模板
./nodes.yml --tags=node_profile    # 配置节点的快捷命令与环境变量
./nodes.yml --tags=node_admin      # 创建节点管理员并配置SSH
./nodes.yml --tags=node_timezone   # 配置节点时区
./nodes.yml --tags=node_ntp        # 配置节点NTP服务

./nodes.yml --tags=consul          # 在节点上配置consul agent/server
./nodes.yml --tags=consul -e consul_clean=clean   # 在节点上强制抹除重新配置consul

./nodes.yml --tags=node_exporter   # 在节点上配置 node_exporter 并注册
./nodes.yml --tags=node_deregister # 将节点监控从元节点上取消注册
./nodes.yml --tags=node_register   # 将节点监控注册到元节点上

```


### 创建管理用户

管理用户是一个先有鸡还是先有蛋的问题。为了执行Ansible剧本，需要有一个管理用户。为了创建一个专用的管理用户，需要执行此Ansible剧本。

Pigsty推荐将管理用户的创建，权限配置与密钥分发放在虚拟机的Provisioning阶段完成，作为机器资源交付内容的一部分。对于生产环境来说，机器交付时应当已经配置有这样一个具有免密远程SSH登陆并执行免密sudo的用户。通常绝大多数云平台和运维体系都可以做到这一点。

如果您只能使用ssh密码和sudo密码，那么必须在所有剧本执行时添加额外的参数 `--ask-pass|-k` 与 `--ask-become-pass|-K`，并在提示出现时输入ssh密码与sudo密码。您可以使用 `nodes.yml` 中创建管理员用户的功能，使用当前用户创建一个专用管理员用户，以下参数用于创建默认的管理员用户：

* [`node_admin_enabled`](v-nodes.md#node_admin_enabled)
* [`node_admin_uid`](v-nodes.md#node_admin_uid)
* [`node_admin_username`](v-nodes.md#node_admin_username)
* [`node_admin_pk_list`](v-nodes.md#node_admin_pk_list)

```bash
./nodes.yml -t node_admin -l <目标机器> --ask-pass --ask-become-pass
```

默认创建的管理员用户为 `dba(uid=88)`，请**不要**使用 `postgres` 或 `{{ dbsu }}` 作为管理用户，请尽量避免直接使用 `root` 作为管理用户。

在沙箱环境中的默认用户 `vagrant` 默认已经配置有免密登陆和免密sudo，您可以从宿主机或沙箱元节点使用vagrant登陆所有的数据库节点。

例如：

```bash
./nodes.yml --limit <target_hosts>  --tags node_admin  -e ansible_user=<another_admin> --ask-pass --ask-become-pass 
```

详情请参考：[准备：管理用户置备](d-prepare.md#管理用户置备)







---------------

## `nodes-remove`

[`nodes-remove.yml`](#nodes-remove) 剧本是 [`nodes`](#nodes)剧本的反向操作，用于将节点从Pigsty中移除。

该剧本需要在 **元节点** 上发起，针对目标节点执行。

```bash
./nodes.yml                      # 移除所有节点（危险！）
./nodes.yml -l nodes-test        # 移除 nodes-test 分组下的机器
./nodes.yml -l 10.10.10.11       # 移除 10.10.10.11这台机器节点
./nodes.yml -l 10.10.10.10 -e rm_dcs_servers=true # 如果节点为DCS Server，需要额外参数移除。
```

![](../_media/playbook/nodes-remove.svg)

### 任务子集

```bash
# play
./nodes-remove.yml --tags=register      # 移除节点注册信息
./nodes-remove.yml --tags=node-exporter # 移除节点指标收集器
./nodes-remove.yml --tags=promtail      # 移除Promtail日志收集组件
./nodes-remove.yml --tags=consul        # 移除Consul Agent服务
./nodes-remove.yml --tags=consul -e rm_dcs_servers=true # 移除Consul服务（包括Server！）
```