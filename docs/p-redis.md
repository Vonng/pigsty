# Playbook: REDIS

> REDIS series [Playbook](p-playbook.md): Define and pull Redis databases in traditional standalone, native, and sentinel clusters.

| Playbook | Function                                                 | Link                                                     |
|--------|--------------------------------------------------------------| ------------------------------------------------------------ |
|  [`redis`](p-redis.md#redis)                        | Deploying a Redis database in Native/Standalone/Sentinel cluster |        [`src`](https://github.com/vonng/pigsty/blob/master/redis.yml)            |
|  [`redis-remove`](p-redis.md#redis-remove)          |        Redis cluster/node destruction        |        [`src`](https://github.com/vonng/pigsty/blob/master/redis-remove.yml)     |


------------------

## `redis`

Deploy redis instances on nodes.

```bash
./redis.yml -l <redis_cluster>
```

![](_media/playbook/redis.svg)

------------------

## `redis-remove`

Remove redis instances from nodes.

```bash
./redis-remove.yml -l <redis_cluster>
./redis-remove.yml -l <redis_node>
```

![](_media/playbook/redis-remove.svg)

