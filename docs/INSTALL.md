# Get Started

> [中文/ZH](INSTALL_ZH.md) : Install Pigsty with 4 steps: [Download](#download), [Bootstrap](#bootstrap), [Configure](#configure) and [Install](#install).


## Short Version

Prepare a new node with Linux x86_64 EL compatible OS, then run as a **sudo-able** user:

```bash
bash -c "$(curl -fsSL http://get.pigsty.cc/latest)"  
cd ~/pigsty   # get pigsty source and entering dir
./bootstrap   # download bootstrap pkgs & ansible [optional]
./configure   # pre-check and config templating   [optional] 
./install.yml # install pigsty according to pigsty.yml
```

Then you will have a pigsty singleton node ready, with Web Services on port `80` and Postgres on port `5432`.

[![asciicast](https://asciinema.org/a/566220.svg)](https://asciinema.org/a/566220)


<details><summary>Download with Get</summary>

```bash
$ curl http://get.pigsty.cc/latest | bash
...
[Checking] ===========================================
[ OK ] SOURCE from CDN due to GFW
FROM CDN    : bash -c "$(curl -fsSL http://get.pigsty.cc/latest)"
FROM GITHUB : bash -c "$(curl -fsSL https://raw.githubusercontent.com/Vonng/pigsty/master/bin/get)"
[Downloading] ===========================================
[ OK ] download pigsty source code from CDN
[ OK ] $ curl -SL http://get.pigsty.cc/v2.2.0/pigsty-v2.2.0.tgz
...
MD5: abcdef1234567890abcdef1234567890  /tmp/pigsty-v2.2.0.tgz
[Extracting] ===========================================
[ OK ] extract '/tmp/pigsty-v2.2.0.tgz' to '/root/pigsty'
[ OK ] $ tar -xf /tmp/pigsty-v2.2.0.tgz -C ~;
cd ~/pigsty      # entering pigsty home directory before proceeding
[Proceeding] ===========================================
./bootstrap      # install ansible & download the optional offline packages
./configure      # preflight-check and generate config according to your env
./install.yml    # install pigsty on this node and init it as the admin node
[Reference] ===========================================
Get Started:     https://vonng.github.io/pigsty/#/INSTALL
Documentation:   https://vonng.github.io/pigsty
Github Repo:     https://github.com/Vonng/pigsty
Public Demo:     http://demo.pigsty.cc
Official Site:   https://pigsty.cc
```

</details>


<details><summary>Download with Git</summary>

You can also download pigsty source with `git`, don't forget to checkout a specific version.

```bash
git clone https://github.com/Vonng/pigsty;
cd pigsty; git checkout v2.2.0
```

</details>


<details><summary>Download Directly</summary>

You can also download pigsty source & offline pkgs directly from GitHub release page. 

```bash
# get from GitHub
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Vonng/pigsty/master/bin/get)"

# or download tarball directly with curl
curl -L https://github.com/Vonng/pigsty/releases/download/v2.2.0/pigsty-v2.2.0.tgz -o ~/pigsty.tgz                 # SRC
curl -L https://github.com/Vonng/pigsty/releases/download/v2.2.0/pigsty-pkg-v2.2.0.el9.x86_64.tgz -o /tmp/pkg.tgz  # EL9
curl -L https://github.com/Vonng/pigsty/releases/download/v2.2.0/pigsty-pkg-v2.2.0.el8.x86_64.tgz -o /tmp/pkg.tgz  # EL8
curl -L https://github.com/Vonng/pigsty/releases/download/v2.2.0/pigsty-pkg-v2.2.0.el7.x86_64.tgz -o /tmp/pkg.tgz  # EL7
```

</details>




-----------------------

## Requirement

**OS**

* Linux RHEL or other compatible distributions
* Vendor: RHEL, CentOS, Rocky, AlmaLinux, ...
* Version: el7, el8, el9
* Please use fresh nodes for installation to avoid unexpected issues 
* It's recommended to RockeyLinux 9 and CentOS 7.9 for production use

**Node**

* `x86_64` architecture (`aarch64/arm64` is not officially supported yet)
* 1 core & 1 GB RAM (at least 2GB mem for the admin node)
* nopass `ssh` access to `root` or any sudo-able user on target nodes (including current node)
* At least 3 nodes for a serious HA deployment, or 2 nodes with some limitations

**Ansible**

* Ansible is required and will be installed during [`bootstrap`](#bootstrap) procedure
* You can also manually install with `yum,` and `epel-release` enabled



-----------------------

## Download

You can get & extract pigsty source via the following command:

```bash
curl -fsSL http://get.pigsty.cc/latest  | bash
```

> HINT: Get the latest beta release with `beta` instead of `latest`.

<details><summary>Download Pigsty Source with Specific Version</summary>

If you want to download a specific version, use the following URLs:

```bash
VERSION=v2.2.0
https://github.com/Vonng/pigsty/releases/download/${VERSION}/pigsty-${VERSION}.tgz
```

For example, Pigsty v2.2.0 source can be acquired with:

```bash 
curl -L https://github.com/Vonng/pigsty/releases/download/v2.2.0/pigsty-v2.2.0.tgz -o ~/pigsty.tgz
curl -L http://get.pigsty.cc/v2.2.0/pigsty-v2.2.0.tgz -o ~/pigsty.tgz   # China CDN Mirror
```

</details>


### Offline Packages

Pigsty downloads rpm packages from the upstream yum repo during installation.
Which can be accelerated dramatically by using a local mirror: offline packages.
It's also extremely useful when you have no Internet available.

The [`bootstrap`](#bootstrap) script will ask for download the corresponding offline package (`--yes|--no`) and setup everything up for you.
You can also download it manually and put it under `/tmp/pkg.tgz` for later use.

<details><summary>Download offline packages manually</summary>

```bash
VERSION=v2.2.0
OS_VERSION=$(rpm -q --qf "%{VERSION}" $(rpm -q --whatprovides redhat-release) | grep -o '^[^.]\+')
ARCH=$(uname -m)
FILENAME=pigsty-pkg-${VERSION}.el${OS_VERSION}.${ARCH}.tgz
PKG_URL="https://github.com/Vonng/pigsty/releases/download/${VERSION}/${FILENAME}"
echo ${PKG_URL} && curl -L ${PKG_URL} -o /tmp/pkg.tgz
```

For example, Pigsty v2.2.0 on EL7.x86_64 will have the following packages: 

```bash
curl -L https://github.com/Vonng/pigsty/releases/download/v2.2.0/pigsty-pkg-v2.2.0.el7.x86_64.tgz  -o /tmp/pkg.tgz
curl -L http://get.pigsty.cc/v2.2.0/pigsty-pkg-v2.2.0.el7.x86_64.tgz -o /tmp/pkg.tgz  # China CDN Mirror
```

> Not all combinations of OS and architecture are supported yet. Please check the official release page.

</details>









-----------------------

## Bootstrap

`bootstrap` script will make sure one thing: `ansible` is ready for using. 

It will also download / extract / setup the offline [packages](#offline-packages) if you choose to do so.

```bash
./boostrap [-p <path>=/tmp/pkg.tgz]   # offline pkg path (/tmp/pkg.tgz by default)
           [-y|--yes] [-n|--no]       # download packages or not? (ask by default)
```

> HINT: `bootstrap` is **OPTIONAL** if you already have `ansible` and plan to download rpm packages from upstream directly.

<details><summary>bootstrap procedure detail</summary>

1. Check preconditions

2. Check local repo exists ?
   * Y -> create `/etc/yum.repos.d/pigsty-local.repo` to enable it
   * N -> Download offline package from the Internet? 
     * Y -> Download from Github / CDN and extract & enable it
     * N -> Add basic os upstream repo file manually ?
          * Y -> add according to region / releasever
          * N -> leave it to user's default configuration
  * Now we have an available repo for installing ansible
    * Precedence: local `pkg.tgz` > downloaded `pkg.tgz` > upstream > user provide

3. install boot utils from the available repo

   * el7,8,9: `nginx wget sshpass createrepo_c yum-utils python2-jmespath`
   * el8 extra: `dnf-utils modulemd-tools python3.11-jmespath`
   * el9 extra: `dnf-utils modulemd-tools python3.11-jmespath`

4. Check ansible availability.

</details>


<details><summary>bootstrap from local packages output</summary>

If `/tmp/pkg.tgz` already exists, bootstrap will use it directly:

```bash
bootstrap pigsty v2.2.0 begin
[ OK ] region = china
[ OK ] kernel = Linux
[ OK ] machine = x86_64
[ OK ] release = 7.9.2009
[ OK ] sudo = vagrant ok
[ OK ] cache = /tmp/pkg.tgz exists
[ OK ] repo = extract from /tmp/pkg.tgz
[ OK ] repo file = use /etc/yum.repos.d/pigsty-local.repo
[ OK ] repo cache = created
[ OK ] install el7 utils
....(yum install ansible output)
[ OK ] ansible = ansible 2.9.27
[ OK ] boostrap pigsty complete
proceed with ./configure
```

</details>

<details><summary>bootstrap download from internet output</summary>

Download `pkg.tgz` from Github and extract it:

```bash
bootstrap pigsty v2.2.0 begin
[ OK ] region = china
[ OK ] kernel = Linux
[ OK ] machine = x86_64
[ OK ] release = 7.9.2009
[ OK ] sudo = vagrant ok
[ IN ] Cache /tmp/pkg.tgz not exists, download? (y/n):
=> y
[ OK ] download from Github http://get.pigsty.cc/v2.2.0/pigsty-pkg-v2.2.0.el7.x86_64.tgz to /tmp/pkg.tgz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  913M  100  913M    0     0   661k      0  0:23:33  0:23:33 --:--:--  834k
[ OK ] repo = extract from /tmp/pkg.tgz
[ OK ] repo file = use /etc/yum.repos.d/pigsty-local.repo
[ OK ] repo cache = created
[ OK ] install el7 utils
...... (yum install createrepo_c sshpass unzip output) 
==================================================================================================================
 Package                        Arch                Version                       Repository                 Size
==================================================================================================================
Installing:
 createrepo_c                   x86_64              0.10.0-20.el7                 pigsty-local               65 k
 sshpass                        x86_64              1.06-2.el7                    pigsty-local               21 k
 unzip                          x86_64              6.0-24.el7_9                  pigsty-local              172 k
Installing for dependencies:
 createrepo_c-libs              x86_64              0.10.0-20.el7                 pigsty-local               89 k

Transaction Summary
==================================================================================================================
...... (yum install ansible output)
==================================================================================================================
 Package                                      Arch            Version                 Repository             Size
==================================================================================================================
Installing:
 ansible                                      noarch          2.9.27-1.el7            pigsty-local           17 M
Installing for dependencies:
 PyYAML                                       x86_64          3.10-11.el7             pigsty-local          153 k
 libyaml                                      x86_64          0.1.4-11.el7_0          pigsty-local           55 k
 python-babel                                 noarch          0.9.6-8.el7             pigsty-local          1.4 M
 python-backports                             x86_64          1.0-8.el7               pigsty-local          5.8 k
 python-backports-ssl_match_hostname          noarch          3.5.0.1-1.el7           pigsty-local           13 k
 python-cffi                                  x86_64          1.6.0-5.el7             pigsty-local          218 k
 python-enum34                                noarch          1.0.4-1.el7             pigsty-local           52 k
 python-idna                                  noarch          2.4-1.el7               pigsty-local           94 k
 python-ipaddress                             noarch          1.0.16-2.el7            pigsty-local           34 k
 python-jinja2                                noarch          2.7.2-4.el7             pigsty-local          519 k
 python-markupsafe                            x86_64          0.11-10.el7             pigsty-local           25 k
 python-paramiko                              noarch          2.1.1-9.el7             pigsty-local          269 k
 python-ply                                   noarch          3.4-11.el7              pigsty-local          123 k
 python-pycparser                             noarch          2.14-1.el7              pigsty-local          104 k
 python-setuptools                            noarch          0.9.8-7.el7             pigsty-local          397 k
 python-six                                   noarch          1.9.0-2.el7             pigsty-local           29 k
 python2-cryptography                         x86_64          1.7.2-2.el7             pigsty-local          502 k
 python2-httplib2                             noarch          0.18.1-3.el7            pigsty-local          125 k
 python2-jmespath                             noarch          0.9.4-2.el7             pigsty-local           41 k
 python2-pyasn1                               noarch          0.1.9-7.el7             pigsty-local          100 k

Transaction Summary
==================================================================================================================
...
Complete!
[ OK ] ansible = ansible 2.9.27
[ OK ] boostrap pigsty complete
proceed with ./configure
```

</details>





-----------------------

## Configure

[`configure`](Config) will create a [`pigsty.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml) config file according to your environment.

```bash
./configure [-n|--non-interactive] [-i|--ip <ipaddr>] [-m|--mode <name>] [-r|--region <default|china|europe>]
```

* `-m|--mode`: Generate config from [templates](https://github.com/Vonng/pigsty/tree/master/files/pigsty) according to `mode`: (`auto|demo|sec|citus|el8|el9|...`)
* `-i|--ip`: Replace IP address placeholder `10.10.10.10` with your primary ipv4 address of current node.
* `-r|--region`: Set upstream repo mirror according to `region` (`default|china|europe`)
* `-n|--non-interactive`: skip interactive wizard and using default/arg values

When `-n|--non-interactive` is specified, you have to specify a primary IP address with `-i|--ip <ipaddr>` in case of multiple IP address, since there's no default value for primary IP address in this case.

?> HINT: `configure` is **OPTIONAL** if you know how to [configure](CONFIG.md) pigsty manually.


<details><summary>configure example output</summary>

```bash
[vagrant@meta pigsty]$ ./configure
configure pigsty v2.2.0 begin
[ OK ] region = china
[ OK ] kernel = Linux
[ OK ] machine = x86_64
[ OK ] sudo = vagrant ok
[ OK ] ssh = vagrant@127.0.0.1 ok
[WARN] Multiple IP address candidates found:
    (1) 10.0.2.15	    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
    (2) 10.10.10.10	    inet 10.10.10.10/24 brd 10.10.10.255 scope global noprefixroute eth1
[ OK ] primary_ip = 10.10.10.10 (from demo)
[ OK ] admin = vagrant@10.10.10.10 ok
[ OK ] mode = demo (vagrant demo)
[ OK ] config = demo @ 10.10.10.10
[ OK ] ansible = ansible 2.9.27
[ OK ] configure pigsty done
proceed with ./install.yml
```

</details>





-----------------------

## Install

You can run [`install.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml) to perform a full installation on current node

```bash
./install.yml    # install everything in one-pass
```

It's a standard ansible playbook, you can have fine-grained control with ansible options:

* `-l`: limit execution targets
* `-t`: limit execution tasks
* `-e`: passing extra args
* ...

Check playbooks for more available functionalities.

> **WARNING: It's very DANGEROUS to run [`install.yml`](https://github.com/Vonng/pigsty/blob/master/install.yml) on existing deployment!**


<details><summary>Installation Output Example</summary>

```bash
[vagrant@meta pigsty]$ ./install.yml

PLAY [IDENTITY] ********************************************************************************************************************************

TASK [node_id : get node fact] *****************************************************************************************************************
changed: [10.10.10.12]
changed: [10.10.10.11]
changed: [10.10.10.13]
changed: [10.10.10.10]
...
...
PLAY RECAP **************************************************************************************************************************************************************************
10.10.10.10                : ok=288  changed=215  unreachable=0    failed=0    skipped=64   rescued=0    ignored=0
10.10.10.11                : ok=263  changed=194  unreachable=0    failed=0    skipped=88   rescued=0    ignored=1
10.10.10.12                : ok=263  changed=194  unreachable=0    failed=0    skipped=88   rescued=0    ignored=1
10.10.10.13                : ok=153  changed=121  unreachable=0    failed=0    skipped=53   rescued=0    ignored=1
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0
```

</details>




-----------------------

## Interface

Once installed, you'll have 4 module [**INFRA**](INFRA.md), [**NODE**](NODE.md), [**ETCD**](ETCD.md) , [**PGSQL**](PGSQL.md) installed on the current node. 

* [**INFRA**](INFRA.md): Monitoring infrastructure can be accessed via `http://<ip>:80`
* [**PGSQL**](PGSQL.md): PostgreSQL cluster can be accessed via default PGURL: `postgres://dbuser_meta:DBUser.Meta@<ip>:5432/meta`

There are several services are exposed by Nginx (configured by [`infra_portal`](PARAM.md#infra_portal)):

|    Component  | Port |    Domain    |     Comment              |     Public Demo          |
| :-----------: | :--: | :----------: | ------------------------ | ------------------------ |
|     Nginx     |  80  |  `h.pigsty`  | Web Service Portal, Repo |  [`home.pigsty.cc`](http://home.pigsty.cc) |
| AlertManager  | 9093 |  `a.pigsty`  | Alter Aggregator         |  [`a.pigsty.cc`](http://a.pigsty.cc) |
|    Grafana    | 3000 |  `g.pigsty`  | Grafana Dashboard Home   |  [`demo.pigsty.cc`](http://demo.pigsty.cc) |
|  Prometheus   | 9090 |  `p.pigsty`  | Prometheus Web UI        |  [`p.pigsty.cc`](http://p.pigsty.cc) |

You can configure public domain names for these infra services or just use local static DNS records & resolver.
e.g., write records to `/etc/hosts` and access via DNS.

If [`nginx_sslmode`](PARAM.md#nginx_sslmode) is set to `enabled` or `enforced`, you can trust self-signed ca: `files/pki/ca/ca.crt` to use `https` in your browser.

```
http://g.pigsty ️-> http://10.10.10.10:80 (nginx) -> http://10.10.10.10:3000 (grafana)
```




> Default credential for grafana: username: `admin`, password: `pigsty`



-----------------------

## More

You can deploy & monitor more clusters with pigsty: add more nodes to `pigsty.yml` and run corresponding playbooks:

```bash
bin/node-add   pg-test      # init 3 nodes of cluster pg-test
bin/pgsql-add  pg-test      # init HA PGSQL Cluster pg-test
bin/redis-add  redis-ms     # init redis cluster redis-ms
```

Check [**PGSQL**](PGSQL.md), [**NODE**](NODE.md), and [**REDIS**](REDIS.md) for detail.