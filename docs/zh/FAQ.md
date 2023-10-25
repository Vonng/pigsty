# 常见问题

> 这里列出了Pigsty用户常遇到的问题，如果您遇到了难以解决的问题，可以提交 [Issue](https://github.com/Vonng/pigsty/issues/new) 或者 [联系我们](overview#about)。


----------------

## 准备

<br>
<details><summary>操作系统建议</summary><br>

Pigsty 支持 EL 7/8/9，Debian 11/12，Ubuntu 20/22 等主流操作系统，我们建议您使用全新精简安装的操作系统，避免无谓的软件冲突问题。
Pigsty 离线软件包构建使用的操作系统版本为： CentOS 7.9, Rocky 8.7，Rocky 9.1，Ubuntu 22.04 / 20.04，Debian 12 / 11。

对于EL系操作系统，我们建议用户选择 RockyLinux 8.8 作为首选操作系统，CentOS 7.9 与 Rocky 9.2 作为保守、激进的备选。
其他EL系兼容操作系统也可使用，例如 AlmaLinux，Oracle Linux，CentOS Stream，但可能会出现少量 RPM 冲突问题，建议不使用离线软件包，直接从互联网上游安装。

对于 Ubuntu / Debian 系列操作系统，Pigsty 在 v2.5.0 提供了初步支持，尚未在大规模生产环境中得到验证，请谨慎使用，欢迎随时反馈问题。
如果您需要使用到一些特殊的软件包，例如 RDKit，或者 PostgresML + CUDA，以及 AI 相关的组件，那么 Ubuntu 是不二之选。
我们建议使用 Ubuntu 22.04 jammy (LTS)，也提供对 Ubuntu 20.04 focal (LTS) 的支持。Debian 建议使用 12 (bookworm) 或 11 (bullseye)。

国产操作系统中，我们建议使用 OpenAnolis 8.8 （RHCK），完全兼容 EL8 的软件包，无需额外适配。
在[企业级服务协议](SUPPORT.md)中，我们也提供对信创国产操作系统的额外付费支持（例如OpenEuler/UOS）。

- 当您看重这些特性时，选择 EL 系操作系统：
  - 最充分的测试与稳定性验证，大规模使用案例
  - 希望使用本地托管的 Supbase （目前依赖的重要扩展仅在 EL 发行版中提供）
  - 建议使用 Rocky 8.8 或等效兼容发行版，也支持 EL 9；EL 7 支持但不建议使用，即将 EOL。

- 当您看重这些特性时，选择 Ubuntu 系操作系统
  - 深度使用 PostgresML ，希望使用 CUDA
  - 希望使用 Nvidia GPU CUDA，RDKit 等 Ubuntu 专有软件包
  - 建议使用 Ubuntu 22.04 jammy，也支持 Ubuntu 20.04 focal

- 当您看重这些特性时，选择 Debian 系操作系统
  - 喜欢由开源社区主导的 Linux 发行版
  - 建议使用 Debian 12 bookworm ，也支持 Debian 11 bullseye

| 代码  | 操作系统发行版 / PG 大版本                  | PG16 | PG15 | PG14 | PG13 | PG12 | 局限性                                          |
|:---:|-----------------------------------|:----:|:----:|:----:|:----:|:----:|----------------------------------------------|
| EL7 | RHEL7 / CentOS7                   |  ⚠️  |  ⭐️  |  ✅   |  ✅   |  ✅   | PG16, supabase, pg_graphql, pgml, pg_net 不可用 |
| EL8 | RHEL 8 / Rocky8 / Alma8 / Anolis8 |  ✅   |  ⭐️  |  ✅   |  ✅   |  ✅   | **EL功能标准集**                                  |
| EL9 | RHEL 9 / Rocky9 / Alma9           |  ✅   |  ⭐️  |  ✅   |  ✅   |  ✅   | pgxnclient 缺失                                |
| D11 | Debian 11 (bullseye)              |  ✅   |  ⭐️  |  ✅   |  ✅   |  ✅   | RDKit 不可用                                    |
| D12 | Ubuntu 12 (bookworm)              |  ✅   |  ⭐️  |  ✅   |  ✅   |  ✅   | **Debian功能标准集**                              |
| U20 | Ubuntu 20.04 (focal)              |  ✅   |  ⭐️  |  ✅   |  ✅   |  ✅   | PostGIS, RDKit 不可用                           |
| U22 | Ubuntu 22.04 (jammy)              |  ✅   |  ⭐️  |  ✅   |  ✅   |  ✅   | **Ubuntu功能标准集**                              |


</details><br>





<details><summary>机器节点要求</summary><br>

CPU架构：目前仅支持 `x86_64` 架构，尚未提供`ARM`支持。

硬件规格：普通节点至少 **1核1G** ，基础设施节点建议使用 **2核4G**，1核1G也可以但容易OOM。

对于严肃的生产应用，建议至少准备 3～4 台至少2核4G规格的节点用于部署。

</details><br>


<details><summary>版本发布策略</summary><br>

Pigsty 使用语义化版本号，例如：`<主版本>.<次版本>.<修订号>`。Alpha/Beta/RC 版本会在版本号后添加后缀，如 `-a1`, `-b1`, `-rc1`。

主版本更新意味着基础性变化和大量新特性；次版本更新通常表示新特性，软件包版本更新和较小的API变动，修订版本更新意味着修复bug和文档更新。

Pigsty 每1-2年发布一次主版本更新，次版本更新通常跟随 PostgreSQL 小版本更新节奏，在 PostgreSQL 新版本发布后最迟一个月内跟进。

Pigsty 使用 master 主干分支进行开发，请始终使用特定版本的 [发行版](https://github.com/Vonng/pigsty/releases)。

除非您知道自己在做什么，否则不要使用GitHub的 `master` 分支。

</details><br>




----------------

## 下载


<br>
<details><summary>如何获取Pigsty软件源码包？</summary><br>

使用以下命令一键安装 Pigsty： `bash -c "$(curl -fsSL https://get.pigsty.cc/latest)"`

上述命令会自动下载最新的稳定版本 `pigsty.tgz` 并解压到 `~/pigsty` 目录。您也可以从以下位置手动下载 Pigsty 源代码的特定版本。

如果您需要在没有互联网的环境中安装，可以提前在有网络的环境中下载好，并通过 scp/sftp 或者 CDROM/USB 传输至生产服务器。

</details><br>



<details><summary>如何加速从上游仓库下载 RPM ?</summary><br>

考虑使用本地仓库镜像，仓库镜像在[`repo_upstream`](param#repo_upstream) 参数中配置，你可以选择 [`region`](param#region) 来使用不同镜像站。

例如，您可以设置 `region` = `china`，这样将使用 `baseurl` 中键为 `china` 的 URL 而不是 `default`。

如果防火墙或GFW屏蔽了某些仓库，考虑使用[`proxy_env`](param#proxy_env) 来绕过。

</details><br>



<details><summary>哪里可以下载 Pigsty 的离线软件包？</summary><br>

离线包可以在[准备/`bootstrap`](install#bootstrap) 过程中提示下载，或者您也可以直接通过以下链接从 GitHub 上下载：

```bash
https://github.com/Vonng/pigsty/releases/download/v2.5.0/pigsty-v2.5.0.tgz                   # 源代码包
https://github.com/Vonng/pigsty/releases/download/v2.5.0/pigsty-pkg-v2.5.0.el7.x86_64.tgz    # el7离线包
https://github.com/Vonng/pigsty/releases/download/v2.5.0/pigsty-pkg-v2.5.0.el8.x86_64.tgz    # el8离线包
https://github.com/Vonng/pigsty/releases/download/v2.5.0/pigsty-pkg-v2.5.0.el9.x86_64.tgz    # el9离线包
```

中国大陆用户可以考虑使用 CDN 下载：

```bash
https://get.pigsty.cc/v2.5.0/pigsty-v2.5.0.tgz                   # 源代码
https://get.pigsty.cc/v2.5.0/pigsty-pkg-v2.5.0.el7.x86_64.tgz    # el7离线包
https://get.pigsty.cc/v2.5.0/pigsty-pkg-v2.5.0.el8.x86_64.tgz    # el8离线包
https://get.pigsty.cc/v2.5.0/pigsty-pkg-v2.5.0.el9.x86_64.tgz    # el9离线包
```

</details><br>



----------------

## 配置


<br>
<details><summary>准备 / bootstrap 过程是干什么的？</summary><br>

检测环境是否就绪、用各种手段确保后续安装所必需的工具 `ansible` 被正确安装。

当你下载 Pigsty 源码后，可以进入目录并执行 [`bootstrap`](INSTALL#准备) 脚本。它会检测你的节点环境，如果没有发现离线软件包，它会询问你要不要从互联网下载。

你可以选择“是”，直接使用离线软件包安装又快又稳定。你也可以选“否”跳过，选择后面在安装过程中直接从互联网上游下载，这样会下载最新的软件版本，而且几乎不会遇到 RPM 冲突问题。

如果使用了离线软件包，bootstrap 会直接从离线软件包中安装 ansible，否则会从上游下载 ansible 并安装，如果你没有互联网访问，又没有 DVD，或者内网软件源，那就只能用离线软件包来安装了。

</details>



<br>
<details><summary>配置 / configure 过程是干什么的？</summary><br>

配置 / [**configure**](INSTALL#配置) 过程会检测你的节点环境并为你生成一个 pigsty 配置文件：`pigsty.yml`，默认根据你的操作系统（EL 7/8/9）选用相应的单机安装模板。

所有默认的配置模板都在 `files/pigsty`中，你可以使用 `-m` 直接指定想要使用的配置模板。如果您已经知道如何配置 Pigsty 了，那么完全可以跳过这一步，直接编辑 Pigsty 配置文件。

</details>



<br>
<details><summary>Pigsty配置文件是干什么的？</summary><br>

Pigsty主目录下的 `pigsty.yml` 是默认的配置文件，可以用来描述整套部署的环境，在 [`files/pigsty`](https://github.com/Vonng/pigsty/tree/master/files/pigsty) 有许多配置示例供你参考。

当执行剧本时，你可以使用 `-i <path>` 参数，选用其他位置的配置文件。例如，你想根据另一个专门的配置文件 `redis.yml` 来安装 redis：`./redis.yml -i files/pigsty/redis.yml`

</details>



<br>
<details><summary>如何使用 CMDB 作为配置清单？</summary><br>

默认的配置文件路径在 [`ansible.cfg`](https://github.com/Vonng/pigsty/blob/master/ansible.cfg) 中指定为：`inventory = pigsty.yml`

你可以使用 [`bin/inventory_cmdb`](https://github.com/Vonng/pigsty/blob/master/bin/inventory_cmdb) 切换到动态的 CMDB 清单，
使用 [`bin/inventory_conf`](https://github.com/Vonng/pigsty/blob/master/bin/inventory_conf) 返回到本地配置文件。
你还需要使用 [`bin/inventory_load`](https://github.com/Vonng/pigsty/blob/master/bin/inventory_load) 将当前的配置文件清单加载到 CMDB。

如果使用 CMDB，你必须从数据库而不是配置文件中编辑清单配置，这种方式适合将 Pigsty 与外部系统相集成。

</details>




<br>
<details><summary>配置文件中的IP地址占位符是干什么的？</summary><br>

Pigsty 使用 `10.10.10.10` 作为当前节点 IP 的占位符，配置过程中会用当前节点的主 IP 地址替换它。

当 `configure` 检测到当前节点有多个 NIC 带有多个 IP 时，配置向导会提示使用哪个**主要** IP，即 **用户用于从内部网络访问节点的 IP**，此 IP 将用于在配置文件模板中替换占位符 `10.10.10.10`。

请注意：不要使用公共 IP 作为主 IP，因为 Pigsty 会使用主 IP 来配置内部服务，例如 Nginx，Prometheus，Grafana，Loki，AlertManager，Chronyd，DNSMasq 等，除了 Nginx 之外的服务不应该对外界暴露端口。

</details>



<br>
<details><summary>配置文件中的哪些参数需要用户特殊关注？</summary><br>

Pigsty 提供了 280+ 配置参数，可以对整个环境与各个模块 infra/node/etcd/minio/pgsql 进行细致入微的定制。

通常在单节点安装中，你不需要对默认生成的配置文件进行任何调整。但如果需要，可以关注以下这些参数：

- 当访问 web 服务组件时，域名由 [`infra_portal`](param#infra_portal) 指定，有些服务只能通过 Nginx 代理使用域名访问。
- Pigsty 假定存在一个 `/data` 目录用于存放所有数据；如果数据磁盘的挂载点与此不同，你可以使用 [`node_data`](param#node_data) 调整这些路径。
- 进行生产部署时，不要忘记在配置文件中更改**密码**，更多细节请参考 [安全考量](security)。

</details>




----------------

## 安装


<br>
<details><summary>在默认单机安装时，到底都安装了什么东西？</summary><br>

当您执行 `make install` 时，实际上是调用 Ansible 剧本 [`install.yml`](https://github.com/Vonng/pigsty/blob/master/install.yml)，根据配置文件中的参数，安装以下内容：

- `INFRA` 模块：提供本地软件源，Nginx Web接入点，DNS服务器，NTP服务器，Prometheus与Grafana可观测性技术栈。
- `NODE` 模块，将当前节点纳入 Pigsty 管理，部署 HAProxy 与 监控。
- `ETCD` 模块，部署一个单机 etcd 集群，作为 PG 高可用的 DCS
- `MINIO` 模块是默认不安装的，它可以作为 PG 的备份仓库。
- `PGSQL` 模块，一个单机 PostgreSQL 数据库实例。

</details>



<br>
<details><summary>安装遇到RPM冲突怎么办？</summary><br>

在安装 node/infra/pgsql 软件包期间，可能有微小的几率出现 rpm 冲突。特别是，如果您使用的 EL 7-9 小版本不同于 7.9, 8.7, 9.1 ，或者使用了一些冷门换皮魔改发行版的话，可能会出现这种情况。

解决这个问题的最简单方法是：不使用离线包进行安装，这将直接从上游仓库中下载最合适您当前系统的软件包。如果只有少数几个 RPM 包有问题，你可以使用一个小技巧快速修复：

```bash
rm -rf /www/pigsty/repo_complete    # 删除 repo_complete 标记文件，以标记此仓库为不完整（这样会重新从上游下载软件）
rm -rf SomeBrokenRPMPackages        # 删除有问题的 RPM 包
./infra.yml -t repo_upstream        # 写入上游仓库。你也可以使用 /etc/yum.repos.d/backup/*
./infra.yml -t repo_pkg             # 根据你当前的操作系统下载软件包
```

</details>



<br>
<details><summary>如何使用 Vagrant 创建本地虚拟机？</summary><br>

当你第一次使用 Vagrant 启动某个特定的操作系统仓库时，它会下载相应的 Box/Img 镜像文件，Pigsty 沙箱默认使用 `generic/rocky9` 镜像。

使用代理可能会增加下载速度。Box/Img 只需下载一次，在重建沙箱时会被重复使用。

</details>



<br>
<details><summary>阿里云上 CentOS 7.9 特有的 RPM 冲突问题</summary><br><br>

阿里云的 CentOS 7.9 额外安装的 `nscd` 可能会导致 RPM 冲突问题：`"Error: Package: nscd-2.17-307.el7.1.x86_64 (@base)"`

遇见安装失败，RPM冲突报错不要慌，这是一个DNS缓存工具，把这个包卸载了就可以了：`sudo yum remove nscd`，或者使用 ansible 命令批量删除所有节点上的 `nscd`：

```bash
ansible all -b -a 'yum remove -y nscd'
```

</details>



<br>
<details><summary>腾讯云上 Rocky 9.1 特有的 RPM 冲突问题</summary><br>

腾讯云的 Rocky 9.x 需要额外的 `annobin` 软件包才可以正常完成 Pigsty 安装。

遇见安装失败，RPM冲突报错不要慌，进入 `/www/pigsty` 把这几个包手动下载下来就好了。

```bash
./infra.yml -t repo_upstream      # add upstream repos
cd /www/pigsty;                   # download missing packages
repotrack annobin gcc-plugin-annobin libuser
./infra.yml -t repo_create        # create repo
```

</details>




<br>

<details><summary>在 Ubuntu 20.04 上安装时，PostGIS 3 安装失败</summary>

> 正如配置文件 [`ubuntu.yml`](https://github.com/Vonng/pigsty/blob/master/files/pigsty/ubuntu.yml) 中说明的：Ubuntu 20.04 中 PostGIS 3 离线安装会有一些问题。 

在安装过程中如果见到以下错误，可以尝试添加 NODE / PGDG 上游源后直接从互联网安装 `postgresql-15-postgis-3` 包，通常可以解决此问题。

如果您用不到 PostGIS，也可以

```
E: Unable to correct problems, you have held broken packages."], "stdout": "Reading package lists...
Building dependency tree...
Reading state information...
Some packages could not be installed. This may mean that you have
requested an impossible situation or if you are using the unstable
distribution that some required packages have not yet been created
or been moved out of Incoming.
The following information may help to resolve the situation:

The following packages have unmet dependencies:
 postgresql-15-postgis-3 : Depends: libgdal26 (>= 2.4.0) but it is not going to be installed
```

You can fix this by add upstream apt repo directly, In that case, this problem can be resolved by manually install postgis.

</details>



<br>

<details><summary>Ansible命令超时（Timeout waiting for xxx）</summary><br>

Ansible 命令的默认 ssh 超时时间是10秒。由于网络延迟或其他原因，某些命令可能需要超过这个时间。

你可以在 ansible 配置文件 [`ansible.cfg`](https://github.com/Vonng/pigsty/blob/master/ansible.cfg) 中增加超时参数：

```ini
[defaults]
timeout = 10 # 将其修改为 60，120 或更高。
```

如果你的SSH连接非常慢，通常会是 DNS的问题，请检查sshd配置确保 `UseDNS no`。

</details>




----------------

## 监控


<br>
<details><summary>PostgreSQL 监控的性能损耗如何？</summary><br>

一个常规 PostgreSQL 实例抓取耗时大约 200ms。抓取间隔默认为 10 秒，对于一个生产多核数据库实例来说几乎微不足道。

请注意，Pigsty 默认开启了库内对象监控，所以如果您的数据库内有数以十万计的表/索引对象，抓取可能耗时会增加到几秒。

您可以修改 Prometheus 的抓取频率，请确保一点：抓取周期应当显著高于一次抓取的时长。

</details>



<br>
<details><summary>如何监控一个现存的 PostgreSQL 实例？</summary><br>

在 [PGSQL Monitor](pgsql-monitor) 中提供了详细的监控配置说明。

</details>


<br>
<details><summary>如何手工从 Prometheus 中移除 PostgreSQL 监控对象？</summary><br>

```bash
./pgsql-rm.yml -t prometheus -l <cls>     # 将集群 'cls' 的所有实例从 prometheus 中移除
```

```bash
bin/pgmon-rm <ins>     # 用于从 Prometheus 中移除单个实例 'ins' 的监控对象，特别适合移除添加的外部实例
```

</details>






----------------

## INFRA


<br>
<details><summary>INFRA模块中包含了哪些组件？</summary><br>

- Ansible 用于自动化、部署和管理；
- Nginx 用于公开对外暴露各种 WebUI 服务，并为提供一个本地软件源
- 自签名 CA 用于 SSL/TLS 证书；
- Prometheus 用于收集存储监控指标；
- Grafana 用于监控/可视化；
- Loki 用于收集存储查询日志；
- AlertManager 用于告警聚合；
- Chronyd 用于 NTP 时间同步；
- DNSMasq 用于 DNS 注册和解析；
- ETCD 作为 PGSQL HA 的 DCS；（可以部署到别的专用节点集群上）
- 在 meta 节点上的 PostgreSQL 作为 CMDB；（可选）
- Docker 用于无状态的应用程序和工具（可选）。

</details>


<br>
<details><summary>如何重新向 Prometheus 注册监控目标？</summary><br>

如果你不小心删除了基础设施节点上 Prometheus 的目标目录（`/etc/prometheus/target`），你可以使用以下命令再次向 Prometheus 注册监控目标：

```bash
./infra.yml -t register_prometheus  # 在 infra 节点上向 prometheus 注册所有 infra 目标
./node.yml  -t register_prometheus  # 在 infra 节点上向 prometheus 注册所有 node  目标
./etcd.yml  -t register_prometheus  # 在 infra 节点上向 prometheus 注册所有 etcd  目标
./minio.yml -t register_prometheus  # 在 infra 节点上向 prometheus 注册所有 minio 目标
./pgsql.yml -t register_prometheus  # 在 infra 节点上向 prometheus 注册所有 pgsql 目标
```

</details>



<br>
<details><summary>如何重新向 Grafana 注册 PostgreSQL 数据源？</summary><br>

在 [`pg_databases`](param#pg_databases) 中定义的 PGSQL 数据库默认会被注册为 Grafana 数据源（以供 PGCAT 应用使用）。

如果你不小心删除了在 Grafana 中注册的 postgres 数据源，你可以使用以下命令再次注册它们：


```bash
# 将所有（在 pg_databases 中定义的） pgsql 数据库注册为 grafana 数据源
./pgsql.yml -t register_grafana
```

</details>



<br>
<details><summary>如何重新向 Nginx 注册节点的 Haproxy 管控界面？</summary><br>

如果你不小心删除了 `/etc/nginx/conf.d/haproxy` 中的已注册 haproxy 代理设置，你可以使用以下命令再次恢复它们：

```bash
./node.yml -t register_nginx     # 在 infra 节点上向 nginx 注册所有 haproxy 管理页面的代理设置
```

</details>



<br>
<details><summary>如何恢复 DNSMASQ 中的域名注册记录？</summary><br>

PGSQL 集群/实例域名默认注册到 infra 节点的 `/etc/hosts.d/<name>`。你可以使用以下命令再次恢复它们：

```bash
./pgsql.yml -t pg_dns    # 在 infra 节点上向 dnsmasq 注册 pg 的 DNS 名称
```

</details>




<br>
<details><summary>如何使用Nginx对外暴露新的上游服务？</summary><br>

如果你希望通过 Nginx 门户公开新的 WebUI 服务，你可以将服务定义添加到 [`infra_portal`](param#infra_portal) 参数中。

然后重新运行 `./infra.yml -t nginx_config,nginx_launch` 来更新并应用 Nginx 配置。

如果你希望通过 HTTPS 访问，你必须删除 `files/pki/csr/pigsty.csr` 和 `files/pki/nginx/pigsty.{key,crt}` 以强制重新生成 Nginx SSL/TLS 证书以包括新上游的域名。

如果您希望使用权威机构签发的 SSL 证书，而不是 Pigsty 自签名 CA 颁发的证书，可以将其放置于 `/etc/nginx/conf.d/cert/` 目录中并修改相应配置：`/etc/nginx/conf.d/<name>.conf`。

</details>



<br>
<details><summary>如何手动向节点添加上游仓库的Repo文件？</summary><br>

Pigsty 有一个内置的包装脚本 `bin/repo-add`，它将调用 ansible 剧本 `node.yml` 来将 repo 文件添加到相应的节点。

```bash
bin/repo-add <selector> [modules]
bin/repo-add 10.10.10.10           # 为节点 10.10.10.10 添加 node 源
bin/repo-add infra   node,infra    # 为 infra 分组添加 node 和 infra 源
bin/repo-add infra   node,local    # 为 infra 分组添加节点仓库和本地pigsty源
bin/repo-add pg-test node,pgsql    # 为 pg-test 分组添加 node 和 pgsql 源
```

</details>




----------------

## NODE


<br>
<details><summary>如何配置主机节点上的NTP服务？</summary><br>

> NTP对于生产环境各项服务非常重要，如果没有配置 NTP，您可以使用公共 NTP 服务，或管理节点上的 Chronyd 作为标准时间。

如果您的节点已经配置了 NTP，可以通过设置 `node_ntp_enabled` 为 `false` 来保留现有配置，不进行任何变更。

否则，如果您有互联网访问权限，可以使用公共 NTP 服务，例如 `pool.ntp.org`。

如果您没有互联网访问权限，可以使用以下方式，确保所有环境内的节点与管理节点时间是同步的，或者使用其他内网环境的 NTP 授时服务。

```bash
node_ntp_servers:                 # /etc/chrony.conf 中的 ntp 服务器列表
  - pool cn.pool.ntp.org iburst
  - pool ${admin_ip} iburst       # 假设其他节点都没有互联网访问，那么至少与 Admin 节点保持时间同步。
```

</details>




<br>
<details><summary>如何在节点上强制同步时间？</summary><br>

为了使用 `chronyc` 来同步时间。您首先需要配置 NTP 服务。

```bash
ansible all -b -a 'chronyc -a makestep'     # 同步时间
```

您可以用任何组或主机 IP 地址替换 `all`，以限制执行范围。

</details>




<br>
<details><summary>远程节点无法通过SSH访问怎么办？</summary><br>

如果目标机器隐藏在SSH跳板机后面， 或者进行了一些无法直接使用`ssh ip`访问的自定义操作， 可以使用诸如 `ansible_port`或`ansible_host` 这一类
[Ansible连接参数](https://docs.ansible.com/ansible/latest/inventory_guide/connection_details.html)来指定各种 SSH 连接信息，如下所示：

```bash
pg-test:
  vars: { pg_cluster: pg-test }
  hosts:
    10.10.10.11: {pg_seq: 1, pg_role: primary, ansible_host: node-1 }
    10.10.10.12: {pg_seq: 2, pg_role: replica, ansible_port: 22223, ansible_user: admin }
    10.10.10.13: {pg_seq: 3, pg_role: offline, ansible_port: 22224 }
```

</details>



<br>
<details><summary>远程节点SSH与SUDO需要密码怎么办？</summary><br>

**执行部署和更改时**，使用的管理员用户**必须**对所有节点拥有`ssh`和`sudo`权限。无需密码免密登录。

您可以在执行剧本时通过`-k|-K`参数传入ssh和sudo密码，甚至可以通过`-e`[`ansible_host`](param#connect)`=<another_user>`使用另一个用户来运行剧本。

但是，Pigsty强烈建议为管理员用户配置SSH**无密码登录**以及无密码的`sudo`。

</details>



<br>
<details><summary>如何使用已有的管理员用户创建专用管理员用户？</summary><br>

使用以下命令，使用该节点上现有的管理员用户，创建由[`node_admin_username`](param#node_admin_username)定义的新的标准的管理员用户。

```bash
./node.yml -k -K -e ansible_user=<another_admin> -t node_admin
```

</details>



<br>
<details><summary>如何使用节点上的HAProxy对外暴露服务？</summary><br>

您可以在配置中中使用[`haproxy_services`](param#haproxy_services)来暴露服务，并使用 `node.yml -t haproxy_config,haproxy_reload` 来更新配置。

以下是使用它暴露MinIO服务的示例：[暴露MinIO服务](minio#暴露服务)

</details>



<br>
<details><summary>为什么我的 /etc/yum.repos.d/* 全没了？</summary><br>

Pigsty会在infra节点上构建的本地软件仓库源中包含所有依赖项。而所有普通节点会根据[`node_repo_local_urls`](param#node_repo_local_urls)的默认配置来使用这个 Infra 节点上的本地软件源。

这一设计从而避免了互联网访问，增强了安装过程的稳定性与可靠性。所有原有的源定义文件会被移动到 `/etc/yum.repos.d/backup` 目录中，您只要按需复制回来即可。

如果您想在普通节点安装过程中保留原有的源定义文件，将 [`node_repo_remove`](param#node_repo_remove)设置为`false`即可。

如果您想在 Infra 节点构建本地源的过程中保留原有的源定义文件，将 [`repo_remove`](param#repo_remove)设置为`false`即可。

</details>



<br>
<details><summary>为什么我的命令行提示符变样了？怎么恢复？</summary><br>

Pigsty 使用的 Shell 命令行提示符是由环境变量 `PS1` 指定，定义在 `/etc/profile.d/node.sh` 文件中。

如果您不喜欢，想要修改或恢复原样，可以将这个文件移除，重新登陆即可。

</details>




----------------

## ETCD

<br>
<details><summary>ETCD集群如果不可用了会有什么影响？</summary><br>

[ETCD](etcd) 对于 PGSQL 集群的高可用至关重要，而 etcd 本身的可用性是通过使用多个节点来保证的。使用3节点的 etcd 集群允许最多一个节点宕机，而其他两个节点仍然可以正常工作；
使用五节点的 ETCD 集群则可以容忍两个节点失效。如果超过一半的 ETCD 节点宕机，ETCD 集群及其服务将不可用。在 Patroni 3.0 之前，这可能导致 [PGSQL](pgsql) 全局故障；所有的主节点将被降级并拒绝写请求。

自从 pigsty 2.0 起，默认启用了 patroni 3.0 的 [DCS 容错模式](https://patroni.readthedocs.io/en/master/dcs_failsafe_mode.html)，
当 etcd 集群不可用时，如果 PostgreSQL 集群主库可以感知到所有成员，就会 **锁定** PGSQL 集群状态。

在这种情况下，PGSQL 集群仍然可以正常工作，但您必须尽快恢复 ETCD 集群。（毕竟如果etcd宕机，您就无法通过 patroni 配置PostgreSQL集群了）

</details>



<br>
<details><summary>如何使用一个外部的已经存在的 ETCD 集群？</summary><br>

配置清单中硬编码了所使用 etcd 的分组名为 `etcd`，这个分组里的成员将被用作 PGSQL 的 DCS 服务器。您可以使用 `etcd.yml` 对它们进行初始化，或直接假设它是一个已存在的外部 etcd 集群。

要使用现有的外部 etcd 集群，只要像往常一样定义它们即可，您可以跳过 `etcd.yml` 剧本的执行，因为集群已经存在，不需要部署。

但您必须确保一点：**现有 etcd 集群证书是由同一 CA 签名颁发的**。否则客户端是无法使用 Pigsty 自签名的 CA 颁发的证书来访问这套 ETCD 的。

</details>



<br>
<details><summary>如何向现有ETCD集群添加新的成员？</summary><br>

> 详细过程，请参考[向 etcd 集群添加成员](etcd#添加成员)

```bash
etcdctl member add <etcd-?> --learner=true --peer-urls=https://<new_ins_ip>:2380 # 在管理节点上宣告新成员加入
./etcd.yml -l <new_ins_ip> -e etcd_init=existing                                 # 真正初始化新 etcd 成员
etcdctl member promote <new_ins_server_id>                                       # 在管理节点上提升新成员为正式成员
```
</details>



<br>
<details><summary>如何从现有ETCD集群中移除成员？</summary><br>

> 详细过程，请参考[从 etcd 集群中移除成员](etcd#移除成员)

```bash
etcdctl member remove <etcd_server_id>   # 在管理节点上从集群中踢出成员
./etcd.yml -l <ins_ip> -t etcd_purge     # 真正清除下线 etcd 实例
```

</details>






----------------

## MINIO


<br>
<details><summary>启动多节点/多盘MinIO集群失败怎么办？</summary><br>

在[单机多盘](MINIO#单机多盘)或[多机多盘](minio#多机多盘)模式下，如果数据目录不是有效的磁盘挂载点，MinIO会拒绝启动。

请使用已挂载的磁盘作为MinIO的数据目录，而不是普通目录。您只能在[单机单盘](minio#单机单盘)模式下使用普通目录作为 MinIO 的数据目录，作为开发测试之用。

</details>




<br>
<details><summary>如何部署一个多节点/多盘MinIO集群？</summary><br>

> 请参阅[创建多节点多盘的MinIO集群](minio#多机多盘)

</details>



<br>
<details><summary>如何向已有的MinIO集群中添加新的成员？</summary><br>

> 在部署之前，您最好规划MinIO集群容量，因为新增成员需要全局重启。

请参考这里：[扩展MinIO部署](https://min.io/docs/minio/linux/operations/install-deploy-manage/expand-minio-deployment.html)

</details>



<br>
<details><summary>如何让PGSQL模块使用高可用MinIO作为备份目的地？</summary><br>

> 使用可选的负载均衡器和不同的端口访问HA MinIO集群。

这里有一个示例：[访问MinIO服务](minio#访问服务)

</details>






----------------

## REDIS

<br>
<details><summary>Redis初始化失败：ABORT due to existing redis instance</summary><br>

这意味着正在初始化的 Redis 实例已经存在了，使用 `redis_clean = true` 和 `redis_safeguard = false` 来强制清除redis数据

当您运行`redis.yml`来初始化一个已经在运行的redis实例，并且[`redis_clean`](param#redis_clean)设置为`false`时，就会出现这种情况。

如果`redis_clean`设置为`true`（并且 [`redis_safeguard`](param#redis_safeguard) 也设置为`false`），`redis.yml`剧本将删除现有的redis实例并将其重新初始化为一个新的实例，这使得`redis.yml`剧本完全具有幂等性。

</details>



<br>

<details><summary>Redis初始化失败：ABORT due to redis_safeguard enabled</summary><br>

这意味着正准备清理的 Redis 实例打开了防误删保险：当 [`redis_safeguard`](param#redis_safeguard) 设置为 `true` 时，尝试移除一个redis实例时就会出现这种情况。

您可以关闭 [`redis_safeguard`](param#redis_safeguard) 来移除Redis实例。这就是 `redis_safeguard` 的作用。

</details>



<br>
<details><summary>如何在某个节点上添加一个新的Redis实例？</summary><br>

使用 `bin/redis-add <ip> <port>` 在节点上部署一个新的redis实例。

</details>



<br>
<details><summary>如何从节点上移除一个特定实例？</summary><br>

使用 `bin/redis-rm <ip> <port>` 从节点上移除一个单独的redis实例。

</details>





----------------

## PGSQL


<br>
<details><summary>PGSQL初始化失败：ABORT due to postgres exists</summary><br>

这意味着正在初始化的 PostgreSQL 实例已经存在了， 将 `pg_clean` 设置为 `true`，并将 `pg_safeguard` 设置为 `false`，就可以在执行 `pgsql.yml` 期间强制清理现存实例。

如果 `pg_clean` 为 `true` (并且 `pg_safeguard` 也为 `false`)，`pgsql.yml` 剧本将会移除现有的 pgsql 数据并重新初始化为新的，这使得这个剧本真正幂等。

你可以通过使用一个特殊的任务标签 `pg_purge` 来强制清除现有的 PostgreSQL 数据，这个标签任务会忽略 `pg_clean` 和 `pg_safeguard` 的设置，所以非常危险。

```bash
./pgsql.yml -t pg_clean      # 优先考虑 pg_clean 和 pg_safeguard
./pgsql.yml -t pg_purge      # 忽略 pg_clean 和 pg_safeguard
```

</details>



<br>
<details><summary>PGSQL初始化失败：ABORT due to pg_safeguard enabled</summary><br>

这意味着正准备清理的 PostgreSQL 实例打开了防误删保险， 禁用 `pg_safeguard` 以移除 Postgres 实例。

如果防误删保险 [`pg_safeguard`](param#pg_safeguard) 打开，那么你就不能使用 `bin/pgsql-rm` 和 `pgsql-rm.yml` 剧本移除正在运行的 PGSQL 实例了。

要禁用 `pg_safeguard`，你可以在配置清单中将 `pg_safeguard` 设置为 `false`，或者在执行剧本时使用命令参数 `-e pg_safeguard=false`。

```bash
./pgsql-rm.yml -e pg_safeguard=false -l <cls_to_remove>    # 强制覆盖 pg_safeguard
```

</details>



<br>
<details><summary>PGSQL初始化失败：Fail to wait for postgres/patroni primary</summary><br>

这通常是因为集群配置错误，或者之前的主节点被不正确地移除了，你必须检查 `/pg/log/*` 来找到具体原因。

一种典型原因是，在DCS中有同名集群残留的垃圾元数据：没有正确完成下线，你可以使用 `etcdctl del --prefix /pg/<cls>` 来手工删除残留数据（请小心）

</details>




<br>
<details><summary>PGSQL初始化失败：Fail to wait for postgres/patroni replica</summary><br>

存在几种可能的原因：

**立即失败**：通常是由于配置错误、网络问题、损坏的DCS元数据等原因。你必须检查 `/pg/log` 找出实际原因。

**过了一会儿失败**：这可能是由于源实例数据损坏。查看 PGSQL FAQ：如何在数据损坏时创建副本？

**过了很长时间再超时**：如果 `wait for postgres replica` 任务耗时 30 分钟或更长时间并由于超时而失败，这对于大型集群（例如，1TB+，可能需要几小时创建一个副本）是很常见的。

在这种情况下，底层创建副本的过程仍在进行。你可以使用 `pg list <cls>` 检查集群状态并等待副本赶上主节点。然后使用以下命令继续以下任务，完成完整的从库初始化：

```bash
./pgsql.yml -t pg_hba,pg_backup,pgbouncer,pg_vip,pg_dns,pg_service,pg_exporter,pg_register -l <problematic_replica>
```

</details>




<br>
<details><summary>如何安装其他的PostgreSQL大版本：12 - 14，以及 16beta</summary><br>

要安装 PostgreSQL 12 - 15，你必须在配置清单中设置 `pg_version` 为 `12`、`13`、`14` 或 `15`，通常在集群级别配置这个参数。

请注意，如果您想要安装 PostgreSQL 12, 13, 16beta，你还需要更改 `pg_libs` 和 `pg_extensions`，这些版本并没有提供完整的核心扩展插件：即只有数据库内核可用。

```yaml
pg_version: 16                    # 在此模板中安装 pg 16
pg_libs: 'pg_stat_statements, auto_explain' # 从 pg 16 beta 中移除 timescaledb，因为它不可用
pg_extensions: []                 # 目前缺少 pg16 扩展
```

在 [prod.yml](https://github.com/Vonng/pigsty/blob/master/files/pigsty/prod.yml#L110) 42节点生产环境仿真模板中提供了安装 12 - 16 大版本集群的示例。

详情请参考 [PGSQL配置：切换大版本](PGSQL-CONF#大版本切换)

</details>




<br>
<details><summary>如何为 PostgreSQL 启用大页/HugePage？</summary><br>

> 使用 `node_hugepage_count` 和 `node_hugepage_ratio` 或 `/pg/bin/pg-tune-hugepage`

如果你计划启用大页（HugePage），请考虑使用 [`node_hugepage_count`](PARAM#node_hugepage_count) 和 [`node_hugepage_ratio`](PARAM#node_hugepage_ratio)，并配合 `./node.yml -t node_tune` 进行应用。

大页对于数据库来说有利有弊，利是内存是专门管理的，不用担心被挪用，降低数据库 OOM 风险。缺点是某些场景下可能对性能由负面影响。 

在 PostgreSQL 启动前，您需要分配 **足够多的** 大页，浪费的部分可以使用 `pg-tune-hugepage` 脚本对其进行回收，不过此脚本仅 PostgreSQL 15+ 可用。

如果你的 PostgreSQL 已经在运行，你可以使用下面的办法启动大页（仅 PG15+ 可用）：

```bash
sync; echo 3 > /proc/sys/vm/drop_caches   # 刷盘，释放系统缓存（请做好数据库性能受到冲击的准备）
sudo /pg/bin/pg-tune-hugepage             # 将 nr_hugepages 写入 /etc/sysctl.d/hugepage.conf
pg restart <cls>                          # 重启 postgres 以使用 hugepage
```

</details>




<br>
<details><summary>如何确保故障转移中数据不丢失？</summary><br>

> 使用 `crit.yml` 参数模板，设置 `pg_rpo` 为 `0`，或[配置集群](pgsql-admin#配置集群)为同步提交模式。

考虑使用 [同步备库](PGSQL-CONF#同步备库) 和 [法定多数提交](pgsql-conf#法定人数提交) 来确保故障转移过程中的零数据丢失。

更多细节，可以参考 [安全考量 - 可用性](SECURITY.md#可用性) 的相关介绍。

</details>




<br>
<details><summary>磁盘写满了如何抢救？</summary><br>

如果磁盘写满了，连 Shell 命令都无法执行，`rm -rf /pg/dummy` 可以释放一些救命空间。

默认情况下，[`pg_dummy_filesize`](param#pg_dummy_filesize) 设置为 `64MB`。在生产环境中，建议将其增加到 `8GB` 或更大。

它将被放置在 PGSQL 主数据磁盘上的 `/pg/dummy` 路径下。你可以删除该文件以释放一些紧急空间：至少可以让你在该节点上运行一些 shell 脚本来进一步回收其他空间。

</details>




<br>
<details><summary>当集群数据已经损坏时如何创建副本？</summary><br>

Pigsty 在所有实例的 patroni 配置中设置了 `cloneform: true` 标签，标记该实例可用于创建副本。

如果某个实例有损坏的数据文件，导致创建新副本的时候出错中断，那么你可以设置 `clonefrom: false` 来避免从损坏的实例中拉取数据。具体操作如下

```bash
$ vi /pg/bin/patroni.yml

tags:
  nofailover: false
  clonefrom: true      # ----------> change to false
  noloadbalance: false
  nosync: false
  version:  '15'
  spec: '4C.8G.50G'
  conf: 'oltp.yml'
  
$ systemctl reload patroni    # 重新加载 Patroni 配置
```

</details>


<br><br><br>