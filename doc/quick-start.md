# Quick Start

3 steps to launch pigsty: **download**, **configure**, **install**

### Download

```bash
cd ~ && curl -fsSLO https://github.com/Vonng/pigsty/releases/download/latest/pigsty.tgz && tar -xf pigsty.tgz && cd pigsty
curl -fSL  https://github.com/Vonng/pigsty/releases/download/latest/pkg.tgz    -o /tmp/pkg.tgz 
```

### Configure

```bash
./configure
```

### Install

```bash
./infra.yml
```

That's it!



### Now what?

* Visit GUI: http://10.10.10.10:3000  username: `admin` , password: `pigsty`
* Make some load and monitoring it!

```
make ri      # init pgbench on pg-meta
make rw      # add some read-write load to pg-meta
make ro      # add some read-only load to pg-meta
```

* Visit Pigsty [Official Site](https://pigsty.cc) and explore all features.



## Detail Explained

TBD
