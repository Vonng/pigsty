# Configuration Template

This directory (`files/conf`) contains pigsty configuration templates, Which will be used during `configure` procedure.

Config templates are named as `pigsty-<mode>.yml`.  `<mode>` can be designated using `./configure -m <mode>`

There are several built-in config modes:

### **demo4 (default)** 

[pigsty-demo4.yml](pigsty-demo4.yml) : 4-node sandbox demo configuration file

which have a one-node cluster `pg-meta` on `10.10.10.10`, and a 3-node cluster `pg-test` on `10.10.10.11(node-1)` , `10.10.10.12(node-2)`, `10.10.10.13(node-3)`

If not configured, this is the default configuration file.

### **demo**

[pigsty-demo.yml](pigsty-demo.yml) : 1-node sandbox demo configuration file

Remove the 3-node cluster `pg-test` based on [demo4](#demo4) config.

This will be used if current user = vagrant (which means under demo environment) during **configure**

This means, `configure` with no args means you want to install pigsty on current single node.


### **pg14**

[pigsty-pg14.yml](pigsty-pg14.yml) : 4-node demo with postgres 14 beta

Same as [default](#default) config, except using pg14 for `pg-test`cluster

This config is used for testing PG14 new features.


### **tiny**

[pigsty-tiny.yml](pigsty-tiny.yml) : default single-node tiny template

Use this if you are installing pigsty on your own node/vm. 

Forked from [demo](#demo) config with some modification:
  * dns nameserver disabled, because you may have pre-configured DNS settings 
  * vip disabled, because your network condition is not determined.
  * `dcs_exists_action: abort`: from `clean` to `abort` to avoid accidentally destroy dcs server
  * `pg_exists_action: abort`: from `clean` to `abort` to avoid accidentally destroy postgres

Will automatically be chosen during configure when:
  * current os user name != vagrant (which means it's not demo env)
  * current cpu core < 8 (which means it's a tiny node, otherwise `oltp` will be used)

### **oltp**

[pigsty-oltp.yml](pigsty-oltp.yml) : default single-node tiny template

Use this if you are installing pigsty on your production environment

Forked from [tiny](#tiny) config with default node & pgsql template set to `oltp`

Will automatically be chosen during configure when:
  * current os user name != vagrant (which means it's not demo env)
  * current cpu core >= 8 (which means the spec is good enough for production setup)



```
 [demo4]   (home default)   
    ↓        configure
    ↓--------------------------↓--------------------------↓
    ↓                          ↓                          ↓ 
    ↓ reduce to 1-node         ↓ use pg14                 ↓ 
    ↓                          ↓                          ↓ 
  [demo]                     [pg14]                     [pub4]
    ↓
    ↓ disable vip & dns
    ↓
  [tiny]
    ↓       
    ↓ have more cpu cores (>=8)
    ↓
  [oltp]

```





## Templating

There are some placeholder values in configuration: Such as meta node ip address. which is hard-coded as `10.10.10.10`.

It will be REPLACED to actual ip address during `configure` with `sed`.

you could just run `configure` and follow the interactive wizard, or render it with `sed` manully:

```bash
sed_cmd="s/10.10.10.10/${primary_ip}/g"
config_src=${pigsty_home}/files/conf/pigsty-${mode}.yml
config_dst=${pigsty_home}/pigsty.yml
sed -e ${sed_cmd} ${config_src} > ${config_dst}
```

