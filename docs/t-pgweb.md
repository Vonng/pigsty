# PGWeb


## PGWEB Config

| ID  | Name                                    |           Section           | Type   | Level | Comment                       |
|-----|-----------------------------------------|-----------------------------|--------|-------|-------------------------------|
| 230 | [`pgweb_enabled`](#pgweb_enabled)            | [`PGWEB`](#PGWEB)           | bool   | G     | enable pgweb|
| 231 | [`pgweb_username`](#pgweb_username)          | [`PGWEB`](#PGWEB)           | string | G     | os user for pgweb|

PGWeb is a browser-based PostgreSQL client tool that can be used for scenarios such as small-batch personal data queries. It is currently an optional Beta feature and is only enabled in the demo by default.

This feature is enabled by default in the demo and disabled by default in other cases, and can be deployed manually on the meta node using [`infra-pgweb`](p-infra.md#infra-pgweb).


### `pgweb_enabled`

Enable PgWeb, type: `bool`, level: G, default value: `false`, enabled by default for demo and personal use, not enabled by default for production env deploy.

The PGWEB web interface is by default only accessible by the Nginx proxy via the domain name, which defaults to `cli.pigsty` and will be run by default with an OS user named `pgweb`.

```yaml
- { name: pgweb,        domain: cli.pigsty, endpoint: "127.0.0.1:8081" }
```


### `pgweb_username`

OS user used by PgWeb, type: `string`, level: G, default value: `"pgweb"`.

The operating system user running the PGWEB server. The default is `pgweb`, which means that a low privileged default user `pgweb` will be created.

The special username `default` will run PGWEB with the user who is currently performing the installation (usually administrator).

A connection string to a database that can be accessed from the env via PgWeb. For example: `postgres://dbuser_dba:DBUser.DBA@127.0.0.1:5432/meta`


## PGWEB Playbook

`infra-pgweb`

PGWeb is a browser-based PostgreSQL client tool that can be used in small batch personal queries and other scenarios. It is currently a  beta feature and is only enabled by default in the Demo env.

The [`infra-pgweb.yml`](https://github.com/Vonng/pigsty/blob/master/infra-pgweb.yml) playbook installs the PGWeb service on the meta node.

Refer to [Config: PGWEB](v-infra.md#PGWEB) to configure PGWEB and just execute this playbook.

```bash
./infra-pgweb.yml
```

