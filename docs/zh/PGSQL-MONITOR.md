# PostgreSQL 监控接入

> Pigsty监控系统架构概览，以及如何监控现存的 PostgreSQL 实例？

----------------

## 监控概览

Pigsty使用现代的可观测技术栈对 PostgreSQL 进行监控：

- 使用Grafana进行指标可视化和PostgreSQL数据源。
- 使用Prometheus来监控PostgreSQL / Pgbouncer / Patroni / HAProxy / Node的指标
- 使用Loki来记录PostgreSQL / Pgbouncer / Patroni / pgBackRest的日志
- Pigsty 提供了开箱即用的 Grafana [仪表盘](PGSQL-DASHBOARD)，展示与 PostgreSQL 有关的方方面面。 


----------------

## 监控指标

PostgreSQL 本身的监控指标完全由 pg_exporter 配置文件所定义：[`pg_exporter.yml`](https://github.com/Vonng/pigsty/blob/master/roles/pgsql/templates/pg_exporter.yml)

它将进一步由 Prometheus 记录规则和警报评估处理：[`files/prometheus/rules/pgsql.yml`](https://github.com/Vonng/pigsty/blob/master/files/prometheus/rules/pgsql.yml)

3个标签：`cls`、`ins`、`ip`将附加到所有指标和日志上，例如`{ cls: pg-meta, ins: pg-meta-1, ip: 10.10.10.10 }`


----------------

## 日志

与 PostgreSQL 有关的日志由 promtail 负责收集，并发送至 infra 节点上的 Loki 日志存储/查询服务。

- [`pg_log_dir`](PARAM#pg_log_dir) : postgres日志目录，默认为`/pg/log/postgres`
- [`pgbouncer_log_dir`](PARAM#pgbouncer_log_dir) : pgbouncer日志目录，默认为`/pg/log/pgbouncer`
- [`patroni_log_dir`](PARAM#patroni_log_dir) : patroni日志目录，默认为`/pg/log/patroni`
- [`pgbackrest_log_dir`](PARAM#pgbackrest_log_dir) : pgbackrest日志目录，默认为`/pg/log/pgbackrest`


----------------

## 目标管理

Prometheus的监控目标在 `/etc/prometheus/targets/pgsql/` 下的静态文件中定义，每个实例都有一个相应的文件。

以 `pg-meta-1` 为例：

```yaml
# pg-meta-1 [primary] @ 10.10.10.10
- labels: { cls: pg-meta, ins: pg-meta-1, ip: 10.10.10.10 }
  targets:
    - 10.10.10.10:9630    # <--- pg_exporter 用于PostgreSQL指标
    - 10.10.10.10:9631    # <--- pg_exporter 用于pgbouncer指标
    - 10.10.10.10:8008    # <--- patroni指标（未启用 API SSL 时）
```

当全局标志 [`patroni_ssl_enabled`](PARAM#patroni_ssl_enabled) 被设置时，patroni目标将被移动到单独的文件 `/etc/prometheus/targets/patroni/<ins>.yml`。 因为此时使用的是https抓取端点。

当使用 `bin/pgsql-rm` 或 `pgsql-rm.yml` 移除集群时，Prometheus监控目标将被移除。您也可以手动移除它，或使用playbook子任务：


```bash
bin/pgmon-rm <ins>      # 从所有infra节点中移除prometheus监控目标
```



----------------

## 监控现有PG

对于现有的PostgreSQL实例，例如RDS，或者不由Pigsty管理的自制PostgreSQL，如果您希望用Pigsty监控它们，需要进行一些额外的配置。


```
------ infra ------
|                 |
|   prometheus    |            v---- pg-foo-1 ----v
|       ^         |  metrics   |         ^        |
|   pg_exporter <-|------------|----  postgres    |
|   (port: 20001) |            | 10.10.10.10:5432 |
|       ^         |            ^------------------^
|       ^         |                      ^
|       ^         |            v---- pg-foo-2 ----v
|       ^         |  metrics   |         ^        |
|   pg_exporter <-|------------|----  postgres    |
|   (port: 20002) |            | 10.10.10.11:5433 |
-------------------            ^------------------^
```

**操作步骤**

1. 在目标上创建监控模式、用户和权限。
2. 在库存中声明集群。例如，假设我们想要监控“远端”的 `pg-meta` & `pg-test` 集群，名称为 `pg-foo` 和 `pg-bar`，我们可以在库存中声明它们如下：

```
yamlCopy code
infra:            # 代理、监控、警报等的infra集群..
  hosts: { 10.10.10.10: { infra_seq: 1 } }

  vars:           # 在组'infra'上为远程postgres RDS安装pg_exporter

    pg_exporters: # 在此列出所有远程实例，为k分配一个唯一的未使用的本地端口

      20001: { pg_cluster: pg-foo, pg_seq: 1, pg_host: 10.10.10.10 }

      20002: { pg_cluster: pg-bar, pg_seq: 1, pg_host: 10.10.10.11 , pg_port: 5432 }
      20003: { pg_cluster: pg-bar, pg_seq: 2, pg_host: 10.10.10.12 , pg_exporter_url: 'postgres://dbuser_monitor:DBUser.Monitor@10.10.10.12:5432/postgres?sslmode=disable'}
      20004: { pg_cluster: pg-bar, pg_seq: 3, pg_host: 10.10.10.13 , pg_monitor_username: dbuser_monitor, pg_monitor_password: DBUser.Monitor }
```

1. 对集群执行playbook：`bin/pgmon-add <clsname>`。

要删除远程集群的监控目标：

```
bashCopy code
bin/pgmon-rm <clsname>
```