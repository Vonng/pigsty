# Postgres CSVLOG Analysis

尽管Pigsty提供了基于Loki的日志查询搜索分析，但有时候还是有需求对某一段时间的日志进行详细探索。
例如，使用SQL对pg日志进行过虑，分析，聚合，提取慢查询列表等。

pglog就是这样的一个datalet，将pg的CSV日志灌入 `pglog.sample` 中，即可在监控面板中自动对其进行分析。


```bash
make            # 安装datalet: 数据与面板
make reload     # 加载当天数据库日志作为分析样本
```