# Quick Start

3 steps to launch pigsty: **download**, **configure**, **install**

### Download

```bash
cd ~ && curl -fsSLO https://github.com/Vonng/pigsty/releases/download/latest/pigsty.tgz && tar -xf pigsty.tgz && cd pigsty
curl -fSL  https://github.com/Vonng/pigsty/releases/download/latest/pkg.tgz    -o /tmp/pkg.tgz 
```

Check [download](download.md) if having problem download pigsty from Github (Especially for mainland China)

### Configure

```bash
./configure
```

It will launch an interactive (or non-interactive with `-n`) cli wizard for env checking & pre-installation works 

### Install

```bash
./infra.yml
```

It will setup everything on your meta node

That's it!



### Now what?

* Visit GUI: http://10.10.10.10:3000  username: `admin` , password: `pigsty`
* Make some load and monitoring it!

```
make ri      # init pgbench on pg-meta
make rw      # add some read-write load to pg-meta
make ro      # add some read-only load to pg-meta
```


### Wants More?

If you have 4 vm nodes: 

`./pgsql.yml -l pg-test` will deploy an extra 3-node pgsql cluster `pg-test`.

You can also add some traffic to this cluster

```bash
make test-init      # init pgbench on pg-test
make test-rw        # add some read-write load to pg-test
make test-ro        # add some read-only load to pg-test
```

### What's Next

**Visit Pigsty [Official Site](https://pigsty.cc) to explore more features and fun tasks.**


