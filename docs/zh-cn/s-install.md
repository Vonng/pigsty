
## 太长不看

![](../_media/how-zh.svg)

准备好**新装**机器（Linux x86_64 CentOS 7.8.2003）一台，配置ssh本机访问，以**root**或**sudo**用户执行以下命令。

```bash
# 离线下载（没有Git时可以使用此curl代码下载）
# curl -SL https://github.com/Vonng/pigsty/releases/download/v1.3.0/pigsty.tgz -o ~/pigsty.tgz  
# curl -SL https://github.com/Vonng/pigsty/releases/download/v1.3.0/pkg.tgz    -o /tmp/pkg.tgz

# 常规安装
git clone https://github.com/Vonng/pigsty && cd pigsty
./configure
make install
```

安装完毕后，可通过本地域名 http://g.pigsty 或管理节点3000端口访问Pigsty图形界面。默认管理员：`admin`: `pigsty`。


> 如果您没有可用机器节点，但有可用的Macbook/PC/笔记本，可使用[沙箱环境](s-sandbox.md)在本机自动创建虚拟机。


----------------


## 准备

安装Pigsty需要[准备](t-prepare.md)一个机器节点：规格至少为1核2GB，采用Linux内核，安装CentOS 7发行版，处理器为x86_64架构。并需要一个可以SSH登陆并带有sudo权限的[管理用户](t-prepare.md#管理用户置备)。
该机器将作为 [管理节点](c-arch.md#管理节点)(meta node) ，发出控制命令，采集监控数据，运行定时任务。

**Pigsty默认以单机模式运行在管理节点上**，您可以额外准备任意数量的普通节点，用于部署额外的数据库实例与集群。例如在[Pigsty沙箱](s-sandbox.md) 有一种4节点版本，会使用额外的三个节点部署一套 1主2从 的测试集群 `pg-test`。

在大规模生产环境中，通常会部署3个或更多的管理节点，用于提供冗余。

----------------

## 下载

**源码包 [`pigsty.tgz`](t-prepare.md#pigsty源代码)**

Pigsty的源码包`pigsty.tgz`（约500 KB）是**必选项**，可以通过`curl`、`git`从Github下载。

```bash
git clone https://github.com/Vonng/pigsty && cd pigsty
curl -SL https://github.com/Vonng/pigsty/releases/download/v1.0.0/pigsty.tgz -o ~/pigsty.tgz
```

建议解压于管理用户的家目录中，即：`PIGSTY_HOME=~/pigsty`。

如果您希望使用最新的功能，请使用Git方式拉取代码，如果您希望保持环境稳定，使用`curl`下载固定版本即可。


**软件包 [`pkg.tgz`](t-prepare.md#pigsty离线软件包)**

Pigsty的离线软件包`pkg.tgz`（约1 GB）是**可选项**，可以通过`curl` 从Github下载。

```bash
curl -SL https://github.com/Vonng/pigsty/releases/download/v1.0.0/pkg.tgz    -o /tmp/pkg.tgz
```

放置至目标机器的`/tmp/pkg.tgz`路径下的离线软件包会在配置过程中被自动识别并使用。


**其他下载渠道**

如果没有互联网/Github访问，也可以从其他位置下载，例如百度云盘，详情参考[FAQ](s-faq.md)。

> 无Github访问下载：https://pan.baidu.com/s/1DZIa9X2jAxx69Zj-aRHoaw (提取码: `8su9`）

----------------

## 配置

解压并进入 pigsty 源码目录： `tar -xf pigsty.tgz && cd pigsty`，
执行以下命令即可开始[配置](v-config.md)：

```bash
./configure
```

`configure`会检查下列事项，小问题会自动尝试修复，否则提示报错退出。

```bash
check_kernel     # kernel        = Linux
check_machine    # machine       = x86_64
check_release    # release       = CentOS 7.x
check_sudo       # current_user  = NOPASSWD sudo
check_ssh        # current_user  = NOPASSWD ssh
check_ipaddr     # primary_ip (arg|probe|input)                    (INTERACTIVE: ask for ip)
check_admin      # check current_user@primary_ip nopass ssh sudo
check_mode       # check machine spec to determine node mode (tiny|oltp|olap|crit)
check_config     # generate config according to primary_ip and mode
check_pkg        # check offline installation package exists       (INTERACTIVE: ask for download)
check_repo       # create repo from pkg.tgz if exists
check_repo_file  # create local file repo file if repo exists
check_utils      # check ansible sshpass and other utils installed
check_bin        # check special bin files in pigsty/bin (loki,exporter) (require utils installed)
```

直接运行 `./configure` 将启动交互式命令行向导，提示用户回答以下三个问题：


**IP地址**

当检测到当前机器上有多块网卡与多个IP地址时，配置向导会提示您输入**主要**使用的IP地址，
即您用于从内部网络访问该节点时使用的IP地址。注意请不要使用公网IP地址。

**下载软件包**

当节点的`/tmp/pkg.tgz`路径下未找到离线软件包时，配置向导会询问是否从Github下载。 
选择`Y`即会开始下载，选择`N`则会跳过。如果您的节点有良好的互联网访问与合适的代理配置，或者需要自行制作离线软件包，可以选择`N`。

**配置模板**

使用什么样的配置文件模板。
配置向导会根据当前机器环境**自动选择配置模板**，因此不会询问用户这个问题，用户通常也无需关心。
但用户总是可以通过命令行参数`-m <mode>`手工指定想要使用的配置模板，例如：

* [`demo`]  项目默认配置文件，4节点沙箱使用的配置文件
* [`auto`]  在生产环境中部署时推荐的配置文件模板
* [`pub4`]  Pigsty公开Demo使用的配置文件，使用VPS部署，作为一个实际的样例。

* 更多配置模板，请参考 [Configuration Template](https://github.com/Vonng/pigsty/tree/master/files/conf)





**配置过程的标准输出**

```bash
vagrant@meta:~/pigsty 
$ ./configure
configure pigsty v1.3.0 begin
[ OK ] kernel = Linux
[ OK ] machine = x86_64
[ OK ] release = 7.8.2003 , perfect
[ OK ] sudo = vagrant ok
[ OK ] ssh = vagrant@127.0.0.1 ok
[WARN] Multiple IP address candidates found:
    (1) 10.0.2.15	    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
    (2) 10.10.10.10	    inet 10.10.10.10/24 brd 10.10.10.255 scope global noprefixroute eth1
    (3) 10.10.10.2	    inet 10.10.10.2/8 scope global eth1
[ OK ] primary_ip = 10.10.10.10 (from demo)
[ OK ] admin = vagrant@10.10.10.10 ok
[ OK ] mode = pub4 (manually set)
[ OK ] config = pub4@10.10.10.10
[ OK ] cache = /tmp/pkg.tgz exists
[ OK ] repo = /www/pigsty ok
[ OK ] repo file = /etc/yum.repos.d/pigsty-local.repo
[ OK ] utils = install from local file repo
[ OK ] ansible = ansible 2.9.23
configure pigsty done. Use 'make install' to proceed
```



----------------

## 安装

`make install`会在当前节点安装Pigsty。

```bash
make install
```

它实际上调用Ansible执行[`infra.yml`](p-infra.md)剧本，在`meta`分组上完成安装。

在沙箱环境2核4GB虚拟机中，完整安装耗时约10分钟。

> 在[configure](#配置)的过程中，Ansible已经通过离线软件包`pkg.tgz`或可用yum源安装完毕。


### 访问图形用户界面

安装完成后，您可以通过[图形用户界面](s-interface.md)访问Pigsty相关服务。

> 访问 `http://<primary_ip>:3000` 即可浏览 Pigsty监控系统主页 (用户名: `admin`, 密码: `pigsty`)


### 部署额外数据库集群（可选）

在4节点沙箱中，您可以执行[`pgsql.yml`](p-pgsql)剧本以完成`pg-test`集群的部署：

```bash
./pgsql.yml -l pg-test
```

该剧本执行完后，即可在监控系统中浏览集群详情。[Check Demo](http://demo.pigsty.cc/d/pgsql-cluster/pgsql-cluster?var-cls=pg-test)


### 部署额外日志收集组件（可选）

Pigsty自带了基于Loki与Promtail的实时日志收集解决方案，但默认不会启用，需要时可以通过以下两行命令手工启用。

```bash
./infra-loki.yml         # 在管理节点上安装loki(日志服务器)
./pgsql-promtail.yml     # 在数据库节点上安装promtail (日志Agent)
```

详见[部署日志收集服务](t-logging.md)

