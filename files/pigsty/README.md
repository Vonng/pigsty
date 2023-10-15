# Configuration Template

This directory (`files/pigsty`) contains pigsty config templates, Which will be used during [`configure`](https://doc.pigsty.cc/#/INSTALL) procedure.

Config templates are named as `<mode>.yml`.  `<mode>` can be designated using `./configure -m <mode>`

There are several built-in templates for your reference, you can also create your own templates in `files/pigsty`.


## Singleton Templates

If `-m <mode>` is specified, corresponding `<mode>.yml` is used, otherwise pigsty will auto-selected the following singleton templates according to your OS distribution:

* [el.yml](el.yml) : Pigsty auto generated config for el8, el9 compatible singleton node
* [el7.yml](el7.yml) : Pigsty auto generated config for el7 compatible singleton node
* [ubuntu.yml](ubuntu.yml) : Pigsty auto generated config for ubuntu singleton node (22.04/20.04)
* [debian.yml](debian.yml) : Pigsty auto generated config for debian singleton node (12/11)

The `configure` procedure is optional. You can always skip it and create `pigsty.yml` by yourself.


## Demonstration Templates

These templates will demonstrate how to configure a cluster with different size and purpose.

* [full.yml](full.yml) : detail documented config example with full default parameter listed
* [demo.yml](demo.yml) : exact same as default.yml, short version
* [remote.yml](remote.yml) : example config for monitoring a remote pgsql cluster or RDS PG.
* [public.yml](public.yml) : config file for the pigsty [public demo](https://demo.pigsty.cc)
* [security.yml](security.yml) : security enhanced config example with delayed replica
* [dual.yml](dual.yml) : example config for a two node deployment

## Development Templates

* [build.yml](build.yml) : building config for el7, el8, el9 nodes
* [build.yml](build.yml) : building config for ubuntu20/22 and debian 11/12
* [check.yml](check.yml) : Validate pigsty on different EL distributions
* [prod.yml](prod.yml) : Production emulation config with 42 nodes and 71C
* [test.yml](test.yml) : config for 3 different EL distribution testing
* [os.yml](os.yml) : Run pigsty on different OS distributions


## Misc Templates

* [redis.yml](redis.yml) : example config for redis clusters
* [minio.yml](minio.yml) : example config for a 3-node minio clusters
* [citus.yml](citus.yml) : citus cluster example: 1 coordinator and 3 data nodes





