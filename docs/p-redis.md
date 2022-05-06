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
# init all redis instances on group <cluster>
 ./redis.yml -l <cluster>    # create redis cluster

# init redis node (package,dir,exporter)
 ./redis.yml -l 10.10.10.10    # create redis cluster

# init all redis instances specific node
 ./redis.yml -l 10.10.10.10    # create redis cluster

# init one specific instance 10.10.10.11:6501
 ./redis.yml -l 10.10.10.11 -e redis_port=6501 -t redis

```

![](_media/playbook/redis.svg)

------------------

## `redis-remove`

Remove redis instances from nodes.

```bash
# Remove cluster `redis-test`
redis-remove.yml -l redis-test

# Remove all instance on redis node 10.10.10.13
redis-remove.yml -l 10.10.10.13

# Remove one specific instance 10.10.10.13:6501
redis-remove.yml -l 10.10.10.13 -e redis_port=6501
```

![](_media/playbook/redis-remove.svg)

