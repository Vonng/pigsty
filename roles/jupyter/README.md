# Jupyter (ansible role)

* setup jupyter notebooks

### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
jupyter : Create jupyter user {{ jupyter_username }}	TAGS: [infra, jupyter, jupyter_user]
jupyter : Run whoami without become	TAGS: [infra, jupyter, jupyter_user]
jupyter : Overwrite jupyter username	TAGS: [infra, jupyter, jupyter_user]
jupyter : Create jupyter config directory	TAGS: [infra, jupyter, jupyter_config]
jupyter : Create jupyter lab directory	TAGS: [infra, jupyter, jupyter_config]
jupyter : Generate jupyter config	TAGS: [infra, jupyter, jupyter_config]
jupyter : Generate jupyter salted password	TAGS: [infra, jupyter, jupyter_config, jupyter_password]
jupyter : Write jupyter lab password file	TAGS: [infra, jupyter, jupyter_config, jupyter_password]
jupyter : Copy jupyter lab systemd service	TAGS: [infra, jupyter, jupyter_launch]
jupyter : Launch jupyter lab service unit	TAGS: [infra, jupyter, jupyter_launch]
jupyter : Wait for jupyter lab online	TAGS: [infra, jupyter, jupyter_launch]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
jupyter_enabled: true                         # setup jupyter lab server?
jupyter_username: jupyter                     # os user name, special names: default|root (dangerous!)
jupyter_password: pigsty                      # default password for jupyter lab (important!)

# - reference - #
nginx_upstream:                               # domain names that will be used for accessing pigsty services
  - { name: jupyter,       domain: lab.pigsty,    endpoint: "127.0.0.1:8888" }     # jupyter lab (8888)
```