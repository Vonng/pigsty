# Metrics

>  **Metric** is the core concept of Pigsty's monitor system.



## Format

**Metrics** are formally cumulative, atomic logical units of measure that can be updated and statistically aggregated over periods.

Metrics typically exist as **time series with dimension labels**. For example, `pg:ins:qps_realtime` in the Pigsty sandbox refers to the presentation of **real-time QPS** for all instances.

```json
pg:ins:xact_commit_rate1m{cls="pg-meta", ins="pg-meta-1", ip="10.10.10.10", role="primary"} 0
pg:ins:xact_commit_rate1m{cls="pg-test", ins="pg-test-1", ip="10.10.10.11", role="primary"} 327.6
pg:ins:xact_commit_rate1m{cls="pg-test", ins="pg-test-2", ip="10.10.10.12", role="replica"} 517.0
pg:ins:xact_commit_rate1m{cls="pg-test", ins="pg-test-3", ip="10.10.10.13", role="replica"} 0
```


Users can perform **operations** on **indicators**: summation, derivation, aggregation, etc. 

```sql
$ sum(pg:ins:xact_commit_rate1m) by (cls)        -- Query real-time instance QPS aggregated by cluster
{cls="pg-meta"} 0
{cls="pg-test"} 844.6

$ avg(pg:ins:xact_commit_rate1m) by (cls)        -- Query the average real-time instance QPS of all instances in each cluster
{cls="pg-meta"} 0
{cls="pg-test"} 280

$ avg_over_time(pg:ins:qps_realtime[30m])        -- Average QPS of instances in the last 30 minutes
pg:ins:qps_realtime{cls="pg-meta", ins="pg-meta-1", ip="10.10.10.10", role="primary"} 0
pg:ins:qps_realtime{cls="pg-test", ins="pg-test-1", ip="10.10.10.11", role="primary"} 130
pg:ins:qps_realtime{cls="pg-test", ins="pg-test-2", ip="10.10.10.12", role="replica"} 100
pg:ins:qps_realtime{cls="pg-test", ins="pg-test-3", ip="10.10.10.13", role="replica"} 0
```



## Model

Each **Metric** **class** of data usually corresponds to multiple **time series**. **Dimensions** distinguish different time series corresponding to the same metric.

Metrics + dimension, which can precisely locate a time series. Each **time series** is an array of (timestamp, fetch) binaries.

Pigsty uses Prometheus' metrics model, whose logical concept can be represented by the following SQL DDL.


```sql
-- Metrics Table,  Metric:TimeSeries = 1:n
CREATE TABLE metrics (
    id   INT PRIMARY KEY,         -- Metrics ID
    name TEXT UNIQUE              -- Metrics Name，[...and other metadata such as type]
);

-- Time Series Table, where each time series corresponds to a metric.
CREATE TABLE series (
    id        BIGINT PRIMARY KEY,               -- Time Series ID 
    metric_id INTEGER REFERENCES metrics (id),  -- MetricID which the time series belonged, refer metrics(id)
    dimension JSONB DEFAULT '{}'                -- Dimension information in the form of k-v pair
);

-- Time Series Data table that holds the final sampled data points. 
-- Each sampled point belongs to a time series 
CREATE TABLE series_data (
    series_id BIGINT REFERENCES series(id),     -- Time Series ID, refer series(id)
    ts        TIMESTAMP,                        -- Timestamp of the data point
    value     FLOAT,                            -- value of the data point
    PRIMARY KEY (series_id, ts)                 -- each data point can be identified by time series id and timestamp
);
```

Take `pg:ins:qps` as an example：

```sql
-- Sample metric data
INSERT INTO metrics VALUES(1, 'pg:ins:qps');  -- It's a metric named pg:ins:qps, type GAUGE
INSERT INTO series VALUES                     -- The metrics contains 4 time-series, distinguished by dimension labels
(1001, 1, '{"cls": "pg-meta", "ins": "pg-meta-1", "role": "primary", "other": "..."}'),
(1002, 1, '{"cls": "pg-test", "ins": "pg-test-1", "role": "primary", "other": "..."}'),
(1003, 1, '{"cls": "pg-test", "ins": "pg-test-2", "role": "replica", "other": "..."}'),
(1004, 1, '{"cls": "pg-test", "ins": "pg-test-3", "role": "replica", "other": "..."}');
INSERT INTO series_data VALUES                 -- The underneath sampling data point
(1001, now(), 1000),                           -- instance pg-meta-1 qps 1000 at this moment
(1002, now(), 1000),                           -- instance pg-test-1 qps 1000 at this moment
(1003, now(), 5000),                           -- instance pg-test-2 qps 5000 at this moment
(1004, now(), 5001);                           -- instance pg-test-3 qps 5000 at this moment
```

* `pg_up` is a metric with 4-time series, representing the aliveness status of all instances in the sandbox.
* `pg_up{ins": "pg-test-1", ...}` is a time series which represent aliveness of the specific instance `pg-test-1`.





## Sources

Pigsty has four primary sources of monitor data: **database**, **connection pool**, **OS**, and **LB**. Exposed to the public via the corresponding exporter.

![](![](/_media/metrics_source.png))


Full sources include.

* PostgreSQL's monitoring metrics
* Statistical metrics from the PostgreSQL logs
* PostgreSQL system directory information
* Metrics from Pgbouncer connection pool median price
* PgExporter metrics
* Metrics of the database working node Node
* LB Haproxy metrics
* DCS (Consul) working metrics
* Monitor system working metrics: Grafana, Prometheus, Nginx
* Blackbox probing metrics (TBD)

Please refer to the [**Reference - Metrics List**](#merics) section for a complete list of available metrics.



## Numbers

Among the database metrics, there are about 230 original metrics related to Postgres and about 50 original metrics related to middleware. Pigsty then designs about 350 DB-related derived metrics based on these actual metrics through hierarchical aggregation and precomputation.

Thus, there are 621 monitor metrics for each database cluster and its attachments for each database cluster. There are 281 machine primitive metrics and 83 derived metrics for a total of 364. Together with the 170 metrics for load balancers, Pigsty has close to 1200 classes of metrics.

Note that here we identify the difference between metric and time-series.
We use the term class rather than the individual. This is because a metric may correspond to many time series.

As of 2021, Pigsty's metrics coverage is one of the best among all open source/commercial monitor systems known to the authors. See **Cross-Sectional Comparison** for details.



## Hierarchy

Pigsty also produces **[Derived Metrics](#special-metric) based on existing metrics**.

For example, metrics can be aggregated at different levels.

| Entity       | Identifier    | Example                              | Label Keys                      |
| ------------ | ------------- | ------------------------------------ | ------------------------------- |
| Environment  | **`job`**     | `pgsql`, `redis`, `staging`          | `{job}`                         |
| Shard        |               | `pg-test-shard\d+`                   | `{job, cls*}`                   |
| **Cluster**  | **`cls`**     | `pg-meta`, `pg-test`                 | `{job, cls}`                    |
| Service      |               | `pg-meta-primary`, `pg-test-replica` | `{job, cls}`                    |
| **Instance** | **`ins`**     | `pg-meta-1`, `pg-test-1`             | `{job, cls, ins, ip, instance}` |
| Database     | **`datname`** | `test`                               | `{..., datname}`                |
| Object       |               | `public.pgbench_accounts`            | `{..., datname, <object>}`      |

Take the derived process of TPS metrics as an example.

The original data is the transaction counters captured from Pgbouncer. There are four instances in the cluster and two databases on each instance, so there are eight DB-level TPS metrics for one instance.

The following chart, which is a cross-sectional comparison of QPS for each instance within the entire cluster, uses predefined rules here to first obtain 8 DB-level TPS metrics by deriving the original transaction counters, then aggregating the 8 DB-level time series into four instance-level TPS metrics, and finally aggregating these four instance-level TPS metrics into cluster-level TPS metrics.

![](m-metric.assets/LABELS.svg)


Pigsty defines a total of 360 classes of derived aggregated metrics, with more to come. The rules for defining derived metrics are described in  [**Reference: Derived-Metrics**](#special-meric).



## Special Metric

The **catalog** is a special indicator.

The boundary between Catalog and Metrics distinction is blurred. For example, the number of pages and the number of tuples in a table, Catalog, or Metrics?

The main difference between Catalog and Metrics in practice is that the information in Catalog is infrequently changed, such as the definition of a table. It would be a waste to grab it once every few seconds like Metrics. So this type of information, which is more static, is classified as Catalog.

The catalog is mainly captured by timed tasks (e.g., Patrol), not Prometheus. Some essential Catalog information, such as some information in `pg_class`, is also converted to metrics and captured by Prometheus.

Pigsty provides the PGCAT series of monitoring panels to capture and present information directly from the Catalog of the target database.





## Summary

After understanding Pigsty metrics, it is helpful to know how Pigsty's [**alert system**](r-alert.md) uses these metrics data for practical production purposes.

