# Configuration Template

This directory (`files/pigsty`) contains pigsty config templates,
Which will be used during [`configure`](https://vonng.github.io/pigsty/#/INSTALL) procedure.

Config templates are named as `<mode>.yml`.  `<mode>` can be designated using `./configure -m <mode>`

There are several built-in templates:

* [full.yml](full.yml) : detail documented config example with default parameters
* [demo.yml](demo.yml) : exact same as default.yml, in short version
* [auto.yml](auto.yml) : Pigsty auto generated config for el7,8,9 singleton
* [el7.yml](el7.yml) : If you wish to download packages from upstream directly on EL7
* [el8.yml](el8.yml) : If you wish to download packages from upstream directly on EL8
* [el8.yml](el8.yml) : If you wish to download packages from upstream directly on EL9
* [security.yml](security.yml) : security enhanced config (on el7)
* [citus.yml](citus.yml) : citus cluster example: 1 coordinator and 3 data nodes
* [build.yml](build.yml) : 3 nodes el7, el8, el9 for release building
* [pubic.yml](public.yml) : config for [public demo](http://demo.pigsty.cc)
* [test.yml](test.yml) : config for different EL distribution testing


If `-m <mode>` is specified, corresponding `<mode>.yml` is used, otherwise, `auto.yml` is used by default.

If you wish to download packages from upstream directly rather than using pre-packed offline packages, just use `el7.yml` or `el8.yml` instead of `auto.yml`.
There's no dedicate `el9.yml` template since the default `auto.yml` assume a EL9 system.


The `configure` procedure is optional. You can always skip it and create `pigsty.yml` by yourself. 