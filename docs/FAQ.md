# Pigsty FAQ

> Here are some frequently asked questions. If you have any unlisted questions or suggestions, please create an [Issue](https://github.com/Vonng/pigsty/issues/new).


----------------

## Preparation


<br>
<details><summary>Node Requirement</summary>

CPU Architecture: `x86_64`. `arm` is not supported yet.

CPU Number: **1** core for common node, at least **2** core for admin node.

Memory: at least **1GB** for common node, at least **2GB** for admin node.

It is recommended to use at least 3~4 x (2C / 4G / 100G) nodes for a serious production deployment.

</details><br>



<details><summary>OS Requirement</summary>

Pigsty is developed and tested on CentOS 7.9, Rocky 8.6 & 9.0 now. RHEL, Alma, Oracle, and any EL compatible distribution also works.

!> We strongly recommend using EL 7.9, 8.6, and 9.0 to avoid meaningless efforts on RPM troubleshooting.

</details><br>



<details><summary>Versioning Policy</summary>

!> Please always use a **version-specific** [release](https://github.com/Vonng/pigsty/releases), do not use the GitHub `master` branch unless you known what you are doing.

Pigsty use semantic version number such as: `<major>. <minor>. <release>`.

Major updates means some fundamental changes and huge features, minor version updates means new features, bumping package version, and minor API changes.
Release version updates means bug fixes and doc updates, and it does change offline package versions (i.e., v1.0.1 and v1.0.0 will use the same `pkg.tgz`).

Pigsty trys to release a Minor Release every 1-3 months and a Major Release every 1-2 years.

</details><br>




----------------

## Download


<br>
<details><summary>Where to download pigsty source code?</summary>

!> `bash -c "$(curl -fsSL http://download.pigsty.cc/get)"`

Executing the above command will automatically download the latest stable version of `pigsty.tgz` and extract it to the `~/pigsty` dir.
You can also manually download a specific version of Pigsty source code from the following location.
If you need to install it in an environment without Internet, you can download it in advance and upload it to the production server via scp/sftp, etc.

</details><br>


<details><summary>Download from upstream repo is too slow</summary>

TBD

</details><br>


<details><summary>Where to download pigsty offline packages</summary>

TBD

</details><br>



----------------

## Configuration


<br>
<details><summary>What does configure do?</summary>

!> Detect the environment, generate the configuration, enable the offline package (optional), and install the essential tool Ansible.

After downloading the Pigsty source package and unpacking it, you need first to execute `./configure` to complete the environment [configure](INSTALL#configure).

Pigsty will check if the current environment meets the installation requirements and generate the recommended config file `pigsty.yml` based on the current machine environment. In the `files/conf/` directory, there are a series of config files named `pigsty-*.yml` that can be used as reference templates for configuration in different scenarios, specified by `-m`.

The Configure installs Ansible, which generally comes with this package as the default source for the node, or from within the offline pkg if it exists.



</details><br>


<details><summary>What is pigsty config inventory?</summary>

!> The source root `pigsty.yml` is the default, unique config source.

Pigsty has one and only one [config file](CONFIG#inventory): [`pigsty.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml) in the source root dir, which describes the state of the entire environment.

In `ansible.cfg` in the same dir: `inventory = pigsty.yml` specifies this file as the default config file, or you can use the `-i` parameter when executing the playbook, restricting the use of a config file from another location. In addition, if you use CMDB as the config source, please modify the config in CMDB.



</details><br>


<details><summary>What is IP address placeholder in config file</summary>

!> Pigsty uses `10.10.10.10` as a placeholder for the current node IP, which will be replaced with the primary IP of the current node during the configure.

When the `configure` detects multiple NICs with multiple IPs on the current node, the config wizard will prompt for the **primary** IP to be used, i.e., **the IP used by the user to access the node from the internal network**. Note that please do not use the public IP.

This IP will be used to replace `10.10.10.10` in the config file template.

</details><br>



<details><summary>Which parameters needs your attention?</summary>

!> Usually, in a singleton installation, there is no need to make any adjustments to the config files.

Pigsty provides 220+ config parameters to customize the entire infra/platform/database.  However, there are a few parameters that can be adjusted in advance if needed:

* When accessing web service components, the domain name is [`infra_portal`](PARAM#infra_portal) (some services can only be accessed using the domain name through the Nginx proxy).
* Pigsty assumes that a `/data` dir exists to hold all data; you can adjust these paths if the data disk mount point differs from this.



</details><br>




----------------

## Installation



<br>
<details><summary>What was executed during installation?</summary>

!> When running `make install`, `ansible-playbook` is called to perform the preconfigured playbook [`infra.yml`](infra.yml) to complete the installation on the meta node.

The `configure` generates the config file by default and marks the current node as an admin  node and an infra node. And `make install` executes the Pigsty meta node initialization playbook `infra.yml`,
deploys the infra components, and initializes the meta node like a normal node on which a singleton PostgreSQL is deployed as CMDB.

</details><br>




<details><summary>Downloading RPM packages is too slow</summary>

!> It is best to use offline packages or configure a [proxy server](PARAM#CONNECT) or a local repo.

Pigsty has used domestic yum repos for downloads whenever possible. However, a few packages are still affected by **GFW**, resulting in slow downloads, such as related software downloaded directly from Github. The following solutions are available.

1. Pigsty provides an offline package, which pre-packages all software and its dependencies, and can skip the step of downloading software from the Internet.

2. Specify a proxy server via [`proxy_env`](PARAM#proxy_env) to download via proxy server.

3. Use other domestic available repos via [`infra_portal`](PARAM#infra_portal).

</details><br>




<details><summary>Remote nodes are not accessible via SSH commands</summary>

!> Specify a different port via the host instance-level [`ansible connection parameters`](PARAM#ansible_host).

Consider using **Ansible connection parameters** if the target machine is hidden behind an SSH springboard machine or if some customizations have been made that cannot be accessed directly using `ssh ip`. Additional SSH ports can be specified with `ansible_port` or `ansible_host` for SSH Alias.

```bash
pg-test:
  vars: { pg_cluster: pg-test }
  hosts:
    10.10.10.11: {pg_seq: 1, pg_role: primary, ansible_host: node-1 }
    10.10.10.12: {pg_seq: 2, pg_role: replica, ansible_port: 22223, ansible_user: admin }
    10.10.10.13: {pg_seq: 3, pg_role: offline, ansible_port: 22224 }
```

</details><br>




<details><summary>Password required for remote node SSH and SUDO</summary>

!> Use the `-k` and `-K` parameters, enter the password at the prompt, and refer to admin provisioning.

**When performing deployments and changes**, the admin user used **must** have `ssh` and `sudo` privileges for all nodes. Password-free is not required.
You can pass in ssh and sudo passwords via the `-k|-K` parameter when executing the playbook or even use another user to run the playbook via `-e`[`ansible_host`](PARAM#connect)`=<another_user>`.
However, Pigsty strongly recommends configuring SSH **passwordless login** with passwordless `sudo` for the admin user.


</details><br>





----------------

## Provision


<br>
<details><summary>How to create local VMs with vagrant</summary>

!> The first time you use Vagrant to pull up a particular OS repo, it will download the corresponding BOX.

Pigsty sandboxes use CentOS 7 by default, and Vagrant will download the `CentOS/7` ISO repo Box the first time the VM is started.

Using a proxy may increase the download speed. Downloading CentOS7 Box only needs to be done the first time the sandbox is started, and will be reused directly when the sandbox is subsequently rebuilt.

Users can also choose to create the required VM manually by downloading the CentOS 7 installation ISO repos.

</details><br>



<details><summary>Virtual machine time out of sync</summary>

!> `sudo ntpdate -u pool.ntp.org`

The time within the VM may not be consistent with the host after the Virtualbox shutdown. You can try the following command: `make sync` to force NTP time sync.

It can solve the problem of no data on the monitoring system after a long hibernation or shutdown and reboot. In addition, restarting the VM can also force a time reset without Internet access: `make dw4; make up4`.

</details><br>




<details><summary>RPMs error on Aliyun CentOS</summary>

!> Aliyun CentOS 7.9 server has DNS caching service `nscd` installed by default. Just remove it.

Aliyun's CentOS 7.9 repo has `nscd` installed by default, locking out the glibc version, which can cause RPM dependency errors during installation.

```bash
"Error: Package: nscd-2.17-307.el7.1.x86_64 (@base)"
```

Run `yum remove -y nscd` on all nodes to resolve this issue, and with Ansible, you can batch.

```bash
ansible all -b -a 'yum remove -y nscd'
```

</details><br>




----------------

## Monitoring


<br>
<details><summary>Performance impact of monitoring exporter</summary>

!> TBD

Not very much, 200ms per 10 ~ 15 seconds.

</details><br>


<details><summary>How to monitoring an existing PostgreSQL instance?</summary>

!> TBD

Check [PGSQL Monitor](PGSQL-MONITOR) for details.

</details><br>


<details><summary>How to remove monitor targets from prometheus?</summary>

!> TBD

```bash
./pgsql-rm.yml -t prometheus -l <cls>     # remove prometheus targets of cluster 'cls'
```

Or

```bash
bin/pgmon-rm <ins>     # shortcut for removing prometheus targets of pgsql instance 'ins'
```

</details><br>


----------------

## INFRA


<br>
<details><summary>Which components are included in INFRA?</summary>

- Ansible for automation, deployment, administration;
- Nginx for exposing any WebUI service and serve the yum repo;
- Self-Signed CA for SSL/TLS certificates;
- Prometheus for monitoring metrics
- Grafana for monitoring/visualization
- Loki for logging collection
- AlertManager for alerts aggregation
- Chronyd for NTP time sync
- DNSMasq for dns registration and resolve
- ETCD as DCS for PGSQL HA; (dedicate module)
- PostgreSQL on meta nodes as CMDB; (optional)
- Docker for stateless application & tools (optional) 


</details><br>



----------------

## NODE


<br>
<details><summary>How to configure NTP service?</summary>

!> If NTP is not configured, use a public NTP service or sync time with the admin node.

If your nodes already have NTP configured, you can leave it be by setting `node_ntp_enabled` to `false`.

Otherwise, if you have the Internet access, you can use public NTP service such as `pool.ntp.org`.

If you don't have Internet access, at least you can sync time with the admin node with:

```bash
node_ntp_servers:                 # NTP servers in /etc/chrony.conf
  - pool cn.pool.ntp.org iburst
  - pool ${admin_ip} iburst       # assume non-admin nodes does not have internet access
```

</details>


<br>
<details><summary>How to sync time on nodes?</summary>

!> Use `chronyc` to sync time. You have to configure NTP service first.

```bash
ansible all -b -a 'chronyc -a makestep'     # sync time
```

You can replace `all` with any group or host IP address to limit execution scope.

</details>



<br>
<details><summary>Create a dedicated admin user with an existing admin user?</summary>

!> `./node.yml -k -K -e ansible_user=<another_admin> -t node_admin`

This will create an admin user specified by [`node_admin_username`](PARAM#node_admin_username) on that node with existing admin user.

</details>


<br>
<details><summary>How to expose service with node HAProxy</summary>

!> TBD

</details><br>









----------------

## ETCD

<br>
<details><summary>How to use existing external etcd cluster?</summary>

!> Define them in the `etcd` group as usual. 

The special group `etcd` will be used as pg dcs servers, you can initialize them with `etcd.yml` or use existing external etcd cluster.

</details><br>


<details><summary>How to add new member to existing etcd cluster?</summary>

!> Check [Add member to etcd cluster](ETCD-ADMIN#add-member)

```bash
etcdctl member add <etcd-?> --learner=true --peer-urls=https://<new_ins_ip>:2380 # on admin node
./etcd.yml -l <new_ins_ip> -e etcd_init=existing                                 # init new etcd member
etcdctl member promote <new_ins_server_id>                                       # on admin node
```

</details><br>


<details><summary>How to remove a member from existing etcd cluster?</summary>

!> Check [Remove member from etcd cluster](ETCD-ADMIN#remove-member)

```bash
etcdctl member remove <etcd_server_id>   # kick member out of cluster (on admin node)
./etcd.yml -l <ins_ip> -t etcd_purge     # purge etcd instance
```


</details><br>




----------------

## MINIO

<br>
<details><summary>How to deploy a multi-node multi-drive MinIO cluster?</summary>

!> TBD

</details><br>


<details><summary>How to add a member to existing MinIO cluster?</summary>

!> TBD

</details><br>





----------------

## REDIS

<br>
<details><summary>Abort due to redis exists?</summary>

!> use `redis_clean = true` and `redis_safeguard = false` to force clean redis data

</details>


<br>
<details><summary>How to add a single new redis instance on node?</summary>

!> Use `bin/redis-add <ip> <port>` to deploy a new redis instance on node.

</details>


<details><summary>How to remove a single redis instance from node?</summary>

!> `bin/redis-rm <ip> <port>` to remove a single redis instance from node

</details><br>




----------------

## PGSQL


<br>
<details><summary>ABORT due to postgres exists</summary>

!> Set `pg_clean` = `true` and `pg_safeguard` = `false` to force clean postgres data during `pgsql.yml`

This is happened when you run `pgsql.yml` on a node that already has postgres running, and [`pg_clean`](PARAM#pg_clean) is set to `false`

If `pg_clean` is true (and the `pg_safeguard` is `false`, too), the `pgsql.yml` playbook will remove the existing pgsql data and re-init it as new one, which makes this playbook fully idempotent.

You can still purge the existing postgres data by using a special tag `pg_purge`

```bash
./pgsql.yml -t pg_clean      # honor pg_clean and pg_safeguard
./pgsql.yml -t pg_purge      # ignore pg_clean and pg_safeguard
```

</details>



<br>
<details><summary>ABORT due to pg_safeguard enabled</summary>

!> If [`pg_safeguard`](PARAM#pg_safeguard) is enabled, you can not run `bin/pgsql-rm` and `pgsql-rm.yml` playbook on that node. 

To disable `pg_safeguard`, you can set `pg_safeguard` to `false` in the inventory, or just passing `-e pg_safeguard=false` as cli arg to playbook:

```bash
./pgsql-rm.yml -e pg_safeguard=false -l <cls_to_remove>    # force override pg_safeguard
```

</details>



<br>
<details><summary>How to create replica when data is corrupted?</summary>

!> Disable `clonefrom` on bad instances and reload patroni config.

Pigsty set the `cloneform: true` tag on all instances' patroni config, which marks the instance available for cloning replica.

If this instance has corrupt data files, you can set `clonefrom: false` to avoid pulling data from the evil instance. To do so:

```bash
$ vi /pg/bin/patroni.yml

tags:
  nofailover: false
  clonefrom: true      ----------> change to false
  noloadbalance: false
  nosync: false
  version:  '15'
  spec: '4C.8G.50G'
  conf: 'oltp.yml'
  
$ systemctl reload patroni
```

</details>



<br>
<details><summary>How enable hugepage for PostgreSQL?</summary>

!> use `node_hugepage_count` and `node_hugepage_ratio` or `/pg/bin/pg-tune-hugepage`

If your planning to enable hugepage, consider using `node_hugepage_count` and `node_hugepage_ratio` and apply with `./node.yml -t node_tune` .

It's a good practice to alloc **enough** hugepage before postgres start, and use `pg_tune_hugepage` to shrink them later.

If your postgres is already running, you can use `/pg/bin/pg-tune-hugepage` to enable hugepage on the fly.

```bash
sync; echo 3 > /proc/sys/vm/drop_caches   # drop system cache (ready for performance impact)
sudo /pg/bin/pg-tune-hugepage             # write nr_hugepages to /etc/sysctl.d/hugepage.conf
pg restart <cls>                          # restart postgres to use hugepage
```

</details>


<br>
<details><summary>How to guarantee 0 data loss during failover?</summary>

!> Use `crit.yml` template, or setting `pg_rpo` to `0`, or [config cluster](PGSQL-ADMIN#config-cluster) with synchronous mode.

Consider using [sync standby](PGSQL-CONF#sync-standby), [quorum-commit](PGSQL-CONF#quorum-commit) to guarantee 0 data loss during failover.

</details>



<br>
<details><summary>How to survive from disk full?</summary>

!> `rm -rf /pg/dummy` will free some emergency space. 

The [`pg_dummy_filesize`](PARAM#pg_dummy_filesize) is set to `64MB` by default, consider increase it to `8GB` or larger in production environment.

It will be placed on `/pg/dummy` same disk as postgres main data disk, you can remove that file to free some emergency space, at least you can run some shell scripts on that node.

</details>



