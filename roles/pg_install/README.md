# PG Install (ansible role)

This role will install postgres with given version
* Init PostgreSQL DBSU (postgres by default, already init during infra provision)
* init postgres directory structure
* install postgres with specified version, extensions, etc...

### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
tasks:
  pg_install : Create postgres directory structure	TAGS: [meta, pg_directory]
  pg_install : Create links from pgbkup to pgroot	TAGS: [meta, pg_directory]
  pg_install : Install offical pgdg yum repo		TAGS: [meta, pg_install]
  pg_install : Listing packages to be installed		TAGS: [meta, pg_install]
  pg_install : Add postgis packages to checklist	TAGS: [meta, pg_install]
  pg_install : Add extension packages to checklist	TAGS: [meta, pg_install]
  pg_install : Print packages to be installed		TAGS: [meta, pg_install]
  pg_install : Install postgres major version		TAGS: [meta, pg_install]
  pg_install : Install postgres according to list	TAGS: [meta, pg_install]
  pg_install : Link /usr/pgsql to current version	TAGS: [meta, pg_install]
  pg_install : Add /usr/ppgsql to profile path		TAGS: [meta, pg_install]
  pg_install : Check installed pgsql version		TAGS: [meta, pg_install]
  pg_install : Copy postgres systemd service file	TAGS: [meta, pg_install]
  pg_install : Daemon reload postgres service		TAGS: [meta, pg_install]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
# cluster: test       # REQUIRED cluster name
version: 12           # REQUIRED default=12

use_pgdg: false       # use official yum repo
postgis: true         # install postgis
postgis_version: 30   # postgis version
extensions: true      # install common extensions
```