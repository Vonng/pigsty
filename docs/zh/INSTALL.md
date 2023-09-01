# 快速上手

> 安装 Pigsty 四步走: [下载](#下载)，[准备](#准备)，[配置](#配置)，以及[安装](#安装)。


----------------

## 简短版本

准备一个使用 Linux x86_64 EL 7，8，9 兼容系统的全新节点，使用带有免密 `sudo` 权限的用户执行：

```bash
curl https://get.pigsty.cc/latest | bash
```

该命令会[下载](#下载)并解压 Pigsty 源码至家目录，按提示完成 [准备](#准备)，[配置](#配置)，[安装](#安装)三个步骤即可完成安装。

```bash
cd ~/pigsty      # 进入 Pigsty 源码目录，完成后续 准备、配置、安装 三个步骤
./bootstrap      # 确保 Ansible 正常安装，如果存在 /tmp/pkg.tgz 离线软件包，便使用它。
./configure      # 执行环境检测，并生成相应的推荐配置文件，如果你知道如何配置 Pigsty 可以跳过
./install.yml    # 根据生成的配置文件开始在当前节点上执行安装，使用离线安装包大概需要10分钟完成
```

安装完成后，您可以通过域名或`80/443`端口通过 Nginx 访问 WEB 界面，通过 `5432` 端口访问默认的 PostgreSQL 数据库服务。

[![asciicast](https://asciinema.org/a/566220.svg)](https://asciinema.org/a/566220)


<details><summary>一键安装脚本</summary>

```bash
$ curl https://get.pigsty.cc/latest | bash
...
[Checking] ===========================================
[ OK ] SOURCE from CDN due to GFW
FROM CDN    : bash -c "$(curl -fsSL https://get.pigsty.cc/latest)"
FROM GITHUB : bash -c "$(curl -fsSL https://raw.githubusercontent.com/Vonng/pigsty/master/bin/get)"
[Downloading] ===========================================
[ OK ] download pigsty source code from CDN
[ OK ] $ curl -SL https://get.pigsty.cc/v2.3.0/pigsty-v2.3.0.tgz
...
MD5: abcdef1234567890abcdef1234567890  /tmp/pigsty-v2.3.0.tgz
[Extracting] ===========================================
[ OK ] extract '/tmp/pigsty-v2.3.0.tgz' to '/root/pigsty'
[ OK ] $ tar -xf /tmp/pigsty-v2.3.0.tgz -C ~;
cd ~/pigsty      # entering pigsty home directory before proceeding
[Proceeding] ===========================================
./bootstrap      # install ansible & download the optional offline packages
./configure      # preflight-check and generate config according to your env
./install.yml    # install pigsty on this node and init it as the admin node
[Reference] ===========================================
Get Started:     https://doc.pigsty.cc/#/INSTALL
Documentation:   https://doc.pigsty.cc
Github Repo:     https://github.com/Vonng/pigsty
Public Demo:     https://demo.pigsty.cc
Official Site:   https://pigsty.cc
```

</details>

<details><summary>Git检出安装</summary>

你也可以使用 `git` 来下载安装 Pigsty 源代码，不要忘了检出特定的版本。

```bash
git clone https://github.com/Vonng/pigsty;   # 您科学上网了吗？
cd pigsty; git checkout v2.3.0
```

</details>



----------------

## 环境要求

**操作系统**

* Linux RHEL 或其他兼容的操作系统发行版
* 供应商: RedHat, CentOS, Rocky, AlmaLinux, ……
* 系统版本：el7, el8, el9, 或其他兼容的版本
* 企业级订阅中提供对信创操作系统（例如：统信 UOS v20）的专门支持
* 请使用全新的节点，以避免无谓的麻烦，1核云虚拟机也就几毛钱一小时。
* 建议使用 RockyLinux 9.1 / RockyLinux 8.7 / CentOS 7.9 ，这是 Pigsty 构建与测试环境使用的版本。

**机器节点**

* 需为 `x86_64` 架构 (目前暂不支持 `aarch64`/`arm` 等架构)
* 管理节点最低 1核2G，配置将自动根据节点规格优化
* 普通节点最低 1核1G，推荐 2C4G 以上，配置将自动根据节点规格优化
* 需要有公钥免密的 `ssh` 访问，且在目标节点上有免密`sudo`或`root`权限，包括当前节点。
* 一个严肃的生产部署最少需要三个节点，目前最大部署规模为 1000+ 节点。

**Ansible**

* Ansible是Pigsty的依赖的核心组件之一，会在 [Bootstrap/准备](#准备) 过程中自动安装
* 您也可以使用 `yum` 直接手动安装，但需要先启用 `epel-release` 源。
* 如果使用了离线软件包，Ansible会从离线软件包中安装。




----------------

## 下载

您可以使用以下命令获取 Pigsty 源码包：

```bash
curl https://get.pigsty.cc/latest  | bash
```

> 提示: 如果您需要下载最新的测试版本（Alpha/Beta/RC），请使用 `beta` 替代 `latest`


如果您的安装环境没有互联网访问，您也可以提前下载好特定版本的源码包，用各种方式（FTP/SCP/USB/CDROM）上传至目标服务器。

```bash
# 从 CDN 或 Github 下载源码包
curl -L https://get.pigsty.cc/v2.3.0/pigsty-v2.3.0.tgz -o ~/pigsty.tgz
curl -L https://github.com/Vonng/pigsty/releases/download/v2.3.0/pigsty-v2.3.0.tgz -o ~/pigsty.tgz

# 如果 curl 不可用，git clone 也可以
git clone https://github.com/Vonng/pigsty; cd pigsty; git checkout v2.3.0
```

### 离线软件包

正常情况下，Pigsty 会从互联网上游下载所需的 RPM 包，但如果您的安装环境没有互联网访问，您可以提前下载好特定版本的离线软件包手工上传。

离线软件包可以极快地加速 Pigsty 的安装过程，省却几十分钟的下载时间，对于没有互联网访问的环境更是有用。它里面包含了 Pigsty 所需的软件及其依赖，大小约为 1GB 。

Pigsty 会在 [Bootstrap/准备](#准备) 时，提示下载对应的离线软件包，您也可以手工下载对应系统的离线软件包以加速安装。下载后的软件包应当放置于 `/tmp/pkg.tgz`。

```bash
# CDN EL 7,8,9
curl -L https://get.pigsty.cc/v2.3.0/pigsty-v2.3.0.tgz -o ~/pigsty.tgz                 # 源码
curl -L https://get.pigsty.cc/v2.3.0/pigsty-pkg-v2.3.0.el9.x86_64.tgz -o /tmp/pkg.tgz  # EL9
curl -L https://get.pigsty.cc/v2.3.0/pigsty-pkg-v2.3.0.el8.x86_64.tgz -o /tmp/pkg.tgz  # EL8
curl -L https://get.pigsty.cc/v2.3.0/pigsty-pkg-v2.3.0.el7.x86_64.tgz -o /tmp/pkg.tgz  # EL7

# GITHUB EL 7,8,9
curl -L https://github.com/Vonng/pigsty/releases/download/v2.3.0/pigsty-v2.3.0.tgz -o ~/pigsty.tgz                 # 源码
curl -L https://github.com/Vonng/pigsty/releases/download/v2.3.0/pigsty-pkg-v2.3.0.el9.x86_64.tgz -o /tmp/pkg.tgz  # EL9
curl -L https://github.com/Vonng/pigsty/releases/download/v2.3.0/pigsty-pkg-v2.3.0.el8.x86_64.tgz -o /tmp/pkg.tgz  # EL8
curl -L https://github.com/Vonng/pigsty/releases/download/v2.3.0/pigsty-pkg-v2.3.0.el7.x86_64.tgz -o /tmp/pkg.tgz  # EL7
```





----------------

## 准备

准备 （`bootstrap`） 脚本的核心任务是确保：`ansible` 能用，并尽可能尝试使用离线软件包搭建本地 Yum 源。

Bootstrap 过程会用各种方式安装 `ansible`，如果需要的话，会提示您下载离线软件包（Ansible本身亦包含其中）。

```bash
./boostrap [-p <path>=/tmp/pkg.tgz]   # 离线软件包的下载地址 (默认是/tmp/pkg.tgz，通常不需修改)
           [-y|--yes] [-n|--no]       # 直接决定 是/否 下载离线软件包 (如果不指定，会交互式询问)
```

> 提示: 如果您决定直接从上游（互联网）安装所有软件包，`bootstrap` 过程是可选的。

Bootstrap 的详细逻辑如下：

1. 检查安装的前提条件是否满足

2. 检查本地离线安装包（`/tmp/pkg.tgz`）是否存在？
* 是 -> 解压到 `/www/pigsty` 并通过 `/etc/yum.repos.d/pigsty-local.repo` 来启用它
* 否 -> 进一步决定是否从互联网下载离线软件包？
    * 是 -> 从 Github 或 CDN 下载离线软件包并解压
    * 否 -> 是否添加操作系统基础的上游源地址以供从互联网下载 ?
        * 是 -> 根据地区与EL版本写入对应的上游源：`/etc/yum.repos.d/`
        * 否 -> 用户自己搞定，或者当前系统的默认配置就带有 Ansible
    * 现在，我们有了一个可用的 yum repo，可以用来安装 pigsty 所需的软件包了，特别是 Ansible。
    * 优先级顺序: 本地的 `pkg.tgz` > 下载的 `pkg.tgz` > 原始上游 > 默认配置

3. 从上一步配置的软件源中，安装一些基本的重要软件，不同版本的软件略有不同：
  * el7: `ansible createrepo_c unzip wget yum-utils sshpass`
  * el8: `ansible python3.11-jmespath createrepo_c unzip wget dnf-utils sshpass modulemd-tools`
  * el9: `ansible python3.11-jmespath createrepo_c unzip wget dnf-utils sshpass modulemd-tools`

4. 检查 `ansible` 是否成功安装。



<details><summary>从本地离线软件包 Bootstrap 的样例输出</summary>

如果离线软件包存在于 `/tmp/pkg.tgz`， bootstrap 会直接使用它：

```bash
bootstrap pigsty v2.3.0 begin
[ OK ] region = china
[ OK ] kernel = Linux
[ OK ] machine = x86_64
[ OK ] release = 7.9.2009
[ OK ] sudo = vagrant ok
[ OK ] cache = /tmp/pkg.tgz exists
[ OK ] repo = extract from /tmp/pkg.tgz
[ OK ] repo file = use /etc/yum.repos.d/pigsty-local.repo
[ OK ] repo cache = created
[ OK ] install el7 utils
....(yum install ansible output)
[ OK ] ansible = ansible 2.9.27
[ OK ] boostrap pigsty complete
proceed with ./configure
```

</details>

<details><summary>从互联网下载离线软件包的 Bootstrap 样例输出</summary>

从 Github/CDN 下载 `pkg.tgz` 并解压使用：

```bash
bootstrap pigsty v2.3.0 begin
[ OK ] region = china
[ OK ] kernel = Linux
[ OK ] machine = x86_64
[ OK ] release = 7.9.2009
[ OK ] sudo = vagrant ok
[ IN ] Cache /tmp/pkg.tgz not exists, download? (y/n):
=> y
[ OK ] download from Github https://get.pigsty.cc/v2.3.0/pigsty-pkg-v2.3.0.el7.x86_64.tgz to /tmp/pkg.tgz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  913M  100  913M    0     0   661k      0  0:23:33  0:23:33 --:--:--  834k
[ OK ] repo = extract from /tmp/pkg.tgz
[ OK ] repo file = use /etc/yum.repos.d/pigsty-local.repo
[ OK ] repo cache = created
[ OK ] install el7 utils
...... (yum install createrepo_c sshpass unzip output)
==================================================================================================================
 Package                        Arch                Version                       Repository                 Size
==================================================================================================================
Installing:
 createrepo_c                   x86_64              0.10.0-20.el7                 pigsty-local               65 k
 sshpass                        x86_64              1.06-2.el7                    pigsty-local               21 k
 unzip                          x86_64              6.0-24.el7_9                  pigsty-local              172 k
Installing for dependencies:
 createrepo_c-libs              x86_64              0.10.0-20.el7                 pigsty-local               89 k

Transaction Summary
==================================================================================================================
...... (yum install ansible output)
==================================================================================================================
 Package                                      Arch            Version                 Repository             Size
==================================================================================================================
Installing:
 ansible                                      noarch          2.9.27-1.el7            pigsty-local           17 M
Installing for dependencies:
 PyYAML                                       x86_64          3.10-11.el7             pigsty-local          153 k
 libyaml                                      x86_64          0.1.4-11.el7_0          pigsty-local           55 k
 python-babel                                 noarch          0.9.6-8.el7             pigsty-local          1.4 M
 python-backports                             x86_64          1.0-8.el7               pigsty-local          5.8 k
 python-backports-ssl_match_hostname          noarch          3.5.0.1-1.el7           pigsty-local           13 k
 python-cffi                                  x86_64          1.6.0-5.el7             pigsty-local          218 k
 python-enum34                                noarch          1.0.4-1.el7             pigsty-local           52 k
 python-idna                                  noarch          2.4-1.el7               pigsty-local           94 k
 python-ipaddress                             noarch          1.0.16-2.el7            pigsty-local           34 k
 python-jinja2                                noarch          2.7.2-4.el7             pigsty-local          519 k
 python-markupsafe                            x86_64          0.11-10.el7             pigsty-local           25 k
 python-paramiko                              noarch          2.1.1-9.el7             pigsty-local          269 k
 python-ply                                   noarch          3.4-11.el7              pigsty-local          123 k
 python-pycparser                             noarch          2.14-1.el7              pigsty-local          104 k
 python-setuptools                            noarch          0.9.8-7.el7             pigsty-local          397 k
 python-six                                   noarch          1.9.0-2.el7             pigsty-local           29 k
 python2-cryptography                         x86_64          1.7.2-2.el7             pigsty-local          502 k
 python2-httplib2                             noarch          0.18.1-3.el7            pigsty-local          125 k
 python2-jmespath                             noarch          0.9.4-2.el7             pigsty-local           41 k
 python2-pyasn1                               noarch          0.1.9-7.el7             pigsty-local          100 k

Transaction Summary
==================================================================================================================
...
Complete!
[ OK ] ansible = ansible 2.9.27
[ OK ] boostrap pigsty complete
proceed with ./configure
```

</details>





----------------

## 配置

配置 / [`configure`](CONFIG.md) 会根据您当前的环境，自动生成推荐的（单机安装） [`pigsty.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml) 配置文件。

提示: 如果您已经了解了如何配置 Pigsty， `configure` 这个步骤是可选的，可以跳过。

```bash
./configure [-n|--non-interactive] [-i|--ip <ipaddr>] [-m|--mode <name>] [-r|--region <default|china|europe>]
```

* `-m|--mode`: 直接指定配置[模板](https://github.com/Vonng/pigsty/tree/master/files/pigsty) : (`auto|demo|sec|citus|el8|el9|prod...`)
* `-i|--ip`: 用于替换IP地址占位符 `10.10.10.10` 的IP地址，即当前主机的首要内网IP地址（特别是在有多块网卡与多个IP地址时）
* `-r|--region`: 用于指定上游源的区域： (`default|china|europe`)
* `-n|--non-interactive`: 直接使用命令行参数提供首要IP地址，跳过交互式向导。

当使用 `-n|--non-interactive` 参数时，您需要使用 `-i|--ip <ipaddr>` 指定当前节点的首要IP地址，特别是在有多块网卡与多个IP地址时。

请注意，在一个严肃的生产部署中，您应当修改配置文件中所有 `password` 类的参数。

<details><summary>configure 的样例输出</summary>

```bash
[vagrant@meta pigsty]$ ./configure
configure pigsty v2.3.0 begin
[ OK ] region = china
[ OK ] kernel = Linux
[ OK ] machine = x86_64
[ OK ] sudo = vagrant ok
[ OK ] ssh = vagrant@127.0.0.1 ok
[WARN] Multiple IP address candidates found:
    (1) 10.0.2.15	    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
    (2) 10.10.10.10	    inet 10.10.10.10/24 brd 10.10.10.255 scope global noprefixroute eth1
[ OK ] primary_ip = 10.10.10.10 (from demo)
[ OK ] admin = vagrant@10.10.10.10 ok
[ OK ] mode = demo (vagrant demo)
[ OK ] config = demo @ 10.10.10.10
[ OK ] ansible = ansible 2.9.27
[ OK ] configure pigsty done
proceed with ./install.yml
```

</details>





----------------

## 安装

使用 [`install.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml) 剧本，默认在当前节点上完成标准的单节点 Pigsty 安装。

```bash
./install.yml    # install everything in one-pass
```

这是一个标准的 Ansible 剧本，您可以使用以下参数控制其执行的目标、任务、并传递额外的命令参数：

* `-l`: 限制执行的目标对象
* `-t`: 限制要执行的任务
* `-e`: 传入额外的命令行参数
* ...

> 警告： 在已经初始化的环境中再次运行 `install.yml` 会重置整个环境，所以请小心谨慎。
>
> 您可以 `chmod a-x install.yml` 避免误执行此剧本。


<details><summary>安装过程的样例输出</summary>

```bash
[vagrant@meta pigsty]$ ./install.yml

PLAY [IDENTITY] ********************************************************************************************************************************

TASK [node_id : get node fact] *****************************************************************************************************************
changed: [10.10.10.12]
changed: [10.10.10.11]
changed: [10.10.10.13]
changed: [10.10.10.10]
...
...
PLAY RECAP **************************************************************************************************************************************************************************
10.10.10.10                : ok=288  changed=215  unreachable=0    failed=0    skipped=64   rescued=0    ignored=0
10.10.10.11                : ok=263  changed=194  unreachable=0    failed=0    skipped=88   rescued=0    ignored=1
10.10.10.12                : ok=263  changed=194  unreachable=0    failed=0    skipped=88   rescued=0    ignored=1
10.10.10.13                : ok=153  changed=121  unreachable=0    failed=0    skipped=53   rescued=0    ignored=1
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0
```

</details>




----------------

## 用户界面

当安装完成后，当前节点会安装有四个模块： [**INFRA**](INFRA.md), [**NODE**](NODE.md), [**ETCD**](ETCD.md) , [**PGSQL**](PGSQL.md) 。

* [**INFRA**](INFRA.md): Pigsty Web界面可以通过 80 端口访问 `http://<ip>:80`: 
* [**PGSQL**](PGSQL.md): 您可以使用默认连接串[访问](PGSQL-SVC.md#单机用户)PGSQL数据库:

```bash
psql postgres://dbuser_dba:DBUser.DBA@10.10.10.10/meta     # 直接用 DBA 超级用户连上去
psql postgres://dbuser_meta:DBUser.Meta@10.10.10.10/meta   # 用默认的业务管理员用户连上去
psql postgres://dbuser_view:DBUser.View@pg-meta/meta       # 用默认的只读用户走实例域名连上去
```

一些基础设施服务组件会使用 Nginx 对外暴露 WebUI ( 可通过参数 [`infra_portal`](PARAM.md#infra_portal) 进行配置):

|      组件      |  端口  |     域名     | 说明               | Demo地址                                     |
|:------------:|:----:|:----------:|------------------|--------------------------------------------|
|    Nginx     |  80  | `h.pigsty` | Web 服务总入口，本地YUM源 | [`home.pigsty.cc`](http://home.pigsty.cc)  |
| AlertManager | 9093 | `a.pigsty` | 告警聚合/屏蔽页面        | [`a.pigsty.cc`](http://a.pigsty.cc)        |
|   Grafana    | 3000 | `g.pigsty` | Grafana 监控面板     | [`demo.pigsty.cc`](https://demo.pigsty.cc) |
|  Prometheus  | 9090 | `p.pigsty` | Prometheus 管理界面  | [`p.pigsty.cc`](http://p.pigsty.cc)        |


您可以通过 IP地址 + 端口的方式直接访问这些服务，也可以通过域名来访问。我们强烈建议您通过 Nginx 域名代理访问所有组件，并对所有的端口权限进行访问控制，以避免未经授权的访问。

使用域名访问 Pigsty WebUI 时，您需要配置 DNS 服务器，或者修改 `/etc/hosts` 文件， 如果您使用本地沙箱， `sudo make dns` 会将所需的本地域名写入 `/etc/hosts`

例如，当您使用 `http://g.pigsty` 访问 Grafana 监控主页时，实际上是通过 Nginx 代理访问了 Grafana 的 WebUI：

```
http://g.pigsty ️-> http://10.10.10.10:80 (nginx) -> http://10.10.10.10:3000 (grafana)
```

> Grafana 的默认密码为: username: `admin`, password: `pigsty`



<details><summary> 如何使用 HTTPS 访问 Pigsty WebUI </summary><br>

Pigsty默认使用自动生成的自签名的CA证书为Nginx启用SSL，如果您希望使用 HTTPS 访问这些页面，而不弹窗提示"不安全"，通常有三个选择：

* 在您的浏览器或操作系统中信任Pigsty自签名的CA证书： `files/pki/ca/ca.crt`
* 如果您使用 Chrome，可以在提示不安全的窗口键入 `thisisunsafe` 跳过提示
* 您可以考虑使用 Let's Encrypt 或其他免费的CA证书服务，为 Pigsty Nginx 生成正式的CA证书

</details>



----------------

## 更多

你可以使用 Pigsty 部署更多的集群，管理更多的节点，例如

```bash
bin/node-add   pg-test      # 将集群 pg-test 的3个节点纳入 Pigsty 管理
bin/pgsql-add  pg-test      # 初始化一个3节点的 pg-test 高可用PG集群
bin/redis-add  redis-ms     # 初始化 Redis 集群： redis-ms
```

更多细节请参见： [**PGSQL**](PGSQL.md), [**NODE**](NODE.md), and [**REDIS**](REDIS.md).