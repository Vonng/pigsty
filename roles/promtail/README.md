# Promtail (Ansible role)

Install promtail on pgsql nodes

### Logs

Following logs will be collected:

* `INFRA`: only enabled on meta nodes
    * `nginx-access`: `/var/log/nginx/access.log`
    * `nginx-error`: `/var/log/nginx/error.log`
    * `grafana`: `/var/log/grafana/grafana.log`

* `NODES`: collected on all nodes
    * `syslog`: `/var/log/messages`
    * `dmesg`: `/var/log/dmesg`
    * `cron`: `/var/log/cron`

* `PGSQL`: collected when `pg_cluster` is defined
    * `postgres`: `/pg/data/log/*.csv`
    * `patroni`: `/pg/log/patroni.log`
    * `pgbouncer`: `/var/log/pgbouncer/pgbouncer.log`

* `REDIS`: collected when `redis_cluster` is defined
    * `redis`: `/var/log/redis/*.log`


### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Install promtail via yum	TAGS: [node-monitor, promtail, promtail_install]
Cleanup promtail positions	TAGS: [node-monitor, promtail, promtail_clean]
Copy promtail systemd service	TAGS: [node-monitor, promtail, promtail_config]
Fetch hostname from server if no node name is given	TAGS: [node-monitor, promtail, promtail_config]
Setup nodename according to hostname	TAGS: [node-monitor, promtail, promtail_config]
Render promtail main config	TAGS: [node-monitor, promtail, promtail_config]
Render promtail default config	TAGS: [node-monitor, promtail, promtail_config]
Launch promtail	TAGS: [node-monitor, promtail, promtail_launch]
Wait for promtail online	TAGS: [node-monitor, promtail, promtail_launch]
```

### Default variables

[defaults/main.yml](defaults/main.yml)


```bash
#------------------------------------------------------------------------------
# PROMTAIL
#------------------------------------------------------------------------------
promtail_enabled: true           # enable promtail logging collector?
promtail_clean: false            # remove promtail status file? false by default
promtail_port: 9080              # default listen address for promtail
promtail_options: '-config.file=/etc/promtail.yml -config.expand-env=true'
promtail_positions: /var/log/positions.yaml   # position status for promtail


#------------------------------------------------------------------------------
# LOKI (Reference)
#------------------------------------------------------------------------------
loki_endpoint: http://10.10.10.10:3100/loki/api/v1/push  # loki url to receive logs
```