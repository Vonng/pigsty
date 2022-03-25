# PGWEB (ansible role)

* setup pgweb web postgres GUI server

### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Create pgweb user	TAGS: [pgweb, pgweb_user]
Run whoami without become	TAGS: [pgweb, pgweb_user]
Overwrite pgweb username	TAGS: [pgweb, pgweb_user]
Unarchive pgweb archive file from local repo	TAGS: [pgweb, pgweb_install]
Move pgweb binary to /usr/local/bin/	TAGS: [pgweb, pgweb_install]
Copy pgweb systemd service	TAGS: [pgweb, pgweb_launch]
Launch pgweb service unit	TAGS: [pgweb, pgweb_launch]
Wait for pgweb lab online	TAGS: [pgweb, pgweb_launch]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
---
#-----------------------------------------------------------------
# PGWEB (BETA)
#-----------------------------------------------------------------
pgweb_enabled: true             # setup jupyter lab server?
pgweb_username: pgweb           # os user name, special names: default|root (dangerous!)

#-----------------------------------------------------------------
# NGINX (Reference)
#-----------------------------------------------------------------
nginx_upstream:                  # domain names and upstream servers
  - { name: pgweb,        domain: cli.pigsty, endpoint: "127.0.0.1:8081" }
...
```