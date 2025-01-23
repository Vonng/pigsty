# Configuration Template

This directory (`conf`) contains pigsty config templates, Which will be used during [`configure`](https://pigsty.io/docs/setup/install/#configure) procedure.

Config templates can be designated using `./configure -c <conf>`, where the conf is relative path to `conf` directory (with or without `.yml` suffix).

```bash
./configure                     # use the meta.yml config template by default
./configure -c meta             # use the meta.yml 1-node template explicitly
./configure -c full             # use the full.yml 4-node template
./configure -c mssql            # use the mssql.yml 4-node babelfish template 
```

Pigsty will use the `meta.yml` single node config template if you do not specify a conf. 


----------

## Main Templates

These config templates provide a boilerplate for running Pigsty on 1/2/3/4 or more nodes:

* [meta.yml](meta.yml) : default config for a singleton node deployment
* [dual.yml](dual.yml) : example config for a 2-node deployment
* [trio.yml](trio.yml) : example config for 3-node deployment
* [full.yml](full.yml) : example config for a 4-node cluster deployment

Templates for exotic DBMS and kernels:

* [supa.yml](supa.yml) : example config for Supabase underlying PostgreSQL (4-node)
* [mssql.yml](mssql.yml) : example config for WiltonDB & Babelfish Cluster with MSSQL compatibility (4-node)
* [polar.yml](polar.yml) : PolarDB for PostgreSQL config example: PG with RAC (4-node)
* [ivory.yml](ivory.yml) : IvorySQL cluster config example: Oracle Compatibility (4-node)
* [citus.yml](citus.yml) : citus cluster example: 1 coordinator and 3 data nodes

Other templates:

* [slim.yml](slim.yml) : 1-node slim config, deploy PostgreSQL without infra and local repo & infra
* [simu.yml](simu.yml) : Production simulation config with 36-node env
* [demo.yml](demo.yml) : config file for the pigsty [public demo](https://demo.pigsty.cc)
* [rich.yml](rich.yml) : 1-node rich config, run multiple database and install all extensions.
* [safe.yml](safe.yml) : security enhanced config example with delayed replica
* [minio.yml](minio.yml) : example config for a 3-node minio clusters


----------

## Demo Templates

In addition to the main templates, Pigsty provides a set of demo templates for different scenarios.

* [demo/el.yml](demo/remote.yml) : config file with all default parameters for EL 8/9 systems.
* [demo/debian.yml](demo/debian.yml) : config file with all default parameters for debian/ubuntu systems.
* [demo/remote.yml](demo/remote.yml) : example config for monitoring a remote pgsql cluster or RDS PG.
* [demo/redis.yml](demo/redis.yml) : example config for redis clusters


----------

## Building Templates

There config templates are used for development and testing purpose.

* [build/oss.yml](build/oss.yml) : building config for EL 8, 9, Debian 12, and Ubuntu 22.04/24.04 OSS.
* [build/pro.yml](build/pro.yml) : building config for EL 7-9, Ubuntu, Debian pro version
* [build/ext.yml](build/ext.yml) : rpm building environment for EL 8/9 and Debian 12, Ubuntu 22/24
