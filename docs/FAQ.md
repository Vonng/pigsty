# Pigsty FAQ

> Here are some frequently asked questions. 
> 
> If you have any unlisted questions or suggestions, please create an [Issue](https://github.com/Vonng/pigsty/issues/new) or ask the [community](README#about) for help.


----------------

## Preparation


<br>
<details><summary>Node Requirement</summary>

CPU Architecture: `x86_64` only. Pigsty does not support `ARM` yet.

CPU Number: **1** core for common node, at least **2** for admin node.

Memory: at least **1GB** for the common node and **2GB** for the admin node.

Using at least 3~4 x (2C / 4G / 100G) nodes for serious production deployment is recommended.

</details><br>



<details><summary>OS Requirement</summary>

Pigsty is now developed and tested on CentOS 7.9, Rocky 8.6 & 9.1. RHEL, Alma, Oracle, and any EL-compatible distribution also work.

We strongly recommend using EL 7.9, 8.6, and 9.1 to avoid meaningless efforts on RPM troubleshooting.

And PLEASE USE FRESH NEW NODES to avoid any unexpected issues.

</details><br>



<details><summary>Versioning Policy</summary>

!> Please always use a **version-specific** [release](https://github.com/Vonng/pigsty/releases), do not use the GitHub `master` branch unless you know what you are doing.

Pigsty uses semantic version numbers such as: `<major>. <minor>. <release>`. Alpha/Beta/RC are suffixed to the version number `-a1`, `-b1`, `-rc1`.

Major updates mean fundamental changes and massive features; minor version updates suggest new features, bump package versions, and minor API changes. Release version updates mean bug fixes and doc updates, and it does change offline package versions (i.e., v1.0.1 and v1.0.0 will use the same `pkg.tgz`).

Pigsty tries to release a Minor Release every 1-3 months and a Major Release every 1-2 years.

</details><br>




----------------

## Download


<br>
<details><summary>Where to download the Pigsty source code?</summary>

!> `bash -c "$(curl -fsSL http://get.pigsty.cc/latest)"`

The above command will automatically download the latest stable version of `pigsty.tgz` and extract it to the `~/pigsty` dir.
You can also manually download a specific version of Pigsty source code from the following location.

If you need to install it in an environment without the Internet, you can download it in advance and upload it to the production server via scp/sftp.

</details><br>


<details><summary>How to accelerate RPM downloading from the upstream repo?</summary>

Consider using the upstream repo mirror of your region. Define them with [`repo_upstream`](PARAM#repo_upstream) and [`region`](PARAM#region).

For example, you can use `region` = `china`, and the baseurl with key = `china` will be used instead of the `default`.

If a firewall or GFW blocks some repo, consider using a [`proxy_env`](PARAM#proxy_env) to bypass that.

</details><br>


<details><summary>Where to download pigsty offline packages</summary>

Offline packages can be downloaded during [`bootstrap`](INSTALL#bootstrap), or you can download them directly via:

```bash
https://github.com/Vonng/pigsty/releases/download/v2.2.0/pigsty-v2.2.0.tgz                   # source code
https://github.com/Vonng/pigsty/releases/download/v2.2.0/pigsty-pkg-v2.2.0.el7.x86_64.tgz    # el7 packages
https://github.com/Vonng/pigsty/releases/download/v2.2.0/pigsty-pkg-v2.2.0.el8.x86_64.tgz    # el8 packages
https://github.com/Vonng/pigsty/releases/download/v2.2.0/pigsty-pkg-v2.2.0.el9.x86_64.tgz    # el9 packages
```

</details><br>



----------------

## Configuration


<br>
<details><summary>What does configure do?</summary>

!> Detect the environment, generate the configuration, enable the offline package (optional), and install the essential tool Ansible.

After downloading the Pigsty source package and unpacking it, you may have to execute `./configure` to complete the environment [configuration](INSTALL#configure). This is optional if you already know how to configure Pigsty properly.

The **configure** procedure will detect your node environment and generate a pigsty config file: `pigsty.yml` for you.

</details>



<br>

<details><summary>What is the Pigsty config file?</summary>

!> `pigsty.yml` under the pigsty home dir is the default config file.

Pigsty uses a single config file `pigsty.yml,` to describe the entire environment, and you can define everything there. There are many config examples in [`files/pigsty`](https://github.com/Vonng/pigsty/tree/master/files/pigsty) for your reference.

You can pass the `-i <path>` to playbooks to use other configuration files. For example, you want to install redis according to another config: `redis.yml`:

```bash
./redis.yml -i files/pigsty/redis.yml
```

</details>



<br>
<details><summary>How to use the CMDB as config inventory</summary>

The default config file path is specified in [`ansible.cfg`](https://github.com/Vonng/pigsty/blob/master/ansible.cfg): `inventory = pigsty.yml`

You can switch to a dynamic CMDB inventory with [`bin/inventory_cmdb`](https://github.com/Vonng/pigsty/blob/master/bin/inventory_cmdb), and switch back to the local config file with [`bin/inventory_conf`](https://github.com/Vonng/pigsty/blob/master/bin/inventory_conf). You must also load the current config file inventory to CMDB with [`bin/inventory_load`](https://github.com/Vonng/pigsty/blob/master/bin/inventory_load).

If CMDB is used, you must edit the inventory config from the database rather than the config file.

</details>




<br>
<details><summary>What is the IP address placeholder in the config file?</summary>

!> Pigsty uses `10.10.10.10` as a placeholder for the current node IP, which will be replaced with the primary IP of the current node during the configuration.

When the `configure` detects multiple NICs with multiple IPs on the current node, the config wizard will prompt for the **primary** IP to be used, i.e., **the IP used by the user to access the node from the internal network**. Note that please do not use the public IP.

This IP will be used to replace `10.10.10.10` in the config file template.

</details>



<br>
<details><summary>Which parameters need your attention?</summary>

!> Usually, in a singleton installation, there is no need to make any adjustments to the config files.

Pigsty provides 265 config parameters to customize the entire infra/node/etcd/minio/pgsql.  However, there are a few parameters that can be adjusted in advance if needed:

* When accessing web service components, the domain name is [`infra_portal`](PARAM#infra_portal) (some services can only be accessed using the domain name through the Nginx proxy).
* Pigsty assumes that a `/data` dir exists to hold all data; you can adjust these paths if the data disk mount point differs from this.
* Don't forget to change those **passwords** in the config file for your production deployment.

</details>




----------------

## Installation


<br>
<details><summary>What was executed during installation?</summary>

!> When running `make install`, the ansible-playbook [`install.yml`](https://github.com/Vonng/pigsty/blob/master/install.yml) will be invoked to install everything on all nodes

Which will:

- Install `INFRA` module on the current node.
- Install `NODE` module on the current node.
- Install `ETCD` module on the current node.
- The `MinIO` module is optional, and will not be installed by default.
- Install `PGSQL` module on the current node.

</details>



<br>
<details><summary>How to resolve RPM conflict?</summary>

There may have a slight chance that rpm conflict occurs during node/infra/pgsql packages installation.

The simplest way to resolve this is to install without offline packages, which will download directly from the upstream repo.

If there are only a few problematic RPMs, you can use a trick to fix the yum repo quickly:

```bash
rm -rf /www/pigsty/repo_complete    # delete the repo_complete flag file to mark this repo incomplete
rm -rf SomeBrokenRPMPackages        # delete problematic RPMs
./infra.yml -t repo_upstream        # write upstream repos. you can also use /etc/yum.repos.d/backup/*
./infra.yml -t repo_pkg             # download rpms according to your current OS
```

</details>



<br>
<details><summary>How to create local VMs with vagrant</summary>

!> The first time you use Vagrant to pull up a particular OS repo, it will download the corresponding BOX.

Pigsty sandbox uses `generic/rocky9` image box by default, and Vagrant will download the `rocky/9` box for the first time the VM is started.

Using a proxy may increase the download speed. Box only needs to be downloaded once, and will be reused when recreating the sandbox.


</details>



<br>

<details><summary>RPMs error on Aliyun CentOS 7.9</summary>

!> Aliyun CentOS 7.9 server has DNS caching service `nscd` installed by default. Just remove it.

Aliyun's CentOS 7.9 repo has `nscd` installed by default, locking out the glibc version, which can cause RPM dependency errors during installation.

```bash
"Error: Package: nscd-2.17-307.el7.1.x86_64 (@base)"
```

Run `yum remove -y nscd` on all nodes to resolve this issue, and with Ansible, you can batch.

```bash
ansible all -b -a 'yum remove -y nscd'
```

</details>



<br>

<details><summary>RPMs error on Tencent Qcloud Rocky 9.1</summary>

!> Tencent Qcloud Rocky 9.1 require extra `annobin` packages

```bash
./infra.yml -t repo_upstream      # add upstream repos
cd /www/pigsty;                   # download missing packages
repotrack annobin gcc-plugin-annobin libuser
./infra.yml -t repo_create        # create repo
```

</details>




<br>

<details><summary>Ansible command timeout (Timeout waiting for xxx）</summary>

The default ssh timeout for ansible command is 10 seconds, some commands may take longer than that due to network latency or other reasons. 

You can increase the timeout parameter in the ansible config file [`ansible.cfg`](https://github.com/Vonng/pigsty/blob/master/ansible.cfg):

```ini
[defaults]
timeout = 10 # change to 60,120 or more
```

</details>




----------------

## Monitoring


<br>
<details><summary>Performance impact of monitoring exporter</summary>

Not very much, 200ms per 10 ~ 15 seconds.

</details>



<br>

<details><summary>How to monitor an existing PostgreSQL instance?</summary>

Check [PGSQL Monitor](PGSQL-MONITOR) for details.

</details>

<br>

<details><summary>How to remove monitor targets from prometheus?</summary>

```bash
./pgsql-rm.yml -t prometheus -l <cls>     # remove prometheus targets of cluster 'cls'
```

Or

```bash
bin/pgmon-rm <ins>     # shortcut for removing prometheus targets of pgsql instance 'ins'
```

</details>






----------------

## INFRA


<br>
<details><summary>Which components are included in INFRA</summary>

- Ansible for automation, deployment, and administration;
- Nginx for exposing any WebUI service and serving the yum repo;
- Self-Signed CA for SSL/TLS certificates;
- Prometheus for monitoring metrics
- Grafana for monitoring/visualization
- Loki for logging collection
- AlertManager for alerts aggregation
- Chronyd for NTP time sync on the admin node.
- DNSMasq for DNS registration and resolution.
- ETCD as DCS for PGSQL HA; (dedicated module)
- PostgreSQL on meta nodes as CMDB; (optional)
- Docker for stateless applications & tools (optional)

</details>


<br>
<details><summary>How to restore Prometheus targets</summary>

If you accidentally deleted the Prometheus targets dir, you can register monitoring targets to Prometheus again with the:

```bash
./infra.yml -t register_prometheus  # register all infra targets to prometheus on infra nodes
./node.yml  -t register_prometheus  # register all node  targets to prometheus on infra nodes
./etcd.yml  -t register_prometheus  # register all etcd targets to prometheus on infra nodes
./minio.yml -t register_prometheus  # register all minio targets to prometheus on infra nodes
./pgsql.yml -t register_prometheus  # register all pgsql targets to prometheus on infra nodes
```

</details>



<br>
<details><summary>How to restore Grafana datasource</summary>

PGSQL Databases in [`pg_databases`](PARAM#pg_databases) are registered as Grafana datasource by default.

If you accidentally deleted the registered postgres datasource in Grafana, you can register them again with

```bash
./pgsql.yml -t register_grafana  # register all pgsql database (in pg_databases) as grafana datasource
```

</details>



<br>
<details><summary>How to restore the HAProxy admin page proxy</summary>

The haproxy admin page is proxied by Nginx under the default server.

If you accidentally deleted the registered haproxy proxy settings in `/etc/nginx/conf.d/haproxy`, you can restore them again with

```bash
./node.yml -t register_nginx     # register all haproxy admin page proxy settings to nginx on infra nodes
```

</details>



<br>
<details><summary>How to restore the DNS registration</summary>

PGSQL cluster/instance domain names are registered to `/etc/hosts.d/<name>` on infra nodes by default.

You can restore them again with the following:

```bash
./pgsql.yml -t pg_dns   # register pg DNS names to dnsmasq on infra nodes
```

</details>




<br>
<details><summary>How to expose new Nginx upstream service</summary>

If you wish to expose a new WebUI service via the Nginx portal, you can add the service definition to the [`infra_portal`](PARAM#infra_portal) parameter.

And re-run `./infra.yml -t nginx_config,nginx_launch` to update & apply the Nginx configuration.

If you wish to access with HTTPS, you must remove `files/pki/csr/pigsty.csr`, `files/pki/nginx/pigsty.{key,crt}` to force re-generating the Nginx SSL/TLS certificate to include the new upstream's domain name.

</details>




<br>
<details><summary>How to manually add upstream repo files</summary>

Pigsty has a built-in wrap script `bin/repo-add`, which will invoke ansible playbook `node.yml` to adding repo files to corresponding nodes.

```bash
bin/repo-add <selector> [modules]
bin/repo-add 10.10.10.10           # add node repos for node 10.10.10.10
bin/repo-add infra   node,infra    # add node and infra repos for group infra
bin/repo-add infra   node,local    # add node repos and local pigsty repo
bin/repo-add pg-test node,pgsql    # add node & pgsql repos for group pg-test
```

</details>




----------------

## NODE


<br>
<details><summary>How to configure NTP service?</summary>

!> If NTP is not configured, use a public NTP service or sync time with the admin node.

If your nodes already have NTP configured, you can leave it there by setting `node_ntp_enabled` to `false`.

Otherwise, if you have Internet access, you can use public NTP services such as `pool.ntp.org`.

If you don't have Internet access, at least you can sync time with the admin node with the following:

```bash
node_ntp_servers:                 # NTP servers in /etc/chrony.conf
  - pool cn.pool.ntp.org iburst
  - pool ${admin_ip} iburst       # assume non-admin nodes do not have internet access
```

</details>




<br>
<details><summary>How to force sync time on nodes?</summary>

!> Use `chronyc` to sync time. You have to configure the NTP service first.

```bash
ansible all -b -a 'chronyc -a makestep'     # sync time
```

You can replace `all` with any group or host IP address to limit execution scope.

</details>



<br>
<details><summary>Remote nodes are not accessible via SSH commands.</summary>

!> Specify a different port via the host instance-level [`ansible connection parameters`](PARAM#ansible_host).

Consider using **Ansible connection parameters** if the target machine is hidden behind an SSH springboard machine,
or if some customizations have been made that cannot be accessed directly using `ssh ip`.
Additional SSH ports can be specified with `ansible_port` or `ansible_host` for SSH Alias.

```bash
pg-test:
  vars: { pg_cluster: pg-test }
  hosts:
    10.10.10.11: {pg_seq: 1, pg_role: primary, ansible_host: node-1 }
    10.10.10.12: {pg_seq: 2, pg_role: replica, ansible_port: 22223, ansible_user: admin }
    10.10.10.13: {pg_seq: 3, pg_role: offline, ansible_port: 22224 }
```

</details>




<br>
<details><summary>Password required for remote node SSH and SUDO</summary>

!> Use the `-k` and `-K` parameters, enter the password at the prompt, and refer to admin provisioning.

**When performing deployments and changes**, the admin user used **must** have `ssh` and `sudo` privileges for all nodes. Password-free is not required.
You can pass in ssh and sudo passwords via the `-k|-K` parameter when executing the playbook or even use another user to run the playbook via `-e`[`ansible_host`](PARAM#connect)`=<another_user>`.
However, Pigsty strongly recommends configuring SSH **passwordless login** with passwordless `sudo` for the admin user.

</details>



<br>
<details><summary>Create an admin user with the existing admin user.</summary>

!> `./node.yml -k -K -e ansible_user=<another_admin> -t node_admin`

This will create an admin user specified by [`node_admin_username`](PARAM#node_admin_username) with the existing one on that node.

</details>




<br>
<details><summary>Exposing node services with HAProxy</summary>

!> You can expose service with [`haproxy_services`](PARAM#haproxy_services) in `node.yml`.

And here's an example of exposing MinIO service with it: [Expose MinIO Service](MINIO#expose-service)

</details>




<br>
<details><summary>Why my nodes /etc/yum.repos.d/* are nuked?</summary>

Pigsty will try to include all dependencies in the local yum repo on infra nodes. This repo file will be added according to [`node_repo_local_urls`](PARAM#node_repo_local_urls).
And existing repo files will be removed by default according to the default value of [`node_repo_remove`](PARAM#node_repo_remove). This will prevent the node from using the Internet repo or some stupid issues.

If you want to keep existing repo files, just set [`node_repo_remove`](PARAM#node_repo_remove) to `false`.

</details>







----------------

## ETCD


<br>
<details><summary>What is the impact of ETCD failure?</summary>
[ETCD](ETCD) availability is critical for the PGSQL cluster's HA, which is guaranteed by using multiple nodes.
With a 3-node ETCD cluster, if one node is down, the other two nodes can still function normally; and with a 5-node ETCD cluster, two-node failure can still be tolerated.
If more than half of the ETCD nodes are down, the ETCD cluster and its service will be unavailable.
Before Patroni 3.0, this could lead to a global [PGSQL](PGSQL) outage; all primary will be demoted and reject write requests.

Since pigsty 2.0, the patroni 3.0 [DCS failsafe mode](https://patroni.readthedocs.io/en/master/dcs_failsafe_mode.html) is enabled by default, which will **LOCK** the PGSQL cluster status if the ETCD cluster is unavailable and all PGSQL members are still known to the primary.

The PGSQL cluster can still function normally, but you must recover the ETCD cluster ASAP. (you can't configure the PGSQL cluster through patroni if etcd is down)

</details>



<br>
<details><summary>How to use existing external etcd cluster?</summary>
The hard-coded group, `etcd`, will be used as DCS servers for PGSQL. You can initialize them with `etcd.yml` or assume it is an existing external etcd cluster.

To use an existing external etcd cluster, define them as usual and make sure your current etcd cluster certificate is signed by the same CA as your self-signed CA for PGSQL.

</details>



<br>
<details><summary>How to add a new member to the existing etcd cluster?</summary>

!> Check [Add a member to etcd cluster](ETCD-ADMIN#add-member)

```bash
etcdctl member add <etcd-?> --learner=true --peer-urls=https://<new_ins_ip>:2380 # on admin node
./etcd.yml -l <new_ins_ip> -e etcd_init=existing                                 # init new etcd member
etcdctl member promote <new_ins_server_id>                                       # on admin node
```

</details>



<br>
<details><summary>How to remove a member from an existing etcd cluster?</summary>

!> Check [Remove member from etcd cluster](ETCD-ADMIN#remove-member)

```bash
etcdctl member remove <etcd_server_id>   # kick member out of the cluster (on admin node)
./etcd.yml -l <ins_ip> -t etcd_purge     # purge etcd instance
```

</details>






----------------

## MINIO


<br>
<details><summary>Fail to launch multi-node / multi-driver MinIO cluster.</summary>

In [Multi-Driver](MINIO#single-node-multi-drive) or [Multi-Node](MINIO#multi-node-multi-drive) mode, MinIO will refuse to start if the data dir is not a valid mount point.

Use mounted disks for MinIO data dir rather than some regular directory. You can use the regular directory only in the [single node, single drive](MINIO#single-node-single-drive) mode.

</details>




<br>
<details><summary>How to deploy a multi-node multi-drive MinIO cluster?</summary>

!> Check [Create Multi-Node Multi-Driver MinIO Cluster](MINIO#multi-node-multi-drive)

</details>



<br>
<details><summary>How to add a member to the existing MinIO cluster?</summary>

!> You'd better plan the MinIO cluster before deployment... Since this requires a global restart

Check this: [Expand MinIO Deployment](https://min.io/docs/minio/linux/operations/install-deploy-manage/expand-minio-deployment.html)

</details>



<br>
<details><summary>How to use a HA MinIO deployment for PGSQL?</summary>

!> Access the HA MinIO cluster with an optional load balancer and different ports.

Here is an example: [Access MinIO Service](MINIO#access-service)

</details>






----------------

## REDIS

<br>
<details><summary>ABORT due to existing redis instance</summary>

!> use `redis_clean = true` and `redis_safeguard = false` to force clean redis data

This happens when you run `redis.yml` to init a redis instance that is already running, and [`redis_clean`](PARAM#redis_clean) is set to `false`.

If `redis_clean` is set to `true` (and the `redis_safeguard` is set to `false`, too), the `redis.yml` playbook will remove the existing redis instance and re-init it as a new one, which makes the `redis.yml` playbook fully idempotent.

</details>



<br>

<details><summary>ABORT due to redis_safeguard enabled</summary>

!> This happens when removing a redis instance with [`redis_safeguard`](PARAM#redis_safeguard) set to `true`.

You can disable [`redis_safeguard`](PARAM#redis_safeguard) to remove the Redis instance. This is redis_safeguard is what it is for.

</details>



<br>
<details><summary>How to add a single new redis instance on this node?</summary>

!> Use `bin/redis-add <ip> <port>` to deploy a new redis instance on node.

</details>



<br>
<details><summary>How to remove a single redis instance from the node?</summary>

!> `bin/redis-rm <ip> <port>` to remove a single redis instance from node

</details>





----------------

## PGSQL

<br>
<details><summary>ABORT due to postgres exists</summary>

!> Set `pg_clean` = `true` and `pg_safeguard` = `false` to force clean postgres data during `pgsql.yml`

This happens when you run `pgsql.yml` on a node with postgres running, and [`pg_clean`](PARAM#pg_clean) is set to `false`.

If `pg_clean` is true (and the `pg_safeguard` is `false`, too), the `pgsql.yml` playbook will remove the existing pgsql data and re-init it as a new one, which makes this playbook fully idempotent.

You can still purge the existing PostgreSQL data by using a special task tag `pg_purge`

```bash
./pgsql.yml -t pg_clean      # honor pg_clean and pg_safeguard
./pgsql.yml -t pg_purge      # ignore pg_clean and pg_safeguard
```

</details>



<br>
<details><summary>ABORT due to pg_safeguard enabled</summary>

!> Disable `pg_safeguard` to remove the Postgres instance.

If [`pg_safeguard`](PARAM#pg_safeguard) is enabled, you can not remove the running pgsql instance with `bin/pgsql-rm` and `pgsql-rm.yml` playbook.

To disable `pg_safeguard`, you can set `pg_safeguard` to `false` in the inventory or pass `-e pg_safeguard=false` as cli arg to the playbook:

```bash
./pgsql-rm.yml -e pg_safeguard=false -l <cls_to_remove>    # force override pg_safeguard
```

</details>



<br>
<details><summary>Fail to wait for postgres/patroni primary</summary>

This usually happens when the cluster is misconfigured, or the previous primary is improperly removed. (e.g., trash metadata in DCS with the same cluster name).

You must check `/pg/log/*` to find the reason.

</details>




<br>
<details><summary>Fail to wait for postgres/patroni replica</summary>

There are several possible reasons:

**Failed Immediately**: Usually, this happens because of misconfiguration, network issues, broken DCS metadata, etc..., you have to inspect `/pg/log` to find out the actual reason.

**Failed After a While**: This may be due to source instance data corruption. Check PGSQL FAQ: How to create replicas when data is corrupted?

**Timeout**: If the `wait for postgres replica` task takes 30min or more and fails due to timeout, This is common for a huge cluster (e.g., 1TB+, which may take hours to create a replica). In this case, the underlying creating replica procedure is still proceeding. You can check cluster status with `pg list <cls>` and wait until the replica catches up with the primary. Then continue the following tasks:

```bash
./pgsql.yml -t pg_hba,pg_backup,pgbouncer,pg_vip,pg_dns,pg_service,pg_exporter,pg_register
```

</details>




<br>
<details><summary>Install PostgreSQL 12 - 14, and 16 beta</summary>

To install PostgreSQL 12 - 15, you have to set `pg_version` to `12`, `13`, `14`, or `15` in the inventory. (usually at cluster level)

To install PostgreSQL 16 beta, you have to change `pg_libs` and `pg_extensions` too, since most extensions are not available for pg16 yet.

```yaml
pg_version: 16                    # install pg 16 in this template
pg_libs: 'pg_stat_statements, auto_explain' # remove timescaledb from pg 16 beta
pg_extensions: []                 # missing pg16 extensions for now
```

</details>




<br>
<details><summary>How enable hugepage for PostgreSQL?</summary>

!> use `node_hugepage_count` and `node_hugepage_ratio` or `/pg/bin/pg-tune-hugepage`

If you plan to enable hugepage, consider using `node_hugepage_count` and `node_hugepage_ratio` and apply with `./node.yml -t node_tune` .

It's good to allocate **enough** hugepage before postgres start, and use `pg_tune_hugepage` to shrink them later.

If your postgres is already running, you can use `/pg/bin/pg-tune-hugepage` to enable hugepage on the fly.

```bash
sync; echo 3 > /proc/sys/vm/drop_caches   # drop system cache (ready for performance impact)
sudo /pg/bin/pg-tune-hugepage             # write nr_hugepages to /etc/sysctl.d/hugepage.conf
pg restart <cls>                          # restart postgres to use hugepage
```

</details>




<br>
<details><summary>How to guarantee zero data loss during failover?</summary>

!> Use `crit.yml` template, or setting `pg_rpo` to `0`, or [config cluster](PGSQL-ADMIN#config-cluster) with synchronous mode.

Consider using [Sync Standby](PGSQL-CONF#sync-standby) and [Quorum Comit](PGSQL-CONF#quorum-commit) to guarantee 0 data loss during failover.

</details>




<br>
<details><summary>How to survive from disk full?</summary>

!> `rm -rf /pg/dummy` will free some emergency space.

The [`pg_dummy_filesize`](PARAM#pg_dummy_filesize) is set to `64MB` by default. Consider increasing it to `8GB` or larger in the production environment.

It will be placed on `/pg/dummy` same disk as the PGSQL main data disk. You can remove that file to free some emergency space. At least you can run some shell scripts on that node.

</details>






<br>
<details><summary>How to create replicas when data is corrupted?</summary>

!> Disable `clonefrom` on bad instances and reload patroni config.

Pigsty sets the `cloneform: true` tag on all instances' patroni config, which marks the instance available for cloning replica.

If this instance has corrupt data files, you can set `clonefrom: false` to avoid pulling data from the evil instance. To do so:

```bash
$ vi /pg/bin/patroni.yml

tags:
  nofailover: false
  clonefrom: true      # ----------> change to false
  noloadbalance: false
  nosync: false
  version:  '15'
  spec: '4C.8G.50G'
  conf: 'oltp.yml'
  
$ systemctl reload patroni
```

</details>






<br>
<details><summary>How to create replicas when data is corrupted?</summary>

!> Disable `clonefrom` on bad instances and reload patroni config.

Pigsty sets the `cloneform: true` tag on all instances' patroni config, which marks the instance available for cloning replica.

If this instance has corrupt data files, you can set `clonefrom: false` to avoid pulling data from the evil instance. To do so:

```bash
$ vi /pg/bin/patroni.yml

tags:
  nofailover: false
  clonefrom: true      # ----------> change to false
  noloadbalance: false
  nosync: false
  version:  '15'
  spec: '4C.8G.50G'
  conf: 'oltp.yml'
  
$ systemctl reload patroni
```

</details>