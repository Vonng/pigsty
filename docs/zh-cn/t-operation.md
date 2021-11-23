# 常用操作命令


## 集群/实例管理

集群管理在底层通过Ansible剧本进行，所有命令行与图形界面工具都是通过调用剧本实现集群管理功能。以三节点`pg-test`集群为例。

```bash
# 集群初始化
./pgsql.yml -l pg-test           # 在新机器上初始化 pg-test 集群

# 实例初始化（集群扩容）
# 备注：初始化单个实例时，如果该实例不是集群主库，则应当保证该集群主库实例已经完成初始化
./pgsql.yml -l 10.10.10.13       # 初始化 pg-test 集群 中的 10.10.10.13 节点

# 集群销毁
# 先销毁所有非主库实例，最后销毁主库实例
./pgsql-remove.yml -l pg-test    # 销毁 pg-test 集群

# 实例销毁（集群缩容）
# 备注：销毁单个非主库实例即为集群缩容，若直接销毁主库会触发集群高可用自动切换
./pgsql-remove.yml -l pg-test    # 销毁 pg-test 集群
```

## 数据库/用户管理

可以通过 [`pgsql-createuser`](p-pgsql-createuser.md) 与 [`pgsql-createdb`](p-pgsql-createdb.md)在已有的数据库中创建新的[业务用户](c-user.md)与[业务数据库](c-database.md)。
业务用户通常指生产环境中由软件程序所使用的用户，例如需要通过连接池访问数据库的用户**必须**通过这种方式管理。其它用户可以使用Pigsty创建与管理，亦可由用户自行维护管理。

```bash
# 在 pg-test 集群创建名为 test 的用户
./pgsql-createuser.yml -l pg-test -e pg_user=test

# 在 pg-test 集群创建名为 test 的数据库
./pgsql-createdb.yml   -l pg-test -e pg_database=test
```

以上命令可以简写为：

```bash
bin/createuser pg-test test  # 在 pg-test 集群创建名为 test 的用户
bin/createdb   pg-test test  # 在 pg-test 集群创建名为 test 的数据库
```

如果数据库配置有OWNER，请先创建对应OWNER用户后再创建相应数据库。


## 组件服务管理

在Pigsty的部署中，所有组件均由`systemd`管理；PostgreSQL除外，PostgreSQL由Patroni管理。
当 [`patroni_mode`](v-pg-provision.md#patroni_mode) 为 `remove` 时例外，Pigsty将直接使用systemd管理Postgres

```bash
systemctl stop patroni             # 关闭 Patroni & Postgres
systemctl stop pgbouncer           # 关闭 Pgbouncer 
systemctl stop pg_exporter         # 关闭 PG Exporter
systemctl stop pgbouncer_exporter  # 关闭 Pgbouncer Exporter
systemctl stop node_exporter       # 关闭 Node Exporter
systemctl stop haproxy             # 关闭 Haproxy
systemctl stop vip-manager         # 关闭 Vip-Manager
systemctl stop consul              # 关闭 Consul
systemctl stop postgres            # 关闭 Postgres （仅当 patroni_mode = remove 时使用）
```

以下组件可以通过 `systemctl reload` 重新加载配置

```bash
systemctl reload pgbouncer           # 重载配置： Pgbouncer 
systemctl reload pg_exporter         # 重载配置： PG Exporter
systemctl reload pgbouncer_exporter  # 重载配置： Pgbouncer Exporter
systemctl reload haproxy             # 重载配置： Haproxy
systemctl reload vip-manager         # 重载配置： vip-manager
systemctl reload consul              # 重载配置： Consul
systemctl reload postgres            # 重载配置： Postgres （仅当 patroni_mode = remove 时使用）
```

在管理节点上，还可以通过 `systemctl reload` 重新加载基础设施组件的配置：

```bash
systemctl reload nginx              # 重载配置： Nginx （更新Haproxy管理界面索引，以及外部访问域名）
systemctl reload prometheus         # 重载配置： Prometheus （更新预计算指标计算逻辑与告警规则）
systemctl reload alertmanager       # 重载配置： Alertmanager
systemctl reload grafana-server     # 重载配置： Grafana
```

当Patroni管理Postgres时，请不要使用 `pg_ctl` 直接操作数据库集簇 （`/pg/data`），您可以通过`pt pause`进入维护模式后再对数据库进行手工管理。




## 数据库管理

用户可以通过`patronictl`管理Patroni与Postgres，使用`patronictl`时需要使用数据库dbsu用户执行（默认为`postgres`），并通过`-c`指定配置文件地址。

以下快捷方式别名已经默认加入到所有节点的 `bashrc` 中。

```bash
alias pt='patronictl -c /pg/bin/patroni.yml'
```

下面将统一使用`pt`作为命令缩写，使用`pt --help`可以打印命令帮助：

```bash
Commands:
  configure    Create configuration file
  dsn          Generate a dsn for the provided member,...
  edit-config  Edit cluster configuration
  failover     Failover to a replica
  flush        Discard scheduled events
  history      Show the history of failovers/switchovers
  list         List the Patroni members for a given Patroni
  pause        Disable auto failover
  query        Query a Patroni PostgreSQL member
  reinit       Reinitialize cluster member
  reload       Reload cluster member configuration
  remove       Remove cluster from DCS
  restart      Restart cluster member
  resume       Resume auto failover
  scaffold     Create a structure for the cluster in DCS
  show-config  Show cluster configuration
  switchover   Switchover to a replica
  topology     Prints ASCII topology for given cluster
  version      Output version of patronictl command or a...
```

常用的管理命令如下所示

```bash
pt list [cluster]               # 打印集群信息
pt edit-config [cluster]        # 编辑某个集群的配置文件 
pt reload  [cluster] [instance] # 重载某个集群或实例的配置

pt pause  [cluster]             # 进入维护模式（不会触发自动故障切换，Patroni不再操作Postgres）
pt resume [cluster]             # 退出维护模式

pt failover [cluster]           # 手工触发某集群的Failover
pt switchover [cluster]         # 手工触发某集群的Switchover

pt restart [cluster] [instance] # 重启某个集群或实例 
pt reinit  [cluster]            # 重新初始化某个集群中的实例
```

例如，想要在三节点演示集群 `pg-test` 上执行Failover，则可以执行以下命令：

<details>
<summary>执行Failover的操作记录</summary>

```bash
[08-05 17:00:29] postgres@pg-meta-1:~
$ pt list
+ Cluster: pg-meta (6988886159426736948) ----+----+-----------+-----------------+-----------------+
| Member    | Host        | Role   | State   | TL | Lag in MB | Pending restart | Tags            |
+-----------+-------------+--------+---------+----+-----------+-----------------+-----------------+
| pg-meta-1 | 172.21.0.11 | Leader | running |  1 |           | *               | clonefrom: true |
+-----------+-------------+--------+---------+----+-----------+-----------------+-----------------+
 Maintenance mode: on

[08-05 17:00:30] postgres@pg-meta-1:~
$ pt list pg-test
+ Cluster: pg-test (6988888117682961035) -----+----+-----------+-----------------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Pending restart | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+-----------------+
| pg-test-1 | 172.21.0.3  | Leader  | running |  1 |           |                 | clonefrom: true |
| pg-test-2 | 172.21.0.4  | Replica | running |  1 |         0 | *               | clonefrom: true |
| pg-test-3 | 172.21.0.16 | Replica | running |  1 |         0 | *               | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+-----------------+

[08-05 17:00:34] postgres@pg-meta-1:~
$ pt failover pg-test
Candidate ['pg-test-2', 'pg-test-3'] []: pg-test-3
Current cluster topology
+ Cluster: pg-test (6988888117682961035) -----+----+-----------+-----------------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Pending restart | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+-----------------+
| pg-test-1 | 172.21.0.3  | Leader  | running |  1 |           |                 | clonefrom: true |
| pg-test-2 | 172.21.0.4  | Replica | running |  1 |         0 | *               | clonefrom: true |
| pg-test-3 | 172.21.0.16 | Replica | running |  1 |         0 | *               | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+-----------------+
Are you sure you want to failover cluster pg-test, demoting current master pg-test-1? [y/N]: y
2021-08-05 17:00:46.04144 Successfully failed over to "pg-test-3"
+ Cluster: pg-test (6988888117682961035) -----+----+-----------+-----------------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Pending restart | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+-----------------+
| pg-test-1 | 172.21.0.3  | Replica | stopped |    |   unknown |                 | clonefrom: true |
| pg-test-2 | 172.21.0.4  | Replica | running |  1 |         0 | *               | clonefrom: true |
| pg-test-3 | 172.21.0.16 | Leader  | running |  1 |           | *               | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+-----------------+

[08-05 17:00:46] postgres@pg-meta-1:~
$ pt list pg-test
+ Cluster: pg-test (6988888117682961035) -----+----+-----------+-----------------+-----------------+
| Member    | Host        | Role    | State   | TL | Lag in MB | Pending restart | Tags            |
+-----------+-------------+---------+---------+----+-----------+-----------------+-----------------+
| pg-test-1 | 172.21.0.3  | Replica | running |  2 |         0 | *               | clonefrom: true |
| pg-test-2 | 172.21.0.4  | Replica | running |  2 |         0 | *               | clonefrom: true |
| pg-test-3 | 172.21.0.16 | Leader  | running |  2 |           | *               | clonefrom: true |
+-----------+-------------+---------+---------+----+-----------+-----------------+-----------------+
```

</details>





## 维护性操作

#### **维护负载均衡配置**

这里介绍Pigsty默认使用的HAProxy接入方式，如果您使用L4 VIP或其它方式接入，则可能与此不同。

集群缩容后，集群负载均衡会根据健康检查**立刻重新分配流量**，但**不会移除下线实例的配置项**。
集群扩容后，**已有实例的负载均衡器配置不会变化**。即，您可以通过新实例上的HAProxy访问已有集群的所有成员，但旧实例上的HAProxy配置不变，因此不会将流量分发至新实例上。
为了让集群已有HAProxy将流量分发至新的数据库实例，您需要在合适的时候更新集群的负载均衡配置：

```bash
# 完整更新集群内的HAProxy负载均衡配置并应用（不会中断已有流量）
./pgsql.yml -l pg-test -t haproxy_config,haproxy_reload
```

#### **维护HBA规则**

Pigsty使用的HBA规则基于 **角色** 而定义，如果您针对数据库主从角色定制了不同的访问控制策略，则需要在集群故障切换后重新调整实例的HBA规则。

```bash
# 重新根据配置渲染 PG HBA规则并应用
./pgsql.yml -l pg-test -t pg_hba
```


#### **维护Prometheus监控目标**

Pigsty默认使用静态文件服务发现来配置监控目标，每一个实例都有一个配置文件，形如：

```bash
# pg-meta-1 [primary] @ 172.21.0.11
- labels: { cls: pg-meta, ins: pg-meta-1 }
  targets: [172.21.0.11:9630, 172.21.0.11:9100, 172.21.0.11:9631, 172.21.0.11:9101]
```

该配置文件会在集群/实例初始化与扩缩容时自动维护，您也可以通过以下命令，重新从配置清单中生产目标实例定义

```bash
# 将 pg-test 集群中的所有实例 注册至管理节点的Prometheus 
# /etc/prometheus/targets/pgsql/<instance>.yml
./pgsql.yml -l pg-test -t register_prometheus

# 仅更新单个实例的配置
./pgsql.yml -l 10.10.10.10 -t register_prometheus
```


#### **维护Grafana数据源：Postgres**

每一个Postgres实例上的每一个[业务数据库](c-database.md)都会在创建时自动注册至Grafana中，您也可以使用以下命令手工注册

```bash
# 将 pg-test 集群中的所有实例上的所有业务数据库 注册至管理节点的Grafana
./pgsql.yml -l pg-test -t register_grafana
```

