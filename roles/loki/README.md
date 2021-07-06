# Loki (Ansible role)

Install loki on meta nodes

### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Copy loki binaries to /usr/bin	TAGS: [loki, loki_install]
Cleanup loki	TAGS: [loki, loki_clean]
Render loki config	TAGS: [loki, loki_config]
Copy loki systemd service	TAGS: [loki, loki_config]
Launch Loki	TAGS: [loki, loki_launch]
Wait for loki online	TAGS: [loki, loki_launch]
```

### Default variables

[defaults/main.yml](defaults/main.yml)


```bash
# - loki - #
loki_clean: false                             # whether remove existing loki data
loki_data_dir: /data/loki                     # default loki data dir
```