# Configuration Template

This directory (`conf`) contains pigsty config templates, Which will be used during [`configure`](https://pigsty.io/docs/setup/install/#configure) procedure.

Config templates can be designated using `./configure -c <conf>`, where the conf is relative path to `conf` directory (with or without `.yml` suffix).

```bash
./configure                     # use the meta.yml config template by default
./configure -c meta             # use the meta.yml 1-node template explicitly
./configure -c full             # use the full.yml 4-node template
./configure -c mssql            # use the mssql.yml 4-node babelfish template 
./configure -c build/ext        # use the extension building template
./configure -c demo/public      # use the conf/demo/public.yml template
```

Pigsty will use the `meta.yml` single node config template if you do not specify a conf. 


----------

## Main Templates

These config templates provide a boilerplate for running Pigsty on 1/2/3/4 or more nodes:

* [meta.yml](meta.yml) : default config for a singleton node deployment
* [dual.yml](dual.yml) : example config for a 2-node deployment
* [trio.yml](trio.yml) : example config for 3-node deployment
* [full.yml](full.yml) : example config for a 4-node cluster deployment

These templates are based on the `full.yml` 4-node templates, with an exotic PostgreSQL kernel (or wrappers).

* [supabase.yml](supabase.yml) : example config for Supabase underlying PostgreSQL (4-node)
* [mssql.yml](mssql.yml) : example config for WiltonDB & Babelfish Cluster with MSSQL compatibility (4-node)
* [polar.yml](polar.yml) : PolarDB for PostgreSQL config example: PG with RAC (4-node)
* [ivory.yml](ivory.yml) : IvorySQL cluster config example: Oracle Compatibility (4-node)
 
Deploy PostgreSQL without Infra (& repo), or run a local 43-node prod env simulation

* [mini.yml](mini.yml) : 1-node mini config, deploy PostgreSQL without infra and local repo
* [prod.yml](prod.yml) : Production emulation config with 43-node env



----------

## Demo Templates

In addition to the main templates, Pigsty provides a set of demo templates for different scenarios.

* [bare.yml](demo/bare.yml): 1-node bare config, the minimal config to run pigsty.
* [rich.yml](demo/rich.yml) : 1-node rich config, run multiple database and install all extensions.
* [demo/el.yml](demo/remote.yml) : config file with all default parameters for EL 8/9 systems.
* [demo/debian.yml](demo/public.yml) : config file with all default parameters for debian/ubuntu systems.
* [demo/remote.yml](demo/remote.yml) : example config for monitoring a remote pgsql cluster or RDS PG.
* [demo/public.yml](demo/public.yml) : config file for the pigsty [public demo](https://demo.pigsty.cc)
* [demo/security.yml](demo/security.yml) : security enhanced config example with delayed replica
* [demo/wool.yml](demo/wool.yml) : aliyun 99¥ ecs config template
* [demo/redis.yml](demo/redis.yml) : example config for redis clusters
* [demo/minio.yml](demo/minio.yml) : example config for a 3-node minio clusters
* [demo/citus.yml](demo/citus.yml) : citus cluster example: 1 coordinator and 3 data nodes


----------

## Building Templates

There config templates are used for development and testing purpose.

* [build/oss.yml](build/oss.yml) : building config for EL 8, 9, Debian 12, and Ubuntu 22.04/24.04 OSS.
* [build/ext.yml](build/ext.yml) : rpm building environment for EL 7/8/9
* [build/pro.yml](build/pro.yml) : building config for EL 7-9, Ubuntu, Debian pro version
* [build/rpm.yml](build/rpm.yml) : building config for EL 7/8/9
* [build/deb.yml](build/deb.yml) : building config for ubuntu20/22/24 and debian 11/12


----------

## Default Templates

Pigsty will auto-select the following singleton templates according to your OS distribution (if configure mode is not
specified):

* [default/el8.yml](default/el8.yml): EL8, Rocky 8.9 and compatible OS
* [default/el9.yml](default/el9.yml): EL9, Rocky 9.3 and compatible OS
* [default/d12.yml](default/d12.yml): Debian 12 bookworm and compatible OS
* [default/u22.yml](default/u22.yml): Ubuntu 22.04 jammy and compatible OS
* [default/u24.yml](default/u24.yml): Ubuntu 24.04 noble and compatible OS

These three templates are deprecated, but still available for backward compatibility:

* [default/el7.yml](default/el7.yml): Ubuntu 20.04 focal and compatible OS
* [default/d11.yml](default/d11.yml): Debian 11 bullseye and compatible OS
* [default/u20.yml](default/u20.yml): Ubuntu 20.04 focal and compatible OS

The `configure` procedure is optional. You can always skip it and create `pigsty.yml` by yourself.
