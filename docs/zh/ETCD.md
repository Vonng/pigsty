# ETCD

> ETCD 是一个分布式的、可靠的键-值存储，用于存放系统中最为关键的数据。 [配置](#配置) | [管理](#管理) | [剧本](#剧本) | [监控](#监控) | [参数](#参数)

Pigsty 使用 [**etcd**](https://etcd.io/) 作为 [**DCS**](https://patroni.readthedocs.io/en/latest/dcs_failsafe_mode.html)：分布式配置存储（或称为分布式共识服务）。这对于 PostgreSQL 的高可用性与自动故障转移至关重要。

在安装任何 [`PGSQL`](PGSQL) 模块之前，你必须先安装 [`ETCD`](ETCD) 模块，因为 `patroni` 和 `vip-manager` 会依赖 etcd 模块，除非你决定使用外部的现有 etcd 集群。

在安装 [`ETCD`](ETCD) 模块前，你无需安装 [`NODE`](NODE) 模块，但应当确保本地 `CA` 是可用的（`INFRA`.`CA`）：因为 etcd 需要可信任的 CA 才能签发证书。




----------------

## 配置

在执行实际部署之前，你必须先定义一个 etcd 集群。关于 etcd 的一些[参数](#参数)。

建议在正式的生产环境使用至少[三节点](#三节点)，这样可以容忍一个实例失效

### 单节点

在配置清单中定义一个 `etcd` 组，它将创建一个单例 etcd 实例。

```yaml
# 单实例 etcd ‘集群’，供 PostgreSQL 高可用使用
etcd: { hosts: { 10.10.10.10: { etcd_seq: 1 } }, vars: { etcd_cluster: etcd } }
```

对于开发、测试和演示，一个实例足够了，但在正式的生产环境中最好不要这样做。


### 三节点

你可以在多个节点上部署 etcd 集群，避免单点失效。

```yaml
etcd: 
  hosts:
    10.10.10.10: { etcd_seq: 1 }  # etcd_seq （etcd实例号）是必须指定的身份参数
    10.10.10.11: { etcd_seq: 2 }  # 实例号是正整数，一般从 0 或 1 开始依次分配
    10.10.10.12: { etcd_seq: 3 }  # 实例号应当终生不可变，一旦分配就不再回收使用。
  vars: # 集群层面的参数
    etcd_cluster: etcd    # 默认情况下，etcd集群名就叫 etcd， 除非您想要部署多套 etcd 集群，否则不要改这个名字
    etcd_safeguard: false # 是否打开 etcd 的防误删安全保险？ 在生产环境初始化完成后，可以考虑打开这个选项，避免误删。
    etcd_clean: true      # 在初始化过程中，是否强制移除现有的 etcd 实例？测试的时候可以打开，这样剧本就是真正幂等的。
```

五节点或更多实例的配置依此类推，请使用奇数个实例数量，避免出现裁决失效的情况。




----------------

## 管理

以下是一些 etcd 管理的常见任务说明，更多问题请参考 [FAQ：ETCD](FAQ#etcd)。

- [创建集群](#创建集群)：如何初始化 etcd 集群？
- [销毁集群](#销毁集群)：如何销毁 etcd 集群？
- [环境变量](#环境变量)：如何配置 etcd 客户端，以访问 etcd 服务器集群？
- [重载配置](#重载配置)：如何更新客户端使用的 etcd 服务器成员列表？
- [添加成员](#添加成员)：如何向现有 etcd 集群添加新成员？
- [移除成员](#移除成员)：如何从 etcd 集群移除老成员？


----------------

### 创建集群

要创建一个集群，在配置清单中定义好后，执行 [`etcd.yml`](#etcdyml) 剧本即可。

```yaml
etcd:
  hosts:
    10.10.10.10: { etcd_seq: 1 }
    10.10.10.11: { etcd_seq: 2 }
    10.10.10.12: { etcd_seq: 3 }
  vars: { etcd_cluster: etcd }
```

```bash
./etcd.yml  # 初始化 etcd 集群 
```

注意，Pigsty 的 etcd 模块提供了防误删保护机制。在默认配置下， [`etcd_clean`](PARAM#etcd_clean) 配置打开，且 [`etcd_safeguard`](PARAM#etcd_safeguard) 配置关闭，
那么执行此剧本的过程中即使遇到存活的etcd实例，也会强制移除，在这种情况下 `etcd.yml` 剧本是真正幂等的。这种配置对于开发，测试，以及生产环境紧急强制重建 etcd 集群来说是有用的。

对于生产环境已经初始化好的 etcd 集群，可以打开防误删保护，避免误删现有的 etcd 实例。此时当剧本检测到存活 etcd 实例时会主动中止，避免误删现有 etcd 实例，您可以使用命令行参数来覆盖这一行为。

----------------

### 销毁集群

要销毁一个 etcd 集群，只需使用 [`etcd.yml`](#etcdyml) 剧本的 `etcd_clean` 子任务即可。执行此命令前请务必三思！

```bash
./etcd.yml -t etcd_clean  # 移除整个集群，会检查现有实例是否存在，根据安全保险判断是否执行
./etcd.yml -t etcd_purge  # 强制移除整个集群，根本不管安全保险是否启用。
```

使用 `etcd_clean` 子任务会尊重 [`etcd_safeguard`](PARAM#etcd_safeguard) 防误删保险的配置，使用 `etcd_purge` 子任务则会无视一切清理现有 etcd 集群。


----------------

### 环境变量

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

配置好客户端环境变量后，你可以使用以下命令进行 etcd CRUD 操作：

```bash
e put a 10 ; e get a; e del a ; # V3 API
```


----------------

### 重载配置

如果 etcd 集群的成员发生变化，我们需要刷新对 etcd 服务端点的引用，目前 Pigsty 中有四处 etcd 引用：

- 现有 etcd 实例成员的配置文件
- etcdctl 客户端环境变量（[infra节点](NODE#infra节点)上）
- patroni DCS 端点配置（[pgsql节点](NODE#pgsql节点)上）
- vip-manager DCS 端点配置（可选）

要在现有etcd成员上刷新 etcd 配置文件 `/etc/etcd/etcd.conf`：

```bash
./etcd.yml -t etcd_conf                           # 使用最新状态刷新 /etc/etcd/etcd.conf
ansible etcd -f 1 -b -a 'systemctl restart etcd'  # 可选操作：重启 etcd 
```

刷新 `etcdctl` 客户端环境变量：

```bash
$ ./etcd.yml -t etcd_env                          # 刷新 /etc/profile.d/etcdctl.sh （管理节点）
```

在 `patroni` 上更新 etcd 端点引用：

```bash
./pgsql.yml -t pg_conf                            # 重新生成 patroni 配置
ansible all -f 1 -b -a 'systemctl reload patroni' # 重新加载 patroni 配置
```

在 `vip-manager` 上更新 etcd 端点引用（如果你正在使用 PGSQL L2 VIP 才需要执行此操作）：

```bash
./pgsql.yml -t pg_vip_config                           # 重新生成 vip-manager 配置
ansible all -f 1 -b -a 'systemctl restart vip-manager' # 重启 vip-manager 以使用新配置 
```



----------------

### 添加成员

ETCD 参考: [添加成员](https://etcd.io/docs/v3.5/op-guide/runtime-configuration/#add-a-new-member)

向现有的 etcd 集群添加新成员通常需要五个步骤：

**简短版本**

1. 执行 `etcdctl member add` 命令，通知现有集群即将有新成员加入（使用学习者模式）
2. 更新配置清单，将新实例写入配置文件 `etcd` 组中。
3. 使用 `etcd_init=existing` 的方式初始化新的 etcd 实例，使其加入现有集群而不是创建一个新集群（**非常重要**）
4. 将新成员从学习者提升为追随者，正式成为集群中具有投票权的一员。
5. [重载配置](#重载配置) 以更新客户端使用的 etcd 服务端点。

```bash
etcdctl member add <etcd-?> --learner=true --peer-urls=https://<new_ins_ip>:2380  # 通知集群
./etcd.yml -l <new_ins_ip> -e etcd_init=existing                                  # 初始化新实例
etcdctl member promote <new_ins_server_id>                                        # 提升实例为追随者
```

<details><summary>详细步骤：向etcd集群添加成员</summary>

下面是具体操作的详细细节，让我们从一个单实例 etcd 集群开始：

```yaml
etcd:
  hosts:
    10.10.10.10: { etcd_seq: 1 } # <--- 集群中原本存在的唯一实例
    10.10.10.11: { etcd_seq: 2 } # <--- 将此新成员定义添加到清单中
  vars: { etcd_cluster: etcd }
```

使用 `etcd member add` 向现有 etcd 集群宣告新的学习者实例 `etcd-2` 即将到来：

```bash
$ etcdctl member add etcd-2 --learner=true --peer-urls=https://10.10.10.11:2380
Member 33631ba6ced84cf8 added to cluster 6646fbcf5debc68f

ETCD_NAME="etcd-2"
ETCD_INITIAL_CLUSTER="etcd-2=https://10.10.10.11:2380,etcd-1=https://10.10.10.10:2380"
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://10.10.10.11:2380"
ETCD_INITIAL_CLUSTER_STATE="existing"
```

使用 `etcdctl member list`（或 `em list`）检查成员列表，我们可以看到一个 `unstarted` 新成员：

```bash
33631ba6ced84cf8, unstarted, , https://10.10.10.11:2380, , true       # 这里有一个未启动的新成员
429ee12c7fbab5c1, started, etcd-1, https://10.10.10.10:2380, https://10.10.10.10:2379, false
```

接下来使用 `etcd.yml` 剧本初始化新的 etcd 实例 `etcd-2`，完成后，我们可以看到新成员已经启动：

```bash
$ ./etcd.yml -l 10.10.10.11 -e etcd_init=existing    # 一定要添加 existing 参数，命令行或配置文件均可
...
33631ba6ced84cf8, started, etcd-2, https://10.10.10.11:2380, https://10.10.10.11:2379, true
429ee12c7fbab5c1, started, etcd-1, https://10.10.10.10:2380, https://10.10.10.10:2379, false
```

新成员初始化完成并稳定运行后，可以将新成员从学习者提升为追随者：

```bash
$ etcdctl member promote 33631ba6ced84cf8   # 将学习者提升为追随者，这里需要使用 etcd 实例的 ID
Member 33631ba6ced84cf8 promoted in cluster 6646fbcf5debc68f

$ em list                # check again, the new member is started
33631ba6ced84cf8, started, etcd-2, https://10.10.10.11:2380, https://10.10.10.11:2379, false
429ee12c7fbab5c1, started, etcd-1, https://10.10.10.10:2380, https://10.10.10.10:2379, fals
```

新成员添加完成，请不要忘记 [重载配置](#重载配置) ，让所有客户端也知道新成员的存在。

重复以上步骤，可以添加更多成员。记住，生产环境中至少要使用 3 个成员。

</details>


----------------

### 移除成员

要从 etcd 集群中删除一个成员实例，通常需要以下三个步骤：

1. 从配置清单中注释/屏蔽/删除该实例，并[重载配置](#重载配置)，让客户端不再使用该实例。
2. 使用 `etcdctl member remove <server_id>` 命令将它从集群中踢除
3. 将该实例临时添加回配置清单，使用剧本彻底移除下线该实例，然后永久从配置中删除

<details><summary>详细步骤：从etcd集群移除成员</summary>

让我们以一个 3 节点的 etcd 集群为例，从中移除 3 号实例。

为了刷新配置，您需要 **注释** 要待删除的成员，然后 [重载配置](#重载配置)，让所有客户端都不要再使用此实例。

```yaml
etcd:
  hosts:
    10.10.10.10: { etcd_seq: 1 }
    10.10.10.11: { etcd_seq: 2 }
    10.10.10.12: { etcd_seq: 3 }   # <---- 首先注释掉这个成员，然后重载配置
  vars: { etcd_cluster: etcd }
```

然后，您需要使用 `etcdctl member remove` 命令，将它从集群中踢出去：

```bash
$ etcdctl member list 
429ee12c7fbab5c1, started, etcd-1, https://10.10.10.10:2380, https://10.10.10.10:2379, false
33631ba6ced84cf8, started, etcd-2, https://10.10.10.11:2380, https://10.10.10.11:2379, false
93fcf23b220473fb, started, etcd-3, https://10.10.10.12:2380, https://10.10.10.12:2379, false  # <--- remove this

$ etcdctl member remove 93fcf23b220473fb  # kick it from cluster
Member 93fcf23b220473fb removed from cluster 6646fbcf5debc68f
```

最后，您要将该成员临时添加回配置清单中以便运行下线任务，将实例彻底关停移除。

```bash
./etcd.yml -t etcd_purge -l 10.10.10.12   # 下线该实例（注意：执行这个命令要求这个实例的定义还在配置清单里）
```

执行完毕后，您可以将其从配置清单中永久删除，移除成员至此完成。

重复以上步骤，可以移除更多成员，与[添加成员](#添加成员)配合使用，可以对 etcd 集群进行滚动升级搬迁。

</details>



----------------

## 剧本

ETCD 模块提供了一个内置的 playbook： [`etcd.yml`](https://github.com/Vonng/pigsty/blob/master/etcd.yml)，用于安装 etcd 集群。但首先你需要[定义](#配置)它。

### `etcd.yml`

在 [`etcd.yml`](https://github.com/Vonng/pigsty/blob/master/etcd.yml) 中，提供了以下是可用的任务子集：

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


[![asciicast](https://asciinema.org/a/566414.svg)](https://asciinema.org/a/566414)



----------------

## 监控

ETCD 模块提供了一个监控面板：Etcd Overview。


### ETCD Overview Dashboard

[ETCD Overview](https://demo.pigsty.cc/d/etcd-overview)：ETCD 集群概览

这个监控面板提供了 ETCD 状态的关键信息：最值得关注的是 ETCD Aliveness，它显示了 ETCD 集群整体的服务状态。

红色的条带标识着实例不可用的时间段，而底下蓝灰色的条带标识着整个集群处于不可用的时间段。

[![etcd-overview.jpg](https://repo.pigsty.cc/img/etcd-overview.jpg)](https://demo.pigsty.cc/d/etcd-overview)




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
#etcd_seq: 1                      # etcd 实例标识符，必填
#etcd_cluster: etcd               # etcd 集群名，默认固定为 etcd
etcd_safeguard: false             # etcd 防误删保险，阻止清除正在运行的 etcd 实例？
etcd_clean: true                  # etcd 清除指令：在初始化时清除现有的 etcd 实例？
etcd_data: /data/etcd             # etcd 数据目录，默认为 /data/etcd
etcd_port: 2379                   # etcd 客户端端口，默认为 2379
etcd_peer_port: 2380              # etcd 同伴端口，默认为 2380
etcd_init: new                    # etcd 初始集群状态，新建或已存在
etcd_election_timeout: 1000       # etcd 选举超时，默认为 1000ms
etcd_heartbeat_interval: 100      # etcd 心跳间隔，默认为 100ms
```
