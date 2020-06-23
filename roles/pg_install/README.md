# PG Install (ansible role)

This role will install postgres with given version
* Init PostgreSQL DBSU (postgres by default, already init during infra provision)
* init postgres directory structure
* install postgres with specified version, extensions, etc...

### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
tasks:
  pg_install : Install offical pgdg yum repo		TAGS: [pg_install]
  pg_install : Listing packages to be installed		TAGS: [pg_install]
  pg_install : Add postgis packages to checklist	TAGS: [pg_install]
  pg_install : Add extension packages to checklist	TAGS: [pg_install]
  pg_install : Print packages to be installed		TAGS: [pg_install]
  pg_install : Create os admin user group admin		TAGS: [pg_install]
  pg_install : Create os user postgres:admin		TAGS: [pg_install]
  pg_install : Install postgres major version pkgs	TAGS: [pg_install]
  pg_install : Install postgres additional packages	TAGS: [pg_install]
  pg_install : Link /usr/pgsql to current version	TAGS: [pg_install]
  pg_install : Add /usr/ppgsql to profile path		TAGS: [pg_install]
  pg_install : Check pgsql version installed		TAGS: [pg_install]
  pg_install : Remove default postgres service		TAGS: [pg_install]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
pg_version: 12                  # default postgresql version
pg_postgis_version: 30          # install postgis extension?
pg_pgdg_repo: false               # use official pgdg yum repo (disable if you have local mirror)
pg_dbsu:  postgres               # postgresql dbsu (currently setup during node provision)
pg_home:  /usr/pgsql             # postgresql binary
pg_postgis_install: true        # install postgis extension?
pg_extension_install: true      # install postgis extension?
```