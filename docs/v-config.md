# Configuring Pigsty

Pigsty uses declarative [configuration] (c-config.md) to describe desired state.
And the idempotent provisioning playbooks are responsible for adjusting system into that state.

Pigsty config is consist of 175 [config entry](#config-entries), 
divided into 10 [groups](#config-groups) and 5 levels. 
Most of them does not need your attention. Only identity parameters are required for defining new database clusters.


## Config Groups

| No | Group | Category | Count | Functionality |
| :--: | :----------------------------: | :------: | :--: | -------------------------------------- |
| 1 | [connect](v-connect.md) | Infra | 1 | Proxy server configuration, connection information for managed objects |
| 2 | [repo](v-repo.md) | Infra | 10 | Customize local Yum sources, install packages offline |
| 3 | [node](v-node.md) | Infra | 31 | Configure the infrastructure on a normal node |
| 4 | [meta](v-meta.md) | Infra | 25 | Installing and enabling infrastructure services on a meta node |
| 5 | [dcs](v-dcs.md) | Infra | 8 | Configure DCS services (consul/etcd) on all nodes |
| 6 | [pg-install](v-pg-install.md) | PgSQL | 11 | Install PostgreSQL database |
| 7 | [pg-provision](v-pg-provision.md) | PgSQL | 32 | Pulling up a PostgreSQL database cluster |
| 8 | [pg-template](v-pg-template.md) | PgSQL | 19 | Customizing PostgreSQL database content |
| 9 | [monitor](v-monitor.md) | PgSQL | 21 | Installing Pigsty database monitoring system |
| 10 | [service](v-service.md) | PgSQL | 17 | Expose database services to the public via Haproxy or VIP |



## Config Entries

|           Group         |                            Name                             |    Type    | Level  | Description |
| :----------------------: | :----------------------------------------------------------: | :--------: | :---: | ---- |
|  [connect](v-connect.md)  |              [proxy_env](v-connect.md#proxy_env)               |  `dict`  |   G   | proxy environment variables |
|   [repo](v-repo.md)    |             [repo_enabled](v-repo.md#repo_enabled)             |  `bool`  |   G   | enable local yum repo |
|   [repo](v-repo.md)    |                [repo_name](v-repo.md#repo_name)                |  `string`  |   G   | local yum repo name |
|   [repo](v-repo.md)    |             [repo_address](v-repo.md#repo_address)             |  `string`  |   G   | external access point of repo |
|   [repo](v-repo.md)    |                [repo_port](v-repo.md#repo_port)                |  `number`  |   G   | repo listen address (80) |
|   [repo](v-repo.md)    |                [repo_home](v-repo.md#repo_home)                |  `string`  |   G   | repo home dir (www) |
|   [repo](v-repo.md)    |             [repo_rebuild](v-repo.md#repo_rebuild)             |  `bool`  |   A   | rebuild local yum repo? |
|   [repo](v-repo.md)    |              [repo_remove](v-repo.md#repo_remove)              |  `bool`  |   A   | remove existing repo file? |
|   [repo](v-repo.md)    |           [repo_upstreams](v-repo.md#repo_upstreams)           |  `object[]`  |   G   | upstream repo definition |
|   [repo](v-repo.md)    |            [repo_packages](v-repo.md#repo_packages)            | `string[]` | G | packages to be downloaded |
|   [repo](v-repo.md)    |        [repo_url_packages](v-repo.md#repo_url_packages)        | `string[]` | G | pkgs to be downloaded via url |
|    [node](v-node.md)    |                 [nodename](v-node.md#nodename)                 |  `string`  |  I  | overwrite hostname if specified |
|    [node](v-node.md)    |           [node_dns_hosts](v-node.md#node_dns_hosts)           |  `string[]`  |  G  | static DNS records |
|    [node](v-node.md)    |          [node_dns_server](v-node.md#node_dns_server)          |  `enum`  |  G  | how to setup dns service? |
|    [node](v-node.md)    |         [node_dns_servers](v-node.md#node_dns_servers)         |  `string[]`  |  G  | dynamic DNS servers |
|    [node](v-node.md)    |         [node_dns_options](v-node.md#node_dns_options)         |  `string[]`  |  G  | /etc/resolv.conf options |
|    [node](v-node.md)    |         [node_repo_method](v-node.md#node_repo_method)         |  `enum`  |  G  | how to use yum repo (local) |
|    [node](v-node.md)    |         [node_repo_remove](v-node.md#node_repo_remove)         |  `bool`  |  G  | remove existing repo file? |
|    [node](v-node.md)    |      [node_local_repo_url](v-node.md#node_local_repo_url)      |  `string[]`  |  G  | local yum repo url |
|    [node](v-node.md)    |            [node_packages](v-node.md#node_packages)            |  `string[]`  |  G  | pkgs to be installed on all node |
|    [node](v-node.md)    |      [node_extra_packages](v-node.md#node_extra_packages)      |  `string[]`  |  C/I/A  | extra pkgs to be installed |
|    [node](v-node.md)    |       [node_meta_packages](v-node.md#node_meta_packages)       |  `string[]`  |  G  | meta node only packages |
|    [node](v-node.md)    | [node_meta_pip_install](v-node.md#node_meta_pip_install)       |  `string`  |  G  | meta node pip3 packages |
|    [node](v-node.md)    |        [node_disable_numa](v-node.md#node_disable_numa)        |  `bool`  |  G  | disable numa? |
|    [node](v-node.md)    |        [node_disable_swap](v-node.md#node_disable_swap)        |  `bool`  |  G  | disable swap? |
|    [node](v-node.md)    |    [node_disable_firewall](v-node.md#node_disable_firewall)    |  `bool`  |  G  | disable firewall? |
|    [node](v-node.md)    |     [node_disable_selinux](v-node.md#node_disable_selinux)     |  `bool`  |  G  | disable selinux? |
|    [node](v-node.md)    |      [node_static_network](v-node.md#node_static_network)      |  `bool`  |  G  | use static DNS config? |
|    [node](v-node.md)    |       [node_disk_prefetch](v-node.md#node_disk_prefetch)       |  `bool`  |  G  | enable disk prefetch? |
|    [node](v-node.md)    |      [node_kernel_modules](v-node.md#node_kernel_modules)      |  `string[]`  |  G  | kernel modules to be installed |
|    [node](v-node.md)    |                [node_tune](v-node.md#node_tune)                |  `enum`  |  G  | node tune mode |
|    [node](v-node.md)    |       [node_sysctl_params](v-node.md#node_sysctl_params)       |  `dict`  |  G  | extra kernel parameters |
|    [node](v-node.md)    |         [node_admin_setup](v-node.md#node_admin_setup)         |  `bool`  |  G  | create admin user? |
|    [node](v-node.md)    |           [node_admin_uid](v-node.md#node_admin_uid)           |  `number`  |  G  | admin user UID |
|    [node](v-node.md)    |      [node_admin_username](v-node.md#node_admin_username)      |  `string`  |  G  | admin user name |
|    [node](v-node.md)    |  [node_admin_ssh_exchange](v-node.md#node_admin_ssh_exchange)  |  `bool`  |  G  | exchange admin ssh keys? |
|    [node](v-node.md) | [node_admin_current_pk](v-node.md#node_admin_current_pk) | `bool` | A | add current user's pkey? |
|    [node](v-node.md)    |           [node_admin_pks](v-node.md#node_admin_pks)           |  `string[]`  |  G  | pks to be added to admin |
|    [node](v-node.md)    |         [node_ntp_service](v-node.md#node_ntp_service)         |  `enum`  |  G  | ntp mode: ntp or chrony? |
|    [node](v-node.md)    |          [node_ntp_config](v-node.md#node_ntp_config)          |  `bool`  |  G  | setup ntp on node? |
|    [node](v-node.md)    |            [node_timezone](v-node.md#node_timezone)            |  `string`  |  G  | node timezone |
|    [node](v-node.md)    |         [node_ntp_servers](v-node.md#node_ntp_servers)         |  `string[]`  |  G  | ntp server list |
|    [meta](v-meta.md)    |                [ca_method](v-meta.md#ca_method)                |  `enum`  |  G  | ca mode |
|    [meta](v-meta.md)    |               [ca_subject](v-meta.md#ca_subject)               |  `string`  |  G  | ca subject |
|    [meta](v-meta.md)    |               [ca_homedir](v-meta.md#ca_homedir)               |  `string`  |  G  | ca cert home dir |
|    [meta](v-meta.md)    |                  [ca_cert](v-meta.md#ca_cert)                  |  `string`  |  G  | ca cert file name |
|    [meta](v-meta.md)    |                   [ca_key](v-meta.md#ca_key)                   |  `string`  |  G  | ca private key name |
|    [meta](v-meta.md)    |           [nginx_upstream](v-meta.md#nginx_upstream)           |  `object[]`  |  G  | nginx upstream definition |
|    [meta](v-meta.md)    |              [dns_records](v-meta.md#dns_records)              |  `string[]`  |  G  | dynamic DNS records |
|    [meta](v-meta.md)    |      [prometheus_data_dir](v-meta.md#prometheus_data_dir)      |  `string`  |  G  | prometheus data dir |
|    [meta](v-meta.md)    |       [prometheus_options](v-meta.md#prometheus_options)       |  `string`  |  G  | prometheus cli args |
|    [meta](v-meta.md)    |        [prometheus_reload](v-meta.md#prometheus_reload)        |  `bool`  |  A  | prom reload instead of init |
|    [meta](v-meta.md)    |     [prometheus_sd_method](v-meta.md#prometheus_sd_method)     |  `enum`  |  G  | service discovery method: static\|consul |
|    [meta](v-meta.md)    | [prometheus_scrape_interval](v-meta.md#prometheus_scrape_interval) |  `interval`  |  G  | prom scrape interval (10s) |
|    [meta](v-meta.md)    | [prometheus_scrape_timeout](v-meta.md#prometheus_scrape_timeout) |  `interval`  |  G  | prom scrape timeout (8s) |
|    [meta](v-meta.md)    |   [prometheus_sd_interval](v-meta.md#prometheus_sd_interval)   |  `interval`  |  G  | prom discovery refresh interval |
|    [meta](v-meta.md)    |        [grafana_endpoint](v-meta.md#grafana_endpoint)         |  `string`  |  G  | grafana API endpoint |
|    [meta](v-meta.md)    |   [grafana_admin_username](v-meta.md#grafana_admin_username)   |  `string`  |  G  | grafana admin username |
|    [meta](v-meta.md)    |   [grafana_admin_password](v-meta.md#grafana_admin_password)   |  `string`  |  G  | grafana admin password |
|    [meta](v-meta.md)    |         [grafana_database](v-meta.md#grafana_database)         |  `string`  |  G  | grafana backend database type |
|    [meta](v-meta.md)    |            [grafana_pgurl](v-meta.md#grafana_pgurl)            |  `string`  |  G  | grafana backend postgres url |
|    [meta](v-meta.md)    |           [grafana_plugin](v-meta.md#grafana_plugin)           |  `enum`  |  G  | how to install grafana plugins |
|    [meta](v-meta.md)    |            [grafana_cache](v-meta.md#grafana_cache)            |  `string`  |  G  | grafana plugins cache path |
|    [meta](v-meta.md)    |          [grafana_plugins](v-meta.md#grafana_plugins)          |  `string[]`  |  G  | grafana plugins to be installed |
|    [meta](v-meta.md)    |      [grafana_git_plugins](v-meta.md#grafana_git_plugins)      |  `string[]`  |  G  | grafana plugins via git |
|    [meta](v-meta.md)    |      [loki_clean](v-meta.md#loki_clean)                        |  `bool`  |  A  | remove existing loki data? |
|    [meta](v-meta.md)    |      [loki_data_dir](v-meta.md#loki_data_dir)                  |  `string`  |  G  | loki data path |
|    [dcs](v-dcs.md)     |         [service_registry](v-dcs.md#service_registry)          |  `enum`  |  G/C/I  | where to register service? |
|    [dcs](v-dcs.md)     |                 [dcs_type](v-dcs.md#dcs_type)                  |  `enum`  |  G  | which dcs to use (consul/etcd) |
|    [dcs](v-dcs.md)     |                 [dcs_name](v-dcs.md#dcs_name)                  |  `string`  |  G  | dcs cluster name (dc) |
|    [dcs](v-dcs.md)     |              [dcs_servers](v-dcs.md#dcs_servers)               |  `dict`  |  G  | dcs server dict |
|    [dcs](v-dcs.md)     |        [dcs_exists_action](v-dcs.md#dcs_exists_action)         |  `enum`  |  G/A  | how to deal with existing dcs |
|    [dcs](v-dcs.md)     |        [dcs_disable_purge](v-dcs.md#dcs_disable_purge)         |  `bool`  |  G/C/I  | disable dcs purge |
|    [dcs](v-dcs.md)     |          [consul_data_dir](v-dcs.md#consul_data_dir)           |  `string`  |  G  | consul data dir path |
|    [dcs](v-dcs.md)     |            [etcd_data_dir](v-dcs.md#etcd_data_dir)             |  `string`  |  G  | etcd data dir path |
|  [pg-install](v-pg-install.md)  |               [pg_dbsu](v-pg-install.md#pg_dbsu)               |  `string`  |  G/C  | os dbsu for postgres |
|  [pg-install](v-pg-install.md)  |           [pg_dbsu_uid](v-pg-install.md#pg_dbsu_uid)           |  `number`  |  G/C  | dbsu UID |
|  [pg-install](v-pg-install.md)  |          [pg_dbsu_sudo](v-pg-install.md#pg_dbsu_sudo)          |  `enum`  |  G/C  | sudo priv mode for dbsu |
|  [pg-install](v-pg-install.md)  |          [pg_dbsu_home](v-pg-install.md#pg_dbsu_home)          |  `string`  |  G/C  | home dir for dbsu |
|  [pg-install](v-pg-install.md)  |  [pg_dbsu_ssh_exchange](v-pg-install.md#pg_dbsu_ssh_exchange)  |  `bool`  |  G/C  | exchange dbsu ssh keys? |
|  [pg-install](v-pg-install.md)  |            [pg_version](v-pg-install.md#pg_version)            |  `string`  |  G/C  | major PG version to be installed |
|  [pg-install](v-pg-install.md)  |             [pgdg_repo](v-pg-install.md#pgdg_repo)             |  `bool`  |  G/C  | add official PGDG repo? |
|  [pg-install](v-pg-install.md)  |           [pg_add_repo](v-pg-install.md#pg_add_repo)           |  `bool`  |  G/C  | add extra upstream PG repo? |
|  [pg-install](v-pg-install.md)  |            [pg_bin_dir](v-pg-install.md#pg_bin_dir)            |  `string`  |  G/C  | PG binary dir |
|  [pg-install](v-pg-install.md)  |           [pg_packages](v-pg-install.md#pg_packages)           |  `string[]`  |  G/C  | PG packages to be installed |
|  [pg-install](v-pg-install.md)  |         [pg_extensions](v-pg-install.md#pg_extensions)         |  `string[]`  |  G/C  | PG extension pkgs to be installed |
| [pg-provision](v-pg-provision.md) |           [pg_cluster](v-pg-provision.md#pg_cluster)           |  `string`  |  **C**  | **PG Cluster Name** |
| [pg-provision](v-pg-provision.md) |               [pg_seq](v-pg-provision.md#pg_seq)               |  `number`  |  **I**  | **PG Instance Sequence** |
| [pg-provision](v-pg-provision.md) |              [pg_role](v-pg-provision.md#pg_role)              |  `enum`  |  **I**  | **PG Instance Role** |
| [pg-provision](v-pg-provision.md) |          [pg_hostname](v-pg-provision.md#pg_hostname)          |  `bool`  |  G/C  | set PG ins name as hostname |
| [pg-provision](v-pg-provision.md) |          [pg_nodename](v-pg-provision.md#pg_nodename)          |  `bool`  |  G/C  | set PG ins name as consul nodename |
| [pg-provision](v-pg-provision.md) |            [pg_exists](v-pg-provision.md#pg_exists)            |  `bool`  |  A  | flag indicate pg exists |
| [pg-provision](v-pg-provision.md) |     [pg_exists_action](v-pg-provision.md#pg_exists_action)     |  `enum`  |  G/A  | how to deal with existing pg ins |
| [pg-provision](v-pg-provision.md) | [pg_disable_purge](v-pg-provision.md#pg_disable_purge)         | `bool`  | G/C/I | disable pg instance purge |
| [pg-provision](v-pg-provision.md) |              [pg_data](v-pg-provision.md#pg_data)              |  `string`  |  G  | pg data dir |
| [pg-provision](v-pg-provision.md) |           [pg_fs_main](v-pg-provision.md#pg_fs_main)           |  `string`  |  G  | pg main data disk mountpoint |
| [pg-provision](v-pg-provision.md) |           [pg_fs_bkup](v-pg-provision.md#pg_fs_bkup)           |  `path`  |  G  | pg backup disk mountpoint |
| [pg-provision](v-pg-provision.md) |            [pg_listen](v-pg-provision.md#pg_listen)            |  `ip`  |  G  | pg listen IP address |
| [pg-provision](v-pg-provision.md) |              [pg_port](v-pg-provision.md#pg_port)              |  `number`  |  G  | pg listen port |
| [pg-provision](v-pg-provision.md) |         [pg_localhost](v-pg-provision.md#pg_localhost)         |  `string`  |  G/C  | pg unix socket path |
| [pg-provision](v-pg-provision.md) |            [pg_upstream](v-pg-provision.md#pg_upstream)        | `string` | I | pg upstream IP address |
| [pg-provision](v-pg-provision.md) |            [pg_backup](v-pg-provision.md#pg_backup)            | `bool`    | I | make base backup on this ins? |
| [pg-provision](v-pg-provision.md) |            [pg_delay](v-pg-provision.md#pg_delay)              | `interval` | I | apply lag for delayed instance |
| [pg-provision](v-pg-provision.md) |         [patroni_mode](v-pg-provision.md#patroni_mode)         |  `enum`  |  G/C  | patroni working mode |
| [pg-provision](v-pg-provision.md) |         [pg_namespace](v-pg-provision.md#pg_namespace)         |  `string`  |  G/C  | namespace for patroni |
| [pg-provision](v-pg-provision.md) |         [patroni_port](v-pg-provision.md#patroni_port)         |  `string`  |  G/C  | patroni listen port (8080) |
| [pg-provision](v-pg-provision.md) | [patroni_watchdog_mode](v-pg-provision.md#patroni_watchdog_mode) |  `enum`  |  G/C  | patroni watchdog policy |
| [pg-provision](v-pg-provision.md) |              [pg_conf](v-pg-provision.md#pg_conf)              |  `enum`  |  G/C  | patroni template |
| [pg-provision](v-pg-provision.md) |   [pg_shared_libraries](v-pg-provision.md#pg_shared_libraries) |  `string`  |  G/C  | default preload shared libraries |
| [pg-provision](v-pg-provision.md) |          [pg_encoding](v-pg-provision.md#pg_encoding)          |  `string`  |  G/C  | character encoding |
| [pg-provision](v-pg-provision.md) |            [pg_locale](v-pg-provision.md#pg_locale)            |  `enum`  |  G/C  | locale |
| [pg-provision](v-pg-provision.md) |        [pg_lc_collate](v-pg-provision.md#pg_lc_collate)        |  `enum`  |  G/C  | collate rule of locale |
| [pg-provision](v-pg-provision.md) |          [pg_lc_ctype](v-pg-provision.md#pg_lc_ctype)          |  `enum`  |  G/C  | ctype of locale |
| [pg-provision](v-pg-provision.md) |       [pgbouncer_port](v-pg-provision.md#pgbouncer_port)       |  `number`  |  G/C  | pgbouncer listen port |
| [pg-provision](v-pg-provision.md) |   [pgbouncer_poolmode](v-pg-provision.md#pgbouncer_poolmode)   |  `enum`  |  G/C  | pgbouncer pooling mode |
| [pg-provision](v-pg-provision.md) | [pgbouncer_max_db_conn](v-pg-provision.md#pgbouncer_max_db_conn) |  `number`  |  G/C  | max connection per database |
| [pg-template](v-pg-template.md) |              [pg_init](v-pg-template.md#pg_init)               |  `string`  |  G/C  | path to postgres init script |
| [pg-template](v-pg-template.md) | [pg_replication_username](v-pg-template.md#pg_replication_username) |  `string`  |  G  | replication user's name |
| [pg-template](v-pg-template.md) | [pg_replication_password](v-pg-template.md#pg_replication_password) |  `string`  |  G  | replication user's password |
| [pg-template](v-pg-template.md) |  [pg_monitor_username](v-pg-template.md#pg_monitor_username)   |  `string`  |  G  | monitor user's name |
| [pg-template](v-pg-template.md) |  [pg_monitor_password](v-pg-template.md#pg_monitor_password)   |  `string`  |  G  | monitor user's password |
| [pg-template](v-pg-template.md) |    [pg_admin_username](v-pg-template.md#pg_admin_username)     |  `string`  |  G  | admin user's name |
| [pg-template](v-pg-template.md) |    [pg_admin_password](v-pg-template.md#pg_admin_password)     |  `string`  |  G  | admin user's password |
| [pg-template](v-pg-template.md) |     [pg_default_roles](v-pg-template.md#pg_default_roles)      |  `role[]`  |  G  | list or global default roles/users |
| [pg-template](v-pg-template.md) | [pg_default_privilegs](v-pg-template.md#pg_default_privilegs)  |  `string[]`  |  G  | list of default privileges |
| [pg-template](v-pg-template.md) |   [pg_default_schemas](v-pg-template.md#pg_default_schemas)    |  `string[]`  |  G  | list of default schemas |
| [pg-template](v-pg-template.md) | [pg_default_extensions](v-pg-template.md#pg_default_extensions) |  `extension[]`  |  G  | list of default extensions |
| [pg-template](v-pg-template.md) |     [pg_offline_query](v-pg-template.md#pg_offline_query)      |  `bool`  |  **I**  | allow offline query? |
| [pg-template](v-pg-template.md) |            [pg_reload](v-pg-template.md#pg_reload)             |  `bool`  |  **A**  | reload configuration? |
| [pg-template](v-pg-template.md) |         [pg_hba_rules](v-pg-template.md#pg_hba_rules)          |  `rule[]`  |  G  | global HBA rules |
| [pg-template](v-pg-template.md) |   [pg_hba_rules_extra](v-pg-template.md#pg_hba_rules_extra)    |  `rule[]`  |  C/I  | ad hoc HBA rules |
| [pg-template](v-pg-template.md) |  [pgbouncer_hba_rules](v-pg-template.md#pgbouncer_hba_rules)   |  `rule[]`  |  G/C  | global pgbouncer HBA rules |
| [pg-template](v-pg-template.md) | [pgbouncer_hba_rules_extra](v-pg-template.md#pgbouncer_hba_rules_extra) |  `rule[]`  |  G/C  | ad hoc pgbouncer HBA rules |
| [pg-template](v-pg-template.md) | [pg_databases](v-pg-template.md#pg_databases) | `database[]`   | G/C | [business databases definition](c-database.md) |
| [pg-template](v-pg-template.md) | [pg_users](v-pg-template.md#pg_users) | `user[]`               | G/C | [business users definition](c-user.md) |
|  [monitor](v-monitor.md)   |       [exporter_install](v-monitor.md#exporter_install)        |  `enum`  |  G/C  | how to install exporter? |
|  [monitor](v-monitor.md)   |      [exporter_repo_url](v-monitor.md#exporter_repo_url)       |  `string`  |  G/C  | repo url for yum install |
|  [monitor](v-monitor.md)   |  [exporter_metrics_path](v-monitor.md#exporter_metrics_path)   |  `string`  |  G/C  | URL path for exporting metrics |
|  [monitor](v-monitor.md)   |  [node_exporter_enabled](v-monitor.md#node_exporter_enabled)   |  `bool`  |  G/C  | node_exporter enabled? |
|  [monitor](v-monitor.md)   |     [node_exporter_port](v-monitor.md#node_exporter_port)      |  `number`  |  G/C  | node_exporter listen port |
|  [monitor](v-monitor.md)   |  [node_exporter_options](v-monitor.md#node_exporter_options)   |  `string`  |  G/C  | node_exporter extra cli args |
|  [monitor](v-monitor.md)   |     [pg_exporter_config](v-monitor.md#pg_exporter_config)      |  `string`  |  G/C  | pg_exporter config path |
|  [monitor](v-monitor.md)   |    [pg_exporter_enabled](v-monitor.md#pg_exporter_enabled)     |  `bool`  |  G/C  | pg_exporter enabled ? |
|  [monitor](v-monitor.md)   |       [pg_exporter_port](v-monitor.md#pg_exporter_port)        |  `number`  |  G/C  | pg_exporter listen address |
|  [monitor](v-monitor.md)   |        [pg_exporter_url](v-monitor.md#pg_exporter_url)         |  `string`  |  G/C  | monitor target pgurl (overwrite) |
|  [monitor](v-monitor.md)   |[pg_exporter_auto_discovery](v-monitor.md#pg_exporter_auto_discovery)     |  `bool`    |  G/C  | enable auto-database-discovery? |
|  [monitor](v-monitor.md)   |[pg_exporter_exclude_database](v-monitor.md#pg_exporter_exclude_database) |  `string`  |  G/C  | excluded list of databases |
|  [monitor](v-monitor.md)   |[pg_exporter_include_database](v-monitor.md#pg_exporter_include_database) |  `string`  |  G/C  | included list of databases |
|  [monitor](v-monitor.md)   | [pgbouncer_exporter_enabled](v-monitor.md#pgbouncer_exporter_enabled) |  `bool`  |  G/C  | pgbouncer_exporter enabled ? |
|  [monitor](v-monitor.md)   | [pgbouncer_exporter_port](v-monitor.md#pgbouncer_exporter_port) |  `number`  |  G/C  | pgbouncer_exporter listen addr? |
|  [monitor](v-monitor.md)   | [pgbouncer_exporter_url](v-monitor.md#pgbouncer_exporter_url)  |  `string`  |  G/C  | target pgbouncer url (overwrite) |
|  [monitor](v-monitor.md)   | [promtail_enabled](v-monitor.md#promtail_enabled)  |  `bool`  |  G/C  | promtail enabled ? |
|  [monitor](v-monitor.md)   | [promtail_clean](v-monitor.md#promtail_clean)  |  `bool`  |  G/C/A  | remove promtail status file ? |
|  [monitor](v-monitor.md)   | [promtail_port](v-monitor.md#promtail_port)  |  `number`  |  G/C  | promtail listen port |
|  [monitor](v-monitor.md)   | [promtail_status_path](v-monitor.md#promtail_status_path)  |  `string`  |  G/C  | path to store promtail status file |
|  [monitor](v-monitor.md)   | [promtail_send_url](v-monitor.md#promtail_send_url)  |  `string`  |  G/C  | loki endpoint to receive log |
|  [service](v-service.md)  |              [pg_weight](v-service.md#pg_weight)              |  `number`  |  **I**  | relative weight in load balancer |
|  [service](v-service.md)  |            [pg_services](v-service.md#pg_services)            |  `service[]`  |  G  | global [service definition](c-service) |
|  [service](v-service.md)  |      [pg_services_extra](v-service.md#pg_services_extra)      |  `service[]`  |  C  | ad hoc [service definition](c-service.md) |
|  [service](v-service.md)  |        [haproxy_enabled](v-service.md#haproxy_enabled)        |  `bool`  |  G/C/I  | haproxy enabled ? |
|  [service](v-service.md)  |         [haproxy_reload](v-service.md#haproxy_reload)         |  `bool`  |  A  | haproxy reload instead of reset |
|  [service](v-service.md)  | [haproxy_admin_auth_enabled](v-service.md#haproxy_admin_auth_enabled) |  `bool`  |  G/C  | enable auth for haproxy admin ? |
|  [service](v-service.md)  | [haproxy_admin_username](v-service.md#haproxy_admin_username) |  `string`  |  G/C  | haproxy admin user name |
|  [service](v-service.md)  | [haproxy_admin_password](v-service.md#haproxy_admin_password) |  `string`  |  G/C  | haproxy admin password |
|  [service](v-service.md)  |  [haproxy_exporter_port](v-service.md#haproxy_exporter_port)  |  `number`  |  G/C  | haproxy exporter listen port |
|  [service](v-service.md)  | [haproxy_client_timeout](v-service.md#haproxy_client_timeout) |  `interval`  |  G/C  | haproxy client timeout |
|  [service](v-service.md)  | [haproxy_server_timeout](v-service.md#haproxy_server_timeout) |  `interval`  |  G/C  | haproxy server timeout |
|  [service](v-service.md)  |               [vip_mode](v-service.md#vip_mode)               |  `enum`  |  G/C  | vip working mode |
|  [service](v-service.md)  |             [vip_reload](v-service.md#vip_reload)             |  `bool`  |  G/C  | reload vip configuration |
|  [service](v-service.md)  |            [vip_address](v-service.md#vip_address)            |  `string`  |  G/C  | vip address used by cluster |
|  [service](v-service.md)  |           [vip_cidrmask](v-service.md#vip_cidrmask)           |  `number`  |  G/C  | vip network CIDR |
|  [service](v-service.md)  |          [vip_interface](v-service.md#vip_interface)          |  `string`  |  G/C  | vip network interface name |
|  [service](v-service.md)  |           [dns_mode](v-service.md#dns_mode)              |  `enum`  |  G/C  | cluster DNS mode |
|  [service](v-service.md)  |          [dns_selector](v-service.md#dns_selector)          |  `string`  |  G/C  | cluster DNS ins selector |

