## 本地沙箱

Pigsty提供了一个开箱即用的沙箱环境，可以在普通Mac/PC上运行的完整Pigsty软件。

## 沙箱环境简介

Pigsty沙箱底层依托于是 [Vagrant](https://www.vagrantup.com/) 托管的 [Virtualbox](https://www.virtualbox.org/) 虚拟机（默认：1台，完整模式：4台）。

使用Pigsty沙箱前，您需要在操作系统中安装 Vagrant 与 Virtualbox，两者都是免费的跨平台开源软件。

您也可以选择自己使用喜爱的虚拟机软件（Parallel Desktop，VMWare）自行创建虚拟机，或直接使用云虚拟机，进行[标准安装部署](t-deploy.md)。

Pigsty沙箱有单节点与四节点两种不同规格，单节点沙箱为默认配置。
单节点沙箱则适合用于个人开发、实验、学习；作为数据分析与可视化的环境；以及设计、演示、分发交互式数据应用，
四节点沙箱可以完整演示Pigsty的功能，充分探索高可用架构与监控系统的能力，请您自行按需选择。


## 快速开始

1. 确保 [Vagrant](https://www.vagrantup.com/) 与 [Virtualbox](https://www.virtualbox.org/) 安装并可用，按照官方向导即可（需要重启）。
2. [下载](s-install.md#下载) pigsty 至 **宿主机**，进入pigsty目录，执行 `make start`拉起虚拟机
3. 在宿主机执行 `make demo` 开始自动安装默认的单节点沙箱
4. （可选）添加静态DNS记录以通过域名访问Pigsty Web UI

沙箱可以在 MacOS 操作系统中一键拉起，在Windows与Linux下则需要少量额外手工步骤。
在MacOS中可以使用以下四条`make`快捷方式来安装软件依赖，配置本地静态DNS，拉起虚拟机，并执行安装。

```bash
make deps   # 安装homebrew，并通过homebrew安装vagrant与virtualbox（需重启）
make dns    # 向本机/etc/hosts写入静态域名 (需sudo输入密码)
make start  # 使用Vagrant拉起单个meta节点  (start4则为4个节点)
make demo   # 使用单节点Demo配置并安装     (demo4则为4节点demo)
```



## 沙箱架构说明

沙箱环境使用固定的IP地址，以便于演示说明，单节点沙箱的节点IP地址固定为：`10.10.10.10`。

> 10.10.10.10 是所有配置文件模板中IP地址的占位符，执行普通部署时，该IP地址会被为管理节点的实际IP地址

无论是何种沙箱，都会有一个管理节点`meta`，节点上部署有一个单例Postgres数据库`pg-meta`。

* `meta    10.10.10.10  pg-meta.pg-meta-1`


在四节点沙箱环境中，有三个额外的数据库节点，会部署一套三节点的数据库集群`pg-test`

* `node-1  10.10.10.11  pg-test.pg-test-1`
* `node-2  10.10.10.12  pg-test.pg-test-2`
* `node-3  10.10.10.13  pg-test.pg-test-3`

同时，沙箱环境还会使用以下两个IP地址与两条静态DNS记录，用于接入数据库集群。

* `10.10.10.2  pg-meta`
* `10.10.10.2  pg-test`

整个沙箱环境（四节点）结构如下图所示：

![](../_media/sandbox.svg)

单节点沙箱即没有上图右侧的三个额外节点，只有左半边的单个管理节点。

## 使用4节点沙箱

将拉起沙箱的两条命令替换为以下命令，即可拉起4节点的沙箱环境。

```bash
make start4 
make demo4
```


## 其他操作系统

其他操作系统需要自行下载并安装Vagrant与Virtualbox，配置静态DNS域名，其余步骤与MacOS一致。

```bash
make start && make demo
```



## DNS配置

Pigsty默认通过**域名**访问所有Web系统，沙箱环境使用的静态DNS记录如下所示：

```bash
# pigsty dns records
10.10.10.10  meta     # sandbox meta node
10.10.10.11  node-1   # sandbox node node-1
10.10.10.12  node-2   # sandbox node node-2
10.10.10.13  node-3   # sandbox node node-3
10.10.10.2   pg-meta  # sandbox vip for pg-meta
10.10.10.3   pg-test  # sandbox vip for pg-test

10.10.10.10 pigsty
10.10.10.10 y.pigsty yum.pigsty
10.10.10.10 c.pigsty consul.pigsty
10.10.10.10 g.pigsty grafana.pigsty
10.10.10.10 p.pigsty prometheus.pigsty
10.10.10.10 a.pigsty alertmanager.pigsty
10.10.10.10 n.pigsty ntp.pigsty
10.10.10.10 h.pigsty haproxy.pigsty
10.10.10.10 s.pigsty server.pigsty
```

在MacOS与Linux中，执行`make dns`会将上述记录写入 `/etc/hosts` （需要sudo权限），在Windows中，则需要您手工添加至：`C:\Windows\System32\drivers\etc\hosts`中。