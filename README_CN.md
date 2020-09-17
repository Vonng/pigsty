# Pigsty —— 图形化PostgreSQL环境

> PIGSTY: Postgres in Graphic STYle （图形化PostgreSQL环境）

本项目为图形化PostgreSQL的演示项目，带有一个演示版本的pigsty监控系统。

本项目可以直接用于开发、测试、生产环境。针对本地开发，亦提供了基于[vagrant](https://vagrantup.com/)的沙箱环境（四虚机节点）



## 亮点

* 高可用PostgreSQL数据库集群，生产验证的部署方案
* 自包含的监控、报警、日志收集系统，基于DCS的自动服务发现
* 自包含的本地源，离线安装所有依赖，无需外网访问。
* 针对四种主要场景：OLTP，OLAP，核心库，虚拟机进行专项优化
* 常用管理，维护，备份，恢复脚本
* 参数化，声明式定义的基础设施，幂等式的执行方式。

  


## 快速开始

1. 准备若干台机器，选定其中一台作为中控机，配置从中控机到其他机器的SSH免密访问，并在中控机上安装Ansible
2. 在中控机上克隆本项目：`git clone https://github.com/vonng/pigsty && cd pigsty`
3. 根据需求修改配置文件根据需求修改全局参数
  * `cls/inventory.yml`定义了目标机器的连接信息与主机级变量，通常需要修改其中的机器IP信息。
  * `group_vars/all.yml`定义了默认的组变量，包含全局一致的基础设施配置信息，通常只需修改少量基础设施定义（例如DCS，DNS，NTP等服务位置）
  * `templates/*.yml`定义了数据库的通用初始化规格，通常不需要修改，通过`-e pg_conf=*.yml`使用预定义的模板即可
  * `templates/*.sh`定义了数据库的定制初始化逻辑，通常按照用户需求更改，通过`-e pg_init=*.sh`使用预定义或自定义的脚本即可
4. 执行`./infra.yml`，在所有机器上初始化基础设施
5. 执行`./postgres.yml`，在所有机器上初始化数据库 

初始化完成后，可以访问控制节点3000端口，admin:admin查看Grafana监控。


## 配置详情

项目的配置文件分为四部分：

**全局变量定义**

全局变量默认定义于`group_vars/all.yml`，针对不同的环境（开发，测试，生产），可以使用不同的全局变量，并通过软连接将`all.yml`指向对应的环境配置。
全局变量针对所有机器生效，当用户希望使用统一的配置时，例如在所有机器上配置相同的 DNS，NTP Server，安装相同的软件包，使用统一的su密码时，可以修改全局变量
全局变量定义分为8个部分，具体的配置项请参阅文档

* 连接信息
* 本地源定义
* 机器节点初始化
* 控制节点初始化
* DCS元数据库初始化
* Postgres安装
* Postgres集群初始化
* 监控初始化
* 负载均衡代理初始化



**主机变量定义**

主机清单（IP，ssh信息，主机变量）默认定义于`cls/inventory.yml`，该文件包含了一套环境中所有主机相关的信息。可以通过`ansible -i <path>`使用其他的主机清单文件。
主机清单使用`ini`格式，定义了一系列分组，默认分组`meta`包含了控制节点的信息。其他分组每个都包含了一个数据库集群的定义。
例如，下面的例子定义了一个名为`pg-test`的集群，其中有三个实例，`10.10.10.11`为主库，`10.10.10.12`与`10.10.10.13`为从库，安装12版本的PostgreSQL数据库。

```ini
[pg-test]
10.10.10.11 ansible_host=node-1 pg_role=primary pg_seq=1
10.10.10.12 ansible_host=node-2 pg_role=replica pg_seq=2
10.10.10.13 ansible_host=node-3 pg_role=replica pg_seq=3

[pg-test:vars]
pg_cluster = pg-test
pg_version = 12
```

**数据库初始化模板**

初始化模板是用于初始化数据库集群的定义文件，默认位于`roles/postgres/templates/patroni.yml`，采用`patroni.yml` [配置文件格式](https://patroni.readthedocs.io/en/latest/SETTINGS.html)
在[`templates/`](templates/)目录中，有四种预定义好的初始化模板：
* [`oltp.yml`](oltp.yml) 常规OLTP模板，默认配置
* [`olap.yml`](olap.yml) OLAP模板，提高并行度，针对吞吐量优化，针对长时间运行的查询进行优化。
* [`crit.yml`](crit.yml) 核心业务模板，基于OLTP模板针对安全性，数据完整性进行优化，采用同步复制，启用数据校验和。
* [`tiny.yml`](tiny.yml) 微型数据库模板，针对低资源场景进行优化，例如运行于虚拟机中的演示数据库集群。

用户也可以基于上述模板进行定制与修改，并通过`pg_conf`参数使用相应的模板。


**数据库初始化脚本**

当数据库初始化完毕后，用户通常希望对数据库进行自定义的定制脚本，例如创建统一的默认角色，用户，创建默认的模式，配置默认权限等。
本项目提供了一个默认的初始化脚本`roles/postgres/templates/initdb.sh`，基于以下几个变量创建默认的数据库与用户。

```yaml
pg_default_username: postgres                 # non 'postgres' will create a default admin user (not superuser)
pg_default_password: postgres                 # dbsu password, omit for 'postgres'
pg_default_database: postgres                 # non 'postgres' will create a default database
pg_default_schema: public                     # default schema will be create under default database and used as first element of search_path
pg_default_extensions: "tablefunc,postgres_fdw,file_fdw,btree_gist,btree_gin,pg_trgm"
```

用户可以基于本脚本进行定制，并通过`pg_init`参数使用相应的自定义脚本。



> #### Note 
>
> It may takes around 5m to download all packages (1GB). But with poor network condition (e.g. Mainland China), it may take around 30m or more. 
> Consider using a local [http proxy](group_vars/dev.yml), and don't forget to make a local cache via  `make cache` after bootstrap. 
>
>  [Grafana](http://grafana.pigsty) default credential: `user=admin pass=admin`, if required.



## Inventory

Default inventory file are split into two files:

* common variables and default values are define in [group_vars/all.yml](group_vars/all.yml) using group variables (for group `all`) (example for vagrant [dev](group_vars/dev.yml) env) 

* Ad hoc variables are defined in [cls/inventory.ini](cls/inventory.ini) using host/group variables (example for vagrant [dev](cls/dev.ini) env)


## Playbooks


* [`infra.yml`](infra.yml) will bootstrap entire infrastructure on given inventory

* [`initdb.yml`](initdb.yml) will bootstrap a PostgreSQL cluster according to your inventory (infrastructure should be initialized before initdb)



### **Database Administration (TBD)**

* admin-report.yml
* admin-backup.yml
* admin-repack.yml
* admin-vacuum.yml
* admin-deploy.yml
* admin-restart.yml
* admin-reload.yml
* admin-createdb.yml
* admin-createuser.yml
* admin-edit-hba.yml
* admin-edit-config.yml
* admin-dump-schema.yml
* admin-dump-table.yml
* admin-copy-data.yml
* admin-pg-exporter-reload.yml

### **Database HA**

* ha-switchover.yml
* ha-failover.yml
* ha-election.yml
* ha-rewind.yml
* ha-restore.yml
* ha-pitr.yml
* ha-drain.yml
* ha-proxy-add.yml
* ha-proxy-remove.yml
* ha-proxy-switch.yml
* ha-repl-report.yml
* ha-repl-sync.yml
* ha-repl-retarget.yml
* ha-pool-retarget.yml
* ha-pool-pause.yml
* ha-pool-resume.yml

Take `init-meta.yml` for example, here are tasks executed by this playbook 

```bash
playbook: ./infra.yml

  play #1 (meta): Init local repo							TAGS: [repo]
    tasks:
      repo : Create local repo directory					TAGS: [repo_dir]
      repo : Check repo boot cache exists					TAGS: [repo_boot]
      repo : Check repo cache exists						TAGS: [repo_download]
      repo : Remove existing repos							TAGS: [repo_upstream]
      repo : Add upstream repos								TAGS: [repo_upstream]
      repo : Remake yum cache if cache not exists			TAGS: [repo_upstream]
      repo : Disable upstream yum repo if cache exists		TAGS: [repo_upstream]
      repo : Download repo boot packages					TAGS: [repo_boot]
      repo : Install bootstrap packages						TAGS: [repo_boot]
      repo : Render repo nginx files						TAGS: [repo_boot]
      repo : Disable selinux								TAGS: [repo_boot]
      repo : Start repo nginx server						TAGS: [repo_boot]
      repo : Waits repo server online						TAGS: [repo_boot]
      repo : Mark bootstrap cache valid						TAGS: [repo_boot]
      repo : Download repo packages							TAGS: [repo_download]
      repo : Download additional url packages				TAGS: [repo_download]
      repo : Create local yum repo index					TAGS: [repo_download]
      repo : Mark repo cache valid							TAGS: [repo_download]

  play #2 (all): Provision Node								TAGS: [node]
    tasks:
      node : Write static dns record to node				TAGS: [node_dns]
      node : Get old nameservers							TAGS: [node_resolv]
      node : Truncate resolv file							TAGS: [node_resolv]
      node : Write resolv options							TAGS: [node_resolv]
      node : Add nameservers								TAGS: [node_resolv]
      node : Append old nameservers if needed				TAGS: [node_resolv]
      node : Stop network manager							TAGS: [node_resolv]
      node : Find all network interface						TAGS: [node_network]
      node : Add peerdns=no to ifcfg						TAGS: [node_network]
      node : Backup existing repos							TAGS: [node_repo]
      node : Install local yum repo							TAGS: [node_repo]
      node : Install upstream repo							TAGS: [node_repo]
      node : Config using local repo						TAGS: [node_repo]
      node : Run yum config manager command					TAGS: [node_repo]
      node : Install node basic packages					TAGS: [node_pkgs]
      node : Install node extra packages					TAGS: [node_pkgs]
      node : Install node meta packages						TAGS: [node_pkgs]
      node : Node configure disable numa					TAGS: [node_feature]
      node : Node configure disable swap					TAGS: [node_feature]
      node : Node configure unmount swap					TAGS: [node_feature]
      node : Node configure disable firewall				TAGS: [node_feature]
      node : Node disable selinux by default				TAGS: [node_feature]
      node : Node configure disk prefetch					TAGS: [node_feature]
      node : Enable kernel modules							TAGS: [node_kernel]
      node : Enable kernel module on reboot					TAGS: [node_kernel]
      node : Get config parameter page count				TAGS: [node_tuned]
      node : Get config parameter page size					TAGS: [node_tuned]
      node : Tune shmmax and shmall via mem					TAGS: [node_tuned]
      node : Create tuned profile postgres					TAGS: [node_tuned]
      node : Render tuned profile postgres					TAGS: [node_tuned]
      node : Active tuned profile postgres					TAGS: [node_tuned]
      node : Change additional sysctl params				TAGS: [node_tuned]
      node : Copy default user bash profile					TAGS: [node_profile]
      node : Setup node default pam ulimits					TAGS: [node_ulimit]
      node : Create os group admin							TAGS: [node_admin]
      node : Create os user admin							TAGS: [node_admin]
      node : Grant admin group nopass sudo					TAGS: [node_admin]
      node : Add no host checking to ssh config				TAGS: [node_admin]
      node : Add ssh no host checking						TAGS: [node_admin]
      node : Fetch admin public keys						TAGS: [node_admin]
      node : Exchange admin ssh keys						TAGS: [node_admin]
      node : Setup default node timezone					TAGS: [node_ntp]
      node : Copy the chrony.conf template					TAGS: [node_ntp]
      node : Launch chronyd ntpd service					TAGS: [node_ntp]

  play #3 (all): Init dcs									TAGS: [dcs]
    tasks:
      include_tasks											TAGS: [dcs]
      include_tasks											TAGS: [dcs, dcs_etcd]

  play #4 (meta): Init meta service							TAGS: [meta]
    tasks:
      nginx : Make sure nginx package installed				TAGS: [nginx]
      nginx : Copy nginx default config						TAGS: [nginx]
      nginx : Copy nginx upstream conf						TAGS: [nginx]
      nginx : Create local html directory					TAGS: [nginx]
      nginx : Update default nginx index page				TAGS: [nginx]
      nginx : Restart meta nginx service					TAGS: [nginx]
      nginx : Wait for nginx service online					TAGS: [nginx]
      nginx : Make sure nginx exporter installed			TAGS: [nginx_exporter]
      nginx : Config nginx_exporter options					TAGS: [nginx_exporter]
      nginx : Restart nginx_exporter service				TAGS: [nginx_exporter]
      nginx : Wait for nginx exporter online				TAGS: [nginx_exporter]
      nginx : Register cosnul nginx service					TAGS: [nginx_register]
      nginx : Register consul nginx-exporter service		TAGS: [nginx_register]
      nginx : Reload consul									TAGS: [nginx_register]
      nameserver : Make sure dnsmasq package installed		TAGS: [dnsmasq]
      nameserver : Copy dnsmasq /etc/dnsmasq.d/config		TAGS: [dnsmasq]
      nameserver : Add dynamic dns records to meta			TAGS: [dnsmasq]
      nameserver : Launch meta dnsmasq service				TAGS: [dnsmasq]
      nameserver : Wait for meta dnsmasq online				TAGS: [dnsmasq]
      nameserver : Register consul dnsmasq service			TAGS: [dnsmasq]
      nameserver : Reload consul							TAGS: [dnsmasq]
      prometheus : Install prometheus and alertmanager		TAGS: [prometheus_install]
      prometheus : Wipe out prometheus config dir			TAGS: [prometheus_clean]
      prometheus : Wipe out existing prometheus data		TAGS: [prometheus_clean]
      prometheus : Recreate prometheus data dir				TAGS: [prometheus_config]
      prometheus : Copy /etc/prometheus configs				TAGS: [prometheus_config]
      prometheus : Copy /etc/prometheus opts				TAGS: [prometheus_config]
      prometheus : Overwrite prometheus scrape_interval		TAGS: [prometheus_config]
      prometheus : Overwrite prometheus evaluation_interval	TAGS: [prometheus_config]
      prometheus : Overwrite prometheus scrape_timeout		TAGS: [prometheus_config]
      prometheus : Overwrite prometheus pg metrics path		TAGS: [prometheus_config]
      prometheus : Launch prometheus service				TAGS: [prometheus_launch]
      prometheus : Launch alertmanager service				TAGS: [prometheus_launch]
      prometheus : Wait for prometheus online				TAGS: [prometheus_launch]
      prometheus : Wait for alertmanager online				TAGS: [prometheus_launch]
      prometheus : Copy prometheus service definition		TAGS: [prometheus_register]
      prometheus : Copy alertmanager service definition		TAGS: [prometheus_register]
      prometheus : Reload consul to register prometheus		TAGS: [prometheus_register]
      grafana : Make sure grafana is installed				TAGS: [grafana_install]
      grafana : Check grafana plugin cache exists			TAGS: [grafana_install]
      grafana : Provision grafana plugin via cache			TAGS: [grafana_install]
      grafana : Download grafana plugins from web			TAGS: [grafana_install]
      grafana : Create grafana plugins cache				TAGS: [grafana_install]
      grafana : Copy /etc/grafana/grafana.ini				TAGS: [grafana_install]
      grafana : Launch grafana service						TAGS: [grafana_install]
      grafana : Wait for grafana online						TAGS: [grafana_install]
      grafana : Register consul grafana service				TAGS: [grafana_install]
      grafana : Reload consul								TAGS: [grafana_install]
      grafana : Launch meta grafana service					TAGS: [grafana_provision]
      grafana : Copy grafana.db to data dir					TAGS: [grafana_provision]
      grafana : Restart meta grafana service				TAGS: [grafana_provision]
      grafana : Wait for meta grafana online				TAGS: [grafana_provision]
      grafana : Remove grafana dashboard dir				TAGS: [grafana_provision]
      grafana : Copy grafana dashboards json				TAGS: [grafana_provision]
      grafana : Preprocess grafana dashboards				TAGS: [grafana_provision]
      grafana : Provision prometheus datasource				TAGS: [grafana_provision]
      grafana : Provision grafana dashboards				TAGS: [grafana_provision]
```


## Operations

```
make				# launch cluster
make new    # create a new pigsty cluster
make dns		# write pigsty dns record to your /etc/hosts (sudo required)
make ssh		# write ssh config to your ~/.ssh/config
make init		# init infrastructure and postgres cluster
make cache	# copy local yum repo packages to your pigsty/pkg
make clean	# delete current cluster
```



## Architecture

TBD


## Todo List

* haproxy improvement
* keepalived imporvement (haproxy health chekc / pg health check)
* metadb , remote catalog
* pg_exporter enhancement
* consul template or vip-manager 
* cloud native support 

## What's Next?

* Explore the monitoring system
* How service discovery works
* Add some load to cluster
* Managing postgres cluster with ansible
* High Available Drill




## About

Author：Vonng ([fengruohang@outlook.com](mailto:fengruohang@outlook.com))

License: (Apache Apache License Version 2.0)[LICENSE] 
