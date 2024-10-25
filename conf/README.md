# Configuration Template

This directory (`conf`) contains pigsty config templates, Which will be used
during [`configure`](https://pigsty.io/docs/setup/install/#configure) procedure.

Config templates can be designated using `./configure -c <conf>`, where the conf is relative path to `conf` directory (
without `.yml` suffix).

```bash
./configure -m sandbox/meta
./configure -m default/el8
./configure -m sample/full
```

If you do not specify a conf, the `default/` template will be used, and chosen according to your OS distribution.



----------

## Default Templates

Pigsty will auto-select the following singleton templates according to your OS distribution (if configure mode is not
specified):

* [default/el8.yml](default/el8.yml): EL8, Rocky 8.9 and compatible OS
* [default/el9.yml](default/el9.yml): EL9, Rocky 9.3 and compatible OS
* [default/d12.yml](default/d12.yml): Debian 12 bookworm and compatible OS
* [default/u22.yml](default/u22.yml): Ubuntu 22.04 jammy and compatible OS

These three templates are deprecated, but still available for backward compatibility:

* [default/el7.yml](default/el7.yml): Ubuntu 20.04 focal and compatible OS
* [default/d11.yml](default/d11.yml): Debian 11 bullseye and compatible OS
* [default/u20.yml](default/u20.yml): Ubuntu 20.04 focal and compatible OS

The `configure` procedure is optional. You can always skip it and create `pigsty.yml` by yourself.

----------

## DBMS Templates

These templates concentrate on specific DBMS or DBMS related configurations.

* [dbms/supabase.yml](dbms/supabase.yml) : example config for Supabase underlying PostgreSQL
* [dbms/redis.yml](dbms/redis.yml) : example config for redis clusters
* [dbms/minio.yml](dbms/minio.yml) : example config for a 3-node minio clusters
* [dbms/citus.yml](dbms/citus.yml) : citus cluster example: 1 coordinator and 3 data nodes
* [dbms/mssql.yml](dbms/mssql.yml) : example config for WiltonDB & Babelfish Cluster with MSSQL compatibility
* [dbms/polar.yml](dbms/polar.yml) : PolarDB for PostgreSQL config example: PG with RAC
* [dbms/ivory.yml](dbms/ivory.yml) : IvorySQL cluster config example: Oracle Compatibility


----------

## Sandbox Templates

* [sandbox/meta.yml](sandbox/meta.yml) : example config for a singleton node deployment
* [sandbox/dual.yml](sandbox/dual.yml) : example config for a two node deployment
* [sandbox/trio.yml](sandbox/trio.yml) : example config for three node deployment
* [sandbox/full.yml](sandbox/full.yml) : example config for a 4-node cluster deployment
* [sandbox/prod.yml](sandbox/prod.yml) : Production emulation config with 42 nodes and 71C (EL8/9)

----------

## Demonstration Templates

These templates will demonstrate how to configure a cluster with different size and purpose.

* [demo/el.yml](demo/remote.yml) : config file with all default parameters for EL 8/9 systems.
* [demo/debian.yml](demo/public.yml) : config file with all default parameters for debian/ubuntu systems.
* [demo/e17.yml](demo/e17.yml) : config file for EL 8/9 systems and PostgreSQL 17
* [demo/d17.yml](demo/d17.yml) : config file for debian/ubuntu systems and PostgreSQL 17
* [demo/remote.yml](demo/remote.yml) : example config for monitoring a remote pgsql cluster or RDS PG.
* [demo/public.yml](demo/public.yml) : config file for the pigsty [public demo](https://demo.pigsty.cc)
* [demo/security.yml](sdemo/ecurity.yml) : security enhanced config example with delayed replica
* [demo/wool.yml](demo/wool.yml) : aliyun 99¥ ecs config template

----------

## Building Templates

There config templates are used for development and testing purpose.

* [build/oss.yml](build/oss.yml) : building config for EL 8, 9, Debian 12, and Ubuntu 22.04 OSS.
* [build/ext.yml](build/ext.yml) : rpm building environment for EL 7/8/9
* [build/pro.yml](build/pro.yml) : building config for EL 7-9, Ubuntu, Debian pro version
* [build/rpm.yml](build/rpm.yml) : building config for EL 7/8/9
* [build/deb.yml](build/deb.yml) : building config for ubuntu20/22 and debian 11/12
* [build/v17.yml](build/v17.yml) : building config for oss four node, but for PostgreSQL 17
