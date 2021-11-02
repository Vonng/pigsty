## Download Issues

#### Where to download the source code?

Pigsty source package: `pigsty.tgz` can be obtained from the following location.

* [Github Release](https://github.com/Vonng/pigsty/releases) is the most authoritative and comprehensive download address, containing all historical releases.
* When mainland users cannot access Github, they can visit Baidu cloud disk to download: [https://pan.baidu.com/s/1DZIa9X2jAxx69Zj-aRHoaw](https://pan.baidu.com/s/1DZIa9X2jAxx69Zj-aRHoaw) (Extraction code : `8su9`)
* If users need to do offline installation, they can download the source package and offline installation package from Github or other channels in advance, and upload them to the server via scp, ftp, etc.

```bash
curl -SL https://github.com/Vonng/pigsty/releases/download/v1.2.0/pigsty.tgz -o ~/pigsty.tgz
```

-----------

#### Where to download the offline packages?

During `configure`, if the offline installer `/tmp/pkg.tgz` does not exist, the user will be automatically prompted to download it, by default from Github Release.

If the user needs to install in an environment where **no internet access**, or Github access is restricted, they will need to download and upload it to the target server at the specified location themselves.

```bash  
# curl -SL https://github.com/Vonng/pigsty/releases/download/v1.2.0/pkg.tgz -o /tmp/pkg.tgz
```

Place it under the `/tmp/pkg.tgz` path on the installation machine and it will be used automatically during the installation. The offline package will be extracted to: `/www/pigsty` by default.


-----------

#### Install without offline packages?

The offline installer contains packages collected and downloaded from various Yum sources and Github Releases. Users can also choose not to use the pre-packaged offline installers and download them directly from the original upstream. This is typically used to resolve most dependency errors when using a non-CentOS 7.8 operating system.
Not using an offline installer simply requires selecting `n` when prompted to download during `configure`.

-----------

#### Error when installing yum package

The default offline software installer is based on CentOS 7.8 environment. If you have problems, you can delete the relevant rpm package in `/www/pigsty` where the problem occurs and the `/www/pigsty/repo_complete` marker file. Execute `make repo-download` to re-download the dependency packages that match the current OS version.

-------------

#### Some packages are too slow to download

Pigsty has been using domestic yum mirrors for downloads as much as possible, however a few packages are still affected by **GFW**, causing slow downloads, such as software related to direct downloads from Github. The following solutions are available.

1. Pigsty provides **offline software installer**, which pre-packages all software and its dependencies. It will automatically prompt the download when `configure`. 2.

2. Specify a proxy server via [`proxy_env`](v-connect#proxy_env) and download through the proxy server, or use an off-wall server directly.


-----------

#### Vagrant sandbox is too slow to start for the first time

Pigsty sandbox uses CentOS 7 virtual machine by default. When Vagrant starts the virtual machine for the first time, it will download the `CentOS/7` ISO image Box, which is not small in size. (Of course users can also choose to download the CentOS 7 installation disk ISO installation by themselves). Using a proxy will increase the download speed, and downloading the CentOS 7 Box only needs to be done when the sandbox is first started, and will be reused directly when the sandbox is subsequently rebuilt.


-----------
What does #### 1.0 GA mean?

Pigsty has been used in real-world production environments since version 0.3, and is not really General Available until 1.0.
1.0 is a milestone point, a complete upgrade of the monitoring system, and new versions after 1.0 will give guidance on version upgrade options.


-----------

#### What is the GUI tool for editing Pigsty configuration files? 

A separate command line tool [`pigsty-cli`](https://github.com/Vonng/pigsty-cli), currently in beta status.


-----------







## Environment issues


#### Pigsty's installation environment

Installation of Pigsty requires at least one machine node: specifications of at least 1 core and 1 GB, with a Linux kernel, CentOS 7 distribution installed, and processor of x86_64 architecture.

In a production environment, it is recommended to use a higher specification machine and deploy **multiple management nodes** for disaster recovery redundancy. The **management nodes** in the production environment are responsible for issuing control commands, managing the deployment of database clusters, collecting monitoring data, running timing tasks, etc.

-----------


#### Operating System Requirements for Pigsty

Pigsty strongly recommends using CentOS 7.8 operating system to install the meta node and database node, which is a well-proven operating system version to effectively avoid consuming energy on unnecessary issues.

Pigsty's default development, testing, and deployment environments are based on CentOS 7.8, and CentOS 7.6 is also fully validated. Other CentOS 7.x and its equivalents RHEL7 , Oracle Linux 7 are theoretically problem-free, but have not been tested and validated.

When monitoring an existing PostgreSQL database cluster using **monitoring-only mode**, it is possible to use a different Linux distribution. Because the monitoring system-related components are all Go-written binaries, they are compatible with various Linux distributions, but this is not an officially supported behavior.

Later other OS support may be provided in the form of container images.


-----------

#### Why not use Docker with Kubernetes?

Although Docker is very good for improving environment compatibility, however databases are not the best scenario for container usage. In addition, Docker and Kubernetes have their own barriers to use. In order to meet the "lower barrier" theme, Pigsty is deployed bare metal.

Pigsty was designed from the beginning with the need for containerization in the cloud in mind, and this is reflected in its declarative implementation of configuration definitions. It does not require much modification to migrate and transform to a cloud-native solution. When the time is right, it will be refactored using the Kubernetes Operator approach.


-----------







## Integration Issues


#### Is it possible to monitor existing PG instances?

For external databases created by non-Pigsty provisioning solutions, they can be deployed using **monitoring-only mode**, please refer to the documentation for details. Note that Pigsty deployments require ssh sudo privileges on the target machine. Therefore cloud vendor RDS is usually not supported, but for example MyBase for PostgreSQL ECS hosted cloud databases can be included for monitoring.

-----------

#### What can I do if I can't monitor the cloud vendor RDS?

Currently Pigsty does not officially support monitoring of pure RDS, as a monitoring system that lacks machine metrics is half-baked. However, users can monitor RDS through local deployment of PG Exporter remote connection, as well as Prometheus local static service discovery to capture local Exporter and achieve curve by manually configuring Label.

-----------

## Monitoring system issues

-----------

#### Why is there no data in the PG Instance Log panel?

Log collection is currently a Beta feature and requires additional installation steps. Executing `make logging` will install `loki` and `promtail` and the panel will be available only after execution.

loki is a relatively new logging solution and not everyone is willing to accept it, so it is available as an option.

-----------

#### How much data does the monitoring system have? 

It depends on the complexity of the user database (workload), for reference: 200 production database instances generate about 16GB of monitoring data in 1 day. Pigsty keeps 30 days of monitoring data by default, which can be adjusted by parameters.

-----------




## Architecture issues

#### What does Pigsty have installed?

For details, please refer to [system architecture](c-arch.md)

! [](... /_media/infra.svg)

Pigsty is a database solution with a full runtime. On the local machine, Pigsty can be used as a development, testing, and data analysis environment. In a production environment, Pigsty can be used to deploy, manage, and monitor large-scale PostgreSQL clusters.

-----------


#### How Pigsty database guarantees high availability

Patroni 2.0 acts as HA Agent, Consul as DCS, and Haproxy as default traffic distributor. members of Pigsty's database cluster are idempotent in use: read/write and read-only traffic can continue to work as long as any instance of the cluster is alive.

The availability of the DCS itself is guaranteed by multi-node consensus, so it is recommended to deploy three or more management nodes in production environments, or to use an external DCS cluster.

-----------





## Software issues


#### Error when using ipython.

This is because the current version of `pip3` has a bug in the default installed version of ipython: its dependency `jedi` is too high (`0.18`). You need to manually install a lower version of `jedi` (`0.17`).

```bash
pip3 install jedi==0.17.2
```

-----------

#### No monitoring data in the virtual machine after shutdown

After Virtualbox virtual machine shutdown, the time in the virtual machine may not be consistent with the host.

You can try the following command: ``make sync`` to force NTP time synchronization.

``bash
sudo ntpdate -u pool.ntp.org
```

That will solve the problem of no data on the monitoring system after a long hibernation or shutdown and reboot.
