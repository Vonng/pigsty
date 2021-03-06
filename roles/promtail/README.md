# Promtail (Ansible role)

Install promtail on pgsql nodes

### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Install promtail binary	TAGS: [promtail, promtail_install]
Cleanup promtail	TAGS: [promtail, promtail_clean]
Render promtail config	TAGS: [promtail, promtail_config]
Copy promtail systemd service	TAGS: [promtail, promtail_config]
Launch promtail	TAGS: [promtail, promtail_launch]
Wait for promtail online	TAGS: [promtail, promtail_launch]
```

### Default variables

[defaults/main.yml](defaults/main.yml)


```bash
---
# - promtail - #                              # promtail is a beta feature which requires manual deployment
promtail_enabled: true                        # enable promtail logging collector?
promtail_clean: false                         # remove promtail status file? false by default
promtail_port: 9080                           # default listen address for promtail
promtail_status_file: /tmp/promtail-status.yml
promtail_send_url: http://pigsty:3100/loki/api/v1/push  # loki url to receive logs
...
```