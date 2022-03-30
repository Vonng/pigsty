# Playbook：INFRA

> 使用 `infra` 系列[剧本](p-playbook.md)在当前管理节点上安装Pigsty，并加装可选功能。

| 剧本                                          | 功能                                   | 链接                                                                     |
|---------------------------------------------|--------------------------------------|------------------------------------------------------------------------|
| [`infra`](p-infra.md#infra)                 | 在管理节点上完整安装Pigsty                     | [`src`](https://github.com/vonng/pigsty/blob/master/infra.yml)         |
| [`infra-demo`](p-infra.md#infra-demo)       | 一次性完整初始化四节点演示沙箱环境的特殊剧本               | [`src`](https://github.com/vonng/pigsty/blob/master/infra-demo.yml)    |
| [`infra-remove`](p-infra.md#infra-remove)   | 在管理节点上卸载Pigsty | [`src`](https://github.com/vonng/pigsty/blob/master/infra-remove.yml)  |
| [`infra-jupyter`](p-infra.md#infra-jupyter) | 在管理节点上加装**可选**数据分析服务组件组件Jupyter Lab  | [`src`](https://github.com/vonng/pigsty/blob/master/infra-jupyter.yml) |
| [`infra-pgweb`](p-infra.md#infra-pgweb)     | 在管理节点上加装**可选**的Web客户端工具PGWeb         | [`src`](https://github.com/vonng/pigsty/blob/master/infra-pgweb.yml)   |








---------------

## `infra`

[`infra.yml`](https://github.com/Vonng/pigsty/blob/master/infra.yml) 剧本会在**管理节点** （默认为当前节点）上完成**Pigsty**的安装与部署。

当您将Pigsty用作开箱即用的数据库时，只要在本节点上直接执行 `infra.yml` ，即可完成安装。

![](_media/playbook/infra.svg)

### What

执行该剧本将完成以下任务

* 配置管理节点的目录与环境变量
* 下载并建立一个本地yum软件源，加速后续安装。（若使用离线软件包，则跳过下载阶段）
* 将当前管理节点作为一个[普通节点](p-nodes.md)纳入 Pigsty 管理
* 部署**基础设施**组件，包括 Prometheus, Grafana, Loki, Alertmanager, Consul Server等
* 在当前节点上部署一个普通的[PostgreSQL](p-pgsql.md)单实例集群，纳入监控。

### Where

该剧本默认针对**管理节点**执行

* Pigsty默认将使用**当前执行此剧本的节点**作为Pigsty的管理节点。
* Pigsty在Configure过程中默认会将当前节点标记为管理节点，并使用**当前节点首要IP地址**替换配置模板中的占位IP地址`10.10.10.10`。
* **管理节点**除了可以发起管理，部署有基础设施外。与一个部署了PG的普通托管节点并无区别。
* Pigsty默认使用管理节点部署DCS Server，用于数据库高可用，但您完全可以选用外部DCS集群。
* 使用多个管理节点是可能的，参考 [DCS3](https://github.com/Vonng/pigsty/blob/master/files/conf/pigsty-dcs3.yml#L33) 配置模板：部署3节点的DCS Server，允许其中一台宕机。

### How

执行该剧本的一些注意事项

* 本剧本为幂等剧本，重复执行会抹除管理节点上的Consul Server与CMDB（关闭保护选项情况下）
* 使用离线软件包时，完整执行该剧本耗时约5-8分钟，视机器配置而异。
* 不使用离线软件包而直接从互联网原始上游下载软件时，可能耗时10-20分钟，根据您的网络条件而异。
* 本剧本会将管理节点作为一个普通节点纳入管理，并部署PG数据库，覆盖了[`nodes.yml`](p-nodes.md) 与[`pgsql.yml`](p-pgsql.md)的所有内容，因此`infra.yml`如果可以在管理节点上成功执行完毕，那么则在相同状态的普通节点上一定可以成功完成数据库部署。
* 管理节点上默认的[`pg-meta`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml#L43)将用作Pigsty元数据库，用于承载高级特性。


### Tasks

该剧本
```bash
./infra.yml --tags=environ                       # 重新在管理节点上配置环境
./infra.yml --tags=repo -e repo_rebuild=true     # 强制重新创建本地源
./infra.yml --tags=repo_upstream                 # 加入上游YumRepo
./infra.yml --tags=prometheus                    # 重新创建Prometheus
./infra.yml --tags=nginx_config,nginx_restart    # 重新生成Nginx配置文件并重启
……
```



在[配置清单](v-config.md)中，隶属于 `meta`分组下的节点将被设置 [`meta_node`](v-meta#meta_node) 标记，用作 Pigsty 的管理节点。








---------------

## `infra-demo`

[`infra-demo.yml`](https://github.com/Vonng/pigsty/blob/master/infra-demo.yml) 是用于演示环境的特殊剧本，通过交织管理节点与普通节点初始化的方式，可以一次性完成4节点沙箱环境的初始化。
在四节点沙箱中，本剧本可等效为

```bash
./infra.yml              # 在管理节点安装 Pigsty
./infra-pgweb.yml        # 在管理节点加装 PgWeb
./infra-jupyter.yml      # 在管理节点加装 Jupyter
./nodes.yml -l pg-test   # 将 pg-test 所属三节点纳入管理
./pgsql.yml -l pg-test   # 在 pg-test 三节点上部署数据库集群
```

此外，当您尝试部署复数个管理节点时，如果选择默认将DCS Server部署在所有管理节点上时，也可以使用此剧本一次性拉起所有管理节点以及其上的DCS与数据库集群。

请注意，配置不当的情况下，此剧本有一次性抹平整个环境的奇效，在生产环境可以移除以避免 "Fat Finger" 的风险。

![](_media/playbook/infra-demo.svg)







---------------

## `infra-remove`

[`infra-remove.yml`](https://github.com/Vonng/pigsty/blob/master/infra-remove.yml) 剧本是 [infra](#infra) 剧本的反向操作。

会将Pigsty从管理节点卸载，剧本会依次卸载下列组件。

![](_media/playbook/infra-remove.svg)

- grafana-server
- prometheus
- alertmanager
- node_exporter
- consul
- jupyter
- pgweb
- loki
- promtail




---------------

## `infra-jupyter`

[`infra-jupyter.yml`](https://github.com/Vonng/pigsty/blob/master/infra-jupyter.yml) 剧本用于在管理节点上加装 Jupyter Lab服务

Jupyter Lab 是非常实用的Python数据分析环境，但自带WebShell，风险较大。因此默认情况下，Demo环境，单机配置模板中会启用 JupyterLab，生产环境部署模版中默认不会启用JupyterLab

请参照：[配置:Jupyter](v-infra.md#JUPYTER) 中的说明调整配置清单，然后执行此剧本即可。

```bash
./infra-jupyter.yml
```


!> 如果您在生产环境中启用了Jupyter，请务必修改Jupyter的密码



---------------

## `infra-pgweb`

PGWeb 是基于浏览器的PostgreSQL客户端工具，可用于小批量个人数据查询等场景。目前为可选Beta功能，默认只在Demo中启用

[`infra-pgweb.yml`](https://github.com/Vonng/pigsty/blob/master/infra-pgweb.yml) 剧本用于在管理节点上加装 PGWeb 服务。

请参照：[配置: PGWEB](v-infra.md#PGWEB) 中的说明调整配置清单，然后执行此剧本即可。

```bash
./infra-pgweb.yml
```











