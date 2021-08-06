# 仅监控部署

> 如何将Pigsty与外部供给方案相集成，只使用Pigsty的监控系统部分。

如果用户只希望使用Pigsty的**监控系统**部分，比如希望使用Pigsty监控系统监控已有的PostgreSQL实例，那么可以使用 **仅监控部署（monitor only）** 模式。

### 仅监控模式的工作假设

Pigsty监控系统 如果要与外部供给方案配合，监控已有数据库集群，需要一些**工作假设**：

- 数据库采用**独占式部署**，与节点存在**一一对应**关系。只有这样，节点指标才能有意义地与数据库指标关联。
- 目标节点可以被Ansible管理（NOPASS SSH与NOPASS SUDO），一些云厂商RDS产品并不允许这样做。
- 数据库需要创建可用于访问监控指标的**监控用户**，安装必须的监控模式与扩展，并合理配置其访问控制权限。

### 仅监控模式的部署流程

仅监控模式的部署流程与标准模式大体上保持一致，但省略了很多步骤

- 在**元节点**上完成[**基础设施初始化**](p-infra.md)的部分，与标准流程**一致**。
- 修改配置文件，在仅监控模式中，通常只需要修改[监控系统](v-monitor.md)部分的参数。
- 执行 [`pgsql.yml`](p-pgsql) 的一个子集，单纯完成监控系统的部署。



## 部署说明

### 监控用户

Pigsty创建的数据库集群会在 [数据库部署](v-pg-provision) 阶段中创建用于监控的系统用户，仅监控模式跳过了这些步骤，因此用户需要**自行创建**用于监控的用户。

您需要手工在目标数据库集群中创建监控用户（默认为`dbuser_monitor`），以及监控相关的**模式**与**扩展**。并调整目标数据库集群的[访问控制](c-auth.md)机制，允许使用该用户连接至数据库并访问监控相关对象。创建监控对象的参考SQL语句如下：

```sql
-- 创建监控用户
CREATE USER dbuser_monitor;
ALTER ROLE dbuser_monitor PASSWORD 'DBUser.Monitor';
ALTER USER dbuser_monitor CONNECTION LIMIT 16;
GRANT pg_monitor TO dbuser_monitor;
    
-- 创建监控模式
CREATE SCHEMA IF NOT EXISTS monitor;
GRANT USAGE ON SCHEMA monitor TO dbuser_monitor;

-- 创建监控扩展
CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA monitor;
```

### 监控连接串

默认情况下，Pigsty会尝试使用以下规则生成数据库与连接池的连接串。

```bash
PG_EXPORTER_URL='postgres://{{ pg_monitor_username }}:{{ pg_monitor_password }}@:{{ pg_port }}/postgres?host={{ pg_localhost }}&sslmode=disable'
PGBOUNCER_EXPORTER_URL='postgres://{{ pg_monitor_username }}:{{ pg_monitor_password }}@:{{ pgbouncer_port }}/pgbouncer?host={{ pg_localhost }}&sslmode=disable'
```

如果用户使用的监控角色连接串无法通过该规则生成，则可以使用以下参数直接配置数据库与连接池的连接信息：

- [`pg_exporter_url`](v-monitor.md#pg_exporter_url)
- [`pgbouncer_exporter_url`](v-monitor.md#pgbouncer_exporter_url)

作为样例，沙箱环境中元节点连接至数据库的连接串为：

```bash
PG_EXPORTER_URL='postgres://dbuser_monitor:DBUser.Monitor@:5432/postgres?host=/var/run/postgresql&sslmode=disable'
```

> ### 懒人方案
>
> 如果不怎么关心安全性与权限，也可以直接使用dbsu ident认证的方式，例如`postgres`用户进行监控。
>
> `pg_exporter` 默认以 `dbsu` 的用户执行，如果允许`dbsu`通过本地`ident`认证免密访问数据库（Pigsty默认配置），则可以直接使用超级用户监控数据库。
>
> Pigsty**非常不推荐**这种部署方式，但它确实很方便，既不用创建新用户，也不用配置权限。
>
> ```bash
> PG_EXPORTER_URL='postgres:///postgres?host=/var/run/postgresql&sslmode=disable'
> ```



## 相关参数

使用**仅监控部署**时，只会用到Pigsty参数的一个子集。

#### 基础设施部分

基础设施与元节点仍然与常规部署保持一致，除了以下两个参数必须强制使用指定的配置选项。

```yml
service_registry: none            # 须关闭服务注册，因为目标环境可能没有DCS基础设施。
prometheus_sd_method: static      # 须使用静态文件服务发现，因为目标实例可能并没有使用服务发现与服务注册
```

#### 目标节点部分

目标节点的[身份参数](c-config.md#身份参数)仍然为必选项，因为这些参数定义了数据库实例在监控系统中的身份标识。

除此之外，通常只需要调整[监控系统参数](v-monitor)。


```yaml

#------------------------------------------------------------------------------
# MONITOR PROVISION
#------------------------------------------------------------------------------
# - install - #
exporter_install: none                        # none|yum|binary, none by default
exporter_repo_url: ''                         # if set, repo will be added to /etc/yum.repos.d/ before yum installation

# - collect - #
exporter_metrics_path: /metrics               # default metric path for pg related exporter

# - node exporter - #
node_exporter_enabled: true                   # setup node_exporter on instance
node_exporter_port: 9100                      # default port for node exporter
node_exporter_options: '--no-collector.softnet --no-collector.nvme --collector.ntp --collector.tcpstat --collector.processes'

# - pg exporter - #
pg_exporter_config: pg_exporter.yml           # default config files for pg_exporter
pg_exporter_enabled: true                     # setup pg_exporter on instance
pg_exporter_port: 9630                        # default port for pg exporter
pg_exporter_url: ''                           # optional, if not set, generate from reference parameters
pg_exporter_auto_discovery: true              # optional, discovery available database on target instance ?
pg_exporter_exclude_database: 'template0,template1,postgres' # optional, comma separated list of database that WILL NOT be monitored when auto-discovery enabled
pg_exporter_include_database: ''             # optional, comma separated list of database that WILL BE monitored when auto-discovery enabled, empty string will disable include mode
pg_exporter_options: '--log.level=info --log.format="logger:syslog?appname=pg_exporter&local=7"'

# - pgbouncer exporter - #
pgbouncer_exporter_enabled: true              # setup pgbouncer_exporter on instance (if you don't have pgbouncer, disable it)
pgbouncer_exporter_port: 9631                 # default port for pgbouncer exporter
pgbouncer_exporter_url: ''                    # optional, if not set, generate from reference parameters
pgbouncer_exporter_options: '--log.level=info --log.format="logger:syslog?appname=pgbouncer_exporter&local=7"'

# - promtail - #                              # promtail is a beta feature which requires manual deployment
promtail_enabled: true                        # enable promtail logging collector?
promtail_clean: false                         # remove promtail status file? false by default
promtail_port: 9080                           # default listen address for promtail
promtail_status_file: /tmp/promtail-status.yml
promtail_send_url: http://10.10.10.10:3100/loki/api/v1/push  # loki url to receive logs

```

通常来说，需要调整的参数包括：

```yaml
exporter_install: binary          # none|yum|binary 建议使用拷贝二进制的方式安装Exporter
pgbouncer_exporter_enabled: false # 如果目标实例没有关联的Pgbouncer实例，则需关闭Pgbouncer监控
pg_exporter_url: ''               # 连接至 Postgres  的URL，如果不采用默认的URL拼合规则，则可使用此参数
pgbouncer_exporter_url: ''        # 连接至 Pgbouncer 的URL，如果不采用默认的URL拼合规则，则可使用此参数
pg_exporter_auto_discovery: true              # optional, discovery available database on target instance ?
pg_exporter_exclude_database: 'template0,template1,postgres' # optional, comma separated list of database that WILL NOT be monitored when auto-discovery enabled
pg_exporter_include_database: ''             # optional, comma separated list of database that WILL BE monitored when auto-discovery enabled, empty string will disable include mode
```



## 执行部署

参数调整完毕后，在目标集群`<cluster>`上执行以下剧本，即可完成监控部署：

```bash
./pgsql.yml -t monitor -l <cluster>
```

!> 忘记使用 `-t` 指定`monitor`任务会执行数据库实例初始化，执行前请确保命令正确

监控组件部署完成后，您可以通过以下命令，将其注册至基础设施中：

```bash
./pgsql.yml -t register_prometheus,register_grafana -l <cluster>
```

`register_prometheus` 任务会将目标数据库实例加入到Prometheus的监控对象列表中，而`register_grafana`则会将集群中所有业务数据库作为数据源注册至Grafana。









## 局限性

Pigsty监控系统 与 Pigsty供给方案 配合紧密，原装的总是最好的。尽管Pigsty并不推荐拆分使用，但这样做确实是可行的，只是存在一些局限性。

### 指标缺失

Pigsty会集成多种[来源](m-metric.md#指标数量)的指标，包括机器节点，数据库，Pgbouncer连接池，Haproxy负载均衡器。如果用户自己的供给方案中缺少这些组件，则相应指标也会发生缺失。

通常Node与PG的监控指标总是存在，而PGbouncer与Haproxy的缺失通常会导致**100～200**个不等的指标损失。

特别是，Pgbouncer监控指标中包含极其重要的PG QPS，TPS，RT，而这些指标是**无法从PostgreSQL本身获取**的。

### 服务发现

外部供给方案通常拥有自己的身份管理机制，因此Pigsty不会越俎代庖地部署DCS用于**服务发现**。这意味着用户只能采用 **静态配置文件** 的方式管理监控对象的身份，通常这并不是一个问题，因为Pigsty v1.0.0默认使用基于静态文件的服务发现机制。

### 身份变更

在Pigsty沙箱中，当实例的角色身份发生变化时，系统会通过回调函数与反熵过程及时修正实例的角色信息，如将`primary`修改为`replica`，将其他角色修改为`primary`。

```json
pg_up{cls="pg-meta", ins="pg-meta-1", instance="10.10.10.10:9630", ip="10.10.10.10", job="pg"}
```

Pigsty的监控系统中不会使用与身份相关的标签（例如`svc`，`role`），因此时间序列的标签不会因为主从切换而变化。
如果您的外部系统，脚本，工具使用Consul服务注册中的角色信息（`service`，`role`），有必要关注自动主从切换导致的身份变化问题。

### 管理权限

Pigsty的监控指标依赖 `node_exporter` 与 `pg_exporter` 获取。

尽管`pg_exporter`可以采用exporter拉取远程数据库实例信息的方式部署，但`node_exporter`必须部署在数据库所属的节点上。

这意味着，用户必须拥有数据库所在机器的SSH登陆与`sudo`权限才能完成部署。该权限仅在部署时需要：目标节点必须可以被Ansible**纳入管理**，而云厂商RDS通常不会给出此类权限。
