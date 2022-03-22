# 剧本：NODES

> 使用 `nodes` 系列[剧本](p-playbook.md)将更多节点纳入Pigsty管理，启用主机监控与日志在当前管理节点上安装Pigsty，并加装可选功能。

节点系列剧本用于将更多节点纳入Pigsty管理，在管理节点上发起，针对配置中声明的节点执行。

| 剧本                                           | 功能                                                           | 链接                                                         |
|----------------------------------------------|----------------------------------------------------------------| ------------------------------------------------------------ |
| [`nodes`](p-nodes.md#nodes)                   |        **节点置备，将节点纳入Pigsty管理，可用于后续数据库部署**                    |        [`src`](https://github.com/vonng/pigsty/blob/master/nodes.yml)            |
| [`nodes-remove`](p-nodes.md#nodes-remove)     |        节点移除，卸载节点DCS与监控，不再纳入Pigsty管理                     |        [`src`](https://github.com/vonng/pigsty/blob/master/nodes-remove.yml)     |



## 概览

当您使用 [`infra.yml`](p-infra.md) 在管理节点上完成Pigsty的完整安装后，您可以进一步使用 本剧本 [`nodes.yml`](p-nodes.md) 将更多节点添加至Pigsty中。

此剧本可以将目标机器节点调整至配置清单所描述的状态，安装Consul服务，并将其纳入Pigsty监控系统，并允许您在这些置备好的节点上进一步部署不同类型的数据库集群。

此剧本包含的功能与任务如下：

* 生成节点身份参数
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
  * 将 Node Exporter 注册至管理节点上的 Prometheus 中。



`nodes.yml` 剧本的行为由 [节点配置](v-nodes.md) 决定，在使用本地源的情况下，完整执行此剧本可能耗时1～3分钟，视机器配置而异。

```bash
./nodes.yml                      # 初始化所有清单中的节点（危险！）
./nodes.yml -l pg-test           # 初始化在 pg-test 分组下的机器（推荐！）
./nodes.yml -l pg-meta,pg-test   # 同时初始化pg-meta与pg-test两个集群中的节点
./nodes.yml -l 10.10.10.11       # 初始化10.10.10.11这台机器节点
```

!> **对于已有数据库运行的节点执行该剧本需要谨慎，使用不当存在误触发短暂数据库不可用的风险，因为初始化节点会抹除DCS Agent**。

节点置备会配置节点的DCS服务（Consul Agent），因此在对运行有PostgreSQL数据库的节点运行此剧本时，请小心！
[dcs_exists_action](v-nodes.md#dcs_exists_action) 参数提供了避免误删的选项作为保险，允许以在初始化过程中，当检测到已有运行中DCS时自动中止或跳过高危操作，避免最坏情况发生。
尽管如此，在**使用完整的`nodes.yml`剧本或其中关于`dcs|consul`的部分时，请再三检查`--tags|-t` 与 `--limit|-l` 参数是否正确。确保自己在正确的目标上执行正确的任务。**


## 选择性执行

用户可以通过ansible的标签机制，**选择性执行**本剧本的一个子集。

例如，如果只想执行节点监控部署的任务，则可以通过以下命令：

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






## 原始内容

<details>

```yaml
#---------------------------------------------------------------
# node identity
#---------------------------------------------------------------
# pg_hostname: use pgsql identity as node identity if applicable
# if node identity is leaving blank, and pgsql identity exists
# pgsql instance's cls & ins will be used as node identity too
#---------------------------------------------------------------
- name: Node Identity
  become: yes
  hosts: all
  gather_facts: no
  tags: [ always, node-id ]
  tasks:
    - name: Overwrite node_cluster
      when: (pg_hostname is defined and pg_hostname|bool) and (node_cluster is not defined or node_cluster == 'nodes' or node_cluster == '') and (pg_cluster is defined and pg_cluster != '')
      set_fact:
        node_cluster: "{{ pg_cluster }}"    # use pg_cluster as non-trivial node_cluster name

    - name: Overwrite nodename
      when: (pg_hostname is defined and pg_hostname|bool) and (nodename is not defined or nodename == '') and (pg_cluster is defined and pg_cluster != '' and pg_seq is defined)
      set_fact:
        nodename: "{{ pg_cluster }}-{{ pg_seq }}"

    - debug:
        msg: "ins={{ nodename|default('NULL') }} cls={{ node_cluster|default('NULL') }}"

#---------------------------------------------------------------
# init node & dcs
#---------------------------------------------------------------
- name: Node Init
  become: yes
  hosts: all
  gather_facts: no
  tags: node-init
  roles:

    # prepare node for use
    - role: node
      tags: node

    # init dcs:consul server/agent
    - role: consul
      tags: [ dcs, consul ]


#---------------------------------------------------------------
# init monitor for node
#---------------------------------------------------------------
- name: Node Monitor
  become: yes
  hosts: all
  gather_facts: no
  tags: node-monitor
  roles:

    # init & register node exporter
    - role: node_exporter
      tags: node_exporter

#---------------------------------------------------------------
...

```

</details>



## 任务详情

使用以下命令可以列出所有节点会执行的任务，以及可以使用的标签：

```bash
./nodes.yml --list-tasks
```

默认任务如下：

<details>

```yaml
playbook: ./nodes.yml

  play #1 (all): Node Identity	TAGS: [always,node-id]
  tasks:
    Overwrite node_cluster	TAGS: [always, node-id]
    Overwrite nodename	TAGS: [always, node-id]
    debug	TAGS: [always, node-id]

  play #2 (all): Node Init	TAGS: [node-init]
  tasks:
    node : Setup node name	TAGS: [node, node-init, node_name]
    node : Fetch hostname from server	TAGS: [node, node-init, node_name]
    node : Exchange hostname among servers	TAGS: [node, node-init, node_name]
    node : Write static dns records to /etc/hosts	TAGS: [node, node-init, node_dns]
    node : Write extra static dns records to /etc/hosts	TAGS: [node, node-init, node_dns]
    node : Get old nameservers	TAGS: [node, node-init, node_resolv]
    node : Write tmp resolv file	TAGS: [node, node-init, node_resolv]
    node : Write resolv options	TAGS: [node, node-init, node_resolv]
    node : Write additional nameservers	TAGS: [node, node-init, node_resolv]
    node : Append existing nameservers	TAGS: [node, node-init, node_resolv]
    node : Swap resolv.conf	TAGS: [node, node-init, node_resolv]
    node : Node configure disable firewall	TAGS: [node, node-init, node_firewall]
    node : Node disable selinux by default	TAGS: [node, node-init, node_firewall]
    node : Backup existing repos	TAGS: [node, node-init, node_repo]
    node : Install upstream repo	TAGS: [node, node-init, node_repo]
    node : Install local repo	TAGS: [node, node-init, node_repo]
    node : Install node basic packages	TAGS: [node, node-init, node_pkgs]
    node : Install node extra packages	TAGS: [node, node-init, node_pkgs]
    node : Install meta specific packages	TAGS: [node, node-init, node_pkgs]
    node : Install node basic packages	TAGS: [node, node-init, node_pkgs]
    node : Install node extra packages	TAGS: [node, node-init, node_pkgs]
    node : Install meta specific packages	TAGS: [node, node-init, node_pkgs]
    node : Install pip3 packages on meta node	TAGS: [node, node-init, node_pip, node_pkgs]
    node : Node configure disable numa	TAGS: [node, node-init, node_feature]
    node : Node configure disable swap	TAGS: [node, node-init, node_feature]
    node : Node configure unmount swap	TAGS: [node, node-init, node_feature]
    node : Node setup static network	TAGS: [node, node-init, node_feature]
    node : Node configure disable firewall	TAGS: [node, node-init, node_feature]
    node : Node configure disk prefetch	TAGS: [node, node-init, node_feature]
    node : Enable linux kernel modules	TAGS: [node, node-init, node_kernel]
    node : Enable kernel module on reboot	TAGS: [node, node-init, node_kernel]
    node : Get config parameter page count	TAGS: [node, node-init, node_tuned]
    node : Get config parameter page size	TAGS: [node, node-init, node_tuned]
    node : Tune shmmax and shmall via mem	TAGS: [node, node-init, node_tuned]
    node : Create tuned profiles	TAGS: [node, node-init, node_tuned]
    node : Render tuned profiles	TAGS: [node, node-init, node_tuned]
    node : Active tuned profile	TAGS: [node, node-init, node_tuned]
    node : Change additional sysctl params	TAGS: [node, node-init, node_tuned]
    node : Copy default user bash profile	TAGS: [node, node-init, node_profile]
    node : Setup node default pam ulimits	TAGS: [node, node-init, node_ulimit]
    node : Create os user group admin	TAGS: [node, node-init, node_admin]
    node : Create os user admin	TAGS: [node, node-init, node_admin]
    node : Grant admin group nopass sudo	TAGS: [node, node-init, node_admin]
    node : Add no host checking to ssh config	TAGS: [node, node-init, node_admin]
    node : Add admin ssh no host checking	TAGS: [node, node-init, node_admin]
    node : Fetch all admin public keys	TAGS: [node, node-init, node_admin]
    node : Exchange all admin ssh keys	TAGS: [node, node-init, node_admin]
    node : Install public keys	TAGS: [node, node-init, node_admin, node_admin_pks]
    node : Install current public key	TAGS: [node, node-init, node_admin, node_admin_pk_current]
    node : Setup default node timezone	TAGS: [node, node-init, node_timezone]
    node : Install ntp package	TAGS: [node, node-init, node_ntp, ntp_config]
    node : Install chrony package	TAGS: [node, node-init, node_ntp, ntp_config]
    node : Copy the ntp.conf file	TAGS: [node, node-init, node_ntp, ntp_config]
    node : Copy the chrony.conf template	TAGS: [node, node-init, node_ntp, ntp_config]
    node : Launch ntpd service	TAGS: [node, node-init, node_ntp, ntp_launch]
    node : Launch chronyd service	TAGS: [node, node-init, node_ntp, ntp_launch]
    consul : Check for existing consul	TAGS: [consul, consul_check, dcs, node-init]
    consul : Consul exists flag fact set	TAGS: [consul, consul_check, dcs, node-init]
    consul : Abort due to consul exists	TAGS: [consul, consul_check, dcs, node-init]
    consul : Skip due to consul exists	TAGS: [consul, consul_check, dcs, node-init]
    consul : Clean existing consul instance	TAGS: [consul, consul_clean, dcs, node-init]
    consul : Stop any running consul instance	TAGS: [consul, consul_clean, dcs, node-init]
    consul : Remove existing consul dir	TAGS: [consul, consul_clean, dcs, node-init]
    consul : Recreate consul dir	TAGS: [consul, consul_clean, dcs, node-init]
    consul : Make sure consul is installed	TAGS: [consul, consul_install, dcs, node-init]
    consul : Make sure consul dir exists	TAGS: [consul, consul_config, dcs, node-init]
    consul : Get dcs server node names	TAGS: [consul, consul_config, dcs, node-init]
    consul : Get dcs node name from var nodename	TAGS: [consul, consul_config, dcs, node-init]
    consul : Fetch hostname as dcs node name	TAGS: [consul, consul_config, dcs, node-init]
    consul : Get dcs name from hostname	TAGS: [consul, consul_config, dcs, node-init]
    consul : Make sure consul hcl absent	TAGS: [consul, consul_config, dcs, node-init]
    consul : Copy /etc/consul.d/consul.json	TAGS: [consul, consul_config, dcs, node-init]
    consul : Copy consul agent service	TAGS: [consul, consul_config, dcs, node-init]
    consul : Copy consul node-meta definition	TAGS: [consul, consul_config, consul_meta, dcs, node-init]
    consul : Restart consul to load new node-meta	TAGS: [consul, consul_config, consul_meta, dcs, node-init]
    consul : Get dcs bootstrap expect quroum	TAGS: [consul, consul_server, dcs, node-init]
    consul : Copy consul server service unit	TAGS: [consul, consul_server, dcs, node-init]
    consul : Launch consul server service	TAGS: [consul, consul_server, dcs, node-init]
    consul : Wait for consul server online	TAGS: [consul, consul_server, dcs, node-init]
    consul : Launch consul agent service	TAGS: [consul, consul_agent, dcs, node-init]
    consul : Wait for consul agent online	TAGS: [consul, consul_agent, dcs, node-init]

  play #3 (all): Node Monitor	TAGS: [node-monitor]
  tasks:
    node_exporter : Add yum repo for node_exporter	TAGS: [node-monitor, node_exporter, node_exporter_install]
    node_exporter : Install node_exporter via yum	TAGS: [node-monitor, node_exporter, node_exporter_install]
    node_exporter : Install node_exporter via binary	TAGS: [node-monitor, node_exporter, node_exporter_install]
    node_exporter : Config node_exporter systemd unit	TAGS: [node-monitor, node_exporter, node_exporter_config]
    node_exporter : Config default node_exporter options	TAGS: [node-monitor, node_exporter, node_exporter_config]
    node_exporter : Launch node_exporter systemd unit	TAGS: [node-monitor, node_exporter, node_exporter_launch]
    node_exporter : Wait for node_exporter online	TAGS: [node-monitor, node_exporter, node_exporter_launch]
    node_exporter : Deregister node exporter from prometheus	TAGS: [deregister_prometheus, node-monitor, node_deregister, node_exporter]
    node_exporter : Fetch hostname from server if no node name is given	TAGS: [node-monitor, node_exporter, node_register, register_prometheus]
    node_exporter : Setup nodename according to hostname	TAGS: [node-monitor, node_exporter, node_register, register_prometheus]
    node_exporter : Register node exporter as prometheus target	TAGS: [node-monitor, node_exporter, node_register, register_prometheus]
```

</details>





