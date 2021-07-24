## 监控面板

Pigsty由提供了专业且易用的PostgreSQL监控系统，浓缩了业界监控的最佳实践。

用户可以方便地进行修改与定制；复用监控基础设施，或与其他监控系统相集成。



## 监控应用

Pigsty监控面板由三个相对独立的应用组成：`PGSQL`，`PGCAT`，`PGLOG`。

| 应用    | 说明                             |
| ------- | -------------------------------- |
| `PGSQL` | 可视化监控指标，**时间序列**数据 |
| `PGCAT` | 呈现、分析系统目录元数据         |
| `PGLOG` | 呈现、分析**日志**数据           |



## 监控层次

监控面板有着自己的层次，自顶向下分别为：

* 全局：关注整个**环境**，大盘全局指标
* 集群：专注单个数据库集群的聚合指标
* 实例：专注单个实例对象：数据库实例，节点，负载均衡器，各类主题面板
* 数据库（对象）：数据库内的活动，表与查询的详细信息


|            全局             |             集群             |            实例             |           数据库            |
| :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
|        PGSQL Overview        |  PGSQL Cluster  | PGSQL Instance | PGSQL Database |
| PGSQL Alert | PGSQL Service | PGSQL Node | PGSQL Tables |
|  | PGSQL Activity | PGSQL Proxy | PGSQL Table |
|  | PGSQL Replication | PGSQL Xacts | PGSQL Query |
|  |  | PGSQL Queries |  |
|  |  |        PGSQL Session        |        |
|  |  | **PGLOG** | **PGCAT** |
|            |  |  PGLOG Instance  | PGCAT Table |
|  |  | PGLOG Analysis | PGCAT Query |
|  |  | PGLOG Session | PGCAT Bloat |

