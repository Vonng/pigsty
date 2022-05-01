# Configuration

> Pigsty uses declarative [configuration](v-config.md).

Pigsty defines infra and database clusters through **Inventory**, and each Pigsty [deploy](d-deploy.md) has a corresponding **config**. Pigsty's config uses the "Infra as Data" philosophy: Users describe requirements through the declarative config, and Pigsty adapts the fundamental components to the expected state.

Formally, the inventory can be implemented as a default local [config file](#config-file) or as dynamic configuration data in [CMDB](t-cmdb.md). This article uses the default YAML configuration file [`pigsty.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml) as an example. Pigsty detects the current node environment and generates the recommended config file in [configure](#configure).

The main content of the **inventory** is [config entries](#config-entry). Pigsty provides 220 parameters that can be configured at multiple [levels](#config-entry-levels), and most parameters can use default values. Config entry can be divided into four major categories according to [category](#config-category):  [INFRA](v-infra.md)， [NODES/host nodes](v-nodes.md)， [PGSQL](v-pgsql.md)， [REDIS](v-redis.md), and further subdivided into 32 subcategories.




--------------

## Configure

Go to the Pigsty project dir and execute `configure`. Pigsty will generate a **config file** based on the current machine env, a process called **Configure**.

```bash
./configure [-n|--non-interactive] [-d|--download] [-i|--ip <ipaddr>] [-m|--mode {auto|demo}]
```

`configure` will check the following things, minor problems will be fixed automatically, otherwise, it will prompt an error to exit.

```bash
check_kernel     # kernel        = Linux
check_machine    # machine       = x86_64
check_release    # release       = CentOS 7.x
check_sudo       # current_user  = NOPASSWD sudo
check_ssh        # current_user  = NOPASSWD ssh
check_ipaddr     # primary_ip (arg|probe|input)              (INTERACTIVE: ask for ip)
check_admin      # check current_user@primary_ip nopass ssh sudo
check_mode       # check machine spec to determine node mode (tiny|oltp|olap|crit)
check_config     # generate config according to primary_ip and mode
check_pkg        # check offline installation package exists (INTERACTIVE: ask for download)
check_repo       # create repo from pkg.tgz if exists
check_repo_file  # create local file repo file if repo exists
check_utils      # check ansible sshpass and other utils installed
```

Running `. /configure` directly will launch an interactive CLI wizard that prompts the user to answer the following 3 questions:

**IP address**

When multiple NICs with multiple IPs are detected on the current machine, the config wizard prompts you to enter the **primary** IP used, which is the IP you use to access the node from the internal network. Note that you should not use the public IP.

**Download Package**

When offline package `/tmp/pkg.tgz` not exists on the node, the config wizard will ask whether to download it from Github. Selecting `Y` will start the download, and selecting `N` will skip it. If your node has good Internet access with a suitable proxy config, or if you need to make offline packages, you can choose `N`.

**Config Template**

The config wizard **automatically selects a config template** based on the current machine env. However, you can specify the use of a config template manually with `-m <mode>`.

- [`demo`](https://github.com/Vonng/pigsty/blob/master/files/conf/pigsty-demo.yml): The project's default config file, the one used by the 4-node sandbox, enables all features.
- [`auto`](https://github.com/Vonng/pigsty/blob/master/files/conf/pigsty-auto.yml): Suitable for deployment in production env with more stable and conservative configs.
- In addition, Pigsty has several preconfigured config templates that can be specified and used directly with the `-m`, see the [`files/conf`](https://github.com/Vonng/pigsty/tree/master/files/conf) for details.

The most important part of the config template is to replace the placeholder IP `10.10.10.10` in the template with the real IP (intranet primary IP) of the current machine and select the appropriate database specification template according to the current machine config.  You can use the default generated config file directly or make further customization based on the automatically generated config file.

<details><summary>Standard output of the configure</summary>

```bash
$ ./configure
configure pigsty v1.4.1 begin
[ OK ] kernel = Linux
[ OK ] machine = x86_64
[ OK ] release = 7.8.2003 , perfect
[ OK ] sudo = root ok
[ OK ] ssh = root@127.0.0.1 ok
[ OK ] primary_ip = 10.10.10.10  (from probe)
[ OK ] admin = root@10.10.10.10 ok
[ OK ] spec = mini (cpu = 2)
[ OK ] config = auto @ 10.10.10.10
[ OK ] cache = /tmp/pkg.tgz exists
[ OK ] repo = /www/pigsty ok
[ OK ] repo file = /etc/yum.repos.d/pigsty-local.repo
[ OK ] utils = install from local file repo
[ OK ] ansible = ansible 2.9.27
configure pigsty done. Use 'make install' to proceed
```

</details>






## Config File

A specific sample config file is available at the root of the Pigsty project: [`pigsty.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml).

The top level of the config file is a single object with a `key` as `all` and contains two sub-projects: `vars` and `children`.

```yaml
all:                      # Top-level object: all
  vars: <123 keys>        # Global Config: all.vars

  children:               # Grouping Definition: all.children Each project defines a cluster 
    meta: <2 keys>...     # Special grouping: meta  Defined environment meta nodes
    
    pg-meta: <2 keys>...  # Detailed definition of database cluster pg-meta
    pg-test: <2 keys>...  # Detailed definition of database cluster pg-test
    ...
```

The content of `vars` is a K-V pair that defines the global config parameters, K is the name of the config entry and V is the content.

The content of `children` is also a K-V pair, K is the cluster name and V is the specific cluster definition, a sample cluster definition is shown below:

* The cluster definition also includes two sub-projects: `vars` defines the config at the **cluster level**. `hosts` define the cluster's instance members.
* The params in the cluster config override the global params, and the cluster configuration params are overridden by the configuration params of the same name at the instance level. The only mandatory cluster configuration parameter is `pg_cluster`, which is the name of the cluster and is consistent with the upper-level cluster name.
* The `hosts` use K-V to define the cluster instance members, K is the IP (must be ssh reachable), and V is the specific instance config params.
* There are two mandatory params in the instance config: `pg_seq`, and `pg_role`, which are the unique serial number of the instance and the role of the instance, respectively.

```yaml
pg-test:                 # The cluster name is used as the cluster name by default
  vars:                  # Database cluster level variables
    pg_cluster: pg-test  # A mandatory config entry defined at the cluster level, consistent throughout pg-test. 
  hosts:                 # Database Cluster Members
    10.10.10.11: {pg_seq: 1, pg_role: primary} # Database Instance Members
    10.10.10.12: {pg_seq: 2, pg_role: replica} # The identity parameters pg_role and pg_seq must be defined
    10.10.10.13: {pg_seq: 3, pg_role: offline} # Variables at the instance level can be specified here
```

Pigsty config files follow [**Ansible rules**](https://docs.ansible.com/ansible/2.5/user_guide/playbooks_variables.html) in YAML format and use a single config file by default. The default config file path is [`pigsty.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml) in the root dir of the Pigsty source code. The default config file is specified via `inventory = pigsty.yml` in [`ansible.cfg`](https://github.com/Vonng/pigsty/blob/master/ansible.cfg) in the same dir. Additional config files can be specified via `-i <config_path>` when executing any playbook.

The config file needs to be used in conjunction with [**Ansible**](https://docs.ansible.com/). Ansible is a popular DevOps tool. If you are proficient in Ansible, you can adapt the config file organization and structure according to Ansible's manifest organization rules.

Please use the browse  [Ansible Quick Start](p-playbook.md#Ansible-quick-start) and start executing playooks with Ansible.





## Config Entry

Config entries are in the form of K-V pairs: the key is the **name** of the Config entry and the value is the content of the config entry.

Pigsty's params can be configured at different **levels** and inherited and overwritten based on rules, with higher priority config entries overwriting lower priority config entries with the same name.

### Config Entry Levels

In Pigsty's [config file](#config-file), **config entry** can appear in three locations: **global**, **cluster**, and **instance**. Config entry defined in **cluster** `vars` **override global config entry** with same-name key override, and config entry defined in an **instance**, in turn, override cluster config entry with global config entry.

| Granularity  | Scope    | Priority | Description                                           | Location                             |
| :----------: | -------- | -------- | ----------------------------------------------------- | ------------------------------------ |
|  **G**lobal  | Global   | Low      | Consistent within the same set of **deployment envs** | `all.vars.xxx`                       |
| **C**luster  | Cluster  | Medium   | Consistency within the same set of **clusters**       | `all.children.<cls>.vars.xxx`        |
| **I**nstance | Instance | High     | The most granular level of config                     | `all.children.<cls>.hosts.<ins>.xxx` |

Not all config entries are **suitable** for use at all levels. For example, infra params will usually only be defined in the **global** config, params such as database instance labels, roles, load balancing weights, and other params can only be configured at the **instance** level, and some operational options can only be provided using CLI params. For details of config entry, please see the [list of config entry](v-config.md).

### Default & Overwrite

In addition to the three config granularities, there are two extra levels of priority in the Pigsty config entry: default value and CLI param forced override:

* **Default**: When a config entry does not appear at either the global/cluster/instance level, the default config entry is used. The default value has the lowest priority. The default params are defined in `roles/<role>/default/main.yml`.
* **Parameter**: Config entry specified by means of CLI incoming params have the highest priority and will override all levels of config. Some config entries can only be specified by means of CLI params.

|    Levels    | Priority | Source    | Description                                           | Location                             |
| :----------: | -------- | --------- | ----------------------------------------------------- | ------------------------------------ |
| **D**efault  | Lowest   | Default   | Default values for code logic definitions             | `roles/<role>/default/main.yml`      |
|  **G**lobal  | Low      | Global    | Consistent within the same set of **deployment envs** | `all.vars.xxx`                       |
| **C**luster  | Medium   | Cluster   | Consistency within the same set of **clusters**       | `all.children.<cls>.vars.xxx`        |
| **I**nstance | High     | Instance  | The most granular level of config                     | `all.children.<cls>.hosts.<ins>.xxx` |
| **A**rgument | Highest  | Parameter | Pass in CLI arguments                                 | `-e `                                |

--------------



## Config Category

Pigsty contains 220 fixed [config entries](#config-entry) divided into four sections: [INFRA](v-infra.md), [NODES](v-nodes.md), [PGSQL](v-pgsql.md), and [REDIS](v-redis.md), for a total of 32 categories.

Usually, only the node/database **identity parameter** is mandatory, other params can be modified on demand using the default values.

| Category              | Section                                         | Description                        | Count |
| --------------------- | ----------------------------------------------- | ---------------------------------- | ----- |
| [`INFRA`](v-infra.md) | [`CONNECT`](v-infra.md#CONNECT)                 | Connection parameters              | 1     |
| [`INFRA`](v-infra.md) | [`REPO`](v-infra.md#REPO)                       | Local source infra                 | 10    |
| [`INFRA`](v-infra.md) | [`CA`](v-infra.md#CA)                           | Public-Private Key Infra           | 5     |
| [`INFRA`](v-infra.md) | [`NGINX`](v-infra.md#NGINX)                     | Nginx Web Server                   | 5     |
| [`INFRA`](v-infra.md) | [`NAMESERVER`](v-infra.md#NAMESERVER)           | DNS Server                         | 1     |
| [`INFRA`](v-infra.md) | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | Monitoring Time Series Database    | 7     |
| [`INFRA`](v-infra.md) | [`EXPORTER`](v-infra.md#EXPORTER)               | Universal Exporter Config          | 3     |
| [`INFRA`](v-infra.md) | [`GRAFANA`](v-infra.md#GRAFANA)                 | Grafana Visualization Platform     | 9     |
| [`INFRA`](v-infra.md) | [`LOKI`](v-infra.md#LOKI)                       | Loki log collection platform       | 5     |
| [`INFRA`](v-infra.md) | [`DCS`](v-infra.md#DCS)                         | Distributed Config Storage Meta DB | 8     |
| [`INFRA`](v-infra.md) | [`JUPYTER`](v-infra.md#JUPYTER)                 | JupyterLab Data Analysis Env       | 3     |
| [`INFRA`](v-infra.md) | [`PGWEB`](v-infra.md#PGWEB)                     | PGWeb Web Client Tool              | 2     |
| [`NODES`](v-nodes.md) | [`NODE_IDENTITY`](v-nodes.md#NODE_IDENTITY)     | Node identity parameters           | 5     |
| [`NODES`](v-nodes.md) | [`NODE_DNS`](v-nodes.md#NODE_DNS)               | Node Domain Name Resolution        | 5     |
| [`NODES`](v-nodes.md) | [`NODE_REPO`](v-nodes.md#NODE_REPO)             | Node Software Source               | 3     |
| [`NODES`](v-nodes.md) | [`NODE_PACKAGES`](v-nodes.md#NODE_PACKAGES)     | Node Packages                      | 4     |
| [`NODES`](v-nodes.md) | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | Node Functionality Features        | 6     |
| [`NODES`](v-nodes.md) | [`NODE_MODULES`](v-nodes.md#NODE_MODULES)       | Node Kernel Module                 | 1     |
| [`NODES`](v-nodes.md) | [`NODE_TUNE`](v-nodes.md#NODE_TUNE)             | Node parameter tuning              | 2     |
| [`NODES`](v-nodes.md) | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | Node Admin User                    | 6     |
| [`NODES`](v-nodes.md) | [`NODE_TIME`](v-nodes.md#NODE_TIME)             | Node time zone and time sync       | 4     |
| [`NODES`](v-nodes.md) | [`NODE_EXPORTER`](v-nodes.md#NODE_EXPORTER)     | Node Indicator Exposer             | 3     |
| [`NODES`](v-nodes.md) | [`PROMTAIL`](v-nodes.md#PROMTAIL)               | Log collection component           | 5     |
| [`PGSQL`](v-pgsql.md) | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | PGSQL Identity Parameters          | 13    |
| [`PGSQL`](v-pgsql.md) | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | PGSQL Business Object Definition   | 11    |
| [`PGSQL`](v-pgsql.md) | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | PGSQL Installation                 | 11    |
| [`PGSQL`](v-pgsql.md) | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | PGSQL Cluster Initialization       | 24    |
| [`PGSQL`](v-pgsql.md) | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | PGSQL Cluster Provisioning         | 9     |
| [`PGSQL`](v-pgsql.md) | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | PGSQL Indicator Exposer            | 13    |
| [`PGSQL`](v-pgsql.md) | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | PGSQL Service Access               | 16    |
| [`REDIS`](v-redis.md) | [`REDIS_IDENTITY`](v-redis.md#REDIS_IDENTITY)   | REDIS Identity Parameters          | 3     |
| [`REDIS`](v-redis.md) | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | REDIS Cluster Provisioning         | 14    |
| [`REDIS`](v-redis.md) | [`REDIS_EXPORTER`](v-redis.md#REDIS_EXPORTER)   | REDIS Indicator Exposer            | 3     |



<details><summary>List of config entries</summary>

| ID   | Name                                                         | Section                                         | Level | Description                                                  |
| ---- | ------------------------------------------------------------ | ----------------------------------------------- | ----- | ------------------------------------------------------------ |
| 100  | [`proxy_env`](v-infra.md#proxy_env)                          | [`CONNECT`](v-infra.md#CONNECT)                 | G     | Proxy server config                                          |
| 110  | [`nginx_enabled`](v-infra.md#nginx_enabled)                    | [`REPO`](v-infra.md#REPO)                       | G     | Enable local sources                                         |
| 111  | [`repo_name`](v-infra.md#repo_name)                          | [`REPO`](v-infra.md#REPO)                       | G     | Local source name                                            |
| 112  | [`repo_address`](v-infra.md#repo_address)                    | [`REPO`](v-infra.md#REPO)                       | G     | Local source external access address                         |
| 113  | [`nginx_port`](v-infra.md#nginx_port)                          | [`REPO`](v-infra.md#REPO)                       | G     | Local source port                                            |
| 114  | [`nginx_home`](v-infra.md#nginx_home)                          | [`REPO`](v-infra.md#REPO)                       | G     | Local source file root dir                                   |
| 115  | [`repo_rebuild`](v-infra.md#repo_rebuild)                    | [`REPO`](v-infra.md#REPO)                       | A     | Rebuild Yum repo                                             |
| 116  | [`repo_remove`](v-infra.md#repo_remove)                      | [`REPO`](v-infra.md#REPO)                       | A     | Remove existing REPO files                                   |
| 117  | [`repo_upstreams`](v-infra.md#repo_upstreams)                | [`REPO`](v-infra.md#REPO)                       | G     | Upstream sources of Yum repo                                 |
| 118  | [`repo_packages`](v-infra.md#repo_packages)                  | [`REPO`](v-infra.md#REPO)                       | G     | List of software from Yum repo                               |
| 119  | [`repo_url_packages`](v-infra.md#repo_url_packages)          | [`REPO`](v-infra.md#REPO)                       | G     | List of software downloaded via URL                          |
| 120  | [`ca_method`](v-infra.md#ca_method)                          | [`CA`](v-infra.md#CA)                           | G     | CA creation method                                           |
| 121  | [`ca_subject`](v-infra.md#ca_subject)                        | [`CA`](v-infra.md#CA)                           | G     | Self-signed CA themes                                        |
| 122  | [`ca_homedir`](v-infra.md#ca_homedir)                        | [`CA`](v-infra.md#CA)                           | G     | CA root dir                                                  |
| 123  | [`ca_cert`](v-infra.md#ca_cert)                              | [`CA`](v-infra.md#CA)                           | G     | CA Certificate                                               |
| 124  | [`ca_key`](v-infra.md#ca_key)                                | [`CA`](v-infra.md#CA)                           | G     | CA private key name                                          |
| 130  | [`nginx_upstream`](v-infra.md#nginx_upstream)                | [`NGINX`](v-infra.md#NGINX)                     | G     | Nginx upstream servers                                       |
| 131  | [`nginx_indexes`](v-infra.md#nginx_indexes)                            | [`NGINX`](v-infra.md#NGINX)                     | G     | List of apps displayed on the navigation bar                 |
| 132  | [`docs_enabled`](v-infra.md#docs_enabled)                    | [`NGINX`](v-infra.md#NGINX)                     | G     | Enable local documents                                       |
| 133  | [`pev2_enabled`](v-infra.md#pev2_enabled)                    | [`NGINX`](v-infra.md#NGINX)                     | G     | Enable PEV2 component                                        |
| 134  | [`pgbadger_enabled`](v-infra.md#pgbadger_enabled)            | [`NGINX`](v-infra.md#NGINX)                     | G     | Enable Pgbadger                                              |
| 140  | [`dns_records`](v-infra.md#dns_records)                      | [`NAMESERVER`](v-infra.md#NAMESERVER)           | G     | Dynamic DNS Resolution Records                               |
| 150  | [`prometheus_data_dir`](v-infra.md#prometheus_data_dir)      | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | G     | Prometheus Catalog                                           |
| 151  | [`prometheus_options`](v-infra.md#prometheus_options)        | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | G     | Prometheus CLI parameters                                    |
| 152  | [`prometheus_reload`](v-infra.md#prometheus_reload)          | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | A     | Reload instead of Recreate                                   |
| 153  | [`prometheus_sd_method`](v-infra.md#prometheus_sd_method)    | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | G     | Service discovery mechanism: static                          |
| 154  | [`prometheus_scrape_interval`](v-infra.md#prometheus_scrape_interval) | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | G     | Prom Crawl Cycle                                             |
| 155  | [`prometheus_scrape_timeout`](v-infra.md#prometheus_scrape_timeout) | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | G     | Prom Crawl Timeout                                           |
| 156  | [`prometheus_sd_interval`](v-infra.md#prometheus_sd_interval) | [`PROMETHEUS`](v-infra.md#PROMETHEUS)           | G     | Prom Service Discovery Refresh Cycle                         |
| 160  | [`exporter_install`](v-infra.md#exporter_install)            | [`EXPORTER`](v-infra.md#EXPORTER)               | G     | Installation of monitoring components method                 |
| 161  | [`exporter_repo_url`](v-infra.md#exporter_repo_url)          | [`EXPORTER`](v-infra.md#EXPORTER)               | G     | YumRepo for monitoring components                            |
| 162  | [`exporter_metrics_path`](v-infra.md#exporter_metrics_path)  | [`EXPORTER`](v-infra.md#EXPORTER)               | G     | Monitor the exposed URL Path                                 |
| 170  | [`grafana_endpoint`](v-infra.md#grafana_endpoint)            | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | Grafana Address                                              |
| 171  | [`grafana_admin_username`](v-infra.md#grafana_admin_username) | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | Grafana Admin Username                                       |
| 172  | [`grafana_admin_password`](v-infra.md#grafana_admin_password) | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | Grafana Admin User Password                                  |
| 173  | [`grafana_database`](v-infra.md#grafana_database)            | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | Grafana Database Types                                       |
| 174  | [`grafana_pgurl`](v-infra.md#grafana_pgurl)                  | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | Grafana's PG connection string                               |
| 175  | [`grafana_plugin_method`](v-infra.md#grafana_plugin_method)                | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | Grafana plugin installation method                           |
| 176  | [`grafana_plugin_cache`](v-infra.md#grafana_plugin_cache)                  | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | Grafana plugin cache location                                |
| 177  | [`grafana_plugin_list`](v-infra.md#grafana_plugin_list)              | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | Installation list of Grafana plugins                         |
| 178  | [`grafana_plugin_git`](v-infra.md#grafana_plugin_git)      | [`GRAFANA`](v-infra.md#GRAFANA)                 | G     | Installing Grafana Plugin from Git                           |
| 180  | [`loki_endpoint`](v-infra.md#loki_endpoint)                  | [`LOKI`](v-infra.md#LOKI)                       | G     | Receiving logs for the loki service                          |
| 181  | [`loki_clean`](v-infra.md#loki_clean)                        | [`LOKI`](v-infra.md#LOKI)                       | A     | Clean up the database dir during Loki installation           |
| 182  | [`loki_options`](v-infra.md#loki_options)                    | [`LOKI`](v-infra.md#LOKI)                       | G     | Loki's CLI parameters                                        |
| 183  | [`loki_data_dir`](v-infra.md#loki_data_dir)                  | [`LOKI`](v-infra.md#LOKI)                       | G     | Loki's data dir                                              |
| 184  | [`loki_retention`](v-infra.md#loki_retention)                | [`LOKI`](v-infra.md#LOKI)                       | G     | Loki log default retention days                              |
| 200  | [`dcs_servers`](v-infra.md#dcs_servers)                      | [`DCS`](v-infra.md#DCS)                         | G     | DCS server name:IP list                                      |
| 201  | [`dcs_registry`](v-infra.md#dcs_registry)            | [`DCS`](v-infra.md#DCS)                         | G     | Service Registration Location                                |
| 202  | [`dcs_type`](v-infra.md#dcs_type)                            | [`DCS`](v-infra.md#DCS)                         | G     | DCS Type                                                     |
| 203  | [`consul_name`](v-infra.md#consul_name)                            | [`DCS`](v-infra.md#DCS)                         | G     | DCS Cluster Name                                             |
| 204  | [`consul_clean`](v-infra.md#consul_clean)          | [`DCS`](v-infra.md#DCS)                         | C/A   | Action when DCS instance exists                              |
| 205  | [`consul_safeguard`](v-infra.md#consul_safeguard)          | [`DCS`](v-infra.md#DCS)                         | C/A   | Prohibit cleaning of DCS instances                           |
| 206  | [`consul_data_dir`](v-infra.md#consul_data_dir)              | [`DCS`](v-infra.md#DCS)                         | G     | Consul Data Catalog                                          |
| 207  | [`etcd_data_dir`](v-infra.md#etcd_data_dir)                  | [`DCS`](v-infra.md#DCS)                         | G     | Etcd Data Catalog                                            |
| 220  | [`jupyter_enabled`](v-infra.md#jupyter_enabled)              | [`JUPYTER`](v-infra.md#JUPYTER)                 | G     | Enable JupyterLab                                            |
| 221  | [`jupyter_username`](v-infra.md#jupyter_username)            | [`JUPYTER`](v-infra.md#JUPYTER)                 | G     | OS users used by Jupyter                                     |
| 222  | [`jupyter_password`](v-infra.md#jupyter_password)            | [`JUPYTER`](v-infra.md#JUPYTER)                 | G     | Jupyter Lab Password                                         |
| 230  | [`pgweb_enabled`](v-infra.md#pgweb_enabled)                  | [`PGWEB`](v-infra.md#PGWEB)                     | G     | Enable PgWeb                                                 |
| 231  | [`pgweb_username`](v-infra.md#pgweb_username)                | [`PGWEB`](v-infra.md#PGWEB)                     | G     | OS users used by PgWeb                                       |
| 300  | [`meta_node`](v-nodes.md#meta_node)                          | [`NODE_IDENTITY`](v-nodes.md#NODE_IDENTITY)     | C     | Meta Node                                                    |
| 301  | [`nodename`](v-nodes.md#nodename)                            | [`NODE_IDENTITY`](v-nodes.md#NODE_IDENTITY)     | I     | Node instance mark                                           |
| 302  | [`node_cluster`](v-nodes.md#node_cluster)                    | [`NODE_IDENTITY`](v-nodes.md#NODE_IDENTITY)     | C     | Node cluster name, default nodes                             |
| 303  | [`nodename_overwrite`](v-nodes.md#nodename_overwrite)        | [`NODE_IDENTITY`](v-nodes.md#NODE_IDENTITY)     | C     | Nodename overrides HOSTNAME                                  |
| 304  | [`nodename_exchange`](v-nodes.md#nodename_exchange)          | [`NODE_IDENTITY`](v-nodes.md#NODE_IDENTITY)     | C     | Exchange hostnames between playbook nodes                    |
| 310  | [`node_etc_hosts_default`](v-nodes.md#node_etc_hosts_default)                | [`NODE_DNS`](v-nodes.md#NODE_DNS)               | C     | Static DNS Analysis                                          |
| 311  | [`node_etc_hosts`](v-nodes.md#node_etc_hosts)    | [`NODE_DNS`](v-nodes.md#NODE_DNS)               | C/I   | Cluster Level                                                |
| 312  | [`node_dns_method`](v-nodes.md#node_dns_method)              | [`NODE_DNS`](v-nodes.md#NODE_DNS)               | C     | Configure DNS server method                                  |
| 313  | [`node_dns_servers`](v-nodes.md#node_dns_servers)            | [`NODE_DNS`](v-nodes.md#NODE_DNS)               | C     | Configure a list of dynamic DNS servers                      |
| 314  | [`node_dns_options`](v-nodes.md#node_dns_options)            | [`NODE_DNS`](v-nodes.md#NODE_DNS)               | C     | Configure the /etc/resolv.conf                               |
| 320  | [`node_repo_method`](v-nodes.md#node_repo_method)            | [`NODE_REPO`](v-nodes.md#NODE_REPO)             | C     | The way nodes use Yum repos                                  |
| 321  | [`node_repo_remove`](v-nodes.md#node_repo_remove)            | [`NODE_REPO`](v-nodes.md#NODE_REPO)             | C     | Remove nodes with existing Yum repos                         |
| 322  | [`node_local_repo_url`](v-nodes.md#node_local_repo_url)      | [`NODE_REPO`](v-nodes.md#NODE_REPO)             | C     | URL of the local source                                      |
| 330  | [`node_packages_default`](v-nodes.md#node_packages_default)                  | [`NODE_PACKAGES`](v-nodes.md#NODE_PACKAGES)     | C     | Packages for nodes                                           |
| 331  | [`node_packages`](v-nodes.md#node_packages)      | [`NODE_PACKAGES`](v-nodes.md#NODE_PACKAGES)     | C     | Extra packages for nodes                                     |
| 332  | [`node_packages_meta`](v-nodes.md#node_packages_meta)        | [`NODE_PACKAGES`](v-nodes.md#NODE_PACKAGES)     | G     | Packages for meta nodes                                      |
| 333  | [`node_packages_meta_pip`](v-nodes.md#node_packages_meta_pip)  | [`NODE_PACKAGES`](v-nodes.md#NODE_PACKAGES)     | G     | Packages installed via pip3                                  |
| 340  | [`node_disable_numa`](v-nodes.md#node_disable_numa)          | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | C     | Disable the node NUMA                                        |
| 341  | [`node_disable_swap`](v-nodes.md#node_disable_swap)          | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | C     | Disable the node SWAP                                        |
| 342  | [`node_disable_firewall`](v-nodes.md#node_disable_firewall)  | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | C     | Disable the node firewall                                    |
| 343  | [`node_disable_selinux`](v-nodes.md#node_disable_selinux)    | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | C     | Disable the node SELINUX                                     |
| 344  | [`node_static_network`](v-nodes.md#node_static_network)      | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | C     | Enable static DNS servers                                    |
| 345  | [`node_disk_prefetch`](v-nodes.md#node_disk_prefetch)        | [`NODE_FEATURES`](v-nodes.md#NODE_FEATURES)     | C     | Enable disk pre-reading                                      |
| 346  | [`node_kernel_modules`](v-nodes.md#node_kernel_modules)      | [`NODE_MODULES`](v-nodes.md#NODE_MODULES)       | C     | Enable kernel module                                         |
| 350  | [`node_tune`](v-nodes.md#node_tune)                          | [`NODE_TUNE`](v-nodes.md#NODE_TUNE)             | C     | Node Tuning Mode                                             |
| 351  | [`node_sysctl_params`](v-nodes.md#node_sysctl_params)        | [`NODE_TUNE`](v-nodes.md#NODE_TUNE)             | C     | OS kernel parameters                                         |
| 360  | [`node_admin_enabled`](v-nodes.md#node_admin_enabled)            | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | G     | Create admin user                                            |
| 361  | [`node_admin_uid`](v-nodes.md#node_admin_uid)                | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | G     | Admin UID                                                    |
| 362  | [`node_admin_username`](v-nodes.md#node_admin_username)      | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | G     | Admin User Name                                              |
| 363  | [`node_admin_ssh_exchange`](v-nodes.md#node_admin_ssh_exchange) | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | C     | Exchange admin user SSH keys                                 |
| 364  | [`node_admin_pk_current`](v-nodes.md#node_admin_pk_current)  | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | A     | Add the current user's public key to the admin user          |
| 365  | [`node_admin_pk_list`](v-nodes.md#node_admin_pk_list)                | [`NODE_ADMIN`](v-nodes.md#NODE_ADMIN)           | C     | Login admin's public key list                                |
| 370  | [`node_timezone`](v-nodes.md#node_timezone)                  | [`NODE_TIME`](v-nodes.md#NODE_TIME)             | C     | NTP time zone setting                                        |
| 371  | [`node_ntp_enabled`](v-nodes.md#node_ntp_enabled)              | [`NODE_TIME`](v-nodes.md#NODE_TIME)             | C     | Configure NTP service                                        |
| 372  | [`node_ntp_service`](v-nodes.md#node_ntp_service)            | [`NODE_TIME`](v-nodes.md#NODE_TIME)             | C     | NTP service type: ntp or chrony                              |
| 373  | [`node_ntp_servers`](v-nodes.md#node_ntp_servers)            | [`NODE_TIME`](v-nodes.md#NODE_TIME)             | C     | NTP Server List                                              |
| 380  | [`node_exporter_enabled`](v-nodes.md#node_exporter_enabled)  | [`NODE_EXPORTER`](v-nodes.md#NODE_EXPORTER)     | C     | Enable node metrics collector                                |
| 381  | [`node_exporter_port`](v-nodes.md#node_exporter_port)        | [`NODE_EXPORTER`](v-nodes.md#NODE_EXPORTER)     | C     | Node Indicator Exposure Port                                 |
| 382  | [`node_exporter_options`](v-nodes.md#node_exporter_options)  | [`NODE_EXPORTER`](v-nodes.md#NODE_EXPORTER)     | C/I   | Node Metrics Collection Options                              |
| 390  | [`promtail_enabled`](v-nodes.md#promtail_enabled)            | [`PROMTAIL`](v-nodes.md#PROMTAIL)               | C     | Enable Protail log collection                                |
| 391  | [`promtail_clean`](v-nodes.md#promtail_clean)                | [`PROMTAIL`](v-nodes.md#PROMTAIL)               | C/A   | Remove existing status information when installing promtail  |
| 392  | [`promtail_port`](v-nodes.md#promtail_port)                  | [`PROMTAIL`](v-nodes.md#PROMTAIL)               | G     | promtail default port                                        |
| 393  | [`promtail_options`](v-nodes.md#promtail_options)            | [`PROMTAIL`](v-nodes.md#PROMTAIL)               | C/I   | promtail CLI parameters                                      |
| 394  | [`promtail_positions`](v-nodes.md#promtail_positions)        | [`PROMTAIL`](v-nodes.md#PROMTAIL)               | C     | promtail status file location                                |
| 500  | [`pg_cluster`](v-pgsql.md#pg_cluster)                        | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | C     | PG database cluster name                                     |
| 501  | [`pg_shard`](v-pgsql.md#pg_shard)                            | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | C     | PG Cluster-owned Shard (Reserved)                            |
| 502  | [`pg_sindex`](v-pgsql.md#pg_sindex)                          | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | C     | PG cluster's slice number (Reserved)                         |
| 503  | [`gp_role`](v-pgsql.md#gp_role)                              | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | C     | Role of PG Cluster in GP                                     |
| 504  | [`pg_role`](v-pgsql.md#pg_role)                              | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | PG instance role                                             |
| 505  | [`pg_seq`](v-pgsql.md#pg_seq)                                | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | PG Instance Serial Number                                    |
| 506  | [`pg_instances`](v-pgsql.md#pg_instances)                    | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | All PG instances on the current node                         |
| 507  | [`pg_upstream`](v-pgsql.md#pg_upstream)                      | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | Replicated upstream nodes of instances                       |
| 508  | [`pg_offline_query`](v-pgsql.md#pg_offline_query)            | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | Offline Search                                               |
| 509  | [`pg_backup`](v-pgsql.md#pg_backup)                          | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | Storing backups on instances                                 |
| 510  | [`pg_weight`](v-pgsql.md#pg_weight)                          | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | I     | Relative weight of instances in load balancing               |
| 511  | [`pg_hostname`](v-pgsql.md#pg_hostname)                      | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | C/I   | PG instance name is set to HOSTNAME                          |
| 512  | [`pg_preflight_skip`](v-pgsql.md#pg_preflight_skip)          | [`PG_IDENTITY`](v-pgsql.md#PG_IDENTITY)         | C/A   | Skip PG identity parameter checks                            |
| 520  | [`pg_users`](v-pgsql.md#pg_users)                            | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | C     | Business User Definition                                     |
| 521  | [`pg_databases`](v-pgsql.md#pg_databases)                    | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | C     | Business Database Definition                                 |
| 522  | [`pg_services_extra`](v-pgsql.md#pg_services_extra)          | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | C     | Cluster Proprietary Services Definition                      |
| 523  | [`pg_hba_rules_extra`](v-pgsql.md#pg_hba_rules_extra)        | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | C     | Cluster/instance specific HBA rules                          |
| 524  | [`pgbouncer_hba_rules_extra`](v-pgsql.md#pgbouncer_hba_rules_extra) | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | C     | Pgbounce specific HBA rules                                  |
| 525  | [`pg_admin_username`](v-pgsql.md#pg_admin_username)          | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | G     | PG Admin Users                                               |
| 526  | [`pg_admin_password`](v-pgsql.md#pg_admin_password)          | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | G     | PG Adimin User Passwords                                     |
| 527  | [`pg_replication_username`](v-pgsql.md#pg_replication_username) | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | G     | PG Replica User                                              |
| 528  | [`pg_replication_password`](v-pgsql.md#pg_replication_password) | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | G     | PG Replica User Passwords                                    |
| 529  | [`pg_monitor_username`](v-pgsql.md#pg_monitor_username)      | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | G     | PG Monitor Users                                             |
| 530  | [`pg_monitor_password`](v-pgsql.md#pg_monitor_password)      | [`PG_BUSINESS`](v-pgsql.md#PG_BUSINESS)         | G     | PG Monitor User passwords                                    |
| 540  | [`pg_dbsu`](v-pgsql.md#pg_dbsu)                              | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | PG OS Super User                                             |
| 541  | [`pg_dbsu_uid`](v-pgsql.md#pg_dbsu_uid)                      | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | Super UID                                                    |
| 542  | [`pg_dbsu_sudo`](v-pgsql.md#pg_dbsu_sudo)                    | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | Sudo privileges for super users                              |
| 543  | [`pg_dbsu_home`](v-pgsql.md#pg_dbsu_home)                    | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | Super User's Home Dir                                        |
| 544  | [`pg_dbsu_ssh_exchange`](v-pgsql.md#pg_dbsu_ssh_exchange)    | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | Exchanging Super User Keys                                   |
| 545  | [`pg_version`](v-pgsql.md#pg_version)                        | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | Large version of the installed database                      |
| 546  | [`pgdg_repo`](v-pgsql.md#pgdg_repo)                          | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | Add PG official repo                                         |
| 547  | [`pg_add_repo`](v-pgsql.md#pg_add_repo)                      | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | Add PG-related upstream repos                                |
| 548  | [`pg_bin_dir`](v-pgsql.md#pg_bin_dir)                        | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | PG Binary Dir                                                |
| 549  | [`pg_packages`](v-pgsql.md#pg_packages)                      | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | List of installed PG packages                                |
| 550  | [`pg_extensions`](v-pgsql.md#pg_extensions)                  | [`PG_INSTALL`](v-pgsql.md#PG_INSTALL)           | C     | List of installed PG plug-ins                                |
| 560  | [`pg_clean`](v-pgsql.md#pg_clean)            | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C/A   | Handling method when PG exists                               |
| 561  | [`pg_safeguard`](v-pgsql.md#pg_safeguard)            | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C/A   | Prohibit clearing of existing PG instances                   |
| 562  | [`pg_data`](v-pgsql.md#pg_data)                              | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG data dir                                                  |
| 563  | [`pg_fs_main`](v-pgsql.md#pg_fs_main)                        | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG master data disk mount point                              |
| 564  | [`pg_fs_bkup`](v-pgsql.md#pg_fs_bkup)                        | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG backup disk mount point                                   |
| 565  | [`pg_dummy_filesize`](v-pgsql.md#pg_dummy_filesize)          | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | The size of the placeholder file /pg/dummy                   |
| 566  | [`pg_listen`](v-pgsql.md#pg_listen)                          | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG listening IP                                              |
| 567  | [`pg_port`](v-pgsql.md#pg_port)                              | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG listening port                                            |
| 568  | [`pg_localhost`](v-pgsql.md#pg_localhost)                    | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | UnixSocket address used by PG                                |
| 580  | [`patroni_enabled`](v-pgsql.md#patroni_enabled)              | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Enable Patroni                                               |
| 581  | [`patroni_mode`](v-pgsql.md#patroni_mode)                    | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Patroni config mode                                          |
| 582  | [`pg_namespace`](v-pgsql.md#pg_namespace)                    | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Patroni's DCS namespace                                      |
| 583  | [`patroni_port`](v-pgsql.md#patroni_port)                    | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Patroni service port                                         |
| 584  | [`patroni_watchdog_mode`](v-pgsql.md#patroni_watchdog_mode)  | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Patroni Watchdog mode                                        |
| 585  | [`pg_conf`](v-pgsql.md#pg_conf)                              | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Patroni's config templates                                   |
| 586  | [`pg_libs`](v-pgsql.md#pg_libs)      | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG Default Shared database                                   |
| 587  | [`pg_encoding`](v-pgsql.md#pg_encoding)                      | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | PG character set encoding                                    |
| 588  | [`pg_locale`](v-pgsql.md#pg_locale)                          | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Localization rules for PG                                    |
| 589  | [`pg_lc_collate`](v-pgsql.md#pg_lc_collate)                  | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Localized sorting rules for PG                               |
| 590  | [`pg_lc_ctype`](v-pgsql.md#pg_lc_ctype)                      | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Localized character set definitions for PG                   |
| 591  | [`pgbouncer_enabled`](v-pgsql.md#pgbouncer_enabled)          | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Enable Pgbouncer                                             |
| 592  | [`pgbouncer_port`](v-pgsql.md#pgbouncer_port)                | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Pgbouncer Port                                               |
| 593  | [`pgbouncer_poolmode`](v-pgsql.md#pgbouncer_poolmode)        | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Pgbouncer pooling mode                                       |
| 594  | [`pgbouncer_max_db_conn`](v-pgsql.md#pgbouncer_max_db_conn)  | [`PG_BOOTSTRAP`](v-pgsql.md#PG_BOOTSTRAP)       | C     | Pgbouncer Maximum DB connections                             |
| 600  | [`pg_provision`](v-pgsql.md#pg_provision)                    | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | C     | Applying templates in PG clusters                            |
| 601  | [`pg_init`](v-pgsql.md#pg_init)                              | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | C     | Custom PG initialization script                              |
| 602  | [`pg_default_roles`](v-pgsql.md#pg_default_roles)            | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | G/C   | Default Roles and Users                                      |
| 603  | [`pg_default_privilegs`](v-pgsql.md#pg_default_privilegs)    | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | G/C   | Database default privileges config                           |
| 604  | [`pg_default_schemas`](v-pgsql.md#pg_default_schemas)        | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | G/C   | Default Mode                                                 |
| 605  | [`pg_default_extensions`](v-pgsql.md#pg_default_extensions)  | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | G/C   | Extensions installed by default                              |
| 606  | [`pg_reload`](v-pgsql.md#pg_reload)                          | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | A     | Reload Database Config (HBA)                                 |
| 607  | [`pg_hba_rules`](v-pgsql.md#pg_hba_rules)                    | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | G/C   | Global HBA rules                                             |
| 608  | [`pgbouncer_hba_rules`](v-pgsql.md#pgbouncer_hba_rules)      | [`PG_PROVISION`](v-pgsql.md#PG_PROVISION)       | G/C   | Pgbouncer Global HBA rules                                   |
| 620  | [`pg_exporter_config`](v-pgsql.md#pg_exporter_config)        | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C     | PG Metrics Definition Document                               |
| 621  | [`pg_exporter_enabled`](v-pgsql.md#pg_exporter_enabled)      | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C     | Enable PG Indicator Collector                                |
| 622  | [`pg_exporter_port`](v-pgsql.md#pg_exporter_port)            | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C     | PG Indicator Exposure Port                                   |
| 623  | [`pg_exporter_params`](v-pgsql.md#pg_exporter_params)        | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | Extra URL parameters for PG Exporter                         |
| 624  | [`pg_exporter_url`](v-pgsql.md#pg_exporter_url)              | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | Acquisition of connection strings for object databases (override) |
| 625  | [`pg_exporter_auto_discovery`](v-pgsql.md#pg_exporter_auto_discovery) | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | Auto-discovery of the database in the instance               |
| 626  | [`pg_exporter_exclude_database`](v-pgsql.md#pg_exporter_exclude_database) | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | Automatic database exclusion list                            |
| 627  | [`pg_exporter_include_database`](v-pgsql.md#pg_exporter_include_database) | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | Automatic database capsule list                              |
| 628  | [`pg_exporter_options`](v-pgsql.md#pg_exporter_options)      | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | PG Exporter CLI parameters                                   |
| 629  | [`pgbouncer_exporter_enabled`](v-pgsql.md#pgbouncer_exporter_enabled) | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C     | Enable PGB Indicator Collector                               |
| 630  | [`pgbouncer_exporter_port`](v-pgsql.md#pgbouncer_exporter_port) | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C     | PGB Indicator Exposure Port                                  |
| 631  | [`pgbouncer_exporter_url`](v-pgsql.md#pgbouncer_exporter_url) | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | Collection of connection strings for object connection pools |
| 632  | [`pgbouncer_exporter_options`](v-pgsql.md#pgbouncer_exporter_options) | [`PG_EXPORTER`](v-pgsql.md#PG_EXPORTER)         | C/I   | PGB Exporter CLI Parameters                                  |
| 640  | [`pg_services`](v-pgsql.md#pg_services)                      | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | G/C   | Global Common Service Definition                             |
| 641  | [`haproxy_enabled`](v-pgsql.md#haproxy_enabled)              | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C/I   | Enable Haproxy                                               |
| 642  | [`haproxy_reload`](v-pgsql.md#haproxy_reload)                | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | A     | Reload Haproxy config                                        |
| 643  | [`haproxy_auth_enabled`](v-pgsql.md#haproxy_auth_enabled) | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | G/C   | Enable authentication for the Haproxy management interface   |
| 644  | [`haproxy_admin_username`](v-pgsql.md#haproxy_admin_username) | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | G     | HAproxy admin user name                                      |
| 645  | [`haproxy_admin_password`](v-pgsql.md#haproxy_admin_password) | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | G     | HAproxy admin user password                                  |
| 646  | [`haproxy_exporter_port`](v-pgsql.md#haproxy_exporter_port)  | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | HAproxy metrics exposer port                                 |
| 647  | [`haproxy_client_timeout`](v-pgsql.md#haproxy_client_timeout) | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | HAproxy client timeout                                       |
| 648  | [`haproxy_server_timeout`](v-pgsql.md#haproxy_server_timeout) | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | HAproxy server timeout                                       |
| 649  | [`vip_mode`](v-pgsql.md#vip_mode)                            | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | VIP mode：none                                               |
| 650  | [`vip_reload`](v-pgsql.md#vip_reload)                        | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | A     | Overload VIP Config                                          |
| 651  | [`vip_address`](v-pgsql.md#vip_address)                      | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | The cluster's VIP address                                    |
| 652  | [`vip_cidrmask`](v-pgsql.md#vip_cidrmask)                    | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | Network CIDR mask length for VIP address                     |
| 653  | [`vip_interface`](v-pgsql.md#vip_interface)                  | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | VIP's network card                                           |
| 654  | [`dns_mode`](v-pgsql.md#dns_mode)                            | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | DNS config mode                                              |
| 655  | [`dns_selector`](v-pgsql.md#dns_selector)                    | [`PG_SERVICE`](v-pgsql.md#PG_SERVICE)           | C     | DNS Object Selector                                          |
| 700  | [`redis_cluster`](v-redis.md#redis_cluster)                  | [`REDIS_IDENTITY`](v-redis.md#REDIS_IDENTITY)   | C     | Redis Cluster Name                                           |
| 701  | [`redis_node`](v-redis.md#redis_node)                        | [`REDIS_IDENTITY`](v-redis.md#REDIS_IDENTITY)   | I     | Redis Node Serial Number                                     |
| 702  | [`redis_instances`](v-redis.md#redis_instances)              | [`REDIS_IDENTITY`](v-redis.md#REDIS_IDENTITY)   | I     | Redis Instance Definition                                    |
| 720  | [`redis_install_method`](v-redis.md#redis_install_method)                  | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | Redis Installation Method                                    |
| 721  | [`redis_mode`](v-redis.md#redis_mode)                        | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | Redis Cluster Mode                                           |
| 722  | [`redis_conf`](v-redis.md#redis_conf)                        | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | Redis Config Template                                        |
| 723  | [`redis_fs_main`](v-redis.md#redis_fs_main)                  | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | PG Instance Role                                             |
| 724  | [`redis_bind_address`](v-redis.md#redis_bind_address)        | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | Redis listening port                                         |
| 725  | [`redis_clean`](v-redis.md#redis_clean)      | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | Actions when Redis exists                                    |
| 726  | [`redis_safeguard`](v-redis.md#redis_safeguard)      | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | Disable wiping of existing Redis                             |
| 727  | [`redis_max_memory`](v-redis.md#redis_max_memory)            | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C/I   | Maximum memory available to Redis                            |
| 728  | [`redis_mem_policy`](v-redis.md#redis_mem_policy)            | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | Memory Eviction Policy                                       |
| 729  | [`redis_password`](v-redis.md#redis_password)                | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | Redis passwords                                              |
| 730  | [`redis_rdb_save`](v-redis.md#redis_rdb_save)                | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | RDB save command                                             |
| 731  | [`redis_aof_enabled`](v-redis.md#redis_aof_enabled)          | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | Enable AOF                                                   |
| 732  | [`redis_rename_commands`](v-redis.md#redis_rename_commands)  | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | Rename Danger Command List                                   |
| 740  | [`redis_cluster_replicas`](v-redis.md#redis_cluster_replicas) | [`REDIS_PROVISION`](v-redis.md#REDIS_PROVISION) | C     | Each master with several slaves                              |
| 741  | [`redis_exporter_enabled`](v-redis.md#redis_exporter_enabled) | [`REDIS_EXPORTER`](v-redis.md#REDIS_EXPORTER)   | C     | Enabling Redis Monitoring                                    |
| 742  | [`redis_exporter_port`](v-redis.md#redis_exporter_port)      | [`REDIS_EXPORTER`](v-redis.md#REDIS_EXPORTER)   | C     | Redis Exporter Listening Port                                |
| 743  | [`redis_exporter_options`](v-redis.md#redis_exporter_options) | [`REDIS_EXPORTER`](v-redis.md#REDIS_EXPORTER)   | C/I   | Redis Exporter Command Parameters                            |

</details>