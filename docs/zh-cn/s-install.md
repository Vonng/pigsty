
## 一键拉起

![](../_media/how-zh.svg)

```bash
# 离线下载
# curl -SL https://github.com/Vonng/pigsty/releases/download/v1.0.0/pigsty.tgz -o ~/pigsty.tgz  
# curl -SL https://github.com/Vonng/pigsty/releases/download/v1.0.0/pkg.tgz    -o /tmp/pkg.tgz

# 常规安装
git clone https://github.com/Vonng/pigsty && cd pigsty
./configure
make install
```

更详细的过程，与预期的结果，请参考下面的介绍。



## 准备

安装Pigsty需要一个机器节点：规格至少为1核2GB，采用Linux内核，安装CentOS 7发行版，处理器为x86_64架构。
该机器将作为 **管理节点(meta node)** ，发出控制命令，采集监控数据，运行定时任务。

## 下载

**源码包`pigsty.tgz`**

Pigsty的源码包`pigsty.tgz`（约500 KB）是**必选项**，可以通过`curl`、`git`从Github下载。

```bash
git clone https://github.com/Vonng/pigsty && cd pigsty
curl -SL https://github.com/Vonng/pigsty/releases/download/v1.0.0/pigsty.tgz -o ~/pigsty.tgz
```

建议解压于管理用户的家目录中，即：`PIGSTY_HOME=~/pigsty`

**软件包`pkg.tgz`**

Pigsty的离线软件包`pkg.tgz`（约1 GB）是**可选项**，可以通过`curl` 从Github下载。

```bash
curl -SL https://github.com/Vonng/pigsty/releases/download/v1.0.0/pkg.tgz    -o /tmp/pkg.tgz
```

放置至目标机器的`/tmp/pkg.tgz`路径下的离线软件包会在配置过程中被自动识别并使用。


**其他下载渠道**

如果没有互联网/Github访问，也可以从其他位置下载，例如百度云盘，详情参考[FAQ](s-faq.md)。



## 配置

解压并进入 pigsty 源码目录： `tar -xf pigsty.tgz && cd pigsty`，执行以下命令即可开始配置：

```bash
./configure
```

执行`configure`会检查下列事项，小问题可直接修复。

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

配置向导会根据当前机器环境**自动选择配置模板**，但用户可以通过`-m <mode>`手工指定使用但配置模板，例如：

* [`demo4`]  项目默认配置文件，4节点沙箱
* [`demo`]   单节点沙箱，若检测到当前为沙箱虚拟机，会使用此配置
* [`tiny`]   单节点部署，若使用普通节点（微型: cpu < 8）部署，会使用此配置
* [`oltp`]   生产单节点部署，若使用普通节点（高配：cpu >= 8）部署，会使用此配置
* 更多配置模板，请参考 [Configuration Template](https://github.com/Vonng/pigsty/tree/master/files/conf)

**配置过程的标准输出**

```bash
vagrant@meta:~/pigsty
$ ./configure
configure pigsty v1.0.0-alpha2 begin
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
[ OK ] mode = demo (vagrant demo)
[ OK ] config = demo@10.10.10.10
[ OK ] cache = /tmp/pkg.tgz exists
[ OK ] repo = /www/pigsty ok
[ OK ] repo file = /etc/yum.repos.d/pigsty-local.repo
[ OK ] utils = install from local file repo
[ OK ] ansible = ansible 2.9.23
[ OK ] bin = extract from /www/pigsty
[ OK ] loki @ /home/vagrant/pigsty/files/bin
configure pigsty done. Use 'make install' to proceed
```



## 安装

```bash
make instsall
```

在`./configure`的过程中，Ansible已经通过离线软件包或可用yum源安装完毕。

`make install`会调用Ansible执行`infra.yml`剧本，在`meta`分组上完成安装。

在沙箱环境2核4GB虚拟机中，完整安装耗时约10分钟。

安装完成后，您可以通过[**用户界面**](s-interface.md)访问Pigsty相关服务。


> 访问 `http://<node_ip>:3000` 即可浏览 Pigsty监控系统[主页](http://g.pigsty.cc/d/home)
> 
> (用户名: `admin`, 密码: `pigsty`)