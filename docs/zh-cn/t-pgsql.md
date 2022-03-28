# Citus部署

https://docs.citusdata.com/en/latest/installation/multi_node_rhel.html

```bash
sudo su - postgres
psql meta 

SELECT * from citus_add_node('10.10.10.11', 5432);
SELECT * from citus_add_node('10.10.10.12', 5432);
SELECT * from citus_add_node('10.10.10.13', 5432);
SELECT * FROM citus_get_active_worker_nodes();
```

```bash
SELECT * FROM citus_get_active_worker_nodes();
  node_name  | node_port
-------------+-----------
 10.10.10.11 |      5432
 10.10.10.13 |      5432
 10.10.10.12 |      5432
(3 rows)
```

```sql
-- declaratively partitioned table
CREATE TABLE github_events
(
    event_id     bigint,
    event_type   text,
    event_public boolean,
    repo_id      bigint,
    payload      jsonb,
    repo         jsonb,
    actor        jsonb,
    org          jsonb,
    created_at   timestamp
) PARTITION BY RANGE (created_at);

SELECT create_distributed_table('github_events', 'repo_id');

SELECT create_time_partitions(
               table_name := 'github_events',
               partition_interval := '1 month',
               end_at := now() + '12 months'
           );

SELECT partition
FROM time_partitions
WHERE parent_table = 'github_events'::regclass;

```


并修改 [Patroni模板](v-customize-patroni.md) 中 `max_prepared_transaction` 参数为一个合适的值（大于等于`max_connections`的值）

详情请参考Citus部署样例配置文件： [pigsty-citus.yml](https://github.com/Vonng/pigsty/blob/master/files/conf/pigsty-citus.yml)