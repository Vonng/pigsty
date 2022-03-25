# Loki (Ansible role)

Install loki on meta nodes

### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Install loki via yum	TAGS: [infra-svcs, loki, loki_install]
Cleanup loki	TAGS: [infra-svcs, loki, loki_clean]
Copy loki systemd service	TAGS: [infra-svcs, loki, loki_config]
Copy loki.yml main config	TAGS: [infra-svcs, loki, loki_config]
Render loki default config	TAGS: [infra-svcs, loki, loki_config]
Launch Loki	TAGS: [infra-svcs, loki, loki_launch]
Wait for loki online	TAGS: [infra-svcs, loki, loki_launch]
```

### Default variables

[defaults/main.yml](defaults/main.yml)


```bash
#-----------------------------------------------------------------
# LOKI
#-----------------------------------------------------------------
loki_clean: false               # whether remove existing loki data
loki_options: '-config.file=/etc/loki.yml -config.expand-env=true'
loki_data_dir: /data/loki       # default loki data dir
loki_retention: 15d             # log retention period
```