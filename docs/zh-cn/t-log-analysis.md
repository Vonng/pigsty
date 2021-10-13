# PGLOG Analysis CSV日志分析

Pigsty提供了一个分析PG CSV日志样本（PG 13+）的实用应用。可用于精细分析故障现场日志，慢查询日志。

> PostgreSQL 13的CSV日志格式发生变化，添加了一个新的`backend_type`字段。如需查阅老版本的PostgreSQL CSV日志，请调整`pglog.sample`表定义（例如通过`ALTER TABLE DROP COLUMN`）



## 图形界面

您可以访问以下的连接，查看样例日志分析界面。

  * [PGLOG Analysis](http://demo.pigsty.cc/d/pglog-analysis):  呈现整份CSV日志样本详情，按多种维度聚合。
  * [PGLOG Session](http://demo.pigsty.cc/d/pglog-session):  呈现日志样本中一条具体连接详情。



## 使用方法

PGLOG固定使用MetaDB中`pglog.sample`表作为数据来源，您只需要将日志灌入该表，然后访问Dashboard即可。
Pigsty提供了一些趁手的命令，用于拉取csv日志，并灌入样本表中。



### pglog脚本

在Pigsty的`bin`目录下有一些以`pglog-`前缀的脚本：

**`pglog-cat`**

`pglog-cat` 会将特定机器特定日期的CSV日志打印到标准输出，第一个参数为机器IP，第二个参数为日期。缺省值为`127.0.0.1`与今天


**`pglog-sample`**

`pglog-sample` 会从标准输入读取CSV日志，并灌入`pglog.sample`表中，以便从Dashboard中分析。


**`pglog-summary`**

`pglog-summary`与`pglog-cat`类似 , 但它会拉取PG CSV日志，并使用Pgbadger进行分析，而不是打印至标准输出



## 方便的快捷命令

```bash
alias pglog="psql service=meta -AXtwc 'TRUNCATE pglog.sample; COPY pglog.sample FROM STDIN CSV;'" # useful alias
### default: get pgsql csvlog (localhost @ today) 
function catlog(){ # getlog <ip|host> <date:YYYY-MM-DD>
    local node=${1-'127.0.0.1'}
    local today=$(date '+%Y-%m-%d')
    local ds=${2-${today}}
    ssh -t "${node}" "sudo cat /pg/data/log/postgresql-${ds}.csv"
}
```

`catlog`命令从特定节点拉取特定日期的CSV数据库日志，写入`stdout`

默认情况下，`catlog`会拉取当前节点当日的日志，您可以通过参数指定节点与日期。

组合使用`pglog`与`catlog`，即可快速拉取数据库CSV日志进行分析。

```bash
catlog | pglog                       # 分析当前节点当日的日志
catlog node-1 '2021-07-15' | pglog   # 分析node-1在2021-07-15的csvlog
```


