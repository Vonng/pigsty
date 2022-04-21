# FAQ: Frequently Asked Questions

> Here are some frequently asked questions. If you have some unlisted questions,  [Contact Us](community.md), or submit an [Issue](https://github.com/Vonng/pigsty/issues/new).





## Preparation



### Node Requirement

At least **1Core/2GB** is required from [singleton meta](c-arch.md#singleton-meta) installation. 1C1G works but is not stable.

**x86_64** Processor is required. ARM is not supported yet.



### OS requirements

**Pigsty strongly recommends using CentOS 7.8 to avoid meaningless efforts.**

It's fully tested and verified in a real-world production environment. And we develop, test, and package pigsty under CentOS 7.8. CentOS 7.6 is also fully tested. Other centos 7.x and its compatible are fine, b



### Versioning Policy

Pigsty use semantic version number: `<major>. <minor>. <release>`. A **major** version update implies fundamental architectural change. A minor version number increase means a significant update, including packages version updates, minor API changes, and other incremental features. The release version number is usually used for bug fixes and doc updates, and a release version increase does not change the package version (i.e. v1.0.1 and v1.0.0 usually use the same `pkg.tgz`).





## Download

#### Where to download Pigsty source code?

Pigsty [source](d-prepare.md#pigsty-source-code) package: `pigsty.tgz` can be obtained from the following location.

```bash
https://github.com/Vonng/pigsty/releases/download/v1.4.1/pigsty.tgz   # Github Release 
http://download.pigsty.cc/v1.4.1/pigsty.tgz                           # CDN
```

* [Github Release](https://github.com/Vonng/pigsty/releases) contains the authoritative releases. While CDN is especially for mainland China GFW.
* If you don't have internet access on production env, download source & offline packages first and ship them via scp/sftp...

Please use a specific version release rather than the master branch.

!> WARN:  Github `master` branch is for developing purposes, and may in a broken status.



#### Where to download Pigsty offline software packages?

You can download [offline software package](d-prepare.md#Pigsty-Offline-Package) via `curl` and put it to `/tmp/pkg.tgz`. Or ship it to prod env with scp/sftp.

```bash
curl https://github.com/Vonng/pigsty/releases/download/v1.4.1/pkg.tgz -o /tmp/pkg.tgz
curl http://download.pigsty.cc/v1.4.1/pkg.tgz -o /tmp/pkg.tgz       
```

During [`configure`](v-config.md#configure) procedure, if `/tmp/pkg.tgz` not exist, it will ask whether to download it. 'Y' will download from Github.

Besides, the built-in `download` script can be used for downloading too: `./download pkg`.



#### Download RPMs too slow

Pigsty use mirrors for RPMs downloading. If it's too slow, try the following solutions:

1. Pigsty has **offline software package**, which pre-packed resources (made under CentOS 7.8).

2. Specify a proxy server via [`proxy_env`](v-infra#proxy_env) and download through the proxy server, or use an off-wall server directly.

3. Use a different repo mirror with [`repo_upsteram`](v-infra.md#repo_upstream).

#### 

## Sandbox





#### How to use the offline software package？

Place the downloaded offline package `pkg.tgz` under the `/tmp/pkg.tgz` path. And it will be used automatically during [configure](v-config.md#configure) procedure.

The offline software package is extracted to `/www/pigsty` by default. During installation, if the `/www/pigsty/` dir exists along with the flag `/www/pigsty/repo_complete`. Pigsty will treat this as a provisioned repo and use it directly. (skip download & build).


-----------

#### Install without offline software packages?

Offline installers contain packages collected and downloaded from various sources and Github URLs. If you trying to install Pigsty without offline software packages. (Which is indicated by `/www/pigsty` & `/www/pigsty/repo_complete` not exists). All these packages will be fetched from the [`repo_upsteram`](v-infra.md#repo_upstream)  directly during installation. 

-----------

#### Install node packages error

The default offline software package is made under CentOS 7.8.2003 Linux x86_64. It's guaranteed to work on that specific OS Release.  It may work on the vast majority of any CentOS 7.x & compatible releases. But some RPMs may be incompatible.

In case of rpm confliction. Try to install Pigsty without offline software packages. It will download corresponding RPMs from available sources. Most dependency issues could be resolved by this approach.

If only several RPMs are incompatible. You could just remove the flag file `/www/pigsty/repo_complete`. Then pigsty will rebuild & download missing deps. Which could be much faster.

-------------

#### Vagrant sandbox is too slow to start for the first time

Pigsty sandbox uses CentOS 7 virtual machine by default. When Vagrant starts the virtual machine for the first time, it will download the `CentOS/7` ISO image Box, which is not small in size. (Of course, users can also choose to download the CentOS 7 installation disk ISO installation by themselves).

Using a proxy will increase the download speed, and downloading the CentOS 7 Box only needs to be done when the sandbox is first started and will be reused directly when the sandbox is subsequently rebuilt.


-----------
#### **RPMs error on Aliyun CentOS 7.8 VM**

Aliyun's CentOS 7.8 image has `nscd` installed by default, locking its glibc version, which can cause RPM dependency errors during installation.

`"Error: Package: nscd-2.17-307.el7.1.x86_64 (@base)`

Run `yum remove -y nscd` on all machines to resolve this issue, or use `ansible all -b -a 'yum remove -y nscd'`.


-----------

#### What is the GUI tool for editing Pigsty configuration files? 

A separate command-line tool [`pigsty-cli`](https://github.com/Vonng/pigsty-cli) is currently in beta status.


-----------







## Environment



-----------




-----------

#### Why not use Docker with Kubernetes?

Although Docker is very good for improving environment compatibility, however, the database is not the best scenario for container usage. In addition, Docker and Kubernetes have their barriers to use. To meet the "lower barrier" theme, Pigsty is deployed bare metal.

Pigsty was designed from the beginning with the need for containerization in the cloud in mind, and this is reflected in its declarative implementation of config definitions. It does not require much modification to migrate and transform to a cloud-native solution. When the time is right, it will be refactored using the Kubernetes Operator approach.


-----------







## Integration Issues


#### Is it possible to monitor existing PG instances?

For external databases created by non-Pigsty provisioning schemes, you can use [Monitor-Only](d-monly) deployment, please refer to the doc for details.

If the instance can be managed by Pigsty, you may consider deploying components such as node_exporter, pg_exporter, etc. on the target node in the same manner as a standard deployment.

If you only have access to the URL of that database (e.g. RDS cloud database instance), you can use the monitor-only deployment mode, where Pigsty monitors the remote PG instance through the pg_exporter instance deployed locally on the meta node.


#### **Can you use an existing DCS cluster?**

Sure, you can use an external DCS cluster by filling in [`dcs_servers`](v-infra.md#dcs_servers)) with the corresponding cluster.


#### **Can you use existing Grafana and Prometheus instances**?

Pigsty installs and configures Prometheus and Grafana directly on the meta node during installation, and maintains the config when creating/destroying instances/clusters.

Therefore, using existing Prometheus and Grafana is not supported, but you can copy the Prometheus config file `/etc/prometheus`, and all panels and data sources of Grafana to the new cluster.



-----------

## Monitoring Issues

-----------

#### How much data does the monitoring system have? 

It depends on the complexity of the user database (workload), for reference: 200 production database instances generate about 16GB of monitoring data in 1 day. Pigsty keeps two weeks of monitoring data by default, which can be adjusted by parameters.

-----------


#### How big is the performance hit of the monitoring system? 

A typical production instance, producing 5,000-time series, takes about 200ms for a single crawl, which is almost insignificant compared to the crawling period of 15s.

-----------





## Software

### Sandbox VM time out of sync 

The time inside the virtual machine after Virtualbox virtual shutdown may not be consistent with the host. You can try the following command: ``make sync`` to force NTP time synchronization.

```bash
sudo ntpdate -u pool.ntp.org
make sync4 #  Time synchronization shortcuts
make ss
```

That is, it can solve the problem of no data in the monitoring system after a long hibernation or shutdown and restart.

And you can always reset vm node time with vagrant reboot:

```bash
make dw4; make up4
```

It will sync vm time with host machine without Internet access for NTP services. 



## DCS


-----------

#### Abort because consul instance already exists

Pigsty has a [safeguard](p-nodes.md#SafeGuard) for dcs service (consul), avoid accidental purge of running consul instances (server or agent).

Pigsty will act according to [`dcs_exists_action`](v-infra.md#dcs_exists_action) if running consul instance is detected:

* `abort` will halt the entire playbook immediately
* `clean` will continue and purge existing dcs & force reset it

And it will be force to `abort` if [`dcs_disable_purge`](v-infra.md#dcs_disable_purge) is set to true.

You can change these variables in configuration files or manually overwrite it with extra args:

```bash
./nodes.yml -e dcs_exists_action=clean
```


-----------



## Postgres

-----------

#### Abort because Postgres instance already exists

Pigsty has a [safeguard](p-pgsql.md#SafeGuard) for dcs service (consul), avoid accidental purge of running PostgreSQL instances.

Pigsty will act according to [`pg_exists_action`](v-pgsql.md#pg_exists_action) if running consul instance is detected:

* `abort` will halt the entire playbook immediately
* `clean` will continue and purge existing dcs & force reset it

And it will be force to `abort` if [`pg_disable_purge`](v-pgsql.md#pg_disable_purge) is set to true.

You can change these variables in configuration files or manually overwrite it with extra args:

```bash
./pgsql.yml -e pg_exists_action=clean
```


-----------





#### What does Pigsty have installed?

For details, please refer to [system architecture](c-arch.md)

![](_media/infra.svg)

Pigsty is a database solution with a complete runtime. On the local machine, Pigsty can be used as an environment for development, testing, and data analysis. In production environments, Pigsty can be used to deploy, manage, and monitor large-scale PostgreSQL clusters.

-----------


#### **How Pigsty database ensures high availability**

Patroni as HA Agent, Consul as DCS, and Haproxy as default traffic distributor. members of Pigsty's database cluster are idempotent in use: read/write and read-only traffic continue to work as long as anyone instance of the cluster remains alive.

The availability of the DCS itself is guaranteed by multi-node consensus, so it is recommended to deploy three or more meta nodes in production environments or to use an external DCS cluster.

-----------

