
## TL; DR

![](../_media/how.svg)

Prepare a new node : Linux x86_64 CentOS 7.8.2003, with root or sudo access

```bash
# download with curl (in case of git not available)
# curl -SL https://github.com/Vonng/pigsty/releases/download/v1.0.0/pigsty.tgz -o ~/pigsty.tgz  
# curl -SL https://github.com/Vonng/pigsty/releases/download/v1.0.0/pkg.tgz    -o /tmp/pkg.tgz
```

Download & Configure & Install

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

Prepare a node (vm & vagrant & cloud vps), which will be used as [meta](c-arch.md#meta) node (admin controller)

* Kernel: Linux
* Arch: x86_64
* OS: CentOS 7.8.2003 (RHEL 7.x and equivalent is OK)
* SSH accessibility

**Pigsty runs in standalone mode on a single meta node by default**. 
You can prepare additional nodes for extra postgres clusters/instances.

In large-scale production environments, three or more management nodes are typically deployed to provide redundancy.

----------------

## Download

**Source [`pigsty.tgz`](t-prepare.md#pigsty-source)**

Source code `pigsty.tgz`（约500 KB）is **required**，can be obtained via `curl` or `git` from Github.

```bash
git clone https://github.com/Vonng/pigsty && cd pigsty
curl -SL https://github.com/Vonng/pigsty/releases/download/v1.0.0/pigsty.tgz -o ~/pigsty.tgz
```

It's typical to unarchive source code to your home dir：`PIGSTY_HOME=~/pigsty`.

If you want to use the latest features, use Git to pull the code, or if you want to keep your environment stable, use `curl` to download a fixed version.


**Package [`pkg.tgz`](t-prepare.md#pigsty-package)**

Pigsty Offline Installation Package `pkg.tgz`（1GB）is **OPTIONAL**, which can be obtained via `curl` from Github.

```bash
curl -SL https://github.com/Vonng/pigsty/releases/download/v1.0.0/pkg.tgz    -o /tmp/pkg.tgz
```

Offline packages placed in the `/tmp/pkg.tgz` path of the target machine will be automatically recognized and used during the configuration process.


----------------

## Configure

Unzip and go to the pigsty source directory: ``tar -xf pigsty.tgz && cd pigsty`` and execute the following command to start [configuration](v-config).

```bash
. /configure
```

Executing `configure` will check for the following things, minor problems will be automatically attempted to be fixed, otherwise it will prompt an error to exit.

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

Running directly `. /configure` will launch an interactive command line wizard that prompts the user to answer the following three questions.


**IP address**

When multiple NICs with multiple IP addresses are detected on the current machine, the configuration wizard prompts you to enter the IP address that **primarily** uses
that is, the IP address you use to access the node from the internal network. Note that you should not use a public IP address.

**Download Package**

When no offline packages are found in the `/tmp/pkg.tgz` path of the node, the configuration wizard will ask if you want to download them from Github.
Selecting `Y` will start the download, selecting `N` will skip it. If your node has good Internet access with a suitable proxy configuration, or if you need to make your own offline packages, you can choose `N`.

**Configuration Template**

What configuration file template to use.

The configuration wizard automatically selects a configuration template** based on the current machine environment **, but users can manually specify the configuration template to use with `-m <mode>`, for example.

* [`demo4`] Project default configuration file, 4-node sandbox
* [`demo`] single-node sandbox, which will be used if the current sandbox VM is detected
* [`tiny`] Single node deployment, this configuration will be used if using normal nodes (micro: cpu < 8) for deployment
* [`oltp`] Production single-node deployment, this configuration is used if you deploy with a normal node (high: cpu >= 8)
* For more configuration templates, please refer to [Configuration Template](https://github.com/Vonng/pigsty/tree/master/files/conf)

**Standard output of the configuration process**


```bash
vagrant@meta:~/pigsty 
$ ./configure
configure pigsty v1.0.0 begin
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

`make install` will call Ansible to execute the [`infra.yml`](p-infra) script to complete the installation on the `meta` grouping.

```bash
make install
```

The full installation took about 10 minutes in a sandbox environment 2-core 4GB VM.

> In the `. /configure` process, Ansible is already installed via offline packages or available yum sources.


### Accessing the GUI

After the installation is complete, you can access Pigsty-related services through the [user interface](s-interface.md).

> Visit `http://<node_ip>:3000` to browse the Pigsty monitoring system home page (username: `admin`, password: `pigsty`)


### Deploy additional database clusters (optional)

In a 4-node sandbox, you can execute the [``pgsql.yml`'' (p-pgsql) script to complete the deployment of the ``pg-test`' cluster by

```bash
. /pgsql.yml -l pg-test
```

Once the script is executed, you can browse the cluster details in the monitoring system. [Check Demo](http://demo.pigsty.cc/d/pgsql-cluster/pgsql-cluster?var-cls=pg-test)


### Deploy additional log collection components (optional)

Pigsty comes with a live log collection solution based on Loki and Promtail, but it is not enabled by default and you need to enable it manually.

```bash
. /infra-loki.yml # Install loki (logging server) on the management node
. /pgsql-promtail.yml # Install promtail (Logging Agent) on the database node
```

See [deploying log collection service](t-logging.md) for details


----------------

## What's Next?

You can start by browsing the official [demo](s-demo.md) site of the Pigsty monitoring system: [http://demo.pigsty.cc](http://demo.pigsty.cc) to get a general impression.

> The Pigsty demo contains two interesting data applications: the WHO New Crown Epidemic Data Big Board: [`covid`](http://demo.pigsty.cc/d/covid-overview), with a global surface weather station historical data query: [`isd`](http://demo.pigsty.cc/ d/isd-overview)

You can try to run Pigsty locally, e.g. via [sandbox environment](s-sandbox.md), or directly [prepare](t-prepare.md) virtual/physical machines for standard [deployment](t-deploy.md).

If you wish to understand the design and concepts of Pigsty, you can refer to the following topics: [architecture](c-arch.md), [entity](c-entity.md), [configuration](c-config.md), [service](c-service.md), [database](c-database.md), [users](c- user.md), [privileges](c-privilege.md), [authentication](c-auth.md), [access](c-access.md)

You can learn how to deploy, manage, and access database clusters, instances, users, DBs, and services with the **Tutorial**. The tutorial [[Using Postgres as a Grafana backend database]](t-grafana-upgrade.md) will go through a complete example of how to create a new database cluster using the control primitives provided by Pigsty, create a new business database with users in an existing cluster, and the specific ways to use that database.

