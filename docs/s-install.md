
## TL; DR

![](../_media/how.svg)

[Prepare](#prepare) a **new** node : Linux x86_64 CentOS 7.8.2003, with **root** or **sudo** access

```bash
# download with curl (in case of git not available)
# curl -SL https://github.com/Vonng/pigsty/releases/download/v1.4.0/pigsty.tgz -o ~/pigsty.tgz  
# curl -SL https://github.com/Vonng/pigsty/releases/download/v1.4.0/pkg.tgz    -o /tmp/pkg.tgz
```

[Download](#download) & [Configure](#configure) & [Install](#install)

```
git clone https://github.com/Vonng/pigsty && cd pigsty
./configure
make install
```

Visit `http://<primary_ip>:3000` to visit Pigsty [Home](http://demo.pigsty.cc/d/home) (username: `admin`, password: `pigsty`)

> If you don't have any available nodes, try running [sandbox](s-sandbox.md) on your laptop/macbook.


----------------

## Detail

### Prepare

Prepare a node (vm & vagrant & cloud vps), which will be used as [meta](c-arch.md#meta-node) node (admin controller)

* Kernel: Linux
* Arch: x86_64
* OS: CentOS 7.8.2003 (RHEL 7.x and equivalent is OK)
* SSH accessibility

Pigsty runs in standalone mode by default (runs everything on a single node) 
You can prepare additional nodes for extra postgres clusters/instances.

In real-world large-scale production environments, 3 or more meta nodes are recommended to provide redundancy.



----------------

## Download

**Source [`pigsty.tgz`](t-prepare.md#pigsty-source)**

Source code `pigsty.tgz`（约500 KB）is **required**，can be obtained via `curl` or `git` from Github.

```bash
git clone https://github.com/Vonng/pigsty && cd pigsty
curl -SL https://github.com/Vonng/pigsty/releases/download/v1.4.0/pigsty.tgz -o ~/pigsty.tgz
```

It's typical to unarchive source code to your home dir：`PIGSTY_HOME=~/pigsty`.

If you want to use the latest features, use Git to pull the code, or if you want to keep your environment stable, use `curl` to download a fixed version.


**Package [`pkg.tgz`](t-prepare.md#pigsty-package)**

Pigsty Offline Installation Package `pkg.tgz`（1GB）is **OPTIONAL**, which can be obtained via `curl` from Github.

```bash
curl -SL https://github.com/Vonng/pigsty/releases/download/v1.4.0/pkg.tgz    -o /tmp/pkg.tgz
```

Offline packages placed in the `/tmp/pkg.tgz` path of the target machine will be automatically recognized and used during the configuration process.


----------------

## Configure

Unarchive and enter pigsty source dir with `tar -xf pigsty.tgz && cd pigsty`, then execute `configure` to perform pre-install check.

```bash
. /configure
```

`configure` will check following items. If check fails, it will prompt an error and exit.

```bash
check_kernel     # kernel        = Linux
check_machine    # machine       = x86_64
check_release    # release       = CentOS 7.x
check_sudo       # current_user  = NOPASSWD sudo
check_ssh        # current_user  = NOPASSWD ssh
check_ipaddr     # primary_ip (arg|probe|input)                    (INTERACTIVE: ask for ip)
check_admin      # check current_user@primary_ip nopass ssh sudo
check_mode       # check machine spec to determine node mode (tiny|oltp|olap|crit)
check_config     # generate config according to primary_ip and mode
check_pkg        # check offline installation package exists       (INTERACTIVE: ask for download)
check_repo       # create repo from pkg.tgz if exists
check_repo_file  # create local file repo file if repo exists
check_utils      # check ansible sshpass and other utils installed
check_bin        # check special bin files in pigsty/bin (loki,exporter) (require utils installed)
```

Running `./configure` without args will run in interactive mode. which will prompts 2 questions:


**Primary IP address**

When multiple NICs or multiple IP addresses are detected on the current node,
the wizard prompts you to enter the IP address that **primarily** uses,
that is, the IP address to access the node from the internal network. 
public IP address should NOT be used here.


**Download Offline Package**

When no offline package are found on `/tmp/pkg.tgz`, the wizard will ask if you want to download it from Github.
Selecting `Y` will start the download, selecting `N` will skip it. 
If your node does not have Internet access or if you wish to make your own offline package, choose `N`.


**Configuration Template**

Which config template to use.

The wizard will choose template automatically according to a set of rules. So no question will be asked for this.
While you can always specify it with `-m <mode>`.

* [`demo4`] Project default configuration file, 4-node sandbox
* [`demo`] single-node sandbox, which will be used if the current sandbox VM is detected
* [`tiny`] Single node deployment, this configuration will be used if using normal nodes (micro: cpu < 8) for deployment
* [`oltp`] Production single-node deployment, this configuration is used if you deploy with a normal node (high: cpu >= 8)
* For more configuration templates, please refer to [Configuration Template](https://github.com/Vonng/pigsty/tree/master/files/conf)

**Stdout of configure**

```bash
vagrant@meta:~/pigsty 
$ ./configure
configure pigsty 1.3.1 begin
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
[ OK ] mode = pub4 (manually set)
[ OK ] config = pub4@10.10.10.10
[ OK ] cache = /tmp/pkg.tgz exists
[ OK ] repo = /www/pigsty ok
[ OK ] repo file = /etc/yum.repos.d/pigsty-local.repo
[ OK ] utils = install from local file repo
[ OK ] ansible = ansible 2.9.23
configure pigsty done. Use 'make install' to proceed
```



----------------

## Install

`make install` will init pigsty on meta node(s)

```bash
make install
```

It actually invokes ansible playbook [`infra.yml`](p-infra.md) on `meta` group. 
Which will init infrastructure and a full-featured `pg-meta` postgres cluster.

The installation procedure took about 10 minutes (offline installation, sandbox, 2C|4GB)

> Ansible is already installed during [configure.check_utils](#configure), via `pkg.tgz` or `yum`


### GUI Access

After the installation is complete, you can access Pigsty GUI through [graphic user interface](s-interface.md).

> Visit `http://<primary_ip>:3000` to browse the Pigsty monitoring system home page (username: `admin`, password: `pigsty`)


### Deploy Extra Postgres Cluster (OPTIONAL)

After meta node is initialized, you can initiate control from it. 
E.g: Deploy & Manage new PostgreSQL clusters on other database nodes.

The 4-node [sandbox](s-sandbox.md) have prepared 3 extra nodes for an extra postgres demo cluster: `pg-test`.

Playbook [`pgsql.yml`](p-pgsql.md) is responsible for initializing new postgres cluster:

```bash
. /pgsql.yml -l pg-test
```

You can check that cluster with [【PGSQL Cluster】](http://demo.pigsty.cc/d/pgsql-cluster/pgsql-cluster?var-cls=pg-test) dashboard once playbook is finished.



### Deploy Logging Components (OPTIONAL)

Pigsty comes with a realtime logging collection solution based on [loki](https://grafana.com/oss/loki/) and [promtail](https://grafana.com/docs/loki/latest/clients/promtail/)
It's optional, and not enabled by default. But you can deploy and enable it with two commands:

```bash
./infra-loki.yml        # Install loki     (logging server) on meta node
./pgsql-promtail.yml    # Install promtail (logging agent) on database node
```

Check [Deploying Logging Components](t-logging.md) for details.

