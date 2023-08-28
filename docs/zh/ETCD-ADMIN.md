# ETCD 集群管理

> 这里列出了一些 [`ETCD`](ETCD) 集群的常见管理任务

- [创建集群](#创建集群)
- [销毁集群](#销毁集群)
- [重载配置](#重载配置)
- [添加成员](#添加成员)
- [移除成员](#移除成员)


----------------

## 创建集群

要创建一个集群，在配置清单中定义好后，执行 `etcd.yml` 剧本即可。

在默认配置下： [`etcd_clean`](PARAM#etcd_clean) 配置打开，且 [`etcd_safeguard`](PARAM#etcd_safeguard) 配置关闭，
那么执行此剧本的过程中即使遇到存活的etcd实例，也会强制移除，在这种情况下 `etcd.yml` 剧本是真正幂等的。
这种配置对于开发，测试，以及生产环境紧急强制重建 etcd 集群来说是有用的。 

如果两者之一不成立，那么当剧本检测到存活 etcd 实例时会主动中止，避免误删现有 etcd 实例。

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



----------------

## 销毁集群

要销毁一个 etcd 集群，只需使用 `etcd.yml` 剧本的 `etcd_clean` 子任务。执行此命令前请务必三思！

```bash
./etcd.yml -t etcd_clean  # 移除整个集群，会检查现有实例是否存在，根据安全保险判断是否执行
./etcd.yml -t etcd_purge  # 强制移除整个集群，根本不管安全保险是否启用。
```



----------------

## 重载配置

如果 etcd 集群的成员发生变化，我们需要刷新对 etcd 服务端点的引用，包括以下四项：

- 现有 etcd 成员的配置文件
- etcdctl 客户端环境变量
- patroni dcs 端点配置
- vip-manager dcs 端点配置

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

## 添加成员

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



----------------

## 移除成员

要从 etcd 集群中删除一个成员实例，通常需要以下三个步骤：

1. 从配置清单中注释/屏蔽/删除该实例，并[重载配置](#重载配置)，让客户端不再使用该实例。
2. 使用 `etcdctl member remove <server_id>` 命令将它从集群中踢除
3. 将该实例临时添加回配置清单，使用剧本彻底移除下线该实例，然后永久从配置中删除


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
