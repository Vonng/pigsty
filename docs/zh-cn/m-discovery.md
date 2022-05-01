# 服务发现

服务发现有多种用途，本文介绍Pigsty监控系统Prometheus用于发现监控对象的机制。

服务发现的基础是**身份标识**，关于身份标识详情，请参阅[**实体**](c-pgsql.md#实体模型)一节

有了身份标识后，还需要在监控系统中将**监控目标**与身份标识相关联，Pigsty提供了两种实现方式：

* [静态文件服务发现](静态文件服务发现)：使用自动维护的配置文件（默认）
* [Consul服务发现](Consul服务发现)：使用自动维护的Consul服务注册信息

静态文件是默认的服务发现机制，在v1.0.0以前，Consul是默认的服务发现方式，可以通过参数配置发现机制。



## 身份参数

所有的实例都具有**身份（Identity）**，**身份标识**（Identifier）是与实例关联的**元数据**，用于标识实例。

[**身份参数**](v-config.md#身份参数)是任何集群与实例都必须定义的唯一标识符。

| 名称 |     变量      | 缩写   | 类型             | 说明                                          |
| :--: | :-----------: | ------ | ---------------- | --------------------------------------------- |
| 集群 | `pg_cluster`  | `cls`  | **核心身份参数** | 集群名称，集群内资源的顶层命名空间            |
| 角色 |   `pg_role`   | `role` | **核心身份参数** | 实例角色，`primary`, `replica`, `offline`,... |
| 标号 |   `pg_seq`    | `seq`  | **核心身份参数** | 实例序号，正整数，集群内唯一。                |
| 实例 | `pg_instance` | `ins`  | 衍生身份参数     | `${pg_cluster}-${pg_seq}`                     |
| 服务 | `pg_service`  | `svc`  | 衍生身份参数     | `${pg_cluster}-${pg_role}`                    |

![](../_media/LABELS.svg)



## 身份关联

为系统中的对象命名后，还需要将 **身份信息** 关联至具体的实例上。

身份信息属于业务赋予的元数据，数据库实例本身不会意识到这些身份信息，它不知道自己为谁而服务，从属于哪个业务，或者自己是集群中的几号实例。

身份赋予可以有多种形式，最朴素的身份关联方式就是**运维人员的记忆**：DBA在脑海中记住了IP地址为`10.2.3.4`上的数据库实例，是用于支付的实例，而另一台上的数据库实例则用于用户管理。更好的管理方式是通过**配置文件**，或者采用**服务发现**的方式来管理集群成员的身份。

Pigsty同时提供这两种身份管理的方式：基于[**Consul**](#consul服务发现)的服务发现，与基于[**配置文件**](#静态文件服务发现)的服务发现

参数 [`prometheus_sd_method`](v-infra.md#prometheus_sd_method) 控制这一行为：

- `consul`：基于Consul进行服务发现，默认配置
- `static`：基于本地配置文件进行服务发现

Pigsty建议使用`static`服务发现，此方式更为简洁，且监控系统无需依赖Consul，具有更强的可靠性。



## 静态文件服务发现

静态文件服务发现是默认的监控对象发现方式，Pigsty默认使用以下配置拉取配置。

```yaml
#------------------------------------------------------------------------------
# job: pgsql (database monitoring)
# node_exporter | pg_exporter | pgbouncer_exporter | haproxy(exporter)
# labels: [cls, ins, instance]
# path: targets/pgsql/*.yml
#------------------------------------------------------------------------------
- job_name: pgsql
  metrics_path: /metrics
  file_sd_configs:
    - refresh_interval: 10s
      files: [ /etc/prometheus/targets/pgsql/*.yml ]
```

在`/etc/prometheus/targets`目录下存放有由Pigsty生成的监控对象定义文件，`pgsql`是默认环境的名称。

**每一个实例由一个单独的文件定义**，形如：

```
/etc/prometheus/targets/pgsql
                     ^-----pg-meta-1.yml
                     ^-----pg-test-1.yml
                     ^-----pg-test-2.yml
                     ^-----pg-test-3.yml
```

其内容为单个实例节点上的**身份标识**，与**监控对象**。

```bash
# pg-meta-1 [primary] @ 10.10.10.10
- labels: { cls: pg-meta, ins: pg-meta-1 }
  targets: [10.10.10.10:9630, 10.10.10.10:9100, 10.10.10.10:9631, 10.10.10.10:9101]
```

静态文件服务发现的优点是没有额外的组件依赖，而且允许人工介入进行管理与调整，亦便于与第三方系统相互集成。

### 维护文件服务发现

使用静态文件服务发现时，所有集群扩容、缩容操作都会自动维护这些配置文件。

使用以下命令，将为环境中所有实例重新生成配置文件

```bash
./pgsql.yml -t register_prometheus
```


### 默认采集对象
每一个被管理的Postgres实例都包括有几个采集端口：
* 采集机器节点指标的 [Node Exporter](https://github.com/prometheus/node_exporter)
* 采集数据库指标的 [PG Exporter](https://github.com/Vonng/pg_exporter)
* 采集连接池指标的 [PGBouncer Exporter](https://github.com/Vonng/pg_exporter) （与PG Exporter使用同一二进制）
* 采集高可用组件的 [Patroni](https://patroni.readthedocs.io/en/latest/releases.html?highlight=%2Fmetrics#version-2-1-3)
* 采集负载均衡器指标的 [HAProxy](https://github.com/Vonng/haproxy-rpm) （内建支持，无需单独部署）

![](../_media/playbook/nodes.svg)

这些采集端口会被[元节点](c-nodes.md#元节点)上的Prometheus所采集。
此外，可选的Promtail用于收集Postgres，Patroni，Pgbouncer日志，是可选的额外安装组件。

默认情况下，所有监控端点都会被注册至Consul，但Prometheus默认会通过静态文件服务发现的方式管理这些任务。
用户可以通过配置 [`prometheus_sd_method`](v-infra.md#prometheus_sd_method) 为 `consul` 来使用Consul服务发现，动态管理实例。




## Consul服务发现

Pigsty内置了基于DCS的配置管理与自动服务发现，用户可以直观地察看系统中的所有节点与服务信息，以及健康状态。Pigsty中的所有服务都会自动注册至DCS中，因此创建、销毁、修改数据库集群时，元数据会自动修正，监控系统能够自动发现监控目标，无需手动维护配置。

用户亦可通过Consul提供的DNS与服务发现机制，实现基于DNS的自动流量切换。

Consul采用了Client/Server架构，整个环境中存在1～5个不等的Consul Server，用于实际的元数据存储。所有节点上都部署有Consul Agent，代理本机服务与Consul Server的通信。Pigsty默认通过本地Consul配置文件的方式注册服务。

### 服务注册

在每个节点上，都运行有 consul agent。服务通过JSON配置文件的方式，由consul agent注册至DCS中。

JSON配置文件的默认位置是`/etc/consul.d/`，采用`svc-<service>.json`的命名规则，以`postgres`为例：

```json
{
  "service": {
    "name": "postgres",
    "port": 5432,
    "tags": [
      "pgsql",
      "primary",
      "pg-meta"
    ],
    "meta": {
      "type": "postgres",
      "role": "primary",
      "seq": "1",
      "instance": "pg-meta-1",
      "service": "pg-meta-primary",
      "cluster": "pg-meta",
      "version": "13"
    },
    "check": {
      "args": ["/usr/pgsql/bin/pg_isready", "-p", "5432", "-U", "dbuser_monitor"],
      "interval": "15s",
      "timeout": "1s"
    }
  }
}
```

其中`meta`与`tags`部分是服务的元数据，存储有实例的**身份信息**。

### 服务查询

用户可以通过Consul提供的DNS服务，或者直接调用Consul API发现**注册到Consul中的服务**

使用DNS API查阅consul服务的方式，请参阅[Consul文档](https://www.consul.io/docs/discovery/dns)。

### 服务发现

Prometheus会自动通过`consul_sd_configs`发现环境中的监控对象。同时带有`pg`和`exporter`标签的服务会自动被识别为抓取对象：

```yaml
- job_name: pg
  # https://prometheus.io/docs/prometheus/latest/configuration/configuration/#consul_sd_config
  consul_sd_configs:
    - server: localhost:8500
      refresh_interval: 5s
      tags:
        - pg
        - exporter
```

> **图：被Prometheus发现的服务**，身份信息已关联至实例的指标维度上。

### 服务维护

有时候，因为数据库主从发生切换，导致注册的角色与数据库实例的实际角色出现偏差。这时候需要通过反熵过程处理这种异常。基于Patroni的故障切换可以正常地通过回调逻辑修正注册的角色，但人工完成的角色切换则需要人工介入处理。使用以下脚本可以自动检测并修复数据库的服务注册。建议在数据库实例上配置Crontab，或在元节点上设置定期巡检任务。

```bash
/pg/bin/pg-register $(pg-role)
```





## 标签

无论是通过Consul服务发现，还是静态文件服务发现。最终的效果是实现**身份信息**与**实例监控指标**相互关联。

这一关联，是通过监控指标的**维度标签**实现的，并不是所有指标都具有以下标签。

但Pigsty中所有数据库集群相关的原始监控指标必定具有`cls`与`ins`两个标签，并在整个生命周期中保持不变。

|   身份参数    | 维度标签 |     取值样例      |
| :-----------: | :------: | :---------------: |
| `pg_cluster`  |  `cls`   |     `pg-test`     |
| `pg_instance` |  `ins`   |    `pg-test-1`    |
| `pg_services` |  `svc`   | `pg-test-primary` |
|   `pg_role`   |  `role`  |     `primary`     |
|   `node_ip`   |   `ip`   |   `10.10.10.11`   |



阅读下一节 [**监控指标**](m-metric.md) ，了解这些指标是如何通过标签组织起来的。

