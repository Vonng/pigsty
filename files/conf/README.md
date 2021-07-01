# Configuration Template

This directory (files/conf) contains pigsty configuration templates, Which will be used during `configure` procedure

* pigsty-demo         :   sandbox 1-vm-node demo (default if admin user = vagrant)
* pigsty-demo4        :   sandbox 4-vm-node demo
* pigsty-oltp         :   standard single node setup (default if cpu core >= 8)
* pigsty-tiny         :   standard single node setup (default if cpu core <  8)
* pigsty-demo-pg14    :   same as demo, but use pg14 by default (beta)
* pigsty-demo4-pg14   :   same as demo4, but use pg14 by default (beta)

Templates are named as `pigsty-<mode>.yml`, `<mode>` can be designated using `./configure -m <mode>`

## Templating

For single-node setup, `10.10.10.10` is a special placeholder which will be replaced by your own meta-node PRIMARY ip address

If you have multiple network interface on your meta node, You must choose one manually. 

How to use template ?

you could just run `configure` and follow the interactive wizard, or render it:

```bash
sed_cmd="s/10.10.10.10/${primary_ip}/g"
config_src=${pigsty_home}/files/conf/pigsty-${mode}.yml
config_dst=${pigsty_home}/pigsty.yml
sed -e ${sed_cmd} ${config_src} > ${config_dst}
```