# Playbook：REDIS

> REDIS series [Playbook](p-playbook.md)：Define and pull up Redis databases in traditional master-slave, clustered, Sentinel mode.

| Playbook | Function                                                 | Link                                                     |
|--------|--------------------------------------------------------------| ------------------------------------------------------------ |
|  [`redis`](p-redis.md#redis)                        | Deploying a Redis database in cluster/master-slave/Sentinel mode |        [`src`](https://github.com/vonng/pigsty/blob/master/redis.yml)            |
|  [`redis-remove`](p-redis.md#redis-remove)          |        Redis cluster/node offline         |        [`src`](https://github.com/vonng/pigsty/blob/master/redis-remove.yml)     |


------------------

## `redis`

Deploy redis instances on nodes

```bash
./redis.yml -l <redis_cluster>
```

![](_media/playbook/redis.svg)

------------------

## `redis-remove`

Remove redis instances from nodes

```bash
./redis-remove.yml -l <redis_cluster>
./redis-remove.yml -l <redis_node>
```

![](_media/playbook/redis-remove.svg)

