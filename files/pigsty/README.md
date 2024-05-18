# Configuration Template

This directory (`files/pigsty`) contains pigsty config templates, Which will be used during [`configure`](https://pigsty.io/docs/setup/install/#configure) procedure.

Config templates are named as `<mode>.yml`.  `<mode>` can be designated using `./configure -m <mode>`

There are several built-in templates for your reference, you can also create your own templates in `files/pigsty`.

----------

## Default Templates

If `-m <mode>` is specified, corresponding `<mode>.yml` is used, otherwise pigsty will auto-selected the following singleton templates according to your OS distribution:

* [el8.yml](el8.yml): EL8, Rocky 8.9 and compatible OS
* [debian12.yml](debian12.yml): Debian 12 bookworm and compatible OS
* [ubuntu22.yml](ubuntu22.yml): Ubuntu 22.04 jammy and compatible OS

The above 3 os distro have corresponding offline packages available. And the following os distros can only be online installed:

* [el7.yml](el7.yml): EL7, CentOS 7.9 and compatible OS
* [el9.yml](el9.yml): EL9, Rocky 9.3 and compatible OS
* [debian11.yml](debian11.yml): Debian 11 bullseye and compatible OS
* [ubuntu20.yml](ubuntu20.yml): Ubuntu 20.04 focal and compatible OS

The `configure` procedure is optional. You can always skip it and create `pigsty.yml` by yourself.


----------

## Demonstration Templates

These templates will demonstrate how to configure a cluster with different size and purpose.

* [full.yml](full.yml) : detail documented config example with full default parameter listed
* [demo.yml](demo.yml) : exact same as default.yml, short version
* [remote.yml](remote.yml) : example config for monitoring a remote pgsql cluster or RDS PG.
* [public.yml](public.yml) : config file for the pigsty [public demo](https://demo.pigsty.cc)
* [security.yml](security.yml) : security enhanced config example with delayed replica
* [dual.yml](dual.yml) : example config for a two node deployment


----------

## Development Templates

There config templates are used for development and testing purpose.

* [oss.yml](oss.yml) : building config for EL 8, Debian 12, and Ubuntu 22.04 OSS version offline package.
* [build.yml](build.yml) : building config for EL 7-9, Ubuntu, Debian pro version
* [rpm.yml](rpm.yml) : building config for EL 7/8/9
* [deb.yml](deb.yml) : building config for ubuntu20/22 and debian 11/12
* [check.yml](check.yml) : Validate pigsty on different EL distributions
* [rpmbuild.yml](rpmbuild.yml) : rpm building environment for EL 7/8/9
* [prod.yml](prod.yml) : Production emulation config with 42 nodes and 71C (EL8/9)
* [prod-deb.yml](prod-deb.yml) : Production emulation config with 42 nodes and 71C (Ubuntu 22/Debian 12)
* [test.yml](test.yml) : config for 3 different EL distribution testing


----------

## Misc Templates

* [redis.yml](redis.yml) : example config for redis clusters
* [minio.yml](minio.yml) : example config for a 3-node minio clusters
* [citus.yml](citus.yml) : citus cluster example: 1 coordinator and 3 data nodes
* [wool.yml](wool.yml) : aliyun 99¥ ecs config template

