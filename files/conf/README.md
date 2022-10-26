# Configuration Template

This directory (`files/conf`) contains pigsty configuration templates, Which will be used during `configure` procedure.

Config templates are named as `pigsty-<mode>.yml`.  `<mode>` can be designated using `./configure -m <mode>`

There are several built-in modes:

* [pigsty-demo.yml](pigsty-demo.yml) : exact same as repo default: 4 node sandbox demo (EL7)
* [pigsty-auto.yml](pigsty-auto.yml) : auto generated template for production installation (EL7)
* [pigsty-el8.yml](pigsty-el8.yml) : example config on RHEL8 and compatible OS distributions
* [pigsty-el9.yml](pigsty-el9.yml) : example config on RHEL9 and compatible OS distributions
* [pigsty-citus.yml](pigsty-citus.yml) : citus cluster example: 1 coordinator and 3 data nodes
* [pigsty-dcs3.yml](pigsty-dcs3.yml) : 3 meta nodes x 3 dcs servers, and delayed replica example 
* [pigsty-mxdb.yml](pigsty-mxdb.yml) : matrixdb (greenplum 7) 4 nodes sandbox on el7
* [pigsty-sec.yml](pigsty-sec.yml) : example of enabling ssl everywhere
* [pigsty-pub4.yml](pigsty-pub4.yml) : configuration file for [public demo](http://demo.pigsty.cc)
* [pigsty-build.yml](pigsty-build.yml) : 3 nodes el7, el8, el9 for release building

if `-m` is not specified, here are some special rules about default mode:

* if el9 is detected, use `pigsty-el9.yml` 
* if el8 is detected, use `pigsty-el8.yml`
* if current admin username is `vagrant`, use `pigsty-demo.yml`
* otherwise, use `pigsty-auto.yml`

`configure` is optional. You can always skip it and edit `pigsty.yml` by yourself. 