# 常用操作流程 /SOP

大多数集群管理操作都需要使用到管理节点上的管理用户，并在Pigsty根目录执行相应Ansible Playbook。

以下示例如无特殊说明，均以沙箱环境三节点集群`pg-test`作为演示对象。



## 操作命令速查表

### 集群实例管理

在管理节点上使用管理用户执行以下命令管理PostgreSQL集群与实例：

```bash
# 集群创建/集群扩容
./pgsql.yml -l pg-test            # 创建集群：在新机器上初始化 pg-test 集群
./pgsql.yml -l 10.10.10.13        # 添加实例（扩容），初始化 pg-test 集群 中的 10.10.10.13 节点

# 集群销毁/实例销毁
./pgsql-remove.yml -l pg-test     # 集群销毁：销毁 pg-test 集群，先销毁所有非主库实例，最后销毁主库实例
./pgsql-remove.yml -l 10.10.10.13 # 实例销毁（缩容）：销毁 pg-test 集群中的 10.10.10.13 节点

# 业务数据库/用户创建
./pgsql-createuser.yml -l pg-test -e pg_user=test     # 在 pg-test 集群创建名为 test 的用户
./pgsql-createdb.yml   -l pg-test -e pg_database=test # 在 pg-test 集群创建名为 test 的数据库

# 集群成员身份调整
./pgsql.yml -l pg-test -t pg_hba                         # 调整集群HBA规则并应用
./pgsql.yml -l pg-test -t haproxy_config,haproxy_reload  # 调整集群负载均衡器配置并应用

# 服务注册信息调整
./pgsql.yml -l pg-test -t register_prometheus       # 将集群作为监控目标注册至管理节点的Prometheus
./pgsql.yml -l pg-test -t register_grafana          # 将集群作为数据源注册至管理节点的Grafana
```

### Patroni数据库管理

Pigsty默认使用Patroni管理PostgreSQL实例数据库。这意味着，您需要使用`patronictl`命令来管理Postgres集群，包括：集群配置变更，重启，Failover，Switchover，重做特定实例，切换自动/手动高可用模式等。

用户可以使用`patronictl`在管理节点上以 `postgres`身份管理所有的数据库集群，亦可以在目标集群的任意实例上以 `postgres` 用户身份执行，别名`pt`已经在所有托管的机器上创建：`alias pt='patronictl -c /pg/bin/patroni.yml'`

常用的管理命令如下所示，更多命令请参考`pt --help`

```bash
pt list        [cluster]             # 打印集群信息
pt edit-config [cluster]             # 编辑某个集群的配置文件 

pt reload      [cluster] [instance]  # 重载某个集群或实例的配置
pt restart     [cluster] [instance]  # 重启某个集群或实例 
pt reinit      [cluster] [instance]  # 重置某个集群中的实例（重新制作从库）

pt pause       [cluster]             # 进入维护模式（不会触发自动故障切换，Patroni不再操作Postgres）
pt resume      [cluster]             # 退出维护模式

pt failover    [cluster]             # 手工触发某集群的Failover
pt switchover  [cluster]             # 手工触发某集群的Switchover
```

### 服务组件管理

在Pigsty的部署中，所有组件均由`systemd`管理；PostgreSQL除外，PostgreSQL由Patroni管理。

> 例外的例外：当 [`patroni_mode`](v-pg-provision.md#patroni_mode) 为 `remove` 时例外，Pigsty将直接使用`systemd`管理Postgres

```bash
systemctl stop patroni               # 关闭 Patroni & Postgres
systemctl stop pgbouncer             # 关闭 Pgbouncer 
systemctl stop pg_exporter           # 关闭 PG Exporter
systemctl stop pgbouncer_exporter    # 关闭 Pgbouncer Exporter
systemctl stop node_exporter         # 关闭 Node Exporter
systemctl stop haproxy               # 关闭 Haproxy
systemctl stop vip-manager           # 关闭 Vip-Manager
systemctl stop consul                # 关闭 Consul
systemctl stop postgres              # 关闭 Postgres （仅当 patroni_mode = remove 时使用）
```

以下组件可以通过 `systemctl reload` 重新加载配置

```bash
systemctl reload patroni             # 重载配置： Patroni
systemctl reload postgres            # 重载配置： Postgres （仅当 patroni_mode = remove 时使用）
systemctl reload pgbouncer           # 重载配置： Pgbouncer 
systemctl reload pg_exporter         # 重载配置： PG Exporter
systemctl reload pgbouncer_exporter  # 重载配置： Pgbouncer Exporter
systemctl reload haproxy             # 重载配置： Haproxy
systemctl reload vip-manager         # 重载配置： vip-manager
systemctl reload consul              # 重载配置： Consul
```

在管理节点上，还可以通过 `systemctl reload` 重新加载基础设施组件的配置：

```bash
systemctl reload nginx          # 重载配置： Nginx （更新Haproxy管理界面索引，以及外部访问域名）
systemctl reload prometheus     # 重载配置： Prometheus （更新预计算指标计算逻辑与告警规则）
systemctl reload alertmanager   # 重载配置： Alertmanager
systemctl reload grafana-server # 重载配置： Grafana
```

当Patroni管理Postgres时，请不要使用 `pg_ctl` 直接操作数据库集簇 （`/pg/data`）。

您可以通过`pt pause`进入维护模式后再对数据库进行手工管理。

### 重置特定组件

```bash
./infra.yml -t repo_upstream       # 重新在管理节点上添加上游repo
./infra.yml -t repo_download       # 重新在管理节点上下载软件包
./infra.yml -t nginx_home          # 重新生成Nginx首页内容
./infra.yml -t prometheus_config   # 重置Prometheus配置
./infra.yml -t grafana_provision   # 重置Grafana监控面板
```

```bash
./pgsql.yml -l pg-test -t=pgsql    # 完成数据库部署：数据库、监控、服务
./pgsql.yml -l pg-test -t=postgres # 完成数据库部署
./pgsql.yml -l pg-test -t=monitor  # 完成监控的部署
./pgsql.yml -l pg-test -t=service  # 完成负载均衡的部署，（Haproxy & VIP）
./pgsql.yml -l pg-test -t=register # 将服务注册至基础设施
./pgsql.yml -l pg-test -t=register # 将服务注册至基础设施
./pgsql.yml -l pg-test -t=consul   # 重置DCS服务器，需先将集群配置为维护模式
```



-----------------------



## Case 1：集群创建/扩容

集群创建/扩容使用剧本 [`pgsql.yml`](p-pgsql)，创建集群使用集群名作为执行对象，创建新实例/集群扩容则以集群中的单个实例作为执行对象。

### **集群初始化**

```bash
# 在新机器上初始化 pg-test 集群
./pgsql.yml -l pg-test
```

### 集群扩容

假设现在有测试集群`pg-test`，包含两实例`10.10.10.11`与`10.10.10.12`，现额外扩容一台`10.10.10.13`。

**修改配置**

首先需要修改配置清单（`pigsty.yml`或CMDB）中的相应配置。请一定注意集群中各实例的`pg_seq` **必须唯一**。

```yaml
pg-test:
  hosts:
    10.10.10.11: { pg_seq: 1, pg_role: primary }
    10.10.10.12: { pg_seq: 2, pg_role: replica }
    10.10.10.13: { pg_seq: 3, pg_role: replica, pg_offline_query: true } # 新势力
  vars: { pg_cluster: pg-test }
```

**执行变更**

然后，执行以下命令，完成集群成员的初始化

```bash
# 初始化 pg-test 集群 中的 10.10.10.13 节点
./pgsql.yml -l 10.10.10.13
```

**调整角色**

集群扩容会导致集群成员变化，请参考 [Case 8：集群角色调整](#case-8：集群角色调整) 将流量分发至新实例。



### 常见问题

#### 常见问题1：数据库与Consul已经存在，执行中止

Pigsty使用安全保险机制来避免误删运行中的数据库，请使用 [`pgsql-remove`](p-pgsql-remove) 剧本先完成数据库实例下线，再复用该节点。如需进行紧急覆盖式安装，可使用以下参数在安装过程中强制抹除运行中实例（危险！！！）




#### 常见问题2：数据库太大，等待从库上线超时

当扩容操作卡在 `Wait for postgres replica online` 这一步并中止时，通常是因为已有数据库实例太大，超过了Ansible的超时等待时间。如果报错中止，该实例仍然会继续在后台拉起从库实例，您可以使用 `pt list pg-test` 命令列出集群当前状态，当新从库的状态为`running`时，可以使用以下命令，从中止的地方继续执行Ansible Playbook：

```bash
./pgsql.yml -l 10.10.10.13 --start-at-task 'Wait for postgres replica online'
```

另一种方式是直接显式指定后续的任务：

```bash
./pgsql.yml -l 10.10.10.13 -t pg_hba,pg_patroni,pgbouncer,pg_user,pg_db,monitor,service,register
```

如果拉起新从库因某些意外而中止，请参考常见问题2。



#### 常见问题3：集群处于维护模式 ，从库没有自动拉起

解决方案1，使用`pt resume pg-test` 将集群配置为自动切换模式，再执行从库创建操作。

解决方案2，使用`pt reinit pg-test pg-test-3`，手动完成实例初始化。该命令也可以用于**重做集群中的现有实例**。



#### 偶见问题4：集群从库带有`clonefrom`标签，但因数据损坏不宜使用或拉取失败

找到问题机器，切换至`postgres`用户，修改 patroni 配置文件并重载生效

```bash
sudo su postgres
sed -ie 's/clonefrom: true/clonefrom: false/' /pg/bin/patroni.yml
sudo systemctl reload patroni
pt list -W # 查阅集群状态，确认故障实例没有clonefrom标签
```



#### 常见问题5：如何使用现有用户创建固定的管理员用户

系统默认使用 `dba` 作为管理员用户，该用户应当可以从管理机通过ssh免密码登陆远程数据库节点，并免密码执行sudo命令。

如果分配的机器默认没有该用户，但您有其他的管理用户（例如`vagrant`）可以ssh登陆远程节点并执行sudo，则可以执行以下命令，使用其他的用户登陆远程机器并自动创建标准的管理用户：

```bash
./pgsql.yml -t node_admin -l pg-test -e ansible_user=vagrant -k -K
SSH password:
BECOME password[defaults to SSH password]:
```

如果指定`-k|--ask-pass -K|--ask-become-pass` 参数，则在执行前应当输入该管理用户的SSH登陆密码与sudo密码。

执行完毕后，即可从管理节点上的管理用户（默认为`dba`） 登陆目标数据库机器，并执行其他剧本。





-----------------------






## Case 2：集群下线/缩容

集群销毁/缩容使用专用剧本 [`pgsql-remove`](p-pgsql-remove) ，针对集群使用时，将下线移除整个集群。

针对集群中的单个实例使用时，将从集群中移除该实例。

注意，直接移除集群主库将导致集群Failover，故逐个移除实例时，请先移除所有从库。

注意，`pgsql-remove`剧本不受 **安全保险** 参数影响，将直接移除数据库实例与集群，请谨慎使用！

### **集群销毁**

```bash
# 销毁 pg-test 集群：先销毁所有非主库实例，最后销毁主库实例
./pgsql-remove.yml -l pg-test

# 销毁集群时，一并移除数据目录与软件包
./pgsql-remove.yml -l pg-test -e rm_pgdata=true -e rm_pgpkgs=true
```

### 集群缩容

```bash
# 实例销毁（缩容）：销毁 pg-test 集群中的 10.10.10.13 节点
./pgsql-remove.yml -l 10.10.10.13 
```

**调整角色

注意：集群缩容会导致集群成员变化，缩容时，该实例健康检查为假，原本由该实例承载的流量将立刻转由其他成员承载。但您仍需参考参考 [Case 8：集群角色调整](#case-8：集群角色调整) 中的说明，将该下线实例从集群配置中彻底移除。

**下线Offline实例**

请注意在默认配置中，如果下线了 `pg_role = offline` 或 `pg_offline_query = true` 的实例，而集群中仅剩下  `primary` 实例。那么离线读取流量将没有实例可以承载。



-----------------------



## Case 3：集群配置变更/重启

### 集群配置修改

修改PostgreSQL集群配置需要通过 `pt edit-config <cluster>` 进行，特别是同步复制选项`synchronous_mode`，必须修改Patroni的配置项（`.synchronous_mode`），而非（`postgresql.parameters.synchronous_mode`等参数）。

配置保存后，无需重启的配置可以通过确认生效。

请注意，`pt edit-config`修改的参数为**集群参数**，单个实例范畴的配置参数（例如Patroni的Clonefrom标签等配置）需要直接修改Patroni配置文件（`/pg/bin/patroni.yml`）并`systemctl reload patroni`生效。

请注意，HBA规则由Pigsty自动创建，请不要使用Patroni来管理HBA规则。

### 集群重启

需要重启的配置则需要安排数据库重启。重启集群可以使用以下命令进行：

```bash
pt restart     [cluster] [instance]  # 重启某个集群或实例 
```

带有需重启生效的实例，在`pt list`中会显示 `pending restart` 记号。





-----------------------



## Case 4：集群业务用户创建

可以通过 [`pgsql-createuser.yml`](p-pgsql-createuser.md) 在已有的数据库中创建新的[业务用户](c-user.md)。

业务用户通常指生产环境中由软件程序所使用的用户，需要通过连接池访问数据库的用户**必须**通过这种方式管理。其它用户可以使用Pigsty创建与管理，亦可由用户自行维护管理。

```bash
# 在 pg-test 集群创建名为 test 的用户
./pgsql-createuser.yml -l pg-test -e pg_user=test
```

以上命令可以简写为：

```bash
bin/createuser pg-test test  # 在 pg-test 集群创建名为 test 的用户
```

如果需要同时创建业务用户与业务数据库，通常应当先创建业务用户。

如果数据库配置有OWNER，请先创建对应OWNER用户后再创建相应数据库。





-----------------------



## Case 5：集群业务数据库创建

可以通过 [`pgsql-createdb.yml`](p-pgsql-createdb.md)在已有的数据库集群中创建新的[业务数据库](c-database.md)。

业务数据库指代由用户创建并使用的数据库对象。如果您希望通过连接池访问该数据库，则必须使用Pigsty提供的剧本进行创建，以维持连接池中的配置与PostgreSQL保持一致。

```bash
# 在 pg-test 集群创建名为 test 的数据库
./pgsql-createdb.yml   -l pg-test -e pg_database=test
```

以上命令可以简写为：

```bash
bin/createdb   pg-test test  # 在 pg-test 集群创建名为 test 的数据库
```

如果数据库配置有OWNER，请先创建对应OWNER用户后再创建相应数据库。



**将新数据库注册为Grafana数据源**

执行以下命令，会将`pg-test`集群中所有实例上所有的业务数据库作为 PostgreSQL 数据源注册入Grafana，供PGCAT应用使用。

```bash
./pgsql.yml -t register_grafana -l pg-test
```



-----------------------





## Case 6：集群HBA规则调整

用户可以通过 [`pgsql.yml`](p-pgsql.md) 的 `pg_hba` 子任务，调整现有的数据库集群/实例的HBA配置。

当集群发生Failover，Switchover，以及HBA规则调整时，应当重新执行此任务，将集群的IP黑白名单规则调整至期待的行为。

Pigsty强烈建议使用配置文件自动管理HBA规则，除非您清楚的知道自己在做什么。

HBA配置由 [`pg_hba_rules`](v-pg-template#pg_hba_rules) 与 [`pg_hba_rules_extra`](v-pg-template#pg_hba_rules_extra) 合并生成，两者都是由规则配置对象组成的数组。样例如下：

```yaml
- title: allow internal infra service direct access
  role: common
  rules:
    - host putong-confluence     dbuser_confluence     10.0.0.0/8  md5
    - host putong-jira           dbuser_jira           10.0.0.0/8  md5
    - host putong-newjira        dbuser_newjira        10.0.0.0/8  md5
    - host putong-gitlab         dbuser_gitlab         10.0.0.0/8  md5
```

执行以下命令，将重新生成HBA规则，并应用生效。

```bash
./pgsql.yml -t pg_hba -l pg-test
```

以上命令可以简写为：

```bash
bin/reloadhba pg-test
```



-----------------------





## Case 7：集群流量控制

Pigsty中PostgreSQL的集群流量默认由HAProxy控制，用户可以直接通过HAProxy提供的WebUI控制集群流量。



**使用HAProxy Admin UI控制流量**

Pigsty的HAProxy默认在9101端口（[`haproxy_exporter_port`](v-service#haproxy_exporter_port)）提供了管理UI，该管理UI默认可以通过Pigsty的默认域名后缀以实例名（`pg_cluster-pg_seq`）访问。管理界面带有可选的认证选项，由参数（[`haproxy_admin_auth_enabled`](v-service#haproxy_admin_auth_enabled)）启用。管理界面认证默认不启用，启用时则需要使用由 [`haproxy_admin_username`](v-service#haproxy_admin_username) 与 [`haproxy_admin_password`](v-service#haproxy_admin_password)的用户名与密码登陆。

使用浏览器访问 `http://pigsty/<ins>`（该域名因配置而变化，亦可从PGSQL Cluster Dashboard中点击前往），即可访问对应实例上的负载均衡器管理界面。[样例界面](http://home.pigsty.cc/pg-meta-1/)

您可以在这里对每集群众一个[服务](c-service)，以及每一个后端服务器的流量进行控制。例如要将相应的Server排干，则可以选中该Server，设置 `MAINT` 状态并应用。如果您同时使用了多个HAProxy进行负载均衡，则需要依次在每一个负载均衡器上执行此动作。



**修改集群配置**

当集群发生成员变更时，您应当在合适的时候调整集群中所有成员的负载均衡配置，以如实反映集群架构变化，例如当发生主从切换后。

此外通过配置 [`pg_weight`](v-service.md#pg_weight) 参数，您可以显式地控制集群中各实例承担的负载比例，该变更需要重新生成集群中HAProxy的配置文件，并reload重载生效。例如，此配置将2号实例在所有服务中的相对权重从默认的100降为0

```
10.10.10.11: { pg_seq: 1, pg_role: primary}
10.10.10.12: { pg_seq: 2, pg_role: replica, pg_weight: 0 }
10.10.10.13: { pg_seq: 3, pg_role: replica,  }
```

使用以下命令调整集群配置并生效。

```bash
./pgsql.yml -l pg-test -t haproxy_config  # 重新生成 pg-test 的HAProxy配置（但没有应用）
./pgsql.yml -l pg-test -t haproxy_reload  # 重新加载 pg-test 的HAProxy配置并启用生效
```

配置与生效命令可以合并简写为：

```
bin/reloadha pg-test
```





-----------------------



## Case 8：集群角色调整

这里介绍Pigsty默认使用的HAProxy接入方式，如果您使用L4 VIP或其它方式接入，则可能与此不同。

当集群发生任何形式的角色变更，即配置清单中集群与实例的 `pg_role` 参数无法真实反映服务器状态时，便需要进行此项调整。

例如，集群缩容后，集群负载均衡会根据健康检查**立刻重新分配流量**，但**不会移除下线实例的配置项**。

集群扩容后，**已有实例的负载均衡器配置不会变化**。即，您可以通过新实例上的HAProxy访问已有集群的所有成员，但旧实例上的HAProxy配置不变，因此不会将流量分发至新实例上。



**1. 修改配置文件 pg_role**

当集群发生了主从切换时，应当按照当前实际情况，调整集群成员的`pg_role`。例如，当`pg-test`发生了Failover或Switchover，导致`pg-test-3`实例变为新的集群领导者，则应当修改 `pg-test-3` 的角色为 `primary`，并将原主库 `pg_role` 配置为 `replica`。同时，您应当确保集群中至少存在一个实例能用于提供Offline服务，故为`pg-test-1`配置实例参数：`pg_offline_query: true`。

```yaml
10.10.10.11: { pg_seq: 1, pg_role: replica, pg_offline_query: true }
10.10.10.12: { pg_seq: 2, pg_role: replica }
10.10.10.13: { pg_seq: 3, pg_role: primary }
```

**2. 调整集群实例HBA**

当集群角色发生变化时，适用于不同角色的HBA规则也应当重新调整。

使用 [Case 6：集群HBA规则调整](#case-6：集群HBA规则调整) 中介绍的方法，调整集群HBA规则

**3. 调整集群负载均衡配置**

HAProxy会根据集群中Patroni返回的健康检查结果来动态分发请求流量，因此节点故障并不会影响外部请求。但用户应当在合适的时间（比如早上睡醒后），调整集群负载均衡配置。例如：将故障彻底从集群配置中剔除，而不是以健康检查DOWN的状态继续僵死在集群中。

使用 [Case 7：集群流量控制](#case-7：集群流量控制) 中介绍的方法，调整集群负载均衡配置。

**4.整合操作**

您可以在修改配置后，使用以下命令，完成集群角色的调整。

```bash
./pgsql.yml -l pg-test -t pg_hba,haproxy_config,haproxy_reload
```

或使用等价的简写脚本

```bash
bin/reloadhba pg-test # 调整集群HBA配置
bin/reloadha  pg-test # 调整集群HAProxy配置
```





-----------------------





## Case 9：监控对象调整

Pigsty默认使用静态文件服务发现的方式管理 Prometheus 监控对象，默认位置：`/etc/prometheus/targets`。

使用 Consul 服务发现是可选项，在此模式下，通常无需手工管理监控对象。使用静态文件服务发现时，在执行实例上线下线时，所有的监控对象都会一并自动处理：注册或注销。但仍然有一些特殊的场景无法覆盖周全（例如修改集群名称）。

**手动添加Prometheus监控对象**

```bash
# 将 pg-test 集群所有成员注册为 prometheus 监控对象
./pgsql.yml -t register_prometheus -l pg-test
```

PostgreSQL的服务发现对象定义默认存储于所有管理节点的 `/etc/prometheus/targets/pgsql` 目录中：每一个实例对应一个yml文件，包含目标的标签，与Exporter暴露的端口。

```yaml
# pg-meta-1 [primary] @ 172.21.0.11
- labels: { cls: pg-meta, ins: pg-meta-1 }
  targets: [172.21.0.11:9630, 172.21.0.11:9100, 172.21.0.11:9631, 172.21.0.11:9101]
```

**手工移除Prometheus监控对象**

```bash
# 移除监控对象文件
rm -rf /etc/prometheus/targets/pgsql/pg-test-*.yml
```

**手工添加Grafana数据源**

```bash
# 将 pg-test 集群中的每一个数据库对象，注册为 grafana 的数据源
./pgsql.yml -t register_grafana -l pg-test
```

**手工移除Grafana数据源**

在Grafana中点击数据源管理，手工删除即可。





-----------------------





## Case 10：集群主从切换

例如，想要在三节点演示集群 `pg-test` 上执行Failover，则可以执行以下命令：

```
pt failover <cluster>
```

然后按照向导提示，执行Failover即可，集群Failover后，应当参考 [Case 8：集群角色调整](#case-8：集群角色调整) 中的说明，修正集群角色。



<details>
<summary>执行Failover的操作记录</summary>


```bash
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



-----------------------





## Case 11：重置组件

> 俗话说，重启可以解决90%的问题，而重装可以解决剩下的10%。

面对疑难杂症，重置问题组件是一种简单有效的止损手段。使用Pigsty的初始化剧本 [`infra.yml`](p-infra) 与 [`pgsql.yml `](p-pgsql)可以重置基础设施与数据库集群，但通常我们只需要使用特定的子任务来重置特定组件即可。

### 基础设施重置

常用的基础设施重新配置命令包括：

```bash
./infra.yml -t repo_upstream       # 重新在管理节点上添加上游repo
./infra.yml -t repo_download       # 重新在管理节点上下载软件包
./infra.yml -t nginx_home          # 重新生成Nginx首页内容
./infra.yml -t prometheus_config   # 重置Prometheus配置
./infra.yml -t grafana_provision   # 重置Grafana监控面板
```

您也可以强行重新安装这些组件

```bash
./infra.yml -t nginx      # 重新配置Nginx
./infra.yml -t prometheus # 重新配置Prometheus
./infra.yml -t grafana    # 重新配置Grafana
./infra.yml -t jupyter    # 重置Jupyterlab
./infra.yml -t pgweb      # 重置PGWeb
```

此外，您可以以下命令使用重置数据库节点上的具体组件

```bash
# 较为常用，安全的重置命令，重装监控与重新注册不会影响服务
./pgsql.yml -l pg-test -t=monitor  # 重新部署监控
./pgsql.yml -l pg-test -t=register # 重新将服务注册至基础设施（Nginx, Prometheus, Grafana, CMDB...）
./pgsql.yml -l pg-test -t=consul -e dcs_exists_action=clean # 在维护模式下重置DCS Agent

# 略有风险的重置操作
./pgsql.yml -l pg-test -t=service    # 重新部署负载均衡，可能导致服务闪断
./pgsql.yml -l pg-test -t=pgbouncer  # 重新部署连接池，可能导致服务闪断

# 非常危险的重置任务
./pgsql.yml -l pg-test -t=consul   # 当高可用自动切换模式启用时，直接重置DCS服务器
./pgsql.yml -l pg-test -t=postgres # 重置数据库（包括Patroni，Postgres，Pgbouncer）
./pgsql.yml -l pg-test -t=pgsql    # 重新完成完整的数据库部署：数据库、监控、服务
```

例如，如果集群的连接池出现问题，一种兜底的止损方式便是重启或重装Pgbouncer连接池。

```bash
./pgsql.yml -l pg-test -t=pgbouncer # 重装连接池（所有用户与DB会重新生成），手工修改的配置会丢失
```





-----------------------





## Case 12：替换集群DCS服务器

DCS（Consul/Etcd）本身是非常可靠的服务，一旦出现问题，其影响也是非常显著的。

按照Patroni的工作逻辑，一旦集群主库发现DCS服务器不可达，会立即遵循Fencing逻辑，将自身降级为普通从库，无法写入。



### **维护模式**

除非当前集群处于“维护模式”（使用`pt pause <cluster>`进入，使用`pg resume <cluster>`退出）

```bash
# 使目标集群进入维护模式
pt pause pg-test

# 将目标集群恢复为自动故障切换模式（可选）
pt resume pg-test
```



### **重置数据库节点的DCS服务**

当DCS故障不可用，需要迁移至新的DCS（Consul）集群时，可以采用以下操作。

首先创建新DCS集群，然后编辑配置清单 [`dcs_servers`](v-dcs#dcs_servers) 填入新DCS Servers的地址。

```bash
# 强制重置目标集群上的Consul Agent（因为HA处于维护模式，不会影响新数据库集群）
./pgsql.yml -l pg-test -t consul -e dcs_exists_action=clean

```

当Patroni完成重启后（维护模式中，Patroni重启不会导致Postgres关停），会将集群元数据KV写入新的Consul集群中，所以必须确保原主库上的Patroni服务首先完成重启。

```bash
# 重要！首先重启目标集群主库的Patroni，然后重启其余从库的Patroni
ansible pg-test-1 'sudo systemctl restart patroni'
ansible pg-test-2,pg-test-3 'sudo systemctl restart patroni'
```





