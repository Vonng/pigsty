# 常见问题

> 这里列出了Pigsty用户常遇到的问题，如果您遇到了难以解决的问题，可以提交 [Issue](https://github.com/Vonng/pigsty/issues/new) 或者 [联系我们](overview#about)。


----------------

## 准备


<br>
<details><summary>机器节点要求</summary><br>

CPU架构：目前仅支持 `x86_64` 架构，尚未提供`ARM`支持。

硬件规格：普通节点至少 **1核1G** ，基础设施节点建议使用 **2核4G**，1核1G也可以但容易OOM。

对于严肃的生产应用，建议至少准备 3～4 台至少2核4G规格的节点用于部署。

</details><br>



<details><summary>操作系统要求</summary><br>

Pigsty 目前在 CentOS 7.9, Rocky 8.7 和 9.1 上进行开发和测试。RHEL、Alma、Oracle 和其他与EL兼容的发行版同样适用。

强烈建议您使用 EL 7.9, 8.6 和 9.1，以避免无谓的 RPM 兼容性问题，并且我们强烈建议您使用**全新的节点**，避免无谓的软件冲突问题。

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

Offline packages can be downloaded during [`bootstrap`](install#bootstrap), or you can download them directly via:

离线包可以在[准备/`bootstrap`](install#bootstrap) 过程中提示下载，或者您也可以直接通过以下链接从 GitHub 上下载：

```bash
https://github.com/Vonng/pigsty/releases/download/v2.3.0/pigsty-v2.3.0.tgz                   # source code
https://github.com/Vonng/pigsty/releases/download/v2.3.0/pigsty-pkg-v2.3.0.el7.x86_64.tgz    # el7 packages
https://github.com/Vonng/pigsty/releases/download/v2.3.0/pigsty-pkg-v2.3.0.el8.x86_64.tgz    # el8 packages
https://github.com/Vonng/pigsty/releases/download/v2.3.0/pigsty-pkg-v2.3.0.el9.x86_64.tgz    # el9 packages
```

中国大陆用户可以考虑使用 CDN 下载：

```bash
https://get.pigsty.cc/v2.3.0/pigsty-v2.3.0.tgz                   # source code
https://get.pigsty.cc/v2.3.0/pigsty-pkg-v2.3.0.el7.x86_64.tgz    # el7 packages
https://get.pigsty.cc/v2.3.0/pigsty-pkg-v2.3.0.el8.x86_64.tgz    # el8 packages
https://get.pigsty.cc/v2.3.0/pigsty-pkg-v2.3.0.el9.x86_64.tgz    # el9 packages
```

</details><br>



----------------

## 配置


<br>
<details><summary>准备 / bootstrap 过程是干什么的？</summary><br>

检测环境是否就绪、用各种手段确保后续安装所必需的工具 `ansible` 被正确安装。

当你下载 Pigsty 源码后，可以进入目录并执行 `bootstrap` 脚本。它会检测你的节点环境，如果没有发现离线软件包，它会询问你要不要下载一个。

你可以选择是，直接使用离线软件包安装又快又稳定。你也可以跳过，选择后面在安装过程中直接从互联网上游下载，这样会下载最新的软件版本，而且几乎不会遇到 RPM 冲突问题。

如果使用了离线软件包，bootstrap 会直接从离线软件包中安装 ansible，否则会从上游下载 ansible 并安装，如果你没有互联网访问，又没有 DVD，或者内网yum源，那就只能用离线软件包来安装了。

</details>



<br>
<details><summary>配置 / configure 过程是干什么的？</summary><br>

检测环境、并生成样例配置文件。

**configure** 过程会检测你的节点环境并为你生成一个 pigsty 配置文件：`pigsty.yml`，默认根据你的操作系统（EL 7/8/9）选用相应的单机安装模板。

所有默认的配置模板都在 `files/pigsty`中，你可以使用 `-m` 直接指定想要使用的配置模板。

如果您已经知道如何配置 Pigsty 了，那么完全可以跳过这一步，直接编辑 Pigsty 配置文件。

</details>



<br>
<details><summary>Pigsty配置文件是干什么的？</summary><br>

Pigsty主目录下的 `pigsty.yml` 是默认的配置文件，可以用来描述整套部署的环境，在 [`files/pigsty`](https://github.com/Vonng/pigsty/tree/master/files/pigsty) 有许多配置示例供你参考。

当执行剧本时，你可以使用 `-i <path>` 参数，选用其他位置的配置文件。

例如，你想根据另一个专门的配置文件 `redis.yml` 来安装 redis：`./redis.yml -i files/pigsty/redis.yml`

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

When running `make install`, the ansible-playbook [`install.yml`](https://github.com/Vonng/pigsty/blob/master/install.yml) will be invoked to install everything on all nodes

Which will:

- Install `INFRA` module on the current node.
- Install `NODE` module on the current node.
- Install `ETCD` module on the current node.
- The `MinIO` module is optional, and will not be installed by default.
- Install `PGSQL` module on the current node.

</details>



<br>
<details><summary>安装遇到RPM冲突怎么办？</summary><br>

There may have a slight chance that rpm conflict occurs during node/infra/pgsql packages installation.

The simplest way to resolve this is to install without offline packages, which will download directly from the upstream repo.

If there are only a few problematic RPMs, you can use a trick to fix the yum repo quickly:

```bash
rm -rf /www/pigsty/repo_complete    # delete the repo_complete flag file to mark this repo incomplete
rm -rf SomeBrokenRPMPackages        # delete problematic RPMs
./infra.yml -t repo_upstream        # write upstream repos. you can also use /etc/yum.repos.d/backup/*
./infra.yml -t repo_pkg             # download rpms according to your current OS
```

</details>



<br>
<details><summary>如何使用 Vagrant 创建本地虚拟机？</summary><br>

!> The first time you use Vagrant to pull up a particular OS repo, it will download the corresponding BOX.

Pigsty sandbox uses `generic/rocky9` image box by default, and Vagrant will download the `rocky/9` box for the first time the VM is started.

Using a proxy may increase the download speed. Box only needs to be downloaded once, and will be reused when recreating the sandbox.


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

<details><summary>Ansible command timeout (Timeout waiting for xxx）</summary><br>

The default ssh timeout for ansible command is 10 seconds, some commands may take longer than that due to network latency or other reasons.

You can increase the timeout parameter in the ansible config file [`ansible.cfg`](https://github.com/Vonng/pigsty/blob/master/ansible.cfg):

```ini
[defaults]
timeout = 10 # change to 60,120 or more
```

</details>




----------------

## 监控


<br>
<details><summary>PostgreSQL 监控的性能损耗如何？</summary><br>

并不是很大，一个常规的实例抓取耗时大约 200ms。抓取间隔默认为 10 秒。

</details>



<br>
<details><summary>如何监控一个现存的 PostgreSQL 实例？</summary><br>

在 [PGSQL Monitor](pgsql/monitor) 提供了详细的监控配置说明。

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

- Ansible for automation, deployment, and administration;
- Nginx for exposing any WebUI service and serving the yum repo;
- Self-Signed CA for SSL/TLS certificates;
- Prometheus for monitoring metrics
- Grafana for monitoring/visualization
- Loki for logging collection
- AlertManager for alerts aggregation
- Chronyd for NTP time sync on the admin node.
- DNSMasq for DNS registration and resolution.
- ETCD as DCS for PGSQL HA; (dedicated module)
- PostgreSQL on meta nodes as CMDB; (optional)
- Docker for stateless applications & tools (optional)

</details>


<br>
<details><summary>如何重新向 Prometheus 注册监控目标？</summary><br>

If you accidentally deleted the Prometheus targets dir, you can register monitoring targets to Prometheus again with the:

```bash
./infra.yml -t register_prometheus  # register all infra targets to prometheus on infra nodes
./node.yml  -t register_prometheus  # register all node  targets to prometheus on infra nodes
./etcd.yml  -t register_prometheus  # register all etcd targets to prometheus on infra nodes
./minio.yml -t register_prometheus  # register all minio targets to prometheus on infra nodes
./pgsql.yml -t register_prometheus  # register all pgsql targets to prometheus on infra nodes
```

</details>



<br>
<details><summary>如何重新向 Grafana 注册 PostgreSQL 数据源？</summary><br>

PGSQL Databases in [`pg_databases`](param#pg_databases) are registered as Grafana datasource by default.

If you accidentally deleted the registered postgres datasource in Grafana, you can register them again with

```bash
./pgsql.yml -t register_grafana  # register all pgsql database (in pg_databases) as grafana datasource
```

</details>



<br>
<details><summary>如何重新向 Nginx 注册节点的 Haproxy 管控界面？</summary><br>

The haproxy admin page is proxied by Nginx under the default server.

If you accidentally deleted the registered haproxy proxy settings in `/etc/nginx/conf.d/haproxy`, you can restore them again with

```bash
./node.yml -t register_nginx     # register all haproxy admin page proxy settings to nginx on infra nodes
```

</details>



<br>
<details><summary>如何恢复 DNSMASQ 中的域名注册记录？</summary><br>

PGSQL cluster/instance domain names are registered to `/etc/hosts.d/<name>` on infra nodes by default.

You can restore them again with the following:

```bash
./pgsql.yml -t pg_dns   # register pg DNS names to dnsmasq on infra nodes
```

</details>




<br>
<details><summary>如何使用Nginx对外暴露新的上游服务？</summary><br>

If you wish to expose a new WebUI service via the Nginx portal, you can add the service definition to the [`infra_portal`](param#infra_portal) parameter.

And re-run `./infra.yml -t nginx_config,nginx_launch` to update & apply the Nginx configuration.

If you wish to access with HTTPS, you must remove `files/pki/csr/pigsty.csr`, `files/pki/nginx/pigsty.{key,crt}` to force re-generating the Nginx SSL/TLS certificate to include the new upstream's domain name.

</details>



<br>
<details><summary>如何手动向节点添加上游仓库的Repo文件？</summary><br>

Pigsty has a built-in wrap script `bin/repo-add`, which will invoke ansible playbook `node.yml` to adding repo files to corresponding nodes.

```bash
bin/repo-add <selector> [modules]
bin/repo-add 10.10.10.10           # add node repos for node 10.10.10.10
bin/repo-add infra   node,infra    # add node and infra repos for group infra
bin/repo-add infra   node,local    # add node repos and local pigsty repo
bin/repo-add pg-test node,pgsql    # add node & pgsql repos for group pg-test
```

</details>




----------------

## NODE


<br>
<details><summary>如何配置主机节点上的NTP服务？</summary><br>

!> If NTP is not configured, use a public NTP service or sync time with the admin node.

If your nodes already have NTP configured, you can leave it there by setting `node_ntp_enabled` to `false`.

Otherwise, if you have Internet access, you can use public NTP services such as `pool.ntp.org`.

If you don't have Internet access, at least you can sync time with the admin node with the following:

```bash
node_ntp_servers:                 # NTP servers in /etc/chrony.conf
  - pool cn.pool.ntp.org iburst
  - pool ${admin_ip} iburst       # assume non-admin nodes do not have internet access
```

</details>




<br>
<details><summary>如何在节点上强制同步时间？</summary><br>

!> Use `chronyc` to sync time. You have to configure the NTP service first.

```bash
ansible all -b -a 'chronyc -a makestep'     # sync time
```

You can replace `all` with any group or host IP address to limit execution scope.

</details>



<br>
<details><summary>远程节点无法通过SSH访问怎么办？</summary><br>

!> Specify a different port via the host instance-level [`ansible connection parameters`](param#ansible_host).

Consider using **Ansible connection parameters** if the target machine is hidden behind an SSH springboard machine,
or if some customizations have been made that cannot be accessed directly using `ssh ip`.
Additional SSH ports can be specified with `ansible_port` or `ansible_host` for SSH Alias.

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

!> Use the `-k` and `-K` parameters, enter the password at the prompt, and refer to admin provisioning.

**When performing deployments and changes**, the admin user used **must** have `ssh` and `sudo` privileges for all nodes. Password-free is not required.
You can pass in ssh and sudo passwords via the `-k|-K` parameter when executing the playbook or even use another user to run the playbook via `-e`[`ansible_host`](param#connect)`=<another_user>`.
However, Pigsty strongly recommends configuring SSH **passwordless login** with passwordless `sudo` for the admin user.

</details>



<br>
<details><summary>如何使用已有的管理员用户创建专用管理员用户？</summary><br>

!> `./node.yml -k -K -e ansible_user=<another_admin> -t node_admin`

This will create an admin user specified by [`node_admin_username`](param#node_admin_username) with the existing one on that node.

</details>



<br>
<details><summary>如何使用节点上的HAProxy对外暴露服务？</summary><br>

!> You can expose service with [`haproxy_services`](param#haproxy_services) in `node.yml`.

And here's an example of exposing MinIO service with it: [Expose MinIO Service](minio#expose-service)

</details>



<br>
<details><summary>为什么我的 /etc/yum.repos.d/* 全没了？</summary><br>

Pigsty will try to include all dependencies in the local yum repo on infra nodes. This repo file will be added according to [`node_repo_local_urls`](param#node_repo_local_urls).
And existing repo files will be removed by default according to the default value of [`node_repo_remove`](param#node_repo_remove). This will prevent the node from using the Internet repo or some stupid issues.

If you want to keep existing repo files, just set [`node_repo_remove`](param#node_repo_remove) to `false`.

</details>







----------------

## ETCD


<br>
<details><summary>ETCD集群如果不可用了会有什么影响？</summary><br>

[ETCD](etcd) availability is critical for the PGSQL cluster's HA, which is guaranteed by using multiple nodes.
With a 3-node ETCD cluster, if one node is down, the other two nodes can still function normally; and with a 5-node ETCD cluster, two-node failure can still be tolerated.
If more than half of the ETCD nodes are down, the ETCD cluster and its service will be unavailable.
Before Patroni 3.0, this could lead to a global [PGSQL](pgsql) outage; all primary will be demoted and reject write requests.

Since pigsty 2.0, the patroni 3.0 [DCS failsafe mode](https://patroni.readthedocs.io/en/master/dcs_failsafe_mode.html) is enabled by default, which will **LOCK** the PGSQL cluster status if the ETCD cluster is unavailable and all PGSQL members are still known to the primary.

The PGSQL cluster can still function normally, but you must recover the ETCD cluster ASAP. (you can't configure the PGSQL cluster through patroni if etcd is down)

</details>



<br>
<details><summary>如何使用一个外部的已经存在的 ETCD 集群？</summary><br>

The hard-coded group, `etcd`, will be used as DCS servers for PGSQL. You can initialize them with `etcd.yml` or assume it is an existing external etcd cluster.

To use an existing external etcd cluster, define them as usual and make sure your current etcd cluster certificate is signed by the same CA as your self-signed CA for PGSQL.

</details>



<br>
<details><summary>如何向现有ETCD集群添加新的成员？</summary><br>

!> Check [Add a member to etcd cluster](etcd-admin#add-member)

```bash
etcdctl member add <etcd-?> --learner=true --peer-urls=https://<new_ins_ip>:2380 # on admin node
./etcd.yml -l <new_ins_ip> -e etcd_init=existing                                 # init new etcd member
etcdctl member promote <new_ins_server_id>                                       # on admin node
```

</details>



<br>
<details><summary>如何从现有ETCD集群中移除成员？</summary><br>

!> Check [Remove member from etcd cluster](etcd-admin#remove-member)

```bash
etcdctl member remove <etcd_server_id>   # kick member out of the cluster (on admin node)
./etcd.yml -l <ins_ip> -t etcd_purge     # purge etcd instance
```

</details>






----------------

## MINIO


<br>
<details><summary>启动多节点/多盘MinIO集群失败怎么办？</summary><br>

In [Multi-Driver](MINIO#single-node-multi-drive) or [Multi-Node](minio#multi-node-multi-drive) mode, MinIO will refuse to start if the data dir is not a valid mount point.

Use mounted disks for MinIO data dir rather than some regular directory. You can use the regular directory only in the [single node, single drive](minio#single-node-single-drive) mode.

</details>




<br>
<details><summary>如何部署一个多节点/多盘MinIO集群？</summary><br>

!> Check [Create Multi-Node Multi-Driver MinIO Cluster](minio#multi-node-multi-drive)

</details>



<br>
<details><summary>如何向已有的MinIO集群中添加新的成员？</summary><br>

!> You'd better plan the MinIO cluster before deployment... Since this requires a global restart

Check this: [Expand MinIO Deployment](https://min.io/docs/minio/linux/operations/install-deploy-manage/expand-minio-deployment.html)

</details>



<br>
<details><summary>如何让PGSQL模块使用高可用MinIO作为备份目的地？</summary><br>

!> Access the HA MinIO cluster with an optional load balancer and different ports.

Here is an example: [Access MinIO Service](minio#access-service)

</details>






----------------

## REDIS

<br>
<details><summary>Redis初始化失败：ABORT due to existing redis instance</summary><br>

!> use `redis_clean = true` and `redis_safeguard = false` to force clean redis data

This happens when you run `redis.yml` to init a redis instance that is already running, and [`redis_clean`](param#redis_clean) is set to `false`.

If `redis_clean` is set to `true` (and the `redis_safeguard` is set to `false`, too), the `redis.yml` playbook will remove the existing redis instance and re-init it as a new one, which makes the `redis.yml` playbook fully idempotent.

</details>



<br>

<details><summary>Redis初始化失败：ABORT due to redis_safeguard enabled</summary><br>

!> This happens when removing a redis instance with [`redis_safeguard`](param#redis_safeguard) set to `true`.

You can disable [`redis_safeguard`](param#redis_safeguard) to remove the Redis instance. This is redis_safeguard is what it is for.

</details>



<br>
<details><summary>如何在某个节点上添加一个新的Redis实例？</summary><br>

Use `bin/redis-add <ip> <port>` to deploy a new redis instance on node.

</details>



<br>
<details><summary>如何从节点上移除一个特定实例？</summary><br>

`bin/redis-rm <ip> <port>` to remove a single redis instance from node

</details>





----------------

## PGSQL

<br>
<details><summary>PGSQL初始化失败：ABORT due to postgres exists</summary><br>

!> Set `pg_clean` = `true` and `pg_safeguard` = `false` to force clean postgres data during `pgsql.yml`

This happens when you run `pgsql.yml` on a node with postgres running, and [`pg_clean`](param#pg_clean) is set to `false`.

If `pg_clean` is true (and the `pg_safeguard` is `false`, too), the `pgsql.yml` playbook will remove the existing pgsql data and re-init it as a new one, which makes this playbook fully idempotent.

You can still purge the existing PostgreSQL data by using a special task tag `pg_purge`

```bash
./pgsql.yml -t pg_clean      # honor pg_clean and pg_safeguard
./pgsql.yml -t pg_purge      # ignore pg_clean and pg_safeguard
```

</details>



<br>
<details><summary>PGSQL初始化失败：ABORT due to pg_safeguard enabled</summary><br>

!> Disable `pg_safeguard` to remove the Postgres instance.

If [`pg_safeguard`](param#pg_safeguard) is enabled, you can not remove the running pgsql instance with `bin/pgsql-rm` and `pgsql-rm.yml` playbook.

To disable `pg_safeguard`, you can set `pg_safeguard` to `false` in the inventory or pass `-e pg_safeguard=false` as cli arg to the playbook:

```bash
./pgsql-rm.yml -e pg_safeguard=false -l <cls_to_remove>    # force override pg_safeguard
```

</details>



<br>
<details><summary>PGSQL初始化失败：Fail to wait for postgres/patroni primary</summary><br>

This usually happens when the cluster is misconfigured, or the previous primary is improperly removed. (e.g., trash metadata in DCS with the same cluster name).

You must check `/pg/log/*` to find the reason.

</details>




<br>
<details><summary>PGSQL初始化失败：Fail to wait for postgres/patroni replica</summary><br>

There are several possible reasons:

**Failed Immediately**: Usually, this happens because of misconfiguration, network issues, broken DCS metadata, etc..., you have to inspect `/pg/log` to find out the actual reason.

**Failed After a While**: This may be due to source instance data corruption. Check PGSQL FAQ: How to create replicas when data is corrupted?

**Timeout**: If the `wait for postgres replica` task takes 30min or more and fails due to timeout, This is common for a huge cluster (e.g., 1TB+, which may take hours to create a replica). In this case, the underlying creating replica procedure is still proceeding. You can check cluster status with `pg list <cls>` and wait until the replica catches up with the primary. Then continue the following tasks:

```bash
./pgsql.yml -t pg_hba,pg_backup,pgbouncer,pg_vip,pg_dns,pg_service,pg_exporter,pg_register
```

</details>




<br>
<details><summary>如何安装其他的PostgreSQL大版本：12 - 14，以及 16beta</summary><br>

To install PostgreSQL 12 - 15, you have to set `pg_version` to `12`, `13`, `14`, or `15` in the inventory. (usually at cluster level)

To install PostgreSQL 16 beta, you have to change `pg_libs` and `pg_extensions` too, since most extensions are not available for pg16 yet.

```yaml
pg_version: 16                    # install pg 16 in this template
pg_libs: 'pg_stat_statements, auto_explain' # remove timescaledb from pg 16 beta
pg_extensions: []                 # missing pg16 extensions for now
```

</details>




<br>
<details><summary>如何为 PostgreSQL 启用大页/HugePage？</summary><br>

!> use `node_hugepage_count` and `node_hugepage_ratio` or `/pg/bin/pg-tune-hugepage`

If you plan to enable hugepage, consider using `node_hugepage_count` and `node_hugepage_ratio` and apply with `./node.yml -t node_tune` .

It's good to allocate **enough** hugepage before postgres start, and use `pg_tune_hugepage` to shrink them later.

If your postgres is already running, you can use `/pg/bin/pg-tune-hugepage` to enable hugepage on the fly.

```bash
sync; echo 3 > /proc/sys/vm/drop_caches   # drop system cache (ready for performance impact)
sudo /pg/bin/pg-tune-hugepage             # write nr_hugepages to /etc/sysctl.d/hugepage.conf
pg restart <cls>                          # restart postgres to use hugepage
```

</details>




<br>
<details><summary>如何确保故障转移中数据不丢失？</summary><br>

!> Use `crit.yml` template, or setting `pg_rpo` to `0`, or [Config Cluster](pgsql/admin#config-cluster) with synchronous mode.

Consider using [Sync Standby](PGSQL-CONF#sync-standby) and [Quorum Comit](pgsql/conf#quorum-commit) to guarantee 0 data loss during failover.

</details>




<br>
<details><summary>如何从磁盘写满逃生？</summary><br>

!> `rm -rf /pg/dummy` will free some emergency space.

The [`pg_dummy_filesize`](param#pg_dummy_filesize) is set to `64MB` by default. Consider increasing it to `8GB` or larger in the production environment.

It will be placed on `/pg/dummy` same disk as the PGSQL main data disk. You can remove that file to free some emergency space. At least you can run some shell scripts on that node.

</details>






<br>
<details><summary>当集群数据已经损坏时如何创建副本？</summary><br>

!> Disable `clonefrom` on bad instances and reload patroni config.

Pigsty sets the `cloneform: true` tag on all instances' patroni config, which marks the instance available for cloning replica.

If this instance has corrupt data files, you can set `clonefrom: false` to avoid pulling data from the evil instance. To do so:

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
  
$ systemctl reload patroni
```

</details>


<br><br><br>