# Configuration Template

This directory (`files/pigsty`) contains pigsty config templates,
Which will be used during [`configure`](https://github.com/Vonng/pigsty/wiki/Configuration) procedure.

Config templates are named as `<mode>.yml`.  `<mode>` can be designated using `./configure -m <mode>`

There are several built-in templates:

* [default.yml](default.yml) : detail documented config example with default parameters
* [el7.yml](el7.yml) : default config on RHEL7 and compatible OS distributions
* [el8.yml](el8.yml) : default config on RHEL8 and compatible OS distributions
* [el9.yml](el9.yml) : default config on RHEL9 and compatible OS distributions
* [security.yml](security.yml) : security enhanced config (on el7)
* [demo.yml](demo.yml) : exact same as default.yml, in short version
* [citus.yml](citus.yml) : citus cluster example: 1 coordinator and 3 data nodes
* [build.yml](build.yml) : 3 nodes el7, el8, el9 for release building
* [pubic.yml](public.yml) : config for [public demo](http://demo.pigsty.cc)
* [test.yml](test.yml) : config for different EL distribution testing


Here are rules of which template is used:

* if `-m <mode>` is specified, corresponding `<mode>.yml` is used.
* otherwise if current admin username is `vagrant`, `demo.yml` is used.
* otherwise
  * if EL9 detected, `el9.yml` is used.
  * if EL8 detected, `el8.yml` is used.
  * if EL7 detected, `el7.yml` is used.
* use el7 by default

`configure` is optional. You can always skip it and create `pigsty.yml` by yourself. 