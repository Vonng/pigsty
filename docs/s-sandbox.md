## Sandbox

Pigsty is shipped with an battery-included sandbox environment which could run on your laptop with one-click.

## Introduction

Pigsty sandbox relies on [Virtualbox](https://www.virtualbox.org/) vm nodes (default: 1, full mode: 4) hosted by [Vagrant](https://www.vagrantup.com/).

You have to install both virtualbox & vagrant on your host before launching Pigsty Sandbox.
Both are free & open source cross-platform software.

You can also run pigsty sandbox with hand-made, cloud provisioned vm nodes, or using bare metal directly.

Pigsty sandbox have two different specs:
   * 1 node version : default spec 
   * 4 node version : complete version of pigsty demo

The [1-node](https://github.com/Vonng/pigsty/blob/master/files/conf/pigsty-demo.yml) sandbox can be used for dev, test, doing experiment, learning postgres, etc...
It can setup a environment for data analysis and visualization, and for designing, demonstrating, distributing interactive data [applications](t-application.md).

The [4-node](https://github.com/Vonng/pigsty/blob/master/files/conf/pigsty-demo4.yml) sandbox can be used for complete demonstration of Pigsty's features. 
You can test high availability behaviors, perform failover/switchover drills, experiment with different replication architecture.


## Quick Start

1. Make sure [Vagrant](https://www.vagrantup.com/) and [Virtualbox](https://www.virtualbox.org/) are installed and viable, just follow the official wizard (reboot required).
2. [Download](s-install.md#download) pigsty to **host** & enter pigsty source directory, execute `make start` to pull up the vm nodes.
3. execute `make demo` on the host to start automatic installation of the default single-node sandbox
4. (Optional) Add static DNS records to access Pigsty Web UI via domain name

The sandbox can be pulled up with a single click on MacOS operating systems and requires a few extra manual steps on Windows and Linux.
The following four ``make`` shortcuts can be used in MacOS to install software dependencies, configure local static DNS, pull up the virtual machine, and perform the installation.

```bash
make deps    # Install homebrew and install vagrant and virtualbox via homebrew (requires reboot)
make dns     # Write static domain name to local /etc/hosts (requires sudo password)
make start   # Pull up a single meta node with Vagrant (start4 is 4 nodes)
make demo    # Configure and install using a single node demo (demo4 is a 4 node demo)
```



## Architecture

The sandbox environment uses a fixed IP address for demonstration purposes. The node IP address for a single-node sandbox is fixed to: `10.10.10.10`.

> 10.10.10.10 is a placeholder for the IP address in all profile templates, which will be used as the actual IP address of the management node when performing a normal deployment

Regardless of the sandbox, there will be a management node `meta` with a single instance Postgres database `pg-meta` deployed on the node.

* `meta 10.10.10.10 pg-meta.pg-meta-1`


In a four-node sandbox environment with three additional database nodes, a three-node set of database clusters `pg-test` will be deployed

* `node-1 10.10.10.11 pg-test.pg-test-1`
* `node-2 10.10.10.12 pg-test.pg-test-2`
* `node-3 10.10.10.13 pg-test.pg-test-3`

Also, the sandbox environment will use the following two IP addresses with two static DNS records for accessing the database cluster.

* `10.10.10.2 pg-meta`
* `10.10.10.2 pg-test`

The entire sandbox environment (four nodes) is structured as shown in the following figure.

![](_media/SANDBOX.gif)

Single-node sandbox i.e. without the three additional nodes on the right side of the diagram above, there is only a single management node on the left half.

## Using a 4-node sandbox

Replace the two commands for pulling up the sandbox with the following commands to pull up a 4-node sandbox environment.

```bash
make start4 
make demo4
```


## Other operating systems

For other operating systems, you need to download and install Vagrant and Virtualbox, configure static DNS domain name, the rest of the steps are the same as MacOS.

```bash
make start && make demo
```



## DNS configuration

Pigsty accesses all web systems via **domain** by default. The static DNS records used by the sandbox environment are shown below.

```bash
# pigsty dns records
10.10.10.10  meta     # sandbox meta node
10.10.10.11  node-1   # sandbox node node-1
10.10.10.12  node-2   # sandbox node node-2
10.10.10.13  node-3   # sandbox node node-3
10.10.10.2   pg-meta  # sandbox vip for pg-meta
10.10.10.3   pg-test  # sandbox vip for pg-test

10.10.10.10 pigsty
10.10.10.10 y.pigsty yum.pigsty
10.10.10.10 c.pigsty consul.pigsty
10.10.10.10 g.pigsty grafana.pigsty
10.10.10.10 p.pigsty prometheus.pigsty
10.10.10.10 a.pigsty alertmanager.pigsty
10.10.10.10 n.pigsty ntp.pigsty
10.10.10.10 h.pigsty haproxy.pigsty
10.10.10.10 s.pigsty server.pigsty
```

In MacOS and Linux, running `make dns` will write the above records to `/etc/hosts` (requires sudo privileges), in Windows, you need to add them manually to: `C:\Windows\System32\drivers\etc\hosts`.