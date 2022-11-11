# Configuration Template

This directory (`files/conf`) contains pigsty configuration templates, Which will be used during [`configure`](https://github.com/Vonng/pigsty/wiki/Configuration) procedure.

Config templates are named as `pigsty-<mode>.yml`.  `<mode>` can be designated using `./configure -m <mode>`

There are several built-in modes:

* [pigsty-el7.yml](pigsty-el7.yml) : default config on RHEL7 and compatible OS distributions
* [pigsty-el8.yml](pigsty-el8.yml) : default config on RHEL8 and compatible OS distributions
* [pigsty-el9.yml](pigsty-el9.yml) : default config on RHEL9 and compatible OS distributions
* [pigsty-sec.yml](pigsty-sec.yml) : security enhanced version (on el7)
* [pigsty-demo.yml](pigsty-demo.yml) : exact same as default pigsty.yml , but in short version
* [pigsty-citus.yml](pigsty-citus.yml) : citus cluster example: 1 coordinator and 3 data nodes
* [pigsty-build.yml](pigsty-build.yml) : 3 nodes el7, el8, el9 for release building
* [pigsty-full.yml](pigsty-default.yml) : detail documented config example with default parameters
* [pigsty-pub.yml](pigsty-pub.yml) : configuration file for [public demo](http://demo.pigsty.cc)


Here are rules of which template is used:

* if `-m <mode>` is specified, corresponding `pigsty-<mode>.yml` is used.
* otherwise if current admin username is `vagrant`, `pigsty-demo.yml` is used.
* otherwise
  * if EL9 detected, `pigsty-el9.yml` is used.
  * if EL8 detected, `pigsty-el8.yml` is used.
  * if EL7 detected, `pigsty-el7.yml` is used.
* use el7 by default

`configure` is optional. You can always skip it and edit `pigsty.yml` by yourself. 