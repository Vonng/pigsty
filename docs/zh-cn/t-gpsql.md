# 部署与监控MatrixDB (Greenplum7)

Pigsty可用于部署与监控 MatrixDB （等效于Greenplum 7 ）
因为目前MatrixDB使用的是PostgreSQL 12的内核，而原生Greenplum仍然使用9.6内核，因此优先使用MatrixDB作为Greenplum实现。

## MatrixDB 实体概念模型

MatrixDB在逻辑上由两部分组成，Master与Segments，两者均由PostgreSQL实例组成，实例分为四类：Master/Standby/Primary/Mirror

* Master为用户直接接触的访问端点，用于承接查询，一套MatrixDB部署仅有一个，通常使用独立节点部署。
* Standby是Master实例的物理从库，用于当Master故障时顶替，是可选的组件，通常也使用独立节点部署。
* 一套MatrixDB部署通常有多个Segment，每个Segment通常由一个必选的 primary 实例与一个 可选的 mirror 实例组成。
* Segment的primary负责实际存储与计算，mirror通常不承担读写流量，当primary宕机时顶替primary，通常与primary分布在不同节点上。
* Segment的primary与mirror分布由MatrixDB安装向导决定，在集群的Segments节点上通常可能存在有多个不同的Segment实例

**部署惯例**
* Master集群 (master/standby) (`gp_role-master`) 构成一个PostgreSQL集群，通常命名包含`mdw`，如`mx-mdw`
* 每个Segment (primary/mirror) 构成一个PostgreSQL集群，通常集群命名包含`seg`，如 `mx-seg1`, `mx-seg2`
* 用户应当显式为集群节点命名，例如 `mx-sdw-1`, `mx-sdw-2`, ...

## 样例配置

```yaml
#----------------------------------#
# cluster: mx-mdw (gp master)
#----------------------------------#
mx-mdw:
  hosts:
    10.10.10.10: { pg_seq: 1, pg_role: primary , nodename: mx-mdw-1 }
  vars:
    gp_role: master          # this cluster is used as greenplum master
    pg_cluster: mx-mdw       # this master cluster name is mx-mdw
    pg_databases:
      - { name: matrixmgr , extensions: [ { name: matrixdbts } ] }
      - { name: meta }
    pg_users:
      - { name: meta , password: DBUser.Meta , pgbouncer: true }
      - { name: dbuser_monitor , password: DBUser.Monitor , roles: [ dbrole_readonly ], superuser: true }

    pg_dbsu: mxadmin              # matrixdb dbsu
    pg_dbsu_uid: 1226             # matrixdb dbsu uid & gid
    pg_dbsu_home: /home/mxadmin   # matrixdb dbsu homedir
    pg_localhost: /tmp            # default unix socket dir
    pg_data: /mxdata/master/mxseg-1 # default data dir for mxdb master
    node_name_exchange: true      # exchange node names among cluster
    patroni_enabled: false        # do not pull up normal postgres with patroni
    pgbouncer_enabled: true       # enable pgbouncer for greenplum master
    pg_provision: false           # provision postgres template & database & user
    haproxy_enabled: false        # disable haproxy monitor on greenplum
    pg_monitor_username: mxadmin  # use default dbsu as monitor username (not recommended in production env)
    pg_monitor_password: mxadmin  # use default dbsu name as monitor password (strongly not recommended in production env)
    pg_exporter_params: 'host=127.0.0.1&sslmode=disable'  # use 127.0.0.1 as local monitor host
    pg_exporter_exclude_database: 'template0,template1,postgres,matrixmgr' # optional, comma separated list of database that WILL NOT be monitored when auto-discovery enabled
    pg_packages: [ 'matrixdb postgresql${pg_version}* pgbouncer pg_exporter node_exporter consul pgbadger pg_activity' ]
    pg_extensions: [ ]
    node_local_repo_url:          # local repo url (if method=local, make sure firewall is configured or disabled)
      - http://pigsty/pigsty.repo
      - http://pigsty/matrix.repo

#----------------------------------#
# cluster: mx-sdw (gp master)
#----------------------------------#
mx-sdw:
  hosts:
    10.10.10.11:
      nodename: mx-sdw-1        # greenplum segment node
      pg_instances:             # greenplum segment instances
        6000: { pg_cluster: mx-seg1, pg_seq: 1, pg_role: primary , pg_exporter_port: 9633 }
        6001: { pg_cluster: mx-seg2, pg_seq: 2, pg_role: replica , pg_exporter_port: 9634 }
    10.10.10.12:
      nodename: mx-sdw-2
      pg_instances:
        6000: { pg_cluster: mx-seg2, pg_seq: 1, pg_role: primary , pg_exporter_port: 9633  }
        6001: { pg_cluster: mx-seg3, pg_seq: 2, pg_role: replica , pg_exporter_port: 9634  }
    10.10.10.13:
      nodename: mx-sdw-3
      pg_instances:
        6000: { pg_cluster: mx-seg3, pg_seq: 1, pg_role: primary , pg_exporter_port: 9633 }
        6001: { pg_cluster: mx-seg1, pg_seq: 2, pg_role: replica , pg_exporter_port: 9634 }
  vars:
    gp_cluster: mx                 # greenplum cluster name
    pg_cluster: mx-sdw
    gp_role: segment               # these are nodes for gp segments
    node_cluster: mx-sdw           # node cluster name of sdw nodes

    pg_preflight_skip: true       # skip preflight check
    pg_dbsu: mxadmin              # matrixdb dbsu
    pg_dbsu_uid: 1226             # matrixdb dbsu uid & gid
    pg_dbsu_home: /home/mxadmin   # matrixdb dbsu homedir
    node_name_exchange: true      # exchange node names among cluster
    patroni_enabled: false        # do not pull up normal postgres with patroni
    pgbouncer_enabled: false      # enable pgbouncer for greenplum master
    pgbouncer_exporter_enabled: false      # enable pgbouncer for greenplum master
    pg_provision: false           # provision postgres template & database & user
    haproxy_enabled: false        # disable haproxy monitor on greenplum
    pg_localhost: /tmp            # connect to segments via /tmp unix socket
    pg_monitor_username: mxadmin  # use default dbsu as monitor username (not recommended in production env)
    pg_monitor_password: mxadmin  # use default dbsu name as monitor password (strongly not recommended in production env)
    pg_exporter_config: pg_exporter_basic.yml                             # use basic config to avoid segment server crash
    pg_exporter_params: 'options=-c%20gp_role%3Dutility&sslmode=disable'  # use gp_role = utility to connect to segments
    pg_exporter_exclude_database: 'template0,template1,postgres,matrixmgr' # optional, comma separated list of database that WILL NOT be monitored when auto-discovery enabled
    pg_packages: [ 'matrixdb postgresql${pg_version}* pgbouncer pg_exporter node_exporter consul pgbadger pg_activity' ]
    pg_extensions: [ ]
    node_local_repo_url: # local repo url (if method=local, make sure firewall is configured or disabled)
      - http://pigsty/pigsty.repo
      - http://pigsty/matrix.repo

```

## 准备安装
您需要准备好MatrixDB的本地安装包（请联系MatrixDB厂商或从公开网站下载，可免费下载使用但非开源）

```bash
make matrix         # 上传 matrixdb 相关资源到沙箱元节点
configure -m mxdb   # 使用 MatrixDB 配置模板
```

### 开始部署

在四节点沙箱环境中部署MatrixDB，注意，默认将使用DBSU `mxadmin:mxadmin` 作为监控用户名与密码

```bash
./meta.yml -e no_cmdb=true     # 如果您准备在meta节点上部署 MatrixDB Master，添加no_cmdb选项
./node.yml                     # 初始化 mdw, sdw 集群的节点，纳入监控
./gpsql.yml                    # 完成 mdw, sdw 节点上 MatrixDB 的安装准备与监控
```

安装完成后，您需要通过MatrixDB 提供的WEB UI完成接下来的安装
打开 http://matrix.pigsty 或访问 http://10.10.10.10:8240，填入 gpsql.yml 输出的初始用户密码进入安装向导 
按照提示依次添加MatrixDB的节点：10.10.10.11, 10.10.10.12, 10.10.10.13，点击确认安装并等待完成后，进行下一步。
因为监控默认使用 mxadmin:mxadmin 作为监控用户名密码，请填入`mxadmin` 或您自己的密码。 
如果您在安装向导中指定了不同的密码， 请一并更改 `pg_monitor_username` 与 `pg_monitor_password` 变量（如果您使用不同于dbsu的用户，通常还需要在所有实例上配置额外的HBA）。

### 收尾工作

最后，在Greenplum/MatrixDB Master节点上执行以下命令，允许监控组件访问**从库**，并重启生效。

```bash
sudo su - mxadmin
psql postgres -c "ALTER SYSTEM SET hot_standby = on;"       # 配置 hot_standby=on 以允许从库查询
psql matrixmgr -c 'SELECT mxmgr_init_local();'              # 初始化MatrixDB自身监控
gpconfig -c hot_standby -v on -m on                         # 配置 hot_standby=on 以允许从库查询
gpstop -a -r -M immediate                                   # 重启MatrixDB以生效
```

然后，您便可以从监控系统中，观察到所有MatrixDB集群。

可选：在元节点上执行剧本，在MatrixDB Master集群上创建监控用户与监控数据库

```bash
bin/createuser mx-mdw  dbuser_monitor   # 在Master主库上创建监控用户
bin/createdb   mx-mdw  matrixmgr        # 在Master主库上创建监控专用数据库
bin/createdb   mx-mdw  meta             # 在Master主库上创建新数据库
bin/reloadhba  
```



