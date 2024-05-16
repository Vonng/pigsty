# Get Started

> Install Pigsty with 4 steps: [Download](#download), [Bootstrap](#bootstrap), [Configure](#configure) and [Install](#install).

----------------

## Short Version

Prepare a fresh Linux x86_64 node that meets the [requirement](#requirement), then run as a **sudo-able** user:

```bash
bash -c "$(curl -fsSL https://get.pigsty.cc/install)"
```

It will [download](#download) Pigsty source to your home. then perform [Bootstrap](#bootstrap), [Configure](#configure), and [Install](#install).

```bash
cd ~/pigsty   # get pigsty source and entering dir
./bootstrap   # download bootstrap pkgs & ansible [optional]
./configure   # pre-check and config templating   [optional]
./install.yml # install pigsty according to pigsty.yml
```

A pigsty singleton node will be ready with Web Services on port `80/443` and Postgres on port `5432`.

[![asciicast](https://asciinema.org/a/566220.svg)](https://asciinema.org/a/566220)


<details><summary>Download with Script</summary>

```bash
$ bash -c "$(curl -fsSL https://get.pigsty.cc/install)"
[v2.7.0] ===========================================
$ curl -fsSL https://pigsty.cc/install | bash
[Site] https://pigsty.io
[Demo] https://demo.pigsty.cc
[Repo] https://github.com/Vonng/pigsty
[Docs] https://pigsty.io/docs/setup/install
[Download] ===========================================
[ OK ] version = v2.7.0 (from default)
curl -fSL https://get.pigsty.cc/v2.7.0/pigsty-v2.7.0.tgz -o /tmp/pigsty-v2.7.0.tgz
########################################################################### 100.0%
[ OK ] md5sums = some_random_md5_hash_value_here_  /tmp/pigsty-v2.7.0.tgz
[Install] ===========================================
[ OK ] install = /home/vagrant/pigsty, from /tmp/pigsty-v2.7.0.tgz
[Resource] ===========================================
[HINT] rocky 8  have [OPTIONAL] offline package available: https://pigsty.io/docs/setup/offline
curl -fSL https://github.com/Vonng/pigsty/releases/download/v2.7.0/pigsty-pkg-v2.7.0.el8.x86_64.tgz -o /tmp/pkg.tgz
curl -fSL https://get.pigsty.cc/v2.7.0/pigsty-pkg-v2.7.0.el8.x86_64.tgz -o /tmp/pkg.tgz # or use alternative CDN
[TodoList] ===========================================
cd /home/vagrant/pigsty
./bootstrap      # [OPTIONAL] install ansible & use offline package
./configure      # [OPTIONAL] preflight-check and config generation
./install.yml    # install pigsty modules according to your config.
[Complete] ===========================================
```

</details>


<details><summary>Download with Git</summary>

You can also download pigsty source with `git`, don't forget to check out a specific version tag, the `master` branch is for development.

```bash
git clone https://github.com/Vonng/pigsty;  # master branch is for develop purpose
cd pigsty; git checkout v2.7.0              # always checkout a specific version
```

</details>


<details><summary>Download Directly</summary>

You can also download pigsty source & [offline packages](https://pigsty.io/docs/setup/offline/) directly from GitHub release page.

```bash
https://github.com/Vonng/pigsty/releases/download/v2.7.0/pigsty-v2.7.0.tgz   # Github Release
https://get.pigsty.cc/v2.7.0/pigsty-v2.7.0.tgz                               # Pigsty CDN
```

</details>




-----------------------

## Requirement

Pigsty support the `Linux` kernel and `x86_64/amd64` processor. It can run on any nodes: bare metal, virtual machines, or VM-like containers, but a **static** IPv4 is required.

The minimum spec is `1C1G`. It is recommended to use bare metals or VMs with at least `2C4G`. Parameters will be auto-tuned.

Public key `ssh` access to localhost and NOPASSWD `sudo` privilege is required to perform the installation, and do not use the `root` user.

Pigsty run on bare OS, and support EL, Debian, and Ubuntu. There may be slight differences in different OS Distros, for example, most pigsty supported extensions are only available on EL(8/9) distros.

Major OS version supported: RedHat 7/8/9, Debian 11/12, and Ubuntu 20/22, and any compatible OS distros such as RHEL, Rocky, Alma, Oracle, Anolis, etc...
We recommend using `RockyLinux 8.9` (Green Obsidian), `Debian 12.04` (bookworm), and `Ubuntu 22.04` (jammy), as they offer the most comprehensive support among all RHEL/DEB OS distros.

For the latest minor version of each supported major version (`Rocky 8.9`，`Debian bookworm`，`Ubuntu jammy`),
We have pre-built [offline packages](#offline-packages) for deployment without the Internet access.
If you use a different minor OS version with those offline packages, you may encounter RPM/DEB package conflicts. Check [FAQ](FAQ#installation) or install without offline packages.

<details><summary>Aliyun VM Image Versions</summary>

If you are using cloud virtual machines or [Terraform](PROVISION#terraform), the following image can be taken into considerations (aliyun):

```bash
# Rocky 8.9    :  rockylinux_8_9_x64_20G_alibase_20231221.vhd
# Debian 12    :  debian_12_4_x64_20G_alibase_20231220.vhd
# Ubuntu 22.04 :  ubuntu_22_04_x64_20G_alibase_20231221.vhd

# other supported os distro
# CentOS 7.9   :  centos_7_9_x64_20G_alibase_20231220.vhd
# Rocky 9.3    :  rockylinux_9_3_x64_20G_alibase_20231221.vhd
# Debian 11.7  :  debian_11_7_x64_20G_alibase_20230907.vhd
# Ubuntu 20.04 :  ubuntu_20_04_x64_20G_alibase_20231221.vhd
# Anolis 8.8   :  anolisos_8_8_x64_20G_rhck_alibase_20230804.vhd
```

</details>



-----------------------

## Download

You can get & extract pigsty source via the following command:

```bash
bash -c "$(curl -fsSL https://get.pigsty.cc/install)"
```

> HINT: To install a specific version, passing the version string as the first parameter:
>
> ```bash
> bash -c "$(curl -fsSL https://get.pigsty.cc/i)" -- v2.6.0
> curl -fsSL https://get.pigsty.cc/i | bash -s v2.6.0
> ```


<details><summary>Download Pigsty Source with Specific Version</summary>

If you want to download a specific version, use the following URLs:

```bash
VERSION=v2.7.0   # version string, check https://pigsty.io/docs/releasenote
https://github.com/Vonng/pigsty/releases/download/${VERSION}/pigsty-${VERSION}.tgz
```

For example, Pigsty v2.7.0 source can be acquired with:

```bash
curl -L https://github.com/Vonng/pigsty/releases/download/v2.7.0/pigsty-v2.7.0.tgz -o ~/pigsty.tgz
curl -L https://get.pigsty.cc/v2.7.0/pigsty-v2.7.0.tgz -o ~/pigsty.tgz   # China CDN Mirror
```

</details>



### Offline Packages

Pigsty will download rpm/deb packages from the upstream yum/apt repo during the initial installation.
It will take a snapshot of the software it uses and create a fast & reliable local software repo to accelerate the installation process and make sure the software version is consistent across all nodes.

The "Offline Packages" is actually a snapshot of the local software repo (`/www/pigsty`) after the installation of Pigsty on the target node.
We offer pre-packed offline packages for the latest minor version of major OS versions, and test them thoroughly before release.

During the [Bootstrap](#bootstrap) procedure, you can choose whether to download the corresponding offline package (`--yes|--no`) if applicable.
Or just ignore it and let Pigsty pull the latest packages from upstream (which requires Internet access).

To make an offline package, you can run the [`cache`](https://github.com/Vonng/pigsty/blob/master/bin/cache) script, it will create the pkg on `/tmp/pkg.tgz`.
To deploy Pigsty on a node without Internet access and non-standard OS, you can install Pigsty on a node that has the same OS and Internet access.
Then create an offline package and upload it to the production environment for offline installation.


<details><summary>Download offline packages manually</summary>

```bash
VERSION=v2.7.0
https://github.com/Vonng/pigsty/releases/download/v2.7.0/pigsty-pkg-${VERSION}.el8.x86_64.tgz      # Package: EL 8(.9)
https://github.com/Vonng/pigsty/releases/download/v2.7.0/pigsty-pkg-${VERSION}.debian12.x86_64.tgz # Package: Debian 12    (bookworm)
https://github.com/Vonng/pigsty/releases/download/v2.7.0/pigsty-pkg-${VERSION}.ubuntu22.x86_64.tgz # Package: Ubuntu 22.04 (jammy)
```

You can also get offline packages from CDN, and specify a specific version:

```bash
VERSION=v2.7.0
https://get.pigsty.cc/${VERSION}/pigsty-pkg-${VERSION}.el8.x86_64.tgz        # Offline Package：EL 8(.9)
https://get.pigsty.cc/${VERSION}/pigsty-pkg-${VERSION}.debian12.x86_64.tgz   # Offline Package：Debian 12    (bookworm)
https://get.pigsty.cc/${VERSION}/pigsty-pkg-${VERSION}.ubuntu22.x86_64.tgz   # Offline Package：Ubuntu 22.04 (jammy)
```

For example, download v2.7.0 offline packages for EL8.x86_64:

```bash
curl -L https://github.com/Vonng/pigsty/releases/download/v2.7.0/pigsty-pkg-v2.7.0.el8.x86_64.tgz  -o /tmp/pkg.tgz
curl -L https://get.pigsty.cc/v2.7.0/pigsty-pkg-v2.7.0.el8.x86_64.tgz -o /tmp/pkg.tgz  # China CDN Mirror
```

</details>

Not all combinations of OS and architecture are supported yet. Please check the [RELEASENOTE](RELEASENOTE) page.
You can always choose to install without it, and pull the latest packages from upstream.



-----------------------

## Bootstrap

`bootstrap` script will make sure one thing: [**Ansible**](PLAYBOOK#ansible) is ready for using.

It will also download / extract / setup the offline [packages](#offline-packagess) if you choose to do so.

```bash
./boostrap [-p <path>=/tmp/pkg.tgz]   # offline pkg path (/tmp/pkg.tgz by default)
           [-y|--yes] [-n|--no]       # download packages or not? (ask by default)
```

> HINT: `bootstrap` is **OPTIONAL** if you already have `ansible` and plan to download rpm packages from upstream directly.

<details><summary>bootstrap procedure detail</summary>

1. Check preconditions

2. Check local repo exists ?
   * Y -> Extract to `/www/pigsty` and create repo file to enable it
   * N -> Download offline package from the Internet?
     * Y -> Download from GitHub / CDN and extract & enable it
     * N -> Add basic os upstream repo file manually ?
          * Y -> add according to region / version
          * N -> leave it to user's default configuration
  * Now we have an available repo for installing ansible
    * Precedence: local `pkg.tgz` > downloaded `pkg.tgz` > upstream > user provide

3. install boot utils from the available repo
   * el7,8,9: `ansible createrepo_c unzip wget yum-utils sshpass`
   * el8 extra: `ansible python3.11-jmespath createrepo_c unzip wget dnf-utils sshpass modulemd-tools`
   * el9 extra: `ansible python3-jmespath python3.11-jmespath createrepo_c unzip wget dnf-utils sshpass modulemd-tools`
   * ubuntu/debian: `ansible python3-jmespath dpkg-dev unzip wget sshpass acl`
4. Check `ansible` availability.

</details>


<details><summary>bootstrap from local packages output</summary>

If `/tmp/pkg.tgz` already exists, bootstrap will use it directly:

```bash
bootstrap pigsty v2.7.0 begin
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

Download `pkg.tgz` from GitHub and extract it:

```bash
bootstrap pigsty v2.7.0 begin
[ OK ] region = china
[ OK ] kernel = Linux
[ OK ] machine = x86_64
[ OK ] release = 7.9.2009
[ OK ] sudo = vagrant ok
[ IN ] Cache /tmp/pkg.tgz not exists, download? (y/n):
=> y
[ OK ] download from Github https://get.pigsty.cc/v2.7.0/pigsty-pkg-v2.7.0.el7.x86_64.tgz to /tmp/pkg.tgz
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

[`configure`](CONFIG) will create a [`pigsty.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml) config file according to your environment.

```bash
./configure [-n|--non-interactive] [-i|--ip <ipaddr>] [-m|--mode <name>] [-r|--region <default|china|europe>] [-x|--proxy]
```

* `-m|--mode`: Generate config from [templates](https://github.com/Vonng/pigsty/tree/master/files/pigsty) according to `mode`: (`auto|demo|sec|citus|el|el7|ubuntu|prod...`)
* `-i|--ip`: Replace IP address placeholder `10.10.10.10` with your primary ipv4 address of current node.
* `-r|--region`: Set upstream repo mirror according to `region` (`default|china|europe`)
* `-n|--non-interactive`: skip interactive wizard and using default/arg values
* `-x|--proxy`: setup `proxy_env` from current environment variables (`http_proxy`/`HTTP_PROXY`， `HTTPS_PROXY`， `ALL_PROXY`， `NO_PROXY`).

When `-n|--non-interactive` is specified, you have to specify a primary IP address with `-i|--ip <ipaddr>` in case of multiple IP address, since there's no default value for primary IP address in this case.

?> HINT: `configure` is **OPTIONAL** if you know how to [configure](CONFIG) pigsty manually.


<details><summary>configure example output</summary>

```bash
[vagrant@meta pigsty]$ ./configure
configure pigsty v2.7.0 begin
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

It's a standard ansible [playbook](PLAYBOOK), you can have fine-grained control with ansible options:

* `-l`: limit execution targets
* `-t`: limit execution tasks
* `-e`: passing extra args
* ...

> **WARNING: It's very DANGEROUS to run [`install.yml`](https://github.com/Vonng/pigsty/blob/master/install.yml) on existing deployment!**
>
> You can use `chmod a-x install.yml` to avoid accidental execution.


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

Once installed, you'll have 4 module [INFRA](INFRA), [NODE](NODE), [**ETCD**](ETCD) , [**PGSQL**](PGSQL) installed on the current node.

* [**INFRA**](INFRA): Monitoring infrastructure can be accessed via `http://<ip>:80`
* [**PGSQL**](PGSQL): PostgreSQL cluster can be [accessed](PGSQL-SVC#personal-user) via default PGURL:

```bash
psql postgres://dbuser_dba:DBUser.DBA@10.10.10.10/meta     # database superuser
psql postgres://dbuser_meta:DBUser.Meta@10.10.10.10/meta   # business administrator
psql postgres://dbuser_view:DBUser.View@pg-meta/meta       # default read-only user via domain name
```

There are several services are exposed by Nginx (configured by [`infra_portal`](PARAM#infra_portal)):

|  Component   | Port |   Domain   | Comment                  | Public Demo                                |
|:------------:|:----:|:----------:|--------------------------|--------------------------------------------|
|    Nginx     |  80  | `h.pigsty` | Web Service Portal, Repo | [`home.pigsty.cc`](http://home.pigsty.cc)  |
| AlertManager | 9093 | `a.pigsty` | Alter Aggregator         | [`a.pigsty.cc`](http://a.pigsty.cc)        |
|   Grafana    | 3000 | `g.pigsty` | Grafana Dashboard Home   | [`demo.pigsty.cc`](https://demo.pigsty.cc) |
|  Prometheus  | 9090 | `p.pigsty` | Prometheus Web UI        | [`p.pigsty.cc`](http://p.pigsty.cc)        |

You can configure public domain names for these infra services or just use local static DNS records & resolver.
e.g: write records to `/etc/hosts` and access via DNS.

If [`nginx_sslmode`](PARAM#nginx_sslmode) is set to `enabled` or `enforced`, you can trust self-signed ca: `files/pki/ca/ca.crt` to use `https` in your browser.

```
http://g.pigsty ️-> http://10.10.10.10:80 (nginx) -> http://10.10.10.10:3000 (grafana)
```

[![pigsty-home.jpg](https://repo.pigsty.cc/img/pigsty-home.jpg)](https://demo.pigsty.cc)

> Default credential for grafana: username: `admin`, password: `pigsty`


<details><summary>How to use HTTPS in Pigsty WebUI?</summary><br>

Pigsty will generate self-signed certs for Nginx, if you wish to access via HTTPS without "Warning", here are some options:

- Apply & add real certs from trusted CA: such as Let's Encrypt
- Trust your generated CA crt as root ca in your OS and browser
- Type `thisisunsafe` in Chrome will supress the warning

</details>



-----------------------

## More

You can deploy & monitor more clusters with pigsty: add more nodes to `pigsty.yml` and run corresponding playbooks:

```bash
bin/node-add   pg-test      # init 3 nodes of cluster pg-test
bin/pgsql-add  pg-test      # init HA PGSQL Cluster pg-test
bin/redis-add  redis-ms     # init redis cluster redis-ms
```

Remember that most modules require the [`NODE`] module installed first. Check [PGSQL](PGSQL), [REDIS](REDIS) for detail.