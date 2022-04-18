# FAQ: Frequently Asked Questions

> Here is a list of common problems encountered by Pigsty users. If you encounter a problem that is difficult to solve, you can [Contact Us](community.md), or submit an [Issue](https://github.com/Vonng/pigsty/issues/new).



## Download Issues

#### Where to download the source code?

Pigsty source package: `pigsty.tgz` can be obtained from the following location.

* [Github Release](https://github.com/Vonng/pigsty/releases) is the most authoritative and comprehensive download address, containing all historical releases.
* When mainland users cannot access Github, they can visit the Baidu cloud disk to download: [https://pan.baidu.com/s/1DZIa9X2jAxx69Zj-aRHoaw](https://pan.baidu.com/s/1DZIa9X2jAxx69Zj-aRHoaw) (Extraction code: `8su9`)
* If users need to do the offline installation, they can download the source package and offline installation package from Github or other channels in advance, and upload them to the server via scp, ftp, etc.

```bash
curl -SL https://github.com/Vonng/pigsty/releases/download/v1.4.0/pigsty.tgz -o ~/pigsty.tgz
```

-----------

#### **versioning policy for source packages**

Pigsty follows the semantic version numbering rule: `<major>. <minor>. <release>`. A major version update implies a major fundamental architectural change (which usually doesn't happen), and
A minor version number increase means a significant update, which usually means package version updates, minor API changes, and other incremental feature changes, and usually includes a note on upgrade considerations.
The release version number is usually used for bug fixes and doc updates, and a release version increase does not change the package version (i.e. v1.1.0 and v1.0.0 correspond to the same `pkg.tgz`).

-----------

#### Where to download the offline packages?

During `configure`, if the offline installer `/tmp/pkg.tgz` does not exist, the user will be automatically prompted to download it, by default from Github Release.

If the user needs to install in an environment where **no internet access** or Github access is restricted, they will need to download and upload it to the target server at the specified location themselves.

```bash  
# curl -SL https://github.com/Vonng/pigsty/releases/download/v1.4.0/pkg.tgz -o /tmp/pkg.tgz
```

-----------

#### How to use the offline package？

Place the downloaded offline package `pkg.tgz` under the `/tmp/pkg.tgz` path on the installation machine to use it automatically during the installation process.

The offline package is extracted to `/www/pigsty` by default. During installation, when the `/www/pigsty/` dir exists along with the marker file `/www/pigsty/repo_complete`, Pigsty will use the package directly, skipping the lengthy download process.


-----------

#### Install without offline packages?

Offline installers contain packages collected and downloaded from various Yum repos and Github Releases, or users can choose not to use pre-packaged offline installers and download them directly from the original upstream.

When the `/www/pigsty/` dir does not exist, or the tag file `/www/pigsty/repo_complete` does not exist, Pigsty will download all software dependencies from the original upstream specified by [`repo_upsteram`](v-infra.md#repo_upstream).

To not use the offline installer simply select no `n` when prompted to download during `configure`.

-----------

#### Error when installing the yum package

The default offline software package is based on CentOS 7.8.2003 Linux x86_64 environment and is guaranteed to install successfully on a freshly installed node of this operating system.

The vast majority of CentOS 7. x and its compatible distributions may have very few package dependency issues. Users should be aware of this when using a non-CentOS 7.8.2003 operating system version.

If RPM dependency and versioning issues arise, consider downloading the correct RPM dependencies directly from upstream Repo without using an offline install, which can usually be used to resolve most dependency errors and omissions.

If there are only scattered individual RPM packages with compatibility issues, you may consider removing the relevant RPM package(s) in `/www/pigsty` that is in question, as well as the `/www/pigsty/repo_complete` flag file.
This will speed up the standard installation by only actually downloading the missing problematic RPM packages.

-------------

#### Some packages are too slow to download

Pigsty has been using domestic yum repos for downloads as much as possible, however, a few packages are still affected by **GFW**, causing slow downloads, such as software related to direct downloads from Github. The following solutions are available.

1. Pigsty provides an **offline software installer**, which pre-packages all software and its dependencies. It will automatically prompt the download when to `configure`. 

2. Specify a proxy server via [`proxy_env`](v-infra#proxy_env) and download through the proxy server, or use an off-wall server directly.


-----------

#### Vagrant sandbox is too slow to start for the first time

Pigsty sandbox uses CentOS 7 virtual machine by default. When Vagrant starts the virtual machine for the first time, it will download the `CentOS/7` ISO image Box, which is not small in size. (Of course, users can also choose to download the CentOS 7 installation disk ISO installation by themselves).
Using a proxy will increase the download speed, and downloading the CentOS 7 Box only needs to be done when the sandbox is first started and will be reused directly when the sandbox is subsequently rebuilt.


-----------
#### **Deploying and installing RPM on AliCloud standard CentOS 7 virtual machine reports an error**

AliCloud's CentOS 7.8 server image has `nscd` installed by default, locking out the glibc version, which can cause RPM dependency errors during installation.

`"Error: Package: nscd-2.17-307.el7.1.x86_64 (@base)`

Run `yum remove -y nscd` on all machines to resolve this issue, or use `ansible all -b -a 'yum remove -y nscd'`.


-----------

#### What is the GUI tool for editing Pigsty configuration files? 

A separate command-line tool [`pigsty-cli`](https://github.com/Vonng/pigsty-cli) is currently in beta status.


-----------





## Environment Issues


#### Pigsty's installation environment

Installation of Pigsty requires at least one machine node: specifications of at least 1 core and 2 GB, with Linux kernel, CentOS 7 distribution installed, and x86_64 architecture for the processor. It is recommended to use a **brand new** node (just after installing the OS).

In a production environment, it is recommended to use a higher specification machine and deploy **multiple meta nodes** as disaster recovery redundancy. In the production environment, **meta nodes** are responsible for issuing control commands, managing the deployment of database clusters, collecting monitoring data, running timing tasks, etc.

-----------

#### Pigsty's OS requirements (very important!) 

Pigsty strongly recommends using CentOS 7.8 operating system to install the meta-node and database node, which is a well-proven operating system version **to effectively avoid expending energy on unnecessary issues**.

**Pigsty's default development, testing, and deployment environments are based on CentOS 7.8**, and CentOS 7.6 is also fully validated. Other CentOS 7. x and its equivalents RHEL7, and Oracle Linux 7 are theoretically fine but have not been tested and validated.

Pigsty has no requirements for the target node's OS when monitoring existing PostgreSQL instances using monitor-only mode.


-----------

#### Why not use Docker with Kubernetes?

Although Docker is very good for improving environment compatibility, however, the database is not the best scenario for container usage. In addition, Docker and Kubernetes have their barriers to use. To meet the "lower barrier" theme, Pigsty is deployed bare metal.

Pigsty was designed from the beginning with the need for containerization in the cloud in mind, and this is reflected in its declarative implementation of config definitions. It does not require much modification to migrate and transform to a cloud-native solution. When the time is right, it will be refactored using the Kubernetes Operator approach.


-----------







## Integration Issues


#### Is it possible to monitor existing PG instances?

For external databases created by non-Pigsty provisioning schemes, you can use [monitor-only mode](d-monly) deployment, please refer to the doc for details.

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




## Architecture Issues

#### What does Pigsty have installed?

For details, please refer to [system architecture](c-arch.md)

![](_media/infra.svg)

Pigsty is a database solution with a complete runtime. On the local machine, Pigsty can be used as an environment for development, testing, and data analysis. In production environments, Pigsty can be used to deploy, manage, and monitor large-scale PostgreSQL clusters.

-----------


#### **How Pigsty database ensures high availability**

Patroni as HA Agent, Consul as DCS, and Haproxy as default traffic distributor. members of Pigsty's database cluster are idempotent in use: read/write and read-only traffic continue to work as long as anyone instance of the cluster remains alive.

The availability of the DCS itself is guaranteed by multi-node consensus, so it is recommended to deploy three or more meta nodes in production environments or to use an external DCS cluster.

-----------





## Software Issues

#### No monitoring data in the virtual machine after shutdown

The time inside the virtual machine after Virtualbox virtual shutdown may not be consistent with the host. You can try the following command: ``make sync`` to force NTP time synchronization.

```bash
sudo ntpdate -u pool.ntp.org
make sync4 #  Time synchronization shortcuts
make ss
```

That is, it can solve the problem of no data in the monitoring system after a long hibernation or shutdown and restart.





## DCS Issues


-----------

#### Abort because consul instance already exists

When performing database & infrastructure initialization, a protection mechanism is provided to avoid accidental library deletion.

When Pigsty finds that Consul is already running, it takes different actions based on the parameter [`dcs_exists_action`](v-infra.md#dcs_exists_action).

The default `abort` means that the execution of the entire playbook will be aborted immediately. `clean`, on the other hand, will force a shutdown to delete existing instances, so please use this parameter with caution.

In addition, if the parameter [`dcs_disable_purge`](v-infra.md#dcs_disable_purge) is true, then `dcs_exists_action` will be forced to be configured as `abort` to avoid accidental deletion of DCS instances.


-----------



## Postgres Issues

-----------

#### Abort because Postgres instance already exists

When performing database & infrastructure initialization, a protection mechanism is provided to avoid accidental deletion of Postgres instances.

When Pigsty finds that Postgres is already running, it takes different actions based on the parameter [`pg_exists_action`](v-pgsql.md#pg_exists_action)

The default `abort` means that the execution of the entire playbook will be aborted immediately. `clean`, on the other hand, will force a shutdown to delete the existing instance, so please use this parameter with caution.

In addition, if the parameter [`pg_disable_purge`](v-pgsql.md#pg_disable_purge) is true, then `pg_exists_action` will force the configuration to `abort` to avoid the accidental deletion of database instances.
