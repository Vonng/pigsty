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

* [el8.yml](default/el8.yml): EL8, Rocky 8.9 and compatible OS
* [el9.yml](default/el9.yml): EL9, Rocky 9.3 and compatible OS
* [d12.yml](default/d12.yml): Debian 12 bookworm and compatible OS
* [u22.yml](default/u22.yml): Ubuntu 22.04 jammy and compatible OS

These three templates are deprecated, but still available for backward compatibility:

* [el7.yml](default/el7.yml): Ubuntu 20.04 focal and compatible OS
* [d11.yml](default/d11.yml): Debian 11 bullseye and compatible OS
* [u20.yml](default/u20.yml): Ubuntu 20.04 focal and compatible OS

The `configure` procedure is optional. You can always skip it and create `pigsty.yml` by yourself.

----------

## DBMS Templates

These templates concentrate on specific DBMS or DBMS related configurations.

* [supabase.yml](dbms/supabase.yml) : example config for Supabase underlying PostgreSQL
* [redis.yml](dbms/redis.yml) : example config for redis clusters
* [minio.yml](dbms/minio.yml) : example config for a 3-node minio clusters
* [citus.yml](dbms/citus.yml) : citus cluster example: 1 coordinator and 3 data nodes
* [mssql.yml](dbms/mssql.yml) : example config for WiltonDB & Babelfish Cluster with MSSQL compatibility
* [polar.yml](dbms/polar.yml) : PolarDB for PostgreSQL config example: PG with RAC
* [ivory.yml](dbms/ivory.yml) : IvorySQL cluster config example: Oracle Compatibility


----------

## Sandbox Templates

* [meta.yml](sandbox/meta.yml) : example config for a singleton node deployment
* [dual.yml](sandbox/dual.yml) : example config for a two node deployment
* [trio.yml](sandbox/trio.yml) : example config for three node deployment
* [full.yml](sandbox/full.yml) : example config for a 4-node cluster deployment
* [prod.yml](sandbox/prod.yml) : Production emulation config with 42 nodes and 71C (EL8/9)

----------

## Demonstration Templates

These templates will demonstrate how to configure a cluster with different size and purpose.

* [el.yml](demo/remote.yml) : config file with all default parameters for EL 8/9 systems.
* [debian.yml](demo/public.yml) : config file with all default parameters for debian/ubuntu systems.
* [remote.yml](demo/remote.yml) : example config for monitoring a remote pgsql cluster or RDS PG.
* [public.yml](demo/public.yml) : config file for the pigsty [public demo](https://demo.pigsty.cc)
* [security.yml](sdemo/ecurity.yml) : security enhanced config example with delayed replica
* [wool.yml](demo/wool.yml) : aliyun 99¥ ecs config template

----------

## Building Templates

There config templates are used for development and testing purpose.

* [oss.yml](build/oss.yml) : building config for EL 8, 9, Debian 12, and Ubuntu 22.04 OSS.
* [ext.yml](build/ext.yml) : rpm building environment for EL 7/8/9
* [pro.yml](build/pro.yml) : building config for EL 7-9, Ubuntu, Debian pro version
* [rpm.yml](build/rpm.yml) : building config for EL 7/8/9
* [deb.yml](build/deb.yml) : building config for ubuntu20/22 and debian 11/12
