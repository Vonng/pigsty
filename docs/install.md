## Short Version

![](_media/how.svg)

Download with `curl` (`pigsty.tgz` can be cloned with `git`, `pkg.tgz` is optional cache for accelerating)

```bash
curl -SL https://github.com/Vonng/pigsty/releases/download/v1.0.0/pigsty.tgz -o ~/pigsty.tgz  
curl -SL https://github.com/Vonng/pigsty/releases/download/v1.0.0/pkg.tgz    -o /tmp/pkg.tgz
```

Download & Configure & Install

```bash
git clone https://github.com/Vonng/pigsty && cd pigsty
./configure
make install
```

Browser `http://<node_ip>:3000` to visit Pigsty [Home](http://g.pigsty.cc/d/home) (username: `admin`, password: `pigsty`)

<iframe style="height:1160px" src="http://g.pigsty.cc/d/home"></iframe>



## Detail

### Prepare

Get a node (vm & vagrant & cloud vps).
* Kernel: Linux
* Arch: x86_64
* OS: CentOS 7.8.2003 (RHEL 7.x and equivalent is OK) 

Execute with `root` or admin user with nopass `sudo` privilege


### Download

Get the latest master updates with `git clone`

```bash
cd ~ && git clone https://github.com/Vonng/pigsty
```

**Or** download stable version release directly

```bash
cd ~ && curl -fsSLO https://github.com/Vonng/pigsty/releases/download/v1.0.0-beta1/pigsty.tgz && tar -xf pigsty.tgz && cd pigsty 
```

Download offline installation packages if you are in bad network condition (e.g Mainland China) [optional]

```bash
curl -fSL  https://github.com/Vonng/pigsty/releases/download/latest/pkg.tgz    -o /tmp/pkg.tgz
```


Check [download](download.md) if having problem download pigsty from Github



### Configure

```bash
./configure
```

It will launch an interactive (or non-interactive with `-n`) cli wizard for env checking & pre-installation works 

Typical output would be:

```bash
[0715] vagrant@meta:~/pigsty
$ ./configure
configure pigsty v1.0.0-alpha2 begin
[ OK ] kernel = Linux
[ OK ] machine = x86_64
[ OK ] release = 7.8.2003 , perfect
[ OK ] sudo = vagrant ok
[ OK ] ssh = vagrant@127.0.0.1 ok
[WARN] Multiple IP address candidates found:
    (1) 10.0.2.15	    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
    (2) 10.10.10.10	    inet 10.10.10.10/24 brd 10.10.10.255 scope global noprefixroute eth1
    (3) 10.10.10.2	    inet 10.10.10.2/8 scope global eth1
[ OK ] primary_ip = 10.10.10.10 (from demo)
[ OK ] admin = vagrant@10.10.10.10 ok
[ OK ] mode = demo (vagrant demo)
[ OK ] config = demo@10.10.10.10
[ OK ] cache = /tmp/pkg.tgz exists
[ OK ] repo = /www/pigsty ok
[ OK ] repo file = /etc/yum.repos.d/pigsty-local.repo
[ OK ] utils = install from local file repo
[ OK ] ansible = ansible 2.9.23
[ OK ] bin = extract from /www/pigsty
[ OK ] loki @ /home/vagrant/pigsty/files/bin
configure pigsty done. Use 'make install' to proceed
```



### Install

```bash
make install
```

which actually does:

```bash
./infra.yml
```

It will setup everything on your meta node.



### Explore

#### View Graphic Interface

* Main GUI are served @ port 3000
* Visit GUI: http://10.10.10.10:3000  username: `admin` , password: `pigsty`


#### Make some noisy !

* Make some load and monitoring from GUI

```
make ri      # init pgbench on pg-meta
make rw      # add some read-write load to pg-meta
make ro      # add some read-only load to pg-meta
```


### Logging

These commands will install *[optional]* realtime logging collector on you pgsql nodes.

Check [logging.md](logging.md) for more detail.

```bash
./infra-loki.yml
./pgsql-promtail.yml
```



### Upgrade Grafana

You can go through pigsty operational tasks with this tutorial: [Upgrade Grafana](grafana-upgrade.md)

It will replace default sqlite3 file database with pg-meta postgres databaes. 




### Deploy more clusters

You can deploy more database cluster with `pgsql.yml`. 

`pigsty-demo4.yml` is an example that deploys an extra 3-node cluster named `pg-test`

Inside sandbox, You can also add some traffic to this cluster to monitoring it from dashboards.

```bash
make test-ri      # init pgbench on pg-test
make test-rw        # add some read-write load to pg-test
make test-ro        # add some read-only load to pg-test
```

### What's Next

**Visit Pigsty [Official Site](https://pigsty.cc) to explore more features and fun tasks.**

