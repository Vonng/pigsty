# 腾讯云VPC部署

本文将介绍如何使用腾讯云虚拟机[部署](t-deploy.md)Pigsty。

Pigsty的Public Demo： http://demo.pigsty.cc 即是通过本教程演示的方式部署的。

------------------------

## 目录

* [准备工作](t-prepare.md)
  * [节点置备](#节点置备)
  * [管理节点置备](#管理节点置备)
  * [管理用户置备](#管理用户置备)
  * [软件置备](#软件置备)
* [修改配置](#修改配置)
* [执行剧本](#执行剧本)
* 可选：部署额外集群`pg-test`
* 可选：部署日志收集组件
* 可选：安装扩展应用`covid`


------------------------

## 准备工作

这里先介绍默认基于单节点的部署，后面会介绍如何部署额外的数据库集群。

### [节点置备](t-prepare.md#节点置备)

在云厂商买一台虚拟机，带公网IP地址。如果您有办法访问该机器上的80端口（Web界面），没有公网IP也可以。

> 这台机器即是Pigsty的公开Demo，会定期重装，请不要乱搞事情。

![](http://v0.pigsty.cc/img/deploy/qcloud-vpc.png)



### [管理节点置备](t-prepare.md#管理节点置备)

如上图所示，最下面一台机器（内网IP：`172.21.0.11`，公网IP：`42.193.xxx.xx`）即是我们要安装Pigsty的机器。

这里共有4台虚拟机，都是`172.21.0.0/24`网段的机器，另外三台将用于后续部署额外的`pg-test`集群。

云厂商交付的机器默认都会给 root 权限，并配置好 ssh 远程访问，这里就不创建新的管理员用户，直接使用`root`登陆:

```bash
$ ssh root@42.193.127.40
Last login: Tue Sep 14 14:14:39 2021 from 117.50.113.38

[09-14 16:24:54] root@pg-meta-1:~
$
```


### [管理用户置备](t-prepare.md#管理用户置备)

**如果**需要管理其它的数据库节点与集群，你需要能从当前的管理节点ssh远程登陆被管理的普通节点。

虽然单机安装时用不到，但这里我们还是准备好管理用户。

```bash
# 生成管理节点的密钥对：~/.ssh/
ssh-keygen

# 配置从管理节点远程ssh免密登陆3个普通节点
ssh-copy-id root@172.21.0.3   # 输入远程root密码，拷贝管理节点的公钥至pg-test-1
ssh-copy-id root@172.21.0.4   # 输入远程root密码，拷贝管理节点的公钥至pg-test-2
ssh-copy-id root@172.21.0.16  # 输入远程root密码，拷贝管理节点的公钥至pg-test-3

# 确认nopass ssh sudo权限正常
ssh 172.21.0.3 'sudo ls'
ssh 172.21.0.4 'sudo ls'
ssh 172.21.0.16 'sudo ls'
```

现在，您可以在管理节点上远程ssh免密登陆三台普通数据库节点，并执行`sudo`命令。



### [软件置备](t-prepare.md#软件置备)

常规的做法是：使用`git`从Github克隆代码，使用`curl`从Github Release下载离线软件包

```bash
git clone https://github.com/Vonng/pigsty
curl -SL https://github.com/Vonng/pigsty/releases/download/v1.0.1/pkg.tgz    -o /tmp/pkg.tgz 
```

如果您不能访问Github（在大陆是很常见的），也可以从别的地方[下载](t-prepare.md#pigsty源代码)（例如百度云盘），然后手工拷贝至服务器上：

```bash
scp pigsty.tgz root@42.193.127.40:~/
scp pkg.tgz root@42.193.127.40:/tmp
```

解压源代码，并进入目录：
```bash
tar -xf pigsty.tgz && cd pigsty
```


------------------------


## [修改配置](v-config.md)

为了在当前虚拟机上安装Pigsty，首先要进行**配置**。

```bash
./configure
```

配置向导自动检测当前环境，并生成配置文件：

```bash
[root@VM-0-11-centos pigsty]# ./configure

configure pigsty v1.0.1 begin
[ OK ] kernel = Linux
[ OK ] machine = x86_64
[ OK ] release = 7.8.2003 , perfect
[ OK ] sudo = root ok
[WARN] ssh = root@127.0.0.1 fixed
[ OK ] primary_ip = 172.21.0.11  (from probe)
[ OK ] admin = root@172.21.0.11 ok
[ OK ] mode = tiny (infer from cpu core < 8)
[ OK ] config = tiny@172.21.0.11
[ OK ] cache = /tmp/pkg.tgz exists
[ OK ] repo = extract from /tmp/pkg.tgz
[ OK ] repo file = /etc/yum.repos.d/pigsty-local.repo
[ OK ] utils = install from local file repo
[ OK ] ansible = ansible 2.9.23
configure pigsty done. Use 'make install' to proceed

[root@VM-0-11-centos pigsty]#
```

公共Demo所使用的配置文件样例 [`pigsty-pub4.yml`](https://github.com/Vonng/pigsty/blob/master/files/conf/pigsty-pub4.yml) 已经集成在项目中。


### 配置自定义域名

Pigsty的用户界面默认可以通过占位域名`*.pigsty`访问，如果您希望通过**自己的域名**访问Pigsty提供的Web系统，
则还需要调整 [nginx_upstream](v-meta.md#nginx_upstream) 中的域名

例如：对于公开演示样例使用的域名`pigsty.cc`（解析至该节点公网IP），可以进行以下配置调整：

```yaml
nginx_upstream:                               # domain names that will be used for accessing pigsty services
    - { name: home,          host: pigsty.cc,      url: "127.0.0.1:3000" }   # default -> grafana (3000)
    - { name: consul,        host: c.pigsty.cc,    url: "127.0.0.1:8500" }   # pigsty consul UI (8500) (domain required)
    - { name: grafana,       host: g.pigsty.cc,    url: "127.0.0.1:3000" }   # pigsty grafana (3000)
    - { name: grafana2,      host: demo.pigsty.cc, url: "127.0.0.1:3000" }   # pigsty grafana public domain (3000)
    - { name: prometheus,    host: p.pigsty.cc,    url: "127.0.0.1:9090" }   # pigsty prometheus (9090)
    - { name: alertmanager,  host: a.pigsty.cc,    url: "127.0.0.1:9093" }   # pigsty alertmanager (9093)
    - { name: haproxy,       host: h.pigsty.cc,    url: "127.0.0.1:9091" }   # pigsty haproxy admin page (9091)
    - { name: server,        host: s.pigsty.cc,    url: "127.0.0.1:9633" }   # pigsty server gui (9093)

```


------------------------


## 执行剧本

配置完毕后，执行以下命令以完成安装。

```bash
make install
```

是的，安装完毕。


<details>
<summary>安装pigsty的标准输出</summary>

```bash
[root@VM-0-11-centos pigsty]# make install
./infra.yml -l meta
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see details

PLAY [Infra Init] *************************************************************************************************************************************************************

TASK [environ : Create pigsty resource dirs on /etc/pigsty] *******************************************************************************************************************
ok: [172.21.0.11] => (item=/etc/pigsty)
ok: [172.21.0.11] => (item=/etc/pigsty/targets)
ok: [172.21.0.11] => (item=/etc/pigsty/playbooks)
ok: [172.21.0.11] => (item=/etc/pigsty/dashboards)
ok: [172.21.0.11] => (item=/etc/pigsty/datasources)
ok: [172.21.0.11] => (item=/etc/pigsty/targets/pgsql)

TASK [environ : Get current username] *****************************************************************************************************************************************
ok: [172.21.0.11]

TASK [environ : Create admin user ssh key pair if not exists] *****************************************************************************************************************
ok: [172.21.0.11]

TASK [environ : Write default user credential to pgpass] **********************************************************************************************************************
ok: [172.21.0.11] => (item=*:*:*:replicator:DBUser.Replicator)
ok: [172.21.0.11] => (item=*:*:*:dbuser_monitor:DBUser.Monitor)
ok: [172.21.0.11] => (item=*:*:*:dbuser_dba:DBUser.DBA)

TASK [environ : Write default meta service to pg_service] *********************************************************************************************************************
ok: [172.21.0.11]

TASK [Set environment for admin user] *****************************************************************************************************************************************
ok: [172.21.0.11]

TASK [Enable environment for admin user] **************************************************************************************************************************************
ok: [172.21.0.11]

TASK [Create local repo directory] ********************************************************************************************************************************************
ok: [172.21.0.11]

TASK [Backup & remove existing repos] *****************************************************************************************************************************************
changed: [172.21.0.11]

TASK [Add required upstream repos] ********************************************************************************************************************************************
[WARNING]: Using a variable for a task's 'args' is unsafe in some situations (see https://docs.ansible.com/ansible/devel/reference_appendices/faq.html#argsplat-unsafe)
changed: [172.21.0.11] => (item={u'gpgcheck': False, u'description': u'CentOS-$releasever - Base', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/os/$basearch/', u'http://mirrors.aliyun.com/centos/$releasever/os/$basearch/', u'http://mirrors.aliyuncs.com/centos/$releasever/os/$basearch/', u'http://mirrors.cloud.aliyuncs.com/centos/$releasever/os/$basearch/', u'http://mirror.centos.org/centos/$releasever/os/$basearch/'], u'name': u'base'})
changed: [172.21.0.11] => (item={u'gpgcheck': False, u'description': u'CentOS-$releasever - Updates', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/updates/$basearch/', u'http://mirrors.aliyun.com/centos/$releasever/updates/$basearch/', u'http://mirrors.aliyuncs.com/centos/$releasever/updates/$basearch/', u'http://mirrors.cloud.aliyuncs.com/centos/$releasever/updates/$basearch/', u'http://mirror.centos.org/centos/$releasever/updates/$basearch/'], u'name': u'updates'})
changed: [172.21.0.11] => (item={u'gpgcheck': False, u'description': u'CentOS-$releasever - Extras', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/extras/$basearch/', u'http://mirrors.aliyun.com/centos/$releasever/extras/$basearch/', u'http://mirrors.aliyuncs.com/centos/$releasever/extras/$basearch/', u'http://mirrors.cloud.aliyuncs.com/centos/$releasever/extras/$basearch/', u'http://mirror.centos.org/centos/$releasever/extras/$basearch/'], u'name': u'extras'})
changed: [172.21.0.11] => (item={u'gpgcheck': False, u'description': u'CentOS $releasever - epel', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/epel/$releasever/$basearch', u'http://mirrors.aliyun.com/epel/$releasever/$basearch', u'http://download.fedoraproject.org/pub/epel/$releasever/$basearch'], u'name': u'epel'})
changed: [172.21.0.11] => (item={u'gpgcheck': False, u'enabled': True, u'description': u'Grafana', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/grafana/yum/rpm', u'https://packages.grafana.com/oss/rpm'], u'name': u'grafana'})
changed: [172.21.0.11] => (item={u'gpgcheck': False, u'description': u'Prometheus and exporters', u'baseurl': u'https://packagecloud.io/prometheus-rpm/release/el/$releasever/$basearch', u'name': u'prometheus'})
changed: [172.21.0.11] => (item={u'gpgcheck': False, u'description': u'PostgreSQL common RPMs for RHEL/CentOS $releasever - $basearch', u'baseurl': [u'http://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/redhat/rhel-$releasever-$basearch', u'https://download.postgresql.org/pub/repos/yum/common/redhat/rhel-$releasever-$basearch'], u'name': u'pgdg-common'})
changed: [172.21.0.11] => (item={u'gpgcheck': False, u'description': u'PostgreSQL 13 for RHEL/CentOS $releasever - $basearch', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/13/redhat/rhel-$releasever-$basearch', u'https://download.postgresql.org/pub/repos/yum/13/redhat/rhel-$releasever-$basearch'], u'name': u'pgdg13'})
changed: [172.21.0.11] => (item={u'gpgcheck': False, u'description': u'CentOS-$releasever - SCLo', u'baseurl': [u'http://mirrors.aliyun.com/centos/$releasever/sclo/$basearch/sclo/', u'http://repo.virtualhosting.hk/centos/$releasever/sclo/$basearch/sclo/'], u'name': u'centos-sclo'})
changed: [172.21.0.11] => (item={u'gpgcheck': False, u'description': u'CentOS-$releasever - SCLo rh', u'baseurl': [u'http://mirrors.aliyun.com/centos/$releasever/sclo/$basearch/rh/', u'http://repo.virtualhosting.hk/centos/$releasever/sclo/$basearch/rh/'], u'name': u'centos-sclo-rh'})
changed: [172.21.0.11] => (item={u'gpgcheck': False, u'skip_if_unavailable': True, u'name': u'nginx', u'baseurl': u'http://nginx.org/packages/centos/$releasever/$basearch/', u'description': u'Nginx Official Yum Repo'})
changed: [172.21.0.11] => (item={u'gpgcheck': False, u'skip_if_unavailable': True, u'name': u'haproxy', u'baseurl': u'https://download.copr.fedorainfracloud.org/results/roidelapluie/haproxy/epel-$releasever-$basearch/', u'description': u'Copr repo for haproxy'})
changed: [172.21.0.11] => (item={u'gpgcheck': False, u'skip_if_unavailable': True, u'name': u'harbottle', u'baseurl': u'https://download.copr.fedorainfracloud.org/results/harbottle/main/epel-$releasever-$basearch/', u'description': u'Copr repo for main owned by harbottle'})

TASK [Check repo pkgs cache exists] *******************************************************************************************************************************************
ok: [172.21.0.11]

TASK [Set fact whether repo_exists] *******************************************************************************************************************************************
ok: [172.21.0.11]

TASK [Move upstream repo to backup] *******************************************************************************************************************************************
changed: [172.21.0.11]

TASK [Add local file system repos] ********************************************************************************************************************************************
changed: [172.21.0.11]

TASK [repo : Remake yum cache if not exists] **********************************************************************************************************************************
changed: [172.21.0.11]

TASK [Install repo bootstrap packages] ****************************************************************************************************************************************
ok: [172.21.0.11] => (item=[u'yum-utils', u'createrepo', u'ansible', u'nginx', u'wget', u'unzip', u'sshpass'])

TASK [Render repo nginx server files] *****************************************************************************************************************************************
ok: [172.21.0.11] => (item={u'dest': u'/www/index.html', u'src': u'index.html.j2'})
ok: [172.21.0.11] => (item={u'dest': u'/etc/nginx/conf.d/default.conf', u'src': u'default.conf.j2'})
ok: [172.21.0.11] => (item={u'dest': u'/www/pigsty.repo', u'src': u'local.repo.j2'})
ok: [172.21.0.11] => (item={u'dest': u'/etc/nginx/nginx.conf', u'src': u'nginx.conf.j2'})

TASK [Disable selinux for repo server] ****************************************************************************************************************************************
ok: [172.21.0.11]

TASK [Launch repo nginx server] ***********************************************************************************************************************************************
changed: [172.21.0.11]

TASK [Waits repo server online] ***********************************************************************************************************************************************
ok: [172.21.0.11]

TASK [repo : Download web url packages] ***************************************************************************************************************************************
skipping: [172.21.0.11] => (item=https://github.com/Vonng/pg_exporter/releases/download/v0.4.0/pg_exporter-0.4.0-1.el7.x86_64.rpm)
skipping: [172.21.0.11] => (item=https://github.com/cybertec-postgresql/vip-manager/releases/download/v1.0/vip-manager_1.0-1_amd64.rpm)
skipping: [172.21.0.11] => (item=https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-amd64.tar.gz)
skipping: [172.21.0.11] => (item=https://github.com/Vonng/pg_exporter/releases/download/v0.4.0/pg_exporter_v0.4.0_linux-amd64.tar.gz)
skipping: [172.21.0.11] => (item=https://github.com/grafana/loki/releases/download/v2.2.1/loki-linux-amd64.zip)
skipping: [172.21.0.11] => (item=https://github.com/grafana/loki/releases/download/v2.2.1/promtail-linux-amd64.zip)
skipping: [172.21.0.11] => (item=https://github.com/grafana/loki/releases/download/v2.2.1/logcli-linux-amd64.zip)
skipping: [172.21.0.11] => (item=https://github.com/grafana/loki/releases/download/v2.2.1/loki-canary-linux-amd64.zip)

TASK [Download repo packages] *************************************************************************************************************************************************
skipping: [172.21.0.11] => (item=epel-release nginx wget yum-utils yum createrepo sshpass unzip)
skipping: [172.21.0.11] => (item=ntp chrony uuid lz4 nc pv jq vim-enhanced make patch bash lsof wget git tuned)
skipping: [172.21.0.11] => (item=readline zlib openssl libyaml libxml2 libxslt perl-ExtUtils-Embed ca-certificates)
skipping: [172.21.0.11] => (item=numactl grubby sysstat dstat iotop bind-utils net-tools tcpdump socat ipvsadm telnet)
skipping: [172.21.0.11] => (item=grafana prometheus2 pushgateway alertmanager)
skipping: [172.21.0.11] => (item=node_exporter postgres_exporter nginx_exporter blackbox_exporter)
skipping: [172.21.0.11] => (item=consul consul_exporter consul-template etcd)
skipping: [172.21.0.11] => (item=ansible python python-pip python-psycopg2 audit)
skipping: [172.21.0.11] => (item=python3 python3-psycopg2 python36-requests python3-etcd python3-consul)
skipping: [172.21.0.11] => (item=python36-urllib3 python36-idna python36-pyOpenSSL python36-cryptography)
skipping: [172.21.0.11] => (item=haproxy keepalived dnsmasq)
skipping: [172.21.0.11] => (item=patroni patroni-consul patroni-etcd pgbouncer pg_cli pgbadger pg_activity)
skipping: [172.21.0.11] => (item=pgcenter boxinfo check_postgres emaj pgbconsole pg_bloat_check pgquarrel)
skipping: [172.21.0.11] => (item=barman barman-cli pgloader pgFormatter pitrery pspg pgxnclient PyGreSQL pgadmin4 tail_n_mail)
skipping: [172.21.0.11] => (item=postgresql13*)
skipping: [172.21.0.11] => (item=postgresql13* postgis31* citus_13 timescaledb_13 pg_repack13 pg_squeeze13)
skipping: [172.21.0.11] => (item=pg_qualstats13 pg_stat_kcache13 system_stats_13 bgw_replstatus13)
skipping: [172.21.0.11] => (item=plr13 plsh13 plpgsql_check_13 plproxy13 plr13 plsh13 plpgsql_check_13 pldebugger13)
skipping: [172.21.0.11] => (item=hdfs_fdw_13 mongo_fdw13 mysql_fdw_13 ogr_fdw13 redis_fdw_13 pgbouncer_fdw13)
skipping: [172.21.0.11] => (item=wal2json13 count_distinct13 ddlx_13 geoip13 orafce13)
skipping: [172.21.0.11] => (item=rum_13 hypopg_13 ip4r13 jsquery_13 logerrors_13 periods_13 pg_auto_failover_13 pg_catcheck13)
skipping: [172.21.0.11] => (item=pg_fkpart13 pg_jobmon13 pg_partman13 pg_prioritize_13 pg_track_settings13 pgaudit15_13)
skipping: [172.21.0.11] => (item=pgcryptokey13 pgexportdoc13 pgimportdoc13 pgmemcache-13 pgmp13 pgq-13)
skipping: [172.21.0.11] => (item=pguint13 pguri13 prefix13  safeupdate_13 semver13  table_version13 tdigest13)
skipping: [172.21.0.11] => (item=gcc gcc-c++ clang coreutils diffutils rpm-build rpm-devel rpmlint rpmdevtools)
skipping: [172.21.0.11] => (item=zlib-devel openssl-libs openssl-devel libxml2-devel libxslt-devel)

TASK [Download repo pkg deps] *************************************************************************************************************************************************
skipping: [172.21.0.11] => (item=epel-release nginx wget yum-utils yum createrepo sshpass unzip)
skipping: [172.21.0.11] => (item=ntp chrony uuid lz4 nc pv jq vim-enhanced make patch bash lsof wget git tuned)
skipping: [172.21.0.11] => (item=readline zlib openssl libyaml libxml2 libxslt perl-ExtUtils-Embed ca-certificates)
skipping: [172.21.0.11] => (item=numactl grubby sysstat dstat iotop bind-utils net-tools tcpdump socat ipvsadm telnet)
skipping: [172.21.0.11] => (item=grafana prometheus2 pushgateway alertmanager)
skipping: [172.21.0.11] => (item=node_exporter postgres_exporter nginx_exporter blackbox_exporter)
skipping: [172.21.0.11] => (item=consul consul_exporter consul-template etcd)
skipping: [172.21.0.11] => (item=ansible python python-pip python-psycopg2 audit)
skipping: [172.21.0.11] => (item=python3 python3-psycopg2 python36-requests python3-etcd python3-consul)
skipping: [172.21.0.11] => (item=python36-urllib3 python36-idna python36-pyOpenSSL python36-cryptography)
skipping: [172.21.0.11] => (item=haproxy keepalived dnsmasq)
skipping: [172.21.0.11] => (item=patroni patroni-consul patroni-etcd pgbouncer pg_cli pgbadger pg_activity)
skipping: [172.21.0.11] => (item=pgcenter boxinfo check_postgres emaj pgbconsole pg_bloat_check pgquarrel)
skipping: [172.21.0.11] => (item=barman barman-cli pgloader pgFormatter pitrery pspg pgxnclient PyGreSQL pgadmin4 tail_n_mail)
skipping: [172.21.0.11] => (item=postgresql13*)
skipping: [172.21.0.11] => (item=postgresql13* postgis31* citus_13 timescaledb_13 pg_repack13 pg_squeeze13)
skipping: [172.21.0.11] => (item=pg_qualstats13 pg_stat_kcache13 system_stats_13 bgw_replstatus13)
skipping: [172.21.0.11] => (item=plr13 plsh13 plpgsql_check_13 plproxy13 plr13 plsh13 plpgsql_check_13 pldebugger13)
skipping: [172.21.0.11] => (item=hdfs_fdw_13 mongo_fdw13 mysql_fdw_13 ogr_fdw13 redis_fdw_13 pgbouncer_fdw13)
skipping: [172.21.0.11] => (item=wal2json13 count_distinct13 ddlx_13 geoip13 orafce13)
skipping: [172.21.0.11] => (item=rum_13 hypopg_13 ip4r13 jsquery_13 logerrors_13 periods_13 pg_auto_failover_13 pg_catcheck13)
skipping: [172.21.0.11] => (item=pg_fkpart13 pg_jobmon13 pg_partman13 pg_prioritize_13 pg_track_settings13 pgaudit15_13)
skipping: [172.21.0.11] => (item=pgcryptokey13 pgexportdoc13 pgimportdoc13 pgmemcache-13 pgmp13 pgq-13)
skipping: [172.21.0.11] => (item=pguint13 pguri13 prefix13  safeupdate_13 semver13  table_version13 tdigest13)
skipping: [172.21.0.11] => (item=gcc gcc-c++ clang coreutils diffutils rpm-build rpm-devel rpmlint rpmdevtools)
skipping: [172.21.0.11] => (item=zlib-devel openssl-libs openssl-devel libxml2-devel libxslt-devel)

TASK [Create local repo index] ************************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [repo : Copy bootstrap scripts] ******************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [Mark repo cache as valid] ***********************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [Update node hostname] ***************************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [node : Add new hostname to /etc/hosts] **********************************************************************************************************************************
skipping: [172.21.0.11]

TASK [node : Write static dns records] ****************************************************************************************************************************************
ok: [172.21.0.11] => (item=172.21.0.11 yum.pigsty)
ok: [172.21.0.11] => (item=172.21.0.11 meta   pg-meta-1)
ok: [172.21.0.11] => (item=10.10.10.11 node-1 pg-test-1)
ok: [172.21.0.11] => (item=10.10.10.12 node-2 pg-test-2)
ok: [172.21.0.11] => (item=10.10.10.13 node-2 pg-test-3)

TASK [node : Get old nameservers] *********************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [node : Write tmp resolv file] *******************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [node : Write resolv options] ********************************************************************************************************************************************
skipping: [172.21.0.11] => (item=options single-request-reopen timeout:1 rotate)
skipping: [172.21.0.11] => (item=domain service.consul)

TASK [node : Write additional nameservers] ************************************************************************************************************************************
skipping: [172.21.0.11] => (item=172.21.0.11)

TASK [node : Append existing nameservers] *************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [node : Swap resolv.conf] ************************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [node : Node configure disable firewall] *********************************************************************************************************************************
ok: [172.21.0.11]

TASK [node : Node disable selinux by default] *********************************************************************************************************************************
ok: [172.21.0.11]

TASK [node : Backup existing repos] *******************************************************************************************************************************************
changed: [172.21.0.11]

TASK [node : Install upstream repo] *******************************************************************************************************************************************
skipping: [172.21.0.11] => (item={u'gpgcheck': False, u'description': u'CentOS-$releasever - Base', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/os/$basearch/', u'http://mirrors.aliyun.com/centos/$releasever/os/$basearch/', u'http://mirrors.aliyuncs.com/centos/$releasever/os/$basearch/', u'http://mirrors.cloud.aliyuncs.com/centos/$releasever/os/$basearch/', u'http://mirror.centos.org/centos/$releasever/os/$basearch/'], u'name': u'base'})
skipping: [172.21.0.11] => (item={u'gpgcheck': False, u'description': u'CentOS-$releasever - Updates', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/updates/$basearch/', u'http://mirrors.aliyun.com/centos/$releasever/updates/$basearch/', u'http://mirrors.aliyuncs.com/centos/$releasever/updates/$basearch/', u'http://mirrors.cloud.aliyuncs.com/centos/$releasever/updates/$basearch/', u'http://mirror.centos.org/centos/$releasever/updates/$basearch/'], u'name': u'updates'})
skipping: [172.21.0.11] => (item={u'gpgcheck': False, u'description': u'CentOS-$releasever - Extras', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/extras/$basearch/', u'http://mirrors.aliyun.com/centos/$releasever/extras/$basearch/', u'http://mirrors.aliyuncs.com/centos/$releasever/extras/$basearch/', u'http://mirrors.cloud.aliyuncs.com/centos/$releasever/extras/$basearch/', u'http://mirror.centos.org/centos/$releasever/extras/$basearch/'], u'name': u'extras'})
skipping: [172.21.0.11] => (item={u'gpgcheck': False, u'description': u'CentOS $releasever - epel', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/epel/$releasever/$basearch', u'http://mirrors.aliyun.com/epel/$releasever/$basearch', u'http://download.fedoraproject.org/pub/epel/$releasever/$basearch'], u'name': u'epel'})
skipping: [172.21.0.11] => (item={u'gpgcheck': False, u'enabled': True, u'description': u'Grafana', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/grafana/yum/rpm', u'https://packages.grafana.com/oss/rpm'], u'name': u'grafana'})
skipping: [172.21.0.11] => (item={u'gpgcheck': False, u'description': u'Prometheus and exporters', u'baseurl': u'https://packagecloud.io/prometheus-rpm/release/el/$releasever/$basearch', u'name': u'prometheus'})
skipping: [172.21.0.11] => (item={u'gpgcheck': False, u'description': u'PostgreSQL common RPMs for RHEL/CentOS $releasever - $basearch', u'baseurl': [u'http://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/redhat/rhel-$releasever-$basearch', u'https://download.postgresql.org/pub/repos/yum/common/redhat/rhel-$releasever-$basearch'], u'name': u'pgdg-common'})
skipping: [172.21.0.11] => (item={u'gpgcheck': False, u'description': u'PostgreSQL 13 for RHEL/CentOS $releasever - $basearch', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/13/redhat/rhel-$releasever-$basearch', u'https://download.postgresql.org/pub/repos/yum/13/redhat/rhel-$releasever-$basearch'], u'name': u'pgdg13'})
skipping: [172.21.0.11] => (item={u'gpgcheck': False, u'description': u'CentOS-$releasever - SCLo', u'baseurl': [u'http://mirrors.aliyun.com/centos/$releasever/sclo/$basearch/sclo/', u'http://repo.virtualhosting.hk/centos/$releasever/sclo/$basearch/sclo/'], u'name': u'centos-sclo'})
skipping: [172.21.0.11] => (item={u'gpgcheck': False, u'description': u'CentOS-$releasever - SCLo rh', u'baseurl': [u'http://mirrors.aliyun.com/centos/$releasever/sclo/$basearch/rh/', u'http://repo.virtualhosting.hk/centos/$releasever/sclo/$basearch/rh/'], u'name': u'centos-sclo-rh'})
skipping: [172.21.0.11] => (item={u'gpgcheck': False, u'skip_if_unavailable': True, u'name': u'nginx', u'baseurl': u'http://nginx.org/packages/centos/$releasever/$basearch/', u'description': u'Nginx Official Yum Repo'})
skipping: [172.21.0.11] => (item={u'gpgcheck': False, u'skip_if_unavailable': True, u'name': u'haproxy', u'baseurl': u'https://download.copr.fedorainfracloud.org/results/roidelapluie/haproxy/epel-$releasever-$basearch/', u'description': u'Copr repo for haproxy'})
skipping: [172.21.0.11] => (item={u'gpgcheck': False, u'skip_if_unavailable': True, u'name': u'harbottle', u'baseurl': u'https://download.copr.fedorainfracloud.org/results/harbottle/main/epel-$releasever-$basearch/', u'description': u'Copr repo for main owned by harbottle'})

TASK [node : Install local repo] **********************************************************************************************************************************************
changed: [172.21.0.11] => (item=http://yum.pigsty/pigsty.repo)

TASK [Install node basic packages] ********************************************************************************************************************************************
skipping: [172.21.0.11] => (item=[])

TASK [Install node extra packages] ********************************************************************************************************************************************
skipping: [172.21.0.11] => (item=[])

TASK [node : Install meta specific packages] **********************************************************************************************************************************
skipping: [172.21.0.11] => (item=[])

TASK [Install node basic packages] ********************************************************************************************************************************************
ok: [172.21.0.11] => (item=[u'wget,yum-utils,sshpass,ntp,chrony,tuned,uuid,lz4,vim-minimal,make,patch,bash,lsof,wget,unzip,git,readline,zlib,openssl', u'numactl,grubby,sysstat,dstat,iotop,bind-utils,net-tools,tcpdump,socat,ipvsadm,telnet,tuned,pv,jq', u'python3,python3-psycopg2,python36-requests,python3-etcd,python3-consul', u'python36-urllib3,python36-idna,python36-pyOpenSSL,python36-cryptography', u'node_exporter,consul,consul-template,etcd,haproxy,keepalived,vip-manager'])

TASK [Install node extra packages] ********************************************************************************************************************************************
ok: [172.21.0.11] => (item=[u'patroni,patroni-consul,patroni-etcd,pgbouncer,pgbadger,pg_activity'])

TASK [node : Install meta specific packages] **********************************************************************************************************************************
ok: [172.21.0.11] => (item=[u'grafana,prometheus2,alertmanager,nginx_exporter,blackbox_exporter,pushgateway', u'nginx,ansible,pgbadger,python-psycopg2,dnsmasq', u'gcc,gcc-c++,clang,coreutils,diffutils,rpm-build,rpm-devel,rpmlint,rpmdevtools', u'zlib-devel,openssl-libs,openssl-devel,libxml2-devel,libxslt-devel'])

TASK [Install pip3 packages on meta node] *************************************************************************************************************************************
changed: [172.21.0.11]

TASK [node : Node configure disable numa] *************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [node : Node configure disable swap] *************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [node : Node configure unmount swap] *************************************************************************************************************************************
skipping: [172.21.0.11] => (item=swap)
skipping: [172.21.0.11] => (item=none)

TASK [node : Node setup static network] ***************************************************************************************************************************************
changed: [172.21.0.11]

TASK [node : Node configure disable firewall] *********************************************************************************************************************************
ok: [172.21.0.11]

TASK [node : Node configure disk prefetch] ************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [node : Enable linux kernel modules] *************************************************************************************************************************************
ok: [172.21.0.11] => (item=softdog)
ok: [172.21.0.11] => (item=br_netfilter)
ok: [172.21.0.11] => (item=ip_vs)
ok: [172.21.0.11] => (item=ip_vs_rr)
ok: [172.21.0.11] => (item=ip_vs_rr)
ok: [172.21.0.11] => (item=ip_vs_wrr)
ok: [172.21.0.11] => (item=ip_vs_sh)

TASK [node : Enable kernel module on reboot] **********************************************************************************************************************************
ok: [172.21.0.11]

TASK [node : Get config parameter page count] *********************************************************************************************************************************
changed: [172.21.0.11]

TASK [node : Get config parameter page size] **********************************************************************************************************************************
changed: [172.21.0.11]

TASK [node : Tune shmmax and shmall via mem] **********************************************************************************************************************************
ok: [172.21.0.11]

TASK [node : Create tuned profiles] *******************************************************************************************************************************************
ok: [172.21.0.11] => (item=oltp)
ok: [172.21.0.11] => (item=olap)
ok: [172.21.0.11] => (item=crit)
ok: [172.21.0.11] => (item=tiny)

TASK [node : Render tuned profiles] *******************************************************************************************************************************************
ok: [172.21.0.11] => (item=oltp)
ok: [172.21.0.11] => (item=olap)
ok: [172.21.0.11] => (item=crit)
ok: [172.21.0.11] => (item=tiny)

TASK [node : Active tuned profile] ********************************************************************************************************************************************
changed: [172.21.0.11]

TASK [node : Change additional sysctl params] *********************************************************************************************************************************

TASK [node : Copy default user bash profile] **********************************************************************************************************************************
ok: [172.21.0.11]

TASK [Setup node default pam ulimits] *****************************************************************************************************************************************
ok: [172.21.0.11]

TASK [node : Create os user group admin] **************************************************************************************************************************************
ok: [172.21.0.11]

TASK [node : Create os user admin] ********************************************************************************************************************************************
ok: [172.21.0.11]

TASK [node : Grant admin group nopass sudo] ***********************************************************************************************************************************
ok: [172.21.0.11]

TASK [node : Add no host checking to ssh config] ******************************************************************************************************************************
ok: [172.21.0.11]

TASK [node : Add admin ssh no host checking] **********************************************************************************************************************************
ok: [172.21.0.11]

TASK [node : Fetch all admin public keys] *************************************************************************************************************************************
changed: [172.21.0.11]

TASK [node : Exchange all admin ssh keys] *************************************************************************************************************************************
ok: [172.21.0.11 -> 172.21.0.11] => (item=[u'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDt17N6PvhOnIHPTt2wRUZ2jw6fQjPfqr96ryxCkZTxVOAEjABYMcXw/IOrN3JyCNOLgN4WzXTH+n6xI/U6hPvnaNHaL1PZfkc9/wrGd4PWa4X5+dl4zvBIzat+WDGAEnScyXUoDdQXHSujRq4eU6h6WB5bh0R1x/dGF8gAyk9hkM+n8jvg+bz2Jh1Gv+KCWW8delReEgK36LqQBkE5WYbhbrUq2W25qd4XvDUYm61zYBZJkUOvpAgmBG7KtcxrL6UnucwaAUnqL8DJDGnOAK/O3LdXReCljf4zyn2bdaXtyQQiSuG2GgtyXBcXmlvi5nthr0StYwsx3EPikYp6O3UZ ansible-generated on VM-0-11-centos', u'172.21.0.11'])

TASK [node : Install public keys] *********************************************************************************************************************************************

TASK [node : Install current public key] **************************************************************************************************************************************
ok: [172.21.0.11]

TASK [node : Install ntp package] *********************************************************************************************************************************************
ok: [172.21.0.11]

TASK [node : Install chrony package] ******************************************************************************************************************************************
ok: [172.21.0.11]

TASK [Setup default node timezone] ********************************************************************************************************************************************
ok: [172.21.0.11]

TASK [node : Copy the ntp.conf file] ******************************************************************************************************************************************
ok: [172.21.0.11]

TASK [node : Copy the chrony.conf template] ***********************************************************************************************************************************
ok: [172.21.0.11]

TASK [node : Launch ntpd service] *********************************************************************************************************************************************
changed: [172.21.0.11]

TASK [node : Launch chronyd service] ******************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [Check for existing consul] **********************************************************************************************************************************************
changed: [172.21.0.11]

TASK [consul : Consul exists flag fact set] ***********************************************************************************************************************************
ok: [172.21.0.11]

TASK [Abort due to consul exists] *********************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [Clean existing consul instance] *****************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [Stop any running consul instance] ***************************************************************************************************************************************
changed: [172.21.0.11]

TASK [Remove existing consul dir] *********************************************************************************************************************************************
ok: [172.21.0.11] => (item=/etc/consul.d)
ok: [172.21.0.11] => (item=/var/lib/consul)

TASK [Recreate consul dir] ****************************************************************************************************************************************************
changed: [172.21.0.11] => (item=/etc/consul.d)
changed: [172.21.0.11] => (item=/var/lib/consul)

TASK [Make sure consul is installed] ******************************************************************************************************************************************
ok: [172.21.0.11]

TASK [Make sure consul dir exists] ********************************************************************************************************************************************
changed: [172.21.0.11]

TASK [consul : Get dcs server node names] *************************************************************************************************************************************
ok: [172.21.0.11]

TASK [consul : Get dcs node name from var nodename] ***************************************************************************************************************************
skipping: [172.21.0.11]

TASK [consul : Get dcs node name from pgsql ins name] *************************************************************************************************************************
skipping: [172.21.0.11]

TASK [consul : Fetch hostname as dcs node name] *******************************************************************************************************************************
skipping: [172.21.0.11]

TASK [consul : Get dcs name from hostname] ************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [Copy /etc/consul.d/consul.json] *****************************************************************************************************************************************
changed: [172.21.0.11]

TASK [Copy consul agent service] **********************************************************************************************************************************************
ok: [172.21.0.11]

TASK [consul : Get dcs bootstrap expect quroum] *******************************************************************************************************************************
ok: [172.21.0.11]

TASK [Copy consul server service unit] ****************************************************************************************************************************************
changed: [172.21.0.11]

TASK [Launch consul server service] *******************************************************************************************************************************************
changed: [172.21.0.11]

TASK [Wait for consul server online] ******************************************************************************************************************************************
ok: [172.21.0.11]

TASK [Launch consul agent service] ********************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [Wait for consul agent online] *******************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [Create local ca directory] **********************************************************************************************************************************************
ok: [172.21.0.11]

TASK [Copy ca cert from local files] ******************************************************************************************************************************************
skipping: [172.21.0.11] => (item=ca.key)
skipping: [172.21.0.11] => (item=ca.crt)

TASK [Check ca key cert exists] ***********************************************************************************************************************************************
ok: [172.21.0.11]

TASK [ca : Create self-signed CA key-cert] ************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [nameserver : Make sure dnsmasq package installed] ***********************************************************************************************************************
ok: [172.21.0.11]

TASK [nameserver : Copy dnsmasq /etc/dnsmasq.d/config] ************************************************************************************************************************
ok: [172.21.0.11]

TASK [nameserver : Add dynamic dns records to meta] ***************************************************************************************************************************
ok: [172.21.0.11] => (item=10.10.10.2  pg-meta)
ok: [172.21.0.11] => (item=10.10.10.3  pg-test)
ok: [172.21.0.11] => (item=172.21.0.11 meta-1)
ok: [172.21.0.11] => (item=172.21.0.11 pigsty)
ok: [172.21.0.11] => (item=172.21.0.11 y.pigsty yum.pigsty)
ok: [172.21.0.11] => (item=172.21.0.11 c.pigsty consul.pigsty)
ok: [172.21.0.11] => (item=172.21.0.11 g.pigsty grafana.pigsty)
ok: [172.21.0.11] => (item=172.21.0.11 p.pigsty prometheus.pigsty)
ok: [172.21.0.11] => (item=172.21.0.11 a.pigsty alertmanager.pigsty)
ok: [172.21.0.11] => (item=172.21.0.11 n.pigsty ntp.pigsty)
ok: [172.21.0.11] => (item=172.21.0.11 h.pigsty haproxy.pigsty)

TASK [nameserver : Launch meta dnsmasq service] *******************************************************************************************************************************
changed: [172.21.0.11]

TASK [nameserver : Wait for meta dnsmasq online] ******************************************************************************************************************************
ok: [172.21.0.11]

TASK [nameserver : Register consul dnsmasq service] ***************************************************************************************************************************
changed: [172.21.0.11]

TASK [nameserver : Reload consul] *********************************************************************************************************************************************
changed: [172.21.0.11]

TASK [Make sure nginx installed] **********************************************************************************************************************************************
ok: [172.21.0.11]

TASK [Create nginx config directory] ******************************************************************************************************************************************
ok: [172.21.0.11]

TASK [nginx : Create local html directory] ************************************************************************************************************************************
ok: [172.21.0.11]

TASK [Update default nginx index page] ****************************************************************************************************************************************
changed: [172.21.0.11]

TASK [Copy nginx default config] **********************************************************************************************************************************************
ok: [172.21.0.11]

TASK [Copy nginx upstream conf] ***********************************************************************************************************************************************
changed: [172.21.0.11] => (item={u'url': u'127.0.0.1:3000', u'host': u'pigsty.cc', u'name': u'home'})
changed: [172.21.0.11] => (item={u'url': u'127.0.0.1:8500', u'host': u'c.pigsty.cc', u'name': u'consul'})
changed: [172.21.0.11] => (item={u'url': u'127.0.0.1:3000', u'host': u'g.pigsty.cc', u'name': u'grafana'})
changed: [172.21.0.11] => (item={u'url': u'127.0.0.1:3000', u'host': u'demo.pigsty.cc', u'name': u'grafana2'})
changed: [172.21.0.11] => (item={u'url': u'127.0.0.1:9090', u'host': u'p.pigsty.cc', u'name': u'prometheus'})
changed: [172.21.0.11] => (item={u'url': u'127.0.0.1:9093', u'host': u'a.pigsty.cc', u'name': u'alertmanager'})
changed: [172.21.0.11] => (item={u'url': u'127.0.0.1:9091', u'host': u'h.pigsty.cc', u'name': u'haproxy'})
changed: [172.21.0.11] => (item={u'url': u'127.0.0.1:9633', u'host': u's.pigsty.cc', u'name': u'server'})

TASK [Create nginx haproxy config dir] ****************************************************************************************************************************************
ok: [172.21.0.11]

TASK [nginx : Create haproxy proxy server config] *****************************************************************************************************************************
changed: [172.21.0.11]

TASK [Restart meta nginx service] *********************************************************************************************************************************************
changed: [172.21.0.11]

TASK [Wait for nginx service online] ******************************************************************************************************************************************
ok: [172.21.0.11]

TASK [Make sure nginx exporter installed] *************************************************************************************************************************************
ok: [172.21.0.11]

TASK [Config nginx_exporter options] ******************************************************************************************************************************************
ok: [172.21.0.11]

TASK [Restart nginx_exporter service] *****************************************************************************************************************************************
changed: [172.21.0.11]

TASK [Wait for nginx exporter online] *****************************************************************************************************************************************
ok: [172.21.0.11]

TASK [Register cosnul nginx service] ******************************************************************************************************************************************
changed: [172.21.0.11]

TASK [Register consul nginx-exporter service] *********************************************************************************************************************************
changed: [172.21.0.11]

TASK [nginx : Reload consul] **************************************************************************************************************************************************
changed: [172.21.0.11]

TASK [Install prometheus and alertmanager] ************************************************************************************************************************************
ok: [172.21.0.11] => (item=prometheus2)
ok: [172.21.0.11] => (item=alertmanager)

TASK [Wipe out prometheus config dir] *****************************************************************************************************************************************
changed: [172.21.0.11]

TASK [Wipe out existing prometheus data] **************************************************************************************************************************************
changed: [172.21.0.11]

TASK [Create prometheus directories] ******************************************************************************************************************************************
changed: [172.21.0.11] => (item=/etc/prometheus)
changed: [172.21.0.11] => (item=/etc/prometheus/bin)
changed: [172.21.0.11] => (item=/etc/prometheus/rules)
changed: [172.21.0.11] => (item=/etc/prometheus/targets)
changed: [172.21.0.11] => (item=/etc/prometheus/targets/infra)
changed: [172.21.0.11] => (item=/etc/prometheus/targets/pgsql)
changed: [172.21.0.11] => (item=/data/prometheus/data)

TASK [Copy prometheus bin scripts] ********************************************************************************************************************************************
changed: [172.21.0.11]

TASK [Copy prometheus rules] **************************************************************************************************************************************************
changed: [172.21.0.11]

TASK [Render prometheus config] ***********************************************************************************************************************************************
changed: [172.21.0.11]

TASK [prometheus : Render altermanager config] ********************************************************************************************************************************
changed: [172.21.0.11]

TASK [Config /etc/prometheus opts] ********************************************************************************************************************************************
ok: [172.21.0.11]

TASK [Launch prometheus service] **********************************************************************************************************************************************
changed: [172.21.0.11]

TASK [Wait for prometheus online] *********************************************************************************************************************************************
ok: [172.21.0.11]

TASK [prometheus : Launch alertmanager service] *******************************************************************************************************************************
changed: [172.21.0.11]

TASK [prometheus : Wait for alertmanager online] ******************************************************************************************************************************
ok: [172.21.0.11]

TASK [Render infra file-sd targets targets for prometheus] ********************************************************************************************************************
changed: [172.21.0.11]

TASK [Reload prometheus service] **********************************************************************************************************************************************
changed: [172.21.0.11]

TASK [Copy prometheus service definition] *************************************************************************************************************************************
changed: [172.21.0.11]

TASK [prometheus : Copy alertmanager service definition] **********************************************************************************************************************
changed: [172.21.0.11]

TASK [Reload consul to register prometheus] ***********************************************************************************************************************************
changed: [172.21.0.11]

TASK [Make sure grafana installed] ********************************************************************************************************************************************
ok: [172.21.0.11]

TASK [Stop grafana service] ***************************************************************************************************************************************************
changed: [172.21.0.11]

TASK [Check grafana plugin cache exists] **************************************************************************************************************************************
ok: [172.21.0.11]

TASK [Provision grafana plugins via cache if exists] **************************************************************************************************************************
changed: [172.21.0.11]

TASK [Download grafana plugins via internet] **********************************************************************************************************************************
ok: [172.21.0.11] => (item=marcusolsson-csv-datasource)
ok: [172.21.0.11] => (item=marcusolsson-json-datasource)
ok: [172.21.0.11] => (item=marcusolsson-treemap-panel)

TASK [Download grafana plugins via git] ***************************************************************************************************************************************
ok: [172.21.0.11] => (item=https://github.com/Vonng/vonng-echarts-panel)

TASK [Remove grafana provisioning config] *************************************************************************************************************************************
changed: [172.21.0.11] => (item=/etc/grafana/provisioning/dashboards/pigsty.yml)
changed: [172.21.0.11] => (item=/etc/grafana/provisioning/datasources/pigsty.yml)

TASK [Remake grafana resource dir] ********************************************************************************************************************************************
ok: [172.21.0.11] => (item=/etc/grafana/)
ok: [172.21.0.11] => (item=/etc/dashboards)
ok: [172.21.0.11] => (item=/etc/grafana/provisioning/dashboards)
ok: [172.21.0.11] => (item=/etc/grafana/provisioning/datasources)

TASK [Templating /etc/grafana/grafana.ini] ************************************************************************************************************************************
ok: [172.21.0.11]

TASK [grafana : Templating datasources provisioning config] *******************************************************************************************************************
changed: [172.21.0.11]

TASK [grafana : Templating dashboards provisioning config] ********************************************************************************************************************
changed: [172.21.0.11]

TASK [Launch grafana service] *************************************************************************************************************************************************
changed: [172.21.0.11]

TASK [Wait for grafana online] ************************************************************************************************************************************************
ok: [172.21.0.11]

TASK [Sync grafana home and core dashboards] **********************************************************************************************************************************
changed: [172.21.0.11]

TASK [Provisioning grafana with grafana.py] ***********************************************************************************************************************************
changed: [172.21.0.11]

TASK [Register consul grafana service] ****************************************************************************************************************************************
changed: [172.21.0.11]

TASK [grafana : Reload consul] ************************************************************************************************************************************************
changed: [172.21.0.11]

PLAY [Pgsql Init] *************************************************************************************************************************************************************

TASK [Create os group postgres] ***********************************************************************************************************************************************
ok: [172.21.0.11]

TASK [postgres : Make sure dcs group exists] **********************************************************************************************************************************
ok: [172.21.0.11] => (item=consul)
ok: [172.21.0.11] => (item=etcd)

TASK [Create dbsu postgres] ***************************************************************************************************************************************************
ok: [172.21.0.11]

TASK [postgres : Grant dbsu nopass sudo] **************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [postgres : Grant dbsu all sudo] *****************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [postgres : Grant dbsu limited sudo] *************************************************************************************************************************************
ok: [172.21.0.11]

TASK [postgres : Config watchdog onwer to dbsu] *******************************************************************************************************************************
ok: [172.21.0.11]

TASK [postgres : Add dbsu ssh no host checking] *******************************************************************************************************************************
ok: [172.21.0.11]

TASK [postgres : Fetch dbsu public keys] **************************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Exchange dbsu ssh keys] **************************************************************************************************************************************
ok: [172.21.0.11 -> 172.21.0.11] => (item=[u'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDWpJf8IeAIebWAyiTCrteS41iC1M15VgKq0wzUrxwF/2c8S98+pW6pITo4H2ORr7dXMpaV2zK808+MPcG8jacU2Wd4Bl0KnT/iHp9GzxINjP1ANPmd2IA4uMvvHxS08S5Sjo0BKPPSRdYLbyKvUq9yyxsjqhcPlnIY5PR/oaVb4BJqhj+i+hmQAfhahjuFWRgMFLosZ7OAdGDl7gx/t/iLcnSW43pGq5MgUOJPbHbB42xhHs0gNOYmVYD4v2rvdVw5crjbrgjHazwznLmD6dG3FWXfCiqDjnXFHG9/SwqhF23Ubaw4lS4uqHlciy0qJPaNYRG/o42zYvvJOKxJ2dW5 ansible-generated on VM-0-11-centos', u'172.21.0.11'])

TASK [postgres : Install offical pgdg yum repo] *******************************************************************************************************************************
skipping: [172.21.0.11] => (item=postgresql${pg_version}*)
skipping: [172.21.0.11] => (item=postgis31_${pg_version}*)
skipping: [172.21.0.11] => (item=citus_${pg_version})
skipping: [172.21.0.11] => (item=timescaledb_${pg_version})
skipping: [172.21.0.11] => (item=pgbouncer patroni pg_exporter pgbadger)
skipping: [172.21.0.11] => (item=patroni patroni-consul patroni-etcd pgbouncer pgbadger pg_activity)
skipping: [172.21.0.11] => (item=python3 python3-psycopg2 python36-requests python3-etcd python3-consul)
skipping: [172.21.0.11] => (item=python36-urllib3 python36-idna python36-pyOpenSSL python36-cryptography)

TASK [postgres : Install pg packages] *****************************************************************************************************************************************
changed: [172.21.0.11] => (item=[u'postgresql13*', u'postgis31_13*', u'citus_13', u'timescaledb_13', u'pgbouncer,patroni,pg_exporter,pgbadger', u'patroni,patroni-consul,patroni-etcd,pgbouncer,pgbadger,pg_activity', u'python3,python3-psycopg2,python36-requests,python3-etcd,python3-consul', u'python36-urllib3,python36-idna,python36-pyOpenSSL,python36-cryptography'])

TASK [postgres : Install pg extensions] ***************************************************************************************************************************************
changed: [172.21.0.11] => (item=[u'pg_repack13,pg_qualstats13,pg_stat_kcache13,wal2json13'])

TASK [postgres : Link /usr/pgsql to current version] **************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Add pg bin dir to profile path] ******************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Fix directory ownership] *************************************************************************************************************************************
ok: [172.21.0.11]

TASK [Remove default postgres service] ****************************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Check necessary variables exists] ****************************************************************************************************************************
ok: [172.21.0.11] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [postgres : Fetch variables via pg_cluster] ******************************************************************************************************************************
ok: [172.21.0.11]

TASK [postgres : Set cluster basic facts for hosts] ***************************************************************************************************************************
ok: [172.21.0.11]

TASK [postgres : Assert cluster primary singleton] ****************************************************************************************************************************
ok: [172.21.0.11] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [postgres : Setup cluster primary ip address] ****************************************************************************************************************************
ok: [172.21.0.11]

TASK [postgres : Setup repl upstream for primary] *****************************************************************************************************************************
skipping: [172.21.0.11]

TASK [postgres : Setup repl upstream for replicas] ****************************************************************************************************************************
skipping: [172.21.0.11]

TASK [postgres : Debug print instance summary] ********************************************************************************************************************************
ok: [172.21.0.11] => {
    "msg": "cluster=pg-meta service=pg-meta-primary instance=pg-meta-1 replication=[primary:itself]->172.21.0.11"
}

TASK [Check for existing postgres instance] ***********************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Set fact whether pg port is open] ****************************************************************************************************************************
ok: [172.21.0.11]

TASK [Abort due to existing postgres instance] ********************************************************************************************************************************
skipping: [172.21.0.11]

TASK [Clean existing postgres instance] ***************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [Shutdown existing postgres service] *************************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Remove registerd consul service] *****************************************************************************************************************************
changed: [172.21.0.11]

TASK [Remove postgres metadata in consul] *************************************************************************************************************************************
changed: [172.21.0.11]

TASK [Remove existing postgres data] ******************************************************************************************************************************************
ok: [172.21.0.11] => (item=/pg)
ok: [172.21.0.11] => (item=/data/postgres)
ok: [172.21.0.11] => (item=/data/backups/postgres)
changed: [172.21.0.11] => (item=/etc/pgbouncer)
changed: [172.21.0.11] => (item=/var/log/pgbouncer)
changed: [172.21.0.11] => (item=/var/run/pgbouncer)

TASK [postgres : Make sure main and backup dir exists] ************************************************************************************************************************
changed: [172.21.0.11] => (item=/data)
changed: [172.21.0.11] => (item=/data/backups)

TASK [Create postgres directory structure] ************************************************************************************************************************************
changed: [172.21.0.11] => (item=/data/postgres)
changed: [172.21.0.11] => (item=/data/postgres/pg-meta-13)
changed: [172.21.0.11] => (item=/data/postgres/pg-meta-13/bin)
changed: [172.21.0.11] => (item=/data/postgres/pg-meta-13/log)
changed: [172.21.0.11] => (item=/data/postgres/pg-meta-13/tmp)
changed: [172.21.0.11] => (item=/data/postgres/pg-meta-13/conf)
changed: [172.21.0.11] => (item=/data/postgres/pg-meta-13/data)
changed: [172.21.0.11] => (item=/data/postgres/pg-meta-13/meta)
changed: [172.21.0.11] => (item=/data/postgres/pg-meta-13/stat)
changed: [172.21.0.11] => (item=/data/postgres/pg-meta-13/change)
changed: [172.21.0.11] => (item=/data/backups/postgres/pg-meta-13/postgres)
changed: [172.21.0.11] => (item=/data/backups/postgres/pg-meta-13/arcwal)
changed: [172.21.0.11] => (item=/data/backups/postgres/pg-meta-13/backup)
changed: [172.21.0.11] => (item=/data/backups/postgres/pg-meta-13/remote)

TASK [postgres : Create pgbouncer directory structure] ************************************************************************************************************************
changed: [172.21.0.11] => (item=/etc/pgbouncer)
changed: [172.21.0.11] => (item=/var/log/pgbouncer)
changed: [172.21.0.11] => (item=/var/run/pgbouncer)

TASK [postgres : Create links from pgbkup to pgroot] **************************************************************************************************************************
changed: [172.21.0.11] => (item=arcwal)
changed: [172.21.0.11] => (item=backup)
changed: [172.21.0.11] => (item=remote)

TASK [postgres : Create links from current cluster] ***************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Copy pg_cluster to /pg/meta/cluster] *************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Copy pg_version to /pg/meta/version] *************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Copy pg_instance to /pg/meta/instance] ***********************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Copy pg_seq to /pg/meta/sequence] ****************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Copy pg_role to /pg/meta/role] *******************************************************************************************************************************
changed: [172.21.0.11]

TASK [Copy postgres scripts to /pg/bin/] **************************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Copy alias profile to /etc/profile.d] ************************************************************************************************************************
changed: [172.21.0.11]

TASK [Copy psqlrc to postgres home] *******************************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Setup hostname to pg instance name] **************************************************************************************************************************
skipping: [172.21.0.11]

TASK [postgres : Copy consul node-meta definition] ****************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Restart consul to load new node-meta] ************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Get config parameter page count] *****************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Get config parameter page size] ******************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Tune shared buffer and work mem] *****************************************************************************************************************************
ok: [172.21.0.11]

TASK [postgres : Hanlde small size mem occasion] ******************************************************************************************************************************
skipping: [172.21.0.11]

TASK [Calculate postgres mem params] ******************************************************************************************************************************************
ok: [172.21.0.11]

TASK [postgres : create patroni config dir] ***********************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : use predefined patroni template] *****************************************************************************************************************************
skipping: [172.21.0.11]

TASK [postgres : Render default /pg/conf/patroni.yml] *************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Link /pg/conf/patroni to /pg/bin/] ***************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Link /pg/bin/patroni.yml to /etc/patroni/] *******************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Config patroni watchdog support] *****************************************************************************************************************************
ok: [172.21.0.11]

TASK [postgres : Copy patroni systemd service file] ***************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : create patroni systemd drop-in dir] **************************************************************************************************************************
changed: [172.21.0.11]

TASK [Copy postgres systemd service file] *************************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Drop-In systemd config for patroni] **************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Launch patroni on primary instance] **************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Wait for patroni primary online] *****************************************************************************************************************************
ok: [172.21.0.11]

TASK [Wait for postgres primary online] ***************************************************************************************************************************************
ok: [172.21.0.11]

TASK [Check primary postgres service ready] ***********************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Check replication connectivity on primary] *******************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Render init roles sql] ***************************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Render init template sql] ************************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Render default pg-init scripts] ******************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Execute initialization scripts] ******************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Check primary instance ready] ********************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Add dbsu password to pgpass if exists] ***********************************************************************************************************************
skipping: [172.21.0.11]

TASK [postgres : Add system user to pgpass] ***********************************************************************************************************************************
changed: [172.21.0.11] => (item={u'username': u'replicator', u'password': u'DBUser.Replicator'})
changed: [172.21.0.11] => (item={u'username': u'dbuser_monitor', u'password': u'DBUser.Monitor'})
changed: [172.21.0.11] => (item={u'username': u'dbuser_dba', u'password': u'DBUser.DBA'})

TASK [postgres : Check replication connectivity to primary] *******************************************************************************************************************
skipping: [172.21.0.11]

TASK [postgres : Launch patroni on replica instances] *************************************************************************************************************************
skipping: [172.21.0.11]

TASK [postgres : Wait for patroni replica online] *****************************************************************************************************************************
skipping: [172.21.0.11]

TASK [Wait for postgres replica online] ***************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [Check replica postgres service ready] ***********************************************************************************************************************************
skipping: [172.21.0.11]

TASK [postgres : Render hba rules] ********************************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Reload hba rules] ********************************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Pause patroni] ***********************************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Stop patroni on replica instance] ****************************************************************************************************************************
skipping: [172.21.0.11]

TASK [postgres : Stop patroni on primary instance] ****************************************************************************************************************************
skipping: [172.21.0.11]

TASK [Launch raw postgres on primary] *****************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [Launch raw postgres on replicas] ****************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [Wait for postgres online] ***********************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [postgres : Check pgbouncer is installed] ********************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Stop existing pgbouncer service] *****************************************************************************************************************************
ok: [172.21.0.11]

TASK [postgres : Remove existing pgbouncer dirs] ******************************************************************************************************************************
changed: [172.21.0.11] => (item=/etc/pgbouncer)
changed: [172.21.0.11] => (item=/var/log/pgbouncer)
changed: [172.21.0.11] => (item=/var/run/pgbouncer)

TASK [Recreate dirs with owner postgres] **************************************************************************************************************************************
changed: [172.21.0.11] => (item=/etc/pgbouncer)
changed: [172.21.0.11] => (item=/var/log/pgbouncer)
changed: [172.21.0.11] => (item=/var/run/pgbouncer)

TASK [postgres : Copy /etc/pgbouncer/pgbouncer.ini] ***************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Copy /etc/pgbouncer/pgb_hba.conf] ****************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Touch userlist and database list] ****************************************************************************************************************************
changed: [172.21.0.11] => (item=database.txt)
changed: [172.21.0.11] => (item=userlist.txt)

TASK [postgres : Add default users to pgbouncer] ******************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Init pgbouncer business database list] ***********************************************************************************************************************
changed: [172.21.0.11] => (item={u'comment': u'pigsty meta database', u'extensions': [{u'name': u'adminpack', u'schema': u'pg_catalog'}, {u'name': u'postgis', u'schema': u'public'}], u'name': u'meta', u'connlimit': -1, u'baseline': u'cmdb.sql', u'schemas': [u'pigsty']})

TASK [postgres : Init pgbouncer business user list] ***************************************************************************************************************************
changed: [172.21.0.11] => (item={u'comment': u'pigsty admin user', u'superuser': False, u'pgbouncer': True, u'createdb': False, u'createrole': False, u'replication': False, u'roles': [u'dbrole_admin'], u'password': u'md5d3d10d8cad606308bdb180148bf663e1', u'name': u'dbuser_meta', u'bypassrls': False, u'connlimit': -1, u'parameters': {}, u'inherit': True, u'login': True, u'expire_in': 3650, u'expire_at': u'2030-12-31'})
changed: [172.21.0.11] => (item={u'comment': u'read-only viewer for meta database', u'roles': [u'dbrole_readonly'], u'password': u'DBUser.Viewer', u'name': u'dbuser_view', u'pgbouncer': True})

TASK [postgres : Copy pgbouncer systemd service] ******************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Launch pgbouncer pool service] *******************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Wait for pgbouncer service online] ***************************************************************************************************************************
ok: [172.21.0.11]

TASK [postgres : Check pgbouncer service is ready] ****************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : include_tasks] ***********************************************************************************************************************************************
included: /root/pigsty/roles/postgres/tasks/createuser.yml for 172.21.0.11
included: /root/pigsty/roles/postgres/tasks/createuser.yml for 172.21.0.11

TASK [postgres : Render user dbuser_meta creation sql] ************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Execute user dbuser_meta creation sql on primary] ************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Add business user to pgbouncer] ******************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Render user dbuser_view creation sql] ************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Execute user dbuser_view creation sql on primary] ************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Add business user to pgbouncer] ******************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : include_tasks] ***********************************************************************************************************************************************
included: /root/pigsty/roles/postgres/tasks/createdb.yml for 172.21.0.11

TASK [postgres : debug] *******************************************************************************************************************************************************
ok: [172.21.0.11] => {
    "msg": {
        "baseline": "cmdb.sql",
        "comment": "pigsty meta database",
        "connlimit": -1,
        "extensions": [
            {
                "name": "adminpack",
                "schema": "pg_catalog"
            },
            {
                "name": "postgis",
                "schema": "public"
            }
        ],
        "name": "meta",
        "schemas": [
            "pigsty"
        ]
    }
}

TASK [postgres : Render database meta creation sql] ***************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Render database meta baseline sql] ***************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Execute database meta creation command] **********************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Execute database meta creation sql] **************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Execute database meta baseline sql] **************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Add biz database to pgbouncer] *******************************************************************************************************************************
changed: [172.21.0.11]

TASK [postgres : Reload pgbouncer to add db and users] ************************************************************************************************************************
changed: [172.21.0.11]

TASK [monitor : Install exporter yum repo] ************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [monitor : Install node_exporter and pg_exporter] ************************************************************************************************************************
skipping: [172.21.0.11] => (item=node_exporter)
skipping: [172.21.0.11] => (item=pg_exporter)

TASK [monitor : Copy exporter binaries] ***************************************************************************************************************************************
skipping: [172.21.0.11] => (item=node_exporter)
skipping: [172.21.0.11] => (item=pg_exporter)
skipping: [172.21.0.11] => (item=promtail)

TASK [monitor : Create /etc/pg_exporter conf dir] *****************************************************************************************************************************
changed: [172.21.0.11]

TASK [monitor : Copy default pg_exporter.yaml] ********************************************************************************************************************************
changed: [172.21.0.11]

TASK [monitor : Config /etc/default/pg_exporter] ******************************************************************************************************************************
changed: [172.21.0.11]

TASK [monitor : Config pg_exporter service unit] ******************************************************************************************************************************
changed: [172.21.0.11]

TASK [monitor : Launch pg_exporter systemd service] ***************************************************************************************************************************
changed: [172.21.0.11]

TASK [monitor : Wait for pg_exporter service online] **************************************************************************************************************************
ok: [172.21.0.11]

TASK [monitor : Config pgbouncer_exporter opts] *******************************************************************************************************************************
changed: [172.21.0.11]

TASK [monitor : Config pgbouncer_exporter service] ****************************************************************************************************************************
changed: [172.21.0.11]

TASK [monitor : Launch pgbouncer_exporter service] ****************************************************************************************************************************
changed: [172.21.0.11]

TASK [monitor : Wait for pgbouncer_exporter online] ***************************************************************************************************************************
ok: [172.21.0.11]

TASK [monitor : Copy node_exporter systemd service] ***************************************************************************************************************************
changed: [172.21.0.11]

TASK [monitor : Config default node_exporter options] *************************************************************************************************************************
changed: [172.21.0.11]

TASK [monitor : Launch node_exporter service unit] ****************************************************************************************************************************
changed: [172.21.0.11]

TASK [monitor : Wait for node_exporter online] ********************************************************************************************************************************
ok: [172.21.0.11]

TASK [service : Make sure haproxy is installed] *******************************************************************************************************************************
ok: [172.21.0.11]

TASK [service : Create haproxy directory] *************************************************************************************************************************************
ok: [172.21.0.11]

TASK [Copy haproxy systemd service file] **************************************************************************************************************************************
changed: [172.21.0.11]

TASK [service : Fetch postgres cluster memberships] ***************************************************************************************************************************
ok: [172.21.0.11]

TASK [service : Templating /etc/haproxy/haproxy.cfg] **************************************************************************************************************************
changed: [172.21.0.11]

TASK [Launch haproxy load balancer service] ***********************************************************************************************************************************
changed: [172.21.0.11]

TASK [service : Wait for haproxy load balancer online] ************************************************************************************************************************
ok: [172.21.0.11]

TASK [Reload haproxy load balancer service] ***********************************************************************************************************************************
changed: [172.21.0.11]

TASK [service : Make sure vip-manager is installed] ***************************************************************************************************************************
skipping: [172.21.0.11]

TASK [Copy vip-manager systemd service file] **********************************************************************************************************************************
skipping: [172.21.0.11]

TASK [service : create vip-manager systemd drop-in dir] ***********************************************************************************************************************
skipping: [172.21.0.11]

TASK [service : create vip-manager systemd drop-in file] **********************************************************************************************************************
skipping: [172.21.0.11]

TASK [service : Templating /etc/default/vip-manager.yml] **********************************************************************************************************************
skipping: [172.21.0.11]

TASK [service : Launch vip-manager] *******************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [service : Fetch postgres cluster memberships] ***************************************************************************************************************************
skipping: [172.21.0.11]

TASK [service : Render L4 VIP configs] ****************************************************************************************************************************************
skipping: [172.21.0.11] => (item={u'src_ip': u'*', u'check_url': u'/primary', u'src_port': 5433, u'name': u'primary', u'dst_port': u'pgbouncer', u'selector': u'[]'})
skipping: [172.21.0.11] => (item={u'src_ip': u'*', u'check_url': u'/read-only', u'src_port': 5434, u'name': u'replica', u'selector_backup': u'[? pg_role == `primary`]', u'dst_port': u'pgbouncer', u'selector': u'[]'})
skipping: [172.21.0.11] => (item={u'haproxy': {u'default_server_options': u'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100', u'balance': u'roundrobin', u'maxconn': 3000}, u'check_url': u'/primary', u'src_port': 5436, u'name': u'default', u'check_method': u'http', u'selector': u'[]', u'src_ip': u'*', u'dst_port': u'postgres', u'check_code': 200, u'check_port': u'patroni'})
skipping: [172.21.0.11] => (item={u'src_ip': u'*', u'check_url': u'/replica', u'src_port': 5438, u'name': u'offline', u'selector_backup': u'[? pg_role == `replica` && !pg_offline_query]', u'dst_port': u'postgres', u'selector': u'[? pg_role == `offline` || pg_offline_query ]'})

TASK [service : include_tasks] ************************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [register : Register postgres service to consul] *************************************************************************************************************************
changed: [172.21.0.11]

TASK [register : Register patroni service to consul] **************************************************************************************************************************
changed: [172.21.0.11]

TASK [register : Register pgbouncer service to consul] ************************************************************************************************************************
changed: [172.21.0.11]

TASK [register : Register node-exporter service to consul] ********************************************************************************************************************
changed: [172.21.0.11]

TASK [register : Register pg_exporter service to consul] **********************************************************************************************************************
changed: [172.21.0.11]

TASK [register : Register pgbouncer_exporter service to consul] ***************************************************************************************************************
changed: [172.21.0.11]

TASK [register : Register haproxy (exporter) service to consul] ***************************************************************************************************************
changed: [172.21.0.11]

TASK [register : Register cluster service to consul] **************************************************************************************************************************
changed: [172.21.0.11] => (item={u'src_ip': u'*', u'check_url': u'/primary', u'src_port': 5433, u'name': u'primary', u'dst_port': u'pgbouncer', u'selector': u'[]'})
changed: [172.21.0.11] => (item={u'src_ip': u'*', u'check_url': u'/read-only', u'src_port': 5434, u'name': u'replica', u'selector_backup': u'[? pg_role == `primary`]', u'dst_port': u'pgbouncer', u'selector': u'[]'})
changed: [172.21.0.11] => (item={u'haproxy': {u'default_server_options': u'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100', u'balance': u'roundrobin', u'maxconn': 3000}, u'check_url': u'/primary', u'src_port': 5436, u'name': u'default', u'check_method': u'http', u'selector': u'[]', u'src_ip': u'*', u'dst_port': u'postgres', u'check_code': 200, u'check_port': u'patroni'})
changed: [172.21.0.11] => (item={u'src_ip': u'*', u'check_url': u'/replica', u'src_port': 5438, u'name': u'offline', u'selector_backup': u'[? pg_role == `replica` && !pg_offline_query]', u'dst_port': u'postgres', u'selector': u'[? pg_role == `offline` || pg_offline_query ]'})

TASK [Reload consul to finish register] ***************************************************************************************************************************************
changed: [172.21.0.11]

TASK [register : Register pgsql instance as prometheus target] ****************************************************************************************************************
changed: [172.21.0.11 -> 172.21.0.11] => (item=172.21.0.11)

TASK [register : Render datasource definition on meta node] *******************************************************************************************************************
changed: [172.21.0.11 -> meta] => (item={u'comment': u'pigsty meta database', u'extensions': [{u'name': u'adminpack', u'schema': u'pg_catalog'}, {u'name': u'postgis', u'schema': u'public'}], u'name': u'meta', u'connlimit': -1, u'baseline': u'cmdb.sql', u'schemas': [u'pigsty']})

TASK [register : Load grafana datasource on meta node] ************************************************************************************************************************
changed: [172.21.0.11 -> meta] => (item={u'comment': u'pigsty meta database', u'extensions': [{u'name': u'adminpack', u'schema': u'pg_catalog'}, {u'name': u'postgis', u'schema': u'public'}], u'name': u'meta', u'connlimit': -1, u'baseline': u'cmdb.sql', u'schemas': [u'pigsty']})

TASK [register : Create haproxy config dir resource dirs on /etc/pigsty] ******************************************************************************************************
ok: [172.21.0.11 -> 172.21.0.11] => (item=172.21.0.11)

TASK [register : Register haproxy upstream to nginx] **************************************************************************************************************************
changed: [172.21.0.11 -> 172.21.0.11] => (item=172.21.0.11)

TASK [register : Register haproxy url location to nginx] **********************************************************************************************************************
changed: [172.21.0.11 -> 172.21.0.11] => (item=172.21.0.11)

TASK [Reload nginx to finish haproxy register] ********************************************************************************************************************************
changed: [172.21.0.11 -> 172.21.0.11] => (item=172.21.0.11)

PLAY RECAP ********************************************************************************************************************************************************************
172.21.0.11                : ok=267  changed=160  unreachable=0    failed=0    skipped=68   rescued=0    ignored=0

```

</details>




## 访问Demo

现在，您可以通过公网IP访问元节点上的服务了！请注意做好信息安全工作！

* http://42.193.127.40:3000

* http://demo.pigsty.cc





------------------------


## 部署额外集群`pg-test`

Pigsty可用于部署，管理多套高可用数据库集群。

编辑配置文件`pigsty.yml`，在`all.children`下添加以下的新集群定义。（与`pg-meta`, `meta`并列）


```bash
#----------------------------------#
# cluster: pg-test (public demo)   #
#----------------------------------#
pg-test:                                # define the new 3-node cluster pg-test
  hosts:
    172.21.0.3:  {pg_seq: 1, pg_role: primary}   # primary instance, leader of cluster
    172.21.0.4:  {pg_seq: 2, pg_role: replica}   # replica instance, follower of leader
    172.21.0.16: {pg_seq: 3, pg_role: offline}   # offline instance, replica that allow offline access
  vars:
    pg_cluster: pg-test                 # define actual cluster name
    pg_version: 13                      # test postgresql 13 with pg-test cluster
    pg_users: [{name: test , password: test  ,pgbouncer: true ,roles: [dbrole_admin], comment: test user for test database cluster }]
    pg_databases: [{ name: test}]       # create a database and user named 'test'
```

然后执行 [pgsql.yml](p-pgsql.md) ，创建该数据库集群。

```bash
./pgsql.yml -l pg-test
```


<details>
<summary>部署新数据库集群pg-test的标准输出</summary>

```bash
[root@VM-0-11-centos pigsty]# ./pgsql.yml -l pg-test
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see details

PLAY [Infra Init] *************************************************************************************************************************************************************

TASK [Update node hostname] ***************************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [node : Add new hostname to /etc/hosts] **********************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [node : Write static dns records] ****************************************************************************************************************************************
changed: [172.21.0.3] => (item=172.21.0.11 yum.pigsty)
changed: [172.21.0.4] => (item=172.21.0.11 yum.pigsty)
changed: [172.21.0.16] => (item=172.21.0.11 yum.pigsty)
changed: [172.21.0.3] => (item=172.21.0.11 meta   pg-meta-1)
changed: [172.21.0.16] => (item=172.21.0.11 meta   pg-meta-1)
changed: [172.21.0.4] => (item=172.21.0.11 meta   pg-meta-1)
changed: [172.21.0.3] => (item=10.10.10.11 node-1 pg-test-1)
changed: [172.21.0.16] => (item=10.10.10.11 node-1 pg-test-1)
changed: [172.21.0.4] => (item=10.10.10.11 node-1 pg-test-1)
changed: [172.21.0.3] => (item=10.10.10.12 node-2 pg-test-2)
changed: [172.21.0.16] => (item=10.10.10.12 node-2 pg-test-2)
changed: [172.21.0.4] => (item=10.10.10.12 node-2 pg-test-2)
changed: [172.21.0.3] => (item=10.10.10.13 node-2 pg-test-3)
changed: [172.21.0.16] => (item=10.10.10.13 node-2 pg-test-3)
changed: [172.21.0.4] => (item=10.10.10.13 node-2 pg-test-3)

TASK [node : Get old nameservers] *********************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.4]
skipping: [172.21.0.16]

TASK [node : Write tmp resolv file] *******************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [node : Write resolv options] ********************************************************************************************************************************************
skipping: [172.21.0.3] => (item=options single-request-reopen timeout:1 rotate)
skipping: [172.21.0.3] => (item=domain service.consul)
skipping: [172.21.0.16] => (item=options single-request-reopen timeout:1 rotate)
skipping: [172.21.0.16] => (item=domain service.consul)
skipping: [172.21.0.4] => (item=options single-request-reopen timeout:1 rotate)
skipping: [172.21.0.4] => (item=domain service.consul)

TASK [node : Write additional nameservers] ************************************************************************************************************************************
skipping: [172.21.0.16] => (item=172.21.0.11)
skipping: [172.21.0.3] => (item=172.21.0.11)
skipping: [172.21.0.4] => (item=172.21.0.11)

TASK [node : Append existing nameservers] *************************************************************************************************************************************
skipping: [172.21.0.16]
skipping: [172.21.0.3]
skipping: [172.21.0.4]

TASK [node : Swap resolv.conf] ************************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [node : Node configure disable firewall] *********************************************************************************************************************************
ok: [172.21.0.16]
ok: [172.21.0.3]
ok: [172.21.0.4]

TASK [node : Node disable selinux by default] *********************************************************************************************************************************
ok: [172.21.0.16]
ok: [172.21.0.3]
ok: [172.21.0.4]

TASK [node : Backup existing repos] *******************************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [node : Install upstream repo] *******************************************************************************************************************************************
skipping: [172.21.0.3] => (item={u'gpgcheck': False, u'description': u'CentOS-$releasever - Base', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/os/$basearch/', u'http://mirrors.aliyun.com/centos/$releasever/os/$basearch/', u'http://mirrors.aliyuncs.com/centos/$releasever/os/$basearch/', u'http://mirrors.cloud.aliyuncs.com/centos/$releasever/os/$basearch/', u'http://mirror.centos.org/centos/$releasever/os/$basearch/'], u'name': u'base'})
skipping: [172.21.0.3] => (item={u'gpgcheck': False, u'description': u'CentOS-$releasever - Updates', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/updates/$basearch/', u'http://mirrors.aliyun.com/centos/$releasever/updates/$basearch/', u'http://mirrors.aliyuncs.com/centos/$releasever/updates/$basearch/', u'http://mirrors.cloud.aliyuncs.com/centos/$releasever/updates/$basearch/', u'http://mirror.centos.org/centos/$releasever/updates/$basearch/'], u'name': u'updates'})
skipping: [172.21.0.16] => (item={u'gpgcheck': False, u'description': u'CentOS-$releasever - Base', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/os/$basearch/', u'http://mirrors.aliyun.com/centos/$releasever/os/$basearch/', u'http://mirrors.aliyuncs.com/centos/$releasever/os/$basearch/', u'http://mirrors.cloud.aliyuncs.com/centos/$releasever/os/$basearch/', u'http://mirror.centos.org/centos/$releasever/os/$basearch/'], u'name': u'base'})
skipping: [172.21.0.16] => (item={u'gpgcheck': False, u'description': u'CentOS-$releasever - Updates', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/updates/$basearch/', u'http://mirrors.aliyun.com/centos/$releasever/updates/$basearch/', u'http://mirrors.aliyuncs.com/centos/$releasever/updates/$basearch/', u'http://mirrors.cloud.aliyuncs.com/centos/$releasever/updates/$basearch/', u'http://mirror.centos.org/centos/$releasever/updates/$basearch/'], u'name': u'updates'})
skipping: [172.21.0.3] => (item={u'gpgcheck': False, u'description': u'CentOS-$releasever - Extras', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/extras/$basearch/', u'http://mirrors.aliyun.com/centos/$releasever/extras/$basearch/', u'http://mirrors.aliyuncs.com/centos/$releasever/extras/$basearch/', u'http://mirrors.cloud.aliyuncs.com/centos/$releasever/extras/$basearch/', u'http://mirror.centos.org/centos/$releasever/extras/$basearch/'], u'name': u'extras'})
skipping: [172.21.0.16] => (item={u'gpgcheck': False, u'description': u'CentOS-$releasever - Extras', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/extras/$basearch/', u'http://mirrors.aliyun.com/centos/$releasever/extras/$basearch/', u'http://mirrors.aliyuncs.com/centos/$releasever/extras/$basearch/', u'http://mirrors.cloud.aliyuncs.com/centos/$releasever/extras/$basearch/', u'http://mirror.centos.org/centos/$releasever/extras/$basearch/'], u'name': u'extras'})
skipping: [172.21.0.3] => (item={u'gpgcheck': False, u'description': u'CentOS $releasever - epel', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/epel/$releasever/$basearch', u'http://mirrors.aliyun.com/epel/$releasever/$basearch', u'http://download.fedoraproject.org/pub/epel/$releasever/$basearch'], u'name': u'epel'})
skipping: [172.21.0.16] => (item={u'gpgcheck': False, u'description': u'CentOS $releasever - epel', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/epel/$releasever/$basearch', u'http://mirrors.aliyun.com/epel/$releasever/$basearch', u'http://download.fedoraproject.org/pub/epel/$releasever/$basearch'], u'name': u'epel'})
skipping: [172.21.0.4] => (item={u'gpgcheck': False, u'description': u'CentOS-$releasever - Base', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/os/$basearch/', u'http://mirrors.aliyun.com/centos/$releasever/os/$basearch/', u'http://mirrors.aliyuncs.com/centos/$releasever/os/$basearch/', u'http://mirrors.cloud.aliyuncs.com/centos/$releasever/os/$basearch/', u'http://mirror.centos.org/centos/$releasever/os/$basearch/'], u'name': u'base'})
skipping: [172.21.0.3] => (item={u'gpgcheck': False, u'enabled': True, u'description': u'Grafana', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/grafana/yum/rpm', u'https://packages.grafana.com/oss/rpm'], u'name': u'grafana'})
skipping: [172.21.0.4] => (item={u'gpgcheck': False, u'description': u'CentOS-$releasever - Updates', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/updates/$basearch/', u'http://mirrors.aliyun.com/centos/$releasever/updates/$basearch/', u'http://mirrors.aliyuncs.com/centos/$releasever/updates/$basearch/', u'http://mirrors.cloud.aliyuncs.com/centos/$releasever/updates/$basearch/', u'http://mirror.centos.org/centos/$releasever/updates/$basearch/'], u'name': u'updates'})
skipping: [172.21.0.16] => (item={u'gpgcheck': False, u'enabled': True, u'description': u'Grafana', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/grafana/yum/rpm', u'https://packages.grafana.com/oss/rpm'], u'name': u'grafana'})
skipping: [172.21.0.3] => (item={u'gpgcheck': False, u'description': u'Prometheus and exporters', u'baseurl': u'https://packagecloud.io/prometheus-rpm/release/el/$releasever/$basearch', u'name': u'prometheus'})
skipping: [172.21.0.16] => (item={u'gpgcheck': False, u'description': u'Prometheus and exporters', u'baseurl': u'https://packagecloud.io/prometheus-rpm/release/el/$releasever/$basearch', u'name': u'prometheus'})
skipping: [172.21.0.4] => (item={u'gpgcheck': False, u'description': u'CentOS-$releasever - Extras', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/extras/$basearch/', u'http://mirrors.aliyun.com/centos/$releasever/extras/$basearch/', u'http://mirrors.aliyuncs.com/centos/$releasever/extras/$basearch/', u'http://mirrors.cloud.aliyuncs.com/centos/$releasever/extras/$basearch/', u'http://mirror.centos.org/centos/$releasever/extras/$basearch/'], u'name': u'extras'})
skipping: [172.21.0.3] => (item={u'gpgcheck': False, u'description': u'PostgreSQL common RPMs for RHEL/CentOS $releasever - $basearch', u'baseurl': [u'http://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/redhat/rhel-$releasever-$basearch', u'https://download.postgresql.org/pub/repos/yum/common/redhat/rhel-$releasever-$basearch'], u'name': u'pgdg-common'})
skipping: [172.21.0.4] => (item={u'gpgcheck': False, u'description': u'CentOS $releasever - epel', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/epel/$releasever/$basearch', u'http://mirrors.aliyun.com/epel/$releasever/$basearch', u'http://download.fedoraproject.org/pub/epel/$releasever/$basearch'], u'name': u'epel'})
skipping: [172.21.0.16] => (item={u'gpgcheck': False, u'description': u'PostgreSQL common RPMs for RHEL/CentOS $releasever - $basearch', u'baseurl': [u'http://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/redhat/rhel-$releasever-$basearch', u'https://download.postgresql.org/pub/repos/yum/common/redhat/rhel-$releasever-$basearch'], u'name': u'pgdg-common'})
skipping: [172.21.0.3] => (item={u'gpgcheck': False, u'description': u'PostgreSQL 13 for RHEL/CentOS $releasever - $basearch', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/13/redhat/rhel-$releasever-$basearch', u'https://download.postgresql.org/pub/repos/yum/13/redhat/rhel-$releasever-$basearch'], u'name': u'pgdg13'})
skipping: [172.21.0.3] => (item={u'gpgcheck': False, u'description': u'CentOS-$releasever - SCLo', u'baseurl': [u'http://mirrors.aliyun.com/centos/$releasever/sclo/$basearch/sclo/', u'http://repo.virtualhosting.hk/centos/$releasever/sclo/$basearch/sclo/'], u'name': u'centos-sclo'})
skipping: [172.21.0.4] => (item={u'gpgcheck': False, u'enabled': True, u'description': u'Grafana', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/grafana/yum/rpm', u'https://packages.grafana.com/oss/rpm'], u'name': u'grafana'})
skipping: [172.21.0.16] => (item={u'gpgcheck': False, u'description': u'PostgreSQL 13 for RHEL/CentOS $releasever - $basearch', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/13/redhat/rhel-$releasever-$basearch', u'https://download.postgresql.org/pub/repos/yum/13/redhat/rhel-$releasever-$basearch'], u'name': u'pgdg13'})
skipping: [172.21.0.4] => (item={u'gpgcheck': False, u'description': u'Prometheus and exporters', u'baseurl': u'https://packagecloud.io/prometheus-rpm/release/el/$releasever/$basearch', u'name': u'prometheus'})
skipping: [172.21.0.16] => (item={u'gpgcheck': False, u'description': u'CentOS-$releasever - SCLo', u'baseurl': [u'http://mirrors.aliyun.com/centos/$releasever/sclo/$basearch/sclo/', u'http://repo.virtualhosting.hk/centos/$releasever/sclo/$basearch/sclo/'], u'name': u'centos-sclo'})
skipping: [172.21.0.3] => (item={u'gpgcheck': False, u'description': u'CentOS-$releasever - SCLo rh', u'baseurl': [u'http://mirrors.aliyun.com/centos/$releasever/sclo/$basearch/rh/', u'http://repo.virtualhosting.hk/centos/$releasever/sclo/$basearch/rh/'], u'name': u'centos-sclo-rh'})
skipping: [172.21.0.16] => (item={u'gpgcheck': False, u'description': u'CentOS-$releasever - SCLo rh', u'baseurl': [u'http://mirrors.aliyun.com/centos/$releasever/sclo/$basearch/rh/', u'http://repo.virtualhosting.hk/centos/$releasever/sclo/$basearch/rh/'], u'name': u'centos-sclo-rh'})
skipping: [172.21.0.3] => (item={u'gpgcheck': False, u'skip_if_unavailable': True, u'name': u'nginx', u'baseurl': u'http://nginx.org/packages/centos/$releasever/$basearch/', u'description': u'Nginx Official Yum Repo'})
skipping: [172.21.0.4] => (item={u'gpgcheck': False, u'description': u'PostgreSQL common RPMs for RHEL/CentOS $releasever - $basearch', u'baseurl': [u'http://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/common/redhat/rhel-$releasever-$basearch', u'https://download.postgresql.org/pub/repos/yum/common/redhat/rhel-$releasever-$basearch'], u'name': u'pgdg-common'})
skipping: [172.21.0.16] => (item={u'gpgcheck': False, u'skip_if_unavailable': True, u'name': u'nginx', u'baseurl': u'http://nginx.org/packages/centos/$releasever/$basearch/', u'description': u'Nginx Official Yum Repo'})
skipping: [172.21.0.3] => (item={u'gpgcheck': False, u'skip_if_unavailable': True, u'name': u'haproxy', u'baseurl': u'https://download.copr.fedorainfracloud.org/results/roidelapluie/haproxy/epel-$releasever-$basearch/', u'description': u'Copr repo for haproxy'})
skipping: [172.21.0.4] => (item={u'gpgcheck': False, u'description': u'PostgreSQL 13 for RHEL/CentOS $releasever - $basearch', u'baseurl': [u'https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/13/redhat/rhel-$releasever-$basearch', u'https://download.postgresql.org/pub/repos/yum/13/redhat/rhel-$releasever-$basearch'], u'name': u'pgdg13'})
skipping: [172.21.0.16] => (item={u'gpgcheck': False, u'skip_if_unavailable': True, u'name': u'haproxy', u'baseurl': u'https://download.copr.fedorainfracloud.org/results/roidelapluie/haproxy/epel-$releasever-$basearch/', u'description': u'Copr repo for haproxy'})
skipping: [172.21.0.3] => (item={u'gpgcheck': False, u'skip_if_unavailable': True, u'name': u'harbottle', u'baseurl': u'https://download.copr.fedorainfracloud.org/results/harbottle/main/epel-$releasever-$basearch/', u'description': u'Copr repo for main owned by harbottle'})
skipping: [172.21.0.4] => (item={u'gpgcheck': False, u'description': u'CentOS-$releasever - SCLo', u'baseurl': [u'http://mirrors.aliyun.com/centos/$releasever/sclo/$basearch/sclo/', u'http://repo.virtualhosting.hk/centos/$releasever/sclo/$basearch/sclo/'], u'name': u'centos-sclo'})
skipping: [172.21.0.16] => (item={u'gpgcheck': False, u'skip_if_unavailable': True, u'name': u'harbottle', u'baseurl': u'https://download.copr.fedorainfracloud.org/results/harbottle/main/epel-$releasever-$basearch/', u'description': u'Copr repo for main owned by harbottle'})
skipping: [172.21.0.4] => (item={u'gpgcheck': False, u'description': u'CentOS-$releasever - SCLo rh', u'baseurl': [u'http://mirrors.aliyun.com/centos/$releasever/sclo/$basearch/rh/', u'http://repo.virtualhosting.hk/centos/$releasever/sclo/$basearch/rh/'], u'name': u'centos-sclo-rh'})
skipping: [172.21.0.4] => (item={u'gpgcheck': False, u'skip_if_unavailable': True, u'name': u'nginx', u'baseurl': u'http://nginx.org/packages/centos/$releasever/$basearch/', u'description': u'Nginx Official Yum Repo'})
skipping: [172.21.0.4] => (item={u'gpgcheck': False, u'skip_if_unavailable': True, u'name': u'haproxy', u'baseurl': u'https://download.copr.fedorainfracloud.org/results/roidelapluie/haproxy/epel-$releasever-$basearch/', u'description': u'Copr repo for haproxy'})
skipping: [172.21.0.4] => (item={u'gpgcheck': False, u'skip_if_unavailable': True, u'name': u'harbottle', u'baseurl': u'https://download.copr.fedorainfracloud.org/results/harbottle/main/epel-$releasever-$basearch/', u'description': u'Copr repo for main owned by harbottle'})

TASK [node : Install local repo] **********************************************************************************************************************************************
changed: [172.21.0.16] => (item=http://yum.pigsty/pigsty.repo)
changed: [172.21.0.3] => (item=http://yum.pigsty/pigsty.repo)
changed: [172.21.0.4] => (item=http://yum.pigsty/pigsty.repo)

TASK [Install node basic packages] ********************************************************************************************************************************************
skipping: [172.21.0.3] => (item=[])
skipping: [172.21.0.16] => (item=[])
skipping: [172.21.0.4] => (item=[])

TASK [Install node extra packages] ********************************************************************************************************************************************
skipping: [172.21.0.3] => (item=[])
skipping: [172.21.0.16] => (item=[])
skipping: [172.21.0.4] => (item=[])

TASK [node : Install meta specific packages] **********************************************************************************************************************************
skipping: [172.21.0.3] => (item=[])
skipping: [172.21.0.16] => (item=[])
skipping: [172.21.0.4] => (item=[])

TASK [Install node basic packages] ********************************************************************************************************************************************
changed: [172.21.0.3] => (item=[u'wget,yum-utils,sshpass,ntp,chrony,tuned,uuid,lz4,vim-minimal,make,patch,bash,lsof,wget,unzip,git,readline,zlib,openssl', u'numactl,grubby,sysstat,dstat,iotop,bind-utils,net-tools,tcpdump,socat,ipvsadm,telnet,tuned,pv,jq', u'python3,python3-psycopg2,python36-requests,python3-etcd,python3-consul', u'python36-urllib3,python36-idna,python36-pyOpenSSL,python36-cryptography', u'node_exporter,consul,consul-template,etcd,haproxy,keepalived,vip-manager'])
changed: [172.21.0.16] => (item=[u'wget,yum-utils,sshpass,ntp,chrony,tuned,uuid,lz4,vim-minimal,make,patch,bash,lsof,wget,unzip,git,readline,zlib,openssl', u'numactl,grubby,sysstat,dstat,iotop,bind-utils,net-tools,tcpdump,socat,ipvsadm,telnet,tuned,pv,jq', u'python3,python3-psycopg2,python36-requests,python3-etcd,python3-consul', u'python36-urllib3,python36-idna,python36-pyOpenSSL,python36-cryptography', u'node_exporter,consul,consul-template,etcd,haproxy,keepalived,vip-manager'])
changed: [172.21.0.4] => (item=[u'wget,yum-utils,sshpass,ntp,chrony,tuned,uuid,lz4,vim-minimal,make,patch,bash,lsof,wget,unzip,git,readline,zlib,openssl', u'numactl,grubby,sysstat,dstat,iotop,bind-utils,net-tools,tcpdump,socat,ipvsadm,telnet,tuned,pv,jq', u'python3,python3-psycopg2,python36-requests,python3-etcd,python3-consul', u'python36-urllib3,python36-idna,python36-pyOpenSSL,python36-cryptography', u'node_exporter,consul,consul-template,etcd,haproxy,keepalived,vip-manager'])

TASK [Install node extra packages] ********************************************************************************************************************************************
changed: [172.21.0.16] => (item=[u'patroni,patroni-consul,patroni-etcd,pgbouncer,pgbadger,pg_activity'])
changed: [172.21.0.3] => (item=[u'patroni,patroni-consul,patroni-etcd,pgbouncer,pgbadger,pg_activity'])
changed: [172.21.0.4] => (item=[u'patroni,patroni-consul,patroni-etcd,pgbouncer,pgbadger,pg_activity'])

TASK [node : Install meta specific packages] **********************************************************************************************************************************
skipping: [172.21.0.3] => (item=[])
skipping: [172.21.0.16] => (item=[])
skipping: [172.21.0.4] => (item=[])

TASK [Install pip3 packages on meta node] *************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [node : Node configure disable numa] *************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [node : Node configure disable swap] *************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [node : Node configure unmount swap] *************************************************************************************************************************************
skipping: [172.21.0.3] => (item=swap)
skipping: [172.21.0.3] => (item=none)
skipping: [172.21.0.16] => (item=swap)
skipping: [172.21.0.4] => (item=swap)
skipping: [172.21.0.16] => (item=none)
skipping: [172.21.0.4] => (item=none)

TASK [node : Node setup static network] ***************************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [node : Node configure disable firewall] *********************************************************************************************************************************
ok: [172.21.0.3]
ok: [172.21.0.16]
ok: [172.21.0.4]

TASK [node : Node configure disk prefetch] ************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [node : Enable linux kernel modules] *************************************************************************************************************************************
changed: [172.21.0.16] => (item=softdog)
changed: [172.21.0.3] => (item=softdog)
changed: [172.21.0.4] => (item=softdog)
changed: [172.21.0.16] => (item=br_netfilter)
changed: [172.21.0.3] => (item=br_netfilter)
changed: [172.21.0.4] => (item=br_netfilter)
changed: [172.21.0.16] => (item=ip_vs)
changed: [172.21.0.3] => (item=ip_vs)
changed: [172.21.0.4] => (item=ip_vs)
changed: [172.21.0.16] => (item=ip_vs_rr)
changed: [172.21.0.3] => (item=ip_vs_rr)
changed: [172.21.0.4] => (item=ip_vs_rr)
ok: [172.21.0.16] => (item=ip_vs_rr)
ok: [172.21.0.3] => (item=ip_vs_rr)
ok: [172.21.0.4] => (item=ip_vs_rr)
changed: [172.21.0.16] => (item=ip_vs_wrr)
changed: [172.21.0.3] => (item=ip_vs_wrr)
changed: [172.21.0.4] => (item=ip_vs_wrr)
changed: [172.21.0.16] => (item=ip_vs_sh)
changed: [172.21.0.3] => (item=ip_vs_sh)
changed: [172.21.0.4] => (item=ip_vs_sh)

TASK [node : Enable kernel module on reboot] **********************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [node : Get config parameter page count] *********************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [node : Get config parameter page size] **********************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [node : Tune shmmax and shmall via mem] **********************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [node : Create tuned profiles] *******************************************************************************************************************************************
changed: [172.21.0.3] => (item=oltp)
changed: [172.21.0.4] => (item=oltp)
changed: [172.21.0.16] => (item=oltp)
changed: [172.21.0.3] => (item=olap)
changed: [172.21.0.4] => (item=olap)
changed: [172.21.0.16] => (item=olap)
changed: [172.21.0.3] => (item=crit)
changed: [172.21.0.4] => (item=crit)
changed: [172.21.0.16] => (item=crit)
changed: [172.21.0.3] => (item=tiny)
changed: [172.21.0.16] => (item=tiny)
changed: [172.21.0.4] => (item=tiny)

TASK [node : Render tuned profiles] *******************************************************************************************************************************************
changed: [172.21.0.3] => (item=oltp)
changed: [172.21.0.16] => (item=oltp)
changed: [172.21.0.4] => (item=oltp)
changed: [172.21.0.3] => (item=olap)
changed: [172.21.0.16] => (item=olap)
changed: [172.21.0.4] => (item=olap)
changed: [172.21.0.3] => (item=crit)
changed: [172.21.0.16] => (item=crit)
changed: [172.21.0.4] => (item=crit)
changed: [172.21.0.3] => (item=tiny)
changed: [172.21.0.16] => (item=tiny)
changed: [172.21.0.4] => (item=tiny)

TASK [node : Active tuned profile] ********************************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.4]
changed: [172.21.0.3]

TASK [node : Change additional sysctl params] *********************************************************************************************************************************

TASK [node : Copy default user bash profile] **********************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [Setup node default pam ulimits] *****************************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [node : Create os user group admin] **************************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [node : Create os user admin] ********************************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [node : Grant admin group nopass sudo] ***********************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [node : Add no host checking to ssh config] ******************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [node : Add admin ssh no host checking] **********************************************************************************************************************************
ok: [172.21.0.3]
ok: [172.21.0.16]
ok: [172.21.0.4]

TASK [node : Fetch all admin public keys] *************************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [node : Exchange all admin ssh keys] *************************************************************************************************************************************
changed: [172.21.0.3 -> 172.21.0.3] => (item=[u'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDT+2zWp9q5GBcRf0Tx/SgLSIFWWMmsWIKZiEEnmYC9LgVQ/RF8jeacroAGE2K7C1b+d413OyTUbqtxaj0nwIW+hurtkRJjCJE3meRPhGqZ+aIG+sh/pwgud3rsoX34l9xb4cx6x1wLzTWjr9FSQZzozZAg2eaRaL6g0I+tJuVx/+8+TWivD8sWd8Me+bNgeCMq1mi3nVFaRYDBzwE+xddxsvDcAt7rxQdny7x+5Yz0D5z4ZxbivMRq4SD4C7sTtGc49H1pQc7bMxiuonFxVwqIYsZGjYLApSW+/KLIh1uN2oJ66ALN06W0lAPawxCOy6z3augR2e+Thgb6BuYJwclx ansible-generated on VM-0-3-centos', u'172.21.0.3'])
changed: [172.21.0.4 -> 172.21.0.3] => (item=[u'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDjgBTRQB7na46rTTxX/PFgWtqN8vZFB82SVt0lOMg7XVVzlWkUv7QaXW2LuUi5FdbLhn7R3QEAVr+Cptdlt4jgyefW2rjdQ4+EGPyQ3ekxoll9/aZ7yqEbcShtGhuYBoWkTl9nSSpLK38wA6d2+AvbhGIA54A2QyIfL4vKyt7s+ePuRJ5eI0h1j2MmzuVJSXmWDlkhoivtcygTkngJCSxSvbpMeETlNm6PhVOlWnqOXCjN7rU1EwAR4r68XxILvLojnwSwzPUU9btgAkWJhX7uXnNuJFAxCt2/DMed3YtQelgNC36IWW37oixrl2FeezaPbUll8HlZoYYoK4abj3XH ansible-generated on VM-0-4-centos', u'172.21.0.3'])
changed: [172.21.0.16 -> 172.21.0.3] => (item=[u'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDYKR2zBlq2PgO8Mfgr62Ff+HfjXXd+4BjuAGQOxTi1yFb2u2YX5L16Fie+eYscdS7yHObZ9GgTngtLPQegrTYj6P9I5ZVkShrm/XqoJ1WvvpX5oK3/ZPA0Y5Dhf8bADJ9c9ULsNnQLhw3ywai+GmKfXsuZXVUStjMf/BUnUmGeSUOlK1LdyfT6iikyS1mYSMeB0IrRUICpVgM4joHq8rWNMMp/YDC+NxGsNmJwFxIuipiSXIFer85vPGbo6E9MQ1Kbd31QJwqAJlSuLixccML3EApXL+2iYdsCUVA72uaNDu1levPXY4M280Z8kJ95lIiHSJG20pKz/XlhKoivsv8j ansible-generated on VM-0-16-centos', u'172.21.0.3'])
changed: [172.21.0.3 -> 172.21.0.16] => (item=[u'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDT+2zWp9q5GBcRf0Tx/SgLSIFWWMmsWIKZiEEnmYC9LgVQ/RF8jeacroAGE2K7C1b+d413OyTUbqtxaj0nwIW+hurtkRJjCJE3meRPhGqZ+aIG+sh/pwgud3rsoX34l9xb4cx6x1wLzTWjr9FSQZzozZAg2eaRaL6g0I+tJuVx/+8+TWivD8sWd8Me+bNgeCMq1mi3nVFaRYDBzwE+xddxsvDcAt7rxQdny7x+5Yz0D5z4ZxbivMRq4SD4C7sTtGc49H1pQc7bMxiuonFxVwqIYsZGjYLApSW+/KLIh1uN2oJ66ALN06W0lAPawxCOy6z3augR2e+Thgb6BuYJwclx ansible-generated on VM-0-3-centos', u'172.21.0.16'])
changed: [172.21.0.16 -> 172.21.0.16] => (item=[u'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDYKR2zBlq2PgO8Mfgr62Ff+HfjXXd+4BjuAGQOxTi1yFb2u2YX5L16Fie+eYscdS7yHObZ9GgTngtLPQegrTYj6P9I5ZVkShrm/XqoJ1WvvpX5oK3/ZPA0Y5Dhf8bADJ9c9ULsNnQLhw3ywai+GmKfXsuZXVUStjMf/BUnUmGeSUOlK1LdyfT6iikyS1mYSMeB0IrRUICpVgM4joHq8rWNMMp/YDC+NxGsNmJwFxIuipiSXIFer85vPGbo6E9MQ1Kbd31QJwqAJlSuLixccML3EApXL+2iYdsCUVA72uaNDu1levPXY4M280Z8kJ95lIiHSJG20pKz/XlhKoivsv8j ansible-generated on VM-0-16-centos', u'172.21.0.16'])
changed: [172.21.0.4 -> 172.21.0.16] => (item=[u'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDjgBTRQB7na46rTTxX/PFgWtqN8vZFB82SVt0lOMg7XVVzlWkUv7QaXW2LuUi5FdbLhn7R3QEAVr+Cptdlt4jgyefW2rjdQ4+EGPyQ3ekxoll9/aZ7yqEbcShtGhuYBoWkTl9nSSpLK38wA6d2+AvbhGIA54A2QyIfL4vKyt7s+ePuRJ5eI0h1j2MmzuVJSXmWDlkhoivtcygTkngJCSxSvbpMeETlNm6PhVOlWnqOXCjN7rU1EwAR4r68XxILvLojnwSwzPUU9btgAkWJhX7uXnNuJFAxCt2/DMed3YtQelgNC36IWW37oixrl2FeezaPbUll8HlZoYYoK4abj3XH ansible-generated on VM-0-4-centos', u'172.21.0.16'])
changed: [172.21.0.3 -> 172.21.0.4] => (item=[u'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDT+2zWp9q5GBcRf0Tx/SgLSIFWWMmsWIKZiEEnmYC9LgVQ/RF8jeacroAGE2K7C1b+d413OyTUbqtxaj0nwIW+hurtkRJjCJE3meRPhGqZ+aIG+sh/pwgud3rsoX34l9xb4cx6x1wLzTWjr9FSQZzozZAg2eaRaL6g0I+tJuVx/+8+TWivD8sWd8Me+bNgeCMq1mi3nVFaRYDBzwE+xddxsvDcAt7rxQdny7x+5Yz0D5z4ZxbivMRq4SD4C7sTtGc49H1pQc7bMxiuonFxVwqIYsZGjYLApSW+/KLIh1uN2oJ66ALN06W0lAPawxCOy6z3augR2e+Thgb6BuYJwclx ansible-generated on VM-0-3-centos', u'172.21.0.4'])
changed: [172.21.0.16 -> 172.21.0.4] => (item=[u'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDYKR2zBlq2PgO8Mfgr62Ff+HfjXXd+4BjuAGQOxTi1yFb2u2YX5L16Fie+eYscdS7yHObZ9GgTngtLPQegrTYj6P9I5ZVkShrm/XqoJ1WvvpX5oK3/ZPA0Y5Dhf8bADJ9c9ULsNnQLhw3ywai+GmKfXsuZXVUStjMf/BUnUmGeSUOlK1LdyfT6iikyS1mYSMeB0IrRUICpVgM4joHq8rWNMMp/YDC+NxGsNmJwFxIuipiSXIFer85vPGbo6E9MQ1Kbd31QJwqAJlSuLixccML3EApXL+2iYdsCUVA72uaNDu1levPXY4M280Z8kJ95lIiHSJG20pKz/XlhKoivsv8j ansible-generated on VM-0-16-centos', u'172.21.0.4'])
changed: [172.21.0.4 -> 172.21.0.4] => (item=[u'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDjgBTRQB7na46rTTxX/PFgWtqN8vZFB82SVt0lOMg7XVVzlWkUv7QaXW2LuUi5FdbLhn7R3QEAVr+Cptdlt4jgyefW2rjdQ4+EGPyQ3ekxoll9/aZ7yqEbcShtGhuYBoWkTl9nSSpLK38wA6d2+AvbhGIA54A2QyIfL4vKyt7s+ePuRJ5eI0h1j2MmzuVJSXmWDlkhoivtcygTkngJCSxSvbpMeETlNm6PhVOlWnqOXCjN7rU1EwAR4r68XxILvLojnwSwzPUU9btgAkWJhX7uXnNuJFAxCt2/DMed3YtQelgNC36IWW37oixrl2FeezaPbUll8HlZoYYoK4abj3XH ansible-generated on VM-0-4-centos', u'172.21.0.4'])

TASK [node : Install public keys] *********************************************************************************************************************************************

TASK [node : Install current public key] **************************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [node : Install ntp package] *********************************************************************************************************************************************
ok: [172.21.0.16]
ok: [172.21.0.3]
ok: [172.21.0.4]

TASK [node : Install chrony package] ******************************************************************************************************************************************
ok: [172.21.0.3]
ok: [172.21.0.16]
ok: [172.21.0.4]

TASK [Setup default node timezone] ********************************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [node : Copy the ntp.conf file] ******************************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [node : Copy the chrony.conf template] ***********************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [node : Launch ntpd service] *********************************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [node : Launch chronyd service] ******************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [Check for existing consul] **********************************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [consul : Consul exists flag fact set] ***********************************************************************************************************************************
ok: [172.21.0.3]
ok: [172.21.0.16]
ok: [172.21.0.4]

TASK [Abort due to consul exists] *********************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [Clean existing consul instance] *****************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [Stop any running consul instance] ***************************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [Remove existing consul dir] *********************************************************************************************************************************************
changed: [172.21.0.3] => (item=/etc/consul.d)
changed: [172.21.0.16] => (item=/etc/consul.d)
changed: [172.21.0.4] => (item=/etc/consul.d)
changed: [172.21.0.3] => (item=/var/lib/consul)
changed: [172.21.0.16] => (item=/var/lib/consul)
changed: [172.21.0.4] => (item=/var/lib/consul)

TASK [Recreate consul dir] ****************************************************************************************************************************************************
changed: [172.21.0.3] => (item=/etc/consul.d)
changed: [172.21.0.16] => (item=/etc/consul.d)
changed: [172.21.0.4] => (item=/etc/consul.d)
changed: [172.21.0.3] => (item=/var/lib/consul)
changed: [172.21.0.16] => (item=/var/lib/consul)
changed: [172.21.0.4] => (item=/var/lib/consul)

TASK [Make sure consul is installed] ******************************************************************************************************************************************
ok: [172.21.0.3]
ok: [172.21.0.16]
ok: [172.21.0.4]

TASK [Make sure consul dir exists] ********************************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [consul : Get dcs server node names] *************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [consul : Get dcs node name from var nodename] ***************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [consul : Get dcs node name from pgsql ins name] *************************************************************************************************************************
ok: [172.21.0.3]
ok: [172.21.0.16]
ok: [172.21.0.4]

TASK [consul : Fetch hostname as dcs node name] *******************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [consul : Get dcs name from hostname] ************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [Copy /etc/consul.d/consul.json] *****************************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [Copy consul agent service] **********************************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [consul : Get dcs bootstrap expect quroum] *******************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [Copy consul server service unit] ****************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [Launch consul server service] *******************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [Wait for consul server online] ******************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [Launch consul agent service] ********************************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [Wait for consul agent online] *******************************************************************************************************************************************
ok: [172.21.0.3]
ok: [172.21.0.16]
ok: [172.21.0.4]

PLAY [Pgsql Init] *************************************************************************************************************************************************************

TASK [Create os group postgres] ***********************************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [postgres : Make sure dcs group exists] **********************************************************************************************************************************
ok: [172.21.0.3] => (item=consul)
ok: [172.21.0.16] => (item=consul)
ok: [172.21.0.4] => (item=consul)
ok: [172.21.0.3] => (item=etcd)
ok: [172.21.0.16] => (item=etcd)
ok: [172.21.0.4] => (item=etcd)

TASK [Create dbsu postgres] ***************************************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [postgres : Grant dbsu nopass sudo] **************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [postgres : Grant dbsu all sudo] *****************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [postgres : Grant dbsu limited sudo] *************************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [postgres : Config watchdog onwer to dbsu] *******************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [postgres : Add dbsu ssh no host checking] *******************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [postgres : Fetch dbsu public keys] **************************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [postgres : Exchange dbsu ssh keys] **************************************************************************************************************************************
changed: [172.21.0.3 -> 172.21.0.3] => (item=[u'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0I6hrDfboNFT93wyqr2g7U76kE4blxv9Ok4YQgcyXvmwBeQ73SpkUGmEzJH22y66XIvTn/Dh+LO08z3ee+KuvUYivL7n8dIkG4aI81MVpb95WnVC7z2Vk58PLM7nyhHtv7z/huM2yC98JRn0kqvg4pjVCu8/sUd7fXZ0+2pZyYGJ5OS65cXTV5kwlSKmMtUqPZXonMeAaaZF6xLbGx+oWA9L0fagei2aKwd53Mi/LAydTnEl8VrnxfL0g0I5bTImIfQIsParjqRb4h0AdrF6aw30Ih2T8WMdGWvamKqdcYyQn4shkh8Nt8aCFo7iSFoZDV19Tyz0akPV7HH+aG8dj ansible-generated on VM-0-3-centos', u'172.21.0.3'])
changed: [172.21.0.16 -> 172.21.0.3] => (item=[u'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+XjXvjsrAys6Zhd9Jm5Ytepn5pxUgjQiFBa7m19QcYeIgw4IK/nOTx0EGve+hPwRB/09L5oeQJVm8meR27ucddA3B9PQwgxvTzLdsRxty5lnfepYNX3VN/5uuQ5rl7LcVVDqUN1M1xRHIp4wxzyZoLd89P6KA4QZkMLhvtUkQIwQIlndjEI51UHHn4QQ8s5u4emVhXUtjr/zgCeHxowFnjA858KGkGlicj+ZV5Wj36u8GeEdlOQUvILmer5d90w6XuzTxP2lcYGuU5EmDFSm2JQbHJyDbB0er1Ceky2tipB0fWjTaUGZsFyOmx5H9i/oFfkof9GpU6DYuw2/OgoAD ansible-generated on VM-0-16-centos', u'172.21.0.3'])
changed: [172.21.0.4 -> 172.21.0.3] => (item=[u'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDYOvfTWkqZbQ2FcfjyU1bnS+aO4RqSBx6sWT7ImF9F8eSsyzMzxDc/KGvHKXfiG/dYP5QwkH0oLaYSftQ6MOZwiEhnkdgw+VC/W6IXGwj/n+lfC7ywTzStCHcfzX9oo1YvjWT6wmGWLVcjkrRaxP9kG9Eq4BE2gED/gMqIcvmODf9sphpOmMDBYjj+hSOTeCjBWRwod8qDBJjLruD8OiskmwK/66X++B6Gm/E1VCE0n5J2WkV4OHZU6GeYKVscpUxsRW3aWDk7HzocmVbG/lz24W8BNA9nvDjlXchWKn4rtNsYS1++32Roz546oMVx7oCBNFx2l+2di5fa4N6g8+KV ansible-generated on VM-0-4-centos', u'172.21.0.3'])
changed: [172.21.0.3 -> 172.21.0.16] => (item=[u'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0I6hrDfboNFT93wyqr2g7U76kE4blxv9Ok4YQgcyXvmwBeQ73SpkUGmEzJH22y66XIvTn/Dh+LO08z3ee+KuvUYivL7n8dIkG4aI81MVpb95WnVC7z2Vk58PLM7nyhHtv7z/huM2yC98JRn0kqvg4pjVCu8/sUd7fXZ0+2pZyYGJ5OS65cXTV5kwlSKmMtUqPZXonMeAaaZF6xLbGx+oWA9L0fagei2aKwd53Mi/LAydTnEl8VrnxfL0g0I5bTImIfQIsParjqRb4h0AdrF6aw30Ih2T8WMdGWvamKqdcYyQn4shkh8Nt8aCFo7iSFoZDV19Tyz0akPV7HH+aG8dj ansible-generated on VM-0-3-centos', u'172.21.0.16'])
changed: [172.21.0.16 -> 172.21.0.16] => (item=[u'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+XjXvjsrAys6Zhd9Jm5Ytepn5pxUgjQiFBa7m19QcYeIgw4IK/nOTx0EGve+hPwRB/09L5oeQJVm8meR27ucddA3B9PQwgxvTzLdsRxty5lnfepYNX3VN/5uuQ5rl7LcVVDqUN1M1xRHIp4wxzyZoLd89P6KA4QZkMLhvtUkQIwQIlndjEI51UHHn4QQ8s5u4emVhXUtjr/zgCeHxowFnjA858KGkGlicj+ZV5Wj36u8GeEdlOQUvILmer5d90w6XuzTxP2lcYGuU5EmDFSm2JQbHJyDbB0er1Ceky2tipB0fWjTaUGZsFyOmx5H9i/oFfkof9GpU6DYuw2/OgoAD ansible-generated on VM-0-16-centos', u'172.21.0.16'])
changed: [172.21.0.4 -> 172.21.0.16] => (item=[u'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDYOvfTWkqZbQ2FcfjyU1bnS+aO4RqSBx6sWT7ImF9F8eSsyzMzxDc/KGvHKXfiG/dYP5QwkH0oLaYSftQ6MOZwiEhnkdgw+VC/W6IXGwj/n+lfC7ywTzStCHcfzX9oo1YvjWT6wmGWLVcjkrRaxP9kG9Eq4BE2gED/gMqIcvmODf9sphpOmMDBYjj+hSOTeCjBWRwod8qDBJjLruD8OiskmwK/66X++B6Gm/E1VCE0n5J2WkV4OHZU6GeYKVscpUxsRW3aWDk7HzocmVbG/lz24W8BNA9nvDjlXchWKn4rtNsYS1++32Roz546oMVx7oCBNFx2l+2di5fa4N6g8+KV ansible-generated on VM-0-4-centos', u'172.21.0.16'])
changed: [172.21.0.3 -> 172.21.0.4] => (item=[u'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0I6hrDfboNFT93wyqr2g7U76kE4blxv9Ok4YQgcyXvmwBeQ73SpkUGmEzJH22y66XIvTn/Dh+LO08z3ee+KuvUYivL7n8dIkG4aI81MVpb95WnVC7z2Vk58PLM7nyhHtv7z/huM2yC98JRn0kqvg4pjVCu8/sUd7fXZ0+2pZyYGJ5OS65cXTV5kwlSKmMtUqPZXonMeAaaZF6xLbGx+oWA9L0fagei2aKwd53Mi/LAydTnEl8VrnxfL0g0I5bTImIfQIsParjqRb4h0AdrF6aw30Ih2T8WMdGWvamKqdcYyQn4shkh8Nt8aCFo7iSFoZDV19Tyz0akPV7HH+aG8dj ansible-generated on VM-0-3-centos', u'172.21.0.4'])
changed: [172.21.0.16 -> 172.21.0.4] => (item=[u'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+XjXvjsrAys6Zhd9Jm5Ytepn5pxUgjQiFBa7m19QcYeIgw4IK/nOTx0EGve+hPwRB/09L5oeQJVm8meR27ucddA3B9PQwgxvTzLdsRxty5lnfepYNX3VN/5uuQ5rl7LcVVDqUN1M1xRHIp4wxzyZoLd89P6KA4QZkMLhvtUkQIwQIlndjEI51UHHn4QQ8s5u4emVhXUtjr/zgCeHxowFnjA858KGkGlicj+ZV5Wj36u8GeEdlOQUvILmer5d90w6XuzTxP2lcYGuU5EmDFSm2JQbHJyDbB0er1Ceky2tipB0fWjTaUGZsFyOmx5H9i/oFfkof9GpU6DYuw2/OgoAD ansible-generated on VM-0-16-centos', u'172.21.0.4'])
changed: [172.21.0.4 -> 172.21.0.4] => (item=[u'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDYOvfTWkqZbQ2FcfjyU1bnS+aO4RqSBx6sWT7ImF9F8eSsyzMzxDc/KGvHKXfiG/dYP5QwkH0oLaYSftQ6MOZwiEhnkdgw+VC/W6IXGwj/n+lfC7ywTzStCHcfzX9oo1YvjWT6wmGWLVcjkrRaxP9kG9Eq4BE2gED/gMqIcvmODf9sphpOmMDBYjj+hSOTeCjBWRwod8qDBJjLruD8OiskmwK/66X++B6Gm/E1VCE0n5J2WkV4OHZU6GeYKVscpUxsRW3aWDk7HzocmVbG/lz24W8BNA9nvDjlXchWKn4rtNsYS1++32Roz546oMVx7oCBNFx2l+2di5fa4N6g8+KV ansible-generated on VM-0-4-centos', u'172.21.0.4'])

TASK [postgres : Install offical pgdg yum repo] *******************************************************************************************************************************
skipping: [172.21.0.3] => (item=postgresql${pg_version}*)
skipping: [172.21.0.3] => (item=postgis31_${pg_version}*)
skipping: [172.21.0.3] => (item=citus_${pg_version})
skipping: [172.21.0.16] => (item=postgresql${pg_version}*)
skipping: [172.21.0.3] => (item=timescaledb_${pg_version})
skipping: [172.21.0.16] => (item=postgis31_${pg_version}*)
skipping: [172.21.0.3] => (item=pgbouncer patroni pg_exporter pgbadger)
skipping: [172.21.0.3] => (item=patroni patroni-consul patroni-etcd pgbouncer pgbadger pg_activity)
skipping: [172.21.0.16] => (item=citus_${pg_version})
skipping: [172.21.0.4] => (item=postgresql${pg_version}*)
skipping: [172.21.0.4] => (item=postgis31_${pg_version}*)
skipping: [172.21.0.3] => (item=python3 python3-psycopg2 python36-requests python3-etcd python3-consul)
skipping: [172.21.0.16] => (item=timescaledb_${pg_version})
skipping: [172.21.0.4] => (item=citus_${pg_version})
skipping: [172.21.0.3] => (item=python36-urllib3 python36-idna python36-pyOpenSSL python36-cryptography)
skipping: [172.21.0.4] => (item=timescaledb_${pg_version})
skipping: [172.21.0.16] => (item=pgbouncer patroni pg_exporter pgbadger)
skipping: [172.21.0.16] => (item=patroni patroni-consul patroni-etcd pgbouncer pgbadger pg_activity)
skipping: [172.21.0.16] => (item=python3 python3-psycopg2 python36-requests python3-etcd python3-consul)
skipping: [172.21.0.16] => (item=python36-urllib3 python36-idna python36-pyOpenSSL python36-cryptography)
skipping: [172.21.0.4] => (item=pgbouncer patroni pg_exporter pgbadger)
skipping: [172.21.0.4] => (item=patroni patroni-consul patroni-etcd pgbouncer pgbadger pg_activity)
skipping: [172.21.0.4] => (item=python3 python3-psycopg2 python36-requests python3-etcd python3-consul)
skipping: [172.21.0.4] => (item=python36-urllib3 python36-idna python36-pyOpenSSL python36-cryptography)

TASK [postgres : Install pg packages] *****************************************************************************************************************************************
changed: [172.21.0.16] => (item=[u'postgresql13*', u'postgis31_13*', u'citus_13', u'timescaledb_13', u'pgbouncer,patroni,pg_exporter,pgbadger', u'patroni,patroni-consul,patroni-etcd,pgbouncer,pgbadger,pg_activity', u'python3,python3-psycopg2,python36-requests,python3-etcd,python3-consul', u'python36-urllib3,python36-idna,python36-pyOpenSSL,python36-cryptography'])
changed: [172.21.0.3] => (item=[u'postgresql13*', u'postgis31_13*', u'citus_13', u'timescaledb_13', u'pgbouncer,patroni,pg_exporter,pgbadger', u'patroni,patroni-consul,patroni-etcd,pgbouncer,pgbadger,pg_activity', u'python3,python3-psycopg2,python36-requests,python3-etcd,python3-consul', u'python36-urllib3,python36-idna,python36-pyOpenSSL,python36-cryptography'])
changed: [172.21.0.4] => (item=[u'postgresql13*', u'postgis31_13*', u'citus_13', u'timescaledb_13', u'pgbouncer,patroni,pg_exporter,pgbadger', u'patroni,patroni-consul,patroni-etcd,pgbouncer,pgbadger,pg_activity', u'python3,python3-psycopg2,python36-requests,python3-etcd,python3-consul', u'python36-urllib3,python36-idna,python36-pyOpenSSL,python36-cryptography'])

TASK [postgres : Install pg extensions] ***************************************************************************************************************************************
changed: [172.21.0.3] => (item=[u'pg_repack13,pg_qualstats13,pg_stat_kcache13,wal2json13'])
changed: [172.21.0.16] => (item=[u'pg_repack13,pg_qualstats13,pg_stat_kcache13,wal2json13'])
changed: [172.21.0.4] => (item=[u'pg_repack13,pg_qualstats13,pg_stat_kcache13,wal2json13'])

TASK [postgres : Link /usr/pgsql to current version] **************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [postgres : Add pg bin dir to profile path] ******************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [postgres : Fix directory ownership] *************************************************************************************************************************************
ok: [172.21.0.3]
ok: [172.21.0.16]
ok: [172.21.0.4]

TASK [Remove default postgres service] ****************************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [postgres : Check necessary variables exists] ****************************************************************************************************************************
ok: [172.21.0.3] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [172.21.0.16] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [172.21.0.4] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [postgres : Fetch variables via pg_cluster] ******************************************************************************************************************************
ok: [172.21.0.16]
ok: [172.21.0.4]
ok: [172.21.0.3]

TASK [postgres : Set cluster basic facts for hosts] ***************************************************************************************************************************
ok: [172.21.0.3]
ok: [172.21.0.16]
ok: [172.21.0.4]

TASK [postgres : Assert cluster primary singleton] ****************************************************************************************************************************
ok: [172.21.0.3] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [172.21.0.16] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [172.21.0.4] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [postgres : Setup cluster primary ip address] ****************************************************************************************************************************
ok: [172.21.0.3]
ok: [172.21.0.16]
ok: [172.21.0.4]

TASK [postgres : Setup repl upstream for primary] *****************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [postgres : Setup repl upstream for replicas] ****************************************************************************************************************************
skipping: [172.21.0.3]
ok: [172.21.0.16]
ok: [172.21.0.4]

TASK [postgres : Debug print instance summary] ********************************************************************************************************************************
ok: [172.21.0.3] => {
    "msg": "cluster=pg-test service=pg-test-primary instance=pg-test-1 replication=[primary:itself]->172.21.0.3"
}
ok: [172.21.0.16] => {
    "msg": "cluster=pg-test service=pg-test-offline instance=pg-test-3 replication=[primary:itself]->172.21.0.16"
}
ok: [172.21.0.4] => {
    "msg": "cluster=pg-test service=pg-test-replica instance=pg-test-2 replication=[primary:itself]->172.21.0.4"
}

TASK [Check for existing postgres instance] ***********************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [postgres : Set fact whether pg port is open] ****************************************************************************************************************************
ok: [172.21.0.3]
ok: [172.21.0.16]
ok: [172.21.0.4]

TASK [Abort due to existing postgres instance] ********************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [Clean existing postgres instance] ***************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [Shutdown existing postgres service] *************************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [postgres : Remove registerd consul service] *****************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [Remove postgres metadata in consul] *************************************************************************************************************************************
skipping: [172.21.0.16]
skipping: [172.21.0.4]
changed: [172.21.0.3]

TASK [Remove existing postgres data] ******************************************************************************************************************************************
ok: [172.21.0.16] => (item=/pg)
ok: [172.21.0.3] => (item=/pg)
ok: [172.21.0.4] => (item=/pg)
ok: [172.21.0.3] => (item=/data/postgres)
ok: [172.21.0.16] => (item=/data/postgres)
ok: [172.21.0.4] => (item=/data/postgres)
ok: [172.21.0.3] => (item=/data/backups/postgres)
ok: [172.21.0.16] => (item=/data/backups/postgres)
ok: [172.21.0.4] => (item=/data/backups/postgres)
changed: [172.21.0.3] => (item=/etc/pgbouncer)
changed: [172.21.0.16] => (item=/etc/pgbouncer)
changed: [172.21.0.4] => (item=/etc/pgbouncer)
changed: [172.21.0.16] => (item=/var/log/pgbouncer)
changed: [172.21.0.3] => (item=/var/log/pgbouncer)
changed: [172.21.0.4] => (item=/var/log/pgbouncer)
changed: [172.21.0.3] => (item=/var/run/pgbouncer)
changed: [172.21.0.16] => (item=/var/run/pgbouncer)
changed: [172.21.0.4] => (item=/var/run/pgbouncer)

TASK [postgres : Make sure main and backup dir exists] ************************************************************************************************************************
changed: [172.21.0.3] => (item=/data)
changed: [172.21.0.16] => (item=/data)
changed: [172.21.0.4] => (item=/data)
changed: [172.21.0.3] => (item=/data/backups)
changed: [172.21.0.16] => (item=/data/backups)
changed: [172.21.0.4] => (item=/data/backups)

TASK [Create postgres directory structure] ************************************************************************************************************************************
changed: [172.21.0.3] => (item=/data/postgres)
changed: [172.21.0.16] => (item=/data/postgres)
changed: [172.21.0.4] => (item=/data/postgres)
changed: [172.21.0.3] => (item=/data/postgres/pg-test-13)
changed: [172.21.0.16] => (item=/data/postgres/pg-test-13)
changed: [172.21.0.4] => (item=/data/postgres/pg-test-13)
changed: [172.21.0.3] => (item=/data/postgres/pg-test-13/bin)
changed: [172.21.0.16] => (item=/data/postgres/pg-test-13/bin)
changed: [172.21.0.4] => (item=/data/postgres/pg-test-13/bin)
changed: [172.21.0.3] => (item=/data/postgres/pg-test-13/log)
changed: [172.21.0.16] => (item=/data/postgres/pg-test-13/log)
changed: [172.21.0.4] => (item=/data/postgres/pg-test-13/log)
changed: [172.21.0.3] => (item=/data/postgres/pg-test-13/tmp)
changed: [172.21.0.16] => (item=/data/postgres/pg-test-13/tmp)
changed: [172.21.0.4] => (item=/data/postgres/pg-test-13/tmp)
changed: [172.21.0.3] => (item=/data/postgres/pg-test-13/conf)
changed: [172.21.0.16] => (item=/data/postgres/pg-test-13/conf)
changed: [172.21.0.4] => (item=/data/postgres/pg-test-13/conf)
changed: [172.21.0.3] => (item=/data/postgres/pg-test-13/data)
changed: [172.21.0.16] => (item=/data/postgres/pg-test-13/data)
changed: [172.21.0.4] => (item=/data/postgres/pg-test-13/data)
changed: [172.21.0.3] => (item=/data/postgres/pg-test-13/meta)
changed: [172.21.0.16] => (item=/data/postgres/pg-test-13/meta)
changed: [172.21.0.4] => (item=/data/postgres/pg-test-13/meta)
changed: [172.21.0.3] => (item=/data/postgres/pg-test-13/stat)
changed: [172.21.0.16] => (item=/data/postgres/pg-test-13/stat)
changed: [172.21.0.4] => (item=/data/postgres/pg-test-13/stat)
changed: [172.21.0.3] => (item=/data/postgres/pg-test-13/change)
changed: [172.21.0.16] => (item=/data/postgres/pg-test-13/change)
changed: [172.21.0.4] => (item=/data/postgres/pg-test-13/change)
changed: [172.21.0.3] => (item=/data/backups/postgres/pg-test-13/postgres)
changed: [172.21.0.16] => (item=/data/backups/postgres/pg-test-13/postgres)
changed: [172.21.0.4] => (item=/data/backups/postgres/pg-test-13/postgres)
changed: [172.21.0.3] => (item=/data/backups/postgres/pg-test-13/arcwal)
changed: [172.21.0.16] => (item=/data/backups/postgres/pg-test-13/arcwal)
changed: [172.21.0.4] => (item=/data/backups/postgres/pg-test-13/arcwal)
changed: [172.21.0.3] => (item=/data/backups/postgres/pg-test-13/backup)
changed: [172.21.0.16] => (item=/data/backups/postgres/pg-test-13/backup)
changed: [172.21.0.4] => (item=/data/backups/postgres/pg-test-13/backup)
changed: [172.21.0.3] => (item=/data/backups/postgres/pg-test-13/remote)
changed: [172.21.0.16] => (item=/data/backups/postgres/pg-test-13/remote)
changed: [172.21.0.4] => (item=/data/backups/postgres/pg-test-13/remote)

TASK [postgres : Create pgbouncer directory structure] ************************************************************************************************************************
changed: [172.21.0.3] => (item=/etc/pgbouncer)
changed: [172.21.0.16] => (item=/etc/pgbouncer)
changed: [172.21.0.4] => (item=/etc/pgbouncer)
changed: [172.21.0.4] => (item=/var/log/pgbouncer)
changed: [172.21.0.16] => (item=/var/log/pgbouncer)
changed: [172.21.0.3] => (item=/var/log/pgbouncer)
changed: [172.21.0.4] => (item=/var/run/pgbouncer)
changed: [172.21.0.16] => (item=/var/run/pgbouncer)
changed: [172.21.0.3] => (item=/var/run/pgbouncer)

TASK [postgres : Create links from pgbkup to pgroot] **************************************************************************************************************************
changed: [172.21.0.3] => (item=arcwal)
changed: [172.21.0.16] => (item=arcwal)
changed: [172.21.0.4] => (item=arcwal)
changed: [172.21.0.3] => (item=backup)
changed: [172.21.0.16] => (item=backup)
changed: [172.21.0.4] => (item=backup)
changed: [172.21.0.3] => (item=remote)
changed: [172.21.0.16] => (item=remote)
changed: [172.21.0.4] => (item=remote)

TASK [postgres : Create links from current cluster] ***************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [postgres : Copy pg_cluster to /pg/meta/cluster] *************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [postgres : Copy pg_version to /pg/meta/version] *************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [postgres : Copy pg_instance to /pg/meta/instance] ***********************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [postgres : Copy pg_seq to /pg/meta/sequence] ****************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [postgres : Copy pg_role to /pg/meta/role] *******************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [Copy postgres scripts to /pg/bin/] **************************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [postgres : Copy alias profile to /etc/profile.d] ************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [Copy psqlrc to postgres home] *******************************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [postgres : Setup hostname to pg instance name] **************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [postgres : Copy consul node-meta definition] ****************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [postgres : Restart consul to load new node-meta] ************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [postgres : Get config parameter page count] *****************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [postgres : Get config parameter page size] ******************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [postgres : Tune shared buffer and work mem] *****************************************************************************************************************************
ok: [172.21.0.3]
ok: [172.21.0.16]
ok: [172.21.0.4]

TASK [postgres : Hanlde small size mem occasion] ******************************************************************************************************************************
ok: [172.21.0.3]
ok: [172.21.0.16]
ok: [172.21.0.4]

TASK [Calculate postgres mem params] ******************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [postgres : create patroni config dir] ***********************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [postgres : use predefined patroni template] *****************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [postgres : Render default /pg/conf/patroni.yml] *************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [postgres : Link /pg/conf/patroni to /pg/bin/] ***************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [postgres : Link /pg/bin/patroni.yml to /etc/patroni/] *******************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [postgres : Config patroni watchdog support] *****************************************************************************************************************************
ok: [172.21.0.3]
ok: [172.21.0.16]
ok: [172.21.0.4]

TASK [postgres : Copy patroni systemd service file] ***************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [postgres : create patroni systemd drop-in dir] **************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [Copy postgres systemd service file] *************************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [postgres : Drop-In systemd config for patroni] **************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [postgres : Launch patroni on primary instance] **************************************************************************************************************************
skipping: [172.21.0.16]
skipping: [172.21.0.4]
changed: [172.21.0.3]

TASK [postgres : Wait for patroni primary online] *****************************************************************************************************************************
skipping: [172.21.0.16]
skipping: [172.21.0.4]
ok: [172.21.0.3]

TASK [Wait for postgres primary online] ***************************************************************************************************************************************
skipping: [172.21.0.16]
skipping: [172.21.0.4]
ok: [172.21.0.3]

TASK [Check primary postgres service ready] ***********************************************************************************************************************************
skipping: [172.21.0.16]
skipping: [172.21.0.4]
[WARNING]: Module remote_tmp /var/lib/pgsql/.ansible/tmp did not exist and was created with a mode of 0700, this may cause issues when running as another user. To avoid this,
create the remote_tmp dir with the correct permissions manually
changed: [172.21.0.3]

TASK [postgres : Check replication connectivity on primary] *******************************************************************************************************************
skipping: [172.21.0.16]
skipping: [172.21.0.4]
changed: [172.21.0.3]

TASK [postgres : Render init roles sql] ***************************************************************************************************************************************
skipping: [172.21.0.16]
skipping: [172.21.0.4]
changed: [172.21.0.3]

TASK [postgres : Render init template sql] ************************************************************************************************************************************
skipping: [172.21.0.16]
skipping: [172.21.0.4]
changed: [172.21.0.3]

TASK [postgres : Render default pg-init scripts] ******************************************************************************************************************************
skipping: [172.21.0.16]
skipping: [172.21.0.4]
changed: [172.21.0.3]

TASK [postgres : Execute initialization scripts] ******************************************************************************************************************************
skipping: [172.21.0.16]
skipping: [172.21.0.4]
changed: [172.21.0.3]

TASK [postgres : Check primary instance ready] ********************************************************************************************************************************
skipping: [172.21.0.16]
skipping: [172.21.0.4]
changed: [172.21.0.3]

TASK [postgres : Add dbsu password to pgpass if exists] ***********************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [postgres : Add system user to pgpass] ***********************************************************************************************************************************
changed: [172.21.0.3] => (item={u'username': u'replicator', u'password': u'DBUser.Replicator'})
changed: [172.21.0.16] => (item={u'username': u'replicator', u'password': u'DBUser.Replicator'})
changed: [172.21.0.4] => (item={u'username': u'replicator', u'password': u'DBUser.Replicator'})
changed: [172.21.0.3] => (item={u'username': u'dbuser_monitor', u'password': u'DBUser.Monitor'})
changed: [172.21.0.16] => (item={u'username': u'dbuser_monitor', u'password': u'DBUser.Monitor'})
changed: [172.21.0.4] => (item={u'username': u'dbuser_monitor', u'password': u'DBUser.Monitor'})
changed: [172.21.0.16] => (item={u'username': u'dbuser_dba', u'password': u'DBUser.DBA'})
changed: [172.21.0.3] => (item={u'username': u'dbuser_dba', u'password': u'DBUser.DBA'})
changed: [172.21.0.4] => (item={u'username': u'dbuser_dba', u'password': u'DBUser.DBA'})

TASK [postgres : Check replication connectivity to primary] *******************************************************************************************************************
skipping: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [postgres : Launch patroni on replica instances] *************************************************************************************************************************
skipping: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [postgres : Wait for patroni replica online] *****************************************************************************************************************************
skipping: [172.21.0.3]
ok: [172.21.0.16]
ok: [172.21.0.4]

TASK [Wait for postgres replica online] ***************************************************************************************************************************************
skipping: [172.21.0.3]
ok: [172.21.0.16]
ok: [172.21.0.4]

TASK [Check replica postgres service ready] ***********************************************************************************************************************************
skipping: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [postgres : Render hba rules] ********************************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [postgres : Reload hba rules] ********************************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [postgres : Pause patroni] ***********************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [postgres : Stop patroni on replica instance] ****************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [postgres : Stop patroni on primary instance] ****************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [Launch raw postgres on primary] *****************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [Launch raw postgres on replicas] ****************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [Wait for postgres online] ***********************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [postgres : Check pgbouncer is installed] ********************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [postgres : Stop existing pgbouncer service] *****************************************************************************************************************************
ok: [172.21.0.3]
ok: [172.21.0.16]
ok: [172.21.0.4]

TASK [postgres : Remove existing pgbouncer dirs] ******************************************************************************************************************************
changed: [172.21.0.3] => (item=/etc/pgbouncer)
changed: [172.21.0.16] => (item=/etc/pgbouncer)
changed: [172.21.0.4] => (item=/etc/pgbouncer)
changed: [172.21.0.3] => (item=/var/log/pgbouncer)
changed: [172.21.0.16] => (item=/var/log/pgbouncer)
changed: [172.21.0.4] => (item=/var/log/pgbouncer)
changed: [172.21.0.3] => (item=/var/run/pgbouncer)
changed: [172.21.0.16] => (item=/var/run/pgbouncer)
changed: [172.21.0.4] => (item=/var/run/pgbouncer)

TASK [Recreate dirs with owner postgres] **************************************************************************************************************************************
changed: [172.21.0.3] => (item=/etc/pgbouncer)
changed: [172.21.0.16] => (item=/etc/pgbouncer)
changed: [172.21.0.4] => (item=/etc/pgbouncer)
changed: [172.21.0.3] => (item=/var/log/pgbouncer)
changed: [172.21.0.16] => (item=/var/log/pgbouncer)
changed: [172.21.0.4] => (item=/var/log/pgbouncer)
changed: [172.21.0.3] => (item=/var/run/pgbouncer)
changed: [172.21.0.16] => (item=/var/run/pgbouncer)
changed: [172.21.0.4] => (item=/var/run/pgbouncer)

TASK [postgres : Copy /etc/pgbouncer/pgbouncer.ini] ***************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [postgres : Copy /etc/pgbouncer/pgb_hba.conf] ****************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.4]
changed: [172.21.0.3]

TASK [postgres : Touch userlist and database list] ****************************************************************************************************************************
changed: [172.21.0.3] => (item=database.txt)
changed: [172.21.0.16] => (item=database.txt)
changed: [172.21.0.4] => (item=database.txt)
changed: [172.21.0.3] => (item=userlist.txt)
changed: [172.21.0.16] => (item=userlist.txt)
changed: [172.21.0.4] => (item=userlist.txt)

TASK [postgres : Add default users to pgbouncer] ******************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [postgres : Init pgbouncer business database list] ***********************************************************************************************************************
changed: [172.21.0.3] => (item={u'name': u'test'})
changed: [172.21.0.16] => (item={u'name': u'test'})
changed: [172.21.0.4] => (item={u'name': u'test'})

TASK [postgres : Init pgbouncer business user list] ***************************************************************************************************************************
changed: [172.21.0.3] => (item={u'comment': u'test user for test database cluster', u'roles': [u'dbrole_admin'], u'password': u'test', u'name': u'test', u'pgbouncer': True})
changed: [172.21.0.4] => (item={u'comment': u'test user for test database cluster', u'roles': [u'dbrole_admin'], u'password': u'test', u'name': u'test', u'pgbouncer': True})
changed: [172.21.0.16] => (item={u'comment': u'test user for test database cluster', u'roles': [u'dbrole_admin'], u'password': u'test', u'name': u'test', u'pgbouncer': True})

TASK [postgres : Copy pgbouncer systemd service] ******************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [postgres : Launch pgbouncer pool service] *******************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [postgres : Wait for pgbouncer service online] ***************************************************************************************************************************
ok: [172.21.0.3]
ok: [172.21.0.16]
ok: [172.21.0.4]

TASK [postgres : Check pgbouncer service is ready] ****************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [postgres : include_tasks] ***********************************************************************************************************************************************
included: /root/pigsty/roles/postgres/tasks/createuser.yml for 172.21.0.3, 172.21.0.16, 172.21.0.4

TASK [postgres : Render user test creation sql] *******************************************************************************************************************************
skipping: [172.21.0.16]
skipping: [172.21.0.4]
changed: [172.21.0.3]

TASK [postgres : Execute user test creation sql on primary] *******************************************************************************************************************
skipping: [172.21.0.16]
skipping: [172.21.0.4]
changed: [172.21.0.3]

TASK [postgres : Add business user to pgbouncer] ******************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [postgres : include_tasks] ***********************************************************************************************************************************************
included: /root/pigsty/roles/postgres/tasks/createdb.yml for 172.21.0.3, 172.21.0.16, 172.21.0.4

TASK [postgres : debug] *******************************************************************************************************************************************************
ok: [172.21.0.3] => {
    "msg": {
        "name": "test"
    }
}
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [postgres : Render database test creation sql] ***************************************************************************************************************************
skipping: [172.21.0.16]
skipping: [172.21.0.4]
changed: [172.21.0.3]

TASK [postgres : Render database test baseline sql] ***************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [postgres : Execute database test creation command] **********************************************************************************************************************
skipping: [172.21.0.16]
skipping: [172.21.0.4]
changed: [172.21.0.3]

TASK [postgres : Execute database test creation sql] **************************************************************************************************************************
skipping: [172.21.0.16]
skipping: [172.21.0.4]
changed: [172.21.0.3]

TASK [postgres : Execute database test baseline sql] **************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [postgres : Add biz database to pgbouncer] *******************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [postgres : Reload pgbouncer to add db and users] ************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [monitor : Install exporter yum repo] ************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [monitor : Install node_exporter and pg_exporter] ************************************************************************************************************************
skipping: [172.21.0.3] => (item=node_exporter)
skipping: [172.21.0.3] => (item=pg_exporter)
skipping: [172.21.0.16] => (item=node_exporter)
skipping: [172.21.0.16] => (item=pg_exporter)
skipping: [172.21.0.4] => (item=node_exporter)
skipping: [172.21.0.4] => (item=pg_exporter)

TASK [monitor : Copy exporter binaries] ***************************************************************************************************************************************
skipping: [172.21.0.3] => (item=node_exporter)
skipping: [172.21.0.3] => (item=pg_exporter)
skipping: [172.21.0.3] => (item=promtail)
skipping: [172.21.0.16] => (item=node_exporter)
skipping: [172.21.0.16] => (item=pg_exporter)
skipping: [172.21.0.16] => (item=promtail)
skipping: [172.21.0.4] => (item=node_exporter)
skipping: [172.21.0.4] => (item=pg_exporter)
skipping: [172.21.0.4] => (item=promtail)

TASK [monitor : Create /etc/pg_exporter conf dir] *****************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [monitor : Copy default pg_exporter.yaml] ********************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [monitor : Config /etc/default/pg_exporter] ******************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [monitor : Config pg_exporter service unit] ******************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [monitor : Launch pg_exporter systemd service] ***************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [monitor : Wait for pg_exporter service online] **************************************************************************************************************************
ok: [172.21.0.3]
ok: [172.21.0.16]
ok: [172.21.0.4]

TASK [monitor : Config pgbouncer_exporter opts] *******************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [monitor : Config pgbouncer_exporter service] ****************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [monitor : Launch pgbouncer_exporter service] ****************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [monitor : Wait for pgbouncer_exporter online] ***************************************************************************************************************************
ok: [172.21.0.3]
ok: [172.21.0.16]
ok: [172.21.0.4]

TASK [monitor : Copy node_exporter systemd service] ***************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [monitor : Config default node_exporter options] *************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [monitor : Launch node_exporter service unit] ****************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [monitor : Wait for node_exporter online] ********************************************************************************************************************************
ok: [172.21.0.16]
ok: [172.21.0.3]
ok: [172.21.0.4]

TASK [service : Make sure haproxy is installed] *******************************************************************************************************************************
ok: [172.21.0.3]
ok: [172.21.0.16]
ok: [172.21.0.4]

TASK [service : Create haproxy directory] *************************************************************************************************************************************
ok: [172.21.0.3]
ok: [172.21.0.16]
ok: [172.21.0.4]

TASK [Copy haproxy systemd service file] **************************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [service : Fetch postgres cluster memberships] ***************************************************************************************************************************
ok: [172.21.0.3]
ok: [172.21.0.16]
ok: [172.21.0.4]

TASK [service : Templating /etc/haproxy/haproxy.cfg] **************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [Launch haproxy load balancer service] ***********************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [service : Wait for haproxy load balancer online] ************************************************************************************************************************
ok: [172.21.0.3]
ok: [172.21.0.16]
ok: [172.21.0.4]

TASK [Reload haproxy load balancer service] ***********************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [service : Make sure vip-manager is installed] ***************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [Copy vip-manager systemd service file] **********************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [service : create vip-manager systemd drop-in dir] ***********************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [service : create vip-manager systemd drop-in file] **********************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [service : Templating /etc/default/vip-manager.yml] **********************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [service : Launch vip-manager] *******************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [service : Fetch postgres cluster memberships] ***************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [service : Render L4 VIP configs] ****************************************************************************************************************************************
skipping: [172.21.0.3] => (item={u'src_ip': u'*', u'check_url': u'/primary', u'src_port': 5433, u'name': u'primary', u'dst_port': u'pgbouncer', u'selector': u'[]'})
skipping: [172.21.0.3] => (item={u'src_ip': u'*', u'check_url': u'/read-only', u'src_port': 5434, u'name': u'replica', u'selector_backup': u'[? pg_role == `primary`]', u'dst_port': u'pgbouncer', u'selector': u'[]'})
skipping: [172.21.0.16] => (item={u'src_ip': u'*', u'check_url': u'/primary', u'src_port': 5433, u'name': u'primary', u'dst_port': u'pgbouncer', u'selector': u'[]'})
skipping: [172.21.0.3] => (item={u'haproxy': {u'default_server_options': u'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100', u'balance': u'roundrobin', u'maxconn': 3000}, u'check_url': u'/primary', u'src_port': 5436, u'name': u'default', u'check_method': u'http', u'selector': u'[]', u'src_ip': u'*', u'dst_port': u'postgres', u'check_code': 200, u'check_port': u'patroni'})
skipping: [172.21.0.4] => (item={u'src_ip': u'*', u'check_url': u'/primary', u'src_port': 5433, u'name': u'primary', u'dst_port': u'pgbouncer', u'selector': u'[]'})
skipping: [172.21.0.16] => (item={u'src_ip': u'*', u'check_url': u'/read-only', u'src_port': 5434, u'name': u'replica', u'selector_backup': u'[? pg_role == `primary`]', u'dst_port': u'pgbouncer', u'selector': u'[]'})
skipping: [172.21.0.3] => (item={u'src_ip': u'*', u'check_url': u'/replica', u'src_port': 5438, u'name': u'offline', u'selector_backup': u'[? pg_role == `replica` && !pg_offline_query]', u'dst_port': u'postgres', u'selector': u'[? pg_role == `offline` || pg_offline_query ]'})
skipping: [172.21.0.4] => (item={u'src_ip': u'*', u'check_url': u'/read-only', u'src_port': 5434, u'name': u'replica', u'selector_backup': u'[? pg_role == `primary`]', u'dst_port': u'pgbouncer', u'selector': u'[]'})
skipping: [172.21.0.16] => (item={u'haproxy': {u'default_server_options': u'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100', u'balance': u'roundrobin', u'maxconn': 3000}, u'check_url': u'/primary', u'src_port': 5436, u'name': u'default', u'check_method': u'http', u'selector': u'[]', u'src_ip': u'*', u'dst_port': u'postgres', u'check_code': 200, u'check_port': u'patroni'})
skipping: [172.21.0.16] => (item={u'src_ip': u'*', u'check_url': u'/replica', u'src_port': 5438, u'name': u'offline', u'selector_backup': u'[? pg_role == `replica` && !pg_offline_query]', u'dst_port': u'postgres', u'selector': u'[? pg_role == `offline` || pg_offline_query ]'})
skipping: [172.21.0.4] => (item={u'haproxy': {u'default_server_options': u'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100', u'balance': u'roundrobin', u'maxconn': 3000}, u'check_url': u'/primary', u'src_port': 5436, u'name': u'default', u'check_method': u'http', u'selector': u'[]', u'src_ip': u'*', u'dst_port': u'postgres', u'check_code': 200, u'check_port': u'patroni'})
skipping: [172.21.0.4] => (item={u'src_ip': u'*', u'check_url': u'/replica', u'src_port': 5438, u'name': u'offline', u'selector_backup': u'[? pg_role == `replica` && !pg_offline_query]', u'dst_port': u'postgres', u'selector': u'[? pg_role == `offline` || pg_offline_query ]'})

TASK [service : include_tasks] ************************************************************************************************************************************************
skipping: [172.21.0.3]
skipping: [172.21.0.16]
skipping: [172.21.0.4]

TASK [register : Register postgres service to consul] *************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [register : Register patroni service to consul] **************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [register : Register pgbouncer service to consul] ************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [register : Register node-exporter service to consul] ********************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [register : Register pg_exporter service to consul] **********************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [register : Register pgbouncer_exporter service to consul] ***************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [register : Register haproxy (exporter) service to consul] ***************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [register : Register cluster service to consul] **************************************************************************************************************************
changed: [172.21.0.16] => (item={u'src_ip': u'*', u'check_url': u'/primary', u'src_port': 5433, u'name': u'primary', u'dst_port': u'pgbouncer', u'selector': u'[]'})
changed: [172.21.0.3] => (item={u'src_ip': u'*', u'check_url': u'/primary', u'src_port': 5433, u'name': u'primary', u'dst_port': u'pgbouncer', u'selector': u'[]'})
changed: [172.21.0.4] => (item={u'src_ip': u'*', u'check_url': u'/primary', u'src_port': 5433, u'name': u'primary', u'dst_port': u'pgbouncer', u'selector': u'[]'})
changed: [172.21.0.3] => (item={u'src_ip': u'*', u'check_url': u'/read-only', u'src_port': 5434, u'name': u'replica', u'selector_backup': u'[? pg_role == `primary`]', u'dst_port': u'pgbouncer', u'selector': u'[]'})
changed: [172.21.0.16] => (item={u'src_ip': u'*', u'check_url': u'/read-only', u'src_port': 5434, u'name': u'replica', u'selector_backup': u'[? pg_role == `primary`]', u'dst_port': u'pgbouncer', u'selector': u'[]'})
changed: [172.21.0.4] => (item={u'src_ip': u'*', u'check_url': u'/read-only', u'src_port': 5434, u'name': u'replica', u'selector_backup': u'[? pg_role == `primary`]', u'dst_port': u'pgbouncer', u'selector': u'[]'})
changed: [172.21.0.3] => (item={u'haproxy': {u'default_server_options': u'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100', u'balance': u'roundrobin', u'maxconn': 3000}, u'check_url': u'/primary', u'src_port': 5436, u'name': u'default', u'check_method': u'http', u'selector': u'[]', u'src_ip': u'*', u'dst_port': u'postgres', u'check_code': 200, u'check_port': u'patroni'})
changed: [172.21.0.16] => (item={u'haproxy': {u'default_server_options': u'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100', u'balance': u'roundrobin', u'maxconn': 3000}, u'check_url': u'/primary', u'src_port': 5436, u'name': u'default', u'check_method': u'http', u'selector': u'[]', u'src_ip': u'*', u'dst_port': u'postgres', u'check_code': 200, u'check_port': u'patroni'})
changed: [172.21.0.4] => (item={u'haproxy': {u'default_server_options': u'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100', u'balance': u'roundrobin', u'maxconn': 3000}, u'check_url': u'/primary', u'src_port': 5436, u'name': u'default', u'check_method': u'http', u'selector': u'[]', u'src_ip': u'*', u'dst_port': u'postgres', u'check_code': 200, u'check_port': u'patroni'})
changed: [172.21.0.3] => (item={u'src_ip': u'*', u'check_url': u'/replica', u'src_port': 5438, u'name': u'offline', u'selector_backup': u'[? pg_role == `replica` && !pg_offline_query]', u'dst_port': u'postgres', u'selector': u'[? pg_role == `offline` || pg_offline_query ]'})
changed: [172.21.0.16] => (item={u'src_ip': u'*', u'check_url': u'/replica', u'src_port': 5438, u'name': u'offline', u'selector_backup': u'[? pg_role == `replica` && !pg_offline_query]', u'dst_port': u'postgres', u'selector': u'[? pg_role == `offline` || pg_offline_query ]'})
changed: [172.21.0.4] => (item={u'src_ip': u'*', u'check_url': u'/replica', u'src_port': 5438, u'name': u'offline', u'selector_backup': u'[? pg_role == `replica` && !pg_offline_query]', u'dst_port': u'postgres', u'selector': u'[? pg_role == `offline` || pg_offline_query ]'})

TASK [Reload consul to finish register] ***************************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.4]

TASK [register : Register pgsql instance as prometheus target] ****************************************************************************************************************
changed: [172.21.0.3 -> 172.21.0.11] => (item=172.21.0.11)
changed: [172.21.0.16 -> 172.21.0.11] => (item=172.21.0.11)
changed: [172.21.0.4 -> 172.21.0.11] => (item=172.21.0.11)

TASK [register : Render datasource definition on meta node] *******************************************************************************************************************
changed: [172.21.0.3 -> meta] => (item={u'name': u'test'})
changed: [172.21.0.16 -> meta] => (item={u'name': u'test'})
changed: [172.21.0.4 -> meta] => (item={u'name': u'test'})

TASK [register : Load grafana datasource on meta node] ************************************************************************************************************************
changed: [172.21.0.3 -> meta] => (item={u'name': u'test'})
changed: [172.21.0.16 -> meta] => (item={u'name': u'test'})
changed: [172.21.0.4 -> meta] => (item={u'name': u'test'})

TASK [register : Create haproxy config dir resource dirs on /etc/pigsty] ******************************************************************************************************
ok: [172.21.0.3 -> 172.21.0.11] => (item=172.21.0.11)
ok: [172.21.0.16 -> 172.21.0.11] => (item=172.21.0.11)
ok: [172.21.0.4 -> 172.21.0.11] => (item=172.21.0.11)

TASK [register : Register haproxy upstream to nginx] **************************************************************************************************************************
changed: [172.21.0.16 -> 172.21.0.11] => (item=172.21.0.11)
changed: [172.21.0.3 -> 172.21.0.11] => (item=172.21.0.11)
changed: [172.21.0.4 -> 172.21.0.11] => (item=172.21.0.11)

TASK [register : Register haproxy url location to nginx] **********************************************************************************************************************
changed: [172.21.0.16 -> 172.21.0.11] => (item=172.21.0.11)
changed: [172.21.0.3 -> 172.21.0.11] => (item=172.21.0.11)
changed: [172.21.0.4 -> 172.21.0.11] => (item=172.21.0.11)

TASK [Reload nginx to finish haproxy register] ********************************************************************************************************************************
changed: [172.21.0.3 -> 172.21.0.11] => (item=172.21.0.11)
changed: [172.21.0.16 -> 172.21.0.11] => (item=172.21.0.11)
changed: [172.21.0.4 -> 172.21.0.11] => (item=172.21.0.11)

PLAY RECAP ********************************************************************************************************************************************************************
172.21.0.16                : ok=163  changed=126  unreachable=0    failed=0    skipped=79   rescued=0    ignored=0
172.21.0.3                 : ok=174  changed=137  unreachable=0    failed=0    skipped=68   rescued=0    ignored=0
172.21.0.4                 : ok=163  changed=126  unreachable=0    failed=0    skipped=79   rescued=0    ignored=0
```

</details>




------------------------

## 部署日志收集组件

Pigsty提供了可选的实时日志收集方案：`loki` 与 `promtail`，详情参考：【[教程：部署日志收集系统](t-logging.md)】

执行以下命令，完成日志收集组件的安装

```bash
./infra-loki.yml         # 在管理节点上安装loki(日志服务器)
./pgsql-promtail.yml     # 在数据库节点上安装promtail (日志Agent)
```

如果后续部署了新的数据库集群，您也需要在该集群上手工部署日志收集的Agent方可启用日志收集功能：

```bash
./pgsql-promtail.yml -l pg-test    # 在pg-test集群上部署日志收集组件
```

安装完毕后，访问 [PGLOG Instance](http://demo.pigsty.cc/d/pglog-instance) 面板即可查询单个实例的实时日志了。



<details>
<summary>安装日志组件的标准输出</summary>

```bash
[root@VM-0-11-centos pigsty]# ./infra-loki.yml
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see details

PLAY [Loki Init] **************************************************************************************************************************************************************

TASK [Copy loki binaries to /usr/bin] *****************************************************************************************************************************************
changed: [172.21.0.11] => (item=loki)
changed: [172.21.0.11] => (item=logcli)
changed: [172.21.0.11] => (item=loki-canary)

TASK [Cleanup loki] ***********************************************************************************************************************************************************
skipping: [172.21.0.11]

TASK [Render loki config] *****************************************************************************************************************************************************
changed: [172.21.0.11]

TASK [Copy loki systemd service] **********************************************************************************************************************************************
changed: [172.21.0.11]

TASK [loki : Launch Loki] *****************************************************************************************************************************************************
changed: [172.21.0.11]

TASK [Wait for loki online] ***************************************************************************************************************************************************
ok: [172.21.0.11]

PLAY RECAP ********************************************************************************************************************************************************************
172.21.0.11                : ok=5    changed=4    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

[root@VM-0-11-centos pigsty]# ./pgsql-promtail.yml
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see details

PLAY [Promtail Init] **********************************************************************************************************************************************************

TASK [Install promtail binary] ************************************************************************************************************************************************
changed: [172.21.0.16] => (item=promtail)
changed: [172.21.0.11] => (item=promtail)
changed: [172.21.0.4] => (item=promtail)
changed: [172.21.0.3] => (item=promtail)

TASK [Cleanup promtail] *******************************************************************************************************************************************************
skipping: [172.21.0.11]
skipping: [172.21.0.16]
skipping: [172.21.0.3]
skipping: [172.21.0.4]

TASK [Render promtail config] *************************************************************************************************************************************************
changed: [172.21.0.16]
changed: [172.21.0.4]
changed: [172.21.0.11]
changed: [172.21.0.3]

TASK [Copy promtail systemd service] ******************************************************************************************************************************************
changed: [172.21.0.3]
changed: [172.21.0.16]
changed: [172.21.0.11]
changed: [172.21.0.4]

TASK [Launch promtail] ********************************************************************************************************************************************************
changed: [172.21.0.11]
changed: [172.21.0.16]
changed: [172.21.0.3]
changed: [172.21.0.4]

TASK [Wait for promtail online] ***********************************************************************************************************************************************
ok: [172.21.0.3]
ok: [172.21.0.16]
ok: [172.21.0.4]
ok: [172.21.0.11]

PLAY RECAP ********************************************************************************************************************************************************************
172.21.0.11                : ok=5    changed=4    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
172.21.0.16                : ok=5    changed=4    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
172.21.0.3                 : ok=5    changed=4    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
172.21.0.4                 : ok=5    changed=4    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```

</details>

------------------------

## 安装扩展应用`covid`

Pigsty提供了两个数据可视化的小应用：covid 与 isd，这里以新冠疫情数据大盘`covid`为例。

执行以下命令，完成`covid`应用的安装

```bash
cd ~/pigsty/app/covid
make
```

安装中会从WHO官方网站下载当日最新的新冠疫情数据。

如果需要更新数据，执行 `make reload` 即可。

安装完毕后，访问 [COVID Overview](http://demo.pigsty.cc/d/covid-overview) 面板即可。
