# 数据库集群初始化

> 如何定义并拉起PostgreSQL数据库集群


## 剧本概览

完成了[**基础设施初始化**](p-infra.md)后，用户可以[ `pgsql.yml`](https://github.com/Vonng/pigsty/blob/master/pgsql.yml) 完成数据库集群的**初始化**。

首先在 **Pigsty配置文件** 中完成数据库集群的定义，然后通过执行`pgsql.yml`将变更应用至实际环境中。

```bash
./pgsql.yml                      # 在所有清单中的机器上执行数据库集群初始化操作（危险！）
./pgsql.yml -l pg-test           # 在 pg-test 分组下的机器执行数据库集群初始化（推荐！）
./pgsql.yml -l pg-meta,pg-test   # 同时初始化pg-meta与pg-test两个集群
./pgsql.yml -l 10.10.10.11       # 初始化10.10.10.11这台机器上的数据库实例
```

!> **该剧本使用不当存在误删数据库的风险，因为初始化数据库会抹除原有数据库的痕迹**。
[保险参数](#保护机制)提供了避免误删的选项作为保险，允许以在初始化过程中，当检测到已有运行中实例时自动中止或跳过高危操作，避免最坏情况发送。尽管如此，在**使用`pgsql.yml`时，请再三检查`--tags|-t` 与 `--limit|-l` 参数是否正确。确保自己在正确的目标上执行正确的任务。使用不带参数的`pgsql.yml`在生产环境中是一个高危操作，务必三思而后行。**



![](../_media/playbook/pgsql.svg)



## 注意事项

* 强烈建议在执行时添加`-l`参数，限制命令执行的对象范围。

* **单独**针对某一集群从库执行初始化时，用户必须自行确保**主库已经完成初始化**

* 集群扩容时，如果`Patroni`拉起从库的时间过长，Ansible剧本可能会因为超时而中止。（但制作从库的进程会继续，例如需要制作从库需超过1天的场景）。您可以在从库自动制作完毕后，通过Ansible的`--start-at-task`从`Wait for patroni replica online`任务继续执行后续步骤。


## 保护机制

`pgsql.yml`提供**保护机制**，由配置参数`pg_exists_action`决定。当执行剧本前会目标机器上有正在运行的PostgreSQL实例时，Pigsty会根据`pg_exists_action`的配置`abort|clean|skip`行动。

* `abort`：建议设置为默认配置，如遇现存实例，中止剧本执行，避免误删库。
* `clean`：建议在本地沙箱环境使用，如遇现存实例，清除已有数据库。
* `skip`：  直接在已有数据库集群上执行后续逻辑。
* 您可以通过`./pgsql.yml -e pg_exists_action=clean`的方式来覆盖配置文件选项，强制抹掉现有实例

`pg_disable_purge`选项提供了双重保护，如果启用该选项，则``pg_exists_action`会被强制设置为`abort`，在任何情况下都不会抹掉运行中的数据库实例。

``dcs_exists_action`与`dcs_disable_purge`与上述两个选项效果一致，但针对DCS（Consul Agent）实例。



## 选择性执行

用户可以通过ansible的标签机制，可以选择执行剧本的一个子集。

举个例子，如果只想执行服务初始化的部分，则可以通过以下命令进行

```bash
./pgsql.yml --tags=service      # 刷新集群的服务定义
```

常用的命令子集如下：

```bash
# 基础设施初始化
./pgsql.yml --tags=infra        # 完成基础设施的初始化，包括机器节点初始化与DCS部署

./pgsql.yml --tags=node         # 完成机器节点的初始化，通常不会影响运行中数据库实例
./pgsql.yml --tags=dcs          # 完成DCS：consul/etcd的初始化
./pgsql.yml --tags=dcs -e dcs_exists_action # 完成consul/etcd的初始化，强制抹除

# 数据库初始化
./pgsql.yml --tags=pgsql        # 完成数据库部署：数据库、监控、服务

./pgsql.yml --tags=postgres     # 完成数据库部署
./pgsql.yml --tags=monitor      # 完成监控的部署
./pgsql.yml --tags=service      # 完成负载均衡的部署，（Haproxy & VIP）
./pgsql.yml --tags=register     # 将服务注册至基础设施
```



## 日常管理任务

日常管理也可以使用`./pgsql.yml`来修改数据库集群的状态，常用的命令子集如下：

```bash
./pgsql.yml --tags=node_admin           # 在目标节点上创建管理员用户
# 如果当前管理员没有ssh至目标节点的权限，可以使用其他具有ssh的用户创建管理员（输入密码）
./pgsql.yml --tags=node_admin -e ansible_user=other_admin -k 

./pgsql.yml --tags=pg_scripts           # 更新/pg/bin/目录脚本
./pgsql.yml --tags=pg_hba               # 重新生成并应用集群HBA规则
./pgsql.yml --tags=pgbouncer            # 重置Pgbouncer
./pgsql.yml --tags=pg_user              # 全量刷新业务用户
./pgsql.yml --tags=pg_db                # 全量刷新业务数据库

./pgsql.yml --tags=register_consul      # 在目标实例本地注册Consul服务(本地执行)
./pgsql.yml --tags=register_prometheus  # 在Prometheus中注册监控对象(代理至所有Meta节点执行)
./pgsql.yml --tags=register_grafana     # 在Grafana中注册监控对象(只注册一次)
./pgsql.yml --tags=register_nginx       # 在Nginx注册负载均衡器(代理至所有Meta节点执行)

# 使用二进制安装的方式重新部署监控
./pgsql.yml --tags=monitor -e exporter_install=binary

# 刷新集群的服务定义（当集群成员或服务定义发生变化时执行）
./pgsql.yml --tags=haproxy_config,haproxy_reload
```



## 剧本说明

[`pgsql.yml`](https://github.com/Vonng/pigsty/blob/master/pgsql.yml) 主要完成以下工作：

* 初始化数据库节点基础设施（`node`）
* 初始化DCS Agent（服务（`consul`）（如果为当前节点为管理节点，则初始化为DCS Server）
* 安装、部署、初始化PostgreSQL， Pgbouncer， Patroni（`postgres`）
* 安装PostgreSQL监控系统（`monitor`）
* 安装部署Haproxy与VIP，对外暴露服务（`service`）
* 将数据库实例注册至基础设施，接受监管（`register`）

精确到任务的标签请参考[**任务详情**](#任务详情)

```yaml
#!/usr/bin/env ansible-playbook
---
#==============================================================#
# File      :   pgsql.yml
# Mtime     :   2020-05-12
# Mtime     :   2021-03-15
# Desc      :   initialize pigsty cluster
# Path      :   pgsql.yml
# Copyright (C) 2018-2021 Ruohang Feng
#==============================================================#


#------------------------------------------------------------------------------
# init node and database
#------------------------------------------------------------------------------
- name: Pgsql Initialization
  become: yes
  hosts: all
  gather_facts: no
  roles:

    - role: node                            # init node
      tags: [infra, node]

    - role: consul                          # init consul
      tags: [infra, dcs]

    - role: postgres                        # init postgres
      tags: [pgsql, postgres]

    - role: monitor                         # init monitor system
      tags: [pgsql, monitor]

    - role: service                         # init service
      tags: [service]

...

```





## 任务详情

使用以下命令可以列出数据库集群初始化的所有任务，以及可以使用的标签：

```bash
./pgsql.yml --list-tasks
```

默认任务如下：

<details>

```yaml
playbook: ./pgsql.yml

  play #1 (all): Infra Init	TAGS: [infra]
    tasks:
      node : Update node hostname	TAGS: [infra, node, node_name]
      node : Add new hostname to /etc/hosts	TAGS: [infra, node, node_name]
      node : Write static dns records	TAGS: [infra, node, node_dns]
      node : Get old nameservers	TAGS: [infra, node, node_resolv]
      node : Write tmp resolv file	TAGS: [infra, node, node_resolv]
      node : Write resolv options	TAGS: [infra, node, node_resolv]
      node : Write additional nameservers	TAGS: [infra, node, node_resolv]
      node : Append existing nameservers	TAGS: [infra, node, node_resolv]
      node : Swap resolv.conf	TAGS: [infra, node, node_resolv]
      node : Node configure disable firewall	TAGS: [infra, node, node_firewall]
      node : Node disable selinux by default	TAGS: [infra, node, node_firewall]
      node : Backup existing repos	TAGS: [infra, node, node_repo]
      node : Install upstream repo	TAGS: [infra, node, node_repo]
      node : Install local repo	TAGS: [infra, node, node_repo]
      node : Install node basic packages	TAGS: [infra, node, node_pkgs]
      node : Install node extra packages	TAGS: [infra, node, node_pkgs]
      node : Install meta specific packages	TAGS: [infra, node, node_pkgs]
      node : Install node basic packages	TAGS: [infra, node, node_pkgs]
      node : Install node extra packages	TAGS: [infra, node, node_pkgs]
      node : Install meta specific packages	TAGS: [infra, node, node_pkgs]
      node : Install pip3 packages on meta node	TAGS: [infra, node, node_pip, node_pkgs]
      node : Node configure disable numa	TAGS: [infra, node, node_feature]
      node : Node configure disable swap	TAGS: [infra, node, node_feature]
      node : Node configure unmount swap	TAGS: [infra, node, node_feature]
      node : Node setup static network	TAGS: [infra, node, node_feature]
      node : Node configure disable firewall	TAGS: [infra, node, node_feature]
      node : Node configure disk prefetch	TAGS: [infra, node, node_feature]
      node : Enable linux kernel modules	TAGS: [infra, node, node_kernel]
      node : Enable kernel module on reboot	TAGS: [infra, node, node_kernel]
      node : Get config parameter page count	TAGS: [infra, node, node_tuned]
      node : Get config parameter page size	TAGS: [infra, node, node_tuned]
      node : Tune shmmax and shmall via mem	TAGS: [infra, node, node_tuned]
      node : Create tuned profiles	TAGS: [infra, node, node_tuned]
      node : Render tuned profiles	TAGS: [infra, node, node_tuned]
      node : Active tuned profile	TAGS: [infra, node, node_tuned]
      node : Change additional sysctl params	TAGS: [infra, node, node_tuned]
      node : Copy default user bash profile	TAGS: [infra, node, node_profile]
      node : Setup node default pam ulimits	TAGS: [infra, node, node_ulimit]
      node : Create os user group admin	TAGS: [infra, node, node_admin]
      node : Create os user admin	TAGS: [infra, node, node_admin]
      node : Grant admin group nopass sudo	TAGS: [infra, node, node_admin]
      node : Add no host checking to ssh config	TAGS: [infra, node, node_admin]
      node : Add admin ssh no host checking	TAGS: [infra, node, node_admin]
      node : Fetch all admin public keys	TAGS: [infra, node, node_admin]
      node : Exchange all admin ssh keys	TAGS: [infra, node, node_admin]
      node : Install public keys	TAGS: [infra, node, node_admin, node_admin_pks]
      node : Install current public key	TAGS: [infra, node, node_admin, node_admin_pk_current]
      node : Install ntp package	TAGS: [infra, node, ntp_install]
      node : Install chrony package	TAGS: [infra, node, ntp_install]
      node : Setup default node timezone	TAGS: [infra, node, ntp_config]
      node : Copy the ntp.conf file	TAGS: [infra, node, ntp_config]
      node : Copy the chrony.conf template	TAGS: [infra, node, ntp_config]
      node : Launch ntpd service	TAGS: [infra, node, ntp_launch]
      node : Launch chronyd service	TAGS: [infra, node, ntp_launch]
      consul : Check for existing consul	TAGS: [consul, consul_check, dcs, infra]
      consul : Consul exists flag fact set	TAGS: [consul, consul_check, dcs, infra]
      consul : Abort due to consul exists	TAGS: [consul, consul_check, dcs, infra]
      consul : Clean existing consul instance	TAGS: [consul, consul_clean, dcs, infra]
      consul : Stop any running consul instance	TAGS: [consul, consul_clean, dcs, infra]
      consul : Remove existing consul dir	TAGS: [consul, consul_clean, dcs, infra]
      consul : Recreate consul dir	TAGS: [consul, consul_clean, dcs, infra]
      consul : Make sure consul is installed	TAGS: [consul, consul_install, dcs, infra]
      consul : Make sure consul dir exists	TAGS: [consul, consul_config, dcs, infra]
      consul : Get dcs server node names	TAGS: [consul, consul_config, dcs, infra]
      consul : Get dcs node name from var nodename	TAGS: [consul, consul_config, dcs, infra]
      consul : Get dcs node name from pgsql ins name	TAGS: [consul, consul_config, dcs, infra]
      consul : Fetch hostname as dcs node name	TAGS: [consul, consul_config, dcs, infra]
      consul : Get dcs name from hostname	TAGS: [consul, consul_config, dcs, infra]
      consul : Copy /etc/consul.d/consul.json	TAGS: [consul, consul_config, dcs, infra]
      consul : Copy consul agent service	TAGS: [consul, consul_config, dcs, infra]
      consul : Get dcs bootstrap expect quroum	TAGS: [consul, consul_server, dcs, infra]
      consul : Copy consul server service unit	TAGS: [consul, consul_server, dcs, infra]
      consul : Launch consul server service	TAGS: [consul, consul_server, dcs, infra]
      consul : Wait for consul server online	TAGS: [consul, consul_server, dcs, infra]
      consul : Launch consul agent service	TAGS: [consul, consul_agent, dcs, infra]
      consul : Wait for consul agent online	TAGS: [consul, consul_agent, dcs, infra]

  play #2 (all): Pgsql Init	TAGS: [pgsql]
    tasks:
      postgres : Create os group postgres	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Make sure dcs group exists	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Create dbsu {{ pg_dbsu }}	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Grant dbsu nopass sudo	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Grant dbsu all sudo	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Grant dbsu limited sudo	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Config watchdog onwer to dbsu	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Add dbsu ssh no host checking	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Fetch dbsu public keys	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Exchange dbsu ssh keys	TAGS: [instal, pg_dbsu, pgsql, postgres]
      postgres : Install offical pgdg yum repo	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Install pg packages	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Install pg extensions	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Link /usr/pgsql to current version	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Add pg bin dir to profile path	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Fix directory ownership	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Remove default postgres service	TAGS: [instal, pg_install, pgsql, postgres]
      postgres : Check necessary variables exists	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Fetch variables via pg_cluster	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Set cluster basic facts for hosts	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Assert cluster primary singleton	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Setup cluster primary ip address	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Setup repl upstream for primary	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Setup repl upstream for replicas	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Debug print instance summary	TAGS: [always, pg_preflight, pgsql, postgres, preflight]
      postgres : Check for existing postgres instance	TAGS: [pg_check, pgsql, postgres, prepare]
      postgres : Set fact whether pg port is open	TAGS: [pg_check, pgsql, postgres, prepare]
      postgres : Abort due to existing postgres instance	TAGS: [pg_check, pgsql, postgres, prepare]
      postgres : Clean existing postgres instance	TAGS: [pg_check, pgsql, postgres, prepare]
      postgres : Shutdown existing postgres service	TAGS: [pg_clean, pgsql, postgres, prepare]
      postgres : Remove registerd consul service	TAGS: [pg_clean, pgsql, postgres, prepare]
      postgres : Remove postgres metadata in consul	TAGS: [pg_clean, pgsql, postgres, prepare]
      postgres : Remove existing postgres data	TAGS: [pg_clean, pgsql, postgres, prepare]
      postgres : Make sure main and backup dir exists	TAGS: [pg_dir, pgsql, postgres, prepare]
      postgres : Create postgres directory structure	TAGS: [pg_dir, pgsql, postgres, prepare]
      postgres : Create pgbouncer directory structure	TAGS: [pg_dir, pgsql, postgres, prepare]
      postgres : Create links from pgbkup to pgroot	TAGS: [pg_dir, pgsql, postgres, prepare]
      postgres : Create links from current cluster	TAGS: [pg_dir, pgsql, postgres, prepare]
      postgres : Copy pg_cluster to /pg/meta/cluster	TAGS: [pg_meta, pgsql, postgres, prepare]
      postgres : Copy pg_version to /pg/meta/version	TAGS: [pg_meta, pgsql, postgres, prepare]
      postgres : Copy pg_instance to /pg/meta/instance	TAGS: [pg_meta, pgsql, postgres, prepare]
      postgres : Copy pg_seq to /pg/meta/sequence	TAGS: [pg_meta, pgsql, postgres, prepare]
      postgres : Copy pg_role to /pg/meta/role	TAGS: [pg_meta, pgsql, postgres, prepare]
      postgres : Copy postgres scripts to /pg/bin/	TAGS: [pg_scripts, pgsql, postgres, prepare]
      postgres : Copy alias profile to /etc/profile.d	TAGS: [pg_scripts, pgsql, postgres, prepare]
      postgres : Copy psqlrc to postgres home	TAGS: [pg_scripts, pgsql, postgres, prepare]
      postgres : Setup hostname to pg instance name	TAGS: [pg_hostname, pgsql, postgres, prepare]
      postgres : Copy consul node-meta definition	TAGS: [pg_nodemeta, pgsql, postgres, prepare]
      postgres : Restart consul to load new node-meta	TAGS: [pg_nodemeta, pgsql, postgres, prepare]
      postgres : Get config parameter page count	TAGS: [pg_config, pgsql, postgres]
      postgres : Get config parameter page size	TAGS: [pg_config, pgsql, postgres]
      postgres : Tune shared buffer and work mem	TAGS: [pg_config, pgsql, postgres]
      postgres : Hanlde small size mem occasion	TAGS: [pg_config, pgsql, postgres]
      postgres : Calculate postgres mem params	TAGS: [pg_config, pgsql, postgres]
      postgres : create patroni config dir	TAGS: [pg_config, pgsql, postgres]
      postgres : use predefined patroni template	TAGS: [pg_config, pgsql, postgres]
      postgres : Render default /pg/conf/patroni.yml	TAGS: [pg_config, pgsql, postgres]
      postgres : Link /pg/conf/patroni to /pg/bin/	TAGS: [pg_config, pgsql, postgres]
      postgres : Link /pg/bin/patroni.yml to /etc/patroni/	TAGS: [pg_config, pgsql, postgres]
      postgres : Config patroni watchdog support	TAGS: [pg_config, pgsql, postgres]
      postgres : Copy patroni systemd service file	TAGS: [pg_config, pgsql, postgres]
      postgres : create patroni systemd drop-in dir	TAGS: [pg_config, pgsql, postgres]
      postgres : Copy postgres systemd service file	TAGS: [pg_config, pgsql, postgres]
      postgres : Drop-In systemd config for patroni	TAGS: [pg_config, pgsql, postgres]
      postgres : Launch patroni on primary instance	TAGS: [pg_primary, pgsql, postgres]
      postgres : Wait for patroni primary online	TAGS: [pg_primary, pgsql, postgres]
      postgres : Wait for postgres primary online	TAGS: [pg_primary, pgsql, postgres]
      postgres : Check primary postgres service ready	TAGS: [pg_primary, pgsql, postgres]
      postgres : Check replication connectivity on primary	TAGS: [pg_primary, pgsql, postgres]
      postgres : Render init roles sql	TAGS: [pg_init, pg_init_role, pgsql, postgres]
      postgres : Render init template sql	TAGS: [pg_init, pg_init_tmpl, pgsql, postgres]
      postgres : Render default pg-init scripts	TAGS: [pg_init, pg_init_main, pgsql, postgres]
      postgres : Execute initialization scripts	TAGS: [pg_init, pg_init_exec, pgsql, postgres]
      postgres : Check primary instance ready	TAGS: [pg_init, pg_init_exec, pgsql, postgres]
      postgres : Add dbsu password to pgpass if exists	TAGS: [pg_pass, pgsql, postgres]
      postgres : Add system user to pgpass	TAGS: [pg_pass, pgsql, postgres]
      postgres : Check replication connectivity to primary	TAGS: [pg_replica, pgsql, postgres]
      postgres : Launch patroni on replica instances	TAGS: [pg_replica, pgsql, postgres]
      postgres : Wait for patroni replica online	TAGS: [pg_replica, pgsql, postgres]
      postgres : Wait for postgres replica online	TAGS: [pg_replica, pgsql, postgres]
      postgres : Check replica postgres service ready	TAGS: [pg_replica, pgsql, postgres]
      postgres : Render hba rules	TAGS: [pg_hba, pgsql, postgres]
      postgres : Reload hba rules	TAGS: [pg_hba, pgsql, postgres]
      postgres : Pause patroni	TAGS: [pg_patroni, pgsql, postgres]
      postgres : Stop patroni on replica instance	TAGS: [pg_patroni, pgsql, postgres]
      postgres : Stop patroni on primary instance	TAGS: [pg_patroni, pgsql, postgres]
      postgres : Launch raw postgres on primary	TAGS: [pg_patroni, pgsql, postgres]
      postgres : Launch raw postgres on replicas	TAGS: [pg_patroni, pgsql, postgres]
      postgres : Wait for postgres online	TAGS: [pg_patroni, pgsql, postgres]
      postgres : Check pgbouncer is installed	TAGS: [pgbouncer, pgbouncer_check, pgsql, postgres]
      postgres : Stop existing pgbouncer service	TAGS: [pgbouncer, pgbouncer_clean, pgsql, postgres]
      postgres : Remove existing pgbouncer dirs	TAGS: [pgbouncer, pgbouncer_clean, pgsql, postgres]
      postgres : Recreate dirs with owner postgres	TAGS: [pgbouncer, pgbouncer_clean, pgsql, postgres]
      postgres : Copy /etc/pgbouncer/pgbouncer.ini	TAGS: [pgbouncer, pgbouncer_config, pgbouncer_ini, pgsql, postgres]
      postgres : Copy /etc/pgbouncer/pgb_hba.conf	TAGS: [pgbouncer, pgbouncer_config, pgbouncer_hba, pgsql, postgres]
      postgres : Touch userlist and database list	TAGS: [pgbouncer, pgbouncer_config, pgsql, postgres]
      postgres : Add default users to pgbouncer	TAGS: [pgbouncer, pgbouncer_config, pgsql, postgres]
      postgres : Init pgbouncer business database list	TAGS: [pgbouncer, pgbouncer_config, pgbouncer_db, pgsql, postgres]
      postgres : Init pgbouncer business user list	TAGS: [pgbouncer, pgbouncer_config, pgbouncer_user, pgsql, postgres]
      postgres : Copy pgbouncer systemd service	TAGS: [pgbouncer, pgbouncer_launch, pgsql, postgres]
      postgres : Launch pgbouncer pool service	TAGS: [pgbouncer, pgbouncer_launch, pgsql, postgres]
      postgres : Wait for pgbouncer service online	TAGS: [pgbouncer, pgbouncer_launch, pgsql, postgres]
      postgres : Check pgbouncer service is ready	TAGS: [pgbouncer, pgbouncer_launch, pgsql, postgres]
      include_tasks	TAGS: [pg_user, pgsql, postgres]
      include_tasks	TAGS: [pg_db, pgsql, postgres]
      postgres : Reload pgbouncer to add db and users	TAGS: [pgbouncer_reload, pgsql, postgres]
      monitor : Install exporter yum repo	TAGS: [exporter_install, exporter_yum_install, monitor, pgsql]
      monitor : Install node_exporter and pg_exporter	TAGS: [exporter_install, exporter_yum_install, monitor, pgsql]
      monitor : Copy exporter binaries	TAGS: [exporter_binary_install, exporter_install, monitor, pgsql]
      monitor : Create /etc/pg_exporter conf dir	TAGS: [monitor, pg_exporter, pgsql]
      monitor : Copy default pg_exporter.yaml	TAGS: [monitor, pg_exporter, pgsql]
      monitor : Config /etc/default/pg_exporter	TAGS: [monitor, pg_exporter, pgsql]
      monitor : Config pg_exporter service unit	TAGS: [monitor, pg_exporter, pgsql]
      monitor : Launch pg_exporter systemd service	TAGS: [monitor, pg_exporter, pgsql]
      monitor : Wait for pg_exporter service online	TAGS: [monitor, pg_exporter, pgsql]
      monitor : Config pgbouncer_exporter opts	TAGS: [monitor, pgbouncer_exporter, pgsql]
      monitor : Config pgbouncer_exporter service	TAGS: [monitor, pgbouncer_exporter, pgsql]
      monitor : Launch pgbouncer_exporter service	TAGS: [monitor, pgbouncer_exporter, pgsql]
      monitor : Wait for pgbouncer_exporter online	TAGS: [monitor, pgbouncer_exporter, pgsql]
      monitor : Copy node_exporter systemd service	TAGS: [monitor, node_exporter, pgsql]
      monitor : Config default node_exporter options	TAGS: [monitor, node_exporter, pgsql]
      monitor : Launch node_exporter service unit	TAGS: [monitor, node_exporter, pgsql]
      monitor : Wait for node_exporter online	TAGS: [monitor, node_exporter, pgsql]
      service : Make sure haproxy is installed	TAGS: [haproxy, haproxy_install, pgsql, service]
      service : Create haproxy directory	TAGS: [haproxy, haproxy_install, pgsql, service]
      service : Copy haproxy systemd service file	TAGS: [haproxy, haproxy_install, haproxy_unit, pgsql, service]
      service : Fetch postgres cluster memberships	TAGS: [haproxy, haproxy_config, pgsql, service]
      service : Templating /etc/haproxy/haproxy.cfg	TAGS: [haproxy, haproxy_config, pgsql, service]
      service : Launch haproxy load balancer service	TAGS: [haproxy, haproxy_launch, haproxy_restart, pgsql, service]
      service : Wait for haproxy load balancer online	TAGS: [haproxy, haproxy_launch, pgsql, service]
      service : Reload haproxy load balancer service	TAGS: [haproxy, haproxy_reload, pgsql, service]
      service : Make sure vip-manager is installed	TAGS: [pgsql, service, vip, vip_l2_install]
      service : Copy vip-manager systemd service file	TAGS: [pgsql, service, vip, vip_l2_install]
      service : create vip-manager systemd drop-in dir	TAGS: [pgsql, service, vip, vip_l2_install]
      service : create vip-manager systemd drop-in file	TAGS: [pgsql, service, vip, vip_l2_install]
      service : Templating /etc/default/vip-manager.yml	TAGS: [pgsql, service, vip, vip_l2_config, vip_manager_config]
      service : Launch vip-manager	TAGS: [pgsql, service, vip, vip_l2_reload]
      service : Fetch postgres cluster memberships	TAGS: [pgsql, service, vip, vip_l4_config]
      service : Render L4 VIP configs	TAGS: [pgsql, service, vip, vip_l4_config]
      include_tasks	TAGS: [pgsql, service, vip, vip_l4_reload]
      register : Register postgres service to consul	TAGS: [pgsql, postgres, register, register_consul, register_consul_postgres]
      register : Register patroni service to consul	TAGS: [pgsql, postgres, register, register_consul, register_consul_patroni]
      register : Register pgbouncer service to consul	TAGS: [pgbouncer, pgsql, register, register_consul, register_consul_pgbouncer]
      register : Register node-exporter service to consul	TAGS: [node_exporter, pgsql, register, register_consul, register_consul_node_exporter]
      register : Register pg_exporter service to consul	TAGS: [pg_exporter, pgsql, register, register_consul, register_consul_pg_exporter]
      register : Register pgbouncer_exporter service to consul	TAGS: [pgbouncer_exporter, pgsql, register, register_consul, register_consul_pgbouncer_exporter]
      register : Register haproxy (exporter) service to consul	TAGS: [haproxy, pgsql, register, register_consul, register_consul_haproxy_exporter]
      register : Register cluster service to consul	TAGS: [haproxy, pgsql, register, register_consul, register_consul_cluster_service]
      register : Reload consul to finish register	TAGS: [pgsql, register, register_consul, register_consul_reload]
      register : Register pgsql instance as prometheus target	TAGS: [pgsql, register, register_prometheus]
      register : Render datasource definition on meta node	TAGS: [pgsql, register, register_grafana]
      register : Load grafana datasource on meta node	TAGS: [pgsql, register, register_grafana]
      register : Create haproxy config dir resource dirs on /etc/pigsty	TAGS: [pgsql, register, register_nginx]
      register : Register haproxy upstream to nginx	TAGS: [pgsql, register, register_nginx]
      register : Register haproxy url location to nginx	TAGS: [pgsql, register, register_nginx]
      register : Reload nginx to finish haproxy register	TAGS: [pgsql, register, register_nginx]

```

</details>

