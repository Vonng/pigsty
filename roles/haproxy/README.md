# HAProxy


## FHS

```bash
# /etc/haproxy                    # main config dir
#       ^----- default            # default haproxy server
#       ^----- pg-test-primary    # 5433
#       ^----- pg-test-replica    # 5434
#       ^----- pg-test-default    # 5435
#       ^----- pg-test-offline    # 5436
#       ^----- redis-test         # ????
#       ^----- .........
```


## Define Service

Define two extra haproxy services on node clusters:

```yaml
haproxy_services:                   # list of haproxy service

  # expose pg-test read only replicas
  - name: pg-test-ro                # [REQUIRED] service name, unique
    port: 5440                      # [REQUIRED] service port, unique
    ip: "*"                         # [OPTIONAL] service listen addr, "*" by default
    protocol: tcp                   # [OPTIONAL] service protocol, 'tcp' by default
    balance: leastconn              # [OPTIONAL] load balance algorithm, roundrobin by default (or leastconn)
    maxconn: 20000                  # [OPTIONAL] max allowed front-end connection, 20000 by default
    default: 'inter 3s fastinter 1s downinter 5s rise 3 fall 3 on-marked-down shutdown-sessions slowstart 30s maxconn 3000 maxqueue 128 weight 100'
    options:
      - option httpchk
      - option http-keep-alive
      - http-check send meth OPTIONS uri /read-only
      - http-check expect status 200
    servers:
      - { name: pg-test-1 ,ip: 10.10.10.11 , port: 5432 , options: check port 8008 , backup: true }
      - { name: pg-test-2 ,ip: 10.10.10.12 , port: 5432 , options: check port 8008 }
      - { name: pg-test-3 ,ip: 10.10.10.13 , port: 5432 , options: check port 8008 }

  # expose redis-cluster with haproxy
  - name: redis-test
    port: 5441
    servers:
      - { name: redis-test-1-6501 , ip: 10.10.10.11 , port: 6501 , options: check }
      - { name: redis-test-1-6502 , ip: 10.10.10.11 , port: 6502 , options: check }
      - { name: redis-test-1-6503 , ip: 10.10.10.11 , port: 6503 , options: check }
      - { name: redis-test-2-6501 , ip: 10.10.10.12 , port: 6501 , options: check }
      - { name: redis-test-2-6502 , ip: 10.10.10.12 , port: 6502 , options: check }
      - { name: redis-test-2-6503 , ip: 10.10.10.12 , port: 6503 , options: check }
```

Append services and reload them

```bash
./node.yml -t haproxy_config
```