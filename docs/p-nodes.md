# Playbook：NODES

> Use the  `nodes` series [playbook](p-playbook.md)  to include more nodes in Pigsty management, adjusting the nodes to the state described in [configuration](v-nodes.md).

Once you have completed a complete installation of Pigsty on the management node using [`infra.yml`](p-infra.md) ,you can further add more nodes to Pigsty using [`nodes.yml`](#nodes)  or remove them from the environment using [`nodes-remove.yml`](nodes-remove) to remove the node from the environment.

| Playbook                                  | Function                                                     | Link                                                         |
| ----------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| [`nodes`](p-nodes.md#nodes)               | **Node provisioning to include nodes in Pigsty management for subsequent database deployment** | [`src`](https://github.com/vonng/pigsty/blob/master/nodes.yml) |
| [`nodes-remove`](p-nodes.md#nodes-remove) | Node removal, offloading node DCS and monitoring, no longer included in Pigsty management | [`src`](https://github.com/vonng/pigsty/blob/master/nodes-remove.yml) |


---------------

## `nodes`

The [`nodes.yml`](p-nodes.md) playbook to add more nodes to Pigsty. This playbook needs to be initiated on the **management node** and executed against the target node.

This playbook adjusts the target machine nodes to the state described in the configuration list, installs the Consul service and incorporates it into the Pigsty monitoring system, and allows you to further deploy different types of database clusters on these provisioned nodes.

The behavior of the `nodes.yml` playbook is determined by the [node configuration](v-nodes.md). The full execution of this playbook may take 1 to 3 minutes when using local sources, depending on the machine configuration.

```bash
./nodes.yml                      # Initialize all nodes in the list (danger!)
./nodes.yml -l pg-test           # Initialize the machines under the pg-test group (recommended!)
./nodes.yml -l pg-meta,pg-test   # Initialize the nodes in both pg-meta and pg-test clusters at the same time
./nodes.yml -l 10.10.10.11       # Initialize the machine node 10.10.10.11
```

![](_media/playbook/nodes.svg)


This playbook contains the following functions and tasks:

* Generate node identity parameters
* Initialize Node
  * Configure the node name
  * Configure node static DNS resolution
  * Configure the node's dynamic DNS resolution server
  * Configure the node's Yum source
  * Install the specified RPM packages
  * Configure features such as numa/swap/firewall
  * Configure node tuned tuning templates
  * Configure shortcut commands and environment variables for the node
  * Create node administrator and configure SSH
  * Configure node time zone
  * Configure the node NTP service
* Initialize the DCS service on the node: Consul
  * Erase existing Consul
  * Initialize the Consul Agent or Server service for the current node
* Initialize the node monitoring component and incorporate Pigsty
  * Install Node Exporter on the node
  * Register the Node Exporter to Prometheus on the management node.

**Caution is required when executing this playbook for cases where there is already a node with a database running, and there is a risk of accidentally triggering a brief unavailability of the database when used improperly, as initializing the node will erase the DCS Agent**.

Node provisioning configures the node's DCS service (Consul Agent), so be careful when running this playbook on a node running a PostgreSQL database!
The [dcs_exists_action](v-nodes.md#dcs_exists_action) parameter provides the option to avoid accidental deletion, allowing to avoid worst-case scenarios by automatically aborting or skipping high-risk operations when an existing running DCS is detected during the initialization process.
Nevertheless，when **using the full `nodes.yml` playbook or the section on `dcs|consul` therein, please check several times that the `-tags|-t` and `-limit|-l` parameters are correct. Make sure you are performing the right task on the right target. **


### Protection mechanism

`nodes.yml`提供**保护机制**，由配置参数 [`dcs_exists_action`](v-nodes.md#dcs_exists_action) 决定。当执行剧本前会目标机器上有正在运行的PostgreSQL实例时，Pigsty会根据 [`dcs_exists_action`](v-nodes.md#dcs_exists_action) 的配置`abort|clean|skip`行动。

* `abort`：建议设置为默认配置，如遇现存DCS实例，中止剧本执行，避免误删库。
* `clean`：建议在本地沙箱环境使用，如遇现存实例，清除已有DCS实例。
* `skip`：  跳过此主机，在其他主机上执行后续逻辑。
* 您可以通过`./nodes.yml -e pg_exists_action=clean`的方式来覆盖配置文件选项，强制抹掉现有实例

[`dcs_disable_purge`](v-nodes.md#dcs_disable_purge) 选项提供了双重保护，如果启用该选项，则 [`dcs_exists_action`](v-nodes.md#dcs_exists_action) 会被强制设置为`abort`，在任何情况下都不会抹掉运行中的数据库实例。



### 选择性执行

用户可以通过ansible的标签机制，**选择性执行**本剧本的一个子集。例如，如果只想执行节点监控部署的任务，则可以通过以下命令：

```bash
./nodes.yml --tags=node-monitor
```

具体的标签请参考 [**任务详情**](#任务详情)

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
./nodes.yml --tags=consul -e dcs_exists_action=clean   # 在节点上强制抹除重新配置consul

./nodes.yml --tags=node_exporter   # 在节点上配置 node_exporter 并注册
./nodes.yml --tags=node_deregister # 将节点监控从元节点上取消注册
./nodes.yml --tags=node_register   # 将节点监控注册到元节点上

```


### 创建管理用户

管理用户是一个先有鸡还是先有蛋的问题。为了执行Ansible剧本，需要有一个管理用户。为了创建一个专用的管理用户，需要执行此Ansible剧本。

Pigsty推荐将管理用户的创建，权限配置与密钥分发放在虚拟机的Provisioning阶段完成，作为机器资源交付内容的一部分。对于生产环境来说，机器交付时应当已经配置有这样一个具有免密远程SSH登陆并执行免密sudo的用户。通常绝大多数云平台和运维体系都可以做到这一点。

如果您只能使用ssh密码和sudo密码，那么必须在所有剧本执行时添加额外的参数 `--ask-pass|-k` 与 `--ask-become-pass|-K`，并在提示出现时输入ssh密码与sudo密码。您可以使用 `nodes.yml` 中创建管理员用户的功能，使用当前用户创建一个专用管理员用户，以下参数用于创建默认的管理员用户：

* [`node_admin_setup`](v-nodes.md#node_admin_setup)
* [`node_admin_uid`](v-nodes.md#node_admin_uid)
* [`node_admin_username`](v-nodes.md#node_admin_username)
* [`node_admin_pks`](v-nodes.md#node_admin_pks)

```bash
./nodes.yml -t node_admin -l <目标机器> --ask-pass --ask-become-pass
```

默认创建的管理员用户为dba (uid=88)，请**不要**使用 postgres 或 dbsu 作为管理用户，请尽量避免直接使用 root 作为管理用户。

在沙箱环境中的默认用户 vagrant 默认已经配置有免密登陆和免密sudo，您可以从宿主机或沙箱管理节点使用vagrant登陆所有的数据库节点。

例如：

```bash
./nodes.yml --limit <target_hosts>  --tags node_admin  -e ansible_user=<another_admin> --ask-pass --ask-become-pass 
```

详情请参考：[准备：管理用户置备](d-prepare.md#管理用户置备)







---------------

## `nodes-remove`

[`nodes-remove.yml`](#nodes-remove) 剧本是 [`nodes`](#nodes)剧本的反向操作，用于将节点从Pigsty中移除。

该剧本需要在 **管理节点** 上发起，针对目标节点执行。

```bash
./nodes.yml                      # 移除所有节点（危险！）
./nodes.yml -l nodes-test        # 移除 nodes-test 分组下的机器
./nodes.yml -l 10.10.10.11       # 移除 10.10.10.11这台机器节点
./nodes.yml -l 10.10.10.10 -e rm_dcs_servers=true # 如果节点为DCS Server，需要额外参数移除。
```

![](_media/playbook/nodes-remove.svg)

### 任务子集

```bash
# play
./nodes-remove.yml --tags=register      # 移除节点注册信息
./nodes-remove.yml --tags=node-exporter # 移除节点指标收集器
./nodes-remove.yml --tags=promtail      # 移除Promtail日志收集组件
./nodes-remove.yml --tags=consul        # 移除Consul Agent服务
./nodes-remove.yml --tags=consul -e rm_dcs_servers=true # 移除Consul服务（包括Server！）
```