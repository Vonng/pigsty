# Jupyter (ansible role)

* setup jupyter lab server

### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Create jupyter user {{ jupyter_username }}	TAGS: [jupyter, jupyter_user]
Run whoami without become	TAGS: [jupyter, jupyter_user]
Overwrite jupyter username	TAGS: [jupyter, jupyter_user]
Create jupyter config directory	TAGS: [jupyter, jupyter_config]
Create jupyter lab directory	TAGS: [jupyter, jupyter_config]
Generate jupyter config	TAGS: [jupyter, jupyter_config]
Generate jupyter salted password	TAGS: [jupyter, jupyter_config, jupyter_password]
Write jupyter lab password file	TAGS: [jupyter, jupyter_config, jupyter_password]
Copy jupyter lab systemd service	TAGS: [jupyter, jupyter_launch]
Launch jupyter lab service unit	TAGS: [jupyter, jupyter_launch]
Wait for jupyter lab online	TAGS: [jupyter, jupyter_launch]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
---
#-----------------------------------------------------------------
# JUPYTER (BETA)
#-----------------------------------------------------------------
jupyter_enabled: true           # setup jupyter lab server?
jupyter_username: jupyter       # os user name, special names: default|root (dangerous!)
jupyter_password: pigsty        # default password for jupyter lab (important!)

#-----------------------------------------------------------------
# NGINX (Reference)
#-----------------------------------------------------------------
nginx_upstream:                 # domain names and upstream servers
  - { name: jupyter,      domain: lab.pigsty, endpoint: "127.0.0.1:8888" }
...
```