## 实时日志收集

Pigsty提供了一个**可选**的实时日志收集方案，基于  [loki](https://grafana.com/oss/loki/) 与 [promtail](https://grafana.com/docs/loki/latest/clients/promtail/)


## 下载软件

通常情况下，用户并不需要操心软件的下载问题。只需要确保`files/bin`中有所需二进制即可。

在执行安装前，需要下载loki, promtail, logcli, loki-canary 这四个二进制程序。

使用离线安装包进行`./configure`时，相关二进制会自动提取，无需操心。

手工执行`bin/get_loki`则会从互联网下载二进制至`/tmp`目录，下载后的二进制程序需要放置在`files/bin/`目录中。



## 启用日志收集

为了启用日志收集功能，您需要执行以下两个剧本。

```bash
./meta-loki.yml         # 在管理节点上安装loki(日志服务器)
./pgsql-promtail.yml     # 在数据库节点上安装promtail (日志Agent)
```



## 查看日志

安装完成后，您可以通过 [PGLOG Instance](http://g.pigsty.cc/d/pglog-instance/pglog-instance?from=now-1h&to=now&var-ins=pg-meta-1&var-datname=grafana&var-ip=172.21.0.11&var-seq=1&var-cls=pg-meta&var-node=pg-meta-1&orgId=1&var-src=postgres) 监控面板查阅单个实例上 Postgres , Pgbouncer , Patroni 日志

