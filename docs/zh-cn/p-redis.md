# 剧本：REDIS

> 使用REDIS系列[剧本](p-playbook.md)，定义并拉起 传统主从、集群、Sentinel模式的Redis数据库。

| 剧本 | 功能                                                         | 链接                                                         |
|--------|--------------------------------------------------------------| ------------------------------------------------------------ |
|  [`redis`](p-redis.md#redis)                        |        部署集群/主从/Sentinel模式的Redis数据库              |        [`src`](https://github.com/vonng/pigsty/blob/master/redis.yml)            |
|  [`redis-remove`](p-redis.md#redis-remove)          |        Redis集群/节点下线                                   |        [`src`](https://github.com/vonng/pigsty/blob/master/redis-remove.yml)     |


------------------

## `redis`

用于在节点上部署Redis集群，节点，实例。

```bash
./redis.yml -l <redis_cluster>
```

![](../_media/playbook/redis.svg)











------------------

## `redis-remove`

用于从节点上移除所有Redis实例

```bash
./redis-remove.yml -l <redis_cluster>
./redis-remove.yml -l <redis_node>
```

![](../_media/playbook/redis-remove.svg)

