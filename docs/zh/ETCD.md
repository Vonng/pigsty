# ETCD

> ETCD 是一个分布式的、可靠的键-值存储，用于存放分布式系统中最关键的数据：例如集群配置，高可用选主共识等。

Pigsty 使用 [**etcd**](https://etcd.io/) 作为 [**DCS**](https://patroni.readthedocs.io/en/latest/dcs_failsafe_mode.html)：分布式配置存储（或称为分布式共识服务）。这对于 PostgreSQL 的高可用性与自动故障转移至关重要。

在安装任何 [`PGSQL`](PGSQL) 模块之前，你必须先安装 [`ETCD`](ETCD) 模块，因为 `patroni` 和 `vip-manager` 会依赖 etcd 模块，除非你决定使用外部的现有 etcd 集群。

在安装 [`ETCD`](ETCD) 模块前，你需要先安装 [`NODE`](NODE) 模块将节点纳管：因为 etcd 需要可信任的 CA 来工作。更多详细信息，请查看 [ETCD管理SOP](ETCD-ADMIN)。


----------------

## 剧本

有一个内置的 playbook： [`etcd.yml`](https://github.com/Vonng/pigsty/blob/master/etcd.yml)，用于安装 etcd 集群。但首先你需要[定义](#配置)它。

```bash
./etcd.yml    # 在 'etcd' 组上安装 etcd 模块
```

以下是可用的任务子集：

- `etcd_assert`  ：生成 etcd 身份
- `etcd_install` ：安装 etcd rpm 包
- `etcd_clean`   ：清理现有的 etcd 实例
  - `etcd_check` ：检查 etcd 实例是否在运行
  - `etcd_purge` ：删除正在运行的 etcd 实例和数据
- `etcd_dir`     ：创建 etcd 数据和配置目录
- `etcd_config`  ：生成 etcd 配置
  - `etcd_conf`  ：生成 etcd 主配置
  - `etcd_cert`  ：生成 etcd ssl 证书
- `etcd_launch`  ：启动 etcd 服务
- `etcd_register` ： 将 etcd 注册到 prometheus

如果 [`etcd_safeguard`](PARAM#etcd_safeguard) 设置为 `true`，或者 [`etcd_clean`](PARAM#etcd_clean) 设置 `false`，那么如果存在任何正在运行的 etcd 实例，剧本将会中止以防意外地删除 etcd 实例。

[![asciicast](https://asciinema.org/a/566414.svg)](https://asciinema.org/a/566414)



----------------

## 配置

在执行实际部署之前，你必须先定义一个 etcd 集群。关于 etcd 的一些[参数](#参数)。

建议在正式的生产环境使用至少3个实例，这样可以容忍1个实例失效

**单节点**

在配置清单中定义一个 `etcd` 组，它将创建一个单例 etcd 实例。

```yaml
# 单实例 etcd ‘集群’，供 PostgreSQL 高可用使用
etcd: { hosts: { 10.10.10.10: { etcd_seq: 1 } }, vars: { etcd_cluster: etcd } }
```

对于开发、测试和演示，一个实例足够了，但在正式的生产环境中最好不要这样做。


**三节点**

你可以在多个节点上部署 etcd 集群，避免单点失效。

请使用奇数个实例数量，避免出现裁决失效的情况。


```yaml
etcd: 
  hosts:
    10.10.10.10: { etcd_seq: 1 }  # etcd_seq （etcd实例号）是必须指定的身份参数
    10.10.10.11: { etcd_seq: 2 }  # 实例号是正整数，一般从1开始依次分配
    10.10.10.12: { etcd_seq: 3 }  # 实例号应当终生不可变，一旦分配就不再回收使用。
  vars: # 集群层面的参数
    etcd_cluster: etcd    # 默认情况下，etcd集群名就叫 etcd， 除非您想要部署多套 etcd 集群，否则不要改这个名字
    etcd_safeguard: false # 是否打开 etcd 的防误删安全保险？ 在生产环境初始化完成后，可以考虑打开这个选项，避免误删。
    etcd_clean: true      # 在初始化过程中，是否强制移除现有的 etcd 实例？测试的时候可以打开，这样剧本就是真正幂等的。
```

**更多节点**

你也可以向现有的 etcd 集群中添加成员：首先需要使用 `etcdctl member add` 告知现有集群有新实例要加入：

```bash
# 告知现有集群有新实例要加入
etcdctl member add <etcd-?> --peer-urls=https://<new_ins_ip>:2380

# 真正初始化新的 etcd 实例
./etcd.yml -l <new_ins_ip> -e etcd_init=existing
```

查看 [ETCD 管理](ETCD-ADMIN) 以获取更多详情。



----------------

## 管理

以下是一些用于 etcd 管理的有用命令，更多详细信息请查看 [ETCD ADMIN](ETCD-ADMIN)。

**集群管理**

- [创建集群](etcd-admin#创建集群)
- [销毁集群](etcd-admin#销毁集群)
- [重载配置](etcd-admin#重载配置)
- [添加成员](etcd-admin#添加成员)
- [移除成员](etcd-admin#移除成员)


**环境**

Pigsty 默认使用 etcd v3 API，以下是etcd客户端配置环境变量的示例。

```bash
alias e="etcdctl"
alias em="etcdctl member"
export ETCDCTL_API=3
export ETCDCTL_ENDPOINTS=https://10.10.10.10:2379
export ETCDCTL_CACERT=/etc/pki/ca.crt
export ETCDCTL_CERT=/etc/etcd/server.crt
export ETCDCTL_KEY=/etc/etcd/server.key
```

**CRUD**

你可以使用以下命令进行 CRUD 操作。

```bash
e put a 10 ; e get a; e del a ; # V3 API
```


----------------

## 监控

ETCD 模块提供了一个监控面板：

[ETCD Overview](https://demo.pigsty.cc/d/etcd-overview)：ETCD 集群概览

<details><summary>ETCD Overview Dashboard</summary>

这个监控面板提供了 ETCD 状态的关键信息：最值得关注的是 ETCD Aliveness，它显示了 ETCD 集群整体的服务状态。

红色的条带标识着实例不可用的时间段，而底下蓝灰色的条带标识着整个集群处于不可用的时间段。

[![etcd-overview](https://github.com/Vonng/pigsty/assets/8587410/3f268146-9242-42e7-b78f-b5b676155f3f)](https://demo.pigsty.cc/d/etcd-overview)

</details>



----------------

## 参数

[ETCD](PARAM#etcd) 模块有 10 个相关参数：

| 参数                                                         |   类型   |  级别   | 注释                            |
|------------------------------------------------------------|:------:|:-----:|-------------------------------|
| [`etcd_seq`](PARAM#etcd_seq)                               |  int   |   I   | etcd 实例标识符，必填                 |
| [`etcd_cluster`](PARAM#etcd_cluster)                       | string |   C   | etcd 集群名，默认固定为 etcd           |
| [`etcd_safeguard`](PARAM#etcd_safeguard)                   |  bool  | G/C/A | etcd 防误删保险，阻止清除正在运行的 etcd 实例？ |
| [`etcd_clean`](PARAM#etcd_clean)                           |  bool  | G/C/A | etcd 清除指令：在初始化时清除现有的 etcd 实例？ |
| [`etcd_data`](PARAM#etcd_data)                             |  path  |   C   | etcd 数据目录，默认为 /data/etcd      |
| [`etcd_port`](PARAM#etcd_port)                             |  port  |   C   | etcd 客户端端口，默认为 2379           |
| [`etcd_peer_port`](PARAM#etcd_peer_port)                   |  port  |   C   | etcd 同伴端口，默认为 2380            |
| [`etcd_init`](PARAM#etcd_init)                             |  enum  |   C   | etcd 初始集群状态，新建或已存在            |
| [`etcd_election_timeout`](PARAM#etcd_election_timeout)     |  int   |   C   | etcd 选举超时，默认为 1000ms          |
| [`etcd_heartbeat_interval`](PARAM#etcd_heartbeat_interval) |  int   |   C   | etcd 心跳间隔，默认为 100ms           |

```yaml
#etcd_seq: 1                      # etcd instance identifier, explicitly required
#etcd_cluster: etcd               # etcd cluster & group name, etcd by default
etcd_safeguard: false             # prevent purging running etcd instance?
etcd_clean: true                  # purging existing etcd during initialization?
etcd_data: /data/etcd             # etcd data directory, /data/etcd by default
etcd_port: 2379                   # etcd client port, 2379 by default
etcd_peer_port: 2380              # etcd peer port, 2380 by default
etcd_init: new                    # etcd initial cluster state, new or existing
etcd_election_timeout: 1000       # etcd election timeout, 1000ms by default
etcd_heartbeat_interval: 100      # etcd heartbeat interval, 100ms by default
```
